/* ###################   APOGEE COMPILED   ################## */
class implementation EMSmassprop;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
# include "msdef.h" /* MS message codes */
# include "ma.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "gocmacros.h"
# include "godef.h"

/*

 History     

        gupta     08/03/89      Creation Date

*/

method EMintcopy (IGRlong          *EMmsg; 
                  struct GRmd_env  *obj_mdenv;
                  struct GRmd_env  *new_mdenv; 
                  GRobjid          *newobjid;
                  struct EMcp_info *copy_info)

{
  IGRlong               stat_OM, msg, i;
  IGRint                chan_index;
  OMuint		child_count, count;
  IGRshort              props;
  IGRboolean            clear_bits, my_copy_exists;
  extern void           EMcpsearch();
  struct GRid           my_copy_GRid;
  GRobjid               child_id, my_owners_copy;
  OM_S_CHANSELECT       to_comps, to_object, notify_chan;
  OM_S_OBJECT_LINKAGE   *child_list, owner_list;

  /*********************************************************************/

  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  child_list = NULL;

  /* find out if I have been already copied or not. If so, return my
     counter part's objid and I am all done */
        
  EMcpsearch (&msg, my_id, newobjid, copy_info, 0, &my_copy_exists);
  EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

  if (my_copy_exists) goto wrapup;

  stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  stat_OM = om$make_chanselect (channame = "EMSmassprop.to_object",
                                p_chanselect = &to_object);
  stat_OM = om$make_chanselect (channame = "GRnotify.notification",
                                p_chanselect = &notify_chan);
  if (! (1 & stat_OM)) goto wrapup;

  /* copy  myself */
        
  stat_OM = om$construct_and_copy(object = me,
                                  osnum = new_mdenv->md_id.osnum,
                                  p_objid = newobjid);
  EMerr_hndlr (! (1 & stat_OM), *EMmsg, MSFAIL, wrapup);

  /* clear GR_RIGID_RELATIONSHIP bit */

  clear_bits = 0;
  props = GR_RIGID_RELATIONSHIP;

  stat_OM = om$send(msg = message GRvg.GRchgprops (&msg, &clear_bits,
                          &props),
       	            targetid = *newobjid,
                    targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, MSFAIL, wrapup);

  stat_OM = om$get_channel_objects (object = me,
                                    p_chanselect = &to_object,
                                    list = &owner_list,
                                    size = 1,
                                    count = &count);
  if (! (1 & stat_OM)) goto wrapup;

  EMcpsearch (&msg, owner_list.S_objid, &my_owners_copy, copy_info, 0,
              &my_copy_exists);
  EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

  if (my_copy_exists)
   {
    chan_index = GRDGNLIMITS_MAX_I;

    stat_OM = om$send(msg = message Root.connect(to_object, chan_index,
                            my_owners_copy, new_mdenv->md_id.osnum,
                            notify_chan, 0),
                      targetid = *newobjid,
                      targetos = new_mdenv->md_id.osnum);
    EMerr_hndlr (! (1 & stat_OM), *EMmsg, EMS_E_Fail, wrapup);
   }

  /* put my_id and my counter part's id in the copy_info */

  EMcpsearch (&msg, my_id, newobjid, copy_info, 3, &my_copy_exists);
  EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

  /* If I have any children then copy and connect them to my copy */

  stat_OM = om$get_channel_count(object = me,
                                 p_chanselect = &to_comps,
                                 count = &count);
  if (! (1 & stat_OM) || (! count)) goto wrapup;

  child_list = (OM_S_OBJECT_LINKAGE *) om$malloc(size =
                            count * (sizeof (OM_S_OBJECT_LINKAGE)));
  EMerr_hndlr (! child_list, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  stat_OM = om$get_channel_objects (object = me,
                                    p_chanselect = &to_comps,
                                    list = child_list,
                                    size = count,
                                    count = &child_count);
  if (! (1 & stat_OM)) goto wrapup;

  my_copy_GRid.objid = *newobjid;
  my_copy_GRid.osnum = new_mdenv->md_id.osnum;

  if (child_count)
   {
    for (i=0; i<count; i++)
     {
      stat_OM = om$send(msg = message GRgraphics.GRcopy (&msg, obj_mdenv,
                              new_mdenv, &child_id),
                        targetid = child_list[i].S_objid,
                        targetos = child_list[i].osnum);
      EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, MSFAIL, wrapup);

      stat_OM = om$send(msg = message GRconnector.GRrigidconn (&msg,
                              &my_copy_GRid, &i),
                        targetid = child_id,
                        targetos = new_mdenv->md_id.osnum);
      EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, MSFAIL, wrapup);

      EMcpsearch (&msg, child_list[i].S_objid, &child_id, copy_info, 3,
                  &my_copy_exists);
      EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
     }
   }

  wrapup:
   EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMintcopy");
   if (child_list) om$dealloc (ptr = child_list);
   return (stat_OM);
}

end implementation EMSmassprop;
