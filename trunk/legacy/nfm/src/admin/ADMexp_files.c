#include "machine.h"
#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>
#include <varargs.h>
#include "MSGstruct.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "NETerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

extern MSGptr NETmsg_ptr;

long ADMfind_export_files (type,output_buffer)
  char      *type;
  MEMptr	*output_buffer;
  {
	long	status;

	/*  Local functions  */

	long	NFMfind_files ();
	long	NFMsort_buffer ();

	/*  External functions  */

	long	MEMopen ();
	long	MEMwrite_format ();
	long	MEMclose ();
        static char *fname = "NETLs_nodes_nfme";

	/*  Open output_buffer  */
/*	
	strcpy(type,"nfme_");
	type[5]='\0';
  */   
        _NFMdebug ((fname, "THIS is Node name <%s>\n", type));

	if ((status = MEMopen (output_buffer, MEM_SIZE)) != MEM_S_SUCCESS)
	  {
		_NFMdebug ((fname,"MEMopen = <0x%.8x>\n", status));
		status = NFM_E_MEM;
		ERRload_struct(NFM,status,"",NULL);
		return (status);
	  }

         _NFMdebug ((fname, "MEMopen <%d>\n", status));

	if ((status = MEMwrite_format
		(*output_buffer, "nodename", "char(25)")) != MEM_S_SUCCESS)
	  {
		MEMclose (output_buffer);
		_NFMdebug ((fname,"MEMwrite_format = <0x%.8x>\n", status));
		status = NFM_E_MEM;
		ERRload_struct(NFM,status,"",NULL);
		return (status);
	  }

         _NFMdebug ((fname, "MEMwrite <0x%.8x>\n", status));
/* HP-PORT IGI 25 Aug 94 */
#if  ( defined( OS_SUNOS ) || defined( OS_SOLARIS )  || defined (OS_SCO_UNIX) || defined(OS_HPUX))
        /* Replaced call to NFMfind_files in directories /usr/lib/nodes/owned
           and /usr/lib/nodes/local by call to NFMget_entries for SUN with
           'owned' as first argument. So this takes environments from
           NFMowne.dat which are local environments. Difference between 'local'
           and 'owned' is not understood. If this distinction is made clear, 
           add another call with 'local' as first argument. So that the
           environment list contains both 'local' and 'owned'environments.
           SSRS - 3/12/93 - 4/12/93
        */
        if ((status = NFMget_entries ("owned",  type,  *output_buffer))!= NFM_S_SUCCESS)
        {
            MEMclose (output_buffer);
            _NFMdebug ((fname, "NFMfind_files = <0x%.8x>\n",  status));
            return (status);
        }
#else
	/*  Get all files in the owned directory  */

	if ((status = NFMfind_files
	("/usr/lib/nodes/owned", type, *output_buffer)) != NFM_S_SUCCESS)
	  {
		MEMclose (output_buffer);
		_NFMdebug ((fname,"NFMfind_files = <0x%.8x>\n", status));
		return (status);
	  }

         _NFMdebug ((fname, "NFMfind_files= <0x%.8x>\n", status));        

        /*  Get all files in the local directory  */

        if ((status = NFMfind_files
             ("/usr/lib/nodes/local", type, *output_buffer)) != NFM_S_SUCCESS)
        {
            MEMclose (output_buffer);
            _NFMdebug ((fname,"NFMfind_files = <0x%.8x>\n", status));
            return (status);
        }
#endif

         _NFMdebug ((fname, "NFMfind_files= <0x%.8x>\n", status));


	/*  Sort the buffer alphabetically   */

	if ((status = NFMsort_buffer (*output_buffer)) != NFM_S_SUCCESS)
	  {
		MEMclose (output_buffer);
		_NFMdebug ((fname,"NFMsort_buffer = <0x%.8x>\n", status));
		return (status);
	  }

	_NFMdebug((fname,"returning NFM_S_SUCCESS <0x%.8x>\n", NFM_S_SUCCESS));
	return (NFM_S_SUCCESS);
  }


