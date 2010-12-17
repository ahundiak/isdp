#include <stdio.h>
#include <math.h>
#include "FI.h"
#include "MRPmacros.h"
#include "MRPstr.h"
#include "rMRPstr.h"
#include "MRPgadlabs.h"
#include "PSUgadlabs.h"
#include "MRPintdef.h"
#include "MRPmessage.h"
#include <tools.h>



/* Static and Global variables */

Form attrl_form_id;

char *ATTR_value;
int attrl_form_created;
int attrl_form_displayed;

static int  PAST_end_flag = FALSE;
static int  BEFORE_start_flag = FALSE;
static int Min_scroll_value = 0;


/* Externs */
extern char *PSUtemplib;
extern int RPT_list_position;
extern int current_form_num;
extern int ps_current_form_num;
extern char **string_buffer;
extern int MRPsingle_select;
extern int PSU_attr_total;
extern int MRPGet_form_text();
extern int MRP_current_g_label;
extern Form del_form_id;
extern Form ps_current_form_id;
extern Form psu_format_id;
extern Form psu_master_id;
extern struct MRPvar *mrpvar;
extern struct PSUattr *psuattr;
extern struct PSUrpt *PDU_pdurpt;
extern Form current_form_id;
extern struct MRPtransattr *tmp_transattr;
extern int MRPlist_flag;
extern struct MRPtransattr *MRPtemp_atlst;
extern int MRPtemp_atotal;

/****************************************************************************

Document:	attrl_notify_routine

Description:	Reacts when the command buttons are pushed to initiate the
		required functions for the specific command.

Algorithm:

Return Status:

History:	10/1/90	Lynn Mettlen    Created

*****************************************************************************/

void attrl_notify_routine ( f_label, g_label, value, fp )
int     f_label;       /* The label of the form   */
int     g_label;       /* The label of the gadget */
double  value;         /* The value of the gadget */
Form    fp;            /* Pointer to the form     */
{
  int	min_value, max_value;	
  int	cnt;
  int   status1;

  switch ( g_label )
  {
    case FI_CANCEL:     /* Member of group  Accept-Cancel */
	 _pdm_debug("current_form_num = %d", current_form_num);
	 PSUfree_list ( string_buffer, PSU_attr_total, 1 );
            _pdm_debug("after MRPfree_list string_buffer",0);
	 free( string_buffer );
         string_buffer = NULL;
         if ( current_form_num == psu_format_form)
            {
            _pdm_debug("setting format text",0);
	    FIg_set_value ( psu_format_id, PSU_ATTR_BUTTON, 0 );
	    FIg_display ( psu_format_id, PSU_ATTR_BUTTON );
            }
         ps_current_form_id = NULL;
	 ps_current_form_num = 0;

          /* Erase the displayed form */
         FIf_erase ( fp );
         break;

    case FI_ACCEPT:     /* Member of group  Accept-Cancel group */
          /* Process form data */
          /**** Process form data ****/
	  /* Set proper settings for specific attribute for flags, value,
	      active attr, width */
	  MRPstrcpy( &mrpvar->attr, psuattr[mrpvar->list_position].syn );
	  _pdm_debug("mrpvar->attr = %s", mrpvar->attr);
	  MRPstrcpy( &mrpvar->attr, psuattr[mrpvar->list_position].syn );
	  _pdm_debug("mrpvar->attr = %s", mrpvar->attr);
	  mrpvar->width = psuattr[mrpvar->list_position].width;
	  _pdm_debug("mrpvar->width = %d", mrpvar->width);
	  _pdm_debug("min_value = %d", mrpvar->list_position);


	 /* Clean check list text strings */
	 _pdm_debug("current_form_num = %d", current_form_num);
	 _pdm_debug("PSU_attr_total = %d", PSU_attr_total);
	 if (( string_buffer != NULL ) && (PSU_attr_total))
	    {
	    PSUfree_list ( string_buffer, PSU_attr_total, 1 );
            _pdm_debug("after MRPfree_list string_buffer",0);
	    free( string_buffer );
            string_buffer = NULL;
	    }
         if ( current_form_num == psu_format_form)
            {
            _pdm_debug("setting format text",0);
	    if ( mrpvar->attr != NULL )
	      {
	      FIfld_set_text(psu_format_id, PSU_ATTR_FIELD, 0, 0, mrpvar->attr, FALSE);
	      FIfld_set_text(psu_format_id, PSU_HEADER_FIELD, 0, 0, mrpvar->attr, FALSE);
	      }
	    FIg_set_value ( psu_format_id, PSU_ATTR_BUTTON, 0 );
	    FIg_display ( psu_format_id, PSU_ATTR_BUTTON );
	    FIg_set_value(psu_format_id, PSU_WIDTH_SLIDER, (double)mrpvar->width);
	    FIfld_set_value(psu_format_id, PSU_WIDTH_FIELD, 0, 0, (double)mrpvar->width, TRUE);
            if (strcmp(psuattr[mrpvar->list_position].datatype, "real") != 0)
              FIg_disable(psu_format_id, PSU_FORMAT_FIELD);
            else
              FIg_enable(psu_format_id, PSU_FORMAT_FIELD);
            }
	    status1 = MRPmatch_attr_rpt_row (PSU_attr_total);
            if (PDU_pdurpt->list == NULL)
		{
		_pdm_debug("MALLOC PDU_pdurpt->list",0);
		PDU_pdurpt->list_total = 1;
		mrpvar->list_position = 0;
		PDU_pdurpt->list = (struct dba_default_list *) malloc (sizeof(struct dba_default_list) );
	        PDU_pdurpt->justification = (int *) malloc (sizeof(int) );
	        PDU_pdurpt->justification[mrpvar->list_position] = 1;
		strcpy(PDU_pdurpt->list[mrpvar->list_position].name, "");
		strcpy(PDU_pdurpt->list[mrpvar->list_position].header, "");
		PDU_pdurpt->list[mrpvar->list_position].type = DBA_COLUMN;
		PDU_pdurpt->list[mrpvar->list_position].start = 0;
		PDU_pdurpt->list[mrpvar->list_position].length = 0;
		PDU_pdurpt->list[mrpvar->list_position].decimal = 1;
		PDU_pdurpt->list[mrpvar->list_position].sort = 0;
		PDU_pdurpt->list[mrpvar->list_position].subtotal = 0;
		PDU_pdurpt->list[mrpvar->list_position].total = 0;
		}
	    else
		{
		mrpvar->list_position = 0;
                status1 = MRPmatch_attr_row ( PDU_pdurpt->list_total );
	        if (mrpvar->list_position == 0)
		    {
		    _pdm_debug("REALLOC PDU_pdurpt->list",0);
		    mrpvar->list_position = PDU_pdurpt->list_total;
		    ++PDU_pdurpt->list_total;
		    PDU_pdurpt->list = (struct dba_default_list *) realloc (PDU_pdurpt->list,  (PDU_pdurpt->list_total *sizeof(struct dba_default_list) ));
		    PDU_pdurpt->justification = (int *) realloc (PDU_pdurpt->justification, (PDU_pdurpt->list_total * sizeof(int)) );
		    PDU_pdurpt->justification[mrpvar->list_position] = 1;
		    strcpy(PDU_pdurpt->list[mrpvar->list_position].name, "");
		    strcpy(PDU_pdurpt->list[mrpvar->list_position].header, "");
		    PDU_pdurpt->list[mrpvar->list_position].type = DBA_COLUMN;
		    PDU_pdurpt->list[mrpvar->list_position].start = 0;
		    PDU_pdurpt->list[mrpvar->list_position].length = 0;
		    PDU_pdurpt->list[mrpvar->list_position].decimal = 1;
		    PDU_pdurpt->list[mrpvar->list_position].sort = 0;
		    PDU_pdurpt->list[mrpvar->list_position].subtotal = 0;
		    PDU_pdurpt->list[mrpvar->list_position].total = 0;
		    }
                 }
	    strcpy( PDU_pdurpt->list[mrpvar->list_position].name, psuattr[RPT_list_position].name );
	    strcpy( PDU_pdurpt->list[mrpvar->list_position].header, mrpvar->attr );
	    PDU_pdurpt->list[mrpvar->list_position].length = psuattr[RPT_list_position].width;
         ps_current_form_id = NULL;
	 ps_current_form_num = 0;

          /* Erase the displayed form */
         FIf_erase ( fp );
         break;

    case SCROLL1:
	 MRPinterpret_message ( MRP_I_CleanStatus, NULL, NULL, NULL );
	 _pdm_debug ("SCROLL1 value is %f", value);
	 _pdm_debug ("SCROLL1 value is %d", (int)value);
	 _pdm_debug ("BEFORE_start_flag value is %d", BEFORE_start_flag);
	 _pdm_debug ("PAST_end_flag value is %d", PAST_end_flag);
	 if ((!BEFORE_start_flag) || ((int)value != 0))
	 if ((!PAST_end_flag) || (((int)value+ MRP_LIST_INCREMENT) < PSU_attr_total))
           {
	   if (((int)value >= 0) && (((int)value ) <= PSU_attr_total))
	      {
		if (((int)value + MRP_LIST_INCREMENT) > PSU_attr_total)
		   {
			max_value = PSU_attr_total;
	   		min_value = max_value - MRP_LIST_INCREMENT;
			if (min_value < 0)
			   {
			    min_value = 0;
			    max_value = MRP_LIST_INCREMENT;
			   }
	 _pdm_debug("cond1 min_value = %d", min_value);
			/* Place last set of 6 Check Boxes in the attr list */
	   		do_check ( 60, 75, 18, attrl_form_id, PSU_attr_total, min_value, max_value, ATTR1, MRPsingle_select, string_buffer );
	 _pdm_debug("before for cond1 min_value = %d", min_value);
			/* Check flags so only check boxes whose corresponding
			   attributes have been chosen are check marked */
			for (cnt = min_value; cnt <= max_value; ++cnt)
			    if (psuattr[cnt].flag == 1)
			       {
				_pdm_debug("psuattr[cnt].flag = %d", psuattr[cnt].flag);
				FIg_set_state_on( fp, (ATTR1+(cnt - min_value)));
				}
		   }
		else
		   {
	   		min_value = ((int)value);
	   		max_value = min_value + MRP_LIST_INCREMENT;
	 _pdm_debug("cond2 min_value = %d", min_value);
			/* Place next set of  6 Check Boxes from the attr list */
	   		do_check ( 60, 75, 18, attrl_form_id, PSU_attr_total, min_value, max_value, ATTR1, MRPsingle_select, string_buffer );
	 _pdm_debug("cond2 min_value = %d", min_value);
			/* Check flags so only check boxes whose corresponding
			   attributes have been chosen are check marked */
			for (cnt = min_value; cnt <= max_value; ++cnt)
			    if (psuattr[cnt].flag == 1)
			       {
				_pdm_debug("psuattr[cnt].flag = %d", psuattr[cnt].flag);
				FIg_set_state_on( fp, (ATTR1+(cnt - min_value)));
				}
		   }
               Min_scroll_value = min_value;
 	       if (((int)value + MRP_LIST_INCREMENT) >= PSU_attr_total) PAST_end_flag = TRUE;
 		else PAST_end_flag = FALSE;
		_pdm_debug ("PAST_end_flag = %d", PAST_end_flag);

 	       if ((int)value == 0) BEFORE_start_flag = TRUE;
		else BEFORE_start_flag = FALSE;
		_pdm_debug ("BEFORE_start_flag = %d", BEFORE_start_flag);
	      }
	    }
	 else
	   MRPinterpret_message ( MRP_I_AT_EndOfList, NULL, NULL, NULL );
	 else
	   MRPinterpret_message ( MRP_I_AT_BeginOfList, NULL, NULL, NULL );
         break;

    case ATTR1:
	  /* Set list_position to current position in attr_list */
	  mrpvar->list_position = Min_scroll_value;

	  /* Set flag to 1 to show selected, if previously selected
	     Set flag to 0 showing unselected */
	  _pdm_debug("BEFORE SET psuattr[mrpvar->list_position].flag = %d",psuattr[mrpvar->list_position].flag);
	  if ( psuattr[mrpvar->list_position].flag == 0)
	     psuattr[mrpvar->list_position].flag = 1;
	  else	  psuattr[mrpvar->list_position].flag = 0;
	  _pdm_debug("AFTER SET psuattr[mrpvar->list_position].flag = %d",psuattr[mrpvar->list_position].flag);
         break;

    case ATTR2:     
	  /* Extract check box text to assign to current attribute (synonym) */
	  /* Set list_position to current position in attr_list */
	  mrpvar->list_position = Min_scroll_value+1;

	  /* Set flag to 1 to show selected, if previously selected
	     Set flag to 0 showing unselected */
	  _pdm_debug("BEFORE SET psuattr[mrpvar->list_position].flag = %d",psuattr[mrpvar->list_position].flag);
	  if ( psuattr[mrpvar->list_position].flag == 0)
	     psuattr[mrpvar->list_position].flag = 1;
	  else	  psuattr[mrpvar->list_position].flag = 0;
	  _pdm_debug("AFTER SET psuattr[mrpvar->list_position].flag = %d",psuattr[mrpvar->list_position].flag);
         break;

    case ATTR3:     
	  /* Extract check box text to assign to current attribute (synonym) */
	  /* Set list_position to current position in attr_list */
	  mrpvar->list_position = Min_scroll_value+2;

	  /* Set flag to 1 to show selected, if previously selected
	     Set flag to 0 showing unselected */
	  _pdm_debug("psuattr[mrpvar->list_position].flag = %d",psuattr[mrpvar->list_position].flag);
	  if ( psuattr[mrpvar->list_position].flag == 0)
	     psuattr[mrpvar->list_position].flag = 1;
	  else	  psuattr[mrpvar->list_position].flag = 0;
         break;

    case ATTR4:     
	  /* Extract check box text to assign to current attribute (synonym) */
	  /* Set list_position to current position in attr_list */
	  mrpvar->list_position = Min_scroll_value+3;

	  /* Set flag to 1 to show selected, if previously selected
	     Set flag to 0 showing unselected */
	  _pdm_debug("psuattr[mrpvar->list_position].flag = %d",psuattr[mrpvar->list_position].flag);
	  if ( psuattr[mrpvar->list_position].flag == 0)
	     psuattr[mrpvar->list_position].flag = 1;
	  else	  psuattr[mrpvar->list_position].flag = 0;
         break;

    case ATTR5:     
	  /* Extract check box text to assign to current attribute (synonym) */
	  /* Set list_position to current position in attr_list */
	  mrpvar->list_position = Min_scroll_value+4;

	  /* Set flag to 1 to show selected, if previously selected
	     Set flag to 0 showing unselected */
	  _pdm_debug("psuattr[mrpvar->list_position].flag = %d",psuattr[mrpvar->list_position].flag);
	  if ( psuattr[mrpvar->list_position].flag == 0)
	     psuattr[mrpvar->list_position].flag = 1;
	  else	  psuattr[mrpvar->list_position].flag = 0;
         break;

    case ATTR6:
	  /* Extract check box text to assign to current attribute (synonym) */
	  /* Set list_position to current position in attr_list */
	  mrpvar->list_position = Min_scroll_value+5;

	  /* Set flag to 1 to show selected, if previously selected
	     Set flag to 0 showing unselected */
	  _pdm_debug("psuattr[mrpvar->list_position].flag = %d",psuattr[mrpvar->list_position].flag);
	  if ( psuattr[mrpvar->list_position].flag == 0)
	     psuattr[mrpvar->list_position].flag = 1;
	  else	  psuattr[mrpvar->list_position].flag = 0;
         break;
  } /* END switch ( g_label ) */

} /* END notification_routine() */


/*************************************************************************

Document:	function MRPattrl_load_cre_init_dp()

Description:	This function loads/creates, initializes, and displays the
		prt_selection form.

History:	10/1/90	Lynn Mettlen    Created

***************************************************************************/

int  PSUattrl_load_cre_init_dp()
{
int sts;
int i, k;      /** counters **/

_pdm_debug("PSUattrl_load_cre_init_db",0);
sts = FIf_new ( psu_attrl_form, "psu_attr_list", attrl_notify_routine, 
		&attrl_form_id);

/*** Create a check group gadget  ***/
sts = FIg_new( attrl_form_id, FI_GROUP, CHECK_GROUP);


/**** Place Form Titles ****/
/* commented out JP */
/*if (catlst == 2)
  MRPdyn_text ( 70, 50, 18, attrl_form_id, "BOM  Attributes", ATTR_TEXT, FI_BLACK);
else
  MRPdyn_text ( 70, 50, 18, attrl_form_id, "Catalog  Attributes", ATTR_TEXT, FI_BLACK);*/

_pdm_debug("PSU_attr_total = %d", PSU_attr_total);

for (k = 0; k < PSU_attr_total; ++k)
      psuattr[k].flag = 0;
_pdm_debug("PSU_attr_total = %d", PSU_attr_total);

if ( PSU_attr_total != 0 )
  {
  /*** Malloc for gadget text strings ***/
  if ( string_buffer == NULL )
           {
           string_buffer = (char **) malloc( PSU_attr_total * sizeof(char *) );
           memset(string_buffer, NULL, PSU_attr_total * sizeof(char *)); 
           }

  /*** Copy synonym attr names into gadget text strings ***/
  for (i = 0; i < PSU_attr_total; ++i)
       {
         MRPstrcpy2(&(string_buffer[i]), psuattr[i].syn);
   	 _pdm_debug("string_buffer[i] = %s", string_buffer[i]);
       }

  /*** Place dynamic check boxes on attribute list form ***/
  do_check ( 60, 75, 18, attrl_form_id, PSU_attr_total, 0, MRP_LIST_INCREMENT, ATTR1, MRPsingle_select, string_buffer );

  Min_scroll_value = 0;
  PAST_end_flag = FALSE;
  BEFORE_start_flag = FALSE;

  /*** If more check box gadgets than 1 page, place scroll bar ***/
  if (PSU_attr_total > MRP_LIST_INCREMENT)
    {
    _pdm_debug("DO SCROLL PSU_attr_total = %d", PSU_attr_total);
    if ( MRPsingle_select == 2 )
       do_scroll ( 347, 75, 367, 240, attrl_form_id, (((float)MRP_LIST_INCREMENT)/((float)(PSU_attr_total-1))), 0.0, 0.0, ((float)(PSU_attr_total-MRP_LIST_INCREMENT)), attrl_notify_routine);
    else
       do_scroll ( 347, 75, 367, 240, attrl_form_id, (((float)MRP_LIST_INCREMENT)/((float)(PSU_attr_total-1))), 0.0, 0.0, ((float)(PSU_attr_total-MRP_LIST_INCREMENT)), attrl_notify_routine);
    }

  attrl_form_created = TRUE;
  ps_current_form_id = attrl_form_id;
  ps_current_form_num = psu_attrl_form;

  /**** Display the prt_selection form and set the flag ****/
  sts = FIf_display ( attrl_form_id );
  }
return( MRP_S_Success );
}

