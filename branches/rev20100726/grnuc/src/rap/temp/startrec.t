 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 


command_string  "start record",0,GRStrtRcrd
class           "RAPcobCO" 
spec_path       "$PLATFORM/co/spec"
start_state     start
product_name    "$PLATFORM"
command_table   "rap.dpt"               /* this goes in $PLATFORM/config */

state_table
#include "coniindex.h"
#include "grmessage.h"


state *
on   EX_RESTART                                           state start
on   EX_BACK_UP                                           state -

state start
    message         "start record"
    execute         does_listener_exist
		       on SUCCESS
                          do status "already recording"
			  do remove_last_command
							state terminate
		       on ERROR                         state get_filename

state get_filename
    prompt          "Enter filename"
    filter          get_event
on  TEXT_VALUE        do have_filename ( sts, 1 ) 
			 on ERROR
			    do status "cannot open file"
							state terminate
			 on SUCCESS
			    do status "start record"
							state terminate
							state terminate
on  EX_BACK_UP                                          state .

