# Navex
Terminal light wright file explorer interface made with dialog.

> Note: Only debian derived systems have been tested

## Dependencies

### Requirements
* _dialog_ - window system on which Navex is based
* _finger_ - obtain user info from system
* _expect_ - help to modify user password (under testing)

## Installation

* You can use the following script to install this explorer and its dependencies.

```shell
sudo git clone https://github.com/mfruizs/navex.git && cd navex && sudo chmod +x installer.sh && sudo ./installer.sh
```

* Once the installation is finished, we must execute the following command to be able to use Navex from any part of the system

```shell
export PATH="$PATH:/usr/local/bin/navex"
```

## Running

```shell
./navex.sh
```