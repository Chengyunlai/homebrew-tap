class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "0.1.9"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.9/ops-agent_0.1.9_darwin-arm64.tar.gz"
      sha256 "da390f309ae2738ec635de6257005fb863d25385e3e17451305e8ede3f9186ca"
    else
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.9/ops-agent_0.1.9_darwin-amd64.tar.gz"
      sha256 "a13f5a62ef958d14238c234bee1cba63c6bd13dfaea20ba699003a0648776e5a"
    end
  end

  on_linux do
    url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.9/ops-agent_0.1.9_linux-amd64.tar.gz"
    sha256 "98bed8ae3c304e0a2d6ed29bd72674e2a41a745dfed8efff3cac498bd90c0bd1"
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
