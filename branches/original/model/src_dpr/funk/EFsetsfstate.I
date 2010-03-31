/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "EMSssprops.h"
#include "EMSopt.h"

from EMSsubbs import EMset_props;

void EFsetsfstate(EMmsg, sf_objid, sf_osnum, on_off)

IGRlong         *EMmsg;
GRobjid         sf_objid;  /*surface objid to set state.*/
OMuword         sf_osnum;  /*surface osnum to set state.*/
IGRboolean      on_off;    /*If EMS_O_ON set state to active         *
                            *else if EMS_O_OFF set state to inactive.*/

/*
Description
    This function will toggle a surface to active or inactive by (re)setting
    the NON_LOCATABLE, NON_DISPLAYABLE, and EMSIS_INACTIVE bits in the
    graphics properties and the ss_props fields.
     
Return Values
    *EMmsg;       EMS_S_Success if all goes well.           

Notes
    Because of old design files, I must set surfaces to LOCATABLE and 
    DISPLAYABLE when activating a surface.    


History

24 Apr 1989 jBk Added code to send GRvg.GRchgprops when
                OM_W_UNKNOWN_MSG is returned from message
                EMSsubbs.EMset_props.  This is to take care of
                those booleans with a null result which are
                wholly removed operands, since objects of class
                GR3dtext do not recognize EMSsubbs.EMset_props.

    DLB  08/03/88 Set LOC and DIS bits when surface becomes active.
    DLB  07/28/88 creation.
*/
{
 IGRlong          OM_stat;
 IGRuchar props;

 
 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
    
 if (on_off == EMS_O_ON)  /*Added by DLB 08/03/88*/
 {
   /*Surface is becoming active.*/
   IGRboolean        action = TRUE; 
   IGRushort mask = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

   OM_stat = om$send(msg = message GRvg.GRchgprops(EMmsg, &action, 
                           (IGRshort *) &mask),
                     senderid = NULL_OBJID,
                     targetid = sf_objid,
                     targetos = sf_osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }

 on_off = (on_off ? EMS_O_OFF : EMS_O_ON); 

 props = EMSIS_INACTIVE;

 OM_stat = om$send(msg = message EMSsubbs.EMset_props(EMmsg, 
                         (IGRuchar) props, (IGRchar) on_off),
                   senderid = NULL_OBJID,
                   targetid = sf_objid,
                   targetos = sf_osnum);
 if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;

 if (on_off IS EMS_O_ON AND OM_stat IS OM_W_UNKNOWN_MSG)
 {
    /*
        if on_off was EMS_O_OFF upon entry, it is EMS_O_ON now;
        do not need to do this if it was EMS_O_ON upon entry
        because it would already have been done above; surface is
        becoming inactive; might be a null-result boolean since
        it did not recognize and/or pass the EMSsubbs.EMset_props
        message -- jBk 24 Apr 1989 
    */

    IGRboolean offaction = FALSE;
    IGRushort bitmask = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

    OM_stat = om$send (
        msg = message GRvg.GRchgprops (
            EMmsg,
            &offaction,
            (IGRshort *) &bitmask
        ),
        senderid = NULL_OBJID,
        targetid = sf_objid,
        targetos = sf_osnum
    );

    if (!(1 & OM_stat & *EMmsg) AND OM_W_UNKNOWN_MSG ISNT OM_stat)
    {
        goto wrapup;
    }
 }

 OM_stat = OM_S_SUCCESS;

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EFsetsfstate")
  return;
}
end implementation EMSdpr;
