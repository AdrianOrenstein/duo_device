#!/usr/bin/env python3
import requests
import base64
import json
import sys
from Crypto.PublicKey import RSA

if __name__ == "__main__":
    raw_input: str = sys.argv[1]
    split_raw_input: list = raw_input.split("-")
    code: str = split_raw_input[0]
    encoded_host: str = split_raw_input[1]
    host: str = base64.decodebytes(encoded_host.encode("utf-8") + b"==").decode()

    url = "https://{host}/push/v2/activation/{code}?customer_protocol=1".format(
        host=host, code=code
    )
    headers = {"User-Agent": "okhttp/2.7.5"}
    data = {
        "pkpush": "rsa-sha512",
        "pubkey": RSA.generate(2048).public_key().export_key("PEM").decode(),
        "jailbroken": "false",
        "architecture": "arm64",
        "region": "US",
        "app_id": "com.duosecurity.duomobile",
        "full_disk_encryption": "true",
        "passcode_status": "true",
        "platform": "Android",
        "app_version": "3.49.0",
        "app_build_number": "323001",
        "version": "11",
        "manufacturer": "unknown",
        "language": "en",
        "model": "Pixel 3a",
        "security_patch_level": "2021-02-01",
    }

    r = requests.post(url, headers=headers, data=data)
    response = json.loads(r.text)

    try:
        secret = base64.b32encode(response["response"]["hotp_secret"].encode())
    except KeyError:
        print(response)
        sys.exit(1)

    with open("duotoken.hotp", "w") as file:
        file.write(secret.decode() + "\n")
        file.write("0")

    with open("response.json", "w") as resp:
        resp.write(r.text)

    print("Done, now finish the activation process on the duo website.")
