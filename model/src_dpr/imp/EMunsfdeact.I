class implementation EMSsfunitesf;


/*

DESCRIPTION

    This method will deactivate me if I am an active state.  This is
    done by changing topology and/or geometry I have saved with what
    is currently active.

Algorithm
    Get the SSI table.
    Put in out_surfaces at composite_index.
    Set properties in the surfaces ON.
    Disconnect the new plane edges
    Connect the disconnected  old edges. 
    If option==EMS_UNDO_SAVE set my active bit OFF else delete
    myself.

Returned values
    EMS_S_SUCCESS if all is well.


HISTORY

    07/10/92  :  AMD  :  Creation
    07/07/93  : Jack  :  Replaced call to EMstitch with EMconnect_edges.
                         The extra work that EMstitch does to connect
                         the pair of common edges is unnecessary in this
                         case.  Also, removed several unused imports.

    22 Nov 93 : AIC   :  Test for reversibility during EMconnect_edges.
    21 Dec 93 : WBC   :  Made some changes to avoid failing when the SSI
                         is not entirely correct.

    02/26/97  : Nilesh : Send the message EMconnect_edges on the correct target
                         id, i.e on the edges_disconnected instead of sending
                         it on the edges_removed.

    08/14/97  : Nilesh : Added the code for handling the undo state of 
                         Tangetntially United Surfaces. 
    01/07/98  : Kiran  : Modified code to avoid undo failure for TR#.. Sorry
                         dont remember.
*/


#include "EMS.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "EMSlmdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "prototypes/bsdistptpt.h"

/* DPR_DISPLAY_BUFF_INCR */
#include "emsdef.h"

#define BUFF_INCR DPR_DISPLAY_BUFF_INCR

from EMSedge import EMgetsurface_info,
                    EMconnect_edges,EMendpts;
from EMSloop import EMget_props;
                    

method EMdeactivate (
    IGRlong *EMmsg;
    IGRshort *option;
    struct GRmd_env *env;
    GRobjid **display_ids; 
    IGRint *display_count
)
{
  IGRlong                       sts,bsrc;
  IGRint                        i,ii,j, *owner_index;
  GRobjid                       *sf_out;
  union EMSssi_table            *ssi;
  struct EMSunssi_table         *my_info;
  struct GRid                   owner_GRid;
  OM_S_CHANSELECT               to_loopset,to_comps, to_common_edge;
  OM_S_CHANSELECT               to_owner,to_component;
  OM_S_OBJECT_LINKAGE           parent_loop;
  OMuint                        count,chan_index;
  GRobjid                       parent_loopid;
  IGRboolean                    delete;
  IGRboolean                    display,found;
  IGRint                        num_edges,my_index,vla_size;   
  IGRshort                      os; 
  IGRushort                     loop_props;
  GRobjid                       new_plane;
  struct GRid                   my_GRid;
  GRspacenum                    dumosnum;
  IGRdouble                     *first_uv1=NULL,*first_uv2=NULL; 
  IGRdouble                     *last_uv1=NULL,*last_uv2=NULL; 
  IGRdouble                     xyztol,sqtol,dist1,dist2;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  ssi = NULL;
  xyztol = 0.0;
  sqtol  = 0.0;

  os = OM_Gw_current_OS;
  found = FALSE;

  delete = (*option&EMS_UNDO_SAVE) ? FALSE : TRUE;

  display = *option & EMS_DO_DISPLAY;
  owner_GRid.objid = my_id;
  owner_GRid.osnum = OM_Gw_current_OS;

  
  first_uv1 = (IGRdouble *)alloca(sizeof(IGRpoint));
  last_uv1 = (IGRdouble *)alloca(sizeof(IGRpoint));
  first_uv2 = (IGRdouble *)alloca(sizeof(IGRpoint));
  last_uv2 = (IGRdouble *)alloca(sizeof(IGRpoint));

  sts = om$make_chanselect(channame="EMSsubbs.to_loopset",
                           p_chanselect=&to_loopset);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  sts = om$make_chanselect(chanaddr=&ME.GRcmpowner->to_components,
                           p_chanselect=&to_comps);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  /* Get the constructed plane */

  sts = om$get_objid_at_index (objid = my_id,
                               p_chanselect = &to_comps,
                               index = 1,
                               objidaddr = &new_plane,
                               osnumaddr = &dumosnum);
  EMomerr_hndlr (sts, wrapup, "om$get_objid_at_index");  

  /* Send a message to myself to get the SSI table.-DLB */

  sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  


  my_info = &ssi->un_info;

  if (*option & EMS_DO_DISPLAY)
  {
   IGRint      inx;          /*DECLARE*/
   enum GRdpmode display_mode = GRbehe;
   IGRboolean  got_it = FALSE;    


   /* Has the added surface already been erased? */
   for (inx=0; inx<*display_count; inx++)
   {
     if ( (*display_ids)[inx] == new_plane )
     {
       got_it = TRUE;
       break;
     }
   }

   if (!got_it)
   {
     /**Erase the modified surface and store it**/

     sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
                         &env->md_env.matrix_type, 
                         env->md_env.matrix, &display_mode,
                         &env->md_id),
              targetid = new_plane);
     EMomerr_hndlr (sts, wrapup, "GRgraphics.GRdisplay"); 

     /**Store modified id**/
     EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                         DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
     if (!(1 & *EMmsg)) goto wrapup;

     (*display_ids)[*display_count] = new_plane;
     (*display_count)++;
   }
  }


  /*Put in the 'out_surfaces' and make them locatable and displayable.
   * NOTE:
   *       DUE TO THE FACT THAT THE SURFACES MUST BE CONNECTED AT THE 
   *       PROPER OWNERS INDEX, CARE MUST BE EXERCISED WHEN RECONNECTING
   *       THE SURFACES.  NAMELY, SINCE THE OWNERS CHANNEL IS A RELATIVELY
   *       ORDERED CHANNEL, THE SURFACES MUST BE CONNECTED IN THE REVERSE
   *       ORDER THAT THEY WERE REMOVED.  THIS REQUIRES THAT THE ARRAY OF
   *       SURFACE OUT IDS BE TRAVERSED FROM END TO BEGINNING. 
   */


  /* Find the total number of surfs removed */

  j = 0;

  for (i = 0; i < my_info->num_composites; i ++)
    j += my_info->num_surfaces_out[i];

  sf_out = &my_info->surface_out_ids[j-1];
  owner_index = &my_info->composite_indices[j-1];

  for(i=my_info->num_composites-1; i>=0; i--)
   {
     owner_GRid.objid = my_info->composite_ids[i];     

     for(j=my_info->num_surfaces_out[i]-1; j>=0; j--)
      {
        /*Reconnect removed surfaces at proper owners index.*/

        sts = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                            &owner_GRid, (IGRlong *) owner_index),
                      targetid = *sf_out);
        /* EMerr_hndlr(!(1&sts&*EMmsg),*EMmsg,EMS_E_Fail,wrapup); */

        EFsetsfstate(EMmsg, *sf_out, OM_Gw_current_OS, EMS_O_ON);
        /* EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_Fail,wrapup); */

        sts = EFfix_parent_child_relationship(EMmsg, *sf_out, 
                                              owner_GRid.objid, 
                                              OM_Gw_current_OS, FALSE, NULL);
        /* if (!(1 & sts & *EMmsg)) goto wrapup; */

        if (display)
        {
          /*Store the out ids in the array.*/
         
          EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                              BUFF_INCR, sizeof(GRobjid));
          if (!(1 & *EMmsg)) goto wrapup;

          (*display_ids)[*display_count] = *sf_out;
          (*display_count)++;
        }

        owner_index--;
        sf_out--;
      }
   }

 /* Disconnect all the old common edges */

 EMmake_chanselect( EMSedge_to_common_edge, &to_common_edge);

 num_edges = my_info->num_edges;
 
 for (i=0; i<num_edges; i++)
  {
   if(my_info->edges_disconnected[i] != NULL_OBJID)
   {
    sts = om$send ( msg = message Root.disconnect( to_common_edge,
                    my_info->edges_added[i], OM_Gw_current_OS, 
                    to_common_edge),
             targetid = my_info->edges_disconnected[i]);

    /* EMomerr_hndlr (sts, wrapup, "Root.disconnect"); */
   }

  }   

 /* Stitch the new plane edges */

  for (i=0; i<num_edges; i++)
  {
   if (my_info->edges_disconnected[i] != NULL_OBJID)
    {
      if(my_info->edges_removed[i] != NULL_OBJID)
      {
        GRobjid srfid0,
                srfid1;

     sts = om$send ( msg = message EMSedge.EMgetsurface_info
                 ( EMmsg, &srfid0, NULL),
            targetid = my_info->edges_removed[i]);
     EMomerr_hndlr (sts, wrapup, "EMSedge.EMgetsurface_info");

     sts = om$send ( msg = message EMSedge.EMgetsurface_info
                 ( EMmsg, &srfid1, NULL),
            targetid = my_info->edges_disconnected[i]);
     EMomerr_hndlr (sts, wrapup, "EMSedge.EMgetsurface_info");

        sts = om$send(msg = message EMSedge.EMconnect_edges(EMmsg,
                            0,
                            TRUE,
                            my_info->edges_disconnected[i],
                            srfid0,
                            srfid1,
                            &env->md_env),
                            targetid = my_info->edges_removed[i] );

     EMomerr_hndlr (sts, wrapup, "EMSedge.EMconnect_edges"); 
     }
     else
     {
      /** The Merged edge has been found, disconnect it and connect back the
          pair of common edges which were previously  disconnected. **/

     chan_index=0;
   
     EMmake_chanselect (EMSedge_to_owner, &to_owner);
     EMmake_chanselect (EMSbd_owner_to_comps, &to_component);
    
     sts = om$get_channel_objects(
           objid = my_info->edges_disconnected[i],
           p_chanselect = &to_owner,
           list = &parent_loop,
           size = 1 ,
           count = &count);

      parent_loopid = parent_loop.S_objid;

    /** Get the index of the Merged Edge on the surface loopset **/

   sts = om$get_index(osnum_c = OM_Gw_current_OS,
                      objid_c = parent_loopid,
                      p_chanselect = &to_component,
                      objid = my_info->edges_disconnected[i],
                      indexaddr = &chan_index);

    /** Disconnect and Delete the Merged Edge  **/

     sts = om$send(msg = message Root.disconnect(to_owner,parent_loopid,os,
                                               to_component),
                                   senderid = NULL_OBJID,
                                   targetid = my_info->edges_disconnected[i],
                                   targetos = OM_Gw_current_OS);

    /** Connect the merg edges(two) at the Correct Index **/

   /** Now we have the same disconnected edge twice in the EMSdpr->ids array,
       first time as part of ssi info and second as part of the sorted array
       of merge_ids.  Scan the list from the bottom to avoid hitting the same
       id in the top which would be disastrous  **/

   vla_size=0;

   vla_size = om$dimension_of(varray=ME.EMSdpr->ids);

   /** Scan from the bottom **/

   for(ii=vla_size;ii>0;ii--)
   {
     if(my_info->edges_disconnected[i] == ME.EMSdpr->ids[ii])
     {
       found = TRUE;
       break;
     }
   }

  /** While connecting if the chan_index==0, there are two possibilites for
      connecting. This shows the edge position before merging.
      1] O    O   O   O
         E1   E2  E3  E4
         If E1 and E2 were merged, then connecting at chan_index(==0) and 1
         would be correct. But if the edges which went for merging were E1
         and E4 then connecting back at 0,1 would be wrong instead they 
         should be connected at 0,3. **/

   for(my_index=0;my_index<2;my_index++)
   {
    sts=om$send(msg = message Root.connect(to_owner,chan_index,parent_loopid,os,
                                         to_component,chan_index),
                                   senderid = NULL_OBJID,
                                   targetid = ME.EMSdpr->ids[ii+1],
                                   targetos = OM_Gw_current_OS);

    if(chan_index == 0)
    {
      sts = om$send(msg = message EMSedge.EMendpts(EMmsg,
                          first_uv1, first_uv2,
                          NULL, NULL, NULL),
                          targetid = ME.EMSdpr->ids[ii+1]);
     
      sts = om$send(msg = message EMSedge.EMendpts(EMmsg,
                          last_uv1, last_uv2,
                          NULL, NULL, NULL),
                          targetid = ME.EMSdpr->ids[ii+2]);
   
      sts = om$send(msg = message EMSloop.EMget_props(EMmsg,&loop_props),
                                         targetid = parent_loopid);

      BSEXTRACTPAR(&bsrc,BSTOLCHRDHT,xyztol);
      sqtol=(xyztol)*(xyztol);
      dist1=0.0;
      dist2=0.0;

   /** Since the distance is in uv space, Initialize the z coordinate to 0 **/
      
      first_uv1[2] = 0.0;
      first_uv2[2] = 0.0;
      last_uv1[2]  = 0.0;
      last_uv2[2]  = 0.0;

      if(loop_props & EMLP_REVERSED)
      {
        dist1 = BSdistptpt(&bsrc,first_uv1,last_uv2);
        if(bsrc!=BSSUCC) goto wrapup;
        if(dist1 < sqtol)
        {
          chan_index++;
        }
        else
        {
          chan_index=OM_K_MAXINT;
        }
        
      }
      else
      {
        dist2 = BSdistptpt(&bsrc,first_uv2,last_uv1);
        if(bsrc!=BSSUCC) goto wrapup;
        if(dist2 < sqtol)
        {
          chan_index++;
        }
        else
        {
          chan_index=OM_K_MAXINT;
        }

      }
    }
    else
    {
      chan_index++;
    }
    ii++;
  }

     sts = om$send (mode = OM_e_wrt_message,
                    msg = message Root.delete(1),
                    targetid = my_info->edges_disconnected[i]);

     }
   }
 }   

/*
 * if the option is EMS_UNDO_SAVE, make myself inactive and 
 * make the  new_plane  unlocatable and undisplayable.
 * Otherwise, delete myself and new_plane;
 */

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 if (delete)
 {
  sts = om$send (msg = message GRgraphics.GRdelete( EMmsg, 
                 env), targetid = new_plane);
  EMomerr_hndlr (sts, wrapup, ""); 

  /*
   * disconnect my components from me before deleting.
   * This is done to turn off the necessary property bits
   * of the components.
   */

  if (*option & EMS_DELETE_DPR)
  {
   sts = om$send (msg = message GRconnector.GRdisconn (
                  EMmsg, &my_GRid),
            p_chanselect = &to_comps);
   EMomerr_hndlr (sts, wrapup, "GRconnector.GRdisconn"); 

   sts = om$send (mode = OM_e_wrt_message,
                  msg = message Root.delete(1),
            targetid = my_id);
   EMomerr_hndlr (sts, wrapup, "Root.delete"); 
  }

 } /* if (delete) */
 else
 {
  /*
   * set my properties ( GRIS_LOCATABLE and GRIS_DISPLAYABLE)
   * to false
   */

  ME.GRgraphics->properties &= ~GRIS_LOCATABLE;
  ME.GRgraphics->properties &= ~GRIS_DISPLAYABLE;

  /*
   * change the properties (GRIS_DISPLAYBLE and
   * GRIS_LOCATABLE) of 
   * to FALSE
   */

  EFsetsfstate(EMmsg, new_plane, OM_Gw_current_OS,
               EMS_O_OFF);
  EMomerr_hndlr (sts, wrapup, "EFsetsfstate"); 

 } /* else for if (delete) */


wrapup:

// if (ssi) om$dealloc(ptr = ssi);

 EMWRAPUP(*EMmsg,sts,"In EMSsfunitesf.EMdeactivate")

 return(sts);
}

end implementation EMSsfunitesf;
