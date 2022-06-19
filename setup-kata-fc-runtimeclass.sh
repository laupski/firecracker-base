kubectl apply -f - <<EOF
apiVersion: node.k8s.io/v1beta1
kind: RuntimeClass
metadata:
  name: kata-fc
handler: kata-fc
EOF