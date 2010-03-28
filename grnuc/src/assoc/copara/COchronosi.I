class implementation COchronos;

#include <math.h>
#include "msmacros.h"
#include "ASmessages.h"
#include "coparadef.h"
#include "AS_status.h"
#include "expmacros.h"
#include "OMmacros.h"

#include  "expression.h"
#include  "AS_status.h"
#include  "nd.h"
#include  "nddef.h"
#include  "ndmacros.h"
#include  "asdef.h"
#include  "asmacros.h"
#include  "asbox.h"
#include  "OMmacros.h"
#include  "dpdef.h"
#include  "dpmacros.h"
#include  "godef.h"


from NDnode     import NDdisplay, NDgive_structure, NDcopy_to_root, NDget_objects, 
                NDdelete;
from expression import NDset_value, modify;

#define DYNAMICS	/* on */
#define AS_DEBUG 1

#define EPSILON  1.e-4
#define MAX_STEP 500000

extern IGRboolean ASbroadcast_in_progress;


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             wakeup                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( int pos )
{
  ex$message ( msgnumb = AC_M_ChaParInc );
  return OM_S_SUCCESS;
}




#define NUM_STATES   5
#define NUM_ACTIONS 10
#define NUM_TOKENS   4

enum possible_states {   
  INITIAL,
      HAV_PAR,
      HAV_MIN,
      HAV_MAX,
      HAV_INCR
};

enum possible_actions {  
  NIL,
  ERR,
  LOC_PAR,
  STO_PAR,
  GET_MIN,
  STO_MIN,
  GET_MAX,
  STO_MAX,
  GET_INCR,
  STO_INCR
};

enum possible_entry {
  PARAM,
  STR,
  NOTHING
};


%safe
static int TokenList [] =
{ 
  RESET,
  STRING,
  GR_UNKNOWN_TYPE,
  LOC_PARAM
};


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {
  {INITIAL , INITIAL  , INITIAL  , HAV_PAR },
  {INITIAL , HAV_MIN  , HAV_PAR  , INITIAL },
  {HAV_PAR , HAV_MAX  , HAV_MIN  , INITIAL },
  {HAV_MIN , HAV_INCR , HAV_MAX  , INITIAL },
  {INITIAL , HAV_MIN  , HAV_PAR  , INITIAL }
};


static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {
  {LOC_PAR  , ERR      , LOC_PAR  , STO_PAR },
  {LOC_PAR  , STO_MIN  , GET_MIN  , ERR     },
  {GET_MIN  , STO_MAX  , GET_MAX  , ERR     },
  {GET_MAX  , STO_INCR , GET_INCR , ERR     },
  {LOC_PAR  , STO_MIN  , GET_MIN  , ERR     }
};
%endsafe



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response; char *response_data; int pos )
{
  int                 status;         /* routine return status */
  int                 size;           /* size of GRevent buffer ( struct GRevent ) */
  long                display_flag;   /* display flag for locate filter */
  long                input_mask;     /* mask for GRgetevent */
  long                locate_mask;    /* mask for GRgetevent */
  long                msg;            /* function return code */
  struct GRevent      grevent0, 
                      grevent1, 
                      grevent2;
  struct GRid         param_obj;      /* object located               */
  double              param_val;
  int                 nb_parents;
  struct GRid         cop_param,*par_list;
  int                 token, ok, stop;
  enum possible_entry entry_requested;
  int                 nb_step, i_step;
  IGRboolean          save_br;
  struct NDcp_struct  clone_list;
  struct GRid         deleted_grid;
  int                 i;

  me->ModuleInfo.md_id.objid = NULL_OBJID;
  me->mod_env = me->ModuleInfo;

  /*
   *  Initialization for locate
   */
  size = sizeof ( struct GRevent );
  locate_mask = GRm_DATA | GRm_STRING | GRm_RESET;
  input_mask  = GRm_DATA | GRm_STRING | GRm_RESET;
  display_flag = ELEM_HILIGHT | ALL_WINDOWS;

  /*
   *  loop until exit condition occurs
   */
  do
  {
    switch ( me->action )
    {
    case NIL:
      break;

    case ERR  :
      /* Error */
      ex$message( msgnumb = AS_E_InvDefRest );
      me->state = INITIAL;
      me->action = LOC_PAR;

    case LOC_PAR:
      /* LOC_PAR */
      ex$message( buff =  me->loc_prompt, msgnumb = AS_P_IdKeyPara );
      ex$message( buff =  me->acc_prompt, msgnumb = AS_P_AccRej );
      entry_requested = PARAM;
      break;

    case STO_PAR:
      /* STO_PAR */

      nb_parents = 1;
      /*** 
	   For NDget_objects struct grid is being passed as NULL.
	   In NDget_objects the member of this struct is being accessed which
	   leads to the problem. The problem was reported on TD for 
	   TR# 119422295 -- Satya -- 1st November 1994.
       ***/
      status = om$send( msg =message NDnode.NDget_objects( ND_ROOT|ND_IN_BUF, 
		    NULL, NULL, &par_list, 0, OM_K_MAXINT, &nb_parents ),
                    targetid = param_obj.objid, 
		    targetos = param_obj.osnum );
      if (nb_parents != 0)
      {
        /* the parameter is not a root parameter */
        ex$message( msgnumb = AS_P_SelRootPara );
        entry_requested = NOTHING;
        me->state = INITIAL;
        me->action= LOC_PAR;
        break;
      }
      me->param_grid = param_obj;
      ex$message ( msgnumb = AS_S_PmValue,type="%s%6.3lf", var = `"",param_val` );

    case GET_MIN:
      /* GET_MIN */
      ex$message ( msgnumb = AS_P_KeyStaVal );
      entry_requested = STR;
      break;

    case STO_MIN:
      /* STO_MIN */
      dp$erase_hilite ( msg = &status ); /* Erase the last one */

      ok= sscanf( response_data,"%lf",&me->min_val );
      if (ok!=1)
      {
        me->action = ERR;
        entry_requested = NOTHING;
        break;
      }

    case GET_MAX:
      /* GET_MAX */
      ex$message ( msgnumb = AS_P_KeyFinVal );
      entry_requested = STR;
      break;

    case STO_MAX:
      /* STO_MAX */
      ok= sscanf ( response_data, "%lf", &me->max_val );
      if (ok! = 1)
      {
        me->action = ERR;
        entry_requested = NOTHING;
        break;
      }


    case GET_INCR:
      /* GET_INCR */
      ex$message ( msgnumb = AS_P_KeySteVal );
      entry_requested = STR;
      break;

    case STO_INCR:
      /* STO_INCR */
      ok= sscanf ( response_data, "%lf", &me->incr_val );
      if (ok! = 1)
      {
        me->action = ERR;
        entry_requested = NOTHING;
        break;
      }
      if (me->incr_val != 0)
        nb_step = (me->max_val - me->min_val) / me->incr_val;
      else 
        nb_step = MAX_STEP +1;

      /* control sign of increments and number of steps*/
      if (nb_step < 0) 
      { 
        me->incr_val = -me->incr_val; 
        nb_step = - nb_step; 
      }
      
      if (nb_step > MAX_STEP)
      {
        me->action = ERR;
        entry_requested = NOTHING;
        break;
      }

      /* Copy the graph */
      {
        int cp_type = 0;
        double val;

        status = om$send ( msg = message NDnode.NDcopy_to_root ( &msg, cp_type,
            &me->mod_env, &me->ModuleInfo, &cop_param ),
            targetid = me->param_grid.objid,
            targetos = me->param_grid.osnum );
        as$status ( action = GOTO_VALUE, value = wrapup );
        if (cop_param.objid == NULL_OBJID)
          cop_param.objid = me->param_grid.objid;

        /* get the graph */
        status = nd$get_graph ( p_root = &me->param_grid, nb_root = 1 );
        as$status ( action = GOTO_VALUE, value = wrapup );

        clone_list.list = NULL;
        status = nd$copy_graph ( p_root = &cop_param, nb_root = 1,
            from_info = &me->mod_env,
            to_info = &me->ModuleInfo,
            p_clone = &clone_list );
        as$status( action = GOTO_VALUE, value = wrapup );

        val = me->min_val;
        stop = 0;
        /* additional step for final value ? */
        if (fabs ( nb_step * me->incr_val) < fabs ( me->min_val - me->max_val ))
          nb_step++;
        i_step = 0;
        save_br = ASbroadcast_in_progress;
        ASbroadcast_in_progress = TRUE;

        /** Modified the condition for while loop - TR# 119422295 **/
        while(nb_step >= i_step)
        {
          short rc;
          char  str_val [DI_PATH_MAX];
          
          ex$message ( msgnumb = AS_S_IncrNum ,type = "%d%d", var = `i_step,nb_step` );
          sprintf ( str_val, "%lf", val );
          status = om$send ( msg = message expression.modify ( "", str_val, &rc ),
              targetid = cop_param.objid, 
              targetos = cop_param.osnum );

          if (!(status & 1)) break;
          status = nd$get_graph ( p_root = &cop_param, nb_root = 1 );
          if (!(status & 1)) break;

          /* Erase the old position */
          dp$erase_hilite ( msg = &status );

          /* Update graph */
          status=nd$update_graph ( cn_type = 
              ND_COMP_NO_ERASE   | ND_COMP_NO_REM_RT |
              ND_COMP_NO_DISPLAY | ND_COMP_NO_REM_RT ,
              root_compute = ND_DONT_UPT_ROOT,
              md_env = &me->ModuleInfo );
          if (!(status & 1)) break;

          /* Display at the new position */
          status=nd$broadcast_graph ( p_msg = message NDnode.NDdisplay( 0, 
              GRhd, &me->ModuleInfo ) );
          if (!(status & 1)) break;

          /* new value of val or break */
/*
          if (stop) break;
*/
          if (IGEstop ())
          { 
            ex$message ( msgnumb = AS_S_IncrStop );
            break;
          }

          val = val + me->incr_val;
/*
          if ((val - me->min_val) * (val - me->max_val) >= 0 )
          {
            val = me->max_val;
            stop = 1;
          }
*/

          i_step++;
        }
        ASbroadcast_in_progress = save_br;

        /* kill the duplicated graph */
        deleted_grid.osnum = me->ModuleInfo.md_id.osnum;
        for(i = 0; i < clone_list.nb_obj; i++)
        {
          if (clone_list.list [i].original != clone_list.list [i].clone  ||
              me->mod_env.md_id.osnum != me->ModuleInfo.md_id.osnum)
          {
            deleted_grid.objid = clone_list.list[i].clone;
            nd$wait_batch ( type = GR_DELETED, l_object = &deleted_grid, nb_obj = 1 );
          }
        }
        if (clone_list.list != NULL) free ( (void *)clone_list.list );

        /* The graph still remains displayed untill dp$erase_hilite */
      }
      
      ex$message ( msgnumb = AS_P_KeyStaVal );
      entry_requested = STR;
      break;

wrapup:

      /* Error on the chronos command */
      entry_requested = PARAM;
      break;
    }   /* end switch ( me->state ) */


    switch (entry_requested)
    {
    case PARAM  :
      me->attr.owner_action |= LC_HANDLES;
      token = ASget_param ( &msg, TokenList, &grevent1, &grevent2,
          &locate_mask, &input_mask, &size, &display_flag,
          response, response_data, me->loc_prompt,me->acc_prompt,
          me->reloc_prompt,&me->attr, &me->locate_stack,
          &param_obj, &param_val );
      break;

    case STR :

      token = GRget_token ( &msg,TokenList,&input_mask,&grevent0,
          &size, response,response_data );
      break;

    case NOTHING :
      break;
    }  /* end switch entry_requested */

    /* new action and new state */
    if (entry_requested != NOTHING)
    {
      me->action = (int) Action [me->state][token];
      me->state =  (int) NewState [me->state][token];
    }
  } while( TokenList[token] != GR_UNKNOWN_TYPE );   /* end do */

  dp$erase_hilite ( msg = &status );

  return status;
}   /*end execute method */

end implementation COchronos;
