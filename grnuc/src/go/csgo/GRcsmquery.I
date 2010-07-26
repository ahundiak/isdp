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
        GRcsmgr.GRget_query_info

Description
        This method accepts a coordinate system type and returns information
        necessary for user input in the specified type, i.e. the number of
        user inputs required and a pointer to an array of input information
        structures.  Each input information structure has a prompt, its
        corresponding input mask, and a default value.  This input information
        is stored at the individual coordinate system class level (e.g.
        GRgencs).  If a coordinate system id is specified, the information is
        obtained from it; otherwise the active cs is used.

Synopsis
        IGRlong *msg            O   MSSUCC if successful
        IGRchar *csname         I   name of the coord sys (NULL => use active)
        IGRchar *cstype         I   type of coord sys. ex: rect,sph,cyl
        IGRshort *num_inputs    O   number of input values required by the user
        struct GRcsquery_info **query_info  O   ptr to query information 
        struct GRid *csobj      O   object queried for information

History
        Kumar Talluri   10/05/86    design date
*/

class implementation GRcsmgr;

#include "grimport.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMerrordef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

from GRcoords import GRget_query_info;

method GRget_query_info (IGRlong                *msg;
                         IGRchar                *csname;
                         IGRchar                *cstype;
                         IGRshort               *num_inputs;
                         struct GRcsquery_info **query_info;
                         struct GRid            *csobj)
{
    IGRlong             sts;            /* return code */
    IGRint              count;          /* # objects returned from to_active */
    IGRlong             size;           /* for dpb query */
    struct GRmd_env     module_info;    /* from dpb */
    OM_S_CHANSELECT     to_active;      /* channel to active coordinate sys */
    OM_S_CHANSELECT     to_components;  /* channel to all coordinate systems */
    OM_S_OBJECT_LINKAGE object_link;    /* object linkage */

    /*
     *  if csname is specified
     *      get its objid
     *  else
     *      if there is an active CS
     *          get its objid
     *      else
     *          make the base CS active and get its objid
     *  send GRget_query_info to the object
     */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_components);
    if (!(sts & 1))
    {
        goto finish;
    }

    if (csname)
    {
        /*
         *  get the id of specified coordinate system
         */

        sts = di$translate (objname = csname,
                            p_objid = &csobj->objid,
                            p_osnum = &csobj->osnum);
        if (!(sts & 1))
        {
            *msg = MSFAIL;
            goto finish;
        }
    }
    else
    {
        /*
         *  get the active cs id
         */

        sts = om$make_chanselect (channame = "GRcsmgr.to_active",
                                  p_chanselect = &to_active);
        if (!(sts & 1))
        {
            goto finish;
        }

        sts = om$get_channel_objects (objid = my_id,
                                      p_chanselect = &to_active,
                                      list = &object_link,
                                      size = 1,
                                      count = (OMuint *)&count);
        if (!(sts & 1))
        {
            goto finish;
        }

        if (count)
        {
            csobj->objid = object_link.S_objid;
            csobj->osnum = object_link.osnum;
        }
        else
        {
            /*
             *  nothing on active channel; make BASEcoordsys active;
             *  the base should be at index 0 on the to_components channel
             */

            sts = om$get_channel_objects (objid = my_id,
                                          p_chanselect = &to_components,
                                          list = &object_link,
                                          size = 1,
                                          count = (OMuint *) &count);
            if (!(sts & 1) || !count)
            {
                goto finish;
            }

            csobj->objid = object_link.S_objid;
            csobj->osnum = object_link.osnum;

            size = sizeof (module_info);

            sts = gr$get_module_env (msg = msg,
                                     sizbuf = &size, 
                                     buffer = &module_info,
                                     nret = &size);

            sts = om$send (msg = message GRcsmgr.GRset_active_cs
                                (msg, &module_info, csobj->objid),
                           targetid = my_id);

            if (!(*msg & sts & 1))
            {
                goto finish;
            }     
        }
    }

    sts = om$send (msg = message GRcoords.GRget_query_info
                        (msg, cstype, num_inputs, query_info),
                   targetid = csobj->objid,
                   targetos = csobj->osnum);
finish:

    return (sts);
}
end implementation GRcsmgr;
