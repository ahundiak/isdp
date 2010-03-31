/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION
===========
        
    This method deletes all the FRTs of the surface.


NOTES
=====
    
    It gets the FRT objects, and sends these objects a message :
     "EMdelete" implemented at "EMSgradata".


ARGUMENTS
=========
    
    VARIABLE                MODE    DESCRIPTION
    --------                ----    -----------
    EMmsg                   Output  Method return status.
                                    1)EMS_S_Success if sucess.
                                    2)EMS_E_Fail if EMdelete on a FRT 
                                      object failed.
                                    3)EMS_E_OMError on OM errors.

HISTORY
=======
    
    SAM     20-Nov-87   Creation.

    AIC     06 January 88   Use Root.delete instead of EMdelete.
                            (EMdelete is no longer a message.)
    NP      26 August  92   Modified for ANSI compliance. Changed variable 
			    "chan_count" to type "IGRuint".
*/

class implementation EMSsubbs;

#include "EMS.h"
# ifndef gocmacros_include
# include "gocmacros.h"
# endif

# include "emsmacros.h"

# define OBJ_LINKS_BUFFER_SIZE 40

extern OMuword OPP_EMSgradata_class_id;

method EMssdelfrt(IGRlong *EMmsg)
{
  IGRlong               mthd_stat;
  IGRlong   		sts;
  IGRuint               chan_count;
  IGRint                i, list_size = OBJ_LINKS_BUFFER_SIZE;
  OM_S_OBJECT_LINKAGE   *obj_links,
                        obj_links_buffer[OBJ_LINKS_BUFFER_SIZE];
  OM_S_CHANSELECT       to_helpers;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  sts = EMmake_chanselect (EMSrequester_to_helpers, &to_helpers);
  if(! (1 & sts)) goto wrapup;
  sts = om$get_channel_count(p_chanselect = &to_helpers,
                             objid = my_id, count = &chan_count);
  if(! (1 & sts)) goto wrapup;

  /*
   * Get the channel linkages
   */
  if(chan_count > list_size)
  {
    list_size = chan_count;
    obj_links = (OM_S_OBJECT_LINKAGE *)
                malloc(list_size * sizeof(OM_S_OBJECT_LINKAGE));
    if(! obj_links) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
  }
  else obj_links = obj_links_buffer;
  sts = om$get_channel_objects(object = me, p_chanselect = &to_helpers,
                               list = obj_links, size = list_size,
                               count = &chan_count);
  if(! (1 & sts)) goto wrapup;

  /*
   * For each object: if it is a subclass of EMSgradata, delete it.
   */
  for(i = 0; i < chan_count; i++)
  {
    IGRboolean  delete = FALSE;
    OMuword     classid;

    sts = om$get_classid(objid = obj_links[i].S_objid,
                         p_classid = &classid);
    if(! (1 & sts)) goto wrapup;

    if(classid IS OPP_EMSgradata_class_id) delete = TRUE;
    else
    {
      if(1 & om$is_ancestry_valid(subclassid = classid,
                                  superclassid = OPP_EMSgradata_class_id))
      delete = TRUE;
    }

    if(delete)
    {
      sts = om$send(msg = message Root.delete(1),
                    p_chanselect = &to_helpers, from = i, to = i);
      if(! (1 & sts)) goto wrapup;
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMssdelfrt.I for surface");
  return(sts);
}

end implementation EMSsubbs;
