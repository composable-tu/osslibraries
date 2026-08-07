/**
 * Copyright (c) 2026 composable-tu
 * OSSLibraries UI (Wearable) is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan PSL v2.
 * You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
 * MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 * See the Mulan PSL v2 for more details.
 */

/**
 * Router parameters for navigating to the license detail page.
 * Declared ONCE here and imported by both the list and detail pages.
 */
export interface LicenseDetailParams {
  /** The uniqueId of the library to display. */
  uniqueId: string;
}
