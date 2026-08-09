# Changelog

## v0.0.4

- 新增：MessagePack（`osslibraries.msgpack`）解析能力。
- 新增：`LibsLoader.fromRawfile(context)` 能力，确保 UI 层调用即获取数据。

## v0.0.3

- 同步 `osslibraries-hvigor-plugin` 上游更改，将 `tag` 字段从 `string` 类型修改为 `string[]` 类型。

## v0.0.2

- 更新 README 与包描述部分。
- 修复缺少 `licenseContent` 时空许可证卡片渲染问题。
- 当许可证名称为空时回退显示 SPDX ID（或 `hash`），以避免出现空白徽章问题。

## v0.0.1

第一次发布。
