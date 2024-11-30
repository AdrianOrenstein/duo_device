# Duo device register

## 1) Generating OTP

1. `git clone https://github.com/AdrianOrenstein/duo_device ~/.ssh/duo_device`
1. https://ccdb.alliancecan.ca/multi_factor_authentications
1. Register a Duo Mobile device
1. Right click `->` Save QR code as `qr.png` into `~/.ssh/duo_device/qr.png`

### With Docker

```bash
docker run --rm -it -w /app --volume=$(pwd):/app/:rw adrianorenstein/duo_device_register:latest zbarimg qr.png | sed 's/QR-Code:duo:\/\/\(.*\)/\1/'
```

Replace `XXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY` below with the output of the command above.
```bash
docker run --rm -it -w /app --volume=$(pwd):/app/:rw adrianorenstein/duo_device_register:latest python duo_activate.py XXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY

chmod -R 700 ~/.ssh/duo_device
```

## 2) Creating the `duo-ssh` command

Inside of `.zshrc` or `.bashrc`, paste:

```bash
echo 'source ~/.ssh/duo_device/duo_ssh.sh' >> ~/.zshrc
source ~/.zshrc
```


## 3) Ready

```bash
`duo-ssh beluga`
```

# Contributors

## Building the docker image

```bash
./scripts/build_docker.sh --push


```


# Cudos
[Repo that reverse engineered the Duo 2FA Mobile App](https://github.com/revalo/duo-bypass)
