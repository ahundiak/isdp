#include <stdio.h>
#include <sys/stat.h>
#include <exdef.h>
#include "PDUintdef.h"
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDUforms.h"
#include "PDUstr.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUproto.h"
#include "PDUform_def.h"
#include "PDUrev_str.h"
#include "PDUstr.h"
#include "PDMmessage.h"
#include "PDUcommand.h"
#include "PDUprompt.h"
#include "PDMtypes.h"
#include "PDUstorage.h"
#include "SQL.h"
#if !defined (__sgi)
#include <unistd.h>
#endif

extern int PDMdebug_on;
extern int PDM_debug_on;
extern int PDU_sub_on_off;
extern int review_mode;
extern int PDU_childno;
extern int PDU_pchildno;
extern int PDU_explode_depth;
extern int PDU_act_row;
extern int PDU_checkout_type;
extern int PDU_command;
extern char *PDU_assy_catalog;
extern char *PDU_assy_partid;
extern char *PDU_assy_revision;
extern char *PDU_assy_parttype;
extern char *PDU_usage_id;
extern char *PDU_quantity;
extern char *PDU_tagno;
extern char *PDU_alt_tagno;
extern char *PDU_incl_BOM;
extern char *PDU_incl_ASM;
extern char *PDU_explode_BOM;
extern char *PDU_save_filename;
extern char *PDU_save_partid;
extern char *PDU_filename;
extern char PDU_attr_value[40];
extern struct PDUforms  forms;
extern struct PDUrev_assy *PDU_assy_ptr;
extern struct PDUrev_assy *PDU_save_ptr;
extern struct PDUrev_assy *current_rev_assy;
extern struct PDUrefresh *refresh;
extern struct PDUparts_list *PDU_save_part_list;
extern struct PDUparts_list *PDU_checked_out_parts;
extern struct PDUfile_list *PDU_copied_files;
extern struct PDUstorage *storage;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_dyn_value_bufr;
extern MEMptr PDU_dyn_data_bufr;
extern MEMptr PDU_dyn_attr_bufr;
extern MEMptr PDU_parm_attr_bufr;
extern MEMptr PDU_parm_data_bufr;
extern MEMptr PDU_parm_list_bufr;
extern MEMptr PDU_attr_bufr;
extern MEMptr PDU_data_bufr;
extern MEMptr PDU_list_bufr;
extern short PDU_display_dyn_attr;
extern short PDU_attach;
extern short PDU_chkout_single;
extern short PDU_read_only_file;
extern short PDU_use_suffix;
extern short PDU_os_modified;
extern short PDU_new_assembly;
extern short PDU_ng_placement;
extern Form PDU_calling_form;
extern Form PDU_form_id;

#define SUFFIX_FLD    34

#define EXLEV_COL      0
#define DISPEXT_COL    5
#define NEWLEV_COL     6
#define CAT_COL        7
#define PART_COL       8
#define REV_COL        9
#define DESC_COL      10
#define LOCFILE_COL   11
#define STGFILE_COL   12
#define DISPNEW_COL   13
#define REV_MCF       11
#define ATTR_MCF      18

/* This function converts the assembly structure buffer to a link list. */

int PDUconvert_assy_buffer_to_linklist(assy_bufr, assy_list)
  MEMptr    assy_bufr;
  struct    PDUrev_assy **assy_list;
{
  int                      status = PDM_S_SUCCESS;
  struct PDUrev_assy      *temp, *tail;
  int                      level_col;
  int                      parent_col;
  int                      child_col;
  int                      cat_col;
  int                      part_col;
  int                      rev_col;
  int                      attach_col;
  int                      use_col;
  int                      quan_col;
  int                      tag_col;
  int                      alttag_col;
  int                      catno_col;
  int                      itemno_col;
  int                      inc_col;
  int                      exp_col;
  int                      file_col;
  int                      desc_col = -1;
  int                      inc_str;
  int                      row = 0;
  int			   counter = 0;
  int			   type_col = 0;
  char                     **data_row;

  _pdm_debug("in the function PDUconvert_assy_buffer_to_linklist", 0);

  _pdm_debug("assy_bufr->rows = %d", (char *)assy_bufr->rows);

  if (assy_bufr == NULL)
    {
    _pdm_status("assembly buffer is empty!!", 0);
    return(PDM_E_NULL_BUFFER);
    }
  else
    {
    MEMbuild_array(assy_bufr);
    PDUsetup_buffer(assy_bufr, ROW, &data_row);

    PDUget_buffer_col(assy_bufr, "p_level", &level_col);
    PDUget_buffer_col(assy_bufr, "p_pchildno", &parent_col);
    PDUget_buffer_col(assy_bufr, "p_childno", &child_col);
    PDUget_buffer_col(assy_bufr, "n_catalogname", &cat_col);
    PDUget_buffer_col(assy_bufr, "n_itemname", &part_col);
    PDUget_buffer_col(assy_bufr, "n_itemrev", &rev_col);
    PDUget_buffer_col(assy_bufr, "n_itemdesc", &desc_col);
    PDUget_buffer_col(assy_bufr, "p_parttype", &type_col);
    PDUget_buffer_col(assy_bufr, "p_attached", &attach_col);
    PDUget_buffer_col(assy_bufr, "p_quantity", &quan_col);
    PDUget_buffer_col(assy_bufr, "p_usageid", &use_col);
    PDUget_buffer_col(assy_bufr, "p_tagno", &tag_col);
    PDUget_buffer_col(assy_bufr, "n_pcatalogno", &catno_col);
    PDUget_buffer_col(assy_bufr, "n_pitemno", &itemno_col);
    PDUget_buffer_col(assy_bufr, "p_alttagno", &alttag_col);
    PDUget_buffer_col(assy_bufr, "p_incbom", &inc_col);
    PDUget_buffer_col(assy_bufr, "p_incstr", &inc_str);
    PDUget_buffer_col(assy_bufr, "p_explode", &exp_col);
    PDUget_buffer_col(assy_bufr, "n_cofilename", &file_col);

    /* create the beginning node */
    temp = (struct PDUrev_assy *)malloc(sizeof(struct PDUrev_assy));
    PDU_assy_ptr = temp;
    tail = PDU_assy_ptr;

    temp->next = NULL;
    temp->ex_level = 0;
    temp->ex_catalog = NULL_STRING;
    temp->ex_partid = NULL_STRING;
    temp->ex_revision = NULL_STRING;
    temp->ex_desc = NULL_STRING;
    temp->ex_cofilename = NULL_STRING;
    temp->ex_parttype = NULL_STRING;
    temp->p_level = 1;
    temp->p_pchildno = 0;
    temp->p_childno = 0;
    temp->p_attached = NULL_STRING;
    temp->p_quantity = NULL_STRING;
    temp->p_usageid = NULL_STRING;
    temp->p_tagno = NULL_STRING;
    temp->p_alttagno = NULL_STRING;
    temp->p_incbom = NULL_STRING;
    temp->p_incstr = NULL_STRING;
    temp->p_explode = NULL_STRING;
    temp->p_history = NULL_STRING;
    temp->n_catalogno = 0;
    temp->n_itemno = 0;
    temp->new_level = 0;
    temp->new_catalog = NULL_STRING;
    temp->new_partid = NULL_STRING;
    temp->new_revision = NULL_STRING;
    temp->new_desc = NULL_STRING;
    temp->new_cofilename = NULL_STRING;
    temp->new_cifilename = NULL_STRING;
    temp->new_parttype = NULL_STRING;
    temp->new_usageid = NULL_STRING;
    strcpy(temp->delete, "");
    strcpy(temp->ems_reffile, "");
    strcpy(temp->add, "");
    strcpy(temp->display, "");
    strcpy(temp->add_db, "");
    temp->mcf_row = 0;
    temp->dyn_attr_count = 0;
    temp->dyn_attr_names = NULL;
    temp->dyn_attr_values = NULL;
    temp->ex_attr_data = NULL;
    temp->new_attr_data = NULL;

    row = 0;
    _pdm_debug("setting data for row 0", 0);
    temp->ex_level = atoi(data_row[(assy_bufr->columns * row) + level_col]);
    temp->p_pchildno = atoi(data_row[(assy_bufr->columns * row) + parent_col]);
    temp->p_childno = atoi(data_row[(assy_bufr->columns * row) + child_col]);

    /* set existing part information */
    PDUfill_in_string(&(temp->ex_catalog),
           data_row[(assy_bufr->columns * row) + cat_col]);
    PDUfill_in_string(&(temp->ex_partid),
           data_row[(assy_bufr->columns * row) + part_col]);
    PDUfill_in_string(&(temp->ex_revision),
           data_row[(assy_bufr->columns * row) + rev_col]);
    if ((refresh->rev_description) && (desc_col != -1))
      PDUfill_in_string(&(temp->ex_desc), refresh->rev_description);
    PDUfill_in_string(&(temp->ex_cofilename),
           data_row[(assy_bufr->columns * row) + file_col]);
    PDUfill_in_string(&(temp->ex_parttype),
           data_row[(assy_bufr->columns * row) + type_col]);

    /* set assembly information */
    PDUfill_in_string(&(temp->p_attached),
           data_row[(assy_bufr->columns * row) + attach_col]);
    PDUfill_in_string(&(temp->p_quantity),
           data_row[(assy_bufr->columns * row) + quan_col]);
    PDUfill_in_string(&(temp->p_tagno),
           data_row[(assy_bufr->columns * row) + tag_col]);
    PDUfill_in_string(&(temp->p_usageid),
           data_row[(assy_bufr->columns * row) + use_col]);
    PDUfill_in_string(&(temp->p_alttagno), 
           data_row[(assy_bufr->columns * row) + alttag_col]);
    PDUfill_in_string(&(temp->p_incbom), 
           data_row[(assy_bufr->columns * row) + inc_col]);
    PDUfill_in_string(&(temp->p_incstr), 
           data_row[(assy_bufr->columns * row) + inc_str]);
    PDUfill_in_string(&(temp->p_explode),
           data_row[(assy_bufr->columns * row) + exp_col]);
    PDUfill_in_string(&(temp->p_history), "");
    temp->n_catalogno = atoi(data_row[(assy_bufr->columns * row) + catno_col]);
    temp->n_itemno = atoi(data_row[(assy_bufr->columns * row) + itemno_col]);

    /* set new data fields */
    temp->new_level = temp->ex_level;
    PDUfill_in_string(&(temp->new_catalog), temp->ex_catalog);
    PDUfill_in_string(&(temp->new_partid), temp->ex_partid);
    PDUfill_in_string(&(temp->new_revision), temp->ex_revision);
    PDUfill_in_string(&(temp->new_parttype), temp->ex_parttype);
    if (desc_col != -1)
      PDUfill_in_string(&(temp->new_desc), 
           data_row[(assy_bufr->columns * row) + desc_col]);
    if (((temp->new_desc) && (strlen(temp->new_desc) == 0)) ||
        (!temp->new_desc))
      {
      if ((refresh->rev_description) && (strlen(refresh->rev_description)))
        PDUfill_in_string(&(temp->new_desc), refresh->rev_description);
      else
        PDUfill_in_string(&(temp->new_desc), "");
      }
      
    PDUfill_in_string(&(temp->new_cofilename), "");
    PDUfill_in_string(&(temp->new_cifilename), "");

    /* set default data */
    strcpy(temp->delete, "N");
    strcpy(temp->ems_reffile, "N");
    strcpy(temp->add, "N");
    strcpy(temp->display, "Y");
    strcpy(temp->add_db, "N");
    temp->mcf_row = 0;
    counter = 0;

    if (assy_bufr->rows == 2)
      if (PDM_debug_on)
        {
        if (PDU_assy_ptr != NULL)
          {
          _pdm_debug("printing assembly linklist", 0);
          PDUprint_assy_linklist(PDU_assy_ptr);
          }
        }

    for (row = 1; row < assy_bufr->rows; ++row)
       {
       /* create the next node */
       temp = (struct PDUrev_assy *)malloc(sizeof(struct PDUrev_assy));

       temp->next = NULL;
       temp->ex_level = 0;
       temp->ex_catalog = NULL_STRING;
       temp->ex_partid = NULL_STRING;
       temp->ex_revision = NULL_STRING;
       temp->ex_desc = NULL_STRING;
       temp->ex_cofilename = NULL_STRING;
       temp->ex_parttype = NULL_STRING;
       temp->p_level = 1;
       temp->p_pchildno = 0;
       temp->p_childno = 0;
       temp->p_attached = 0;
       temp->p_quantity = NULL_STRING;
       temp->p_usageid = NULL_STRING;
       temp->p_tagno = NULL_STRING;
       temp->p_alttagno = NULL_STRING;
       temp->p_incbom = NULL_STRING;
       temp->p_incstr = NULL_STRING;
       temp->p_explode = NULL_STRING;
       temp->p_history = NULL_STRING;
       temp->n_catalogno = 0;
       temp->n_itemno = 0;
       temp->new_level = 0;
       temp->new_catalog = NULL_STRING;
       temp->new_partid = NULL_STRING;
       temp->new_revision = NULL_STRING;
       temp->new_desc = NULL_STRING;
       temp->new_cofilename = NULL_STRING;
       temp->new_cifilename = NULL_STRING;
       temp->new_parttype = NULL_STRING;
       temp->new_usageid = NULL_STRING;
       strcpy(temp->delete, "");
       strcpy(temp->ems_reffile, "");
       strcpy(temp->add, "");
       strcpy(temp->display, "");
       strcpy(temp->add_db, "");
       temp->mcf_row = 0;
       temp->dyn_attr_count = 0;
       temp->dyn_attr_names = NULL;
       temp->dyn_attr_values = NULL;
       temp->ex_attr_data = NULL;
       temp->new_attr_data = NULL;

       temp->ex_level = atoi(data_row[(assy_bufr->columns * row) + level_col]);
       temp->p_pchildno = atoi(data_row[(assy_bufr->columns * row) + parent_col]);
       temp->p_childno = atoi(data_row[(assy_bufr->columns * row) + child_col]);
   
       /* set existing part information */
       PDUfill_in_string(&(temp->ex_catalog),
              data_row[(assy_bufr->columns * row) + cat_col]);
       PDUfill_in_string(&(temp->ex_partid),
              data_row[(assy_bufr->columns * row) + part_col]);
       PDUfill_in_string(&(temp->ex_revision),
              data_row[(assy_bufr->columns * row) + rev_col]);
       PDUfill_in_string(&(temp->ex_desc),
              data_row[(assy_bufr->columns * row) + desc_col]);
       PDUfill_in_string(&(temp->ex_cofilename),
              data_row[(assy_bufr->columns * row) + file_col]);
       PDUfill_in_string(&(temp->ex_parttype),
              data_row[(assy_bufr->columns * row) + type_col]);
   
       /* set assembly information */
       PDUfill_in_string(&(temp->p_attached),
              data_row[(assy_bufr->columns * row) + attach_col]);
       PDUfill_in_string(&(temp->p_quantity),
              data_row[(assy_bufr->columns * row) + quan_col]);
       PDUfill_in_string(&(temp->p_tagno),
              data_row[(assy_bufr->columns * row) + tag_col]);
       PDUfill_in_string(&(temp->p_usageid),
              data_row[(assy_bufr->columns * row) + use_col]);
       PDUfill_in_string(&(temp->p_alttagno), 
              data_row[(assy_bufr->columns * row) + alttag_col]);
       PDUfill_in_string(&(temp->p_incbom), 
              data_row[(assy_bufr->columns * row) + inc_col]);
       PDUfill_in_string(&(temp->p_incstr), 
              data_row[(assy_bufr->columns * row) + inc_str]);
       PDUfill_in_string(&(temp->p_explode),
              data_row[(assy_bufr->columns * row) + exp_col]);
       PDUfill_in_string(&(temp->p_history), "");
       temp->n_catalogno = atoi(data_row[(assy_bufr->columns * row) + catno_col]);
       temp->n_itemno = atoi(data_row[(assy_bufr->columns * row) + itemno_col]);
   
       /* set new data fields */
       temp->new_level = temp->ex_level;
       PDUfill_in_string(&(temp->new_catalog), temp->ex_catalog);
       PDUfill_in_string(&(temp->new_partid), temp->ex_partid);
       PDUfill_in_string(&(temp->new_revision), temp->ex_revision);
       PDUfill_in_string(&(temp->new_parttype), temp->ex_parttype);
       if (desc_col != -1)
         PDUfill_in_string(&(temp->new_desc),
              data_row[(assy_bufr->columns * row) + desc_col]);
       else
         PDUfill_in_string(&(temp->new_desc), "");

       PDUfill_in_string(&(temp->new_cofilename), "");
       PDUfill_in_string(&(temp->new_cifilename), "");
   
       /* set default data */
       strcpy(temp->delete, "N");
       strcpy(temp->ems_reffile, "N");
       strcpy(temp->add, "N");
       strcpy(temp->add_db, "N");

       if (temp->ex_level > 1)
         strcpy(temp->display, temp->p_incstr);
       else
         strcpy(temp->display, "Y");

       if (strcmp(temp->display, "Y") == 0)
         {
         ++counter;
         temp->mcf_row = counter;
         }
       else
         temp->mcf_row = -1;
   
       tail->next = temp;
       tail = temp;
       }
    }

  *assy_list = NULL;
  *assy_list = PDU_assy_ptr;

  if (PDM_debug_on)
    {
    if (PDU_assy_ptr != NULL)
      {
      _pdm_debug("printing global assembly linklist", 0);
      PDUprint_assy_linklist(PDU_assy_ptr);
      }
    }

  return(status);
}  /* end PDUassy_buffer_to_linklist */

/* This function prints a link list of type PDUrev_assy */

int PDUprint_assy_linklist(head)
  struct PDUrev_assy   *head;
{
  int    status = PDM_S_SUCCESS;
  FILE  *pdu_debug_file, *fopen();

  _pdm_debug("in the function PDUprint_assy_linklist", 0);

  if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
    {
    printf("Could not open debug file\n");
    return(PDM_E_OPEN_FILE);
    }

  while (head)
    {
    fprintf(pdu_debug_file, "ex_level      = %d\n", head->ex_level);
    fprintf(pdu_debug_file, "ex_catalog    = %s\n", head->ex_catalog);
    fprintf(pdu_debug_file, "ex_partid     = %s\n", head->ex_partid);
    fprintf(pdu_debug_file, "ex_revision   = %s\n", head->ex_revision);
    fprintf(pdu_debug_file, "ex_desc       = %s\n", head->ex_desc);
    fprintf(pdu_debug_file, "ex_cofilename = %s\n", head->ex_cofilename);
    fprintf(pdu_debug_file, "ex_parttype   = %s\n", head->ex_parttype);
    fprintf(pdu_debug_file, "p_level       = %d\n", head->p_level);
    fprintf(pdu_debug_file, "p_pchildno    = %d\n", head->p_pchildno);
    fprintf(pdu_debug_file, "p_childno     = %d\n", head->p_childno);
    fprintf(pdu_debug_file, "p_attached    = %s\n", head->p_attached);
    fprintf(pdu_debug_file, "p_quantity    = %s\n", head->p_quantity);
    fprintf(pdu_debug_file, "p_usageid     = %s\n", head->p_usageid);
    fprintf(pdu_debug_file, "p_tagno       = %s\n", head->p_tagno);
    fprintf(pdu_debug_file, "p_alttagno    = %s\n", head->p_alttagno);
    fprintf(pdu_debug_file, "p_incbom      = %s\n", head->p_incbom);
    fprintf(pdu_debug_file, "p_incstr      = %s\n", head->p_incstr);
    fprintf(pdu_debug_file, "p_explode     = %s\n", head->p_explode);
    fprintf(pdu_debug_file, "p_history     = %s\n", head->p_history);
    fprintf(pdu_debug_file, "n_catalogno   = %d\n", head->n_catalogno);
    fprintf(pdu_debug_file, "n_itemno      = %d\n", head->n_itemno);
    fprintf(pdu_debug_file, "new_level     = %d\n", head->new_level);
    fprintf(pdu_debug_file, "new_catalog   = %s\n", head->new_catalog);
    fprintf(pdu_debug_file, "new_partid    = %s\n", head->new_partid);
    fprintf(pdu_debug_file, "new_revision  = %s\n", head->new_revision);
    fprintf(pdu_debug_file, "new_desc      = %s\n", head->new_desc);
    fprintf(pdu_debug_file, "new_cofilename= %s\n", head->new_cofilename);
    fprintf(pdu_debug_file, "new_cifilename= %s\n", head->new_cifilename);
    fprintf(pdu_debug_file, "new_parttype  = %s\n", head->new_parttype);
    fprintf(pdu_debug_file, "new_usageid   = %s\n", head->new_usageid);
    fprintf(pdu_debug_file, "delete        = %s\n", head->delete);
    fprintf(pdu_debug_file, "ems_reffile   = %s\n", head->ems_reffile);
    fprintf(pdu_debug_file, "add           = %s\n", head->add);
    fprintf(pdu_debug_file, "display       = %s\n", head->display);
    fprintf(pdu_debug_file, "add_db        = %s\n", head->add_db);
    fprintf(pdu_debug_file, "mcf_row       = %d\n", head->mcf_row);
    fprintf(pdu_debug_file, "\n");
    head = head->next;
    }

  fclose (pdu_debug_file);
  return(status);
}  /* end PDUprint_assy_linklist */

/* This function queries the database for the files associated with each part
   in the list and adds them to the list */

int PDUadd_multiple_files_to_linklist(assy_list)
struct PDUrev_assy **assy_list;
{
  int	status = PDM_S_SUCCESS;
  int   file_col = 0;
  int   row = 0;
  char  *temp_filename = NULL;
  char  **data_row;
  struct PDUrev_assy	*temp = NULL;
  struct PDUrev_assy	*current_list = NULL;
  MEMptr file_buffer = NULL;

  _pdm_debug("in the function PDUadd_multiple_files_to_linklist", 0);

  if (!*assy_list)
    {
    _pdm_debug("linklist is empty", 0);
    return(PDM_E_NULL_ASSY_LIST);
    }

  *assy_list = PDU_assy_ptr;

  temp = *assy_list;
  current_list = *assy_list;

  while (current_list)
    {
    if (strcmp(current_list->display, "Y") == 0)
      {
      _pdm_debug("resetting file_buffer", 0);
      if (file_buffer)
        {
        MEMclose(&file_buffer);
        file_buffer = NULL;
        }
  
      status = PDMget_filenames(	current_list->ex_catalog,
				  	current_list->ex_partid,
				  	current_list->ex_revision,
				  	&file_buffer);
      _pdm_status("PDMget_filenames", status);
  
      if (!file_buffer)
        {
        current_list = current_list->next;
        continue;
        }
  
      if ((file_buffer->rows < 2) && (current_list->ex_level == 0))
        {
        current_list = current_list->next;
        continue;
        }
      else if ((file_buffer->rows < 1) && (current_list->ex_level != 0))
        {
        current_list = current_list->next;
        continue;
        }
  
      status = MEMbuild_array(file_buffer);
      _pdm_status("MEMbuild_array", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_BUILD_BUFFER_ARRAY);
      PDUsetup_buffer(file_buffer, ROW, &data_row);
  
      status = PDUget_buffer_col(file_buffer, "n_cofilename", &file_col);
      _pdm_status("PDUget_buffer_col", status);
      if (status != PDM_S_SUCCESS)
        {
        MEMclose(&file_buffer);
        file_buffer = NULL;
        return(status);
        }
  
      _pdm_debug("part has %d files", (char *)(file_buffer->rows));
      
      for (row = 0; row < file_buffer->rows; ++row)
         {
         PDUfill_in_string(&temp_filename, 
                           data_row[(file_buffer->columns * row) + file_col]);

         _pdm_debug("row = %d", (char *)row);
         _pdm_debug("level = %d", (char *)current_list->ex_level);

         if ((row == 0) && (current_list->ex_level != 0))
           {
           _pdm_debug("writing first filename <%s> for child", temp_filename);
           PDUfill_in_string(&(current_list->ex_cofilename), temp_filename);
           }

         else if (((current_list->ex_level == 0) && 
                  (temp_filename) && (current_list->ex_cofilename) && 
                  (strcmp(temp_filename, current_list->ex_cofilename) != 0)) ||
                  ((row > 0) && (current_list->ex_level != 0) &&
                                (current_list->ex_level != -1)))
           {
           _pdm_debug("adding file <%s> to link list", temp_filename);
           temp = (struct PDUrev_assy *)malloc(sizeof(struct PDUrev_assy));

           _pdm_debug("initializing data fields", 0);
           temp->next = NULL;
           temp->ex_level = -1;
           temp->ex_catalog = NULL_STRING;
           temp->ex_partid = NULL_STRING;
           temp->ex_revision = NULL_STRING;
           temp->ex_desc = NULL_STRING;
           temp->ex_cofilename = NULL_STRING;
           temp->ex_parttype = NULL_STRING;
           temp->p_level = 1;
           temp->p_pchildno = -1;
           temp->p_childno = -1;
           temp->p_attached = NULL_STRING;
           temp->p_quantity = NULL_STRING;
           temp->p_usageid = NULL_STRING;
           temp->p_tagno = NULL_STRING;
           temp->p_alttagno = NULL_STRING;
           temp->p_incbom = NULL_STRING;
           temp->p_incstr = NULL_STRING;
           temp->p_explode = NULL_STRING;
           temp->p_history = NULL_STRING;
           temp->n_catalogno = 0;
           temp->n_itemno = 0;
           temp->new_level = -1;
           temp->new_catalog = NULL_STRING;
           temp->new_partid = NULL_STRING;
           temp->new_revision = NULL_STRING;
           temp->new_desc = NULL_STRING;
           temp->new_cofilename = NULL_STRING;
           temp->new_cifilename = NULL_STRING;
           temp->new_parttype = NULL_STRING;
           temp->new_usageid = NULL_STRING;
           strcpy(temp->delete, "N");
           strcpy(temp->ems_reffile, "N");
           strcpy(temp->add, "N");
           strcpy(temp->display, "Y");
           strcpy(temp->add_db, "N");
           temp->mcf_row = 0;
           temp->dyn_attr_count = 0;
           temp->dyn_attr_names = NULL;
           temp->dyn_attr_values = NULL;
           temp->ex_attr_data = NULL;
           temp->new_attr_data =  NULL;

           _pdm_debug("writing to data fields", 0);
           PDUfill_in_string(&(temp->ex_catalog), current_list->ex_catalog);
           PDUfill_in_string(&(temp->ex_partid), current_list->ex_partid);
           PDUfill_in_string(&(temp->ex_revision), current_list->ex_revision);
           PDUfill_in_string(&(temp->ex_cofilename), temp_filename);
           strcpy(temp->delete, "N");
           strcpy(temp->ems_reffile, "N");
           strcpy(temp->add, "N");
           strcpy(temp->display, "Y");
           strcpy(temp->add_db, "N");
           temp->mcf_row = -1;

           /* connect the temp node to the link list */
           if (!current_list->next)  /* this is the last node in the list */
             {
             current_list->next = temp;
             current_list = current_list->next;
             }
           else
             {
             temp->next = current_list->next;
             current_list->next = temp;
             current_list = current_list->next;
             }
           }
         }

      /* move pointer to the next row with data */
      current_list = current_list->next;

      }  /* end display */
    else
      {
      current_list = current_list->next;
      }
    }   /* end while */

  *assy_list = PDU_assy_ptr;
  current_list = PDU_assy_ptr;

  if (PDMdebug_on)
    {
    _pdm_debug("printing PDU_assy_ptr", 0);
    PDUprint_assy_linklist(PDU_assy_ptr);
    }

  _pdm_debug("closing filename buffer", 0);
  if (file_buffer)
    MEMclose(&file_buffer);

  if (temp_filename)
    free(temp_filename);
  
  _pdm_debug("resetting MCF row pointers", 0);
  status = PDUreset_assy_mcf_row_pointers();
  _pdm_status("PDUreset_assy_mcf_row_pointers", status);

  *assy_list = PDU_assy_ptr;

  if (PDMdebug_on)
    {
    _pdm_debug("printing PDU_assy_ptr", 0);
    PDUprint_assy_linklist(PDU_assy_ptr);
    }

  return(PDM_S_SUCCESS);
}

/* This function sorts through the link list and reset the mcf_row entry for
   each node in the list.  This is necessary anytime after a row is added to
   or deleted from the form. */

int PDUreset_assy_mcf_row_pointers()
{
  int    counter = 0;
  struct PDUrev_assy *current_list = NULL;

  if (!PDU_assy_ptr)
    {
    _pdm_debug("linklist is empty", 0);
    return(PDM_E_NULL_ASSY_LIST);
    }

  current_list = PDU_assy_ptr;

  _pdm_debug("in the function PDUreset_assy_mcf_row_pointers", 0);

  while (current_list)
    {
    if (strcmp(current_list->display, "Y") == 0)
      {
      current_list->mcf_row = counter;
      ++counter;
      }
    else
      current_list->mcf_row = -1;
    current_list = current_list->next;
    }

  return(PDM_S_SUCCESS);
}

/* This function searches through the link list and loads all parts that are
   marked with "display = Y" on the revise assembly form.  When writing the 
   file name, the file suffix is added to the previous filename, if specified 
   by the user.  The database is queried for the checkin file name */

int PDUload_revise_assembly_form(assy_list, form, field)
  struct PDUrev_assy *assy_list;
  Form	 form;
  int    field;
{

  int   row = 0;
  int   select, pos, length;
  static char *suffix = NULL;
  char  *filename = NULL;
  char  temp_string[5];
  char  newfile[15];
  int   status = PDM_S_SUCCESS;
  int   level = 0;
  MEMptr file_bufr = NULL;

  _pdm_debug("in the function PDUload_revise_assembly_form", 0);

  if (!assy_list)
    {
    _pdm_debug("assy_list is NULL", 0);
    return(PDM_E_NULL_ASSY_LIST);
    }

  PDUmessage(PDS_M_LOADING_PARTS, 's');

  if (PDMdebug_on)
    {
    _pdm_debug("printing assy_list", 0);
    PDUprint_assy_linklist(assy_list);
    }

  if (PDU_use_suffix)
    {
    FIfld_get_text_length(form, SUFFIX_FLD, 0, 0, &length);
    suffix = (char *) malloc (sizeof (char) * length + 1);
    memset(suffix, NULL, sizeof (char) * length + 1);
    FIfld_get_text(form, SUFFIX_FLD, 0, 0, length,
                  (unsigned char *)suffix, &select, &pos);
    }
  else
    PDUfill_in_string(&suffix, NULL_STRING);

  _pdm_debug("suffix = <%s>", suffix);

  while (assy_list)
    {
    if (strcmp(assy_list->display, "Y") != 0)
      {
      assy_list = assy_list->next;
      continue;
      }

    _pdm_debug("setting text on row %d", (char *)row);
    if ((row == 0) || (level == 0))
      {
      if (assy_list->ex_level != -1)
        {
        sprintf(temp_string, "%d", (assy_list->ex_level));
        _pdm_debug("ex_level = %d", (char *)temp_string);
        FIfld_set_text(form, field, row, 0, temp_string, FALSE);

        _pdm_debug("freeing file_bufr", 0);
        if (file_bufr)
          {
          MEMclose(&file_bufr);
          file_bufr = NULL;
          }

        FIfld_set_text(form, field, row, 1, assy_list->ex_catalog,    FALSE);
        FIfld_set_text(form, field, row, 2, assy_list->ex_partid,     FALSE);
        FIfld_set_text(form, field, row, 3, assy_list->ex_revision,   FALSE);
        }

      FIfld_set_text(form, field, row, 4, assy_list->ex_cofilename, FALSE);

      if (assy_list->new_level != -1)
        {
        sprintf(temp_string, "%d", (assy_list->new_level));
        _pdm_debug("new_level = %d", (char *)temp_string);
        FIfld_set_text(form,field, row, 6, temp_string, FALSE);
        FIfld_set_text(form,field, row, CAT_COL, assy_list->new_catalog, FALSE);
        FIfld_set_text(form,field, row, PART_COL, assy_list->new_partid, FALSE);
        FIfld_set_text(form,field, row, REV_COL, "", FALSE); 	/* revision */
        FIfld_set_text(form,field, row, DESC_COL, assy_list->new_desc, FALSE);
        }

      /* add the suffix for new_filename */
      _pdm_debug("adding suffix to cofilename filename", 0);
      if ((PDU_use_suffix) && (suffix) && (strlen(suffix)) &&
          (assy_list->ex_cofilename) && (strlen(assy_list->ex_cofilename)))
        {
        status = PDUappend_file_suffix(assy_list->ex_cofilename, 
                                       suffix, newfile);
        _pdm_status("PDUappend_file_suffix", status);
        _pdm_debug("new filename = <%s>", newfile);
        PDUfill_in_string(&(assy_list->new_cofilename), newfile);
        }
      else
        {
        _pdm_debug("file will not have a suffix", 0);
        PDUfill_in_string(&(assy_list->new_cofilename), 
                          assy_list->ex_cofilename);
        }

      FIfld_set_text(form, field, row, LOCFILE_COL, 
                     assy_list->new_cofilename, FALSE);

      /* get the storage area filename */
      _pdm_debug("getting storage area filename", 0);
      status = PDUget_storage_filename(	(assy_list->ex_catalog),
					(assy_list->ex_partid),
					(assy_list->ex_revision),
					(assy_list->ex_cofilename),
                                        &file_bufr,
					&filename);
      _pdm_status("PDUget_storage_filename", status);

      if (status != PDM_S_SUCCESS)
        PDUfill_in_string(&filename, NULL_STRING);

      /* append suffix to storage area filename */
      if ((PDU_use_suffix) && (filename) && (strlen(filename)))
        {
        _pdm_debug("adding suffix to cifilename filename", 0);
        if ((suffix) && (strlen(suffix)))
          {
          status = PDUappend_file_suffix(filename, suffix, newfile);
          _pdm_status("PDUappend_file_suffix", status);
          _pdm_debug("new filename = <%s>", newfile);
          PDUfill_in_string(&(assy_list->new_cifilename), newfile);
          }
        else
          {
          _pdm_debug("file will not have a suffix", 0);
          PDUfill_in_string(&(assy_list->new_cifilename), filename);
          }
        FIfld_set_text(form, field, row, STGFILE_COL, 
                       assy_list->new_cifilename, FALSE);
        }
      else
        FIfld_set_text(form, field, row, STGFILE_COL, NULL_STRING, FALSE);
      }
    else
      {
      level = 1;
      if (assy_list->ex_level != -1)
        {
        sprintf(temp_string, "%d", (assy_list->ex_level));
        FIfld_set_text(form, field, row, 0, temp_string, FALSE);
        FIfld_set_text(form, field, row, 1, (assy_list->ex_catalog), FALSE);
        FIfld_set_text(form, field, row, 2, (assy_list->ex_partid), FALSE);
        FIfld_set_text(form, field, row, 3, (assy_list->ex_revision), FALSE);
        }
      FIfld_set_text(form, field, row, 4, (assy_list->ex_cofilename), FALSE);

      if (assy_list->new_level != -1)
        {
        sprintf(temp_string, "%d", (assy_list->new_level));
        FIfld_set_text(form,field,row, 6, temp_string,FALSE);
        FIfld_set_text(form,field,row, CAT_COL, assy_list->new_catalog, FALSE);
        FIfld_set_text(form,field,row, PART_COL, assy_list->new_partid, FALSE);
        FIfld_set_text(form,field,row, REV_COL, assy_list->new_revision, FALSE);
        FIfld_set_text(form,field,row, DESC_COL, assy_list->new_desc, FALSE);
        }
      }

    ++row;
    assy_list = assy_list->next;
    if ((assy_list) && (assy_list->ex_level == 1))
      level = 1;
    }

  FIfld_set_num_rows(form, field, row);

  return(PDM_S_SUCCESS);
}

/* This function frees a link list of structures of type PDUrev_assy */

int PDUfree_assy_linklist(assy_list)
  struct PDUrev_assy  **assy_list;
{
  struct PDUrev_assy * head = NULL;
  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUfree_assy_linklist", 0);

  if (*assy_list)
    {
    _pdm_debug("setting head", 0);
    head = *assy_list;

    _pdm_debug("entering while loop", 0);
    while ((*assy_list)->next)
      {
      *assy_list = (*assy_list)->next;
      if ((*assy_list)->ex_attr_data)
        {
        _pdm_debug("freeing ex_attr buffers", 0);
        free_attr_data_buffer(&(*assy_list)->ex_attr_data);
        (*assy_list)->ex_attr_data = NULL;
        }
      if ((*assy_list)->new_attr_data)
        {
        _pdm_debug("freeing new_attr buffers", 0);
        free_attr_data_buffer(&(*assy_list)->new_attr_data);
        (*assy_list)->new_attr_data = NULL;
        }
      if ((*assy_list)->dyn_attr_count > 0)
        {
        _pdm_debug("freeing dynamic attributes", 0);
        if ((*assy_list)->dyn_attr_names)
          PDUfree_string_array(&((*assy_list)->dyn_attr_names), 
                                 (*assy_list)->dyn_attr_count);
        if ((*assy_list)->dyn_attr_values)
          PDUfree_string_array(&((*assy_list)->dyn_attr_values),
                                 (*assy_list)->dyn_attr_count);
        }

      /* free the current node in the list */
      _pdm_debug("freeing head", 0);
      free(head);

      /* reset the pointer */
      _pdm_debug("resetting pointer", 0);
      head = *assy_list;
      }

    _pdm_debug("setting assy_list to NULL", 0);
    if ((*assy_list)->ex_attr_data)
      {
      _pdm_debug("freeing ex_attr buffers", 0);
      free_attr_data_buffer(&(*assy_list)->ex_attr_data);
      (*assy_list)->ex_attr_data = NULL;
      }
    if ((*assy_list)->new_attr_data)
      {
      _pdm_debug("freeing new_attr buffers", 0);
      free_attr_data_buffer(&(*assy_list)->new_attr_data);
      (*assy_list)->new_attr_data = NULL;
      }
    if ((*assy_list)->dyn_attr_count > 0)
      {
      _pdm_debug("freeing dynamic attributes", 0);
      if ((*assy_list)->dyn_attr_names)
        PDUfree_string_array(&((*assy_list)->dyn_attr_names), 
                               (*assy_list)->dyn_attr_count);
      if ((*assy_list)->dyn_attr_values)
        PDUfree_string_array(&((*assy_list)->dyn_attr_values),
                               (*assy_list)->dyn_attr_count);
      }

    *assy_list = NULL;
    }
  else
    status = PDM_E_NULL_ASSY_LIST;

  return(status);
}

/* This function searches through the link list and queries for the file status
   of each part.  If any part is not checked in, an error message is returned.
*/

int PDUcheck_file_status_for_assy_linklist(assy_list)
struct PDUrev_assy *assy_list;
{
  int	status = PDM_S_SUCCESS;
  char  *state = NULL;
  struct PDUrev_assy	*current_list = NULL;

  _pdm_debug("in the function PDUcheck_file_status_for_assy_linklist", 0);

  if (!assy_list)
    {
    _pdm_debug("linklist is empty", 0);
    return(PDM_E_NULL_ASSY_LIST);
    }

  current_list = assy_list;

  current_list = current_list->next;

  while (current_list)
    {
      /* skip rows that just contain a filename */
      if ((current_list->ex_level == -1) || 
          (strcmp(current_list->display, "N") == 0))
        {
        current_list = current_list->next;
        continue;
        }

      _pdm_debug("catalog = <%s>", current_list->ex_catalog);
      _pdm_debug("partid = <%s>", current_list->ex_partid);
      _pdm_debug("revision = <%s>", current_list->ex_revision);

      status = PDUget_file_status(	current_list->ex_catalog,
				  	current_list->ex_partid,
				  	current_list->ex_revision,
				  	&state);
      _pdm_status("PDUget_file_status", status);

      _pdm_debug("state = <%s>", state);

      if ((state) && (strcmp(state, "I") != 0) && (strcmp(state, "") != 0))
        {
        PDUdisplay_status(PDM_I_PART_CHECKIN, forms.rev_assy_form_id);
        return(PDM_I_PART_CHECKIN);
        }
  
      /* move pointer to the next row with data */
      current_list = current_list->next;

    }   /* end while */

  if (state)
    free(state);

  return(PDM_S_SUCCESS);
}

/* This function adds a blank row beneath the row that is passed in.  An empty
   node is initialized to the linklist */

int PDUadd_blank_row_to_linklist(assy_list, row, level)
  struct PDUrev_assy **assy_list;
  int    row;
  int    level;
{
  int	 status = PDM_S_SUCCESS;
  struct PDUrev_assy *current_list = NULL;
  struct PDUrev_assy *temp = NULL;
  char   *msg = NULL;

  _pdm_debug("in the function PDUadd_blank_row_to_linklist", 0);

  if (!assy_list)
    {
    _pdm_debug("linklist is empty", 0);
    return(PDM_E_NULL_ASSY_LIST);
    }

  *assy_list = PDU_assy_ptr;

  current_list = *assy_list;

  _pdm_debug("row to insert = %d", (char *)row);

  while (current_list)
    {
    _pdm_debug("current_list->mcf_row = %d", (char *)current_list->mcf_row);
    if (current_list->mcf_row == (row - 1))
      {
      _pdm_debug("adding node to link list", 0);
      temp = (struct PDUrev_assy *)malloc(sizeof(struct PDUrev_assy));
 
      _pdm_debug("initializing data fields", 0);
      temp->next = NULL;
      temp->ex_level = level;
      temp->ex_catalog = NULL;
      temp->ex_partid = NULL;
      temp->ex_revision = NULL;
      temp->ex_desc = NULL;
      temp->ex_cofilename = NULL_STRING;
      temp->ex_parttype = NULL_STRING;
      temp->p_level = 1;
      temp->p_pchildno = -1;
      temp->p_childno = -1;
      temp->p_attached = NULL_STRING;
      temp->p_quantity = NULL_STRING;
      temp->p_usageid = NULL_STRING;
      temp->p_tagno = NULL_STRING;
      temp->p_alttagno = NULL_STRING;
      temp->p_incbom = NULL_STRING;
      temp->p_incstr = NULL_STRING;
      temp->p_explode = NULL_STRING;
      temp->p_history = NULL_STRING;
      temp->n_catalogno = 0;
      temp->n_itemno = 0;
      temp->new_level = level;
      temp->new_catalog = NULL_STRING;
      temp->new_partid = NULL_STRING;
      temp->new_revision = NULL_STRING;
      temp->new_desc = NULL_STRING;
      temp->new_cofilename = NULL_STRING;
      temp->new_cifilename = NULL_STRING;
      temp->new_parttype = NULL_STRING;
      temp->new_usageid = NULL_STRING;
      _pdm_debug("setting default values", 0);
      strcpy(temp->delete, "");
      strcpy(temp->ems_reffile, "");
      strcpy(temp->add, "");
      strcpy(temp->display, "");
      strcpy(temp->add_db, "");
      temp->dyn_attr_count = 0;
      temp->dyn_attr_names = NULL;
      temp->dyn_attr_values = NULL;
      _pdm_debug("setting buffers", 0);
      temp->ex_attr_data =  NULL;
      temp->new_attr_data = NULL;
 
      _pdm_debug("writing to data fields", 0);
      msg = (char *) PDUtranslate_message(PDM_I_ADDED_ROW);
      PDUfill_in_string(&(temp->ex_catalog), msg);
      PDUfill_in_string(&(temp->ex_partid), msg);
      PDUfill_in_string(&(temp->ex_revision), msg);
      PDUfill_in_string(&(temp->ex_desc), msg);
      PDUfill_in_string(&(temp->p_quantity), PDU_quantity);

      if ((PDU_incl_BOM) && (strcmp(PDU_incl_BOM, "Y") != 0) &&
                            (strcmp(PDU_incl_BOM, "N") != 0))
        {
        _pdm_debug("PDU_incl_BOM has invalid value, resetting to Y", 0);
        PDUfill_in_string(&PDU_incl_BOM, "Y");
        }
      else if ((!PDU_incl_BOM) || ((PDU_incl_BOM) && (!strlen(PDU_incl_BOM))))
        {
        _pdm_debug("PDU_incl_BOM is NULL or EMPTY, resetting to Y", 0);
        PDUfill_in_string(&PDU_incl_BOM, "Y");
        }

      PDUfill_in_string(&(temp->p_incbom), PDU_incl_BOM);
      PDUfill_in_string(&(temp->p_incstr), PDU_incl_ASM);
      PDUfill_in_string(&(temp->p_explode), PDU_explode_BOM);
      if (PDU_attach)
        PDUfill_in_string(&(temp->p_attached), "Y");
      else
        PDUfill_in_string(&(temp->p_attached), "N");
      if ((PDU_usage_id) && (strlen(PDU_usage_id)))
        PDUfill_in_string(&(temp->new_usageid), PDU_usage_id);
      strcpy(temp->delete, "N");
      strcpy(temp->ems_reffile, "N");
      strcpy(temp->add, "Y");
      strcpy(temp->display, "Y");
      strcpy(temp->add_db, "N");
      temp->mcf_row = row;
      temp->dyn_attr_count = 0;
      temp->dyn_attr_names = NULL;
      temp->dyn_attr_values = NULL;

      /* connect the temp node to the link list */
      if (!current_list->next)  /* this is the last node in the list */
        {
        current_list->next = temp;
        current_list = current_list->next;
        }
      else
        {
        temp->next = current_list->next;
        current_list->next = temp;
        current_list = current_list->next;
        }
      break;
      }
    else
      current_list = current_list->next;
    }

  
  *assy_list = PDU_assy_ptr;
  current_list = PDU_assy_ptr;

  _pdm_debug("resetting MCF row pointers", 0);
  status = PDUreset_assy_mcf_row_pointers();
  _pdm_status("PDUreset_assy_mcf_row_pointers", status);

  *assy_list = PDU_assy_ptr;

  if (PDMdebug_on)
    {
    _pdm_debug("printing PDU_assy_ptr", 0);
    PDUprint_assy_linklist(PDU_assy_ptr);
    }

  return(PDM_S_SUCCESS);
}

/* This function appends a suffix to the filename that is passed in and passes
   it back to the calling function.  If the new filename exceeds 14 chars, the
   filename is passed back as an empty string. */

PDUappend_file_suffix(oldfile, suffix, newfile)
char  *oldfile;
char  *suffix;
char  newfile[15];
{
  short found = FALSE;
  int 	index = 0;
  int   i = 0;

  _pdm_debug("In the function PDUappend_file_suffix", 0);

  _pdm_debug("filename = <%s>", oldfile);

  if ((oldfile) && (suffix) && ((strlen(oldfile)) + (strlen(suffix))) > 14)
    {
    _pdm_debug("filename is too long; not adding suffix", 0);
    strcpy(newfile, NULL_STRING);
    _pdm_debug("filename = <%s>", newfile);
    }
  else
    {
    index = 0;
    while (oldfile[index] != '\0')
      {
      if (oldfile[index] == '.')
        {
        _pdm_debug("filename has a <.> suffix", 0);
        strncpy(newfile, oldfile, index);
        newfile[index] = '\0';
        _pdm_debug("newfile = <%s>", newfile);
        strcat(newfile, suffix);
        _pdm_debug("newfile after adding default suffix = <%s>", newfile);
        
        for (i = 0; i < index; ++i)
          oldfile = oldfile + 1;
        _pdm_debug("existing suffix  = <%s>", oldfile);

        strcat(newfile, oldfile);
        _pdm_debug("newfile after adding existing suffix = <%s>", newfile);

        found = TRUE;
        break;
        }
      ++index;
      }

    if (!found)
      {
      strcpy(newfile, oldfile);
      strcat(newfile, suffix);
      }

    _pdm_debug("newfile = <%s>", newfile);
    }

  return(PDM_S_SUCCESS);
}

/* This function creates and exact copy of the link list that is passed in */

int PDUcopy_assy_linklist(assy_list, copy_list, backup)
  struct    PDUrev_assy  *assy_list;
  struct    PDUrev_assy **copy_list;
  short     backup;    /* 1 = backup, 0 = restore */
{
  int                      status = PDM_S_SUCCESS;
  struct PDUrev_assy      *temp, *tail;

  _pdm_debug("in the function PDUcopy_assy_linklist", 0);

  if (!assy_list)
    {
    _pdm_status("assembly buffer is empty!!", 0);
    return(PDM_E_NULL_ASSY_LIST);
    }

    /* create the beginning node */
    temp = (struct PDUrev_assy *)malloc(sizeof(struct PDUrev_assy));
    if (backup)
      {
      PDU_save_ptr = temp;
      tail = PDU_save_ptr;
      }
    else
      {
      PDU_assy_ptr = temp;
      tail = PDU_assy_ptr;
      }

    temp->next = NULL;
    temp->ex_level = 0;
    temp->ex_catalog = NULL_STRING;
    temp->ex_partid = NULL_STRING;
    temp->ex_revision = NULL_STRING;
    temp->ex_desc = NULL_STRING;
    temp->ex_cofilename = NULL_STRING;
    temp->ex_parttype = NULL_STRING;
    temp->p_level = 1;
    temp->p_pchildno = 0;
    temp->p_childno = 0;
    temp->p_attached = NULL_STRING;
    temp->p_quantity = NULL_STRING;
    temp->p_usageid = NULL_STRING;
    temp->p_tagno = NULL_STRING;
    temp->p_alttagno = NULL_STRING;
    temp->p_incbom = NULL_STRING;
    temp->p_incstr = NULL_STRING;
    temp->p_explode = NULL_STRING;
    temp->p_history = NULL_STRING;
    temp->n_catalogno = 0;
    temp->n_itemno = 0;
    temp->new_level = 0;
    temp->new_catalog = NULL_STRING;
    temp->new_partid = NULL_STRING;
    temp->new_revision = NULL_STRING;
    temp->new_desc = NULL_STRING;
    temp->new_cofilename = NULL_STRING;
    temp->new_cifilename = NULL_STRING;
    temp->new_parttype = NULL_STRING;
    temp->new_usageid = NULL_STRING;
    strcpy(temp->delete, "");
    strcpy(temp->ems_reffile, "");
    strcpy(temp->add, "");
    strcpy(temp->display, "");
    strcpy(temp->add_db, "");
    temp->mcf_row = 0;
    temp->dyn_attr_count = 0;
    temp->dyn_attr_names = NULL;
    temp->dyn_attr_values = NULL;
    temp->ex_attr_data = NULL;
    temp->new_attr_data = NULL;

    _pdm_debug("writing data for first node", 0);
    temp->ex_level = assy_list->ex_level;
    temp->p_pchildno = assy_list->p_pchildno;
    temp->p_childno = assy_list->p_childno;
    PDUfill_in_string(&(temp->ex_catalog), assy_list->ex_catalog);
    PDUfill_in_string(&(temp->ex_partid), assy_list->ex_partid);
    PDUfill_in_string(&(temp->ex_revision), assy_list->ex_revision);
    PDUfill_in_string(&(temp->ex_desc), assy_list->ex_desc);
    PDUfill_in_string(&(temp->ex_cofilename), assy_list->ex_cofilename);
    PDUfill_in_string(&(temp->ex_parttype), assy_list->ex_parttype);
    PDUfill_in_string(&(temp->p_attached), assy_list->p_attached);
    PDUfill_in_string(&(temp->p_quantity), assy_list->p_quantity);
    PDUfill_in_string(&(temp->p_tagno), assy_list->p_tagno);
    PDUfill_in_string(&(temp->p_usageid), assy_list->p_usageid);
    PDUfill_in_string(&(temp->p_alttagno), assy_list->p_alttagno);
    PDUfill_in_string(&(temp->p_incbom), assy_list->p_incbom);
    PDUfill_in_string(&(temp->p_incstr), assy_list->p_incstr);
    PDUfill_in_string(&(temp->p_explode), assy_list->p_explode);
    PDUfill_in_string(&(temp->p_history), assy_list->p_history);
    temp->n_catalogno =  assy_list->n_catalogno;
    temp->n_itemno =  assy_list->n_itemno;
    temp->new_level =  assy_list->new_level;
    PDUfill_in_string(&(temp->new_catalog), assy_list->new_catalog);
    PDUfill_in_string(&(temp->new_partid), assy_list->new_partid);
    PDUfill_in_string(&(temp->new_revision), assy_list->new_revision);
    PDUfill_in_string(&(temp->new_desc), assy_list->new_desc);
    PDUfill_in_string(&(temp->new_cofilename), assy_list->new_cofilename);
    PDUfill_in_string(&(temp->new_cifilename), assy_list->new_cifilename);
    PDUfill_in_string(&(temp->new_parttype), assy_list->new_parttype);
    PDUfill_in_string(&(temp->new_usageid), assy_list->new_usageid);
    strcpy(temp->delete, assy_list->delete);
    strcpy(temp->ems_reffile, assy_list->ems_reffile);
    strcpy(temp->add, assy_list->add);
    strcpy(temp->display, assy_list->display);
    strcpy(temp->add_db, assy_list->add_db);
    temp->mcf_row = assy_list->mcf_row;

    assy_list = assy_list->next;

    while (assy_list)
       {
       /* create the beginning node */
       temp = (struct PDUrev_assy *)malloc(sizeof(struct PDUrev_assy));

       temp->next = NULL;
       temp->ex_level = 0;
       temp->ex_catalog = NULL_STRING;
       temp->ex_partid = NULL_STRING;
       temp->ex_revision = NULL_STRING;
       temp->ex_desc = NULL_STRING;
       temp->ex_cofilename = NULL_STRING;
       temp->ex_parttype = NULL_STRING;
       temp->p_level = 1;
       temp->p_pchildno = 0;
       temp->p_childno = 0;
       temp->p_attached = NULL_STRING;
       temp->p_quantity = NULL_STRING;
       temp->p_usageid = NULL_STRING;
       temp->p_tagno = NULL_STRING;
       temp->p_alttagno = NULL_STRING;
       temp->p_incbom = NULL_STRING;
       temp->p_incstr = NULL_STRING;
       temp->p_explode = NULL_STRING;
       temp->p_history = NULL_STRING;
       temp->n_catalogno = 0;
       temp->n_itemno = 0;
       temp->new_level = 0;
       temp->new_catalog = NULL_STRING;
       temp->new_partid = NULL_STRING;
       temp->new_revision = NULL_STRING;
       temp->new_desc = NULL_STRING;
       temp->new_cofilename = NULL_STRING;
       temp->new_cifilename = NULL_STRING;
       temp->new_parttype = NULL_STRING;
       temp->new_usageid = NULL_STRING;
       strcpy(temp->delete, "");
       strcpy(temp->ems_reffile, "");
       strcpy(temp->add, "");
       strcpy(temp->display, "");
       strcpy(temp->add_db, "");
       temp->mcf_row = 0;
       temp->dyn_attr_count = 0;
       temp->dyn_attr_names = NULL;
       temp->dyn_attr_values = NULL;
       temp->ex_attr_data = NULL;
       temp->new_attr_data = NULL;

       _pdm_debug("writing data for next node", 0);
       temp->ex_level = assy_list->ex_level;
       temp->p_pchildno = assy_list->p_pchildno;
       temp->p_childno = assy_list->p_childno;
       PDUfill_in_string(&(temp->ex_catalog), assy_list->ex_catalog);
       PDUfill_in_string(&(temp->ex_partid), assy_list->ex_partid);
       PDUfill_in_string(&(temp->ex_revision), assy_list->ex_revision);
       PDUfill_in_string(&(temp->ex_desc), assy_list->ex_desc);
       PDUfill_in_string(&(temp->ex_cofilename), assy_list->ex_cofilename);
       PDUfill_in_string(&(temp->ex_parttype), assy_list->ex_parttype);
       PDUfill_in_string(&(temp->p_attached), assy_list->p_attached);
       PDUfill_in_string(&(temp->p_quantity), assy_list->p_quantity);
       PDUfill_in_string(&(temp->p_tagno), assy_list->p_tagno);
       PDUfill_in_string(&(temp->p_usageid), assy_list->p_usageid);
       PDUfill_in_string(&(temp->p_alttagno), assy_list->p_alttagno);
       PDUfill_in_string(&(temp->p_incbom), assy_list->p_incbom);
       PDUfill_in_string(&(temp->p_incstr), assy_list->p_incstr);
       PDUfill_in_string(&(temp->p_explode), assy_list->p_explode);
       PDUfill_in_string(&(temp->p_history), assy_list->p_history);
       temp->n_catalogno =  assy_list->n_catalogno;
       temp->n_itemno =  assy_list->n_itemno;
       temp->new_level =  assy_list->new_level;
       PDUfill_in_string(&(temp->new_catalog), assy_list->new_catalog);
       PDUfill_in_string(&(temp->new_partid), assy_list->new_partid);
       PDUfill_in_string(&(temp->new_revision), assy_list->new_revision);
       PDUfill_in_string(&(temp->new_desc), assy_list->new_desc);
       PDUfill_in_string(&(temp->new_cofilename), assy_list->new_cofilename);
       PDUfill_in_string(&(temp->new_cifilename), assy_list->new_cifilename);
       PDUfill_in_string(&(temp->new_parttype), assy_list->new_parttype);
       PDUfill_in_string(&(temp->new_usageid), assy_list->new_usageid);
       strcpy(temp->delete, assy_list->delete);
       strcpy(temp->ems_reffile, assy_list->ems_reffile);
       strcpy(temp->add, assy_list->add);
       strcpy(temp->display, assy_list->display);
       strcpy(temp->add_db, assy_list->add_db);
       temp->mcf_row = assy_list->mcf_row;
   
       tail->next = temp;
       tail = temp;
       assy_list = assy_list->next;
       }

  *copy_list = NULL;
  if (backup)
    *copy_list = PDU_save_ptr;
  else
    *copy_list = PDU_assy_ptr;

  if (PDM_debug_on)
    {
    if ((PDU_save_ptr) && (backup))
      {
      _pdm_debug("printing backup assembly linklist", 0);
      PDUprint_assy_linklist(PDU_save_ptr);
      }
    if (PDU_assy_ptr)
      {
      _pdm_debug("printing restored assembly linklist", 0);
      PDUprint_assy_linklist(PDU_assy_ptr);
      }
    }

  return(status);
}  /* end PDUcopy_assy_linklist */

/* This function searches through the assembly link list for parts that do not
   exist in the database.  All parts that do not exist are added. */

int PDUadd_parts_for_revise_assy()
{
  int	status = PDM_S_SUCCESS;
  int	status1 = PDM_S_SUCCESS;
  int   type_col = 0;
  int   part_col = 0;
  int   rev_col = 0;
  int   desc_col = 0;
  int   acl_col = 0;
  int   sano_col = 0;
  int   saname_col = 0;
  int   name_col = 0;
  int   valueno_col = 0;
  int   stg_buffer_no = 0;
  int   acl_buffer_no = 0;
  int   i = 0;
  char  **data_row;
  char  **dummy_row;
  char  **dummy_col;
  char  **dummy_format;
  char  parttype[3];
  char  aclno[5];
  char  sano[5];
  char  saname[40];
  char  *title = NULL;
  short write_sa = FALSE;
  struct PDUattr_data *attr_data = NULL;
  struct PDUrev_assy  *save_list = NULL;
  MEMptr attr_bufr = NULL;
  MEMptr data_bufr = NULL;
  MEMptr list_bufr = NULL;
  MEMptr file_data = NULL;
  MEMptr acl_bufr = NULL;
  MEMptr stg_bufr = NULL;
  extern void PDUactive_part_form();
  extern void PDUdelete_active_part_form();

  _pdm_debug("In the function PDUadd_parts_for_revise_assy", 0);

  current_rev_assy = PDU_assy_ptr;

  while (current_rev_assy)
    {
    if (strcmp(current_rev_assy->add_db, "N") == 0)
      {
      current_rev_assy = current_rev_assy->next;
      continue;
      }

    _pdm_debug("adding part:", 0);
    _pdm_debug("catalog = <%s>", current_rev_assy->new_catalog);
    _pdm_debug("partid = <%s>", current_rev_assy->new_partid);
    _pdm_debug("revision = <%s>", current_rev_assy->new_revision);
    _pdm_debug("cofilename = <%s>", current_rev_assy->new_cofilename);
    _pdm_debug("cifilename = <%s>", current_rev_assy->new_cifilename);

    refresh->command = PDC_M_CREATE_ELEMENT;

    if (current_rev_assy->new_attr_data == NULL)
      {
      _pdm_debug("retrieving buffers", 0);
      review_mode = FALSE;
      status = PDUget_part_bufrs(current_rev_assy->new_catalog,
                                 current_rev_assy->new_partid,
                                 current_rev_assy->new_revision,
                                 &current_rev_assy->new_attr_data,
                                 0);
      _pdm_status("PDUget_part_bufrs", status);
      }

    attr_data = current_rev_assy->new_attr_data;

    if ((!attr_data->attr_bufr) || (!attr_data->data_bufr) ||
       (!attr_data->list_bufr))
     {
     PDUmessage(PDM_E_NULL_BUFFER, 's');
     return(PDM_E_NULL_BUFFER);
     }

    _pdm_debug("setting global buffers", 0);
    if (attr_bufr)
      {
      MEMclose(&attr_bufr);
      attr_bufr = NULL;
      }
    if (data_bufr)
      {
      MEMclose(&data_bufr);
      data_bufr = NULL;
      }
    if (list_bufr)
      {
      MEMclose(&list_bufr);
      list_bufr = NULL;
      }
  
    status = MEMsplit_copy_buffer(attr_data->attr_bufr, &attr_bufr, 0);
    _pdm_status("MEMsplit_copy_buffer", status);
    status = MEMsplit_copy_buffer(attr_data->data_bufr, &data_bufr, 0);
    _pdm_status("MEMsplit_copy_buffer", status);
    status = MEMsplit_copy_buffer(attr_data->list_bufr, &list_bufr, 1);
    _pdm_status("MEMsplit_copy_buffer", status);

    _pdm_debug("making sure the part does not exist", 0);
    status = PDMcheck_partnum(current_rev_assy->new_catalog,
                              current_rev_assy->new_partid,
                              current_rev_assy->new_revision);
    _pdm_status("PDMcheck_partnum",status);
    MEMclose(&PDU_ret_bufr); PDU_ret_bufr = NULL;
    if (status == PDM_S_SUCCESS)
      return(PDM_E_PART_EXISTS);
    else if (status == PDM_E_PARTREV_NOT_FOUND)
      status = PDM_S_SUCCESS;
    else if (status != PDM_S_SUCCESS)
      return(status);
  
    _pdm_debug("validating access", 0);
    status = PDMvalidate_user_access ( "PDMAdd Part", NULLSTR,
                                        current_rev_assy->new_catalog,
                                        NULLSTR, NULLSTR, NULLSTR );
    _pdm_status("PDMvalidate_access", status);
    if (status != PDM_S_SUCCESS)
      return(status);

    _pdm_debug("verifying parttype", 0);
    status = MEMbuild_array(data_bufr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);
  
    PDUsetup_buffer(data_bufr, ROW, &data_row);

    status = PDUget_buffer_col(data_bufr, "p_parttype", &type_col);
    _pdm_status("PDUget_buffer_col",status);
    if (status != PDM_S_SUCCESS)
      return(status);

    strcpy(parttype, data_row[(data_bufr->columns * 0) + type_col]);
    _pdm_debug("parttype = <%s>", parttype);

    if (((strcmp(parttype, "N") == 0) || (strcmp(parttype, "n") == 0)) &&
         (strlen(current_rev_assy->new_cofilename)))
      return(PDM_E_ADD_FILES_NG_PART);

    status = PDUget_buffer_col(data_bufr, "n_itemname", &part_col);
    _pdm_status("PDUget_buffer_col",status);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(data_bufr, "n_itemrev", &rev_col);
    _pdm_status("PDUget_buffer_col",status);
    if (status != PDM_S_SUCCESS)
      return(status);

    desc_col = -1;
    status = PDUget_buffer_col(data_bufr, "n_itemdesc", &desc_col);
    _pdm_status("PDUget_buffer_col",status);

    status = MEMwrite_data(data_bufr,current_rev_assy->new_partid,
                           1,part_col + 1);
    _pdm_status("MEMwrite_data", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
  
    status = MEMwrite_data(data_bufr,current_rev_assy->new_revision,
                           1,rev_col + 1);
    _pdm_status("MEMwrite_data", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
  
    if (desc_col != -1)
      {
      status = MEMwrite_data(data_bufr,current_rev_assy->new_desc,
                             1,desc_col + 1);
      _pdm_status("MEMwrite_data", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_WRITE_BUFFER);
      }

    _pdm_debug("building attr_bufr", 0);
    status = MEMbuild_array(attr_bufr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    status = PDUsetup_buffer(attr_bufr, ROW, &data_row);
    _pdm_status("PDUsetup_buffer", status);
    if (status != PDM_S_SUCCESS)
      return(status);
  
    _pdm_debug("building list_bufr", 0);
    status = MEMbuild_array(list_bufr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);
  
    status = PDUget_buffer_col(attr_bufr,"n_name", &name_col);
    _pdm_status("PDUget_col_number",status);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(attr_bufr,"n_valueno", &valueno_col);
    _pdm_status("PDUget_col_number",status);
    if (status != PDM_S_SUCCESS)
      return(status);

    _pdm_debug("getting acl buffer number", 0);
    for (i = 0; i < attr_bufr->rows; ++i)
       {
       if (strcmp(data_row[(attr_bufr->columns * i) + name_col], "n_aclno")==0)
         {
         acl_buffer_no = atoi(data_row[(attr_bufr->columns * i) + valueno_col]);
         _pdm_debug("acl_buffer_no = %d", (char *)acl_buffer_no);
         break;
         }
       }
  
    status = PDUsetup_buffer_list(list_bufr, 1, acl_buffer_no, &dummy_row,
                                  &dummy_col,&dummy_format, &acl_bufr);
    _pdm_status("PDUsetup_buffer_list",status);
    if (status != PDM_S_SUCCESS)
      return(status);
  
    _pdm_debug("getting storage buffer number", 0);
    for (i = 0; i < attr_bufr->rows; ++i)
       {
       if (strcmp(data_row[(attr_bufr->columns * i) + name_col],"n_cisano") == 0)
         {
         stg_buffer_no = atoi(data_row[(attr_bufr->columns * i) + valueno_col]);
         _pdm_debug("stg_buffer_no = %d", (char *)stg_buffer_no);
         break;
         }
       }
  
    status = PDUsetup_buffer_list(list_bufr, 1, stg_buffer_no, &dummy_row,
                                  &dummy_col,&dummy_format,&stg_bufr);
    _pdm_status("PDUsetup_buffer_list",status);
    if (status != PDM_S_SUCCESS)
      return(status);
  
    if ((acl_bufr) && (acl_bufr->rows == 1))
      {
      _pdm_debug("setting default aclno", 0);

      status = MEMbuild_array(acl_bufr);
      _pdm_status("MEMbuild_array", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_BUILD_BUFFER_ARRAY);

      if (PDM_debug_on)
        MEMprint_buffer("acl buffer", acl_bufr, PDU_DEBUG_FILE);

      status = PDUsetup_buffer(acl_bufr, ROW, &data_row);
      if (status != PDM_S_SUCCESS)
        return(status);

      status = PDUget_buffer_col(acl_bufr, "n_aclno", &acl_col);
      _pdm_status("PDUget_buffer_col",status);
      if (status != PDM_S_SUCCESS)
        return(status);

      strcpy(aclno, data_row[(acl_bufr->columns * 0) + acl_col]);
      _pdm_debug("aclno = <%s>", aclno);

      _pdm_debug("writing aclno to data_bufr", 0);
      status = PDUget_buffer_col(data_bufr, "n_aclno", &acl_col);
      _pdm_status("PDUget_buffer_col",status);
      if (status != PDM_S_SUCCESS)
        return(status);

      status = MEMwrite_data(data_bufr, aclno, 1, acl_col + 1);
      _pdm_status("MEMwrite_data", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_WRITE_BUFFER);
      }

    if ((stg_bufr) && (stg_bufr->rows == 1))
      {
      _pdm_debug("setting default stgno", 0);
 
      status = MEMbuild_array(stg_bufr);
      _pdm_status("MEMbuild_array", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_BUILD_BUFFER_ARRAY);

      if (PDM_debug_on)
        MEMprint_buffer("stg buffer", stg_bufr, PDU_DEBUG_FILE);

      status = PDUsetup_buffer(stg_bufr, ROW, &data_row);
      if (status != PDM_S_SUCCESS)
        return(status);

      status = PDUget_buffer_col(stg_bufr, "n_saname", &saname_col);
      _pdm_status("PDUget_buffer_col",status);
      if (status != PDM_S_SUCCESS)
        return(status);

      status = PDUget_buffer_col(stg_bufr, "n_sano", &sano_col);
      _pdm_status("PDUget_buffer_col",status);
      if (status != PDM_S_SUCCESS)
        return(status);

      strcpy(sano, data_row[(stg_bufr->columns * 0) + sano_col]);
      strcpy(saname, data_row[(stg_bufr->columns * 0) + saname_col]);

      _pdm_debug("sano = <%s>", sano);
      _pdm_debug("saname = <%s>", saname);

      _pdm_debug("writing to data_bufr", 0);
      status = PDUget_buffer_col(data_bufr, "n_cisano", &sano_col);
      _pdm_status("PDUget_buffer_col",status);
      if (status != PDM_S_SUCCESS)
        return(status);

      status = MEMwrite_data(data_bufr, sano, 1, sano_col + 1);
      _pdm_status("MEMwrite_data", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_WRITE_BUFFER);

      write_sa = TRUE;
      }

    PDUdelete_active_part_form();

    /* display active part form */
    title = (char *)PDUtranslate_message(PDM_I_ADDING_PART);
    PDUactive_part_form(current_rev_assy->new_catalog,
                        current_rev_assy->new_partid,
                        current_rev_assy->new_revision,
                        current_rev_assy->new_desc, title);
    if (title) free(title);

    status = PDUcreate_add_file_buffer(&file_data, 
					current_rev_assy->new_cifilename,
					current_rev_assy->new_cofilename,
                              		attr_bufr, data_bufr, list_bufr);
    _pdm_status("PDUcreate_add_file_buffer", status);
    if (status != PDM_S_SUCCESS)
      {
      if (forms.active_part_form_id)
        {
        FIf_erase(forms.active_part_form_id);
        FIf_delete(forms.active_part_form_id);
        forms.active_part_form_id = 0;
        }
      return(status);
      }

    if (write_sa)
      {
      _pdm_debug("writing n_cisaname to file_data", 0);
      status = MEMbuild_array(file_data);
      _pdm_status("MEMbuild_array", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_BUILD_BUFFER_ARRAY);
  
      status = PDUget_buffer_col(file_data, "n_cisaname", &saname_col);
      _pdm_status("PDUget_buffer_col",status);
      if (status != PDM_S_SUCCESS)
        return(status);
  
      status = MEMwrite_data(file_data, saname, 1, saname_col + 1);
      _pdm_status("MEMwrite_data", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_WRITE_BUFFER);
      }

    _pdm_debug("calling PDMadd_part", 0);
    status = PDMradd_part("", current_rev_assy->new_catalog,
                              current_rev_assy->new_partid,
                              current_rev_assy->new_revision,
                              attr_bufr, data_bufr, file_data);
    _pdm_status("PDMadd_part", status);
    PDUmessage(status, 's');

    PDUdelete_active_part_form();

    if (status != PDM_S_SUCCESS)
      return(status);

    _pdm_debug("setting the state", 0);
    status1 = PDUwf_check(PDC_M_CREATE_ELEMENT);
    _pdm_status("PDUwf_check", status1);
    if (status1 != PDM_S_SUCCESS)
      return(status1);
  
    /* ex$message cannot be used to translate the message key to a string */
    status1 = PDMset_to_state ( status, "PDM", "" );
    _pdm_status ("PDMset_to_state", status1);
    
    if (attr_bufr)
      {
      MEMclose(&attr_bufr);
      attr_bufr = NULL;
      }
  
    if (data_bufr)
      {
      MEMclose(&data_bufr);
      data_bufr = NULL;
      }
  
    if (file_data)
      {
      MEMclose(&file_data);
      file_data = NULL;
      }
  
    _pdm_debug("setting add_db to N", 0);
    strcpy(current_rev_assy->add_db, "N");
    PDUupdate_mult_files_for_rev_assy("add_db", "N");

    _pdm_debug("checking for duplicate parts", 0);
    save_list = current_rev_assy;
    current_rev_assy = PDU_assy_ptr;
    while (current_rev_assy)
      {
      if ((strcmp(current_rev_assy->new_catalog, 
                  save_list->new_catalog) == 0)   &&
          (strcmp(current_rev_assy->new_partid,
                  save_list->new_partid) == 0)   &&
          (strcmp(current_rev_assy->new_revision,
                  save_list->new_revision) == 0)   &&
          (strcmp(current_rev_assy->display, "Y") == 0) &&
          (current_rev_assy->mcf_row != save_list->mcf_row))
        { 
        _pdm_debug("duplicate part found:  resetting ADD_DB", 0);
        strcpy(current_rev_assy->add_db, "N");
        PDUupdate_mult_files_for_rev_assy("add_db", "N");
        }
      current_rev_assy = current_rev_assy->next;
      }

    current_rev_assy = save_list;
    current_rev_assy = current_rev_assy->next;
    }

  return(status);
}

/* This function creates a buffer of file names to be used when adding a part
   to the database through the revise assembly interface. */

int PDUcreate_add_file_buffer(file_bufr, cifile, cofile, 
                              attr_bufr, data_bufr, list_bufr)
MEMptr *file_bufr;
char   *cifile;
char   *cofile;
MEMptr  attr_bufr;
MEMptr  data_bufr;
MEMptr  list_bufr;
{
  int	status = PDM_S_SUCCESS;
  int   valueno_col = 0;
  int   name_col = 0;
  int   saname_col = 0;
  int   sano_col = 0;
  int   cisano_col = 0;
  int   i = 0;
  int   char_index = 0;
  int   col = 0;
  int   stg_buffer_no = 0;
  int   filedesc_col = 0;
  int   filetype_col = 0;
  int   cifile_col = 0;
  char  *line = NULL;
  char	**data_row;
  char	**attr_row;
  char	**stg_row;
  char	**dummy;
  char  *sano = NULL;
  char  *saname = NULL;
  char  *filetype = NULL;
  char  *filedesc = NULL;
  MEMptr stg_bufr = NULL;
  struct PDUrev_assy *temp_list = NULL;

  _pdm_debug("in the function PDUcreate_add_file_buffer", 0);

  if (!*file_bufr)
    {
    /* create the file_bufr */
    status = PDUformat_buffer(PDU_ADD_FILE_BUFFER, file_bufr);
    _pdm_status("PDUformat_buffer", status);

    if (status != PDM_S_SUCCESS)
      return(status);

    line = (char*) malloc ((*file_bufr)->row_size);
    memset (line, NULL, (*file_bufr)->row_size);
    char_index = 0;

    /* write a blank first row to the file buffer */
    for (col = 0; col < (*file_bufr)->columns; ++col)
       line[col] = '\1';

    status = MEMwrite (*file_bufr, line);
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      {
      _pdm_debug("Error writing to file_bufr", 0);
      return(PDM_E_WRITE_BUFFER);
      }
    else
      status = PDM_S_SUCCESS;

    cifile_col = 1;
    }
  else
    {
    line = (char*) malloc ((*file_bufr)->row_size);

    status = PDUget_buffer_col(*file_bufr, "n_cifilename", &cifile_col);
    if (status != PDM_S_SUCCESS)
      {
      cifile_col = 0;
      _pdm_debug("ci_filename is READ ONLY", 0);
      }
    }

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(status);

  status = MEMbuild_array(list_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(status);

  PDUsetup_buffer(attr_bufr, ROW, &attr_row);

  status = PDUget_buffer_col(attr_bufr,"n_valueno", &valueno_col);
  _pdm_status("PDUget_buffer_col",status);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(attr_bufr,"n_name", &name_col);
  _pdm_status("PDUget_buffer_col",status);
  if (status != PDM_S_SUCCESS)
    return(status);

  _pdm_debug("getting storage buffer number", 0);
  for (i = 0; i < attr_bufr->rows; ++i)
     {
     if (strcmp(attr_row[(attr_bufr->columns * i) + name_col],"n_cisano") == 0)
       {
       stg_buffer_no = atoi(attr_row[(attr_bufr->columns * i) + valueno_col]);
       _pdm_debug("stg_buffer_no = %d", (char *)stg_buffer_no);
       break;
       }
     }

  status = PDUsetup_buffer_list(list_bufr, 1, stg_buffer_no, &stg_row,
                                &dummy,&dummy,&stg_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(data_bufr, ROW, &data_row);

  _pdm_debug("getting filedesc", 0);
  status = PDUget_buffer_col(data_bufr,"p_filedesc", &filedesc_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    PDUfill_in_string(&filedesc, NULL_STRING);
  else
    PDUfill_in_string(&filedesc,data_row[(data_bufr->columns*0)+filedesc_col]);
  _pdm_debug("filedesc = <%s>", filedesc);

  _pdm_debug("getting filetype", 0);
  status = PDUget_buffer_col(data_bufr,"n_filetype", &filetype_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    PDUfill_in_string(&filetype, NULL_STRING);
  else
    PDUfill_in_string(&filetype,data_row[(data_bufr->columns*0)+filetype_col]);
  _pdm_debug("filetype = <%s>", filetype);

  _pdm_debug("getting cisano", 0);
  status = PDUget_buffer_col(data_bufr,"n_cisano", &sano_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    {
    _pdm_debug("error retrieving cisano", 0);
    return(status);
    }

  PDUfill_in_string(&sano, data_row[(data_bufr->columns * 0) + sano_col]);
  _pdm_debug("sano = <%s>", sano);

  status = MEMbuild_array(stg_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(status);

  PDUsetup_buffer(stg_bufr, ROW, &stg_row);

  status = PDUget_buffer_col(stg_bufr,"n_sano", &cisano_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  if (((sano) && (!(strlen(sano)))) || ((!sano)))
    {
    _pdm_debug("putting default storage area number in the data bufr", 0);
    PDUfill_in_string(&sano, stg_row[(stg_bufr->columns * 0) + cisano_col]);
    _pdm_debug("sano = <%s>", sano);

    _pdm_debug("writing sano to data_bufr", 0);
    status = MEMwrite_data(data_bufr, sano, 1, sano_col + 1);
    _pdm_status("MEMwrite_data", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
    }

  _pdm_debug("get the storage area name", 0);
  status = PDUget_buffer_col(stg_bufr,"n_saname", &saname_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  for (i = 0; i < stg_bufr->rows; ++i)
     if (strcmp(sano, stg_row[(stg_bufr->columns * i) + cisano_col]) == 0)
       PDUfill_in_string(&saname, stg_row[(stg_bufr->columns*0) + saname_col]);

  _pdm_debug("saname = <%s>", saname);

  _pdm_debug("setting entry for n_filenum", 0);
  line[char_index++] = '\1';  /* entry for n_filenum */

  if ((cofile) && (strlen(cofile)))
    PDUadd_buffer_string(line, &char_index, cofile);
  else
    line[char_index++] = '\1';

  if (filetype && (strlen (filetype )))
    PDUadd_buffer_string(line, &char_index, filetype);
  else
    line[char_index++] = '\1';

  if (saname && (strlen (saname )))
    PDUadd_buffer_string(line, &char_index, saname);
  else
    line[char_index++] = '\1';

  if (cifile_col)
    {
    if (cifile && (strlen (cifile )))
      PDUadd_buffer_string(line, &char_index, cifile);
    else
      line[char_index++] = '\1';
    }

  line[char_index++] = '\1';  /* entry for n_cosano */
  line[char_index++] = '\1';  /* entry for n_couser */

  if (filedesc && (strlen (filedesc )))
    PDUadd_buffer_string(line, &char_index, filedesc);
  else
    line[char_index++] = '\1';

  _pdm_debug("line = <%s>", line);
  status = MEMwrite (*file_bufr, line);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    {
    _pdm_debug("Error writing to file_bufr", 0);
    return(PDM_E_WRITE_BUFFER);
    }
  else
    status = PDM_S_SUCCESS;

  /* check for multiple files */
  temp_list = current_rev_assy;
  temp_list = temp_list->next;
  while (temp_list)
    {
    if (temp_list->ex_level == -1)
      {
      _pdm_debug("part has multiple files", 0);
      char_index = 0;
      memset(line, NULL, ((*file_bufr)->row_size));

      if (!strlen(temp_list->new_cofilename))
        {
        temp_list = temp_list->next;
        continue;
        }

      _pdm_debug("setting entry for n_filenum", 0);
      line[char_index++] = '\1';  /* entry for n_filenum */
    
      if ((temp_list->new_cofilename) && (strlen(temp_list->new_cofilename)))
        PDUadd_buffer_string(line, &char_index, temp_list->new_cofilename);
      else
        line[char_index++] = '\1';
    
      _pdm_debug("setting entry for n_filetype", 0);
      line[char_index++] = '\1';  /* entry for n_filetype */
    
      if (saname && (strlen (saname )))
        PDUadd_buffer_string(line, &char_index, saname);
      else
        line[char_index++] = '\1';
    
      if (temp_list->new_cifilename && (strlen(temp_list->new_cifilename)))
        PDUadd_buffer_string(line, &char_index, temp_list->new_cifilename);
      else
        line[char_index++] = '\1';
    
      line[char_index++] = '\1';  /* entry for n_cosano */
      line[char_index++] = '\1';  /* entry for n_couser */
      line[char_index++] = '\1';  /* entry for p_filedesc */

      _pdm_debug("line = <%s>", line);
      status = MEMwrite (*file_bufr, line);
      _pdm_status("MEMwrite", status);
    
      if (status != MEM_S_SUCCESS)
        {
        _pdm_debug("Error writing to file_bufr", 0);
        return(PDM_E_WRITE_BUFFER);
        }
      else
        status = PDM_S_SUCCESS;
      }
    else
      {
      _pdm_debug("breaking after checking for multiple files", 0);
      break;
      }
    temp_list = temp_list->next;
    }

  if (PDMdebug_on)
    MEMprint_buffer("file_bufr", *file_bufr, PDU_DEBUG_FILE);

  if (filedesc)
    free(filedesc);
  if (filetype)
    free(filetype);
  if (saname)
    free(saname);
  if (sano)
    free(sano);
  if (line)
    free(line);

  if (stg_bufr)
    MEMclose(&stg_bufr);

  return(status);
}

/* This function traverses through the assembly structure link list and sets
   the display entry so that the assembly structure will be displayed as a
   BOM on the revise assembly form.  (i.e. Only one entry is shown for a given
   part no matter how many times it appears in a given subassembly.) */

int PDUcreate_BOM_assy_list(assy_list, assy_bufr)
  struct PDUrev_assy **assy_list;
  MEMptr assy_bufr;
{
  int    status = PDM_S_SUCCESS;
  int    active_row = 0;
  int    pchildno = 0;
  int    childno = 0;
  int    level = 0;
  int    tmp_level = 0;
  int    level_col = 0;
  int    cat_col = 0;
  int    part_col = 0;
  int    rev_col = 0;
  int    row = 0;
  struct PDUrev_assy *list = NULL;
  char   *catalog = NULL;
  char   *partid = NULL;
  char   *revision = NULL;
  char   *parent_cat1 = NULL;
  char   *parent_part1 = NULL;
  char   *parent_rev1 = NULL;
  char   *parent_cat2 = NULL;
  char   *parent_part2 = NULL;
  char   *parent_rev2 = NULL;
  char   **data_row;

  _pdm_debug("in the function PDUcreate_BOM_assy_list", 0);

  if (!assy_list)
    {
    _pdm_debug("linklist is empty", 0);
    return(PDM_E_NULL_ASSY_LIST);
    }

  if (!assy_bufr)
    {
    _pdm_debug("buffer is empty", 0);
    return(PDM_E_NULL_BUFFER);
    }

  list = PDU_assy_ptr;

  status = MEMbuild_array(assy_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(assy_bufr, ROW, &data_row);

  status = PDUget_buffer_col(assy_bufr, "n_catalogname", &cat_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(assy_bufr, "n_itemname", &part_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);
  
  status = PDUget_buffer_col(assy_bufr, "n_itemrev", &rev_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);
  
  status = PDUget_buffer_col(assy_bufr, "p_level", &level_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);
  
  while (list)
    {
    _pdm_debug("active_row = <%d>", (char *)active_row);
    while ((list) && (list->mcf_row <= active_row))
      list = list->next;

    if (!list)
      break;

    if (strcmp(list->display, "Y") == 0)
      {
      _pdm_debug("processing row %d", list->mcf_row);
      PDUfill_in_string(&catalog, list->ex_catalog);
      PDUfill_in_string(&partid, list->ex_partid);
      PDUfill_in_string(&revision, list->ex_revision);
      pchildno = list->p_pchildno;
      childno = list->p_childno;
      active_row = list->mcf_row;
      level = list->ex_level;
  
      /* get the parent child # of the level one part */
      if (list->ex_level != 1)
        {
        for (row = list->mcf_row; row > 0; --row)
           {
           tmp_level = 
                    atoi(data_row[(assy_bufr->columns * row) + level_col]);
           if (tmp_level == 1) 
             {
             PDUfill_in_string(&parent_cat1,
                    data_row[(assy_bufr->columns * row) + cat_col]);
             PDUfill_in_string(&parent_part1,
                    data_row[(assy_bufr->columns * row) + part_col]);
             PDUfill_in_string(&parent_rev1,
                    data_row[(assy_bufr->columns * row) + rev_col]);
             break;
             }
           }
        }

      _pdm_debug("catalog = <%s>", catalog);
      _pdm_debug("partid = <%s>", partid);
      _pdm_debug("revision = <%s>", revision);
      _pdm_debug("pchildno = <%d>", (char *)pchildno);
      _pdm_debug("childno = <%d>", (char *)childno);
      _pdm_debug("active_row = <%d>", (char *)active_row);
      _pdm_debug("level = <%d>", (char *)level);
  
      list = list->next;
  
      while (list) 
        {
        if ((strcmp(list->display, "Y") == 0) &&
            (strcmp(list->ex_catalog, catalog) == 0) &&
            (strcmp(list->ex_partid, partid) == 0) &&
            (strcmp(list->ex_revision, revision) == 0) &&
            (list->p_pchildno == pchildno) &&
            (list->ex_level == level))
          {
          _pdm_debug("duplicate part found at mcf_row <%d>", (char *)list->mcf_row);
          /* find the level 1 part */
          if ((list->ex_level != 1) && (list->p_childno == childno))
            {
            for (row = list->mcf_row; row > 0; --row)
               {
               tmp_level = 
                    atoi(data_row[(assy_bufr->columns * row) + level_col]);
               if (tmp_level == 1) 
                 {
                 PDUfill_in_string(&parent_cat2,
                        data_row[(assy_bufr->columns * row) + cat_col]);
                 PDUfill_in_string(&parent_part2,
                        data_row[(assy_bufr->columns * row) + part_col]);
                 PDUfill_in_string(&parent_rev2,
                        data_row[(assy_bufr->columns * row) + rev_col]);
                 break;
                 }
               }

            _pdm_debug("parent_cat2 = <%s>", parent_cat2);
            _pdm_debug("parent_part2 = <%s>", parent_part2);
            _pdm_debug("parent_rev2 = <%s>", parent_rev2);

            if ((parent_cat1) && (parent_part1) && (parent_rev1) &&
                (parent_cat2) && (parent_part2) && (parent_rev2) &&
               ((strcmp(parent_cat1, parent_cat2) != 0) ||
                (strcmp(parent_part1, parent_part2) != 0) ||
                (strcmp(parent_rev1, parent_rev2) != 0)))
              {
              _pdm_debug("nested part was not a duplicate", 0);
              list = list->next;
              continue;
              }
            }

          strcpy(list->display, "N");
          level = list->ex_level;
          list = list->next;
    
          _pdm_debug("marking child parts", 0);
          if ((list) && (list->ex_level > level))
            {
            while ((list) && (list->ex_level > level))
              {
              if (strcmp(list->display, "Y") == 0)
                {
                strcpy(list->display, "N");
                list = list->next;
                }
              }
            }
          }
        else
          list = list->next;
        }
      _pdm_debug("resetting list", 0);
      list = PDU_assy_ptr;
      }
     else
       list = list->next;
    }

  list = PDU_assy_ptr;

  _pdm_debug("resetting MCF row pointers", 0);
  status = PDUreset_assy_mcf_row_pointers();
  _pdm_status("PDUreset_assy_mcf_row_pointers", status);

  list = PDU_assy_ptr;

  if (PDMdebug_on)
    {
    _pdm_debug("printing reset list", 0);
    PDUprint_assy_linklist(PDU_assy_ptr);
    }

  *assy_list = PDU_assy_ptr;

  return(status);
}

/* This function traverses through the assembly link list and checks to see
   which data the user has changed.  Based on the information that has changed,
   a file name may or may not be required.  A catalog, partid and revision
   are required for all rows of data (except those with multiple files).  
   The function verifies this.  For any part that has been changed or added,
   a function is called to verify the status of and validate access for the
   parent part.  A determination is made as to whether or not the change
   affects just the CIT or object space also.  Flags are set and returned
   based on CIT/object space changes. */

int PDUcheck_assy_list_for_change(assy_bufr, change)
  MEMptr assy_bufr;
  short	 *change;
{

  char  *add_msg = NULL;
  char  *del_msg = NULL;
  int   level = 0;
  int   status = PDM_S_SUCCESS;
  struct PDUrev_assy *temp_list = NULL;
 
  _pdm_debug("in the function PDUcheck_assy_list_for_change", 0);

  current_rev_assy = PDU_assy_ptr;

  if (!current_rev_assy)
    return(PDM_E_NULL_ASSY_LIST);

  add_msg = (char *) PDUtranslate_message(PDM_I_ADDED_ROW);
  del_msg = (char *) PDUtranslate_message(PDM_I_DELETED);

  while (current_rev_assy)
    {
    if (current_rev_assy->ex_level == -1)
      {
      current_rev_assy = current_rev_assy->next;
      continue;
      }

    if (strcmp(current_rev_assy->display, "N") == 0)
      {
      current_rev_assy = current_rev_assy->next;
      continue;
      }

    level = current_rev_assy->ex_level;

    if ((!(strlen(current_rev_assy->new_catalog))) &&
        (!(strlen(current_rev_assy->new_partid))) &&
        (!(strlen(current_rev_assy->new_revision))))
      {
      PDUdisplay_status(PDM_E_PART_DATA_FOR_REVISE, forms.rev_assy_form_id);
      FIfld_pos_cursor(forms.rev_assy_form_id, REV_MCF, 
                       current_rev_assy->mcf_row, 0, CAT_COL, 0, 1, 1);
      return(PDM_E_PART_DATA_FOR_REVISE);
      }

    if (!(strlen(current_rev_assy->new_catalog)))
      {
      PDUdisplay_status(PDM_E_CATALOG_FOR_REVISE, forms.rev_assy_form_id);
      FIfld_pos_cursor(forms.rev_assy_form_id, REV_MCF, 
                       current_rev_assy->mcf_row, 0, CAT_COL, 0, 1, 1);
      return(PDM_E_CATALOG_FOR_REVISE);
      }

    if (!(strlen(current_rev_assy->new_partid)))
      {
      PDUdisplay_status(PDM_E_PART_FOR_REVISE, forms.rev_assy_form_id);
      FIfld_pos_cursor(forms.rev_assy_form_id, REV_MCF, 
                       current_rev_assy->mcf_row, 0, PART_COL, 0, 1, 1);
      return(PDM_E_PART_FOR_REVISE);
      }

    if (!(strlen(current_rev_assy->new_revision)))
      {
      PDUdisplay_status(PDM_E_REVISION_FOR_REVISE, forms.rev_assy_form_id);
      FIfld_pos_cursor(forms.rev_assy_form_id, REV_MCF, 
                       current_rev_assy->mcf_row, 0, REV_COL, 0, 1, 1);
      return(PDM_E_REVISION_FOR_REVISE);
      }

    if ((strcmp(current_rev_assy->ex_catalog,  add_msg) != 0) &&
        (strcmp(current_rev_assy->new_catalog, del_msg) != 0) &&
        (strcmp(current_rev_assy->ex_catalog,  
                current_rev_assy->new_catalog) == 0) &&
        (strcmp(current_rev_assy->ex_partid,   
                current_rev_assy->new_partid) == 0) &&
        (strcmp(current_rev_assy->ex_revision, 
                current_rev_assy->new_revision) == 0))
      {
      _pdm_debug("part data is the same", 0);
      _pdm_debug("filename must be the same", 0);

      if ((current_rev_assy->new_cofilename) && 
          (strlen(current_rev_assy->new_cofilename)))
        {
        if (strcmp(current_rev_assy->new_cofilename, 
                   current_rev_assy->ex_cofilename) != 0)
          {
          _pdm_debug("user error: filename cannot be changed", 0);
          return(PDM_E_CHANGE_FILE_ON_PART_FORM);
          }

        temp_list = current_rev_assy;
        current_rev_assy = current_rev_assy->next;
        _pdm_debug("checking for multiple files", 0);
        while (current_rev_assy)
          {
          if (current_rev_assy->ex_level == -1)
            {
            if (strcmp(current_rev_assy->new_cofilename,
                   current_rev_assy->ex_cofilename) != 0)
              {
              _pdm_debug("user error: filename cannot be changed", 0);
              return(PDM_E_CHANGE_FILE_ON_PART_FORM);
              }
            }
          else
            break;
          current_rev_assy = current_rev_assy->next;
          }
        _pdm_debug("resetting list", 0);
        current_rev_assy = temp_list;

        current_rev_assy = current_rev_assy->next;
        continue;
        }

      else if (!(strlen(current_rev_assy->new_cofilename)))
        {
        _pdm_debug("filename is empty", 0);
        if (strlen(current_rev_assy->ex_cofilename))
          {
  _pdm_debug("setting newfile to exfile <%s>", current_rev_assy->ex_cofilename);
          PDUfill_in_string(&(current_rev_assy)->new_cofilename, 
                            current_rev_assy->ex_cofilename);

          temp_list = current_rev_assy;
          current_rev_assy = current_rev_assy->next;
          _pdm_debug("checking for multiple files", 0);
          while (current_rev_assy)
            {
            if (current_rev_assy->ex_level == -1)
              {
  _pdm_debug("setting newfile to exfile <%s>", current_rev_assy->ex_cofilename);
              PDUfill_in_string(&(current_rev_assy)->new_cofilename,
                            current_rev_assy->ex_cofilename);
              }
            else
              break;
            current_rev_assy = current_rev_assy->next;
            }
          _pdm_debug("resetting list", 0);
          current_rev_assy = temp_list;
          }
        current_rev_assy = current_rev_assy->next;
        continue;
        }
      }
    else if ((strcmp(current_rev_assy->ex_catalog,  add_msg) == 0) ||
             (strcmp(current_rev_assy->new_catalog, del_msg) == 0) ||
             (strcmp(current_rev_assy->ex_catalog,  
                     current_rev_assy->new_catalog) != 0) ||
             (strcmp(current_rev_assy->ex_partid,   
                     current_rev_assy->new_partid) != 0) ||
             (strcmp(current_rev_assy->ex_revision, 
                     current_rev_assy->new_revision) != 0) ||
             (strcmp(current_rev_assy->delete, "Y") == 0) ||
             (strcmp(current_rev_assy->add, "Y") == 0))
      {
      _pdm_debug("assembly has been modified", 0);
      _pdm_debug("mcf_row = %d", (char *)(current_rev_assy->mcf_row));
      _pdm_debug("partid = %s", current_rev_assy->new_partid);
      *change = TRUE;

      if (strcmp(current_rev_assy->delete, "Y") != 0)
        {
        _pdm_debug("make sure filenames are not duplicates", 0);
        if ((strlen(current_rev_assy->new_cofilename)) &&
            (strcmp(current_rev_assy->new_cofilename, 
                    current_rev_assy->ex_cofilename) == 0))
          {
          _pdm_debug("part has been changed: enter new filename", 0);
          FIfld_pos_cursor(PDU_form_id, REV_MCF, current_rev_assy->mcf_row, 0,
                           LOCFILE_COL, 0 , 0, 0);
          return(PDM_E_NEW_FILE_FOR_CHGD_PARTS);
          }
  
        _pdm_debug("checking for multiple files", 0);
        temp_list = current_rev_assy;
        current_rev_assy = current_rev_assy->next;
        while (current_rev_assy)
          {
          if (current_rev_assy->ex_level == -1)
            {
            _pdm_debug("Checking filename for multiple file", 0);
            if ((strlen(current_rev_assy->new_cofilename)) &&
                (strcmp(current_rev_assy->new_cofilename,
                        current_rev_assy->ex_cofilename) == 0))
              {
              _pdm_debug("part has been changed: enter new filename", 0);
              FIfld_pos_cursor(PDU_form_id, REV_MCF, current_rev_assy->mcf_row, 0,
                               LOCFILE_COL, 0 , 0, 0);
              return(PDM_E_NEW_FILE_FOR_CHGD_PARTS);
              }
            }
          else
            break;
          current_rev_assy = current_rev_assy->next;
          }
        current_rev_assy = temp_list;
  
        _pdm_debug("attach = <%s>", current_rev_assy->p_attached);
        _pdm_debug("filename = <%s>", current_rev_assy->new_cofilename);
  
        if ((!(strlen(current_rev_assy->new_cofilename))) &&
            (strcmp(current_rev_assy->p_attached, "Y") == 0))
          {
          _pdm_debug("part cannot be attached: filename is NULL", 0);
          _pdm_debug("resetting p_attached to <N>", 0);
          PDUfill_in_string(&(current_rev_assy)->p_attached, "N");
          PDU_attach = FALSE;
          }
        else
          {
          if (strcmp(current_rev_assy->p_attached, "Y") == 0)
            PDU_attach = TRUE;
          else
            PDU_attach = FALSE;
          }
        }

      if (current_rev_assy->ex_level > 0)
        {
        status = PDUcheck_parent_part_for_revise_assy(
                                      current_rev_assy->mcf_row,
                                      current_rev_assy->ex_level,
                                      assy_bufr);
        _pdm_status("PDUcheck_parent_part_for_revise_assy", status);
        if (status != PDM_S_SUCCESS)
          return(status);
        }
      }

    current_rev_assy = current_rev_assy->next;
    }

  return(PDM_S_SUCCESS);
}

/* This function prints a link list of type PDUparts_list */

int PDUprint_parts_list(head)
  struct PDUparts_list   *head;
{
  int    status = PDM_S_SUCCESS;
  FILE  *pdu_debug_file, *fopen();

  _pdm_debug("in the function PDUprint_parts_list", 0);

  if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
    {
    printf("Could not open debug file\n");
    return(PDM_E_OPEN_FILE);
    }

  while (head)
    {
    fprintf(pdu_debug_file, "catalog    = %s\n", head->catalog);
    fprintf(pdu_debug_file, "partid     = %s\n", head->partid);
    fprintf(pdu_debug_file, "revision   = %s\n", head->revision);
    fprintf(pdu_debug_file, "desc       = %s\n", head->description);
    fprintf(pdu_debug_file, "parttype   = %s\n", head->parttype);
    fprintf(pdu_debug_file, "cofilename = %s\n", head->cofilename);
    fprintf(pdu_debug_file, "cifilename = %s\n", head->cifilename);
    fprintf(pdu_debug_file, "\n");
    head = head->next;
    }

  fclose (pdu_debug_file);
  return(status);
}  /* end PDUprint_parts_list */

/* This function prints a link list of type PDUparts_list */

int PDUprint_assy_parts_list(head)
  struct PDUassy_parts_list   *head;
{
  int    status = PDM_S_SUCCESS;
  FILE  *pdu_debug_file, *fopen();

  _pdm_debug("in the function PDUprint_assy_parts_list", 0);

  if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
    {
    printf("Could not open debug file\n");
    return(PDM_E_OPEN_FILE);
    }

  while (head)
    {
    fprintf(pdu_debug_file, "level      = %d\n", head->p_level);
    fprintf(pdu_debug_file, "childno    = %d\n", head->p_childno);
    fprintf(pdu_debug_file, "pchildno   = %d\n", head->p_pchildno);
    fprintf(pdu_debug_file, "catalog    = %s\n", head->catalog);
    fprintf(pdu_debug_file, "partid     = %s\n", head->partid);
    fprintf(pdu_debug_file, "revision   = %s\n", head->revision);
    fprintf(pdu_debug_file, "\n");
    head = head->next;
    }

  fclose (pdu_debug_file);
  return(status);
}  /* end PDUprint_assy_parts_list */

/* This function adds a part to the end of a link list of type PDUparts_list */

int PDUadd_part_to_list(catalog, partid, revision, description, parttype,
                        cofilename, cifilename, parts_list)
  char   *catalog;
  char   *partid;
  char   *revision;
  char   *description;
  char   *parttype;
  char   *cofilename;
  char   *cifilename;
  struct PDUparts_list **parts_list;
{
  int                      status = PDM_S_SUCCESS;
  struct PDUparts_list    *temp = NULL, *local_list = NULL;
  short  null_list = FALSE;

  _pdm_debug("in the function PDUadd_part_to_list", 0);

  if (!(*parts_list))
    {
    _pdm_debug("creating the beginning node", 0);
    temp = (struct PDUparts_list *)malloc(sizeof(struct PDUparts_list));
    *parts_list = temp;
    null_list = TRUE;
    }
  else
    {
    local_list = *parts_list;
    
    _pdm_debug("moving to end of current list", 0);
    while (local_list->next)
      local_list = local_list->next;

    temp = (struct PDUparts_list *)malloc(sizeof(struct PDUparts_list));
    }

  _pdm_debug("initializing data", 0);
  temp->next = NULL;
  temp->catalog = NULL_STRING;
  temp->partid = NULL_STRING;
  temp->revision = NULL_STRING;
  temp->description = NULL_STRING;
  temp->parttype = NULL_STRING;
  temp->cofilename = NULL_STRING;
  temp->cifilename = NULL_STRING;

  _pdm_debug("writing values", 0);
  PDUfill_in_string(&(temp)->catalog, catalog);
  PDUfill_in_string(&(temp)->partid, partid);
  PDUfill_in_string(&(temp)->revision, revision);
  PDUfill_in_string(&(temp)->description, description);
  PDUfill_in_string(&(temp)->parttype, parttype);
  PDUfill_in_string(&(temp)->cofilename, cofilename);
  PDUfill_in_string(&(temp)->cifilename, cifilename);

  if (!null_list)
    {
    local_list->next = temp;
    }

  if (PDM_debug_on)
    {
    if (*parts_list)
      {
      _pdm_debug("printing global save part list", 0);
      PDUprint_parts_list(*parts_list);
      }
    }

  return(status);
}

/* This function adds a part to the end of a link list of type 
   PDUassy_parts_list */

int PDUadd_part_to_assy_list(level, p_childno, p_pchildno, 
                             catalog, partid, revision, parts_list)
  int    level;
  int    p_childno;
  int    p_pchildno;
  char   *catalog;
  char   *partid;
  char   *revision;
  struct PDUassy_parts_list **parts_list;
{
  int                      status = PDM_S_SUCCESS;
  struct PDUassy_parts_list    *temp = NULL, *local_list = NULL;
  short  null_list = FALSE;

  _pdm_debug("in the function PDUadd_part_to_assy_list", 0);

  if (!(*parts_list))
    {
    _pdm_debug("creating the beginning node", 0);
    temp = (struct PDUassy_parts_list *)malloc(sizeof(struct PDUassy_parts_list));
    *parts_list = temp;
    null_list = TRUE;
    }
  else
    {
    local_list = *parts_list;
    
    _pdm_debug("moving to end of current list", 0);
    while (local_list->next)
      local_list = local_list->next;

    temp = (struct PDUassy_parts_list *)malloc(sizeof(struct PDUassy_parts_list));
    }

  _pdm_debug("initializing data", 0);
  temp->next = NULL;
  temp->p_level = 0;
  temp->p_childno = 0;
  temp->p_pchildno = 0;
  temp->catalog = NULL_STRING;
  temp->partid = NULL_STRING;
  temp->revision = NULL_STRING;

  _pdm_debug("writing values", 0);
  temp->p_level = level;
  temp->p_childno = p_childno;
  temp->p_pchildno = p_pchildno;
  PDUfill_in_string(&(temp)->catalog, catalog);
  PDUfill_in_string(&(temp)->partid, partid);
  PDUfill_in_string(&(temp)->revision, revision);

  if (!null_list)
    {
    local_list->next = temp;
    *parts_list = local_list;
    }

  if (PDM_debug_on)
    {
    if (*parts_list)
      {
      _pdm_debug("printing global assy part list", 0);
      PDUprint_assy_parts_list(*parts_list);
      }
    }

  return(status);
}

/* This function traverses through a list of type PDUparts_list to see if the
   the part that is passed in is already in the list.  1 is returned if the
   part is in the list. */

int PDUis_part_in_list(catalog, partid, revision, parts_list)
char   *catalog;
char   *partid;
char   *revision;
struct PDUparts_list *parts_list;
{
  _pdm_debug("in the function PDUis_part_in_list", 0);

  if (!parts_list)
    {
    _pdm_debug("parts list is NULL", 0);
    return(0);
    }

  while (parts_list)
    {
    if ((strcmp(parts_list->catalog, catalog) == 0) &&
        (strcmp(parts_list->partid, partid) == 0) &&
        (strcmp(parts_list->revision, revision) == 0))
      {
      _pdm_debug("part found in parts list", 0);
      return(1);
      }
    parts_list = parts_list->next;
    }

  _pdm_debug("part is not in list", 0);
  return(0);
}

/* This function traverses through a list of type PDUparts_list to see if the
   the part that is passed in is already in the list.  1 is returned if the
   part is in the list. */

int PDUis_part_in_assy_list(level, p_childno, p_pchildno,
                            catalog, partid, revision, parts_list)
int     level;
int     p_childno;
int     p_pchildno;
char   *catalog;
char   *partid;
char   *revision;
struct PDUassy_parts_list *parts_list;
{
  _pdm_debug("in the function PDUis_part_in_assy_list", 0);

  if (!parts_list)
    {
    _pdm_debug("parts list is NULL", 0);
    return(0);
    }

  while (parts_list)
    {
    if ((strcmp(parts_list->catalog, catalog) == 0) &&
        (strcmp(parts_list->partid, partid) == 0) &&
        (strcmp(parts_list->revision, revision) == 0))
      {
      _pdm_debug("part found in parts list; verify childnos", 0);
      if ((parts_list->p_level == level) &&
          (parts_list->p_childno == p_childno) &&
          (parts_list->p_pchildno == p_pchildno))
        {
        _pdm_debug("part is not a duplicate", 0);
        }
      else
        {
        _pdm_debug("part is a duplicate", 0);
        return(1);
        }
      }
    parts_list = parts_list->next;
    }

  _pdm_debug("part is not in list", 0);
  return(0);
}

/* This function verifies the file status of a part and calls a function to 
   add it to a link list of type PDUparts_list */

int PDUcheck_parent_part_for_revise_assy(mcf_row, current_level, assy_bufr)
    int    mcf_row;
    int    current_level;
    MEMptr assy_bufr;
{
    int    status = PDM_S_SUCCESS;
    int    part_status = PDM_S_SUCCESS;
    int    row = 0;
    int    cat_col = 0;
    int    part_col = 0;
    int    rev_col = 0;
    int    add_db_col = 0;
    int    row_col = 0;
    int    level_col = 0;
    int    buffer_row = -1;
    int    level = 0;
    int    disp_col = 0;
    int    index = 0;
    int    del_col = 0;
    int    parent_row = 0;
    short  in_list = FALSE;
    char   **data_row;
    char   *catalog = NULL;
    char   *partid = NULL;
    char   *revision = NULL;
    char   *add_db = NULL;
    struct PDUparts_list *list = NULL;

    _pdm_debug("in the function PDUcheck_parent_part_for_revise_assy", 0);

    if (!assy_bufr)
      {
      _pdm_debug("assy_bufr is NULL", 0);
      return(PDM_E_NULL_BUFFER);
      }

    status = MEMbuild_array(assy_bufr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    status = PDM_S_SUCCESS;

    PDUsetup_buffer(assy_bufr, ROW, &data_row);
    PDUget_buffer_col(assy_bufr, "new_catalog", &cat_col);
    PDUget_buffer_col(assy_bufr, "new_partid", &part_col);
    PDUget_buffer_col(assy_bufr, "new_revision", &rev_col);
    PDUget_buffer_col(assy_bufr, "add_db", &add_db_col);
    PDUget_buffer_col(assy_bufr, "mcf_row", &row_col);
    PDUget_buffer_col(assy_bufr, "ex_level", &level_col);
    PDUget_buffer_col(assy_bufr, "display", &disp_col);
    PDUget_buffer_col(assy_bufr, "delete", &del_col);

    _pdm_debug("find matching row in the buffer", 0);
    buffer_row = -1;
    for (row = 0; row < assy_bufr->rows; ++row)
       {
       buffer_row = atoi(data_row[(assy_bufr->columns * row) + row_col]);

       if (buffer_row == mcf_row)
         {
         _pdm_debug("matching row is %d", (char *)buffer_row);
         break;
         }
       }
    if (buffer_row == -1)
      {
      _pdm_debug("matching row not found in buffer", 0);
      return(PDM_E_ROW_NOT_FOUND);
      }

    _pdm_debug("search backwards for the parent part", 0);
    for (index = row - 1; index >= 0; --index)
       {
       _pdm_debug("index = %d", (char *)index);

       if (strcmp(data_row[(assy_bufr->columns * index) + disp_col], "N") == 0)
         {
         _pdm_debug("skipping row %d", (char *)index);
         continue;
         }

       if (strcmp(data_row[(assy_bufr->columns * index) + del_col], "Y") == 0)
         {
         _pdm_debug("checking row that is marked for delete", 0);
         level = atoi(data_row[(assy_bufr->columns * index) + level_col]);
         _pdm_debug("level = <%d>", (char *)level);
         if (level < current_level)
           {
           _pdm_debug("parent part has been marked for delete", 0);
           return(PDM_S_SUCCESS);
           }
         else
           {
           _pdm_debug("skipping deleted row %d", (char *)index);
           continue;
           }
         }

       level = atoi(data_row[(assy_bufr->columns * index) + level_col]);
       _pdm_debug("level = <%d>", (char *)level);

       if ((level == current_level) || (level == -1))
         continue;

       else if (level < current_level)
         {
         _pdm_debug("retrieving part information", 0);
         PDUfill_in_string(&catalog, 
                           data_row[(assy_bufr->columns * index) + cat_col]);
         PDUfill_in_string(&partid,
                           data_row[(assy_bufr->columns * index) + part_col]);
         PDUfill_in_string(&revision,
                           data_row[(assy_bufr->columns * index) + rev_col]);
         PDUfill_in_string(&add_db,
                           data_row[(assy_bufr->columns * index) + add_db_col]);
         parent_row = atoi(data_row[(assy_bufr->columns * index) + row_col]);

         _pdm_debug("catalog = <%s>", catalog);
         _pdm_debug("partid = <%s>", partid);
         _pdm_debug("revision = <%s>", revision);
         _pdm_debug("add_db = <%s>", add_db);

         _pdm_debug("check if file status has already been checked", 0);
         list = PDU_save_part_list;
         in_list = PDUis_part_in_list(catalog, partid, revision, list);
         _pdm_debug("PDUis_part_in_list returns %d", (char *)in_list);

         if (in_list)
           break; 

         if ((level != 0) && (strcmp(current_rev_assy->add_db, "Y") != 0))
         {
         status = PDMvalidate_user_access("PDMCheck Out Part", NULLSTR,
                                    catalog, NULLSTR, partid, revision );
         _pdm_status ("PDMvalidate_user_access", status);
         if (status != PDM_S_SUCCESS)
           {
           PDUdisplay_status(status, forms.rev_assy_form_id);
           FImcf_set_select(forms.rev_assy_form_id, REV_MCF, parent_row, TRUE);
           return(status);
           }

         _pdm_debug("checking file status of parent part", 0);
         part_status = PDMrcheck_part_status(catalog, partid, revision);
         _pdm_status("PDMrcheck_part_status", part_status);
         if ((part_status != PDM_I_CHECKED_IN) && 
             (part_status != PDM_I_NEVER_CHECKED_IN))
           {
           PDUdisplay_status(PDM_I_PART_CHECKIN, forms.rev_assy_form_id);
           FImcf_set_select(forms.rev_assy_form_id, REV_MCF,parent_row,TRUE);
           return(PDM_I_PART_CHECKIN);
           }
         }

         _pdm_debug("adding parent part to list", 0);
         list = PDU_save_part_list;
         status = PDUadd_part_to_list(catalog, partid, revision, "", "", "", "",
                                      &list);
         _pdm_status("PDUadd_part_to_list", status);
         PDU_save_part_list = list;

         break;
         }
       else
         continue;
       }

  _pdm_debug("Exiting:  PDUcheck_parent_part_for_revise_assy", 0);
  return(status);
}

/* This function frees a link list of structures of type PDUparts_list */

int PDUfree_parts_list(list)
  struct PDUparts_list  **list;
{
  struct PDUparts_list * head = NULL;
  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUfree_parts_list", 0);

  if (*list)
    {
    _pdm_debug("setting head", 0);
    head = *list;

    _pdm_debug("entering while loop", 0);
    while ((*list)->next)
      {
      *list = (*list)->next;

      /* free the current node in the list */
      _pdm_debug("freeing head", 0);
      free(head);

      /* reset the pointer */
      _pdm_debug("resetting pointer", 0);
      head = *list;
      }

    _pdm_debug("setting list to NULL", 0);
    *list = NULL;
    }

  return(status);
}

/* This function frees a link list of structures of type PDUassy_parts_list */

int PDUfree_assy_parts_list(list)
  struct PDUassy_parts_list  **list;
{
  struct PDUassy_parts_list * head = NULL;
  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUfree_assy_parts_list", 0);

  if (*list)
    {
    _pdm_debug("setting head", 0);
    head = *list;

    _pdm_debug("entering while loop", 0);
    while ((*list)->next)
      {
      *list = (*list)->next;

      /* free the current node in the list */
      _pdm_debug("freeing head", 0);
      free(head);

      /* reset the pointer */
      _pdm_debug("resetting pointer", 0);
      head = *list;
      }

    _pdm_debug("setting list to NULL", 0);
    *list = NULL;
    }

  return(status);
}

/* This function converts a link list of type PDUrev_assy to a buffer of type
   PDU_ASSY_BUFR */

int PDUassy_list_to_ASSY_BUFR(list, buffer)
  struct PDUrev_assy     *list;
  MEMptr                  *buffer;
{
  int		status = PDM_S_SUCCESS;
  char          *line;

  _pdm_debug("in the function PDUassy_list_to_ASSY_BUFR", 0);

  if (!list)
    {
    _pdm_debug("linklist is NULL", 0);
    return(PDM_E_NULL_ASSY_LIST);
    }

  if (PDM_debug_on)
    {
    if (PDU_assy_ptr != NULL)
      {
      _pdm_debug("printing assembly linklist", 0);
      PDUprint_assy_linklist(PDU_assy_ptr);
      }
    }

  status = PDUformat_buffer(PDU_ASSY_BUFR, buffer);
  _pdm_status("PDUformat_buffer", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  line = (char *) malloc ((*buffer)->row_size);
  memset(line, NULL, (*buffer)->row_size);

  while (list)
     {
       sprintf(line, 
     "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1",
                     list->ex_level,
                     list->ex_catalog,
                     list->ex_partid,
                     list->ex_revision,
                     list->ex_desc,
                     list->ex_cofilename,
                     list->ex_parttype,
                     list->p_level,
                     list->p_pchildno,
                     list->p_childno,
                     list->p_attached,
                     list->p_quantity,
                     list->p_usageid,
                     list->p_tagno,
                     list->p_alttagno,
                     list->p_incbom,
                     list->p_incstr,
                     list->p_explode,
                     list->p_history,
                     list->n_catalogno,
                     list->n_itemno,
                     list->new_level,
                     list->new_catalog,
                     list->new_partid,
                     list->new_revision,
                     list->new_desc,
                     list->new_cofilename,
                     list->new_cifilename,
                     list->new_parttype,
                     list->new_usageid,
                     list->delete,
                     list->ems_reffile,
                     list->add,
                     list->display,
                     list->add_db,
                     list->mcf_row);
       status = MEMwrite(*buffer, line);
       _pdm_status("MEMwrite (assembly buffer)", status);
       if (status != MEM_S_SUCCESS)
         {
         status = PDM_E_WRITE_ROW;
         PDUmessage(status, 's');
         return(status);
         }
     list = list->next;
     }

/*
  if (PDMdebug_on)
    MEMprint_buffer("assembly buffer", *buffer, PDU_DEBUG_FILE);
*/

  if (status == MEM_S_SUCCESS)
    return(PDM_S_SUCCESS);
  else
    return(status);

}

/* This function is called after a part has been marked for delete on the 
   revise assembly form.  It traverses through the assembly structure link list
   and marks all identicle parts with the same level number for delete. */

void PDUdelete_multiple_occurrences(catalog, partid, revision, level,
                                    parent_cat, parent_part, parent_rev)
char   *catalog;
char   *partid;
char   *revision;
int    level;
char   *parent_cat;
char   *parent_part;
char   *parent_rev;
{

  int   row = 0;
  int   mcf_row = 0;
  int   length, pos, select;
  int   parent_level = 0;
  int   num_rows = 0;
  int   tmp_level = 0;
  static char *text = NULL;
  char  *displayed = NULL;
  char  *msg = NULL;
  Form  fp;
  struct PDUrev_assy *assy_list = NULL;

  _pdm_debug("in the function PDUdelete_multiple_occurrences", 0);

  _pdm_debug("parent_cat = <%s>", parent_cat);
  _pdm_debug("parent_part = <%s>", parent_part);
  _pdm_debug("parent_rev = <%s>", parent_rev);

  _pdm_debug("child catalog = <%s>", catalog);
  _pdm_debug("child partid = <%s>", partid);
  _pdm_debug("child revision = <%s>", revision);

  fp = forms.rev_assy_form_id;

  current_rev_assy = PDU_assy_ptr;
  assy_list = PDU_assy_ptr;

  msg = (char *)PDUtranslate_message(PDM_I_DELETED);

  while (assy_list)
    {
    if ((strcmp(assy_list->new_catalog, parent_cat) == 0) &&
        (strcmp(assy_list->new_partid, parent_part) == 0) &&
        (strcmp(assy_list->new_revision, parent_rev) == 0))
      {
      _pdm_debug("parent part found", 0);
      parent_level = assy_list->new_level;
      level = parent_level + 1;
      _pdm_debug("parent_level = <%d>", (char *)parent_level);
      if (assy_list)
        {
        _pdm_debug("moving on to next node", 0);
        assy_list = assy_list->next;
        }
      else
        return;

      _pdm_debug("find matching row in global list", 0);
      current_rev_assy = PDU_assy_ptr;
      while (current_rev_assy)
        {
        if (current_rev_assy->mcf_row == assy_list->mcf_row)
          break;
        current_rev_assy = current_rev_assy->next;
        }

      _pdm_debug("searching for multiple occurrence of child part", 0);
      while (current_rev_assy)
        {
        _pdm_debug("comparing part info", 0);
        _pdm_debug("delete = <%s>", current_rev_assy->delete);
        _pdm_debug("new level = %d", (char *)current_rev_assy->new_level);
        if ((strcmp(current_rev_assy->new_catalog, catalog) == 0) &&
            (strcmp(current_rev_assy->new_partid, partid) == 0) &&
            (strcmp(current_rev_assy->new_revision, revision) == 0) &&
            (current_rev_assy->new_level == (parent_level + 1)))
          {
          if (strcmp(current_rev_assy->delete, "Y") == 0)
            {
            _pdm_debug("found part already marked for delete", 0);
            break;
            }

          _pdm_debug("multiple occurrence found", 0);
          strcpy(current_rev_assy->delete, "Y");
          PDUupdate_mult_files_for_rev_assy("delete", "Y");
          mcf_row = current_rev_assy->mcf_row;
          PDUfill_in_string(&displayed, current_rev_assy->display);

          if (strcmp(displayed, "Y") == 0)
            {
            _pdm_debug("marking part in mcf", 0);
            FIfld_set_text(fp, REV_MCF, mcf_row, CAT_COL,  msg, FALSE);
            FIfld_set_text(fp, REV_MCF, mcf_row, PART_COL, msg, FALSE);
            FIfld_set_text(fp, REV_MCF, mcf_row, REV_COL,  msg, FALSE);
            FIfld_set_text(fp, REV_MCF, mcf_row, DESC_COL, msg, FALSE);
            FIfld_set_text(fp, REV_MCF, mcf_row, LOCFILE_COL,NULL_STRING,FALSE);
            FIfld_set_text(fp, REV_MCF, mcf_row, STGFILE_COL,NULL_STRING,FALSE);
            }

          if (current_rev_assy)
            current_rev_assy = current_rev_assy->next;
          else
            break;
    
          _pdm_debug("searching for children", 0);
          while (current_rev_assy)
            {
            if (current_rev_assy->ex_level > level)
              {
              strcpy(current_rev_assy->delete, "Y");
              PDUupdate_mult_files_for_rev_assy("delete", "Y");
              }
            else if (current_rev_assy->ex_level == -1)
              {
              strcpy(current_rev_assy->delete, "Y");  /* multiple file */
              PDUupdate_mult_files_for_rev_assy("delete", "Y");
              }
            else
              break;
            current_rev_assy = current_rev_assy->next;
            }

          if (strcmp(displayed, "Y") == 0)
            {
            _pdm_debug("marking children in mcf", 0);
            FIfld_get_num_rows(fp, REV_MCF, &num_rows);
            for (row = mcf_row; row < num_rows; ++row)
               {
               FIfld_get_text_length(fp,REV_MCF,row,EXLEV_COL,&length);
               text = (char *)malloc(sizeof(char) * length + 1);
               memset(text,NULL,sizeof(char) * length + 1);
               FIfld_get_text(fp,REV_MCF,row,EXLEV_COL,length,
                   (unsigned char *)text, &select, &pos);
               _pdm_debug("level = %s",text);
   
               tmp_level = atoi(text);
   
               if (tmp_level > level)
                {
                 _pdm_debug("setting text on row %d", (char *)row);
                 FIfld_set_text(fp, REV_MCF, row, CAT_COL,  msg, FALSE);
                 FIfld_set_text(fp, REV_MCF, row, PART_COL, msg, FALSE);
                 FIfld_set_text(fp, REV_MCF, row, REV_COL,  msg, FALSE);
                 FIfld_set_text(fp, REV_MCF, row, DESC_COL, msg, FALSE);
                 FIfld_set_text(fp, REV_MCF, row,LOCFILE_COL,NULL_STRING,FALSE);
                 FIfld_set_text(fp, REV_MCF, row,STGFILE_COL,NULL_STRING,FALSE);
                 }
               else if (tmp_level == -1)
                 {
                 _pdm_debug("multiple file on row %d", (char *)row);
                 FIfld_set_text(fp, REV_MCF, row,LOCFILE_COL,NULL_STRING,FALSE);
                 FIfld_set_text(fp, REV_MCF, row,STGFILE_COL,NULL_STRING,FALSE);
                 }
               else
                 break;
               }
            }
          }
        else
          {
          _pdm_debug("skipping row <%d>", current_rev_assy->mcf_row);
          }
        if (current_rev_assy)
          current_rev_assy = current_rev_assy->next;
        else
          break;
        }
      }
    if (assy_list)
      assy_list = assy_list->next;
    }

  _pdm_debug("exiting PDUdelete_multiple_occurrences", 0);
  return;
}

void PDUundelete_multiple_occurrences(catalog, partid, revision, level,
                                    parent_cat, parent_part, parent_rev)
char   *catalog;
char   *partid;
char   *revision;
int    level;
char   *parent_cat;
char   *parent_part;
char   *parent_rev;
{

  int   row = 0;
  int   mcf_row = 0;
  int   length, pos, select;
  int   parent_level = 0;
  int   num_rows = 0;
  int   tmp_level = 0;
  static char *text = NULL;
  char  *displayed = NULL;
  Form  fp;
  struct PDUrev_assy *assy_list = NULL;

  _pdm_debug("in the function PDUundelete_multiple_occurrences", 0);

  _pdm_debug("parent_cat = <%s>", parent_cat);
  _pdm_debug("parent_part = <%s>", parent_part);
  _pdm_debug("parent_rev = <%s>", parent_rev);

  _pdm_debug("child catalog = <%s>", catalog);
  _pdm_debug("child partid = <%s>", partid);
  _pdm_debug("child revision = <%s>", revision);

  fp = forms.rev_assy_form_id;

  current_rev_assy = PDU_assy_ptr;
  assy_list = PDU_assy_ptr;

  while (assy_list)
    {
    if ((strcmp(assy_list->new_catalog, parent_cat) == 0) &&
        (strcmp(assy_list->new_partid, parent_part) == 0) &&
        (strcmp(assy_list->new_revision, parent_rev) == 0))
      {
      _pdm_debug("parent part found", 0);
      parent_level = assy_list->new_level;
      level = parent_level + 1;
      _pdm_debug("parent_level = <%d>", (char *)parent_level);
      if (assy_list)
        {
        _pdm_debug("moving on to next node", 0);
        assy_list = assy_list->next;
        }
      else
        return;

      _pdm_debug("find matching row in global list", 0);
      current_rev_assy = PDU_assy_ptr;
      while (current_rev_assy)
        {
        if (current_rev_assy->mcf_row == assy_list->mcf_row)
          break;
        current_rev_assy = current_rev_assy->next;
        }

      _pdm_debug("searching for multiple occurrence of child part", 0);
      while (current_rev_assy)
        {
        _pdm_debug("delete = <%s>", current_rev_assy->delete);
        _pdm_debug("new level = %d", (char *)current_rev_assy->new_level);
        if ((strcmp(current_rev_assy->new_catalog, catalog) == 0) &&
            (strcmp(current_rev_assy->new_partid, partid) == 0) &&
            (strcmp(current_rev_assy->new_revision, revision) == 0) &&
            (current_rev_assy->new_level == (parent_level + 1)) &&
            (strcmp(current_rev_assy->delete, "Y") == 0))
          {
          _pdm_debug("multiple occurrence found", 0);
          strcpy(current_rev_assy->delete, "N");
          PDUupdate_mult_files_for_rev_assy("delete", "N");
          mcf_row = current_rev_assy->mcf_row;
          PDUfill_in_string(&displayed, current_rev_assy->display);

          if (strcmp(displayed, "Y") == 0)
            {
            _pdm_debug("marking part in mcf", 0);
  
            if (current_rev_assy->new_catalog)
              FIfld_set_text(fp, REV_MCF, mcf_row, CAT_COL,
                             current_rev_assy->new_catalog, FALSE);
            if (current_rev_assy->new_partid)
              FIfld_set_text(fp, REV_MCF, mcf_row, PART_COL,
                             current_rev_assy->new_partid, FALSE);
            if (current_rev_assy->new_revision)
              FIfld_set_text(fp, REV_MCF, mcf_row, REV_COL,
                             current_rev_assy->new_revision, FALSE);
            if (current_rev_assy->new_desc)
              FIfld_set_text(fp, REV_MCF, mcf_row, DESC_COL,
                           current_rev_assy->new_desc, FALSE);
            if (current_rev_assy->new_cofilename)
              FIfld_set_text(fp, REV_MCF, mcf_row, LOCFILE_COL,
                           current_rev_assy->new_cofilename, FALSE);
            if (current_rev_assy->new_cifilename)
              FIfld_set_text(fp, REV_MCF, mcf_row, STGFILE_COL,
                           current_rev_assy->new_cifilename, FALSE);
            }

          if (current_rev_assy)
            current_rev_assy = current_rev_assy->next;
          else
            break;
    
          _pdm_debug("searching for children", 0);
          while (current_rev_assy)
            {
            if (current_rev_assy->ex_level > level)
              {
              strcpy(current_rev_assy->delete, "N");
              PDUupdate_mult_files_for_rev_assy("delete", "N");
              }
            else if (current_rev_assy->ex_level == -1)
              {
              strcpy(current_rev_assy->delete, "N");  /* multiple file */
              PDUupdate_mult_files_for_rev_assy("delete", "N");
              }
            else
              break;
            current_rev_assy = current_rev_assy->next;
            }

          if ((strcmp(displayed, "Y") == 0) && (current_rev_assy))
            {
            _pdm_debug("marking children in mcf", 0);
            FIfld_get_num_rows(fp, REV_MCF, &num_rows);
            for (row = mcf_row; row < num_rows; ++row)
               {
               _pdm_debug("row = %d", (char *)row);
               FIfld_get_text_length(fp,REV_MCF,row,EXLEV_COL,&length);
               text = (char *)malloc(sizeof(char) * length + 1);
               memset(text,NULL,sizeof(char) * length + 1);
               FIfld_get_text(fp,REV_MCF,row,EXLEV_COL,length,
                   (unsigned char *)text, &select, &pos);
               _pdm_debug("level = %s",text);
   
               tmp_level = atoi(text);
   
               if (tmp_level > level)
                {
                 _pdm_debug("setting text on row %d", (char *)row);
                 if (current_rev_assy->new_catalog)
                   FIfld_set_text(fp, REV_MCF, row, CAT_COL,
                                  current_rev_assy->new_catalog, FALSE);
                 if (current_rev_assy->new_partid)
                   FIfld_set_text(fp, REV_MCF, row, PART_COL,
                                  current_rev_assy->new_partid, FALSE);
                 if (current_rev_assy->new_revision)
                   FIfld_set_text(fp, REV_MCF, row, REV_COL,
                                  current_rev_assy->new_revision, FALSE);
                 if (current_rev_assy->new_desc)
                   FIfld_set_text(fp, REV_MCF, row, DESC_COL,
                                  current_rev_assy->new_desc, FALSE);
                 if (current_rev_assy->new_cofilename)
                   FIfld_set_text(fp, REV_MCF, row, LOCFILE_COL,
                                current_rev_assy->new_cofilename, FALSE);
                 if (current_rev_assy->new_cifilename)
                   FIfld_set_text(fp, REV_MCF, row, STGFILE_COL,
                                current_rev_assy->new_cifilename, FALSE);
                 }
               else if (tmp_level == -1)
                 {
                 _pdm_debug("multiple file on row %d", (char *)row);
                 if (current_rev_assy->new_cofilename)
                   FIfld_set_text(fp, REV_MCF, row, LOCFILE_COL,
                                current_rev_assy->new_cofilename, FALSE);
                 if (current_rev_assy->new_cifilename)
                   FIfld_set_text(fp, REV_MCF, row, STGFILE_COL,
                                current_rev_assy->new_cifilename, FALSE);
                 }
               else
                 break;
               }
            }
          }
        else
          {
          _pdm_debug("skipping row <%d>", current_rev_assy->mcf_row);
          }
        if (current_rev_assy)
          current_rev_assy = current_rev_assy->next;
        else
          break;
        }
      }
    if (assy_list)
      assy_list = assy_list->next;
    }

  _pdm_debug("exiting PDUdelete_multiple_occurrences", 0);
  return;
}

/* This function traverses through the assembly link list and changes the 
   catalog, partid, revision and description entries for parts that have been 
   marked for delete */

void PDUmark_deleted_parts_for_revise_assy()
{
  char *msg = NULL;
  
  _pdm_debug("PDUmark_deleted_parts_for_revise_assy", 0);

  current_rev_assy = PDU_assy_ptr;

  msg = (char *)PDUtranslate_message(PDM_I_DELETED);

  while (current_rev_assy)
    {
    if (strcmp(current_rev_assy->delete, "Y") == 0)
      {
      _pdm_debug("part found", 0);

      strcpy(current_rev_assy->add, "N");
      strcpy(current_rev_assy->add_db, "N");
      PDUupdate_mult_files_for_rev_assy("add", "N");
      PDUupdate_mult_files_for_rev_assy("add_db", "N");

      PDUfill_in_string(&(current_rev_assy)->new_catalog, msg);
      PDUfill_in_string(&(current_rev_assy)->new_partid, msg);
      PDUfill_in_string(&(current_rev_assy)->new_revision, msg);
      PDUfill_in_string(&(current_rev_assy)->new_desc, msg);
      PDUfill_in_string(&(current_rev_assy)->new_cofilename, NULL_STRING);
      PDUfill_in_string(&(current_rev_assy)->new_cifilename, NULL_STRING);

      _pdm_debug("checking for buffers", 0);
      if (current_rev_assy->new_attr_data)
        {
        free_attr_data_buffer(&current_rev_assy->new_attr_data);
        current_rev_assy->new_attr_data = NULL;
        }
      if (current_rev_assy->ex_attr_data)
        {
        free_attr_data_buffer(&current_rev_assy->ex_attr_data);
        current_rev_assy->ex_attr_data = NULL;
        }
      }
    current_rev_assy = current_rev_assy->next;
    }

  _pdm_debug("exiting PDUmark_deleted_parts_for_revise_assy", 0);

  return;
}

int PDUprocess_rev_assy_form(assy_bufr)
  MEMptr   assy_bufr;
{
  int   status = PDM_S_SUCCESS;
  char  *title = NULL;
  extern void PDUactive_part_form();
  extern void PDUdelete_active_part_form();

  _pdm_debug("in the function PDUprocess_rev_assy_form", 0);

  status = PDUcheck_assembly_for_file_creation();
  _pdm_status("PDUcheck_assembly_for_file_creation", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  if (status == 0)
    status = PDM_S_SUCCESS;

  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUmodify_assembly_thru_OBJ2(assy_bufr);
  _pdm_status("PDUmodify_assembly_thru_OBJ2", status);
  
  if (status == 0)
    status = PDM_S_SUCCESS;

  if (status != PDM_S_SUCCESS)
    return(status);

  _pdm_debug("check file status of level 0 part", 0);
  current_rev_assy = PDU_assy_ptr;
  status = PDUverify_file(current_rev_assy->new_cofilename);
  _pdm_status("PDUverify_file", status);
  if (status == PDM_S_SUCCESS)
    {
    _pdm_debug("check the file status of the NEW assembly part", 0);
    status = PDMrcheck_part_status(current_rev_assy->new_catalog,
                                   current_rev_assy->new_partid,
                                   current_rev_assy->new_revision);
    _pdm_status("PDMrcheck_part_status", status);
    if ((status == PDM_I_CHECKED_OUT_BY_YOU) || 
        (status == PDM_I_NEVER_CHECKED_IN))
      {
      _pdm_debug("check in the part", 0);
      PDUfill_in_string(&refresh->rev_catalog,
                         current_rev_assy->new_catalog);
      PDUfill_in_string(&refresh->rev_partid,
                         current_rev_assy->new_partid);
      PDUfill_in_string(&refresh->rev_revision,
                         current_rev_assy->new_revision);
      PDUfill_in_string(&refresh->rev_parttype,
                         current_rev_assy->new_parttype);

      PDUdelete_active_part_form();

      /* display active part form */
      title = (char *)PDUtranslate_message(PDM_I_CHECKING_PART_IN);
      PDUactive_part_form(current_rev_assy->new_catalog,
                          current_rev_assy->new_partid,
                          current_rev_assy->new_revision,
                          current_rev_assy->new_desc, title);
      if (title) free(title);

      status = PDUcheckin();
      _pdm_status("PDUcheckin", status);

      PDUdelete_active_part_form();

      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status);
        return(status);
        }
      }
    }
  else
    {
    _pdm_debug("assembly file is not local; bypass checkin", 0);
    status = PDM_S_SUCCESS;
    }

  PDU_new_assembly = FALSE;

  PDUdelete_active_part_form();

  _pdm_debug("Exit:  PDUprocess_rev_assy_form", 0);
  return(status);
}

int PDUcopy_files_for_revise_assembly(newfile_list, exfile_list, file_count)
  char   newfile_list[10][15];
  char   exfile_list[10][15];
  int    file_count;
{
  int   status = PDM_S_SUCCESS;
  int   row = 0;
  int   level = 0;
  int   catno = 0;
  int   itemno = 0;
  int   parent_level = 0;
  int   ref_count = 0;
  int   save_row = 0;
  int   current_level = 0;
  int   fildes[2];
  short delete_file = FALSE;
  short in_list = FALSE;
  short check_ref_files = FALSE;
  char  path[80];
  char  answer[2];
  char  sql_str[1024];
  char  *save_filename = NULL;
  char  *prompt_str = NULL;
  char  *title = NULL;
  char  *add_msg = NULL;
  char  *catstr = NULL;
  char  *itemstr = NULL;
  char  *refstr = NULL;
  char  **data = NULL;
  pid_t child = 0;
  mode_t mode;
  register int ret_status;
  MEMptr bufr = NULL;
  MEMptr return_bufr = NULL;
  MEMptr copy_bufr = NULL;
  struct PDUrev_assy *temp_list = NULL;
  struct PDUfile_list *copied_files = NULL;
  struct PDUparts_list *list = NULL;
  struct PDUparts_list *attach_list = NULL;
  extern void PDUactive_part_form();
  extern void PDUdelete_active_part_form();
  extern int PDUcopy_files_for_revise_assembly();

  _pdm_debug("in the function PDUcopy_files_for_revise_assembly", 0);

  _pdm_debug("from part has %d files", file_count);
     
  for (row = 0; row < file_count; ++row)
     {
     check_ref_files = FALSE;
     _pdm_debug("new file is <%s>", newfile_list[row]);

     if (!(newfile_list[row]))
       {
       _pdm_debug("new filename is blank", 0);
       continue;
       }

     if (!strlen(newfile_list[row]))
       {
       _pdm_debug("new filename is blank", 0);
       continue;
       }

     /* check to see if the new file already exists */
     status = PDUverify_file(newfile_list[row]);
     _pdm_status("PDUverify_file", status);
     if (status == PDM_S_SUCCESS)
       {
       _pdm_debug("new file is already local", 0);
       prompt_str = (char *)PDUtranslate_message_and_vars(PDP_P_FILE_EXISTS,
                                                          newfile_list[row]);
       UI_prompt(prompt_str);
       do
         {
         status = PDUget_keyin(answer);

         if ((answer) && (strlen(answer) > 0) &&
             (strcmp(answer,"y")) && (strcmp(answer,"Y")) &&
             (strcmp(answer,"n")) && (strcmp(answer,"N")))
           {
           status = PDM_E_INVALID_INPUT;
           }
         }
       while (status == PDM_E_INVALID_INPUT);
       UI_prompt(NULL_STRING);

       _pdm_debug("answer = <%s>", answer);

       if ((strcmp(answer, "n")== 0) || (strcmp(answer, "N")==0))
         {
         _pdm_debug("user selected not to overwrite file", 0);

/*  11/29/95 - MJG - TR 139528373 - check the permissions on the new file */
         _pdm_debug("checking file permissions", 0);
         PDUfill_in_string(&save_filename, refresh->act_filename);
         PDUfill_in_string(&refresh->act_filename, newfile_list[row]);
         status = PDUcheck_file_permissions();
         _pdm_status("PDUcheck_file_permissions", status);
         if (!status)
           {
           _pdm_debug("file is read-only; changing mode of new file", 0);
           mode = S_IRUSR | S_IRGRP | S_IROTH | S_IWUSR | S_IWGRP;
           status = PDUchange_file_permissions(newfile_list[row], mode);
           _pdm_status("PDUchange_file_permissions", status);
           }
         PDUfill_in_string(&refresh->act_filename, save_filename);
         status = PDM_S_SUCCESS;
         if (save_filename)
           {
           free(save_filename);
           save_filename = NULL;
           }
 
/* 12/2/95 MJG - Add file to list of copied files */
         _pdm_debug("adding copied file to list", 0);
         copied_files = PDU_copied_files;
         status = PDUadd_file_to_list(newfile_list[row], &copied_files);
         _pdm_status("PDUadd_file_to_list", status);
         PDU_copied_files = copied_files;

         continue;
         }
       }
      
     _pdm_debug("existing file is <%s>", exfile_list[row]);
     status = PDUverify_file(exfile_list[row]);
     _pdm_status("PDUverify_file", status);

     if (status == PDM_E_FILE_NOT_FOUND)
       {
       _pdm_debug("file <%s> is not local", exfile_list[row]);

       status = PDMrcheck_part_status(current_rev_assy->ex_catalog,
                                      current_rev_assy->ex_partid,
                                      current_rev_assy->ex_revision);
       _pdm_status("PDMrcheck_part_status", status);
       PDUmessage(PDM_E_CLEAR_FIELD,'s');

       if (status == PDM_I_NEVER_CHECKED_IN)
         {
         _pdm_debug("FROM part files do not exist", 0);

/* if the from part is different from the to part and ADD = Y, check the 
   children.  If the from and to parts are the same and ADD = N, set ADD to Y */

         /* check to see if part info has been changed */
         if ((strcmp(current_rev_assy->add, "Y") == 0) ||
            ((strcmp(current_rev_assy->ex_catalog,
                     current_rev_assy->new_catalog) != 0) ||
             (strcmp(current_rev_assy->ex_partid,
                     current_rev_assy->new_partid) != 0) ||
             (strcmp(current_rev_assy->ex_revision,
                     current_rev_assy->new_revision) != 0)))
           {
           _pdm_debug("save place in current_rev_assy", 0);
           save_row = current_rev_assy->mcf_row;
           current_level = current_rev_assy->ex_level;
           _pdm_debug("current_level = %d", (char *)current_level);
           current_rev_assy = current_rev_assy->next;

           add_msg = (char *)PDUtranslate_message(PDM_I_ADDED_ROW);

           while ((current_rev_assy) &&
                  (current_rev_assy->ex_level != current_level))
             {
             if ((current_rev_assy->new_level == current_level + 1) &&
                 (strcmp(current_rev_assy->delete, "Y") != 0) &&
                 (strcmp(current_rev_assy->add, "Y") != 0) &&
                 (strcmp(current_rev_assy->ex_catalog, add_msg) != 0))
               {
               _pdm_debug("set add to Y for child part", 0);
               strcpy(current_rev_assy->add, "Y");
               PDUupdate_mult_files_for_rev_assy("add", "Y");
               }
             current_rev_assy = current_rev_assy->next;
             }

           _pdm_debug("reset current_rev_assy", 0);
           current_rev_assy = PDU_assy_ptr;
           while (current_rev_assy)
             {
             if (current_rev_assy->mcf_row == save_row)
               break;
             current_rev_assy = current_rev_assy->next;
             }
           _pdm_debug("active row is %d", current_rev_assy->mcf_row);
           }
         status = PDM_S_SUCCESS;
         continue;
         }
       else if ((status == PDM_I_CHECKED_OUT_BY_YOU) ||
                (status == PDM_I_CHECKED_OUT_BY_ANOTHER_USER) ||
                (status == PDM_I_CHECKED_IN) ||
                (status == PDM_I_COPIED_TO_LOCAL_BY_YOU) ||
                (status == PDM_I_ATTACHED_TO_LOCAL_ASSY))
          {
          _pdm_debug("create buffer for copy", 0);
          status = PDUcreate_copy_buffer_for_rev_assy(&copy_bufr);
          _pdm_status("PDUcreate_copy_buffer_for_rev_assy", status);
          if (status != PDM_S_SUCCESS)
            return(status);

          /* display active part form */
          title = (char *)PDUtranslate_message(PDM_I_COPYING_FILES);
          PDUactive_part_form(current_rev_assy->ex_catalog,
                              current_rev_assy->ex_partid,
                              current_rev_assy->ex_revision,
                              current_rev_assy->ex_desc, title);
          if (title) free(title);

          _pdm_debug("Copying file to local",0);
          status = PDMcopy(copy_bufr, &return_bufr);
          _pdm_status("PDMcopy", status);
          MEMclose(&return_bufr);  return_bufr = NULL;
          MEMclose(&copy_bufr);  copy_bufr = NULL;

          if (forms.active_part_form_id)
            {
            FIf_erase(forms.active_part_form_id);
            FIf_delete(forms.active_part_form_id);
            forms.active_part_form_id = 0;
            }
          if (status != PDM_S_SUCCESS)
            {
            _pdm_debug("error copying files to local", 0);
            return(status);
            }
          _pdm_debug("setting delete flag to TRUE", 0);
          delete_file = TRUE;
          }
       }
     else
       {
       _pdm_debug("file <%s> is already local", exfile_list[row]);

       PDUfill_in_string(&refresh->rev_filename, exfile_list[row]);

       _pdm_debug("checking file permissions", 0);
       PDUfill_in_string(&save_filename, refresh->act_filename);
       PDUfill_in_string(&refresh->act_filename, refresh->rev_filename);
       status = PDUcheck_file_permissions();
       _pdm_status("PDUcheck_file_permissions", status);
       if (!status)
         PDU_read_only_file = TRUE;
       PDUfill_in_string(&refresh->act_filename, save_filename);
       status = PDM_S_SUCCESS;
       if (save_filename)
         {
         free(save_filename);
         save_filename = NULL;
         }
       }

     status = PDUcheck_if_graphic(exfile_list[row]);
     _pdm_status("PDUcheck_if_graphic",status);
     if (status == PDM_S_SUCCESS)
       {
       _pdm_debug("File <%s> is graphic",exfile_list[row]);
       _pdm_debug("Do a copyOS",0);
  
       _pdm_debug("checking to see if file is open", 0);
       status = PDUis_file_open(exfile_list[row]);
       _pdm_status("PDUis_file_open", status);
       if (status == 1)
         {
         _pdm_debug("design file is open", 0);
         return(PDM_E_COPY_OPEN_FILE);
         }
  
       /* get path of exnuc on workstation */
       _pdm_debug("Getting path of EXNUC", 0);
       status = PDUget_exnuc_path(path);
       _pdm_status("PDUget_exnuc_path returns", status);
  
       if (status != PDM_S_SUCCESS)
         {
         _pdm_debug("failed to get EXNUC path", 0);
         return(status);
         }
  
       strcat(path, "bin/copyOS");
       _pdm_debug("Path is <%s>", path);
  
       /* forking  a child */
       /* The return statuses of vfork can be
          <  0 i.e the fork failed
          >  0  i.e it's the parent itself
          =  0   i.e it's the child process
       */
  
#if defined (__sgi)
       if ((child = fork()) == -1)
          {
          _pdm_debug("FORK failed",0);
          return(PDM_E_COPY_OPEN_FILE);
          }
#else
       if ((child = vfork()) == -1)
          {
          _pdm_debug("VFORK failed",0);
          return(PDM_E_COPY_OPEN_FILE);
          }
#endif
       else if((child == 0)) /* child = 0. Do the copyOS */
          {
          _pdm_debug("Execute the copyOS",0);
          ret_status = execlp(path,path,exfile_list[row], 
                              newfile_list[row],(char *)0);
          if (ret_status == -1)
             {
             _pdm_debug("copyOS failed",0);
             return(PDM_E_COPY_OBJECT_SPACE);
             }
          else
             {
             _pdm_debug("copyOS was Successful",0); 
             }
          }
  
       if (waitpid(child,NULL,0) < 0)
          _pdm_debug("Wait Error", 0);

       check_ref_files = TRUE;
       }
     else
       {
       _pdm_debug("File <%s> is not graphic",exfile_list[row]);
       _pdm_debug("Do a unix copy",0);
       strcpy(path, "/bin/cp");
       _pdm_debug("Path is <%s>", path);
       if (pipe(fildes) == 0)
          {
#if defined (__sgi)
          if (ret_status = fork())
             {
             if (ret_status != -1)
                {
                close(fildes[0]);
                close(fildes[1]);
                }
              }
#else
          if (ret_status = vfork())
             {
             if (ret_status != -1)
                {
                close(fildes[0]);
                close(fildes[1]);
                }
             }
#endif
          else
             {
             _pdm_debug("copying file", 0);
             close(fileno(stdout));
             dup(fildes[1]);
             close(fildes[1]);
             execl(path, path, exfile_list[row], newfile_list[row], (char *)0);
             }
          }
       }

     _pdm_debug("changing mode of new file", 0);
     mode = S_IRUSR | S_IRGRP | S_IROTH | S_IWUSR | S_IWGRP;
     status = PDUchange_file_permissions(newfile_list[row], mode);
     _pdm_status("PDUchange_file_permissions", status);

     _pdm_debug("verifying new file <%s>", newfile_list[row]);
     status = PDUverify_file(newfile_list[row]);
     _pdm_status("PDUverify_file", status);
     if (status != PDM_S_SUCCESS)
       {
       _pdm_debug("error copying files", 0);
       return(PDM_E_ERROR_COPYING_FILES);
       }

/* 12/2/95 MJG - Add file to list of copied files */
       _pdm_debug("adding copied file to list", 0);
       copied_files = PDU_copied_files;
       status = PDUadd_file_to_list(newfile_list[row], &copied_files);
       _pdm_status("PDUadd_file_to_list", status);
       PDU_copied_files = copied_files;
     }
/* END 12/2/95 */

  for (row = 0; row < file_count; ++row)
     {
     if ((file_count > 1) && (check_ref_files))
       {
       _pdm_debug("calling PDUupdate_ref_files_for_rev_assy", 0);
       status = PDUupdate_ref_files_for_rev_assy(exfile_list[row],
						newfile_list[row],
						exfile_list,
						newfile_list,
						file_count);
       _pdm_status("PDUupdate_ref_files_for_rev_assy", status);
       if (status != PDM_S_SUCCESS)
         return(status);
       }
     }

  /* Check to see if part is an assembly with children that need to be copied.
     If so, do not delete the file yet.  */

  if (!delete_file)
    {
    _pdm_debug("Exit:  PDUcopy_files_for_revise_assembly", 0);
    return(PDM_S_SUCCESS);
    }

  _pdm_debug("check to see if other files need to be copied", 0);

  add_msg = (char *)PDUtranslate_message(PDM_I_ADDED_ROW);

  temp_list = current_rev_assy;

  level = current_rev_assy->ex_level;

  current_rev_assy = current_rev_assy->next;

  while ((current_rev_assy) && (current_rev_assy->ex_level == -1))
    current_rev_assy = current_rev_assy->next;

  while (current_rev_assy)
    {
    if (current_rev_assy->ex_level == level)
      {
      _pdm_debug("reached part at same placement level", 0);
      break;
      }
    else if (current_rev_assy->ex_level == -1)
      {
      current_rev_assy = current_rev_assy->next;
      continue;
      }

    if ((strcmp(current_rev_assy->add, "Y") == 0) &&
        (strcmp(current_rev_assy->ex_catalog, add_msg) != 0))
      {
      _pdm_debug("check status of new part", 0);
      status = PDMrcheck_part_status(current_rev_assy->new_catalog,
                                     current_rev_assy->new_partid,
                                     current_rev_assy->new_revision);
      _pdm_status("PDMrcheck_part_status", status);
      if ((status == PDM_I_CHECKED_IN) || 
          (status == PDM_I_COPIED_TO_LOCAL_BY_YOU) ||
          (status == PDM_I_ATTACHED_TO_LOCAL_ASSY))
        {
        status = PDM_S_SUCCESS;
        current_rev_assy = current_rev_assy->next;
        continue;
        }

      if ((status == PDM_I_NEVER_CHECKED_IN) &&
          (strcmp(current_rev_assy->new_cofilename, NULL_STRING) != 0))
        {
        status = PDM_S_SUCCESS;
        status = PDUverify_file(current_rev_assy->new_cofilename);
        _pdm_status("PDUverify_file", status);
        if (status == PDM_S_SUCCESS)
          {
          _pdm_debug("new file is already local", 0);

  _pdm_debug("make sure file has not already been copied at another level", 0);
          copied_files = PDU_copied_files;
          in_list = PDUis_file_in_list(current_rev_assy->new_cofilename,
                                       copied_files);
          _pdm_debug("PDUis_file_in_list returns %d", (char *)in_list);
          if (in_list)
            {
            _pdm_debug("file has already been copied", 0);
            current_rev_assy = current_rev_assy->next;
            continue;
            }

/*  11/29/95 - MJG - TR 139528373 - check the permissions on the new file */

          prompt_str = (char *)PDUtranslate_message_and_vars(PDP_P_FILE_EXISTS,
                                           current_rev_assy->new_cofilename);
          UI_prompt(prompt_str);
          do
            {
            status = PDUget_keyin(answer);
   
            if ((answer) && (strlen(answer) > 0) &&
                (strcmp(answer,"y")) && (strcmp(answer,"Y")) &&
                (strcmp(answer,"n")) && (strcmp(answer,"N")))
              {
              status = PDM_E_INVALID_INPUT;
              }
            }
          while (status == PDM_E_INVALID_INPUT);
          UI_prompt(NULL_STRING);
   
          _pdm_debug("answer = <%s>", answer);
   
          if ((strcmp(answer, "n")== 0) || (strcmp(answer, "N")==0))
            {

            _pdm_debug("checking file permissions", 0);
            PDUfill_in_string(&save_filename, refresh->act_filename);
            PDUfill_in_string(&refresh->act_filename, 
                              current_rev_assy->new_cofilename);
            status = PDUcheck_file_permissions();
            _pdm_status("PDUcheck_file_permissions", status);
            if (!status)
              {
              _pdm_debug("file is read-only; changing mode of new file", 0);
              mode = S_IRUSR | S_IRGRP | S_IROTH | S_IWUSR | S_IWGRP;
              status = PDUchange_file_permissions(
                                      current_rev_assy->new_cofilename, mode);
              _pdm_status("PDUchange_file_permissions", status);
              }
            PDUfill_in_string(&refresh->act_filename, save_filename);
            status = PDM_S_SUCCESS;
            if (save_filename)
              {
              free(save_filename);
              save_filename = NULL;
              }

            _pdm_debug("adding copied file to list", 0);
            copied_files = PDU_copied_files;
            status = PDUadd_file_to_list(current_rev_assy->new_cofilename, 
                                         &copied_files);
            _pdm_status("PDUadd_file_to_list", status);
            PDU_copied_files = copied_files;

            current_rev_assy = current_rev_assy->next;
            continue;
            }
          }
        else
          status = PDM_S_SUCCESS;
        }

      if (strcmp(current_rev_assy->new_cofilename, NULL_STRING) != 0)
        {
        _pdm_debug("make sure parts are not the same", 0);
        
        if ((strcmp(current_rev_assy->ex_catalog,
                    current_rev_assy->new_catalog) == 0) &&
            (strcmp(current_rev_assy->ex_partid,
                    current_rev_assy->new_partid) == 0) &&
            (strcmp(current_rev_assy->ex_revision,
                    current_rev_assy->new_revision) == 0))
          {
          _pdm_debug("specially marked part; continue", 0);
          current_rev_assy = current_rev_assy->next;
          continue;
          }
       
        _pdm_debug("creating file lists", 0);
        status = PDUcreate_copy_file_lists_for_rev_assy(newfile_list,
                                                        exfile_list,
                                                        &file_count);
        _pdm_status("PDUcreate_copy_file_lists_for_rev_assy", status);
        if (status != PDM_S_SUCCESS)
          return(status);
     
        if (file_count == 0)
          continue;
  
        _pdm_debug("copying files of associated part", 0);
        status = PDUcopy_files_for_revise_assembly(newfile_list, exfile_list,
                                                   file_count);
        _pdm_status("PDUcopy_files_for_revise_assembly", status);
        if (status != PDM_S_SUCCESS)
          return(status);
        }
      }

    current_rev_assy = current_rev_assy->next;
    while ((current_rev_assy) && (current_rev_assy->ex_level == -1))
      current_rev_assy = current_rev_assy->next;
    }
  current_rev_assy = temp_list;

/* 1/12/96 MJG - TR 139528369 - Increment the ref count for the attached parts
   before calling delete local file */

  _pdm_debug("set ref count for nested parts", 0);

  if (current_rev_assy)
    parent_level = current_rev_assy->ex_level;
  else
    _pdm_debug("error current_rev_assy = NULL", 0);

  if (current_rev_assy)
    current_rev_assy = current_rev_assy->next;

  while ((current_rev_assy) && (current_rev_assy->ex_level != parent_level))
    {
    if (((strcmp(current_rev_assy->display, "Y") == 0) &&
         (strcmp(current_rev_assy->ex_catalog, add_msg) != 0) &&
         (strcmp(current_rev_assy->p_attached, "Y") == 0)) &&

        ((strcmp(current_rev_assy->ex_catalog, 
                 current_rev_assy->new_catalog) != 0) ||
         (strcmp(current_rev_assy->ex_partid, 
                 current_rev_assy->new_partid) != 0) ||
         (strcmp(current_rev_assy->ex_revision, 
                 current_rev_assy->new_revision) != 0)))
      {
      _pdm_debug("check if part has already been ref'd", 0);
      list = attach_list;
      in_list = PDUis_part_in_list(current_rev_assy->ex_catalog,
                                   current_rev_assy->ex_partid,
                                   current_rev_assy->ex_revision, list);
      _pdm_debug("PDUis_part_in_list returns <%d>", (char *)in_list);
      if (in_list)
        {
        _pdm_debug("ref count has already been incremented for this part", 0);
        current_rev_assy = current_rev_assy->next;
        continue;
        }

      _pdm_debug("child part found <%s>", current_rev_assy->p_usageid);
      _pdm_debug("get the catno and partno", 0);
      status = PDMget_catno_partno(current_rev_assy->ex_catalog,
				current_rev_assy->ex_partid,
				current_rev_assy->ex_revision,
				&catstr, &itemstr);
      _pdm_status("PDMget_catno_partno", status);
      catno = atoi(catstr);
      itemno = atoi(itemstr);

      sql_str[0] = '\0';

      sprintf(sql_str, "select n_ref from nfmsafiles where n_sano = %d  and n_catalogno = %d and n_itemno = %d ", storage->storage_no, catno, itemno );

      _pdm_debug("sql_str = <%s>", sql_str);
      status = SQLquery(sql_str, &bufr, 512);
      _pdm_status("SQLquery", status);
      if (status != SQL_S_SUCCESS)
        {
        if (bufr) MEMclose(&bufr);
        _pdm_debug("SQLquery failed", 0);
        return(PDM_E_ERROR_COPYING_FILES);
        }
    
      _pdm_debug("checking bufr for NULL", 0);
      if (!bufr)
        {
        _pdm_debug("SQL bufr is NULL", 0);
        return(PDM_E_ERROR_COPYING_FILES);
        }

      _pdm_debug("printing bufr", 0);
      if (PDMdebug_on)
        MEMprint_buffer("ref bufr", bufr, PDU_DEBUG_FILE);

      status = MEMbuild_array(bufr);
      _pdm_status("MEMbuild_array", status);
      if (status != MEM_S_SUCCESS)
        {
        if (bufr) MEMclose(&bufr);
        return(PDM_E_BUILD_BUFFER_ARRAY);
        }

      data = (char **) bufr->data_ptr;
      refstr = data[0];
      _pdm_debug("refstr = <%s>", (char *)refstr);

      if ((refstr) && (strlen(refstr)))
        ref_count = atoi(refstr);
      else
        ref_count = 0;
      ++ref_count;
      _pdm_debug("ref_count = %d", (char *)ref_count);

      if (bufr)
        {
        MEMclose(&bufr);
        bufr = NULL;
        }

      sql_str[0] = '\0';
      sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %d WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s", ref_count, storage->storage_no, catstr, itemstr);
      _pdm_debug("sql_str = <%s>", sql_str);
      _pdm_debug("calling SQLstmt", 0);
      status = SQLstmt(sql_str);
      _pdm_status("SQLstmt", status);
      if (status != SQL_S_SUCCESS)
        {
        _pdm_debug("error writing to NFMSAFILES table", 0);
        return(PDM_E_ERROR_COPYING_FILES);
        }

      list = attach_list;
      status = PDUadd_part_to_list(current_rev_assy->ex_catalog,
                                   current_rev_assy->ex_partid,
                                   current_rev_assy->ex_revision,
                                   "", "", "", "", &list);
      _pdm_status("PDUadd_part_to_list", status);
      attach_list = list;
      }

    current_rev_assy = current_rev_assy->next;
    }
  current_rev_assy = temp_list;

  _pdm_debug("removing copied files", 0);

  PDUfill_in_string(&refresh->rev_catalog, current_rev_assy->ex_catalog);
  PDUfill_in_string(&refresh->rev_partid, current_rev_assy->ex_partid);
  PDUfill_in_string(&refresh->rev_revision, current_rev_assy->ex_revision);
  PDUfill_in_string(&refresh->rev_filename, 
                    current_rev_assy->ex_cofilename);

  _pdm_debug("create buffer for delete", 0);
  status = PDUcreate_copy_buffer_for_rev_assy(&copy_bufr);
  _pdm_status("PDUcreate_copy_buffer_for_rev_assy", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDMrdelete_local_files(copy_bufr, &return_bufr);
  _pdm_status("PDMrdelete_local_files", status);
  MEMclose(&return_bufr);  return_bufr = NULL;
  MEMclose(&copy_bufr);  copy_bufr = NULL;
  if (status != PDM_S_SUCCESS)
    _pdm_debug("ERROR removing files",0);

  _pdm_debug("Exit:  PDUcopy_files_for_revise_assembly", 0);
  return(status);
}

int PDUcheck_assembly_for_file_creation()
{
  int    status = PDM_S_SUCCESS;
  int    file_status = PDM_S_SUCCESS;
  int    file_count = 0;
  int    in_list = 0;
  int    i = 0;
  char   *add_msg = NULL;
  char   *title = NULL;
  char   newfile_list[10][15];
  char   exfile_list[10][15];
  MEMptr assy_bufr = NULL;
  extern void PDUactive_part_form();
  extern void PDUdelete_active_part_form();
  struct PDUfile_list *copied_files = NULL;

  _pdm_debug("in the function PDUcheck_assembly_for_file_creation", 0);

  add_msg = (char *)PDUtranslate_message(PDM_I_ADDED_ROW);

  current_rev_assy = PDU_assy_ptr;

  while (current_rev_assy)
    {
    if (current_rev_assy->ex_level == -1)
      {
      _pdm_debug("skipping multiple file", 0);
      current_rev_assy = current_rev_assy->next;
      continue;
      }

    if ((strcmp(current_rev_assy->add, "Y") == 0) &&
        (strcmp(current_rev_assy->ex_catalog, add_msg) == 0))
      {
      _pdm_debug("part does not have an associated existing part", 0);
      current_rev_assy = current_rev_assy->next;
      continue;
      }

    else if ((strcmp(current_rev_assy->add, "Y") == 0) &&
        (strcmp(current_rev_assy->ex_catalog, add_msg) != 0))
      {
      _pdm_debug("part has an associated existing part", 0);

/* Make sure ADD has not been set to Y because the parent part does not have
   files
*/
      if ((strcmp(current_rev_assy->ex_catalog,
                  current_rev_assy->new_catalog) == 0) &&
          (strcmp(current_rev_assy->ex_partid,
                  current_rev_assy->new_partid) == 0) &&
          (strcmp(current_rev_assy->ex_revision,
                  current_rev_assy->new_revision) == 0))
        {
        _pdm_debug("specially marked part; continue", 0);
        current_rev_assy = current_rev_assy->next;
        continue;
        }

/* 12/2/95 MJG - Check to see if file has already been copied */
      copied_files = PDU_copied_files;
      in_list = PDUis_file_in_list(current_rev_assy->new_cofilename, 
                                   copied_files);
      _pdm_debug("PDUis_file_in_list returns %d", (char *)in_list);
      if (in_list)
        {
        _pdm_debug("moving on to next file", 0);
        current_rev_assy = current_rev_assy->next;
        continue;
        }
/* END 12/2/95 */

/* 2/5/96 - if the TO part has ever been checked in, continue; files already
   exist */
      status = PDMrcheck_part_status(current_rev_assy->new_catalog,
                                     current_rev_assy->new_partid,
                                     current_rev_assy->new_revision);
      _pdm_status("PDMrcheck_part_status", status);
      if (status != PDM_I_NEVER_CHECKED_IN)
        {
        _pdm_debug("part files already exist; continue", 0);
        status = PDM_S_SUCCESS;
        current_rev_assy = current_rev_assy->next;
        continue;
        }

      if (strcmp(current_rev_assy->new_cofilename, NULL_STRING) != 0)
        {
        _pdm_debug("creating file lists", 0);
        status = PDUcreate_copy_file_lists_for_rev_assy(newfile_list,
                                                        exfile_list, 
                                                        &file_count);
        _pdm_status("PDUcreate_copy_file_lists_for_rev_assy", status);
        if (status != PDM_S_SUCCESS)
          return(status);

        if (file_count == 0)
          {
          _pdm_debug("file list is empty", 0);
          continue;
          }

        _pdm_debug("copying files of associated part", 0);
        status = PDUcopy_files_for_revise_assembly(newfile_list, exfile_list,
                                                   file_count);
        _pdm_status("PDUcopy_files_for_revise_assembly", status);
        if (status != PDM_S_SUCCESS)
          return(status);

        _pdm_debug("check to see if the part is an assembly", 0);
        status = PDMget_assembly_structure(current_rev_assy->ex_catalog,
                                           current_rev_assy->ex_partid,
                                           current_rev_assy->ex_revision,
                                           1, &assy_bufr, 0);
        _pdm_status("PDMget_assembly_structure", status);
    
        if ((status == PDM_E_PART_NOT_ASSEMBLY) ||
           ((assy_bufr) && (assy_bufr->rows == 1)) &&
           ((current_rev_assy->new_level != 0)))
          {
          if (assy_bufr)
            {
            MEMclose(&assy_bufr);
            assy_bufr = NULL;
            }

          file_status = 0;
/* files need to be verified because the parts files may not exist yet. */
          for (i = 0; i < file_count; ++i)
           {
             if (!(newfile_list[i]))
               continue;
             if (!strlen(newfile_list[i]))
               continue;

             _pdm_debug("verify the new files", 0);
             file_status = PDUverify_file(newfile_list[i]);
             _pdm_status("PDUverify_file", file_status);
             if (file_status != PDM_S_SUCCESS)
               {
               _pdm_debug("file <%s> was not found", newfile_list[i]);
               break;
               }
             }
          if ((file_status == PDM_S_SUCCESS) && (file_count > 0))
            {
            _pdm_debug("check in the part", 0);
            PDUfill_in_string(&refresh->rev_catalog, 
                               current_rev_assy->new_catalog);
            PDUfill_in_string(&refresh->rev_partid, 
                               current_rev_assy->new_partid);
            PDUfill_in_string(&refresh->rev_revision, 
                               current_rev_assy->new_revision);
            PDUfill_in_string(&refresh->rev_parttype, 
                               current_rev_assy->new_parttype);
  
            PDUdelete_active_part_form();

            /* display active part form */
            title = (char *)PDUtranslate_message(PDM_I_CHECKING_PART_IN);
            PDUactive_part_form(current_rev_assy->new_catalog,
                                current_rev_assy->new_partid,
                                current_rev_assy->new_revision,
                                current_rev_assy->new_desc, title);
            if (title) free(title);
  
            status = PDUcheckin();
            _pdm_status("PDUcheckin", status);
  
            PDUdelete_active_part_form();

            if (status != PDM_S_SUCCESS)
              return(status);
            }
          }
        else
          {
          _pdm_debug("existing part is an assy; files will not be copied",0);
          /* do nothing */
          }
        }
      else
        {
        _pdm_debug("no filename listed for new part", 0);
        status = PDM_S_SUCCESS;
        }
      }
    current_rev_assy = current_rev_assy->next;
    }

  if (add_msg) free(add_msg);

  _pdm_debug("Exit:  PDUcheck_assembly_for_file_creation", 0);
  return(status);
}

int PDUcreate_copy_file_lists_for_rev_assy(newfile_list,exfile_list,file_count)
char    newfile_list[10][15];
char    exfile_list[10][15];
int    *file_count;
{
  int	status = PDM_S_SUCCESS;
  int   index = 0;
  short parent_part = FALSE;
  struct PDUrev_assy *temp_list = NULL;

  _pdm_debug("in the function PDUcreate_copy_file_lists_for_rev_assy", 0);

  _pdm_debug("new_catalog = <%s>", current_rev_assy->new_catalog);
  _pdm_debug("new_partid = <%s>", current_rev_assy->new_partid);
  _pdm_debug("new_revision = <%s>", current_rev_assy->new_revision);
  _pdm_debug("ex_catalog = <%s>", current_rev_assy->ex_catalog);
  _pdm_debug("ex_partid = <%s>", current_rev_assy->ex_partid);
  _pdm_debug("ex_revision = <%s>", current_rev_assy->ex_revision);

  if ((strcmp(current_rev_assy->ex_catalog, 
              current_rev_assy->new_catalog) == 0) &&
      (strcmp(current_rev_assy->ex_partid,
              current_rev_assy->new_partid) == 0) &&
      (strcmp(current_rev_assy->ex_revision,
              current_rev_assy->new_revision) == 0))
    {
    _pdm_debug("parts are equal; resetting ADD to N", 0);
    strcpy(current_rev_assy->add, "N");
    PDUupdate_mult_files_for_rev_assy("add", "N");
    return(PDM_S_SUCCESS);
    }
  else if (current_rev_assy->ex_level == 0)
    {
    _pdm_debug("level = 0; resetting ADD to N", 0);
    strcpy(current_rev_assy->add, "N");
    PDUupdate_mult_files_for_rev_assy("add", "N");
    parent_part = TRUE;
    }

  /* initialize file list */
  for (index = 0; index < 10; ++index)
     {
     exfile_list[index][0] = '\0';
     newfile_list[index][0] = '\0';
     }

  *file_count = 0;

  if (strlen(current_rev_assy->new_cofilename))
    {
    _pdm_debug("writing files to list", 0);
    index = 0;
    strcpy(exfile_list[index], current_rev_assy->ex_cofilename);
    strcpy(newfile_list[index], current_rev_assy->new_cofilename);
    ++index;
    *file_count = 1;
    }

  PDU_new_assembly = TRUE;     /* the main assembly has been copied */

  /* check for multiple files */
  temp_list = current_rev_assy;
  temp_list = temp_list->next;
  while (temp_list)
    {
    if (*file_count > 10)
      {
      _pdm_debug("Error: number of files exceeds size of list", 0);
      return(PDM_E_NUM_FILES_EXCEEDS_LIST);
      }
    if (temp_list->ex_level == -1)
      {
      _pdm_debug("existing part has multiple files", 0);

      if (!strlen(temp_list->new_cofilename))
        {
        temp_list = temp_list->next;
        continue;
        }

      strcpy(exfile_list[index], temp_list->ex_cofilename);
      strcpy(newfile_list[index], temp_list->new_cofilename);
      ++index;
      ++(*file_count);

      if ((strcmp(current_rev_assy->ex_catalog, 
                  current_rev_assy->new_catalog) == 0) &&
          (strcmp(current_rev_assy->ex_partid,
                  current_rev_assy->new_partid) == 0) &&
          (strcmp(current_rev_assy->ex_revision,
                  current_rev_assy->new_revision) == 0))
        {
        _pdm_debug("resetting ADD to N", 0);
        strcpy(current_rev_assy->add, "N");
        PDUupdate_mult_files_for_rev_assy("add", "N");
        }
      else if (parent_part)
        {
        _pdm_debug("resetting ADD to N", 0);
        strcpy(current_rev_assy->add, "N");
        PDUupdate_mult_files_for_rev_assy("add", "N");
        }
      }
    else
      {
      _pdm_debug("breaking after checking for multiple files", 0);
      break;
      }
    temp_list = temp_list->next;
    }

  _pdm_debug("existing file list", 0);
  for (index = 0; index < (*file_count); ++index)
     _pdm_debug("exfile_list entry = <%s>", exfile_list[index]);
     
  _pdm_debug("new file list", 0);
  for (index = 0; index < (*file_count); ++index)
     _pdm_debug("newfile_list entry = <%s>", newfile_list[index]);

  _pdm_debug("Exit:  PDUcreate_copy_file_lists_for_rev_assy", 0);
  return(status);
}

int PDUcheckout_part_for_revise_assembly(catalog, partid, revision, desc,
                                         filename, parttype)
char   *catalog;
char   *partid;
char   *revision;
char   *desc;
char   *filename;
char   *parttype;

{
  int   status = PDM_S_SUCCESS;
  char  *title = NULL;
  extern void PDUactive_part_form();
  extern void PDUdelete_active_part_form();

  _pdm_debug("in the function PDUcheckout_part_for_revise_assembly", 0);

  _pdm_debug("catalog = <%s>", catalog);
  _pdm_debug("partid = <%s>", partid);
  _pdm_debug("revision = <%s>", revision);
  _pdm_debug("filename = <%s>", filename);
  _pdm_debug("parttype = <%s>", parttype);

  PDUfill_in_string(&refresh->rev_catalog, catalog);
  PDUfill_in_string(&refresh->rev_partid, partid);
  PDUfill_in_string(&refresh->rev_revision, revision);
  PDUfill_in_string(&refresh->rev_filename, filename);
  PDUfill_in_string(&refresh->rev_parttype, parttype);

  PDU_checkout_type = 0;
  PDU_command = PDC_M_CHECKOUT;
  PDU_chkout_single = TRUE;

  PDUdelete_active_part_form();

  /* display active part form */
  title = (char *)PDUtranslate_message(PDM_I_CHECKING_PART_OUT);
  PDUactive_part_form(catalog, partid, revision, desc, title);
  if (title) free(title);

  status = PDUext_checkout();
  _pdm_status("PDUext_checkout", status);

  PDU_command = 0;

  PDUdelete_active_part_form();

  _pdm_debug("Exit:  PDUcheckout_part_for_revise_assembly", 0);
  return(status);
}

int PDUcheck_usageid_for_rev_assy(list, usageid)
  struct PDUrev_assy   *list;
  char   *usageid;
{
  _pdm_debug("in the function PDUcheck_usageid_for_rev_assy", 0);

  if (!PDU_assy_ptr)
    return(PDM_E_NULL_LINKLIST);

  list = PDU_assy_ptr;
  
  /* check value of usageid for all parts */
  while (list)
    {
    if ((strcmp(list->new_usageid, usageid) == 0) ||
        (strcmp(list->p_usageid, usageid) == 0))
      return(PDM_E_UNIQUE_USAGE);
    list = list->next;
    }

  _pdm_debug("Exit:  PDUcheck_usageid_for_rev_assy", 0);
  return(PDM_S_SUCCESS);

}  /* end PDUcheck_usageid_for_rev_assy */

int PDUcheck_alttag_for_rev_assy(list, alttag)
  struct PDUrev_assy    *list;
  char                  *alttag;
{
  _pdm_debug("PDUcheck_alttag_for_rev_assy", 0);

  if (!PDU_assy_ptr)
    return(PDM_E_NULL_LINKLIST);

  list = PDU_assy_ptr;

  /* check value of alttag for all parts */
  while (list)
    {
    if (strcmp(list->p_alttagno, alttag) == 0)
      return(PDM_E_ALT_TAG_NOT_UNIQUE);
    list = list->next;
    }

  _pdm_debug("Exit:  PDUcheck_alttag_for_rev_assy", 0);
  return(PDM_S_SUCCESS);

}  /* end PDUcheck_alttag_for_rev_assy */

int PDUng_place_part_for_revise_assembly(start_row)
  int    start_row;
{
  int    status = PDM_S_SUCCESS;
  int    stat = PDM_S_SUCCESS;
  int    catalogno = 0;
  int    itemno = 0;
  int    display_flag = 0;
  int    parent_level = 0;
  char   *attach = NULL;
  char   *p_explode = NULL;
  char   *title = NULL;
  extern void PDUdelete_active_part_form();
  extern void PDUactive_part_form();

  _pdm_debug("in the function PDUng_place_part_for_revise_assembly", 0);

  PDUdelete_active_part_form();

  /* display active part form */
  title = (char *)PDUtranslate_message(PDM_I_PLACING_PART);
  PDUactive_part_form(current_rev_assy->new_catalog,
                      current_rev_assy->new_partid,
                      current_rev_assy->new_revision,
                      current_rev_assy->new_desc, title);
  if (title) free(title);

  parent_level = current_rev_assy->new_level - 1;

  status = PDUgenerate_rev_assy_data(parent_level, start_row);
  _pdm_status("PDUgenerate_rev_assy_data", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUdelete_active_part_form();
    return(status);
    }

  PDUfill_in_string(&attach, "N");
  PDU_attach = FALSE;
  _pdm_debug("PDU_quantity = <%s>", PDU_quantity);

  /* default quantity */
 PDUfill_in_string(&PDU_quantity, "1.000000");

 if (PDU_dyn_attr_bufr)
   MEMclose(&PDU_dyn_attr_bufr);
 if (PDU_dyn_data_bufr)
   MEMclose(&PDU_dyn_data_bufr);
 if (PDU_dyn_value_bufr)
   MEMclose(&PDU_dyn_value_bufr);

 /* Extract dynamic attributes from PDM if any, and display them on form */
 stat = PDMquery_dynamic_attrs(
                               current_rev_assy->new_catalog,
                               current_rev_assy->new_partid,
                               current_rev_assy->new_revision,
                               &PDU_dyn_attr_bufr,
                               &PDU_dyn_data_bufr,
                               &PDU_dyn_value_bufr,
                               &p_explode
                              );
 _pdm_status("PDMquery_dynamic_attrs", stat);

 PDUdelete_active_part_form();

 /* Display dynamic attributes form, if necessary */
 if ((PDU_display_dyn_attr) || 
     (strcmp(current_rev_assy->new_parttype, "P") == 0) ||
     (strcmp(current_rev_assy->new_parttype, "p") == 0))
    {
    PDU_calling_form = forms.rev_assy_form_id;
    FIf_erase(PDU_calling_form);
    PDU_ng_placement = TRUE;
    _pdm_debug("Calling PDUdynamic_attr_form", 0);
    stat = PDUdynamic_attr_form();
    _pdm_status("PDUdynamic_attr_form", stat);

    stat = WaitForEvent();
    _pdm_status("WaitForEvent", stat);
    if (!stat)
      {
      _pdm_debug("dynamic attr form was cancelled", 0);
      PDUmessage(PDM_E_CMD_CANCELLED, 's');
      return(PDM_E_CMD_CANCELLED);
      }

    PDU_ng_placement = FALSE;
    PDUfill_in_string(&(current_rev_assy)->new_usageid, PDU_usage_id);
    PDUfill_in_string(&(current_rev_assy)->p_quantity, PDU_quantity);
    PDUfill_in_string(&(current_rev_assy)->p_alttagno, PDU_alt_tagno);
    }
  else
    {
    display_flag = PDUcheck_display_dynamic_attr(PDU_dyn_attr_bufr,
                                                 PDU_dyn_data_bufr);
    _pdm_debug("display flag = <%d>", (char *)display_flag);
    if (display_flag)
      {
      PDU_calling_form = forms.rev_assy_form_id;
      FIf_erase(PDU_calling_form);
      PDU_ng_placement = TRUE;
      _pdm_debug("Calling PDUdynamic_attr_form", 0);
      stat = PDUdynamic_attr_form();
      _pdm_status("PDUdynamic_attr_form", stat);

      stat = WaitForEvent();
      _pdm_status("WaitForEvent", stat);
      if (!stat)
        {
        _pdm_debug("dynamic attr form was cancelled", 0);
        PDUmessage(PDM_E_CMD_CANCELLED, 's');
        return(PDM_E_CMD_CANCELLED);
        }

      PDU_ng_placement = FALSE;
      PDUfill_in_string(&(current_rev_assy)->new_usageid, PDU_usage_id);
      PDUfill_in_string(&(current_rev_assy)->p_quantity, PDU_quantity);
      PDUfill_in_string(&(current_rev_assy)->p_alttagno, PDU_alt_tagno);
      }
    }

  /* set the catalog and item numbers */
  _pdm_debug("setting the catalog and item numbers", 0);
  catalogno = 0;
  itemno = 0;

  current_rev_assy->p_childno = PDU_childno;
  current_rev_assy->p_pchildno = PDU_pchildno;
  PDUfill_in_string(&(current_rev_assy)->p_tagno, PDU_tagno);
  PDUfill_in_string(&(current_rev_assy)->p_quantity, PDU_quantity);
  PDUfill_in_string(&(current_rev_assy)->p_alttagno, PDU_alt_tagno);
  _pdm_debug("resetting PDU_incl_BOM", 0);
  if ((PDU_incl_BOM) && (strcmp(PDU_incl_BOM, "B") == 0))
    PDUfill_in_string(&PDU_incl_BOM, "Y");
  PDUfill_in_string(&(current_rev_assy)->p_incbom, PDU_incl_BOM);
  PDUfill_in_string(&(current_rev_assy)->p_incstr, PDU_incl_ASM);
  PDUfill_in_string(&(current_rev_assy)->p_explode, PDU_explode_BOM);
  PDUfill_in_string(&(current_rev_assy)->p_attached, "N");
  current_rev_assy->n_catalogno = catalogno;
  current_rev_assy->n_itemno = itemno;

  _pdm_debug("level = <%d>", (char *)current_rev_assy->new_level);
  _pdm_debug("parent = <%d>", (char *)current_rev_assy->p_pchildno);
  _pdm_debug("child = <%d>", (char *)current_rev_assy->p_childno);
  _pdm_debug("catalog = <%s>", current_rev_assy->new_catalog);
  _pdm_debug("partid = <%s>", current_rev_assy->new_partid);
  _pdm_debug("revision = <%s>", current_rev_assy->new_revision);
  _pdm_debug("attach = <%s>", current_rev_assy->p_attached);
  _pdm_debug("PDU_usage_id = <%s>", current_rev_assy->new_usageid);
  _pdm_debug("tagno = <%s>", current_rev_assy->p_tagno);
  _pdm_debug("alttagno = <%s>", PDU_alt_tagno);
  _pdm_debug("explode = <%s>", PDU_explode_BOM);
  _pdm_debug("incbom = <%s>", PDU_incl_BOM);
  _pdm_debug("incstr = <%s>", PDU_incl_ASM);
  _pdm_debug("filename = <%s>", "");
  _pdm_debug("catalogno = <%d>", (char *)catalogno);
  _pdm_debug("itemno = <%d>", (char *)itemno);

  PDUdelete_active_part_form();

  _pdm_debug("freeing pointers", 0);
  if (attach) free (attach);
  if (p_explode) free (p_explode);

  if (PDU_usage_id)
    {
    free(PDU_usage_id);
    PDU_usage_id = NULL;
    }
  if (PDU_alt_tagno)
    {
    free(PDU_alt_tagno);
    PDU_alt_tagno = NULL;
    }
  PDUfill_in_string(&PDU_quantity, "1.000000");

  _pdm_debug("Exit:  PDUng_place_part_for_revise_assembly", 0);
  return(status);
}

/* This function is called when a part is being placed on the revise assembly
   form.  It generates the childno, parent childno, usageid and tagno.  
   Dynamic attr information is not allowed to be saved during nongraphic part
   placement, because the part does not have a file yet.
*/


int PDUgenerate_rev_assy_data(parent_level, start_row)
  int   parent_level;
  int   start_row;
{
  int   status = PDM_S_SUCCESS;
  int   length = 0;
  int   instanceno = 1;
  int   tmp_tagno = 0;
  int   tagno = 0;
  int   childno = 0;
  int   tmp_childno = 0;
  char  tag_str[9];
  char  *usageid = NULL;
  char  *catalogno = NULL;
  char  *itemno = NULL;
  char  *tmp_instancestr = NULL;
  char  test_usage[100];
  char  instance_str[10];
  char  tmp_usageid[MAX_VALUE];
  short found = FALSE;
  MEMptr bufr = NULL;
  struct PDUrev_assy *temp_list = NULL;

  _pdm_debug("in the function PDUgenerate_rev_assy_data", 0);

  _pdm_debug("catalog = <%s>", current_rev_assy->new_catalog);
  _pdm_debug("partid = <%s>", current_rev_assy->new_partid);
  _pdm_debug("revision = <%s>", current_rev_assy->new_revision);
  _pdm_debug("parent_level = <%d>", (char *)parent_level);
  _pdm_debug("start_row = <%d>", (char *)start_row);

  /* needed for PDUis_cyclic_placement */
  PDUfill_in_string(&refresh->act_catalog, PDU_assy_catalog);
  PDUfill_in_string(&refresh->act_partid, PDU_assy_partid);
  PDUfill_in_string(&refresh->act_revision, PDU_assy_revision);

/* parent childno was retrieved in PDUupdate_assy_through_database */
  _pdm_debug("parent childno = %d", (char *)PDU_pchildno);

  _pdm_debug("calling PDUis_cyclic_placement", 0);
  _pdm_debug("PDU_incl_ASM = <%s>", PDU_incl_ASM);
  status = PDUis_cyclic_placement(current_rev_assy->new_catalog,
                                  current_rev_assy->new_partid,
                                  current_rev_assy->new_revision,
                                  &bufr);
  _pdm_status("PDUis_cyclic_placement", status);
  MEMclose(&bufr);
  bufr = NULL;

  if (status == 1)
    {
    PDUmessage(PDM_E_CYCLIC_1STLEVEL, 's');
    return(PDM_E_CYCLIC_1STLEVEL);
    }

  status = PDM_S_SUCCESS;

/*****************************************************************************/

  _pdm_debug("get the usage id", 0);

  _pdm_debug("PDU_usage_id = <%s>", PDU_usage_id);

  /* check to see if the user specified a usage id */
  if ((!current_rev_assy->new_usageid) || 
     ((current_rev_assy->new_usageid) &&
     (!(strlen(current_rev_assy->new_usageid)))))
    {
    _pdm_debug("generating usage id", 0);
    status = PDMget_usageid_cat(current_rev_assy->new_catalog, &usageid);
    _pdm_status("PDMget_usageid_cat", status);
  
    if ((usageid == NULL) || (strcmp(usageid, "") == 0) ||
        (status == PDM_I_NO_USAGE_ID))
      {
      /* generate default usageid */
      _pdm_debug("generating default usage id", 0);
  
      length = strlen(current_rev_assy->new_partid) + 
               strlen(current_rev_assy->new_revision) + 10;
  
      usageid = (char *) malloc (sizeof (char) * length);
      memset(usageid, NULL, sizeof (char) * length);
  
      strcpy(usageid, current_rev_assy->new_partid);
      strcat(usageid, " ");
      strcat(usageid, current_rev_assy->new_revision);
  
      _pdm_debug("defaulted usageid = <%s>", usageid);
      status = PDM_S_SUCCESS;
      }
  
    if (!PDU_assy_ptr)
      return(PDM_E_NULL_ASSY_LIST);
  
    _pdm_debug("get the instance number", 0);

    _pdm_debug("setting usageid", 0);
    strcpy(test_usage, usageid);
    _pdm_debug("trying instance number = %d", (char *)instanceno);

    instance_str[0] = '\0';
    sprintf(instance_str, "%d", instanceno);
    strcat(test_usage, " #");
    strcat(test_usage, instance_str);
    _pdm_debug("string to look for = <%s>", test_usage);

    _pdm_debug("setting temp list to first part in assy structure", 0);
    temp_list = PDU_assy_ptr;
    while (temp_list)
      {
      if (temp_list->mcf_row == start_row)
        {
        found = TRUE;
        break;
        }
      temp_list = temp_list->next;
      }
    if (!found)
      {
      _pdm_debug("error finding first part in structure", 0);
      return(PDM_E_PART_IN_LIST);
      }

    _pdm_debug("start row = %d", (char *)(temp_list->mcf_row));

    _pdm_debug("search for parts with the same usageid", 0);
    while ((temp_list) && (temp_list->new_level != parent_level))
      {
      if (temp_list->new_level != parent_level + 1)
        {
        _pdm_debug("bypassing part on row %d", (char *)(temp_list->mcf_row));
        temp_list = temp_list->next;
        continue;
        }

      if ((strcmp(temp_list->p_usageid, test_usage) == 0) ||
          (strcmp(temp_list->new_usageid, test_usage) == 0))
        {
        _pdm_debug("usageid already in list", 0);
        ++instanceno;

        _pdm_debug("resetting usageid", 0);
        strcpy(test_usage, usageid);
        _pdm_debug("instance number = %d", (char *)instanceno);

        instance_str[0] = '\0';
        sprintf(instance_str, "%d", instanceno);
        strcat(test_usage, " #");
        strcat(test_usage, instance_str);
        _pdm_debug("string to look for = <%s>", test_usage);

        _pdm_debug("resetting link list", 0);
        temp_list = PDU_assy_ptr;
        while (temp_list)
          {
          if (temp_list->mcf_row == start_row)
            break;
          temp_list = temp_list->next;
          }
        _pdm_debug("start row = %d", (char *)(temp_list->mcf_row));
        }

      temp_list = temp_list->next;
      }

    PDUfill_in_string(&usageid, test_usage);
    _pdm_debug("usage id = <%s>", usageid);
  
    if ((usageid) && (strlen(usageid) > 25))
      {
      status = PDMget_catno_partno(current_rev_assy->new_catalog, 
			           current_rev_assy->new_partid, 
			           current_rev_assy->new_revision, 
			           &catalogno, &itemno);
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
    if (usageid)
      {
      PDUfill_in_string(&(current_rev_assy)->new_usageid, usageid);
      PDUfill_in_string(&(current_rev_assy)->p_usageid, usageid);
      PDUfill_in_string(&PDU_usage_id, usageid);
      }
    }
  else
    {
    _pdm_debug("usageid is already in list", 0);
    PDUfill_in_string(&PDU_usage_id, current_rev_assy->new_usageid);
    }
  
  _pdm_debug("usageid = <%s>", current_rev_assy->new_usageid);

/*****************************************************************************/

  _pdm_debug("get the tagno", 0);

  _pdm_debug("resetting link list", 0);
  temp_list = PDU_assy_ptr;
  while (temp_list)
    {
    if (temp_list->mcf_row == start_row)
      break;
    temp_list = temp_list->next;
    }
  _pdm_debug("start row = %d", (char *)(temp_list->mcf_row));

  _pdm_debug("search for parts with the same tagno", 0);
  found = FALSE;
  while ((temp_list) && (temp_list->new_level != parent_level))
    {
    if (temp_list->new_level != parent_level + 1)
      {
      _pdm_debug("bypassing part on row %d", (char *)(temp_list->mcf_row));
      temp_list = temp_list->next;
      continue;
      }

    if ((strcmp(current_rev_assy->new_catalog, 
               temp_list->new_catalog) == 0) &&
        (strcmp(current_rev_assy->new_partid,
               temp_list->new_partid) == 0) &&
        (strcmp(current_rev_assy->new_revision,
               temp_list->new_revision) == 0) &&
        (current_rev_assy->mcf_row != temp_list->mcf_row))
      {
      _pdm_debug("part already exists in structure", 0);
      tagno = atoi(temp_list->p_tagno);
      found = TRUE;
      break;
      }
    temp_list = temp_list->next;
    }

  if (!found)
    {
    _pdm_debug("part does not already exist in structure", 0);
    _pdm_debug("generating new tag number", 0);
    tagno = 0;
  
    /* get value of tagno */
    _pdm_debug("resetting link list", 0);
    temp_list = PDU_assy_ptr;
    while (temp_list)
      {
      if (temp_list->mcf_row == start_row)
        break;
      temp_list = temp_list->next;
      }
    _pdm_debug("start row = %d", (char *)(temp_list->mcf_row));
  
    _pdm_debug("set the tagno", 0);
    found = FALSE;
    while ((temp_list) && (temp_list->new_level != parent_level))
      {
      if (temp_list->new_level != parent_level + 1)
        {
        _pdm_debug("bypassing part on row %d", (char *)(temp_list->mcf_row));
        temp_list = temp_list->next;
        continue;
        }

      if (strlen((char *)(temp_list->p_tagno)))
        {
        tmp_tagno = atoi(temp_list->p_tagno);
        if (tmp_tagno > tagno)
          tagno = tmp_tagno;
        }
      else
        tagno = 0;
      temp_list = temp_list->next;
      }

    _pdm_debug("incrementing tagno = %d", (char *)tagno);
    ++tagno;
    }

  sprintf(tag_str, "%d", tagno);
  PDUfill_in_string(&PDU_tagno, tag_str);
  PDUfill_in_string(&(current_rev_assy)->p_tagno, tag_str);
  _pdm_debug("new tagno = %s", PDU_tagno);

/*****************************************************************************/

  _pdm_debug("get the childno", 0);
  childno = 0;
  _pdm_debug("resetting link list", 0);
  temp_list = PDU_assy_ptr;
  while (temp_list)
    {
    if (temp_list->mcf_row == start_row)
      break;
    temp_list = temp_list->next;
    }
  _pdm_debug("start row = %d", (char *)(temp_list->mcf_row));

  _pdm_debug("set the childno", 0);
  found = FALSE;
  while ((temp_list) && (temp_list->new_level != parent_level))
    {
    if (temp_list->new_level != parent_level + 1)
      {
      _pdm_debug("bypassing part on row %d", (char *)(temp_list->mcf_row));
      temp_list = temp_list->next;
      continue;
      }

    tmp_childno = temp_list->p_childno;
    if (tmp_childno > childno)
      childno = tmp_childno;

    temp_list = temp_list->next;
    }

  ++childno;

  PDU_childno = childno;
  _pdm_debug("childno = %d", (char *)PDU_childno);
  _pdm_debug("parent childno = %d", (char *)PDU_pchildno);

  if (temp_list)
    temp_list = NULL;

  if (usageid) free (usageid);
  if (catalogno) free (catalogno);
  if (itemno) free (itemno);
  if (tmp_instancestr) free (tmp_instancestr);

  _pdm_debug("Exit:  PDUgenerate_rev_assy_data", 0);
  return(status);
}

void PDUcleanup_revise_assembly()
{

  int  status = PDM_S_SUCCESS;
  int  part_status = PDM_S_SUCCESS;
  char *title = NULL;
  extern void PDUactive_part_form();
  extern void PDUdelete_active_part_form();
  struct PDUparts_list *checked_out_parts = NULL;

  _pdm_debug("In the function PDUcleanup_revise_assembly", 0);

  checked_out_parts = PDU_checked_out_parts;

  _pdm_debug("cancel checkout for parts were checked out", 0);
  while (checked_out_parts)
    {
    part_status = PDMrcheck_part_status(checked_out_parts->catalog,
                                        checked_out_parts->partid,
                                        checked_out_parts->revision);
    _pdm_status("PDMrcheck_part_status", part_status);
    if (part_status == PDM_I_CHECKED_OUT_BY_YOU)
      {
      _pdm_debug("cancel checkout", 0);
      PDUdelete_active_part_form();
   
      /* display active part form */
      title = (char *)PDUtranslate_message(PDM_I_CANCELLING_CHECKOUT);
      PDUactive_part_form(checked_out_parts->catalog,
                          checked_out_parts->partid,
                          checked_out_parts->revision,
                          checked_out_parts->description, title);
      if (title) free(title);
  
      PDUfill_in_string(&refresh->rev_catalog,
                         checked_out_parts->catalog);
      PDUfill_in_string(&refresh->rev_partid,
                         checked_out_parts->partid);
      PDUfill_in_string(&refresh->rev_revision,
                         checked_out_parts->revision);
      PDUfill_in_string(&refresh->rev_parttype,
                         checked_out_parts->parttype);
  
      status = PDUext_cancel_checkout();
      _pdm_status("PDUext_cancel_checkout", status);
      PDUmessage(status, 's');
    
      PDUdelete_active_part_form();
      }
    checked_out_parts = checked_out_parts->next;
    }

  if (PDU_checked_out_parts)
    {
    _pdm_debug("freeing PDU_checked_out_parts link list", 0);
    status = PDUfree_parts_list(&PDU_checked_out_parts);
    _pdm_status("PDUfree_parts_list", status);
    PDU_checked_out_parts = NULL;

    if (PDU_checked_out_parts)
      _pdm_debug("ERROR>>> failed to free PDU_checked_out_parts", 0);
    }

  return;
}

int PDUget_param_attrs_for_rev_assy(catalog, partid, revision)
char   *catalog;
char   *partid;
char   *revision;
{
  int    status = PDM_S_SUCCESS;
  int    char_index = 0;
  char   *line = NULL;
  char   cat_type[5];
  MEMptr part_bufr = NULL;

  _pdm_debug("in the function PDUget_param_attrs_for_rev_assy", 0);

  /* format buffer with only parts and revisions */
  status = PDUformat_update_parm_parts_bufr(&part_bufr);
  _pdm_status("PDUformat_update_parm_parts_bufr", status);

  if (status != PDM_S_SUCCESS)
    {
    FIf_display(forms.parametric_parts_form_id);
    return(status);
    }

  line = (char *)malloc(part_bufr->row_size);
  memset(line, NULL, part_bufr->row_size);
  if ((partid) && (strcmp(partid, "") != 0))
    PDUadd_buffer_string(line, &char_index, partid);
  else
    line[char_index++] = '\1';
  _pdm_debug("line = <%s>", line);

  if ((revision) && (strcmp(revision, "") != 0))
    PDUadd_buffer_string(line, &char_index, revision);
  else
    line[char_index++] = '\1';

  _pdm_debug("line = <%s>", line);

  status = MEMwrite(part_bufr, line);
  _pdm_status("MEMwrite", status);

  if (line)
    free(line);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  if (PDU_parm_attr_bufr)
    {
    MEMclose(&PDU_parm_attr_bufr);
    PDU_parm_attr_bufr = NULL;
    }
  if (PDU_parm_data_bufr)
    {
    MEMclose(&PDU_parm_data_bufr);
    PDU_parm_data_bufr = NULL;
    }
  if (PDU_parm_list_bufr)
    {
    MEMclose(&PDU_parm_list_bufr);
    PDU_parm_list_bufr = NULL;
    }

  status = PDMquery_catalog_type(catalog, cat_type);
  _pdm_status("PDMquery_catalog", status);

  if ((strcmp(cat_type, "P") == 0) || (strcmp(cat_type, "PXT") == 0))
    {
    PDUmessage(PDS_M_GET_TABLE_ATTR, 's');
    PDUload_exec_structure("",catalog,"",cat_type,
                           "", "", "", MODIFY_DATA,
                           PDM_PARAMETRIC_PART);

    _pdm_debug("Calling PDMsget_table_attributes", 0);
    status = PDMsget_table_attributes(&PDU_parm_attr_bufr,
                                      &PDU_parm_data_bufr,
                                      &PDU_parm_list_bufr);
    _pdm_status("PDMsget_table_attributes", status);

    if (status != PDM_S_SUCCESS)
      return(status);

    PDUload_exec_structure("",catalog,"","", "", "", "", 0, 0);
    status = PDMget_list_for_modify(&PDU_parm_attr_bufr, &PDU_parm_data_bufr,
                                    cat_type, &part_bufr);
    _pdm_status("PDMget_list_for_modify", status);
  
    if (status != PDM_S_SUCCESS)
      return(status);

    if (PDMdebug_on)
      {
      MEMprint_buffer("parametric attributes buffer",PDU_parm_attr_bufr,
                      PDU_DEBUG_FILE);
      MEMprint_buffer("parametric data buffer",PDU_parm_data_bufr,
                      PDU_DEBUG_FILE);
      MEMprint_buffer("part buffer",part_bufr, PDU_DEBUG_FILE);
      }
    }
  else
    {
    if (strcmp(cat_type, "CID") == 0)
      return(PDM_E_VIEW_CATALOG);
    else
      return(PDM_E_CAT_NOT_PARAMETRIC);
    }

  _pdm_debug("Exit:  PDUget_param_attrs_for_rev_assy", 0);
  return(status);
}

int PDUupdate_AttrForm_function_value()
{
  int  status = PDM_S_SUCCESS;
  int  act_row, act_pos;
  int  length, select, pos;
  int  i;
  int  n_name_col = 0;
  int  n_syn_col = 0;
  static char *attr_text = NULL;
  char **attr_data_row;
  short found = FALSE;

  _pdm_debug("in the function PDUupdate_AttrForm_function_value", 0);

  FIfld_get_active_row(forms.attr_value_form_id, ATTR_MCF, &act_row, &act_pos);
  FIfld_set_text(forms.attr_value_form_id, ATTR_MCF, act_row, 1,
                 PDU_attr_value, FALSE);

  FIfld_get_text_length(forms.attr_value_form_id,ATTR_MCF, act_row, 0, &length);
  attr_text = (char *) malloc (sizeof (char) * length + 1);
  memset(attr_text, NULL, sizeof (char) * length + 1);
  FIfld_get_text(forms.attr_value_form_id, ATTR_MCF,act_row, 0, length, 
                (unsigned char*)attr_text, &select, &pos);

  if (attr_text[0] == '*')
    attr_text = attr_text + 1;

  status = MEMbuild_array(PDU_attr_bufr);
  _pdm_status("MEMbuild_array",status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(PDU_attr_bufr, ROW, &attr_data_row);

  PDUget_buffer_col(PDU_attr_bufr, "n_name", &n_name_col);
  PDUget_buffer_col(PDU_attr_bufr, "n_synonym", &n_syn_col);

  for (i = 0; i < PDU_attr_bufr->rows; i = i + 1)
    {
    if (strcmp(attr_data_row[(PDU_attr_bufr->columns * i) +
           n_syn_col], attr_text) == 0)
      {
      status = MEMwrite_data(PDU_data_bufr,PDU_attr_value,1,i + 1);
      if (status != MEM_S_SUCCESS)
        {
        PDUdisplay_status(PDM_E_WRITE_BUFFER, forms.attr_value_form_id);
        return(PDM_E_WRITE_BUFFER);
        }
      found = 1;
      }
    else if (strcmp(attr_data_row[(PDU_attr_bufr->columns * i) +
               n_name_col], attr_text) == 0)
      {
      status = MEMwrite_data(PDU_data_bufr,PDU_attr_value,1,i + 1);
      if (status != MEM_S_SUCCESS)
        {
        PDUdisplay_status(PDM_E_WRITE_BUFFER, forms.attr_value_form_id);
        return(PDM_E_WRITE_BUFFER);
        }
      found = 1;
      }

    if (found)
      break;
    }

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
}

void PDUdelete_active_part_form()
{
  _pdm_debug("deleting active part form", 0);
  if (forms.active_part_form_id)
    {
    FIf_erase(forms.active_part_form_id);
    FIf_delete(forms.active_part_form_id);
    forms.active_part_form_id = 0;
    }
}  

int PDUadd_parts_to_assy_buffer(assy_catalog, 
                                assy_partid, 
                                assy_revision, 
                                buffer)
  char     *assy_catalog;
  char     *assy_partid;
  char     *assy_revision;
  MEMptr   *buffer;
{
  int   status = PDM_S_SUCCESS;
  int   child_col;
  int   cat_col;
  int   part_col;
  int   rev_col;
  int   attach_col;
  int   use_col;
  int   quan_col;
  int   tag_col;
  int   alttag_col;
  int   catno_col;
  int   itemno_col;
  int   inc_col;
  int   exp_col;
  int   file_col;
  int   inc_str;
  int   row = 0;
  int   level_col = 0;
  int   alt_col = 0;
  int   char_index = 0;
  char  **data_row;
  char  *catalog = NULL;
  char  *partid = NULL;
  char  *revision = NULL;
  char  *level = NULL;
  char  *child = NULL;
  char  *quantity = NULL;
  char  *usageid = NULL;
  char  *tagno = NULL;
  char  *alttag = NULL;
  char  *incbom = NULL;
  char  *incstr = NULL;
  char  *explode = NULL;
  char  *filename = NULL;
  char  *catno = NULL;
  char  *itemno = NULL;
  char  *attach = NULL;
  char  *line = NULL;
  MEMptr assy_bufr = NULL;

  _pdm_debug("in the function PDUadd_parts_to_assy_buffer", 0);

  status = PDMget_assembly_structure(assy_catalog, assy_partid, assy_revision, 
                                     1, &assy_bufr, 0);
  _pdm_status("PDMget_assembly_structure", status);

  if ((status == PDM_E_PART_NOT_ASSEMBLY) ||
     ((assy_bufr) && (assy_bufr->rows == 1)) ||
     ((assy_bufr) && (assy_bufr->rows == 0)))
    {
    if (assy_bufr)
      {
      MEMclose(&assy_bufr);
      assy_bufr = NULL;
      }
    return(PDM_S_SUCCESS);
    }

  _pdm_debug("assy_bufr->rows = %d", (char *)assy_bufr->rows);

  MEMbuild_array(assy_bufr);
  PDUsetup_buffer(assy_bufr, ROW, &data_row);

  PDUget_buffer_col(assy_bufr, "p_level", &level_col);
  PDUget_buffer_col(assy_bufr, "p_childno", &child_col);
  PDUget_buffer_col(assy_bufr, "n_catalogname", &cat_col);
  PDUget_buffer_col(assy_bufr, "n_itemname", &part_col);
  PDUget_buffer_col(assy_bufr, "n_itemrev", &rev_col);
  PDUget_buffer_col(assy_bufr, "p_attached", &attach_col);
  PDUget_buffer_col(assy_bufr, "p_quantity", &quan_col);
  PDUget_buffer_col(assy_bufr, "p_usageid", &use_col);
  PDUget_buffer_col(assy_bufr, "p_tagno", &tag_col);
  PDUget_buffer_col(assy_bufr, "n_pcatalogno", &catno_col);
  PDUget_buffer_col(assy_bufr, "n_pitemno", &itemno_col);
  PDUget_buffer_col(assy_bufr, "p_alttagno", &alttag_col);
  PDUget_buffer_col(assy_bufr, "p_incbom", &inc_col);
  PDUget_buffer_col(assy_bufr, "p_incstr", &inc_str);
  PDUget_buffer_col(assy_bufr, "p_explode", &exp_col);
  PDUget_buffer_col(assy_bufr, "n_cofilename", &file_col);

  _pdm_debug("make sure the childnos are unique", 0);
  status = PDUcompare_childnos(assy_bufr, buffer);
  _pdm_status("PDUcompare_childnos", status);

  _pdm_debug("make sure the tagnos are unique", 0);
  status = PDUcompare_tagnos(assy_bufr, buffer);
  _pdm_status("PDUcompare_tagnos", status);

  _pdm_debug("make sure the usageids are unique", 0);
  status = PDUcompare_usageids(assy_bufr, buffer);
  _pdm_status("PDUcompare_usageids", status);

  line = (char*) malloc ((*buffer)->row_size);
  memset (line, NULL, (*buffer)->row_size);

  for (row = 1; row < assy_bufr->rows; ++row)
   {
   PDUfill_in_string(&level, data_row[(assy_bufr->columns * row) + level_col]);

   if (strcmp(level, "1") == 0)
     {
     char_index = 0;

     PDUfill_in_string(&catalog, 
                       data_row[(assy_bufr->columns * row) + cat_col]);
     PDUfill_in_string(&partid, 
                       data_row[(assy_bufr->columns * row) + part_col]);
     PDUfill_in_string(&revision, 
                       data_row[(assy_bufr->columns * row) + rev_col]);
     PDUfill_in_string(&quantity, 
                       data_row[(assy_bufr->columns * row) + quan_col]);
     PDUfill_in_string(&usageid, 
                       data_row[(assy_bufr->columns * row) + use_col]);
     PDUfill_in_string(&tagno, 
                       data_row[(assy_bufr->columns * row) + tag_col]);
     PDUfill_in_string(&attach, 
                       data_row[(assy_bufr->columns * row) + attach_col]);
     PDUfill_in_string(&catno, 
                       data_row[(assy_bufr->columns * row) + catno_col]);
     PDUfill_in_string(&itemno, 
                       data_row[(assy_bufr->columns * row) + itemno_col]);
     PDUfill_in_string(&incbom, 
                       data_row[(assy_bufr->columns * row) + inc_col]);
     PDUfill_in_string(&incstr, 
                       data_row[(assy_bufr->columns * row) + inc_str]);
     PDUfill_in_string(&alttag, 
                       data_row[(assy_bufr->columns * row) + alt_col]);
     PDUfill_in_string(&explode, 
                       data_row[(assy_bufr->columns * row) + exp_col]);
     PDUfill_in_string(&filename, 
                       data_row[(assy_bufr->columns * row) + file_col]);
     PDUfill_in_string(&child, 
                       data_row[(assy_bufr->columns * row) + child_col]);

     if (child && (strlen (child )))
       PDUadd_buffer_string(line, &char_index, child);
     else
       line[char_index++] = '\1';
 
     if (catalog && (strlen (catalog )))
       PDUadd_buffer_string(line, &char_index, catalog);
     else
       line[char_index++] = '\1';
   
     if (partid && (strlen (partid )))
       PDUadd_buffer_string(line, &char_index, partid);
     else
       line[char_index++] = '\1';
   
     if (revision && (strlen (revision )))
       PDUadd_buffer_string(line, &char_index, revision);
     else
       line[char_index++] = '\1';
   
     if (attach && (strlen (attach )))
       PDUadd_buffer_string(line, &char_index, attach);
     else
       line[char_index++] = '\1';
   
     if (quantity && (strlen (quantity )))
       PDUadd_buffer_string(line, &char_index, quantity);
     else
       line[char_index++] = '\1';
   
     if (usageid && (strlen (usageid )))
       PDUadd_buffer_string(line, &char_index, usageid);
     else
       line[char_index++] = '\1';
   
     if (tagno && (strlen (tagno )))
       PDUadd_buffer_string(line, &char_index, tagno);
     else
       line[char_index++] = '\1';
   
     if (alttag && (strlen (alttag )))
       PDUadd_buffer_string(line, &char_index, alttag);
     else
       line[char_index++] = '\1';
   
     if (incbom && (strlen (incbom )))
       PDUadd_buffer_string(line, &char_index, incbom);
     else
       line[char_index++] = '\1';
   
     if (incstr && (strlen (incstr )))
       PDUadd_buffer_string(line, &char_index, incstr);
     else
       line[char_index++] = '\1';
   
     if (explode && (strlen (explode )))
       PDUadd_buffer_string(line, &char_index, explode);
     else
       line[char_index++] = '\1';
   
     if (filename && (strlen (filename )))
       PDUadd_buffer_string(line, &char_index, filename);
     else
       line[char_index++] = '\1';
   
     line[char_index++] = '\1'; /* p_history entry */
 
     if (catno && (strlen (catno )))
       PDUadd_buffer_string(line, &char_index, catno);
     else
       line[char_index++] = '\1';
   
     if (itemno && (strlen (itemno )))
       PDUadd_buffer_string(line, &char_index, itemno);
     else
       line[char_index++] = '\1';
   
     if (level && (strlen (level )))
       PDUadd_buffer_string(line, &char_index, level);
     else
       line[char_index++] = '\1';
   
     _pdm_debug("line = <%s>", line);
     status = MEMwrite (*buffer, line);
     _pdm_status("MEMwrite", status);
   
     if (status != MEM_S_SUCCESS)
       {
       _pdm_debug("Error writing to buffer", 0);
       return(PDM_E_WRITE_BUFFER);
       }
     status = PDM_S_SUCCESS;
     memset (line, NULL, (*buffer)->row_size);
     }
   }

  if (PDMdebug_on)
    MEMprint_buffer("new assy buffer", *buffer, PDU_DEBUG_FILE);

  return(status);
}

int PDUcompare_tagnos(buffer1, buffer2)
MEMptr buffer1;
MEMptr *buffer2;
{
  int    status = PDM_S_SUCCESS;
  int    cat1_col = 0;
  int    part1_col = 0;
  int    rev1_col = 0;
  int    tag1_col = 0;
  int    cat2_col = 0;
  int    part2_col = 0;
  int    rev2_col = 0;
  int    tag2_col = 0;
  int    row = 0;
  int    row2 = 0;
  int    index = 0;
  int    tagno = 0;
  int    tmp_tag = 0;
  int    save_tag;
  char   **data1;
  char   **data2;
  char   tag_str[9];
  short  found = FALSE;

  _pdm_debug("in the function PDUcompare_tagnos", 0);

  MEMbuild_array(buffer1);
  PDUsetup_buffer(buffer1, ROW, &data1);

  MEMbuild_array(*buffer2);
  PDUsetup_buffer(*buffer2, ROW, &data2);

  PDUget_buffer_col(buffer1, "n_catalogname", &cat1_col);
  PDUget_buffer_col(buffer1, "n_itemname", &part1_col);
  PDUget_buffer_col(buffer1, "n_itemrev", &rev1_col);
  PDUget_buffer_col(buffer1, "p_tagno", &tag1_col);

  PDUget_buffer_col(*buffer2, "n_catalogname", &cat2_col);
  PDUget_buffer_col(*buffer2, "n_itemname", &part2_col);
  PDUget_buffer_col(*buffer2, "n_itemrev", &rev2_col);
  PDUget_buffer_col(*buffer2, "p_tagno", &tag2_col);

  _pdm_debug("find the greatest tagno in buffer1", 0);
  tmp_tag = 0;
  for (row = 0; row < buffer1->rows; ++row)
     {
     tagno = atoi(data1[(buffer1->columns * row) + tag1_col]);
     if (tmp_tag > tagno)
       tagno = tmp_tag;
     }
  _pdm_debug("the greatest tagno = <%d>", (char *)tagno);

  found = FALSE;
  _pdm_debug("checking existing assembly buffer", 0);
  for (row2 = 0; row2 < (*buffer2)->rows; ++row2)
     {
     for (row = 0; row < buffer1->rows; ++row)
        {
        if ((strcmp(data2[((*buffer2)->columns * row2) + cat2_col], 
                    data1[(buffer1->columns * row) + cat1_col]) == 0) &&
            (strcmp(data2[((*buffer2)->columns * row2) + part2_col],
                    data1[(buffer1->columns * row) + part1_col]) == 0) &&
            (strcmp(data2[((*buffer2)->columns * row2) + rev2_col],
                    data1[(buffer1->columns * row) + rev1_col]) == 0))
          {
          _pdm_debug("part already exists in structure", 0);
          found = TRUE;
   
          if (strcmp(data2[((*buffer2)->columns * row2) + tag2_col],
                     data1[(buffer1->columns * row) + tag1_col]) == 0)
            {
            _pdm_debug("tagnos match", 0);
            break;
            }
          else
            {
            _pdm_debug("tagnos do not match; use existing tagno", 0);
            /* write tagno to buffer2 */
            status = MEMwrite_data(*buffer2, 
                                   data1[(buffer1->columns * row) + tag1_col],
                                   row2 + 1, tag2_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);
            status = PDM_S_SUCCESS;
            break;
            }
          }
        }

     if (!found)
       {
       _pdm_debug("write new tagno to buffer2", 0);
       save_tag = atoi(data2[((*buffer2)->columns * row2) + tag2_col]);
       _pdm_debug("save_tag = <%d>", (char *)save_tag);
       if (tagno >= save_tag)
         {
         ++tagno;
         sprintf(tag_str, "%d", tagno);
         status = MEMwrite_data(*buffer2, tag_str, row2 + 1, tag2_col + 1);
         _pdm_status("MEMwrite_data", status);
         if (status != MEM_S_SUCCESS)
           return(PDM_E_WRITE_BUFFER);
         status = PDM_S_SUCCESS;
  
         _pdm_debug("search for other parts with the same tagno", 0);
         for (index = row2 + 1; index < (*buffer2)->rows; ++index)
            {
            _pdm_debug("checking row <%d>", (char *)index);
            if (save_tag ==
                       atoi(data2[((*buffer2)->columns * index) + tag2_col]))
              {
              status =MEMwrite_data(*buffer2, tag_str, index + 1, tag2_col + 1);
              _pdm_status("MEMwrite_data", status);
              if (status != MEM_S_SUCCESS)
                return(PDM_E_WRITE_BUFFER);
              status = PDM_S_SUCCESS;
              }
            }
         }
       }
     }

  if (PDMdebug_on)
    MEMprint_buffer("buffer2", *buffer2, PDU_DEBUG_FILE);

  return(status);
}

int  PDUcompare_childnos(buffer1, buffer2)
MEMptr  buffer1;
MEMptr  *buffer2;
{
  int   status = PDM_S_SUCCESS;
  int   child1_col;
  int   child2_col;
  int   row;
  int   tmp_child;
  int   childno = 0;
  char  **data1;
  char  child_str[5];

  _pdm_debug("in the function PDUcompare_childnos", 0);

  MEMbuild_array(buffer1);
  PDUsetup_buffer(buffer1, ROW, &data1);

  MEMbuild_array(*buffer2);

  PDUget_buffer_col(buffer1, "p_childno", &child1_col);
  PDUget_buffer_col(*buffer2, "p_childno", &child2_col);

  _pdm_debug("find the greatest childno in buffer1", 0);
  tmp_child = 0;
  for (row = 0; row < buffer1->rows; ++row)
     {
     childno = atoi(data1[(buffer1->columns * row) + child1_col]);
     if (tmp_child > childno)
       childno = tmp_child;
     }
  _pdm_debug("the greatest childno = <%d>", (char *)childno);

  _pdm_debug("reset childnos in buffer2", 0);
  for (row = 0; row < (*buffer2)->rows; ++row)
     {
     ++childno;
     sprintf(child_str, "%d", childno);
     status =MEMwrite_data(*buffer2, child_str, row + 1, child2_col + 1);
     _pdm_status("MEMwrite_data", status);
     if (status != MEM_S_SUCCESS)
       return(PDM_E_WRITE_BUFFER);
     status = PDM_S_SUCCESS;
     }

  if (PDMdebug_on)
    MEMprint_buffer("buffer2", *buffer2, PDU_DEBUG_FILE);

  return(status);
}

int  PDUcompare_usageids(buffer1, buffer2)
MEMptr  buffer1;
MEMptr  *buffer2;
{
  int   status = PDM_S_SUCCESS;
  int   row;
  int   row2;
  int   length;
  int   instanceno;
  int   count = 0;
  int   usage1_col = 0;
  int   usage2_col = 0;
  int   index, i, j;
  char  instancestr[5];
  char  *test_usage = NULL;
  char  *usageid2 = NULL;
  char  **data1;
  char  **data2;
  short found = FALSE;
  short new_usage = FALSE;

  _pdm_debug("PDUcompare_usageids", 0);

  MEMbuild_array(buffer1);
  PDUsetup_buffer(buffer1, ROW, &data1);

  MEMbuild_array(*buffer2);
  PDUsetup_buffer(*buffer2, ROW, &data2);

  PDUget_buffer_col(buffer1, "p_usageid", &usage1_col);
  PDUget_buffer_col(*buffer2, "p_usageid", &usage2_col);

  _pdm_debug("check buffer1 for duplicate usageids", 0);
  found = FALSE;
  for (row2 = 0; row2 < (*buffer2)->rows; ++row2)
     {
     PDUfill_in_string(&usageid2, 
                       data2[((*buffer2)->columns * row2) + usage2_col]);
     _pdm_debug("checking usageid <%s>", usageid2);
     for (row = 0; row < buffer1->rows; ++row)
        {
        found = FALSE;
        if (strcmp(usageid2, 
                   data1[(buffer1->columns * row) + usage1_col]) == 0)
          {
          _pdm_debug("duplicate usageid found", 0);
          found = TRUE;
          new_usage = TRUE;
          length = strlen(usageid2);
          _pdm_debug("mallocing test_usage", 0);
          test_usage = (char *) malloc (sizeof (char) * length + 5);
          memset(test_usage, NULL, sizeof (char) * length + 5);

          i = 0;
          while ((usageid2[i] != '#') && (usageid2[i] != '\0'))
            ++i;
          ++i;

          strncpy(test_usage, usageid2, i);

          _pdm_debug("seeded usageid = <%s>", test_usage);

          _pdm_debug("get the instance number", 0);
          j = 0;
          while (usageid2[i] != '\0')
            {
            instancestr[j] = usageid2[i];
            ++i;
            ++j;
            }

          instanceno = atoi(instancestr);
          _pdm_debug("current instanceno = <%d>", (char *)instanceno);
          ++instanceno;

          instancestr[0] = '\0';
          sprintf(instancestr, "%d", instanceno);
          strcat(test_usage, instancestr);
          PDUfill_in_string(&usageid2, test_usage);
          _pdm_debug("string to look for = <%s>", test_usage);
          row = 0;
          }
        }
     if ((found) && (!new_usage))
       {
       _pdm_debug("write usageid <%s> to buffer", test_usage);
       status =MEMwrite_data(*buffer2, usageid2, row2 + 1, usage2_col + 1);
       _pdm_status("MEMwrite_data", status);
       if (status != MEM_S_SUCCESS)
         return(PDM_E_WRITE_BUFFER);
       status = PDM_S_SUCCESS;
       }
     else if ((found) && (new_usage))
       {
       _pdm_debug("check buffer2 for duplicate usageids", 0);
       count = 0;
       for (index = 0; index < (*buffer2)->rows; ++index)
          {
          if (strcmp(usageid2, 
                     data2[((*buffer2)->columns * row2) + usage2_col]) == 0)
            {
            ++count;
            if (count > 1)
              {
              _pdm_debug("duplicate usageid found in buffer2", 0);
              length = strlen(usageid2);
              test_usage = (char *) malloc (sizeof (char) * length + 5);
              memset(test_usage, NULL, sizeof (char) * length + 5);
    
              i = 0;
              while ((usageid2[i] != '#') && (usageid2[i] != '\0'))
                ++i;
              ++i;
    
              strncpy(test_usage, usageid2, i);

              _pdm_debug("seeded usageid = <%s>", test_usage);
    
              _pdm_debug("get the instance number", 0);
              j = 0;
              while (usageid2[i] != '\0')
                {
                instancestr[j] = usageid2[i];
                ++i;
                ++j;
                }
    
              instanceno = atoi(instancestr);
              _pdm_debug("current instanceno = <%d>", (char *)instanceno);
              ++instanceno;
    
              instancestr[0] = '\0';
              sprintf(instancestr, "%d", instanceno);
              strcat(test_usage, instancestr);
              PDUfill_in_string(&usageid2, test_usage);
              _pdm_debug("string to look for = <%s>", test_usage);
              index = 0;
              }
            }
          }
       if (count < 2)
         {
         _pdm_debug("write usageid <%s> to buffer (case 2)", test_usage);
         status =MEMwrite_data(*buffer2, usageid2, row2 + 1, usage2_col + 1);
         _pdm_status("MEMwrite_data", status);
         if (status != MEM_S_SUCCESS)
           return(PDM_E_WRITE_BUFFER);
         status = PDM_S_SUCCESS;
         }
       }
     }

  if (PDMdebug_on)
    MEMprint_buffer("buffer2", *buffer2, PDU_DEBUG_FILE);

  return(status);
}

/* This function adds a file to the end of a link list of type PDUfile_list */

int PDUadd_file_to_list(cofilename, file_list)
  char   *cofilename;
  struct PDUfile_list **file_list;
{
  int                      status = PDM_S_SUCCESS;
  struct PDUfile_list    *temp = NULL, *local_list = NULL;

  _pdm_debug("in the function PDUadd_file_to_list", 0);

  if (PDM_debug_on)
    {
    if (*file_list)
      {
      _pdm_debug("file_list on entry", 0);
      PDUprint_file_linklist(*file_list);
      }
    }

  if (!(*file_list))
    {
    _pdm_debug("creating the beginning node", 0);
    temp = (struct PDUfile_list *)malloc(sizeof(struct PDUfile_list));
    *file_list = temp;
    temp->next = NULL;
    temp->cofilename = NULL_STRING;
    PDUfill_in_string(&(temp)->cofilename, cofilename);
    }
  else
    {
    local_list = *file_list;
    
    _pdm_debug("moving to end of current list", 0);
    while (local_list->next)
      local_list = local_list->next;
    temp = (struct PDUfile_list *)malloc(sizeof(struct PDUfile_list));

    _pdm_debug("initializing data", 0);
    temp->next = NULL;
    temp->cofilename = NULL_STRING;
  
    _pdm_debug("writing values", 0);
    PDUfill_in_string(&(temp)->cofilename, cofilename);

    local_list->next = temp;
    }

  if (PDM_debug_on)
    {
    if (*file_list)
      {
      _pdm_debug("printing global save file_list list", 0);
      PDUprint_file_linklist(*file_list);
      }
    }

  return(status);
}

/* This function prints a link list of type PDUfile_list */

int PDUprint_file_linklist(head)
  struct PDUfile_list   *head;
{
  int    status = PDM_S_SUCCESS;
  FILE  *pdu_debug_file, *fopen();

  _pdm_debug("in the function PDUprint_file_linklist", 0);

  if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
    {
    printf("Could not open debug file\n");
    return(PDM_E_OPEN_FILE);
    }

  while (head)
    {
    fprintf(pdu_debug_file, "cofilename = %s\n", head->cofilename);
    fprintf(pdu_debug_file, "\n");
    head = head->next;
    }

  fclose (pdu_debug_file);
  return(status);
}  /* end PDUprint_file_linklist */

/* This function traverses through a list of type PDUfile_list to see if the
   the file that is passed in is already in the list.  1 is returned if the
   file is in the list. */

int PDUis_file_in_list(filename, file_list)
char   *filename;
struct PDUfile_list *file_list;
{
  _pdm_debug("in the function PDUis_file_in_list", 0);

  if (!file_list)
    {
    _pdm_debug("file list is NULL", 0);
    return(0);
    }

  while (file_list)
    {
    if (strcmp(file_list->cofilename, filename) == 0)
      {
      _pdm_debug("file found in parts list", 0);
      return(1);
      }
    file_list = file_list->next;
    }

  _pdm_debug("file is not in list", 0);
  return(0);
}

/* This function frees a link list of type PDUfile_list */

int PDUfree_file_list(list)
  struct PDUfile_list  **list;
{
  struct PDUfile_list * head = NULL;
  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUfree_file_list", 0);

  if (*list)
    {
    _pdm_debug("setting head", 0);
    head = *list;

    _pdm_debug("entering while loop", 0);
    while ((*list)->next)
      {
      *list = (*list)->next;

      /* free the current node in the list */
      _pdm_debug("freeing head", 0);
      free(head);

      /* reset the pointer */
      _pdm_debug("resetting pointer", 0);
      head = *list;
      }

    _pdm_debug("setting list to NULL", 0);
    *list = NULL;
    }

  return(status);
}

int PDUmodify_assembly_thru_OBJ2(assy_bufr)
  MEMptr assy_bufr;
{
  int    status = PDM_S_SUCCESS;
  int    status1 = PDM_S_SUCCESS;
  int    row = 0;
  int    level = 0;
  int    level_col = 0;
  int    cat_col = 0;
  int    part_col = 0;
  int    rev_col = 0;
  int    row_col = 0;
  int    i = 0;
  int    buffer_row = 0;
  int    parent_level = 0;
  int    parent_row = 0;
  int    newfile_col = 0;
  int    k = 0;
  int    disp_col = 0;
  int    test_level = 0;
  int    type_col = 0;
  int    del_col = 0;
  char   *add_msg = NULL;
  char   *del_msg = NULL;
  char   *title = NULL;
  char   **data_row = NULL;
  short  found = FALSE;
  short  in_list = FALSE;
  struct PDUparts_list *list = NULL;
  struct PDUrev_assy *temp_list = NULL;
  extern void PDUactive_part_form();
  extern void PDUdelete_active_part_form();

  int PDUmodify_assembly_thru_OBJ2();

  _pdm_debug("in the function PDUmodify_assembly_thru_OBJ2", 0);

  add_msg = (char *)PDUtranslate_message(PDM_I_ADDED_ROW);
  del_msg = (char *)PDUtranslate_message(PDM_I_DELETED);

      if (PDM_debug_on)
        {
        if (PDU_assy_ptr != NULL)
          {
          _pdm_debug("printing assembly linklist", 0);
          PDUprint_assy_linklist(PDU_assy_ptr);
          }
        }

  /* find the lowest level part that was changed in the structure */
  current_rev_assy = PDU_assy_ptr;
  found = FALSE;
  while (current_rev_assy)
    {
    if (((current_rev_assy->new_level > level) && 
         (strcmp(current_rev_assy->display, "Y") == 0)) &&
        ((strcmp(current_rev_assy->add, "Y") == 0) ||
         (strcmp(current_rev_assy->delete, "Y") == 0)))
      {
      level = current_rev_assy->new_level;
      row = current_rev_assy->mcf_row;
      found = TRUE;
      }
    current_rev_assy = current_rev_assy->next;
    }
 
  if (!found)
    {
    _pdm_debug("Successful exit from PDUmodify_assembly_thru_OBJ2", 0);
    return(PDM_S_SUCCESS);
    }

  _pdm_debug("the lowest level of explosion is %d", (char *)level);
  _pdm_debug("part is on mcf_row %d", (char *)row);

  /* go back to the lowest level part */
  current_rev_assy = PDU_assy_ptr;
  while (current_rev_assy)
    {
    if (current_rev_assy->mcf_row == row)
      break;
    else
      current_rev_assy = current_rev_assy->next;
    }

  parent_level = current_rev_assy->new_level - 1;

  status = MEMbuild_array(assy_bufr);
  _pdm_status("MEMbuild_array", status);

  PDUsetup_buffer(assy_bufr, ROW, &data_row);

  PDUget_buffer_col(assy_bufr, "new_level", &level_col);
  PDUget_buffer_col(assy_bufr, "new_catalog", &cat_col);
  PDUget_buffer_col(assy_bufr, "new_partid", &part_col);
  PDUget_buffer_col(assy_bufr, "new_revision", &rev_col);
  PDUget_buffer_col(assy_bufr, "mcf_row", &row_col);
  PDUget_buffer_col(assy_bufr, "display", &disp_col);
  PDUget_buffer_col(assy_bufr, "new_cofilename", &newfile_col);
  PDUget_buffer_col(assy_bufr, "ex_parttype", &type_col);
  PDUget_buffer_col(assy_bufr, "delete", &del_col);

  _pdm_debug("find active row in the buffer", 0);
  buffer_row = -1;
  for (i = 0; i < assy_bufr->rows; ++i)
     {
     buffer_row = atoi(data_row[(assy_bufr->columns * i) + row_col]);

     if (buffer_row == current_rev_assy->mcf_row)
       {
       _pdm_debug("matching row is %d", (char *)buffer_row);
       level = atoi(data_row[(assy_bufr->columns * i) + level_col]);
       parent_level = level - 1;
       break;
       }
     }
  if (buffer_row == -1)
    {
    _pdm_debug("matching row not found in buffer", 0);
    return(PDM_E_ROW_NOT_FOUND);
    }

  _pdm_debug("search backwards for the parent part", 0);
    found = FALSE;
    for (k = i - 1; k >= 0; --k)
       {
       _pdm_debug("k = %d", (char *)k);
       if (strcmp(data_row[(assy_bufr->columns * k) + disp_col], "N")==0)
         {
         _pdm_debug("skipping row %d", (char *)k);
         continue;
         }
  
       if (strcmp(data_row[(assy_bufr->columns * k) + del_col], "Y")==0)
         {
         _pdm_debug("parent part is marked for delete: make recursive function call", 0);
         strcpy(current_rev_assy->display, "N");
  
         _pdm_debug("recursive call to PDUmodify_assembly_thru_OBJ2", 0);
         status = PDUmodify_assembly_thru_OBJ2(assy_bufr);
         _pdm_status("PDUmodify_assembly_thru_OBJ2", status);
         return(status);
         }
  
       test_level = atoi(data_row[(assy_bufr->columns * k) + level_col]);
       _pdm_debug("test_level = %d", (char *)test_level);
  
       if (parent_level == test_level)
         {
         _pdm_debug("parent part found", 0);
         PDUfill_in_string(&PDU_assy_catalog, 
                           data_row[(assy_bufr->columns * k) + cat_col]);
         PDUfill_in_string(&PDU_assy_partid, 
                           data_row[(assy_bufr->columns * k) + part_col]);
         PDUfill_in_string(&PDU_assy_revision, 
                           data_row[(assy_bufr->columns * k) + rev_col]);
         PDUfill_in_string(&PDU_assy_parttype, 
                           data_row[(assy_bufr->columns * k) + type_col]);
         parent_row = atoi(data_row[(assy_bufr->columns * k) + row_col]);
  
         found = TRUE;
         break;
         }
       }
    if (!found)
      {
      _pdm_debug("parent part not found in buffer", 0);
      return(PDM_E_ROW_NOT_FOUND);
      }
  
  _pdm_debug("parent_row = %d", (char *)parent_row);
  _pdm_debug("parent_level = %d", (char *)parent_level);
  _pdm_debug("catalog = <%s>", PDU_assy_catalog);
  _pdm_debug("partid = <%s>", PDU_assy_partid);
  _pdm_debug("revision = <%s>", PDU_assy_revision);

  status = PDUprocess_parent_for_revise_assembly(   parent_row, 
							parent_level,
							assy_bufr);
  _pdm_status("PDUprocess_parent_for_revise_assembly", status);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    sleep(3);

    list = PDU_checked_out_parts;
    in_list = PDUis_part_in_list(PDU_assy_catalog,
                        PDU_assy_partid,
                        PDU_assy_revision, list);
    _pdm_debug("PDUis_part_in_list returns <%d>", (char *)in_list);
        
    if (in_list)
      {
      _pdm_debug("cancel checkout for the parent part", 0);
      PDUdelete_active_part_form();
    
      /* display active part form */
      title = (char *)PDUtranslate_message(PDM_I_CANCELLING_CHECKOUT);
      PDUactive_part_form(PDU_assy_catalog, 
                          PDU_assy_partid, 
                          PDU_assy_revision, "", title);
    
      PDUfill_in_string(&refresh->rev_catalog, PDU_assy_catalog);
      PDUfill_in_string(&refresh->rev_partid, PDU_assy_partid);
      PDUfill_in_string(&refresh->rev_revision, PDU_assy_revision);
      PDUfill_in_string(&refresh->rev_parttype, PDU_assy_parttype);
    
      status1 = PDUext_cancel_checkout();
      _pdm_status("PDUext_cancel_checkout", status1);
      PDUmessage(status1, 's');
  
      PDUdelete_active_part_form();
      }
    return(status);
    }

  /* reset the link list */
  current_rev_assy = PDU_assy_ptr;

  _pdm_debug("freeing variables", 0);
  if (title) free(title);
  if (add_msg) free(add_msg);
  if (del_msg) free(del_msg);

  if (parent_level > 0)
    {
    _pdm_debug("regenerate the assy_bufr", 0);
    temp_list = PDU_assy_ptr;
    if (assy_bufr)
      {
      MEMclose(&assy_bufr);
      assy_bufr = NULL;
      }
    status = PDUassy_list_to_ASSY_BUFR(temp_list, &assy_bufr);
    _pdm_status("PDUassy_list_to_ASSY_BUFR", status);
    if (status != PDM_S_SUCCESS)
      {
      MEMclose(&assy_bufr);
      assy_bufr = NULL;
      }
    temp_list = NULL;
    }

  _pdm_debug("recursive call to PDUmodify_assembly_thru_OBJ2", 0);
  status = PDUmodify_assembly_thru_OBJ2(assy_bufr);
  _pdm_status("PDUmodify_assembly_thru_OBJ2", status);

  _pdm_debug("Exit:  PDUmodify_assembly_thru_OBJ2", 0);
  return(status);
}

int PDUprocess_parent_for_revise_assembly(parent_row, parent_level, assy_bufr)
int	parent_row;
int	parent_level;
MEMptr	assy_bufr;
{
  int       status = PDM_S_SUCCESS;
  int       part_status = PDM_S_SUCCESS;
  int       i = 0;
  int       n = 0;
  int       index = 0;
  int       file_count = 0;
  int       new_file_count = 0;
  int       child_row = 0;
  short     ng_modify = FALSE;
  short     found = FALSE;
  short     parent_design_file = TRUE;
  char      *file_list[10];
  char      *new_file_list[10];
  char      *title = NULL;
  char      *save_catalog = NULL;
  char      *add_msg = NULL;
  struct    PDUparts_list *list = NULL;
  extern void PDUactive_part_form();

  _pdm_debug("in the function PDUprocess_parent_for_revise_assembly", 0);

  _pdm_debug("find the parent in the link list", 0);
  current_rev_assy = PDU_assy_ptr;
  found = FALSE;
  while (current_rev_assy)
    {
    if ((current_rev_assy->mcf_row == parent_row) &&
        (current_rev_assy->new_level == parent_level) &&
        (strcmp(current_rev_assy->display, "Y") == 0))
      {
      _pdm_debug("parent part found in link list", 0);
      found = TRUE;
      break;
      }
    current_rev_assy = current_rev_assy->next;
    }
  
  if (!found)
    {
    _pdm_debug("error finding parent part in link list", 0);
    return(PDM_E_PART_IN_LIST);
    }

  /* checkout the parent part */
  if ((current_rev_assy->new_cofilename) && 
      (strlen(current_rev_assy->new_cofilename)))
    {
    _pdm_debug("checking file status of parent part", 0);
    part_status = PDMrcheck_part_status(current_rev_assy->new_catalog, 
                                        current_rev_assy->new_partid, 
                                        current_rev_assy->new_revision);
    _pdm_status("PDMrcheck_part_status", part_status);
    _pdm_status("part_status", part_status);
    if (part_status == PDM_I_CHECKED_IN)
      {
      /* check out parent part */
      status = PDUcheckout_part_for_revise_assembly(
                                               current_rev_assy->new_catalog,
                                               current_rev_assy->new_partid,
                                               current_rev_assy->new_revision,
                                               "", "",  /* desc, filename */
                                               current_rev_assy->new_parttype);
      _pdm_status("PDUcheckout_part_for_revise_assembly", status);
      if (status != PDM_S_SUCCESS)
        return(status);
  
      list = PDU_checked_out_parts;
      status = PDUadd_part_to_list(current_rev_assy->new_catalog,
                                   current_rev_assy->new_partid,
                                   current_rev_assy->new_revision,
                                   "",   /* desc */
                                   current_rev_assy->new_parttype,
                                   "", "",
                                   &list);
      _pdm_status("PDUadd_part_to_list", status);
      PDU_checked_out_parts = list;
      }
    }

  /* initialize file lists */
  for (i = 0; i < 10; ++i)
     {
     file_list[i] = NULL;
     new_file_list[i] = NULL;
     }

/* may need to get the filenames for the parent part */

  _pdm_debug("create file list for parent part", 0);
  if (current_rev_assy->new_cofilename)
    PDUfill_in_string(&file_list[0], current_rev_assy->new_cofilename);

  _pdm_debug("check for multiple files", 0);
  if (current_rev_assy)
    current_rev_assy = current_rev_assy->next;
  index = 1;
  while ((current_rev_assy) && (current_rev_assy->new_level == -1))
    {
    PDUfill_in_string(&file_list[index], current_rev_assy->new_cofilename);
    current_rev_assy = current_rev_assy->next;
    ++index;
    }
  _pdm_debug("parent part has <%d> files", (char *)index);
  file_count = index;


  _pdm_debug("process the child parts", 0);
  while ((current_rev_assy) && (current_rev_assy->new_level != parent_level))
    {
    if (!parent_design_file)
      {
      _pdm_debug("parent part does not have a design file; break", 0);
      break;
      }
    if (current_rev_assy->new_level != (parent_level + 1))
      {
      _pdm_debug("skipping nested part", 0);
      current_rev_assy = current_rev_assy->next;
      continue;
      }

    if ((strcmp(current_rev_assy->display, "Y") == 0) &&
        (current_rev_assy->new_level == -1))
      {
      _pdm_debug("skipping multiple file", 0);
      current_rev_assy = current_rev_assy->next;
      continue;
      }

    if (strcmp(current_rev_assy->add, "Y") == 0) 
      {
      _pdm_debug("processing part to be added", 0);
      child_row = current_rev_assy->mcf_row;

      /* if the part being placed has never been checked in, has all files
         created, and attach flag is ON, check in the part */

      add_msg = (char *)PDUtranslate_message(PDM_I_ADDED_ROW);

      _pdm_debug("attach flag = <%d>", current_rev_assy->p_attached);
      if (strcmp(current_rev_assy->p_attached, "Y") == 0)
/*
          (strcmp(current_rev_assy->ex_catalog, add_msg) != 0))
*/
        {
        _pdm_debug("creating file list for child part", 0);
        index = 0;
        PDUfill_in_string(&new_file_list[index],
                          current_rev_assy->new_cofilename);
        _pdm_debug("first file = <%s>", new_file_list[index]);
        current_rev_assy = current_rev_assy->next;

        ++index;
        if ((new_file_list[0]) && (strlen(new_file_list[0])))
          {
          while ((current_rev_assy) && (current_rev_assy->new_level == -1))
            {
            PDUfill_in_string(&new_file_list[index], 
                              current_rev_assy->new_cofilename);
            current_rev_assy = current_rev_assy->next;
            ++index;
            }
          _pdm_debug("child part has <%d> files", (char *)index);
          new_file_count = index;
          }
        else
          {
          _pdm_debug("filename is empty", 0);
          PDUfill_in_string(&new_file_list[0], NULL_STRING);
          new_file_count = 0;
/* may need to call get_filenames to be sure */
          }

        _pdm_debug("reset the link list to point to the child part", 0);
        current_rev_assy = PDU_assy_ptr;
        found = FALSE;
        while (current_rev_assy)
          {
          if ((current_rev_assy->mcf_row == child_row) &&
              (strcmp(current_rev_assy->display, "Y") == 0))
            {
            _pdm_debug("child part found in link list", 0);
            found = TRUE;
            break;
            }
          current_rev_assy = current_rev_assy->next;
          }
        
        if (!found)
          {
          _pdm_debug("error finding child part in link list", 0);
          return(PDM_E_PART_IN_LIST);
          }

        if (new_file_count > 0)
          {
          /* check the file status of the part */
          status = PDMrcheck_part_status(current_rev_assy->new_catalog,
                                         current_rev_assy->new_partid,
                                         current_rev_assy->new_revision);
          _pdm_status("PDMrcheck_part_status", status);
          if (status == PDM_I_NEVER_CHECKED_IN)
            {
            _pdm_debug("part has never been checked in", 0);
            if (new_file_count == 0)
              status = PDM_E_NULL_FILE_LIST;
  
            /* check to see if files are created */
            for (n = 0; n < new_file_count; ++n)
               {
               status = PDUverify_file(new_file_list[n]);
               _pdm_status("PDUverify_file", status);
               if (status != PDM_S_SUCCESS)
                 {
                 _pdm_debug("file <%s> has not been created", new_file_list[n]);
                 _pdm_debug("resetting attach flag", 0);
                 strcpy(current_rev_assy->p_attached, "N");
                 break;
                 }
               }
            if (status == PDM_S_SUCCESS)
              {
              _pdm_debug("checking in child part", 0);
              PDUfill_in_string(&refresh->rev_catalog,
                                 current_rev_assy->new_catalog);
              PDUfill_in_string(&refresh->rev_partid,
                                 current_rev_assy->new_partid);
              PDUfill_in_string(&refresh->rev_revision,
                                 current_rev_assy->new_revision);
              PDUfill_in_string(&refresh->rev_parttype,
                                 current_rev_assy->new_parttype);
  
              PDUdelete_active_part_form();
  
              /* display active part form */
              title = (char *)PDUtranslate_message(PDM_I_CHECKING_PART_IN);
              PDUactive_part_form(current_rev_assy->new_catalog,
                                  current_rev_assy->new_partid,
                                  current_rev_assy->new_revision,
                                  current_rev_assy->new_desc, title);
              if (title) free(title);
  
              status = PDUcheckin();
              _pdm_status("PDUcheckin", status);

              PDUdelete_active_part_form();
  
              if (status != PDM_S_SUCCESS)
                {
                PDUmessage(status);
                return(status);
                }
              _pdm_debug("part checked in successfully", 0);
              }
            status = PDM_S_SUCCESS;
            }
          }
        }
      else
        {
        PDUfill_in_string(&new_file_list[0], NULL_STRING);
        new_file_count = 0;
        }

      PDUfill_in_string(&save_catalog, refresh->rev_catalog);
      PDUfill_in_string(&refresh->rev_catalog, current_rev_assy->new_catalog);

      if (strcmp(current_rev_assy->new_parttype, "") == 0)
        {
        status = PDUget_parttype(current_rev_assy->new_catalog,
                                 current_rev_assy->new_partid,
                                 current_rev_assy->new_revision,
                                 &(current_rev_assy)->new_parttype);
        _pdm_status("PDUget_parttype", status);
        }

      if (strcmp(current_rev_assy->p_attached, "N") == 0)
        PDU_attach = FALSE;
      else if (strcmp(current_rev_assy->p_attached, "Y") == 0)
        PDU_attach = TRUE;

      if ((strcmp(current_rev_assy->new_parttype, "P") == 0) ||
          (strcmp(current_rev_assy->new_parttype, "p") == 0))
        PDU_attach = FALSE;

      if ((strcmp(current_rev_assy->new_parttype, "M") != 0) &&
          (strcmp(current_rev_assy->new_parttype, "m") != 0))
        {
        /* call function to modify object space */
        if (strcmp(current_rev_assy->ex_catalog, add_msg) != 0)
          {
          status = PDUreplace_part_for_revise_assembly(
                                  PDU_assy_catalog,
                                  PDU_assy_partid,
                                  PDU_assy_revision,
                                  PDU_assy_parttype,
                                  file_list,
                                  file_count,
                                  current_rev_assy->new_catalog,
                                  current_rev_assy->new_partid,
                                  current_rev_assy->new_revision,
                                  current_rev_assy->new_parttype,
                                  new_file_list,
                                  new_file_count,
                                  current_rev_assy->p_attached,
                                  current_rev_assy->p_quantity,
                                  current_rev_assy->new_usageid,
                                  current_rev_assy->p_alttagno,
                                  current_rev_assy->p_incbom,
                                  current_rev_assy->p_incstr,
                                  current_rev_assy->p_explode,
                                  current_rev_assy->p_usageid,
                                  current_rev_assy->add_db
                                  );
          _pdm_status("PDUreplace_part_for_revise_assembly", status);

/*
          if (status == PDM_E_DESIGN_FILE_NOT_FOUND)
            {
            _pdm_debug("check for child parts that may need to be added", 0);

            _pdm_debug("save place in current_rev_assy", 0);
            save_row = current_rev_assy->mcf_row;
            current_level = current_rev_assy->ex_level;
            _pdm_debug("current_level = %d", (char *)current_level);
            current_rev_assy = current_rev_assy->next;
 
            add_msg = (char *)PDUtranslate_message(PDM_I_ADDED_ROW);
 
            while ((current_rev_assy) &&
                   (current_rev_assy->ex_level != current_level))
              {
              if ((current_rev_assy->new_level == current_level + 1) &&
                  (strcmp(current_rev_assy->delete, "Y") != 0) &&
                  (strcmp(current_rev_assy->add, "Y") != 0) &&
                  (strcmp(current_rev_assy->ex_catalog, add_msg) != 0))
                {
                _pdm_debug("set add to Y for child part", 0);
                strcpy(current_rev_assy->add, "Y");
                PDUupdate_mult_files_for_rev_assy("add", "Y");
                }
              current_rev_assy = current_rev_assy->next;
              }
 
            _pdm_debug("reset current_rev_assy", 0);
            current_rev_assy = PDU_assy_ptr;
            while (current_rev_assy)
              {
              if (current_rev_assy->mcf_row == save_row)
                break;
              current_rev_assy = current_rev_assy->next;
              }
            _pdm_debug("active row is %d", current_rev_assy->mcf_row);
            }
*/
          }
        else if (strcmp(current_rev_assy->ex_catalog, add_msg) == 0)
          {
          status = PDUplace_part_for_revise_assembly(
                                  PDU_assy_catalog,
                                  PDU_assy_partid,
                                  PDU_assy_revision,
                                  PDU_assy_parttype,
                                  file_list,
                                  file_count,
                                  current_rev_assy->new_catalog,
                                  current_rev_assy->new_partid,
                                  current_rev_assy->new_revision,
                                  current_rev_assy->new_parttype,
                                  new_file_list,
                                  new_file_count,
                                  current_rev_assy->p_attached,
                                  current_rev_assy->p_quantity,
                                  current_rev_assy->new_usageid,
                                  current_rev_assy->p_alttagno,
                                  current_rev_assy->p_incbom,
                                  current_rev_assy->p_incstr,
                                  current_rev_assy->p_explode,
                                  current_rev_assy->add_db
                                  );
          _pdm_status("PDUplace_part_for_revise_assembly", status);
          }

        PDUfill_in_string(&refresh->rev_catalog, save_catalog);

        strcpy(current_rev_assy->add, "N");

        if (status == PDM_E_DESIGN_FILE_NOT_FOUND)
            {
            _pdm_debug("setting marker for non-graphic placement", 0);
            strcpy(current_rev_assy->add, "Y");
            PDUupdate_mult_files_for_rev_assy("add", "Y");
            status = PDM_S_SUCCESS;
            ng_modify = TRUE;
            parent_design_file = FALSE;
            }

        PDUdelete_active_part_form();

        if (refresh->status == PDM_E_CMD_CANCELLED)
          status = PDM_E_CMD_CANCELLED;
        if (status != PDM_S_SUCCESS)
          return(status);

        }
      else
        {
        _pdm_debug("placing a macro part", 0);
        _pdm_debug("setting marker for non-graphic placement", 0);
        strcpy(current_rev_assy->add, "Y");
        PDUupdate_mult_files_for_rev_assy("add", "Y");
        status = PDM_S_SUCCESS;
        ng_modify = TRUE;
        }

      }

    else if (strcmp(current_rev_assy->delete, "Y") == 0)
      {
      _pdm_debug("processing part to be deleted", 0);

      status = PDUdelete_part_for_revise_assembly(file_list,
						file_count,
						current_rev_assy->p_usageid,
						current_rev_assy->ex_catalog,
						current_rev_assy->ex_partid,
						current_rev_assy->ex_revision);
      _pdm_status("PDUdelete_part_for_revise_assembly", status);

      if (status == PDM_E_DESIGN_FILE_NOT_FOUND)
        {
        _pdm_debug("setting marker for non-graphic delete", 0);
        strcpy(current_rev_assy->delete, "Y");
        PDUupdate_mult_files_for_rev_assy("delete", "N");
        strcpy(current_rev_assy->add, "N");
        PDUupdate_mult_files_for_rev_assy("add", "N");
        ng_modify = TRUE;
        status = PDM_S_SUCCESS;
        parent_design_file = FALSE;
        }
      else
        {
        strcpy(current_rev_assy->delete, "N");
        PDUupdate_mult_files_for_rev_assy("delete", "N");
        strcpy(current_rev_assy->add, "N");
        PDUupdate_mult_files_for_rev_assy("add", "N");
        }

      if (status != PDM_S_SUCCESS)
        return(status);
      }

    if (current_rev_assy)
      current_rev_assy = current_rev_assy->next;
    }

  if (parent_design_file)
    {
    _pdm_debug("check in the parent part", 0);
    PDUfill_in_string(&refresh->rev_catalog, PDU_assy_catalog);
    PDUfill_in_string(&refresh->rev_partid, PDU_assy_partid);
    PDUfill_in_string(&refresh->rev_revision, PDU_assy_revision);
    PDUfill_in_string(&refresh->rev_parttype, PDU_assy_parttype);
  
    PDUdelete_active_part_form();
  
    /* display active part form */
    title = (char *)PDUtranslate_message(PDM_I_CHECKING_PART_IN);
    PDUactive_part_form(PDU_assy_catalog, PDU_assy_partid, PDU_assy_revision, 
                        "", title);
    if (title) free(title);
  
    status = PDUcheckin();
    _pdm_status("PDUcheckin", status);
  
    PDUdelete_active_part_form();
  
    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status);
      return(status);
      }
    }
  
  if (!ng_modify)
    {
    _pdm_debug("no parts to modify nongraphically", 0);
    return(status);
    }

  _pdm_debug("check to see if parts have to added/deleted thru the CIT", 0);
  if (ng_modify)
    {
    _pdm_debug("modifying assembly non_graphically", 0);
    status = PDUmodify_assembly_thru_database(parent_row, parent_level);
    _pdm_status("PDUmodify_assembly_thru_database", status);
    if (status != PDM_S_SUCCESS)
      return(status);
    }

  _pdm_debug("freeing pointers", 0);
  if (title) free (title);
  if (save_catalog) free (save_catalog);
  if (add_msg) free (add_msg);

  for (i = 0; i < 10; ++i)
     {
     if (file_list[i]) free (file_list[i]);
     if (new_file_list[i]) free (new_file_list[i]);
     }

  _pdm_debug("Exit:   PDUprocess_parent_for_revise_assembly", 0);
  return(status);
}

int PDUmodify_assembly_thru_database(parent_row, parent_level)
  int    parent_row;
  int    parent_level;
{
  int    status = PDM_S_SUCCESS;
  int    start_row;
  short  found = FALSE;
  char   *line = NULL;
  char   *add_msg = NULL;
  MEMptr buffer = NULL;

    _pdm_debug("in the function PDUmodify_assembly_thru_database", 0);

    _pdm_debug("parent_row = %d", (char *)parent_row);
    _pdm_debug("parent_level = %d", (char *)parent_level);

      if (PDM_debug_on)
        {
        if (PDU_assy_ptr != NULL)
          {
          _pdm_debug("printing assembly linklist", 0);
          PDUprint_assy_linklist(PDU_assy_ptr);
          }
        }

    _pdm_debug("set list to the first child of the current parent", 0);
    current_rev_assy = PDU_assy_ptr;
    found = FALSE;
    _pdm_debug("entering loop", 0);
    while (current_rev_assy)
      {
      if ((current_rev_assy->mcf_row == parent_row) &&
          (current_rev_assy->ex_level == parent_level) &&
          (strcmp(current_rev_assy->display, "Y") == 0))
        {
        _pdm_debug("parent part found in link list", 0);

        _pdm_debug("setting parent childno", 0);
        PDU_pchildno = current_rev_assy->p_childno;
        _pdm_debug("parent childno = %d", (char *)PDU_pchildno);

        current_rev_assy = current_rev_assy->next;
        found = TRUE;
        while ((current_rev_assy) && (current_rev_assy->new_level == -1))
          current_rev_assy = current_rev_assy->next;
        break;
        }
      current_rev_assy = current_rev_assy->next;
      }
    
/*
    if (current_rev_assy)
      current_rev_assy = current_rev_assy->next;
*/

    if ((!found) || (!current_rev_assy))
      {
      _pdm_debug("error finding first child in link list", 0);
      return(PDM_E_PART_IN_LIST);
      }

    _pdm_debug("setting start_row", 0);
    start_row = current_rev_assy->mcf_row;

    _pdm_debug("format an assembly buffer", 0);
    /* format a buffer to define the assembly structure */
    status = PDUformat_buffer(PDU_CHILD_BUFR, &buffer);
    _pdm_status("PDUformat_buffer", status);
  
    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return(status);
      }
  
    line = (char *) malloc (buffer->row_size);

    add_msg = (char *) PDUtranslate_message(PDM_I_ADDED_ROW);

 _pdm_debug("write parts to new buffer leaving out parts marked for delete", 0);

    while ((current_rev_assy) && 
           (current_rev_assy->new_level != parent_level))
      {
      if (current_rev_assy->new_level != parent_level + 1)
        {
        _pdm_debug("skipping nested part", 0);
        current_rev_assy = current_rev_assy->next;
        continue;
        }

      if ((strcmp(current_rev_assy->add, "Y") == 0) &&
          (strcmp(current_rev_assy->ex_catalog,
                  current_rev_assy->new_catalog) == 0) &&
          (strcmp(current_rev_assy->ex_partid,
                  current_rev_assy->new_partid) == 0) &&
          (strcmp(current_rev_assy->ex_revision,
                  current_rev_assy->new_revision) == 0))
        {
        _pdm_debug("resetting part on row %d to ADD = N", (char *)current_rev_assy->mcf_row);
        strcpy(current_rev_assy->add, "N");
        PDUupdate_mult_files_for_rev_assy("add", "N");
        }
 
      if (strcmp(current_rev_assy->delete, "Y") == 0)
        {
        _pdm_debug("deleting part:", 0);
        _pdm_debug("catalog <%s>", current_rev_assy->ex_catalog);
        _pdm_debug("partid <%s>", current_rev_assy->ex_partid);
        _pdm_debug("revision <%s>", current_rev_assy->ex_revision);

        _pdm_debug("ADD and DELETE should be N for these parts", 0);
        if (strcmp(current_rev_assy->display, "Y") == 0)
          {
          strcpy(current_rev_assy->add, "N");
          PDUupdate_mult_files_for_rev_assy("add", "N");
          strcpy(current_rev_assy->delete, "N");
          PDUupdate_mult_files_for_rev_assy("delete", "N");
          }
        }

      else if ((strcmp(current_rev_assy->display, "N") == 0) ||
              ((strcmp(current_rev_assy->add, "N") == 0) &&
               (strcmp(current_rev_assy->delete, "N") == 0)))
        {
        _pdm_debug("keeping part that is not displayed OR not marked for add or delete", 0);
        _pdm_debug("catalog <%s>", current_rev_assy->ex_catalog);
        _pdm_debug("partid <%s>", current_rev_assy->ex_partid);
        _pdm_debug("revision <%s>", current_rev_assy->ex_revision);

        memset(line, NULL, buffer->row_size);
        sprintf(line,
        "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1",
		current_rev_assy->p_childno,
		current_rev_assy->ex_catalog,
		current_rev_assy->ex_partid,
		current_rev_assy->ex_revision,
		current_rev_assy->p_attached,
		current_rev_assy->p_quantity,
		current_rev_assy->p_usageid,
		current_rev_assy->p_tagno,
		current_rev_assy->p_alttagno,
		current_rev_assy->p_incbom,
		current_rev_assy->p_incstr,
		current_rev_assy->p_explode,
		current_rev_assy->ex_cofilename,
		"",  /* entry for p_history */
		current_rev_assy->n_catalogno,
		current_rev_assy->n_itemno,
		1);  /* define assy expects level 1 parts only */

        status = MEMwrite(buffer, line);
        _pdm_status("MEMwrite (assembly buffer)", status);
        if (status != MEM_S_SUCCESS)
          {
          status = PDM_E_WRITE_ROW;
          PDUmessage(status, 's');
          return(status);
          }

        _pdm_debug("ADD and DELETE should be N for these parts", 0);
        if (strcmp(current_rev_assy->display, "Y") == 0)
          {
          strcpy(current_rev_assy->add, "N");
          PDUupdate_mult_files_for_rev_assy("add", "N");
          strcpy(current_rev_assy->delete, "N");
          PDUupdate_mult_files_for_rev_assy("delete", "N");
          }
        }
      else if (strcmp(current_rev_assy->add, "N") == 0)
        _pdm_debug("part on row %d is being added", (char *)current_rev_assy->mcf_row);

      if (current_rev_assy)
        current_rev_assy = current_rev_assy->next;
      }

    _pdm_debug("reset list to the first child of the current parent", 0);
    current_rev_assy = PDU_assy_ptr;
    found = FALSE;
    while (current_rev_assy)
      {
      if ((current_rev_assy->mcf_row == start_row) &&
          (strcmp(current_rev_assy->display, "Y") == 0))
        {
        _pdm_debug("first child found in link list", 0);
        found = TRUE;
        break;
        }
      current_rev_assy = current_rev_assy->next;
      }
    
    if (!found)
      {
      _pdm_debug("error finding first child in link list", 0);
      return(PDM_E_PART_IN_LIST);
      }

    _pdm_debug("add new parts to buffer", 0);
    while ((current_rev_assy) && (current_rev_assy->new_level != parent_level))
      {
      if ((strcmp(current_rev_assy->add, "Y") == 0) &&  
          (current_rev_assy->new_level == (parent_level + 1)))
        {
        status = PDUng_place_part_for_revise_assembly(start_row);
        _pdm_status("PDUng_place_part_for_revise_assembly", status);
        if (status != PDM_S_SUCCESS)
          return(status);

        memset(line, NULL, buffer->row_size);
        sprintf(line,
        "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1",
                     current_rev_assy->p_childno,
                     current_rev_assy->new_catalog,
                     current_rev_assy->new_partid,
                     current_rev_assy->new_revision,
                     current_rev_assy->p_attached,
                     current_rev_assy->p_quantity,
                     current_rev_assy->new_usageid,
                     current_rev_assy->p_tagno,
                     current_rev_assy->p_alttagno,
                     current_rev_assy->p_incbom,
                     current_rev_assy->p_incstr,
                     current_rev_assy->p_explode,
                     current_rev_assy->new_cofilename,
                     current_rev_assy->p_history,
                     current_rev_assy->n_catalogno,
                     current_rev_assy->n_itemno,
                     1);  /* parts are always added at level 1 - p_level */

        status = MEMwrite(buffer, line);
        _pdm_status("MEMwrite (assembly buffer)", status);
        if (status != MEM_S_SUCCESS)
          {
          status = PDM_E_WRITE_ROW;
          PDUmessage(status, 's');
          return(status);
          }

        _pdm_debug("setting ADD to N for <%s>", current_rev_assy->new_usageid);
        strcpy(current_rev_assy->add, "N");
        PDUupdate_mult_files_for_rev_assy("add", "N");
        strcpy(current_rev_assy->delete, "N");
        PDUupdate_mult_files_for_rev_assy("delete", "N");
        }

      current_rev_assy = current_rev_assy->next;
      }

  status = PDMdefine_assembly_structure(PDU_assy_catalog, 
                                        PDU_assy_partid, 
                                        PDU_assy_revision, 
                                        1, buffer);
  _pdm_status("PDMdefine_assembly_structure", status);

  _pdm_debug("freeing pointers", 0);
  if (line) free (line);
  if (add_msg) free (add_msg);

  _pdm_debug("Exit:   PDUmodify_assembly_thru_database", 0);
  return(status);
}

int PDUupdate_mult_files_for_rev_assy(field, value)
char  *field;
char  *value;
{
  int  mcf_row = 0;

  _pdm_debug("in the function PDUupdate_mult_files_for_rev_assy", 0);

  mcf_row = current_rev_assy->mcf_row;
  _pdm_debug("first file is on row %d", (char *)current_rev_assy->mcf_row);

  if (current_rev_assy)
    current_rev_assy = current_rev_assy->next;

  while ((current_rev_assy) && (current_rev_assy->new_level == -1))
    {
    if (strcmp(field, "add_db") == 0)
      {
      _pdm_debug("setting add_db to <%s>", value);
      strcpy(current_rev_assy->add_db, value);
      }
    else if (strcmp(field, "add") == 0)
      {
      _pdm_debug("setting add to <%s>", value);
      strcpy(current_rev_assy->add, value);
      }
    else if (strcmp(field, "delete") == 0)
      {
      _pdm_debug("setting delete to <%s>", value);
      strcpy(current_rev_assy->delete, value);
      }
    current_rev_assy = current_rev_assy->next;
    }

  _pdm_debug("resetting current_rev_assy", 0);
  current_rev_assy = PDU_assy_ptr;
  while (current_rev_assy)
    {
    if (current_rev_assy->mcf_row == mcf_row)
      break;
    current_rev_assy = current_rev_assy->next;
    }

  _pdm_debug("Exit:   PDUupdate_mult_files_for_rev_assy", 0);
  return(PDM_S_SUCCESS);
}

int PDUcreate_copy_buffer_for_rev_assy(file_bufr)
MEMptr   *file_bufr;
{

  int   status = PDM_S_SUCCESS;
  int   type = 0;
  int   char_index = 0;
  int   save_row = 0;
  char  *line = NULL;

  _pdm_debug("in the function PDUcreate_copy_buffer_for_rev_assy", 0);

  /* create buffer */
  type = PDU_FILE_BUFFER;

  status = PDUformat_buffer (type, file_bufr);
  _pdm_status("PDUformat_buffer", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  line = (char*) malloc ((*file_bufr)->row_size);

  memset (line, NULL, (*file_bufr)->row_size);
  char_index = 0;

  /* add the n_catalogno and n_itemno columns to the buffer */
  line[char_index++] = '\1';    /* entry for n_catalono */
  line[char_index++] = '\1';    /* entry for n_itemno */

  if (current_rev_assy->ex_catalog && (strlen (current_rev_assy->ex_catalog )))
    PDUadd_buffer_string(line, &char_index, current_rev_assy->ex_catalog);
  else
    line[char_index++] = '\1';

  if (current_rev_assy->ex_partid && (strlen (current_rev_assy->ex_partid )))
    PDUadd_buffer_string(line, &char_index, current_rev_assy->ex_partid);
  else
    line[char_index++] = '\1';

  if (current_rev_assy->ex_revision && (strlen (current_rev_assy->ex_revision )))
    PDUadd_buffer_string(line, &char_index, current_rev_assy->ex_revision);
  else
    line[char_index++] = '\1';

  if (current_rev_assy->ex_cofilename && (strlen (current_rev_assy->ex_cofilename )))
    PDUadd_buffer_string(line, &char_index, current_rev_assy->ex_cofilename);
  else
    line[char_index++] = '\1';

  if (current_rev_assy->ex_parttype && (strlen (current_rev_assy->ex_parttype )))
    PDUadd_buffer_string(line, &char_index, current_rev_assy->ex_parttype);
  else
    line[char_index++] = '\1';

  line[char_index++] = '\1';    /* entry for p_action */
  _pdm_debug("line = <%s>", line);
  status = MEMwrite (*file_bufr, line);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    {
    _pdm_debug("Error writing to file buffer", 0);
    _pdm_status("MEMwrite_format ()", status);

    memset (line, NULL, (*file_bufr)->row_size);
    }

  save_row = current_rev_assy->mcf_row;

  if (current_rev_assy->next)
    current_rev_assy = current_rev_assy->next;

  while (current_rev_assy && (current_rev_assy->ex_level == -1))
    {
    _pdm_debug("adding multiple files to buffer", 0);
    memset (line, NULL, (*file_bufr)->row_size);
    char_index = 0;
  
    /* add the n_catalogno and n_itemno columns to the buffer */
    line[char_index++] = '\1';    /* entry for n_catalono */
    line[char_index++] = '\1';    /* entry for n_itemno */
  
    if (current_rev_assy->ex_catalog && (strlen (current_rev_assy->ex_catalog )))
      PDUadd_buffer_string(line, &char_index, current_rev_assy->ex_catalog);
    else
      line[char_index++] = '\1';
  
    if (current_rev_assy->ex_partid && (strlen (current_rev_assy->ex_partid )))
      PDUadd_buffer_string(line, &char_index, current_rev_assy->ex_partid);
    else
      line[char_index++] = '\1';
  
    if (current_rev_assy->ex_revision && (strlen (current_rev_assy->ex_revision )))
      PDUadd_buffer_string(line, &char_index, current_rev_assy->ex_revision);
    else
      line[char_index++] = '\1';
  
    if (current_rev_assy->ex_cofilename && (strlen (current_rev_assy->ex_cofilename )))
      PDUadd_buffer_string(line, &char_index, current_rev_assy->ex_cofilename);
    else
      line[char_index++] = '\1';
  
    if (current_rev_assy->ex_parttype && (strlen (current_rev_assy->ex_parttype )))
      PDUadd_buffer_string(line, &char_index, current_rev_assy->ex_parttype);
    else
      line[char_index++] = '\1';
  
    line[char_index++] = '\1';    /* entry for p_action */
    _pdm_debug("line = <%s>", line);
    status = MEMwrite (*file_bufr, line);
  
    if (status != MEM_S_SUCCESS)
      {
      _pdm_debug("Error writing to file buffer", 0);
      _pdm_status("MEMwrite_format ()", status);
  
      memset (line, NULL, (*file_bufr)->row_size);
      }
    current_rev_assy = current_rev_assy->next;
    }

  if (PDMdebug_on)
    MEMprint_buffer("file buffer", *file_bufr, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  _pdm_debug("resetting current_rev_assy", 0);
  current_rev_assy = PDU_assy_ptr;
  while (current_rev_assy)
    {
    if (current_rev_assy->mcf_row == save_row)
      break;
    current_rev_assy = current_rev_assy->next;
    }

  if ((*file_bufr) && ((*file_bufr)->rows == 0))
    {
    MEMclose(file_bufr);
    return(PDM_E_COPY_LIST_EMPTY);
    }

  return(status);
}
