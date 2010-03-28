class implementation COm_crdef;

#include <sys/param.h>
#include "OMmacros.h"
#include "AS_status.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "dpmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "exmacros.h"

#define AS_DEBUG

%safe
char *COm_crdef_form_ptr = NULL;
char *COm_crdef_option_ptr = NULL;
int COm_crdef_nb_command = 0; 

static int x_memo = -1,
       y_memo = -1,
       s_memo = -1;

%endsafe

extern struct ACdef_param ACglobal_create;

/*
    Define default creation option as global to give a chance to the 
    startup command to modify them 
*/

from GRvg import GRgetobjinfo;
from GRgraphics import GRdisplay;
from NDnode import ASreturn_go;
from NDmacro import ACreturn_foot;
from expression import list;

/******************************************************************************

   Interface function between C-form and CO

******************************************************************************/

COm_crdef_router(form_label,label,value,form_ptr)
int form_label,label;
double value;
char *form_ptr;
/*.COm_router*/
{
 char text[80];
 int status;
 struct GRid cmd_obj;
 FIf_get_cmd_oid_os(form_ptr,&cmd_obj.objid,&cmd_obj.osnum);
 /*" cmd_obj %d %d\n",cmd_obj.objid,cmd_obj.osnum */
 if(cmd_obj.objid == NULL_OBJID)
  {
   /* Delete command even if not active */
   if(label != FORM_ABORT)
    {
     ex$message( buff = text,msgnumb = AS_S_FoNoAc);
     FIfld_set_text(form_ptr,ERROR_BOX,0,0,text,FALSE);
    }
   else COm_crdef_delete_form();
  }
 else
  {
   status = om$send(msg = message COm_crdef.form_notification
				    (form_label,label,value,form_ptr,TRUE),
		  senderid = NULL_OBJID,
		  targetid = cmd_obj.objid,
		  targetos = cmd_obj.osnum);
   as$status()
  }
 return(1);
}


#argsused
COm_crdef_option(form_label,label,value,form_ptr)
int form_label,label;
double value;
char *form_ptr;
/*.COm_crdef_option*/
{
 COm_crdef_router(form_label,label+200,value,COm_crdef_form_ptr);
 return(1);
}

COm_hilite_elem(obj,type,dp_mode,md_env)
struct GRid *obj;
int type;
enum GRdpmode dp_mode;
struct GRmd_env *md_env;

/*.COm_hilite_elem*/
{
long msg,status;
struct GRobj_info info;
char formula[MAXPATHLEN];
struct GRmd_env display_env;
struct GRid display_id;

/*"hilite element %d type %d\n",obj->objid,type*/

  display_id = *obj;
  display_env = *md_env;

  strcpy(info.type,"");

if(!(type & parameter_generic) || (type == ~0))
{
  status = om$send(msg = message GRvg.GRgetobjinfo(&msg, &info),
		   senderid = NULL_OBJID,
                   targetid = obj->objid,
                   targetos = obj->osnum);

  om$send(msg = message NDmacro.ACreturn_foot(&msg,"",&display_id,
					        &display_env.md_env.matrix_type,
					         display_env.md_env.matrix),
		   senderid = NULL_OBJID,
                   targetid = obj->objid,
                   targetos = obj->osnum);

 if ( display_id.objid != NULL_OBJID )
 {		   
  if(!(status&1)) status = om$send(msg = message GRvg.GRgetobjinfo(&msg, &info),
		   senderid = NULL_OBJID,
                   targetid = display_id.objid,
                   targetos = display_id.osnum);
  if((status&msg&1)) UI_status(info.type);
	      
  dp_mode = GRhdo;
/*" display obj %d %d\n",display_id.objid,display_id.osnum */
/*" md_id %d %d\n",display_env.md_id.objid,display_env.md_id.osnum */
  status = om$send(msg = message GRgraphics.GRdisplay (&msg,
					        &display_env.md_env.matrix_type,
					         display_env.md_env.matrix,
					&dp_mode,&display_env.md_id),
		   senderid = NULL_OBJID,
                   targetid = display_id.objid,
                   targetos = display_id.osnum);
  as$status();
 }
}
else
 {
  /* To beheave properly with pretend */
  status = om$send(msg = message NDnode.ASreturn_go(&display_id,
                                                &display_env.md_env.matrix_type,
                                                 display_env.md_env.matrix),
                   senderid = NULL_OBJID,
                   targetid = obj->objid,
                   targetos = obj->osnum);
  if(!(status&1)) display_id = *obj;

  status = om$send(msg = message GRgraphics.GRdisplay (&msg,
					        &display_env.md_env.matrix_type,
					         display_env.md_env.matrix,
					&dp_mode,&display_env.md_id),
		   senderid = NULL_OBJID,
                 targetid = display_id.objid,
                 targetos = display_id.osnum);

  status=om$send(msg = message expression.list(formula),
		 senderid = NULL_OBJID,
                 targetid = display_id.objid,
                 targetos = display_id.osnum);
  if(status &1) UI_status(formula);
 }
 return(status); 
}

method init (int type; char *string_ptr )
{
 int status;
 int FORM=0;

  status = om$send(msg = message COpara.init(type,string_ptr),
		   targetid = my_id,
		   mode = OM_e_wrt_message);



  /* Initialize form */

 if(COm_crdef_form_ptr == NULL)
  {
   FIf_new( FORM, "ASCrMacro", COm_crdef_router, &COm_crdef_form_ptr);
  }

 if(COm_crdef_form_ptr != NULL)
  {
   if(x_memo != -1)
     {
       FIf_set_location(COm_crdef_form_ptr,x_memo,y_memo);
       /*" set  s_memo %d\n",s_memo */
       FIf_set_screen(COm_crdef_form_ptr,s_memo);
     }

   FIf_display(COm_crdef_form_ptr);
   COm_crdef_nb_command += 1;
  }

  /* Initialize instances */

  me->macro_name[0] = 0;
  me->Nb_Max_Feet = 0;

  /* Initialize default options */
 
  me->hdr_symb   = ACglobal_create.symb;
  me->hdr_type   = ACglobal_create.hdr_type;
  me->hdr_scroll = ACglobal_create.hdr_scroll;
  me->hdr_def    = ACglobal_create.hdr_def;
  strcpy(me->search_path,ACglobal_create.search_path);

  return(status);
}

method wakeup ( IGRint n )
{
 int status;
 status = om$send(msg = message COpara.wakeup(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 if(COm_crdef_form_ptr != NULL)
 {
  if (!(FIf_is_valid (COm_crdef_form_ptr))) {
      FIf_set_cmd_oid_os( COm_crdef_form_ptr, my_id, OM_Gw_current_OS );
      FIg_enable(COm_crdef_form_ptr,FORM_EXEC);
      status = om$send(msg = message COm_crdef.write_form(COm_crdef_form_ptr),
		    	targetid = my_id);
      }
    else {
      long size;
      int  resp;
      char data[1];
      IGRlong msg;

      resp = TERMINATE;
      data[0]=0;
      size = 1;
      status = ex$putque(msg = &msg, response = &resp,
		      byte = &size, buffer = data);
      COm_crdef_form_ptr = NULL;
    }
 }
 if(me->mytype == 0) ex$message(msgnumb = AC_M_ASCrMcDf); 
 return (status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                  sleep                                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method super_cmd.sleep ( IGRint n )
{
 int status,msg;
 if(COm_crdef_form_ptr)
  {
   FIf_set_cmd_oid_os(COm_crdef_form_ptr,NULL_OBJID,0);
   FIg_disable(COm_crdef_form_ptr,FORM_EXEC);
  }

 if(COm_crdef_option_ptr)
  {
   FIg_set_state(COm_crdef_form_ptr,DEF_OPTIONS,0);
   FIf_erase(COm_crdef_option_ptr);
   FIf_delete(COm_crdef_option_ptr);
   COm_crdef_option_ptr = NULL;
  }

 dp$erase_hilite(msg = &msg);
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
 if(COm_crdef_form_ptr)
  {
   COm_crdef_nb_command = COm_crdef_nb_command-1;
   
   if(COm_crdef_nb_command == 0) COm_crdef_delete_form();

  }
 status = om$send(msg = message COpara.delete(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 return(status);
}

COm_crdef_delete_form()
{
 FIf_get_location(COm_crdef_form_ptr,&x_memo,&y_memo);
 FIf_get_screen(COm_crdef_form_ptr,&s_memo);
 /*" get s_memo %d\n",s_memo */
 FIf_erase(COm_crdef_form_ptr);
 FIf_delete(COm_crdef_form_ptr);
 COm_crdef_form_ptr = NULL;
 COm_crdef_nb_command = 0;
 return OM_S_SUCCESS;
}
end implementation COm_crdef;
