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
