/**
 * Describes the organization behind a library.
 */
export class Organization {
  name: string = '';
  url: string = '';

  constructor(name: string = '', url: string = '') {
    this.name = name;
    this.url = url;
  }
}
