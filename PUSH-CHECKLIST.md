# PUSH-CHECKLIST —— 推送前逐项过

> **本清单不执行推送** ✓：推送需要作者的 GitHub 账号、仓名与公开/私有决定 ✓，
> 清单只把"推之前必须自己过一遍"的事写清楚 ✓。
>
> 纪律：推送是**不可逆的公开动作** ✓（删仓要另说，改历史更不用提 ✓）。
> 每一步都留下可查的痕迹 ✓，不跳过 ✓。

## 零、作者必须先给的三件事

| # | 要什么 | 为什么需要 |
|---|---|---|
| 1 | GitHub 账号名 | 拼仓 URL ✓ |
| 2 | 三个仓名（可与本地同名） | 拼仓 URL ✓ |
| 3 | 公开 / 私有 | 决定可见性与 CI 触发方式 ✓ |

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
git push -u origin master            # 本仓分支名是 master

# ── 2) axiscope
cd /path/to/axiscope
git remote add origin https://github.com/<账号>/<仓名2>.git
git push -u origin main              # 本仓分支名是 main（与 mcopilot 不同！）

# ── 3) trae_factory
cd /path/to/trae_factory
git remote add origin https://github.com/<账号>/<仓名3>.git
git push -u origin master

# ── 4) 索引仓（本仓）
cd /path/to/forensics-learning-index
git init -b main
git add -A && git commit -m "索引仓：三仓索引 + 推送清单"
git remote add origin https://github.com/<账号>/<索引仓名>.git
git push -u origin main
```

**分支名不一致**（mcopilot/trae = `master` ✓，axiscope = `main` ✓）——
GitHub 新建仓默认分支是 `main` ✓，推送 `master` 会**多出一个分支** ✓。
两个选择都行 ✓，但**要在建仓时就定** ✓（推荐：推之前先
`git branch -m master main` 统一 ✓，或建仓时选 master ✓）。

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
      git clone https://github.com/<账号>/<仓名1>.git && cd <仓名1> && python -m pytest -q
      ```
      —— 干净克隆与本机工作树的差异正是"公开后读者实际拿到的东西" ✓
- [ ] 索引仓的 `<账号>` 占位符**已全部替换** ✓

## 四、公开后仍然成立的账（不许在 README 里抹掉）

- 锚点 commit **未动** ✓（mcopilot `b53ac62` / axiscope `b95ffb2` / trae `954c210` ✓），
  锚点后的新提交在书侧 `ASSETS.md` 登记 ✓。
- mcopilot 早期提交的出站身份仍是自动化身份 ✓（**不改历史** ✓）。
- 协议标准原件在**仓外** ✓ → 干净克隆时相关门禁记 **SKIP** ✓（不是 FAIL ✓）。
- 真机层**未验证** ✓ → 任何"可上产线"的说法都不成立 ✓。
