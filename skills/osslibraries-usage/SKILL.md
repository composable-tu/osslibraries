---
name: "osslibraries-usage"
description: "Guide for integrating OSSLibraries license scanning & display library in HarmonyOS. Invoke when adding the license list page (phone or wearable UI), configuring the hvigor scan plugin, customizing UI, or troubleshooting osslibraries.json."
license: "MulanPSL-2.0"
---

# OSSLibraries Usage Guide

OSSLibraries is an open-source license scanning and display library for HarmonyOS, distributed as OHPM packages:

- **`osslibraries`** (core): data models, JSON parser, and cross-page holder. Used for custom UI.
- **`osslibraries_ui`**: predefined list page, detail page, and `LicenseItem` component for phone/tablet. Ready out of the box.
- **`osslibraries_ui_wear`**: predefined list page, detail page, and `WearLicenseListItem` component for wearable devices. Adapts to screen shape via `display.screenShape`: round faces use ArkUI `ArcList` (digital-crown scroll, chain animation), square faces fall back to a regular `List`.

License data is generated at compile time by a standalone Hvigor plugin **`osslibraries-hvigor-plugin`** (npm package) that scans `oh_modules/` and produces `entry/src/main/resources/rawfile/osslibraries.json`.

## Cangjie HarmonyOS Support

Not supported. Per Huawei's documentation:

> 在开发仓颉应用时，通过调用 ArkTS 已有库复用 ArkTS 丰富的库生态。仓颉应用中不支持增加 ArkTS 页面，但支持增加 ArkTS 模块。ArkTS 库分为 NAPI (Node.js API) 模块和三方库模块，仓颉当前支持调用 NAPI 模块，但不支持三方库模块，调用 NAPI 模块的方式可参见仓颉调用 ArkTS。

Two independent blockers apply to this library:

1. **No ArkTS pages**: Cangjie HarmonyOS apps cannot add ArkTS pages, and `osslibraries_ui` is built on ArkTS pages.
2. **No third-party ArkTS libraries**: Cangjie HarmonyOS apps cannot call third-party ArkTS library modules, and `osslibraries` / `osslibraries_ui` are third-party OHPM packages (not NAPI modules).

## When to Use This Skill

- The user wants to display an "Open Source Licenses" page in a HarmonyOS app
- The user wants to integrate the predefined phone UI (`osslibraries_ui`) or wearable UI (`osslibraries_ui_wear`), or build a custom UI (`osslibraries` core)
- The user wants to configure / troubleshoot the `osslibraries-hvigor-plugin` scan plugin
- The user wants to read or parse `osslibraries.json`
- The user wants to filter self-owned modules out of the license list
- **Not applicable**: Cangjie HarmonyOS apps are not supported

## Decide the Path First

Confirm the user's intended path before integrating:

| User goal                           | Package to install     | Plugin needed?           | Import pages?               |
| ----------------------------------- | ---------------------- | ------------------------ | --------------------------- |
| Predefined pages (phone/tablet)     | `osslibraries_ui`      | Yes                      | Yes (register named routes) |
| Predefined pages (wearable)         | `osslibraries_ui_wear` | Yes                      | Yes (register named routes) |
| Fully custom UI                     | `osslibraries`         | Yes                      | No                          |
| Only read an already-generated JSON | `osslibraries`         | No (JSON already exists) | No                          |

> `osslibraries_ui` and `osslibraries_ui_wear` already depend on `osslibraries`; do not install core separately.

## Path A: Use the Predefined Phone UI (Recommended)

### 1. Install dependencies

```zsh
# OHPM package (HarmonyOS module)
ohpm install osslibraries_ui

# npm package (Hvigor plugin, installed at project root)
npm install osslibraries-hvigor-plugin --save-dev
# or: pnpm add osslibraries-hvigor-plugin -D
```

### 2. Register the Hvigor plugin

Edit the `hvigorfile.ts` of the **target module** (typically `entry/hvigorfile.ts`):

```ts
import { hapTasks } from "@ohos/hvigor-ohos-plugin";
import { ossScanPlugin } from "osslibraries-hvigor-plugin";

export default {
  system: hapTasks,
  plugins: [ossScanPlugin()],
};
```

On each build, the plugin scans `oh_modules/` and generates `entry/src/main/resources/rawfile/osslibraries.json`.

**Filter self-owned modules**: pass dependency names for modules that should not appear in the list:

```ts
plugins: [ossScanPlugin({ selfModules: ["mylibrary", "3rdlibrary"] })];
```

### 3. Import the HAR pages (register named routes)

At the top of a page file in the `entry` module (e.g. `Index.ets`):

```ets
import 'osslibraries_ui/src/main/ets/pages/OSSLibrariesLicenseListPage';
import 'osslibraries_ui/src/main/ets/pages/OSSLibrariesLicenseDetailPage';
```

`entry/src/main/resources/base/profile/main_pages.json` **does not need changes** — keep only its own pages.

### 4. Navigate to the license list page

From any page:

```ets
this.getUIContext().getRouter().pushNamedRoute({
  name: 'OSSLibrariesLicenseListPage'
});
```

The list page already implements: load JSON → `LibsHolder.set(libs)` → tap an item to navigate to the detail page.

## Path B: Custom UI

### 1. Install dependencies

```zsh
ohpm install osslibraries
# The hvigor plugin is still required to generate the JSON (repeat steps 1–2 of Path A)
```

### 2. Read and parse osslibraries.json

```ets
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { Libs, LibsHolder } from 'osslibraries';

// Read rawfile
const context: common.Context = this.getUIContext().getHostContext() as common.Context;
const content: Uint8Array = await context.resourceManager.getRawFileContent('osslibraries.json');
const json: string = util.TextDecoder.create('utf-8').decode(content);

// Parse (libraries are sorted by name)
const libs: Libs = Libs.fromJson(json);

// Look up a library
const lib = libs.findLibrary('@ohos/hypium');

// Share across pages
LibsHolder.set(libs);
```

### 3. Reuse predefined components (optional)

`osslibraries_ui` also exports standalone components and helpers:

```ets
import { LicenseItem, buildTitleBarOpts, getMaterialLevel } from 'osslibraries_ui';
```

- `LicenseItem`: single library info card, accepts `@Prop lib: Library`.
- `buildTitleBarOpts(title, materialLevel, contentOverrides?)`: builds HdsNavigation title bar options.
- `getMaterialLevel()`: returns the appropriate material level based on whether the system supports IMMERSIVE material.

## Path C: Use the Predefined Wearable UI

For round wearable faces. Built on ArkUI `ArcList` (API version 18+, Wearable-only). Does not depend on `@kit.UIDesignKit`.

### 1. Install dependencies

```zsh
# OHPM package
ohpm install osslibraries_ui_wear

# npm package (Hvigor plugin, installed at project root)
npm install osslibraries-hvigor-plugin --save-dev
```

### 2. Register the Hvigor plugin

Edit the `hvigorfile.ts` of the **wearable HAP module** (typically `entry_wear/hvigorfile.ts`):

```ts
import { hapTasks } from "@ohos/hvigor-ohos-plugin";
import { ossScanPlugin } from "osslibraries-hvigor-plugin";

export default {
  system: hapTasks,
  plugins: [ossScanPlugin()],
};
```

On each build, the plugin scans `oh_modules/` and generates `entry_wear/src/main/resources/rawfile/osslibraries.json`.

### 3. Build setup (wearable product)

Before building, add a `wearable` product to the root `build-profile.json5` (see `build-profile.json5_example` in the repo), then build with:

```zsh
hvigorw assembleHap -p product=wearable
```

### 4. Import the HAR pages (register named routes)

At the top of a page file in the wearable HAP module (e.g. `Index.ets`):

```ets
import 'osslibraries_ui_wear/src/main/ets/pages/OSSLibrariesLicenseListPageWear';
import 'osslibraries_ui_wear/src/main/ets/pages/OSSLibrariesLicenseDetailPageWear';
```

### 5. Navigate to the license list page

From any page:

```ets
this.getUIContext().getRouter().pushNamedRoute({
  name: 'OSSLibrariesLicenseListPageWear'
});
```

### Wearable UI behavior (differs from phone UI)

- **Pages & routes**: list page struct `OSSLibrariesLicenseListPageWear` registers route **`OSSLibrariesLicenseListPageWear`** (this is the route you push to enter). Detail page struct `OSSLibrariesLicenseDetailPageWear` registers route `OSSLibrariesLicenseDetailPageWear` — you don't push it manually; the list page navigates to it via `pushNamedRoute` on item tap. Both route names are centralized in `WearRouteNames.ets` (`WEAR_LIST_PAGE_ROUTE` / `WEAR_DETAIL_PAGE_ROUTE`); host apps should import and reuse these constants instead of string literals.
- **Layout**: both pages detect the screen shape via `display.screenShape` (`WearScreenUtil`). Round screens render inside a 466×466 `ArcList` (with `header`-based title); square screens fall back to a regular `List` at `width('100%')`. List page title: "开放源代码许可" / "Open Source Licenses"; detail page title: the selected library's name.
- **Card sizing**: `ArcListItem` cards have no fixed height — they auto-size to content. Long license text scrolls inside the `ArcList`; the license item sets `autoScale(false)` to prevent text distortion near the circle edges.
- **Link tap = copy**: wearable devices have no standalone browser. Tapping a link card (website / scm.url) copies the URL to the system clipboard and shows a "已复制" / "Copied" toast — it does **not** open the URL.
- **List item**: `WearLicenseListItem` shows library name (primary) and a `v{version} · {license}` subtitle (secondary), left-aligned.
- **Dependencies**: only `osslibraries` core. No `@kit.UIDesignKit`.

## API Reference

### core (`osslibraries`) exports

| Name                                             | Type          | Description                                                              |
| ------------------------------------------------ | ------------- | ------------------------------------------------------------------------ |
| `Libs`                                           | class         | Main entry point. Holds `libraries: Library[]` and `licenses: License[]` |
| `Libs.fromJson(json)`                            | static method | Builds from a JSON string; libraries sorted by name                      |
| `libs.findLibrary(uniqueId)`                     | method        | Finds a library by uniqueId; returns `undefined` if not found            |
| `libs.findLicense(hash)`                         | method        | Finds a license by hash                                                  |
| `LibsHolder`                                     | class         | Static holder; `set(libs)` / `get()` to share across pages               |
| `Parser` / `ParseResult`                         | class         | Low-level parser; `Libs.fromJson` is usually enough                      |
| `SortUtil.compareLibraryByName`                  | method        | Case-insensitive library name comparator                                 |
| `Library`                                        | class         | Full metadata of a single dependency                                     |
| `License`                                        | class         | License info; `hash` is the unique key                                   |
| `Developer` / `Organization` / `Scm` / `Funding` | class         | Sub-entities                                                             |

### `Library` fields

| Field             | Type                      | Description                                                       |
| ----------------- | ------------------------- | ----------------------------------------------------------------- |
| `uniqueId`        | string                    | Unique identifier (typically packageName without version)         |
| `artifactVersion` | string                    | Version                                                           |
| `name`            | string                    | Display name                                                      |
| `description`     | string                    | Description                                                       |
| `website`         | string                    | Website                                                           |
| `developers`      | Developer[]               | Developer list                                                    |
| `organization`    | Organization \| undefined | Organization                                                      |
| `scm`             | Scm \| undefined          | Source control info                                               |
| `licenses`        | License[]                 | Associated licenses (resolved from hash references at parse time) |
| `funding`         | Funding[]                 | Funding channels                                                  |
| `tag`             | string                    | Grouping tag                                                      |
| `artifactId`      | getter                    | Returns `uniqueId:artifactVersion`                                |
| `openSource`      | getter                    | `true` when `scm.url` is non-empty                                |

### `License` fields

`hash` (unique key), `name`, `url`, `year`, `spdxId` (e.g. "Apache-2.0"), `licenseContent` (full text).

### ui (`osslibraries_ui`) exports

| Name                            | Description                                                  |
| ------------------------------- | ------------------------------------------------------------ |
| `OSSLibrariesLicenseListPage`   | List page (named route name is the same)                     |
| `OSSLibrariesLicenseDetailPage` | Detail page (named route name is the same)                   |
| `LicenseItem`                   | Single library card component                                |
| `buildTitleBarOpts`             | HdsNavigation title bar options builder                      |
| `getMaterialLevel`              | Material level probe                                         |
| `LicenseDetailParams`           | Detail page route params interface, field `uniqueId: string` |

Route names are centralized in `RouteNames.ets` (`UI_LIST_PAGE_ROUTE` / `UI_DETAIL_PAGE_ROUTE`); host apps should import and reuse these constants instead of string literals.

### ui_wear (`osslibraries_ui_wear`) exports

| Name                                | Description                                                                                    |
| ----------------------------------- | ---------------------------------------------------------------------------------------------- |
| `OSSLibrariesLicenseListPageWear`   | Wearable list page. Route name: `OSSLibrariesLicenseListPageWear`                              |
| `OSSLibrariesLicenseDetailPageWear` | Wearable detail page. Route name: `OSSLibrariesLicenseDetailPageWear`                          |
| `WearLicenseListItem`               | Wearable list item component, accepts `@Prop lib: Library`                                     |
| `LicenseDetailParams`               | Detail page route params interface, field `uniqueId: string` (same shape as `osslibraries_ui`) |

### osslibraries.json structure

```json
{
  "libraries": [
    {
      "uniqueId": "@ohos/hypium",
      "artifactVersion": "1.0.25",
      "name": "hypium",
      "description": "...",
      "website": "...",
      "developers": [{ "name": "...", "organisationUrl": "..." }],
      "organization": { "name": "...", "url": "..." },
      "scm": { "connection": "", "developerConnection": "", "url": "..." },
      "licenses": ["hash1"],
      "funding": [{ "platform": "...", "url": "..." }],
      "tag": ""
    }
  ],
  "licenses": {
    "hash1": {
      "hash": "hash1",
      "name": "Apache-2.0",
      "spdxId": "Apache-2.0",
      "url": "...",
      "content": "..."
    }
  }
}
```

`libraries[].licenses` is an array of hash strings, resolved against the top-level `licenses` map.

## Troubleshooting

### List page is blank / shows "load failed"

1. Verify `osslibraries-hvigor-plugin` is registered in the target module's `hvigorfile.ts`.
2. Verify a build has been run and `entry/src/main/resources/rawfile/osslibraries.json` exists and is non-empty.
3. Verify `osslibraries_ui` was installed via OHPM (not linked as a local workspace module).

### Named route navigation fails with "route does not exist"

- A loaded page file must `import 'osslibraries_ui/src/main/ets/pages/OSSLibrariesLicenseListPage'` at its top — importing registers the named route.
- Do not add these two pages to `main_pages.json`.

### Self-owned modules appear in the license list

- Filter them with `ossScanPlugin({ selfModules: ['dependency-name'] })`.
