import { Developer } from './Developer';
import { Organization } from './Organization';
import { Scm } from './Scm';
import { Funding } from './Funding';
import { License } from './License';

/**
 * Describes a complete Library element — all metadata about a single
 * open-source dependency used by the project.
 */
export class Library {
  /** Unique identifier, typically `packageName` without version. */
  uniqueId: string = '';
  /** Version of the artifact used. */
  artifactVersion: string = '';
  /** Display name of the dependency. */
  name: string = '';
  /** Description of the dependency. */
  description: string = '';
  /** Website provided by the package metadata. */
  website: string = '';
  /** List of developers. */
  developers: Developer[] = [];
  /** Organization that created the dependency. */
  organization: Organization | undefined = undefined;
  /** SCM information linking to the source repository. */
  scm: Scm | undefined = undefined;
  /** All identified licenses for this artifact (by hash reference, resolved at parse time). */
  licenses: License[] = [];
  /** All identified funding opportunities. */
  funding: Funding[] = [];
  /** Optional tag for grouping. */
  tag: string = '';

  /** Returns `uniqueId:artifactVersion` combined. */
  get artifactId(): string {
    return `${this.uniqueId}:${this.artifactVersion}`;
  }

  /** Returns true if this artifact is assumed open source (scm.url is present). */
  get openSource(): boolean {
    return this.scm !== undefined && this.scm.url.length > 0;
  }
}
