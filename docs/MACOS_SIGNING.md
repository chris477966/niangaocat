# macOS 签名、公证与监听权限

## 每位 macOS 用户须知

本分支尚未发布经 Apple Developer ID 签名及公证的安装包。源码公开、MIT 授权或本地签名校验成功，都不代表 Apple 已验证发布者或完成公证。

- **用户不需要购买 Apple Developer Program，也不需要自己申请证书。** 正式签名与公证应由发布者完成。
- macOS 的输入监控／辅助功能授权与应用的代码身份有关。未完整签名、临时签名或升级时改变签名要求，都可能使旧授权失效，即使开关仍显示已开启。
- 本机曾在上游 4.7.0、4.9.1 安装包中检查到整个 App 签名校验失败。补签并重建两项权限后，4.9.1 的监听通道已启用且订阅键盘按下／松开事件。这是单台 Mac 的诊断，不代表所有用户都会遇到或都已修复。
- Developer ID、公证与系统隐私授权是不同机制；签名、公证不能自动授予键盘权限，也不能保证所有升级场景都无需重新授权。

若可信安装包升级后失灵：退出程序，在「输入监控」及「辅助功能」（部分系统称「设备控制和数据访问」）删除旧 KuroCat 条目，重新添加实际安装路径的 App、启用并重启。若仍失灵，先验证签名，避免反复盲目授权：

```sh
codesign --verify --strict --all-architectures --verbose=2 /Applications/KuroCat.app
codesign -d --verbose=4 /Applications/KuroCat.app
```

本分支保留 `KuroCat.app` 和 `com.kurocat.pet`，兼容已有设置及 MCP 路径；项目名 NianGaoCat 是分支名称。不要同时运行上游与本分支；安装前备份设置与皮肤，分支的自动更新地址已改为 `chris477966/niangaocat`，避免被上游更新覆盖。

## 发布者：正式分发流程

需要发布者自己的 Apple Developer Program 资格、有效 **Developer ID Application** 证书及其私钥、notarytool 认证信息。此仓库不包含这些凭据；本次工作环境检查到 **0 个有效代码签名身份**。不能伪造 Apple 证书或把 ad hoc 签名宣称为 Developer ID 签名。

1. 在发布专用 Mac 的钥匙串中安装证书和私钥（切勿提交 `.p12`、`.p8`、密码或 Token）。
2. 按 Apple 文档运行 `xcrun notarytool store-credentials niangaocat-notary`，交互式保存认证信息至钥匙串。不要在公开日志或聊天里粘贴密钥。
3. 构建 Universal App，然后执行：

```sh
export APPLE_SIGNING_IDENTITY='Developer ID Application: YOUR NAME (TEAMID)'
export APPLE_NOTARY_PROFILE='niangaocat-notary'
bash scripts/sign-macos-app.sh \
  src-tauri/target/universal-apple-darwin/release/bundle/macos/KuroCat.app
```

脚本完成 Hardened Runtime 签名、所有架构的完整签名验证、`notarytool submit --wait`、ticket stapling／校验及 Gatekeeper 检查。当前 App 无内嵌第三方 framework；未来新增嵌套可执行文件时，应先由内到外逐项签名，不能依赖 `--deep` 掩盖签名问题。若公证失败应检查 Apple 的提交日志，不得继续发布为“已公证”。

4. 使用**同一份已签名并 stapled 的 App**制作 DMG 与更新压缩包。DMG 还应签名、提交公证及 staple，并对最终下载包做解包验证和真实升级测试。
5. 在干净系统与已有版本上测试：首次安装、普通输入框键盘／鼠标反馈、密码保护、休眠恢复、升级后的隐私授权及银点皮肤。

本仓库现有 GitHub 托管 runner **尚未配置证书导入与公证认证**。macOS tag 发布会在缺少 Developer ID 时失败关闭；手动构建仅生成明确未公证的测试产物。上面的正式签名脚本已提供，但 Developer ID 路径未实测，也未据此发布二进制安装包。其他平台构建沿用上游流程。

## 本地测试签名（不等于公证）

仅对自己信任并检查过的测试 App 使用：

```sh
ALLOW_ADHOC=1 bash scripts/sign-macos-app.sh /path/to/test/KuroCat.app
```

此路径补齐整个 App 的 ad hoc 签名并验证，不能提供 Apple 发布者身份，不能消除所有 Gatekeeper 提示，也不能保证升级后 TCC 权限延续。正式 tag 构建不会静默降级到此模式。

## Apple 官方参考

- [Signing Mac Software with Developer ID](https://developer.apple.com/developer-id/)
- [Developer ID certificates](https://developer.apple.com/help/account/certificates/create-developer-id-certificates)
- [Notarizing macOS software before distribution](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)
