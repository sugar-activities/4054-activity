#!/bin/sh
# Author:  Bert Freudenberg

# Modified slightly by Milan Zimmermann so Etoys based activities can share this code without changes.

# Notes:

# 1. This describes metadata and executable for Etoys based Sugar activity.
#    An Etoys based Sugar Activity must have supporting classes, which, must look at parameters. 
#    If the parameter ETOYS_ACTIVITY_ID is present, the supporting class knows it is running in context of Sugar.
#    This is a hack, which ensures that SugarLauncher>>startUp does NOT use ACTIVITY_ID and OBJECT_ID
#    to open a new project on top of the project we load 
#    from --document parameter passed to etoys.sh 

# 2. See: SugarBasedActivity.st for FreeCell, and FreeCellLauncher class as an example of the Smalltalk code that creates a Etoys based Sugar activity.

# 3. It would be nice to generalize this script and make it part of etoys.sh

echo Running $0 ... 1 ARGS = $@ > $HOME/HH

# arguments are unordered, have to loop
args=""
while [ -n "$2" ] ; do
    case "$1" in
      	-b | --bundle-id)   bundle_id="$2"   ; args="$args BUNDLE_ID $2" ;;
      	-a | --activity-id) activity_id="$2" ; args="$args ETOYS_ACTIVITY_ID $2";;
      	-o | --object-id)   object_id="$2"   ; args="$args OBJECT_ID $2";;
	-u | --uri)         uri="$2"         ; args="$args URI $2";;
	*) echo unknown argument $1 $2 ;;
    esac
    shift;shift
done

# really need bundle id and activity id
if [ -z "$bundle_id" -o -z "$activity_id" ] ; then
  echo Running $0 ... 3 b=$bundle_id a=$activity_id o=$object_id DOC=$etoysActivityDocumentArg ARGS=$args >> $HOME/HH
  echo ERROR: bundle-id and activity-id arguments required
  echo Aborting
  exit 1
fi

# some debug output
echo launching $bundle_id instance $activity_id
[ -n "$object_id"   ] && echo with journal obj $object_id
[ -n "$uri"         ] && echo loading uri $uri
echo

# sanitize
[ -z "$SUGAR_PROFILE" ] && SUGAR_PROFILE=default
[ -z "$SUGAR_ACTIVITY_ROOT" ] && SUGAR_ACTIVITY_ROOT="$HOME/.sugar/$SUGAR_PROFILE/etoys"

# rainbow-enforced locations
export SQUEAK_SECUREDIR="$SUGAR_ACTIVITY_ROOT/data/private"
export SQUEAK_USERDIR="$SUGAR_ACTIVITY_ROOT/data/MyEtoys"

# make group-writable for rainbow
umask 0002
[ ! -d "$SQUEAK_SECUREDIR" ] && mkdir -p "$SQUEAK_SECUREDIR" && chmod o-rwx "$SQUEAK_SECUREDIR"
[ ! -d "$SQUEAK_USERDIR" ] && mkdir -p "$SQUEAK_USERDIR"

# do not crash on dbus errors
export DBUS_FATAL_WARNINGS=0

  echo Running $0 ... 4 b=$bundle_id a=$activity_id iDOC=$etoysActivityDocumentArg ARGS=$args >> $HOME/HH

# now run Squeak VM with Etoys image and document 
# containing Smalltalk code, for example FreeCell.st
exec etoys \
    -sugarBundleId $bundle_id \
    -sugarActivityId $activity_id \
    --document EtoysBasedActivityCode.st \
    BUNDLE_PATH "$SUGAR_BUNDLE_PATH" \
    MO_PATH "$SUGAR_BUNDLE_PATH/locale" \
    $args
