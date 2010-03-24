/*
   ABSTRACT :
   --------
   
   The following file contains the entry points to handle the object
   space root directory.

   HISTORY :
   -------

   03/18/1988 : HGB - Creation Date
*/
class implementation DIroot;

#define DEBUG
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include <stdio.h>
#include "DIomac.h"


method init ( DIint *status )
{
  /*|connect myself to the OS */
  om_connect_by_name ( my_id, "to_OS", 0, "to_NamObjDir" );
  om_send_msg ( IGRdir.init ( status ), my_id, my_id );
  om_send_msg ( GRoups.init ( status ), my_id, my_id );
  om_send ( DIstorage.init ( status ), my_id, my_id );

  return OM_S_SUCCESS;
}


method identify ( DIobjid *objid )
{
  *objid = my_id;
  return OM_S_SUCCESS;
}


void DIfind_root( osnum, p_objid )
                  DIspacenum  osnum  	/* Osnum 			IN  */;
                  DIobjid     *p_objid	/* Root of OS objid		OUT */;
/* This procedure is used to find the root directory of an object space */
/*.DIfind_root */
{
  DIint           status, count = 0;
  OM_S_CHANSELECT chan;

  /*|find the root of that object space */
  *p_objid = NULL_OBJID;
  chan.type = OM_e_name;
  chan.u_sel.name = "to_NamObjDir";
  status = om$get_channel_count ( osnum = osnum, objid = 0,
                                  p_chanselect = &chan,
                                  count = (OMuint *) &count );
  if (count)
  {
    OM_S_OBJECT_LINKAGE *list;

    list = (OM_S_OBJECT_LINKAGE *) malloc ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
    if (list)
    {
      DIint i;

      om$get_channel_objects ( osnum = osnum, objid = 0, p_chanselect = &chan,
                               list = list, size = count,
                               count = (OMuint *) &count );
      for (i = 0; (i < count) && (*p_objid == NULL_OBJID); i++)
      {
        om$send ( msg      = message DIroot.identify ( p_objid ),
                  senderid = NULL_OBJID, targetid = list [i].S_objid,
                  targetos = osnum );
      }

/*      DIfree ( list ) */
  if (!(list))
  {
    fprintf ( stderr, "in %s at line %d : CAN'T free\n",
              __FILE__, __LINE__ );
  }
  else 
  {
    free ( list );
    list = NULL;
  }


    }
    else fprintf ( stderr, "DIfind_root : CAN'T MALLOC\n" );
  }
}

end implementation DIroot;
