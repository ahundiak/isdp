
#### This file contains shell variables needed by COB, and some that
####   are merely convenient to have defined.


export IGE=$EXNUC		    ;#### this is necessary for slic
export EXNUC			    ;#### this is necessary for slic

export DRAFT=$GRNUC		    ;#### this is necessary for slic
			     ####   IMPORTANT:  If you're not building
			     ####   on the draft platform, then comment
			     ####   this out and don't set $DRAFT
export GRNUC
#export PDU=/usr/pdu/01030102

export FI=$IGE/fi

export OM=$IGE/om    ;#### this is necessary for slic only
			     ####   if your om isn't in $INGR/om
			     #### Perhaps your om is
			     ####   export COB=$INGR/om

export COB=$IGE/icob	    ;#### This is your *IGE* COB --
			     ####   it is necessary for slic only if
			     ####   your cob isn't in $IGE/icob
			     #### Perhaps your cob is 
			     ####   export COB=$IGE/icob

### the next one is needed for slic
export COBCPPOPT="-I$COB/include -I$IGE/include -I$OM/include -I$DRAFT/include -I$DRAFT/display/include -I$PDU/include -I$UMS/include"

alias -x slic="$IGE/bin/slic"	;### Perhaps your slic is 
				 ###   alias -x slic =$IGE/bin/slic

### the next one is needed for slic
alias -x omcpp="$IGE/bin/omcpp"	;### Perhaps your omcpp is 
				 ###  alias -x omcpp =$INGR/om/bin/omcpp

