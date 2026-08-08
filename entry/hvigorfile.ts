import { hapTasks } from "@ohos/hvigor-ohos-plugin";
import { ossScanPlugin, OutputFormat } from "osslibraries-hvigor-plugin";

export default {
  system: hapTasks /* Built-in plugin of Hvigor. It cannot be modified. */,
  plugins: [
    ossScanPlugin({ format: OutputFormat.MessagePack }),
  ] /* Scan OHPM deps and generate osslibraries.json at build time. */,
};
