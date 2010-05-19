/* $Id: VDXpost.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/VDXpost.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXpost.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1999/04/19  14:08:00  pinnacle
 * for dynapipe
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/16/99        ylong           created
 *			
 ***************************************************************************/

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VDXpost.c */
extern int VDXconn_status __((char *server_name, int connection, int conn_status));
extern int VDXsend_cmd __((char *server_name, char *vds_id, char *file_id,
                          char *outstr, int oursz));


#if defined(__cplusplus)
}
#endif

