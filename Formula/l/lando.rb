class Lando < Formula
  desc "Push button development environments"
  homepage "https://docs.lando.dev"
  url "https://github.com/lando/core/archive/refs/tags/v3.23.2.tar.gz"
  sha256 "a3edf4c1d82ce6af725d9760122f74e8ed74d453140d12407bf5764f19b145d5"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "node"

  def install
    system "npm", "install", "--production", *std_npm_args
    system "npm", "add", "@yao-pkg/pkg@5.15.0"
    system "npx", "pkg", "--config", "package.json", "--targets", "node20",
     "--options", "'dns-result-order=ipv4first'", "bin/lando"
    bin.install "dist/@lando/core" => "lando"
  end

  def caveats
    <<~EOS
      To complete the installation:
        lando setup
    EOS
  end

  test do
    assert_match "127.0.0.1", shell_output("#{bin}/lando config --path proxyIp")
  end
end
