class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "0.1.12"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.12/ops-agent_0.1.12_darwin-arm64.tar.gz"
      sha256 "10b686a3d75b85412da5aef8d0294ae4deb5964aba3e68d020e55d098f3db663"
    else
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.12/ops-agent_0.1.12_darwin-amd64.tar.gz"
      sha256 "f44d6dac1e7be0c3d79de9256005fe76c52c1613d10bdcb935bc82314fd4c003"
    end
  end

  on_linux do
    url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.12/ops-agent_0.1.12_linux-amd64.tar.gz"
    sha256 "8d88eeaa996f13892d50aa6d9c4bf3948ec0a8cf4bc28e361041cd809674d1a3"
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
