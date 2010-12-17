#include <stdio.h>
#include "FI.h"
#include "tools.h"
#include "PDUuser.h"
#include "PDUstr.h"
#include "PDUform_def.h"
#include "PDUintdef.h"
#include "PDUerror.h"
#include "PDUforms.h"
#include <PDUfile_def.h>
#include "PDUassy.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUproto.h"
#include "PDMproto.h"
#include <sys/types.h>
#include <sys/stat.h>
#include "exdef.h"

#define ASSEMBLY_MCF         17
#define DEFINE_ASSY_MCF      17
#define DEFINE_ASSY_MCF_GRP  54
#define USAGEID_FLD          50
#define PROJECT_FIELD        33
#define CATALOG_FIELD        34
#define PARTNUM_FIELD        35
#define REVISION_FLD         36
#define DESC_FLD             37
#define PROJECT_LIST_BTN     66
#define CATALOG_LIST_BTN     67
#define PARTNUM_LIST_BTN     68
#define REVISION_LIST_BTN    69
#define ADD_BTN              40
#define DELETE_BTN           41
#define ASSY_CAT_FLD         39
#define ASSY_PART_FLD        55
#define ASSY_REV_FLD         56
#define ASSY_DESC_FLD        57
#define ASSY_SELECT_GRP      64
#define PART_SEARCH_MCF      59
#define EXPLODE_DEPTH        12
#define ASSY_CAT_LIST_BTN    71
#define ASSY_PART_LIST_BTN   72
#define ASSY_REV_LIST_BTN    73
#define STRUCTURE_LIST_GRP   71
#define STRUCTURE_MCF        57
#define PLACE_BTN            40
#define DELETE_BTN           41
#define ASSY_OPTIONS_BTN     22
#define SELECT_ALL           80
#define DESELECT_ALL         81
#define UPDATE               43
#define SEARCH_BTN           42

extern int    PDU_command;
extern int    PDMdebug_on;
extern int    PDU_act_row;
extern int    PDU_explode_depth;
extern int    PDU_save_level;
extern int    PDU_selected_rows;
extern int    PDU_checkout_type;
extern int    *PDU_parts_index;
extern short  PDU_keyin_area;
extern short  PDU_select_area;
extern short  PDU_second_row;
extern short  PDU_structure_list;
extern short  PDU_attach;
extern short  PDU_display_dyn_attr;
extern MEMptr PDU_assy_parts_bufr;
extern MEMptr PDU_struct_bufr;
extern MEMptr PDU_dyn_attr_bufr;
extern MEMptr PDU_dyn_data_bufr;
extern MEMptr PDU_dyn_value_bufr;
extern MEMptr PDU_def_assy_bufr;
extern MEMptr PDU_hold_bufr;
extern char   *PDU_assy_catalog;
extern char   *PDU_assy_partid;
extern char   *PDU_assy_revision;
extern char   *PDU_assy_description;
extern char   *PDU_assy_parttype;
extern char   *PDU_usage_id;
extern char   *PDU_quantity;
extern char   *PDU_explode_BOM;
extern char   *PDU_alt_tagno; 
extern char   *PDU_tagno;    
extern char   *PDU_incl_BOM; 
extern char   *PDU_incl_ASM;
extern Form   PDU_form_id;
extern Form   PDU_struct_type;
extern Form   PDU_calling_form;
extern struct PDUforms    forms;
extern struct PDUrefresh  *refresh;
extern struct PDUuser     *user;
extern struct PDUassy_node   *PDU_assy_head;
extern char   **PDU_file_list;

int PDUdisplay_review_structure(assy_buffer)
MEMptr        assy_buffer;
{
int           all_flag = FALSE;
int           no_headings;
int           status = PDM_S_SUCCESS;
char          **headings;

  _pdm_debug("In the function PDUdisplay_review_structure", 0);

  PDUsetup_single_buffer(assy_buffer);

  all_flag = FALSE;
  no_headings = 8;
  headings = (char **) malloc (sizeof (char *) * no_headings);
  memset(headings, NULL, sizeof (char *) * no_headings);

  PDUfill_in_string(&headings[0], "p_level");
  PDUfill_in_string(&headings[1], "n_catalogname");
  PDUfill_in_string(&headings[2], "n_itemname");
  PDUfill_in_string(&headings[3], "n_itemrev");
  PDUfill_in_string(&headings[4], "n_itemdesc");
  PDUfill_in_string(&headings[5], "p_attached");
  PDUfill_in_string(&headings[6], "p_quantity");
  PDUfill_in_string(&headings[7], "p_usageid");

  PDUsetup_popup_list(headings, no_headings, all_flag, assy_buffer);

  PDUfree_string_array(&headings, no_headings);

  PDU_second_row = FALSE;
  _pdm_debug("PDU_structure_list = <%d>", (char *)PDU_structure_list);
  if (PDU_structure_list == FALSE)
    {
    _pdm_debug("displaying STRUCTURE_LIST_GRP", 0);
    FIg_display(forms.local_files_form_id, STRUCTURE_LIST_GRP);
    }
  PDU_structure_list = TRUE;
  PDU_selected_rows = 0;
  FIg_display(forms.local_files_form_id, SELECT_ALL);
  FIg_display(forms.local_files_form_id, DESELECT_ALL);

  PDUbufr_to_mcf(assy_buffer, forms.local_files_form_id, STRUCTURE_MCF);
  FIfld_set_active_row(forms.local_files_form_id, STRUCTURE_MCF, 0, 0);

  /* initialize a global array for selected part rows */
  PDU_parts_index = (int *) malloc (sizeof (int) * (assy_buffer->rows));
  memset(PDU_parts_index, -1, sizeof (int) * (assy_buffer->rows));

  _pdm_debug("setting number of rows to <%d>", (char *)(assy_buffer->rows));
  FIfld_set_num_rows(forms.local_files_form_id, STRUCTURE_MCF, 
                     (assy_buffer->rows));

  PDUmessage(status, 's');
  return(status);
}

int PDUload_assembly_structure()
{
int           all_flag = FALSE;
int           no_headings;
int           status = PDM_S_SUCCESS;
char          **headings;

  _pdm_debug("In the function PDUload_assembly_structure", 0);

  PDUsetup_single_buffer(PDU_def_assy_bufr);

  all_flag = FALSE;
  no_headings = 9;
  headings = (char **) malloc (sizeof (char *) * no_headings);
  memset(headings, NULL, sizeof (char *) * no_headings);

  PDUfill_in_string(&headings[0], "p_level");
  PDUfill_in_string(&headings[1], "n_catalogname");
  PDUfill_in_string(&headings[2], "n_itemname");
  PDUfill_in_string(&headings[3], "n_itemrev");
  PDUfill_in_string(&headings[4], "p_attached");
  PDUfill_in_string(&headings[5], "p_quantity");
  PDUfill_in_string(&headings[6], "p_usageid");
  PDUfill_in_string(&headings[7], "p_pchildno");
  PDUfill_in_string(&headings[8], "p_childno");

  PDUsetup_popup_list(headings, no_headings, all_flag, PDU_def_assy_bufr);

  PDUfree_string_array(&headings, no_headings);

  FIg_display(forms.define_assy_form_id, DEFINE_ASSY_MCF_GRP);

  PDU_second_row = TRUE;
  PDUbufr_to_mcf(PDU_def_assy_bufr,forms.define_assy_form_id,DEFINE_ASSY_MCF);
  FIfld_set_active_row(forms.define_assy_form_id, DEFINE_ASSY_MCF, 0, 0);
  PDU_second_row = FALSE;
  PDU_act_row = -1;

  FIfld_set_num_rows(forms.define_assy_form_id, DEFINE_ASSY_MCF, 
                     PDU_def_assy_bufr->rows - 1);
  PDUunfreeze_assy_mcf();

  PDUmessage(status, 's');
  return(status);

}  /* end PDUload_assembly_structure */

int PDUadd_part_to_assy_structure()
{
  int      status = PDM_S_SUCCESS;
  int      tagno;
  char     *temp_usage = NULL;
  char     *p_explode = NULL;

  _pdm_debug("in the function PDUadd_part_to_assy_structure", 0);

  /* query for template usage id */
  status = PDMget_usageid_cat(PDU_assy_catalog, &temp_usage);
  _pdm_status("PDMget_usageid", status);

  _pdm_debug("temp_usageid = <%s>", temp_usage);

  /* check the usage id */
  if (PDU_usage_id == NULL)
    {
    /* default the usage id */
    _pdm_debug("usage id is NULL", 0);
    PDUgenerate_ng_usageid(PDU_assy_catalog,PDU_assy_partid,PDU_assy_revision);
    _pdm_debug("Usage id = <%s>", PDU_usage_id);
    }
  else if (strcmp(PDU_usage_id, "") == 0)
    {
    /* default the usage id */
    _pdm_debug("usage id = NULL_STRING", 0);
    PDUgenerate_ng_usageid(PDU_assy_catalog,PDU_assy_partid,PDU_assy_revision);
    _pdm_debug("Usage id = <%s>", PDU_usage_id);
    }
  else if ((temp_usage) && (strcmp(temp_usage, "") != 0) &&
           (strcmp(PDU_usage_id, temp_usage) == 0))
    {
    /* default the usage id */
    PDU_usage_id = NULL_STRING;
    _pdm_debug("usage id = NULL_STRING", 0);
    PDUgenerate_ng_usageid(PDU_assy_catalog,PDU_assy_partid,PDU_assy_revision);
    _pdm_debug("Usage id = <%s>", PDU_usage_id);
    }
  else
    {
    _pdm_debug("usage id is not NULL", 0);
    _pdm_debug("Usage id = <%s>", PDU_usage_id);
    }

  /* get the tagno number for the part to be added */
  if (PDU_assy_head)
    tagno = PDUgenerate_tagno_from_linklist(PDU_assy_head);
  else
    tagno = 1;
  _pdm_debug("tagno = %d", (char *)tagno);
  PDU_tagno = (char *) malloc (sizeof (char) * 10);
  memset(PDU_tagno, NULL, sizeof (char) * 10);
  sprintf(PDU_tagno, "%d", tagno);

  /* get dynamic buffers */
  if (PDU_dyn_data_bufr)
    {
    MEMclose(&PDU_dyn_data_bufr);
    PDU_dyn_data_bufr = NULL;
    }
  if (PDU_dyn_attr_bufr)
    {
    MEMclose(&PDU_dyn_attr_bufr);
    PDU_dyn_attr_bufr = NULL;
    }
  if (PDU_dyn_value_bufr)
    {
    MEMclose(&PDU_dyn_value_bufr);
    PDU_dyn_value_bufr = NULL;
    }

  status = PDMquery_dynamic_attrs(PDU_assy_catalog, PDU_assy_partid,
                                  PDU_assy_revision, &PDU_dyn_attr_bufr,
                                  &PDU_dyn_data_bufr,&PDU_dyn_value_bufr,
                                  &p_explode);
  _pdm_status("PDMquery_dynamic_attrs", status);

  if ((status != PDM_S_SUCCESS) || (PDU_dyn_attr_bufr == NULL))
    {
      _pdm_debug("No Dynamic Attributes Were Defined For This Catalog", 0);
    }

  /* Display dynamic form if toggle is ON */
  if ((PDU_display_dyn_attr) || (strlen(PDU_usage_id) > 25))
    {
    FIf_erase(forms.define_assy_form_id);
    PDU_calling_form = forms.define_assy_form_id;
    _pdm_debug("Calling PDUdynamic_attr_form", 0);
    _pdm_debug("PDU_usage_id = <%s>", PDU_usage_id);
    status = PDUdynamic_attr_form();
    _pdm_status("PDUdynamic_attr_form", status);
    return(status);
    }
  else
    {
    status = PDUplace_ng_assembly();
    _pdm_status("PDUplace_ng_assembly", status);
    }

  return(status);

}  /* end PDUadd_part_to_assy_structure */

int PDUdelete_assy_part()
{
  int       status = PDM_S_SUCCESS;
  int       i;
  int       num_rows;
  int       level;
  int       select, pos;
  int       length;
  int       column;
  char      *usageid = NULL;
  static char *text = NULL;

  _pdm_debug("in the function PDUdelete_assy_part", 0);

  _pdm_debug("active row = %d", (char *)PDU_act_row);

  /* get the usage id for the active row */
  column = 6;   /* usage id column */
  FIfld_get_text_length(forms.define_assy_form_id, DEFINE_ASSY_MCF, PDU_act_row,
                        column, &length);
  text = (char *) malloc (sizeof (char) * length + 1);
  memset(text, NULL, sizeof (char) * length + 1);
  FIfld_get_text(forms.define_assy_form_id, DEFINE_ASSY_MCF, PDU_act_row, 
                 column, length, (unsigned char *)text, &select, &pos);
  _pdm_debug("usage id = <%s>", text);
  PDUfill_in_string(&usageid, text);

  /* drop a link in the linked list */
  PDUdrop_node_from_linklist(usageid);

  /* erase row in the assembly mcf */
  FIfld_delete_rows(forms.define_assy_form_id, DEFINE_ASSY_MCF, PDU_act_row, 1);

  FIfld_get_num_rows(forms.define_assy_form_id, DEFINE_ASSY_MCF, &num_rows);

  if (PDU_act_row == num_rows)  /* no more rows in the field */
    {
    if ((PDMdebug_on) && (PDU_assy_head))
      PDUprint_linklist(PDU_assy_head);
    return(status);
    }

  /* delete parts up to the next first-level part */
  for (i = PDU_act_row; i < num_rows; ++i)
     {
     _pdm_debug("PDU_act_row = %d", (char *)PDU_act_row);
     _pdm_debug("num_rows = %d", (char *)num_rows);
     /* check the level number of the part */
     level = PDUcheck_level_no(forms.define_assy_form_id, DEFINE_ASSY_MCF, i);
     _pdm_debug("level = %d", (char *)level);
     if (level != 1)
       {
       /* erase row in the assembly mcf */
       _pdm_debug("deleting row %d", (char *)i);
       FIfld_delete_rows(forms.define_assy_form_id, DEFINE_ASSY_MCF, i, 1);
     
       FIfld_get_num_rows(forms.define_assy_form_id,DEFINE_ASSY_MCF,&num_rows);
       --i;   /* since you decreased num_rows, 'i' must be decremented */

       /* get the usage id for the active row */
       column = 6;   /* usage id column */
       FIfld_get_text_length(forms.define_assy_form_id, DEFINE_ASSY_MCF, i,
                             column, &length);
       text = (char *) malloc (sizeof (char) * length + 1);
       memset(text, NULL, sizeof (char) * length + 1);
       FIfld_get_text(forms.define_assy_form_id, DEFINE_ASSY_MCF, i, 
                      column, length, (unsigned char *)text, &select, &pos);
       _pdm_debug("usage id = <%s>", text);
       PDUfill_in_string(&usageid, text);

       /* drop a link in the linked list */
       PDUdrop_node_from_linklist(usageid);

       }
     else
       break;
     }

  if (PDMdebug_on)
    PDUprint_linklist(PDU_assy_head);

  return(status);
}  /* end PDUdelete_assy_part */

int PDUadd_row_to_assy_mcf(form, field, rows, level, parent, child,
                           catalog, partid, revision, 
                           attach, quantity, usage)
   Form                      form;
   int                       field;
   int                       rows;
   int                       level;
   int                       parent;
   int                       child;
   char                      *catalog;
   char                      *partid;
   char                      *revision;
   char                      *attach;
   char                      *quantity;
   char                      *usage;
{
  int           status = PDM_S_SUCCESS;
  int           num_rows;
  char          level_str[10];
  char          parent_str[10];
  char          child_str[10];

  _pdm_debug("in the function PDUadd_row_to_assy_mcf", 0);

  FIfld_set_num_rows(form, field, rows + 1);
  FIfld_get_num_rows(form, field, &num_rows);
  _pdm_debug("new num_rows = %d", (char *)num_rows);

  sprintf(level_str, "%d", level);
  sprintf(parent_str, "%d", parent);
  sprintf(child_str, "%d", child);

  FIfld_set_text(form, field, rows, 0, level_str, FALSE);
  FIfld_set_text(form, field, rows, 1, catalog, FALSE);
  FIfld_set_text(form, field, rows, 2, partid, FALSE);
  FIfld_set_text(form, field, rows, 3, revision, FALSE);
  FIfld_set_text(form, field, rows, 4, attach, FALSE);
  FIfld_set_text(form, field, rows, 5, quantity, FALSE);
  FIfld_set_text(form, field, rows, 6, usage, FALSE);
  FIfld_set_text(form, field, rows, 7, parent_str, FALSE);
  FIfld_set_text(form, field, rows, 8, child_str, FALSE);

  return(status);
}  /* end PDUadd_row_to_assy_mcf */

int PDUcreate_assembly_parts_buffer(form, field, buffer)
  Form      form;
  int       field;
  MEMptr    *buffer;
{
  int       status = PDM_S_SUCCESS;
  int       length;
  int       select, pos;
  int       row, column;
  int       num_rows;
  int       level;
  int       char_index;
  static char *text;
  char      *line;
  char      *catalog = NULL;
  char      *partid = NULL;
  char      *revision = NULL;
  char      *attached = NULL;
  char      *quantity = NULL;
  char      *usageid = NULL;
  char      *tag = NULL;
  char      *alttagno = NULL;
  char      *incbom = NULL;
  char      *explode = NULL;
  char      *filename = NULL;
  char      *history = NULL;
  char      *parent_str = NULL;
  char      *child_str = NULL;

  _pdm_debug("In the function PDUcreate_assembly_parts_buffer", 0);

  status = PDUformat_buffer(PDU_CHILD_BUFR, buffer);
  _pdm_status("PDUformat_buffer", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  FIfld_get_num_rows(form, field, &num_rows);

  for (row = 0; row < num_rows; ++row)
     {
     level = PDUcheck_level_no(form, field, row);
     if (level == 1)
       {
       line = (char*) malloc ((*buffer)->row_size);
       memset (line, NULL, (*buffer)->row_size);

       for (column = 1; column < 10; ++column)
          {
          FIfld_get_text_length(form, field, row, column, &length);
          text = (char *) malloc (sizeof (char) * length);
          FIfld_get_text(form, field, row, column, length, 
                        (unsigned char *)text, &select, &pos);
          if      (column == 1) PDUfill_in_string(&catalog, text);
          else if (column == 2) PDUfill_in_string(&partid, text);
          else if (column == 3) PDUfill_in_string(&revision, text);
          else if (column == 4) PDUfill_in_string(&attached, text);
          else if (column == 5) PDUfill_in_string(&quantity, text);
          else if (column == 6) PDUfill_in_string(&usageid, text);
          else if (column == 7) PDUfill_in_string(&parent_str, text);
          else if (column == 8) PDUfill_in_string(&child_str, text);
          free(text);
          }

       PDUfill_in_string(&tag, "");
       PDUfill_in_string(&alttagno, "");
       PDUfill_in_string(&incbom, "Y");
       PDUfill_in_string(&explode, "");
       PDUfill_in_string(&filename, "");
       PDUfill_in_string(&history, "");

       char_index = 0;
  
       if ((strlen (child_str )) && child_str)
         PDUadd_buffer_string(line, &char_index, child_str);
       else
         line[char_index++] = '\1';
  
       if ((strlen (catalog )) && catalog)
         PDUadd_buffer_string(line, &char_index, catalog);
       else
         line[char_index++] = '\1';
  
       if ((strlen (partid )) && partid)
         PDUadd_buffer_string(line, &char_index, partid);
       else
         line[char_index++] = '\1';
  
       if ((strlen (revision )) && revision)
         PDUadd_buffer_string(line, &char_index, revision);
       else
         line[char_index++] = '\1';
  
       if ((strlen (attached )) && attached)
         PDUadd_buffer_string(line, &char_index, attached);
       else
         line[char_index++] = '\1';
  
       if ((strlen (quantity )) && quantity)
         PDUadd_buffer_string(line, &char_index, quantity);
       else
         line[char_index++] = '\1';
  
       if ((strlen (usageid )) && usageid)
         PDUadd_buffer_string(line, &char_index, usageid);
       else
         line[char_index++] = '\1';
  
       if ((strlen (tag )) && tag)
         PDUadd_buffer_string(line, &char_index, tag);
       else
         line[char_index++] = '\1';
  
       if ((strlen (alttagno )) && alttagno)
         PDUadd_buffer_string(line, &char_index, alttagno);
       else
         line[char_index++] = '\1';
  
       if ((strlen (incbom )) && incbom)
         PDUadd_buffer_string(line, &char_index, incbom);
       else
         line[char_index++] = '\1';
  
       if ((strlen (explode )) && explode)
         PDUadd_buffer_string(line, &char_index, explode);
       else
         line[char_index++] = '\1';

       if ((strlen (filename )) && filename)
         PDUadd_buffer_string(line, &char_index, filename);
       else
         line[char_index++] = '\1';

       if ((strlen (history )) && history)
         PDUadd_buffer_string(line, &char_index, history);
       else
         line[char_index++] = '\1';

       _pdm_debug("line = <%s>", line);

       status = MEMwrite (*buffer, line);
       free(line);
       }
     }

  if (PDMdebug_on)
    MEMprint_buffer("assembly parts buffer", *buffer, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
}  /* end PDUcreate_assembly_parts_buffer */

int PDUcheck_level_no(form, field, row)
  Form     form;
  int      field;
  int      row;
{
  int      level;
  static char *text = NULL;
  int      length;
  int      select, pos;

  _pdm_debug("in the function PDUcheck_level_no", 0);

  /* get the level number */
  FIfld_get_text_length(form, field, row, 0, &length);
  text = (char *) malloc (sizeof (char) * length);
  FIfld_get_text(form, field, row, 0, length, (unsigned char *)text, 
                 &select, &pos);
  if ((text != NULL) && (strcmp(text, "") != 0))
    sscanf(text, "%d", &level);
  free(text);

  return(level);

}  /* end PDUcheck_level_no */

int PDUdefault_usageid(catalog, partid, revision, childno, usageid)
   char      *catalog;
   char      *partid;
   char      *revision;
   int        childno;
   char      **usageid;
{
   int   status = PDM_S_SUCCESS;
   char  child_str[10];
   char  *catno = NULL;
   char  *partno = NULL;

   _pdm_debug("in the function PDUdefault_usageid", 0);

   *usageid = NULL_STRING;

   sprintf(child_str, "%d", childno);

   _pdm_debug("getting the catalog and part numbers", 0);
   status = PDMget_catno_partno(catalog, partid, revision, &catno, &partno);
   _pdm_status("PDMget_catno_partno", status);

   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return(status);
     }

   *usageid = (char *) malloc (sizeof (char) * 25);
   memset(*usageid, NULL, sizeof (char) * 25);
  
   strcpy(*usageid, catno);
   strcat(*usageid, " ");
   strcat(*usageid, partno);
   strcat(*usageid, " #");
   strcat(*usageid, child_str);
  
   return(PDM_S_SUCCESS);
}  /* end PDUdefault_usageid */

int PDUget_assembly(get_level)
  short  get_level;
{
  int    status = PDM_S_SUCCESS;
  int    row;
  int    column;
  int    num_rows;
  int    num_cols;
  int    level;
  int    select, pos;
  int    length;
  int    file_col;
  char   *state = NULL;
  char   *msg = NULL;
  char   *filename = NULL;
  char   explode_string[10];
  char   type[2];
  char   **data_row;
  static char *text = NULL;
  MEMptr ret_bufr = NULL;

  _pdm_debug("in the function PDUget_assembly", 0);

  /* check the catalog field - work around */
  FIfld_get_text_length(forms.define_assy_form_id,CATALOG_FIELD,0,0, &length);
  text = (char *) malloc (sizeof (char) * length + 1);
  memset(text, NULL, sizeof (char) * length + 1);
  FIfld_get_text(forms.define_assy_form_id, CATALOG_FIELD, 0, 0, length, 
                 (unsigned char *)text, &select, &pos);
  if ((text == NULL) || (strcmp(text, "") == 0))
    refresh->rev_catalog = NULL;
  else
    PDUfill_in_string(&refresh->rev_catalog, text);
  if (text); 
    free(text);

  _pdm_debug("catalog = <%s>", refresh->rev_catalog);
  
  if ((refresh->rev_catalog != NULL)           &&
      (strcmp(refresh->rev_catalog, "") != 0))
    {
    /* check the type of the catalog */
    status = PDMquery_catalog_type(refresh->rev_catalog, type);
    _pdm_status("PDMquery_catalog_type", status);

    if ((strcmp(type, "P") == 0) ||
        (strcmp(type, "CID") == 0) ||
        (strcmp(type, "EID") == 0))
      {
      PDUmessage(PDM_E_PARAMETRIC_STRUCTURE, 's');
      msg = (char *) PDUtranslate_message(PDM_E_PARAMETRIC_STRUCTURE);
      FIg_set_text(forms.define_assy_form_id, FI_MSG_FIELD, msg);
      refresh->rev_catalog = NULL;
      FIg_set_text(forms.define_assy_form_id, CATALOG_FIELD, NULL_STRING);
      PDUmessage(PDM_E_PARAMETRIC_STRUCTURE, 's');
      return(PDM_E_PARAMETRIC_STRUCTURE);
      }

    /* enable assembly options button */
    FIg_enable(forms.define_assy_form_id, ASSY_OPTIONS_BTN);
    }
  else
    FIg_disable(forms.define_assy_form_id, ASSY_OPTIONS_BTN);

  if ((refresh->rev_catalog != NULL)           &&
      (strcmp(refresh->rev_catalog, "") != 0)  &&
      (refresh->rev_partid != NULL)            &&
      (strcmp(refresh->rev_partid, "") != 0)   &&
      (refresh->rev_revision != NULL)          &&
      (strcmp(refresh->rev_revision, "") != 0))
    {
    /* check the parttype */
/*
    status = PDMquery_part_type(refresh->rev_catalog, refresh->rev_partid, 
                                refresh->rev_revision, &buffer);
    _pdm_status("PDMquery_part_type", status);
 
    if ((buffer) && (status == PDM_S_SUCCESS))
      {
      MEMbuild_array(buffer);
      status = PDUget_buffer_col(buffer, "p_parttype", &type_col);
      if (status != PDM_S_SUCCESS)
        return(status);

      PDUsetup_buffer(buffer, ROW, &list_row);

      PDUfill_in_string(&refresh->rev_parttype,
                  list_row[(buffer->columns * 0) + type_col]);
      _pdm_debug("parttype = <%s>", refresh->rev_parttype);
      MEMclose(&buffer);
      }
    else
      {
      PDUmessage(status, 's');
      MEMclose(&buffer);
      }
*/
   _pdm_debug("parttype = <%s>", refresh->rev_parttype);

    _pdm_debug("retrieving filenames", 0);
    status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                           refresh->rev_revision, &ret_bufr);
    _pdm_status("PDMget_filenames", status);

    if ((status == PDM_S_SUCCESS) && (ret_bufr) && (ret_bufr->rows > 0))
      {
      MEMbuild_array(ret_bufr);
      PDUsetup_buffer(ret_bufr, ROW, &data_row);
      status = PDUget_buffer_col(ret_bufr, "n_cofilename", &file_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(PDM_E_COL_NOT_IN_BUFFER, 's');
        return(PDM_E_COL_NOT_IN_BUFFER);
        }

      for (row = 0; row < ret_bufr->rows; ++row)
         {
         PDUfill_in_string(&filename,
                             data_row[(ret_bufr->columns * 0) + file_col]);
         if ((filename) && (strcmp(filename, "") != 0))
           {
           _pdm_debug("filename = <%s>", filename);
           status = PDUis_file_open(filename);
           _pdm_status("PDUis_file_open", status);
           if (status == 1)
             {
             PDUmessage(PDM_E_OPEN_FILE_NOT_ALLOWED, 's');
             MEMclose(&ret_bufr);
             return(PDM_E_OPEN_FILE_NOT_ALLOWED);
             }
           }
         }
      MEMclose(&ret_bufr);
      }
 
    /* validate access */
    status = PDMvalidate_user_access("PDMUpdate Assembly Structure", NULLSTR,
           refresh->rev_catalog, NULLSTR, refresh->rev_partid,
           refresh->rev_revision );
    _pdm_status ("PDMvalidate_user_access", status);

    if (status != PDM_S_SUCCESS)
      return(status);

    /* get the file status of the part */
    status = PDUget_file_status(refresh->rev_catalog, refresh->rev_partid,
                                refresh->rev_revision, &state);
    _pdm_status("PDUget_file_status", status);

    if ((state) && (strcmp(state, "I") != 0) && (strcmp(state, "") != 0))
      {
      PDUmessage(PDM_I_PART_CHECKIN, 's');
      msg = (char *)PDUtranslate_message(PDM_I_PART_CHECKIN);
      FIg_set_text(forms.define_assy_form_id, FI_MSG_FIELD, msg);
      refresh->rev_catalog = NULL;
      refresh->rev_partid = NULL;
      refresh->rev_revision = NULL;
      refresh->rev_description = NULL;

      FIg_set_text(forms.define_assy_form_id, CATALOG_FIELD, NULL_STRING);
      FIg_set_text(forms.define_assy_form_id, PARTNUM_FIELD, NULL_STRING);
      FIg_set_text(forms.define_assy_form_id, REVISION_FLD, NULL_STRING);
      FIg_set_text(forms.define_assy_form_id, DESC_FLD, NULL_STRING);

      FIfld_pos_cursor(forms.define_assy_form_id, CATALOG_FIELD, 0,0,0,0,1,1);
      return(PDM_S_SUCCESS);
      }

    if (PDU_def_assy_bufr)
      {
      MEMclose(&PDU_def_assy_bufr);
      PDU_def_assy_bufr = NULL;

      /* clear out the mcf */
      FIfld_get_num_rows(forms.define_assy_form_id, DEFINE_ASSY_MCF, &num_rows);
      FImcf_get_num_cols(forms.define_assy_form_id, DEFINE_ASSY_MCF, &num_cols);
      for (row = 0; row < num_rows; ++row)
         for (column = 0; column < num_cols; ++column)
            FIfld_set_text(forms.define_assy_form_id, DEFINE_ASSY_MCF, row,
                           column, "", FALSE);
      }

    if (get_level == TRUE)
      {
      /* get the max level of display from the database */
      status = PDUget_max_level(&level);
      _pdm_status("PDUget_max_level", status);

      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status);
        return(status);
        }

      _pdm_debug("level = %d", (char *)level);
      _pdm_debug("setting PDU_explode_depth", 0);
      PDU_explode_depth = level;
      _pdm_debug("setting PDU_save_level", 0);
      PDU_save_level = level;
      
      /* fill in the explode level on the options form */
      if (PDU_explode_depth != MAX_LEVEL)
        {
        _pdm_debug("PDU_explode_depth = %d", (char *)PDU_explode_depth);
        sprintf(explode_string, "%d", PDU_explode_depth);
/*
        if (PDU_assy_options_created == TRUE)
          FIg_set_text(forms.assy_options_form_id,EXPLODE_DEPTH,explode_string);
*/
        }
      else
        {
/*
        if (PDU_assy_options_created == TRUE)
          FIg_set_text(forms.assy_options_form_id, EXPLODE_DEPTH, "MAX_LEVEL");
*/
        }
      }
    
    _pdm_debug("explode depth = %d", (char *)PDU_explode_depth);
    status = PDMget_assembly_structure(refresh->rev_catalog, 
                                  refresh->rev_partid, refresh->rev_revision,
                                  PDU_explode_depth, &PDU_def_assy_bufr, 0);
    _pdm_status("PDMget_assembly_structure", status);

    if (!PDU_def_assy_bufr)
      {
      PDUmessage(PDM_E_RETRIEVE_ASSEMBLY, 's');
      return(PDM_E_RETRIEVE_ASSEMBLY);
      }

    if ((status != PDM_S_SUCCESS) && (status != PDM_E_PART_NOT_ASSEMBLY))
      {
      PDUmessage(status, 's');
      return(status);
      }
  
    if ((status == PDM_E_PART_NOT_ASSEMBLY) || (PDU_def_assy_bufr->rows == 1))
      {
      MEMclose(&PDU_def_assy_bufr);
      PDU_def_assy_bufr = NULL;
      _pdm_debug("Part is not an assembly", 0);
      PDUmessage(PDM_I_ATOMIC_PART, 's');
      msg = (char *) PDUtranslate_message(PDM_I_ATOMIC_PART);
      FIg_set_text(forms.define_assy_form_id, FI_MSG_FIELD, msg);
      status = PDM_S_SUCCESS;
      PDUunfreeze_assy_mcf();
      }

    if (PDMdebug_on)
      MEMprint_buffer("non-graphic assembly buffer", PDU_def_assy_bufr, 
                      PDU_DEBUG_FILE);

    MEMsplit_copy_buffer(PDU_def_assy_bufr, &PDU_hold_bufr, 0);

    /* load the assembly structure into the form */
    if ((PDU_def_assy_bufr == NULL) || (PDU_def_assy_bufr ->rows < 1))
      {
      PDUmessage(PDM_I_ATOMIC_PART, 's');
      msg = (char *) PDUtranslate_message(PDM_I_ATOMIC_PART);
      FIg_set_text(forms.define_assy_form_id, FI_MSG_FIELD, msg);
      }
    else
      {
      status = PDUload_assembly_structure();
      _pdm_status("PDUload_assembly_structure", status);
      }

    /* freeze refresh area */
    PDUfreeze_assy_refresh();
    FIg_enable(forms.define_assy_form_id, SEARCH_BTN);

    FIg_enable(forms.define_assy_form_id, UPDATE);

    /* unfreeze part selection area */
    if (PDU_keyin_area == TRUE)
      {
      _pdm_debug("PDU_keyin_area = TRUE", 0);
      _pdm_debug("unfreezing PDU_keyin_area", 0);
      PDUunfreeze_assy_part_area();
      }
    }
  else
    {
    /* freeze part selection area */
    if (PDU_keyin_area == TRUE)
      PDUfreeze_assy_part_area();

    FIg_disable(forms.define_assy_form_id, UPDATE);
    FIg_disable(forms.define_assy_form_id, SEARCH_BTN);
    }

  PDUmessage(status, 's');
  return(status);
}  /* end PDUget_assembly */

int PDUfreeze_assy_refresh()
{
    _pdm_debug("in the function PDUfreeze_assy_refresh", 0);

    /* freeze refresh area */
    FIfld_set_mode(forms.define_assy_form_id, PROJECT_FIELD, 0, FI_REVIEW);
    FIfld_set_mode(forms.define_assy_form_id, CATALOG_FIELD, 0, FI_REVIEW);
    FIfld_set_mode(forms.define_assy_form_id, PARTNUM_FIELD, 0, FI_REVIEW);
    FIfld_set_mode(forms.define_assy_form_id, REVISION_FLD, 0, FI_REVIEW);

    FIg_disable(forms.define_assy_form_id, PROJECT_LIST_BTN);
    FIg_disable(forms.define_assy_form_id, CATALOG_LIST_BTN);
    FIg_disable(forms.define_assy_form_id, PARTNUM_LIST_BTN);
    FIg_disable(forms.define_assy_form_id, REVISION_LIST_BTN);

    return(PDM_S_SUCCESS);
}

int PDUunfreeze_assy_refresh()
{
    _pdm_debug("in the function PDUunfreeze_assy_refresh", 0);

    /* unfreeze refresh area */
    FIfld_set_mode(forms.define_assy_form_id, PROJECT_FIELD, 0, FI_INSERT);
    FIfld_set_mode(forms.define_assy_form_id, CATALOG_FIELD, 0, FI_INSERT);
    FIfld_set_mode(forms.define_assy_form_id, PARTNUM_FIELD, 0, FI_INSERT);
    FIfld_set_mode(forms.define_assy_form_id, REVISION_FLD, 0, FI_INSERT);

    FIg_enable(forms.define_assy_form_id, PROJECT_LIST_BTN);
    FIg_enable(forms.define_assy_form_id, CATALOG_LIST_BTN);
    FIg_enable(forms.define_assy_form_id, PARTNUM_LIST_BTN);
    FIg_enable(forms.define_assy_form_id, REVISION_LIST_BTN);

    return(PDM_S_SUCCESS);
}

int PDUget_max_level(level)
  int    *level;
{
  char   *query_string = NULL;
  char   *sort_string = NULL;
  char   *level_str = NULL;
  char   **data_row;
  MEMptr ret_bufr = NULL;
  int    status = PDM_S_SUCCESS;
  int    length;

    _pdm_debug("in the function PDUget_max_level", 0);

    if (PDU_command != PDC_M_ACTIVATE_PART)
      {
      length = strlen(refresh->rev_partid) + strlen(refresh->rev_revision) + 50;
      query_string = (char *) malloc (sizeof (char) * length);
      memset(query_string, NULL, sizeof (char) * length);

      _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
      _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
      _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);

      strcpy(query_string, "where ");
      strcat(query_string, "n_itemname =");
      strcat(query_string, " \'");
      strcat(query_string, refresh->rev_partid);
      strcat(query_string, "\' and ");
      strcat(query_string, "n_itemrev =");
      strcat(query_string, " \'");
      strcat(query_string, refresh->rev_revision);
      strcat(query_string, "\'");
      _pdm_debug("query_string = <%s>", query_string);

      PDUfill_in_string(&sort_string, "order by p_maxlevel");

      status = PDMsql_query(refresh->rev_catalog, "p_maxlevel", query_string,
                            sort_string, &ret_bufr);
      _pdm_status("PDMsql_query", status);
      }
    else
      {
      length = strlen(refresh->act_partid) + strlen(refresh->act_revision) + 50;
      query_string = (char *) malloc (sizeof (char) * length);
      memset(query_string, NULL, sizeof (char) * length);

      strcpy(query_string, "where ");
      strcat(query_string, "n_itemname =");
      strcat(query_string, " \'");
      strcat(query_string, refresh->act_partid);
      strcat(query_string, "\' and ");
      strcat(query_string, "n_itemrev =");
      strcat(query_string, " \'");
      strcat(query_string, refresh->act_revision);
      strcat(query_string, "\'");
      _pdm_debug("query_string = <%s>", query_string);

      PDUfill_in_string(&sort_string, "order by p_maxlevel");

      status = PDMsql_query(refresh->act_catalog, "p_maxlevel", query_string,
                            sort_string, &ret_bufr);
      _pdm_status("PDMsql_query", status);
      }

    if (status != PDM_S_SUCCESS)
      return(status);

    if (PDMdebug_on)
      MEMprint_buffer("max_level bufr", ret_bufr, PDU_DEBUG_FILE);

    if ((ret_bufr != NULL) && (ret_bufr->rows != 0))
      {
      MEMbuild_array(ret_bufr);
      PDUsetup_buffer(ret_bufr, ROW, &data_row);
      PDUfill_in_string(&level_str, data_row[(ret_bufr->columns * 0) + 0]);
      *level = atoi(level_str);
      _pdm_debug("max_level = %d", (char *)*level);
      }
  return(status);
}

int PDUfreeze_assy_part_area()
{
    _pdm_debug("in the function PDUfreeze_assy_part_area", 0);

    /* freeze refresh area */
    FIfld_set_mode(forms.define_assy_form_id, ASSY_CAT_FLD, 0, FI_REVIEW);
    FIfld_set_mode(forms.define_assy_form_id, ASSY_PART_FLD, 0, FI_REVIEW);
    FIfld_set_mode(forms.define_assy_form_id, ASSY_REV_FLD, 0, FI_REVIEW);
    FIfld_set_mode(forms.define_assy_form_id, ASSY_DESC_FLD, 0, FI_REVIEW);

    FIg_disable(forms.define_assy_form_id, ASSY_CAT_LIST_BTN);
    FIg_disable(forms.define_assy_form_id, ASSY_PART_LIST_BTN);
    FIg_disable(forms.define_assy_form_id, ASSY_REV_LIST_BTN);

    return(PDM_S_SUCCESS);
}

int PDUunfreeze_assy_part_area()
{
    _pdm_debug("in the function PDUunfreeze_assy_part_area", 0);

    /* unfreeze refresh area */
    FIfld_set_mode(forms.define_assy_form_id, ASSY_CAT_FLD, 0, FI_INSERT);
    FIfld_set_mode(forms.define_assy_form_id, ASSY_PART_FLD, 0, FI_INSERT);
    FIfld_set_mode(forms.define_assy_form_id, ASSY_REV_FLD, 0, FI_INSERT);
    FIfld_set_mode(forms.define_assy_form_id, ASSY_DESC_FLD, 0, FI_INSERT);

    /* redisplay fields */
    FIg_display(forms.define_assy_form_id, ASSY_CAT_FLD);
    FIg_display(forms.define_assy_form_id, ASSY_PART_FLD);
    FIg_display(forms.define_assy_form_id, ASSY_REV_FLD);
    FIg_display(forms.define_assy_form_id, ASSY_DESC_FLD);

    FIg_enable(forms.define_assy_form_id, ASSY_CAT_LIST_BTN);
    FIg_enable(forms.define_assy_form_id, ASSY_PART_LIST_BTN);
    FIg_enable(forms.define_assy_form_id, ASSY_REV_LIST_BTN);

    return(PDM_S_SUCCESS);
}

int PDUgenerate_ng_usageid(catalog, partid, revision)
  char     *catalog;
  char     *partid;
  char     *revision;
{
  char     *usageid = NULL;
  int      status = PDM_S_SUCCESS;
  int      length;
  int      instanceno;
  char     instance_str[10];
  char     tmp_usageid[MAX_VALUE];
  char     *catalogno = NULL;
  char     *itemno = NULL;
  char     *tmp_instancestr = NULL;

  _pdm_debug("in the function PDUgenerate_ng_usageid", 0);

  /* check to see if the user specified a usage id */
  status = PDMget_usageid_cat(catalog, &usageid);
  _pdm_status("PDMget_usageid_cat", status);

  if ((usageid == NULL) || (strcmp(usageid, "") == 0) ||
      (status == PDM_I_NO_USAGE_ID))
    {
    /* generate default usageid */
    _pdm_debug("generating default usage id", 0);

    length = strlen(partid) + strlen(revision) + 10;

    usageid = (char *) malloc (sizeof (char) * length);
    memset(usageid, NULL, sizeof (char) * length);

    strcpy(usageid, partid);
    strcat(usageid, " ");
    strcat(usageid, revision);

    _pdm_debug("defaulted usageid = <%s>", usageid);
    status = PDM_S_SUCCESS;
    }

  /* get the instance number */
  if (PDU_assy_head)
    {
    status = PDUfind_instanceno_in_linklist(PDU_assy_head, &usageid);
    _pdm_status("PDUfind_instanceno_in_linklist", status);
    _pdm_debug("usage id = <%s>", usageid);
    }
  else
    {
    instanceno = 1;

    _pdm_debug("instance number = %d", (char *)instanceno);

    sprintf(instance_str, "%d", instanceno);
  
    strcat(usageid, " #");
    strcat(usageid, instance_str);
  
    _pdm_debug("usageid = <%s>", usageid);
    }

  /* added by JBP for TR#139314401 */
  if (strlen(usageid) > 25)
    {
    status = PDMget_catno_partno(catalog, partid, revision, &catalogno,
                                 &itemno);
    _pdm_status("PDUget_catno_partno", status);

    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return(status);
      }

    tmp_instancestr = (char *)strrchr(usageid, '#');
    ++tmp_instancestr;
    sprintf(tmp_usageid, "%s %s #%s", catalogno, itemno, tmp_instancestr);
    PDUfill_in_string(&usageid, tmp_usageid);
    }

  PDUfill_in_string(&PDU_usage_id, usageid);

  return(status);
}

int PDUplace_ng_assembly()
{
  int      status = PDM_S_SUCCESS;
  int      row;
  int      num_rows;
  int      level_col;
  int      cat_col;
  int      part_col;
  int      rev_col;
  int      use_col;
  int      parent_col;
  int      child_col;
  int      qty_col;
  int      childno;
  int      parentno;
  int      parent_child_no;
  int      level;
  int      catalogno;
  int      itemno;
  int      explode_depth;
  char     *catalog = NULL;
  char     *partid = NULL;
  char     *revision = NULL;
  char     *attach = NULL;
  char     **data_row = NULL;

  _pdm_debug("in the function PDUplace_ng_assembly", 0);

  FIfld_get_num_rows(forms.define_assy_form_id, DEFINE_ASSY_MCF, &num_rows);

  /* set parent and level numbers */
  parentno = 0;
  level = 1;

  /* get child number of the part to be added */
  if (PDU_assy_head)
    childno = PDUfind_childno_in_linklist(PDU_assy_head);
  else
    childno = 1;
  _pdm_debug("childno = %d", (char *)childno);
  parent_child_no = childno;

/*  6-8-93 PDU_attach will always be defaulted to FALSE */
/*
  if (PDU_assy_parttype)
    {
    if ((strcmp(PDU_assy_parttype, "P") == 0) ||
        (strcmp(PDU_assy_parttype, "p") == 0) ||
        (strcmp(PDU_assy_parttype, "N") == 0) ||
        (strcmp(PDU_assy_parttype, "n") == 0))
       {
       PDU_attach = FALSE;
       _pdm_debug("setting PDU_attach to FALSE", 0);
       }
    }

  if (PDU_attach == TRUE)
    {
    _pdm_debug("PDU_attach = TRUE", 0);
    if ((PDU_assy_parttype) && (strcmp(PDU_assy_parttype, "G") != 0) &&
                               (strcmp(PDU_assy_parttype, "g") != 0) &&
                               (strcmp(PDU_assy_parttype, "N") != 0) &&
                               (strcmp(PDU_assy_parttype, "n") != 0) &&
                               (strcmp(PDU_assy_parttype, "P") != 0) &&
                               (strcmp(PDU_assy_parttype, "p") != 0) &&
                               (strcmp(PDU_assy_parttype, "M") != 0) &&
                               (strcmp(PDU_assy_parttype, "m") != 0) &&
                               (strcmp(PDU_assy_parttype, "D") != 0) &&
                               (strcmp(PDU_assy_parttype, "d") != 0))
      {
      status = PDM_E_INVALID_PART_TYPE;
      PDU_usage_id = NULL;
      PDUfill_in_string(&PDU_quantity, "1.000000");
      PDUmessage(status, 's');
      return(status);
      }

    status = PDUget_file_status(PDU_assy_catalog, PDU_assy_partid,
                                PDU_assy_revision, &state);
    _pdm_status("PDUget_file_status", status);

    if ((state) && (strcmp(state, "I") != 0))
      {
      status = PDM_E_ATTACH_CHECKIN;
      PDU_usage_id = NULL;
      PDUfill_in_string(&PDU_quantity, "1.000000");
      PDUmessage(status, 's');
      return(status);
      }
    }
*/

  /* set global values */
/*
  if (PDU_attach == TRUE)
    PDUfill_in_string(&attach, "Y");
  else
*/

  PDUfill_in_string(&attach, "N");
  _pdm_debug("PDU_quantity = <%s>", PDU_quantity);

  /* set the part info */
  _pdm_debug("setting the catalog, partid, and revision", 0);
  PDUfill_in_string(&catalog, PDU_assy_catalog);
  PDUfill_in_string(&partid, PDU_assy_partid);
  PDUfill_in_string(&revision, PDU_assy_revision);

  /* set the catalog and item numbers */
  _pdm_debug("setting the catalog and item numbers", 0);
  catalogno = 0;
  itemno = 0;

  _pdm_debug("Calling PDUadd_node_to_linklist", 0);
  _pdm_debug("level = <%d>", (char *)level);
  _pdm_debug("parent = <%d>", (char *)parentno);
  _pdm_debug("child = <%d>", (char *)childno);
  _pdm_debug("catalog = <%s>", catalog);
  _pdm_debug("partid = <%s>", partid);
  _pdm_debug("revision = <%s>", revision);
  _pdm_debug("attach = <%s>", attach);
  _pdm_debug("PDU_usage_id = <%s>", PDU_usage_id);
  _pdm_debug("tagno = <%s>", PDU_tagno);
  _pdm_debug("alttagno = <%s>", PDU_alt_tagno);
  _pdm_debug("explode = <%s>", PDU_explode_BOM);
  _pdm_debug("incbom = <%s>", PDU_incl_BOM);
  _pdm_debug("incstr = <%s>", PDU_incl_ASM);
  _pdm_debug("filename = <%s>", "");
  _pdm_debug("catalogno = <%d>", (char *)catalogno);
  _pdm_debug("itemno = <%d>", (char *)itemno);

  /* add a node to the end of the assembly linklist */
  PDUadd_node_to_linklist(level, parentno, childno, catalog, partid, revision,
                          attach, PDU_quantity, PDU_usage_id, PDU_tagno,
                          PDU_explode_BOM, "", catalogno, itemno);

  _pdm_debug("before add row usage id = <%s>", PDU_usage_id);
  /* add a row to the end of the assembly mcf */
  PDUadd_row_to_assy_mcf(forms.define_assy_form_id, DEFINE_ASSY_MCF, 
                         num_rows, level, parentno, childno, catalog, partid,
                         revision, attach, PDU_quantity, PDU_usage_id);

  _pdm_debug("PDU_explode_BOM = <%s>", PDU_explode_BOM);
  if ((PDU_explode_BOM) && (strcmp(PDU_explode_BOM, "Y") == 0) &&
      (PDU_explode_depth > 1))
    {
    _pdm_debug("getting assembly structure of part", 0);
    _pdm_debug("PDU_explode_depth = %d", (char *)PDU_explode_depth);
    explode_depth = PDU_explode_depth - 1;
    _pdm_debug("add part explode depth = %d", (char *)PDU_explode_depth);
    /* get the assembly structure of the part being added */
/*
    status = PDMget_assembly_structure(PDU_assy_catalog, PDU_assy_partid,
                           PDU_assy_revision, explode_depth, &child_bufr, 1);
    _pdm_status("PDMget_assembly_structure", status);

    if (!child_bufr)
      {
      PDUmessage(PDM_E_RETRIEVE_ASSEMBLY, 's');
      PDUfill_in_string(&PDU_quantity, "1.000000");
      PDU_usage_id = NULL;
      return(PDM_E_RETRIEVE_ASSEMBLY);
      }

    if ((status != PDM_S_SUCCESS) && (status != PDM_E_PART_NOT_ASSEMBLY))
      {
      PDUmessage(status, 's');
      PDUfill_in_string(&PDU_quantity, "1.000000");
      PDU_usage_id = NULL;
      return(status);
      }
  
    if ((status == PDM_E_PART_NOT_ASSEMBLY) || (child_bufr->rows == 1))
      {
      MEMclose(&child_bufr);
      child_bufr = NULL;
      _pdm_debug("Part is not an assembly", 0);
      status = PDM_S_SUCCESS;
      PDUmessage(status, 's');
      PDU_usage_id = NULL;
      PDUfill_in_string(&PDU_quantity, "1.000000");
      return(status);
      }
*/
  
    if (PDU_struct_bufr && (PDU_struct_bufr->rows == 1))
      {
      MEMclose(&PDU_struct_bufr);
      PDU_struct_bufr = NULL;
      _pdm_debug("Part is not an assembly", 0);
      status = PDM_S_SUCCESS;
      PDUmessage(status, 's');
      PDU_usage_id = NULL;
      PDUfill_in_string(&PDU_quantity, "1.000000");
      return(status);
      }

    if (PDMdebug_on)
      MEMprint_buffer("child assembly buffer", PDU_struct_bufr, PDU_DEBUG_FILE);
  
    /* get the column numbers in the buffer */
    MEMbuild_array(PDU_struct_bufr);
    PDUsetup_buffer(PDU_struct_bufr, ROW, &data_row);

    PDUget_buffer_col(PDU_struct_bufr, "p_level", &level_col);
    PDUget_buffer_col(PDU_struct_bufr, "p_pchildno", &parent_col);
    PDUget_buffer_col(PDU_struct_bufr, "p_childno", &child_col);
    PDUget_buffer_col(PDU_struct_bufr, "n_catalogname", &cat_col);
    PDUget_buffer_col(PDU_struct_bufr, "n_itemname", &part_col);
    PDUget_buffer_col(PDU_struct_bufr, "n_itemrev", &rev_col);
    PDUget_buffer_col(PDU_struct_bufr, "p_quantity", &qty_col);
    PDUget_buffer_col(PDU_struct_bufr, "p_usageid", &use_col);

    for (row = 1; row < PDU_struct_bufr->rows; ++row)
       {
       /* get the level number from the buffer */
       level = atoi(data_row[(PDU_struct_bufr->columns * row) + level_col]);
       PDUfill_in_string(&PDU_quantity, 
                         data_row[(PDU_struct_bufr->columns * row) + qty_col]);
       _pdm_debug("PDU_quantity = <%s>", PDU_quantity);
       
  
       _pdm_debug("setting parent number", 0);
       /* set parent and level numbers */
       if (level == 1)
         parentno = parent_child_no;
       else
         parentno = atoi(data_row[(PDU_struct_bufr->columns*row) + parent_col]);
       
       ++level;
       _pdm_debug("level = %d", (char *)level);
  
       /* get child number from the buffer */
       childno = atoi(data_row[(PDU_struct_bufr->columns * row) + child_col]);
  
       /* set the usage id */
       PDUfill_in_string(&PDU_usage_id, 
                         data_row[(PDU_struct_bufr->columns*row)+use_col]);
  
       /* set the part info */
       PDUfill_in_string(&catalog, 
                         data_row[(PDU_struct_bufr->columns * row) + cat_col]);
       PDUfill_in_string(&partid, 
                         data_row[(PDU_struct_bufr->columns * row) + part_col]);
       PDUfill_in_string(&revision,
                         data_row[(PDU_struct_bufr->columns * row) + rev_col]);
  
       _pdm_debug("Calling PDUadd_node_to_linklist", 0);
       _pdm_debug("level = <%d>", (char *)level);
       _pdm_debug("parent = <%d>", (char *)parentno);
       _pdm_debug("child = <%d>", (char *)childno);
       _pdm_debug("catalog = <%s>", catalog);
       _pdm_debug("partid = <%s>", partid);
       _pdm_debug("revision = <%s>", revision);
       _pdm_debug("attach = <%s>", attach);
       _pdm_debug("PDU_usage_id = <%s>", PDU_usage_id);
       _pdm_debug("tagno = <%s>", PDU_tagno);
       _pdm_debug("alttagno = <%s>", PDU_alt_tagno);
       _pdm_debug("explode = <%s>", PDU_explode_BOM);
       _pdm_debug("incbom = <%s>", PDU_incl_BOM);
       _pdm_debug("incstr = <%s>", PDU_incl_ASM);
       _pdm_debug("filename = <%s>", "");
       _pdm_debug("catalogno = <%d>", (char *)catalogno);
       _pdm_debug("itemno = <%d>", (char *)itemno);
  
       /* add a node to the end of the assembly linklist */
       PDUadd_node_to_linklist(level,parentno,childno,catalog, partid, revision,
                               attach, PDU_quantity, PDU_usage_id, PDU_tagno,
                               PDU_explode_BOM, "", catalogno, itemno);
  
       FIfld_get_num_rows(forms.define_assy_form_id,DEFINE_ASSY_MCF,&num_rows);
       _pdm_debug("num_rows before add row = %d", (char *)num_rows);
  
       /* add a row to the end of the assembly mcf */
       PDUadd_row_to_assy_mcf(forms.define_assy_form_id, DEFINE_ASSY_MCF, 
                            num_rows,level,parentno, childno, catalog, partid,
                            revision, attach, PDU_quantity, PDU_usage_id);
       }
    }

  _pdm_debug("PDU_act_row = %d", (char *)PDU_act_row);

  if (PDU_act_row != -1)
    {
    FImcf_set_select(forms.define_assy_form_id, DEFINE_ASSY_MCF, PDU_act_row, 
                     FALSE);
    PDU_act_row = -1;

    /* set assembly variables to NULL */
    PDU_assy_catalog = NULL_STRING;
    PDU_assy_partid = NULL_STRING;
    PDU_assy_revision = NULL_STRING;
    PDU_assy_description = NULL_STRING;

    if ((PDU_select_area == TRUE) || (PDU_keyin_area == TRUE))
      {
      /* restore part data */
      PDUrestore_assy_part_selection_area();

      if (strcmp(PDU_assy_partid, "") == 0)
        {
        FIg_disable(forms.define_assy_form_id, PLACE_BTN);
        FIg_disable(forms.define_assy_form_id, DELETE_BTN);
        }
      }
    }

  PDU_usage_id = NULL;
  PDUfill_in_string(&PDU_quantity, "1.000000");
  PDUmessage(status, 's');

  if (PDU_struct_bufr)
    {
    MEMclose(&PDU_struct_bufr);
    PDU_struct_bufr = NULL;
    }

  return(status);

}
