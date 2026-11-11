import type { ProfileConfig } from "@/types/config";
import { withUserConfig } from "../utils/config-overlay.ts";

/**
 * 博主资料：头像 / 名称 / 简介 / 社交链接（侧栏 Profile 卡片、页脚、RSS 作者等消费）。
 * 类型见 src/types/config.ts。
 *
 * 【替换头像】把图片放进 src/assets/images/，然后把 avatar 改成相对 src 的路径，
 * 构建期会自动生成响应式 WebP/AVIF；以 "/" 开头则是从 public/ 取原图、不做优化。
 */
export const profileConfig: ProfileConfig = withUserConfig("profile", {
	avatar: "assets/images/demo-avatar.webp",
	name: "叁月",
	bio: "把日常写成可以翻阅的样子。",
	links: [
		{
			// 想加一个入口就复制这一段：name 显示名，icon 去 https://icones.js.org/ 搜图标代码，
			// url 填你的主页。用到的图标集必须已安装（fa7-brands / material-symbols 已内置）。
			name: "GitHub",
			icon: "fa7-brands:github",
			url: "https://github.com",
		},
	],
});
