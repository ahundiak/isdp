/*
  ABSTRACT
	commad object to place occurences of macro.
	There is three kinds of placement :

	- Placement of a symbol macro
	- Placement of an expanded macro
	- Placement of a dropped macro
	- Placement of a ci_macro

  HISTORY
    ???             mm/dd/yy             initial spec & wrote it
    elp             01/06/93             port to NT
    scw             08/10/94             port to Intel Solaris

*/
class implementation COm_place;

#include "OMmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "acdef.h"
#include "acmacros.h"
#include "dpmacros.h"
#include "grgsmacros.h"
#include "dpgraphics.h"
#include "griomacros.h"

#define AS_DEBUG


%safe
static int x_memo = -1,
       y_memo = -1,
       s_memo = -1;
%endsafe

extern struct ACdef_param ACglobal_place;


/******************************************************************************

   Interface function between C-form and CO

******************************************************************************/

COm_place_router(
  int    form_label,
  int    label,
  double value,
  char  *form_ptr)
/*.COm_router*/
{
 int status;
 struct GRid cmd_obj;

 FIf_get_cmd_oid_os(form_ptr,&cmd_obj.objid,&cmd_obj.osnum);
 if(cmd_obj.osnum == 0)
  {
   if(label != FORM_ABORT)
    {
     ex$message(msgnumb = AS_S_FoNoAc);
    }
   else om$send(msg = message COm_place.delete_form(),
	        senderid = NULL_OBJID,
	        targetid = cmd_obj.objid,
	        targetos = OM_Gw_TransOSnum_0);
  }
 else
  {
   status = om$send(msg = message COm_place.form_notification
				              (form_label,label,value,form_ptr),
		  senderid = NULL_OBJID,
		  targetid = cmd_obj.objid,
		  targetos = cmd_obj.osnum);
   as$status()
  }
 return(1);
}

COm_user_place_router(
  int    form_label,
  int    label,
  double value,
  char  *form_ptr)
/*.COm_router*/
{
 int status;
 struct GRid cmd_obj;

 FIf_get_cmd_oid_os(form_ptr,&cmd_obj.objid,&cmd_obj.osnum);
 if(cmd_obj.osnum == 0)
  {
   if(label != FORM_ABORT)
    {
     ex$message(msgnumb = AS_S_FoNoAc);
    }
   else om$send(msg = message COm_place.delete_form(),
	        senderid = NULL_OBJID,
	        targetid = cmd_obj.objid,
	        targetos = OM_Gw_TransOSnum_0);
  }
 else
  {
   status = om$send(msg = message COm_place.user_form_notification
				              (form_label,label,value,form_ptr),
		  senderid = NULL_OBJID,
		  targetid = cmd_obj.objid,
		  targetos = cmd_obj.osnum);
   as$status()
  }
 return(1);
}

COm_place_select(
  int    form_label,
  int    label,
  double value,
  char  *form_ptr)
/*.COm_place_select*/
{
 extern struct GRid *ACpath_grid;
 int row,pos;
 struct GRid macro_def;

 switch(label)
 {
  default : /*| accept or dismiss button */
  COm_place_router(form_label,label+100,value,form_label);
  break;

  case MACRO_LIB : /*| display the contents of the macro lib */
  FIfld_get_active_row(form_ptr,label,&row,&pos);
  macro_def.objid = NULL_OBJID;
  COm_list_macro(ACpath_grid+row,&macro_def,form_ptr);

  case MACRO_IN_LIB :
  break;
 }
 return OM_S_SUCCESS;
}

/* form_label is the pointer to the form which call the place option form */

COm_place_option(
  int    form_label,
  int    label,
  double value,
  char  *form_ptr)
/*.COm_place_option*/
{
 /*
    The form which call the place_option sub form has its form_pointer
    stored in the form_label of the sub form
 */
 COm_place_router(form_label,label+200,value,(char *) form_label);
 return 1;
}


COm_place_name(
  int    form_label,
  int    label,
  double value,
  char  *form_ptr)
/*.COm_place_option*/
{
 /*
    The form which call the place_option sub form has its form_pointer
    stored in the form_label of the sub form
 */
 COm_place_router(form_label,label+300,value,(char *) form_label);
 return 1;
}

method get_form_name(char *form_name)
{
 strcpy(form_name,"ASPlMacro");
 return OM_S_SUCCESS;
}

method init (int type; char *string_ptr )
{
 int status;
 char form_name[80];
 int FORM = 0;
 status = om$send(msg = message COpara.init(type,string_ptr),
		   targetid = my_id,
		   mode = OM_e_wrt_message);

  /* Initialize form */

 status = om$send(msg = message COm_place.get_form_name(form_name),
		  targetid = my_id);
 if(!(status&1)) return OM_W_ABORT;
 
 FIf_new( FORM, form_name , COm_place_router, &me->form_ptr);
 if(!me->form_ptr) return OM_W_ABORT;

 if(!strcmp(form_name,"ASPlMacro") && (me->mytype == 1))
  {
    char text[80];
    ex$message( buff = text, msgnumb = AC_M_MdMcOc);
    FIg_erase(me->form_ptr,CMD_NAME);
    FIg_set_text(me->form_ptr,CMD_NAME,text);
    FIg_display(me->form_ptr,CMD_NAME);
    FIg_erase(me->form_ptr,LOAD_TEMPLATE);
    FIg_erase(me->form_ptr,DEF_SELECTION);
    FIg_erase(me->form_ptr,DEF_OPTIONS);
    FIg_erase(me->form_ptr,DEF_NAMES);
   }

 if(x_memo != -1)
  {
   FIf_set_location(me->form_ptr,x_memo,y_memo);
#if ! defined( NT )
   FIf_set_screen(me->form_ptr,s_memo);
#endif
  }

 FIf_display(me->form_ptr);

  /* Initialize instances */

  me->form_option_ptr = NULL;
  me->form_select_ptr = NULL;
  me->user_form_ptr = NULL;
  me->form_names_ptr = NULL;
  me->macro_name[0] = 0;
  me->macro_id.objid = NULL_OBJID;
  me->macro_id.osnum = 0;
  me->macro_type = -1;
  me->def_id.objid = NULL_OBJID;
  me->hdr_name[0] = 0;
  me->hdr.objid = NULL_OBJID;
  me->def_hdr.objid = NULL_OBJID;
  me->def_window.objid = NULL_OBJID;
  me->scale_fact = 0;
  me->scale_flag = 0;

  me->Nb_Max_Temp = 0;
  me->index_to_locate = -1;

  /* Initialize default options */

  me->hdr_symb   = ACglobal_place.symb;
  me->hdr_type   = ACglobal_place.hdr_type;
  me->hdr_scroll = ACglobal_place.hdr_scroll;
  me->hdr_def    = ACglobal_place.hdr_def;
  strcpy(me->search_path,ACglobal_place.search_path);

  /* Initialise chanselect to connect grset */ 

   status = om$make_chanselect (
      channame = "COm_place.located_graphics",
      p_chanselect = &me->located_chansel );
   as$status();

  
  return(status);
}

method wakeup ( IGRint n )
{
 char text[80];
 int status,i;
 IGRlong msg;
 char  disp_factor[EXFI_STRLEN];
 char return_array[52];
 char format[10];
 short flag=0, num_default=1;
 struct GRIOreadout_spec readout_spec;

      if (me->mytype == 0) {ex$message( msgnumb = AC_M_ASPMc);
			    ex$message( buff = text, msgnumb = AC_M_PlMcOc);}
 else if (me->mytype == 1) {ex$message( msgnumb = AC_M_MdMcOc);
			    ex$message( buff = text, msgnumb = AC_M_MdMcOc);}
 status = om$send(msg = message COpara.wakeup(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);

/* Make sure that the template still exist */
 for(i=0;i<me->Nb_Max_Temp;i++)
  {
   if(me->Temp_List[i].objid == NULL_OBJID) continue;
   status = om$is_objid_valid(objid = me->Temp_List[i].objid,
			      osnum = me->Temp_List[i].osnum);
   if(!(status&1)) me->Temp_List[i].objid = NULL_OBJID;
  }

  status = co$get_default_units(msg = &msg,
                                table_name = GRIO_DISTANCE,
                                osnum = 2,
                                flag = &flag,
                                num_defaults = &num_default ,
                                default_units = return_array) ;

  status = co$cvt_exp_to_wrk( msg = &msg,
                              unit_type = GRIO_DISTANCE ,
                              osnum = 2,
                              units = 1.0,
                              alias = return_array,
                              result = &me->scale_fact);

 if(me->form_ptr && me->scale_fact != 1.0)
  {

   status = co$update_readout_spec(msg = &msg,
                                   unit_type = GRIO_DISTANCE,
                                   osnum = 2 ,
                                   update_flag = FALSE,
                                   readout_spec = &readout_spec);
   as$status(action = RET_STATUS);

   format[0] = '%';
   format[1] = '.';
   format[2] = '0' + readout_spec.precision ;
   format[3] = 'l';
   format[4] = 'f';
   format[5] = '\0';

   sprintf(disp_factor,format,me->scale_fact);
   FIg_enable(me->form_ptr,SCALE_GADG);
   FIg_enable(me->form_ptr,SCALE_FACT);
   FIg_set_text(me->form_ptr,SCALE_FACT,disp_factor);
   FIg_display(me->form_ptr,SCALE_GADG);
   FIg_display(me->form_ptr,SCALE_FACT);
  }

 if(me->form_ptr)
  {
   FIf_set_cmd_oid_os( me->form_ptr, my_id, OM_Gw_current_OS );
   FIg_enable(me->form_ptr,FORM_EXEC);

   status = om$send(msg = message COm_place.write_form(),
		    targetid = my_id);
  }
 if(me->user_form_ptr)
  {
   FIf_set_cmd_oid_os( me->user_form_ptr, my_id, OM_Gw_current_OS );
  }
 return (status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                  sleep                                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method super_cmd.sleep ( IGRint n )
{
 int status,msg;

 if(me->form_ptr)
  {
   FIf_set_cmd_oid_os(me->form_ptr,my_id,0);
   FIg_disable(me->form_ptr,FORM_EXEC);
  }

 if(me->user_form_ptr)
  {
   FIf_set_cmd_oid_os(me->form_ptr,my_id,0);
  }

/* I don't want to interrupt the command with the sub form active */

if(me->form_option_ptr)
  {
   FIg_set_state(me->form_ptr,DEF_OPTIONS,0);
   FIf_erase(me->form_option_ptr);
   FIf_delete(me->form_option_ptr);
   me->form_option_ptr = NULL;
  }

if(me->form_select_ptr)
  {
   FIg_set_state(me->form_ptr,DEF_SELECTION,0);
   FIf_erase(me->form_select_ptr);
   FIf_delete(me->form_select_ptr);
   me->form_select_ptr = NULL;
  }

if(me->form_names_ptr)
  {
   FIg_set_state(me->form_ptr,DEF_NAMES,0);
   FIf_erase(me->form_names_ptr);
   FIf_delete(me->form_names_ptr);
   me->form_names_ptr = NULL;
  }

 dp$erase_hilite(msg = &msg);
 status = om$send(msg = message COpara.sleep(n),
		   targetid = my_id,
		   mode = OM_e_wrt_message);
  return (status);
}

method delete(int n)
{
 long status,msg;
 OM_S_CHANSELECT  chansel;

 status = om$send(msg = message COm_place.delete_form(),
		  targetid = my_id);
 as$status();

 /* delete graphic set if any */

 chansel.type = OM_e_addr;
 chansel.u_sel.addr = &me->located_graphics;

 status = gr$gsempty (msg = &msg, p_chanselect = &chansel);

 status = om$send(msg = message COpara.delete(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 return(status);
}

method delete_form()
{
 long status = OM_S_SUCCESS;
		


/* Remove default occurence from the Rtree */
 if(me->def_hdr.objid != NULL_OBJID &&
    me->def_window.objid != NULL_OBJID)
  {
   ACerase_macro
            (&me->def_hdr,&me->def_id,me->dup,me->Nb_Max_Temp,&me->def_gragad);
  }

/* Delete if necessary window used to display default occurence */

 if(me->def_window.objid != NULL_OBJID)
  {
   status = om$send(msg = message Root.delete(1),
                    targetid = me->def_window.objid,
                    targetos = me->def_window.osnum);
   as$status();
  }

/*
 * 04/10/92 - JSD - This fixes the problem when dismissing the macro form and
 * macro window in any way.  The problem was the focus of the input was not
 * set to any valid window after the deletion of the window occurred.
 * Thanks to Shridar and Steve for the help in finding the solution.
 */
#ifdef X11
XSync ( EXdisplay, 0 );
#endif

/* now delete the form */
if(me->form_ptr)
{
 FIf_get_location(me->form_ptr,&x_memo,&y_memo);
 FIf_get_screen(me->form_ptr,&s_memo);
 FIf_erase(me->form_ptr);
 FIf_delete(me->form_ptr);
 me->form_ptr = NULL;
}

 return status;
}
end implementation COm_place;
