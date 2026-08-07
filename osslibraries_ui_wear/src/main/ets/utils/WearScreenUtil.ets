/**
 * Copyright (c) 2026 composable-tu
 * OSSLibraries UI (Wearable) is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan PSL v2.
 * You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
 * MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 * See the Mulan PSL v2 for more details.
 */

import { display } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 穿戴设备屏幕形状检测工具。
 *
 * 通过 `display.getDefaultDisplaySync().screenShape` 判断圆形/方形屏（API 18+）。
 * 相比 mediaquery 的 `round-screen`，该接口在 Wearable 模拟器上也能正确返回结果。
 */
export class WearScreenUtil {
  private static _shapeDetected: boolean = false;
  private static _isRound: boolean = false;

  /** 当前屏幕是否为圆形。多次调用只检测一次并缓存结果。 */
  static isRoundScreen(): boolean {
    if (!WearScreenUtil._shapeDetected) {
      WearScreenUtil._detectShape();
    }
    return WearScreenUtil._isRound;
  }

  /** 当前屏幕是否为方形。 */
  static isSquareScreen(): boolean {
    return !WearScreenUtil.isRoundScreen();
  }

  private static _detectShape(): void {
    WearScreenUtil._shapeDetected = true;
    try {
      const d: display.Display = display.getDefaultDisplaySync();
      const shape: display.ScreenShape | undefined = d.screenShape;
      WearScreenUtil._isRound = (shape === display.ScreenShape.ROUND);
      hilog.info(0x0001, 'WearScreenUtil',
        `screenShape = ${shape}, isRound = ${WearScreenUtil._isRound}`);
    } catch (e) {
      WearScreenUtil._isRound = false;
      hilog.error(0x0001, 'WearScreenUtil', `detect shape failed: ${e}`);
    }
  }
}
