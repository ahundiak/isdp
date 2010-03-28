#include <stdio.h>
#include "OMlimits.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "expriv.h"
#include "ex.h"


int	GRget_cmds (search_string, num_cmds, list)

char  search_string[];  /* i - Search string			*/
long  *num_cmds;	  /* o - Number of eligible commands	*/
char  *list[];	  /* o - Command list. Can be NULL	*/

/* Doc: AP_get_cmds

   Abstract:
	
   History:

	Date		Who		Why
	---------	------		----------------------------------
	11-02-90	kk		Creation
    10/01/01    dhm     Modified to place in Grnuc

   Return Status:


   Examples:

*/

{
  char  cmd_name[64];
  long  i;
  int   match;
  extern struct EX_cmd_cntrl  *EX_cmdlist_ptr;
  struct EX_cmd_cntrl  *cmd_cntrl;


  cmd_cntrl = EX_cmdlist_ptr;
  *num_cmds = 0;

  for ( i = 0; i < cmd_cntrl->no_of_cmd; i++)
  {
    strncpy( cmd_name, " ", 64);

    strncpy( cmd_name, cmd_cntrl->cmd[i].command_name_ptr,
             cmd_cntrl->cmd[i].command_nbytes );

    match = GRis_substr(search_string, cmd_name);

    if (match)
    {
      if ( list ) strcpy( list[*num_cmds], cmd_name );
	  (*num_cmds)++;
    }

  }

  return(1);
}


int	GRis_substr(search_string, full_string)

char  search_string[];	/* i - Search for	*/
char  full_string[];		/* i - Search in	*/

{
  long  slen, flen, i, ii, j, found, match;
  char  schar, fchar;

  slen = strlen(search_string);
  flen = strlen(full_string);

  if ( slen > flen ) return(0);

  found = 0;

  for ( i = 0; (i <= (flen-slen)) && (! found) ; i++ )
  {
    ii = i;
    j = 0;

    do
    {
      fchar = full_string[ii];  ii++;
      schar = search_string[j++];

      match = ((fchar == schar) || 
               (fchar < 96 && fchar == schar - 32) ||
               (fchar > 96 && fchar == schar + 32));

    } while ( (j < slen)  && match );

    if ( match ) found = 1;
  }

  return(found);
}
