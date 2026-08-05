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

/**
 * Describes a complete License element.
 * Either retrieved from SPDX or downloaded from the artifact's repository.
 *
 * The `hash` field is the unique identifier — two License objects with the
 * same hash are considered equal.
 */
export class License {
  /** Internal hash used as the unique key for this license. */
  hash: string = '';
  /** Human-readable name of the license. */
  name: string = '';
  /** URL linking to the hosted form of this license. */
  url: string = '';
  /** Year of the license, if available. */
  year: string = '';
  /** SPDX identifier (e.g. "Apache-2.0", "MIT"). */
  spdxId: string = '';
  /** Full license text. */
  licenseContent: string = '';

  constructor(hash: string = '', name: string = '', url: string = '', spdxId: string = '',
              licenseContent: string = '', year: string = '') {
    this.hash = hash;
    this.name = name;
    this.url = url;
    this.spdxId = spdxId;
    this.licenseContent = licenseContent;
    this.year = year;
  }
}
