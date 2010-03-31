/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: EMSmassprop
     METHOD NAMES: GRconstruct

     Abstract:  This file contains the construct method for the mass
                property class

-----
%SC%    

    VALUE = GRconstruct(arglist)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *arglist     GRvg_construct construct arguments

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------


-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:

     Methods:
              GRputrang
              GRputattr
              GRputsymb
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
           The return code in the input argument list can have the 
           following values:

          
                EMS_S_Success - successful
                EMS_E_Fail - if failure

-----
%CH%

     CHANGE HISTORY:
                        gupta 08/16/89 : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


class implementation EMSmassprop;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#define TRUE  1
#define FALSE 0

#include "OMlimits.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSerrordef.h"

method GRconstruct(struct GRvg_construct *arglist)
{
 IGRlong  stat_OM = OM_S_SUCCESS;
 struct   GRsymbology symb;

/* Initialize */

 *(arglist->msg) = EMS_S_Success;
 if(arglist->newflag) return(OM_S_SUCCESS);

 /* Set up the properties */

 ME.GRgraphics->properties = (arglist->properties | GRIS_NEW) &
                             ~GRIS_MODIFIED;
 /* Load the symbology */

 symb.display_attr = *(arglist->display);
 symb.level        = arglist->level;
 stat_OM = om$send(msg = message GRvg.GRputsymb(arglist->msg, &symb),
                   targetid = my_id);
 if (!(1 & stat_OM)) goto wrapup;

wrapup:
 EMWRAPUP(*(arglist->msg), stat_OM, "In EMSmassprop.GRconstruct")
 return(stat_OM);
}
end implementation EMSmassprop;

