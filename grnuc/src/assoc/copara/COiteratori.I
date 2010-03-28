/*----

     Abstract:  This method implements the iterator

     CHANGE HISTORY:

	bd  nov-86  : Associative implementation
        ch  nov_87  : parameter iterator

----*/

class implementation COiterator;

#include "msmacros.h"
#include "ASmessages.h"
#include "grmsg.h"
#include "coparadef.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"
#include "asmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "OMmacros.h"
#include "ASmatrix.h"

from NDnode import NDdisplay, NDgive_structure, NDget_objects;

#define DYNAMICS	/* on */
#define AS_DEBUG 1


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             wakeup                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( int pos)
{
 if(me->mytype==0)
  	{ ex$message( msgnumb = AC_M_MovExpPara);}
 else
  	{ ex$message( msgnumb = AC_M_MovImpPara);}

 return( OM_S_SUCCESS);
}



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
                 char *response_data;
                 int  pos)
{

#define NUM_STATES 3
#define NUM_ACTIONS 8
#define NUM_TOKENS 6


enum possible_states { 	INITIAL,
			HAV_OBJ,
			HAV_PAR
		     };

enum possible_actions {	NIL,
			ERR,
			LOC_OBJ,
			STO_OBJ,
			LOC_PAR,
			STO_PAR,
			GET_POS,
			MODIF_PAR
		       };

enum possible_entry {
		     PARENT,
		     PARAM ,
		     POINT ,
		     RIEN
		    };


static IGRint TokenList[] =
 		      { RESET,
			DATA ,
			STRING,
			GR_UNKNOWN_TYPE ,
			LOC_PARENT ,
			LOC_PARAM
		      };

static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*            ************************** TOKENS ******************************
  Old State  *   RESET   , DATA     , STRING  , UNKNOWN  , PARENT ,  PARAM   */

/* INITIAL   */ {INITIAL , INITIAL  , INITIAL , INITIAL , HAV_OBJ , INITIAL },
/* HAV_OBJ   */ {INITIAL , HAV_OBJ  , HAV_PAR , HAV_OBJ , HAV_OBJ , HAV_PAR },
/* HAV_PAR   */ {INITIAL , HAV_PAR  , HAV_PAR , HAV_PAR , HAV_PAR , HAV_PAR }};

static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {
/*            ************************** TOKENS ******************************
  Old State  *   RESET   , DATA      , STRING  , UNKNOWN , PARENT  , PARAM   */

/* INITIAL   */ {LOC_OBJ , ERR       , ERR     , LOC_OBJ , STO_OBJ , ERR     },
/* HAV_OBJ   */ {LOC_OBJ , ERR       , STO_PAR , LOC_PAR , ERR     , STO_PAR },
/* HAV_PAR   */ {LOC_OBJ , MODIF_PAR , ERR     , GET_POS , ERR     , ERR     }};

                                                
    enum GRdpmode   DisplayMode;    /* display mode for display msg send */
                                                                            
    IGRint      status;         /* routine return status */
    IGRint      size;           /* size of GRevent buffer (struct GRevent) */
    IGRlong     display_flag;   /* display flag for locate filter */
    IGRlong     input_mask;     /* mask for GRgetevent */
    IGRlong     input_mask2;    /* mask for GRgetevent */
    IGRlong     locate_mask;    /* mask for GRgetevent */
    IGRlong     msg;            /* function return code */

    struct GRevent grevent1;           /* event returned by GRgetevent */
    struct GRmd_env mod_id;            /* dummy context, filled in at  */
    struct GRid  object, param_obj;    /* object located               */
    struct GRid  context;
    struct ret_struct ret_struct;
    IGRdouble param_val;
    IGRint nb_parents;

    IGRint token = 0;
    enum possible_entry entry_requested = PARENT;

    DisplayMode = GRbd;                   /* how to display element   */
    
    /*
     * get module id and space number.
     */
    status = GRfindmod(&mod_id);
    if( COERROR(status))
    {
        printf(" COiterator: err: GRfindmod status = %d\n", status);
        om$report_error(sts = status);
    }

    /*
     *  Initialization for locate
     */
    size = sizeof (struct GRevent);
    locate_mask = GRm_DATA | GRm_STRING | GRm_RESET;
    input_mask  = GRm_DATA | GRm_STRING | GRm_RESET;
    display_flag = ELEM_HILIGHT | ALL_WINDOWS;

    /*
     *  loop until exit condition occurs
     */

   do
    {
     switch (me->action)
      {       
        case NIL:
		 break;

	case ERR  :
		 ex$message( msgnumb = AS_E_InvDefRest);
		 me->state = INITIAL;
		 me->action = LOC_OBJ;

        case LOC_OBJ:
		ex$message( buff = me->loc_prompt, msgnumb = AS_P_IdEleKeyPara);
		entry_requested = PARENT;
		ex$message( buff = me->acc_prompt, msgnumb = AS_P_AccRej);
                break;

	case STO_OBJ:
  	       status =as$make_source(go_grid = object,
                         as_os = object.osnum,
                         as_grid = &me->obj_grid);
  	       if(!(status&1)) return OM_W_ABORT;
               me->obj_type = ret_struct.type;

               if( !(me->obj_type & parameter_generic)  &&
		    (me->mytype != 0) 	  )
		 {
		  /*| on remet dans input queue */
		  if(me->grevent0.response != SPECIFIED_OBJ)
		  status = EXputq_front(&msg, response, &size,
				        &(me->grevent2.event));

		  status = EXputq_front( &msg, response, &size,
				        &(me->grevent0.event));
                 }


	case LOC_PAR:
  	       ex$message( buff =  me->loc_prompt, msgnumb = AS_P_IdKeyParaIte);
	       ex$message( buff =  me->acc_prompt, msgnumb = AS_P_AccRej);
	       entry_requested = PARAM;
	       break;
		    

	case STO_PAR:
	       /*| STO_PAR */
               nb_parents = 1;
               status = om$send(msg =message NDnode.NDget_objects( ND_ROOT, 
				NULL, NULL, NULL, 0, OM_K_MAXINT, &nb_parents),
		        targetid = param_obj.objid, targetos = param_obj.osnum);
               if( nb_parents != 0 )
                {
		 /*| the parameter is not a root parameter */
		 ex$message( msgnumb = AS_P_SelRootPara);
	         entry_requested = RIEN;
		 me->state = HAV_OBJ;
		 me->action= LOC_PAR;
		 break;
        	}
		
		/*" dependency param %d obj %d\n",param_obj.objid,me->obj_grid.objid */

               if(!(nd$dep_exist(l_root  = &param_obj,    nb_root = 1,
                    		 l_tip   = &me->obj_grid, nb_tip  = 1)))
		{
		 /*| There is no dependency */
		 ex$message( msgnumb = AS_P_SelRootPara);
	         entry_requested = RIEN;
		 me->state = HAV_OBJ;
		 me->action= LOC_PAR;
		 break;
        	}

	       me->param_grid = param_obj;

        case GET_POS:
	       /*| GET_POS */
               if( me->obj_type & parameter_generic)
	        {
                 /*| no use the dynamic */
		 me->grevent0.event.value = me->value;
                 UI_prompt ("");
	         entry_requested = RIEN;
		 me->state = HAV_PAR;
		 me->action= MODIF_PAR;
	         break;
		}
	       else
	        {
                 ex$message( msgnumb = GR_P_EntDstPt);
	         entry_requested = POINT;
		 break;
        	}


	case MODIF_PAR :
               /*|COiteratori MODIF_PAR, before ASiterend */

               /* erase old position */
	       status=nd$get_graph(p_root=&me->param_grid,nb_root=1);
	       status=nd$broadcast_graph(
		     p_msg = message NDnode.NDdisplay(0,GRbe,&me->ModuleInfo));
	       as$status(action = RET_STATUS);

	       status=ASiterend( me->obj_grid, me->param_grid,
				 &me->grevent0,
				 my_id,&me->ModuleInfo);
	       if(status!= OM_S_SUCCESS)  ex$message( msgnumb = AS_E_ChFail);

               /* display new one */
     	       status=nd$broadcast_graph(
		      p_msg = message NDnode.NDdisplay(0,GRbd,&me->ModuleInfo));
	       as$status(action = RET_STATUS);

               if( me->obj_type & parameter_generic)
	        {
	         entry_requested = RIEN;
		 me->state = INITIAL;
		 me->action= LOC_OBJ;
		}
 	       break;

        }   /* end switch (me->state) */

/* the different possible input are respectively
       - definition of the object to move
       - definition of the parameter
       - definition of the destination point
       - rien for nothing
*/

   switch (entry_requested)
    {
     case PARENT :
        do
          {
	   token =ASget_parent( &msg,TokenList, &me->grevent0,
                  &me->grevent2, &locate_mask, &input_mask, &size, 
		  &display_flag, response, response_data, me->loc_prompt,
		  me->acc_prompt, me->reloc_prompt,
		  &me->attr, &me->locate_stack,
                  line_generic|conic_generic|point_generic|parameter_generic,
		  &object,&context,&ret_struct);

           if(TokenList[token] == STRING)
            {
 	     IGRint rc;

	   /*EXP_find_exp(response_data, &object.objid, &owner_id, &rc);*/
	     rc = exp$translate(exp_name = response_data,
				p_exp_id = &object.objid,
				p_osnum  = &object.osnum);
				
             /*| The object is a parameter */
	     
             if(!(rc&1))
              {
               ex$message( msgnumb = AS_E_ParaNFound);
               }
              else
               {
		om$send(msg = message NDnode.NDgive_structure
					     (&msg,&ret_struct,&me->ModuleInfo),
			targetid = object.objid, targetos = object.osnum); 

                UI_status("");
	        for(token=0; TokenList[token] != LOC_PARENT; token++);
	       }
	      }

           if(   TokenList[token] == LOC_PARENT
              && ret_struct.type&parameter_generic)
             {
                /* ask for the desired value */
		input_mask2 = GRm_DIST | GRm_RESET;/* Si angle GRm_ANGLE, si scalair GRm_SCALAR */
                ex$message( msgnumb = AS_P_Entvalue);
		do
		 {
                  /*| ask the value */
                  GRgetevent( &msg, &input_mask2, &size, &me->grevent0,
		  	      response, response_data);
		 } while(me->grevent0.response != VALUE && me->grevent0.response != RESET); 

		if( me->grevent0.response == RESET) { token = 0; break; }
		me->value = me->grevent0.event.value;
              }
          } while(TokenList[token] == STRING);
	UI_prompt("");
	break;

     case PARAM  :
	token = ASget_param (&msg,TokenList, &grevent1, &me->grevent2,
             &locate_mask, &input_mask, &size, &display_flag,
             response,response_data,me->loc_prompt,me->acc_prompt,
             me->reloc_prompt,&me->attr,&me->locate_stack,
             &param_obj,&param_val);
	break;

     case POINT :
	DYiterator(me->obj_grid, me->param_grid,
		   &me->grevent0, &me->grevent0.located_object[0].module_info,
		   &me->ModuleInfo);

	token = GRget_token(&msg,TokenList,&input_mask,&me->grevent0,
			    &size, response,response_data);
	break;

     case RIEN :
	break;
	}  /* end switch entry_requested */

   /* new action and new state */
   if( entry_requested != RIEN)
    {
      me->action = (IGRint) Action[   me->state ][ token ];
      me->state =  (IGRint) NewState[ me->state ][ token ];
    }

   /*"token : %d \n new_action : %d \n new_state : %d \nmsg : %d",token,me->action,me->state,msg */

  } while( TokenList[token] != GR_UNKNOWN_TYPE);   /* end do */

 return( status);
}   /*  end execute method */

end implementation COiterator;
