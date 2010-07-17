
/* $Id: VCGchild.I,v 1.1.1.1 2001/01/04 21:12:33 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcguide / VCGchild.I
 *
 * Description:
 *   Information methods for cable guide
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCGchild.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:20:16  pinnacle
# Integ into Route 02040304
#
# Revision 1.2  1997/03/06  23:07:54  pinnacle
# Replaced: vcguide/VCGchild.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:39:32  pinnacle
# Created: vcguide/VCGchild.I by hverstee for cabling
#
 *
 * History:
 *        06/20/96        hv         Initial
 *
 *************************************************************************/

class implementation VCGuide;

from      VCCable    import   VCCbDetach;

/*
#define   MY_DEBUG
*/



method NDchildren_deleted (IGRlong     *msg;
                           IGRint       count_deleted;
                    struct GRid         list_deleted [];
                    struct GRid        *new_obj;
                    struct GRmd_env    *md_env)

{
  IGRint       status;
  IGRlong      retmsg;
  IGRint       i;

  struct GRid  myself;

  *msg = MSSUCC;

  myself.objid = my_id;
  myself.osnum = OM_Gw_current_OS;

  for (i=0; i<count_deleted; i++)
  {

#ifdef MY_DEBUG
    printf (" child deleted %d %d \n",list_deleted[i].objid,
                                      list_deleted[i].osnum);
#endif

    /*A    detach myself from this child cable   */

    status =
    om$send( msg = message VCCable.VCCbDetach (&retmsg, &myself),
        targetid = list_deleted[i].objid,
        targetos = list_deleted[i].osnum);
    as$status( action = RET_STATUS );
    if (retmsg != MSSUCC) *msg = retmsg;
  }

  /*A    Do default processing (if any)   */

  status =
  om$send(msg = message NDnode.NDchildren_deleted
                       (&retmsg, count_deleted, list_deleted, new_obj, md_env),
         mode = OM_e_wrt_message,
     targetid = my_id );
  as$status(action = RET_STATUS );

  return (status);
}

end implementation VCGuide;
