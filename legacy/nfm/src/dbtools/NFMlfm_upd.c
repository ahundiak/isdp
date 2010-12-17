#include "machine.h"
#include <stdio.h>



/************************************************************************
*									*
*			NFMlfm_update                                   *
*									*
* This procedure will update the local file manager table ( nfmsafiles) *
* based on the flag sent by user					*
* Validity of data and action is the user's responsibility		*
*									*
* Input:								*
*									*
*	1. MEMptr input_list; List of all the attributes to be added/   *
*          deleted/updated along with the values.			*
*	   Notes: 1. Insert needs all the attributes in nfmsafiles	*
*		     table						*
*		  2. Delete needs attributes that uniquely identify	*
*		     a row(s). If no attributes are passed in the 	*
*                    result is unpredictable. ( Depends on the database)*
*		  3. Change needs the attributes that uniquely identify *
*		     row(s) to be changed and the attributes to be      *
*		     changed in those rows. The following attributes    *
*		     cannot be changed.					*
*			a.	n_sano					*
*			b.	n_filename				*
*			c.	n_catalogno				*
*			d.	n_itemno				*
*			e.	n_filenum				*
*			e.	n_fileversion				*
*									*
*	2. long flag;	The flag specifies action to be taken		*
*			0 ---> Bad Value				*
*			NFM_LFM_INSERT ---> Add to NFMSAFILE table	*
*			NFM_LFM_DELETE ---> Delete from NFMSAFILE    *
*						table			*
*			NFM_LFM_CHANGE ---> Change  values		*
*									*
************************************************************************/

/* Application include files */
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "NFMapi.h"
#include "ERR.h"
#include "RPSdef.h"


/* Function specific #defines */
#define SQL_STR_SIZE            2048
#define STR_SIZE                1024


/* External variables */


long NFMlfm_update(input_list,flag )
	long flag ;
	MEMptr input_list ;
{
/* Internal variables */
	long status,and_flag1,and_flag2,i,j,count ;
	char *fname="NFMupdate_lfm" ;
	char **data , **column, **format ;
	char sql_str[SQL_STR_SIZE], temp_str1[STR_SIZE],temp_str2[STR_SIZE] ;

	_NFMdebug((fname,"input_list address <%x> flag <%d>\n",input_list,flag));
/* Validate data */
	if(input_list == (MEMptr ) 0)
	{
		ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","input_list");
		_NFMdebug((fname,"Input list pointer is NULL \n"));
		return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
	if (flag != NFM_LFM_INSERT && flag != NFM_LFM_DELETE && flag!= NFM_LFM_CHANGE )
	{
		ERRload_struct(NFM,NFM_E_BAD_VALUE,"%s%d","flag",flag);
		_NFMdebug((fname,"Bad value for flag = <%d>\n",flag));
		return(NFM_E_BAD_VALUE);
	}

/* Build an array for the MEMbuffer */

	status = MEMbuild_array ( input_list ) ;
	if(status != MEM_S_SUCCESS )
	{
		_NFMdebug((fname,"Cannot MEMbuild array for input_list status = <0x%.8x>\n",status)) ;
		ERRload_struct(NFM,NFM_E_MEM,"");
		return(NFM_E_MEM);
	}
/* Set the data and column_ptr */
	data = (char **)input_list->data_ptr;
	column = (char **)input_list->column_ptr ;
	format = (char **)input_list->format_ptr ;

/* Initialize query string */
	temp_str1[0]=temp_str2[0] = 0;
	switch(flag)
	{
		case NFM_LFM_INSERT: /* INSERT */
			for(j=0;j< input_list->rows; j++)
			{
			and_flag1 = 0;
			count= input_list->rows * j ;
			strncpy(sql_str,"INSERT into nfmsafiles ",SQL_STR_SIZE-1);
			strcpy(temp_str1,"(");
			strcpy(temp_str2,"(");
			for(i=0 ; i < input_list->columns ; i++)
			{
				if(and_flag1> 0)
				{
					strncat(temp_str1,",",STR_SIZE-1);
					strncat(temp_str2,",",STR_SIZE-1);
				
				}
				strncat(temp_str1,column[i],STR_SIZE-1);
				if (! strncmp (format [i], "char",     4))
				{
					strncat(temp_str2,"'" , STR_SIZE - 1);
					strncat(temp_str2,data[count+i],STR_SIZE-1);
					strncat(temp_str2,"'" , STR_SIZE - 1);
				}
				else 
				{
				   if(strlen(data[count+i]) > 0 )
					strncat(temp_str2,data[count+i],STR_SIZE-1);
				   else
					strncat(temp_str2,"0",STR_SIZE-1);
				}
				and_flag1 = 1;
			}
			strncat(temp_str1,")");
			strncat(temp_str2,")");
			strncat (sql_str,temp_str1,SQL_STR_SIZE );
			strncat (sql_str," values ",SQL_STR_SIZE );
			strncat (sql_str,temp_str2,SQL_STR_SIZE );
			if((status=SQLstmt(sql_str))!=SQL_S_SUCCESS)
			{
				ERRload_struct(NFM,NFM_E_UPDATE_LFM,"%s","Insert");
				_NFMdebug((fname,"Update LFM failed for Insert\
status = <0x%.8x>\nsql_str <%s>\n",NFM_E_UPDATE_LFM,sql_str));
				return(NFM_E_UPDATE_LFM) ;
			}
			}
			break;
		case NFM_LFM_DELETE: /* DELETE */
			for(j=0;j< input_list->rows; j++)
			{
			and_flag1 = 0;
			count= input_list->rows * j ;
			strncpy(sql_str,"DELETE from  nfmsafiles ",SQL_STR_SIZE-1);
			strcpy(temp_str1,"");
			for(i=0 ; i < input_list->columns ; i++)
			{
				if(!strcmp(column[i],"n_sano") ||
				   !strcmp(column[i],"n_filename") ||
				   !strcmp(column[i],"n_catalogno") ||
				   !strcmp(column[i],"n_itemno") ||
				   !strcmp(column[i],"n_filenum") )
			{
				if(and_flag1> 0)
					strncat(temp_str1," AND " ,STR_SIZE-1);
				strncat(temp_str1,column[i],STR_SIZE-1);
				strncat(temp_str1," = ",STR_SIZE-1);
				if (! strncmp (format [i], "char",     4))
				{
					strncat(temp_str1,"'" , STR_SIZE - 1);
					strncat(temp_str1,data[count+i],STR_SIZE-1);
					strncat(temp_str1,"'" , STR_SIZE - 1);
				}

				else strncat(temp_str1,data[count+i],STR_SIZE-1);
				and_flag1 = 1;
			}
			}
			strncat (sql_str," WHERE ",SQL_STR_SIZE );
			strncat (sql_str,temp_str1,SQL_STR_SIZE );
			if((status=SQLstmt(sql_str))!=SQL_S_SUCCESS)
			{
				ERRload_struct(NFM,NFM_E_UPDATE_LFM,"%s","DELETE");
				_NFMdebug((fname,"Update LFM failed for Delete\
status = <0x%.8x>\nsql_str <%s>\n",NFM_E_UPDATE_LFM,sql_str));
				return(NFM_E_UPDATE_LFM) ;
			}
			}
			break;
		case NFM_LFM_CHANGE: /* CHANGE  */
			for(j=0;j< input_list->rows; j++)
			{
			and_flag1 = 0;
			and_flag2 = 0;
			count= input_list->rows * j ;
			strncpy(sql_str,"UPDATE  nfmsafiles SET ",SQL_STR_SIZE-1);
			strcpy(temp_str1,"");
			for(i=0 ; i < input_list->columns ; i++)
			{
				if(!strcmp(column[i],"n_sano") ||
				   !strcmp(column[i],"n_filename") ||
				   !strcmp(column[i],"n_catalogno") ||
				   !strcmp(column[i],"n_itemno") ||
				   !strcmp(column[i],"n_filenum") )
			{
				if(and_flag1 > 0)
					strncat(temp_str1," AND " ,STR_SIZE-1);
				strncat(temp_str1,column[i],STR_SIZE-1);
				strncat(temp_str1," = ",STR_SIZE-1);
				if (! strncmp (format [i], "char",     4))
				{
					strncat(temp_str1,"'" , STR_SIZE - 1);
					strncat(temp_str1,data[count+i],STR_SIZE-1);
					strncat(temp_str1,"'" , STR_SIZE - 1);
				}

				else strncat(temp_str1,data[count+i],STR_SIZE-1);
				and_flag1 = 1;
			}
			else
			{
				if(strlen(data[count+i]) <= 0 ) continue ;
				if(and_flag2 > 0)
					strncat(temp_str2," , " ,STR_SIZE-1);
				strncat(temp_str2,column[i],STR_SIZE-1);
				strncat(temp_str2," = ",STR_SIZE-1);
				if (! strncmp (format [i], "char",     4))
				{
					strncat(temp_str2,"'" , STR_SIZE - 1);
					strncat(temp_str2,data[count+i],STR_SIZE-1);
					strncat(temp_str2,"'" , STR_SIZE - 1);
				}

				else strncat(temp_str2,data[count+i],STR_SIZE-1);
				and_flag2 = 1;
			}
			}
			strncat (sql_str,temp_str2,SQL_STR_SIZE );
			strncat (sql_str," WHERE ",SQL_STR_SIZE );
			strncat (sql_str,temp_str1,SQL_STR_SIZE );
			if((status=SQLstmt(sql_str))!=SQL_S_SUCCESS)
			{
				ERRload_struct(NFM,NFM_E_UPDATE_LFM,"%s","DELETE");
				_NFMdebug((fname,"Update LFM failed for Delete\
status = <0x%.8x>\nsql_str <%s>\n",NFM_E_UPDATE_LFM,sql_str));
				return(NFM_E_UPDATE_LFM) ;
			}
			}

			break;
		default:
			ERRload_struct(NFM,NFM_E_BAD_VALUE,"%s%d","flag",flag);
			_NFMdebug((fname,"Bad value for flag = <%d>\n",flag));
			return(NFM_E_BAD_VALUE);
			break;
	}


	_NFMdebug((fname,"EXIT SUCCESS\n"));
	return(NFM_S_SUCCESS);
}


