FROM ubuntu:18.04

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8     
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    bc \
    build-essential \
    cmake \
    dbus-x11 \
    gdb \
    git \
    libffi-dev \
    libssl-dev \
    locales \
    man \
    nautilus \
    python3-pip \  
    python-pip \
    python-dev \
    ruby \
    sudo \
    terminator \
    tmux \
    unzip \
    vim \
    wget \
    xpra \
    xterm \
  && sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && locale-gen

# Setup Ghidra
WORKDIR /usr/local/bin
RUN git clone https://github.com/bkerler/ghidra_installer.git . \
  && ./install-ghidra.sh \
  && ./install-scaling.sh \
  && ./install-jdk.sh

# Setup GEF
RUN echo 'export LC_CTYPE=C.UTF-8' >> /root/.bashrc \
  && echo 'export LD_LIBRARY_PATH=/usr/local/lib/' >> /root/.bashrc \
  && pip3 install \
    archinfo \
    capstone \
    keystone-engine \
    pyvex \
    ropper \
    unicorn \
    z3 \
  && wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

# Setup PWN Tools
RUN pip install pwntools

# Setup OneGadget
RUN gem install one_gadget

# angr
RUN pip install angr

ADD workspace.sh .

WORKDIR /home/hacker
RUN sed -i 's#/root#/home/hacker#' /etc/passwd

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["workspace.sh"]

