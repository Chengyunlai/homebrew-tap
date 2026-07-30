class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "0.1.4"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.4/ops-agent_0.1.4_darwin-arm64.tar.gz"
      sha256 "6c6a2f6f78744bf603b9adf25d9fd7ed9a5614bc81c4c26c4838398967cc7d7f"
    else
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.4/ops-agent_0.1.4_darwin-amd64.tar.gz"
      sha256 "44f39a9c422b58bfac60f97adf17596dd9457e7cb8b921bdd2001a9618bf4a63"
    end
  end

  on_linux do
    url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.4/ops-agent_0.1.4_linux-amd64.tar.gz"
    sha256 "d6764ce2c2a16a03d34213151d3d76e9101dd9dfa036ccae1b950306ffb1b875"
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
    assert_match version.to_s, shell_output("#{bin}/ops-agent --version")
  end
end
