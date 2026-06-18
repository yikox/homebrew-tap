class Quicklauncher < Formula
  desc "菜单栏快速启动器（QuickLauncher）"
  homepage "https://github.com/yikox/quick-launcher"
  url "https://github.com/yikox/quick-launcher/archive/refs/tags/v1.2.1.tar.gz"
  sha256 "4da3010bedf4a5357c034d4c16b660a77588bc701f7b59fef6be6535224c4050"
  license "MIT"

  # 只需 Swift 工具链（AppKit/SwiftUI/Yams 均在 Command Line Tools 的 SDK 内），
  # 不要求完整 Xcode；Homebrew 本就以 Command Line Tools 为前提。
  depends_on :macos

  def install
    ENV["VERSION"] = version.to_s
    # Homebrew 在自己的沙箱里构建，SwiftPM 解析 manifest 时还会嵌套调用
    # sandbox-exec（会被拒），用 --disable-sandbox 关掉 SwiftPM 那层沙箱。
    ENV["EXTRA_SWIFT_FLAGS"] = "--disable-sandbox"
    # 复用仓库里的打包脚本：swift build -c release + 组装 .app + ad-hoc 签名
    system "./scripts/build-app.sh"
    prefix.install "build/QuickLauncher.app"

    # 提供一个 CLI 入口，方便 `quicklauncher` 直接拉起
    (bin/"quicklauncher").write <<~SH
      #!/bin/bash
      open "#{opt_prefix}/QuickLauncher.app"
    SH
  end

  def caveats
    <<~EOS
      QuickLauncher.app 已安装到:
        #{opt_prefix}/QuickLauncher.app

      放进「应用程序」(可选):
        ln -sf "#{opt_prefix}/QuickLauncher.app" /Applications/QuickLauncher.app

      直接启动:
        quicklauncher

      开机自启请到「系统设置 ▸ 通用 ▸ 登录项」添加。
    EOS
  end

  test do
    assert_predicate prefix/"QuickLauncher.app/Contents/MacOS/QuickLauncher", :executable?
  end
end
