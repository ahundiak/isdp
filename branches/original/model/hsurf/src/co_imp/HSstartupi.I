/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/


class implementation HSstartup;

/*
DESCRIPTION
        Implementation file for the Hidden Surface startup command

HISTORY
        S.P. Rogers  11/27/87  Creation Date
        r. Druzynski  4/11/91  Apogee conversion
*/

/*#include "hsurf_import.h"*/
#include "stdlib.h"

#include "stdio.h"

#include "igrtypedef.h"

#include "exdef.h"
#include "exmacros.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "wl.h"
#include "igetypedef.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "hslight.h"
#include "hsmacdef.h"
#include "hsmacros.h"

/*--- execute -------------------------------------------------*/

method execute( int  *response;
                char *response_data;
                int  pos )
/*
DESCRIPTION
     Perform the initialization required for shading.

HISTORY
     07/--/89  S.P. Rogers Changed to construct HSdpb2 instead of HSdpb.
     06/07/90  S.P. Rogers Changed to construct HSctbl2 instead of HSctbl.
     05/04/93  J.D. Underwood Removed HSctbl2 since not needed for IGEcolor2 object.
*/

{
   IGRlong        sts;
   OM_S_OBJID     mod_id;
   OMuword        mod_osnum;
   OM_S_OBJID     super_id;
   OMuword        super_osnum;
   struct HS_light_source  ambient;

   sts = ex$get_cur_mod( osnum = &mod_osnum, id = &mod_id );

   /* Make sure that there is an HSdpb2 object for this module*/
   /* If it is an old file, ex$get_super will return the id of the previously*/
   /* created HSctbl2 super object and the color table will not be*/
   /* reconfigured*/

   sts = ex$get_super( mod_id      = mod_id,
                       mod_osnum   = mod_osnum,
                       super_name  = "HSdpb2",
                       create      = 1,
                       super_class = "HSdpb2",
                       super_id    = &super_id,
                       super_osnum = &super_osnum );

   hs$get_global_lights( ambient_light = &ambient );
   IGEset_ambient_light( ambient.red, ambient.green, ambient.blue);
   IGEset_min_ramp_shades( 2 );
   ige$configure_color_table();

   *response = TERMINATE;
   return( OM_S_SUCCESS );

}  /* execute */

end implementation HSstartup;

