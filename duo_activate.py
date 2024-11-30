#!/usr/bin/env python3
import pathlib
import pyotp
import requests
import base64
import json
import sys
import cv2


def readQR(filepath: pathlib.Path):
    img = cv2.imread(qrFile.name)
    detector = cv2.QRCodeDetector()
    data, bbox, _ = detector.detectAndDecode(img)
    if bbox is None and data == "":
        print("No QR code detected in file.")
        data = input("Please enter QR Code value manually: ")
    return data


if "__name__" == "__main__":
    qrFile = pathlib.Path("qr.png")

    # if file exists read QR code. Else let the user input the QR value
    if qrFile.is_file():
        data = readQR(qrFile.as_posix())
    else:
        print(qrFile.as_posix() + " not found.")
        data = input("Enter QR Code value manually: ")

    # The QR Code is in the format: XXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
    code = data.split("-")[0]

    # decode YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY - decoded format should look like: api-XXXXX.duosecurity.com
    b64host = data.split("-")[1]

    # add missing base64 padding for successful base64 decode: https://stackoverflow.com/questions/2941995/python-ignore-incorrect-padding-error-when-base64-decoding
    b64hostpadding = b64host + "=" * (-len(b64host) % 4)

    # decode base64 and convert to string
    host = base64.b64decode(b64hostpadding).decode("utf-8")

    url = "https://{host}/push/v2/activation/{code}?customer_protocol=1".format(
        host=host, code=code
    )
    headers = {"User-Agent": "okhttp/2.7.5"}
    data = {
        "jailbroken": "false",
        "architecture": "arm64",
        "region": "US",
        "app_id": "com.duosecurity.duomobile",
        "full_disk_encryption": "true",
        "passcode_status": "true",
        "platform": "Android",
        "app_version": "4.13.0",
        "app_build_number": "413000",
        "version": "12",
        "manufacturer": "unknown",
        "language": "en",
        "model": "unknown",
        "security_patch_level": "2022-04-01",
    }

    r = requests.post(url, headers=headers, data=data)
    response = json.loads(r.text)

    try:
        secret = base64.b32encode(response["response"]["hotp_secret"].encode())
    except KeyError:
        print(response)
        sys.exit(1)

    with open("duotoken.hotp", "w") as f:
        f.write(secret.decode() + "\n")
        f.write("0")

    with open("response.json", "w") as resp:
        resp.write(r.text)
