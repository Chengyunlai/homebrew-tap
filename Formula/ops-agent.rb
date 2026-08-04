class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "0.1.10"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.10/ops-agent_0.1.10_darwin-arm64.tar.gz"
      sha256 "a846bd239d9e8d6a7c178331822f139d2551bb084d1f16df82fca3eabeb22ce5"
    else
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.10/ops-agent_0.1.10_darwin-amd64.tar.gz"
      sha256 "8f74567046a234b3d1ec7947d24bf36a9213509ef31656dd801eb1ead79378e2"
    end
  end

  on_linux do
    url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.10/ops-agent_0.1.10_linux-amd64.tar.gz"
    sha256 "080eac3db5155b84138a78a2fd0128f237897fc8343052600df0389af055662d"
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
