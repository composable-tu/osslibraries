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

import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute, ComponentContent, LengthMetrics } from '@kit.ArkUI';
import { Libs, Library, License, LibsHolder } from 'osslibraries';
import { LicenseDetailParams } from '../model/RouteParams';

/**
 * 穿戴端开源许可证详情页。
 */

@Builder
function detailPageHeader(name: string) {
  Column() {
    Text(name)
      .fontColor($r('sys.color.font_primary'))
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }
  .width('100%')
  .alignItems(HorizontalAlign.Center)
  .padding({ top: 10, bottom: 10 })
}

@Entry({ routeName: 'OSSSLibrariesLicenseDetailPageWear' })
@Component
export struct OSSLibrariesLicenseDetailPageWear {
  @State lib: Library = new Library();
  @State notFound: boolean = false;
  @State scmUrl: string = '';
  private arcListHeader: ComponentContent<string> = new ComponentContent(this.getUIContext(), wrapBuilder<[string]>(detailPageHeader), '');

  aboutToAppear(): void {
    const params: Object = this.getUIContext().getRouter().getParams() as Object;
    const detail: LicenseDetailParams = params as LicenseDetailParams;
    const uniqueId: string = detail?.uniqueId ?? '';

    const libs: Libs | undefined = LibsHolder.get();
    const found: Library | undefined = libs?.findLibrary(uniqueId);

    if (found === undefined) {
      this.notFound = true;
      return;
    }
    this.lib = found;
    this.scmUrl = found.scm?.url ?? '';
    this.arcListHeader.update(
      this.lib.name.length > 0 ? this.lib.name : this.lib.uniqueId
    );
  }

  build() {
    Column() {
      if (this.notFound) {
        Text($r('app.string.osslibraries_library_not_found'))
          .fontSize(13)
          .fontColor($r('sys.color.font_secondary'))
          .textAlign(TextAlign.Center)
          .padding({ left: 24, right: 24 })
      } else {
        ArcList({ initialIndex: 0, header: this.arcListHeader }) {
          // website 链接卡片
          if (this.lib.website.length > 0) {
            ArcListItem() {
              this.LinkCard(this.lib.website)
            }
            .width('414px')
            .borderRadius('65px')
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .onClick(() => {
              this.copyUrl(this.lib.website);
            })
          }

          // 仓库地址链接卡片
          if (this.scmUrl.length > 0 && this.scmUrl !== this.lib.website) {
            ArcListItem() {
              this.LinkCard(this.scmUrl)
            }
            .width('414px')
            .borderRadius('65px')
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .onClick(() => {
              this.copyUrl(this.scmUrl);
            })
          }

          // 许可证全文
          ForEach(
            this.lib.licenses.filter((lic: License) => lic.licenseContent.length > 0),
            (lic: License) => {
              ArcListItem() {
                Column() {
                  Text(lic.licenseContent)
                    .fontSize(12)
                    .fontColor($r('sys.color.font_primary'))
                    .lineHeight(18)
                    .width('100%')
                    .copyOption(CopyOptions.LocalDevice)
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
                .padding(16)
              }
              .width('414px')
              .borderRadius('65px')
              .backgroundColor($r('sys.color.comp_background_list_card'))
              .autoScale(false)
            },
            (lic: License) => lic.hash
          )
        }
        .width('466px')
        .height('466px')
        .space(LengthMetrics.px(10))
        .borderRadius('233px')
        .backgroundColor($r('sys.color.ohos_id_color_background'))
        .chainAnimation(true)
        .cachedCount(4)
        .digitalCrownSensitivity(CrownSensitivity.MEDIUM)
        .focusable(true)
        .focusOnTouch(true)
        .defaultFocus(true)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('sys.color.ohos_id_color_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  LinkCard(url: string) {
    Column() {
      Text(url)
        .fontSize(12)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(16)
  }

  /**
   * 复制 URL 到系统剪贴板，并提示已复制。
   */
  private copyUrl(url: string): void {
    try {
      const systemPasteboard = pasteboard.getSystemPasteboard();
      const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, url);
      systemPasteboard.setData(pasteData).then(() => {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.osslibraries_wear_copied'),
          duration: 1500
        });
      });
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      hilog.error(0x0001, 'OSSLibrariesLicenseDetailPageWear',
        `copyUrl failed: code=${err.code}, message=${err.message}`);
    }
  }
}