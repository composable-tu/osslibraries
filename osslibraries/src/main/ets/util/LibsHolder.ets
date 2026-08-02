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
