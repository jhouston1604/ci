FROM debian:bullseye-slim

LABEL maintainer "<Josh Houston <jhouston1604@gmail.com>"

ENV HELM_VERSION="v3.5.3"
ENV TERAFORM_VERSION="0.14.9"
ENV PACKER_VERSION="1.7.0"

RUN apt-get update && apt-get -y upgrade &&  apt-get -y install \
    ca-certificates \
    wget \
    curl \
    python3 \
    python3-pip \
    pwgen \
    jq \
    uuid-runtime \
    zip \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN curl -L https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator \
    && chmod +x /usr/local/bin/aws-iam-authenticator
    
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

RUN wget https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && tar -xvf helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin \
    && rm -f /helm-${HELM_VERSION}-linux-amd64.tar.gz
#add helm charts
RUN helm repo add stable https://charts.helm.sh/stable \
    && helm repo add elastic https://helm.elastic.co \
    && helm repo add loki https://grafana.github.io/loki/charts \
    && helm repo add grafana https://grafana.github.io/helm-charts \ 
    && helm repo add gitlab https://charts.gitlab.io \ 
    && helm repo add prometheus-community https://prometheus-community.github.io/helm-charts \ 
    && helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx \
    && helm repo add jetstack https://charts.jetstack.io \
    && helm repo update

#copy python and ansible requirements files
COPY requirements.txt /tmp/
COPY requirements.yml /tmp
RUN pip3 install -r /tmp/requirements.txt \
    && mkdir -p /root/.aws \
    && rm -f /tmp/requirements.txt
# install ansible galaxy collections
RUN ansible-galaxy collection install -r /tmp/requirements.yml
#download packer binary
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
    mv packer /usr/bin && \
    rm -fv /packer_${PACKER_VERSION}_linux_amd64.zip

#download and install terraform
RUN wget https://releases.hashicorp.com/terraform/${TERAFORM_VERSION}/terraform_${TERAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm -fv terraform_${TERAFORM_VERSION}_linux_amd64.zip

#linkerd2 install
RUN curl -sL https://run.linkerd.io/install | sh \
    && export PATH=$PATH:$HOME/.linkerd2/bin
#download and install kops
RUN export LATEST_KOPS_RELEASE=$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4) && curl -LO https://github.com/kubernetes/kops/releases/download/$LATEST_KOPS_RELEASE/kops-linux-amd64 \
    && chmod +x kops-linux-amd64 \
    && mv kops-linux-amd64 /usr/local/bin/kops

ENV PATH "$PATH:$HOME/.linkerd2/bin"
ENTRYPOINT ["helm"]
CMD ["help"]
