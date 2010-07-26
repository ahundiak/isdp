/*
     R PATIENCE 18/1/87    : Creation date
*/
class implementation COm_edit;

#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include "expression.h"
#include "expmacros.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "acmacros.h"

#define AS_DEBUG
#define macro_MAX 40

from ACmacro_defn import ACgive_temp_desc,ACtake_template,ACgive_feet_desc;
from ACcreate import ACmplace;
from ACcomplex import ACmremove_all;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*        init method = init method of the superclass : COpara                */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                  wakeup                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( IGRint Centring_Attribute )
{
  ex$message( field = 1, msgnumb = AC_M_ASEdMcDf );
  return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                  sleep                                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method sleep ( IGRint Centring_Attribute )
{
  ex$message( field = 2, in_buff="" );
  ex$message( field = 1, in_buff="" );
  return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                   execute                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int  *response; char *response_data; int  pos )
{

#define NUM_STATES     3  
#define NUM_ACTIONS    7 
#define NUM_TOKENS     3  

enum possible_states
  {
  LOC_MAC,
  LOC_PRP,  
  LOC_UP
  };

enum possible_actions
  {
  NIL,                       /* Does not make anything                        */
  ERR_M,                     /* When an error occurs                          */
  PR_L_MAC,                  /* PRepar to LOCATE the MACRO to edit            */
  ST_L_MAC,                  /* STORE it 				      */
  PR_L_PRP,		     /* prepare to get prompt 			      */
  ST_L_PRP,		     /* store it 				      */
  PR_L_UP,	             /* PRepar to LOCATE the MACRO where to take feet */
  ST_L_UP,                   /* STORE it				      */
  EDIT                       /* EDIT 					      */
  };

enum Poss_Entry 
  {
  PROMPT,                    /* when the user get a PROMPT                    */
  NOTHING                    /* when the system wait NOTHING                  */
  };

static IGRint TokenList[] =
  {
  STRING,
  RESET,
  GR_UNKNOWN_TYPE
  };

static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = 
  {
               /***************************************************************/
               /*                            TOKENS                           */
/****************-------------------------------------------------------------*/
/*  Old State   *   STRING   ,  RESET    , GR_UNKNOWN */
/*----------------------------------------------------------------------------*/
/*   LOC_MAC    */{  LOC_PRP ,  LOC_MAC  ,  LOC_MAC   },
/*   LOC_PRP    */{  LOC_UP  ,  LOC_MAC  ,  LOC_PRP   },
/*   LOC_UP     */{  LOC_MAC ,  LOC_PRP  ,  LOC_UP    }};

static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = 
  {
               /***************************************************************/
               /*                            TOKENS                           */
/****************-------------------------------------------------------------*/
/*  Old State   *   STRING   ,  RESET    , GR_UNKNOWN */
/*----------------------------------------------------------------------------*/
/*   LOC_MAC    */{ ST_L_MAC , PR_L_MAC  ,   PR_L_MAC  },
/*   LOC_PRP    */{ ST_L_PRP , PR_L_MAC  ,   PR_L_PRP  },
/*   LOC_UP     */{ ST_L_UP  , PR_L_PRP  ,   PR_L_UP   }};

  IGRlong    		Om_Ret_Msg, Input_Mask;
  IGRint     		Size, Token;               
  enum Poss_Entry	Entry_Request;
  struct GRevent      	Event_Ac;    
  struct GRid 		New_Obj;                   
  IGRint 		resp, status;
  IGRint 		ifeet,itemp,iup,nb_feet;
  struct 		myfeet *l_feet;

  *response = TERMINATE;
  Size = sizeof(struct GRevent);

  Input_Mask  = GRm_STRING | GRm_RESET;

  do 
  {
    switch (ME.COpara->action)
    {
      case NIL :
        break;

      case ERR_M : 
        ex$message( msgnumb = AS_E_InvDefRest );
        break;

      case PR_L_MAC : 
        ex$message( msgnumb = AS_P_KyMacWhTmp );
        Entry_Request=PROMPT;
        break;
 
      case ST_L_MAC : 
        strcpy(me->macro_name,Event_Ac.event.keyin);
        strcpy(me->full_name,Event_Ac.event.keyin);
	status = ac$find_macro_defn( action 		= ACfind_no_load, 
			    	     macro_name 	= me->full_name,
			    	     p_macro_defn_id 	= &New_Obj );

        if(!IF_NULL_OBJID(New_Obj.objid))
        {
          struct stemp *xdtemp;
	  int i;
          /*| take the description of the macro */

          me->macro_id = New_Obj;
          status = om$send( msg =message ACmacro_defn.ACgive_temp_desc(
				&(me->tot_temp),&xdtemp),
			    targetid = New_Obj.objid,
			    targetos = New_Obj.osnum  );
	  /*"%d tot_temp\n",me->tot_temp*/
          if(status&1)
	    { for(i=0;i<me->tot_temp;i++) me->dtemp[i]=xdtemp[i];}
	}
	else
	{
 	  status = 0;
	}

	if(!(status&1))
	{
          ex$message( field = 2, msgnumb = AS_S_MacNotFnd );
	  Entry_Request = NOTHING;
	  me->state  = LOC_MAC;
	  me->action = PR_L_MAC;
	  break;
	}

      case PR_L_PRP: 
/*
/*        if(me->mytype == 1)
/*	{
/*	  me->state = LOC_UP;
/*	  me->action = PR_L_UP;
/*	  Entry_Request = NOTHING;
/*	}
/*	else
/*	{
/* */
        ex$message( field = 3, msgnumb = AS_P_KyPmptPmbx );
        Entry_Request=PROMPT;
        break;
 
      case ST_L_PRP : 
        strcpy( me->dup[0].prompt, Event_Ac.event.keyin);

      case PR_L_UP : 
        ex$message( field = 3, msgnumb = AS_P_EntPmbxNam );
        Entry_Request=PROMPT;
        break;

      case ST_L_UP : 
	strcpy(me->macro_name,Event_Ac.event.keyin);
	{
	  IGRint 	inew_temp, suc, val_type;
	  IGRchar 	*exp_name[macro_MAX];
	  IGRdouble 	exp_value;
          OM_S_OBJID 	exp[macro_MAX];

/* MOD LU
	  status = ac$find_macro_defn( action 		= ACfind_no_load, 
			    	     macro_name 	= me->full_name,
			    	     p_macro_defn_id 	= &New_Obj );
END MOD LU */
	  status = ac$find_macro_defn( action 		= ACfind_no_load, 
			    	     macro_name 	= me->macro_name,
			    	     p_macro_defn_id 	= &New_Obj );
	  if(!status&1)
	  {
	    exp_value = 0;
	    inew_temp = 0;
	    for(itemp = 0; itemp<me->tot_temp; itemp++)
	    {
	      if(!(me->dtemp[itemp].type & parameter_generic)) continue;

		if( inew_temp == macro_MAX ){
			printf(" Error too many expression template to edit macro\n");
			printf(" abort command \n");
			return	OM_W_ABORT;
		}

	      if( me->dtemp[itemp].type & text_type)
		{
		    val_type = EXP_TEXT;
		    exp$create(exp_name = NULL,
		         exp_syntax = "",
			 p_exp_id = &exp[inew_temp],
			 type_rq = val_type,
			 osnum = me->ModuleInfo.md_id.osnum);
	       }
	      else 
		{
		    val_type = EXP_DOUBLE;
                    exp$create(exp_name = NULL,
		         exp_value = exp_value,
			 p_exp_id = &exp[inew_temp],
			 type_rq = val_type,
			 osnum = me->ModuleInfo.md_id.osnum);
	       }
	       exp_name[inew_temp] = me->dtemp[itemp].name;
	       inew_temp++;
	    }
	    if( inew_temp == 0 ) 
		{
        		me->state = LOC_MAC;
       			me->action= PR_L_MAC;
  			Entry_Request=NOTHING;
			break;
		}
	    status = om$construct(classname = "ACcreate",
				 osnum = me->ModuleInfo.md_id.osnum,
				 p_objid = &New_Obj.objid);
	    New_Obj.osnum = me->ModuleInfo.md_id.osnum;

	    status = om$send(msg=message ACcreate.ACmplace(&suc,
					ACcant_place_sym,me->macro_name,
					inew_temp,exp,exp_name,
					inew_temp,exp,exp_name,
					&me->ModuleInfo),
			    targetid = New_Obj.objid,
			    targetos = New_Obj.osnum);
	    as$status();
		
	    status = om$send(msg=message ACcomplex.ACmremove_all(&suc, 1, 
							&me->ModuleInfo),
			    targetid = New_Obj.objid,
			    targetos = New_Obj.osnum);
	    as$status();
	  }
          ex$message( field = 2, msgnumb = AS_S_StPmCrtd );

          strcpy(me->full_name,Event_Ac.event.keyin);

	  status = ac$find_macro_defn( action 		= ACfind_no_load, 
			    	     macro_name 	= me->full_name,
			    	     p_macro_defn_id 	= &New_Obj );

          if(!IF_NULL_OBJID(New_Obj.objid))
          {
  	    status = om$send( msg = message ACmacro_defn.ACgive_feet_desc
                                 (&nb_feet,&l_feet),
              		    targetid = New_Obj.objid,
              		    targetos = New_Obj.osnum);
            as$status();
	  }
	  else
          {
            status = 0;
	  }

 	  if(!(status&1))
	  {
            ex$message( field = 2, msgnumb = AS_S_MacNotFnd );
	    Entry_Request = NOTHING;
	    me->state  = LOC_UP;
	    me->action = PR_L_UP;
	    break;
	  }

	  me->num_up = 0;
	  for(itemp=0;itemp<me->tot_temp;itemp++)
	  {
	    strcpy(me->dtemp[itemp].down_scan,".");
	    for(ifeet=0;ifeet<nb_feet;ifeet++)
	    {
	      if(!strcmp(me->dtemp[itemp].name,l_feet[ifeet].name))
	      {
	        strcpy(me->dtemp[itemp].down_scan,l_feet[ifeet].name);
	        break;
	      }
            }
	    if(me->dtemp[itemp].down_scan[0] == '.') me->num_up++;
	  } 

	  me->dup[me->num_up].type=macro_generic;
	  strcpy(me->dup[me->num_up].prompt,me->dup[0].prompt);
	  strcpy(me->dup[me->num_up].up_scan,"*");
	  me->num_up++;
	  iup = 0;
	  for(itemp=0;itemp<me->tot_temp;itemp++)
	  {
	    if(me->dtemp[itemp].down_scan[0] == '.')
	    {
	      me->dtemp[itemp].back = iup;
	      me->dup[iup].type= me->dtemp[itemp].type;
	      strcpy(me->dup[iup].prompt,me->dtemp[itemp].name);
	      strcpy(me->dup[iup].up_scan,".");
	      iup++;
	    }
	    else
	    {
	      me->dtemp[itemp].back = me->num_up-1;
	    }
	  }
          status = om$send( msg =message ACmacro_defn.ACtake_template
              		(me->num_up,me->dup,me->tot_temp,me->dtemp),
                        targetid = me->macro_id.objid,
                        targetos = me->macro_id.osnum  );
          as$status();
          ex$message( field = 2, msgnumb = AS_S_MacEdBgNwOn );
	}
        me->state = LOC_MAC;
        me->action= PR_L_MAC;
        Entry_Request=NOTHING;
        break;
    }/* switch (me->action) */

    /*"===== entri_required %d bef switch \n", Entry_Request */

    switch (Entry_Request)
    {
      case PROMPT :
        Token = GRget_token(&Om_Ret_Msg,TokenList,&Input_Mask,&Event_Ac,
                &Size,&resp,response_data);
        break;

      case NOTHING :
        for (Token=0;TokenList[Token] != GR_UNKNOWN_TYPE;Token++);
	break;
    }
    /*"===== old action %d old state %d\n",me->action, me->state */

    me->action = (IGRint) Action   [me->state][Token];
    me->state  = (IGRint) NewState [me->state][Token];

    /*"===== entri_required %d token %d\n", Entry_Request, Token */
    /*"===== action %d state %d\n",me->action, me->state */

  } while ((TokenList[Token] != GR_UNKNOWN_TYPE) || (Entry_Request == NOTHING));

  *response = resp;
  return (Om_Ret_Msg);
}

end implementation COm_edit;
