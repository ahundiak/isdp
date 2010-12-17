/******************************************************************************

Doc:	utl_umount

	Copyright (c) 1992
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source:	utl_umount.c

Author:	Jeff Silvaggi

Date:	29-JUN-1989

SDM Number:

Description:	This function checks to see if a remote file
	system is still in use. If not, it will be umounted
	and removed from the resource table.

Examples:
	status = utl_umount()

Return Status:
	 0 = Successful completion
	-1 = Error

History:
	03-19-92  jms	Modified to be a stand-alone utility function
******************************************************************************/
#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include "utl.h"
#include "dmc_ums.h"

extern utl_resources *utl_mount_addr;	/* Address of mounted resource shared memory */
extern int utl_mount_id;		/* Id of mounted resource shared memory */

utl_umount()
{
struct utl_mpts *rsrc;			/* Mounted resource table entry */
struct shmid_ds sm;
char cmd[80];
int x, in_use;

/* If no resources, just return */
if( utl_mount_id == 0 ) return(0);

utldbg( utl_dbg, UTL_INDENT, "Entering utl_umount\n" );

/* Attempt to umount all currently mounted file systems */
in_use = 0;
rsrc = utl_mount_addr->utl_mpts;
for( x = 0; x < UTL_MAX_RESOURCES; x++, rsrc++ )
{
  if( rsrc->node[0] )		/* If mounted */
  {
    /* Unmount remote file system */
    sprintf( cmd, "/etc/umount %s >/dev/null 2>&1", rsrc->l_filsys );
    if( system( cmd ) )
    {
      in_use++;
      continue;
    }

/*
    if( umount( rsrc->l_filsys ) )
    {
      if( errno == EBUSY )
        continue;
      else
      {
        fprintf(errlog,"UTL_UMOUNT: Error umounting remote file system %s errno = %d\n", rsrc->l_filsys, errno );
        continue;
      }
    }
*/

    /* Remove root directory entry for file system */
    if( rmdir( rsrc->l_filsys ) )
    {
      utl_process_error_var( DMC_E_RMDIR, UTL_BOTH_MSG, __FILE__, __LINE__, "%d%s", errno, rsrc->l_filsys );
      return( -1 );
    }
    
    /* Remove entry from resource table */
    memset( rsrc, 0, sizeof( struct utl_mpts ) );
  }
}

/* If there are still resources in use, don't detach */
if( in_use )
{
  utldbg( utl_dbg, UTL_UNINDENT, "Leaving utl_umount...with <%d> mount points in use\n", in_use );
  return( 0 );
}

/* Detach shared memory */
shmdt( utl_mount_addr );

/* If no other processes are attached, remove shared memory */
shmctl( utl_mount_id, IPC_STAT, &sm );
if( sm.shm_nattch == 0 ) shmctl( utl_mount_id, IPC_RMID, 0 );

/* Clear this processes shared memory information */
utl_mount_addr = 0;
utl_mount_id = 0;

utldbg( utl_dbg, UTL_UNINDENT, "Leaving utl_umount\n" );
return( 0 );
} /* end of utl_umount() */
