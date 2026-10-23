# 取证式学习 · 三仓索引

> 本仓**不含代码**，是一张**索引**：指向三个相互独立、各自可跑的工程仓，
> 并说清它们之间**怎么接**、**接到哪一步**、**哪些还没接上**。
>
> 为什么要一个索引：三个仓的**锚点语义**各不相同（坐标按各自仓根相对路径记 ✓），
> 合成一个仓会破掉它 ✓；但完全不索引，读者又不知道三者怎么配合 ✓。

## 一、三个仓

| 仓（GitHub 上的公开名） | 是什么 | 体量（入库） | 状态 |
|---|---|---|---|
| **[mcopilot](https://github.com/JosephIvon/mcopilot)** | 协议域的**真值钉扎与门禁**：协议知识库（Modbus / S7 / FOCAS / SLMP）、帧级黄金测试、契约测试、故障注入农场、接入闭环 | 199 件 / 13.5 MB | 门禁 G1–G12 全绿 ✓，pytest 387 passed ✓ |
| **[forensics-code-factory](https://github.com/JosephIvon/forensics-code-factory)** | 上位机**代码工厂**：浏览器里填轴数与工艺，生成带真值链的 C# 运动控制工程 | 190 件 / 2.2 MB | 生成器可跑 ✓，单文件交付物与 `gen/` 同源 ✓ |
| **[axiscope](https://github.com/JosephIvon/axiscope)** | **数据契约与知识库**：C1–C7 数据契约、KB0–KB8 知识库、数据溯源存证、评测纪律 | 185 件 / 25.5 MB | pytest 403 passed ✓，脱敏自检通过 ✓ |

> **可见性**：三个工程仓**全部公开** ✓（作者裁定 2026-10-23 ✓）。
> **仓名**：`mcopilot` / `axiscope` / `forensics-code-factory` / 本索引仓 `forensics-learning-index` ✓；
> **分支**：三个工程仓统一 `main` ✓（mcopilot 与 trae_factory 由 `master` 改名 ✓）。
> **`JosephIvon` 仍是占位符** ✓——GitHub 账号尚未提供，推送前必须替换 ✓。

## 二、它们怎么接（接缝图）

```
        mcopilot（协议真值：签名 / 黄金帧 / 契约 / 故障签名）
              │  生成时实时读取 knowledge/sdks/*.json（不复制副本）
              ▼
        trae_factory（生成 C# 适配层，逐条标 [源|核对|提取]）
              │  生成物（out/mc_*/）
              ▼
        axiscope（数据契约与知识库：字段口径 / 单位 / 溯源 / 评测）
```

三条接缝的真实状态（**不粉饰** ✓）：

| 接缝 | 内容 | 状态 |
|---|---|---|
| 接缝 1 | trae_factory → mcopilot：生成时读知识库，不另设真值副本 | **已接** ✓；知识库不可达时整体降级并在产物里写明 ✓ |
| 接缝 2 | mcopilot → axiscope：数据契约与判据 | **已接** ✓（复核脚本 `verify_traekb_citations.py` ✓） |
| 接缝 3 | 共享行为评测集（接缝 3） | **未闭合** ✗：评测集文件与对照脚本**未入库** ✓，故工厂侧只有断言、没有 mcopilot 侧对照行 ✓ |

## 三、真值链：每条 P/Invoke 都带三根轴

产物里每个 P/Invoke 声明都标着 `[源 | 核对 | 提取]` ✓：

- **源** —— 这条结论从哪来（`verified` = 有出处；未标注 = 不知道 ✓）
- **核对** —— 验到哪一步（`manual` / `hardware` / `auto` / `none` ✓）
- **提取** —— 签名对是否等于调用对（`judgment` = 有语义陷阱，**必须人签字才能当事实用** ✓）

**当前实数**（从 `trae_factory` 的真值链文档实算 ✓）：

| 品牌 | P/Invoke | 钉扎 | 未收录（降级） | 核对进度 |
|---|---|---|---|---|
| 固高 GTS/GTN | 22 | 19 | 3 | none 19 |
| 正运动 ZMotion | 20 | 17 | 3 | none 17 |
| 雷赛 DMC/EMC | 16 | 13 | 3 | none 13 |
| 软赢 / 高川 | 0（骨架） | 0 | 0 | — |
| ACS SPiiPlus | 0 | 0 | 0 | 需厂商 DLL，不在全品牌套件 |
| **全品牌套件** | **58** | **49** | **9** | **none 49** |

**诚实的读法** ✓：`钉扎 49` 只解决"这条从哪来"✓，**不解决"它对不对"** ✓——
`核对 none 49` 说明这 49 条**一条都没核对过** ✓，
按本工程的 R2 纪律，它们在生成代码里标着 `TODO[需核对厂商手册]` ✓。

## 四、共同的硬规矩（三仓都写在自己仓里）

1. **门禁是唯一的裁判** —— 文档说"能做"不算，门禁跑绿才算 ✓。
2. **静默 skip 不算绿** —— 门禁的 SKIP 必须在汇总行喊出"当前不可自动复核" ✓
   （PROVENANCE §4 点名的最危险失败模式 ✓）。
3. **原件外置，指针留仓** —— 厂商/标准原件放在仓外约定目录 ✓，
   仓内只留 `size` + `sha256` ✓；原件不在位时门禁记 SKIP 并写明原因 ✓。
4. **不删记录** —— 曾经存在的件即使当前生成器不再产出，也保留并标注 ✓。
5. **不为署名改历史** —— 本体系以 commit 哈希为坐标锚 ✓，历史不可重写 ✓。

## 五、许可与第三方材料

- 三仓的自有代码均为 **MIT** ✓（各仓的 `LICENSE` ✓）。
- 第三方材料逐件登记在**各仓自己的 `NOTICE.md`** ✓：
  mcopilot（厂商抽取 CSV / 公开 issue 语料 / 招聘信息语料 / pcap 片段 ✓）、
  axiscope（DaRUS / ScienceDB / Zenodo 派生的样本卡，**CC BY 4.0 须署名** ✓）、
  trae_factory（**不含第三方原件** ✓，真值引用来自 mcopilot 且不复制 ✓）。
- 协议标准与厂商手册原件（7 份 PDF）**不随任何一仓分发** ✓：
  放在 mcopilot 的仓外约定目录 ✓，公开读者若需复核请按 NOTICE 记的公开渠道取原件 ✓。

## 六、与本书的关系

《取证式学习》三册的正文坐标 = **各仓的锚点 commit + 路径** ✓，
审计器按锚点 commit 读源文件（`git show`）✓——
所以**改工作树或新增提交，不会影响书里任何一行坐标** ✓。

| 册 | 对应的仓 | 坐标锚点 |
|---|---|---|
| 卷一《协议域卷》 | mcopilot | `b53ac62` |
| 册一《审计与合规卷》 | axiscope | `b95ffb2` |
| 册二《代码工厂与真值链卷》 | trae_factory（公开名 `forensics-code-factory`） | `954c210` |

> 锚点之后各仓都有新提交 ✓（公开前硬化等 ✓），**锚点本身未动** ✓——
> 动锚点要重验全书 697 个坐标 ✓，收益远小于代价 ✓。

## 七、还没接上的（挂账，不假装已清）

- **真机层**：三仓都**没有真机验证** ✓，真机波次是**设计性挂起** ✓
  （Tier C 冻结至硬件到场 ✓）。
- **接缝 3**：共享行为评测集未入库 ✓。
- **mcopilot 历史署名**：早期提交仍是自动化身份（不改历史 ✓，代价已登记 ✓）。
- **协议标准原件**：外置于仓外约定目录，干净检出时相关门禁记 SKIP ✓。

## 八、怎么用（三分钟版）

```bash
# 1) 取协议真值与门禁
git clone https://github.com/JosephIvon/mcopilot.git
cd mcopilot && pip install -e . && python -m pytest -q      # 387 passed

# 2) 取代码工厂（可选：让它读上面的 mcopilot 知识库）
git clone https://github.com/JosephIvon/forensics-code-factory.git
cd forensics-code-factory && node test_gen.js all                      # 退出码 0

# 3) 取数据契约与知识库
git clone https://github.com/JosephIvon/axiscope.git
cd axiscope && pip install -e . && python -m pytest -q       # 403 passed
```

三仓**可各自独立跑** ✓；相互引用时按 §二 的接缝图摆放 ✓
（同级兄弟目录 ✓，或用环境变量指定 ✓）。
