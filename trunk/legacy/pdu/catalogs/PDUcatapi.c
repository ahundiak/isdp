#include        <stdio.h>
#include        <FI.h>
#include        <PDUstr.h>
#include        <PDUuser.h>
#include        <PDUstorage.h>
#include        <PDUerror.h>
#include        <PDMtypes.h>
#include        <PDUforms.h>
#include        <PDUprompt.h>
#include        <PDUcommand.h>
#include        <PDUfile_def.h>
#include        <PDUparamdef.h>
#include        <part_gadgets.h>
#include        <MEMerrordef.h>
#include        <PDMmessage.h>
#include        <PDUproto.h>
#include        <PDMproto.h>

extern char *PDU_cat_atr;
extern char *PDU_cat_data;
extern char *PDU_cat_list;
extern char *PDU_dyn_attr;
extern char *PDU_dyn_data;
extern int  PDM_debug_on;

int PDUcheck_for_reserved_words(string)

char *string;

  {
  int status;

  _pdm_debug("In PDUcheck_for_reserved_words",0);

  if ((strcmp(string, "accept") == 0) || (strcmp(string, "arch") == 0) ||
      (strcmp(string, "area") == 0) || (strcmp(string, "auto") == 0) ||
      (strcmp(string, "black") == 0) || (strcmp(string, "border") == 0) ||
      (strcmp(string, "code") == 0) || (strcmp(string, "color") == 0) ||
      (strcmp(string, "colors") == 0) || (strcmp(string, "connect") == 0))
    status = PDM_E_FAILURE;
  else if ((strcmp(string, "constraint") == 0) || (strcmp(string, "constraints")
  == 0) || (strcmp(string, "construct") == 0) || (strcmp(string, "count") == 0)
        || (strcmp(string, "cycle") == 0) || (strcmp(string,"description") == 0)
        || (strcmp(string, "fill") == 0) || (strcmp(string, "finish") == 0) ||
           (strcmp(string, "flush") == 0) || (strcmp(string, "force") == 0))
     status = PDM_E_FAILURE;
 else if ((strcmp(string,"granularity") == 0) || (strcmp(string,"graphic") == 0)
       || (strcmp(string, "growth") == 0) || (strcmp(string, "inuse") == 0) ||
          (strcmp(string, "len") == 0) || (strcmp(string, "length") == 0) ||
          (strcmp(string, "level") == 0) || (strcmp(string, "lower") == 0) ||
          (strcmp(string, "numparts") == 0) || (strcmp(string, "off") == 0))
     status = PDM_E_FAILURE;
  else if ((strcmp(string, "offset") == 0) || (strcmp(string, "optimize") == 0)
        || (strcmp(string, "option") == 0) || (strcmp(string, "options") == 0)
        || (strcmp(string, "order") == 0) || (strcmp(string, "package") == 0)
        || (strcmp(string, "packed") == 0) || (strcmp(string, "part") == 0)
        || (strcmp(string,"permanent") == 0) || (strcmp(string,"picture") == 0))
     status = PDM_E_FAILURE;
  else if ((strcmp(string, "pipe") == 0) || (strcmp(string, "place") == 0) ||
           (strcmp(string, "placement") == 0) || (strcmp(string,"plan") == 0) ||
           (strcmp(string,"position") == 0) || (strcmp(string,"positive") == 0) 
        || (strcmp(string,"post") == 0) || (strcmp(string, "precision") == 0) ||
           (strcmp(string, "primary") == 0) || (strcmp(string, "prior") == 0))
     status = PDM_E_FAILURE;
  else if ((strcmp(string, "private") == 0) || (strcmp(string,"procedure") == 0)
        || (strcmp(string,"protection") == 0) || (strcmp(string,"raise") == 0) 
        || (strcmp(string,"range") == 0) || (strcmp(string,"raw") == 0) ||
           (strcmp(string,"ready") == 0) || (strcmp(string, "release") == 0) ||
           (strcmp(string, "remote") == 0) || (strcmp(string, "repair") == 0))
     status = PDM_E_FAILURE;
  else if ((strcmp(string, "require") == 0) || (strcmp(string,"required") == 0)
        || (strcmp(string,"resource") == 0) || (strcmp(string,"restrict") == 0) 
        || (strcmp(string,"scale") == 0) || (strcmp(string,"schedule") == 0) ||
           (strcmp(string,"ready") == 0) || (strcmp(string, "release") == 0) ||
           (strcmp(string, "section") == 0) || (strcmp(string, "segment") == 0))
     status = PDM_E_FAILURE;
  else if ((strcmp(string, "shift") == 0) || (strcmp(string,"size") == 0) ||
         (strcmp(string,"specification") == 0) || (strcmp(string,"status") == 0)
        || (strcmp(string,"storage") == 0) || (strcmp(string,"time") == 0) ||
           (strcmp(string,"total") == 0) || (strcmp(string, "trim") == 0) ||
           (strcmp(string, "units") == 0) || (strcmp(string, "use") == 0))
     status = PDM_E_FAILURE;
  else if ((strcmp(string, "used") == 0) || (strcmp(string,"user") == 0) ||
           (strcmp(string,"users") == 0) || (strcmp(string,"using") == 0) ||
           (strcmp(string,"verify") == 0) || (strcmp(string,"view") == 0) ||
           (strcmp(string,"views") == 0) || (strcmp(string, "volumes") == 0) ||
           (strcmp(string, "window") == 0) || (strcmp(string, "mount") == 0) ||
           (strcmp(string, "number") == 0))
     status = PDM_E_FAILURE;
  else if ((strcmp(string, "version") == 0) || 
           (strcmp(string, "versions") == 0) || (strcmp(string, "temp") == 0) ||
           (strcmp(string, "next") == 0) || (strcmp(string, "test") == 0))
     status = PDM_E_FAILURE;
  else
    status = PDM_S_SUCCESS;

  return(status);
  }

void PDUprepare_load_attribute_structure(status, attribute, datatype,synonym,
                                        value,attr_list)

int *status;
char *attribute;
char *datatype;
char *synonym;
char *value;
struct PDUattribute_info **attr_list;

  {
  struct PDUattribute_info *temp = NULL;
  struct PDUattribute_info *tail = NULL;

  _pdm_debug("in the function PDUprepare_load_attribute_structure", 0);

  temp = (struct PDUattribute_info *)malloc(sizeof(struct PDUattribute_info));
  temp->attr_name = NULL;
  temp->datatype = NULL;
  temp->synonym = NULL;
  temp->value = NULL;
  temp->next = NULL;

  if ((attribute) && (strcmp(attribute, "") != 0))
    PDUfill_in_string(&temp->attr_name, attribute);
  else
    PDUfill_in_string(&temp->attr_name, "");

  if ((datatype) && (strcmp(datatype, "") != 0))
    PDUfill_in_string(&temp->datatype, datatype);
  else
    PDUfill_in_string(&temp->datatype, "");

  if ((synonym) && (strcmp(synonym, "") != 0))
    PDUfill_in_string(&temp->synonym, synonym);
  else
    PDUfill_in_string(&temp->synonym, "");

  if ((value) && (strcmp(value, "") != 0))
    PDUfill_in_string(&temp->value, value);
  else
    PDUfill_in_string(&temp->value, "");

  _pdm_debug("temp->attr_name = <%s>", temp->attr_name);
  _pdm_debug("temp->datatype = <%s>", temp->datatype);
  _pdm_debug("temp->synonym = <%s>", temp->synonym);
  _pdm_debug("temp->value = <%s>", temp->value);

  _pdm_debug("check to see if attr_list is NULL", 0);
  if (!(*attr_list))
    {
    _pdm_debug("attr_list is NULL; writing first node", 0);
    *attr_list = temp;
    }
  else
    {
    _pdm_debug("attr_list is not NULL", 0);
    tail = *attr_list;
    while (tail)
      {
      if (!tail->next)  /* last node in list */
        {
        _pdm_debug("found last node in list", 0);
        tail->next = temp;
	tail = tail->next;
        break;
        }
      _pdm_debug("moving to next node", 0);
      tail = tail->next;
      }
    }

  if (PDM_debug_on)
    PDUprint_PDUattr_list(*attr_list);

  *status = PDM_S_SUCCESS;
  return;
  }

void PDUprepare_free_attribute_structure(status,
                                         attr_list)

int *status;
struct PDUattribute_info **attr_list;

  {
  struct PDUattribute_info *head = NULL;

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

  *status = PDM_S_SUCCESS;
  return;
  }

int PDUadd_static_attributes(attr)

struct PDUattribute_info *attr;

  {
  struct PDUattribute_info *head = NULL;
  char *row = NULL;
  char msg[80];
  MEMptr attr_bufr = NULL;
  MEMptr data_bufr = NULL;
  int status;
  int attr_row;

  _pdm_debug("PDUadd_static_attributes", 0);

  attr_bufr = (MEMptr)PDU_cat_atr;
  data_bufr = (MEMptr)PDU_cat_data;
  head = attr;

  row = (char *)malloc(attr_bufr->row_size);

  while (head)
     {
     if (head->attr_name == NULL)
       return(PDM_E_ATTR_NOT_FOUND);
     else if (strcmp(head->attr_name, "") == 0)
       return(PDM_E_ATTR_NOT_FOUND);
     else
       {
       /* validate attribute name */
       MEMbuild_array(attr_bufr);
       attr_row = PDUfind_attr_in_buffer(attr_bufr, head->attr_name);
       if (attr_row != -1)
         return(PDM_E_ATTR_EXISTS);
       status = PDUvalid_attr(head->attr_name,"",msg);
       _pdm_status("PDUvalid_attr", status);
       if (status != PDM_S_SUCCESS)
         return(PDM_E_INVALID_ATTR);
       status = PDUcheck_for_reserved_words(head->attr_name);
       _pdm_status("PDUcheck_for_reserved_words", status);
       if (status != PDM_S_SUCCESS)
         return(PDM_E_RESERVED_ATTR);
       }
     if (head->datatype == NULL)
       return(PDM_E_DATATYPE);
     else if (strcmp(head->datatype, "") == 0)
       return(PDM_E_DATATYPE);
     else
       {
       /* validate a dataype */
       status = PDUvalid_datatype(head->datatype, "", msg);
       _pdm_status("PDUvalid_datatype", status);
       if (status != PDM_S_SUCCESS)
         return(PDM_E_INVALID_DATATYPE);
       }
     memset(row,NULL, attr_bufr->row_size);
     if ((head->synonym) && (strcmp(head->synonym, "") != 0))
       sprintf(row,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1%s\1",
       head->attr_name,head->datatype,head->synonym,"PDM","Y","Y","Y","Y","N",
       (attr_bufr->rows + 1),"0","0");
     else
       sprintf(row,
       "%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1%s\1",
       head->attr_name,head->datatype,"PDM","Y","Y","Y","Y","N",
       (attr_bufr->rows + 1),"0","0");
     status = MEMwrite(attr_bufr, row);
     _pdm_status("MEMwrite", status);

     if (status != MEM_S_SUCCESS)
       return(PDM_E_WRITE_BUFFER);

     head = head->next;
     }

  status = PDUupdate_data_buffer(&data_bufr, attr_bufr);
  _pdm_status("PDUupdate_data_bufr", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  if (row)
    free(row);

  PDU_cat_atr = (char *)attr_bufr;
  PDU_cat_data = (char *)data_bufr;
  return(PDM_S_SUCCESS);
  }

int PDUadd_dynamic_attributes(attr)

struct PDUattribute_info *attr;

  {
  struct PDUattribute_info *head = NULL;
  char *row = NULL;
  char msg[80];
  MEMptr attr_bufr = NULL;
  MEMptr data_bufr = NULL;
  int status;
  int attr_row;

  _pdm_debug("In PDUadd_dynamic_attributes", 0);

  attr_bufr = (MEMptr)PDU_dyn_attr;
  data_bufr = (MEMptr)PDU_dyn_data;

  if (attr_bufr == NULL)
    {
    _pdm_debug("format dynamic attribute buffer", 0);
    status = PDUcreate_dynamic_attr_buffr(&attr_bufr);
    _pdm_status("PDUcreate_dynamic_attr_buffr", status);
    if (status != PDM_S_SUCCESS)
      return(status);
    row = (char *)malloc(attr_bufr->row_size);
    memset(row,NULL, attr_bufr->row_size);
    sprintf(row,
        "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
    "p_pdcno","integer","Pdc No","PDM","N","N","N","N","N","1","0","0");
    status = MEMwrite(attr_bufr, row);
    _pdm_status("MEMwrite", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
    free(row);
    }

  head = attr;

  row = (char *)malloc(attr_bufr->row_size);

  while (head)
     {
     if (head->attr_name == NULL)
       return(PDM_E_ATTR_NOT_FOUND);
     else if (strcmp(head->attr_name, "") == 0)
       return(PDM_E_ATTR_NOT_FOUND);
     else
       {
       /* validate attribute name */
       MEMbuild_array(attr_bufr);
       attr_row = PDUfind_attr_in_buffer(attr_bufr, head->attr_name);
       if (attr_row != -1)
         return(PDM_E_ATTR_EXISTS);
       status = PDUvalid_attr(head->attr_name,"",msg);
       _pdm_status("PDUvalid_attr", status);
       if (status != PDM_S_SUCCESS)
         return(PDM_E_INVALID_ATTR);
       status = PDUcheck_for_reserved_words(head->attr_name);
       _pdm_status("PDUcheck_for_reserved_words", status);
       if (status != PDM_S_SUCCESS)
         return(PDM_E_RESERVED_ATTR);
       }
     if (head->datatype == NULL)
       return(PDM_E_DATATYPE);
     else if (strcmp(head->datatype, "") == 0)
       return(PDM_E_DATATYPE);
     else
       {
       /* validate a dataype */
       status = PDUvalid_datatype(head->datatype, "", msg);
       _pdm_status("PDUvalid_datatype", status);
       if (status != PDM_S_SUCCESS)
         return(PDM_E_INVALID_DATATYPE);
       }
     memset(row,NULL, attr_bufr->row_size);
     if ((head->synonym) && (strcmp(head->synonym, "") != 0))
       sprintf(row,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1%1",
       head->attr_name,head->datatype,head->synonym,"PDM","Y","Y","Y","Y","N",
       (attr_bufr->rows + 1),"0");
     else
       sprintf(row,
       "%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1\1",
       head->attr_name,head->datatype,"PDM","Y","Y","Y","Y","N",
       (attr_bufr->rows + 1),"0");
     status = MEMwrite(attr_bufr, row);
     _pdm_status("MEMwrite", status);

     if (status != MEM_S_SUCCESS)
       return(PDM_E_WRITE_BUFFER);

     head = head->next;
     }

  status = PDUupdate_data_buffer(&data_bufr, attr_bufr);
  _pdm_status("PDUupdate_data_bufr", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  if (row)
    free(row);

  PDU_dyn_attr = (char *)attr_bufr;
  PDU_dyn_data = (char *)data_bufr;
  return(PDM_S_SUCCESS);
  }

int PDUmadd_attribute_defaults()

  {
  MEMptr cat_attr = NULL;
  MEMptr cat_data = NULL;
  int   acl_no;
  int   attr_row = -1;
  int   status;

    _pdm_debug("PDUm_add_attribute_defaults", 0);
    cat_attr = (MEMptr)PDU_cat_atr;
    cat_data = (MEMptr)PDU_cat_data;

    acl_no = 4;
    MEMbuild_array(cat_attr);
    MEMbuild_array(cat_data);
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_NFM_ACL_NO);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "6", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }

  /* default parttype to G */
  attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_PARTTYPE_ATTR);
  if (attr_row != -1)
   {
   status = MEMwrite_data(cat_data, "G", 1, (attr_row + 1));
   _pdm_status("MEMwrite_data", status);
    }

  /* default version limit to 1 */
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_NFM_VERSIONLIMIT);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "1", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }

  /* default explode in bom to Y */
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_EXPLODE_ATTR);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "Y", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }

  /* default max level of explosion to 50 */
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_MAXLEVEL_ATTR);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "50", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }

  /* default include part in summary */
    attr_row = PDUfind_attr_in_buffer(cat_attr, "p_incpartrpt");
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "Y", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }

  /* default input required column to yes for p_partnum and p_revision */
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_PARTID_ATTR);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_attr, "Y", (attr_row + 1),
                             (PDU_NFM_REQ_COL + 1));
      _pdm_status("MEMwrite_data", status);
      }

    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_REVISION_ATTR);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_attr, "Y", (attr_row + 1),
                             (PDU_NFM_REQ_COL + 1));
      _pdm_status("MEMwrite_data", status);
      }

    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_NFM_COCMT);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_attr, "N", (attr_row + 1),
                             (PDU_NFM_WRITE_COL + 1));
      _pdm_status("MEMwrite_data", status);
      }
  PDU_cat_atr = (char *)cat_attr;
  PDU_cat_data = (char *)cat_data;
  return(PDM_S_SUCCESS);
  }
