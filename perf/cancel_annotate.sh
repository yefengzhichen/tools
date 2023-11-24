#!/bin/bash

# 获取名称匹配正则表达式的节点
nodes=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep 'node-71')

function cancel_annotate() {
  # 设置节点名和注解键
  node_name=$1
  pool_name=$2

  # 获取注解的值
  annotation_value=$(kubectl get node $node_name -o jsonpath="{.metadata.annotations.ipam\.cilium\.io/openstack-ip-pool}")
  echo "old values: $annotation_value"

  # 将注解的值分割成数组
  IFS=',' read -ra values <<< "$annotation_value"

  # 遍历数组，移除pool_name
  new_values=()
  for value in "${values[@]}"; do
    if [[ $value != $pool_name ]]; then
      new_values+=($value)
    fi
  done

  # 将新的值合并成字符串
  new_annotation_value=$(IFS=,; echo "${new_values[*]}")
  echo "new values: $new_annotation_value"

  # 更新注解的值
  kubectl annotate node $node_name ipam.cilium.io/openstack-ip-pool=$new_annotation_value --overwrite
}

pool_name=$1
for node in $nodes
do
  echo $node
  cancel_annotate $node $pool_name
done