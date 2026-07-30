class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "0.1.6"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.6/ops-agent_0.1.6_darwin-arm64.tar.gz"
      sha256 "9196f0a6ad4d4e5d80e6d7cd9ae7472823d19ef3178f2c6e2e10ea87ee11bebb"
    else
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.6/ops-agent_0.1.6_darwin-amd64.tar.gz"
      sha256 "ba3a90436764bbcf55639d14ed3a316e908f972544312ec2c56efb64a2debc74"
    end
  end

  on_linux do
    url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.6/ops-agent_0.1.6_linux-amd64.tar.gz"
    sha256 "46dc2837d119339b748cd48a73d6b0bb3131a3d52414e7bcfc792f5df6048a8b"
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
