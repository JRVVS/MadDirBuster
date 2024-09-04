MAD DIRECTORY BUSTER with Gobuster
Version 7.3
Creator: IK IJOMAH
==================================

Overview:
---------
The MAD DIRECTORY BUSTER is a bash script designed to automate directory busting using Gobuster. This tool helps security professionals and enthusiasts discover hidden directories on web servers. The script supports both IP and URL scanning and allows for the use of custom wordlists.

Prerequisites:
--------------
- Gobuster: Ensure that Gobuster is installed on your system. If not installed, the script will prompt you to install it before proceeding.
- Bash: This script is intended to run in a bash shell.

Usage:
------
1. Run the Script:
   $ ./mad_directory_buster.sh

2. Choose Scan Type:
   The script will prompt you to choose whether to scan IPs or URLs:
   - Enter '1' for IP scanning.
   - Enter '2' for URL scanning.

3. Single or Multiple Targets:
   Depending on your choice, the script will ask if you want to scan a single IP/URL or multiple IPs/URLs:
   - For a single target, enter the IP address or URL.
   - For multiple targets, provide the path to a file containing the IPs/URLs.

4. Wordlist Customization:
   Users Can specify custom wordlitst path otherwise, a default wordlist is used.
   The script uses a default wordlist located at:
   wordlist="/home/*****/SecLists/Discovery/Web-Content/directory-list-lowercase-2.3-medium.txt"
   You can change this path directly in the script to use a different wordlist.

5. Threads:
   The script will prompt you to enter the number of threads to use. More threads can speed up the scan but may consume more system resources.

6. Output Directory:
   Specify the directory where the output files will be saved. If the directory doesn't exist, the script will create it.

7. Logs:
   Logs are automatically generated and stored in a 'logs' directory within your specified output directory.

Example:
--------
To run a scan on a single URL with 10 threads and save the results in the '/tmp/results' directory:
$ ./mad_directory_buster.sh
# Follow the prompts:
# 2 (URLs)
# 1 (Single URL)
# http://example.com
# 10 (threads)
# /tmp/results

Notes:
------
- Custom Wordlist: If the default wordlist is not found, the script will prompt you to provide a custom wordlist.
- Log Files: Log files are named based on the date and time the scan is performed.

Author:
-------
- IK Ijomah: Created this script in 2024 to simplify the process of directory busting.
