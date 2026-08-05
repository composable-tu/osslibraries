import 'osslibraries_ui/src/main/ets/pages/OSSLibrariesLicenseListPage';
import 'osslibraries_ui/src/main/ets/pages/OSSLibrariesLicenseDetailPage';

@Entry
@Component
struct Index {
  build() {
    Scroll() {
      Column() {
        Column() {
          Text($r('app.string.entry_title'))
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.Center)
            .width('100%')

          Text($r('app.string.entry_tagline'))
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 8 })
            .textAlign(TextAlign.Center)
            .width('100%')
        }
        .width('100%')
        .margin({ top: 24, bottom: 24 })

        this.FeatureCard(
          $r('app.string.entry_feature_scan_title'),
          $r('app.string.entry_feature_scan_desc'),
        )

        this.FeatureCard(
          $r('app.string.entry_feature_ui_title'),
          $r('app.string.entry_feature_ui_desc'),
        )

        this.FeatureCard(
          $r('app.string.entry_feature_skill_title'),
          $r('app.string.entry_feature_skill_desc'),
        )

        Button($r('app.string.entry_button_view'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor($r('sys.color.brand'))
          .borderRadius(12)
          .height(48)
          .width('100%')
          .margin({ top: 24, bottom: 24 })
          .onClick(() => {
            this.getUIContext().getRouter().pushNamedRoute({
              name: 'OSSLibrariesLicenseListPage'
            });
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .edgeEffect(EdgeEffect.Spring)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  FeatureCard(title: Resource, desc: Resource) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')

      Text(desc)
        .fontSize(13)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ top: 4 })
        .lineHeight(20)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .margin({ bottom: 12 })
  }
}
