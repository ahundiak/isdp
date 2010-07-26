/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRtext
     METHOD NAME:  GRchgname

     Abstract: This method changes the name of a text object.
               If the text object is an empty text object it is erased,
               its text string replaced with the new name and the object
               is displayed.
-----
%SC%    

     GRchgname(msg,env,name)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE              DESCRIPTION
     ----------   ------------   ------------------------------------
     *env         GRmd_env       environment structure
     *name        IGRchar        name of the object

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE              DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        completion code
                                     MSSUCC - successful completion
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  none.

     Methods:  GRvg.GRchgname
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  none.
-----
%CH%

     CHANGE HISTORY:
        
        WBC     07/22/88: Design date.
        WBC     07/22/88: Creation date.
        SCW     07/22/92: Ansi conversion.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This method first sends a message to invoke the GRvg class
change name method.  If the text object is empty it is erased, its
text string is replaced with the new name and it is displayed.
----*/
/*EH*/

class implementation GRtext;

#include "grimport.h"
#include "msdef.h"
#include "fontdef.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "gotextdef.h"
#include "dpmacros.h"

method GRchgname(IGRlong *msg; struct GRmd_env *env; IGRchar *name)

{
    IGRlong                  rc;            /* status return code            */
    IGRlong                  temp_msg;      /* completion code               */
    IGRint                   status;
    IGRmatrix                *matr[1];      /* matrix ptr for display        */
    struct GRid              empty_text_id;

    /*
     * changed the text object's name
     */

    *msg = MSSUCC;

    rc = om$send(mode = OM_e_wrt_message,
                 msg = message GRvg.GRchgname(msg,env,name),
                 targetid = my_id);

    if (1 & rc)
    {
        /*
         * if the text object is empty, erase it
         */

        if (me^^GRtext.attr.flag & EMPTY_TEXT_FLAG)
        {
            empty_text_id.objid = my_id;
            empty_text_id.osnum = OM_Gw_current_OS;
            matr[0] = (IGRmatrix *)env->md_env.matrix;

            status = dp$display(msg = &temp_msg,
                                mode = GRbehe,
                                oids = &empty_text_id,
                                mtx_type = &env->md_env.matrix_type,
                                matrix = matr);

            if (1 & status & temp_msg)
            {
                /*
                 * replace the text object's text string with the
                 * new object name
                 */

                rc = om$send(mode = OM_e_wrt_object,
                             msg =  message GRtext.GRreplace_text(
                                               &temp_msg,env,
                                               (IGRshort)strlen(name),
                                               (IGRuchar *)name),
                             targetid = my_id);
                if (1 & rc & temp_msg)
                {
                    /*
                     * display the text object
                     */

                    status = dp$display(msg = &temp_msg,
                                        mode = GRbd,
                                        oids = &empty_text_id,
                                        mtx_type = &env->md_env.matrix_type,
                                        matrix = matr);

                    if (! (1 & status & temp_msg))
                    {
                        *msg = MSFAIL;
                    }
                }
                else    /* failed replacing the text object's text string */
                {
                    *msg = MSFAIL;
                }
            }
            else    /* failed erasing the text object */
            {
                *msg = MSFAIL;
            }
        }
    }
    else    /* failed changing the text object's name */
    {
        *msg = MSFAIL;
    }
    return (rc);   
}

end implementation GRtext;
