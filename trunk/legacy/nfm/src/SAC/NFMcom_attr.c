#include "machine.h"

/****************************************************************************
*									*
*			NFMcom_attr_list					*
*									*
*	This procedure returns the list of attributes common to all
*	 catalogs in nfmcatalogs					*
*	For each attribute in the table the n_name  is		*
*	returned							*
*									*
************************************************************************/

#include <stdio.h>
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "SQLerrordef.h"
#include "NFMsacdef.h"
#include "DEBUG.h"
#include "ERR.h"

#define MEM_INT_SIZE	15


NFMcom_attr_list(user_id,cat_list,out_list)
	long user_id;
	MEMptr cat_list,*out_list;
{
 long status,size,count=0,table_no, i=0,j=0,no_of_catalogs=0,done_flag = 0;
 MEMptr sql_list = MEMNULL;
 char *sql_str,*cond_str,*return_str,temp[SIZE];
 char *fname="NFMcom_attr_list";
 char **data,**format,**column;
	_NFMdebug((fname,"Entry >>\n\t\tuser_id\t%d\n\t\tcatalog list\t%d\n\t\t\
Output list address\t%d\n",user_id,cat_list,out_list));

/*	Check if user id is NULL */
	if(user_id <= 0)
	{
		_NFMdebug((fname,"Bad user_id <%d>\n",user_id));
/*	Error processor string here */
		status = ERRload_struct(NFM,NFM_E_BAD_USER_ID,"%d",user_id);
		if(status!=ERR_S_SUCCESS)
		_NFMdebug((fname,"ERRLoad_struct status =<0x%.8x>\n",status));
		return(NFM_E_BAD_USER_ID);
	}
/* check if the pointer to the Catalog list is NULL */
	if(cat_list == MEMNULL)
	{
		_NFMdebug((fname,"Catalog list address is <%d>NULL\n",cat_list));
/*	Error processor string here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","catalog list");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
/* check if the pointer to the MEMptr is NULL */
	if(out_list == MEMPTRNULL)
	{
		_NFMdebug((fname,"Output list pointer address is <%d>NULL\n",out_list));
/*	Error processor string here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","output buffer ptr");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
/* Close the memory associated with out_list */
	MEMclose(out_list);

/*	build the array of catalog list */
        if((status=MEMbuild_array(cat_list)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMbuild_array failed for catalog list\
                 status = <0x%.8x>\n" , status));
		status=ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MEM);
        }

/* generate the data lists */
        data = (char **) cat_list->data_ptr;
/* generate the condition string */
	no_of_catalogs = cat_list->rows;
/* check if there are any catalogs in catalog list 
   There must be atleast one catalog */
	if(no_of_catalogs < 1)
	{
		_NFMdebug((fname,"Number of catalogs  %d < 1\n",no_of_catalogs));
                status = ERRload_struct(NFM,NFM_E_NO_CATALOGS,"%s","Empty list");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NO_CATALOGS);
	}
	size = (MEM_INT_SIZE + 5) * no_of_catalogs + SIZE + 5 ;
	if((cond_str =(char *)malloc(size))==(char *)0)
	{
		_NFMdebug((fname,"Failed to malloc <%d> bytes fro condition string\n",size));
                status = ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MALLOC);
	}
	size = size +2 * SIZE ;
	if((sql_str =(char *)malloc(size))==(char *)0)
	{
		_NFMdebug((fname,"Failed to malloc <%d> bytes for SQL string\n",size));
		free(cond_str);
                status = ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MALLOC);
	}
	strcpy(cond_str,"n_tableno IN (");
/* check the size of condition string */
/* catalog list has both the n_catalogname and n_catalogno = n_tableno */
        for ( i=1 ; i <cat_list->rows*cat_list->columns; i+=2)
	{
		if(i> 1) strcat (cond_str , ",");
		strcat(cond_str , data[i]);
	}
	strcat(cond_str ," )");
/*	check the size of sql string */
/* generate query to get  n_name from all the tables */
	sprintf(sql_str,
	"SELECT %s FROM %s WHERE %s %s",
        "n_name " , "NFMATTRIBUTES" , cond_str ,
	 " AND n_read = 'Y' ORDER BY n_name");

	status = SQLquery(sql_str , &sql_list , 2*MEM_SIZE);
	if(status!=SQL_S_SUCCESS)
	{
		_NFMdebug((fname,"SQL query failed to get attribute list status=<0x%.8x>\n",status));
		MEMclose(&sql_list);
		free(sql_str);
		free(cond_str);
                if(status == SQL_I_NO_ROWS_FOUND)
                {

                        status = ERRload_struct(NFM,NFM_E_BAD_ATTR,"%s","NFMcom_attr_list");
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                        return(NFM_E_BAD_ATTR);
                }
                else
                {
                        status = ERRload_struct(NFM,NFM_E_SQL_QUERY,"%s","NFMcom_attr_list");
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                        return(NFM_E_SQL_QUERY);
                }
	}
/* Free the memory associated with sql_str and cond_str */
		free(sql_str);
		free(cond_str);
/* check for common attributes */
/*      build the array of SQL list */
        if((status=MEMbuild_array(sql_list)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMbuild_array failed for sql_list\
                 status = <0x%.8x>\n" , status));
		MEMclose(&sql_list);
		status=ERRload_struct(NFM,NFM_E_MEM,"");
		if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MEM);
        }

/* generate the data lists */
        data = (char **) sql_list->data_ptr;
	column =( char **) sql_list->column_ptr;
	format = (char **) sql_list->format_ptr;
/* check for data in the sql list */
	if(sql_list->rows < 1)
	{
                _NFMdebug((fname,"Number of rows %d < 1\n",sql_list->rows));
		MEMclose(&sql_list);
		status=ERRload_struct(NFM,NFM_E_NO_CATALOGS,"%s","Empty list");
		if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NO_CATALOGS);
	}	
        size = 0;
        if (! strncmp (format [0], "integer",  7)) size = 15;
        else if (! strncmp (format [0], "smallint", 8)) size = 15;
        else if (! strncmp (format [0], "double",   6)) size = 50;
        else if (! strncmp (format [0], "real",     4)) size = 50;
        else if (! strncmp (format [0], "char",     4))
                 sscanf (format [0], "%5s%d", temp, &size);
        if(size <= 0)
        {
               _NFMdebug((fname,"Failed to get length of attribute  0"));
		MEMclose(&sql_list);
		status=ERRload_struct(NFM,NFM_E_FAILURE,"%s%s","SIZE OF","Size 0 ");
		if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_FAILURE);
        }
	size = size + SIZE ;
	if((return_str =(char *)malloc(size))==(char *)0)
	{
		_NFMdebug((fname,"Failed to malloc <%d> bytes fro condition string\n",size));
		MEMclose(&sql_list);
                status = ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MALLOC);
	}

		
/* Open a memory structure */
        if((status=MEMopen(out_list,4*MEM_SIZE)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMopen failed for out_list\
                 status = <0x%.8x>\n" , status));
		MEMclose(&sql_list);
		free(return_str);
		status=ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MEM);
        }
/* write the format */
	if((status=MEMwrite_format(*out_list , column[0] , format[0]))!=MEM_S_SUCCESS)
	{	
               	_NFMdebug((fname,"MEMwrite_format failed for out_list\
       	          status = <0x%.8x>\n" , status));
		MEMclose(&sql_list);
		MEMclose(out_list);
		free(return_str);
		status=ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MEM);
	}
	done_flag=0;
	for(i=0 ; (i< sql_list->rows ) && !done_flag; i++)
	{
		if(i== (sql_list->rows  - 1)) done_flag = 1;
		else if((strcmp(data[i],data[i+1]))> 0) done_flag = 1;
		count = 1;

		for(j=i+1 ; (j< sql_list->rows ) && !done_flag; j++)
		{
			if((strcmp(data[i] , data[j])) == 0) count++;
			if(count == no_of_catalogs) done_flag = 2;
		}
		if(count == no_of_catalogs) done_flag = 2;
		if(done_flag == 2)
		{
			sprintf(return_str,"%s\1",data[i]);
			if((status=MEMwrite(*out_list , return_str))!=MEM_S_SUCCESS)
			{	
                	_NFMdebug((fname,"MEMwrite failed for out_list\
       		          status = <0x%.8x> string=%s\n" , status,return_str));
			MEMclose(&sql_list);
			MEMclose(out_list);
			free(return_str);
			status=ERRload_struct(NFM,NFM_E_MEM,"");
	                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
       		         return(NFM_E_MEM);
			}

			done_flag = 0;
		}	
	}
	_NFMdebug((fname,"Exit >> SUCCESSFUL\n"));
	MEMclose(&sql_list);
	free(return_str);
	return(NFM_S_SUCCESS);
}
