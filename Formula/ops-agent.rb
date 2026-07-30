class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "0.1.5"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.5/ops-agent_0.1.5_darwin-arm64.tar.gz"
      sha256 "d5a936300c5699d7c3521e124a14f0ec7cd09c12933898b8cecea693f11f6f8c"
    else
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.5/ops-agent_0.1.5_darwin-amd64.tar.gz"
      sha256 "cdbb7064d1d716a8111a860873e8d2709edc1dc403fd3583f34842a012963210"
    end
  end

  on_linux do
    url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.5/ops-agent_0.1.5_linux-amd64.tar.gz"
    sha256 "d7b0978a5669b71e05f8bb4cfb6f38d457f465a58399612a4604509776d1fa79"
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
