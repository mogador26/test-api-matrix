#!/bin/bash

ROOM="!xxxxxxxxxxxx:xxxxxxx.tchap.gouv.fr"
NOM_PRENOM="nom.prenom"
PASSWORD=""
DEVICE="ubuntu"
FILE_NAME="./token.txt"
TOKEN=""

if [ $# -eq 1 ]
  then
    MESSAGE=$1
else
    MESSAGE="veuillez saisir un message ..."
fi

MESSAGE_PLAIN="${MESSAGE}"
MESSAGE_FORMATTED="&#9888;&#65039;<strong>${MESSAGE}<strong>"

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

#curl -sk -X POST "https://matrix.agent.interieur.tchap.gouv.fr/_matrix/client/r0/logout?access_token=${TOKEN} 


