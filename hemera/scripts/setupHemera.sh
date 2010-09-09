#!/bin/bash
#
# Author: Bertrand BENOIT <bertrand.benoit@bsquare.no-ip.org>
# Version: 1.0
# Description: setups Hemera.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
source "$installDir/scripts/utilities.sh"

category="setup"
sysconfigFile="/etc/sysconfig/hemera"
profileFile="/etc/profile.d/hemera"
configurationFile="$installDir/config/hemera.conf"

#########################
## INSTRUCTIONS
# Ensures user is root.
[ "$( whoami )" != "root" ] && errorMessage "Setup must be launched by root superuser."

writeMessage "Defined installDir=$installDir"

# Writes the sysconfig file.
writeMessage "Managing System configuration file '$sysconfigFile' ... " 0
if [ -f "$sysconfigFile" ]; then
  echo "ignored (already exist)."
else
cat > $sysconfigFile << End-of-Message
# Installation directory.
installDir="$installDir"
End-of-Message

  echo "created."
fi

# Writes the profile file.
writeMessage "Managing Profile file '$profileFile' ... " 0
if [ -f "$profileFile" ]; then
  echo "ignored (already exist)."
else
cat > $profileFile << End-of-Message
#!/bin/bash

# Ensures the configuration file exists.
if [ -f "$sysconfigFile" ]; then
  # Gets installation directory.
  source "$sysconfigFile"
  
  # Updates the path.
  source "$installDir/scripts/hemeraPath.sh"
fi
End-of-Message
  chmod +x "$profileFile"
  
  echo "created."

  writeMessage "Hemera main binary/script will be available after next reboot (source $profileFile for immediate effect in your shell)."
fi

# Checks if Hemera has been configured.
[ ! -f "$configurationFile" ] && writeMessage "You might begin configuring Hemera creating $configurationFile file from sample."
