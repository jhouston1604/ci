# CI/CD container

This is the main CI container for use with github actions

## Installed software in container

### Via Apt   
```
ca-certificates
wget
curl
python3
python3-pip
pwgen
jq
uuid-runtime
zip
git
```
### Via vendor curl direct download  
```
kubectl
helm
kops
packer
terraform
linkerd2
```

### Software via pip(requirements.txt)  
```
pyhcl
ansible
awscli
python-lambda-local
```

### Prerequisites

If your building manually you need to install docker
