#!/bin/bash

conf=/etc/ibcontroller/conf.ini

# Force those values
export IB_ForceTwsApiPort=
export IB_IbBindAddress=127.0.0.1
export IB_IbDir=/var/run/ibcontroller/tws/conf

# thanks to kafka-docker for this wonderful snippet
for VAR in `env`; do
    if [[ $VAR =~ ^IB_ ]]; then
        name=`echo "$VAR" | sed -r "s/IB_(.*)=.*/\1/g"`
        env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
        if egrep -q "(^|^#)$name=" $conf; then
            sed -r -i "s@(^|^#)($name)=(.*)@\2=${!env_var}@g" $conf #note that no config values may contain an '@' char
        else
            echo "$name=${!env_var}" >> $conf
        fi
    fi
done

socat TCP-LISTEN:4003,fork TCP:127.0.0.1:4002&

/usr/sbin/xvfb-run \
    --auto-servernum \
    -f \
    /var/run/xvfb/ \
    /usr/share/ib-tws/jre/bin/java \
    -cp \
    /usr/share/ib-tws/jars/total-2017.jar:/usr/share/ib-tws/jars/jts4launch-966.jar:/usr/share/ib-tws/jars/twslaunch-966.jar:/usr/share/ib-tws/jars/twslaunch-install4j-1.8.jar:/usr/share/ib-tws/jars/log4j-core-2.5.jar:/usr/share/ib-tws/jars/log4j-api-2.5.jar:/usr/share/ib-tws/jars/locales.jar:/usr/share/java/ibcontroller/ibcontroller.jar \
    -Xmx512M \
    ibcontroller.IBGatewayController \
    $conf
