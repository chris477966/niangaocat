# NianGaoCat 分支更新记录

## 2026-11-24 — 银点形象与 macOS 发布说明（源码更新）

1. 新增内置「🤍 我家银点」：银白／奶白底毛、灰蓝眼睛、粉色鼻耳、浅银灰额纹和前腿纹、冰蓝按键反馈。独立 JSON 预设可通过 MCP 导入。使用同一预设嵌入桌面端皮肤列表，保留现有用户选择。
2. README 顶部新增每位 macOS 用户须知，说明 Developer ID、公证、系统隐私授权各自的职责。明确当前未完成正式签名、公证，不要求用户购买开发者账号。
3. macOS 打包前验证完整 App 签名；仅允许显式选择的手动测试使用 ad hoc，正式 tag 缺少 Developer ID 时拒绝发布 macOS 包。提供本地 Developer ID／notarytool 发布脚本及剩余配置说明。
4. 自动更新来源改为本分支，避免上游升级覆盖分支改动。

本次不发布正式二进制版本；上游版本字段暂保持 4.9.1。项目展示名为 NianGaoCat，应用包／Bundle ID 为兼容历史设置仍沿用 KuroCat。

## 致谢与许可

本项目基于 [qianyiai/kurocat](https://github.com/qianyiai/kurocat)，同步基线为 `5555f0af467fb4c64b33a4b0eea8f18dc0a06c34`。感谢原作者 qianyiai 与 KuroCat Contributors 提供桌宠渲染、全局键鼠监听、MCP 和跨平台基础。保留上游 MIT LICENSE 和版权声明。
