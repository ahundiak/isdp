command_string GRMAttRef,0,GRAtRfFl
class          COref
product_name   "$GRNUC"
super_class    COtools
super_class    CEO_GSLOCATE
path           "."
spec_path      "$GRNUC/co/spec"
start_state    start
status_display "GRAttachRef","-1","-1"
options        "siCT"

state_table

#include <OMerrordef.h>
#include <execmsg.h>
#include <grmessage.h>
#include <toolco.h>
#include <grerr.h>
#include <referr.h>
#include <msdef.h>
#include "detailco.h"
#include <DIdef.h>
#include <OMtypes.h>
#include <ODE.h>


at init do COref.assign_defaults ()

at wakeup do status_display_button(1)


state *

on EX_RESTART       do COref.assign_origin_flag ( 0 )
                                                state start
state start

message_key GRC_M_AttRef
prompt_key  GR_P_EntFil
execute options_mode (FILENAME_MODE,".")
filter    get_event

on STATUS_DISP    
do COref.options_mode (FILENAME_MODE,".")
state .

on TEXT_VALUE       do COtools.access_file ( sts,
                                            (CO_file_exists | CO_file_reg | CO_file_read),
                                             me->event1.event.keyin,
                                             0 )
    on MSSUCC       do COref.assign_filename ( me->event1.event.keyin )  
                                                  state get_view
    on MSFAIL       do status_key GR_E_FlNotFnd   state .
                                                  state .

on EX_BACK_UP                                     state .


state get_view

prompt_key  GR_P_KySavVwNme
execute options_mode(VIEW_MODE,0)
execute     status_display_button(1)
filter get_event
on STATUS_DISP
    do file_mode()
    do options_mode( VIEW_MODE, 0)
    state .
on EX_RJT_MOVEON or NULL_STRING
                    do COref.assign_view ( "" )
                    do COref.assign_origin_flag ( 0 )
                    do COref.assign_scale ( "1" )
                                                  state construct_reffile
on TEXT_VALUE       do COref.assign_view ( me->event1.event.keyin )
                                                  state get_origin
on EX_BACK_UP                                     state -

state get_origin

prompt_key  GR_P_EntOrg

filter get_event

on EX_DATA          do COref.assign_origin_flag ( 1 )
                    do COref.assign_origin_event ()
                                        state get_scale      
on EX_RJT_MOVEON    do COref.assign_origin_flag ( 0 )
                                        state get_scale 
on EX_BACK_UP                           state -

state get_scale

prompt_key  GR_P_EntScFac
execute options_mode(SCALE_MODE,0)
execute     status_display_button(1)

filter  get_event
on STATUS_DISP
    do options_mode(SCALE_MODE,0)
    state .

on EX_RJT_MOVEON or NULL_STRING
                    do COref.assign_scale ( "1" )
                                                state construct_reffile 
on TEXT_VALUE       do COref.assign_scale ( me->event1.event.keyin )
                                                state construct_reffile 
on EX_BACK_UP       do COref.assign_origin_flag ( 0 )
                                                state -
state get_name

prompt_key  GR_P_EntAtNme

filter    get_event

on TEXT_VALUE       do COref.assign_name (me->event1.event.keyin)
                                                  state construct_reffile

on EX_BACK_UP                                     state start


state construct_reffile

status_key  GR_I_RefAtt

execute echo_mode
execute erase_form_by_label (STATUS_FORM, 1, sts)
execute construct_reference_file

on OM_I_DUPLICATE_OS    do status ""
                        do error_box_key EX_F_DupIntOSName 
                                                        state start
on MSSUCC 
    do status ""                    
    do display_mode GRbd
    do display_located
    state start

on GRFILENOTFOUND       do status_key GR_E_FlNotFnd     state start
on GRVIEWNOTFOUND       do status_key GR_E_SvVwNotFnd   state get_view
on GRNAMEDUPLICATED     do status_key GR_E_AttnameEx    state get_name
on GRSDGNEXCEED         do status_key GR_E_InvScFac     state get_scale
on OM_E_NO_OS_AVAIL     do status_key GR_E_MaxRfFl	    state start
on MSFAIL               do status_key GR_E_ErrEncCmdRst state start

