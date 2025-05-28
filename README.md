# [VKAX](https://vkaxcore.github.io/VKAX/)


## **Vero Kum Abdite Xenium**


*"_In truth we arise with a hidden gift_"*

<br/>
<br/>

<picture>
  <img src="https://github.com/vkaxcore/VKAX/blob/master/src/qt/res/icons/dash.png?raw=true" alt="VKAX Crypto Currency Coin Image">
</picture>

<br/>
<br/>

<br/>

<br/>

> [!NOTE]
> VKAX is forked from DASH and BITCOIN, utilizing a CPU mining algorithm based on GHOSTRIDER called MIKE
<br/>

VKAX is an experimental, community owned cryptocurrency which mirrors parts of the open source [Bitcoin](https://github.com/bitcoin/bitcoin) and [Dash](https://github.com/dashpay/dash) code base. This means VKAX gains the power of the UTXO blockchain model as well as the benefits of masternodes – which allow qualified holders to earn a share of the block reward. The Mike mining algorithm is based on the asic-proof [Ghostrider](https://github.com/Raptor3um/raptoreum) which ensures that the VKAX network has one CPU, one vote. Through upgrades and hardforks, the community can guarantee that VKAX remains ASIC resistant. 

Operating on a peer-to-peer network without a central authority, VKAX enables secure, private transactions and instant payments. As a full fork of Dash, it incorporates masternodes to enhance transaction speed, privacy, and network security. Masternodes also play a crucial role in governance, guiding the project's future.

VKAX's emission schedule starts with 10,000 VKAX per block, divided between miners (6,750 VKAX) and masternodes (2,250 VKAX). Over time, rewards decrease to control inflation and maintain value. By block height 1,950,005, miner rewards will drop to 222.22 VKAX, and masternode rewards will be around 277.78 VKAX. The 150-second block time ensures consistent reward distribution.

VKAX is community-driven, with masternode operators and network participants proposing and voting on changes. This decentralized governance structure ensures decisions are made by the community, not a centralized entity.

VKAX is built to be sustainable and accessible, with long-term viability ensured by its emission schedule and decentralized governance. It's designed to stand the test of time, driven by a community that values fairness and stability.

The genesis block carries the timestamp: "June 14, 2022, Elon Musk Is Set to Address Twitter Employees for the First Time."



<br/>

## Building VKAX
(tested for ubuntu)

<br/>

Install dependencies
```
sudo apt-get install curl build-essential libtool autotools-dev automake pkg-config python3 bsdmainutils bison build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev g++-aarch64-linux-gnu  g++-mingw-w64-x86-64 mingw-w64-x86-64-dev gperf zip git curl libevent-dev
```

<br/>

Build from source 
```
git clone https://github.com/vkaxcore/VKAX &&
cd VKAX/depends/ &&
chmod +x conf* &&
make &&
cd .. &&
./autogen.sh &&
./configure --prefix=$PWD/depends/x86_64-pc-linux-gnu/ &&
make
```
(will take a few minutes)


<br/>

## VKAX Wallets
[[built by github]](https://github.com/vkaxcore/VKAX/actions/runs/8527185200/)

### [[WINDOWS]](https://github.com/vkaxcore/VKAX/releases/download/v100.11.2-windows/VKAX.Setup.exe)

### [[MAC]](https://github.com/vkaxcore/VKAX/releases/download/v100.11.2/vkax-macos12-.zip)

### [[UBUNTU]](https://github.com/vkaxcore/VKAX/releases/download/v100.11.2/vkax-ubuntu22-.zip)

### [[RASPBERRY PI]](https://github.com/vkaxcore/VKAX/releases/download/v100.11.2/vkax-ubuntu22-arm64-.zip)


<br/>

## Mining VKAX
### [[XmrigCC] (CPU)](https://github.com/Bendr0id/xmrigCC/releases/tag/3.4.0)

### [[Cpuminer Rplant] (CPU)](https://github.com/rplant8/cpuminer-opt-rplant/releases)

### [[SRBMiner] (CPU)](https://github.com/doktor83/SRBMiner-Multi/releases)

### [[Wildrig] (GPU)](https://github.com/andru-kun/wildrig-multi/releases)



<br/>

## VKAX Documents

### [[VKAX Whitepaper v1]](https://github.com/vkaxcore/VKAX/blob/master/doc/vkaxwhitepaper.pdf)

### [[VKAX Test Net Guide]](https://vkaxcore.github.io/VKAX/doc/testnet-participation)

### [[VKAX Command Line Reference]](https://vkaxcore.github.io/VKAX/doc/vkax-command-line-rpc-api-reference)

### [[VKAX Remote Procedure Calls (RPC)]](https://vkaxcore.github.io/VKAX/doc/vkax-remote-procedure-calls)


<br/>

## VKAX Links

### [[VKAX Website]](https://vkaxcore.github.io/VKAX/)

### [[VKAX Explorer]](https://explore.vkax.net/)

### [[VKAX BitcoinTalk Forum]](https://bitcointalk.org/index.php?topic=5414883)

### [[VKAX Coin Gecko]](https://www.coingecko.com/coins/vkax)

### [[VKAX Coin Paprika]](https://coinpaprika.com/coin/vkax-vkax/)

### [[VKAX Mining Pool Stats]](https://miningpoolstats.stream/vkax)


## Socials

### [[VKAX Discord]](https://discord.gg/C3sfPFB3)

### [[VKAX Twitter (X)]](https://twitter.com/vkaxcore)


## Contact

### dev@vkax.net

<br/>

# Emission Schedule
![image](https://github.com/vkaxcore/VKAX/blob/master/VKAXemission.png?raw=true)

<br/>

# Testing

## Participating in the VKAX Test Net
> [!TIP]
> Learning how to use the VKAX **Test Net** will prepare you to do things like mine solo or run a masternode on the **Main Net**
<br/>

### Getting Ubuntu 
Ubuntu is an open source system which is easy to use, but still powerful and stable. This means that an entire operating system can function with as little as **1 cpu** core and less than **1 gig** of ram! To participate in the VKAX **Test Net** you will need an operational [**Ubuntu**](https://ubuntu.com/) system - either locally or with a cloud service. It is possible for anyone to run a Ubuntu system without difficulty or cost.

Some local examples include, a **[Raspberry Pi](https://www.raspberrypi.com/)**, old hardware like a **[Laptop with Broken Screen](https://www.ebay.com/sch/i.html?_nkw=laptop+broken+screen)**, a **[Discarded PC](https://www.goodwillfinds.com/search/?q=computer)** - or even from within your main PC using [**Virtualbox**](https://duckduckgo.com/?q=how+to+install+ubuntu+on+virtual+box) or [**Vmware Workstation**](https://duckduckgo.com/?q=how+to+install+ubuntu+on+vmware+workstation)

If you do not have any hardware resources available or you want to run multiple nodes, there is a [**list of services which offer free trials or an always free option**](https://linktr.ee/setvin)

Because Ubuntu is open source and relies on decentralization, we should realize it shares an overlap with many of the ideals we believe in crypto currencies! Understanding free and open source systems like Ubuntu will benefit anyone interested in mastering their experience! Relying on central services and paying for things which should be free is not beneficial to decentralization or genuine network growth. 

If you **don't have a few minutes** to learn something new, then you probably **do not have time** to invest in or mine crypto currencies without encoutering significant risk! Windows users are most often targeted for scams and hacks, so the value of learning linux can't be measured immediately. Remember, there is no such thing as a free lunch, or getting rich quick. If you want it, you must get it! 
<br/>
<br/>

> [!WARNING]
> Failure to follow instructions may result in an incorrect build! The order is important, please ensure you review each step


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

### Create VKAX User
Run the below commands in a terminal console one at a time. We will need to create a new **User** to run the daemon. 
(You can give it any password or press **enter** to skip.)
```
sudo adduser vkax-test
```
**Login** to become the VKAX user
```
sudo su vkax-test
```
<br/>

### Make the Daemon (Node)
After installing the prerequisites and becoming the vkax-test user, we can **build the daemon from source**
```
cd &&
git clone https://github.com/vkaxcore/VKAX &&
cd VKAX/depends/ &&
chmod +x conf* &&
make NO_QT=1 &&
cd .. &&
./autogen.sh &&
./configure --disable-tests --disable-bench --without-gui --prefix=$PWD/depends/x86_64-pc-linux-gnu/ &&
make
```
> [!NOTE]  
> The build will take a long time. Please do not close the system while the script is working

When it is **complete** it should look like this
<br/>

![image](https://github.com/vkaxcore/vkax/assets/117243445/447103d0-57ce-47f5-b072-3dae6524c4b6)


<br/>

### Write VKAX.conf
This will **Write** default settings for your VKAX testnet node.
```
mkdir /home/vkax-test/.vkaxcore/
touch /home/vkax-test/.vkaxcore/vkax.conf &&
echo -e "rpcuser=vkaxtestnet\nrpcpassword=changemepassword123\nmaxconnections=256\nrpcallowip=127.0.0.1\ntestnet=1\nlisten=1\nserver=1\ndaemon=1\nusehd=1\n" >> /home/vkax-test/.vkaxcore/vkax.conf
```

<br/>
<br/>

**Exit** as the vkax-test user
```
exit
```
> [!CAUTION]
> If you forget to **log out** of the vkax-test user, the below commands **will not work** properly

<br/>
<br/>

### Starting the Daemon
Using **`systemd`** we can create a service which starts the VKAX daemon on boot, and restarts it after a crash
<br/>
<br/>

Become a **Super User** first
```
sudo su
```
<br/>

**Clean** up the build files
```
mv /home/vkax-test/VKAX/src/vkax-cli /home/vkax-test/VKAX/src/vkaxd /home/vkax-test/.vkaxcore/ &&
chmod 777 /home/vkax-test/.vkaxcore &&
rm -R /home/vkax-test/VKAX/
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
touch /etc/systemd/system/vkax-test.service
echo -e "[Unit]\nDescription=vkax test daemon control service\n\n[Service]\nType=forking\nRestart=on-failure\nRestartSec=5s\nExecStartPre=/bin/sleep 5\nWorkingDirectory=/home/vkax-test/.vkaxcore/\nExecStart=/home/vkax-test/.vkaxcore/vkaxd\nRemainAfterExit=yes\nUser=vkax-test\n\n[Install]\nWantedBy=multi-user.target" >> /etc/systemd/system/vkax-test.service
systemctl enable vkax-test
```
<br/>

**Reboot** for changes to take effect
```
reboot
```
<br/>

We can **Watch** the **Status** of our daemon at any time with the following command
```
watch systemctl status vkax-test
```
<br/>


## Using VKAX Test Net


<br/>

**Login** as vkax-test user
```
sudo su vkax-test
```

> [!IMPORTANT]  
> Always remember to login as vkax-test before running commands, and to log out with `exit` or close the terminal when complete. The daemon will continue to run in the background.


<br/>
<br/> 


To ensure you have a **connection** with the network you can write
```
~/.vkaxcore/vkax-cli -testnet getconnectioncount 
```
<br/> 

Run the **Help** command as the **vkax-test** user to get a full list of available commands! )You must include **-testnet** when using the testnet)
```
~/.vkaxcore/vkax-cli -testnet help
```
<br/> 

# Getting your HD Seed Phrase 
Getting a seed phrase is essential for anyone who wants security, confidence or is considering doing serious development work on the VKAX network. 
All you have to do is write down your seed words and remember to use them.

Display your seed phrase with the below command
```
~/.vkaxcore/vkax-cli -testnet dumphdinfo
```
> [!CAUTION]
> ***WRITE THIS DOWN!***

Do not store your **confidential seed phrase** on a computer or on a phone! **Do not share** this phrase with anyone, or leave it out for people to find! There is no support ticket or central body which can recover your coins, so you should **never share these words with anyone! Ever! For any reason!** You can use this same **seed phrase** forever with VKAX, even on the main net! You can save yourself a lot of time by **writing this down now**. Hackers cannot access a sheet of paper in your sock drawer!

<br/> 
<br/> 

<br/> 

## Basic VKAX Commands

<br/> 

To check the status of the testnet daemon's **debug log**
```
watch tail ~/.vkaxcore/testnet3/debug.log -n25
```

<br/> 
<br/> 

To start **mining** for blocks
```
~/.vkaxcore/vkax-cli -testnet setgenerate true
```

The only indication that mining has started is this output which shows us how many cores are running.

![image](https://github.com/vkaxcore/vkax/assets/117243445/f61bccb1-2097-4d99-a854-e8dc410cdfa9)

<br/> 

You can also check **cpu usage** after mining using the **`htop`** command
```
htop
```

`htop` will look liks this. (press **CTRL + C** to exit)
![image](https://github.com/vkaxcore/vkax/assets/117243445/cfdb2012-d202-4207-a162-328836a58428)


<br/> 
<br/> 

After finding a block you will get **sent coins**. Use this command to see the **last 10** transations
```
~/.vkaxcore/vkax-cli -testnet listtransactions
```

<br/> 

To see the current **block** count

```
~/.vkaxcore/vkax-cli -testnet getblockcount 
```
<br/> 

To check your **coin** balance (will only display mature blocks after 200 confirmations)
```
~/.vkaxcore/vkax-cli -testnet getbalance
```
<br/> 
<br/> 

To **Stop Mining**
```
~/.vkaxcore/vkax-cli -testnet setgenerate false 0
```

<br/> 

## More VKAX Commands
[VKAX Legacy Command Line Reference](https://github.com/vkaxcore/vkax/blob/master/doc/vkax-command-line-rpc-api-reference.md)
<br/>

[VKAX Remote Procedure Calls (RPC)](https://github.com/vkaxcore/vkax/blob/master/doc/vkax-remote-procedure-calls.md)
<br/> 

## Conclusion

Congrats! You are now running a node on the **VKAX Test Net**

After accumulating **10 000 000** coins you will be eligable to create a **masternode**

Once you are become familiar with the **Test Net** envoirnment, you should be ready to confidently use the VKAX **Main Net**. Good luck!










