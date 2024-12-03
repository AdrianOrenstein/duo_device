# /bin/bash

duo-ssh() {
    # Check that duo-otp is available
    if ! command -v duo-otp >/dev/null 2>&1; then
        echo "Error: 'duo-otp' function not found."
        echo "Please follow the instructions to enable the 'duo-otp' function before using this script."
        return 1
    fi

    # Get the OTP code from the duo-otp function
    code=$(duo-otp)

    # Use expect to automate the SSH login, passing all arguments to ssh
    expect -c "
        set timeout 30

        spawn ssh -tt $*
        
        expect {
            \"Passcode or option\" {
                send \"$code\r\"
            }
            -re \"Password:\" {
                stty -echo
                expect_user -re \"(.*)\\n\"
                stty echo
                send \"$expect_out(1,string)\r\"
                exp_continue
            }
            eof {
                exit
            }
        }
        interact
    "
}