#!/bin/bash

# Exit on any error
set -e

export PROJECT=rails-kube-demo
export NAME=app
export TAG=$1
export IMAGE="us.gcr.io/$PROJECT/$NAME:$TAG"

echo "deploying $IMAGE"

# cleanup any stale deploy-tasks jobs
kubectl delete job deploy-tasks 2&> /dev/null || true

# create the deploy-tasks job by creating a pod, running the migrate script
cat kube/deploy-tasks-job.yml.tmpl | envsubst | kubectl create -f -

while [ true ]; do
  phase=`kubectl get pods -a --selector="name=deploy-tasks" -o 'jsonpath={.items[0].status.phase}' || 'false'`

  if [[ "$phase" != 'Pending' ]]; then
    break
  fi
done

echo '=============== deploy_tasks output'
kubectl attach $(kubectl get pods -a --selector="name=deploy-tasks" -o 'jsonpath={.items[0].metadata.name}')
echo '==============='

while [ true ]; do
  succeeded=`kubectl get jobs deploy-tasks -o 'jsonpath={.status.succeeded}'`
  failed=`kubectl get jobs deploy-tasks -o 'jsonpath={.status.failed}'`

  if [[ "$succeeded" == "1" ]]; then
    break
  elif [[ "$failed" -gt "0" ]]; then
    kubectl describe job deploy-tasks
    kubectl delete job deploy-tasks
    echo '!!! Deploy canceled. deploy-tasks failed.'
    exit 1
  fi
done

# deploy web containers
kubectl set image deployments/web "web=$IMAGE"

kubectl describe deployment web

kubectl delete job deploy-tasks || true

kubectl rollout status deployment/web
