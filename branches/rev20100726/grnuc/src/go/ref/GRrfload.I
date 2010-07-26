/*

Name
  GRrfload.I

Description
  This file contains the method to load and unload the reference file
  attachment's file to and from memory.

Notes

*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "refdef.h"
#include "referr.h"
#include "exdef.h"
#include "exmacros.h"

/*
Name
  GRrfload

Abstract
  Loads the reference file attachment's file into memory.

Synopsis
  GRrfload(msg)

  long  *msg            O    Completion code

Description
  This method causes the reference file to be loaded into
  memory.

Return Value
  The possible return code values in the msg field are:

  MSSUCC - successful completion
  MSFAIL - error occured

Notes

Index

Keywords
  method, reference-file

History
  08/04/93 : jhw : creation date

*/
method GRrfload (IGRlong * msg)
{
    IGRlong om_msg = OM_S_SUCCESS;
    
    *msg = MSSUCC;
    
    if (me->ref_properties & GRRF_UNLOADED)
    {
        struct GRid ref_id, ctx_id;
        IGRboolean  constr_flag = FALSE;
        IGRchar     logical[DI_PATH_MAX];
        GRspacenum  osnum;
        GRobjid     modid;

        ref_id.objid = my_id;
        ref_id.osnum = OM_Gw_current_OS;

        /*
         * If this file isn't already loaded ...
         */
        if (me->ref_properties & GRRF_UNLOADED)
        {
            om_msg = ex$get_modid(mod_id = &modid, 
                                  mod_osnum = OM_Gw_current_OS);

            if (!(om_msg & 1))
            {
                goto quit;
            }

            om_msg = GRname_reffile (msg, 
                                     NULL, /* KLUDGE: Go with default mount name. */
                                     me->filename, 
                                     &ref_id, 
                                     &constr_flag,
                                     logical);

            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
        
            /*
             * On GRrfload the unloaded properties bit must be cleared
             * before the GRrfinit since GRrfinit will check the bit
             * to determine whether to load it or not.
             */
            me->ref_properties &= ~GRRF_UNLOADED;

            om_msg = om$send (msg = message GRreffile.GRrfinit (msg, 
                                                                &constr_flag, 
                                                                logical,
                                                                &osnum, 
                                                                &modid, 
                                                                &ctx_id), 
                              targetid = my_id);

            if (!(om_msg & *msg & 1))
            {
                me->ref_properties |= GRRF_UNLOADED;
#ifdef DEBUG
                printf ("Error: GRreffile.GRrfload: GRrfinit failed\n");
#endif
            }
        }
    }
    
 quit:
    
    GR_NOTIFY_LISTENERS (msg, &om_msg, GR_ATTR_MODIFIED);

    return om_msg;
}

/*
Name
  GRrfunload

Abstract
  Unloads the reference file attachment's file from memory.

Synopsis
  GRrfunload(msg)

  long  *msg            O    Completion code

Description
  This method causes the reference file to be unloaded from
  memory.

Return Value
  The possible return code values in the msg field are:

  MSSUCC - successful completion
  MSFAIL - error occured

Notes

Index

Keywords
  method, reference-file

History
  08/04/93 : jhw : creation date

*/
method GRrfunload (IGRlong * msg)
{
    IGRlong     om_msg = OM_S_SUCCESS;
    IGRlong     type;
    GRspacenum  osnum;
    IGRboolean  writable = FALSE;
    
    om_msg = om$os_name_to_number (osname = me->osname,
                                   p_osnum = &osnum);
    
    if (!(om_msg & 1))
    {
        goto quit;
    }

    /*
     * Don't allow writable files to be unloaded. This isn't allowed
     * since it could cause the associative connections between the
     * master file and reference file to become out of sync and would
     * certainly confuse the users.
     */
    GRis_writable (msg, me->osname, 1, OM_Gw_current_OS);
    
    if (writable = (*msg == MSSUCC))
    {
        if (OM_GA_OSDs [osnum]->flags & OM_e_loados_ro)
        {
            writable = FALSE;
        }
    }
    
    if (!writable)
    {
        if (!(me->ref_properties & GRRF_UNLOADED))
        {
            type = 4; /* UNLOAD_FILE in GRrfclose. */

            om_msg = om$send (msg = message GRreffile.GRrfclose (msg, &type),
                              targetid = my_id);

            if (om_msg & *msg & 1)
            {
                me->ref_properties |= GRRF_UNLOADED;
            }

#ifdef DEBUG
            else
            {
                printf ("Error: GRreffile.GRrfunload: GRrfclose failed\n");
            }
#endif
        }
    }
    else
    {
        /*
         * Can't unload writable files at this time.
         */
        *msg = MSFAIL;
    }

    GR_NOTIFY_LISTENERS (msg, &om_msg, GR_ATTR_MODIFIED);
 
 quit:
    
    return om_msg;
}

end implementation GRreffile;

