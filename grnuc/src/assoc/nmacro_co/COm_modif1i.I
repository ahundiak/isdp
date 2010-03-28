class implementation COm_modif;

#include "OMmacros.h"
#include "AS_status.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "dpmacros.h"
#include "acdef.h"
#include "acmacros.h"


#define AS_DEBUG

%safe
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
  elp             01/18/93             erase form before delete instead of
                                       delete then erase.  move form display
                                       from init to wakeup but only display
                                       if not displayed
*/

/******************************************************************************

   Interface function between C-form and CO

******************************************************************************/

COm_modif_router(form_label,label,value,form_ptr)
int form_label,label;
double value;
char *form_ptr;
/*.COm_router*/
{
 int status;
 struct GRid cmd_obj;
 FIf_get_cmd_oid_os(form_ptr,&cmd_obj.objid,&cmd_obj.osnum);
 /*" cmd_obj %d %d\n",cmd_obj.objid,cmd_obj.osnum */
 if(cmd_obj.osnum == 0)
  {
   /* Delete command even if not active */
   if(label != FORM_ABORT)
    {
     ex$message(msgnumb = AS_S_FoNoAc);
    }
   else
    {
     om$send(msg = message COm_modif.delete_form(),
	     senderid = NULL_OBJID,
	     targetid = cmd_obj.objid,
	     targetos = OM_Gw_TransOSnum_0);
    }
  }
 else
  {
   status = om$send(msg = message COm_modif.form_notification
				    (form_label,label,value,form_ptr,TRUE),
		  senderid = NULL_OBJID,
		  targetid = cmd_obj.objid,
		  targetos = cmd_obj.osnum);
   as$status()
  }
 return(1);
}

COm_modif_option(form_label,label,value,form_ptr)
int form_label,label;
double value;
char *form_ptr;
/*.COm_crdef_option*/
{
 if ( form_ptr ) ;
 COm_modif_router(form_label,label+200,value,(char *) form_label);
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

 FIf_new( FORM, "ASMdMacro", COm_modif_router, &me->form_ptr);

 if(me->form_ptr != NULL)
  {
   if(x_memo != -1)
     {
       FIf_set_location(me->form_ptr,x_memo,y_memo);
#if ! defined( NT )
       FIf_set_screen(me->form_ptr,s_memo);
#endif
     }
  }

  /* Initialize instances */

  me->macro_name[0] = 0;
  me->form_select_ptr = NULL;
  me->form_option_ptr = NULL;
  return(status);
}

method wakeup ( IGRint n )
{
 int status;
 status = om$send(msg = message COpara.wakeup(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 ex$message(msgnumb = AC_M_MdMcDf);
 if(me->form_ptr != NULL)
 {
  int displayed;

  FIf_set_cmd_oid_os( me->form_ptr, my_id, OM_Gw_current_OS );
  FIg_enable(me->form_ptr,FORM_EXEC);

  status = om$send(msg = message COm_modif.write_form(),
		    targetid = my_id);
  FIf_is_displayed( me->form_ptr, &displayed );
  if ( ! displayed )
    FIf_display(me->form_ptr);
 }
 return (status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                  sleep                                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method sleep ( IGRint n )
{
 int status;
 if(me->form_select_ptr)
  {
   FIg_set_state(me->form_ptr,DEF_SELECTION,0);
   FIf_erase(me->form_select_ptr);
   FIf_delete(me->form_select_ptr);
   me->form_select_ptr = NULL;
  }
 if(me->form_option_ptr)
  {
   FIg_set_state(me->form_ptr,DEF_OPTIONS,0);
   FIf_erase(me->form_option_ptr);
   FIf_delete(me->form_option_ptr);
   me->form_option_ptr = NULL;
  }
 if(me->form_ptr)
  {
   FIf_set_cmd_oid_os(me->form_ptr,NULL_OBJID,0);
   FIg_disable(me->form_ptr,FORM_EXEC);
  }
 status = om$send(msg = message COpara.sleep(n),
		   targetid = my_id,
		   mode = OM_e_wrt_message);
  return (status);
}

method delete(int n)
{
 int status;
 status = om$send(msg = message COm_modif.delete_form(),
		  targetid = my_id); 

 status = om$send(msg = message COpara.delete(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 return(status);
}

method delete_form()
{
 if(me->form_ptr)
 {
  FIf_get_location(me->form_ptr,&x_memo,&y_memo);
  FIf_get_screen(me->form_ptr,&s_memo);
  /*" get s_memo %d\n",s_memo */
  FIf_erase(me->form_ptr);
  FIf_delete(me->form_ptr);
  me->form_ptr = NULL;
 }
 return OM_S_SUCCESS;
}
end implementation COm_modif;
