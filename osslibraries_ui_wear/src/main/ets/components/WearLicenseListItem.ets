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

import { Library, License } from 'osslibraries';

/**
 * 穿戴端库条目内容，供 ArcList 的 ArcListItem 使用。
 */
@Component
export struct WearLicenseListItem {
  @Prop lib: Library = new Library();

  build() {
    Column() {
      // 库名称
      Text(this.lib.name.length > 0 ? this.lib.name : this.lib.uniqueId)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      // 版本 · 许可
      if (this.subtitle().length > 0) {
        Text(this.subtitle())
          .fontSize(11)
          .fontColor($r('sys.color.font_secondary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
          .width('100%')
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(16)
  }

  private subtitle(): string {
    const parts: string[] = [];

    if (this.lib.artifactVersion.length > 0) {
      const v: string = this.lib.artifactVersion;
      const first: string = v.charAt(0);
      parts.push(first >= '0' && first <= '9' ? `v${v}` : v);
    }

    if (this.lib.licenses.length > 0) {
      const lic: License = this.lib.licenses[0];
      const licName: string = lic.name.length > 0 ? lic.name : lic.spdxId;
      if (licName.length > 0) {
        parts.push(licName);
      }
    }

    return parts.join(' · ');
  }
}