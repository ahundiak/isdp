/* $Id: VDSform_fn.I,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdudp/func / VDSform_fn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSform_fn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/11/29  13:53:48  pinnacle
# Replaced: ./vdudp/func/VDSform_fn.I for:  by ksundar for vds.240
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
 *
 * -------------------------------------------------------------------*/

/****************************************************
/*
/* funtions implementing the macros which need VDpath 
/* forms given (macros are defined in VDSudp_mac.h 
/* or VDSudp_priv.h ).
/*
/****************************************************/

class implementation Root;

#include <stdio.h>
#include <ctype.h>

#include "OMerrordef.h"


#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "FI.h"

#include "wl.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "AS_status.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSudp_priv.h"
#include "VDSpath_form.h"

#define AS_DEBUG 1



/*---------------------- VDSinit_list_form -----------------------------------
    This function is used to initialise the path list form
*/
VDSinit_list_form(form_ptr)
char		*form_ptr;

{
int		num_rows;
long		status;

if (form_ptr == NULL)
 {
     printf("ERROR: no form_ptr set\n");
     return OM_E_ABORT; 
 }

status = FIfld_get_num_rows(form_ptr,LIST_FIELD, &num_rows);
if (status != FI_SUCCESS)
		{printf("FIfld_get_num_rows fail \n"); return OM_E_ABORT;}

if(num_rows != 0)
 {
  status = FIfld_delete_rows(form_ptr,LIST_FIELD, 0, num_rows);
  if (status != FI_SUCCESS)
		{printf("FIfld_delete_rows fail \n"); return OM_E_ABORT;}
 }
status = FIg_enable(form_ptr,SYMB_BUTTON);
status = FIg_enable(form_ptr,SELECT_BUTTON);
status = FIg_enable(form_ptr,LOAD_BUTTON);
status = FIg_enable(form_ptr,EXIT);
status = FIg_enable(form_ptr,SAVE);

status = FIg_set_state_off(form_ptr,SYMB_BUTTON);
status = FIg_set_state_off(form_ptr,SELECT_BUTTON);
status = FIg_set_state_off(form_ptr,LOAD_BUTTON);
if (status != FI_SUCCESS)
		{printf("FIfld_set_state_off fail \n"); return OM_E_ABORT;}

return OM_S_SUCCESS;

}

/*---------------------- VDSset_symbology -----------------------------------
/*    This function is used to set the gadget of the symbology form  
/*    and fill the fields with the given symbology
/**/

VDSset_symbology(text_symb,symb_ptr)

struct txt_symb *text_symb;
char		*symb_ptr;
/*.VDSset_symbology*/
{
struct GRsymbology	symbology;
long			sts, status;
char			text[SYMB_CHAR];

if (symb_ptr == NULL)
 {
     printf("ERROR: no form_ptr set\n");
     return OM_E_ABORT; 
 }
if(text_symb == NULL)
 {
    printf("ERROR: no symbology given\n");
     return OM_E_ABORT; 
 }
 sts = vds$get_active_symb( symbology = &symbology);
 if ( !(sts&1)) {printf("error vds$get_active_symb\n");return OM_E_ABORT;}

 if(strcmp(text_symb->color,"act")==0)
  {
   FIg_set_state_off(symb_ptr, COLOR_TOG );
   if( !(ige$get_name_from_color(name = text,
				color = (short)symbology.display_attr.color)))
     {
	/*|act color has no name */
        sprintf(text,"%d",symbology.display_attr.color);
     }
   
   status = FIfld_set_text(symb_ptr, COLOR_FIELD, 0 ,0,
			   text, FALSE);
   if (status != FI_SUCCESS)
		{printf("FIfld_set_text fail \n"); return OM_E_ABORT;}
   FIfld_set_active_char(symb_ptr, COLOR_FIELD, 0, 0, 0);
  }
 else
 {
   FIg_set_state_on(symb_ptr, COLOR_TOG );
   status = FIfld_set_text(symb_ptr, COLOR_FIELD, 0 ,0,text_symb->color, FALSE);
   if (status != FI_SUCCESS)
		{printf("FIfld_set_text fail \n"); return OM_E_ABORT;}
   FIfld_set_active_char(symb_ptr, COLOR_FIELD, 0, 0, 0);
 }
 if(strcmp(text_symb->weight,"act")==0)
  {
   FIg_set_state_off(symb_ptr, WEIGHT_TOG );
   sprintf(text,"%d",symbology.display_attr.weight);
   status = FIfld_set_text(symb_ptr, WEIGHT_FIELD, 0 ,0,
			   text, FALSE);
   if (status != FI_SUCCESS)
		{printf("FIfld_set_text fail \n"); return OM_E_ABORT;}
  }
 else
 {
   FIg_set_state_on(symb_ptr, WEIGHT_TOG );
   status = FIfld_set_text(symb_ptr, WEIGHT_FIELD, 0 ,0,text_symb->weight, FALSE);
   if (status != FI_SUCCESS)
		{printf("FIfld_set_text fail \n"); return OM_E_ABORT;}
 }

 if(strcmp(text_symb->style,"act")==0)
  {
   FIg_set_state_off(symb_ptr, STYLE_TOG );
   sprintf(text,"%d",symbology.display_attr.style);
   status = FIfld_set_text(symb_ptr, STYLE_FIELD, 0 ,0,
			 text, FALSE);
   if (status != FI_SUCCESS)
		{printf("FIfld_set_text fail \n"); return OM_E_ABORT;}
  }
 else
 {
   FIg_set_state_on(symb_ptr, STYLE_TOG );
   status = FIfld_set_text(symb_ptr, STYLE_FIELD,0 ,0,text_symb->style, FALSE);
   if (status != FI_SUCCESS)
		{printf("FIfld_set_text fail \n"); return OM_E_ABORT;}
 }

 if(strcmp(text_symb->layer,"act")==0)
  {
   FIg_set_state_off(symb_ptr, LAYER_TOG );
   sprintf(text,"%d",symbology.level);
   status = FIfld_set_text(symb_ptr,LAYER_FIELD , 0 ,0,
			   text, FALSE);
   if (status != FI_SUCCESS)
		{printf("FIfld_set_text fail \n"); return OM_E_ABORT;}
  }
 else
 {
   FIg_set_state_on(symb_ptr, LAYER_TOG );
   status = FIfld_set_text(symb_ptr, LAYER_FIELD,0 ,0,text_symb->layer, FALSE);
   if (status != FI_SUCCESS)
		{printf("FIfld_set_text fail \n"); return OM_E_ABORT;}
 }
if(text_symb->layer_name[0] != '\0'){
   status = FIfld_set_text(symb_ptr, LAYER_NAME,0 ,0,text_symb->layer_name, FALSE);
   if (status != FI_SUCCESS)
		{printf("FIfld_set_text fail \n"); return OM_E_ABORT;}
   FIfld_set_active_char(symb_ptr, LAYER_NAME, 0, 0, 0);
	
}
else{
   status = FIfld_set_text(symb_ptr, LAYER_NAME,0 ,0,"", FALSE);
   if (status != FI_SUCCESS)
		{printf("FIfld_set_text fail \n"); return OM_E_ABORT;}
   FIfld_set_active_char(symb_ptr, LAYER_NAME, 0, 0, 0);
}
return OM_S_SUCCESS;

}


/*----------------------- VDSupdate_path ---------------------------*/
VDSupdate_path(form_ptr, current,main,search,nb_main,nb_search)
   char                 *form_ptr;
   struct current_path	*current;    
   struct constr_path   *main;
   struct constr_path   *search;       /*(I) input information  */
   int			nb_main;       /*   to put in the forms */
   int			nb_search;

/*.VDSupdate_path*/

{
long                    status,sts;
int                     i,num_row;
char			act_dir[DI_PATH_MAX];


num_row = 0;



if ( form_ptr == NULL )
   {
     printf("ERROR: no form_ptr set \n");
     goto wrapup; 
    }

  /* mise a jour de active dir */

  sts = di$pwd(dirname = act_dir);
  if(!(sts&1)){printf("error pwd\n");goto wrapup;}

  status = FIfld_set_text(form_ptr,ACT_DIR , 0 ,0,act_dir,FALSE);
  if (status != FI_SUCCESS)
               {printf("FIfld_set_text fail \n"); goto wrapup;}

   /*| mise a jour des active paths */

  if(current != NULL)
   {
     status = FIfld_set_text(form_ptr, REFERENCE, 0 , 0,current->reference_path,
			   FALSE);
     if (status != FI_SUCCESS)
               {printf("FIfld_set_text fail \n"); goto wrapup;}

    FIfld_set_active_char(form_ptr, REFERENCE, 0, 0, 0);
    status = FIfld_set_text(form_ptr,MAIN_NAME_FIELD , 0 ,0,
                             current->main_cst_path.name,FALSE);
     if (status != FI_SUCCESS)
               {printf("FIfld_set_text fail \n"); goto wrapup;}

    FIfld_set_active_char(form_ptr, MAIN_NAME_FIELD, 0, 0, 0);
     status = FIfld_set_text(form_ptr,MAIN_PATH_FIELD , 0 ,0,
                             current->main_cst_path.path,FALSE);
     if (status != FI_SUCCESS)
               {printf("FIfld_set_text fail \n"); goto wrapup;}

     status = FIfld_set_text(form_ptr, SEARCH_NAME_FIELD, 0, 0, 
                             current->search_cst_path.name, FALSE);
     if (status != FI_SUCCESS)
               {printf("FIfld_set_text fail \n"); goto wrapup;}
    FIfld_set_active_char(form_ptr, SEARCH_NAME_FIELD, 0, 0, 0);
     status = FIfld_set_text(form_ptr, SEARCH_PATH_FIELD, 0, 0, 
                             current->search_cst_path.path, FALSE);
     if (status != FI_SUCCESS)
               {printf("FIfld_set_text fail \n"); goto wrapup;}
   }

   /*| mise a jour des listes de noms */

  if(main != NULL)
   {
     num_row = 0;
     status = FIfld_set_list_num_rows(form_ptr, MAIN_NAME_FIELD, 0, num_row);
     for (i=0;i < nb_main;i++)
      {
        if(main[i].name[0] != '\0')
         {
           status = FIfld_get_list_num_rows(form_ptr, MAIN_NAME_FIELD, 0, &num_row);
           status = VDfld_set_list_text(form_ptr, MAIN_NAME_FIELD, num_row,0,
				     main[i].name,FALSE);
           if (status != FI_SUCCESS)
               {printf("VDfld_set_list_text fail\n"); goto wrapup;}
         }
      }
   }
  if(search != NULL)
   {
     num_row = 0;
     status = FIfld_set_list_num_rows(form_ptr, SEARCH_NAME_FIELD, 0, num_row);
     for (i=0;i< nb_search;i++)
      {
        if(search[i].name[0] != '\0')
         {
           status = FIfld_get_list_num_rows(form_ptr, SEARCH_NAME_FIELD, 0, &num_row);
           status = VDfld_set_list_text(form_ptr,SEARCH_NAME_FIELD , num_row,0,
				        search[i].name,FALSE);
           if (status != FI_SUCCESS)
               {printf("VDfld_set_list_text fail\n"); goto wrapup;}
         }
      }
   }

return OM_S_SUCCESS;
wrapup:
        return OM_E_ABORT;
}


end implementation Root;

