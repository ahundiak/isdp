/* -----------------------  strip_quotes  ----------------------------*/
#include <ode_export.h>

char * strip_quotes ( q_string )
  char	* q_string;
{
  static char	  string [_max_data_union_str + 10];

  if ( q_string [0] == '"' )
    {
      strcpy ( string, & q_string [1] );
      string [ strlen ( string ) - 1 ] = 0;
      return string;
    }
  else return q_string;
} /* strip_quotes */
