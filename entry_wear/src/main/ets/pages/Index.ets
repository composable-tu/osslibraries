import 'osslibraries_ui_wear/src/main/ets/pages/OSSLibrariesLicenseListPageWear';
import 'osslibraries_ui_wear/src/main/ets/pages/OSSLibrariesLicenseDetailPageWear';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Column() {
        Text($r('app.string.entry_title'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Center)
          .width('100%')

        Text($r('app.string.entry_tagline'))
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 4 })
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .width('100%')
      .margin({ top: 12, bottom: 16 })

      Button($r('app.string.entry_button_view'))
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.brand'))
        .borderRadius(24)
        .height(48)
        .width(168)
        .onClick(() => {
          this.getUIContext().getRouter().pushNamedRoute({
            name: 'OSSLibrariesLicenseListPageWear'
          });
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.ohos_id_color_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}