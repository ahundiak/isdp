/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "EMS.h"
# include "OMmacros.h"      /* OM_BLOCK_MOVE                */
# include "emsedgedef.h"    /* EMlinestring                 */
# include "EMSprop.h"       /* EMLP_ACTIVE                  */
# include "EMSopt.h"        /* nesting and profile options  */
# include "EMSbnddef.h"     /* EMSbnd.h                     */
# include "EMSbnd.h"        /* EMSpartolbasis               */
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

extern OMuword  OPP_GR3dlineseg_class_id;
extern OMuword  OPP_GR3dlinestr_class_id;
extern OMuword  OPP_EMSvsfeature_class_id;
extern OMuword  OPP_EMSlinedge_class_id;

from EMSgraloop     import  EMglpinit, EMupdate_feature;
from EMSloop        import  EMget_props, EMgetrange;
from EMSlinedge     import  EMleinit;
from EMSboundary    import  EMget_objid;
from EMSloopset     import  EMtreemod, EMget_props;
from EMShorizon     import  EMset_orientation,
                            EMcheck_orientation;

method EMprofile(IGRlong                *EMmsg;
                 struct GRmd_env        *md_env;
                 struct GRvg_construct  *construct_list;
                 IGRint                  num_vectors;
                 IGRvector               vectors[];
                 IGRshort                options;
                 IGRint                 *num_crvs;
                 struct GRid            **crv_ids)



/*
Abstract

    This method generates profile lines by placing view-specific
    feature loops on the surface or by placing curve objects in
    the specified module environment.

Notes

    If crv_ids is not NULL, then num_crvs must be a valid
    non-NULL pointer.
    This routine is no longer used for horizon edges, only
    for parting lines which are placed as curve objects in 
    a graphic group.

History

    30 Aug 1988 AIC  Genesis.
    12 Jul 1990 AIC  Modified to handle multiple vectors.
    09 Oct 1990 AIC  Handle cases where there are no results.
    29 Apr 1991 Jack Modified for 2.0.1 Horizon Loop implementation. 
    28 Nov 1991 Jack Removed generating horizon edge status message.
                     Also reacted to EMpartingLines returning -1
                     groups to signify the object was a plane.
    16 Feb 1991 Jack Moved the call to get the partolbasis earlier in
                     the method.
    25 Aug 1992 NP   Modified for ANSI compliance. Added typecast in realloc.
*/
{

  IGRboolean            loopset_constructed = FALSE;
  unsigned short        trim = NULL;
  long                  sts = OM_S_SUCCESS;
  int                   local_numgrps = 0,
                        i;

  double                *v;

  GRobjid               ls_id = NULL_OBJID,
                        flp_id = NULL_OBJID;
  struct GRid           *local_crv_ids = NULL;
  struct BSpartgrp      *local_partgrps = NULL;
  struct EMSpartolbasis partolbasis;

  extern IGRboolean     EFplace_line_string();
  OM_S_CHANSELECT       to_loopset,
                        to_owner,
                        to_edges;
  IGRboolean            world = TRUE;


  /*
   * Check options validity.
   */
  if(((options & EMSplaceProfileCurves) && (num_vectors != 1)) ||
     ((options & EMSplaceProfileFeatures) && (options & EMSignoreBoundaries)))
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }

  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;
  local_numgrps = 0;

  sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  if(! (1 & sts)) goto wrapup;


   /*
    * Get the surface parametric tolerance.
    */
    sts = om$send(msg =  message EMSsubbs.EMpartolbasis(
                                 EMmsg,
                                &md_env->md_env.matrix_type, 
                                 md_env->md_env.matrix,
                                &world, 
                                 FALSE, 
                                &partolbasis.tol),
                  targetid = my_id);
    if(! (1 & sts)) goto wrapup;
    partolbasis.is_valid = TRUE;
    partolbasis.in_world = TRUE;
    partolbasis.mattyp = &md_env->md_env.matrix_type;
    partolbasis.mat = md_env->md_env.matrix;



  /*
   * Set the trimming options
   */
  if(options & EMSplaceProfileFeatures)
  {
    trim = EMSuntrimmedParametricData;
  }
  else if(options & EMSplaceProfileCurves)
  {
    if(options & EMSignoreBoundaries) trim = EMSuntrimmedWorldData;
    else trim = EMStrimWorldData;
  }
  else { *EMmsg = EMS_I_NoSolution; goto wrapup; }

  for(i = 0, v = (IGRdouble *) vectors; i < num_vectors; i ++, v += 3)
  {
    int exists = FALSE;

    /*
     * Free the memory for the parting line data.
     */
    if(local_partgrps)
    {
      int                 j;
      struct BSpartgrp    *grp;

      for(j = 0, grp = local_partgrps; j < local_numgrps; j ++)
      {
        if(grp->pts) om$dealloc(ptr = grp->pts);
        grp->pts = NULL;
        if(grp->par) om$dealloc(ptr = grp->par);
        grp->par = NULL;
        grp = grp->next;
      }
      om$dealloc(ptr = local_partgrps);
      local_partgrps = NULL;
    }

    if(! (exists && (options & EMSplaceProfileFeatures)))
    {

      /*
       * Calculate the parting lines
       */
      local_numgrps = 0;
      local_partgrps = NULL;
      sts = om$send(msg = message EMSsubbs.EMpartingLines(
                                  EMmsg, 
                                  md_env, 
                                  v, 
                                  trim,
                                 &partolbasis, 
                                 &local_numgrps, 
                                 &local_partgrps),
                    targetid = my_id);
      if(! (1 & sts)) goto wrapup;

      /* EMpartingLines returns -1 if the surface was an ancestor of 
         EMSplane, just return. 
       */
    if(local_numgrps >= 0) /* there are results */        
     {
      if(options & EMSplaceProfileFeatures)
      {
        int                 j;
        int                 count;
        struct BSpartgrp    *grp;

        /*
         * Construct the feature loop.
         */
        sts = om$construct(classid = OPP_EMShorizon_class_id,
                           p_objid = &flp_id);
        if(! (1 & sts)) goto wrapup;


        if(local_numgrps) /* There are results */
        {
          /*
           * Make linear edges for each parting line group.
           */
          for(j=0, grp=local_partgrps; j<local_numgrps; grp=grp->next, j++)
          {
            GRobjid               edge_id;
            struct IGRpolyline    inpoly;

            /*
             * Construct the edge.
             */
            inpoly.num_points = grp->num;
            inpoly.points = (IGRdouble *) grp->par;
            sts = om$construct(classid = OPP_EMSlinedge_class_id,
                               p_objid = &edge_id);
            if(! (1 & sts)) goto wrapup;

            sts = om$send(msg = message EMSlinedge.EMleinit(
                                        EMmsg, 
                                        NULL, 
                                        EMlinestring,
                                       &inpoly, 
                                       &partolbasis, 
                                        NULL, 
                                        my_id),
                          targetid = edge_id);


            sts = EMmake_chanselect( EMSedge_to_owner, &to_owner );
            EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup );

            sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
            if(! (1 & sts)) goto wrapup;
                

            /*
             * Add the edge to the feature.
             */
            sts = om$send(msg = message Root.connect(
                                        to_owner,         /* targ. chan */
                                        0,                /* targ index */
                                        flp_id,           /* send objid */
                                        OM_Gw_current_OS, /* send os    */
                                        to_edges,         /* send chan  */ 
                                        0),               /* from index */
                          targetid = edge_id);
            if(! (1 & sts)) goto wrapup;

          } /* for */

        } /* if there are results */

        /*
         * Initialize the feature loop data.
         */
        sts = om$send(msg = message EMSgraloop.EMglpinit(
                                               EMmsg, 
                                               EMLP_ACTIVE,
                                              &partolbasis, 
                                               my_id),
                      targetid = flp_id);
        if(! (1 & sts)) goto wrapup;
	

        /*
         * Initialize the view-specific data.
         */
        sts = om$send(msg = message EMShorizon.EMset_orientation(
                                        NULL, 
                                        v),
                      targetid = flp_id);
        if(! (1 & sts)) goto wrapup;

        /*
         * If there is no loopset create one.
         */
        for(count = 0; (ls_id IS NULL_OBJID) || (count <= 1); count ++)
        {
          /*
           * Get the id of the loopset.
           */
          sts = om$send(msg = message EMSboundary.EMget_objid(
                                                  EMmsg, 
                                                 &ls_id),
                        p_chanselect = &to_loopset);
          if(! (1 & sts)) goto wrapup;

          if(ls_id IS NULL_OBJID)
          {
            /*
             * There is not a loopset, create one.
             */
            loopset_constructed = TRUE;
            sts = om$send(msg = message EMSsubbs.EMmk_nat_bdry(
                                                 EMmsg, 
                                                &md_env->md_env,
                                                 NULL),
                          targetid = my_id);
            if(! (1 & sts)) goto wrapup;

          } /* if ls_id IS NULL_OBJID */

          count ++;

        } /* for */

        if(ls_id IS NULL_OBJID) { *EMmsg = EMS_E_Fail; goto wrapup; }

        /*
         * Update the features against the boundaries
         */
        sts = om$send(msg = message EMSgraloop.EMupdate_feature(
                                                 EMmsg, 
                                                &md_env->md_env.matrix_type,
                                                 md_env->md_env.matrix),
                      targetid = flp_id);

      } /* if place features */

      /*
       * Place the profiles as curves.
       */
      if((options & EMSplaceProfileCurves) && (local_numgrps > 0))
      {
        int                 j;
        struct BSpartgrp    *grp;

        /*
         * Allocate the local GRid array.
         */
        local_crv_ids = (struct GRid *)om$malloc
                        (size = local_numgrps * sizeof(*local_crv_ids));
        if(! local_crv_ids) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }

        for(j=0, grp=local_partgrps; j<local_numgrps; j++, grp=grp->next)
        {
          IGRboolean status;

          /*
           * Construct the curve.
           */
          local_crv_ids[j].osnum = construct_list->env_info->md_id.osnum;
          status = EFplace_line_string(my_id, 
                                       construct_list, 
                                       grp->num,
                                       grp->pts, 
                                      &local_crv_ids[j].objid, 
                                       EMmsg); 
          if(! status) { *EMmsg = EMS_E_Fail; goto wrapup; }

        } /* for j < local_numgrps */

        if(crv_ids) /* Return the curve ids? */
        {
          if(*crv_ids) /* Are there already curves from a previous call? */
          {
            int size;

            /*
             * Concatenate the crv_ids array with local_crv_ids.
             */
            size = (*num_crvs + local_numgrps) * sizeof(*local_crv_ids);
            *crv_ids = (struct GRid *) om$realloc(ptr = (IGRchar *)*crv_ids, 
							size = size);
            size = local_numgrps * sizeof(*local_crv_ids);
            OM_BLOCK_MOVE(local_crv_ids, &(*crv_ids)[*num_crvs], size);
            *num_crvs += local_numgrps;
            om$dealloc(ptr = local_crv_ids);
          }
          else /* First set of curves */
          {
            /*
             * Return the results.
             */
            *crv_ids = local_crv_ids;
            *num_crvs = local_numgrps;
          }

        } /* if crv_ids */

        else if(num_crvs) *num_crvs += local_numgrps;

      } /* if place curves and local_numgrps */
     } /* if the surface is not a plane */
    } /* if not (placing features and appropriate features exist) */

  } /* for each vector */

wrapup:
  /*
   * Clean up memory allocated for curve ids unless it being returned.
   */
  if((local_crv_ids) && (! crv_ids)) om$dealloc(ptr = local_crv_ids);

  /*
   * Free the memory for the parting line data.
   */
  if(local_partgrps)
  {
    int                 i;
    struct BSpartgrp    *grp;

    for(i = 0, grp = local_partgrps; i < local_numgrps; i ++)
    {
      if(grp->pts) om$dealloc(ptr = grp->pts);
      grp->pts = NULL; 
      if(grp->par) om$dealloc(ptr = grp->par);
      grp->par = NULL;
      grp = grp->next;
    }
    om$dealloc(ptr = local_partgrps);
    local_partgrps = NULL;
  }

#if REPORT
 ex$message(msgnumb = EMS_I_ClearStatusField)
#endif

  EMWRAPUP(*EMmsg, sts, "EMSsubbs.EMprofile")
  return sts;
}

end implementation EMSsubbs;
