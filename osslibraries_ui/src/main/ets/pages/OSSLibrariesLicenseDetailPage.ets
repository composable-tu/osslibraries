import { Library, License, Libs, LibsHolder } from 'osslibraries';
import { LicenseDetailParams } from '../model/RouteParams';
import { buildTitleBarOpts, getMaterialLevel } from '../components/TitleBarBuilder';
import { hdsMaterial, HdsNavigation, HdsNavigationTitleMode } from '@kit.UIDesignKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 开源许可证详情页
 */
@Entry({ routeName: 'OSSLibrariesLicenseDetailPage' })
@Component
export struct OSSLibrariesLicenseDetailPage {
  @State lib: Library = new Library();
  @State notFound: boolean = false;
  @State scmUrl: string = '';
  @State customMaterialLevel: hdsMaterial.MaterialLevel = hdsMaterial.MaterialLevel.EXQUISITE;

  aboutToAppear(): void {
    this.customMaterialLevel = getMaterialLevel();
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
    // 提前抽取 scm.url,避免在 build() 中对 nullable Scm 链式访问。
    this.scmUrl = found.scm?.url ?? '';
  }

  build() {
    HdsNavigation() {
      if (this.notFound) {
        Column() {
          Text($r('app.string.osslibraries_library_not_found'))
            .fontSize(16)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 0 }) {
          // 顶部链接卡片:website + 仓库地址
          if (this.lib.website.length > 0) {
            ListItem() {
              this.LinkCard(this.lib.website, $r('sys.symbol.link'))
            }
            .onClick(() => {
              this.openUrl(this.lib.website);
            }, 1)
          }
          if (this.scmUrl.length > 0 && this.scmUrl !== this.lib.website) {
            ListItem() {
              this.LinkCard(this.scmUrl, $r('sys.symbol.link'))
            }
            .onClick(() => {
              this.openUrl(this.scmUrl);
            }, 1)
          }

          // 许可证全文（仅渲染有正文内容的许可证）
          ForEach(
            this.lib.licenses.filter((lic: License) => lic.licenseContent && lic.licenseContent.length > 0),
            (lic: License) => {
              ListItem() {
                this.LicenseContent(lic)
              }
            },
            (lic: License) => lic.hash
          )

          // 底部留白
          ListItem() {
            Column().height(24).width('100%')
          }
        }
        .width('100%')
        .height('100%')
        .padding({ left: 16, right: 16, top: 8 })
        .clip(false)
        .cachedCount(4, true)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .titleMode(HdsNavigationTitleMode.MINI)
    .titleBar(buildTitleBarOpts(this.lib.name.length > 0 ? this.lib.name : $r('app.string.osslibraries_license_detail'),
      this.customMaterialLevel))
    .hideBackButton(false)
  }

  @Builder
  LinkCard(url: string, icon: Resource) {
    Row() {
      SymbolGlyph(icon)
        .fontSize(18)
        .fontColor([$r('sys.color.font_primary')])
        .margin({ right: 8 })

      Text(url)
        .fontSize(14)
        .fontColor($r('sys.color.font_primary'))
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .margin({ bottom: 12 })
  }

  @Builder
  LicenseContent(lic: License) {
    Column() {
      // 许可证全文
      if (lic.licenseContent.length > 0) {
        Text(lic.licenseContent)
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(22)
          .width('100%')
          .copyOption(CopyOptions.LocalDevice)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
  }

  /**
   * 通过系统 startAbility 打开 URL。
   */
  private openUrl(url: string): void {
    try {
      const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      context.startAbility({
        action: 'ohos.want.action.viewData',
        uri: url,
      });
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      hilog.error(0x0001, 'OSSLibrariesLicenseDetailPage', `openUrl failed: code=${err.code}, message=${err.message}`);
    }
  }
}
