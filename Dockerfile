FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    bc \
    build-essential \
    dbus-x11 \
    gdb \
    git \
    man \
    nautilus \
    sudo \
    terminator \
    tmux \
    unzip \
    vim \
    wget \
    xpra \
    xterm

# Setup Ghidra
WORKDIR /usr/local/bin
RUN git clone https://github.com/bkerler/ghidra_installer.git . \
  && ./install-ghidra.sh \
  && ./install-scaling.sh \
  && ./install-jdk.sh

# Setup GEF
WORKDIR /tmp
RUN wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

# Setup PWN Tools
RUN apt-get install -y \
    python2.7 \
    python-pip \
    python-dev \
    libssl-dev \
    libffi-dev \
  && pip install pwntools

# Setup OneGadget
RUN apt-get install -y \
    ruby \
  && gem install one_gadget

# angr
RUN pip install angr

WORKDIR /usr/local/bin
ADD workspace.sh .

WORKDIR /home/hacker
RUN sed -i 's#/root#/home/hacker#' /etc/passwd

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["workspace.sh"]

