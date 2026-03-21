ui_print "**************************************"
ui_print " Pixel Regional Restrictions Disabler "
ui_print "**************************************"

DEVICE_MODEL=$(getprop ro.product.device)
ui_print "- Device: $DEVICE_MODEL"

case "$DEVICE_MODEL" in
    "raven"|"cheetah"|"tangorpro"|"felix")
        SUB_FOLDER="uwb_67" ;;
    "husky"|"komodo"|"caiman"|"comet")
        SUB_FOLDER="uwb_89" ;;
    "mustang"|"blazer"|"rango")
        SUB_FOLDER="uwb_10" ;;
    *)
        ui_print "- Unsupported model. Skipping UWB configs."
        SUB_FOLDER="" ;;
esac

if [ -n "$SUB_FOLDER" ]; then
    ui_print "- Target detected: $SUB_FOLDER"
    
    DEST_DIR="$MODPATH/system/vendor/etc/uwb"
    mkdir -p "$DEST_DIR"

    ui_print "- Extracting $SUB_FOLDER files..."
    unzip -o "$ZIPFILE" "uwb/$SUB_FOLDER/*" -d "$TMPDIR" >&2

    if [ -d "$TMPDIR/uwb/$SUB_FOLDER" ]; then
        cp -af "$TMPDIR/uwb/$SUB_FOLDER/." "$DEST_DIR/"
        
        set_perm_recursive "$DEST_DIR" 0 0 0755 0644
        ui_print "- Installation successful!"
    else
        ui_print "- Error: Files not found inside ZIP!"
        ui_print "  (Path expected: uwb/$SUB_FOLDER/)"
    fi
else
    ui_print "- Skipping UWB file installation."
fi

case "$DEVICE_MODEL" in
    "husky"|"komodo"|"caiman"|"mustang"|"blazer")
        THERMO_SUPPORT="true";;
    *)
        ui_print "- Unsupported model. Skipping thermometer xml."
		THERMO_SUPPORT="false";;
esac

if [ "$THERMO_SUPPORT" = "true" ]; then
	APP_DATA="/data/data/com.google.android.apps.pixel.health"
    THERMO_DIR="$APP_DATA/shared_prefs"
	if [ -d "$APP_DATA" ]; then
		unzip -o "$ZIPFILE" "thermometer/*" -d "$TMPDIR" >&2
		if [ -d "$TMPDIR/thermometer" ]; then
			cp -af "$TMPDIR/thermometer/thermometer.xml" "$THERMO_DIR/"
			USER_ID=$(stat -c '%u' /data/data/com.google.android.apps.pixel.health)
			GROUP_ID=$(stat -c '%g' /data/data/com.google.android.apps.pixel.health)

			chown -R $USER_ID:$GROUP_ID "$THERMO_DIR"
			chmod 771 "$THERMO_DIR"
			chmod 660 "$THERMO_DIR/thermometer.xml"
		
			APP_CONTEXT=$(ls -Zd "$APP_DATA" | awk '{print $1}')
			chcon "$APP_CONTEXT" "$THERMO_DIR/thermometer.xml" 2>/dev/null
			am force-stop com.google.android.apps.pixel.health
		else
			ui_print "- Error: Files not found inside ZIP!"
			ui_print "  (Path expected: thermometer/)"	
		fi
	else
		ui_print "- Pixel Thermometer app not found. Skipping thermometer xml."
	fi
fi

if [ -d "$MODPATH/uwb" ]; then
    rm -rf "$MODPATH/uwb"
fi

if [ -d "$MODPATH/thermometer" ]; then
    rm -rf "$MODPATH/thermometer"
fi
