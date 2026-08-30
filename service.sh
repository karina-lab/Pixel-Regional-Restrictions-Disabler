{
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 1
    done

    # cmd wifi: works in modern Android
    cmd wifi force-country-code enabled AU
    # prop: works in legacy Android
    resetprop ro.boot.wificountrycode AU
    resetprop wifi.country AU
    # Force enable 6GHz overlay configs if possible
    # These are often device specific but setting them doesn't hurt
    resetprop ro.wifi.6ghz.enabled true
    resetprop config.disable_wifi_6ghz false

    setprop gsm.operator.iso-country us,us
    setprop gsm.sim.operator.iso-country us,us
}&

