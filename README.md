# Duo device register

This setup guide walks you through registering a duo device, and setting up a `duo-otp` command that prints to terminal a Duo One-Time-Password (OTP), and another command `duo-ssh` that reads the stdout and autofills a OTP if detected. 

## 1) Registering a Duo device
For the time being Duo only provides a user interface to register a mobile or a hardware device key. 
This section walks you through registering alternative devices. 
Registering alternative devices came from [the repo that reverse engineered the Duo 2FA Mobile App](https://github.com/revalo/duo-bypass) and this repo adapted device registration for Compute Canada users.
Namely, this repo just adds the `duo-otp` and `duo-ssh` commands for convenience.

1. Clone this repo into your ssh folder: `git clone https://github.com/AdrianOrenstein/duo_device ~/.ssh/duo_device`
2. Make sure your SSH auth keys are setup: https://ccdb.alliancecan.ca/ssh_authorized_keys, this repo assumes you do not need to enter passwords. 
3. Register a Duo Mobile device: https://ccdb.alliancecan.ca/multi_factor_authentications. As you register, you will see a QR code. Right click on the QR code and save as `qr.png` into `~/.ssh/duo_device/qr.png`

### With Docker
I have created docker images to save you the hastle of installing some packages that you only need for registering. 
[Verify the docker image here](https://github.com/AdrianOrenstein/duo_device/blob/main/dockerfiles/Dockerfile).

<details>
<summary>Setup Instructions for docker</summary>

```bash
docker run --rm -it -w /app --volume=$(pwd):/app/:rw adrianorenstein/duo_device_register:latest zbarimg qr.png | sed 's/QR-Code:duo:\/\/\(.*\)/\1/'
```

Replace `XXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY` below with the output of the command above.
```bash
docker run --rm -it -w /app --volume=$(pwd):/app/:rw adrianorenstein/duo_device_register:latest python duo_activate.py XXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY

# Make sure only your user can read the files in this directory. Stops other users from reading your hotp secret. https://linuxize.com/post/chmod-command-in-linux/#symbolic-text-method
chmod u=rwx,go= ~/.ssh/duo_device
find ~/.ssh/duo_device -type f -exec chmod 600 {} \;
find ~/.ssh/duo_device -type d -exec chmod 700 {} \;
chmod u=rwx,go= ~/.ssh/duo_device/duo_ssh.sh
chmod u=rwx,go= ~/.ssh/duo_device/duo_otp.sh
```
</details>

### Alternatively, install the packages yourself with venv.
Alternatively, you can install everything manually yourself:

<details>
<summary>Setup Instructions for venv</summary>

#### zbarimg
Need `zbarimg` to extract the hotp code.
```bash
# For Debian/Ubuntu, run:
apt-get install -y zbar-tools libzbar-dev

# or for macOS with Homebrew, run:
brew install zbar


zbarimg qr.png | sed 's/QR-Code:duo:\/\/\(.*\)/\1/'
```

#### duo_activate
Replace `XXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY` below with the output of the command above.

```bash
virtualenv -p python3.11 venv
./venv/bin/python3.11 -m pip install pyotp requests pycryptodome pyqrcode
./venv/bin/python3.11 duo_activate.py XXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY

# Make sure only your user can read the files in this directory. Stops other users from reading your hotp secret. https://linuxize.com/post/chmod-command-in-linux/#symbolic-text-method
chmod u=rwx,go= ~/.ssh/duo_device
find ~/.ssh/duo_device -type f -exec chmod 600 {} \;
find ~/.ssh/duo_device -type d -exec chmod 700 {} \;
chmod u=rwx,go= ~/.ssh/duo_device/duo_ssh.sh
chmod u=rwx,go= ~/.ssh/duo_device/duo_otp.sh
```

</details>

### Finish device registration on the duo website

Now that you have generated the OTP secret, you can finish the device registration on duo. 

## 2) Generating OTPs

This is the section where we setup commands to generate OTPs on demand, or in the next sub-section we can optionally enable an auto-fill script.

### oathtool
`oathtool` is required for the `duo-otp` and `duo-ssh` command to work, this dependancy makes it easier to generate OTPs using the hotp secret you generated in the previous section.

```bash
# For Debian/Ubuntu, run:
sudo apt-get install oathtool

# or for macOS with Homebrew, run:
brew install oath-toolkit
```

### The `duo-otp` command

This is the minimal command needed to generate OTPs. 

```bash
# .bashrc
echo 'alias duo-otp="$HOME/.ssh/duo_device/duo_otp.sh"' >> ~/.bashrc
source ~/.bashrc

# or .zshrc
echo 'alias duo-otp="$HOME/.ssh/duo_device/duo_otp.sh"' >> ~/.zshrc
source ~/.zshrc
```

#### Expected behaviour
```bash
> duo-otp
123456 # <- A unique OTP should be printed.
```


### The `duo-ssh` command

This is an optional feature to auto-fill the OTP, this requires giving a script temporary access to stdout and stdin, so...

The `duo-ssh` command is a security concern. 
You're allowing the autofill script to watch your terminal for a short period of time to fill in the OTP when it detects the duo 2fa prompt. 
Best practices are to **always verify the [autofill script](https://github.com/AdrianOrenstein/duo_device/blob/main/duo_ssh.sh)** and verify again if you pull an update.
Arbitrary code execution on your host machine should never go unverified.

<details>
<summary>Setup instructions: </summary>

#### Enabling
```bash
# .bashrc
echo 'alias duo-ssh="$HOME/.ssh/duo_device/duo_ssh.sh"' >> ~/.bashrc
source ~/.bashrc

# or .zshrc
echo 'alias duo-ssh="$HOME/.ssh/duo_device/duo_ssh.sh"' >> ~/.zshrc
source ~/.zshrc
```
#### Expected behaviour
As you have enabled ssh keys, you likely won't have a password prompt. 
```
Multifactor authentication is now mandatory to connect to this cluster.
...
...
...
...

Enter a passcode or select one of the following options:

 1. <Some existing duo mobile device>
 2. <The device you just registered> (Android)

Passcode or option (1-2): ###### <- A unique OTP should be auto-filled for you.
Success. Logging you in...
```
</details>

## 3) Ready

```bash
# generate a otp and then paste it in when prompted.
duo-opt
> ###### <- a code will be here.
ssh beluga
```

Or, if you enabled auto-fill:
```bash
# now use duo-ssh as you would ssh
duo-ssh beluga
```

Note: fingerprints will require user input and likely re-doing the duo-ssh command. 

# Contributors

## Building the docker image

```bash
./scripts/build_docker.sh
```

# Kudos
[Repo that reverse engineered the Duo 2FA Mobile App](https://github.com/revalo/duo-bypass)

David, for helping me write a more readable readme.
