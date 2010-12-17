/******************************************************************************

Doc:	utl_mount

	Copyright (c) 1992
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source:	utl_mount.c

Author:	Jeff Silvaggi

Date:	29-JUN-1989

SDM Number:

Description:	This function checks to see if a remote file
	system is mounted.  If not, then the shell is called to mount
	the file system.

Examples:
	status = utl_mount( node, filename, lpath )

Return Status:
	 0 = Successful completion
	-1 = Error

History:
	01-02-91  jms	Modified to use a 16 character remote file system
			name and to check for an invalid length.
	07-29-91  jms	Modified to handle VAX file systems
	09-04-91  jms	Modified to use Internet address for node compare
	03-18-92  jms	Modified to be a stand-alone utility function
	08-17-92  jms	Modified to prevent simultaneous mount point allocation
	08-17-92  jms	Modified to re-use existing mount points
******************************************************************************/
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/utsname.h>
#include <sys/ipc.h>
#include <sys/stat.h>
#include "utl.h"
#include "dmc_ums.h"

utl_resources *utl_mount_addr;	/* Address of mounted resource shared memory */
int utl_mount_id=0;		/* Id of mounted resource shared memory */

utl_mount( node, file, lpath )
char *node;			/* I - Node name where file resides */
char *file;			/* I - Complete path to file */
char *lpath;			/* O - Local path name of file */
{
int x, num1, num2, ret;
int id, addr, bytes, flags;
char *ptr, r_filsys[16], l_filsys[16];
char cmd[80], t_path[80], net_addr[80];
char fname[80];
static char my_addr[30]="";
struct utsname node_info;	/* Node information structure */
struct utl_mpts *rsrc;		/* Mounted resource table entry */
struct stat sb;

utldbg( utl_dbg, UTL_INDENT, "Entering utl_mount...node <%s>  file <%s>\n", node, file);

/* Set this nodes address if not already set */
if( my_addr[0] == 0 )
{
  uname( &node_info );
  
  if( get_tcp( node_info.nodename, my_addr ) )
  {
    utl_process_error_var( DMC_E_ADDRESS_LOOKUP, UTL_BOTH_MSG, __FILE__, __LINE__, "%s", node_info.nodename );
    return( -1 );
  }
}

/* Determine file Internet address */
if( get_tcp( node, net_addr ) )
{
  utl_process_error_var( DMC_E_ADDRESS_LOOKUP, UTL_BOTH_MSG, __FILE__, __LINE__, "%s", node );
  return( -1 );
}

utldbg( utl_dbg, UTL_SAMELVL, "local <%s>  file <%s>\n", my_addr, net_addr );

/* If file is on this node, just copy filename and return */
if( strcmp( net_addr, my_addr ) == 0 )
{
  strcpy( lpath, file );
  utldbg( utl_dbg, UTL_UNINDENT, "Leaving utl_mount .. path <%s>\n", lpath);
  return( 0 );
}

strcpy( fname, file );

/* If VAX file system */
ptr = strchr( fname, ':' );
if( ptr )
{
  *ptr = 0;
  sprintf( r_filsys, "/%s", fname );

  strcpy( t_path, ++ptr );

  /* Parse file path */
  ptr = strchr( t_path, '[' );
  if( ptr )
  {
    *ptr = '/';

    ptr = strchr( t_path, ',' );
    if( ptr )
    {
      sscanf( t_path, "/%d,%d]", &num1, &num2 );
      ptr = strchr( t_path, ']' );
      strcpy( cmd, ++ptr );
      sprintf( t_path, "/%.3d%.3d%s", num1, num2, cmd );
    }
    else
    {
      ptr = strchr( t_path, ']' );
      if( ptr ) *ptr = 0;
    
      /* Replace periods "." */
      ptr = strchr( t_path, '.' );
      while( ptr )
      {
        *ptr = '/';
        ptr = strchr( ptr, '.' );
      }
    
      /* Complete filename */
      ptr = strchr( t_path, 0 );
      strcpy( cmd, t_path );
      strcat( cmd, ++ptr );
      strcpy( t_path, cmd );
    }
  }
  ptr = t_path;
}
else	/* Otherwise UNIX file system */
{
  ptr = fname;
  ptr = strchr(++ptr, '/');
  if(ptr == 0)
  {
    utl_process_error_var( DMC_E_INVALID_PATH, UTL_BOTH_MSG, __FILE__, __LINE__, "%s", fname );
    return(-1);
  }
  
  x = ptr - fname;
  if( x > 14 )
  {
    utl_process_error_var( DMC_E_BAD_SYSNAME, UTL_BOTH_MSG, __FILE__, __LINE__, "" );
    return(-1);
  }

  memset(r_filsys, 0x00, 16);
  memcpy(r_filsys, fname, x);
}

/* If not already attached to resource shared memory, attach it */
bytes = 0;
if( utl_mount_id == 0 )
{
  /* Attempt to get shared memory id */
  flags = 0666 | IPC_CREAT;
  id = shmget( UTL_RESRC_KEY, 0, flags );

  /* If it does not exist, create it */
  if( id == -1 )
  { 
    /* Create shared memory */
    bytes = sizeof( utl_resources );
    flags = 0666 | IPC_CREAT;
    id = shmget( UTL_RESRC_KEY, bytes, flags );
    if( id == -1 )
    { 
      utl_process_error_var( DMC_E_SHM_CREATE, UTL_BOTH_MSG, __FILE__, __LINE__, "%d", errno );
      return(-1);
    }
  }

  /* Attach the shared memory segment */
  addr = shmat( id, 0, 0 );
  if ( addr == -1 )
  { 
    utl_process_error_var( DMC_E_SHM_ATTACH, UTL_BOTH_MSG, __FILE__, __LINE__, "%d", errno );
    shmctl( id, IPC_RMID, 0 );
    return(-1);
  }

  /* Set global data and initialize resource structure */
  utl_mount_id = id;
  utl_mount_addr = (utl_resources *)addr;
  if( bytes ) memset( utl_mount_addr, 0, bytes );
}
  
/* Wait until no other mounts are happening */
while( utl_mount_addr->lock )
  sleep( 1 );

/* Set mount lock */
utl_mount_addr->lock = 1;

/* Determine if remote file system is already mounted */
rsrc = utl_mount_addr->utl_mpts;
for( x = 0; x < UTL_MAX_RESOURCES; x++,rsrc++ )
{
  if( rsrc->node[0] )
  {
    if( strcmp(rsrc->net_addr, net_addr) == 0 && strcmp(rsrc->r_filsys, r_filsys) == 0 )
    {
      strcpy(lpath, rsrc->l_filsys);
      strcat(lpath, ptr);
      utldbg( utl_dbg, UTL_UNINDENT, "Leaving utl_mount .. path <%s>\n", lpath);
      utl_mount_addr->lock = 0;
      return(0);
    }
  }
}

/* Find an open resource */
rsrc = utl_mount_addr->utl_mpts;
for( x = 0; x < UTL_MAX_RESOURCES && rsrc[x].node[0]; x++ );

/* If none were available, attempt to unmount and try again */
if( x >= UTL_MAX_RESOURCES )
{
  utl_umount();
  for( x = 0; x < UTL_MAX_RESOURCES && rsrc[x].node[0]; x++ );
}

/* Error if there are still no available resources */
if( x >= UTL_MAX_RESOURCES )
{
  utl_process_error_var( DMC_E_RESOURCE, UTL_BOTH_MSG, __FILE__, __LINE__, "" );
  utl_mount_addr->lock = 0;
  return(-1);
}

#if !(defined(SCO_UNIX) || defined(SPARC_SOLARIS) || defined(INTEL_SOLARIS))
/* See if node is up and running */
if( ping( node ) )
{
  utl_process_error_var( DMC_E_NO_RESPONSE, UTL_BOTH_MSG, __FILE__, __LINE__, "%s", node );
  utl_mount_addr->lock = 0;
  return(-1);
}
#endif

/* Make local file system name */
sprintf(l_filsys, "/dmands%d", x);

/* Get status of file */
ret = stat( l_filsys, &sb );

/* If file exists */
if( ret == 0 )
{
  utldbg( utl_dbg, UTL_SAMELVL, "%s exists...removing\n", l_filsys );

  /* Attempt to remove it */
  if( unlink( l_filsys ) )
  {
    /* If it's mounted, attempt to unmount it */
    if( errno == EBUSY && sb.st_mode & 040000 )
    {
      utldbg( utl_dbg, UTL_SAMELVL, "%s busy...attempting umount\n", l_filsys );
      sprintf( cmd, "/etc/umount %s >/dev/null 2>&1", l_filsys );
      system( cmd );
      if( unlink( l_filsys ) )
      {
        utl_process_error_var( DMC_E_FS_INUSE, UTL_BOTH_MSG, __FILE__, __LINE__, "%s", l_filsys );
        utl_mount_addr->lock = 0;		/* Re-set mount lock */
        return(-1);
      }
    }
    else
    {
      utl_process_error_var( DMC_E_RMDIR, UTL_BOTH_MSG, __FILE__, __LINE__, "%d%s", errno, l_filsys );
      utl_mount_addr->lock = 0;			/* Re-set mount lock */
      return(-1);
    }
  }
}

/* Create root directory entry for file system */
if( mkdir(l_filsys, 0777) )
{
  utl_process_error_var( DMC_E_MKDIR, UTL_BOTH_MSG, __FILE__, __LINE__, "%d%s", errno, l_filsys );
  utl_mount_addr->lock = 0;
  return(-1);
}

/* Mount remote file system */
sprintf(cmd, "/etc/mount -f NFS,soft %s:%s %s >/dev/null 2>&1", node, r_filsys, l_filsys);
utldbg( utl_dbg, UTL_SAMELVL, "l_filsys = %s\n", l_filsys );
utldbg( utl_dbg, UTL_SAMELVL, "mount cmd = %s\n", cmd );

if( ret = system( cmd ) )
{
  utl_process_error_var( DMC_E_MOUNT, UTL_BOTH_MSG, __FILE__, __LINE__, "" );
  rmdir( l_filsys );
  utl_mount_addr->lock = 0;
  return(-1);
}

/* Store entry in resource table */
rsrc = &utl_mount_addr->utl_mpts[x];
strcpy( rsrc->node, node );
strcpy( rsrc->net_addr, net_addr );
strcpy( rsrc->r_filsys, r_filsys );
strcpy( rsrc->l_filsys, l_filsys );
utl_mount_addr->lock = 0;

/* Copy local name to callers buffer and return */
strcpy( lpath, rsrc->l_filsys );
strcat( lpath, ptr );
utldbg( utl_dbg, UTL_UNINDENT, "Leaving utl_mount .. path <%s>\n", lpath );
return( 0 );
} /* end of utl_mount() */
