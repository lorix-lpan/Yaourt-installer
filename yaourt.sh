#!/bin/bash

install_aur(){
  num=$RANDOM
  echo
  confirmation "Download the $1 tarball from aur?"
  mkdir ~/"$1"-tmp-lorix-"$num"
  cd ~/"$1"-tmp-lorix-"$num"
  wget https://aur.archlinux.org/packages/"${1:0:2}"/"$1"/"$1".tar.gz 
  if [[ -e "$1".tar.gz ]]; then
    tar -xvf "$1".tar.gz  
  else
    echo "Error: cannot find the '$1'.tar.gz. Please check your
    internet connection or contact the author"
    exit 1
  fi
  cd "$1"
  echo
  echo "$1 has been downloaded"
  confirmation "Are you sure to make the package"
  makepkg
  pak=$(ls | grep .xz)
  sudo pacman -U "$pak"
  echo "Finish"
  cd
  rm -r ~/"$1"-tmp-lorix-"$num"
}

confirmation() {
  echo -n "'$1' [Y/n]"
  read input
  if [[ "$input" != "Y" && "$input" != "y" && "$input" != '' ]]; then
    echo "exiting"
    cd
    garbage=$(ls | grep tmp-lorix)
    if [[ -e $garbage ]]; then
      echo "Control-C to exit the program without deleting the tmp directory"
      confirmation "Remove '$garbage'?"
      rm -r "$garbage"
      echo "The directory is removed"
    fi
    exit 1
  fi
}

check_aur() {
  if (pacman -Q "$1"); then
    echo "'$1' is installed"
    echo
  else
    install_aur "$1"
  fi
}

echo "* This is an installer for yaourt with dependency resolution"
echo "* Before you proceed, please check the README file"
echo 

confirmation "Proceed with yaourt's installation?"

echo "Resolving dependencies"
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
check_aur "package-query"

echo "Checking if yaourt is intalled"
check_aur "yaourt"
