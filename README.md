# Shell Scripts

常用 Shell 脚本集合。

---

## 脚本列表

| 脚本 | 简介 | 目录 |
|------|------|------|
| [NPM → Homepage 双列同步](npm-to-homepage/) | 将 Nginx Proxy Manager 的代理配置自动同步到 Homepage 仪表盘，生成外网+内网双列服务布局 | [`npm-to-homepage/`](npm-to-homepage/) |

---

## 目录结构

```
shell/
├── README.md              # 本文件，脚本索引
└── npm-to-homepage/       # 每个脚本独立目录
    ├── README.md          # 脚本说明文档
    └── npm-to-homepage-dual.sh  # 脚本文件
```

> 新增脚本时，在根目录创建独立子目录，放入脚本文件和对应 README。
