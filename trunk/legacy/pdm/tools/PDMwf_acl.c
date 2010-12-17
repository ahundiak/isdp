#include <stdio.h>
#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "PDMproto.h"
#include "NFMerrordef.h"

#define MAX_BUFFER_SIZE 16384
#define NOT !
#define	TRUE	1
#define FALSE	0

extern long     sqlstatus;
extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static long     status;
static char     s[1024];


/* Given a catalog this function gets the valid acls and
   workflows associated with the catalog. Kumar 9/30/91*/

int PDMwfacl_of_catalog(PDMexec)
PDMexec_ptr PDMexec;
{
  char   sql_str[512];
  MEMptr temp_bufr = NULL;

    PDMdebug("ENTER: PDMwfacl_of_catalog");
      sql_str[0] ='\0';
sprintf(sql_str,"%s FROM %s %s '%s' %s ",
   "SELECT nfmacls.n_aclname,nfmworkflow.n_workflowname ","nfmacls,nfmcatalogs,nfmworkflows,nfmcatalogaclmap", "WHERE nfmcatalogs.n_catalogname = '%s' AND nfmcatalogaclmap.n_catalogno = nfmcatalogs.n_catalogno AND nfmcatalogaclmap.n_aclno =nfmacls.n_aclno AND nfmacls.n_workflowno = nfmworkflow.n_workflowno ",PDMexec->catalog);

   status = SQLquery(sql_str,&temp_bufr,512);
   if(status != SQL_S_SUCCESS)
   {
                MEMclose(&temp_bufr);
                switch(status)
                {
                        case SQL_I_NO_ROWS_FOUND :
                                 sprintf(s,"%s %s %s %s \n",
                                 "PDMget_children: Could not find Part ",
                                 PDMexec->part_num,PDMexec->revision);
                                 PDMdebug(s);
                                 return(PDM_E_ACLWF_NOT_FOUND);
                        case PDMS_NO_SUCH_ATTRIBUTE:
                                 sprintf(s,"%s %s  \n",
                                 "PDMget_children: Could not ",
                                 "find a required column in catalog");
                                 PDMdebug(s);
   return(PDM_E_REQ_COLUMN_NOT_FOUND);
                        case PDMS_NO_SUCH_TABLE:
                                 sprintf(s,"%s %s \n",
                                 "PDMget_children: Could not find Catalog ",
                                 PDMexec->catalog);
                                 PDMdebug(s);
                                 return(PDM_E_CATALOG_NOT_FOUND);
                        default:
                                 return(PDM_E_SQL_QUERY);
                }
   }
     PDMexec->return_buffer = temp_bufr;
     PDMdebug("EXIT: PDMwfacl_of_catalog\n");
     return(PDM_S_SUCCESS);
}


/* Given a catalog this function gets the valid storageareas
   associated with the catalog. Kumar 9/30/91*/

int PDMstrg_of_catalog(PDMexec)
PDMexec_ptr PDMexec;
{
  char   sql_str[512];
  MEMptr temp_bufr = NULL;

    PDMdebug("ENTER: PDMstrg_of_catalog\n");
      sql_str[0] = '\0';
sprintf(sql_str,"%s FROM %s %s '%s' %s ",
   "SELECT nfmstroragearea.n_saname ","nfmstoragearea,nfmcatalogs,nfmcatalogsamap", "WHERE nfmcatalogs.n_catalogname = '%s' AND nfmcatalogsamap.n_catalogno = nfmcatalogs.n_catalogno AND nfmcatalogsamap.n_sano = nfmstoragearea.n_sano ",PDMexec->catalog);

   status = SQLquery(sql_str,&temp_bufr,512);
   if(status != SQL_S_SUCCESS)
   {
                MEMclose(&temp_bufr);
                switch(status)
                {
                        case SQL_I_NO_ROWS_FOUND :
                                 sprintf(s,"%s %s %s %s \n",
                                 "PDMget_children: Could not find Part ",
                                 PDMexec->part_num,PDMexec->revision);
                                 PDMdebug(s);
                                 return(PDM_E_PART_NOT_FOUND);
                        case PDMS_NO_SUCH_ATTRIBUTE:
                                 sprintf(s,"%s %s  \n",
                                 "PDMget_children: Could not ",
                                 "find a required column in catalog");
                                 PDMdebug(s);
   return(PDM_E_REQ_COLUMN_NOT_FOUND);
                        case PDMS_NO_SUCH_TABLE:
                                 sprintf(s,"%s %s \n",
                                 "PDMget_children: Could not find Catalog ",
                                 PDMexec->catalog);
                                 PDMdebug(s);
                                 return(PDM_E_CATALOG_NOT_FOUND);
                        default:
                                 return(PDM_E_SQL_QUERY);
                }
   }
     PDMexec->return_buffer = temp_bufr;
     PDMdebug("EXIT: PDMstrg_of_catalog\n");
     return(PDM_S_SUCCESS);
}

int PDMget_commandno (command, command_no)
char	*command;
int	*command_no;
{
 char		*fn = "PDMget_commandno";
 int		nfmcommandno = 0, commandno = 0;
 char		sql_str[300], entity[5];
 MEMptr		qry_buf = NULL;
 char		**data;

    PDMdebug("ENTER:PDMget_command_no\n");
     sql_str[0]= '\0';
sprintf (sql_str,
     "SELECT  %s FROM %s WHERE %s = '%s'",
     "n_commandno, n_nfmcommandno, n_entity",
     "NFMCOMMANDS",
     "n_commandname", command);

   status = SQLquery(sql_str,&qry_buf,512);
   if (status != SQL_S_SUCCESS) {
     MEMclose(&qry_buf);
     _PDMdebug (fn, "SQL statement failed: status %d\n", status);
     PDMdebug(s);
     return(PDM_E_SQL_STMT);
   }

   status = MEMbuild_array(qry_buf);
   if(status != MEM_S_SUCCESS) {
                MEMclose(&qry_buf);
                sprintf(s,"%s %d \n",
                "MEMbuild_array ",status);
                PDMdebug(s);
                return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on) {
       MEMprint_buffer("qry_buf in PDMget_commandno",
       qry_buf,PDM_DEBUG_FILE);
   }

   data = (char **)qry_buf->data_ptr;
   commandno = atol(data[0]);
   nfmcommandno = atol(data[1]);
   strcpy (entity, data[2]);

MEMclose (&qry_buf);

     if (nfmcommandno) 
        *command_no = nfmcommandno;
      else 
        *command_no = commandno;

    PDMdebug("EXIT:PDMget_command_no\n");
  return (PDM_S_SUCCESS);
 
}
         
/* Function to get the workflowno given the aclno - MaC 012693 */


int PDMget_workflowno (aclno, workflowno)
int	aclno;
int	*workflowno;
{
 char		*fn = "PDMget_workflowno";
 char		sql_str[300];
 MEMptr		qry_buf = NULL;
 char		**data;

    PDMdebug("ENTER:PDMget_workflowno\n");
     sql_str[0]= '\0';
     sprintf (sql_str, "SELECT n_workflowno FROM NFMACLS  WHERE %s = %d",
     "n_aclno", aclno);

   status = SQLquery(sql_str,&qry_buf,512);
   if (status != SQL_S_SUCCESS) {
     MEMclose(&qry_buf);
     _PDMdebug (fn, "SQL statement failed: status %d\n", status);
     PDMdebug(s);
     return(PDM_E_SQL_STMT);
   }

   status = MEMbuild_array(qry_buf);
   if(status != MEM_S_SUCCESS) {
                MEMclose(&qry_buf);
                _PDMdebug (fn, "%s %d \n", "MEMbuild_array ",status);
                return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on) {
       MEMprint_buffer("qry_buf in PDMget_workflowno",
       qry_buf,PDM_DEBUG_FILE);
   }

   data = (char **)qry_buf->data_ptr;
   *workflowno = atol(data[0]);

  MEMclose (&qry_buf);
  PDMdebug("EXIT:PDMget_workflowno\n");
  return (PDM_S_SUCCESS);
 
}




int PDMget_state_aclno (catalog, itemname, revision, aclno, stateno)
char	*catalog, *itemname, *revision;
int	*aclno;
int	*stateno;
{
 char		*fn = "PDMget_state_aclno";
 char		sql_str[300];
 MEMptr		qry_buf = NULL;
 char		**data;

    PDMdebug("ENTER:PDMget_state_aclno\n");
     sql_str[0]= '\0';
     sprintf (sql_str, 
    "SELECT n_stateno, n_aclno FROM %s WHERE %s '%s' AND %s '%s'",
     catalog,
     "n_itemname = ", itemname,
     "n_itemrev = ", revision);

   status = SQLquery(sql_str,&qry_buf,512);
   if (status != SQL_S_SUCCESS) {
     MEMclose(&qry_buf);
     _PDMdebug (fn, "SQL statement failed: status %d\n", status);
     PDMdebug(s);
     return(PDM_E_SQL_STMT);
   }

   status = MEMbuild_array(qry_buf);
   if(status != MEM_S_SUCCESS) {
                MEMclose(&qry_buf);
                _PDMdebug (fn, "%s %d \n", "MEMbuild_array ",status);
                return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on) {
       MEMprint_buffer("qry_buf in PDMget_state_aclno",
       qry_buf,PDM_DEBUG_FILE);
   }

   data = (char **)qry_buf->data_ptr;
   *stateno = atol(data[0]);
   *aclno = atol(data[1]);

  MEMclose (&qry_buf);
  PDMdebug("EXIT:PDMget_state_aclno\n");
  return (PDM_S_SUCCESS);
 
}



/* ALR  9/8/93    Function to get n_statename, n_workflowname, n_aclname 
    given the catalog name and partnum.
*/


int PDMgetacl_info(cat_name, part_num, revision, acl_name, state_name, wkfl_name)
char *cat_name, *part_num, *revision;
char acl_name[20], state_name[40], wkfl_name[20];
{
  long status;
  char sql_str[180], **data, s[1080];
  MEMptr tmp_buff = NULL;
  int stateno, aclno, wkflno;


   PDMdebug("PDMgetacl_info:  Enter \n");

    status = PDMget_state_aclno(cat_name, part_num, revision, &aclno, &stateno);
    if (status != PDM_S_SUCCESS)
     {
       sprintf(s,"PDMget_state_aclno failed <0x%.8x> \n",status);
       PDMdebug(s);
       return(status);
     }
 
    sprintf(s,"stateno %d aclno %d \n",stateno, aclno);
    PDMdebug(s);

    MEMclose(&tmp_buff);


    status = PDMget_workflowno(aclno,&wkflno);
    if (status != PDM_S_SUCCESS)
     {
       sprintf(s,"PDMget_state_aclno failed <0x%.8x> \n",status);
       PDMdebug(s);
       return(status);
     }

    sprintf(sql_str,"select n_statename from nfmstates where n_stateno = %d \0",stateno);
    status = SQLquery(sql_str,&tmp_buff,MEM_SIZE);
    if (status != SQL_S_SUCCESS)
     {
       sprintf(s,"%s failed <0x%.8x> \n",sql_str,status);
       PDMdebug(s);
       return(status);
     }

     status = MEMbuild_array(tmp_buff);
     if (status != MEM_S_SUCCESS)
      {
       sprintf(s,"MEMbuild_array failed <0x%.8x> \n",status);
       PDMdebug(s);
       return(status);
      }

     data = (char **)tmp_buff->data_ptr;
     strcpy(state_name,data[0]);

     sprintf(s,"state_name %s \n",state_name);
     PDMdebug(s);

     MEMclose(&tmp_buff);

     sprintf(sql_str,"select n_aclname from nfmacls where n_aclno = %d \0",aclno);
     status = SQLquery(sql_str,&tmp_buff,MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        sprintf(s,"%s failed <0x%.8x> \n",sql_str,status);
        PDMdebug(s);
        return(status);
      }

      status = MEMbuild_array(tmp_buff);
      if (status != MEM_S_SUCCESS)
       {
         sprintf(s,"MEMbuild_array failed <0x%.8x> \n",status);
         PDMdebug(s);
         return(status);
       }

       data = (char **)tmp_buff->data_ptr;
       strcpy(acl_name,data[0]);

       sprintf(s,"acl_name %s \n",acl_name);
       PDMdebug(s);

       MEMclose(&tmp_buff);
    
       sprintf(sql_str,"select n_workflowname from nfmworkflow where n_workflowno = %d\0",wkflno);
       status = SQLquery(sql_str,&tmp_buff,MEM_SIZE);
       if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
         {
           sprintf(s,"%s failed <0x%.8x> \n",sql_str,status);
           PDMdebug(s);
           return(status);
         }

       if (status == SQL_I_NO_ROWS_FOUND)
           strcpy(wkfl_name,"");
       else
       {
         status = MEMbuild_array(tmp_buff);
         if (status != MEM_S_SUCCESS)
          {
            sprintf(s,"MEMbuild_array failed <0x%.8x> \n",status);
            PDMdebug(s);
            return(status);
          } 
     
         data = (char **)tmp_buff->data_ptr;
         strcpy(wkfl_name,data[0]);
       }
       sprintf(s,"wkfl_name %s \n",wkfl_name);
       PDMdebug(s);
 
       MEMclose(&tmp_buff);

   PDMdebug("PDMgetacl_info:  Exit \n");
  
   return(PDM_S_SUCCESS);
}
          
