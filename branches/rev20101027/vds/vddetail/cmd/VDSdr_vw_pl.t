/* $Id: VDSdr_vw_pl.t,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / VDSdr_vw_pl.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdr_vw_pl.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  2000/03/01  14:36:44  pinnacle
# ylong
#
# Revision 1.2  1999/10/29  20:21:02  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.6  1995/03/22  14:55:14  pinnacle
# Replaced: vddetail/cmd/VDSdr_vw_pl.t by azuurhou r#
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
 *	10/27/99	ylong		added locate class +VDatBase
 *	03/01/00	ylong		TR179901113 locate class VSplate
 * -------------------------------------------------------------------*/

/*
    File : VDSdr_vw_pl.t

    Dependencies :
		VDCmdDetail.S
		./config/commands/VDCrDrVwFP
		./config/vds_cmd_tbl

    Description
	This command object creates, by using the methods from the
	class VDCmdDetail, a drawing view (unaligned).

	The drawing view is created from a plane, of class EMSplane, 
	which can selected by OBJECT and by NAME. Inn case of given
	a text string, the object must be placed in the working directory.

	The object is selected from a reference file, which has to be 
	attached to the active file. Objects from the active file will
	not be accepted.

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

	Further, the following items are asked:

		- The scale of the drawing view, default (1:100).
		- Drawing view origin
		- The coordinate system origin in the drawing view.

	Removed are :
		
		- Drawing view label text origin.
		- Drawing view scale text origin.
		- Drawing view name.
		- Drawing view description.


	All the required information can be modified in a STATUS_FORM, which
	will be available at the moment an object is selected.
	The form is called "VDDetail"

    Revision 

	Cause: 

	When selecting objects using a fence on the drawing view created,
	objects outside the range of the drawing view are also selected.  This
	is because of the nature of the design of the locate filter. The locate
	filter selects all objects that fall within the view volume defined by
	the fence boundary and the display depths of the current window. 
	Logically, one would not want objects outside the range of the drawing 
	view (these objects are not visible in the drawing view) to be
	selected.  Hence the following fix has been incorporated into the 
	design.

	When creating a drawing view, the display depths of the window are set
	to the z depths of the clipping polygon associated with the drawing
	view.  Then any locate with respect to this drawing view would work as
	desired.  When more than one drawing view is created in the same 
	window, then the display depths of the window would be set to the z
	depths of the latest drawing view created.  
	The user can change the display depths of any window, based on the 
	z depths associated with any drawing view using, the "Set Display 
	Depths from Drawing View" command.
	
    History
	Ad Zuurhout    01/01/92    Creation date.
	Radhai Manem   06/22/93    Set z depths in window, equal to the z
				   depths of the drawing view 
 */

/* ********************************************************** */
/*	CLASS SPECIFICATION				      */
/* ********************************************************** */

command_string  VDC_M_CrDrVwFP,VD_drawview,VDCrDrVwFP
command_table	"vds.cmd"
class		VDCmdDetail
/*
 *		super_class	"COdetail"
 *		super_class	"VDS_LOCATE"
 */
product_name    "$VDS"
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

#define  VD_RANGE_BY_OBJECTS	1000
#define  VD_EXTEND_RANGE	1001
#define  VD_RANGE_BY_POINTS	1002

state *

  on EX_RESTART							state start

state start

  execute		clear_objects
  execute		get_reference_info
  execute		VDdet_del_tmp_obj

  /*
   * look for the GRID_ON / GRID_LOCK in all windows
   * and set the flags off.
   */
  execute		set_grid_flags_off

  message_key		VD_M_CrDrVwFP
  prompt		"Identify Plane, Plate or Assembly "
  accept_key		VD_P_AccRej
  relocate_key		VD_P_RelocPlane
  locate_class		" EMSplane,VDdrawing,VSplate,+VDatBase"
  locate_properties	" LC_DP_ONLY | LC_LC_ONLY | LC_RW "
  locate_owner		" LC_RIGID_COMP | LC_RIGID_OWNER |
			  LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS "
  locate_display	" ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
			  ALL_WINDOWS | LC_ERASE_ALL "
  mask			" GRm_STRING | GRm_DATA | GRm_RJT_MOVEON | 
			  GRm_OBJID | GRm_BACK_UP "
  filter		vds_locate

  /*
   * look in the list if the flag GRID_ON / GRID_LOCK was active
   * and reset the flags on.
   */
  execute reset_grid_flags

  on STATUS_DISP do status_key VD_E_IdStaDisp 			state .

  on EX_RJT_MOVEON						state .
  on NULL_STRING or EX_BACK_UP					state .
  on EX_DATA or EX_OBJID
	do get_ref_component_id
	  on RETURN_CODE = MSFAIL				state .
	  on RETURN_CODE = MSSUCC
	    do get_object_environment
	      on RETURN_CODE = MSFAIL				state .
	      on RETURN_CODE = MSSUCC				state def_objview
	    							state .
								state .
  on EX_STRING
	do get_component_name
	  on RETURN_CODE = MSFAIL				state .
	  on RETURN_CODE = MSSUCC
	    do get_object_environment
	      on RETURN_CODE = MSFAIL				state .
	      on RETURN_CODE = MSSUCC
		do status_key VD_S_PlObjAcc 			state def_objview
								state .
								state .

state  init_noplane
  execute  VDdet_init_noplane()
  on ELSE  state def_objview

state def_objview

  execute define_objview

  on RETURN_CODE = MSFAIL
	do status_key VD_E_ErrObjDef				state start

  on RETURN_CODE = MSSUCC
	do VDdet_init_toggles
	do VDupdate_form( sts, 0 )
	do status_key VD_S_StFrmAvail				state cr_drview

state cr_drview

  prompt_key	VD_P_EntDrVwOr
  dynamics	2
  filter	get_event

  on STATUS_DISP	do VDupdate_form( sts, 1 )		state .
  on GR_UNKNOWN_TYPE.VD_RANGE_BY_OBJECTS			state objRange
  on GR_UNKNOWN_TYPE.VD_EXTEND_RANGE				state extRange
  on GR_UNKNOWN_TYPE.VD_RANGE_BY_POINTS				state ptsRange
  on EX_RJT_MOVEON						state start
  on EX_BACK_UP							state start
  on EX_DATA
	do create_drawview
	  on RETURN_CODE = MSFAIL				state start
	  on RETURN_CODE = MSSUCC
		do status_key VD_S_DrPlaced
		do VDdet_init_toggles				state start
								state .

state objRange
  execute		erase_sts_disp
  prompt		"Locate object(s)"
  accept_key		VD_P_AccRej
  relocate		"Object(s) not found"
  locate_class		"+GRgraphics"
  locate_properties	" LC_DP_ONLY | LC_LC_ONLY | LC_RW "
  locate_owner		" LC_RIGID_COMP | LC_RIGID_OWNER |
			  LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS "
  locate_display	" ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
			  ALL_WINDOWS | LC_ERASE_ALL "
  mask			" GRm_STRING | GRm_DATA | GRm_RJT_MOVEON | 
			  GRm_OBJID | GRm_BACK_UP "
  filter		vds_locate

  on EX_RJT_MOVEON or EX_BACKUP				state sts_disp
  on EX_DATA or EX_OBJID
	do get_range_from_objid
	  on RETURN_CODE = MSFAIL
		do status  "Error finding range; Plaese try again"
							state .
	  on RETURN_CODE = MSSUCC
	    do set_range
	      on RETURN_CODE = MSFAIL			state .
	      on RETURN_CODE = MSSUCC			state sts_disp
							state .
							state .
  on ELSE						state .

state extRange
  execute		erase_sts_disp
  prompt		"Locate object(s)"
  accept_key		VD_P_AccRej
  relocate		"Object(s) not found"
  locate_class		"+GRgraphics"
  locate_properties	" LC_DP_ONLY | LC_LC_ONLY | LC_RW "
  locate_owner		" LC_RIGID_COMP | LC_RIGID_OWNER |
			  LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS "
  locate_display	" ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
			  ALL_WINDOWS | LC_ERASE_ALL "
  mask			" GRm_STRING | GRm_DATA | GRm_RJT_MOVEON | 
			  GRm_OBJID | GRm_BACK_UP "
  filter		vds_locate

  on EX_RJT_MOVEON or EX_BACKUP				state sts_disp
  on EX_DATA or EX_OBJID
	do get_range_from_objid
	  on RETURN_CODE = MSFAIL			state .
	  on RETURN_CODE = MSSUCC
	    do extend_range
	      on RETURN_CODE = MSFAIL			state .
	      on RETURN_CODE = MSSUCC			state sts_disp
							state .
							state .
  on ELSE						state .


state ptsRange
  execute		erase_sts_disp
  prompt		"Locate point 1"
  accept_key		VD_P_AccRej
  relocate		"Point not found"
  locate_class		"+GR3dpoint"
  locate_properties	" LC_DP_ONLY | LC_LC_ONLY | LC_RW "
  locate_owner		" LC_RIGID_COMP | LC_RIGID_OWNER |
			  LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS "
  locate_display	" ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
			  ALL_WINDOWS | LC_ERASE_ALL "
  mask			" GRm_STRING | GRm_DATA | GRm_RJT_MOVEON | 
			  GRm_OBJID | GRm_BACK_UP "
  filter		vds_locate

  on EX_RJT_MOVEON or EX_BACKUP				state sts_disp
  on EX_DATA or EX_OBJID
	do get_coord_of_pt( &me->ret, 0 )
	  on RETURN_CODE = MSFAIL			state .
	  on RETURN_CODE = MSSUCC			state getPt2
	  						state .
  on ELSE						state .

state getPt2
  execute		erase_sts_disp
  prompt		"Locate point 2"
  accept_key		VD_P_AccRej
  relocate		"Point not found"
  locate_class		"+GR3dpoint"
  locate_properties	" LC_DP_ONLY | LC_LC_ONLY | LC_RW "
  locate_owner		" LC_RIGID_COMP | LC_RIGID_OWNER |
			  LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS "
  locate_display	" ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
			  ALL_WINDOWS | LC_ERASE_ALL "
  mask			" GRm_STRING | GRm_DATA | GRm_RJT_MOVEON | 
			  GRm_OBJID | GRm_BACK_UP "
  filter		vds_locate

  on EX_RJT_MOVEON or EX_BACKUP				state ptsRange
  on EX_DATA or EX_OBJID
	do get_coord_of_pt( &me->ret, 1)
	  on RETURN_CODE = MSFAIL			state .
	  on RETURN_CODE = MSSUCC
	    do set_range
	      on RETURN_CODE = MSFAIL			state .
	      on RETURN_CODE = MSSUCC			state sts_disp
							state .
							state .
  on ELSE						state .

state sts_disp
  execute disp_sts_disp
  on ELSE						state cr_drview





at init		do VDdet_init
at delete	do VDdet_del_tmp_obj
