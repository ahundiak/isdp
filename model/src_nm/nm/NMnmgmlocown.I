class implementation NMnonmanigm;

#include "msdef.h"         /* MSSUCC               */
#include "EMSlcdef.h"      /* LC_...               */
#include "stdio.h"

method GRlocate_owner(IGRlong *EMmsg; struct GRlc_cvl *cvl;
                      struct GRlc_path *path; IGRint *path_position)
{
  IGRlong          sts=OM_S_SUCCESS;
  unsigned long loc_props;
            
  *EMmsg = MSSUCC;

  loc_props = cvl->attributes.obj_attr.owner_action;

  if ( (loc_props & LC_INTERMIDIATE) || 
       (ME.NMnonmanigm->nmprops & NMgm_Active) )
  {
    sts = om$send(msg = message GRowner.GRlocate_owner(EMmsg, cvl, path,
          path_position), mode = OM_e_wrt_message, targetid = my_id);
  }
  else 
  {
    OMuint           count;
    OM_S_CHANSELECT  to_owners;

    EMmake_chanselect(GRconnector_to_owners, &to_owners);
    sts = om$get_channel_count(object = me,
          p_chanselect = &to_owners, count = &count);
    if (count)
     sts = om$send(msg = OPPmargs, p_chanselect = &to_owners, from = 0,
	    to = 0);
    else
    {
      ME.NMnonmanigm->nmprops |= NMgm_Active;
      fprintf(stderr,
       "NMnonmanigm %d has incorrect active state bit(Corrected).\n",my_id);
      fprintf(stderr,"Model may be corrupt.\n");
      sts = om$send(msg = message GRowner.GRlocate_owner(EMmsg, cvl, path,
            path_position), mode = OM_e_wrt_message, targetid = my_id);
    }
  }

 EMWRAPUP(*EMmsg, sts, "NMnonmanigm.GRlocate_owner");
 return(sts);
}

end implementation NMnonmanigm;
