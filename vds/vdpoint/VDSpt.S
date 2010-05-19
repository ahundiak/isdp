/* $Id: VDSpt.S,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpoint / VDSpt.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSpt.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
ABSTRACT :
          The VDSpt class is the class of point with an view scale 
	  independent text.

		
CHANGE HISTORY
	
	CH    6 Feb  92 : design date
	ADZ   6 Feb  94 : correction for display list toggle
*/


class specification VDSpt (0:1) of GR3dpoint;

instance VDSpt
{
 variable IGRchar  	vd_text[0];
 IGRshort		my_props;
 IGRshort		x_offset, y_offset; /* Offset in picels */
};

 /* About the instance my_props;
 /*
 /* SM_PT_NO_DISP_TXT  : Don't display the text.
 /* SM_PT_NO_DISP_PT   : Don't display the graphic point.
 /*
 /* The following allows defining a justification
 /* 
 /* SM_X_POS	       : 	  
 /* SM_X_NEG	       : 
 /* SM_Y_POS	       : 
 /* SM_Y_NEG	       : 
 /* */

override GRdisyourself;

override GRadd_to_display_list;


/*\
OVERRIDE MOTIVATION
    Specific behaviour for
        GRdisyourself    : Display also the text in view dependant (in dynamic).

	GRadd_to_display_list : To avoid setting in display list
\*/

message VDdisyourself(  IGRlong *msg; IGRshort *mx_type; IGRmatrix
                        matrix;  enum GRdpmode *mode;
			struct IGRaltdisplay *alt_symb;
			struct DP_information *sp_info;
                        OM_p_KEY_DESC range_key);

/* Private massages */

message VDinitinst();

message VDsettext(char *text);

message VDsetprops(short props);

message VDsetoffset(short x_offset, y_offset);

message VDgetprops(short *props);

message VDchgprops(short mask, props);

message VDgetoffset(short *x_offset, *y_offset);

message VDgettext(char *text; short size);

end specification VDSpt;
