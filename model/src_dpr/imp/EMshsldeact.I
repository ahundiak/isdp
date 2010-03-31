class implementation EMSshslbool;

/*

??/??/??: creation.
06/01/93: sampath : added code to undo based on the offset direction.
30Jun'93: sudhakar: get appropriate 'compositeid' from the SSI info as
                    the solid id.
09/07/93: sampath : Made changes to delete only first two components for
                    symmetric undo. This process is needed because the
                    orginal solid is connected at third location.
09/29/93: Sudhakar: Modified to handle 'Pre- EMS 2.4' models.
*/
#include "OMmacros.h"
#include "EMSopt.h"
#include "REshsolid.h"
#include "gr.h"
#include "grmacros.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"

method EMdeactivate (IGRlong *msg; IGRshort *option; struct GRmd_env *env;
                     GRobjid **display_ids; IGRint *display_count)
{
  IGRboolean delete, is_symmetric;
  IGRlong stat_OM, msg_loc;
  enum GRdpmode dpmode;
  OM_S_CHANSELECT chan_to_comps;
  union EMSssi_table *org_ssi=NULL;
  GRobjid org_solid=0;
  IGRint off_dir;
  IGRint size;
  struct EMSshell_solid *ashell;
  OM_S_CHANSELECT chan_to_connector;
  OMuint          count,numsf1;
  OM_S_OBJECT_LINKAGE  *owner_comps=NULL;
  IGRboolean aflag = 0;
  struct GRmd_env  display_env;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /* get offset direction from recompute info */

  ashell = NULL;
  stat_OM = om$send (msg = message EMSassoc.EMget_info (&msg_loc, NULL,
               	NULL, (IGRuint *) &size,(IGRchar **) &ashell),
		targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if(size)
  {
    if(ashell->inward)
	off_dir = 1;
    else 
	off_dir = 2;
    is_symmetric = ashell->is_symmetric;
  }
  else
  {
    /* 'Pre-EMS 2.4' Models */
    off_dir = 1;  /* Only inward offset was allowed earlier */
    is_symmetric = FALSE;
  }

  /* get orginal solid id from ssi */

  if(is_symmetric)
  {
	off_dir = 0;
  	stat_OM = om$send(msg = message EMSdpr.EMgetSSI(&msg_loc, &org_ssi),
                          targetid = my_id);
  	EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

   	org_solid = 
        org_ssi->bool_info.composite_ids[org_ssi->bool_info.num_composites - 1];

	if(org_ssi)
		om$dealloc(ptr = org_ssi);
  }

  if(ashell) om$dealloc(ptr = ashell);

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  stat_OM = om$send (mode = OM_e_wrt_message,
             msg = message EMSsfboolean.EMdeactivate (&msg_loc, option, env,
             display_ids, display_count), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  delete = ! (*option & EMS_UNDO_DONTDELME || *option & EMS_UNDO_SAVE);

  /* delete the components according to the direction of offset */


  gr$get_module_env(buffer = &display_env);
  aflag = pwIsActivationOn();

  if (*option & EMS_DO_DISPLAY || delete)
    switch(off_dir)
    {

    case 0: /* symmetric */
	count = 1;
        EMmake_chanselect (GRconnector_to_owners, &chan_to_connector);
        while(count) 
        {
                om$get_channel_count (objid = org_solid,
                        p_chanselect = &chan_to_connector,
                        count = &count);
                if(count)
                {
                owner_comps = (OM_S_OBJECT_LINKAGE *) om$malloc
                        (size = count * (sizeof (OM_S_OBJECT_LINKAGE)));
                om$get_channel_objects (objid = org_solid,
                        p_chanselect = &chan_to_connector,
                        count = &numsf1, size = count,
                        list = owner_comps);
		org_solid = owner_comps->S_objid;
                om$dealloc(ptr = owner_comps);
		}
	}
     
      dpmode = GRbe;
      om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                                 aflag?&display_env.md_env.matrix_type:
                                       &env->md_env.matrix_type,
                                 aflag?display_env.md_env.matrix:
                                       env->md_env.matrix,
                                 &dpmode,
                                 aflag?&display_env.md_id:
                                       &env->md_id),
                                 p_chanselect = &chan_to_comps, 
                                 from = 1, to = 0);

     if (delete)
      om$send (msg = message GRgraphics.GRdelete (&msg_loc, env),
                       p_chanselect = &chan_to_comps, from = 1, to = 0);
      dpmode = GRbd;
      
      om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                                 aflag?&display_env.md_env.matrix_type:
                                       &env->md_env.matrix_type,
                                 aflag?display_env.md_env.matrix:
                                       env->md_env.matrix,
                                 &dpmode,
                                 aflag?&display_env.md_id:
                                       &env->md_id), targetid = org_solid);
    break;

    case 1 : /* inward */

      dpmode = GRbe;
      om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                                 aflag?&display_env.md_env.matrix_type:
                                       &env->md_env.matrix_type,
                                 aflag?display_env.md_env.matrix:
                                       env->md_env.matrix,
                                 &dpmode,
                                 aflag?&display_env.md_id:
                                       &env->md_id),
                                 p_chanselect = &chan_to_comps,
                                 from = MAXINT, to = 1);

     if (delete)
      om$send (msg = message GRgraphics.GRdelete (&msg_loc, env),
                  p_chanselect = &chan_to_comps, from = MAXINT, to = 1);
    break;

    case 2 : /* outward */

     dpmode = GRbe;
     om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                                 aflag?&display_env.md_env.matrix_type:
                                       &env->md_env.matrix_type,
                                 aflag?display_env.md_env.matrix:
                                       env->md_env.matrix,
                                 &dpmode,
                                 aflag?&display_env.md_id:
                                       &env->md_id),
                                 p_chanselect = &chan_to_comps,
                                 from = 0, to = 0);

     if (delete)
      om$send (msg = message GRgraphics.GRdelete (&msg_loc, env),
                       p_chanselect = &chan_to_comps, from = 0, to = 0);




    break;
   }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSshslbool.EMdeactivate");
  return (stat_OM);
}

end implementation EMSshslbool;
