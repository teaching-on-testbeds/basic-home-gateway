sudo ip addr flush dev eth1

# Stop DHCP client on eth0
sudo killall dhclient
# Set hostname to keep sudo from complaining
sudo hostname $(hostname -s)
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

# for CloudLab web interface
sudo route add -net 155.98.33.0/24 gw $gateway

sudo route add -host $myip gw $gateway
sudo route add -net $(echo $myip | cut -f1-3 -d'.').0/24 gw $gateway
sudo route del default gw $gateway
