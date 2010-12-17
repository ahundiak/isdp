#include		<stdio.h>
#include		"SQLerrordef.h"
#include 		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"PDMdbs_err.h"
#include		"MEMstruct.h"
#include		"PDUerror.h"
#include "NFMapi.h"
#include "NFMstruct.h"
#include		"PDMproto.h"
#include		"PDUpdmrpro.h"


extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static char     s[1024];
static long     status;
extern PDMexec_ptr PDMexec;

/* Author:  Stan Mckay, May 13, 1991, Search across catalogs */
/* Modified: Kumar oct. 11 1991 */
/*
 * DESCRIPTION: This function will perform a search for items across all the
 * catalogs that are in the nfmcatalogs(except the nfmsyscat) that belong to the
 * application. PARAMETERS:  PDMexecptr       PDMexec;
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
 * (1) names_bufr 
 * (2) in_attr_bufr 
 * 
 * 
 * OUTPUT: 
 *
 * out_buffer_list: This is a list of all items that the search returns.
 * The catalogname is enterred in the first column (not first release), 
 * followed by the other attributes requested by the user.
 * Common attributes are returned if in_attr_list is NULL or there is a
 * mismatch atrribute specified by the user. 
 * 
 * mis_attr_list: A list consisting of all the attributes specified by the user
 * that do not exist in the common attribute list.
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
PDMsearch_across_catalogs(names_bufr, in_attr_list, 
                          out_buffer_list, mis_attr_list)
	MEMptr          names_bufr;
	MEMptr          in_attr_list;
	MEMptr          *out_buffer_list;
	MEMptr          *mis_attr_list;
{

	PDMdebug("ENTER:PDMsearch_across_catalogs \n");

	*out_buffer_list = NULL;
	*mis_attr_list = NULL;
/*
	status = MEMreset_buffer(PDMexec->ws_buffer, &curbuf_no);
	if (status != MEM_S_SUCCESS) {
		PDMdebug("PDMsearch_across_catalogs:\n");
		sprintf(s, "\tMEMreset_buffer failed : status %d\n", status);
		PDMdebug(s);
		return (PDM_E_RESET_BUFFER);
	} else if (curbuf_no != 2) {
		PDMdebug("PDMsearch_across_catalogs:\n");
		sprintf(s, "\tIncorrect Number of Buffers Received\n");
		PDMdebug(s);
		PDMdebug("Second buffer couldnot be found \n");
		return (PDM_E_NUMBER_OF_BUFFERS);
	}

	status = MEMsplit_copy_buffer(PDMexec->ws_buffer, &names_bufr, 0);
	if (status != MEM_S_SUCCESS) {
		PDMdebug("PDMsearch_across_catalogs:\n");
		sprintf(s, "\tMEMsplit_copy_buffer failed : status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_COPY_BUFFER);
	}

	status = MEMreset_buffer(PDMexec->ws_buffer, &curbuf_no);
	if (status != MEM_S_SUCCESS) {
		PDMdebug("PDMsearch_across_catalogs:\n");
		sprintf(s, "\tMEMreset_buffer failed : status %d\n", status);
		PDMdebug(s);
		return (PDM_E_RESET_BUFFER);
	} else if (curbuf_no != 3) {
		PDMdebug("PDMsearch_across_catalogs:\n");
		sprintf(s, "\tIncorrect Number of Buffers Received\n");
		PDMdebug(s);
		PDMdebug("Third buffer couldnot be found \n");
		return (PDM_E_NUMBER_OF_BUFFERS);
	}
	status = MEMsplit_copy_buffer(PDMexec->ws_buffer, &in_attr_list, 0);
	if (status != MEM_S_SUCCESS) {
		PDMdebug("PDMsearch_across_catalogs:\n");
		sprintf(s, "\tMEMcopy_split_buffer failed : status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_COPY_BUFFER);
	}
*/
	if (PDMdebug_on) {
		MEMprint_buffer("names_bufr", names_bufr, PDM_DEBUG_FILE);
		MEMprint_buffer("in_attr_list", in_attr_list, PDM_DEBUG_FILE);
	}
	status = PDMi_search_across_catalogs(PDMexec->user_id, names_bufr,
					     in_attr_list, out_buffer_list, mis_attr_list,PDMexec->drawing);

	if ((status != PDM_S_SUCCESS) && (status != PDM_E_BAD_ATTRIBUTE)) {
		MEMclose(&names_bufr);
		MEMclose(&in_attr_list);
		MEMclose(out_buffer_list);
		MEMclose(mis_attr_list);
		PDMdebug("PDMsearch_across_catalogs:\n");
		sprintf(s, "\tPDMi_search_across_catalogs failed : status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	if (PDMdebug_on) {
		MEMprint_buffer("out_buffer_list", *out_buffer_list, PDM_DEBUG_FILE);
		MEMprint_buffer("mis_attr_list", *mis_attr_list, PDM_DEBUG_FILE);
	}
	if (*out_buffer_list != NULL) {
                sprintf(s,"OUT_BUFFER_LIST IS NOT NULL\n",PDM_DEBUG_FILE);
		PDMdebug(s);
		if (*mis_attr_list != NULL) {
			if (status != MEM_S_SUCCESS) {
				MEMclose(&names_bufr);
				MEMclose(&in_attr_list);
				PDMdebug("PDMsearch_across_catalogs:\n");
				sprintf(s, "\tMEMappend failed : status %d\n", 
                                        status);
				PDMdebug(s);
				return (PDM_E_APPEND_BUFFER);
			}
                sprintf(s,"MIS_ATTR_LIST IS NOT NULL\n",PDM_DEBUG_FILE);
		PDMdebug(s);
	        PDMdebug("EXIT:PDMsearch_across_catalogs \n");
 		return (PDM_E_BAD_ATTRIBUTE);
		}
	        PDMdebug("EXIT:PDMsearch_across_catalogs \n");
	        return (PDM_S_SUCCESS);
	}
	PDMdebug("EXIT:PDMsearch_across_catalogs \n");
	return (PDM_S_SUCCESS);
}

int 
PDMi_search_across_catalogs(user_id, names_bufr, in_attr_list, 
                            out_buffer_list, mis_attr_list, read_flag)

	long            user_id;
	MEMptr          names_bufr;
	MEMptr          in_attr_list;
	MEMptr         *out_buffer_list;
	MEMptr         *mis_attr_list;
{
	char           *string1 = NULL;
	char           *string2 = NULL;
	char           *string3 = NULL;
	char           *string4 = NULL;
        char           **names;
       struct  NFMquery_info query_info1;
       struct  NFMquery_info query_info2;
       struct  NFMquery_info query_info3;
       struct  NFMquery_info query_info4;


	
	PDMdebug("ENTER:PDMi_search_across_catalogs\n");

	status = MEMbuild_array(names_bufr);
	if (status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
        
	names = (char **) names_bufr->data_ptr;

     /* Extract LOC SEARCH CRITERIA */

          PDMinit_query_info_struct(&query_info1);
          PDMinit_query_info_struct(&query_info2);
          PDMinit_query_info_struct(&query_info3);
          PDMinit_query_info_struct(&query_info4);
  
        if(strcmp(read_flag,"READ"))
         {
	      if (!strcmp(names[0],"") )
	        {
		string1 = (char *) malloc (2);
		strcpy(string1, "");
                }
              else
                {
		string1 = (char *) malloc (strlen(names[0] ) +1);
		strcpy(string1, names[0]);
                 }

	}
	else
	{
            status = NFMretrieve_query(names[0],&query_info1);
                if(status != NFM_S_SUCCESS)
                 {
                  sprintf(s,"%s %d\n",
                "NFMretrieve_query failed status ",status);
                PDMdebug(s);
                return(PDM_E_RPS_READ_FORMAT);
                  }
                if(strlen(query_info1.where_clause))
                 {
	string1 = (char *) malloc (strlen(query_info1.where_clause) + 1);
                strcpy(string1,query_info1.where_clause);
                  }
                  else
                   {
		string1 = (char *) malloc (2);
                strcpy(string1,"");
                  }

	} 

     /* Extract LOC SORT CRITERIA */

        PDMdebug("EXTRACT LOC SORT CRITERIA\n"); 
        if(strcmp(read_flag,"READ"))
        {
	     if (!strcmp(names[1],""))
	        {
		if ((string2 = (char *) malloc (2)) == NULL)
		       {
			PDMdebug("Failed to malloc for STRING2\n");
			return(PDM_E_COULD_NOT_MALLOC);
		        }
		strcpy(string2, "");
                }
		else
		{
		string2 = (char *) malloc (strlen(names[1] ) + 1);
		strcpy(string2, names[1]);
		}
	}
	else
	{
            status = NFMretrieve_query(names[1],&query_info2);
                if(status != NFM_S_SUCCESS)
                 {
                  sprintf(s,"%s %d\n",
                "NFMretrieve_query failed status ",status);
                PDMdebug(s);
                return(PDM_E_RPS_READ_FORMAT);
                  }
                if(strlen(query_info2.order_by_clause))
                 {
	string2 = (char *) malloc (strlen(query_info1.order_by_clause) + 1);
                strcpy(string2,query_info1.order_by_clause);
                  }
                  else
                   {
		string2 = (char *) malloc (2);
                strcpy(string2,"");
                    }
	} 

     /* Extract CATALOG SEARCH CRITERIA */

        PDMdebug("CATALOG SEARCH CRITERIA\n");
    
        if(strcmp(read_flag,"READ"))
        {
	    if (!strcmp(names[2],""))
	      {
		if ((string3 = (char *) malloc (2)) == NULL)
		{
			PDMdebug("Failed to malloc for STRING3\n");
			return(PDM_E_COULD_NOT_MALLOC);
		}
		strcpy(string3, "");
                }
		else
		{
		string3 = (char *) malloc (strlen(names[2] ) +1);
		strcpy(string3, names[2]);
		}
	}
	else
	{
            status = NFMretrieve_query(names[2],&query_info3);
                if(status != NFM_S_SUCCESS)
                 {
                  sprintf(s,"%s %d\n",
                "NFMretrieve_query failed status ",status);
                PDMdebug(s);
                return(PDM_E_RPS_READ_FORMAT);
                  }
                if(strlen(query_info3.where_clause))
                 {
	string3 = (char *) malloc (strlen(query_info3.where_clause) + 1);
                strcpy(string3,query_info3.where_clause);
                  }
                  else
                   {
		string3 = (char *) malloc (2);
                strcpy(string3,"");
                  }
	} 

     /* Extract CATALOG SORT CRITERIA */

        PDMdebug("CATALOG SORT CRITERIA\n");
 
        if(strcmp(read_flag,"READ"))
        {
	        if (!strcmp(names[3],""))
	            {
		    if ((string4 = (char *) malloc (2)) == NULL)
		     {
			PDMdebug("Failed to malloc for STRING4\n");
			return(PDM_E_COULD_NOT_MALLOC);
		      }
		strcpy(string4, "");
                    }
		else
		      {
		string4 = (char *) malloc (strlen(names[3]) +1);
		strcpy(string4, names[3]);
		       }
	}
	else
	{
            status = NFMretrieve_query(names[4],&query_info4);
                if(status != NFM_S_SUCCESS)
                 {
                  sprintf(s,"%s %d\n",
                "NFMretrieve_query failed status ",status);
                PDMdebug(s);
                return(PDM_E_RPS_READ_FORMAT);
                  }
                if(strlen(query_info4.order_by_clause))
                 {
	string4 = (char *) malloc (strlen(query_info4.order_by_clause) + 1);
                strcpy(string4,query_info4.order_by_clause);
                  }
                  else
                   {
		string4 = (char *) malloc (2);
                strcpy(string4,"");
                    }
       }
/* Search across all the known catalogs for the items */

        PDMdebug("ENTER: NFMsearch_across_catalogs\n");

   
	status = NFMsearch_across_catalogs(user_id, string1, string2,
                                           string3, string4, in_attr_list,
                                           out_buffer_list, mis_attr_list);
        PDMdebug("NFMsearch_across_catalogs returns 0x%.8x\n", status);
	if ((status != NFM_S_SUCCESS) && (status != NFM_E_BAD_ATTRIBUTE)) {
		sprintf(s, "NFMsearch_across_catalogs failed : status 0x%.8x\n", 
                        status);
		PDMdebug(s);
                if (*out_buffer_list)
                  {
                  MEMclose(out_buffer_list);
                  *out_buffer_list = NULL;
                  }
                if (*mis_attr_list)
                  {
                  MEMclose(mis_attr_list);
                  *mis_attr_list = NULL;
                  }
		free(string4);
		free(string3);
		free(string2);
		free(string1);
         PDMfree_query_info_struct (query_info1);
         PDMfree_query_info_struct (query_info2);
        PDMfree_query_info_struct (query_info3);
         PDMfree_query_info_struct (query_info4);
               	return (PDM_E_SEARCH_CATALOG);
	}
        PDMdebug("printing buffers\n");

	if (PDMdebug_on) {
		MEMprint_buffer("out_buffer_list", *out_buffer_list, PDM_DEBUG_FILE);
		MEMprint_buffer("mis_attr_list", *mis_attr_list, PDM_DEBUG_FILE);
        }
	
        if ((status == NFM_S_SUCCESS) && (status == NFM_E_BAD_ATTRIBUTE))
        {  
		sprintf(s, "NFMsearch_across_catalogs status : 0x%.8x\n", status);
		PDMdebug(s);
        }

        if (strlen(string1)) free(string1);
        if (strlen(string2)) free(string2);
        if (strlen(string3)) free(string3);
        if (strlen(string4)) free(string4);

         /* Freeing the structs */

       
	sprintf(s, "PDMfree_query_info_struct \n");
	PDMdebug(s);
	if (strcmp(names[1],"")) PDMfree_query_info_struct (query_info1);
	if (strcmp(names[2],"")) PDMfree_query_info_struct (query_info2);
	if (strcmp(names[3],"")) PDMfree_query_info_struct (query_info3);
	if (strcmp(names[4],"")) PDMfree_query_info_struct (query_info4);

	sprintf(s, "EXIT:PDMi_search_across_catalogs \n");
	PDMdebug(s);
        if(status == NFM_E_BAD_ATTRIBUTE) return(PDM_E_BAD_ATTRIBUTE);
        else return (PDM_S_SUCCESS);
}


int 
PDMsearch_for_parts(names_bufr, return_buffer)
	MEMptr          names_bufr;
	MEMptr          *return_buffer;
{
	MEMptr          in_attr_list = NULL;
	MEMptr          catalog_buffer = NULL;
        MEMptr          out_buffer_list = NULL;
        MEMptr          temp_bufr = NULL;
        MEMptr          mis_attr_list = NULL;
        int             i,nxi,k,nxk,found,a = -1;
        char            **data, **data1, **column1;
        char            sql_str[1024];

	PDMdebug("ENTER:PDMsearch_for_parts \n");

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
        

        PDMdebug("ENTER: NFMsearch_across_catalogs\n");

   
	status = NFMsearch_across_catalogs(PDMexec->user_id, data[0],
                                          "",data[2], data[3], in_attr_list, &out_buffer_list, &mis_attr_list);
PDMdebug("after NFMsearch_across_catalogs\n");
	if ((status != NFM_S_SUCCESS) && (status != NFM_E_BAD_ATTRIBUTE)) {
		sprintf(s, "NFMsearch_across_catalogs failed : status 0x%.8x\n", 
                        status);
		PDMdebug(s);
                if (out_buffer_list) {
                  MEMclose(&out_buffer_list);
                  out_buffer_list = NULL; }
                if (mis_attr_list) {
                  MEMclose(&mis_attr_list);
                  mis_attr_list = NULL; }
               	return (PDM_E_SEARCH_CATALOG);
	}

	if (PDMdebug_on) {
		MEMprint_buffer("out_buffer_list", out_buffer_list, PDM_DEBUG_FILE);
		MEMprint_buffer("mis_attr_list", mis_attr_list, PDM_DEBUG_FILE);
        }

                if (mis_attr_list) {
                  MEMclose(&mis_attr_list);
                  mis_attr_list = NULL; }
	
        if ((status == NFM_S_SUCCESS) || (status == NFM_E_BAD_ATTRIBUTE))
        {  
		sprintf(s, "NFMsearch_across_catalogs status : 0x%.8x\n", status);
		PDMdebug(s);
        }
        status = MEMopen(&catalog_buffer,512);
        if(status != MEM_S_SUCCESS)
           {
                MEMclose(&out_buffer_list);
                out_buffer_list = NULL;
               return(PDM_E_OPEN_BUFFER);
           }
        status = MEMwrite_format(catalog_buffer,"n_catalogname","char(20)");
        if(status != MEM_S_SUCCESS)
           {
                MEMclose(&out_buffer_list);
                out_buffer_list = NULL;
               return(PDM_E_WRITE_FORMAT);
           }
        
	if (out_buffer_list != NULL) 
      {
          status = MEMbuild_array(out_buffer_list);
           if(status != MEM_S_SUCCESS)
             {
               MEMclose(&out_buffer_list);
               out_buffer_list = NULL;
               MEMclose(&catalog_buffer);
               catalog_buffer = NULL;
               return(PDM_E_BUILD_ARRAY);
              }
           data1 = (char **) out_buffer_list->data_ptr;
           column1 = (char **) out_buffer_list->column_ptr;

          for(i=0;i< out_buffer_list->columns; i++)
             {
               if(!strcmp(column1[i],"n_catalogname")) 
               {
                a = i;
                break;
                }
             }
             found = 0;
  if((strcmp(PDMexec->project,"")) && (PDMexec->project != NULL))
        {
            for(i=0; i < out_buffer_list->rows; i++)
              {
                  nxi = i * out_buffer_list->columns;
            for(k=0; k < i; k++)
                {
                  nxk = k * out_buffer_list->columns;
                   if(!strcmp(data1[nxi+a],data1[nxk+a]) ) found = 1;
                 }
                 if (found == 1) continue;
                sql_str[0]='\0';
                sprintf(sql_str,"SELECT nfmcatalogs.n_catalogname FROM nfmcatalogs,nfmpr ojects,nfmcatalogsamap,nfmprojectsamap WHERE nfmprojects.n_projectname = '%s' AN D nfmprojectsamap.n_projectno = nfmprojects.n_projectno AND nfmcatalogsamap.n_ma pno = nfmprojectsamap.n_mapno AND nfmcatalogsamap.n_catalogno = nfmcatalogs.n_catalogno AND nfmcatalogs.n_catalogname = '%s'",PDMexec->project,data1[nxi+a]);
        status = SQLquery(sql_str,&temp_bufr,1024);
        if(status != SQL_S_SUCCESS)
        {
              if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
                     MEMclose(&temp_bufr);
                     temp_bufr = NULL;
                     continue;
                    } 
               else 
                    {
                     MEMclose(&temp_bufr);
                     temp_bufr = NULL;
                     MEMclose(&out_buffer_list);
                     out_buffer_list = NULL;
                     MEMclose(&catalog_buffer);
                     catalog_buffer = NULL;
                     return(PDM_E_SQL_QUERY);
                    } 
        }
                  sql_str[0]='\0';
                  sprintf(sql_str,"%s\1",data1[nxi+a]);        
                  status = MEMwrite(catalog_buffer,sql_str);
          if(status != MEM_S_SUCCESS)
           {
                MEMclose(&out_buffer_list);
                     out_buffer_list = NULL;
               MEMclose(&catalog_buffer);
                     catalog_buffer = NULL;
             return(PDM_E_WRITE_BUFFER);
           }
           
        }/* end of the for loop of out_buffer_list */ 
       } /* if project != NULL */
       else
           {
            for (i=0; i < out_buffer_list->rows; i++)
               {
                 nxi = i * out_buffer_list->columns;
            for(k=0; k < i; k++)
                {
                  nxk = k * out_buffer_list->columns;
                   if(!strcmp(data1[nxi+a],data1[nxk+a]) ) found = 1;
                 }
                 if (found == 1) continue;
                  sql_str[0]='\0';
                  sprintf(sql_str,"%s\1",data1[nxi+a]);        
                  status = MEMwrite(catalog_buffer,sql_str);
                 if(status != MEM_S_SUCCESS)
                  {
                       MEMclose(&out_buffer_list);
                     out_buffer_list = NULL;
                    MEMclose(&catalog_buffer);
                     catalog_buffer = NULL;
                    return(PDM_E_WRITE_BUFFER);
                  }
               }
                 
           }  
     } /* if out_buffer_list != NULL */
     else 
          {
            *return_buffer = NULL;
            return(PDM_E_NO_CATALOGS_FOUND);
           }

    if (PDMdebug_on)
      MEMprint_buffer("catalog_buffer", catalog_buffer, PDM_DEBUG_FILE);

    MEMsplit_copy_buffer(catalog_buffer, return_buffer, 0);

    if (out_buffer_list) {
        MEMclose(&out_buffer_list);
        out_buffer_list = NULL; }
    if (catalog_buffer) {
        MEMclose(&catalog_buffer);
        catalog_buffer = NULL; }

	PDMdebug("EXIT:PDMsearch_for_parts \n");
	return (PDM_S_SUCCESS);
}
