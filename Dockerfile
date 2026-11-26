FROM ubuntu:26.04

ARG OPENCODE_UID="1000"
ARG OPENCODE_GID="1000"

ARG INSTALL_CPP="1"
ARG INSTALL_GOLANG="1"
ARG INSTALL_JAVA="1"
ARG INSTALL_RUST="1"
ARG INSTALL_PHP="1"
ARG INSTALL_IMAGEMAGICK="1"
ARG INSTALL_LIBREOFFICE="0"
ARG INSTALL_POSTGRES_DBA_MCP="1"
ARG INSTALL_DBHUB="1"
ARG INSTALL_DDGS="1"
ARG INSTALL_GRAPHIFY="1"

ARG OPENCODE_VERSION="2.4.1"
ARG GOLANG_VERSION="1.27"
ARG NODE_MAJOR="26"
ARG POSTGRES_DBA_MCP_VERSION="0.4.2"
ARG DBHUB_VERSION="2.1.0"

###############################################################################
# general dependencies
###############################################################################

RUN apt-get update &&\
    apt-get install -y \
        git \
        mercurial \
        python3 \
        python3-pip \
        pipx \
        wget \
        curl \
        ca-certificates \
        gnupg \
        mc \
        nano \
        micro \
        jq \
        yq \
        pkg-config \
        software-properties-common \
        locales \
        sudo \
        net-tools \
        iputils-ping &&\
    \
    if [ ${INSTALL_CPP} -ne 0 ]; then \
        apt-get install -y build-essential cmake; \
    fi &&\
    \
    if [ ${INSTALL_RUST} -ne 0 ]; then \
        apt-get install -y rustc cargo; \
    fi &&\
    \
    if [ ${INSTALL_JAVA} -ne 0 ]; then \
        apt-get install -y openjdk-25-jdk maven; \
    fi &&\
    \
    if [ ${INSTALL_PHP} -ne 0 ]; then \
        apt-get install -y \
            php-cli \
            php-intl \
            php-json \
            php-mbstring \
            php-pq \
            php-redis \
            php-yaml \
            php-zip \
            composer; \
    fi &&\
    \
    if [ ${INSTALL_IMAGEMAGICK} -ne 0 ]; then \
        apt-get install -y imagemagick; \
    fi &&\
    \
    if [ ${INSTALL_LIBREOFFICE} -ne 0 ]; then \
        apt-get install -y libreoffice; \
    fi &&\
    \
    rm -rf /var/lib/apt/lists/* &&\
    \
    locale-gen en_US.UTF-8

ENV LANG="en_US.UTF-8"

###############################################################################
# user & group    
###############################################################################
    
RUN userdel -r ubuntu &&\
    \
    groupadd --gid ${OPENCODE_GID} opencode &&\
    useradd --home /home/opencode --uid ${OPENCODE_UID} --gid ${OPENCODE_GID} --shell /bin/bash opencode &&\
    \
    cd /home &&\
    mkdir opencode &&\
    chown opencode:opencode opencode &&\
    \
    echo "opencode ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/opencode &&\
    chmod 0440 /etc/sudoers.d/opencode

###############################################################################
# nodejs    
###############################################################################

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

###############################################################################
# golang    
###############################################################################

RUN if [ ${INSTALL_GOLANG} -ne 0 ]; then \
        add-apt-repository -y ppa:longsleep/golang-backports &&\
        apt-get update &&\
        apt-get install -y "golang-${GOLANG_VERSION}" &&\
        rm -rf /var/lib/apt/lists/*; \
    fi

###############################################################################
# postgres-dba-mcp
###############################################################################

RUN if [ ${INSTALL_POSTGRES_DBA_MCP} -ne 0 ]; then \
        cd /tmp &&\
        mkdir postgres-dba-mcp &&\
        cd postgres-dba-mcp &&\
        wget -O postgres-dba-mcp.tar.gz "https://github.com/a-lafon/postgres-dba-mcp/releases/download/v${POSTGRES_DBA_MCP_VERSION}/postgres-dba-mcp_${POSTGRES_DBA_MCP_VERSION}_linux_amd64.tar.gz" &&\
        tar -xvf postgres-dba-mcp.tar.gz &&\
        mv postgres-dba-mcp /usr/local/bin &&\
        cd / &&\
        rm -rf /tmp/postgres-dba-mcp; \
    fi

###############################################################################
# ddgs[mcp]
###############################################################################

RUN if [ ${INSTALL_DDGS} -ne 0 ]; then \
        pipx install --global ddgs[mcp]; \
    fi

###############################################################################
# dbhub
###############################################################################

RUN if [ ${INSTALL_DBHUB} -ne 0 ]; then \
        npm install -g "@bytebase/dbhub@${DBHUB_VERSION}"; \
    fi

###############################################################################
# graphify
###############################################################################

RUN if [ ${INSTALL_GRAPHIFY} -ne 0 ]; then \
    pipx install --global \
        "graphifyy" \
        "graphifyy[pdf]" \
        "graphifyy[office]" \
        "graphifyy[svg]" \
        "graphifyy[mcp]" \
        "graphifyy[sql]" \
        "graphifyy[postgres]"; \
    fi

###############################################################################
# opencode
###############################################################################

RUN npm install -g "@opencode/cli@${OPENCODE_VERSION}"

###############################################################################
# run configuration
###############################################################################

USER opencode

CMD ["/bin/bash", "-c", "opencode serve --hostname 0.0.0.0 --port 4096"]
