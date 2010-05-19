/* $Id: VDtxbox.S,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/imp / VDtxbox.S
 *
 * Description:
	The class VDtxbox is the replacement class for VDtxldr.
	The class allows to create annotation text with will be associative
	to the connected object (type ACncpx).

	The graphical representation of the VDtxbox is identical to the 
	DMtxldr with an option to create a box frame over the expression.
	The management of the box is done by the instance box_type, which
	has the following value types:

		VD_box_NO_DISPLAY	: No display of the box.
		VD_box_DISPLAY		: Display the box.
		VD_box_AUTOMATIC	: Display the box if an attribute of 
					  the father object is active.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDtxbox.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.2  1995/11/20  15:13:42  pinnacle
# Replaced: vdannot/imp/VDtxbox.S for:  by tlbriggs for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
	09/23/93 	Ad Zuurhout    	first implementation
 *	11/17/95	tlb		Remove override of get_dim_params
 *
 * -------------------------------------------------------------------*/


class specification VDtxbox(2:0) of DMtxldr;

#include "dimdef13.h"

instance VDtxbox
{
	IGRuchar	box_type;			/* box type */

	IGRchar		att_type[MAX_TEXT_STRING];	/* test attribute */
	
	IGRdouble	value;				/* attribute value */

	IGRchar		text_string[MAX_TEXT_STRING];	/* attribute value */
};


/*
 * override of methods for VDtxbox without any respect to the box.
 */
override GRdelete;
override GRgetobjinfo;
override DMcompute_node;
override gather_data;
override txdynamics;
override GRxform;

/*
 * override of methods for VDtxbox with box display and management.
 */
override get_disp_list;
override make_an_text;

message update_text_box(
        IGRlong *msg;
        IGRuchar *text_string;
        struct IGRestx *estx;
        struct IGRlbsys *lbs_geom;
        struct GRmd_env *md_env);

message disp_box_type(
	IGRlong *msg;
	IGRint	*display );

message set_box_type(
	IGRlong *msg;
	IGRuchar box_type );

message get_box_type(
	IGRlong *msg;
	IGRuchar *box_type );

message set_att_type(
	IGRlong *msg;
	IGRchar *att_type;
	IGRchar *text_string;
	IGRdouble *value );

message get_att_type(
	IGRlong *msg;
	IGRchar *att_type;
	IGRchar *text_string;
	IGRdouble *value );
 

/*\
MOTIVATION

    Specific behaviour for

	GRgetobjinfo	: - UI_status when locate

	DMcompute_node	: - See if we have to delete the box graphics and
			    get the text expression value.

	gather_data	: - delete the second root AN_ROOT_ELEM2

	txdynamics	: - avoid to add text in the expression.

	get_disp_list	: - in case box needs to display, reorganize the list
			    list of component/owner objects.

	make_an_text	: - make the annotation text layout and recalculate 
			    the box values.

	update_text_box	: - calculate the sizes of the box according to the
			    given expression.

	disp_box_type	: - returns the display = 0 or display = 1 depending
			    of the display box option.

	set_box_type	: - set box type in instance.

	get_box_type	: - get box type of object.

	set_att_type	: - set attribute type in instance.

	get_att_type	: - get attribute type of object.

	NDmove_to_root	: - delete itself if no ACcpx remains connected on the
			    parent channel
			  - disconnect from deleted parent if some others remain
			    connected.

\*/

end specification VDtxbox;

