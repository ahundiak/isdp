/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              Intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*
Name
        GRcsmgr.GRget_acs_info

Description
        This method requests the name, the description, type and/or the id
        of the active coordinate system.

History
        mrm     08/05/87    creation
                05/04/89    make sure a cs is on the active channel
        dhm     08/06/91    added the argument, type
*/

class implementation GRcsmgr;

#include "grimport.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

from GRgencs import GRget_cs_info;

method GRget_acs_info (IGRlong        *msg;
                       IGRint          namebuf_size;
                       IGRchar        *name;
                       IGRint         *namebytes_ret;
                       IGRint          descbuf_size;
                       IGRchar        *desc;
                       IGRint         *descbytes_ret;
                       IGRshort       *type;
                       struct GRid    *id)
{
    IGRint              count;          /* number of objects */
    IGRlong             sts;            /* return code */
    struct GRmd_env     module_info;    /* from dpb */
    OM_S_CHANSELECT     to_active;      /* channel to the active coord sys */
    OM_S_CHANSELECT     to_components;  /* channel to all coordinate systems */
    OM_S_OBJECT_LINKAGE object_link;    /* object linkage */

    *msg = MSSUCC;

    sts = om$make_chanselect (channame = "GRcsmgr.to_active",
                              p_chanselect = &to_active);
    if (sts & 1)
    {
        /*
         *  make sure there is an active coordinate system
         */

        sts = om$get_channel_count (p_chanselect = &to_active,
                                    object = me,
                                    count = (OMuint *) &count);

        if (count < 1)
        {
            /*
             *  make the base cs active
             */

            sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                                      p_chanselect = &to_components);

            sts = om$get_channel_objects (objid = my_id,
                                          p_chanselect = &to_components,
                                          list = &object_link,
                                          size = 1,
                                          count = (OMuint *) &count);
            if (!(sts & 1) || !count)
            {
                *msg = MSFAIL;
                goto finish;
            }

            count = sizeof (module_info);

            sts = gr$get_module_env (msg = msg,
                                     sizbuf = &count, 
                                     buffer = &module_info,
                                     nret = &count);

            sts = om$send (msg = message GRcsmgr.GRset_active_cs
                                (msg, &module_info, object_link.S_objid),
                           targetid = my_id);

            if (!(*msg & sts & 1))
            {
                goto finish;
            }     
        }

        sts = om$send (msg = message GRgencs.GRget_cs_info
                            (msg, namebuf_size, name, namebytes_ret,
                             descbuf_size, desc, descbytes_ret, type, id),
                       p_chanselect = &to_active);
    }

finish:

    return (sts);
}
end implementation GRcsmgr;
