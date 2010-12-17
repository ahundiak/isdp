#include 	<stdio.h>
#include	<tools.h>
#include        <string.h>
#include        <ctype.h>
#include        <PDUerror.h>
#include        <PDUcommand.h>
#include        <PDUextdef.h>
#include        <PDUproto.h>

int PDUvalidate_quantity(quantity)

char  *quantity;

  {
  int		status = PDM_S_SUCCESS; /* PDM status */
  int		string_len, i, DIGIT_FOUND = FALSE;

  _pdm_debug("quantity= <%s>", quantity);
  
  string_len = strlen(quantity);
  
  if ( string_len == 0 )
    status = PDM_E_INVALID_INPUT;
    
  for ( i = 0;((i < string_len) && (status == PDM_S_SUCCESS));
       ++i )
    {
     _pdm_debug("Examining character <%c>", (char *)quantity[i]);
     
     if ( isdigit ( quantity[i] ))
       {
       _pdm_debug("It is a digit",0);
       if ( DIGIT_FOUND == FALSE )
         DIGIT_FOUND = TRUE;
       }
     else if ((i == 0) && (quantity[i] == '-'))
       {
       _pdm_debug("quantity is a negative", 0);
       DIGIT_FOUND = TRUE;
       }
     else
       if ( quantity[i] == ' ' ) 
         {
         if ( DIGIT_FOUND )
           status = PDM_E_INVALID_INPUT;
         }
       else       
         {
         if ( quantity[i] != '.') 
            status = PDM_E_INVALID_INPUT;
         }

    }

  return(status);
  }

int PDUvalid_filename(catalog, part, revision, filename)
char *catalog;
char *part;
char *revision;
char *filename;

{
  int status;
  int i;
  MEMptr ret_bufr = NULL;
  char **data_data = NULL;
  char **col_data = NULL;
  int attr_col = -1;
  short FOUND = FALSE;

  _pdm_debug("In the function PDUvalid_filename", 0);
  
  /* call function to get the filename */
  status = PDMget_filenames(catalog, part, revision, &ret_bufr);
  _pdm_status("PDMget_filenames", status);

  if ( status != PDM_S_SUCCESS )
    {
    MEMclose(&ret_bufr);
    return(status);
    }

  if ((ret_bufr == NULL) || (ret_bufr->rows == 0))
    {
    _pdm_debug("No files assosciated with this part", 0);
    return(PDM_E_NO_FILE_NAME); 
    }

  MEMbuild_array(ret_bufr);
  
  col_data = (char **)ret_bufr->column_ptr;
  data_data = (char **)ret_bufr->data_ptr;

  for (i = 0; i < ret_bufr->columns; i ++)
     if (strcmp(col_data[i], "n_cofilename") == 0)
       {
       _pdm_debug("n_cofilename found", 0);
       attr_col = i;
       break;
       }

  if (attr_col == -1)
    return(PDM_E_INVALID_BUFFER_FORMAT);

  for (i = 0; i < ret_bufr->rows; i ++)
     if (strcmp(data_data[(ret_bufr->columns * i) + attr_col], filename) == 0)
       {
       _pdm_debug("Filename in buffer", 0);
       FOUND = TRUE;
       break;
       }

  if (FOUND)
    status = PDM_S_SUCCESS;
  else 
    status = PDM_E_FILE_NOT_FOUND;

  if (ret_bufr)
    MEMclose(&ret_bufr);
  return(status);
  }
