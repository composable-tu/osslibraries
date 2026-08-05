/**
 * Copyright (c) 2026 composable-tu
 * OSSLibraries UI is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan PSL v2.
 * You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
 * MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 * See the Mulan PSL v2 for more details.
 */

import {
  hdsMaterial,
  HdsNavigationTitle,
  HdsNavigationTitleBarOptions,
  ScrollEffectType,
  TitleBarContentOptions,
} from '@kit.UIDesignKit';
import { LengthMetrics } from '@kit.ArkUI';

/**
 * 构建标题栏配置
 *
 * @param title 标题文本(字符串或资源)
 * @param materialLevel 材质级别(通过 getMaterialLevel() 获取)
 * @param contentOverrides 可选,菜单/返回图标等覆盖配置
 */
export function buildTitleBarOpts(
  title: string | Resource,
  materialLevel: hdsMaterial.MaterialLevel,
  contentOverrides?: Partial<TitleBarContentOptions>,
  subTitle?: string | Resource
): HdsNavigationTitleBarOptions {
  const navTitle: HdsNavigationTitle = { mainTitle: title };
  if (subTitle) {
    navTitle.subTitle = subTitle;
  }
  const content: TitleBarContentOptions = { title: navTitle };
  if (contentOverrides) {
    if (contentOverrides.backIcon) {
      content.backIcon = contentOverrides.backIcon;
    }
    if (contentOverrides.menu) {
      content.menu = contentOverrides.menu;
    }
  }
  return {
    content: content,
    enableComponentSafeArea: true,
    style: {
      scrollEffectOpts: {
        enableScrollEffect: true,
        scrollEffectType: ScrollEffectType.IMMERSIVE_GRADIENT_BLUR,
        blurEffectiveStartOffset: LengthMetrics.vp(0),
        blurEffectiveEndOffset: LengthMetrics.vp(20)
      },
      systemMaterialEffect: {
        materialType: hdsMaterial.MaterialType.ADAPTIVE,
        materialLevel: materialLevel
      },
      originalStyle: {
        backgroundStyle: {
          backgroundColor: $r('sys.color.ohos_id_color_background'),
        },
        contentStyle: {
          titleStyle: {
            mainTitleColor: $r('sys.color.font_primary'),
            subTitleColor: $r('sys.color.font_secondary')
          },
          menuStyle: {
            backgroundColor: $r('sys.color.comp_background_tertiary'),
            iconColor: $r('sys.color.icon_primary')
          },
          backIconStyle: {
            backgroundColor: $r('sys.color.comp_background_tertiary'),
            iconColor: $r('sys.color.icon_primary')
          }
        }
      },
      scrollEffectStyle: {
        backgroundStyle: {
          backgroundColor: $r('sys.color.ohos_id_color_background_transparent')
        },
        contentStyle: {
          titleStyle: {
            mainTitleColor: $r('sys.color.font_primary'),
            subTitleColor: $r('sys.color.font_secondary')
          },
          menuStyle: {
            backgroundColor: $r('sys.color.comp_background_tertiary'),
            iconColor: $r('sys.color.icon_primary')
          },
          backIconStyle: {
            backgroundColor: $r('sys.color.comp_background_tertiary'),
            iconColor: $r('sys.color.icon_primary')
          }
        }
      }
    },
  };
}

/**
 * 根据系统是否支持 IMMERSIVE 材质,返回合适的材质级别。
 * 不支持 IMMERSIVE 时降级为 SMOOTH,否则使用 EXQUISITE。
 */
export function getMaterialLevel(): hdsMaterial.MaterialLevel {
  const materialTypes: Array<hdsMaterial.MaterialType> = hdsMaterial.getSystemMaterialTypes();
  if (materialTypes.indexOf(hdsMaterial.MaterialType.IMMERSIVE) < 0) {
    return hdsMaterial.MaterialLevel.SMOOTH;
  }
  return hdsMaterial.MaterialLevel.EXQUISITE;
}
