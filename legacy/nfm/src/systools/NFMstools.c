#include "machine.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"
#include "NFMerrordef.h"

NFMparse_local_filename (i_name)

char *i_name;

{
  long length, b4_dot, load_w=0;
  char a_char[2];
  char *fname="NFMparse_local_filename";
  char first_8[NFM_COFILENAME+1], last_3[NFM_COFILENAME+1];
  char tstring[NFM_COFILENAME+1];

  _NFMdebug ((fname, "i_name = [%s]\n", i_name));
  strcpy (first_8, "\0"); strcpy (last_3, "\0");
  a_char[1] = '\0';
  for (length = 0, b4_dot = 1; length < strlen (i_name); length ++)
  {
    a_char[0] = i_name[length];
    if (a_char[0] == '.')
      b4_dot = 0;
    if (b4_dot && (strlen (first_8) < 8))
      strcat (first_8, a_char); 
    else if (!b4_dot && (a_char[0] != '.') && (strlen (last_3) < 3))
      strcat (last_3, a_char);
    else if (a_char[0] != '.')
    {
      _NFMdebug ((fname, "first_8 is > 8 or last_3 is > 3\n"));
      load_w = 1;
    }    
  }
  if (load_w)
  {
    sprintf (tstring, "%s.%s", first_8, last_3);
    ERRload_struct (NFM, NFM_W_FILE_NAME_TRUNC_DMM, "%s%s",
     i_name, tstring );
  }
  _NFMdebug ((fname, "successful\n"));
  return (NFM_S_SUCCESS);
}
