#! /bin/bash

aws eks update-kubeconfig --name gitlab
kubectl apply -f gitlab-admin-service-account.yaml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab-admin | awk '{print $1}')
token_name=$(kubectl get secrets | awk 'NR==2{print $1}')
kubectl get secret ${token_name} -o jsonpath="{['data']['ca\.crt']}" | base64 --decode