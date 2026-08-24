# nonconstant v1

**给 AI 编码工作流装一道闸：让「我检查过了」变成一条能跑的命令 + 一个退出码。**

十条判据，全部非交互、以退出码作答（`0` 过 / `1` 未过 / `2` **判不了**）。
⭐ 第三档是关键：判不了绝不返回 0。装进任何 git 仓库，三个时机各有入口 ——
随手查一条（`bash .nonconstant/<gate>.sh`）、提交前自动（`pre-commit` hook）、
任务过程中（spec-kit workflow）。

⚠️ ⛔ **它不保证你的判断正确，只保证你的声明可核。**
自己的操作协议 33 条里只有 5 条是机器化的，四项已知缺口写在 README 里 ——
⭐ 包括「本仓最好的那个 demo 可以用一行注释绕过」。

⭐ 建在 [github/spec-kit](https://github.com/github/spec-kit) v1.0.0 之上（submodule pin，不含其代码）。
定位建在 Addy Osmani 的 [Loop Engineering](https://addyosmani.com/blog/loop-engineering/) 上。
⚠️ 同域已有更成熟的工具（axiom / groundtruth / nah / Mantiz）—— README 里点了名。

MIT。
