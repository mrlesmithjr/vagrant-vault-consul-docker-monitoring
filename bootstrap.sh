#!/bin/bash
if [ -f /etc/debian_version ]; then
  codename="$(lsb_release -c | awk '{print $2}')"
  if [[ $codename == "vivid" ]]; then
    test -e /usr/bin/python || (sudo apt-get update && sudo apt-get -y install python-minimal)
  fi
  if [[ $codename == "wily" ]]; then
    test -e /usr/bin/python || (sudo apt-get update && sudo apt-get -y install python-minimal)
  fi
  if [[ $codename == "xenial" ]]; then
    test -e /usr/bin/python || (sudo apt-get update && sudo apt-get -y install python-minimal)
  fi
  if [[ $codename == "yakkety" ]]; then
    test -e /usr/bin/python || (sudo apt-get update && sudo apt-get -y install python-minimal)
  fi
  if [[ $codename == "zesty" ]]; then
    test -e /usr/bin/python || (sudo apt-get update && sudo apt-get -y install python-minimal)
  fi
fi
if [ -f /etc/redhat-release ]; then
  if [ -f /etc/os-release ]; then
    codename="$(gawk -F= '/^NAME/{print $2}' /etc/os-release)"
    if [[ $codename == "Fedora" ]]; then
      sudo dnf -y install python-devel python-dnf && \
      sudo dnf -y group install "C Development Tools and Libraries"
    fi
  fi
fi
