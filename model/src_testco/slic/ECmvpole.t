command_string          EM_M_MvPoleonCurve,CURVE,EMMvPlOnCr
synonym		        EM_M_MvPoleonSurface,SURFACE,EMMvPlOnSr
class                   ECmvpole
super_class             ECcmd
spec_path               "$MODEL/spec"
product_name            "$MODEL"
options                 "si"

state_table
#include <msdef.h>
#include "ECcmd_def.h"
#include "ECcmd.h"
#include "ECmsg.h"

#define EMS_CK_TANGENCY 101
#define EMS_INV_POLE    102
#define TRUE 1
#define FALSE 0

at wakeup   do change_class("GRbcsubbc")
            do turn_poly_on

at sleep    do turn_poly_off
            do delete_obj(&me->objid, FALSE)


state start
 on CMD_TYPE = CURVE	do message_key	EM_M_MvPlonCurve
                        state map_zview
 on CMD_TYPE = SURFACE	do message_key  EM_M_MvPlonSurface
                        state map_zview

state map_zview
 prompt_key        EMS_P_Prsrv_view_z
 filter		   get_event
 on EX_BACK_UP	   state .
 on STRING = "n"   do set_cond(&me->zview_cond, (short)FALSE)
                   state start_id
 on STRING = "N"   do set_cond(&me->zview_cond, (short)FALSE)
                   state start_id
 on STRING = ""    do set_cond(&me->zview_cond, (short)TRUE)
                   state start_id
 on EX_RJT_MOVEON  do set_cond(&me->zview_cond, (short)TRUE)
                   state start_id
 on STRING = "y"   do set_cond(&me->zview_cond, (short)TRUE)
                   state start_id
 on STRING = "Y"   do set_cond(&me->zview_cond, (short)TRUE)
                   state start_id

state start_id
 on CMD_TYPE = CURVE	do prompt_key	EMS_P_00030
                        do relocate_key EMS_I_00010
                        do locate_class	"GRbspline"
                        do locate_owner "LC_FLEX_COMP | LC_RIGID_COMP"
                        state locate_ele
 on CMD_TYPE = SURFACE	do message_key  EM_M_MvPlonSurface
                        do prompt_key EMS_P_00031
                        do relocate_key EMS_I_00011
                        do locate_class	"EMSsubbs"
                        do locate_owner LC_FLEX_COMP
                        state locate_ele

state locate_ele
 locate_display 	"ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
 locate_properties      "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
 accept_key             EMS_P_00038
 filter                 locate
 on EX_BACK_UP  state map_zview
 on DATA        do highlight_located 0 /* dehilited locate channel */
                do check_ancestry
                  on MSFAIL do status_key EMS_I_InvEleLoc  state .
                do ECcmd.EMsave_located_object(&me->event1,&me->located_obj[0])
                do change_class("GRbcsubbc")
                do turn_poly_on
                state input_pole

state input_pole
 prompt_key     EMS_P_Inputpole
 filter	        get_event
 on EX_BACK_UP  do turn_poly_off
                do status " "
                do delete_obj(&me->objid, TRUE)
                do delete_obj(&me->located_obj[0].located_obj.objid, TRUE)
                state start_id
 on DATA        do keypoint_pole
                do status " "
                do check_for_endpoint
                  on EMS_INV_POLE do status_key EMS_I_InvPole  state .
                  on EMS_CK_TANGENCY  state maintain_tangent
                state input_new_pos

state maintain_tangent
 prompt_key       EMS_P_Mainttangency
 filter           get_event
 on EX_BACK_UP    do set_cond(&me->tangency_cond, (short)FALSE)
                  state input_pole
 on STRING = "n"  do set_cond(&me->tangency_cond, (short)FALSE)
                  state input_new_pos
 on STRING = "N"  do set_cond(&me->tangency_cond, (short)FALSE)
                  state input_new_pos
 on STRING = ""   do set_cond(&me->tangency_cond, (short)FALSE)
                  state input_new_pos
 on EX_RJT_MOVEON do set_cond(&me->tangency_cond, (short)FALSE)
                  state input_new_pos
 on STRING = "y"  do set_cond(&me->tangency_cond, (short)TRUE)
                  state input_new_pos
 on STRING = "Y"  do set_cond(&me->tangency_cond, (short)TRUE)
                  state input_new_pos

state input_new_pos
 prompt_key     EMS_P_00141
 dynamics       dynmod
 filter         get_event
 on EX_BACK_UP  do set_cond(&me->tangency_cond, FALSE)
                state input_pole
 on DATA        do  prompt " "
                do process
                  on MSFAIL state not_mod
                do delete_obj(&me->located_obj[0].located_obj.objid, FALSE)
                state input_new_pos

state not_mod
 status         " "
 on CMD_TYPE = CURVE    do status_key EMS_P_Crvnotmodif
                        state start_id
 on CMD_TYPE = SURFACE  do status_key EMS_P_Surfnotmodif
                        state start_id
