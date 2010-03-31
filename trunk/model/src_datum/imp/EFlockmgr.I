class implementation EMAdatpln;

#include "EMSdatumdef.h"
#include "EMdtmacros.h"

/*
  The following functionality has been developed to allow for successive
  commands (which require the reference plane lock to be on), to do 
  so without causing a flicker resulting from the alternative sleep-
  wakeup implementation of the lock getting turned off/on. This flicker
  occurs since we change the color of the active reference plane from
  red to green and viceversa based on the state of the lock.

  We are able to implement this feature since the command server today
  sends an init message to the command being put on the stack before it
  sends a sleep message to the command that is being stacked.

  History
    Creation : PP : 07/01/92
 */



/*
 * This function is targeted to be called during the wakeup and sleep
 * methods of a command which is desirous of turning the lock on.
 * During the wakeup turnon option is set to TRUE and during sleep 
 * turnon field is set to FALSE.
 */

EFrefplane_lock_mgr(msg, options, turnon,prev_state)
IGRint *msg;
IGRint options;
IGRint turnon;
IGRint *prev_state;
{
 IGRint status,msg_loc;
 IGRint ref_lock_state;

 *msg = EMS_S_Success;
 status = OM_S_SUCCESS;

 ems$ref_plane_lock(msg = &msg_loc,
                      options = EMS_REF_PLANE_LOCK_INQ,
                      mode = &ref_lock_state);

 if (turnon)
 {

   if (ref_lock_state & EMS_REF_PLANE_LOCK_OFF)
   {
    ems$ref_plane_lock(msg = &msg_loc,
                       options = EMS_REF_PLANE_LOCK_ON |
                                 EMS_REF_PLANE_LOCK_SET);
    if (prev_state)
      *prev_state = 0;
   }
   else
    if (prev_state)
      *prev_state = 1;
 }
 else
 {
   if (ref_lock_state & EMS_REF_PLANE_LOCK_ON)
   {
    ems$ref_plane_lock(msg = &msg_loc,
                       options = EMS_REF_PLANE_LOCK_OFF |
                                 EMS_REF_PLANE_LOCK_SET);
    if (prev_state)
     *prev_state = 1;
   }
   else
    if (prev_state)
     *prev_state = 0;
 }
 return(status);
}

/*
 * This function is called by the command which requires the
 * reference plane lock to be on for doing its thing during the
 * init method. This serves to be a warning to the lock manager to
 * not cause the reference plane lock to be turned off in the sleep
 * of the previous command.
 */

 

int EFneedthelockon()
{
 return(1);
}

long EFlmgr_set_lock_state(state)
int state;
{
 return (1);
}
end implementation EMAdatpln;

