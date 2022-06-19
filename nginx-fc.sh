kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx-fc
spec:
  runtimeClassName: kata-fc
  containers:
    - name: nginx
      image: nginx
EOF