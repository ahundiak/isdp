#include 	<stdio.h>
#include 	"FI.h"
#include 	"PDUstr.h"
#include        "PDUerror.h"
#include        "PDUcommand.h"
#include        "MEMerrordef.h"
#include        "PDUproto.h"

int PDUformat_list_buffer(list_buffer)

MEMptr *list_buffer;	/* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;
  
  _pdm_debug("In PDUformat_list_buffer", 0);
  
  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  /* depending on type format the buffer */

  status = MEMwrite_format(buffer, "n_input", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_minvalue", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_maxvalue", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_value", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_filename", "char(14)");
  _pdm_status("MEMwrite_format(list_buffer)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_type", "char(1)");
  _pdm_status("MEMwrite_format(list_buffer)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_appname", "char(3)");
  _pdm_status("MEMwrite_format(list_buffer)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_apptype", "char(1)");
  _pdm_status("MEMwrite_format(list_buffer)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  *list_buffer = buffer;
  return(PDM_S_SUCCESS);
  }

int PDUfind_attr_by_synonym(synonym, attr_bufr)

char *synonym;
MEMptr attr_bufr;

  {
  int status;
  int i, row = -1;
  char **attr_data = NULL;

  _pdm_debug("In PDUfind_attr_by_synonym", 0);

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_data = (char **)attr_bufr->data_ptr;

  for (i = 0; i < attr_bufr->rows; i++)
    if (strcmp(synonym, attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL])
        == 0)
      {
      row = i;
      break;
      }

  return(row);
  }

int PDUfind_dyn_attr_by_synonym(synonym, attr_bufr)

char *synonym;
MEMptr attr_bufr;

  {
  int status;
  int i, row = -1;
  char **attr_data = NULL;

  _pdm_debug("In PDUfind_dyn_attr_by_synonym", 0);

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_data = (char **)attr_bufr->data_ptr;

  for (i = 0; i < attr_bufr->rows; i++)
    if (strcmp(synonym, attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL])
        == 0)
      {
      row = i;
      break;
      }

  return(row);
  }

int PDUformat_classification_buffer(class_buffer)

MEMptr *class_buffer;    /* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUformat_list_buffer", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "p_classlevel", "integer");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_class", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  *class_buffer = buffer;
  return(PDM_S_SUCCESS);
  }

int PDUformat_cat_class_bufr(no_levels,class_buffer)

int    no_levels;        /* I - number of classification levels */
MEMptr *class_buffer;    /* I/O - formated list buffer according to type */

  {
  int status;
  int i;
  MEMptr buffer = NULL;
  char   row[256];

  _pdm_debug("In PDUformat_cat_class_bufr", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "n_catalogname", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_usageid", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status =  PDM_S_SUCCESS;
  for (i = 0; i < no_levels; i++)
    {
    /* append levels to go 1 to n */
    sprintf(row, "%s%d", "level_", (i + 1));
    status = MEMwrite_format(buffer, row, "char(40)");
    _pdm_status("MEMwrite_format(list_buffer)", status);

     if (status != MEM_S_SUCCESS)
       {
       status = PDM_E_WRITE_FORMAT;
       break;
       }
     else 
       status = PDM_S_SUCCESS;
     }

  *class_buffer = buffer;
  return(status);
  }

int PDUformat_parameter_buffer(parm_buffer)

MEMptr *parm_buffer;    /* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUformat_parameters_buffer", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "n_catalogname", "char(18)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_synonym", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_templatename", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_type", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_iotype", "char(5)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_units", "char(10)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  *parm_buffer = buffer;
  return(PDM_S_SUCCESS);
  }

int PDUformat_macro_buffer(macro_buffer)

MEMptr *macro_buffer;    /* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUformat_macro_buffer", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "n_catalogname", "char(18)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_macrocat", "char(18)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_macropartno", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_macrorev", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_macroname", "char(30)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_rle", "char(14)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  *macro_buffer = buffer;
  return(PDM_S_SUCCESS);
  }

int PDUformat_search_dyntable_bufr(dyntable_bufr)

MEMptr *dyntable_bufr;    /* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUformat_search_dyntable_bufr", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "n_name", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_synonym", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_datatype", "char(15)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  *dyntable_bufr = buffer;
  return(PDM_S_SUCCESS);
}

int PDUformat_delete_part_bufr(new_bufr)

MEMptr *new_bufr;    /* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUformat_delete_part_bufr", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "n_catalogname", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_itemname", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_itemrev", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  *new_bufr = buffer;
  return(PDM_S_SUCCESS);
}

int PDUformat_status_bufr(new_bufr)

MEMptr *new_bufr;    /* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUformat_delete_part_bufr", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "n_itemname", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_itemrev", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_itemdesc", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  *new_bufr = buffer;
  return(PDM_S_SUCCESS);
}

int PDUformat_macro_bufr(new_bufr)

MEMptr *new_bufr;    /* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUformat_macro_bufr", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "n_catalogname", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_macrocat", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_macropartno", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_macrorev", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_macrolib", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  *new_bufr = buffer;
  return(PDM_S_SUCCESS);
}

int PDUformat_macrolib_copy_bufr(new_bufr)

MEMptr *new_bufr;    /* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUformat_macrolib_copy_bufr", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "n_catalogno", "integer");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_itemno", "integer");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_catalogname", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_itemname", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_itemrev", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_cofilename", "char(15)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_action", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  *new_bufr = buffer;
  return(PDM_S_SUCCESS);
}

int PDUformat_os_parts_bufr(new_bufr)

MEMptr *new_bufr;    /* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUformat_os_parts_bufr", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "n_catalogname", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_itemname", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_itemrev", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_quantity", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "p_usageid", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  *new_bufr = buffer;
  return(PDM_S_SUCCESS);
}

int PDUformat_function_bufr(new_bufr)

MEMptr *new_bufr;    /* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUformat_function_bufr", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "n_name", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_filename", "char(14)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_new_filename", "char(14)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  *new_bufr = buffer;
  return(PDM_S_SUCCESS);
}

int PDUformat_catalog_list_bufr(new_bufr)

MEMptr *new_bufr;    /* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUformat_catalog_list_bufr", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "n_name", "char(80)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_catalogdesc", "char(80)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  *new_bufr = buffer;
  return(PDM_S_SUCCESS);
}

int PDUformat_define_support_lib_bufr(new_bufr)

MEMptr *new_bufr;    /* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUformat_define_support_lib_bufr", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "n_catalogname", "char(20)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_itemname", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_itemrev", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_catalogno", "integer");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_itemno", "integer");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  *new_bufr = buffer;
  return(PDM_S_SUCCESS);
}

int PDUformat_update_parm_parts_bufr(new_bufr)

MEMptr *new_bufr;    /* I/O - formated list buffer according to type */

  {
  int status;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUformat_update_parm_parts_bufr", 0);

  status = MEMopen(&buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(buffer, "n_itemname", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(buffer, "n_itemrev", "char(40)");
  _pdm_status("MEMwrite_format(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  *new_bufr = buffer;
  return(PDM_S_SUCCESS);
}
