chooseport() {
  while true; do
    local event=$(/system/bin/getevent -lc 1 2>&1)
    if echo "$event" | grep -q "KEY_VOLUMEUP"; then
      return 0
    elif echo "$event" | grep -q "KEY_VOLUMEDOWN"; then
      return 1
    fi
  done
}

ask_user() {
  ui_print "- $1"
  ui_print "  Vol+ = Yes, Vol- = No"
  if chooseport; then
    ui_print "  Selected: Yes"
	sleep 0.5
	ui_print " "
    return 0
  else
    ui_print "  Selected: No"
	sleep 0.5
	ui_print " "
    return 1
  fi
}

ui_print "**************************************"
ui_print " Pixel Regional Restrictions Disabler "
ui_print "**************************************"

DEVICE_MODEL=$(getprop ro.product.device)
ui_print "- Device: $DEVICE_MODEL"
ui_print " "

case "$DEVICE_MODEL" in
    "raven"|"cheetah"|"tangorpro"|"felix")
        SUB_FOLDER="uwb_67" ;;
    "husky"|"komodo"|"caiman"|"comet")
        SUB_FOLDER="uwb_89" ;;
    "mustang"|"blazer"|"rango")
        SUB_FOLDER="uwb_10" ;;
    *)
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
        ui_print "- UWB fix installed."
		ui_print " "
    else
        ui_print "- Error: Files not found inside ZIP!"
        ui_print "  (Path expected: uwb/$SUB_FOLDER/)"
		ui_print " "
    fi
else
    ui_print "- Unsupported model. Skipping UWB file installation."
	ui_print " "
fi

case "$DEVICE_MODEL" in
    "husky"|"komodo"|"caiman"|"mustang"|"blazer")
        THERMO_SUPPORT="true";;
    *)
        ui_print "- Unsupported model. Skipping thermometer fix."
		ui_print " "
		THERMO_SUPPORT="false";;
esac

if [ "$THERMO_SUPPORT" = "true" ]; then
    APP_DATA="/data/data/com.google.android.apps.pixel.health"
    if [ -d "$APP_DATA" ]; then
        if ask_user "Enable Body Temperature in Pixel Thermometer?"; then
            THERMO_DIR="$APP_DATA/shared_prefs"
            mkdir -p "$THERMO_DIR"
            unzip -o "$ZIPFILE" "thermometer/*" -d "$TMPDIR" >&2
            
            if [ -f "$TMPDIR/thermometer/thermometer.xml" ]; then
                cp -af "$TMPDIR/thermometer/thermometer.xml" "$THERMO_DIR/"
                
                USER_ID=$(stat -c '%u' "$APP_DATA")
                GROUP_ID=$(stat -c '%g' "$APP_DATA")

                chown -R $USER_ID:$GROUP_ID "$THERMO_DIR"
                chmod 771 "$THERMO_DIR"
                chmod 660 "$THERMO_DIR/thermometer.xml"
        
				chcon --reference="$APP_DATA" "$THERMO_DIR/thermometer.xml" 2>/dev/null  
                
                am force-stop com.google.android.apps.pixel.health
                ui_print "- Thermometer fix installed."
				ui_print " "
            else
                ui_print "- Error: thermometer.xml not found in ZIP!"
				ui_print " "
            fi
        fi
    else 
        ui_print "- Pixel Thermometer app not found. Skipping."
		ui_print " "
    fi
fi

APP_DATA_GBOARD="/data/data/com.google.android.inputmethod.latin"
if [ -d "$APP_DATA_GBOARD" ]; then
    if ask_user "Enable AI features in Gboard?"; then
        GBOARD_DIR="$APP_DATA_GBOARD/files/datastore"
        mkdir -p "$GBOARD_DIR"
        unzip -o "$ZIPFILE" "gboard/*" -d "$TMPDIR" >&2
        
        if [ -f "$TMPDIR/gboard/flags_jetpack_data_store.pb" ]; then
            cp -af "$TMPDIR/gboard/flags_jetpack_data_store.pb" "$GBOARD_DIR/"
            
            USER_ID=$(stat -c '%u' "$APP_DATA_GBOARD")
            GROUP_ID=$(stat -c '%g' "$APP_DATA_GBOARD")

            chown -R $USER_ID:$GROUP_ID "$GBOARD_DIR"
            chmod 660 "$GBOARD_DIR/flags_jetpack_data_store.pb"
        
			chcon --reference="$APP_DATA_GBOARD" "$GBOARD_DIR/flags_jetpack_data_store.pb" 2>/dev/null    
			
            am force-stop com.google.android.inputmethod.latin
            ui_print "- Gboard fix installed."
			ui_print " "
        else
            ui_print "- Error: Gboard flags not found in ZIP!"
			ui_print " "
        fi
    fi
else
    ui_print "- Gboard not found. Skipping."
fi

ui_print "- VoLTE fix installed."
ui_print " "
ui_print "- VoWiFi fix installed."
ui_print " "
ui_print "- 5G fix installed."
ui_print " "
ui_print "- Hotspot fix installed."
ui_print " "

rm -rf "$MODPATH/uwb" "$MODPATH/thermometer" "$MODPATH/gboard" 2>/dev/null