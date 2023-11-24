#!/bin/bash

# benchmark or load 
for file in $(find benchmark/ -type f ! -name "*.png")
do
  echo "handle $file"
  sed -i '' 's/istio-system/servicemesh/g' "$file"
  sed -i '' 's/gcr.io/gcr.yylt.gq/g' "$file"
  sed -i '' 's/istio: ingressgateway/istio: istio-ingressgateway/g' "$file"
done
