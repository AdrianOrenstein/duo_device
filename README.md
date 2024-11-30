# Duo device register

This setup guide creates a `duo-ssh` command to auto-fill in a Duo One-Time-Password (OTP) when prompted during an ssh login cli. After filling, the ssh session resumes as normal. 

## 1) Generating OTP

1. Clone this repo into your ssh folder: `git clone https://github.com/AdrianOrenstein/duo_device ~/.ssh/duo_device`
2. Make sure your SSH auth keys are setup: https://ccdb.alliancecan.ca/ssh_authorized_keys
3. Register a Duo Mobile device: https://ccdb.alliancecan.ca/multi_factor_authentications
4. Right click `->` Save QR code as `qr.png` into `~/.ssh/duo_device/qr.png`

### With Docker

```bash
docker run --rm -it -w /app --volume=$(pwd):/app/:rw adrianorenstein/duo_device_register:latest zbarimg qr.png | sed 's/QR-Code:duo:\/\/\(.*\)/\1/'
```

Replace `XXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY` below with the output of the command above.
```bash
docker run --rm -it -w /app --volume=$(pwd):/app/:rw adrianorenstein/duo_device_register:latest python duo_activate.py XXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY

# Make sure only your user can read the files in this directory. Stops other users from reading your hotp secret. 
chmod -R 600 ~/.ssh/duo_device
```

## 2) Creating the `duo-ssh` command

Inside of `.zshrc` or `.bashrc`, paste:

```bash
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
./scripts/build_docker.sh --push
```


# Kudos
[Repo that reverse engineered the Duo 2FA Mobile App](https://github.com/revalo/duo-bypass)
