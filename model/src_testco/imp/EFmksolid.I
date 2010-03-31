/* ###################   APOGEE COMPILED   ################## */
/*
Description
   This function will convert a composite surface into a solid.

Algorithm
   o If EMS_VERIFT_CLOSURE option then:
       Display the incoming composite's stitchable edges.
       If any stitchable edges return success.

   o If EMS_ASK_CONVERT option then:
       Ask user if the composite should be converted to a solid.
       If no return success.

   o Change the class to incoming class name.
 
   o If EMS_GOOD_ORIENT option then:
       Normals are oriented correctly so return success.

   o Send EMorient_solid message to new solid to orient surfaces correctly.

   o If successful then return success.

   o Show normals.

   o Ask user if surface orientation is correct.

   o If not toggle normals.

   o Return success.
       
Return values
   EMS_S_SUCCESS    if all is well.
   EMS_I_NoResponse if input composite surface has stitchable edges (open).
   
   If no input is taken by this function then the event->response field
   will contain a string event.
                    
Notes
   If the composite surface has stitchable edges then these edges will be
   displayed by this function.  It is left up to the caller to dehilite
   these edges.

History 
   DLB  12/16/87  Creation.
   RV   03/18/88  Added test-degeneracy for open edges.
   DLB  09/01/88  Added <CR> and MOVE_ON as default responses at 
                  getevent processing code.
   SM   26-Oct-88 Fixed following -
                  If some of the connectable edges were degenerate then
                  their degenerate property was not being set. This property
                  was being set only if all connectable edges were
                  degenerate. Now I modified it so that as soon as an edge
                  is found to be degenerate it is marked as such.
   SM   06-Feb-89 Display the connectable edges after the degeneracy
                  test has been performed. This is to avoid an edge
                  being shown to the user as connectable and then declared
                  degenerate.
   SM   23-May-89 Added argument 'cvrt_prompt'. This is the prompt used in
                  conjunction with the option EMS_ASK_CONVERT. If NULL the
                  default prompt will be used.
   DLB  03/13/92  Broke out non-degen stitchable edge check into a function
                  since this must also be done when recomputing dpr ops.
Rustagi 06/02/92  Modified for Message Sub-system Compliance
Sudha   07/05/93  Modified for BSprototypes ansification

*/

class implementation EMScompsurf;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#include <stdio.h>
#include <string.h>
#include "ems_m_inc.h"
#include "griodef.h"
#include "exdef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "EMSbnddef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSlmdef.h"
#include "bsparameters.h"
#include "bserr.h"
#include "msmacros.h"
#include "EC_S.h"
#include "bschangepar.h"

from EMSsolid import EMorient_yourself;
from EMSedge import EMset_props, EMtst_degn, EMdisplay;

IGRint EFmksolid(EMmsg, env, display, compositeid, event, response,
                 response_data, token_array, options, newclass, cvrt_prompt)
IGRlong           *EMmsg;
struct GRmd_env   *env;
struct IGRdisplay *display;
struct GRid       *compositeid;
struct GRevent    *event;
IGRint            *response;
IGRchar           *response_data;
IGRint            *token_array;
IGRushort options;
char              *newclass, *cvrt_prompt;

{
 IGRlong       eventmsg, OM_stat;
 IGRint        event_size = sizeof(struct GRevent), token;
 IGRint        event_mask, edge_count;
 IGRboolean    no_event_gotten = TRUE, stitchable;
 extern IGRboolean EFcomp_stitchable();

 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 if (options & EMS_CHECK_CLOSURE)
 {
   stitchable = EFcomp_stitchable(EMmsg, 
                                  compositeid->objid, compositeid->osnum, 
                                  env,
                                  NULL, NULL);
   if (!(1 & *EMmsg)) goto wrapup;

   if (stitchable)
   { 
     OM_stat = om$send(msg = message EMSsurface.EMdisplay_edges(EMmsg, env,
                           EMS_OPT_CONNECTABLE, GRhd, &edge_count),
                     senderid = NULL_OBJID,
                     targetid = compositeid->objid,
                     targetos = compositeid->osnum);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;

     ex$message(msgnumb = EMS_S_ConnEdhilite);

     ems_sleep(2);

     *EMmsg = EMS_I_NoResponse; 
     goto wrapup;
   }
 } /* if (options & EMS_CHECK_CLOSURE) */

 if (options & EMS_ASK_CONVERT)
 {
   /* Ask user if composite surface should be converted into a solid.*/
   
   if(cvrt_prompt)
     ex$message(field=PROMPT_FIELD, justification=RIGHT_JUS,
                in_buff=cvrt_prompt)
   else
     ex$message( msgnumb = EMS_P_CompsfToSolid);
   event_mask = GRm_STRING | GRm_BACK_UP | GRm_RJT_MOVEON;
   token = GRget_token(&eventmsg, token_array, &event_mask, event,
                       &event_size, response, response_data);
   ex$message(msgnumb = EMS_P_ClearPromptField);
    
   no_event_gotten = FALSE;

   if (event->response == EX_RJT_MOVEON || eventmsg == GRw_no_value)
   {
     /*<CR> or MOVE_ON was given (meaning take default) so pretend user
      * said 'y'.
      */
     event->response = STRING;
     *response = STRING;
     strcpy(event->event.keyin, "Y");
     strcpy(response_data, "Y");                    
     token = GRloc_token(&eventmsg, token_array, event);
   }

   if (token_array[token] == GR_UNKNOWN_TYPE) goto wrapup;
   
   if (token_array[token] == STRING)
     if (toupper (event->event.keyin[0]) == 'N') goto wrapup;

   if (token_array[token] == EX_BACK_UP) goto wrapup;
 }

 ex$message(msgnumb = EMS_I_00003);
 OM_stat = om$change_class(objid = compositeid->objid,
                           osnum = compositeid->osnum,
                           classname = newclass);
 if (!(1 & OM_stat)) goto wrapup;     

 if (options & EMS_GOOD_ORIENT) goto wrapup;

 ex$message(msgnumb = EMS_S_Processing);
 OM_stat = om$send(msg = message EMSsolid.EMorient_yourself(EMmsg, NULL,
                         env),
                   senderid = NULL_OBJID,
                   targetid = compositeid->objid,
                   targetos = compositeid->osnum);
 if (1 & OM_stat & *EMmsg) goto wrapup;  /*If all is well then quit.*/

 ex$message(msgnumb = EMS_S_AutoRntFail);

 OM_stat = om$send(msg = message EMSsurface.EMshow_normals(EMmsg, env, 
                         display, GRhd), 
                   senderid = NULL_OBJID,
                   targetid = compositeid->objid,
                   targetos = compositeid->osnum);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 do
 {
   ex$message(msgnumb = EMS_P_CorrectSurfOrnt);

   event_mask = GRm_STRING | GRm_RJT_MOVEON;
   token = GRget_token(&eventmsg, token_array, &event_mask, event,
                       &event_size, response, response_data);
   ex$message(msgnumb = EMS_P_ClearPromptField);
    
   if (event->response == EX_RJT_MOVEON || eventmsg == GRw_no_value)
   {
     /*<CR> or MOVE_ON was given (meaning take default) so pretend user
      * said 'y'.
      */
     event->response = STRING;
     *response = STRING;
     strcpy(event->event.keyin, "Y");
     strcpy(response_data, "Y");                    
     token = GRloc_token(&eventmsg, token_array, event);
   }
 } while (token_array[token] != STRING);

 no_event_gotten = FALSE;

 OM_stat = om$send(msg = message EMSsurface.EMshow_normals(EMmsg, env,
                         display, GRhe), 
                   senderid = NULL_OBJID,
                   targetid = compositeid->objid, 
                   targetos = compositeid->osnum);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 if (toupper (event->event.keyin[0]) == 'N') 
 {
   OM_stat = om$send(msg = message EMSsurface.EMrevorient(EMmsg),
                     senderid = NULL_OBJID,
                     targetid = compositeid->objid,
                     targetos = compositeid->osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }

 wrapup:
  if (no_event_gotten)
  { 
    /*Simulate a string event*/
    event->response = STRING;
  }
  ex$message(msgnumb = EMS_S_ClearStatusField);
  EMWRAPUP (*EMmsg, OM_stat, "EFmksolid")
  return (OM_stat);
}

/*DL function 3/13/92.
 * no options so far...
 * num_stitchable can be passed as NULL if not wanted.
 */
IGRboolean EFcomp_stitchable(EMmsg, compid, compos, env, num_stitchable,
                             options) 
IGRlong         *EMmsg;
GRobjid         compid;
OMuword         compos;
struct GRmd_env *env;
IGRint          *num_stitchable;
OMuword         options;
{
  IGRlong       OM_stat=OM_S_SUCCESS, rc=BSSUCC;
  IGRboolean    is_degen, reset_disq_tol=FALSE;
  struct GRid   *edges=NULL;
  IGRint        ix, buf_size=0, edge_count=0, num_degen=0;
  IGRdouble     disq_tol, cht_tol;


  *EMmsg = EMS_S_Success;
                                   
  OM_stat = om$send(msg = message EMSsurface.EMgetedges(EMmsg,
                          EMS_OPT_CONNECTABLE, &edges, &buf_size,
                          &edge_count, NULL, NULL, NULL, NULL),
                    senderid = NULL_OBJID,
                    targetid = compid,
                    targetos = compos);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (edge_count)
  {
    /*
     * need to do the test for degeneracy with cht_tol instead of 
     * dis_tol. Since the math function BStstcvdegn uses BSTOLSQLENVEC,
     * change that to cht_tol*cht_tol, temporarily.
     */
    BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht_tol);
    if (rc != BSSUCC) goto wrapup;

    BSEXTRACTPAR(&rc, BSTOLSQLENVEC, disq_tol);
    if (rc != BSSUCC) goto wrapup;

    reset_disq_tol = TRUE;

    BSchangepar(&rc, BSTOLSQLENVEC, cht_tol*cht_tol);
    if (rc != BSSUCC) goto wrapup;

    for (ix=0; ix<edge_count; ix++)
    {
      OM_stat = om$send(msg = message EMSedge.EMtst_degn(EMmsg, NULL,
                              NULL_OBJID, &env->md_env, &is_degen),
                        senderid = NULL_OBJID,
                        targetid = edges[ix].objid,
                        targetos = edges[ix].osnum);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (is_degen)
      {
        OM_stat = om$send(msg = message EMSedge.EMset_props (EMmsg,
                                EMED_DEGENERATE, EMS_O_ON),
                          senderid = NULL_OBJID,
                          targetid = edges[ix].objid,
                          targetos = edges[ix].osnum);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        num_degen++;
      }
    }

    if (num_degen == edge_count) edge_count = 0;

  } /* if edge_count*/

  if (num_stitchable) *num_stitchable = edge_count;

wrapup:
  if (reset_disq_tol)
  {
    BSchangepar(&rc, BSTOLSQLENVEC, disq_tol);
  }
  if (edges) om$dealloc(ptr = edges);
  EMWRAPUP(*EMmsg, OM_stat, "EFcomp_stitchable")
  return(edge_count!=0);
}
end implementation EMScompsurf;


