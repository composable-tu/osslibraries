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

import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute, ComponentContent, LengthMetrics } from '@kit.ArkUI';
import { Libs, Library, LibsHolder } from 'osslibraries';
import { WearLicenseListItem } from '../components/WearLicenseListItem';
import { LicenseDetailParams } from '../model/RouteParams';
import { WEAR_ARC_LIST_SIZE, WEAR_ARC_LIST_RADIUS, WEAR_ARC_ITEM_WIDTH, WEAR_ARC_ITEM_RADIUS } from '../constants/WearLayoutConstants';
import { WEAR_DETAIL_PAGE_ROUTE } from '../constants/WearRouteNames';
import { WearScreenUtil } from '../utils/WearScreenUtil';

/**
 * 穿戴端开源许可证列表页。
 */

@Builder
function listPageHeader() {
  Column() {
    Text($r('app.string.osslibraries_wear_title_licenses'))
      .fontColor($r('sys.color.font_primary'))
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
  }
  .width('100%')
  .alignItems(HorizontalAlign.Center)
  .padding({ top: 10, bottom: 10 })
}

@Entry({ routeName: 'OSSLibrariesLicenseListPageWear' })
@Component
export struct OSSLibrariesLicenseListPageWear {
  @State isLoaded: boolean = false;
  @State libs: Libs = new Libs();
  @State errorMsg: string = '';
  @State isRoundScreen: boolean = true;
  private arcListHeader: ComponentContent<Object> = new ComponentContent(this.getUIContext(), wrapBuilder(listPageHeader));

  aboutToAppear(): void {
    this.isRoundScreen = WearScreenUtil.isRoundScreen();
    this.loadData();
  }

  async loadData(): Promise<void> {
    try {
      const context: common.Context = this.getUIContext().getHostContext() as common.Context;
      const content: Uint8Array = await context.resourceManager.getRawFileContent('osslibraries.json');
      const decoder: util.TextDecoder = util.TextDecoder.create('utf-8');
      const json: string = decoder.decode(content);
      this.libs = Libs.fromJson(json);
      LibsHolder.set(this.libs);
      this.isLoaded = true;
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      this.errorMsg = err.message;
      this.isLoaded = true;
    }
  }

  build() {
    Column() {
      if (!this.isLoaded) {
        LoadingProgress()
          .width(40)
          .height(40)
      } else if (this.errorMsg.length > 0) {
        Text($r('app.string.osslibraries_load_failed', this.errorMsg))
          .fontSize(12)
          .fontColor($r('sys.color.ohos_id_color_warning'))
          .textAlign(TextAlign.Center)
          .padding({ left: 24, right: 24 })
      } else {
        if (this.isRoundScreen) {
          ArcList({ initialIndex: 0, header: this.arcListHeader }) {
            ForEach(this.libs.libraries, (lib: Library) => {
              ArcListItem() {
                WearLicenseListItem({ lib: lib })
              }
              .width(WEAR_ARC_ITEM_WIDTH)
              .borderRadius(WEAR_ARC_ITEM_RADIUS)
              .backgroundColor($r('sys.color.comp_background_list_card'))
              .onClick(() => {
                if (lib.licenses.length > 0 || lib.website.length > 0) {
                  this.navigateToDetail(lib.uniqueId);
                }
              })
            }, (lib: Library) => lib.uniqueId)
          }
          .width(WEAR_ARC_LIST_SIZE)
          .height(WEAR_ARC_LIST_SIZE)
          .space(LengthMetrics.px(10))
          .borderRadius(WEAR_ARC_LIST_RADIUS)
          .backgroundColor($r('sys.color.ohos_id_color_background'))
          .chainAnimation(true)
          .cachedCount(5)
          .digitalCrownSensitivity(CrownSensitivity.MEDIUM)
          .focusable(true)
          .focusOnTouch(true)
          .defaultFocus(true)
        } else {
          List({ space: '10px' }) {
            ListItem() {
              Text($r('app.string.osslibraries_wear_title_licenses'))
                .fontColor($r('sys.color.font_primary'))
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 10, bottom: 10 })
            }

            ForEach(this.libs.libraries, (lib: Library) => {
              ListItem() {
                WearLicenseListItem({ lib: lib })
              }
              .width('100%')
              .borderRadius(WEAR_ARC_ITEM_RADIUS)
              .backgroundColor($r('sys.color.comp_background_list_card'))
              .onClick(() => {
                if (lib.licenses.length > 0 || lib.website.length > 0) {
                  this.navigateToDetail(lib.uniqueId);
                }
              })
            }, (lib: Library) => lib.uniqueId)
          }
          .width('100%')
          .height('100%')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor($r('sys.color.ohos_id_color_background'))
          .cachedCount(5)
          .focusable(true)
          .focusOnTouch(true)
          .defaultFocus(true)
        }
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('sys.color.ohos_id_color_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private navigateToDetail(uniqueId: string): void {
    const params: LicenseDetailParams = { uniqueId: uniqueId };
    this.getUIContext().getRouter().pushNamedRoute({
      name: WEAR_DETAIL_PAGE_ROUTE,
      params: params
    });
  }
}