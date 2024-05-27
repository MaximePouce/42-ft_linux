#!/bin/bash
# This script will install all dependencies required to start
# building a kernel in their latest available version.

packages_file="dependencies.txt"
if [[ ! -f $packages_file ]]; then
	echo -e "${RED}Could not load dependencies from $packages_file.${NC}" 1>&2
	exit $PACKAGES_FAILURE
fi

mapfile -t packages < "$packages_file"

for package in "${packages[@]}"; do
	IFS=' ' read -r package binary min_version <<< "$package"
	apt-get install $(echo $package | awk '{print tolower($0)}') -y
done

