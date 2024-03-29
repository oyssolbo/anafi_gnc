#!/bin/bash

usage="Usage: $(basename "$0") <test-name> <env (sim/lab/real)>"

if [ $# -ne 2 ]
  then
    echo $usage
    exit
fi

TEST_NAME=$1
ENV=$2
SCRIPT_DIR=$(dirname "$(realpath $0)")

OUTPUT_DIR=$SCRIPT_DIR/../out/rosbag/$ENV/$TEST_NAME
mkdir -p $OUTPUT_DIR

if [ -e $OUTPUT_DIR/*.bag ]
then
    OLD_DIR=$OUTPUT_DIR/old
    echo "Moving old bagfile into "$OLD_DIR""
    mkdir -p $OLD_DIR
    mv $OUTPUT_DIR/*.bag $OLD_DIR
fi

TIME=$(date +%Y-%m-%d-%H-%M-%S)

ANAFI_OUTPUT_TOPICS="\
        /anafi/image \
        /anafi/attitude \
        /anafi/gnss_location \
        /anafi/height \
        /anafi/optical_flow_velocities \
        /anafi/link_goodput \
        /anafi/link_quality \
        /anafi/wifi_rssi \
        /anafi/battery \
        /anafi/state \
        /anafi/pose \
        /anafi/odometry \
        /anafi/rpy \
        /anafi/polled_body_velocities \
        /anafi/link_quality \
        /anafi/link_goodput \
        /anafi/wifi_rssi \
        /anafi/msg_latency \
        /anafi/ned_pos_from_gnss"

ANAFI_CMD_TOPICS="\
        /anafi/cmd_takeoff \
        /anafi/cmd_land \
        /anafi/cmd_emergency \
        /anafi/cmd_rpyt \
        /anafi/cmd_moveto \
        /anafi/cmd_moveby \
        /anafi/cmd_camera \
        /anafi/cmd_moveto_ned_position"

DARKNET_TOPICS="/darknet_ros/bounding_boxes"

ESTIMATE_TOPICS="\
        /estimate/dnn_cv/heading \
        /estimate/dnn_cv/position \
        /estimate/ekf \
        /estimate/tcv/pose"

EMULATION_TOPICS="\
        /emulation/platform_position_ned"

QUAlISYS_TOPICS="\
        /qualisys/Anafi/odom \
        /qualisys/Anafi/pose \
        /qualisys/Anafi/velocity \
        /qualisys/Platform/odom \
        /qualisys/Platform/pose \
        /qualisys/Platform/velocity \
        /qualisys/Anafi/pose_downsampled"

GNC_TOPICS="\
        /guidance/pure_pursuit/velocity_reference \
        /guidance/pid/velocity_reference \
        /ipid/delta_hat"

STANDARD_TOPICS="\
        $ANAFI_OUTPUT_TOPICS \
        $ANAFI_CMD_TOPICS \
        $DARKNET_TOPICS \
        $ESTIMATE_TOPICS \
        $GNC_TOPICS \
        /tf"

if [[ $ENV == "sim" ]]; then
    echo "Rosbagging sim topics"
    rosbag record -O $OUTPUT_DIR/$TIME \
        $STANDARD_TOPICS \
        $EMULATION_TOPICS
elif [[ $ENV == "lab" ]]; then
    echo "Rosbagging lab topics"
    rosbag record -O $OUTPUT_DIR/$TIME \
        $STANDARD_TOPICS \
        $QUAlISYS_TOPICS 
elif [[ $ENV == "real" ]]; then
    echo "Rosbagging real topics"
    rosbag record -O $OUTPUT_DIR/$TIME \
        $STANDARD_TOPICS \
        $QUAlISYS_TOPICS 
fi
