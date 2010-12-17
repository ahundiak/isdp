#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDMdbs_err.h"
#include		"PDMproto.h"
#include		"PDUpdmrpro.h"

static	long		status;
static	char		s[1024];


extern	int			PDMdebug_on;
extern  char		PDM_DEBUG_FILE[];
extern  PDMexec_ptr	PDMexec;


int PDMget_children_attachments(user_id,n_catalogname,n_itemname,n_itemrev,
                                return_buffer)
long user_id;
char *n_catalogname;
char *n_itemname;
char *n_itemrev;
MEMptr *return_buffer;
{
	char		sql_str[512];
	char		n_setindicator[5];
        char		**temp_data;
	char		**column_ptr;
	char 		**data;
	int			n_itemno;
	int			i;
	int			n1 = -1;
	int			n2 = -1;
	int			n3 = -1;
	int			n4 = -1;
	int			n5 = -1;
        int             nxm;
	MEMptr		set_attr = NULL;
	MEMptr		set_data = NULL;
	MEMptr		table_bufr = NULL;
	MEMptr		temp_bufr = NULL;
        char            a_row[512];
        char            filename[20];
        char            p_parttype[2];
        char            p_attached[2];
 /* BETH 7/28/91 should use active_bom not review */
        char            active_bom[40];
       

   PDMdebug("ENTER:PDMget_children_attachments\n");

	/* get n_itemno and n_setindicator */

   sql_str[0] = '\0';
   sprintf(sql_str,"%s FROM %s %s '%s' %s '%s'",
   "SELECT n_setindicator,n_itemno ",n_catalogname,
   "WHERE n_itemname = ",n_itemname,
   "AND n_itemrev = ",n_itemrev);
	
   status = SQLquery(sql_str,&temp_bufr,512);
   if(status != SQL_S_SUCCESS)
   {
		MEMclose(&temp_bufr);
		switch(status)
		{
			case SQL_I_NO_ROWS_FOUND :
				 sprintf(s,"%s %s %s %s \n",
				 "PDMget_children: Could not find Part ",
				 n_itemname,n_itemrev);
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
				 n_catalogname);
				 PDMdebug(s);
		  		 return(PDM_E_CATALOG_NOT_FOUND);
			default:
				 return(PDM_E_SQL_QUERY);
		}			
   }
   status = MEMbuild_array(temp_bufr);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&temp_bufr);
		sprintf(s,"%s %d\n",
		"PDMget_children: MEMbuild_array failed status ",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   temp_data = (char **) temp_bufr->data_ptr;
   n_setindicator[0] = '\0';
   strcpy(n_setindicator,temp_data[0]);
   n_itemno = atol(temp_data[1]);
   MEMclose(&temp_bufr);
   temp_bufr = NULL;
   if(!strncmp(n_setindicator,"N",1) ||
	  !strncmp(n_setindicator,"n",1) ||
	  !strcmp(n_setindicator,""))
   {
		sprintf(s,"n_setindicator <%s>\n",n_setindicator);
		PDMdebug(s);
		return(PDM_E_PART_NOT_ASSEMBLY);
   }

   /* a direct join on nfmcit and pdmcit is not possible 
	  because nfmcit has indices which are to be resolved 
      before the actual data can be accessed */
   status = NFMquery_set_members(user_id,n_catalogname,
			n_itemname,n_itemrev,50,0,
			&set_attr,&set_data);
   if(status != NFM_S_SUCCESS)
   {
		sprintf(s," %s %s %d \n",
		"PDMget_children: NFMquery_set_members ",
		" failed status -> ",status);
		PDMdebug(s);
		return(PDM_E_QUERY_SET_MEMBERS);
   }
   MEMclose(&set_attr);
   status = MEMbuild_array(set_data);
   if(status != MEM_S_SUCCESS)
   {

		MEMclose(&set_data);
		sprintf(s," %s %s %d \n",
		"PDMget_children : MEMbuild_array ",
		" failed status -> ",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   column_ptr = (char **) set_data->column_ptr;
   data = (char **) set_data->data_ptr;
   if(PDMdebug_on)
     {
      MEMprint_buffer("set_data bufr",set_data,PDM_DEBUG_FILE);
     }
   for(i=0;i<set_data->columns;i++)
   {	
		if(!strcmp(column_ptr[i],"n_catalogname"))  n1 = i;
		if(!strcmp(column_ptr[i],"n_itemname"))  	n2 = i;
		if(!strcmp(column_ptr[i],"n_itemrev"))  	n3 = i;
		if(!strcmp(column_ptr[i],"n_citno"))  	n4 = i;
		if(!strcmp(column_ptr[i],"n_level"))  	n5 = i;
   }
   if(n1 == -1 || n2 == -1 || n3 == -1  || n4 == -1 || n5 == -1)
   {
	        MEMclose(&set_data);
		PDMdebug("PDMget_children : Failed to set offsets \n");
  		return(PDM_E_BUFFER_FORMAT);
   }
   status = MEMopen(&table_bufr,1024);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&set_data);
		sprintf(s,"MEMopen failed status %d \n",status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
   }
   status = MEMwrite_format(table_bufr,"n_catalogname","char(20)");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"n_itemname","char(30)");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"n_itemrev","char(30)");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"n_cofilename","char(14)");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"n_catalogno","integer");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"n_itemno","integer");
   if(status == MEM_S_SUCCESS) 
/* Added p_level since update_file_manager expects the buffer to contain 
   level info also -MaC 7/27/91 (fixing cancelpartchkout prob) */
   status = MEMwrite_format(table_bufr,"p_level","integer");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(table_bufr,"p_mtype","integer");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&set_data);
		MEMclose(&table_bufr);
		sprintf(s,"MEMwrite_format failed status %d \n",status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
/* BETH 7/28/91 should use the active bom instead of the review 
review_bom[0] = '\0';
        status = PDMquery_bom_name(n_catalogname,
                                   n_itemname,
                                   n_itemrev,
                                   "R", review_bom);
*/
active_bom[0] = '\0';
        status = PDMquery_bom_name(n_catalogname,
                                   n_itemname,
                                   n_itemrev,
                                   "A", active_bom);
        if (status != PDM_S_SUCCESS &&
            status != PDM_E_BOM_NOT_FOUND) {
                sprintf(s, "PDMquery_bom_name failed status %d\n", status);
                PDMdebug(s);
                return (status);
        }
   
/* Load the  part from info in pdmcit */
     

for(i=0;i<set_data->rows;i++)
         {
        nxm = i * set_data->columns;
status = PDMquery_parttype(data[nxm+n1], data[nxm+n2],
                                   data[nxm+n3], p_parttype);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMquery_parttype failed status %d\n",
                        status);
                PDMdebug(s);
        }
if (!strncmp(p_parttype, "N", 1) || !strncmp(p_parttype, "n", 1)) continue; 
       p_attached[0]='\0';
              if(i == 0) strcpy(p_attached,"Y");
  if (atol(data[nxm+n5]) == 1)
      {
status = PDMquery_cit_attachment( atol(data[nxm + n4]), p_attached);
                if (status != PDM_S_SUCCESS) {
                        sprintf(s, "PDMquery_cit_attachment failed status %d\n",
                                status);
                        PDMdebug(s);
                        sprintf(s, "p_citno = %d\n", atol(data[nxm + n4]));
                        PDMdebug(s);
                }
		if ((!strncmp(p_attached, "N", 1) ||
		    !strncmp(p_attached, "n", 1) ||
		    !strcmp(p_attached, "")) && (strlen(active_bom))) {
	                status = PDMquery_bom_attachment(active_bom, 
					data[nxm+n2],data[nxm+n3],data[nxm+n1],
					 atol(data[nxm+n5]),p_attached);
	                if (status != PDM_S_SUCCESS) {
                        sprintf(s, "PDMquery_bom_attachment failed status %d\n",
                                status);
                        PDMdebug(s);
                        continue;
 	                }
	         }

       }
/* BETH 7/28/91 should use the active bom instead of the review
  else if ((atol(data[nxm+n5]) > 1) && strlen(review_bom))
*/
  else if ((atol(data[nxm+n5]) > 1) && strlen(active_bom))
         {
                status = PDMquery_bom_attachment(active_bom, data[nxm+n2],
data[nxm+n3],data[nxm+n1], atol(data[nxm+n5]),p_attached);
                if (status != PDM_S_SUCCESS) {
                        sprintf(s, "PDMquery_bom_attachment failed status %d\n",
                                status);
                        PDMdebug(s);
                        continue;
                }
         }
filename[0]='\0';
        status = PDMi_find_cofilename(data[nxm+n1],data[nxm+n2],data[nxm+n3], filename);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMi_find_cofilename failed status %d\n",
                        status);
                PDMdebug(s);
                return (status);
        }

   if (!strncmp(p_attached, "Y", 1) || !strncmp(p_attached, "y", 1)) 
        {
        sprintf(a_row,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
                        data[nxm+n1],data[nxm+n2],data[nxm+n3],
                        filename,"","",data[nxm+n5],"Y");
                status = MEMwrite(table_bufr,a_row);
                    if(status != MEM_S_SUCCESS)
                        {
                                MEMclose(table_bufr);
                                free(a_row); 
                                sprintf(s,"MEMwrite failed status %d\n",
                                status); PDMdebug(s);
                                return(PDM_E_WRITE_ROW);
                        }
         }
        }                  /* end of for */

            free(a_row);

         /* load n_catalogno, n_itemno for new files */

         status = PDMload_partnos(table_bufr);
         if(status != PDM_S_SUCCESS )
                {
                        MEMclose(table_bufr);
                        sprintf(s,"PDMload_partnos failed status %d\n",
                        status); PDMdebug(s);
                        return(status);
                }
          if(PDMdebug_on)
          {
          MEMprint_buffer("file_list of the part",
                                                table_bufr,PDM_DEBUG_FILE);
           }

        *return_buffer = table_bufr;
        return(PDM_S_SUCCESS);

}

int PDMmake_file_list(n_catalogname,n_itemname,n_itemrev,
                                return_buffer)
char *n_catalogname;
char *n_itemname;
char *n_itemrev;
MEMptr *return_buffer;

{
   MEMptr   table_bufr = NULL;
   int      n_catalogno,n_itemno;
   char     n_cofilename[40];
   char     a_row[512];

   
   status = MEMopen(&table_bufr,1024);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&table_bufr);
		sprintf(s,"MEMopen failed status %d \n",status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
   }
   status = MEMwrite_format(table_bufr,"n_catalogname","char(20)");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"n_itemname","char(30)");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"n_itemrev","char(30)");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"n_cofilename","char(14)");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"n_catalogno","integer");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"n_itemno","integer");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"p_mtype","integer");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"p_level","integer");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&table_bufr);
		sprintf(s,"MEMwrite_format failed status %d \n",status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = PDMi_find_cofilename(n_catalogname,n_itemname,
             n_itemrev,n_cofilename);
   if(status != PDM_S_SUCCESS)
   {
     return(status);       
   }
   status = PDMquery_catalog_partnos(n_catalogname,n_itemname,
            n_itemrev,&n_catalogno,&n_itemno);
   if(status != PDM_S_SUCCESS)
   {
    return(status);
   }

        sprintf(a_row,"%s\1%s\1%s\1%s\1%d\1%d\1%s\1%s\1",
         n_catalogname,n_itemname,n_itemrev,
         n_cofilename,n_catalogno,n_itemno,"Y","");
                status = MEMwrite(table_bufr,a_row);
                    if(status != MEM_S_SUCCESS)
                        {
                                free(a_row); 
                                sprintf(s,"MEMwrite failed status %d\n",
                                status); PDMdebug(s);
                                return(PDM_E_WRITE_ROW);
                        }

            free(a_row);
         *return_buffer = table_bufr;
         return(PDM_S_SUCCESS);

}


int PDMmake_attach_bufr(n_catalogname,n_itemname,n_itemrev,
                                attach_buffer)
char *n_catalogname;
char *n_itemname;
char *n_itemrev;
MEMptr *attach_buffer;

{
   MEMptr   table_bufr = NULL;
   char     a_row[512];

   PDMdebug("ENTER: PDMmake_attach_bufr\n"); 
   status = MEMopen(&table_bufr,512);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&table_bufr);
		sprintf(s,"MEMopen failed status %d \n",status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
   }
   status = MEMwrite_format(table_bufr,"p_seqno","integer");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"n_catalogname","char(20)");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"n_itemname","char(30)");
   if(status == MEM_S_SUCCESS) 
   status = MEMwrite_format(table_bufr,"n_itemrev","char(30)");
   if(status != MEM_S_SUCCESS)
   status = MEMwrite_format(table_bufr,"p_childno","integer");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&table_bufr);
		sprintf(s,"MEMwrite_format failed status %d \n",status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
        sprintf(a_row,"%d\1%s\1%s\1%s\1%d\1",
         0,n_catalogname,n_itemname,n_itemrev);
                status = MEMwrite(table_bufr,a_row);
                    if(status != MEM_S_SUCCESS)
                        {
                                free(a_row); 
                                sprintf(s,"MEMwrite failed status %d\n",
                                status); PDMdebug(s);
                                return(PDM_E_WRITE_ROW);
                        }

            free(a_row);
         *attach_buffer = table_bufr;
   PDMdebug("EXIT: PDMmake_attach_bufr\n"); 
         return(PDM_S_SUCCESS);

}

 /* This function gets the no. of attachments of a part to a
    1 level parent of the cit and nth level in the review bom */


int PDMget_attach_count(p_type,n_catalogname,n_itemname,n_itemrev,
                         c_catalogname,c_partnum,c_revision,p_level,attach_count)
char   *n_catalogname;
char   *n_itemname;
char   *n_itemrev;
char   *c_catalogname;
char   *c_partnum;
char   *c_revision;
int    p_level;
int    *attach_count;
int    p_type;

{

int    n_catalogno;
int    p_itemno;
int    c_catalogno;
int    c_itemno;
/* APOGEE START */
/*
int    count1 = 0,count2 = 0,k,total;
*/
/* APOGEE END */

int    count1 = 0,count2 = 0,k;
char   sql_str[512];
char   **temp_data;
MEMptr temp_bufr = NULL;
MEMptr cit_bufr = NULL;
char   bom_name[40];

   
   PDMdebug("ENTER:PDMget_attach_count\n");
   status = PDMquery_catalog_partnos(n_catalogname,n_itemname,n_itemrev,
                                     &n_catalogno,&p_itemno);
    if(status != PDM_S_SUCCESS)
    {
      return(PDM_E_PART_NOT_FOUND);
    }
   status = PDMquery_catalog_partnos(c_catalogname,c_partnum,c_revision,
                                     &c_catalogno,&c_itemno);
    if(status != PDM_S_SUCCESS)
    {
      return(PDM_E_PART_NOT_FOUND);
    }

    sprintf(sql_str,"%s %s %d %s %d %s %d %s %d",
          "SELECT n_citno FROM nfmsetcit ",
          "WHERE n_pcatalogno =",n_catalogno,
          "AND n_pitemno =",p_itemno,
          "AND n_ccatalogno =",c_catalogno,
          "AND n_citemno =",c_itemno);
           status = SQLquery(sql_str,&temp_bufr,512);
           if(status != SQL_S_SUCCESS)
           {
               if(status == SQL_I_NO_ROWS_FOUND)
               {
               count1 = 0; 
               goto bom_attach;
               }
               else
               return(PDM_E_SQL_QUERY);
           }
            status = MEMbuild_array(temp_bufr);
            if(status != MEM_S_SUCCESS)
            {
               MEMclose(&temp_bufr);
               return(PDM_E_BUILD_ARRAY);
            }
      temp_data = (char **)temp_bufr->data_ptr;
   for(k=0;k<temp_bufr->rows;k++)
       {
    sprintf(sql_str,"%s %s  %s %s '%s'",
          "SELECT p_attached FROM pdmcit ",
          "WHERE p_citno =",temp_data[k],
           " AND p_attached = ","Y");
           status = SQLquery(sql_str,&cit_bufr,512);
           if(status != SQL_S_SUCCESS)
           {
               if(status == SQL_I_NO_ROWS_FOUND)
               {
               count1 = 0; 
               goto bom_attach;
               }
               else
               return(PDM_E_SQL_QUERY);
           }
       } 
            count1 = cit_bufr->rows;
sprintf (s, "count1 = %d\n", count1);
PDMdebug(s);
            MEMclose(&temp_bufr);
            MEMclose(&cit_bufr);

bom_attach:
PDMdebug ("In bom_attach:\n");


   status = PDMquery_bom_name(n_catalogname,n_itemname,n_itemrev,
                              "A",bom_name);

    if(status != PDM_S_SUCCESS)
    {
         status = PDMquery_bom_name(n_catalogname,n_itemname,n_itemrev,
                              "R",bom_name);
         if(status != PDM_S_SUCCESS)
         goto total;
          
    }
   
/* Load the no of attachments of the part from info in review bom */  

        if(strlen(bom_name))
        {
         status = PDMcount_bom_attachments(p_type,bom_name,c_catalogname,
                  c_partnum,c_revision,p_level,&count2);
          if (status != PDM_S_SUCCESS)
            {
               goto total;
             }
sprintf (s, "count2 = %d\n", count2);
PDMdebug(s);
        }

total:

        *attach_count = count1 + count2;
/*
PDMdebug ("In total:\n");
        total = count1 + count2;
sprintf (s, "attach_count = %d\n", total );
PDMdebug(s);
*/
        if(*attach_count == 0)
        {
   PDMdebug("attach_count was zero; and has been set to 1.\n");
           *attach_count =1;
        }
      PDMdebug("EXIT: PDMget_attach_count\n");
      return(PDM_S_SUCCESS);

}
        
/*
	DESCRIPTION:
				 Lists saved views of the part in a buffer
    OUTPUT:
			 If successfull the return_buffer contains all 
		the saved views . The format is as follows.

		char(100)		p_origin
   		char(528)		p_rotation
	   	char(40)	 	p_viewname

    RETURN CODES:
	PDM_S_SUCCESS	
	PDM_E_PART_NOT_FOUND
    PDM_E_CATALOG_NOT_FOUND
	PDM_E_BUILD_ARRAY
	
	PDM_E_NO_VIEWS_DEFINED
	PDM_E_VIEWS_TABLE_NOT_FOUND
*/

int PDMsshow_saved_views(temp_bufr)
	MEMptr		*temp_bufr;
{
	char		sql_str[512];
	int			n_itemno;
	char		sv_table[40];
	char		**temp_data;

   PDMdebug("ENTER:PDMsshow_saved_views\n");

   *temp_bufr = NULL;

   status = PDMverify_part(PDMexec->catalog,
			PDMexec->part_num,PDMexec->revision);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s,"%s %d\n",
		"PDMverify_part failed ",status);
		PDMdebug(s);
		return(status);
   }
   sprintf(sv_table,"v_%s",PDMexec->catalog);

	/* get n_itemno */

   sql_str[0] = '\0';
   sprintf(sql_str,"%s FROM %s %s '%s' %s '%s'",
   "SELECT n_itemno ",PDMexec->catalog,
   "WHERE n_itemname = ",PDMexec->part_num,
   "AND n_itemrev = ",PDMexec->revision);
	
   status = SQLquery(sql_str,temp_bufr,512);
   if(status != SQL_S_SUCCESS)
   {
		MEMclose(temp_bufr);
		switch(status)
		{
			case SQL_I_NO_ROWS_FOUND :
				 sprintf(s,"%s %s %s %s \n",
				 "Could not find Part ",
				 PDMexec->part_num,PDMexec->revision);
				 PDMdebug(s);
		  		 return(PDM_E_PART_NOT_FOUND);
			case PDMS_NO_SUCH_ATTRIBUTE:
				 sprintf(s,"%s %s  \n",
				 "Could not ",
				 "find a required column in catalog");
				 PDMdebug(s);
		  		 return(PDM_E_REQ_COLUMN_NOT_FOUND);
			case PDMS_NO_SUCH_TABLE:
				 sprintf(s,"%s %s \n",
				 "Could not find Catalog ",
				 PDMexec->catalog);
				 PDMdebug(s);
		  		 return(PDM_E_CATALOG_NOT_FOUND);
			default:
				 return(PDM_E_SQL_QUERY);
		}			
   }
   status = MEMbuild_array(*temp_bufr);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(temp_bufr);
		sprintf(s,"%s %d\n",
		"MEMbuild_array failed status ",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   temp_data = (char **) (*temp_bufr)->data_ptr;
   n_itemno = atol(temp_data[0]);
   MEMclose(temp_bufr);
   *temp_bufr = NULL;
 
   /* select all the saved views */

   sql_str[0] = '\0';
   sprintf(sql_str,"%s %s %s %d",
   "SELECT p_origin,p_rotation,p_viewname FROM ",
   sv_table,"WHERE n_itemno = ",n_itemno);
   status = SQLquery(sql_str,temp_bufr,2048);
   if(status != SQL_S_SUCCESS)
   {
		MEMclose(temp_bufr);
		switch(status)
		{
			case SQL_I_NO_ROWS_FOUND :
				 sprintf(s,"%s \n",
				 "No views defined found ");
				 PDMdebug(s);
		  		 return(PDM_E_NO_VIEWS_DEFINED);
			case PDMS_NO_SUCH_ATTRIBUTE:
				 sprintf(s,"%s %s %s \n",
				 "PDMsshow_saved_views: Could not ",
				 "find a required column in ",sv_table);
				 PDMdebug(s);
		  		 return(PDM_E_REQ_COLUMN_NOT_FOUND);
			case PDMS_NO_SUCH_TABLE:
				 sprintf(s,"%s %s \n",
				 "PDMsshow_saved_views: Could not find ",sv_table);
				 PDMdebug(s);
		  		 return(PDM_E_VIEWS_TABLE_NOT_FOUND);
			default:
				return(PDM_E_SQL_QUERY);
		}		
   }
   PDMdebug("EXIT:PDMsshow_saved_views\n");
   return(PDM_S_SUCCESS);
}


int PDMget_saved_views(temp_bufr)
	MEMptr		*temp_bufr;
{
	char		sql_str[512];
	int			n_itemno;
	char		sv_table[40];

   PDMdebug("ENTER:PDMget_saved_views\n");
   sprintf(sv_table,"v_%s",PDMexec->catalog);

	/* get n_itemno */

status = PDMris_get_pitemno(&n_itemno,PDMexec->catalog,
                        PDMexec->part_num, PDMexec->revision);
	
   if(status != SQL_S_SUCCESS)
   {
		switch(status)
		{
			case SQL_I_NO_ROWS_FOUND :
				 sprintf(s,"%s %s %s %s \n",
				 "Could not find Part ",
				 PDMexec->part_num,PDMexec->revision);
				 PDMdebug(s);
		  		 return(PDM_E_PART_NOT_FOUND);
			default:
				 return(PDM_E_SQL_QUERY);
		}			
   }
 
   /* select all the saved views */

   sql_str[0] = '\0';
   sprintf(sql_str,"%s %s %s %d",
   "SELECT p_viewname FROM ",
   sv_table,"WHERE n_itemno = ",n_itemno);
   status = SQLquery(sql_str,temp_bufr,2048);
   if(status != SQL_S_SUCCESS)
   {
		switch(status)
		{
			case SQL_I_NO_ROWS_FOUND :
				 sprintf(s,"%s \n",
				 "No views defined found ");
				 PDMdebug(s);
		  		 return(PDM_E_NO_VIEWS_DEFINED);
			case PDMS_NO_SUCH_ATTRIBUTE:
				 sprintf(s,"%s %s %s \n",
				 "PDMshow_saved_views: Could not ",
				 "find a required column in ",sv_table);
				 PDMdebug(s);
		  		 return(PDM_E_REQ_COLUMN_NOT_FOUND);
			case PDMS_NO_SUCH_TABLE:
				 sprintf(s,"%s %s \n",
				 "PDMshow_saved_views: Could not find ",sv_table);
				 PDMdebug(s);
		  		 return(PDM_E_VIEWS_TABLE_NOT_FOUND);
			default:
				return(PDM_E_SQL_QUERY);
		}		
   }
   PDMdebug("EXIT:PDMget_saved_views\n");
   return(PDM_S_SUCCESS);
}

int PDMmodify_assembly(assembly,attach_bufr)
MEMptr	assembly;
MEMptr	*attach_bufr;
{
	char	**data;
	int		i,nxi;
	char	p_parttype[2];
        char	filename[20];
	
	PDMdebug("ENTER:PDMmodify_assembly\n");
	status = MEMbuild_array(assembly);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	status = PDMi_prepare_buffer1(attach_bufr);
	if(status != PDM_S_SUCCESS)
	{
    	sprintf(s,"PDMi_prepare_buffer1 failed status %d\n",status);
		PDMdebug(s);
		return(status);
	}
	data = (char **) assembly->data_ptr;
	for(i=0;i<assembly->rows;i++)
	{
		nxi = i * assembly->columns;
		p_parttype[0] = '\0';
		status = PDMquery_parttype(data[nxi+1],data[nxi+2],
						data[nxi+3],p_parttype);
		if(status != PDM_S_SUCCESS)
		{
			sprintf(s,"PDMquery_parttype failed status %d\n",
			status); PDMdebug(s);
		}

                status = PDMi_find_cofilename(data[nxi+1],data[nxi+2],
						data[nxi+3],filename);
		sprintf(s,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
		data[nxi+1],data[nxi+2],data[nxi+3],data[nxi+0],
		filename,p_parttype,"","Y",data[nxi+5]);
		status = MEMwrite(*attach_bufr,s);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(attach_bufr);
			sprintf(s,"MEMwrite failed status %d\n",
			status); PDMdebug(s);
			return(PDM_E_WRITE_ROW);
		}
	}
	PDMdebug("EXIT:PDMmodify_assembly\n");
	return(PDM_S_SUCCESS);
}


