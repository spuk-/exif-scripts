set_location()
{
    local LATLON

    case "$1" in
                         manual)  LATLON=`zenity --text="Formatted as 15°48'08.1\"S 47°54'41.7\"W or -15.802248, -47.911572" --entry` ;;
                           test)  LATLON="-15.802248, -47.911572" ;;
                          test2)  LATLON="15°48'08.1\"S 47°54'41.7\"W" ;;
                              *)  exit 1  ;;
    esac

    echo "$LATLON"
}

