class implementation EMSplane;

#include "EMSlmdef.h"
#include "EMSbnd.h"
#include "EMSprop.h"

/*


DESCRIPTION

  This method tranfers the common edges connections from the old
surfaces to the new plane. It returns a linked list of surfaces
removed together with their respective owners.

HISTORY

  07/09/92  : AMD : Creation.
  09/29/92  : AMD : Maintain dominant properties of the edges as
                    before the unite surface state.
  09/30/92  : AMD : Use EMconnect_edges instead of EMstitch to connect
                    up the edges of the new plane. Done because
                    EMstitch was not able to connect tiny edges.
*/

from EMSedge import EMconnect_edges, EMdisplay, 
                    EMget_props, EMset_props;


method EMreplace_with_new_plane ( IGRlong *msg;
                                  struct GRmd_env *md_env;
                                  struct EMSpartolbasis *partolbasis;
                                  IGRint num_surfs;
                                  GRobjid *surfs;
                                  IGRint num_edinfo;
                                  struct EMmerge_info *edinfo;
                                  IGRint *numowners;
                                  struct EMSownercomp **ownercomps)

{
 IGRlong                    sts;
 OM_S_CHANSELECT            chan_to_owners, chan_to_comps,
                            to_comm_edge;
 OM_S_OBJECT_LINKAGE        ownlist;
 IGRint                     i;
 GRobjid                    compid;
 struct GRid                ownerid;
 OMuint                     index, count;
 IGRushort                  edprops, newed_props,
                            commed_props;
 IGRboolean                 is_composite_surface = FALSE;

 void EMmkownlist(); 

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;

 EMmake_chanselect (GRconnector_to_owners, &chan_to_owners);
 EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
 EMmake_chanselect (EMSedge_to_common_edge, &to_comm_edge );


 /* Disconnect the  surfaces and store the composite and the index on
    which it is connected */
 
 for (i=0; i<num_surfs; i++)
 {
  sts = om$get_channel_objects ( objid = surfs[i],
                                p_chanselect = &chan_to_owners,
                                list = &ownlist,
                                size = 1,
                                count = &count );
  EMomerr_hndlr (sts, ret_end, "om$get_channel_objects"); 

  compid = ownlist.S_objid;

  sts = om$get_index ( objid_c = compid,
                       p_chanselect = &chan_to_comps,
                       objid = surfs[i],
                       indexaddr = &index );
  EMomerr_hndlr (sts, ret_end, "om$get_index"); 

  ownerid.objid = compid;
  ownerid.osnum = OM_Gw_current_OS;

  sts = om$send ( msg = message GRconnector.GRdisconn
                ( msg , &ownerid),
           targetid = surfs[i]);
  EMomerr_hndlr (sts, ret_end, "GRconnector.GRdisconn"); 

  if(ownercomps)
  {
   IGRboolean list_extended;
   EMmkownlist ( msg, ownercomps, compid, index, surfs[i], FALSE,
                 &list_extended );
   EMomerr_hndlr (sts, ret_end, "EMmkownlist"); 

   if (list_extended && numowners)
   (*numowners)++;
  }

 }

 /* Disconnect the common edges  */

  for ( i=0; i<num_edinfo; i++)
  {
   if (edinfo[i].edge1 != NULL_OBJID)
    {
     sts = om$send ( msg = message Root.disconnect ( to_comm_edge, 
                     edinfo[i].edge1, OM_Gw_current_OS, to_comm_edge),
              targetid = edinfo[i].edge0);
     EMomerr_hndlr (sts, ret_end, "Root.disconnect"); 
    }
  }
                    
 /* Stitch my common edges */

  for (i=0; i<num_edinfo; i++)
  {
   if (edinfo[i].edge1 != NULL_OBJID)
   {

    /* Get the dominant properties before connecting */

    edprops=NULL; newed_props=NULL; commed_props=NULL;

    if(!is_composite_surface) index = i;

    is_composite_surface = TRUE;

    sts = om$send ( msg = message EMSedge.EMget_props ( msg,
                           &edprops),
             targetid = edinfo[i].edge1);
    EMomerr_hndlr (sts, ret_end, "EMSedge.EMget_props"); 

    sts = om$send(msg = message EMSedge.EMconnect_edges( msg,
                        edprops, TRUE, edinfo[i].new_edge,
                        NULL_OBJID, NULL_OBJID, &md_env->md_env),
             targetid = edinfo[i].edge1);
    EMomerr_hndlr (sts, ret_end, "EMSedge.EMconnect_edges"); 

    /* Maintain the dominant properties as before */

    sts = om$send(msg = message EMSedge.EMget_props(
                        msg, &newed_props),
             targetid = edinfo[i].new_edge);
    EMomerr_hndlr (sts, ret_end, "EMSedge.EMget_props"); 

    sts = om$send(msg = message EMSedge.EMget_props(
                        msg, &commed_props),
             targetid = edinfo[i].edge1);
    EMomerr_hndlr (sts, ret_end, "EMSedge.EMget_props"); 

    if(edprops & EMED_SUBORDINATE)
     {
      commed_props |= EMED_SUBORDINATE;
      newed_props &= ~EMED_SUBORDINATE;
     }
    else
     {
      newed_props |= EMED_SUBORDINATE;
      commed_props &= ~EMED_SUBORDINATE;
     }

    sts = om$send(msg = message EMSedge.EMset_props(
                        msg, newed_props, EMS_O_SET),
             targetid = edinfo[i].new_edge);
    EMomerr_hndlr (sts, ret_end, "EMSedge.EMset_props"); 

    sts = om$send(msg = message EMSedge.EMset_props(
                        msg, commed_props, EMS_O_SET),
             targetid = edinfo[i].edge1);
    EMomerr_hndlr (sts, ret_end, "EMSedge.EMset_props"); 
   }
  }   

 /* Orient the new plane */

 if(is_composite_surface)
 {
  struct IGRbsp_surface        *surface1=NULL, *surface2=NULL;
  IGRlong                      surf1_size, surf2_size;
  IGRushort                    props0=NULL, props1 = NULL;
  IGRboolean                   rev_orient;
  
  edprops = NULL;

  sts = om$send ( msg = message EMSedge.EMget_props ( msg,
                        &edprops),
           targetid = edinfo[index].edge1);
  EMomerr_hndlr (sts, ret_end, "EMSedge.EMget_props"); 

  sts = om$send ( msg = message GRvg.GRgetsize ( msg,
                  &md_env->md_env.matrix_type, md_env->md_env.matrix,
                  &surf1_size),
           targetid = edinfo[index].surf1);
  EMomerr_hndlr (sts, ret_end, "GRvg.GRgetsize"); 

  surface1 = (struct IGRbsp_surface *) alloca(surf1_size);

  sts = om$send ( msg = message EMSsubbs.GRgetgeom( msg,
                  &md_env->md_env.matrix_type,
                  md_env->md_env.matrix, (IGRchar *) surface1),
          targetid = edinfo[index].surf1);
  EMomerr_hndlr (sts, ret_end, "EMSsubbs.GRgetgeom"); 

  sts = om$send ( msg = message GRvg.GRgetsize ( msg,
                  &md_env->md_env.matrix_type, md_env->md_env.matrix,
                  &surf2_size),
           targetid = my_id);
  EMomerr_hndlr (sts, ret_end, "GRvg.GRgetsize"); 

  surface2 = (struct IGRbsp_surface *) alloca(surf2_size);

  sts = om$send ( msg = message EMSsubbs.GRgetgeom( msg,
                  &md_env->md_env.matrix_type,
                  md_env->md_env.matrix, (IGRchar *) surface2),
          targetid = my_id);
  EMomerr_hndlr (sts, ret_end, "EMSsubbs.GRgetgeom"); 

  props0 = surface1->pos_orient ? 0x1 : 0x0;
  props1 = surface2->pos_orient ? 0x1 : 0x0;

  if(edprops & EMED_REVERSE_CONNECT)
     rev_orient = (props0 ^ props1) ? TRUE : FALSE;
  else
     rev_orient = (props0 ^ props1) ? FALSE : TRUE;

  if(rev_orient)
   {
    sts = om$send ( msg = message EMSsurface.EMrevorient(msg),
                    targetid = my_id);
    EMomerr_hndlr (sts, ret_end, "EMSsurface.EMrevorient"); 
   }
 }

 /* Switch on my property bits */

  EFsetsfstate ( msg, my_id, OM_Gw_current_OS, EMS_O_ON);

ret_end:

 return (sts);

}

end implementation EMSplane;
 

 
 
