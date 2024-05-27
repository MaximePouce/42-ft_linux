#!/bin/bash
# This script will check that all dependencies required to start
# building a kernel are installed and in a recent enough version.

# Color coding
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Error codes
SUCCESS=0
COMMAND_FAILURE=1
VERSION_FAILURE=2
PACKAGES_FAILURE=3

exit_code=$SUCCESS

check_version()
{
		ver=$($2 --version | grep -E -o '[0-9]+\.[0-9}+(\.[0-9]+)?[a-z]?' | head -1)
		min_ver=$3

		if printf '%s\n' $min_ver $ver | sort -V --check
		then
				echo -e "${CYAN}$1: Installed version ($ver) is greater or equal than $min_ver${NC}"
		else
				echo -e "${RED}$1: Installed version ($ver) does not match minimum required version ($min_ver)${NC}" 1>&2
				exit_code=$VERSION_FAILURE
		fi
}

packages_file="dependencies.txt"
if [[ ! -f $packages_file ]]; then
	echo -e "${RED}Could not load dependencies from $packages_file.${NC}" 1>&2
	exit $PACKAGES_FAILURE
fi

mapfile -t packages < "$packages_file"

for package in "${packages[@]}"; do
		IFS=' ' read -r package binary min_version <<< "$package"
		if ! command -v "$binary" &>/dev/null; then
				echo -e "${RED}$package is not installed.${NC}" 1>&2
				exit_code=$COMMAND_FAILURE
		else
				check_version $package $binary $min_version
		fi
done

exit $exit_code
