class implementation COm_place;

#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include <limits.h>
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "expmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "FI.h"
#include "grclasses.h"
#include "grmsg.h"


#define AS_DEBUG

from expression   import list;
from IGRdir 	  import translate;
from ACmacro_defn import ACgive_upscan;
from GRvg	  import GRgetname;
from ACpretend    import ACfind_parent,ACgive_downscan;
from ACrg_collect import AClist_attribute;


COm_display_line(fp,gadget,num_col,i_row,
		 prompt,Temp_Type,Temp_Value,Temp_List,mytype)
char *fp;
int gadget,num_col,i_row;
char *prompt;
int Temp_Type;
struct ret_struct *Temp_Value;
struct GRid *Temp_List;
int mytype;
{
 char text[DI_PATH_MAX],text1[DI_PATH_MAX],text2[DI_PATH_MAX];
 char temp_text [DI_PATH_MAX];
 IGRlong status,msg;
 char *c,*strchr(),*strrchr();

 status = msg = OM_S_SUCCESS;

/* name */
 
     if(num_col > 1)
        FIfld_set_text(fp,gadget,i_row,0,prompt,FALSE);

/* type */
/*     strcpy(text,"other type");*/
     ex$message (msgnumb = AS_S_OthrType, buff = text);

     if(Temp_Type & macro_generic)
        {
/*	  strcpy(text,"const ");*/
          ex$message (msgnumb = AS_S_Const, buff = text);
	  strcat(text,Temp_Value->var.macro_st.name);
	}
     else if(Temp_Type & class_generic)
        {
/*	  strcpy(text,"class ");*/
          ex$message (msgnumb = AS_S_Class, buff = text);
	  strcat(text,Temp_Value->var.macro_st.name);
	}
     else
      {
       text[0] = '\0';
       if(Temp_Type & line_generic)  {
            ex$message (msgnumb = AS_S_Line, buff = text);
            strcat(text," | ");
       }
       if(Temp_Type & point_generic) {
            ex$message (msgnumb = GC_I_point, buff = text);
            strcat(text," | ");
       }
       if(Temp_Type & conic_generic) {
            ex$message (msgnumb = GC_I_circle, buff = text);
            strcat(text," | ");
       }
       if(Temp_Type & curve_generic) {
            ex$message (msgnumb = GC_I_curve, buff = text);
            strcat(text," | ");
       }
       if(Temp_Type & parameter_generic)
        { if(Temp_Type == double_type)  {
              ex$message (msgnumb = AS_S_Double, buff = text);
              strcat(text," | ");
          }
          else if(Temp_Type == text_type)  {
              ex$message (msgnumb = GC_I_text, buff = text);
              strcat(text," | ");
          }
	  else {
             ex$message (msgnumb = AS_S_Double, buff = text);
             strcat(text," | ");
             ex$message (msgnumb = GC_I_text, buff = temp_text);
             strcat(text, temp_text);
             strcat(text," | ");
          }
	}
       if(Temp_Type & lbs_generic)  {
          ex$message (msgnumb = GC_I_text, buff = text);
          strcat(text," | ");
       }
       if(Temp_Type & ref_generic)  {
          ex$message (msgnumb = AS_S_CoordSys, buff = text);
          strcat(text," | ");
       }
       if(Temp_Type & debug_type)   {
          ex$message (msgnumb = GR_I_plane, buff = text);
          strcat(text," | ");
       }
       if(Temp_Type & other_generic) {
          ex$message (msgnumb = AS_S_OthrType, buff = text);
          strcat(text,"other type | ");
       }
       c = strrchr(text,'|');
       if(c) *c = '\0';
      }


/* Type in col 1 when there are 3 col */

     if(num_col == 3)
       {
        FIfld_set_text(fp,gadget,i_row,1,text,FALSE);
        if(Temp_List->objid == NULL_OBJID)
	 {
	  if(mytype){ ex$message(buff = text,msgnumb = AS_S_NotMod); }
	  else      { ex$message(buff = text,msgnumb = AS_S_NotDef); }
	 }
	else
	 {
	  if(mytype == 2){ ex$message(buff = text,msgnumb = AS_S_Modify); }
	  else      { ex$message(buff = text,msgnumb = AS_S_Def); }
	 }
       }

/* Type or value in the last column  */

     c = text;

     if((Temp_Value->type & parameter_generic)&& (Temp_Value->type!= ~0))
      {
       if(Temp_List->objid != NULL_OBJID)
        {
         status=om$send(msg = message expression.list(text),
			senderid = NULL_OBJID,
                        targetid = Temp_List->objid,
                        targetos = Temp_List->osnum);
	 if(!(status&1))Temp_List->objid = NULL_OBJID;
         else
          {
           char *b1,*b2;
           /*" remove the shit in %s\n",text */
           if(text[0] == '\\')
            {if( strchr(text,'=') != NULL) c = strchr(text,'=')+1;}

           for(; *c == ' ' ; c++);

           for(b1=c,b2=c;*b1 != '[' && *b1 != '\0';b1++)
            {if( *b1 != ' ') *b2++ = *b1;}
           *b2 = '\0';
           /*"result %s\n",c*/
          }
        }
       else status = 0;

       if(!(status&1) && !(mytype&2))
        { if(Temp_Value->type == double_type)
	    sprintf(text,"%g",Temp_Value->var.root_pm_st.value);
	  else
	    strcpy(text,Temp_Value->var.text_st.text_string);
        }
      }
     else
      {
       status = om$send(msg = message ACpretend.ACgive_downscan(text1),
		      senderid = NULL_OBJID,
                      targetid = Temp_List->objid,
                      targetos = Temp_List->osnum);
       if(status&1)
        {
         struct GRid mac;
	 status = om$send(msg = message ACpretend.ACfind_parent(&mac,NULL,NULL),
		      senderid = NULL_OBJID,
                      targetid = Temp_List->objid,
                      targetos = Temp_List->osnum);
         if(status&1)
           {
            status = om$send(msg = message GRvg.GRgetname(&msg,text2),
		      senderid = NULL_OBJID,
                      targetid = mac.objid,
                      targetos = mac.osnum);
 	    if(status&msg&1)
              { strcat(text2,":");strcat(text2,text1); c = text2; }
	   }
	}
      else
        {
         status = om$send(msg = message GRvg.GRgetname(&msg,text1),
		      senderid = NULL_OBJID,
                      targetid = Temp_List->objid,
                      targetos = Temp_List->osnum);
         if(status&msg&1) c = text1;
        }
     }

     /*"value %s\n",text */
     FIfld_set_text(fp,gadget,i_row,num_col-1,c,FALSE);
 return 1;
}

/* Display filed with eligible values */

#argsused
COm_display_elig(fp,text_hdr,field,elig_coll,str)
char *fp;
int text_hdr,field;
struct GRid *elig_coll;
struct ret_struct *str;
/*.COm_display_elig*/
{
struct ACrg_coll _attr_list[5], *attr_list;
char text[80];
IGRlong msg,status;
int i,nb_attr;
int sel=0;
double fabs();

msg = status = OM_S_SUCCESS;

/* Get eligible values */

attr_list = _attr_list;
status = om$send(msg = message ACrg_collect.AClist_attribute(&msg,5,
					attr_list,&nb_attr),
		 senderid = NULL_OBJID,
		 targetid = elig_coll->objid,
		 targetos = elig_coll->osnum);
as$status(action = RET_STATUS);

/*
/* KLUDGE TO JUST HAVE VDS REPRESENTATION AND NOT SUB REPRESENTATION */
/*
/* if(strcmp(attr_list[0].name,"Symbolic")) nb_attr = 3;
/***/
 
if(nb_attr >5)
 { 
  attr_list = (struct ACrg_coll *) om$malloc
				(size = nb_attr*sizeof(struct ACrg_coll));
  status = om$send(msg = message ACrg_collect.AClist_attribute(&msg,nb_attr,
					attr_list,&nb_attr),
		 senderid = NULL_OBJID,
		 targetid = elig_coll->objid,
		 targetos = elig_coll->osnum);
  as$status(action = RET_STATUS);
 }


if(nb_attr >0)
 {
/*" field %d text %d\n",field,text */
  FIg_disable(fp,TEMPLATE_LIST);
  FIg_display(fp,field);

  for (i=0 ; i<nb_attr ; i++)
   {
    if(attr_list[i].desc.type == AC_ATTRIB_TEXT)
     {
      if(strcmp(attr_list[i].desc.value.att_txt,
			str->var.text_st.text_string)) sel=FALSE;
      else sel=TRUE;
      FIfld_set_text(fp,field,i,1,attr_list[i].desc.value.att_txt,sel);
     }
    else if(attr_list[i].desc.type == AC_ATTRIB_DOUBLE)
     {
      if(fabs(attr_list[i].desc.value.att_exp-
			str->var.root_pm_st.value)>1.e-6) sel=FALSE;
      else sel=TRUE;

      /*"att %d sel %d\n",i,sel */
      sprintf(text,"%5.3lf",attr_list[i].desc.value.att_exp);
      FIfld_set_text(fp,field,i,1,text,sel);
     }
    FIfld_set_text(fp,field,i,0,attr_list[i].name,sel);
   }
 }

if(nb_attr >5) om$dealloc(ptr = attr_list);
return OM_S_SUCCESS;
}

method write_form ()
{
int i;
int attr;
char * fp;
char *c,*strrchr();
long status;

/*" Display Macro name %s\n",me->macro_name */

  status = OM_S_SUCCESS;

  fp = me->form_ptr;
 
  c = strrchr(me->macro_name,':');
  if(!c) c = me->macro_name;
  else c += 1;

  FIg_erase(fp,MAC_NAME);
  FIg_set_text(fp,MAC_NAME,c);
  FIg_display(fp,MAC_NAME);

/* Erase eligible values if displayed */

  FIg_get_attr(fp,ELIGIBLE_LIST,&attr);
  if(!(attr&FI_NOT_DISPLAYED))
   {
    FIg_erase(fp,ELIGIBLE_LIST);
    FIg_enable(fp,TEMPLATE_LIST);
   }
 
/*" Display macro template nb %d\n",me->Nb_Max_Temp */

  FIfld_set_num_rows(fp,TEMPLATE_LIST,me->Nb_Max_Temp);
  for(i=0;i<me->Nb_Max_Temp;i=i+1)
    {
     status = om$send(msg = message COm_place.write_template
                      			  (me->Temp_List+i,i),
                         targetid = my_id);
    }

/* display occurence name if naming form is displayed */
 
 if(me->form_names_ptr)
  COm_display_names(me->form_names_ptr,me->hdr_name, me->temp_name);

return(OM_S_SUCCESS);
}

/* field the form with template/occurence names */

COm_display_names(form_names_ptr,hdr_name,temp_name)
 char *form_names_ptr,*hdr_name,*temp_name;
{
 char text[80];
 int row,sel;

 if(form_names_ptr == NULL) return OM_S_SUCCESS;

 /*| occurance name                                           */
 FIfld_set_text(form_names_ptr,OCC_NAME,0,0,hdr_name,FALSE);

 /* template name */
 if (temp_name[0] == '\0')      row=0;
 else if (temp_name[0] == '.')  row=1;
 else                           row=2;


 FIfld_get_list_text(form_names_ptr,TEMP_NAME,row,0,80,text,&sel);
 FIfld_set_list_select(form_names_ptr,TEMP_NAME,row,0,TRUE);
 FIfld_set_text(form_names_ptr,TEMP_NAME,0,0,text,TRUE);

 return OM_S_SUCCESS;
}

method write_template(struct GRid *template;int itemp)
{
 int iline,ncol,gadget,g_type;
 int display_line_mode;
 char *fp;
 long sts;
 int *ptr;
 

/* get gadget and row number */

if(me->user_form_ptr)
 {
 /* Retrieve the gadget number corresponding to the form */
 /* trick to store gadget number in an hole of the structure ret_struct */
  
  ptr = (int *) (me->Temp_Value+itemp);
  gadget = ptr[1];
  fp = me->user_form_ptr;
  iline = 0;

  sts = FIg_get_type(fp,gadget,&g_type);
  if(sts != FI_SUCCESS) return OM_S_SUCCESS;
  else if(g_type == FI_FIELD) 
	ncol = 1;
  else if(g_type == FI_MULTI_COL)
	sts = FImcf_get_num_cols(fp,gadget,&ncol);
  else return OM_S_SUCCESS;
 }
else
 {
  fp = me->form_ptr;
  iline = itemp;
  ncol = 2;
  gadget = TEMPLATE_LIST;
 }
 
/* how to write in the gadget */

 if(me->mytype&1 && me->set_index >= 0 ) display_line_mode = 2;
 else if(me->mytype&1) display_line_mode = 1;
 else display_line_mode = 0;

 COm_display_line(fp,gadget,ncol,iline,
                       me->dup[itemp].prompt,
                        me->dup[itemp].type,
                        me->Temp_Value+itemp,
                        template,display_line_mode);
 return OM_S_SUCCESS;
}

method set_action_and_state(enum possible_actions action;
			    enum possible_states  state)
{
 long size;
 int  resp;
 char data[1];
 IGRlong status,msg;

     status = msg = OM_S_SUCCESS;

 /*"set state to %d and action to %d\n",state,action */
     me->action = action;
     me->state =  state;
     me->Entry_Request = NOTHING;

     resp = ABS_DIG; /* Just to have an "unkown" */
     data[0]=0;
     size = 1;
     status = ex$putque(msg = &msg, response = &resp,
                      byte = &size, buffer = data);

     return (OM_S_SUCCESS);
}

#argsused
COm_set_form_select(macro_def,macro_name,fp)
struct GRid *macro_def;
char *macro_name;
char *fp;
/*.COmset_form_select*/
{
 extern int ACpath_gr_number;
 extern struct GRid *ACpath_grid;

 char macro_lib_name[80];
 int i,select,num_row;
 struct GRid  selected_lib;

/*" arguments macro_def %d %d\n",macro_def->objid,macro_def->osnum*/

/*^ { if(macro_name != NULL)  printf("macro_name %s\n",macro_name);} */

/* Get and display macro libraries */

  selected_lib.objid = NULL_OBJID;

  FIfld_get_num_vis_rows(fp,MACRO_LIB,&num_row);
  for(i=0; i<ACpath_gr_number; i++)
   {
    if(   ACpath_grid[i].osnum  == macro_def->osnum 
       || ACpath_gr_number      == 1               )
       {select = TRUE; selected_lib = ACpath_grid[i];
	/*"lib found in %d\n",i */ } 
    else select = FALSE;

    ACos_to_path(ACpath_grid[i].osnum,macro_lib_name);

    FIfld_set_text(fp,MACRO_LIB,i,0,macro_lib_name,select);

    if(select) 
	 FIfld_set_active_row(fp,MACRO_LIB,i, i<num_row-1 ? i : num_row-1);
   }

/* Get and display macro in the selected macro library */

   if(selected_lib.objid != NULL_OBJID)
				     COm_list_macro(&selected_lib,macro_def,fp);
 return 1;
}

/* Display in the form the macros contained in osnum */

COm_list_macro(macro_lib,macro_def,fp)
struct GRid  *macro_lib,*macro_def;
char *fp;
/*.COm_list_macro*/
{
  int i_lines,nb_lines;
  int status,msg;
  char dir_name[DI_PATH_MAX];
  char **lines = NULL;
  int select,num_row,row;
  char *macro_name,*strrchr();
#define ARGUMENT_LEN 200
  char argument[ARGUMENT_LEN];
  struct GRid macro;
  struct sup *dup;
  int Nb_Max_Temp,i_temp,dummy;
  int len,len_arg;
  GRclassid obj_class;
  extern GRclassid OPP_ACcpx_defn_class_id;
  char *macro_lib_name,*strrchr();

/*| Get contents of selected macro library */

  status = di$give_pathname ( osnum =  macro_lib->osnum,
                              pathname =  dir_name);

  macro_lib_name = strrchr(dir_name,':');
  if (macro_lib_name)
   {
    FIg_erase(fp,MACRO_IN_LIB_TITLE);
    status = FIg_set_text(fp,MACRO_IN_LIB_TITLE,macro_lib_name+1);
    FIg_display(fp,MACRO_IN_LIB_TITLE);
   }
  

  strcat(dir_name,":constructs:*");

  /*"path_name %s\n",dir_name */

  status = di$ls( regexp = dir_name ,
		  options = NULL,
                  lines = &lines ,
                  ptr = &nb_lines);

  if(!(status&1)) return(OM_S_SUCCESS);

/*"Initialize field : %d lines and selected lines\n",nb_lines */

  FIfld_set_num_rows(fp,MACRO_IN_LIB,0);

  if(nb_lines == 0) return(OM_S_SUCCESS);

/*| Display the macros */

  FIfld_get_num_vis_rows(fp,MACRO_IN_LIB,&num_row);

  row = 0;
  for(i_lines=0;i_lines<nb_lines;i_lines=i_lines+1)
    {
     /*" %d\n",i_lines */
     /*| Get information about macro */

     macro_name = strrchr(lines[i_lines],':');
     if(macro_name != NULL) macro_name = macro_name + 1;
     else		    macro_name = lines[i_lines];
     /*^if(macro_name != NULL)  printf("%s\n",macro_name);*/

     status = om$send ( msg = message IGRdir.translate( &msg, macro_name,
                                                0,NULL,&macro.objid),
                     senderid = NULL_OBJID,
                     targetid = macro_lib->objid,
                     targetos = macro_lib->osnum );
     if(!(status&msg&1)) continue;
     macro.osnum = macro_lib->osnum;

     om$get_classid(objid = macro.objid,
		    osnum = macro.osnum,
		    p_classid = &obj_class);
     if(om$is_ancestry_valid(superclassid = OPP_ACcpx_defn_class_id,
			     subclassid = obj_class) != OM_S_SUCCESS) continue;

     /*"%s --> %d\n",macro_name,macro.objid */

     status = om$send(msg = message ACmacro_defn.ACgive_upscan
                             		       (&Nb_Max_Temp,&dummy,&dup),
                      senderid = NULL_OBJID,
                      targetid = macro.objid,
                      targetos = macro.osnum );
     if(!(status&1)) continue;
  


     /*| Display Name */

     if(macro_def->objid != macro.objid) select = FALSE;
     else				 select = TRUE;
     FIfld_set_text(fp,MACRO_IN_LIB,row,0,macro_name,select);

     /*| Display Argument descriptions */

     argument[0] = '(';
     len = 1;

     for(i_temp=0 ; i_temp<Nb_Max_Temp ; i_temp++)
      {
       len_arg = strlen(dup[i_temp].prompt);
       if(len_arg > ARGUMENT_LEN -len -3) len_arg = ARGUMENT_LEN -len -3;
       OM_BLOCK_MOVE(dup[i_temp].prompt,argument+len,len_arg);
       len += len_arg;
       /*"argument %d --> len %d\n",i_temp,len*/
       if(len >= ARGUMENT_LEN -3) break;
       if(i_temp<Nb_Max_Temp-1) { argument[len++]=','; }
      }
     argument[len] = ')';
     argument[len+1] = '\0';
     /*"argument %s\n",argument */
     FIfld_set_text(fp,MACRO_IN_LIB,row,1,argument,select);

     /*^ if(select) printf("found in %d\n",i_lines); */

     if(select) FIfld_set_active_row
	     (fp,MACRO_IN_LIB,row, row<num_row-1 ? row : num_row-1);

     row += 1;

    }


 
  if(lines != NULL && nb_lines != 0)
   {
    di$free(lines = lines,
            count = nb_lines);
    if(!(status&1))di$report_error(sts = status);
   }
 return 1;
}


ACcheck_expression_name( char *response_data)

{
 IGRint i=0;
 int ret_status=1;
 char *strchr();

 /* Reject all the blanks, '+','-' signs and look for the first occurance of
    a digit or alphabet. subhasish */

 while(!isalnum(response_data[i]))
    i++;
 if(response_data[i]=='\0')
    ret_status = 0;
 /* If the first letter is an alphabet then look for '=' */
 else if(isalpha(response_data[i]))
   if(!strchr(response_data,'='))
    ret_status = 0;
 return(ret_status);
}

end implementation COm_place;
