/*
  DESCRIPTION 

    This is a layer on top of the co$getevent. It's job is to shield command
    objects from the idea of expressions being used in place of values.
    All characteristics remain the same as far as getevent is concerned,
    except that this filter is now able to accept expression-definitions
    as valid input wherever a double-value is asked for.

    Since an expression-definition is syntactically no different than a
    string or a command invocation, there is precedence rule that takes
    affect: Every string is first tried as an expression whenever a value
    is requested. xy=, dx= and di= (commands cased out in the function
    EMis_command_keyin) are exceptions to this rule. The filter
    on finding this syntax leaves things alone. When the string does not
    make sense as an expression, the filter again leaves things alone.

    This function also handles the new mask GRm_PLNDATA, which is a data
    point lying on the active reference plane. If no ref plane is active
    no data-point is returned. If the ref-plane is edge-on in the window
    in which the data point was input, no data point is returned.

  NOTES

    A value, when keyed in as syntax for an expression, returns a double value
    as if the value was keyed-in. The response to the caller is returned
    as EX_VALUE. Except that an expression object may be found in the
    located_object[0] field. If a plain, vanilla value was keyed-in by
    the user, the located_object[0] is NULL_OBJID.

  HISTORY
    DLB :  04/15/91  :  Keyin of variable w/o an rhs (rad1) resulted in
                        UNKNOWN.  Happens because EXP_extract_lhs_rhs returns
                        the variable as the rhs and lhs is NULL.  So, if such a
                        case, move the rhs into the lhs.  What about "=rad1",
                        or "=10".  Siki says there is some function that can be
                        called to verify valid syntax.  When we have this
                        function it should be added before the
                        EXP_extract_lhs_rhs call. 
    SS  :  03/08/91  :  Creation. Argument list exactly the same as COgetevent.
    HGB :  07/15/92  :  Equational constraints support.
    Sudha  06/30/93  :  Modified for BSprototypes ansification

*/

class implementation expression;

#include <string.h>
#include "OMmacros.h"
#include "exdef.h"
#include "ex.h"
#include "expression.h"
#include "expmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "EMSobjmgrdef.h"
#include "EMSasnucdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bsparameters.h"
#include "adpdef.h"
#include "bserr.h"
#include "bsproj1.h"

#include "actparam.h"

static IGRboolean aflag;

#define MATCH  0

#define STRING_MASK (GRm_STRING | GRm_TEXT_VALUE)
#define VALUE_MASK (GRm_VALUE | GRm_SCALAR | GRm_DIST | GRm_ANGLE)

#define EMonerror(sts, label) if (EMSerror (sts)) goto label;

from FIdirform import update;
from EMSdatpln import EMget_pln_info;

long EMgetevent ( ReturnMsg,
                    ScaleFlag,
                    EventMask,
                    EventSize,
                    Prompt,
                    MsgNumber,
                    MsgName,
                    ValueType,
                    Mode,
                    nbytes,
                    response,
                    response_data,
                    Event )
                         /* Notation:  (-) output; (+) input;          */
long  *ReturnMsg;        /* (-) return information code                */
long   ScaleFlag;        /* (+) flag specifying what kind of scaling   */
                         /*     (if any) is applied to values returned */
long   EventMask;        /* (+) mask indicating types of event wanted  */
long   EventSize;        /* (+) size of memory allocated for event     */
char  *Prompt;           /* (+) Prompt issued before waiting for input */
long   MsgNumber;        /* (+) if Prompt not specified, this is index */
                         /*     in the message subsystem               */
char  *MsgName;          /* (+) name of message used as a prompt       */
char  *ValueType;        /* (+) value type identifier string           */
long   Mode;             /* (+) mode for getting keyboard input        */
int   *nbytes;           /* (-) nbr of bytes returned in response_data */
long  *response;         /* (-) response type from Exec's WFI          */
char  *response_data;    /* (-) response data from Exec's WFI          */
struct GRevent  *Event;  /* (-) returned event                         */
{
  IGRboolean      lookup_expression, string_already_requested;
  IGRboolean      good_expr, expr_created, syntax_only;
  char            keyin [DI_PATH_MAX], name [DI_PATH_MAX], syntax [DI_PATH_MAX];
  char            statusmsg [GR_MAX_CHAR];
  int             bytes_in, bytes_out, dum, ref_lock_state, gragad_flags;
  long            getevent_status, stat_func, msg_loc, local_EventMask;
  double          val, *dptr;
  IGRpoint        datpln_origin;
  IGRvector       datpln_normal;
  GRobjid         expid, gragad_objid;
  GRspacenum      expos;
  struct GRid     datplnid;
  struct GRmd_env md_env;
  struct GRid     *event_grid;
  struct var_list var_list [2];
  IGRboolean      EMis_command_keyin ();

  *ReturnMsg = MSSUCC;
  getevent_status = MSSUCC;

  /*
   * If a value is requested, make sure a string is also being asked
   * for. If a value is being requested, also make sure that the 
   * located_object[0] is initialized to a NULL_OBJID, as this is going to be
   * interpreted on a return of EX_VALUE, by the caller.
   */

  lookup_expression = FALSE;
  local_EventMask = EventMask;

  if (EventMask & VALUE_MASK)
  {
    if (! (EventMask & STRING_MASK))
    {
      local_EventMask |= GRm_STRING;
      string_already_requested = FALSE;
    }
    else
      string_already_requested = TRUE;

    event_grid = &Event->located_object[0].located_obj;
    event_grid->objid = NULL_OBJID;
    lookup_expression = TRUE;
  }

  /*
   * If a data point on a reference plane is being requested, call the
   * co$getevent function with the regular data point call. This then can
   * be further doctored.
   */

  if (EventMask & GRm_PLNDATA)
    local_EventMask |= GRm_DATA;

  /*
   * Call the co$getevent macro
   */

  getevent_status = co$getevent (msg = ReturnMsg, scale_flag = ScaleFlag,
      event_mask = local_EventMask, event_size = EventSize,
      prompt = Prompt, msgnum = MsgNumber,
      msgname = MsgName, value_type = ValueType,
      mode = Mode, nbytes = nbytes, response = response,
      response_data = response_data, event = Event);
  if (EMSerror (getevent_status & *ReturnMsg))
    goto ret_end;

  /*
   * If a string is found, and is found to be a valid expression string,
   * create an expression out of it. The expression object is then stored
   * in the located_object[0] field. The expression string could be one of
   * the following types:
   * 1) a = b + c * 10
   * 2) b
   * 3) b + c * 10
   * In case (1) an expression object with a directory entry-name of 'a'
   * is created with the associated syntax (subtype is GRst_v_NEWEXPR).
   * In case (2), a pre-existing expression object of a directory-entry
   * name 'b' is expected (subtype is GRst_v_OLDEXPR). And, in case (3) a
   * temporary shell expression object is used to store and parse this syntax
   * (subtype is GRst_v_SYNTAX).
   * If the string turns out not to be a valid expression the response is
   * returned as EX_STRING;
   */

  if (lookup_expression && Event->response == EX_STRING)
  {
    strcpy ( keyin, Event->event.keyin );
    good_expr = FALSE;

    if (strlen ( keyin ))
    {
/** RFA - Will require a change here **/

      bytes_in = sizeof ( struct GRmd_env );
      gr$get_module_env ( msg = &msg_loc, sizbuf = &bytes_in, 
          buffer = &md_env, nret = &bytes_out );
      EMerr_hndlr ( EMSerror ( msg_loc ), getevent_status, MSFAIL, ret_end );
      expos = md_env.md_id.osnum;
      expr_created = FALSE;
      syntax_only = FALSE;
      
      stat_func = di$translate ( objname = keyin, p_objid = &expid, p_osnum = &expos );
      if (stat_func == DIR_S_SUCCESS)
        good_expr = TRUE;
      else
        if (!EMis_command_keyin ( keyin ))
        {
          int call_create = 0;
          
          if (strchr ( keyin, '=' ))
          {
            strcpy ( syntax, keyin );
            call_create = 1;
          }
          else
            if (strchr ( keyin, '+' ) || strchr ( keyin, '-' ) || strchr ( keyin, '/' ) ||
                strchr ( keyin, '*' ) || strchr ( keyin, '(' ) || strchr ( keyin, '%' ))
            {
              EMdefnewname ( name, md_env.md_id.osnum, EMSdistance );
              sprintf ( syntax, "%s=%s", name, keyin );
              syntax_only = TRUE;
              call_create = 1;
            }

          if (call_create)
          {
            stat_func = exp$create ( exp_name = NULL, exp_syntax = syntax,
               osnum = expos, p_exp_id = &expid );
            if (stat_func & 1)
            {
              DIupdate_form ();
              expr_created = TRUE;
              good_expr = TRUE;
            }
          }
        }

      if (good_expr)
      {
        stat_func = om$send (msg = message expression.give_formula ( statusmsg ),
            targetid = expid, targetos = expos, senderid = NULL_OBJID );
        if (!EMSerror ( stat_func ))
        {
          BSrc BSmsg=BSSUCC;
          double lentol=0;

          stat_func = om$send (msg = message expression.NDgive_value ( &val ),
              targetid = expid, targetos = expos, senderid = NULL_OBJID );

          BSEXTRACTPAR (&BSmsg, BSTOLLENVEC, lentol);

          if (!EMSerror ( stat_func ) && (val < (GR_MAXDOUBLE - lentol)))
          {
            UI_status ( statusmsg );
  
            Event->response = EX_VALUE;
            Event->nbytes = sizeof (double);
            Event->event.value = val;
            Event->num_id = 1;
            Event->num_val = 0;
            if (expr_created)
              Event->subtype = GRst_v_NEWEXPR;
            else 
              if (syntax_only)
                Event->subtype = GRst_v_SYNTAX;
              else
                Event->subtype = GRst_v_OLDEXPR;
  
            Event->values[0] = val;
            event_grid->objid = expid;
            event_grid->osnum = expos;
          }
          else
            good_expr = FALSE;
        }
        else
          good_expr = FALSE;
      }
    }

    if (!good_expr && !string_already_requested)
      Event->response = GR_UNKNOWN_TYPE;
  }
  else 
  if (local_EventMask & GRm_PLNDATA && Event->response == EX_DATA)
  {
    /*
     * If a ref-plane point is requested and the user response is a 
     * data point, make sure that the point lies on the ref-plane. Edge-on
     * condition is treated as an unknown-type.
     */
    ref_lock_state = NULL;
    ems$ref_plane_lock ( msg = &msg_loc, options = EMS_REF_PLANE_LOCK_INQ,
        mode = &ref_lock_state );
  
    if (ref_lock_state & EMS_REF_PLANE_LOCK_ON)
    {
      gragad_objid = Event->event.button.objid;
      if (!IF_NULL_OBJID (gragad_objid))
      {
        var_list[0].var = GRAGAD_FLAGS;
        var_list[0].var_ptr = (char *) &gragad_flags;
        var_list[0].num_bytes = sizeof (int);
        var_list[0].bytes_returned = (IGRlong *) &bytes_out;
  
        var_list[1].var = END_PARAM;
        var_list[1].var_ptr = NULL;
        var_list[1].num_bytes = 0;
        var_list[1].bytes_returned = NULL;
  
        stat_func = dp$inq_set_gragad (msg = &msg_loc,
           osnum = Event->event.button.osnum, 
           gragad_objid = gragad_objid, which_error = &dum,
           var_list = var_list);
        if (!EMSerror (stat_func & msg_loc))
        {
          if (!(gragad_flags & CONST_PLANE_ON))
          {
            Event->response = GR_UNKNOWN_TYPE;
            ex$message (msgnumb = EMS_S_InactiveRefPlninWindow);
            sleep(1);
          }
          else if (!(gragad_flags & VALID_ALT_INV))
          {
            Event->response = GR_UNKNOWN_TYPE;
            ex$message (msgnumb = EMS_S_OrthoRefPlaneinWindow);
            sleep(1);
          }
        }
      }
  
      aflag = pwIsActivationOn();
     
      if (Event->subtype != GRst_REGULAR /*&& !aflag*/)
      {
        datplnid.objid = NULL_OBJID;
        ems$get_active_datum_plane (msg = &msg_loc, datpln = &datplnid);

        if (!IF_NULL_OBJID (datplnid.objid))
        {
          struct GRmd_env rfenv;
          if(aflag)
          {
            pwGetActiveModuleEnv(&rfenv);
          }
       
          stat_func = om$send (msg = message EMSdatpln.EMget_pln_info 
              (&msg_loc, NULL, aflag ? &rfenv : NULL, NULL, NULL, datpln_normal,
              datpln_origin, NULL), targetid = datplnid.objid, 
              targetos = datplnid.osnum, senderid = NULL_OBJID);
          if (!EMSerror (stat_func & msg_loc))
          {

            dptr = &Event->event.button.x;
            BSproj1 (&msg_loc, dptr, datpln_normal, datpln_origin, dptr);
          }

        }
      }
    }
    else
      Event->response = GR_UNKNOWN_TYPE;
  }
  else 
    /*
     * If the input was simply a value key-in, indicate this with
     * the appropriate sub-type.
     */
    if (Event->response == EX_VALUE)
      Event->subtype = GRst_v_REGULAR;

ret_end:
  if (EMSerror ( getevent_status ))

  *ReturnMsg = MSFAIL;
  return getevent_status;
}



/*
 * The following function checks the incoming string to be a common
 * command keyin. If yes, then the function returns TRUE, else a FALSE.
 */

IGRboolean EMis_command_keyin ( str )
char *str;
{
  char loc_str [GR_MAX_CHAR];
  int i, len;

  /*
   * A commonly occurring set of command keyins are specially recognized
   * and will not be created or as expressions when they occur on the
   * left-hand side of an expression relationship.
   */
  strcpy (loc_str, str);
  len = strlen (loc_str);
  for (i=0; i<len; i++)
    toupper (loc_str[i]);

  if (strcmp (str, "XY") == MATCH ||
      strcmp (str, "DX") == MATCH ||
      strcmp (str, "DI") == MATCH ||
      strcmp (str, "DL") == MATCH)
    return TRUE;
  else
    return FALSE;
}


end implementation expression;
