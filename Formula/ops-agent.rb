class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "0.1.2"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.2/ops-agent_0.1.2_darwin-arm64.tar.gz"
      sha256 "b1623c1707f70a9fd92f06956276a6de671be449396d1d221525dc849229a8d0"
    else
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.2/ops-agent_0.1.2_darwin-amd64.tar.gz"
      sha256 "0fecbd746143cf6f254c76f7c380eb6c17b4a7c2f5f0578fe3192e11de502fa9"
    end
  end

  on_linux do
    url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.2/ops-agent_0.1.2_linux-amd64.tar.gz"
    sha256 "920e32784a8905636faa7cc06e50e89caa09692f4053c05ca2cec61ef6a2e57a"
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
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ops-agent --version")
  end
end
