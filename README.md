# OSSLibraries

An open source license scanning and display library for HarmonyOS.

[中文文档](README_zh.md)

## Demo

![](./readme-assets/demo.jpg)

## Quick Start (with predefined UI)

### Add OHPM dependency

```zsh
ohpm install osslibraries_ui
```

### Register the Hvigor plugin

The license scanner is a standalone Hvigor plugin `osslibraries-hvigor-plugin` that runs before ArkTS compilation and writes `osslibraries.json` into the `rawfile` directory of the `entry` module (the target module can be customized; `entry` is used here as an example).

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
> plugins: [ossScanPlugin({ selfModules: ['mylibrary', '3rdlibrary'] })]
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

## Custom UI

You can skip the predefined OSSLibraries UI pages and use the `core` module directly:

```zsh
ohpm install osslibraries
```

Then read `osslibraries.json` in your custom page as follows:

```ets
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { Libs, LibsHolder } from 'osslibraries';

// Read osslibraries.json
const context: common.Context = this.getUIContext().getHostContext() as common.Context;
const content: Uint8Array = await context.resourceManager.getRawFileContent('osslibraries.json');
const json: string = util.TextDecoder.create('utf-8').decode(content);

// Parse JSON
const libs: Libs = Libs.fromJson(json);

// Find a library
const lib = libs.findLibrary('@ohos/hypium');

// Share data across pages
LibsHolder.set(libs);
```

## License

Mulan PSL v2

## Acknowledgements

This project references the implementation of [mikepenz/AboutLibraries](https://github.com/mikepenz/AboutLibraries) to some extent. Thanks for the inspiration.
