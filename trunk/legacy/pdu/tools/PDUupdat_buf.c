#include	<stdio.h>
#include	<PDUstr.h>
#include	<MEMerrordef.h>
#include	<PDUerror.h>
#include        <PDUcommand.h>
#include        <PDUproto.h>

extern int PDU_command;

int PDUupdate_data_buffer(data_buffer, attr_buffer)
  MEMptr	*data_buffer;	/* i/o - buffer containing old data for defaults and new user defined attribute defaults and initial values */
  MEMptr	attr_buffer;	/* i - buffer of attributes (default and user defined */

/******************************************************************************

Doc:	PDUupdate_data_buffer

Abstract:
	Create a new data buffer which matches the attribute buffer.

Algorithm:
	.bp
		1.	Build new array of pointers to the modified attribute buffer.
		2.	Open a new data buffer.
		3.	Put the old data buffer column names and formats in the new buffer.
		4.	Put the new attributes and data type in new buffer column names and format information.
		5.	Add the data from the old buffer in the new buffer.
	.ep

Return Status:

	PDM_S_SUCCESS			-	Successful completion
	PDM_E_BUILD_BUFFER_ARRAY	-	Could not build array of pointers to the new attribute buffer
	PDM_E_OPEN_BUFFER		-	Could not open a new buffer
	PDM_E_WRITE_BUFFER		-	Could not write data to the new buffer
	PDM_E_WRITE_FORMAT		-	Could not write the format information to the new buffer

Caveats:

History:

*****************************************************************************/

  {
    int		status = PDM_S_SUCCESS; /* PDM status */
    MEMptr	new_buffer = NULL;	/* new buffer containing new defaults and initials */
    int		row = 0; /* row index for buffer */
    int		col = 0; /* column index for buffer */
    char	*string = NULL; /* string to concatenate the data to put in new buffer */
    int		string_len = 0; /* length of string used to add a row to new buffer */
    int		string_index = 0; /* character index for string */
    char        **data_cols = NULL; /*     added NULL    APOGEE   */
    char	**data_format = NULL; /*   added NULL    APOGEE   */            /* array of pointers to data types of columns in old data buffer */
    char	**data_data = NULL; /*     added NULL    APOGEE   */            /* array of pointers to old default and initial values */
    char	**attr_data; /* array of pointers to default and user defined attributes */
    int         max_col;
    int         max_row;

    _pdm_debug("In the function PDUupdate_data_buffer",0);

    /* construct array of pointers to attribute data */
    status = MEMbuild_array(attr_buffer);
    _pdm_status("MEMbuild_array", status);
    if ( status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    if (*data_buffer)
     {
      status = MEMbuild_array(*data_buffer);
      _pdm_status("MEMbuild_array", status);
      if ( status != MEM_S_SUCCESS)
         return(PDM_E_BUILD_BUFFER_ARRAY);
     }

    /* open the new buffer */
    status = MEMopen(&new_buffer, PDM_BUFFER_SIZE);
    _pdm_status("MEMopen", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_OPEN_BUFFER);

    if (*data_buffer)
     {
      data_cols = (char **)(*data_buffer)->column_ptr;
      data_format = (char **)(*data_buffer)->format_ptr;
      data_data = (char **)(*data_buffer)->data_ptr;
      max_col = (*data_buffer)->columns;
      max_row = (*data_buffer)->rows;
     }
    else

    {
     max_col = 0;
    
     if (attr_buffer->rows == 0)
        max_row = 0;
     else
        max_row = 1;
    }
      attr_data = (char **) attr_buffer->data_ptr;

    /* write the format information from the old buffer to the new buffer */
    for (col=0; col<max_col; ++col)
      {
        status = MEMwrite_format (new_buffer, data_cols[col], data_format[col]);
        _pdm_status("MEMwrite_format",status);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
          
      }

    /* put the attribute name and data types for new attribute in column data */
    for (row=max_col;col<attr_buffer->rows; ++row, ++col)
      {
        status = MEMwrite_format(new_buffer, 
                   attr_data[(attr_buffer->columns * row)+PDU_NFM_ATTR_COL],
                   attr_data[(attr_buffer->columns * row)+PDU_NFM_DATA_COL]);
        _pdm_status("MEMwrite_format",status);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
      }

    string_len = new_buffer->row_size;

    string = (char *)malloc (string_len);

    for (row=0; row < max_row; ++row)
      {
        string_index=0;
        memset(string,NULL, string_len);

	/* copy the old defaults and initials */
       for (col=0; col<max_col; ++col)
           PDUadd_buffer_string(string, &string_index, 
			data_data[(max_col * row) + col]);
       
       /* add the blank values for the user defined attributes */
       for (; col<attr_buffer->rows; ++col)
         string[string_index++] = PDM_BUFFER_TERM;

       status = MEMwrite(new_buffer, string);
       _pdm_status("MEMwrite", status);

       if ( status != MEM_S_SUCCESS)
         {
           MEMclose(&new_buffer);
           free(string);
           return(PDM_E_WRITE_BUFFER);
         }
      }

    MEMclose(data_buffer);
    *data_buffer = new_buffer;
    
    return(PDM_S_SUCCESS);
  }
  
int PDUupdate_parm_data_buffer(data_buffer, attr_buffer)
  MEMptr	*data_buffer;	/* i/o - buffer containing old data for defaults and new user defined attribute defaults and initial values */
  MEMptr	attr_buffer;	/* i - buffer of attributes (default and user defined */

  {
    int		status = PDM_S_SUCCESS; /* PDM status */
    MEMptr	new_buffer = NULL;	/* new buffer containing new defaults and initials */
    int		row = 0; /* row index for buffer */
    int		col = 0; /* column index for buffer */
    char        **data_cols = NULL; /*     added NULL    APOGEE   */
    char	**data_format = NULL; /*   added NULL    APOGEE   */            /* array of pointers to data types of columns in old data buffer */
    char	**data_data = NULL; /*     added NULL    APOGEE   */            /* array of pointers to old default and initial values */
    char	**attr_data; /* array of pointers to default and user defined attributes */
    int         max_col;
    int         max_row;

    _pdm_debug("In the function PDUupdate_data_buffer",0);

    /* construct array of pointers to attribute data */
    status = MEMbuild_array(attr_buffer);
    _pdm_status("MEMbuild_array", status);
    if ( status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    if (*data_buffer)
     {
      status = MEMbuild_array(*data_buffer);
      _pdm_status("MEMbuild_array", status);
      if ( status != MEM_S_SUCCESS)
         return(PDM_E_BUILD_BUFFER_ARRAY);
     }

    /* open the new buffer */
    status = MEMopen(&new_buffer, PDM_BUFFER_SIZE);
    _pdm_status("MEMopen", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_OPEN_BUFFER);

    if (*data_buffer)
     {
      data_cols = (char **)(*data_buffer)->column_ptr;
      data_format = (char **)(*data_buffer)->format_ptr;
      data_data = (char **)(*data_buffer)->data_ptr;
      max_col = (*data_buffer)->columns;
      max_row = (*data_buffer)->rows;
     }
    else

    {
     max_col = 0;
    
     if (attr_buffer->rows == 0)
        max_row = 0;
     else
        max_row = 1;
    }
      attr_data = (char **) attr_buffer->data_ptr;

    /* write the format information from the old buffer to the new buffer */
    for (col=0; col<max_col; ++col)
      {
        status = MEMwrite_format (new_buffer, data_cols[col], data_format[col]);
        _pdm_status("MEMwrite_format",status);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
          
      }

    /* put the attribute name and data types for new attribute in column data */
    for (row=max_col;col<attr_buffer->rows; ++row, ++col)
      {
        status = MEMwrite_format(new_buffer, 
                   attr_data[(attr_buffer->columns * row)+PDU_NFM_ATTR_COL],
                   attr_data[(attr_buffer->columns * row)+PDU_NFM_DATA_COL]);
        _pdm_status("MEMwrite_format",status);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
      }

    MEMclose(data_buffer);
    *data_buffer = new_buffer;
    
    return(PDM_S_SUCCESS);
  }

int PDUupdate_dyn_data_buffer(data_buffer, attr_buffer)
  MEMptr	*data_buffer;	/* i/o - buffer containing old data for defaults and new user defined attribute defaults and initial values */
  MEMptr	attr_buffer;	/* i - buffer of attributes (default and user defined */

  {
    int		status = PDM_S_SUCCESS; /* PDM status */
    MEMptr	new_buffer = NULL;	/* new buffer containing new defaults and initials */
    int		row = 0; /* row index for buffer */
    int		col = 0; /* column index for buffer */
    char	*string = NULL; /* string to concatenate the data to put in new buffer */
    int		string_len = 0; /* length of string used to add a row to new buffer */
    int		string_index = 0; /* character index for string */
    char        **data_cols = NULL; /*     added NULL    APOGEE   */
    char	**data_format = NULL; /*   added NULL    APOGEE   */            /* array of pointers to data types of columns in old data buffer */
    char	**data_data = NULL; /*     added NULL    APOGEE   */            /* array of pointers to old default and initial values */
    char	**attr_data; /* array of pointers to default and user defined attributes */
    int         max_col;
    int         max_row;

    _pdm_debug("In the function PDUupdate_dyn_data_buffer",0);

    /* construct array of pointers to attribute data */
    status = MEMbuild_array(attr_buffer);
    _pdm_status("MEMbuild_array", status);
    if ( status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    if (*data_buffer)
     {
      status = MEMbuild_array(*data_buffer);
      _pdm_status("MEMbuild_array", status);
      if ( status != MEM_S_SUCCESS)
         return(PDM_E_BUILD_BUFFER_ARRAY);
     }

    /* open the new buffer */
    status = MEMopen(&new_buffer, PDM_BUFFER_SIZE);
    _pdm_status("MEMopen", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_OPEN_BUFFER);

    if (*data_buffer)
     {
      data_cols = (char **)(*data_buffer)->column_ptr;
      data_format = (char **)(*data_buffer)->format_ptr;
      data_data = (char **)(*data_buffer)->data_ptr;
      max_col = (*data_buffer)->columns;
      max_row = (*data_buffer)->rows;
     }
    else

    {
     max_col = 0;
    
     if (attr_buffer->rows == 0)
        max_row = 1;
     else
        max_row = 1;
    }
      attr_data = (char **) attr_buffer->data_ptr;

    /* write the format information from the old buffer to the new buffer */
/* TR# 139422018. 20/Dec/94 - raj. PDMNorm needs 120 char width.
        status = MEMwrite_format (new_buffer, "n_defaultvalue", "char(40)");
*/
        status = MEMwrite_format (new_buffer, "n_defaultvalue", "char(120)");
        _pdm_status("MEMwrite_format",status);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
        status = MEMwrite_format (new_buffer, "n_listno", "integer");
        _pdm_status("MEMwrite_format",status);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
        status = MEMwrite_format (new_buffer, "n_maxvalue", "char(40)");
        _pdm_status("MEMwrite_format",status);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
        status = MEMwrite_format (new_buffer, "n_minvalue", "char(40)");
        _pdm_status("MEMwrite_format",status);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
    _pdm_debug("write blank row", 0);

    string_len = new_buffer->row_size;

    string = (char *)malloc (string_len);

    for (row=0; row < (*data_buffer)->rows; row++)
      {
        _pdm_debug("writing blank row", 0);
        string_index=0;
        memset(string,NULL, string_len);

	/* copy the old defaults and initials */
       for (col=0; col< 4; ++col)
           PDUadd_buffer_string(string, &string_index, 
			data_data[(max_col * row) + col]);
       
       /* add the blank values for the user defined attributes */
       status = MEMwrite(new_buffer, string);
       _pdm_status("MEMwrite", status);

       if ( status != MEM_S_SUCCESS)
         {
           MEMclose(&new_buffer);
           free(string);
           return(PDM_E_WRITE_BUFFER);
         }
      }

    for (row=(*data_buffer)->rows; row < attr_buffer->rows; row++)
      {
        _pdm_debug("writing blank row", 0);
        string_index=0;
        memset(string,NULL, string_len);

	/* copy the old defaults and initials */
       for (col=0; col< 4; ++col)
         string[string_index++] = '\1'; 
       /* add the blank values for the user defined attributes */
       status = MEMwrite(new_buffer, string);
       _pdm_status("MEMwrite", status);

       if ( status != MEM_S_SUCCESS)
         {
           MEMclose(&new_buffer);
           free(string);
           return(PDM_E_WRITE_BUFFER);
         }
      }
    if (string)
      free(string);

    if (*data_buffer)
     MEMclose(data_buffer);
    *data_buffer = new_buffer;
    
    return(PDM_S_SUCCESS);
  }

int PDUupdate_dyn_data_buffer1(data_buffer, attr_buffer)
  MEMptr        *data_buffer;
  MEMptr	attr_buffer;	/* i - buffer of attributes (default and user defined */

  {
    int		status = PDM_S_SUCCESS;
    MEMptr	new_buffer = NULL;	

    _pdm_debug("In the function PDUupdate_dyn_data_buffer1",0);

    /* open the new buffer */
    status = MEMopen(&new_buffer, PDM_BUFFER_SIZE);
    _pdm_status("MEMopen", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_OPEN_BUFFER);

    /* write the format information from the old buffer to the new buffer */
/* TR# 139422018. 20/Dec/94 - raj. PDMNorm needs 120 char width.
        status = MEMwrite_format (new_buffer, "n_defaultvalue", "char(40)");
*/
        status = MEMwrite_format (new_buffer, "n_defaultvalue", "char(120)");
        _pdm_status("MEMwrite_format",status);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
        status = MEMwrite_format (new_buffer, "n_listno", "integer");
        _pdm_status("MEMwrite_format",status);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
        status = MEMwrite_format (new_buffer, "n_maxvalue", "char(40)");
        _pdm_status("MEMwrite_format",status);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
        status = MEMwrite_format (new_buffer, "n_minvalue", "char(40)");
        _pdm_status("MEMwrite_format",status);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
    if (*data_buffer)
     MEMclose(data_buffer);
    *data_buffer = new_buffer;

    return(PDM_S_SUCCESS);
  }
