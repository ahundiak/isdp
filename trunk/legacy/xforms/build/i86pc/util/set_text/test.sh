
if [ ! -d /usr/tmp/text ]
then
  mkdir /usr/tmp/text /usr/tmp/forms
fi

for FFF in $*
do
  ### first, see if the file is an I/Forms binary form file
  $IFORMS/bin/FIf_show_fonts $FFF	1>/dev/null 2>&1

  if [ $? != 0 ]
  then
    continue
  fi

  $IFORMS/bin/FIf_get_text $FFF /usr/tmp/text/$FFF 1>/usr/tmp/err1 2>&1
  if [ $? != 0 ]
  then
    echo "\n********  ERROR:  FIf_get_text $FFF  *******************\n"
    cat /usr/tmp/err1
  fi

  echo "\n FIf_set_text $FFF ===========\n"
  $IFORMS/bin/FIf_set_text $FFF /usr/tmp/text/$FFF  /usr/tmp/forms/$FFF

  bdiff $FFF /usr/tmp/forms/$FFF	1>/dev/null 2>&1

  if [ $? != 0 ]
  then
    echo "\n***************  Form files are different !!!  *********\n"
  fi

done
