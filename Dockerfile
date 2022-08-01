FROM python:3.9-slim-bullseye

COPY ./ /build
WORKDIR /build

RUN apt-get update &&\
    apt-get install -y apt-transport-https ca-certificates curl git gpg vim zsh &&\
    # Hashicorp Tools
    curl -sL https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg &&\
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com bullseye main" | tee /etc/apt/sources.list.d/hashicorp.list &&\
    apt-get update && apt-get install -y packer terraform &&\
    # Kubectl
    curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg &&\
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list &&\
    apt-get update && apt-get install -y kubectl=1.24.3-00 &&\
    # Helm
    curl -sL https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null &&\
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list &&\
    apt-get update && apt-get install helm=3.9.1-1 &&\
    # Ansible Setup
    python3 -m venv /opt/virtualenvs/ansible &&\
    .  /opt/virtualenvs/ansible/bin/activate &&\
    pip3 install -r venv.txt &&\
    echo "source  /opt/virtualenvs/ansible/bin/activate" >> /root/.bashrc &&\
    # Starship prompt
    curl -sSO https://starship.rs/install.sh &&\
    sh ./install.sh -y &&\
    mv /build/.zshrc /root/.zshrc &&\
    # Cleanup
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* &&\
    pip3 cache purge &&\
    rm -rf /build

WORKDIR /
CMD ["/usr/bin/zsh"]