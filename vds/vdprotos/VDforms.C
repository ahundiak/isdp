/* $Id: VDforms.C,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdprotos/VDforms.C
 *
 * Description:
 *		FIforms functions with prototype problems.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDforms.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:05  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1996/03/04  07:30:54  pinnacle
 * Replaced: include/VX_FIproto.h for:  by msbraju for vds.240
 *
 * Revision 1.1  1995/11/29  14:24:42  pinnacle
 * Created: ./vdprotos/VDforms.C by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      11/29/95	adz		creation date
 *
 ***************************************************************************/

#include "VX_FIproto.h"

int VDfld_set_list_text(Form form, int label, int row, int col, char *text, int sel_flg)
{
	int sts = -1 ;
 
#ifdef	X11     /* INTEL SOLARIS */
	sts = FIfld_set_list_text( form, label, row, col,
				(unsigned char *)text, sel_flg );
#endif

#ifdef	ENV5
	sts = FIfld_set_list_text( form, label, row, col, text, sel_flg );
#endif

	return sts ;

} /* VDfld_set_list_text */

/*--------------------------------------------------------------------------*/
int VDgrp_callback(Form form, int group_label, void (*callback_routine)(),
		   int user_arg )
{
	int sts = -1 ;
 
#ifdef	X11     /* INTEL SOLARIS */
        sts = FIgrp_callback( form, group_label, (int (*)()) callback_routine,
			      user_arg ); 
#endif

#ifdef	ENV5
        sts = FIgrp_callback( form, group_label, callback_routine, user_arg ); 
#endif

	return sts ;

} /* VDgrp_callback */
