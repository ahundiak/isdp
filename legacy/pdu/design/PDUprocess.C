#include	<errno.h>
#include	<exmacros.h>
#include	<igrtypedef.h>
#include	<PDUintdef.h>

/****************************************************************************

Document:	PDUexternal_process

Description:
	This function provides the capability of forking a sub-process
	from within PDU. It uses vfork, which circumvents memory space
	problems. The parent process waits for the child process to die
	before continuing.

Algoritm:
	1. Construct argument list.
	2. Fork a child process.
	3. Child:  Execute sub-process using argument list.
	   Parent: Wait for child process to die.

Return Status:
	0 - success
	1 - fork failed or child process failed

Notes:
	Format of argument list sent to child process:
	  argv[0] - path name of external process
	  argv[1] - external request type
	  argv[2] - debug flag
	  argv[3-n] - additional arguments from PDU

History:
	01/13/89	Bill Kirk	Created
	03/27/89	Bill Kirk	Modified to use PDUget_path

*****************************************************************************/

IGRint	PDUexternal_process (type, args, argc)

  IGRint	type;			/* i - request type */
  IGRchar	**args;			/* i - argument list */
  IGRint	argc;			/* i - argument count */
  {
  IGRint	status = 0;		/* return status */
  IGRint	pid;			/* child process id */
  IGRint	stat_loc = 0;		/* child return status */
  IGRint	i, j;			/* loop indices */
  IGRchar	**argv = NULL;		/* external argument list */
  IGRchar	debug_flag[3];		/* external debug flag */
  IGRchar	request_type[3];	/* external request type */
  IGRchar	process_name[PDU_PATHNAME_SIZE];  /* path to external process */

  _pdm_debug("In function PDUexternal_process, request type = %d", type);

  /* allocate argument list for external process */
  argv = (char **) malloc ( sizeof(char *) * (argc + 4) );
  if ( !argv )  return (PDM_E_COULD_NOT_MALLOC);

  status = PDUget_search_path ( "Pdu", process_name);
  _pdm_status("PDUget_search_path", status );

  if ( 1&status  )
     {
     strcat( process_name, "bin/pdux");
     status = 0;
     }
  else
     {
     _pdm_debug ("Could not establish path to external process", 0);
     return (1);
     }

  /* extra arguments for process, request, debug */
  sprintf(request_type, "%d", type);
  sprintf(debug_flag, "%d", PDM_debug_on);

  /* construct argument list, terminate with NULL entry */
  argv[0] = process_name;
  argv[1] = request_type;
  argv[2] = debug_flag;

  for ( i = 0, j = 3; i < argc; ++i, ++j )
      argv[j] = args[i];
  argv[j] = NULL;

  switch ( type )
     {
     case PDU_EXT_NFSMOUNT:
	  _pdm_debug("Spawning child process for NFS mount", 0);
	  break;
     case PDU_EXT_NFSUNMOUNT:
	  _pdm_debug("Spawning child process for NFS unmount", 0);
	  break;
     case PDU_EXT_OSCONVERT:
	  _pdm_debug("Spawning child process for Object Space Conversion", 0);
	  break;
     }

  /* fork a child process */
#if defined (__sgi)
  pid = fork();
#else
  pid = vfork();
#endif

  /* parent/child actions after fork */
  switch ( pid )
     {
     case 0:						/* child process */
	  _pdm_debug("Ready to exec child", 0);

	  status = execv(argv[0], argv);

	  if ( status == -1 )
	     {
	     _pdm_debug("Exec from child failed, errno = %d", errno);
	     exit(1);
	     }
	  status = 1;
	  break;

     case -1:						/* parent process */
	  _pdm_debug("Fork of parent failed, errno = %d", errno);
	  status = 1;
	  break;

     default:						/* parent process */
	  _pdm_debug("Fork of parent succeeded, child pid = %d", pid);

	  /* wait for child process to finish */
pause:
	  status = wait ((int *) &stat_loc);
	  if ( status == pid )			/* correct child process returns */
	     {
	     /* echo return status from child process */
	     if ( stat_loc == 0 )
		status = 0;
	     else
		status = 1;
	     }
	  else if ( status == -1 )		/* wait failed */
	     {
	     _pdm_debug("Parent wait failed, errno = %d", errno);
	     status = 1;
	     }
	  else
	     goto  pause;			/* incorrect child returned */

	  break;
     }

  return ( status );
  }
