/**
 * Copyright (c) 2026 composable-tu
 * OSSLibraries is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan PSL v2.
 * You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
 * MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 * See the Mulan PSL v2 for more details.
 */

import { Libs } from '../Libs';

/**
 * A simple static holder for sharing a `Libs` instance between pages.
 *
 * The list page sets the data before navigating to the detail page;
 * the detail page reads it to look up the selected library.
 */
export class LibsHolder {
  private static libs: Libs | undefined = undefined;

  static set(libs: Libs | undefined): void {
    LibsHolder.libs = libs;
  }

  static get(): Libs | undefined {
    return LibsHolder.libs;
  }
}
