# Duo device register

This setup guide creates a `duo-ssh` command that auto-fills a Duo One-Time-Password (OTP). The [autofill script is here](https://github.com/AdrianOrenstein/duo_device/blob/main/duo_ssh.sh). The 

## 1) Generating OTP

1. Clone this repo into your ssh folder: `git clone https://github.com/AdrianOrenstein/duo_device ~/.ssh/duo_device`
2. Make sure your SSH auth keys are setup: https://ccdb.alliancecan.ca/ssh_authorized_keys
3. Register a Duo Mobile device: https://ccdb.alliancecan.ca/multi_factor_authentications
4. Right click `->` Save QR code as `qr.png` into `~/.ssh/duo_device/qr.png`

### With Docker

<details>
<summary>Setup Instructions for docker</summary>

```bash
docker run --rm -it -w /app --volume=$(pwd):/app/:rw adrianorenstein/duo_device_register:latest zbarimg qr.png | sed 's/QR-Code:duo:\/\/\(.*\)/\1/'
```

Replace `XXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY` below with the output of the command above.
```bash
docker run --rm -it -w /app --volume=$(pwd):/app/:rw adrianorenstein/duo_device_register:latest python duo_activate.py XXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY

# Make sure only your user can read the files in this directory. Stops other users from reading your hotp secret. 
chmod -R 600 ~/.ssh/duo_device
```
</details>

### or, with venv

<details>
<summary>Setup Instructions for venv</summary>

#### zbarimg
Need `zbarimg` to extract the hotp code.
```bash
apt-get install -y zbar-tools libzbar-dev

zbarimg qr.png | sed 's/QR-Code:duo:\/\/\(.*\)/\1/'
```

#### duo_activate
Replace `XXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY` below with the output of the command above.

```bash
virtualenv -p python3.11 venv
./venv/bin/python3.11 -m pip install pyotp requests pycryptodome pyqrcode
./venv/bin/python3.11 duo_activate.py XXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY

# Make sure only your user can read the files in this directory. Stops other users from reading your hotp secret. 
chmod -R 600 ~/.ssh/duo_device
```

</details>

## 2) Creating the `duo-ssh` command

### oathtool
`oathtool` is required for the `duo-ssh` command to work, so:
```bash
# For Debian/Ubuntu, run:
sudo apt-get install oathtool

# or for macOS with Homebrew, run:
brew install oath-toolkit
```

### duo-ssh command
Then we can add the `duo-ssh` command into your:
```bash
# .bashrc
echo 'source ~/.ssh/duo_device/duo_ssh.sh' >> ~/.bashrc
source ~/.bashrc

# or .zshrc
echo 'source ~/.ssh/duo_device/duo_ssh.sh' >> ~/.zshrc
source ~/.zshrc
```


## 3) Ready

```bash
duo-ssh beluga
```

Note: fingerprints will require user input and likely re-doing the duo-ssh login. 

# Contributors

## Building the docker image

```bash
./scripts/build_docker.sh
```


# Kudos
[Repo that reverse engineered the Duo 2FA Mobile App](https://github.com/revalo/duo-bypass)
