#!/bin/bash


usage()
{
    MYNAME=`basename $0`
    cat <<FIN

$MYNAME - copies EXIF GPS tags from source to other files (needs exiv2)

Usage:
$MYNAME --from FILE FILE..             : copies \$location from FILE into FILE..

FIN
}


if [ "0$NODEBUG" -ne 0 ]; then
    alias _exiv2='exiv2'
else
    echo
    echo '*** DEBUG ***'
    echo
    alias _exiv2='echo exiv2'
fi
shopt -s expand_aliases


case "$1" in
    --from) FROM="$2"; shift 2;;
    --help|-h|"") usage; exit 0 ;;
esac


LATREF=`exiv2 -Pv -K Exif.GPSInfo.GPSLatitudeRef "$FROM" 2>/dev/null || echo`
LAT=`exiv2 -Pv -K Exif.GPSInfo.GPSLatitude "$FROM" 2>/dev/null || echo`
LONREF=`exiv2 -Pv -K Exif.GPSInfo.GPSLongitudeRef "$FROM" 2>/dev/null || echo`
LON=`exiv2 -Pv -K Exif.GPSInfo.GPSLongitude "$FROM" 2>/dev/null || echo`
ALTREF=`exiv2 -Pv -K Exif.GPSInfo.GPSAltitudeRef "$FROM" 2>/dev/null || echo`
ALT=`exiv2 -Pv -K Exif.GPSInfo.GPSAltitude "$FROM" 2>/dev/null || echo`


if [  "0$NODEBUG" -eq 0 ]; then
    echo "LAT=${LAT[@]} LATREF=$LATREF"
    echo "LON=${LON[@]} LONREF=$LONREF"
    echo "ALT=${ALT[@]} ALTREF=$ALTREF"
fi

if [ -n "$LAT" -a -n "$LON" ]; then
_exiv2 -k \
    -M"set Exif.GPSInfo.GPSLatitudeRef $LATREF" \
    -M"set Exif.GPSInfo.GPSLatitude ${LAT[*]}" \
    -M"set Exif.GPSInfo.GPSLongitudeRef $LONREF" \
    -M"set Exif.GPSInfo.GPSLongitude ${LON[*]}" \
    "$@"
fi

if [ -n "$ALT" ]; then
_exiv2 -k \
    -M"set Exif.GPSInfo.GPSAltitudeRef $ALTREF" \
    -M"set Exif.GPSInfo.GPSAltitude ${ALT[*]}" \
    "$@"
fi

