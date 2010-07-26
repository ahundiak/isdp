class implementation COm_del;

#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "msmacros.h"
#include "AS_status.h"
#include "ACcondit.h"
#include "acmacros.h"
#define AS_DEBUG

from ACmacro_defn import  ACmremove_all,ACgive_upscan,ACgive_temp_desc,
			  ACgive_feet_desc;

from ACcond_def   import  ACgive_condit_desc;

from GRgraphics   import GRdelete;


#define NUM_STATES     1     /* NUMber of possible STATES                     */
#define NUM_ACTIONS    4     /* NUMber of possible ACTIONS                    */
#define NUM_TOKENS     3     /* NUMber of TOKEN (DATA type)                   */

enum possible_states
  {
  LOC_MACRO                  /* wait LOCATE of the macro                      */
  };

enum possible_actions
  {
  NIL,                       /* Does not make anything                        */
  ERR_M,                     /* When an error occurs                          */
  PR_MAC_N,                  /* PRepar MACro NAME acquisition                 */
  D_MACRO                    /* Dump or Delete the MACRO ,PR_MAC_N            */
  };

enum Poss_Entry 
  {
  PROMPT,                    /* when the user get a PROMPT                    */
  NOTHING                    /* when the system wait NOTHING                  */
  };

/* STATIC DECLARATIONS */

%safe
static IGRint TokenList[] =
  {
  STRING,                    /* when the user get a STRING                    */
  RESET,                     /* when the user click the reset buttom          */
  GR_UNKNOWN_TYPE            /* when the user make an UNKNOWN TYPE command    */
  };

static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = 
  {
               /***************************************************************/
               /*                            TOKENS                           */
/****************-------------------------------------------------------------*/
/*  Old State   *       STRING       ,       RESET         ,    GR_UNKNOWN    */
/*----------------------------------------------------------------------------*/
/*  LOC_MACRO   */{    LOC_MACRO     ,       LOC_MACRO     ,    LOC_MACRO     }
/*----------------------------------------------------------------------------*/
};


static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = 
  {
               /***************************************************************/
               /*                            TOKENS                           */
/****************-------------------------------------------------------------*/
/*  Old State   *       STRING       ,       RESET         ,    GR_UNKNOWN    */
/*----------------------------------------------------------------------------*/
/*  LOC_MACRO   */{     D_MACRO      ,       PR_MAC_N      ,    PR_MAC_N      }
/*----------------------------------------------------------------------------*/
};

%endsafe


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*        init method = init method of the superclass : COpara                */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                  wakeup                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( IGRint Centring_Attribute )
{
  if(ME.super_cmd->mytype == 0)
  {
    ex$message( field = 1, msgnumb = AC_M_ASShMcRtDW );
  }
  else
  {
    ex$message( field = 1, msgnumb = AC_M_ASDlMcDf );
  }
  return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                  sleep                                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method sleep ( IGRint Centring_Attribute )
{
  return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                   execute                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int  *response; char *response_data; int  pos )
{
  IGRlong    		status, msg, Input_Mask;       
  IGRint     		Size, Token=0;             
  enum Poss_Entry	Entry_Request;
  struct GRevent      	Event_Ac;    
  struct GRid		New_Obj;      
  IGRint     		resp;         
  int ups_num,temp_num,feet_num,i;
  int ups_prop;
  struct sup *ups_def;
  struct stemp *temp_def; 
  struct myfeet *feet_def;

  *response = TERMINATE;

  /*| Initialization for the Locate of an event */

  Size = sizeof(struct GRevent);
  Input_Mask  = GRm_STRING | GRm_RESET;

  do
  {
    switch (ME.COpara->action)
    {
      case NIL :
        break;

      case ERR_M : 
	/*| When an error occurs */
        ex$message( msgnumb = AS_E_InvDefRest );
        break;

      case PR_MAC_N : 
	/*| PRepar MACro NAME acquisition */
        ex$message( msgnumb = AS_P_EnMcNm );
        Entry_Request=PROMPT;
        break;

      case D_MACRO : 
	/*| Dump or Delete the MACRO ,PR_MAC_N            */
        /*| parse input for name description */
        strcpy(ME.COm_del->Macro_Name,Event_Ac.event.keyin);

	status = ac$find_macro_defn( action	= ACfind_no_load,
				macro_name 	= ME.COm_del->Macro_Name,
				p_macro_defn_id = &New_Obj );
        if (!(status&1) )
        {
          ex$message( field = 2, msgnumb = AS_S_MacNotFnd );
          Entry_Request=NOTHING;
        }
        else
        {
	 /*| Print macro definition */
          if (ME.super_cmd->mytype == 0)
          {
            status = om$send( msg = message ACmacro_defn.ACgive_upscan
						(&ups_num,&ups_prop,&ups_def),
                              targetid = New_Obj.objid, 
			      targetos = New_Obj.osnum );

            status = om$send( msg = message ACmacro_defn.ACgive_temp_desc
						(&temp_num,&temp_def),
                              targetid = New_Obj.objid, 
			      targetos = New_Obj.osnum );
	    as$status();
            status = om$send( msg = message ACmacro_defn.ACgive_feet_desc
						(&feet_num,&feet_def),
                              targetid = New_Obj.objid, 
			      targetos = New_Obj.osnum );
	    as$status();

            printf( "\n\n--name %s-------\n",ME.COm_del->Macro_Name);
            printf( "\n------Macro Attachment Definition ----------\n" );
            for ( i=0;i<ups_num;i++ )
            printf( "Prompt operator with=%s and search for macro or root=%s\n",
    				ups_def[i].prompt, ups_def[i].up_scan);

            for ( i=0;i<temp_num;i++ )
     	    printf
	      ("My root_name= %s corresponds to =%s in located object num %d\n",
        	temp_def[i].name, temp_def[i].down_scan, temp_def[i].back);

            printf
	       ("\n\n------List of named element in this construction -----\n");
            for ( i=0;i<feet_num;i++ )
            printf( " name= %s type=%d pos=%d \n",
                           feet_def[i].name ,feet_def[i].chan, feet_def[i].pos);

	    /* Additionnal information for condit		     */
	    {int num_condit,num_value;
	     struct ACcond_descrip *condit_desc;
	     struct ACcond_temp    *def_value;
	     char text[80];

	    status = om$send(msg = message ACcond_def.ACgive_condit_desc
				(&num_condit,&condit_desc,&num_value,&def_value),
                             targetid = New_Obj.objid, 
			      targetos = New_Obj.osnum );
	    if(status&1)
	     {
              printf("\n\n---- this is the following conditional ----\n");
              printf("condition value  placed macro\n");
	 
	      for(i=0;i<num_condit;i++)
	       {
	        ACprint_condition(&condit_desc[i].cond,text);
	        printf("%s %s\n",text,condit_desc[i].konst);
	       }
	    }}
		
          }
          else
          {
            struct GRmd_env md_env;
	    char full_name[DI_PATH_MAX];
	    char *c,*strrchr();
	    int nb_defaults;
	    struct GRid defaults;
	    char **defaults_name = NULL;

            md_env = me->ModuleInfo;
            md_env.md_id.osnum = New_Obj.osnum;
            md_env.md_id.objid = NULL_OBJID;

	    /* Get full name of the macro */
 	    status = di$untranslate(objid = New_Obj.objid,
                         	    osnum = New_Obj.osnum,
                                    objname = full_name);
	    as$status();

            /* The osnum is used to remove the symbol name from btree */
	    /* CGEE bug 5/12/90 				      */
            status = om$send(msg      = message ACmacro_defn.ACmremove_all(
						(int *) &msg, 1, &md_env),
                             targetid = New_Obj.objid, 
			     targetos = New_Obj.osnum );
            as$status();

            if (!(status&1) )
            { ex$message( msgnumb = AS_S_RmvFld ); }
            else
	    { ex$message( msgnumb = AS_S_MacDltd ); }

            /* Remove also default parameters if they are no longer used */

 	    c = strrchr(full_name,'$');
 	    if(c != NULL) strcpy(c,"$*");
 	    else strcat(full_name,"$*");

	    defaults_name = NULL; 
	    nb_defaults = 0;
 	    status = di$ls( regexp = full_name,
			    lines = &defaults_name,
			    ptr = &nb_defaults,
			    options = 0);
	    /*"nb_defaults %d\n",nb_defaults */

	    for(i=0;i<nb_defaults;i++)
	      {
	       status = di$translate(objname = defaults_name[i],
				     p_objid = &defaults.objid,
				     p_osnum = &defaults.osnum);
	       if(status&1)
               status = om$send(msg = message GRgraphics.GRdelete(&msg,&md_env),
                             targetid = defaults.objid, 
			     targetos = defaults.osnum );
	      }
	    if(nb_defaults && defaults_name) 
		di$free(lines = defaults_name,
			count = nb_defaults);
            
 	  }

          ex$message( msgnumb = AS_P_EnMcNm );
          Entry_Request=PROMPT;
        }
        break;

      default :
        /*| Unexpected case */
        printf("COm_del.execute --> Unexpected ME.COpara->action\n");
        break;

    }/* end switch (ME.COpara->action) */

    switch (Entry_Request)
    {
      case PROMPT :
        Token = GRget_token(&status,TokenList,&Input_Mask,&Event_Ac,
                &Size,&resp,response_data);
        break;
	
      case NOTHING :
        for (Token=0;TokenList[Token] != GR_UNKNOWN_TYPE;Token++);
	break;

    }
    ME.COpara->action = (IGRint) Action   [ME.super_cmd->state][Token];
    ME.super_cmd->state  = (IGRint) NewState [ME.super_cmd->state][Token];
  } while ((TokenList[Token] != GR_UNKNOWN_TYPE) || (Entry_Request == NOTHING));

  *response = resp;
  return (status);
}

end implementation COm_del;
