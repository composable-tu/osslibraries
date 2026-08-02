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
