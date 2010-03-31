/*
 * This function will map a set of curves onto a composite surface and create
 * boundaries on it. The orientation is based on a track point, which will 
 * indicate the area side.  
 *     The imposition of the boundaries is done as a single-sided boolean and
 * an object of EMSsfboolean is created.
 *
 * The assumptions are:
 * 1. All curves to impose are in the same module environment.
 * 2. The collection of curves is consistently parametrized (all oriented in
 *    the same direction in model space).
 * 3. All curves MUST lie on the surfaces that they will eventually be
 *    mapped to.
 * 4. The subset of the curves that lie on a particular surface must 
 *    necessarily end on the boundaries on that surface.
 * 5. There is a point available for at least one subset to unambiguously
 *    designate the area side after trimming. This point MUST NOT lie on a 
 *    surface on which there no curves.
 * 6. Curves at split at boundaries, i.e. one single curve cannot span two
 *    different surfaces.
 * 7. The correspondence of each curve and the surface it is mapped to is 
 *    known.
 */

/*---------------------------- START ALGORITHM ------------------------------*/

/*

 Given below is a brief overview of the algorithm. Sufficient comments have been
 included in the code to give a good idea of the flow.


  - Get the surface with track point (input)

  - Rearrange the surface ids so that the track surface is FIRST in the array
    (because track sf. curves have to be oriented first and curves on other 
     surfaces will be oriented w.r.t. it)

  - FOR every surface:
      - Get all the curves that lie on this surface.

      - Create oriented edges on the surface using these curves.
        (using EMget_mapped_data()).

      - If this is the track surface (first surface), then:
          - do a pt locate with the track point to check the orientation.
          - If data need to be reversed
             - set track sf reverse bit to true
             - store track sf pos-orient bit (master bit) 

      - Check the pos-orient bit for this surface. 

      - If current pos-orient is OPPOSITE of master pos-orient (on track sf) 
           set reverse bit to complement of track sf reverse bit
        else
           set reverse bit to track sf reverse bit

      - FOR every edge created on this surface
          - Call EMmkintlist to create an intobj node for this edge and add it
            to the inters list
          - If this is first edge or last edge (since edges are created as part
            of a loop on the surface [in EMget_mapped_data], we only need to 
            look at the ends of the loop to get the incidence info)
               - call EMgetincedinfo() to create the EMSsfintedpar struct
                 for the ends of the intobj.
      - End FOR (edge)

  - End FOR (surface) 

- Trace the inters list using EMsfinttrace()

- Call boolean_surfaces_with_intersection to create DPR state

- Compress the DPR node to permanently impose boundaries on comp. surface

- Return the modified composite surface

*/

/*----------------------------- END ALGORITHM ------------------------------*/

class implementation Root;


/* includes */
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "ex.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "emsmapdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emserr.h"
#include "emsbool.h"

/* imports */
from GRvg	import	GRgetsize, GRgetgeom;
from EMSsubbs 	import  EMpartolbasis,EMgetbsdef;
from EMSloop    import  EMpt_location;
from EMSedge    import  EMpt_location;
from GRowner	import  GRget_number_components,GRget_components;
from EMSdpr	import  EMmake_primitive1;


/* externs */
extern GRclassid OPP_EMSsfboolean_class_id;
extern struct EMSsfintedpar *EMsfintedpar_malloc();
extern void EMsfintedpar_free();
extern struct EMSintobj *EMmkintlist();
extern IGRint EMget_mapped_data();
extern IGRboolean BSmdistptsf();
extern void EMgetincedinfo();
extern void EMsfinttrace();
extern IGRlong EMboolean_surfaces_w_intersection();
extern void EMSinters_free(), EMinters_data_free();

IGRlong EFmap_compcv_compsf(
EFmsg,		    /* Status code */
comp_sf,            /* GRid of composite surface or solid */
modenv_compsf,      /* module env. of composite surface or solid */
comp_cv,            /* GRid of composite curve */
modenv_compcv,      /* array of module environments of composite curves */
num_cvs_comp,       /* number of curves in composite */
curves,             /* array of individual curve ids */
surfaces,           /* surface ids that EVERY curve above maps to*/
track_pt,           /* XYZ points (MUST lie ON surf)for area-side orientation */
track_sf,           /* surface that track point lies on */
construct_list,
options,
map_options,
imp_options,
out_compsf   	    /* compsf. with boundary */
)
IGRlong			*EFmsg;
struct GRid		*comp_sf;
struct GRmd_env 	*modenv_compsf;
struct GRid		*comp_cv;
struct GRmd_env 	*modenv_compcv;
IGRint			num_cvs_comp;
GRobjid			*curves;
GRobjid			*surfaces;
IGRdouble		*track_pt;
GRobjid			track_sf;
struct GRvg_construct 	*construct_list;
IGRushort		options, map_options, imp_options;
GRobjid			*out_compsf;
{




IGRlong			sts, msg_loc;
IGRshort		location;
GRobjid			*map_sfs=NULL, curr_sf, *map_cvs=NULL, *cv_ids=NULL;
GRspacenum		thisos;
struct GRid		clip_ls; 
IGRboolean		found, track_sf_ed_rev, ed_rev;
IGRboolean		track_sf_pos_orient, pos_orient, in_world=TRUE;
IGRint			num_map_sfs, num_map_cvs, num_curves;
struct IGRbsp_surface	*sf_geom=NULL;
IGRlong			sf_size=0;
IGRmatrix		mat;
IGRshort		mattyp;
IGRdouble		u,v, min_dist, dist_from_edge;
IGRdouble		proj_track_pt[3], uvpt[2], xyztol;
OMuint			count, ed_count, num_edges;
OM_S_OBJECT_LINKAGE	ls_list, *ed_list=NULL;
OM_S_CHANSELECT		sf_ls_chan, to_comps_chan;
OM_S_CHANSELECT		compcv_to_cv_chan, cv_to_compcv_chan;
struct GRlc_info	*cv_obj_info=NULL;
struct EMSgetlp_output  out_loops, out_cvs;
struct EMSpartolbasis   sfpartol;
struct EMSptloc_info    ptloc_info;
GRobjid			nearest_edge;
IGRint			i,j,k;
struct EMSdataselect	edge_dataselect, xyz_cv_dataselect;
struct GRid		edge_grid, xyz_cv_grid, sf_grid, *cv_grids=NULL;
struct EMSintobj	*intobj=NULL;
struct EMSinters	*inters=NULL;
struct EMSsftracedata 	tracedata;
IGRboolean		sfinttrace_alloced=FALSE;
struct GRid		bool_grid;
IGRchar			status_str[100];
struct GRid		compressed_compsf;

sts     = OM_S_SUCCESS;
*EFmsg  = EMS_S_Success;

sts = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
EMerr_hndlr (!(1&sts),*EFmsg,EMS_E_OMerror,wrapup);

sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_comps_chan);
EMerr_hndlr (!(1&sts),*EFmsg,EMS_E_OMerror,wrapup);

sts = EMmake_chanselect (GRconnector_to_owners, &cv_to_compcv_chan);
EMerr_hndlr (!(1&sts),*EFmsg,EMS_E_OMerror,wrapup);

sts = EMmake_chanselect (GRcmpowner_to_components, &compcv_to_cv_chan);
EMerr_hndlr (!(1&sts),*EFmsg,EMS_E_OMerror,wrapup);

/* since the composite curve is to be imposed onto the composite surface, the
 * module environment in the construct list (used for creating the edges on the
 * composite surface) HAS to be the same as the module environment of the 
 * composite surface. Malloc memory for "construct_list->env_info" if 
 * necessary (should not happen, since caller is expected to provide valid mem.
 */
if (!(construct_list->env_info))
{  construct_list->env_info = (struct GRmd_env *)om$malloc ( size = 
                                               sizeof(struct GRmd_env));
   EMerr_hndlr(!(construct_list->env_info), *EFmsg, EMS_E_NoDynamicMemory, 
                                                                       wrapup);
}
OM_BLOCK_MOVE(modenv_compsf,construct_list->env_info,sizeof(struct GRmd_env)); 

thisos = construct_list->env_info->md_id.osnum;
mattyp = construct_list->env_info->md_env.matrix_type;
OM_BLOCK_MOVE((construct_list->env_info->md_env.matrix), (mat), 
                sizeof (IGRmatrix));

/*mat    = construct_list->env_info->md_env.matrix;*/

/* twice XYZ chord height tol is used for calc. end-info of edges on surface,
 */
BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, xyztol);
xyztol *= 2;

/* Error out if data invalid */
if (!num_cvs_comp || !track_pt )
   EMerr_hndlr (1, *EFmsg, EMS_E_InvalidArg, wrapup);

/* Allocate memeory for the array of surfaces that actually get mapped to.
 * (allocate stack memory for maximum number of possible surfaces in the 
 * composite. Since all curves are trimmed at boundaries, the max. number of
 * surfaces posssible is "num_cvs_comp", i.e. the number of curves in the comp)
 */

 map_sfs = (GRobjid *) alloca (num_cvs_comp * sizeof (GRobjid));

 /* Allocate stack memory for the "ed_list" struct array. This array is used
  * (&re-used) repeatedly while processing each surface. This array will hold
  * info about all edges pertaining to a particular loop. Basically,all 
  * mapped edges on a surface that are contiguous, are connected to a loop. 
  * Obviously, there might be more than one mapped loop on a surface, if there
  * are non-contiguous curves on the same surface.
  *   Allocate max. possible size.
  */

 ed_list = (OM_S_OBJECT_LINKAGE *) alloca (num_cvs_comp *
                                       sizeof(OM_S_OBJECT_LINKAGE) );
 /* memory for curves, maximum possible */
 cv_ids   = (GRobjid *) alloca (num_cvs_comp * sizeof (GRobjid));
 cv_grids = (struct GRid *)    alloca (num_cvs_comp * sizeof (struct GRid));


 /* find out how many different surfaces are to be mapped to */
 num_map_sfs=0;
 for (i=0; i<num_cvs_comp; i++)
 {   found=FALSE;
     for (j=0; j<num_map_sfs; j++)
     { if (map_sfs[j] == surfaces[i])
       {  found = TRUE;
          break;
       }
     } 
     if (!found)
       map_sfs[num_map_sfs++] = surfaces[i];
 }

/* push the surface with the track point to the top of this array */
found=FALSE;
for (i=0; i<num_map_sfs; i++)
{  
   if (map_sfs[i] == track_sf)
   {  /* switch places with first element in array */
      map_sfs[i] =  map_sfs[0];
      map_sfs[0] = track_sf;
      found      = TRUE;
   }
}
/* error out if track point is placed on a surface on which NO curves lie. This
 * is because then, we cannot orient the curves. 
 */
if (!found)
  EMerr_hndlr (1, *EFmsg, EMS_E_Fail, wrapup);


/* allocate an array to hold ids of curves to be mapped on a surface. This array
 * will get re-used for mapping to every surface. Allocate max. size.
 */
map_cvs = (GRobjid *) alloca (num_cvs_comp * sizeof (GRobjid));

/* allocate an array of struct GRlc_info structures. This structure will be used
 * to pass into "EMget_mapped_data" all the input curve objects to be mapped 
 * onto a particular surface.
 */

cv_obj_info= (struct GRlc_info *) alloca ((sizeof (struct GRlc_info)) *
                                     num_cvs_comp);


track_sf_ed_rev=FALSE;
track_sf_pos_orient=FALSE;
inters=NULL; /* no inters list on the composite surface exists */

/* do the following for every surface on which curves are to be mapped */

for (i=0; i<num_map_sfs; i++)
{
  curr_sf = map_sfs[i];
  sf_grid.objid = curr_sf;
  sf_grid.osnum = thisos;
  ed_rev  = FALSE; /* does not matter what this is initialized to */
  pos_orient = FALSE; /* does not matter what this is initialized to */

  /* get the parametric tolerance on this surface */

  sts = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                         &mattyp, mat, &in_world, FALSE, &(sfpartol.tol)),
               targetid = curr_sf, 
               targetos = thisos, 
               senderid = NULL_OBJID);
  EMerr_hndlr(!(msg_loc&sts&1), *EFmsg, msg_loc, wrapup);
  sfpartol.is_valid = TRUE;

  /* get size of surface geometry */
  sts = om$send(msg = message GRvg.GRgetsize(
                &msg_loc,
                &(modenv_compsf->md_env.matrix_type),
                modenv_compsf->md_env.matrix,
                &sf_size),
               senderid = NULL_OBJID,
               targetid = curr_sf,
               targetos = thisos);
  EMerr_hndlr(!(1&sts&msg_loc),*EFmsg,msg_loc,wrapup);

  /* allocate memory for surface geometry */
  sf_geom = (struct IGRbsp_surface *) om$malloc (size = sf_size);
  EMerr_hndlr(!sf_geom,*EFmsg,EMS_E_NoDynamicMemory,wrapup);

  /* Get the surface geometry.*/
  sts = om$send(msg = message GRvg.GRgetgeom(
                &msg_loc,
                &(modenv_compsf->md_env.matrix_type),
                modenv_compsf->md_env.matrix,
                (IGRchar *) sf_geom),
               senderid = NULL_OBJID,
               targetid = curr_sf,
               targetos = thisos);
  EMerr_hndlr(!(msg_loc&sts&1), *EFmsg, msg_loc, wrapup);


 
  /* get the id of the loopset on surface so that the curves can be clipped
   * against it while mapping.
   */
  sts = om$get_channel_objects (osnum=thisos,
                                objid=curr_sf,
                                p_chanselect=&sf_ls_chan,
                                list= &ls_list,
                                size=1,
                                count=&count);
  EMerr_hndlr (!(1&sts) || !count,*EFmsg,EMS_E_OMerror,wrapup);

  /* can add code to not error out above if the surface did not have a loopset,
   * instead, creating one for it.
   */
  clip_ls.objid= ls_list.S_objid; /* loopset on surface */
  clip_ls.osnum= thisos;  /** same as OS of composite surface ?? **/

  /* get all the curves to be mapped on to this surface */
  num_map_cvs=0; /* no.of curves being mapped on current sf.*/

  for (j=0; j<num_cvs_comp; j++)
  {  if (surfaces[j] == curr_sf)
       map_cvs [num_map_cvs++] = curves[j];   
  }

  /* create appropriate input structure for the curves */
  for (j=0; j<num_map_cvs; j++)
  {
    /*only these inputs are needed in the struct */
    cv_obj_info[j].located_obj.objid  = map_cvs [j];
    cv_obj_info[j].located_obj.osnum  = modenv_compcv->md_id.osnum;
    OM_BLOCK_MOVE ( modenv_compcv, &(cv_obj_info[j].module_info),
                                                  sizeof(struct GRmd_env) ); 
  } 
  /* Set "out_loops.objs" to NULL so that the function will allocate memory.
   * The loop objects created in this array are deleted at the end of this 
   * for loop (after disconnecting from their edge objects which are used in 
   * the inters lists).
   */
  out_loops.objs = NULL; 
  out_cvs.objs   = NULL; 

  /* create edges by mapping the curves onto the surface. The option 
   * "EMMapBnd_WantBadCurves" is needed because during mapping to special planes
   * a scaling is done for the poles and this allows the poles to fall outside
   * the surface bounds (however the curve MUST lie on the surface).
   */
  sts = EMget_mapped_data(
      num_map_cvs,   /* no. of curves to be mapped */
      NULL,         
      cv_obj_info,   /* curves on this surface*/
      construct_list, 
      sf_geom,
      NULL,          /* will be computed by function */
      modenv_compsf,
      NULL,          /* not intersted in outputting bad curves */
      NULL,          /* not interested in dangling data (should never happen) */
      &out_loops,    /* output: loops on surface (kinda like subgroups) */ 
      &out_cvs,       /* output: XYZ mapped curves */
      clip_ls,       /* loopset to clip against*/
      EMMapBnd_WantStatMsg | EMMapBnd_StrokeIfNeeded | EMMapBnd_RmvDegenCvs |
      EMMapBnd_WantBadCurves,
      NULL,          /* no planar info needed */
      &msg_loc
      );
  EMerr_hndlr(!(msg_loc&sts&1), *EFmsg, msg_loc, wrapup);

  /* since degenerate curves are removed during mapping, we now have to depend
   * on edges returned and ignoring the input curve arrays from now on.
   */ 

  /* The surface with the track point has been ensured to come in FIRST. It
   * gets handled first, so that edges on other surfaces can get oriented with
   * respect to this surface.
   */

   if (curr_sf == track_sf)
   {
     /* project track pt. onto surface just to make sure it lies on surface*/
    sts = BSmdistptsf( (BSrc *)&msg_loc, sf_geom, track_pt, &u,&v, 
                       proj_track_pt, &min_dist);
    EMerr_hndlr (!(sts&1) || BSERROR(msg_loc), *EFmsg, EMS_E_BSerror, wrapup);

    /* pt location needs a UV point */
    uvpt[0] = u;
    uvpt[1] = v;
    
    /* do a point location on the each of the output loops above in "out_loops"
     * and find out which is the nearest edge to the input point. If that edge
     * has the point to its left, then all the edges on this surface have to 
     * be reversed in orientation, else not.
     */

    min_dist         = MAXDOUBLE;
    nearest_edge     = NULL_OBJID;
    location         = EMS_L_UNKNWN;

    for (j=0; j<out_loops.num_objs; j++)
    {
      ptloc_info.options =  EMS_PTLOC_CLOSEST_EDGE;
      ptloc_info.location = EMS_L_UNKNWN;

      /* For an open loop on the surface, and if the track point does not lie
       * on any edge or any vertex of the loop (and it should'nt), the method 
       * will likely return an "EMS_I_NoSolution" return code. This is alright 
       * with us, since the nearest edge and the orientation of the point (right
       * or left) with respect to that edge will still be returned in 
       * "ptloc_info".
       */
      sts=om$send (msg = message EMSloop.EMpt_location (&msg_loc, uvpt,
                           &ptloc_info, &sfpartol),
                   senderid 	= NULL_OBJID,
   		   targetid 	= out_loops.objs[j],
                   targetos     = thisos);
      EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_EdgeError, wrapup);


      dist_from_edge   = ptloc_info.edge[0].nst_pt.dist;
      location         = ptloc_info.location;
      
      if ((dist_from_edge < min_dist) && 
            ( (location == EMS_L_RIGHT) || (location == EMS_L_LEFT)) )
      { min_dist = dist_from_edge;
        nearest_edge = ptloc_info.edge[0].edge_id;
      }
    }/*for, j*/ 

    if (((location != EMS_L_RIGHT) && (location != EMS_L_LEFT))  
                || (nearest_edge == NULL_OBJID) ) 
    {   *EFmsg = EMS_E_Fail;
        goto wrapup;
    }

    /* now send a point location message to the nearest edge to find out if
     * the point is on the LEFT or RIGHT of the edge, which implies that the
     * edge (and hence the loop) has to be REVERSED or NOT REVERSED.
     */

    ptloc_info.location = EMS_L_UNKNWN;

    sts = om$send(msg = message EMSedge.EMpt_location
                            (&msg_loc,uvpt,&ptloc_info,NULL,&sfpartol),
                   senderid     = NULL_OBJID,
                   targetid     = nearest_edge,
                   targetos     = thisos);
    EMerr_hndlr(!(1&sts&msg_loc),*EFmsg,EMS_E_EdgeError,wrapup);

    if ( (ptloc_info.location != EMS_L_RIGHT) && 
         (ptloc_info.location != EMS_L_LEFT) )
    {  /* error, since nearest edge not orientable */
       *EFmsg = EMS_E_EdgeError;
       goto wrapup;
    } 

    if (location == EMS_L_LEFT)
       track_sf_ed_rev = TRUE;

    /* also set info about track surface pos orient bit */
    track_sf_pos_orient = sf_geom->pos_orient;

   }
   else
   {
     /* all other surfaces except track surface */

     pos_orient = sf_geom->pos_orient;

     if (pos_orient != track_sf_pos_orient)
        ed_rev = !track_sf_ed_rev;
     else
        ed_rev = track_sf_ed_rev; 
   }

   /* At this time we have loops created on this surface. Each loop may have
    * any number of edges. We convert all edges into dataselects.
    */


    
    for (j=0; j<(out_loops.num_objs); j++)
    { /* get all edges of the loop */

      sts = om$get_channel_count( objid=out_loops.objs[j],
                                  osnum=thisos,
                                  p_chanselect=&to_comps_chan,
                                  count=&ed_count );
      EMerr_hndlr (!(1&sts) || !ed_count,*EFmsg,EMS_E_OMerror,wrapup); 

      sts = om$get_channel_objects (objid=(out_loops.objs[j]),
 				    osnum=thisos,
                                    p_chanselect=&to_comps_chan,
                                    list= ed_list,
                                    size=ed_count, 
                                    count=&num_edges);
      EMerr_hndlr (!(1&sts) || !num_edges || (num_edges != ed_count),
                                                 *EFmsg,EMS_E_OMerror,wrapup); 
      
      /* Get XYZ curve objects corresponding to the edges. Struct "out_cvs" is 
       * very similar to the "out_loops" structs. i.e. every loop in "out_loops"
       * corresponds to a composite curve in "out_cvs". However, for loops with 
       * only ONE edge, corresponding element is a curve and not a composite 
       * curve. Example (L=loop, E=edge, CC=comp cv, C=curve) : Consider the 
       * output of the following three loops:
       * L1 (E1 E2 E3) L2 (E4 E5) & L3 (E6).
       *      Corrresponding "out_cvs" entries are,
       * CC1 (C1 C2 C3) CC2 (C4 C5) & C6
       */
       if (num_edges > 1)
       {
         sts = om$send (msg = message GRowner.GRget_number_components (&msg_loc,
                                               &num_curves),
                          targetid = out_cvs.objs[j],
                          targetos = thisos,
                          senderid = NULL_OBJID);
         EMerr_hndlr (!(1&sts), *EFmsg,EMS_E_OMerror,wrapup); 
         EMerr_hndlr (num_curves!=num_edges, *EFmsg,EMS_E_Fail,wrapup); 
        
         /* get the ids of the model space curves (pass num_edges as the
          * max. number of curves on this composite, since num_curves 
          * has to be separately passed).
          */
         sts = om$send (msg = message GRowner.GRget_components (&msg_loc,
                          modenv_compcv, cv_grids, num_edges, 
                          &num_curves, 0, num_edges-1),
			  targetid = out_cvs.objs[j],
                          targetos = thisos,
                          senderid = NULL_OBJID);
         EMerr_hndlr (!(1&sts), *EFmsg,EMS_E_OMerror,wrapup);
         EMerr_hndlr (num_curves!=num_edges, *EFmsg,EMS_E_Fail,wrapup); 

         for (k=0; k<num_curves; k++)
           cv_ids[k] = cv_grids[k].objid;
          
       }
       else /* ==> loop with one edge ==> no comp. cv */
          cv_ids[0] = out_cvs.objs[j];
         
 
      for (k=0; k<num_edges; k++)
      {  /* put edge and XYZ curve in dataselect format */
         edge_grid.objid 		= ed_list[k].S_objid;
         edge_grid.osnum 		= thisos;

         edge_dataselect.datatype  	= EMSdata_object;
         edge_dataselect.data.object    = NULL;
         edge_dataselect.data.object    = 
                      (struct GRid *) om$malloc (size = sizeof (struct GRid));
         EMerr_hndlr (!(edge_dataselect.data.object), *EFmsg, 
                                               EMS_E_NoDynamicMemory, wrapup);
         edge_dataselect.data.object->objid	= edge_grid.objid;
         edge_dataselect.data.object->osnum	= edge_grid.osnum;

         xyz_cv_grid.objid 		= cv_ids[k];
         xyz_cv_grid.osnum 		= thisos;

         xyz_cv_dataselect.datatype 	= EMSdata_object;
         xyz_cv_dataselect.data.object  = NULL;
         xyz_cv_dataselect.data.object  = 
                      (struct GRid *) om$malloc (size = sizeof (struct GRid));
         EMerr_hndlr (!(xyz_cv_dataselect.data.object), *EFmsg, 
                                               EMS_E_NoDynamicMemory, wrapup);

         xyz_cv_dataselect.data.object->objid = xyz_cv_grid.objid;
         xyz_cv_dataselect.data.object->osnum = xyz_cv_grid.osnum;

         /* call EMmkintlist() to create an intobj node for this edge */
         intobj = NULL;
         intobj = EMmkintlist (&msg_loc, 
                               &inters,NULL,
                               &sf_grid,NULL,
                               NULL, NULL,
                               NULL, NULL,
                               &xyz_cv_dataselect,
                               &edge_dataselect,NULL,
                               (curr_sf==track_sf)?track_sf_ed_rev:ed_rev,NULL,
                               NULL, NULL,
                               NULL, NULL,
                               TRUE, FALSE); 
                               

         /* If first or last edge in loop, get its end-info */
         if (k==0 || k==(num_edges-1))
         {  /* This edge has one/both end(s) lying on a boundary. Update the 
             * "more_info" in the "intobj" struct for the edge.
             */

             /* malloc memory for the EMSsfintedpar structure (2 nodes)*/
             intobj->more_info = 
                       (IGRchar *)EMsfintedpar_malloc (&msg_loc, 2);
             EMerr_hndlr (!(1&msg_loc) || !(intobj->more_info),
                                               *EFmsg, msg_loc, wrapup); 
            
             /* get sfintedpar info about start point of edge */
             EMgetincedinfo (&msg_loc, thisos, edge_grid.objid, FALSE, NULL, 
                             &mattyp, mat, curr_sf, xyztol, sfpartol.tol,
                             (struct EMSsfintedpar *)(intobj->more_info));

             EMerr_hndlr (!(msg_loc&1), *EFmsg, msg_loc, wrapup);

             /* get sfintedpar info about stop point of edge */
             EMgetincedinfo (&msg_loc, thisos, edge_grid.objid, TRUE, NULL, 
                             &mattyp, mat, curr_sf, xyztol, sfpartol.tol,
                      ((struct EMSsfintedpar *)(intobj->more_info))->next);

             EMerr_hndlr (!(msg_loc&1), *EFmsg, msg_loc, wrapup);
         }

      }/* for, k */  


      /* now delete the loop object after doing a wild-disconnect on its 
       * channels. This is so as to not delete the edges that are now part
       * of the inters lists. Similarly we need to delete the composite 
       * curve (its component curves are used in the inters list and hence not
       * deletable).
       */

       sts = om$send (msg = message Root.wild_disconnect(to_comps_chan),
                                targetid = out_loops.objs[j],
                                targetos = thisos,
                                senderid = NULL_OBJID);
       EMerr_hndlr (!(1&sts) ,*EFmsg, EMS_E_OMerror, wrapup); 

       /* now delete the loop (it is not connected to any loopset and neither
        * does it have any inner loops) 
        */
       sts = om$send (msg = message Root.delete(1), 
                         targetid = out_loops.objs[j],
                         targetos = thisos,
                         senderid = NULL_OBJID);
       EMerr_hndlr (!(1&sts) ,*EFmsg, EMS_E_OMerror, wrapup); 


       /* Do the same thing with the composite curve (composite curve is
        * produced ONLY if the number of curves is > 1).
        */

        if (num_edges > 1)
        { sts = om$send (msg = message Root.wild_disconnect(compcv_to_cv_chan),
                                targetid = out_cvs.objs[j],
                                targetos = thisos,
                                senderid = NULL_OBJID);
          EMerr_hndlr (!(1&sts) ,*EFmsg, EMS_E_OMerror, wrapup);

          sts = om$send (msg = message Root.delete(1),
                         targetid = out_cvs.objs[j],
                         targetos = thisos,
                         senderid = NULL_OBJID);
          EMerr_hndlr (!(1&sts) ,*EFmsg, EMS_E_OMerror, wrapup);

        }

    }/*for, j*/

    loc_wrapup:
       /* free surface geometry */
       if (sf_geom)
       { om$dealloc(ptr = sf_geom); 
         sf_geom = NULL;
       }
}/*for i*/


/* At this point we have a inters list on the composite surface, just as if it
 * was created by surface-surface intersection. We trace the inters list to 
 * establish contiguity and prepare input for validation and the rest of the 
 * boolean.
 */

/* Initialize pointers*/

tracedata.num_grps = 0;
tracedata.num_subgrps_grp = NULL;
tracedata.num_elems_subgrp = NULL;
tracedata.elems = NULL;
tracedata.subgrp_rev = NULL;
tracedata.elem_rev = NULL;
tracedata.grp_closed = NULL;
tracedata.subgrp_closed = NULL;

EMsfinttrace (&msg_loc, &mattyp, mat, inters, NULL, &xyztol,
     &(tracedata.num_grps), 
     &(tracedata.num_subgrps_grp), 
     &(tracedata.num_elems_subgrp),
     &(tracedata.elems), 
     &(tracedata.subgrp_rev), 
     &(tracedata.elem_rev),
     &(tracedata.grp_closed), 
     &(tracedata.subgrp_closed) );
sfinttrace_alloced=TRUE; /* free trace memory later only if this flag is true */
EMerr_hndlr (!(1&msg_loc), *EFmsg, msg_loc, wrapup);


/* construct a dpr object. Malloc the memory for boolean if it is to be
 * returned to the calling function.
 */
bool_grid.osnum = thisos;
sts = om$construct(
             classid = OPP_EMSsfboolean_class_id,
             p_objid = &(bool_grid.objid),
             osnum   = thisos);
EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);


/* call EMboolean_surafces_w_intersection() to create a one-sided boolean on
 * the composite surface.
 */
strcpy (status_str, "Processing.");

sts = EMboolean_surfaces_w_intersection (&msg_loc, &bool_grid, EMSbool_union,
               modenv_compsf, comp_sf->objid, 0, NULL,
               inters, NULL,
               &tracedata,NULL,
               NULL, NULL,
               EMSsfbool_opt_display,
               NULL, NULL, status_str);
EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
               
/* Delete the boolean node (IF reqd)and return the modified composite surface.
 * Later, provide an option to return the dpr object back instead of 
 * permanently changing the input composite surface.
 */

/*
sts = om$send (msg = message EMSdpr.EMmake_primitive1 (&msg_loc,
                                modenv_compsf, &compressed_compsf),
                          targetid = bool_grid.objid,
                          targetos = bool_grid.osnum,
                          senderid = NULL_OBJID);
EMerr_hndlr (!(1&sts) ,*EFmsg, EMS_E_OMerror, wrapup);
*/

*out_compsf = compressed_compsf.objid;  /* output changed composite sf */

wrapup:

/* free trace data */
if (sfinttrace_alloced)
{
   EMsfinttrace_free (&msg_loc, 
      tracedata.num_grps, tracedata.num_subgrps_grp, tracedata.num_elems_subgrp,
      tracedata.elems, tracedata.subgrp_rev, tracedata.elem_rev,
      tracedata.grp_closed, tracedata.subgrp_closed);
}

/* free inters list */
if (inters)
{
  EMinters_data_free(&msg_loc, inters, MAXINT, NULL, EMsfintedpar_free);
  EMinters_free(inters, MAXINT);
}

EMWRAPUP(*EFmsg, sts, "In EFmap_compcv_compsf");

return (sts); 

}/* END of EFmap_comcv_compsf()*/


end implementation Root;
