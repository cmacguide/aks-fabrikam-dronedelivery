envsubst < helm-values-dev.yaml > helm-values-dev-resolved.yaml

# Depois faça o deploy

helm install delivery-v0.1.0-dev delivery-v0.1.0.tgz \
 --values helm-values-dev-resolved.yaml \
 --namespace backend-dev
