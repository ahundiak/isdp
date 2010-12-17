#include        <PDUstr.h>
#include        <PDUerror.h>
#include        <PDUextdef.h>
#include        <PDUcommand.h>
#include        <PDMtypes.h>
#include        <PDUuser.h>
#include        <MEMerrordef.h>
#include        <MRPstr.h>
#include        <rMRPstr.h>
#include        <PSUgadlabs.h>
#include        <MRPmessage.h>
#include        <MRPmacros.h>
#include        <PDUrptdef.h>
#include        <PDUproto.h>

extern struct PSUrpt *PDU_pdurpt;
extern struct PDUuser *user;
extern char *PDU_delete_reports;

int PDUload_PSUattr_struct(attr_struct, attr_bufr,num_rows)

struct PSUattr **attr_struct;
MEMptr attr_bufr;
int    *num_rows;

{
  int status;
  int i,j;
  char **attr_data = NULL;
  
  _pdm_debug("In the function PDUload_PSUattr_struct", 0);

  /* MEMbuild the attribute buffer */
  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_data = (char **)attr_bufr->data_ptr;

  *num_rows = 0;
  for ( i = 0; i < attr_bufr->rows; i++)
    if (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_READ_COL],"Y") == 0)
       {
       *num_rows = *num_rows + 1;
       }

  /* malloc array of structures to be number of rows in attr_bufr */
  *attr_struct = (struct PSUattr *)malloc(*num_rows
                * sizeof(struct PSUattr));

  /* initialize each structure */
  for (i = 0; i < *num_rows; i++) 
    {
    (*attr_struct)[i].name = NULL;
    (*attr_struct)[i].syn = NULL;
    (*attr_struct)[i].datatype = NULL;
    (*attr_struct)[i].width = 0;
    (*attr_struct)[i].flag = 0;
    }

  i = 0;
  for (j = 0; j < attr_bufr->rows; j ++)
    {
   if (strcmp(attr_data[(attr_bufr->columns * j) + PDU_NFM_READ_COL], "Y") == 0)
    {
    PDUfill_in_string(&((*attr_struct)[i].name), 
                      attr_data[(attr_bufr->columns * j) +
                      PDU_NFM_ATTR_COL]);
    if ((attr_data[(attr_bufr->columns * j) + PDU_NFM_SYN_COL]) && 
       (strcmp(attr_data[(attr_bufr->columns * j) + PDU_NFM_SYN_COL], "") != 0))
      PDUfill_in_string(&((*attr_struct)[i].syn), 
                      attr_data[(attr_bufr->columns * j) +
                      PDU_NFM_SYN_COL]);
    else
      PDUfill_in_string(&((*attr_struct)[i].syn), 
                      attr_data[(attr_bufr->columns * j) +
                      PDU_NFM_ATTR_COL]);
    PDUfill_in_string(&((*attr_struct)[i].datatype), 
                      attr_data[(attr_bufr->columns * 
                      j) + PDU_NFM_DATA_COL]);
    MRPcalc_width(attr_data[(attr_bufr->columns * j) + PDU_NFM_DATA_COL],
                  &((*attr_struct)[i].width));
    i = i + 1;
    }
  }
  return(PDM_S_SUCCESS);
  }

int PDUformat_report_buffers(options_bufr, list_bufr)

MEMptr *options_bufr;
MEMptr *list_bufr;

  {
  int status;

  _pdm_debug("In the function PDUformat_report_buffers", 0);

  /* format options buffer */
  status = MEMopen(options_bufr, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(*options_bufr, "table", "char(30)");
  _pdm_status("MEMwrite_format(options_bufr)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*options_bufr, "template_name", "char(20)");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*options_bufr, "description", "char(50)");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*options_bufr, "output", "char(50)");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*options_bufr, "title", "char(50)");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*options_bufr, "subtotals", "integer");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*options_bufr, "totals", "integer");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*options_bufr, "width", "integer");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*options_bufr, "lines", "integer");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  /*status = MEMwrite_format(*options_bufr, "p_justification", "char(200)");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);*/

  /* format list buffer */
  status = MEMopen(list_bufr, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(*list_bufr, "name", "char(18)");
  _pdm_status("MEMwrite_format(options_bufr)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*list_bufr, "header", "char(30)");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*list_bufr, "type", "integer");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*list_bufr, "start", "integer");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*list_bufr, "length", "integer");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*list_bufr, "decimal", "integer");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*list_bufr, "sort", "integer");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*list_bufr, "subtotal", "integer");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*list_bufr, "total", "integer");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*list_bufr, "p_justification", "integer");
  _pdm_status("MEMwrite_format(rpt_bufr)", status);
   
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  return(PDM_S_SUCCESS);
  }


int PDUfrom_bufrs_to_structures(options_buffer, list_buffer)

  MEMptr options_buffer;
  MEMptr list_buffer;

  {
  int status;
  char **options_data = NULL;
  char **list_data = NULL;
  int i;
  int temp = 0;

  _pdm_debug("In the function PDUfrom_bufrs_to_structures",0);

  status = MEMbuild_array(options_buffer);
  _pdm_status("MEMbuild_array(options_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = MEMbuild_array(list_buffer);
  _pdm_status("MEMbuild_array(list_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  options_data = (char **)options_buffer->data_ptr;

  /* load info from option buffer into PDU_pdurpt */
  if ((options_data[PDU_PSU_TABLE_COL] != NULL) &&
      (strcmp(options_data[PDU_PSU_TABLE_COL], "") != 0))
    strcpy((PDU_pdurpt->options).table, options_data[PDU_PSU_TABLE_COL]);

  if ((options_data[PDU_PSU_TMPNAME_COL] != NULL) &&
      (strcmp(options_data[PDU_PSU_TMPNAME_COL], "") != 0))

    strcpy((PDU_pdurpt->options).template_name, options_data[PDU_PSU_TMPNAME_COL]);
  
  if ((options_data[PDU_PSU_DESCR_COL] != NULL) &&
      (strcmp(options_data[PDU_PSU_DESCR_COL], "") != 0))
    strcpy((PDU_pdurpt->options).description, options_data[PDU_PSU_DESCR_COL]);
  
  if ((options_data[PDU_PSU_OUTPUT_COL] != NULL) &&
      (strcmp(options_data[PDU_PSU_OUTPUT_COL], "") != 0))
    strcpy((PDU_pdurpt->options).output, options_data[PDU_PSU_OUTPUT_COL]);
  
  if ((options_data[PDU_PSU_TITLE_COL] != NULL) &&
      (strcmp(options_data[PDU_PSU_TITLE_COL], "") != 0))
    strcpy((PDU_pdurpt->options).title, options_data[PDU_PSU_TITLE_COL]);
  
  if ((options_data[PDU_PSU_OPT_SUBTOTL_COL] != NULL) &&
      (strcmp(options_data[PDU_PSU_OPT_SUBTOTL_COL], "") != 0))
    {
    /* load subtotal into structure */
    sscanf(options_data[PDU_PSU_OPT_SUBTOTL_COL], "%d", &temp);
    (PDU_pdurpt->options).subtotals = temp;
    }

  if ((options_data[PDU_PSU_OPT_TOTAL_COL] != NULL) &&
      (strcmp(options_data[PDU_PSU_OPT_TOTAL_COL], "") != 0))
    {
    /* load total into structure */
    sscanf(options_data[PDU_PSU_OPT_TOTAL_COL], "%d", &temp);
    (PDU_pdurpt->options).totals = temp;
    }

  if ((options_data[PDU_PSU_WIDTH_COL] != NULL) &&
      (strcmp(options_data[PDU_PSU_WIDTH_COL], "") != 0))
    {
    /* load total into structure */
    sscanf(options_data[PDU_PSU_WIDTH_COL], "%d", &temp);
    (PDU_pdurpt->options).width = temp;
    }

  if ((options_data[PDU_PSU_LINES_COL] != NULL) &&
      (strcmp(options_data[PDU_PSU_LINES_COL], "") != 0))
    {
    /* load total into structure */
    sscanf(options_data[PDU_PSU_LINES_COL], "%d", &temp);
    (PDU_pdurpt->options).lines = temp;
    }

  /*if ((options_data[PDU_PSU_JUSTIFICATION] != NULL) &&
      (strcmp(options_data[PDU_PSU_JUSTIFICATION], "") != 0))
    {*/
    /* load total into structure */
    /*PDU_pdurpt->justification = (int *) malloc (PDU_pdurpt->list_total * sizeof(int));
    PDUfill_in_string(&justification, options_data[PDU_PSU_JUSTIFICATION]);
    for (i = 0; i < PDU_pdurpt->list_total; i++)
       PDU_pdurpt->justification[i] = justification[i];
    }*/

  /* malloc structure according to rows in the list buffer */
  PDU_pdurpt->list = (struct dba_default_list *)malloc(list_buffer->rows
                * sizeof(struct dba_default_list));

  PDU_pdurpt->justification = (int *) malloc (list_buffer->rows * sizeof(int));
  /* load info from list buffer into PDU_pdurpt */

  PDU_pdurpt->list_total = list_buffer->rows;
  for (i = 0; i < list_buffer->rows; i++)
  {
  list_data = (char **)list_buffer->data_ptr;
  strcpy((PDU_pdurpt->list[i]).name, "");
  if ((list_data[(list_buffer->columns * i) + PDU_PSU_COLNAME_COL] != NULL) &&
      (strcmp(list_data[(list_buffer->columns * i) + PDU_PSU_COLNAME_COL], "")
       != 0))
    strcpy((PDU_pdurpt->list[i]).name, list_data[(list_buffer->columns * i) +
            PDU_PSU_COLNAME_COL]);

  strcpy((PDU_pdurpt->list[i]).header, "");
  if ((list_data[(list_buffer->columns * i) + PDU_PSU_HEADER_COL] != NULL) &&
      (strcmp(list_data[(list_buffer->columns * i) + PDU_PSU_HEADER_COL], "")
      != 0))
    strcpy((PDU_pdurpt->list[i]).header, list_data[(list_buffer->columns * i ) +
           PDU_PSU_HEADER_COL]);

  (PDU_pdurpt->list[i]).type = DBA_COLUMN;
  if ((list_data[(list_buffer->columns * i) + PDU_PSU_COL_TYPE_COL] != NULL) &&
      (strcmp(list_data[(list_buffer->columns * i) + PDU_PSU_COL_TYPE_COL], "")
      != 0))
    {
    /* load total into structure */
    sscanf(list_data[(list_buffer->columns * i) + PDU_PSU_COL_TYPE_COL], "%d", 
           &temp);
    (PDU_pdurpt->list[i]).type = temp;
    }

  (PDU_pdurpt->list[i]).start = 0;
  if ((list_data[(list_buffer->columns * i) + PDU_PSU_START_COL] != NULL) &&
      (strcmp(list_data[(list_buffer->columns * i) + PDU_PSU_START_COL], "")
      != 0))
    {
    /* load total into structure */
    sscanf(list_data[(list_buffer->columns * i) + PDU_PSU_START_COL], "%d", 
           &temp);
    (PDU_pdurpt->list[i]).start = temp;
    }

  (PDU_pdurpt->list[i]).length = 0;
  if ((list_data[(list_buffer->columns * i) + PDU_PSU_LENGTH_COL] != NULL) &&
      (strcmp(list_data[(list_buffer->columns * i) + PDU_PSU_LENGTH_COL], "")
      != 0))
    {
    /* load total into structure */
    sscanf(list_data[(list_buffer->columns * i) + PDU_PSU_LENGTH_COL], "%d", 
           &temp);
    (PDU_pdurpt->list[i]).length = temp;
    }

  (PDU_pdurpt->list[i]).decimal = 1;
  if ((list_data[(list_buffer->columns * i) + PDU_PSU_DECIMAL_COL] != NULL) &&
      (strcmp(list_data[(list_buffer->columns * i) + PDU_PSU_DECIMAL_COL], "")
      != 0))
    {
    /* load total into structure */
    sscanf(list_data[(list_buffer->columns * i) + PDU_PSU_DECIMAL_COL], "%d", 
           &temp);
    (PDU_pdurpt->list[i]).decimal = temp;
    }

  (PDU_pdurpt->list[i]).sort = 0;
  if ((list_data[(list_buffer->columns * i) + PDU_PSU_SORT_COL] != NULL) &&
      (strcmp(list_data[(list_buffer->columns * i) + PDU_PSU_SORT_COL], "")
      != 0))
    {
    /* load total into structure */
    sscanf(list_data[(list_buffer->columns * i) + PDU_PSU_SORT_COL], "%d", 
           &temp);
    (PDU_pdurpt->list[i]).sort = temp;
    }

  (PDU_pdurpt->list[i]).subtotal = 0;
  if ((list_data[(list_buffer->columns * i) + PDU_PSU_COL_SUBTOTL_COL] 
      != NULL) &&
      (strcmp(list_data[(list_buffer->columns * i) + PDU_PSU_COL_SUBTOTL_COL], 
      "")!= 0))
    {
    /* load total into structure */
    sscanf(list_data[(list_buffer->columns * i) + PDU_PSU_COL_SUBTOTL_COL], 
           "%d", &temp);
    (PDU_pdurpt->list[i]).subtotal = temp;
    }

  (PDU_pdurpt->list[i]).total = 0;
  if ((list_data[(list_buffer->columns * i) + PDU_PSU_COL_TOTAL_COL] 
      != NULL) &&
      (strcmp(list_data[(list_buffer->columns * i) + PDU_PSU_COL_TOTAL_COL], 
      "")!= 0))
    {
    /* load total into structure */
    sscanf(list_data[(list_buffer->columns * i) + PDU_PSU_COL_TOTAL_COL], 
           "%d", &temp);
    (PDU_pdurpt->list[i]).total = temp;
    }

  if ((list_data[(list_buffer->columns * i) + PDU_PSU_JUSTIFICATION] 
      != NULL) &&
      (strcmp(list_data[(list_buffer->columns * i) + PDU_PSU_JUSTIFICATION], 
      "")!= 0))
    {
    /* load total into structure */
    sscanf(list_data[(list_buffer->columns * i) + PDU_PSU_JUSTIFICATION], 
           "%d", &temp);
    PDU_pdurpt->justification[i] = temp;
    }
  }

  return(PDM_S_SUCCESS);
  }

int PDUfrom_struct_to_buffers(def_op, def_list)

MEMptr *def_op;
MEMptr *def_list;

  {
  int status;
  int i;
  int char_index;
  char *row = NULL;
  char dummy[15];

  _pdm_debug("In the function PDUfrom_struct_to_buffers", 0);
  /*if (PDU_pdurpt->justification != NULL)
  {
  _pdm_debug("justification <%d>", PDU_pdurpt->justification[0]);
  sprintf(justification,"%d", PDU_pdurpt->justification[0]);
  _pdm_debug("listtotal = <%d>", PDU_pdurpt->list_total);
  for ( i = 1; i < PDU_pdurpt->list_total; i++)
    {
    sprintf(temp,"%d", PDU_pdurpt->justification[i]);
    _pdm_debug("justification <%d>", PDU_pdurpt->justification[i]);
    strcat(justification,temp);
    }
  _pdm_debug("justification = <%s>", justification);
  }*/

  /* load info into def_op */ 
  row = (char *)malloc((*def_op)->row_size);
  memset(row, NULL, (*def_op)->row_size);
 /*sprintf(row, "%s\1%s\1%s\1%s\1\1%d\1%d\1%d\1%d\1%s\1", PDU_pdurpt->options.table,
          PDU_pdurpt->options.template_name, PDU_pdurpt->options.description, 
          PDU_pdurpt->options.output, PDU_pdurpt->options.title, 
          PDU_pdurpt->options.subtotals, PDU_pdurpt->options.totals, 
          PDU_pdurpt->options.width, PDU_pdurpt->options.lines, 
          PDU_pdurpt->options.lines,justification);*/
  
  char_index = 0;
  if ((PDU_pdurpt->options.table) && (strcmp(PDU_pdurpt->options.table, "") != 0) && 
      (strlen(PDU_pdurpt->options.table)))
    {
    _pdm_debug("PDU_pdurpt->options.table = <%s>", PDU_pdurpt->options.table);
    PDUadd_buffer_string(row, &char_index, PDU_pdurpt->options.table);
    }
  else
    row[char_index++] = '\1';

  if ((PDU_pdurpt->options.template_name) && 
      (strcmp(PDU_pdurpt->options.template_name, "") != 0) &&
      (strlen(PDU_pdurpt->options.template_name)))
    {
    _pdm_debug("PDU_pdurpt->options.template_name = <%s>", 
                PDU_pdurpt->options.template_name);
    PDUadd_buffer_string(row, &char_index, PDU_pdurpt->options.template_name);
    }
  else
    row[char_index++] = '\1';

  if ((PDU_pdurpt->options.description) && 
      (strcmp(PDU_pdurpt->options.description, "") != 0) && 
      (strlen(PDU_pdurpt->options.description)))
    {
    _pdm_debug("PDU_pdurpt->options.description = <%s>", 
                PDU_pdurpt->options.description);
    PDUadd_buffer_string(row, &char_index, PDU_pdurpt->options.description);
    }
  else
    row[char_index++] = '\1';

  if ((PDU_pdurpt->options.output) && 
      (strcmp(PDU_pdurpt->options.output, "") != 0) && 
      (strlen(PDU_pdurpt->options.output)))
    {
    _pdm_debug("PDU_pdurpt->options.output = <%s>", PDU_pdurpt->options.output);
    PDUadd_buffer_string(row, &char_index, PDU_pdurpt->options.output);
    }
  else
    row[char_index++] = '\1';

  if ((PDU_pdurpt->options.title) && (strcmp(PDU_pdurpt->options.title, "") != 0) &&
      (strlen(PDU_pdurpt->options.title)))
    {
    _pdm_debug("PDU_pdurpt->options.title = <%s>", PDU_pdurpt->options.title);
    PDUadd_buffer_string(row, &char_index, PDU_pdurpt->options.title);
    }
  else
    row[char_index++] = '\1';

  /* SUN - remove pass by address from "dummy" to get rid of warning 
     Mychelle 3/21/92 */
  /*sprintf(&dummy, "%d", PDU_pdurpt->options.subtotals);*/

  sprintf(dummy, "%d", PDU_pdurpt->options.subtotals);
  _pdm_debug("subtotal = <%s>", dummy);
  PDUadd_buffer_string(row, &char_index, dummy);
  _pdm_debug("totals = <%s>", dummy);
  sprintf(dummy, "%d", PDU_pdurpt->options.totals);
  PDUadd_buffer_string(row, &char_index, dummy);
  _pdm_debug("width = <%s>", dummy);
  sprintf(dummy, "%d", PDU_pdurpt->options.width);
  PDUadd_buffer_string(row, &char_index, dummy);
  _pdm_debug("lines = <%s>", dummy);
  sprintf(dummy, "%d", PDU_pdurpt->options.lines);
  PDUadd_buffer_string(row, &char_index, dummy);

  /*if (PDU_pdurpt->justification != NULL) 
    PDUadd_buffer_string(row, &char_index, justification);
  else
    row[char_index++] = '\1';*/

  _pdm_debug("row = <%s>", row);
  status = MEMwrite(*def_op, row);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_ROW);
  free(row);

  /* load info into def_list */
  row = (char *)malloc((*def_list)->row_size);
  
  for (i = 0; i < PDU_pdurpt->list_total; i ++)
   { 
    memset(row, NULL, (*def_list)->row_size);
    sprintf(row, "%s\1%s\1%d\1%d\1%d\1%d\1%d\1%d\1%d\1%d\1", (PDU_pdurpt->list[i]).name,
            (PDU_pdurpt->list[i]).header, (PDU_pdurpt->list[i]).type, 
            (PDU_pdurpt->list[i]).start, (PDU_pdurpt->list[i]).length, 
            (PDU_pdurpt->list[i]).decimal, (PDU_pdurpt->list[i]).sort, 
            (PDU_pdurpt->list[i]).subtotal, (PDU_pdurpt->list[i]).total,
            PDU_pdurpt->justification[i]);
    status = MEMwrite(*def_list, row);
    _pdm_status("MEMwrite", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_ROW);
    }

    if (row)
      free(row);
    status = PDM_S_SUCCESS;

  return(status);
  }

int PDUformat_delete_report_bufr(buffer)

MEMptr *buffer;

  {
  int status;

  _pdm_debug("In the function PDUformat_delete_report_bufr", 0);

  /* format options buffer */
  status = MEMopen(buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(*buffer, "filename", "char(20)");
  _pdm_status("MEMwrite_format(buffers)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  return(PDM_S_SUCCESS);
  }

int PDUdelete_report_locally()

  {
  int status;
  int i;
  char *filename = NULL;
  char **bufr_data = NULL;
  MEMptr buffer = NULL;

  _pdm_debug("PDUdelete_report_locally", 0);

  buffer = (MEMptr)PDU_delete_reports;

  status = MEMbuild_array(buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    {
    if (buffer)
      MEMclose(&buffer);
    PDU_delete_reports = NULL;
    return(PDM_E_BUILD_BUFFER_ARRAY);
    }

   bufr_data = (char **)buffer->data_ptr;

   for (i = 0; i < buffer->rows; i ++)
     {
     filename = (char *)malloc(strlen(user->wrkst_cwd) + (strlen(bufr_data[i]) +
               2));
    memset(filename, NULL, (strlen(user->wrkst_cwd) + (strlen(bufr_data[i]) + 
               2)));
     strcpy(filename, user->wrkst_cwd);
     strcat(filename, "/");
     strcat(filename, bufr_data[i]);
     status = unlink(filename);
     _pdm_status("link status = %d", status);

     if (status == -1)
       _pdm_debug("unlink failed", 0);
     if (filename)
       free(filename);
     }

  if (buffer)
    {
    MEMclose(&buffer);
    PDU_delete_reports = NULL;
    }

  return(PDM_S_SUCCESS);
  }

int PDUformat_bom_map_bufr(buffer)

MEMptr *buffer;

  {
  int status;

  _pdm_debug("In the function PDUformat_bom_map_bufr", 0);

  /* format options buffer */
  status = MEMopen(buffer, PDM_BUFFER_SIZE);
  _pdm_status("MEMopen(buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(*buffer, "p_bomattrno", "integer");
  _pdm_status("MEMwrite_format(buffers)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*buffer, "p_attrname", "char(20)");
  _pdm_status("MEMwrite_format(buffers)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*buffer, "n_catalogno", "integer");
  _pdm_status("MEMwrite_format(buffers)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*buffer, "n_catalogname", "char(20)");
  _pdm_status("MEMwrite_format(buffers)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  status = MEMwrite_format(*buffer, "p_mapattrno", "integer");
  _pdm_status("MEMwrite_format(buffers)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  return(PDM_S_SUCCESS);
  }
