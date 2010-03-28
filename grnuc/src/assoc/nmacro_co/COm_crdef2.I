class implementation COm_crdef;

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
#include "dpmacros.h"
#include "asbox.h"

#define AS_DEBUG

from NDnode import NDchg_state,NDgive_structure;
from ACmacro_defn import ACgive_upscan;

%safe
static int w_gadget,w_row=-1,w_col;
static int stacked = -1;
%endsafe

extern char *COm_crdef_option_ptr;
extern       COm_crdef_option();
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
int row,col,sel,pos,index;
char text[80];
char *c;
int num_rows,irow;
long size;
int  resp;
char data[1];

status = OM_S_SUCCESS;
if(stacked == my_id)
  {
   struct GRevent grevent;
   /*| KLUDGE to be able to accept in the form */

   size = sizeof(struct GRevent);

   resp = DATA;
   grevent.event.button.x = 0;
   grevent.event.button.y = 0;
   grevent.event.button.z = 0;
   grevent.num_id = 0;

   ex$putque(msg = &msg, response = &resp,
             byte =  &size, buffer = (char *) &(grevent.event));
   return(OM_S_SUCCESS);
  }
switch(g_label)
 {
 case FORM_EXEC :  /*| verify if the name is correct */
    {
     char data[1];
     /*| All ok to place the macro */

     me->action = CREATE_MACRO;
     me->Entry_Request = NOENT;

     resp = ABS_DIG; /* Just to have an "unkown" */
     data[0]=0;
     size = 1;
     status = ex$putque(msg = &msg, response = &resp,
		      byte = &size, buffer = data);
    }
   break;


 case FORM_ABORT : /*| Abort command						      */
  {
   resp = TERMINATE;
   data[0]=0;
   size = 1;
   status = ex$putque(msg = &msg, response = &resp,
		      byte = &size, buffer = data);
   break;
  }

 case FORM_RESTART :
   status = om$send(msg = message COm_crdef.set_action_and_state
						(RESTART,WAIT_OBJ),
		    targetid = my_id);
   break;
   

 case MACRO_NAME : /*| Get macro name, default parameter, initialize form     */

/* Get macro name */
  
   FIfld_get_text(fp,g_label,0,0,DI_PATH_MAX,me->macro_name,&sel,&pos);
   break;

 case TEMPLATE_LIST : /*| Get one of the template			      */

   FIfld_get_active_row (fp,g_label,&row,&pos);
   FImcf_get_active_col (fp,g_label,&col,&pos);
   index = row;

   if(init_notif)
    {
     /*| Initial selection of the line */
     dp$erase_hilite(msg = &msg);
     COm_hilite_elem(me->Temp_List+index,me->Temp_Value[index].type,
		     GRhdo,&me->ModuleInfo);
     if(me->state == FULL_DEF)
      {
       FIfld_get_text(fp,g_label,row,col,macro_MAX_CHAR,text,&sel,&pos);
       c = text;
       if (col == 0) {  ex$message(msgnumb = AS_P_EnNewNamTemp); }
       else if(col==1)
       {
        if( (me->Temp_Value[index].type & parameter_generic) &&
            (me->Temp_Value[index].type != ~0))
	 {
	  ex$message(msgnumb = AS_P_EnDefValTemp);
	 }
        else if(me->Temp_Value[index].type & macro_generic)
	 {
	  ex$message(msgnumb = AS_P_KeyElMac);
	  c = strchr(text,' ');
	  if(c) c++;
	  else c = text;
	 }
        else if(me->Temp_Value[index].type & class_generic)
	 {
	  ex$message(msgnumb = AS_P_KeyElCla);
	  c = strchr(text,' ');
	  if(c) c++;
	  else c = text;
	 }
	else
	 {
	  ex$message(msgnumb = AS_P_KeyEl);
	  ex$message(msgnumb = AS_S_Elig);
	 }
      }
     else if(col ==2)
      {
       /* Change template type from fixed to not fixed */
       if(me->Temp_Fixed[index])
	{
	  me->Temp_Fixed[index] = 0;
          FIfld_set_text(fp,TEMPLATE_LIST,index,2,"NO",FALSE);
	}
       else
	{
	  me->Temp_Fixed[index] = 1;
          FIfld_set_text(fp,TEMPLATE_LIST,index,2,"YES",FALSE);
	}
      }

     if(col >= 0 && col <2)
      {
       w_row=row;
       w_col=col;
       w_gadget = g_label;
       FIfld_set_text(fp,ERROR_BOX,0,0,c,TRUE);
       FIfld_pos_cursor(fp,ERROR_BOX,0,0,0,0,0,0);
      }
     }
    }
   else
   {
    /*| notification due to new value of the line */
    FIfld_get_text(fp,g_label,row,col,80,text,&sel, &pos);
    FIfld_set_text(fp,ERROR_BOX,0,0,"\0",FALSE);
    if(text[0] != '\0')
     {
      if(col == 0)
       {
        /*| Get new template name */
	text[macro_MAX_CHAR-1] = '\0';
        c = me->Temp_Name+macro_MAX_CHAR*index;
        strcpy(c,text);
       }
      else if(col == 1)
       {
        if(me->Temp_Value[index].type == double_type)
        {
         /*| Get possible double value */
         status = sscanf(text,"%lf",&value);
         if(status == 1) me->Temp_Value[index].var.root_pm_st.value = value;
	 status = 1;
        }
        else if(me->Temp_Value[index].type == text_type)
        {
         /*| Get possible text value */
	 strncpy(me->Temp_Value[index].var.text_st.text_string,text,79);
	 me->Temp_Value[index].var.text_st.text_string[79] = '\0';
        }
      else if(me->Temp_Value[index].type & (macro_generic | class_generic))
       {
	strncpy(me->Temp_Value[index].var.macro_st.name,text,macro_MAX_CHAR);
	me->Temp_Value[index].var.text_st.text_string[macro_MAX_CHAR-1] = '\0';
       }
      else
       {
	status = COm_find_type_from_text(text,&me->Temp_Value[index].type);
	if(!(status&1))
	   COm_display_line(fp,TEMPLATE_LIST,2,index,
        		    me->Temp_Name+macro_MAX_CHAR*index,
		me->Temp_Value[index].type,me->Temp_Value+index,&NULL_GRID,0);
       }
      }
    }
    COm_display_line(fp,TEMPLATE_LIST,2,row,me->Temp_Name+macro_MAX_CHAR*row,
		     me->Temp_Value[row].type,me->Temp_Value+row,&NULL_GRID,0);
    ex$message(msgnumb = AS_P_MdMcDefForm);
   }

   break;
   
  case FEET_LIST : /*| Get one of the feet */
   FIfld_get_active_row (fp,g_label,&row,&pos);
   FImcf_get_active_col (fp,g_label,&col,&pos);
   index = row;
   /*"init_notif %d row %d --> feet %d %d\n",init_notif,row,index,me->Feet_List[index].objid*/
   if(init_notif)
    {
     dp$erase_hilite(msg = &msg);
     COm_hilite_elem(me->Feet_List+index,me->Feet_Type[index],
		     GRhdo,&me->ModuleInfo);
     if(me->state == FULL_DEF)
     {
      if(col == 0)
      {
       ex$message(msgnumb = AS_P_EnNewNamFoot);
       w_row=row;
       w_col=-1;
       w_gadget = g_label;
       FIfld_get_text(fp,g_label,row,0,macro_MAX_CHAR,text,&sel,&pos);
       FIfld_set_text(fp,ERROR_BOX,0,0,text,TRUE);
       FIfld_pos_cursor(fp,ERROR_BOX,0,0,0,0,0,0);
      }
     else if(col ==1)
      {
       /* Change feet type from removed to not fixed */
       if(me->Feet_Removed[row])
	{
	  me->Feet_Removed[row] = 0;
          FIfld_set_text(fp,FEET_LIST,row,1,"NO",FALSE);
	}
       else
	{
	  me->Feet_Removed[index] = 1;
          FIfld_set_text(fp,FEET_LIST,row,1,"YES",FALSE);
	}
      }
     }
    }
   else
    {
     FIfld_get_text(fp,g_label,row,0,macro_MAX_CHAR,text,&sel,&pos);
     /*"new name %s c[0] %d\n",c,*c*/
     if(text[0] != '\0')
       {
        c = me->Feet_Name+macro_MAX_CHAR*index;
	strcpy(c,text);
        FIfld_set_text(fp,ERROR_BOX,0,0,"\0",FALSE);
       }
    }
   break;

  case ERROR_BOX :
   /*| This because initial notification does not work !!!!! */

     FIfld_get_text(fp,g_label,0,0,80,text,&sel,&pos);
     /*"error --> %s\n",text*/

   /* Verify if this row is still active */
     FIfld_get_active_row (fp,w_gadget,&row,&pos);
     if(row != w_row){/*| row no longer active !! */break;}
     if(w_col != -1)
       {
        FImcf_get_active_col (fp,w_gadget,&col,&pos);
	if(col != w_col) {/*| col no longer active !!!*/ break;}
       }
     else
       col = 0;
     /*"Put text %s in label %d row %d col %d\n",text,g_label,row,col*/
     /* FIfld_set_select(fp,w_gadget,-1,col,TRUE); */
     FIfld_set_text(fp,w_gadget,row,col,text,TRUE);
     status = om$send(msg = message COm_crdef.form_notification
				(f_label, w_gadget,value,fp,FALSE),
		      targetid = my_id);
     break;

 case DEF_OPTIONS :

  if(COm_crdef_option_ptr == NULL)
   {
    int FORM = 0;
    FIf_new( FORM, "ASPlSymb", COm_crdef_option, &COm_crdef_option_ptr);
    if(COm_crdef_option_ptr)
     {
      int xpos,ypos,screen;
      FIf_get_location(fp,&xpos,&ypos);
      FIf_get_screen(fp,&screen);
      xpos = xpos + 440;  /*420 */
      FIf_set_location(COm_crdef_option_ptr,xpos,ypos);
#if ! defined( NT )
      FIf_set_screen(COm_crdef_option_ptr,screen);
#endif
      COm_set_form_options(COm_crdef_option_ptr,
                 me->hdr_symb,me->hdr_scroll,me->hdr_type,
		 me->hdr_def,me->search_path);
      FIf_display(COm_crdef_option_ptr);
     }
   }
  else
   {
    /*| Form is already there */
    FIg_set_state(fp,DEF_OPTIONS,1);
   }

  break;

 case ACCEPT_OPTIONS :

  COm_get_form_options(COm_crdef_option_ptr,mac_not_def,
                  &me->hdr_symb,&me->hdr_scroll,&me->hdr_type,
		  &me->hdr_def,me->search_path,&ACglobal_create);
  /*"symb %d scroll %d type %d def %d \n",me->hdr_symb,me->hdr_scroll,me->hdr_type,me->hdr_def */

 case ABORT_OPTIONS :
  FIfld_erase_cursor(COm_crdef_option_ptr,SEARCHDIR);
  FIf_erase(COm_crdef_option_ptr);
  FIf_delete(COm_crdef_option_ptr);
  COm_crdef_option_ptr = NULL;
  FIg_set_state(fp,DEF_OPTIONS,0);
  break;

 case TEMPLATE_TYPE :
  FIfld_get_list_num_rows(fp,TEMPLATE_TYPE,0,&num_rows);
  for(irow=0;irow<num_rows;irow++)
   {
    FIfld_get_list_select(fp,TEMPLATE_TYPE,irow,0,&sel);
    if(sel)
     {
      if     (irow == 0) me->template_type = ND_ROOT | ND_BODY;
      else if(irow == 1) me->template_type = ND_ROOT ;
      else if(irow == 2) me->template_type = ND_ROOT | ND_BODY 
					   | ND_TEMPLATE_AND_FEET;
      /* Just to have an "unkown" and update prompt and locate mask */
      resp = ABS_DIG; 
      data[0]=0;
      size = 1;
      status = ex$putque(msg = &msg, response = &resp,
		      byte = &size, buffer = data);
      break;
     }
   }
  break;

   case SEARCHDIR_200 :
 
   { char text1[80];
   /*| Prompt the user for path name if the selected option is user specified */
   FIfld_get_list_text
	   (COm_crdef_option_ptr,SEARCHDIR,USER_SPECIFIED,0,80,text1,&sel,&pos);
   FIfld_get_text
	     (COm_crdef_option_ptr,SEARCHDIR,0,0,80,text,&sel,&pos);
   if(!strcmp(text,text1)) 
    {
     /*| affect cursor */
     ex$message(msgnumb = AS_P_KeyDirNam);
     text[0] = '\0';
     FIfld_set_text(COm_crdef_option_ptr,SEARCHDIR,0,0,text,TRUE);
     FIfld_pos_cursor(COm_crdef_option_ptr,SEARCHDIR,
                      0,0,0,0,0,0);
    }
   break;
  }

 }
 return(status);
}

COm_find_type_from_text(atext,type)
char *atext;
int  *type;
{
 char *c,*c1,*strchr();
 int Temp_Type;
 int error;
 char text[200];

 strncpy(text,atext,200);
 text[199] ='\0';
 c = text;
 Temp_Type = 0;
 error = 0;
 while(1)
  {
   /* find or operator if any */

   c1 = strchr(c,'|');
   if(c1 != NULL) *c1='\0';

   /* Remove leading blank */
   while(*c == ' ') c++;
   if(*c == '\0') break;

   /* compare with known type */

        if(strncmp(c,"line",4) == 0) Temp_Type |=  line_generic;
   else if(strncmp(c,"point",5)== 0) Temp_Type |=  point_generic;
   else if(strncmp(c,"circle",6)== 0) Temp_Type |=  conic_generic;
   else if(strncmp(c,"curve",5)== 0) Temp_Type |=  curve_generic;
   else if(strncmp(c,"text",4)== 0) Temp_Type |=  lbs_generic;
   else if(strncmp(c,"coor",4)== 0) Temp_Type |=  ref_generic;
   else if(strncmp(c,"plane",4)== 0) Temp_Type |=  debug_type;
   else if(strncmp(c,"other type",3)== 0) Temp_Type |=  other_generic;
   else
     { ex$message(msgnumb = AS_S_InNoCh, type = "%s",
		  var = `c`); 
       error = 1;
     }
   if(c1 == NULL) break;
   c = c1+1;
  }
  if(!error) *type = Temp_Type;
 return 1;
}


end implementation COm_crdef;
