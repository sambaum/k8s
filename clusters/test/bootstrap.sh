export GITHUB_TOKEN=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

microk8s config > ~/.kube/config

GITHUB_USER=sambaum
REPOSITORY=k8s
BRANCH=test
ENVIRONMENT=test

kubectl create namespace flux-system
cat ~/.sops/age.agekey |
kubectl create secret generic sops-age \
--namespace=flux-system \
--from-file=age.agekey=/dev/stdin

flux bootstrap github \
  --components-extra=image-reflector-controller,image-automation-controller \
  --owner=$GITHUB_USER \
  --repository=$REPOSITORY \
  --branch=$BRANCH \
  --path=./clusters/$ENVIRONMENT \
  --read-write-key \
  --personal
