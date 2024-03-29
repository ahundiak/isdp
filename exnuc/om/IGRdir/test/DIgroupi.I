/*
    H.Bequet 02/09/1987                                           DIgroupi.I 

    ABSTRACT :
    --------

    This class is a directory and a graphics groups.

    HISTORY :
    -------

    11/04/1988 : HGB - Creation Date
*/

class implementation DIgroup;

#define  DEBUG

#include <string.h>
#include "OMobjid.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DIomac.h"
#include "DIprims.h"


method untranslate ( DIint *status; DIobjid objid; DIchar *name )
/*
   This method is used to find a name knowing an objid
*/
{
  *status = di$untranslate ( objid = objid, objname = name );
  return OM_S_SUCCESS;
} /* method untranslate */



method i_find ( DIint *status; DIchar *my_name; DIchar **exp_buf; DIint buf_count;
                DIint level, max_level, *deep; DIchar ***lines; DIgrid **grids;
                DIint *count; DIchar options )
{
  *status = OM_S_SUCCESS;
  if (!me->tree)
  {
    om_send ( DIstorage.wakeup ( status ), my_id, my_id );
  }

  if (*status == OM_S_SUCCESS)
  {
    om_send_msg ( IGRdir.i_find ( status, my_name, exp_buf, buf_count, level,
                                  max_level, deep, lines, grids, count, options ),
                  my_id, my_id );
  }
  return OM_S_SUCCESS;
}


method init ( DIint *status )
{
  om_send_msg ( IGRdir.init ( status ), my_id, my_id );
  om_send_msg ( GRoups.init ( status ), my_id, my_id );
  om_send ( DIstorage.init ( status ), my_id, my_id );

  return OM_S_SUCCESS;
}


method debug ()
{
  om_send_msg ( DIbstch.debug (), my_id, my_id );
  om_send_msg ( IGRdir.debug (), my_id, my_id );

  return OM_S_SUCCESS;
}


end implementation DIgroup;
