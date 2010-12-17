#include 	"PDUcommand.h"
#include        "PDUerror.h"
#include        "PDUstr.h"
#include        "MEMerrordef.h"
#include        <stdio.h>
#include        <tools.h>
#include        "PDUproto.h"

int PDUvalidate_value(value, datatype)

char *value;
char *datatype;

  {
  int status;
  int length;
  char msg[256];
/* SUN */
  /*char length_str[10] = "";*/
  char length_str[10];


  strcpy(length_str, "");

  _pdm_debug("PDUvalidate_value", 0);
  _pdm_debug("Value to validate = <%s>", value);
  _pdm_debug("Datatype = <%s>", datatype);

  if (!datatype)
    return(PDM_E_DATATYPE);

   if ((strcmp(datatype,"integer") == 0) ||  (strcmp(datatype, "Integer")== 0))
     {
     status = PDUvalid_number(value, "I", msg);
     _pdm_status("PDUvalid_number(I)", status);
     }
   else if ((strcmp(datatype,"real") == 0)  ||  (strcmp(datatype, "Real") == 0))
     {
     status = PDUvalid_number(value, "F", msg);
     _pdm_status("PDUvalid_number(F)", status);
     }
   else if ((strcmp(datatype,"double") == 0)  ||
            (strcmp(datatype, "Double") == 0))
     {
     status = PDUvalid_number(value, "F", msg);
     _pdm_status("PDUvalid_number(F)", status);
     }
   else if ((strcmp(datatype,"decimal") == 0)  ||
            (strcmp(datatype, "Decimal") == 0))
     {
     status = PDUvalid_number(value, "F", msg);
     _pdm_status("PDUvalid_number(F)", status);
     }
   else if ((strcmp(datatype,"smallint") == 0) ||
            (strcmp(datatype, "Smallint") == 0))
     {
     status = PDUvalid_smallint(value, "", msg);
     _pdm_status("PDUvalid_smallint", status);
     }
   else if ((strncmp(datatype,"char",4) == 0)  || 
            (strncmp(datatype, "Char", 4) == 0))
     {
     /* Stan 2/16/92 */
     sscanf(datatype,"char(%d)",&length);
     _pdm_debug("Length = %d",(char *)length);

     sprintf(length_str,"%d",length);

     status = PDUvalid_string(value,length_str, msg);
     _pdm_status("PDUvalid_string", status);
     }
   else if ((strcmp(datatype, "timestamp") == 0) ||
           (strcmp(datatype, "Timestamp") == 0))
     {
     status = PDUvalid_timestamp(value, msg);
     _pdm_status("PDUvalid_timestamp", status);
     }
   else if ((strncmp(datatype, "expression",10) == 0) ||
           (strncmp(datatype, "Expression",10) == 0))
     {
     status = PDM_S_SUCCESS;
     }
   else
     {
     _pdm_debug("Invalid Datatype", 0);
     status = PDM_E_DATATYPE;
     }
  return(status);
  }

int PDUvalidate_dyn_value(attr_name, value, attr_buffer, list_buffer)

char *attr_name;
char *value;
MEMptr attr_buffer;
MEMptr list_buffer;

  {
  int status, i, attr_row;
  char *datatype = NULL;
  char **attr_data = NULL;
  char **list_data = NULL;
  int  buffer_number;
  int  FOUND = FALSE;

  _pdm_debug("In PDUvalidate_dyn_value", 0);

  /* find attr_name in attr_buffer */
  status = MEMbuild_array(attr_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_row = PDUfind_attr_in_buffer(attr_buffer, attr_name);

  if (attr_row == -1)
     return(PDM_E_FAILURE);

  attr_data = (char **)attr_buffer->data_ptr;

  PDUfill_in_string(&datatype, attr_data[(attr_buffer->columns  * attr_row ) +
                    PDU_NFM_DATA_COL]);

  status = PDUvalidate_value(value, datatype);
  _pdm_status("PDUvalidate_value", status);

  if (status != PDM_S_SUCCESS)
    return(status);

   scanf(attr_data[(attr_buffer->columns * attr_row) + PDU_NFM_LISTNO_COL], 
         "%d", &buffer_number); 

   if (buffer_number == 0)
     return(PDM_S_SUCCESS);

   status = MEMreset_buffer_no(list_buffer, buffer_number);
   _pdm_status("MEMreset_buffer_no", status);

   if (status != MEM_S_SUCCESS)
     return(PDM_E_RESET_BUFFER);

   list_data = (char **)list_buffer->data_ptr;

   for (i = 0; i < list_buffer->rows; i++)
      if (strcmp(value, list_data[i]) == 0)
        {
        _pdm_debug("value found in assosciated list", 0);
        FOUND = TRUE;
        break;
        }

    if (FOUND)
      status = PDM_S_SUCCESS;
    else
      status = PDM_E_INVALID_INPUT;

  return(status);
  }

int PDUcheck_if_change_toggles(attr_name)

char *attr_name;

{
int status;

_pdm_debug("In the function PDUcheck_if_change_toggles", 0);

if ((strncmp(attr_name, "p_", 2) == 0) || (strncmp(attr_name, "n_", 2) == 0))
  if (strcmp(attr_name, "n_itemdesc") != 0)
    if (strcmp(attr_name, "n_aclno") != 0)
        if (strcmp(attr_name, "n_filetype") != 0)
          if (strcmp(attr_name, "n_cifilename") != 0)
              if (strcmp(attr_name, "n_cocomment") != 0)
                if (strcmp(attr_name, "n_cosano") != 0)
                  if (strcmp(attr_name, "n_cofilename") != 0)
                    if (strcmp(attr_name, "p_explode") != 0)
                      if (strcmp(attr_name, "p_maxlevel") != 0)
                        if (strcmp(attr_name, "p_parttype") != 0)
                            if (strcmp(attr_name, "p_mrpbomuom") != 0)
                            if (strcmp(attr_name, "p_mrpeffectdate") != 0)
                            if (strcmp(attr_name, "p_mrpinvuom") != 0)
                            if (strcmp(attr_name, "p_filedesc") != 0)
                            if (strcmp(attr_name, "n_iconname") != 0)
                            if (strcmp(attr_name, "n_lgfiletype") != 0)
                            if (strcmp(attr_name, "n_lgfiletype") != 0)
                              if (strcmp(attr_name, "n_iconno") != 0)
                                status = PDM_E_FAILURE;
                              else
                                status = PDM_S_SUCCESS;
                            else
                              status = PDM_S_SUCCESS;
                            else
                              status = PDM_S_SUCCESS;
                            else
                              status = PDM_S_SUCCESS;
                            else
                              status = PDM_S_SUCCESS;
                            else
                              status = PDM_S_SUCCESS;
                          else
                            status = PDM_S_SUCCESS;
                        else
                          status = PDM_S_SUCCESS;
                      else
                        status = PDM_S_SUCCESS;
                    else
                      status = PDM_S_SUCCESS;
                  else
                    status = PDM_S_SUCCESS;
                else
                  status = PDM_S_SUCCESS;
              else
                status = PDM_S_SUCCESS;
            else
              status = PDM_S_SUCCESS;
      else 
        status = PDM_S_SUCCESS;
    else 
      status = PDM_S_SUCCESS;
  else
    status = PDM_S_SUCCESS;
else 
  status = PDM_S_SUCCESS;
else 
  status = PDM_S_SUCCESS;

return(status);
}

int PDUcheck_if_change_datatype(attr_name)

char *attr_name;

{
int status;

_pdm_debug("In the function PDUcheck_if_change_datatype", 0);

if ((strncmp(attr_name, "p_", 2) == 0) || (strncmp(attr_name, "n_", 2) == 0))
  {
  if (strcmp(attr_name, "n_setindicator") == 0)
    status = PDM_E_FAILURE;
  else if (strcmp(attr_name, "n_status") == 0)
    status = PDM_E_FAILURE;
  else if (strcmp(attr_name, "n_pendingflag") == 0)
    status = PDM_E_FAILURE;
  else if (strcmp(attr_name, "n_itemlock") == 0)
    status = PDM_E_FAILURE;
  else if (strcmp(attr_name, "n_archivestate") == 0)
    status = PDM_E_FAILURE;
  else if (strcmp(attr_name, "p_explode") == 0)
    status = PDM_E_FAILURE;
  else if (strcmp(attr_name, "p_parttype") == 0)
    status = PDM_E_FAILURE;
  else if (strcmp(attr_name, "p_incpartrpt") == 0)
    status = PDM_E_FAILURE;
  else if (strncmp(attr_name, "p_mrp",5) == 0)
    status = PDM_E_FAILURE;
  else if (strcmp(attr_name, "n_filetype") == 0)
    status = PDM_E_FAILURE;
  else if (strcmp(attr_name, "n_fileclass") == 0)
    status = PDM_E_FAILURE;
  else if (strcmp(attr_name, "n_restoreflag") == 0)
    status = PDM_E_FAILURE;
  else if (strcmp(attr_name, "n_fileco") == 0)
    status = PDM_E_FAILURE;
  else if (strcmp(attr_name, "n_convertind") == 0)
    status = PDM_E_FAILURE;
  else 
    status = PDM_S_SUCCESS;
  }
  else
    status = PDM_S_SUCCESS;

  return(status);
}
