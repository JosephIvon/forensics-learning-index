# PUSH-CHECKLIST —— 推送前逐项过

> **一键版** ✓：设好令牌后跑本仓的 `push_to_github.ps1` ✓，它会建空仓 → 推四个仓 →
> 再从 GitHub **干净克隆复验** ✓（读者实际拿到的东西 ✓）。
>
> ```powershell
> $env:GITHUB_TOKEN = "<你的 PAT>"      # 需要 repo 权限
> pwsh -File push_to_github.ps1 -Account JosephIvon
> ```
>
> 令牌只进进程环境 ✓，不落盘 ✓、不进 git config ✓、不进仓库 ✓。
> 下面的清单是**这份脚本做的每一件事的人工对照** ✓ —— 脚本跑一遍即可，
> 但清单留着：脚本哪天没人维护了，口径不该跟着丢 ✓。

> **本清单不代替作者拍板** ✓：推送是不可逆的公开动作 ✓
> （删仓要另说，改历史更不用提 ✓）。每一步都留下可查的痕迹 ✓，不跳过 ✓。

## 零、作者必须先给的三件事

| # | 要什么 | 状态 |
|---|---|---|
| 1 | GitHub 账号名 | 默认 `JosephIvon` ✓（与仓内提交身份 `JosephIvon <fanwenbo2046@163.com>` 一致 ✓）；改账号传 `-Account` ✓ |
| 2 | 三个仓名 | 已定：`mcopilot` / `axiscope` / `forensics-code-factory` ✓ |
| 3 | 公开 / 私有 | 已定：**全部公开** ✓（作者裁定 2026-10-23 ✓） |
| 4 | 一个可用的 PAT | **待给** ✓：2026-10-23 试过账号密码 `Gh@112114` → API 三种鉴权头全 401 ✗（GitHub 的 API 与 git 已不接受账号密码 ✓）→ 需在 GitHub 设置里生成 **Personal Access Token**（勾 `repo` ✓）✓ |

> 仓名有重名风险时建议加前缀（如 `forensics-mcopilot`）✓——
> `mcopilot` / `axiscope` / `trae_factory` 都是常见名 ✓。

## 一、推送前必须全绿的检查（本地已跑过一遍 ✓）

| 项 | 命令 | 实测 | 备注 |
|---|---|---|---|
| mcopilot 测试 | `python -m pytest -q` | **387 passed / 0 failed** ✓ | 基线曾是 383/2failed/2skipped ✓，那 2 条已修 ✓ |
| mcopilot 门禁 | `pwsh -File scripts/gate_protocol.ps1` | **12/12** ✓ | G1–G12 ✓ |
| axiscope 测试 | `python -m pytest -q` | **403 passed** ✓ | |
| axiscope 脱敏 | `python data/probe_pii.py` | 三个标识值 token **0** ✓ | |
| trae 生成 | `node test_gen.js all` | 退出码 **0** ✓ | |
| trae 单文件同源 | `node concat.js` 后 `git diff` | 必须**为空** ✓ | 防止交付物再漂移 ✓ |
| 绝对路径 | `python <书仓>/tools/scan_absolute_paths.py` | 家目录/用户名 **0**、本机工作区 **0** ✓ | 余下是 `C:\Program Files` / `C:\Windows` 系统路径 ✓ |
| 秘密 | `python <书仓>/tools/probe_publish_readiness.py` | 疑似秘密 **0** ✓ | |
| 账实相符 | `python <书仓>/tools/check_doc_refs_heads.py` | 真断链 **0** ✓ | 按 HEAD 核 ✓ |
| 工作树 | `git status --porcelain` | 三仓均 **0 件** ✓ | 推之前必须干净 ✓ |

### 一之二：**干净克隆**复验（2026-10-23 新增 ✓ —— 这才是"读者拿到的东西" ✓）

> 本机工作树绿 ≠ 公开后能用 ✓。上一轮 push 前实测发现**四个真实发布缺陷** ✓：
> `.gitignore` 的 `*.log` 把测试夹具扫掉 ✗、87 个测试因原始数据不在位而红 ✗、
> G5 与 G7 的缺件口径不一致 ✗、负向门禁 N1 在缺件时**假绿** ✗。
> 所以下面这组检查是**发布前的硬门槛** ✓（全部由本地路径克隆跑出 ✓ = CI 会跑的 ✓）：

| 仓 | 干净克隆实测 | 处置 |
|---|---|---|
| mcopilot | pytest **382 passed / 5 skipped** ✓；门禁 **10/12（SKIP 2，失败 0）** ✓；负向门禁 **7/7 PASS + SKIP 1** ✓ | 缺件记 SKIP 且**写明「当前不可自动复核」** ✓；N1 基线不可核时记 SKIP 而非假绿 ✓ |
| axiscope | pytest **294 passed / 110 skipped** ✓；`probe_pii` 退出码 **0** ✓ | 新增 `tests/conftest.py` ✓：按各文件 `REQUIRES_DATA` **显式声明**执行 loud SKIP ✓ |
| trae_factory | `node test_gen.js all` 退出码 **0** ✓；`concat.js` 后单文件 **无差异** ✓；产物绝对路径 **0** ✓ | 无 mcopilot 兄弟目录时**降级并在产物里写明** ✓（`JointEval.md` 的「⚠ 共享评测集缺失」✓） |

> 跳过 ≠ 通过 ✓。每条 SKIP 都带原因 ✓，CI 日志里能一眼看出
> **有多少断言在缺件时没跑** ✓ —— 那正是"当前不可自动复核"的范围 ✓。

**入库体积**（GitHub 限 100 MB/文件 ✓）✓：

| 仓 | 件数 | 体积 | 最大单文件 |
|---|---|---|---|
| mcopilot | 199 | 13.5 MB | 5.5 MB（`samples/servo/klipper_resonance_x.csv` ✓） |
| axiscope | 185 | 25.5 MB | 1.7 MB（`bench/samples/*/waveform.tsv` ✓） |
| trae_factory | 190 | 2.2 MB | — |

> `out/`（mcopilot、trae_factory）与 `data/`（axiscope）是**不入库区** ✓，
> 不随推送走 ✓；`out/` 可再生 ✓，`data/raw` 按 DOI 可重下 ✓。

## 二、建仓与推送（按顺序，一个一个来）

```bash
# ── 0) 在 GitHub 上先建**空**仓（不要勾 README/.gitignore/LICENSE——
#      本地已有，这三个会让首次 push 冲突）
#    三个仓：<账号>/<仓名1>、<账号>/<仓名2>、<账号>/<仓名3>

# ── 1) mcopilot
cd /path/to/mcopilot
git remote add origin https://github.com/<账号>/<仓名1>.git
git push -u origin main              # 分支已统一为 main

# ── 2) axiscope
cd /path/to/axiscope
git remote add origin https://github.com/<账号>/<仓名2>.git
git push -u origin main              # 本仓本来就是 main

# ── 3) trae_factory
cd /path/to/trae_factory
git remote add origin https://github.com/<账号>/<仓名3>.git
git push -u origin main

# ── 4) 索引仓（本仓）
cd /path/to/forensics-learning-index
git init -b main
git add -A && git commit -m "索引仓：三仓索引 + 推送清单"
git remote add origin https://github.com/<账号>/<索引仓名>.git
git push -u origin main
```

**分支名已统一** ✓：三个工程仓都已在本地改为 `main` ✓
（mcopilot 与 trae_factory 由 `master` 改名 ✓，axiscope 本就是 `main` ✓）。
**改名不改历史、不改任何坐标** ✓——坐标锚的是 commit，不是分支名 ✓。

## 三、推完之后的验证（不是"推了就算"）

- [ ] 三个仓的网页上**文件树完整** ✓（尤其含中文名目录 ✓ ——
      之前踩过 `git ls-files` 对中文路径加引号的坑 ✓，网页上要亲眼确认 ✓）
- [ ] 三个仓的 **Actions 第一次跑是绿的** ✓（CI 都在 `.github/workflows/` ✓）：
      - mcopilot `gates.yml`（windows-latest + pytest + G1–G12 ✓）
      - axiscope `tests.yml`（403 项 + 脱敏自检 ✓）
      - trae_factory `build.yml`（再生 + 单文件同源 + 产物无绝对路径 ✓）
- [ ] 随机挑 2 个**中文名文件**点开，确认内容没乱码 ✓
- [ ] 在**干净克隆**里跑一遍主命令 ✓：
      ```bash
      git clone https://github.com/<账号>/mcopilot.git && cd mcopilot && python -m pytest -q
      ```
      —— 干净克隆与本机工作树的差异正是"公开后读者实际拿到的东西" ✓
- [ ] 索引仓的 `<账号>` 占位符**已全部替换** ✓

## 四、公开后仍然成立的账（不许在 README 里抹掉）

- 锚点 commit **未动** ✓（mcopilot `b53ac62` / axiscope `b95ffb2` / trae `954c210` ✓），
  锚点后的新提交在书侧 `ASSETS.md` 登记 ✓。
- mcopilot 早期提交的出站身份仍是自动化身份 ✓（**不改历史** ✓）。
- 协议标准原件在**仓外** ✓ → 干净克隆时相关门禁记 **SKIP** ✓（不是 FAIL ✓）。
- 真机层**未验证** ✓ → 任何"可上产线"的说法都不成立 ✓。
