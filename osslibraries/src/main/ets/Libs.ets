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

import { Library } from './entity/Library';
import { License } from './entity/License';
import { Parser, ParseResult } from './util/Parser';
import { SortUtil } from './util/SortUtil';

/**
 * The `Libs` class is the main access point to the scanned license data.
 * It holds the list of libraries and the set of unique licenses.
 */
export class Libs {
  libraries: Library[] = [];
  licenses: License[] = [];

  constructor(libraries: Library[] = [], licenses: License[] = []) {
    this.libraries = libraries;
    this.licenses = licenses;
  }

  /**
   * Find a library by its uniqueId.
   * Returns undefined if not found.
   */
  findLibrary(uniqueId: string): Library | undefined {
    for (let i = 0; i < this.libraries.length; i++) {
      if (this.libraries[i].uniqueId === uniqueId) {
        return this.libraries[i];
      }
    }
    return undefined;
  }

  /**
   * Find a license by its hash.
   * Returns undefined if not found.
   */
  findLicense(hash: string): License | undefined {
    for (let i = 0; i < this.licenses.length; i++) {
      if (this.licenses[i].hash === hash) {
        return this.licenses[i];
      }
    }
    return undefined;
  }

  /**
   * Build a `Libs` instance from a JSON string in OSSLibraries format.
   * Libraries are sorted by name (case-insensitive).
   */
  static fromJson(json: string): Libs {
    const result: ParseResult = Parser.parse(json);
    const sorted: Library[] = result.libraries.sort(SortUtil.compareLibraryByName);
    return new Libs(sorted, result.licenses);
  }
}
