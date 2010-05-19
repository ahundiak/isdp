/* $Id: VDSInfPl.S,v 1.1.1.1 2001/01/04 21:09:15 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdspace/imp / VDSInfPl.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSInfPl.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:15  cvs
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
          The VDSInfPl class is the class of vds infinite plane.

		
CHANGE HISTORY
	
	CH    7 Dec  90 : design date
	ADZ   2 Fec  94 : Add  message GRadd_to_display_list().
*/


class specification VDSInfPl (0:1) of EMSplane;

instance VDSInfPl
{
 variable char  vd_text[0];
 short		size;   
};

 /* About the instance size   bit:    store    
 /*			     0-3      size
 /*			     4-7      next axis justif   
 /*			     8-11     next next axis justif
 /*			     12-15    not used
 /* */

override GRdisyourself;

override GRdetplane, GRgenabsg;

override GRgetobjinfo;

override GRadd_to_display_list;

/*\
OVERRIDE MOTIVATION
    Specific behaviour for
        GRdisyourself    : Display also the text in view dependant (in dynamic).

	GRdetplane	 : The scale of the plane is so thin that the regular
			   method does not give the right result.

	GRgenabsg	 : Return something bigger than the truth one.

	GRadd_to_display_list : Return *msg = MSFAIL to avoid to set in the
			   Toogle Display List.

\*/

message VDdisyourself(  IGRlong *msg; IGRshort *mx_type; IGRmatrix
                        matrix;  enum GRdpmode *mode;
			struct IGRaltdisplay *alt_symb;
			struct DP_information *sp_info;
                        OM_p_KEY_DESC range_key);

/* Private massages */

message VDinitinst();

message VDsettext(char *text);

message VDsetsize(short size);

message VDsetjustif(short j1, j2);

message VDgetsize(short *size);

message VDgetjustif(short *j1, *j2);

message VDgettext(char *text; short size);

end specification VDSInfPl;
