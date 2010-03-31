/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: EMScompsurf
     METHOD NAMES: GRconstruct

     Abstract:  This file contains the construct method for the composite
                surface based subclasses of the GRvg class.

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
                        gupta 12/03/86 : Creation date.

                        RC    12/15/86 : Added the code to calculate
                                         and post the range.

                        DLB   10/30/87 : Converted for version 1.1.0 and
                                         removed a lot of code unneeded
                                         code.

                        pp    05/04/88 : Removed the GRputname and
                                         GRputsymb sends to myself.

                        AIC   06/02/88 : Set GRNO_NOTIFICATION flag.

    15 Sep 1988 AIC Do not set GRNO_NOTIFICATION bit.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


class implementation EMScompsurf;

#include "EMS.h"
#define TRUE  1
#define FALSE 0

#include "OMlimits.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSerrordef.h"

method GRconstruct(struct GRvg_construct *arglist)
{
 IGRlong  OM_stat = OM_S_SUCCESS;              /* om return status     */
 struct   GRsymbology symb;

/*
 * Initialize
 */

 *(arglist->msg) = EMS_S_Success;
 if(arglist->newflag) return(OM_S_SUCCESS);

/*
 * Set up the properties
 */

 ME.GRgraphics->properties = (arglist->properties | GRIS_NEW) &
                             ~GRIS_MODIFIED;

/*
 * Load the elements name, if any
 */

/*
 if( arglist->name )
 {
   OM_stat = om$send(msg = message GRvg.GRputname(
                           arglist->msg, arglist->name),
                     targetid = my_id);
   if (!(1 & OM_stat & *(arglist->msg))) goto wrapup;
 }

*/
/*
 * Load the symbology. This will be sent to all components.
 */
/*
 symb.display_attr = *(arglist->display);
 symb.level        = arglist->level;
 OM_stat = om$send(msg = message GRvg.GRputsymb(arglist->msg, &symb),
                   targetid = my_id);
 if (!(1 & OM_stat)) goto wrapup;
*/

wrapup:
 EMWRAPUP(*(arglist->msg), OM_stat, "In EMScompsurf.GRconstruct")
 return(OM_stat);
}
end implementation EMScompsurf;

