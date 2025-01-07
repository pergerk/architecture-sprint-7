#!/bin/bash


./create_roles.sh
./bind_roles.sh


./create_users.sh administrator admin-cluster,admin-secrets
./create_users.sh user1 user-cluster,developers
./create_users.sh developer1 user-cluster,developers
