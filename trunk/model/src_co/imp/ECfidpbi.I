/* ###################   APOGEE COMPILED   ################## */

class implementation ECfidpb;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "exdef.h" /* For CLEAR_STACK */
/* *************************************************************************

 Description 
   This file contains implementation for 
    execute : This method displays the form and exits.
    wakeup,
    sleep : return success

 History
  scw : 08/14/94              Clarified sleep method
  msm : 04/03/91              Changed to c_based form.
   pp : 01/24/90              Made the co$getevent expect a form finished
                              instead of a data point.
   PP : 06/08/89              Rigged the command object so that whenever
                              the user enters a clear stack the form is
                              dismissed to enable ATPS for certification.
   PP : 04/28/88              Redesigned the command object to allow
                              for the conversion of form to a window. Before
                              the command object was servicing the form. Now
                              the dpb object services the form.
   PP : 02/22/88              Added code to disenable writing to
                              the message fields, to fix the 
                              whitening of the fields during exit
   PP : 10/27/87                   Creation

   ************************************************************************* */
   
#include "ems_m_inc.h"			/* Includes everything */
#include "griomacros.h"
#include "msmacros.h"                   /* for ms$onoff */
#include "EMSerrordef.h"                /* EMSerror defintions */
#include "EC_I.h"                       /* Informational include file */
#include "EMSdpb.h"                     /* EMSdpb declarations */
#include "igewinmacros.h"               /* For ige$SR_active */
#include "exdef.h"                      /* For EX_RESPONSE_DATA_SIZE */
#include "FI.h"

#define DEBUG 0
#if DEBUG
 #include <stdio.h>
#endif


from EMSdpb import EMupdate_form, is_displayed,
            disp_form, erase_form;

method super_cmd.sleep (int pos)
{
 return (OM_S_SUCCESS);
}

method wakeup (int pos)
{
 return (OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
 IGRlong EMmsg,status;
 struct GRid dpbid;
 IGRint displayed;
 IGRint buf_size;
 struct GRevent ret_event;
 IGRshort prevstate, oldstate;

 status = OM_S_SUCCESS;
 EMmsg = EMS_S_Success;

          
 ms$onoff(msg = &EMmsg,
          prevstate = &prevstate,
          type = MS_OFF);
#if DEBUG
EFprintcode(0,EMmsg);
fprintf(stderr, "%d oldstate \n", prevstate);
#endif

 oldstate = prevstate;

 EMget_dpbobjid (&EMmsg, &dpbid.objid, &dpbid.osnum);
 if (!(1&EMmsg)) 
 {
  *response = TERMINATE;
  return (OM_E_ABORT);
 }

 status = om$send (msg = message EMSdpb.is_displayed (&EMmsg, &displayed),
                   targetid = dpbid.objid,
                   targetos = dpbid.osnum);
 if (!(1&EMmsg&status))
 {
  return (OM_E_ABORT);
 }

 if (displayed)
 {
  ex$message(msgnumb = EMS_I_00083); /* Form has been displayed */
  *response = TERMINATE;
  return (OM_S_SUCCESS);
 }
 status = om$send (msg = message EMSdpb.EMupdate_form (&EMmsg),
                   targetid = dpbid.objid,
                   targetos = dpbid.osnum);
 if (!(1&EMmsg&status)) 
 {
  return (OM_E_ABORT);
 }

 status = om$send (msg = message EMSdpb.disp_form (&EMmsg),
                   targetid = dpbid.objid,
                   targetos = dpbid.osnum);
 if (!(1&EMmsg&status))
 {
  return (OM_E_ABORT);
 }
/*
 * Wait for input due to save restore craziness. 
 */

 *response = 0;
 while (ige$SR_active() && !(*response == CLEAR_STACK))
 {
  status = co$getevent (
    msg = &EMmsg,
    event_mask = GRm_FORM_FINISHED,
    response = response,
    response_data = response_data,
    event = &ret_event);
 }

/*
 * Rig the command object to help certification people so that
 * they can dismiss the form in case the form is save restore and
 * the response on the q is clear_stack.
 * pp (06/06/89)
 */

 if (ige$SR_active() && (*response == CLEAR_STACK))
 {
  status = om$send (msg = message EMSdpb.erase_form(&EMmsg),
                   targetid = dpbid.objid,
                   targetos = dpbid.osnum);
 if (!(1&EMmsg&status))
 {
  return (OM_E_ABORT);
 }
 }
 else
  *response = TERMINATE;

 ms$onoff(msg = &EMmsg,
          prevstate = &prevstate,
          setstate = oldstate,
          type = MS_SET);

#if DEBUG
 EFprintcode(0,EMmsg);

fprintf(stderr, "%d state \n", prevstate);
#endif
 return (OM_S_SUCCESS);
}
end implementation ECfidpb;
