/* $Id: PDMloc_part1.c,v 1.1 2003/03/12 20:20:49 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/pdm/PDMloc_part1.c
 *
 * Description:
 * This file contains the function PDMsearch_for_parts_in_catalog
 * It was copied from the master PDM_loc.c file.
 * refer to that file for more information.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: PDMloc_part1.c,v $
 *	Revision 1.1  2003/03/12 20:20:49  ahundiak
 *	ah CR7415
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/12/03  ah	     Added to cvs
 * 03/12/03  ah      CR7415 Fixed the WHERE processing code
 *                   Return proper status when query fails
 * -------------------------------------------------------------------*/

#include		<stdio.h>
#include		"SQLerrordef.h"
#include 		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"PDMdbs_err.h"
#include		"MEMstruct.h"
#include		"PDUerror.h"
#include		"PDUstorage.h"
#include		"PDMproto.h"
#include		"PDUpdmrpro.h"

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static char     s[1024];
static long     status;

extern PDMexec_ptr PDMexec;
extern struct PDUstorage *storage;

/* ----------------------------------------------
 * CR7415 - Want to add some additional WHERE
 * conditions to the List Parts in Catalog
 *
 * There is a global WHERE variable that makes it
 * way to here.  The problem is that the table name
 * get's added to the field names somewhere in the middle.
 * 
 * However, the actualy query uses table aliases which
 * causes the query to fail.  
 * 
 * this code replaces the table names with the aliases.
 */
#include <string.h>
static void replaceTableName(char *buf, char *name, char *alias)
{
  char *p;
  
  while((p = strstr(buf,name)))
  {
    memcpy(p,alias,strlen(alias));
    p += strlen(alias);
    strcpy(p,p + strlen(name) - strlen(alias));
  }
  return;
}
static void replaceTableNames(char *buf, char *catName)
{
  char name[128];

  /* A few tests */
  if (buf == NULL) return;
  if (strlen(catName) < 2) return;

  /* Check f_ first */
  sprintf(name,"f_%s.",catName);
  replaceTableName(buf,name,"t2.");

  /* Then the real one */
  sprintf(name,"%s.",catName);
  replaceTableName(buf,name,"t1.");

  return;
}


/* Written by kumar to report on the parts in a given 
   catalog 
Documented in the database
  
   - 10/10/92

*/
int PDMsearch_for_parts_in_catalog
(
	MEMptr          names_bufr,
        MEMptr          *attr_list
)
{
	char		*fname = "PDMsearch_for_parts_in_catalog";
	MEMptr          fcat_bufr = NULL;
        MEMptr          fmgr_bufr = NULL;
        int             i,nxi,catno;
        char            *search,*order,**data,  **fmgr_data,**fcat_data;
        char            sql_str[3048],p_local[120],p_update[3];
        char            type[6],e_cat[21];
        long            status1;
        long            PDMfind_entry_in_fmgr_bufr();
        char          n_fileversion[5], n_ref[5], n_co[3], n_copy[3];

	_PDMdebug(fname,"ENTER: \n");

	*attr_list = NULL;
        search = NULL;
        order  = NULL;

         status = MEMbuild_array(names_bufr);
	if (status != MEM_S_SUCCESS)
	{
		_PDMdebug(fname, "MEMbuild_array failed status %d\n",status);
		return (PDM_E_BUILD_ARRAY);
	}
        data = (char **) names_bufr->data_ptr;
	if (PDMdebug_on) {
		MEMprint_buffer("names_bufr", names_bufr, PDM_DEBUG_FILE);
		PDMprint_storage_area();
	}
	status = MEMopen(attr_list, 512);
        if (status != MEM_S_SUCCESS)
	{
	_PDMdebug(fname,"MEMopen failed status %d\n",status);
	_PDMdebug(fname,"EXIT:-ERROR \n");
	return(PDM_E_OPEN_BUFFER);
	}
	status = MEMwrite_format(*attr_list, "n_catalogname", "char(20)");
        if (status == MEM_S_SUCCESS)
	status = MEMwrite_format(*attr_list, "n_itemname", "char(120)");
        if (status == MEM_S_SUCCESS)
	status = MEMwrite_format(*attr_list, "n_itemrev", "char(40)");
        if (status == MEM_S_SUCCESS)
	status = MEMwrite_format(*attr_list, "n_itemdesc", "char(120)");
        if (status == MEM_S_SUCCESS)
	status = MEMwrite_format(*attr_list, "n_filetype", "char(5)");
        if (status == MEM_S_SUCCESS)
	status = MEMwrite_format(*attr_list, "n_cofilename", "char(15)");
        if (status == MEM_S_SUCCESS)
	status = MEMwrite_format(*attr_list, "p_local", "char(120)");
        if (status == MEM_S_SUCCESS)
	status = MEMwrite_format(*attr_list, "n_statename", "char(40)");
        if (status == MEM_S_SUCCESS)
	status = MEMwrite_format(*attr_list, "p_update", "char(3)");
        if (status == MEM_S_SUCCESS)
	status = MEMwrite_format(*attr_list, "p_parttype", "char(2)");
        if (status != MEM_S_SUCCESS)
	{
	  _PDMdebug(fname,"MEMwrite_format failed status %d\n",status);
	  _PDMdebug(fname,"EXIT:-ERROR \n");
	  return(PDM_E_WRITE_FORMAT);
	}
        if(data != NULL && names_bufr->rows > 0)
        {
          search  = (char *) malloc(strlen(data[0]) + 10);
          memset(search,NULL,(strlen(data[0]) + 10));
          if( strlen(data[0]))
          {
            strcpy(search,data[0]);
            strcat(search," AND ");
            replaceTableNames(search,PDMexec->catalog);
          }
          else strcpy(search,"");
        }
        else
        {
          search  = (char *) malloc(10);
          strcpy(search,"");
        }

        if(data != NULL && names_bufr->rows > 0)
        {
          order  = (char *) malloc(strlen(data[1]) + 10);
          memset(order,NULL,(strlen(data[1]) + 10));
          if( strlen(data[1]) )
          {
            strcat(order,", ");
            strcat(order,data[1]);
            replaceTableNames(order,PDMexec->catalog);
          }
          else strcpy(order,"");
        }
        else
        {
          order  = (char *) malloc(10);
          strcpy(order,"");
        }
        catno = 0; 
        status = PDMget_catno_type(PDMexec->catalog,&catno,type);
        if(status != SQL_S_SUCCESS)
        {
          _PDMdebug(fname,"EXIT: -Error\n");
        }
        if(!strcmp(type,"C") || !strcmp(type,"EXT") || !strcmp(type,"M"))
        {
/* Instead of performing multiple queries and multiple joins,  nested
   queries are done here*/

          sql_str[0] = '\0';
          sprintf(sql_str,
            "SELECT "
            "t1.n_itemno,t1.n_itemname,t1.n_itemrev,t1.n_itemdesc,"
            "t2.n_filetype,  t2.n_cofilename,t3.n_statename,t2.n_fileversion,"
            "t1.p_parttype , t2.n_filenum,   t1.n_status,   t2.n_cosano "
            "FROM "
            "f_%s t2,nfmstates t3,%s t1 "
            "WHERE  %s  "
            "t3.n_stateno = t1.n_stateno AND "
            "t1.n_itemno  = t2.n_itemnum AND "
            "t2.n_fileversion = "
            "(SELECT MAX(n_fileversion) FROM f_%s t2 "
            "WHERE t1.n_itemno = t2.n_itemnum) "
            "ORDER BY n_itemname,n_itemrev,n_cofilename %s",
            PDMexec->catalog,
            PDMexec->catalog,search, 
            PDMexec->catalog,order);

	_PDMdebug(fname,"LIST PARTS IN CATALOG QUERY\n %s;\n",sql_str);

      if (0) printf("%s\n",sql_str);

      status = SQLquery(sql_str,&fcat_bufr,512);
      free(search);
      free(order);
      if(status != SQL_S_SUCCESS)
      {
        if(status ==  SQL_I_NO_ROWS_FOUND )
        {
          MEMclose(&fcat_bufr);
	  _PDMdebug(fname,"EXIT:-NO PARTS FOUND\n");
          return(PDM_E_NO_PARTS_FOUND);
        } 
        else 
        {
          MEMclose(&fcat_bufr);
	  _PDMdebug(fname,"EXIT:-ERROR \n");
          printf("*** LIST PARTS IN CATALOG QUERY ERROR\n%s\n",sql_str);
          return(PDM_E_SQL_QUERY);
        } 
      }
      status = MEMbuild_array(fcat_bufr);
      if (status != MEM_S_SUCCESS)
	     {
	MEMclose(&fcat_bufr);
        _PDMdebug(fname,"MEMwrite_format failed status %d\n",status);
	_PDMdebug(fname,"EXIT:-ERROR \n");
	return(PDM_E_BUILD_ARRAY);
        }
               fcat_data = (char **)fcat_bufr->data_ptr;
                if(PDMdebug_on)
                {
                 MEMprint_buffer("fcat_bufr", fcat_bufr, PDM_DEBUG_FILE);
                }
                catno = 0; 
             status = PDMris_get_catno(PDMexec->catalog,&catno);
                if(status != SQL_S_SUCCESS)
                {
		MEMclose(&fcat_bufr);
	        PDMdebug(fname,"EXIT:Cannot find catno-ERROR \n");
                }
                if(fcat_bufr->rows > 2000)
                {
/* MJG 8/21/95 - CR 139422921 - Allow more than 2000 parts to be listed
		MEMclose(&fcat_bufr);
	        _PDMdebug(fname,"EXIT:MORE THAN 2000 parts \n");
                 return(PDM_E_TOO_MANY_PARTS);
*/
                 PDMdebug("list contains more than 2000 parts\n");
                 PDUmessage(PDM_E_LIST_EXCEEDS_2000_PARTS, 's');
                 }
               
 sprintf(sql_str,"SELECT n_fileversion, n_ref, n_co, n_copy,n_catalogno, n_itemno, n_filenum from nfmsafiles where  n_sano = %d  ", storage->storage_no);
            status = SQLquery(sql_str,&fmgr_bufr,512);
             if(status != SQL_S_SUCCESS)
               {
                 if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
                    MEMclose(&fmgr_bufr); fmgr_bufr = NULL;
        _PDMdebug(fname,"NO local files for this storage area \n");
                   }
               }
         if(status == SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
               {
               status = MEMbuild_array(fmgr_bufr);
               if (status != MEM_S_SUCCESS)
                {
                MEMclose(&fmgr_bufr);
                sprintf(s,"MEMbuild_array failed status %d\n",status);
                PDMdebug(s);
                return(PDM_E_BUILD_ARRAY);
                }
                if(PDMdebug_on)
                {
                 MEMprint_buffer("FMGR BUFR", fmgr_bufr, PDM_DEBUG_FILE);
                }
               }
          for(i=0;i < fcat_bufr->rows;i++)
          {
       nxi = i * fcat_bufr->columns;
/*       fmgr_bufr = NULL; */
       sql_str[0] = '\0';
            n_fileversion[0] = '\0';
             n_ref[0] = '\0';
             n_co[0] = '\0';
             n_copy[0] = '\0';
     status = PDMfind_entry_in_fmgr_bufr(catno,atoi(fcat_data[nxi]), fcat_data[nxi+9], n_fileversion, n_ref, n_co, n_copy, fmgr_bufr);
         if(status != PDM_S_SUCCESS)
         {
         _PDMdebug(fname,"storage->storage_no %d fcat_data[nxi+11] %s\n",storage->storage_no, fcat_data[nxi+11]);
         if(status ==  SQL_I_NO_ROWS_FOUND )
          {
   if(!strcmp(fcat_data[nxi+10], "I") ) strcpy(p_local,"CHECKED IN");
 else if(!strcmp(fcat_data[nxi+10], "O") || !strcmp(fcat_data[nxi+10],"S")) 
     {
        if(storage->storage_no == atoi(fcat_data[nxi+11]))
          strcpy(p_local,"NEVER CHECKED IN - JUST ADDED");
         else
          {
       status1 = PDMsano_to_name(atoi(fcat_data[nxi+11]),p_local);
         _PDMdebug(fname,"p_local","%s\n",p_local);
        if(status1 != PDM_S_SUCCESS) strcpy(p_local,"OUT ELSEWHERE");
          }
      }
    else if(!strcmp(fcat_data[nxi+10], "ON") ) strcpy(p_local,"ON TRANSFER");
    else if(!strcmp(fcat_data[nxi+10], "TI") ) strcpy(p_local,"ON TRANSFER");
    else if(!strcmp(fcat_data[nxi+10], "TO") ) strcpy(p_local,"ON TRANSFER");
      else strcpy(p_local,"NEVER CHECKED IN");
          strcpy(p_update,"NA");
             /*MEMclose(&fmgr_bufr); */
            } 
          else 
            {
             MEMclose(&fmgr_bufr);
	   _PDMdebug(fname,"EXIT:-SQL QUERY ERROR \n");
            return(status);
             } 
         }
          if(status != SQL_I_NO_ROWS_FOUND)
           {
    if(!strcmp(n_co,"Y") ) strcpy(p_local,"CHECKED OUT");
  else if(!strcmp(n_copy,"Y") && (atoi(n_ref) == 0)) strcpy(p_local,"COPIED TO LOCAL");
  else if(atoi(n_ref) > 0) strcpy(p_local,"ATTACHED");
  else  strcpy(p_local,"LOCAL");
if(atoi(n_fileversion)  < atoi(fcat_data[nxi+7])) strcpy(p_update ,"N");
                else strcpy(p_update,"Y");
          }
    sql_str[0] = '\0';
    if(PDMdebug_on)
     {
    _PDMdebug(fname,"PDMexec->catalog = %s n_itemname = %s, n_itemrev = %s n_itemdesc = %s filetype = %s cofilename = %s statename = %s p_local = %s p_update = %s p_parttype = %s\n", PDMexec->catalog,fcat_data[nxi+1],fcat_data[nxi+2],fcat_data[nxi+3], fcat_data[nxi+4],fcat_data[nxi+5],p_local,fcat_data[nxi+6], p_update,fcat_data[nxi+8]);
       }

    sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",PDMexec->catalog,fcat_data[nxi+1],fcat_data[nxi+2],fcat_data[nxi+3],fcat_data[nxi+4],fcat_data[nxi+5],p_local,fcat_data[nxi+6],p_update,fcat_data[nxi+8]);
       status = MEMwrite(*attr_list,sql_str);
             if(status != MEM_S_SUCCESS)
               {
       _PDMdebug(fname, "MEMwrite to attr_list failed: status = %d\n", status);
		MEMclose(&fcat_bufr);
		MEMclose(&fmgr_bufr);
	        _PDMdebug(fname,"EXIT:-ERROR \n");
                 return(PDM_E_WRITE_BUFFER);
               }
       }
		MEMclose(&fmgr_bufr);
    }
        else if(!strcmp(type,"P") || !strcmp(type, "PXT"))
         {
    sql_str[0] = '\0';
     sprintf(sql_str,"SELECT t1.n_itemno,t1.n_itemname,t1.n_itemrev,t1.n_itemdesc,t3.n_statename,t1.p_parttype ,t1.n_status FROM nfmstates t3,%s t1 WHERE  %s  t3.n_stateno = t1.n_stateno  ORDER BY n_itemname,n_itemrev %s", PDMexec->catalog,search, order);
          status = SQLquery(sql_str,&fcat_bufr,512);
      free(search);
      free(order);
          if(status != SQL_S_SUCCESS)
            {
             if(status ==  SQL_I_NO_ROWS_FOUND )
              {
               MEMclose(&fcat_bufr);
	       PDMdebug(fname,"EXIT:NO PARAMETRIC PARTS \n");
               return(PDM_E_NO_PARTS_FOUND);
               } 
               else 
                {
                 MEMclose(&fcat_bufr);
	         _PDMdebug(fname,"EXIT:-ERROR \n");
                 return(status);
                  } 
               }
               status = MEMbuild_array(fcat_bufr);
               if (status != MEM_S_SUCCESS)
	        {
		MEMclose(&fcat_bufr);
		_PDMdebug(fname,"MEMwrite_format failed status %d\n",status);
	        _PDMdebug(fname,"EXIT:-ERROR \n");
		return(PDM_E_BUILD_ARRAY);
                }
                fcat_data = (char **)fcat_bufr->data_ptr;
                if(PDMdebug_on)
                {
                 MEMprint_buffer("fcat_bufr", fcat_bufr, PDM_DEBUG_FILE);
                }
                if(fcat_bufr->rows > 2000)
                {
/* MJG 8/21/95 - CR 139422921 - Allow more than 2000 parts to be listed
		MEMclose(&fcat_bufr);
	        _PDMdebug(fname,"EXIT:MORE THAN 2000 parts to list \n");
                return(PDM_E_TOO_MANY_PARTS);
*/
                 PDMdebug("list contains more than 2000 parts\n");
                 PDUmessage(PDM_E_LIST_EXCEEDS_2000_PARTS, 's');
                 }
               
         for(i=0;i < fcat_bufr->rows;i++)
           {
            nxi = i * fcat_bufr->columns;
       fmgr_bufr = NULL;

    sprintf(sql_str,"%s\1%s\1%s\1%s\1PAR\1\1NA\1%s\1NA\1P\1",PDMexec->catalog,fcat_data[nxi+1],fcat_data[nxi+2],fcat_data[nxi+3],fcat_data[nxi+4]);
       status = MEMwrite(*attr_list,sql_str);
             if(status != MEM_S_SUCCESS)
               {
             _PDMdebug(fname, "MEMwrite failed: status = %d\n", status);
		MEMclose(&fcat_bufr);
	      _PDMdebug(fname,"EXIT:-ERROR \n");
                 return(PDM_E_WRITE_BUFFER);
               }
           }
         }
        else if(!strcmp(type,"EID") || !strcmp(type,"CID"))
         {
         sql_str[0] = '\0';
         e_cat[0] = '\0';
         sprintf( e_cat,"e_%s",PDMexec->catalog); 
     sprintf(sql_str,
      "SELECT t1.n_itemno,t1.n_itemname,t1.n_itemrev,t1.n_itemdesc,\
      t3.n_statename,t1.p_parttype ,t1.n_status FROM nfmstates t3,%s t1 \
      WHERE  %s  t3.n_stateno = t1.n_stateno AND t1.n_itemno > 0  \
      ORDER BY n_itemname,n_itemrev %s", 
        e_cat, search,order);
            status = SQLquery(sql_str,&fcat_bufr,512);
      free(search);
      free(order);
             if(status != SQL_S_SUCCESS)
              {
               if(status ==  SQL_I_NO_ROWS_FOUND )
                {
                MEMclose(&fcat_bufr);
	       _PDMdebug(fname,"EXIT:NO COMPUTED PARTS FOUND \n");
                 return(PDM_E_NO_PARTS_FOUND);
                } 
               else 
                   {
                    MEMclose(&fcat_bufr);
         	_PDMdebug(fname,"EXIT:-ERROR \n");
                     return(status);
                    } 
               }
               status = MEMbuild_array(fcat_bufr);
               if (status != MEM_S_SUCCESS)
	        {
		MEMclose(&fcat_bufr);
		_PDMdebug(fname,"MEMwrite_format failed status %d\n",status);
	        _PDMdebug(fname,"EXIT:-ERROR \n");
		return(PDM_E_BUILD_ARRAY);
                }
                fcat_data = (char **)fcat_bufr->data_ptr;
                if(PDMdebug_on)
                {
                 MEMprint_buffer("fcat_bufr", fcat_bufr, PDM_DEBUG_FILE);
                }
                if(fcat_bufr->rows > 2000)
                {
/* MJG 8/21/95 - CR 139422921 - Allow more than 2000 parts to be listed
		MEMclose(&fcat_bufr);
	        _PDMdebug(fname,"EXIT:MORE THAN 2000 parts to list \n");
                return(PDM_E_TOO_MANY_PARTS);
*/
                 PDMdebug("list contains more than 2000 parts\n");
                 PDUmessage(PDM_E_LIST_EXCEEDS_2000_PARTS, 's');
                 }
         for(i=0;i < fcat_bufr->rows;i++)
           {
            nxi = i * fcat_bufr->columns;
       fmgr_bufr = NULL;

    sprintf(sql_str,"%s\1%s\1%s\1%s\1PAR\1\1NA\1%s\1NA\1P\1",PDMexec->catalog,fcat_data[nxi+1],fcat_data[nxi+2],fcat_data[nxi+3],fcat_data[nxi+4]);
       status = MEMwrite(*attr_list,sql_str);
             if(status != MEM_S_SUCCESS)
               {
             _PDMdebug(fname, "MEMwrite failed: status = %d\n", status);
		MEMclose(&fcat_bufr);
	      _PDMdebug(fname,"EXIT:-ERROR\n");
                 return(PDM_E_WRITE_BUFFER);
               }
           }
         }
         if(*attr_list == NULL || (*attr_list)->rows == 0)
           {
		MEMclose(&fcat_bufr);
		MEMclose(&fmgr_bufr);
	       _PDMdebug(fname,"EXIT:NO COMPUTED PARTS FOUND \n");
            return(PDM_E_NO_PARTS_FOUND);
           }
           if(PDMdebug_on)
           {
            PDMdebug("MEMprinting attr_list\n");
            MEMprint_buffer("attr_list",*attr_list,PDM_DEBUG_FILE);
           }
		MEMclose(&fcat_bufr);
	_PDMdebug(fname,"EXIT:-SUCCESS \n");
	return (PDM_S_SUCCESS);
}


