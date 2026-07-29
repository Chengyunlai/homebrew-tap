from __future__ import annotations

import argparse
import json
import re
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any

_REPOSITORY = "Chengyunlai/ops-agent"
_VERSION = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+$")
_SHA256 = re.compile(r"^[0-9a-f]{64}$")


@dataclass(frozen=True)
class ReleaseAsset:
    name: str
    url: str


@dataclass(frozen=True)
class Release:
    version: str
    assets: dict[str, ReleaseAsset]


def parse_release(payload: dict[str, Any]) -> Release:
    tag_name = payload.get("tag_name")
    if not isinstance(tag_name, str) or not tag_name.startswith("v"):
        raise ValueError("latest release tag must start with v")
    version = tag_name.removeprefix("v")
    if not _VERSION.fullmatch(version):
        raise ValueError("latest release tag must use vMAJOR.MINOR.PATCH")

    assets: dict[str, ReleaseAsset] = {}
    for value in payload.get("assets", []):
        if not isinstance(value, dict):
            continue
        name = value.get("name")
        url = value.get("browser_download_url")
        if isinstance(name, str) and isinstance(url, str):
            assets[name] = ReleaseAsset(name=name, url=url)
    return Release(version=version, assets=assets)


def parse_checksums(content: str) -> dict[str, str]:
    checksums: dict[str, str] = {}
    for line in content.splitlines():
        parts = line.split()
        if len(parts) != 2 or not _SHA256.fullmatch(parts[0]):
            raise ValueError(f"invalid SHA256SUMS line: {line!r}")
        checksums[parts[1]] = parts[0]
    return checksums


def render_formula(release: Release, checksums: dict[str, str]) -> str:
    target_assets = {
        target: f"ops-agent_{release.version}_{target}.tar.gz"
        for target in ("darwin-arm64", "darwin-amd64", "linux-amd64")
    }
    values: dict[str, tuple[str, str]] = {}
    for target, asset_name in target_assets.items():
        try:
            asset = release.assets[asset_name]
            checksum = checksums[asset_name]
        except KeyError as error:
            raise ValueError(f"release is missing {asset_name}") from error
        if not asset.url.startswith("https://github.com/Chengyunlai/ops-agent/"):
            raise ValueError(f"unexpected download URL for {asset_name}")
        if not _SHA256.fullmatch(checksum):
            raise ValueError(f"invalid checksum for {asset_name}")
        values[target] = (asset.url, checksum)

    darwin_arm_url, darwin_arm_sha = values["darwin-arm64"]
    darwin_amd_url, darwin_amd_sha = values["darwin-amd64"]
    linux_amd_url, linux_amd_sha = values["linux-amd64"]
    return f'''class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "{release.version}"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "{darwin_arm_url}"
      sha256 "{darwin_arm_sha}"
    else
      url "{darwin_amd_url}"
      sha256 "{darwin_amd_sha}"
    end
  end

  on_linux do
    url "{linux_amd_url}"
    sha256 "{linux_amd_sha}"
    depends_on arch: :x86_64
  end

  def install
    libexec.install "ops-agent"
    system "tar", "-czf", libexec/"_internal.tar.gz", "_internal"
    bin.install_symlink libexec/"ops-agent"
    bin.install_symlink libexec/"ops-agent" => "ops_agent"
    pkgshare.install "config.example.toml"
  end

  def post_install
    return if (libexec/"_internal").directory?

    system "tar", "-xzf", libexec/"_internal.tar.gz", "-C", libexec
    rm libexec/"_internal.tar.gz"
    system libexec/"ops-agent", "--version"
  end

  test do
    assert_match version.to_s, shell_output("#{{bin}}/ops-agent --version")
  end
end
'''


def fetch_json(url: str) -> dict[str, Any]:
    request = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "Chengyunlai/homebrew-tap",
            "X-GitHub-Api-Version": "2022-11-28",
        },
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        payload = json.load(response)
    if not isinstance(payload, dict):
        raise TypeError("GitHub API returned a non-object response")
    return payload


def fetch_text(url: str) -> str:
    request = urllib.request.Request(
        url,
        headers={"User-Agent": "Chengyunlai/homebrew-tap"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8")


def update_formula(output: Path) -> None:
    release = parse_release(
        fetch_json(f"https://api.github.com/repos/{_REPOSITORY}/releases/latest")
    )
    try:
        checksum_asset = release.assets["SHA256SUMS"]
    except KeyError as error:
        raise ValueError("release is missing SHA256SUMS") from error
    checksums = parse_checksums(fetch_text(checksum_asset.url))
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(render_formula(release, checksums), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Update the Ops Agent Formula from the latest GitHub release."
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path(__file__).parents[1] / "Formula/ops-agent.rb",
    )
    args = parser.parse_args()
    update_formula(args.output)
    print(args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
