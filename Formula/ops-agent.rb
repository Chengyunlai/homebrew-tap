class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "0.1.7"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.7/ops-agent_0.1.7_darwin-arm64.tar.gz"
      sha256 "7d399c5e6a13985eb4597de05f8ddfb6de08ac1076bb156bd7965e42e015cb87"
    else
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.7/ops-agent_0.1.7_darwin-amd64.tar.gz"
      sha256 "2e88bab99ba90d45501f1dba0b54dc969b187d46d9b0adbdc2f537e58b94bfe7"
    end
  end

  on_linux do
    url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.7/ops-agent_0.1.7_linux-amd64.tar.gz"
    sha256 "464cef5375cd1bba580215c32f64e96b206e248a5550980db1f23af5f6c0540a"
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
