/*

Name
  CO_expi.I

Description

Command object for the create expression command

Notes


 */

class implementation CO_exp;

#include "stdio.h"
#include "OMindex.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "OMlimits.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"

#include "godef.h"
#include "go.h"
#include "ex.h"

#include "grdpbmacros.h"
#include "codef.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#include "parametric.h"
#include "expression.h"
#include "expmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h" 
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ASmessages.h"
#include "dpdef.h"


from FIdirform  import update;
from GRgraphics import GRdelete, GRdisplay; 

#define NUM_TOKENS   3

/* define the states for place expression */

#define AT_START   0
#define AT_KEYIN   1
#define NUM_STATES   2

/* define the actions for place expression */

#define NIL          0
#define GET_KEY      1
#define T_EXPR       2
#define ERR          4
#define ERR2         5
#define NUM_ACTIONS   6

/* define the different commands */

#define EXPRESSION 0
#define REMOVE     2

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                  wakeup                                   */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( int Centring_Attribute; )
{
  UI_prompt ( "" );
  UI_status ( "" );

  switch (ME.CO_exp->Command)
  {
  case EXPRESSION:
    ex$message( msgnumb = AC_M_PlaExp);
    break;

  case REMOVE:
    ex$message( msgnumb = AC_M_RemExp);
    break;

  default:
    return OM_W_ABORT;
  }

  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                   init                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
method init(int  type; char *string_ptr)
{
  UI_prompt("");
  UI_status("");
  UI_message("");

  /* initialise assoc */
  ASsuper_construct ();

  /* initialise DI */
  di$init ();

  /* initialise the instances */

  ME.CO_exp->Command = type;
  ME.CO_exp->state   = AT_START;
  ME.CO_exp->action  = GET_KEY;

  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                execute                                   */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
method execute ( int *response;
char *response_data;
int pos )
{
  struct GRevent event; /* event from getevent                           */
  struct GRid    buffer;
  long      rc;     /* OM return code                                */
  long      size;   /* size of GRevent struct.                       */
  long      mask;   /* mask for input                                */
  int       token;  /* token that was found                          */
  long      msg;   /* for return code                               */
  int   resp;   /* local response to avoid infiniter loop when   */
  int  status;

  static int Tokens[] = {
    RESET,STRING,GR_UNKNOWN_TYPE  };

  static char Newstate[NUM_STATES][NUM_TOKENS] = {
    {  AT_START , AT_KEYIN,     AT_START    },
    {  AT_START , AT_KEYIN,     AT_KEYIN    },
    /****************----------------------------------------------------------*/
  };

  static char Action[NUM_STATES][NUM_TOKENS] = {
    {  GET_KEY  ,  T_EXPR ,         NIL     },
    {  GET_KEY  ,  T_EXPR ,         NIL     },
    /****************----------------------------------------------------------*/
  };

  /*! *response = TERMINATE */
  /* Initialisation step */

  *response = TERMINATE;
  size       = sizeof(struct GRevent);
  mask      = GRm_STRING | GRm_RESET;
  rc        = OM_S_SUCCESS;

  switch ( ME.CO_exp->Command )
  {
  case EXPRESSION:
    do
    {
      switch (ME.CO_exp->action)
      {
      case NIL:                        /* do nothing */
        break;

      case GET_KEY:                  /* get first keyin */
        ex$message(msgnumb = AS_P_KExp);
        break;

      case T_EXPR:     /* place expression */
        {
          char exp_name [EXP_MAX_LEN], exp_syntax [EXP_MAX_LEN];

          EXP_extract_lhs_rhs( event.event.keyin, exp_name, exp_syntax);

          if(exp_syntax[0] == '"')
          {
            OMuword osnum;

            /* text expression creation */
            di$pwd ( p_osnum = &osnum );

            if(EXP_text_exp_build(exp_name, exp_syntax, osnum,
                &buffer.objid ) == EXP_S_SUCCESS)
            {
              ex$message(msgnumb = AS_S_TxtCre);
              status = di$send( msg        = message FIdirform.update(),
                  targetname = "IGENOD:DirCmds",
                  targetos   = OM_Gw_current_OS );
            }
            else
              ex$message(msgnumb = AS_S_SynErr);
          }
          else
          {
            status = exp$create(exp_name = exp_name,
                                exp_syntax =  event.event.keyin,
                                p_exp_id = &buffer.objid);
            if (status == EXP_S_SUCCESS)
            {
              if( exp_name[0] != '\0' )
              {
                int status;
                ex$message ( msgnumb = AS_S_EqnCrea, type = "%s", var = `event.event.keyin` );
                status = di$send( msg        = message FIdirform.update(),
                    targetname = "IGENOD:DirCmds",
                    targetos   = OM_Gw_current_OS );
              }
            }
            else
              if (status != EXP_INV_REF_FILE)
                ex$message(msgnumb = AS_S_SynErr);
          }
          ex$message(msgnumb = AS_P_KExp);
        }
        break;

      default:
        break;

      }/* end switch (ME.CO_exp->action) */

      token = GRget_token(&msg,Tokens,&mask,&event,&size,
          &resp,response_data);

      ME.CO_exp->action = Action[ME.CO_exp->state][token];
      ME.CO_exp->state = Newstate[ME.CO_exp->state][token];

    }while(Tokens[token] != GR_UNKNOWN_TYPE);
    break;

  case REMOVE:
    do
    {
      switch (ME.CO_exp->action)
      {
      case NIL:
        break;

      case GET_KEY:
        ex$message(msgnumb = AS_P_KExpDel);
        break;

      case T_EXPR:
        {
          short   rc;
          char         keybuf[EXP_MAX_LEN];
          struct GRid   mod_grid, exp_grid;
          struct        GRmd_env mod_env;
          long   NumberOfBytes, BytesReceived;

          GRfindmod ( &mod_grid );
          NumberOfBytes = sizeof( mod_env );
          gr$get_module_env(
              msg= &msg,
              sizbuf= &NumberOfBytes,
              buffer= &(mod_env),
              nret= &BytesReceived );


          strncpy ( keybuf, event.event.keyin, EXP_MAX_LEN-1 );
          keybuf[EXP_MAX_LEN-1 ] ='\0';

          rc = di$translate ( objname = keybuf, p_objid = &exp_grid.objid,
              p_osnum = &exp_grid.osnum );
          if (rc != DIR_S_SUCCESS)
          {
            ex$message(msgnumb = AS_E_ExpNtF);
            ME.CO_exp->state = AT_START;
            ME.CO_exp->action = GET_KEY;
            ex$message(msgnumb = AS_P_KExpDel);
          }
          else
          {
            int           mode;
%safe
            enum GRdpmode dpmode;

            /*
             * erase and delete the expression (this is only going to work for the
             * module -> this command should use locate instead of translate). Better,
             * this command should go away and people should use delete.
             */
%endsafe
            dpmode = GRbehe;
            om$send (msg = message GRgraphics.GRdisplay ( &msg,
               &mod_env.md_env.matrix_type, mod_env.md_env.matrix, &dpmode, &mod_env.md_id ), 
               targetid = exp_grid.objid, targetos = exp_grid.osnum);
            om$send ( msg = message GRgraphics.GRdelete ( &msg, &mod_env ),
                targetid = exp_grid.objid, targetos = exp_grid.osnum );

            ex$message ( msgnumb = AS_S_ExpDel );

            status = nd$mod_batch ( request = ND_INQ, p_ret_mode = &mode);
            as$status( action = RET_STATUS );

            if( mode != ND_DEFER )
            {
              status = nd$exec_batch(mode = 0);
              as$status( action = RET_STATUS );

              status = di$send( msg = message FIdirform.update(),
                  targetname = "IGENOD:DirCmds",
                  targetos = OM_Gw_current_OS );
            }
          }
        }
        break;

      default:
        break;
      }/* end switch (ME.CO_exp->action) */

      token = GRget_token( &msg,Tokens,&mask,&event,&size,
          &resp,response_data );

      ME.CO_exp->action = Action[ME.CO_exp->state][token];
      ME.CO_exp->state = Newstate[ME.CO_exp->state][token];
    }while( (Tokens[token] != GR_UNKNOWN_TYPE) );
    break;

  }/* end switch (ME.CO_exp->command) */

  *response = resp;
  return OM_S_SUCCESS;
}

end implementation CO_exp;
