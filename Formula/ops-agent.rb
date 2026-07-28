class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "0.1.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.0/ops-agent_0.1.0_darwin-arm64.tar.gz"
      sha256 "5ccf2314f5e9e105eea12dd221b633f308c83b3fffe5cb7e296238ce5c5b1e35"
    else
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.0/ops-agent_0.1.0_darwin-amd64.tar.gz"
      sha256 "f4a07f75ce2d3002b9efc7485dd3e6fdf900004cc31ebb73b65b397a3cb0d5ea"
    end
  end

  on_linux do
    url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.0/ops-agent_0.1.0_linux-amd64.tar.gz"
    sha256 "83a54686623ed83718fd99efab5ad9e7d5350cf58a04473b7041cb50df77ed04"
    depends_on arch: :x86_64
  end

  def install
    bin.install "ops-agent", "ops_agent"
    pkgshare.install "config.example.toml"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ops-agent --version")
  end
end
