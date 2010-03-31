/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: EMSsubbs
     METHOD NAME: GRgeomprops

     Abstract: This method returns the geometry properties of an surface
               object.

-----
%SC%    

    GRgeomprops(msg,mat_type,matrix,properties)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type    IGRshort       matrix type
     matrix       IGRmatrix      environment matrix
     
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        return code:
                                        MSSUCC - successful
                                        MSFAIL - failure to get 
                                 abstract geometry.

     *properties  GRprops        geometric properties.

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
             none.
     Methods:
             GRgenabsg
             
-----
%RL%

     RELATIONS REFERENCED:  none.
                          
-----
%NB%

     NOTES:  none.
           
-----
%CH%

     CHANGE HISTORY:

        AIC     25 July 87  Moved from EMSsubbs to EMSsubbs.
        RLW     09/21/86 : OM 4.0 conversion
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine gets the abstract data of the object in order find out the
 properties for output. It also assigns the type to be GRSS.

----*/
/*EH*/

class implementation EMSsubbs;

#include "EMS.h"
# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif

# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "madef.h"

method GRgeomprops(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix; 
                   struct GRprops *properties)

{
 struct IGRbsp_surface *bs;             /* abstract geometry pointer  */
 IGRchar *ptr;                          /* abstract geometry pointer  */
 IGRint i;                              /* index                      */

 *msg = MSSUCC;
 GRgetabsg(msg,mat_type,matrix,&ptr,i);
  if (!(1 & *msg)) return(OM_E_ABORT);
 bs = (struct IGRbsp_surface *)ptr;
 properties->type         = GRSURFACE;
 properties->subtype      = GRSS;
 properties->closed       = 0;
 properties->phy_closed   = bs->u_phy_closed || bs->v_phy_closed;
 properties->is_segmented = 0;
 properties->planar       = bs->planar;
 return(OM_S_SUCCESS);
}

end implementation EMSsubbs;
