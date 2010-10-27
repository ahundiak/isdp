/* $Id: VDfrmtxt.S,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/imp / VDfrmtxt.S
 *
 * Description:
	The class VDfrmtxt is the replacement class for VDtxbox.
	The class allows to create annotation text with will be associative
	to the connected object (type ACncpx).
        
        Comparing with VDtxbox, it removes the three instance:
            att_type
            value
            text_string
        Those instance are not useful and take 2k space for each object.
 

	The graphical representation of the VDfrmbox is identical to the 
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
 *	$Log: VDfrmtxt.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/09/18  03:13:50  pinnacle
# Replaced: vdannot/imp/VDfrmtxt.S for:  by mdong for vds
#
# Revision 1.2  1997/08/26  22:10:36  pinnacle
# Replaced: vdannot/imp/VDfrmtxt.S for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/08/12  22:06:34  pinnacle
# Replaced: vdannot/imp/VDfrmtxt.S for:  by yzhu for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/05/09  22:31:06  pinnacle
# Created: vdannot/imp/VDfrmtxt.S by yzhu for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
	05/07/96 	Yzhu    	first implementation
 *
 * -------------------------------------------------------------------*/


class specification VDfrmtxt(1:0) of DMtxldr;

#include "dimdef13.h"

instance VDfrmtxt
{

	IGRuchar		box_type;	/* box type */
        variable  IGRchar 	info[0];        /* textual information */
};


/*
 * override of methods for VDfrmtxt without any respect to the box.
 */
override GRdelete;
override GRgetobjinfo;
override DMcompute_node;
override gather_data;
override txdynamics;
override GRxform;
override GRgetattr;            
override GRputattr;          
override position_text;
override update_leader;

/*
 * override of methods for VDfrmtxt with box display and management.
 */
override get_disp_list;
override make_an_text;

message get_box_caps_parser_type(
        IGRlong *msg;
        IGRuchar *box_type;
        IGRuchar *cap_type;
        IGRuchar *par_type);

message set_box_caps_parser_type(
        IGRlong *msg;
        IGRuchar *box_type;
        IGRuchar *cap_type;
        IGRuchar *par_type);

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

message VDsetAttribute(
        IGRlong *msg;
	IGRlong text_flag;
        IGRchar *attr_ptr; );

message VDgetAngle(
        IGRlong *msg;
        IGRdouble *angle );

message VDgetCapsFlag(
        IGRlong *msg;
        IGRuchar *caps_flag );

message VDgetMirrorFlag(
        IGRlong *msg;
        IGRuchar *mirror_flag );

message VDgetReverseFlag(
        IGRlong *msg;
        IGRuchar *reverse_flag );

/*\
MOTIVATION

    Specific behaviour for

	GRsetattr	: - Set instance data.

	GRgetattr	: - Retrieve instance data.

	GRgetobjinfo	: - UI_status when locate.

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

\*/

end specification VDfrmtxt;

