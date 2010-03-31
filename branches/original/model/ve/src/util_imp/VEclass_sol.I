
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $

HISTORY

        Sudha   07/28/93        Modified for BSprototype ansification
	Ramana  08/16/95	Added emsdef.h as bsvalues.h is changed.
*/

class implementation Root;

#define CHECK_RETURN_CODES	1

#define LOG_BS2sfprtcsp	0
#define LOG_BSshprtlncl	0
#define LOG_BSsmprtlncl 0
#define LOG_BScsprtlncl	0

#define CONST_U_IND 0
#define CONST_V_IND 1

#define EDGE_OPT_ISO_ISO 0
#define EDGE_OPT_LST_LST 1
#define EDGE_OPT_ISO_LST 2
#define EDGE_OPT_LST_ISO 3

#define SHARED_EDGE_PARTING_MEM		10
#define SHARED_EDGE_CLASSIFY_MEM	10
#define CUSP_PARTING_MEM		10
#define CUSP_CLASSIFY_MEM		10
#define PARTING_CLASSIFY_MEM		10

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "OMminimum.h"
#include "OMerrordef.h"

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"

#include "madef.h"

#include "bs.h"
#include "bsparameters.h"
#include "bsvalues.h"

#include "msdef.h"
#include "gr.h"

#include "igrdp.h"
#include "godef.h"
#include "go.h"

#include "igrdp.h"
#include "godef.h"

#include "dpstruct.h"

#include "emsdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSobjmgrdef.h"

#include "ve_timing.h"
#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
%safe
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"
#include "VEpr_hiding.h"

#include "bscsprtlncl.h"
#include "bsmdstptcv.h"
#include "bssfpartcsp.h"
#include "bssmprtlncl.h"
#include "bsshprtlncl.h"
#include "bssfeval.h"
#include "bs2sfprtcsp.h"
#include "bsprgeomsf.h"
#include "bsxtractpar.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

#if LOG_BS2sfprtcsp
static void VElog_BS2sfprtcsp __(( 	
				struct IGRbsp_surface  *surf1, 
				struct IGRbsp_surface  *surf2,
				IGRdouble              *u1_range,
				IGRdouble              *v1_range,
				IGRdouble              *u2_range,
				IGRdouble              *v2_range,
				IGRint                 edge_opt,
				IGRint                 uv1_ind,
				IGRint                 uv2_ind;
				IGRdouble              uv1_par,
				IGRdouble              uv2_par,
				IGRint                 num_pts1,
				IGRint                 num_pts2,
				IGRdouble              *sf1_pars,
				IGRdouble              *sf2_pars,
				IGRint                 given_mem ));
#endif
#if LOG_BSshprtlncl
static void VElog_BSshprtlncl __((
			 	struct BSgeom_bsp_surf *gmsurf1,
				struct BSgeom_bsp_surf *gmsurf2,
				IGRint                 edge_opt,
				IGRint                 uv1_ind,
				IGRint                 uv2_ind,
				IGRdouble              uv1_par,
				IGRdouble              uv2_par,
				IGRdouble              *part1_pars,
				IGRdouble              *part2_pars,
				IGRint                 num_pts1,
				IGRint                 num_pts2,
				IGRdouble              *sf1_pars,
				IGRdouble              *sf2_pars,
				IGRdouble              *part_indices,
				IGRboolean             reverse1,
				IGRboolean             reverse2,
				IGRint                 given_mem ));
#endif
#if LOG_BSsmprtlncl
static void VElog_BSsmprtlncl __((
				struct BSgeom_bsp_surf *gmsurf,
				IGRint                 num_pts,
				IGRdouble              *pts,
				IGRint                 given_mem ));

#endif
#if LOG_BScsprtlncl
static void VElog_BScsprtlncl __((
				struct IGRbsp_surface  *surf,
				IGRint                 uv_ind,
				IGRdouble              uv_par,
				IGRdouble              *part_pars,
				IGRint                 given_mem ));
#endif

static IGRboolean VEis_iso_edge __((
				struct VEedge_header   *edge,
				OMuword                osnum,
				IGRint                 *uv_ind,
				IGRdouble              *const_par,
				IGRdouble              *par_range,
				IGRboolean             *reverse_flag,
				IGRboolean             *part_edge ));

static void VEget_linestring_info __(( 
				struct VEedge_header   *edge,
				OMuword                osnum,
				IGRint                 *num_pts,
				IGRdouble              **uv_pts,
				IGRboolean             *reverse_flag ));

static void VEmap_uv_isocurve_points_to_curve __(( 
				struct VEedge_header   *edge,
				struct IGRbsp_surface  *surf,
				struct IGRbsp_curve    *curve,
				IGRdouble              const_par,
				IGRdouble              u1,
				IGRdouble              u2,
				IGRboolean             curve_on_surface,
				IGRboolean             curve_reversed,
				IGRboolean             part_edge,
				IGRdouble              *mapped_u1,
				IGRdouble              *mapped_u2 ));

static IGRdouble VEmap_uv_linestring_point_to_curve __(( 
				IGRdouble              index,
				IGRint                 num_uv_pts,
				IGRdouble              *uv_pts,
				struct IGRbsp_surface  *surf,
				struct IGRbsp_curve    *curve ));

static IGRint VEinterpret_math_classification __(( 
				IGRint                 edge_class ));

static void VEdetermine_shared_edge_info __(( 
				struct VEedge_header   *edge1, 
				struct VEedge_header   *edge2,
				OMuword                osnum,
				IGRint                 *edge_opt,
				IGRint                 *uv1_ind,
				IGRint                 *uv2_ind,
				IGRdouble              *const1_par,
				IGRdouble              *const2_par,
				IGRdouble              *par1_range,
				IGRdouble              *par2_range,
				IGRboolean             *reverse1,
				IGRboolean             *reverse2,
				IGRboolean             *part_edge1,
				IGRboolean             *part_edge2,
				IGRint                 *num_pts1,
				IGRint                 *num_pts2,
				IGRdouble              **sf1_pars, 
				IGRdouble              **sf2_pars ));

static void VEsplit_and_classify_shared_edges __(( 
				struct VEelement_header *real_elem,
				struct VEedge_header    **real_edge,
				struct VEedge_header    **real_prev_edge ));

static void  VEsplit_and_classify_parting_line __((
				struct VEelement_header *element,
				struct VEedge_header    **edge,
				struct VEedge_header    **prev_edge ));

static void VEsplit_and_classify_cusp_line __(( 
				struct VEelement_header *element,
				struct VEedge_header    **edge,
				struct VEedge_header    **prev_edge ));

#if defined(__cplusplus)
}
#endif

#undef __
%endsafe

#if TIMING
extern IGRdouble   VEtime_2sfpart;
extern IGRdouble   VEtime_shprtcl;
extern IGRdouble   VEtime_csprtcl;
extern IGRdouble   VEtime_partcsp;
extern IGRdouble   VEtime_smprtcl;
extern IGRint      VEcount_2sfpart;
extern IGRint      VEcount_shprtcl;
extern IGRint      VEcount_csprtcl;
extern IGRint      VEcount_partcsp;
extern IGRint      VEcount_smprtcl;
extern struct tms  VEs_time;
extern struct tms  VEe_time;
#endif

from EMSedge import EMget_props, EMgetpygeom, EMendpts;

%safe
static IGRdouble id_matrix[16] = { 1.0, 0.0, 0.0, 0.0,
	                           0.0, 1.0, 0.0, 0.0,
	                           0.0, 0.0, 1.0, 0.0,
                                   0.0, 0.0, 0.0, 1.0 };
%endsafe

/* External global variables */
extern struct VEexecution_parms  VEexec_parms;
extern struct VEexecution_status VEexec_status;
extern IGRboolean                VEuse_classification_alg;


#if LOG_BS2sfprtcsp
static void VElog_BS2sfprtcsp( surf1, surf2,
	                       u1_range, v1_range,
	                       u2_range, v2_range,
	                       edge_opt, uv1_ind, uv2_ind, uv1_par, uv2_par,
	                       num_pts1, num_pts2, sf1_pars, sf2_pars, given_mem )

	struct IGRbsp_surface *surf1, *surf2;
	IGRdouble             *u1_range, *v1_range, *u2_range, *v2_range;
	IGRint                edge_opt;
	IGRint                uv1_ind, uv2_ind;
	IGRdouble             uv1_par, uv2_par;
	IGRint                num_pts1, num_pts2;
	IGRdouble             *sf1_pars, *sf2_pars;
	IGRint                given_mem;

/*
NAME
	VElog_BS2sfprtcsp (static)

KEYWORD
	debug

DESCRIPTION
	This function writes the parameters for a call to BS2sfprtcsp() to
	stderr.  Its primary use is to give test cases to the math group.

PARAMETERS
	surf1 (IN) - surface 1
	surf2 (IN) - surface 2
	u1_range (IN) - u range of surface 1
	v1_range (IN) - v range of surface 1
	u2_range (IN) - u range of surface 2
	v1_range (IN) - v range of surface 2
	edge_opt (IN) - edge option
	uv1_ind (IN) - uv indicator for edge1
	uv2_ind (IN) - uv indicator for edge2
	num_pts1 (IN) - number of points on edge1
	num_pts2 (IN) - number of points on edge2
	sf1_pars (IN) - UV points for edge1
	sf2_pars (IN) - UV points for edge2
	given_mem (IN) - amount of preallocated memory

GLOBALS USED
	none

HISTORY
	S.P. Rogers 05/xx/91 Creation Date
*/

	{
	IGRint    ii;
	IGRlong   rc;
	IGRdouble base_tol;

	fprintf( stderr, "INPUT DATA for BS2sfprtcsp\n\n" );

	BSxtractpar( &rc, BSTOLBASIS,  &base_tol );
	fprintf( stderr, "BASE TOL: %20.15lf\n\n", base_tol );

	fprintf( stderr, "SURF1\n" );
	VEdebug_surface( surf1, TRUE );
	fprintf( stderr, "\n" );

	fprintf( stderr, "SURF2\n" );
	VEdebug_surface( surf2, TRUE );
	fprintf( stderr, "\n" );

	fprintf( stderr, "U1-RANGE: %lf %lf\n\n", u1_range[0], u1_range[1] );

	fprintf( stderr, "V1-RANGE: %lf %lf\n\n", v1_range[0], v1_range[1] );

	fprintf( stderr, "U2-RANGE: %lf %lf\n\n", u2_range[0], u2_range[1] );

	fprintf( stderr, "V2-RANGE: %lf %lf\n\n", v2_range[0], v2_range[1] );

	fprintf( stderr, "EDGE-OPT: %d\n\n", edge_opt );

	fprintf( stderr, "UV1-IND: %d\n", uv1_ind );
	fprintf( stderr, "UV2-IND: %d\n\n", uv2_ind );

	fprintf( stderr, "UV1-PAR: %lf\n", uv1_par );
	fprintf( stderr, "UV2-PAR: %lf\n\n", uv2_par );

	fprintf( stderr, "NUM-PTS1: %d\n\n", num_pts1 );
	fprintf( stderr, "NUM-PTS2: %d\n\n", num_pts2 );

	if ( sf1_pars )
	   {
	   fprintf( stderr, "SF1-PARS:\n" );
	   for ( ii = 0; ii < num_pts1; ii++ )
	      fprintf( stderr, "   %lf %lf\n", sf1_pars[ii*2], sf1_pars[ii*2+1] );
	   }
	else
	   fprintf( stderr, "SF1-PARS: NULL\n" );

	if ( sf2_pars )
	   {
	   fprintf( stderr, "SF2-PARS:\n" );
	   for ( ii = 0; ii < num_pts2; ii++ )
	      fprintf( stderr, "   %lf %lf\n", sf2_pars[ii*2], sf2_pars[ii*2+1] );
	   }
	else
	   fprintf( stderr, "SF2-PARS: NULL\n" );


	fprintf( stderr, "\n" );

	fprintf( stderr, "GIVEN MEM: %d\n", given_mem );
	}  /* VElog_BS2sfprtcsp */

#endif

#if LOG_BSshprtlncl
static void VElog_BSshprtlncl( gmsurf1, gmsurf2, edge_opt,
	                       uv1_ind, uv2_ind, uv1_par, uv2_par,
	                       part1_pars, part2_pars,
	                       num_pts1, sf1_pars,
	                       num_pts2, sf2_pars,
	                       part_indices,
	                       reverse1, reverse2, given_mem )

	struct BSgeom_bsp_surf *gmsurf1, *gmsurf2;
	IGRint                 edge_opt;
	IGRint                 uv1_ind, uv2_ind;
	IGRdouble              uv1_par, uv2_par;
	IGRdouble              *part1_pars, *part2_pars;
	IGRint                 num_pts1, num_pts2;
	IGRdouble              *sf1_pars, *sf2_pars;
	IGRdouble              *part_indices;
	IGRboolean             reverse1, reverse2;
	IGRint                 given_mem;

/*
NAME
	VElog_BSshprtlncl (static)

KEYWORD
	debug

DESCRIPTION
	This function writes the parameters for a call to BSshprtlncl() to
	stderr.  Its primary use is to give test cases to the math group.

PARAMETERS
	gmsurf1 (IN) - surface 1
	gmsurf2 (IN) - surface 2
	edge_opt (IN) - edge option
	uv1_ind (IN) - uv indicator for edge1
	uv2_ind (IN) - uv indicator for edge2
	part1_pars (IN) - parting segment for edge1
	part2_pars (IN) - parting segment for edge2
	num_pts1 (IN) - number of points on edge1
	num_pts2 (IN) - number of points on edge2
	sf1_pars (IN) - UV points for edge1
	sf2_pars (IN) - UV points for edge2
	part_indices (IN) - parting segment indices
	reverse1 (IN) - reverse flag for edge1
	reverse2 (IN) - reverse flag for edge2
	given_mem (IN) - amount of preallocated memory

GLOBALS USED
	none

HISTORY
	05/xx/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRint    ii;
	IGRlong   rc;
	IGRdouble base_tol;

	fprintf( stderr, "INPUT DATA for BSshprtlncl\n\n" );

	BSxtractpar( &rc, BSTOLBASIS,  &base_tol );
	fprintf( stderr, "BASE TOL: %20.15lf\n\n", base_tol );

	fprintf( stderr, "SURF1\n" );
	BSprgeomsf( stderr, gmsurf1, &rc );
	fprintf( stderr, "\n" );

	fprintf( stderr, "SURF2\n" );
	BSprgeomsf( stderr, gmsurf2, &rc );
	fprintf( stderr, "\n" );

	fprintf( stderr, "EDGE-OPT: %d\n\n", edge_opt );

	fprintf( stderr, "UV1-IND: %d\n", uv1_ind );
	fprintf( stderr, "UV2-IND: %d\n\n", uv2_ind );

	fprintf( stderr, "UV1-PAR: %lf\n", uv1_par );
	fprintf( stderr, "UV2-PAR: %lf\n\n", uv2_par );

	if ( part1_pars )
	   fprintf( stderr, "PART1-PARS: %lf %lf\n", part1_pars[0], part1_pars[1] );
	else
	   fprintf( stderr, "PART1-PARS: NULL\n" );
	if ( part2_pars )
	   fprintf( stderr, "PART2-PARS: %lf %lf\n\n", part2_pars[0], part2_pars[1] );
	else
	   fprintf( stderr, "PART2-PARS: NULL\n\n" );

	fprintf( stderr, "NUM-PTS1: %d\n\n", num_pts1 );

	if ( sf1_pars )
	   {
	   fprintf( stderr, "SF1-PARS:\n" );
	   for ( ii = 0; ii < num_pts1; ii++ )
	      fprintf( stderr, "   %lf %lf\n", sf1_pars[ii*2], sf1_pars[ii*2+1] );
	   }
	else
	   fprintf( stderr, "SF1-PARS: NULL\n" );

	fprintf( stderr, "\n" );

	fprintf( stderr, "NUM-PTS2: %d\n\n", num_pts2 );

	if ( sf2_pars )
	   {
	   fprintf( stderr, "SF2-PARS:\n" );
	   for ( ii = 0; ii < num_pts2; ii++ )
	      fprintf( stderr, "   %lf %lf\n", sf2_pars[ii*2], sf2_pars[ii*2+1] );
	   }
	else
	   fprintf( stderr, "SF2-PARS: NULL\n" );

	fprintf( stderr, "\n" );

	if ( part_indices )
	   fprintf( stderr, "PART INDICES: %lf %lf\n", part_indices[0], part_indices[1] );
	else
	   fprintf( stderr, "PART INDICES: NULL\n" );

	fprintf( stderr, "\n" );

	fprintf( stderr, "REVERSE1: %d\n", reverse1 );
	fprintf( stderr, "REVERSE2: %d\n", reverse2 );

	fprintf( stderr, "\n" );

	fprintf( stderr, "GIVEN MEM: %d\n", given_mem );
	} /* VElog_BSshprtlncl */

#endif

#if LOG_BSsmprtlncl
static void VElog_BSsmprtlncl( gmsurf, num_pts, pts, given_mem )

	struct BSgeom_bsp_surf *gmsurf;
	IGRint                 num_pts;
	IGRdouble              *pts;
	IGRint                 given_mem;

/*
NAME
	VElog_BSsmprtlncl (static)

KEYWORD
	debug

DESCRIPTION
	This function writes the parameters for a call to BSsmprtlncl() to
	stderr.  Its primary use is to give test cases to the math group.

PARAMETERS
	gmsurf (IN) - surface that has smooth parting line
	num_pts (IN) - number of points on smooth parting line
	pts (IN) - XYZ points of smooth parting line
	given_mem (IN) - amount of preallocated memory

GLOBALS USED
	none

HISTORY
	05/xx/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRint    ii;
	IGRlong   rc;
	IGRdouble base_tol;

	fprintf( stderr, "INPUT DATA for BSsmprtlncl\n\n" );

	BSxtractpar( &rc, BSTOLBASIS,  &base_tol );
	fprintf( stderr, "BASE TOL: %20.15lf\n\n", base_tol );

	fprintf( stderr, "SURF\n" );
	BSprgeomsf( stderr, gmsurf, &rc );
	fprintf( stderr, "\n" );

	fprintf( stderr, "NUM-PTS: %d\n\n", num_pts );

	fprintf( stderr, "PTS:\n" );
	for ( ii = 0; ii < num_pts; ii++ )
	   fprintf( stderr, "   %lf %lf %lf\n", pts[ii*3], pts[ii*3+1], pts[ii*3+2] );

	fprintf( stderr, "\n" );

	fprintf( stderr, "GIVEN MEM: %d\n", given_mem );
	}  /* VElog_BSsmprtlncl */
#endif

#if LOG_BScsprtlncl
static void VElog_BScsprtlncl( surf, uv_ind, uv_par, part_pars, given_mem )

	struct IGRbsp_surface *surf;
	IGRint                uv_ind;
	IGRdouble             uv_par;
	IGRdouble             *part_pars;
	IGRint                given_mem;

/*
NAME
	VElog_BScsprtlncl (static)

KEYWORD
	debug

DESCRIPTION
	This function writes the parameters for a call to BScsprtlncl() to
	stderr.  Its primary use is to give test cases to the math group.

PARAMETERS
	surf (IN) - surface that has cusp line
	uv_ind (IN) - uv indicator of cusp line
	uv_par (IN) - constant parameter of cusp line
	part_pars (IN) - parting line region of cusp line
	given_mem (IN) - amount of preallocated memory

GLOBALS USED
	none

HISTORY
	05/xx/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong   rc;
	IGRdouble base_tol;

	fprintf( stderr, "INPUT DATA for BScsprtlncl\n\n" );

	BSxtractpar( &rc, BSTOLBASIS,  &base_tol );
	fprintf( stderr, "BASE TOL: %20.15lf\n\n", base_tol );

	fprintf( stderr, "SURF\n" );
	VEdebug_surface( surf, TRUE );
	fprintf( stderr, "\n" );

	fprintf( stderr, "UV-IND: %d\n\n", uv_ind );

	fprintf( stderr, "UV-PAR: %lf\n\n", uv_par );

	fprintf( stderr, "PART-PARS: %lf %lf\n", part_pars[0], part_pars[1] );

	fprintf( stderr, "\n" );

	fprintf( stderr, "GIVEN MEM: %d\n", given_mem );
	}  /* VElog_BScsprtlncl */
#endif


/*--- VEis_iso_edge -----------------------------------------------*/

static IGRboolean VEis_iso_edge(	struct VEedge_header *edge,
					OMuword              osnum,
					IGRint               *uv_ind,
					IGRdouble            *const_par,
					IGRdouble            *par_range,
					IGRboolean           *reverse_flag,
					IGRboolean           *part_edge )

/*
NAME
	VEis_iso_edge (static)

DESCRIPTION
	This function determines if an edge is an isocurve in
	parametric space and returns an indicator of which
	dimension it is constant in, the constant parameter,
	the parametric range in the constant dimension, a flag
	indicating whether the edge is reversed in parameterization
	with respect to the surface, and a flag indicating whether
	the edge is a part edge (i.e, it is only part of the isocurve
	on the surface instead of the whole isocurve).

PARAMETERS
	edge (IN) - the edge to check
	osnum (IN) - the object space number of the edge
	uv_ind (OUT) - indicator of whether the iso curve is constant U
	               or constant V
	const_par (OUT) - the constant parameter of the iso curve
	par_range (OUT) - array of 2 doubles describing the parametric range
	                  of the isocurve in the constant dimension
	reverse_flag (OUT) - flag telling whether the edge is reversed in
	                     parameterization with respect to the surface
	part_edge (OUT) - flag telling whether the edge is a part edge

RETURN VALUES
	TRUE - if the edge is an isocurve
	FALSE - if the edge is not an isocurve

GLOBALS USED
	none

HISTORY
	02/28/91    S.P. Rogers
	   Creation Date
*/
	
	{
	IGRlong    sts, msg;
	IGRdouble  beg_pt[2], end_pt[2];

	if ( edge->status & EDGE_IS_ISOCURVE )
	   {
	   /* get beginning and ending points of the edge in UV space */
	   sts = om$send( msg      = message EMSedge.EMendpts( &msg, beg_pt, end_pt, NULL, NULL, NULL ),
	                  senderid = NULL_OBJID,
	                  targetid = edge->edge_id,
	                  targetos = osnum );

	      OM_ERRCHK( sts, "VEis_iso_edge: EMendpts send failed" ); 	
	      MSG_ERRCHK( msg, "VEis_iso_edge: EMendpts failed" ); 	

	   if ( edge->status & CONSTANT_U_ISOCURVE )
	      {
	      /* constant u */
	      *uv_ind = CONST_U_IND;
	      *const_par = beg_pt[0];
	      if ( beg_pt[1] < end_pt[1] )
	         {
	         *reverse_flag = FALSE;
	         par_range[0] = beg_pt[1];
	         par_range[1] = end_pt[1];
	         }
	      else
	         {
	         *reverse_flag = TRUE;
	         par_range[0] = end_pt[1];
	         par_range[1] = beg_pt[1];
	         }
	      }
	   else if ( edge->status & CONSTANT_V_ISOCURVE )
	      {
	      /* constant v */
	      *uv_ind = CONST_V_IND;
	      *const_par = beg_pt[1];

	      if ( beg_pt[0] < end_pt[0] )
	         {
	         *reverse_flag = FALSE;
	         par_range[0] = beg_pt[0];
	         par_range[1] = end_pt[0];
	         }
	      else
	         {
	         *reverse_flag = TRUE;
	         par_range[0] = end_pt[0];
	         par_range[1] = beg_pt[0];
	         }
	      }

	   *part_edge = (par_range[0] != 0.0) || (par_range[1] != 1.0);
	   return( TRUE );
	   }
	else
	   return( FALSE );

	}  /* VEis_iso_edge */


/*--- VEget_linestring_info -------------------------------------------------*/

static void VEget_linestring_info( 	struct VEedge_header *edge,
					OMuword              osnum,
					IGRint               *num_pts,
					IGRdouble            **uv_pts,
					IGRboolean           *reverse_flag )

/*
NAME
	VEget_linestring_info (static)

DESCRIPTION
	Given an edge that is represented as a linestring in UV space, this
	function gets the number of points and UV points that represent the
	linestring.  It also gets the reverse flag for the edge.

PARAMETERS
	edge (IN) - linestring edge
	osnum (IN) - object space number of 'edge'
	num_pts (OUT) - number of points in the linestring, 0 if an error
	                occurs
	uv_pts (OUT) - array of UV points representing the linestring, NULL
	               if an error occurs; the memory for this array is
	               allocated by this function and should be freed by the
	               caller
	reverse_flag (OUT) - reverse flag for the edge

GLOBALS USED
	none

HISTORY
	02/28/91  S.P. Rogers
	   Creation Date
*/

	{
	IGRlong               sts, msg;
	IGRshort              mat_type = MAIDMX;
	IGRushort             props;
	struct IGRpolyline    polyline;
	struct EMSpartolbasis partol;

	/* get the properties word for the edge */
	sts = om$send( msg      = message EMSedge.EMget_props( &msg, &props ),
	               senderid = NULL_OBJID,
	               targetid = edge->edge_id,
	               targetos = osnum );

	   OM_ERRCHK( sts, "VEget_linestring_info: EMget_props send failed" ); 	
	   MSG_ERRCHK( msg, "VEget_linestring_info: EMget_props failed" ); 	

	if ( ! (1 & sts & msg) )
	   {
	   *num_pts = 0;
	   *uv_pts = NULL;
	   return;
	   }
	   
	/* Have the linestring reversed if the edge is reverse connected and  */
	/* the other edge of the shared edge is the edge for which VE is      */
	/* maintaining geometry.  This is done so the start/end points of the */
	/* edges match up and is required because VE always sets reverse to   */
	/* FALSE when getting the edge geometry during the marking phase.     */
	*reverse_flag = ( (props & EMED_REVERSE_CONNECT) &&
	                  ( ( (edge->status & WAS_A_DUMMY) && (!(edge->status & USING_DUMMY_GEOMETRY)) ) ||
	                    ( (edge->status & REAL_SHARED_EDGE) && (edge->status & USING_DUMMY_GEOMETRY) ) ) );

	partol.is_valid = FALSE;
	partol.in_world = TRUE;
	partol.mat      = id_matrix;
	partol.mattyp   = &mat_type;

	polyline.num_points = 0;
	polyline.points = NULL;
	sts = om$send( msg      = message EMSedge.EMgetpygeom( &msg, 0, MAXINT,
	                                                       *reverse_flag, NULL, &polyline, &partol,
	                                                       NULL ),
	               senderid = NULL_OBJID,
	               targetid = edge->edge_id,
	               targetos = osnum );

	   OM_ERRCHK( sts, "VEget_linestring_info: EMgetpygeom send failed" ); 	
	   MSG_ERRCHK( msg, "VEget_linestring_info: EMgetpygeom failed" ); 	

	if ( ! (1 & sts & msg) )
	   {
	   *num_pts = 0;
	   *uv_pts = NULL;
	   }
	else
	   {
	   *num_pts = polyline.num_points;
	   *uv_pts = polyline.points;
	   }

	}  /* VEget_linestring_info */


/*--- VEmap_uv_isocurve_points_to_curve ----------------------------------------*/

static void VEmap_uv_isocurve_points_to_curve(
					struct VEedge_header  *edge,
					struct IGRbsp_surface *surf,
					struct IGRbsp_curve   *curve,
					IGRdouble             const_par,
					IGRdouble             u1, 
					IGRdouble             u2,
					IGRboolean            curve_on_surface,
					IGRboolean            curve_reversed,
					IGRboolean            part_edge,
					IGRdouble             *mapped_u1,
					IGRdouble             *mapped_u2 )

/*
NAME
	VEmap_uv_isocurve_points_to_curve (static)

DESCRIPTION
	This function maps two points on a isocurve of a surface to the
	parametric space of a curve that represents the isocurve.  The curve
	that is being mapped to might not be on the surface that is being
	mapped from and it might not even be an isocurve on the surface to
	which it belongs (e.g., shared edges).

PARAMETERS
	edge (IN) - the edge header for the isocurve we are mapping from
	surf (IN) - the surface on which the isocurve we are mapping from lies
	curve (IN) - the curve that we are mapping to
	const_par (IN) - the constant parameter of the isocurve
	u1 (IN) - the first parameter to map
	u2 (IN) - the second parameter to map
	curve_on_surface (IN) - TRUE, if the curve we are mapping to was
	                        extracted from the surface we are mapping from
	curve_reversed (IN) - TRUE, if the curve we are mapping to is reversed
	                      in parameterization with respect to the isocurve
	                      it represents (only valid if 'curve_on_surface'
	                      is TRUE)
	part_edge (IN) - TRUE, if the curve we are mapping to is a part edge
	                 (i.e., it isn't the entire isocurve on the surface)
	                 (only valid if 'curve_on_surface' is TRUE)
	mapped_u1 (OUT) - the mapped parameter of 'u1'
	mapped_u2 (OUT) - the mapped parameter of 'u2'

GLOBALS USED
	none

ALGORITHM
	The basic algorithm is to map from UV space on the surface to XYZ
	space to U space on the target curve.  The parameters
	'curve_on_surface', 'curve_reversed', and 'part_edge' are used to make
	the mapping more efficient.  If 'curve_on_surface' is TRUE,
	'curve_reversed' is FALSE, and 'part_edge' is FALSE, then the curve
	that is being mapped to is assumed to be an extraction of the isocurve
	on the surface we are mapping from and thus no mapping is required.

HISTORY
	02/28/91    S.P. Rogers
	   Creation Date
	01/03/92    S.P. Rogers
	   Added the special case to determine if the curve that is being
	   mapped to is an extraction of the isocurve on the surface that
	   is being mapped from
*/

	{
	IGRlong    rc;
	IGRdouble  surf_u1, surf_v1, surf_u2, surf_v2;
	IGRdouble  xyz_pt[3];
	IGRdouble  u_par;
	IGRdouble  mid_u, max_u, min_u;
	IGRdouble  dist;
	IGRpoint   base_pt;

	if ( (curve_on_surface) && (! curve_reversed) && (!part_edge) && (curve->order != 2) )
	   {
	   /* The curve we are mapping to is on the surface we are mapping from AND  */
	   /* it is not reversed in parameterization with respect to the surface     */
	   /* AND the order of the curve is not 2 so it couldn't have been           */
	   /* been reparameterized for better processing (see VEget_edge_geometry()  */
	   /*. AND the curve is not a part edge (i.e., only part of the isocurve).   */
	   /* This is sufficient to say that the curve we are mapping to is the same */
	   /* curve you would get if you extracted the isocurve from the surface.    */
	   /* Because of this, the mapped parameters are equal to the parameters on  */
	   /* isoline of the surface.                                                */
	   *mapped_u1 = u1;
	   *mapped_u2 = u2;
	   return;
	   }

	if ( edge->status & CONSTANT_U_ISOCURVE )
	   {
	   surf_u1 = surf_u2 = const_par;
	   surf_v1 = u1;
	   surf_v2 = u2;
	   }
	else
	   {
	   surf_u1 = u1;
	   surf_u2 = u2;
	   surf_v1 = surf_v2 = const_par;
	   }

	/* map UV space point to XYZ */
	BSsfeval( surf, surf_u1, surf_v1, 0, (IGRpoint *)xyz_pt, &rc );

	   BS_ERRCHK( rc, "VEmap_uv_isocurve_point_to_curve: BSsfeval failed" );

	/* map XYZ point to curve */
	BSmdstptcv( curve, xyz_pt, &u_par, base_pt, &dist, &rc );

	   BS_ERRCHK( rc, "VEmap_uv_isocurve_point_to_curve: BSmdstptcv failed" );

	*mapped_u1 = u_par;

	/* map UV space point to XYZ */
	BSsfeval( surf, surf_u2, surf_v2, 0, (IGRpoint *)xyz_pt, &rc );

	   BS_ERRCHK( rc, "VEmap_uv_isocurve_point_to_curve: BSsfeval failed" );

	/* map XYZ point to curve */
	BSmdstptcv( curve, xyz_pt, &u_par, base_pt, &dist, &rc );

	   BS_ERRCHK( rc, "VEmap_uv_isocurve_point_to_curve: BSmdstptcv failed" );

	*mapped_u2 = u_par;

	if ( curve->phy_closed )
	   {
	   min_u = curve->knots[curve->order - 1];
	   max_u = curve->knots[curve->num_knots - curve->order ];

	   if ( (*mapped_u1 == min_u) && (*mapped_u2 == min_u) )
	      *mapped_u2 = max_u;
	   else if ( (*mapped_u1 == min_u) || (*mapped_u2 == min_u) )
	      {
	      mid_u = (u1 + u2) * 0.5;

	      if ( edge->status & CONSTANT_U_ISOCURVE )
	         surf_v2 = mid_u;
	      else
	         surf_u2 = mid_u;

	      /* map UV space point to XYZ */
	      BSsfeval( surf, surf_u2, surf_v2, 0, (IGRpoint *)xyz_pt, &rc );

	         BS_ERRCHK( rc, "VEmap_uv_isocurve_point_to_curve: BSsfeval failed" );

	      /* map XYZ point to curve */
	      BSmdstptcv( curve, xyz_pt, &u_par, base_pt, &dist, &rc );

	         BS_ERRCHK( rc, "VEmap_uv_isocurve_point_to_curve: BSmdstptcv failed" );

	      if ( *mapped_u2 == min_u )
	         {
	         if ( u_par > *mapped_u1 )
	            *mapped_u2 = max_u;
	         }
	      else
	         {
	         if ( u_par > *mapped_u2 )
	            *mapped_u2 = max_u;
	         }

	      }

	   }  /* end: curve is physically closed */

	}  /* VEmap_uv_isocurve_point_to_curve */


/*--- VEmap_uv_linestring_point_to_curve ----------------------------------------*/

static IGRdouble VEmap_uv_linestring_point_to_curve( index, num_uv_pts, uv_pts, surf, curve )

	IGRdouble             index;
	IGRint                num_uv_pts;
	IGRdouble             *uv_pts;
	struct IGRbsp_surface *surf;
	struct IGRbsp_curve   *curve;

/*
NAME
	VEmap_uv_linestring_point_to_curve (static)

DESCRIPTION
	Given an index into an array of UV points, the UV points, a surface,
	and a curve, this function maps the UV point to the U space of the
	curve.  The index is a floating point number and the fractional part
	of the index is used to linearly interpolate between two adjacent
	UV points.

PARAMETERS
	index (IN) - the index of the point in the array of UV points to map
	num_uv_pts (IN) - the number of points in the array
	uv_pts (IN) - the array of UV points
	surf (IN) - the surface to map from
	curve (IN) - the curve to map to

GLOBALS USED
	none

RETURN VALUES
	The U parameter on the curve that represents the same XYZ point as the
	UV point on the surface.

HISTORY
	02/28/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    rc;
	IGRint     int_part, ind1, ind2;
	IGRdouble  frac_part, u, v;
	IGRdouble  xyz_pt[3];
	IGRdouble  u_par;
	IGRdouble  dist;
	IGRpoint   base_pt;

	if ( index < 0 )
	   index = 0.0;
	else if ( index > (num_uv_pts - 1) )
	   index = num_uv_pts - 1;

	/* the following two special cases make sure that closed curves */
	/* don't cause a problem (they are also a speed enhancement)    */
	if ( index == 0.0 )
	   {
	   /* special case for first point on linestring       */
	   /* return the u value of the beginning of the curve */
	   return( curve->knots[ curve->order - 1 ] );
	   }
	else if ( index == (num_uv_pts - 1) )
	   {
	   /* special case for last point on linestring  */
	   /* return the u value of the end of the curve */	   
	   return( curve->knots[ curve->num_knots - curve->order ] );
	   }
	   
	/* interpolate UV point from index */
	int_part = index;
	frac_part = index - int_part;
	ind1 = int_part * 2;
	ind2 = (int_part + 1) * 2;
	u = uv_pts[ind1] + (uv_pts[ind2] - uv_pts[ind1]) * frac_part;
	v = uv_pts[ind1+1] + (uv_pts[ind2+1] - uv_pts[ind1+1]) * frac_part;
	
	/* map UV space point to XYZ */
	BSsfeval( surf, u, v, 0, (IGRpoint *)xyz_pt, &rc );

	   BS_ERRCHK( rc, "VEmap_uv_linestring_point_to_curve: BSsfeval failed" );

	/* map XYZ point to curve */
	BSmdstptcv( curve, xyz_pt, &u_par, base_pt, &dist, &rc );

	   BS_ERRCHK( rc, "VEmap_uv_linestring_point_to_curve: BSmdstptcv failed" );

	return( u_par );

	}  /* VEmap_uv_linestring_point_to_curve */


/*--- VEinterpret_math_classification ---------------------------------------*/

static IGRint VEinterpret_math_classification( edge_class )

	IGRint               edge_class;

/*
NAME
	VEinterpret_math_classification (static)

DESCRIPTION
	This function takes the classification of an edge returned by the math
	routines and maps into into the classifications used by Visible Edges.

PARAMETERS
	edge_class (IN) - the classification return by the math routines
	                  for 'edge'

RETURN VALUES
	The VE counterpart of the math classification is returned.  The
	possible values are: VISIBLE_NON_PROFILE, VISIBLE_PROFILE,
	HIDDEN_NON_PROFILE, and HIDDEN_NORMAL_FLIP.  VISIBLE_PROFILE is
	returned is the math classification is invalid.

GLOBALS USED
	none

HISTORY
	02/28/91  S.P. Rogers
	   Creation Date
*/

	{
	IGRint classification;

	switch ( edge_class )
	   {
	   case 0 :  /* near - TOWARD, far - TOWARD */
	      classification = VISIBLE_NON_PROFILE;
	      break;
	   case 1 :  /* near - TOWARD, far - AWAY */
	   case 2 :  /* near - TOWARD, far - PERPINDICULAR */
	   case 5 :  /* near - AWAY, far - PERPINDICULAR */
	   case 6 :  /* near - PERPINDICULAR, far - TOWARD */
	   case 7 :  /* near - PERPINDICULAR, far - AWAY */
	   case 8 :  /* near - PERPINDICULAR, far - PERPINDICULAR */
	      classification = VISIBLE_PROFILE;
	      break;
	   case 3 :  /* near - AWAY, far - TOWARD */
	      classification = HIDDEN_NORMAL_FLIP;
	      break;
	   case 4 :  /* near - AWAY, far - AWAY */
	      classification = HIDDEN_NON_PROFILE;
	      break;
	   default :
	      classification = VISIBLE_PROFILE;
	      break;
	   }  /* end: switch */

	return( classification );
	}  /* VEinterpret_math_classification */


/*--- VEdetermine_shared_edge_info --------------------------------------------------*/

static void VEdetermine_shared_edge_info( struct VEedge_header *edge1,
					  struct VEedge_header *edge2,
					  OMuword              osnum,
					  IGRint               *edge_opt,
					  IGRint               *uv1_ind, 
					  IGRint               *uv2_ind,
					  IGRdouble            *const1_par,
					  IGRdouble            *const2_par,
					  IGRdouble            *par1_range,
					  IGRdouble            *par2_range,
					  IGRboolean           *reverse1, 
					  IGRboolean           *reverse2,
					  IGRboolean           *part_edge1,
					  IGRboolean           *part_edge2,
					  IGRint               *num_pts1,
					  IGRint               *num_pts2,
					  IGRdouble            **sf1_pars, 
					  IGRdouble            **sf2_pars )

/*
NAME
	VEdetermine_shared_edge_info (static)

DESCRIPTION
	This function determines the information about a shared edge pair.  The
	info that is determined is whether it is an isocurve/isocurve,
	isocurve/linestring, linestring/linestring, or linestring/isocurve
	pair.  If an edge is an isocurve, the following information is also
	determined: uv indicator, constant parameter, parametric range,
	reverse flag, and part edge flag.  If an edge is a linestring, the
	following information is also determined: reverse flag, number of
	points, and the uv points.

PARAMETERS
	edge1 (IN) - the real shared edge
	edge2 (IN) - the dummy shared edge
	osnum (IN) - the object space number of the edges
	edge_opt (OUT) - the type of shared edge pair
	uv1_ind (OUT) - uv indicator for edge1 if edge1 is an isocurve
	uv2_ind (OUT) - uv indicator for edge2 if edge2 is an isocurve
	const1_par (OUT) - constant parameter for edge1 if edge1 is an isocurve
	const2_par (OUT) - constant parameter for edge2 if edge2 is an isocurve
	par1_range (OUT) - parametric range for edge1 if edge1 is an isocurve
	par2_range (OUT) - parametric range for edge2 if edge2 is an isocurve
	reverse1 (OUT) - reverse flag for edge1
	reverse2 (OUT) - reverse flag for edge2
	part_edge1 (OUT) - part edge flag for edge1 if edge1 is an isocurve
	part_edge2 (OUT) - part edge flag for edge2 if edge2 is an isocurve
	num_pts1 (OUT) - number of points on edge1 if edge1 is a linestring
	num_pts2 (OUT) - number of points on edge2 if edge2 is a linestring
	sf1_pars (OUT) - uv points of edge1 is edge1 is a linestring
	sf2_pars (OUT) - uv points of edge2 is edge2 is a linestring

GLOBALS USED
	none

HISTORY
	01/02/92  S.P. Rogers
	   Creation Date (extracted from VEsplit_and_classify_shared_edges)
*/

	{
	if ( VEis_iso_edge( edge1, osnum, uv1_ind, const1_par, par1_range, reverse1, part_edge1 ) )
	   {
	   if ( VEis_iso_edge( edge2, osnum, uv2_ind, const2_par, par2_range, reverse2, part_edge2 ) )
	      {
	      /* both edges are isocurves */
	      *edge_opt = EDGE_OPT_ISO_ISO;
	      }
	   else
	      {
	      /* edge1 is an isocurve and edge2 is a linestring */
	      *edge_opt = EDGE_OPT_ISO_LST;
	      VEget_linestring_info( edge2, osnum, num_pts2, sf2_pars, reverse2 );
	      }
	   }
	else
	   {
	   if ( VEis_iso_edge( edge2, osnum, uv2_ind, const2_par, par2_range, reverse2, part_edge2 ) )
	      {
	      /* edge1 is a linestring and edge2 is an isocurve */
	      /* this case should NEVER happen (I mean NEVER)   */
	      *edge_opt = EDGE_OPT_LST_ISO;
	      }
	   else
	      {
	      /* both edges linestrings */
	      *edge_opt = EDGE_OPT_LST_LST;
	      VEget_linestring_info( edge1, osnum, num_pts1, sf1_pars, reverse1 );
	      VEget_linestring_info( edge2, osnum, num_pts2, sf2_pars, reverse2 );
	      }
	   }

	}  /* VEdetermine_shared_edge_info */


#define SWITCH_VARIABLES_IF_NEEDED			                      \
	                                                                      \
	if ( (edge_opt == EDGE_OPT_LST_LST) && (num_pts1 > num_pts2) )        \
	   {	                                                              \
	   /* for the linestring/linestring case the answer is returned */    \
	   /* w.r.t. the edge with the fewest number of points          */    \
	   gmsurf1a = gmsurf2;                                                \
	   gmsurf2a = gmsurf1;                                                \
	   surf1a = surf2;                                                    \
	   surf2a = surf1;                                                    \
	   reverse1a = reverse2;                                              \
	   reverse2a = reverse1;                                              \
	   part_edge1a = part_edge2;                                          \
	   part_edge2a = part_edge1;                                          \
	   num_pts1a = num_pts2;                                              \
	   sf1a_pars = sf2_pars;                                              \
	   num_pts2a = num_pts1;                                              \
	   sf2a_pars = sf1_pars;                                              \
	   }                                                                  \
	else                                                                  \
	   {                                                                  \
	   gmsurf1a = gmsurf1;                                                \
	   gmsurf2a = gmsurf2;                                                \
	   surf1a = surf1;                                                    \
	   surf2a = surf2;                                                    \
	   reverse1a = reverse1;                                              \
	   reverse2a = reverse2;                                              \
	   part_edge1a = part_edge1;                                          \
	   part_edge2a = part_edge2;                                          \
	   num_pts1a = num_pts1;                                              \
	   sf1a_pars = sf1_pars;                                              \
	   num_pts2a = num_pts2;                                              \
	   sf2a_pars = sf2_pars;                                              \
	   }                                                                  \


/*--- VEsplit_and_classify_shared_edges --------------------------------------*/

static void VEsplit_and_classify_shared_edges( real_elem, real_edge, real_prev_edge )

	struct VEelement_header *real_elem;
	struct VEedge_header    **real_edge;
	struct VEedge_header    **real_prev_edge;

/*
NAME
	VEsplit_and_classify_shared_edges (static)

DESCRIPTION
	This function will split and classify the parting line segmetns of a
	shared edge pair from a solid given the real shared edge and the
	element the real shared edge is on.  The real edge that is passed in
	is replaced in its edge list with the split and classified edges.  New
	dummy edges that go along with the split pieces are also created and
	substitued for the original dummy edge in its edge list.

PARAMETERS
	real_elem (IN) - the element to which the real shared edge belongs
	real_edge (IN/OUT) - the real edge to be split and classified
	real_prev_edge (IN/OUT) - the edge before the real edge in the edge
	                          list

GLOBALS USED
	none

HISTORY
	02/28/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong                 rc;
	IGRint                  edge_opt;
	IGRint                  uv1_ind = 0 , uv2_ind = 0;
	IGRdouble               const1_par = 0.0, const2_par = 0.0;
	IGRdouble               par1_range[2], par2_range[2];
	IGRdouble               u1_range[2], v1_range[2], u2_range[2], v2_range[2];
	IGRint                  num_pts1 = 0, num_pts2 = 0, num_pts1a = 0, num_pts2a = 0;
	IGRdouble               *sf1_pars = NULL, *sf2_pars = NULL, *sf1a_pars = NULL, *sf2a_pars = NULL;
	IGRint                  num_part;
	IGRdouble               *part1_pars = NULL, stack_part1_pars[SHARED_EDGE_PARTING_MEM * 2];
	IGRdouble               *part2_pars = NULL, stack_part2_pars[SHARED_EDGE_PARTING_MEM * 2];
	IGRdouble               *part_indices = NULL, stack_part_indices[SHARED_EDGE_PARTING_MEM * 2];
	IGRdouble               *cur_part_indices = NULL;
	IGRdouble               *cv1_pars, stack_cv1_pars[SHARED_EDGE_CLASSIFY_MEM + 1];
	IGRdouble               *cv2_pars, stack_cv2_pars[SHARED_EDGE_CLASSIFY_MEM + 1];
	IGRdouble               *lstr_ind, stack_lstr_ind[SHARED_EDGE_CLASSIFY_MEM + 1];
	IGRint                  *seg_classes, stack_seg_classes[SHARED_EDGE_CLASSIFY_MEM];
	IGRint                  num_segs;
	IGRint                  ii, jj;
	IGRboolean              real_edge_on_surf1;
	IGRboolean              reverse1, reverse2, reverse1a, reverse2a;
	IGRboolean              part_edge1 = FALSE, part_edge2 = FALSE, part_edge1a, part_edge2a;
	IGRboolean              had_to_alloc_2sfcsp = FALSE, had_to_alloc_shprtcl = FALSE;
	IGRdouble               u_start, u_end, temp_u;
	IGRdouble               *pars1 = NULL, *pars2 = NULL;
	struct VEelement_header *dummy_elem;
	struct VEedge_header    *dummy_edge, *dummy_prev_edge;
	struct VEedge_header    *head = NULL, *tail = NULL;
	struct VEedge_header    *class_head = NULL, *class_tail = NULL;
	struct VEedge_header    *unclass_head = NULL, *unclass_tail = NULL;
	struct VEedge_header    *saved_next_edge;
	struct VEedge_header    *new_edge;
	struct BSgeom_bsp_surf  *gmsurf1, *gmsurf2, *gmsurf1a = NULL, *gmsurf2a = NULL;
	struct IGRbsp_surface   *surf1, *surf2, *surf1a = NULL, *surf2a = NULL;
	struct VEedge_header    *edge1, *edge2;
	

	dummy_edge = (*real_edge)->shared_edge;
	dummy_elem = (*real_edge)->shared_elem;

	if ( ! VEfind_other_shared_edge( dummy_edge->edge_id, dummy_edge, dummy_elem,
	                                 &dummy_prev_edge, &dummy_edge ) )
	   return;

	/* initialize the necessary variables */
	if ( (*real_edge)->status & USING_DUMMY_GEOMETRY )
	   {
	   /* the curve geometry stored with 'real_edge' is really the */
	   /* geometry of the dummy edge                               */
	   real_edge_on_surf1 = FALSE;
	   gmsurf1 = dummy_elem->geom.gmsurf;
	   surf1 = dummy_elem->geom.gmsurf->bspsf;
	   edge1 = dummy_edge;
	   memcpy( u1_range, dummy_elem->u_range, sizeof( IGRdouble ) * 2 );
	   memcpy( v1_range, dummy_elem->v_range, sizeof( IGRdouble ) * 2 );
	   gmsurf2 = real_elem->geom.gmsurf;
	   surf2 = real_elem->geom.gmsurf->bspsf;
	   edge2 = *real_edge;
	   memcpy( u2_range, real_elem->u_range, sizeof( IGRdouble ) * 2 );
	   memcpy( v2_range, real_elem->v_range, sizeof( IGRdouble ) * 2 );
	   }
	else
	   {
	   /* the curve geometry stored with 'real_edge' is the */
	   /* geometry of the real edge                         */
	   real_edge_on_surf1 = TRUE;
	   gmsurf2 = dummy_elem->geom.gmsurf;
	   surf2 = dummy_elem->geom.gmsurf->bspsf;
	   edge2 = dummy_edge;
	   memcpy( u2_range, dummy_elem->u_range, sizeof( IGRdouble ) * 2 );
	   memcpy( v2_range, dummy_elem->v_range, sizeof( IGRdouble ) * 2 );
	   gmsurf1 = real_elem->geom.gmsurf;
	   surf1 = real_elem->geom.gmsurf->bspsf;
	   edge1 = *real_edge;
	   memcpy( u1_range, real_elem->u_range, sizeof( IGRdouble ) * 2 );
	   memcpy( v1_range, real_elem->v_range, sizeof( IGRdouble ) * 2 );
	   }

	VEdetermine_shared_edge_info( edge1, edge2, real_elem->env->osnum, &edge_opt,
	                              &uv1_ind, &uv2_ind, &const1_par, &const2_par,
	                              par1_range, par2_range,
	                              &reverse1, &reverse2,
	                              &part_edge1, &part_edge2,
	                              &num_pts1, &num_pts2,
	                              &sf1_pars, &sf2_pars );

	if ( edge_opt == EDGE_OPT_LST_ISO )
	   {
	   /* this case should NEVER happen */
	   fprintf( stderr, "VE PANIC: Linestring/Isocurve case in edge classification\n" );
	   (*real_edge)->status |= (ALREADY_CLASSIFIED | VISIBLE_PROFILE);
	   return;
	   }

	if ( (edge_opt == EDGE_OPT_ISO_ISO) || (edge_opt == EDGE_OPT_ISO_LST) )
	   {
	   /* update parametric range for math routines to consider */
	   /* on surfaces that have an iso curve                    */
	   if ( uv1_ind == CONST_U_IND )
	      memcpy( v1_range, par1_range, sizeof( IGRdouble ) * 2 );
	   else
	      memcpy( u1_range, par1_range, sizeof( IGRdouble ) * 2 );

	   if ( edge_opt == EDGE_OPT_ISO_ISO )
	      {
	      /* update range for math routine to consider */
	      if ( uv2_ind == CONST_U_IND )
	         memcpy( v2_range, par2_range, sizeof( IGRdouble ) * 2 );
	      else
	         memcpy( u2_range, par2_range, sizeof( IGRdouble ) * 2 );
	      }
	   }

#if LOG_BS2sfprtcsp
	VElog_BS2sfprtcsp( surf1, surf2,
	                   u1_range, v1_range, u2_range, v2_range,
	                   edge_opt, uv1_ind, uv2_ind, const1_par, const2_par,
	                   num_pts1, num_pts2, sf1_pars, sf2_pars, SHARED_EDGE_PARTING_MEM );
#endif

#if TIMING
	times( &VEs_time );
#endif

	/* find out which sections of the shared edges are parting lines */
	BS2sfprtcsp( surf1, surf2,
	             u1_range, v1_range, u2_range, v2_range,
	             edge_opt, uv1_ind, uv2_ind, const1_par, const2_par,
	             num_pts1, num_pts2, sf1_pars, sf2_pars,
	             SHARED_EDGE_PARTING_MEM,
	             &num_part,
	             stack_part1_pars, stack_part2_pars, stack_part_indices,
	             &had_to_alloc_2sfcsp,
	             &part1_pars, &part2_pars,
	             &part_indices, &rc );
#if TIMING
	times( &VEe_time );
	VEcount_2sfpart++;
	VEtime_2sfpart += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                      (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif

	if ( rc != BSSUCC )
	   {
	   /* math failure => mark whole edge as a VISIBLE PROFILE */
	   (*real_edge)->status |= (ALREADY_CLASSIFIED | VISIBLE_PROFILE);
	   return;
	   }

	if ( ! had_to_alloc_2sfcsp )
	   {
	   part1_pars = stack_part1_pars;
	   part2_pars = stack_part2_pars;
	   part_indices = stack_part_indices;
	   }

	if ( num_part )
	   {
	   VEinit_temp_list( *real_edge );

	   SWITCH_VARIABLES_IF_NEEDED;

	   /* loop over all of the parting line segments */
	   for ( ii = 0; ii < num_part; ii++ )
	      {
	      switch ( edge_opt )
	         {
	         case EDGE_OPT_ISO_ISO : /* both iso-curves */
	            if ( part1_pars[ii*2] < par1_range[0] )
	               part1_pars[ii*2] = par1_range[0];
	            else if ( part1_pars[ii*2] > par1_range[1] )
	               part1_pars[ii*2] = par1_range[1];

	            if ( part1_pars[ii*2+1] < par1_range[0] )
	               part1_pars[ii*2+1] = par1_range[0];
	            else if ( part1_pars[ii*2+1] > par1_range[1] )
	               part1_pars[ii*2+1] = par1_range[1];

	            if ( part1_pars[ii*2] == part1_pars[ii*2+1] )
	               {
	               /* check for bad data returned by BS2sfprtcsp() */
	               u_start = u_end = 0.0;
	               }
	            else
	               {
	               VEmap_uv_isocurve_points_to_curve( edge1, surf1, (*real_edge)->gm_curve3d->bspcv,
	                                                  const1_par, part1_pars[ii*2], part1_pars[ii*2+1],
	                                                  real_edge_on_surf1,
	                                                  (real_edge_on_surf1) ? reverse1a : reverse2a,
	                                                  (real_edge_on_surf1) ? part_edge1a : part_edge2a,
	                                                  &u_start, &u_end );
	               }

	            pars1 = &part1_pars[ii*2];
	            pars2 = &part2_pars[ii*2];
	            break;

	         case EDGE_OPT_LST_LST : /* both linestrings */
	            cur_part_indices = &part_indices[ii*2];
	            u_start = VEmap_uv_linestring_point_to_curve( cur_part_indices[0],
	                                                          num_pts1a, sf1a_pars,
	                                                          surf1a, (*real_edge)->gm_curve3d->bspcv );
	            u_end = VEmap_uv_linestring_point_to_curve( cur_part_indices[1],
	                                                        num_pts1a, sf1a_pars,
	                                                        surf1a, (*real_edge)->gm_curve3d->bspcv );
	            break;

	         case EDGE_OPT_ISO_LST :  /* iso curve and linestring */
	            if ( part1_pars[ii*2] < par1_range[0] )
	               part1_pars[ii*2] = par1_range[0];
	            else if ( part1_pars[ii*2] > par1_range[1] )
	               part1_pars[ii*2] = par1_range[1];

	            if ( part1_pars[ii*2+1] < par1_range[0] )
	               part1_pars[ii*2+1] = par1_range[0];
	            else if ( part1_pars[ii*2+1] > par1_range[1] )
	               part1_pars[ii*2+1] = par1_range[1];

	            if ( part1_pars[ii*2] == part1_pars[ii*2+1] )
	               {
	               /* check for bad data returned by BS2sfprtcsp() */
	               u_start = u_end = 0.0;
	               }
	            else
	               {
	               VEmap_uv_isocurve_points_to_curve( edge1, surf1, (*real_edge)->gm_curve3d->bspcv,
	                                                  const1_par, part1_pars[ii*2], part1_pars[ii*2+1],
	                                                  real_edge_on_surf1,
	                                                  (real_edge_on_surf1) ? reverse1a : reverse2a,
	                                                  (real_edge_on_surf1) ? part_edge1a : part_edge2a,
	                                                  &u_start, &u_end );
	               }

	            pars1 = &part1_pars[ii*2];
	            break;

	         default :
		    u_start = u_end = 0.0;
	            break;

	         }  /* end: swtich */

	      if ( u_start == u_end )
	         continue;
	      else if ( u_start > u_end )
	         {
	         temp_u = u_start;
	         u_start = u_end;
	         u_end = temp_u;
	         }

	      /* mark this parting line segment as overlapped on the real edge */
	      /* to indicate that it has already been classified               */
	      VEadd_overlap_region( u_start, u_end, *real_edge, UNKNOWN, 0.00001 );

#if LOG_BSshprtlncl
	      VElog_BSshprtlncl( gmsurf1a, gmsurf2a, edge_opt,
	                         uv1_ind, uv2_ind, const1_par, const2_par,
	                         pars1, pars2,
	                         num_pts1a, sf1a_pars,
	                         num_pts2a, sf2a_pars,
	                         cur_part_indices,
	                         !reverse1a, !reverse2a, SHARED_EDGE_CLASSIFY_MEM );
#endif

	      /* classify this parting line segment */
	      cv1_pars = cv2_pars = NULL;
	      lstr_ind = NULL;
	      seg_classes = NULL;

#if TIMING
	      times( &VEs_time );
#endif
	      BSshprtlncl( gmsurf1a, gmsurf2a, edge_opt,
	                   uv1_ind, uv2_ind, const1_par, const2_par,
	                   pars1, pars2,
	                   num_pts1a, num_pts2a,
	                   sf1a_pars, sf2a_pars,
	                   cur_part_indices,
	                   !reverse1a, !reverse2a,
	                   SHARED_EDGE_CLASSIFY_MEM,
	                   &num_segs,
	                   stack_cv1_pars, stack_cv2_pars, stack_lstr_ind, stack_seg_classes,
	                   &had_to_alloc_shprtcl,
	                   &cv1_pars, &cv2_pars,
	                   &lstr_ind, &seg_classes, &rc );
#if TIMING
	      times( &VEe_time );

	      VEcount_shprtcl++;
	      VEtime_shprtcl += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                            (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif
	         BS_ERRCHK( rc, "VEsplit_and_classify_shared_edges: BSshprtlncl failed" );

	      if ( ! had_to_alloc_shprtcl )
	         {
	         cv1_pars = stack_cv1_pars;
	         cv2_pars = stack_cv2_pars;
	         lstr_ind = stack_lstr_ind;
	         seg_classes = stack_seg_classes;
	         }

	      if ( rc != BSSUCC )
	         {
	         /* math error => mark this parting line segment as a VISIBLE_PROFILE */
	         new_edge = VEedge_split( *real_edge, u_start, u_end );
	         new_edge->status &= (~TOTALLY_OVERLAPPED);
	         new_edge->status |= (ALREADY_CLASSIFIED | VISIBLE_PROFILE);
	         VEfind_curve_range( new_edge->gm_curve3d->bspcv, new_edge->range );
	         VEadd_edges_to_list( new_edge, &class_head, &class_tail );
	         continue;
	         }

	      /* loop over each classification segment for this parting region */
	      for ( jj = 0; jj < num_segs; jj++ )
	         {
	         switch ( edge_opt )
	            {
	            case EDGE_OPT_ISO_ISO : /* both iso-curves */
	               VEmap_uv_isocurve_points_to_curve( edge1, surf1a, (*real_edge)->gm_curve3d->bspcv,
	                                                  const1_par, cv1_pars[jj], cv1_pars[jj+1],
	                                                  real_edge_on_surf1,
	                                                  (real_edge_on_surf1) ? reverse1a : reverse2a,
	                                                  (real_edge_on_surf1) ? part_edge1a : part_edge2a,
	                                                  &u_start, &u_end );
	               break;

	            case EDGE_OPT_LST_LST : /* both linestrings */
	               u_start = VEmap_uv_linestring_point_to_curve( lstr_ind[jj],
	                                                             num_pts1a, sf1a_pars,
	                                                             surf1a, (*real_edge)->gm_curve3d->bspcv );
	               u_end = VEmap_uv_linestring_point_to_curve( lstr_ind[jj+1],
	                                                           num_pts1a, sf1a_pars,
	                                                           surf1a, (*real_edge)->gm_curve3d->bspcv );

	               break;

	            case EDGE_OPT_ISO_LST :  /* iso curve and linestring */
	               VEmap_uv_isocurve_points_to_curve( edge1, surf1a, (*real_edge)->gm_curve3d->bspcv,
	                                                  const1_par, cv1_pars[jj], cv1_pars[jj+1],
	                                                  real_edge_on_surf1,
	                                                  (real_edge_on_surf1) ? reverse1a : reverse2a,
	                                                  (real_edge_on_surf1) ? part_edge1a : part_edge2a,
	                                                  &u_start, &u_end );
	               break;

	            default :
	               u_start = u_end = 0.0;
	               break;
	            }  /* end: switch */

	         if ( u_start == u_end )
	            {
	            /* put in because Rob said BSshprtlncl */
	            /* sometimes returns zero length spans */
	            continue;
	            }
	         else if ( u_start > u_end )
	            {
	            temp_u = u_start;
	            u_start = u_end;
	            u_end = temp_u;
	            }

	         new_edge = VEedge_split( *real_edge, u_start, u_end );
	         new_edge->status &= (~TOTALLY_OVERLAPPED);
	         new_edge->status |= ALREADY_CLASSIFIED;
	         VEfind_curve_range( new_edge->gm_curve3d->bspcv, new_edge->range );
	         VEadd_edges_to_list( new_edge, &class_head, &class_tail );

	         new_edge->status |= VEinterpret_math_classification( seg_classes[jj] );
	         }  /* end: for ( jj ... */

	      if ( had_to_alloc_shprtcl )
	         {
	         if ( cv1_pars )
	            free( (IGRchar *) cv1_pars );
	         if ( cv2_pars )
	            free( (IGRchar *) cv2_pars );
	         if ( lstr_ind )
	            free( (IGRchar *) lstr_ind );
	         if ( seg_classes )
	            free( (IGRchar *) seg_classes );
	         }

	      }  /* end: for ( ii ... */

	   /* generate a list of the unclassified pieces of the edge by */
	   /* splitting out the non-overlaped regions from 'real_edge'  */
	   /* VEsplit_out_temp_list_overlaps() frees the edge passed in */
	   saved_next_edge = (*real_edge)->next;
	   VEsplit_out_temp_list_overlaps( *real_edge, &unclass_head, &unclass_tail );

	   /* link up the unclassified and classified pieces */
	   if ( class_head )
	      {
	      head = class_head;
	      if ( unclass_head )
	         {
	         class_tail->next = unclass_head;
	         tail = unclass_tail;
	         }
	      else
	         tail = class_tail;
	      }
	   else
	      {
	      head = unclass_head;
	      tail = unclass_tail;
	      }
	      
	   /* create new dummies for the split pieces */
	   VEcreate_dummies_for_split_pieces( real_elem, head, dummy_edge, dummy_elem );

	   /* add split pieces to the edge list where 'real_edge' was */
	   tail->next = saved_next_edge;
	   if ( *real_prev_edge )
	      (*real_prev_edge)->next = head;
	   else
	      real_elem->edges = head;
	   *real_edge = tail;
	
	   if ( had_to_alloc_2sfcsp )
	      {
	      if ( part1_pars )
	         free( (IGRchar *) part1_pars );
	      if ( part2_pars )
	         free( (IGRchar *) part2_pars );
	      if ( part_indices )
	         free( (IGRchar *) part_indices );
	      }

	   }  /* end: if ( num_part ) */

	if ( sf1_pars )
	   free( (IGRchar *) sf1_pars );
	if ( sf2_pars )
	   free( (IGRchar *) sf2_pars );

	}  /* VEsplit_and_classify_shared_edges */


/*--- VEsplit_and_classify_parting_line ---------------------------------------------*/

static void  VEsplit_and_classify_parting_line( element, edge, prev_edge )

	struct VEelement_header *element;
	struct VEedge_header    **edge;
	struct VEedge_header    **prev_edge;

/*
NAME
	VEsplit_and_classify_parting_line (static)

DESCRIPTION
	This function will split and classify a parting line.  The entire
	parting line will be classified into pieces that are either
	VISIBLE_PROFILE or HIDDEN_NORMAL_FLIP.  The parting line that is
	passed in is replaced in its edge list with a list of the split
	and classified edges.

PARAMETERS
	element (IN) - the element to which the parting line belongs
	edge (IN/OUT) - the parting line to be split and classified
	prev_edge (IN/OUT) - the edge before the parting line in the edge list

GLOBALS USED
	none

HISTORY
	03/08/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong              rc;
	IGRint               num_segs;
	IGRint               *seg_indices = NULL, stack_seg_indices[PARTING_CLASSIFY_MEM + 1];
	IGRint               *seg_classes = NULL, stack_seg_classes[PARTING_CLASSIFY_MEM];
	IGRint               ii;
	IGRboolean           had_to_alloc= FALSE;
	IGRdouble            u_start, u_end;
	struct VEedge_header *saved_edge;
	struct VEedge_header *new_edge;
	struct VEedge_header *head = NULL, *tail = NULL;
	struct IGRbsp_curve  *curve;

	saved_edge = *edge;
	curve = (*edge)->gm_curve3d->bspcv;

#if TIMING
	times( &VEs_time );
#endif
	BSsmprtlncl( element->geom.gmsurf,
	             curve->num_poles, (IGRpoint *)curve->poles,
	             PARTING_CLASSIFY_MEM,
	             &num_segs,
	             stack_seg_indices, stack_seg_classes,
	             &had_to_alloc,
	             &seg_indices, &seg_classes, &rc );

#if TIMING
	times( &VEe_time );

	VEcount_smprtcl++;
	VEtime_smprtcl += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                      (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif
	   BS_ERRCHK( rc, "VEsplit_and_classify_parting_line: BSsmprtlncl failed" );

	if ( ! had_to_alloc )
	   {
	   seg_indices = stack_seg_indices;
	   seg_classes = stack_seg_classes;
	   }

	if ( rc != BSSUCC )
	   {
#if LOG_BSsmprtlncl
	VElog_BSsmprtlncl( element->geom.gmsurf, curve->num_poles, curve->poles, PARTING_CLASSIFY_MEM );
#endif

	   /* math error => mark this parting line as a VISIBLE_PROFILE */
	   (*edge)->status |= (ALREADY_CLASSIFIED | VISIBLE_PROFILE);
	   return;
	   }

	for ( ii = 0; ii < num_segs; ii++ )
	   {
	   u_start = curve->knots[ seg_indices[ii] + 1 ];
	   u_end = curve->knots[ seg_indices[ii+1] + 1 ];

	   if ( u_start == u_end )
	      {
	      /* put in because Rob said BSsmprtlncl */
	      /* sometimes returns zero length spans */
	      continue;
	      }

	   new_edge = VEedge_split( *edge, u_start, u_end );
	   new_edge->status |= ALREADY_CLASSIFIED;
	   VEfind_curve_range( new_edge->gm_curve3d->bspcv, new_edge->range );
	   VEadd_edges_to_list( new_edge, &head, &tail );

	   new_edge->status |= VEinterpret_math_classification( seg_classes[ii] );
	   }  /* end: for ( ii ... */

	/* insert split pieces where 'edge' was */
	tail->next = (*edge)->next;
	if ( *prev_edge )
	   (*prev_edge)->next = head;
	else
	   element->edges = head;

	*edge = tail;

	/* free the edge header that was passed in */
	VEfree_visib_node_list( saved_edge->visib_list );
	VEfree_edge_header( saved_edge );

	if ( had_to_alloc )
	   {
	   if ( seg_indices )
	      free( (IGRchar *) seg_indices );
	   if ( seg_classes )
	      free( (IGRchar *) seg_classes );
	   }

	}  /* VEsplit_and_classify_parting_line */


/*--- VEsplit_and_classify_cusp_line ---------------------------------------------*/

static void VEsplit_and_classify_cusp_line( element, edge, prev_edge )

	struct VEelement_header *element;
	struct VEedge_header    **edge;
	struct VEedge_header    **prev_edge;

/*
NAME
	VEsplit_and_classify_cusp_line (static)

DESCRIPTION
	This function will split and classify the parting line segments of a
	cusp line.  The cusp line that is passed in is replaced in its edge
	list with a list of the split and classified edges.  

PARAMETERS
	element (IN) - the element to which the cusp line belongs
	edge (IN/OUT) - the cusp line to be split and classified
	prev_edge (IN/OUT) - the edge before the cusp line in the edge list

GLOBALS USED
	none

HISTORY
	03/11/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong              rc;
	IGRint               uv_ind;
	IGRdouble            uv_par;
	IGRint               num_part, num_segs;
	IGRint               ii, jj;
	IGRboolean           had_to_alloc_partcsp = FALSE, had_to_alloc_csprtlncl = FALSE;
	IGRdouble            *part_pars = NULL, stack_part_pars[CUSP_PARTING_MEM * 2];
	IGRdouble            u_start, u_end;
	IGRdouble            min_u, max_u;
	IGRdouble            *cv_pars, stack_cv_pars[CUSP_CLASSIFY_MEM + 1];
	IGRint               *seg_classes, stack_seg_classes[CUSP_CLASSIFY_MEM];
	struct VEedge_header *new_edge;
	struct VEedge_header *saved_next_edge;
	struct VEedge_header *head = NULL, *tail = NULL;
	struct VEedge_header *class_head = NULL, *class_tail = NULL;
	struct VEedge_header *unclass_head = NULL, *unclass_tail = NULL;


	/* get iso curve information for the cusp line */
	if ( (*edge)->status & CONSTANT_U_ISOCURVE )
	   {
	   /* constant u */
	   uv_ind = CONST_U_IND;
	   uv_par = (*edge)->iso_parm;
	   }
	else
	   {
	   /* constant v */
	   uv_ind = CONST_V_IND;
	   uv_par = (*edge)->iso_parm;
	   }

#if TIMING
	times( &VEs_time );
#endif
	/* determine what pieces of the cusp line are parting lines */
	BSsfpartcsp( element->geom.gmsurf->bspsf,
	             element->u_range, element->v_range,
	             uv_ind, uv_par,
	             CUSP_PARTING_MEM,
	             &num_part,
	             stack_part_pars, &had_to_alloc_partcsp,
	             &part_pars, &rc );

#if TIMING
	times( &VEe_time );

	VEcount_partcsp++;
	VEtime_partcsp += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                      (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif

	   BS_ERRCHK( rc, "VEsplit_and_classify_cusp_line: BSsfpartcsp failed" );

	if ( ! had_to_alloc_partcsp )
	   part_pars = stack_part_pars;

	if ( (rc == BSSUCC) && num_part )
	   {
	   VEinit_temp_list( *edge );

	   min_u = (*edge)->gm_curve3d->bspcv->knots[(*edge)->gm_curve3d->bspcv->order - 1];
	   max_u = (*edge)->gm_curve3d->bspcv->knots[(*edge)->gm_curve3d->bspcv->num_knots - (*edge)->gm_curve3d->bspcv->order];

	   /* loop over all of the parting line segments */
	   for ( ii = 0; ii < num_part; ii++ )
	      {
	      u_start = part_pars[ii*2];
	      u_end = part_pars[ii*2+1];

	      if ( (u_start > max_u) || (u_end < min_u) || (u_start == u_end) )
	         continue;

	      if ( u_start < min_u )
	         u_start = min_u;
	      if ( u_end > max_u )
	         u_end = max_u;

	      /* classify this parting line segment */
	      cv_pars = NULL;
	      seg_classes = NULL;

#if LOG_BScsprtlncl
	      VElog_BScsprtlncl( element->geom.gmsurf->bspsf,
	                         uv_ind, uv_par, &part_pars[ii*2], 
	                         CUSP_PARTING_MEM );
#endif

#if TIMING
	      times( &VEs_time );
#endif
	      BScsprtlncl( element->geom.gmsurf->bspsf,
	                   uv_ind, uv_par, &part_pars[ii*2],
	                   CUSP_CLASSIFY_MEM,
	                   &num_segs,
	                   stack_cv_pars, stack_seg_classes, &had_to_alloc_csprtlncl,
	                   &cv_pars, &seg_classes, &rc );
#if TIMING
	      times( &VEe_time );
	      VEcount_csprtcl++;
	      VEtime_csprtcl += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                            (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif

	         BS_ERRCHK( rc, "VEsplit_and_classify_cusp_line: BScsprtlncl failed" );

	      if ( ! had_to_alloc_csprtlncl )
	         {
	         cv_pars = stack_cv_pars;
	         seg_classes = stack_seg_classes;
	         }

	      if ( rc != BSSUCC )
	         continue;  /* math error => skip this parting line segment */

	      /* mark this parting line segment as overlapped on the edge */
	      /* so we'll know it's already been classified               */
	      VEadd_overlap_region( u_start, u_end, *edge, UNKNOWN, 0.00001 );

	      /* loop over each classification */
	      for ( jj = 0; jj < num_segs; jj++ )
	         {
	         u_start = cv_pars[jj];
	         u_end = cv_pars[jj+1];

	         if ( u_start == u_end )
	            continue; /* BScsprtlncl sometimes returns zero length spans */

	         new_edge = VEedge_split( *edge, u_start, u_end );
	         new_edge->status &= (~TOTALLY_OVERLAPPED);
	         new_edge->status |= ALREADY_CLASSIFIED;
	         VEfind_curve_range( new_edge->gm_curve3d->bspcv, new_edge->range );
	         VEadd_edges_to_list( new_edge, &class_head, &class_tail );

	         new_edge->status |= VEinterpret_math_classification( seg_classes[jj] );
	         }  /* end: for ( jj ... */

	      if ( had_to_alloc_csprtlncl )
	         {
	         if ( cv_pars )
	            free( (IGRchar *) cv_pars );
	         if ( seg_classes )
	            free( (IGRchar *) seg_classes );
	         }

	      }  /* end: for ( ii ... */

	   saved_next_edge = (*edge)->next;

	   /* VEsplit_out_temp_list_overlaps() frees the edge that is passed in */
	   VEsplit_out_temp_list_overlaps( *edge, &unclass_head, &unclass_tail );

	   /* link up classified/unclassified edge into one list */
	   if ( class_head )
	      {
	      head = class_head;
	      if ( unclass_head )
	         {
	         class_tail->next = unclass_head;
	         tail = unclass_tail;
	         }
	      else
	         tail = class_tail;
	      }
	   else
	      {
	      head = unclass_head;
	      tail = unclass_tail;
	      }
	      
	   /* add split pieces to the edge list where 'edge' was */
	   tail->next = saved_next_edge;
	   if ( *prev_edge )
	      (*prev_edge)->next = head;
	   else
	      element->edges = head;

	   *edge = tail;
	
	   if ( had_to_alloc_partcsp )
	      {
	      if ( part_pars )
	         free( (IGRchar *) part_pars );
	      }

	   }  /* end: if ( num_part ) */

	}  /* VEsplit_and_classify_cusp_line */


/*--- VEclassify_edges_of_solid ----------------------------------------------*/

void VEclassify_edges_of_solid ( solid )

	struct VEelement_header *solid;

/*
NAME
	VEclassify_edges_of_solid

DESCRIPTION
	This function splits and classifies all of the edges of a solid into
	four categories:

		VISIBLE_PROFILE
		VISIBLE_NON_PROFILE
		HIDDEN
		HIDDEN_NORMAL_FLIP

	If tracing is not being performed, then any edge that is classified as
	HIDDEN or HIDDEN_NORMAL_FLIP is output and removed from its edge list
	because further processing of the edge is not needed.

PARAMETERS
	solid (IN/OUT) - the solid to be classified

GLOBALS USED
	VEexec_status.VEabort    - set if the stop sign was pressed
	VEexec_status.VEtracing  - referenced to determine if tracing is being
	                           done
	VEuse_classifcation_alg  - referenced to determine if classification
	                           should be done

ALGORITHM
	The edges are classified in two steps.  The first step is to determine
	the parts of the edges that are horizon edges and classify them.  This
	step is performed using specialized math routines.  The next step is
	to determine the classification for the non-horizon parts of the
	edges.

NOTES
	The edges of the solid that are passed may be split by this function so
	any pointers to the edges or edge-lists of the solid should be treated
	as invalid when this function returns.

HISTORY
	02/28/91    S.P. Rogers
	   Creation Date
*/

	{
	struct VEelement_header *this_element;
	struct VEedge_header    *this_edge, *prev_edge;

	if ( ! VEuse_classification_alg )
	   return;

	/* determine which parts of edges are horizons and classify them */
	this_element = solid->next_in_solid;  /* skip solid header */
	while ( this_element )
	   {
	   VEupdate_heartbeat();
	   if ( IGEstop() )
	      {
	      VEexec_status.VEabort = TRUE;
	      break;
	      }

	   prev_edge = NULL;
	   this_edge = this_element->edges;
	   while ( this_edge )
	      {
	      if ( this_edge->status & REAL_SHARED_EDGE )
	         {
	         VEsplit_and_classify_shared_edges( this_element, &this_edge, &prev_edge );
	         }
	      else if ( (this_edge->type == HORIZON_EDGE) || (this_edge->type == HORIZON_CURVE) )
	         {
	         VEsplit_and_classify_parting_line( this_element, &this_edge, &prev_edge );
	         }
	      else if ( this_edge->type == SHARP )
	         {
	         VEsplit_and_classify_cusp_line( this_element, &this_edge, &prev_edge );
	         }

	      prev_edge = this_edge;
	      this_edge = this_edge->next;
	      }  /* end; while ( this_edge ) */

	   this_element = this_element->next_in_solid;
	   }  /* end: while ( this_element ) */

	if ( ! VEexec_status.VEabort )
	   {
	   /* classify the non-horizon  pieces */
	   VEsplit_and_classify_non_horizon_edges( solid );

	   /* output any edges that have been classified as hidden */
	   if ( (! VEexec_status.VEabort) && (! VEexec_parms.VEtracing) )
	      {
	      this_element = solid->next_in_solid;  /* skip solid header */
	      while ( this_element )
	         {
	         VEoutput_hidden_edges( this_element );
	         this_element = this_element->next_in_solid;
	         }
	      }
	   }

	} /* VEclassify_edges_of_solid */

end implementation Root;
