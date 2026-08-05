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
 * Describes a developer of a library.
 * Mirrors the `developer` section found in OHPM package metadata.
 */
export class Developer {
  name: string = '';
  organisationUrl: string = '';

  constructor(name: string = '', organisationUrl: string = '') {
    this.name = name;
    this.organisationUrl = organisationUrl;
  }
}
