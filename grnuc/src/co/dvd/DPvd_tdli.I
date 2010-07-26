class implementation DPvd_tdl;
/*
** DPvd_tdl  - toggle display list on/off
*/

#include <stdio.h>
#include <math.h>
#include <FI.h>




#include "go.h"
#include "dpdef.h" 
#include "dp.h" 
#include "dpmacros.h" 
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grmsg.h"
#include "grcmd.h"
#include "dpcodef.h"





method execute (int *response;
		char *response_data;
		int pos )
/*
NAME
        execute(method)
       
DESCRIPTION
        Get the current state of the display list.
        if on   - set the display list off. Display list is
                  deleted (freed) and not used any more.
        if off  - set the display list on, create a display list and use it.
       
SYNOPSIS
        method execute (int *response;
                        char *response_data;
	                int pos )
       
PARAMETERS
GLOBALS USED
RETURN VALUES
        Always OM_S_SUCCESS     
NOTES
HISTORY
        07/14/93    G. Werner
*/

{
   IGRushort dvd_flags;

   ex$message (field = MESSAGE_FIELD,
                   msgnumb =  GRC_M_TogDisLst );

   *response = TERMINATE;

   DPcodpb_get_dvd_flags(&dvd_flags);

   if (dvd_flags & DVD_DLIST_ON)
      dvd_flags = dvd_flags & ~DVD_DLIST_ON;
   else
      dvd_flags = dvd_flags | DVD_DLIST_ON;

   DPcodpb_set_dvd_flags(dvd_flags);

   ex$message (field = ERROR_FIELD,
                   msgnumb = (dvd_flags & DVD_DLIST_ON) ? GR_I_DisLisOn : GR_I_DisLisOff);

   return OM_S_SUCCESS;
}/* end execute method */


end implementation DPvd_tdl;
