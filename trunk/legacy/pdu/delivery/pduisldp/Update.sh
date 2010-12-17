#
#  If they have tcp/ip, update /etc/services and /etc/inetd.conf
#
  if [ -d /usr/ip32/tcpip ]
  then
      server_line=`grep -n "PDMserver" $ROOT/etc/services | \
               sed s/\ \ /\ /g | \
               cut -f1 -d":"`
      new_line="PDMserver  1801/tcp  none"
      if [ "$server_line" = "" ]
      then
          echo ${new_line} >> $ROOT/etc/services
      else
          echo "${server_line}c\n${new_line}\n.\nw" > $ROOT/pdm.tmp
          ed $ROOT/etc/services < $ROOT/pdm.tmp  >/dev/null 2>&1
          rm $ROOT/pdm.tmp
      fi
      AOK=$?
      if [ "$AOK" != "0" ] ; then exit $AOK; fi

      server_line=`grep -n "PDMserver" $ROOT/etc/inetd.conf | \
               sed s/\ \ /\ /g | \
              cut -f1 -d":"`
      new_line="PDMserver stream tcp nowait nfmadmin /usr/ip32/pdm/bin/PDMserver PDMserver TCP"

      if [ "$server_line" = "" ]
      then
          echo ${new_line} >> $ROOT/etc/inetd.conf
      else
          echo "${server_line}c\n${new_line}\n.\nw" > $ROOT/pdm.tmp
          ed $ROOT/etc/inetd.conf < $ROOT/pdm.tmp  >/dev/null 2>&1
          rm $ROOT/pdm.tmp
      fi
      AOK=$?
      if [ "$AOK" != "0" ] ; then exit $AOK; fi

    fi
