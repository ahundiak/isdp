class implementation EMSsubbs;

#include "EMSlmdef.h"
#include "EMSbnd.h"
#include "EMSprop.h"
#include "bs.h"
#include "bsparameters.h" 

/*

DESCRIPTION

  This function tranfers the common edges connections from the old
surfaces to the new plane. It returns a linked list of surfaces
removed together with their respective owners.

HISTORY

 08/14/97 : Nilesh : Creation.
                     Maintain dominant properties of the edges as
                     before the unite surface state.Note:
                     EMstitch was not able to connect tiny edges.
                     Added the code for Handling Unite of Tangential surfaces.
 01/07/98 : kiran :  Modified.
            jaikish 

                     Dominant properties are correctly allocated.  
                     Used EMconnect_edges instead of EMstitch to connect
                     up the edges of the new plane. The Emed_reverse_connect
                     bit was removed, as it is taken care by EMedconnect
                     edges;
*/

from EMSedge import EMconnect_edges, EMdisplay, 
                    EMget_props, EMset_props;

 extern void EMmkownlist(); 

IGRlong EMreplace_with_new_surf (msg,md_env,partolbasis,num_surfs,surfs,
                num_edinfo,edinfo,numowners,ownercomps,new_surf) 
                                  IGRlong *msg;
                                  struct GRmd_env *md_env;
                                  struct EMSpartolbasis *partolbasis;
                                  IGRint num_surfs;
                                  GRobjid *surfs;
                                  IGRint num_edinfo;
                                  struct EMmerge_info *edinfo;
                                  IGRint *numowners;
                                  struct EMSownercomp **ownercomps;
                                  GRobjid new_surf;

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
 IGRlong                    rc;


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
           senderid = new_surf,
           targetid = surfs[i]);
  EMomerr_hndlr (sts, ret_end, "GRconnector.GRdisconn"); 

  if(ownercomps)
  {
   IGRboolean list_extended=TRUE;
   EMmkownlist ( msg, ownercomps, compid,index, surfs[i], FALSE,
                 &list_extended );
   EMomerr_hndlr (sts, ret_end, "EMmkownlist"); 

   if (list_extended && numowners)
   (*numowners)++;
  }

 }

 /* Disconnect the common edges  */

  for ( i=0; i<num_edinfo; i++)
  {
   if((edinfo[i].edge0 !=NULL_OBJID) && (edinfo[i].edge1 !=NULL_OBJID))
   {
     sts = om$send ( msg = message Root.disconnect ( to_comm_edge, 
                     edinfo[i].edge1, OM_Gw_current_OS, to_comm_edge),
              senderid = new_surf,
              targetid = edinfo[i].edge0);
     EMomerr_hndlr (sts, ret_end, "Root.disconnect"); 
  }
 }
                    
 /* Stitch my common edges */
  for (i=0; i<num_edinfo; i++)
  {
   if ((edinfo[i].edge1 != NULL_OBJID) && (edinfo[i].new_edge !=NULL_OBJID))
   {

    /* Get the dominant properties before connecting */

    edprops=NULL; newed_props=NULL; commed_props=NULL;

    if(!is_composite_surface) index = i;

    is_composite_surface = TRUE;

    sts = om$send ( msg = message EMSedge.EMget_props ( msg,
                           &edprops),
             senderid = new_surf,
             targetid = edinfo[i].edge1);
    EMomerr_hndlr (sts, ret_end, "EMSedge.EMget_props"); 

    sts = om$send(msg = message EMSedge.EMconnect_edges( msg,
                        edprops, TRUE, edinfo[i].new_edge,
                        NULL_OBJID, NULL_OBJID, &md_env->md_env),
             senderid = new_surf,
             targetid = edinfo[i].edge1);
    
    EMomerr_hndlr (sts, ret_end, "EMSedge.EMconnect_edges"); 
 

    /* Maintain the dominant properties as before */

    sts = om$send(msg = message EMSedge.EMget_props(
                        msg, &newed_props),
             senderid = new_surf,
             targetid = edinfo[i].new_edge);
    EMomerr_hndlr (sts, ret_end, "EMSedge.EMget_props"); 

    sts = om$send(msg = message EMSedge.EMget_props(
                        msg, &commed_props),
             senderid = new_surf,
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
             senderid = new_surf,
             targetid = edinfo[i].new_edge);
    EMomerr_hndlr (sts, ret_end, "EMSedge.EMset_props"); 

    sts = om$send(msg = message EMSedge.EMset_props(
                        msg, commed_props, EMS_O_SET),
             senderid = new_surf,
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
           senderid = new_surf,
           targetid = edinfo[index].edge1);
  EMomerr_hndlr (sts, ret_end, "EMSedge.EMget_props"); 

  sts = om$send ( msg = message GRvg.GRgetsize ( msg,
                  &md_env->md_env.matrix_type, md_env->md_env.matrix,
                  &surf1_size),
           senderid = new_surf,
           targetid = edinfo[index].surf1);
  EMomerr_hndlr (sts, ret_end, "GRvg.GRgetsize"); 

  surface1 = (struct IGRbsp_surface *) om$malloc(size=surf1_size);

  sts = om$send ( msg = message EMSsurface.GRgetgeom( msg,
                  &md_env->md_env.matrix_type,
                  md_env->md_env.matrix, (IGRchar *) surface1),
           senderid = new_surf,
          targetid = edinfo[index].surf1);
  EMomerr_hndlr (sts, ret_end, "EMSsubbs.GRgetgeom"); 

  sts = om$send ( msg = message GRvg.GRgetsize ( msg,
                  &md_env->md_env.matrix_type, md_env->md_env.matrix,
                  &surf2_size),
           senderid = new_surf,
           targetid = new_surf);
  EMomerr_hndlr (sts, ret_end, "GRvg.GRgetsize"); 

  surface2 = (struct IGRbsp_surface *) om$malloc(size=surf2_size);

  sts = om$send ( msg = message EMSsurface.GRgetgeom( msg,
                  &md_env->md_env.matrix_type,
                  md_env->md_env.matrix, (IGRchar *) surface2),
           senderid = new_surf,
          targetid = new_surf);
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
                    senderid = new_surf,
                    targetid = new_surf);
    EMomerr_hndlr (sts, ret_end, "EMSsurface.EMrevorient"); 
   }
 
  if(surface1)
  {
   om$dealloc(ptr=surface1);
   surface1=NULL;
  }
  if(surface2)
  {
    om$dealloc(ptr=surface2);
    surface2=NULL;
  }
}
 /* Switch on my property bits */

  EFsetsfstate ( msg, new_surf, OM_Gw_current_OS, EMS_O_ON);

ret_end:
 return (sts);

}

end implementation EMSsubbs;
 

 
 
