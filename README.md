# SHRDZMmon
Service to read power values from smartmeter using SHRDZM device 

Features:
 * store values in shared memory for easy access (conky, ...)
 * show value on TM1637 display (Raspberry Pi)
 * store values to csv file

## Install display (Raspberry Pi)

```bash

wget https://github.com/WiringPi/WiringPi/releases/download/2.61-1/wiringpi-2.61-1-armhf.deb
sudo apt install ./wiringpi-2.61-1-armhf.deb

git clone https://github.com/GrazerComputerClub/TM1637Display
cd TM1637Display
g++ -o 2display 2display.cpp TM1637Display.cpp -Wall -lwiringPi
sudo cp 2display /usr/local/bin
```

## Install

```bash
sudo apt install jq 

sudo chmod +x SHRDZM.sh  
sudo cp SHRDZM.sh /usr/local/bin
sudo cp SHRDZM.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start SHRDZM
sudo systemctl status SHRDZM
sudo systemctl enable SHRDZM
```
