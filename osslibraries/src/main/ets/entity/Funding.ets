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
