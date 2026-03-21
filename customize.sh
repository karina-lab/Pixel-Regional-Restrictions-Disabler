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

if [ -d "$MODPATH/uwb" ]; then
    rm -rf "$MODPATH/uwb"
fi