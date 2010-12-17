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

/* Added for SCO/SUN - MVR 22/11/93 */
/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
        long    NFMget_entries();       
#endif

long ADMLs_nodes_nfmexp (type,output_buffer)
  char       *type;
  MEMptr	 *output_buffer;
  {
	long	status;

	/*  Local functions  */

	long	NFMfind_files ();
	long	NFMsort_buffer ();

	/*  External functions  */

	long	MEMopen ();
	long	MEMwrite_format ();
	long	MEMclose ();
    static char *fname = "ADMLs_nodes_nfmexp";

	/*  Open output_buffer  */
/*	
	strcpy(type,"nfms_");
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

	/*  Get all files in the owned directory  */

/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
        /* Added the code to get information from NFMenv.dat and NFMser.dat */
        /* for SCO/SUN - MVR 22.11.93                                         */
        /* added 'heard' as first argument - SSRS - 4/12/93                 */

        if ((status = NFMget_entries ("heard",type,   *output_buffer)) != NFM_S_SUCCESS)
        {
                MEMclose (output_buffer);
                _NFMdebug ((fname,  "NFMget_entries = <0x%.8x>\n",  status));
                return (status);

        }
#else
	if ((status = NFMfind_files
	("/usr/lib/nodes/heard", type, *output_buffer)) != NFM_S_SUCCESS)
	  {
		MEMclose (output_buffer);
		_NFMdebug ((fname,"NFMfind_files = <0x%.8x>\n", status));
		return (status);
	  }

         _NFMdebug ((fname, "NFMfind_files= <0x%.8x>\n", status));        

#endif
	/*  Sort the buffer alphabetically   */

	if ((status = NFMsort_buffer (*output_buffer)) != NFM_S_SUCCESS)
	  {
		MEMclose (output_buffer);
		_NFMdebug ((fname,"NFMsort_buffer = <0x%.8x>\n", status));
		return (status);
	  }

	_NFMdebug ((fname, "returning NFM_S_SUCCESS <0x%.8x>\n", NFM_S_SUCCESS));
	return (NFM_S_SUCCESS);
  }


