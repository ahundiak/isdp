/****************************************************************************

Name
   pdmoRisStatement

Abstract
   This function allows a user to execute an sql statement on the database. 

Synopsis
  long pdmoRisStatement ( )

Description
   Input:

   Input/Output:

   Output:

   Algorithm:
   1)

Return Values

Notes

Index

Keywords
RisStmt

History
   Audra Romans Thur Aug 12 09:26:31 CDT 1993: Initial Creation
****************************************************************************/


/****************************************************************************
Include Files
****************************************************************************/
#include <stdio.h>
#include <NFMerrordef.h>
#include <PDUerror.h>
#include <PDMapi_value.h>
#include <PDMapi_struc.h>
 
/* "sql.h" renamed "ris.h" in RIS V5. 07/mar/95 - raj. */
#if defined ( RISV4 )
#include "sql.h"
#elif defined ( RISV5 )
#include "ris.h"
#else
#error "RIS version must be defined"
#endif
 
#include <NFMstruct.h>
#include <PDMproto.h>
#include <PDUproto.h>

/* Externs */

extern struct NFMglobal_st NFMglobal;
extern struct sqlda query_out_desc;

long pdmoRisStatement(cpr_sql_str, spw_err_code)
char *cpr_sql_str;
struct pdmRisError **spw_err_code;
{

  long status;
  long ris_err_code; 
  char dbtype[2];
  char sch_name[80];
  

  _pdm_debug("Enter pdmoRisStatement",0);

  /* check if logged in */

  if (pdmcheck_log_in() == 0)
    return(PDM_E_USER_NOT_LOGGED_IN);
  
  /* decrypt schema name */
  status = NFMdecrypt(NFMglobal.NFMsch_name,sch_name);
  if (status != NFM_S_SUCCESS)
   {
    _pdm_debug("NFMdecrypt failed <0x%.8x>",status);
    return(status); 
   }

  _pdm_debug("SQLget_dbtype",0);
  status = SQLget_dbtype(sch_name,dbtype);
  if (status != SQL_S_SUCCESS)
    {
      _pdm_debug("SQLget_dbtype failed <0x%.8x>",status);
      return(status);
    }

  _pdm_debug("Execute ris statement |%s|",cpr_sql_str);

  status = PDMris_stmt(cpr_sql_str,&ris_err_code);
  if (status != SQL_S_SUCCESS)
  {
    _pdm_debug("PDMris_stmt failed %d",status);

    if ((*spw_err_code) == NULL)
     (*spw_err_code) = (struct pdmRisError *)malloc(sizeof(struct pdmRisError));
    if ((*spw_err_code) == NULL)
      return(SQL_E_MALLOC); 
    (*spw_err_code)->ris_error_code = ris_err_code;
    strcpy((*spw_err_code)->ris_error_string,risca->sqlerrm.sqlerrmc);
    (*spw_err_code)->db_error_code = dbca->sqlcode;
    (*spw_err_code)->db_type = dbtype[0];  
    return(status); 
  }

 (*spw_err_code) = NULL;
 _pdm_debug("Exit pdmoRisStatement",0 );
 return(PDM_S_SUCCESS);

}


/****************************************************************************

Name
   pdmoRisQuery

Abstract
   This function allows a user to execute an sql query on the database. 

Synopsis
  long pdmoRisQuery ( )

Description
   Input:

   Input/Output:

   Output:

   Algorithm:
   1)

Return Values

Notes

Index

Keywords

RisQuery

History
   Audra Romans Mon Aug 16 12:56:31 CDT 1993: Initial Creation
****************************************************************************/


pdmoRisQuery(cpr_sql_str,spm_query_info,spw_err_code)
char *cpr_sql_str;
struct pdmRisQuery **spm_query_info;
struct pdmRisError **spw_err_code;
{

  long status;
  int ipr_rows = 0, ris_err_code = 0, i = 0, j = 0;
  int row_idx = 0;
  char sch_name[80], *tok_ptr = NULL; 
  char dbtype[2], *new_str = NULL, del_str;
  char *cpr_out_buff = NULL, *ptr = NULL, *next_ptr = NULL;
  char check_str[5];

  _pdm_debug("Enter pdmoRisQuery",0);
 
  /* check if logged in */

  if (pdmcheck_log_in() == 0)
    return(PDM_E_USER_NOT_LOGGED_IN);

  /* decrypt schema name */
  NFMdecrypt(NFMglobal.NFMsch_name,sch_name);

  /* Get database type */
  status = SQLget_dbtype(sch_name,dbtype);
  if (status != SQL_S_SUCCESS)
   {
     _pdm_debug("SQLget_dbtype failed <0x%.8x>",status);
     (*spw_err_code) = NULL; 
     return(status);
   }

  /* call PDMquery */

  del_str = '\1';
  status = PDMquery(cpr_sql_str, &ipr_rows, &cpr_out_buff, &ris_err_code, del_str); 
  if (status != SQL_S_SUCCESS)
   {
     if ((*spw_err_code) == NULL)
      (*spw_err_code) = (struct pdmRisError *)malloc(sizeof(struct pdmRisError));
    if ((*spw_err_code) == NULL)
      return(SQL_E_MALLOC); 
    
    (*spw_err_code)->ris_error_code = ris_err_code;
    strcpy((*spw_err_code)->ris_error_string,risca->sqlerrm.sqlerrmc);
    (*spw_err_code)->db_error_code = dbca->sqlcode;
    (*spw_err_code)->db_type = dbtype[0];

     return(status);
   }

 
  if ((*spm_query_info))
    free((*spm_query_info));
  (*spm_query_info) = (struct pdmRisQuery *)malloc(sizeof(struct pdmRisQuery));
  if ((*spm_query_info) == NULL)
    return(PDM_E_COULD_NOT_MALLOC);
 
 
   /* Fill up query structure with results of query */
 
   if (cpr_out_buff)
   {
     (*spm_query_info)->no_of_rows = ipr_rows;
     
  
   /* use global variable query_out_desc to build char array of column names*/  

     (*spm_query_info)->columns = (char **)malloc(sizeof(char *) * query_out_desc.sqld);

     for (i=0; i < query_out_desc.sqld; i++)
     {
       (*spm_query_info)->columns[i] = (char *)malloc(sizeof (char) * strlen (query_out_desc.sqlvar[i].sqlname.sqlnamec) + 1);
       if ((*spm_query_info)->columns[i] == NULL)
           return(SQL_E_MALLOC);

       strcpy((*spm_query_info)->columns[i],query_out_desc.sqlvar[i].sqlname.sqlnamec);
     }

     (*spm_query_info)->no_of_cols = query_out_desc.sqld;

   /* Loop thru the data and break into pieces */

     (*spm_query_info)->data = (char **)malloc(sizeof(char *) * ((*spm_query_info)->no_of_rows  * (*spm_query_info)->no_of_cols));

     ptr = cpr_out_buff;
     for (i=0; i < (*spm_query_info)->no_of_rows; i++)
      {
         row_idx = i * (*spm_query_info)->no_of_cols;

         for (j=0; j < (*spm_query_info)->no_of_cols; j++)
          {
            /* parse the char string cpr_out_buff for the delimeter */
            /* Warned against using strtok */
           
             tok_ptr = (char *)strchr(ptr,del_str);
             next_ptr = tok_ptr;
             next_ptr ++; 
             tok_ptr[0] = '\0';
             new_str = ptr;
             ptr = next_ptr;

               /* check for nill string */
       
              sprintf(check_str,"nil%c\0",del_str);
              if ((!strncmp(new_str,check_str,3)) || (new_str[0] == del_str))
{
               (*spm_query_info)->data[j+row_idx] = "";
}
              else
               {
                 /* malloc space for data */
                 (*spm_query_info)->data[j+row_idx] = (char *)malloc(sizeof (char) * strlen(new_str) + 1);

                 strcpy((*spm_query_info)->data[j+row_idx],new_str);
               }
              new_str[0] = '\0';
          }
      }
     free (cpr_out_buff);
   }
   if (query_out_desc.sqlvar)
     free(query_out_desc.sqlvar);

   _pdm_debug("Exit pdmoRisQuery",0);
   return (PDM_S_SUCCESS);
}

