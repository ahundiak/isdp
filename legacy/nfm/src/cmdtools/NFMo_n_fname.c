#include "machine.h"
/************************************************************************
*			NFMo_n_fname					*
*	This procedure retrieves the old and new file name based on     *
*	catalog number and file number					*
************************************************************************/
#include <stdio.h>
#include "NFMerrordef.h"
#include "NFMsacdef.h"
#include "NFMdef.h"
#include "ERR.h"
#include "DEBUG.h"


long NFMo_n_fname(user_id,cat_no,file_no,old_name,new_name)
	long user_id,cat_no,file_no;
	char *old_name,*new_name;
/* CALLING PROGRAM RESPONSIBLE TO ENSURE ENOUGH SPACE IN THE NAMES */
{
	long status;
	char *fname="NFMo_n_fname";

	_NFMdebug((fname,"Entry>>user_id  %d  cat_no  %d fileno\
  %d old file name  %s new file name  %s\n",user_id,cat_no,file_no,
old_name,new_name));
	if(cat_no < 0)
	{
		_NFMdebug((fname,"Catalog number less than 0 \n"));
		status=ERRload_struct(NFM,NFM_E_BAD_CATALOG,"");
		if(status !=ERR_S_SUCCESS)
			_NFMdebug((fname,"ERRload_struct status <0x%.8x>\n",status));
		return(NFM_E_BAD_CATALOG);
	}
	if(file_no <0)
	{
		_NFMdebug((fname,"File number less than 0 \n"));
		status=ERRload_struct(NFM,NFM_E_FAILURE,"");
		if(status !=ERR_S_SUCCESS)
			_NFMdebug((fname,"ERRload_struct status <0x%.8x>\n",status));
		return(NFM_E_FAILURE);
	}
	if((status=NFMold_file_name(user_id,cat_no,file_no,old_name))!=NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Cannot obtain old file name\n"));
		status=ERRload_struct(NFM,NFM_E_BAD_FILE_NAME,"");
		if(status !=ERR_S_SUCCESS)
			_NFMdebug((fname,"ERRload_struct status <0x%.8x>\n",status));
		return(NFM_E_BAD_FILE_NAME);
	}
	if((status=NFMnew_file_name(user_id,cat_no,file_no,new_name))!=NFM_S_SUCCESS)
	{
/* NFMnew_file_name loads the error struct */
		_NFMdebug((fname,"Cannot obtain new file name\n"));
		return(status);
	}
	_NFMdebug((fname,"SUCCESSFUL\n"));
	return(NFM_S_SUCCESS);
}
