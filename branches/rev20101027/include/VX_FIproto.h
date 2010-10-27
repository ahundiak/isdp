/* $Id: VX_FIproto.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/VX_FIproto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VX_FIproto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
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
 * Revision 1.3  1996/03/04  07:30:42  pinnacle
 * Replaced: include/VX_FIproto.h for:  by msbraju for vds.240
 *
 * Revision 1.2  1995/11/29  14:22:58  pinnacle
 * Replaced: ./include/VX_FIproto.h for:  by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/11/95		adz		creation date
 *
 ***************************************************************************/

#if defined(X11)
#	include "XFIproto_pub.h"
#elif defined(ENV5)
#	include "FIproto_pub.h"
#endif

/*
 * VDS declared prototype routines.
 */

extern int VDfld_set_list_text(Form form, int label, int row, int col,char *text, int sel_flg);

extern int VDgrp_callback( Form form, int group_label, 
			   void (*callback_routine)(), int user_arg );
