/* -----------------------  put_strs  --------------------------------*/
#include <sli.h>

put_strs ( slist, fp, arg1, arg2, arg3, arg4, arg5, arg6 )
  str_rec	* slist;
  FILE		* fp;
  char		* arg1;
  char		* arg2;
  char		* arg3;
  char		* arg4;
  char		* arg5;
  char		* arg6;
{
  if ( fp )
    _COB_for_list ( spp, list, slist, str_rec )
      fprintf ( fp, spp->str, arg1, arg2, arg3, arg4, arg5, arg6 );
      fputc ( '\n', fp );
    _COB_end_for_list /* ( spp ) */
} /* put_strs */
