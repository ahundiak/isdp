/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION
   This function was previously named 'EMget_loops_for_imposition'.
   After the change in the argument list (to make it better), I renamed
   it to 'EMget_mapped_data'.
   The changes during the metamorphosis were -

   1) Got rid of the arg 'sender_obj'.
   2) Made par_tol_basis input by reference instead of value. So if NULL, the
      function will obtain it.
   3) defined structure for output. The structure contains number of objects
      and objids as its fields. The old args 'num_out_loops' and 'out_loops'
      were bunched into single arg 'out_loops'. Similarly for 'out_curves'.
   4) Bunched the four old args 'in_edge_types', 'in_curve_info', 'out_edges'
      and 'num_out_edges' into one structure.

   All the new structures can be found in include/emsmapdef.h

   The main reason (among other things) for the above action was to reduce
   the number of arguments for this function. A case in point - in the old 
   function if one was not interested in planar info (like sending in edge 
   types and curve info and getting back edges), one had to specify 4 NULLs 
   on the arg list. This is now possible with a single NULL.

   -- SM	27-Mar-1989.

   This function accepts a list of model-space curve-objects ^ curve buffers 
   and maps them onto the given surface. The output is a corresponding list
   of parametric space loop objects or model space curves mapped onto the
   surface along the surface normals.
   This function ensures, unless opted otherwise, that:

   1) No jump occurs in parametric space when there is not a corresponding
      jump in model space.
   2) The parametric linestrings do not intersect themselves.
   3) The parametric linestrings do not intersect with any other
      parametric linestrings in the same space.
   4) The parametric linestrings do not have edges which lie
      along the natural surface boundaries.  In doing this it
      also moves points which are very near natural edges to the
      natural edge.

   RETURN VALUES

   EMmsg                EMS_S_Success if sucess
                        EMS_E_DynamicMemoryAllocated if no memory
                        EMS_E_Fail if severe problems (best to
                        abort), note that this most likely
                        implies coding, algorithm, or math
                        problems

NOTES
   If the incoming surface is an order 2 plane with equal and parallel sides
   then the boundaries with order > 2 are mapped as bspline curves and
   bs edges are created instead of stroking the curve out and constructing
   linear edges. 
   If the input curves contain a composite then each component of the
   composite is handled individually. Thus an edge will be formed for each
   component of the composite if loops are desired. If model space curves
   are desired, a composite will result after mapping.

Arguments

   number_of_objects      input  Number of curve objects you have 
   input_curves           input  curve buffers. 
   object_information     input  Locate information per curve object.
				 The curve objects can be in any object space.
			         Required to get curve geometries if input
			         is curve objects instead of curve buffers.
   const_list             input  construct list for model space curves. If
                                 curves not desired, can be NULL.
   surface                input  The surface for imposition 
   par_tol_basis          input  par_tol for this surface. If NULL, 
				 it is computed by the function.
   env                    input  mod env of the surface (can be
                                 different from curves)
   bad_curves	   	  output Info about the bad curves encountered (curves
				 not within tol from the surface). The
				 structure is defined in include/emsmapdef.h
				 not interested ? NULL : non NULL. If 
				 bad_curves.bad_indices is NULL, memory is
				 allocated by the function, else enough memory
				 is assumed.
   bad_points		  output Xyz points corresponding to ends of dangling 
				 parametric data
				 not interested ? NULL : non NULL.
				 Memory for the 3D points is ALWAYS allocated 
				 by the function.
   out_loops              output The parametric loops resulting from the
                                 input parametric curves. Can be NULL if
                                 not interested. If out_loops.objs is non NULL
				 enough memory is assumed, else memory
				 is allocated by the function, 
   out_curves	          output Curves mapped along surface normals. Rest as 
				 above.
   clip_ls                input  Clipping loopset. If clip_ls.objid is 
				 NULL_OBJID then a natural loopset will be used
				 for clipping. Relevant only if clipping
				 is not suppressed via the options.
   options                input  See file /ems/include/emsmapdef.h
   planar_info		  input	 optional information for curves being mapped
				 onto planar surfaces. It consists of the
				 following 4 fields -
				
                                 edge types- Ignored if comp curve is input.
				 All edges produced from a curve will have the 
                                 corresponding edge type set. If no edge
				 types, set the pointer value to NULL.
				
				 curve_info - is an input array of pointers
				 per curve. The pointer for a curve is returned
				 back as 'more_info' with edges produced
				 from that curve. Relevant only for planes.
				
   				 out_edges - edges created are returned via
				 structure 'EMgetlp_edgeinfo'.
                                 Each pointer in the array points to begining 
				 of the array containing edges for a loop. 
				 
   				 num_out_edges array of num edges in each loop

   EMmsg                  output Error return code 

HISTORY
        SM      09-Oct-87       Rewrote the original function to handle 
                                combinations of bs and linear edges. Also
                                handles composite curves.
        SM      28-Oct-87       added arguments so that for planar cases
                                the caller can pass in some info about each
                                curve in form of a character pointer. Upon
                                output each edge produced will be output
                                in a data strcture 'EMgetlp_edgeinfo' which
                                carries the edgeid and the value of the pointer
                                for the corresponding curve from which
                                the edge was produced.
        SM      02-Nov-87       Modified so that any edges which
                                need to be reversed are marked as reversed
                                instead of actually reversing their
                                geometry. For model space curves however, the
                                actual geometry will be reversed.
        RC       15-july-88      Added EMMapBnd_NoRmvColEds option. If this
                                option is on and fixing is requested, the
                                portions of the mapped boundaries, lying
                                on the natural boundary of the surface,
                                will not be removed.
	SM	28-Jul-88	Fixed a bug regarding returning of bad curve
				indices. If more than one components of
				a composite are bad, the composite curve
				index is returned only once. 
	SM	06-Dec-88	use sub_group_closed flags for validity check
				and loop closure property instead of distance
				checks. Also if clip_ls is non natural, then
				ends of open boundaries are checked to lie
				on its edges (criteria for validity) using
				point location.
	SM	20-Feb-89	Use trace info for uv closure of edges.
	SM	22-Sep-89	Changed the way I was freeing memory occupied
				by the mapped data. Now when the pointer
				is given to EFfix_the_int for example, the
				corresponding pointer returned by
				EFmap.. is set to NULL. All pointers are
				used for freeing at the end. Earlier
				checks based on the input options were used
				to determine which pointer is to be used
				for freeing. I came across a case where after
				an error from EFfix_the_int to memory was
				being freed before erroring out.
	SM	06-Oct-89	Added call to EFpts_degenerate() to check
				if an edge is degenerate in model space and
				if so set its property accordingly.
	SM	27-Dec-89	Pass cht*cht instead of trace_tol * trace_tol
				to EMvalidate_points() function.
	SM	08-Nov-90	Pass FALSE for 'positioned' flag to 
                                EMmakeintlist since only then will this 
                                fuction intilize the more_info field in the 
                                inters list with the surface geometry.
        NP  	02-Feb-92    	Changed the call "EFfix_the_intersections" to
                                "EFfix_the_int". The name of the function was
                                changed because an argument was added.
        AMD     02-Feb-92       Fixed an uninitialized variable in
                                EMvalidate_points.
        NP      05/27/93        Funtction "EMmkintlist" is now called by a new
                                name, "EMmakeintlist", due to addition of two 
                                new curve type parameters.
                                NOTE: TRY AND SET CURVE TYPES MEANINGFULLY IN 
                                      THE CALL (CURRENTLY SET TO NULL).
        SCW     06/21/93        Initialized the props field of the trace_list
                                structure.
        Sudha   07/09/93        Modified for BSprototypes anisfication

*/

class implementation GRvg;

#include "EMS.h"

#ifndef DEBUG
#define	DEBUG	0
#endif

#if DEBUG
#include <stdio.h>
#endif

#include "emsdattyp.h"                  /* enum EMSdata_ etc. */
#include "emsinter.h"                   /* struct defintions for int. */
#include "EMSmsgdef.h"                  /* EMS return codes */
#include "EMSbnddef.h"                  /* EMS_O_Planar etc. */
#include "msdef.h"
#include "madef.h"
#include "bserr.h"                      /* BSERROR */
#include "bsparameters.h"               /* BSEXTRACTPAR macro */
#include "OMmacros.h"                   /* OM_BLOCK_MOVE */
#include "emsmacros.h"                  /* EMerr_hndlr */
#include "emsedgedef.h"                 /* edge types */
#include "emsmapdef.h"          	/* options definitions */
#include "emserr.h"                     /* EMerr_hndlr */
#include "EMSprop.h"                    /* EMLP_ACTIVE etc. */
#include "EMSopt.h"                     /* EMS_O_OFF */
#include "emsdef.h"                     /* MAXINT */
#include "emsinterdef.h"
#include "emssfintdef.h"
#include "emslpinitdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "EMSwrmacros.h"
#include "bsrev_cv.h"

%safe
static IGRint EMvalidate_points();
static void EMnode_endpts();
%endsafe

#define MaxCurveToClip	50
#define MaxGroups	20
#define CharBuf		300

struct EMSgetlp_moreinfo
 {
   IGRchar              *more_info;
   IGRuchar     *curve_type;
 };

extern OMuword OPP_EMSloop_class_id,OPP_EMSlinedge_class_id;
extern OMuword OPP_EMSbsedge_class_id, OPP_EMSloopset_class_id;
extern OMuword OPP_EMScomposite_class_id, OPP_GRcompcurve_class_id;
extern OMuword OPP_EMSptedge_class_id, OPP_EMSptloop_class_id;

from EMSloop import EMlpinit, EMset_props;
from EMSlinedge import EMleinit;
from EMSbsedge import EMbsinit;
from GRowner import GRget_number_components, GRget_components;
from EMSloopset import EMmake_natural_loopset, EMset_props;
from EMSptedge import EMpteinit;
from EMSboundary import EMarea;

IGRint EMget_mapped_data( number_of_objects, input_curves, object_information,
	       	const_list, surface, par_tol_basis, env, bad_curves, 
		bad_points, out_loops, out_curves, clip_ls, options,
        	planar_info, EMmsg)
      
IGRlong         		number_of_objects;
struct IGRbsp_curve 		**input_curves;
struct          		GRlc_info *object_information;
struct          		GRvg_construct *const_list;
struct          		IGRbsp_surface *surface;
IGRdouble       		*par_tol_basis;
struct GRmd_env 		*env;
struct EMSgetlp_badcrvinfo	*bad_curves;
struct IGRpolyline	        *bad_points;
struct EMSgetlp_output		*out_loops;
struct EMSgetlp_output		*out_curves;
struct GRid     		clip_ls;
IGRushort 		options;
struct EMSgetlp_planar_info	*planar_info;
IGRlong         		*EMmsg;
{

 struct EMSgetlp_edgeinfo	***out_edges;
 IGRint				**num_out_edges;

 extern void EMsfintedpar_free();
 extern void            EMinters_free(),EMinters_data_free(), EMsfinttrace(), EMrevpyline();
 extern struct EMSintobj *EMmakeintlist();

extern IGRboolean EFfix_the_int() , EFextract_par() , 
EFis_linear_map_ok() , 
EFmap_the_curve() , 
EFpts_degenerate() ;

 extern IGRint          EMfix_sfint_after_uvtrace();

 IGRint			num_comp_curves = 0,
			num_grps = 0, *num_subgrps_grp = NULL,
			**num_elems_subgrp = NULL, *num_out_curves = NULL, 
                        num_curves_to_clip = 0, num_curves_cliped = 0,
			number_of_groups = 0, 
			num_out_curves_buf[MaxCurveToClip], 
			curve_index, dsz, dpsz, lsz, isz, gridsz, cpsz, 
			polysz, dspsz;
			
 IGRboolean             lin_map_ok = FALSE, 
			composite = FALSE, **valid_group = NULL, 
			*valid_group_buf[MaxGroups], 
			**subgrp_rev = NULL, ***elem_rev = NULL,
			*grp_closed = NULL, **sub_grp_closed = NULL, 
			dealloc_trace = FALSE, 
			atleast_one_composite = FALSE, 
                        ls_constructed = FALSE, remove_collapse = TRUE;

 IGRlong                loc_sts, sts, i = 0, j = 0, k = 0, m = 0, 
			num_bytes = 0, *points_per_group = NULL, 
			current_size = 0, rc;
			
 IGRdouble              cht, trace_tol, xyzlentol, xyzlentolsq, plentol,
			plentolsq, **uv_group = NULL, **xyz_group = NULL, *mat,
			loc_partol;
			
 struct EMSinters       trace_list, *trace_list_ptr;
 GRspacenum             loop_os, crvos;
 struct EMSdataselect   xyzdata, uvdata;
 struct EMSintobj       ***elems = NULL, *geom = NULL;

 struct GRid            my_obj, *to_id = NULL,curves_to_impose[MaxCurveToClip],
			*curve_ptr = NULL, ownerid;
			
 struct IGRbsp_curve    *curve = NULL;

 struct EMSdataselect   **uv_curves_cliped = NULL, **xyz_curves_cliped =NULL,
			*data = NULL, *modeldata = NULL, 
			*uv_curves_cliped_buf[MaxCurveToClip], 
			*xyz_curves_cliped_buf[MaxCurveToClip];
			
 IGRuchar               *out_curve_type_cliped = NULL, *in_edge_types, 
			out_curve_type_cliped_buf[MaxCurveToClip];
			
 IGRshort               planar_case, curve_props = NULL, *mattyp;
 OMuword                curve_classid;
 struct EMSpartolbasis  partolbasis;
 struct GRmdenv_info    *md_env_ptr = NULL;
 IGRchar                **more_info_ptr = NULL, **in_curve_info, 
			*more_info[MaxCurveToClip], char_buf[CharBuf];
 struct EMSgetlp_moreinfo *trace_more_info = NULL, 
			trace_more_info_buf[MaxGroups];
 OM_S_CHANSELECT	to_owners;
 GRobjid		crvid, prev_ownerid = NULL_OBJID;

/*
 * Initialize
 */
 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 if(bad_curves) bad_curves->num = 0;
 if(bad_points) bad_points->num_points = 0;
 loop_os = env->md_id.osnum;
 mattyp = &env->md_env.matrix_type;
 mat = env->md_env.matrix;
 curve = (struct IGRbsp_curve *) char_buf;
 more_info_ptr = more_info;
 curve_ptr = curves_to_impose;
 in_edge_types = planar_info ? planar_info->edge_types : NULL;
 in_curve_info = planar_info ? planar_info->curve_info : NULL;
 out_edges = planar_info ? planar_info->out_edges : NULL;
 num_out_edges = planar_info ? planar_info->num_out_edges : NULL;


 /* Sizes of frequently used data types */
 dsz = sizeof(IGRdouble);
 dpsz = sizeof(IGRdouble *);
 lsz = sizeof(IGRlong);
 isz = sizeof(IGRint);
 gridsz = sizeof(struct GRid);
 cpsz = sizeof(IGRchar *);
 polysz = sizeof(struct IGRpolyline);
 dspsz = sizeof(struct EMSdataselect *);

 trace_list_ptr = (struct EMSinters *) &trace_list;
 trace_list.next = NULL;
 trace_list.more_info = NULL;
 trace_list.num_pts = 0;
 trace_list.pts = NULL;
 trace_list.num_cvs = 0;
 trace_list.cvs = NULL;
 trace_list.num_coincs = NULL;
 trace_list.coinc_info_list = NULL;
 trace_list.props = 0;
 
 if(!par_tol_basis)
  {
   sts = EFsspbtol_by_geom(EMmsg, surface, &loc_partol);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);
   par_tol_basis = (IGRdouble *) &loc_partol;
  }

 partolbasis.tol = *par_tol_basis;
 partolbasis.is_valid = TRUE;
 partolbasis.in_world = FALSE;

 remove_collapse = ((options & EMMapBnd_NoRmvColEds) ||out_curves )
                     ? FALSE : TRUE;

 EMerr_hndlr(!number_of_objects, *EMmsg, EMS_I_NoMoreLoops, wrapup);
 if(options & EMMapBnd_NoClip) clip_ls.objid = NULL_OBJID;

 if(IF_NULL_OBJID(clip_ls.objid) && (!(options & EMMapBnd_NoClip)))
  {
    sts = om$construct(classid = OPP_EMSloopset_class_id, 
                    p_objid =&clip_ls.objid, osnum = loop_os, 
                    msg = message EMSloopset.EMmake_natural_loopset
                          (EMmsg, NULL, NULL, NULL));
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
    clip_ls.osnum = loop_os;
    ls_constructed = TRUE;
  }

 sts = EFextract_par(BSTOLLENVEC, *par_tol_basis, &plentol,EMmsg);
 sts = EFextract_par(BSTOLSQLENVEC, *par_tol_basis, &plentolsq,EMmsg);
 BSEXTRACTPAR (&rc, BSTOLCHRDHT, cht);
 BSEXTRACTPAR (&rc, BSTOLLENVEC, xyzlentol);
 BSEXTRACTPAR (&rc, BSTOLSQLENVEC, xyzlentolsq);


 /*
  * Check whether linear mapping is ok for the surface. If the curve info
  * and out_edges arguments are non NULL then the caller knows that the
  * surface is such that linear mapping from xyz to uv is ok. In such
  * case don't spend time determining it.
 */
 if( (in_curve_info && out_edges) || (options & EMMapBnd_SurfIsPlane) )
  {lin_map_ok = TRUE; planar_case = EMS_O_Planar;}
 else
  {
   sts = EFis_linear_map_ok (EMmsg, surface, &lin_map_ok);
   planar_case = lin_map_ok ? EMS_O_Planar : EMS_O_NonPlanar;
  }


 /* Collect all the curves to be imposed. If the curve is a composite
   then each of its components will be an individual candidate for imposition.
   If curve geometries are input then no need to do this.
 */
 if(!input_curves)
  {
   IGRint total_num_crvs = 0;
   num_curves_to_clip = 0;
   for(i=0; i<number_of_objects; i++)
    {
     num_comp_curves = 0;
     to_id = &object_information[i].located_obj;
     sts = om$send(msg = message GRowner.GRget_number_components
            (EMmsg, &num_comp_curves), senderid = NULL_OBJID, 
                        targetid = to_id->objid, targetos = to_id->osnum);
     if(sts == OM_W_UNKNOWN_MSG)
      num_comp_curves = 1;
     else if(!(1&sts)) {*EMmsg = EMS_E_Fail; goto wrapup;}
     else atleast_one_composite = TRUE;
     num_curves_to_clip += num_comp_curves;
     sts = OM_S_SUCCESS;
    }

   if(num_curves_to_clip > MaxCurveToClip)
    {
     curve_ptr = (struct GRid *) om$malloc(
                       size = num_curves_to_clip * gridsz);
     EMerr_hndlr(!curve_ptr, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     if(in_curve_info)
      {
       more_info_ptr = (IGRchar **) om$malloc(
                              size = num_curves_to_clip * cpsz);
       EMerr_hndlr(!more_info_ptr, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
    }
   total_num_crvs = num_curves_to_clip;
   num_curves_to_clip = 0;
   for(i=0; i<number_of_objects; i++)
    {
     to_id = &object_information[i].located_obj;
     num_comp_curves = 0;
     sts = OM_S_SUCCESS;
     sts = om$send(msg = message GRowner.GRget_components
                        (EMmsg, &object_information[i].module_info, 
                         &curve_ptr[num_curves_to_clip], total_num_crvs, 
                         &num_comp_curves, 0, MAXINT), 
                         senderid = NULL_OBJID, 
                         targetid = to_id->objid, targetos = to_id->osnum);
     if(sts == OM_W_UNKNOWN_MSG)
      {
       OM_BLOCK_MOVE(to_id, &curve_ptr[num_curves_to_clip], gridsz);
       num_comp_curves = 1;
      }
     else if(!(1&sts)) {*EMmsg = EMS_E_Fail; goto wrapup;}
     
     if(in_curve_info)
      {
       for(j=num_curves_to_clip; j<num_comp_curves; j++)
        OM_BLOCK_MOVE(&in_curve_info[j], &more_info_ptr[j], cpsz);
      }
     num_curves_to_clip += num_comp_curves;
     sts = OM_S_SUCCESS;

    } /* for i=0; i<number_of_objects; i++ */

   } /* If !input_curves */
  else
   {
     num_curves_to_clip = number_of_objects;
     more_info_ptr = in_curve_info;
     curve_ptr = curves_to_impose;
   }

  /* If there is atleast one composite curve passed in, then the input edge
   types(if any) will be unconditionaly ignored.
   The to_owners channel structure is used later on.
  */

  if(atleast_one_composite || out_curves)
   {
    if(atleast_one_composite) in_edge_types = NULL;
    if(bad_curves || out_curves)
     {
      sts = EMmake_chanselect (GRconnector_to_owners, &to_owners);
      if(!(1&sts)) goto wrapup;
     }
   }

  /* Do the memory allocations.  
  */
  if(num_curves_to_clip > MaxCurveToClip)
   {
    uv_curves_cliped = (struct EMSdataselect **) om$malloc (size = 
                       num_curves_to_clip * dspsz);
    xyz_curves_cliped = (struct EMSdataselect **) om$malloc (size = 
                       num_curves_to_clip * dspsz);
    out_curve_type_cliped = (IGRuchar *) om$malloc(size = 
                        num_curves_to_clip * sizeof(IGRuchar));
    num_out_curves = (IGRint *) om$malloc(size = num_curves_to_clip * isz);
   }
  else
   {
    uv_curves_cliped = (struct EMSdataselect **) uv_curves_cliped_buf;
    xyz_curves_cliped = (struct EMSdataselect **) xyz_curves_cliped_buf;
    out_curve_type_cliped = (IGRuchar *) out_curve_type_cliped_buf;
    num_out_curves = (IGRint *) num_out_curves_buf;
   }

  EMerr_hndlr(!uv_curves_cliped || !xyz_curves_cliped ||
      !out_curve_type_cliped || !num_out_curves, *EMmsg, EMS_E_NoDynamicMemory,
      wrapup);

  for(i=0; i<num_curves_to_clip; i++)
   {
    uv_curves_cliped[i] = xyz_curves_cliped[i] = NULL;
    num_out_curves[i] = 0;
   }

  num_curves_cliped = 0;

  if(bad_curves && !bad_curves->bad_indices)
   {
    bad_curves->bad_indices = (IGRlong *) om$malloc(size = num_curves_to_clip
					* sizeof(IGRlong));
    EMerr_hndlr(!bad_curves->bad_indices, *EMmsg, EMS_E_NoDynamicMemory, 
					wrapup);
   }

  /* If edge types are passed in then ask EFmap_the_curve 
     not to return them again.
  */
  if(in_edge_types || input_curves) options |= EMMapBnd_NoCurveType;

  /* If curve objects are passed in, they can be all in the same object space
    or each can be in a different object space which itself could be different
    from the object space of the surface. 
  */
 if(!input_curves)
  {
    curve = (struct IGRbsp_curve *) char_buf;
    current_size = CharBuf;
  }

 if(options & EMMapBnd_WantStatMsg) 
  ex$message(msgnumb = EMS_I_MappingToParSpace)

 prev_ownerid = NULL_OBJID;
 curve_index = 0;
 for (i = 0; i < num_curves_to_clip; i++)
  {
   if(!input_curves)
    {
     IGRshort	*mxtyp;
     IGRdouble  *mx;

     crvos = curve_ptr[i].osnum;
     crvid = curve_ptr[i].objid;
     md_env_ptr = NULL;
     for(j=0; (j<number_of_objects) && !md_env_ptr; j++)
      if(object_information[j].module_info.md_id.osnum == crvos)
       md_env_ptr = &object_information[j].module_info.md_env;

     EMerr_hndlr(!md_env_ptr, *EMmsg, EMS_E_Fail, wrapup);
     mxtyp = &md_env_ptr->matrix_type;
     mx = md_env_ptr->matrix;

     if(atleast_one_composite && bad_curves)
      {
       sts = om$send(msg = message GRgraphics.GRgetprops(EMmsg, &curve_props),
		senderid = NULL_OBJID, targetid = crvid,targetos = crvos);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
       if(curve_props & GR_RIGID_RELATIONSHIP)
	{
	 sts = om$get_objid_at_index(objid = crvid, osnum = crvos, 
		p_chanselect = &to_owners, index = 0, 
		objidaddr = &ownerid.objid, osnumaddr = &ownerid.osnum);
         EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
        }
       else ownerid.objid = NULL_OBJID;
      }
     else ownerid.objid = NULL_OBJID;

     /*
      * Get the geometry for this particular curve
      */
     sts = om$send(msg = message GRvg.GRgetsize(EMmsg, mxtyp, mx, &num_bytes),
             senderid = NULL_OBJID,targetid = crvid, targetos = crvos);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

     /* If the appropriate memory is alredy available, use it.
     */
     if(current_size < num_bytes)
      {
       if(curve != (struct IGRbsp_curve *) char_buf)
        curve = (struct IGRbsp_curve *) om$realloc(ptr = (char *) curve, 
						size = num_bytes);
       else
        curve = (struct IGRbsp_curve *) om$malloc(size = num_bytes);	
       current_size = num_bytes;
      }
     EMerr_hndlr(!curve, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

     sts = om$send(msg = message GRvg.GRgetgeom(EMmsg, mxtyp, mx, 
                         (IGRchar *)curve),
               senderid = NULL_OBJID, targetid = crvid, targetos = crvos);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

    } /* If !input_curves */

   else
    {
      curve = (struct IGRbsp_curve *) input_curves[i];
      ownerid.objid = NULL_OBJID;
    }

   /*
    * Map this curve into the parametric space of the surface
    */
   sts = EFmap_the_curve(input_curves ? curve_ptr[0] : curve_ptr[i], 
		curve, surface, clip_ls, &cht,
		&partolbasis, options, &planar_case, 
	     	&num_out_curves[num_curves_cliped],
		&uv_curves_cliped[num_curves_cliped], 
		&xyz_curves_cliped[num_curves_cliped], 
		&out_curve_type_cliped[num_curves_cliped], NULL, FALSE, EMmsg);
   if(!sts) 
    {
     *EMmsg = EMS_E_Fail;
     sts = OM_S_SUCCESS;
     goto wrapup;
    }
   else sts = OM_S_SUCCESS;

   /* If the edge types were passed in use them. If they are not
       passed in,the user might have given curveids,in which case
       map the curve would have determined the edge type. If no
       curve ids are available and if the user has not supplied any
       edge types,then set the edge type to free form curve by
       default.
   */
   if(in_edge_types) 
    out_curve_type_cliped[num_curves_cliped] = in_edge_types[i];
   else if(options & EMMapBnd_NoCurveType)
    out_curve_type_cliped[num_curves_cliped] = EMfreeform_curve;

   if(i && (IF_NULL_OBJID(ownerid.objid) ||
     !IF_EQ_OBJID(ownerid.objid, prev_ownerid))) curve_index++;

   if(*EMmsg == EMS_I_OutOfBounds) 
    {
     if(bad_curves && (IF_NULL_OBJID(ownerid.objid) ||
	 		!IF_EQ_OBJID(ownerid.objid, prev_ownerid)))
      bad_curves->bad_indices[bad_curves->num++] = curve_index;
     if (options & EMMapBnd_WantBadCurves) num_curves_cliped++;
    }
   else num_curves_cliped++;
   prev_ownerid = ownerid.objid;
    
  } /* for (i = 0; i < num_curves_to_clip; i++) */

 EMerr_hndlr(!num_curves_cliped, *EMmsg, EMS_I_NoMoreLoops, wrapup);

 number_of_groups = 0;
 for(i=0; i<num_curves_cliped; i++) number_of_groups += num_out_curves[i];

 EMerr_hndlr(!number_of_groups, *EMmsg, EMS_I_NoMoreLoops, wrapup);

 /* Fixing is done if the caller wishes  and if it is a non planar
   surface.
 */
 
 if ((planar_case != EMS_O_Planar)&&(!(options & EMMapBnd_NoTraceClipFix)))
 {
  IGRint junk;
  junk = number_of_groups * dpsz;
  uv_group = (IGRdouble **) om$malloc(size = junk);
  xyz_group = (IGRdouble **) om$malloc(size = junk);
  points_per_group = (IGRlong *) om$malloc(size = number_of_groups * lsz);
  EMerr_hndlr(!uv_group, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  EMerr_hndlr(!xyz_group, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  EMerr_hndlr(!points_per_group, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  k = 0;
  for(i=0; i<num_curves_cliped; i++)
   for(j=0;j<num_out_curves[i]; j++)
    {
     OM_BLOCK_MOVE(&uv_curves_cliped[i][j].data.poly->points, &uv_group[k], 
                        dpsz);
     uv_curves_cliped[i][j].data.poly->points = NULL;
     OM_BLOCK_MOVE(&xyz_curves_cliped[i][j].data.poly->points, &xyz_group[k]
                        , dpsz);
     xyz_curves_cliped[i][j].data.poly->points = NULL;
     OM_BLOCK_MOVE(&xyz_curves_cliped[i][j].data.poly->num_points, 
                      &points_per_group[k++], lsz);
    }

  if(!(options & EMMapBnd_NoFixing))
   {
    sts = EFfix_the_int( NULL, remove_collapse, surface, NULL,
		&number_of_groups, &points_per_group, &xyz_group, &uv_group,
           	NULL, EMmsg);
    if (!sts) 
     {
      if(*EMmsg == MSFAIL) *EMmsg = EMS_E_Fail;
      else if(*EMmsg == MANOMEMORY) *EMmsg = EMS_E_NoDynamicMemory;
      sts = OM_S_SUCCESS;
      goto wrapup;
     }
    else sts = OM_S_SUCCESS;
    EMerr_hndlr(!number_of_groups, *EMmsg, EMS_I_NoMoreLoops, wrapup);
   }

 } /* If non planar and validation */

 /* Convert the data we have so far into the 'inters' format.
  * Then trace and validate it.
  *
 */
 if( !(options & EMMapBnd_NoTraceClipFix))
  {
   trace_tol = 2 * cht;
   my_obj.osnum = OM_Gw_current_OS;
   my_obj.objid = NULL_OBJID;
   trace_list.this_obj = my_obj;		/* Have only one surface*/

   if (planar_case != EMS_O_Planar)
    {
     xyzdata.datatype = EMSdata_poly3d;
     uvdata.datatype = EMSdata_poly2d; 
     for(i=0; i<number_of_groups; i++)
      {
       xyzdata.data.poly = (struct IGRpolyline *) om$malloc (size = polysz);
       EMerr_hndlr(!xyzdata.data.poly, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

       xyzdata.data.poly->num_points = points_per_group[i];
       xyzdata.data.poly->points = (IGRdouble *) xyz_group[i];
       xyz_group[i] = NULL;

       uvdata.data.poly = (struct IGRpolyline *) om$malloc (size = polysz);
       EMerr_hndlr(!uvdata.data.poly, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

       uvdata.data.poly->num_points = points_per_group[i];
       uvdata.data.poly->points = (IGRdouble *) uv_group[i];
       uv_group[i] = NULL;

       EMmakeintlist (EMmsg, &trace_list_ptr, NULL, &my_obj, NULL, surface, 
		NULL, NULL,NULL,&xyzdata, &uvdata,NULL, FALSE, FALSE, 
                NULL, NULL, NULL, NULL, NULL, NULL, TRUE, FALSE);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
      }

    } /* If planar_case != EMS_O_Planar*/
   else
    { 
     IGRint  ele_num;
        
     if(in_curve_info)
      {
       if(number_of_groups > MaxGroups)
        trace_more_info = (struct EMSgetlp_moreinfo *) om$malloc(
                  size = number_of_groups * sizeof(struct EMSgetlp_moreinfo));
       else trace_more_info = (struct EMSgetlp_moreinfo *)
					trace_more_info_buf;
       EMerr_hndlr(!trace_more_info, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
     ele_num = 0;
     for(i=0; i<num_curves_cliped; i++)
      for(j=0; j<num_out_curves[i]; j++)
       {
        /* Put the curve type with each component curve so that after trace
           we still have the correct type with each node(the node can be
           shifted around during trace).
        */
        if(in_curve_info)
         {
          trace_more_info[ele_num].curve_type = (IGRuchar *)
               				&out_curve_type_cliped[i];
          trace_more_info[ele_num].more_info = (IGRchar *) more_info_ptr[i];
         }
        EMmakeintlist (EMmsg, &trace_list_ptr, NULL, &my_obj, NULL, surface, 
		NULL, NULL,NULL,&xyz_curves_cliped[i][j], 
                &uv_curves_cliped[i][j], NULL, 
                FALSE, FALSE, in_curve_info ?(char *)&trace_more_info[ele_num] :
                (char *)&out_curve_type_cliped[i], NULL, EMSintobj_nontriminfo, 
		EMSintobj_nontriminfo, NULL, NULL, TRUE, FALSE);
        EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
	xyz_curves_cliped[i][j].datatype = EMSdata_null;
        xyz_curves_cliped[i][j].data.poly = NULL;
        xyz_curves_cliped[i][j].data.curve = NULL;
	uv_curves_cliped[i][j].datatype = EMSdata_null;
	uv_curves_cliped[i][j].data.poly = NULL;
        uv_curves_cliped[i][j].data.curve = NULL;
        ele_num++;
       }
        
    } /* if planar */

   EMsfinttrace(EMmsg, mattyp, mat, trace_list_ptr, &plentol, 
	&trace_tol, &num_grps, &num_subgrps_grp, &num_elems_subgrp, &elems,
	&subgrp_rev, &elem_rev, &grp_closed, &sub_grp_closed);
   dealloc_trace = TRUE;

   if(!(1&*EMmsg)) {*EMmsg=EMS_E_Intersect; goto wrapup;}   

   sts = EMfix_sfint_after_uvtrace(EMmsg, mattyp, mat, mattyp, mat, NULL,
			trace_list_ptr,
                        &plentol, &trace_tol, &num_grps,
                        &num_subgrps_grp,&num_elems_subgrp,&elems,&subgrp_rev,
                        &elem_rev,&grp_closed, &sub_grp_closed, NULL, NULL, 
			NULL, NULL, 0);
   if(!(1&*EMmsg)) {*EMmsg=EMS_E_Intersect; goto wrapup;}   

   /* If the caller wishes the validity check then do it.
   */
   if(!(options & EMMapBnd_NoValidate))
    {
     if(num_grps > MaxGroups) valid_group = NULL;
     else valid_group = (IGRboolean **) valid_group_buf;
     sts = EMvalidate_points(surface, num_grps, num_subgrps_grp, 
		num_elems_subgrp, elems, subgrp_rev, elem_rev, grp_closed,
	   	sub_grp_closed, &valid_group, plentol, plentolsq, 
		/*trace_tol * trace_tol,*/ cht * cht, 
		bad_points ? &bad_points->num_points : NULL, 
		bad_points ? &bad_points->points : NULL, EMmsg);
     if (!sts)
      {
       *EMmsg = EMS_E_Fail;
       sts = OM_S_SUCCESS;
       goto wrapup;
      }
     else sts = OM_S_SUCCESS;
    }


   /* Reverse the element geometries if the trace has determined so.
    * The element geometries need to be reversed if the caller wishes
    * model space curves to be output. For parametric space edges, if
    * the geometry is reversed, the edge will be marked as such at
    * construction time.
    */
   if(out_curves)
    {
     for(i=0;i<num_grps;i++)
      for(m=0;m<num_subgrps_grp[i];m++)
       {
        geom = elems[i][m];
        for(j=0;j<num_elems_subgrp[i][m];j++)
         {
          data = &geom->this_xyzintobj;
          if (!elem_rev[i][m][j]) {geom = geom->next; continue;}
          if(data->datatype == EMSdata_curve3d)
           {
            BSrev_cv (&rc, data->data.curve);
            EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);
           }
          else if(data->datatype == EMSdata_poly3d)
           {
            EMrevpyline(EMmsg, data->data.poly,3,NULL);
            EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);
           }
          else {*EMmsg = EMS_E_Fail; goto wrapup;}
          geom = geom->next;
        
         }  /* for(i=0; i<num_elems_subgrp[i][m]; i++) */
        
       } /* for(m=0;m<num_subgrps_grp[i];m++) */

    } /* if(out_curves) */


  } /* if (! (options & EMMapBnd_NoTraceClipFix)) */

 /*
  * At this point the data is ready to be output. 
  * Construct parametric loops/edges and/or model space curves.
  */
 {
  OM_S_CHANSELECT              to_edges, to_lp, to_comps;
  IGRint                       loop_count, num_loops, curve_count, loop_num;
  GRobjid                      loop,edge;
  struct GRid                  curve;
  IGRushort            lpprops = EMLP_ACTIVE, lpinit_options = NULL;
  IGRuchar             edge_type, *edge_type_ptr;
  extern IGRlong               EFget_classid_for_an_edge_type();
  IGRboolean                   notrace;

  if(out_loops)
   {
    sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
    EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
    sts = EMmake_chanselect (EMSedge_to_owner, &to_lp);
    EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
   }
  if(out_curves)
   {
    sts = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
    EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
   }

  num_loops = 0;
  notrace = options & EMMapBnd_NoTraceClipFix;
  if(notrace) num_loops = 1;
  else
   for(i=0;i<num_grps;i++) num_loops += num_subgrps_grp[i];

  if(out_loops && num_loops)
   {
    if(!out_loops->objs)
     out_loops->objs = (GRobjid *) om$malloc(size = num_loops*sizeof(GRobjid));
    if(!out_loops->objs){*EMmsg=EMS_E_DynamicMemoryAllocated;goto wrapup;}
    out_loops->num_objs = 0;
   }

  if(out_edges && num_loops)   
   {
    if(!*out_edges)
      *out_edges = (struct EMSgetlp_edgeinfo **) om$malloc(size = num_loops *
                                        sizeof(struct EMSgetlp_edgeinfo *));
    if(!*out_edges){*EMmsg=EMS_E_DynamicMemoryAllocated;goto wrapup;}
    if(!*num_out_edges)
      *num_out_edges = (IGRint *) om$malloc(size = num_loops * isz);
    if(!*num_out_edges){*EMmsg=EMS_E_DynamicMemoryAllocated;goto wrapup;}
   }

  if(out_curves && num_loops)
   {
    if(!out_curves->objs)
      out_curves->objs = (GRobjid *) om$malloc(size = num_loops * 
					sizeof(GRobjid));
    if(!out_curves->objs){*EMmsg = EMS_E_DynamicMemoryAllocated; goto wrapup;}
    out_curves->num_objs = 0;
   }

  if(const_list) OM_BLOCK_MOVE(&const_list->env_info->md_id.osnum, &crvos, 
                                sizeof(GRspacenum));
  loop_num = 0;
  for(i=0; i< (notrace ? 1 : num_grps) ;i++)
   for(m=0; m< (notrace ? 1 : num_subgrps_grp[i]) ;m++)
    {
     if(valid_group && (!valid_group[i][m])) continue;
     if(out_loops)
      {
       sts = om$construct(classid=OPP_EMSloop_class_id, osnum = loop_os, 
                         p_objid = &out_loops->objs[out_loops->num_objs]);
       if(!(1&sts)) goto wrapup;
       loop = out_loops->objs[out_loops->num_objs++];
      } 

     composite = notrace ? (num_curves_cliped > 1) 
			 : (num_elems_subgrp[i][m] > 1);
                        
     if(out_curves && composite)
      {
       sts = om$construct(classid= OPP_GRcompcurve_class_id, osnum = crvos, 
                     p_objid = &out_curves->objs[out_curves->num_objs], 
                     msg = message GRgraphics.GRconstruct(const_list));
       if(!(1&sts)) goto wrapup;
       curve.objid = out_curves->objs[out_curves->num_objs++];
       curve.osnum = crvos;
      }

     /* get the address of the start of the elements
     */
     if(!notrace)
      OM_BLOCK_MOVE(&elems[i][m], &geom, sizeof(struct EMSintobj *));

     loop_count = curve_count = 0;

     if(out_edges)
      {
       (*out_edges)[loop_num] = (struct EMSgetlp_edgeinfo *) 
                                om$malloc(size = num_elems_subgrp[i][m] * 
                                sizeof(struct EMSgetlp_edgeinfo));
       EMerr_hndlr(!(*out_edges)[loop_num], *EMmsg, EMS_E_NoDynamicMemory, 
                        wrapup);
       (*num_out_edges)[loop_num] = num_elems_subgrp[i][m];
      }

     for(j=0;j< (notrace ? num_curves_cliped : num_elems_subgrp[i][m]) ;j++)
      {
       if(planar_case == EMS_O_Planar)
        {
         if(notrace) edge_type = out_curve_type_cliped[j];
         else
          {
           struct EMSgetlp_moreinfo *dummy;
                
           if(in_curve_info)
            {
             dummy = (struct EMSgetlp_moreinfo *) geom->more_info;
             edge_type = *(dummy->curve_type);
             if(out_edges) 
             (*out_edges)[loop_num][loop_count].info = dummy->more_info;
            }
           else
            {
             edge_type_ptr = (IGRuchar *) geom->more_info;
             edge_type = *edge_type_ptr;
            }
          }
         }  /* if(planar_case == EMS_O_Planar) */

        else edge_type = EMfreeform_curve;
                
        if(out_loops)
         {
          IGRushort edprops = NULL;
          IGRushort leinit_options = NULL;
	  IGRboolean closure = FALSE, isdegn = FALSE;
	        
          data = notrace ? &uv_curves_cliped[j][0]
                            : &geom->this_uvintobj;

          modeldata = notrace ? &xyz_curves_cliped[j][0]
                            : &geom->this_xyzintobj;

          edprops = notrace ? NULL : 
                        (elem_rev[i][m][j] ? EMED_REVERSED : NULL);

          if( !notrace && (num_elems_subgrp[i][m] == 1) && 
		 (num_subgrps_grp[i] == 1) && grp_closed[i])
     	   edprops |= EMED_XYZ_CLOSED;

          if( !notrace && (num_elems_subgrp[i][m] == 1) && 
		    (num_subgrps_grp[i] == 1) && grp_closed[i] && 
		    sub_grp_closed[i][m])
           {
            edprops &= ~EMED_OPEN;
	    edprops |= EMED_XYZ_CLOSED;
	    leinit_options |= EMSleinit_NoClosureCheck;
	    closure = TRUE;	   
	   }
          else {leinit_options = NULL; closure = FALSE;}
		
          if (data->datatype == EMSdata_poly2d)
           {
            if(planar_case != EMS_O_Planar)
             {
              if(data->data.poly->num_points > 2) edge_type = EMlinestring;
    	      else edge_type = EMlinesegment;
	     }
	    isdegn = EFpts_degenerate(data->data.poly->num_points, 
			 data->data.poly->points, NULL, 2, partolbasis.tol);
            if(isdegn)
	     {
              sts = om$construct(classid = OPP_EMSptedge_class_id,
                             p_objid = &edge, msg = message EMSptedge.EMpteinit
               		(EMmsg, edprops, data->data.poly->points), 
			osnum = loop_os);
              if(!(1&*EMmsg&sts)) goto wrapup;
	     }
            else
	     {
	      /* Is the edge degenerate in model space ?
	      */
	      isdegn = EFpts_degenerate(modeldata->data.poly->num_points, 
			 modeldata->data.poly->points, NULL, 3, cht);
	      if(isdegn) edprops |= EMED_DEGENERATE;
	
              sts = om$construct(classid = OPP_EMSlinedge_class_id,
                                p_objid=&edge,msg=message EMSlinedge.EMleinit
               (EMmsg,edprops, edge_type, data->data.poly, &partolbasis,
  		leinit_options | EMSleinit_SnapToUvLimits, 
		NULL_OBJID), osnum = loop_os);
              if(!(1&*EMmsg&sts)) goto wrapup;
	     }
           }
          else if(data->datatype == EMSdata_curve3d)
           {
	    if(closure) data->data.curve->phy_closed = TRUE;
            isdegn = EFpts_degenerate(data->data.curve->num_poles, 
			 data->data.curve->poles, data->data.curve->weights, 
					 2, partolbasis.tol);
   	    if(isdegn)
	     {
	      IGRdouble pt[2];
		
	      pt[0] = data->data.curve->poles[0];
              pt[1] = data->data.curve->poles[1];
	      if(data->data.curve->rational && data->data.curve->weights)
	       {
		pt[0] /= data->data.curve->weights[0];
		pt[1] /= data->data.curve->weights[0];		
	       }
              sts = om$construct (classid = OPP_EMSptedge_class_id,
                                 p_objid=&edge, msg=message EMSptedge.EMpteinit
                            (EMmsg, edprops, pt), osnum = loop_os);
              if(!(1&*EMmsg&sts)) goto wrapup;
             }
            else
             {
	      /* Is the edge degenerate in model space ?
	      */
              isdegn = EFpts_degenerate(modeldata->data.curve->num_poles, 
		     modeldata->data.curve->poles, 
		     modeldata->data.curve->weights, 3, cht);
	      if(isdegn) edprops |= EMED_DEGENERATE;
              sts = om$construct (classid = OPP_EMSbsedge_class_id,
                           p_objid=&edge, msg=message EMSbsedge.EMbsinit
                   (EMmsg,edprops,edge_type,data->data.curve, &partolbasis), 
                                 osnum = loop_os);
              if(!(1&*EMmsg&sts)) goto wrapup;
    	     }
		
            }

           else {*EMmsg = EMS_E_Fail; goto wrapup;}
                
           sts = om$send(msg=message Root.connect(to_edges,NULL,edge,
                                loop_os,to_lp,loop_count),
                                senderid=edge,targetid=loop, 
                                targetos = loop_os);
           if(!(1&sts)) goto wrapup;
           if(out_edges) (*out_edges)[loop_num][loop_count].edgeid = edge;
           loop_count++;
	
          }  /* If out_loops */
          
         if(out_curves)
          {
           data = notrace ? &xyz_curves_cliped[j][0] : &geom->this_xyzintobj;
           if(data->datatype == EMSdata_poly3d)
            {
/****************************************************************************
             sts = EFplace_line_string(NULL_OBJID, const_list, 
                                data->data.poly->num_points,
                                data->data.poly->points, &crvid, EMmsg);
****************************************************************************/
             sts = ems$place_line_string(msg = EMmsg,
                               number_of_points = data->data.poly->num_points,
                               points = (IGRpoint *)data->data.poly->points,
                               construction_args = const_list,
                               objid = &crvid);
             EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
            }
           else if(data->datatype == EMSdata_curve3d)
            {
             /* Can come here only for planar case */

             sts = EFget_classid_for_an_edge_type(&curve_classid,edge_type);
             EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);

             const_list->geometry = (IGRchar *) data->data.curve;
             sts = om$construct(classid = curve_classid, osnum = crvos, 
                            p_objid = &crvid, 
                            msg = message GRgraphics.GRconstruct(const_list));
             EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
                
            } /* If data->datatyp == EMSdata_curve3d */

           else {*EMmsg = EMS_E_Fail; goto wrapup;}
                
           if(!composite)
             out_curves->objs[out_curves->num_objs++] = crvid;
           else
            {
             sts = om$send(msg = message Root.connect
                       (to_comps, NULL, crvid, crvos, to_owners, curve_count), 
                        targetid = curve.objid, targetos = curve.osnum, 
                        senderid = crvid);
             EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
             curve_count++;
                
            } /* if composite */
        
           } /* If out_curves */
          if(!notrace && geom) geom = geom->next;
        
        } /* For (j=0;j < (notrace ? num_curves_cliped : 
                        num_elems_subgrp[i][m]) ;j++) */

/* Initialize the loop constructed.
*/
       if(out_loops)
        {
	 lpprops = EMLP_ACTIVE;
	 if(!notrace && !sub_grp_closed[i][m]) lpprops |= EMLP_OPEN;

	 lpinit_options = notrace ? NULL : EMLpInit_NoClosureTest;
         sts = om$send(msg=message EMSloop.EMlpinit
                                (EMmsg, lpprops, &partolbasis, lpinit_options),
                                senderid=NULL_OBJID,targetid = loop,
                                targetos = loop_os);
         if(!(1&*EMmsg&sts)) goto wrapup;
        }
       loop_num++;

    }/* for(m=0;m< (notrace ? 1 : num_subgrps_grp[i]) ;m++) */

  } /*construction block*/
 
/*
 * End of routine
 */

wrapup:

 /* Set the more info pointer to NULL because the EMinters_data_free function
   should not deallocate that memory.
 */
   for(i=0; i<num_grps; i++)
    for(j=0; j<num_subgrps_grp[i]; j++)
     {
      geom = elems[i][j];
      for(m=0; m<num_elems_subgrp[i][j]; m++)
       {
        geom->more_info = NULL;
        geom = geom->next;
       }
     }

 /* if tracing was done then the EMSinters structure has the pointer to the
   surface geomtery as 'more_info'. Set this to NULL so that it does not
   get freed.
 */
 trace_list.more_info = NULL;

 if(!IF_NULL_OBJID(clip_ls.objid) && ls_constructed)
  loc_sts = om$send(msg = message Root.delete(TRUE), targetid = clip_ls.objid, 
                        targetos = clip_ls.osnum, senderid = NULL_OBJID);
                        
 if(out_curve_type_cliped && (out_curve_type_cliped != 
			      out_curve_type_cliped_buf)) 
	om$dealloc(ptr = out_curve_type_cliped);
 if(num_out_curves && (num_out_curves != num_out_curves_buf)) 
	om$dealloc(ptr = num_out_curves);

 for(i=0;i<num_curves_cliped;i++)
  {
   if(uv_curves_cliped[i])
    EMdataselect_data_free(&rc, uv_curves_cliped[i], 1);
   if(xyz_curves_cliped[i])
    EMdataselect_data_free(&rc, xyz_curves_cliped[i], 1);
  }
 EMinters_data_free (&rc, trace_list_ptr, MAXINT, NULL,
                        NULL);
 if(trace_list_ptr)
   {
   void EMintobj_free();
   while (trace_list_ptr)
     {
     EMintobj_free (trace_list_ptr->pts, NULL);
     EMintobj_free (trace_list_ptr->cvs, NULL);
     trace_list_ptr = trace_list_ptr->next;
     }
   }
 for(i=0; i<number_of_groups; i++)
  {
   if (xyz_group && xyz_group[i]) om$dealloc(ptr = xyz_group[i]);
   if (uv_group && uv_group[i]) om$dealloc(ptr = uv_group[i]);
  }

 if (xyz_group) om$dealloc(ptr = xyz_group);
 if (uv_group) om$dealloc(ptr = uv_group);
 if (points_per_group) om$dealloc(ptr = points_per_group);
 if(uv_curves_cliped) 
  {
   for(i=0; i<num_curves_to_clip; i++)
     if(uv_curves_cliped[i]) om$dealloc(ptr = uv_curves_cliped[i]);
   if(uv_curves_cliped != uv_curves_cliped_buf) 
     om$dealloc(ptr = uv_curves_cliped);
  }

 if(xyz_curves_cliped) 
  {
   for(i=0; i<num_curves_to_clip; i++)
    if(xyz_curves_cliped[i]) om$dealloc(ptr = xyz_curves_cliped[i]);
   if(xyz_curves_cliped != xyz_curves_cliped_buf)
    om$dealloc(ptr = xyz_curves_cliped);
  }

 if(valid_group) 
  {
   for(i=0;i<num_grps;i++) om$dealloc(ptr = valid_group[i]);
   if(valid_group != valid_group_buf) om$dealloc(ptr = valid_group);
  }

 if(curve_ptr && curve_ptr != curves_to_impose) om$dealloc(ptr = curve_ptr);
 if(more_info_ptr && more_info_ptr!=more_info && more_info_ptr!=in_curve_info)
   om$dealloc(ptr = more_info_ptr);

 if(trace_more_info && (trace_more_info != trace_more_info_buf)) 
   om$dealloc(ptr = trace_more_info);

 if(curve && !input_curves && (curve != (struct IGRbsp_curve *) char_buf)) 
      om$dealloc(ptr = curve);

 if(dealloc_trace) EMsfinttrace_free(&rc,num_grps,num_subgrps_grp,
                    num_elems_subgrp,elems,subgrp_rev,elem_rev,grp_closed, 
                    sub_grp_closed);

  EMWRAPUP(*EMmsg, sts, "In EMget_mapped_data");
  return(sts);
}



/*
 * This function accepts the output from EMsfinttrace and validates each
 * subgroup for imposition. A subgrp is valid if it is closed wrt itself
 * or wrt the natural boundary of the surface.
 */

#define GET_ADDR        1
#define PUT_POINT       0


static IGRint EMvalidate_points(
  surface,                      /* Surface data */
  num_grps,
  num_subgrps_grp,
  num_elems_subgrp,
  elems,
  subgrp_rev,
  elem_rev,
  grp_closed,
  sub_grp_closed, 
  valid_group,
  par_tol,                      /* Parametric tolerance */
  par_tol_sq, 
  model_tol_sq, 
  number_of_points,             /* Number of points at end of bad open loops */
  points,                       /* Points at the end of bad open loops */
  msg)                          /* Error return code */

struct          IGRbsp_surface *surface;
IGRint          num_grps;
IGRint          *num_subgrps_grp;
IGRint          **num_elems_subgrp;
struct EMSintobj ***elems;
IGRboolean      **subgrp_rev,***elem_rev,*grp_closed, **sub_grp_closed;
IGRboolean      ***valid_group;
IGRdouble       par_tol, par_tol_sq, model_tol_sq;
IGRlong         *number_of_points;
IGRpoint        **points;
IGRlong         *msg;

{
 IGRboolean             xyz_data,EFvalidate_an_untrimmed_loop();
 IGRlong                i, j, sts, m, rc;
 IGRdouble              *last_point_uv, *first_point_uv;
 IGRdouble              *first_point_xyz, *last_point_xyz;
 IGRdouble              u_low, u_hig, v_low, v_hig;
 struct EMSintobj       *last_node, *first_node, *this_node;
 struct EMSdataselect   *first_uv, *last_uv, *first_xyz, *last_xyz;
 IGRdouble		*loc_points = NULL;
 IGRlong		loc_num_pts = 0;

/*
 * Initialize
 */

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 if(number_of_points) *number_of_points = 0;
 if(points) *points = NULL;

 if(!(*valid_group))(*valid_group) = (IGRboolean **) malloc(num_grps *
                                        sizeof(IGRboolean *));
 EMerr_hndlr(!(*valid_group),*msg,EMS_E_DynamicMemoryAllocated,wrapup);

/*
 * Determine the parametric values of the edges of the surface
 */

 u_low = surface->u_knots[surface->u_order - 1];
 u_hig = surface->u_knots[surface->u_num_poles];
 v_low = surface->v_knots[surface->v_order - 1];
 v_hig = surface->v_knots[surface->v_num_poles];


/*
 * Loop around all the input data
 * index i represents the number of 'global' groups.
 * index m represents number of subgroups in each 'global' group. If we
 * have a single surfaces with some linetsrings (traced), then there can
 * be any number of groups each having ONLY one subgroup.
 * subgroups are therefore components of a group per surface.
 */

 for (i = 0; i < num_grps; i++)
 {
  (*valid_group)[i] = (IGRboolean *) om$malloc(size=
                        num_subgrps_grp[i]* sizeof(IGRboolean));
  EMerr_hndlr(!(*valid_group)[i],*msg,EMS_E_DynamicMemoryAllocated,wrapup);
  for(m=0; m<num_subgrps_grp[i];m++)
   {
    (*valid_group)[i][m] = TRUE;
    if(sub_grp_closed[i][m]) continue;		/* closed loop */

    /* Determine the addresses of the first and last elements in this sub 
       group.
    */
    first_node = elems[i][m];
    last_node = elems[i][m];
    for(j=0;j<num_elems_subgrp[i][m]-1;j++) last_node = last_node->next;
    xyz_data = (first_node->this_xyzintobj.datatype == EMSdata_null) ? 
                                                FALSE : TRUE;
    first_uv = &first_node->this_uvintobj;
    last_uv  = &last_node->this_uvintobj;
    first_xyz = &first_node->this_xyzintobj;
    last_xyz  = &last_node->this_xyzintobj;

    /* Determine the addresses of the start point and the end point of this 
       sub group.
    */
    EMnode_endpts(msg, first_uv, &first_point_uv, NULL, GET_ADDR, 
		  elem_rev[i][m][0]);
    if(!(1&*msg)) goto wrapup;
    EMnode_endpts(msg, last_uv, NULL, &last_point_uv, GET_ADDR, 
                     elem_rev[i][m][num_elems_subgrp[i][m] - 1]);
    if(!(1&*msg)) goto wrapup;

    if(xyz_data)
     {
      EMnode_endpts(msg, first_xyz,&first_point_xyz, NULL, 
                                GET_ADDR, elem_rev[i][m][0]);
      if(!(1&*msg)) goto wrapup;
      EMnode_endpts(msg, last_xyz, NULL, &last_point_xyz, 
                                GET_ADDR, 
                                elem_rev[i][m][num_elems_subgrp[i][m] - 1]);
      if(!(1&*msg)) goto wrapup;
     }
     
    sts = EFvalidate_an_untrimmed_loop(surface, u_low, u_hig, v_low, v_hig,
                first_point_uv, last_point_uv, xyz_data, first_point_xyz,
                last_point_xyz, par_tol, par_tol_sq, model_tol_sq,
                &(*valid_group)[i][m],
                number_of_points ? number_of_points : &loc_num_pts,
/* MODIFIED FOLLOWING LINE FOR APOGEE - HAD TO EXPLICITLY TYPECAST POINTERS 
   TO (IGRdouble **) - Ashok */
                points ? (IGRdouble **) points : (IGRdouble **) &loc_points, msg);
    if (!sts) goto wrapup;

    /* Weight the poles back if the data was a rational curve.
    */
    if(first_uv->datatype == EMSdata_curve3d)
      EMnode_endpts(msg, first_uv, &first_point_uv, NULL, PUT_POINT, 
                        elem_rev[i][m][0]);
    if(last_uv->datatype == EMSdata_curve3d)
      EMnode_endpts(msg, last_uv, NULL, &last_point_uv, PUT_POINT, 
                        elem_rev[i][m][num_elems_subgrp[i][m] - 1]);
    if(xyz_data)
     {
      if(first_xyz->datatype == EMSdata_curve3d)
       EMnode_endpts(msg, first_xyz, &first_point_xyz, NULL, PUT_POINT, 
                          elem_rev[i][m][0]);
      if(last_xyz->datatype == EMSdata_curve3d)
       EMnode_endpts(msg, last_xyz, NULL, &last_point_xyz, PUT_POINT, 
                          elem_rev[i][m][num_elems_subgrp[i][m] - 1]);
     }
        
  } /* for (m = 0; m < num_subgrps_grp[i]; m++) */

 } /* for(i=0; i<num_grps; i++) */

wrapup:
    if(loc_points) free(loc_points);
    EMWRAPUP(*msg, sts, "In EMget_mapped_data - EMvalidate_pts");
    return(sts);
} 




/* This is a very special purpose function intended to be used by the functions
   in this file and created to avoid code duplication. It returns the 
   addresses of the begin and end points of the data represented by 
   EMSdataselect. For EMSdata_curve3d type data, it unweights the end points 
   and optionally weights them back, in place.
*/
static void EMnode_endpts(msg, indata, start_pts, stop_pts, option, reverse)
IGRlong                 *msg;
struct EMSdataselect    *indata;
IGRshort                option;
IGRdouble               **start_pts, **stop_pts;
IGRboolean              reverse;
{
  IGRint in_numpts, i;
  IGRdouble *in_pts, **start_loc, **stop_loc;
  struct IGRbsp_curve *cv;

  *msg = EMS_S_Success;
  if(reverse)
   {
     start_loc = stop_pts;
     stop_loc = start_pts;
   }
  else
   {
     start_loc = start_pts;
     stop_loc = stop_pts;
   }

  switch (indata->datatype)
   {
      case EMSdata_poly2d:
        if(option == GET_ADDR)
         {
           in_numpts = indata->data.poly->num_points;
           in_pts = indata->data.poly->points;
           if(start_loc) *start_loc = in_pts;
           if(stop_loc)  *stop_loc  = &in_pts[(in_numpts-1)*2];
         }
        break;

      case EMSdata_poly3d:
        if(option == GET_ADDR)
         {
           in_numpts = indata->data.poly->num_points;
           in_pts = indata->data.poly->points;
           if(start_loc) *start_loc = in_pts;
           if(stop_loc)  *stop_loc  = &in_pts[(in_numpts-1)*3];
         }
        break;
      
      case EMSdata_curve3d:
        cv = indata->data.curve;
        in_numpts = indata->data.curve->num_poles;
        in_pts = indata->data.curve->poles;
        if(option == GET_ADDR)
         {
           if(start_loc) *start_loc = in_pts;
           if(stop_loc)  *stop_loc  = &in_pts[(in_numpts-1)*3];

           if (cv->rational)
           for (i=0; i<3; i++)
            {
              if(start_loc) (*start_loc)[i] /= cv->weights[0];
              if(stop_loc)  (*stop_loc)[i] /= cv->weights[in_numpts-1];
            }
         }
        else if(option == PUT_POINT)
         {
           if (cv->rational)
           for (i=0; i<3; i++)
            {
              if(start_loc) (*start_loc)[i] *= cv->weights[0];
              if(stop_loc)  (*stop_loc)[i] *= cv->weights[in_numpts-1];
            }
         }
        break;

      default:
        *msg = EMS_E_InvalidArg;
   }

} 


end implementation GRvg;
