/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     Abstract:    This function will set or inquire a static flag that
                  indicates whether or not to delete the graphic set when
                  the graphic set manager is sent a sleep message.
-----
%SC%
     Value =  GRset_inq_gs_flag(msg,set_flag,gs_flag)
-----
%EN%
 
     ON ENTRY:

        NAME         DATA TYPE                   DESCRIPTION
     ----------     ------------            ---------------------------
     set_flag       IGRint                  TRUE if setting the gs_flag,
                                            FALSE if inquiring the flag
     *gs_flag       IGRint                  if setting the flag, this is
                                            the value to set it to;
                                            - bit 0 set -> delete the
                                            graphics set
                                            - bit 0 clear -> don't delete
                                            the graphics set
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong         Completion code
                                    - MSSUCC if successful

     *gs_flag       IGRint        if inquiring the flag, this is
                                  the meaning of the flag:
                                  - bit 0 set -> delete the
                                    graphics set
                                  - bit 0 clear -> don't delete
                                    the graphics set

     VALUE (IGRint) = TRUE        - if successful
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
        SCW  07/10/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This function will set or inquire a static flag that
indicates whether or not to delete the graphic set when
the graphic set manager is sent a sleep message.
----*/
/*EH*/

#include "coimport.h"
#include "msdef.h"


#argsused
IGRint GRset_inq_gs_flag(msg,set_flag,gs_flag)

IGRlong       *msg;       /* completion code                              */
IGRint        set_flag;   /* TRUE if setting the gs_flag, FALSE otherwise */
IGRint        *gs_flag;   /* bit 0 set -> delete the graphics set         */
                          /* bit 0 clear -> don't delete the graphics set */
{
    static IGRint     delete_gs = 1;

    if (set_flag)
    {
        delete_gs = *gs_flag;
    }
    else  /* inquiring the flag */
    {
        *gs_flag = delete_gs;
    }
    return(TRUE);
}
