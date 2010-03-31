/* ###################   APOGEE COMPILED   ################## */
class implementation GAcurve;

#include "EMS.h"
# include <stdio.h>
# include "OMmacros.h"
# include "emsdef.h"
# include "EMcp.h"
# include "godef.h"
# include "gocmacros.h"


method GRcopy(IGRlong *msg; struct GRmd_env *obj_mdenv; 
              struct GRmd_env *new_mdenv; GRobjid *newobjid)

/*
Description
            This file contains the GRcopy method for the associative
            model-space counterparts root class GAcurve.  It clears the
            GRIS_ASSOCIATIVE and GRHAS_EXTERNAL_CONSTRAINT bits of the
            copied object since it will not be an associative object.

            *msg          method completion code.
            *obj_mdenv    struct describing objects's present environment.
            *new_mdenv    struct describing copy's environment.
            *newobjid     objid of the copied composite surface.

Algorithm

Return Values
                Upon exit the completion code will be one of 

                - MSSUCC if successful
                - MSFAIL(severe) if failure

History
                WBC    06/21/91 : Creation date.
*/
                
{
    IGRlong     OM_stat,
                mthd_stat;
    IGRshort    action,
                props;
    IGRchar     classname[OM_K_MAXCLASS_LEN];

    *msg = MSSUCC;
    OM_stat = OM_S_SUCCESS;

    /*
     * send a message to myself to perform the copy process
     */

    OM_stat = om$send(mode = OM_e_wrt_parent,
                      msg = message GAcurve.GRcopy(msg, obj_mdenv,
                                                   new_mdenv, newobjid),
                      targetid = my_id);
    EMerr_hndlr(!(1 & OM_stat & *msg),*msg, MSFAIL, wrapup);

    /*
     * send GRchgprops to the copied object to clear the associative and
     * externally constrained bits since the new object will not be associative
     */

    action = 0;
    props = GRIS_ASSOCIATIVE | GRHAS_EXTERNAL_CONSTRAINT;

    OM_stat = om$send(msg = message GRgraphics.GRchgprops(&mthd_stat,
                                                          &action, &props),
                      targetid = *newobjid,
                      targetos = new_mdenv->md_id.osnum);
    EMerr_hndlr(!(1 & OM_stat & *msg),*msg, MSFAIL, wrapup);

    /* change the class of the copied object to be the corresponding
     * non-associative class since the copy is not associative and making
     * it non-associative will result in a smaller object
     */

    OM_stat = om$get_classname(osnum = new_mdenv->md_id.osnum,
                               objid = *newobjid,
                               classname = classname);
    EMerr_hndlr(!(1 & OM_stat),*msg, MSFAIL, wrapup);

    classname[1] = 'R';  /* changing from GAxxxx to GRxxxx */

    OM_stat = om$change_class(osnum = new_mdenv->md_id.osnum,
                              objid = *newobjid,
                              classname = classname);
    EMerr_hndlr(!(1 & OM_stat),*msg, MSFAIL, wrapup);

wrapup:

     EMWRAPUP (*msg, OM_stat, "In GAcurve.GRcopy");
     return(OM_stat);
}

end implementation GAcurve;
