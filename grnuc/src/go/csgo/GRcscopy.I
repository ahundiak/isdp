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
        GRgencs.GRcopy

Description
        This method is overridden to produce a copy of the coordinate
        system which is connected to the coordinate system manager and is
        nameless.

History
        kt      11/26/86    design and implementation
        mrm     01/30/87    connect the copies to the cs manager
                03/14/88    rewrite, make copies nameless, use om$construct
                04/27/88    yank om$construct, use GRgraphics.GRcopy and
                            then connect to manager
*/

class implementation GRgencs;

#include "grimport.h"
#include "msdef.h"
#include "csdef.h"
#include "exmacros.h"
#include "gocmacros.h"

method GRcopy (IGRlong         *msg;
               struct GRmd_env *current_mod;
               struct GRmd_env *target_mod;
               GRobjid         *newobjid)
{
    unsigned char       weight;         /* weight to make copy */
    IGRlong             flex_flag;      /* connect with override */
    OM_S_OBJID          new_mod_id;     /* target module id */
    IGRlong             sts;            /* return code */
    IGRlong             owners_index;   /* index to connect at */
    IGRlong             graphics_index; /* index to connect at */
    struct GRid         csmgr;          /* coordinate system manager */

    /*
     *  use the inherited method
     */

    sts = om$send (mode = OM_e_wrt_message,
                   msg = message GRgraphics.GRcopy
                        (msg, current_mod, target_mod, newobjid),
                   targetid = my_id);

    if (sts & *msg & 1)
    {
        /*
         *  get the csmgr's id
         */

        if (target_mod->md_id.objid == NULL_OBJID)
        {
            sts = ex$get_modid (mod_osnum = target_mod->md_id.osnum,
                                mod_id = &new_mod_id);
        }
        else
        {
            sts = OM_S_SUCCESS;
            new_mod_id = target_mod->md_id.objid;
        }

        if (sts & 1)
        {
            sts = ex$get_super (mod_id = new_mod_id,
                                mod_osnum = target_mod->md_id.osnum,
                                super_name = CoordSysMgr,
                                create = TRUE,
                                super_class = "GRcsmgr",
                                super_id = &csmgr.objid,
                                super_osnum = &csmgr.osnum);

            if (sts & 1)
            {
                /*
                 *  connect the copy to the cs manager
                 */

                flex_flag = 1;
                owners_index = graphics_index = OM_K_MAXINT;

                sts = om$send (msg = message GRconnector.GRflexconn
                                    (msg, &flex_flag, &csmgr,
                                     &owners_index, &graphics_index),
                               targetid = *newobjid,
                               targetos = target_mod->md_id.osnum);

                if ((sts & *msg & 1) &&
                    (me->display_attr.weight == ACTIVE_CS_WEIGHT))
                {
                    weight = 0;
                    sts = om$send (msg = message GRvg.GRchgweight
                                        (msg, &weight),
                                   targetid = *newobjid,
                                   targetos = target_mod->md_id.osnum);
                }
            }
        }
    }

#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("GRgencs.GRcopy failed\n");
    if (!(*msg & 1)) printf ("msg = 0x%x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    GR_NOTIFY_LISTENERS (msg, &sts, GR_COPIED);

    return (sts);
}
end implementation GRgencs;
