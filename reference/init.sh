#!/usr/bin/env bash

source ./bash-ini-parser.sh

# Functions

# section takes the section name as an argument and the text of the file from STDIN
# section then returns the section of the file under the square-bracketed header
function section() {
  declare section="${1}"
  declare found=false
  while read line
  do
    [[ ${found} == false && "${line}"    != "[${section}]" ]] && continue
    [[ ${found} == true  && "${line:0:1}" = '[' ]]            && break
    declare found=true
    echo "${line}"
  done
  [[ ${found} == false ]] && { echo "section: ${section} : not found in input" 1>&2 ; return 1 }
  [[ ${found} == true  ]] && return 0
}

function confedit() {
    declare file="${1}"
    declare sect="${2}"
    declare key="${3}"
    declare value="${4}"

    [[ -f ${file} && -w ${file} ]] || { echo "confedit: ${file} : missing or readonly" 1>&2 ; return 1 }
    declare contents=$( section ${sect} < ${file} || return 1 )
    declare 
}

# Set Vars & check requirements

declare home_dir="~/repos/xx_test_playground/testhome"

declare reqbin=('git')
for bin in ${reqbin}; do
  type ${bin} 2&>1 > /dev/null || { echo "Required binary ${bin} not present"; return 1 }
done

# Place fresh .gitconf from template
cp ./tpl.gitconf ${home_dir}/.gitconf

# Make user choose editor
declare message=$(cat <<EOF
Please choose your text editor:
1. VI
2. VIM
3. Visual Studio Code
4. Atom
5. SublimeText
6. TextMate
7. Notepad++ 32-bit
8. Notepad++ 64-bit
EOF
)
while [ ${i} != 1 ]; do
  echo ${message} && echo "Type the number of your choice and press Enter:" && read c
  case c in
    1)
      type vi 2&>1 > /dev/null || { echo "vi not on PATH"; continue }
      git config --global core.editor vi
      confedit 
    ;;
    2)
      type vim 2&>1 > /dev/null || { echo "vim not on PATH"; continue }
      git config --global core.editor vim
    ;;
    3)
      type code 2&>1 > /dev/null || { echo "VSCode 'code' binary not on PATH"; continue }
      git config --global core.editor "code --wait"
    ;;
    # git config --global core.editor "code --wait"
    4)
      type atom 2&>1 > /dev/null || { echo "Atom 'atom' binary not on PATH"; continue }
      git config --global core.editor "atom --wait"
    ;;
    # git config --global core.editor "atom --wait"
    5)
      type subl 2&>1 > /dev/null || { echo "SublimeText 'subl' binary not on PATH"; continue }
      git config --global core.editor "subl -n -w"
    ;;
    # git config --global core.editor "subl -n -w"
    6)
      type mate 2&>1 > /dev/null || { echo "TextMate 'mate' binary not on PATH"; continue }
      git config --global core.editor "mate -w"
    ;;
    # git config --global core.editor "mate -w"
    7)
      declare npp="C:/Program Files (x86)/Notepad++/notepad++.exe"
      type "${npp}" 2&>1 > /dev/null || { echo "Notepad++ 32-bit binary not in default location"; continue }
      git config --global core.editor "'${npp}' -multiInst -notabbar -nosession -noPlugin"
    ;;
    8)
      declare npp="C:/Program Files/Notepad++/notepad++.exe"
      type "${npp}" 2&>1 > /dev/null || { echo "Notepad++ 64-bit binary not in default location"; continue }
      git config --global core.editor "'${npp}' -multiInst -notabbar -nosession -noPlugin"
    ;;
    # git config --global core.editor "'C:/Program Files (x86)/Notepad++/notepad++.exe' -multiInst -notabbar -nosession -noPlugin"
    *)
      echo "Number not found - retry"
      continue
    ;;
  esac
done

# Grab any existing vars from global config file
# Place those vars inside .gitconf

# Open editor and have them confirm contents of .gitconf
set -- $(git config core.editor) ~/.gitconf
"$@"
