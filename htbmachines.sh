#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Global variables
main_url="https://htbmachines.github.io/bundle.js"


# Functions
function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Usage:${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Search machine by name${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Search machine by difficulty${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Search machine by ip address${endColour}"
  echo -e "\t${purpleColour}o)${endColour}${grayColour} Search machine by OS${endColour}"
  echo -e "\t${purpleColour}s)${endColour}${grayColour} Search machine by skills${endColour}"
  echo -e "\t${purpleColour}y)${endColour}${grayColour} Link to machine resolution video${endColour}"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Download or update necessary files${endColour}" 
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Show help panel${endColour}\n"
}

function updateFiles(){
tput civis
  if [ ! -f bundle.js ]; then
    echo -e "\n${yellowColour}[+]${endColour}${greenColour} Downloading...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${greenColour} Update completed${endColour}"
    tput cnorm
  else
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${greenColour} Checking updates...${endColour}"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
  if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${greenColour} No updates available${endColour}"
      rm bundle_temp.js
  else
      echo -e "\n${yellowColour}[+]${endColour}${greenColour} Update available${endColour}"
      sleep 1
      rm bundle.js && mv bundle_temp.js bundle.js
  echo -e "\n${yellowColour}[+]${endColour}${greenColour} Update completed!${endColour}"
  fi  
    tput cnorm
  fi
}

function searchMachine(){
  machineName="$1"
  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
  if [ "$machineName_checker" ]; then
    echo -e "\n${yellowColour}[+]${greenColour} Listing machine properties from${endColour}${redColour} $machineName${endColour}${greyColour}:${endColour}\n"
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
  else
    echo -e "\n${redColour}[!] The provided machine does not exist${endColour}\n"
  fi
}

function searchIP(){
  ipAddress="$1"
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  if [ "$machineName" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${greenColour} The corresponding machine for the IP${endColour}${blueColour} $ipAddress${endColour}${greyColour} is${endColour}${redColour} $machineName${endColour}\n":
  else
      echo -e "\n${redColour}[!] The provided ip address does not exist${endColour}\n"
  fi
  }

function getYoutubeLink (){
  machineName="$1"
  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"
  if [ $youtubeLink ]; then
    echo -e "\n${yellowColour}[+]${endColour}${greenColour} The tutorial for this machine is at the following link:${endColour}${blueColour} $youtubeLink${endColour}\n"
  else
      echo -e "\n${redColour}[!] The provided machine does not exist${endColour}\n"
    fi
}

function getMachinesDifficulty(){
  difficulty="$1"
  results_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"
  if [ "$results_check" ]; then
    echo -e "\n${yellowColour}[!]${endColour}${greenColour} Deploying machines with the difficulty level${endColour}${blueColour} $difficulty${endColour}:\n"
    cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column
  else
    echo -e "\n${redColour}[!] The provided difficulty does not exist${endColour}\n"
  fi
}
 
function getOSMachines(){
  os="$1"
  os_results="$(cat bundle.js | grep "os: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"
  if [ "$os_results" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${greenColour} Deploying machines with the operative system${endColour}${blueColour} $os${endColour}:\n"
    cat bundle.js | grep "os: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column
  else
    echo -e "\n${redColour}[!] The provided operative system does not exist${endColour}\n"
  fi
}

function getOSDifficultyMachines(){
  difficulty="$1"
  os="$2"
  check_results="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -i -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"
  if [ "$check_results" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${greenColour} Deploying machines of difficulty${endColour}${blueColour} $difficulty${endColour}${greenColour} on the os${endColour}${blueColour} $os${endColour}:\n"
    cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column
  else
    echo -e "\n${redColour}[+]  Incorrect input parameters${endColour}\n"
  fi
}

function getSkills(){
  skills="$1"
  check_skills="$(cat bundle.js | grep "skills: " -B 6 | grep "$skills" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' |column)"
  if [ "$check_skills" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${greenColour} Deploying machines were you can practice the skill${endColour}${blueColour} $skills${endColour}:\n"
    cat bundle.js | grep "skills: " -B 6 | grep "$skills" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' |column
  else
    echo -e "\n${redColour}[+]  Incorrect input parameters${endColour}\n"
  fi
}

# Indicators
declare -i parameter_counter=0

# Ctrl+C
trap ctrl_c INT

# Snitchs
declare -i snitch_difficulty=0
declare -i snitch_os=0

while getopts "m:uhd:y:i:o:s:" arg; do
    case $arg in
      m) machineName="$OPTARG";  let parameter_counter+=1;;
      u) let parameter_counter+=2;;
      i) ipAddress="$OPTARG";let parameter_counter+=3;;
      y) machineName="$OPTARG";let parameter_counter+=4;;
      d) difficulty="$OPTARG"; snitch_difficulty=1; let parameter_counter+=5;;
      o) os="$OPTARG"; snitch_os=1; let parameter_counter+=6;;
      s) skills="$OPTARG"; let parameter_counter+=7;; 
      h) ;;
    esac
done


if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getMachinesDifficulty $difficulty 
elif [ $parameter_counter -eq 6 ]; then
  getOSMachines $os
elif [ $parameter_counter -eq 7 ]; then
  getSkills "$skills"
elif [ $snitch_difficulty -eq 1 ] && [ $snitch_os -eq 1 ]; then
  getOSDifficultyMachines $difficulty $os
else
  helpPanel
fi
