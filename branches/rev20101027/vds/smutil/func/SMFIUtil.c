/* $Id: SMFIUtil.c,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smutil/func / SMFIUtil.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMFIUtil.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1996/03/22  14:21:38  pinnacle
 * Replaced: vdlocate/cmd/VDS_LOCATE.sl for:  by ksundar for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* 
    File             SMFIUtil.c;
    Creation Date    September 92
    Auteur           Jean Jasinczuk (ISDC)

    Some utilities for Forms and gadgets

    History
*/

#include <stdio.h>
#include <varargs.h>
#include <stdlib.h>
#include <FI.h>


/* -----------------------  int SMget_double --------------------------- */
/* This function improve the FIfld_get_value . It recovers a double or   */
/* return 0 if the field is empty or is not representing a double        */

int SMget_double(form,label,row,col,db)
Form    form;    /* [I] */
int     label;   /* [I] */
int     row;     /* [I] */
int     col;     /* [I] */
double *db;      /* [O] */
{
  char txt_value[80];
  int sel_flag,r_pos;
  char *ptr = NULL;

  txt_value[0] = '\0';
  FIfld_get_text(form,label,row,col,80,txt_value,&sel_flag,&r_pos);
  txt_value[79] = '\0';
  if(txt_value[0] == '\0') return 0;
  *db = strtod(txt_value,&ptr);
  if(ptr == NULL) return 1;
  while(*ptr && isspace(*ptr)) *ptr++;
  if(*ptr == '\0') return 1;
  else return 0;
}

/* -------------------- SMSetSingleSelectMode -------------------- */
/* Put all the column of a field gadget in FI_SINGLE_SELECT_MODE   */
/* Deselect all that could have been selected before               */

SMSetSingleSelectMode(form,label,nb_row,nb_col)
Form form;        /* [I] Pointer to the form            */
int  label;       /* [I] Gadget label                   */
int  nb_row;      /* [I] Number of rows in the field    */
int  nb_col;      /* [I] Number of columms in the field */
{
  int col,row;
  long mask;

  /* All column in review mode */
  for(col = 0; col < nb_col ; col++)
    FIfld_set_mode(form,label,col,FI_SINGLE_SELECT);

  FImcf_get_attr(form,label,&mask);
  FImcf_set_attr(form, label,mask | FI_ROW_SELECT);

     /* Deselect all previous row */
     for(row =0; row < nb_row; row++)
       for(col = 0; col < nb_col ; col++)
	 FIfld_set_select(form,label,row,col,0);
  FIg_display(form,label);
}

/* --------------- SMStopSingleSelectMode(va_alist) --------------- */
/* For a gadget field stop single select mode */
/* Form [I] Pointer to the form */
/* int gadget_label [I] */
/* nb_colum  [I] Number of column */
/* Mode for the columm */

SMStopSingleSelectMode(va_alist)
va_dcl
{
  Form form;
  int label,n;
  int col;
  long mask;
  va_list pa;
  int select_mode;

  va_start(pa);
  form  = va_arg(pa,Form);
  label = va_arg(pa,int);
  n     = va_arg(pa,int);

  FImcf_get_attr(form,label,&mask);
  if(mask & FI_ROW_SELECT)
    FImcf_set_attr(form,label,mask ^ FI_ROW_SELECT);
  for(col = 0; col < n; col++)
   {
     select_mode = va_arg(pa,int);
     FIfld_set_mode(form,label,col,select_mode);
   }
  FIg_display(form,label);
}

/* Place text  in the gadget given on parameters */ 
/* Form [I] Pointer to the form  */
/* n    [I] Number of gadget     */
/* int gadget_label [I] , char *text  [I] */
void SMVA_set_text(va_alist)
va_dcl
{
  char *text;
  int n,label,i;
  Form form;
  va_list pa;
 
  va_start(pa);
  form = va_arg(pa,Form);
  n    = va_arg(pa,int);

  for(i = 0; i < n; i++)
   {
     label = va_arg(pa,int);
     text  = va_arg(pa,char *);
     FIg_set_text(form,label,text);
   }
  va_end(pa);
}

/* Place text and default text in the gadgets given on parameters */ 
/* Form [I] Pointer to the form  */
/* n    [I] Number of gadget     */
/* int gadget_label [I] , char *text  [I] */
void SMVA_set_default_text(va_alist)
va_dcl
{
  char *text;
  int n,label,i;
  Form form;
  va_list pa;
 
  va_start(pa);
  form = va_arg(pa,Form);
  n    = va_arg(pa,int);

  for(i = 0; i < n; i++)
   {
     label = va_arg(pa,int);
     text  = va_arg(pa,char *);
     FIg_set_text(form,label,text);
     FIfld_set_default_text(form,label,0,0,text,0);
   }
  va_end(pa);
}


/* Place state and default state in the gadgets given on parameters */ 
/* Argument : */
/* Form [I] Pointer to the form  */
/* n    [I] Number of gadget     */
/* int gadget_label [I] , int state  [I] */
void SMVA_set_default_state(va_alist)
va_dcl
{
  int state;
  int n,label,i;
  Form form;
  va_list pa;
 
  va_start(pa);
  form = va_arg(pa,Form);
  n    = va_arg(pa,int);

  for(i = 0; i < n; i++)
   {
     label = va_arg(pa,int);
     state  = va_arg(pa,int);
     FIg_set_state(form,label,state);
     FIg_set_default_value(form,label,(double)state);
   }
  va_end(pa);
}




/* Place value in the gadgets given on parameters */ 
/* Arguments : */
/* Form [I] Pointer to the form  */
/* n    [I] Number of gadget     */
/* int gadget_label [I] , double value  [I] */
void SMVA_set_value(va_alist)
va_dcl
{
  double value;
  int n,label,i;
  Form form;
  va_list pa;

  va_start(pa);
  form = va_arg(pa,Form);
  n    = va_arg(pa,int);

  for(i = 0; i < n; i++)
   {
     label = va_arg(pa,int);
     value  = va_arg(pa,double);

     FIg_set_value(form,label,value);
   }
  va_end(pa);
}


/* Place value and default value in the gadget given on parameters */ 
/* Arguments : */
/* Form [I] Pointer to the form  */
/* n    [I] Number of gadget     */
/* int gadget_label [I] , double value  [I] */
void SMVA_set_default_value(va_alist)
va_dcl
{
  char tmp[80];
  double value;
  int n,label,i;
  Form form;
  va_list pa;

  va_start(pa);
  form = va_arg(pa,Form);
  n    = va_arg(pa,int);

  for(i = 0; i < n; i++)
   {
     label = va_arg(pa,int);
     value  = va_arg(pa,double);

     FIg_set_value(form,label,value);
     sprintf(tmp,"%g",value);
     FIfld_set_default_text(form,label,0,0,tmp,0);
   }
  va_end(pa);
}

/* Disable a series of gadget in a form */
/* Arguments : */
/* Form [I] Pointer to the form  */
/* n    [I] Number of gadget     */
/* int gadget_label [I] */
void SMVA_disable(va_alist)
va_dcl
{
  int n,label,i;
  Form form;

  va_list pa;

  va_start(pa);
  form = va_arg(pa,Form);
  n    = va_arg(pa,int);

  for(i = 0; i < n; i++)
   {
     label = va_arg(pa,int); 
     FIg_disable(form,label);
   }
  va_end(pa);
}

/* Enable a series of gadget in a form */
/* Arguments : */
/* Form [I] Pointer to the form  */
/* n    [I] Number of gadget     */
/* int gadget_label [I] */
void SMVA_enable(va_alist)
va_dcl
{
  int n,label,i;
  Form form;

  va_list pa;

  va_start(pa);
  form = va_arg(pa,Form);
  n    = va_arg(pa,int);

  for(i = 0; i < n; i++)
   {
     label = va_arg(pa,int); 
     FIg_enable(form,label);
   }
  va_end(pa);
}

/* Display a series of gadget in a form */
/* Arguments : */
/* Form [I] Pointer to the form  */
/* n    [I] Number of gadget     */
/* int gadget_label [I] */
void SMVA_display(va_alist)
va_dcl
{
  int n,label,i;
  Form form;

  va_list pa;

  va_start(pa);
  form = va_arg(pa,Form);
  n    = va_arg(pa,int);

  for(i = 0; i < n; i++)
   {
     label = va_arg(pa,int); 
     FIg_display(form,label);
   }
  va_end(pa);
}

/* Erase a series of gadget in a form */
/* Arguments : */
/* Form [I] Pointer to the form  */
/* n    [I] Number of gadget     */
/* int gadget_label [I] */
void SMVA_erase(va_alist)
va_dcl
{
  int n,label,i;
  Form form;

  va_list pa;

  va_start(pa);
  form = va_arg(pa,Form);
  n    = va_arg(pa,int);

  for(i = 0; i < n; i++)
   {
     label = va_arg(pa,int); 
     FIg_erase(form,label);
   }
  va_end(pa);
}








