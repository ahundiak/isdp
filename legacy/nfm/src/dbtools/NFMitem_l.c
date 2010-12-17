#include "machine.h"
#include "DEBUG.h"

/***************************************************************************
*				NFMitem_list			   *
*									   *
*	This function generates a list of items from all the catalogs in   *
*	the table NFMCATALOGS  performing a join between catalog and 	   *
*	f_catalog to get n_itemname, n_itemno and n_cisano for all items   *
*	that have n_archivestate!='A' , n_coout in (I,O,TI,TO) and         *
*	n_cifilename  in ('',"",null)					   *
***************************************************************************/
#include <stdio.h>
#include "MEMstruct.h"
#include "WFstruct.h"
#include "NFMerrordef.h"
#include "MEMerrordef.h"
#include "RPSdef.h"
#include "NFMsacdef.h"
#include "NFMdef.h"
#include "ERR.h"



long NFMitem_list(out_buffer_list,cat_name ,cat_no,sort_name )
	MEMptr	*out_buffer_list;
	char *cat_name,*sort_name,*cat_no;
{
	long status = 0,offset=0,i,j,k;
	char temp[SIZE],qry_str[5*STR_SIZE],return_str[2*STR_SIZE];
	char n_itemrev[SIZE],n_fileversion[SIZE];
	char n_cofilename[SIZE];
	char n_saname[SIZE];
	char n_fileno[SIZE],n_cisano[SIZE],n_itemno[SIZE] , n_itemname[SIZE];
	char n_cifilename[SIZE],n_itemnum[SIZE];
	char *fname="NFMgen_item_list";
	char **data;
	MEMptr attr_list = MEMNULL;
	long return_status= NFM_S_SUCCESS;
	return_status= NFM_S_SUCCESS;
	strcpy(n_saname,"n_saname");
	strcpy(n_itemrev,"n_itemrev");
	strcpy(n_cofilename,"n_cofilename");
	strcpy(n_fileno,"n_fileno");
	strcpy(n_cisano,"n_cisano");
	strcpy(n_itemno,"n_itemno");
	strcpy(n_itemname,"n_itemname");
	strcpy(n_itemnum,"n_itemnum");
	strcpy(n_cifilename,"n_cifilename");
	strcpy(n_fileversion,"n_fileversion");
	attr_list = MEMNULL ;

	_NFMdebug((fname,"Entry\t>>\n\t\tout_buffer_list\t%d\n\t\tcatalog name\
\t%s\n\t\tcatalog number\t%s\n\t\tsort name\t%s\n" ,
out_buffer_list,cat_name,cat_no,sort_name));
/* check if the list pointer is NULL */
	if(out_buffer_list == MEMPTRNULL)
	{
		_NFMdebug((fname,"Output buffer pointer Address is <%d>\n",out_buffer_list));
/*>>>>>>>>>>>>>>Error processor Error here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","output buffer pointer");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);

	}
/* make sure that the list is NULL  at entry point*/
	if(*out_buffer_list != MEMNULL)
	{
		_NFMdebug((fname,"<<<<WARNING>>>> MEMclose on Output buffer <%d>\n",*out_buffer_list));
/* set out_buffer_list to NULL */
		MEMclose(out_buffer_list);
	}
	if((strlen(cat_name)) <= 0)
	{
		_NFMdebug((fname,"Catalog name is null\n"));
                status = ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","catalog name");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_VALUE);
	}
	if((strlen(cat_no)) <= 0)
	{
		_NFMdebug((fname,"Catalog number is null\n"));
                status = ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","catalog number");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_VALUE);
	}
/* Get the n_name for n_fileno , n_cisano , n_itemno , n_itemname */
/*	sprintf(qry_str, "SELECT  n_nfmname , n_name from nfmattributes where \
n_tableno in (SELECT n_tableno from nfmtables where n_tablename='%s' or n_tablename='f_%s')",cat_name,cat_name);
	if((status = SQLquery (qry_str , &attr_list,MEM_SIZE))!=SQL_S_SUCCESS)
	{
		_NFMdebug((fname,"<<WARNING>>\t\tInternal Error\n\t\t\t\
Cannot get n_name from nfmattributes table. Using defaults\n"));
        }
        else
        {
                if((status=MEMbuild_array(attr_list))!=MEM_S_SUCCESS)
                {
                        _NFMdebug((fname,"<<WARNING>>\t\tInternal Failure MEMbuild_array failed on\n\t\t\tn_name list. Using n_name"));
                }
                else
                {
                        data = (char **)attr_list->data_ptr;
			for(i=0; i < attr_list->rows ; i+=2)
			{
				if(strcmp(data[i],"n_fileno")== 0)
strncpy(n_fileno,data[i+1],SIZE-1);
				else if(strcmp(data[i],"n_cisano")== 0)
strncpy(n_cisano,data[i+1],SIZE-1);
				else if(strcmp(data[i],"n_itemno")== 0)
strncpy(n_itemno,data[i+1],SIZE-1);
				else if(strcmp(data[i],"n_itemname")== 0)
strncpy(n_itemname,data[i+1],SIZE-1);
				else if(strcmp(data[i],"n_itemnum")== 0)
strncpy(n_itemnum,data[i+1],SIZE-1);
				else if(strcmp(data[i],"n_cofilename")== 0)
strncpy(n_cofilename,data[i+1],SIZE-1);
				else if(strcmp(data[i],"n_itemrev")== 0)
strncpy(n_itemrev,data[i+1],SIZE-1);
				else if(strcmp(data[i],"n_cifilename")== 0)
strncpy(n_cifilename,data[i+1],SIZE-1);
				else if(strcmp(data[i],"n_fileversion")== 0)
strncpy(n_cifilename,data[i+1],SIZE-1);
			}
                }
        }
        MEMclose(&attr_list);
*/
/* Generate the SQL string and perform the SQL query */
	_NFMdebug((fname,"Get list of items for catalog <%s>\n",cat_name));
	sprintf(qry_str,"SELECT %s.%s , %s.%s,f_%s.%s,f_%s.%s,f_%s.%s,\
nfmstoragearea.%s,f_%s.%s FROM %s, f_%s , nfmstoragearea WHERE \
%s.%s = f_%s.%s AND f_%s.%s = nfmstoragearea.n_sano ", 
cat_name,n_itemname,cat_name,n_itemrev,cat_name,n_fileversion,cat_name,n_cofilename,cat_name,
n_cifilename,n_saname,cat_name,n_fileno,cat_name,cat_name,cat_name,n_itemno,cat_name,n_itemnum,
cat_name,n_cisano);
/* Get the sort_string */
        if(strcmp(sort_name,"")!=0)
        {
                status = NFMget_string_criteria(66635,sort_name,RPS_SORT_TYPE,
return_str);
                if(status!=NFM_S_SUCCESS)
                {
                        _NFMdebug((fname,"Sort string failed for %s status=<0x%.8x>\n",sort_name,status));
                        status = ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",sort_name);
                        if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                        return(NFM_E_BAD_CRITERIA);

                }
                strcat(qry_str, " ORDER BY ");
                strcat(qry_str,return_str);
        }

        else
        {
                sprintf(return_str," %s %s.%s","ORDER BY ",cat_name,n_itemname);
                strcat(qry_str,return_str);
        }

	status = SQLquery(qry_str, out_buffer_list, 4*MEM_SIZE);
	if(status==SQL_I_NO_ROWS_FOUND)
	{
		_NFMdebug((fname,"No items in catalog <%s>\n",cat_name));
		MEMclose(out_buffer_list);
		return(status);
	}
	else if (status !=SQL_S_SUCCESS)
	{
		_NFMdebug((fname,"List Item failed for catalog %s status\=<0x%.8x>\n",cat_name,status));
		MEMclose(out_buffer_list);
		return(status);
	}
	if((status = MEMbuild_array(*out_buffer_list))!=MEM_S_SUCCESS)
	{
		_NFMdebug((fname,"MEM build array failed\n"));
		MEMclose(out_buffer_list);
		return_status = status;
                status = ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                        return(NFM_E_MEM);
	}
	data = (char **) (*out_buffer_list)->data_ptr;
	offset= (*out_buffer_list)->columns;
	j=0;
	for(i=0; i < (*out_buffer_list)->rows; i++)
	{
		if(strlen(data[j+4]) <=0)
		{
			status = NFMnew_file_name(66635,atol(cat_no),atol(data[j+6]),temp);
			if(status !=NFM_S_SUCCESS)
			{
				_NFMdebug((fname,"Failed to get Filename\n"));
			}
			else
			{
				status=MEMwrite_data(*out_buffer_list,temp,i+1,5);
				if(status!=MEM_S_SUCCESS)
				_NFMdebug((fname,"MEMwrite_data Failed\n"));

			}
		}
		j+=offset;
	}
	
	_NFMdebug((fname,"Exit >> SUCCESSFUL\n"));
	return(return_status);
}
