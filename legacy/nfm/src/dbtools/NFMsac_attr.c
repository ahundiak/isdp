#include "machine.h"

/************************************************************************
*									*
*			NFMsac_attr_list				*
*									*
*	This procedure returns the list of attributes common to all     *
*	 catalogs in cat_list					*
*	For each attribute in the table the n_name  is			*
*	returned							*
*									*
************************************************************************/

#include "NFMnfmsacinc.h"

NFMsac_attr_list(cat_list,src_catalog,out_list,synonym_list,cat_name_syn)
	MEMptr cat_list,*out_list,*synonym_list;
	char *src_catalog,*cat_name_syn;
{
	long status;
	int i,count,count1,count2,j,done_flag;
	char *fname="NFMsac_attr_list";
	long no_of_attr,new_cat_no,src_cat_no,size,no_of_catalogs;
	char *sql_str,*out_str,*synonym_str,temp[96];
        char **data,**format,**column;
        MEMptr sql_list = (MEMptr)0;

	_NFMdebug((fname,"Entry:Memptr: cat_list <%x>: out_list <%x>:\
synonym_list <%x>\n src_catalog <%s>:Catalog name synonym <%s>\n",cat_list,
out_list,synonym_list,src_catalog,cat_name_syn));

	src_cat_no = -1;
	no_of_attr = 0;

/* check if the pointer to the Catalog list is NULL */
	if(cat_list == (MEMptr)0)
	{
		_NFMdebug((fname,"Catalog list address is <%x>NULL\n",cat_list));
                ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","catalog list");
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
/* check if the pointer to the MEMptr is NULL */
	if(out_list == (MEMptr *)0)
	{
		_NFMdebug((fname,"Output list pointer address is <%x>NULL\n",out_list));
                ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","output buffer ptr");
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
	if(synonym_list == (MEMptr *)0)
	{
		_NFMdebug((fname,"synonym list pointer address is <%x>NULL\n",synonym_list));
                ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","synonym buffer ptr");
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
/* Close the memory associated with synonym_list */
	MEMclose(out_list);
	MEMclose(synonym_list);

/*	build the array of catalog list */
        if((status=MEMbuild_array(cat_list)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMbuild_array failed for catalog list\
                 status = <0x%.8x>\n" , status));
                ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMbuild_array",fname,"Status",status);
                return(NFM_E_MEM_ERR);
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
                ERRload_struct(NFM,NFM_E_NO_CATALOGS,"%s","Empty list");
                return(NFM_E_NO_CATALOGS);
	}
	
	size = (INTEGER + 5) * no_of_catalogs + 128 + 64 ;
	if((sql_str =(char *)malloc(size))==(char *)0)
	{
		_NFMdebug((fname,"Failed to malloc <%d> bytes for SQL string\n",size));
                ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
                return(NFM_E_MALLOC);
	}

	sprintf(sql_str,"SELECT n_name, n_tableno,n_seqno,n_synonym FROM\
 NFMATTRIBUTES WHERE n_read = 'Y' AND n_tableno in (");
	
	if(strlen(src_catalog) <= 0 ) src_cat_no = atol(data[N_CAT_NO_INDEX]);
	for(i=no_of_catalogs-1 ; i >=0; i--)
	{
		count = cat_list->columns * i;
		if(src_cat_no < 0 )
			if(!strcmp(data[count+N_CAT_NAME_INDEX],src_catalog)) src_cat_no = atol(data[count+N_CAT_NO_INDEX]);
		strcat(sql_str,data[count+N_CAT_NO_INDEX]);
		if(i > 0 ) strcat(sql_str,",");
	}
	strcat (sql_str,") ORDER BY n_seqno ");
	_NFMdebug((fname,"Sql_str <%s>\n",sql_str));
	status = SQLquery(sql_str , &sql_list , 2*MEM_SIZE);
	free(sql_str);
	if(status!=SQL_S_SUCCESS)
	{
		_NFMdebug((fname,"SQL query failed to get attribute list status=<0x%.8x>\n",status));
		MEMclose(&sql_list);
                if(status == SQL_I_NO_ROWS_FOUND)
                {

                        status = ERRload_struct(NFM,NFM_E_BAD_ATTR,"%s","NFMsac_attr_list");
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                        return(NFM_E_BAD_ATTR);
                }
                else
                {
                        status = ERRload_struct(NFM,NFM_E_SQL_QUERY,"%s","NFMsac_attr_list");
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                        return(NFM_E_SQL_QUERY);
                }
	}
/* build the common attribute list */
/* check for common attributes */
/*      build the array of SQL list */
        if((status=MEMbuild_array(sql_list)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMbuild_array failed for sql_list\
                 status = <0x%.8x>\n" , status));
		MEMclose(&sql_list);
		ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMbuild_array",fname,"status",status);
                return(NFM_E_MEM_ERR);
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
	      ERRload_struct(NFM,NFM_E_NO_COMMON_ATTRIBUTES,"%s","Empty list");
              return(NFM_E_NO_COMMON_ATTRIBUTES);
	}	
/* Create the format for out_list */
        size = 0;
        if (! strncmp (format [N_NAME_INDEX], "integer",  7)) size = 15;
        else if (! strncmp (format [N_NAME_INDEX], "smallint", 8)) size = 15;
        else if (! strncmp (format [N_NAME_INDEX], "double",   6)) size = 50;
        else if (! strncmp (format [N_NAME_INDEX], "real",     4)) size = 50;
        else if (! strncmp (format [N_NAME_INDEX], "timestamp",9)) size = 20;
        else if (! strncmp (format [N_NAME_INDEX], "char",     4))
                 sscanf (format [N_NAME_INDEX], "%5s%d", temp, &size);
        if(size <= 0)
        {
               _NFMdebug((fname,"Failed to get length of attribute n_name  0\n"));
		MEMclose(&sql_list);
		ERRload_struct(NFM,NFM_E_FAILURE,"%s%s","SIZE OF ATTRIBUTE NAME","Size 0 ");
                return(NFM_E_FAILURE);
        }
	size = size + 96 ;
	if((out_str =(char *)malloc(size))==(char *)0)
	{
		_NFMdebug((fname,"Failed to malloc <%d> bytes for out string\n",size));
		MEMclose(&sql_list);
                ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
                return(NFM_E_MALLOC);
	}

		
/* Open a memory structure */
        if((status=MEMopen(out_list,4*MEM_SIZE)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMopen failed for out_list\
                 status = <0x%.8x>\n" , status));
		MEMclose(&sql_list);
		free(out_str);
		ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMopen for out_list",
fname,"status",status);
                return(NFM_E_MEM_ERR);
        }
/* write the format */
	if((status=MEMwrite_format(*out_list , column[N_NAME_INDEX] , format[N_NAME_INDEX]))!=MEM_S_SUCCESS)
	{	
               	_NFMdebug((fname,"MEMwrite_format failed for out_list\
       	          status = <0x%.8x>\n" , status));
		MEMclose(&sql_list);
		free(out_str);
		ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMwrite_format for out_list",fname,"status",status);
                return(NFM_E_MEM_ERR);
	}
/* Create the format for synonym_list */
        size = 0;
        if (! strncmp (format [N_SYNONYM_INDEX], "integer",  7)) size = 15;
        else if (! strncmp (format [N_SYNONYM_INDEX], "smallint", 8)) size = 15;
        else if (! strncmp (format [N_SYNONYM_INDEX], "double",   6)) size = 50;
        else if (! strncmp (format [N_SYNONYM_INDEX], "real",     4)) size = 50;
        else if (! strncmp (format [N_SYNONYM_INDEX], "timestamp",9)) size = 20;
        else if (! strncmp (format [N_SYNONYM_INDEX], "char",     4))
                 sscanf (format [N_SYNONYM_INDEX], "%5s%d", temp, &size);
        if(size <= 0)
        {
               _NFMdebug((fname,"Failed to get length of synonym name  0\n"));
		MEMclose(&sql_list);
		free(out_str);
		ERRload_struct(NFM,NFM_E_FAILURE,"%s%s","SIZE OF SYNONYM NAME","Size 0 ");
                return(NFM_E_FAILURE);
        }
	size = size + 96 ;
	if((synonym_str =(char *)malloc(size))==(char *)0)
	{
		_NFMdebug((fname,"Failed to malloc <%d> bytes for out string\n",size));
		MEMclose(&sql_list);
		free(out_str);
                ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
                return(NFM_E_MALLOC);
	}

		
/* Open a memory structure */
        if((status=MEMopen(synonym_list,4*MEM_SIZE)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMopen failed for synonym_list\
                 status = <0x%.8x>\n" , status));
		MEMclose(&sql_list);
		free(synonym_str);
		free(out_str);
		ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMopen for synonym_list",
fname,"status",status);
                return(NFM_E_MEM_ERR);
        }
/* write the format */
	if((status=MEMwrite_format(*synonym_list , column[N_SYNONYM_INDEX] , format[N_SYNONYM_INDEX]))!=MEM_S_SUCCESS)
	{	
               	_NFMdebug((fname,"MEMwrite_format failed for synonym_list\
       	          status = <0x%.8x>\n" , status));
		MEMclose(&sql_list);
		free(out_str);
		free(synonym_str);
		ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMwrite_format for synonym_list",fname,"status",status);
                return(NFM_E_MEM_ERR);
        }
	done_flag=0;
	if(strlen(cat_name_syn) > 0)
	{
			sprintf(synonym_str,"%s\1",cat_name_syn);
			if((status=MEMwrite(*synonym_list , synonym_str))!=MEM_S_SUCCESS)
			{	
                	_NFMdebug((fname,"MEMwrite failed for synonym_list\
       		          status = <0x%.8x> string=%s\n" , status,synonym_str));
			MEMclose(&sql_list);
			free(out_str);
			free(synonym_str);
			ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%s","MEMwrite",fname,"synonym_str",synonym_str);
       		         return(NFM_E_MEM_ERR);
			}
	}
	for(i=0 ; (i< sql_list->rows ) && !done_flag; i++)
	{
		count1 = sql_list->columns * i;
		new_cat_no = atol ( data[count1+N_TABLE_NO_INDEX]);
		if(src_cat_no != new_cat_no ) continue;
		count = 0;

		for(j= 0 ; (j< sql_list->rows ) && !done_flag; j++)
		{
			count2 = sql_list->columns * j;
			if((strcmp(data[count1+N_NAME_INDEX] , data[count2+N_NAME_INDEX])) == 0) count++;
			if(count == no_of_catalogs) done_flag = 2;
		}
		if(done_flag == 2)
		{
			sprintf(synonym_str,"%s\1",data[count1+N_SYNONYM_INDEX]);
			sprintf(out_str,"%s\1",data[count1+N_NAME_INDEX]);
			if((status=MEMwrite(*out_list , out_str))!=MEM_S_SUCCESS)
			{	
                	_NFMdebug((fname,"MEMwrite failed for out_list\
       		          status = <0x%.8x> string=%s\n" , status,out_str));
			MEMclose(&sql_list);
			free(out_str);
			free(synonym_str);
			ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%s","MEMwrite",fname,"out_str",out_str);
       		         return(NFM_E_MEM_ERR);
			}
			if((status=MEMwrite(*synonym_list , synonym_str))!=MEM_S_SUCCESS)
			{	
                	_NFMdebug((fname,"MEMwrite failed for synonym_list\
       		          status = <0x%.8x> string=%s\n" , status,synonym_str));
			MEMclose(&sql_list);
			free(out_str);
			free(synonym_str);
			ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%s","MEMwrite",fname,"synonym_str",synonym_str);
       		         return(NFM_E_MEM_ERR);
			}

			no_of_attr++;
			done_flag = 0;
		}	
	}
	MEMclose(&sql_list);
	free(out_str);
	free(synonym_str);
	if(no_of_attr <= 0 )
	{
		status = NFM_E_NO_COMMON_ATTRIBUTES;
		_NFMdebug((fname,"Number of common attributes <%d> is < = 0\n",no_of_attr));
		ERRload_struct(NFM,status,"%d",no_of_attr);
		return(status);
	}
	_NFMdebug((fname,"Exit >> SUCCESSFUL : status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}
