/*

Name
  COchexpi.I

Abstract

Synopsis

Description
  Routines for the change expression command

Return Value

Notes

Index

Keywords
  associative,parameters,expression

History
  03/25/93 : Rajiv Agrawal : Restore the old syntax of the expression if an error occurs
             during the update of the dependents.

  04/13/94 : Sudha         : made purify fix
 */

class implementation COchexp;

#incude <string.h>
#include "OMmacros.h"
#include "OMerrordef.h"
#include "lcmacros.h"
#include "exmacros.h"
#include "parametric.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "expmacros.h"
#include "coparadef.h"
#include "AS_status.h"
#include "ASmessages.h"
#include "DImacros.h"
#include "madef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dpdef.h"
#include "dpmacros.h"


from expression import list, give_formula;
from GRgraphics import GRdisplay, GRgetprops;
from FIdirform  import update;

#define GET_TOKEN    0
#define GET_PARENT   1
#define GET_PARAM    2
#define NO_ENTRIES   3

#define NUM_TOKENS   5
#define NUM_STATES   3


enum possible_actions 
{
  NIL,
      ERR,
      GET_EXP,
      TSTRING_EXP1,
      GET_KEY,
      GTK_NST,
      T_VALUE,
      T_EXPR,
};

enum possible_states 
{
  AT_START,
      HAVE_PARA,
      HAVE_VALU
};

%safe
static int Tokens[] = 
{
  D_RESET,
  STRING,
  DATA,
  GR_UNKNOWN_TYPE,
  LOC_PARAM
};

static enum possible_states Newstate[NUM_STATES][NUM_TOKENS] = {
  {AT_START,  HAVE_PARA, AT_START,  AT_START,    HAVE_PARA},
  {AT_START,  HAVE_VALU, HAVE_PARA, HAVE_PARA,   HAVE_PARA},
  {HAVE_PARA, HAVE_VALU, HAVE_VALU, HAVE_VALU,   HAVE_VALU},
  /****************----------------------------------------------------------*/
};

static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {
  {GET_EXP , TSTRING_EXP1, NIL   ,     GET_EXP,     GET_KEY},
  {GET_EXP , T_VALUE     , NIL   ,     GET_KEY,     GET_KEY},
  {GET_EXP , T_EXPR      , NIL   ,     GET_KEY,     T_EXPR},
  /***************----------------------------------------------------------*/
};
%endsafe

#define  AS_DEBUG

/*
 *  init method   
 */
method init ( int type; char *string_ptr )

{
  /* initialise assoc */
  ASsuper_construct ();

  me->mytype = type;
  me->state = NIL;
  me->action = GET_EXP;
  me->locate_stack.num_entries = 0;

  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                  wakeup                                   */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
method wakeup(int Centring_Attribute; )
{
  UI_prompt("");
  UI_status("");
  ex$message( msgnumb = AC_M_ModExp);

  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                execute                                   */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
method execute ( int *response; char *response_data; int pos )
{
  struct    GRevent  acc_Event;
  int       resp, status;
  long      display_flag;
  long      EventSize;
  int       token, rc;
  long      msg;
  long      loc_Mask;
  long      eventmask;
  double    param_val;
  OMuword   ob_classid;
  char      formula [EXP_MAX_LEN], name [EXP_MAX_LEN], SavedSyntax [EXP_MAX_LEN];
  char      *value,*equal,*strchr(), *pString;

/*
 *  Next two lines are there to remove warnings during compile
 */
  token = -1;
  value = NULL;

  /*! *response    = TERMINATE; */

  EventSize    = sizeof(struct GRevent);
  ex$message( buff =  me->loc_prompt, msgnumb = AS_P_LocExp);
  ex$message( buff =  me->acc_prompt, msgnumb = AS_P_AccRej);
  ex$message( buff =  me->reloc_prompt, msgnumb = AS_E_EleNotFound);

  loc_Mask     = GRm_DATA | GRm_STRING | GRm_BACK_UP;
  eventmask    = GRm_DATA | GRm_STRING | GRm_BACK_UP | GRm_SPECIFIED_OBJ;
  display_flag = ELEM_HILIGHT | ALL_WINDOWS;
  *response    = TERMINATE;

  do
  {
    msg = OM_S_SUCCESS;
    switch (me->action)
    {
    case NIL: /*  NIL action */

      break;

    case ERR:
    case GET_EXP:    /*  get keyin or first LOCATE point */
      dp$erase_hilite ( msg = &msg );
      ex$message(msgnumb = AS_P_LocExp);
      me->input_requested = GET_PARAM;
      break;

    case TSTRING_EXP1: /*  a string has been entered */
      /* is there an equal sign */
      if(strcmp(response_data, "") != 0)
      {
        equal = strchr(response_data,'=');
        if(equal != NULL)
        { /*  name and value entered */
          *equal = '\0';
          value = equal+1;
          me->action = T_EXPR;
          me->state = HAVE_VALU;
          me->input_requested = NO_ENTRIES;
        }
        else
        { /*  just the name entered */
          me->action = GET_KEY;
          me->state = HAVE_PARA;
          me->input_requested = NO_ENTRIES;
        }

        /* Get now the objid of the expression */

        /* stupid user name*/

        di$cvt_name_from_input(u_path = response_data,
                               s_path = name);

        rc = di$translate( objname = name,
		           p_objid = &(me->locate_param).objid, 
                           p_osnum = &(me->locate_param).osnum );

	if ( rc != DIR_S_SUCCESS )
          rc = DIR_W_NAME_NOT_FOUND;
        else
        /* make sure that the guy is locatable and displayable */
        {
          long  msg;
          short props;

          /* make sure the guy is locatable AND displayable */
          status = om$send ( msg = message GRgraphics.GRgetprops ( &msg, &props ),
              senderid = NULL_OBJID,
              targetid = me->locate_param.objid,
              targetos = me->locate_param.osnum );
          if (!(status & 1) || !(props & GRIS_LOCATABLE) || !(props & GRIS_DISPLAYABLE))
            rc = DIR_W_NAME_NOT_FOUND;
        
	  if ( rc != DIR_W_NAME_NOT_FOUND )
          /* make sure we can modify that guy */
          {
             GRclassid        classid;
             extern GRclassid OPP_angl_pm_class_id, OPP_dist_pm_class_id, 
			      OPP_radius_pm_class_id;
          
              om$get_classid ( objid = me->locate_param.objid, 
    		               osnum = me->locate_param.osnum,
                               p_classid = &classid );

              if ((om$is_ancestry_valid ( subclassid = classid,
                   superclassid = OPP_radius_pm_class_id) == OM_S_SUCCESS) ||
                  (om$is_ancestry_valid ( subclassid = classid,
                   superclassid = OPP_angl_pm_class_id) == OM_S_SUCCESS) ||
                  (om$is_ancestry_valid ( subclassid = classid,
                   superclassid = OPP_dist_pm_class_id) == OM_S_SUCCESS))
                rc = DIR_W_NAME_NOT_FOUND;
          }
	}
      }
      else
        rc = DIR_W_NAME_NOT_FOUND;

      if(rc==DIR_W_NAME_NOT_FOUND)
      {
        me->action = GET_EXP;
        me->state = AT_START;
        me->input_requested = NO_ENTRIES;
        ex$message(msgnumb = AS_E_ExpNtF);
      }

      break;

    case GET_KEY: /*  expression not located by name */
      status = om$send( msg      = message expression.list( formula ),
          targetid = (me->locate_param).objid,
          targetos = (me->locate_param).osnum );
      /*  expression.list done */
      as$status(sts=status, msg= "COchexp.execute->expression.list" );
#define SIZE_MESS 55

      formula[SIZE_MESS-1] = '\0';
      UI_status( formula );

      {
        struct GRid   cur_mod;
        enum GRdpmode mode = GRhd;
        short         mtx_type;
        double        matrix [16];

        status = ex$get_cur_mod ( id = &cur_mod.objid, osnum = &cur_mod.osnum );
        as$status ();

        mtx_type = MAIDMX;
        MAidmx ( &msg, matrix );
        if (cur_mod.osnum == me->locate_param.osnum)
          om$send ( msg = message GRgraphics.GRdisplay ( &msg, &mtx_type, matrix, 
              &mode, &cur_mod ),
              senderid = NULL_OBJID,
              targetid = me->locate_param.objid,
              targetos = me->locate_param.osnum );
      }

    case GTK_NST: /*  get new exp value(NO status) */
      ex$message(msgnumb = AS_P_KNwExp);
      me->input_requested = GET_TOKEN;
      break;

    case T_VALUE: /*  treat the value entered */
      value = response_data;

    case T_EXPR: /*  treat the expression modification */
      {
        om$get_classid( objid = (me->locate_param).objid, 
            osnum = (me->locate_param).osnum,
            p_classid = &ob_classid );

        if(om$is_ancestry_valid ( subclassid = ob_classid,
            superclassname = "text_exp" ) == OM_S_SUCCESS)
          status = EXP_extract_string(value, value);
        else
          status = EXP_SUCCESS;
      }

      /*
       * Save the old syntax of the guy
       */
      om$send ( msg = message expression.give_formula ( SavedSyntax ),
        senderid = NULL_OBJID, targetid = (me->locate_param).objid,
        targetos = (me->locate_param).osnum );
      
      /*
       * Get rid of the value in [], we hate it, but we don't know any other way...
       */
      for (pString = &SavedSyntax [strlen ( SavedSyntax )]; pString != SavedSyntax;
           pString--)
        if (*pString == '[')
        {
          *(--pString) = '\0';
          break;
        } 

      if(   status == EXP_SUCCESS 
          && exp$modify ( exp_id = (me->locate_param).objid,
          osnum  = (me->locate_param).osnum,
          exp_syntax = value ) == EXP_S_SUCCESS)
      {
        long        msg;
        struct GRid grid;
        
        grid.objid = (me->locate_param).objid;
        grid.osnum = (me->locate_param).osnum;        

        dp$display ( msg = &msg, oids = &grid );
        me->action = GET_EXP;
        me->state = AT_START;
        me->input_requested = NO_ENTRIES;

        ex$message(msgnumb = AS_S_ExpMod);
      }
      else
      {
        me->action = GTK_NST;
        me->state = HAVE_PARA;
        me->input_requested = NO_ENTRIES;
      }
      break;

    default:
      break;
    }/* end switch (me->action) */

    if( me->input_requested == NO_ENTRIES )
      continue;

    else if( me->input_requested == GET_TOKEN )
    { /*  get_token of a point or a string */
      token = GRget_token( &msg, Tokens, &eventmask, &me->Event,
          &EventSize, &resp, response_data );
    }

    else if(me->input_requested == GET_PARAM)
    { /*  locate the parameter */
      LCdef_cursor();
      token = GRget_token( &msg, Tokens, &eventmask, &me->Event,
          &EventSize, &resp, response_data );
      LCrestore_cursor();
      if(resp == DATA || resp == SPECIFIED_OBJ)
      {
        status = EXputq_front(&msg,&resp,&EventSize,(IGRchar *)&me->Event.event);
        me->attr.owner_action |= LC_HANDLES;

        token = ASget_param( &msg, Tokens, &me->Event, &acc_Event, 
            &loc_Mask, &eventmask, &EventSize, &display_flag,
            &resp, response_data, me->loc_prompt, me->acc_prompt,
            me->reloc_prompt, &me->attr, &me->locate_stack,
            &(me->locate_param), &param_val );
      }
    }
    if (Tokens[token] == D_RESET) UI_status("");

    me->action = Action[me->state][token];
    me->state = Newstate[me->state][token];
  }
  while (Tokens [token] != GR_UNKNOWN_TYPE);
  *response = resp;
  dp$erase_hilite ( msg = &msg );

  return OM_S_SUCCESS;
}

end implementation COchexp;
