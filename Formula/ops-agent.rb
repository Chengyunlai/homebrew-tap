class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "0.1.3"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.3/ops-agent_0.1.3_darwin-arm64.tar.gz"
      sha256 "1b5fd6c5d8c15c59921c0946b7146413cb96851f6c1ae54f69202d9fdce7abd1"
    else
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.3/ops-agent_0.1.3_darwin-amd64.tar.gz"
      sha256 "79eb37732588e989b2fa01b7dca31d80dd9d6bd54e46281eca9ac2f8ca5b80a9"
    end
  end

  on_linux do
    url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.3/ops-agent_0.1.3_linux-amd64.tar.gz"
    sha256 "4a3afdf41761647109b6cf15d03409477c5c31b96f89fd8f1e7d4b57ce9272d6"
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
