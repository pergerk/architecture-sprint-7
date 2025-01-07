#!/bin/bash

kubectl apply -f pods.yml
kubectl apply -f non-admin-api-allow.yml
