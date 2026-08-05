/**
 * Copyright (c) 2026 composable-tu
 * OSSLibraries is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan PSL v2.
 * You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
 * MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 * See the Mulan PSL v2 for more details.
 */

import { Library } from '../entity/Library';
import { License } from '../entity/License';
import { Developer } from '../entity/Developer';
import { Organization } from '../entity/Organization';
import { Scm } from '../entity/Scm';
import { Funding } from '../entity/Funding';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 解析结果
 */
export class ParseResult {
  libraries: Library[] = [];
  licenses: License[] = [];
}

interface JsonLicense {
  hash?: string;
  name?: string;
  url?: string;
  spdxId?: string;
  year?: string;
  content?: string;
  licenseContent?: string;
}

interface JsonDeveloper {
  name?: string;
  organisationUrl?: string;
}

interface JsonOrganization {
  name?: string;
  url?: string;
}

interface JsonScm {
  connection?: string;
  developerConnection?: string;
  url?: string;
}

interface JsonFunding {
  platform?: string;
  url?: string;
}

interface JsonLibrary {
  uniqueId?: string;
  artifactVersion?: string;
  name?: string;
  description?: string;
  website?: string;
  developers?: JsonDeveloper[];
  organization?: JsonOrganization;
  scm?: JsonScm;
  licenses?: string[]; // hash 引用
  funding?: JsonFunding[];
  tag?: string;
}

interface JsonRoot {
  libraries?: JsonLibrary[];
  licenses?: Record<string, JsonLicense>;
}

const LOG_DOMAIN: number = 0x0001;
const LOG_TAG: string = 'OSSLibraries.Parser';

/**
 * 将 OSSLibraries JSON 解析为 Library / License 对象。
 *
 * JSON 结构:
 * ```
 * {
 *   "libraries": [ { ..., "licenses": ["hash1", "hash2"] } ],
 *   "licenses":  { "hash1": { "name": "...", "content": "...", "hash": "hash1" } }
 * }
 * ```
 * 每个库条目内的 licenses 数组持有 hash 引用,会与顶层 licenses 映射对照解析。
 *
 * uniqueId 为唯一必需字段;缺失则跳过该条目并记录告警,避免脏数据进入列表。
 */
export class Parser {
  /**
   * 解析 OSSLibraries 格式的 JSON 字符串。
   */
  static parse(json: string): ParseResult {
    const root: JsonRoot = JSON.parse(json) as JsonRoot;
    const result: ParseResult = new ParseResult();

    // --- 先解析 licenses 映射,后续库条目可据此解析引用 ---
    const licensesMap: Map<string, License> = new Map();
    const licensesRecord: Record<string, JsonLicense> = root.licenses ?? {};
    const licKeys: string[] = Object.keys(licensesRecord);
    for (let i = 0; i < licKeys.length; i++) {
      const key: string = licKeys[i];
      const licRaw: JsonLicense | undefined = licensesRecord[key];
      if (licRaw === undefined || licRaw === null) {
        continue;
      }
      const lic: License = Parser.parseLicense(licRaw, key);
      licensesMap.set(key, lic);
      result.licenses.push(lic);
    }

    // --- 解析 libraries 数组 ---
    const libsArr: JsonLibrary[] = root.libraries ?? [];
    for (let i = 0; i < libsArr.length; i++) {
      const libObj: JsonLibrary | undefined = libsArr[i];
      if (libObj === undefined || libObj === null) {
        continue;
      }
      // 必需字段校验：uniqueId 缺失则跳过并告警，避免空 ID 污染列表。
      if (libObj.uniqueId === undefined || libObj.uniqueId === null || libObj.uniqueId.length === 0) {
        hilog.warn(LOG_DOMAIN, LOG_TAG, `skip library at index ${i}: missing required field 'uniqueId'`);
        continue;
      }
      const lib: Library = Parser.parseLibrary(libObj, licensesMap);
      result.libraries.push(lib);
    }

    return result;
  }

  private static parseLicense(obj: JsonLicense, fallbackHash: string): License {
    const lic: License = new License();
    lic.hash = obj.hash ?? fallbackHash;
    lic.name = obj.name ?? '';
    lic.url = obj.url ?? '';
    lic.spdxId = obj.spdxId ?? '';
    lic.year = obj.year ?? '';
    // 部分 JSON 用 "content"，部分用 "licenseContent"
    lic.licenseContent = obj.content ?? obj.licenseContent ?? '';
    return lic;
  }

  private static parseLibrary(obj: JsonLibrary, licensesMap: Map<string, License>): Library {
    const lib: Library = new Library();
    // uniqueId 已在 parse() 校验,这里安全取值。
    lib.uniqueId = obj.uniqueId ?? '';
    lib.artifactVersion = obj.artifactVersion ?? '';
    lib.name = obj.name ?? lib.uniqueId;
    lib.description = obj.description ?? '';
    lib.website = obj.website ?? '';

    // 开发者
    const devs: JsonDeveloper[] = obj.developers ?? [];
    for (let i = 0; i < devs.length; i++) {
      const devObj: JsonDeveloper | undefined = devs[i];
      if (devObj === undefined || devObj === null) {
        continue;
      }
      const dev: Developer = new Developer();
      dev.name = devObj.name ?? '';
      dev.organisationUrl = devObj.organisationUrl ?? '';
      lib.developers.push(dev);
    }

    // 组织
    const org: JsonOrganization | undefined = obj.organization;
    if (org !== undefined && org !== null) {
      lib.organization = new Organization(
        org.name ?? '',
        org.url ?? '');
    }

    // SCM
    const scm: JsonScm | undefined = obj.scm;
    if (scm !== undefined && scm !== null) {
      lib.scm = new Scm(
        scm.connection ?? '',
        scm.developerConnection ?? '',
        scm.url ?? '');
    }

    // 许可证 —— hash 字符串数组,与 licenses 映射对照解析
    const licRefs: string[] = obj.licenses ?? [];
    for (let i = 0; i < licRefs.length; i++) {
      const ref: string | undefined = licRefs[i];
      if (ref === undefined || ref === null) {
        continue;
      }
      const resolved: License | undefined = licensesMap.get(ref);
      if (resolved !== undefined) {
        lib.licenses.push(resolved);
      }
    }

    // 资助
    const fundArr: JsonFunding[] = obj.funding ?? [];
    for (let i = 0; i < fundArr.length; i++) {
      const fundObj: JsonFunding | undefined = fundArr[i];
      if (fundObj === undefined || fundObj === null) {
        continue;
      }
      lib.funding.push(new Funding(
        fundObj.platform ?? '',
        fundObj.url ?? ''));
    }

    // 标签
    lib.tag = obj.tag ?? '';

    return lib;
  }
}