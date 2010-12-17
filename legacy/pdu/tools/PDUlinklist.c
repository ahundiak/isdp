#include <stdio.h>
#include "PDUintdef.h"
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDUforms.h"
#include "PDUstr.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUproto.h"

#define ASSEMBLY_MCF  17

extern int PDMdebug_on;
extern int PDM_debug_on;
extern int PDU_sub_on_off;
extern char *PDU_assy_catalog;
extern char *PDU_assy_partid;
extern char *PDU_assy_revision;
extern char *PDU_usage_id;
extern char *PDU_quantity;
extern char *PDU_tagno;
extern char *PDU_alt_tagno;
extern char *PDU_incl_BOM;
extern char *PDU_incl_ASM;
extern char *PDU_explode_BOM;
extern struct PDUassy_node  *PDU_assy_head;
extern struct PDUforms  forms;

int PDUassy_buffer_to_linklist(assy_bufr)
  MEMptr    assy_bufr;
{
  int                      status = PDM_S_SUCCESS;
  struct PDUassy_node      *temp, *tail;
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
  int                      inc_str;
  int                      row;
  char                     **data_row;

  _pdm_debug("in the function PDUassy_buffer_to_linklist", 0);

  _pdm_debug("assy_bufr->rows = %d", (char *)assy_bufr->rows);

  if ((assy_bufr->rows <= 1) || (assy_bufr == NULL))
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
    temp = (struct PDUassy_node *)malloc(sizeof(struct PDUassy_node));
    PDU_assy_head = temp;
    tail = PDU_assy_head;

    temp->next = NULL;
    temp->p_level = NULL;
    temp->p_pchildno = NULL;
    temp->p_childno = NULL;
    temp->n_catalogname = NULL;
    temp->n_itemname = NULL;
    temp->n_itemrev = NULL;
    temp->p_attached = NULL;
    temp->p_quantity = NULL;
    temp->p_usageid = NULL;
    temp->p_tagno = NULL;
    temp->p_alttagno = NULL;
    temp->p_incbom = NULL;
    temp->p_incstr = NULL;
    temp->p_explode = NULL;
    temp->p_filename = NULL;
    temp->p_history = NULL;
    temp->n_catalogno = NULL;
    temp->n_itemno = NULL;

    row = 1;
    temp->p_level = atoi(data_row[(assy_bufr->columns * row) + level_col]);
    temp->p_pchildno = atoi(data_row[(assy_bufr->columns * row) + parent_col]);
    temp->p_childno = atoi(data_row[(assy_bufr->columns * row) + child_col]);
    PDUfill_in_string(&(temp->n_catalogname),
           data_row[(assy_bufr->columns * row) + cat_col]);
    PDUfill_in_string(&(temp->n_itemname),
           data_row[(assy_bufr->columns * row) + part_col]);
    PDUfill_in_string(&(temp->n_itemrev),
           data_row[(assy_bufr->columns * row) + rev_col]);
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
    PDUfill_in_string(&(temp->p_filename),
           data_row[(assy_bufr->columns * row) + file_col]);
    PDUfill_in_string(&(temp->p_history), "");
    temp->n_catalogno = atoi(data_row[(assy_bufr->columns * row) + catno_col]);
    temp->n_itemno = atoi(data_row[(assy_bufr->columns * row) + itemno_col]);

    if (assy_bufr->rows == 2)
      if (PDM_debug_on)
        {
        if (PDU_assy_head != NULL)
          {
          _pdm_debug("printing assembly linklist", 0);
          PDUprint_linklist(PDU_assy_head);
          }
        }

    for (row = 2; row < assy_bufr->rows; ++row)
       {
       /* create the beginning node */
       temp = (struct PDUassy_node *)malloc(sizeof(struct PDUassy_node));
       temp->next = NULL;
       temp->p_level = NULL;
       temp->p_pchildno = NULL;
       temp->p_childno = NULL;
       temp->n_catalogname = NULL;
       temp->n_itemname = NULL;
       temp->n_itemrev = NULL;
       temp->p_attached = NULL;
       temp->p_quantity = NULL;
       temp->p_usageid = NULL;
       temp->p_tagno = NULL;
       temp->p_alttagno = NULL;
       temp->p_incbom = NULL;
       temp->p_incstr = NULL;
       temp->p_explode = NULL;
       temp->p_filename = NULL;
       temp->p_history = NULL;
       temp->n_catalogno = NULL;
       temp->n_itemno = NULL;

       temp->p_level = atoi(data_row[(assy_bufr->columns * row) + level_col]);
       temp->p_pchildno = 
                 atoi(data_row[(assy_bufr->columns * row) + parent_col]);
       temp->p_childno = atoi(data_row[(assy_bufr->columns * row) + child_col]);
       PDUfill_in_string(&(temp->n_catalogname),
              data_row[(assy_bufr->columns * row) + cat_col]);
       PDUfill_in_string(&(temp->n_itemname),
              data_row[(assy_bufr->columns * row) + part_col]);
       PDUfill_in_string(&(temp->n_itemrev),
              data_row[(assy_bufr->columns * row) + rev_col]);
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
       PDUfill_in_string(&(temp->p_filename),
              data_row[(assy_bufr->columns * row) + file_col]);
       PDUfill_in_string(&(temp->p_history), "");
       temp->n_catalogno = atoi(data_row[(assy_bufr->columns*row)+catno_col]);
       temp->n_itemno = atoi(data_row[(assy_bufr->columns * row) + itemno_col]);

       tail->next = temp;
       tail = temp;
       }
    }

  if (PDM_debug_on)
    {
    if (PDU_assy_head != NULL)
      {
      _pdm_debug("printing assembly linklist", 0);
      PDUprint_linklist(PDU_assy_head);
      }
    }

  return(status);
}  /* end PDUassy_buffer_to_linklist */

int PDUprint_linklist(head)
  struct PDUassy_node   *head;
{
  int    status = PDM_S_SUCCESS;
  FILE  *pdu_debug_file, *fopen();

  _pdm_debug("in the function PDUprint_linklist", 0);

  if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
    {
    printf("Could not open debug file\n");
    return(PDM_E_OPEN_FILE);
    }

  while (head)
    {
    fprintf(pdu_debug_file, "p_level       = %d\n", head->p_level);
    fprintf(pdu_debug_file, "p_pchildno    = %d\n", head->p_pchildno);
    fprintf(pdu_debug_file, "p_childno     = %d\n", head->p_childno);
    fprintf(pdu_debug_file, "n_catalogname = %s\n", head->n_catalogname);
    fprintf(pdu_debug_file, "n_itemname    = %s\n", head->n_itemname);
    fprintf(pdu_debug_file, "n_itemrev     = %s\n", head->n_itemrev);
    fprintf(pdu_debug_file, "p_attached    = %s\n", head->p_attached);
    fprintf(pdu_debug_file, "p_quantity    = %s\n", head->p_quantity);
    fprintf(pdu_debug_file, "p_usageid     = %s\n", head->p_usageid);
    fprintf(pdu_debug_file, "p_tagno       = %s\n", head->p_tagno);
    fprintf(pdu_debug_file, "p_alttagno    = %s\n", head->p_alttagno);
    fprintf(pdu_debug_file, "p_incbom      = %s\n", head->p_incbom);
    fprintf(pdu_debug_file, "p_incstr      = %s\n", head->p_incstr);
    fprintf(pdu_debug_file, "p_explode     = %s\n", head->p_explode);
    fprintf(pdu_debug_file, "p_filename    = %s\n", head->p_filename);
    fprintf(pdu_debug_file, "p_history     = %s\n", head->p_history);
    fprintf(pdu_debug_file, "n_catalogno   = %d\n", head->n_catalogno);
    fprintf(pdu_debug_file, "n_itemno      = %d\n", head->n_itemno);
    fprintf(pdu_debug_file, "\n");
    head = head->next;
    }

  fclose (pdu_debug_file);
  return(status);
}  /* end PDUprint_linklist */

int PDUassy_linklist_to_buffer(head, buffer)
  struct PDUassy_node     *head;
  MEMptr                  *buffer;
{
  int		status = PDM_S_SUCCESS;
  char          *line;

  _pdm_debug("in the function PDUassy_linklist_to_buffer", 0);

  if (PDM_debug_on)
    {
    if (PDU_assy_head != NULL)
      {
      _pdm_debug("printing assembly linklist", 0);
      PDUprint_linklist(PDU_assy_head);
      }
    }

  status = PDUformat_buffer(PDU_CHILD_BUFR, buffer);
  _pdm_status("PDUformat_buffer", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  line = (char *) malloc ((*buffer)->row_size);
  memset(line, NULL, (*buffer)->row_size);

  while (head)
     {
     if (head->p_level == 1)
       {
       sprintf(line, 
        "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1",
                     head->p_childno,
                     head->n_catalogname,
                     head->n_itemname,
                     head->n_itemrev,
                     head->p_attached,
                     head->p_quantity,
                     head->p_usageid,
                     head->p_tagno,
                     head->p_alttagno,
                     head->p_incbom,
                     head->p_incstr,
                     head->p_explode,
                     head->p_filename,
                     head->p_history,
                     head->n_catalogno,
                     head->n_itemno,
                     head->p_level);
       status = MEMwrite(*buffer, line);
       _pdm_status("MEMwrite (assembly buffer)", 0);
       if (status != MEM_S_SUCCESS)
         {
         status = PDM_E_WRITE_ROW;
         PDUmessage(status, 's');
         return(status);
         }
       }
     head = head->next;
     }

  if (PDMdebug_on)
    MEMprint_buffer("assembly buffer", *buffer, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    return(PDM_S_SUCCESS);
  else
    return(status);

}  /* end PDUassy_linklist_to_buffer */

void PDUdrop_node_from_linklist(usage_id)
  char                     *usage_id;
{
  struct PDUassy_node    *current_node, *prev_node;

  _pdm_debug("in the function PDUdrop_node_from_linklist", 0);

  if (PDU_assy_head == NULL)
    {
    _pdm_debug("linklist is empty", 0);
    return;
    }

  current_node = PDU_assy_head;
  prev_node = PDU_assy_head;

  _pdm_debug("usage id to delete = <%s>", usage_id);

  while (current_node)
    {
    if (strcmp(current_node->p_usageid, usage_id) != 0)
      {
      _pdm_debug("current_node->p_usageid = <%s>", current_node->p_usageid);
      prev_node = current_node;
      current_node = current_node->next;
      }
    else
      {
      /* drop node from linklist */
      if ((PDU_assy_head->next == NULL) && (PDU_assy_head->p_level == 1))
        {
        _pdm_debug("deleting last node in list: list is NULL", 0);
        free(PDU_assy_head);
        PDU_assy_head = NULL;
        }
      else if ((strcmp(PDU_assy_head->p_usageid, usage_id) == 0) &&
               (PDU_assy_head->p_level == 1))
        {
        _pdm_debug("deleting first node in list", 0);
        PDU_assy_head = current_node->next;
        free(current_node);
        }
      else
        {
        if (current_node->p_level == 1)
          {
          _pdm_debug("level = %d", (char *)current_node->p_level);
          _pdm_debug("deleting node after first node in list", 0);
          prev_node->next = current_node->next;
          free(current_node);
          }
        else
          {
          _pdm_debug("match not found", 0);
          prev_node = current_node;
          current_node = current_node->next;
          continue;
          }
        }

      _pdm_debug("dropped node <%s> from assembly linklist", usage_id);
      break;
      }
    }

  if (PDM_debug_on)
    {
    if (PDU_assy_head != NULL)
      {
      _pdm_debug("printing assembly linklist", 0);
      PDUprint_linklist(PDU_assy_head);
      }
    }

}  /* PDUdrop_node_from_linklist */

void PDUadd_node_to_linklist(level, parent, child, catalog, partid, revision,
                             attach, quantity, usage, tag, 
                             explode, filename, catalogno, itemno)
   int                        level;
   int                        parent;
   int                        child;
   char                      *catalog;
   char                      *partid;
   char                      *revision;
   char                      *attach;
   char                      *quantity;
   char                      *usage;
   char                      *tag;
   char                      *explode;
   char                      *filename;
   int                       catalogno;
   int                       itemno;
{
   struct PDUassy_node       *current_node, *temp;

   _pdm_debug("in the function PDUadd_node_to_linklist", 0);

   if (PDU_assy_head == NULL)
     {
     /* create the beginning node */
     temp = (struct PDUassy_node *)malloc(sizeof(struct PDUassy_node));
     PDU_assy_head = temp;

     temp->next = NULL;
     temp->p_level = NULL;
     temp->p_pchildno = NULL;
     temp->p_childno = NULL;
     temp->n_catalogname = NULL;
     temp->n_itemname = NULL;
     temp->n_itemrev = NULL;
     temp->p_attached = NULL;
     temp->p_quantity = NULL;
     temp->p_usageid = NULL;
     temp->p_tagno = NULL;
     temp->p_alttagno = NULL;
     temp->p_incbom = NULL;
     temp->p_incstr = NULL;
     temp->p_explode = NULL;
     temp->p_filename = NULL;
     temp->p_history = NULL;
     temp->n_catalogno = NULL;
     temp->n_itemno = NULL;
  
     temp->p_level = level;
     temp->p_pchildno = parent;
     temp->p_childno = child;
     PDUfill_in_string(&(temp->n_catalogname), catalog);
     PDUfill_in_string(&(temp->n_itemname), partid);
     PDUfill_in_string(&(temp->n_itemrev), revision);
     PDUfill_in_string(&(temp->p_attached), attach);
     PDUfill_in_string(&(temp->p_quantity), quantity);
     PDUfill_in_string(&(temp->p_usageid), usage);
     PDUfill_in_string(&(temp->p_tagno), tag);
     if (PDU_alt_tagno == NULL)
       PDUfill_in_string(&PDU_alt_tagno, "");
     PDUfill_in_string(&(temp->p_alttagno), PDU_alt_tagno);
     if ((PDU_incl_BOM == NULL) || (strcmp(PDU_incl_BOM, "") == 0))
       PDUfill_in_string(&PDU_incl_BOM, "Y");
     PDUfill_in_string(&(temp->p_incbom), PDU_incl_BOM);
     if ((PDU_incl_ASM == NULL) || (strcmp(PDU_incl_ASM, "") == 0))
       PDUfill_in_string(&PDU_incl_ASM, "N");
     PDUfill_in_string(&(temp->p_incstr), PDU_incl_ASM);
     PDUfill_in_string(&(temp->p_explode), explode);
     PDUfill_in_string(&(temp->p_filename), filename);
     PDUfill_in_string(&(temp->p_history), "");
     temp->n_catalogno = catalogno;
     temp->n_itemno = itemno;

     if (PDM_debug_on)
       {
       if (PDU_assy_head != NULL)
         {
         _pdm_debug("printing assembly linklist", 0);
         PDUprint_linklist(PDU_assy_head);
         }
       }
     return;
     }
   
   current_node = PDU_assy_head;

   while(current_node->next)
     current_node = current_node->next;

   /* create another node */
   temp = (struct PDUassy_node *)malloc(sizeof(struct PDUassy_node));

   temp->next = NULL;
   temp->p_level = NULL;
   temp->p_pchildno = NULL;
   temp->p_childno = NULL;
   temp->n_catalogname = NULL;
   temp->n_itemname = NULL;
   temp->n_itemrev = NULL;
   temp->p_attached = NULL;
   temp->p_quantity = NULL;
   temp->p_usageid = NULL;
   temp->p_tagno = NULL;
   temp->p_alttagno = NULL;
   temp->p_incbom = NULL;
   temp->p_incstr = NULL;
   temp->p_explode = NULL;
   temp->p_filename = NULL;
   temp->p_history = NULL;
   temp->n_catalogno = NULL;
   temp->n_itemno = NULL;
  
   temp->p_level = level;
   temp->p_pchildno = parent;
   temp->p_childno = child;
   PDUfill_in_string(&(temp->n_catalogname), catalog);
   PDUfill_in_string(&(temp->n_itemname), partid);
   PDUfill_in_string(&(temp->n_itemrev), revision);
   PDUfill_in_string(&(temp->p_attached), attach);
   PDUfill_in_string(&(temp->p_quantity), quantity);
   PDUfill_in_string(&(temp->p_usageid), usage);
   PDUfill_in_string(&(temp->p_tagno), tag);
   if (PDU_alt_tagno == NULL)
     PDUfill_in_string(&PDU_alt_tagno, "");
   PDUfill_in_string(&(temp->p_alttagno), PDU_alt_tagno);
   if ((PDU_incl_BOM == NULL) || (strcmp(PDU_incl_BOM, "") == 0))
     PDUfill_in_string(&PDU_incl_BOM, "Y");
   PDUfill_in_string(&(temp->p_incbom), PDU_incl_BOM);
   if ((PDU_incl_ASM == NULL) || (strcmp(PDU_incl_ASM, "") == 0))
     PDUfill_in_string(&PDU_incl_ASM, "N");
   PDUfill_in_string(&(temp->p_incstr), PDU_incl_ASM);
   PDUfill_in_string(&(temp->p_explode), explode);
   PDUfill_in_string(&(temp->p_filename), filename);
   PDUfill_in_string(&(temp->p_history), "");
   temp->n_catalogno = catalogno;
   temp->n_itemno = itemno;

   current_node->next = temp;

   if (PDM_debug_on)
     {
     if (PDU_assy_head != NULL)
       {
       _pdm_debug("printing assembly linklist", 0);
       PDUprint_linklist(PDU_assy_head);
       }
     }

}  /* end PDUadd_node_to_linklist */

int PDUfind_field_in_linklist(field, value)
  char                        *field;
  char                        **value;
{
  int      status = PDM_S_SUCCESS;
  struct PDUassy_node    *current_node;

  _pdm_debug("in the function PDUfind_field_in_linklist", 0);

  if (PDU_assy_head == NULL)
    return(PDM_E_NULL_LINKLIST);

  current_node = PDU_assy_head;

  while (current_node)
    {
    /* get contents of field for this node */
    if (strcmp(field, current_node->p_attached) == 0)
      {
      PDUfill_in_string(value, current_node->p_attached);
      break;
      }

    current_node = current_node->next;
    }

  return(status);
}  /* PDUfind_field_in_linklist */

int PDUupdate_field_in_linklist(field, value)
  char                        *field;
  char                        *value;
{
  int      status = PDM_S_SUCCESS;
  struct PDUassy_node    *current_node;

  _pdm_debug("in the function PDUupdate_field_in_linklist", 0);

  if (PDU_assy_head == NULL)
    return(PDM_E_NULL_LINKLIST);

  current_node = PDU_assy_head;

  while (current_node)
      {
      /* change contents of field for this node */
      if (strcmp(field, "p_attached") == 0)
        {
        PDUfill_in_string(&(current_node->p_attached), value);
        break;
        }

      current_node = current_node->next;
      }

  return(status);
}  /* PDUupdate_field_in_linklist */

int PDUfind_instanceno_in_linklist(head, usageid)
  struct PDUassy_node    *head;
  char                   **usageid;
{
  int      instanceno;
  char     test_usage[100];
  char     instance_str[10];
  struct PDUassy_node *head_save;
  short    cont;

  _pdm_debug("in the function PDUfind_instanceno_in_linklist", 0);

  if (head == NULL)
    return(PDM_E_NULL_LINKLIST);

  head_save = head;

  instanceno = 1;
  cont = TRUE;

  while (cont)
    {
    cont = FALSE;

    /* reset the link list */
    head_save = head;

    strcpy(test_usage, *usageid);
    _pdm_debug("trying instance number = %d", (char *)instanceno);
  
    sprintf(instance_str, "%d", instanceno);
    strcat(test_usage, " #");
    strcat(test_usage, instance_str);
    _pdm_debug("string to look for = <%s>", test_usage);

    while (head_save)
      {
      _pdm_debug("existing usageid = <%s>", head_save->p_usageid);

      if (head_save->p_level > 1)
        {
        head_save = head_save->next;
        continue;
        }
      
      if (strcmp(test_usage, head_save->p_usageid) == 0)
        {
        _pdm_debug("Occurence of part was found", 0);
        ++instanceno;
        cont = TRUE;
        break;
        }
      head_save = head_save->next;
      cont = FALSE;
      }
    }

  PDUfill_in_string(usageid, test_usage);

  return(PDM_S_SUCCESS);
}  /* PDUfind_instanceno_in_linklist */

int PDUfind_childno_in_linklist(head)
  struct PDUassy_node    *head;
{
  int      childno, tmp_childno;

  _pdm_debug("in the function PDUfind_childno_in_linklist", 0);

  if (head == NULL)
    return(PDM_E_NULL_LINKLIST);

  childno = 0;

  while (head)
    {
    tmp_childno = head->p_childno;
    if (tmp_childno > childno)
    childno = tmp_childno;
    head = head->next;
    }

  ++childno;
  _pdm_debug("childno = %d", (char *)childno);

  return(childno);
}  /* PDUfind_childno_in_linklist */

int PDUcheck_usageid_for_uniqueness(head, usageid)
  struct PDUassy_node   *head;
  char                  *usageid;
{
  int   found = FALSE;
  char  *string = NULL;

  _pdm_debug("PDUcheck_usageid_for_uniqueness", 0);

  found = FALSE;

  if (head == NULL)
    return(PDM_E_NULL_LINKLIST);

  /* get value of usageid for all parts */
  while (head)
    {
    PDUfill_in_string(&string, head->p_usageid);
    if (strcmp(string, usageid) == 0)
      found = TRUE;
    head = head->next;
    }

  return(found);

}  /* end PDUcheck_usageid_for_uniqueness */

int PDUgenerate_tagno_from_linklist(head)
  struct PDUassy_node   *head;
{
  int      tagno, tmp_tagno;
  char     *tag_str = NULL;
  struct PDUassy_node *head2 = NULL;

  _pdm_debug("in the function PDUgenerate_tagno_from_linklist", 0);

  if (head == NULL)
    return(PDM_E_NULL_LINKLIST);

  tagno = 0;

  head2 = head;

  while (head)
    {
    /* check for matching value in linklist */
    if ((strcmp(PDU_assy_catalog, head->n_catalogname) == 0) &&
        (strcmp(PDU_assy_partid, head->n_itemname) == 0) &&
        (strcmp(PDU_assy_revision, head->n_itemrev) == 0))
      {
      _pdm_debug("part already exists in structure", 0);
      PDUfill_in_string(&tag_str, head->p_tagno);
      sscanf(tag_str, "%d", &tmp_tagno);
      tagno = tmp_tagno;
      return(tagno);
      }
    head = head->next;
    }

  _pdm_debug("part does not already exist in structure", 0);
  _pdm_debug("generating new tag number", 0);

  /* get value of tagno */
  while (head2)
    {
    if ((strcmp(head2->p_tagno, "") != 0) && (head2->p_tagno != NULL))
      {
      PDUfill_in_string(&tag_str, head2->p_tagno);
      sscanf(tag_str, "%d", &tmp_tagno);
      if (tmp_tagno > tagno)
        tagno = tmp_tagno;
      }
    head2 = head2->next;
    }

  ++tagno;

  return(tagno);
}

int PDUcheck_alttag_for_uniqueness(head, alttag)
  struct PDUassy_node   *head;
  char                  *alttag;
{
  int   found = FALSE;
  char  *string = NULL;

  _pdm_debug("PDUcheck_alttag_for_uniqueness", 0);

  found = FALSE;

  if (head == NULL)
    return(PDM_E_NULL_LINKLIST);

  /* get value of alttag for all parts */
  while (head)
    {
    PDUfill_in_string(&string, head->p_alttagno);
    if (strcmp(string, alttag) == 0)
      found = TRUE;
    head = head->next;
    }

  return(found);

}  /* end PDUcheck_alttag_for_uniqueness */
