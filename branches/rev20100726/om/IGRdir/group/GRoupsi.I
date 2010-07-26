/*
    ABSTRACT :
    --------

    This is the implementation file of the class GRoups.  This class provides
    a group-oriented protection mechanism for the objects.

    HISTORY :
    -------

    03/31/1988 : HGB - Creation Date
    05/14/1992 : EMS - Change PATH_MAX to DI_PATH_MAX
*/

class implementation GRoups;

#include "OMerrordef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "GRprims.h"
#include "GRtypedef.h"
#include "GRdef.h"
#include "GRglob.h"

#define DEBUG
#include "DIdebug.h"

#include "DIomac.h"


from GRoup  import check_passwd;


method init ( GRint *status )
{
  /*"set me->index to %d\n", GR_cur_gr_ind */
  me->index = GR_cur_gr_ind;
  *status = GR_S_SUCCESS;

  return OM_S_SUCCESS;
}


method give_group ( GRint *status; GRint *group_ind )
{
  if (group_ind)
  {
    *group_ind = me->index;
    *status = GR_S_SUCCESS;
    /*"group index = '%d'\n", group_ind */
  }
  else
    *status = GR_E_ABORT;

  return OM_S_SUCCESS;
}


method change_group ( GRint *status; GRchar *passwd )
{
  GRspacenum osnum;
  GRobjid    groupid;

  /*"now entering the change_group message with passwd '%s'\n", passwd */

  if (me->index == GR_cur_gr_ind)
    *status = GR_S_SUCCESS;
  else
  {
    GRchar group_name [DI_PATH_MAX];

    /*"passwd = '%s'\n", passwd */
    /*"me->index changed from '%d'\n", me->index */

    /*|find the group name & id */
    *status = di$index ( dirname = ":groups",
			 index   = me->index,
			 p_objid = &groupid,
			 p_osnum = &osnum,
			 name    = group_name );

    /*"old group name : '%s'\n", group_name */
    if (*status == DIR_S_SUCCESS)
    {
      /*|send it to my group */
      om_send_for ( GRoup.check_passwd ( status, passwd, group_name),
                    NULL_OBJID, groupid, osnum );

      if (*status == GR_S_SUCCESS)
        me->index = GR_cur_gr_ind;
      else
        *status = GR_E_PERMISSION;
    }
    /*"to me->index = '%d'\n", me->index */
  }

  return OM_S_SUCCESS;
}


method validate ( GRint *status; GRchar type )
{
  *status = gr$validate ( type = type );

  return OM_S_SUCCESS;
}


end implementation GRoups;
