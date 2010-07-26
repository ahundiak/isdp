/*

   ABSTRACT :
   --------
   
   The following file contains the entry points to handle the object
   space interface for the directory sub-system.

   HISTORY :
   -------

   07/31/1987 : HGB - Creation Date
   03/18/1988 : HGB - Move to OM
*/
class implementation DIlink;

#define DEBUG

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "DIomac.h"

#include <stdio.h>

method delete ( DIint flag )
{
  /* the hash table and the master directory should be deleted */

  om_send_msg ( Root.delete ( flag ), my_id, my_id );

  return ( OM_S_SUCCESS );
}


method set_target ( DIint *status; DIgrid target )
{
  DIint om_status;

  *status = DIR_S_SUCCESS;

  me->root = target;
  
  /*|let my messages be intercepted */
  om_status = om$set_intercept ( objid        = my_id, 
                                 target_osnum = target.osnum,
                                 target_objid = target.objid );
  return om_status;
}

end implementation DIlink;
