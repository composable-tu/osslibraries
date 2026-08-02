import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Libs, LibsHolder, Library } from 'osslibraries';
import { LicenseItem } from '../components/LicenseItem';
import { LicenseDetailParams } from '../model/RouteParams';
import { buildTitleBarOpts, getMaterialLevel } from '../components/TitleBarBuilder';
import { hdsMaterial, HdsNavigation, HdsNavigationTitleMode } from '@kit.UIDesignKit';

/**
 * 开源许可证列表页
 *
 * 数据从 rawfile/osslibraries.json 加载，通过 LibsHolder 跨页面共享。
 */
@Entry({ routeName: 'OSSLibrariesLicenseListPage' })
@Component
export struct OSSLibrariesLicenseListPage {
  @State isLoaded: boolean = false;
  @State libs: Libs = new Libs();
  @State errorMsg: string = '';
  @State customMaterialLevel: hdsMaterial.MaterialLevel = hdsMaterial.MaterialLevel.EXQUISITE;

  aboutToAppear(): void {
    this.customMaterialLevel = getMaterialLevel();
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
    HdsNavigation() {
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
            }, 1)
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
    .backgroundColor($r('sys.color.background_secondary'))
    .titleMode(HdsNavigationTitleMode.MINI)
    .titleBar(buildTitleBarOpts($r('app.string.osslibraries_title_licenses'), this.customMaterialLevel))
    .hideBackButton(false)
  }

  private navigateToDetail(uniqueId: string): void {
    const params: LicenseDetailParams = { uniqueId: uniqueId };
    this.getUIContext().getRouter().pushNamedRoute({
      name: 'OSSLibrariesLicenseDetailPage',
      params: params
    });
  }
}
