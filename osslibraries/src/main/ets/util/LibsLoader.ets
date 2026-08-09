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

import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Libs } from '../Libs';

const LOG_DOMAIN: number = 0x0001;
const LOG_TAG: string = 'OSSLibraries.LibsLoader';

const MSGPACK_FILE: string = 'osslibraries.msgpack';
const JSON_FILE: string = 'osslibraries.json';

/**
 * 从 rawfile 加载 OSSLibraries 数据的助手。
 *
 * 解析策略：优先查找并解析 `osslibraries.msgpack`（MessagePack 二进制，更小更快），
 * 查找不到或解析失败时回退到 `osslibraries.json`。
 */
export class LibsLoader {
  /**
   * 从指定模块上下文的 rawfile 中加载并解析许可证数据。
   *
   * @param context 宿主模块上下文（通常通过 `getUIContext().getHostContext()` 获取）。
   * @returns 解析并按名称排序后的 `Libs` 实例。
   * @throws 当 msgpack 与 json 均不可用时，抛出最后一次（json）的加载异常。
   */
  static async fromRawfile(context: common.Context): Promise<Libs> {
    // --- 1. 优先尝试 MessagePack ---
    try {
      const bytes: Uint8Array = await context.resourceManager.getRawFileContent(MSGPACK_FILE);
      if (bytes.length > 0) {
        const libs: Libs = Libs.fromMsgpack(bytes);
        hilog.info(LOG_DOMAIN, LOG_TAG, `loaded ${libs.libraries.length} libraries from ${MSGPACK_FILE}`);
        return libs;
      }
    } catch (e) {
      // msgpack 不存在或解析失败，记录底层错误后回退到 JSON，便于排查区分「文件缺失」与「解码错误」。
      const err: BusinessError = e as BusinessError;
      hilog.warn(LOG_DOMAIN, LOG_TAG,
        `${MSGPACK_FILE} unavailable (code=${err.code}, msg=${err.message}), falling back to ${JSON_FILE}`);
    }

    // --- 2. 回退到 JSON ---
    const content: Uint8Array = await context.resourceManager.getRawFileContent(JSON_FILE);
    const decoder: util.TextDecoder = util.TextDecoder.create('utf-8');
    const json: string = decoder.decode(content);
    const libs: Libs = Libs.fromJson(json);
    hilog.info(LOG_DOMAIN, LOG_TAG, `loaded ${libs.libraries.length} libraries from ${JSON_FILE}`);
    return libs;
  }
}
