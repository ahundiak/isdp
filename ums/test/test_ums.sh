#
#
#	umscompile test.txt
#
#

#sml,dmb,sbc:04-07-93:Test if umscompile generated test.msg

TEST_STATUS="OK"
test_name="umscompile test.txt"
echo $test_name
echo '----------------------------------------------------------'
umscompile test.txt
echo '----------------------------------------------------------'

if [ -f test.h ]
then 
  if cmp test.h standard.h
  then
	# succeeded
	echo "test.h IS SAME as standard.h"
  else
	# failed
	echo "test.h NOT SAME as standard.h"
    TEST_STATUS="NOT OK"
  fi  
else
  echo "umcompile did not generate test.h"
  TEST_STATUS="NOT OK"
fi

if [ -f test.msg ]
then 
  if cmp test.msg standard.msg
  then
	# succeeded
	echo "test.msg IS SAME as standard.msg"
  else
	# failed
	echo "test.msg NOT SAME as standard.msg"
    TEST_STATUS="NOT OK"
  fi  
else
  echo "umcompile did not generate test.msg"
  TEST_STATUS="NOT OK"
fi

echo
if [ "$TEST_STATUS" = "OK" ]
then
  echo '*** SUCCESS:  '$test_name
else
  echo '*** FAILURE:  '$test_name
fi
rm -f test.msg test.h 

echo '********************************************************************'




#
#
#	umscomptxt test.txt
#
#

#sml,dmb,sbc:04-07-93:Test if umscompile generated test.h

TEST_STATUS="OK"
test_name="umscomptxt test.txt"
echo $test_name
echo '----------------------------------------------------------'
umscomptxt test.txt
echo '----------------------------------------------------------'

if [ -f test.h ]
then 
  echo "umcomptxt INCORRECTLY generated test.h"
  TEST_STATUS="NOT OK"
else
  echo "umcomptxt CORRECTLY did not generate test.h"
fi

#sml,dmb,sbc:04-07-93:Test if umscomptxt generated test.msg

if [ -f test.msg ]
then 
  if cmp test.msg standard.msg
  then
	# succeeded
	echo "test.msg IS SAME as standard.msg"
  else
	# failed
	echo "test.msg NOT SAME as standard.msg"
	TEST_STATUS="NOT OK"
  fi  
else
  echo "umcompile did not generate test.msg"
  TEST_STATUS="NOT OK"
fi

echo

if [ "$TEST_STATUS" = "OK" ]
then
  echo '*** SUCCESS:  '$test_name
else
  echo '*** FAILURE:  '$test_name
fi

rm -f test.msg test.h 


echo '********************************************************************'

#
#
#	umscompile -m TEST.msg -p TEST.h test.txt
#
#

TEST_STATUS="OK"
test_name="umscompile -p TEST.h -m TEST.msg test.txt"
echo $test_name
echo '----------------------------------------------------------'
umscompile -p TEST.h -m TEST.msg test.txt
echo '----------------------------------------------------------'

#sml,dmb,sbc:04-07-93:Test if umscompile generated TEST.h
if [ -f TEST.h ]
then 
  if   cmp TEST.h standard.h 
  then
	# succeeded
	echo "TEST.h IS SAME as standard.h"
  else
	# failed
	echo "TEST.h NOT SAME as standard.h"
    TEST_STATUS="NOT OK"
  fi  
else
  echo "umcompile did not generate TEST.h"
  TEST_STATUS="NOT OK"
fi

#sml,dmb,sbc:04-07-93:Test if umscompile generated test.msg
if [ -f TEST.msg ]
then 
  if cmp TEST.msg standard.msg
  then
	# succeeded
	echo "TEST.msg IS SAME as standard.msg"
  else
	# failed
	echo "TEST.msg NOT SAME as standard.msg"
    TEST_STATUS="NOT OK"
  fi  
else
  echo "umcompile did not generate TEST.msg"
  TEST_STATUS="NOT OK"
fi

rm -f TEST.h TEST.msg test.h test.msg test.inc

echo
if [ "$TEST_STATUS" = "OK" ]
then
  echo '*** SUCCESS:  '$test_name
else
  echo '*** FAILURE:  '$test_name
fi


echo '********************************************************************'





#
#
#	umscompile -m TEST.msg -F test.txt
#
#

TEST_STATUS="OK"
test_name="umscompile -m TEST.msg -F test.txt"
echo $test_name
echo '----------------------------------------------------------'
umscompile -m TEST.msg -F test.txt
echo '----------------------------------------------------------'

if [ -f test.inc ]
then 
  if   cmp test.inc standard.inc
  then
	# succeeded
	echo "test.inc IS SAME as standard.inc"
  else
	# failed
	echo "test.inc NOT SAME as standard.inc"
    TEST_STATUS="NOT OK"
  fi  
else
  echo "umcompile did not generate test.inc"
  echo "pg test.inc"
  pg test.inc
  TEST_STATUS="NOT OK"
fi

#sml,dmb,sbc:04-07-93:Test if umscompile generated test.msg
if [ -f TEST.msg ]
then 
  if cmp TEST.msg standard.msg
  then
	# succeeded
	echo "TEST.msg IS SAME as standard.msg"
  else
	# failed
	echo "TEST.msg NOT SAME as standard.msg"
    TEST_STATUS="NOT OK"
  fi  
else
  echo "umcompile did not generate TEST.msg"
  TEST_STATUS="NOT OK"
fi

rm -f TEST.h TEST.msg test.h test.msg test.inc


echo
if [ "$TEST_STATUS" = "OK" ]
then
  echo '*** SUCCESS:  '$test_name
else
  echo '*** FAILURE:  '$test_name
fi

echo '********************************************************************'

