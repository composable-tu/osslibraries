import { Library, License, Developer } from 'osslibraries';
import { LengthMetrics } from '@kit.ArkUI';

@Component
export struct LicenseItem {
  @Prop lib: Library = new Library();

  build() {
    Column() {
      // 库名称
      Text(this.lib.name.length > 0 ? this.lib.name : this.lib.uniqueId)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      // 包名(uniqueId)
      if (this.lib.uniqueId.length > 0 && this.lib.uniqueId !== this.lib.name) {
        Text(this.lib.uniqueId)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .maxLines(1)
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
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
          .width('100%')
      }

      // 版本徽章 + 许可证徽章
      if (this.lib.artifactVersion.length > 0 || this.lib.licenses.length > 0) {
        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(7) } }) {
          // 版本徽章
          if (this.lib.artifactVersion.length > 0) {
            Text(this.formatVersion())
              .fontSize(11)
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius(4)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .textAlign(TextAlign.Center)
          }

          // 许可证徽章
          ForEach(this.lib.licenses, (lic: License) => {
            Text(lic.name)
              .fontSize(11)
              .fontColor($r('sys.color.brand'))
              .backgroundColor($r('sys.color.ohos_id_select_selected_color'))
              .borderRadius(4)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .textAlign(TextAlign.Center)
          }, (lic: License) => lic.hash)
        }
        .margin({ top: 8 })
        .width('100%')
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
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
