class implementation Root;

/*
  DESCRIPTION

    The following function checks for intersections that lie along existing
    edges and which if used in an impose boundary type operation may cause
    degenerate regions with coincident edges to be produced. If such edges
    are found it will try and push these across to the common edge if one
    exists, thus causing the boundary to be imposed on the adjacent surface
    without producing the coincident edge.

    This function will wipe out the EMSintobj_marked bit from the props
    field of every EMSintobj.

  BUGS

    For now only EMSdumedge is looked for (produced by coincident plane
    operation).

  HISTORY

    SS  :  10/19/89  :  Creation
    NP  :  10/29/91  :  Modifications to handle "sliver" problem, i.e.
                        degerate portions of a loop. Formerly code handled
                        only "dummy" edges, but now also handles cases which 
                        are not "dummy" edges.
    NP  :  12/12/91  :	Enhanced sliver code to handle closed coincident edges,
                        which include cases such as: 
                           - closed intersection coinciding with closed edge 
                           - non-closed intersection coinciding with a closed 
                             edge such that the end-pt of the closed edge lies
                             on the intersection.
    NP  :  01/31/92  :  In evaluating the point where the intobj is to be split
                        (in the case of closed edges), do not use the  
                        uv endpts of the closed edge along with EMpratpt to get
                        the split parameter on the intobj. PROJECT the 
                        uv endpts of the closed edge onto the intobj.
  inasu :  02/17/92  :  Changed EFsplit_intobj() to EMsplit_intobj().
   NP  :  03/12/92   :  Check for coincidence of a "non-dummy edge" intobj is 
                        done ONLY if the intobj has a non-NULL "more_info" 
                        pointer, which points to the edges it is incident on.
    SS  : 04/29/92   :  Changed EMsplit_intobj EMsplit_sfintobj_uv
    SS  : 06/29/92   :  Fixed TR 90N3141 as part of training exercise.
    NR  : 07/30/92   :  Changed EMsplit_sfintobj_uv to  EMsplit_sf_intobj_uv
    NR  : 07/30/92   :  changed EMpushcoined() to EMpush_coined().
    NR  : 08/20/92   :  changed EMpush_coined() to EMpush_coinc_ed().
    NR  : 10/29/92   :  changed EMpush_coinc_ed() to EMpush_coinc_edges().
    SM  : 01/27/93   :  argument change to EMpushtocommon. See the source
                        file src_bound/imped/EMedsfintdat.I
    NP  : 3/22/93    :  UV values were being mistakenly passed in for the XYZ 
                        split point information into "EMsplit_sf_intobj_uv".
   Jack : 04/22/93   :  Added code to deallocate the poles, knots, and weights
                        of edge_geom_xyz.  Also initialized temp_fedge = NULL_OBJID
                        to fix an uninitialized memory read(umr). (Purify)
   Jack : 06/02/93   :  Added code to deallocate "is_rightend" before it is reset
                        to point to the preallocated memory.  Purify memory leak fix.

 Sanjay : 04/04/95   :  Initialized partolbasis in the main function. Fixed an 
                        ABR which was occuring in "EMnon_planar_coinc_proc".
                        Fix for TR# 119524813 (Make Thinwall Solid).
*/


%safe
#include <math.h>
%endsafe
#include "EMS.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "EMS.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSopt.h"
#include "EMSbnd.h"
#include "EMSprop.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsinterdef.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsedgedef.h"
#include "bserr.h"
#include "bsparameters.h"

#define FIRST  0
#define SECOND 1

#define START  0
#define STOP   1

/*
 * Possible maximum number of edges that share a vertex. Used in finding all
 * the edges that surround a vertex. (needed in "EMpushcoined" function)
 */

#define MAX_EDGES_PER_VERTEX 6

#define EMerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSdumedge_class_id;

from EMSpartedge import EMpeinit;
from EMSedge import EMgetvtxedges, EMget_props, EMreverse, EMendpts;
from EMSedge import EMinternalpt, EMpratpt, EMchkconvex;
from EMSedge import EMget_bcxyz_geom, EMptproject, EMget_props_type;
from EMSloop import EMget_props;
from EMSloopset import EMpt_location;
from EMSboundary import EMgetsurface_info;
from EMSsubbs import EMpratmpt, EMpassloop;
from EMSsubbs import GRptproject;
from GRvg import GRgetgeom, GRgetsize;

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif
IGRlong EMpush_coinc_edges (msg, inters, modenv, altxyztol, num_samplepts,
                      checkthese, options, nummarked, numchged, check,
                      operate, 
                  push_coinc_list, delete_list, num_push_coinc, num_del,
                  push_coinc_list_2, delete_list_2, num_push_coinc_2, num_del_2)
IGRlong *msg;
struct EMSinters **inters;
struct GRmdenv_info *modenv;
IGRdouble *altxyztol;
IGRint num_samplepts;
IGRushort checkthese, options;
IGRint *nummarked, *numchged;
IGRboolean *check, *operate;
struct GRid **push_coinc_list, **delete_list;
struct GRid **push_coinc_list_2, **delete_list_2;
IGRint *num_push_coinc, *num_push_coinc_2,  *num_del, *num_del_2;
{
        /* added for sliver check */
  struct EMSedgebound start_param, end_param;
  IGRboolean edge_closed;
  IGRboolean dummy_edge; 
  IGRboolean edge_endpt_lies_on_intobj_middle, found_edge;
  struct EMSpypoint *projected_pts, *projected_pts_buffer;
  IGRdouble *internal_pts, *internal_pts_buffer, *mindist, *mindist_buffer; 
  IGRdouble intobj_pts_uv[4];
  struct EMSdataselect edge_ingeom;
  IGRdouble xyz_chd_ht;
  struct IGRbsp_curve edge_geom_xyz; 
  struct EMSsfintedpar *intobj_start, *intobj_end;
  GRobjid coincident_edgeid;
  struct EMSproj_info edge_proj_info[2]; /* proj. of intobj endpts onto edge */
  IGRushort get_coinc_edge_opt;
  IGRint  i,j, num_edges_start, num_edges_end;
  GRobjid *intobj_start_edges, *intobj_end_edges;
  GRobjid *intobj_start_edges_buffer, *intobj_end_edges_buffer;
  IGRboolean *is_rightend, *is_rightend_buffer; 
  IGRboolean edge_int_at_rt_vtx, intobj_coinc_with_edge;
  GRobjid likely_coincident_edgeid[MAX_EDGES_PER_VERTEX];
  IGRint npce, edg;
  IGRdouble start_pt[3], stop_pt[3];
        /* added for sliver check */

  IGRboolean has_actloop, bad_coincidence, reversed1, reversed2, degenerate;
  IGRuchar cctype;
  IGRushort lpprops, fprops, dprops;
  IGRushort drev, frev, cintprops, bit_mask;
  IGRint count, owncount, commed_exists;
  IGRlong msg_loc, stat_OM, sts;
  IGRdouble lentol, chttol, tolfactor;
  GRclassid intedclass;
  GRspacenum os;
  GRobjid temp_fedge=NULL_OBJID, fedge=NULL_OBJID, cedge=NULL_OBJID, dedge=NULL_OBJID;
  IGRlong size;
  struct IGRbsp_surface *surface;
  struct GRid *intedid, csfid;
  struct EMSinters *inters_loc;
  struct EMSintobj *intobj_loc, *intobj_loc_next, *other_intobj, *new_intobj;
  struct EMSpartolbasis ptolbas;
  struct EMSdataselect cdata, cintdata;
  struct EMSsfintedpar *cincparms;
  OM_S_CHANSELECT chan_to_fulled, chan_to_loops, chan_to_commed;
  OM_S_OBJECT_LINKAGE objlist;

  extern void EMdelintobj(), EMcmpinters(), EMdataselect_data_free();
  extern void EMsfintedpar_free();
  extern IGRlong EMpushtocommon_mod(), EMmkintdata();
  extern struct EMSintobj *EMmakeintlist();

  IGRboolean    surfs_are_non_planar_coinc=FALSE, go_ahead_push = TRUE,
                 if_nonpln_coinc_int_del_then_process = FALSE;
  IGRint me_surf_id, other_surf_id, ku;
  struct GRid this_surf_grid;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
 
  *nummarked = 0;
  *numchged = 0;

  /*
   * Initialize local variables
   */

  cdata.datatype = EMSdata_null;
  cdata.data.object = NULL;
  cintdata.datatype = EMSdata_null;
  cintdata.data.object = NULL;
  cincparms = NULL;

  edge_geom_xyz.poles   = NULL;
  edge_geom_xyz.knots   = NULL;
  edge_geom_xyz.weights = NULL;

  ptolbas.is_valid = FALSE; 
  ptolbas.in_world = FALSE;
  ptolbas.mattyp   = &(modenv->matrix_type);
  ptolbas.mat      = modenv->matrix;

  stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_fulled);
  EMerr_exit (stat_OM, ret_end);

  stat_OM = EMmake_chanselect (EMSedge_to_owner, &chan_to_loops);
  EMerr_exit (stat_OM, ret_end);

  stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &chan_to_commed);
  EMerr_exit (stat_OM, ret_end);

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
  tolfactor = chttol / lentol;

  /*
   * Wipe out the EMSintobj_marked bit, so that this can be locally
   * used here.
   */

  inters_loc = *inters;
  while (inters_loc)
    {
    intobj_loc = inters_loc->cvs;
    while (intobj_loc)
      {
      intobj_loc->props &= ~EMSintobj_marked;
      intobj_loc = intobj_loc->next;
      }
    inters_loc = inters_loc->next;
    }

  /* Set the xyz tolerance for point-point coincidence check to be done 
   * below. Use the value passed in, or if null, get the current chord ht
   * tolerance.
   */
    
   if (altxyztol)
	xyz_chd_ht = *altxyztol;
   else 
	BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, xyz_chd_ht);
  /*
   * Locate any "bad" coincidences and push them across if possible. On
   * succeeding, mark this new intersection so that it may not be accidentally
   * picked up again and send this whole thing into an infinite loop.
   */
   
   /* The foll. buffers are used to temporarily store lists of edges to
    * check for a possible coincident edge with the intobj. These will ONLY be
    * made use of, if the intobj is NOT a dummy edge. Re-used for every intobj.
    */
   intobj_start_edges_buffer = (GRobjid *)alloca(MAX_EDGES_PER_VERTEX 
							* sizeof (GRobjid));
   if (intobj_start_edges_buffer == NULL)
	om$report_error (sts = OM_E_NODYNMEM);

   intobj_end_edges_buffer   = (GRobjid *)alloca(MAX_EDGES_PER_VERTEX 
							* sizeof (GRobjid));
   if (intobj_end_edges_buffer == NULL)
        om$report_error (sts = OM_E_NODYNMEM);

   is_rightend_buffer        = (IGRboolean *)alloca(MAX_EDGES_PER_VERTEX
							* sizeof(IGRboolean));
   if (is_rightend_buffer == NULL)
        om$report_error (sts = OM_E_NODYNMEM);

   /* The following buffers are used in projecting internal points of the
    * intobj onto the coincident  edge. They are re-used for every intobj. 
    * In addition, the "projected_pts" buffer needs to be in a linked list
    * format for the EMprojectpt function to work. Again, used only if the 
    * intobj is NOT a dummy edge.
    */
   internal_pts_buffer 	     = (IGRdouble *) alloca (num_samplepts * 3 *
						sizeof (IGRdouble));
   if (internal_pts_buffer == NULL)
        om$report_error (sts = OM_E_NODYNMEM);

   mindist_buffer 	     = (IGRdouble *) alloca (num_samplepts * 
						sizeof (IGRdouble));
   if (mindist_buffer == NULL)
        om$report_error (sts = OM_E_NODYNMEM);

   projected_pts_buffer      = (struct EMSpypoint *) alloca ( num_samplepts * 
						sizeof(struct EMSpypoint));
   if (projected_pts_buffer == NULL)
        om$report_error (sts = OM_E_NODYNMEM);

   for (i=0; i<num_samplepts-1; i++)
	(projected_pts_buffer+i)->next = projected_pts_buffer+i+1;
   (projected_pts_buffer+num_samplepts-1)->next = NULL;


  inters_loc = *inters;
  while (inters_loc)
    {
    intobj_loc = inters_loc->cvs;
    while (intobj_loc)
      {
      intobj_loc_next = intobj_loc->next;

  if(*check)
  {
    if( (*num_push_coinc == 0) && (!push_coinc_list[0] || !push_coinc_list[1]))
     {
      push_coinc_list[0] =
              (struct GRid *)om$malloc(size = 20 * sizeof(struct GRid));
      EMerr_hndlr ( !push_coinc_list[0], *msg, EMS_E_NoDynamicMemory, ret_end); 
      push_coinc_list[1] =
              (struct GRid *)om$malloc(size = 20 * sizeof(struct GRid));
      EMerr_hndlr ( !push_coinc_list[1], *msg, EMS_E_NoDynamicMemory, ret_end); 
     }
    else if(*num_push_coinc >= 20)
     {
      push_coinc_list[0] =
         (struct GRid *)om$realloc( ptr = (char *) push_coinc_list[0],
                          size = (*num_push_coinc+1) * sizeof(struct GRid));
      EMerr_hndlr ( !push_coinc_list[0], *msg, EMS_E_NoDynamicMemory, ret_end); 

      push_coinc_list[1] = 
         (struct GRid *)om$realloc(ptr = (char *) push_coinc_list[1],
                          size = (*num_push_coinc+1) * sizeof(struct GRid));
      EMerr_hndlr ( !push_coinc_list[1], *msg, EMS_E_NoDynamicMemory, ret_end); 
     }

    if( (*num_del == 0) && (!delete_list[0] || !delete_list[1]))
     {
      delete_list[0]=(struct GRid *)om$malloc(size = 20 * sizeof(struct GRid));
      EMerr_hndlr ( !delete_list[0], *msg, EMS_E_NoDynamicMemory, ret_end); 
      delete_list[1]=(struct GRid *)om$malloc(size = 20 * sizeof(struct GRid));
      EMerr_hndlr ( !delete_list[1], *msg, EMS_E_NoDynamicMemory, ret_end); 
     }
    else if(*num_del >= 20)
     {
      delete_list[0] = (struct GRid *)om$realloc(ptr=  (char *) delete_list[0],
                                     size = (*num_del+1) * sizeof(struct GRid));
      EMerr_hndlr ( !delete_list[0], *msg, EMS_E_NoDynamicMemory, ret_end); 
      delete_list[1] = (struct GRid *)om$realloc(ptr=  (char *) delete_list[1],
                                     size = (*num_del+1) * sizeof(struct GRid));
      EMerr_hndlr ( !delete_list[1], *msg, EMS_E_NoDynamicMemory, ret_end); 
     }
   }
      bad_coincidence = FALSE; /* assume at start, for this intobj */
      dummy_edge = FALSE; /* assume that intobj is not of type dummy edge */


      /*
       * Determine coincidence with existing edge. First, check if the
       * edge is not marked "processed". Then check if the intersection 
       * is an object. If both are true, the interesection edge class is
       * FIRST checked if it is a EMSdumedge (i.e. if the intersection is 
       * a "dummy edge"), and if so,  if it's full-edge belongs to an
       * active loop and if it has a common edge and if it flows opposite to
       * the dum-edge. If this is TRUE, then the push operation needs to be
       * performed. ELSE, check if the intersection (which we know
       * now is NOT a dummy edge) coincides anyway with an edge on the surface.
       * If so, it is checked if the edge flows opposite to the intersection 
       * and if it does, the push operation needs to be performed. 
       */
   
      if (! (intobj_loc->props & EMSintobj_marked))
        {
        if (intobj_loc->this_uvintobj.datatype == EMSdata_object)
          {
          intedid = intobj_loc->this_uvintobj.data.object;
          os = intedid->osnum;

          stat_OM = om$get_classid (objid = intedid->objid, osnum = os,
                     p_classid = &intedclass);
          EMerr_exit (stat_OM, Next);

	  /*if the "intobj" edge is a dummy edge, it has to be pushed across*/

          if (intedclass == OPP_EMSdumedge_class_id)
	  {
		dummy_edge = TRUE; /** intobj is of type dummy edge **/
	  }

          if (dummy_edge)
            {
            dedge = intedid->objid;
            stat_OM = om$get_channel_objects (objid = dedge, osnum = os,
                       p_chanselect = &chan_to_fulled, list = &objlist,
                       size = 1, count = (OMuint *)&count);
            EMerr_exit (stat_OM, Next);

            fedge = objlist.S_objid;
            stat_OM = om$get_channel_count (objid = fedge, osnum = os,
                       p_chanselect = &chan_to_loops, count = (OMuint *)&owncount);
            EMerr_exit (stat_OM, Next);

            has_actloop = FALSE;
            for (i=0; i<owncount; i++)
              {
              stat_OM = om$send (msg = message EMSloop.EMget_props (&msg_loc,
                         &lpprops), senderid = fedge, targetos = os,
                         from = i, to = i, p_chanselect = &chan_to_loops);
              if (EMSerror (stat_OM))
                continue;

              if (lpprops & EMLP_ACTIVE)
                {
                has_actloop = TRUE;
                break;
                }
              }

            if (has_actloop)
              {
              stat_OM = om$get_channel_objects (objid = fedge, osnum = os,
                         p_chanselect = &chan_to_commed, list = &objlist,
                         size = 1, count = (OMuint *)&commed_exists);
              EMerr_exit (stat_OM, Next);

              if (commed_exists)
                {
                cedge = objlist.S_objid;

                stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc,
                           &dprops), targetid = dedge, targetos = os,
                           senderid = NULL_OBJID);
                EMerr_exit (stat_OM, Next);

                stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc,
                           &fprops), targetid = fedge, targetos = os,
                           senderid = NULL_OBJID);
                EMerr_exit (stat_OM, Next);

                drev = (dprops & EMED_REVERSED ? TRUE : FALSE) ^
                       (intobj_loc->reversed ? TRUE : FALSE);
                frev = (fprops & EMED_REVERSED ? TRUE : FALSE);

                if (drev ^ frev)
                  bad_coincidence = TRUE;
                }
              }
            }

	/* If the intobj is NOT a dummy edge, then it is checked anyway
	 * for coincidence with an edge on the surface with which it 
	 * forms a degenerate portion of a loop (sliver). To check for such
	 * slivers, the following algorithm is used:
	 *
	 * Get a list of all edges with which the intobj is PROBABLY 
	 * coincident.
	 *	(If the intobj coincides with an edge such that at least one
	 *	endpoint coincides, then the SFintedpar structure for the intobj
 	 *	will not always point to the coincident edge, but could also 
	 *	point to any other edge that is coincident at that point.
	 *	So, get  lists of edges that the intobj is coincident with at 
	 *	either end and look for edges that are common to both lists.)
	 *
	 * FOR (EVERY probable coincident edge)
	 *	Project "num_samplepts" number of internal points of the 	
	 *	intobj onto the edge in Model Space (xyz) and check if they
	 *	coincide.
	 *
	 *      IF [fully coincides] (it means this edge fully coincides with 
	 *	   the intobj keeping in mind that "full" coincidence is based 
	 *	   on "num_samplepts" internal points only).
	 *
	 *	   IF   the edge is closed and its end-points lie on 
	 *	   	the intobj, the intobj needs to be split into two at
         *		that point and the two split parts (intobj's) sent 
	 *	  	back into the "while(intobj)" loop that encloses the
	 *		entire algorithm.
	 *	   ELSE 
	 *		Project the end-pts  of the intobj onto the edge to
	 *		determine the direction of flow of the edge with respect
	 *		to the intobj. If the edge flows OPPOSITE to the intobj
	 *		then set the flag to push the intobj to another surface
	 *		across the common edge. The FIRST coincident edge  
	 * 	  	found will stop the processing of any other probable
	 *		coincident edges (in other words, break the FOR loop).
	 * 	   ENDIF
	 *
	 *      ENDIF
	 *
	 * ENDFOR
	 */
	/* Intobj was NOT dummy edge. Check for coincidence. The intobj needs
         * to have its more_info field non-null, otherwise we do not have ANY
         * idea about which edges it is incident on at either end.
         */
        if (!dummy_edge && 
            (intobj_loc->more_info && 
             !(intobj_loc->props & EMSintobj_nontriminfo)))
	{

	  /* These may be interchanged at this point, but the final result
           * is modified based on "reverse" field of the intobj, below.
           */
	  intobj_start = (struct EMSsfintedpar *)(intobj_loc->more_info);
	  intobj_end   = intobj_start->next;
	  coincident_edgeid = NULL_OBJID; /** assume at start **/

	  /* If either end of the intobj does NOT end at another edge, then
  	   * we assume the intobj is NOT coincident with ANY edge.
           */
          if ( (intobj_start->edgeid == NULL_OBJID) || 
	       (intobj_end->edgeid   == NULL_OBJID)
	     )
	 	{
	     		goto Next;  /*  process the next intobj in the list */
		}/*if*/

	  /* set the pointers to the pre-allocated memory */

          intobj_start_edges = intobj_start_edges_buffer;
          is_rightend        = is_rightend_buffer;
	  found_edge         = FALSE;

	  switch (intobj_start->intloc)
	  {
	  case EMScvint_middle:    
	       intobj_start_edges[0] = intobj_start->edgeid;
	       num_edges_start       = 1;
 	       found_edge            = TRUE;
	       break;
	  case EMScvint_rtend:
	  case EMScvint_rtendcoll:
	       edge_int_at_rt_vtx = TRUE;
	       break;
	  case EMScvint_lfend:
	  case EMScvint_lfendcoll:
	       edge_int_at_rt_vtx = FALSE;
	       break;
	  default:
	       goto Next; 
	  }/*switch*/

	  if (!found_edge)
	  { get_coinc_edge_opt = EMSvtxedges_onlythissurf;
            num_edges_start = 0;  /*IMPORTANT: EMgetvtxedges expects this */
	    stat_OM = om$send (msg = message EMSedge.EMgetvtxedges (
						&msg_loc,get_coinc_edge_opt,
                                                edge_int_at_rt_vtx,
						MAX_EDGES_PER_VERTEX,
						&num_edges_start, 
						&intobj_start_edges, 
						&is_rightend),
					targetid = intobj_start->edgeid,
					senderid = NULL_OBJID,
					targetos = os); 
            EMerr_exit (stat_OM, Next);
            EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end); 
	  }/*if*/
  

          /*
           * before resetting "is_rightend" to the pre-allocated memory,
           * we need to deallocate memory that may have been allocated
           * by EMgetvtxedges. (Purify)
           */
	  if (is_rightend != is_rightend_buffer)
		om$dealloc (ptr = is_rightend);

	  /* set the pointers to the pre-allocated memory */

          intobj_end_edges = intobj_end_edges_buffer;
          is_rightend      = is_rightend_buffer;
	  found_edge       = FALSE;

	  switch (intobj_end->intloc)
	  {
	  case EMScvint_middle:    
	       intobj_end_edges[0] = intobj_end->edgeid;
	       num_edges_end       = 1;
 	       found_edge          = TRUE;
	       break;
	  case EMScvint_rtend:
	  case EMScvint_rtendcoll:
	       edge_int_at_rt_vtx = TRUE;
	       break;
	  case EMScvint_lfend:
	  case EMScvint_lfendcoll:
	       edge_int_at_rt_vtx = FALSE;
	       break;
	  default:
	       goto Next;
	  }/*switch*/

	  if (!found_edge)
	  {  get_coinc_edge_opt = EMSvtxedges_onlythissurf;
             num_edges_end = 0; /*IMPORTANT: EMgetvtxedges expects this */
	     stat_OM = om$send (msg = message EMSedge.EMgetvtxedges (
						&msg_loc,get_coinc_edge_opt, 
						edge_int_at_rt_vtx,
						MAX_EDGES_PER_VERTEX,
						&num_edges_end,
						&intobj_end_edges, 
						&is_rightend),
					targetid = intobj_end->edgeid,
					senderid = NULL_OBJID,
					targetos = os); 
             EMerr_exit (stat_OM, Next);
             EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end); 
	  }/*if*/

	  /* At this point check for common edges in the two lists, which then
	   * are likely candidates for coincidence. These likely coincident 
	   * edges are checked one by one (till the first actual coincidence is 
	   * ascertained) by projecting the intobj on it. Note that the check 
	   * ends when the FIRST coincident edge is ascertained.
	   */

	  found_edge = FALSE;
	  npce = 0; /**Number of Probable Coincident Edges*/
	  for (i=0; i<num_edges_start; i++)
          {	for (j=0; j<num_edges_end; j++)
		{	
			if (intobj_start_edges[i] == intobj_end_edges[j])
			{ 	likely_coincident_edgeid[npce++]=
							intobj_start_edges[i];
				found_edge = TRUE;
				break; /* go to new "start" edge */
			}/*if*/
		}/*for,j*/
		
	  }/*for,i*/

	  /* EMgetvtxedges allocates memory if the supplied memory is not
           * sufficient. If that has happened, then the intobj_start_edges will
	   * not be pointing to the same location as intobj_start_edges_buffer,
	   * in which case, we free the memory malloced in EMgetvtxedges.
	   */
   
	  if (intobj_start_edges != intobj_start_edges_buffer)
		om$dealloc (ptr = intobj_start_edges);
	  if (intobj_end_edges != intobj_end_edges_buffer)
		om$dealloc (ptr = intobj_end_edges);
	  if (is_rightend != is_rightend_buffer)
		om$dealloc (ptr = is_rightend);

	  /* If likely coincident edge(s) exists. Else it will loop around
	   * to the next intobj.
  	   */
	  if ( found_edge) 
          {
	      /* for EVERY probable coincident edge */
	      
	      for (edg=0; edg < npce; edg++)
              {
		bad_coincidence = FALSE; /** assume, at start. IMPORTANT **/
		coincident_edgeid = likely_coincident_edgeid[edg];

              /* The end points of the intobj lie on the same edge.
               * Find if some internal points of the intobj also lie on the 
	       * edge. If they do,it is a good indication that intobj & the edge
	       * might be coincident. Also,the number of points to be checked is
	       * determined by the variable "num_samplepts" that is passed into 
	       * this function.The "num_samplepts" value DOES NOT include the 
	       * endpoints.
	       */

              /* get the geometry of the  edge */


	      /** initializations required by the method **/

	      edge_geom_xyz.poles   = NULL;
	      edge_geom_xyz.knots   = NULL;
	      edge_geom_xyz.weights = NULL;
              stat_OM = om$send (msg = message EMSedge.EMget_bcxyz_geom 
					(&msg_loc, modenv, NULL, NULL, 0, 
					 MAXINT, FALSE, NULL, &edge_geom_xyz), 
				targetid = coincident_edgeid,
				senderid = NULL_OBJID,
				targetos = os);
              EMerr_exit (stat_OM, Next);
              EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end); 


 	      /* allocate memory for the internal points on stack */

	      internal_pts = internal_pts_buffer; /* pre-allocated */

              /* Find "num_samplepts" internal points of the intobj */

              EMinternalpt (&msg_loc, &(modenv->matrix_type), modenv->matrix, 
				&(intobj_loc->this_xyzintobj), EMScvint_middle, 
				num_samplepts, internal_pts);
              EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end); 

              /* The EMprojectpt call needs the edge geometry in
               * "dataselect" format while the "EMget_bcxyz_geom "
               * routine returns the geometry as a 3D IGRbsp_curve.
               */
              edge_ingeom.datatype = EMSdata_curve3d;
              edge_ingeom.data.curve = &edge_geom_xyz;

              mindist = mindist_buffer; /* pre-allocated */
              projected_pts = projected_pts_buffer; /*pre-allocated*/


              /* Project intobj's internal points onto the edge */

              EMprojectpt (&msg_loc, &(modenv->matrix_type),modenv->matrix, 
				&edge_ingeom, num_samplepts, internal_pts, 
				xyz_chd_ht, projected_pts, mindist);

              EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end); 

              /* Check if internal points and corresponding projected points 
	       * are same. If ALL of them coincide, the intobj lies on the edge.
	       */
              intobj_coinc_with_edge = TRUE; /** assume **/
              for (i=0; i< num_samplepts; i++)
              {   if (mindist[i] > xyz_chd_ht)  /** should it be "2.0 *" ?? **/
                  {     intobj_coinc_with_edge = FALSE; 
                        break;
                  }/*if*/
              }/*for*/

	    /* If the intobj DOES coincide with the edge, it must also be 
	     * ensured that the coincident edge flows OPPOSITE to the intobj.
	     * The first edge to meet this condition is caught and the loop 
	     * is broken out of.
	     */
	    if (intobj_coinc_with_edge)
	      {	
		/* Get the properties of intersected coincident edge.
		 * IMPORTANT: The properties of the edge are got in 
		 * ---------  the variable "fprops", because "fprops" 
		 * is needed later on in the code. (Look for line:
		 * "reversed2 = fprops & EMED_REVERSE_CONNECT? FALSE:TRUE")
		 */

                 stat_OM = om$send (msg = message EMSedge.EMget_props 
			                (&msg_loc, &fprops), 
				   targetid = coincident_edgeid, 
				   senderid = NULL_OBJID,
				   targetos = os);
		 EMerr_exit (stat_OM, Next);
                 EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end); 

		 /* Check if intersected edge is closed. If it is, and the
	 	  * end point of the edge lies in the middle of the intobj  
		  * ("middle" ==> anywhere BUT the end points of the intobj),
		  * then the intobj will need to be split at the point of 
		  * intersection of the end point of the edge with the intobj. 
		  * Then, the new intobj's will have to go through the whole 
		  * coincident edge check again.
		  */

		 if ( fprops & EMED_XYZ_CLOSED)
		 {	
		    edge_closed = TRUE;

		    /* project edge's end pts onto intobj and check if
		     * projected pts. lie in the "middle" of intobj, i.e.
		     * at any location other than the endpoints.
		     */

	            /* get 1 PAIR of end-pts of the edge. This function
		     * has the capability to get multiple pairs of points
		     * starting from the ends
		     */
	            sts = EMgetendpts_xyz (&msg_loc, &(modenv->matrix_type),
					       modenv->matrix, 
					       &edge_ingeom,
					       FALSE, 1,
					       start_pt, stop_pt);
              	    EMerr_hndlr(!(sts&msg_loc&1),*msg, EMS_E_Fail,ret_end); 

		    /* project ONE end-pt(since the edge is closed) onto the
		     * intobj and check if the projected point is in the 
		     * "middle" of the intobj.
		     */
              	    EMprojectpt ( &msg_loc, 
				      &(modenv->matrix_type),
				      modenv->matrix, 
				      &(intobj_loc->this_xyzintobj),
				      1, 
				      start_pt, 
				      xyz_chd_ht, 
				      projected_pts, mindist);
              	    EMerr_hndlr (EMSerror(msg_loc),*msg,EMS_E_Fail,ret_end); 

		    /* If the projected point is at an end-point of the 
		     * intobj, then it means that it is a case like two 
		     * cylinders with their seams lined up, which is not
 		     * different from a non-closed-edge case.
		     */   

		    if (mindist[0] <= (2.0 * xyz_chd_ht))
		    { if (projected_pts->props & EMS_PYPT_ATMIDDLE) 
		      {
			 edge_endpt_lies_on_intobj_middle = TRUE; 

		      }
		      else
		      {	 /* cases where the ends of the edge lie
			  * on one/both end-pts of the intobj. This can
			  * be handled like the non-closed edge case. 
			  */
			 edge_endpt_lies_on_intobj_middle = FALSE;
		      }
		    }
		    else
		    {
                      /* cases where the ends of the edge do NOT lie on
                       * the intobj. Since we have already determined in
                       * the code above, that there IS coincidence, this means
                       * that the coinciding intobj lies in the interior of the
                       * edge. Can be handled like a non-closed edge case.
                       */
                      edge_endpt_lies_on_intobj_middle = FALSE;
		    }
		 }
		 else
		 {
		    edge_closed = FALSE;
		 }


		 if (edge_closed && edge_endpt_lies_on_intobj_middle)
		 {
		    IGRboolean 		succ;
		    IGRdouble		coinc_start_uv[2], coinc_end_uv[2];
		    struct EMSpypoint	split_info_uv, split_info_xyz;
	            struct EMSedgebound	coinc_start_param,coinc_end_param;
                    struct EMSproj_info intobj_split_pt;

		    /* Do the following:
		     * 1. Split the intobj at the point where the endpts of
                     *    of the closed edge lie on it.
		     * 2. Reset the "intobj_loc_next" variable back to
		     *    "intobj_loc", so that both the split parts of the
		     *    intobj will now go through the above checks again.
		     *    (After the split, "intobj_loc" will point to the first
		     *    part of the split and the other half will be next
		     *    in the linked list).
		     */

                    /* To get the value of the split point on the intobj, we
                     * get the UV values of the endpt of the closed edge and
                     * then project this point onto the intobj.
                     */ 
		    sts = om$send (msg=message EMSedge.EMendpts (&msg_loc,
					coinc_start_uv, coinc_end_uv, 
					&coinc_start_param,&coinc_end_param,
					NULL),
				targetid= coincident_edgeid,
				targetos= os,
				senderid= NULL_OBJID);
                    EMerr_hndlr (!(sts & msg_loc & 1), 
					*msg,EMS_E_EdgeError,ret_end);

		    /* The EMptproject method needs the ptolbas. If not given,
		     * it attempts to evaluate the same using intobj's uv-edge, 
		     * which will be an error, since intobj is not connected to
		     * any surface at this stage.
		     */
	      	    ptolbas.is_valid = FALSE; 
  		    ptolbas.in_world = FALSE;
  		    ptolbas.mattyp   = &(modenv->matrix_type);
  		    ptolbas.mat      = modenv->matrix;

  		    sts = om$send (msg = message EMSboundary.EMgetsurface_info(
						&msg_loc, NULL, &ptolbas),
                    			targetid = coincident_edgeid,
					targetos = os,
					senderid = NULL_OBJID);
                    EMerr_hndlr(!(sts & msg_loc & 1),*msg,
						EMS_E_EdgeError,ret_end);

                    /* Now project the endpt of the closed edge onto the
                     * intobj, which will be the split point.
                     */
                    sts = om$send (msg=message EMSedge.EMptproject (&msg_loc,
					coinc_start_uv, 1, &intobj_split_pt, 
					NULL, &ptolbas),
				   targetid = intedid->objid,
				   targetos = os,
               			   senderid = NULL_OBJID);
                    EMerr_hndlr (!(sts & msg_loc & 1) || 
                                  (intobj_split_pt.location != EMScvint_middle),
                                          *msg, EMS_E_EdgeError,ret_end); 

		    /* create the sfintedpar structure for the split pt. 
		     * which will be needed for the call to"EMsplit_sfintobj_uv"
		     */
					
		    split_info_uv.props    = EMS_PYPT_ATMIDDLE; /* known */
		    split_info_uv.point[0] = intobj_split_pt.proj_pt[0]; 
		    split_info_uv.point[1] = intobj_split_pt.proj_pt[1]; 
                    split_info_uv.span_inx = intobj_split_pt.param.span_inx;
                    split_info_uv.param    = intobj_split_pt.param.param;
		    split_info_uv.info     = NULL;
		    split_info_uv.next     = NULL; 


                    /* The xyz split information is available to us (from the
                     * projection of an xyz endpt of the closed edge onto the 
                     * intobj) in "projected_pts[0]" from above.
                     */
 		    split_info_xyz.props    = EMS_PYPT_ATMIDDLE; /* known */
 		    split_info_xyz.point[0] = projected_pts[0].point[0];
 		    split_info_xyz.point[1] = projected_pts[0].point[1];
 		    split_info_xyz.point[2] = projected_pts[0].point[2];
                    split_info_xyz.span_inx = projected_pts[0].span_inx;
                    split_info_xyz.param    = projected_pts[0].param;
 		    split_info_xyz.info     = NULL;
 		    split_info_xyz.next     = NULL; 
 
			
		    /* Now make the call to split the intobj into TWO intobj's
		     * that will then go back into the intobj loop for further
		     * processing. The intobj's created are in the logical dir-
		     * ection of the original intobj, such that the first part
		     * goes from start to split point and the other part goes 
		     * from split point to end (of the original intobj)

		     */
 		    succ =  EMsplit_sf_intobj_uv (&msg_loc, NULL, modenv, 
 				intobj_loc, &split_info_uv,&split_info_xyz, 
                                NULL);
                    EMerr_hndlr ((!succ || !(msg_loc & 1)), 
					*msg, EMS_E_EdgeError,ret_end); 

		    /* Now that the intobj's have been split into two, the info-
		     * mation about which edges these intobj's intersect and at
		     * what edgeparameter is not known. This info will be requi-
		     * red for the processing of the intobj's when they come 
		     * back into the intobj loop. The info that needs to be up-
		     * dated is the "more_info" field of the intobj's,that point
		     * to a linked list of two EMSsfintedpar nodes, the first
		     * refering to the start  point of the intobj and the other 
		     * to the end pt. For the first intobj (first part of the 
		     * split), we know that the start point lies in the "middle"
		     * of the coincident edge. However, the end-pt, coincides 
		     * with AN end-point of the coincident edge. Since we need
		     * to know whether it is the LEFT or the RIGHT endpoint, we
		     * project two (& this is important!) INTERNAL points of the
		     * intobj onto the coincident edge to check for direction of
		     * flow. If the coincident edge flows OPPOSITE to the intobj
		     * then the end-pt of the first half lies on the START pt of
                     * the coincident edge else on the END point. Accordingly,
		     * the start point of the OTHER half of the split
                     * lies either on the END point or on the START point of the
                     * coincident edge.  
		     * NOTE: There is also the OTHER intobj node which has 
		     * ----  simultaneously been split into two parts. We do not
		     * do anything about that here as far as the more-info field
		     * since we do not have sufficient info. Moreover this will 
		     * be a problem only if the OTHER intobj node was also 
		     * fully coincident with another edge...which is less likely
		     */

		    {		/* UPDATE SFINTEDPAR */
		     IGRdouble			intern_pts[4];
		     IGRboolean			opposite_flow;
		     struct EMSpartolbasis	ptolbas;
		     struct EMSproj_info	proj_info[2];
		     struct EMSsfintedpar	*more_info;
		     struct EMSedgebound	param0, param1;

		    /* get two internal points on the first intobj. If we also
		     * needed proj. pts, then we would need to pass in the value
		     * of partolbas (from the coincident edge, since intobj
		     * is not connected to any surface yet)
		     */
		    sts = om$send (msg=message EMSedge.EMinternalpt (&msg_loc,
							2,NULL, intern_pts,
							NULL, NULL),
		      targetid = intobj_loc->this_uvintobj.data.object->objid,
		      targetos = intobj_loc->this_uvintobj.data.object->osnum,
		      senderid = NULL_OBJID);
                    EMerr_hndlr(!(sts&msg_loc&1),*msg,EMS_E_EdgeError,ret_end); 

		    /* project internal points onto the coincident edge */
		    ptolbas.is_valid = FALSE;
		    ptolbas.in_world = FALSE;
                    ptolbas.mattyp   = &(modenv->matrix_type);
                    ptolbas.mat      = modenv->matrix;
		    sts = om$send (msg=message EMSedge.EMptproject (&msg_loc,
						intern_pts, 2, proj_info,
						NULL, &ptolbas),
 				targetid = coincident_edgeid,
                      		targetos = os,
                      		senderid = NULL_OBJID);
                    EMerr_hndlr(!(sts&msg_loc&1),*msg,EMS_E_EdgeError,ret_end); 

		    /* check if direction of flow is opposite. If by some 
		     * chance one of the points happened to project onto the 
		     * END points of the coincident edge, this might give wrong
		     * results. But since "EMinternalpt" does NOT pick end pts,
		     * this will not happen. The internal pts are in the 
		     * direction of the logical flow of the intobj. The proj. of
		     * intern_pts[0] is param0 and of intern_pts[1] is param1.
                     * If param0 > param1, then the edge probably flows opposite
 		     * to the intobj. This can finally be ascertained ONLY after
		     * checking the reverse bits of the coincident edge. 
                     */
		     param0 = proj_info[0].param;
		     param1 = proj_info[1].param;
		     opposite_flow = FALSE; /*assume at start*/

                     if ( ((double)(param0.span_inx) + param0.param)
                                                     >
                          ((double)(param1.span_inx) + param1.param)
                        )
                     {
                        opposite_flow = TRUE;
                     }
		     
		    /* we do not need to check the reverse bits of the intobj, 
		     * since the purpose of this opposite check is to determine
		     * ONLY whether the "this_uvintobj" flows opposite to the
		     * coincident edge, which will then tell us whether the end
		     * point of the "this_uvintobj" is coincident with the START
		     * or END point of the coincident edge. The "more_info" 
		     * always matches the flow of "this_uvintobj". 
		     */

		    if ( fprops & EMED_REVERSED)
			opposite_flow = !opposite_flow;

			
		    /* Now fill in the sfintedpar structures for the two new
		     * intobj's that were created from the original intobj. The
		     * "EMsplit_sfintobj_uv" function does not update these.
		     */

		    /* for the END pt of the FIRST half of the split */

		    more_info = (struct EMSsfintedpar *)(intobj_loc->more_info);
		    more_info = more_info->next;

		    more_info->intloc 	= (opposite_flow)? EMScvint_lfend:
							   EMScvint_rtend;
		    more_info->edgeid 	= coincident_edgeid;
		    more_info->edgepar	= (opposite_flow)?coinc_start_param :
						     	  coinc_end_param;

		    /* does it matter, since both points are the same? Test this
		     * out later.
		     */

		    if (opposite_flow)
		    {  	more_info->point[0] = coinc_start_uv[0];
		      	more_info->point[1] = coinc_start_uv[1];
		    }
		    else
		    {  	more_info->point[0] = coinc_end_uv[0];
		      	more_info->point[1] = coinc_end_uv[1];
		    }

		    /* for the START pt of the SECOND half of the split */

		    more_info = (struct EMSsfintedpar *)
						(intobj_loc->next->more_info);
		    more_info->intloc 	= (opposite_flow)? EMScvint_rtend:
							   EMScvint_lfend;
		    more_info->edgeid 	= coincident_edgeid;
		    more_info->edgepar	= (opposite_flow)?coinc_end_param :
						     	  coinc_start_param;
		    if (opposite_flow)
		    {  	more_info->point[0] = coinc_end_uv[0];
		      	more_info->point[1] = coinc_end_uv[1];
		    }
		    else
		    {  	more_info->point[0] = coinc_start_uv[0];
		      	more_info->point[1] = coinc_start_uv[1];
		    }

		    }/* 	UPDATE SFINTEDPAR */

		    /* the first part of the split will have the same
		     * pointer as the original intobj and the other part 
		     * of the split will be next in the linked list of 
		     * intobj's. Re-insert the intobj pointer into 
		     * the loop.
		     */

		    intobj_loc_next = intobj_loc;
		    goto Next;

		 }
		 else 
		 {   
		     /* We now have to check if the intobj and the edge flow
		      * in opposite directions. If the coincident edge is CLOSED
		      * we project two internal points of the intobj onto the 
		      * edge to check direction of flow, ELSE we project the end
		      * points of the intobj. The reason to use internal points 
		      * in case of a closed edge is that, IF one/both endpoints 
		      * of the intobj coincide with an endpt of the coinc. edge,
		      * then the projection of the intobj endpt may fall on the
		      * wrong endpt of the coinc. edge, which will give us wrong
		      * conclusions about direction of flow.
		      */ 

		     if (fprops & EMED_XYZ_CLOSED)
	             {
			/* get two internal points of the intobj */
			sts = om$send (msg = message EMSedge.EMinternalpt (
						&msg_loc, 2, NULL, 
						intobj_pts_uv, NULL, NULL),
					targetid = intedid->objid,
					targetos = os,
					senderid = NULL_OBJID);
                    	EMerr_hndlr(!(sts&msg_loc&1),*msg,EMS_E_EdgeError,
								    ret_end); 
		     }
		     else
		     {	/* use the end-pts (UV) stored in the "more_info"
			 * sfintedpar structure.
			 */
	      	     	intobj_pts_uv[0] = intobj_start->point[0];
	      	     	intobj_pts_uv[1] = intobj_start->point[1];
	      	     	intobj_pts_uv[2] = intobj_end->point[0];
	      	     	intobj_pts_uv[3] = intobj_end->point[1];
		     }

		     /* Even though ptolbas is calculated within the EMptproject
		      * function, the following fields MUST be set, because
		      * they are used when the loopset calls a method to get
		      * the information from the surface.
		      */
	      	     ptolbas.is_valid = FALSE; 
  		     ptolbas.in_world = FALSE;
  		     ptolbas.mattyp   = &(modenv->matrix_type);
  		     ptolbas.mat      = modenv->matrix;
		     
              	     stat_OM = om$send (msg = message EMSedge.EMptproject 
					       (&msg_loc, intobj_pts_uv, 2,
				 	        edge_proj_info, NULL, &ptolbas),
 					 targetid = coincident_edgeid, 
				   	 senderid = NULL_OBJID,
				   	 targetos = os);
              	     EMerr_exit (stat_OM, Next);
              	     EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end); 
	      	     start_param = edge_proj_info[0].param;
	      	     end_param   = edge_proj_info[1].param;
 
		     /* If start parameter > end parameter, then the coinc. edge
		      * probably flows opposite to the intobj. This can finally
		      * be ascertained ONLY after checking the reverse bits of
		      * both the edge and the intobj.
		      */
		     if ( ((double)(start_param.span_inx) + start_param.param) 
						          > 
			  ((double)(end_param.span_inx)   + end_param.param)
		        ) 
		        {  
		       	   bad_coincidence = TRUE;
		        }/*if*/
 
		     if (intobj_loc->reversed)
			 bad_coincidence = !bad_coincidence;

		     if (fprops & EMED_REVERSED)
			 bad_coincidence = !bad_coincidence;	


 
 /* check to see if the intersection is coincident with an edge which is
    a common edge of one of the intersecting surface and another surface -
    and if that another surface is coincident with the other intersecting 
    surface causing the coincident intersection with the first surface */
 
                    other_surf_id = 
                    intobj_loc->other_intobj_node->
                                              this_obj_node->this_obj.objid; 

                     me_surf_id = intobj_loc->this_obj_node->this_obj.objid;

                     EMnon_planar_coinc_proc (
                               &msg_loc,
                               &modenv->matrix_type,
                               modenv->matrix,
                               os, 
                               &ptolbas,
                               intobj_loc,
                               inters,
                               me_surf_id,
                               &this_surf_grid.objid,
                               other_surf_id,
                               coincident_edgeid,
                               &surfs_are_non_planar_coinc,
                               &if_nonpln_coinc_int_del_then_process);
              	     EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end); 

                     if(if_nonpln_coinc_int_del_then_process)
                         fedge =  coincident_edgeid;
 
		     if (bad_coincidence)
		     {   
			 /* "fedge" needed by call to "EMpushtocommon_mod" */
			 fedge = coincident_edgeid; 
			 break;
		     }
 
		 }/*else*/
 
	       }/*if, intobj_coinc_with_edge*/
 
               {
                /* deallocate the curve info before looping back around */
                if(edge_geom_xyz.poles)
                  {
                    om$dealloc( ptr = edge_geom_xyz.poles);
                    edge_geom_xyz.poles = NULL;
                  }
                if(edge_geom_xyz.knots)
                  {
                    om$dealloc( ptr = edge_geom_xyz.knots);
                    edge_geom_xyz.knots = NULL; 
                  }
                if(edge_geom_xyz.weights)
                  {
                    om$dealloc( ptr = edge_geom_xyz.weights); 
                    edge_geom_xyz.weights   = NULL;
                  }
               } /* end dealloc block */ 


	      }/*for*/

             }/*if (found_edge)*/

	    }/*if (!dummy_edge)*/
				
          }/*if*/

        }/*if*/


       if(surfs_are_non_planar_coinc || 
         ( bad_coincidence || if_nonpln_coinc_int_del_then_process) )
        {
#ifdef DEBUG
{
printf("**********************\n");
printf("check/operate %d / %d \n", *check, *operate);
printf(" status %d %d %d \n", bad_coincidence, surfs_are_non_planar_coinc, if_nonpln_coinc_int_del_then_process);
printf("surfs %d - %d \n",this_surf_grid.objid, other_surf_id);
printf("coinc_edid %d \n", fedge);
}
#endif
        (*nummarked)++;

        /*
         * A "bad" coincidence exists. Generate an intersection edge
         * along the full-coincident edge's common edge and put into the
         * intersection list. Then delete this coincident edge.
         */

        ptolbas.is_valid = FALSE;
        cdata.datatype = EMSdata_null;
        cincparms = NULL;

 
/****************************************
    if it is a case of coincident surfaces causing coincident intersections
    with a common edge then check the "pushed" input to see if the intersection
    (intobj) needs to be pushed on to the common edge or is to be deleted. If is
    some other case of "bad coincidence" the disregard the "pushed" flag. 
*****************************************/
 
    if(*check)
    {
     if(temp_fedge != fedge)
      {
      temp_fedge = fedge;
      if(surfs_are_non_planar_coinc && !if_nonpln_coinc_int_del_then_process)
        {
        push_coinc_list[0][*num_push_coinc].osnum = os ;
        push_coinc_list[0][*num_push_coinc].objid =  this_surf_grid.objid;
        push_coinc_list[1][*num_push_coinc].osnum = os ;
        push_coinc_list[1][*num_push_coinc].objid = other_surf_id;
        (*num_push_coinc) ++;
        }
      else if(if_nonpln_coinc_int_del_then_process)
        {
        delete_list[0][*num_del].osnum = os ;
        delete_list[0][*num_del].objid = this_surf_grid.objid;
        delete_list[1][*num_del].osnum = os ;
        delete_list[1][*num_del].objid = other_surf_id;
        (*num_del) ++;
        }
        goto Next;
      }
    }
    else
    {
    IGRint me_count_1, me_count_2;

    go_ahead_push = TRUE;
  if( surfs_are_non_planar_coinc)
  {

/*****************************************
check to see it the intersection pairs are on the same operand
*****************************************/
      me_count_1 = me_count_2 = 0;
      for(ku=0; ku< *num_del_2; ku++)
         if( ( (this_surf_grid.objid == delete_list_2[0][ku].objid)  && 
             (other_surf_id  == delete_list_2[1][ku].objid) )  ||
           ( (this_surf_grid.objid == delete_list_2[1][ku].objid)  &&
             ( other_surf_id == delete_list_2[0][ku].objid) ) ) 
             {
             me_count_1 ++;
             }
      for(ku=0; ku< *num_push_coinc_2; ku++)
         if( ( (this_surf_grid.objid == push_coinc_list_2[0][ku].objid)  && 
             (other_surf_id  == push_coinc_list_2[1][ku].objid) )  ||
           ( (this_surf_grid.objid == push_coinc_list_2[1][ku].objid)  &&
             ( other_surf_id == push_coinc_list_2[0][ku].objid) ) ) 
             {
             me_count_2 ++;
             }


   if ((me_count_1 + me_count_2) != 2)
   {
/***********************************************
THE intersection pairs are on different operands:
-------------------------------------------------------------------------------
               |        i_am_deletable       |      i_am_not_deletable
-------------------------------------------------------------------------------
               |   delete unconditionally    |     do not delete at all
 operate       |                             |
-------------------------------------------------------------------------------
               |                             |
 do_not_operate|   delete  if counterpart    |     do not delete at all
               |       is pushable           |         
--------------------------------------------------------------------------------
************************************************/
      go_ahead_push = TRUE;
      if(if_nonpln_coinc_int_del_then_process)
        {
        if_nonpln_coinc_int_del_then_process = FALSE;
        if (*operate)
           {
           go_ahead_push = FALSE;
           }
        else
           {
          /******
          delete intersection if counterpart is pushable 
          ******/
            for(ku=0; ku< *num_push_coinc; ku++)
              if( ( (this_surf_grid.objid == push_coinc_list[0][ku].objid)  && 
                   (other_surf_id  == push_coinc_list[1][ku].objid) )  ||
                 ( (this_surf_grid.objid == push_coinc_list[1][ku].objid)  &&
                     ( other_surf_id == push_coinc_list[0][ku].objid) ) ) 
                  {
                  go_ahead_push = FALSE;
                  break;
                  }
           }
        }
    }
    else
    {
/*************************************************
THE intersection pairs are on the same  operand: 
-------------------------------------------------------------------------------
               |        i_am_deletable       |      i_am_not_deletable
-------------------------------------------------------------------------------
               |                             |
 operate       |    delete  it if deletable  |     do not delete it   
               |    and counterpart is       |
               |         pushable            |
-------------------------------------------------------------------------------
               |                             |
 do_not_operate|   do not delete             |     delete if pushable and
               |                             |       counterpart is
               |                             |          deletable
               |                             |     
--------------------------------------------------------------------------------
**************************************************/
      if(*operate)
        {
          if(me_count_1 == 1  &&  me_count_2 == 1)
           if(if_nonpln_coinc_int_del_then_process)
              go_ahead_push = FALSE;
           else
              go_ahead_push=TRUE;
        }
        else
        {
          if(me_count_1 == 1  &&  me_count_2 == 1)
           if(if_nonpln_coinc_int_del_then_process)
              go_ahead_push=TRUE;
           else
              go_ahead_push = FALSE;
        }
    }
  } /******** if surfs are non planar coinc *******/

    if(go_ahead_push && !bad_coincidence)
         goto Next;

     if(go_ahead_push )
       { 
#ifdef DEBUG
printf("pushed \n");
#endif
        stat_OM = EMpushtocommon_mod (&msg_loc, &modenv->matrix_type,
                   modenv->matrix, FALSE, FALSE, NULL_OBJID,
                   &intobj_loc->this_xyzintobj, NULL_OBJID, os, fedge, os,
                   tolfactor, FALSE, intobj_loc->reversed, TRUE, NULL,
                   &csfid, &cdata, &cctype,
                   NULL, &cincparms, NULL, NULL, &ptolbas);
        EMerr_exit (stat_OM, Next);
        EMerr_hndlr (EMSerror (msg_loc) || msg_loc == EMS_I_NoSolution,
         msg_loc, msg_loc, Next);
       }
       else
       {
#ifdef DEBUG
printf("not pushed \n");
#endif
       intobj_loc->props |= EMSintobj_deletable;
          *msg = EMS_S_Success;
          stat_OM = OM_S_SUCCESS;
          goto Next;
       }


 
        cintdata.datatype = EMSdata_null;
        stat_OM = EMmkintdata (&msg_loc, &cdata, cctype, NULL, FALSE,
                   NULL, NULL, TRUE, &ptolbas.tol, NULL, &cintdata);
        EMerr_exit (stat_OM, Next);
        EMerr_hndlr (EMSerror (msg_loc) || msg_loc == EMS_I_NoSolution,
         msg_loc, msg_loc, Next);
        if (msg_loc == EMS_I_Degenerate)
          degenerate = TRUE;
        else
          degenerate = FALSE;
        cdata.data.object->objid = NULL_OBJID;
        EMdataselect_data_free (&msg_loc, &cdata, 1);

        /*
         * If the direction of the uv-data generated by the "pushtocommon" call
         * is the reverse of the xyz-data currently residing in intobj_loc,
         * make it consistent and record the fact that the true direction
         * is the reverse of the current.
         */

        if (intobj_loc->reversed)
          {
          stat_OM = om$send (msg = message EMSedge.EMreverse (&msg_loc),
                     targetid = cintdata.data.object->objid,
                     targetos = cintdata.data.object->osnum,
                     senderid = NULL_OBJID);
          EMerr_exit (stat_OM, ret_end);

          cincparms->next->next = cincparms;
          cincparms = cincparms->next;
          cincparms->next->next = NULL;

          reversed1 = TRUE;
          }
        else
          reversed1 = FALSE;

        bit_mask = EMSintobj_coincident | EMSintobj_dupothersurf |
                    EMSintobj_dupthissurf | EMSintobj_nonoriented |
                    EMSintobj_deletable | EMSintobj_xyzdegenerate;
        cintprops = (intobj_loc->props & bit_mask) |
                    (degenerate ? EMSintobj_uvdegenerate : NULL);
        other_intobj = intobj_loc->other_intobj_node;
        intobj_loc->this_xyzintobj.datatype = EMSdata_null;
        intobj_loc->other_intobj_node = NULL;
        EMdelintobj (&msg_loc, intobj_loc);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

        /*
         * The "bad" coincidence is based on the relative direction between
         * the "dummy-edge" and it's "full-edge". If the "full-edge" is
         * reverse connected to it's common-edge then the new, pushed
         * intersection edge being generated on this common-edge is already in
         * the correct direction, viz, opposite in quality. Otherwise,
         * it has to be reversed.
         */

        reversed2 = fprops & EMED_REVERSE_CONNECT ? FALSE : TRUE;
        
        /*
         * The pushed intersection is now put back into the intersection
         * list, taking care to see that the reverse-flag is set as the
         * exclusive OR of the two calls for reversal.
         */

         this_surf_grid.objid = csfid.objid;
         this_surf_grid.osnum = csfid.osnum;
         surface = NULL;
         if(!IF_NULL_OBJID(this_surf_grid.objid))
          {
           sts = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                                                    &modenv->matrix_type,
                                                    modenv->matrix,
                                                    &size ),
                     targetid = this_surf_grid.objid,
                     targetos = this_surf_grid.osnum,
                     senderid = NULL_OBJID);
           if(1&msg_loc&sts)
            {       
             surface = (struct IGRbsp_surface *) om$malloc ( size=  size);
             sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                                                    &modenv->matrix_type,
                                                    modenv->matrix,
                                                    (IGRchar *)surface ),
                     targetid = this_surf_grid.objid,
                     targetos = this_surf_grid.osnum,
                     senderid = NULL_OBJID);
             if(!(1&msg_loc&sts))
              {
               surface = NULL;
               msg_loc = EMS_S_Success;
               sts = OM_S_SUCCESS;
              }           
            }
           else
            {
             msg_loc = EMS_S_Success;
             sts = OM_S_SUCCESS;
            }
          }


        new_intobj = EMmakeintlist (&msg_loc, inters, NULL, &csfid, NULL,
                      surface, NULL, NULL, NULL,
                      other_intobj ? &other_intobj->this_xyzintobj : NULL,
                      &cintdata, NULL,
                      reversed1 ^ reversed2, NULL,
                      cincparms, NULL,
                      cintprops, NULL,
                      &cctype, NULL, 
                      TRUE, FALSE);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        if (other_intobj)
          {
          new_intobj->other_intobj_node = other_intobj;
          other_intobj->other_intobj_node = new_intobj;
          }
        new_intobj->props |= EMSintobj_marked;
        cincparms = NULL;

        (*numchged)++;
        }
      }

      Next:
      *msg = EMS_S_Success;
      msg_loc = EMS_S_Success;
      stat_OM = OM_S_SUCCESS;
      EMdataselect_data_free (&msg_loc, &cdata, 1);
      if (cincparms)
        EMsfintedpar_free (cincparms, NULL);
      intobj_loc = intobj_loc_next;
      }
    inters_loc = inters_loc->next;
    }

  /*
   * Wipe out the EMSintobj_marked bit for exit.
   */

  inters_loc = *inters;
  while (inters_loc)
    {
    intobj_loc = inters_loc->cvs;
    while (intobj_loc)
      {
      intobj_loc->props &= ~EMSintobj_marked;
      intobj_loc = intobj_loc->next;
      }
    inters_loc = inters_loc->next;
    }

  /*
   * Check if any of the intersection lists have ended up containing 
   * zero number of EMSintobj nodes. Remove such EMSinters nodes and
   * if this leaves a list empty, flag this occurence in an appropriate
   * return code.
   */

  if (*numchged)
    {
    EMcmpinters (&msg_loc, inters);
    if (msg_loc == EMS_I_NoMore)
      *msg = msg_loc;
    }

ret_end:

    {
     /* deallocate the curve info just in case we didn't do it above */
     if(edge_geom_xyz.poles)
       {
         om$dealloc( ptr = edge_geom_xyz.poles);
         edge_geom_xyz.poles = NULL;
       }
     if(edge_geom_xyz.knots)
       {
        om$dealloc( ptr = edge_geom_xyz.knots);
        edge_geom_xyz.knots = NULL;
       }
     if(edge_geom_xyz.weights)
       {
        om$dealloc( ptr = edge_geom_xyz.weights);
        edge_geom_xyz.weights   = NULL;
       }
    } /* end dealloc block */



  EMdataselect_data_free (&msg_loc, &cdata, 1);
  if (cincparms)
    EMsfintedpar_free (cincparms, NULL);

  EMWRAPUP (*msg, stat_OM, "EMpush_coinc_ed");
  return (stat_OM);
}



#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif
EMnon_planar_coinc_proc(msg,
                          matrix_type,
                          matrix,
                          os, 
                          ptolbassis,
                          this_intobj,
                          inters_list,
                          me_surf_id,
                          this_surf_id,
                          other_surf_id,
                          coincident_edgeid,
                          surfs_are_non_planar_coinc,
                          non_planar_coinc_int_del)
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRint me_surf_id;
  IGRint *this_surf_id;
  IGRint other_surf_id;
  GRobjid  coincident_edgeid;
  GRspacenum os;
  struct EMSpartolbasis *ptolbassis;
  IGRboolean *surfs_are_non_planar_coinc, *non_planar_coinc_int_del;
  struct EMSinters **inters_list;
  struct EMSintobj *this_intobj;


 {
  IGRlong msg_loc=EMS_S_Success, sts=OM_S_SUCCESS;
  struct GRid common_coinc_sf_grid;
  IGRboolean    volume_on_same_side = TRUE;
  IGRint num_coincs=0, ii=0;
  IGRdouble angle_measure1=0,angle_measure2=0,nutral_angle_tol=0;
  IGRboolean   ed_is_convex=FALSE, ed_is_nutral=FALSE;
  IGRushort convex_opts=0;
  struct EMSinters *inters=NULL;
  struct IGRbsp_surface  *this_srf=NULL, *other_srf=NULL;
  IGRboolean other_pos_orient=FALSE, this_pos_orient=FALSE, found_edge=FALSE;
  IGRdouble UV_pt[3], dot_buster=0, internal_pt[3];
  IGRpoint xyzpt_1, xyzpt_2;
  IGRvector xyznor_1, xyznor_2;
  IGRint num_samples=0;
  struct GRparms proj_parms;
  IGRlong EMgetcommonsf();
  

  extern EMgetabsg(), BSnorvec(), BSsfarrevn(), EMinternalpt();
  extern IGRdouble BSdotp();

  *msg = EMS_S_Success;
   sts = OM_S_SUCCESS;

 /* check to see if the intersection is coincident with an edge which is
    a common edge of one of the intersecting surface and another surface -
    and if that another surface is coincident with the other intersecting 
    surface causing the coincident intersection with the first surface */
 
   (void) EMgetcommonsf (&msg_loc,
                      matrix_type,
                      matrix,
                      coincident_edgeid,
                      os,
                      &common_coinc_sf_grid,
                      ptolbassis);
       EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end); 
 
       other_surf_id =
            this_intobj->other_intobj_node->this_obj_node->this_obj.objid; 
       *this_surf_id = common_coinc_sf_grid.objid;
       inters = *inters_list;


       *surfs_are_non_planar_coinc = FALSE; 
       if (inters) 
       {
         if(inters->coinc_info_list )
         {
         num_coincs  = *(inters->num_coincs);
         for(ii=0; ii< num_coincs ; ii++)
            if (  ((inters->coinc_info_list[0][ii] == other_surf_id) && 
                      (inters->coinc_info_list[1][ii] == *this_surf_id )) ||
                 ((inters->coinc_info_list[0][ii] == *this_surf_id) && 
                      (inters->coinc_info_list[1][ii] == other_surf_id ))  )
              {
              *surfs_are_non_planar_coinc = TRUE; 
              break;
              }
          }
        }

        if(! *surfs_are_non_planar_coinc )
           {
           *non_planar_coinc_int_del =  FALSE;
           goto ret_end;
           }


        convex_opts = NULL;
        convex_opts |= EMSchkconvex_nextgeomsf ;
        nutral_angle_tol = EMS_ZEROANGLE_DEG_MAX;
 	sts = om$send (msg = message EMSedge.EMchkconvex 
                   ( &msg_loc, 
                     convex_opts,
		     matrix_type,
		     matrix, 
                     nutral_angle_tol,
                     &ed_is_convex,
                     &ed_is_nutral,
                     &angle_measure1),
                targetid = coincident_edgeid,
		targetos = os,
		senderid = NULL_OBJID);
         EMerr_hndlr(!(sts&msg_loc&1),*msg,EMS_E_EdgeError, ret_end); 
 
         num_samples=1;
         EMinternalpt (&msg_loc, matrix_type, matrix, 
				&(this_intobj->this_xyzintobj),
                                EMScvint_middle, 
				num_samples,
                                internal_pt);
         EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end); 

	 sts = om$send (msg=message EMSsubbs.GRptproject
                            (&msg_loc,
                             matrix_type,
                             matrix,
                             internal_pt,
                             UV_pt,
                             &proj_parms),
                     targetid = *this_surf_id,
                     targetos = os,
                     senderid = NULL_OBJID);
         EMerr_hndlr(!(sts&msg_loc&1),*msg,EMS_E_EdgeError, ret_end); 

         UV_pt[0] = proj_parms.u;
         UV_pt[1] = proj_parms.v;

         EMgetabsg  ( &msg_loc, 
                      matrix_type,
                      matrix,
                      OM_Gw_current_OS,
                      *this_surf_id,
                      &this_srf);
         EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end); 

        if(this_srf->planar == 1 )
           {
           *surfs_are_non_planar_coinc = FALSE;
           *non_planar_coinc_int_del =  FALSE;
           goto ret_end;
           }
         this_pos_orient = this_srf->pos_orient;

         BSsfarrevn (&msg_loc, this_srf, 1,
                          &UV_pt[0], 1, &UV_pt[1],
                          xyzpt_1, xyznor_1);
         EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

	 sts = om$send (msg=message EMSsubbs.GRptproject
                            (&msg_loc,
                             matrix_type,
                             matrix,
                             internal_pt,
                             UV_pt,
                             &proj_parms),
                     targetid = other_surf_id,
                     targetos = os,
                     senderid = NULL_OBJID);
         EMerr_hndlr(!(sts&msg_loc&1),*msg,EMS_E_EdgeError, ret_end); 

         UV_pt[0] = proj_parms.u;
         UV_pt[1] = proj_parms.v;

/**********************
         proj_parms.leaf_id.objid;
 
         sts = om$send (msg = message EMSsubbs.EMpassloop (&send_rc,
             message EMSloopset.EMpt_location
               (&msg_loc,
                UV_pt,
                &location,
                ptolbassis)),
             targetid = other_surf_id,
             targetos = os,
             senderid = NULL_OBJID );
         EMerr_exit (sts, ret_end);
         EMerr_hndlr (EMSerror (msg_loc & send_rc), *msg, EMS_E_LoopsetError,
 
         if(location.num_located_edges > 0 )
             found_edge=TRUE;
 
         printf(" other_surf %d other_surf_as_loc %d \n num_located_edge %d \n",
                  other_surf_id, proj_parms.leaf_id.objid,
                  location.num_located_edges);
         printf("options %d  %d\n",
             location.options,location.options & EMS_L_ONEDGE);
         printf("loc edges \n");
         for(ii=0;ii< location.num_located_edges;ii++)
              printf(" %d ",location.edge[ii].edge_id);
         printf(" \n");
 
         if(location.num_located_edges > 0 )
             found_edge=TRUE;
 
        if(found_edge)
        {
            angle_measure2= 0;
            located_edgeid = location.edge[0].edge_id;
 
            convex_opts = NULL;
            convex_opts |= EMSchkconvex_nextgeomsf ;
            nutral_angle_tol = EMS_ZEROANGLE_DEG_MAX;
            sts = om$send (msg = message EMSedge.EMchkconvex
                   ( &msg_loc,
                     convex_opts,
                     matrix_type,
                     matrix,
                     nutral_angle_tol,
                     &ed_is_convex,
                     &ed_is_nutral,
                     &angle_measure2),
                targetid = located_edgeid,
                targetos = os,
                senderid = NULL_OBJID);
            EMerr_hndlr(!(sts&msg_loc&1),*msg,EMS_E_EdgeError, ret_end);
         }
***************/

              
         EMgetabsg ( &msg_loc, 
                     matrix_type,
                     matrix,
                     OM_Gw_current_OS,
                     other_surf_id,
                     &other_srf);
         EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end); 

        if(other_srf->planar == 1 )
           {
           *surfs_are_non_planar_coinc = FALSE;
           *non_planar_coinc_int_del =  FALSE;
           goto ret_end;
           }
         other_pos_orient = other_srf->pos_orient;

         BSsfarrevn (&msg_loc, other_srf, 1,
                          &UV_pt[0], 1, &UV_pt[1],
                          xyzpt_2, xyznor_2);
         EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

         BSnorvec(&msg_loc, xyznor_1);
         BSnorvec(&msg_loc, xyznor_2);
         dot_buster = BSdotp(&msg_loc, xyznor_1, xyznor_2);

         if ((other_pos_orient && !this_pos_orient) || 
                   ( !other_pos_orient &&  this_pos_orient))
             volume_on_same_side = (dot_buster < 0) ? TRUE :FALSE;
         else
             volume_on_same_side = (dot_buster < 0) ? FALSE : TRUE;

         if(found_edge)
           {
           if(volume_on_same_side)
              *non_planar_coinc_int_del = (angle_measure1 > angle_measure2) ?
                                            FALSE:TRUE;
           else
              *non_planar_coinc_int_del = (angle_measure1 > angle_measure2) ?
                                            TRUE:FALSE;
           }
         else
           {
           if( volume_on_same_side) 
              *non_planar_coinc_int_del = (ed_is_convex)? TRUE:FALSE;
           else
              *non_planar_coinc_int_del = (ed_is_convex)? FALSE:TRUE;
           }
 
 ret_end:
    EMWRAPUP (*msg, sts, "EMpush_coinc_ed.EMnon_planar_coinc");
    return (sts);
  }

IGRlong EMgetcommonsf (msg, mattyp, mat,
                        uvedge, uvos,
                         commsf, partolb)
 IGRlong *msg;
 IGRshort *mattyp;
 IGRmatrix mat;
 GRobjid  uvedge;
 GRspacenum uvos;
 struct GRid *commsf;
 struct EMSpartolbasis *partolb;
 {
 IGRlong count,msg_loc, stat_OM;
 GRobjid commedge;
 OM_S_CHANSELECT chan_to_common;
 OM_S_OBJECT_LINKAGE objlist;
 struct EMSpartolbasis *ptolptr;

   *msg = EMS_S_Success;
   stat_OM = OM_S_SUCCESS;

/*
* Initialize working variables
*/


  stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);
   EMerr_exit (stat_OM, ret_end);

/*
* Obtain information about the common edge
*/


   count = 0;
   stat_OM = om$get_channel_objects (objid = uvedge, osnum = uvos, 
     p_chanselect = &chan_to_common, list = &objlist, size = 1,
     count = (OMuint *)&count);
   EMerr_exit (stat_OM, ret_end);
   EMerr_hndlr (!count, *msg, EMS_I_NoSolution, ret_end);
   commedge = objlist.S_objid;

   if (! partolb->is_valid)
   {
      partolb->in_world = TRUE;
      partolb->mattyp = mattyp; 
      partolb->mat = mat;
      ptolptr = partolb;
   }
   else
      ptolptr = NULL;

   stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
       &commsf->objid, ptolptr), targetid = commedge, targetos = uvos,
       senderid = NULL_OBJID);
    EMerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
    commsf->osnum = uvos;

 ret_end:
    EMWRAPUP (*msg, stat_OM, "EMpush_coinc_ed.EMgetcommonsf");
     return (stat_OM);
 }

end implementation Root;
