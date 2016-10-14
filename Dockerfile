FROM ubuntu:16.04

ENV PBF_RESOURCE none

RUN \
  DEBIAN_FRONTEND=noninteractive apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential curl git cmake pkg-config \
	libbz2-dev libstxxl-dev libstxxl1v5 libxml2-dev \
	libzip-dev libboost-all-dev lua5.1 liblua5.1-0-dev libluabind-dev libtbb-dev curl

RUN \
  git clone git://github.com/Project-OSRM/osrm-backend.git /src && \
  cd /src && git checkout v4.9.1 && cd ~ && \
  mkdir -p /build && \
  cd /build && \
  cmake /src && make -j4 && \
  mv /src/profiles/car.lua profile.lua && \
  mv /src/profiles/lib/ lib && \
  echo "disk=/tmp/stxxl,25000,syscall" > /build/.stxxl && \
  rm -rf /src

WORKDIR /build
ADD run.sh run.sh
EXPOSE 5000
CMD bash run.sh
