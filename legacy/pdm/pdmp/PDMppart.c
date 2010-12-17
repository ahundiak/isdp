#include <stdio.h>
#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "NFMerrordef.h"
#include "NFMfile.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"

extern int	PDMdebug_on;
extern char PDM_DEBUG_FILE[];
static	long   status;
static	char   s[1024];


int PDMi_copy_library(user_id,catalog,
				  part_num,revision,
				  strg_bufr,n_cofilename)
long	user_id;
char	*catalog;
char	*part_num;
char	*revision;
char	*n_cofilename;
MEMptr	strg_bufr;
{
	char	**temp_data;
	char	**data;
	char	**column_ptr;
	int		i,n1;
	MEMptr	attr_bufr = NULL;
	MEMptr	data_bufr = NULL;

	PDMdebug("ENTER:PDMi_copy_library\n");
	status = MEMbuild_array(strg_bufr);
	if(status != MEM_S_SUCCESS)
    {
		sprintf(s,"%s %d \n",
		"MEMbuild_array failed ", status );
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	temp_data = (char **) strg_bufr->data_ptr;
	status = NFMprepare_item_copy(user_id,catalog,
								  part_num,revision,
								  &attr_bufr,&data_bufr);
	if(status != NFM_S_SUCCESS)
	{
		sprintf(s,"%s %d \n",
		"NFMprepare_item_copy failed ", status );
		PDMdebug(s);
		return(PDM_E_PREPARE_ITEM_COPY);
	}
	status = MEMbuild_array(data_bufr);
	if(status != MEM_S_SUCCESS)
    {
		MEMclose(&attr_bufr);MEMclose(&data_bufr);	
		sprintf(s,"%s %d \n",
		"MEMbuild_array failed ", status );
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	n1 = -1;
    data = (char **) data_bufr->data_ptr;
    column_ptr	= (char **) data_bufr->column_ptr;	
    for(i=0;i<data_bufr->columns;i++)
	{
		if(!strcmp(column_ptr[i],"n_cofilename")) n1 = i;
	}
	if(n1 == -1)
    {
		PDMdebug("Could not set offset in data_bufr\n");
		return(PDM_E_BUFFER_FORMAT);
	}
	status = NFMcomplete_item_copy(user_id,
			 temp_data[0],temp_data[1],temp_data[2],
			 temp_data[3],temp_data[4],
			 attr_bufr,data_bufr);
	if(status != NFM_S_SUCCESS)
	{
		MEMclose(&attr_bufr);MEMclose(&data_bufr);	
		sprintf(s,"%s %d \n",
		"NFMcomplete_item_copy failed ", status );
		PDMdebug(s);
		return(PDM_E_COMPLETE_ITEM_COPY);
	}
        data = (char **) data_bufr->data_ptr;
	strcpy(n_cofilename,data[n1]);
	MEMclose(&attr_bufr);
	MEMclose(&data_bufr);
	PDMdebug("EXIT:PDMi_copy_library\n");
    return(PDM_S_SUCCESS);
}

int	 PDMcopy_macrolib_file(user_id,
						 catalog,
		 				 part_num,
						 revision,
						 strg_bufr,n_cofilename)
long		user_id;
char 		*catalog;
char		*part_num;
char		*revision;
MEMptr		strg_bufr;
char            *n_cofilename;
{
        MEMptr		attach_bufr=NULL;
/* APOGEE START
	char		sql_str[512];
	char		p_parttype[2];
	int		n_itemno;
	MEMptr		new_files = NULL;
        char            *filename;
   APOGEE END */
        char            **data;

	PDMdebug("ENTER:PDMcopy_macrolib_file\n");

	/*p_parttype[0] = '\0';

	status = PDMquery_parttype(catalog,
							   part_num,
							   revision,p_parttype);
	if(status != PDM_S_SUCCESS)
	{
		sprintf("PDMquery_parttype failed %d\n",status);
		PDMdebug(s);
	}
	status = PDMquery_partno(catalog,
							 part_num,
						     revision,&n_itemno);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMquery_partno failed status %d\n",status);
		PDMdebug(s);
		return(status);
	}	

	p_parttype[0] = '\0';
	status = PDMquery_parttype(catalog,
							   part_num,
							   revision,p_parttype);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMquery_parttype failed status %d\n",status);
		PDMdebug(s);
		return(status);
	}	
	if(!strncmp(p_parttype,"N",1) || 
	   !strncmp(p_parttype,"n",1))
	{
		sprintf(s,"p_parttype is set to non-graphic\n");
		PDMdebug(s);
		return(PDM_E_PART_NONGRAPHIC);
	}
	status = NFMcheck_item(user_id,
						   catalog,
						   n_itemno,NFM_ITEM_COPY);
	if(status != NFM_S_SUCCESS)
	{
		sprintf(s,"NFMcheck_item failed status %d\n",status);
		PDMdebug(s);
		return(status);
	}
	status = PDMi_prepare_buffer1(attach_bufr);
    if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMi_prepare_buffer1 failed status %d\n",
		status); PDMdebug(s);
		return(status);
	}
    status = PDMi_find_cofilename(catalog,part_num,revision,filename);
    if(status != PDM_S_SUCCESS)
    {
		sprintf(s,"PDMi_find_cofilename failed status %d\n",
		status); PDMdebug(s);
		return(status);
    }
	sprintf(s,"%s\1%s\1%s\1%s\1%s\1\1%s\1",
	catalog,part_num,revision,p_parttype,filename,"Y");	
	status = MEMwrite(*attach_bufr,s);
    if(status != MEM_S_SUCCESS)
	{
		MEMclose(attach_bufr);
		sprintf(s,"MEMwrite failed statuis %d \n",
		status); PDMdebug(s);
		return(PDM_E_WRITE_ROW);
    }
	status = PDMcopy_file_transfers(*attach_bufr,
								    strg_bufr,&new_files);
B
	if(status != PDM_S_SUCCESS)
	{
		MEMclose(attach_bufr);
		sprintf(s,"PDMcopy_file_transfers failed status %d\n",status);
		PDMdebug(s);
		return(status);
	}
	status = PDMsend_files(user_id,*attach_bufr,strg_bufr);
	if(status != PDM_S_SUCCESS)
	{
		MEMclose(attach_bufr); MEMclose(&new_files);
		sprintf(s,"PDMsend_files failed status %d\n",status);
		PDMdebug(s);
		return(status);
	}

	status = PDMupdate_filemanager(new_files,strg_bufr,"COPY");
	if(status != PDM_S_SUCCESS)
	{
		MEMclose(attach_bufr); MEMclose(&new_files);
		sprintf(s,"PDMupdate_filemanager failed status %d\n",status);
		PDMdebug(s);
		return(status);
	}
	MEMclose(&new_files);
       */
	status = PDMcopy_atomic_file(user_id,catalog,part_num,revision,
                                     strg_bufr,-1,&attach_bufr);
	if(status != PDM_S_SUCCESS)
	{
		MEMclose(&strg_bufr); MEMclose(&attach_bufr);
		sprintf(s,"PDMcopy atomic file failed status %d\n",status);
		PDMdebug(s);
		return(status);
	}
	status = MEMbuild_array(attach_bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&strg_bufr);
		MEMclose(&attach_bufr);
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
        data = (char **)attach_bufr->data_ptr;
        strcpy(n_cofilename,data[4]);
	PDMdebug("EXIT:PDMcopy_macrolib_file\n");
    return(PDM_S_SUCCESS);
}
