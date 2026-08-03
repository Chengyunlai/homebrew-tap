class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "0.1.8"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.8/ops-agent_0.1.8_darwin-arm64.tar.gz"
      sha256 "3900b20c0b03300991332471e8b49b8907ef0d824ff37bc74555bba759d16f6f"
    else
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.8/ops-agent_0.1.8_darwin-amd64.tar.gz"
      sha256 "3f189406e7d5506daf973b5f392ab05b33aaca95781f0ba6f058229c3e32d5a6"
    end
  end

  on_linux do
    url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.8/ops-agent_0.1.8_linux-amd64.tar.gz"
    sha256 "6b07eb44ca490edda589d03c922dad35e959bb9dc9bd87aa9f2d44a996e1607f"
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
