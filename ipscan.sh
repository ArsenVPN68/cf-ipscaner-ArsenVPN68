#!/bin/bash


ip_to_decimal() {
    local ip="$1"
    local a b c d
    IFS=. read -r a b c d <<< "$ip"
    echo "$((a * 256**3 + b * 256**2 + c * 256 + d))"
}


decimal_to_ip() {
    local dec="$1"
    local a=$((dec / 256**3 % 256))
    local b=$((dec / 256**2 % 256))
    local c=$((dec / 256 % 256))
    local d=$((dec % 256))
    echo "$a.$b.$c.$d"
}


measure_latency() {
    local ip=$1
    local latency=$(ping -c 1 -W 1 "$ip" | grep 'time=' | awk -F'time=' '{ print $2 }' | cut -d' ' -f1)
    if [ -z "$latency" ]; then
        latency="N/A"
    fi
    printf "%s %s\n" "$ip" "$latency"
}


generate_ips_in_cidr() {
    local cidr="$1"
    local base_ip=$(echo "$cidr" | cut -d'/' -f1)
    local prefix=$(echo "$cidr" | cut -d'/' -f2)
    local ip_dec=$(ip_to_decimal "$base_ip")
    local range_size=$((2 ** (32 - prefix)))
    local ips=()

    for ((i=0; i<range_size; i++)); do
        ips+=("$(decimal_to_ip $((ip_dec + i)))")
    done

    echo "${ips[@]}"
}

check_and_install() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 not found, installing..."
        pkg install -y $2
    else
        echo "$1 is already installed."
    fi
}


check_and_install ping inetutils
check_and_install awk coreutils
check_and_install grep grep
check_and_install cut coreutils
check_and_install curl curl
check_and_install bc bc


IP_RANGES=(
"104.28.94.0/24" "104.28.95.0/24" "104.28.96.0/24"
"104.28.97.0/24" "104.28.98.0/24" "104.28.99.0/24"
"104.28.100.0/24" "104.28.101.0/24" "104.28.102.0/24"
"104.28.103.0/24" "104.28.104.0/24" "104.28.105.0/24"
"104.28.106.0/24" "104.28.107.0/24" "104.28.108.0/24"
"104.28.109.0/24" "104.28.110.0/24" "104.28.111.0/24"
"104.28.112.0/24" "104.28.113.0/24" "104.28.114.0/24"
"104.28.115.0/24" "104.28.116.0/24" "104.28.117.0/24"
"104.28.118.0/24" "104.28.119.0/24" "104.28.120.0/24"
"104.28.121.0/24" "104.28.122.0/24" "104.28.123.0/24"
"104.28.124.0/24" "104.28.125.0/24" "104.28.126.0/24"
"104.28.127.0/24" "104.28.128.0/24" "104.28.129.0/24"
"104.28.130.0/24" "104.28.131.0/24" "104.28.132.0/24"
"104.28.133.0/24" "104.28.134.0/24" "104.28.135.0/24"
"104.28.144.0/24" "104.28.145.0/24" "104.28.146.0/24"
"104.28.147.0/24" "104.28.148.0/24" "104.28.149.0/24"
"104.28.150.0/24" "104.28.151.0/24" "104.28.152.0/24"
"104.28.153.0/24" "104.28.154.0/24" "104.28.155.0/24"
"104.28.156.0/24" "104.28.157.0/24" "104.28.158.0/24"
"104.28.159.0/24" "104.28.192.0/24" "104.28.193.0/24"
"104.28.194.0/24" "104.28.195.0/24" "104.28.196.0/24"
"104.28.197.0/24" "104.28.198.0/24" "104.28.199.0/24"
"104.28.200.0/24" "104.28.201.0/24" "104.28.202.0/24"
"104.28.203.0/24" "104.28.204.0/24" "104.28.205.0/24"
"104.28.206.0/24" "104.28.207.0/24" "104.28.208.0/24"
"104.28.209.0/24" "104.28.210.0/24" "104.28.211.0/24"
"104.28.212.0/24" "104.28.213.0/24" "104.28.214.0/24"
"104.28.215.0/24" "104.28.216.0/24" "104.28.217.0/24"
"104.28.218.0/24" "104.28.219.0/24" "104.28.220.0/24"
"104.28.221.0/24" "104.28.222.0/24" "104.28.223.0/24"
"104.28.224.0/24" "104.28.225.0/24" "104.28.226.0/24"
"104.28.227.0/24" "104.28.228.0/24" "104.28.229.0/24"
"104.28.230.0/24" "104.28.231.0/24" "104.28.232.0/24"
)


fetch_additional_ips() {
    local needed_ips=$1
    local ip_ranges=("${@:2}")

    local ips=()
    for range in "${ip_ranges[@]}"; do
        ips+=($(generate_ips_in_cidr "$range"))
        if [[ ${#ips[@]} -ge $needed_ips ]]; then
            break
        fi
    done

    echo "${ips[@]}"
}


show_progress() {
    local current=$1
    local total=$2
    local percent=$(( 100 * current / total ))
    local progress=$(( current * 50 / total ))
    local green=$(( progress ))
    local red=$(( 50 - progress ))

    
    printf "\r["
    printf "\e[42m%${green}s\e[0m" | tr ' ' '='
    printf "\e[41m%${red}s\e[0m" | tr ' ' '='
    printf "] %d%%" "$percent"
}


SELECTED_IP_RANGES=($(shuf -e "${IP_RANGES[@]}" -n 10))
echo "Selected IP Ranges: ${SELECTED_IP_RANGES[@]}"


SELECTED_IPS=()
for range in "${SELECTED_IP_RANGES[@]}"; do
    ips=($(generate_ips_in_cidr "$range"))
    SELECTED_IPS+=("${ips[@]}")
done


SHUFFLED_IPS=($(shuf -e "${SELECTED_IPS[@]}" -n 100))


display_table_ipv4() {
    printf "+-----------------------+------------+\n"
    printf "| IP                    | Latency(ms) |\n"
    printf "+-----------------------+------------+\n"
    echo "$1" | head -n 10 | while read -r ip latency; do
        if [ "$latency" == "N/A" ]; then
            
            continue
        fi
        printf "| %-21s | %-10s |\n" "$ip" "$latency"
    done
    printf "+-----------------------+------------+\n"
}


valid_ips=()
total_ips=${#SHUFFLED_IPS[@]}
processed_ips=0

while [[ ${#valid_ips[@]} -lt 10 ]]; do
    
    ping_results=$(printf "%s\n" "${SHUFFLED_IPS[@]}" | xargs -I {} -P 10 bash -c '
    measure_latency() {
        local ip="$1"
        local latency=$(ping -c 1 -W 1 "$ip" | grep "time=" | awk -F"time=" "{ print \$2 }" | cut -d" " -f1)
        if [ -z "$latency" ]; then
            latency="N/A"
        fi
        printf "%s %s\n" "$ip" "$latency"
    }
    measure_latency "$@"
    ' _ {})

    
    valid_ips=($(echo "$ping_results" | grep -v "N/A" | awk '{print $1}'))

    processed_ips=$((${#valid_ips[@]} + ${#SHUFFLED_IPS[@]} - $total_ips))
    show_progress $processed_ips $total_ips

    if [[ ${#valid_ips[@]} -lt 10 ]]; then
        echo -e "\nNot enough valid IPs found. Selecting more IP ranges..."
        additional_ips=($(fetch_additional_ips $((100 - ${#valid_ips[@]})) "${IP_RANGES[@]}"))
        SHUFFLED_IPS=($(shuf -e "${additional_ips[@]}" -n 100))
        total_ips=${#SHUFFLED_IPS[@]}
        processed_ips=0
    fi
done


clear
echo -e "\e[1;35m*****************************************"
echo -e "\e[1;35m*\e[0m \e[1;31mY\e[1;32mO\e[1;33mU\e[1;34mT\e[1;35mU\e[1;36mB\e[1;37mE\e[0m : \e[4;34mKOLANDONE\e[0m         \e[1;35m"
echo -e "\e[1;35m*\e[0m \e[1;31mT\e[1;32mE\e[1;33mL\e[1;34mE\e[1;35mG\e[1;36mR\e[1;37mA\e[1;31mM\e[0m : \e[4;34mKOLANDJS\e[0m         \e[1;35m"
echo -e "\e[1;35m*\e[0m \e[1;31mG\e[1;32mI\e[1;33mT\e[1;34mH\e[1;35mU\e[1;36mB\e[0m : \e[4;34mhttps://github.com/Kolandone\e[0m \e[1;35m"
echo -e "\e[1;35m*****************************************\e[0m"
echo ""

show_progress $total_ips $total_ips
echo -e "\n"


echo -e "\e[1;32mDisplaying top 10 IPs with valid latency...\e[0m"
display_table_ipv4 "$ping_results"


comma_separated_ips=$(IFS=,; echo "${valid_ips[*]}")
echo -e "\e[1;33mDisplaying all valid IPs:\e[0m"
echo "$comma_separated_ips"

