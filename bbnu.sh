#!/bin/bash
cd && clear

echo "TEXT='\E[37;40m NOTE \E[0m'
INFO='\E[37;44m INFO \E[0m'
ERROR='\E[37;41m ERROR \E[0m'
WARN='\E[37;43m WARN \E[0m'
DONE='\E[37;42m DONE \E[0m'
" >/etc/environment

echo "export LS_OPTIONS='--color=auto'
eval \"\$(dircolors)\"
alias ls='ls \$LS_OPTIONS'
alias ll='ls \$LS_OPTIONS -l'
alias la='ls \$LS_OPTIONS -lA'" >.bashrc
[[ -f .bashrc ]] && source .bashrc || . .bashrc
[[ -e /etc/os-release ]] && source /etc/os-release || . /etc/os-release

alignX() {
  [[ $# == 0 ]] && return 1

  declare -i TERM_COLS="$(tput cols)"
  declare -i str_len="${#1}"
  [[ $str_len -ge $TERM_COLS ]] && {
    echo "$1"
    return 0
  }

  declare -i filler_len="$(((TERM_COLS - str_len) / 2))"
  [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
  filler=""
  for ((i = 0; i < filler_len; i++)); do
    filler="${filler}${ch}"
  done

  printf "%s%s%s" "$filler" "$1" "$filler"
  [[ $(((TERM_COLS - str_len) % 2)) -ne 0 ]] && printf "%s" "${ch}"
  printf "\n"

  return 0
}

get_ipaddress() {
  getIPV4=$(hostname -I | cut -d ' ' -f 1)
  echo "IPADDR=${getIPV4}" >>/etc/environment
}

get_domain() {
  read -p " Sila masukkan nama Domain: " getDomain
  echo "DOMAIN=${getDomain}" >>/etc/environment
}

get_email() {
  read -p " Sila masukkan Alamat emel: " getEmail
  echo "EMAIL=${getEmail}" >>/etc/environment
}

get_country() {
  read -p " Sila masukkan nama Negara: " getCountry
  echo "COUNTRY=${getCountry}" >>/etc/environment
}

get_state() {
  read -p " Sila masukkan nama Negeri: " getState
  echo "STATE=${getState}" >>/etc/environment
}

get_region() {
  read -p " Sila masukkan nama Daerah: " getRegion
  echo "REGION=${getRegion}" >>/etc/environment
}

get_organization() {
  read -p " Sila masukkan nama Organisasi: " getOrg
  echo "ORGANIZATION=${getOrg}" >>/etc/environment
}

get_organization_unit() {
  read -p " Sila masukkan nama Unit organisasi: " getOrgUnit
  echo "ORGUNIT=${getOrgUnit}" >>/etc/environment
}

get_common_name() {
  read -p " Sila masukkan nama Samaran: " getName
  echo "CNAME=${getName}" >>/etc/environment
}

ask_questions() {
  get_ipaddress
  get_domain
  get_email
  get_country
  get_state
  get_region
  get_organization
  get_organization_unit
  get_common_name
}
ask_questions

check_shell() {
  if readlink /proc/$$/exe | grep -q "dash"; then
    echo -e " ${ERROR} ✕ ${RESET} This installer needs to be run with \"bash\"."
    exit
  fi
}

check_userid() {
  if [[ "$EUID" -ne 0 ]]; then
    echo -e " ${ERROR} ✕ ${RESET} Installer needs to be run with superuser privileges. "
    exit
  fi
}

check_tunnel() {
  if [[ ! -e /dev/net/tun ]]; then
    echo -e " ${ERROR} ✕ ${RESET} TUN is not available or enabled. "
    exit
  fi
}

check_timezone() {
  echo -e -n " Change timezone... "
  timedatectl set-timezone Asia/Kuala_Lumpur
  ln -sf /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime
  echo -e "${DONE} [ DONE ] ${RESET}"
}

limits_config() {
  echo -e -n " Add new lines limits... "
  echo "* soft nofile 51200
* hard nofile 51200
root soft nofile 51200
root hard nofile 51200" >/etc/security/limits.conf
  ulimit -n 51200
  echo -e "${DONE} [ DONE ] ${RESET}"
}

sysctl_config() {
  echo -e -n " Add new lines sysctl... "
  echo "kernel.domainname = $DOMAIN
fs.file-max = 51200
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.ip_forward=1
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
net.ipv6.conf.eth1.disable_ipv6 = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = hybla" >/etc/sysctl.conf
  echo -e "${DONE} [ DONE ] ${RESET}"
  sysctl -p &>/dev/null
}

hosts_confing() {
  getHostname=$(cat /etc/hostname)
  echo -e -n " Set hostname & domain... "
  echo "127.0.1.1 $getHostname" >/etc/hosts
  echo "127.0.0.1 $getDomain" >>/etc/hosts
  echo -e "${DONE} [ DONE ] ${RESET}"
}

shells_config() {
  echo -e -n " Adding new shells... "
  add-shell /bin/false
  add-shell /usr/bin/false
  add-shell /usr/sbin/nologin
  echo -e "${DONE} [ DONE ] ${RESET}"
}

welcome_message() {
  echo -e -n " Change welcome massage... "
  echo "" >/etc/motd
  wget -q -O /etc/update-motd.d/10-uname 'https://raw.githubusercontent.com/cybertize/buster/advance/sources/banner'
  wget -q -O /etc/issue.net 'https://raw.githubusercontent.com/cybertize/buster/advance/sources/message'
  echo -e "${DONE} [ DONE ] ${RESET}"
}

start_initial() {
  check_shell
  check_distro
  check_userid
  check_tunnel
  check_timezone
  limits_config
  sysctl_config
  hosts_confing
  shells_config
  buster_backports
  welcome_message
}
start_initial

echo -e -n " Updating & Upgrading... "
apt-get -qq update && apt-get -y -qq upgrade &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

echo -e -n " Install pakages & dependencies... "
dependencies=(
  'build-essential'
  'cmake'
  'automake'
  'curl'
  'git'
  'unzip'
  'libnss3'
  'libtool'
  'libssl-dev'
  'libpcre3-dev'
  'libev-dev'
  'asciidoc'
  'xmlto'
  'software-properties-common'
  'apt-transport-https'
  'uuid-runtime'
  'jq'
  'qrencode'
  'xz-utils'
  'gnupg'
  'gnupg1'
  'gnupg2'
  'lsb-release'
  'rng-tools'
)
for dep in "${dependencies[@]}"; do
  apt-get -y -qq install --no-install-recommends $dep &>/dev/null
done
echo -e "${DONE} [ DONE ] ${RESET}"

echo -e -n " fixing rng-tools... "
echo "HRNGDEVICE=/dev/urandom" >>/etc/default/rng-tools
systemctl restart rng-tools &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"
echo

# nginx installation
echo -e -n " Install & Configure nginx... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/nginx.sh && bash nginx.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# dropbear installation
echo -e -n " Install & Configure dropbear... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/dropbear.sh && bash dropbear.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# openvpn installation
echo -e -n " Install & Configure openvpn... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/openvpn.sh && bash openvpn.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# shadowsocks-libev installation
echo -e -n " Install & Configure shadowsocks... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/libev.sh && bash libev.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# trojan installation
echo -e -n " Install & Configure trojan... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/trojan.sh && bash trojan.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# v2ray installation
echo -e -n " Install & Configure v2ray... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/v2ray.sh && bash v2ray.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# xray installation
echo -e -n " Install & Configure xray... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/xray.sh && bash xray.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# wireguard installation
echo -e -n " Install & Configure wireguard... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/wireguard.sh && bash wireguard.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# stunnel installation
echo -e -n " Install & Configure stunnel... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/stunnel.sh && bash stunnel.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# squid installation
echo -e -n " Install & Configure squid... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/squid.sh && bash squid.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# naive installation
echo -e -n " Install & Configure naiveproxy... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/naive.sh && bash naive.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# haproxy installation
echo -e -n " Install & Configure haproxy... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/haproxy.sh && bash haproxy.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# ohpserver installation
echo -e -n " Install & Configure ohpserver... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/ohpserver.sh && bash ohpserver.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# websocket installation
echo -e -n " Install & Configure websocket... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/websocket.sh && bash websocket.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# badvpn installation
echo -e -n " Install & Configure badvpn... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/badvpn.sh && bash badvpn.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# webmin installation
echo -e -n " Install & Configure webmin... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/webmin.sh && bash webmin.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# security installation
echo -e -n " Install & Configure firewall... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/packages/security.sh && bash security.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

# command installation
echo -e -n " Download plugins & commands... "
wget -q https://raw.githubusercontent.com/cybertize/buster/advance/plugins/command.sh && bash command.sh &>/dev/null
echo -e "${DONE} [ DONE ] ${RESET}"

{
  apt-get -qq update
  apt-get -y -qq upgrade
  apt-get -y -qq autoclean
  apt-get -y -qq autocear
} &>/dev/null

echo
alignX "=" "="
alignX " Tahniah, kami telah selesai dengan pemasangan " " "
alignX " pada pelayan anda. Jangan lupa untuk reboot " " "
alignX " sistem pelayan anda terlebih dahulu. " " "
alignX "=" "="
echo
