/* $Id: VDXf_tools.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/VDXf_tools.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log $
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

/* VDXf_tools.c */
extern int VDXcenter_message __((Form form, int g_label, char *msg_str));
extern int VDXget_text __((Form form, int gadget_label, int row, int col, char *text, int *text_size));
extern int VDXconvert_lev_array __((IGRint *msg, IGRint *levels, char * buffer));
extern int VDXget_on_off_lev __((IGRint *msg, IGRint *levels, IGRshort *on_levels, IGRshort *num_on_levels, IGRshort *off_levels, IGRshort *num_off_levels));

#if defined(__cplusplus)
}
#endif

