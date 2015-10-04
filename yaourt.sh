#!/bin/bash

usage(){
    echo -e "$0: -sh\n-s: skip confirmations\n-h: show this text"
    exit
}

bold=$(tput bold)
normal=$(tput sgr0)
install_aur(){
  num=$RANDOM
  echo
  confirmation "Do you want to make $1?"
  mkdir ~/"$1"-tmp-"$num"
  cd ~/"$1"-tmp-"$num"
  # old download link
  # wget https://aur.archlinux.org/packages/"${1:0:2}"/"$1"/"$1".tar.gz 
  wget https://aur.archlinux.org/cgit/aur.git/snapshot/"$1".tar.gz
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
  makepkg
  pak=$(ls | grep .xz)
  if [[ "$SKIP_CONFIRM" != "y" ]]; then
      sudo pacman -U "$pak"
    else
      sudo pacman --noconfirm -U "$pak"
  fi
  echo "Finish"
  cd
  rm -r ~/"$1"-tmp-"$num"
  check_aur "$1"
}

confirmation() {
  if [[ "$SKIP_CONFIRM" != "y" ]]; then
    echo -n "$1 [Y/n]"
    read input
    if [[ "$input" != "Y" && "$input" != "y" && "$input" != '' ]]; then
      echo "exiting"
      exit 1
    fi
  fi
}

check_aur() {
  if pacman -Q "$1" > /dev/null 2>&1; then
    echo "$1 is installed"
    echo
  else
    echo "$1 is not installed"
    install_aur "$1"
  fi
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi
 
if [[ "$1" == "-s" ]]; then
    SKIP_CONFIRM=y
fi

echo
confirmation "Proceed with yaourt's installation?"

echo -e "\n${bold}Resolving dependencies${normal}\n"
depend=("gettext" "diffutils" "wget" "yajl")
missing=()

for i in ${depend[@]}; do
  if pacman -Q $i > /dev/null 2>&1; then
    echo "$i is installed"
    echo
  else
    echo "$i will be installed in a moment"
    echo
    missing+=("$i")
  fi
done

if [[ -n "$missing" ]]; then
  echo "Installing the dependencies from the official repository"
  if [[ "$SKIP_CONFIRM" != "y" ]]; then
    sudo pacman -S ${missing[@]}
  else
    sudo pacman --noconfirm -S ${missing[@]}
  fi
fi

check_aur "package-query"

check_aur "yaourt"
