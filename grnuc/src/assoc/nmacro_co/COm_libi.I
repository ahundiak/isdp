/*
  ABSTRACT
	commad object to manage macro libraries

  HISTORY
	jla	Creation				?????
	jhw	Fixed path limit problem (TR#119300722)	2/26/93
*/
class implementation COm_lib;

#include "OMmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "acdef.h"
#include "acmacros.h"
#include "ASmessages.h"
#include "FI.h"

#define AS_DEBUG

#define EXIT 1
#define VALIDATE 2
#define FORM_RESTART 3
#define FORM_ABORT 4
#define WD 16
#define PATH 11
#define SAVE 12
#define REVIEW 19
#define ABORT_REVIEW 104

#define SUB_TITLE 14
#define SUB_LIST  11 
#define SAVE_OPTION 20

%safe
Form COm_lib_form_ptr   = NULL;
Form COm_lib_review_ptr = NULL;

static int x_memo = -1,
       y_memo = -1,
       s_memo = -1;
%endsafe

extern int ACpath_gr_number;
extern struct GRid *ACpath_grid;
extern int ACauto_save;

/*

Name
 COdelete_rev_lib_forms
Abstract
 This function is called from the super_object when 
 it gets the sleep message. It deletes the forms so that  
 they won't interfere with journaling when doing a save.
Synopsis

Description
 
Return Value

Notes

Index

Keywords
  form,journaling,macro

History
  02/10/93 : Carlos M. Diaz : created

*/

void COdelete_rev_lib_forms()
{
  if (COm_lib_form_ptr)
  {
    FIf_delete(COm_lib_form_ptr);
    COm_lib_form_ptr = NULL;
  }
   if (COm_lib_review_ptr)
  {
    FIf_delete(COm_lib_review_ptr);
    COm_lib_review_ptr = NULL;
  }
  
}

/******************************************************************************

   Interface function between C-form and CO

******************************************************************************/

COm_lib_review(
  int    f_label,
  int    g_label,
  double value,
  char  *fp)
/*.COm_router*/
{
  COm_lib_router(f_label,g_label+100,value,COm_lib_form_ptr);
  return 1;
}

COm_lib_router(
  int    f_label,
  int    g_label,
  double value,
  char  *fp)
/*.COm_router*/
{
 char *c, *c1, *strchr(), *strrchr();
 int i,row,pos,sel;
 char text[200],text1[200];
 struct GRid macro;
/******** Begin data for TR#119300722 ***********************/
 char * p_text = NULL;
 int status = OM_S_SUCCESS, len = 0;
/******** End data for TR#119300722 *************************/

 switch(g_label)
  {
   int first;

   case EXIT :

   case VALIDATE :
     FIg_get_state(fp,SAVE_OPTION,&ACauto_save);
     FIfld_get_text (fp,WD,0,0,200,text,&sel,&pos);
     /*"wd %s\n",text*/
     ac$construct_wd(mode = AC_SET,
                     name = text);

     FIfld_get_num_rows(fp,PATH,&row);
     /*"nb row %d\n",row */
     first = 1;
     for(i=0 ; i<row; i++)
      {
       FIfld_get_text (fp,PATH,i,0,200,text,&sel,&pos);
       /*"path >%s<\n",text*/
       if(text[0] != '\0')
        {
         if(first) ac$construct_path(mode = AC_SET,
				     name = text);

         else      ac$construct_path(mode = AC_ADD_PATH,
				     name = text);
         first = 0;
        }
      }
     ex$message(msgnumb = AS_S_LibUpt);
     if(g_label == EXIT)
      {
       FIf_get_location(fp,&x_memo,&y_memo);
       FIf_get_screen(fp,&s_memo);
       FIf_erase(fp);
       FIf_delete(fp);
       COm_lib_form_ptr = NULL;
       if(COm_lib_review_ptr != NULL)
	 {
          FIf_erase(COm_lib_review_ptr);
          FIf_delete(COm_lib_review_ptr);
          COm_lib_review_ptr = NULL;
         }
       break;
      }

   case FORM_RESTART :
     FIg_set_state(fp,SAVE_OPTION,ACauto_save);
     ac$construct_wd(mode = AC_INQ,
                     name = text,
		     name_size = 200);
     FIfld_set_text(fp,WD,0,0,text,FALSE);
     /*"wd %s\n",text */

/******** Begin fix TR#119300722 ***********************/
     p_text = text;
     status = ac$construct_path(mode = AC_INQ,
              		        path = p_text,
		       		path_size = 200,
		       		path_len = &len);

     if ((len > 200) || !(status & 1))
     {
	if (p_text = om$malloc (size = ++len))
	{
	    status = ac$construct_path(mode = AC_INQ,
        	      		       path = p_text,
				       path_size = len);
	}
	else
	{
	    status = OM_E_NODYNMEM;
	}
     }

     if (!(status & 1)) 
     {
	break;
     }
/******** End fix TR#119300722 ***********************/

     /*"path %s\n",text */

     c  = p_text;
     row = 0;
     /*"c %s\n",c*/
     while(1)
      {
       /*"c %d %c\n",c,*c */
       c1 = strchr(c,',');
       /*"c1 %d %c\n",c1,*c1 */
       if(c1==c) {c++;continue;}
       if(c1 != NULL) *c1 = '\0';
       FIfld_set_text(fp,PATH,row++,0,c,FALSE);
       /*"add c %s\n",c*/

       if(c1 == NULL) break;
       c = c1+1;
       if(*c == '\0') break;
      }
     FIfld_set_num_rows(fp,PATH,row);

/******** Cleanup for fix TR#119300722 ***********************/
     if (p_text != text)
     {
	om$dealloc (ptr = p_text);
     }
/*************************************************************/

     break;

   case FORM_ABORT :
     FIf_get_location(fp,&x_memo,&y_memo);
     FIf_get_screen(fp,&s_memo);
     FIf_erase(fp);
     FIf_delete(fp);
     COm_lib_form_ptr = NULL;
       if(COm_lib_review_ptr != NULL)
	 {
          FIf_erase(COm_lib_review_ptr);
          FIf_delete(COm_lib_review_ptr);
          COm_lib_review_ptr = NULL;
         }
       break;

   case WD :
     /* add WD in PATH if not already there */
     FIfld_get_text (fp,g_label,0,0,200,text,&sel,&pos);
     /*" WD %s\n",text*/
     if(text[0] != '\0')
      {
       FIfld_get_num_rows(fp,PATH,&row);
       for(i=0;i<row;i++)
        {
	 FIfld_get_text(fp,PATH,i,0,200,text1,&sel,&pos);
         /*" PATH %s\n",text1*/
	 if(strcmp(text1,text) == 0) break;
        }
       if(i >= row)
        {
         /*| Add it in path */
	 FIfld_set_text(fp,PATH,row,0,text,FALSE);
        }
      }
     break;

   case PATH :
    FIfld_get_active_row (fp,g_label,&row,&pos);
    FIfld_get_text (fp,g_label,row,0,200,text,&sel,&pos);
#if 0
/*
 * HGB (07/21/93): don't do this since it corrupts the form...
 */
    if(text[0] == '\0')
	{/*"remove row %d\n",row*/ FIfld_delete_rows(fp,g_label,row,1);}
#endif
    break;

   case SAVE :
    ac$save_wd();
    FIg_set_state_off (fp, g_label);
    break;

   case REVIEW :
    {
    int FORM = 0;

    /* Create sub form if necessary */
     
     if(!COm_lib_review_ptr)
      {
       int xpos,ypos,screen;
       FIf_new( FORM, "ASRevMacLib1", COm_lib_review, &COm_lib_review_ptr);
       if(COm_lib_review_ptr)
       {
        FIf_get_location(fp,&xpos,&ypos);
        FIf_get_screen(fp,&screen);
        xpos = xpos + 485;  /*420 */
        FIf_set_location(COm_lib_review_ptr,xpos,ypos);
        FIf_set_screen(COm_lib_review_ptr,screen);
        FIf_display(COm_lib_review_ptr);
       }
      }

     /* get the macro lib and list its contains */
     
       macro.objid = NULL_OBJID;
       FIfld_get_active_row(fp,PATH,&row,&pos);
       if(row < ACpath_gr_number)
          COm_list_macro(ACpath_grid+row,&macro,COm_lib_review_ptr);
    }
    break;

   case ABORT_REVIEW :
    FIg_set_state(fp,REVIEW,0);
    FIf_erase(COm_lib_review_ptr);
    FIf_delete(COm_lib_review_ptr);
    COm_lib_review_ptr = NULL;
    break;
  }

  


   /* update text on save and review button */

/*  if(COm_lib_form_ptr != NULL)
/*   {
/*    FIg_get_text(fp,SAVE,text);
/* 
/* /***** DOES NOT WORK WHY ???
/* /*     c = strchr(text,'\10');
/* /*     if(c != NULL)
/* /********/
/* 
/*    c = text + 6;
/*    FIg_erase(fp,SAVE);
/*    FIfld_get_text (fp,WD,0,0,200 - (1+ (int) c -(int) text),c+1,&sel,&pos);
/*    FIg_set_text(fp,SAVE,text);
/*    FIg_display(fp,SAVE);
/* 
/*    FIg_get_text(fp,REVIEW,text);
/* 
/*    c = text + 7;
/*    FIg_erase(fp,REVIEW);
/*    FIfld_get_active_row(fp,PATH,&row,&pos);
/*    FIfld_get_text (fp,PATH,row,0,200 - (1+ (int) c -(int) text),c+1,&sel,&pos);
/*    FIg_set_text(fp,REVIEW,text);
/*    FIg_display(fp,REVIEW);
/*   }
/*****/
 return(1);
}

method init (int type; char *string_ptr )
{
 int FORM=0;
 double value;

 /* Initialize form */

 if(COm_lib_form_ptr == NULL)
  {
   FIf_new( FORM, "ASRevMacLib", COm_lib_router, &COm_lib_form_ptr);
  }

 if(COm_lib_form_ptr != NULL)
  {
   if(x_memo != -1)
     {
       FIf_set_location(COm_lib_form_ptr,x_memo,y_memo);
       FIf_set_screen(COm_lib_form_ptr,s_memo);
     }
   FIf_display(COm_lib_form_ptr);
   value = 0;
   COm_lib_router(FORM,FORM_RESTART,value,COm_lib_form_ptr);
  }

 return(OM_S_SUCCESS);
  
}

method execute ( int *response;
                 char *response_data;
                 int  pos)
{
 *response = TERMINATE;
 return(OM_S_SUCCESS);
}

end implementation COm_lib;
