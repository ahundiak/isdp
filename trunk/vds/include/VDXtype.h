/* $Id: VDXtype.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/VDXtype.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXtype.h,v $
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

/* VDXtype2.c */
extern int VDXtype2 __((IGRdouble range[6 ], struct IGRpolyline *geometry, IGRlong num_bdrys, IGRlong *msg, IGRint *file_des, IGRchar *dgn_buf, struct VDX_IGDS_cell *ele_buf, IGRint *ele_size, IGRchar class_name[], struct GRsymbology *symbology, IGRushort *properties, IGRlong grgroup[2 ], IGRlong scale));

/* VDXtype15.c */
extern int VDXtype15 __((IGRlong *msg, IGRlong *file_des, IGRchar *dgn_buf, struct type15_element *igds, IGRlong *igds_size, IGRchar class_name[], struct IGRarc *geometry, GRrange range, struct GRsymbology *symbology, IGRshort *properties, IGRlong grgroup[2 ], IGRlong scale));

/* VDXtype18.c */
extern int VDXtype18 __((
	IGRlong *msg, 
	IGRint *file_des, 
	IGRchar *dgn_buf, 
	struct IGDS_linestring *ele_buf, 
	IGRint *ele_size, 
	IGRchar *class_name, 
	IGRint num_profiles;
	IGRint *types, 
	IGRint *num_pnts, 
	IGRdouble *pnts, 
	struct GRsymbology *symbology, 
	IGRushort *properties, 
	IGRboolean *fill_bit, 
	IGRlong *grgroup, 
	IGRlong scale, 
	IGRdouble *range));

extern int VDXradius1 __((double p1[3 ], double p2[3 ], double p3[3 ], double p4[3 ], double *rad, double cen[3 ], double matrix[16 ], double *sweep));
extern int VDXv_cross1 __((double v1[3 ], double v2[3 ], double v3[3 ]));
extern int VDXv_scale1 __((double v1[3 ], double s, double v2[3 ]));
extern int VDXv_len1 __((double v1[3 ], double *l));

/* VDXtype23.c */
extern IGRlong VDXtype23 __((IGRlong *msg, IGRint *file_des, IGRchar *dgn_buf, struct type23_element *igds, IGRint *igds_size, IGRchar class_name[], struct EMsurface_params *geometry, GRrange range, struct GRsymbology *symbology, IGRshort *properties, IGRlong grgroup[2 ], IGRlong scale));

/* VDXtype24.c */
extern int VDXtype24 __((IGRlong *msg, IGRint *file_des, IGRchar *dgn_buf, IGRchar *igds, IGRint *igds_size, IGRchar class_name[], struct IGRbsp_surface *geometry, GRrange range, struct GRsymbology *symbology, struct GRprops *geometric_props, IGRshort *properties, IGRlong grgroup[2 ], IGRlong scale));

/* VDXtype46.c */
extern int VDXtype46 __((IGRdouble range[6 ], struct IGRbsp_curve *geometry, IGRlong *msg, IGRint *file_des, IGRchar *dgn_buf, struct IGDS_linestring *ele_buf, IGRint *ele_size, IGRchar class_name[], struct GRsymbology *symbology, IGRushort *properties, IGRlong grgroup[2 ], IGRlong scale));

#if defined(__cplusplus)
}
#endif

