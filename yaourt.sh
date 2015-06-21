#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

install_aur(){
  num=$RANDOM
  echo
  confirmation "Do you want to make $1?"
  mkdir ~/"$1"-tmp-"$num"
  cd ~/"$1"-tmp-"$num"
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
  makepkg
  pak=$(ls | grep .xz)
  sudo pacman -U "$pak"
  echo "Finish"
  cd
  rm -r ~/"$1"-tmp-"$num"
  check_aur "$1"
}

confirmation() {
  echo -n "$1 [Y/n]"
  read input
  if [[ "$input" != "Y" && "$input" != "y" && "$input" != '' ]]; then
    echo "exiting"
    # cd
    # garbage=$(ls | grep tmp-)
    # if [[ -e $garbage ]]; then
    #   echo "Control-C to exit the program without deleting the tmp directory"
    #   confirmation "Remove '$garbage'?"
    #   rm -r "$garbage"
    #   echo "The directory is removed"
    # fi
    exit 1
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
    missing+="$i"
  fi
done

if [[ -e missing ]]; then
  echo "Installing the dependencies from the official repository"
  sudo pacman -S ${missing[@]}
fi

check_aur "package-query"

check_aur "yaourt"
