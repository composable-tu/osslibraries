---
name: "osslibraries-usage"
description: "Guide for integrating OSSLibraries license scanning & display library in HarmonyOS. Invoke when adding the license list page, configuring the hvigor scan plugin, customizing UI, or troubleshooting osslibraries.json."
license: "MulanPSL-2.0"
---

# OSSLibraries Usage Guide

OSSLibraries is an open-source license scanning and display library for HarmonyOS, distributed as two OHPM packages:

- **`osslibraries`** (core): data models, JSON parser, and cross-page holder. Used for custom UI.
- **`osslibraries_ui`**: predefined list page, detail page, and `LicenseItem` component. Ready out of the box.

License data is generated at compile time by a standalone Hvigor plugin **`osslibraries-hvigor-plugin`** (npm package) that scans `oh_modules/` and produces `entry/src/main/resources/rawfile/osslibraries.json`.

## When to Use This Skill

- The user wants to display an "Open Source Licenses" page in a HarmonyOS app
- The user wants to integrate the predefined UI (`osslibraries_ui`) or build a custom UI (`osslibraries` core)
- The user wants to configure / troubleshoot the `osslibraries-hvigor-plugin` scan plugin
- The user wants to read or parse `osslibraries.json`
- The user wants to filter self-owned modules out of the license list

## Decide the Path First

Confirm the user's intended path before integrating:

| User goal                           | Package to install | Plugin needed?           | Import pages?               |
|-------------------------------------|--------------------|--------------------------|-----------------------------|
| Predefined pages, minimal code      | `osslibraries_ui`  | Yes                      | Yes (register named routes) |
| Fully custom UI                     | `osslibraries`     | Yes                      | No                          |
| Only read an already-generated JSON | `osslibraries`     | No (JSON already exists) | No                          |

> `osslibraries_ui` already depends on `osslibraries`; do not install core separately.

## Path A: Use the Predefined UI (Recommended)

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
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
import { ossScanPlugin } from 'osslibraries-hvigor-plugin';

export default {
  system: hapTasks,
  plugins: [ossScanPlugin()]
}
```

On each build, the plugin scans `oh_modules/` and generates `entry/src/main/resources/rawfile/osslibraries.json`.

**Filter self-owned modules**: pass dependency names for modules that should not appear in the list:

```ts
plugins: [ossScanPlugin({ selfModules: ['mylibrary', '3rdlibrary'] })]
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

## API Reference

### core (`osslibraries`) exports

| Name                                             | Type          | Description                                                              |
|--------------------------------------------------|---------------|--------------------------------------------------------------------------|
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
|-------------------|---------------------------|-------------------------------------------------------------------|
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
|---------------------------------|--------------------------------------------------------------|
| `OSSLibrariesLicenseListPage`   | List page (named route name is the same)                     |
| `OSSLibrariesLicenseDetailPage` | Detail page (named route name is the same)                   |
| `LicenseItem`                   | Single library card component                                |
| `buildTitleBarOpts`             | HdsNavigation title bar options builder                      |
| `getMaterialLevel`              | Material level probe                                         |
| `LicenseDetailParams`           | Detail page route params interface, field `uniqueId: string` |

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
    "hash1": { "hash": "hash1", "name": "Apache-2.0", "spdxId": "Apache-2.0", "url": "...", "content": "..." }
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
