import { Library } from '../entity/Library';
import { License } from '../entity/License';
import { Developer } from '../entity/Developer';
import { Organization } from '../entity/Organization';
import { Scm } from '../entity/Scm';
import { Funding } from '../entity/Funding';

/**
 * Result of parsing the OSSLibraries JSON.
 */
export class ParseResult {
  libraries: Library[] = [];
  licenses: License[] = [];
}

/**
 * Parses OSSLibraries JSON into `Library` and `License` objects.
 *
 * JSON structure:
 * ```
 * {
 *   "libraries": [ { ..., "licenses": ["hash1", "hash2"] } ],
 *   "licenses":  { "hash1": { "name": "...", "content": "...", "hash": "hash1" } }
 * }
 * ```
 * The `licenses` array inside each library entry holds hash references that
 * are resolved against the top-level `licenses` map.
 */
export class Parser {
  /**
   * Parse a JSON string in OSSLibraries format.
   */
  static parse(json: string): ParseResult {
    const parsed: Object = JSON.parse(json);
    const root: Record<string, Object> = parsed as Record<string, Object>;

    const result: ParseResult = new ParseResult();

    // --- Parse the licenses map first so library entries can resolve refs ---
    const licensesMap: Map<string, License> = new Map();
    const licensesObj: Object = root['licenses'];
    if (licensesObj !== undefined && licensesObj !== null) {
      const licensesRecord: Record<string, Object> = licensesObj as Record<string, Object>;
      const keys: string[] = Object.keys(licensesRecord);
      for (let i = 0; i < keys.length; i++) {
        const key: string = keys[i];
        const licRaw: Object = licensesRecord[key];
        if (licRaw === undefined || licRaw === null) {
          continue;
        }
        const lic: License = Parser.parseLicense(licRaw as Record<string, Object>, key);
        licensesMap.set(key, lic);
        result.licenses.push(lic);
      }
    }

    // --- Parse the libraries array ---
    const libsRaw: Object = root['libraries'];
    if (libsRaw !== undefined && libsRaw !== null) {
      const libsArr: Object[] = libsRaw as Object[];
      for (let i = 0; i < libsArr.length; i++) {
        const libObj: Object = libsArr[i];
        if (libObj === undefined || libObj === null) {
          continue;
        }
        const lib: Library = Parser.parseLibrary(libObj as Record<string, Object>, licensesMap);
        result.libraries.push(lib);
      }
    }

    return result;
  }

  private static parseLicense(obj: Record<string, Object>, fallbackHash: string): License {
    const lic: License = new License();
    lic.hash = Parser.getStr(obj, 'hash', fallbackHash);
    lic.name = Parser.getStr(obj, 'name', '');
    lic.url = Parser.getStr(obj, 'url', '');
    lic.spdxId = Parser.getStr(obj, 'spdxId', '');
    lic.year = Parser.getStr(obj, 'year', '');
    // Some JSON uses "content", others "licenseContent"
    lic.licenseContent = Parser.getStr(obj, 'content', Parser.getStr(obj, 'licenseContent', ''));
    return lic;
  }

  private static parseLibrary(obj: Record<string, Object>, licensesMap: Map<string, License>): Library {
    const lib: Library = new Library();
    lib.uniqueId = Parser.getStr(obj, 'uniqueId', '');
    lib.artifactVersion = Parser.getStr(obj, 'artifactVersion', '');
    lib.name = Parser.getStr(obj, 'name', lib.uniqueId);
    lib.description = Parser.getStr(obj, 'description', '');
    lib.website = Parser.getStr(obj, 'website', '');

    // Developers
    const devsRaw: Object = obj['developers'];
    if (devsRaw !== undefined && devsRaw !== null) {
      const devsArr: Object[] = devsRaw as Object[];
      for (let i = 0; i < devsArr.length; i++) {
        const devObj: Object = devsArr[i];
        if (devObj === undefined || devObj === null) {
          continue;
        }
        const dev: Developer = new Developer();
        const devRecord: Record<string, Object> = devObj as Record<string, Object>;
        dev.name = Parser.getStr(devRecord, 'name', '');
        dev.organisationUrl = Parser.getStr(devRecord, 'organisationUrl', '');
        lib.developers.push(dev);
      }
    }

    // Organization
    const orgRaw: Object = obj['organization'];
    if (orgRaw !== undefined && orgRaw !== null) {
      const orgRecord: Record<string, Object> = orgRaw as Record<string, Object>;
      lib.organization = new Organization(
        Parser.getStr(orgRecord, 'name', ''),
        Parser.getStr(orgRecord, 'url', ''));
    }

    // SCM
    const scmRaw: Object = obj['scm'];
    if (scmRaw !== undefined && scmRaw !== null) {
      const scmRecord: Record<string, Object> = scmRaw as Record<string, Object>;
      lib.scm = new Scm(
        Parser.getStr(scmRecord, 'connection', ''),
        Parser.getStr(scmRecord, 'developerConnection', ''),
        Parser.getStr(scmRecord, 'url', ''));
    }

    // Licenses — array of hash strings resolved against the licenses map
    const licRefsRaw: Object = obj['licenses'];
    if (licRefsRaw !== undefined && licRefsRaw !== null) {
      const licRefs: Object[] = licRefsRaw as Object[];
      for (let i = 0; i < licRefs.length; i++) {
        const ref: Object = licRefs[i];
        if (ref === undefined || ref === null) {
          continue;
        }
        const hash: string = ref as string;
        const resolved: License | undefined = licensesMap.get(hash);
        if (resolved !== undefined) {
          lib.licenses.push(resolved);
        }
      }
    }

    // Funding
    const fundRaw: Object = obj['funding'];
    if (fundRaw !== undefined && fundRaw !== null) {
      const fundArr: Object[] = fundRaw as Object[];
      for (let i = 0; i < fundArr.length; i++) {
        const fundObj: Object = fundArr[i];
        if (fundObj === undefined || fundObj === null) {
          continue;
        }
        const fundRecord: Record<string, Object> = fundObj as Record<string, Object>;
        lib.funding.push(new Funding(
          Parser.getStr(fundRecord, 'platform', ''),
          Parser.getStr(fundRecord, 'url', '')));
      }
    }

    // Tag
    lib.tag = Parser.getStr(obj, 'tag', '');

    return lib;
  }

  /**
   * Safely extract a string property from a Record, returning a fallback
   * when the key is missing or the value is not a string.
   */
  private static getStr(obj: Record<string, Object>, key: string, fallback: string): string {
    const val: Object = obj[key];
    if (val === undefined || val === null) {
      return fallback;
    }
    if (typeof val === 'string') {
      return val as string;
    }
    return fallback;
  }
}
