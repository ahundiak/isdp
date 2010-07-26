class implementation COm_modif;

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

%safe
static int w_gadget,w_row=-1,w_col;
%endsafe

extern       COm_modif_option();
extern struct ACdef_param ACglobal_create;

/*
History
  ???             mm/dd/yy             initial spec & wrote it
  elp             01/06/93             port to NT
  elp             01/18/93             erase form in "dismiss" logic.
                                       display option form after setting
                                       the fields
*/

method form_notification (int f_label, g_label;double value;char *fp;
			  int init_notif)
{
long status,msg;
int i;
int row,col,sel,pos,index;
char text[80];
char *c,*c1,*c2,*strrchr(),*strchr();

status = OM_S_SUCCESS;
switch(g_label)
 {
 case FORM_EXEC :  /*| verify if the name is correct */
    {
     long size;
     int  resp;
     char data[1];
     /*| All ok to place the macro */

     me->action = MODIFY;
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
   long size;
   int  resp;
   char data[1];

   resp = TERMINATE;
   data[0]=0;
   size = 1;
   status = ex$putque(msg = &msg, response = &resp,
		      byte = &size, buffer = data);
   FIf_erase( fp );
   break;
  }

 case FORM_RESTART :
   status = om$send(msg = message COm_modif.set_action_and_state
						(RESTART,WAIT_DEF),
		    targetid = my_id);
   break;
   

 case DEF_NAME : /*| Get macro name, default parameter, initialize form     */

/* Get macro name */
  
   FIfld_get_text(fp,g_label,0,0,80,text,&sel,&pos);
   /* verify if this name is correct */
   c = strrchr(me->macro_name,':');
   if(c) c++;
   else c = me->macro_name;

   c1 = strrchr(text,':');
   if(c1) c1++;
   else c1 = text;
   c2 = strrchr(c1,'$');
   if(c2) *c2='\0';
   
   if(!c2 || strcmp(c,c1))
    {
     FIfld_set_text(fp,g_label,0,0,me->def_name,FALSE);
     ex$message(msgnumb = AS_S_PlOpt, type = "%s", var = `c`);
    }
   else
    {
     *c2 = '$';
     strcpy(me->def_name,text);
    }
   break;

 case TEMPLATE_LIST : /*| Get one of the template			      */

   FIfld_get_active_row (fp,g_label,&row,&pos);
   FImcf_get_active_col (fp,g_label,&col,&pos);
   index = row;
   /*"init_notif %d row %d col %d --> template %d\n",init_notif,row,col,index*/

   if(init_notif)
    {
     /*| Initial selection of the line */
       FIfld_get_text(fp,g_label,row,1,macro_MAX_CHAR,text,&sel,&pos);
       if( (me->Temp_Value[index].type & parameter_generic) &&
           (me->Temp_Value[index].type != ~0))
	 {
	  ex$message(msgnumb = AS_P_EnDefValTemp);
          w_row=row;
          w_col=1;
          w_gadget = g_label;
          FIfld_set_text(fp,ERROR_BOX,0,0,text,TRUE);
          FIfld_pos_cursor(fp,ERROR_BOX,0,0,0,0,0,0);
	  FImcf_set_active_col(fp,g_label,1,1);
        }
       else ex$message(msgnumb = AS_P_MdMcDefForm);
    }
   else
   {
    /*| notification due to new value of the line */
    FIfld_get_text(fp,g_label,row,col,80,text,&sel, &pos);
    FIfld_set_text(fp,ERROR_BOX,0,0,"\0",FALSE);
    if(text[0] != '\0')
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
    }
    COm_display_line(fp,TEMPLATE_LIST,2,row,me->dup[row].prompt,
		     me->Temp_Value[row].type,me->Temp_Value+row,&NULL_GRID,0);
    ex$message(msgnumb = AS_P_MdMcDefForm);
   }

   break;
   
  case OTHER_OPTIONS :
   FIfld_get_active_row (fp,g_label,&row,&pos);
   FImcf_get_active_col (fp,g_label,&col,&pos);
   if(init_notif)
    {
     /*| Initial selection of the line */

      text[0] = '\0';
      FIfld_get_text(fp,g_label,row,col,macro_MAX_CHAR,text,&sel,&pos);
      if(row >=  me->Nb_Max_Opt)
	{
	 ex$message(msgnumb = AS_P_KeyNamOptAdd);
	 col = 0;
	 row = me->Nb_Max_Opt;
         text[0] = '\0';
  	 FIfld_set_active_row(fp,OTHER_OPTIONS,row,0);
         FImcf_set_active_col(fp,OTHER_OPTIONS,col,0);
	}
       else if(col == 0)
	{
	 ex$message(msgnumb = AS_P_KeyNewNamOpt);
	}
       else if(col == 1)
	{
	 ex$message(msgnumb = AS_P_KeyNewValOpt);
	}
    }
   else
    {
     FIfld_get_text(fp,g_label,row,col,80,text,&sel, &pos);
     FIfld_set_text(fp,ERROR_BOX,0,0,"\0",FALSE);
     /*"text >%s<\n",text */
     if(text[0] == '\0')
       { if(col == 0 || row == me->Nb_Max_Opt)
	  {
	   if(row<me->Nb_Max_Opt-1)
	    {
	     for(i=row;i<me->Nb_Max_Opt-1;i++)
	     	 me->Opt_Value[i] = me->Opt_Value[i+1];
	     OM_BLOCK_MOVE(me->Opt_Name+(row+1)  *OPT_LEN,
	     		   me->Opt_Name+(row)    *OPT_LEN,
			   (me->Nb_Max_Opt-row-1)*OPT_LEN);
	    }
	    
	   if(row<me->Nb_Max_Opt) me->Nb_Max_Opt--;
	   row = -1;
	  }
	 status = om$send(msg = message COm_modif.write_form(),
			  targetid = my_id);
	}
     else
     {
      if(col== 0)
       { strncpy(me->Opt_Name + row*OPT_LEN,text,80);
	 me->Opt_Name[(row+1)*OPT_LEN -1] ='\0';
       }
      else if(col== 1)
       { if(me->Opt_Value[row].type == text_type)
	  {
	    strncpy(me->Opt_Value[row].var.text_st.text_string,text,80);
	    me->Opt_Value[row].var.text_st.text_string[79] = '\0';
	  }
	 else if(me->Opt_Value[row].type == double_type)
	  {
	    /*
	     * 12/23/92 - Shelley Heard - the following statement did not
	     * compile under ANSI C. 
	     * 
	     *  sscanf(&me->Opt_Value[row].var.root_pm_st.value,"%lf",text);
	     * 
	     *  Without understanding what the code does, I reversed the order
	     *  of the 1st and 3rd arguments, assuming it was an error. 
 	     */
	    sscanf(text,"%lf",&me->Opt_Value[row].var.root_pm_st.value);
	  }
       }
      }

     if(row == me->Nb_Max_Opt)
       {
	if(col == 0)
	 {
	  /* enter value now */
	  me->Opt_Value[row].type = text_type;
	  text[0]='\0';
	  col = 1;
	  ex$message(msgnumb = AS_P_KeyCorVal);
  	  FIfld_set_active_row(fp,OTHER_OPTIONS,row,0);
          FImcf_set_active_col(fp,OTHER_OPTIONS,col,col);
	 }
	else
	 {
	  me->Nb_Max_Opt++;
	  FIfld_set_text(fp,g_label,me->Nb_Max_Opt,0,"\0",FALSE);
	  FIfld_set_text(fp,g_label,me->Nb_Max_Opt,1,"\0",FALSE);
	  row = -1;
	 }
       }
     else row = -1;
    }
    if(row >= 0)
     {
      w_row=row;
      w_col=col;
      w_gadget = g_label;
      FIfld_set_text(fp,ERROR_BOX,0,0,text,TRUE);
      FIfld_pos_cursor(fp,ERROR_BOX,0,0,0,0,0,0);
     }
    else
     {
      ex$message(msgnumb = AS_P_MdMcDefForm);
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
     status = om$send(msg = message COm_modif.form_notification
				(f_label, w_gadget,value,fp,FALSE),
		      targetid = my_id);
     break;

 case DEF_OPTIONS :

  if(me->form_option_ptr == NULL)
   {
    FIf_new( fp, "ASPlSymb", COm_modif_option, &me->form_option_ptr);
    if(me->form_option_ptr)
     {
      int xpos,ypos,screen;
      FIf_get_location(fp,&xpos,&ypos);
      FIf_get_screen(fp,&screen);
      xpos = xpos + 440;  /*420 */
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
  COm_get_form_options(me->form_option_ptr,mac_not_def,
                  &me->hdr_symb,&me->hdr_scroll,&me->hdr_type,
		  &me->hdr_def,me->search_path,&ACglobal_create);
  /*"symb %d scroll %d type %d def %d \n",me->hdr_symb,me->hdr_scroll,me->hdr_type,me->hdr_def */

 case ABORT_OPTIONS :
  FIfld_erase_cursor(me->form_option_ptr,SEARCHDIR);
  FIg_set_state(fp,DEF_OPTIONS,0);
  FIf_erase(me->form_option_ptr);
  FIf_delete(me->form_option_ptr);
  me->form_option_ptr = NULL;
  break;


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

 }
 return(status);
}
end implementation COm_modif;
