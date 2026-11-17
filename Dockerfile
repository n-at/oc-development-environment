FROM ubuntu:26.04

ENV OPENCODE_VERSION="2.3.0" \
    GOLANG_VERSION="1.27" \
    NODE_MAJOR="26" \
    POSTGRES_DBA_MCP_VERSION="0.3.3" \
    OPENCODE_UID="1000" \
    OPENCODE_GID="1000"

###############################################################################
# general dependencies
###############################################################################

RUN apt-get update &&\
    apt-get install -y \
        git \
        mercurial \
        build-essential \
        cmake \
        python3 \
        python3-pip \
        openjdk-25-jdk \
        maven \
        rustc \
        cargo \
        php-cli \
        php-intl \
        php-json \
        php-mbstring \
        php-pq \
        php-redis \
        php-yaml \
        php-zip \
        composer \
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
        iputils-ping \
        imagemagick &&\
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
# golang    
###############################################################################

RUN add-apt-repository -y ppa:longsleep/golang-backports &&\
    apt-get update &&\
    apt-get install -y "golang-${GOLANG_VERSION}" &&\
    rm -rf /var/lib/apt/lists/*

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
# postgres-dba-mcp
###############################################################################

RUN cd /tmp &&\
    mkdir postgres-dba-mcp &&\
    cd postgres-dba-mcp &&\
    wget -O postgres-dba-mcp.tar.gz "https://github.com/a-lafon/postgres-dba-mcp/releases/download/v${POSTGRES_DBA_MCP_VERSION}/postgres-dba-mcp_${POSTGRES_DBA_MCP_VERSION}_linux_amd64.tar.gz" &&\
    tar -xvf postgres-dba-mcp.tar.gz &&\
    mv postgres-dba-mcp /usr/local/bin &&\
    cd / &&\
    rm -rf /tmp/postgres-dba-mcp

###############################################################################
# opencode
###############################################################################

RUN npm i -g "@opencode/cli@${OPENCODE_VERSION}"

###############################################################################
# run configuration
###############################################################################

USER opencode

COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

CMD ["/bin/bash", "/usr/local/bin/entrypoint.sh"]
