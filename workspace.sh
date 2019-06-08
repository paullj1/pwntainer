#!/bin/bash

if [ -f ~/.gdbinit ]; then
  ln -s /root/.gdbinit ./.gdbinit
fi

if [ -f ~/.gdbinit-gef.py ]; then
  ln -s /root/.gdbinit-gef.py ./.gdbinit-gef.py
fi

ghidra &
terminator 

