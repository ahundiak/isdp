#include	<stdio.h>
#include	"PDUstr.h"
#include	"MEMerrordef.h"
#include	"PDUerror.h"
#include	"PDUfile_def.h"
#include	"PDUproto.h"

int PDUfind_col_in_buffer(buffer, attr)
  MEMptr	buffer; 	/* i - buffer of attributes */
  char		*attr;		/* i - attribute or synonym */

  {
  int		row;
  char 		**data;

  _pdm_debug("in PDUfind_col_in_buffer", 0);
  data = (char **)buffer->column_ptr;

  for (row=0; row<buffer->columns; ++row)
    {
     if (strcmp(data[row],attr) == 0)
       break;
    }

  if (row == buffer->columns)
    row = -1;

  return(row);
  }    

int PDUget_column_width(datatype)
  char		*datatype;
  {
   int		width;

   if (strcmp(datatype,"integer") == 0)
     return(15);
   if (strcmp(datatype,"smallint") == 0)
     return(10);
   if (strcmp(datatype,"double") == 0)
     return(25);
   if (strcmp(datatype,"real") == 0)
     return(25);
   if (strncmp(datatype,"char",4) == 0)
     {
       sscanf(datatype,"char(%d)", &width);
       return(width);
     }
   else
     return(15);
  }
 
int PDUheader_string_to_array(string, header_data, header_pos)
  char			*string;
  char			***header_data;
  int			**header_pos;
  {
    int			status = PDM_S_SUCCESS;
    char		**data;
    int			*pos;
    int			char_index;
    int			data_count = 0;
    int			row;
    int			char_count;
    
    _pdm_debug("In the function PDUheader_string_to_array", 0);
    _pdm_debug("string = <%s>", string);

    char_index = 0;

    while (char_index < strlen(string))
      {
        while (string[char_index] == ' ')
	  ++char_index;

        if ( string[char_index] != '\0' )
          data_count++;

        while ((string[char_index] != ' ') && (string[char_index] != '\0'))
   	  ++char_index;
      }

    data = (char **) malloc (data_count * sizeof(char *));
    memset(data, NULL, (data_count * sizeof(char *)));

    pos = (int *) malloc ((data_count + 1) * sizeof(int));
    
    char_index = 0;
    row = 0;

    while(char_index < strlen(string))
      {
        while (string[char_index] == ' ')
	  ++char_index;

        if ( string[char_index] != '\0' )
            pos[row] = char_index;

        char_count = 0;
        
        while ((string[char_index + char_count] != ' ') && 
		(string[char_index + char_count] != '\0')) 
           ++char_count;

        data[row] = (char *) malloc (char_count + 1);
        memset(data[row], NULL, (char_count + 1));
        strncpy(data[row], (string + char_index), char_count);

        char_index += char_count;        
        ++row;
      }

    pos[row] = -1;

    *header_data = data;
    *header_pos = pos;

    return(status);
  }

int PDUupdate_copy_macro_lib_bufr(catalog)

char *catalog;

  {
  int status;
  int cat_col = 0;
  int i, j, char_index;
  int FOUND = FALSE;
  MEMptr new_bufr = NULL;
  char *row = NULL;
  char **macro_data = NULL;
  extern MEMptr PDUmacro_lib_list;
  extern int PDM_debug_on;

  _pdm_debug("In PDUupdate_copy_macro_lib_bufr", 0);

  if (PDUmacro_lib_list == NULL)
    return(PDM_S_SUCCESS);

  status = PDUformat_macro_bufr(&new_bufr);
  _pdm_status("PDUformat_macro_bufr", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  status = MEMbuild_array(PDUmacro_lib_list);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = MEMbuild_array(new_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUget_buffer_col(PDUmacro_lib_list, "n_catalogname", &cat_col);
  _pdm_debug("cat_col = <%d>", (char *)cat_col);

  macro_data = (char **)PDUmacro_lib_list->data_ptr;
  
  row = (char *)malloc(PDUmacro_lib_list->row_size);

  for (i = 0; i < PDUmacro_lib_list->rows; i ++)
    {
    memset(row, NULL, PDUmacro_lib_list->row_size);
    char_index = 0;
    FOUND = FALSE;
    for (j = 0; j < PDUmacro_lib_list->columns; j++)
      {
   if ((cat_col == j) && (macro_data[(PDUmacro_lib_list->columns * i) + j]) && 
       (strcmp(macro_data[(PDUmacro_lib_list->columns * i) + j], catalog) == 0))
        {
        _pdm_debug("catalog found", 0);
        FOUND = TRUE;
        break;
        }
      if ((macro_data[(PDUmacro_lib_list->columns * i) + j]) && 
          (strcmp(macro_data[(PDUmacro_lib_list->columns * i) + j], "") != 0))
        PDUadd_buffer_string(row, &char_index, 
                             macro_data[(PDUmacro_lib_list->columns * i) + j]);
      else
        row[char_index++] = '\1';
      }
      if (FOUND)
        continue;

     _pdm_debug("row = <%s>", row);
     status = MEMwrite(new_bufr, row);
     _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      break;
    }
    
    if (row)
      free(row);

    if (status != MEM_S_SUCCESS)
      {
      MEMclose(&new_bufr);
      return(PDM_E_WRITE_BUFFER);
      }

    if (PDM_debug_on)
      MEMprint_buffer("new copy macro_buffer", new_bufr, PDU_DEBUG_FILE);

    MEMclose(&PDUmacro_lib_list);
    PDUmacro_lib_list = new_bufr;
   
    _pdm_debug("Leaving PDUupdate_copy_macro_lib_bufr", 0);
    return(PDM_S_SUCCESS);
    }
