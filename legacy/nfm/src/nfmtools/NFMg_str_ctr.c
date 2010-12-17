#include "machine.h"
#include <stdio.h>
#include <string.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

long NFMget_string_criteria (user_id, input_string, type, output_string)
  long user_id;
  char *input_string;
  char *type;
  char *output_string;
{
  char *fname="NFMget_string_criteria";
  long   status;

  _NFMdebug((fname,"Entry: This procedure is obsolete: This procedure just\n\
loads the input string into output string and returns.Please use new search/sort\n\
criteria retrieval calls for future use\n"));

     strcpy (output_string, input_string);

  _NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
  return(NFM_S_SUCCESS);
}
