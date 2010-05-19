/* $Id: PDUdsgn_frm.c,v 1.4 2001/10/29 17:16:25 jdsauby Exp $ */
/* -------------------------------------------------------------------
 * I/VDS
 *
 * File: vds/emsfixes/pdu/design/PDUdsgn_frm.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *       $Log: PDUdsgn_frm.c,v $
 *       Revision 1.4  2001/10/29 17:16:25  jdsauby
 *       JTS CR 5552 - jds
 *
 *       Revision 1.3  2001/10/16 15:35:36  jdsauby
 *       JTS MP CR 5536, plus misc  JDS 10/16/01
 *
 *       Revision 1.2  2001/09/07 18:30:54  jdsauby
 *       Final Checkin for AIM / PDU integration  - jds
 *
 *       Revision 1.1  2001/08/15 19:25:57  jdsauby
 *       Added to SP for AIM PDM integration - jds, tls
 *
 *
 *
 * Revision 1.3  2000/10/24  21:50:08  pinnacle
 * (No comment)
 *
 *
 * History:
 *       MM/DD/YY        AUTHOR          DESCRIPTION
 *       08/15/01	 js		 AIM integration
 * -------------------------------------------------------------------------*/


/*#include "PALfunkpro.h"*/
#include <tools.h>
#include "FI.h"
#include "exdef.h"
#include "PDUstr.h"
#include "PDUforms.h"
#include "PDUform_def.h"
#include "PDUcommand.h"
#include "PDUerror.h"
#include "MEMerrordef.h"
#include "PDUextdef.h"
#include "PDUfile_def.h"
#include "PDUassy.h"
#include "PDUproto.h"
/*#include "PDMproto.h"*/
#include "part_gadgets.h"


/* Gadgets */
#define REPLACE_PART    49
#define DB_UTILITIES    31
#define PLACE_PART      36
#define DEFINE_ORIGIN   63
#define DELETE_ORIGIN   64
#define COPY_PART       42
#define ACT_CATALOG	22
#define ACT_PART        23
#define ACT_REV         25
#define ACT_FILE        24
#define HIGHLIGHT_PART  34
#define MANAGE_DISPLAY  18
#define DSP_PART_PTR    12
#define POSITION_PARTS  43
#define REPORTS         47
#define LOGOUT          20
#define DELETE_PART     26
#define TOP_DOWN        19

/* Externs */

/* TLS: Added per ISDP ( Ad ) request 10/24/00 */ 
extern int EX_is_batch();

extern char * calloc();
extern char * realloc();
extern int FIg_get_text_length();
extern int FIg_get_text();
extern Form dynamic_attr_form_id;
extern int PDUdynamic_attr_form();
extern struct PDUrefresh *refresh;
extern struct PDUforms forms;
extern struct PDUassy_node *PDU_assy_head;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_struct_bufr;
extern short  PDU_display_dyn_attr;
extern short  PDU_attach;
extern short  PDU_align;
extern short  PDU_edit_display;
extern short  PDU_auto_login;
extern char   *PDU_incl_BOM;
extern char   *PDU_incl_ASM;
extern char   *PDU_explode_BOM;
extern char    PDU_place_part_by;
extern char    PDU_align_part_by;
extern char    *PDU_save;
extern int    PDU_command;
extern Form     PDU_form_id;
extern Form     PDU_calling_form;
extern int      PDU_form_type;
extern int      PDU_search_type;
extern int    PDU_refresh_gadgets[7];
extern MEMptr   PDU_display_buffer;
extern MEMptr   PDU_design_parts_bufr;
extern char     ***PDU_update_struct;
extern int      *PDU_gadget_labels;
extern int      PDMdebug_on;
extern Form   PDU_struct_type;
extern short    PDU_display_pointers;
extern int      PDU_design_opt_create;
extern int      PDU_active_part_create;
extern int      new_mode;
extern struct PDUpath_node *PDU_path_list;
extern short      PDU_design_form_display;
extern int        PDU_active_button;
extern int        PDU_active_list;
extern int        PDU_explode_depth;
extern int        PDU_save_level;
extern short      PDU_perm_window;
extern short      PDU_design_perm_window;
extern short      PDU_local_perm_window;
extern int        PDM_debug_on;
extern short      PDU_activate_copy;
extern short      PDU_active_part;
extern int        PDU_local_files_displayed;
extern int        PDU_local_files_created;
extern char       *PDU_usage_id;
extern short      PDU_list_parts;
extern char     *PDU_save_act_catalog;
extern char     *PDU_save_act_partid;
extern char     *PDU_save_act_revision;
extern char     *PDU_save_act_description;
extern char     *PDU_save_act_filename;

extern int PDMInfoOnCommandbar();

extern struct part_dynamic_attrs *part_occur_list;

extern long VDpdmInitReplPart();


/* TLS: Added per ISDP ( Ad ) request 10/24/00 */
int PDU_FIf_display(Form form)
{
  long  sts = 1;



  if( !EX_is_batch() ) {
        sts = FIf_display(form);
  }

  return sts;
}

int design_form_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int             status;
  int             responses[1];
  char            *strings[1];
  int             state;

  int length, pos, select;

  static char *text1, *text2, *text3;


  FIg_set_text(fp, FI_MSG_FIELD, "");

  

  PDU_form_id = forms.design_form_id;
  fp = forms.design_form_id;

  switch ( g_label )
  {
    case REPLACE_PART:     
           PDU_list_parts = FALSE;
           if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
             PDUfill_in_string(&PDU_usage_id, NULL);
         
         /* erase the design form */
         PDU_design_form_display = FALSE;
         FIf_erase(forms.design_form_id);
         PDU_command = PDC_M_REPLACE_PART;

         /* JAMAL: Call Sarma's Modify/Replace part */
         PDU_calling_form = 0;
         //ModifyPart(fp);

	 // Call Sauby's replace Part for VDS.
	 VDpdmInitReplPart();

         break;

    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         value = 0.0;
         _pdm_debug("f_label = <%d>", f_label);
         FIf_cvrt_to_perm_win(fp);
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("design_form");

         break;

    case FI_RESET:
         if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
            PDUfill_in_string(&PDU_usage_id, NULL);

         if (refresh->rev_project)
           PDUfill_in_string(&refresh->rev_project, NULL);
         if (refresh->rev_catalog)
           PDUfill_in_string(&refresh->rev_catalog, NULL);
         if (refresh->rev_partid)
           PDUfill_in_string(&refresh->rev_partid, NULL);
         if (refresh->rev_revision)
           PDUfill_in_string(&refresh->rev_revision, NULL);
         if (refresh->rev_description)
           PDUfill_in_string(&refresh->rev_description, NULL);
         if (refresh->rev_filename)
           PDUfill_in_string(&refresh->rev_filename, NULL);
         if (refresh->rev_parttype)
           PDUfill_in_string(&refresh->rev_parttype, NULL);

         PDUcheck_file_for_origins();
         PDUcheck_file_for_parts();
         PDUcheck_if_file_an_assembly();

         break;

    case FI_CVT_TO_PERM_WIN:
 
         PDU_perm_window = TRUE;
         PDU_design_perm_window = TRUE;
         break;

    case FI_CANCEL:

         PDU_design_form_display = FALSE;
         if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
            PDUfill_in_string(&PDU_usage_id, NULL);
         PDUmessage(PDM_E_CLEAR_FIELD, 's');
         FIf_erase(fp);
	 PDU_design_form_display = FALSE;

         break;

    case REPORTS:     
         if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
            PDUfill_in_string(&PDU_usage_id, NULL);

         /* collapse the design form */
         PDU_design_form_display = FALSE;
         FIf_erase(forms.design_form_id);

         PDU_calling_form = forms.design_form_id;
         /* call reports form */
         PDUreports_form();
         break;

    case PLACE_PART:     
         if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
            PDUfill_in_string(&PDU_usage_id, NULL);

         /* erase the design form */
         PDU_design_form_display = FALSE;
         FIf_erase(forms.design_form_id);

      /* JAMAL - Added to call Sarma's Form */
      PDU_calling_form = 0;
      PDUfill_in_string(&refresh->rev_parttype, NULL);
      SelectOrPlacePart(FALSE,FALSE,forms.design_form_id);

         break;

    case COPY_PART:
         PDU_list_parts = FALSE;
         if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
            PDUfill_in_string(&PDU_usage_id, NULL);

         /* erase the design form */
         PDU_design_form_display = FALSE;
         FIf_erase(fp);

         PDU_command = PDC_M_COPY_PART_PTR;

         /* JAMAL - Added a call to Sarma's Copy part */
         PALcopy_part(fp);

         break;

    case DELETE_PART:
         PDU_list_parts = FALSE;
         if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
            PDUfill_in_string(&PDU_usage_id, NULL);

         /* erase the design form */
         PDU_design_form_display = FALSE;
         FIf_erase(fp);

         PDU_command = PDC_M_DELETE_PART_PTR;

         /* JAMAL - Added a call to Sarma's Delete part */
         PALdel_part(fp);

         break;

    case DEFINE_ORIGIN:     /* Sequenced to     */
         if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
            PDUfill_in_string(&PDU_usage_id, NULL);

         /* erase design form */
         PDU_design_form_display = FALSE;
         FIf_erase(forms.design_form_id);

         break;

    case DELETE_ORIGIN:     
         if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
            PDUfill_in_string(&PDU_usage_id, NULL);

         /* erase design form */
         PDU_command = PDC_M_DELETE_ORIGIN;
         PDU_design_form_display = FALSE;
         FIf_erase(forms.design_form_id);

         break;
   
    case HIGHLIGHT_PART:
         if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
            PDUfill_in_string(&PDU_usage_id, NULL);

         /* erase design form */
        PDU_design_form_display = FALSE;
        FIf_erase(forms.design_form_id);
         PDU_command = PDC_M_LOCATE_REV_PRTS;

        break;

   case MANAGE_DISPLAY:
/* For some reason, we lose the PDU_form_id in the z d l process
   * try to get it back to make the design form (Part_id) display */
  if ( fp == NULL ) {
      printf ("## PDU_form_id == NULL (recovering)\n");
      FI_get_form_by_name("Part_id", &fp);
  }

         PDU_design_form_display = FALSE;
         FIf_erase(fp);
        break;

   case POSITION_PARTS:
         PDU_list_parts = FALSE;
         if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
            PDUfill_in_string(&PDU_usage_id, NULL);

         PDU_attach = TRUE;

         PDU_design_form_display = FALSE;
         FIf_erase(forms.design_form_id);
         PDU_command = PDC_M_POSITION_PARTS;

        break;

   case DSP_PART_PTR:
         if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
            PDUfill_in_string(&PDU_usage_id, NULL);

        FIg_get_state(fp, DSP_PART_PTR, &state);

        if (state == 0)
          PDU_display_pointers = FALSE;
        else
          PDU_display_pointers = TRUE;

         responses[0] = EX_CMD_KEY;

         strings[0] = "PDTgPrPnDs";

         status = PDUprepare_queue ( responses, strings, 1 );
        _pdm_status("PDUprepare_queue (activate non-existing file)",status);

        break;

  case LOGOUT:

       FIg_disable(fp, g_label);
       PDU_form_id = forms.design_form_id;
       break;

  case DB_UTILITIES:

       PDU_design_form_display = FALSE;
       FIf_erase(fp);
       if ((refresh->act_catalog) && (strcmp(refresh->act_catalog, "") != 0))
         PDUfill_in_string(&refresh->rev_catalog, refresh->act_catalog);
       if ((refresh->act_partid) && (strcmp(refresh->act_partid, "") != 0))
         PDUfill_in_string(&refresh->rev_partid, refresh->act_partid);
       if ((refresh->act_revision) && (strcmp(refresh->act_revision, "") != 0))
         PDUfill_in_string(&refresh->rev_revision, refresh->act_revision);
       if ((refresh->act_filename) && (strcmp(refresh->act_filename, "") != 0))
         PDUfill_in_string(&refresh->rev_filename, refresh->act_filename);
       if ((refresh->act_parttype) && (strcmp(refresh->act_parttype, "") != 0))
         PDUfill_in_string(&refresh->rev_parttype, refresh->act_parttype);
       if ((refresh->act_description) && 
           (strcmp(refresh->act_description, "") != 0))
         PDUfill_in_string(&refresh->rev_description, refresh->act_description);
       if (PDU_local_files_created)
         {
         PDUrefresh_local_files_form();

/* Forms on SGI/Sol does not have FI_NORMAL_PRIORITY defined. MaC */
#if defined (clipper)
         FIf_set_window_level(forms.local_files_form_id, FI_NORMAL_PRIORITY);
#endif
         /* TLS: Added per ISDP ( Ad ) request 10/24/00 */
		 PDU_FIf_display(forms.local_files_form_id);
 	
/* added code Pullabhotla 05/06/2000 when Invoking DATABASE_UTILITIES BUTTON 
   after PDM login*/
	

  FIfld_get_text_length(forms.design_form_id, ACT_CATALOG, 0, 0, &length);
  						
  text1 = (char *) malloc (sizeof (char) * length + 1);
  memset(text1, NULL, sizeof (char) * length + 1);

  FIfld_get_text(forms.design_form_id, ACT_CATALOG, 0, 0, length,
        	 (unsigned char *)text1, &select, &pos);


  FIfld_get_text_length(forms.design_form_id, ACT_PART, 0, 0, &length);

  text2 = (char *) malloc (sizeof (char) * length + 1);
  memset(text2, NULL, sizeof (char) * length + 1);

  FIfld_get_text(forms.design_form_id, ACT_PART, 0, 0, length, 
                 (unsigned char *)text2, &select, &pos);


  FIfld_get_text_length(forms.design_form_id, ACT_REV, 0, 0, &length);

  text3 = (char *) malloc (sizeof (char) * length + 1);
  memset(text3, NULL, sizeof (char) * length + 1);

  FIfld_get_text(forms.design_form_id, ACT_REV, 0, 0, length, 
                  (unsigned char *)text3, &select, &pos);


  if(text1 != NULL && text2 != NULL && text3 != NULL)
         {
	      //status = PDMQueryforMdcExists(text1, text2, text3);
		status = PDMInfoOnCommandbar(text1, text2, text3);
		
	 } 
  		          
 	 
         break;
         }
       else
         PDUlocal_files_form();
	 
/* added code pullabhotla  02/06/2000 Invoking DATABASE_UTILITIES at the
   time of LOGIN_TO_PDM */

   
   FIfld_get_text_length(forms.design_form_id, ACT_CATALOG, 0, 0, &length);
						
   text1 = (char *) malloc (sizeof (char) * length + 1);
   memset(text1, NULL, sizeof (char) * length + 1);

   FIfld_get_text(forms.design_form_id, ACT_CATALOG, 0, 0, length,
      	          (unsigned char *)text1, &select, &pos);

   FIfld_get_text_length(forms.design_form_id, ACT_PART, 0, 0, &length);

   text2 = (char *) malloc (sizeof (char) * length + 1);
   memset(text2, NULL, sizeof (char) * length + 1);
	 
   FIfld_get_text(forms.design_form_id, ACT_PART, 0, 0, length, 
                  (unsigned char *)text2, &select, &pos);

   FIfld_get_text_length(forms.design_form_id, ACT_REV, 0, 0, &length);

   text3 = (char *) malloc (sizeof (char) * length + 1);
   memset(text3, NULL, sizeof (char) * length + 1);
   
   FIfld_get_text(forms.design_form_id, ACT_REV, 0, 0, length, 
                  (unsigned char *)text3, &select, &pos);

		     
    if(text1 != NULL && text2 != NULL && text3 != NULL)
       {
          //status = PDMQueryforMdcExists(text1, text2, text3);
		status = PDMInfoOnCommandbar(text1, text2, text3);

       } 

      break;
   
  } /* END switch ( g_label ) */
  return(1);
} /* END design_form_notification_routine() */

int design_form()
{
  int  status;
  int   level = 0;

  static char *text1, *text2, *text3;
  int length, pos, select;


  _pdm_debug("In the design_form function", 0);

  /* Initialise global variables */
  PDUinitialize_replace_pointers();

  _pdm_debug("Initalizing Design Form", 0);
  status = FIf_new(DESIGN_FORM, "Part_id", 
		design_form_notification_routine,
                &forms.design_form_id);

  // SSR 2 JUN
  if (!PDU_auto_login)
    {
    status = PDUconvert_form_to_win(forms.design_form_id);
    _pdm_status("PDUconvert_form_to_win", status);
    }
  if (!PDU_auto_login)
  {
   /* set active part info into the active part fields */
   if ((refresh->act_catalog) && (strcmp(refresh->act_catalog, "") != 0))
    FIg_set_text(forms.design_form_id, ACT_CATALOG, refresh->act_catalog);
   else
    FIg_set_text(forms.design_form_id, ACT_CATALOG, "");
   if ((refresh->act_partid) && (strcmp(refresh->act_partid, "") != 0))
    FIg_set_text(forms.design_form_id, ACT_PART, refresh->act_partid);
   else
    FIg_set_text(forms.design_form_id, ACT_PART, "");
   if ((refresh->act_revision) && (strcmp(refresh->act_revision, "") != 0))
    FIg_set_text(forms.design_form_id, ACT_REV, refresh->act_revision);
   else
     FIg_set_text(forms.design_form_id, ACT_REV, "");
   if ((refresh->act_filename) && (strcmp(refresh->act_filename, "") != 0))
     FIg_set_text(forms.design_form_id, ACT_FILE, refresh->act_filename);
   else
    {
     FIg_set_text(forms.design_form_id, ACT_FILE, "");
     if (PDUis_active_file_a_part())
      {
        FIg_set_text(forms.design_form_id, ACT_CATALOG, refresh->act_catalog);
        FIg_set_text(forms.design_form_id, ACT_PART, refresh->act_partid);
        FIg_set_text(forms.design_form_id, ACT_REV, refresh->act_revision);
        FIg_set_text(forms.design_form_id, ACT_FILE, refresh->act_filename);
       }
     }
    //added by SSR 2 JUN
  /*  printf("\n setting refresh values%s,%s,%s",
    refresh->act_catalog,refresh->act_partid, refresh->act_revision); */
  
    }

  /* set global refresh array for listing fields */

  /* check file for write permissions */
/*
  status = PDUcheck_file_permissions();
  if ((status == FALSE) || (PDU_activate_copy))
    {
    FIg_disable(forms.design_form_id, DEFINE_ORIGIN);
    msg = (char *)PDUtranslate_message(PDM_E_READ_ONLY);
    FIg_set_text(forms.design_form_id, FI_MSG_FIELD, msg);
    PDU_activate_copy = FALSE;
    }
*/
  /* set global variables for TOGGLES in form to "N" or FALSE */
  PDUfill_in_string(&PDU_incl_BOM, "Y");
  PDUfill_in_string(&PDU_incl_ASM, "Y");
  PDUfill_in_string(&PDU_explode_BOM, "Y");

  PDU_attach = TRUE;
  PDU_align = FALSE;
  PDU_display_dyn_attr = FALSE;
  PDU_place_part_by = 'A';
  PDU_align_part_by = 'P';
  PDU_display_pointers = TRUE;
  PDU_explode_depth = MAX_LEVEL;
  PDU_edit_display = FALSE;
  
  /* set up global form_id */
  PDU_form_id = forms.design_form_id;
  PDU_calling_form = forms.design_form_id;

  PDU_struct_type = forms.design_form_id;

  if (!PDU_auto_login)
  {
    /* PDUcheck_file_for_parts */
     PDUcheck_file_for_parts();
     PDUcheck_file_for_origins();
     PDUcheck_if_file_an_assembly();
  }

  /* Make sure path list is initialized and freed */
  if (PDU_path_list)
     {
      _pdm_debug("freeing PDU_path_list", 0);
      free(PDU_path_list);
      PDU_path_list = NULL;
     }

  /* get the max level of display from the database */
  if ((refresh->act_catalog) && (strcmp(refresh->act_catalog, "") != 0) &&
      (refresh->act_partid) && (strcmp(refresh->act_partid, "") != 0) &&
      (refresh->act_revision) && (strcmp(refresh->act_revision, "") != 0))
    {
    PDU_command = PDC_M_ACTIVATE_PART;
    status = PDUget_max_level(&level);
    _pdm_status("PDUget_max_level", status);

    if (status != PDM_S_SUCCESS)
    {
    /* default the level */
    _pdm_debug("defaulting max_level", 0);
    PDU_explode_depth = 50;
    PDU_save_level = 50;
    }
    else
    {
    PDU_explode_depth = level;
    PDU_save_level = level;
    }
    }
  else
    {
    PDU_explode_depth = 50;
    PDU_save_level = 50;
    FIg_disable(forms.design_form_id, DEFINE_ORIGIN);
    FIg_disable(forms.design_form_id, PLACE_PART);
    FIg_disable(forms.design_form_id, TOP_DOWN);
    }

  PDU_perm_window = TRUE;
  PDU_design_perm_window = TRUE;

  FIf_set_size(forms.design_form_id, 498, 389);

  _pdm_debug("Displaying the design form", 0);
  /* TLS: Added per ISDP ( Ad ) request 10/24/00 */
  if (!PDU_auto_login) {
    status = PDU_FIf_display(forms.design_form_id);
  }
  PDU_active_part = TRUE;

/* added code Pullabhotla 06/06/2000 Displays MDC Info at the time of
   LOGIN_TO_PDM */

 FIfld_get_text_length(forms.design_form_id, ACT_CATALOG, 0, 0, &length);
 						
 text1 = (char *) malloc(sizeof (char) * length + 1);
 memset(text1, NULL, sizeof (char) * length + 1);

 FIfld_get_text(forms.design_form_id, ACT_CATALOG, 0, 0, length,
        	 (unsigned char *)text1, &select, &pos);

 FIfld_get_text_length(forms.design_form_id, ACT_PART, 0, 0, &length);

 text2 = (char *) malloc (sizeof (char) * length + 1);
 memset(text2, NULL, sizeof (char) * length + 1);

 FIfld_get_text(forms.design_form_id, ACT_PART, 0, 0, length, 
                (unsigned char *)text2, &select, &pos);

  FIfld_get_text_length(forms.design_form_id, ACT_REV, 0, 0, &length);

  text3 = (char *) malloc (sizeof (char) * length + 1);
  memset(text3, NULL, sizeof (char) * length + 1);
	   
  FIfld_get_text(forms.design_form_id, ACT_REV, 0, 0, length, 
                 (unsigned char *)text3, &select, &pos);

	
  if(text1 != NULL && text2 != NULL && text3 != NULL)
      {
	     //status = PDMQueryforMdcExists(text1, text2, text3);
		 status = PDMInfoOnCommandbar(text1, text2, text3);

      }  


  return(status); 
}

int PDUdesign_form()

{
  int status;


  _pdm_debug("Displaying PDU Design Form", 0);

  PDU_design_opt_create = FALSE;
  PDU_active_part_create = FALSE;

  status = design_form();
  if (status == FI_SUCCESS)
    status = PDM_S_SUCCESS;
  refresh->status = PDM_S_SUCCESS;

  return(status);
}

int PDUupdate_design_form()

  {
  int status;

  static char *text1, *text2, *text3;
  int length, pos, select;

  _pdm_debug("in the function PDUupdate_design_form", 0);

  if (!forms.design_form_id)
    {
    PDUdesign_form();
    return(PDM_S_SUCCESS);
    }

  FIg_set_state_off(forms.design_form_id, FI_CANCEL);

  if (PDU_design_perm_window)
    PDU_perm_window = TRUE;
  else
    PDU_perm_window = FALSE;

  PDU_command = -1;
  PDUsetup_design_struct();
  PDUcheck_file_for_origins();
  PDUcheck_file_for_parts();
  PDUcheck_if_file_an_assembly();

  if ((refresh->act_catalog) && (strcmp(refresh->act_catalog, "") != 0))
    {
    FIg_set_text(forms.design_form_id, ACT_CATALOG, refresh->act_catalog);
    FIg_enable(forms.design_form_id, DEFINE_ORIGIN);
    FIg_enable(forms.design_form_id, PLACE_PART);
    FIg_enable(forms.design_form_id, TOP_DOWN);
    }
  else
    {
    FIg_set_text(forms.design_form_id, ACT_CATALOG, "");
    FIg_disable(forms.design_form_id, DEFINE_ORIGIN);
    FIg_disable(forms.design_form_id, PLACE_PART);
    FIg_disable(forms.design_form_id, TOP_DOWN);
    }
  if ((refresh->act_partid) && (strcmp(refresh->act_partid, "") != 0))
    FIg_set_text(forms.design_form_id, ACT_PART, refresh->act_partid);
  else
    FIg_set_text(forms.design_form_id, ACT_PART, "");
  if ((refresh->act_revision) && (strcmp(refresh->act_revision, "") != 0))
    FIg_set_text(forms.design_form_id, ACT_REV, refresh->act_revision);
  else
    FIg_set_text(forms.design_form_id, ACT_REV, "");
  if ((refresh->act_filename) && (strcmp(refresh->act_filename, "") != 0))
    FIg_set_text(forms.design_form_id, ACT_FILE, refresh->act_filename);
  else
    FIg_set_text(forms.design_form_id, ACT_FILE, "");

  status = PDUconvert_form_to_win(forms.design_form_id);
  _pdm_status("PDUconvert_form_to_win", status);

  /* TLS: Added per ISDP ( Ad ) request 10/24/00 */
  PDU_FIf_display(forms.design_form_id);
  PDUmessage(PDM_S_SUCCESS, 's');

/* added code Pullabhotla 06/06/2000 Displays MDC Info after PDM login */


 FIfld_get_text_length(forms.design_form_id, ACT_CATALOG, 0, 0, &length);
  						
 text1 = (char *) malloc(sizeof (char) * length + 1);
 memset(text1, NULL, sizeof(char) * length + 1);

 FIfld_get_text(forms.design_form_id, ACT_CATALOG, 0, 0, length,
                (unsigned char *)text1, &select, &pos);

 FIfld_get_text_length(forms.design_form_id, ACT_PART, 0, 0, &length);

 text2 = (char *) malloc (sizeof (char) * length + 1);
 memset(text2, NULL, sizeof (char) * length + 1);

 FIfld_get_text(forms.design_form_id, ACT_PART, 0, 0, length, 
                (unsigned char *)text2, &select, &pos);


 FIfld_get_text_length(forms.design_form_id, ACT_REV, 0, 0, &length);

 text3 = (char *) malloc (sizeof (char) * length + 1);
 memset(text3, NULL, sizeof (char) * length + 1);

 FIfld_get_text(forms.design_form_id, ACT_REV, 0, 0, length, 
                (unsigned char *)text3, &select, &pos);


  if(text1 != NULL && text2 != NULL && text3 != NULL)
       {
	   //status = PDMQueryforMdcExists(text1, text2, text3);
	   status = PDMInfoOnCommandbar(text1, text2, text3);

       } 
		    	
		   

  return(PDM_S_SUCCESS);
  }

int PDUsetup_design_struct()

  {

  _pdm_debug("In the function PDUsetup_design_struct", 0);

  /* set global refresh array for listing fields */

  PDU_form_id = forms.design_form_id;

  if (PDU_design_perm_window)
    PDU_perm_window = TRUE;
  else
    PDU_perm_window = FALSE;

  _pdm_debug("Leaving PDUsetup_design_struct", 0);

  return(PDM_S_SUCCESS);
  }

int PDUcheck_file_for_parts()

  {
  int status;

  _pdm_debug("In the function PDUcheck_file_for_parts", 0);

  /*status = PDUis_active_file_a_part();
  _pdm_status("PDUis_active_file_a_part", status);
  
  if (!status)
    FIg_enable(forms.design_form_id, PLACE_PART);*/

  status = PDUdo_parts_exist(0, 2);

  if (status == TRUE)
    {
    _pdm_debug("Part Pointers Exist ", 0);
    FIg_enable(forms.design_form_id, REPLACE_PART);
    FIg_enable(forms.design_form_id, COPY_PART);
    FIg_enable(forms.design_form_id, DELETE_PART);
    FIg_enable(forms.design_form_id, HIGHLIGHT_PART);
   }
  else
    {
    _pdm_debug("Part Pointers Do Not Exist ", 0);
    FIg_disable(forms.design_form_id, REPLACE_PART);
    FIg_disable(forms.design_form_id, COPY_PART);
    FIg_disable(forms.design_form_id, DELETE_PART);
    FIg_disable(forms.design_form_id, HIGHLIGHT_PART);
   }

  status = PDUdo_positionless_parts_exist();
  _pdm_status("PDUdo_positionless_parts_exisit", status);
  if (status == TRUE)
    FIg_enable(forms.design_form_id, POSITION_PARTS);
  else
    FIg_disable(forms.design_form_id, POSITION_PARTS);

  return(PDM_S_SUCCESS);
}

int PDUcheck_file_for_origins()

  {
  int status;

  status = PDUdo_origins_exist(0, 2);

  if (status == TRUE)
    {
    _pdm_debug("Origins Exist", 0);
    FIg_enable(forms.design_form_id, DELETE_ORIGIN);
    }
  else
    {
    _pdm_debug("Origins Don't Exist", 0);
    FIg_disable(forms.design_form_id, DELETE_ORIGIN);
    }
  return(PDM_S_SUCCESS);
  }

int PDUdisplay_design_form()

  {
  int  display;
  char form_name[256];

  _pdm_debug("In PDUdisplay_design_form",0);

  // TR5691, system crashed because we lost the form pointer, get it back
  FI_get_form_by_name("Part_id", &forms.design_form_id);

  
  if (forms.seed_form_form_id)
    {
    FIf_is_displayed(forms.seed_form_form_id, &display);
    if (display)
      {
      _pdm_debug("restoring refresh active information", 0);
      PDUfill_in_string(&refresh->act_catalog, PDU_save_act_catalog);
      PDUfill_in_string(&refresh->act_partid, PDU_save_act_partid);
      PDUfill_in_string(&refresh->act_revision, PDU_save_act_revision);
      PDUfill_in_string(&refresh->act_filename, PDU_save_act_filename);
      PDUfill_in_string(&refresh->act_description, PDU_save_act_description);
      FIf_erase(forms.seed_form_form_id);
      FIf_delete(forms.seed_form_form_id);
      /* TR# 139418100.	24/may/94 - raj.	*/
      forms.seed_form_form_id = 0;

      }
    }

  PDUsetup_design_struct();
  PDUcheck_file_for_origins();
  PDUcheck_file_for_parts();
  PDUcheck_if_file_an_assembly();
  /* TLS: Added per ISDP ( Ad ) request 10/24/00 */
  PDU_FIf_display(forms.design_form_id);

  return(PDM_S_SUCCESS);
  }

int PDUcheck_if_file_an_assembly()

  {
  MEMptr assy_bufr = NULL;

  _pdm_debug("In the function PDUcheck_if_file_an_assembly", 0);

/* MJG - 10/4/95 - If a part has just been placed or replaced, we know that
   the active design file is an assembly */
  if ((PDU_command == PDC_M_PLACE_PART) || (PDU_command == PDC_M_REPLACE_PART))
    {
    _pdm_debug("Part IS an assembly ", 0);
    FIg_enable(forms.design_form_id, MANAGE_DISPLAY);
    return(PDM_S_SUCCESS);
    }
  PDUload_assy_struct_buffer(NULL, &assy_bufr, -1, NULL);
  if (assy_bufr == NULL)
    {
    _pdm_debug("Part is not an assembly ", 0);
    FIg_disable(forms.design_form_id, MANAGE_DISPLAY);
    }
  else if ((assy_bufr->rows == 0) || (assy_bufr->rows == 1))
    {
    _pdm_debug("Part is not an assembly ", 0);
    FIg_disable(forms.design_form_id, MANAGE_DISPLAY);
    }
  else 
    {
    _pdm_debug("Part is an assembly ", 0);
    FIg_enable(forms.design_form_id, MANAGE_DISPLAY);
    }

  if (assy_bufr)
    MEMclose(&assy_bufr);
  return(PDM_S_SUCCESS);
}

int PDUupdate_active_part_info()

  {

  _pdm_debug("PDUupdate_active_part_info", 0);
  if (!forms.design_form_id)
    return(PDM_S_SUCCESS);

  _pdm_debug("Update active part information on design form", 0);
  if ((refresh->act_catalog) && (strcmp(refresh->act_catalog, "") != 0))
    {
    FIg_set_text(forms.design_form_id, ACT_CATALOG, refresh->act_catalog);
    FIg_enable(forms.design_form_id, DEFINE_ORIGIN);
    FIg_enable(forms.design_form_id, PLACE_PART);
    FIg_enable(forms.design_form_id, TOP_DOWN);
    }
  else
    {
    FIg_set_text(forms.design_form_id, ACT_CATALOG, "");
    FIg_disable(forms.design_form_id, DEFINE_ORIGIN);
    FIg_disable(forms.design_form_id, PLACE_PART);
    FIg_disable(forms.design_form_id, TOP_DOWN);
    }
  if ((refresh->act_partid) && (strcmp(refresh->act_partid, "") != 0))
    FIg_set_text(forms.design_form_id, ACT_PART, refresh->act_partid);
  else
    FIg_set_text(forms.design_form_id, ACT_PART, "");
  if ((refresh->act_revision) && (strcmp(refresh->act_revision, "") != 0))
    FIg_set_text(forms.design_form_id, ACT_REV, refresh->act_revision);
  else
    FIg_set_text(forms.design_form_id, ACT_REV, "");
  if ((refresh->act_filename) && (strcmp(refresh->act_filename, "") != 0))
    FIg_set_text(forms.design_form_id, ACT_FILE, refresh->act_filename);
  else
    FIg_set_text(forms.design_form_id, ACT_FILE, "");

  return(PDM_S_SUCCESS);
  }

