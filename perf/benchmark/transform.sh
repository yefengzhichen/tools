#!/bin/bash

# 设置文件夹路径
folder_path="out1"
out_dir="out2"

# 循环遍历文件夹中的所有 .json 文件
for file in $folder_path/*.json
do
  # 获取文件名（不包括扩展名）
  filename=$(basename -- "$file")
  filename="${filename%.*}"

  # 使用 docker 命令处理文件，并将结果保存为 .fortio.json 文件
  cat "$file" | docker run -i --rm docker.io/envoyproxy/nighthawk-dev:59683b759eb8f8bd8cce282795c08f9e2b3313d4 nighthawk_output_transform --output-format fortio > "$out_dir/$filename.fortio.json"
done