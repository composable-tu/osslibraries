# Changelog

## v0.0.3

- 列表页改用 `osslibraries` 的 `LibsLoader.fromRawfile` 加载数据。
- 更新 `osslibraries` 上游依赖版本至 0.0.4：
    - 新增：MessagePack（`osslibraries.msgpack`）解析能力。

## v0.0.2

- 新增：方形表盘屏幕适配。OSSLibraries UI（Wearable）现在会根据穿戴设备屏幕形态自适应选择显示 ArcList 还是普通 List。
- 修复：`copyUrl` 中 `setData` 的 Promise reject 未捕获（静默失败）问题。

## v0.0.1

第一次发布。
