#include <string.h>
#include "FI.h"
#include <tools.h>
#include "MRPstr.h"
#include "rMRPstr.h"
#include "MRPmacros.h"
#include "MRPgadlabs.h"
#include "PSUgadlabs.h"
#include "MRPmessage.h"
#include "PDUfile_def.h"
#include "PDUforms.h"
#include "PDUstr.h"
#include "PDUerror.h"
#include "PDUproto.h"
#include "MRPintdef.h"


#define FORMT_STRT_ACT_POS 15
#define FORMT_STRT_LABEL 11

#define PDM_M_DEFINE 30

/* Static and Global variables */

extern struct PDUforms forms;
extern Form psu_format_id;

extern int psu_format_created;
extern int psu_format_displayed;
extern int rpt_value_pulldown;
static int PSUmode;
static int position;
extern struct PSUattr *psuattr;
extern char **rpt_value_list;
extern int  sort_total;
extern int  subtotal;
extern int  total;
extern int  PSU_list_size;


/* Externs */
extern int PSU_list_total;
extern int RPT_list_position;
extern struct PSUrpt *PDU_pdurpt;
extern int  PSU_attr_total;
extern long PSUcommand;
extern int MRPscroll_col;
extern int current_form_num;
extern int ps_current_form_num;
extern char * calloc();
extern char * realloc();
extern int MRPGet_form_text();
extern int MRPtcode_load_cre_init_dp();
extern int MRPdelete_form();
extern int MRPsingle_select;
extern int file_total;
extern int PSUjustification;
extern Form current_form_id;
extern Form ps_current_form_id;
extern Form attrl_form_id;
extern struct MRPvar *mrpvar;
extern struct rMRPvar *rmrpvar;
extern char *PSUtemplib;

/****************************************************************************

Document:	MRPdelete_form	

Description:	Checks if the given form pointer exists, if yes, the function
		deletes the form and sets the form pointer to null.

Algorithm:

Return Status:	FI_SUCCESS

History:	10/1/90	Lynn Mettlen    Created

*****************************************************************************/

int MRPdelete_form (cur_form_id)
       Form    cur_form_id;            /* Pointer to the form     */
{
int sts=MRP_S_Success;

  _pdm_debug("MRPdelete_form",0);
  if (cur_form_id != NULL)
     {
     _pdm_debug("form deleted",0);
     sts = FIf_delete ( cur_form_id );
     }
  else
     _pdm_debug("form NULL",0);

  return( sts );
}

/****************************************************************************

Document:	MRPGet_form_text

Description:	Returns the text from a text field.

Algorithm:

Return Status:  FI_SUCCESS
		FI_NO_SUCH_GADGET
		FI_INVALID_GADGET_TYPE
		FI_INVALID_ROW
		FI_INVALID_COL

History:
	10/1/90	Lynn Mettlen    Created

*****************************************************************************/

int MRPGet_form_text ( fp, g_label, text, text_size )
       Form    fp;            /* Pointer to the form     */
       int     g_label;       /* The label of the gadget */
       char ** text;          /* The text contained in the field */
       int   * text_size;     /* The space allocated for the text */
{
    int status;
    int text_len;
    int field_type;
    int select_flag;
    int row = 0;
    int col = 0;
    int pos = 0;

    FIg_get_type ( fp, g_label, &field_type );

    if ( field_type == FI_MULTI_COL )
    {
        /* Get the col for the MCF */

        FImcf_get_active_col ( fp, g_label, &col, &pos );

    }

    /* Get the row for the field or MCF */

    FIfld_get_active_row ( fp, g_label, &row, &pos );
    FIfld_get_text_length ( fp, g_label, row, col, &text_len );

    /* Increment text_len because of NULL */

    text_len++;

    if ( * text_size < text_len )
    {
        if ( * text_size > 0 )
        {
           /* Realloc space for larger string */
           * text = realloc ( * text, text_len );
	   _pdm_debug("REALLOC text",0);
        }
        else
        {
           /* Malloc space for string */
           * text = (char *) malloc ( text_len * sizeof (char));
	   _pdm_debug("MALLOC text",0);
        }
        * text_size = text_len;
    }

    if ( ! * text )
    {
      * text_size = 0;
      _pdm_debug("COULD NOT MALLOC text",0);
      return ( FI_NO_MEMORY );
    }

    status = FIfld_get_text ( fp, g_label, row, col, * text_size,
                            (unsigned char*)* text, &select_flag, &pos );
    return ( status );
}

pformat_notify_routine ( f_label, g_label, value, fp )
int     f_label;       /* The label of the form   */
int     g_label;       /* The label of the gadget */
double  value;         /* The value of the gadget */
Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  static int      text_size = 0;
  char	*textg=NULL, *temp=NULL;
  char  *s = NULL;
  long  status = MRP_S_Success;
  int   status1;
  int	i, textg_len = 0;
  int   temp_pos;
  int   x_pos, y_pos, x_hi_pos, x_posr, y_posr;
  int   frmt_inc;
  int   gad_lab;
  char  txt[45];
  int   list_row;
  int   state;
  int   temp_width;
  char  *tmp_attr = NULL;
  char  *msg = NULL;

  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  _pdm_debug("tformat_notify_routine",0);
  _pdm_debug("f_label = <%d>",(char *)f_label);
  if ( ( g_label > 1211) && ( g_label < 1411 ) )
        {
	if ( mrpvar-> attr != NULL )
	 {
	 MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );
	  _pdm_debug("before get location",0);
	  FIg_get_location ( fp, g_label, &x_pos, &y_pos );
	  _pdm_debug("after get location x_pos = %d",(char *)x_pos);
	  frmt_inc = MRPscroll_col * 100;
	  position = (((x_pos -15)/8 + 1)+frmt_inc);
	  _pdm_debug("after get location position = %d", (char *)position);
          switch ( PSUmode )
	  {
	  case PSU_INSERT_MODE:
	       _pdm_debug("INSERT MODE",0);
               if ((position + PDU_pdurpt->list[mrpvar->list_position].length) > 
                    PDU_pdurpt->options.width)
                 {
                 msg = (char *)PDUtranslate_message(PDM_E_ATTR_PLACE_TOO_LONG);
                 FIg_set_text(fp, FI_MSG_FIELD, msg);
                 PDUmessage(PDM_E_ATTR_PLACE_TOO_LONG, 's');
                 break;
                 }
	       MRPcheck_position(g_label, &y_pos, fp, PDU_pdurpt->list_total);
	       x_hi_pos = x_pos + ((PDU_pdurpt->list[mrpvar->list_position].length-1) * 8) + 5;
	       _pdm_debug("x_hi_pos = %d", (char *)x_hi_pos);
               MRPGet_form_text ( fp, PSU_ATTR_FIELD, & text, & text_size );
               if (text == NULL)
                 break;
               else if (strcmp(text, "") == 0)
                 break;
               MRPGet_form_text ( fp, PSU_HEADER_FIELD, & text, & text_size );
               if (text == NULL)
                 break;
               else if (strcmp(text, "") == 0)
                 break;
               if (( y_pos == 148 ) || ( y_pos == 103) )
                 {
		  if (y_pos == 103)
	            sprintf(txt, "%s\n\n\n\nv", text);
	          else
	            sprintf(txt, "%s\nv", text);
	            MRPdyn_text ( x_pos, y_pos, 15, psu_format_id, txt,
		     INSERT_TEXT+mrpvar->list_position + frmt_inc, FI_DK_RED );
	            MRPdyn_rect ( x_pos-3, 180, x_hi_pos, 195, psu_format_id,
		     INSERT_RECT+mrpvar->list_position + frmt_inc, FI_DK_RED );
		 }
               else if (( y_pos == 133 ) || ( y_pos == 88) )
                 {
		  if (y_pos == 88)
	            sprintf(txt, "%s\n\n\n\n\nv", text);
		  else
	            sprintf(txt, "%s\n\nv", text);
	          MRPdyn_text ( x_pos, y_pos, 15, psu_format_id, txt,
		    INSERT_TEXT+mrpvar->list_position +frmt_inc, FI_WHITE );
	          MRPdyn_rect ( x_pos-3, 180, x_hi_pos, 195, psu_format_id, INSERT_RECT+mrpvar->list_position + frmt_inc, FI_WHITE );
                 }
               else
		 {
		  if (y_pos == 73)
	            sprintf(txt, "%s\n\n\n\n\n\nv", text);
		  else
	            sprintf(txt, "%s\n\n\nv", text);
	          MRPdyn_text ( x_pos, y_pos, 15, psu_format_id, txt, INSERT_TEXT+mrpvar->list_position + frmt_inc, FI_DK_BLUE );
	          MRPdyn_rect ( x_pos-3, 180, x_hi_pos, 195, psu_format_id, INSERT_RECT+mrpvar->list_position + frmt_inc, FI_DK_BLUE );
		 }

        _pdm_debug("mrpvar->list_position = %d", (char *)mrpvar->list_position);
	       PDU_pdurpt->list[mrpvar->list_position].start = position;
	  _pdm_debug("PDU_pdurpt->list[mrpvar->list_position].start = %d",
                     (char *)PDU_pdurpt->list[mrpvar->list_position].start);
	  _pdm_debug("mrpvar->width = %d", (char *)mrpvar->width);
	       PDU_pdurpt->list[mrpvar->list_position].length = mrpvar->width;
	  _pdm_debug("PDU_pdurpt->list[mrpvar->list_position].length = %d", 
                     (char *)PDU_pdurpt->list[mrpvar->list_position].length);
           FIg_set_text(fp, PSU_ATTR_FIELD, "");
           FIg_set_text(fp, PSU_HEADER_FIELD, "");
           PSUdelete_attr_from_pulldown();
	  break;

	  case PSU_DELETE_MODE:
	  break;

	  case PSU_MODIFY_MODE:
	  break;
          }
	 }
	 else
	  MRPinterpret_message( MRP_I_NoAttrMatch, NULL, NULL, NULL );
         }
  else if ( ( g_label > 399 ) && ( g_label < 800) )
        {
	 MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );
	  _pdm_debug("before get location",0);
	  FIg_get_location ( fp, g_label, &x_pos, &y_pos );
	  _pdm_debug("after get location x_pos = %d", (char *)x_pos);
	  frmt_inc = MRPscroll_col * 100;
	  position = (((x_pos -15)/8 + 1)+frmt_inc);
	  _pdm_debug("after get location position = %d", (char *)position);
          switch ( PSUmode )
	  {
	  case PSU_INSERT_MODE:
	  break;

	  case PSU_DELETE_MODE:
	    status = FIg_get_text_length( psu_format_id, g_label, &textg_len );
	    _pdm_debug("status = %d", (char *)status);
            if ( textg_len > 0 )
              {
	      textg = (char *) malloc ( textg_len + 1);
	      FIg_get_text( psu_format_id, g_label, textg );
	      _pdm_debug("textg = %s", textg);
	      s = strtok(textg, "\n");
	    /* parse text for synonymn name */
/*	    for ( s = strtok(textg, "v"), j = 0;
		  s != NULL && j < 2;
		  s = strtok(0,"v"), ++j )
		{  */
	      _pdm_debug("s = %s", s);
              if (strcmp(s, "Level") == 0)
                {
                msg = (char *)PDUtranslate_message(PDM_E_REPLACE_LEVEL_ATTR);
                FIg_set_text(fp, FI_MSG_FIELD, msg);
                PDUmessage(PDM_E_REPLACE_LEVEL_ATTR, 's');
                break;
                }
	      MRPstrcpy (&mrpvar->attr, s);
/*		} */
	      status = MRPmatch_attr_row( PDU_pdurpt->list_total );
	      if ( status == MRP_S_Success )
		{
	        PDU_pdurpt->list[mrpvar->list_position].start = 0;
		_pdm_debug("list pos = %d", (char *)mrpvar->list_position);
		}
              PSUadd_attr_to_pulldown(TRUE);
	      if (textg != NULL)
		{
	         free(textg);
		 textg = NULL;
                 textg_len = 0;
		}
              }		
	    FIg_delete( fp, g_label );
	    FIg_delete( fp, g_label+400 );
	  break;

	  case PSU_MODIFY_MODE:
               MRPGet_form_text ( fp, PSU_ATTR_FIELD, & text, & text_size );
               if (text == NULL)
                 break;
               else if (strcmp(text, "") == 0)
                 break;
               MRPGet_form_text ( fp, PSU_HEADER_FIELD, & text, & text_size );
               if (text == NULL)
                 break;
               else if (strcmp(text, "") == 0)
                 break;
               if ((position + PDU_pdurpt->list[mrpvar->list_position].length) > 
                    PDU_pdurpt->options.width)
                 {
                 msg = (char *)PDUtranslate_message(PDM_E_ATTR_PLACE_TOO_LONG);
                 FIg_set_text(fp, FI_MSG_FIELD, msg);
                 PDUmessage(PDM_E_ATTR_PLACE_TOO_LONG, 's');
                 break;
                 }
	     _pdm_debug("before get location",0);
	    status = FIg_get_text_length( psu_format_id, g_label, &textg_len );
	    _pdm_debug("status = %d", (char *)status);
            if ( textg_len > 0 )
              {
	      textg = (char *) malloc ( textg_len + 1);
	      FIg_get_text( psu_format_id, g_label, textg );
	      _pdm_debug("textg = %s label = %d", textg, g_label);
	      s = strtok(textg, "\n");
	    /* parse text for synonymn name */
	      _pdm_debug("s = %s", s);
              if (strcmp(s, "Level") == 0)
                {
                msg = (char *)PDUtranslate_message(PDM_E_REPLACE_LEVEL_ATTR);
                FIg_set_text(fp, FI_MSG_FIELD, msg);
                PDUmessage(PDM_E_REPLACE_LEVEL_ATTR, 's');
                break;
                }
	      temp = (char *) malloc ( strlen(mrpvar->attr) + 1);
	      strcpy (temp, mrpvar->attr);
	      temp_pos = mrpvar->list_position;
	      MRPstrcpy (&mrpvar->attr, s);
	      status = MRPmatch_attr_row( PDU_pdurpt->list_total );
	      if ( status == MRP_S_Success )
		{
	        PDU_pdurpt->list[mrpvar->list_position].start = 0;
		_pdm_debug("list pos = %d", (char *)mrpvar->list_position);
		}
              PSUadd_attr_to_pulldown(FALSE);
	      if ( textg != NULL )
		{
	        free(textg);
                textg_len = 0;
		textg = NULL;
		}
	     MRPstrcpy (&mrpvar->attr, temp);
	     mrpvar->list_position = temp_pos;
	     if ( temp != NULL )
		{
	        free(temp);
		temp = NULL;
		}
              }		
             FIg_set_text(fp, PSU_ATTR_FIELD, "");
             FIg_set_text(fp, PSU_HEADER_FIELD, "");
             PSUdelete_attr_from_pulldown();
	     FIg_get_location ( fp, g_label, &x_pos, &y_pos );
	     FIg_get_location ( fp, g_label+400, &x_posr, &y_posr );

         /* ALR  These locations are adjusted by 50 because of an old form.
            Readjust these locations so that the following code will work
            as before. */

             y_pos = y_pos - 50;
             y_posr = y_posr - 50;
             
	     _pdm_debug("after get location y_pos %d",y_pos);
	     frmt_inc = MRPscroll_col * 100;
/*	     y_pos = 135; */
	     position = ((x_pos -15)/8 + 1) + frmt_inc;
/*	     position = (g_label - INSERT_TEXT); */
	     FIg_delete( fp, g_label );
	     FIg_delete( fp, g_label+400 );
	     x_hi_pos = x_pos + ((PDU_pdurpt->list[mrpvar->list_position].length-1) * 8) + 5;
               if (( y_pos == 148 ) || ( y_pos == 103) )
                 {
		  if (y_pos == 103)
	            sprintf(txt, "%s\n\n\n\nv", mrpvar->attr);
		  else
	            sprintf(txt, "%s\nv", mrpvar->attr);
	          MRPdyn_text ( x_pos, y_pos, 15, psu_format_id, txt, INSERT_TEXT+mrpvar->list_position + frmt_inc, FI_DK_RED );
	          MRPdyn_rect ( x_posr, y_posr, x_hi_pos, y_posr+15, psu_format_id, INSERT_RECT+mrpvar->list_position + frmt_inc, FI_DK_RED );
		 }
               else if (( y_pos == 133 ) || ( y_pos == 88) )
                 {
		  if (y_pos == 88)
	            sprintf(txt, "%s\n\n\n\n\nv", mrpvar->attr);
		  else
	            sprintf(txt, "%s\n\nv", mrpvar->attr);
	         MRPdyn_text ( x_pos, y_pos, 15, psu_format_id, txt, INSERT_TEXT+mrpvar->list_position + frmt_inc, FI_WHITE );
	         MRPdyn_rect ( x_posr, y_posr, x_hi_pos, y_posr+15, psu_format_id, INSERT_RECT+mrpvar->list_position + frmt_inc, FI_WHITE );
                 }
               else
		 {
		  if (y_pos == 73)
	            sprintf(txt, "%s\n\n\n\n\n\nv", mrpvar->attr);
		  else
	            sprintf(txt, "%s\n\n\nv", mrpvar->attr);
	          MRPdyn_text ( x_pos, y_pos, 15, psu_format_id, txt, INSERT_TEXT+mrpvar->list_position + frmt_inc, FI_DK_BLUE );
	          MRPdyn_rect ( x_posr, y_posr, x_hi_pos, y_posr+15, psu_format_id, INSERT_RECT+mrpvar->list_position + frmt_inc, FI_DK_BLUE );
		 }
	       PDU_pdurpt->list[mrpvar->list_position].start = position;
	  _pdm_debug("PDU_pdurpt->list[mrpvar->list_position].start = %d",
                     (char *)PDU_pdurpt->list[mrpvar->list_position].start);
	  _pdm_debug("mrpvar->width = %d", (char *)mrpvar->width);
	       PDU_pdurpt->list[mrpvar->list_position].length = mrpvar->width;
	  _pdm_debug("PDU_pdurpt->list[mrpvar->list_position].length = %d", 
                      (char *)PDU_pdurpt->list[mrpvar->list_position].length);
          }
         }
  else
  {		
  switch ( g_label )
  {
    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */
         _pdm_debug("f_label = <%d>", (char *)f_label);
         value = 0.0;

         PDUfree_string_array(&rpt_value_list, PSU_attr_total);

         FIf_erase(fp);
         FIf_delete ( fp );

         /* clear out global variables */
         FIf_display(forms.report_form_id);
         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */

         PDUfree_string_array(&rpt_value_list, PSU_attr_total);

         FIf_delete ( fp );

         /* call function to finish defining report */
         PDUfinish_define_format();

         break;

    case PSU_COL_SCROLL:

	 MRPscroll_col = (int)value;
	 for ( gad_lab = INSERT_TEXT; gad_lab < INSERT_TEXT+400; ++gad_lab )
	    {
	    FIg_delete( fp, gad_lab );
	    FIg_delete( fp, gad_lab+400 );
	    }
         for ( i = 1; i < 101; ++i )
            {
	    FIg_delete ( fp, GAUGE_TX_ROW + (i-1)/10 );
            if ( (i%10) == 0  )
               {
   	       strcpy(txt, "");
	       sprintf(txt, "%d", (i + (MRPscroll_col * 100)));
	       MRPdyn_text ( (13+(i-1)*8), 42, 18, psu_format_id, txt,
		       GAUGE_TX_ROW + (i-1)/10, FI_BLACK);
	       }
	    }
         temp_pos = mrpvar->list_position;
         PDUfill_in_string(&tmp_attr, mrpvar->attr);
	 if ( PDU_pdurpt->list != NULL )
	    status = PSUplace_attr_fmt( PDU_pdurpt->list_total );
         mrpvar->list_position = temp_pos;
	 MRPstrcpy( &mrpvar->attr, tmp_attr );
         break;

    case PSU_ATTR_BUTTON:     /* Data linked to FM_ATTR_FIELD   */
/*         if ( ps_current_form_num != attrl_form )
            {
*/	    MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );
	    /*MRPselect_all = 1;
	    MRPsingle_select = 1;
	    _pdm_debug("PSU Attr Button",0);
	    if (( PSUcommand == PSU_C_LOP_GEN ) ||
	       ( PSUcommand == PSU_C_LOP_PRINT ))
	       PSUattrl_load_cre_init_dp(1);
	    else
	       PSUattrl_load_cre_init_dp(2);*/
/*            }
	 else
	    MRPinterpret_message( MRP_I_AlreadySel, NULL, NULL, NULL );
         break;*/

           /* process GRpulldown list: added JP 3-31 */
           GRproc_pull_down_list(rpt_value_pulldown);
           break;

    case  PSU_ATTR_ASSOC_GAD:

          list_row = value - 1;
          /* Set proper settings for specific attribute for flags, value,
              active attr, width */
          MRPstrcpy( &mrpvar->attr, rpt_value_list[list_row]);
          _pdm_debug("mrpvar->attr = %s", mrpvar->attr);
    
          /* find attribute in psuattr */
          list_row = PSUfind_attr(mrpvar->attr);
          if (list_row == -1)
            break;

          mrpvar->width = psuattr[list_row].width;
          _pdm_debug("mrpvar->width = %d", (char *)mrpvar->width);
          _pdm_debug("min_value = %d", (char *)list_row);

         if ( current_form_num == psu_format_form)
            {
            _pdm_debug("setting format text",0);
            if ( mrpvar->attr != NULL )
              {
              FIfld_set_text(psu_format_id, PSU_ATTR_FIELD, 0, 0, mrpvar->attr,
FALSE);
              FIfld_set_text(psu_format_id, PSU_HEADER_FIELD, 0, 0, mrpvar->attr
, FALSE);
              }
            _pdm_debug("setting slider and width field",0);
            FIg_set_value(psu_format_id, PSU_WIDTH_SLIDER, (double)mrpvar->width
);
            FIfld_set_value(psu_format_id, PSU_WIDTH_FIELD, 0, 0, (double)mrpvar
->width, TRUE);
            if ((strcmp(psuattr[list_row].datatype, "real") == 0) ||
               (strcmp(psuattr[list_row].datatype, "double") == 0))
              FIg_enable(psu_format_id, PSU_FORMAT_FIELD);
            else
              FIg_disable(psu_format_id, PSU_FORMAT_FIELD);
            }
            _pdm_debug("Before MRPmatch_attr_rpt_row",0);
            status1 = MRPmatch_attr_rpt_row (PSU_attr_total);
            if (PDU_pdurpt->list == NULL)
                {
                _pdm_debug("MALLOC PDU_pdurpt->list",0);
                PDU_pdurpt->list_total = 1;
                mrpvar->list_position = 0;
                PDU_pdurpt->list = (struct dba_default_list *) malloc (sizeof(struct
 dba_default_list) );
                PDU_pdurpt->justification = (int *) malloc (sizeof(int) );
                PDU_pdurpt->justification[mrpvar->list_position] = 
                PSUjustification;
                strcpy(PDU_pdurpt->list[mrpvar->list_position].name, "");
                strcpy(PDU_pdurpt->list[mrpvar->list_position].header, "");
                PDU_pdurpt->list[mrpvar->list_position].type = DBA_COLUMN;
                PDU_pdurpt->list[mrpvar->list_position].start = 0;
                PDU_pdurpt->list[mrpvar->list_position].length = 0;
                PDU_pdurpt->list[mrpvar->list_position].decimal = 1;
                PDU_pdurpt->list[mrpvar->list_position].sort = 0;
                PDU_pdurpt->list[mrpvar->list_position].subtotal = subtotal;
                PDU_pdurpt->list[mrpvar->list_position].total = total;
                }
            else
                {
                mrpvar->list_position = 0;
                _pdm_debug("Before MRPmatch_attr_rpt_row",0);
                status1 = MRPmatch_attr_row ( PDU_pdurpt->list_total );
                if (mrpvar->list_position == 0)
                    {
                    _pdm_debug("REALLOC PDU_pdurpt->list",0);
                    mrpvar->list_position = PDU_pdurpt->list_total;
                    ++PDU_pdurpt->list_total;
                    PDU_pdurpt->list = (struct dba_default_list *) realloc (PDU_pdurpt->
list,  (PDU_pdurpt->list_total *sizeof(struct dba_default_list) ));
                    PDU_pdurpt->justification = (int *) realloc (PDU_pdurpt->justification, (PDU_pdurpt->list_total * sizeof(int)) );
                    PDU_pdurpt->justification[mrpvar->list_position] = 
                    PSUjustification;
                    strcpy(PDU_pdurpt->list[mrpvar->list_position].name, "");
                    strcpy(PDU_pdurpt->list[mrpvar->list_position].header, "");
                    PDU_pdurpt->list[mrpvar->list_position].type = DBA_COLUMN;
                    PDU_pdurpt->list[mrpvar->list_position].start = 0;
                    PDU_pdurpt->list[mrpvar->list_position].length = 0;
                    PDU_pdurpt->list[mrpvar->list_position].decimal = 1;
                    PDU_pdurpt->list[mrpvar->list_position].sort = 0;
                    PDU_pdurpt->list[mrpvar->list_position].subtotal = subtotal;
                    PDU_pdurpt->list[mrpvar->list_position].total = total;
                    }
                 }
	    strcpy( PDU_pdurpt->list[mrpvar->list_position].name, psuattr[list_row].name );
            strcpy( PDU_pdurpt->list[mrpvar->list_position].header, mrpvar->attr );
            PDU_pdurpt->list[mrpvar->list_position].length = 
                 psuattr[list_row].width;

          break;

    /*case PSU_FRMTDESC_FIELD: i*/       /* Field Type:    ASCII    */
	 /*MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );*/

          /* Get the text string */

          /*status = MRPGet_form_text ( fp, g_label, & text, & text_size );

          if ( status != FI_SUCCESS )
            {
              return;
            }
	  else
	    {*/
          /* Code to process text string "text" */
	    /*strncpy( PDU_pdurpt->options.description, text, PSU_DESC_MAX );
            }
         break;*/


    case PSU_HEADER_FIELD:        /* Field Type:    ASCII    */
	 MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );

          /* Get the text string */

          status = MRPGet_form_text ( fp, g_label, & text, & text_size );

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */

              break;
            }
	  else
	    {
            if (PDU_pdurpt->list != NULL)
            {
          /* Code to process text string "text" */
	    strncpy( PDU_pdurpt->list[mrpvar->list_position].header, text, PSU_HEADER_MAX );
            }
            }
         break;

    case PSU_SUBTOTAL:         /* Field Type:    ASCII    */
            if (PDU_pdurpt->list != NULL)
            {
            FIg_get_state(fp, PSU_SUBTOTAL, &state);
            if (state == 0)
	      subtotal = 0;
            else
	      subtotal = 1;
            }
         break;

    case PSU_TOTAL:         /* Field Type:    ASCII    */
	 MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );

          FIg_get_state(fp, PSU_TOTAL, &state);
            if (state == 0)
	      total = 0;
            else
	      total = 1;
         break;

    case PSU_CHARS_FIELD:         /* Field Type:    ASCII    */
	 MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );

          /* Get the text string */

          status = MRPGet_form_text ( fp, g_label, & text, & text_size );

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */

              break;
            }
	  else
	    {
          /* Code to process text string "text" */
            temp_width = atoi(text);
            if (temp_width > 500)
              {
              msg = (char *)PDUtranslate_message(PDM_E_REPORT_WIDTH_500);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              PDUmessage(PDM_E_REPORT_WIDTH_500, 's');
              FIg_set_text(fp, g_label, "");
              break;
              }
            else
	      PDU_pdurpt->options.width = temp_width;
            }
         break;

    case PSU_LINES_FIELD:         /* Field Type:    ASCII    */
	 MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );

          /* Get the text string */

          status = MRPGet_form_text ( fp, g_label, & text, & text_size );

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */

              break;
            }
	  else
	    {
          /* Code to process text string "text" */
	    PDU_pdurpt->options.lines = atoi(text);
            }
         break;

    case PSU_TEMPLIB_FIELD:         /* Template Library field    ASCII    */
	 MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );

          /* Get the text string */

          status = MRPGet_form_text ( fp, g_label, & text, & text_size );

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */

              break;
            }
	  else 
	    {
          /* Code to process text string "text" */
	    MRPstrcpy(&PSUtemplib, text);
	    if ( strlen(text) <= PSU_LIB_MAX )
	       MRPstrcpy(&PDU_pdurpt->templib, text);
	    }
         break;

    case PSU_ATTR_FIELD:         /* Field Type:    ASCII    */
	 MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );

          /* Get the text string */

          status = MRPGet_form_text ( fp, g_label, & text, & text_size );

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */

              break;
            }
	  else
	    {
                list_row = PSUfind_attr(text);
                if (list_row == -1)
                  {
                  FIg_set_text(fp, g_label, "");
                  break;
                  }

          /* Code to process text string "text" */
	    MRPstrcpy( &mrpvar->attr, text );
	    if (PDU_pdurpt->list == NULL)
	       {
	       PDU_pdurpt->list_total = 1;
	       mrpvar->list_position = 0;
	       PDU_pdurpt->list = (struct dba_default_list *) malloc (sizeof(struct dba_default_list));
	       PDU_pdurpt->justification = (int *) malloc (sizeof(int) );
	       PDU_pdurpt->justification[mrpvar->list_position] = PSUjustification;
	       strcpy(PDU_pdurpt->list[mrpvar->list_position].name, "");
	       strcpy(PDU_pdurpt->list[mrpvar->list_position].header, "");
	       PDU_pdurpt->list[mrpvar->list_position].type = DBA_COLUMN;
	       PDU_pdurpt->list[mrpvar->list_position].start = 0;
	       PDU_pdurpt->list[mrpvar->list_position].length = 0;
	       PDU_pdurpt->list[mrpvar->list_position].decimal = 1;
	       PDU_pdurpt->list[mrpvar->list_position].sort = 0;
	       PDU_pdurpt->list[mrpvar->list_position].subtotal = subtotal;
	       PDU_pdurpt->list[mrpvar->list_position].total = total;
	       }
	    else
	       {
                /*status = MRPmatch_attr_row ( PDU_pdurpt->list_total ); */
		    mrpvar->list_position = PDU_pdurpt->list_total;
		    ++PDU_pdurpt->list_total;
		    PDU_pdurpt->list = (struct dba_default_list *) realloc (PDU_pdurpt->list,  (PDU_pdurpt->list_total *sizeof(struct dba_default_list) ));
		    PDU_pdurpt->justification = (int *) realloc (PDU_pdurpt->justification, (PDU_pdurpt->list_total * sizeof(int)) );
		PDU_pdurpt->justification[mrpvar->list_position] = PSUjustification;
		strcpy(PDU_pdurpt->list[mrpvar->list_position].name, "");
		    strcpy(PDU_pdurpt->list[mrpvar->list_position].header, "");
		    PDU_pdurpt->list[mrpvar->list_position].type = DBA_COLUMN;
		    PDU_pdurpt->list[mrpvar->list_position].start = 0;
		    PDU_pdurpt->list[mrpvar->list_position].length = 0;
		    PDU_pdurpt->list[mrpvar->list_position].decimal = 1;
		    PDU_pdurpt->list[mrpvar->list_position].sort = 0;
		    PDU_pdurpt->list[mrpvar->list_position].subtotal = subtotal;
		    PDU_pdurpt->list[mrpvar->list_position].total = total;
                 }
	    strcpy( PDU_pdurpt->list[mrpvar->list_position].name, psuattr[list_row].name );
	    strcpy( PDU_pdurpt->list[mrpvar->list_position].header, text );
            FIg_set_text(fp, PSU_HEADER_FIELD, text);
	    PDU_pdurpt->list[mrpvar->list_position].length = psuattr[list_row].width;
            mrpvar->width = psuattr[list_row].width;
            FIg_set_value(psu_format_id, PSU_WIDTH_SLIDER, (double)mrpvar->width
);
            FIfld_set_value(psu_format_id, PSU_WIDTH_FIELD, 0, 0, (double)mrpvar
->width, TRUE);
            if ((strcmp(psuattr[list_row].datatype, "real") == 0) ||
               (strcmp(psuattr[list_row].datatype, "double") == 0))
              FIg_enable(psu_format_id, PSU_FORMAT_FIELD);
            else
              FIg_disable(psu_format_id, PSU_FORMAT_FIELD);
	    }
         break;

    case PSU_FRMT_EXEC_BUTTON:     /* Member of group   */
         /* Process form data */
	 MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );
	 PSUmode = MRP_NO_MODE;
	 MRPinterpret_message( status, NULL, NULL, NULL );
	 FIf_erase ( fp );
	 MRPdelete_form ( ps_current_form_id );
	 ps_current_form_id = NULL;
	 ps_current_form_num = 0;
         break;

    case PSU_WIDTH_FIELD:     /* Data linked to WIDTH_SLIDER   */
                          /* Field Type:    ASCII    */
	 MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );
          /* Get the text string */

          status = MRPGet_form_text ( fp, g_label, & text, & text_size );

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */

              break;
            }
	  mrpvar->width = atoi(text);
          _pdm_debug("mrpvar->width = %d", (char *)mrpvar->width);

	  if ( PDU_pdurpt->list != NULL)
            {
	    PDU_pdurpt->list[mrpvar->list_position].length = mrpvar->width;
            _pdm_debug("PDU_pdurpt->list[mrpvar->list_position].length = %d", 
                        (char *)PDU_pdurpt->list[mrpvar->list_position].length);
	    }

          /* Code to process text string "text" */


         break;

    case PSU_SORT_BUTTON: 
	 MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );
         FIg_get_state(fp, PSU_SORT_BUTTON, &state);
         if (state == 0)
           break;
	 if ( PDU_pdurpt->list != NULL)
            {
            sort_total = sort_total + 1;
	    PDU_pdurpt->list[mrpvar->list_position].sort = sort_total;
            _pdm_debug("PDU_pdurpt->list[mrpvar->list_position].sort = %d", 
                       (char *)PDU_pdurpt->list[mrpvar->list_position].sort);
	    }
         break;

    case PSU_FORMAT_FIELD:    /* Field Type:    ASCII    */
	 MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );
          /* Get the text string */

          status = MRPGet_form_text ( fp, g_label, & text, & text_size );

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */

              break;
            }
          _pdm_debug("text = %s", text);

          /* added J.P. 03/12/92 */
          if ((text == NULL) || (strcmp(text, "") == 0))
            break;

          /* Code to process text string "text" */

	  if ( PDU_pdurpt->list != NULL)
            {
	    PDU_pdurpt->list[mrpvar->list_position].decimal = atoi(text);
            _pdm_debug("PDU_pdurpt->list[mrpvar->list_position].decimal = %d", 
                       (char *)PDU_pdurpt->list[mrpvar->list_position].decimal);
	    }

         break;

    case PSU_JUST_R:
	 PSUjustification = PSU_RIGHT_JUSTIFY;
         break;

    case PSU_JUST_C:
	 PSUjustification = PSU_CENTER_JUSTIFY;
         break;

    case PSU_JUST_L:
	 PSUjustification = PSU_LEFT_JUSTIFY;
         break;

    case PSU_INSERT_BUTTON:     /* Sequenced to     */
	 PSUmode = PSU_INSERT_MODE;
         break;

    case PSU_MOD_BUTTON:     /* Sequenced to     */
	 PSUmode = PSU_MODIFY_MODE; 
         break;

    case PSU_FRMT_DEL_BUTTON:     /* Sequenced to     */
         PSUmode = PSU_DELETE_MODE;
         break;

    case PSU_WIDTH_SLIDER:     
	 MRPinterpret_message( MRP_I_CleanStatus, NULL, NULL, NULL );
	 mrpvar->width = value;
         _pdm_debug("mrpvar->width = %d", (char *)mrpvar->width);

	  if ( PDU_pdurpt->list != NULL)
            {
	    PDU_pdurpt->list[mrpvar->list_position].length = mrpvar->width;
            _pdm_debug("PDU_pdurpt->list[mrpvar->list_position].length = %d", 
                      (char *)PDU_pdurpt->list[mrpvar->list_position].length);
	    }
         break;

  } /* END switch ( g_label ) */
 }
} /* END notification_routine() */


/********************************************************

	function load_cre_init_dp()

This function loads/creates, initializes, and displays the
psu_format form.

*********************************************************/

int  PSUload_list_format( command, attr, attr_total)
int command;
struct PSUattr *attr;
int attr_total;
{
int sts;
int i,j;
int temp;
int found_row = -1;
int found_row1 = -1;
char txt[10];
char row[10];

PSUmode = MRP_NO_MODE;
PSUcommand = command;

_pdm_debug("MRPtfrmt_load_cre_init_dp",0);

psuattr = attr;
PSU_attr_total = attr_total;

sts = FIf_new ( psu_format_form, "psu_format", pformat_notify_routine,
	&psu_format_id);

/* added JP */
PSUjustification = PSU_LEFT_JUSTIFY;
PSUmode = PSU_INSERT_MODE;
sort_total = 0;
subtotal = 0;
total = 0;

current_form_num = psu_format_form;
_pdm_debug ("set psu_format_id",0);
current_form_id = psu_format_id;
psu_format_created = TRUE;
MRPscroll_col = 0;

txt[0] = '\0';
row[0] = '\0';

_pdm_debug ("dealloc mrpvar->attr",0);
MRPdealloc ( &mrpvar->attr );

_pdm_debug ("before for loop",0);
for ( i = 1; i < 116; ++i )
  {
   if (( (i%10) == 0  ) && ( i < 101 ))
        {
   	strcpy(txt, "");
	sprintf(txt, "%d", i);
	MRPdyn_text ( (13+(i-1)*8), 42, 18, psu_format_id, txt,
		       GAUGE_TX_ROW + (i-1)/10, FI_BLACK);
        }
   if ( (i%5) == 0  )
        {
	if ( i < 101 )
	   {
/* printf("slashes i = %d gad_lab = %d\n", i, DOT_TX_ROW +(i-1)); */
             MRPdyn_text ( (15+(i-1)*8), 62, 18, psu_format_id, "|",
		       DOT_TX_ROW + (i-1), FI_BLACK);
             MRPdyn_text ( (15+(i-1)*8), 172, 15, psu_format_id, "|",
		       DOT_TX_ROW1 + (i-1), FI_BLACK);
           }
        }
   else 
	{
	if ( i < 101 )
	   {
/* printf("dots i = %d gad_lab = %d\n", i, DOT_TX_ROW +(i-1)); */
            MRPdyn_text ( (15+(i-1)*8), 62, 20, psu_format_id, ".",
		       DOT_TX_ROW + (i - 1), FI_BLACK);
            MRPdyn_text ( (15+(i-1)*8), 172, 20, psu_format_id, ".",
		       DOT_TX_ROW1 + (i-1), FI_BLACK);
	   }
	}
   }

  /* fill up list from psuattr structure */
  _pdm_debug ("before loading rpt_value_list",0);
  _pdm_debug("PSU_attr_total = %d", (char *) PSU_attr_total);
  rpt_value_list = (char **) malloc (sizeof (char *) * PSU_attr_total);
  memset(rpt_value_list, NULL, sizeof (char *) * PSU_attr_total);

  PSU_list_size = 0;
  for (i = 0; i < PSU_attr_total; i++)
   {
   rpt_value_list[i] = (char *) malloc(sizeof (char) * 80);
   memset(rpt_value_list[i], NULL, sizeof (char) * 80);
   if (strcmp(psuattr[i].name, "p_attached") != 0)
     {
     if ((psuattr[i].syn) && (strcmp(psuattr[i].syn, "") != 0))
       strcpy(rpt_value_list[PSU_list_size], psuattr[i].syn);
     else
       strcpy(rpt_value_list[PSU_list_size], psuattr[i].name);
     PSU_list_size = PSU_list_size + 1;
     }
   }
     /* ALR  Rearranged the following code so that GRcreate_pull_down_list
        was called after the "LEVEL" was taken out. GRdelete_pull_down_list
        was not needed. This was to fix report format from core dumping
        on the SGI. Could not determine why GRdelete_pull_down_list was
        core dumping. 6/9/94.
     */

   if (((strcmp(PDU_pdurpt->templatetype, "P") == 0) ||
        (strcmp(PDU_pdurpt->templatetype, "X") == 0)) && 
        (PDU_pdurpt->list == NULL))
       {
	   PDU_pdurpt->list_total = 1;
           mrpvar->list_position = 0;
	   PDU_pdurpt->list = (struct dba_default_list *) malloc (sizeof(struct dba_default_list) );
	   PDU_pdurpt->justification = (int *) malloc (sizeof(int) );
	   PDU_pdurpt->justification[mrpvar->list_position] = 1;
	   strcpy(PDU_pdurpt->list[mrpvar->list_position].name, "n_level");
	   strcpy(PDU_pdurpt->list[mrpvar->list_position].header, "Level");
	   PDU_pdurpt->list[mrpvar->list_position].type = DBA_COLUMN;
	   PDU_pdurpt->list[mrpvar->list_position].start = 1;
	   PDU_pdurpt->list[mrpvar->list_position].length = 10;
	   PDU_pdurpt->list[mrpvar->list_position].decimal = 1;
	   PDU_pdurpt->list[mrpvar->list_position].sort = 0;
	   PDU_pdurpt->list[mrpvar->list_position].subtotal = 0;
	   PDU_pdurpt->list[mrpvar->list_position].total = 0;
         }
   for (i=0; i < PDU_pdurpt->list_total; i++)
     {           
        for (j = 0; j < PSU_attr_total; j++)
         {
              if (strcmp(psuattr[j].name,PDU_pdurpt->list[i].name ) == 0)
              {
                found_row = j;
                 break;
               }
         }

         if (found_row != -1)
          {
             for (j = 0; j < PSU_list_size; j ++)
              if (strcmp(rpt_value_list[j],psuattr[found_row].syn) == 0)
               {
                 found_row1 = j;
                  break;
                }
              if (found_row1 != -1)
              { 
                PSU_list_size = PSU_list_size - 1;
                for (j = found_row1; j < PSU_list_size; j ++)
                  strcpy(rpt_value_list[j], rpt_value_list[j + 1]);
              }
          }

         if (PSU_list_size == 0)
              FIg_erase(psu_format_id, PSU_ATTR_BUTTON);

         PSUplace_attr_fmt ( PDU_pdurpt->list_total );
    }


  GRcreate_pull_down_list(psu_format_form, psu_format_id, PSU_ATTR_ASSOC_GAD,
                        PSU_list_size,VIS_ROWS,rpt_value_list, PSU_list_size,1,
                        &rpt_value_pulldown);
  GRchange_pull_down_text(rpt_value_pulldown, rpt_value_list, PSU_list_size);
 

  /* default character/line field to default width */
  _pdm_debug ("before setting report width",0);
  sprintf(row, "%d", PDU_pdurpt->options.width);
  FIg_set_text(psu_format_id, PSU_CHARS_FIELD, row);

  _pdm_debug ("before setting report length",0);
  sprintf(row, "%d", PDU_pdurpt->options.lines);
  FIg_set_text(psu_format_id, PSU_LINES_FIELD, row);

/**** Display the psu_format form and set the flag ****/
sts = FIf_display ( psu_format_id );
return( MRP_S_Success );
}

int PSUfind_attr(text)
char *text;
  {
  int status = MRP_S_Success;
  int i;
  int row = -1;

  for (i = 0; i < PSU_attr_total; i++)
    {
    if (strcmp(text, psuattr[i].syn) == 0)
      {
      status = MRP_S_Success;
      row = i;
      break;
      }
    else if (strcmp(text, psuattr[i].name) == 0)
      {
      status = MRP_S_Success;
      row = i;
      break;
      }
    else
      status = MRP_I_NoMRPAttrFound;
    }

  if (status != MRP_S_Success)
    {
    row = -1;
    return(row);
    }

  for (i = 0; i < PSU_list_size; i ++) 
    {
    if ((strcmp(psuattr[row].name, rpt_value_list[i]) == 0) || 
        (strcmp(psuattr[row].syn, rpt_value_list[i]) == 0))
      {
      status = MRP_S_Success;
      break;
      }
   else
     status = MRP_I_NoMRPAttrFound;
   }
  if (status != MRP_S_Success)
    row = -1;
  return(row);
  }

int PSUdelete_attr_from_pulldown()

{
  int i;
  int found_row = -1;
  int found_row1 = -1;

  _pdm_debug("Enter PSUdelete_attr_from_pulldown",0); 
  for (i = 0; i < PSU_attr_total; i++)
   {
   if (strcmp(psuattr[i].name,
       PDU_pdurpt->list[mrpvar->list_position].name ) == 0)
     {
     found_row = i;
     break;
     }
   }

  if (found_row == -1)
    return(MRP_S_Success);

 /* ALR  Synonyms may not exist for user defined attributes. Why do we
     need to check for the position of the user defined attribute.
     TR139420169 */
 
  for (i = 0; i < PSU_list_size; i ++)
  {
   if (strcmp(rpt_value_list[i], 
       psuattr[found_row].syn) == 0)
     {
     found_row1 = i;
     break;
     }
   }

  if (found_row1 == -1)
   return(PDM_S_SUCCESS);

  PSU_list_size = PSU_list_size - 1;
  for (i = found_row1; i < PSU_list_size; i ++)
    strcpy(rpt_value_list[i], rpt_value_list[i + 1]);


  if (PSU_list_size == 0)
    FIg_erase(psu_format_id, PSU_ATTR_BUTTON);
 GRdelete_pull_down_list(rpt_value_pulldown);
 GRcreate_pull_down_list(psu_format_form, psu_format_id, PSU_ATTR_ASSOC_GAD,
                        PSU_list_size,VIS_ROWS,rpt_value_list, PSU_list_size,1, 
                        &rpt_value_pulldown); 
  GRchange_pull_down_text(rpt_value_pulldown, rpt_value_list, PSU_list_size);
  return(MRP_S_Success);
  }

int PSUadd_attr_to_pulldown(recreate_pulldown)
short recreate_pulldown;
  {
  int i;

  for (i = 0; i < PSU_attr_total; i++)
   if (strcmp(psuattr[i].name, PDU_pdurpt->list[mrpvar->list_position].name) == 0)
     {
     if ((psuattr[i].syn) && (strcmp(psuattr[i].syn, "") != 0))
       {
       strcpy(rpt_value_list[PSU_list_size], psuattr[i].syn);
       }
     else
       {
       strcpy(rpt_value_list[PSU_list_size], psuattr[i].name);
       }
     PSU_list_size = PSU_list_size + 1;
     break;
     }

  FIg_display(psu_format_id, PSU_ATTR_BUTTON);
  if (recreate_pulldown)
  {
  GRdelete_pull_down_list(rpt_value_pulldown);
  GRcreate_pull_down_list(psu_format_form, psu_format_id, PSU_ATTR_ASSOC_GAD,
                        PSU_list_size,VIS_ROWS,rpt_value_list, PSU_list_size,1, 
                        &rpt_value_pulldown); 
  GRchange_pull_down_text(rpt_value_pulldown, rpt_value_list, PSU_list_size);
  }
  return(MRP_S_Success);
  }
 
