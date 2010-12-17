#include	<string.h>
#include	<ctype.h>
#include	<time.h>
#include	<OMlimits.h>
#include	<PDUintdef.h>
#include	<PDUstorage.h>
#include	<PDUint.h>
#include	<igrtypedef.h>
#include	<exdef.h>
#include        <MEMerrordef.h>
#include        <FI.h>
#include        <PDUforms.h>
#include        <PDUfile_def.h>
#include        <PDUuser.h>
#include        <PDUproto.h>
#include        <PDMproto.h>
#include        <sys/types.h>
#include        <sys/stat.h>


extern struct PDUrefresh	*refresh; 
extern struct PDUuser	*user; 
extern struct PDUstorage	*storage; 
extern int    PDU_value_pulldown;
extern Form   PDU_form_id;
extern int    PDU_attr_label;
extern int    new_mode;
extern int    similar_mode;
extern int    change_mode;
extern int    review_mode;
extern struct PDUforms forms;
extern MEMptr PDUmacro_lib_list;
extern MEMptr PDU_storage_area;
extern MEMptr PDU_func_buffer;

extern char *PDU_value_list[605];

/**************************************************************************
 
 DOCUMENT: 
  TOOLS for Product Data User    					
 									
   History:		11/8/89  changed values refering to orientation	
 				 length and origin string length. Com-	
 				 mented out PDUvwpoint_to_string.	
 **************************************************************************/

/* get product path based on a key string */
int  PDUget_search_path (search_key, path_name)
  char	*search_key;
  char	*path_name;
  {
  int	status = PDM_S_SUCCESS;
  int	i, r;
  int	length;
  char	buffer[PDU_PATHNAME_SIZE], *s;
  char	product_key[20];
  char	logo[20];
  char	module_type[40];
  char	search_path[40];
  char	config_path[80];

  FILE	*in_file;

  _pdm_debug("In function PDUget_path, product search key = %s", search_key);

  strcpy(path_name, "");
  strcpy(path_name, "");
  length = sizeof(buffer);

  in_file = fopen(PDU_PRODUCT_DATA_FILE, "r");
  if ( in_file != NULL )
     {
     status = PDM_E_FAILURE;
     i = 0;
     s = fgets(buffer, length , in_file);

     while ( s != NULL )	  
	  {
	  ++i;
/*
	  _pdm_debug("product data: %s", buffer);
*/
	  r = sscanf (buffer, "%s %s %s %s %s",
		      product_key, logo, module_type, search_path, config_path);
	  if ( r == 0 )	return(PDM_E_INVALID_FORMAT);

	  _pdm_debug("product key = %s", product_key);
	  _pdm_debug("search key = %s", search_key);
	  PDUunquote(product_key);

	  if ( PDUlstrcmp( product_key, search_key ) == 0 )
	     {
	     _pdm_debug("product entry was found", 0);

	     strncpy(path_name, config_path, PDU_PATHNAME_SIZE);
	     strcat( path_name, "/");
	     status = PDM_S_SUCCESS;

	     break;
	     }

	  s = fgets(buffer, length , in_file);               
	  }

     _pdm_debug("Finished reading %d lines of product data file", (char *)i );

     fclose(in_file);
     }
  else
     {
     _pdm_debug("Couldn't open file %s for input", PDU_PRODUCT_DATA_FILE);
     status = PDM_E_OPEN_FILE;
     }

  return (status);
  }


/* strip off quotes from a string */
int  PDUunquote (input_string)
  char	*input_string;
  {
  char *ptr = NULL;
  _pdm_debug("In the PDUunquote function", 0);
  
  if (input_string == NULL)
    {
    _pdm_debug("input_string is NULL", 0);
    }
  else
    {
    _pdm_debug("input string = <%s>", input_string);
    }

  /* Check to see if input string = "" */
/* SUN */
  if (input_string == NULL)
     {
      return (PDM_S_SUCCESS);
     }
  else if (strcmp(input_string, "") == 0)
     {
      return (PDM_S_SUCCESS);
     }

  /* strip quotes off of command string */
  ptr = strchr(input_string, '"');
  if (ptr == NULL)
    return(PDM_S_SUCCESS); 
  strcpy(input_string, strtok(&input_string[1], "\"") );

  return (PDM_S_SUCCESS);
  }


/* lower case string compare */
int  PDUlstrcmp (string1, string2)
  char	*string1;
  char	*string2;
  {
  while ( (tolower(*string1) == tolower(*string2)) && *string1 && *string2 )
     {
     ++string1; ++string2;
     }

  if ( *string1 || *string2 )
     return(1);
  else
     return(0);
  }

int	PDUget_date ( date )
  char	*date;
  {
  IGRlong       systime;

  /* get date from system */
  time (&systime);
  strncpy(date, ctime(&systime), 26); date[24] = '\0';
 
  return (PDM_S_SUCCESS);
  }

#define PDM_LEVEL_MASK          0x80000000

int	PDUsetlevels (level_mask)
int	*level_mask;
  {
  IGRint	i;

  /* clear level mask array */
  for ( i = 0; i < 31; ++i ) level_mask[i] = 0;

  /* set level mask bit for pdm indicator level */
  level_mask[31] |= PDM_LEVEL_MASK;

  return (PDM_S_SUCCESS);
  }

/* function to find the value of a given obj. directory */

int PDUextract_dir_value(dir_path,dir_name,dir_value)

char   *dir_path;
char   *dir_name;
char   **dir_value;

   {
     char   *s;
     char   *temp = NULL;


     _pdm_debug("In the function PDUextract_dir_value",0); 

     s = strtok(dir_path,":");

/* BETH should check s for NULL */
/*
     while (dir_path)
*/
     while (s)
           {
             PDUfill_in_string(&temp,s);
             _pdm_debug("token = <%s>",temp);
             if (strcmp(temp,dir_name) ==0)
                {
                 s = strtok(0,":");
                 PDUfill_in_string(dir_value,s);
                 return(PDM_S_SUCCESS);
                }
             s = strtok(0,":");
           }
     _pdm_debug("PDUextract_dir_value fails",0);
     return (PDM_S_SUCCESS);
   }

int PDUcheck_expression_value(value)
   char  **value;
   {
    IGRchar  *temp_str = NULL;
    IGRchar  *s;
    IGRint   length; 
    IGRlong  status = PDM_S_SUCCESS;

    _pdm_debug("In the function PDUcheck_expression_value",0);

    _pdm_debug("expression value = <%s>",*value);

    if ((strcmp(*value, "") ==  0) || (*value == NULL))
      return(PDM_E_EXP_ERROR);

    if ((*value)[0] == '"')
       {
        _pdm_debug("string expression <%s> need to be unquoted",*value);
        PDUunquote(*value);
        return(PDM_S_SUCCESS);
       }

    else
       {
        PDUfill_in_string(&temp_str,*value);
        s = strpbrk(temp_str,"[");
        if (s)
           {
            s = strtok(temp_str,"[");
            _pdm_debug("numeric expression <%s> need to be modified",*value);

            PDUfill_in_string(value,s);
            length = strlen(*value);
            (*value)[length - 1] = '\0';
            return(PDM_S_SUCCESS);
           }
       }
    return (status);
   }
 
int PDUmodify_assy_entry(entry_name,old_dir_name,new_dir_name,modified_entry)

char   *entry_name;
char   *old_dir_name;
char   *new_dir_name;
char   **modified_entry;

   {
     char   *s;
     char   *temp = NULL;
     long   status = PDM_S_SUCCESS;


     _pdm_debug("In the function PDUmodify_assy_entry",0); 

     _pdm_debug("old entry name = <%s>",entry_name);
     _pdm_debug("old directory name = <%s>",old_dir_name);
     _pdm_debug("new directory name = <%s>",new_dir_name);

     /* initialize modified_string to ":" */
     strcpy(*modified_entry,":");

     s = strtok(entry_name,":");

     while (s)
           {
             PDUfill_in_string(&temp,s);
             _pdm_debug("token = <%s>",temp);
             
             if (strcmp(temp,"ASSEMBLY") == 0)
                {
                 strcat(*modified_entry,temp);
                 strcat(*modified_entry,":");

                 s = strtok(0,":");
                 PDUfill_in_string(&temp,s);
                 _pdm_debug("part child no = <%s>",temp);

                 if (strcmp(temp,old_dir_name) == 0)
                    {
                     strcat(*modified_entry,new_dir_name);
                     strcat(*modified_entry,":");
                     s = strtok(0,":");
                    }
                }
             else
                {
                 strcat(*modified_entry,temp);
                 strcat(*modified_entry,":");
                 s = strtok(0,":");
                }
            }

         _pdm_debug("modified entry = <%s>",*modified_entry);

     return (status);
   }

int PDUprocess_pulldown_list(name, attr_buffer, list_buffer)

char *name;
MEMptr attr_buffer;
MEMptr list_buffer;

  {

  int status;
  char **attr_data;
  char **list_data;
  char **list_cols;
  int  list_size;
  int  row;
  int  i;
  int  buffer_number;
  char *attr_name = NULL;
  char *function_name = NULL;
  

  _pdm_debug("In the function PDUprocess_pulldown_list", 0);

  if (PDM_debug_on)
    _pdm_debug("attr_name = <%s>", name);     

  status = MEMbuild_array(attr_buffer,"");
  _pdm_status("MEMbuild_array(attr_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  /* see if name is synonym or attribute name */
  row = PDUfind_attr_by_synonym(name, attr_buffer);
  if (row != -1 )
    {
    _pdm_debug("row = %d", (char *)row);
    attr_data = (char **)attr_buffer->data_ptr;
    _pdm_debug("Before PDUfill", 0);
    PDUfill_in_string(&attr_name, attr_data[(attr_buffer->columns * row) +
                      PDU_NFM_ATTR_COL]);
    _pdm_debug("attr_name = <%s>", attr_name);
    }
  else
    {
    PDUfill_in_string(&attr_name, name);
    row = PDUfind_attr_in_buffer(attr_buffer, name);
    }

  attr_data = (char **)attr_buffer->data_ptr;

  _pdm_debug("Convert buffer_number to integer", 0);
  sscanf(attr_data[(attr_buffer->columns * row) + PDU_NFM_LISTNO_COL],
         "%d", &buffer_number);
  _pdm_debug("buffer_number = %d ", (char *)buffer_number);
  if (buffer_number >= 1)
    {
    status = MEMreset_buffer_no(list_buffer, buffer_number);
    _pdm_status("MEMreset_buffer_no", status);
    _pdm_debug("buffer number = %d ", (char *)buffer_number);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_RESET_BUFFER);

    list_cols = (char **)list_buffer->column_ptr;
    list_data = (char **)list_buffer->data_ptr;
    if (strcmp(list_cols[0], "n_value") == 0)
      {
      _pdm_debug("Static list of values defined", 0);
      for (i = 0; i < list_buffer->rows; i ++)
        PDUfill_in_string(&PDU_value_list[i], list_data[list_buffer->columns * i 
                          + 0]);
      }
    else if (strcmp(attr_name, "n_aclno") == 0)
      {
      _pdm_debug("list of acls defined", 0);
      for (i = 0; i < list_buffer->rows; i ++)
        PDUfill_in_string(&PDU_value_list[i],list_data[list_buffer->columns * i
                          + 2]);
      }
     
    list_size = list_buffer->rows;
    /* put the values in the pull down list */
    GRchange_pull_down_text(PDU_value_pulldown, PDU_value_list,
                            list_size);

    /* display the pulldown list */
    GRproc_pull_down_list(PDU_value_pulldown);
    }
   else if (PDU_func_buffer)
     {
     status = PDUcheck_for_function(attr_name, &function_name, PDU_func_buffer);
     _pdm_status("PDUcheck_for_function", status);

     if (status == PDM_S_SUCCESS)
       {
       status = PDUprocess_function(function_name);
       _pdm_status("PDUprocess_function", status);
       }
     }

  return(PDM_S_SUCCESS);
  }

int PDUprocess_dyn_pulldown_list(catalog, name, attr_buffer)

char *catalog;
char *name;
MEMptr attr_buffer;

  {

  int status;
  char **attr_data;
  char **list_data;
  int  list_size;
  int  row;
  int  i;
  char *attr_name = NULL;
  char *function_name = NULL;
  MEMptr list_buffer = NULL;
  

  _pdm_debug("In the function PDUprocess_pulldown_list", 0);

  _pdm_debug("attr_name = <%s>", name);     
  _pdm_debug("catalog = <%s>", catalog);     

  status = MEMbuild_array(attr_buffer,"");
  _pdm_status("MEMbuild_array(attr_buffer)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  /* see if name is synonym or attribute name */
  row = PDUfind_dyn_attr_by_synonym(name, attr_buffer);
  if (row != -1 )
    {
    _pdm_debug("row = %d", (char *)row);
    attr_data = (char **)attr_buffer->data_ptr;
    _pdm_debug("Before PDUfill", 0);
    PDUfill_in_string(&attr_name, attr_data[(attr_buffer->columns * row) +
                      PDU_DYN_ATTR_COL]);
    _pdm_debug("attr_name = <%s>", attr_name);
    }
  else
    {
    PDUfill_in_string(&attr_name, name);
    row = PDUfind_attr_in_buffer(attr_buffer, name);
    }

   if (PDU_func_buffer)
     {
     status = PDUcheck_for_function(attr_name, &function_name, PDU_func_buffer);
     _pdm_status("PDUcheck_for_function", status);

     if (status == PDM_S_SUCCESS)
       {
       status = PDUprocess_function(function_name);
       _pdm_status("PDUprocess_function", status);
       return(PDM_S_SUCCESS);
       }
     }

  status = PDMget_list_buffer(catalog, attr_name, &list_buffer);
  _pdm_status("PDMget_list_buffer", status);

  if (status != PDM_S_SUCCESS)
    return(PDM_S_SUCCESS);
  else if (list_buffer == NULL) 
    return(PDM_S_SUCCESS);
  else if (list_buffer->rows == 0)
    return(PDM_S_SUCCESS);

  status = MEMbuild_array(list_buffer);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(status);
  list_data = (char **)list_buffer->data_ptr;
  for (i = 0; i < list_buffer->rows; i ++)
    PDUfill_in_string(&PDU_value_list[i], list_data[(list_buffer->columns * i) +
                       0]);
  list_size = list_buffer->rows;
  /* put the values in the pull down list */
  GRchange_pull_down_text(PDU_value_pulldown, PDU_value_list,
                          list_size);

  /* display the pulldown list */
  GRproc_pull_down_list(PDU_value_pulldown);
  return(PDM_S_SUCCESS);
  }

int PDUfill_attribute_list(attr_bufr, data_bufr, list_bufr)

MEMptr attr_bufr;
MEMptr data_bufr;
MEMptr list_bufr;

  {
  int status, i,j;
  char **attr_data = NULL;
  char **data_data = NULL;
  char **list_data = NULL;
  char **list_values = NULL;
  char **func_data = NULL;
  char *string;
  int  n_attr_col;
  int  num_rows = 0;
  int  buffer_number;
  int FOUND = FALSE;

  if (PDU_form_id == forms.dynamic_attr_form_id)
  {
  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array(attr_bufr)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array(data_bufr)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
  }

  attr_data = (char **) attr_bufr->data_ptr;
  data_data = (char **) data_bufr->data_ptr;

  _pdm_debug("attr_bufr->rows = <%d>", (char *)attr_bufr->rows);

  if ((PDU_form_id == forms.part_operations_form_id) && ((new_mode == TRUE) ||
       (similar_mode == TRUE)))
    n_attr_col = PDU_NFM_WRITE_COL;
  else if ((PDU_form_id == forms.part_operations_form_id) && 
           (change_mode == TRUE)) 
    n_attr_col = PDU_NFM_UPDATE_COL;
  else if ((PDU_form_id == forms.part_operations_form_id) && 
           (review_mode == TRUE))
    n_attr_col = PDU_NFM_READ_COL;
  else
    n_attr_col = PDU_NFM_WRITE_COL;
    
  FIfld_set_max_num_rows(PDU_form_id, PDU_attr_label, 0);
  for (i = 0; i < attr_bufr->rows; i++)
    {
    if (strcmp(attr_data[(attr_bufr->columns * i) + n_attr_col],"Y")
            == 0)
      {
      if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
           "n_itemname")) &&
           (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
            "n_itemrev")) &&
           (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
            "p_parttype")) &&
           (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
            "n_itemdesc")) &&
           (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
            "n_aclno")) &&
           (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
             "n_filetype")) &&
           (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
             "n_cifilename")) &&
           (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
            "n_cisano")) &&
           (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
            "p_filedesc")) &&
           (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
            "n_cocomment")) &&
           (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
            "n_stateno")) &&
           (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
             "n_cofilename")))
        {
      if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_LISTNO_COL], "0")
          == 0) && 
           (PDU_func_buffer))
          {
          _pdm_debug("check for function", 0);
          status = MEMbuild_array(PDU_func_buffer);
          _pdm_status("MEMbuild_array", status);

          if (status != MEM_S_SUCCESS)
            return(PDM_E_BUILD_BUFFER_ARRAY);
          func_data = (char **)PDU_func_buffer->data_ptr;

          FOUND = FALSE;
          for (j = 0; j < PDU_func_buffer->rows; j++)
            {
            if (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
              func_data[(PDU_func_buffer->columns * j) + 0]) == 0)
             {
             FOUND = TRUE;
            string = (char *)malloc((attr_bufr)->row_size);
            if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL], 
               "") != 0) &&
              (attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL] != NULL))
             {
             sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) + 
                     PDU_NFM_SYN_COL]);
             _pdm_debug("string after sprintf = <%s>", string);
             FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
	                    string,FALSE);
            }
           else
            {
             sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) + 
                   PDU_NFM_ATTR_COL]);
             _pdm_debug("string after sprintf = <%s>", string);
             FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
	                    string,FALSE);
             }
           free(string);
           break;
           }
         }
       if (!FOUND)
        {
        if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL], 
             "") != 0) && 
            (attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL] != NULL))
           FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
          attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL],FALSE);
        else
          FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
         attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],FALSE);
       }
      }
     else if (strcmp(attr_data[(attr_bufr->columns * i) + 
                  PDU_NFM_LISTNO_COL], "0") == 0)
          {
          if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL], 
               "") != 0) &&
              (attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL] != NULL))
             FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
	          attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL],FALSE);
          else
            FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
	         attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],FALSE);
          }
       else
          {
          sscanf(attr_data[(attr_bufr->columns * i) + PDU_NFM_LISTNO_COL], "%d",
                   &buffer_number);
          status = MEMreset_buffer_no(list_bufr, buffer_number);
          _pdm_status("MEMreset_buffer_no", status);

          if (status != MEM_S_SUCCESS)
            return(PDM_E_RESET_BUFFER);

          list_data = (char **)list_bufr->column_ptr;

          if (strcmp(list_data[0], "n_value") == 0)
            {
            string = (char *)malloc((attr_bufr)->row_size);
            if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL], 
               "") != 0) &&
              (attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL] != NULL))
             {
             sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) + 
                     PDU_NFM_SYN_COL]);
             _pdm_debug("string after sprintf = <%s>", string);
             FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
	                    string,FALSE);
            }
           else
            {
             sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) + 
                   PDU_NFM_ATTR_COL]);
             _pdm_debug("string after sprintf = <%s>", string);
             FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
	                    string,FALSE);
             }
           free(string);
           }
      else if ((strcmp(list_data[0], "n_input") == 0) &&
               (strcmp(list_data[1], "n_minvalue") == 0))
        {
        string = (char *)malloc(attr_bufr->row_size);
        memset(string, NULL, attr_bufr->row_size);
        list_values = (char **)list_bufr->data_ptr;
         if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL], "")
             != 0) && (attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL]))
           {
            sprintf(string, "%s (min: %s max: %s)",
                    attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL],
                    list_values[1], list_values[2]);
           _pdm_debug("string = <%s>", string);
           FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, string,
                          FALSE);
            }
          else
           {
           sprintf(string, "%s (min: %s max: %s)",
                    attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
                    list_values[1], list_values[2]);
           _pdm_debug("string = <%s>", string);
           FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, string,
                          FALSE);
            }
          if (string)
            free(string);
         }
         else
           {
          if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL], 
               "") != 0) &&
              (attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL] != NULL))
             FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
	          attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL],FALSE);
          else
            FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
	         attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],FALSE);
           }
          }
       _pdm_debug("data_bufr->columns %d", (char *)data_bufr->columns);
       _pdm_debug("Filling in dynamic data col", 0);
       if (strcmp(data_data[i], "") != 0)
         FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 1, 
                 data_data[i],FALSE);
       else
         FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 1, 
                 "",FALSE);
       num_rows = num_rows + 1;
       }
       }
     }
   if (num_rows > 0)
     FIfld_set_max_num_rows(PDU_form_id, PDU_attr_label, num_rows);
   else
     FIfld_set_max_num_rows(PDU_form_id, PDU_attr_label, 1);
   return(PDM_S_SUCCESS);
  }

int PDUfill_attribute_list1(attr_bufr, data_bufr)

MEMptr attr_bufr;
MEMptr data_bufr;

  {
  int status, i,j;
  char **attr_data = NULL;
  char **data_data = NULL;
  char **func_data = NULL;
  char *string;
  int  num_rows = 0;
  int FOUND = FALSE;

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array(attr_bufr)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array(data_bufr)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_data = (char **) attr_bufr->data_ptr;
  data_data = (char **) data_bufr->data_ptr;

  _pdm_debug("attr_bufr->rows = <%d>", (char *)attr_bufr->rows);

  FIfld_set_max_num_rows(PDU_form_id, PDU_attr_label, 0);
  for (i = 0; i < attr_bufr->rows; i++)
    {
    if ((attr_data[(attr_bufr->columns * i) + PDU_DYN_WRITE_COL]) && 
        (strcmp(attr_data[(attr_bufr->columns * i) + PDU_DYN_WRITE_COL], "N")
        == 0))
      continue;
    if ((data_data[(data_bufr->columns * i) + PDU_DYN_LISTNO_COL]) && 
        (strcmp(data_data[(data_bufr->columns * i) + PDU_DYN_LISTNO_COL], "")
        != 0))
       {
       string = (char *)malloc((attr_bufr)->row_size);
       if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL], 
           "") != 0) &&
           (attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL] != NULL))
         {
         sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) + 
                 PDU_DYN_SYN_COL]);
         _pdm_debug("string after sprintf = <%s>", string);
          FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
	                 string,FALSE);
          }
        else
          {
          sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) + 
                  PDU_DYN_ATTR_COL]);
          _pdm_debug("string after sprintf = <%s>", string);
          FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
	                 string,FALSE);
          }
        free(string);
       }
     else if ((strcmp(data_data[(data_bufr->columns * i) + PDU_DYN_MIN_VAL_COL],
              "") != 0) || (strcmp(data_data[(data_bufr->columns * i) + 
              PDU_DYN_MAX_VAL_COL], "") != 0))
        {
        string = (char *)malloc(attr_bufr->row_size);
        memset(string, NULL, attr_bufr->row_size);
        if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL], "")
            != 0) && (attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL]))
           {
            sprintf(string, "%s (min: %s max: %s)",
                    attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL],
                    data_data[(data_bufr->columns * i) + PDU_DYN_MIN_VAL_COL],
                    data_data[(data_bufr->columns * i) + PDU_DYN_MAX_VAL_COL]);
           _pdm_debug("string = <%s>", string);
           FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, string,
                          FALSE);
            }
          else
           {
           sprintf(string, "%s (min: %s max: %s)",
                    attr_data[(attr_bufr->columns * i) + PDU_DYN_ATTR_COL],
                    data_data[(data_bufr->columns * i) + PDU_DYN_MIN_VAL_COL],
                    data_data[(data_bufr->columns * i) + PDU_DYN_MAX_VAL_COL]);
           _pdm_debug("string = <%s>", string);
           FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, string,
                          FALSE);
            }
          if (string)
            free(string);
         }
       else if (PDU_func_buffer)
         {
         _pdm_debug("check for function", 0);
         status = MEMbuild_array(PDU_func_buffer);
         _pdm_status("MEMbuild_array", status);

         if (status != MEM_S_SUCCESS)
           return(PDM_E_BUILD_BUFFER_ARRAY);
         func_data = (char **)PDU_func_buffer->data_ptr;

         FOUND = FALSE;
         for (j = 0; j < PDU_func_buffer->rows; j++)
           {
           if (strcmp(attr_data[(attr_bufr->columns * i) + PDU_DYN_ATTR_COL],
             func_data[(PDU_func_buffer->columns * j) + 0]) == 0)
             {
             FOUND = TRUE;
             string = (char *)malloc((attr_bufr)->row_size);
             if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL],
               "") != 0) &&
              (attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL] != NULL))
             {
             sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) +
                     PDU_DYN_SYN_COL]);
             _pdm_debug("string after sprintf = <%s>", string);
             FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0,
                            string,FALSE);
             }
             else
             {
             sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) +
                   PDU_DYN_ATTR_COL]);
             _pdm_debug("string after sprintf = <%s>", string);
             FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0,
                            string,FALSE);
             }
             free(string);
             break;
             }
           }
         if (!FOUND)
           {
           if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL],
               "") != 0) &&
              (attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL] != NULL))
             FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0,
               attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL],FALSE);
           else
             FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0,
             attr_data[(attr_bufr->columns * i) + PDU_DYN_ATTR_COL],FALSE);
           }
        }
      else
           {
          if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL], 
               "") != 0) &&
              (attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL] != NULL))
             FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
	          attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL],FALSE);
          else
            FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 0, 
	         attr_data[(attr_bufr->columns * i) + PDU_DYN_ATTR_COL],FALSE);
           }
       _pdm_debug("data_bufr->columns %d", (char *)data_bufr->columns);
       _pdm_debug("Filling in dynamic data col", 0);
       if (strcmp(data_data[(data_bufr->columns * i) + PDU_DYN_DEFAULT_VAL_COL],
           "") != 0)
         FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 1, 
                 data_data[(data_bufr->columns * i) + PDU_DYN_DEFAULT_VAL_COL],
           FALSE);
       else
         FIfld_set_text(PDU_form_id, PDU_attr_label, num_rows, 1, 
                 "",FALSE);
       num_rows = num_rows + 1;
     }
   if (num_rows > 0)
     FIfld_set_max_num_rows(PDU_form_id, PDU_attr_label, num_rows);
   else
     FIfld_set_max_num_rows(PDU_form_id, PDU_attr_label, 1);
   return(PDM_S_SUCCESS);
  }

int PDUvalidate_data_value(attr_text1, attr_value, attr_buffer, list_buffer)

char *attr_text1;
char *attr_value;
MEMptr attr_buffer;
MEMptr list_buffer;

  {
  int status;
  int i;
  int buffer_number = 0;
  int attr_num;
  int min_num;
  int max_num;
  int FOUND = FALSE;
  double real_num, real_max, real_min;
  double doub_num, doub_max, doub_min;
  char **attr_data = NULL;
  char **list_data = NULL;
  char **list_col = NULL;
  char *datatype = NULL;
  char *attr_name = NULL;
  char *attr_text = NULL;
  char *str = NULL;
  char *function_name = NULL;
  char *msg;

  _pdm_debug("In PDUvalidate_data_value", 0);

  _pdm_debug("Attribute text is <%s>", attr_text);
  _pdm_debug("Attribute value is <%s>", attr_value);

  status = MEMbuild_array(attr_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_data = (char **)attr_buffer->data_ptr;

  /* strip off * if there is one */
  PDUfill_in_string(&attr_text, attr_text1);
  if (attr_text[0] == '*') 
    attr_text = attr_text + 1;
  else 
    {
     str = strstr(attr_text, "(min:");

     if (str)
        {
        *((char *) strstr(attr_text, "(min:")) = '\0';
        *((char *) strrchr(attr_text, ' ')) = '\0';
        }
    }
/*

     {
     ptr = strrchr(attr_text, '(');

     if (ptr)
       {
          *((char *) strrchr(attr_text, '(')) = '\0';
          *((char *) strrchr(attr_text, ' ')) = '\0';
        }
     }
    }

*/
  for (i = 0; i < attr_buffer->rows; i ++)
    {
     if (strcmp(attr_data[(attr_buffer->columns * i) + PDU_NFM_SYN_COL], 
         attr_text) == 0)
       {
       PDUfill_in_string(&attr_name, attr_data[(attr_buffer->columns * i) +
                         PDU_NFM_ATTR_COL]);
       PDUfill_in_string(&datatype, attr_data[(attr_buffer->columns * i)
                         + PDU_NFM_DATA_COL]);
       sscanf(attr_data[(attr_buffer->columns * i) + PDU_NFM_LISTNO_COL],
                        "%d", &buffer_number);
       break;
       }
     else if (strcmp(attr_data[(attr_buffer->columns * i) + PDU_NFM_ATTR_COL], 
              attr_text) == 0)
       {
       PDUfill_in_string(&attr_name, attr_text);
       PDUfill_in_string(&datatype, attr_data[(attr_buffer->columns * i)
                         + PDU_NFM_DATA_COL]);
       sscanf(attr_data[(attr_buffer->columns * i) + PDU_NFM_LISTNO_COL],
                        "%d", &buffer_number);
       break;
       }
     }

     if ((strcmp(attr_value, "") == 0) && (strcmp(attr_name, PDU_MAXLEVEL_ATTR)
         == 0))
        return(PDM_E_AT_MAXLEVEL);
     else if (strcmp(attr_value, "") == 0)
        return(PDM_S_SUCCESS);

     status = PDUvalidate_value(attr_value, datatype);
     _pdm_status("PDUvalidate_value", status);

     if (status != PDM_S_SUCCESS)
       return(status);

     if (buffer_number > 0)
       {
       /* check and see if what kind of list */
       _pdm_debug("buffer_number = <%d>", (char *)buffer_number);
       status = MEMreset_buffer_no(list_buffer, buffer_number);
       _pdm_status("MEMreset_buffer_no", status);
       if (status != MEM_S_SUCCESS)
         return(PDM_E_RESET_BUFFER);
       
       list_data = (char **)list_buffer->data_ptr;
       list_col = (char **)list_buffer->column_ptr;

       if (strcmp(list_col[0], "n_value") == 0)
         {
         _pdm_debug("validate value against static list", 0);
         for (i = 0; i < list_buffer->rows; i ++)
           {
         if (strcmp(attr_value, list_data[(list_buffer->columns * i) + 0]) == 0)
             {
             FOUND = TRUE;
             break;
             }
           }
         if (!FOUND)
           status = PDM_E_INVALID_INPUT;
         else 
           status = PDM_S_SUCCESS;
         } 
       else if (strcmp(list_col[0], "n_aclno") == 0)
         {
         _pdm_debug("validate value against static list", 0);
         for (i = 0; i < list_buffer->rows; i ++)
           {
           if (strcmp(attr_value, list_data[list_buffer->columns * i]) == 0)
             {
             FOUND = TRUE;
             break;
             }
           }
         if (!FOUND)
           {
             msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_LIST);
             FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
           status = PDM_E_INVALID_INPUT;
           }
         else 
           status = PDM_S_SUCCESS;
         } 
       else if ((strcmp(datatype, "integer") == 0) || (strcmp(datatype,
                 "smallint") == 0))
         {
           sscanf(list_data[1], "%d", &min_num);
           sscanf(list_data[2], "%d", &max_num);
           sscanf(attr_value, "%d", &attr_num);
           if ((strcmp(list_data[1], "") == 0) && (attr_num > max_num))
             {
             msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
             FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
             status = PDM_E_INVALID_INPUT;
             }
           else if (strcmp(list_data[1], "") == 0)
             status = PDM_S_SUCCESS;
           else if ((strcmp(list_data[2], "") == 0) && (attr_num < min_num))
             {
             msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
             FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
             status = PDM_E_INVALID_INPUT;
             }
           else if (strcmp(list_data[2], "") == 0)
             status = PDM_S_SUCCESS;
           else if ((attr_num > max_num) || (attr_num < min_num))
             {
             msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
             FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
             status = PDM_E_INVALID_INPUT;
             }
           else
             status = PDM_S_SUCCESS;
         }
       else if (strcmp(datatype, "real") == 0)
         {
           sscanf(list_data[1], "%lf", &real_min);
           sscanf(list_data[2], "%lf", &real_max);
           sscanf(attr_value, "%lf", &real_num);
           if ((strcmp(list_data[1], "") == 0) && (real_num > real_max))
             {
             msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
             FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
             status = PDM_E_INVALID_INPUT;
             }
           else if (strcmp(list_data[1], "") == 0)
             status = PDM_S_SUCCESS;
           else if ((strcmp(list_data[2], "") == 0) && (real_num < real_min))
             {
             msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
             FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
             status = PDM_E_INVALID_INPUT;
             }
           else if (strcmp(list_data[2], "") == 0)
             status = PDM_S_SUCCESS;
           else if ((real_num > real_max) || (real_num < real_min))
             {
             msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
             FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
             status = PDM_E_INVALID_INPUT;
             }
           else
             status = PDM_S_SUCCESS;
         }
       else
         {
           sscanf(list_data[1], "%lf", &doub_min);
           sscanf(list_data[2], "%lf", &doub_max);
           sscanf(attr_value, "%lf", &doub_num);
           if ((strcmp(list_data[1], "") == 0) && (doub_num > doub_max))
             {
             msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
             FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
             status = PDM_E_INVALID_INPUT;
             }
           else if (strcmp(list_data[1], "") == 0)
             status = PDM_S_SUCCESS;
           else if ((strcmp(list_data[2], "") == 0) && (doub_num < doub_min))
             {
             msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
             FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
             status = PDM_E_INVALID_INPUT;
             }
           else if (strcmp(list_data[2], "") == 0)
             status = PDM_S_SUCCESS;
           else if ((doub_num > doub_max) || (doub_num < doub_min))
             {
             msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
             FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
             status = PDM_E_INVALID_INPUT;
             }
           else
             status = PDM_S_SUCCESS;
         }
       }
   else if (PDU_func_buffer)
     {
     status = PDUcheck_for_function(attr_name, &function_name, PDU_func_buffer);
     _pdm_status("PDUcheck_for_function", status);

     if (status == PDM_S_SUCCESS)
       status = PDM_E_FAILURE; 
     else
       status = PDM_S_SUCCESS;
      }
   return(status);
   }

int PDUvalidate_dyn_data_value(attr_text1, attr_value, catalog, attr_buffer,
                               data_bufr)

char *attr_text1;
char *attr_value;
char *catalog;
MEMptr attr_buffer;
MEMptr data_bufr;

  {
  int status;
  int i;
  int attr_num;
  int min_num;
  int max_num;
  int attr_row = 0;
  int FOUND = FALSE;
  short list_assoc = FALSE;
  double real_num, real_max, real_min;
  double doub_num, doub_max, doub_min;
  char **attr_data = NULL;
  char **data_data = NULL;
  char **list_data = NULL;
  char *datatype = NULL;
  char *attr_name = NULL;
  char *attr_text = NULL;
  char *str = NULL;
  char *function_name = NULL;
  char *msg;
  MEMptr list_buffer = NULL;

  _pdm_debug("In PDUvalidate_dyn_data_value", 0);

  _pdm_debug("Attribute text is <%s>", attr_text1);
  _pdm_debug("Attribute value is <%s>", attr_value);

  status = MEMbuild_array(attr_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_data = (char **)attr_buffer->data_ptr;

  status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  data_data = (char **)data_bufr->data_ptr;
  /* strip off * if there is one */
  PDUfill_in_string(&attr_text, attr_text1);
  if (attr_text[0] == '*') 
    attr_text = attr_text + 1;
  else 
    {
     str = strstr(attr_text, "(min:");

     if (str)
        {
        *((char *) strstr(attr_text, "(min:")) = '\0';
        *((char *) strrchr(attr_text, ' ')) = '\0';
        }
    }
  _pdm_debug("attr_text = <%s>", attr_text);
  for (i = 0; i < attr_buffer->rows; i ++)
    {
    _pdm_debug("attribute = <%s>", attr_data[(attr_buffer->columns * i) + 
               PDU_DYN_ATTR_COL]);
    _pdm_debug("synonym = <%s>", attr_data[(attr_buffer->columns * i) + 
               PDU_DYN_SYN_COL]);
     if (strcmp(attr_data[(attr_buffer->columns * i) + PDU_DYN_SYN_COL], 
         attr_text) == 0)
       {
       PDUfill_in_string(&attr_name, attr_data[(attr_buffer->columns * i) +
                         PDU_DYN_ATTR_COL]);
       PDUfill_in_string(&datatype, attr_data[(attr_buffer->columns * i)
                         + PDU_DYN_DATA_COL]);
       if (strcmp(data_data[(data_bufr->columns * i) + PDU_DYN_LISTNO_COL], 
           "") != 0)
         list_assoc = TRUE;
       else
         list_assoc = FALSE;
       attr_row = i;
       break;
       }
     else if (strcmp(attr_data[(attr_buffer->columns * i) + PDU_DYN_ATTR_COL], 
              attr_text) == 0)
       {
       PDUfill_in_string(&attr_name, attr_text);
       PDUfill_in_string(&datatype, attr_data[(attr_buffer->columns * i)
                         + PDU_DYN_DATA_COL]);
       if (strcmp(data_data[(data_bufr->columns * i) + PDU_DYN_LISTNO_COL], 
           "") != 0)
         list_assoc = TRUE;
       else
         list_assoc = FALSE;
        attr_row = i;
       break;
       }
     }

     if (strcmp(attr_value, "") == 0)
        return(PDM_S_SUCCESS);

     status = PDUvalidate_value(attr_value, datatype);
     _pdm_status("PDUvalidate_value", status);

     if (status != PDM_S_SUCCESS)
       return(status);

     if (list_assoc)
       {
       /* check and see if what kind of list */
       status = PDMget_list_buffer(catalog, attr_name, &list_buffer);
       _pdm_status("PDMget_list_buffer", status);
       if (status != PDM_S_SUCCESS)
         return(PDM_S_SUCCESS);
       else if (list_buffer == NULL)
         return(PDM_S_SUCCESS);
       else if (list_buffer->rows == 0)
         return(PDM_S_SUCCESS);
       list_data = (char **)list_buffer->data_ptr;

       _pdm_debug("validate value against static list", 0);
       for (i = 0; i < list_buffer->rows; i ++)
         {
         if (strcmp(attr_value, list_data[(list_buffer->columns * i) + 0]) == 0)
           {
           FOUND = TRUE;
           break;
           }
         }
       if (!FOUND)
         status = PDM_E_ENTER_VALUE_LIST;
       else 
         status = PDM_S_SUCCESS;
       }
     else if ((strcmp(data_data[(data_bufr->columns * i) + PDU_DYN_MIN_VAL_COL],
              "") != 0) || (strcmp(data_data[(data_bufr->columns * i) +
              PDU_DYN_MAX_VAL_COL], "") != 0))
       {
       if ((strcmp(datatype, "integer") == 0) || (strcmp(datatype, "smallint") 
            == 0))
         {
         sscanf(data_data[(data_bufr->columns * attr_row) +
                PDU_DYN_MIN_VAL_COL], 
                "%d", &min_num);
         sscanf(data_data[(data_bufr->columns * attr_row) + 
                PDU_DYN_MAX_VAL_COL], 
                "%d", &max_num);
         sscanf(attr_value, "%d", &attr_num);
         if ((strcmp(data_data[(data_bufr->columns * attr_row) + 
             PDU_DYN_MIN_VAL_COL], "") == 0) && (attr_num > max_num))
           {
           msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
           FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
           status = PDM_E_INVALID_INPUT;
           }
         else if (strcmp(data_data[(data_bufr->columns * attr_row) + 
                  PDU_DYN_MIN_VAL_COL], "") == 0)
           status = PDM_S_SUCCESS;
         else if ((strcmp(data_data[(data_bufr->columns * attr_row) + 
                   PDU_DYN_MAX_VAL_COL], "") == 0) && (attr_num < min_num))
           {
           msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
           FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
           status = PDM_E_INVALID_INPUT;
           }
         else if (strcmp(data_data[(data_bufr->columns * attr_row) + 
                  PDU_DYN_MAX_VAL_COL], "") == 0)
           status = PDM_S_SUCCESS;
         else if ((attr_num > max_num) || (attr_num < min_num))
           {
           msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
           FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
           status = PDM_E_INVALID_INPUT;
           }
         else
           status = PDM_S_SUCCESS;
         }
       else if (strcmp(datatype, "real") == 0)
         {
         sscanf(data_data[(data_bufr->columns * attr_row) + 
                PDU_DYN_MIN_VAL_COL], "%lf", &real_min);
         sscanf(data_data[(data_bufr->columns * attr_row) + 
                PDU_DYN_MAX_VAL_COL], "%lf", &real_max);
         sscanf(attr_value, "%lf", &real_num);
         if ((strcmp(data_data[(data_bufr->columns * attr_row) + 
              PDU_DYN_MIN_VAL_COL], "") == 0) && (real_num > real_max))
           {
           msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
           FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
           status = PDM_E_INVALID_INPUT;
           }
         else if (strcmp(data_data[(data_bufr->columns * attr_row) + 
                  PDU_DYN_MIN_VAL_COL], "") == 0)
           status = PDM_S_SUCCESS;
         else if ((strcmp(data_data[(data_bufr->columns * attr_row) + 
                   PDU_DYN_MAX_VAL_COL], "") == 0) && (real_num < real_min))
           {
           msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
           FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
           status = PDM_E_INVALID_INPUT;
           }
         else if (strcmp(data_data[(data_bufr->columns * attr_row) +
                  PDU_DYN_MAX_VAL_COL], "") == 0)
           status = PDM_S_SUCCESS;
         else if ((real_num > real_max) || (real_num < real_min))
           {
           msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
           FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
           status = PDM_E_INVALID_INPUT;
           }
         else
           status = PDM_S_SUCCESS;
         }
       else
         {
         sscanf(data_data[(data_bufr->columns * attr_row) + 
                PDU_DYN_MIN_VAL_COL], "%lf", &doub_min);
         sscanf(data_data[(data_bufr->columns * attr_row) + 
                PDU_DYN_MAX_VAL_COL], "%lf", &doub_max);
         sscanf(attr_value, "%lf", &doub_num);
         if ((strcmp(data_data[(data_bufr->columns * attr_row) + 
              PDU_DYN_MIN_VAL_COL], "") == 0) && (doub_num > doub_max))
           {
           msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
           FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
           status = PDM_E_INVALID_INPUT;
           }
         else if (strcmp(data_data[(data_bufr->columns * attr_row) + 
                  PDU_DYN_MIN_VAL_COL], "") == 0)
           status = PDM_S_SUCCESS;
         else if ((strcmp(data_data[(data_bufr->columns * attr_row) + 
                   PDU_DYN_MAX_VAL_COL], "") == 0) && (doub_num < doub_min))
           {
           msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
           FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
           status = PDM_E_INVALID_INPUT;
           }
         else if (strcmp(data_data[(data_bufr->columns * attr_row) + 
                  PDU_DYN_MAX_VAL_COL], "") == 0)
           status = PDM_S_SUCCESS;
         else if ((doub_num > doub_max) || (doub_num < doub_min))
           {
           msg = (char *)PDUtranslate_message(PDM_E_ENTER_VALUE_IN_RANGE);
           FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
           status = PDM_E_INVALID_INPUT;
           }
         else
           status = PDM_S_SUCCESS;
         }
       }
     else if (PDU_func_buffer)
       {
       status = PDUcheck_for_function(attr_name, &function_name, 
                                      PDU_func_buffer);
       _pdm_status("PDUcheck_for_function", status);

       if (status == PDM_S_SUCCESS)
         status = PDM_E_FAILURE; 
       else
         status = PDM_S_SUCCESS;
        }
     return(status);
   }

int PDUcheck_file_permissions()

  {
  long status;
  int status1;
  char local_file_path[256];
  struct stat file_status;

  _pdm_debug("In the function PDUcheck_file_permissions", 0);

  strcpy(local_file_path, "");
  strcpy(local_file_path, refresh->act_filename);
  _pdm_debug("checking files <%s> for r--r--r-- permissions", local_file_path);

  status = stat(local_file_path, &file_status);

  _pdm_debug("mode = <%d>", (char *)file_status.st_mode);
  if (file_status.st_mode == 33060)
    status1 = FALSE;
  else 
    status1 = TRUE;

  return(status1);
  }

int PDUget_param_data(catalog)

char *catalog;

  {
  int status;
  int sts;
  int i;
  int max_rows;
  int err_code;
  int status_col;
  char query[256];
  char *output_str = NULL;
  char *ptr = NULL;
  char *macrorev = NULL;
  char *macrocat = NULL;
  char *macropart = NULL;
  char *macrolib = NULL;
  char *row = NULL;
  char **data_data = NULL;
  char **status_data = NULL;
  MEMptr buffer = NULL;
  MEMptr status_buffer = NULL;

  _pdm_debug("PDUget_param_data", 0);

  /* check and make sure catalog name is valid */
  if (catalog == NULL)
    return(PDM_E_CAT_NULL);
  else if (strcmp(catalog, "") == 0)
    return(PDM_E_CAT_NULL);

  if (PDUmacro_lib_list)
    {
    status = MEMbuild_array(PDUmacro_lib_list);
    _pdm_status("MEMbuild_array", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    data_data = (char **) PDUmacro_lib_list->data_ptr;
    for ( i = 0; i < PDUmacro_lib_list->rows; i++)
      {
      if (strcmp(catalog, data_data[(PDUmacro_lib_list->columns + 0) * i]) == 0)
        {
        status = PDM_S_SUCCESS;
        break;
        }
      else
        status = PDM_E_CATALOG_NOT_FOUND;
      }

    if (status == PDM_S_SUCCESS)
      return(status);
    }
  else
    {
    status = PDUformat_macro_bufr(&PDUmacro_lib_list);
    _pdm_status("PDUformat_macro_bufr", status);
    if (status != PDM_S_SUCCESS)
      return(status);
     }

  /* get macro_part and macro rev for catalog and copy files */
  
  sprintf(query, "select p_macrocat, p_macropartno, p_macrorev from pdmparamloc where n_catalogname = '%s'", catalog);
  _pdm_debug("string for query = <%s>", query);

   sts = RISquery(query, &max_rows, &output_str, &err_code); 
  
  if (sts < 0)
    return (PDM_E_MACRO_NOT_FOUND);
  
  _pdm_debug("output_str = <%s>", output_str);
  ptr = strtok(output_str,"~");
  macrocat = (char *)malloc(strlen(ptr) + 1);
  strcpy(macrocat, ptr);

  ptr = strtok(NULL,"~");
  macropart = (char *)malloc(strlen(ptr) + 1);
  strcpy(macropart, ptr);

  ptr = strtok(NULL,"~");
  macrorev = (char *)malloc(strlen(ptr) + 1);
  strcpy(macrorev, ptr);

  status = PDUformat_macrolib_copy_bufr(&buffer);
  _pdm_status("PDUformat_macrolib_copy_bufr", status);

  if (status != PDM_S_SUCCESS)
    return(status);
  /* write data to buffer to copy */
  row = (char *)malloc(buffer->row_size);
  memset(row, NULL, buffer->row_size);
  sprintf(row, "\1\1%s\1%s\1%s\1\1%s\1", macrocat, macropart, macrorev, "N");
  status = MEMwrite(buffer, row);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  if (row)
    free(row);

  _pdm_debug("get storage_area", 0);
  status = PDUget_storage_buffer(&PDU_storage_area);
  _pdm_status("PDUget_storage_buffer", status);

  status = PDMcopy_macro_library(storage->storage_name, buffer, &status_buffer);
  _pdm_status("PDMcopy_macro_library", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  if ((status_buffer) && (status_buffer->rows > 0))
    {
    status = MEMbuild_array(status_buffer);
    _pdm_status("MEMbuild_array",status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);
    status_data = (char **)status_buffer->data_ptr;
    PDUget_buffer_col(status_buffer, "n_status", &status_col);
    for (i = 0; i < status_buffer->rows; i++)
      {
      sscanf(status_data[(status_buffer->columns * i) + status_col], "%d", 
             &status);
      if (status != PDM_S_SUCCESS)
        break;
      }
    if (status != PDM_S_SUCCESS)
      return(status);
    }
      
  /* call function to attach macro library */
  status = PDUattach_macro_library(
                                   macrocat, 
                                   macropart,
                                   macrorev,
                                   catalog,
                                   &macrolib
                                  );
  _pdm_status("PDUattach_macro_library", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  /* write info to PDUmacro_lib_list */
  row = (char *)malloc(PDUmacro_lib_list->row_size);
  memset(row, NULL, PDUmacro_lib_list->row_size);

  sprintf(row, "%s\1%s\1%s\1%s\1%s\1", catalog, macrocat, macropart, macrorev,
          macrolib);
  status = MEMwrite(PDUmacro_lib_list, row);
  _pdm_status("MEMwrite", status);

  if (row)
    free(row);
  if (macrocat)
    free(macrocat);
  if (macrorev)
    free(macrorev);
  if (macropart)
    free(macropart);
    
  return(PDM_S_SUCCESS);
  }

void PDUstrip_dir_entry(entry)
  char    *entry;

 {
  _pdm_debug("In the PDUstrip_dir_entry function", 0);

  if (entry[strlen(entry) - 1] == ':')
     {
      /* Strip out ':' */
      *((char *)strrchr(entry, ':')) = '\0';
     }
 }

/*
 * This function converts the letters in a string from upper to lower.
 */
 int convert_tolower (string, string1)
  char *string ;
  char *string1 ;
  {
   int i ;

   for (i=0; i<strlen(string) ; i++ )
       string1[i] = tolower (string[i]) ;

   return(PDM_S_SUCCESS);
  }

/*
 * This function changes local file permissions. 
 */
 int PDUchmod (path, mode)
  char   *path;
  mode_t mode;
  {
   if (!chmod(path, mode))
      {  
       return(PDM_S_SUCCESS);
      }

   else
       {
         _pdm_debug("could not change permissions on <%s>", path);
         return(0);
       }
  }

/*
 * This function returns the full path for the seed_file of the
 * running product.
 */
 int PDUget_seed_file(seed_file)
  char **seed_file;
  {
   int found = 0;
   extern char *find_file();

   _pdm_debug("In the function PDUget_seed_file", 0);
  
   *seed_file = find_file( "seed_file", "config/", &found );

   if (found)
      {
       _pdm_debug("product seed_file full path is <%s>", *seed_file);
       return(PDM_S_SUCCESS);
      }

   else
       {
        _pdm_debug("product seed_file full path could not be found", 0);
        return(0);
       }
  }

int PDUcopyOS_file(copyOS_path, source_path, dest_path)
  char *copyOS_path;
  char *source_path;
  char *dest_path;

  {
  register int ret_status = 0;
  pid_t child = 0;
  
  _pdm_debug("PDUcopyOS_file", 0);
  _pdm_debug("copyOS_path = <%s>", copyOS_path);
  _pdm_debug("source_path = <%s>", source_path);
  _pdm_debug("dest_path = <%s>", dest_path);

#if defined (__sgi)
  if ((child = fork()) == -1)
    {
     _pdm_debug("FORK did not work",0);
     return(PDM_E_COPY_FILE);
    }
#else
  if ((child = vfork()) == -1)
    {
     _pdm_debug("VFORK did not work",0);
     return(PDM_E_COPY_FILE);
    }
#endif
  else if((child == 0)) /*child=0. Do the copyOS */
    {
     _pdm_debug("Execute the copyOS",0);

     ret_status=execlp(copyOS_path,copyOS_path,
                       source_path, dest_path,(char *)0);
     }
  if (ret_status == -1)
    {
    _pdm_debug("copyOS failed", 0);
    return(PDM_E_COPY_FILE);
    }
  if (waitpid(child,NULL,0) < 0)
    {
    _pdm_debug("Wait Error", 0);
    return(PDM_E_COPY_FILE);
    }
  _pdm_debug("Copy successful", 0);
  return(PDM_S_SUCCESS);
  }


/*
 * This function converts a form to window based on the value of the 
 * environment variavle PDM_FORM_TO_WIN.
 */
int PDUconvert_form_to_win(form)
  Form  form;
 {
  char  *(getenv) ();
  char  *env_value = NULL;
  extern short   PDU_local_perm_window;
  extern short   PDU_design_perm_window;


  _pdm_debug("In the function PDUconvert_form_to_win", 0);


  /* Does not apply for the SUN */
  #ifdef sparc
  _pdm_debug("SUN is not supported yet", 0);
  return(1);
  #endif
 

  /* Get value of environment variable PDM_FORM_TO_WIN. */
  env_value = getenv("PDM_FORM_TO_WIN");

  if (!env_value)
     {
      _pdm_debug("env. variable PDM_FORM_TO_WIN is not set", 0);
      return(1);
     }

  _pdm_debug("env_value = <%s>", env_value);

  if ( (strcmp(env_value, "MAIN") == 0) && (forms.local_files_form_id == form) )
     {
      FIf_cvrt_to_perm_win(form);
      PDU_local_perm_window = TRUE;
      return(1);
     }

  else if ((strcmp(env_value, "DESIGN") == 0) && (forms.design_form_id == form))
          {
           FIf_cvrt_to_perm_win(form);
           PDU_design_perm_window = TRUE;
           return(1);
          }

  else if (strcmp(env_value, "BOTH") == 0)
          {
           FIf_cvrt_to_perm_win(form);

           if (forms.local_files_form_id == form)
              PDU_local_perm_window = TRUE;

           else if (forms.design_form_id == form)
                   PDU_design_perm_window = TRUE;

           return(1);
          }

  else
      {
       _pdm_debug("encountered unknown case", 0);
       return(0);
      }
 }

int PDUcheck_PDU_form_display()

  {
  int disp_mod = FALSE;
  extern Form place_part_f;
  extern Form ModifyPartForm;


  _pdm_debug("PDUcheck_PDU_form_display", 0);

   if (forms.local_files_form_id)
     {
     FIf_is_displayed(forms.local_files_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("Local files form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.sort_form_id)
     {
     FIf_is_displayed(forms.sort_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("sort form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.part_operations_form_id)
     {
     FIf_is_displayed(forms.part_operations_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("part operations form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.seed_form_form_id)
     {
     FIf_is_displayed(forms.seed_form_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("seed file form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.rev_assy_form_id)
     {
     FIf_is_displayed(forms.rev_assy_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("define assy form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.single_list_form_id)
     {
     FIf_is_displayed(forms.single_list_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("single list form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.mcf_list_form_id)
     {
     FIf_is_displayed(forms.mcf_list_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("mcf list form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.cat_name_form_id)
     {
     FIf_is_displayed(forms.cat_name_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("catalog name form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.cat_attr_form_id)
     {
     FIf_is_displayed(forms.cat_attr_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("catalog attr form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.dynamic_attr_form_id)
     {
     FIf_is_displayed(forms.dynamic_attr_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("dynamic attribute form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.part_list_form_id)
     {
     FIf_is_displayed(forms.part_list_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("parts list form displayed", 0);
       return(disp_mod);
       }
     } 
   if (forms.topdown_form_id)
     {
     FIf_is_displayed(forms.topdown_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("topdown form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.report_form_id)
     {
     FIf_is_displayed(forms.report_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("reports form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.copy_file_form_id)
     {
     FIf_is_displayed(forms.copy_file_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("copy file form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.design_options_form_id)
     {
     FIf_is_displayed(forms.design_options_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("design options form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.sort_options_form_id)
     {
     FIf_is_displayed(forms.sort_options_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("sort options form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.bom_contents_form_id)
     {
     FIf_is_displayed(forms.bom_contents_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("bom contents form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.file_list_form_id)
     {
     FIf_is_displayed(forms.file_list_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("file list form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.parts_list_form_id)
     {
     FIf_is_displayed(forms.parts_list_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("parts list form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.parametric_catalog_form_id)
     {
     FIf_is_displayed(forms.parametric_catalog_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("parametric catalog form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.change_symbology_form_id)
     {
     FIf_is_displayed(forms.change_symbology_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("change symbology form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.parametric_parts_form_id)
     {
     FIf_is_displayed(forms.parametric_parts_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("parametricy parts form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.design_parts_form_id)
     {
     FIf_is_displayed(forms.design_parts_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("design parts form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.part_file_list_form_id)
     {
     FIf_is_displayed(forms.part_file_list_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("part file list form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.cancel_list_form_id)
     {
     FIf_is_displayed(forms.cancel_list_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("cancel list form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.where_used_form_id)
     {
     FIf_is_displayed(forms.where_used_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("where used form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.define_lib_form_id)
     {
     FIf_is_displayed(forms.define_lib_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("define lib form displayed", 0);
       return(disp_mod);
       }
      }
   if (forms.origin_list_form_id)
     {
     FIf_is_displayed(forms.origin_list_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("origin list form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.class_cat_form_id)
     {
     FIf_is_displayed(forms.class_cat_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("class catalog form id", 0);
       return(disp_mod);
       }
     } 
   if (forms.assembly_display_form_id)
     {
     FIf_is_displayed(forms.assembly_display_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("assembly display form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.ex_file_form_id)
     {
     FIf_is_displayed(forms.ex_file_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("ex file form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.flag_form_id)
     {
     FIf_is_displayed(forms.flag_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("flag form displayed", 0);
       return(disp_mod);
       }
     }
   if (forms.move_state_form_id)
     {
     FIf_is_displayed(forms.move_state_form_id, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("move state form displayed", 0);
       return(disp_mod);
       }
     }
   if (place_part_f)
     {
     FIf_is_displayed(place_part_f, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("part selection form displayed", 0);
       return(disp_mod);
       }
     }
   if (ModifyPartForm)
     {
     FIf_is_displayed(ModifyPartForm, &disp_mod);
     if (disp_mod)
       {
       _pdm_debug("Modify Part Form", 0);
       return(disp_mod);
       }
     }
   _pdm_debug("no PDU form displayed", 0);
  return(0);
  } 
    
/* ALR   This function was written to be used by the ems hooks functions.
   If another object space is being brought up then the design form or
   utilitites form needs to be erased. */

void Check_displayed_forms()
{
 int is_displayed;
 int is_collapsed;

  is_displayed = 0;
  is_collapsed = 0;

  if (forms.local_files_form_id != 0)
  {
    FIf_is_displayed(forms.local_files_form_id,&is_displayed);
    if (is_displayed)
    {
     FIf_is_collapsed(forms.local_files_form_id,&is_collapsed);
     if (!is_collapsed)
       FIf_erase(forms.local_files_form_id);
    }
  }
  if (forms.design_form_id != 0)
  {
    FIf_is_displayed(forms.design_form_id,&is_displayed);
    if (is_displayed)
    {
      FIf_is_collapsed(forms.design_form_id,&is_collapsed);
      if (!is_collapsed)
        FIf_erase(forms.design_form_id);
    }
  }
  if (forms.assembly_display_form_id != 0)
  {
    FIf_is_displayed(forms.assembly_display_form_id,&is_displayed);
    if (is_displayed)
    {
      FIf_is_collapsed(forms.assembly_display_form_id,&is_collapsed);
      if (!is_collapsed)
        FIf_erase(forms.assembly_display_form_id);
    }
  }
} 

/* 2/7/96 MJG - TR 139526084 */
/* Written to support referenced TR */

short PDUis_part_in_buffer(cat, part, rev, buffer)
char   *cat;
char   *part;
char   *rev;
MEMptr buffer;
{
   int status = PDM_S_SUCCESS;
   short found = FALSE;
   int cat_col = 0;
   int part_col = 0;
   int rev_col = 0;
   int row = 0;
   char  **data;

   _pdm_debug("in the function PDUis_part_in_buffer", 0);

   status = MEMbuild_array(buffer);
   _pdm_status("MEMbuild_array", status);
 
   PDUsetup_buffer(buffer, ROW, &data);

   PDUget_buffer_col(buffer, "n_catalogname", &cat_col);
   PDUget_buffer_col(buffer, "n_itemname", &part_col);
   PDUget_buffer_col(buffer, "n_itemrev", &rev_col);

   for (row = 0; row < buffer->rows; ++row)
      {
      if ((strcmp(cat, data[(buffer->columns * row) + cat_col]) == 0) &&
          (strcmp(part, data[(buffer->columns * row) + part_col]) == 0) &&
          (strcmp(rev, data[(buffer->columns * row) + rev_col]) == 0))
        {
        _pdm_debug("part found in buffer", 0);
        found = TRUE;
        break;
        }
      }

   if (!found)
     _pdm_debug("part is not in buffer", 0);
     
   return(found);
}
