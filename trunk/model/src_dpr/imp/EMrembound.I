class implementation EMSsfrembnd;

/*

DESCRIPTION

 This method removes the loops from the surface/solid and stores the
information in SSI table.

HISTORY

 August 1991 :  AMD  :  Creation
 07/09/1992  :  AMD  :  Fixed an uninitialized pointer

*/
 

#include "EMSerrordef.h"
#include "emserr.h"
#include "EMSopt.h"
#include "EMSlmdef.h"

extern GRclassid  OPP_EMSloopset_class_id;

extern IGRlong EFcheck_loop_position();

from EMSsubbs import EMpassloop;
from EMSloopset import EMtoglpactive;
from EMSloop import EMdelbnd_init;
from EMSedge import EMdisplay;

method EMremove_boundaries( IGRlong                 *EMmsg;
                            IGRshort                matrix_type[];
                            IGRmatrix               matrix;
                            struct GRvg_construct   construct_list;
			    struct GRid             active_GRid;
                            IGRint                  num_loops;
                            GRobjid                 *loop_ids)

{
 IGRlong                     rc, sts ;
 struct EMSdbssi_table       *myssiinfo;
 union  EMSssi_table         *ssibuff;
 union  EMSssiSizeData       size_data;
 GRobjid                     *edges;
 struct EMSownercomp         *sfmodloops, *solrmsfs, *ownlist;
 OMuint                      i, j, k, count ;
 IGRint                      inx, inxlim, num_edges ;
 IGRint                      altinx1, altinx2;
 IGRint                      numsfsmod, numsolsmod;
 IGRint                      totnumloops_out, totnumsfs_out;
 OM_S_CHANSELECT             loop_to_edges, to_components;
 OM_S_OBJECT_LINKAGE         comp_list;
 IGRushort                   options;
 IGRboolean                  outter_and_alone;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 
 EMmake_chanselect( EMSbd_owner_to_comps, &loop_to_edges);
 EMmake_chanselect( GRcmpowner_to_components, &to_components);

 sfmodloops = NULL;
 solrmsfs = NULL;
 ssibuff  = NULL;
 edges    = NULL;
 num_edges = 0;
 numsfsmod = 0;
 numsolsmod = 0;

 for( i=0; i<num_loops; i++)
  {
   outter_and_alone = FALSE;
 
  /*
   * Check if the loop is outermost and is connected to a loopset
   * which has only one loop. If not, then do not remove the surface.
   */ 

   EFcheck_loop_position (&rc, loop_ids[i], OM_Gw_current_OS,
			  &outter_and_alone);
   EMomerr_hndlr (sts, ret_end, "EFcheck_loop_position"); 

   if(outter_and_alone)
    options = EMS_REMBND_SURF ;
   else 
    options &=~ EMS_REMBND_SURF;

  /*
   * Send the message for removing the loop tree which is owned by
   * this loop.
   */
 
   sts = om$send (msg = message EMSloop.EMdelbnd_init(&rc,
                         construct_list,
		         &numsfsmod, &sfmodloops, 
			 &numsolsmod, &solrmsfs,
              		 &num_edges, &edges,
			 options),
          targetid = loop_ids[i]);                     
   EMomerr_hndlr (sts, ret_end, "EMSloop.EMdelbnd_init"); 
  }

  ownlist = solrmsfs;
  totnumsfs_out = 0;
  for (i=0; i<numsolsmod; i++)
    {
    totnumsfs_out += ownlist->num_comps;
    ownlist = ownlist->next;
    }
   
  ownlist = sfmodloops;
  totnumloops_out = 0;
  for (i=0; i<numsfsmod; i++)
    {
     totnumloops_out += ownlist->num_comps;
     ownlist = ownlist->next;
    }

 /* Find out the size of SSI table */

  size_data.db_info.num_composites = numsolsmod;
  size_data.db_info.num_surfaces_out = totnumsfs_out;
  size_data.db_info.num_surfaces = numsfsmod;
  size_data.db_info.num_regions_out = totnumloops_out;
  size_data.db_info.num_edges_disconnected = num_edges;

  sts = om$send (msg = message EMSdpr.EMgetSSIbuffer (&rc,
             &size_data, &ssibuff),
             targetid = my_id );
  EMerr_hndlr (EMSerror (rc), *EMmsg, EMS_E_SurfaceError, ret_end);

 /* Fill up the SSI table */

  myssiinfo = &ssibuff->db_info;
  myssiinfo->num_composites = numsolsmod;
  ownlist = solrmsfs;
  inx = 0;
  for (i=0; i<numsolsmod; i++)
    {
    myssiinfo->composite_ids[i] = ownlist->owner;
    inxlim = myssiinfo->num_surfaces_out[i] = ownlist->num_comps;
    for (j=0; j<inxlim; j++)
      {
      myssiinfo->surface_out_ids[inx] = ownlist->comps[j];
      myssiinfo->composite_indices[inx] = ownlist->ownerindex[j];
      inx++;
      }
    ownlist = ownlist->next;
    }

  myssiinfo->num_surfaces = numsfsmod;
  ownlist = sfmodloops;
  altinx1 = 0;
  altinx2 = 0;
  for (i=0; i<numsfsmod; i++)
    {
     myssiinfo->surface_ids[i] = ownlist->owner;
      inxlim = myssiinfo->num_regions_out[i] 
             = ownlist->num_comps;
      for (k=0; k<inxlim; k++)
        myssiinfo->region_out_ids[altinx2++] = ownlist->comps[k];

     ownlist = ownlist->next;
    }

  myssiinfo->num_edges_disconnected = num_edges;  
  myssiinfo->edges_disconnected = edges;

  sts = om$send (msg = message EMSsfrembnd.EMfixSSI( &rc,
                       (union EMSssi_table *) myssiinfo,
                        construct_list.env_info), 
        targetid = my_id);
  EMomerr_hndlr (sts, ret_end, "EMSsfrembnd.EMfixSSI"); 

  /* Save all the relevant information in my instance data. */

  sts = om$send (msg = message EMSdpr.EMputSSI ( &rc, 
                                            (union EMSssi_table *) myssiinfo),
                 targetid = my_id);
  EMomerr_hndlr (sts, ret_end, "EMSdpr.EMputSSI");

  /* The property bits - GRIS_DISPLAYABLE and GRIS_LOCATABLE are set
     off for all the surfaces removed. All the loops removed are set
     to inactive */

   inx = 0;
   for (i=0; i<myssiinfo->num_composites; i++)
     {
     for (j=0; j<myssiinfo->num_surfaces_out[i]; j++)
       {
       EFsetsfstate (&rc, myssiinfo->surface_out_ids[inx],
        OM_Gw_current_OS, EMS_O_OFF);
       EMomerr_hndlr (sts, ret_end, "EFsetsfstate");

       sts = om$send(msg = message EMSsubbs.EMpassloop(&rc, 
                  message EMSloopset.EMtoglpactive(&rc)),
               targetid = myssiinfo->surface_out_ids[inx++],
               targetos = OM_Gw_current_OS, 
               senderid = NULL_OBJID);
       EMomerr_hndlr (sts, ret_end, "EMSsubbs.EMpassloop");
       }
     } 

   /* Added for associativity check. In case of recompute the
      connection already exists. */

   sts = om$get_channel_objects ( osnum = OM_Gw_current_OS,
				  objid = my_id,
				  p_chanselect = &to_components,
				  list = &comp_list,
				  size = 1,
				  count = &count);
   EMomerr_hndlr (sts, ret_end, "om$get_channel_objects");

/* fix for umr */
   if(count)
     if (comp_list.S_objid == active_GRid.objid) goto ret_end;

   /* Connect myself to the active state */
   {
    IGRlong             index;
    struct GRid        myGRid;
  
    index = 0;

    myGRid.objid = my_id;
    myGRid.osnum = OM_Gw_current_OS;

     sts = om$send(msg = message GRconnector.GRrigidconn(&rc,
                   &myGRid, &index ),
           targetid = active_GRid.objid,
	   targetos = active_GRid.osnum);
     EMomerr_hndlr (sts, ret_end, "GRconnector.GRrigidconn");

   }

  ME.EMSdpr->dpr_props = EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH;    
 
  ME.GRgraphics->properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  {
   /*Set my last state's active bits off - this could be subbs so I ignore
    * UNKNOWN_MSG warning. -- DLB
    */
    OM_S_CHANSELECT    to_components;
    IGRboolean action = FALSE;
    IGRushort mask = EMSIS_ACTIVE_STATE;

    EMmake_chanselect(GRcmpowner_to_components, &to_components);
    sts = om$send(msg = message EMSdpr.EMsetprops(&rc, &action, 
                            &mask),
                      p_chanselect = &to_components,
             senderid = my_id);
    if(sts != OM_W_UNKNOWN_MSG)
    {
      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, ret_end);
      EMerr_hndlr (EMSerror(rc), *EMmsg, EMS_E_Fail, ret_end);
    }
    else
      sts = OM_S_SUCCESS; /*fix the return code*/
  }


ret_end:
 
  if(edges) om$dealloc (ptr=edges);
  if (sfmodloops)
    EMownercomp_free (sfmodloops, MAXINT);
  if (solrmsfs)
    EMownercomp_free (solrmsfs, MAXINT);
  /* fix for mlk */
 if(ssibuff) om$dealloc(ptr = ssibuff);

  return (sts);
}

end implementation EMSsfrembnd;
