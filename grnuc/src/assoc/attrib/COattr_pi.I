/*
History
  D.P.    04/12/89	: Design date.
  elp     01/20/93        move form display from init to wakeup.
                          in delete method never physically
                          delete the form, hide it with erase.
*/

class implementation COattr_p;

#include "OMmacros.h"
#include "coparadef.h"
#include "AS_status.h"
#include "exmacros.h"
#include "ctype.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "dpmacros.h"
#include "ASmsg.h"

from ACdiowner import ACcreate, ACadd_component, ACadd_attribute,
  		      ACmod_attribute, ACrem_attribute;

from FIdirform import update;

from IGRdir import dump;

from NDmacro import ACgive_structure;

from GRgraphics import GRdisplay;

#define CMD_NAME 13
#define ATTRIB 12
#define ABORT 4


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

%safe
#if 1   /* change to 0 to dload */
char *COattr_p_form = NULL;
int   COattr_nb_cmd = 0;
#else
extern char *COattr_p_form;
extern int   COattr_nb_cmd;
#endif
%endsafe

#define  ATTR_PLACE     0            /* Command to place an attribute         */
#define  ATTR_REMOVE    1            /* Command to remove an attribute        */
#define  ATTR_MODIFY    2            /* Command to modify an attribute        */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define  MAX_PROMPT       80
#define  NAME_OF_DIR_FORM ":transient:IGENOD:DirCmds"

#define NUM_STATES     3   
#define NUM_ACTIONS    10 
#define NUM_TOKENS     4   

enum possible_states
{
  WAIT_ATTR,                  /* Wait a new attribute                         */
  WAIT_VALUE,                 /* Wait the attribute's value                   */
  WAIT_GO		      /* Wait the graphic object 		      */
};

enum possible_actions
{
  NIL,                        /* Does not make anything                       */
  ERR_M,                      /* When an error occurs                         */
  CLEAR_ATTR,                 /* Clear the attribute's                        */
  F_ATTR,                     /* Fetch attribute acquisition 		      */
  ST_ATTR,                    /* Store attribute,F_ATTR or F_VALUE            */
  REM_ATTR,		      /* Remove last attribute			      */
  ST_ATTR_ARR,		      /* Store an array of attributes obtained by     */
			      /* locating an object			      */
  F_VALUE,                    /* Fetch the value                              */
  ST_VALUE,                   /* Store the value  F_OBJ,                      */
  F_OBJ,                      /* Fetch the graphic object                     */
  EXEC_COM                    /* Execute the command                          */
};

enum Poss_Entry 
{
  PROMPT,                     /* If the user get a PROMPT                     */
  OBJECT,                     /* If the user get an OBJECT                    */
  NOTHING,                    /* If the system wait NOTHING                   */
};

%safe
static IGRint TokenList[] =
{
  STRING,               /* when the user get a STRING                    */
  RESET,                /* when the user click the reset buttom          */
  GR_UNKNOWN_TYPE,      /* when the user make an UNKNOWN TYPE command    */
  LOC_PARENT            /* when the user locate a parent                 */
};

static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = 
{
              /*--------------------------------------------------------------*/
              /*                            TOKENS                            */
/***************--------------------------------------------------------------*/
/*  Old State  *    STRING     , RESET       , GR_UNKNOWN     ,   LOC_PARENT  */
/*----------------------------------------------------------------------------*/
/* WAIT_ATTR   */{WAIT_ATTR    , WAIT_GO     , WAIT_ATTR      ,   WAIT_ATTR   },
/*----------------------------------------------------------------------------*/
/* WAIT_VALUE  */{WAIT_ATTR    , WAIT_ATTR   , WAIT_VALUE     ,   WAIT_VALUE  },
/*----------------------------------------------------------------------------*/
/* WAIT_GO     */{WAIT_GO      , WAIT_ATTR   , WAIT_GO        ,   WAIT_GO     }
/*----------------------------------------------------------------------------*/
};


static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = 
{
               /*-------------------------------------------------------------*/
               /*                            TOKENS                           */
/***************--------------------------------------------------------------*/
/*  Old State  *  STRING       , RESET       , GR_UNKNOWN     ,   LOC_PARENT  */
/*----------------------------------------------------------------------------*/
/* WAIT_ATTR   */{ST_ATTR      , F_OBJ       , F_ATTR         ,   ST_ATTR_ARR },
/*----------------------------------------------------------------------------*/
/* WAIT_VALUE  */{ST_VALUE     , REM_ATTR    , F_VALUE        ,   ERR_M       },
/*----------------------------------------------------------------------------*/
/* WAIT_GO     */{ERR_M        , CLEAR_ATTR  , F_OBJ          ,   EXEC_COM    }
/*----------------------------------------------------------------------------*/
};
%endsafe

#define AS_DEBUG

/******************************************************************************

   Interface function between C-form and CO

******************************************************************************/

COattr_router(form_label,label,value,form_ptr)
int form_label,label;
double value;
char *form_ptr;
/*.COattr_router*/
{
 int status;
 struct GRid cmd_obj;
 FIf_get_cmd_oid_os(form_ptr,&cmd_obj.objid,&cmd_obj.osnum);
 if(cmd_obj.objid == NULL_OBJID) return(1);

 status = om$send(msg = message COattr_p.form_notification
                                    (form_label,label,value,form_ptr),
                  senderid = NULL_OBJID,
                  targetid = cmd_obj.objid,
                  targetos = cmd_obj.osnum);
 as$status()
 return(1);
}

method form_notification (int f_label, g_label;double value;char *fp)
{
 int row,col,sel,pos;
 char text[80];
 int status;
 long msg;

switch(g_label)
{
 case ABORT : /*| Abort command                                               */
  {
   int resp;
   long size;
   char data[1];

   resp = TERMINATE;
   data[0]=0;
   size = 1;
   status = ex$putque(msg = &msg, response = &resp,
                      byte = &size, buffer = data);
   COattr_p_dismiss_form();
   break;
  }

 case ATTRIB : /*| attribute */
   FIfld_get_active_row (fp,g_label,&row,&pos);
   FImcf_get_active_col (fp,g_label,&col,&pos);
   if(col == 0)
    {
     FIfld_get_text (fp,g_label,row,0,80,text,&sel,&pos);
     if(text[0] == '\0')
        {/*"remove row %d\n",row*/ FIfld_delete_rows(fp,g_label,row,1);}
     break;
    }
 }
 return(OM_S_SUCCESS);

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                    init                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method init (int type; char *string_ptr )
  { 
  IGRlong    status; 
  int FORM = 0;

  status = om$send(mode     = OM_e_wrt_message,
                   msg      = message COpara.init(type,string_ptr),
                   targetid = my_id);
  as$status(action =RET_STATUS);

  /*| Initialize the instances */
  me->nb_attr     = 0;
  me->current_size = 0;

  /*| Initialize the form */

 if(COattr_p_form == NULL)
  {
   FIf_new( FORM, "ASattribute", COattr_router, &COattr_p_form);
  }

 if(COattr_p_form != NULL)
  {
   COattr_nb_cmd += 1;
  }
 else
   return( OM_W_ABORT );

  return(status);
}/* end init */

method delete(int n)
{
 int status;
/*
   delete the form and make the notification pointer point to the previous
   command object if any
*/
 if(COattr_p_form)
  {
   COattr_p_dismiss_form();
   COattr_nb_cmd = COattr_nb_cmd - 1;
  }

 status = om$send(msg = message COpara.delete(n),
                  targetid = my_id,
                  mode = OM_e_wrt_message);
 return(status);
}



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                  wakeup                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( IGRint Centring_Attribute )
{ 
  ex$message( field = 3, in_buff="" );

  if(COattr_p_form != NULL) {
    int msgnumb = 0, displayed;
    char ums_text[256];

    FIf_set_cmd_oid_os( COattr_p_form, my_id, OM_Gw_current_OS );
    FIg_erase(COattr_p_form, CMD_NAME);

    switch(me->mytype) {
      case ATTR_PLACE:  msgnumb = AC_M_PLACE_ATTR;  break;
      case ATTR_REMOVE: msgnumb = AC_M_REMOVE_ATTR; break;
      case ATTR_MODIFY: msgnumb = AC_M_MODIFY_ATTR; break;
    }/* end switch*/

    ex$message( field = MESSAGE_FIELD, msgnumb = msgnumb, buff = ums_text );
    FIg_set_text(COattr_p_form,CMD_NAME,ums_text);

    FIg_display(COattr_p_form,CMD_NAME);

    FIf_is_displayed( COattr_p_form, &displayed );
    if ( ! displayed )
      FIf_display(COattr_p_form);
  }

  return(OM_S_SUCCESS);
}/* end wake up */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                   execute                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int  *response; char *response_data; int  pos )
{ 
  int          len;
  char         *strchr();        /* Fonction to find a char in a string       */
  struct GRid  located_obj;      /* Located object                            */
  struct GRid  *l_object;        /* List of objects in the fence              */
  int          nb_object;        /* Number of objects in the fence            */
  int          index1;           /* Index for a loop                          */
  char         *attribute;       /* Attribute                                 */
  char         *syntax = NULL;   /* Syntax of the attribute                   */
  struct GRid  di_owner;         /* Owner of the attributes                   */
  struct GRid  di_formid;        /* Identifier of the Dir_cmd form            */
  IGRlong      msg;              /* Completion code of messages               */
  int i_attr;

  IGRlong    		status, Input_Mask, Locate_Mask, Display_Flag;  
  IGRint     		Size, Token = 0, Obj_Generic = ~0; 
  enum Poss_Entry   	Entry_Request = NOTHING;
  struct GRevent      	Event_Ac;
  struct GRid 		Context_GRid;
  struct ret_struct     rst;
  int 			resp;
  int nb_to_upd;
  char ums_text[256];
  
  *response    = TERMINATE;
  Size         = sizeof(struct GRevent);
  Input_Mask   = GRm_DATA | GRm_STRING | GRm_RESET;
  Display_Flag = ELEM_HILIGHT | ALL_WINDOWS;
  me->attr.properties = LC_DP_ONLY | LC_LC_ONLY | LC_WRITE_ONLY;

  do
    {
    switch(ME.COpara->action)
      {
      case NIL:
      break;

      case ERR_M: /*| ERR_M */
      ex$message(msgnumb= AS_E_InvDefRest);
      break;

      case CLEAR_ATTR:
      {
        me->nb_attr = 0;
        me->current_size = 0;
        dp$erase_hilite(msg = &msg);
        if(COattr_p_form)
          FIfld_set_num_rows(COattr_p_form,ATTRIB,0);
      }
      case F_ATTR:
      {
        /*| Prompt the attribute name */
        ex$message(msgnumb = AS_P_KEYIN_ATTR, buff = ums_text );
        sprintf(me->loc_prompt,ums_text,me->nb_attr);
        Entry_Request = OBJECT;
        Locate_Mask  = GRm_DATA | GRm_STRING | GRm_RESET;
        break;
      }
      case ST_ATTR_ARR:
      {
	 /*| Get an attribute from a graphic object */
	 ACreturn_diowner(&located_obj,&di_owner);
	 if(!IF_NULL_OBJID(di_owner.objid))
	 {
	   int nb_lines,i_lines;
	   char **lines;
	   struct GRid *grids;
	   char ssyn[21];
	   enum GRdpmode dp_mode;
           /*| a diowner has been found */

	   dp_mode = GRhd;
	   status = om$send(msg = message GRgraphics.GRdisplay (&msg,
				&me->ModuleInfo.md_env.matrix_type,
				 me->ModuleInfo.md_env.matrix,&dp_mode,
				&me->ModuleInfo.md_id),
                 targetid = located_obj.objid,
                 targetos = located_obj.osnum);

	   
	   nb_lines = 0;
	   lines = NULL;
	   grids = NULL;
	   status = om$send(msg = message IGRdir.dump((DIint *)&msg,NULL,NULL,
					&lines,(DIgrid **) &grids,&nb_lines,0),
			    targetid = di_owner.objid,
			    targetos = di_owner.osnum);
	   as$status(action = RET_STATUS);
	   /*"%d attrib \n",nb_lines*/
		
	   for(i_lines=0 ; i_lines<nb_lines ; i_lines++)
	   {
	      status = om$send(msg = message NDmacro.ACgive_structure((IGRint *)&msg,NULL,
							    lines[i_lines],&rst,
				    &me->grevent.located_object[0].module_info),
			       targetid = di_owner.objid,
			       targetos = di_owner.osnum);
	      if(rst.type == double_type)
		{sprintf(ssyn,"%g",rst.var.root_pm_st.value);
		 syntax = ssyn;
		}
	      else if(rst.type == text_type)
		 syntax = rst.var.text_st.text_string;
	      else syntax = NULL;
	      if(syntax != NULL)
	      {
      		 status=om$send(msg = message COattr_p.store_attrib
						        (lines[i_lines],syntax),
                     		targetid = my_id);
      		 as$status(action = RET_STATUS);
	      }
	      om$dealloc(ptr = lines[i_lines]);
	   }
	   if(lines != NULL) om$dealloc(ptr = lines);
	   if(grids != NULL) om$dealloc(ptr = grids);
         }
         else if(resp == STRING)
         {
           /*| Just take it has a name */
	   me->action = ST_ATTR;
	   Entry_Request = NOTHING;
           break;
         }
         else
         {
	  /* "There is no attribute on the located object" */
           ex$message( msgnumb = AS_S_NO_ATTR_ON_OBJ, buff = ums_text );
           UI_status(ums_text);
         }

         me->action = F_ATTR;
	 me->state  = WAIT_ATTR;
	 Entry_Request = NOTHING;
	 break;
      }
      case REM_ATTR:
      {
	 /*| Remove last attribute */
	 if(me->nb_attr>0)
	 {
	    me->current_size = me->attr_index[2*me->nb_attr-2];
	    me->nb_attr -=1;
	 }
         me->action = F_ATTR;
	 me->state  = WAIT_ATTR;
	 Entry_Request = NOTHING;
	 break;
      }
      case ST_ATTR:
      {
        UI_status("");
  
        syntax = strchr(response_data,'=');
        if(syntax)
        {
          /*| The syntax is in the response */
  	
          *syntax = '\0';
    	  syntax +=1;
  	  len = strlen(syntax);
        }
        else
        {
          len = 0;
        }
  
        status=om$send(msg = message COattr_p.store_attrib(response_data,syntax),
                       targetid = my_id);
        as$status(action = RET_STATUS);
  
        if(len != 0 || me->mytype == ATTR_REMOVE)
        {
           me->action = F_ATTR;
    	   me->state  = WAIT_ATTR;
  	   Entry_Request = NOTHING;
   	   break;
  	}
      }

      case F_VALUE:
      {
        /*| Fetch the value */
        ex$message(msgnumb = AS_P_KEYIN_VALUE, buff = ums_text );
 
        sprintf(me->loc_prompt,ums_text,
  	      me->attr_name+me->attr_index[2*me->nb_attr-2]);
        UI_prompt(me->loc_prompt);
        ME.super_cmd->state = WAIT_VALUE;
        Entry_Request       = PROMPT;
        syntax = response_data;
        break;
  
  
        case ST_VALUE:
        len = strlen(syntax);
  
        if(len > 0)
        {
          /*| Store the syntax */
  
          ME.COpara->action   = F_ATTR;
          ME.super_cmd->state = WAIT_ATTR;
          Entry_Request	    = NOTHING;
  	  status = om$send(msg = message COattr_p.store_attrib(NULL,syntax),
  	 		  targetid = my_id); 
  	  as$status(action = RET_STATUS);
        }
        else
        {
           /*| Ask value again */
           ME.COpara->action   = F_VALUE;
           ME.super_cmd->state = WAIT_VALUE;
           Entry_Request = NOTHING;
        }
        break;
      }
   
      case F_OBJ:
      {
        if(me->nb_attr)
        {
          /*| Fetch the object */
          ex$message(msgnumb = AS_P_LOCATE_OBJ, buff = ums_text );
          strcpy(ME.COpara->loc_prompt,ums_text);
          Entry_Request = OBJECT;
          Locate_Mask  = GRm_DATA | GRm_RESET;
        }
        else
        {
          /*| No attribute defined */
          ex$message(msgnumb = AS_P_NO_ATTRIBUTE, buff = ums_text );
          UI_status(ums_text);
          ME.COpara->action   = F_ATTR;
          ME.super_cmd->state = WAIT_ATTR;
          Entry_Request	      = NOTHING;
        } /* end if(me->nb_attr)*/
        break;
      }
      
      case EXEC_COM:
      {
        /*| Fence processing */
  
        ASstart_fence(located_obj,located_obj.osnum,&nb_object,
                      &l_object,&resp,response_data);
        /*" %d object(s) will receive these attributes\n",nb_object */
        di_owner.objid = NULL_OBJID;
  
        for(index1=0; index1 < nb_object; index1++)
          {
  	 /* returns di_owner if already exist or creates it for add attribute */
  
  	 ACreturn_diowner(&l_object[index1],&di_owner);
  
  	 if(IF_NULL_OBJID(di_owner.objid))
            {
              /*| Create a new owner */
  
  	    status = om$construct (classname = "ACdiowner", 
  			p_objid   = &di_owner.objid,
  			osnum     = me->ModuleInfo.md_id.osnum);
  	    as$status(action = RET_STATUS);
              di_owner.osnum = me->ModuleInfo.md_id.osnum;
  
              status = om$send (msg      = message ACdiowner.ACcreate(&msg,NULL),
      		        targetid = di_owner.objid,
                          targetos = di_owner.osnum);
              as$status();
  
              status = om$send (msg      = message ACdiowner.ACadd_component
  					(&msg,&l_object[index1]),
      		        targetid = di_owner.objid,
                          targetos = di_owner.osnum);
              as$status();
            }
   
  	if(COattr_p_form)
  	  FIfld_get_num_rows(COattr_p_form,ATTRIB,&nb_to_upd);
          else nb_to_upd = me->nb_attr;
   
          for(i_attr=0; i_attr<nb_to_upd; i_attr++ )
            {
  	   char name_form[80],syntax_form[80];
  	   int sel;
             if(COattr_p_form)
  	    {
      	     FIfld_get_text
  			 (COattr_p_form,ATTRIB,i_attr,0,80,name_form,&sel,&pos);
  	     attribute = name_form;
      	     FIfld_get_text
  			 (COattr_p_form,ATTRIB,i_attr,1,80,syntax_form,&sel,&pos);
  	     syntax = syntax_form;
  	    }
  	   else
  	   {
              attribute = me->attr_name + me->attr_index[2*i_attr];
              syntax    = me->attr_name + me->attr_index[2*i_attr+1];
  	   }
            if(!strlen(attribute)) break;
  
            switch(me->mytype)
            {
              case ATTR_PLACE:
      /*" Add the attributes to the owner %d.%d\n",di_owner.objid,di_owner.osnum*/
  
              if(!strlen(syntax)) break;
  
              status = om$send (msg      = message ACdiowner.ACadd_attribute
                                     			(&msg,attribute,syntax),
    		              targetid = di_owner.objid,
                                targetos = di_owner.osnum);
              as$status();
              break;
  
              case ATTR_REMOVE:
              if(di_owner.objid != NULL_OBJID)
                {
   /*" Remove the attributes to the owner %d.%d\n",di_owner.objid,di_owner.osnum*/
                status = om$send (msg      = message ACdiowner.ACrem_attribute
                                       			       (&msg,attribute),
                                  targetid = di_owner.objid,
                                  targetos = di_owner.osnum);
                as$status();
              }/* end if(di_owner)*/
              break;
  
              case ATTR_MODIFY:
  	      {
  	        if(di_owner.objid != NULL_OBJID)
                {
                /*" Modify the attributes to the owner %d.%d\n",di_owner.objid,di_owner.osnum*/
  
                  if(!strlen(syntax)) 
                     break;
                  status = om$send (msg = message ACdiowner.ACmod_attribute
                                       			(&msg,attribute,syntax),
    		                    targetid = di_owner.objid,
                            	    targetos = di_owner.osnum);
                  as$status();
   	        } /* end if(di_owner) */
                break;
              }
              
              default:
                break;
            }/* end switch */
          }/* end for(attr_length)*/
        }/* end for(index1)*/
        ASend_fence();
        
        /*| Update the DIform */   
  
        status = di$translate
                   (objname = NAME_OF_DIR_FORM,
  		  osnum = OM_Gw_current_OS,
  		  p_objid = &di_formid.objid,
  		  p_osnum = &di_formid.osnum );
        if(status == DIR_S_SUCCESS)
        {
          status = om$send
                     (msg = message FIdirform.update(),
                      targetid = di_formid.objid,
  		    targetos = di_formid.osnum);
        }/* end if(status)*/
  
        /*| Ask an other object */
  
        ME.COpara->action   = F_OBJ;
        ME.super_cmd->state = WAIT_GO;
        Entry_Request	  = NOTHING;
        break;
      }
    
      default :
      /*| Unexpected case */
      break;
    }/* switch (ME.COpara->action) */


    switch (Entry_Request)
     {
      case PROMPT :
        Token = GRget_token(&status,TokenList,&Input_Mask,&me->grevent,
                &Size,&resp,response_data);
        break;

      case OBJECT :
          Token = ASget_parent (
			&status,			TokenList, 
			&me->grevent, 			&Event_Ac,
                  	&Locate_Mask, 			&Input_Mask, 
			&Size, 				&Display_Flag,
                  	&resp, 				response_data, 
			ME.COpara->loc_prompt,  	ME.COpara->acc_prompt, 
			ME.COpara->reloc_prompt,	&ME.COpara->attr, 
			&ME.COpara->locate_stack,       Obj_Generic,
			&located_obj,			&Context_GRid,
			&rst );

        break;
	
      case NOTHING :
	break;
     }/* switch (Entry_Request) */

    /*" Token -->%d \n",Token*/
    /*" old_action -->%d \n",ME.COpara->action*/
    /*" old_state -->%d \n",ME.super_cmd->state*/

    if(Entry_Request != NOTHING)
    {
      ME.COpara->action    = (IGRint) Action   [ME.super_cmd->state][Token];
      ME.super_cmd->state  = (IGRint) NewState [ME.super_cmd->state][Token];
    }
    /*" new_action -->%d \n",ME.COpara->action*/
    /*" new_state -->%d \n",ME.super_cmd->state*/

  } while (TokenList[Token] != GR_UNKNOWN_TYPE);
  *response = resp;
  return(OM_S_SUCCESS);
}/* end execute */

method store_attrib(char *name,*syntax)
{
 int name_len,syntax_len;
 int size_index,size_name,new_size_name;
 int status;

  if(name != NULL) name_len = strlen(name)+1;
  else             name_len = 0;

  if(syntax != NULL) syntax_len = strlen(syntax)+1;
  else		     syntax_len = 0;

  /* Realloc if necessary arraies */

  size_index = om$dimension_of(varray = me->attr_index);
/*"size_index %d nb_attr %d\n",size_index,me->nb_attr*/
  if(2*me->nb_attr >= size_index)
    { /*| realloc index */
      status = om$vla_set_dimension(varray = me->attr_index,
				    size = size_index+10);
      as$status(action = RET_STATUS);
    }
 
  size_name = om$dimension_of(varray = me->attr_name);
  new_size_name = name_len+syntax_len+me->current_size;
/*"size_name %d name_len %d syntax_len %d current_size %d\n",size_name,name_len,syntax_len,me->current_size*/
  if(new_size_name > size_name)
    { /*| realloc name*/
      status = om$vla_set_dimension(varray = me->attr_name,
				    size = new_size_name + 50);
      as$status(action = RET_STATUS);
    }

  /* Copy name */

  if(name != NULL)
    {
     /*" store name %s\n",name*/
     OM_BLOCK_MOVE(name,me->attr_name+me->current_size,name_len);
     me->attr_index[2*me->nb_attr] = me->current_size;
     me->attr_index[2*me->nb_attr+1] = -1 ;
     me->current_size += name_len;
     me->nb_attr += 1;
    }

  /* Copy syntax */

  if(syntax != NULL)
    {
     /*" store syntax %s\n",syntax*/
     OM_BLOCK_MOVE(syntax,me->attr_name+me->current_size,syntax_len);
     me->attr_index[2*me->nb_attr-1] = me->current_size;
     me->current_size += syntax_len;
    }

  if(COattr_p_form)
   {
    int rows;

    FIfld_get_num_rows (COattr_p_form,ATTRIB,&rows);
    if(name != NULL)
      {
       FIfld_set_text (COattr_p_form,ATTRIB,rows,0,name,TRUE);
       rows++;
      }
    if(syntax != NULL)
       FIfld_set_text (COattr_p_form,ATTRIB,rows-1,1,syntax,TRUE);
   }
 return(OM_S_SUCCESS);
}

int COattr_p_dismiss_form()
{
  if ( COattr_p_form ) {
    if ( (COattr_nb_cmd - 1) == 0 ) {
      FIf_erase( COattr_p_form );
    }
  }
  return OM_S_SUCCESS;
}

end implementation COattr_p;
