class implementation EMSsfboolean;

#include "EMS.h"
#include "OMmacros.h"

method EMgetSSI(IGRlong *EMmsg; union EMSssi_table **ssi)
/*
Description
    This method gets the stave state info structure from the instance
    data of this object and orders it logically. 

Return values 
    EMmsg - EMS_S_Success if all goes well.

History

13 Apr 1989 jBk Modified to return valid SSI tables for the
                currently inconsistently represented disjoint
                boolean results.  Consistency checks can be
                removed when disjoint boolean operations always
                construct a consistent SSI table.

                When the instance data representations of SSI
                tables are always consistent, all references to
                the variables "insconsistent," "firstOnly,"
                "allButFirst," and "lastOnly" may be removed, as
                well as all clauses dependent only upon said
                variables.

    DLB    11/02/87    Changed name of structure to ssi for vers. 1.1.0

    AIC    03/31/87    Creation Date
*/
{
  IGRlong                   sts;
  IGRint                    i, j, k, l, total_surfs_out;
  struct EMSboolssi_table   *my_info;
  union EMSssiSizeData      size_data;
  IGRboolean inconsistent = FALSE, firstOnly, allButFirst, lastOnly;
  IGRboolean emptySet, active;

  /*Initialize.*/
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  *ssi = NULL;
  active = me^^EMSdpr.dpr_props & EMSIS_ACTIVE_PATH;

  sts = om$send(msg = message EMSdpr.EMgetSSIsize(EMmsg, &size_data),
                targetid = my_id);
  if (!(1 & sts & *EMmsg)) goto wrapup;

  if (*EMmsg IS EMS_I_Success)
  {
    inconsistent = TRUE;
  }

  if (inconsistent OR NOT active)
  {
    sts = om$send (
        msg = message EMSsfboolean.EMget_operation_type (
            EMmsg       /* IGRlong *EMmsg; */,
            NULL        /* enum EMSbooltype *request; */,
            NULL        /* enum EMSbooltype *exactOperation; */,
            NULL        /* enum EMSbooltype *generalOperation; */,
            NULL        /* IGRboolean *reverseOrientation; */,
            &emptySet   /* IGRboolean *emptySet; */,
            NULL        /* IGRboolean *disjointSurfaces; */,
            &firstOnly  /* IGRboolean *firstOnly; */,
            &allButFirst/* IGRboolean *allButFirst; */,
            &lastOnly   /* IGRboolean *lastOnly; */,
            NULL        /* IGRboolean *removedSolids; */,
            NULL        /* IGRlong *msgNumber */
        ),
        targetid = my_id
    );
  }

  if (!(1 & sts & *EMmsg)) goto wrapup;

  sts = om$send(msg = message EMSdpr.EMgetSSIbuffer(EMmsg, &size_data,
                      ssi), 
                targetid = my_id); 
  if (!(1 & sts & *EMmsg)) goto wrapup;

  my_info = &((*ssi)->bool_info);

/*
  my_info->num_composites = ME.EMSsfboolean->num_composites;

  The above line would be fine if all SSI tables were consistent,
  but, since they are not, I prefer to rely upon the information
  returned from message EMgetSSIsize. -- jBk
*/
  
  my_info->num_composites = size_data.bool_info.num_composites;

  /*Move num surfs out per composite to ssi struct.*/

  if (inconsistent)
  {
    /*
        total_surfs_out is only used for instances of consistent
        SSI tables so we needn't set it
    */

    my_info->num_surfaces_out[0] = size_data.bool_info.num_surfaces_out;

  }
  else
  {
    total_surfs_out = 0;
    for (i = 0; i < my_info->num_composites; i ++)
    {
       my_info->num_surfaces_out[i] = ME.EMSsfregmod->in_out[i];
       /*Compute total num surfs out in order to get comp indices*/
       total_surfs_out += ME.EMSsfregmod->in_out[i];
    }
  }

  my_info->num_surfaces = ME.EMSsfregmod->num_surfaces;

  /*Move num loops in per surf to ssi struct.*/
  for (j = 0; j < my_info->num_surfaces; j ++, i ++)
    my_info->num_regions_in[j] = ME.EMSsfregmod->in_out[i];

  /*Move num loops out per surf to ssi struct.*/
  for (j = 0; j < my_info->num_surfaces; j ++, i ++)
    my_info->num_regions_out[j] = ME.EMSsfregmod->in_out[i];

  if (inconsistent)
  {
    int low_ix, high_ix, comp_index;
    IGRint *p_ix;

    if (emptySet OR lastOnly)
    {
        /* no operands or only last operand kept active */

        low_ix = 0;
        high_ix = size_data.bool_info.num_surfaces_out - 1;
        comp_index = 0;
/*
        since we start with the highest index and procede to
        lower indices in EMdeactivate, add them all back at index
        zero
*/
    }
    else if (firstOnly)
    {
        /* only first operand kept active */

        low_ix = 1;
        high_ix = size_data.bool_info.num_surfaces_out;
        comp_index = 1;
/*
        since we start with the highest index and procede to
        lower indices in EMdeactivate, add them all back at index
        one
*/
    }
    else if (allButFirst)
    {
        /* first operand removed into SSI table instance */

        low_ix = 0;
        high_ix = 0;
        comp_index = 0;

        /* size_data.bool_info.num_surfaces_out must be 1 */
    }
    else
    {
        sts = OM_E_ABORT;
        *EMmsg = EMS_E_Fail;
        goto wrapup;
    }
    
    p_ix = my_info->composite_indices;

    while (low_ix++ <= high_ix)
    {
      *p_ix++ = comp_index;
    }
  }
  else /* consistent */
  {
    /*Move composite to surface channel indices to ssi struct.*/
    for (j = 0; j < total_surfs_out; j ++, i ++)
      my_info->composite_indices[j] = ME.EMSsfregmod->in_out[i];
  }

  if (inconsistent)
  {
    my_info->composite_ids[0] = my_id;
    i = 0;
  }
  else
  {
    /*Get the composite ids.*/
    for(i = 0; i < my_info->num_composites; i ++)
    {
      sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
      if (sts == OM_S_SUCCESS)
        my_info->composite_ids[i] = ME.EMSdpr->ids[i];
      else
      {
        my_info->composite_ids[i] = NULL_OBJID;
        sts = OM_S_SUCCESS;
      }
    }
  }

  l = 0;
  for(j = 0; j < my_info->num_composites; j ++)
  {
    for(k = 0; k < my_info->num_surfaces_out[j]; k ++, i ++, l ++)
    {
      sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
      if (sts == OM_S_SUCCESS)
        my_info->surface_out_ids[l] = ME.EMSdpr->ids[i];
      else
      {
        my_info->surface_out_ids[l] = NULL_OBJID;
        sts = OM_S_SUCCESS;
      }
    }
  }

  for(j = 0; j < my_info->num_surfaces; j ++, i ++)
  {
    sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
    if (sts == OM_S_SUCCESS)
      my_info->surface_ids[j] = ME.EMSdpr->ids[i];
    else
    {
      my_info->surface_ids[j] = NULL_OBJID;
      sts = OM_S_SUCCESS;
    }
  }

  l = 0;
  for(j = 0; j < my_info->num_surfaces; j ++)
  {
    for(k = 0; k < my_info->num_regions_in[j]; k ++, i++, l ++)
    {
      sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
      if (sts == OM_S_SUCCESS)
        my_info->region_in_ids[l] = ME.EMSdpr->ids[i];
      else
      {
        my_info->region_in_ids[l] = NULL_OBJID;
        sts = OM_S_SUCCESS;
      }
    }
  }

  l = 0;
  for(j = 0; j < my_info->num_surfaces; j ++)
  {
    for(k = 0; k < my_info->num_regions_out[j]; k ++, i++, l ++)
    {
      sts = om$is_objid_valid(objid = ME.EMSdpr->ids[i]);
      if (sts == OM_S_SUCCESS)
        my_info->region_out_ids[l] = ME.EMSdpr->ids[i];
      else
      {
        my_info->region_out_ids[l] = NULL_OBJID;
        sts = OM_S_SUCCESS;
      }
    }
  }

  if (emptySet AND NOT active AND my_info->num_composites)
  {
    /* null symbol id is in output SSI table; must replace it */

    my_info->composite_ids[0] = my_id;

    if (inconsistent)
    {
        IGRint childCt;

        sts = om$send (
            msg = message GRowner.GRget_number_components (
                EMmsg,
                &childCt
            ),
            targetid = my_id
        );

        if (EMSokay (sts) AND EMSokay (*EMmsg))
        {
            /* got number components */

            if (childCt)
            {
                struct GRid zeroIndexChild;

/*
                send wrt message for class EMScomposite because I
                do not want the EMSsfdpr implementation of this
                message; that is, I do not necessarily want
                leaves but actual children 
*/

                sts = om$send (
                    mode = OM_e_wrt_message,
                    msg = message EMScomposite.GRget_components (
                        EMmsg,
                        NULL,
                        &zeroIndexChild,
                        1,
                        &childCt,
                        0,
                        OM_K_MAXINT
                    ),
                    targetid = my_id
                );
    
                if (childCt IS 1 AND EMSokay (sts) AND EMSokay (*EMmsg))
                {

                    me^^EMSdpr.ids[0] = zeroIndexChild.objid;
                }
                else
                {
                    sts = OM_E_ABORT;
                    *EMmsg = EMS_E_Fail;
                }
            }
            else /* zero components; perhaps already removed */
            {
                me^^EMSdpr.ids[0] = NULL_OBJID;
            }

        } /* fi got number components */

    } /* fi inconsistent */

  } /* fi null symbol id is in output SSI table; must replace it */

 wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSsfboolean.EMgetSSI")
  return(sts);
}
end implementation EMSsfboolean;
