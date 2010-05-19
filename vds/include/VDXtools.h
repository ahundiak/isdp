/* $Id: VDXtools.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/VDXtools.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXtools.h,v $
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

/* VDXtools.c */
extern void VDXdebug __((int state, FILE *log_file, char *filename, char *msg_buf));
extern long VDXgen_filename __((char *in_filename, char *out_filename, char *extension));
extern long VDX_find_product __((char *product_num, char *msg_str));

#if defined(__cplusplus)
}
#endif

