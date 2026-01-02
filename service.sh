{
    until [[ "$(getprop sys.boot_completed)" == "1" ]]; do
        sleep 15
    done

    cmd wifi force-country-code enabled GB
    setprop gsm.operator.iso-country us,us
    setprop gsm.sim.operator.iso-country us,us
}&

