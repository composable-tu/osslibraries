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

/**
 * 圆形表盘 ArcList 布局尺寸常量。
 *
 * 466px 对应典型圆形表盘视口直径；414px 为其内接正方形边长（卡片宽），
 * 圆角值取对应半径，使卡片贴合圆形与圆角矩形视觉。
 */

/** ArcList 视口宽/高（圆形直径）。 */
export const WEAR_ARC_LIST_SIZE: string = '466px';

/** ArcList 圆角（半径 = 直径 / 2）。 */
export const WEAR_ARC_LIST_RADIUS: string = '233px';

/** ArcListItem 宽（圆形内接正方形边长）。 */
export const WEAR_ARC_ITEM_WIDTH: string = '414px';

/** ArcListItem 圆角。 */
export const WEAR_ARC_ITEM_RADIUS: string = '65px';
