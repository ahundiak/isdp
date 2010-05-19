/* $Id: VD_EMintf.I,v 1.6 2001/10/08 21:54:02 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintf/cmd / VD_EMintf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VD_EMintf.I,v $
 *	Revision 1.6  2001/10/08 21:54:02  hans
 *	Fix for TR# MP5640 (etl10419)
 *	
 *	Revision 1.5  2001/07/27 15:53:08  jayadev
 *	fix for etl#9533
 *
 *	Revision 1.4  2001/07/10 18:35:52  hans
 *	No TR. Optimizations for suppressing FALSE Interferences
 *
 *	Revision 1.3  2001/02/09 14:13:01  hans
 *	Just some cleanups
 *
 *	Revision 1.2  2001/01/12 19:11:03  hans
 *	SP16 import to CVS
 *
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
 *	Initial import to CVS
 *
# Revision 1.35  2000/12/14  21:16:26  pinnacle
# Replaced: vds/vdintf/cmd/VD_EMintf.I for:  by jwfrosch for Service Pack
#
# Revision 1.20  2000/09/26  18:43:08  pinnacle
# Replaced: vds/vdintf/cmd/VD_EMintf.I for:  by jwfrosch for Service Pack
#
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *	06/26/97	HF	Phase (1) of major restructuring:
 *				Make interferences ASSOCIATIVE in stead of
 *				just dumb graphics.
 *
 *				Based on ORIGINAL FILE : EMintf.I
 *				The function VD_EManalyzeIntf() is an adapted
 *				version of the original EMS function EManalyzeIntf()
 *
 *	10/30/97	ah	UnInit warnings
 *
 *	12/22/97	HF	Changed from using instance variable "STATE" of ci_macro
 *				(this was causing problems for "nested" macros) for
 *				storing interference_flags, to using the instance variable
 *				"internal_buffer" (==>>union state intf_flags) instead.
 *
 *				The ci_macro method give_internal_ptr will return a pointer
 *				to this instance variable.
 *				Since we manipulate a pointer into the instance data of the
 *				ci_macro, it is IMPORTANT to be VERY carefull in order to not
 *				corrupt the ci_macro !!!
 *
 *	06/29/99	HF	Fix for TR 179900673
 *	01/28/00	HF	Fix for TR 179901020
 *
 *	05/30/00	HF	TR 179901258
 *                              Functionality to prevent generating so-called 'false' interferences...
 *
 *	09/20/00	HF	NO TR
 *                              Functionality to dramatically improve performance ...
 *                              Testcase: 1461 x 2154 elements went from 20 HOURS to 6 MINUTES !!!
 *                              (there also was far less swap space usage (~15MB <<==>> ~150MB !!!)
 *
 *                              ONLY if (assoc_opt == 0 OR assoc_opt == 1)
 *                              ==========================================
 *                              Function VDrange_box_test() does a preliminary range-box intersection
 *                              and stores the result in the 2-dim array: boxint[NumEle1][NumEle2]
 *
 *	10/18/00	HF	NO TR
 *                              Further performance improvements ...
 *                              Testcase: 4113 x 4113 elements went from 105 MINUTES to 21 MINUTES !!!
 *
 *                              ONLY if (assoc_opt == 0 OR assoc_opt == 1)
 *                              ==========================================
 *                              Use the function EMintersect_two_element() whenever possible, instead of
 *                              EMintersect_surfaces or the method GRowner.GRpass_messg->EMSsurface.EMowner_sfsfint()
 *
 *	11/02/2000	HF	No TR
 *                              Added functionality to enable/disable Reduce_Range of objects...
 *                              Created function VDreduce_range()
 *	11/17/2000	HF	No TR
 *                              New function to remove ACmodel, ACrg_collect and to_components from RTree:
 *                                        (Used in PPL COz_cleanRT)
 *                              VDdelete_class_and_comp_from_rtree(class_id);
 *	12/02/2000	HF	TR 4219 (etl4760)
 *                              When dealing with ROUTE-compoments,
 *                              do NOT reduce_range, ONLY GRgetrang.
 *      07/27/01        Jayadev etl#9533
 *	10/08/2001	HF	Fix for TR# MP5640 (etl10419)
 * -------------------------------------------------------------------*/
/*
Abstract
  The function VD_EManalyzeIntf() is a modified version of the original EMS function EManalyzeIntf()
  This function analyzes interference between EACH element of a set against ALL elements of another set.

Arguments
	SetInfo1	input		The set information
	Ele1		input		Set of elements to be checked for
					interference. There will be a structure
					per element.
	NumEle1		input		Number of elements in above array.
	setnum1		input		The index or number of the set
					that should be included in the report
	SetInfo2	input		The set information
	Ele2  		input		Set of elements against which each
					element of the first set is to
					be checked.
	NumEle2 	input		Number of elements in above array
	setnum1		input		The index or number of the set
					that should be included in the report
	options		input		See EMSintf.h
	ReportFileName	input		Filename in which the report is to
					be written. If EMinterference_NoReport
					is specified, this will be
					ignored. If report desired and this
					is NULL, stdout will be used.
	const_list	input		If intersection curves are to be
					constructed.
	result		output		Results of the analysis, optionally
					returned back.
	num_results	output		number of structures in the result
					array.
					All the output memory is always
					allocated by the method. All the
					memory MUST be freed via the function
					EMintf_free().
  The following arguments (all INPUT) are only present in VD_EManalyzeIntf()...
	Form	 form_ptr		ptr to StatusForm
	IGRint	 assoc_opt		0 = No Assoc; 1 = Limited Assoc; 2 = Full Assoc
	IGRint	 VD_avoid_false_interf	If 1: Shrink smallest of 2 objects to minimize 'False' Interferences
	IGRint	 VD_use_old_intf	If 1: Use EMSsurface.EMowner_sfsfint; else use EMintersect_two_element()
	IGRint	 VD_skip_reduce_range	0 = ReduceRange; 1 = NO ReduceRange
	IGRchar	*prog_msg_file		Filename of file containing progress messages

Return Values

Files
	EMsfintf.I
History
	SM	03-Jun-89	Creation.
	SM	18-Sep-89	Added and supported option EMSintf_Display
				to display the curve and volume elements
				as soon as they are computed.
	SM	11-May-90	If same object is in both sets, prevent
				self intersection.
        SM      08-Apr-92       When processing same GRid but with different
                                envs (as in same file attatched twice in
                                different orientations),  make copies before
                                intersection. This is because
                                the inters list and the uv intobj are linked
                                based on GRid only. If both operands have
				same GRid everything goes haywire wrt tracing
                                fixing etc.
        NP      27-Aug-92	Modified for ANSI compliance.
        ???     22-Mar-93       Who knows?
        scw     25-jun-93       Added buffer_size to ex$message call
*/

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

class implementation EMSsurface;

#include "EMS.h"

#ifndef DEBUG
#define DEBUG 0
#endif

#include <stdio.h>
#include <string.h>

#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSsfparms.h"
#include "OMmacros.h"
#include "bsdefs.h"
#include "emsdef.h"
#include "emssfint.h"
#include "EMSintf.h"
#include "griodef.h"
#include "msdef.h"
#include "msmacros.h"         /* struct MS_sd_msg for ex$message */
#include "emssfintdef.h"
#include "emsbool.h"
#include "emserr.h"
#include "emsmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "bsparameters.h"
#include "bserr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "igr.h"
#include "godef.h"
#include "go.h"
#include "nddef.h"
#include "parametric.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grmacros.h"
#include "bslenvec.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bsscale_pts.h"
#include "bsbxint.h"
#include "bsrgbxint.h"
#include "matypemx.h"

#define M_PI            3.14159265358979323846
#define M_PI_2          1.57079632679489661923
#define M_PI_4          0.78539816339744830962

/* ex$message */

#include "EC_M.h"       /* Command strings */
#include "EC_I.h"       /* Status strings */
#include "EC_P.h"       /* Prompt strings */
#include "EC_F.h"       /* Error box strings */
#include "EC_E.h"       /* Error strings */
#include "EMStpmacros.h"
#include "EMSsffmacros.h"
#include "EMcp.h"

#include	<FI.h>

#include "AS_status.h"
#include	<v_miscmacros.h>

#define	VD_DEBUG
#include	<VDdebug.h>
#include	<VDintf_rev.h>		/* struct for storing VDS representation info	*/

#if DEBUG
#define ResultBufInc	1
#else
#define ResultBufInc	20
#endif

#define			MAX_TEMP	2
#define			MAX_FEET	10
#define                 MAX_NUM_SRF     500

from	ACcpx_defn	import	ACgive_name;
from	ACcpx		import	find_macro;
from	ACcpx		import	ACfind_exp_temp_obj;
from	ACcpx		import	ACfind_exp_temp_struct;
from	NDmacro		import	ACreturn_foot;
from	NDnode		import	NDget_objects, NDchg_state, NDchange_node, NDcompute_node,
                                ASreturn_go, NDdisconnect, NDconnect;
from	ci_macro	import	set_all_extern_feet, give_internal_ptr;
from	ci_macro	import	init;
from	ACncpx		import	ACget_NV_rep, ACget_STATE, ACchg_STATE;

/* method specific error handling macros.
*/
#define EMlocerrinit(cond, e1, e2, e3, junk) \
	{\
	 if((cond)) \
	  {\
	   (e1).objid = NULL_OBJID;\
	   (e2).objid = NULL_OBJID;\
	   (e3).objid = NULL_OBJID;\
	   (junk) = FALSE;\
	  }\
	}

#define EMlocerrhndlr(cond, code, reccode, ele1, ele2, numf, f, buf, skip)\
	{\
	 if( (cond) ) \
	  {\
	   *(code) = (reccode);\
	   EMintf_recordFailure( (code), (ele1), (ele2), (numf), (f), (buf), EMqualitative);\
	   sts = OM_S_SUCCESS; \
	   if((skip)) continue;\
	  }\
	}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
// Forward declarations ...
extern IGRlong EMintersect_two_element
(
  struct GRlc_info      *p_ele1,
  struct GRlc_info      *p_ele2,
  IGRushort              trim_opt,
  struct GRvg_construct *cst,
  IGRlong               *num_inters,
  struct GRid          **GRinters,
  IGRlong               *msg
);

extern int VDconstruct_intersection_curves
(
  struct GRid		 CI_MACRO_ID,
  int			 recompute,
  struct GRid		*out_cvs,
  struct GRlc_info	*p_ele1,
  struct GRlc_info	*p_ele2
);

extern IGRlong VDrange_box_test
(
  IGRint                 avoid_false_interf,          /* I */
  IGRint                 set1_equals_set2,            /* I */
  IGRint                 NumEle1,                     /* I */
  IGRint                 NumEle2,                     /* I */
  struct GRlc_info      *Ele1,                        /* I */
  struct GRlc_info      *Ele2,                        /* I */
  FILE                  *fpdb,                        /* I */
  struct GRvg_construct *const_list,                  /* I */
  IGRchar             ***boxint,                      /* O Must be _FREE'd by caller */
  IGRlong               *EMmsg,                       /* O */
  IGRint                *boxcnt                       /* O */
);

extern IGRlong VDrecursCountGridsOnChan
(
  OM_S_OBJECT_LINKAGE	  ModelId,
  OM_S_CHANSELECT	 *my_chansel,
  short			  classid,
  short                   opt_all,
  int			 *NbFound
);

extern IGRlong VDrecursGetGridsFromChan
(
  OM_S_OBJECT_LINKAGE	  ModelId,
  OM_S_CHANSELECT	 *my_chansel,
  short			  classid,
  short                   opt_all,
  int			 *NbFound
);

extern void VDget_ptr_to_memory ( int nm );
extern void VDfree_ptr_to_memory();

extern IGRlong VDreduce_range
(
  IGRlong         *msg,
  struct GRmd_env *env_info,
  struct GRid     *in_id,
  GRrange          range
);

extern IGRlong VDget_accumulated_range
(
  IGRlong         *msg,
  struct GRid     *in_id,
  struct GRmd_env *env_info,
  GRrange          range
);

static IGRlong VDaccumulated_ranges
(
  IGRlong          *msg,
  struct GRid      *GRid_12,
  struct GRmd_env  *mdenv12,
  GRrange          *accu_rng
);

struct myrange
{
  IGRdouble         pt[6];
};

static IGRboolean VDtest_coinc_faces
(
  IGRlong          *msg,
  struct GRid      *GRid_12,
  struct GRmd_env  *mdenv12
);

extern IGRlong VDfind_coinc_faces
(
  IGRlong         *msg,
  struct GRid     *in_id,
  struct GRmd_env *env_info,
  GRrange        **range,
  IGRdouble       *ctpt,
  IGRint          *nm_rng
);

extern IGRlong VDget_true_range
(
  IGRlong         *msg,
  struct GRid      in_id,
  struct GRmd_env *md_env,
  GRrange          true_rng
);

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

extern OM_S_CHANSELECT AS_to_comp;
extern OMuword OPP_EMSslboolean_class_id, OPP_EMSsolid_class_id,
               OPP_EMSsfboolean_class_id, OPP_EMSsurface_class_id,
               OPP_EMSsubbs_class_id, OPP_EMScompsurf_class_id, OPP_GRcurve_class_id,
               OPP_EMSplane_class_id, OPP_EMSproject_class_id,
               OPP_VDdrwObj_class_id, OPP_VDdrwGm_class_id,
	       OPP_nci_macro_class_id, OPP_ACheader_class_id, OPP_ACmodel_class_id;

/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;


from GRowner     import GRget_siblings, GRpass_messg;
from EMSdpr      import EMmake_primitive1;
from EMSsubbs    import EMreduce_range;

#define MaxInters		 20
#define NUM_STATIC_SIBLINGS	 200

//#define	CLIX

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * HF: 06/10/97	  Make interferences ASSOCIATIVE in stead of just dumb graphics
 *
 * static GLOBAL variables for DATA transfer between :
 *
 *   function 1 : VD_EManalyzeIntf()
 *   function 2 : VDconstruct_intersection_curves()
 *			(embedded/called in CI_MACRO ppl : VDinterf_cvs.u)
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
#define ASSOC_OPTION_1   01
#define ASSOC_OPTION_2   02
#define AVOID_FALSE_INTF 04
%safe
static IGRlong           retmsg;
static IGRint            num_interf_cvs,
                         num_interf_GRid,
                         keep_inters,
                         always_make_macro,
                         avoid_false_interf, skip_reduce_range,
                         num_feet,     use_shrink_buffers,
                         use_old_intf, use_range_check,
                         idx_set1,     idx_set2,
                         shrink_buff1, shrink_buff2;
static IGRdouble         shrink_factor;
static struct EMSinters *inters[2];
static struct GRid      *shrunk_Set1, *shrunk_Set2;
static struct GRid      *p_FoundId, FoundId[MAX_NUM_SRF];
static int               nr_rangebox_swp, tot_coinc_face;
static int               post_process_inter, post_proc_deleted;
static FILE             *fp_post;
%endsafe
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

#include "ma.h"
#include "bstypes.h"

#define SCALE_FCT 0.999

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void myrgbxint(
  IGRpoint      min1,
  IGRpoint	max1,
  IGRpoint      min2,
  IGRpoint	max2,
  IGRboolean   *intersect,
  IGRpoint      newmin,
  IGRpoint	newmax,
  BSrc         *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#endif

  IGRdouble    dist_tol = 0.0;       /* distance tolerance value                */
  IGRint       i;                    /* loop indice                             */

  *rc = BSSUCC;
//    BSEXTRACTPAR( rc, BSTOLLENVEC, dist_tol);

  *intersect = TRUE;
  for (i=0;i < 3;i++)
  {
    newmin[i] = MAX(min1[i],min2[i]);
    newmax[i] = MIN(max1[i],max2[i]);
    if (((max1[i] + dist_tol) < min2[i]) || ((max2[i] + dist_tol) < min1[i]))
    {
      *intersect = FALSE;
      break;
    }
  }

  {
    if(BSERROR(*rc))
      BSdbgrc(*rc,"myrgbxint");
    return;
  }
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

// Function to enable toggling the value of post_process_inter (Post Process Interference)
// from within a PPL.
// Execute PPL: ci=toggle_post
//
// Some Struct Beams do have somewhat incorrect loopsets...
// This results sometimes in intersections where there should not be ANY !!!

int toggle_post_process_intf()
{
  if (post_process_inter)
  {
    post_process_inter = 0;
  }
  else
  {
    post_process_inter = 1;
  }
  return post_process_inter;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

// Function to enable toggling the value of use_shrink_buffers (Suppress False Interference)
// from within a PPL.
// Execute PPL: ci=toggle_sbuf
//
// For whatever mysterious reason, using buffers for storing the ID's of shrunk objects,
// seems to slow down the processing drastically, in stead of the expected opposite effect.
// So, for the time being, the default value for use_shrink_buffers = 0 ...
int toggle_shrink_buffers()
{
  if (use_shrink_buffers)
  {
    use_shrink_buffers = 0;
  }
  else
  {
    use_shrink_buffers = 1;
  }
  return use_shrink_buffers;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
// Function to enable modifying the value of shrink_factor (Suppress False Interference)
// from within a PPL.
// Execute PPL: ci=getsetscale

IGRdouble get_set_intf_shrinkage( double scale_in )
{
  if ( scale_in >= 0.9 && scale_in <= 0.9999 )
  {
    return (shrink_factor = scale_in);
  }
  else
  {
    return (shrink_factor = SCALE_FCT);
  }
}

IGRdouble get_intf_shrinkage()
{
  if ( shrink_factor >= 0.9 && shrink_factor <= 0.9999 )
  {
    return (shrink_factor);
  }
  else
  {
    return (shrink_factor = SCALE_FCT);
  }
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
// Function to enable/disable extra preprocessing in order to reduce the occurence of as many "FALSE"
// Interference's as possible from within a PPL.
//
// Execute PPL: ci=rngchk_intf
//
int range_check_intf()
{
  if (use_range_check)
  {
    use_range_check = 0;
  }
  else
  {
    use_range_check = 1;
  }
  return use_range_check;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static int test_shrink_range_boxes( GRrange *range, IGRpoint *ctrpt, IGRdouble scale )
{
  int        i0, j0, k0, shr_ind = -1;
  IGRlong    msg;
  IGRboolean sts[2];
  GRrange    newrng;
  IGRdouble  matrix[3][3];

  __enterFunction ( name = "test_shrink_range_boxes", argfmt = "scale = %18.15lf",
                    args = `scale`);

  for (i0=0; i0 < 3; i0++)
  {
    for (j0=0; j0 < 3; j0++)
    {
      matrix[i0][j0] = 0.0;
    }
  }
  matrix[0][0] = matrix[1][1] = matrix[2][2] = 1.0;

  for (i0=0, j0=1; i0 < 2; i0++, j0--)
  {
    for (k0=0; k0 < 6; k0++)
    {
      newrng[k0] = scale * ( range[i0][k0] - ctrpt[i0][k0%3] ) + ctrpt[i0][k0%3];
    }
    // Check if the range-boxes overlap...
    sts[i0] = BSbxint (&msg, &range[j0][0], &range[j0][3], &newrng[0], &newrng[3]);

    if (BSERROR(msg))
      goto quit;
  }
  if( sts[0] != sts[1] )
  {
    if ( sts[1] )
    {
      shr_ind = 0;
    }
    else
    {
      shr_ind = 1;
    }
    nr_rangebox_swp++;
    //printf("nr_rangebox_swp = %d\n", nr_rangebox_swp);
  }
  else if( sts[0] && sts[1] )
  {
    shr_ind = 2;
  }

quit:

  __exitFunction ( name = "test_shrink_range_boxes", argfmt = "shr_ind = %d, nr_rangebox_swp = %d, sts[] = [%d, %d]",
                   args = `shr_ind, nr_rangebox_swp, sts[0], sts[1]` );

  return (shr_ind);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

setup_scaling_matrix (
  IGRdouble  scale,
  IGRdouble *trn,
  IGRdouble *matrix,
  IGRshort  *matrix_type )
{
  IGRlong   i0, status;
  IGRdouble fact;
  __enterFunction ( name = "setup_scaling_matrix", argfmt = "scale = %lf, trn[] = %lf %lf %lf",
                    args = `scale, trn[0], trn[1], trn[2]`);

  for (i0=0; i0 < 16; i0++)
  {
    matrix[i0] = 0.0;
  }
  matrix[15]   = 1.0;
  matrix[0]    = matrix[5] = matrix[10] = scale;

  fact         = 1.0 - scale;
  matrix[3]    = trn[0] * fact;
  matrix[7]    = trn[1] * fact;
  matrix[11]   = trn[2] * fact;

  MAtypemx(&status, matrix, matrix_type);

  __exitFunction ( name = "setup_scaling_matrix", argfmt = "status = %d, matrix_type = %d",
                   args = `status, *matrix_type` );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDcheck_for_header_and_model
(
  struct GRid tstID
)
{
  OM_S_OBJECT_LINKAGE lobj1[10], lobj2[10];
  OMuint              cnt1 = 0, cnt2 = 0;
  int                 i0   = 0, j0   = 0, header_model = 0;
  IGRlong             status;

  __enterFunction ( name = "VDcheck_for_header_and_model", argfmt = "tstID = [%d,%d]",
                    args = `tstID.osnum, tstID.objid` );

  status =
    om$get_channel_count ( osnum        = tstID.osnum,
                           objid        = tstID.objid,
                           p_chanselect = &AS_to_comp,
                           count        = &cnt1 );
  if ( cnt1 < 10 )
  {
    status =
      om$get_channel_objects( osnum        = tstID.osnum,
                              objid        = tstID.objid,
                              p_chanselect = &AS_to_comp,
                              size         =  cnt1,
                              list         =  lobj1,
                              count        = &cnt1 );

    for (i0 = 0; i0 < cnt1; i0++)
    {
      struct GRid tmpID;
      OMuword     clid;

      tmpID.objid = lobj1[i0].S_objid;
      tmpID.osnum = lobj1[i0].osnum;

      om$get_classid ( objid = tmpID.objid, osnum = tmpID.osnum, p_classid = &clid);
      if ( om$is_ancestry_valid ( subclassid = clid, superclassid = OPP_ACheader_class_id ) == OM_S_SUCCESS)
      {
        status =
          om$get_channel_count ( osnum        = tmpID.osnum,
                                 objid        = tmpID.objid,
                                 p_chanselect = &AS_to_comp,
                                 count        = &cnt2 );
        if ( cnt2 < 10 )
        {
          status =
            om$get_channel_objects( osnum        = tmpID.osnum,
                                    objid        = tmpID.objid,
                                    p_chanselect = &AS_to_comp,
                                    size         =  cnt2,
                                    list         =  lobj2,
                                    count        = &cnt2 );

          for (j0 = 0; j0 < cnt2; j0++)
          {
            om$get_classid ( objid = lobj2[j0].S_objid, osnum = lobj2[j0].osnum, p_classid = &clid);

            if ( om$is_ancestry_valid ( subclassid = clid, superclassid = OPP_ACmodel_class_id ) == OM_S_SUCCESS)
            {
              header_model = 1;
              goto wrapup;
            }
          }
        }
      }
    }
  }
wrapup:
  __exitFunction ( name = "VDcheck_for_header_and_model", argfmt = "tstID = [%d,%d], header_model = %d, cnt1 = %d, cnt2 = %d, i0 = %d, j0 = %d",
                   args = `tstID.osnum, tstID.objid, header_model, cnt1, cnt2, i0, j0` );
  return header_model;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDget_comp_chan_crvs
(
  struct GRid   tstID,
  int          *nrobj,
  struct GRid **cmpID
)
{
  OM_S_OBJECT_LINKAGE *lobj1 = NULL;
  OMuint               cnt1  = 0;
  int                  i0    = 0, j0 = 0;
  IGRlong              status;
  OMuword              clid;
  struct GRid          tmpID;

  __enterFunction ( name = "VDget_comp_chan_crvs", argfmt = "tstID = [%d,%d]",
                    args = `tstID.osnum, tstID.objid` );

  *nrobj = 0;
  *cmpID = _MALLOC(1, struct GRid);

  if (! (*cmpID)) goto wrapup;

  om$get_classid ( objid = tstID.objid, osnum = tstID.osnum, p_classid = &clid);
  if ( om$is_ancestry_valid ( subclassid = clid, superclassid = OPP_GRcurve_class_id ) == OM_S_SUCCESS)
  {
    (*cmpID)[0] = tstID;
    *nrobj = 1;
  }
  else
  {
    status =
      om$get_channel_count ( osnum        = tstID.osnum,
                             objid        = tstID.objid,
                             p_chanselect = &AS_to_comp,
                             count        = &cnt1 );

    if ( cnt1 )
    {
      lobj1  = _MALLOC (cnt1, OM_S_OBJECT_LINKAGE);
      *cmpID = _REALLOC(*cmpID, cnt1, struct GRid);

      if ( lobj1 && (*cmpID) )
      {
        status =
          om$get_channel_objects( osnum        = tstID.osnum,
                                  objid        = tstID.objid,
                                  p_chanselect = &AS_to_comp,
                                  size         =  cnt1,
                                  list         =  lobj1,
                                  count        = &cnt1 );

        for (i0 = 0; i0 < cnt1; i0++)
        {
          tmpID.objid = lobj1[i0].S_objid;
          tmpID.osnum = lobj1[i0].osnum;

          om$get_classid ( objid = tmpID.objid, osnum = tmpID.osnum, p_classid = &clid);
          if ( om$is_ancestry_valid ( subclassid = clid, superclassid = OPP_GRcurve_class_id ) == OM_S_SUCCESS)
          {
            (*cmpID)[j0].objid = lobj1[i0].S_objid;
            (*cmpID)[j0].osnum = lobj1[i0].osnum;
            j0++;
          }
        }
        *nrobj = j0;
      }
      if(lobj1) { _FREE(lobj1); lobj1 = NULL; }
    }
  }
wrapup:
  __exitFunction ( name = "VDget_comp_chan_crvs", argfmt = "tstID = [%d,%d], cnt1 = %d, nrobj = %d",
                   args = `tstID.osnum, tstID.objid, i0, *nrobj` );
  return;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

IGRlong VDshrink_one_object
(
  struct GRid		 CI_MACRO_ID,		/* I */
  struct GRid		*GRid_12,		/* I */
  struct GRmd_env	*mdenv12,		/* I */
  struct GRmd_env       *mod_env,		/* I */
  struct GRid		*GRidcpy,		/* O Temporary GRid; must be deleted after intersection */
  int			*copy_num		/* O index(1/2) which of 2 objs is the smaller (range)  */
)
{
  static char           *superclassnm_1 = {"VRComponent"};
  static char           *superclassnm_2 = {"VRConcComp"};
  int                    i0, j0, idx = -1, shr_ind = -1, route_comp = 0, draw_comp = 0, found_shrunk = 0;
  IGRboolean		 world  = 1;
  IGRshort               matrix_type;
  IGRlong                status = 1, msg;
  IGRdouble              vctln  [2], matrix[16], scale, var_scl = 1.0, maxdst = 0.0, shr_dst;
  OMuword	         clid;
  struct GRid		 go_sup [2], TEMP[2];
  struct GRmd_env	 sup_env[2], new_env;
  GRrange		 range  [2], accu_rng[2];
  IGRpoint               ctrpt  [2];
  IGRvector              rgvec  [2], delta = {0.0};

  __enterFunction ( name = "VDshrink_one_object", argfmt = "GRid_12[0] = [%d,%d], GRid_12[1] = [%d,%d], CI_MACRO_ID = [%d,%d]",
                    args = `GRid_12[0].osnum, GRid_12[0].objid, GRid_12[1].osnum, GRid_12[1].objid, CI_MACRO_ID.osnum, CI_MACRO_ID.objid` );

  GRidcpy->objid = NULL_OBJID;
  GRidcpy->osnum = 2;
  *copy_num      = 0;

  go_sup [0]     = GRid_12[0];
  go_sup [1]     = GRid_12[1];

  sup_env[0]     = mdenv12[0];
  sup_env[1]     = mdenv12[1];
  new_env        = *mod_env;

  for ( i0=0; i0 < 2; i0++ )
  {
    status =
    om$send ( msg      = message GRvg.GRgetrang( &msg,
                                                 &sup_env[i0].md_env.matrix_type,
                                                  sup_env[i0].md_env.matrix,
                                                 &world,
                                                  range[i0] ),
              senderid = NULL_OBJID,
              targetid = go_sup[i0].objid,
              targetos = go_sup[i0].osnum );
    as$status();

    // Get centerpoint and range vector ...
    for (j0=0; j0 < 3; j0++)
    {
      ctrpt[i0][j0] = (range[i0][j0+3] + range[i0][j0]) * .5;
      rgvec[i0][j0] =  range[i0][j0+3] - range[i0][j0];
    }
    // Get length of range vector...
    vctln[i0]    = BSlenvec ( &msg, rgvec[i0] );

    __printf("GRgetrang: status = %d, msg = %d, go_sup[%d] = [%d,%d]\n    range[] = %lf %lf %lf\n              %lf %lf %lf",
             `status, msg, i0, go_sup[i0].osnum, go_sup[i0].objid,
              range[i0][0], range[i0][1], range[i0][2], range[i0][3], range[i0][4], range[i0][5]`);
  }
  // Determine which of the 2 objects has the smallest range...
  if ( vctln[0] <= vctln[1] )
  {
    *copy_num = 1;
  }
  else
  {
    *copy_num = 2;
  }
  if ( *copy_num )
    idx = *copy_num - 1;

  // Just quit if the range-boxes do not overlap...
  if ( ! BSbxint (&msg, &range[0][0], &range[0][3], &range[1][0], &range[1][3]) )
    goto quit;

  // Scale can be varied between 0.9 - 0.9999 ...
  scale = get_set_intf_shrinkage( shrink_factor );

  // In stead of using a fixed scale, determine a variable scale factor: var_scl...
  // The idea is the following: The largest (orthogonal) dimension of the range-box should NOT
  // shrink more than the amount (in millimeters) determined by: ((1.0 - scale) * 1000.0)
  //
  // Example: a box with largest dimension of  1000 mm. will shrink 1 mm ==>> scale == var_scl     = .999
  //          a box with largest dimension of   100 mm. will shrink 1 mm ==>> scale = .999 var_scl = .99
  //          a box with largest dimension of 10000 mm. will shrink 1 mm ==>> scale = .999 var_scl = .9999

  shr_dst = (1.0 - scale) * 1000.0;

  for (i0=0; i0 < 3; i0++)
  {
    delta[i0] = range[idx][i0+3] - range[idx][i0];
    if ( i0 == 0 )
    {
      maxdst = delta[i0];
    }
    else
    {
      maxdst = MAX(delta[i0], delta[i0-1]);
    }
  }

  if ( maxdst > shr_dst )
  {
    var_scl = (maxdst - shr_dst) / maxdst;
  }
  if ( var_scl < 0.9 )
  {
    printf("<<< Adjusting var_scale = %lg to 0.9 (GRid [%d,%d] [%d,%d], idx = %d) >>>\n",
           var_scl, GRid_12[0].osnum, GRid_12[0].objid, GRid_12[1].osnum, GRid_12[1].objid, idx);
    var_scl = 0.9;
  }

  if (use_range_check)
  {
    // Find which of the 2 range-boxes is the preferred candidate to shrink...
    shr_ind = test_shrink_range_boxes( range, ctrpt, var_scl );
    if ( shr_ind == 0 || shr_ind == 1 )
    {
      idx       = shr_ind;
      *copy_num = shr_ind + 1;
    }
    else if ( shr_ind == 2 )    // rangeboxes overlap in both combinations...
    {
      // Try the same procedure, with more accurate range-boxes from the accumulate range of the separate
      // surfaces of the (composite) objects...
      status = VDaccumulated_ranges ( &msg, GRid_12, mdenv12, accu_rng );

      // Find which of the 2 accumulated range-boxes is the preferred candidate to shrink...
      shr_ind = test_shrink_range_boxes( accu_rng, ctrpt, 0.99999 /*scale*/ );
      if ( shr_ind == 0 || shr_ind == 1 )
      {
        idx       = shr_ind;
        *copy_num = shr_ind + 1;
      }
    }
  }

  //setup_scaling_matrix ( scale,   ctrpt[idx], matrix, &matrix_type );
  setup_scaling_matrix ( var_scl, ctrpt[idx], matrix, &matrix_type );

  // If we have buffers shrunk_Set1 OR shrunk_Set2, check if object already has been shrunk ...
  if (use_shrink_buffers)
  {
    if      ( idx == 0 && shrink_buff1 == 1 && shrunk_Set1 && idx_set1 > -1 )
    {
      *GRidcpy = shrunk_Set1[idx_set1];
    }
    else if ( idx == 1 && shrink_buff2 == 1 && shrunk_Set2 && idx_set2 > -1 )
    {
      *GRidcpy = shrunk_Set2[idx_set2];
    }
    if ( GRidcpy->objid != NULL_OBJID )
    {
      status = 1;
      found_shrunk = 1;
      goto quit;
    }
  }

  if (VDcomment)
  {
    __printf("MAtypemx: matrix_type = %d, msg = %d, vctln[] = %lf %lf", `matrix_type, msg, vctln[0], vctln[1]`);
    for ( i0=0; i0 < 16; i0+=4 )
    {
      __printf("    %lf %lf %lf %lf", `matrix[i0], matrix[i0+1], matrix[i0+2], matrix[i0+3]`);
    }
  }

  // VDdrwObj objects do NOT behave correctly under GRcptform ...
  // An overwrite of GRcptform would be required ...
  // ===============================================
  // For the time being, get the VDdrwGm object on the to_component channel,
  // and perform the GRcptform on this object ...
  om$get_classid ( objid = go_sup[idx].objid, osnum = go_sup[idx].osnum, p_classid = &clid);
  if ( om$is_ancestry_valid ( subclassid = clid, superclassid = OPP_VDdrwObj_class_id ) == OM_S_SUCCESS)
  {
    OM_S_OBJECT_LINKAGE lobj1[10];
    OMuint              cnt1 = 0;

    draw_comp = 1;

    status =
      om$get_channel_count ( osnum        = go_sup[idx].osnum,
                             objid        = go_sup[idx].objid,
                             p_chanselect = &AS_to_comp,
                             count        = &cnt1 );
    if ( cnt1 < 10 )
    {
      status =
        om$get_channel_objects( osnum        = go_sup[idx].osnum,
                                objid        = go_sup[idx].objid,
                                p_chanselect = &AS_to_comp,
                                size         =  cnt1,
                                list         =  lobj1,
                                count        = &cnt1 );

      om$get_classid ( objid = lobj1[0].S_objid, osnum = lobj1[0].osnum, p_classid = &clid);

      if ( om$is_ancestry_valid ( subclassid = clid, superclassid = OPP_VDdrwGm_class_id ) == OM_S_SUCCESS)
      {
        struct GRid gr_id1;

        gr_id1.objid = lobj1[0].S_objid;
        gr_id1.osnum = lobj1[0].osnum;

        __printf ( "Replaced VDdrwObj = [%d,%d] ==>> VDdrwGm : [%d,%d]",
                   `go_sup[idx].osnum, go_sup[idx].objid, gr_id1.osnum, gr_id1.objid` );

        go_sup[idx] = gr_id1;
      }
    }
  }

  // Some ROUTE objects behave pretty weird under GRcptform ...
  // In particular these: VRComp   ==>>   ACheader   ==>>   ACmodel
  //                             to_comp           to_comp
  //
  // An overwrite of GRcptform would be required ...
  // ===============================================
  // Until we have this figured out, for the time being, just quit...
  //
  om$get_classid ( objid = go_sup[idx].objid, osnum = go_sup[idx].osnum, p_classid = &clid);
  if ( om$is_ancestry_valid ( subclassid = clid, superclassname = superclassnm_1 ) == OM_S_SUCCESS ||
       om$is_ancestry_valid ( subclassid = clid, superclassname = superclassnm_2 ) == OM_S_SUCCESS )
  {
//    route_comp = VDcheck_for_header_and_model ( go_sup[idx] );
    route_comp = 1;

    goto quit;
  }

  if (VDcomment)
  {
    __printf(">>>>> GRgraphics.GRcptform: go_sup[%d] = [%d,%d]",
             `idx, go_sup[idx].osnum, go_sup[idx].objid`);
    __printf("new_env.matrix_type = %d, new_env.md_id = [%d,%d]",
             `new_env.md_env.matrix_type, new_env.md_id.osnum, new_env.md_id.objid`);
    for ( i0=0; i0 < 16; i0+=4 )
    {
      __printf("    %lf %lf %lf %lf", `new_env.md_env.matrix[i0+0], new_env.md_env.matrix[i0+1],
                                       new_env.md_env.matrix[i0+2], new_env.md_env.matrix[i0+3]`);
    }

    __printf("sup_env[%d].matrix_type = %d, sup_env[%d].md_id = [%d,%d]",
             `idx, sup_env[idx].md_env.matrix_type, idx, sup_env[idx].md_id.osnum, sup_env[idx].md_id.objid`);
    for ( i0=0; i0 < 16; i0+=4 )
    {
      __printf("    %lf %lf %lf %lf", `sup_env[idx].md_env.matrix[i0+0], sup_env[idx].md_env.matrix[i0+1],
               sup_env[idx].md_env.matrix[i0+2], sup_env[idx].md_env.matrix[i0+3]`);
    }
  }

  // Scale (shrink) the smaller object of the 2...
  status =
    om$send ( msg      = message GRgraphics.GRcptform( &msg,
                                                       &sup_env[idx],
                                                        matrix,
                                                       &new_env,
                                                       &GRidcpy->objid ),
              senderid = NULL_OBJID,
              targetid = go_sup[idx].objid,
              targetos = go_sup[idx].osnum );
  as$status();
  if ( status != OM_S_SUCCESS && VDcomment ) om$report_error (sts = status);
  if ( ! ( status & msg & 1) )
  {
    GRidcpy->objid = NULL_OBJID;
  }

  // If we have buffers shrunk_Set1 OR shrunk_Set2, store the shrunk object ...
  if (use_shrink_buffers)
  {
    if      ( GRidcpy->objid != NULL_OBJID && idx == 0 && shrink_buff1 == 1 && shrunk_Set1 && idx_set1 > -1 )
    {
      shrunk_Set1[idx_set1] = *GRidcpy;
    }
    else if ( GRidcpy->objid != NULL_OBJID && idx == 1 && shrink_buff2 == 1 && shrunk_Set2 && idx_set2 > -1 )
    {
      shrunk_Set2[idx_set2] = *GRidcpy;
    }
  }

quit:

  if (found_shrunk)
  {
    if (idx == 0)
    {
      __exitFunction ( name   = "VDshrink_one_object",
                       argfmt = "status = %d, msg = %d, found_shrunk = %d, idx_set1 = %d, copy_num = %d, GRidcpy = [%d,%d]",
                       args   = `status, msg, found_shrunk, idx_set1, *copy_num, GRidcpy->osnum, GRidcpy->objid` );
    }
    else if (idx == 1)
    {
      __exitFunction ( name   = "VDshrink_one_object",
                       argfmt = "status = %d, msg = %d, found_shrunk = %d, idx_set2 = %d, copy_num = %d, GRidcpy = [%d,%d]",
                       args   = `status, msg, found_shrunk, idx_set2, *copy_num, GRidcpy->osnum, GRidcpy->objid` );
    }
  }
  else
  {
    __exitFunction ( name   = "VDshrink_one_object",
                     argfmt = "status = %d, msg = %d, route_comp = %d, draw_comp = %d, copy_num = %d, GRidcpy = [%d,%d]",
                     args   = `status, msg, route_comp, draw_comp, *copy_num, GRidcpy->osnum, GRidcpy->objid` );
  }

  return(status);

wrapup:

  __exit_error_Function ( name = "VDshrink_one_object" );
  status = 0;
  return (status);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDfind_common_children
(
  IGRlong		*msg,
  struct GRid		*templates,
  struct GRid		*mac_inter
)
{
  IGRlong		status;
  int			i0, j0, rc = 1;
  int			num_chld[MAX_TEMP];
  struct GRid		*chptr = NULL, *buffer = NULL, *child_0 = NULL, *child_1 = NULL;

  *msg = MSSUCC;

  __enterFunction ( name = "VDfind_common_children" );

  for (i0=0; i0 < MAX_TEMP; i0++)
  {
    status =
      om$send (	msg	 = message NDnode.NDget_objects (
						ND_CHILDREN | ND_IN_BUF, NULL, 0,
						&chptr,	0, OM_K_MAXINT, &num_chld[i0] ),
		targetid = templates[i0].objid,
		targetos = templates[i0].osnum,
		senderid = NULL_OBJID);

    __printf ("NDnode.NDget_objects: num_chld[%d]  = %d", `i0, num_chld[i0]` );

    if (i0 == 0)
    {
      if ( num_chld[i0] ) buffer = _MALLOC ( num_chld[i0], struct GRid );
    }
    else
    {
      if ( num_chld[i0] )
      {
	if (buffer) buffer = _REALLOC ( buffer, num_chld[0] + num_chld[i0], struct GRid );
	else	    buffer = _MALLOC  ( num_chld[i0], struct GRid );
      }
    }
    if ( buffer == NULL )
    {
      __print_goto ( "quit" );
      goto quit;
    }

    if ( num_chld[i0] )
    {
      OM_BLOCK_MOVE ( chptr, (i0 == 0) ? buffer : &buffer[ num_chld[0] ], num_chld[i0] * sizeof (struct GRid) );
    }
  }

  child_0 =  buffer;
  child_1 = &buffer[ num_chld[0] ];

  for (i0=0; i0 < num_chld[0]; i0++)
  {
    __printf ("NDnode.NDget_objects: child_0[%d]  = [%d,%d]", `i0, child_0[i0].osnum, child_0[i0].objid` );
  }
  for (i0=0; i0 < num_chld[1]; i0++)
  {
    __printf ("NDnode.NDget_objects: child_1[%d]  = [%d,%d]", `i0, child_1[i0].osnum, child_1[i0].objid` );
  }

  for (i0=0; i0 < num_chld[0]; i0++)
  {
    char	*c = NULL;
    OMuword	 cid;
    struct GRid	 macro;

    om$get_classid ( objid = child_0[i0].objid, osnum = child_0[i0].osnum, p_classid = &cid);
    if ( om$is_ancestry_valid ( subclassid = cid, superclassid = OPP_nci_macro_class_id) == OM_S_SUCCESS)
    {
      macro.objid = NULL_OBJID;

      status =
	om$send (	msg	 = message ACcpx.find_macro ( &macro ),
			targetid = child_0[i0].objid,
			targetos = child_0[i0].osnum,
			senderid = NULL_OBJID);
      as$status();
      status =
	om$send (	msg	 = message ACcpx_defn.ACgive_name ( &c ),
			targetid = macro.objid,
			targetos = macro.osnum,
			senderid = NULL_OBJID);
      as$status();
      __printf ("ACcpx_defn.ACgive_name:child[%d] = [%d,%d], name = <%s>", `i0, child_0[i0].osnum, child_0[i0].objid, c` );

      if ( c && strcmp ( c, "VDinterf_cvs" ) == 0 )
      {
	for (j0=0; j0 < num_chld[1]; j0++)
	{
	  if ( IF_EQ_GRID ( child_0[i0], child_1[j0] ) )
	  {
	    *mac_inter = child_0[i0];
	    goto quit;
	  }
	}
      }
    }
  }

quit:
  if (buffer) _FREE ( buffer );

  __exitFunction ( name = "VDfind_common_children" );

  return (rc);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDtest_GRid_1_2
(
  struct GRid		*GRid1,
  struct GRid		*GRid2
)
{
  int			status = 1, sts, found1 = 0, found2 = 0;
  OMuint		cnt1, cnt2;
  char			*supercls1 = {"VRCorrection"};
  char			cl_nm[DI_PATH_MAX];
  struct GRid		gr_id1, gr_id2;

  OM_S_CHANSELECT	my_chansel;
  OM_S_OBJECT_LINKAGE	lobj1, lobj2;

  __enterFunction ( name = "VDtest_GRid_1_2" );

  my_chansel.type	= OM_e_name;
  my_chansel.u_sel.name = "to_owners";

  gr_id1.objid = gr_id2.objid = NULL_OBJID;

  sts = om$get_channel_count (	osnum		= GRid1->osnum,
				objid		= GRid1->objid,
				p_chanselect	= &my_chansel,
				count		= &cnt1 );
  if ( cnt1 == 1 )
  {
    sts = om$get_channel_objects(
				 osnum		= GRid1->osnum,
				 objid		= GRid1->objid,
				 p_chanselect	= &my_chansel,
				 size		= cnt1,
				 list		= &lobj1,
				 count		= &cnt1 );

    gr_id1.objid = lobj1.S_objid;
    gr_id1.osnum = lobj1.osnum;

    om$get_classname (		objid		= lobj1.S_objid,
				osnum		= lobj1.osnum,
				classname	= cl_nm );

    if ( om$is_ancestry_valid ( subclassname = cl_nm, superclassname = supercls1 ) == OM_S_SUCCESS)
    {
      __printf ( "Found 1 VRCorrection owner GRid1 : [%d,%d] ==>> [%d,%d]", `GRid1->osnum, GRid1->objid, gr_id1.osnum, gr_id1.objid` );
      found1 = 1;
    }
  }
  else
  {
    __printf ( "Found %d owner(s) on GRid1 : [%d,%d]", `cnt1, GRid1->osnum, GRid1->objid` );
    goto quit;
  }

  sts = om$get_channel_count (	osnum		= GRid2->osnum,
				objid		= GRid2->objid,
				p_chanselect	= &my_chansel,
				count		= &cnt2 );
  if ( cnt2 == 1 )
  {
    sts = om$get_channel_objects(
				 osnum		= GRid2->osnum,
				 objid		= GRid2->objid,
				 p_chanselect	= &my_chansel,
				 size		= cnt2,
				 list		= &lobj2,
				 count		= &cnt2 );

    gr_id2.objid = lobj2.S_objid;
    gr_id2.osnum = lobj2.osnum;

    om$get_classname (		objid		= lobj2.S_objid,
				osnum		= lobj2.osnum,
				classname	= cl_nm );

    if ( om$is_ancestry_valid ( subclassname = cl_nm, superclassname = supercls1 ) == OM_S_SUCCESS)
    {
      __printf ( "Found 1 VRCorrection owner GRid2 : [%d,%d] ==>> [%d,%d]", `GRid2->osnum, GRid2->objid, gr_id2.osnum, gr_id2.objid` );
      found2 = 1;
    }
  }
  else
  {
    __printf ( "Found %d owner(s) on GRid2 : [%d,%d]", `cnt2, GRid2->osnum, GRid2->objid` );
    goto quit;
  }

  if ( found1 && found2 && (gr_id1.objid == gr_id2.objid) && (gr_id1.osnum == gr_id2.osnum) )
  {
    status = 0;
    __printf ( ">>>>>>>>>> DO NOT create VDinterf_cvs macro ==>> common VRCorrection owner [%d,%d]", `gr_id2.osnum, gr_id2.objid` );
  }

quit:
  __exitFunction ( name = "VDtest_GRid_1_2" );

  return (status);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDCreate_interf_macro
(
  struct GRid	       *GRid1,
  struct GRid	       *GRid2,
  struct GRmd_env      *openv,
  struct GRid	       *interf_grid,
  IGRint	       *store_in_macro
)
{
  union	state	       *intf_flags;
  union state		macro_state;

  IGRlong		msg, status;
  int			i0, sts, rc = 1, mac_state = *store_in_macro;
  unsigned char		repr_1 = 0, repr_2 = 0;

  struct GRid		TEMP    [MAX_TEMP], mac_inter;
  struct GRobj_env	mac_foot[MAX_FEET];

  __enterFunction ( name = "VDCreate_interf_macro" );

  mac_inter.objid = NULL_OBJID;
  mac_inter.osnum = openv->md_id.osnum;

  macro_state.int_stat   = 0;

  for (i0=0; i0 < MAX_FEET; i0++)
  {
    mac_foot[i0].obj_id.objid = NULL_OBJID;
  }

  sts = om$send ( msg	   = message ACncpx.ACget_NV_rep ( &repr_1 ),
		  targetid = GRid1->objid,
		  targetos = GRid1->osnum,
		  senderid = NULL_OBJID);

  sts = om$send ( msg	   = message ACncpx.ACget_NV_rep ( &repr_2 ),
		  targetid = GRid2->objid,
		  targetos = GRid2->osnum,
		  senderid = NULL_OBJID);

  ASmake_source_from_env ( GRid1, openv, &TEMP[0] );
  ASmake_source_from_env ( GRid2, openv, &TEMP[1] );

  __printf ( "GRid1   = [%d,%d], GRid2   = [%d,%d], repr_1 = %d, repr_2 = %d",
	     `GRid1->osnum, GRid1->objid, GRid2->osnum, GRid2->objid, repr_1, repr_2` );
  __printf ( "TEMP[0] = [%d,%d], TEMP[1] = [%d,%d]", `TEMP[0].osnum, TEMP[0].objid, TEMP[1].osnum, TEMP[1].objid` );

  keep_inters = FALSE;

  /*
   * We first need to check if these two TEMP's already are the parent of a
   * CI_MACRO : if they are AND it is the SAME CI_MACRO_ID for both, then
   * do NOT construct a new macro, but use the existing one
   */
  status = VDfind_common_children ( &msg, TEMP, &mac_inter );

  if ( mac_inter.objid == NULL_OBJID )
  {
    status =
      om$construct (	classid	= OPP_nci_macro_class_id,
			p_objid	= &mac_inter.objid,
			osnum	= openv->md_id.osnum);
    as$status();

    status =
      om$send (	msg	 = message ci_macro.init (	&rc,
							0,
							"VDinterf_cvs",
							MAX_TEMP,
							TEMP,
							(IGRchar *) &macro_state,
							openv),
		targetid = mac_inter.objid,
		targetos = mac_inter.osnum,
		senderid = NULL_OBJID);

    as$status();

    __printf ( "ci_macro.init        : mac_inter   = [%d,%d], rc = %d", `mac_inter.osnum, mac_inter.objid, rc` );

    if( rc == 0 )
    {
      status =
	om$send (	msg	 = message Root.delete(0),
			targetid = mac_inter.objid,
			targetos = mac_inter.osnum,
			senderid = NULL_OBJID);
      goto quit;
    }
  }
  else
  {
    /*
     * Make sure to NOT call EMinit() at the end of VDconstruct_intersection_curves().
     * NDnode.NDcompute_node will execute the function VDconstruct_intersection_curves(),
     * from the PPL compute function and normally would call EMinit() to cleanup the static struct *inters[2] etc.,
     * but in this case we do NOT want that in order to be able to report the interferences !!!
     * For that purpose the static variable is used : keep_inters
     *
     * In case a recompute should NOT be required ==>> keep the existing CI_MACRO in its unmodified state,
     * just cancel this section !!!
     */

    keep_inters = TRUE;

    status =
      om$send (	msg	 = message NDnode.NDcompute_node ( &msg, 0, 2, TEMP, openv ),
		targetid = mac_inter.objid,
		targetos = mac_inter.osnum,
		senderid = NULL_OBJID);
    as$status();

    keep_inters = FALSE;
  }

  /*  The nci_macro should delete itself if one of its parents is deleted */

  status =
    om$send (	msg	 = message NDnode.NDchg_state( ND_DONT_MVRT, ND_DONT_MVRT ),
		targetid = mac_inter.objid,
		targetos = mac_inter.osnum,
		senderid = NULL_OBJID);

  /*
   * Use the instance variable internal_buffer(==>>intf_flags) of ci_macro to store following info
   * =============================================================================================
   * #define ASSOC_OPTION_1   01
   * #define ASSOC_OPTION_2   02
   * #define AVOID_FALSE_INTF 04
   *
   * 	byt[0] : the value of static variable "always_make_macro"
   *		 assoc_opt   = byt[0] & ASSOC_OPTION_1
   *		 assoc_opt   = byt[0] & ASSOC_OPTION_2
   *             avoid_false = byt[0] & AVOID_FALSE_INTF
   * 	byt[1] : the NV_repr of template 1
   * 	byt[2] : the NV_repr of template 2
   * 	byt[3] : reserved for the STATUS of the Interference
   *
   *
   * Also it is important to notice that byt[0,1,2] will ONLY be set
   * when the Interference macro is CREATED and that any following recompute
   * p.e. "Change Element Representation"
   * will leave these bytes unaffected !!!!!
   */

  macro_state.int_stat    = mac_state;
  macro_state.byt_stat[1] = repr_1;
  macro_state.byt_stat[2] = repr_2;
  mac_state = (int)macro_state.int_stat;
  /*
   * This is tricky: get a pointer into the instance data of the macro
   */
  status =
    om$send (	msg	 = message ci_macro.give_internal_ptr ( (IGRint *) &msg, (IGRchar **) &intf_flags ),
		targetid = mac_inter.objid,
		targetos = mac_inter.osnum,
		senderid = NULL_OBJID);

  __printf ( "<<<<<<<<<< ci_macro.give_internal_ptr : status = %d, msg = %d", `status, msg` );

  if( ! ( status & msg & 1 ) )
  {
    goto quit;
  }

  intf_flags->int_stat = macro_state.int_stat;

  /* return the graphic objects (feet) from the nci_macro */

  for ( i0=0, num_feet = 0; i0 < MAX_FEET; i0++, num_feet++ )
  {
    char      foot_nam[20];
    sprintf ( foot_nam, "interf%d", i0);

    status =
      om$send (	msg	 = message NDmacro.ACreturn_foot(
							 &msg,
							  foot_nam,
							 &mac_foot[i0].obj_id,
							 &mac_foot[i0].mod_env.md_env.matrix_type,
							  mac_foot[i0].mod_env.md_env.matrix ),
		targetid = mac_inter.objid,
		targetos = mac_inter.osnum,
		senderid = NULL_OBJID);
    as$status();

    __printf ( "NDmacro.ACreturn_foot: num_feet = %d, mac_foot[%d]  = [%d,%d], foot_nam = <%s>, status = %d, msg = %d",
	     `num_feet, i0, mac_foot[i0].obj_id.osnum, mac_foot[i0].obj_id.objid, foot_nam, status, msg` );

    interf_grid[i0] = mac_foot[i0].obj_id;

    if ( mac_foot[i0].obj_id.objid == NULL_OBJID )
    {
      break;
    }
  }

quit:

  __exitFunction ( name = "VDCreate_interf_macro" );

  return (rc);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static void EMcleanup
(
  struct GRid     *op1,
  struct GRid     *op2,
  struct GRid     *vol,
  struct GRmd_env *env
)
{
  IGRlong	locsts, rc;

  if(!IF_NULL_OBJID(op1->objid))
    locsts = om$send(msg = message GRgraphics.GRdelete (&rc, env),
		     senderid = NULL_OBJID, targetid = op1->objid, targetos = op1->osnum);

  if(!IF_NULL_OBJID(op2->objid))
    locsts = om$send(msg = message GRgraphics.GRdelete (&rc, env),
		     senderid = NULL_OBJID,  targetid = op2->objid, targetos = op2->osnum);

  if(!IF_NULL_OBJID(vol->objid))
    locsts = om$send(msg = message GRgraphics.GRdelete (&rc, env),
		     senderid = NULL_OBJID, targetid = vol->objid, targetos = vol->osnum);

  op1->objid = NULL_OBJID;
  op2->objid = NULL_OBJID;
  vol->objid = NULL_OBJID;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 *The following function assumes non intersecting operands.
 */
#include "EMSconstruct.h"   /* EMS_S_INSOLID etc. */

static void EMinsideOutside
(
  IGRlong		*EMmsg,
  struct GRlc_info	*ele1,
  struct GRlc_info	*ele2,
  struct GRid		*volelem,
  struct GRvg_construct	*const_list,
  IGRint		*num_inters
)
{
  IGRlong		sts = OM_S_SUCCESS;
  extern EMSrc		EFsolidRelationship();
  /*extern IGRlong	EMdupinters();*/
  IGRulong		location;
  struct GRlc_info	*inelem = NULL;
  OMuword		cid;
  struct GRid		obj1, obj2;
  IGRboolean		sol1 = TRUE, sol2 = TRUE;

  __enterFunction ( name = "EMinsideOutside" );

  *EMmsg = EMS_S_Success;
  if(volelem) volelem->objid = NULL_OBJID;
  *num_inters = 0;
  obj1 = ele1->located_obj;
  obj2 = ele2->located_obj;

  sts = om$get_classid(objid = obj1.objid, osnum = obj1.osnum,
		       p_classid = &cid);

  if( (cid != OPP_EMSsolid_class_id) &&
      ((sts = om$is_ancestry_valid(superclassid = OPP_EMSsolid_class_id,
				   subclassid = cid)) != OM_S_SUCCESS)) sol1 = FALSE;

  if(sol1)
  {
    sts = om$get_classid(objid = obj2.objid, osnum = obj2.osnum,
			 p_classid = &cid);

    if( (cid != OPP_EMSsolid_class_id) &&
	((sts = om$is_ancestry_valid(superclassid = OPP_EMSsolid_class_id,
				     subclassid = cid)) != OM_S_SUCCESS)) sol2 = FALSE;
  }

  if(sol1 && sol2)
  {
    /* Is ele2 inside ele1 ?
     */
    sts = EFsolidRelationship(EMmsg, obj1.objid, obj1.objid, obj2.objid,
			      obj1.osnum, obj2.osnum, &ele1->module_info, &ele2->module_info,
			      NULL, &location);
    if(!(1&*EMmsg&sts)) goto wrapup;

    if(location == EMS_S_INSOLID)
      inelem = ele2;
    else if(location == EMS_S_OUTSOLID)
    {
      /* Do a reverse check to find whether ele1 is inside ele2.
       */
      sts = EFsolidRelationship(EMmsg, obj2.objid, obj2.objid, obj1.objid,
				obj2.osnum, obj1.osnum, &ele2->module_info, &ele1->module_info,
				NULL, &location);
      if(!(1&*EMmsg&sts)) goto wrapup;
      if(location == EMS_S_INSOLID) inelem = ele1;
    }

  } /* if(sol1 && sol2) */
  else
    *EMmsg = EMS_I_Useless;

  if(inelem)
  {
    *num_inters = 1;
    if(volelem)
    {
/****************************************************************************
      sts = EMdupinters(EMmsg, NULL, NULL, FALSE, TRUE, &inelem->located_obj,
			volelem, TRUE, &inelem->module_info, const_list, NULL, NULL,
			0, NULL, NULL, 0);
***************************************************************************/
      sts = ems$dupinters(msg = EMmsg,
			  copyintobjs = FALSE,
			  delorigintobjs = TRUE,
			  origsfid = &inelem->located_obj,
			  copysfid = volelem,
			  origsfenv = &inelem->module_info,
			  construction_args = const_list);
    }
  }

wrapup:

  if(!(1&*EMmsg&sts) && volelem && !IF_NULL_OBJID(volelem->objid))
  {
    IGRlong rc;
    sts = om$send(msg = message GRgraphics.GRdelete(&rc, const_list->env_info),
		  targetid = volelem->objid, targetos = volelem->osnum,
		  senderid = volelem->objid);
    volelem->objid = NULL_OBJID;
  }

  __exitFunction ( name = "EMinsideOutside" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static void EMinit
(
  struct EMSsftracedata     *trace,
  struct EMSinters	   **inters,
  struct EMSsfintloopsdata  *sfintloopsdata,
  struct EMSsfintloopsdata **loopdata,
  IGRboolean		     dealloc
)
{
  IGRint	i, msg_loc;

  extern void  	EMsfintedpar_free();

//  __enterFunction ( name = "EMinit", argfmt = "dealloc = %d", args = dealloc );

  if(dealloc)
  {
    for (i=0; i<2; i++)
    {
      if(inters[i])
      {
/*****************************************************************************
	EMinters_data_free (&msg_loc, inters[i], MAXINT, NULL,EMsfintedpar_free);
	EMinters_free (inters[i], MAXINT);
*****************************************************************************/
	ems$inters_data_free (
			      msg = (IGRlong *)&msg_loc,
			      inters_list = inters[i],
			      num_nodes = MAXINT,
			      userdfnd_func_to_free_intobj_moreinfo = EMsfintedpar_free);
	ems$inters_free (
			 inters_list = inters[i],
			 num_nodes = MAXINT);
      }
/**************************************************************************
      EMsfinttrace_free ( (IGRlong *)&msg_loc, trace[i].num_grps,
			   trace[i].num_subgrps_grp, trace[i].num_elems_subgrp,
			  (IGRchar ***)trace[i].elems, trace[i].subgrp_rev, trace[i].elem_rev,
			   trace[i].grp_closed, trace[i].subgrp_closed);
**************************************************************************/
      ems$sfinttrace_free (
			   msg			 = (IGRlong *)&msg_loc,
			   num_grps		 = trace[i].num_grps,
			   num_subgrps_grp	 = trace[i].num_subgrps_grp,
			   num_elems_subgrp	 = trace[i].num_elems_subgrp,
			   elems		 = (IGRchar ***)trace[i].elems,
			   subgrp_rev		 = trace[i].subgrp_rev,
			   elem_rev		 = trace[i].elem_rev,
			   grp_closed		 = trace[i].grp_closed,
			   subgrp_closed	 = trace[i].subgrp_closed);

      if (sfintloopsdata[i].sfintloops_alloced)
      {
	EMsfintloops_free (sfintloopsdata[i].loop_sf,
			   sfintloopsdata[i].endedges,
			   sfintloopsdata[i].intedpars,
			   sfintloopsdata[i].sfpartolb);
      }
    }
  }

  for (i=0; i<2; i++)
  {
    inters[i] = NULL;
    trace[i].num_grps		 = 0;
    trace[i].num_subgrps_grp	 = NULL;
    trace[i].num_elems_subgrp	 = NULL;
    trace[i].elems		 = NULL;
    trace[i].subgrp_rev		 = NULL;
    trace[i].elem_rev		 = NULL;
    trace[i].grp_closed		 = NULL;
    trace[i].subgrp_closed	 = NULL;

    sfintloopsdata[i].loop_sf		 = NULL;
    sfintloopsdata[i].endedges		 = NULL;
    sfintloopsdata[i].intedpars		 = NULL;
    sfintloopsdata[i].sfpartolb		 = NULL;
    sfintloopsdata[i].sfintloops_alloced = FALSE;
    sfintloopsdata[i].numedsplit	 = 0;
    sfintloopsdata[i].commed_k_exists	 = TRUE;
    sfintloopsdata[i].nocommed_k_exists	 = FALSE;
    loopdata[i] = &sfintloopsdata[i];
  }

// __exitFunction ( name = "EMinit" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

IGRlong VD_EManalyzeIntf
(
  IGRlong                   *EMmsg,
  struct GRlc_info          *SetInfo1,
  struct GRlc_info          *Ele1,
  IGRint                     NumEle1,
  IGRint                     setnum1,
  struct GRlc_info          *SetInfo2,
  struct GRlc_info          *Ele2,
  IGRint                     NumEle2,
  IGRint                     setnum2,
  IGRushort                  options,
  IGRchar                   *ReportFileName,
  struct GRvg_construct     *const_list,
  struct EMSintf           **result,
  IGRint                    *num_result,
  // The following arguments (all INPUT) are only present in VD_EManalyzeIntf()...
  Form                       form_ptr,
  IGRint                     assoc_opt,
  IGRint                     VD_avoid_false_interf,
  IGRint                     VD_use_old_intf,
  IGRint                     VD_skip_reduce_range,
  IGRchar                   *prog_msg_file
)
{
  char                       start_time[80], end_time[80];
  static char               *superclassnm_1 = {"VRComponent"};
  static char               *superclassnm_2 = {"VRConcComp"};
  IGRchar                  **boxint   = NULL;
  IGRchar                   *stackptr = NULL;
  IGRchar                    str_array[MS_MAX_MSG_LENGTH];
  IGRboolean                 nocurves = FALSE, nomsg = FALSE, sameobj = FALSE, intpt = FALSE, novol = FALSE, outp;
  IGRboolean                *in_set2, *in_set1;
  IGRint                     i, j, k, bufSize = 0, numchecked = 0, num_siblings;
  IGRint                     failBufSize  = 0, numfail = 0, RbufSize = 0;
  IGRint                     locnumresult = 0, num_inters = 0;
  IGRint                     boxcnt = 0, set1_equals_set2 = 0;
  IGRlong                    sts    = OM_S_SUCCESS;
  int                        fpos   = -1;
  long                       offset = 0;
  FILE                      *fpdb   = NULL;

  struct EMSintf            *locresult = NULL;
  struct GRid                intersobj [MAX_FEET], volelem, op1, op2;
  struct GRid                sibling_store[NUM_STATIC_SIBLINGS], *siblings = NULL;

  struct EMSintf_failure    *failed = NULL;
  struct EMSsftracedata      trace[2];
  struct GRmdenv_info       *envinfo1, *envinfo2;
  struct EMSsfintloopsdata   sfintloopsdata[2], *loopdata[2];

  struct GRlc_info          *p_ele1 = NULL, *p_ele2 = NULL;

//  struct EMSinters     *inters[2];            // Moved to STATIC GLOBAL DATA section

  extern void                EMintf_free(),   EMintf_recordFailure(), EMintfDisplay();
  extern void                EMintf_report(), EMintf_failureReport(), VD_EMintf_report();
  extern char               *EMgettime();
  extern IGRboolean          IGEstop(), EMisElementSame(), EMisFirstDominant();
  /* extern IGRlong          EMdupinters();              */

  __enterFunction ( name = "VD_EManalyzeIntf" );

  strcpy ( start_time, EMgettime() );

  __printf ( "form_ptr = %#x, assoc_opt = %d, avoid_false_interf = %d, skip_reduce_range = %d, start_time = %s",
             `form_ptr, assoc_opt, VD_avoid_false_interf, VD_skip_reduce_range, start_time` );

  __printf ( "use_old_intf = %d, use_shrink_buffers = %d", `VD_use_old_intf, use_shrink_buffers` );

  *EMmsg       = EMS_S_Success;
  str_array[0] = '\0';

  nocurves     = options & EMSintf_NoCurves;
  nomsg        = options & EMSintf_NoStatMsg;
  novol        = options & EMSintf_NoVolElems ? TRUE : FALSE;

  if ( TRUE || ! nomsg )
  {
    // Append Progress Messages to file ...
    fpdb = fopen(prog_msg_file, "a");
    if (fpdb)
    {
      fprintf(fpdb, "Enter VD_EManalyzeIntf -- Start Time = %s\n", start_time);
      fflush (fpdb);
    }
  }

  if ( post_process_inter )
  {
    IGRchar post_proc_msg[80], act_fil[80], *ptr = NULL;
    IGRchar filnam[DI_PATH_MAX];
    sts = ex$filename (name = filnam, len = DI_PATH_MAX);
    strcpy (post_proc_msg, "Post_Proc_Intf_");

    ptr = strrchr (filnam, '/') + 1;
    strcpy (act_fil, ptr);
    ptr = strrchr (act_fil, '.');
    if (ptr)
      *ptr = 0;
    strcat (post_proc_msg, act_fil);
    __printf("<<<<< %s >>>>>", `post_proc_msg`);

    fp_post = fopen(post_proc_msg, "w");
    if (fp_post)
    {
      fprintf(fp_post, "Enter VD_EManalyzeIntf -- Start Time = %s\n", start_time);
      fflush (fp_post);
    }

    post_proc_deleted = 0;
  }

  always_make_macro  = assoc_opt;
  avoid_false_interf = VD_avoid_false_interf;
  use_old_intf       = VD_use_old_intf;
  skip_reduce_range  = VD_skip_reduce_range;

  if (avoid_false_interf == 0 )
    use_shrink_buffers = 0;

  if (nocurves && novol)
    outp = FALSE;
  else
    outp = TRUE;

  EMinit(trace, inters, sfintloopsdata, loopdata, FALSE);

  if ( ! result )         result = &locresult;
  if ( ! num_result ) num_result = &locnumresult;

  *result     = NULL;
  *num_result = 0;
  nr_rangebox_swp = 0;
  // Test if Set1 and Set2 are identical...
  if (NumEle1 == NumEle2)
  {
    for (i=0; i < NumEle1; i++)
    {
      if ( Ele1[i].located_obj.objid == Ele2[i].located_obj.objid &&
           Ele1[i].located_obj.osnum == Ele2[i].located_obj.osnum )
      {
        set1_equals_set2 = 1;
      }
      else
      {
        set1_equals_set2 = 0;
        break;
      }
    }
  }

  __printf ( "<<<<<<<<<< set1_equals_set2 = %d >>>>>>>>>>", `set1_equals_set2` );

  // Do a preliminary range-box intersection (ONLY if assoc_opt <= 1) and store the result in the
  // allocated 2-dim array boxint[NumEle1][NumEle2]... (Must be _FREE'd !!!)
  if ( assoc_opt < 2 )
  {
    int         sts, is_displayed = 0;
    struct GRid go_sup;

    if ( form_ptr )
    {
      sts = FIf_is_displayed ( form_ptr, &is_displayed );
    }

    sts = VDrange_box_test( avoid_false_interf, set1_equals_set2, NumEle1, NumEle2, Ele1, Ele2, fpdb, const_list, &boxint, EMmsg, &boxcnt);
    if ( ! (sts & 1))
    {
      sprintf(str_array, "VDrange_box_test(sts = %d) error - Stop Processing", sts);

      UI_status( str_array );
      if ( is_displayed )
      {
        sts = FIg_set_text   ( form_ptr, FI_MSG_FIELD, str_array );
        ems_sleep(2);
      }
      goto wrapup;
    }

    sprintf(str_array, "Number of intersecting range-boxes : %d", boxcnt);
    if ( TRUE || ! nomsg )
    {
      fprintf(fpdb, "  %s\n\n", str_array);
    }

    UI_status( str_array );
    if ( is_displayed )
    {
      sts = FIg_set_text   ( form_ptr, FI_MSG_FIELD, str_array );
      ems_sleep(2);
    }

    if ( VDcomment )
    {
      // Activate for debugging/testing purpose...
      //goto wrapup;
    }
  }

  if ( TRUE || ! nomsg )
  {
    // First, find offset to EOF ...
    offset = ftell (fpdb);

    //printf ( "ftell() : offset = %d\n", offset );
    fclose (fpdb); fpdb = NULL;
    // Now that we have the offset to EOF, reopen for update (read-write) ...
    fpdb = fopen(prog_msg_file, "r+");
  }

  // Allocate two buffers for storing shrunk objects...
  if (use_shrink_buffers && avoid_false_interf)
  {
    idx_set1     = idx_set2     = -1;
    shrink_buff1 = shrink_buff2 = 0;
    shrunk_Set1  = shrunk_Set2  = NULL;

    if ( NumEle1 )
    {
      shrunk_Set1 = _MALLOC ( NumEle1, struct GRid );
      if ( shrunk_Set1 )
      {
        shrink_buff1 = 1;
        for (i=0; i< NumEle1; i++)
        {
          shrunk_Set1[i].objid = NULL_OBJID;
          shrunk_Set1[i].osnum = 2;
        }
      }
    }
    if ( NumEle2 )
    {
      shrunk_Set2 = _MALLOC ( NumEle2, struct GRid );
      if ( shrunk_Set2 )
      {
        shrink_buff2 = 1;
        for (i=0; i< NumEle2; i++)
        {
          shrunk_Set2[i].objid = NULL_OBJID;
          shrunk_Set2[i].osnum = 2;
        }
      }
    }

    __printf ( ">>>>> _MALLOC(shrunk_Set1) : size = %d, shrunk_Set1 = %#x", `(NumEle1) * sizeof (struct GRid), shrunk_Set1` );
    __printf ( ">>>>> _MALLOC(shrunk_Set2) : size = %d, shrunk_Set2 = %#x", `(NumEle2) * sizeof (struct GRid), shrunk_Set2` );
  }

  EMerr_hndlr(!Ele1 || !Ele2, *EMmsg, EMS_E_InvalidArg, wrapup);
  EMerr_hndlr( (options & EMSintf_ReportBoth) && ! ReportFileName, *EMmsg, EMS_E_InvalidArg, wrapup);

 /*
  * Prepare lists of Boolean flags for the two sets, indicating the elements
  * that are contained in both sets
  */
//stackptr = (IGRchar *)stackalloc ((NumEle1 + NumEle2) * sizeof (IGRboolean));
  stackptr = (IGRchar *) _MALLOC   ((NumEle1 + NumEle2) * sizeof (IGRboolean), IGRchar );
  EMerr_hndlr (!stackptr, *EMmsg, EMS_E_NoStackMemory, wrapup);
  __printf ( ">>>>> stackalloc() : size = %d, stackptr = %#x", `(NumEle1 + NumEle2) * sizeof (IGRboolean), stackptr` );
  in_set2 =   (IGRboolean *) stackptr;
  in_set1 = &((IGRboolean *) stackptr)[NumEle1];
  for (i=0; i<NumEle1; i++)    in_set2[i] = FALSE;
  for (i=0; i<NumEle2; i++)    in_set1[i] = FALSE;
  for (i=0; i<NumEle1; i++)
  {
    for (j=0; j<NumEle2; j++)
    {
      envinfo1 = &Ele1[i].module_info.md_env;
      envinfo2 = &Ele2[j].module_info.md_env;
      if ( ! in_set1[j] &&
           EMisElementSame (&Ele1[i].located_obj, &Ele2[j].located_obj,
                            envinfo1->matrix_type, envinfo2->matrix_type,
                            envinfo1->matrix, envinfo2->matrix))
      {
        in_set2[i] = TRUE;
        in_set1[j] = TRUE;
      }
    }
  }

 /*
  * Begin interference checking.
  */

  volelem.osnum = const_list->env_info->md_id.osnum;
  for(i=0; (i<NumEle1) && !intpt; i++)
  {
    IGRboolean			   atleastone = FALSE;
    struct EMSintf_qualitative	 **against;
    struct EMSintf		  *this_result;

    /* ------------------------------------------------
     * 10/30/97 Art Hundiak
     * Compilier gives warnings about possible UnInited values
     * Code is too complex for me to trace so init them then
     * add some checks before using
     */
    against       = NULL;
    this_result   = NULL;

    op1.objid     = NULL_OBJID;
    op2.objid     = NULL_OBJID;
    volelem.objid = NULL_OBJID;
    idx_set1      = i;

    if ( (intpt = IGEstop()) ) break;	/* user interrupt */

    //__printf ( ">>>>> i =  %d", `i` );

    if(RbufSize)
    {
      this_result                   = (struct EMSintf *) &(*result)[*num_result];
      this_result->numintf          = 0;
      this_result->intfInfoType     = EMqualitative;
      this_result->info.qualitative = NULL;
      against = (struct EMSintf_qualitative **) &this_result->info.qualitative;
    }
    numchecked++;
//  for(j=0; (j < NumEle2) && ! intpt; j++)
    // Avoid double processing when sets are identical ...
    for(j=((set1_equals_set2 == 0) ? 0 : i+1); (j < NumEle2) && ! intpt; j++)
    {
//#ifdef CLIX
//      IGRchar			sts_array[MS_MAX_MSG_LENGTH+1];
//#endif
      IGRboolean		found;
      IGRushort			outworld_opt, outparam_opt, trim_opt, inters_opt;
      struct EMSdataselect	other;
      struct GRid		GRid1, GRid2;
      struct GRmd_env		*env1, *env2, *openv;
      IGRboolean		sol1, sol2;
      IGRboolean		sf1, sf2;
      OMuword			cid;
      int			corr_chk;

      idx_set2      = j;

      //__printf ( ">>>>>>>>>> i =  %d, j = %d", `i, j` );

      if ( (intpt = IGEstop()) ) break; 	/* user interrupt */

      GRid1             = Ele1[i].located_obj;
      GRid2             = Ele2[j].located_obj;
      env1              = &Ele1[i].module_info;
      env2              = &Ele2[j].module_info;
      openv             = const_list->env_info;
      other.datatype    = EMSdata_object;
      other.data.object = &GRid2;

      op1.objid         = NULL_OBJID;
      op2.objid         = NULL_OBJID;
      volelem.objid     = NULL_OBJID;
//#ifdef CLIX
//      sts_array[0] = '\0';
//#endif
      if (IF_EQ_GRID(GRid1, GRid2))
	sameobj = TRUE;
      else
	sameobj = FALSE;

      // If range-boxes did NOT intersect, continue ...
      if ( assoc_opt <= 1 && boxint )
      {
        if ( boxint[i][j] == 0 )
        {
          continue;
        }
      }

      // HF: 10/11/2000 - Since every Set is now pre-processed (sorted AND duplicates removed) in VDintf_check_located_obj()
      //                  in file VDintfi.I, added "&&(! set1_equals_set2)" ....

      if ( in_set2[i] && in_set1[j] &&
           ( ! set1_equals_set2 )   &&
           ( EMisElementSame ( &GRid1, &GRid2,
                               env1->md_env.matrix_type, env2->md_env.matrix_type,
                               env1->md_env.matrix, env2->md_env.matrix) ||
           ! EMisFirstDominant (&GRid1, &GRid2,
                               env1->md_env.matrix_type, env2->md_env.matrix_type,
                               env1->md_env.matrix, env2->md_env.matrix)))
      {
        continue;
      }

      //__printf ( ">>>>>>>>>> i =  %d, j = %d", `i, j` );

     /*
      * Check if GRid2 is a "sibling" of GRid1 (if GRid1 is a GRowner).
      * If so, then this check is skipped.
      */

      om$get_classid (objid     = GRid1.objid, osnum = GRid1.osnum,
		      p_classid = &cid);
      if (om$is_ancestry_valid (subclassid   = cid,
				superclassid = OPP_GRowner_class_id) == OM_S_SUCCESS)
      {
        __printf ( ">>>>>>>>>> 1 GRowner.GRget_siblings() i =  %d, j = %d", `i, j` );

        sts = om$send (msg = message GRowner.GRget_siblings ( EMmsg, NULL,
                                                              &num_siblings,
                                                              &siblings,
                                                              NUM_STATIC_SIBLINGS,
                                                              sibling_store),
                       targetid = GRid1.objid,
                       targetos = GRid1.osnum,
                       senderid = NULL_OBJID);

        __printf ( "<<<<<<<<<< 1 GRowner.GRget_siblings(): sts = %d, *EMmsg = %d, num_siblings =  %d, i =  %d, j = %d",
                   `sts, *EMmsg, num_siblings, i, j` );

        if ( ! ( sts & *EMmsg & 1 ) )
        {
          // These ROUTE objects do not respond correctly to GRget_siblings ... (return: sts = 38830248 : OM-W-NOTONCHAN)
          // The VRgeneric.GRget_siblings method needs to be fixed, until then skip them ...
          if ( om$is_ancestry_valid ( subclassid = cid, superclassname = superclassnm_1 ) != OM_S_SUCCESS &&
               om$is_ancestry_valid ( subclassid = cid, superclassname = superclassnm_2 ) != OM_S_SUCCESS )
          {
            if (siblings && siblings != sibling_store)
            {
              _FREE ( siblings );
            }
            //HF: 06/21/99 DO NOT goto wrapup, but continue instead, AND write a failure
            EMlocerrhndlr ( ! (1 & sts), EMmsg, EMS_E_Fail, &Ele1[i], &Ele2[j], &numfail, &failed, &failBufSize, TRUE);
          }
        }
//	EMerr_hndlr (EMSerror (sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

        found = FALSE;
        for (k=0; k<num_siblings; k++)
        {
          if (GRid2.objid == siblings[k].objid &&
              GRid2.osnum == siblings[k].osnum)
          {
            found = TRUE;
            break;
          }
        }

        if (siblings && siblings != sibling_store)
        {
          _FREE ( siblings );
        }

        __printf ( "<<<<<<<<<< 1 GRowner.GRget_siblings() i =  %d, j = %d, found = %d", `i, j, found` );

        if (found)
          continue;
      }

     /*
      * Check if GRid1 is a "sibling" of GRid2 (if GRid2 is a GRowner).
      * If so, then this check is skipped.
      */

      om$get_classid (objid     = GRid2.objid, osnum = GRid2.osnum,
		      p_classid = &cid);
      if (om$is_ancestry_valid (subclassid   = cid,
				superclassid = OPP_GRowner_class_id) == OM_S_SUCCESS)
      {
        __printf ( ">>>>>>>>>> 2 GRowner.GRget_siblings() i =  %d, j = %d", `i, j` );

        sts = om$send (msg = message GRowner.GRget_siblings ( EMmsg, NULL,
                                                              &num_siblings,
                                                              &siblings,
                                                              NUM_STATIC_SIBLINGS,
                                                              sibling_store),
                       targetid = GRid2.objid,
                       targetos = GRid2.osnum,
                       senderid = NULL_OBJID);

        __printf ( "<<<<<<<<<< 2 GRowner.GRget_siblings(): sts = %d, *EMmsg = %d, num_siblings =  %d, i =  %d, j = %d",
                   `sts, *EMmsg, num_siblings, i, j` );

        if ( ! ( sts & *EMmsg & 1 ) )
        {
          // These ROUTE objects do not respond correctly to GRget_siblings ... (return: sts = 38830248 : OM-W-NOTONCHAN)
          // The VRgeneric.GRget_siblings method needs to be fixed, until then skip them ...
          if ( om$is_ancestry_valid ( subclassid = cid, superclassname = superclassnm_1 ) != OM_S_SUCCESS &&
               om$is_ancestry_valid ( subclassid = cid, superclassname = superclassnm_2 ) != OM_S_SUCCESS )
          {
            if (siblings && siblings != sibling_store)
            {
              _FREE ( siblings );
            }
            //HF: 06/21/99 DO NOT goto wrapup, but continue instead, AND write a failure
            EMlocerrhndlr ( ! (1 & sts), EMmsg, EMS_E_Fail, &Ele1[i], &Ele2[j], &numfail, &failed, &failBufSize, TRUE);
          }
        }
//	EMerr_hndlr (EMSerror (sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

        found = FALSE;
        for (k=0; k<num_siblings; k++)
        {
          if (GRid1.objid == siblings[k].objid &&
              GRid1.osnum == siblings[k].osnum)
          {
            found = TRUE;
            break;
          }
        }

        if (siblings && siblings != sibling_store)
        {
          _FREE ( siblings );
        }

        __printf ( "<<<<<<<<<< 2 GRowner.GRget_siblings() i =  %d, j = %d, found = %d", `i, j, found` );

        if (found)
          continue;
      }

      if ( TRUE || ! nomsg )
      {
	int	sts, is_displayed = 0;

	if (setnum1 != setnum2)
	  sprintf(str_array, "Set #%d - Elem[%d] = [%d,%d] : Set #%d - Elem[%d] = [%d,%d]",
                  setnum1, i, GRid1.osnum, GRid1.objid, setnum2, j, GRid2.osnum, GRid2.objid);
	else
	  sprintf(str_array, "Set #%d - Elem[%d] = [%d,%d] : Elem[%d] = [%d,%d]",
                  setnum1, i, GRid1.osnum, GRid1.objid, j, GRid2.osnum, GRid2.objid);

        if (fpdb)
        {
          fpos = fseek(fpdb, offset, SEEK_SET);

          //printf ( "fseek() : fpos = %d, offset = %d\n", fpos, offset);
          // Print to Log-File "Progress_VDS_Intf_" ...
          if ( ! fpos )
          {
            fprintf (fpdb, "  %s\n", str_array);
            fflush  (fpdb);
          }
        }

	if ( form_ptr )
	{
	  sts = FIf_is_displayed ( form_ptr, &is_displayed );
	}

	if ( is_displayed && ! nomsg )
	{
	  sts = FIg_set_text   ( form_ptr, FI_MSG_FIELD, str_array );
	}
	else
	{
#ifdef CLIX
	  ex$message(justification = LEFT_JUS, msgnumb = EMS_I_ProcessingSomething, var = `str_array`, type = "%s");
#endif
	}

//       ex$message(justification = LEFT_JUS, msgnumb = EMS_I_ProcessingSomething, var = `str_array`,
//                  type = "%s", buff = sts_array, buffer_size = (sizeof(sts_array)));
      }

      for (k=0; k < MAX_FEET; k++)
      {
	intersobj[k].osnum = volelem.osnum;
	intersobj[k].objid = NULL_OBJID;
      }

      num_inters = 0;
      outworld_opt = EMSINT_OUTPUT_WORLD;

      outparam_opt = EMSINT_OUTPUT_PARAM  | EMSINT_PARAM_OBJECT |
		     EMSINT_ORIENT_OUTPUT | EMSINT_ORIENT_RIGHT;

//    trim_opt = EMSINT_TRIM_OUTPUT      | EMSINT_TRIM_BDRYISAREA |
//  		 EMSINT_TRIM_COPLANAR    | EMSINT_TRIM_MOREPRECISE |
//  		 EMSINT_TRIM_PROCOVERLAP | EMSINT_TRIM_ONLYCUTTING;

      // Use the same options as IntTwoSrf()
      trim_opt = EMSINT_TRIM_HANDLESTOP |
                 EMSINT_TRIM_OUTPUT     |
                 EMSINT_TRIM_BDRYISAREA |
                 EMSINT_TRIM_COPLANAR   |
                 EMSINT_TRIM_PROCOVERLAP;

//    inters_opt =	 EMS_SFINT_DOUBLECHECK | EMS_SFINT_HANDLESTOP;	// | (!outp ? EMS_SFINT_YESORNO : NULL);

      // Using EMS_SFINT_SKIPFIXING gives dramatic performance improvement in some cases....!!!!!
      inters_opt =	 EMS_SFINT_SKIPFIXING  | EMS_SFINT_HANDLESTOP;	// | (!outp ? EMS_SFINT_YESORNO : NULL);

      EMinit(trace, inters, sfintloopsdata, loopdata, TRUE);

      sol1 = sol2 = sf1 = sf2 = TRUE;
      om$get_classid (objid = GRid1.objid, osnum = GRid1.osnum, p_classid = &cid);

      if (om$is_ancestry_valid (superclassid = OPP_EMSsolid_class_id, subclassid = cid) != OM_S_SUCCESS)
      {
	sol1 = FALSE;
      }
      if (om$is_ancestry_valid (superclassid = OPP_EMSsurface_class_id, subclassid = cid) != OM_S_SUCCESS)
      {
	sf1 = FALSE;
      }

      om$get_classid (objid = GRid2.objid, osnum = GRid2.osnum, p_classid = &cid);

      if (om$is_ancestry_valid (superclassid = OPP_EMSsolid_class_id, subclassid = cid) != OM_S_SUCCESS)
      {
	sol2 = FALSE;
      }
      if (om$is_ancestry_valid (superclassid = OPP_EMSsurface_class_id, subclassid = cid) != OM_S_SUCCESS)
      {
	sf2 = FALSE;
      }
      __printf ( "__LINE__ = %d, GRid1 = [%d,%d], GRid2 = [%d,%d], sf1 = %d, sf2 = %d",
                 `__LINE__, GRid1.osnum, GRid1.objid, GRid2.osnum, GRid2.objid, sf1, sf2` );

//////////////////////////////     START      VDconstruct_intersection_curves ( CI_MACRO_ID );
      /*
       * First test if GRid1 & GRid2 have the SAME owner of class VRCorrection :
       *   - if this is the case,
       *     then we do NOT create the macro OR the non-assoc (dumb) interference
       */

      p_ele1 = NULL;
      p_ele2 = NULL;

      if ( corr_chk = VDtest_GRid_1_2 ( &GRid1, &GRid2 ) )
      {
	int	  mac_sts;

	if ( always_make_macro  )
	{
          int store_in_macro = always_make_macro | avoid_false_interf;

          // We need to store avoid_false_interf in the instance data: macro_byt[0] also...

	  mac_sts = VDCreate_interf_macro ( &GRid1, &GRid2, openv, intersobj, &store_in_macro );
	}
	else
	{
	  struct GRid CI_MACRO_ID;

	  CI_MACRO_ID.objid = NULL_OBJID;
	  CI_MACRO_ID.osnum = 0;
          p_ele1            = &Ele1[i];
          p_ele2            = &Ele2[j];
//            memcpy (&p_ele1, &Ele1[i], sizeof(struct GRlc_info));
//            memcpy (&p_ele2, &Ele2[j], sizeof(struct GRlc_info));

	  keep_inters = TRUE;
	  mac_sts = VDconstruct_intersection_curves ( CI_MACRO_ID, 1 , intersobj, p_ele1, p_ele2 );
	  keep_inters = FALSE;
	}
      }
      else
      {
	continue;
      }

      *EMmsg     = retmsg;
      num_inters = num_interf_cvs;

      for (k=0; k < num_feet; k++)
      {
	__printf ( "<<<<< AFTER VDCreate_interf_macro() sts = %d, retmsg = %d, num_inters = %d, num_feet = %d, num_interf_GRid = %d, intersobj = [%d,%d]",
		   `sts, retmsg, num_inters, num_feet, num_interf_GRid, intersobj[k].osnum, intersobj[k].objid` );
      }

//////////////////////////////     FINISH      VDconstruct_intersection_curves ( CI_MACRO_ID );

      if((intpt = (*EMmsg == EMS_I_Interrupt ? TRUE : FALSE))) break;

      /*
       * HF: 06/28/99        TR 179900673
       * If, for whatever reason, num_inters > 0 AND num_interf_GRid == 0,
       * write these two elements to the error section of the report-file.
       */
      if ( num_inters > 0 && num_interf_GRid == 0 )
      {
        EMlocerrhndlr ( ! (1 & *EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], &Ele2[j], &numfail, &failed, &failBufSize, FALSE);
        continue;
      }

      /*
       * All we need is for num_inters to behave like a switch.
       */

      // When we are using EMintersect_two_element() we can NOT use this ...
      if (0)
      {
        if (!inters[0] || !inters[1])
          num_inters = FALSE;
        else
          num_inters = TRUE;
      }

     /*
      * The following return codes are possible if there is no intersection
      * (based on the cutting option) or if they were non orientable. We
      * ignore non orientable intersections, typically resulting out of
      * tangencies, for interference.
      */
      if( (*EMmsg == EMS_I_NotFound) || (*EMmsg == EMS_I_IntersectOrient))
	num_inters = 0;

      __printf ( "sts = %d, retmsg = %d, num_inters = %d, num_feet = %d, num_interf_GRid = %d",
                 `sts, retmsg, num_inters, num_feet, num_interf_GRid` );

     /*
      * If volume elements are desired and there is some intersection between
      * the two elements, perform boolean intersection. The two elements
      * must be surfaces and not just GRowners.
      *
      * HF: 07/03/97
      *
      * The following section will NOT be executed anymore because the command :
      * "VDS Interference Analysis" has been modified to NEVER ask for volumetric output
      * ================================================================================
      */
      if ( ! novol && num_inters && sf1 && sf2 )	/* ++++++++++ FROM HERE ++++++++++ */
      {
	IGRushort booloptions = EMSsfbool_opt_HandleStop;
	IGRboolean coolscene = TRUE;

	if((intpt = IGEstop())) break; 	/* user interrupt */

       /*
	* In case of any error after this point atleast output the
	* curves, if asked for and the fact that there was interference
        */
	sts = om$construct(classid = sol1 && sol2 ? OPP_EMSslboolean_class_id
						  : OPP_EMSsfboolean_class_id,
			   p_objid = &volelem.objid, osnum = openv->md_id.osnum);
	if(!(1&sts)) EMcleanup(&op1, &op2, &volelem, openv);

	EMlocerrinit (!(1&sts), volelem, op1, op2, coolscene);
	EMlocerrhndlr(!(1&sts), EMmsg, EMS_E_BoolFail, &Ele1[i],
		      &Ele2[j], &numfail, &failed, &failBufSize, FALSE);

	if(!sameobj)
	{
	  if(coolscene)
	  {
/****************************************************************************
	   sts = EMdupinters(EMmsg, &inters[0], NULL, FALSE, TRUE,
		&Ele1[i].located_obj, &op1, TRUE, env1, const_list, NULL, NULL,
		0, NULL, NULL, 0);
****************************************************************************/

	    __printf ( ">>>>>>>>>> 3 ems$dupinters() i =  %d, j = %d", `i, j` );

	    sts = ems$dupinters(msg = EMmsg,
				origsf_inters = &inters[0],
				copyintobjs = FALSE,
				delorigintobjs = TRUE,
				origsfid = &Ele1[i].located_obj,
				copysfid = &op1,
				origsfenv = env1,
				construction_args = const_list);
	    if(!(1&*EMmsg&sts)) EMcleanup(&op1, &op2, &volelem, openv);
	    EMlocerrinit(!(1&sts&*EMmsg), volelem, op1, op2, coolscene);
	    EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_BoolFail, &Ele1[i],
			  &Ele2[j], &numfail, &failed, &failBufSize, FALSE);

	    __printf ( "<<<<<<<<<< 3 ems$dupinters() i =  %d, j = %d", `i, j` );
	  }

	  if ( (intpt = IGEstop()) ) break; 	/* user interrupt */

	  if(coolscene)
	  {
/*****************************************************************************
	   sts = EMdupinters(EMmsg, &inters[1], NULL, FALSE, TRUE,
		&Ele2[j].located_obj, &op2, TRUE, env2, const_list, NULL, NULL,
		0, NULL, NULL, 0);
*****************************************************************************/

	    __printf ( ">>>>>>>>>> 4 ems$dupinters() i =  %d, j = %d", `i, j` );

	    sts = ems$dupinters(msg = EMmsg,
				origsf_inters = &inters[1],
				copyintobjs = FALSE,
				delorigintobjs = TRUE,
				origsfid = &Ele2[j].located_obj,
				copysfid = &op2,
				origsfenv = env2,
				construction_args = const_list);
	    if(!(1&*EMmsg&sts)) EMcleanup(&op1, &op2, &volelem, openv);
	    EMlocerrinit(!(1&sts&*EMmsg), volelem, op1, op2, coolscene);
	    EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_BoolFail, &Ele1[i],
			  &Ele2[j], &numfail, &failed, &failBufSize, FALSE);

	    __printf ( "<<<<<<<<<< 4 ems$dupinters() i =  %d, j = %d", `i, j` );

	  }
	}

	if(coolscene)
	{
	  __printf ( ">>>>>>>>>> EMboolean_surfaces_w_intersection() i =  %d, j = %d", `i, j` );

	  sts = EMboolean_surfaces_w_intersection(EMmsg, &volelem,
						  EMSbool_intersect, openv, op1.objid, 1, &op2.objid, inters[0],
						  inters[1], &trace[0], &trace[1], NULL, NULL,
						  booloptions, NULL, NULL, NULL /* sts_array */);

	  __printf ( "<<<<<<<<<< EMboolean_surfaces_w_intersection() i =  %d, j = %d", `i, j` );
	}

	if((intpt = (*EMmsg == EMS_I_Interrupt ? TRUE : FALSE)))
	{
	  EMcleanup(&op1, &op2, &volelem, openv);
	  break;
	}

	if(!(1&*EMmsg&sts) || !coolscene)
	{
	  coolscene = FALSE;
	  EMcleanup(&op1, &op2, &volelem, openv);
	  EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_BoolFail, &Ele1[i],
			&Ele2[j], &numfail, &failed, &failBufSize, FALSE);
	}

	if(coolscene)
	{
	  __printf ( ">>>>>>>>>> EMSdpr.EMmake_primitive1() i =  %d, j = %d", `i, j` );

	  sts = om$send(msg = message EMSdpr.EMmake_primitive1 (EMmsg, openv, &volelem),
			targetid = volelem.objid,
			targetos = volelem.osnum,
			senderid = NULL_OBJID);
	  if( (sts == OM_W_UNKNOWN_MSG) || (*EMmsg == EMS_E_InvalidSend))
	  {*EMmsg = EMS_S_Success; sts = OM_S_SUCCESS;}

	  if(!(1&*EMmsg&sts))
	  {
	    coolscene = FALSE;
	    EMcleanup(&op1, &op2, &volelem, openv);
	    EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_BoolFail, &Ele1[i],
			  &Ele2[j], &numfail, &failed, &failBufSize, FALSE);
	  }

	  __printf ( "<<<<<<<<<< EMSdpr.EMmake_primitive1() i =  %d, j = %d", `i, j` );
	}
      }	/* if(!(options & EMSintf_NoVolElems) && num_inters) */ 	/* ++++++++++ UNTIL HERE ++++++++++ */

      /*
       * If there is no intersection check for the an element completely
       * enclosing the other element.
       * in such a case we do not output interference curves even if
       * asked for. However we output the common volume (which will be the
       * entire solid inside) if the volume elements are asked for.
       */

      else if ( ! num_inters && sol1 && sol2)
      {
	EMinsideOutside(EMmsg, &Ele1[i], &Ele2[j], novol ? NULL : &volelem,
			const_list, &num_inters);
      }

      if(!num_inters || novol || !sf1 || !sf2)
	EMcleanup(&op1, &op2, &volelem, openv);

      EMinit(trace, inters, sfintloopsdata, loopdata, TRUE);

      if(num_inters)
      {
	struct EMSintf_qualitative *junk;
	IGRint	num;

	if(!RbufSize)
	{
	  if(!(*result))
	  {
	    *result = _MALLOC ( ResultBufInc, struct EMSintf );
//	    *result = (struct EMSintf *) om$malloc(size = ResultBufInc *
//						  sizeof(struct EMSintf));
	  }
	  else
	  {
	    *result = _REALLOC ( *result, ResultBufInc + *num_result, struct EMSintf );
//	    *result = (struct EMSintf *) om$realloc(ptr = (IGRchar *)(*result),
//						   size = (ResultBufInc + *num_result) *
//						   sizeof(struct EMSintf));
	  }
	  EMlocerrhndlr(!(*result), EMmsg, EMS_E_NoDynamicMemory, &Ele1[i],
			NULL, &numfail, &failed, &failBufSize, TRUE);
	  RbufSize = ResultBufInc;

	  this_result = (struct EMSintf *) &(*result)[*num_result];
	  this_result->numintf = 0;
	  this_result->intfInfoType = EMqualitative;
	  this_result->info.qualitative = NULL;
	  against = (struct EMSintf_qualitative **) &this_result->info.qualitative;
	}

	if (this_result == NULL)
	{
	  printf("Error, this_result is NULL in VD_EManalyzeIntf\n");
	  goto wrapup;
	}

	num = this_result->numintf;
	if(!bufSize)
	{
	  if (against == NULL)
	  {
	    printf("Error, against is NULL in VD_EManalyzeIntf\n");
	    goto wrapup;
	  }

	  if(!(*against))
	  {
	    *against = _MALLOC ( ResultBufInc, struct EMSintf_qualitative );
//	    *against = (struct EMSintf_qualitative *) om$malloc(size = ResultBufInc *
//				       sizeof(struct EMSintf_qualitative));
	  }
	  else
	  {
	    *against = _REALLOC ( *against, ResultBufInc + num, struct EMSintf_qualitative );
//	    *against = (struct EMSintf_qualitative *) om$realloc(
//								ptr  = (IGRchar *)(*against),
//								size = (ResultBufInc + num) *
//								sizeof(struct EMSintf_qualitative));
	  }
	  EMlocerrhndlr(!(*against), EMmsg, EMS_E_NoDynamicMemory, &Ele1[i],
			NULL, &numfail, &failed, &failBufSize, TRUE);
	  bufSize = ResultBufInc;
	}

	if (this_result == NULL)
	{
	  printf("Error, this_result is NULL in VD_EManalyzeIntf\n");
	  goto wrapup;
	}

	junk = (struct EMSintf_qualitative *) &this_result->info.qualitative[num];

	this_result->eleminfo  = Ele1[i];
	junk->against_eleminfo = Ele2[j];


	if(nocurves)
	  junk->inters.objid = NULL_OBJID;
	else
	  junk->inters = intersobj[0];

	if(novol)
	  junk->volelem.objid = NULL_OBJID;
	else
	  junk->volelem = volelem;

	if(options & EMSintf_Display)
	{
	  if(!IF_NULL_OBJID(junk->inters.objid))
	    EMintfDisplay(const_list->env_info, &junk->inters, TRUE);
	  if(!IF_NULL_OBJID(junk->volelem.objid))
	    EMintfDisplay(const_list->env_info, &junk->volelem, TRUE);
	}

	if (this_result == NULL)
	{
	  printf("Error, this_result is NULL in VD_EManalyzeIntf\n");
	  goto wrapup;
	}

	(this_result->numintf)++;
	bufSize--;
	atleastone = TRUE;

      }	/* if(num_inters) */

      num_inters = 0;

      __printf ( "<<<<<<<<<< i =  %d, j = %d", `i, j` );

    }	/* for(j=0; j<NumEle2; j++) */

    if(atleastone)
    {
      (*num_result)++;
      bufSize = 0;
      RbufSize--;
    }

    __printf ( "<<<<< i =  %d", `i` );

  }	/* for(i=0; i<NumEle1; i++) */

wrapup:

  if (boxint)
  {
    for (i=0; i < NumEle1; i++)
    {
      if (boxint[i]) _FREE (boxint[i]);
    }
    _FREE (boxint);
  }

  strcpy ( end_time, EMgettime() );

  if(!nomsg) ex$message(msgnumb = EMS_I_ClearStatusField);
  if (fpdb)
  {
    fprintf(fpdb, "\nExit  VD_EManalyzeIntf -- End   Time = %s", end_time);
    fclose (fpdb);
  }

  if ( post_process_inter && fp_post )
  {
    if ( 0 )
      fprintf(fp_post, "\nPost Processing: Total Number Deleted Interferences = %d\n", post_proc_deleted);
    else
      fprintf(fp_post, "\nPost Processing: Total Number Moved Interferences = %d\n", post_proc_deleted);

    fprintf(fp_post, "\nExit  VD_EManalyzeIntf -- End   Time = %s", end_time);
    fclose (fp_post);
  }

  if (stackptr)
  {
//    __printf ( "<<<<< stackfree() : stackptr = %#x", `stackptr` );
//    stackfree (stackptr);
    _FREE (stackptr);
  }
  if (siblings && siblings != sibling_store)
  {
    _FREE ( siblings );
  }

  if ( use_shrink_buffers && avoid_false_interf && (shrink_buff1 || shrink_buff2 ) )
  {
    struct GRmd_env	 mod_env;
    int			 BytesReceived = 0, NumberOfBytes = 0, shrunk_copies = 0;
    IGRlong		 status, msg;

    NumberOfBytes = sizeof(mod_env);
    gr$get_module_env (	msg	= &msg,
			sizbuf	= &NumberOfBytes,
			buffer	= &mod_env,
			nret	= &BytesReceived );
    if (shrunk_Set1)
    {
      __printf ( "Number of objects in shrunk_Set1 = %d", `NumEle1` );
      for (i=0; i< NumEle1; i++)
      {
        if ( shrunk_Set1[i].objid != NULL_OBJID )
        {
          shrunk_copies++;
          __printf ( "   Original: Ele1[%d].located_obj = [%d,%d],\tCopy: shrunk_Set1[%d] = [%d,%d]",
                     `i, Ele1[i].located_obj.osnum, Ele1[i].located_obj.objid, i, shrunk_Set1[i].osnum, shrunk_Set1[i].objid` );
          status =
            om$send(msg      = message GRgraphics.GRdelete(&msg, &mod_env),
                    targetid = shrunk_Set1[i].objid,
                    targetos = shrunk_Set1[i].osnum,
                    senderid = NULL_OBJID);
        }
      }
      __printf ( "Number of objects in shrunk_Set1 = %d, shrunk_copies = %d", `NumEle1, shrunk_copies` );
      idx_set1     = -1;
      shrink_buff1 = 0;
      _FREE (shrunk_Set1);
    }
    if (shrunk_Set2)
    {
      shrunk_copies = 0;
      for (i=0; i< NumEle2; i++)
      {
        if ( shrunk_Set2[i].objid != NULL_OBJID )
        {
          shrunk_copies++;
          __printf ( "   Original: Ele2[%d].located_obj = [%d,%d],\tCopy: shrunk_Set2[%d] = [%d,%d]",
                     `i, Ele2[i].located_obj.osnum, Ele2[i].located_obj.objid, i, shrunk_Set2[i].osnum, shrunk_Set2[i].objid` );
          status =
            om$send(msg      = message GRgraphics.GRdelete(&msg, &mod_env),
                    targetid = shrunk_Set2[i].objid,
                    targetos = shrunk_Set2[i].osnum,
                    senderid = NULL_OBJID);
        }
      }
      __printf ( "Number of objects in shrunk_Set2 = %d, shrunk_copies = %d", `NumEle2, shrunk_copies` );
      idx_set2     = -1;
      shrink_buff2 = 0;
      _FREE (shrunk_Set2);
    }
  }

//  if( (1 & *EMmsg & sts) && !(options & EMSintf_NoReport))
  if( (1 & sts) && !(options & EMSintf_NoReport))
  {
    IGRboolean repboth = FALSE, stdrep = FALSE;
    FILE	*fileptr;
    void VDinterference_report();

    repboth = options & EMSintf_ReportBoth;
    stdrep = repboth || !ReportFileName;

    if(ReportFileName)
    {
      {
	fileptr = fopen(ReportFileName, "a");
	if(!fileptr) {*EMmsg = EMS_E_FileOpen; goto wrapup;}

	VD_EMintf_report(numchecked,
			 Ele1, NumEle1, setnum1, SetInfo1,
			 Ele2, NumEle2, setnum2, SetInfo2,
			 *result,  *num_result, options, fileptr, start_time);
	if (numfail)
	  EMintf_failureReport(failed, numfail, fileptr);
	fclose(fileptr);
      }
    }

    if(stdrep)
    {
//    if ( always_make_macro )
//    {
//	VDinterference_report( "stdout", 1, 0, start_time );
//    }
//    else
      {
	VD_EMintf_report(numchecked,
			 Ele1, NumEle1, setnum1, SetInfo1,
			 Ele2, NumEle2, setnum2, SetInfo2,
			 *result, *num_result, options, stdout, start_time);
      }

      if (numfail)
	EMintf_failureReport(failed, numfail, stdout);
    }
  }

  if((*result) && (*result == locresult))
    EMintf_free(*result, *num_result);

  if (failed) _FREE ( failed );
  if (use_range_check)
  {
    printf("\nnr_rangebox_swp = %d, tot_coinc_face = %d\n", nr_rangebox_swp, tot_coinc_face);
  }
  EMinit(trace, inters, sfintloopsdata, loopdata, TRUE);

  __exitFunction ( name = "VD_EManalyzeIntf" );

  if(intpt) *EMmsg = EMS_I_Interrupt;
  EMWRAPUP(*EMmsg,sts,"In EMSsurface.VD_EManalyzeIntf");
  return(sts);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int	VDconstruct_intersection_curves
(
  struct GRid		 CI_MACRO_ID,
  int			 recompute,
  struct GRid		*out_cvs,
  struct GRlc_info	*p_ele1,
  struct GRlc_info	*p_ele2
)
{
  static char           *superclassnm_1 = {"VRComponent"};
  static char           *superclassnm_2 = {"VRConcComp"};
  union	state		*intf_flags;
  union state		 macro_state;
  OMuword		 clid0, clid1;
  IGRushort		 outworld_opt, outparam_opt, trim_opt, inters_opt;
  IGRshort		 level, route_component = 0;
  IGRboolean		 save_pathway_trim, save_pathway_orient;
  IGRboolean		 sf1, sf2, sol1, sol2, sameobj = FALSE, world = 1, overlap = 0, dumdum;
  int			 BytesReceived = 0, NumberOfBytes, copy_num = 0;
  int                    i0, j0, k0, tot_int = 0, nbsf1 = 0, nbsf2 = 0;
  IGRint		 num_ent = 0, num_inters = 0;
  IGRlong		 status, msg;
  GRobjid		 INTF_OBJ[MAX_NUM_SRF];
  struct GRid		*GRinters = NULL, op1, op2, volelem, GRidcpy, GRid_12[2];
  struct GRid		 go_sup[2], OBJ_ID[2], tmp_CVS[MAX_NUM_SRF], INTF_CVS[MAX_NUM_SRF];
  struct GRlc_info	 srf1[MAX_NUM_SRF], srf2[MAX_NUM_SRF], *p_srf1 = NULL, *p_srf2 = NULL;
  struct GRmd_env	*mdsf1 = NULL, *mdsf2 = NULL;
  struct GRmd_env	 mod_env, sup_env[2], mdenv12[2];
  GRrange		 range[2];

  struct GRvg_construct	 cst;
  struct IGRdisplay	 dis;

  OM_S_CLASSLIST	 sfclass_list;
  OM_S_CHANSELECT	 my_chansel;
  OM_S_OBJECT_LINKAGE    lobjs[2];

  struct EMSsftracedata		 trace[2];
  struct EMSsfintloopsdata	 sfintloopsdata[2], *loopdata[2];
  struct EMSdataselect		 other;

  __enterFunction ( name = "VDconstruct_intersection_curves", argfmt = "CI_MACRO_ID: [%d,%d]", args = `CI_MACRO_ID.osnum, CI_MACRO_ID.objid`  );

  sfclass_list.p_classes = &OPP_EMSsurface_class_id;
  sfclass_list.w_count   = 1;
  sfclass_list.w_flags   = OM_CLST_subclass;
  my_chansel.type        = OM_e_name;
  my_chansel.u_sel.name  = "to_components";

  p_srf1 = srf1;
  p_srf2 = srf2;

  NumberOfBytes = sizeof(mod_env);
  gr$get_module_env (	msg	= &msg,
			sizbuf	= &NumberOfBytes,
			buffer	= &mod_env,
			nret	= &BytesReceived );

  NumberOfBytes = sizeof(dis);
  gr$get_active_display ( msg	= &msg,
			  sizbuf= &NumberOfBytes,
			  buffer= &dis,
			  nret	= &BytesReceived );

  NumberOfBytes = sizeof(level);
  gr$get_active_level ( msg	= &msg,
			sizbuf  = &NumberOfBytes,
			buffer  = &level,
			nret	= &BytesReceived );

  for ( i0=0; i0 < MAX_NUM_SRF; i0++ )
  {
    INTF_CVS[i0].objid = INTF_OBJ[i0] = NULL_OBJID;
    INTF_CVS[i0].osnum = mod_env.md_id.osnum;
  }

  if ( CI_MACRO_ID.objid != NULL_OBJID )
  {
    /*
     * This is tricky: get a pointer into the instance data of the macro
     */
    status =
      om$send ( msg      = message ci_macro.give_internal_ptr ( (IGRint *) &msg, (IGRchar **) &intf_flags ),
                senderid = NULL_OBJID,
                targetid = CI_MACRO_ID.objid,
                targetos = CI_MACRO_ID.osnum);

    //__printf ( "<<<<<<<<<< ci_macro.give_internal_ptr : status = %d, msg = %d, size = %d", `status, msg, sizeof (intf_flags)` );

    if( ! ( status & msg & 1 ) )
    {
      goto wrapup;
    }

    macro_state = *intf_flags;

    if ( recompute )
    {
      always_make_macro  = macro_state.byt_stat[0] & (ASSOC_OPTION_1 | ASSOC_OPTION_2);
      avoid_false_interf = macro_state.byt_stat[0] & AVOID_FALSE_INTF;
    }

    __printf ( "CI_MACRO_ID: [%d,%d], always_make_macro = %d, avoid_false_interf = %d, STATE = %d, %d, %d, %d",
               `CI_MACRO_ID.osnum, CI_MACRO_ID.objid, always_make_macro, avoid_false_interf,
               macro_state.byt_stat[0], macro_state.byt_stat[1], macro_state.byt_stat[2], macro_state.byt_stat[3]` );
  }

  if ( always_make_macro == 0 && CI_MACRO_ID.objid == NULL_OBJID )
  {
    num_ent = 2;

    go_sup [0] = p_ele1->located_obj;
    go_sup [1] = p_ele2->located_obj;

    sup_env[0] = p_ele1->module_info;
    sup_env[1] = p_ele2->module_info;

    GRid_12[0] = go_sup [0];
    GRid_12[1] = go_sup [1];
  }
  else
  {
    /*
     * Find the number or templates for input.
     */
    status =
      om$send ( msg      = message NDnode.NDget_objects ( ND_ROOT, NULL, 0, NULL,
                                                          0, OM_K_MAXINT, &num_ent),
                senderid = NULL_OBJID,
                targetid = CI_MACRO_ID.objid,
                targetos = CI_MACRO_ID.osnum);
    if ( ! ( status & 1 ) || num_ent > MAX_TEMP )
    {
      __print_goto ( "wrapup" );
      goto wrapup;
    }

//      __printf ( "num_ent    : %d", num_ent );
//      __printf ( "CI_MACRO_ID: [%d,%d]", `CI_MACRO_ID.osnum, CI_MACRO_ID.objid` );

    for ( i0=0; i0 < num_ent; i0++ )
    {
      status =
        om$send ( msg      = message  ACcpx.ACfind_exp_temp_obj ( (int *)&msg, i0, &OBJ_ID[i0] ),
                  senderid = NULL_OBJID,
                  targetid = CI_MACRO_ID.objid,
                  targetos = CI_MACRO_ID.osnum );
      if( ! ( status & msg & 1 ) )
      {
        __print_goto ( "wrapup" );
        goto wrapup;
      }
      __printf ( "OBJ_ID[%d]  : [%d,%d]", `i0, OBJ_ID[i0].osnum, OBJ_ID[i0].objid` );
      // Initialize..., VERY IMPORTANT, ACreturn_foot does NOT update sup_env[i0].md_id's
      sup_env[i0] = mod_env;

      status =
        om$send ( msg      = message NDmacro.ACreturn_foot( &msg, "",
                                                            &go_sup [i0],
                                                            &sup_env[i0].md_env.matrix_type,
                                                             sup_env[i0].md_env.matrix ),
                  senderid = NULL_OBJID,
                  targetid = OBJ_ID[i0].objid,
                  targetos = OBJ_ID[i0].osnum );
      as$status();

      GRid_12[i0] = go_sup [i0];
    }
  }

  for ( i0=0; i0 < num_ent; i0++ )
  {
    sup_env[i0].md_id.osnum    = go_sup[i0].osnum;

    status =
      ex$get_modid ( mod_osnum =  sup_env[i0].md_id.osnum,
                     mod_id    = &sup_env[i0].md_id.objid );

    mdenv12[i0] = sup_env[i0];
  }

//////////////////////////////     START      VD_avoid_false_interf
  /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   * HF: 05/30/00 TR 179901258  Functionality to prevent generating so-called 'false' interferences
   *
   * Get the rangebox of GRid1 & GRid2. Scale (GRcptform) the smaller object with SCALE_FCT
   * about the centerpoint of its range BEFORE intersecting
   */

  if ( avoid_false_interf )
  {
    status = VDshrink_one_object ( CI_MACRO_ID, GRid_12, mdenv12, &mod_env, &GRidcpy, &copy_num);
  }
  if ( status & 1 && copy_num && GRidcpy.objid != NULL_OBJID )
  {
    go_sup[copy_num - 1] = GRidcpy;
  }
//////////////////////////////     END      VD_avoid_false_interf

  for ( i0=0; i0 < num_ent; i0++ )
  {
    __printf ( "go_sup[%d]  : [%d,%d]", `i0, go_sup[i0].osnum, go_sup[i0].objid` );

    status =
      om$send (msg      = message GRvg.GRgetrang ( &msg,
                                                   &sup_env[i0].md_env.matrix_type,
                                                    sup_env[i0].md_env.matrix,
                                                   &world,
                                                    range[i0] ),
               senderid = NULL_OBJID,
               targetid = go_sup[i0].objid,
               targetos = go_sup[i0].osnum );
    as$status();

    __printf ( "Range[LO] %d: %14.6lf %14.6lf %14.6lf", `i0, range[i0][0], range[i0][1], range[i0][2]` );
    __printf ( "Range[HI] %d: %14.6lf %14.6lf %14.6lf", `i0, range[i0][3], range[i0][4], range[i0][5]` );
  }

  // Check if the range-boxes overlap...
  //overlap = BSbxint (&msg, &range[0][0], &range[0][3], &range[1][0], &range[1][3]);

  /*
   * Setup up const_lst
   */

//  dis.color    = 1;	//cnst_list.color;
//  dis.weight   = 1;
//  dis.style    = 0;	//cnst_list.style;

  cst.msg        = &msg;
  cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cst.display    = &dis;
  cst.env_info   = &mod_env;
  cst.newflag    = 0;
  cst.level      = level;
  cst.geometry   = NULL;
  cst.class_attr = 0;
  cst.name       = 0;

  if ( IF_EQ_GRID ( go_sup[0], go_sup[1] ) )
    sameobj = TRUE;
  else
    sameobj = FALSE;

  /*
   * Construct the Interference_curves
   */
  EMinit(trace, inters, sfintloopsdata, loopdata, FALSE);
  EMinit(trace, inters, sfintloopsdata, loopdata, TRUE);

  save_pathway_trim   = _pathway_trim;
  save_pathway_orient = _pathway_orient;
  _pathway_trim       = _pathway_orient = 1;

  outworld_opt = EMSINT_OUTPUT_WORLD;

  outparam_opt = EMSINT_OUTPUT_PARAM  | EMSINT_PARAM_OBJECT |
		 EMSINT_ORIENT_OUTPUT | EMSINT_ORIENT_RIGHT;

/* All possible TRIM & SFINT flags ...
#define EMSINT_TRIM_OUTPUT		0x0001
#define EMSINT_TRIM_COPLANAR		0x0002
#define EMSINT_TRIM_BDRYISAREA		0x0004
#define EMSINT_TRIM_MOREPRECISE		0x0008
#define EMSINT_TRIM_OPSWITCHED		0x0010
#define EMSINT_TRIM_PROCOVERLAP		0x0020
#define EMSINT_TRIM_ONLYCUTTING		0x0040
#define EMSINT_TRIM_HANDLESTOP		0x0080
#define EMSINT_TRIM_IGNOREVOLUME	0x0100
#define EMSINT_TRIM_RETAIN_ON_PRIMARY	0x0200
#define EMSINT_TRIM_DELETE_ON_SECONDARY	0x0400

#define EMS_SFINT_MUSTINTERSECT		0x0001
#define EMS_SFINT_MUSTCLOSE		0x0002
#define EMS_SFINT_MUSTORIENT		0x0004
#define EMS_SFINT_MUSTNOAMBIGUOUS	0x0008
#define EMS_SFINT_SKIPSFINT		0x0010
#define EMS_SFINT_NOREFINE		0x0020
#define EMS_SFINT_DOUBLECHECK		0x0040
#define EMS_SFINT_SKIPFIXING		0x0080
#define EMS_SFINT_AUTODOUBLECHECK	0x0100
#define EMS_SFINT_REVERSESECONDINT	0x0200
#define EMS_SFINT_HANDLESTOP		0x0400
#define EMS_SFINT_PUSHBADCOINC		0x0800
#define EMS_SFINT_MARKEDDELINFO		0x1000
#define EMS_SFINT_YESORNO		0x2000
#define EMS_SFINT_NOCURVECOPY		0x4000
#define EMS_SFINT_CHTTRACETOL		0x8000
*/

//    trim_opt = EMSINT_TRIM_OUTPUT      | EMSINT_TRIM_BDRYISAREA |
//  		 EMSINT_TRIM_COPLANAR    | EMSINT_TRIM_MOREPRECISE |
//  		 EMSINT_TRIM_PROCOVERLAP | EMSINT_TRIM_ONLYCUTTING;

//inters_opt =	 EMS_SFINT_DOUBLECHECK | EMS_SFINT_HANDLESTOP;	// | (!outp ? EMS_SFINT_YESORNO : NULL);

  // Use the same options as IntTwoSrf()
  trim_opt =	 EMSINT_TRIM_OUTPUT     |
                 EMSINT_TRIM_PROCOVERLAP|
                 EMSINT_TRIM_BDRYISAREA |
                 EMSINT_TRIM_COPLANAR   |
                 EMSINT_TRIM_HANDLESTOP;

  // Using EMS_SFINT_SKIPFIXING gives dramatic performance improvement in some cases....!!!!!
  inters_opt =	 EMS_SFINT_SKIPFIXING  |
                 EMS_SFINT_HANDLESTOP  |
                 EMS_SFINT_NOREFINE;

  lobjs[0].osnum   = go_sup[0].osnum;
  lobjs[0].S_objid = go_sup[0].objid;
  lobjs[1].osnum   = go_sup[1].osnum;
  lobjs[1].S_objid = go_sup[1].objid;

  sol1 = sol2 = sf1 = sf2 = TRUE;

  om$get_classid (objid = go_sup[0].objid, osnum = go_sup[0].osnum, p_classid = &clid0);

  if (om$is_ancestry_valid (superclassid = OPP_EMSsolid_class_id, subclassid = clid0) != OM_S_SUCCESS)
  {
    sol1 = FALSE;
  }

  if (om$is_ancestry_valid (superclassid = OPP_EMSsurface_class_id, subclassid = clid0) != OM_S_SUCCESS)
  {
    sf1 = FALSE;
  }

  om$get_classid (objid = go_sup[1].objid, osnum = go_sup[1].osnum, p_classid = &clid1);

  if (om$is_ancestry_valid (superclassid = OPP_EMSsolid_class_id, subclassid = clid1) != OM_S_SUCCESS)
  {
    sol2 = FALSE;
  }

  if (om$is_ancestry_valid (superclassid = OPP_EMSsurface_class_id, subclassid = clid1) != OM_S_SUCCESS)
  {
    sf2 = FALSE;
  }

  if ( om$is_ancestry_valid ( subclassid = clid0, superclassname = superclassnm_1 ) == OM_S_SUCCESS ||
       om$is_ancestry_valid ( subclassid = clid0, superclassname = superclassnm_2 ) == OM_S_SUCCESS ||
       om$is_ancestry_valid ( subclassid = clid1, superclassname = superclassnm_1 ) == OM_S_SUCCESS ||
       om$is_ancestry_valid ( subclassid = clid1, superclassname = superclassnm_2 ) == OM_S_SUCCESS  )
  {
    route_component = 1;
  }

  // When dealing with composite objects, we need to recursively retrieve the (nested) solids/surfaces on the "to_component" channel,
  // if we want to use the function EMintersect_two_element()...
  //
  // We cannot use EMintersect_two_element() on ROUTE component objects ...!!!
  if ( route_component == FALSE )
  {
    short opt_all = 0;      // Do NOT decompose solids/compsurfaces

    if ( ! sf1 && ! sol1 )
    {
      nbsf1  = 0;
      status = VDrecursCountGridsOnChan ( lobjs[0], &my_chansel, -OPP_EMSsurface_class_id, opt_all, &nbsf1 );
      __printf ( "VDrecursCountGridsOnChan() nbsf1 = %d, status = %d", `nbsf1, status` );

      if ( nbsf1  )
      {
        VDget_ptr_to_memory( nbsf1 );
        if ( p_FoundId )
        {
          nbsf1  = 0;
          status = VDrecursGetGridsFromChan ( lobjs[0], &my_chansel, -OPP_EMSsurface_class_id, opt_all, &nbsf1 );

          // HF: 10/08/2001	Fix for TR# MP5640 (etl10419)
          if (nbsf1 > MAX_NUM_SRF)
          {
            p_srf1 = _MALLOC( nbsf1, struct GRlc_info);
            if ( ! p_srf1 )
            {
              status = msg = 0;
              EMerr_hndlr ( status, msg, EMS_E_NoDynamicMemory, wrapup);
            }
          }

          for (i0=0; i0 < nbsf1; i0++)
          {
            p_srf1[i0].located_obj = p_FoundId[i0];
            p_srf1[i0].module_info = sup_env[0];

            __printf ( "    p_FoundId[%d] = [%d,%d], p_srf1[].md_id = [%d,%d], p_srf1[].matrix_type = %d",
                       `i0, p_FoundId[i0].osnum, p_FoundId[i0].objid,
                       p_srf1[i0].module_info.md_id.osnum, p_srf1[i0].module_info.md_id.objid, p_srf1[i0].module_info.md_env.matrix_type` );
          }
          VDfree_ptr_to_memory();
        }
      }
    }

    if ( ! sf2 && ! sol2 )
    {
      nbsf2  = 0;
      status = VDrecursCountGridsOnChan ( lobjs[1], &my_chansel, -OPP_EMSsurface_class_id, opt_all, &nbsf2 );
      __printf ( "VDrecursCountGridsOnChan() nbsf2 = %d, status = %d", `nbsf2, status` );

      if ( nbsf2 )
      {
        VDget_ptr_to_memory( nbsf2 );
        if ( p_FoundId )
        {
          nbsf2  = 0;
          status = VDrecursGetGridsFromChan ( lobjs[1], &my_chansel, -OPP_EMSsurface_class_id, opt_all, &nbsf2 );

          // HF: 10/08/2001	Fix for TR# MP5640 (etl10419)
          if (nbsf2 > MAX_NUM_SRF)
          {
            p_srf2 = _MALLOC( nbsf2, struct GRlc_info);
            if ( ! p_srf1 )
            {
              status = msg = 0;
              EMerr_hndlr ( status, msg, EMS_E_NoDynamicMemory, wrapup);
            }
          }

          for (i0=0; i0 < nbsf2; i0++)
          {
            p_srf2[i0].located_obj = p_FoundId[i0];
            p_srf2[i0].module_info = sup_env[0];

            __printf ( "    p_FoundId[%d] = [%d,%d], p_srf2[].md_id = [%d,%d], p_srf2[].matrix_type = %d",
                       `i0, p_FoundId[i0].osnum, p_FoundId[i0].objid,
                       p_srf2[i0].module_info.md_id.osnum,  p_srf2[i0].module_info.md_id.objid, p_srf2[i0].module_info.md_env.matrix_type` );
          }
          VDfree_ptr_to_memory();
        }
      }
    }

    if ( nbsf1 == 0 )
    {
      if ( p_ele1 )
      {
        memcpy (&srf1[0], p_ele1, sizeof(struct GRlc_info));
      }
      else
      {
        srf1[0].located_obj = go_sup [0];
        srf1[0].module_info = sup_env[0];
      }
      nbsf1 = 1;
    }
    if ( nbsf2 == 0 )
    {
      if ( p_ele2 )
      {
        memcpy (&srf2[0], p_ele2, sizeof(struct GRlc_info));
      }
      else
      {
        srf2[0].located_obj = go_sup [1];
        srf2[0].module_info = sup_env[1];
      }
      nbsf2 = 1;
    }
  }

  // It would be nice if we could replace ALL intersections with EMintersect_two_element() ==>> much cleaner & very much faster results ...!!!
  if ( use_old_intf == FALSE && route_component == FALSE)
  {
    for (i0=0; i0 < nbsf1; i0++)
    {
      for (j0=0; j0 < nbsf2; j0++)
      {
        GRinters = NULL;
        status = EMintersect_two_element ( &p_srf1[i0], &p_srf2[j0], trim_opt, &cst, (IGRlong*) &num_inters, &GRinters, &msg);

        if ( num_inters > 0 )
        {
          __printf ( "EMintersect_two_element() num_inters = %d, trim_opt = %d, status = %d, msg = %#x, p_srf1[%d] = [%d,%d], p_srf2[%d] = [%d,%d]",
                     `num_inters, trim_opt, status, msg,
                     i0, p_srf1[i0].located_obj.osnum, p_srf1[i0].located_obj.objid,
                     j0, p_srf2[j0].located_obj.osnum, p_srf2[j0].located_obj.objid` );
        }

        for (k0=0; k0 < num_inters && tot_int < MAX_NUM_SRF; k0++)
        {
          if( om$is_objid_valid ( osnum = GRinters[k0].osnum, objid = GRinters[k0].objid ) )
          {
            tmp_CVS[tot_int] = GRinters[k0];
            tot_int++;
          }
        }
        if (GRinters) { _FREE( GRinters ); GRinters = NULL; }
      }
    }
    for ( i0=0; i0 < MAX_NUM_SRF; i0++ )
    {
      INTF_CVS[i0].objid = INTF_OBJ[i0] = NULL_OBJID;
    }
    num_inters = tot_int;
    for ( i0=0, num_interf_GRid=0; i0 < MIN(num_inters,MAX_NUM_SRF); i0++, num_interf_GRid++ )
    {
      INTF_CVS[i0] = tmp_CVS[i0];
      INTF_OBJ[i0] = INTF_CVS[i0].objid;

      __printf ( "tot_num_inters = %d, INTF_CVS[%d] = [%d,%d]",
                 `num_inters, i0, INTF_CVS[i0].osnum, INTF_CVS[i0].objid` );

      if ( INTF_CVS[i0].objid == NULL_OBJID )
      {
        break;
      }
    }
    if (num_inters > 1)
    {
      IGRlong msg_loc;
      status = EFbuild_graphic_group (num_inters, NULL, INTF_CVS, &cst, INTF_OBJ, &msg_loc);

      __printf ( "EFbuild_graphic_group() num_inters = %d, status = %d, msg_loc = %#x, INTF_OBJ[0] = %d",
                   `num_inters, status, msg_loc, INTF_OBJ[0]` );

      if (status & msg_loc & 1)
      {
        INTF_CVS[0].objid = INTF_OBJ[0];
        INTF_CVS[1].objid = NULL_OBJID;
      }
      //      EMerr_hndlr (EMSerror (msg_loc), msg, EMS_E_Fail, wrapup);

      // If everything went OK, reset num_inters to 1 ...
      //num_inters = 1;
    }
  }
  else
  {
    __printf ( "__LINE__ = %d, go_sup[0] = [%d,%d], go_sup[1] = [%d,%d], sf1 = %d, sf2 = %d",
               `__LINE__, go_sup[0].osnum, go_sup[0].objid, go_sup[1].osnum, go_sup[1].objid, sf1, sf2` );

    other.datatype    = EMSdata_object;
    other.data.object = &go_sup[1];

    if (!sf1 || !sf2)
    {
      IGRint inx1, inx2;
      IGRlong pass_rc;
      struct GRmdenv_info *this_mdenv_info, *other_mdenv_info;
      struct GRid          this_grid, other_grid;
      /*
       * HF: 06/28/99        TR 179900673
       */
      if (!sf1)
      {
        inx1 = 0;
        inx2 = 1;

        this_grid        = go_sup[0];
        other_grid       = go_sup[1];

        this_mdenv_info  = &sup_env[0].md_env;
        other_mdenv_info = &sup_env[1].md_env;
      }
      else
      {
        inx1 = 1;
        inx2 = 0;

        this_grid        = go_sup[1];
        other_grid       = go_sup[0];

        this_mdenv_info  = &sup_env[1].md_env;
        other_mdenv_info = &sup_env[0].md_env;
      }

      __printf ( ">>>>>>>>>> GRowner.GRpass_messg->EMSsurface.EMowner_sfsfint() go_sup[0] = [%d,%d], go_sup[1] = [%d,%d]",
                 `go_sup[0].osnum, go_sup[0].objid, go_sup[1].osnum, go_sup[1].objid` );

      status =
      om$send ( msg = message GRowner.GRpass_messg
                   			( &pass_rc, NULL,
                                          OM_e_wrt_object,
                                          message EMSsurface.EMowner_sfsfint
                                         			( &msg,
                                                                   this_mdenv_info,
                                                                  &other_grid,
                                                                   other_mdenv_info,
                                                                   inters_opt,
                                                                   outworld_opt,
                                                                   outparam_opt,
                                                                   trim_opt,
                                                                  &cst,
                                                                  &num_inters,
                                                                  &inters[inx1],
                                                                  &inters[inx2],
                                                                  INTF_OBJ,
                                                                  NULL,
                                                                  NULL		//sts_array
                                                                ),
                                                       this_mdenv_info,
                                                       &sfclass_list, NULL, NULL, NULL, MAXINT),
                   targetid = this_grid.objid,
                   targetos = this_grid.osnum,
                   senderid = NULL_OBJID);

      for ( i0=0, num_interf_GRid=0; i0 < MIN(num_inters,MAX_FEET); i0++, num_interf_GRid++ )
      {
        INTF_CVS[i0].objid = INTF_OBJ[i0];

        __printf ( "<<<<<<<<<< GRowner.GRpass_messg->EMSsurface.EMowner_sfsfint() num_inters = %d, INTF_CVS[%d] = [%d,%d], status = %d, msg = %d",
                   `num_inters, i0, INTF_CVS[i0].osnum, INTF_CVS[i0].objid, status, msg` );

        if ( INTF_OBJ[i0] == NULL_OBJID )
        {
          break;
        }
      }
    }
    else
    {
      if(sameobj)
      {
        struct EMSdataselect locother;

        op1.objid = NULL_OBJID;
        op2.objid = NULL_OBJID;
        volelem.objid = NULL_OBJID;

        status =
          ems$dupinters (	msg			 = &msg,
                                copyintobjs		 =  FALSE,
                                delorigintobjs		 =  TRUE,
                                origsfid		 = &go_sup [0],
                                copysfid		 = &op1,
                                origsfenv		 = &sup_env[0],
                                construction_args	 = &cst);

        if(!(1&msg&status)) EMcleanup(&op1, &op2, &volelem, &mod_env);

        //      EMlocerrhndlr(!(1&status&msg), &msg, EMS_E_Intersect, &Ele1[i], &Ele2[j], &numfail, &failed, &failBufSize, TRUE);

        status =
          ems$dupinters (	msg			 = &msg,
                                copyintobjs		 =  FALSE,
                                delorigintobjs		 =  TRUE,
                                origsfid		 = &go_sup [1],
                                copysfid		 = &op2,
                                origsfenv		 = &sup_env[1],
                                construction_args	 = &cst);

        //      EMlocerrhndlr(!(1&status&msg), &msg, EMS_E_Intersect, &Ele1[i], &Ele2[j], &numfail, &failed, &failBufSize, TRUE);

        locother.datatype    = EMSdata_object;
        locother.data.object = &op2;

        __printf ( ">>>>>>>>>> 2 ems$intersect_surfaces() go_sup[0] = [%d,%d], go_sup[1] = [%d,%d]",
		   `go_sup[0].osnum, go_sup[0].objid, go_sup[1].osnum, go_sup[1].objid` );

        status =
          ems$intersect_surfaces(
            msg			 = &msg,
            surface1		 = &op1,
            surface1env		 = &mod_env,
            numsurfaces2	 = 1,
            surfaces2		 = &locother,
            surfaces2env	 = &mod_env,
            inters_opts		 =  inters_opt,
            world_opts		 =  outworld_opt,
            param_opts		 =  outparam_opt,
            trim_opts		 =  trim_opt,
            construction_args	 = &cst,
            num_inters		 = &num_inters,
            surface1_inters	 = &inters[0],
            surfaces2_inters	 = &inters[1],
            surface1_tracedata	 = &trace[0],
            surfaces2_tracedata	 = &trace[1],
            inters_outputobj	 = INTF_OBJ,			//nocurves ? NULL :
            status_str		 = NULL,			//sts_array
            );

        for ( i0=0, num_interf_GRid=0; i0 < MIN(num_inters,MAX_FEET); i0++, num_interf_GRid++ )
        {
          INTF_CVS[i0].objid = INTF_OBJ[i0];

          __printf ( "<<<<<<<<<< 2 ems$intersect_surfaces() num_inters = %d, INTF_CVS[%d] = [%d,%d], status = %d, msg = %d",
                     `num_inters, i0, INTF_CVS[i0].osnum, INTF_CVS[i0].objid, status, msg` );

          if ( INTF_OBJ[i0] == NULL_OBJID )
          {
            break;
          }
        }
      }
      else
      {
        __printf ( ">>>>>>>>>> 1 ems$intersect_surfaces() go_sup[0] = [%d,%d], go_sup[1] = [%d,%d]",
		   `go_sup[0].osnum, go_sup[0].objid, go_sup[1].osnum, go_sup[1].objid` );

        status =
          ems$intersect_surfaces(
            msg			 = &msg,
            surface1		 = &go_sup [0],
            surface1env		 = &sup_env[0].md_env,
            numsurfaces2	 = 1,
            surfaces2		 = &other,
            surfaces2env	 = &sup_env[1].md_env,
            inters_opts		 =  inters_opt,
            world_opts		 =  outworld_opt,
            param_opts		 =  outparam_opt,
            trim_opts		 =  trim_opt,
            construction_args	 = &cst,
            num_inters		 = &num_inters,
            surface1_inters	 = &inters[0],
            surfaces2_inters	 = &inters[1],
            surface1_tracedata	 = &trace[0],
            surfaces2_tracedata	 = &trace[1],
            inters_outputobj	 = INTF_OBJ,			//nocurves ? NULL :
            status_str		 = NULL,			//sts_array
            );

        for ( i0=0, num_interf_GRid=0; i0 < MIN(num_inters,MAX_FEET); i0++, num_interf_GRid++ )
        {
          INTF_CVS[i0].objid = INTF_OBJ[i0];

          __printf ( "<<<<<<<<<< 1 ems$intersect_surfaces() num_inters = %d, INTF_CVS[%d] = [%d,%d], status = %d, msg = %d",
                     `num_inters, i0, INTF_CVS[i0].osnum, INTF_CVS[i0].objid, status, msg` );

          if ( INTF_OBJ[i0] == NULL_OBJID )
          {
            break;
          }
        }
      }
    }
  }

  //
  // HF: 09/25/2001 - Fix/Kludge for TR# MP5347
  // Some Struct Beams do have somewhat incorrect loopsets...
  // This results sometimes in intersections where there should not be ANY !!!
  // This KLUDGE intersects the resulting intersection curves with both surface/solid (input) objects,
  // and rejects it as an invalid intersection if ONLY ONE results in a new intersection...
  // Of course, this carries a performance penalty !!!
  //
  // Unfortunately, as a large testcase, with a couple of hundred real interferences, reveiled,
  // testing for BOTH new intersections to be generated doesn't work, because, not even ONE
  // intersection remained, when testing for both (srf_cvs_intf[0] + srf_cvs_intf[1] == 2)
  //
  // By default, this code-section is NOT executed.
  // It can be activated by using the PPL (calls function: toggle_post_process_intf() ):
  //
  //	ci=toggle_post
  //

  if ( post_process_inter && INTF_CVS[0].objid != NULL_OBJID )
  {
    int               num_intf_cvs = 0, nrobj = 0, srf_cvs_intf[2];
    struct GRlc_info  p_srf[2], cvs_intf;
    struct GRid      *cmpID = NULL;

    srf_cvs_intf[0]      = srf_cvs_intf[1] = 0;
    p_srf[0].located_obj = go_sup[0];
    p_srf[1].located_obj = go_sup[1];
    p_srf[0].module_info = sup_env[0];
    p_srf[1].module_info = sup_env[1];
    cvs_intf.module_info = mod_env;

    // Get the curve objects from the to_component channel of the intersection...
    VDget_comp_chan_crvs( INTF_CVS[0], &nrobj, &cmpID );

    for (i0=0; i0 < 2; i0++)
    {
      for (j0=0; j0 < nrobj; j0++)
      {
        GRinters = NULL;
        cvs_intf.located_obj = cmpID[j0];

        status = EMintersect_two_element ( &p_srf[i0], &cvs_intf, trim_opt, &cst, (IGRlong*) &num_intf_cvs, &GRinters, &msg);

        __printf ( "EMintersect_two_element() num_intf_cvs = %d, status = %d, msg = %#x, p_srf[%d] = [%d,%d], cvs_intf = [%d,%d]",
                   `num_intf_cvs, status, msg,
                   i0, p_srf[i0].located_obj.osnum, p_srf[i0].located_obj.objid,
                   cvs_intf.located_obj.osnum, cvs_intf.located_obj.objid` );

        if ( num_intf_cvs > 0 )
        {
          srf_cvs_intf[i0] = 1;

          for (k0=0; k0 < num_intf_cvs; k0++)
          {
            status = om$send(msg      = message GRgraphics.GRdelete(&msg, &mod_env),
                             targetid = GRinters[k0].objid,
                             targetos = GRinters[k0].osnum,
                             senderid = NULL_OBJID);
            as$status();
          }
        }
        if (GRinters) _FREE( GRinters );
      }
    }
    if ( srf_cvs_intf[0] + srf_cvs_intf[1] == 1 )
    {
      struct GRsymbology smb;

      if ( 0 )
      {
        num_inters = 0;
        status = om$send(msg      = message GRgraphics.GRdelete(&msg, &mod_env),
                         targetid = INTF_CVS[0].objid,
                         targetos = INTF_CVS[0].osnum,
                         senderid = NULL_OBJID);
        as$status();
        fprintf(fp_post, "Deleted Interference between Objects [%d,%d] and [%d,%d]\n",
                GRid_12[0].osnum, GRid_12[0].objid, GRid_12[1].osnum, GRid_12[1].objid);
      }
      else
      {
        gr$get_symbology( object_id = &INTF_CVS[0], symb = &smb );
        smb.display_attr.color++;
        smb.level++;
        gr$put_symbology( object_id = &INTF_CVS[0], symb = &smb );

        fprintf(fp_post, "Moved Interference between Objects [%d,%d] and [%d,%d] to layer %d\n",
                GRid_12[0].osnum, GRid_12[0].objid, GRid_12[1].osnum, GRid_12[1].objid, smb.level);
      }
      fflush (fp_post);

      post_proc_deleted++;
    }
    __printf ( "<<<<<<<<<<>>>>>>>>>> post_process_inter = %d, srf_cvs_intf[0] = %d, srf_cvs_intf[1] = %d",
               `post_process_inter, srf_cvs_intf[0], srf_cvs_intf[1]` );

    if (cmpID) { _FREE (cmpID); cmpID = NULL; }
  }

  _pathway_trim   = save_pathway_trim;
  _pathway_orient = save_pathway_orient;

//////////////////////////////     START      VD_avoid_false_interf
  if ( //0 == VDcomment &&
       avoid_false_interf && copy_num && GRidcpy.objid != NULL_OBJID )
  {
    go_sup[0] = GRid_12[0];
    go_sup[1] = GRid_12[1];
    if ( p_ele1 && p_ele2 )
    {
      p_ele1->located_obj = GRid_12[0];
      p_ele2->located_obj = GRid_12[1];
    }
    // Only delete shrunk copy if we are not using shrink_buff1 OR shrink_buff2 ...
    if (use_shrink_buffers == 0 &&
        shrink_buff1 == 0 && shrunk_Set1 == NULL && shrink_buff2 == 0 && shrunk_Set2 == NULL )
    {
      status = om$send(msg      = message GRgraphics.GRdelete(&msg, &mod_env),
                       targetid = GRidcpy.objid,
                       targetos = GRidcpy.osnum,
                       senderid = NULL_OBJID);
      as$status();
    }
  }
//////////////////////////////     END      VD_avoid_false_interf

  retmsg         = msg;
  num_interf_cvs = num_inters;
  num_feet	 = 1; //num_inters; EMintersect_two_element()

  __printf ( "<<<<<<<<<<>>>>>>>>>> num_inters = %d, num_feet = %d, always_make_macro = %d", `num_inters, num_feet, always_make_macro` );

  /*
   * -0- Do NOT create CI_MACRO
   * -1- Only   create CI_MACRO when there actually is an interference
   * -2- Always create CI_MACRO ==>> allows for "auto-interference detection"
   */
  if ( always_make_macro == 2 )
  {
    status =
      om$send (	msg	 = message  ci_macro.set_all_extern_feet
						( (IGRint *)&msg, num_feet, INTF_CVS, &mod_env ),
		senderid = NULL_OBJID,
		targetid = CI_MACRO_ID.objid,
		targetos = CI_MACRO_ID.osnum );
  }
  else if ( always_make_macro == 1 )
  {
    if ( num_inters && num_feet )
    {
      status =
	om$send (	msg	 = message  ci_macro.set_all_extern_feet
						( (IGRint *)&msg, num_feet, INTF_CVS, &mod_env ),
			senderid = NULL_OBJID,
			targetid = CI_MACRO_ID.objid,
			targetos = CI_MACRO_ID.osnum );
    }
    else
    {
      status =
	om$send (	msg	 = message GRgraphics.GRdelete (&msg, &mod_env),
			targetid = CI_MACRO_ID.objid,
			targetos = CI_MACRO_ID.osnum,
			senderid = NULL_OBJID);
      status = 0;
    }
  }
  else if ( always_make_macro == 0 )
  {
    enum GRdpmode	Display_Mode = GRbd;

    out_cvs[0] = INTF_CVS[0];
    status     = 0;

    if ( INTF_CVS[0].objid != NULL_OBJID )
    {
      status =
      om$send(
			msg	 = message GRgraphics.GRdisplay(
							   &msg,
							   &mod_env.md_env.matrix_type,
							    mod_env.md_env.matrix,
							   &Display_Mode,
							   &mod_env.md_id),
			targetid = INTF_CVS[0].objid,
			targetos = INTF_CVS[0].osnum,
			senderid = NULL_OBJID);
    }
  }
  // HF: 10/08/2001	Fix for TR# MP5640 (etl10419)
  if (nbsf1 > MAX_NUM_SRF && p_srf1 && p_srf1 != srf1)
  {
    _FREE(p_srf1); p_srf1 = NULL;
  }

  if (nbsf2 > MAX_NUM_SRF && p_srf2 && p_srf2 != srf2)
  {
    _FREE(p_srf2); p_srf2 = NULL;
  }

  /*
   * If a recompute occurs because one of the templates changes, then we must
   * delete the intersection curves
   */

  if ( recompute && keep_inters == FALSE )
  {
    EMinit(trace, inters, sfintloopsdata, loopdata, TRUE);
  }

  __exitFunction ( name = "VDconstruct_intersection_curves", argfmt = "status = %d", args = status );

  return(status);

wrapup:
  // HF: 10/08/2001	Fix for TR# MP5640 (etl10419)
  if (nbsf1 > MAX_NUM_SRF && p_srf1 && p_srf1 != srf1)
  {
    _FREE(p_srf1); p_srf1 = NULL;
  }

  if (nbsf2 > MAX_NUM_SRF && p_srf2 && p_srf2 != srf2)
  {
    _FREE(p_srf2); p_srf2 = NULL;
  }

  for ( i0=0; i0 < MAX_NUM_SRF; i0++ )
  {
    INTF_CVS[i0].objid = INTF_OBJ[i0] = NULL_OBJID;
    INTF_CVS[i0].osnum = mod_env.md_id.osnum;
  }
  num_feet = 0;

  __exit_error_Function ( name = "VDconstruct_intersection_curves" );

  return (0);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

IGRlong VDrange_box_test
(
  IGRint                   avoid_false_interf,		/* I */
  IGRint                   set1_equals_set2,		/* I */
  IGRint		   NumEle0,			/* I */
  IGRint		   NumEle1,			/* I */
  struct GRlc_info	  *Ele1,			/* I */
  struct GRlc_info	  *Ele2,			/* I */
  FILE                    *fpdb,			/* I */
  struct GRvg_construct   *const_list,                  /* I */
  IGRchar               ***boxint,			/* O Must be _FREE'd by caller */
  IGRlong                 *EMmsg,			/* O */
  IGRint                  *boxcnt			/* O */
)
{
  char			 cl_nm[DI_PATH_MAX];
  int                    i0, j0, k0, idx = 0, rng_fail0 = 0, rng_fail1 = 0;
  IGRboolean		 world = 1;
  IGRlong                sts   = 1, msg, count = 0, boxsct = 0;
  IGRdouble              vctln  [2], scale = 1.0, shr_dst;
  struct GRid		 go_sup [2];
  struct GRmd_env	 sup_env[2];
  GRrange		 range  [2], tot_rng;
  IGRpoint               ctrpt  [2];
  IGRvector              rgvec  [2];
  IGRint		*rfail0 = NULL, *rfail1 = NULL;
  IGRdouble		*vctln0 = NULL, *vctln1 = NULL;
  GRrange		*range0 = NULL, *range1 = NULL;
  IGRpoint		*ctrpt0 = NULL, *ctrpt1 = NULL;
  IGRvector		*rgvec0 = NULL, *rgvec1 = NULL;
  IGRboolean             reduced = 0, coinc_face = 0;
  IGRushort              options = 0;

  if (avoid_false_interf)
  {
    // Scale can be varied between 0.9 - 0.9999 ...
    scale = get_set_intf_shrinkage( shrink_factor );
  }
  __enterFunction ( name = "VDrange_box_test", argfmt = "NumEle0 = %d, NumEle1 = %d, avoid_false_interf = %d, scale = %lg",
                    args = `NumEle0, NumEle1, avoid_false_interf, scale` );

//    // Slightly increase scale, p.e.: .999 ==>> .99925 or .9 ==>> .925
//    if (scale < 1.0)
//    {
//      scale += .25 * (1.0 - scale);
//    }
  // Example: a box with largest dimension of  1000 mm. will shrink 1 mm ==>> scale == var_scl     = .999
  //          a box with largest dimension of   100 mm. will shrink 1 mm ==>> scale = .999 var_scl = .99
  //          a box with largest dimension of 10000 mm. will shrink 1 mm ==>> scale = .999 var_scl = .9999

  shr_dst = (1.0 - scale) * 1000.0;

  // Allocate memory (Must be _FREE'd by caller)...
  (*boxint) = _MALLOC (NumEle0, IGRchar *);
  if ((*boxint) == NULL)
  {
    sts = msg = 0;
    EMerr_hndlr ( sts, msg, EMS_E_NoDynamicMemory, wrapup);
  }
  for (i0=0; i0 < NumEle0; i0++)
  {
    (*boxint)[i0] = _CALLOC (NumEle1, IGRchar );
    if ((*boxint)[i0] == NULL)
    {
      sts = msg = 0;
      EMerr_hndlr ( sts, msg, EMS_E_NoDynamicMemory, wrapup);
    }
  }

  // Temporary allocate memory ...
  rfail0 = _MALLOC (NumEle0, IGRint);
  rfail1 = _MALLOC (NumEle1, IGRint);
  range0 = _CALLOC (NumEle0, GRrange);
  range1 = _CALLOC (NumEle1, GRrange);
  ctrpt0 = _MALLOC (NumEle0, IGRpoint);
  ctrpt1 = _MALLOC (NumEle1, IGRpoint);
  rgvec0 = _MALLOC (NumEle0, IGRvector);
  rgvec1 = _MALLOC (NumEle1, IGRvector);
  vctln0 = _MALLOC (NumEle0, IGRdouble);
  vctln1 = _MALLOC (NumEle1, IGRdouble);

  if (range0 == NULL || range1 == NULL || ctrpt0 == NULL || ctrpt1 == NULL ||
      rgvec0 == NULL || rgvec1 == NULL || vctln0 == NULL || vctln1 == NULL)
  {
    sts = msg = 0;
    EMerr_hndlr ( sts, msg, EMS_E_NoDynamicMemory, wrapup);
  }
  tot_rng[0] = tot_rng[1] = tot_rng[2] =  1.0e10;
  tot_rng[3] = tot_rng[4] = tot_rng[5] = -1.0e10;
  // Collect all range-boxes for Set1 ...
  for (i0=0; i0 < NumEle0; i0++)
  {
    go_sup [0] = Ele1[i0].located_obj;
    sup_env[0] = Ele1[i0].module_info;

    rfail0[i0] = -1;
    reduced    = 0;
    msg        = 0;
    sts = VDreduce_range( &msg, &sup_env[0], &go_sup [0], range0[i0]);

    //if ( ! (sts & msg & 1) || (((i0)%1000) == 0))    // For testing ...
    if ( ! (sts & msg & 1) )
    {
      rfail0[i0] = i0;
      *EMmsg     = msg;
      rng_fail0++;
      continue;
    }

    if (i0 == 0)
    {
      memcpy (tot_rng, range0[i0], 48);
    }
    else
    {
      for (j0=0; j0 < 3; j0++)
      {
        if(tot_rng[j0] > range0[i0][j0]) tot_rng[j0] = range0[i0][j0];
      }
      for (j0=3; j0 < 6; j0++)
      {
        if(tot_rng[j0] < range0[i0][j0]) tot_rng[j0] = range0[i0][j0];
      }
    }
    // Get centerpoint and range vector ...
    for (j0=0; j0 < 3; j0++)
    {
      ctrpt0[i0][j0] = (range0[i0][j0+3] + range0[i0][j0]) * .5;
      rgvec0[i0][j0] =  range0[i0][j0+3] - range0[i0][j0];
    }
    // Get length of range vector...
    vctln0[i0]    = BSlenvec ( &msg, rgvec0[i0] );

    if ( set1_equals_set2 )
    {
      memcpy (range1[i0], range0[i0], 48);
      memcpy (ctrpt1[i0], ctrpt0[i0], 24);
      memcpy (rgvec1[i0], rgvec0[i0], 24);
      vctln1[i0] = vctln0[i0];
      rfail1[i0] = rfail0[i0];
      rng_fail1  = rng_fail0;
    }
  }

  if ( ! set1_equals_set2 )
  {
    // Collect all range-boxes for Set2 ...
    for (i0=0; i0 < NumEle1; i0++)
    {
      go_sup [0] = Ele2[i0].located_obj;
      sup_env[0] = Ele2[i0].module_info;

      rfail1[i0] = -1;
      reduced    = 0;
      msg        = 0;
      sts = VDreduce_range( &msg, &sup_env[0], &go_sup [0], range1[i0]);

      if ( ! (sts & msg & 1))
      {
        rfail1[i0] = i0;
        *EMmsg     = msg;
        rng_fail1++;
        continue;
      }
      for (j0=0; j0 < 3; j0++)
      {
        if(tot_rng[j0] > range1[i0][j0]) tot_rng[j0] = range1[i0][j0];
      }
      for (j0=3; j0 < 6; j0++)
      {
        if(tot_rng[j0] < range1[i0][j0]) tot_rng[j0] = range1[i0][j0];
      }
      // Get centerpoint and range vector ...
      for (j0=0; j0 < 3; j0++)
      {
        ctrpt1[i0][j0] = (range1[i0][j0+3] + range1[i0][j0]) * .5;
        rgvec1[i0][j0] =  range1[i0][j0+3] - range1[i0][j0];
      }
      // Get length of range vector...
      vctln1[i0]    = BSlenvec ( &msg, rgvec1[i0] );
    }
  }

  if ( rng_fail0 || rng_fail1 )
  {
    IGRchar str_array[MS_MAX_MSG_LENGTH];

    __printf ( "set1_equals_set2 = %d, rng_fail0 = %d, rng_fail1 = %d", `set1_equals_set2, rng_fail0, rng_fail1` );

    if ( rng_fail0 )
    {
      // Print to Log-File "Progress_VDS_Intf_" ...
      sprintf(str_array, "  Following %d elements of %d in Set1 will be skipped\n", rng_fail0, NumEle0);
      fprintf(stdout,"%s", str_array);
      if (fpdb)
        fprintf (fpdb, "%s\n", str_array);

      for (i0=0; i0 < NumEle0; i0++)
      {
        if ( rfail0[i0] >= 0 )
        {
          om$get_classname (objid     = Ele1[i0].located_obj.objid,
                            osnum     = Ele1[i0].located_obj.osnum,
                            classname = cl_nm );
          sprintf(str_array, "\tobj[%d] = [%d,%d]\t\t%s\n", i0, Ele1[i0].located_obj.osnum,  Ele1[i0].located_obj.objid, cl_nm);
          fprintf(stdout,"%s", str_array);
          if (fpdb)
            fprintf (fpdb, "%s", str_array);
        }
      }
    }
    if (fpdb)
    {
      fprintf (fpdb, "\n");
      fflush  (fpdb);
    }

    if ( rng_fail1 && set1_equals_set2 == 0 )
    {
      // Print to Log-File "Progress_VDS_Intf_" ...
      sprintf(str_array, "  Following %d elements of %d in Set2 will be skipped\n", rng_fail1, NumEle1);
      fprintf(stdout,"%s", str_array);
      if (fpdb)
        fprintf (fpdb, "%s\n", str_array);

      for (i0=0; i0 < NumEle1; i0++)
      {
        if ( rfail1[i0] >= 0 )
        {
          om$get_classname (objid     = Ele2[i0].located_obj.objid,
                            osnum     = Ele2[i0].located_obj.osnum,
                            classname = cl_nm );
          sprintf(str_array, "\tobj[%d] = [%d,%d]\t\t%s\n", i0, Ele2[i0].located_obj.osnum,  Ele2[i0].located_obj.objid, cl_nm);
          fprintf(stdout,"%s", str_array);
          if (fpdb)
            fprintf (fpdb, "%s", str_array);
        }
      }
    }
    if (fpdb)
    {
      fprintf (fpdb, "\n");
      fflush  (fpdb);
    }
  }
  __printf("Total range = %lf %lf %lf\n                      %lf %lf %lf   dX = %lf dY = %lf dZ = %lf",
           `tot_rng[0],  tot_rng[1], tot_rng[2],  tot_rng[3], tot_rng[4],  tot_rng[5],
            tot_rng[3] - tot_rng[0], tot_rng[4] - tot_rng[1], tot_rng[5] - tot_rng[2]`);

  // Intersect ALL range-boxes and set a flag in boxint[][] if they do ...
  tot_coinc_face = 0;
  for (i0=0; i0 < NumEle0; i0++)
  {
    go_sup [0] = Ele1[i0].located_obj;
    sup_env[0] = Ele1[i0].module_info;

    if ( rfail0[i0] >= 0 )    // Skip invalid range in Set1 ...
    {
      continue;
    }

    for (j0=((set1_equals_set2 == 0) ? 0 : i0+1); j0 < NumEle1; j0++)
    {
      go_sup [1]     = Ele2[j0].located_obj;
      sup_env[1]     = Ele2[j0].module_info;
      (*boxint)[i0][j0] = 0;

      if ( rfail1[j0] >= 0 )    // Skip invalid range in Set2 ...
      {
        continue;
      }

      if ( go_sup[0].objid == go_sup[1].objid && go_sup[0].osnum == go_sup[1].osnum )
      {
        continue;
      }

      memcpy (range[0], range0[i0], 48);
      memcpy (range[1], range1[j0], 48);
      memcpy (ctrpt[0], ctrpt0[i0], 24);
      memcpy (ctrpt[1], ctrpt1[j0], 24);

      // Determine which of the 2 boxes has the smallest range...
      idx = 0;
      if ( vctln0[i0] > vctln1[j0] )
      {
        idx = 1;
      }

      // Just de-activate this function if you do NOT want to scale the smallest range-box...
      if (scale < 1.0)
      {
//          BSscale_pts( 2, range[idx], NULL, scale, ctrpt[idx], &msg);

        // Do NOT use scale, but apply a delta of "shr_dst" mm to the (smallest) range-box...
        // (but make sure that we do NOT shrink more than the actual size of the box...)
        for (k0=0; k0 < 3; k0++)
        {
          double tmp_shr = 0.0;

          tmp_shr = 0.4 * ( range[idx][k0+3] - range[idx][k0] );
          tmp_shr = MIN( shr_dst, tmp_shr );

//            if ( tmp_shr < shr_dst )
//              printf("tmp_shr (%lg) < shr_dst (%lg)\n", tmp_shr, shr_dst);

          range[idx][k0]   += tmp_shr;
          range[idx][k0+3] -= tmp_shr;
        }
      }

      // Count the number of intersecting range-boxes and set a flag in boxint[][] ...
      if ( BSbxint (&msg, &range[0][0], &range[0][3], &range[1][0], &range[1][3]) )
      {
        if (use_range_check)
        {
          // To further improve the whole process, try to find if there are coincident faces...
          coinc_face = VDtest_coinc_faces ( &msg, go_sup, sup_env );
          if ( coinc_face && (msg & 1) )
          {
            tot_coinc_face++;
            continue;    // Found 2 coincident faces; treat this case as non-intersecting and continue...
          }
          else
          {
            (*boxint)[i0][j0] = 1;
            boxsct++;
          }
        }
        else
        {
          (*boxint)[i0][j0] = 1;
          boxsct++;
        }
      }
      count++;
    }
  }
  *boxcnt = boxsct;

wrapup:

  if (rfail0) _FREE (rfail0);
  if (rfail1) _FREE (rfail1);
  if (range0) _FREE (range0);
  if (range1) _FREE (range1);
  if (ctrpt0) _FREE (ctrpt0);
  if (ctrpt1) _FREE (ctrpt1);
  if (rgvec0) _FREE (rgvec0);
  if (rgvec1) _FREE (rgvec1);
  if (vctln0) _FREE (vctln0);
  if (vctln1) _FREE (vctln1);

  if (use_range_check)
  {
    printf("\ntot_coinc_face  = %d\n", tot_coinc_face);
  }

  __exitFunction ( name   = "VDrange_box_test",
                   argfmt = "sts = %d, msg = %d, count = %d, boxsct = %d, tot_coinc_face = %d",
                   args   = `sts, msg, count, boxsct, tot_coinc_face` );

  return(sts);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

static OM_S_OBJECT_LINKAGE      *get_conn_objects
(
  OM_S_OBJECT_LINKAGE    objet,         /* Input        */
  OM_S_CHANSELECT       *my_chansel,    /* Input        */
  short                  opt_all,       /* Input        */
  int                   *count          /* Output       */
)
{
  char                  classname[80];
  OMuword               clid;
  int                   i0, size, sts, sz = 0;
  OMuint                cnt = 0;
  struct        GRid    OBJ_ID;
  OM_S_OBJECT_LINKAGE   *lobj = NULL;

  *count = 0;

  if ( om$is_objid_valid ( osnum = objet.osnum, objid = objet.S_objid ) != OM_S_SUCCESS )
  {
    return NULL;
  }

  om$get_classname (    objid           = objet.S_objid,
                        osnum           = objet.osnum,
                        classname       = classname  );

  om$get_classid   (    classname       = classname,
                        p_classid       = &clid );

  // We don't have to scan further if the object is a solid or a composite surface...
  if ( opt_all == FALSE &&
       (om$is_ancestry_valid (superclassid = OPP_EMSsolid_class_id, subclassid = clid) == OM_S_SUCCESS ||
        om$is_ancestry_valid (superclassid = OPP_EMScompsurf_class_id, subclassid = clid) == OM_S_SUCCESS))
  {
    return NULL;
  }

  OBJ_ID.objid = objet.S_objid;
  OBJ_ID.osnum = objet.osnum;

  /* find the number of objects on the channel */

  sts = om$get_channel_count ( osnum            = objet.osnum,
                               objid            = objet.S_objid,
                               p_chanselect     = my_chansel,
                               count            = &cnt );
  if ( cnt > 0 )
  {
    lobj = _MALLOC ( cnt, OM_S_OBJECT_LINKAGE);

    if ( lobj )
    {
      sts = om$get_channel_objects( osnum        = objet.osnum,
                                    objid        = objet.S_objid,
                                    p_chanselect = my_chansel,
                                    size         = cnt,
                                    list         = lobj,
                                    count        = &cnt );

      *count  = cnt;

      if ( ! sts )
      {
        om$report_error(sts=sts);
        return NULL;
      }
    }
  }

  return ( lobj );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

/*+fe
 -------------------------------------------------------------------------
  Function VDrecursGetGridsFromChan

  Macro Name
	None

  Abstract
	Function to retrieve the number of objects from a channel

  Arguments

	OM_S_OBJECT_LINKAGE  obj	I	Id of the owner object
	OM_S_CHANSELECT	    *my_chansel	I	channel to retrieve onjects from
	short		     classid	I	classid to look for :
						classid > 0 : exact match
						classid = 0 : all objects on channel
						classid < 0 : all subclassed objects
        short                opt_all	I	If 0, do NOT decompose solids/compsurfaces
	int		    *NbFound	O	# objects found on channel

	struct GRid	    *p_FoundId		Global pointer
						List of objects found on channel
						HAS TO BE FREED BY CALLING FUNCTION
						if (NbFound > MAX_NUM_SRF && (p_FoundId != FoundId)) !!!
  Notes/Remarks

  Returns
	OM_S_SUCCESS	= if success
	OM_E_ABORT	= if error
 -------------------------------------------------------------------------
-fe*/

IGRlong VDrecursGetGridsFromChan      /* scans channel for an object, and recurses */
(
  OM_S_OBJECT_LINKAGE     obj,          /* Input  */
  OM_S_CHANSELECT        *my_chansel,   /* Input  */
  short                   classid,      /* Input  */
  short                   opt_all,      /* Input  */
  int                    *NbFound       /* Output */
)
{
  int                  i0, cnt = 0, sz = 0;
  OMuword              clid;

  OM_S_OBJECT_LINKAGE *p_obj = NULL;
  OM_S_OBJECT_LINKAGE *s_obj = NULL;

  p_obj = get_conn_objects ( obj, my_chansel, opt_all, &cnt );

//for (i0=0; i0 < cnt && (*NbFound) < MAX_NUM_SRF; i0++)
  for (i0=0; i0 < cnt; i0++)
  {
    om$get_classid (objid = p_obj[i0].S_objid, osnum = p_obj[i0].osnum, p_classid = &clid);

    if ( classid < 0 )
    {
      if (om$is_ancestry_valid (superclassid = -classid, subclassid = clid) == OM_S_SUCCESS)
      {
        p_FoundId[*NbFound].objid = p_obj[i0].S_objid;
        p_FoundId[*NbFound].osnum = p_obj[i0].osnum;
        (*NbFound)++;
      }
    }
    else if ( classid == 0 )
    {
      p_FoundId[*NbFound].objid = p_obj[i0].S_objid;
      p_FoundId[*NbFound].osnum = p_obj[i0].osnum;
      (*NbFound)++;
    }
    else if ( classid == clid )
    {
      p_FoundId[*NbFound].objid = p_obj[i0].S_objid;
      p_FoundId[*NbFound].osnum = p_obj[i0].osnum;
      (*NbFound)++;
    }
  }

  if ( p_obj )
  {
    s_obj = p_obj;
  }

  while ( cnt-- >= 1)
  {
    if ( ! VDrecursGetGridsFromChan( *p_obj++, my_chansel, classid, opt_all, NbFound ) ) break;
  }

  if ( s_obj )
  {
    _FREE (s_obj);
  }
  return (1);
}

/*+fe
 -------------------------------------------------------------------------
  Function VDrecursCountGridsOnChan

  Macro Name
	None

  Abstract
	Function to retrieve the number of objects from a channel

  Arguments

	OM_S_OBJECT_LINKAGE  obj	I	Id of the owner object
	OM_S_CHANSELECT	    *my_chansel	I	channel to retrieve onjects from
	short		     classid	I	classid to look for :
						classid > 0 : exact match
						classid = 0 : all objects on channel
						classid < 0 : all subclassed objects
        short                opt_all	I	If 0, do NOT decompose solids/compsurfaces
	int		    *NbFound	O	# objects found on channel

  Notes/Remarks

  Returns
	OM_S_SUCCESS	= if success
 -------------------------------------------------------------------------
-fe*/

IGRlong VDrecursCountGridsOnChan      /* scans channel for an object, and recurses */
(
  OM_S_OBJECT_LINKAGE     obj,          /* Input  */
  OM_S_CHANSELECT        *my_chansel,   /* Input  */
  short                   classid,      /* Input  */
  short                   opt_all,      /* Input  */
  int                    *NbFound       /* Output */
)
{
  int                  i0, cnt = 0, sz = 0;
  OMuword              clid;

  OM_S_OBJECT_LINKAGE *p_obj = NULL;
  OM_S_OBJECT_LINKAGE *s_obj = NULL;

  p_obj = get_conn_objects ( obj, my_chansel, opt_all, &cnt );

  for (i0=0; i0 < cnt; i0++)
  {
    om$get_classid (objid = p_obj[i0].S_objid, osnum = p_obj[i0].osnum, p_classid = &clid);

    if ( classid < 0 )
    {
      if (om$is_ancestry_valid (superclassid = -classid, subclassid = clid) == OM_S_SUCCESS)
      {
        (*NbFound)++;
      }
    }
    else if ( classid == 0 )
    {
      (*NbFound)++;
    }
    else if ( classid == clid )
    {
      (*NbFound)++;
    }
  }

  if ( p_obj )
  {
    s_obj = p_obj;
  }

  while ( cnt-- >= 1)
  {
    if ( ! VDrecursCountGridsOnChan( *p_obj++, my_chansel, classid, opt_all, NbFound ) ) break;
  }

  if ( s_obj )
  {
    _FREE (s_obj);
  }
  return (1);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

void VDget_ptr_to_memory( int nm )
{
  __enterFunction ( name = "VDget_ptr_to_memory", argfmt = "nm = %d, FoundId = %#x", args = `nm, FoundId` );

  p_FoundId = FoundId;    // Set static pointer to static array !!!
  if (nm > MAX_NUM_SRF)
  {
    p_FoundId = _MALLOC(nm, struct GRid);
  }
  __exitFunction ( name = "VDget_ptr_to_memory", argfmt = "nm = %d, FoundId = %#x, p_FoundId = %#x", args = `nm, FoundId, p_FoundId` );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

void VDfree_ptr_to_memory()
{
  if (p_FoundId && (p_FoundId != FoundId) )
  {
    _FREE (p_FoundId);
  }
  p_FoundId = FoundId;    // Set static pointer to static array !!!
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*
 * Find all objects of "clid" (p.e. ACmodel) and delete it and its component objects from the RTree.
 * This function is used by PPL: COz_cleanRT
 */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

IGRint VDdelete_class_and_comp_from_rtree(GRclassid clid)
{
  int                  i, j, cnt, sts, nbobj;
  long                 msg;
  short                all_obj, opt_all;
  struct GRobj_env     obj_OE;
  struct GRid         *ptr_id;
  IGRchar              buf[80];
  IGRchar              classname[256];
  OM_S_OBJID          *list;
  OM_S_OBJECT_LINKAGE  ModelId;

  __enterFunction ( name = "VDdelete_class_and_comp_from_rtree", argfmt = "class_id = %d", args = `clid` );

  gr$get_module_env(buffer = &obj_OE.mod_env);
  obj_OE.obj_id.osnum = obj_OE.mod_env.md_id.osnum;

  om$get_classname ( classid   = clid,
                     classname = classname );

  sprintf(buf,"Removing <%s> and to_components from Range Tree...", classname);
  printf ("%s\n", buf);
  UI_status (buf);

  list = NULL;
  sts  = VDpms_find_objects ( obj_OE.mod_env.md_id.osnum, clid, &cnt, list );

  if ( cnt )
  {
    list = _MALLOC ( cnt, OM_S_OBJID );
  }

  if ( list )
  {
    opt_all = 1;    // Decompose solids/compsurfaces

    sts  = VDpms_find_objects( obj_OE.mod_env.md_id.osnum, clid, &cnt, list );

    for( i=0; i < cnt; i=i+1 )
    {
      if (!(i % 100))
      {
        sprintf(buf,"Remove from Range Tree %d of %d...",i,cnt);
        UI_status(buf);
      }

      ModelId.osnum   = obj_OE.mod_env.md_id.osnum;
      ModelId.S_objid = list[i];
      nbobj           = 0;
      all_obj         = 0;
      sts   = VDrecursCountGridsOnChan ( ModelId, &AS_to_comp, all_obj, opt_all, &nbobj );
      __printf ( "  VDrecursCountGridsOnChan() nbobj = %3d, sts = %d, ModelId = [%d,%d]", `nbobj, sts, ModelId.osnum, list[i]` );

      if ( nbobj )
      {
        VDget_ptr_to_memory (nbobj);
        ptr_id = p_FoundId;
        nbobj  = 0;
        sts    = VDrecursGetGridsFromChan ( ModelId, &AS_to_comp, all_obj, opt_all, &nbobj );

        __printf ( "  VDrecursGetGridsFromChan() nbobj = %3d, sts = %d, ptr_id = %#x",` nbobj, sts, ptr_id`);

        if ( sts == 1 && nbobj > 0 && ptr_id )
        {
          for ( j=0; j < nbobj; j=j+1 )
          {
            sts = om$send(msg      = message GRgraphics.GRremwrng( &msg, &obj_OE.mod_env),
                          senderid = NULL_OBJID,
                          targetos = ptr_id[j].osnum,
                          targetid = ptr_id[j].objid);
            __printf ( "    Removed from RTree() ptr_id[%d] = [%d,%d], sts = %d", `j, ptr_id[j].osnum, ptr_id[j].objid, sts` );
          }
        }
        VDfree_ptr_to_memory ();
      }
    }
    if (list) _FREE ( list );
  }

wrapup:

  __exitFunction ( name = "VDdelete_class_and_comp_from_rtree", argfmt = "class_id = %d", args = `clid` );
  return 1;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

IGRlong VDreduce_range
(
  IGRlong         *msg,
  struct GRmd_env *env_info,
  struct GRid     *in_id,
  GRrange          range
)
{
  static char         *superclassnm_1  = {"VRComponent"};
  static char         *superclassnm_2  = {"VRConcComp"};
  OMuword              clid;
  GRobjid              new_id          = NULL_OBJID;
  IGRboolean           world           = 1;
  IGRshort             route_component = 0;
  IGRint               sts             = OM_S_SUCCESS, ii;
  int                  nbsf0           = 0, i0, j0, val0, val1;
  IGRdouble            water_mark      = 0.0;
  GRrange              tot_rng, tmprng, true_rng;
  struct GRlc_info     srf1[MAX_NUM_SRF], *p_srf = NULL;
  struct GRid          save_id;
  OM_S_CHANSELECT      to_comps;
  OM_S_OBJECT_LINKAGE  ModelId;

  __enterFunction ( name   = "VDreduce_range", argfmt = "in_id = [%d,%d], skip_reduce_range = %d",
                    args = `in_id->osnum, in_id->objid, skip_reduce_range` );

  ModelId.osnum   = in_id->osnum;
  ModelId.S_objid = in_id->objid;
  save_id         = *in_id;
  tot_rng[0] = tot_rng[1] = tot_rng[2] =  1.0e10;
  tot_rng[3] = tot_rng[4] = tot_rng[5] = -1.0e10;

  clid = omClassidFromObjid ( save_id.objid , save_id.osnum ) ;

  if ( om$is_ancestry_valid ( subclassid = clid, superclassname = superclassnm_1 ) == OM_S_SUCCESS ||
       om$is_ancestry_valid ( subclassid = clid, superclassname = superclassnm_2 ) == OM_S_SUCCESS  )
  {
    route_component = 1;
  }

  __printf("env_info->matrix_type = %d, env_info->md_id = [%d,%d], route_component = %d",
           `env_info->md_env.matrix_type, env_info->md_id.osnum, env_info->md_id.objid, route_component`);
  for ( i0=0; i0 < 16; i0+=4 )
  {
    __printf("    %lf %lf %lf %lf", `env_info->md_env.matrix[i0+0], env_info->md_env.matrix[i0+1],
             env_info->md_env.matrix[i0+2], env_info->md_env.matrix[i0+3]`);
  }

  // HF: 12/02/2000 TR 4219 (etl4760)
  // When dealing with ROUTE-compoments, do NOT reduce_range, ONLY GRgetrang...
  if ( route_component )
  {
    sts =
    om$send ( msg      = message GRvg.GRgetrang( msg,
                                                 &env_info->md_env.matrix_type,
                                                  env_info->md_env.matrix,
                                                 &world,
                                                  range ),
              senderid = NULL_OBJID,
              targetid = save_id.objid,
              targetos = save_id.osnum );
    as$status(sts = sts);

    goto wrapup;  // Do NOT reduce_range on ROUTE-compoments !!!!!
  }

  if ( omIsAncestryValid ( clid , OPP_EMSsubbs_class_id ))
  {
    /*
     * in_id is a single surface.
     */

    if ( ! skip_reduce_range)
    {
      new_id = NULL_OBJID;
      sts =
      om$send ( msg      = message EMSsubbs.EMreduce_range ( msg,
                                                             env_info,
                                                             &new_id,
                                                             water_mark ),
                senderid = save_id.objid,
                targetid = save_id.objid,
                targetos = save_id.osnum );
      as$status(sts = sts);

      __printf ( "<<<<< EMreduce_range sts = %d, msg = %#x, in_id = [%d,%d], save_id.objid = %d, new_id = %d,",
                 `sts, *msg, in_id->osnum, in_id->objid, save_id.objid, new_id`);

      if ( !( sts & *msg & 1 ) )
      {
        printf ( "EMreduce_range error: sts = %d, msg = %#x, old_id = [%d,%d], new_id = %d\n",
                 sts, *msg, in_id->osnum, in_id->objid, new_id);
        goto wrapup;
      }
      else
      {
        if ( new_id != save_id.objid )
        {
          val0 = om$is_objid_valid ( osnum = save_id.osnum, objid = save_id.objid ) == OM_S_SUCCESS;
          val1 = om$is_objid_valid ( osnum = save_id.osnum, objid = new_id ) == OM_S_SUCCESS;
          if ( ! val0 && ! val1 )
          {
            save_id = *in_id;
          }
          else if ( ! val0 && val1 )
          {
            save_id.objid = new_id;
          }
        }
      }
    }

    sts =
    om$send ( msg      = message GRvg.GRgetrang( msg,
                                                 &env_info->md_env.matrix_type,
                                                  env_info->md_env.matrix,
                                                 &world,
                                                  range ),
              senderid = NULL_OBJID,
              targetid = save_id.objid,
              targetos = save_id.osnum );
    as$status(sts = sts);
    if ( ! (sts & 1 & *msg) ) goto wrapup;

    sts = VDget_true_range( msg, save_id, env_info, true_rng );
    if (sts & 1 & *msg)
    {
      /*
       *etl# 9533 - this memcpy was causing memory problems
       */
      //memcpy (range, true_rng, 48);
      for(ii=0; ii<6; ii++) range[ii] = true_rng[ii];
    }
  }
  else
  {
    short opt_all = 1;    // Decompose solids/compsurfaces
    /*
     * in_id is a composite surface/solid.
     */
    sts = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

    p_FoundId = FoundId;    // Set global pointer to global array !!!
    p_srf     = srf1;

    nbsf0 = 0;
    sts   = VDrecursCountGridsOnChan ( ModelId, &to_comps, -OPP_EMSsubbs_class_id, opt_all, &nbsf0 );
    __printf ( "VDrecursCountGridsOnChan() nbsf0 = %d, sts = %d", `nbsf0, sts` );

    // HF: 10/08/2001	Fix for TR# MP5640 (etl10419)
    if (nbsf0 > MAX_NUM_SRF)
    {
      p_srf = _MALLOC( nbsf0, struct GRlc_info);
      if ( ! p_srf )
      {
        sts = *msg = 0;
        EMerr_hndlr ( sts, *msg, EMS_E_NoDynamicMemory, wrapup);
      }
    }

    if ( nbsf0 )
    {
      VDget_ptr_to_memory (nbsf0);
      nbsf0  = 0;
      sts    = VDrecursGetGridsFromChan ( ModelId, &to_comps, -OPP_EMSsubbs_class_id, opt_all, &nbsf0 );

      for (i0=0; i0 < nbsf0; i0++)
      {
        p_srf[i0].located_obj = p_FoundId[i0];
        p_srf[i0].module_info = *env_info;
        new_id = NULL_OBJID;

        clid = omClassidFromObjid ( p_FoundId[i0].objid , p_FoundId[i0].osnum ) ;

        // Skip solids and / or composite surfaces ...
        if ( omIsAncestryValid ( clid , OPP_EMScompsurf_class_id ))
        {
          continue;
        }

        if ( ! skip_reduce_range)
        {
          sts =
            om$send ( msg          = message EMSsubbs.EMreduce_range ( msg,
                                                                       env_info,
                                                                       &new_id,
                                                                       water_mark ),
//                    p_chanselect = &to_comps,
                      senderid     = NULL_OBJID,
                      targetid     = p_FoundId[i0].objid,
                      targetos     = p_FoundId[i0].osnum);
          as$status(sts = sts);

          __printf ( "<<<<< EMreduce_range sts = %d, msg = %#x, p_FoundId[%d] = [%d,%d], new_id = %d, p_srf[] = %d, md_id = [%d,%d]",
                     `sts, *msg, i0, p_FoundId[i0].osnum, p_FoundId[i0].objid, new_id, p_srf[i0].located_obj.objid,
                     p_srf[i0].module_info.md_id.osnum,  p_srf[i0].module_info.md_id.objid` );

          if ( !( sts & *msg & 1 ) )
          {
            p_FoundId[i0] = p_srf[i0].located_obj;
            printf ( "EMreduce_range error: sts = %d, msg = %#x, old_id = [%d,%d], p_FoundId[%d] = [%d,%d], new_id = %d\n",
                     sts, *msg, in_id->osnum, in_id->objid, i0, p_FoundId[i0].osnum, p_FoundId[i0].objid, new_id);
            goto wrapup;
          }
          else
          {
            if ( new_id != p_FoundId[i0].objid )
            {
              val0 = om$is_objid_valid ( osnum = p_FoundId[i0].osnum, objid = p_FoundId[i0].objid ) == OM_S_SUCCESS;
              val1 = om$is_objid_valid ( osnum = p_FoundId[i0].osnum, objid = new_id ) == OM_S_SUCCESS;
              if ( ! val0 && ! val1 )
              {
                p_FoundId[i0] = p_srf[i0].located_obj;
              }
              else if ( ! val0 && val1 )
              {
                p_FoundId[i0].objid = new_id;
              }
            }
          }
        }

        sts =
        om$send ( msg      = message GRvg.GRgetrang(  msg,
                                                     &env_info->md_env.matrix_type,
                                                      env_info->md_env.matrix,
                                                     &world,
                                                      tmprng ),
                  senderid = NULL_OBJID,
                  targetid = p_FoundId[i0].objid,
                  targetos = p_FoundId[i0].osnum);
        as$status(sts = sts);
        __printf ( "<<<<< GRgetrang      sts = %d, msg = %#x, p_FoundId[%d] = [%d,%d]",`sts, *msg, i0, p_FoundId[i0].osnum, p_FoundId[i0].objid`);

        if ( ! (sts & 1 & *msg) ) goto wrapup;

        sts = VDget_true_range( msg, p_FoundId[i0], env_info, true_rng );
        if (sts & 1 & *msg)
        {
          /*
           * etl# 9533 - this memcpy was causing memory problems ???
           */
          //memcpy (tmprng, true_rng, 48);
          for(ii=0; ii<6; ii++) tmprng[ii] = true_rng[ii];
        }

        if (i0 == 0)
        {
          memcpy (tot_rng, tmprng, 48);
        }
        else
        {
          for (j0=0; j0 < 3; j0++)
          {
            if(tot_rng[j0] > tmprng[j0]) tot_rng[j0] = tmprng[j0];
          }
          for (j0=3; j0 < 6; j0++)
          {
            if(tot_rng[j0] < tmprng[j0]) tot_rng[j0] = tmprng[j0];
          }
        }
      }
      VDfree_ptr_to_memory (nbsf0);
    }
    memcpy (range, tot_rng, 48);

    if (nbsf0 > MAX_NUM_SRF && p_srf)
    {
      _FREE(p_srf); p_srf = NULL;
    }
  }

wrapup:

  __exitFunction ( name   = "VDreduce_range",
                   argfmt = "sts = %d, msg = %#x, in_id = [%d,%d], skip_reduce_range = %d",
                   args   = `sts, *msg, in_id->osnum, in_id->objid, skip_reduce_range` );
  return (sts);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

IGRlong VDget_accumulated_range
(
  IGRlong         *msg,
  struct GRid     *in_id,
  struct GRmd_env *env_info,
  GRrange          range
)
{
  static char         *superclassnm_1  = {"VRComponent"};
  static char         *superclassnm_2  = {"VRConcComp"};
  OMuword              clid;
  GRobjid              new_id          = NULL_OBJID;
  IGRboolean           world           = 1;
  IGRshort             route_component = 0;
  IGRshort             nr_planes = 0, nr_project = 0, skip_planes = 0;
  IGRint               sts             = OM_S_SUCCESS;
  int                  nbsf0           = 0, i0, j0, val0, val1;
  IGRdouble            water_mark      = 0.0;
  GRrange              tot_rng, tmprng, true_rng;
  struct GRlc_info     srf1[MAX_NUM_SRF], *p_srf = NULL;
  struct GRid          save_id;
  OM_S_CHANSELECT      to_comps;
  OM_S_OBJECT_LINKAGE  ModelId;

  __enterFunction ( name   = "VDget_accumulated_range", argfmt = "in_id = [%d,%d]",
                    args = `in_id->osnum, in_id->objid` );

  ModelId.osnum   = in_id->osnum;
  ModelId.S_objid = in_id->objid;
  save_id         = *in_id;
  tot_rng[0] = tot_rng[1] = tot_rng[2] =  1.0e10;
  tot_rng[3] = tot_rng[4] = tot_rng[5] = -1.0e10;

  clid = omClassidFromObjid ( save_id.objid , save_id.osnum ) ;

  if ( om$is_ancestry_valid ( subclassid = clid, superclassname = superclassnm_1 ) == OM_S_SUCCESS ||
       om$is_ancestry_valid ( subclassid = clid, superclassname = superclassnm_2 ) == OM_S_SUCCESS  )
  {
    route_component = 1;
  }

  __printf("env_info->matrix_type = %d, env_info->md_id = [%d,%d], route_component = %d",
           `env_info->md_env.matrix_type, env_info->md_id.osnum, env_info->md_id.objid, route_component`);
  for ( i0=0; i0 < 16; i0+=4 )
  {
    __printf("    %lf %lf %lf %lf", `env_info->md_env.matrix[i0+0], env_info->md_env.matrix[i0+1],
             env_info->md_env.matrix[i0+2], env_info->md_env.matrix[i0+3]`);
  }

  // HF: 12/02/2000 TR 4219 (etl4760)
  // When dealing with ROUTE-compoments, do NOT reduce_range, ONLY GRgetrang...
  if ( route_component )
  {
    sts =
    om$send ( msg      = message GRvg.GRgetrang( msg,
                                                 &env_info->md_env.matrix_type,
                                                  env_info->md_env.matrix,
                                                 &world,
                                                  range ),
              senderid = NULL_OBJID,
              targetid = save_id.objid,
              targetos = save_id.osnum );
    as$status(sts = sts);

    goto wrapup;  // Do NOT reduce_range on ROUTE-compoments !!!!!
  }

  if ( omIsAncestryValid ( clid , OPP_EMSsubbs_class_id ))
  {
    /*
     * in_id is a single surface.
     */

    sts =
    om$send ( msg      = message GRvg.GRgetrang( msg,
                                                 &env_info->md_env.matrix_type,
                                                  env_info->md_env.matrix,
                                                 &world,
                                                  range ),
              senderid = NULL_OBJID,
              targetid = save_id.objid,
              targetos = save_id.osnum );
    as$status(sts = sts);
    if ( ! (sts & 1 & *msg) ) goto wrapup;

    sts = VDget_true_range( msg, save_id, env_info, true_rng );
    if (sts & 1 & *msg)
    {
      memcpy (range, true_rng, 48);
    }
  }
  else
  {
    short opt_all   = 1;    // Decompose solids/compsurfaces
    /*
     * in_id is a composite surface/solid.
     */
    sts = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

    p_FoundId = FoundId;    // Set global pointer to global array !!!
    p_srf     = srf1;

    nbsf0 = 0;
    sts   = VDrecursCountGridsOnChan ( ModelId, &to_comps, -OPP_EMSsubbs_class_id, opt_all, &nbsf0 );
    __printf ( "VDrecursCountGridsOnChan() nbsf0 = %d, sts = %d", `nbsf0, sts` );

    // HF: 10/08/2001	Fix for TR# MP5640 (etl10419)
    if (nbsf0 > MAX_NUM_SRF)
    {
      p_srf = _MALLOC( nbsf0, struct GRlc_info);
      if ( ! p_srf )
      {
        sts = *msg = 0;
        EMerr_hndlr ( sts, *msg, EMS_E_NoDynamicMemory, wrapup);
      }
    }

    if ( nbsf0 )
    {
      VDget_ptr_to_memory (nbsf0);
      nbsf0  = 0;
      sts    = VDrecursGetGridsFromChan ( ModelId, &to_comps, -OPP_EMSsubbs_class_id, opt_all, &nbsf0 );

      nr_planes = nr_project = skip_planes = 0;

      for (i0=0; i0 < nbsf0; i0++)
      {
        clid = omClassidFromObjid ( p_FoundId[i0].objid , p_FoundId[i0].osnum ) ;

        if ( clid == OPP_EMSplane_class_id )
        {
          nr_planes++;
        }
        if ( clid == OPP_EMSproject_class_id )
        {
          nr_project++;
        }
      }
      if ( nr_planes && nr_project && (nr_planes + nr_project) == nbsf0 )
      {
        skip_planes = TRUE;
      }

      for (i0=0; i0 < nbsf0; i0++)
      {
        p_srf[i0].located_obj = p_FoundId[i0];
        p_srf[i0].module_info = *env_info;
        new_id = NULL_OBJID;

        clid = omClassidFromObjid ( p_FoundId[i0].objid , p_FoundId[i0].osnum ) ;

        if ( skip_planes && clid == OPP_EMSplane_class_id )
        {
          continue;
        }

        // Skip solids and / or composite surfaces ...
//          if ( omIsAncestryValid ( clid , OPP_EMScompsurf_class_id ))
//          {
//            continue;
//          }

        sts =
        om$send ( msg      = message GRvg.GRgetrang(  msg,
                                                     &env_info->md_env.matrix_type,
                                                      env_info->md_env.matrix,
                                                     &world,
                                                      tmprng ),
                  senderid = NULL_OBJID,
                  targetid = p_FoundId[i0].objid,
                  targetos = p_FoundId[i0].osnum);
        as$status(sts = sts);
        __printf ( "<<<<< GRgetrang      sts = %d, msg = %#x, p_FoundId[%d] = [%d,%d]",`sts, *msg, i0, p_FoundId[i0].osnum, p_FoundId[i0].objid`);

        if ( ! (sts & 1 & *msg) ) goto wrapup;

        sts = VDget_true_range( msg, p_FoundId[i0], env_info, true_rng );
        if (sts & 1 & *msg)
        {
          memcpy (tmprng, true_rng, 48);
        }

        if (i0 == 0)
        {
          memcpy (tot_rng, tmprng, 48);
        }
        else
        {
          for (j0=0; j0 < 3; j0++)
          {
            if(tot_rng[j0] > tmprng[j0]) tot_rng[j0] = tmprng[j0];
          }
          for (j0=3; j0 < 6; j0++)
          {
            if(tot_rng[j0] < tmprng[j0]) tot_rng[j0] = tmprng[j0];
          }
        }
      }
      VDfree_ptr_to_memory (nbsf0);
    }
    memcpy (range, tot_rng, 48);

    if (nbsf0 > MAX_NUM_SRF && p_srf)
    {
      _FREE(p_srf); p_srf = NULL;
    }
  }

wrapup:

  __exitFunction ( name   = "VDget_accumulated_range",
                   argfmt = "sts = %d, msg = %#x, in_id = [%d,%d], skip_planes = %d, nbsf0 = %d, nr_planes = %d, nr_project = %d",
                   args   = `sts, *msg, in_id->osnum, in_id->objid, skip_planes, nbsf0, nr_planes, nr_project` );
  return (sts);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

static IGRlong VDaccumulated_ranges
(
  IGRlong		*msg,
  struct GRid		*GRid_12,
  struct GRmd_env	*mdenv12,
  GRrange		*accu_rng
)
{
  IGRlong              sts = OM_S_SUCCESS;
  int                  i0;

  for (i0=0; i0 < 2; i0++)
  {
    sts = VDget_accumulated_range( msg, &GRid_12 [i0], &mdenv12[i0], accu_rng[i0]);
  }

  return (sts);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

IGRlong VDfind_coinc_faces
(
  IGRlong         *msg,
  struct GRid     *in_id,
  struct GRmd_env *env_info,
  GRrange        **range,
  IGRdouble       *ctpt,
  IGRint          *nm_rng
)
{
  static char         *superclassnm_1  = {"VRComponent"};
  static char         *superclassnm_2  = {"VRConcComp"};
  OMuword              clid;
  IGRboolean           world           = 1;
  IGRshort             route_component = 0;
  IGRint               sts             = OM_S_SUCCESS;
  int                  nbsf0           = 0, i0, j0;
  struct GRlc_info     srf1[MAX_NUM_SRF], *p_srf = NULL;
  struct GRid          save_id;
  GRrange              loc_rng, true_rng;
  OM_S_CHANSELECT      to_comps;
  OM_S_OBJECT_LINKAGE  ModelId;

  __enterFunction ( name   = "VDfind_coinc_faces", argfmt = "in_id = [%d,%d]",
                    args = `in_id->osnum, in_id->objid` );

  ModelId.osnum   = in_id->osnum;
  ModelId.S_objid = in_id->objid;
  save_id         = *in_id;
  *nm_rng         = 0;

  clid = omClassidFromObjid ( save_id.objid , save_id.osnum ) ;

  if ( om$is_ancestry_valid ( subclassid = clid, superclassname = superclassnm_1 ) == OM_S_SUCCESS ||
       om$is_ancestry_valid ( subclassid = clid, superclassname = superclassnm_2 ) == OM_S_SUCCESS  )
  {
    route_component = 1;
  }

  __printf("env_info->matrix_type = %d, env_info->md_id = [%d,%d], route_component = %d",
           `env_info->md_env.matrix_type, env_info->md_id.osnum, env_info->md_id.objid, route_component`);
  for ( i0=0; i0 < 16; i0+=4 )
  {
    __printf("    %lf %lf %lf %lf", `env_info->md_env.matrix[i0+0], env_info->md_env.matrix[i0+1],
             env_info->md_env.matrix[i0+2], env_info->md_env.matrix[i0+3]`);
  }

  sts =
    om$send ( msg      = message GRvg.GRgetrang( msg,
                                                 &env_info->md_env.matrix_type,
                                                 env_info->md_env.matrix,
                                                 &world,
                                                 loc_rng ),
              senderid = NULL_OBJID,
              targetid = save_id.objid,
              targetos = save_id.osnum );
  as$status(sts = sts);
  if ( ! (sts & 1 & *msg) ) goto wrapup;

  ctpt[0] = ( loc_rng[0] + loc_rng[3] ) / 2;
  ctpt[1] = ( loc_rng[1] + loc_rng[4] ) / 2;
  ctpt[2] = ( loc_rng[2] + loc_rng[5] ) / 2;

  if ( route_component )
  {
    *range = _CALLOC (1, GRrange);

    sts =
    om$send ( msg      = message GRvg.GRgetrang( msg,
                                                 &env_info->md_env.matrix_type,
                                                  env_info->md_env.matrix,
                                                 &world,
                                                 (*range)[0] ),
              senderid = NULL_OBJID,
              targetid = save_id.objid,
              targetos = save_id.osnum );
    as$status(sts = sts);
    if ( ! (sts & 1 & *msg) ) goto wrapup;

    ctpt[0] = ( (*range)[0][0] + (*range)[0][3] ) / 2;
    ctpt[1] = ( (*range)[0][1] + (*range)[0][4] ) / 2;
    ctpt[2] = ( (*range)[0][2] + (*range)[0][5] ) / 2;
    *nm_rng = 1;
    goto wrapup;  // Do NOT decompose ROUTE-compoments !!!!!
  }

  if ( omIsAncestryValid ( clid , OPP_EMSsubbs_class_id ))
  {
    /*
     * in_id is a single surface.
     */
    *range = _CALLOC (1, GRrange);

    sts =
    om$send ( msg      = message GRvg.GRgetrang( msg,
                                                 &env_info->md_env.matrix_type,
                                                  env_info->md_env.matrix,
                                                 &world,
                                                 (*range)[0] ),
              senderid = NULL_OBJID,
              targetid = save_id.objid,
              targetos = save_id.osnum );
    as$status(sts = sts);
    if ( ! (sts & 1 & *msg) ) goto wrapup;

    sts = VDget_true_range( msg, save_id, env_info, true_rng );
    if (sts & 1 & *msg)
    {
      memcpy ((*range)[0], true_rng, 48);
    }

    *nm_rng = 1;
    goto wrapup;
  }
  else
  {
    short opt_all   = 1;    // Decompose solids/compsurfaces
    /*
     * in_id is a composite surface/solid.
     */
    sts = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

    p_FoundId = FoundId;    // Set global pointer to global array !!!
    p_srf     = srf1;

    nbsf0 = 0;
    sts   = VDrecursCountGridsOnChan ( ModelId, &to_comps, -OPP_EMSsubbs_class_id, opt_all, &nbsf0 );
    __printf ( "VDrecursCountGridsOnChan() nbsf0 = %d, sts = %d", `nbsf0, sts` );

    // HF: 10/08/2001	Fix for TR# MP5640 (etl10419)
    if (nbsf0 > MAX_NUM_SRF)
    {
      p_srf = _MALLOC( nbsf0, struct GRlc_info);
      if ( ! p_srf )
      {
        sts = *msg = 0;
        EMerr_hndlr ( sts, *msg, EMS_E_NoDynamicMemory, wrapup);
      }
    }

    if ( nbsf0 )
    {
      VDget_ptr_to_memory (nbsf0);
      nbsf0  = 0;
      sts    = VDrecursGetGridsFromChan ( ModelId, &to_comps, -OPP_EMSsubbs_class_id, opt_all, &nbsf0 );

      *range = _CALLOC (nbsf0, GRrange);

      for (i0=0; i0 < nbsf0; i0++)
      {
        p_srf[i0].located_obj = p_FoundId[i0];
        p_srf[i0].module_info = *env_info;

        sts =
        om$send ( msg      = message GRvg.GRgetrang(  msg,
                                                     &env_info->md_env.matrix_type,
                                                      env_info->md_env.matrix,
                                                     &world,
                                                     (*range)[*nm_rng] ),
                  senderid = NULL_OBJID,
                  targetid = p_FoundId[i0].objid,
                  targetos = p_FoundId[i0].osnum);
        as$status(sts = sts);
        __printf ( "<<<<< GRgetrang      sts = %d, msg = %#x, p_FoundId[%d] = [%d,%d]",
                   `sts, *msg, i0, p_FoundId[i0].osnum, p_FoundId[i0].objid`);

        __printf("(*range)[%2d] = %#x, (*range)[] = %lf, %lf, %lf        %lf, %lf, %lf",
                 `i0, (*range)[i0], (*range)[i0][0], (*range)[i0][1], (*range)[i0][2], (*range)[i0][3], (*range)[i0][4], (*range)[i0][5]`);

        if ( ! (sts & 1 & *msg) ) goto wrapup;

        sts = VDget_true_range( msg, p_FoundId[i0], env_info, true_rng );
        if (sts & 1 & *msg)
        {
          memcpy ((*range)[*nm_rng], true_rng, 48);
        }

        (*nm_rng)++;
      }
      VDfree_ptr_to_memory (nbsf0);
    }

    if (nbsf0 > MAX_NUM_SRF && p_srf)
    {
      _FREE(p_srf); p_srf = NULL;
    }
  }

wrapup:

  __exitFunction ( name   = "VDfind_coinc_faces",
                   argfmt = "sts = %d, msg = %#x, in_id = [%d,%d],  nbsf0 = %d",
                   args   = `sts, *msg, in_id->osnum, in_id->objid, nbsf0` );
  return (sts);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

static IGRboolean VDtest_coinc_faces
(
  IGRlong		*msg,
  struct GRid		*GRid_12,
  struct GRmd_env	*mdenv12
)
{
  IGRboolean           coinc_face = 0, int_sect = 0;
  IGRlong              sts        = OM_S_SUCCESS, rc;
  IGRint               i0, j0, num_coinc = 0, nm_rng[2] = {0};
  IGRpoint             ptmin, ptmax, totmax, totmin;
  IGRdouble            dx = 0.0, dy = 0.0, dz = 0.0, dlx = 0.0, dly = 0.0, dlz = 0.0, cht_tol;
  IGRdouble            dotp = 0.0, ctpt1[3] = {0}, ctpt2[3] = {0}, ctpt3[3] = {0};
  IGRvector            vec1 = {0}, vec2 = {0};
  GRrange             *rng_bx1 = NULL, *rng_bx2 = NULL;

  BSEXTRACTPAR( &sts, BSTOLCHRDHT, cht_tol);

  __enterFunction ( name   = "VDtest_coinc_faces", argfmt = "GRid_12[0] = [%d,%d], GRid_12[1] = [%d,%d], cht_tol = %lg",
                    args = `GRid_12[0].osnum, GRid_12[0].objid, GRid_12[1].osnum, GRid_12[1].objid, cht_tol` );

  for (i0=0; i0 < 2; i0++)
  {
    if (i0 == 0)
    {
      sts = VDfind_coinc_faces( msg, &GRid_12 [i0], &mdenv12[i0], &rng_bx1, ctpt1, &nm_rng[i0] );
    }
    else
    {
      sts = VDfind_coinc_faces( msg, &GRid_12 [i0], &mdenv12[i0], &rng_bx2, ctpt2, &nm_rng[i0] );
    }
    if ( ! (sts & 1 & *msg) ) goto wrapup;
  }

  // Now loop over all separate range-boxes from GRid_12[0] against all range-boxes from GRid_12[1]
  // and determine the overlap.
  // If ONLY one dimension of the overlap (dx, dy or dz) is less than cht_tol, then we have a coincident face...
  for (i0=0; i0 < nm_rng[0]; i0++)
  {
    for (j0=0; j0 < nm_rng[1]; j0++)
    {
      // This function returns the (minimum) overlap range-box when two boxes intersect...
      BSrgbxint( &rng_bx1[i0][0], &rng_bx1[i0][3], &rng_bx2[j0][0], &rng_bx2[j0][3], &int_sect, ptmin, ptmax, msg);

//        if (int_sect)
//          printf("i0 = %2d, j0 = %2d, int_sect = %d\n", i0, j0, int_sect);

      if (BSERROR(*msg))
        goto wrapup;
      else
        *msg = OM_S_SUCCESS;
      if (int_sect)
      {
        dx = ptmax[0] - ptmin[0];
        dy = ptmax[1] - ptmin[1];
        dz = ptmax[2] - ptmin[2];

        // Check if only ONE of the orthogonal delta's == 0 ... ( < cht_tol )
        if ( dx < cht_tol && (dy > cht_tol && dz > cht_tol) ||
             dy < cht_tol && (dx > cht_tol && dz > cht_tol) ||
             dz < cht_tol && (dx > cht_tol && dy > cht_tol) )
        {
          int  k0;
          for (k0=0; k0 < 3; k0++)
          {
            totmin[k0] = MIN(rng_bx1[i0][k0],  rng_bx2[j0][k0]);
            totmax[k0] = MAX(rng_bx1[i0][k0+3],rng_bx2[j0][k0+3]);

            dlx = totmax[0] - totmin[0];
            dly = totmax[1] - totmin[1];
            dlz = totmax[2] - totmin[2];
          }

          // Only accept as a coincident face if the volume of the accumulated range-box of the 2 surfaces == 0    AND
          // the overlap range-box of the 2 surfaces is identical to ONE of the 2 separate range-boxes...
          //
          // I know that, when we do this, we exclude partial overlaps, which could be a case of FALSE interference, but alas...
          if ( (dlx * dly * dlz) == 0.0 &&
               ((ptmin[0] == rng_bx1[i0][0] && ptmin[1] == rng_bx1[i0][1] && ptmin[2] == rng_bx1[i0][2]  &&
                 ptmax[0] == rng_bx1[i0][3] && ptmax[1] == rng_bx1[i0][4] && ptmax[2] == rng_bx1[i0][5]) ||
                (ptmin[0] == rng_bx2[j0][0] && ptmin[1] == rng_bx2[j0][1] && ptmin[2] == rng_bx2[j0][2]  &&
                 ptmax[0] == rng_bx2[j0][3] && ptmax[1] == rng_bx2[j0][4] && ptmax[2] == rng_bx2[j0][5])))
          {
//              printf("i0 = %2d, j0 = %2d, int_sect = %d, dx = %10.5lf, dy = %10.5lf, dz = %10.5lf, dlx = %10.5lf, dly = %10.5lf, dlz = %10.5lf\n",
//                     i0, j0, int_sect, dx, dy, dz, dlx, dly, dlz);
//              printf("rng_bx1[%d] = %10.5lf, %10.5lf, %10.5lf        %10.5lf, %10.5lf, %10.5lf\n",
//                     i0, rng_bx1[i0][0], rng_bx1[i0][1], rng_bx1[i0][2], rng_bx1[i0][3], rng_bx1[i0][4], rng_bx1[i0][5]);
//              printf("rng_bx2[%d] = %10.5lf, %10.5lf, %10.5lf        %10.5lf, %10.5lf, %10.5lf\n",
//                     j0, rng_bx2[j0][0], rng_bx2[j0][1], rng_bx2[j0][2], rng_bx2[j0][3], rng_bx2[j0][4], rng_bx2[j0][5]);

            __printf("i0 = %2d, j0 = %2d, int_sect = %d, dx = %10.5lf, dy = %10.5lf, dz = %10.5lf, dlx = %10.5lf, dly = %10.5lf, dlz = %10.5lf",
                   `i0, j0, int_sect, dx, dy, dz, dlx, dly, dlz`);

            __printf("rng_bx1[%d] = %10.5lf, %10.5lf, %10.5lf        %10.5lf, %10.5lf, %10.5lf",
                 `i0, rng_bx1[i0][0], rng_bx1[i0][1], rng_bx1[i0][2], rng_bx1[i0][3], rng_bx1[i0][4], rng_bx1[i0][5]`);

            __printf("rng_bx2[%d] = %10.5lf, %10.5lf, %10.5lf        %10.5lf, %10.5lf, %10.5lf",
                 `j0, rng_bx2[j0][0], rng_bx2[j0][1], rng_bx2[j0][2], rng_bx2[j0][3], rng_bx2[j0][4], rng_bx2[j0][5]`);

            // One more test to prevent mistakenly missing a REAL intersection...?!?!?
            if ( FALSE /* TRUE */ )
            {
              ctpt3[0] = ( ptmin[0] + ptmax[0] ) / 2;
              ctpt3[1] = ( ptmin[1] + ptmax[1] ) / 2;
              ctpt3[2] = ( ptmin[2] + ptmax[2] ) / 2;

              for (k0=0; k0 < 3; k0++)
              {
                vec1[k0] = ctpt1[k0] - ctpt3[k0];
                vec2[k0] = ctpt2[k0] - ctpt3[k0];
              }
              (void) BSnorvec (&rc, vec1);
              if (BSERROR(rc))
                continue;
              (void) BSnorvec (&rc, vec2);
              if (BSERROR(rc))
                continue;

              dotp = BSdotp(&rc, vec1, vec2);
              if(BSERROR(rc))
                continue;

              __printf("vec1 = %10.8lf %10.8lf %10.8lf  vec2 = %10.8lf %10.8lf %10.8lf  dotp = %10.8lf",
                       `vec1[0], vec1[1], vec1[2], vec2[0], vec2[1], vec2[2], dotp`);
              if( dotp > 0.0 )
                continue;
            }
            num_coinc++;
          }
        }
      }
    }
  }

wrapup:

//    printf("\ncoinc_face = %d\n", coinc_face);

  if (rng_bx1) _FREE (rng_bx1);
  if (rng_bx2) _FREE (rng_bx2);

  coinc_face = ((num_coinc == 1) ? TRUE : FALSE);

  __exitFunction ( name   = "VDtest_coinc_faces", argfmt = "sts = %d, *msg = %d, num_coinc = %d, coinc_face = %d",
                    args = `sts, *msg, num_coinc, coinc_face` );

  return (coinc_face);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

IGRlong VDget_true_range
(
  IGRlong         *msg,
  struct GRid      in_id,
  struct GRmd_env *md_env,
  GRrange          true_rng
)
{
  OMuword                 clid;
  IGRushort               new_params_type = EMfreeform_surface;
  IGRlong                 sts = OM_S_SUCCESS, size = 0, dumdum = 0;
  struct IGRbsp_surface  *srf = NULL;
  struct EMsurface_params new_params;

  *msg = MSSUCC;
  true_rng[0] = true_rng[1] = true_rng[2] = true_rng[3] = true_rng[4] = true_rng[5] = 0.0;

  __enterFunction ( name   = "VDget_true_range", argfmt = "in_id[0] = [%d,%d]",
                    args = `in_id.osnum, in_id.objid` );

  clid = omClassidFromObjid ( in_id.objid , in_id.osnum ) ;

  if ( ! omIsAncestryValid ( clid , OPP_EMSsubbs_class_id ))
  {
    sts = 0;
    goto wrapup;
  }
  new_params.params.project.curve.knots   = NULL;
  new_params.params.project.curve.poles   = NULL;
  new_params.params.project.curve.weights = NULL;
  new_params.params.revolve.curve.knots   = NULL;
  new_params.params.revolve.curve.poles   = NULL;
  new_params.params.revolve.curve.weights = NULL;

  sts = om$send ( msg = message GRvg.GRgenabsg ( msg,
                                                &md_env->md_env.matrix_type,
                                                 md_env->md_env.matrix,
                                                 ( char ** ) &srf ),
                  senderid = NULL_OBJID,
                  targetid = in_id.objid,
                  targetos = in_id.osnum );
  EMerr_hndlr(!(1&*msg), *msg, EMS_E_SurfaceError, wrapup);

  sts = om$send(msg = message EMSsurface.EMget_params( msg,
                                                       srf,
                                                       md_env,
                                                       &new_params_type,
                                                       &new_params),
                senderid = NULL_OBJID,
                targetid = in_id.objid,
                targetos = in_id.osnum);
  EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_BSerror, wrapup);

  memcpy (true_rng, new_params.range, sizeof(GRrange));

wrapup:

  if (srf) GRabsg_del(srf);

  if(new_params_type == EMproject)
  {
    if(new_params.params.project.curve.knots)
      om$dealloc(ptr = new_params.params.project.curve.knots);
    if(new_params.params.project.curve.poles)
      om$dealloc(ptr = new_params.params.project.curve.poles);
    if(new_params.params.project.curve.weights)
      om$dealloc(ptr = new_params.params.project.curve.weights);
  }
  else if(new_params_type == EMrevol)
  {
    if(new_params.params.revolve.curve.knots)
      om$dealloc(ptr = new_params.params.revolve.curve.knots);
    if(new_params.params.revolve.curve.poles)
      om$dealloc(ptr = new_params.params.revolve.curve.poles);
    if(new_params.params.revolve.curve.weights)
      om$dealloc(ptr = new_params.params.revolve.curve.weights);
  }

  __exitFunction ( name   = "VDget_true_range", argfmt = "sts = %d, *msg = %d",
                    args = `sts, *msg` );

  return (sts);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation EMSsurface;
