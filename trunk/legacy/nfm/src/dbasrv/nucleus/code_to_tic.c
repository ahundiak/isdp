/* $Revision: 1.1 $ */
#include "dba.ext"
/* Function:	dba_code_to_tic */
int dba_code_to_tic (char_ptr)
char *char_ptr;
{
  char *tic_ptr;

  if (!char_ptr) return (0);

  for (tic_ptr=char_ptr; tic_ptr[0] != 0; ++tic_ptr)
    { if (tic_ptr[0] == 92 && tic_ptr[1] == '3' && tic_ptr[2] == '9')
      { tic_ptr[0] = 39;  strcpy (tic_ptr+1, tic_ptr+3); } }
  return (0);
}
