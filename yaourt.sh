#!/bin/bash

install_package_query(){
  num=$RANDOM
  mkdir ~/yaourt-tmp-"$num"
  cd ~/yaourt-tmp-"$num"
  wget https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz
  if [[ -e package-query.tar.gz ]]; then
    tar -xvf package-query.tar.gz  
  else
    echo "Error: cannot find the package-query.tar.gz. Please check your
    internet connection"
    exit 1
  fi
  cd package-query
  makepkg
  pak=$(ls | grep .xz)
  sudo pacman -U "$pak"
}


echo "* This is an installer for yaourt with dependency resolution"
echo "* Before you proceed, please check the README file"
echo 
echo -n "Are you sure to install yaourt (Y/n)"

read input

if [[ "$input" != "Y" && "$input" != "y" && "$input" != '' ]]; then
  echo "exiting"
  exit 1
fi

echo "Checking dependencies"
depend=("gettext" "diffutils" "wget" "yajl")
missing=()

# Checking the dependencies
for i in ${depend[@]}; do
  if (pacman -Q $i); then
    echo "$i is installed"
    echo
  else
    echo "$i will be installed in a moment"
    echo
    missing+="$i"
  fi
done

if [[ -e missing ]]; then
  echo "Installing the dependencies from the official repository"
fi

for i in ${missing[@]}; do
  sudo pacman -S "$i"
done

echo "Checking if package query is installed"
if (pacman -Q package-query); then
  echo "package-query is installed"
  echo
else
  install_package_query
fi

