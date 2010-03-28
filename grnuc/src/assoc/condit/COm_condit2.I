class implementation COm_condit;

#include <string.h>
#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include "exmacros.h"
#include "exdef.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "expression.h"
#include "expmacros.h"
#include "nddef.h"
#include "griomacros.h"

#define AS_DEBUG

from NDnode import NDchg_state,NDgive_structure;
from ACmacro_defn import ACgive_upscan;

extern char *COm_condit_option_ptr;
extern int   COm_condit_dismiss_form();
extern       COm_condit_option();
extern struct ACdef_param ACglobal_create;

/*
History
  ???             mm/dd/yy             initial spec & wrote it
  elp             01/06/93             port to NT
  elp             01/19/93             fill in subform before displaying
*/

method form_notification (int f_label, g_label;double value;char *fp;
			  int init_notif)
{
long status,msg;
int i;
int row,col,sel,pos,num_col,num_row;
char text[80];
char *c,*strrchr();
double low,high;

status = OM_S_SUCCESS;

switch(g_label)
 {
 case FORM_EXEC : 
    {
     status = om$send(msg = message COm_condit.set_action_and_state
			      (CREATE_CONDIT, (enum possible_states) me->state),
		      targetid = my_id);
    }
   break;

 case FORM_RESTART :
   status = om$send(msg = message COm_condit.set_action_and_state
                                                (RESTART,WAIT_MACRO),
                    targetid = my_id);
   break;


 case FORM_ABORT : /*| Abort command						      */
  {
   int resp;
   long size;
   char data[1];

   resp = TERMINATE;
   data[0]=0;
   size = 1;
   status = ex$putque(msg = &msg, response = &resp,
		      byte = &size, buffer = data);
   COm_condit_dismiss_form();
   break;
  }

 case MACRO_TEMP :  /*| get default value for a template */
     /* 
	From the position in the form retrieve the corresponding macro
	and the template index
     */
    { int temp_num,dummy;
      struct sup *temp_desc;
     FIfld_get_active_row(fp,g_label,&me->active_template,&pos);
     FImcf_get_active_col(fp,g_label,&me->active_macro,&pos);
     FIfld_get_text(fp,g_label,me->active_template,me->active_macro,
		    80,text,&sel,&pos);
     c = strrchr(text,'=');
     if(c) *c = '\0';

     /*"active_template %d active_macro %d text %s\n",me->active_template,me->active_macro,text */
     status = om$send(msg = message ACmacro_defn.ACgive_upscan
                                        (&temp_num,&dummy,&temp_desc),
                      targetid = me->macro[me->active_macro].objid,
                      targetos = me->macro[me->active_macro].osnum);
     as$status(action = RET_STATUS);

     for(i=0;i<temp_num;i++)
      {if(!strcmp(text,temp_desc[i].prompt))
	{ me->active_template = i;
	  /*"me->active_template %d\n",me->active_template */
	  i = temp_num+1;
          status = om$send(msg = message COm_condit.set_action_and_state
					(GET_DEF_TEMP,WAIT_DEF_TEMP),
		           targetid = my_id);
        }
      }
     }
     break;

 case COND_VALUE : /*| Condition value */
  /* Seems to be impossible to have right notification .....*/
  for(col= 0; col<me->nb_macros ; col++)
   {
    FIfld_get_text(fp,g_label,col,pos,80,text,&sel,&pos);
    /*"col %d\n",col */
    COm_decode(text,me->value+col);
    status = om$send(msg = message COm_condit.write_macro
                                    (fp,col,0),
		     targetid = my_id);
   }
  break;


 case CONDIT_NAME : /*| GET condit name */
   FIfld_get_text(fp,g_label,0,0,macro_MAX_CHAR,me->condit_name,&sel,&pos);
   FIfld_set_active_row(fp,g_label,0,0);
   FImcf_set_active_col(fp,g_label,0,0);

   /*"new name %s\n",me->condit_name */
   break;


 case SCROLL_MACRO :

   FIg_get_value(fp,g_label,&value);
   FIg_get_low_value(fp,g_label,&low);
   FIg_get_high_value(fp,g_label,&high);
   FImcf_get_num_vis_cols(fp,MACRO_NAME,&num_col);

   col = me->nb_macros>num_col ? me->nb_macros-num_col : 0;
   
   col = 0.5 + col*(value-low)/(high-low);

   msg = FImcf_set_active_col(fp,MACRO_NAME,col,0);
   msg = FIg_display(fp,MACRO_NAME);
   msg = FImcf_set_active_col(fp,COND_VALUE,col,0);
   msg = FIg_display(fp,COND_VALUE);
   msg = FImcf_set_active_col(fp,MACRO_TEMP,col,0);
   msg = FIg_display(fp,MACRO_TEMP);
   msg = FImcf_set_active_col(fp,MACRO_FEET,col,0);
   msg = FIg_display(fp,MACRO_FEET);
   FImcf_get_active_col(fp,MACRO_FEET,&col,&pos);
   break;

 case SCROLL_TEMPLATE :
   FIg_get_value(fp,g_label,&value);
   FIg_get_low_value(fp,g_label,&low);
   FIg_get_high_value(fp,g_label,&high);
   FIfld_get_num_vis_rows(fp,CONDIT_TEMP,&num_row);

   row = me->Nb_Max_Temp>num_row ? me->Nb_Max_Temp-num_row : 0;
   row = 0.5 + row*(value-low)/(high-low);

   /*"first_row %d\n",row */
   FIfld_set_active_row(fp,CONDIT_TEMP,row,0); 
   msg = FIg_display(fp,CONDIT_TEMP);
   FIfld_set_active_row(fp,MACRO_TEMP,row,0);
   msg = FIg_display(fp,MACRO_TEMP);
   break;

 case SCROLL_FEET:
   FIg_get_value(fp,g_label,&value);
   FIg_get_low_value(fp,g_label,&low);
   FIg_get_high_value(fp,g_label,&high);
   FIfld_get_num_vis_rows(fp,CONDIT_FEET,&num_row);

   row = me->Nb_Max_Feet>num_row ? me->Nb_Max_Feet-num_row : 0;
   row = 0.5 + row*(value-low)/(high-low);

   /*"first_row %d\n",row*/
   FIfld_set_active_row(fp,CONDIT_FEET,row,0);
   msg = FIg_display(fp,CONDIT_FEET);
   FIfld_set_active_row(fp,MACRO_FEET,row,0);
   msg = FIg_display(fp,MACRO_FEET);
   break;

 case CONDIT_TEMP :
   /* Get default value */
   FIfld_get_active_row (fp,g_label,&row,&pos);
   FImcf_get_active_col (fp,g_label,&col,&pos);
   if(col != 1) break;

   FIfld_get_text(fp,g_label,row,col,80,text,&sel, &pos);
     /*"text >%s<\n",text*/
   if(me->Temp_Value[row].type == double_type)
      {
       status = sscanf(text,"%lf",&value);
       /*"%d --> %lf\n",row,value */
       if(status == 1) me->Temp_Value[row].var.root_pm_st.value = value;
      }
   else if(me->Temp_Value[row].type == text_type)
      {
       strncpy(me->Temp_Value[row].var.text_st.text_string,text,79);
       me->Temp_Value[row].var.text_st.text_string[79] = '\0';
      }

    status = om$send(msg = message COm_condit.write_condit(fp),
		     targetid = my_id);
   break;

 case DEF_OPTIONS :

  if(COm_condit_option_ptr == NULL)
   {
    int FORM = 0;
    FIf_new( FORM, "ASPlSymb", COm_condit_option, &COm_condit_option_ptr);
    if(COm_condit_option_ptr)
     {
      int xpos,ypos,screen;
      FIf_get_location(fp,&xpos,&ypos);
      FIf_get_screen(fp,&screen);
/*      xpos = xpos + 440;  /*420 */
      FIf_set_location(COm_condit_option_ptr,xpos,ypos);
#if ! defined( NT )
      FIf_set_screen(COm_condit_option_ptr,screen);
#endif
      COm_set_form_options(COm_condit_option_ptr,
                 me->hdr_symb,me->hdr_scroll,me->hdr_type,
		 me->hdr_def,me->search_path);
      FIf_display(COm_condit_option_ptr);
     }
   }
  else
   {
    /*| Form is already there */
    FIg_set_state(fp,DEF_OPTIONS,1);
   }

  break;

 case ACCEPT_OPTIONS :

  COm_get_form_options(COm_condit_option_ptr,mac_not_def,
                  &me->hdr_symb,&me->hdr_scroll,&me->hdr_type,
		  &me->hdr_def,me->search_path,&ACglobal_create);
  /*"symb %d scroll %d type %d def %d \n",me->hdr_symb,me->hdr_scroll,me->hdr_type,me->hdr_def */

 case ABORT_OPTIONS :
  FIfld_erase_cursor(COm_condit_option_ptr,SEARCHDIR);
  FIf_erase(COm_condit_option_ptr);
  FIf_delete(COm_condit_option_ptr);
  COm_condit_option_ptr = NULL;
  FIg_set_state(fp,DEF_OPTIONS,0);
  break;

   case SEARCHDIR_200 :
 
   { char text1[80];
   /*| Prompt the user for path name if the selected option is user specified */
   FIfld_get_list_text
	   (COm_condit_option_ptr,SEARCHDIR,USER_SPECIFIED,0,80,text1,&sel,&pos);
   FIfld_get_text
	     (COm_condit_option_ptr,SEARCHDIR,0,0,80,text,&sel,&pos);
   if(!strcmp(text,text1)) 
    {
     /*| affect cursor */
     ex$message(msgnumb = AS_P_KeyDirNam);
     text[0] = '\0';
     FIfld_set_text(COm_condit_option_ptr,SEARCHDIR,0,0,text,TRUE);
     FIfld_pos_cursor(COm_condit_option_ptr,SEARCHDIR,
                      0,0,0,0,0,0);
    }
   break;
  }
 }
 return(status);
}
method set_action_and_state(enum possible_actions action;
                            enum possible_states  state)
{
 int resp;
 long size;
 char data[1];
 IGRlong status,msg;

 /*"set state to %d and action to %d\n",state,action */
     me->action = action;
     me->state =  state;
     me->Entry_Request = NOENT;

     resp = ABS_DIG; /* Just to have an "unkown" */
     data[0]=0;
     size = 1;
     status = ex$putque(msg = &msg, response = &resp,
                      byte = &size, buffer = data);

     return (OM_S_SUCCESS);
}


end implementation COm_condit;
