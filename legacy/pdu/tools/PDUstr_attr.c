#include	<stdio.h>
#include	<PDUerror.h>
#include	<PDUextdef.h>
#include	<PDUstr.h>
#include	<PDUproto.h>

int PDUstring_to_attributes(string, count, list)
  char			*string;
  int			*count;
  char			***list;
  {
  /*int			status;      APOGEE */
    int			char_index;
    int			attr_len;
    int			attr_count = 0;
    char		**attr_list = NULL; 

    char_index = 0;
    
    while( char_index < (strlen(string)))
      {
        while ((string[char_index] == ' ') || (string[char_index] == ','))
	  ++char_index;

        while((string[char_index] != ',') && (char_index < strlen(string)))
          ++char_index;

        ++attr_count;
      }      
        
    *count = attr_count;
    attr_list = (char **) malloc (attr_count * sizeof(char *));
    memset(attr_list, NULL, (attr_count * sizeof(char *)));

    char_index = 0;
    attr_count = 0;

    while ((char_index < (strlen(string))) && (attr_count < *count))
      {
        while (string[char_index] == ' ')
	  ++char_index;
                
        for (attr_len = 0; ((string[char_index + attr_len] != ',') && 
			    ((char_index + attr_len) < strlen(string)) &&
                             (attr_count < *count)); ++attr_len);
        
        attr_list[attr_count] = (char *) malloc (attr_len + 1);
        memset(attr_list[attr_count], NULL, (attr_len + 1));

        strncpy(attr_list[attr_count], (string + char_index), attr_len);

        char_index = char_index + attr_len + 1;

        ++attr_count;
      }      

   *list = attr_list;        
 
   return(PDM_S_SUCCESS);

  }
