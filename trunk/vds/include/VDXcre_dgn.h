/* $Id: VDXcre_dgn.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/VDXcre_dgn.h
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

/* VDXcre_dgn.u */
/**
extern int VDXcre_dgn __((int mode, char *design_file, int all_or_evgen, char *prod_path, char *output_file, Form form));
**/
extern long VDXrecurs_search __((struct GRid in_obj, struct GRmd_env alt1_env, IGRlong ggno[2 ]));
extern int VDXmacro_search __((struct GRid in_obj, struct GRid out_obj[1 ], struct GRmd_env alt2_env[1 ], int start[1 ], int of[1 ], IGRlong ggno[2 ]));
extern long VDXcopy_element __((struct GRid *in_obj, IGRlong group_no[2 ]));
extern long VDXopen_files __((char *design_file, char *prod_path, char *dst_file, char *dri_file, char *drv_file, char *dgn_file));
extern int VDXclose_up_dgn __((void));
extern int delete __((void));
extern int VDXeval_surf __((struct GRid *in_obj));
extern long VDXget_coll_data __((struct GRid DIR, struct GRmd_env VDXmod_env, MYFILE *outfile));
extern int VDXreport_file_generate __((long start_time, char *design_file, char *dst_file, char *dri_file, char *drv_file, char *dgn_file));
extern void VDXinit __((void));
extern long VDXpre_process __((int mode int all_or_evgen, int all_or_evgen, Form form));
extern long VDXprocess __((int mode Form form, int form));
extern long VDXopen_dgn_seedfile __((char *prod_path, char *sfilename));
extern long VDXwrite_dst __((char *dst_filename));
extern long VDXwrite_rpt_heading __((FILE *log_file));
extern long VDXwrite_dri __((char *dri_filename, char *dgn_filename, char *drv_filename));
extern long VDXinit_drv_file __((char *drv_filename));
extern long VDXinit_dgn_file __((char *dgn_filename));

#if defined(__cplusplus)
}
#endif

