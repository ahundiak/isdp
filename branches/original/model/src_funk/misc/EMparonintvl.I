/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    Given a parameteric value, this function determines whether it truly lies
    within a given parametric interval on a given edge; and if it does lie
    within this edge-interval, whether it is at the start, middle or at the
    stop point of the interval. The parametric basis tolerance for this 
    decision is passed in. If the bounds of the edge in uv-space (endpoints)
    are known these should be passed in. Else this function gets them through
    a message send. Likewise, if the uv-point corresponding to the paramter to
    be tested is known, it should be passed in.
    
  ARGUMENTS

    edgeid		- Input: The object-id of the edge in question.
                          Can be NULL_OBJID if startpt, stoppt and pt
                          are provided and a valid tolerance in the
                          partol_basis structure is provided.

    startpar, startpt	- Input: The beginning of the edge-interval in
			  the edge's paramteric space (w-space) and in
                          it's real space (uv-space), respectively. 
                          "startpt" could be NULL.

    stoppar, stoppt	- Input: The end of the edge-interval in
			  the edge's paramteric space (w-space) and in
                          it's real space (uv-space), respectively. 
                          "stoppt" could be NULL. 

    par, pt		- Input: The parameter and the corresponding uv-point
                          to be tested. "pt" could be NULL.
                          
    partol_basis	- Input: The parameteric basis tolerance with respect
                          to which this check needs to be made.

    on_interval		- Output: Flag that indicates if the input
                          to be tested lies outside or on the edge.

    in_middle		- Output: If on_interval is TRUE, this flag indicates
                          whether the input is in the middle of the edge.

    on_start		- Output: If in_middle is FALSE (and of course
                          on_interval is TRUE), this flag indicates whether
                          the input is at the start or the stop point
                          of the edge.

  RETURN VALUE

    The function returns a Boolean value of TRUE or FALSE, depending
    on whether the input paramter/point lay on the edge or not.

    Upon return the completion code (msg) will be one of the following:

      Success codes:
      - EMS_S_Success
          if succeeded. Always successful when the all the 'points' are
          given and the 'partol_basis' has a valid tolerance in it.

      Error codes:
      - EMS_E_EdgeError
          if a failure occurred in an edge-method that was invoked
      - EMS_E_OMerror
          if any other failure occurred during a message invocation

  ALGORITHM

    The uv-endpts are used to do a uv-distance check. No attempt to trivially
    determine the state by using "W-tolerance" is made.
    
  HISTORY

    SS  :  03/01/87  :  Creation
    SS  :  11/18/87  :  Removed the code that used W-par tolerance to
                        trivially determine the status. Now, no trivial
                        check is done. Has become a little slower but
                        much more accurate.

*/

class implementation EMSedge;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

IGRboolean EMpar_on_edintvl (msg, edgeid, startpar, startpt, stoppar, stoppt,
                             par, pt, partol_basis, 
                             on_interval, in_middle, on_start)
IGRlong *msg;
GRobjid edgeid;
struct EMSedgebound *startpar, *stoppar, *par;
IGRdouble *startpt, *stoppt, *pt;
struct EMSpartolbasis *partol_basis;
IGRboolean *on_interval, *in_middle, *on_start;
{
  IGRboolean reversed, surely_on_interval, possibly_on_start; 
  IGRint stat_OM;
  IGRlong msg_loc;
  IGRdouble startval, stopval, inval, tempval;
  IGRdouble inpt_mem[2], endpt_mem[2], *temppt;
  IGRdouble lentol, lentolsq;
  GRobjid dumid;
  struct EMSedgebound *tempend;
  IGRboolean EFextract_par();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (!partol_basis->is_valid)
    {
    stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
               &dumid, partol_basis), targetid = edgeid, 
               senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
    }
  partol_basis->is_valid = TRUE;
  EFextract_par (BSTOLLENVEC, partol_basis->tol, &lentol, &msg_loc);

  startval = startpar->span_inx + startpar->param;
  stopval = stoppar->span_inx + stoppar->param;
  if (startval > stopval)
    {
    reversed = TRUE; 
    tempend = startpar;
    startpar = stoppar;
    stoppar = tempend;
    tempval = startval;
    startval = stopval;
    stopval = tempval;
    temppt = startpt;
    startpt = stoppt;
    stoppt = temppt;
    }
  else
    reversed = FALSE;
  inval = par->span_inx + par->param;

  *on_interval = FALSE;
  *in_middle = FALSE;
  *on_start = FALSE;

  if (inval >= startval && inval <= stopval)
    surely_on_interval = TRUE;
  else
    {
    surely_on_interval = FALSE;
    if (startval - inval > 0)
      possibly_on_start = TRUE;
    else
      possibly_on_start = FALSE;
    }

  /*
   * Until a better, faster logic can be developed, the 
   * end-points and the input param are evaluated and tested
   * for closeness. If the input parameter was not readily recognized
   * as on interval, it has atleast been judged as possibly lying either on
   * the start of the interval or at the end. This judgement cannot be
   * violated. It takes on special significance in the case of closed
   * edges, when ambiguity can arise at the common-endpoint.
   */
   
  if (! pt)
    {
    pt = inpt_mem;
    stat_OM = om$send (msg = message EMSedge.EMptatpr (&msg_loc, 1, 
               par, NULL, pt), targetid = edgeid, senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
    }

  if (! startpt)
    {
    startpt = endpt_mem;
    stat_OM = om$send (msg = message EMSedge.EMptatpr (&msg_loc, 1,
               startpar, NULL, startpt), targetid = edgeid, 
               senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
    }

  lentolsq = lentol * lentol;

  if (EM2ddistptpts (pt, startpt) < lentolsq &&
      (surely_on_interval ? TRUE : possibly_on_start))
    {
    *on_interval = TRUE;
    *in_middle = FALSE;
    *on_start = reversed ? FALSE : TRUE;
    }
  else
    {
    if (! stoppt) 
      {
      stoppt = endpt_mem;
      stat_OM = om$send (msg = message EMSedge.EMptatpr (&msg_loc, 1,
                 stoppar, NULL, stoppt), targetid = edgeid, 
                 senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
      }

    if (EM2ddistptpts (pt, stoppt) < lentolsq &&
        (surely_on_interval ? TRUE : !possibly_on_start))
      {
      *on_interval = TRUE;
      *in_middle = FALSE;
      *on_start = reversed ? TRUE : FALSE;
      }
    else
      {
      /*
       * The input parameter is definitely not at the endpoints
       * of the given interval. But if, earlier it had been detected
       * that the input parameter is within the interval, then it is
       * in the middle.
       */

      if (surely_on_interval)
        {
        *on_interval = TRUE;
        *in_middle = TRUE;
        *on_start = FALSE;
        }
      }
    }

ret_end:
  if (EMSerror (stat_OM) && (! EMSerror (*msg)))
    *msg = EMS_E_OMerror;
  EMWRAPUP (*msg, stat_OM, "EMpar_on_edintvl");
  return (*on_interval);
}

end implementation EMSedge;
