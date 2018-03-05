#!/bin/bash


usage()
{
    MYNAME=`basename $0`
    cat <<FIN

$MYNAME - sets EXIF GPS tags for image/video files (needs exiv2)

Usage:
$MYNAME --\$location FILE..            : sets \$location (from locations.sh) for FILE..
or
$MYNAME --manual FILE..               : sets manually entered (needs zenity) location for FILE..
or
ln -s $0 set-exif-gps-\$location
./set-exif-gps-\$location FILE         : sets \$location (from locations.sh) for FILE..

FIN
}


if [ "0$DEBUG" -ne 0 ]; then
    echo
    echo '*** DEBUG ***'
    echo
    alias _exiv2='echo exiv2'
else
    alias _exiv2='exiv2'
fi
shopt -s expand_aliases


. "`dirname $0`/locations.sh"
if [ $? -ne 0 ]; then
    echo "'locations.sh' must be in the same directory as this script (i.e. '`dirname $0`')." >&2
    exit 1
fi

case "$1" in
    --help|-h|"") usage; exit 0 ;;
    --*) LATLON=`set_location ${1#--}`; shift ;;
esac
case "$0" in
    *set-exif-gps-*) ME=${0%.sh}; ME=${ME/*set-exif-gps-}; LATLON="`set_location $ME`" ;;
esac


case "$LATLON" in
    # 00°00'00.0"S 00°00'00.0"W format
    *[0-9]\°[0-9]*\'[0-9]*.[0-9]*\"[SN]\ *[0-9]\°[0-9]*\'*[0-9].[0-9]*\"[WE])
        read LATDEG LATMIN LATSEC LATREF LONDEG LONMIN LONSEC LONREF <<<`echo "$LATLON" | awk -F"[°'\" ]" '
            {
                latsecden=10^(length($3)-index($3,"."))
                lonsecden=10^(length($7)-index($7,"."))
                
                gsub(/\./,"",$3)
                gsub(/\./,"",$7)

                printf "%s/1 %s/1 %s/%s %s %s/1 %s/1 %s/%s %s\n", $1, $2, $3, latsecden, $4, $5, $6, $7, lonsecden, $8
            }
        '`
        LAT=($LATDEG $LATMIN $LATSEC)
        LON=($LONDEG $LONMIN $LONSEC)
    ;;
    # -00.00000, -00.000 format
    [-+\ 0-9][0-9]*.*[0-9]\,\ [-+\ 0-9][0-9]*.*[0-9])
        read LATDEG LATMIN LATSEC LATREF LONDEG LONMIN LONSEC LONREF <<<`echo "$LATLON" | awk -F', *' '
            BEGIN { SN="N"; WE="E" }
            $1 ~ /^-/ { SN="S" }
            $2 ~ /^-/ { WE="W" }
            {
                sub(/^-/,"",$1)
                sub(/^-/,"",$2)
                latden=10^(length($1)-index($1,"."))
                londen=10^(length($2)-index($2,"."))
                gsub(/\./,"",$1)
                gsub(/\./,"",$2)

                printf "%s/%s 0/1 0/1 %s %s/%s 0/1 0/1 %s\n", $1, latden, SN, $2, londen, WE
            }
        '`
        LAT=($LATDEG $LATMIN $LATSEC)
        LON=($LONDEG $LONMIN $LONSEC)
    ;;
    *) exit 1 ;;
esac

if [ -n "$DEBUG" ]; then
    echo "LATLON=$LATLON"
    echo "LAT=${LAT[@]} LATREF=$LATREF"
    echo "LON=${LON[@]} LONREF=$LONREF"
fi

if [ -n "$LAT" -a -n "$LON" ]; then
_exiv2 -k \
    -M"set Exif.GPSInfo.GPSLatitudeRef $LATREF" \
    -M"set Exif.GPSInfo.GPSLatitude ${LAT[*]}" \
    -M"set Exif.GPSInfo.GPSLongitudeRef $LONREF" \
    -M"set Exif.GPSInfo.GPSLongitude ${LON[*]}" \
    "$@"
fi

