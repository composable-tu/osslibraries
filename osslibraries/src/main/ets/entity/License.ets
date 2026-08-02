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
