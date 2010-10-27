/* $Id: VDSvw_pl.t,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / VDSvw_pl.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSvw_pl.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/06/21  13:50:46  pinnacle
# Replaced: vddetail/cmd/VDSvw_pl.t for:  by apazhani for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/11  22:42:50  pinnacle
# updated files
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
    File : VDSvw_pl.t

    Dependencies :
		VDCmdDetail.S
		./config/commands/VDCrVwFrPl
		./config/vds_cmd_tbl

    Description
	This command object creates, by using the methods from the
	class VDCmdDetail, a window view.

	The window view is created from a plane, of class EMSplane, 
	which can selected by OBJECT and by NAME. Inn case of given
	a text string, the object must be placed in the working directory.

	The object is selected from the current file or a reference file, 
	which has to be attached to the active file. 

	The drawing view can be changed before drawing, by changing the
	x-axis and the y-axis for the transformation matrix. The normal
	of the plane is unchangable.

	The x-axis can be changed by given a new vector for the transfor-
	mation matrix. The y-axis will be recalculated.

	The y-axis can be inverted.

	The x-axis and y-axis accept values unequal to the norm vector values.
	which gives the possibility the change the scale of the object in
	the drawing view.

	The drawing view is constructed by using the methods in COdetail.

	The window view is created in the same environment of the selected
	object.

    History
	Ad Zuurhout    01/01/92    Creation date.
 */

/* ********************************************************** */
/*	CLASS SPECIFICATION				      */
/* ********************************************************** */

command_string  VDC_M_CrWnFrPl,VD_viewplane,VDCrWnFrPl
class		VDCmdDetail
super_class	"COdetail"
super_class	"VDS_LOCATE"
product_name    "$VDS"
command_table	"vds.cmd"
options		"siTC"

status_display	"VDDetail","-1","-1"

start_state     start


/* ********************************************************** */
/* 	STATUS AREA					      */
/* ********************************************************** */

state_table

#include "OMerrordef.h"
#include "execmsg.h"
#include "grmessage.h"
#include "referr.h"
#include "grerr.h"
#include "msdef.h"
#include "toolco.h"
#include "detailcodef.h"
#include "detailco.h"
#include "DIdef.h"
#include "VDdetail.h"
#include "VDSFilter.h"
#include "VDmsg.h"


state *

  on EX_RESTART							state start

state start

  execute		VDdet_erase_hilite
  execute 		clear_objects

  message_key		VD_M_CrWnFrPl
  prompt_key		VD_P_IdPlane
  accept_key		VD_P_AccRej
  relocate_key		VD_P_IdPlane
  locate_class		" EMSplane "
  locate_properties	" LC_DP_ONLY | LC_LC_ONLY | LC_RW "
  locate_owner		" LC_RIGID_COMP | LC_RIGID_OWNER |
			  LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS "
  mask			" GRm_STRING |GRm_DATA | GRm_RJT_MOVEON | 
			  GRm_OBJID | GRm_BACK_UP "
  filter		vds_locate

  on EX_RJT_MOVEON						state terminate
  on NULL_STRING or EX_BACK_UP					state .
  on EX_DATA or EX_OBJID
	do get_component_id
	  on RETURN_CODE = MSFAIL				state .
	  on RETURN_CODE = MSSUCC
	    do get_object_environment
	      on RETURN_CODE = MSFAIL				state .
	      on RETURN_CODE = MSSUCC
		do status_key VD_S_PlObjAcc			state def_objvw
	    							state .
								state .
  on EX_STRING
	do get_component_name
	  on RETURN_CODE = MSFAIL				state .
	  on RETURN_CODE = MSSUCC
	    do get_object_environment
	      on RETURN_CODE = MSFAIL				state .
	      on RETURN_CODE = MSSUCC
		do status_key VD_S_PlObjAcc			state def_objvw
								state .
								state .

state def_objvw

  execute define_objview

  on RETURN_CODE = MSFAIL
	do status_key VD_E_ErrObjDef				state start

  on RETURN_CODE = MSSUCC
	do status ""						state mod_param

state mod_param

  prompt_key	VD_P_MdDrWnPrm
  filter	get_event

  on EX_RJT_MOVEON or NULL_STRING				state cr_objview
  on EX_STRING = "n" or EX_STRING = "N"				state cr_objview
  on EX_STRING = "y" or EX_STRING = "Y"				state form_info
  on GR_UNKNOWN_TYPE.VD_DET_FORM_ACCEPT				state cr_objview
  on GR_UNKNOWN_TYPE.VD_DET_FORM_EXECUTE			state cr_objview
  on STRING							state .

state form_info

  execute VDupdate_form( sts, 1 )

  status	""
  prompt_key	VD_P_MdPrm
  filter	get_event

  on GR_UNKNOWN_TYPE.VD_DET_FORM_ACCEPT				state cr_objview
  on GR_UNKNOWN_TYPE.VD_DET_FORM_EXECUTE			state cr_objview

state cr_objview

  execute construct_objview

  on RETURN_CODE = MSFAIL
	do status_key GR_E_ErrEncCmdRst				state start

  on RETURN_CODE = MSSUCC
	do object_disconnect
	do status ""						state start

at init		do VDdet_init
