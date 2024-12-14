#!/bin/bash

# figure out the absolute path to the script being run a bit
# non-obvious, the ${0%/*} pulls the path out of $0, cd's into the
# specified directory, then uses $PWD to figure out where that
# directory lives - and all this in a subshell, so we don't affect
# $PWD

EXEC_NAME=$(basename "$0" .sh)

GAMEROOT=$(cd "${0%/*}" && echo $PWD)

# determine platform
UNAME=`uname`
if [ "$UNAME" == "Darwin" ]; then
   # Workaround OS X El Capitan 10.11 System Integrity Protection (SIP) which does not allow
   # DYLD_INSERT_LIBRARIES to be set for system processes.
   if [ "$STEAM_DYLD_INSERT_LIBRARIES" != "" ] && [ "$DYLD_INSERT_LIBRARIES" == "" ]; then
      export DYLD_INSERT_LIBRARIES="$STEAM_DYLD_INSERT_LIBRARIES"
   fi
   # prepend our lib path to LD_LIBRARY_PATH
   export DYLD_LIBRARY_PATH="${GAMEROOT}"/bin:$DYLD_LIBRARY_PATH
elif [ "$UNAME" == "Linux" ]; then
	# TF2 requires the sniper container runtime
	. /etc/os-release
	if [ "$VERSION_CODENAME" != "sniper" ]; then
		# a dialog box (zenity?) would be nice, but at this point we do not really know what is available to us
		echo
		echo "FATAL: It appears $EXEC_NAME was not launched within the Steam for Linux sniper runtime environment."
		echo "FATAL: Please consult documentation to ensure correct configuration, aborting."
		echo
		#exit 1
	fi

	# prepend our lib path to LD_LIBRARY_PATH
	export LD_LIBRARY_PATH="${GAMEROOT}"/bin:$LD_LIBRARY_PATH
fi

if [ -z $GAMEEXE ]; then
	if [ "$UNAME" == "Darwin" ]; then
		GAMEEXE="${EXEC_NAME}"_osx
	elif [ "$UNAME" == "Linux" ]; then
		GAMEEXE="${EXEC_NAME}"_linux
		#GAMEEXE="${EXEC_NAME}"_linux64
	fi
fi

ulimit -n 2048

# enable nVidia threaded optimizations
export __GL_THREADED_OPTIMIZATIONS=1

# and launch the game
cd "$GAMEROOT"

# Enable path match if we are running with loose files
if [ -f pathmatch.inf ]; then
	export ENABLE_PATHMATCH=1
fi

# Do the following for strace:
# 	GAME_DEBUGGER="strace -f -o strace.log"

STATUS=42
while [ $STATUS -eq 42 ]; do
	if [ "${GAME_DEBUGGER}" == "gdb" ] || [ "${GAME_DEBUGGER}" == "cgdb" ]; then
		ARGSFILE=$(mktemp $USER.$EXEC_NAME.gdb.XXXX)
		echo b main > "$ARGSFILE"

		# Set the LD_PRELOAD varname in the debugger, and unset the global version. This makes it so that
		#   gameoverlayrenderer.so and the other preload objects aren't loaded in our debugger's process.
		echo set env LD_PRELOAD=$LD_PRELOAD >> "$ARGSFILE"
		echo show env LD_PRELOAD >> "$ARGSFILE"
		unset LD_PRELOAD

		echo run $@ >> "$ARGSFILE"
		echo show args >> "$ARGSFILE"
		${GAME_DEBUGGER} "${GAMEROOT}"/${GAMEEXE} -x "$ARGSFILE"
		rm "$ARGSFILE"
	else
		${GAME_DEBUGGER} "${GAMEROOT}"/${GAMEEXE} "$@"
	fi
	STATUS=$?
done
exit $STATUS
