/**
 * Router parameters for navigating to the license detail page.
 * Declared ONCE here and imported by both the list and detail pages.
 */
export interface LicenseDetailParams {
  /** The uniqueId of the library to display. */
  uniqueId: string;
}
