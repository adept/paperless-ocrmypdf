#/bin/bash
set -o pipefail

if [ -z "${OCRMYPDF_BINARY}" ] ; then
    OCRMYPDF_BINARY=$(find / -name ocrmypdf -type f -executable 2>/dev/null)
    if [ -z "${OCRMYPDF_BINARY}" ] ; then
        echo "Failed to find ocrmypdf binary. Set env var OCRMYPDF_BINARY manually"
        exit 1
    else
        echo "Found ocrmypdf binary $OCRMYPDF_BINARY"
    fi
fi

if [ ! -x "${OCRMYPDF_BINARY}" ] ; then
    echo "ocrmypdf binary ${OCRMYPDF_BINARY} is not executable. If you set OCRMYPDF_BINARY manually, check your settings"
fi

inotifywait -m -e close_write -e moved_to /in |
    while read -r path action file; do
        echo "Waiting for $file..."
        sleep 10
        echo "Processing $file..."

        out="${file%%.*}.pdf"
        
        ${OCRMYPDF_BINARY} ${OCRMYPDF_PARAMETERS} "$path/$file" "/work/$out" 2>&1 | tee /tmp/log
        rc=$?
        if [ $rc -ne 0 ] ; then
            echo "OCRmyPDF failed with code $rc"
            if [ -n "$(grep DpiError /tmp/log)" ] ; then
                echo "It was DpiError, retrying with img2pdf"
                img2pdf --pagesize A4 "$path/$file" | ${OCRMYPDF_BINARY} ${OCRMYPDF_PARAMETERS} - "/work/$out"
                rc=$?
                if [ $rc -ne 0 ] ; then
                    echo "img2pdf + OCRmyPDF failed with code $rc"
                fi
            fi
        fi

        if [ $rc -eq 0 -a -f "/work/$out" ] ; then
            mv -n "/work/$out" "/out/$out"
            mv -n "$path/$file" /archive/$(date +%y%m%d-%H%M%S)_"$file"
            echo "File $file processed and archived"
        else
            echo "Failed to process $file, leaving as is"
            [ -f "/work/$out" ] && rm "/work/$out"
        fi
    done

