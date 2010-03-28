/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     CLASS NAME   COgrpevent

     Abstract:    This function will compare the current object id and osnum
               with an array of object ids and osnums passed in and if the
               current object does not match one of the objects in the array,
               the current object will be set a delete message.  The usr_info
               argument contains a pointer to an array of objids and osnums
               owned by the graphics set mentioned above.
-----
%SC%
     Value =  GRdel_obj_not_listed(msg,current_obj,usr_info)
-----
%EN%
 
     ON ENTRY:

        NAME         DATA TYPE                   DESCRIPTION
     ----------     ------------            ---------------------------
     *current_obj   struct GRid             object id and os number
                                            of object in master file
     *usr_info      IGRchar                 number of objects owned by
                                            the graphics set and an
                                            array of object info. about
                                            each of these objects
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong         Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:    

-----
%RL%

     RELATIONS REFERENCED:

-----
%UI%

     USER INTERFACE DESCRIPTION:

-----
%NB%

     NOTES:  

-----
%CH%
     CHANGE HISTORY:
        
        WBC  03/30/89 : Design date.
        WBC  03/30/89 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This function will compare the current object id and osnum
with an array of object ids and osnums passed in and if the
current object does not match one of the objects in the array,
the current object will be set a delete message.  The usr_info
argument contains a pointer to an array of objids and osnums
owned by the graphics set mentioned above.
----*/
/*EH*/

class implementation COgrpevent;

#include "coimport.h"
#include "msdef.h"

from GRgraphics   import GRdelete;

IGRint GRdel_obj_not_listed(msg,current_obj,usr_info)

IGRlong       *msg;                 /* completion code                */
struct  GRid  *current_obj;         /* object id and os num of object */
                                    /* in the maste file              */
struct GRfunction_info *usr_info;
{
    IGRlong    status;            /* return code                          */
    IGRint     i;
    IGRboolean obj_not_in_gs;
    GRclassid  classid;           /* classid of the current object */
    struct gs_members
    {
        IGRint            num_objects;
        struct GRobj_env  *obj_env;
        struct GRmd_env   mod_env;
        GRclassid         clippoly_classid;
    } *gs_info;

    *msg = MSSUCC;
    gs_info = (struct gs_members *) usr_info->info;

    /*
     * determine if the current object is a member of the array; if not,
     * delete it
     */

    obj_not_in_gs = TRUE;

    for (i = 0; (i < gs_info->num_objects) && obj_not_in_gs; ++i)
    {
        if ((gs_info->obj_env[i].obj_id.objid == current_obj->objid) &&
            (gs_info->obj_env[i].obj_id.osnum == current_obj->osnum))
        {
            obj_not_in_gs = FALSE;
        }
    }

    if (obj_not_in_gs)
    {
        /*
         * object is not listed in the array; if it is not of the class
         * GRclippoly, delete it
         */

        status = om$get_classid(osnum = current_obj->osnum,
                                objid = current_obj->objid,
                                p_classid = &classid);

        if ((status & 1) &&
            (classid != gs_info->clippoly_classid))
        {
            om$send(msg = message GRgraphics.GRdelete(&status,
                                                      &gs_info->mod_env),
                    senderid = NULL_OBJID,
                    targetid = current_obj->objid,
                    targetos = current_obj->osnum);
        }
    }

    return(TRUE);
}

end implementation COgrpevent;
