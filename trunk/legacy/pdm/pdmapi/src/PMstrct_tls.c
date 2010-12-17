#include "stdio.h"
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDUintdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "SQLerrordef.h"
#include "PDUproto.h"
#include "PDMproto.h"

extern int PDM_debug_on;


int PDUloadapi_transition_structure(spr_trans_bufr, spw_trans_list)
MEMptr    spr_trans_bufr;
struct part_transition **spw_trans_list;
{

  long    status = PDM_S_SUCCESS;
  int     statename_col = 0;
  int     stateno_col = 0;
  int     status_col = 0;
  int     trans_col = 0;
  int     row = 0;
  char    **data_row = NULL;
  char    cur_status[40];
  struct part_transition *temp = NULL;

  _pdm_debug("in the function PDUloadapi_transition_structure", 0);

  if (spr_trans_bufr == NULL)
    return(PDM_E_NULL_BUFFER);

  if (spr_trans_bufr->rows == 0)
    return(PDM_E_NULL_BUFFER);

  status = MEMbuild_array(spr_trans_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = PDUget_buffer_col(spr_trans_bufr, "n_statename", &statename_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(spr_trans_bufr, "n_stateno", &stateno_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(spr_trans_bufr, "n_transitionname", &trans_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(spr_trans_bufr, "n_status", &status_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  PDUsetup_buffer(spr_trans_bufr, ROW, &data_row);

  if (PDM_debug_on)
    MEMprint_buffer("spr_trans_bufr", spr_trans_bufr, PDU_DEBUG_FILE);

  _pdm_debug("getting the current state", 0);
  row = 0;
  cur_status[0] = '\0';
  strcpy(cur_status, data_row[(spr_trans_bufr->columns * row) + status_col]);
  _pdm_debug("current status = <%s>", cur_status);

  if (strcmp(cur_status, "CURRENT STATE") != 0)
    {
    /* create the beginning node */
    _pdm_debug("mallocing the first node", 0);
    temp = (struct part_transition *)malloc(sizeof(struct part_transition));
  
    temp->next = NULL;
    temp->statename[0] = '\0';
    temp->transition[0] = '\0';
    temp->stateno = 0;

    _pdm_debug("writing to first node", 0);
    strcpy((temp->statename),
                data_row[(spr_trans_bufr->columns * row) + statename_col]);
    temp->stateno = 
                atoi(data_row[(spr_trans_bufr->columns * row) + stateno_col]);
    strcpy((temp->transition),
                data_row[(spr_trans_bufr->columns * row) + trans_col]);

    _pdm_debug("pointing to second node", 0);
    if (!*spw_trans_list)
      *spw_trans_list = temp;
    else
      {
      temp->next = *spw_trans_list;
      *spw_trans_list = temp;
      }
    }

  for (row = 1; row < spr_trans_bufr->rows; ++row)
     {
     strcpy(cur_status, 
                       data_row[(spr_trans_bufr->columns * row) + status_col]);
     _pdm_debug("current status = <%s>", cur_status);

     if (strcmp(cur_status, "CURRENT STATE") != 0)
       {
       _pdm_debug("mallocing next node", 0);
       temp= (struct part_transition *)malloc(sizeof(struct part_transition));
       temp->next = NULL;
       temp->statename[0] = '\0';
       temp->transition[0] = '\0';
       temp->stateno = 0;

       _pdm_debug("writing to next node", 0);
       strcpy((temp->statename),
                 data_row[(spr_trans_bufr->columns * row) + statename_col]);
       temp->stateno = 
                 atoi(data_row[(spr_trans_bufr->columns * row) + stateno_col]);
       strcpy((temp->transition),
                 data_row[(spr_trans_bufr->columns * row) + trans_col]);
   
       _pdm_debug("pointing to next node", 0);
       if (!*spw_trans_list)
         *spw_trans_list = temp;
       else
         {
         temp->next = *spw_trans_list;
         *spw_trans_list = temp;
         }
       }
     }

  _pdm_debug("calling print", 0);
  if ((*spw_trans_list) && (PDM_debug_on))
    PDUprint_transition_list(*spw_trans_list);

  return(status);
}

int PDUloadapi_file_structure(	cpr_desc, 
				cpr_localfn, 
				cpr_stgfn, 
				cpr_type, 
				ir_mode, 
				spm_file_list)
char   *cpr_desc;
char   *cpr_localfn;
char   *cpr_stgfn;
char   *cpr_type;
int     ir_mode;
struct file_info **spm_file_list;
{

  long     status = PDM_S_SUCCESS;
  struct file_info *tail, *temp, *head;
  struct file_info *current = NULL;

  _pdm_debug("in the function PDUloadapi_file_structure", 0);

  if (cpr_desc == NULL)
    cpr_desc = NULL_STRING;
  if (cpr_localfn == NULL)
    cpr_localfn = NULL_STRING;
  if (cpr_stgfn == NULL)
    cpr_stgfn = NULL_STRING;
  if (cpr_type == NULL)
    cpr_type = NULL_STRING;

  if (strcmp(cpr_localfn, "") == 0)
    return(PDM_E_FILENAME_BLANK);

  current = *spm_file_list;
  _pdm_debug("checking for duplicate filenames", 0);
  if (*spm_file_list)
    {
    _pdm_debug("checking for duplicate filenames", 0);
    while (current)
      {
      if (strcmp(cpr_localfn, current->local_fn) == 0)
        {
        _pdm_debug("local filename <%s> is a duplicate", cpr_localfn);
        return(PDM_E_DUPLICATE_FILENAME);
        }
      if ((strcmp(cpr_stgfn, current->storage_fn) == 0) && 
          (strcmp(cpr_stgfn, "") != 0))
        {
        _pdm_debug("storage filename <%s> is a duplicate", cpr_stgfn);
        return(PDM_E_DUPLICATE_FILENAME);
        }
      current = current->next;
      }
    }

  temp = NULL;
  tail = NULL;
  head = NULL;

  temp = (struct file_info *)malloc(sizeof(struct file_info));
  temp->next = NULL;
  temp->file_desc[0] = '\0';
  temp->local_fn[0] = '\0';
  temp->storage_fn[0] = '\0';
  temp->file_type[0] = '\0';
  temp->mode = 0;

  strcpy((temp->file_desc), cpr_desc);
  strcpy((temp->local_fn), cpr_localfn);
  strcpy((temp->storage_fn), cpr_stgfn);
  strcpy((temp->file_type), cpr_type);

  temp->mode = ir_mode;

  if (*spm_file_list)
    {
    tail = *spm_file_list;
    while (tail)
      {
      head = tail;
      tail = tail->next;
      }
    head->next = temp;
    }
  else
    *spm_file_list = temp;

  if ((*spm_file_list) && (PDM_debug_on))
    PDUprint_file_list(*spm_file_list);

  return(status);
}

int PDUloadapi_change_structure(	cpr_desc, 
					cpr_chg_desc, 
					cpr_localfn, 
					cpr_chg_localfn, 
					cpr_stgfn, 
					cpr_chg_stgfn, 
					cpr_type, 
					cpr_chg_type, 
					ir_mode, 
					spm_chg_list)
char   *cpr_desc;
char   *cpr_chg_desc;
char   *cpr_localfn;
char   *cpr_chg_localfn;
char   *cpr_stgfn;
char   *cpr_chg_stgfn;
char   *cpr_type;
char   *cpr_chg_type;
int     ir_mode;
struct chg_file_info **spm_chg_list;
{

  long     status = PDM_S_SUCCESS;
  struct chg_file_info *tail, *temp, *head;
  struct chg_file_info *current = NULL;

  _pdm_debug("in the function PDUloadapi_change_structure", 0);

  ir_mode = 2;

  if (cpr_chg_desc == NULL)
    cpr_chg_desc = NULL_STRING;
  if (cpr_chg_localfn == NULL)
    cpr_chg_localfn = NULL_STRING;
  if (cpr_chg_stgfn == NULL)
    cpr_chg_stgfn = NULL_STRING;
  if (cpr_chg_type == NULL)
    cpr_chg_type = NULL_STRING;

  if (cpr_desc == NULL)
    cpr_desc = NULL_STRING;
  if (cpr_localfn == NULL)
    cpr_localfn = NULL_STRING;
  if (cpr_stgfn == NULL)
    cpr_stgfn = NULL_STRING;
  if (cpr_type == NULL)
    cpr_type = NULL_STRING;

  if ((strcmp(cpr_chg_desc, "") == 0) &&
      (strcmp(cpr_chg_localfn, "") == 0) &&
      (strcmp(cpr_chg_stgfn, "") == 0) &&
      (strcmp(cpr_chg_type, "") == 0))
    return(PDM_E_REQUIRED_DATA);

  else if ((strcmp(cpr_desc, "") == 0) &&
           (strcmp(cpr_localfn, "") == 0) &&
           (strcmp(cpr_stgfn, "") == 0) &&
           (strcmp(cpr_type, "") == 0))
    return(PDM_E_REQUIRED_DATA);

  current = *spm_chg_list;
  if (*spm_chg_list)
    {
    _pdm_debug("checking for duplicate filenames", 0);
    while (current)
      {
      if ((strlen(current->chg_local_fn)) &&
          (strcmp(cpr_chg_localfn, current->chg_local_fn) == 0))
        return(PDM_E_DUPLICATE_FILENAME);
      if ((strlen(current->chg_storage_fn)) &&
          (strcmp(cpr_chg_stgfn, current->chg_storage_fn) == 0))
        return(PDM_E_DUPLICATE_FILENAME);
      current = current->next;
      }
    }

  temp = NULL;
  tail = NULL;
  head = NULL;

  temp = (struct chg_file_info *)malloc(sizeof(struct chg_file_info));
  temp->next = NULL;
  temp->file_desc[0] = '\0';
  temp->chg_file_desc[0] = '\0';
  temp->local_fn[0] = '\0';
  temp->chg_local_fn[0] = '\0';
  temp->storage_fn[0] = '\0';
  temp->chg_storage_fn[0] = '\0';
  temp->file_type[0] = '\0';
  temp->chg_file_type[0] = '\0';
  temp->mode = 0;

  strcpy((temp->file_desc), cpr_desc);
  strcpy((temp->chg_file_desc), cpr_chg_desc);
  strcpy((temp->local_fn), cpr_localfn);
  strcpy((temp->chg_local_fn), cpr_chg_localfn);
  strcpy((temp->storage_fn), cpr_stgfn);
  strcpy((temp->chg_storage_fn), cpr_chg_stgfn);
  strcpy((temp->file_type), cpr_type);
  strcpy((temp->chg_file_type), cpr_chg_type);

  /* mode = 2 for CHANGE */
  temp->mode = 2;

  if (*spm_chg_list)
    {
    tail = *spm_chg_list;
    while (tail)
      {
      head = tail;
      tail = tail->next;
      }
    head->next = temp;
    }
  else
    *spm_chg_list = temp;

  if ((*spm_chg_list) && (PDM_debug_on))
    PDUprint_change_list(*spm_chg_list);

  return(status);
}

int PDUloadapi_attr_structure(	cpr_attrname, 
				cpr_datatype, 
				cpr_synonym, 
				cpr_value, 
				attr_list)
char   *cpr_attrname;
char   *cpr_datatype;
char   *cpr_synonym;
char   *cpr_value;
struct attribute_info **attr_list;
{

  long     status = PDM_S_SUCCESS;
  struct attribute_info *temp, *tail, *head;

  _pdm_debug("in the function PDUloadapi_attr_structure", 0);

  if (cpr_attrname == NULL)
    cpr_attrname = NULL_STRING;
  if (cpr_datatype == NULL)
    cpr_datatype = NULL_STRING;
  if (cpr_synonym == NULL)
    cpr_synonym = NULL_STRING;
  if (cpr_value == NULL)
    cpr_value = NULL_STRING;

  if ((strcmp(cpr_attrname, "") == 0) && (strcmp(cpr_synonym, "") == 0))
      return(PDM_E_REQUIRED_DATA);

  temp = NULL;
  tail = NULL;
  head = NULL;

  _pdm_debug("mallocing space", 0);
  temp = (struct attribute_info *)malloc(sizeof(struct attribute_info));
  temp->next = NULL;
  temp->attr_name[0] = '\0';
  temp->datatype[0] = '\0';
  temp->synonym[0] = '\0';
  temp->value[0] = '\0';

  strcpy((temp->attr_name), cpr_attrname);
  strcpy((temp->datatype), cpr_datatype);
  strcpy((temp->synonym), cpr_synonym);
  strcpy((temp->value), cpr_value);

  _pdm_debug("adding node", 0);
  if (*attr_list)
    {
    tail = *attr_list;
    while (tail)
      {
      head = tail;
      tail = tail->next;
      }
    head->next = temp;
    }
  else
    *attr_list = temp;

  if ((*attr_list) && (PDM_debug_on))
    PDUprint_attr_list(*attr_list);

  return(status);
}


int PDUloadapi_attr_list_from_buffer(attr_bufr, data_bufr, attr_list)
MEMptr      attr_bufr;
MEMptr      data_bufr;
struct attribute_info **attr_list;
{

  long    status = PDM_S_SUCCESS;
  int     name_col = 0;
  int     syn_col = 0;
  int     type_col = 0;
  int     attr_col = -1;
  int     row = 0;
  char    **data_row;
  char    **attr_row;
  struct attribute_info *temp = NULL, *tail = NULL;

  _pdm_debug("in the function PDUloadapi_attr_list_from_buffer", 0);

  if ((attr_bufr == NULL) || (data_bufr == NULL))
    return(PDM_E_NULL_BUFFER);

  _pdm_debug("attr_bufr->rows = %d", (char *) attr_bufr->rows);

  if (attr_bufr->rows == 0)
    return(PDM_E_NULL_BUFFER);

  _pdm_debug("setting up attr_bufr", 0);
  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(attr_bufr, ROW, &data_row);
 
  status = PDUget_buffer_col(attr_bufr, "n_name", &name_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(attr_bufr, "n_synonym", &syn_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(attr_bufr, "n_datatype", &type_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  _pdm_debug("setting up data_bufr", 0);
  status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(data_bufr, ROW, &attr_row);
 
  /* create the beginning node */
  temp = (struct attribute_info *)malloc(sizeof(struct attribute_info));

  *attr_list = temp;
  tail = *attr_list;

  temp->next = NULL;
  temp->attr_name[0] = '\0';
  temp->datatype[0] = '\0';
  temp->synonym[0] = '\0';
  temp->value[0] = '\0';

  row = 0;
  strcpy((temp->attr_name), data_row[(attr_bufr->columns * row) + name_col]);
  strcpy((temp->datatype), data_row[(attr_bufr->columns * row) + type_col]);
  strcpy((temp->synonym), data_row[(attr_bufr->columns * row) + syn_col]);

  _pdm_debug("getting value for <%s>", temp->attr_name);
  attr_col = PDUfind_attr_in_buffer(attr_bufr, temp->attr_name);
  if (attr_col != -1)
    {
    strcpy(temp->value, attr_row[(data_bufr->columns * 0) + attr_col]);
    _pdm_debug("value = <%s>", temp->value);
    }

  _pdm_debug("writing to other nodes", 0);
  for (row = 1; row < attr_bufr->rows; ++row)
     {
     temp = (struct attribute_info *)malloc(sizeof(struct attribute_info));
     temp->next = NULL;
     temp->attr_name[0] = '\0';
     temp->datatype[0] = '\0';
     temp->synonym[0] = '\0';
     temp->value[0] = '\0';

     strcpy((temp->attr_name), data_row[(attr_bufr->columns * row) + name_col]);
     strcpy((temp->datatype), data_row[(attr_bufr->columns * row) + type_col]);
     strcpy((temp->synonym), data_row[(attr_bufr->columns * row) + syn_col]);

     _pdm_debug("getting value for <%s>", temp->attr_name);
     attr_col = PDUfind_attr_in_buffer(attr_bufr, temp->attr_name);
     if (attr_col != -1)
       {
       strcpy(temp->value, attr_row[(attr_bufr->columns * 0) + attr_col]);
       _pdm_debug("value = <%s>", temp->value);
       }

     tail->next = temp;
     tail = temp;
     }

  _pdm_debug("calling print", 0);
  if ((*attr_list) && (PDM_debug_on))
    PDUprint_attr_list(*attr_list);

  return(status);
}

int PDUfree_api_file_structure(file_list)
struct file_info **file_list;
{
  struct file_info * head = NULL;
  long   status = PDM_S_SUCCESS;

  if (*file_list)
    {
    head = *file_list;
    while (*file_list)
      {
      *file_list = (*file_list)->next;
      free(head);
      head = *file_list;
      }
    *file_list = NULL;
    }
  else
    status = PDM_E_NULL_FILE_LIST;
  return(status);
}

int PDUfree_api_change_file_structure(file_list)
struct chg_file_info **file_list;
{
  struct chg_file_info * head = NULL;
  long   status = PDM_S_SUCCESS;

  if (*file_list)
    {
    head = *file_list;
    while (*file_list)
      {
      *file_list = (*file_list)->next;
      free(head);
      head = *file_list;
      }
    *file_list = NULL;
    }
  else
    status = PDM_E_NULL_FILE_LIST;
  return(status);
}

int PDUfree_api_attr_structure(attr_list)
struct attribute_info **attr_list;
{
  struct attribute_info * head = NULL;
  long   status = PDM_S_SUCCESS;

  if (*attr_list)
    {
    head = *attr_list;
    while (*attr_list)
      {
      *attr_list = (*attr_list)->next;
      free(head);
      head = *attr_list;
      }
    *attr_list = NULL;
    }
  else
    status = PDM_E_ATTR_LIST_EMPTY;
  return(status);
}

int PDUfree_api_trans_structure(trans_list)
struct part_transition **trans_list;
{
  struct part_transition * head = NULL;
  long   status = PDM_S_SUCCESS;

  if (*trans_list)
    {
    head = *trans_list;
    while (*trans_list)
      {
      *trans_list = (*trans_list)->next;
      free(head);
      head = *trans_list;
      }
    *trans_list = NULL;
    }
  else
    status = PDM_E_NULL_FILE_LIST;
  return(status);
}

int PDUprint_attr_list(list)
  struct attribute_info   *list;
{
  long   status = PDM_S_SUCCESS;
  FILE  *pdu_debug_file, *fopen();
 
  _pdm_debug("in the function PDUprint_attr_list", 0);

  if (!list)
    {
    _pdm_debug("Attr Structure Linklist is NULL", 0);
    return(PDM_S_SUCCESS);
    }
 
  if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
    {
    printf("Could not open debug file\n");
    return(PDM_E_OPEN_FILE);
    }

  while (list)
    {
    fprintf(pdu_debug_file, "cpr_attr_name  = %s\n", list->attr_name);
    fprintf(pdu_debug_file, "cpr_datatype = %s\n", list->datatype);
    fprintf(pdu_debug_file, "cpr_synonym   = %s\n", list->synonym);
    fprintf(pdu_debug_file, "cpr_value  = %s\n", list->value);
    fprintf(pdu_debug_file, "\n");
    list = list->next;
    }
 
  fclose (pdu_debug_file);
  return(status);
} 

int PDUverify_delete_file_list(cpr_catalog,
			       cpr_partnum,
			       cpr_revision,
			       spr_files)		
char   *cpr_catalog;
char   *cpr_partnum;
char   *cpr_revision;
struct file_info *spr_files;
{
  long   status = PDM_S_SUCCESS;
  MEMptr bufr = NULL;

  _pdm_debug("in the function PDUverify_delete_file_list", 0);

  while(spr_files)
    {
    if (spr_files->mode != DELETE)
      return(PDM_E_INVALID_MODE);

    if ((strlen(spr_files->local_fn) == 0) && 
        (strlen(spr_files->storage_fn) == 0))
      return(PDM_E_NO_DATA_IN_FILE_LIST);

    if (strlen(spr_files->local_fn))
      {
      _pdm_debug("checking to see if file exists", 0);
      status = PDUvalid_filename(cpr_catalog, cpr_partnum, cpr_revision,
                                 spr_files->local_fn);
      _pdm_status("PDUvalid_filename", status);
      if (status != PDM_S_SUCCESS)
        return(status);

      _pdm_debug("checking where used", 0);
      status = PDMrget_imm_parents(cpr_catalog,cpr_partnum,cpr_revision,&bufr);
      _pdm_status("PDMrget_imm_parents", status);
      MEMclose(&bufr);
      if ((status != PDM_E_NO_PARENTS) && (status != SQL_I_NO_ROWS_FOUND))
        return(PDM_I_PART_IN_ASS);
      else
        status = PDM_S_SUCCESS;
      }
      
    spr_files = spr_files->next;
    }

  return(status);
}

int PDUprint_transition_list(trans_list)
  struct part_transition   *trans_list;
{
  long   status = PDM_S_SUCCESS;
  FILE  *pdu_debug_file, *fopen();
 
  _pdm_debug("in the function PDUprint_transition_list", 0);

  if (!trans_list)
    {
    _pdm_debug("Part Transition Linklist is NULL", 0);
    return(PDM_S_SUCCESS);
    }
 
  if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
    {
    printf("Could not open debug file\n");
    return(PDM_E_OPEN_FILE);
    }

  while (trans_list)
    {
    fprintf(pdu_debug_file, "cpr_statename  = %s\n",trans_list->statename);
    fprintf(pdu_debug_file, "cpr_transition = %s\n",trans_list->transition);
    fprintf(pdu_debug_file, "ir_stateno     = %d\n",trans_list->stateno);
    fprintf(pdu_debug_file, "\n");
    trans_list = trans_list->next;
    }
 
  fclose (pdu_debug_file);
  return(status);
} 
