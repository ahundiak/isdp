#include "machine.h"
#include <stdio.h>
#include "pc.h"
#include "DEBUG.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "MEMstruct.h"
#include "NFMpcproto.h"

extern char *COMMAND_BUFFER ;

long _NFMpc_load_message (message) 
     char *message ;
{
  char *fname = "_NFMpc_load_message" ;
  long  status ;
  char mess [MAX_MESSAGE_LENGTH + 2] ;

  _NFMdebug ((fname, "ENTER\n")) ;
  if (strlen (message) > MAX_MESSAGE_LENGTH)
    {
      _NFMdebug ((fname, "string too long\n")) ;
      return (NFM_E_MESSAGE) ;
    }

  sprintf (mess, "%s\001", message) ;

  status = _NFMpc_write_row (&COMMAND_BUFFER, mess) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "pc write row failed : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (status) ;
}


long _NFMpc_load_command_error ()
{
  char *fname = "_NFMpc_load_command_error" ;
  long status ;
  char message [MAX_MESSAGE_LENGTH+2] ;

  status = ERRget_message (message) ;
  if (status != ERR_S_SUCCESS)
    {
      _NFMdebug ((fname, "ERRget_message : BAD MESSAGE :status = <0x%.8x>\n", 
		  status)) ;
      strcpy (message, "UNKNOWN ERROR CODE") ;
/*      return (status) ; */
    }

  status = PCmem_write_data (COMMAND_BUFFER, 1, 1, message) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "PC mem write data : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
