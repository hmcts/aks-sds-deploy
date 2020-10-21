FROM ubuntu:16.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive

RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        git \
        iputils-ping \
        libcurl3 \
        libicu55 \
        libunwind8 \
        openssh-client \
        netcat

WORKDIR /azp

# Install custom dependencies   
ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 18.06.3-ce
ENV DOCKER_COMPOSE_VERSION 1.24.1
ENV TERRAFORM_VERSION 0.11.0
ENV HELM_VERSION v2.15.2
COPY ./addons.sh .
RUN ./addons.sh

COPY ./start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]