/*
Name
	Detach Reference File

History
	mrm	07/22/93	added associativity check
*/

command_string GRMDetFil,0,GRDtRfFl
class          COref
product_name   "$SOURCE"
super_class    COtools
super_class    CEO_GSLOCATE
path           "."
spec_path      "$GRNUC/co/spec"
start_state    start
options        "siCT"

state_table

#include <grmessage.h>
#include <toolco.h>

at delete
	do COtools.erase_highlight ()
	do status ""

state *
	on EX_RESTART   do COtools.erase_highlight ()   state start

state start
	message_key  GRC_M_DetFil
	prompt_key  GR_P_IdRefAtt
	accept_key GR_P_AccRejAtt
	relocate_key GRC_M_AttNotLoc
	gslocate_num_inputs 1
	gslocate_spec_mask1 "GRm_DATA | GRm_OBJID | GRm_STRING"
	gslocate_spec_prompt1_key GR_P_AccRejAtt
	locate_class "GRreffile"
	locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
	locate_properties "LC_WRITE_ONLY | LC_LC_ONLY | LC_DP_ONLY"
	locate_owner  "LC_REF_HEADER"
	locate_mask "GRm_DATA | GRm_OBJID | GRm_STRING"
	accept_mask "GRm_DATA | GRm_STRING"
	filter gs_locate
		on EX_DATA or EX_OBJID or EX_STRING
			do is_associative()
				on SUCCESS
					state verify_associative_delete
				on ELSE
					state delete_attachment
			state .

state verify_associative_delete
	execute COtools.confirm(GR_E_LosingAssoc, sts)
		on SUCCESS
			state delete_attachment
		on ELSE
			do status_key GR_I_RefFileNotDetached
			do COtools.erase_highlight()
			do disconnect_located 1
			state start

state delete_attachment
	on ELSE
		do COtools.erase_highlight ()
		do display_mode GRbe
		do display_located
		do COtools.delete_grset(sts, &me->located_chansel)  
		state start
