# NPM → Homepage 双列服务自动同步

将 [Nginx Proxy Manager](https://nginxproxymanager.com/) (NPM) 的代理配置自动转换为 [Homepage 仪表盘](https://gethomepage.dev/) `services.yaml`，生成**外网 + 内网双列**服务布局。

---

## 功能特性

- 🔄 自动读取 NPM SQLite 数据库中的反向代理配置
- 🌐 生成**外网服务**（走 NPM 反代端口）和**内网服务**（直连内网地址）双列布局
- ⚡ 内网服务直连容器/主机 IP，避免经过反代端口，访问更快
- 🎨 自动提取域名作为服务名称，图标命名为 `服务名.png`

---

## 前置依赖

| 依赖 | 说明 |
|------|------|
| `sqlite3` | 用于读取 NPM 的 SQLite 数据库 |
| `docker` | 运行 NPM 和 Homepage 容器 |

---

## 配置说明

修改脚本开头的配置变量：

```bash
NPM_DB="/data/docker-data/NPM/data/database.sqlite"      # NPM 数据库路径
OUTPUT_YAML="/data/docker-data/homepage/config/services.yaml"  # 输出路径
EXTERNAL_PORT="1443"                                      # 外网端口
```

---

## 使用方法

```bash
chmod +x npm-to-homepage-dual.sh
./npm-to-homepage-dual.sh
docker restart homepage
```

---

## 输出示例

```yaml
- 外网服务:
    - nas:
        href: "https://nas.example.com:1443"
        icon: "nas.png"
        description: 外网访问

- 内网服务:
    - nas:
        href: "http://172.17.0.5:5000"
        icon: "nas.png"
        description: 内网高速访问
```

---

## 注意事项

1. 域名自动去除 `[]`、引号、逗号，取第一个域名
2. 内网服务根据 `forward_scheme` 选择 `http/https`，默认为 `http`
3. Homepage 需要对应目录下有 `服务名.png` 图标
4. 外网列仅包含 `enabled = 1` 的代理
5. 已删除（`is_deleted = 1`）的代理会被跳过

---

## 常见问题

**Q: `sqlite3: command not found`？**

```bash
# Debian/Ubuntu
sudo apt install sqlite3
# CentOS/RHEL
sudo yum install sqlite3
# Alpine
sudo apk add sqlite
```

**Q: 如何排除某些服务？**

在 NPM 中将不需要的代理标记为**未启用**（`enabled = 0`）。