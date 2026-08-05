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
 * Describes a funding opportunity for a library.
 */
export class Funding {
  platform: string = '';
  url: string = '';

  constructor(platform: string = '', url: string = '') {
    this.platform = platform;
    this.url = url;
  }
}
