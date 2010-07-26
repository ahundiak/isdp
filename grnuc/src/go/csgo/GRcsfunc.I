/*
Name
        GRcsfunc

Description
        This files contains functions referenced by the macros defined
        in csmacros.h.

History
        mrm     03/04/88    creation
                10/12/88    added cs$get_scale, cs$set_scale
                07/24/89    added cs$cvt_to_lcl, cs$cvt_to_wld
        dhm     08/07/91    added type argument to get_acs_info
                08/12/91    added cs$change_type
*/

class implementation GRgencs;

#include "grimport.h"
#include "msdef.h"
#include "csdef.h"
#include "csmacros.h"
#include "exmacros.h"

from GRcsmgr import GRget_acs_info, GRset_active_cs;

IGRint GRcsget_mgr (msg, osnum, module, objid)

IGRlong     *msg;       /* return code */
GRspacenum   osnum;     /* space number of the desired manager */
GRobjid      module;    /* module of the desired manager */
GRobjid     *objid;     /* id of the desired manager */

{
    IGRlong     sts;        /* return code */
    GRobjid     mod;        /* module id */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS; 

    if (!module)
    {
        sts = ex$get_modid (mod_osnum = osnum, mod_id = &mod);
    }
    else
    {
        mod = module;
    }

    if (sts & 1)
    {
        /*
         *  get the coordinate system manager's id
         */

        sts = ex$get_super (mod_id = mod,
                            mod_osnum = osnum,
                            super_name = CoordSysMgr,
                            create = TRUE,
                            super_class = CoordSysMgrClass,
                            super_id = objid);
    }

    return (sts);
}

IGRint GRcsget_active_info (msg, osnum, module, csmgr,
                            namebuf_size, name, namebytes_ret,
                            descbuf_size, desc, descbytes_ret,
                            type, objid)

IGRlong    *msg;            /* return code */
GRspacenum  osnum;          /* in which to find the active cs */
GRobjid     module;         /* module id, if known */
GRobjid     csmgr;          /* coordinate system manager, if known */
IGRint      namebuf_size;   /* size of the input name buffer */
IGRchar    *name;           /* buffer in which to put name */
IGRint     *namebytes_ret;  /* size of name */
IGRint      descbuf_size;   /* size of the input description buffer */
IGRchar    *desc;           /* buffer in which to put name */
IGRint     *descbytes_ret;  /* size of description */
IGRshort   *type;           /* type of CS */
GRobjid    *objid;          /* objid of the active coordinate system */

{
    IGRlong     sts;        /* return code */
    GRobjid     csmanager;  /* coordinate system manager in the specified os */
    struct GRid active_cs;  /* active coordinate system id and os */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS; 
    active_cs.objid = NULL_OBJID;

    /*
     *  get the cs manager's id
     */

    if (csmgr)
    {
        csmanager = csmgr;
    }
    else
    {
        sts = cs$get_mgr (msg = msg,
                          osnum = osnum,
                          module = module,
                          csmgr = &csmanager);

        if (!(sts & *msg & 1)) goto finish;
    }

    /*
     *  get the desired info
     */

    sts = om$send (msg = message GRcsmgr.GRget_acs_info
                        (msg,  namebuf_size, name, namebytes_ret,
                         descbuf_size, desc, descbytes_ret, type, &active_cs),
                   senderid = NULL_OBJID,
                   targetid = csmanager,
                   targetos = osnum);

    if (objid)
    {
        *objid = active_cs.objid;
    }

finish:

    return (sts);
}


#argsused
IGRint GRcsmake_active (msg, objid, module, csmgr, display_old, display_new)

IGRlong            *msg;            /* return code */
GRobjid             objid;          /* to make active */
struct GRmd_env    *module;         /* of coordinate system */
GRobjid             csmgr;          /* cs manager, if known */
IGRint              display_old;    /* redraw old active cs */
IGRint              display_new;    /* display new active cs */

{
    IGRlong     sts;        /* return code */
    GRobjid     csmanager;  /* coordinate system manager in the specified os */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS; 

    /*
     *  get the cs manager's id
     */

    if (csmgr)
    {
        csmanager = csmgr;
    }
    else
    {
        sts = cs$get_mgr (msg = msg,
                          osnum = module->md_id.osnum,
                          module = module->md_id.objid,
                          csmgr = &csmanager);

        if (!(sts & *msg & 1)) goto finish;
    }

    /*
     *  set the default coordinate system
     */

    sts = om$send (msg = message GRcsmgr.GRset_active_cs
                        (msg, module, objid),
                   senderid = NULL_OBJID,
                   targetid = csmanager,
                   targetos = module->md_id.osnum);

finish:

    return (sts);
}

IGRint GRcsget_scale (msg, cs_id, cs_os, scale)

IGRlong         *msg;           /* O   return code: MSSUCC - always succeeds */
GRobjid          cs_id;         /* I   id of cs in question */
GRspacenum       cs_os;         /* I   object space number of cs */
IGRdouble       *scale;         /* O   scale values */

{
    IGRlong     sts;
    OM_S_OBJID  cs;

    if (cs_id)
    {
        cs = cs_id;
    }
    else
    {
        sts = cs$get_active_info (msg           = msg, 
                                  osnum         = cs_os, 
                                  module        = (GRobjid)NULL,
                                  csmgr         = (GRobjid)NULL,
                                  name          = (IGRchar *)NULL,
                                  namebytes_ret = (IGRint *)NULL,
                                  desc          = (IGRchar *)NULL,
                                  descbytes_ret = (IGRint *)NULL,
                                  type          = (IGRshort *)NULL,
                                  objid         = &cs);

        if (!(sts & *msg & 1)) goto finish;
    }

    sts = om$send (msg = message GRgencs.GRcsgetscale (msg, scale),
                   senderid = NULL_OBJID,
                   targetid = cs,
                   targetos = cs_os);

finish:

    return (sts);
}

IGRint GRcsset_scale (msg, abs_rel, cs_id, cs_os, scale)

IGRlong         *msg;           /* O   return code: MSSUCC - always succeeds */
IGRint           abs_rel;       /* I   absolute/relative scale alteration */
GRobjid          cs_id;         /* I   id of cs in question */
GRspacenum       cs_os;         /* I   object space number of cs */
IGRdouble       *scale;         /* I   scale values */

{
    IGRlong     sts;
    OM_S_OBJID  cs;

    if (cs_id)
    {
        cs = cs_id;
    }
    else
    {
        sts = cs$get_active_info (msg           = msg, 
                                  osnum         = cs_os, 
                                  module        = (GRobjid)NULL,
                                  csmgr         = (GRobjid)NULL,
                                  name          = (IGRchar *)NULL,
                                  namebytes_ret = (IGRint *)NULL,
                                  desc          = (IGRchar *)NULL,
                                  descbytes_ret = (IGRint *)NULL,
                                  type          = (IGRshort *)NULL,
                                  objid         = &cs);

        if (!(sts & *msg & 1)) goto finish;
    }

    sts = om$send (msg = message GRgencs.GRcssetscale (msg, abs_rel, scale),
                   senderid = NULL_OBJID,
                   targetid = cs,
                   targetos = cs_os);

finish:

    return (sts);
}

IGRint GRcscvt_coords (msg, to_world, cs_id, cs_os, cstype, npts, lcl, wld)
IGRlong *msg;
IGRint to_world;
GRobjid cs_id;
GRspacenum cs_os;
IGRchar *cstype;
IGRint npts;
IGRdouble *lcl;
IGRdouble *wld;
{
    IGRlong sts;
    OM_S_OBJID cs;
    OM_p_MESSAGE m;

    if (cs_id)
    {
        cs = cs_id;
    }
    else
    {
        sts = cs$get_active_info (msg           = msg, 
                                  osnum         = cs_os, 
                                  module        = (GRobjid)NULL,
                                  csmgr         = (GRobjid)NULL,
                                  name          = (IGRchar *)NULL,
                                  namebytes_ret = (IGRint *)NULL,
                                  desc          = (IGRchar *)NULL,
                                  descbytes_ret = (IGRint *)NULL,
                                  type          = (IGRshort *)NULL,
                                  objid         = &cs);

        if (!(sts & *msg & 1)) goto finish;
    }

    if (to_world)
    {
        m = message GRgencs.GRcvt_to_wld_coords (msg, cstype, npts, lcl, wld);
    }
    else
    {
        m = message GRgencs.GRcvt_to_lcl_coords (msg, cstype, npts, wld, lcl);
    }

    sts = om$send (msg = m,
                   senderid = NULL_OBJID,
                   targetid = cs,
                   targetos = cs_os);
finish:

    return (sts);
}

IGRint GRcschange_type(msg, cs_id, cs_os, type, type_string)
IGRlong  *msg;
GRobjid  cs_id;
GRspacenum  cs_os;
IGRshort *type;
IGRchar  *type_string;
{
  struct GRid  cs_obj;
  GRobjid      mod_id;
  IGRlong      status;

  status = OM_S_SUCCESS;

  if (cs_os)
  {
    cs_obj.osnum = cs_os;
  }
  else
  {
    ex$get_cur_mod(id = &mod_id,
                   osnum = &cs_obj.osnum);
  }

  if (cs_id)
  {
    cs_obj.objid = cs_id;
  }
  else
  {
    cs$get_active_info(msg           = msg,
                       osnum         = cs_obj.osnum,
                       module        = (GRobjid)NULL,
                       csmgr         = (GRobjid)NULL,
                       name          = (IGRchar *)NULL,
                       namebytes_ret = (IGRint *)NULL,
                       desc          = (IGRchar *)NULL,
                       descbytes_ret = (IGRint *)NULL,
                       type          = (IGRshort *)NULL,
                       objid         = &cs_obj.objid);
    if (!(*msg & 1))
      goto quit;
  }

  status = om$send(msg = message GRgencs.GRchange_type(msg, type, type_string),
                   senderid = NULL_OBJID,
                   targetid = cs_obj.objid,
                   targetos = cs_obj.osnum);
  if (!(status & *msg & 1))
    goto quit;

quit:
  return(status);

}

end implementation GRgencs;
