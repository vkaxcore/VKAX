# Participating in the SPRINGBOK Test Net
Learning how to use the SPRINGBOK **Test Net** will prepare you to do things like mine solo or run a masternode on the **Main Net**
<br/>

## Getting Ubuntu 
Ubuntu is an open source system which is easy to use, but still powerful and stable. This means that an entire operating system can function with as little as **1 cpu** core and less than **1 gig** of ram! To participate in the SPRINGBOK **Test Net** you will need an operational [**Ubuntu**](https://ubuntu.com/) system - either locally or with a cloud service. It is possible for anyone to run a Ubuntu system without difficulty or cost.

Some local examples include, a **[Raspberry Pi](https://www.raspberrypi.com/)**, old hardware like a **[Laptop with Broken Screen](https://www.ebay.com/sch/i.html?_nkw=laptop+broken+screen)**, a **[Discarded PC](https://www.goodwillfinds.com/search/?q=computer)** - or even from within your main PC using [**Virtualbox**](https://duckduckgo.com/?q=how+to+install+ubuntu+on+virtual+box) or [**Vmware Workstation**](https://duckduckgo.com/?q=how+to+install+ubuntu+on+vmware+workstation)

If you do not have any hardware resources available or you want to run multiple nodes, there is a [**list of services which offer free trials or an always free option**](https://linktr.ee/setvin)

Because Ubuntu is open source and relies on decentralization, we should realize it shares an overlap with many of the ideals we believe in crypto currencies! Understanding free and open source systems like Ubuntu will benefit anyone interested in mastering their experience! Relying on central services and paying for things which should be free is not beneficial to decentralization or genuine network growth. 

If you **don't have a few minutes** to learn something new, then you probably **do not have time** to invest in or mine crypto currencies without encoutering significant risk! Windows users are most often targeted for scams and hacks, so the value of learning linux can't be measured immediately. Remember, there is no such thing as a free lunch, or getting rich quick. If you want it, you must get it! 
<br/>
<br/>

Failure to follow instructions may result in an incorrect build! The order is important, please ensure you review each step


<br/>

### Install Dependencies
Before proceeding to do anything, we must first install the relevant dependencies. **Copy and Paste** the following code into a terminal console on Ubuntu 
(Press the **button on the right** of the code block, or press **CTRL + C** to copy and then **CTRL + V** to paste) 
```
sudo apt update -y && sudo apt upgrade -y &&
sudo apt-get install curl build-essential libtool autotools-dev automake pkg-config python3 bsdmainutils screen hwloc bison nohang htop
```
<br/>

### Enable Swap
Creating a swap file will use some of the storage space but provide the system additional memory handling functions, making crashes on low end systems less likely.
```
sudo fallocate -l 2G /swapfile &&
sudo mkswap /swapfile &&
sudo chmod 0600 /swapfile &&
sudo swapon /swapfile &&
sudo swapon -s &&
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Create SPRINGBOK User
Run the below commands in a terminal console one at a time. We will need to create a new **User** to run the daemon. 
(You can give it any password or press **enter** to skip.)
```
sudo adduser springbok-test
```
**Login** to become the SPRINGBOK user
```
sudo su springbok-test
```
<br/>

### Make the Daemon (Node)
After installing the prerequisites and becoming the springbok-test user, we can **build the daemon from source**
```
cd &&
git clone https://github.com/springbokcore/springbok &&
cd springbok/depends/ &&
chmod +x conf* &&
make NO_QT=1 &&
cd .. &&
./autogen.sh &&
./configure --disable-tests --disable-bench --without-gui --prefix=$PWD/depends/x86_64-pc-linux-gnu/ &&
make
```
The build will take a long time. Please do not close the system while the script is working

When it is **complete** it should look like this
<br/>

![image](https://github.com/springbokcore/springbok/assets/117243445/447103d0-57ce-47f5-b072-3dae6524c4b6)


<br/>

### Write SPRINGBOK.conf
This will **Write** default settings for your SPRINGBOK testnet node.
```
mkdir ~/.springbokcore/
touch ~/.springbokcore/springbok.conf &&
echo -e "rpcuser=springboktestnet\nrpcpassword=changemepassword123\nmaxconnections=256\nrpcallowip=127.0.0.1\ntestnet=1\nlisten=1\nserver=1\ndaemon=1\nusehd=1\n" >> ~/.springbokcore/springbok.conf
```

<br/>
<br/>

**Exit** as the springbok-test user
```
exit
```
> [!CAUTION]
> If you forget to **log out** of the springbok-test user, the below commands **will not work** properly

<br/>
<br/>

### Starting the Daemon
Using **`systemd`** we can create a service which starts the SPRINGBOK daemon on boot, and restarts it after a crash
<br/>
<br/>

Become a **Super User** first
```
sudo su
```
<br/>

**Clean** up the build files
```
mv /home/springbok-test/springbok/src/springbok-cli /home/springbok-test/springbok/src/springbokd /home/springbok-test/.springbokcore/ &&
chmod 777 /home/springbok-test/.springbokcore &&
rm -R /home/springbok-test/springbok/
```
<br/>

**Open** the Ports and Enable **Firewall**
```
sudo apt update -y && sudo apt upgrade -y &&
sudo apt install ufw &&
sudo ufw default deny incoming &&
sudo ufw default allow outgoing &&
sudo ufw allow ssh &&
sudo ufw allow 11110/tcp &&
sudo ufw allow 22220/tcp &&
sudo ufw enable
```

<br/>

**Create** and **Enable** the systemd service
```
touch /etc/systemd/system/springbok-test.service
echo -e "[Unit]\nDescription=springbok test daemon control service\n\n[Service]\nType=forking\nRestart=on-failure\nRestartSec=5s\nExecStartPre=/bin/sleep 5\nWorkingDirectory=/home/springbok-test/.springbokcore/\nExecStart=/home/springbok-test/.springbokcore/springbokd\nRemainAfterExit=yes\nUser=springbok-test\n\n[Install]\nWantedBy=multi-user.target" >> /etc/systemd/system/springbok-test.service
systemctl enable springbok-test
```
<br/>

**Reboot** for changes to take effect
```
reboot
```
<br/>

We can **Watch** the **Status** of our daemon at any time with the following command
```
watch systemctl status springbok-test
```
<br/>


## Using SPRINGBOK Test Net


<br/>

**Login** as springbok-test user
```
sudo su springbok-test
```

Always remember to login as springbok-test before running commands, and to log out with `exit` or close the terminal when complete. The daemon will continue to run in the background.


<br/>
<br/> 


To ensure you have a **connection** with the network you can write
```
~/.springbokcore/springbok-cli -testnet getconnectioncount 
```
<br/> 

Run the **Help** command as the **springbok-test** user to get a full list of available commands! )You must include **-testnet** when using the testnet)
```
~/.springbokcore/springbok-cli -testnet help
```
<br/> 

# Getting your HD Seed Phrase 
Getting a seed phrase is essential for anyone who wants security, confidence or is considering doing serious development work on the SPRINGBOK network. 
All you have to do is write down your seed words and remember to use them.

Display your seed phrase with the below command
```
~/.springbokcore/springbok-cli -testnet dumphdinfo
```
> [!CAUTION]
> ***WRITE THIS DOWN!***

Do not store your **confidential seed phrase** on a computer or on a phone! **Do not share** this phrase with anyone, or leave it out for people to find! There is no support ticket or central body which can recover your coins, so you should **never share these words with anyone! Ever! For any reason!** You can use this same **seed phrase** forever with SPRINGBOK, even on the main net! You can save yourself a lot of time by **writing this down now**. Hackers cannot access a sheet of paper in your sock drawer!

<br/> 
<br/> 

<br/> 

## Basic SPRINGBOK Commands

<br/> 

To check the status of the testnet daemon's **debug log**
```
watch tail ~/.springbokcore/testnet3/debug.log -n25
```

<br/> 
<br/> 

To start **mining** for blocks
```
~/.springbokcore/springbok-cli -testnet setgenerate true
```

The only indication that mining has started is this output which shows us how many cores are running.

![image](https://github.com/springbokcore/springbok/assets/117243445/f61bccb1-2097-4d99-a854-e8dc410cdfa9)

<br/> 

You can also check **cpu usage** after mining using the **`htop`** command
```
htop
```

`htop` will look liks this. (press **CTRL + C** to exit)
![image](https://github.com/springbokcore/springbok/assets/117243445/cfdb2012-d202-4207-a162-328836a58428)


<br/> 
<br/> 

After finding a block you will get **sent coins**. Use this command to see the **last 10** transations
```
~/.springbokcore/springbok-cli -testnet listtransactions
```

<br/> 

To see the current **block** count

```
~/.springbokcore/springbok-cli -testnet getblockcount 
```
<br/> 

To check your **coin** balance (will only display mature blocks after 200 confirmations)
```
~/.springbokcore/springbok-cli -testnet getbalance
```
<br/> 
<br/> 

To **Stop Mining**
```
~/.springbokcore/springbok-cli -testnet setgenerate false 0
```

<br/> 

## More SPRINGBOK Commands
[SPRINGBOK Legacy Command Line Reference](https://github.com/springbokcore/springbok/blob/master/doc/springbok-command-line-rpc-api-reference.md)
<br/>

[SPRINGBOK Remote Procedure Calls (RPC)](https://github.com/springbokcore/springbok/blob/master/doc/springbok-remote-procedure-calls.md)
<br/> 

## Conclusion

Congrats! You are now running a node on the **SPRINGBOK Test Net**

After accumulating **10 000 000** coins you will be eligable to create a **masternode**

Once you are become familiar with the **Test Net** envoirnment, you should be ready to confidently use the SPRINGBOK **Main Net**. Good luck!









