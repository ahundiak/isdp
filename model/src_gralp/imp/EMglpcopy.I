/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
class implementation EMSgraloop;

#include "EMS.h"
#include "OMmacros.h"

/* history
   25-APR-91  SCW  Genesis
   
*/   

method EMhelperCopy( IGRlong          *EMmsg; 
                     struct GRid      *sender_copy;
                     struct EMcp_info *copy_info )
{
  IGRlong           sts;
  OM_S_OBJID        copy = NULL_OBJID;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  sts = om$send( msg = message EMSboundary.EMintcopy( EMmsg, 
                                                      NULL,
                                                      OM_Gw_current_OS, 
                                                      sender_copy->osnum, 
                                                      NULL, 
                                                     &copy,
                                                      copy_info ), 
                 targetid = my_id );

  /*
   * Send the init message if copied.
   */
  if( !IF_NULL_OBJID( copy ))
  {

    sts = om$send( mode = OM_e_wrt_message,
                   msg = message EMShelper.EMhelperCopy( EMmsg, 
                                                         sender_copy,
                                                         copy_info ),
                   senderid = sender_id,
                   targetid = my_id );
    if( !( 1 & *EMmsg & sts )) goto wrapup;

    /* previously called EMSgradata.EMinit
    sts = om$send( msg = message EMSgraloop.EMinit( EMmsg,
                                                    sender_copy->objid, 
                                                    NULL_OBJID ),
                  targetid = copy, 
                  targetos = sender_copy->osnum );
     */
  }

wrapup:
  /*
   * On failure, delete the copy.
   */
  if( !( 1 & *EMmsg & sts ))
  {
    if( copy ISNT NULL_OBJID )
    {
      om$send( msg = message Root.delete( 0 ),
               targetid = copy, 
               targetos = sender_copy->osnum );
    }
  }

  EMSmsgReport( sts, "EMSgraloop.EMhelperCopy", FALSE );
  if EMSmsgReport( *EMmsg, "EMSgraloop.EMhelperCopy", FALSE )
    sts = OM_E_ABORT;
  return( sts );                              
}

end implementation EMSgraloop;
