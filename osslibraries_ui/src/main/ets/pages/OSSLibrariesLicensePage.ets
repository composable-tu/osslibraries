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

import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Libs, LibsHolder, LibsLoader, Library } from 'osslibraries';
import { LicenseItem } from '../components/LicenseItem';
import { LicenseDetailView } from '../components/LicenseDetailView';
import { LicenseDetailParams } from '../model/RouteParams';
import { buildTitleBarOpts, getMaterialLevel } from '../components/TitleBarBuilder';
import { UI_DETAIL_PAGE_ROUTE } from '../constants/RouteNames';
import { hdsMaterial, HdsNavigation, HdsNavigationTitleMode, HdsNavDestination, HdsNavDestinationTitleMode } from '@kit.UIDesignKit';

/**
 * 开源许可证页(自适应容器)。
 *
 * 使用单个 HdsNavigation 承载列表(侧边栏)与详情(navDestination),并保持 Auto 模式:
 *  - 手机/窄屏(Stack):列表占满全屏,点击项 push 详情覆盖;
 *  - 大屏(Split):列表常驻左侧侧边栏,详情显示在右侧内容区。
 *
 * 数据通过 core 的 LibsLoader 加载(优先 osslibraries.msgpack,回退 osslibraries.json),
 * 通过 LibsHolder 跨视图共享。
 */
@Entry({ routeName: 'OSSLibrariesLicensePage' })
@Component
export struct OSSLibrariesLicensePage {
  @State pathStack: NavPathStack = new NavPathStack();
  @State isLoaded: boolean = false;
  @State libs: Libs = new Libs();
  @State errorMsg: string = '';
  @State customMaterialLevel: hdsMaterial.MaterialLevel = hdsMaterial.MaterialLevel.EXQUISITE;
  @State navigationMode: NavigationMode = NavigationMode.Auto;

  aboutToAppear(): void {
    this.customMaterialLevel = getMaterialLevel();
    this.loadData();
  }

  async loadData(): Promise<void> {
    try {
      const context: common.Context = this.getUIContext().getHostContext() as common.Context;
      this.libs = await LibsLoader.fromRawfile(context);
      LibsHolder.set(this.libs);
      this.isLoaded = true;
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      this.errorMsg = err.message;
      this.isLoaded = true;
    }
  }

  build() {
    HdsNavigation(this.pathStack) {
      this.NavBar()
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .mode(NavigationMode.Auto)
    .navBarWidth('37.5%')
    .titleMode(HdsNavigationTitleMode.MINI)
    .titleBar(buildTitleBarOpts($r('app.string.osslibraries_title_licenses'), this.customMaterialLevel))
    .hideBackButton(false)
    .navDestination(this.DetailDestination)
    .onNavigationModeChange((mode: NavigationMode) => {
      this.navigationMode = mode;
    })
  }

  @Builder
  NavBar() {
    if (!this.isLoaded) {
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
        Text($r('app.string.osslibraries_loading'))
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 8 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else if (this.errorMsg.length > 0) {
      Column() {
        Text($r('app.string.osslibraries_load_failed', this.errorMsg))
          .fontSize(14)
          .fontColor($r('sys.color.ohos_id_color_warning'))
          .textAlign(TextAlign.Center)
          .padding({ left: 24, right: 24 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      List({ space: 12 }) {
        ForEach(this.libs.libraries, (lib: Library) => {
          ListItem() {
            LicenseItem({ lib: lib })
          }
          .onClick(() => {
            if (lib.licenses.length > 0 || lib.website.length > 0) {
              this.navigateToDetail(lib.uniqueId);
            }
          }, 5)
        }, (lib: Library) => lib.uniqueId)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 24 })
      .clip(false)
      .cachedCount(4, true)
      .edgeEffect(EdgeEffect.Spring)
    }
  }

  @Builder
  DetailDestination(name: string, pageInfos: Object) {
    HdsNavDestination() {
      LicenseDetailView({
        uniqueId: (pageInfos as LicenseDetailParams).uniqueId
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .titleMode(HdsNavDestinationTitleMode.MINI)
    .titleBar(buildTitleBarOpts(
      this.navigationMode === NavigationMode.Split
        ? this.detailTitleOf((pageInfos as LicenseDetailParams).uniqueId)
        : $r('app.string.osslibraries_title_licenses'),
      this.customMaterialLevel,
      undefined,
      this.navigationMode === NavigationMode.Split
        ? undefined
        : this.libNameOf((pageInfos as LicenseDetailParams).uniqueId)
    ))
    .hideBackButton(this.navigationMode === NavigationMode.Split)
  }

  private navigateToDetail(uniqueId: string): void {
    const params: LicenseDetailParams = { uniqueId: uniqueId };
    if (this.pathStack.size() > 0) {
      this.pathStack.replacePathByName(UI_DETAIL_PAGE_ROUTE, params);
    } else {
      this.pathStack.pushPathByName(UI_DETAIL_PAGE_ROUTE, params);
    }
  }

  /**
   * 详情页标题栏主标题:大屏分栏下使用库名,未找到或无名时回退到默认标题。
   */
  private detailTitleOf(uniqueId: string): Resource | string {
    const name: string | undefined = this.libNameOf(uniqueId);
    if (name !== undefined) {
      return name;
    }
    return $r('app.string.osslibraries_title_licenses');
  }

  /**
   * 查询库名称用于详情页标题栏副标题;未找到或无名时返回 undefined。
   */
  private libNameOf(uniqueId: string): string | undefined {
    const found: Library | undefined = LibsHolder.get()?.findLibrary(uniqueId);
    if (found !== undefined && found.name.length > 0) {
      return found.name;
    }
    return undefined;
  }
}