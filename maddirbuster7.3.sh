#!/bin/bash

# MAD DIRECTORY BUSTER with Gobuster
echo "###########################################"
echo "#                                         #"
echo "#        MAD DIRECTORY BUSTER V7.3        #"
echo "#        Creator: IK Ijomah               #"
echo "#        CIRCA August 2024                #"
echo "#                                         #"
echo "###########################################"

# Default wordlist path
default_wordlist="/home/sanlam/SecLists/Discovery/Web-Content/directory-list-lowercase-2.3-medium.txt"

# Check if gobuster is installed
if ! command -v gobuster &> /dev/null; then
    echo "gobuster could not be found. Please install it before running this script."
    exit 1
fi

# User input for scanning choice
echo "Do you want to scan IPs or URLs?"
echo "1) IPs"
echo "2) URLs"
read -p "Enter your choice (1 or 2): " choice

# Function to perform the scan
perform_scan() {
    local target=$1
    local output_file=$2
    local log_file=$3

    # Perform directory busting with Gobuster and tee for logging
    gobuster dir -u $target -w $wordlist -o "$output_file" -t "$threads" -s "200,403" -b "" | tee -a "$log_file"

    if [ $? -eq 0 ]; then
        echo "Scan completed for $target. Results saved in $output_file." | tee -a "$log_file"
    else
        echo "Scan failed for $target." | tee -a "$log_file"
    fi
}

# Function to sanitize URL for filename
sanitize_url() {
    echo $1 | sed 's|https\?://||' | sed 's|/|_|g'
}

# Function to display scan progress
display_progress() {
    local current=$1
    local total=$2
    local percent=$(( 100 * current / total ))
    echo -ne "Progress: $percent% ($current/$total) completed\r"
}

# Function to prompt for changing the default wordlist path
change_default_wordlist() {
    attempts=0
    while [ $attempts -lt 5 ]; do
        read -p "Enter the new path for the default wordlist: " new_wordlist
        if [ -f "$new_wordlist" ]; then
            default_wordlist="$new_wordlist"
            echo "Default wordlist changed to: $default_wordlist"
            break
        else
            echo "Wordlist file not found. Please try again."
        fi
        ((attempts++))
    done

    if [ $attempts -ge 5 ]; then
        echo "Maximum attempts reached. Exiting."
        exit 1
    fi
}

# Handle IP scanning
if [ "$choice" == "1" ]; then
    echo "Do you want to scan a single IP or multiple IPs?"
    echo "1) Single IP"
    echo "2) Multiple IPs"
    read -p "Enter your choice (1 or 2): " ip_choice

    if [ "$ip_choice" == "1" ]; then
        attempts=0
        while [ $attempts -lt 5 ]; do
            read -p "Enter the IP address: " single_ip

            # Validate single IP
            if [[ $single_ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && [[ ! $single_ip =~ 25[6-9]|2[6-9][0-9]|[3-9][0-9]{2} ]]; then
                # Resolve DNS name
                dns_name=$(dig +short -x $single_ip | sed 's/\.$//')
                if [ -z "$dns_name" ]; then
                    dns_name=$single_ip
                fi
                break
            else
                echo "Invalid IP address format. Please try again."
            fi
            ((attempts++))
        done

        if [ $attempts -ge 5 ]; then
            echo "Maximum attempts reached. Exiting."
            exit 1
        fi

    elif [ "$ip_choice" == "2" ]; then
        attempts=0
        while [ $attempts -lt 5 ]; do
            read -p "Enter the path to the file containing IP addresses: " ip_file

            # Check if IP file exists
            if [ -f "$ip_file" ]; then
                break
            else
                echo "IP file not found. Please try again."
            fi
            ((attempts++))
        done

        if [ $attempts -ge 5 ]; then
            echo "Maximum attempts reached. Exiting."
            exit 1
        fi
    fi

# Handle URL scanning
elif [ "$choice" == "2" ]; then
    echo "Do you want to scan a single URL or multiple URLs?"
    echo "1) Single URL"
    echo "2) Multiple URLs"
    read -p "Enter your choice (1 or 2): " url_choice

    if [ "$url_choice" == "1" ]; then
        read -p "Enter the URL: " single_url

        # Sanitize URL for filename
        url_name=$(sanitize_url "$single_url")

    elif [ "$url_choice" == "2" ]; then
        attempts=0
        while [ $attempts -lt 5 ]; do
            read -p "Enter the path to the file containing URLs: " url_file

            # Check if URL file exists
            if [ -f "$url_file" ]; then
                break
            else
                echo "URL file not found. Please try again."
            fi
            ((attempts++))
        done

        if [ $attempts -ge 5 ]; then
            echo "Maximum attempts reached. Exiting."
            exit 1
        fi
    fi
fi

# Ask user to use the default wordlist or custom wordlist
attempts=0
while [ $attempts -lt 5 ]; do
    read -p "Do you want to use the default wordlist? (y/n): " use_default
    if [ "$use_default" == "y" ]; then
        # Check if the default wordlist exists
        if [ -f "$default_wordlist" ]; then
            wordlist="$default_wordlist"
            break
        else
            echo "Default wordlist not found. You must specify a custom wordlist."
            use_default="n"
        fi
    fi

    if [ "$use_default" == "n" ]; then
        read -p "Enter the path to the custom wordlist: " wordlist
        if [ -f "$wordlist" ]; then
            break
        else
            echo "Wordlist file not found. Please try again."
        fi
    fi

    if [ "$use_default" == "change" ]; then
        change_default_wordlist
        wordlist="$default_wordlist"
        break
    fi
    ((attempts++))
done

if [ $attempts -ge 5 ]; then
    echo "Maximum attempts reached. Exiting."
    exit 1
fi

# Ask for the number of threads
read -p "Enter the number of threads to use: " threads

# Ask for the output directory
read -p "Enter the path for the output directory: " output_dir

# Create output and log directories if they don't exist
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
    echo "Created output directory: $output_dir"
fi
log_dir="$output_dir/logs"
if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"
    echo "Created log directory: $log_dir"
fi

# Log file based on current date-time
log_file="$log_dir/$(date +'%Y-%m-%d_%H-%M-%S')-log.txt"

# Execute the scan
if [ "$choice" == "1" ]; then
    if [ "$ip_choice" == "1" ]; then
        result_file="$output_dir/${dns_name// /_}-results.txt"
        perform_scan "http://$single_ip" "$result_file" "$log_file"
        display_progress 1 1
    elif [ "$ip_choice" == "2" ]; then
        total_ips=$(wc -l < "$ip_file")
        current_ip=0
        while read -r IP; do
            if [ -z "$IP" ]; then
                echo "Skipping empty IP entry." | tee -a "$log_file"
                continue
            fi

            # Validate IP
            if [[ $IP =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && [[ ! $IP =~ 25[6-9]|2[6-9][0-9]|[3-9][0-9]{2} ]]; then
                dns_name=$(dig +short -x $IP | sed 's/\.$//')
                if [ -z "$dns_name" ]; then
                    dns_name=$IP
                fi
                result_file="$output_dir/${dns_name// /_}-results.txt"
                perform_scan "http://$IP" "$result_file" "$log_file"
                ((current_ip++))
                display_progress $current_ip $total_ips
            else
                echo "Invalid IP address format: $IP. Skipping." | tee -a "$log_file"
            fi
        done < "$ip_file"
    fi
elif [ "$choice" == "2" ]; then
    if [ "$url_choice" == "1" ]; then
        result_file="$output_dir/${url_name}-results.txt"
        perform_scan "$single_url" "$result_file" "$log_file"
        display_progress 1 1
    elif [ "$url_choice" == "2" ]; then
        total_urls=$(wc -l < "$url_file")
        current_url=0
        while read -r URL; do
            if [ -z "$URL" ]; then
                echo "Skipping empty URL entry." | tee -a "$log_file"
                continue
            fi
            url_name=$(sanitize_url "$URL")
            result_file="$output_dir/${url_name}-results.txt"
            perform_scan "$URL" "$result_file" "$log_file"
            ((current_url++))
            display_progress $current_url $total_urls
        done < "$url_file"
    fi
fi

echo -ne "\n"
echo "Scan process completed. Logs can be found in $log_file"
