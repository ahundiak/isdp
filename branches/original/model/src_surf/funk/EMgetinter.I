/*
 DESCRIPTION

 This function is designed to create the inters output for the features
 like ribs/webs. It takes in the base solid and three surfaces (which
 are going to be the part of rib or web) and generates two inters list. The
 first inters list is related to the base solid and second inters list
 comprises of intersections produced on the three surfaces. Call EMintersect_
 surfaces produces these results. What this function additionally does is
 the splitting of intersections if they happens to intersect each other.
 After the splitting each of the splitted intersections is modified to
 converge to the exact point of intersection since it may be involved
 in the split of other intersections. The split of other_intobj node and
 their refinement is taken care of at the same stage.

   The output of this function is inters list which have intersection data
 having atleast positional continuity with the other intersection lying
 on the surface.

 HISTORY

   Rustagi : ???????? : Creation
   NP      : 06/22/93 : Added code to make "fwd" & "bwd" connections between
                        split intobj's in logical directions.
   Sudha   : 07/06/93 : Modified for BSprototypes ansification
   NP      : 07/27/93 : Updated intobj split connections ("fwd", "bwd") so that
                        "incoming" ptr defaults to "intobj->bwd" and "outgoing"
                        ptr defaults to "intobj->fwd".
   NP      : 08/23/93 : Added "EMSINT_PARAM_OBJECT" & "EMS_SFINT_MUSTORIENT" 
                        options in intersect surfaces. Objects are created 
                        because the sliver code operates only on objects.
   NP      : 08/27/93 : To generate maximum intobjs on the "rib" surfaces, we 
                        need to simulate the condition when the rib surfaces
                        are "pushed" into the base solid in case of co-planarity
                        which means sending the rib surfaces as the first 
                        operand to intersect surfaces and the base solid second.

   NP      : 09/06/93 : Handle the case to set fwd and bwd pointers between two
                        intobjs that just "touch" at endpts and do not split 
                        each other. However, the flaw here is that if BOTH 
                        endpts of the intobjs touch each other, and we have NO
                        intersection in the middle, then fwd/bwd pointers are
                        set only for the FIRST endpt intersection as returned by
                        EFget_intersection_points(). Hopefully there will be 
                        very few cases like that.

   NP      : 09/10/93 : Added "status_str" parameter. Rearranged the call to 
                        intersect_surfaces so as to allow double check in case
                        of first pass failure.

   NP      :09/14/93  : The "split_info" for splitting intobjs has to be with
                        respect to the dataselect, and therfore we must NOT take
                        the reversed field of the intobj into account. Modified
                        code accordingly. This was causing model corruption!!!!!
   NP      :10/11/93  : Added code to handle non-manifold situations in rib 
                        placement. (i.e. when a profile ends on an edge and the 
                        extention does not enter volume).
   NP      :10/21/93  : After splitting intobjs, the refinement was not taking
                        care of keeping the xyz dataselect's data pointers for
                        "this" and "other" intobj consistent, if they were same
                        to begin with. This was causing crashes.(TR 119311859).
   NP      :11/24/93  : Removed non-manifold support. This will take some more
                        thought. Re-ordered the intersections with base solid
                        so that a new inters list is sent in every time. If not
                        refinement sometimes fails since intobjs are not split
                        at this stage. Also why work repeatedly on the same 
                        intobjs every time? Memory was not being freed on error.
   NP      :11/29/93  : Dont modify the intobjs in case triple surface iteration
                        returns EMS_I_NoSolution. Later modify the function
                        "EFrefine_the_intobj" so that "EMS_I_NoSolution" is 
                        returned ONLY if two of the surfaces are coplanar. All
                        other cases should result in error, if math fails.
   NP      :12/14/93  : In case of "type 2" ribs (thickness in profile plane)
                        which are no-extend, a SINGLE composite surface has been
                        generated for the rib, with cap plane(s), which is 
                        needed to  generate intersections on the correct surface
                        of the rib. Here, we need to reverse that procedure by 
                        uncapping the cap(s), so that we may have intersections
                        between rib surfaces so that we can "mark" intobjs and
                        close correct groups. 
   NP      :12/16/93  : While splitting intobjs, if the split point location on
                        the intobj was marked "EMS_PYPT_POSUNKNOWN", we were not
                        splitting that intobj.
   NP      :12/25/93  : You'd think I'd have something better to do on Christmas
                        Day right? You'd think wrong. Anyway, here goes: Due to
                        the refinemnt being done in stages, some intobjs had 
                        incorrect incidence info. Fixed it by calling new 
                        function EFfixendinfo().
   NP      :12/29/93  : Removed the old refine function"EFrefine_the_intobjs"
                        and completely rewrote it. Added checks for seam jumps.
                        Now refinement is done only ONCE per pair being split
                        and not twice as before. Also, if only one intobj from
                        a pair is split,the second intobj,(whose ENDPT will now
                        lie at the split point) is also modified. The name of
                        the new function is EMrefine_intobjs.
   NP      :12/29/93  : Unset all "connect" properties in the intobjs after the
                        intersections and before the splitting. Since these 
                        properties were not generated by intersecting ALL the
                        surfaces simultaneously many are probably incorrect. Any
                        wrong "noconnect"/"connect" can screw up trace later.
  Sanjay   :03/24/95  : If there is no intersection between none of the rib
                        surfaces, base solid error out.
  Sanjay   :08/13/95  : In "EMperform_split_intobjs", if there is an interaction
                        point at the start of the intersections then don't 
                        process this interaction point.
*/ 

class implementation Root;

%safe
#include <math.h>
%endsafe
#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "ex.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlogic.h"
#include "emsdattyp.h"
#include "EMSopt.h"
#include "emsinterdef.h"
#include "EMSprop.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "timerdef.h"
#include "bstrpsfiter.h"
#include "bsparameters.h"
#include "bsmdistptsf.h"
#include "bsprptonsf.h"
#include "bsdistptpt.h"
#include "bssfeval.h"

#define FIRST 0
#define SECOND 1

/***************
#define DEBUG 1
***************/

/* externs */

extern OMuword OPP_EMScompsurf_class_id;
extern OMuword OPP_EMSedge_class_id, OPP_EMSbsedge_class_id;

extern IGRlong EMintersect_surfaces();
extern IGRlong EMfind_uv_xyz_point();
extern IGRint EMgetendpts_xyz(), EMgetendpts();
extern void EMsortpypts();
extern void EMpypoint_free(), EMcmpinters(), EMmergeinters();
extern IGRint EMextend_poly(), EMextend_curve(), EMextend_object();
extern void EFget_intersection_points();
extern IGRboolean EMis_same_dataselect();
extern void EMgetincinfo();
extern void EMinters_data_free(), EMinters_free(), EMsfintedpar_free();
extern void EFtransfer_inters();
extern IGRint EMgetvggeom(), EMgetendpts();
extern IGRlong EMrefine_intobjs();
extern IGRboolean EFfind_closest_uv_side();
/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;


%safe
static void EFfixendinfo();
#ifdef DEBUG
IGRlong total_refines=0, extracts=0;
#endif
%endsafe

/* imports */

from EMSsubbs import EMpartolbasis, EMget_edges;
from GRvg import GRgetsize, GRgetgeom, GRdisconn;
from EMSedge import EMextend_geom, EMget_props, EMset_props, EMptproject;

#ifdef __STDC__
#argsused
#else
/*ARGSUSED*/
#endif

IGRlong EFcreate_inters(msg,
                        base_solid,
                        modenv,
                        feasfs,
                        num_feasfs,
                        num_caps,
                        const_args,
                        options,
                        sf1_inters,
                        sfs2_inters,
                        status_str)
IGRlong *msg;
struct GRid *base_solid;
struct GRmd_env *modenv;
struct GRid **feasfs;
IGRint *num_feasfs, num_caps;
struct GRvg_construct *const_args;
IGRlong options;
struct EMSinters **sf1_inters, **sfs2_inters;
IGRchar *status_str;
/*

 ARGUMENTS
 
 msg          output : The returned code message.
 base_solid   Input  : GRid of the base solid.
 modenv_base  Input  : Module environment info of the base solid.
 feasfs       Input  : Array of GRid's of the input surfaces.
 modenv_fea   Input  : module environment info for feature surfaces i.e
                       They are assumed to be created in the same module
                       environment.
 const_args   Input  : Construct list arguments.
 options      Input  : Argument for any future use. Currently not in
                       use.
 sf1_inters   Output : Inters list corresponding to the base solid.
 sfs2_inters  Output : Inters list corresponding to the second operand.
                       It contains the intersections on the top, side1 and 
                       side2 surfaces.
 status_str   Input/ : Dots are added to this string as the intersect surfaces
              Output   functions is called over and over.
*/
{
IGRlong msg_loc, status;
OM_S_CHANSELECT to_owners, to_common_edge;
OM_S_OBJECT_LINKAGE common_edge[1];
OMuint count;
IGRushort world_opt, param_opt, inters_opt, trim_opt;
IGRint num_inters, i, j, loc_num_inters;
struct GRid *sfs2ids=NULL, *edges=NULL;
struct EMSinters *inters[2], *inters_loc, **feainters=NULL, **baseinters=NULL;
struct EMSinters **inters_ptr=NULL;
struct EMSintobj *intobj_loc=NULL;
struct EMSdataselect *sfs2data=NULL, base_data;
IGRlong EMperform_split_intobjs();
GRspacenum const_os, comp_os;
IGRdouble *mat, cht_tol;
IGRshort mattyp;
IGRint num_comps, array_size=0, num_edges=0;
GRobjid *comps=NULL;
IGRboolean is_comp;
IGRboolean save_pathway_trim, save_pathway_orient;

/* 
 *initialisation
 */
 *msg     = EMS_S_Success;
 status   = OM_S_SUCCESS;
 const_os = const_args->env_info->md_id.osnum;
 mat      = const_args->env_info->md_env.matrix;
 mattyp   = const_args->env_info->md_env.matrix_type;

 BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);
 cht_tol *= 2;

 /* If this is a type 2 rib placed as a no-extend, then we have to unlink the 
  * cap surfaces (2 if finite and 1 if not) from the rib composite surface, so
  * that our intobj marking algorithm can mark the trace intobjs. The unlinking
  * however, is to be done AFTER intersecting the rib surfaces with the base 
  * solid. Also, in case we have capped surfaces, then there should be only ONE
  * composite surface coming in (that includes one or both caps).
  */

 if (num_caps)
 {
     EMerr_hndlr (*num_feasfs != 1, *msg, EMS_E_InvalidArg, ret_end);
 }

 inters[FIRST] = NULL;
 inters[SECOND] = NULL;
 intobj_loc = NULL;
 feainters = NULL;
 baseinters = NULL;
 feainters = (struct EMSinters **) om$malloc (size = (*num_feasfs) * 
                                      sizeof(struct EMSinters *));
 baseinters = (struct EMSinters **) om$malloc (size = (*num_feasfs) * 
                                      sizeof(struct EMSinters *));
 for(i=0; i<*num_feasfs; i++)
 {  feainters[i] = NULL;
    baseinters[i] = NULL;
 }

 status = EMmake_chanselect (GRconnector_to_owners, &to_owners);
 EMSmsgReport(status, "EFcreate_inters: chan select", FALSE);

 status = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, ret_end);

 /* The intersections are being performed between the following
  * set of operands ...
  * (1) between base solid and all surfaces input in feasfs.
  * (2) between the surfaces within feasfs.
  * The intersections which are being produced in (2) are being
  * marked specially.
  */
 trim_opt  = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA |
             EMSINT_TRIM_COPLANAR | EMSINT_TRIM_PROCOVERLAP;
 world_opt = EMSINT_OUTPUT_WORLD | EMSINT_WORLD_NOTYPEDCV;
 param_opt = EMSINT_OUTPUT_PARAM | EMSINT_ORIENT_OUTPUT | EMSINT_PARAM_OBJECT; 

 /* NOTE: The option "EMS_SFINT_AUTODOUBLECHECK" has to be used very carefully.
  * ----  Internally, "EMintersect_surfaces" frees the inters lists on error
  *       during regular check and recursively calls itself after OR'ing in 
  *       the "EMS_SFINT_DOUBLECHECK" bit. Now, if a SEPARATE set of inters 
  *       lists is not used for every call of "EMintersect_surfaces", there is
  *       the danger of freeing valid intersections from earlier calls, in case 
  *       the recursive call is made. Now, for the intersections between the 
  *       rib surfaces and the base solid, we DO send in separate lists for each
  *       call to "EMintersect_surfaces" and later merge the result. Therefore,
  *       in this case, setting "EMS_SFINT_AUTODOUBLECHECK" is OK. But for 
  *       intersections between the rib surfaces, the same inters lists are sent
  *       in multiple times and therefore, we CANNOT set this bit. So, for 
  *       those intersections, we choose to set "EMS_SFINT_DOUBLECHECK" always,
  *       so there is no question of mistakenly freeing good intersections in 
  *       case of error. Admittedly, always setting double check is an overhead
  *       but there are very few rib surfaces compared to surfaces in base solid
  *       and therfore, this is OK. (NP 12/12/93).
  */

 inters_opt= EMS_SFINT_MUSTINTERSECT | EMS_SFINT_PUSHBADCOINC |
             /*EMS_SFINT_MUSTORIENT |*/ EMS_SFINT_MUSTNOAMBIGUOUS | 
             EMS_SFINT_AUTODOUBLECHECK;
/*
 * Finding the intersection between the base solid and the surfaces in put
 * in feasfs.
 */
 sfs2ids = (struct GRid *) om$malloc (size = (*num_feasfs) * 
                                       sizeof(struct GRid)); 
 EMerr_hndlr(!sfs2ids, *msg, EMS_E_NoDynamicMemory, ret_end);

 sfs2data = (struct EMSdataselect *) om$malloc (size = (*num_feasfs) *
                                        sizeof(struct EMSdataselect));
 EMerr_hndlr(!sfs2data, *msg, EMS_E_NoDynamicMemory, ret_end);

 for(i=0; i<*num_feasfs; i++)
 {
 sfs2ids[i].objid = (*feasfs)[i].objid;
 sfs2ids[i].osnum = (*feasfs)[i].osnum;
 sfs2data[i].datatype = EMSdata_object;
 sfs2data[i].data.object = &sfs2ids[i];
 }
/* The following call of EMintersect_surfaces() will find all the 
 * intersections on the solid.
 */
 loc_num_inters = num_inters = 0;
 base_data.datatype = EMSdata_object;
 base_data.data.object = base_solid;

 /* NOTE: It is VERY important that we send in a fresh inters list for every 
  * call of EMintersect_surfaces. If we send in the same list every time, then
  * although it MAY still work fine, all the post processing calls within the 
  * "EMintersect_surfaces" function such as duplicate processing, tracing, 
  * refinement, data fitting etc. etc. will be done on the SAME data (from prior
  * calls to "EMintersect_surfaces") again and again and again. This is a waste
  * of compute resources and also could lead to problems with tracing and 
  * refinement since intobjs on the surfaces of the base solid from different 
  * rib surfaces may not meet at endpts, since rib surfaces are extended. 
  * Tracing is done specially on the rib surfaces individully in a later 
  * function call and we dont want the trace function within 
  * "EMintersect_surfaces" to trace across the entire inters list for both the 
  * base solid AND the feature surfaces. Hence we send in individual lists and 
  * later merge them. Prevent "status str" being sent in repeatedly. Doesn't 
  * look very good to the user.
  * (NP 10/22/93)
  */

 for(i = 0; i < *num_feasfs; i++)
 {
    save_pathway_trim = _pathway_trim;
    save_pathway_orient = _pathway_orient;
    _pathway_trim = 0;
    _pathway_orient = 0;

    loc_num_inters = 0;
    status = EMintersect_surfaces (&msg_loc, &sfs2ids[i],
                   &modenv->md_env, 1, &base_data,
                   &modenv->md_env, 
                   inters_opt,
                   world_opt,
                   param_opt, 
                   trim_opt /*| EMSINT_TRIM_IGNOREVOLUME*/,
                   const_args,
                   &loc_num_inters, &feainters[i], &baseinters[i],
                   NULL, NULL, NULL, NULL, NULL);

    _pathway_trim = save_pathway_trim;
    _pathway_orient = save_pathway_orient;


      if(msg_loc == EMS_E_NoIntersection)
      {
       msg_loc = EMS_I_NoIntersection;
       status = OM_S_SUCCESS;
      }

      EMerr_hndlr(!(1&status&msg_loc), *msg, msg_loc, ret_end);

      num_inters += loc_num_inters;
 }

 /*
  * None of the rib surfaces is intersecting with the base solid. I don't
  * think, there is no point in placing the feature in the space. So, error
  * out.
  */
 EMerr_hndlr(!num_inters, *msg, EMS_E_Fail, ret_end);

  /* Intersections with base solid are completed */
  if (status_str)
  {  strcat (status_str, ".");
     UI_status(status_str);
  }

  /* merge the array of inters lists above to create one inters list each for
   * the base solid and the feature surfaces.
   */
  for(i=0; i<*num_feasfs; i++)
  {
    if(baseinters[i])
    {
      EMmergeinters(&msg_loc, &inters[FIRST], baseinters[i]);
      baseinters[i] = NULL; /* do this BEFORE error check, so that it is not 
                             * freed twice below.
                             */
      EMerr_hndlr(!(1&msg_loc), *msg, msg_loc, ret_end);
    }
    if(feainters[i])
    {
      EMmergeinters(&msg_loc, &inters[SECOND], feainters[i]);
      feainters[i] = NULL;
      EMerr_hndlr(!(1&msg_loc), *msg, msg_loc, ret_end);
    }
  }

 /* Fix any incorrect incidence information due to refinement done in stages, 
  * i.e. surface by surface.  Note that rib surfaces are going one-by-one
  * into successive calls of the function inside the for loop. Let us say rib
  * surface A intersected an edge E of base solid and edge E was refined at the
  * intersection. The intobj on the surface S of the base solid due to A, had 
  * its "more_info" modified (span-inx, param), since its original span-inx and
  * param were no longer valid, since E's geometry was changed. Now along comes
  * the next surface from the rib, surface B and also intersects the same edge E
  * on the base solid. Again, E was refined and this time the intobj due to the 
  * surface B on surface S had its "more-info" correctly modified with respect 
  * to the once again modified geometry of the edge. By now you must be smiling,
  * right? You are saying, BUT WAIT!!!! What happens to the intobj on surface S
  * that was generated by surface A? It's "more_info" will have to be modified 
  * too, since it is incident on the SAME edge!!! At which point, I would tell 
  * you, I am sorry, that surface was in the previous iteration, and since its 
  * trace data was NOT available during THIS iteration, the refinement code did
  * not KNOW that there was another intobj incident on edge E. AH HA!!! Now we 
  * know what the problem is. The refinement function needs the complete trace 
  * data from both the rib and the base solid to do its job. But we know this
  * is NOT possible. We cannot and SHOULD not pass in trace data for the rib
  * surfaces at this stage. SInce the rib surface are NOT common-edge connected
  * yet, there is the danger of intobj incidence info being snapped to the 
  * vertices by the refinement code (the refinement code always considers that
  * ALL the surfaces in an inters list are common-edge connected at AT LEAST one
  * other surface in the same list - for ribs, this need not be so). 
  *     Therfore, we update ALL available incidence info of intobjs that have
  * valid edge ids in their incidence info. Now the inters list can be 
  * considered to be "clean" again, and ready for further processing.
  * (NP 12/25/93)
  */
 
 (void) EFfixendinfo (&msg_loc, &mattyp, mat, inters[FIRST]);
 EMerr_hndlr(!(1&msg_loc), *msg, msg_loc, ret_end);

 (void) EFfixendinfo (&msg_loc, &mattyp, mat, inters[SECOND]);
 EMerr_hndlr(!(1&msg_loc), *msg, msg_loc, ret_end);

 /* Do the duplicate processing only. Tracing will be internally done,
  * but is not returned. There is no option to skip tracing. Also, refinement
  * has already been done, we do not do it here. If it is done here, there is
  * also the danger of refinement code incorrectly pushing endpts of intobjs to
  * vertices, since all surfaces on inters[SECOND] are not common edge connected
  * yet. They will be, at the end of the boolean.
  */

 save_pathway_trim = _pathway_trim;
 save_pathway_orient = _pathway_orient;
 _pathway_trim = 0;
 _pathway_orient = 0;

 status = EMintersect_surfaces (&msg_loc, NULL, 
                   &modenv->md_env, 0, NULL, &modenv->md_env,
                   EMS_SFINT_SKIPSFINT | EMS_SFINT_NOREFINE,
                   NULL, NULL, NULL, const_args,
                   NULL, &inters[FIRST], &inters[SECOND],
                   NULL, NULL, NULL, NULL, NULL); 

 _pathway_trim = save_pathway_trim;
 _pathway_orient = save_pathway_orient;

 EMerr_hndlr(!(1&status&msg_loc), *msg, msg_loc, ret_end);



/* This is an important step. As already explained above, we may need to unlink
 * the "cap surface" in a composite so as to generate intersections between the
 * side surfaces and the cap planes, which intersections we can then "mark" 
 * specially in helping us close trace groups. If we do not unlink the caps,
 * there are NO intersections between rib surfaces, therefore no intobjs to be
 * marked, therefore algorithm concludes none of the intersections on the rib
 * surfaces (those that came from base solid) are needed and everything ends up
 * getting deleted.
 */

 if (num_caps)
 {
    /* For each cap, we need to unlink it from the composite and ADD it to the
     * array of surfaces, reallocing space in the array as necessary. We simply
     * disconnect ALL edges in the loopset of the disconnected surface, thereby
     * breaking all ties to the incoming composite. We cannot delete its 
     * existing loops, since there might be existing intersections which have
     * existing edges as part of their endpt sfintedpar info.
     * NOTE: Caps are always at the END of the channel, which is ensured while
     * ----  they are created.
     */

    num_comps=0;
    comps = NULL;
    (void)EFget_components(&msg_loc,&((*feasfs)[(*num_feasfs)-1]),
                                    &num_comps,&comps,&is_comp);
    EMerr_hndlr(!(1&msg_loc), *msg, msg_loc, ret_end);

    comp_os = ((*feasfs)[0]).osnum;

    for (i=0; i< num_caps; i++, num_comps--)
    {
      /* disconnect from composite */
      status = om$send (msg = message GRvg.GRdisconn(&msg_loc, &((*feasfs)[0])),
                          senderid = NULL_OBJID,
                          targetid = comps[num_comps-1],
                          targetos = comp_os);
      EMerr_hndlr(!(1&status&msg_loc), *msg, msg_loc, ret_end);

      /* add it to the surfaces array */
      *feasfs = (struct GRid *)om$realloc(
                        ptr  = (IGRchar *)(*feasfs),
                        size = (*num_feasfs + 1) * sizeof(struct GRid));
      EMerr_hndlr(!(*feasfs), *msg, EMS_E_NoDynamicMemory, ret_end);

      /* add the disconnected surface to the list of rib surfaces */
      (*feasfs)[(*num_feasfs)].objid = comps[num_comps-1];
      (*feasfs)[(*num_feasfs)].osnum = comp_os;
      (*num_feasfs)++;

      /* since the next major step will be intersection AMONG the rib surfaces,
       * we need to create a inters list for EACH logical rib surface. One 
       * list for the incoming composite surface already exists.  Every time 
       * we unlink a surface from the composite, we create an inters list 
       * pointer for the newly unlinked surface and TRANSFER the inters node 
       * from the original comp. surfaces's inters list to the new list. This 
       * is to maintain sanctity of indices for the next call of "EMintersect_
       * surfaces". We also need to realloc the arrays "sfs2ids" &  "sfs2data" 
       * which are used in that call.
       */

      sfs2ids = (struct GRid *) om$realloc (
                         ptr  = (IGRchar *)sfs2ids,
                         size = (*num_feasfs * sizeof(struct GRid)));
      EMerr_hndlr(!sfs2ids, *msg, EMS_E_NoDynamicMemory, ret_end);

      sfs2data  = (struct EMSdataselect *) om$realloc (
                         ptr  = (IGRchar *)sfs2data,
                         size = (*num_feasfs * sizeof(struct EMSdataselect)));
      EMerr_hndlr(!sfs2data, *msg, EMS_E_NoDynamicMemory, ret_end);

      /* Because of realloc, pointer to data object will be different. 
       * Reassign all. 
       */
      for(j=0; j<*num_feasfs; j++)
      {
         sfs2ids[j].objid = (*feasfs)[j].objid;
         sfs2ids[j].osnum = (*feasfs)[j].osnum;
         sfs2data[j].datatype = EMSdata_object;
         sfs2data[j].data.object = &sfs2ids[j];
      }

      /* alloc memory for pointers to a new inters list pointer */
      feainters = (struct EMSinters **) om$realloc (
                             ptr  = (IGRchar *)feainters,
                             size = (*num_feasfs * sizeof(struct EMSinters *)));
      EMerr_hndlr(!feainters, *msg, EMS_E_NoDynamicMemory, ret_end);
    
      for(j=0; j<*num_feasfs; j++)
         feainters[j] = NULL;

      /* get ALL the edges on the disconnected surface */
      array_size=0;
      num_edges=0;
      edges=NULL;
      status = om$send (msg = message EMSsubbs.EMget_edges (&msg_loc, MAXINT,
                              EMS_OPT_ALL,modenv,&edges,&array_size,&num_edges),
                           senderid = NULL_OBJID,
                           targetid = comps[num_comps-1],
                           targetos = comp_os);
      EMerr_hndlr (!(status&msg_loc&1), *msg, EMS_E_LoopsetError, ret_end);
 
      /* now disconnect all the common edges of the surface's loops. Make sure
       * all common-edge related bits are unset.
       */
      for (j=0; j<num_edges; j++)
      {
         /* no need to check for existence of common edge */

          status = om$get_channel_objects (osnum=edges[j].osnum, 
                                  objid=edges[j].objid,
                                  p_chanselect = &to_common_edge,
                                  list=common_edge, size=1,
                                  count = &count);
          EMerr_hndlr (!(status&1), *msg, EMS_E_OMerror, ret_end);

          status = om$send(msg = message Root.wild_disconnect(to_common_edge),
                                targetid = edges[j].objid,
                                targetos = edges[j].osnum,
                                senderid = NULL_OBJID);
          EMerr_hndlr (!(1&status), *msg, EMS_E_OMerror, ret_end); 

          status = om$send(msg = message EMSedge.EMset_props(&msg_loc, 
                            (EMED_REVERSE_CONNECT|EMED_SUBORDINATE), EMS_O_OFF),
                                targetid = edges[j].objid,
                                targetos = edges[j].osnum,
                                senderid = NULL_OBJID);
          EMerr_hndlr (!(1&status&msg_loc), *msg, EMS_E_OMerror, ret_end); 

          status = om$send(msg = message EMSedge.EMset_props(&msg_loc, 
                            (EMED_REVERSE_CONNECT|EMED_SUBORDINATE), EMS_O_OFF),
                                targetid = common_edge[0].S_objid,
                                targetos = comp_os,
                                senderid = NULL_OBJID);
          EMerr_hndlr (!(1&status&msg_loc), *msg, EMS_E_OMerror, ret_end); 

      }
    }
 }

/*
 * The following calls of EMintersect_surfaces() finds the intersection
 * with in the surfaces input through feasfs. It is to be noted that same
 * inters list is being passed in the arguments stands for the inters corre-
 * sponding to operand1 and operand2. We dont need to set EMS_TRIM_IGNOREVOLUME
 * here because all intersections generated will be manifold (NP 10/22/93).
 */

  inters_opt &= ~(EMS_SFINT_MUSTNOAMBIGUOUS | EMS_SFINT_AUTODOUBLECHECK);
  inters_opt |=   EMS_SFINT_DOUBLECHECK | EMS_SFINT_NOREFINE;
  param_opt  |=   EMSINT_ORIENT_RIGHT; 

  loc_num_inters = 0;
  for(i=0; i<*num_feasfs; i++)
  {
    for(j=i+1; j<*num_feasfs; j++)
    {
        save_pathway_trim = _pathway_trim;
        save_pathway_orient = _pathway_orient;
        _pathway_trim = 0;
        _pathway_orient = 0;

        status = EMintersect_surfaces (&msg_loc, &((*feasfs)[i]), 
                      &modenv->md_env,
                      1, &sfs2data[j], &modenv->md_env, 
                      inters_opt,
                      world_opt, param_opt, trim_opt, 
                      const_args, &loc_num_inters, &feainters[i], 
                      &feainters[j], NULL, NULL, NULL, NULL, NULL);

        _pathway_trim = save_pathway_trim;
        _pathway_orient = save_pathway_orient;

        if(msg_loc == EMS_E_NoIntersection)
        {
        msg_loc = EMS_I_NoIntersection;
        status = OM_S_SUCCESS;
        }
         
        EMerr_hndlr(!(1&status&msg_loc), *msg, msg_loc, ret_end);

    }
  }

  /* All intersections are completed */
  if (status_str)
  {  strcat (status_str, ".");
     UI_status(status_str);
  } 

  /* Unsetting of the EMSintobj_tmpmarked property bit incase it happens
   * to be set through the boolean processing. It needs to be unsetted
   * for those intersections coming from the base solid on the second
   * intersection list.
   */

  /* Intobjs created BETWEEN the surfaces of the rib have to be marked with a
   * special bit "EMSintobj_tmpmarked". This bit differentiates intobs on the
   * rib surfaces which have been generated with another rib surface versus 
   * those generated against the base solid. Before marking intobjs as desired,
   * remove any such markings (on rib surfaces) that MAY have come from 
   * the base solid.
   */

  inters_loc = inters[SECOND];
  while(inters_loc)
  {  if(inters_loc->cvs)
     { intobj_loc = inters_loc->cvs;
       while(intobj_loc)
       { intobj_loc->props &= ~EMSintobj_tmpmarked;
         if(intobj_loc->other_intobj_node)
           intobj_loc->other_intobj_node->props &= ~EMSintobj_tmpmarked;
         intobj_loc = intobj_loc->next;
       }
     }
     inters_loc = inters_loc->next;
  }

  for(i=0; i<*num_feasfs; i++)
  { if(feainters[i])
    { inters_loc = feainters[i];
      while(inters_loc)
      { intobj_loc = inters_loc->cvs;
        while(intobj_loc)
        { intobj_loc->props |= EMSintobj_tmpmarked;
          intobj_loc = intobj_loc->next;
        }
        inters_loc = inters_loc->next;
      }
    }
  }

/*
 * Now we merge the inters linked lists in the feainters array into
 * inters[SECOND] to create a consolidated inters list for the rib surfaces, 
 * after which we will be finally left with just two inters lists,  one for the
 * base solid (inters[FIRST]) and one for the rib surfaces (inters[SECOND]).
 */
  for(i=0; i<*num_feasfs; i++)
  {
    if(feainters[i])
    {
      EMmergeinters(&msg_loc, &inters[SECOND], feainters[i]);
      feainters[i] = NULL;
      EMerr_hndlr(!(1&msg_loc), *msg, msg_loc, ret_end);
    }
  }

 EMcmpinters(&msg_loc, &inters[SECOND]);
 EMerr_hndlr(!(1&msg_loc), *msg, msg_loc, ret_end);


/* for EVERY intobj on the second (rib surface) list, UNSET the 
 * "EMSintobj_marked" bit, because this bit will be used later on to select
 * intobjs to initiate tracing. We mark intobjs ONLY on rib surfaces.
 */
 inters_loc = inters[SECOND];
 while(inters_loc)
 { if(inters_loc->cvs)
   { intobj_loc = inters_loc->cvs;
     while(intobj_loc)
     { intobj_loc->props &= ~EMSintobj_marked;
       intobj_loc = intobj_loc->next;
     }
   }
   inters_loc = inters_loc->next;
 }

 /* Since we have intersected rib surfaces with the base solid and then 
  * separately intersected rib surfaces among themselves, we may
  * have duplicates on the rib surfaces.  This would be a good place to remove
  * those duplicates. HOWEVER, there is a BIG problem. There might be duplicates
  * on the rib surfaces that run opposite to each other, NOT because they are
  * from a non-manifold intersection, but because one of these intersections 
  * come from the base solid and the other came from another rib surface. This
  * is because the operation between rib surfaces is an INTERSECTION, while 
  * between the rib surfaces and the base solid we do a UNION. Therefore you can
  * have oppositely oriented intersection on the rib surface. In such cases, we
  * DONT want to remove both (which the EMfixsfintout calls will do by default,
  * for oppositely oriented intersections). The correct one will usually be 
  * kept after doing the individual trace on the rib surfaces, which comes 
  * later down in the code. Even when there are genuine duplicates, but where
  * one is a subset of the other, we should actually delete the smaller of the
  * two. Although, the "delsfintdup" function called from  EMfixsfintout DOES 
  * check for one being the subset of the other (by taking a pair of intobjs and
  * projecting each on the other) the deletion criteria is rigid,  ie. delete
  * "marked" (which is the incoming intobj) or delete "unmarked" (which is the
  * intobj on the inters list that matches incoming intobj's geometry). 
  * Therefore EVEN if the function found that the "marked" or incoming  intobj 
  * was the smaller of the two (or subset), the deletion criteria might be to
  * delete "unmarked", which will simply delete the superset. This is usually 
  * not a problem for regular intersections between surfaces, where the 
  * duplicates are usually of the same size, but with special algorithms such as
  * the rib, we run into the subset-superset problems. 
  *    For all these reasons, we dont do the duplicate processing on the rib
  * intersections at this point. 
  * (NP 12/28/93)
  */


  /* Due to intersection between surfaces and rib being done in different calls
   * to the interscet surfaces function, we cannot believe any "connect"
   * properties set. This is because while these properties were being set
   * all the intersections on that surface may not have been created. Therefore
   * it is dangerous to have these properties around, as they can cause much
   * heart-ache later when we want to close groups. Delete those properties here
   * before getting into the split code. The split code sets these properties on
   * the rib surfaces, between the split pairs.
   */
  for (i=0; i<2; i++)
  { inters_loc = (i==0? inters[FIRST] : inters[SECOND]);
    while (inters_loc)
    { intobj_loc = inters_loc->cvs;
      while (intobj_loc)
      { intobj_loc->props &= ~(EMSintobj_fwd_noconnectuv |
                               EMSintobj_bwd_noconnectuv |
                               EMSintobj_fwd_connectuv   |
                               EMSintobj_bwd_connectuv);
        intobj_loc->fwd = NULL;
        intobj_loc->bwd = NULL;

        intobj_loc = intobj_loc->next;
      }
      inters_loc = inters_loc->next;
    }
  }

/* The marking of the intersections has been completed and now the 
 * splitting has to take place between the those which has been
 * marked as 'EMSintobj_marked' and the one which are not marked.
 */
#ifdef DEBUG
 total_refines=0; extracts=0;
#endif
 status = EMperform_split_intobjs(&msg_loc,
                                  inters[SECOND],
                                  modenv,
                                  EMSintobj_tmpmarked,
                                  NULL,
                                  NULL,
                                  EMSintobj_tmpmarked);
 EMerr_hndlr (EMSerror (status & msg_loc), *msg, EMS_E_Fail, ret_end);

 #ifdef DEBUG
   printf ("Total refines = %d\n", total_refines);
   printf ("Total extracts = %d\n", extracts);
 #endif

 /* Splitting of intobjs complete */
 if (status_str)
 {  strcat (status_str, ".");
    UI_status(status_str);
 } 

 *sf1_inters = inters[FIRST];
 *sfs2_inters = inters[SECOND];

         
ret_end:

  /* on error, free any inters lists created in here */
  if (!(1&status&*msg))
  { for (i=FIRST; i<SECOND; i++)
    { inters_ptr = (i==FIRST? &inters[FIRST] : &inters[SECOND]);
      if (*inters_ptr)
      { EMinters_data_free (&msg_loc, *inters_ptr, MAXINT, NULL,
                        EMsfintedpar_free);
        EMinters_free (*inters_ptr, MAXINT);
        *inters_ptr = NULL;
      }
    }

    for (i=0; i<*num_feasfs; i++)
    { 
        if (feainters && feainters[i])
        { EMinters_data_free (&msg_loc, feainters[i], MAXINT, NULL,
                         EMsfintedpar_free);
          EMinters_free (feainters[i], MAXINT);
          feainters[i] = NULL;
        }
        if (baseinters && baseinters[i])
        { EMinters_data_free (&msg_loc, baseinters[i], MAXINT, NULL,
                         EMsfintedpar_free);
          EMinters_free (baseinters[i], MAXINT);
          baseinters[i] = NULL;
        }
    }

  }/*if ERROR*/

  if (feainters)
    {om$dealloc (ptr = feainters);}
  if (baseinters)
    {om$dealloc (ptr = baseinters);}
  if (sfs2ids)
    {om$dealloc (ptr = sfs2ids);}
  if (sfs2data)
    {om$dealloc (ptr = sfs2data);}

  EMWRAPUP (*msg, status, "In EFcreate_inters");
  return(status);
}  

/* IMPORTANT: This function assumes that the "uv_split_info" in the form of
 * ---------  EMSpypoint, is w.r.t. the "this_uvintobj" dataselect of the 
 *            intobj and not with respect to the LOGICAL direction of the intobj
 *            (NP 09/14/93)
 */

IGRlong EMset_pypt_props(msg,
                         modenv,
                         intobj,
                         uv_split_info)
IGRlong *msg;
struct GRmd_env *modenv;
struct EMSintobj *intobj;
struct EMSpypoint *uv_split_info;
{
 IGRlong msg_loc, status;
 struct EMSpypoint *tmp_pypt, xyz_split_info;
 IGRpoint xyz_pt_start, xyz_pt_stop, int_point;
 IGRdouble dist[2], xyz_chd_ht;
 BSrc rc;

 *msg = EMS_S_Success;
 status = OM_S_SUCCESS;
 BSEXTRACTPAR (&rc, BSTOLCHRDHT, xyz_chd_ht);
 if(uv_split_info)
 {
   /* get the endpts of the DATASELECT and NOT the LOGICAL endpts of the intobj.
    * (i.e. the "intobj->reversed" bit is NOT applied). However, it IS 
    * assumed that the UV and XYZ data have same flow. This is achieved by 
    * setting the "reverse" field to FALSE.
    */
   status = EMgetendpts_xyz(&msg_loc, &modenv->md_env.matrix_type,
                modenv->md_env.matrix, &intobj->this_xyzintobj,
                FALSE, 1,
                xyz_pt_start, xyz_pt_stop);
   EMerr_hndlr(EMSerror(status & msg_loc), *msg, EMS_E_Fail, ret_end);
   tmp_pypt = uv_split_info;
   while(tmp_pypt)
   {
     /* check only those nodes that are NOT marked stop or start, to see if 
      * they COULD possibly be at an endpt of the dataselect. The only cases
      * will enter the "if" statement are "ATMIDDLE", "ATEND" or "POSUNKNOWN".
      */
     if (!(tmp_pypt->props & (EMS_PYPT_ATSTART | EMS_PYPT_ATSTOP)))
     {
        status = EMfind_uv_xyz_point(&msg_loc, &modenv->md_env,
                        &intobj->this_obj_node->this_obj, NULL,
                        &intobj->this_uvintobj, &intobj->this_xyzintobj,
                        TRUE, NULL, tmp_pypt, &xyz_split_info);
        EMerr_hndlr(EMSerror(status & msg_loc), *msg, EMS_E_Fail, ret_end);

        OM_BLOCK_MOVE(xyz_split_info.point, int_point, sizeof(IGRpoint));

        dist[0] = BSdistptpt(&rc, xyz_pt_start, int_point);
        dist[1] = BSdistptpt(&rc, xyz_pt_stop, int_point);

        /* The first two cases should trap the "ATEND" cases or the "ATMIDDLE"
         * cases that are within cht of an endpt.
         */
        if(dist[0] < xyz_chd_ht)
        {
          tmp_pypt->props |= EMS_PYPT_ATEND | EMS_PYPT_ATSTART;
          tmp_pypt->props &= ~(EMS_PYPT_ATMIDDLE|EMS_PYPT_POSUNKNOWN);
        }
        else if(dist[1] < xyz_chd_ht)
        {
          tmp_pypt->props |= EMS_PYPT_ATEND | EMS_PYPT_ATSTOP;
          tmp_pypt->props &= ~(EMS_PYPT_ATMIDDLE|EMS_PYPT_POSUNKNOWN);
        }
        else if (tmp_pypt->props & EMS_PYPT_POSUNKNOWN)
        { /* Added this & the next case.The above two cases catch the following:
           *       - props are "ATMIDDLE", but pt is within cht of endpt.
           *       - props are "ATEND"
           * But, we also have to trap the "POSUNKNOWN" case.
           * (NP, 12/16/93).
           */
           tmp_pypt->props |= EMS_PYPT_ATMIDDLE;
           tmp_pypt->props &= ~EMS_PYPT_POSUNKNOWN; 

        }
        else if (!(tmp_pypt->props & EMS_PYPT_ATMIDDLE))
        {
           EMerr_hndlr(TRUE, *msg, EMS_E_Fail, ret_end);
        }
    }
    tmp_pypt = tmp_pypt->next;
   }
 }
ret_end:


EMWRAPUP (*msg, status, "In EMset_pypt_props");
return(status);
}


/*
 * This function takes in a link list of EMSpypoint and checks for the
 * property bit. It deletes those pypoints from the list for which
 * the property is "NOT"  EMS_PYPT_ATMIDDLE. This function was written
 * to avoid the splitting of intobj's when the split point happens to
 * lie at the end point of the intobj. The retained pypoint liked list is
 * then sorted and returned. 
 */
/*
 * Function which takes in link list of EMSpypoints and a node address to be
 * deleted.
 */
struct EMSpypoint *EMprocess_pypoint_list(list, node)
struct EMSpypoint *list, *node;
{
struct EMSpypoint *header, *temp, *header_next;
/*
void EMsortpypts();
extern void EMpypoint_free();
*/

 header = temp = header_next = NULL;
 if(list)
 {
 header = list;
 if(header = node)
  {
  header_next = header->next;
  EMpypoint_free(header, 1); 
  header = header_next;
  }
 else
  {
  temp = header;
  while(temp != node)
   temp = temp->next;
  EMpypoint_free(temp, 1);
  }
 }
 return(header);
}

/* Here it is assumed that the two intobjs in question are lying
 * on the same surface. Moreover it is taken that two inters list
 * belonging to the two operands ( Note that if we have an intobj,
 * in a sense we have access to the surfaces belonging to the
 * other inters list through "other_intobj_node" pointer. Here I
 * am emphasising again that the two inters list have been created in
 * the same module environment.
 */
IGRlong EMperform_split_intobjs(msg,
                                inters,
                                modenv,
                                checkpresent_a,
                                checkabsent_a,
                                checkpresent_b,
                                checkabsent_b)
IGRlong *msg;
struct EMSinters *inters;
struct GRmd_env *modenv;
IGRlong checkpresent_a, checkabsent_a, checkpresent_b, checkabsent_b;
{
IGRlong status, msg_loc;
IGRint num_int, i;
IGRboolean world, *split_intobj, split_intobj1, split_intobj2;
IGRboolean set_pointers, set_ptr_for_1, set_ptr_for_2;
IGRboolean intobj1_intr_at_logical_start, intobj2_intr_at_logical_start;
IGRushort *other_prop_at_intr, prop1_at_intr_with_2, prop2_at_intr_with_1;
IGRulong intobj1_props=NULL, intobj1_other_props=NULL;
IGRulong intobj2_props=NULL, intobj2_other_props=NULL;
IGRulong intobj_props=NULL, intobj_other_props=NULL;
IGRdouble uvtol,  *uv_exact[3];
struct GRid this_sf;
struct EMSpartolbasis partolb;
struct EMSpypoint *py_point_info, *py_point_info1, *py_point_info2;
struct EMSpypoint *pypt, *temp_pypt, tmp_split_info;
struct EMSpypoint *pypt1, *pypt1_next;
struct EMSpypoint *pypt2, *pypt2_next;
struct EMSinters *inters_ptr=NULL, *inters_ptr_next=NULL;
struct EMSintobj *incoming1, *outgoing1, *incoming2, *outgoing2;
struct EMSintobj *intobj=NULL, **intobj_next=NULL, *other_split_intobj=NULL;
struct EMSintobj *intobj1=NULL, *intobj1_next=NULL;
struct EMSintobj *intobj2=NULL, *intobj2_next=NULL;
struct EMSintobj *fwd1, *bwd1, *fwd2, *bwd2;
IGRulong         fwd1_props, bwd1_props, fwd2_props, bwd2_props;
IGRlong          int_pos1=0, int_pos2=0;
struct EMSpypoint *EMprocess_pypoint_list();
IGRlong EMmodify_xyzdata();
IGRlong EMmodify_uvdata();
IGRlong EMrefine_the_intobj();
void EFset_split_intobj_pointers();

 /*
  * Initialisation.
  */
 status = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 world = TRUE;
 pypt1 = pypt2 = temp_pypt = NULL;
 pypt1_next = pypt2_next = NULL;
 for(i=0; i<3; i++)
 {
 uv_exact[i] = NULL;
 uv_exact[i] = (IGRdouble *) om$malloc (size = 2 * sizeof(IGRdouble));
 EMerr_hndlr (!uv_exact[i], *msg, EMS_E_NoDynamicMemory, ret_end);
 }
 
 if(!inters)
 {
 status = EMS_S_Fail;
 *msg = EMS_E_InvalidArg;
 goto ret_end;
 }
 inters_ptr = inters;
 while(inters_ptr && (inters_ptr->cvs && inters_ptr->cvs->next))
 {
 inters_ptr_next = inters_ptr->next;
 this_sf = inters_ptr->this_obj;
 partolb.is_valid = FALSE;
 status = om$send(msg = message EMSsubbs.EMpartolbasis(&msg_loc,
                                 &modenv->md_env.matrix_type,
                                 modenv->md_env.matrix, &world, TRUE,
                                 &partolb.tol),
                        senderid = NULL_OBJID,
                        targetos = this_sf.osnum,
                        targetid = this_sf.objid);
 EMerr_hndlr(!(1&status&msg_loc), *msg, EMS_E_SurfaceError, ret_end);
 partolb.is_valid = TRUE;
 EFextract_par(BSTOLLENVEC, partolb.tol, &uvtol, &msg_loc);
 intobj1 = inters_ptr->cvs;
 while(intobj1)
  {
  intobj1_next = intobj1->next;
  intobj1_props = intobj1->props;
  intobj1_other_props = intobj1->other_intobj_node->props;
  if(  (checkpresent_a? (intobj1->props & checkpresent_a) : TRUE) && 
       (checkabsent_a ?!(intobj1->props & checkabsent_a)  : TRUE))
   {
   intobj2 = inters_ptr->cvs;
   while(intobj2)
    {
    intobj2_next = intobj2->next;
    if(intobj2 != intobj1)
    {
    if(  (checkpresent_b? (intobj2->props & checkpresent_b) : TRUE) && 
         (checkabsent_b ?!(intobj2->props & checkabsent_b)  : TRUE))
     {
      intobj2_props = intobj2->props;
      intobj2_other_props = intobj2->other_intobj_node->props;
      num_int = 0;
      py_point_info1 = NULL;
      py_point_info2 = NULL;


      /* The intersection information obtained between the two dataselects is
       * w.r.t. the DATASELECT and NOT with respect to the LOGICAL direction
       * of the intobjs. This is because the split-intobj function wants it that
       * way.  If we send in "reversed" field of the intobj, then the span-index
       * and param pair will be w.r.t. the ACTUAL geometry is seen reversed. 
       * (e.g. if there are 5 spans and intersection in on 2nd span, the 
       * "reversed" flag will tell us that there is an intersection on the 4th
       * span, which is 2nd span from the end. This is wrong and NOT what we
       * want). 
       * Therfore, note that properties in "py_point_info1/2" such as 
       * "EMS_PYPOINT_ATSTART" etc. are with respect to the LOGICAL uv/xyz 
       * DATASELECT and NOT w.r.t the logical intobj direction.              
       * (NP 9/14/93). 
       *
       * Also, the py_point lists SHOULD have the SAME number 
       * of nodes and the i-th nodes of each list correspond to the (SAME) i-th
       * (XYZ) point of intersection. 
       */
      EFget_intersection_points(&msg_loc, uvtol, NULL, NULL,
                                   &intobj1->this_uvintobj,
                                   FALSE, /*intobj1->reversed*/
                                   &intobj2->this_uvintobj, 
                                   FALSE, /*intobj2->reversed*/
                                   &num_int,
                                   &py_point_info1, &py_point_info2);
      EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
     
     if (num_int)
     {
       struct EMSpypoint *pypt1, *pypt2;
       IGRpoint pt1, pt2;
       BSrc rc;
       

       pypt1 = py_point_info1;
       pypt2 = py_point_info2;
       for (i=0; i<num_int; i++)
       {
          OM_BLOCK_MOVE(pypt1->point, pt1, 2 * sizeof(IGRdouble)); 
          OM_BLOCK_MOVE(pypt2->point, pt2, 2 * sizeof(IGRdouble)); 
          pt1[2] = pt2[2] = 0.0;

          if (BSdistptpt(&rc, pt1, pt2) > uvtol)
          {
#ifdef DEBUG 
             printf ("Mismatched points %f, %f & %f, %f\n", 
                                                pypt1->point[0],
                                                pypt1->point[1],
                                                pypt2->point[0],
                                                pypt2->point[1]);
#endif

          }



          if ( ((struct EMSpypoint *)(pypt1->info) != pypt2)  || 
               ((struct EMSpypoint *)(pypt2->info) != pypt1) )
          {
#ifdef DEBUG 
             printf ("Mismatched pypt lists\n");
#endif
          }
         pypt1 =  pypt1->next; 
         pypt2 =  pypt2->next; 
       }

     } 

    if(num_int)
    {
      /* save all the fwd and bwd connections before the split */
      fwd1_props = intobj1->props & 
                     (EMSintobj_fwd_connectuv|EMSintobj_fwd_noconnectuv);
      fwd1       = fwd1_props? intobj1->fwd : NULL;

      bwd1_props = intobj1->props & 
                     (EMSintobj_bwd_connectuv|EMSintobj_bwd_noconnectuv);
      bwd1       = bwd1_props? intobj1->bwd : NULL;

      fwd2_props = intobj2->props & 
                     (EMSintobj_fwd_connectuv|EMSintobj_fwd_noconnectuv);
      fwd2       = fwd2_props? intobj2->fwd : NULL;

      bwd2_props = intobj2->props & 
                     (EMSintobj_bwd_connectuv|EMSintobj_bwd_noconnectuv);
      bwd2       = bwd2_props? intobj2->bwd : NULL;
  
      /* If any intersection point is marked as lying ATMIDDLE, then, if it
       * lies within "cht" of an endpt of the intobj, set it to ATSTART or 
       * ATSTOP as appropriate. This needs to be done BEFORE the for loop below,
       * because properties of the "other pypoint node" are relied on for 
       * setting "bwd" and "fwd" pointers (for checking "incoming" and 
       * "outgoing" node etc.). However, note that the properties are set w.r.t
       * the ACTUAL endpts of the dataselect and NOT the LOGICAL endpts of the
       * intobj. (NP 09/14/93).
       */

       for (i=0; i<2; i++)
       {
         py_point_info = (i==0) ? py_point_info1 : py_point_info2;

         while (py_point_info)
         {
           py_point_info->props &= ~(EMS_PYPT_ATMIDDLE|EMS_PYPT_POSUNKNOWN|
                                     EMS_PYPT_ATSTART|EMS_PYPT_ATSTOP|
                                     EMS_PYPT_ATEND);
           py_point_info->props |= EMS_PYPT_POSUNKNOWN;
           py_point_info = py_point_info->next;
         }
       }

       status = EMset_pypt_props(&msg_loc, modenv, intobj1, py_point_info1);
       EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
       status = EMset_pypt_props(&msg_loc, modenv, intobj2, py_point_info2);
       EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

     split_intobj1 = split_intobj2 = FALSE;

     for (i=0; i<2; i++)
     {
       
       /* process both intobjs for splitting ."i=0,1 is intobj1, intobj2"*/

       intobj             = (i==0? intobj1 : intobj2);
       other_split_intobj = (i==0? intobj2 : intobj1);
       intobj_next        = (i==0? &intobj1_next : &intobj2_next);
       py_point_info      = (i==0? py_point_info1 : py_point_info2);
       intobj_props       = (i==0? intobj1_props : intobj2_props);
       intobj_other_props = (i==0? intobj1_other_props : intobj2_other_props);
       split_intobj       = (i==0? &split_intobj1 : &split_intobj2);
       other_prop_at_intr= (i==0? &prop2_at_intr_with_1:&prop1_at_intr_with_2);

       /* initializations */
       pypt                 = NULL; 
       *other_prop_at_intr = NULL;


       /*
        * Find from the EMSpypoint fields the exact location of
        * the point of intersection and based on the fact it is 
        * lying in the middle or at the ends of the intersecting
        * intobj's, decides the splitting criteria. 
        * Do NOT split those intobj's where the
        * determined pypoint lies at the end point of the intobj.
        * If the number of intersections found after the processing
        * are more than one, we split ONLY at the FIRST split point in the 
        * MIDDLE of the intobj. Any other possible split pts will be generated
        * again in this while loop, since the split pieces of the intobj go back
        * into the loop again. 
        */
       
        /* get the first ATMIDDLE node. If there are no such nodes, this intobj
         * is NOT to be split, and we move on. Also, we assume that in case of
         * multiple intersection pts, the split information (pypoint info) 
         * corresponding to the current split point on the other intobj (i.e. 
         * the intobj being split against) is available thro the "info" pointer 
         * on this intobj's pypoint node.
         */

         pypt = py_point_info;

         while (pypt)
         {  if(pypt->props & EMS_PYPT_ATMIDDLE)
            { *split_intobj = TRUE;
              *other_prop_at_intr = ((struct EMSpypoint *)(pypt->info))->props;
              break;
            }
            else 
              pypt = pypt->next;
         }

       if (!(*split_intobj)) /* ==> intersections at endpts ONLY */
       {
         /* Note that the case where intobjs touch each other at BOTH endpts, 
          * is not handled well here, since we attempt to make fwd, bwd 
          * connections for only the FIRST point of intersection between the 
          * two before we pass on to other intobjs. 
          */
         *other_prop_at_intr = ((struct EMSpypoint *)
                                (py_point_info->info))->props;

       }

       if(*split_intobj)
       {
         tmp_split_info = *pypt;

         EMsplit_sf_intobj_uv(&msg_loc, EMSintobj_split_noconnectuv, 
                              &modenv->md_env, intobj,
                              &tmp_split_info, NULL,NULL); 
         EMerr_hndlr(EMSerror(msg_loc), *msg, msg_loc, ret_end);


       /* push the same intobj back into the loop to check for any more 
        * intersections. This way, both the split pieces will get tested for 
        * any more intersections (because after the split, "intobj" node 
        * represents the "first" half of the split and the other half is 
        * intobj->next, which will get tested AFTER intobj gets tested).
        */

       *intobj_next = intobj;  

       } /*if "*split_intobj"*/
       
     }/*for*/
     
     if (split_intobj1 || split_intobj2)
     {
       status = EMrefine_intobjs (&msg_loc, modenv, 
                                  intobj1, intobj2, 
                                  split_intobj1, split_intobj2, 
                                  prop1_at_intr_with_2, 
                                  prop2_at_intr_with_1);
       EMerr_hndlr(!(1&msg_loc&status), *msg, EMS_E_Fail, ret_end);   
#ifdef DEBUG
       total_refines++;
#endif
     }

      /* make the fwd bwd connection here */

      /* IMPORTANT: The properties ATSTOP, ATSTART etc. are assumed to be w.r.t.
       * ---------  the DATASELECT and NOT the LOGICAL direction of the intobj,
       *            which means that the intobj->reversed bits have NOT been 
       *            applied on it.
       */

      /* When we have cases of an intobj (say A) just "touching" another (say B)
       * then A is not split. However, after splitting B, the "bwd" or "fwd"
       * intobj of A (depending on whether A's logical START or STOP point lies
       * on B), if it exists, must be used as the "incoming" or "outgoing" 
       * pointer of A, respectively. This special case is also coded below.
       */

      set_pointers = TRUE;

      if (split_intobj1 || split_intobj2 || (!split_intobj1 && !split_intobj2))
      {
  
        if (!split_intobj1)
        {
          intobj1_intr_at_logical_start = intobj1->reversed ? 
                                  (prop1_at_intr_with_2 & EMS_PYPT_ATSTOP) :
                                  (prop1_at_intr_with_2 & EMS_PYPT_ATSTART) ;
        }

        if (!split_intobj2)
        {
          intobj2_intr_at_logical_start = intobj2->reversed ? 
                                  (prop2_at_intr_with_1 & EMS_PYPT_ATSTOP) :
                                  (prop2_at_intr_with_1 & EMS_PYPT_ATSTART) ;
        }

        if (!split_intobj1 && !split_intobj2) 
        {
          /* 
           * Intobjs have endpt contact. Check, whether this interaction is
           * at the start/stop of the intobjs. If it is at the "START_START"
           * or "STOP-STOP" of the intobjs, then there is no need to process
           * this interaction point, as these two intobjs will never be con-
           * nected together.
           */    

          int_pos1 = (prop1_at_intr_with_2 & EMS_PYPT_ATSTART) ? 1 :  
                     (prop1_at_intr_with_2 & EMS_PYPT_ATSTOP) ? 2 : 0; 
          int_pos2 = (prop2_at_intr_with_1 & EMS_PYPT_ATSTART) ? 1 :  
                     (prop2_at_intr_with_1 & EMS_PYPT_ATSTOP) ? 2 : 0; 

          if (int_pos1 && int_pos2)
          { 
            if (intobj1->reversed)
              int_pos1 = (int_pos1 == 1) ? 2 : 1;
            if (intobj2->reversed)
              int_pos2 = (int_pos2 == 1) ? 2 : 1;

            if (int_pos1 == int_pos2)
              set_pointers = FALSE;
          }

          if (set_pointers)
          {
          /* (NP 9/8/93)
           * verify that no "fwd" or "bwd" connections exist for the endpts of
           * the intobjs in question. After a regular split, intobjs will have
           * endpt contact AND at the same time, will already have their fwd/bwd
           * pointers set at the endpts. In this case, we SHOULD NOT reset the
           * fwd/bwd properties. What we are looking for here is cases
           * of intobjs meeting at endpts where they have NO fwd/bwd connect 
           * properties set. (This case arises when profile endpts lie ON 
           * existing edges of solids. Therefore, on one or more of the rib 
           * surfaces, an intobj from another rib surface will lie exactly at 
           * the join of two intobjs that came from the base solid. Since there
           * was no need to split any intobj, the fwd/bwd connections will never
           * get set, unless we explicitly check for this condition).
           * NOTE: Right now I am assuming that "no-connect" property being set 
           * ----  is of no significance here, since we only need the "connect" 
           *       property for tracing.
           */

           /* we already know that intobjs have endpt contact, therefore, if the
            * pypoint prop. is not ATSTART, it MUST be ATSTOP.
            */
           set_ptr_for_1 = intobj1_intr_at_logical_start?
                             !(intobj1->props & EMSintobj_bwd_connectuv) :
                             !(intobj1->props & EMSintobj_fwd_connectuv)   ;
           set_ptr_for_2 = intobj2_intr_at_logical_start?
                             !(intobj2->props & EMSintobj_bwd_connectuv) :
                             !(intobj2->props & EMSintobj_fwd_connectuv)   ;

           /* check for BOTH not settable. If one of them has a pointer set
            * due to refinement, which usually points to its contiguous intobj,
            * that is fine with us.
            */
           if (!set_ptr_for_1 && !set_ptr_for_2)
              set_pointers = FALSE; /*default is TRUE above */
           }
        }

        /* If an intobj is NOT split, then that the intersection with
         * that intobj was ONLY at the ends.
         */

        incoming1 = split_intobj1?
                    (intobj1->reversed? intobj1->next:intobj1)   :
                    (intobj1_intr_at_logical_start ? bwd1 : intobj1);
        outgoing1 = split_intobj1?
                    (intobj1->reversed? intobj1:intobj1->next)   :
                    (intobj1_intr_at_logical_start? intobj1 : fwd1);

        incoming2 = split_intobj2?
                    (intobj2->reversed? intobj2->next:intobj2)   :
                    (intobj2_intr_at_logical_start ? bwd2 : intobj2);

        outgoing2 = split_intobj2?
                    (intobj2->reversed? intobj2:intobj2->next)   :
                    (intobj2_intr_at_logical_start? intobj2 : fwd2);
      

        if (set_pointers)
        {
           EFset_split_intobj_pointers(&msg_loc, 
               fwd1, fwd1_props, bwd1, bwd1_props,
               incoming1, outgoing1,
               fwd2, fwd2_props, bwd2, bwd2_props,
               incoming2, outgoing2);
 
           EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);   
        }
      }
 
      EMpypoint_free(py_point_info1, NULL);
      EMpypoint_free(py_point_info2, NULL);

     }/* if "num_int" */

     
     }/* if likely intobj 2*/
   
      
    }/* if intobj2 != intobj1 */

    intobj2 = intobj2_next;

    }/*while intobj2 loop*/

   }/* if likely intobj 1 */

   intobj1 = intobj1_next;
  } 
 inters_ptr = inters_ptr_next;
 }

ret_end: 
 return(status);
}

IGRlong EMmodify_xyzdata(msg,
                         indata,
                         modenv,
                         point)
IGRlong *msg;
struct EMSdataselect *indata;
struct GRmd_env *modenv;
IGRdouble *point;
{
IGRlong msg_loc, sts;
IGRdouble xyz_tol;
IGRint location;
IGRboolean replace_endpts;
BSrc rc;
/*
extern IGRint EMextend_poly(), EMextend_curve(), EMextend_object();
*/

sts = OM_S_SUCCESS;
*msg = EMS_S_Success;
location = UNKNOWN;
replace_endpts = FALSE;

BSEXTRACTPAR(&rc, BSTOLLENVEC, xyz_tol);
switch (indata->datatype)
{
case EMSdata_poly3d:
 {
 sts = EMextend_poly(&msg_loc, 3, indata->data.poly, NULL, point, &location,
                     replace_endpts, NULL, NULL, xyz_tol, FALSE);
 if(!(1&msg_loc&sts)) goto ret_end;
 break;
 }
case EMSdata_curve3d:
 {
 sts = EMextend_curve(&msg_loc, &indata->data.curve, NULL, point, &location,
                     xyz_tol, 3, FALSE);
 if(!(1&msg_loc&sts)) goto ret_end;
 break;
 }
case EMSdata_object:
 {
 sts = EMextend_object(&msg_loc, indata->data.object, point, &location,
                       xyz_tol, modenv, FALSE);
 if(!(1&msg_loc&sts)) goto ret_end;
 break;
 }
}
ret_end:
 return(sts);
}

/* NOTE: Return EMS_I_InvalidArg, if modification failed in ANY way. 
   (NP 1/7/94).
 */

IGRlong EMmodify_uvdata(msg,
                        indata,
                        surf_GRid,
                        modenv,
                        partol,
                        point)
IGRlong *msg;
struct EMSdataselect *indata;
struct GRid *surf_GRid;
struct GRmd_env *modenv;
struct EMSpartolbasis *partol;
IGRdouble *point;
{
IGRlong msg_loc, sts;
IGRdouble  lentol;
IGRint location;
IGRboolean replace_endpts;
BSrc rc;

sts = OM_S_SUCCESS;
*msg = EMS_S_Success;
location = UNKNOWN;
replace_endpts = FALSE;

if(partol->is_valid)
 sts = EFextract_par(BSTOLLENVEC, partol->tol, &lentol, &rc);
else lentol = 0.00000001;

/* Before we actually replace the endpt of the dataselect with the exact point
 * coming in, project it onto the dataselect first and see if the distance of
 * projected point is greater than a certain value. This is because, the exact
 * point calculated by triple surface iteration could be on the wrong seam, if
 * the incoming dataselect runs along a seam.
 */
 
switch (indata->datatype)
{
case EMSdata_poly2d:
 {
 sts = EMextend_poly(&msg_loc, 2, indata->data.poly, NULL, point, &location,
                     replace_endpts, NULL, NULL, lentol, FALSE);
       EMerr_hndlr(!(1&msg_loc&sts), *msg, EMS_I_InvalidArg, ret_end);   
 break;
 }
case EMSdata_curve3d:
 {
 sts = EMextend_curve(&msg_loc, &indata->data.curve, NULL, point, &location,
                     lentol, 2, FALSE);
 EMerr_hndlr(!(1&msg_loc&sts), *msg, EMS_I_InvalidArg, ret_end);   
 break;
 }
case EMSdata_object:
 {
 sts = om$send(msg = message EMSedge.EMextend_geom(&msg_loc, point,
                          &location, replace_endpts, NULL, NULL, NULL,
                          partol, NULL, surf_GRid, NULL,
                          modenv->md_env.matrix,
                          &modenv->md_env.matrix_type),
                     senderid = NULL_OBJID,
                     targetid = indata->data.object->objid,
                     targetos = indata->data.object->osnum);
 EMerr_hndlr(!(1&msg_loc&sts), *msg, EMS_I_InvalidArg, ret_end);   
 break;
 }
}
ret_end:

 return(OM_S_SUCCESS); /* ALWAYS return success from here. (NP 1/7/94) */
}


/*
HISTORY:

NP     ?????  Creation.

ASSUMPTION: The two split pieces of an intobj will NEVER be connected to 
            each other.

LOGIC:      Connect "incoming1" to "outgoing2" and vice versa.

            The fucntion does not break or unset existing bits, but tries to 
            create new connections with other intobjs if it can. However, at the
            split point, for an intobj from one set, if there is an intobj from 
            the other set that it can logically continue along, then that takes
            priority over an existing fwd or bwd pointer.

            Since these intobjs have been generated by the splitting operation,
            the split pieces are connected to each other by default. Therfore, 
            whenever new connections are made here, old connections are first
            removed.
           
            If fwd1, bwd1, fwd2, bwd2 etc. are NULL, then they are ignored. This
            means then that existing pointers are kept. Otherwise they override
            existing fwd/bwd pointers.
*/
void EFset_split_intobj_pointers(EFmsg, fwd1, fwd1_prop, bwd1, bwd1_prop,
                                        incoming1, outgoing1, 
                                        fwd2, fwd2_prop, bwd2, bwd2_prop,
                                        incoming2, outgoing2)
IGRlong *EFmsg;
struct EMSintobj *fwd1, *bwd1, *fwd2, *bwd2;
IGRulong fwd1_prop, bwd1_prop, fwd2_prop, bwd2_prop;
struct EMSintobj *incoming1, *outgoing1, *incoming2, *outgoing2;
{
  IGRlong msg_loc;
  void EFset_intobj_bwd(), EFset_intobj_fwd();
 
  *EFmsg = EMS_S_Success;

  /*initialize*/
  
  /* if fwd1/bwd1 or fwd2/bwd2 is sent in as NULL, then existing 
   * forward/backward pointers will be set to NULL and the "fwd/bwd_noconnectuv"
   * property will be set. We dont want that to happen here, because we dont 
   * know in this function enough to set "fwd/bwd_noconnectuv". Therefore we 
   * make the connections only if fwd1/bwd1 or fwd2/bwd2 are non-NULL. Also make
   * sure that we do not connect intobjs to themselves. (OVERRIDE FOR INTOBJS
   * THAT ARE CLOSED????)
   */
  if (incoming1 && bwd1 && (incoming1!=bwd1))
      EFset_intobj_bwd(&msg_loc, incoming1, bwd1, bwd1_prop);
   
  if (outgoing1 && fwd1 && (outgoing1!=fwd1))
      EFset_intobj_fwd(&msg_loc, outgoing1, fwd1, fwd1_prop);
   
  if (incoming2 && bwd2 && (incoming2!=bwd2))
      EFset_intobj_bwd(&msg_loc, incoming2, bwd2, bwd2_prop);

  if (outgoing2 && fwd2 && (outgoing2!=fwd2))
      EFset_intobj_fwd(&msg_loc, outgoing2, fwd2, fwd2_prop);
 
  /* do the actual linking */
  if (incoming1 && outgoing2) 
      EFset_intobj_fwd(&msg_loc, incoming1, outgoing2, EMSintobj_fwd_connectuv);

  if (outgoing1 && incoming2) 
      EFset_intobj_bwd(&msg_loc, outgoing1, incoming2, EMSintobj_bwd_connectuv);

}


void EFset_intobj_fwd (EFmsg, intobj, fwd_intobj, connect_option)
IGRlong *EFmsg;
struct EMSintobj *intobj, *fwd_intobj;
IGRushort connect_option;
{
  IGRlong sts;

  *EFmsg = EMS_S_Success;
  sts    = OM_S_SUCCESS;

  if (intobj)
  {  if (connect_option & EMSintobj_fwd_connectuv)
     {  /* if no forward intobj exists, nothing to be done */
        if (fwd_intobj)
        {
           if ((fwd_intobj->bwd) && 
               (fwd_intobj->bwd != intobj) &&
               (fwd_intobj->bwd->fwd == fwd_intobj))
           {
              /* Make sure NO OTHER intobj has a "fwd" pointer to "fwd_intobj".
               * Right now the way to identify such an intobj is by 
               * "fwd_intobj->bwd", but we cannot handle a situation where 
               * some other intobj NOT connected to "fwd_intobj" also points 
               * to "fwd_intobj" as its "fwd" node. This is unlikely, however, 
               * since "fwd" and "bwd" connections are always made in pairs.
               * Also, we want to remove any "EMSintobj_fwd_noconnectuv" props
               * from "fwd_intobj->bwd", since we are setting its "fwd" ptr to
               * NULL, which in conjunction with an  existing "noconnectuv"
               * property will mean that intobj "fwd_intobj->bwd" should not be 
               * connected to ANYTHING in its forward direction, which we do not
               * know enough about here.
               */
              fwd_intobj->bwd->fwd = NULL;
              fwd_intobj->bwd->props &= ~EMSintobj_fwd_connectuv;
              fwd_intobj->bwd->props &= ~EMSintobj_fwd_noconnectuv;
           }

           /* make similar check for "intobj" too */
           if ((intobj->fwd) && 
               (intobj->fwd != fwd_intobj) &&
               (intobj->fwd->bwd == intobj))
           {
              intobj->fwd->bwd = NULL;
              intobj->fwd->props &= ~EMSintobj_bwd_connectuv;
              intobj->fwd->props &= ~EMSintobj_bwd_noconnectuv;
           }

           intobj->fwd     =  fwd_intobj;
           intobj->props  |=  EMSintobj_fwd_connectuv;
           intobj->props  &= ~EMSintobj_fwd_noconnectuv;

           fwd_intobj->bwd    =  intobj;
           fwd_intobj->props |=  EMSintobj_bwd_connectuv; 
           fwd_intobj->props &= ~EMSintobj_bwd_noconnectuv; 
        }
     }
     else if (connect_option & EMSintobj_fwd_noconnectuv)
     {
        /* if "fwd_intobj" is NULL, dont do anything, because we dont know 
         * enough to say that "intobj" is not to be connected to ANYTHING at its
         * forward end (which is what having a "NULL" fwd ptr and having the
         * no-connect property implies).
         */
        
        if (fwd_intobj)
        {
           intobj->fwd        =  fwd_intobj;
           intobj->props     |=  EMSintobj_fwd_noconnectuv;
           intobj->props     &= ~EMSintobj_fwd_connectuv;
           fwd_intobj->bwd    =  intobj;
           fwd_intobj->props |=  EMSintobj_bwd_noconnectuv;
           fwd_intobj->props &= ~EMSintobj_bwd_connectuv;
        }
     }
     else
     {
        EMerr_hndlr(TRUE, *EFmsg, EMS_E_InvalidArg, wrapup);
     }
  }
  
  wrapup:
   EMWRAPUP (*EFmsg, sts, "In EFset_intobj_fwd");
}



void EFset_intobj_bwd (EFmsg, intobj, bwd_intobj, connect_option)
IGRlong *EFmsg;
struct EMSintobj *intobj, *bwd_intobj;
IGRushort connect_option;
{
  IGRlong sts;

  *EFmsg = EMS_S_Success;
  sts    = OM_S_SUCCESS;

  if (intobj)
  {  if (connect_option & EMSintobj_bwd_connectuv)
     {  /* if no backward intobj exists, cleanly exit.*/
        if (bwd_intobj)
        {

           if ((bwd_intobj->fwd) && 
               (bwd_intobj->fwd != intobj) &&
               (bwd_intobj->fwd->bwd == bwd_intobj))
           {
              /* Make sure NO OTHER intobj has a "bwd" pointer to "bwd_intobj".
               * Right now the way to identify such an intobj is by 
               * "bwd_intobj->fwd", but we cannot handle a situation where 
               * some other intobj NOT connected to "bwd_intobj" also points 
               * to "bwd_intobj" as its "bwd" node. This is unlikely, however, 
               * since "fwd" and "bwd" connections are always made in pairs.
               * Also, we want to remove any "EMSintobj_fwd_noconnectuv" props
               * from "bwd_intobj->fwd", since we are setting its "bwd" ptr to
               * NULL, which in conjunction with an  existing "noconnectuv"
               * property will mean that intobj "bwd_intobj->fwd" should not be 
               * connected to ANYTHING in its backward direction, which we do 
               * not know enough about here.
               */
              bwd_intobj->fwd->bwd = NULL;
              bwd_intobj->fwd->props &= ~EMSintobj_bwd_connectuv;
              bwd_intobj->fwd->props &= ~EMSintobj_bwd_noconnectuv;
           }

           /* make similar check for "intobj" too */
           if ((intobj->bwd) && 
               (intobj->bwd != bwd_intobj) &&
               (intobj->bwd->fwd == intobj))
           {
              intobj->bwd->fwd = NULL;
              intobj->bwd->props &= ~EMSintobj_fwd_connectuv;
              intobj->bwd->props &= ~EMSintobj_fwd_noconnectuv;
           }


           intobj->bwd     =  bwd_intobj;
           intobj->props  |=  EMSintobj_bwd_connectuv;
           intobj->props  &= ~EMSintobj_bwd_noconnectuv;

           bwd_intobj->fwd    =  intobj;
           bwd_intobj->props |=  EMSintobj_fwd_connectuv; 
           bwd_intobj->props &= ~EMSintobj_fwd_noconnectuv; 
        }
     }
     else if (connect_option & EMSintobj_bwd_noconnectuv)
     {

        /* if "bwd_intobj" is NULL, dont do anything, because we dont know 
         * enough to say that "intobj" is not to be connected to ANYHTING at its
         * backward end (which is what having a "NULL" bwd ptr and having the
         * no-connect property implies).
         */
        
        if (bwd_intobj)
        {  intobj->bwd        =  bwd_intobj;
           intobj->props     |=  EMSintobj_bwd_noconnectuv;
           intobj->props     &= ~EMSintobj_bwd_connectuv;
           bwd_intobj->fwd    =  intobj;
           bwd_intobj->props |=  EMSintobj_fwd_noconnectuv;
           bwd_intobj->props &= ~EMSintobj_fwd_connectuv;
        }
     }
     else
     {
        EMerr_hndlr(TRUE, *EFmsg, EMS_E_InvalidArg, wrapup);
     }
  }
  
  wrapup:
   EMWRAPUP (*EFmsg, sts, "In EFset_intobj_bwd");
}

static void EFfixendinfo (EFmsg, mattyp, mat, inters)
IGRlong *EFmsg;
IGRmatrix mat;
IGRshort *mattyp;
struct EMSinters *inters;
{

    struct EMSinters *inters_loc;
    struct EMSintobj *intobj_loc;
    struct EMSsfintedpar *edpar1, *edpar2;
    struct EMSpartolbasis ptolbasis;
    struct EMSproj_info proj_info;
    IGRboolean world=TRUE, project_startpt, project_endpt;

    IGRlong msg_loc, sts;

    *EFmsg = EMS_S_Success;
    sts    = OM_S_SUCCESS;

    inters_loc = inters;

    while (inters_loc)
    {
       ptolbasis.in_world = TRUE;
       ptolbasis.is_valid = FALSE;
       ptolbasis.mattyp   = mattyp;
       ptolbasis.mat      = mat;

       world = TRUE;
       sts = om$send(msg = message EMSsubbs.EMpartolbasis
                               (&msg_loc, mattyp, mat, &world,
                                TRUE, &(ptolbasis.tol)),
                      senderid = NULL_OBJID,
                      targetid = inters_loc->this_obj.objid,
                      targetos = inters_loc->this_obj.osnum);
       EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, EMS_E_SurfaceError, wrapup);
       ptolbasis.is_valid = TRUE;

       intobj_loc = inters_loc->cvs;

       while (intobj_loc)
       {
         edpar1 = edpar2 = NULL;
         edpar1 = (struct EMSsfintedpar *) (intobj_loc->more_info);
         edpar2 = edpar1 ? edpar1->next : NULL;

         project_startpt=(edpar1 && (edpar1->edgeid != NULL_OBJID))?TRUE:FALSE;
         project_endpt  =(edpar2 && (edpar2->edgeid != NULL_OBJID))?TRUE:FALSE;
         
         /* re-project the relevant endpt of the uv-dataselect onto the
          * incident edge, to generate correct end-info. The hope is that
          * this will fix any wrong parameters that were not updated, 
          * primarily because the refinement was done with separate 
          * rib surfaces, hence if one surface refined an edge, another
          * surface that split the same edge before this one, did NOT 
          * know about it and hence the intobjs the old surface generated
          * still have the old span-inx/param. However, we assume the uv value 
          * in the more-info is EXACT. This is an important assumption.
          * If the end info is wrong it can easily CORRUPT the model, because
          * common edges may not meet at their ends etc. etc.
          */
         if (project_startpt)
         {
             sts = om$send(msg = message EMSedge.EMptproject
                             (&msg_loc, edpar1->point, 1, &proj_info,
                              NULL, &ptolbasis), 
                           senderid = NULL_OBJID,
                           targetid = edpar1->edgeid,
                           targetos = inters_loc->this_obj.osnum);
             EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, msg_loc, wrapup);

             OM_BLOCK_MOVE(&(proj_info.param), &(edpar1->edgepar),
                                     sizeof(struct EMSedgebound));
             /*** if(proj_info.location != EMScvint_unknown) ****/
             edpar1->intloc = proj_info.location;
         }
         if (project_endpt)
         {
             sts = om$send(msg = message EMSedge.EMptproject
                             (&msg_loc, edpar2->point, 1, &proj_info,
                              NULL, &ptolbasis), 
                           senderid = NULL_OBJID,
                           targetid = edpar2->edgeid,
                           targetos = inters_loc->this_obj.osnum);
             EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, msg_loc, wrapup);

             OM_BLOCK_MOVE(&(proj_info.param), &(edpar2->edgepar),
                                     sizeof(struct EMSedgebound));
             /*** if(proj_info.location != EMScvint_unknown) ****/
             edpar2->intloc = proj_info.location;
         }

         intobj_loc = intobj_loc->next;
       }

       inters_loc = inters_loc->next;
    }
   
wrapup:

  EMWRAPUP (*EFmsg, sts, "In EFfixendinfo");

}


 /* Do the triple surface iteration to put exact values into the ends of the
  * split dataselects. This function is called if at least one of the two  
  * intobjs coming in was split. If an intobj is split, the corresponding
  * incoming node will represent the first half of the split. Also, their 
  * relative locations at the split pt are passed in.
  *
  * 12/28/93   NP    Creation.
  * 01/08/94   NP    Checks added to used existing exact points wherever 
  *                  available. 
  */

IGRlong EMrefine_intobjs (EFmsg, modenv, intobj1, intobj2, intobj1_split, 
                              intobj2_split, prop1_at_intr_with_2, 
                              prop2_at_intr_with_1)
IGRlong *EFmsg;
struct GRmd_env *modenv;
struct EMSintobj *intobj1, *intobj2;
IGRboolean intobj1_split, intobj2_split;
IGRushort prop1_at_intr_with_2, prop2_at_intr_with_1;
{

  BSrc rc;
  IGRlong sts, msg_loc, i, location_index;
  IGRdouble *mat;
  IGRshort mattyp;
  enum EMSdatatype datatype;
  struct IGRbsp_surface *geom[3];
  struct GRid sfids[3];
  struct EMSintobj *refine_intobjs[3];
  struct EMSpartolbasis surf_tol[3];
  enum EMScvinttype location[3], extend_location;
  IGRdouble new_uv1[2], new_uv2[2], junk[2], approx_uv[3][2], exact_uv[3][2]; 
  IGRpoint junk_xyz, xyz_exact, xyzpt;
  IGRboolean success=FALSE, on_seam=FALSE, exact_pt_available = FALSE;
  IGRboolean *intobj_split;
  IGRboolean uvexact1, uvexact2, xyzexact1, xyzexact2, this_exact, other_exact;
  IGRulong this_prop_set=NULL, other_prop_set=NULL;
  struct GRid *this_sf, *other_sf;
  struct EMSpartolbasis *this_sf_tol, *other_sf_tol;
  IGRdouble dist1, dist2, cht, *this_exact_uv, *other_exact_uv;
  IGRboolean same_xyz_dataselect, onsrf, use1, use2;
  struct EMSintobj *intobj, *other_intobj, *next_intobj, *other_next_intobj;
  struct EMSintobj *chk_intobj;
  IGRlong side;
  




  *EFmsg = EMS_S_Success;
  sts    = OM_S_SUCCESS; 

  EMerr_hndlr(!intobj1_split && !intobj2_split, *EFmsg, EMS_I_InvalidArg, 
              wrapup);

  mattyp = modenv->md_env.matrix_type;
  mat    = modenv->md_env.matrix;
 
  BSEXTRACTPAR (&rc, BSTOLCHRDHT, cht);
  exact_pt_available = FALSE;;

  for(i=0; i<3; i++)
     geom[i] = NULL; /* Initialization */

  refine_intobjs[0] = intobj1;
  refine_intobjs[1] = intobj1->other_intobj_node;
  refine_intobjs[2] = intobj2->other_intobj_node;
  
  for(i=0; i<3; i++)
  {
    sfids[i] = refine_intobjs[i]->this_obj_node->this_obj;

    datatype = EMSdata_surface;
    sts = EMgetvggeom (&msg_loc, &mattyp, mat, &(sfids[i]), 
                             (IGRchar **)&(geom[i]), &datatype);
    EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);

    sts = EFsspbtol_by_geom (&msg_loc, geom[i],&(surf_tol[i].tol));
    EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
    surf_tol[i].is_valid = TRUE;
    surf_tol[i].in_world = TRUE;
    surf_tol[i].mattyp   = &mattyp;
    surf_tol[i].mat      = mat;
  }
  
  /* To do the triple surface iteration, we need guess UV points on the three
   * surfaces. We use the appropriate ends of the intobj  uv dataselects to get
   *  these points. We note here that since the 2nd and 3rd intobjs in the 
   * "refine_intobjs" array are "other_intobjs" of each other, they will have 
   * to have their SAME logical end modified.
   * It is important to note here that we are NOT concerned about the "reversed"
   * field of the intobjs. We are always looking at the logical direction of the
   * intobj uv dataselects. If an intobj is split into two nodes, the node that
   * retains the incoming intobj pointer is the first half of the split and will
   * be the one that has the FIRST half of the LOGICAL UV dataselect.  Therefore
   * if an intobj is split, the UV split point can be obtained by looking at the
   * LOGICAL END point of the UV dataselect of that node. 
   */

  if (intobj1_split)
     location[0] = EMScvint_rtend; /* ALWAYS, for first half of split intobj */ 
  else
  {
     /* Since intobj1 is not split, intobj2 definitely HAS been split */
     if (prop1_at_intr_with_2 & EMS_PYPT_ATSTOP)
        location[0] = EMScvint_rtend;
     else if (prop1_at_intr_with_2 & EMS_PYPT_ATSTART)
        location[0] = EMScvint_lfend;
     else
     { /* Since intobj1 did not get split, one of its endpoints HAS to lie
        * on intobj2. Else there is some error.
        */
       EMerr_hndlr(TRUE, *EFmsg, EMS_E_InvalidArg, wrapup);
     }

  }

  location[1] = location[0]; /*because they are "other intobj"s of each other*/ 

  /* The split location for intobj2's other intobj node will be the SAME as the
   * location on intobj2. 
   */
  if (intobj2_split)
  {
     location[2] = EMScvint_rtend; 
  }
  else
  {
     /* Since intobj2 is not split, intobj1 definitely HAS been split */
     if (prop2_at_intr_with_1 & EMS_PYPT_ATSTOP)
        location[2] = EMScvint_rtend;
     else if (prop2_at_intr_with_1 & EMS_PYPT_ATSTART)
        location[2] = EMScvint_lfend;
     else
     {
       /* Since intobj2 did not get split, one of its endpoints HAS to lie
        * on intobj1. Else there is some error.
        */
       EMerr_hndlr(TRUE, *EFmsg, EMS_E_InvalidArg, wrapup);
     }
  }
     

 /* extract the approx uv values as the correct LOGICAL endpt of UV dataselect*/

 for (i=0; i<3; i++)
 {
    sts = EMgetendpts (&msg_loc, NULL, NULL, 
                        &(refine_intobjs[i]->this_uvintobj), FALSE, 1, 
                        (location[i]==EMScvint_rtend?junk:approx_uv[i]), 
                        (location[i]==EMScvint_rtend?approx_uv[i]:junk),FALSE);
    EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
 }

 for (i=0; i<3; i++)
 {
   OM_BLOCK_MOVE(approx_uv[i], exact_uv[i], 2 * sizeof(IGRdouble));
 }

 /* If one of the intobjs was generated by coincident plane processing, then
  * two out of the three surfaces above will be coplanar and triple surface 
  * iteration will have no correct solution in this case. Although math MAY 
  * return success code, we cannot trust that. 
  *
  * Consider the following example:
  *      Intobj1 & intobj2 lie on surface1. Intobj1's "other" intobj is on a 
  * coincident plane (surface2), while intobj2's "other" intobj is on a 
  * cylindrical surface (surface3). Since surfaces 1 & 2 are coplanar, math 
  * cannot find a solution. Now, the split point on surface 1 on intobj1 can
  * be ASSUMED to be exact, since surface 1 is a plane and the uv 
  * intersection point between intobj1 and intobj2 is as accurate as we can hope
  * for. If we want endpts of intobj1 and intobj2 to be exactly the same, we can
  * take an average of their endpts and use that as the correct split point on 
  * surface1 (however, if one of them is a curve3d, then we use the endpt of the
  * curve3d dataselect and snap the other one to it). Next, we evaluate this 
  * point in XYZ and find the uv values of min. dist points on each of the other
  * surfaces. We use these three points as the exact UV values and go on as if
  * math returned us the exact points. 
  *    To ensure accuracy, we do all of ths ONLY if we are on a coincident plane
  * (i.e. either intobj1 or intobj2 has been produced by coincident plane 
  * processing). It is possible that surfaces of "intobj1->other_intobj_node"
  * and "intobj2->other_intobj_node" may be coincident. It is proper to not 
  * handle that case here, since the hope is that refinement of these intobjs 
  * will take place when one of those two planes comes into this function as
  * surface1.
  *
  * NOTE: (IMPORTANT)
  * Since the coincident intersection can be pushed onto adjoining surfaces, 
  * this surface (i.e. intobj1's surface) need not necessarily be a plane. If it
  * is not, then maybe we can trust the result of triple surface iteration. In
  * the code below, it is assumed that the if intobj1 (or intobj2) is marked 
  * coincident, it will ALWAYS lie on a plane, because of the specifics of the
  * rib algorithm. The way we split intobjs, "intobj1" is always going to be a 
  * marked "tmp_marked" (which means its "other_intobj" came from another rib
  * surface) and will lie on a rib surface. Intobj2 obviously lies on the same 
  * rib  surface, but its "other_intobj" HAS to lie on a surface of the  base 
  * solid. Since the side, top, bottom surfaces of the rib are separate, there 
  * is no common edge to push these intersections across. Therefore, if intobj1
  * or intobj2 is marked "coincident", we simply assume that they lie on a 
  * plane and we dont do triple surface iteration.
  *
  * ANOTHER NOTE: (EQUALLY IMPORTANT)
  *
  * We might already know the exact refined point, without having to go through
  * triple surface iteration OR taking the coincident plane intobj endpt 
  * (assumed exact) as explained above. If BOTH "intobj1_split" and 
  * "intobj2_split" are TRUE, that means this is a NEWLY generated split point
  * and is obviously NOT refined. BUT, if only ONE of the intobjs has been split
  * then there exists the possibility that its endpt MAY be exact, if it has
  * been refined before. As an example, consider that intobj1 is NOT split:
  *   Although intobj1 is NOT split againt intobj2, it COULD have been split
  *   earlier while being an "other_intobj" of an intobj on another surface.
  *   If during THAT split an EXACT triple surface iteration point was 
  *   calculated, then we can use that point here, without doing triple surface
  *   iteration here.
  * The advantage of this is as follows:
  *   Assume we did not use intobj1's endpt, although it was exact. Then, if the
  *   surface that intobj1 and intobj2 lie on is a coincident plane, we are 
  *   forced to use its endpts AS IS (which is hopefully exact, but not 
  *   guaranteed to be so, due to the splitting), since math does not have a 
  *   solution for coplanar surfaces. This means that we might end up using an 
  *   INEXACT point in lieu of a an exact point we already knew we had.
  *   Therefore, using a known exact point will reduce any errors we may 
  *   introduce inside this function by using an inexact point. The hope is that
  *   even if we are forced to use an endpt of a coincident plane intobj, at
  *   some point in the splitting process, these intobjs might be the 
  *   "other_intobjs" of an exact split and might get updated with the exact pt.
  *   
  *   (NP 1/7/94)
  */
 
 exact_pt_available = FALSE;
 for (i=0; i<2;i++)
 {
   intobj_split       = (i==0? &intobj1_split : &intobj2_split);
   intobj             = (i==0? intobj1 : intobj2);
   other_intobj       = intobj->other_intobj_node;
   location_index     = (i==0? 0 : 2); 

   /* We get the endpt at the SAME logical end of the xyz dataselect as we 
    * determined for the uv dataselect, since one of the foundations of our
    * boolean algorithm is that logical uv and xyz dataselects flow in the 
    * same dir.
    */
   if (!(*intobj_split)) /* if NOT split */
   {  /* location is for logical uv/xyz dataselect */
     if (location[location_index]==EMScvint_rtend) 
     {
       chk_intobj = intobj;
       exact_pt_available = 
          (((intobj->props & EMSintobj_exact_atstop)  && !intobj->reversed) || 
           ((intobj->props & EMSintobj_exact_atstart) &&  intobj->reversed));
       /* try and see if the "other" intobj" has exact endpts. This can happen
        * if this intobj could not be extended to the correct point, but the 
        * "other" intobj was. Again keep in mind that the dataselects for
        * "this" and "other" intobj will flow in same direction. Therefore
        * ""EMScvint_rtend/lfend" will be same.
        */
       if (!exact_pt_available)
       {
         chk_intobj = other_intobj;
         exact_pt_available =
          (((other_intobj->props&EMSintobj_exact_atstop)&& !intobj->reversed)||
          ((other_intobj->props&EMSintobj_exact_atstart) && intobj->reversed)); 
       }  
     }
     else if (location[location_index]==EMScvint_lfend)
     {
       chk_intobj = intobj;
       exact_pt_available = 
          (((intobj->props & EMSintobj_exact_atstop)  &&  intobj->reversed) || 
           ((intobj->props & EMSintobj_exact_atstart) && !intobj->reversed));

       /* try and see if the "other" intobj" has exact endpts.*/
       if (!exact_pt_available)
       {
         chk_intobj = other_intobj;
         exact_pt_available =
         (((other_intobj->props&EMSintobj_exact_atstop) && intobj->reversed) ||
         ((other_intobj->props & EMSintobj_exact_atstart)&& !intobj->reversed));
       }
     }
                            
     /* intobj is marked exact by us ONLY if BOTH UV & XYZ are exact. So we can
      *  safely extract the XYZ endpt.
      */
     if (exact_pt_available)
     {
        sts = EMgetendpts (&msg_loc, &mattyp, mat,
                  &(chk_intobj->this_xyzintobj), FALSE, 1,
                  (location[location_index]==EMScvint_rtend?junk_xyz:xyz_exact),
                  (location[location_index]==EMScvint_rtend?xyz_exact:junk_xyz),
                  TRUE);
        EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

#ifdef DEBUG
       printf ("Exact pt known. No triple surface iteration.\n");
       extracts++;
#endif
        break; /* search ends */
     }
      
   }
 }

 /* At some point in time, actually check the three surfaces to make sure that
  * NO TWO of them are coplanar. If they are, then math will NOT have a solution
  * to it.
  */

 if (!exact_pt_available)
 {
   if ((intobj1->props & EMSintobj_coincident) || 
      (intobj2->props & EMSintobj_coincident) )
   {
      /* if intobj1 were produced by coplanar processing, then we can ASSUME 
       * the exact point in "exact_uv[0]" from above. However, if it NOT, and 
       * intobj2 is, then we need to extract the relevant endpt of intobj2. If 
       * both are produced by coincident plane processing, then we need to 
       * prefer the endpt of a BSedge intobj over a EMSlinedge. We are assuming,
       *  correctly, that all dataselects for uv data are only objects.
       *
       * Another important thing to note is that here, we DONT set the variable
       * "exact_pt_available" to TRUE, because this pt is NOT produced from an
       * existing EXACT intobj or from triple surface iteration.
       */
       use1 = use2 = FALSE;
  
       if ((intobj1->props & EMSintobj_coincident) && 
          (intobj2->props & EMSintobj_coincident) )
       {
         use1 = EFisAncestryValid(&msg_loc,
                     intobj1->this_uvintobj.data.object->objid,
                     intobj1->this_uvintobj.data.object->osnum,
                     OPP_EMSbsedge_class_id, FALSE);
         use2 = EFisAncestryValid(&msg_loc,
                     intobj2->this_uvintobj.data.object->objid,
                     intobj2->this_uvintobj.data.object->osnum,
                     OPP_EMSbsedge_class_id, FALSE);
   
         /* if both are bs edges, use any one of them */
         if (use1 && use2)
            use2 = FALSE; 
       }
       else if (intobj2->props & EMSintobj_coincident)
       {
        /* Since intobj1 is not from coinc. plane proc., use endpt of intobj 2*/
         use2 = TRUE;
       }
   
       if (use2)
       {
         sts = EMgetendpts (&msg_loc, NULL, NULL,
                          &(intobj2->this_uvintobj), FALSE, 1,
                          (location[2]==EMScvint_rtend?junk:exact_uv[0]),
                          (location[2]==EMScvint_rtend?exact_uv[0]:junk),FALSE);
         EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
       }
   
       /* Now evaluate the uv point on this surface and find the corresponding 
        * points on the other surfaces by projection.
        */
   
       BSsfeval(geom[0], exact_uv[0][0], exact_uv[0][1], 0, &xyzpt, &rc);
       EMerr_hndlr(rc!=BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);
   
   
       for (i=1; i<3; i++)
       {
         onsrf = FALSE;
         success = BSprptonsf (&rc, geom[i], xyzpt, 
                            &(exact_uv[i][0]), &(exact_uv[i][1]), &onsrf);
         EMerr_hndlr ((rc!=BSSUCC) || !onsrf || !success, *EFmsg, EMS_E_BSerror,
                        wrapup);
   
         /* Actually, even if the projected point is NOT on the surface, we need
          * not error out. Instead we can simply use the nearest uv values 
          * returned in "exact_uv[i]" and move on. Right now I am erroring out,
          * since it seems to me that "onsrf" should NEVER be FALSE.
          */
       }
       /* One final step remains. Move the XYZ point over to "xyz_exact" */
   

       OM_BLOCK_MOVE (xyzpt, xyz_exact, sizeof (IGRpoint));

#ifdef DEBUG
      printf ("Using endpt of coplanar intobj\n");
#endif

   }
   else
   {
  
      /* Generate the exact uv values on the three surfaces using triple surface
       * iteration. Math modifies the input vlaues in place.
       */
      success = FALSE;
      BStrpsfiter(geom[0], geom[1], geom[2], 
                  surf_tol[0].tol, surf_tol[1].tol, surf_tol[2].tol, 
                  &(exact_uv[0][0]), &(exact_uv[0][1]),
                  &(exact_uv[1][0]), &(exact_uv[1][1]),
                  &(exact_uv[2][0]), &(exact_uv[2][1]),
                  xyz_exact, &success, &rc);
      EMerr_hndlr(rc!=BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);
      EMerr_hndlr(!success, *EFmsg, EMS_I_NoSolution, wrapup);
     
#ifdef DEBUG
      printf ("Doing triple surface iteration\n");
#endif
      exact_pt_available = TRUE;
   }
 }

 
  /* Check all three uv pairs for jumps across seam if warranted by the surface
   * type. Math does not guarantee that there will be no jumps.
   */

 for (i=0; i<3; i++)
 {
    /* if the surface is NOT physically closed in BOTH u AND v, there is no 
     * chance of a seam. Ignore the seam check for such surfaces.
     */
    if (!geom[i]->u_phy_closed && !geom[i]->v_phy_closed)
       continue;

    on_seam = FALSE;
    on_seam = EFfind_closest_uv_side(
                         geom[i]->u_knots[geom[i]->u_order - 1], 
                         geom[i]->u_knots[geom[i]->u_num_poles], 
                         geom[i]->v_knots[geom[i]->v_order - 1], 
                         geom[i]->v_knots[geom[i]->v_num_poles],
                         exact_uv[i][0], exact_uv[i][1], surf_tol[i].tol, &side,
                         &(new_uv1[0]), &(new_uv1[1]), 
                         &(new_uv2[0]), &(new_uv2[1]));
    /* If the exact uv value lies on a seam, compare the distance of the two
     * possible new uv values with the "approximate" uv, to see which of the new
     * values is closest to it. THAT is the value we want. There is a potential
     * for a problem here, if we generated the "approximate" value from the 
     * wrong end of the dataselect, which uv may be closer to the wrong "new" 
     * uv. To make sure that this is not the case, we first evaluate the 
     * "approximate" uv value on the surface and make sure that it's XYZ value
     * was WITHIN cht of the exact XYZ point. If not, it means that we started
     * with the wrong uv value. In that case, we evaluate the OTHER end of the
     * dataselect that generated the approximate uv and check if THAT is within
     * cht of the exact XYZ point. If it is, we could use THAT value in the 
     * check below. But this should NEVER happen, since we being VERY careful to
     * pick the approximate UV from the CORRECT end of the UV dataselect. 
     * Therefore, for now, we error out if the approximate uv's evaluated xyz
     * point is MORE than cht away from the exact xyz. Only do all this if 
     * "on_seam" is TRUE, so that all iterations dont pay the penalty.
     */

    if (on_seam)
    {
#ifdef DEBUG
       printf("Triple surface iteration pt on seam\n");
#endif
       BSsfeval(geom[i], approx_uv[i][0], approx_uv[i][1], 0, &xyzpt, &rc);
       EMerr_hndlr(rc!=BSSUCC, *EFmsg, EMS_E_Fail, wrapup);

       if (BSdistptpt(&rc, xyz_exact, xyzpt) > cht)
         {EMerr_hndlr(TRUE, *EFmsg, EMS_E_InvalidCase, wrapup);}
      
       dist1 = (approx_uv[i][0] - new_uv1[0]) * (approx_uv[i][0] - new_uv1[0]) +
               (approx_uv[i][1] - new_uv1[1]) * (approx_uv[i][1] - new_uv1[1]);
       dist2 = (approx_uv[i][0] - new_uv2[0]) * (approx_uv[i][0] - new_uv2[0]) +
               (approx_uv[i][1] - new_uv2[1]) * (approx_uv[i][1] - new_uv2[1]);

       if (dist1 < dist2)
         {OM_BLOCK_MOVE(new_uv1, exact_uv[i], 2 * sizeof(IGRdouble));}
       else
         {OM_BLOCK_MOVE(new_uv2, exact_uv[i], 2 * sizeof(IGRdouble));}
    }
 }
                    
 /* Now we need to update the following UV/XYZ DATASELECTS. No matter what the 
  * setting of the reversed bit for the intobj is, this much we can say for 
  * CERTAIN, based on how the "split_intobj" code inserts the split pieces in
  * the linked list: "If an intobj is split, the intobj pointer, after the split
  * points to the FIRST half (startpt of logical uv intobj->splitpt) of its 
  * logical UV DATASELECT, and its "next" points to the second half (splitpt->
  * endpt of logical uv dataselect)". 
  *    Using this fact, we modify the intobj DATASELECTS (completely ignore the
  *  intobj "reversed" bit):
  * 
  * 1. endpt of intobj1 (UV/XYZ)
  * 2. startpt of intobj1->next (UV/XYZ), if intobj1 has been split
  * 3. endpt of intobj1->other_intobj_node (UV/XYZ)
  * 4. endpt of intobj1->other_intobj_node->next (UV/XYZ), 
  *             if intobj1 & hence intobj1->other_intobj_node has been split
  * 5. Repeat above for intobj2
  *
  * Mark intobjs as exact if we were successful in extending BOTH the 
  * dataselects (uv & xyz) to their respective exact points in uv and xyz.
  */

 for (i=0; i<2; i++)
 {
    intobj_split       = (i==0? &intobj1_split : &intobj2_split);  
    extend_location    = (i==0? location[0] : location[2]);
    intobj             = (i==0? intobj1 : intobj2);
    other_intobj       = intobj->other_intobj_node;
    next_intobj        = intobj->next;
    other_next_intobj  = next_intobj?next_intobj->other_intobj_node:NULL;
    this_sf            = &(sfids[0]);
    this_sf_tol        = &(surf_tol[0]);
    other_sf           = (i==0? &(sfids[1]) : &(sfids[2]));
    other_sf_tol       = (i==0? &(surf_tol[1]) : &(surf_tol[2]));
    this_exact_uv      = exact_uv[0];
    other_exact_uv     = (i==0? exact_uv[1] : exact_uv[2]);
 
    /* these are for setting the "exact" property of the intobjs" */
    this_exact = other_exact = FALSE; /* assume */

    this_prop_set = NULL; other_prop_set= NULL; /* important */

    if (extend_location==EMScvint_rtend)
    {
       this_prop_set = intobj->reversed? EMSintobj_exact_atstart :
                                         EMSintobj_exact_atstop;
       other_prop_set= other_intobj->reversed? EMSintobj_exact_atstart :
                                               EMSintobj_exact_atstop;
    }
    else if (extend_location==EMScvint_lfend)
    {
       this_prop_set = intobj->reversed? EMSintobj_exact_atstop :
                                         EMSintobj_exact_atstart;
       other_prop_set= other_intobj->reversed? EMSintobj_exact_atstop :
                                               EMSintobj_exact_atstart;
    }
 
    if (!(*intobj_split)) /* only THESE could be already exact */
    { 
      /* it may NOT be necessary to extend this intobj to the exact point, if
       * the intobj is ALREADY marked as exact. Skip extending such intobjs. 
       * Obviuosly, if an intobj is NOT split, we dont know if its "next" intobj
       * is really its geometrically contiguous intobj. Therefore, we can simply
       * continue with the next iteration of the for loop.
       */
       this_exact  = intobj->props & this_prop_set;
       other_exact = other_intobj->props & other_prop_set;

       if (this_exact && other_exact)
         continue;
    }
    else
    {
       /* this is for "intobj1" or "intobj2" and their "other" intobjs.*/
       this_exact  = FALSE;
       other_exact = FALSE;

    }

    /* If the current intobj and its "other_intobj" point to the same XYZ data 
     * in memory, keep track of that.
     */
    same_xyz_dataselect = EMis_same_dataselect(&intobj->this_xyzintobj, 
                             &other_intobj->this_xyzintobj);
    if (!this_exact) /* split intobjs will come in here */
    {
       uvexact1 = xyzexact1 = FALSE; /*assume */

       /* Update UV dataselect of this intobj */
       sts = EMmodify_uvdata(&msg_loc, &(intobj->this_uvintobj), this_sf, 
                          modenv, this_sf_tol, this_exact_uv);
       EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
       uvexact1 = (msg_loc == EMS_I_InvalidArg)? FALSE : TRUE;
       
       /* Update XYZ dataselect of this intobj */
       sts = EMmodify_xyzdata(&msg_loc, &intobj->this_xyzintobj, modenv,
                               xyz_exact);
       EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
       xyzexact1 = (msg_loc == EMS_I_InvalidArg)? FALSE : TRUE;

       if (exact_pt_available && uvexact1 && xyzexact1)
       {
         intobj->props |= this_prop_set;
         this_exact = TRUE; 
       }
    }


    if (!other_exact) /* always TRUE for split intobjs */
    {
        uvexact2 = xyzexact2 = FALSE; /*assume */

       /* Update UV dataselect of other intobj */
       sts = EMmodify_uvdata(&msg_loc, &(other_intobj->this_uvintobj),other_sf, 
                             modenv, other_sf_tol, other_exact_uv);
       EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
       uvexact2 = (msg_loc == EMS_I_InvalidArg)? FALSE : TRUE;
   
       if (same_xyz_dataselect)
       {
          /* If the xyz dataselects were the same, then if we have modified the
           * xyz dataselect for intobj, we have freed the old xyz dataselect. 
           * Make sure the xyz data is still same.
           */
          other_intobj->this_xyzintobj.data.curve = 
                                    intobj->this_xyzintobj.data.curve;
         xyzexact2 = xyzexact1;
       }
       else
       { sts = EMmodify_xyzdata(&msg_loc,&other_intobj->this_xyzintobj,modenv,
                                xyz_exact);
         EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
         xyzexact2 = (msg_loc == EMS_I_InvalidArg)? FALSE : TRUE;
       }

       if (exact_pt_available && uvexact2 && xyzexact2)
       {
         other_intobj->props |= other_prop_set;
         other_exact = TRUE; 
       }
    }

    /* Now, if the current intobj is the first half of a split of another intobj
     * then we need to insert the exact point into the dataselects of the "next"
     * intobj too. The "next" intobj is the other half of the split. The "next"
     * intobj and "intobj" are split pieces of the same intobj and lie
     * on "this" surface, hence their "other" nodes lie on the "other" surface.
     *  Also, since a split HAS taken place, we know that the split end is NOT 
     * exact and needs to be extended to the exact points in uv and xyz.
     */
     
    uvexact1 = uvexact2 = xyzexact1 = xyzexact2 = FALSE; /* we KNOW this */
    if (*intobj_split)
    {
       /* if "*intobj_split" is TRUE, there MUST be a next_intobj and the 
        *  next_intobj's other_intobj. Verify this.
        */
       EMerr_hndlr(!next_intobj || !other_next_intobj, 
                     *EFmsg, EMS_E_Fail, wrapup);

       /* Update UV dataselect of next intobj */
       sts = EMmodify_uvdata(&msg_loc, &(next_intobj->this_uvintobj), this_sf,
                          modenv, this_sf_tol, this_exact_uv);
       EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
       uvexact1 = (msg_loc == EMS_I_InvalidArg)? FALSE : TRUE;

       /* Update UV dataselect of next intobj's other intobj */
       sts = EMmodify_uvdata(&msg_loc, &(other_next_intobj->this_uvintobj),
                            other_sf, modenv, other_sf_tol, other_exact_uv);
       EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
       uvexact2 = (msg_loc == EMS_I_InvalidArg)? FALSE : TRUE;

       same_xyz_dataselect = EMis_same_dataselect(&next_intobj->this_xyzintobj,
                                &other_next_intobj->this_xyzintobj);
       /* Update XYZ dataselect of next intobj */
       
       sts = EMmodify_xyzdata(&msg_loc, &next_intobj->this_xyzintobj, modenv,
                               xyz_exact);
       EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
       xyzexact1 = (msg_loc == EMS_I_InvalidArg)? FALSE : TRUE;
   
       if (same_xyz_dataselect)
       {
          other_next_intobj->this_xyzintobj.data.curve =
                                      next_intobj->this_xyzintobj.data.curve;
          xyzexact2 = xyzexact1;
       }
       else
       {
         sts = EMmodify_xyzdata(&msg_loc,&other_next_intobj->this_xyzintobj,
                                modenv, xyz_exact);
         EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
         xyzexact2 = (msg_loc == EMS_I_InvalidArg)? FALSE : TRUE;
       }

       /* update "exact" properties. Since "next_intobj" is the "second" half of
        * the split,  the location is ALWAYS "lfend". We could not make such a 
        * firm determination for "intobj", because it could have been a "split"
        * one or an "unsplit" one. As always, the location "lfend" is w.r.t. the
        * intobj dataselect and NOT w.r.t. the intobj.
        */
        this_prop_set = next_intobj->reversed? EMSintobj_exact_atstop :
                                               EMSintobj_exact_atstart;
        other_prop_set= other_next_intobj->reversed? EMSintobj_exact_atstop :
                                                     EMSintobj_exact_atstart;
       if (exact_pt_available && uvexact1 && xyzexact1)
         next_intobj->props |= this_prop_set;

       if (exact_pt_available && uvexact2 && xyzexact2)
         other_next_intobj->props |= other_prop_set;
   
    }

 }


 wrapup:

 #ifdef DEBUG
 if (*EFmsg == EMS_I_NoSolution)
 {
    printf ("3 surf. iteration failed \n");
 }
#endif

 for(i=0; i<3; i++)
   if(geom[i]) om$dealloc (ptr = geom[i]);


 EMWRAPUP (*EFmsg, sts, "In EMrefine_intobjs");
 return(sts);

}


end implementation Root;

