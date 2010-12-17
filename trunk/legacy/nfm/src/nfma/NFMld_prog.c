#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

/***************************************************************************
 *                                                                         *
 *   Function: NFMload_program.                                            *
 *   Date:     January 22, 1990                                            * 
 *                                                                         *
 *             This function is used to load program executable file       *
 *             into NFM.                                                   *  
 *             This function calls NFMadd_program.                         * 
 *                                                                         *
 ***************************************************************************/

long NFMload_program (user_id, sa_name, program_name, program_desc, file_name)
  long	  user_id;
  char    *sa_name;     /* storage_area name. */ 
  char    *program_name;
  char    *program_desc;
  char    *file_name;
{
  static char *fname = "NFMload_program" ;
  char   lock_tables[100];
  long   status;

  _NFMdebug ((fname, "Storage area name  = <%s> : Program Name = <%s> : Program Desc <%s> : File Name <%s>\n", 
	      sa_name, program_name, program_desc, file_name));

  /* transaction processing will be handled by "add_item", and "check_in"
     functions.  As of 3/21/91.   B.W.                                   */

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
     _NFMdebug ((fname, "NFMstop_transaction: status = <0x%.8x>",status));
     return (status);
  }


  sprintf (lock_tables, "NFMINDEX, %s", "nfmprograms") ;
  status = NFMlock_table (lock_tables) ;
  if (status != NFM_S_SUCCESS)
  {
     ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
     _NFMdebug ( (fname, "NFMlock_table: 0x%.8x", NFM_E_FAILURE) );
     return (NFM_E_FAILURE);
  }

  /* Call NFMadd_program to add the program to NFM. */

  status = NFMadd_program (user_id, sa_name, program_name, program_desc, 
							file_name); 
  if (status != NFM_S_SUCCESS)
  {
     NFMrollback_transaction (0);
     _NFMdebug ((fname, "NFMadd_program: status = <0x%.8x>\n",status));
     return (status); 
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
     ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
     status = NFM_E_FAILURE;
     return (status);
  }

  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
     _NFMdebug ((fname, "NFMstart_transaction: status = <0x%.8x>",status));
     return (status);
  }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS); 
}

