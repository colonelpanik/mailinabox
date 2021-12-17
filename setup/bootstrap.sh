#!/bin/bash
#########################################################
# This script is intended to be run like this:
#
#   curl https://mailinabox.email/setup.sh | sudo bash
#
#########################################################

if [ -z "$TAG" ]; then
	# If a version to install isn't explicitly given as an environment
	# variable, then install the latest version. But the latest version
	# depends on the operating system.
	# Also, the system status checks read this script for TAG = (without the
	# space, but if we put it in a comment it would confuse the status checks!)
	# to get the latest version, so the first such line must be the one that we
	# want to display in status checks.
	if [ "$(grep -q /Linux release 8/)" -eq 0 ]
		echo "This script must be run on a system running a RHEL/CentOS/Rocky Linux 8 compatible distro"
		exit 1
	fi
fi

# Are we running as root?
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root. Did you leave out sudo?"
	exit 1
fi

# Clone the Mail-in-a-Box repository if it doesn't exist.
if [ ! -d $HOME/mailinabox ]; then
	if [ ! -f /usr/bin/git ]; then
		echo Installing git . . .
		dnf --quiet --assumeyes update
		dnf --quiet --assumeyes git
		echo
	fi

	echo Downloading Mail-in-a-Box $TAG. . .
	git clone \
		-b $TAG --depth 1 \
		https://github.com/colonelpanik/mailinabox \
		$HOME/mailinabox \
		< /dev/null 2> /dev/null

	echo
fi

# Change directory to it.
cd $HOME/mailinabox

# Update it.
if [ "$TAG" != $(git describe) ]; then
	echo Updating Mail-in-a-Box to $TAG . . .
	git fetch --depth 1 --force --prune origin tag $TAG
	if ! git checkout -q $TAG; then
		echo "Update failed. Did you modify something in $(pwd)?"
		exit 1
	fi
	echo
fi

# Start setup script.
setup/start.sh

