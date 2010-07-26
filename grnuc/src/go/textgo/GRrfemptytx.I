/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     CLASS NAME   GRtext

     Abstract:    This function will determine if the specified object is a
               text object and if so, send it a message to either turn its
               locate and dispaly bits on and display itself or erase itself
               and turn its locate and display bits off if it's an empty
               text object.
-----
%SC%
     Value =  GRrf_empty_text_display(msg,ref_obj,usr_info)
-----
%EN%
 
     ON ENTRY:

        NAME         DATA TYPE                   DESCRIPTION
     ----------     ------------            ---------------------------
     *ref_obj       struct GRid             object id and os number
                                            of object in reference file
     *usr_info      IGRchar                 display on or off mode and
                                            the matrix type and matrix
                                            for display
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
        
        WBC  04/11/88 : Design date.
        WBC  04/11/88 : Creation date.
        SCW  07/22/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This function will determine if the specified object is a
text object and if so, send it a message to either turn its
locate and dispaly bits on and display itself or erase itself
and turn its locate and display bits off if it's an empty
text object.
----*/
/*EH*/

class implementation GRtext;

#include "grimport.h"
#include "msdef.h"

IGRint GRrf_empty_text_display(msg,ref_obj,usr_info)

IGRlong       *msg;                 /* completion code             */
struct  GRid  *ref_obj;             /* object id and os num of ref */
                                    /* file object                 */
struct GRfunction_info *usr_info;
{
    IGRlong   status;            /* return code                          */
    GRclassid classid;           /* classid of the reference file object */

    struct empty_text_arguments
    {
        IGRboolean   display_on;
        GRclassid    classid;
    } *empty_text_args;

    *msg = MSSUCC;
    empty_text_args = (struct empty_text_arguments *)usr_info->info;

    /*
     *  find the classid of the object in the reference file
     */

    status = om$get_classid(osnum = ref_obj->osnum,
                            objid = ref_obj->objid,
                            p_classid = &classid);

    if (status & 1)
    {
        /*
         *  check to see if the reference file object's class is a subclass
         *  of class GRtext
         */
    
        status = om$is_ancestry_valid(subclassid = classid,
                                      superclassid = empty_text_args->classid);

        if (status == OM_S_SUCCESS)
        {
            /*
             *  object is a text object; send it the GRdpemptytext message
             */

            om$send(msg = message GRtext.GRdpemptytext
                                (msg,
                                 empty_text_args->display_on,
                                 &usr_info->md_env->md_env.matrix_type,
                                 usr_info->md_env->md_env.matrix),
                    senderid = NULL_OBJID,
                    targetid = ref_obj->objid,
                    targetos = ref_obj->osnum);
        }
    }
    else  /* om$get_classid failed */
    {
        *msg = MSFAIL;
    }
    return(TRUE);
}

end implementation GRtext;
