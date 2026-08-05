# Changelog

## v0.0.4

- 优化了 OSSLibraries UI 视觉效果，包括卡片样式、点击态样式、详情页标题样式。
- 优化了点击守卫条件：手指偏移阈值从 `1vp` 放宽为 `5vp`。

## v0.0.3

- 适配 `osslibraries-hvigor-plugin` 上游更改，现在许可证名称和 SPDX ID 均为空时不再向 UI 展示 `hash`。

## v0.0.2

- 更新 `osslibraries` 上游依赖版本至 0.0.2。
- 修复：`osslibraries_ui` 的 `osslibraries` 依赖指向本地而非 OHPM 的问题。
- 修复缺少 `licenseContent` 时空许可证卡片渲染问题。
- 当许可证名称为空时回退显示 SPDX ID（或 `hash`），以避免出现空白徽章问题。

## v0.0.1

第一次发布。
