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

/*\
Abstract	
Notes
History
\*/
command_string  "IGE_RETRIEVE_OPTIONS","0,0,1",GRRtOpFr
class		COretco
super_class	CEO
start_state	start
product_name	"$SOURCE"
path            "."
form            "GRRetOpt",0,1,"-1","-1"
options 	"siCT"

state_table

#include <grmessage.h>

state start 

     message_key GRC_M_RetFileOpt
     prompt_key  GR_P_SelFrForm
     filter      wfi
     
     on FORM_FINISHED  
               do set_options()    state terminate

at wakeup do set_gadgets()
