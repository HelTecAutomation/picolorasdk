#!/bin/bash
dir=`cd $(dirname "$0") & pwd`
dir_change=$(echo $dir | sed 's/\//\\\//g')
dir_p=${dir%/*}
dir_p_change=$(echo $dir_p | sed 's/\//\\\//g')
#lrgateway.service
sudo cp -f ${dir}/lrgateway.service ${dir}/lrgateway.service.tmp
sudo cp -f ${dir}/lrgateway.service /lib/systemd/system
sudo cp -f ${dir}/lrgateway.service /etc/systemd/system
sudo cp -f /home/pi/lora/picoGW_hal/util_chip_id/util_chip_id /home/pi/lora/picolorasdk
sudo sh ./update_gwid.sh local_conf.json
sleep 1
sudo cp -f local_conf.json /home/pi/lora/picoGW_packet_forwarder/lora_pkt_fwd
chmod +x reset.sh
sudo cp -f reset.sh /home/pi/lora/picoGW_packet_forwarder

sed -i "s/^WorkingDirectory=picoGW_packet_forwarder\/lora_pkt_fwd/WorkingDirectory=${dir_p_change}\/picoGW_packet_forwarder\/lora_pkt_fwd/" ${dir}/lrgateway.service.tmp
sed -i "s/^ExecStartPre=picoGW_packet_forwarder\/reset.sh start picoGW_packet_forwarder\/lora_pkt_fwd\/local_conf.json/\ ExecStartPre=${dir_p_change}\/picoGW_packet_forwarder\/reset.sh start ${dir_p_change}\/picoGW_packet_forwarder\/lora_pkt_fwd\/local_conf.json/" ${dir}/lrgateway.service.tmp
sed -i "s/^ExecStart=picoGW_packet_forwarder\/lora_pkt_fwd\/lora_pkt_fwd/ExecStart=${dir_p_change}\/picoGW_packet_forwarder\/lora_pkt_fwd\/lora_pkt_fwd/" ${dir}/lrgateway.service.tmp
sed -i "s/^ExecStopPost=picoGW_packet_forwarder\/reset.sh stop/ExecStopPost=${dir_p_change}\/picoGW_packet_forwarder\/reset.sh stop/" ${dir}/lrgateway.service.tmp

sudo systemctl daemon-reload
sudo systemctl restart systemd-journald

sudo systemctl enable lrgateway
sudo systemctl restart lrgateway

