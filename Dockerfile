FROM ubuntu:26.04

ENV OPENCODE_VERSION="2.3.0" \
    GOLANG_VERSION="1.27" \
    NODE_MAJOR="26"

RUN groupadd --gid 4096 opencode &&\
    useradd --home /home/opencode --uid 4096 --gid 4096 --shell /bin/bash opencode &&\
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
        software-properties-common

RUN add-apt-repository -y ppa:longsleep/golang-backports &&\
    apt-get update &&\
    apt-get install -y "golang-${GOLANG_VERSION}"

RUN mkdir -p /etc/apt/keyrings &&\
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg &&\
    echo \
"Types: deb \n\
URIs: https://deb.nodesource.com/node_${NODE_MAJOR}.x/ \n\
Suites: nodistro \n\
Components: main \n\
Signed-By: /etc/apt/keyrings/nodesource.gpg" | tee /etc/apt/sources.list.d/nodesource.sources &&\
    apt-get update &&\
    apt-get install -y nodejs

RUN npm i -g "@opencode/cli@${OPENCODE_VERSION}"

USER opencode

#opencode
EXPOSE 4096

#opencode-mem
EXPOSE 4747 

#plannotator
EXPOSE 19432

COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["opencode", "serve", "--hostname", "0.0.0.0", "--port", "4096"]
