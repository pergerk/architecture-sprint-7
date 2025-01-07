#!/bin/bash

USER=${1:-user1}
USER_GROUPS=${2:-group1}
echo $USER $USER_GROUPS

for group in $(echo $USER_GROUPS | tr "," "\n")
do
    user_groups="$user_groups/O=$group"
done
echo $user_groups
exit 0;


KUBERNETES_ADMIN_CONTEXT=docker-desktop


if [[ -d $USER ]]; then
    echo "Пользователь $USER уже создан"
    exit 0
fi

mkdir -p $USER

cert_key=$USER/user.key
cert_crt=$USER/user.crt
cert_pem=$USER/user.pem
cert_csr=$USER-csr

openssl genrsa -out $cert_key 2048

kubernetes_csr=$USER/kubernetes.csr.yml


cat <<EOF > $kubernetes_csr
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $cert_csr
spec:
  request: $(openssl req -new -key $cert_key -subj "/CN=$USER$USER_GROUPS/" | base64 | tr -d "\n")
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages:
  - client auth
EOF

kubectl apply -f $kubernetes_csr --context $KUBERNETES_ADMIN_CONTEXT

kubectl certificate approve $cert_csr --context $KUBERNETES_ADMIN_CONTEXT

kubectl wait --for=condition=approved csr $cert_csr --context $KUBERNETES_ADMIN_CONTEXT

kubectl get csr $cert_csr -o jsonpath='{.status.certificate}'  --context $KUBERNETES_ADMIN_CONTEXT | base64 -d > $cert_pem

openssl x509 -in $cert_pem -out $cert_crt -outform PEM

kubectl config set-context  $USER --user $USER --cluster $KUBERNETES_ADMIN_CONTEXT --namespace default

echo "Пользователь $USER создан"
