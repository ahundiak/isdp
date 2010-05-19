/* $Id: vdgrenvproto.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude/prototypes / vdgrenvproto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdgrenvproto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
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
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/VDS
*/

#ifndef vdgrenvproto_include
#	define vdgrenvproto_include

#include <standards.h>
#include "vdgraphicenv.h"

extern int
VD_flipblock		__((	VDgrEnvWindow	*wno,
				int		x,
				int		y,
				int		X,
				int		Y )) ;

extern int
VD_Clear_scrap		__((	void )) ;

extern int
VD_Put_scrap		__((	char		*type,
				char		*buf,
				int		size )) ;

extern int
VD_Get_scrap		__((	char		*type,
				char		*data,
				int		*size,
				int		*index )) ;

extern int
VD_Wait_timer		__((	int		time )) ;

extern int
VD_Mouseposition	__((	VDgrEnvWindow	*wno,
				int		*x,
				int		*y,
				int		*work_status )) ;

extern int
VD_InqEvents		__((	VDgrEnvEvent	*events )) ;
extern int

VD_isKeyBoardEvent	__((	VDgrEnvEvent	*events )) ;

extern int
VD_isBtnOrWnEvent	__((	VDgrEnvEvent	*events )) ;

extern int
VD_isWnEvent		__((	VDgrEnvEvent	*events )) ;

extern int
VD_DPhandle_event	__((	VDgrEnvEvent	*events )) ;

extern int
VD_FI_process_event	__((	VDgrEnvEvent	*events )) ;

extern int
VD_FIf_get_window	__((	char		*form,
				VDgrEnvWindow	*p_wno )) ;

extern int
VD_FImouseposition	__((	char		*form,
				int		*x,
				int		*y,
				int		*work_status )) ;

extern int
VD_FIweight		__((	char		*form,
				int		weight )) ;

extern int
VD_FIfgcolor		__((	char		*form,
				int		color )) ;


extern int
VD_FIhidecursor		__((	char		*form )) ;

extern int
VD_FIshowcursor		__((	char		*form )) ;

#endif /* vdgrenvproto_include */
