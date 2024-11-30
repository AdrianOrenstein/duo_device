# Duo device register

## 1) Generating OTP

1. `git clone https://github.com/AdrianOrenstein/duo_device ~/.ssh/duo_device`
1. https://ccdb.alliancecan.ca/multi_factor_authentications
1. Register a Duo Mobile device
1. Right click `->` Save QR code as `qr.png` into `~/.ssh/duo_device/qr.png`

### With Docker

```bash
docker run docker.io/adrianorenstein/duo_device_register:latest python duo_activate.py --qr_img qr.png
chmod -R 600 ~/.ssh/duo_device
chmod +x ~/.ssh/duo_device/duo_activate.py
chmod +x ~/.ssh/duo_device/duo_gen_cli.py
```

### Or, with venv

```bash
# make a virtualenv 

```

## 2) Creating the `duo-ssh` command

Inside of `.zshrc` or `.bashrc`, paste:

```bash
echo 'source ~/.ssh/duo_device/duo_ssh.sh' >> ~/.zshrc
source ~/.zshrc
```

# Contributors

## Building the docker image

```bash
./scripts/build_docker.sh --push


```


# Cudos
[Repo that reverse engineered the Duo 2FA Mobile App](https://github.com/revalo/duo-bypass)
