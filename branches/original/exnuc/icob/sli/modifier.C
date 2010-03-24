/* -------------------  sli_modifier  --------------------------------*/
#include <sli.h>

sli_modifier ( str )
  char		* str;
{
  str_rec	* srec_ptr;
  extern   char * calloc( );

  if ( cur_sym )
    {
      srec_ptr = (str_rec *) calloc ( 1, sizeof(str_rec) + strlen(str));
      if ( ! srec_ptr )
        {
          fprintf(stderr,
	    "slic: sli_modifier() -- No dynamic memory available\n\n");
          exit(1);
        }
      strcpy ( srec_ptr->str, strip_quotes ( str ));
      _COB_append_to_list ( srec_ptr, list, cur_sym->strs );
    }
}
