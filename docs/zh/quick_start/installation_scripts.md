# 安装脚本

MinerU 提供了自动化安装脚本，可简化不同平台的安装过程。这些脚本处理检查系统要求、安装依赖项以及为您的特定环境配置 MinerU 的所有复杂性。

## 可用脚本

### Python 脚本（跨平台）
- **文件**: `install_mineru.py`
- **平台**: Linux、macOS、Windows
- **特性**: 提供多种选项的交互式安装

### Bash 脚本（Unix）
- **文件**: `install_mineru.sh`
- **平台**: Linux、macOS
- **特性**: 快速自动化安装

### PowerShell 脚本（Windows）
- **文件**: `install_mineru.ps1`
- **平台**: Windows
- **特性**: Windows 快速自动化安装

## 快速开始

### Linux / macOS

**交互式安装（推荐）**
```bash
python3 install_mineru.py
```

**快速安装**
```bash
bash install_mineru.sh
```

**一键安装**
```bash
curl -sSL https://raw.githubusercontent.com/opendatalab/MinerU/master/install_mineru.sh | bash
```

### Windows

**交互式安装（推荐）**
```powershell
python install_mineru.py
```

**快速安装**
```powershell
powershell -ExecutionPolicy Bypass -File install_mineru.ps1
```

## Python 脚本功能

Python 安装脚本（`install_mineru.py`）提供了一个交互式菜单，包含三个安装选项：

### 1. 快速安装（推荐）
安装 `mineru[all]`，包含：
- 所有核心功能（VLM + Pipeline + API + Gradio）
- 平台特定优化：
  - **Linux**: vLLM 支持
  - **macOS**: MLX 支持（Apple Silicon）
  - **Windows**: LMDeploy 支持

### 2. 自定义安装
允许您选择特定的后端：
- **core**: 所有核心功能，不包含平台特定加速器
- **pipeline**: 传统管道后端（兼容性好）
- **vlm**: 视觉语言模型后端（高准确度）
- **api**: FastAPI 服务器支持
- **gradio**: Gradio Web UI 支持
- **mlx/vllm/lmdeploy**: 平台特定加速器

### 3. 从源码安装
克隆仓库并从源代码安装，适用于：
- 开发工作
- 最新未发布功能
- 为项目做贡献

## 脚本执行的操作

所有安装脚本执行以下步骤：

1. **系统检查**
   - 验证 Python 版本（要求 3.10-3.13，Windows 上为 3.10-3.12）
   - 检测操作系统和架构
   - 检查 macOS 版本（要求 14.0+）
   - 验证 Windows Python 版本兼容性

2. **依赖项安装**
   - 升级 pip 到最新版本
   - 安装 uv 包管理器（推荐）
   - 如果 uv 安装失败则回退到 pip

3. **MinerU 安装**
   - 安装选定的 MinerU 包
   - 优雅地处理安装错误
   - 提供详细的错误消息

4. **验证**
   - 验证安装成功
   - 显示已安装版本
   - 显示使用说明

5. **使用指南**
   - 显示基本命令
   - 显示后续步骤
   - 提供文档链接

## 脚本输出

脚本提供彩色编码输出以便于阅读：

- ✓ **绿色**: 成功的操作
- ✗ **红色**: 错误
- ⚠ **黄色**: 警告
- ℹ **青色**: 信息消息

## 故障排除

### Python 版本问题

如果看到 "Python X.X is not supported"：

```bash
# 检查您的 Python 版本
python3 --version

# 如果安装了多个版本，使用特定的 Python 版本
python3.11 install_mineru.py
```

### 权限错误

**Linux/macOS:**
```bash
# 仅为当前用户安装
python3 -m pip install --user "mineru[all]"
```

**Windows:**
- 以管理员身份运行 PowerShell
- 或使用虚拟环境

### 网络问题

如果遇到下载缓慢或超时：

```bash
# 使用镜像源（中国用户）
pip install -i https://mirrors.aliyun.com/pypi/simple "mineru[all]"

# 或设置环境变量
export PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple
python3 install_mineru.py
```

### 脚本执行错误

**macOS 脚本被阻止:**
```bash
chmod +x install_mineru.sh
bash install_mineru.sh
```

**PowerShell 执行策略:**
```powershell
# 临时允许脚本执行
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 或直接运行
powershell -ExecutionPolicy Bypass -File install_mineru.ps1
```

## 虚拟环境（推荐）

为了清洁安装，使用虚拟环境：

**Linux/macOS:**
```bash
python3 -m venv mineru-env
source mineru-env/bin/activate
python3 install_mineru.py
```

**Windows:**
```powershell
python -m venv mineru-env
.\mineru-env\Scripts\Activate.ps1
python install_mineru.py
```

## 手动安装

如果脚本不适用于您的系统，可以手动安装：

```bash
pip install --upgrade pip
pip install uv
uv pip install -U "mineru[all]"
```

详细的手动安装说明请参阅 [INSTALL.md](../../../INSTALL.md)。

## 后续步骤

安装后：

1. **下载模型**（首次设置）
   ```bash
   mineru-models-download
   ```

2. **测试安装**
   ```bash
   mineru -p sample.pdf -o output_dir
   ```

3. **探索功能**
   - 尝试 API 服务器: `mineru-api`
   - 启动 Gradio UI: `mineru-gradio`
   - 阅读[使用指南](../usage/index.md)

## 获取帮助

如果遇到问题：

- 查看 [FAQ](../faq/index.md)
- 访问 [INSTALL.md](../../../INSTALL.md) 了解详细故障排除
- 加入我们的 [Discord](https://discord.gg/Tdedn9GTXq) 社区
- 在 [GitHub Issues](https://github.com/opendatalab/MinerU/issues) 上提问

## 贡献

发现安装脚本中的错误或有改进建议？欢迎贡献！

1. Fork 仓库
2. 创建功能分支
3. 进行更改
4. 提交 Pull Request

请参阅 [CONTRIBUTING.md](../../../CONTRIBUTING.md) 了解指南。
