#!/bin/sh


kubectl -n kube-system create token admin-user > token.txt
echo 'Open dashboard in  and paste token from token.txt https://localhost:10443'
token=`cat token.txt`
echo $token
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard-kong-proxy 10443:443 --address 0.0.0.0 &
