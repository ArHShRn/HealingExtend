# HealingExtend Plus v1.1.3

**KF2 Healing Extension Mutator — Designed for CD Mode**
**KF2 治疗扩展 Mutator — 为 CD 模式设计**

---

## Project Status 项目状态

This project was dormant for a long time, but is now **active again** with plans for a refactor.

**重新活跃**，准备进行重构。

### Refactoring Direction 重构方向

- **Extract core healing mechanics** (headshot healing, overclocking) and simplify code structure
  提取核心治疗机制（爆头回复、超频），简化代码结构
- **Remove HUDManager** and other modules known to cause compatibility issues
  移除 HUDManager 等已知引起兼容性问题的模块
- **Goal**: Cleaner codebase, better compatibility
  目标：更干净的代码，更好的兼容性

Progress will be steady but unhurried. Ideas, bug reports, and questions are welcome — feel free to open an issue.

会持续推进，有想法、发现 bug 或有问题的话，欢迎提 issue。

---

## Command Lines 启用命令行

```
?Mutator=HealingExtend.HE_Main
```

**If using RPW, put HE after RPW for compatibility:**
**如果使用了 RPW，请将 HE 放在 RPW 后面以确保兼容性：**

```
?Mutator=RPWMod.RestrictPW,HealingExtend.HE_Main
```

---

## Thanks 感谢名单

Pharrahnox
Teriyakisaurus Rex
Blackout

---

## Wiki

The `wiki/` directory contains archived documentation on the plugin's code structure and design, based on the v1.1.3 codebase. Useful for understanding the plugin's internals and development history.

`wiki/` 目录下有基于 v1.1.3 代码的结构归纳文档，供了解插件内部实现和开发历史参考。

- [中文版 Chinese](wiki/index_CN.html)
- [English](wiki/index_EN.html)
