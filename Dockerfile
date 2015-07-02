FROM ubuntu:14.04.1

MAINTAINER Gerard Choinka <gerard.choinka@ambrosys.de>

#####
# Build
#  docker run --name='apt-cacher-ng' -d -p 3142:3142 sameersbn/apt-cacher-ng:latest
#  docker build -t cgtab-prof-of-concept .
#####
# Run
#  docker run --rm -it --entrypoint bash --volume=$PWD:/vol/cgtab cgtab-prof-of-concept
#####

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
RUN locale-gen --no-purge en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

#test if an apt-cacher-ng runs, if yes then use it
ENV APT_PROXY_CONFIG /etc/apt/apt.conf.d/01proxy
RUN nc -z 172.17.42.1 3142 && echo 'Acquire::http { Proxy "http://172.17.42.1:3142"; };' >> "${APT_PROXY_CONFIG}"

RUN apt-get -y update && \
    apt-get -y install git build-essential ssh-client wget libssl-dev man time && \
    apt-get -y build-dep git

 
RUN test -f "${APT_PROXY_CONFIG}" && rm "${APT_PROXY_CONFIG}"

RUN wget -qO- http://www.cmake.org/files/v3.3/cmake-3.3.0-rc2.tar.gz | tar xvz --directory /opt/
RUN cd /opt/cmake-*/ && ./bootstrap && make --jobs 4 && make install
 
RUN git clone https://github.com/git/git /opt/git && \
    make install --jobs 4 -C /opt/git
    
ENV PATH /root/bin/:${PATH}

    
ADD . /src/cgtab 

RUN mkdir /src/cgtab/build && cd /src/cgtab/build && cmake ..

ENTRYPOINT cd /src/cgtab/UnitTest/ && ./SpeedTestDepth.sh
