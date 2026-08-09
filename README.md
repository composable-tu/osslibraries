# OSSLibraries

An open source license scanning and display library for HarmonyOS.

![](./readme-assets/banner.png)

[中文文档](README_zh.md)

> [!NOTE]
> This library does not support Cangjie HarmonyOS apps. Per Huawei's documentation, Cangjie HarmonyOS apps cannot add ArkTS pages or call third-party ArkTS libraries; this library is a third-party library built on ArkTS pages and components.

## Features

- **End-to-end** — scans your dependencies at build time and displays the license list in your app. No manual JSON editing, no drift.
- **Prebuilt UI pages** — drop-in list and detail pages built on ArkUI & UI Design Kit components.
- **Custom UI, no problem** — use the core package alone to load and parse the license data and render it in any UI you build.
- **Always up to date** — the Hvigor plugin scans `oh_modules/` on every build. The license list always matches what you ship.
- **AI-assisted integration** — ships an Agent Skill so an AI can wire the library into your project for you.

## Demo

![](./readme-assets/demo.jpg)

## Quick Start (with predefined UI)

> [!TIP]
> You can install the Agent Skills provided by this library to let an AI Agent help integrate it into your HarmonyOS project quickly:
>
> ```zsh
> npx skills add composable-tu/osslibraries
> ```

### Add OHPM dependency

```zsh
ohpm install osslibraries_ui
```

### Register the Hvigor plugin

The license scanner is a standalone Hvigor plugin [`osslibraries-hvigor-plugin`](https://github.com/composable-tu/osslibraries-hvigor-plugin) that runs before ArkTS compilation and writes `osslibraries.json` into the `rawfile` directory of the `entry` module (the target module can be customized; `entry` is used here as an example).

Install via npm:

```zsh
npm install osslibraries-hvigor-plugin --save-dev
```

Other package managers also work:

```zsh
yarn add osslibraries-hvigor-plugin --dev
pnpm add osslibraries-hvigor-plugin -D
vp add osslibraries-hvigor-plugin -D
vlt install osslibraries-hvigor-plugin -D
bun add osslibraries-hvigor-plugin -D
```

Then edit `entry/hvigorfile.ts` to register the plugin:

```TS
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
import { ossScanPlugin } from 'osslibraries-hvigor-plugin';

export default {
  system: hapTasks,
  plugins: [ossScanPlugin()]
}
```

> [!TIP]
> If you have modules that should not appear in the license list, pass their dependency names to `selfModules`:
>
> ```ts
> plugins: [ossScanPlugin({ selfModules: ["mylibrary", "3rdlibrary"] })];
> ```

On each build, the plugin scans `oh_modules/` and generates `entry/src/main/resources/rawfile/osslibraries.json`.

### Import the HAR pages (register named routes)

At the top of a page file in the `entry` module (e.g. `Index.ets`), add:

```ets
import 'osslibraries_ui/src/main/ets/pages/OSSLibrariesLicenseListPage';
import 'osslibraries_ui/src/main/ets/pages/OSSLibrariesLicenseDetailPage';
```

No changes are needed in `entry`'s `main_pages.json` — just keep its own pages.

### Navigate to the license list page

From any page in your app, navigate via `pushNamedRoute`:

```ets
this.getUIContext().getRouter().pushNamedRoute({
  name: 'OSSLibrariesLicenseListPage'
});
```

## Wearable Integration (with predefined UI)

The OSSLibraries UI for wearable devices is a separate `osslibraries_ui_wear` module:

```zsh
ohpm install osslibraries_ui_wear
```

Register the Hvigor plugin in the wearable module, same as for `osslibraries_ui`:

```TS
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
import { ossScanPlugin } from 'osslibraries-hvigor-plugin';

export default {
  system: hapTasks,
  plugins: [ossScanPlugin()]
}
```

At the top of a page file in the wearable module (e.g. `Index.ets`), import the pages to register the named routes:

```ets
import 'osslibraries_ui_wear/src/main/ets/pages/OSSLibrariesLicenseListPageWear';
import 'osslibraries_ui_wear/src/main/ets/pages/OSSLibrariesLicenseDetailPageWear';
```

Then navigate via `pushNamedRoute`:

```ets
this.getUIContext().getRouter().pushNamedRoute({
  name: 'OSSLibrariesLicenseListPageWear'
});
```

## Custom UI

You can skip the predefined OSSLibraries UI pages and use the `core` module directly:

```zsh
ohpm install osslibraries
```

The core package handles data loading and parsing. In your custom page, call `LibsLoader.fromRawfile(context)` to get a sorted `Libs` instance:

```ets
import { common } from '@kit.AbilityKit';
import { Libs, LibsHolder, LibsLoader } from 'osslibraries';

const context: common.Context = this.getUIContext().getHostContext() as common.Context;

const libs: Libs = await LibsLoader.fromRawfile(context);

// Find a library
const lib = libs.findLibrary('@ohos/hypium');

// Share data across pages
LibsHolder.set(libs);
```

## License

Mulan PSL v2

## Acknowledgements

This project references the implementation of [mikepenz/AboutLibraries](https://github.com/mikepenz/AboutLibraries) to some extent. Thanks for the inspiration.
