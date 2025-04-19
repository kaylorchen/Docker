#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#
# Dynamic Domain Name Server (Cloudflare API)
#
# Author: StarryVoid <stars@starryvoid.com>
# Intro:  https://blog.starryvoid.com/archives/313.html
# Build:  2020/04/26
#

# Select API(1) Or Token(2)
SelectAT="1"

# CloudFlare API " X-Auth-Email: *** " " X-Auth-Key: *** "
XAUTHEMAIL="$EMAIL"
XAUTHKEY="$API_KEY"

# CloudFlare Token " Authorization: Bearer *** "
AuthorizationToken="YOURTOKEN"

# Domain Name " example.com " " ddns.example.com "
ZONENAME="$ZONE_NAME"
DOMAINNAME="$DOMAIN_NAME"
DOMAINTTL="1"

# Output
OUTPUTINFO="/root/ddns_output.info"
OUTPUTLOG="/root/ddns_shell.log"

# Time
DATETIME=$(date +%Y-%m-%d_%H:%M:%S)

# ------------ Start ------------

check_environment () {
    if ! [ -x "$(command -v curl)" ]; then echo "Command not found \"curl\"" >> "${OUTPUTLOG}" ; exit 1 ; fi
    if ! [ -x "$(command -v wget)" ]; then echo "Command not found \"wget\"" >> "${OUTPUTLOG}" ; exit 1 ; fi
}

check_selectAT () {
    if [[ ! "${SelectAT}" = 1 && ! "${SelectAT}" = 2 ]]; then echo "Failed to Select API(1) Or Token(2)" >> "${OUTPUTLOG}"; exit 1; fi
}

get_zone_records() {
    if [ "${SelectAT}" = 1 ]; then ZONERECORDSLOG=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${ZONENAME}" -H "X-Auth-Email: ${XAUTHEMAIL}" -H "X-Auth-Key: ${XAUTHKEY}" -H "Content-Type: application/json" --connect-timeout 30 -m 10 ); fi
    if [ "${SelectAT}" = 2 ]; then ZONERECORDSLOG=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${ZONENAME}" -H "Authorization: Bearer ${AuthorizationToken}" -H "Content-Type: application/json" --connect-timeout 30 -m 10 ); fi
    ZONERECORDS=$(echo "${ZONERECORDSLOG}" | awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}' | sed 's/ //g' | grep '"id":"[a-f0-9]*' -o | head -1 | grep -o ':"[a-f0-9]*[a-f0-9]' | grep -o '[a-f0-9]*[a-f0-9]' )
    if [ ! "${ZONERECORDS}" ]; then echo "Failed to get zone_records from cloudflare." >> "${OUTPUTLOG}" ; echo "---log---" >> "${OUTPUTLOG}" ; echo "${ZONERECORDSLOG}" >> "${OUTPUTLOG}" ; echo "---log---" >> "${OUTPUTLOG}" ; exit 1; fi
}

get_dns_records() {
    if [ "${SelectAT}" = 1 ]; then DNSRECORDSLOG=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONERECORDS}/dns_records?type=A&name=${DOMAINNAME}" -H "X-Auth-Email: ${XAUTHEMAIL}" -H "X-Auth-Key: ${XAUTHKEY}" -H "Content-Type: application/json" --connect-timeout 30 -m 10 ); fi
    if [ "${SelectAT}" = 2 ]; then DNSRECORDSLOG=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONERECORDS}/dns_records?type=A&name=${DOMAINNAME}" -H "Authorization: Bearer ${AuthorizationToken}" -H "Content-Type: application/json" --connect-timeout 30 -m 10 ); fi
    DNSRECORDS=$(echo "${DNSRECORDSLOG}" | awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}' | sed 's/ //g' | grep '"id":"[a-f0-9]*' -o | head -1 | grep -o ':"[a-f0-9]*[a-f0-9]' | grep -o '[a-f0-9]*[a-f0-9]' )
    if [ ! "${DNSRECORDS}" ]; then echo "Failed to get dns_records from cloudflare." >> "${OUTPUTLOG}"; echo "---log---" >> "${OUTPUTLOG}" ; echo "${DNSRECORDSLOG}" >> "${OUTPUTLOG}" ; echo "---log---" >> "${OUTPUTLOG}" ; exit 1; fi
}

get_domain_ip() {
    if [ "${SelectAT}" = 1 ]; then DOMAINIPADDLOG=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONERECORDS}/dns_records/${DNSRECORDS}" -H "X-Auth-Email: ${XAUTHEMAIL}" -H "X-Auth-Key: ${XAUTHKEY}" -H "Content-Type: application/json" --connect-timeout 30 -m 10 ); fi
    if [ "${SelectAT}" = 2 ]; then DOMAINIPADDLOG=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONERECORDS}/dns_records/${DNSRECORDS}" -H "Authorization: Bearer ${AuthorizationToken}" -H "Content-Type: application/json" --connect-timeout 30 -m 10 ); fi
   # DOMAINIPADD=$(echo "${DOMAINIPADDLOG}" | awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}' | sed 's/ //g' | grep -o '(?<="content":")[^"]*' | head -1 )
   DOMAINIPADD=$(echo "${DOMAINIPADDLOG}" | grep content | awk -F "content\"\:\"" '{print $2}' | awk -F "\"" '{print $1}' )
   # echo "${DOMAINIPADDLOG}" | grep content
    if [ ! "${DOMAINIPADD}" ]; then echo "Failed to get DNS resolution address from cloudflare." >> "${OUTPUTLOG}"; echo "---log---" >> "${OUTPUTLOG}" ; echo "${DOMAINIPADDLOG}" >> "${OUTPUTLOG}" ; echo "---log---" >> "${OUTPUTLOG}" ; exit 1; fi
}

update_new_ipaddress() {
    if [ "${SelectAT}" = 1 ]; then curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONERECORDS}/dns_records/${DNSRECORDS}" -H "X-Auth-Email: ${XAUTHEMAIL}" -H "X-Auth-Key: ${XAUTHKEY}" -H "Content-Type: application/json"  --data "{\"type\":\"A\",\"name\":\"${DOMAINNAME}\",\"content\":\"${NEWIPADD}\",\"ttl\":"${DOMAINTTL}",\"proxied\":false}" --connect-timeout 30 -m 10 > /dev/null 2>&1 && UPDATENEWIPADDRESS=1 || UPDATENEWIPADDRESS=0; fi
    if [ "${SelectAT}" = 2 ]; then curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONERECORDS}/dns_records/${DNSRECORDS}" -H "Authorization: Bearer ${AuthorizationToken}" -H "Content-Type: application/json"  --data "{\"type\":\"A\",\"name\":\"${DOMAINNAME}\",\"content\":\"${NEWIPADD}\",\"ttl\":"${DOMAINTTL}",\"proxied\":false}" --connect-timeout 30 -m 10 > /dev/null 2>&1 && UPDATENEWIPADDRESS=1 || UPDATENEWIPADDRESS=0; fi
    if [ "${UPDATENEWIPADDRESS}" = 1 ] ; then echo "Successfully updated domain name resolution address." >> "${OUTPUTLOG}" ; fi
    if [ "${UPDATENEWIPADDRESS}" = 0 ] ; then echo "Failed to updated domain name resolution address." >> "${OUTPUTLOG}" ; exit 1 ; fi
}

get_server_new_ip() {
    # ipset add cniplist 45.249.247.246
    # ipset add cniplist 134.122.130.183
    # [ -z "${NEWIPADD}" ] && NEWIPADD=$( wget -qO- -t1 -T2 https://www.fbisb.com/ip.php )
    # [ -z "${NEWIPADD}" ] && NEWIPADD=$( curl  -s www.ip111.cn  |grep China |awk -F ' ' '{print $1}' )
    # [ -z "${NEWIPADD}" ] && NEWIPADD=$( ip address | grep pppoe | grep inet | awk -F ' ' '{print $2}' )
    [ -z "${NEWIPADD}" ] && NEWIPADD=$(curl -4 ipinfo.io/ip)
    echo "new ip is ${NEWIPADD}"
    if [[ ! "${NEWIPADD}" ]]; then echo "Failed to get server public network address from internet." >> "${OUTPUTLOG}"; exit 1; fi
}

check_ddns_info_file() {
    if [ -f "${OUTPUTINFO}" ]; then
        CHECKDDNSINFOFILE=1
        ZONERECORDS=$(cat < "${OUTPUTINFO}" | grep "ZONERECORDS=" | awk -F "=" '{print $2}' | sed 's/\"//g' | sed "s/\'//g" )
        DNSRECORDS=$(cat < "${OUTPUTINFO}" | grep "DNSRECORDS=" | awk -F "=" '{print $2}' | sed 's/\"//g' | sed "s/\'//g" )
        DOMAINIPADD=$(cat < "${OUTPUTINFO}" | grep "DOMAINIPADD=" | awk -F "=" '{print $2}' | sed 's/\"//g' | sed "s/\'//g" )
        if [[ ! "${ZONERECORDS}" ]]; then CHECKDDNSINFOFILE=0 ; fi
        if [[ ! "${DNSRECORDS}" ]]; then CHECKDDNSINFOFILE=0 ; fi
        if [[ ! "${DOMAINIPADD}" ]]; then CHECKDDNSINFOFILE=0 ; fi
    else
        CHECKDDNSINFOFILE=0
    fi
    if [ "${CHECKDDNSINFOFILE}" = 0 ] ; then echo "Failed to check DDNS information file." >> "${OUTPUTLOG}" ; rm -f "${OUTPUTINFO}" ; exit 1 ; fi
}

make_ddns_info_file() {
    if [ -f "${OUTPUTINFO}" ] ; then rm -f "${OUTPUTINFO}" ; fi
    touch "${OUTPUTINFO}"
    echo Update Time is "${DATETIME}" >> "${OUTPUTINFO}"
    get_zone_records
    get_dns_records
    get_domain_ip
    echo -e "ZONERECORDS=\"${ZONERECORDS}\"\nDNSRECORDS=\"${DNSRECORDS}\"\nDOMAINIPADD=\"${DOMAINIPADD}\"" >> "${OUTPUTINFO}"
    echo "Successfully generated DDNS information." >> "${OUTPUTLOG}"
}

main() {
    check_environment
    check_selectAT
    echo "Running Time is ${DATETIME}" >> "${OUTPUTLOG}"
    get_server_new_ip
    if [ -f "${OUTPUTINFO}" ]; then
        check_ddns_info_file
    else
        make_ddns_info_file
    fi
    if [[ "${NEWIPADD}" == "${DOMAINIPADD}" ]]; then
        echo "IP address has not changed." >> "${OUTPUTLOG}"
        exit 0
    else
        update_new_ipaddress
        sleep 10s
        make_ddns_info_file
        if [[ "${NEWIPADD}" == "${DOMAINIPADD}" ]]; then
            echo "IP address has been modified to \"${NEWIPADD}\"." >> "${OUTPUTLOG}"
            exit 0
        else
            echo "IP address modification failed." >> "${OUTPUTLOG}"
            exit 1
        fi
    fi
}

# ------------ End ------------

while true; do
    main
    # get_server_new_ip
    sleep 300  # 300秒 = 5分钟
done