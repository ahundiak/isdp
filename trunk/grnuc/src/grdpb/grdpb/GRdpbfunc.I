/*
Name
        GRdpbfunc

Description
        This file contains miscellaneous functions associated with
        the dpb.
*/

class implementation GRdpb;

#include "grimport.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "gr.h"
#include "ex.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "dpdef.h"
#include "dp.h"
#include "dpdef.h"
#include "gomacros.h"
#include "madef.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#ifndef IDRAW
extern IGRboolean RScalccalib();
extern IGRint RSloadvlt();
#endif

/*
Name
        GRset_dpb_objid, GRget_dpb_objid

Description
        These functions optimize the retrieval of the DPB objid.
*/

%safe
/* can't use NULL_OBJID; it's an extern */
static OM_S_OBJID GRdpb_objid = 0xffffffff;
%endsafe

void GRset_dpb_objid(objid)
OM_S_OBJID objid;   /* >    dpb id to store */
{
    GRdpb_objid = objid;
}

IGRint GRget_dpb_objid(dpb_id, mod_osnum)
OM_S_OBJID *dpb_id;     /* <    dpb id */
OMuword *mod_osnum;     /* <    dpb osnum */
{
    IGRlong sts = 1;
    OM_S_OBJID mod_id;
    IGRboolean aflag;

    aflag = pwIsActivationOn(); 

    /* get the current module space number */

    if (aflag)
    {
      struct GRmd_env rfenv;
      pwGetActiveModuleEnv(&rfenv);
      mod_id = rfenv.md_id.objid;
      *mod_osnum = rfenv.md_id.osnum;

      GRset_dpb_objid(NULL_OBJID);
    }
    else
    {
      GRset_dpb_objid(NULL_OBJID);
      sts = ex$get_cur_mod(id = &mod_id, osnum = mod_osnum);
    }

    if (sts & 1)
    {
        /* set the dpb objid */

        if (GRdpb_objid == NULL_OBJID)
        {
            /* not initialized, so get the id the hard way */

            sts = ex$get_super(mod_id = mod_id,
                               mod_osnum = *mod_osnum,
                               super_name = "GRdpb",
                               create = TRUE,
                               super_class = "GRdpb",
                               super_id = dpb_id);
            /*
                It is tempting at this point to call GRset_dpb_objid,
                but down that path lies danger.  Consider this case: 
                During a close/retrieve, GRdpb is sent sleep, and calls
                GRset_dpb_objid(NULL_OBJID).  Then another super
                receives sleep, and calls gr$get___, which ends up back
                here.  If GRset_dpb_objid were called here, it would
                store the dpb id from the old space.  Then when someone
                in the new object space called gr$get___ before the new
                GRdpb received a wakeup, the id stored would refer to
                the old space, and would probably not be good in the
                new space.  Therefore, only GRdpb.wake_up and
                GRdpb.sleep should call GRset_dpb_objid.
            */
        }
        else
        {
            *dpb_id = GRdpb_objid;
        }
    }
    return(sts & 1);
}

/*
Name
        GRgetactenv -- get the active environment information

Description
        This function currently just returns the active module
        information.

History
        MAS     03/27/87    Design date
        dhm     07/09/92    ANSI conversion.
*/

#argsused
IGRint GRgetactenv(msg, point, sizbuf, md_env, nret)
IGRlong *msg;               /* return message */
struct EX_button *point;    /* point to be used */
IGRint *sizbuf, *nret;      /* size of input buffer and output information */
struct GRmd_env *md_env;    /* environment returned */
{
    *msg = MSSUCC;
    gr$get_module_env(buffer = md_env);
    return(TRUE);
}

/*
Name
        GRdpb_get

Description
        This function is called from all of the gr$get... macros defined
        in grdpbmacros.h.  It will invoke the appropriate method on the
        GRdpb object to return the requested information.
*/

IGRint GRdpb_get(msg, parameter, sizbuf, buffer, nret)
IGRint *msg, parameter, *sizbuf, *nret;
IGRchar *buffer;
{
    IGRint sts, l_msg;
    OMuword dpb_os;
    OM_S_OBJID dpb_id;
   
    if (msg == NULL) msg = &l_msg;
    if (sts = GRget_dpb_objid(&dpb_id, &dpb_os))
    {
        if (nret && sizbuf) *nret = *sizbuf;

        sts = om$send(msg = message GRdpb.GRget(msg, parameter, buffer),
                      senderid = NULL_OBJID,
                      targetid = dpb_id,
                      targetos = dpb_os);
    }
    else
    {
        *msg = MSFAIL;
    }
    return(sts & *msg & 1);
}


/*
Name
        GRdpb_put

Description
        This function is called from all of the gr$put... macros defined
        in grdpbmacros.h.  It will invoke the appropriate method on the
        GRdpb object to deposit the specified information.
*/

#argsused
IGRint GRdpb_put(msg, parameter, sizbuf, buffer)
IGRint *msg, parameter, *sizbuf;
IGRchar *buffer;
{
    IGRint sts, l_msg;
    OMuword dpb_os;
    OM_S_OBJID dpb_id;
   
    if (msg == NULL) msg = &l_msg;
    if (sts = GRget_dpb_objid(&dpb_id, &dpb_os))
    {
        sts = om$send(msg = message GRdpb.GRput(msg, parameter, buffer),
                      senderid = NULL_OBJID,
                      targetid = dpb_id,
                      targetos = dpb_os);
    }
    else
    {
        *msg = MSFAIL;
    }
    return(sts & *msg & 1);
}

#ifndef IDRAW
IGRint GRsetinqcolcal(msg,inq0_set1,calibration_flag)
IGRlong *msg;
IGRint inq0_set1;
IGRint *calibration_flag;
{
    IGRdouble exponent;
    IGRint status;
    OMuword mod_osnum;
    OM_S_OBJID mod_id;
    struct GRIOvar_def var_info;

    *msg = MSSUCC;

    ex$get_cur_mod(id = &mod_id, osnum = &mod_osnum);

    if (inq0_set1 == 0)
    {
        status = co$cvtvar(msg = msg,
                           alias = "GRcolorcal",
                           osnum = mod_osnum,
                           var = &var_info);

        if (!(status & 1))
        {
            var_info.type = GRIO_VAR_INT;
            var_info.contents.ivalue = 0;
        
            co$addvar(msg = msg,
                      input_alias = "GRcolorcal",
                      osnum = mod_osnum,
                      input_string = &var_info);

            *calibration_flag = 0;
        }
        else
        {
            *calibration_flag = var_info.contents.ivalue;
        }
    }
    else
    {
        var_info.type = GRIO_VAR_INT;
        var_info.contents.ivalue = *calibration_flag;
 
        co$addvar(msg = msg,
                  input_alias = "GRcolorcal",
                  osnum = mod_osnum,
                  input_string = &var_info);

        if (*calibration_flag)
        {
            exponent = 0.45;
        }
        else
        {
            exponent = 1.0;
        }

        RScalccalib(msg,&exponent,&exponent,&exponent);
        DPset_load_vlt_ptr(RSloadvlt);
    }

    return(1);
}
#endif                          
end implementation GRdpb;

