#!/usr/bin/env expect

# Construct the OTP script path using the HOME environment variable
set otp_script "$env(HOME)/.ssh/duo_device/duo_otp.sh"
set host [lindex $argv 0]

spawn ssh $host
expect {
    "Password:" {
        stty -echo
        expect_user -re "(.*)\n"
        set password $expect_out(1,string)
        stty echo
        send_user "\n"
        send "$password\r"
        exp_continue
    }
    "Passcode or option" {
        send "[exec $otp_script]\r"
        expect "Success. Logging you in..."
        interact
    }
    eof {
        send_user "Connection closed unexpectedly.\n"
        exit 1
    }
    timeout {
        send_user "Timed out waiting for prompts.\n"
        exit 1
    }
}