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
/*static int      curbuf_no;  */
extern PDMexec_ptr PDMexec;
extern struct PDUstorage *storage;

/* PDMlist_of_parts()
 *
 * Coded by Kumar - 10/14/91 -  Documented in database 
 * DESCRIPTION: This function will perform a search for items across all the
 * catalogs that are in the nfmcatalogs(except the nfmsyscat) that belong to the
 * application. Then it will join with f_<catalog> and filemanager tabes
 * to load the information for  the parts  in the main form.
 * The fields which are returned are [catalog,part number, rev, description,
 * file type, filename, file local, workflow state, updated]
 * PARAMETERS:  PDMexecptr       PDMexec;
 * 
 * INPUT:   
 *
 * The following fields in the PDMexec are required --
 * 
 * PDMexec->user_id; PDMexec->ws_buffer;
 * 
 * The ws_buffer field is expected to contain the following buffers appended in
 * the order specified.
 * 
 * (1) names_bufr[LOC search string, LOC sort string, Part search string,
                  Part sort string] 
 * (2) in_attr_bufr 
 * 
 * 
 * OUTPUT: 
 *   ws_buffer with the information needed for the List of Parts/Files
 *   form in the PDU.
 * 
 * 
 * RETURN CODES:
 * 
 * PDM_S_SUCCESS                on success
 * 
 * The following are fatal errors meaning that the function failed. The
 * following point are worth noting.
 * 
 * (a) It is possible to fail while trying to reset(rollback). This happens when
 * the function tests for fatal errors and accordingly tries to
 * reset/rollback.
 * 
 * (b) Some are a result of checks on the PDU interface. Though this interface
 * may be stable soon the NET layer may cause problems.
 * 
 * PDM_E_RESET_BUFFER 		MEM Sub systems PDM_E_COPY_BUFFER
 * ailures. PDM_E_BUILD_ARRAY
 * 
 * PDM_E_NUMBER_OF_BUFFERS   The appended list of buffers doesn't contain the
 *                           required number of buffers. 
 * PDM_E_BUFFER_FORMAT       System Buffers are of incorrect format (NFM & PDM).
 * PDM_E_NO_CATALOGS	     No catalog satisfies the criteria.
 * PDM_E_NO_ITEMS	     No part satisfies the criteria.
 * PDM_E_CAT_SRSTR_NULL      Catalog search string is not defined.
 * PDM_E_ITEM_SRSTR_NULL     Item search string is not defined.
 * PDM_E_SYSTEM_CORRUPTED    Failed to delete catalog and/or not delete the
 *                           pdmcatalogs entry.
 */

int 
PDMlist_of_parts(names_bufr, attr_list)
	MEMptr          names_bufr;
        MEMptr          *attr_list;
{
	MEMptr          in_attr_list = NULL;
        MEMptr          out_buffer_list = NULL;
        MEMptr          mis_attr_list = NULL;
        char            **data;

	PDMdebug("ENTER:PDMlist_of_parts \n");

	*attr_list = NULL;

	if (PDMdebug_on) {
		MEMprint_buffer("names_bufr", names_bufr, PDM_DEBUG_FILE);
		PDMprint_storage_area();
	}
         status = MEMbuild_array(names_bufr);
	if (status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
        data = (char **) names_bufr->data_ptr;
        PDMdebug("ENTER: NFMsearch_across_catalogs\n");
	status = NFMsearch_across_catalogs(PDMexec->user_id, data[0],data[1],
                                           data[2], data[3], in_attr_list,
                                           &out_buffer_list, &mis_attr_list);
	if ((status != NFM_S_SUCCESS) && (status != NFM_E_BAD_ATTRIBUTE)) {
		sprintf(s, "NFMsearch_across_catalogs failed : status 0x%.8x\n", 
                        status);
		PDMdebug(s);
                MEMclose(&out_buffer_list);
                MEMclose(&mis_attr_list);
               if(status == 0x0878bba) return (PDM_E_NO_CATALOGS_FOUND);
               else
               	return (PDM_E_SEARCH_CATALOG);
	}
                MEMclose(&mis_attr_list);
	status = PDMi_list_of_parts(storage->storage_no,out_buffer_list, attr_list);
	if ((status != PDM_S_SUCCESS) ) {
		MEMclose(&names_bufr);
		MEMclose(attr_list);
		MEMclose(&out_buffer_list);
		PDMdebug("PDMlist_of_parts:\n");
		sprintf(s, "\tPDMi_list_of_parts failed : status %d\n", status);
		PDMdebug(s);
		return (status);
	}
        MEMclose(&names_bufr);
        MEMclose(&out_buffer_list);
	if (PDMdebug_on) 
		MEMprint_buffer("attr_list", *attr_list, PDM_DEBUG_FILE);
	if (attr_list != NULL) {
	        PDMdebug("EXIT:PDMlist_of_parts \n");
	        return (PDM_S_SUCCESS);
	}
	PDMdebug("EXIT:PDMlist_of_parts \n");
	return (PDM_S_SUCCESS);
}

int 
PDMi_list_of_parts(sano,out_buffer_list, attr_list)
        int            sano;
	MEMptr         out_buffer_list;
	MEMptr         *attr_list;
{
        char           **data, **column;
        char           **fcat_data, **fmgr_data;
        char           sql_str[1024],mem_str[250],type[6];
        MEMptr         fcat_bufr = NULL; 
        MEMptr         fmgr_bufr = NULL; 
        int            i,nxi,a= 0,b=0,c=0,d=0, k=0, kxi=0;
        char           p_local[120],state[42],e_cat[21];
        char           p_update[3];
        int            catno,partno;
        int            part_count = 0;
        long           status1;
        char           *fname = "PDMi_list_of_parts";
        long   PDMfind_entry_in_fmgr_bufr();
        char          n_fileversion[5], n_ref[5], n_co[3], n_copy[3];

	
	PDMdebug("ENTER:PDMi_list_of_parts\n");

	status = MEMbuild_array(out_buffer_list);
	if (status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
        
	data = (char **) out_buffer_list->data_ptr;
	column = (char **) out_buffer_list->column_ptr;
          for(i=0;i< out_buffer_list->columns; i++)
             {
               if(!strcmp(column[i],"n_catalogname")) a = i;
               else if(!strcmp(column[i],"n_itemname")) b = i;
               else if(!strcmp(column[i],"n_itemrev")) c = i;
               else if(!strcmp(column[i],"n_itemdesc")) d = i;
             }

	status = MEMopen(attr_list, 512);
        if (status != MEM_S_SUCCESS)
	{
		MEMclose(attr_list);
		sprintf(s,"MEMopen failed status %d\n",status);
		PDMdebug(s);
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
		MEMclose(out_buffer_list);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
	}
      sprintf(sql_str,"SELECT n_fileversion, n_ref, n_co, n_copy,n_catalogno, n_itemno, n_filenum from nfmsafiles where  n_sano = %d  ", sano);
            status = SQLquery(sql_str,&fmgr_bufr,512);
             if(status != SQL_S_SUCCESS)
               {
                 if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
                   }
               }
               status = MEMbuild_array(fmgr_bufr);
               if (status != MEM_S_SUCCESS)
	        {
		MEMclose(&fmgr_bufr);
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
                }
for(i=0;i< out_buffer_list->rows; i++)
       {
            if(part_count > 2000)
                   {
		MEMclose(out_buffer_list);
		MEMclose(attr_list);
	PDMdebug("EXIT:PDMi_list_of_parts \n");
                     return(PDM_E_TOO_MANY_PARTS);
                    }
               nxi = i * out_buffer_list->columns;
           fcat_bufr = NULL;
                catno = 0; partno = 0;
             status = PDMget_catno_type(data[nxi+a],&catno, type);
                if(status != SQL_S_SUCCESS)
                {
                       if(status == SQL_I_NO_ROWS_FOUND) continue;
                       else
                       return(PDM_E_SQL_STMT);

                 }
         if(!strcmp(type,"C") || !strcmp(type,"EXT"))
         {
           sql_str[0] = '\0';
     sprintf(sql_str,"SELECT f_%s.n_filetype,f_%s.n_cofilename,nfmstates.n_statename,f_%s.n_filenum,%s.p_parttype ,f_%s.n_fileversion, %s.n_status,f_%s.n_cosano FROM f_%s,nfmstates,%s WHERE %s.n_itemname = '%s' AND %s.n_itemrev = '%s' AND %s.n_itemno = f_%s.n_itemnum AND nfmstates.n_stateno = %s.n_stateno AND f_%s.n_fileversion = (SELECT MAX(n_fileversion) FROM f_%s WHERE %s.n_itemno = f_%s.n_itemnum) ORDER BY n_cofilename",
data[nxi+a],data[nxi+a],data[nxi+a],data[nxi+a],data[nxi+a],data[nxi+a],data[nxi+a],
data[nxi+a], data[nxi+a],data[nxi+a],data[nxi+b],data[nxi+a],data[nxi+c], 
data[nxi+a],data[nxi+a],data[nxi+a],data[nxi+a],data[nxi+a],data[nxi+a],
data[nxi+a]);        
            status = SQLquery(sql_str,&fcat_bufr,512);
             if(status != SQL_S_SUCCESS)
              {
                 if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
                     MEMclose(&fcat_bufr);
                     continue;
                    } 
               else 
                    {
                     MEMclose(&fcat_bufr);
                     MEMclose(&out_buffer_list);
                     MEMclose(attr_list);
                     return(status);
                    } 
               }
               status = MEMbuild_array(fcat_bufr);
               if (status != MEM_S_SUCCESS)
	        {
		MEMclose(out_buffer_list);
		MEMclose(&fcat_bufr);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
               }
                fcat_data = (char **)fcat_bufr->data_ptr;
	     PDMdebug("calling PDMris_get_pitemno\n");
             status = PDMris_get_pitemno(&partno,data[nxi+a],data[nxi+b],data[nxi+c]);
             if(status != SQL_S_SUCCESS)
                {
                       if(status == SQL_I_NO_ROWS_FOUND) continue;
                       else
                       return(PDM_E_SQL_STMT);
                 }
       for(k = 0; k < fcat_bufr->rows; k++)
         {
               kxi = k * fcat_bufr->columns;
             fmgr_bufr = NULL;
             sql_str[0] = '\0';
             n_fileversion[0] = '\0'; 
             n_ref[0] = '\0'; 
             n_co[0] = '\0'; 
             n_copy[0] = '\0'; 
            status = PDMfind_entry_in_fmgr_bufr(catno,partno, fcat_data[kxi+3], n_fileversion, n_ref, n_co, n_copy, fmgr_bufr);
      if(status != PDM_S_SUCCESS)
          {
           if(status == SQL_I_NO_ROWS_FOUND)
           {
      if(!strcmp(fcat_data[kxi+6], "I") ) strcpy(p_local,"CHECKED IN");
 else if(!strcmp(fcat_data[kxi+6], "O") || !strcmp(fcat_data[kxi+6],"S")) 
     {
        if(sano == atoi(fcat_data[kxi+7]))
          strcpy(p_local,"NEVER CHECKED IN - JUST ADDED");
         else
         {
       status1 = PDMsano_to_name(atoi(fcat_data[kxi+7]),p_local);
         _PDMdebug(fname,"p_local","%s\n",p_local);
        if(status1 != PDM_S_SUCCESS) strcpy(p_local,"OUT ELSEWHERE");
          }
      }
 else if(!strcmp(fcat_data[kxi+6], "") ) strcpy(p_local,"NEVER CHECKED IN");
  else strcpy(p_local,"ON TRANSFER");
        strcpy(p_update,"NA");
                     MEMclose(&fmgr_bufr);
           } 
               else 
                    {
                     MEMclose(&fmgr_bufr);
                     MEMclose(&out_buffer_list);
                     MEMclose(attr_list);
                     return(status);
                    } 
         }
          if(status != PDM_S_SUCCESS)
               {
    if(!strcmp(n_co,"Y") ) strcpy(p_local,"CHECKED OUT");
  else if(!strcmp(n_copy,"Y") && (atoi(n_ref) == 0)) strcpy(p_local,"COPIED TO LOCAL");
  else if(atoi(n_ref) > 0) strcpy(p_local,"ATTACHED");
  else  strcpy(p_local,"LOCAL");
if(atoi(n_fileversion)  < atoi(fcat_data[kxi+5])) strcpy(p_update ,"N");
                else strcpy(p_update,"Y");
                   
                if(atoi(n_fileversion)  < atoi(fcat_data[kxi+5])) strcpy(p_update,"N");
                else strcpy(p_update,"Y");
                }
               part_count++;             
               mem_str[0] = '\0';
           sprintf(mem_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",data[nxi+a],data[nxi+b],data[nxi+c],data[nxi+d],fcat_data[0],fcat_data[1],p_local,fcat_data[2],p_update,fcat_data[5]);
              status = MEMwrite(*attr_list,mem_str);
               if(status != MEM_S_SUCCESS)
                {
		MEMclose(out_buffer_list);
		MEMclose(&fcat_bufr);
		MEMclose(&fmgr_bufr);
		MEMclose(attr_list);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_WRITE_BUFFER);
                }

                MEMclose(&fmgr_bufr);
               }
                MEMclose(&fcat_bufr);
              
            }
            else if(!strcmp(type,"P") || !strcmp(type,"PXT"))
            {
          status = PDMquery_stateno(data[nxi+a],data[nxi+b],data[nxi+c],state);
           if(status != SQL_S_SUCCESS)
             {
             strcpy(state,"Unknown state");
             }
               part_count++;             
               mem_str[0] = '\0';
           sprintf(mem_str,"%s\1%s\1%s\1%s\1PAR\1\1NA\1%s\1NA\1P\1",data[nxi+a],data[nxi+b],data[nxi+c],data[nxi+d],state);
              status = MEMwrite(*attr_list,mem_str);
               if(status != MEM_S_SUCCESS)
                {
		MEMclose(out_buffer_list);
		MEMclose(&fcat_bufr);
		MEMclose(&fmgr_bufr);
		MEMclose(attr_list);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_WRITE_BUFFER);
                }
             }
            else if(!strcmp(type,"CID") || !strcmp(type,"EID"))
            {
             sprintf(e_cat,"e_%s",data[nxi+a]);
          status = PDMquery_stateno(e_cat,data[nxi+b],data[nxi+c],state);
           if(status != SQL_S_SUCCESS)
             {
             strcpy(state,"Unknown state");
             }
               part_count++;             
               mem_str[0] = '\0';
           sprintf(mem_str,"%s\1%s\1%s\1%s\1PAR\1\1NA\1%s\1NA\1P\1",data[nxi+a],data[nxi+b],data[nxi+c],data[nxi+d],state);
              status = MEMwrite(*attr_list,mem_str);
               if(status != MEM_S_SUCCESS)
                {
		MEMclose(out_buffer_list);
		MEMclose(&fcat_bufr);
		MEMclose(&fmgr_bufr);
		MEMclose(attr_list);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_WRITE_BUFFER);
                }
             }
         }
                MEMclose(&fcat_bufr);
                MEMclose(&fmgr_bufr);
             
return(PDM_S_SUCCESS);
}

/* Written by kumar to report on the parts in a given 
   project 
Documented in the database
  
   - 10/3/92

*/


int PDMsearch_for_parts_in_project(names_bufr, temp_bufr)

	MEMptr          names_bufr;
        MEMptr          *temp_bufr;
{
	MEMptr          fcat_bufr = NULL;
        MEMptr          cit_bufr = NULL;
        MEMptr          fmgr_bufr = NULL;
        MEMptr          mis_attr_list = NULL;
        int             i,nxi,proj_no, k, kxi;
        char            **data, **cit_data, **fmgr_data,**fcat_data;
        char            sql_str[1024],p_local[120],p_update[3];
        char            p_catalog[20];
        char            temp_table[40], part[41],rev[41],desc[41];
        char            temp_table1[20], e_cat[21], type[6],state[41] ;
        char            del_table[50];
        char            search[200];
        long            status1;

	PDMdebug("ENTER:PDMsearch_for_parts_in_project \n");

	*temp_bufr = NULL;

	if (PDMdebug_on) {
		MEMprint_buffer("names_bufr", names_bufr, PDM_DEBUG_FILE);
		PDMprint_storage_area();
	}
         status = MEMbuild_array(names_bufr);
	if (status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMbuild_array failed status %d\n",status);
                MEMclose(&names_bufr);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
        data = (char **) names_bufr->data_ptr;
        sql_str[0] = '\0';
        status = PDMris_get_projectno(PDMexec->project,&proj_no);
        if(status != SQL_S_SUCCESS) return(PDM_E_PROJECT_NOT_FOUND);
       sprintf(sql_str,"SELECT n_citno,n_catalogno,n_itemno FROM NFMPROJECTCIT WHERE n_projectno = %d ",proj_no);
         status = SQLquery(sql_str,&cit_bufr,512);
          if(status != SQL_S_SUCCESS)
            {
                MEMclose(&names_bufr);
              if(status == SQL_I_NO_ROWS_FOUND)
                 return(PDM_E_NO_PARTS_FOUND);
               else return(status);
             }
          status = MEMbuild_array(cit_bufr);
          cit_data = (char **)cit_bufr->data_ptr;
          sql_str[0] = '\0';
          /* Temporary table is created to avoid concurrency problems */
          /* The table is  created to use the searching and sorting
              algorithms of the DBMS rather than reinventing the
               wheel again - Kumar */
           status = PDMgen_table_name(temp_table1);
        if (status != PDM_S_SUCCESS) {
                MEMclose(&names_bufr);
                sprintf(s, "%s %d\n",
                        "PDMcreate_temp_table failed status ", status);
                PDMdebug(s);
                return (status);
        }
    sprintf(temp_table,"PRJ_%s",temp_table1);
sprintf(sql_str,"CREATE TABLE %s ( ", temp_table);
        strcat(sql_str,"n_catalogname char(20),");
        strcat(sql_str,"n_itemname char(120),");
        strcat(sql_str,"n_itemrev char(40),");
        strcat(sql_str,"n_itemdesc char(120),");
        strcat(sql_str,"n_filetype char(5),");
        strcat(sql_str,"n_cofilename char(15),");
        strcat(sql_str,"p_local char(120),");
        strcat(sql_str,"n_statename char(40),");
        strcat(sql_str,"p_update char(3),");
        strcat(sql_str,"p_parttype char(2)");
        strcat(sql_str,")");
        sprintf(del_table,"DROP TABLE %s", temp_table);
        status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
        {
              SQLstmt(del_table);
        }
     for(i=0; i< cit_bufr->rows; i++)
        {
           nxi = i * cit_bufr->columns;
        status = PDMris_get_catname(atol(cit_data[nxi+1]),p_catalog, type);
        if(status != SQL_S_SUCCESS)
          {
            continue;
          }
   
         if(!strcmp(type,"C") || !strcmp(type,"EXT"))
         {
    sql_str[0] = '\0';
     sprintf(sql_str,"SELECT %s.n_itemname,%s.n_itemrev,%s.n_itemdesc,f_%s.n_filetype,f_%s.n_cofilename,nfmstates.n_statename,f_%s.n_fileversion,%s.p_parttype,f_%s.n_filenum,%s.n_status f_%s.n_cosano FROM f_%s,nfmstates,%s WHERE %s.n_itemno = %s AND  %s.n_itemno = f_%s.n_itemnum AND nfmstates.n_stateno = %s.n_stateno AND f_%s.n_fileversion = (SELECT MAX(n_fileversion) FROM f_%s WHERE %s.n_itemno = f_%s.n_itemnum) ORDER BY n_itemname, n_itemrev, n_cofilename",
p_catalog,p_catalog,p_catalog,p_catalog,p_catalog,p_catalog,p_catalog,p_catalog,p_catalog,p_catalog,p_catalog,p_catalog, p_catalog, cit_data[nxi+2], p_catalog, p_catalog, p_catalog, p_catalog, p_catalog, p_catalog, p_catalog);
            status = SQLquery(sql_str,&fcat_bufr,512);
             if(status != SQL_S_SUCCESS)
              {
                 if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
                     MEMclose(&fcat_bufr);
                     continue;
                    } 
               else 
                    {
                MEMclose(&names_bufr);
                     MEMclose(&fcat_bufr);
                     SQLstmt(del_table);
                     return(status);
                    } 
               }
               status = MEMbuild_array(fcat_bufr);
               if (status != MEM_S_SUCCESS)
	        {
                MEMclose(&names_bufr);
		MEMclose(&fcat_bufr);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		PDMdebug(s);
                     SQLstmt(del_table);
		return(PDM_E_BUILD_ARRAY);
                }
                fcat_data = (char **)fcat_bufr->data_ptr;

   for(k =0; k < fcat_bufr->rows; k++)
       {
            kxi = k * fcat_bufr->columns;
             fmgr_bufr = NULL;
             sql_str[0] = '\0';
sprintf(sql_str,"SELECT n_fileversion,  n_ref, n_co, n_copy from nfmsafiles where n_catalogno = %s and n_itemno = %s  and n_filenum = %s  and n_sano = %d ",cit_data[nxi+1],cit_data[nxi+2],fcat_data[kxi+8],storage->storage_no);

            status = SQLquery(sql_str,&fmgr_bufr,512);
             if(status != SQL_S_SUCCESS)
              {
                 if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
  if(!strcmp(fcat_data[kxi + 9], "I") ) strcpy(p_local,"CHECKED IN");
 else if(!strcmp(fcat_data[kxi+9], "O") || !strcmp(fcat_data[kxi+9],"S")) 
     {
       status1 = PDMsano_to_name(atoi(fcat_data[kxi+10]),p_local);
        if(status1 != PDM_S_SUCCESS) strcpy(p_local,"OUT ELSEWHERE");
      }
  else if(!strcmp(fcat_data[kxi+9], "ON") ) strcpy(p_local,"ON TRANSFER");
  else if(!strcmp(fcat_data[kxi+9], "") ) strcpy(p_local,"NEVER CHECKED IN");
  else strcpy(p_local,"CREATION");
                     strcpy(p_update,"NA");
                     MEMclose(&fmgr_bufr);
                    } 
               else 
                    {
                MEMclose(&names_bufr);
                     MEMclose(&fmgr_bufr);
                     SQLstmt(del_table);
                     return(status);
                    } 
               }
              if(status != SQL_I_NO_ROWS_FOUND)
               {
               status = MEMbuild_array(fmgr_bufr);
               if(status != MEM_S_SUCCESS)
                {
		MEMclose(&fcat_bufr);
		MEMclose(&fmgr_bufr);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		PDMdebug(s);
                     SQLstmt(del_table);
		return(PDM_E_BUILD_ARRAY);
                }
                fmgr_data = (char **)fmgr_bufr->data_ptr;
    if(!strcmp(fmgr_data[2],"Y") ) strcpy(p_local,"CHECKED OUT");
  else if(!strcmp(fmgr_data[3],"Y") && (atoi(fmgr_data[1]) == 0)) strcpy(p_local,"COPIED TO LOCAL");
  else if(atoi(fmgr_data[1]) > 0) strcpy(p_local,"ATTACHED");
  else  strcpy(p_local,"LOCAL");
if(atoi(fmgr_data[0])  < atoi(fcat_data[kxi+6])) strcpy(p_update ,"N");
                else strcpy(p_update,"Y");
                }
    sprintf(sql_str,"INSERT INTO %s (n_catalogname,n_itemname,n_itemrev,n_itemdesc,n_filetype,n_cofilename,p_local,n_statename,p_update,p_parttype) VALUES ('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')",temp_table, p_catalog,fcat_data[0],fcat_data[1],fcat_data[2],fcat_data[3],fcat_data[4],p_local,fcat_data[5],p_update,fcat_data[7]);
      status = SQLstmt(sql_str);
          if(status != SQL_S_SUCCESS)
           {
                     SQLstmt(del_table);
             return(status);
           }
       } /* Looping of the fcat_bufr for multiple files */

           MEMclose(&fcat_bufr);
            fcat_bufr = NULL;
         }
         else if(!strcmp(type,"P") || !strcmp(type,"PXT"))
         {
status = PDMi_get_partnum_rev_desc(p_catalog,atoi(cit_data[nxi+2]),part,rev,desc);
           if(status != PDM_S_SUCCESS)
             {
                     SQLstmt(del_table);
             return(status);
             }
          status = PDMquery_stateno(p_catalog,part,rev,state);
           if(status != SQL_S_SUCCESS)
             {
             strcpy(state,"Unknown state");
             }
   sprintf(sql_str,"INSERT INTO %s (n_catalogname,n_itemname,n_itemrev,n_itemdesc,n_filetype,p_local,n_statename,p_update,p_parttype) VALUES ('%s','%s','%s','%s','PAR','NA','%s','NA','P')",temp_table, p_catalog,part,rev,desc,state);
      status = SQLstmt(sql_str);
          if(status != SQL_S_SUCCESS)
                {
                     SQLstmt(del_table);
             return(status);
                }
         }
         else if(!strcmp(type,"CID") || !strcmp(type,"EID"))
            {
             sprintf(e_cat,"e_%s",p_catalog);
status = PDMi_get_partnum_rev_desc(e_cat,atoi(cit_data[nxi+2]),part,rev,desc);
           if(status != PDM_S_SUCCESS)
             {
                     SQLstmt(del_table);
             return(status);
             }
          status = PDMquery_stateno(e_cat,part,rev,state);
           if(status != SQL_S_SUCCESS)
             {
             strcpy(state,"Unknown state");
             }
   sprintf(sql_str,"INSERT INTO %s (n_catalogname,n_itemname,n_itemrev,n_itemdesc,n_filetype,p_local,n_statename,p_update,p_parttype) VALUES ('%s','%s','%s','%s','PAR','NA','%s','NA','P')",temp_table, p_catalog,part,rev,desc,state);
      status = SQLstmt(sql_str);
          if(status != SQL_S_SUCCESS)
                {
                     SQLstmt(del_table);
             return(status);
                }
           } /* If it is a EID catalog */
        }      
         if(strlen(data[0]) ) 
           sprintf(search," WHERE %s",data[0]);
         else
            search[0] = '\0';
                sql_str[0] = '\0';
  if((!strcmp(PDMexec->catalog,"")) && (PDMexec->catalog != NULL))
                sprintf(sql_str,"SELECT *  FROM %s  %s ORDER BY n_catalogname,n_itemname", temp_table,search);
  else      
                sprintf(sql_str,"SELECT *  FROM  %s %s AND  n_catalogname = '%s' ORDER BY n_catalogname,n_itemname", temp_table, search,PDMexec->catalog);
        status = SQLquery(sql_str,temp_bufr,1024);
        if(status != SQL_S_SUCCESS)
        {
              if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
                     MEMclose(temp_bufr);
                    } 
               else 
                    {
                MEMclose(&names_bufr);
                     MEMclose(temp_bufr);
                MEMclose(&mis_attr_list);
                     SQLstmt(del_table);
                     return(status);
                    } 
        }
        sql_str[0] = '\0';
           SQLstmt(del_table);
         if((*temp_bufr)->rows > 2000)
           {
                MEMclose(&names_bufr);
                MEMclose(&cit_bufr);
                MEMclose(&fcat_bufr);
                MEMclose(&fmgr_bufr);
                MEMclose(&mis_attr_list);
	PDMdebug("EXIT:PDMsearch_for_parts_in_project \n");
	return (PDM_E_TOO_MANY_PARTS);
           }
         if(*temp_bufr == NULL)
           {
                MEMclose(&names_bufr);
                MEMclose(&cit_bufr);
                MEMclose(&mis_attr_list);
                MEMclose(&fcat_bufr);
                MEMclose(&fmgr_bufr);
            return(PDM_E_NO_PARTS_FOUND);
           }
                MEMclose(&names_bufr);
                MEMclose(&cit_bufr);
                MEMclose(&fcat_bufr);
                MEMclose(&fmgr_bufr);
                MEMclose(&mis_attr_list);
	PDMdebug("EXIT:PDMsearch_for_parts_in_project \n");
	return (PDM_S_SUCCESS);
}

/* Written by kumar to report on the parts in a given 
   project 
Documented in the database
  
   - 10/5/92

*/

int PDMsearch_for_parts_in_project2(names_bufr, temp_bufr)

	MEMptr          names_bufr;
        MEMptr          *temp_bufr;
{
        MEMptr          cit_bufr = NULL;
        MEMptr          fcat_bufr = NULL;
        int             i,nxi,proj_no,flag;
        char            **data,**cit_data,**fcat_data;
        char            sql_str[1024],mem_str[250];
        char            p_catalog[20], type[6];

	PDMdebug("ENTER:PDMsearch_for_parts_in_project2 \n");

	*temp_bufr = NULL;

	if (PDMdebug_on) {
		MEMprint_buffer("names_bufr", names_bufr, PDM_DEBUG_FILE);
	}
         status = MEMbuild_array(names_bufr);
	if (status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
        data = (char **) names_bufr->data_ptr;
         sql_str[0] = '\0';
       status = PDMris_get_projectno(PDMexec->project,&proj_no);
          if(status != SQL_S_SUCCESS)
           {
                MEMclose(&names_bufr);
	PDMdebug("EXIT:PDMsearch_for_parts_in_project2 \n");
             return(PDM_E_PROJECT_NOT_FOUND);
            }
       sprintf(sql_str,"SELECT n_citno,n_catalogno,n_itemno FROM NFMPROJECTCIT WHERE n_projectno = %d  ORDER BY n_catalogno,n_itemno",proj_no);
         status = SQLquery(sql_str,&cit_bufr,512);
          if(status != SQL_S_SUCCESS)
            {
                MEMclose(&names_bufr);
	PDMdebug("EXIT:PDMsearch_for_parts_in_project2 \n");
              if(status == SQL_I_NO_ROWS_FOUND)
                 return(PDM_E_NO_PARTS_FOUND);
               else return(status);
             }
          status = MEMbuild_array(cit_bufr);
          cit_data = (char **)cit_bufr->data_ptr;
            if(cit_bufr->rows > 2000)
               {
                MEMclose(&names_bufr);
                MEMclose(&cit_bufr);
	PDMdebug("EXIT:PDMsearch_for_parts_in_project2 \n");
             return(PDM_E_TOO_MANY_PARTS);
               }

        status = MEMopen(temp_bufr,512);
        if(status != MEM_S_SUCCESS)
           {
                MEMclose(temp_bufr);
                MEMclose(&cit_bufr);
                MEMclose(&names_bufr);
	PDMdebug("EXIT:PDMsearch_for_parts_in_project2 \n");
               return(PDM_E_OPEN_BUFFER);
           }
        status = MEMwrite_format(*temp_bufr,"n_catalogname","char(20)");
if (status == MEM_S_SUCCESS)
        status = MEMwrite_format(*temp_bufr,"n_itemname","char(120)");
if (status == MEM_S_SUCCESS)
        status = MEMwrite_format(*temp_bufr,"n_itemrev","char(40)");
if (status == MEM_S_SUCCESS)
        status = MEMwrite_format(*temp_bufr,"n_itemdesc","char(120)");
if (status == MEM_S_SUCCESS)
        if(status != MEM_S_SUCCESS)
           {
                MEMclose(temp_bufr);
                MEMclose(&cit_bufr);
                MEMclose(&names_bufr);
	PDMdebug("EXIT:PDMsearch_for_parts_in_project2 \n");
               return(PDM_E_WRITE_FORMAT);
           }
      flag = 1;
   if((!strcmp(PDMexec->catalog,"")) || (PDMexec->catalog == NULL)) flag = 2;
        
     for(i=0; i< cit_bufr->rows; i++)
        {
           nxi = i * cit_bufr->columns;
        status = PDMris_get_catname(atol(cit_data[nxi+1]),p_catalog, type);
        if(status != SQL_S_SUCCESS)
          {
            continue;
          }
         if(flag == 1) 
           {
             if(strcmp(PDMexec->catalog,p_catalog)) continue;
           }
   
    sql_str[0] = '\0';
      if((strcmp(data[0],"")) && (strlen(data[0])))
     sprintf(sql_str,"SELECT n_itemname,n_itemrev,n_itemdesc FROM %s WHERE %s ORDER BY n_itemname,n_itemrev",p_catalog,data[0]);
       else
     sprintf(sql_str,"SELECT n_itemname,n_itemrev,n_itemdesc FROM %s ORDER BY n_itemname,n_itemrev",p_catalog);
            status = SQLquery(sql_str,&fcat_bufr,512);
             if(status != SQL_S_SUCCESS)
              {
                 if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
                     MEMclose(&fcat_bufr);
                     continue;
                    } 
               else 
                    {
                     MEMclose(temp_bufr);
                     MEMclose(&cit_bufr);
                     MEMclose(&fcat_bufr);
                MEMclose(&names_bufr);
	PDMdebug("EXIT:PDMsearch_for_parts_in_project2 \n");
                     return(status);
                    } 
               }
               status = MEMbuild_array(fcat_bufr);
               if (status != MEM_S_SUCCESS)
	        {
                     MEMclose(temp_bufr);
                     MEMclose(&cit_bufr);
                     MEMclose(&fcat_bufr);
                MEMclose(&names_bufr);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		PDMdebug(s);
	PDMdebug("EXIT:PDMsearch_for_parts_in_project2 \n");
		return(PDM_E_BUILD_ARRAY);
                }
                fcat_data = (char **)fcat_bufr->data_ptr;
               mem_str[0] = '\0';
           sprintf(mem_str,"%s\1%s\1%s\1%s\1",p_catalog,fcat_data[0],fcat_data[1],fcat_data[2]);
              status = MEMwrite(*temp_bufr,mem_str);
               if(status != MEM_S_SUCCESS)
                {
		MEMclose(&fcat_bufr);
		MEMclose(temp_bufr);
		MEMclose(&cit_bufr);
                MEMclose(&names_bufr);
	PDMdebug("EXIT:PDMsearch_for_parts_in_project2 \n");
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		PDMdebug(s);
	PDMdebug("EXIT:PDMsearch_for_parts_in_project2 \n");
		return(PDM_E_WRITE_BUFFER);
                }
      }
		MEMclose(&fcat_bufr);
		MEMclose(&cit_bufr);
                MEMclose(&names_bufr);
	PDMdebug("EXIT:PDMsearch_for_parts_in_project2 \n");
	return (PDM_S_SUCCESS);
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
            }
       else
           strcpy(search,"");
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
            }
       else
           strcpy(order,"");
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
     sprintf(sql_str,"SELECT t1.n_itemno,t1.n_itemname,t1.n_itemrev,t1.n_itemdesc,t2.n_filetype,t2.n_cofilename,t3.n_statename,t2.n_fileversion,t1.p_parttype , t2.n_filenum, t1.n_status, t2.n_cosano FROM f_%s t2,nfmstates t3,%s t1 WHERE  %s  t3.n_stateno = t1.n_stateno AND t1.n_itemno = t2.n_itemnum AND t2.n_fileversion = (SELECT MAX(n_fileversion) FROM f_%s t2 WHERE t1.n_itemno = t2.n_itemnum) ORDER BY n_itemname,n_itemrev,n_cofilename %s",
PDMexec->catalog,PDMexec->catalog, search, 
PDMexec->catalog,order);
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

/* Written by kumar to support the main form to list parts from the
   search form.

Documented in the database
  
   - 11/10/92

*/

int PDMexpand_parts_list(names_bufr, nos_bufr, attr_list)

	MEMptr          names_bufr;
	MEMptr          nos_bufr;
        MEMptr          *attr_list;
{
        char            *fname = "PDMexpand_parts_list";
        MEMptr          fcat_bufr = NULL;
        MEMptr          fmgr_bufr = NULL;
        int             i,w,nxi,wxi,catno;
        char            e_cat[20];
        short           a = 0, b = 0, c = 0;
        char            **data,**column,**fcat_data, **fmgr_data;
        char            **no_data,**no_column,**no_fcat_data, **no_fmgr_data;
        char            sql_str[2048],mem_str[250], type[6];
        char            p_catalog[20], p_local[120],p_update[5];
        long            status1 = MEM_S_SUCCESS, status2 = MEM_S_SUCCESS;

	_PDMdebug(fname,"ENTER:\n");

        if((names_bufr == NULL) && (nos_bufr == NULL))
         {
		_PDMdebug(fname,"Error: Both input bufrs are null\n");
		return(PDM_E_OPEN_BUFFER);
         }
	*attr_list = NULL;
	status = MEMopen(attr_list, 512);
        if (status != MEM_S_SUCCESS)
	{
		_PDMdebug(fname,"MEMopen failed status %d\n",status);
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
		return(PDM_E_WRITE_FORMAT);
	}
	if (PDMdebug_on) {
		MEMprint_buffer("names_bufr", names_bufr, PDM_DEBUG_FILE);
		MEMprint_buffer("nos_bufr", nos_bufr, PDM_DEBUG_FILE);
	}
         status1 = MEMbuild_array(names_bufr);
	if (status1 != MEM_S_SUCCESS && status1 !=MEM_E_NULL_LIST)
	{
     _PDMdebug(fname, "MEMbuild_array of names_bufr failed status %d\n",status);
	}
        if(status1 == MEM_S_SUCCESS)
        {
         sql_str[0] = '\0';
	data = (char **) names_bufr->data_ptr;
	column = (char **) names_bufr->column_ptr;
          for(i=0;i< names_bufr->columns; i++)
             {
               if(!strcmp(column[i],"n_catalogname")) a = i;
               else if(!strcmp(column[i],"n_itemname")) b = i;
               else if(!strcmp(column[i],"n_itemrev")) c = i;
             }

 for(i=0; i< names_bufr->rows; i++)
   {
     nxi = i * names_bufr->columns;
      if((strcmp(data[nxi+a],"")) && (strlen(data[nxi+a])))
      {
       status = PDMget_catno_type(data[nxi+a],&catno,type);
              if(status != SQL_S_SUCCESS)
              {
               if(status == SQL_I_NO_ROWS_FOUND) continue;
               else return(PDM_E_SQL_STMT);
              }
       if(!strcmp(type,"C") || !strcmp(type,"EXT"))
       {
    sql_str[0] = '\0';
     sprintf(sql_str,"SELECT t1.n_itemno,t1.n_itemdesc,t2.n_filetype,\
    t2.n_cofilename,t3.n_statename,t2.n_fileversion,t1.p_parttype , \
    t2.n_filenum, t1.n_status,t1.n_itemname,t1.n_itemrev, t2.n_cosano FROM f_%s t2, nfmstates t3, %s t1\
    WHERE \
    ((t1.n_itemname = '%s' AND t1.n_itemrev = '%s') AND t3.n_stateno = t1.n_stateno) AND (t1.n_itemno = t2.n_itemnum AND t2.n_fileversion = (SELECT MAX(n_fileversion) FROM f_%s t2 WHERE t1.n_itemno = t2.n_itemnum)) ORDER BY n_itemname,n_itemrev,n_cofilename ", \
data[nxi+a],data[nxi+a],data[nxi+b],data[nxi+c], data[nxi+a]);

          status = SQLquery(sql_str,&fcat_bufr,512);
          if(status != SQL_S_SUCCESS)
              {
              if(status ==  SQL_I_NO_ROWS_FOUND )
                {
                   MEMclose(&fcat_bufr);
	         _PDMdebug(fname," <%s> <%s> <%s> doesn't exist\n", data[nxi+a],data[nxi+b], data[nxi+c]);
                    continue;
                } 
               else 
                  {
                   MEMclose(&fcat_bufr);
	           _PDMdebug(fname,"EXIT:-Error\n");
                   return(status);
                   } 
               }
               status = MEMbuild_array(fcat_bufr);
               if (status != MEM_S_SUCCESS)
	        {
                     MEMclose(&fcat_bufr);
		  _PDMdebug(fname,"MEMbuild_array failed status %d\n",status);
		return(PDM_E_BUILD_ARRAY);
                }
                fcat_data = (char **)fcat_bufr->data_ptr;
                 for(w=0; w < fcat_bufr->rows; w++)
               {
                  wxi = w * fcat_bufr->columns;

sprintf(sql_str,"SELECT n_fileversion,  n_ref, n_co, n_copy from nfmsafiles where n_catalogno = %d and n_itemno = %s  and n_filenum = %s  and n_sano = %d ",catno,fcat_data[wxi],fcat_data[wxi+7],storage->storage_no);

            status = SQLquery(sql_str,&fmgr_bufr,512);
             if(status != SQL_S_SUCCESS)
              {
                 if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
     if(!strcmp(fcat_data[wxi+8], "I") ) strcpy(p_local,"CHECKED IN");
 else if(!strcmp(fcat_data[wxi+8], "O") || !strcmp(fcat_data[wxi+8],"S")) 
     {
       status1 = PDMsano_to_name(atoi(fcat_data[wxi+11]),p_local);
        if(status1 != PDM_S_SUCCESS) strcpy(p_local,"OUT ELSEWHERE");
      }
    else if(!strcmp(fcat_data[wxi+8], "ON") ) strcpy(p_local,"ON TRANSFER");
    else if(!strcmp(fcat_data[wxi+8], "TI") ) strcpy(p_local,"ON TRANSFER");
    else if(!strcmp(fcat_data[wxi+8], "TO") ) strcpy(p_local,"ON TRANSFER");
     else strcpy(p_local,"NEVER CHECKED IN");
                     strcpy(p_update,"NA");
                     MEMclose(&fmgr_bufr);
                    } 
               else 
                    {
                     MEMclose(&fmgr_bufr);
                     MEMclose(&fcat_bufr);
	             _PDMdebug(fname,"EXIT:Error \n");
                     return(status);
                    } 
               }
              if(status != SQL_I_NO_ROWS_FOUND)
               {
               status = MEMbuild_array(fmgr_bufr);
               if(status != MEM_S_SUCCESS)
                {
		MEMclose(&fcat_bufr);
		MEMclose(&fmgr_bufr);
		_PDMdebug(fname,"MEMwrite_format failed status %d\n",status);
		return(PDM_E_BUILD_ARRAY);
                }
                fmgr_data = (char **)fmgr_bufr->data_ptr;
    if(!strcmp(fmgr_data[2],"Y") ) strcpy(p_local,"CHECKED OUT");
  else if(!strcmp(fmgr_data[3],"Y") && (atoi(fmgr_data[1]) == 0)) strcpy(p_local,"COPIED TO LOCAL");
  else if(atoi(fmgr_data[1]) > 0) strcpy(p_local,"ATTACHED");
  else  strcpy(p_local,"LOCAL");
if(atoi(fmgr_data[0])  < atoi(fcat_data[wxi+5])) strcpy(p_update ,"N");
                else strcpy(p_update,"Y");
               }
               mem_str[0] = '\0';
           sprintf(mem_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",data[nxi+a],data[nxi+b],data[nxi+c],fcat_data[wxi+1],fcat_data[wxi+2],fcat_data[wxi+3],p_local, fcat_data[wxi+4],p_update,fcat_data[wxi+6]);
              status = MEMwrite(*attr_list,mem_str);
               if(status != MEM_S_SUCCESS)
                {
		MEMclose(&fcat_bufr);
		MEMclose(&fmgr_bufr);
		_PDMdebug(fname,"MEMwrite_format failed status %d\n",status);
		return(PDM_E_WRITE_BUFFER);
                }
            } /* for all the multile files in the part */
         MEMclose(&fcat_bufr);
         MEMclose(&fmgr_bufr);
          fcat_bufr = NULL;
          fmgr_bufr = NULL;
       } /* If it is a standard  or a external catalog */
    else  if(!strcmp(type,"P") || !strcmp(type, "PXT"))
       {
    sql_str[0] = '\0';
     sprintf(sql_str,"SELECT t1.n_itemdesc, t3.n_statename,t1.n_status FROM  nfmstates t3, %s t1 WHERE ((t1.n_itemname = '%s' AND t1.n_itemrev = '%s') AND t3.n_stateno = t1.n_stateno)",  data[nxi+a],data[nxi+b],data[nxi+c]);
            status = SQLquery(sql_str,&fcat_bufr,512);
            if(status != SQL_S_SUCCESS)
              {
              if(status ==  SQL_I_NO_ROWS_FOUND )
                {
                   MEMclose(&fcat_bufr);
	         _PDMdebug(fname," <%s> <%s> <%s> doesn't exist\n", data[nxi+a],data[nxi+b], data[nxi+c]);
                    continue;
                } 
               else 
                  {
                   MEMclose(&fcat_bufr);
	    _PDMdebug(fname,"SQLquery failed status 0x%x.8>\n", status);
	           _PDMdebug(fname,"EXIT:-Error\n");
                   return(status);
                   } 
               }
               status = MEMbuild_array(fcat_bufr);
               if (status != MEM_S_SUCCESS)
	        {
                     MEMclose(&fcat_bufr);
	  _PDMdebug(fname,"MEMbuild_array failed status %d\n",status);
		return(PDM_E_BUILD_ARRAY);
                }
                fcat_data = (char **)fcat_bufr->data_ptr;
                 fmgr_bufr = NULL;
                 mem_str[0] = '\0';
    sprintf(mem_str,"%s\1%s\1%s\1%s\1PAR\1\1NA\1%s\1NA\1P\1",data[nxi+a],data[nxi+b],data[nxi+c],fcat_data[0],fcat_data[1]);
              status = MEMwrite(*attr_list,mem_str);
               if(status != MEM_S_SUCCESS)
                   {
		MEMclose(&fcat_bufr);
      _PDMdebug(fname,"MEMwrite_format failed status 0x%x.8>\n",status);
		return(PDM_E_WRITE_BUFFER);
                   }
          MEMclose(&fcat_bufr); fcat_bufr = NULL;
         } /* If it is a parametric catalog */
        else if(!strcmp(type,"EID") || !strcmp(type,"CID"))
         {
         sql_str[0] = '\0';
          sprintf( e_cat,"e_%s",data[nxi+a]); 
     sprintf(sql_str,"SELECT t1.n_itemdesc,t3.n_statename,t1.n_status FROM nfmstates t3,%s t1 WHERE t1.n_itemname = '%s' AND t1.n_itemrev = '%s' AND t3.n_stateno = t1.n_stateno", e_cat, data[nxi+b], data[nxi+c]);
            status = SQLquery(sql_str,&fcat_bufr,512);
             if(status != SQL_S_SUCCESS)
              {
               if(status ==  SQL_I_NO_ROWS_FOUND )
                {
                MEMclose(&fcat_bufr);
	         _PDMdebug(fname," <%s> <%s> <%s> doesn't exist\n", data[nxi+a],data[nxi+b], data[nxi+c]);
	       _PDMdebug(fname,"EXIT:NO SUCH COMPUTED PART\n");
                continue;
                } 
               else 
                 {
                   MEMclose(&fcat_bufr);
       	       _PDMdebug(fname,"EXIT:- ERROR in selecting CID parts\n");
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
                fmgr_bufr = NULL;
                 mem_str[0] = '\0';
    sprintf(mem_str,"%s\1%s\1%s\1%s\1PAR\1\1NA\1%s\1NA\1P\1",data[nxi+a],data[nxi+b],data[nxi+c],fcat_data[0],fcat_data[1]);
       status = MEMwrite(*attr_list,mem_str);
             if(status != MEM_S_SUCCESS)
               {
        _PDMdebug(fname, "MEMwrite failed: status <0x%x.8> \n", status);
		MEMclose(&fcat_bufr);
	      _PDMdebug(fname,"EXIT:-ERROR\n");
                 return(PDM_E_WRITE_BUFFER);
               }
          MEMclose(&fcat_bufr); fcat_bufr = NULL;
         } /* If it a Computed ID catalog */
        } /* If there is a catalog to be expanded */ 
      } /* For all the catalogs in the names bufr */
     } /* If there is any information in names bufr */
          MEMclose(&fcat_bufr); fcat_bufr = NULL;
          MEMclose(&fmgr_bufr); fmgr_bufr = NULL;
         status2 = MEMbuild_array(nos_bufr);
        if(status2 == MEM_E_NULL_LIST && status2 != MEM_S_SUCCESS)
          {
          _PDMdebug(fname, "MEMbuild_array of nos_bufr failed status %d\n",status);
          }
        if(status2 == MEM_S_SUCCESS)
        {
         sql_str[0] = '\0';
	no_data = (char **) nos_bufr->data_ptr;
	no_column = (char **) nos_bufr->column_ptr;
          for(i=0;i< nos_bufr->columns; i++)
             {
               if(!strcmp(no_column[i],"n_catalogno")) a = i;
               else if(!strcmp(no_column[i],"n_pcatalogno")) a = i;
               else if(!strcmp(no_column[i],"n_itemno")) b = i;
               else if(!strcmp(no_column[i],"n_pitemno")) b = i;
             }
         for(i=0; i< nos_bufr->rows; i++)
           {
            nxi = i * nos_bufr->columns;
            if((strcmp(no_data[nxi+a],"")) && (strlen(no_data[nxi+a])))
            {
      status = PDMris_get_catname(atoi(no_data[nxi+a]),p_catalog, type);
             if(status != SQL_S_SUCCESS)
              {
            continue;
               }
           if(!strcmp(type,"C") || !strcmp(type,"EXT"))
            {
            sql_str[0] = '\0';
     sprintf(sql_str,"SELECT t1.n_itemname,t1.n_itemrev,t1.n_itemdesc,t2.n_filetype,\
    t2.n_cofilename,t3.n_statename,t2.n_fileversion,t1.p_parttype , \
    t2.n_filenum, t1.n_status, t2.n_cosano FROM f_%s t2,nfmstates t3, %s t1 \
    WHERE \
    ((t1.n_itemno = %s AND t2.n_itemnum = %s) AND t3.n_stateno = t1.n_stateno) AND (t2.n_fileversion = (SELECT MAX(n_fileversion) FROM f_%s t2 WHERE t1.n_itemno = t2.n_itemnum)) ORDER BY n_itemname,n_itemrev,n_cofilename ", \
p_catalog,p_catalog, no_data[nxi+b],no_data[nxi+b], p_catalog);

            status = SQLquery(sql_str,&fcat_bufr,512);
            if(status != SQL_S_SUCCESS)
              {
              if(status ==  SQL_I_NO_ROWS_FOUND )
                {
                   MEMclose(&fcat_bufr);
                    continue;
                } 
               else 
                  {
                   MEMclose(&fcat_bufr);
	           _PDMdebug(fname,"EXIT:-Error\n");
                   return(status);
                   } 
               }
               status = MEMbuild_array(fcat_bufr);
               if (status != MEM_S_SUCCESS)
	        {
                     MEMclose(&fcat_bufr);
		  _PDMdebug(fname,"MEMbuild_array failed status %d\n",status);
		return(PDM_E_BUILD_ARRAY);
                }
                no_fcat_data = (char **)fcat_bufr->data_ptr;
                 for(w=0; w < fcat_bufr->rows; w++)
               {
                  wxi = w * fcat_bufr->columns;

sprintf(sql_str,"SELECT n_fileversion,  n_ref, n_co, n_copy from nfmsafiles where n_catalogno = %s and n_itemno = %s  and n_filenum = %s  and n_sano = %d ",no_data[nxi+a],no_data[nxi+b], no_fcat_data[wxi+8],storage->storage_no);

            status = SQLquery(sql_str,&fmgr_bufr,512);
             if(status != SQL_S_SUCCESS)
              {
                 if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
     if(!strcmp(no_fcat_data[wxi+9], "I") ) strcpy(p_local,"CHECKED IN");
 else if(!strcmp(no_fcat_data[wxi+9], "O") || !strcmp(no_fcat_data[wxi+9],"S")) 
     {
       status1 = PDMsano_to_name(atoi(no_fcat_data[wxi+10]),p_local);
        if(status1 != PDM_S_SUCCESS) strcpy(p_local,"OUT ELSEWHERE");
      }
    else if(!strcmp(no_fcat_data[wxi+9], "ON") ) strcpy(p_local,"ON TRANSFER");
    else if(!strcmp(no_fcat_data[wxi+9], "TI") ) strcpy(p_local,"ON TRANSFER");
    else if(!strcmp(no_fcat_data[wxi+9], "TO") ) strcpy(p_local,"ON TRANSFER");
     else strcpy(p_local,"NEVER CHECKED IN");
                     strcpy(p_update,"NA");
                     MEMclose(&fmgr_bufr);
                    } 
               else 
                    {
                     MEMclose(&fmgr_bufr);
                     MEMclose(&fcat_bufr);
	             _PDMdebug(fname,"EXIT:Error \n");
                     return(status);
                    } 
               }
              if(status != SQL_I_NO_ROWS_FOUND)
               {
               status = MEMbuild_array(fmgr_bufr);
               if(status != MEM_S_SUCCESS)
                {
		MEMclose(&fcat_bufr);
		MEMclose(&fmgr_bufr);
		_PDMdebug(fname,"MEMwrite_format failed status %d\n",status);
		return(PDM_E_BUILD_ARRAY);
                }
                no_fmgr_data = (char **)fmgr_bufr->data_ptr;
    if(!strcmp(no_fmgr_data[2],"Y") ) strcpy(p_local,"CHECKED OUT");
  else if(!strcmp(no_fmgr_data[3],"Y") && (atoi(no_fmgr_data[1]) == 0)) strcpy(p_local,"COPIED TO LOCAL");
  else if(atoi(no_fmgr_data[1]) > 0) strcpy(p_local,"ATTACHED");
  else  strcpy(p_local,"LOCAL");
if(atoi(no_fmgr_data[0])  < atoi(no_fcat_data[wxi+6])) strcpy(p_update ,"N");
                else strcpy(p_update,"Y");
               }
               mem_str[0] = '\0';
           sprintf(mem_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",p_catalog,no_fcat_data[wxi],no_fcat_data[wxi+1],no_fcat_data[wxi+2],no_fcat_data[wxi+3],no_fcat_data[wxi+4],p_local, no_fcat_data[wxi+5],p_update,no_fcat_data[wxi+7]);
              status = MEMwrite(*attr_list,mem_str);
               if(status != MEM_S_SUCCESS)
                {
		MEMclose(&fcat_bufr);
		MEMclose(&fmgr_bufr);
		_PDMdebug(fname,"MEMwrite_format failed status %d\n",status);
		return(PDM_E_WRITE_BUFFER);
                }
            } /* for all the multile files in the part */
          MEMclose(&fcat_bufr); fcat_bufr = NULL;
          MEMclose(&fmgr_bufr); fmgr_bufr = NULL;
           } /* If it a standard or a external catalog */
    else  if(!strcmp(type,"P") || !strcmp(type, "PXT"))
       {
    sql_str[0] = '\0';
     sprintf(sql_str,"SELECT t1.n_itemname, t1.n_itemrev, t1.n_itemdesc, t3.n_statename,t1.n_status FROM  nfmstates t3, %s t1 WHERE (t1.n_itemno = %s AND t3.n_stateno = t1.n_stateno)",  p_catalog,no_data[nxi+b]);
            status = SQLquery(sql_str,&fcat_bufr,512);
            if(status != SQL_S_SUCCESS)
              {
              if(status ==  SQL_I_NO_ROWS_FOUND )
                {
                   MEMclose(&fcat_bufr);
	         _PDMdebug(fname," <%s> <%d> doesn't exist\n", p_catalog,no_data[nxi+b]);
                    continue;
                } 
               else 
                  {
                   MEMclose(&fcat_bufr);
	    _PDMdebug(fname,"SQLquery failed status 0x%x.8>\n", status);
	           _PDMdebug(fname,"EXIT:-Error\n");
                   return(status);
                   } 
               }
               status = MEMbuild_array(fcat_bufr);
               if (status != MEM_S_SUCCESS)
	        {
                     MEMclose(&fcat_bufr);
	  _PDMdebug(fname,"MEMbuild_array failed status %d\n",status);
		return(PDM_E_BUILD_ARRAY);
                }
                no_fcat_data = (char **)fcat_bufr->data_ptr;
                 fmgr_bufr = NULL;
                 mem_str[0] = '\0';
    sprintf(mem_str,"%s\1%s\1%s\1%s\1PAR\1\1NA\1%s\1NA\1P\1",p_catalog,no_fcat_data[0],no_fcat_data[1],no_fcat_data[2],no_fcat_data[3]);
              status = MEMwrite(*attr_list,mem_str);
               if(status != MEM_S_SUCCESS)
                   {
		MEMclose(&fcat_bufr);
      _PDMdebug(fname,"MEMwrite_format failed status 0x%x.8>\n",status);
		return(PDM_E_WRITE_BUFFER);
                   }
          MEMclose(&fcat_bufr); fcat_bufr = NULL;
         } /* If it is a parametric catalog */
        else if(!strcmp(type,"EID") || !strcmp(type,"CID"))
         {
         sql_str[0] = '\0';
          sprintf( e_cat,"e_%s",p_catalog); 
     sprintf(sql_str,"SELECT t1.n_itemname, t1.n_itemrev, t1.n_itemdesc,t3.n_statename,t1.n_status FROM nfmstates t3,%s t1 WHERE t1.n_itemno = %s AND  t3.n_stateno = t1.n_stateno", e_cat, no_data[nxi+b]);
            status = SQLquery(sql_str,&fcat_bufr,512);
             if(status != SQL_S_SUCCESS)
              {
               if(status ==  SQL_I_NO_ROWS_FOUND )
                {
                MEMclose(&fcat_bufr);
	         _PDMdebug(fname," <%s> <%s> doesn't exist\n", p_catalog,no_data[nxi+b]);
	       _PDMdebug(fname,"EXIT:NO SUCH COMPUTED PART\n");
                continue;
                } 
               else 
                 {
                   MEMclose(&fcat_bufr);
       	       _PDMdebug(fname,"EXIT:- ERROR in selecting CID parts\n");
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
                no_fcat_data = (char **)fcat_bufr->data_ptr;
                fmgr_bufr = NULL;
                 mem_str[0] = '\0';
    sprintf(mem_str,"%s\1%s\1%s\1%s\1PAR\1\1NA\1%s\1NA\1P\1",p_catalog,no_fcat_data[0],no_fcat_data[1],no_fcat_data[2],no_fcat_data[3]);
       status = MEMwrite(*attr_list,mem_str);
             if(status != MEM_S_SUCCESS)
               {
        _PDMdebug(fname, "MEMwrite failed: status <0x%x.8> \n", status);
		MEMclose(&fcat_bufr);
	      _PDMdebug(fname,"EXIT:-ERROR\n");
                 return(PDM_E_WRITE_BUFFER);
               }
          MEMclose(&fcat_bufr); fcat_bufr = NULL;
         } /* If it a Computed ID catalog */
        } /* If there is a catalog */
          MEMclose(&fcat_bufr); fcat_bufr = NULL;
          MEMclose(&fmgr_bufr); fmgr_bufr = NULL;
      } /* For all the catalogs in the nos bufr */
     } /* If there is any information in nos bufr */

     if(status1 != MEM_S_SUCCESS && status2 != MEM_S_SUCCESS)
      {
          _PDMdebug(fname, "Both input buffers have problems\n");
	  _PDMdebug(fname,"EXIT-Error:\n");
        return(status1);
       }
	_PDMdebug(fname,"EXIT: -SUCCESS \n");
     return(PDM_S_SUCCESS);

}

long   PDMfind_entry_in_fmgr_bufr
(
int catno, 
int partno, 
char *n_filenum, 
char *n_fileversion, 
char *n_ref, 
char *n_co, 
char *n_copy, 
MEMptr fmgr_bufr
)
{
char            *fname = "PDMfind_entry_in_fmgr_bufr";
char            **data = NULL, **column = NULL;
int             i = 0,nxi = 0;


  _PDMdebug(fname, "Enter\n");

    if(fmgr_bufr && fmgr_bufr->rows > 0) {

/* */
     status = MEMbuild_array (fmgr_bufr);
     if (status != MEM_S_SUCCESS) {
        _PDMdebug (fname, "MEMbuild_array failed status %d\n",status);
        return (PDM_E_BUILD_ARRAY);
	}

     data = (char **) fmgr_bufr->data_ptr;
     column = (char **) fmgr_bufr->column_ptr;

     for (i= 0; i < fmgr_bufr->rows; i++) {
         nxi = i * fmgr_bufr->columns;
         _PDMdebug (fname, "Testing %d and %d with [%s] and [%s]\n",
                    catno, partno, data[nxi+4], data[nxi+5]);
         if((catno == atoi(data[nxi+4])) &&
            (partno == atoi(data[nxi+5])) &&
            (!strcmp(n_filenum, data[nxi+6])))
           {
             strcpy(n_fileversion, data[nxi]);
             strcpy(n_ref, data[nxi+1]);
             strcpy(n_co, data[nxi+2]);
             strcpy(n_copy, data[nxi+3]);
              _PDMdebug(fname, "Exit - Match found\n");
             return(PDM_S_SUCCESS);
            }
       }
     }
     _PDMdebug(fname, 
     "No entry found for catno <%d> partno <%d> fileno<%s> in LFM \n", 
     catno, partno, n_filenum);
      return(SQL_I_NO_ROWS_FOUND);
}

