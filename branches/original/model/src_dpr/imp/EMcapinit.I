class implementation EMSsfcapsf;

/* 

HISTORY

   AMD : 11/10/92 : Creation

DESCRIPTION

   This method prepares the dpr state for the 'place solid by capping'
   command

*/
 

#define BUFF_INCR  30

method  EMprepare_dpr_state ( IGRlong      *EMmsg;
                              IGRushort    dpr_options;
                              IGRint       num_caps;
                              GRobjid      *caps)

{
 IGRlong                      sts;
 struct GRid                  *sfedges = NULL, my_grid;
 IGRint                       array_size, numed, num_cap_edges,
                              i, j;
 OMuint                       edge_count;
 struct EMScapssi_table       *myssiinfo;
 union  EMSssi_table          *ssibuff;
 union  EMSssiSizeData        size_data;
 OM_S_CHANSELECT              to_components, to_common_edge;
 GRobjid                      *cap_edges = NULL;
 OM_S_OBJECT_LINKAGE          comm_edge;


 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 num_cap_edges = 0;

 EMmake_chanselect ( EMSedge_to_common_edge, &to_common_edge);
 EMmake_chanselect (GRcmpowner_to_components, &to_components);

 /* Get all the connected edges of the caps */

 for ( i=0; i<num_caps; i++)
 {
  numed = 0;
  sfedges = NULL;
  array_size = 0;
  sts = om$send (msg = message EMSsurface.EMgetedges ( EMmsg,
                       EMS_OPT_NONDEG_NONSEAM, &sfedges, &array_size,
                       &numed, NULL, NULL, NULL, NULL),
           targetid = caps[i],
           targetos = OM_Gw_current_OS,
           senderid = NULL_OBJID);
  EMomerr_hndlr (sts, ret_end, "EMSsurface.EMgetedges");  

  /* Get the common edge */

  for (j=0; j<numed; j++)
  {
   sts = om$get_channel_objects (
                objid = sfedges[j].objid,
                p_chanselect = &to_common_edge,
                list = &comm_edge,
                size = 1,
                count = &edge_count);
   EMomerr_hndlr (sts, ret_end, "om$get_channel_objects");  

    if(! (num_cap_edges % BUFF_INCR))
     {
      if (!num_cap_edges)
       cap_edges = (GRobjid *) om$malloc ( size = (BUFF_INCR) * 
                   sizeof (GRobjid *));   
      else
       cap_edges = (GRobjid *) om$realloc ( ptr = (IGRchar *)(cap_edges),
                    size = ((num_cap_edges) + BUFF_INCR) * 
                    sizeof (GRobjid *));
     }

   cap_edges[num_cap_edges] = sfedges[j].objid;
   cap_edges[num_cap_edges + 1] = comm_edge.S_objid;
   num_cap_edges += 2;
  }   
  /*fix for mlk */
  if( sfedges ) om$dealloc ( ptr = sfedges );
 }

  /* Fill up the SSI table */

  sts = om$send(msg = message EMSdpr.EMgetSSIsize
                      (EMmsg, &size_data),
           targetid = my_id);
  EMomerr_hndlr (sts, ret_end, "EMSdpr.EMgetSSIsize");  
  if (!(1 & sts & *EMmsg)) goto ret_end;

  size_data.cap_info.num_edges = num_cap_edges;

  sts = om$send ( msg = message EMSdpr.EMgetSSIbuffer(
                        EMmsg, &size_data, &ssibuff),
           targetid = my_id); 
  EMomerr_hndlr (sts, ret_end, "EMSdpr.EMgetSSIbuffer");  

  myssiinfo = &ssibuff->cap_info;

  myssiinfo->num_edges = num_cap_edges;

  for (i=0; i<myssiinfo->num_edges; i++)
   myssiinfo->edges_connected[i] = cap_edges[i];

  sts = om$send (msg = message EMSdpr.EMputSSI(EMmsg,
                      (union EMSssi_table *) myssiinfo),
          targetid = my_id);
  EMomerr_hndlr (sts, ret_end, "EMSdpr.EMputSSI");

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  ME.EMSdpr->dpr_props = EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH;    
 
  ME.GRgraphics->properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  /* Set my last state's active bits off - this could be subbs so I ignore
   * UNKNOWN_MSG warning.
   */

  {
   IGRboolean action = FALSE;
   IGRushort mask = EMSIS_ACTIVE_STATE;

   sts = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action, 
                       &mask),
            p_chanselect = &to_components,
            senderid = my_id);
    if(sts != OM_W_UNKNOWN_MSG)
    {
      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, ret_end);
    }
    else
      sts = OM_S_SUCCESS; /*fix the return code*/
  }


ret_end:

 if( cap_edges ) om$dealloc ( ptr = cap_edges );
/* fix for mlk */
 if(ssibuff) om$dealloc(ptr = ssibuff);
 return (sts);

}


end implementation EMSsfcapsf;
  
