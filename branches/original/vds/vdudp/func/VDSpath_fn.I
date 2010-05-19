/* $Id: VDSpath_fn.I,v 1.2 2001/01/19 22:16:18 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdudp/func / VDSpath_fn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSpath_fn.I,v $
 *	Revision 1.2  2001/01/19 22:16:18  ramarao
 *	Merged from SP.
 *	
# Revision 1.1  2000/05/31  22:18:18  pinnacle
# Created: vds/vdupd/func/VDSpath_fn.I by rchennup for Service Pack
#
# Revision 1.2  1998/08/28  16:34:10  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/11/17  10:45:56  pinnacle
# Replaced: vdudp/func/VDSpath_fn.I for:  by msbraju for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/28/98	adz		correction 'path not found'.
 * -------------------------------------------------------------------*/

 /****************************************************
/*
/* funtions implementing the macros given
/* in VDSudp_mac.h and VDSudp_priv.h
/*
/* 	1.  VDSset_current 
/* 	2.  VDSget_active_symb -
/* 	3.  VDSgive_symb 
/* 	4.  VDSsymb_to_text 
/* 	5.  VDStext_to_symb 
/* 	6.  VDSpath_name 
/* 	7.  VDSout_path -
/* 	8.  VDSextract_part_exp -
/* 	9.  VDSextract_all_part_exp -
/* 	10. VDSpath_in_list 
/* 	11. VDSname_in_list 
/* 	12. VDSinit_path 
/* 	13. VDSget_path  
/* 	14. VDSget_search_path 
/* 	15. VDSdelete_path 
/* 	16. VDStranslate -
/* 	17. VDSuntranslate -
/* 	18. VDSauto_name  
/* 	19. VDSgive_exp 
/* 	20. VDSname_exp 
/* 	21. VDSset_act_path 
/* 	22. VDSadd_path 
/* 	23. VDSsymbology_from_path 
/* 	24. VDSpath_from_level 
/*
/*     History :
/*       15 Juil 92  : Jean
	 For 2.0 substitute EXP_locate() (no longer exists)
	 with VDexp_locate() 
         Implements VDexp_locate()  
	 
	 13 April 93 : Update for 2.2

/****************************************************/

class implementation Root;

#include <stdio.h>
#include <ctype.h>
#include <string.h>

#include "OMerrordef.h"
#include "OMprimitives.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "parametric.h"
#include "adpdef.h"
#include "igewindef.h"
#include "wl.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"

#include "exdef.h"
#include "exmacros.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSudp_priv.h"
#include "v_dbgmacros.h"

#include "AS_status.h"

#define AS_DEBUG 1

extern IGRboolean ASbroadcast_in_progress;

%safe
IGRshort VDexp_locate();
%endsafe

from 	text_exp 	import  NDgive_structure, modify,give_formula,list;

/*1---------------------- VDSset_current -----------------------------------
/*    	This function is used to set the current directory and the 
/*	current symbology.
/* 
/* */
VDSset_current(
char			*current_dir, 	/* (I) dir to set active	*/
char			*path,		/* (I) relative path		*/
char			*out_path,	/* (O) out_path			*/
struct GRsymbology	*symbology	/* (I) symbology to set active	*/
)
/*.VDSset_current*/
{
long			msg,sts;
IGRlong			NumberOfBytes;


if(out_path != NULL)
 {
   sts = vds$out_path(in_path =  current_dir, 
		      ref_path = path,
		      out_path = out_path);
   if (! (sts & 1))
	{ 
	  printf("error vds$out_path\n");
    	  return OM_E_ABORT;
	}
  }
sts = di$cd(dirname = current_dir,
            path    = path);  
if(sts != DIR_S_SUCCESS)	return OM_W_WARNING;

if(symbology != NULL)
 {

   NumberOfBytes = sizeof( symbology->level);
   gr$put_active_level(	msg    = &msg,
			sizbuf = &NumberOfBytes,
			buffer = &symbology->level);
    
   if ( !(msg&1)) 
    {
	printf("error put_active_level\n");
    	return OM_E_ABORT;
    }

   NumberOfBytes = sizeof( symbology->display_attr);
   gr$put_active_display(  msg    = &msg,
			   sizbuf = &NumberOfBytes,
			   buffer = &symbology->display_attr);

   if ( !(msg&1))
    {
	printf("error put_active_display\n");
	return OM_E_ABORT;
    }
 }

return OM_S_SUCCESS;

}


/*2---------------------- VDSget_active_symb -----------------------------------
/*    
/*    	This macro is used to return the active symbology 
/*    
/**/

VDSget_active_symb(
struct GRsymbology  *symbology    /* (O) return symbology	*/
)
{
IGRlong		NumberOfBytes;
IGRlong		BytesReceived;
long		msg;

if(symbology == NULL)
 {
  printf("ERROR: symbology must be allocated\n");
  return OM_E_ABORT;
 }
 NumberOfBytes = sizeof( symbology->level);
 gr$get_active_level(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = &symbology->level,
            nret = &BytesReceived);

 if ( !(msg&1)) {printf("error get_active_level\n");return OM_E_ABORT;}


 NumberOfBytes = sizeof( symbology->display_attr);
 gr$get_active_display(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = &symbology->display_attr,
            nret = &BytesReceived);
 if ( !(msg&1)) {printf("error get_active_display\n");return OM_E_ABORT;}


return OM_S_SUCCESS;
}

/*3---------------------- VDSgive_symb -----------------------------------
/*
/*    	This function is used to return the symbology given by the txt_symb
/*    	structure
/*
/**/

VDSgive_symb(
struct GRsymbology  *symbology,   /*  (O) return symbology */
struct txt_symb	    *txt_symb    /*  (I) text symbology */
)
{
 int  			wrk_value;
 IGRlong		NumberOfBytes;
 IGRlong		BytesReceived;
 IGRchar		buf[DI_PATH_MAX];
 long			msg;
 struct GRsymbology  	symb;    

 if(strncmp(txt_symb->color,"act",3) == 0 || strncmp(txt_symb->style,"act",3) == 0
    || strncmp(txt_symb->weight,"act",3) == 0)
  {

    NumberOfBytes = sizeof( symb.display_attr);
    gr$get_active_display(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = &symb.display_attr,
            nret = &BytesReceived);
    if ( !(msg&1)) {printf("error get_active_display\n");return OM_E_ABORT;}
  }

/* -- fill color -- */

  if(strncmp(txt_symb->color,"act",3) == 0)
   {
     /* active color */

      symbology->display_attr.color = symb.display_attr.color;
   }
  else
   {
     if(isalpha(txt_symb->color[0]))
      {
	/* color by name */

	if( !(ige$get_color_from_name(name = txt_symb->color,
                                      color = (IGRshort *)&symbology->display_attr.color)))
	  {
         	sprintf(buf, "Invalid color name %s, take active one",txt_symb->color);
	 	UI_status(buf);
		symbology->display_attr.color = symb.display_attr.color;
	  }
      }
     else
     {
      	sscanf(txt_symb->color,"%d", &wrk_value);
    	symbology->display_attr.color = (short unsigned)wrk_value;
     }
   }

/* -- fill style -- */

  if(strncmp(txt_symb->style,"act",3) == 0)
   {
     /* active style */

      symbology->display_attr.style = symb.display_attr.style;
   }
  else
   {
      	sscanf(txt_symb->style,"%d", &wrk_value);
    	symbology->display_attr.style = (short unsigned)wrk_value;
   }

/* -- fill weight -- */

  if(strncmp(txt_symb->weight,"act",3) == 0)
   {
     /* active weight */

      symbology->display_attr.weight = symb.display_attr.weight;
   }
  else
   {
      	sscanf(txt_symb->weight,"%d", &wrk_value);
    	symbology->display_attr.weight = (short unsigned)wrk_value;
   }

/* -- fill level -- */

  if(strncmp(txt_symb->layer,"act",3) == 0)
   {
     /* active level */

    NumberOfBytes = sizeof( symbology->level);
    gr$get_active_level(	msg = &msg,
            			sizbuf = &NumberOfBytes,
            			buffer = &symbology->level,
            			nret = &BytesReceived);

    if ( !(msg&1)) {printf("error get_active_level\n");return OM_E_ABORT;}
   }
  else
   {
      	sscanf(txt_symb->layer,"%d", &wrk_value);
    	symbology->level = (short )wrk_value;
   }

return OM_S_SUCCESS;
}


/*8---------------------- VDSextract_part_exp ------------------------*/
/* 	function which return in before the part of exp  
/*	before the char 'sep_char' and in after the part of exp  
/*	after sep_char            
/* 	If no sep char found, before[0] = '\0' 			    
/**/

int VDSextract_part_exp(
char    *exp,	  /* (I) nb elts allocated for part_exp */
char    *before,  /* (I) expression to partition	*/
char    *after,  /* (O) nb part returned		*/
char	sep_char /* (I) separate char			*/
)
/*.VDSextract_part_exp*/
{
  int i, length;

  if(exp == NULL || before == NULL || after == NULL)
   {printf("ERROR: arguments cannot be NULL\n");return OM_E_ABORT;}


  if(exp[0] == '\0'){
    /*|no sep_char in input because exp empty */
    before[0] = '\0';
    strcpy(after, exp);
    return OM_E_ABORT;
  }

  /* look for the char */

  for (i = 0, length = strlen ( exp);(i < length) && (exp[i] != sep_char); i++);

  if (i == length)
  {
    /*|no sep_char in input*/

    before[0] = '\0';
    strcpy(after, exp);
    return OM_E_ABORT;
  }
  else
  {
    strncpy (before, exp, i);
    before[i]='\0';
    strcpy ( after, &(exp[i+1]) );
  }
   EXP_strip(before);
   EXP_strip(after);
  
return OM_S_SUCCESS;

}


/*4---------------------- VDSsymb_to_text -----------------------------------
/*    	This macro is used to return the color, layer,weight, style given by 
/*    	the symbology expression.
/*
/*    struct txt_symb	*txt_symb (O)   : returned text symbology
/*    char 		*exp_symb (I)   : value of symbology expression 
/**/

VDSsymb_to_text(
struct txt_symb	*txt_symb,	/* (O) returned text symbology */
char 		*exp_symb	/* (I) value of symbology expression  */
)
{

int 		  len;
char		  save_exp[MY_MAX],sep_char,before[MY_MAX],after[MY_MAX],
		  symb_name[MY_MAX],after1[MY_MAX],symb_value[MY_MAX], 
		  buf[DI_PATH_MAX];

int		  sts;
int		  wrk_value;

sep_char =',';

if(txt_symb == NULL)
   {printf("ERROR: argument txt_symb cannot be NULL\n"); return OM_E_ABORT;}

if(exp_symb == NULL)
  {
    /* exp_symb = NULL -> active symbology */

    strcpy(txt_symb->color,"act");
    strcpy(txt_symb->layer,"act");
    strcpy(txt_symb->weight,"act");
    strcpy(txt_symb->style,"act");
    txt_symb->layer_name[0] = '\0';
    return OM_S_SUCCESS;
  }
len = strlen(exp_symb);
if(len>=MY_MAX){printf("ERROR: [%s] is too long\n",exp_symb);return OM_E_ABORT;}


strcpy(save_exp,exp_symb);

sts = VDSextract_part_exp(save_exp, before, after,sep_char);
if(!(sts & 1)){printf("ERROR: no ',' found\n");return OM_E_ABORT;}


if( before[0] == '\0') {printf("ERROR: nothing before ','\n");return OM_E_ABORT;}
EXP_extract_lhs_rhs(before,symb_name,symb_value);


/*| a mettre dans la color */
   
if(isalpha(symb_value[0]) && strncmp(symb_value,"act",3)!=0)
 {
   /*|color by name */
   if( !(ige$get_color_from_name(name = symb_value,
				 color = (IGRshort *)&wrk_value)))
    {
         sprintf(buf, "Invalid color name %s, take active one",symb_value);
	 UI_status(buf);
    	 strcpy(txt_symb->color,"act");
	 goto next;
    }
 }
if(isdigit(symb_value[0]))
 {
      	sscanf(symb_value,"%d", &wrk_value);
	if(wrk_value >= 512 || wrk_value <= 0)
    		{printf("ERRROR, invalid in expression\n");return OM_E_ABORT;}
 }   
strcpy(txt_symb->color,symb_value);

next:
strcpy(save_exp,after);


sts = VDSextract_part_exp(save_exp, before, after,sep_char);
if(!(sts & 1)){printf("ERROR: no ',' found\n");return OM_E_ABORT;}


if( before[0] == '\0') {printf("ERROR: nothing before ','\n");return OM_E_ABORT;}
EXP_extract_lhs_rhs(before,symb_name,symb_value);


sts = VDSextract_part_exp(symb_value, before, after1,':');
if(!(sts & 1)){
	/*|ERROR: no ':' found ie no name */
	after1[0] = '\0';
}
else {
	if( before[0] == '\0') {printf("ERROR: nothing before ':'\n");return OM_E_ABORT;}
	strcpy(symb_value,before);
}
strcpy(txt_symb->layer_name,after1);

/*| a mettre dans level */

if(isalpha(symb_value[0]) && strncmp(symb_value,"act",3)!=0)
    {printf("ERRROR, invalid level in expression\n");return OM_E_ABORT;}
if(isdigit(symb_value[0]))
 {
   sscanf(symb_value,"%d", &wrk_value);
    if(wrk_value < GR_LO_LAYER || wrk_value > GR_HI_LAYER) 
     {printf("ERRROR, invalid level in expression\n");return OM_E_ABORT;}
 }
strcpy(txt_symb->layer,symb_value);
strcpy(save_exp,after);


sts = VDSextract_part_exp(save_exp, before, after,sep_char);
if(!(sts & 1)){printf("ERROR: no ',' found\n");return OM_E_ABORT;}


if( before[0] == '\0') {printf("ERROR: nothing before ','\n");return OM_E_ABORT;}
EXP_extract_lhs_rhs(before,symb_name,symb_value);


/*| a mettre dans weight */

if(isalpha(symb_value[0]) && strncmp(symb_value,"act",3)!=0)
    {printf("ERRROR, invalid weight in expression\n");return OM_E_ABORT;}
if(isdigit(symb_value[0]))
 {
   sscanf(symb_value,"%d", &wrk_value);
    if(wrk_value < GR_LO_WEIGHT || wrk_value > GR_HI_WEIGHT) 
     {printf("ERRROR, invalid weight in expression\n");return OM_E_ABORT;}
 }
strcpy(txt_symb->weight,symb_value);
EXP_extract_lhs_rhs(after,symb_name,symb_value);


/*| a mettre dans style */

if(isalpha(symb_value[0]) && strncmp(symb_value,"act",3)!=0)
    {printf("ERRROR, invalid style in expression\n");return OM_E_ABORT;}
if(isdigit(symb_value[0]))
 {
   sscanf(symb_value,"%d", &wrk_value);
    if(wrk_value < GR_LO_STYLE || wrk_value > GR_HI_STYLE) 
     {printf("ERRROR, invalid style in expression\n");return OM_E_ABORT;}
 }
strcpy(txt_symb->style,symb_value);


return OM_S_SUCCESS;
}

/*5---------------------- VDStext_to_symb -----------------------------------
/*    This macro is used to give the expression of the symbology given
/*    the color, weight, style, layer.
/*
/*    struct txt_symb	*txt_symb (I) : text symbology
/*    char 		*exp_symb (O) : return value of symbology expression 
/*
/*
/**/
VDStext_to_symb(
struct txt_symb	*txt_symb, /* (I)  text symbology */
char 		*exp_symb /* (O) return value of symbology expression */
)
{

if(exp_symb == NULL)
   {printf("ERROR: argument exp_symb cannot be NULL\n"); return OM_E_ABORT;}

if(txt_symb == NULL)
 {
   /*|txt_symb == NULL -> expression active */
   strcpy(exp_symb,"color=act,level=act,weight=act,style=act");
   return OM_S_SUCCESS;
 }

strcpy(exp_symb,"color=");
strcat(exp_symb,txt_symb->color);

strcat(exp_symb,",level=");
strcat(exp_symb,txt_symb->layer);

if(txt_symb->layer_name[0] != '\0'){
	strcat(exp_symb,":");
	strcat(exp_symb,txt_symb->layer_name);
}	

strcat(exp_symb,",weight=");
strcat(exp_symb,txt_symb->weight);

strcat(exp_symb,",style=");
strcat(exp_symb,txt_symb->style);


return OM_S_SUCCESS;
}

/*6---------------------- VDSpath_name  -----------------------------------
/*
/*    	This macro is used to return the relative path if the path is
/*    	not absolute (relative is regard to the ref path)
/*
/*    	also return the current dir if path is .
/*
/**/

VDSpath_name (
char 	*in_path , /* (I) input path */
char 	*out_path /* (O) path to use in the dir system */
)
{
char		return_ref[2*DI_PATH_MAX];
long		sts;


if(in_path == NULL || out_path == NULL)
 {
  printf("ERROR: arguments in_path and out_path cannot be NULL\n");
  return OM_E_ABORT;
 }
if (in_path[0] == '.')
   {
     sts = di$pwd(dirname = out_path); 
     if(sts != DIR_S_SUCCESS){printf("error pwd\n");return OM_E_ABORT;} 
   }
else if (in_path[0] != ':') 
   {
     /*| relatif to ref */
       sts = vds$get_path( return_path = return_ref, const_flag = REF_PATH);
       if (! (sts & 1)){ printf("error get ref_path\n");return OM_E_ABORT; }

      strcat(return_ref,":");
      strcat(return_ref,in_path);
      strcpy(out_path,return_ref);

   }
else { /*|out = in */ strcpy(out_path,in_path);}


return OM_S_SUCCESS;

}
/*7---------------------- VDSout_path  -----------------------------------
/*
/*    This macro is used to return the relative path if the path is
/*    not absolute (relative is regard to the ref path). 
/*    Same as vds$path_name but works on instances and not on expressions
/*
/*    also return the current dir if path is .
/*
/**/

VDSout_path(
char 	*in_path ,	/* (I) input path */
char 	*ref_path ,	/* (I) ref_path */
char 	*out_path	/* (O) path relative to reference given */
)
{
char		return_ref[DI_PATH_MAX];
long		sts;

if(in_path == NULL || ref_path == NULL || out_path == NULL)
 {
  printf("ERROR: arguments in_path, ref_path and out_path cannot be NULL\n");
  return OM_E_ABORT;
 }
strcpy(return_ref,ref_path);

if (ref_path[0] == '.')
   {
     sts = di$pwd(dirname = return_ref); 
     if(sts != DIR_S_SUCCESS){printf("error pwd\n");return OM_E_ABORT;} 
   }
else if (ref_path[0] != ':')
   {
     sts = di$pwd(dirname = return_ref); 
     if(sts != DIR_S_SUCCESS){printf("error pwd\n");return OM_E_ABORT;} 
     strcat(return_ref,":");
     strcat(return_ref,ref_path);
   }
if (in_path[0] =='.')
   {
     sts = di$pwd(dirname = out_path); 
     if(sts != DIR_S_SUCCESS){printf("error pwd\n");return OM_E_ABORT;} 
   }
else if (in_path[0] != ':') 
   {
     /*| relatif to ref */
      strcat(return_ref,":");
      strcat(return_ref,in_path);
      strcpy(out_path,return_ref);

   }
else { /*|out = in */ strcpy(out_path,in_path);}


return OM_S_SUCCESS;

}



/*9---------------------- VDSextract_all_part_exp ------------------------*/
/*
/* 	function which return the number of the part_exp separated 
/*	by sep_char in the given expression. 
/*	part_exp is the array of nb_returned expressions 
/* 	that is found in expression between the sep_char.
/**/

VDSextract_all_part_exp(
int	nb_returned,	/* (I) nb elts allocated for part_exp	*/
char    *expression, 	/* (I) expression to partition 		*/
int	*nb_part,	/* (O) nb part returned			*/
char    **part_exp,	/* (O) array of exp returned		*/
char	sep_char	/* (I) separate char			*/
)
{
int		i,len;
char		*wrk_exp,*after,*path;
long		sts;

wrk_exp = NULL;
after   = NULL;
path   = NULL;


if(expression == NULL)
     {printf("ERROR: argument expression cannot be NULL\n");return OM_E_ABORT;}


if(nb_part!=NULL) *nb_part = 0;
len = strlen(expression);

wrk_exp = (char *)om$malloc(size = (len+1)*sizeof(char));
if(!wrk_exp) {printf("Error malloc wrk_exp\n");goto wrapup;}

after = (char *)om$malloc(size = (len+1)*sizeof(char));
if(!after) {printf("Error malloc after\n");goto wrapup;}

path = (char *)om$malloc(size = (len+1)*sizeof(char));
if(!path) {printf("Error malloc path\n");goto wrapup;}


strcpy(wrk_exp,expression);
strcpy(after,expression); /* if nb_returned = 0 must return nb_part of the
			  /* complete expression */

if ((nb_returned) && (part_exp == NULL))
     {
      printf("ERROR: part_exp not allocated\n"); goto wrapup;
     }

for(i=0;i<nb_returned;i++)
  {
    if(part_exp[i] == NULL) 
	{printf("ERROR: part_exp[i] not allocated\n"); goto wrapup;}
    sts = VDSextract_part_exp(wrk_exp, part_exp[i], after, sep_char);
    if(!(sts&1))
      {
       /*| no sep_char found*/

       if(nb_part!=NULL) *nb_part = 1;
       strcpy(part_exp[i],wrk_exp);
       goto success;
      }

    strcpy(wrk_exp,after);
    if(nb_part != NULL) *nb_part = *nb_part + 1;
   }


if(nb_part != NULL)
 {
  strcpy(wrk_exp,after);
  while (1)
   {
     sts = VDSextract_part_exp(wrk_exp, path, after, sep_char);
     if(!(sts&1)){ /*|no sep_char found*/ *nb_part = *nb_part + 1;break;}
     strcpy(wrk_exp,after);
     *nb_part = *nb_part + 1;
   }
 }
goto success;
success:
	if(wrk_exp != NULL) {
               free(wrk_exp); wrk_exp = NULL;}
	if(after != NULL) {
                free(after); after = NULL;}
	if(path != NULL) {
               free(path); path = NULL;}
	return OM_S_SUCCESS;
wrapup:
	if(wrk_exp != NULL) {
               free(wrk_exp); wrk_exp = NULL;}
	if(after != NULL) {
               free(after); after = NULL;}
	if(path != NULL) {
              free(path); path = NULL;}
	return OM_E_ABORT;
}



/*10----------------------- VDSpath_in_list ---------------------------*/
/*
/* 	function which return if the given path is in the given list   
/* 	the return index is the position in the list. If not found	  
/* 	index = -1 ,nb_list = nb elts in list, index_name is the index 
/* 	of the expression name (main2 is not automaticly the second    
/* 	in the list. Can also return the name of the path	   	  
/**/

VDSpath_in_list(
char 	 	   *in_path,	/*  (I) path  search in the list   */
int		   *out_index,	/*  (O) index of path in the list  */
char		   *out_name,	/*  (O) name of path in the list  */
struct constr_path *list,	/*  (I) list where to search       */
int		   nb_elts,	/*  (I) nb elts in input list	   */
struct txt_symb	   *symb,       /*  (O) symbology associated       */
int		   *found	/*  (O) 1 = found 0 = not found    */
)
/*.VDSpath_in_list*/
{
int		i;

if(in_path == NULL || list == NULL || found == NULL)
 {
  printf("ERROR: arguments in_path, list and found cannot be NULL\n");
  return OM_E_ABORT;
 }

*found = 0;
for(i=0;i<nb_elts;i++)
 {
   if(strcmp(in_path,list[i].path) == 0 )
     {
      *found = 1;
      if(out_index != NULL) *out_index = i;
      if(out_name != NULL) strcpy(out_name,list[i].name);
      if(symb != NULL) *symb = list[i].symbology;
     }
 }


return OM_S_SUCCESS;

}
/*11----------------------- VDSname_in_list ---------------------------
/*
/* 	function which return if the given name is in the given list   
/* 	the return index is the position in the list. If not found	  
/* 	index = -1 ,nb_list = nb elts in list, index_name is the index 
/* 	of the expression name (main2 is not automaticly the second   
/* 	in the list. Can also return the the path corresponding to  	  
/* 	that name.							  
/**/

VDSname_in_list(
char 	 	   *in_name,	/*  (I) name  search in the list   */
int		   *out_index,	/*  (O) index of path in the list  */
char		   *out_path,	/*  (O) path in the list  	   */
struct constr_path *list,	/*  (I) list where to search       */
int		   nb_elts,	/*  (I) nb elts in input list	   */
struct txt_symb	   *symb,       /*  (O) symbology associated       */
int		   *found	/*  (O) 1 = found 0 = not found    */
)
/*.VDSname_in_list*/
{
int		i,len;

if(in_name == NULL || in_name[0] == '\0' || list == NULL || found == NULL)
 {
  printf("ERROR: arguments in_name, list and found cannot be NULL\n");
  return OM_E_ABORT;
 }
*found = 0;
len = strlen(in_name);
if(len >= NAME_MAX)
 {
  printf("ERROR: in_name: [%s] cannot be >= NAME_MAX\n",in_name);
  return OM_E_ABORT;
 }

for(i=0;i<nb_elts;i++)
 {
   if(strcmp(in_name,list[i].name) == 0 )
     {
      *found = 1;

      if(out_index != NULL) *out_index = i;
      if(out_path != NULL) strcpy(out_path,list[i].path);
      if(symb != NULL) *symb = list[i].symbology;
     }
 }

return OM_S_SUCCESS;

}

/*12----------------------- VDSinit_path ---------------------------*/

VDSinit_path(
char 			*ref_path ,   /*(I) reference path to set.	*/
struct constr_path	*main_path ,  /*(I) main path to set.		*/
struct constr_path	*search_path, /*(I) search_path to set.		*/
char 			*user_path,   /*(O) path of the directory expression*/
struct GRid     	*dir_obj,     /*(O) object of the dir user_path	*/
struct GRmd_env 	*md_env      /*(O) current mod_env		*/
)
{
long		msg,sts;
OM_S_OBJID   	mod_id;
OMuword      	mod_osnum;
struct GRmd_env wrk_env; 
short		rc;
char		symb_path[MY_MAX],act_dir[DI_PATH_MAX],path[DI_PATH_MAX+30],
		main[MY_MAX],search[MY_MAX],ref_dir[DI_PATH_MAX];
struct GRid	dir;
int		len,len1;

 
/*| look for the directory user_path or create it */

sts = VDSis_pathdir(path ,&wrk_env );
if(!(sts&1))
   {
    /* directory user_path doesn't exist */

    if(strncmp(path,"PATH_NOT_FOUND",14) == 0)
    {printf("ERROR,path to the current os not found\n");return OM_E_ABORT;}


    sts = di$mkdir(dirname =path, p_dirid = &dir.objid, p_osnum = &dir.osnum);
    if (sts != DIR_S_SUCCESS)
	{printf("mkdir user_path fail\n");return OM_E_ABORT;}


    if(user_path != NULL) strcpy(user_path,path);
    if(dir_obj != NULL) *dir_obj = dir; 

    if(md_env != NULL) *md_env = wrk_env;

   }
else 
   {
    sts = di$translate(objname = path, p_objid = &dir.objid,p_osnum = &dir.osnum);
    if (sts != DIR_S_SUCCESS)  return OM_E_ABORT;

    if(user_path != NULL) strcpy(user_path,path);

    if(dir_obj != NULL) *dir_obj = wrk_env.md_id ;

    if(md_env != NULL) *md_env = wrk_env; 

    len = strlen(path); 

    sts = di$pwd(dirname = act_dir);  
    if(sts != DIR_S_SUCCESS){printf("error pwd\n");return OM_E_ABORT;} 
    len1 = strlen(act_dir);
    if(len1 >= MY_PATH_MAX)
     {printf("ERROR: [%s] is too long\n",act_dir);return OM_E_ABORT;} 

    strcpy(&path[len],":active_dir");
    sts = VDSexp_path(act_dir, path, dir.osnum);
    if(!(sts&1)) {printf("error VDSexp_path\n");return OM_E_ABORT;}

    /*| Begin CH KLUDGE */
    /* TEMPORARY KLUDGE TO MODIFY THE REFERENCE PATH IF THE FILE NAME HAS
    /* CHANGED.
    /* THE SOLUTION SHOULD BE TO CONCIDERE THE DIR SYSTEM STARTING AFTER
    /* THE FILE NAME.
    /* */
     {
     char 		c_ref_path[2*DI_PATH_MAX+10], file_name[DI_PATH_MAX];
     char		tmp[2*DI_PATH_MAX+10], tmp2[2*DI_PATH_MAX+10];
     struct GRid	c_ref;
     struct ret_struct  ret_st;
    
     /* Extract the file name */

     c_ref_path[0] = ':';
     sts = VDSextract_part_exp(&path[1], &c_ref_path[1], tmp,':');
     if(!(sts&1)) { printf("VDSextract_part_exp fail\n"); return OM_E_ABORT;}
     sts = VDSget_filename(file_name);
     if(!(sts&1)) printf("VDSget_filename fail\n"); 
      strcpy(file_name, c_ref_path);

     /* Get the ref_name */

     strcpy(&path[len],":ref_path");
     sts = di$translate(objname = path, p_objid = &c_ref.objid,p_osnum = &c_ref.osnum);
     if (sts != DIR_S_SUCCESS) {printf("Cannot get the ref path\n"); return OM_E_ABORT;}

     sts = om$send( msg = message text_exp.NDgive_structure(&msg,&ret_st,&wrk_env),
     			senderid = NULL_OBJID,
     			targetid = c_ref.objid,
			targetos = c_ref.osnum);
     if(!(sts&1)) { printf("VDSpath_fn, text_exp.NDgive_structure ERROR\n"); return(OM_S_SUCCESS);}


     if(strlen(ret_st.var.text_st.text_string) < 2)  return OM_S_SUCCESS;
     sts = VDSextract_part_exp(&ret_st.var.text_st.text_string[1], tmp, tmp2, ':');

     if(!(sts&1)) return OM_S_SUCCESS;

     if(strcmp(&file_name[1],tmp) == 0)
      {
       /*| Same file name ==> ok */
      }
     else 
      {
       IGRboolean save_broadcast;

       /*| Not same file name ==> not ok */
       strcat(file_name,":");
       strcat(file_name,tmp2);

       save_broadcast = ASbroadcast_in_progress;
       ASbroadcast_in_progress = TRUE;   /* Don't make a wait batch */
       sts = om$send( msg = message text_exp.modify(path,file_name,&rc),
     			senderid = NULL_OBJID,
     			targetid = c_ref.objid,
			targetos = c_ref.osnum);
       ASbroadcast_in_progress = save_broadcast;
       if(!(sts&1)) 
          { printf("VDSpath_fn, text_exp.modify ERROR\n"); return(OM_E_ABORT);}
      }

    }
   /*| END   CH KLUDGE */

    if(ref_path == NULL && main_path == NULL && search_path == NULL) 
        return OM_S_SUCCESS;
   }

len = strlen(path); 


 /* fill the directory user_path with the default expressions */

 sts = di$pwd(dirname = act_dir);  
 if(sts != DIR_S_SUCCESS){printf("error pwd\n");return OM_E_ABORT;} 
 len1 = strlen(act_dir);
 if(len1 >= MY_PATH_MAX)
     {printf("ERROR: [%s] is too long\n",act_dir);return OM_E_ABORT;} 

  strcpy(&path[len],":active_dir");

 sts = VDSexp_path(act_dir, path, dir.osnum);
 if(!(sts&1)) {printf("error VDSexp_path\n");return OM_E_ABORT;}


if(ref_path == NULL)
 { 
   ex$get_cur_mod ( id=&mod_id, osnum=&mod_osnum ) ;
   di$give_pathname ( osnum = mod_osnum, pathname = ref_dir);
   strcat(ref_dir,":usr");
/* 
/*  CH ----   
/*  Why a dynamic space allocation ?????
/*
/* */
   ref_path = (char *)om$malloc(size = MY_PATH_MAX*sizeof(char));
   if(ref_path == NULL)
	{
	  printf("bad allocation of ref_path\n");
	  return OM_E_ABORT;
  	}
   strcpy(ref_path,ref_dir);
 }
len1 = strlen(ref_path);
if(len1 >= MY_PATH_MAX){printf("ERROR: [%s] is too long\n",ref_path);return OM_E_ABORT;} 
if(main_path == NULL)
    {
      main_path = (struct constr_path*)om$malloc(size = sizeof(struct constr_path));
      if(main_path == NULL)
	{
	  printf("bad allocation of main_path\n");
	  return OM_E_ABORT;
  	}
      strcpy(main_path->path,".");
      strcpy(main_path->name,"path0");
    }
if(search_path == NULL)
    {
      search_path = (struct constr_path*)om$malloc(size = sizeof(struct constr_path));
      if(search_path == NULL)
	{
	  printf("bad allocation of search_path\n");
	  return OM_E_ABORT;
  	}
      strcpy(search_path->path,".");
      strcpy(search_path->name,"search0");
    }
len1 = strlen(main_path->path);
if(len1 >= MY_PATH_MAX){printf("ERROR: [%s] is too long\n",main_path->path);return OM_E_ABORT;} 
len1 = strlen(main_path->name);
if(len1 >= NAME_MAX){printf("ERROR: [%s] is too long\n",main_path->name);return OM_E_ABORT;} 

len1 = strlen(search_path->path);
if(len1 >= MY_PATH_MAX){printf("ERROR: [%s] is too long\n",search_path->path);return OM_E_ABORT;} 
len1 = strlen(search_path->name);
if(len1 >= NAME_MAX){printf("ERROR: [%s] is too long\n",search_path->name);return OM_E_ABORT;} 

sts = write_exp(main_path, main);
if(!(sts&1)) {printf("error write_exp\n");return OM_E_ABORT;}
sts = write_exp( search_path, search);
if(!(sts&1)) {printf("error write_exp\n");return OM_E_ABORT;}



 strcpy(&path[len],":act_main");
 sts = VDSexp_path(main, path, dir.osnum);
 if(!(sts&1)) {printf("error VDSexp_path\n");return OM_E_ABORT;}

 strcpy(&path[len],":main0");
 sts = VDSexp_path(main, path, dir.osnum);
 if(!(sts&1)) {printf("error VDSexp_path\n");return OM_E_ABORT;}

 strcpy(&path[len],":act_search");
 sts = VDSexp_path(search, path, dir.osnum);
 if(!(sts&1)) {printf("error VDSexp_path\n");return OM_E_ABORT;}

 strcpy(&path[len],":search0");
 sts = VDSexp_path(search, path, dir.osnum);
 if(!(sts&1)) {printf("error VDSexp_path\n");return OM_E_ABORT;}

 strcpy(&path[len],":ref_path");
 sts = VDSexp_path(ref_path, path, dir.osnum);
 if(!(sts&1)) {printf("error VDSexp_path\n");return OM_E_ABORT;}

 strcpy(symb_path,"color=act,level=act,weight=act,style=act");

 strcpy(&path[len],":act_symbol_main");
 sts = VDSexp_path(symb_path, path, dir.osnum);
 if(!(sts&1)) {printf("error VDSexp_path\n");return OM_E_ABORT;}

 strcpy(&path[len],":symbol_main0");
 sts = VDSexp_path(symb_path, path, dir.osnum);
 if(!(sts&1)) {printf("error VDSexp_path\n");return OM_E_ABORT;}

   
 return OM_S_SUCCESS;
}



/*13  ----------------------- VDSget_path ---------------------------*/

VDSget_path(
char			*return_path ,	/* (O) return path 		*/
char			*name_path,     /* (O) name of the path         */
int			const_flag,	/* (I) MAIN_PATH or REF_PATH 	*/
char			*in_name,	/* (I) name of path to return 	*/
struct GRsymbology  	*symbology,	/* (O) return symbology		*/
int		        *found,		/* (O) 1 = found 0 = not found  */
int		        nb_lines,	/* (I) nb_lines entered (0 if NULL) */
char		        **lines	       /* (I) lines			    */
)
{
int			tnb_lines,len,wrk_symb,main_index;
struct GRmd_env		md_env;
long			sts,msg;
char			us_path[DI_PATH_MAX+30],act_dir[DI_PATH_MAX],
			symb_text[MY_MAX];
struct GRid		exp, dir_obj;
struct ret_struct	ret_st;
struct constr_path 	out_struct, *exp_main;
struct current_path 	current;

wrk_symb   = 0;
main_index = 0;
exp_main   = NULL;



if(nb_lines == 0 && lines != NULL)
 {
   printf("ERROR: nb_lines=0 and lines != NULL ????\n");
   goto wrapup;
 }


/* look for the directory user_path */

sts = vds$init_path(user_path = us_path, dir_obj = &dir_obj,md_env = &md_env); 
if ( !(sts&1)) {printf("error vds$init_path\n");goto wrapup;}

len=strlen(us_path);
if(in_name == NULL)
     { printf("ERROR: argument in_name cannot be NULL\n");goto wrapup;}
if(strlen(in_name) >= NAME_MAX)
   {printf("ERROR: [%s] is too long\n",in_name);goto wrapup;}

if(found != NULL) *found = 1;

if(const_flag != MAIN_PATH && const_flag != REF_PATH)
     { printf("ERROR: not a valid arg const_flag\n");goto wrapup;}

if(nb_lines == 0 && const_flag != REF_PATH)
 {

   lines    = NULL;
   tnb_lines = 0;
   strcpy(&us_path[len],":*");

   sts = di$ls( regexp = us_path,
		lines  = &lines,
		ptr    = &tnb_lines);
   if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}
 }
else tnb_lines = nb_lines;

if(strncmp(in_name,"ACTIVE",6) == 0)
 {
  /*|return active path */

  if (const_flag == MAIN_PATH) strcpy(&us_path[len],":act_main");
  if (const_flag == REF_PATH)  strcpy(&us_path[len],":ref_path");

   sts = di$translate(objname = us_path, p_objid = &exp.objid,
                                       p_osnum = &exp.osnum);
   if (sts != DIR_S_SUCCESS) {printf("ERROR: path [%s] not found\n",us_path);goto wrapup;}


   sts = om$send ( msg = message text_exp.NDgive_structure( &msg, &ret_st, 
							  &md_env),
                     senderid = NULL_OBJID,
                     targetid = exp.objid,
		     targetos = exp.osnum);
   if (! (sts & 1))
      {
        printf("failure sending text_exp.NDgive_structure\n");
        as$status(sts = sts,action = RET_STATUS);
        goto wrapup;
      }
  if(const_flag == REF_PATH)
   { 
    strcpy(out_struct.path,ret_st.var.text_st.text_string);
    out_struct.name[0] = '\0';
   }
  else if (const_flag == MAIN_PATH) 
   { 
       sts = read_exp(ret_st.var.text_st.text_string,&out_struct );
       if (! (sts & 1))
           {
             printf("failure read_exp\n");
             goto wrapup;
           }
	sts = vds$give_exp(current = &current, 
                          nb_lines = tnb_lines,
			  lines    = lines);
        if (! (sts & 1))
           {
             printf("failure vds$give_exp\n");
             goto wrapup;
           }
  	out_struct.symbology = current.main_cst_path.symbology;
   }
 }
else
 {
  if(const_flag == REF_PATH) 
    {
      printf("ERROR: reference path is not named\n");
      goto wrapup;
    }
  if(found == NULL)
    {
      printf("ERROR: argument found cannot be NULL in get by name\n");
      goto wrapup;
    }

  /*|retrieve list of name */

    sts = vds$give_exp( nb_main   = &main_index, 
                        nb_lines  = tnb_lines,
			lines     = lines);
    if(!(sts & 1)) {printf("ERROR in vds$give_exp\n"); goto wrapup;}

   exp_main = (struct constr_path *)om$malloc(size = main_index*
						sizeof(struct constr_path));
   if(exp_main == NULL)
    {
      printf("bad allocation of exp_main\n");
      goto wrapup;
    }
   sts = vds$give_exp( main_alloc   = main_index, 
 		       main   	    = exp_main, 
                       nb_lines     = tnb_lines,
		       lines        = lines);

   if(!(sts & 1)) {printf("ERROR in vds$give_exp\n"); goto wrapup;}


   sts = vds$name_in_list(in_name  = in_name,
  			    out_path = out_struct.path,
                            list     = exp_main,
			    nb_elts  = main_index,
			    symb     = &out_struct.symbology,
			    found    = found);
     if ( !(sts&1)) {printf("error vds$name_in_list\n");goto wrapup;}
     if (*found == 0)
      { 
        /* printf("WARNING: name not found in list\n");*/

	/* MODIF PL 04-01-93 return the active symbology */ 
	
	if(symbology) vds$get_active_symb(symbology = symbology);

        goto success;
      }		 
     strcpy(out_struct.name, in_name);
 }

if(return_path != NULL)
{
 if(out_struct.path[0] == '.')
  {
    sts = di$pwd(dirname = act_dir);  
    if(sts != DIR_S_SUCCESS){printf("error pwd\n");goto wrapup;} 

    if(strlen(act_dir) >=MY_PATH_MAX)
      {printf("ERROR: [%s] is too long\n",act_dir);goto wrapup;}
    strcpy(return_path,act_dir);
  }
 else if(const_flag != REF_PATH)
  {
    /*|output absolute path relative to reference*/

     sts = vds$path_name(in_path = out_struct.path,out_path = return_path);
     if ( !(sts&1)) {printf("error vds$name_in_list\n");goto wrapup;}
  }
 else strcpy(return_path,out_struct.path);
}

if(name_path != NULL) strcpy(name_path,out_struct.name);
    
if(symbology != NULL)
 {
  if (const_flag == REF_PATH) {printf("error no symbology for ref_path\n");
			       goto wrapup;}
  if(strncmp(in_name,"ACTIVE",6) != 0)
     {
	sts = vds$text_to_symb( txt_symb = &out_struct.symbology,
				exp_symb = symb_text);      
        if(!(sts&1)){printf("error vds$text_to_symb\n");goto wrapup;}


        sts = VDSexp_to_symb(symbology, symb_text, &wrk_symb);
        if(!(sts&1)){printf("error VDSexp_to_symb\n");goto wrapup;}
        goto success;
     }
  if (const_flag == MAIN_PATH) strcpy(&us_path[len],":act_symbol_main");

  sts = di$translate(objname = us_path, p_objid = &exp.objid,
                                       p_osnum = &exp.osnum);
  if (sts != DIR_S_SUCCESS) {printf("ERROR: path [%s] not found\n",us_path);goto wrapup;}


  sts = om$send ( msg = message text_exp.NDgive_structure( &msg, &ret_st, 
							  &md_env),
                     senderid = NULL_OBJID,
                     targetid = exp.objid,
		     targetos = exp.osnum);
  if (! (sts & 1))
      {
        printf("failure sending text_exp.NDgive_structure\n");
        as$status(sts = sts,action = RET_STATUS);
        goto wrapup;
      }

if(strlen(ret_st.var.text_st.text_string) >= MY_MAX)
{printf("ERROR: [%s] is too long\n",ret_st.var.text_st.text_string);goto wrapup;}

  strcpy(symb_text,ret_st.var.text_st.text_string);

 sts = VDSexp_to_symb(symbology, symb_text, &wrk_symb);
 if(!(sts&1)){printf("error VDSexp_to_symb\n");goto wrapup;}
 
 }


goto success;

success:

	if(nb_lines == 0 && lines!= NULL) 
 	 {
   	   /*|only dealloc lines allocated in the function */
    	   di$free(lines = lines,
            	   count = tnb_lines);
           lines    = NULL;
           tnb_lines = 0;
 	 }
	if(exp_main != NULL) {free(exp_main);exp_main = NULL;}
	return OM_S_SUCCESS;
wrapup:
	if(nb_lines == 0 && lines!= NULL) 
 	 {
   	   /*|only dealloc lines allocated in the function */
    	   di$free(lines = lines,
            	   count = tnb_lines);
           lines    = NULL;
           tnb_lines = 0;
 	 }
	if(found != NULL) *found = 0;
	if(exp_main != NULL) {free(exp_main);exp_main = NULL;}
	return OM_E_ABORT;



}


/*14  ---------------------- vds$get_search_path -------------------------- */

VDSget_search_path(
char		    *in_name,		/* (I) name of path to return 	    */
int		    *nb_search,		/* (O) nb of elts in the search list*/
char		    ***search_path,	/* (O) returned list		    */
char		    *search_name,	/* (O) name of search list	    */
int		    *found,		/* (O) 1 = found 0 = not found      */
int		    nb_lines,		/* (I) nb_lines entered (0 if NULL) */
char		    **lines,		/* (I) lines			    */
int 		    nb_call             /* (I) maximum recursive call       */
)
/*.VDSget_search_path */
{
int			i,j,k,l,real_nb,wrk_nb;
OM_S_OBJID   		mod_id;
OMuword      		mod_osnum;
struct GRmd_env		md_env;
long			sts,msg;
char			FILENAME[DI_PATH_MAX],us_path[DI_PATH_MAX+30],**wrk_search, 
			after[MY_MAX],exp_name[MY_MAX], symb_text[MY_MAX], 
			***star_line, ***search_tab, **line_exp, tmp[DI_PATH_MAX];
struct GRid		exp, dir_obj;
struct ret_struct	ret_st;
int		 	*int_found, exp_found,len,len1,search_index, *nb_tab, 
			*star_nb, tnb_lines, nb_regexp;
struct constr_path 	out_struct, *exp_search;
int			status; 

wrk_nb       = 0;
search_index = 0;
exp_search   = NULL;
wrk_search   = NULL;
int_found    = NULL;
star_line    = NULL;
line_exp     = NULL;
exp_found    = 0;
search_tab   = NULL;
star_nb      = NULL; 
nb_tab       = NULL;
real_nb	     = 0;
tnb_lines    = 0;
nb_regexp    = 0;
FILENAME[0] = '\0';

if(lines == NULL) { /*| lines NULL */ }

/* look for the directory user_path */


if(nb_call == 0) 
{
   printf("ERROR: Too much recursive calls in VDSget_search_path\n");
   goto wrapup;
}


if(nb_lines == 0 && lines != NULL)
 {
   printf("ERROR: nb_lines=0 and lines != NULL ????s\n");
   goto wrapup;
 }

sts = vds$init_path(user_path = us_path, dir_obj = &dir_obj,md_env = &md_env); 
if ( !(sts&1)) {printf("error vds$init_path\n");goto wrapup;}

len = strlen(us_path);
if(in_name == NULL)
     { printf("ERROR: argument in_name cannot be NULL\n");goto wrapup;}

if(found != NULL) *found = 1;
if(nb_search != NULL) *nb_search = 0;

if(nb_lines == 0)
 {

   lines    = NULL;
   tnb_lines = 0;
   strcpy(&us_path[len],":*");

   sts = di$ls( regexp = us_path,
		lines  = &lines,
		ptr    = &tnb_lines);
   if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}
 }
else tnb_lines = nb_lines;


if(strncmp(in_name,"ACTIVE",6) == 0)
 {
   strcpy(&us_path[len],":act_search");

   sts = di$translate(objname = us_path, p_objid = &exp.objid,
                                       p_osnum = &exp.osnum);
   if (sts != DIR_S_SUCCESS) {printf("ERROR: path [%s] not found\n",us_path);goto wrapup;}

   sts = om$send ( msg = message text_exp.NDgive_structure( &msg, &ret_st, 
							  &md_env),
                     senderid = NULL_OBJID,
                     targetid = exp.objid,
		     targetos = exp.osnum);
   if (! (sts & 1))
      {
        printf("failure sending text_exp.NDgive_structure\n");
        as$status(sts = sts,action = RET_STATUS);
        goto wrapup;
      }
   sts =read_exp(ret_st.var.text_st.text_string,&out_struct );
  if (! (sts & 1))
      {
        printf("failure read_exp\n");
        goto wrapup;
      }

 }
else
 {
  if( found == NULL)
    {
      printf("ERROR: arguments list and found cannot be NULL in get by name\n");
      goto wrapup;
    }
  if(strlen(in_name) >=NAME_MAX)
     {printf("ERROR: [%s] is too long\n",in_name);goto wrapup;}

  /*|retrieve list of name */

    sts = vds$give_exp( nb_search   = &search_index, 
                        nb_lines    = tnb_lines,
			lines       = lines);
    if(!(sts & 1)) {printf("ERROR in vds$give_exp\n"); goto wrapup;}

   exp_search = (struct constr_path *)om$malloc(size = search_index*
						sizeof(struct constr_path));
   if(exp_search == NULL)
    {
      printf("bad allocation of exp_search\n");
      goto wrapup;
    }
   sts = vds$give_exp( 	search_alloc   = search_index, 
 		       	search         = exp_search,
			nb_lines       = tnb_lines,
			lines          = lines);
   if(!(sts & 1)) {printf("ERROR in vds$give_exp\n"); goto wrapup;}


  sts = vds$name_in_list(in_name  = in_name,
			 out_path = out_struct.path,
                         list     = exp_search,
			 nb_elts  = search_index,
			 found	  = found);
  if ( !(sts&1)) {printf("error vds$name_in_list\n");goto wrapup;}
  if (*found == 0)
   { 
     printf("WARNING: name not found in list\n");
     goto success;
   }
  strcpy(out_struct.name, in_name);


 }
if(exp_search != NULL){ free(exp_search);exp_search = NULL;}

if(search_name != NULL) strcpy(search_name,out_struct.name);


  strcpy(symb_text,out_struct.path);
  strcpy(after, symb_text);
  
  sts = vds$extract_all_part_exp( nb_part = &wrk_nb,
     		             	    expression = symb_text); 
  if(sts != 1) {printf("vds$extract_all_part_exp fail\n"); goto wrapup;}

  real_nb = wrk_nb;
  
  wrk_search = (char **)om$malloc(size = wrk_nb*sizeof(char*));
  if(wrk_search == NULL)
	{
	  printf("bad allocation of wrk_search\n");
	  goto wrapup;
  	}
  for(i=0;i<wrk_nb;i++)
     	{
          wrk_search[i] = NULL;
          wrk_search[i] = (char *)om$malloc(size = DI_PATH_MAX * sizeof(char));
          if(wrk_search[i] == NULL)
		    {
			printf("bad allocation of search_path\n");
			goto wrapup;
  		    }
  	 }
   /*|fill wrk_search */

   sts = vds$extract_all_part_exp( nb_returned = wrk_nb, 
			  	expression  = symb_text, 
     			  	part_exp    = wrk_search);	
   if(sts != 1) {printf("vds$extract_all_part_exp fail\n"); goto wrapup;}

   /*|alloc search_tab */
   search_tab =(char ***)om$malloc(size = wrk_nb * sizeof(char**));
   if(search_tab == NULL)
     {
	 printf("bad allocation of search_tab\n");
	 goto wrapup;
     }

   nb_tab = (int *) om$malloc(size = wrk_nb * sizeof(int));
   if(nb_tab == NULL)
     {
	 printf("bad allocation of nb_tab\n");
	 goto wrapup;
     }

   int_found = (int *) om$malloc(size = wrk_nb * sizeof(int));
   if(int_found == NULL)
    {
	 printf("bad allocation of int_found\n");
	 goto wrapup;
    }

   for(k=0;k<wrk_nb;k++) {search_tab[k] = NULL;int_found[k] = 0;nb_tab[k]=0;}
   for(i=0;i<wrk_nb;i++)
    {
     if(wrk_search[i][0] == '$' && strncmp(wrk_search[i],"$FILENAME",9 ) == 0){
	 	/* if it is $FILENAME get the file name */

		if(FILENAME[0] == '\0'){
   			ex$get_cur_mod ( id=&mod_id, osnum=&mod_osnum ) ;
   			di$give_pathname ( osnum = mod_osnum, pathname = FILENAME);
		}
     }
     else if(wrk_search[i][0] == '$')
       {
         int_found[i] = 0;
         exp_found = 0;

	 if(strcmp(&wrk_search[i][1],out_struct.name) == 0)
          {
	    /*| don't add this path */
	   int_found[i] = 0;
           real_nb = real_nb - 1;
           continue;
          }

         sts = vds$name_exp(	pathname  = &wrk_search[i][1],
				exp_name  = exp_name,
				const_flag= SEARCH_PATH,
				found     = &exp_found,
				nb_lines  = tnb_lines,
				lines	  = lines);

         if ( !(sts&1)) {printf("error vds$name_exp\n");goto wrapup;}
         if (exp_found == 1)
          {
           /*|name found in search list */
           int_found[i] = 1;
           /*|-----------------appel get_search */
  	   sts = vds$get_search_path(	in_name     = &wrk_search[i][1], 
				      	nb_search   = &nb_tab[i],
					search_path = &search_tab[i], 
					found	    = &exp_found,
                        		nb_lines    = tnb_lines,
					lines       = lines,
                                        nb_call     = nb_call -1);
  	   if(!(sts&1)){/*printf("error get_search_path for exp with $\n");*/
                        goto wrapup;}
	   if(exp_found == 0){printf("error, path must exist\n");goto wrapup;}

           real_nb = real_nb + nb_tab[i] - 1;
          }/* end found in search list */
         else
          {
		 
            sts = vds$name_exp(	pathname  = &wrk_search[i][1],
				exp_name  = exp_name,
				found     = &exp_found,
				nb_lines  = tnb_lines,
				lines	  = lines);

            if ( !(sts&1)) {printf("error vds$name_exp\n");goto wrapup;}
            if (exp_found == 1)
              {
                /*|name found in main but it is just the name ??*/
                int_found[i] = 1;
                nb_tab[i] = 1;
                search_tab[i] = NULL;
  	        search_tab[i] = (char **)om$malloc(size = nb_tab[i]*sizeof(char*));
                if(search_tab[i] == NULL)
	         {
	  	   printf("bad allocation of search_tab\n");
	  	   goto wrapup;
  	         }
                search_tab[i][0] = NULL;
          	search_tab[i][0] = (char *)om$malloc(size = DI_PATH_MAX*
							sizeof(char));
          	if(search_tab[i][0] == NULL)
		  {
		    printf("bad allocation of search_tab\n");
		    goto wrapup;
  		  }
                strcpy(search_tab[i][0],&wrk_search[i][1]);
              }
          }/* end else */
        if(int_found[i] == 0) real_nb = real_nb - 1;
       }/* end wrk_search[i][0] == '$' */
     
       
    }

line_exp = NULL;
line_exp = (char **)om$malloc(size = real_nb*sizeof(char*));
if(line_exp == NULL)
 {
   printf("bad allocation of line_exp\n");
   goto wrapup;
 }
for(i=0;i<real_nb;i++)
 {
   line_exp[i] = NULL;
   line_exp[i] = (char *)om$malloc(size = DI_PATH_MAX*sizeof(char));
   if(line_exp[i] == NULL)
	 {
	   printf("bad allocation of line_exp[i]\n");
	   goto wrapup;
  	 }
  }
/*|remplissage de line_exp */
i=0;
j=0;
while(i<real_nb)
 {
  if(j< wrk_nb && wrk_search[j][0] != '$' )
     {
     	sts = vds$path_name(in_path = wrk_search[j],
                            out_path = line_exp[i]);
     	if ( !(sts&1)) {printf("error vds$name_in_list\n");goto wrapup;}
        i = i + 1;
        j = j + 1;
     }
  else if(wrk_search[i][0] == '$' && strncmp(wrk_search[i],"$FILENAME",9 ) == 0){
	strcpy(tmp, &wrk_search[j][9]);
	sprintf(line_exp[i],"%s%s",FILENAME,tmp);
        i = i + 1;
        j = j + 1;
  }
  else
    {
        if(int_found[j] ==0) {j= j + 1;continue;}
        for(l=0,k=i  ;l<nb_tab[j];l++,k++)
         {
     	   sts = vds$path_name(in_path = search_tab[j][l],
                               out_path = line_exp[k]);
     	   if ( !(sts&1)) {printf("error vds$name_in_list\n");goto wrapup;}

          }
        i= i + nb_tab[j] ;
        j= j + 1;
    }
 }


/* dealloc des tableaux intermediaires */

if(wrk_search != NULL) 
   {
 	  for(i=0;i<wrk_nb;i++) 
          if(wrk_search[i]!=NULL) 
                        {
                          free(wrk_search[i]);wrk_search[i]=NULL;}
 	  if(wrk_search != NULL) {
                      free(wrk_search); wrk_search=NULL;}
                     
   }

if(search_tab != NULL) 
   {
 	  for(i=0;i<wrk_nb;i++) 
          if(search_tab[i]!=NULL) 
                {
                  for(k=0;k<nb_tab[i];k++)
                     {
                       if(search_tab[i][k]!=NULL)
			 {
                           free(search_tab[i][k]);search_tab[i][k]=NULL;}
                     }
		  if(search_tab[i]!=NULL)
		     {
                      free(search_tab[i]);search_tab[i]=NULL;}
                 }
 	  if(search_tab != NULL) {
                        free(search_tab);search_tab=NULL;}
                     
   }
if(nb_tab != NULL){free(nb_tab); nb_tab = NULL;}

star_nb = NULL;
star_nb = (int *)om$malloc(size = real_nb *sizeof(int));
if(star_nb == NULL){printf("bad dynamic allocation \n");goto wrapup;}

star_line = NULL;
star_line = (char ***)om$malloc(size = real_nb *sizeof(char **));
if(star_line == NULL){printf("bad dynamic allocation \n");goto wrapup;}

nb_regexp = 0;
for(i=0;i<real_nb;i++)
 { 

   star_line[i] = NULL;
   star_nb[i]   = 0;
   sts = di$ls( regexp = line_exp[i],
		lines  = &star_line[i],
		ptr    = &star_nb[i]);
   if (sts != DIR_S_SUCCESS) 
     {
       /* directory can be defined and not created */
       star_nb[i] = 0;
       if (sts == DIR_E_ABORT) {di$report_error(sts=sts);goto wrapup;}
     }

   for(k=0;k<star_nb[i];k++) 
     {

       len1= strlen(star_line[i][k]);

       if(star_line[i][k][len1-1] == ':') star_line[i][k][len1-1] = '\0';
     }
   if(star_nb[i]>1)
    { 
      nb_regexp = nb_regexp + star_nb[i] -1;

    }
 }
nb_regexp = nb_regexp + real_nb ;


if(search_path != NULL && nb_regexp != 0)
 {
  *search_path = (char **)om$malloc(size = nb_regexp*sizeof(char*));
  if(*search_path == NULL)
	{
	  printf("bad allocation of *search_path\n");
	  goto wrapup;
  	}
  for(i=0;i<nb_regexp;i++)
     	{
          (*search_path)[i] = (char *)om$malloc(size = DI_PATH_MAX*
							sizeof(char));
          if((*search_path)[i] == NULL)
		    {
			printf("bad allocation of (*search_path)[i]\n");
			goto wrapup;
  		    }
  	 }
   /*|remplissage de search_path */
   i=0;
   j=0;
   while(i<real_nb)
     	{
          if(star_nb[i] > 0)
           {
            for(k=0;k<star_nb[i];k++)
              {
               len1 = strlen(star_line[i][k]);
               if(len1 > DI_PATH_MAX) 
                 {
                   printf("path [%s] not loaded because its lenght\n",star_line[i][k]);
                   continue;
                 }
               strncpy( (*search_path)[j], star_line[i][k] ,DI_PATH_MAX);
               j = j+ 1;
              }
           }
          else
           {
               len1 = strlen(line_exp[i]);
               if(len1 > DI_PATH_MAX) 
                 {
                   printf("path [%s] not loaded because its lenght\n",line_exp[i]);
                   continue;
                 }
               strncpy( (*search_path)[j], line_exp[i], DI_PATH_MAX);
               j = j+ 1;
           }
          i = i + 1;
        }
 
 }

if(nb_search != NULL) *nb_search = nb_regexp;


success:
   status = OM_S_SUCCESS;
   goto cleanup;

wrapup:
   status = OM_E_ABORT;   

cleanup:

if(nb_lines == 0 && lines!= NULL) 
 {
   /*|only dealloc lines allocated in the function */
    di$free(lines = lines,
            count = tnb_lines);
    lines    = NULL;
    tnb_lines = 0;
 }
if(line_exp != NULL) 
   {
 	  for(i=0;i<real_nb;i++)
              if(line_exp[i] != NULL){free(line_exp[i]);line_exp[i] = NULL;}
          if(line_exp != NULL){free(line_exp);line_exp = NULL;}
   }
if(star_line != NULL)
 {
   for(i=0;i<real_nb;i++)
    {
      di$free(lines = star_line[i],
              count = star_nb[i]);
      star_line[i]     = NULL;
      star_nb[i]       = 0;
    }
   if(star_line != NULL){
       free(star_line);star_line = NULL;}
    }
if(star_nb != NULL){
      free(star_nb);star_nb = NULL;}
if(wrk_search != NULL) 
   {
 	  for(i=0;i<wrk_nb;i++) 
          if(wrk_search[i]!=NULL) 
                        {
                free(wrk_search[i]);wrk_search[i]=NULL;}
 	  if(wrk_search != NULL) {
                free(wrk_search); wrk_search=NULL;}
                     
   }


if(search_tab != NULL) 
   {
 	  for(i=0;i<wrk_nb;i++) 
          if(search_tab[i]!=NULL) 
                {
                  for(k=0;k<nb_tab[i];k++)
                     {
                       if(search_tab[i][k]!=NULL)
			 {
                  
                         free(search_tab[i][k]);search_tab[i][k]=NULL;}
                     }
		  if(search_tab[i]!=NULL)
		     {
                    free(search_tab[i]);search_tab[i]=NULL;}
                }
 	  if(search_tab != NULL) {
                   free(search_tab);search_tab=NULL;}
                     
   }
if(nb_tab != NULL){
      free(nb_tab); nb_tab = NULL;}
if(int_found != NULL){
      free(int_found); int_found = NULL;}
if(exp_search != NULL){
     free(exp_search);exp_search = NULL;}


 return status;

}



/*15  ----------------------- vds$delete_path -------------------------------*/
VDSdelete_path(
char	*in_name,	/* (I) name of path to delete	*/
int	const_flag	/* (I) MAIN_PATH or SEARCH_PATH */
)
{
char			name[DI_PATH_MAX],path[DI_PATH_MAX+10], value[DI_PATH_MAX];	
char			real_name[DI_PATH_MAX],extrd_value[DI_PATH_MAX];
struct GRmd_env 	md_env;	
char			**lines;
int			i,nb_lines,len,found;
struct digrid		*exp;
struct GRid		symb_obj,dir_obj;	
long			sts,status;
struct constr_path 	cst_path;


lines 		= NULL;
nb_lines	= 0;
exp   		= NULL;
found 		= 0;

if(in_name == NULL) 
  {printf("no name given, nothing to delete\n");return OM_S_SUCCESS;}

if(const_flag != MAIN_PATH && const_flag != SEARCH_PATH)
  {printf("not a valid arg. const_flag\n");return OM_S_SUCCESS;}

/* look for the directory user_path */

sts = vds$init_path(user_path = path, md_env = &md_env, dir_obj = &dir_obj); 
if ( !(sts&1)) {printf("error vds$init_path\n");goto wrapup;}


len = strlen(path);

strcat(path,":*");

 sts = di$dump( regexp = path,
		lines  = &lines,
		ptr    = &nb_lines,
		grids  = &exp);
 if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}

 for (i=0;i<nb_lines;i++)
   {

    EXP_extract_lhs_rhs(lines[i],name,value);

    sts = di$split(pathname = name, name = real_name);
    if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}


     if(const_flag == MAIN_PATH)
      {
        status = VDexp_locate("act_symbol_main",real_name);
        if (status != 0) continue;
        status = VDexp_locate("act_main",real_name);
        if (status != 0) continue;
        status = VDexp_locate("symbol_main",real_name);
        if (status != 0) continue;
        sts = VDexp_locate("main",real_name);
      }
     else if(const_flag == SEARCH_PATH)
      {
        status = VDexp_locate("act_search",real_name);
        if (status != 0) continue;
        sts = VDexp_locate("search",real_name);
      }
     if (sts != 0) 
      {
        EXP_extract_string(value,extrd_value);


         sts = read_exp(extrd_value,&cst_path);
  	if (! (sts & 1))
         {
           printf("failure read_exp\n");
           goto wrapup;
         }

	if(strcmp(cst_path.name,in_name) == 0) 
	 {
	   /*| name found */
     	   found = 1;
           /*|delete expression */
           sts = om$send ( msg = message Root.delete(0),
                              senderid = NULL_OBJID,
                              targetid = exp[i].objid,
		              targetos = exp[i].osnum);
           if (! (sts & 1))
              {
                printf("failure sending Root.delete\n");
                as$status(sts = sts,action = RET_STATUS);
                goto wrapup;
              }
           if(const_flag == MAIN_PATH)
              {
		/*|delete symbology associated to the path */
 		strcpy(&path[len],":symbol_main");
          	strcat(path,&real_name[4]); 

                sts = di$translate(objname = path, p_objid = &symb_obj.objid,
			            p_osnum = &symb_obj.osnum);
                if (sts != DIR_S_SUCCESS) 
		    {printf("ERROR: name [%s] not found\n",name); goto wrapup;}
                /*|delete expression */
                sts = om$send ( msg = message Root.delete(0),
                                   senderid = NULL_OBJID,
                                   targetid = symb_obj.objid,
		                   targetos = symb_obj.osnum);
                if (! (sts & 1))
                   {
                     printf("failure sending Root.delete\n");
                     as$status(sts = sts,action = RET_STATUS);
                     goto wrapup;
                   }

              }
           break;
          } /* cst_name = in_name */
       }
   }

if(found == 0)
   printf("WARNING: name not found, no path deleted\n");

  if(exp != NULL) {free(exp);exp = NULL;}   
  if(lines != NULL && nb_lines != 0)
   {
    di$free(lines = lines,
            count = nb_lines);
    lines = NULL;
    nb_lines = 0;
   }


return OM_S_SUCCESS;
wrapup:
  if(exp != NULL) {free(exp);exp = NULL;}   
  if(lines != NULL && nb_lines != 0)
   {
    di$free(lines = lines,
            count = nb_lines);
    lines = NULL;
    nb_lines = 0;
   }
return OM_E_ABORT;
}

/*16  ----------------------- vds$translate-------------------------------*/

VDStranslate(
char		    *objname,	/* (I) name to translate		*/
DIobjid		    *p_objid,	/* (O) objid associated to the name	*/
DIspacenum	    *p_osnum,	/* (O) os of the object			*/
int		    *p_index	/* (O) index of path in search_list	*/
)
{
char		path[DI_PATH_MAX+30],**search_path;
long		sts;
int		wrk_index,nb_search, found, i;

 nb_search = 0;
 found = 0;
 wrk_index = 0;
 search_path = NULL;
 sts = DIR_S_SUCCESS;


 if(objname == NULL)
  {
   printf("ERROR: argument objname cannot be NULL\n");
   return OM_E_ABORT;
  }
 if(isdigit(objname[0]))
  {
   return(DIR_W_NAME_NOT_FOUND);
  }
 if(objname[0] == ':')
  {
   /*|don't use path system */


     sts = di$translate( objname = objname,
    		         p_objid = p_objid,
		         p_osnum = p_osnum);

    if(sts != DIR_S_SUCCESS) 
      {
	        /* translate fail Try the input name objname */
     		sts = di$translate( objname = objname,
    				    p_objid = p_objid,
		         	    p_osnum = p_osnum);
			if(sts !=DIR_S_SUCCESS) 
			 {
/*
   TR# 179423633 : Reporting error while creating expression
   ':<filename>:PDU:serial_no' ( PLACE PLATE command) in a new file.
   Fix : Commented out reporting error to unix window. Calling routine which
   gets the return status should perform the task of reporting error
   to user.  Raju 11/17.
			  di$report_error(sts = sts);
*/
			  return(DIR_W_NAME_NOT_FOUND);
			 }
      }
     return(sts);
  }

  sts = vds$get_search_path(nb_search = &nb_search, search_path = &search_path);
  if(!(sts&1)){printf("error get_search_path\n");goto wrapup;}

 
  for(i=0;i<nb_search;i++)
   {
     strcat(search_path[i],":");
     strcat(search_path[i], objname);


     sts = di$translate( objname = search_path[i],
    		         p_objid = p_objid,
		         p_osnum = p_osnum);
     if(sts ==DIR_S_SUCCESS) 
        {
         found = 1;
         strcpy(path,search_path[i]);
         wrk_index = i;
         break;
        }

    }
if(p_index != NULL) *p_index = wrk_index;

if(found != 1) sts = DIR_W_NAME_NOT_FOUND;

if(search_path != NULL) 
   {
 	  for(i=0;i<nb_search;i++) 
          if(search_path[i]!=NULL) 
                        {free(search_path[i]);search_path[i]=NULL;}
 	  free(search_path);
          search_path=NULL;
                     
   }


return(sts);

wrapup:

		if(search_path != NULL) 
           	   {
 	    		for(i=0;i<nb_search;i++) 
               		if(search_path[i]!=NULL) 
                              {free(search_path[i]);search_path[i]=NULL;}
 	    		free(search_path);
            		search_path=NULL;
                     
           	   }
		 return DIR_E_ABORT;

}

/*17  ------------------------ vds$untranslate-----------------------------*/

VDSuntranslate(
char		    *objname,	/* (O) name of the object (with path)	*/
DIobjid		    objid,	/* (I) objid of the object to find name	*/
DIspacenum	    osnum,	/* (I) os of the object			*/
DIint		    *p_index	/* (O) index of name in the search_list	*/
)
/*.VDSuntranslate*/
{
char		dirname[DI_PATH_MAX],real_name[DI_PATH_MAX],**search_path,
		path[DI_PATH_MAX+30];
long		sts;
int		i, nb_search,wrk_index,found;

 sts = DIR_S_SUCCESS;
 nb_search = 0;
 wrk_index = 0;
 found = 0;
 search_path = NULL;

 if(objname == NULL)
  {
   printf("ERROR: argument objname cannot be NULL\n");
   return OM_E_ABORT;
  }

  sts = vds$get_search_path(nb_search = &nb_search, search_path = &search_path);
  if(!(sts&1)){printf("error get_search_path\n");goto wrapup;}

  sts = di$untranslate( objname = path,
    		        objid = objid,
		        osnum = osnum);

  if(sts !=DIR_S_SUCCESS) 
     {di$report_error(sts = sts, comment = "untranslate");return OM_E_ABORT;}


  sts = di$split(pathname = path,
	         name     = real_name,
	         dirname  = dirname);
  if(sts !=DIR_S_SUCCESS) 
     {di$report_error(sts = sts, comment = "split");return OM_E_ABORT;}


  for(i=0;i<nb_search;i++) 
     {
	if (strcmp(dirname,search_path[i]) == 0) 
            {
	     /*|found*/
	     wrk_index = i;
	     found = 1;
             strcpy(objname,path);
 	     break;
            }
     }
      
if(p_index != NULL) 
     {
      *p_index = wrk_index;
     }

if(found != 1) sts = DIR_W_NAME_NOT_FOUND;

if(search_path != NULL) 
{
 for(i=0;i<nb_search;i++) 
   if(search_path[i]!=NULL) 
       {free(search_path[i]);search_path[i]=NULL;}
 free(search_path);
 search_path=NULL;
                     
}


return(sts);

wrapup:


		if(search_path != NULL) 
           	   {
 	    		for(i=0;i<nb_search;i++) 
               		if(search_path[i]!=NULL) 
                              {free(search_path[i]);search_path[i]=NULL;}
 	    		free(search_path);
            		search_path=NULL;
                     
           	   }
		 return DIR_E_ABORT;

}

/*18  ------------------------ VDSauto_name-----------------------------*/


VDSauto_name(
int		     index,	 /* (I) index of the name	*/
struct  constr_path  *to_name,	 /* (I) path to be auto_named	*/
int		     const_flag, /* (I) MAIN_PATH, SEARCH_PATH	*/
char		     *name,      /* (O) name of path */
int		     *named_flag /* (O) 1 = a name has been given */
)
{
char	list_index[3];

if(to_name == NULL || named_flag == NULL) 
 {printf("ERROR: arguments to_name and named_flag cannot be NULL\n"); return OM_E_ABORT;}

if(const_flag != MAIN_PATH && const_flag != SEARCH_PATH )
 {printf("ERROR: not a valid arg. const_flag\n"); return OM_E_ABORT;}


*named_flag = 0;
if(const_flag == MAIN_PATH)
 {
   if(to_name->name[0] == '\0')
    { 
     strcpy(to_name->name,"path");
     sprintf(list_index,"%d",index);
     strcat(to_name->name,list_index);
     *named_flag = 1;
    }
   else {/*|path already named */}
 }
else 
 {
   if(to_name->name[0] == '\0')
    { 
     strcpy(to_name->name,"search");
     sprintf(list_index,"%d",index);
     strcat(to_name->name,list_index);
     *named_flag = 1;
    }
   else {/*|path already named */}
 }

if(name != NULL)  strcpy(name,to_name->name);


return OM_S_SUCCESS;
}


/*19  ------------------------ VDSgive_exp -----------------------------*/
/* function that read in directory user_path the expressions of paths
/* main and search structures must be allocated of nb_main and nb_search.
/* 
/* 
/* */

VDSgive_exp( 
int			main_alloc,	/* (I) nb allocated for main 	*/
int			search_alloc,	/* (I) nb allocated for search*/	
int			*nb_main,	/* (O) nb elt returned in main 	*/
int			*nb_search,	/* (O) nb elt returned in search*/	
struct current_path	*current,	/* (O) active paths returned  	*/	
struct constr_path  	*main,		/* (O) main paths returned  	*/
struct constr_path  	*search,	/* (O) search paths returned  	*/
int			nb_lines,	/* (I) nb_lines (0) si not lines*/
char			**lines		/* (I) lines 			*/
)
{
char			path[DI_PATH_MAX+30], name[DI_PATH_MAX],real_name[DI_PATH_MAX],
			value[DI_PATH_MAX], extrd_value[DI_PATH_MAX];
long			status, msg, sts;
struct GRid		exp,dir_obj;
struct GRmd_env		md_env;
struct ret_struct	ret_st;
int                     wrk_main, wrk_search, i, tnb_lines, len;

SetProc( VDSgive_expr ); Begin ;

/* look for the directory path */

if(nb_lines == 0 && lines != NULL)
 {
   printf("ERROR: nb_lines null  and lines != NULL ????\n");
   goto wrapup;
 }

sts = vds$init_path(user_path = path, md_env = &md_env, dir_obj = &dir_obj); 
if ( !(sts&1)) {printf("error vds$init_path\n");goto wrapup;}

__DBGpr_str(" Path ", path );

len = strlen(path);

if (nb_main != NULL) *nb_main = 0;
if (nb_search != NULL) *nb_search = 0;

wrk_main 	= 0;
wrk_search 	= 0;


if ((main_alloc > 0) && (main == NULL))
     {
      printf("ERROR: main not allocated\n"); goto wrapup;
     }
if ((search_alloc > 0) && (search == NULL))
     {
      printf("ERROR: search not allocated\n"); goto wrapup;
     }

if(nb_lines == 0)
 {

   lines    = NULL;
   tnb_lines = 0;
   strcpy(&path[len],":*");

   sts = di$ls( regexp = path,
		lines  = &lines,
		ptr    = &tnb_lines);
   if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}

 }
else tnb_lines = nb_lines;

 for (i=0;i<tnb_lines;i++)
   {

    __DBGpr_str(" Directory Line: ", lines[i] );

    EXP_extract_lhs_rhs(lines[i],name,value);

    sts = di$split(pathname = name, name = real_name);
    if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}

    __DBGpr_str(" Directory Path: ", name );
    __DBGpr_str(" Directory Name: ", real_name );

    EXP_extract_string(value,extrd_value);

    __DBGpr_str(" Directory Value ", extrd_value );

       status = VDexp_locate("act_main",real_name);
       if (status != 0)
        {
	  /*|VDexp_locate act_main */
          if(current == NULL) continue;
          sts = read_exp(extrd_value,&((*current).main_cst_path));
  	  if (! (sts & 1))
           {
             printf("failure read_exp\n");
             goto wrapup;
           }

          continue;
        }

       status = VDexp_locate("act_search",real_name);
       if (status != 0)
        {
	  /*|VDexp_locate act_search */
          if(current == NULL) continue;
          sts = read_exp(extrd_value,&((*current).search_cst_path));
  	  if (! (sts & 1))
           {
             printf("failure read_exp\n");
             goto wrapup;
           }

          continue;
        }

       status = VDexp_locate("ref",real_name);
       if (status != 0)
        {
	  /*|VDexp_locate ref */
          if(current == NULL) continue;
   	  strcpy((*current).reference_path,extrd_value);

          continue;
        }

       status = VDexp_locate("act_symbol_main",real_name);
       if (status != 0)
        {
	  /*|VDexp_locate act_symbol_main */
          if(current == NULL) continue;
	  sts = vds$symb_to_text(txt_symb = &((*current).main_cst_path.symbology), 
				 exp_symb = extrd_value);
          if(!(sts&1)){printf("VDSsymb_to_text fail\n");goto wrapup;}
          continue;
        }

       status = VDexp_locate("search",real_name);
       if (status != 0)
        {
	  /*|VDexp_locate search */
          if(search_alloc <= wrk_search)
           {/*|alloc < nb_search */ wrk_search = wrk_search + 1; continue;}

	  sts = read_exp(extrd_value,&search[wrk_search] );
  	  if (! (sts & 1))
           {
             printf("failure read_exp\n");
             goto wrapup;
           }
          wrk_search = wrk_search + 1;
          continue;
        }

       status = VDexp_locate("symbol_main",real_name);
       if (status != 0)
        {
	  /*|VDexp_locate symbol_main */
          if(main_alloc <= wrk_main) 
               {/*|alloc < nb_main */ wrk_main = wrk_main + 1; continue;}
	
          /* take the index name to set the main_path at the same index */
	  
	  sts = vds$symb_to_text(txt_symb = &main[wrk_main].symbology, 
				 exp_symb = extrd_value);
          if(!(sts&1)){printf("VDSsymb_to_text fail\n");goto wrapup;}

          strcpy(&path[len],":main");
          strcat(path,&real_name[11]);

	  __DBGpr_str(" symbol_main ", path );

          sts = di$translate(objname = path, 
			     p_objid = &exp.objid,
                             p_osnum = &exp.osnum);
 	  if (sts != DIR_S_SUCCESS){
          	printf("WARNING:path '%s' not found\n", path );
		continue ; /* goto wrapup; */
	  }
          /*|give structure */
          sts = om$send ( msg = message text_exp.NDgive_structure(&msg,&ret_st, 
							  &md_env),
                              senderid = NULL_OBJID,
                              targetid = exp.objid,
		              targetos = exp.osnum);
          if (! (sts & 1)){
                 printf("failure sending text_exp.NDgive_structure\n");
		 goto wrapup;
          }

	  sts = read_exp(ret_st.var.text_st.text_string,&main[wrk_main] );
  	  if (! (sts & 1)){
             printf("failure read_exp\n");
             goto wrapup;
          }
          wrk_main = wrk_main + 1;
          continue;
        }

   }
if (nb_main != NULL)   *nb_main   = wrk_main;
if (nb_search != NULL) *nb_search = wrk_search;


if(nb_lines == 0 && lines!= NULL) {
    /*|only dealloc lines allocated in the function */
    di$free(lines = lines,
            count = tnb_lines);
    lines    = NULL;
    tnb_lines = 0;
 }

 End
 return OM_S_SUCCESS;

wrapup:
	if(nb_lines == 0 && lines!= NULL) 
 	{
    	   /*|only dealloc lines allocated in the function */
    	   di$free(lines = lines,
                   count = tnb_lines);
    	   lines    = NULL;
    	   tnb_lines = 0;
 	}

	End
	return OM_E_ABORT;
}

/*20  ------------------------ VDSname_exp -----------------------------*/
/* function that read in directory user_path and return if the given name
/* exist. If exist returns the expression name.(doesn't search in active
/* path (active path must also be in the list)).
/* The user must specify if he wants to search the name in the main or 
/* search path list. 
/* */

VDSname_exp(
char			*pathname,	/* (I) name of path to find	*/
int			const_flag,	/* (I) MAIN_PATH, SEARCH_PATH	*/	
char			*exp_name,	/* (O) returned exp name 	*/
char			*exp_value,	/* (O) returned exp value 	*/
int			*found,		/* (O) 1 = name has been found  */	
int		    	nb_lines,	/* (I) nb_lines entered (0 if NULL) */
char		    	**lines		/* (I) lines			    */
)
{
char			path[DI_PATH_MAX+30],name[DI_PATH_MAX],real_name[DI_PATH_MAX],
			value[DI_PATH_MAX],extrd_name[DI_PATH_MAX], extrd_value[DI_PATH_MAX],
			after[DI_PATH_MAX];
long			status, sts;
struct GRid		dir_obj;
struct GRmd_env		md_env;
int                     i, wrk_found, len, tnb_lines;


/* look for the directory user_path */


if(lines == NULL) { /*| lines NULL */ }


if(nb_lines == 0 && lines != NULL)
 {
   printf("ERROR: nb_lines=0 and lines != NULL ????\n");
   goto wrapup;
 }

sts = vds$init_path(user_path = path, md_env = &md_env, dir_obj = &dir_obj); 
if ( !(sts&1)) {printf("error vds$init_path\n");goto wrapup;}


if(const_flag != MAIN_PATH && const_flag != SEARCH_PATH )
 {printf("ERROR: not a valid arg. const_flag\n"); goto wrapup;}

len = strlen(path);

wrk_found 	= 0;

if(pathname == NULL) 
   {printf("argument pathname cannot be NULL\n"); goto wrapup;}

if(found != NULL) *found = 0;

if(nb_lines == 0)
 {

   lines    = NULL;
   tnb_lines = 0;
   strcpy(&path[len],":*");

   sts = di$ls( regexp = path,
		lines  = &lines,
		ptr    = &tnb_lines);
   if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}

 }
else tnb_lines = nb_lines;


 for (i=0;i<tnb_lines;i++)
   {

    EXP_extract_lhs_rhs(lines[i],name,value);

    sts = di$split(pathname = name, name = real_name);
    if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}
    if(strlen(real_name) >=MY_MAX)
       {printf("ERROR: [%s] is too long\n",real_name);goto wrapup;}

    EXP_extract_string(value,extrd_value);

    if(const_flag == MAIN_PATH)
     {
       status = VDexp_locate("act_symbol_main",real_name);
       if (status != 0) continue;

       status = VDexp_locate("symbol_main",real_name);
       if (status != 0) continue;

       status = VDexp_locate("act_main",real_name);
       if (status != 0) continue;

       status = VDexp_locate("main",real_name);
       if (status != 0) 
        {
          sts = VDSextract_part_exp(extrd_value, extrd_name, after,'!');
          if(!(sts&1))
           { 
       		printf("ERROR: no sep_char found \n");
       		goto wrapup;
           }
	  if(strcmp(extrd_name,pathname) == 0)
           {

	     if(found != NULL) *found = 1;
             if(exp_name != NULL) strcpy(exp_name, real_name);
             if(exp_value != NULL)strcpy(exp_value, extrd_value);
	     wrk_found = 1;
             break;
           }
          else continue;
        }
     }
    else if(const_flag == SEARCH_PATH)
     {
       status = VDexp_locate("act_search",real_name);
       if (status != 0) continue;

       status = VDexp_locate("search",real_name);
       if (status != 0)
        {
          sts = VDSextract_part_exp(extrd_value, extrd_name, after,'!');
          if(!(sts&1))
           { 
       		printf("ERROR: no sep_char found \n");
       		goto wrapup;
           }
	  if(strcmp(extrd_name,pathname) == 0)
           {

	     if(found != NULL) *found = 1;
             if(exp_name != NULL) strcpy(exp_name,  real_name);
             if(exp_value != NULL)strcpy(exp_value, extrd_value);
	     wrk_found = 1;
             break;
           }
          else continue;
        }
     }

   }

if (found != NULL) *found = wrk_found;

if(nb_lines == 0 && lines!= NULL) 
 {
   /*|only dealloc lines allocated in the function */
    di$free(lines = lines,
            count = tnb_lines);
    lines    = NULL;
    tnb_lines = 0;
 }


return OM_S_SUCCESS;
wrapup:
	if(lines != NULL && tnb_lines >= 0) 
 	{
    	 di$free(lines = lines,
                 count = tnb_lines);
    	 lines    = NULL;
    	 tnb_lines = 0;
 	}
	return OM_E_ABORT;


}

/*21  ------------------------ VDSset_act_path -----------------------------*/
/* function that set the given path active.
/* The user define the path to add by its name and the kind of path he wants 
/* to add (MAIN_PATH or SEARCH_PATH). The path must already exist in the list,
/* (can be verified by vds$get_path or vds$get_search_path).
/**/

VDSset_act_path(
char			*path_name,     /* (I) name of the path         */
int			const_flag,	/* (I) MAIN_PATH or SEARCH_PATH */
char			*ret_path      /* (O) returned path         */
)
/*.VDSset_act_path*/
{
char			ref_path[DI_PATH_MAX],path[DI_PATH_MAX+30], 
			exp_name[MY_MAX],exp_value[MY_MAX] ;
struct GRmd_env 	md_env;	
int			len, found,wrk_symb;
struct GRid		dir_obj,exp;	
long			msg,sts;
struct constr_path 	cst_path;
short			rc;
IGRlong			NumberOfBytes;
struct GRsymbology  	symbology;	
struct ret_struct	ret_st;
IGRboolean save_broadcast;




if(path_name == NULL || path_name[0] == '\0')
 {printf("error: arg path_name must be defined\n");goto wrapup;}

len = strlen(path_name);
if(len >= NAME_MAX)
   {printf("ERROR: len of [%s] is > NAME_MAX\n",path_name);goto wrapup;}

if(const_flag != MAIN_PATH && const_flag != SEARCH_PATH )
 {printf("ERROR: not a valid arg. const_flag\n"); goto wrapup;}

/* look for the directory user_path */

sts = vds$init_path(user_path = path, md_env = &md_env, dir_obj = &dir_obj); 
if ( !(sts&1)) {printf("error vds$init_path\n");goto wrapup;}



len = strlen(path);
found = 0;
wrk_symb = 0;

if(const_flag == SEARCH_PATH) strcpy(&path[len],":act_search");
else if(const_flag == MAIN_PATH) strcpy(&path[len],":act_main");

sts = vds$name_exp(	pathname   = path_name,
			const_flag = const_flag,
			exp_name   = exp_name,
			exp_value  = exp_value,
			found      = &found);

if ( !(sts&1)) {printf("error vds$name_exp\n");goto wrapup;}
if ( found != 1) 
 {printf("ERROR: name [%s] doesn't exist\n",path_name);goto wrapup;}

sts = di$translate(	objname = path, 
			p_objid = &exp.objid,
			p_osnum = &exp.osnum);
if (sts != DIR_S_SUCCESS)
 { 
   printf("ERROR: [%s] doesn't exist\n",path);
   goto wrapup;
 }
sts = read_exp(exp_value,&cst_path );
if (! (sts & 1))
  {
    printf("failure read_exp\n");
    goto wrapup;
  }

if(ret_path != NULL) strcpy(ret_path, cst_path.path);

save_broadcast = ASbroadcast_in_progress;
ASbroadcast_in_progress = TRUE;
sts = om$send ( msg = message text_exp.modify( path, exp_value, &rc ),
                     	senderid = NULL_OBJID,
                     	targetid = exp.objid,
		     	targetos = exp.osnum);
ASbroadcast_in_progress = save_broadcast;
if (! (sts & 1))
 {
   printf("failure sending text_exp.modify\n");
   goto wrapup;
 }

if(const_flag == MAIN_PATH) 
 {
   /*| modify symbology expression */
   strcpy(&path[len],":symbol_main");
   strcat(path,&exp_name[4]);

   sts = di$translate(objname = path, p_objid = &exp.objid,
                                       p_osnum = &exp.osnum);
   if (sts != DIR_S_SUCCESS) {printf("ERROR: path [%s] not found\n",path);goto wrapup;}

   /*|give structure */

   sts = om$send ( msg = message text_exp.NDgive_structure( &msg, &ret_st, 
							  &md_env),
                     senderid = NULL_OBJID,
                     targetid = exp.objid,
		     targetos = exp.osnum);
   if (! (sts & 1))
      {
        printf("failure sending text_exp.NDgive_structure\n");
        as$status(sts = sts,action = RET_STATUS);
        goto wrapup;
      }

   /*|define value of expression*/
    strcpy(exp_value,ret_st.var.text_st.text_string);

    sts = VDSexp_to_symb(&symbology, exp_value, &wrk_symb);
    if(!(sts&1)){printf("error VDSexp_to_symb\n");goto wrapup;}

    strcpy(&path[len],":act_symbol_main");

   sts = di$translate(	objname = path, 
			p_objid = &exp.objid,
			p_osnum = &exp.osnum);
   if (sts != DIR_S_SUCCESS)
    { 
      printf("ERROR: [%s] doesn't exist\n",path);
      goto wrapup;
    }

   save_broadcast          = ASbroadcast_in_progress;
   ASbroadcast_in_progress = TRUE;
   sts = om$send ( msg = message text_exp.modify( path, exp_value, &rc ),
                     	senderid = NULL_OBJID,
                     	targetid = exp.objid,
		     	targetos = exp.osnum);
   ASbroadcast_in_progress = save_broadcast;
   if (! (sts & 1))
    {
      printf("failure sending text_exp.modify\n");
      goto wrapup;
    }

 /*| change current dir and current symbology if possible*/

	sts = vds$get_path( return_path = ref_path,const_flag = REF_PATH);
	if (! (sts & 1)){ printf("error get_path\n");goto wrapup; }

	sts = di$cd(dirname = cst_path.path,
            	    path    = ref_path);  
	if(sts != DIR_S_SUCCESS)
 	  {printf("WARNING: can't change the current dir\n");return  OM_S_SUCCESS; }
	
	     /*|put level*/

	     NumberOfBytes = sizeof( symbology.level);
	     gr$put_active_level(msg = &msg,
				 sizbuf = &NumberOfBytes,
				 buffer = &symbology.level);
    
	     if ( !(msg&1)) 
    	     {
		     printf("error put_active_level\n");
    		     return OM_S_SUCCESS;
    	     }
	     /*|put display_attr*/
	     NumberOfBytes = sizeof( symbology.display_attr);
	     gr$put_active_display(msg = &msg,
				   sizbuf = &NumberOfBytes,
				   buffer = &symbology.display_attr);

	     if ( !(msg&1))
    	     {
		     printf("error put_active_display\n");
    		     return OM_S_SUCCESS;
    	     }
 }



return OM_S_SUCCESS;

wrapup:

return OM_E_ABORT;
}


/*22  ------------------------ VDSadd_path -----------------------------*/
/* function that add a path in the path or search path list
/* The user define the path to add, its name (otherwise a default name
/* is given, the symbology of path (if not a search path), and what kind
/* of path he wants to add (MAIN_PATH or SEARCH_PATH). If a name is given,
/* and if that name already exist, the function only modify the definition
/* of the path (to avoid duplicate name). If the user really wants to add
/* a named path, he can verify with the macro vds$get_path or 
/* vds$get_search_path if the name already exist or not. The macro can be
/* used to modify the symbology of a path, by given the name of the path,
/* the symbology, and set the path to NULL. 
/* 
/* */

VDSadd_path(
char			*in_path ,	/* (I) path to add		*/
char			*path_name,     /* (I) name of the path         */
int			const_flag,	/* (I) MAIN_PATH or SEARCH_PATH */
struct GRsymbology  	*symbology,	/* (I) symbology of path	*/
char			*out_name	/* (O) name of path given	*/
)

{

char			name[DI_PATH_MAX],path[DI_PATH_MAX+30], value[DI_PATH_MAX];	
char			real_name[DI_PATH_MAX], extrd_value[DI_PATH_MAX], symb[MY_MAX], 
			list_index[3],auto_name[NAME_MAX],path_to_set[MY_MAX];
struct GRmd_env 	md_env;	
char			**lines;
int			named_flag, exp_index,name_index, wrk_index,i,nb_lines,
			found, len, modify_flag;
struct GRid		dir_obj,exp;	
long			msg,sts,status;
struct constr_path 	act_cst, cst_path;
struct txt_symb		txt_symb ;
struct ret_struct	ret_st;
IGRboolean save_broadcast;
short			rc;



lines    	= NULL;
nb_lines 	= 0;	
found    	= 0;
modify_flag	= 0;

if(in_path == NULL  && path_name == NULL)
 {printf("error: arg in_path or path_name must be defined\n");goto wrapup;}

if(in_path != NULL)
 {
   len = strlen(in_path);
   if(len >= MY_PATH_MAX)
     {printf("ERROR: len of [%s] is > MAX_LEN\n",in_path);goto wrapup;}
 }
if(path_name != NULL)
 {
  len = strlen(path_name);
  if(len >= NAME_MAX)
   {printf("ERROR: len of [%s] is > MAX_LEN\n",path_name);goto wrapup;}
 }
if(const_flag != MAIN_PATH && const_flag != SEARCH_PATH )
 {printf("ERROR: not a valid arg. const_flag\n"); goto wrapup;}


if(symbology != NULL)
 {
    sprintf(txt_symb.layer,"%d",(int)symbology->level);
    sprintf(txt_symb.color,"%d",(int)symbology->display_attr.color);
    sprintf(txt_symb.weight,"%d",(int)symbology->display_attr.weight);
    sprintf(txt_symb.style,"%d",(int)symbology->display_attr.style);
txt_symb.layer_name[0] = '\0';
 }
else
 {
   /*|active symbology */
    strcpy(txt_symb.color,"act");
    strcpy(txt_symb.layer,"act");
    strcpy(txt_symb.weight,"act");
    strcpy(txt_symb.style,"act");
    txt_symb.layer_name[0] = '\0';
 
 }

/* look for the directory user_path */

sts = vds$init_path(user_path = path, md_env = &md_env, dir_obj = &dir_obj); 
if ( !(sts&1)) {printf("error vds$init_path\n");goto wrapup;}


len = strlen(path);

strcat(path,":*");


 sts = di$ls( 	regexp = path,
		lines  = &lines,
		ptr    = &nb_lines);
 if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}

	/**/
	/*| retrieve exp_index and name_index */
	/**/

exp_index  = 0;
name_index = 0;

for (i=0;i<nb_lines;i++)
   {

    EXP_extract_lhs_rhs(lines[i],name,value);

    sts = di$split(pathname = name, name = real_name);
    if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}


     if(const_flag == MAIN_PATH)
      {
        status = VDexp_locate("act_symbol_main",real_name);
        if (status != 0) continue;
        status = VDexp_locate("symbol_main",real_name);
        if (status != 0) continue;
        status = VDexp_locate("act_main",real_name);
        if (status != 0) continue;
        sts = VDexp_locate("main",real_name);
      }
     else if(const_flag == SEARCH_PATH)
      {
        status = VDexp_locate("act_search",real_name);
        if (status != 0) continue;
        sts = VDexp_locate("search",real_name);
      }
     if (sts != 0) 
      {
	wrk_index = -1;
        if(const_flag == MAIN_PATH)
   		sscanf(&real_name[4],"%d", &wrk_index);
        else if(const_flag == SEARCH_PATH)
   		sscanf(&real_name[6],"%d", &wrk_index);

	if(exp_index < wrk_index) exp_index = wrk_index;

        EXP_extract_string(value,extrd_value);


         sts = read_exp(extrd_value,&cst_path);
  	  if (! (sts & 1))
           {
             printf("failure read_exp\n");
             goto wrapup;
           }

	wrk_index = -1;

        if(const_flag == MAIN_PATH && strncmp(cst_path.name,"path",4) == 0)
   		sscanf(&cst_path.name[4],"%d", &wrk_index);
        else if(const_flag == SEARCH_PATH&& strncmp(cst_path.name,"search",6) == 0)
   		sscanf(&cst_path.name[6],"%d", &wrk_index);

    	if(name_index < wrk_index) name_index = wrk_index;
      }

   }


	/**/
	/*|  auto name => necessary add the path */
	/**/

 if(path_name == NULL || path_name[0] == '\0')
  {
    /*|path is added with an auto name */
    cst_path.name[0] = '\0';
    if(in_path == NULL || in_path[0] == '\0')
     {printf("ERROR: neither path_name nor in_path defined\n");goto wrapup;}
    strcpy(cst_path.path, in_path);
    sts = vds$auto_name(	index      = name_index + 1,
				to_name    = &cst_path,
				const_flag = const_flag,
			   	name       = auto_name,
			   	named_flag = &named_flag); 
    if (! (sts & 1) || named_flag == 0)
      	 {
		printf("error vds$auto_name\n");
		goto wrapup;
      	 }

    strcpy(cst_path.name, auto_name);
    if(const_flag == SEARCH_PATH)
     {
   	strcpy(&path[len],":search");
   	sprintf(list_index,"%d",exp_index + 1);
   	strcat(path,list_index);

        sts = write_exp(&cst_path, path_to_set);
	if(!(sts&1)) {printf("error write_exp\n");goto wrapup;}
   	sts = EXP_text_exp_build(path, path_to_set, md_env.md_id.osnum,
 			    &exp.objid);
   	if(!(sts&1))
    	 {
	   printf("error EXP_text_exp_build\n");
    	   goto wrapup;
    	 }
     }
    else if(const_flag == MAIN_PATH)
     {
       strcpy(&path[len],":main");
       sprintf(list_index,"%d",exp_index + 1);
       strcat(path,list_index);

        sts = write_exp(&cst_path, path_to_set);
	if(!(sts&1)) {printf("error write_exp\n");goto wrapup;}
   	sts = EXP_text_exp_build(path, path_to_set, md_env.md_id.osnum,
 			    &exp.objid);
   	if(!(sts&1))
    	 {
	   printf("error EXP_text_exp_build\n");
    	   goto wrapup;
    	 }
        strcpy(&path[len],":symbol_main");
        sprintf(list_index,"%d",exp_index + 1);
        strcat(path,list_index);
	sts = vds$text_to_symb( txt_symb = &txt_symb, 
				exp_symb = path_to_set);

   	sts = EXP_text_exp_build(path, path_to_set, md_env.md_id.osnum,
 			    &exp.objid);
   	if(!(sts&1))
    	 {
	   printf("error EXP_text_exp_build\n");
    	   goto wrapup;
    	 }

     }      
    goto success;
  }

	/**/
	/*|  given name => necessary path or modify it if name already exist */
	/*      if modify is done, verify the name of the active path 
	/*      because path must be modified if this name is the given one
	/**/


 for (i=0;i<nb_lines;i++)
   {

    EXP_extract_lhs_rhs(lines[i],name,value);

    sts = di$split(pathname = name, name = real_name);
    if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}



     if(const_flag == MAIN_PATH)
      {
        status = VDexp_locate("act_symbol_main",real_name);
        if (status != 0) continue;
        status = VDexp_locate("symbol_main",real_name);
        if (status != 0) continue;
        status = VDexp_locate("act_main",real_name);
        if (status != 0) continue;
        sts = VDexp_locate("main",real_name);
      }
     else if(const_flag == SEARCH_PATH)
      {
        status = VDexp_locate("act_search",real_name);
        if (status != 0) continue;
        sts = VDexp_locate("search",real_name);
      }
     if (sts != 0) 
      {

        EXP_extract_string(value,extrd_value);


         sts = read_exp(extrd_value,&cst_path);
  	  if (! (sts & 1))
           {
             printf("failure read_exp\n");
             goto wrapup;
           }


	/**/
	/*|     name is found, don't add but modify existing path */
	/**/

	if(strcmp(cst_path.name,path_name) == 0) 
	 {
           modify_flag = 1;
           sts = write_exp(&cst_path, path_to_set);
	   if(!(sts&1)) {printf("error write_exp\n");goto wrapup;}
	   /*| name found */

           sts = di$translate(objname = name, p_objid = &exp.objid,
			       p_osnum = &exp.osnum);
           if (sts != DIR_S_SUCCESS) {printf("ERROR: name [%s] not found\n",name); goto wrapup;}
           /*|modify expression */

	   save_broadcast          = ASbroadcast_in_progress;
	   ASbroadcast_in_progress = TRUE;
     	   sts = om$send ( msg = message text_exp.modify( name, path_to_set,
							  &rc ),
                     senderid = NULL_OBJID,
                     targetid = exp.objid,
		     targetos = exp.osnum);
	   ASbroadcast_in_progress = save_broadcast;
           if (! (sts & 1))
              {
                printf("failure sending text_exp.modify\n");
                as$status(sts = sts,action = RET_STATUS);
                goto wrapup;
              }
	   if(const_flag == MAIN_PATH)
             {
		/* modify symbology expression */
		strcpy(symb,"symbol_main");
        	strcat(symb, &real_name[4]);

		strcpy(&path[len],":");
		strcat(path,symb);

           	sts = di$translate(objname = path, p_objid = &exp.objid,
			       p_osnum = &exp.osnum);

           	if (sts != DIR_S_SUCCESS) {printf("ERROR: name [%s] not found\n",path); goto wrapup;}
	   	/*|define value of expression*/
		sts = vds$text_to_symb( txt_symb = &txt_symb, 
					exp_symb = path_to_set);
        	if(!(sts&1)){printf("error vds$text_to_symb\n");goto wrapup;}

           	/*|modify expression */

		save_broadcast          = ASbroadcast_in_progress;
		ASbroadcast_in_progress = TRUE;
     	   	sts = om$send ( msg = message text_exp.modify( 	path, 
								path_to_set,
							  	&rc ),
                     		senderid = NULL_OBJID,
                     		targetid = exp.objid,
		     		targetos = exp.osnum);
		ASbroadcast_in_progress = save_broadcast;
           	if (! (sts & 1))
              	 {
                   printf("failure sending text_exp.modify\n");
                   as$status(sts = sts,action = RET_STATUS);
                   goto wrapup;
                 }
              }/* const_flag = main */

	   if(const_flag == SEARCH_PATH) strcpy(&path[len],":act_search");
	   if(const_flag == MAIN_PATH) strcpy(&path[len],":act_main");

           sts = di$translate(objname = path, p_objid = &exp.objid,
			       p_osnum = &exp.osnum);
           if (sts != DIR_S_SUCCESS) {printf("ERROR: name [%s] not found\n",path); goto wrapup;}
   	   sts = om$send ( msg = message text_exp.NDgive_structure(&msg,&ret_st, 
							  &md_env),
                     senderid = NULL_OBJID,
                     targetid = exp.objid,
		     targetos = exp.osnum);
   	   if (! (sts & 1))
      	     {
                printf("failure sending text_exp.NDgive_structure\n");
                as$status(sts = sts,action = RET_STATUS);
        	goto wrapup;
      	     }
  	   sts = read_exp(ret_st.var.text_st.text_string,&act_cst );
  	   if (! (sts & 1))
           {
             printf("failure read_exp\n");
             goto wrapup;
           }
	   /**/
	   /*|     name is also the active one , modify active path */
	   /**/

	   if(strcmp(act_cst.name,path_name) == 0) 
	    {
	      /*| the name is also the active name => modify active path */
              sts = write_exp(&cst_path, path_to_set);
	      if(!(sts&1)) {printf("error write_exp\n");goto wrapup;}
	      /*| name found */

              sts = di$translate(objname = path, p_objid = &exp.objid,
			       p_osnum = &exp.osnum);
              if (sts != DIR_S_SUCCESS) {printf("ERROR: name [%s] not found\n",path); goto wrapup;}
              /*|modify expression */
	      save_broadcast          = ASbroadcast_in_progress;
	      ASbroadcast_in_progress = TRUE;
     	      sts = om$send ( msg = message text_exp.modify( path, path_to_set,
							  &rc ),
                     senderid = NULL_OBJID,
                     targetid = exp.objid,
		     targetos = exp.osnum);
	      ASbroadcast_in_progress = save_broadcast;
              if (! (sts & 1))
               {
                 printf("failure sending text_exp.modify\n");
                 as$status(sts = sts,action = RET_STATUS);
                 goto wrapup;
               }
	      if(const_flag == MAIN_PATH)
                {
		   /* modify active symbology expression */
		   strcpy(&path[len],":act_symbol_main");	

           	   sts = di$translate(objname = path, p_objid = &exp.objid,
			       p_osnum = &exp.osnum);

           	   if (sts != DIR_S_SUCCESS) {printf("ERROR: name [%s] not found\n",path); goto wrapup;}
	   	   /*|define value of expression*/
		   sts = vds$text_to_symb( txt_symb = &txt_symb, 
					exp_symb = path_to_set);
        	   if(!(sts&1)){printf("error vds$text_to_symb\n");goto wrapup;}

           	   /*|modify expression */

		   save_broadcast          = ASbroadcast_in_progress;
		   ASbroadcast_in_progress = TRUE;
     	   	   sts = om$send ( msg = message text_exp.modify( path, 
								path_to_set,
							  	&rc ),
                     		senderid = NULL_OBJID,
                     		targetid = exp.objid,
		     		targetos = exp.osnum);
		   ASbroadcast_in_progress = save_broadcast;
           	   if (! (sts & 1))
              	    {
                      printf("failure sending text_exp.modify\n");
                      as$status(sts = sts,action = RET_STATUS);
                      goto wrapup;
                    }
                 }/* const_flag = main  for active path */
	     }/* act_cst.name = path_name */
           break;
          } /* cst_name = in_name */
       }/* main or search found in exp */
   }/* end boucle */

if(modify_flag == 0)
 {
  /*|add path with given name */
    if(in_path == NULL ||in_path[0] =='\0')
      {printf("ERROR: path must be defined to add path\n");goto wrapup;} 
    strcpy(cst_path.path, in_path);
    strcpy(cst_path.name, path_name);
    if(const_flag == SEARCH_PATH)
     {
   	strcpy(&path[len],":search");
   	sprintf(list_index,"%d",exp_index + 1);
   	strcat(path,list_index);

        sts = write_exp(&cst_path, path_to_set);
	if(!(sts&1)) {printf("error write_exp\n");goto wrapup;}
   	sts = EXP_text_exp_build(path, path_to_set, md_env.md_id.osnum,
 			    &exp.objid);
   	if(!(sts&1))
    	 {
	   printf("error EXP_text_exp_build\n");
    	   goto wrapup;
    	 }
     }
    else if(const_flag == MAIN_PATH)
     {
       strcpy(&path[len],":main");
       sprintf(list_index,"%d",exp_index + 1);
       strcat(path,list_index);

        sts =write_exp(&cst_path, path_to_set);
	if(!(sts&1)) {printf("error write_exp\n");goto wrapup;}
   	sts = EXP_text_exp_build(path, path_to_set, md_env.md_id.osnum,
 			    &exp.objid);
   	if(!(sts&1))
    	 {
	   printf("error EXP_text_exp_build\n");
    	   goto wrapup;
    	 }
        strcpy(&path[len],":symbol_main");
        sprintf(list_index,"%d",exp_index + 1);
        strcat(path,list_index);
	sts = vds$text_to_symb( txt_symb = &txt_symb, 
				exp_symb = path_to_set);

   	sts = EXP_text_exp_build(path, path_to_set, md_env.md_id.osnum,
 			    &exp.objid);
   	if(!(sts&1))
    	 {
	   printf("error EXP_text_exp_build\n");
    	   goto wrapup;
    	 }

     }      

 }

goto success;

success:


 if(out_name != NULL)
  {
   strcpy(out_name, cst_path.name);

  }
  if(lines != NULL && nb_lines != 0)
   {
    di$free(lines = lines,
            count = nb_lines);
    lines = NULL;
    nb_lines = 0;
   }


  return OM_S_SUCCESS;

wrapup:
  if(lines != NULL && nb_lines != 0)
   {
    di$free(lines = lines,
            count = nb_lines);
    lines = NULL;
    nb_lines = 0;
   }
return OM_E_ABORT;
}


/*23  ----------------------- VDSsymbology_from_path ---------------------------*/
/*
/*  Given a path, return the symbology associated to this path in the Path
/*  system.(return OM_E_ABORT if path is not found)
/**/


VDSsymbology_from_path(
char			*path ,   	/* (I) input dir + path	*/
struct GRsymbology 	*symbology	/* (O) output symbology	*/
)
/*.VDSsymbology_from_path*/
{
long			status;
int			found,err_flag, wrk_symb,i, nb_main;
struct constr_path 	*exp_main;
char			symb_text[MY_MAX], wrk_path[DI_PATH_MAX];

 exp_main = NULL; 
 wrk_symb = 0;
 err_flag = 0;


 if(path[0] != ':'){
	printf("ERROR, path must be defined in an absolute way\n");
	err_flag = 1;
	goto wrapup;
 }
 status = vds$give_exp( nb_main   = &nb_main);
 if(!(status & 1)) 
	{printf("ERROR in vds$give_exp\n"); err_flag = 1;goto wrapup;}

 exp_main = (struct constr_path *)om$malloc(size = nb_main*
						sizeof(struct constr_path));
 if(exp_main == NULL){
      printf("bad allocation of exp_main\n");
      err_flag = 1;
      goto wrapup;
 }
 status = vds$give_exp( main_alloc   = nb_main, 
 		        main   	     = exp_main);

 if(!(status & 1)) 
  	{printf("ERROR in vds$give_exp\n"); err_flag = 1;goto wrapup;}

 
 found = 0;
 for (i=0;i< nb_main;i++){

	VDSpath_name(exp_main[i].path, wrk_path);

	if(strcmp(wrk_path, path) == 0){

		/*|path is found, fill symbology*/
		found = 1;
		status = VDStext_to_symb(&exp_main[i].symbology, symb_text);
        	if(!(status&1)){
			printf("error vds$text_to_symb\n");
			err_flag = 1;
			goto wrapup;
		}



 		status = VDSexp_to_symb(symbology, symb_text, &wrk_symb);
 		if(!(status&1)){
			printf("error VDSexp_to_symb\n");
			err_flag = 1; 
			goto wrapup;
		}


		break;       
	}
 }/* loop on path */

 if(!found) err_flag = 1;



wrapup:
 
 if(exp_main != NULL) {free(exp_main);exp_main = NULL;}
 if (err_flag) return OM_E_ABORT;
 return OM_S_SUCCESS;
}

/*24  ----------------------- VDSpath_from_level ---------------------------*/
/*
/*  Given a level, return the first path of the path system which have
/*  this level.(return OM_E_ABORT if level is not found)
/**/


VDSpath_from_level(
IGRshort		level,		/* (I) input level	*/
char			*path    	/* (O) output dir + path	*/
)
{
long			status;
struct GRsymbology 	path_symb;
int			found, err_flag, wrk_symb,i,nb_main;
struct constr_path 	*exp_main;
char			symb_text[MY_MAX];

 exp_main = NULL; 
 wrk_symb = 0;
 err_flag = 0;


 status = vds$give_exp( nb_main   = &nb_main);
 if(!(status & 1)) 
	{printf("ERROR in vds$give_exp\n"); err_flag = 1;goto wrapup;}

 exp_main = (struct constr_path *)om$malloc(size = nb_main*
						sizeof(struct constr_path));
 if(exp_main == NULL){
      printf("bad allocation of exp_main\n");
      err_flag = 1;
      goto wrapup;
 }
 status = vds$give_exp( main_alloc   = nb_main, 
 		        main   	     = exp_main);

 if(!(status & 1)) 
  	{printf("ERROR in vds$give_exp\n"); err_flag = 1;goto wrapup;}

 
 found = 0;
 for (i=0;i< nb_main;i++){

	status = VDStext_to_symb(&exp_main[i].symbology, symb_text);
        if(!(status&1))
	   {printf("error vds$text_to_symb\n");err_flag = 1;goto wrapup;}



 	status = VDSexp_to_symb(&path_symb, symb_text, &wrk_symb);
 	if(!(status&1)){
		printf("error VDSexp_to_symb\n");
		err_flag = 1; 
		goto wrapup;
	}


	if(path_symb.level == level) {

    		/*|path_symb.level == input level */
		found = 1;
		strcpy(path, exp_main[i].path);
		VDSpath_name(path,path);

		break;
	}
 }


if(!found ) err_flag = 1;

wrapup:

 if(exp_main != NULL) {free(exp_main);exp_main = NULL;}
 if (err_flag) return OM_E_ABORT;
 return OM_S_SUCCESS;
}



/* Modification for 2.0 */

/*----------------------------------------------------------------------------*\
 | Looks  for an occurence of the string Pattern in the string Source 
\*----------------------------------------------------------------------------*/
IGRshort  VDexp_locate(char *Pattern, char *Source)
{
	char	*cp,        /* char in Pattern */
		*cs, *csp;  /* char in Source  */

	if(!Pattern || !Source)    return 0;
 
	cs = Source;
	while(*cs != '\0')
	{
	  csp = cs;
	  cp  = Pattern;
	  while(1)
	  {
	    if(*cp  == '\0'){
		 return 1; /* end of pattern --> found */
	    }
	    if(*cp  != *csp) break;     /* string different         */
	    if(*csp == '\0') break;     /* end of string  --> not found */

	    csp++; cp++;
	  }
	  cs++;
	}

	return 0;
}
  
end implementation Root;
