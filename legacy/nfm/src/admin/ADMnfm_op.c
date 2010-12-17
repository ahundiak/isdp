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
#include "NFIerrordef.h"
#include "NFMdef.h"
#include "ERR.h"
#include "NFMsacdef.h"
#include "DEBUG.h"
#include "NFMstruct.h"

extern MSGptr NETmsg_ptr;
extern struct NFMglobal_st NFMglobal;

long OPnodes_oper (output_buffer)
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
    char    type[10];
    int     i;
    char    **data;
    static char *fname = "OPnodes_oper";

    _NFMdebug((fname, "Enter\n"));

/*  check if the list pointer is NULL */

     if (output_buffer == MEMPTRNULL)
     {
        _NFMdebug((fname, "MEMptr list address is <%d>\n", output_buffer));

        status = ERRload_struct(NFM, NFM_E_NULL_OUTPUT_MEMPTR, "%s",
              "Output Buffer ptr");

      if(status!=ERR_S_SUCCESS)
      _NFMdebug((fname, "ERRload_struct status= <0x%.8x>\n", status));
      return(NFM_E_NULL_OUTPUT_MEMPTR);

     }

/*  make sure that the list is NULL as we will fill new info here */

    if (*output_buffer != MEMNULL)
    {

      _NFMdebug((fname, "List is non empty List=<0x%.8x>\n", *output_buffer));
      _NFMdebug((fname,  "MEMclose on List =<0x%.8x>\n", *output_buffer));
      MEMclose(output_buffer);
    }

	/*  Open output_buffer  */
	
	strcpy(type,"nfme_");
	type[5]='\0';
    
        _NFMdebug ((fname, "THIS is Node name <%s>\n", type));


	if ((status = MEMopen (output_buffer, MEM_SIZE)) != MEM_S_SUCCESS)
	  {
		_NFMdebug ((fname,"MEMopen = <0x%.8x>\n", status));
		status = NFM_E_MEM_ERR;
		ERRload_struct(NFM,status,"%s%s%s%x","MEMopen",fname, "status", status);
		return (status);
	  }

         _NFMdebug ((fname, "MEMopen <%d>\n", status));

	if ((status = MEMwrite_format
		(*output_buffer, "name", "char(14)")) != MEM_S_SUCCESS)
	  {
		MEMclose (output_buffer);
		_NFMdebug ((fname,"MEMwrite_format = <0x%.8x>\n", status));
		status = NFM_E_MEM_ERR;
		ERRload_struct(NFM,status,"%s%s%s%s","MEMwrite_format",fname,"name","name");
		return (status);
	  }

         _NFMdebug ((fname, "MEMwrite <0x%.8x>\n", status));

	/*  Get all files in the owned directory  */

/* HP-PORT IGI 25 Aug 94 */
#if (defined (OS_SUNOS) || defined( OS_SOLARIS) || defined (OS_SCO_UNIX) || defined(OS_HPUX))
    /* Getting environments from NFMenv.dat file for SUN/SCO - SSRS - 8/12/93 */
        if ((status = NFMget_entries
        ("owned", type, *output_buffer)) != NFM_S_SUCCESS)
          {
                MEMclose (output_buffer);
                _NFMdebug ((fname,"NFMget_entries = <0x%.8x>\n", status));
                return (status);
          }
#else
	if ((status = NFMfind_files
	("/usr/lib/nodes/owned", type, *output_buffer)) != NFM_S_SUCCESS)
	  {
		MEMclose (output_buffer);
		_NFMdebug ((fname,"NFMfind_files = <0x%.8x>\n", status));
		return (status);
	  }
#endif

       data = (char **) (*output_buffer)->data_ptr;
  
       for (i=0 ; i<(*output_buffer)->rows; ++i)
        {
          if (strcmp(NFMglobal.environment_name, type)==0)
             strcpy(NFMglobal.environment_name,"");
         }

         _NFMdebug ((fname, "NFMfind_files= <0x%.8x>\n", status));        

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


