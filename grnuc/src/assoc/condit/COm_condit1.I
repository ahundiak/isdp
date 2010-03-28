class implementation COm_condit;

#include "OMmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "dpmacros.h"

#define AS_DEBUG

%safe

#if 1   /* change to 0 to dload */
char *COm_condit_form_ptr = NULL;
char *COm_condit_option_ptr = NULL;
int COm_condit_nb_command = 0;
#else
extern char *COm_condit_form_ptr;
extern char *COm_condit_option_ptr;
extern int COm_condit_nb_command;
#endif

static int x_memo = -1,
       y_memo = -1,
       s_memo = -1;

%endsafe

/*
    Define default creation option as global to give a chance to the 
    startup command to modify them 

History
  ???             mm/dd/yy             initial spec & wrote it
  elp             01/06/93             port to NT
  elp             01/20/93             move form display from init to wakeup.
                                       in delete method never physically
                                       delete the form, hide it with erase.
  scw             08/10/94             port to Intel Solaris
*/

from GRvg import GRgetobjinfo;
from NDnode import NDdisplay;
from expression import list;

/******************************************************************************

   Interface function between C-form and CO

******************************************************************************/

COm_condit_router(form_label,label,value,form_ptr)
int form_label,label;
double value;
char *form_ptr;
/*.COm_router*/
{
 char text[80];
 int status;
 struct GRid cmd_obj;
 FIf_get_cmd_oid_os(form_ptr,&cmd_obj.objid,&cmd_obj.osnum);
 if(cmd_obj.objid == NULL_OBJID)
  {
   if(label != FORM_ABORT)
    {
     ex$message( buff = text,msgnumb = AS_S_FoNoAc);
     FIfld_set_text(form_ptr,ERROR_BOX,0,0,text,FALSE);
    }
   else COm_condit_delete_form();
  }
 else
  {
   status = om$send(msg = message COm_condit.form_notification
				    (form_label,label,value,form_ptr,TRUE),
		  senderid = NULL_OBJID,
		  targetid = cmd_obj.objid,
		  targetos = cmd_obj.osnum);
   as$status()
  }
 return(1);
}


#argsused
COm_condit_option(form_label,label,value,form_ptr)
int form_label,label;
double value;
char *form_ptr;
/*.COm_crdef_option*/
{
 COm_condit_router(form_label,label+200,value,COm_condit_form_ptr);
 return(1);
}



method init (int type; char *string_ptr )
{
 int status;
 int FORM = 0;
  status = om$send(msg = message COpara.init(type,string_ptr),
		   targetid = my_id,
		   mode = OM_e_wrt_message);

  /* Initialize form */

 if(COm_condit_form_ptr == NULL)
  {
   FIf_new( FORM, "ASCrCondit", COm_condit_router, &COm_condit_form_ptr);
   if(COm_condit_form_ptr != NULL)
    {
/*     FImcf_set_scroll_link(COm_condit_form_ptr,MACRO_TEMP,MACRO_TEMP);
/*     FImcf_set_scroll_link(COm_condit_form_ptr,MACRO_FEET,COND_VALUE);
/*     FImcf_set_scroll_link(COm_condit_form_ptr,MACRO_FEET,MACRO_NAME);
/****/
    }
    
  }

 if(COm_condit_form_ptr != NULL)
  {
   if(x_memo != -1)
     {
       FIf_set_location(COm_condit_form_ptr,x_memo,y_memo);
       /*" set  s_memo %d\n",s_memo */
#if ! defined( NT )
       FIf_set_screen(COm_condit_form_ptr,s_memo);
#endif
     }

   COm_condit_nb_command += 1;
  }
 else
  {
   return(OM_W_ABORT);
  }

  /* Initialize instances */
  me->nb_macros = 0;
  me->Nb_Max_Temp = 0;
  me->Nb_Max_Feet = 0;
  me->Nb_Max_Feet = 0;
  me->condit_name[0] = '\0';
  
  /* Initialize default options */
 
  return(status);
}

method wakeup ( IGRint n )
{
 int status;
 if(me->mytype == 0) ex$message(msgnumb = AC_M_ACCrCnDF); 

 status = om$send(msg = message COpara.wakeup(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 if(COm_condit_form_ptr != NULL)
 {
  int displayed;

  FIf_set_cmd_oid_os( COm_condit_form_ptr, my_id, OM_Gw_current_OS );
  FIg_enable(COm_condit_form_ptr,FORM_EXEC);

  status = om$send(msg = message COm_condit.write_form(COm_condit_form_ptr),
		    targetid = my_id);
  FIf_is_displayed(COm_condit_form_ptr, &displayed);
  if ( ! displayed )
    FIf_display(COm_condit_form_ptr);
 }
 return (status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                  sleep                                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method super_cmd.sleep ( IGRint n )
{
 int status;

 if(COm_condit_form_ptr)
  {
   FIf_set_cmd_oid_os(COm_condit_form_ptr,NULL_OBJID,0);
   FIg_disable(COm_condit_form_ptr,FORM_EXEC);
  }

   /* delete the subform */
 if(COm_condit_option_ptr)
  {
   FIg_set_state(COm_condit_form_ptr,DEF_OPTIONS,0);
   FIf_erase(COm_condit_option_ptr);
   FIf_delete(COm_condit_option_ptr);
   COm_condit_option_ptr = NULL;
  }

 status = om$send(msg = message COpara.sleep(n),
                  targetid = my_id,
	          mode = OM_e_wrt_message);
 return (status);
}

method delete(int n)
{
 int status;
/*
   delete the form and make the notification pointer point to the previous
   command object if any
*/
 if(COm_condit_form_ptr)
  {
   COm_condit_dismiss_form();
   COm_condit_nb_command = COm_condit_nb_command - 1;
  }

 status = om$send(msg = message COpara.delete(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 return(status);
}

int COm_condit_delete_form()
{
 FIf_get_location(COm_condit_form_ptr,&x_memo,&y_memo);
 FIf_get_screen(COm_condit_form_ptr,&s_memo);
 /*" get s_memo %d\n",s_memo */
 FIf_delete(COm_condit_form_ptr);
 FIf_erase(COm_condit_form_ptr);
 COm_condit_form_ptr = NULL;
 COm_condit_nb_command = 0;
 return OM_S_SUCCESS;
}

int COm_condit_dismiss_form()
{
  if ( COm_condit_form_ptr ) {
    if ( (COm_condit_nb_command - 1) == 0 ) {
      FIf_erase( COm_condit_form_ptr );
    }
  }
  return OM_S_SUCCESS;
}

end implementation COm_condit;
