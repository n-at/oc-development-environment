FROM ubuntu:26.04

ENV OPENCODE_VERSION="2.3.0" \
    GOLANG_VERSION="1.27" \
    NODE_MAJOR="26" \
    OPENCODE_UID="1000" \
    OPENCODE_GID="1000"

RUN userdel -r ubuntu &&\
    groupadd --gid ${OPENCODE_GID} opencode &&\
    useradd --home /home/opencode --uid ${OPENCODE_UID} --gid ${OPENCODE_GID} --shell /bin/bash opencode &&\
    cd /home &&\
    mkdir opencode &&\
    chown opencode:opencode opencode

RUN apt-get update &&\
    apt-get install -y \
        git \
        mercurial \
        build-essential \
        python3 \
        python3-pip \
        openjdk-25-jdk \
        maven \
        rustc \
        cargo \
        php-cli \
        wget \
        curl \
        ca-certificates \
        gnupg \
        mc \
        nano \
        pkg-config \
        software-properties-common \
        locales \
        sudo &&\
    rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:longsleep/golang-backports &&\
    apt-get update &&\
    apt-get install -y "golang-${GOLANG_VERSION}" &&\
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings &&\
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg &&\
    echo \
"Types: deb \n\
URIs: https://deb.nodesource.com/node_${NODE_MAJOR}.x/ \n\
Suites: nodistro \n\
Components: main \n\
Signed-By: /etc/apt/keyrings/nodesource.gpg" | tee /etc/apt/sources.list.d/nodesource.sources &&\
    apt-get update &&\
    apt-get install -y nodejs &&\
    rm -rf /var/lib/apt/lists/*

RUN npm i -g "@opencode/cli@${OPENCODE_VERSION}"

RUN locale-gen en_US.UTF-8

ENV LANG="en_US.UTF-8"

RUN echo "opencode ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/opencode &&\
    chmod 0440 /etc/sudoers.d/opencode

USER opencode

COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

CMD ["/bin/bash", "/usr/local/bin/entrypoint.sh"]
