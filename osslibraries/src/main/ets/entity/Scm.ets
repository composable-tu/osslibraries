/**
 * Describes SCM (source control management) information for a library.
 */
export class Scm {
  connection: string = '';
  developerConnection: string = '';
  url: string = '';

  constructor(connection: string = '', developerConnection: string = '', url: string = '') {
    this.connection = connection;
    this.developerConnection = developerConnection;
    this.url = url;
  }
}
