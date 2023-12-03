sd=$(cat /etc/resolv.conf  | grep ^search  | awk '{print $2}')
hn=$(hostname)
sudo ip addr flush dev eth1

# Stop DHCP client on eth0
sudo killall dhclient
# Set hostname to keep sudo from complaining
sudo hostname $hn
echo "127.0.0.1     localhost" | sudo tee /etc/hosts
echo "127.0.0.1     $(hostname)" | sudo tee /etc/hosts -a
# Remove university name server config
sudo rm /etc/resolv.conf
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Add route for the IP address you are currently connected to, via eth0
# Then remove default route via eth0
read _ _ gateway _ < <(ip route list match 0/0)
read _ _ _ _ _ _ _ _ connection _ < <(sudo lsof -i tcp -n | grep sshd | grep $USER)
myip=$(echo $connection | cut -f2 -d ">" | cut -f1 -d":")

# for Emulab - and all clusters need this too, for shell and VNC
sudo ip route add $(dig +short boss.emulab.net | cut -f1-3 -d'.').0/24 via $gateway 
sudo ip route add $(dig +short ops.emulab.net | cut -f1-3 -d'.').0/24 via $gateway

# for APT - more general than strictly required, but ¯\_(ツ)_/¯
sudo ip route add $(dig +short boss.apt.emulab.net | cut -f1-3 -d'.').0/24 via $gateway 
sudo ip route add $(dig +short ops.apt.emulab.net | cut -f1-3 -d'.').0/24 via $gateway 

if [[ $sd == "utah.cloudlab.us" ]]
then
  # for Utah - more general than strictly required, but ¯\_(ツ)_/¯
  sudo ip route add $(dig +short boss.utah.cloudlab.us | cut -f1-3 -d'.').0/24 via $gateway 
  sudo ip route add $(dig +short ops.utah.cloudlab.us | cut -f1-3 -d'.').0/24 via $gateway 
fi

if [[ $sd == "wisc.cloudlab.us" ]]
then
  # for Wisconsin - more general than strictly required, but ¯\_(ツ)_/¯
  sudo ip route add $(dig +short boss.wisc.cloudlab.us | cut -f1-3 -d'.').0/24 via $gateway 
  sudo ip route add $(dig +short ops.wisc.cloudlab.us | cut -f1-3 -d'.').0/24 via $gateway 
fi

if [[ $sd == "clemson.cloudlab.us" ]]
then
  # for Clemson - more general than strictly required, but ¯\_(ツ)_/¯
  sudo ip route add $(dig +short boss.clemson.cloudlab.us | cut -f1-3 -d'.').0/24 via $gateway 
  sudo ip route add $(dig +short ops.clemson.cloudlab.us | cut -f1-3 -d'.').0/24 via $gateway 
fi

# private range for virtual nodes (VMs) without routable IP addresses
sudo ip route add 172.16.0.0/12 dev eth0

# for my own network
sudo ip route add $myip/32 via $gateway
sudo ip route add $(echo $myip | cut -f1-3 -d'.').0/24 via $gateway
sudo ip route del default
