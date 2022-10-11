#!/usr/bin/env bash
set -e

script_cmdline ()
{
    local param
    for param in $(< /proc/cmdline); do
        case "${param}" in
            script=*) echo "${param#*=}" ; return 0 ;;
        esac
    done
}

automated_script ()
{
    local script rt
    script="$(script_cmdline)"
    if [[ -n "${script}" && ! -x /tmp/startup_script ]]; then
        if [[ "${script}" =~ ^((http|https|ftp)://) ]]; then
            curl "${script}" --location --retry-connrefused --retry 10 -s -o /tmp/startup_script >/dev/null
            rt=$?
        else
            cp "${script}" /tmp/startup_script
            rt=$?
        fi
        if [[ ${rt} -eq 0 ]]; then
            chmod +x /tmp/startup_script
            /tmp/startup_script
        fi
    fi
}

if [[ $(tty) == "/dev/tty1" ]]; then
    automated_script
fi

neofetch
mount -o remount,size=4G /run/archiso/cowspace

DEFAULT_IFACE=`route | grep '^default' | grep -o '[^ ]*$' | head -n 1`
export MAC=`cat /sys/class/net/$DEFAULT_IFACE/address`
envsubst < machine-query.yaml | sponge machine-query.yaml
uor pull go.registry:1338/test:latest --output="/" --attributes=all-query.yaml --insecure --plain-http
uor pull go.registry:1338/test:latest --output="/" --attributes=machine-query.yaml --insecure --plain-http
chmod +x /init.sh
sh /init.sh

