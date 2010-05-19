/* $Id: VDCsupGenPli.I,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/cmd/VDCsupGenPli.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCsupGenPli.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/29  15:20:46  pinnacle
# Added Headers
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 ***************************************************************************/

class implementation VDCsupGenPl;

#include "VDmaster.h"

#include "VDmsg.h"
#include "VDCsupForm.h"

from	ACrg_collect    import AClist_attribute;
from	ACncpx		import ACget_rep, ACget_NV_rep, ACset_NV_rep;

#ifdef XXX_YYY
extern  DB_debug();           /* Function to print debug		      */
extern	ASstart_fence(), ASend_fence();
extern  NDexec_batch();       /* Function to execute the batch queue          */
extern  ACcreate_possible_rep_col(); /* Fn to find/create representation      */
#endif

extern VDsupDispObj();

method hello ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  printf("Hello\n");
  status = OM_S_SUCCESS;
  goto quit;
quit:
  return OM_S_SUCCESS;
}

method get_initFlag ( long * sts )
{
  *sts = me->initFlag;
  return OM_S_SUCCESS;
}

method init ( int type ; char * str_ptr )
{
  int status;

  status = om$send( 
    msg  = message VDCsupGen.init(type,str_ptr),
    mode = OM_e_wrt_message,
    targetid = my_id
  );
  as$status( action = RET_STATUS );

  me->initFlag = 1;

  if (me->ClearFlag) {
    printf("### Clear Me!!!\n");
  }
  me->ClearFlag = 0;

  return OM_S_SUCCESS;
}

method sleep (int pos)
{
  int status;

  status = om$send( 
    msg  = message CEO_LOCATE.sleep(pos),
    mode = OM_e_wrt_message,
    targetid = my_id
  );
  as$status( action = RET_STATUS );

  me->sleepFlag = 1;

  return OM_S_SUCCESS;
}
method wakeup (int pos)
{
  int status;

  status = om$send( 
    msg  = message CEO_LOCATE.wakeup(pos),
    mode = OM_e_wrt_message,
    targetid = my_id
  );
  as$status( action = RET_STATUS );

  me->sleepFlag = 0;

  return OM_S_SUCCESS;
}

end implementation VDCsupGenPl;
