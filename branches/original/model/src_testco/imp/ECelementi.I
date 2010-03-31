/* ###################   APOGEE COMPILED   ################## */
/*
HISTORY

08/14/94    scw  clarified sleep method
06/1/92  Rustagi Modified for Message Sub-system Compliance
08/08/91    scw  Converted to use gr$dpb associative flag
5/5/91      jhw  Added code to turn on/off assoc button.
11 May 1989 jBk  Added HISTORY.

                Added wakeup override.  Moved much of init code
                to wakekup.

                Changed sleep's unhighlight of instance data's
                me^^ECelement.elem.located_obj to be a general
                erasure of the highlight plane.

SS 10/04/86 : Design Date
*/

class implementation ECelement;

#include "EMS.h"
#include "EMSdpb.h"
#include "EC_M.h"
#include "EC_P.h"

/* grdpb.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef ex_include
# include "ex.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef grdpbdef_include
# include "grdpbdef.h"
# endif

# ifndef grdpb_include
# include "grdpb.h"
# endif

/* end of grdpb.h replacement */
/* igemacros replacement */

# ifndef grdpbmacros_include
# include "grdpbmacros.h" /* gr$get_active_display */
# endif
/* end of igemacros.h replacement */
#include "emsdef.h"
#include "emserr.h"

# include "dpmacros.h" /* dp$erase_hilite */


#include "madef.h"
#include "maidmx.h"
#include "actparam.h"

static IGRboolean aflag;


from GRgraphics import GRdisplay;

method init (IGRint type; IGRchar *string)
{
/*
    ME.super_cmd->state = 0;
    ME.ECelement->elem_hilit = FALSE;
    ME.ECelement->locate_stack.num_entries = 0;

    unnecessary because all instance data are zero upon creation
*/
    ME.super_cmd->mytype = type;
  
    return OM_S_SUCCESS;
}

method wakeup (int pos)
{
    IGRint bytes_in, bytes_out;
    IGRlong omrc = OM_S_SUCCESS, rc;
    IGRint sts;

    ex$message(msgnumb = EMS_P_ClearPromptField); 

    bytes_in = sizeof (me^^ECelement.active_display);
    gr$get_active_display (
        msg = &rc,
        sizbuf = &bytes_in,
        buffer = &me^^ECelement.active_display,
        nret = &bytes_out
    );

    if (EMSmsgReport (rc, "ECelement.wakeup get active display", FALSE))
    {
        return OM_E_ABORT;
    }

    bytes_in = sizeof (me^^ECelement.active_level);
    gr$get_active_level (
        msg = &rc,
        sizbuf = &bytes_in,
        buffer = &me^^ECelement.active_level,
        nret = &bytes_out
    );

    if (EMSmsgReport (rc, "ECelement.wakeup get active level", FALSE))
    {
        return OM_E_ABORT;
    }

   /****
    aflag = pwIsActivationOn();
    if (aflag)
    {
	  sts = pwGetActiveModuleEnv(&me^^ECelement.md_env);
      MAidmx(&rc, me^^ECelement.md_env.md_env.matrix);
      me^^ECelement.md_env.md_env.matrix_type = MAIDMX;
    }
    else
   ****/
    {
       bytes_in = sizeof (me^^ECelement.md_env);
       gr$get_module_env (
           msg = &rc, 
           sizbuf = &bytes_in, 
           buffer = &me^^ECelement.md_env,
           nret = &bytes_out);
    }

    if (EMSmsgReport (rc, "ECelement.wakeup get module env", FALSE))
    {
        return OM_E_ABORT;
    }

    if (me^^ECelement.elem_hilit)
    {
        enum GRdpmode dpmode = GRbd;

        aflag = pwIsActivationOn();
        if (aflag)
        {
            struct GRmd_env dispenv;

            bytes_in = sizeof (dispenv);
            gr$get_module_env (
                msg = &rc,
                sizbuf = &bytes_in,
                buffer = &dispenv,
                nret = &bytes_out);

            omrc = om$send (
                msg = message GRgraphics.GRdisplay (
                    &rc,
                    &dispenv.md_env.matrix_type,
                    dispenv.md_env.matrix,
                    &dpmode,
                    &dispenv.md_id),
                senderid = my_id,
                targetid = me^^ECelement.elem.located_obj.objid,
                targetos = me^^ECelement.elem.located_obj.osnum
        );
        }
        else
        {
            omrc = om$send (
                msg = message GRgraphics.GRdisplay (
                    &rc,
                    &me^^ECelement.elem.module_info.md_env.matrix_type,
                    me^^ECelement.elem.module_info.md_env.matrix,
                    &dpmode,
                    &me^^ECelement.md_env.md_id),
               senderid = my_id, 
               targetid = me^^ECelement.elem.located_obj.objid,
               targetos = me^^ECelement.elem.located_obj.osnum
        );
        }

        EMSmsgReport (rc, "ECelement.wakeup GRdisplay rc", FALSE);
        EMSmsgReport (omrc, "ECelement.wakeup GRdisplay omrc", FALSE);
    }

    return omrc;
}

method super_cmd.sleep (IGRint pos)
{
    IGRchar errmsg[EMMAXERRMSG_LEN];
    IGRlong msg_loc, stat_OM;
    enum GRdpmode dpmode;

    stat_OM = OM_S_SUCCESS;
    strcpy (errmsg, "ECelement.sleep");

    ex$message(msgnumb = EMS_P_ClearPromptField);
    ex$message(msgnumb = EMS_S_ClearStatusField);
    ex$message(msgnumb = EM_M_ClearMessageField); 

    if (ME.ECelement->elem_hilit)
    {
        stat_OM = dp$erase_hilite(msg = &msg_loc);

        EMomerr_hndlr (stat_OM, ret_end, errmsg);
        EMerr_hndlr_action (EMis_error (msg_loc), msg_loc, msg_loc,
                        printf ("%s\n", errmsg));
    }

    GRdisplay_associative_button(FALSE);

ret_end:
    return stat_OM;
}

end implementation ECelement;
