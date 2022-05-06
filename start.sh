#! /bin/bash

# CONTAINER NAMES FOR THE APPLICATIONS
VS_CONTAINER_NAME=vs_application
HVAC_CONTAINER_NAME=hvac_application
OTA_CONTAINER_NAME=ota_application
OD_CONTAINER_NAME=od_application
DDS_GATEWAY_CONTAINER_NAME=dds_gateway_application
OPENDDS_PATH=~/OpenDDS

trap "trap_ctrlc" 2

function trap_ctrlc ()
{
    # perform cleanup here
    echo " Ctrl-C caught... Performing clean up"

    echo "Exiting..."

    # exit shell script with error code 2
    # if omitted, shell script will continue execution
    docker stop $VS_CONTAINER_NAME $HVAC_CONTAINER_NAME $OD_CONTAINER_NAME
    docker stop  $DDS_GATEWAY_CONTAINER_NAME $OTA_CONTAINER_NAME
    kill -9 $(ps -ef | grep " python" | awk '{print $2}')
    mv nohup.out nohup.out.$(date +%s)
    exit 2
}

IVI_UI_FOLDER_PATH=$PWD

# Start the dockerized applications
docker run -d --rm --net=host --name $DDS_GATEWAY_CONTAINER_NAME sdv-dds-gateway:latest
#docker run -d --rm -p 5001:5001 --name $VS_CONTAINER_NAME vs-ms:latest
#docker run -d --rm --net=host --name $HVAC_CONTAINER_NAME sdv-hvac:latest
#docker run -d --rm -p 5003:5003 -v $PWD/nativeUI:/opt/ota/OTA_code/nativeUI --name $OTA_CONTAINER_NAME ota-ms:latest
#docker run -d --rm  --name od_application -p 5002:5002 od-ms:latest

#-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH 

source $OPENDDS_PATH/setenv.sh

#IVI_UI_FOLDER_PATH=$PWD
echo "UI Folder Path - " $IVI_UI_FOLDER_PATH
source $IVI_UI_FOLDER_PATH/pydds/bin/activate

cd $IVI_UI_FOLDER_PATH/UI_pubSub/ui_pub_sub
python3.8 ui_pub_integrated.py &
sleep 2
deactivate

cd $IVI_UI_FOLDER_PATH/nativeUI
python3 SDV_Application &
sleep 1

source $IVI_UI_FOLDER_PATH/pydds/bin/activate
cd $IVI_UI_FOLDER_PATH/UI_pubSub/ui_pub_sub
python3.8 ui_sub_integrated.py &
#sleep 1.5

#cd $IVI_UI_FOLDER_PATH/Ice-sdv
#python3.6 Server_Ice.py &
#sleep 1

#python3.6 Client_Ice.py &

sleep 99999999999999999999999999999999999999999
