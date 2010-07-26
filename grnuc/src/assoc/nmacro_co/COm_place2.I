class implementation COm_place;

#include <string.h>

#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "expression.h"
#include "expmacros.h"
#include "nddef.h"

#define AS_DEBUG

from NDnode  import NDchg_state;
from NDmacro import ACgive_structure;


extern COm_place_select(),
       COm_place_option(),
       COm_place_name();

extern struct ACdef_param ACglobal_place;


/*
History
  ???             mm/dd/yy             initial spec & wrote it
  elp             01/06/93             port to NT
  elp             01/18/93             set subform fields before displaying

*/

method form_notification (int f_label, g_label;double value;char *fp)
{
long status,msg;
int i;
int row,sel,pos,num_rows;
char text[DI_PATH_MAX];
extern struct GRid *ACpath_grid;

status = OM_S_SUCCESS;
switch(g_label)
{
 case FORM_EXEC :  /*| verify if the occurence is fully defined and place the macro*/
   if(me->state != WAIT_TEM && me->state != FULL_DEF) break;

   if(!(me->mytype&1))
    {
     for(i=0;i<me->Nb_Max_Temp;i++)
       {
        if(me->Temp_List[i].objid != NULL_OBJID) continue;
        if (!(me->dup[i].type & parameter_generic) ||
             (me->dup[i].type == ~0)) break;
       }
     if(i < me->Nb_Min_Var_Temp) break;
     me->Nb_Max_Temp = i;
    }

   status = om$send(msg = message COm_place.set_action_and_state
                                      (CREATE_MACRO,
                                      (enum possible_states)me->state),
		    targetid = my_id);
   break;


 case LOAD_TEMPLATE :
  if(me->macro_id.objid == NULL_OBJID && me->mytype&1)
    {
     ex$message(msgnumb = AS_S_DefBefMcNa);
     FIg_set_state(fp,LOAD_TEMPLATE,0);
     break;
    }

  FIg_get_state(fp,LOAD_TEMPLATE,&sel);
  if(sel) status=om$send(msg = message COm_place.set_action_and_state
							    (PRO_LOAD,WAIT_LOA),
		    targetid = my_id);
 
  break;

 case FORM_RESTART :
   if(me->mytype&1)
    {
     FIg_disable(me->form_ptr,DEF_NAMES);
    }
   status = om$send(msg = message COm_place.set_action_and_state
                                                (PRO_MAC,WAIT_MAC),
                    targetid = my_id);
   break;


 case FORM_ABORT : /*| Abort command				*/
  {
   long size;
   int  resp;
   char data[1];

   resp = TERMINATE;
   data[0]=0;
   size = 1;
   status = ex$putque(msg = &msg, response = &resp,
		      byte = &size, buffer = data);
   break;
  }

 
   
 case TEMPLATE_LIST : /*| Get one of the template			      */
   row = value;
   if(row<me->Nb_Max_Temp)
    {
     me->index_to_locate = row;
     status=om$send(msg = message COm_place.set_action_and_state
							    (PRO_TEMP,WAIT_TEM),
		    targetid = my_id);
    }
   /*" template nb %d\n",row*/
   break;

 case DEF_NAMES : /*| names */
  if(me->macro_id.objid == NULL_OBJID)
   {
    ex$message(msgnumb = AS_S_DefBefMcNa);
    FIg_set_state(fp,DEF_NAMES,0);
   }
  else if(me->form_names_ptr == NULL)
   {
    FIf_new( fp, "ASPlName", COm_place_name, &me->form_names_ptr);
    if(me->form_names_ptr)
     {
      int xpos,ypos,screen;
      FIf_get_location(fp,&xpos,&ypos);
      FIf_get_screen(fp,&screen);
      if(xpos<500) xpos += 490;
      FIf_set_location(me->form_names_ptr,xpos,ypos);
#if ! defined( NT )
      FIf_set_screen(me->form_names_ptr,screen);
#endif
      COm_display_names(me->form_names_ptr,me->hdr_name,me->temp_name);
      FIf_display(me->form_names_ptr);
     }
   }
  else
   {
    /*| Form is already there */
    FIg_set_state(fp,DEF_OPTIONS,1);
   }
  break;

 case RESET_NAMES :
   COm_display_names(me->form_names_ptr,me->hdr_name,me->temp_name);
   break;

 case VALID_NAMES  :

 case ACCEPT_NAMES : /*| READ the names to give to the occurence */

   FIfld_get_text(me->form_names_ptr,OCC_NAME,0,0,DI_PATH_MAX,me->hdr_name,
		  &sel,&pos);

   FIfld_get_list_num_rows(me->form_names_ptr,TEMP_NAME,0,&num_rows);

   for(row=0;row<num_rows;row++)
     {
      FIfld_get_list_select(me->form_names_ptr,TEMP_NAME,row,0,&sel);
      /*"row %d sel %d\n",row,sel*/
      if(sel)
       {     if(row ==0) me->temp_name[0] = '\0';
        else if(row ==1) me->temp_name[0] = '.';
        else if(row ==2) me->temp_name[0] = '#';
        break;
       }
     }
   /*" name of occurence %s\n",me->hdr_name */
  if(g_label == VALID_NAMES) break; 

 case ABORT_NAMES :
  FIg_set_state(fp,DEF_NAMES,0);
  FIf_erase(me->form_names_ptr);
  FIf_delete(me->form_names_ptr);
  me->form_names_ptr = NULL;
  break;


 case OCC_TYPE_200 : /*| Check if occurance type is valid		     */

  { 
   FIfld_get_list_num_rows(me->form_option_ptr,OCC_TYPE,0,&num_rows);
   for(i=0;i<num_rows;i++)
   {
    FIfld_get_list_select(me->form_option_ptr,OCC_TYPE,i,0,&sel);
    if(sel) break;
   }
   /*"i %d\n",i */
   if(sel)  /* bug in form, if the user select the same field than displayed */ 
    {
     row = me->hdr_type;

     if(me->mytype & 1) {/*| Can not change type because modify cmd */}

     else if(me->macro_type == mac_sym)  row = HDR_SYMB;

     else if(me->macro_type == mac_exp)
          {
           if(  (!(me->def_properties&ACno_symbol   ) && i == HDR_SYMB)
              ||(!(me->def_properties&ACno_construct) && i == HDR_CONS)
              ||(!(me->def_properties&ACno_drop     ) && i == HDR_DROP))
                                                        row = i;
          }

     else if(me->macro_type == mac_ci)
        {if(i == HDR_CONS || i == HDR_SYMB || i == HDR_GRAPHIC)  row = i;}

    /*" Update the form mac_type %d hdr_type %d\n",me->macro_type,row */
     FIfld_get_list_text
		    (me->form_option_ptr,OCC_TYPE,row,0,80,text,&sel);
     FIfld_set_list_select(me->form_option_ptr,OCC_TYPE,row,0,TRUE);
     FIfld_set_text(me->form_option_ptr,OCC_TYPE,0,0,text,TRUE);
     break;
    }
  }

 case SEARCHDIR_200 :

   { char text1[80];
   /*| Prompt the user for path name if the selected option is user specified */
   FIfld_get_list_text
           (me->form_option_ptr,SEARCHDIR,USER_SPECIFIED,0,80,text1,&sel,&pos);
   FIfld_get_text
             (me->form_option_ptr,SEARCHDIR,0,0,80,text,&sel,&pos);
   if(!strcmp(text,text1))
    {
     /*| affect cursor */
     ex$message(msgnumb = AS_P_KeyDirNam);
     text[0] = '\0';
     FIfld_set_text(me->form_option_ptr,SEARCHDIR,0,0,text,TRUE);
     FIfld_pos_cursor(me->form_option_ptr,SEARCHDIR,
                      0,0,0,0,0,0);
    }
   break;
  }

 case DEF_OPTIONS :

  if(me->macro_id.objid == NULL_OBJID)
   {
    ex$message(msgnumb = AS_S_DefBefMcNa);
    FIg_set_state(fp,DEF_OPTIONS,0);
   }
  else if(me->form_option_ptr == NULL)
   {
    FIf_new( fp, "ASPlSymb", COm_place_option, &me->form_option_ptr);
    if(me->form_option_ptr)
     {
      int xpos,ypos,screen;
      FIf_get_location(fp,&xpos,&ypos);
      FIf_get_screen(fp,&screen);
      xpos = xpos + 400;  /*420 */
      FIf_set_location(me->form_option_ptr,xpos,ypos);
#if ! defined( NT )
      FIf_set_screen(me->form_option_ptr,screen);
#endif
      COm_set_form_options(me->form_option_ptr,
		 me->hdr_symb,me->hdr_scroll,me->hdr_type,
		 me->hdr_def,me->search_path);
      FIf_display(me->form_option_ptr);
     }
   }
  else
   {
    /*| Form is already there */
    FIg_set_state(fp,DEF_OPTIONS,1);
   }
  break;

 case ACCEPT_OPTIONS :

  {
  enum ACm_poss_def_par new_hdr_def;
  int mac_type;

  new_hdr_def = NO_OPTION;
  if(me->mytype&1) mac_type = mac_cant_change;
  else if(me->macro_id.objid == NULL_OBJID) mac_type = mac_not_def;
  else mac_type = me->macro_type;
  COm_get_form_options(me->form_option_ptr,mac_type,
		  &me->hdr_symb,&me->hdr_scroll,&me->hdr_type,
		  &new_hdr_def,text,&ACglobal_place);
  /*"scroll %d\n",me->hdr_scroll */
  /*"symb %d\n",me->hdr_symb */
  /*"text[0] %c text[1] %c\n",text[0],text[1] */
  /*"text %s\n",text */

  /* Store the new option in the macro library */

  if(  (new_hdr_def != me->hdr_def)
     ||(new_hdr_def == USER_SPECIFIED) && strcmp(text,me->search_path))
    {
     /*| change seach path --> reinitialize */
     me->hdr_def = new_hdr_def;
     if(me->hdr_def == USER_SPECIFIED)
       { strncpy(me->search_path,text,DI_PATH_MAX-1);
         me->search_path[DI_PATH_MAX-1] = '\0';
       }
	 
     status = om$send(msg = message COm_place.set_action_and_state
							     (STO_DEF,WAIT_TEM),
		      targetid = my_id);
    }
  }

 case ABORT_OPTIONS :
  FIg_set_state(fp,DEF_OPTIONS,0);
  FIf_erase(me->form_option_ptr);
  FIf_delete(me->form_option_ptr);
  me->form_option_ptr = NULL;
  break;

 case DEF_SELECTION :

  if(me->form_select_ptr == NULL)
   {
    FIf_new( fp, "ASPlMacro1", COm_place_select, &me->form_select_ptr);
    if(me->form_select_ptr)
     {
      int xpos,ypos,screen;
      FIf_get_location(fp,&xpos,&ypos);
      FIf_get_screen(fp,&screen);
      xpos = xpos + 370;  /* 380 */
      FIf_set_location(me->form_select_ptr,xpos,ypos);
#if ! defined( NT )
      FIf_set_screen(me->form_select_ptr,screen);
#endif
      COm_set_form_select(&me->macro_id,me->macro_name,me->form_select_ptr);
      ex$message(msgnumb = AS_P_SelMac);
      FIf_display(me->form_select_ptr);
     }
   } 
  else
   {
    /*| Form is already there */
    FIg_set_state(fp,DEF_SELECTION,1);
   }

  break;

 case ACCEPT_SELECTION :
  /*| Get the name of macro and macro_lib, generate the full path_name */

  FIfld_get_active_row(me->form_select_ptr,MACRO_LIB,&row,&pos);

  status = di$give_pathname ( osnum =  ACpath_grid[row].osnum,
                              pathname =  me->macro_name);
  strcat(me->macro_name,":constructs:");

  /*"macro_name %s\n",me->macro_name */

  FIfld_get_active_row(me->form_select_ptr,MACRO_IN_LIB,&row,&pos);
  /*"active_row %d\n",row */
  FIfld_get_text(me->form_select_ptr,MACRO_IN_LIB,row,0,80,text,
		 &sel,&pos);
  /*"text %s\n",text */
  strcat(me->macro_name,text);
  /*"macro_name %s\n",me->macro_name */


 case ABORT_SELECTION :
  FIg_set_state(fp,DEF_SELECTION,0);
  FIf_erase(me->form_select_ptr);
  FIf_delete(me->form_select_ptr);
  me->form_select_ptr = NULL;
  if(g_label == ABORT_SELECTION) break;

 /*| Update state table */
 status = om$send(msg = message COm_place.set_action_and_state
 							     (STO_MAC,WAIT_TEM),
 		   targetid = my_id);
 break;

 case ELIGIBLE_LIST : /*| Get template value from eligible values */
   status = om$send(msg = message COm_place.set_action_and_state
						   (STO_ELI,WAIT_TEM),
		    targetid = my_id);
   break;

 case SCALE_GADG :
          if( me->scale_flag == 0 )
             me->scale_flag = 1;
          else
             me->scale_flag = 0;
   break; 
}
 return(status);
}

method user_form_notification (int f_label, g_label;double value;char *fp)

{
 int i,*label;
 long status;

 if(g_label == FORM_EXEC || g_label == FORM_ABORT || g_label == FORM_RESTART)
  {
   status = om$send(msg = message COm_place.form_notification
			    (f_label,g_label,value,me->form_ptr),
		    targetid = my_id);
  }
 else
  {
   for(i=0;i<me->Nb_Max_Var_Temp; i++)
    {
     label = (int *) (me->Temp_Value + i);
     if(label[1] == g_label)
      {
       value = i;
       status = om$send(msg = message COm_place.form_notification
			    (f_label,TEMPLATE_LIST,value,me->form_ptr),
		    targetid = my_id);
       break;
      }
    }
  }
 return OM_S_SUCCESS;
}


end implementation COm_place;
