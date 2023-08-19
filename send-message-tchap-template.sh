#!/bin/bash

ROOM="!xxxxxxxxxxxx:xxxxxxx.tchap.gouv.fr"
NOM_PRENOM="nom.prenom"
PASSWORD=""
DEVICE="ubuntu-shell-unix"
FILE_NAME="./token.txt"
TOKEN=""

ORIGINE_MESSAGE="<em>#Origine</em>: ${DEVICE}<br><br>"
BALISE_ITALIC_D=""
BALISE_ITALIC_F=""
BALISE_GRAS_D=""
BALISE_GRAS_F=""

### code html pour emoji
EMOJI_RED_CIRCLE="&#128308;"
EMOJI_GREEN_CIRCLE="&#128994;"
EMOJI_WARN="&#9888;&#65039;"
EMOJI_INFO="&#8505;&#65039;"

### valeur emoji
VAL_EMOJI=""

### règle d'utiisation
function usage() { 
  echo "Utilisation: $0 -m {message} [ -i ] [ -b ] -e {red|green|warn|info}" 1>&2 
  echo " -i : caractères en italique" 1>&2
  echo " -b : caractères en gras" 1>&2
  echo " -e : emoji" 1>&2
}
### fonction de demande de token session 
function getTokenSession() {

  local NOM_PRENOM=$1
  local PASSWORD=$2
  local DEVICE=$3

  TOKEN=`curl -sk -H "Content-Type: application/json" -X POST "https://matrix.agent.interieur.tchap.gouv.fr/_matrix/client/r0/login" -H "Content-Type: application/json" -d \
"{\"type\": \"m.login.password\", \"user\": \"@${NOM_PRENOM}-interieur.gouv.fr:agent.interieur.tchap.gouv.fr\", \"password\": \"${PASSWORD}\", \"initial_device_display_name\": \"${DEVICE}\" }" | jq .access_token | sed 's,",,g'`

func_result=${TOKEN}
}

### fonction d'envoi de message
function sendMessage() {

local MESSAGE_PLAIN=$1
local MESSAGE_FORMATTED=$2
local ROOM=$3
local TOKEN=$4

curl -sk -X POST -H "Content-Type: application/json" -d "{\"msgtype\":\"m.text\", \"body\":\"${MESSAGE_PLAIN}\",\"format\":\"org.matrix.custom.html\",\"formatted_body\":\"${MESSAGE_FORMATTED}\"}" "https://matrix.agent.interieur.tchap.gouv.fr/_matrix/client/r0/rooms/${ROOM}/send/m.room.message?access_token=${TOKEN}"

}

### lecture des paramètres

while getopts "ibe:m:" flag
do
    case ${flag} in
        m)MESSAGE_PLAIN="${OPTARG}";;
        i)
	  BALISE_ITALIC_D="<em>"
	  BALISE_ITALIC_F="</em>"
	  ;;
        b)
	  BALISE_GRAS_D="<strong>"
	  BALISE_GRAS_F="</strong>"
          ;;
	e)EMOJI="${OPTARG}"
	  case ${EMOJI} in 
	     "green") VAL_EMOJI=${EMOJI_GREEN_CIRCLE};;
	     "red") VAL_EMOJI=${EMOJI_RED_CIRCLE}};;
	     "info") VAL_EMOJI=${EMOJI_INFO};;
	     "warn") VAL_EMOJI=${EMOJI_WARN};;
	     *) VAL_EMOJI=""
		;;
	  esac
	  ;;
	?)usage
	  exit 1
	  ;;
    esac
done

if [ -z "${MESSAGE_PLAIN}" ]
then
usage
exit 1
fi

MESSAGE_FORMATTED="${ORIGINE_MESSAGE}${VAL_EMOJI}${BALISE_ITALIC_D}${BALISE_GRAS_D}${MESSAGE_PLAIN}${BALISE_GRAS_F}${BALISE_ITALIC_F}"


### main

if [ -f "$FILE_NAME" ]
then

 TOKEN=`cat $FILE_NAME`
 if [ -z "${TOKEN}" ]
 then
   echo "generer le token de session ...."
   getTokenSession ${NOM_PRENOM} ${PASSWORD} ${DEVICE}
   TOKEN=`echo $func_result`
 fi
else
  echo "generer le token de session ...."
  getTokenSession $NOM_PRENOM $PASSWORD $DEVICE
  TOKEN=`echo $func_result`
fi

echo ${TOKEN} > token.txt

if [ ! -z "${TOKEN}" ] 
then
echo "envoi de message"
sendMessage "${MESSAGE_PLAIN}" "${MESSAGE_FORMATTED}" ${ROOM} ${TOKEN}
fi

exit 0
#curl -sk -X POST "https://matrix.agent.interieur.tchap.gouv.fr/_matrix/client/r0/logout?access_token=${TOKEN} 
