export GITHUB_TOKEN=***

microk8s config > ~/.kube/config

GITHUB_USER=sambaum
REPOSITORY=k8s
BRANCH=master
ENVIRONMENT=isp

kubectl create namespace flux-system
cat ~/.sops/age.agekey |
kubectl create secret generic sops-age \
--namespace=flux-system \
--from-file=age.agekey=/dev/stdin

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=$REPOSITORY \
  --branch=$BRANCH \
  --path=./clusters/$ENVIRONMENT \
  --personal
