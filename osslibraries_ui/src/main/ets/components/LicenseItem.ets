import { Developer, Library, License } from 'osslibraries';
import { LengthMetrics } from '@kit.ArkUI';

@Component
export struct LicenseItem {
  @Prop lib: Library = new Library();
  @State isPressed: boolean = false;

  build() {
    Column() {
      Column() { // 库名称
        Text(this.lib.name.length > 0 ? this.lib.name : this.lib.uniqueId)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      // 包名(uniqueId)
      if (this.lib.uniqueId.length > 0 && this.lib.uniqueId !== this.lib.name) {
        Text(this.lib.uniqueId)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 2 })
          .width('100%')
      }

      // 作者信息
      if (this.lib.developers.length > 0) {
        Text(this.formatDevelopers())
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: 4 })
          .width('100%')
      }

      // 描述
      if (this.lib.description.length > 0) {
        Text(this.lib.description)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
          .width('100%')
      }

      // 版本徽章 + 许可证徽章
      if (this.lib.artifactVersion.length > 0 || this.lib.licenses.length > 0) {
        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(7) } }) { // 版本徽章
          if (this.lib.artifactVersion.length > 0) {
            Text(this.formatVersion())
              .fontSize(11)
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius(4)
              .padding({
                left: 8,
                right: 8,
                top: 3,
                bottom: 3
              })
              .textAlign(TextAlign.Center)
          }

          // 许可证徽章
          ForEach(this.lib.licenses, (lic: License) => {
            if (lic.name.length > 0 || (lic.spdxId && lic.spdxId.length > 0)) {
              Text(lic.name.length > 0 ? lic.name : lic.spdxId)
                .fontSize(11)
                .fontColor($r('sys.color.brand'))
                .backgroundColor($r('sys.color.ohos_id_select_selected_color'))
                .borderRadius(4)
                .padding({
                  left: 8,
                  right: 8,
                  top: 3,
                  bottom: 3
                })
                .textAlign(TextAlign.Center)
            }
          }, (lic: License) => lic.hash)
        }.margin({ top: 8 }).width('100%')
      }
      }.width('100%').padding(8).borderRadius(15)
      .backgroundColor(this.isPressed ? $r('sys.color.ohos_id_color_click_effect') : Color.Transparent)
    }.width('100%').padding(6)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(21)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
  }

  /**
   * 格式化版本号:若首字符为数字则加 "v" 前缀,否则原样返回。
   */
  private formatVersion(): string {
    const v: string = this.lib.artifactVersion;
    if (v.length === 0) {
      return '';
    }
    const first: string = v.charAt(0);
    if (first >= '0' && first <= '9') {
      return `v${v}`;
    }
    return v;
  }

  /**
   * 将开发者列表格式化为逗号分隔的字符串。
   */
  private formatDevelopers(): string {
    const names: string[] = [];
    for (let i = 0; i < this.lib.developers.length; i++) {
      const dev: Developer = this.lib.developers[i];
      if (dev.name.length > 0) {
        names.push(dev.name);
      }
    }
    return names.join(', ');
  }
}
