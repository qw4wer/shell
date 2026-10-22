#!/bin/bash

# ===================== 【按需修改下面配置】 =====================
# NPM 数据库路径
NPM_DB="/data/docker-data/NPM/data/database.sqlite"

# 输出到 Homepage 的 services.yaml
OUTPUT_YAML="/data/docker-data/homepage/config/services.yaml"

# 外网访问端口
EXTERNAL_PORT="1443"
# ============================================================
# 清空并生成头部
cat > "$OUTPUT_YAML" << EOF
# NPM 自动生成：外网 + 内网 双列服务
# 生成时间: $(date)

- 外网服务:
EOF

# 生成外网服务（已修复：去掉 [] 和 引号）
sqlite3 "$NPM_DB" "
SELECT domain_names, forward_port
FROM proxy_host
WHERE enabled = 1 AND is_deleted = 0
ORDER BY id DESC;
" | while IFS='|' read -r domain port; do

    # 【核心修复】去掉 []、引号、逗号，只留纯域名
    REAL_DOMAIN=$(echo "$domain" \
      | sed 's/[][]//g' \
      | sed 's/"//g' \
      | cut -d',' -f1 \
      | xargs
    )

    NAME=$(echo "$REAL_DOMAIN" | cut -d'.' -f1)

    cat >> "$OUTPUT_YAML" << EOF
    - $NAME:
        href: "https://$REAL_DOMAIN:$EXTERNAL_PORT"
        icon: "$NAME.png"
        description: 外网访问
EOF
done

# 生成内网服务
cat >> "$OUTPUT_YAML" << EOF

- 内网服务:
EOF

sqlite3 "$NPM_DB" "
SELECT domain_names, forward_port, forward_host, forward_scheme
FROM proxy_host
WHERE is_deleted = 0
ORDER BY id DESC;
" | while IFS='|' read -r domain port forward_host forward_scheme; do

    # 如果 forward_scheme 为空，默认 http
    scheme="${forward_scheme:-http}"

    REAL_DOMAIN=$(echo "$domain" \
      | sed 's/[][]//g' \
      | sed 's/"//g' \
      | cut -d',' -f1 \
      | xargs
    )

    NAME=$(echo "$REAL_DOMAIN" | cut -d'.' -f1)

    cat >> "$OUTPUT_YAML" << EOF
    - $NAME:
        href: "${scheme}://${forward_host}:${port}"
        icon: "$NAME.png"
        description: 内网高速访问
EOF
done

echo "♻️  重启 Homepage 生效：docker restart homepage"