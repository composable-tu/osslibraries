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

import { Library } from '../entity/Library';

/**
 * Shared comparison helpers.
 */
export class SortUtil {
  /**
   * Case-insensitive comparator for libraries by name.
   * Suitable for `Array.prototype.sort`.
   */
  static compareLibraryByName(a: Library, b: Library): number {
    const aName: string = a.name.toLowerCase();
    const bName: string = b.name.toLowerCase();
    if (aName < bName) {
      return -1;
    } else if (aName > bName) {
      return 1;
    } else {
      return 0;
    }
  }
}
