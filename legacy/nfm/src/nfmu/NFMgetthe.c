#include <stdio.h>
#include "DEBUG.h"
#include "ERR.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFTftr.h"
#include "UTIerrordef.h"


long NFMget_thesaurus ( thesaurus )

MEMptr *thesaurus;

{
  char *fname="NFMget_thesaurus";
  char file_list[1024], *strptr;
  char *tokptr, d_type[20], row_str[1024];
  long length, status;

  _NFMdebug ((fname, "ENTER\n"));

  status = NFT_get_thesaurus_list (file_list);
  if (status != UTI_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFT_get_thesaurus 0x%.8x\n", status));
    return (status);
  }
 
  _NFMdebug ((fname, "file_list [%s]\n", file_list));
  strptr = (char *) calloc (strlen(file_list) + 1, sizeof (char));
  if(strptr == (char *)0)
  {
    _NFMdebug ((fname, "Memory allocation failed for strptr\n"));
    return (NFM_E_FAILURE);
  }

  strcpy (strptr, file_list);
  _NFMdebug ((fname, "strptr [%s]\n", strptr));
  length = 0;
  while ((tokptr = (char *) strtok (strptr, "\n")) != (char *) NULL)
  {
    _NFMdebug ((fname, "tokptr [%s] length [%d]\n", tokptr, strlen(tokptr)));
    if (length < strlen(tokptr))
    {
      length = strlen (tokptr);
    }
    strptr = (char *) NULL;
  }

  if (strptr != (char *) NULL)
    free (strptr);

  _NFMdebug ((fname, "max length = %d\n", length));

  status = MEMopen (thesaurus, 512 );
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
    return (status);
  }
  else
  {
    _NFMdebug ((fname, "MEMopen successfully\n"));
  }

  sprintf (d_type, "char(%d)", length+1);

  status = MEMwrite_format (*thesaurus, "filenames", d_type);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite_format 0x%.8x\n", status));
    return (status);
  }
  else
  {
    _NFMdebug ((fname, "MEMwrite_format successfully\n"));
  }

  strptr = (char *) calloc (strlen(file_list) +1, sizeof (char));
  if(strptr == (char *)0)
  {
    _NFMdebug ((fname, "Memory allocation failed for strptr\n"));
    return (NFM_E_FAILURE);
  }
  strcpy (strptr, file_list);
  _NFMdebug ((fname, "strptr [%s]\n", strptr));
  while ((tokptr = (char *) strtok (strptr, "\n")) != (char *) NULL)
  {
    _NFMdebug ((fname, "tokptr [%s] \n", tokptr));
    sprintf (row_str, "%s\1", tokptr);

    status = MEMwrite (*thesaurus, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
  	if (strptr != (char *) NULL)
    		free (strptr);
      	return (status);
    }

    strptr = (char *) NULL;
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("thesaurus", *thesaurus, _NFMdebug_st.NFMdebug_file);
  }

  if (strptr != (char *) NULL)
    free (strptr);
 
  _NFMdebug ((fname, "EXIT successful\n"));
  return (NFM_S_SUCCESS);
}
