/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRtext
     METHOD NAME:  GRlocate_processing

     Abstract: This method checks to see if the graphics object
               passes the class list check and the tolerance
               check.
-----
%SC%    

     GRlocate_processing(msg,cvl,path,path_position,owner_elig,
                         comp_elig)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE              DESCRIPTION
     ----------   ------------   ------------------------------------
     *cvl         GRlc_cvl       structure containing all locate info
     path[]       GRlc_path      path information about the object
     *path_position IGRint       position of object in path array
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE              DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        completion code
                                      - MSSUCC if successful
                                      - MSFAIL (severe) if failure
     path[]       GRlc_path      path information about the object
     *path_position IGRint       position of object in path array
     *owner_elig  IGRint         indicator of whether owner is eligible
     *comp_elig   IGRint         indicator of whether component is
                                 eligible
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  

     Methods:  GRgraphics.GRlocate_processing

-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  none.
-----
%CH%

     CHANGE HISTORY:
        
        DEK     09/16/88: Design date.
        DEK     09/16/88: Creation date.
        SCW     07/22/92: Removed copyright header
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This method checks to see if the graphics object passes the class
list check and the tolerance check.
----*/
/*EH*/

class implementation GRtext;

#include "msdef.h"
#include "grimport.h"

method GRlocate_processing(IGRlong *msg; struct GRlc_cvl *cvl;
              struct GRlc_path *path; IGRint *path_position; 
              IGRint *owner_elig; IGRint *comp_elig)
{
   IGRlong                  rc;            /* status return code            */

   rc = om$send(mode = OM_e_wrt_message,
                msg = message GRlbsys.GRlocate_processing
                      (msg,cvl,path,path_position,owner_elig,comp_elig),
                senderid = my_id,
                targetid = my_id,
                targetos = OM_Gw_current_OS);

   return (rc);   
}

end implementation GRtext;
