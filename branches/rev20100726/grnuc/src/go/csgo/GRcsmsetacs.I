/*
Method
        GRcsmgr.GRset_active_cs

Description
        This method:
            o  erases the old active CS
            o  changes the weight of old CS to 0
            o  displays the old CS with new weight
            o  disconnects the old CS from 'to_active' channel
            o  connects the new CS to 'to_active' channel
            o  sets the weight of the new CS to ACTIVE_CS_WEIGHT (3)
            o  change CS type if mode is on
            o  displays the new active CS

History
        10/15/86  Kumar Talluri  Design and Implementation.
        10/01/87  mrm            change channel usage, method name
        08/06/91  dhm            change cs type
        08/22/94  Vidya          Check to see if the incoming cs 
				 subclasses from NDnode and connect
			 	 to the root accordingly
*/

class implementation GRcsmgr;

#include "grimport.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

from GRvg       import  GRchgweight;
from GRgraphics import  GRdisplay;
from GRgencs    import  GRget_cs_info;
extern GRclassid OPP_NDnode_class_id;

method GRset_active_cs (IGRlong            *msg;
                        struct GRmd_env    *module_info; 
                        GRobjid             CSobjid)
{
    unsigned char       weight;         /* of coordinate system */
    IGRshort            matrix_type;    /* of module */
    IGRboolean          flags;          /* dpb flag */
    IGRshort            type;           /* CS type */
    IGRchar             type_string[MAX_CS_TYPE];     /* CS type as a string */
    IGRint              count;          /* from om$get_channel_objects */
    IGRlong             sts;            /* return code */
    GRobjid             new_active;     /* new active coordinate system */
    enum GRdpmode       mode;           /* to display with */
    IGRdouble           *matrix;         /* pointer to module matrix */
    struct GRid         mod_id;         /* of module */
    OM_S_CHANSELECT     to_active;      /* GRcsmgr.to_active channel */
    OM_S_CHANSELECT     to_components;  /* GRcmpowner.to_components channel */
    OM_S_CHANSELECT     to_csmgr;       /* GRgencs.to_csmgr channel */
    OM_S_OBJECT_LINKAGE object_link,*obj_link=NULL;    /* object linkage */
    OMuword classid;


    *msg = MSSUCC;
    sts = OM_S_SUCCESS;
    mod_id = module_info->md_id;
    matrix_type = module_info->md_env.matrix_type;
    matrix = (IGRdouble *) module_info->md_env.matrix;

    /*
     *  erase the old active cs
     */

    sts = om$make_chanselect (channame = "GRcsmgr.to_active",
                              p_chanselect = &to_active);
    if (!(sts & 1))
    {
        goto finish;
    }

    mode = GRbehe;
    sts = om$send (msg = message GRgraphics.GRdisplay
                        (msg, &matrix_type, matrix, &mode, &mod_id),
                   p_chanselect = &to_active);

    if (!(sts & *msg & 1))
    {
        goto finish;
    }

    /*
     *  change the weight of the old active cs
     */

    weight = 0;
    sts = om$send (msg = message GRvg.GRchgweight (msg, &weight),
                   p_chanselect = &to_active);

    if (!(sts & *msg & 1))
    {
        goto finish;
    }

    /*
     *  display the old active cs with 0 weight
     */

    mode = GRbd;
    sts = om$send (msg = message GRgraphics.GRdisplay
                        (msg, &matrix_type, matrix, &mode, &mod_id),
                   p_chanselect = &to_active);

    if (!(sts & *msg & 1))
    {
        goto finish;
    }

    /*
     *  disconnect the old active cs from the to_active channel
     */

    sts = om$send (msg = message Root.wild_disconnect (to_active),
                   targetid = my_id);

    if (!(sts & 1))
    {
        goto finish;
    }

    /*
     *  set up channel selector
     */

    sts = om$make_chanselect (channame = "GRgencs.to_csmgr",
                              p_chanselect = &to_csmgr);
    if (!(sts & 1))
    {
        goto finish;
    }

    /*
     *  if input cs objid is NULL_OBJID, make the base cs active
     */

    if (CSobjid == NULL_OBJID)
    {
        sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                                  p_chanselect = &to_components);

        if (!(sts & 1))
        {
            goto finish;
        }

        sts = om$get_channel_objects (objid = my_id,
                                      p_chanselect = &to_components,
                                      list = &object_link,
                                      size = 1,
                                      count = (OMuint *)&count);
        if (!(sts & 1) || !count)
        {
            goto finish;
        }

        new_active = object_link.S_objid;
    }
    else
    {
        new_active = CSobjid;
    }

#ifdef DEBUG
    printf ("GRcsmgr.GRset_active_cs: making %d active\n", new_active);
#endif

    /*
     *  connect the new cs to the to_active channel
     */

    sts = om$get_classid(objid = new_active,
                         osnum = mod_id.osnum, p_classid = &classid);
    if (! (1 & sts))  goto finish;

/* begin of fix for TR119416458 */
/* check to see if the incoming cs subclasses from NDnode
 * if so, to get the actual object which is connected to cs_mgr
 */
    sts = om$is_ancestry_valid(subclassid = classid,
                               superclassid = OPP_NDnode_class_id);
    if(sts == OM_S_SUCCESS)
      {
      IGRboolean cs_found;
      IGRint ii;
      
      sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                                  p_chanselect = &to_components);

        if (!(sts & 1))
        {
            goto finish;
        }

      sts = om$get_channel_count(objid = new_active,
			  osnum = mod_id.osnum,
			  p_chanselect = &to_components,
			  count = (OMuint *)&count);
      if(!(sts & 1) || !count) goto finish;

      obj_link = (OM_S_OBJECT_LINKAGE *)om$malloc(size = count *
			sizeof(OM_S_OBJECT_LINKAGE ));    /* object linkage */
      sts = om$get_channel_objects (objid = new_active,
                                      p_chanselect = &to_components,
                                      list = obj_link,
                                      size = count,
                                      count = (OMuint *)&count);
      if (!(sts & 1) || !count)
         goto finish;
      cs_found = FALSE;
      for(ii = 0 ; ii< count ; ii++)
        {
        sts = om$get_classid(objid = obj_link[ii].S_objid,
                         osnum = mod_id.osnum, p_classid = &classid);
        if (! (1 & sts))  goto finish;

        sts = om$is_ancestry_valid(subclassid = classid,
                               superclassid = OPP_GRgencs_class_id);
        if(sts == OM_S_SUCCESS)
          {
          cs_found = TRUE;
          new_active = obj_link[ii].S_objid;
          break;
          }
        }

	if(!cs_found) 
          goto finish;
      }
/* end of fix for TR#119416458 */

    sts = om$send (msg = message Root.connect
                        (to_csmgr, NULL,
                         my_id, OM_Gw_current_OS, to_active, NULL),
                   targetid = new_active,
                   targetos = mod_id.osnum);

    if (!(sts & 1))
    {
        goto finish;
    }

    /*
     *  set the weight of the new cs to the proper active cs weight
     */

    weight = ACTIVE_CS_WEIGHT;
    sts = om$send (msg = message GRvg.GRchgweight (msg, &weight),
                   targetid = new_active,
                   targetos = mod_id.osnum);

    if (!(sts & *msg & 1))
    {
        goto finish;
    }

    /*
     * If DPB_CHANGE_ACS_TYPE mode is on, then change the cs type in the dpb  
     * to be the new active coordinate system's type.
     */

    gr$get_change_acs_type(buffer = &flags);

    if (flags)
    {
        sts = om$send (msg = message GRgencs.GRget_cs_info(msg, NULL, NULL,
                             NULL, NULL, NULL, NULL, &type, NULL),
                       targetid = new_active,
                       targetos = mod_id.osnum);

        if (!(sts & *msg & 1))
        {
            goto finish;
        }

        if (type == RECTANGULAR)
          strcpy(type_string, Rectangular);
        else if (type == SPHERICAL)
          strcpy(type_string, Spherical);
        else if (type == CYLINDRICAL)
          strcpy(type_string, Cylindrical);

        gr$put_cs_type(buffer = type_string);
    }

    /*
     *  display the new active cs
     */

    mode = GRbd;
    sts = om$send (msg = message GRgraphics.GRdisplay 
                        (msg, &matrix_type, matrix, &mode, &mod_id),
                   targetid = new_active);
finish:
  if(obj_link)
  om$dealloc(ptr = obj_link);

    return (sts);
}

end implementation GRcsmgr;
