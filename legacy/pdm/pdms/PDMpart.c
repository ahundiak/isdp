#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"NFMapi.h"
#include "NFMfto_buf.h"
#include                "WFexterns.h"
#include                "ERR.h"
#include		"PDMproto.h"
#include		"PDUpdmrpro.h"
#include		"PDMmessage.h"


extern	int 	PDMdebug_on;
extern	char	PDM_DEBUG_FILE[];
extern	char	glob_var[100];
static int		status;
static char		s[1024];
extern PDMexec_ptr PDMexec;
extern PDMpart_ptr PDMpart;

/* DESCRIPTION: adds a part to the catalog with multiple files per part.

   PARAMETERS:  PDMexecptr       PDMexec;

   INPUT:	PDMexec, attr_list, data_list, filelist_list 

   The following fields of PDMexec are REQUIRED.
	PDMexec->catalog
	PDMexec->part_num
	PDMexec->revision

   OUTPUT : None

   RETURN CODES:
  PDM_S_SUCCESS    			SUCCESS
  PDM_E_RESET_BUFFER
  PDM_E_COPY_BUFFER
  PDM_E_NUMBER_OF_BUFFERS
  PDM_E_PART_EXISTS			Part num and rev are not unique 
  PDM_E_ADD_ITEM			NFM function for adding item failed

Kumar 8/12/92

*/

int PDMadd_part(attr_list, data_list, filelist_list)
	MEMptr		attr_list;
	MEMptr		data_list;
	MEMptr		filelist_list;
{
	char		**column_ptr;
	char		**data;
	int		i = 0,a1 = -1,a2 = -1, n_itemno;
        MEMptr          dummy_attr = NULL;
        MEMptr          dummy_data = NULL;
        MEMptr          dummy_list = NULL;
        char            message[512];
        char            *fname = "PDMadd_part";
	long            status = PDM_S_SUCCESS;


	_PDMdebug(fname,"ENTER :\n");

 	/* may have to load some PDM data here */

	status = MEMbuild_array(data_list);
	if(status != MEM_S_SUCCESS)
	{
       _PDMdebug(fname,"MEMbuild_array failed : status %d\n", status);
	return(PDM_E_BUILD_ARRAY);
	}
        if(PDMdebug_on)
        {
	MEMprint_buffer("attr_list",attr_list,PDM_DEBUG_FILE);
	MEMprint_buffer("data_list",data_list,PDM_DEBUG_FILE);
        }

	column_ptr = (char **) data_list->column_ptr;
	data = (char **) data_list->data_ptr;
	a1 = -1; a2 = -1;
	for(i=0;i<data_list->columns;i++)
	{
		if(!strcmp(column_ptr[i],"p_maxlevel")) a1 = i;
		if(!strcmp(column_ptr[i],"p_explode"))  a2 = i;
	}
	if(a1 == -1 || a2 == -1)
	{
       _PDMdebug(fname,"failed to set offsets in data_list\n");
        return(PDM_E_BUFFER_FORMAT);
	}
	if(!strcmp(data[a1],"") || !strlen(data[a1]))
	{
		/* default p_maxlevel is 0 */

		s[0] = '\0';
		sprintf(s,"%d",0);
		status = MEMwrite_data(data_list,s,1,a1+1);
		if(status != MEM_S_SUCCESS)
		{
		_PDMdebug(fname,"MEMwrite_data failed : status %d\n", status);
		return(PDM_E_WRITE_COLUMN);
		}
	}

	/* if p_explode is not set default to Y */

	if(!strcmp(data[a2],"") || !strlen(data[a2]))
	{
		status = MEMwrite_data(data_list,"Y",1,a2+1);
		if(status != MEM_S_SUCCESS)
		{
	        _PDMdebug(fname,"MEMwrite_data failed : status %d\n", status);
		return(PDM_E_WRITE_COLUMN);
		}
	}

   status = NFMadd_item(PDMexec->user_id,PDMexec->catalog, attr_list,data_list);
    if(status != NFM_S_SUCCESS)
    {
	_PDMdebug(fname,"NFMadd_item failed status -> %d \n", status);
        if(status == NFM_E_DUP_ITEM) return(PDM_E_PART_EXISTS);
        else
           {
              ERRget_specific_number (NFM, &status);
              ERRget_specific_message (NFM, message);
             _PDMdebug (fname, "status = <0x%.8x>\n", status);
             _PDMdebug (fname, "MESSAGE \n%s\n", message);
             _PDMdebug (fname, "****ADD PART FAILED *****\n");
             return(status);
            }
    }    
    if(filelist_list != NULL)
     {
      if(PDMdebug_on)
        MEMprint_buffer("Add file to Item - filelist_list",filelist_list,PDM_DEBUG_FILE);
	status = MEMbuild_array(filelist_list);
	if(status != MEM_S_SUCCESS && status != MEM_E_NULL_BUFFER)
	{
         NFMdelete_item(PDMexec->user_id, PDMexec->catalog,PDMexec->part_num,PDMexec->revision,&n_itemno);
       _PDMdebug(fname,"MEMbuild_array failed : status %d\n", status);
	return(PDM_E_BUILD_ARRAY);
	}
    if((status == MEM_S_SUCCESS) && (filelist_list->rows > 0))
     {
    status = NFMget_file_information( PDMexec->catalog,PDMexec->part_num,PDMexec
->revision,NFM_ADD_FILE_TO_ITEM, &dummy_attr,&dummy_data,&dummy_list);

    if(status != NFM_S_SUCCESS)
    {
            MEMclose(&dummy_attr);
            MEMclose(&dummy_data);
            MEMclose(&dummy_list);
         NFMdelete_item(PDMexec->user_id, PDMexec->catalog,PDMexec->part_num,PDMexec->revision,&n_itemno);
/* commented out by Mychelle 11/11/93
            NFMreset_file_information(PDMexec->catalog,PDMexec->part_num, PDMexec->revision);
*/
      _PDMdebug(fname,"NFMget_file_information failed status -> %d \n", status);
      return(status);
    }
      if(PDMdebug_on)
        {
        MEMprint_buffer("Add file to Item - dummy_attr",dummy_attr,PDM_DEBUG_FILE);
        MEMprint_buffer("Add file to Item - dummy_data",dummy_data,PDM_DEBUG_FILE);
        MEMprint_buffer("Add file to Item - dummy_list",dummy_list,PDM_DEBUG_FILE);
         }
               MEMclose(&dummy_attr);
               MEMclose(&dummy_data);
               MEMclose(&dummy_list);
status = PDMstart_transaction(0);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMstart_transaction failed status %d\n", status);
                PDMdebug(s);
                return(status);
        }
status = PDMstop_transaction(1200);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMstop_transaction failed status %d\n", status);
                PDMdebug(s);
                return(status);
        }
    status = NFMdefine_file_information(PDMexec->catalog,PDMexec->part_num,PDMexec->revision,NFM_ADD_FILE_TO_ITEM,filelist_list);
   if(status != NFM_S_SUCCESS)
    {
        _PDMdebug(fname,"NFMdefine_fle failed status -> %d \n", status);
/* Commented out by Mychelle - 11/11/93.  Only call in success case
        NFMreset_file_information(PDMexec->catalog,PDMexec->part_num, PDMexec->revision);
*/
         NFMdelete_item(PDMexec->user_id, PDMexec->catalog,PDMexec->part_num,PDMexec->revision,&n_itemno);
            return(status);
    }
status = PDMstart_transaction(1200);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMstart_transaction failed status %d\n", status);
                PDMdebug(s);
                return(status);
        }
      }
    }

    _PDMdebug(fname,"EXIT:\n");
    return(PDM_S_SUCCESS);	
}

int	 PDMdelete_part()
{
        char            *fname = "PDMdelete_part";
        char            *fn = "PDMdelete_part";
	long		status;
	long		n_itemno;
	char		pdmsv_tbl[40];
	char		sql_str[512];
        char            n_setindicator[3];
        char            *msg = NULL;
        long            PDMdel_part ();
        
     _PDMdebug(fname,"ENTER:\n");

     n_setindicator[0] = '\0';

     status = PDMload_catno(PDMexec->catalog);
     if (status != SQL_S_SUCCESS) {
        _PDMdebug (fn, "PDMload_catno failed status %d\n", status);
        return (status);
        }

     msg = (char *)PDUtranslate_message(PDS_M_DELETE_PART);
     strcpy(glob_var, msg);

     PDMupdate_dots ();

     status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
                                PDMexec->revision);
     if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "PDMload_part_info failed status %d\n", status);
                return (status);
        }
      
     if((!strncmp(PDMpart.n_setindicator,"Y",1)) ||
          (!strncmp(PDMpart.n_setindicator,"A",1)))
     { 
          status = PDMdelete_bom();
          if (status != PDM_S_SUCCESS &&
                status != PDM_E_BOM_NOT_FOUND)
                   {
                 _PDMdebug(fname, "%s %d\n",
                             "PDMdelete_bom failed status ", status);
                        }
        status = PDMdron_setindicator(PDMpart.n_catalogno,PDMpart.n_itemno);
        if(status != PDM_S_SUCCESS)
            {
                _PDMdebug(fname," %s %d \n",
                "PDMdelete_set_members failed status -> ",status);
             if(!strcmp(PDMpart.p_parttype,"G") )
                goto wrapup;

            }
        }
  
        n_itemno = PDMpart.n_itemno;
   
	status = PDMdel_part(PDMexec->catalog, PDMexec->part_num,
                            PDMexec->revision);
	if(status != PDM_S_SUCCESS)
	{
	   _PDMdebug(fname,"NFMdelete_item failed status %d\n");
             ERRget_specific_number (NFM, &status);
            goto wrapup;
	}

	/* find saved view table for the catalog */
	
	sprintf(pdmsv_tbl,"v_%s",PDMexec->catalog);

        /* delete entry in v_XX table */

	sprintf(sql_str,"DELETE FROM %s where n_itemno = %d",
	pdmsv_tbl, n_itemno);	
	status = SQLstmt(sql_str);
	
	_PDMdebug(fname,"EXIT:-SUCCESS\n");
	return(PDM_S_SUCCESS);
   
  wrapup:

    status = PDMrollback_transaction(1200);
    if(status != PDM_S_SUCCESS)
    {
          _PDMdebug(fname,"PDMrollback_transaction failed status %d\n",status);
    }
		return(PDM_E_DELETE_ITEM);
}

int	PDMscancel_modify_part(attr_list, data_list)
	MEMptr	attr_list;
	MEMptr	data_list;
{
	char	s[512];
        char            sql_str[512];
	long	status;

	PDMdebug("ENTER:PDMscancel_modify_part\n");
/*
    status = MEMreset_buffer(PDMexec->ws_buffer,&curbuf_no);
    if(status != MEM_S_SUCCESS)
    {
		sprintf(s,"MEMreset_buffer failed : status %d\n",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
    }
    status = MEMsplit_copy_buffer(PDMexec->ws_buffer,&attr_list,0);
    if(status != MEM_S_SUCCESS)
    {
		MEMclose(&attr_list);
		sprintf(s,"MEMcopy_split_buffer failed : status %d\n",
			status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
    }
    status = MEMreset_buffer(PDMexec->ws_buffer,&curbuf_no);
    if(status != MEM_S_SUCCESS)
    {
		MEMclose(&attr_list);
		sprintf(s,"MEMreset_buffer failed : status %d\n",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
    }
    status = MEMsplit_copy_buffer(PDMexec->ws_buffer,&data_list,0);
    if(status != MEM_S_SUCCESS)
    {
       MEMclose(&attr_list);
       sprintf(s,"MEMcopy_split_buffer failed : status %d\n",
			status);
       PDMdebug(s);
       return(PDM_E_COPY_BUFFER);
    }
*/
    status = NFMcancel_update_item(PDMexec->user_id,
								attr_list,data_list);			    
    if(status != NFM_S_SUCCESS)
       {
			sprintf(s,"\t%s %d \n",
			"NFMcancel_update_item failed status ",status);
			PDMdebug(s);
			return(PDM_E_CANCEL_UPDATE_ITEM);
       } 

/* added by kumar on 3/23/92 */

      sprintf (sql_str, "UPDATE %s SET n_itemlock = 'N' WHERE n_itemname = '%s' AND n_itemrev = '%s'", PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
      SQLstmt(sql_str);

	PDMdebug("EXIT:PDMscancel_modify_part\n");
	return(PDM_S_SUCCESS);
}

/* Kumar 3.8.91 */

int PDMsadd_part_to_project(attr_list, data_list)
	MEMptr		attr_list;
	MEMptr		data_list;
{
   char *fname = "PDMsadd_part_to_project";
   char **part_data, **data, sql_str[512], n_itemlock[5];
   MEMptr bufr = NULL;
   int    i = 0, nx  =0;
   long status = PDM_S_SUCCESS;
   long status1 = PDM_S_SUCCESS;

      _PDMdebug(fname,"ENTER :\n");

    if (PDMdebug_on)
      {
        MEMprint_buffer("attr_list", attr_list, PDM_DEBUG_FILE);
        MEMprint_buffer("data_list", data_list, PDM_DEBUG_FILE);
      }

     status = MEMbuild_array(data_list);
      if(status != MEM_S_SUCCESS)
          return(status);
      else
          part_data = (char **) data_list->data_ptr;

      for (i = 0; i < data_list->rows; i++)
       {
          nx = i * data_list->columns;
         if( !strcmp(part_data[nx+3], PDMexec->catalog) &&
             !strcmp(part_data[nx+4], PDMexec->part_num) &&
             !strcmp(part_data[nx+5], PDMexec->revision))
             {
               if(strcmp(part_data[nx], "Add"))
                {
               _PDMdebug(fname,"Part is already added\n");
               return(PDM_E_PART_ASSOC_WITH_PROJECT);
                }
              }
       }
           
/*  Mychelle - unlock the last row in the buffer - 4/24/93
    sprintf(sql_str,"select n_itemlock from %s where n_itemname = '%s' and n_itemrev = '%s'", part_data[3],part_data[4],part_data[5]);
*/
    sprintf(sql_str,"select n_itemlock from %s where n_itemname = '%s' and n_itemrev = '%s'", 
        part_data[(data_list->columns * (data_list->rows - 1)) + 3],
        part_data[(data_list->columns * (data_list->rows - 1)) + 4],
        part_data[(data_list->columns * (data_list->rows - 1)) + 5]);

       status = SQLquery(sql_str, &bufr,512);
        if(status != SQL_S_SUCCESS)
         {
          MEMclose(&bufr);
          strcpy(n_itemlock,"N");
          }
         else
          {
            status = MEMbuild_array(bufr);
             if(status != MEM_S_SUCCESS)
              {
               MEMclose(&bufr);
               strcpy(n_itemlock,"N");
               }
             else
               {
              data = (char **) bufr->data_ptr;
               strcpy(n_itemlock,data[0]);
                MEMclose(&bufr);
                }
            }
               
         

sprintf (sql_str, "UPDATE %s SET n_itemlock = 'N' WHERE n_itemname = '%s' AND n_itemrev = '%s'",
        part_data[(data_list->columns * (data_list->rows - 1)) + 3],
        part_data[(data_list->columns * (data_list->rows - 1)) + 4],
        part_data[(data_list->columns * (data_list->rows - 1)) + 5]);
      SQLstmt(sql_str);


    status = NFMupdate_project_members( PDMexec->user_id, attr_list,data_list);
    if(status != NFM_S_SUCCESS)
    {
     status1 = MEMbuild_array(data_list);
      if(status1 != MEM_S_SUCCESS)
          return(status1);
      else
          part_data = (char **) data_list->data_ptr;
sprintf (sql_str, "UPDATE %s SET n_itemlock = '%s' WHERE n_itemname = '%s' AND n_itemrev = '%s'", 
        part_data[(data_list->columns * (data_list->rows - 1)) + 3],
        n_itemlock,
        part_data[(data_list->columns * (data_list->rows - 1)) + 4],
        part_data[(data_list->columns * (data_list->rows - 1)) + 5]);
      SQLstmt(sql_str);
   _PDMdebug(fname,"NFMupdate_project_members failed status -> %d \n", status);
    if(status == NFM_E_DUP_ITEM) return(PDM_E_PART_EXISTS);
        else
          {
          ERRget_specific_number (NFM, &status);
          return(status);
           }
    }    

     status = MEMbuild_array(data_list);
      if(status != MEM_S_SUCCESS)
          return(status);
      else
          part_data = (char **) data_list->data_ptr;
sprintf (sql_str, "UPDATE %s SET n_itemlock = '%s' WHERE n_itemname = '%s' AND n_itemrev = '%s'", 
        part_data[(data_list->columns * (data_list->rows - 1)) + 3],
        n_itemlock,
        part_data[(data_list->columns * (data_list->rows - 1)) + 4],
        part_data[(data_list->columns * (data_list->rows - 1)) + 5]);
      SQLstmt(sql_str);

    _PDMdebug(fname,"EXIT:\n");
    return(PDM_S_SUCCESS);	
}

int	 PDMscheck_delete_part()
{
	long		status;
	char		s[200];
	char		sql_str[512];
        int             catno,partno;
        MEMptr          cit_bufr = NULL;
	
	PDMdebug("ENTER:PDMcheck_delete_part\n");
        status = PDMquery_catalog_partnos(PDMexec->catalog,PDMexec->part_num,
                                      PDMexec->revision,&catno,&partno);
	if(status == PDM_S_SUCCESS)
	{
                sql_str[0] = '\0';
                sprintf(sql_str,"%s %s %d %s %d ",
                "SELECT n_citno FROM nfmsetcit",
                "WHERE n_ccatalogno = ",catno,
                "AND n_citemno = ", partno);
                status = SQLquery(sql_str,&cit_bufr,512);
                if(status != SQL_S_SUCCESS)
                 {
                MEMclose(&cit_bufr);
                }
                else 
                {
		PDMdebug("PDMdelete_part:\n");
                MEMclose(&cit_bufr);
		sprintf(s,"PDMquery_catpartnos failed status %d\n");
		PDMdebug(s);
		return(PDM_I_PART_IN_ASS);
                }
	}
	if(status != PDM_S_SUCCESS)
	{
		PDMdebug("PDMdelete_part:\n");
		sprintf(s,"PDMquery_catpartnos failed status %d\n");
		PDMdebug(s);
	}
        
	
	PDMdebug("EXIT:PDMscheck_delete_part\n");
		return(PDM_S_SUCCESS);
}


int PDMload_state_name(data_buffer)
MEMptr data_buffer;
{

   static char *fname = "PDMload_state_name";
    char      sql_str[512], state[41];
    char      **data, **column, **state_data;
    int       i = 0, n1 = -1 , n2 = -1;
    MEMptr    bufr = NULL;


    sql_str[0]='\0'; state[0]='\0';
   status = MEMbuild_array(data_buffer);
   if(status != MEM_S_SUCCESS)
   {
                MEMclose(&data_buffer);
             _PDMdebug(fname, "MEMbuild_array : status %d\n", status);
                return(PDM_E_BUILD_ARRAY);
   }

    data = (char **)data_buffer->data_ptr;
    column = (char **)data_buffer->column_ptr;

   for(i=0;i<data_buffer->columns;i++)
      {
        if(!strcmp(column[i],"n_cocomment")) n1 = i;
        else if(!strcmp(column[i],"n_stateno")) n2 = i;
      }
    if (n1 == -1 || n2 == -1)
   {
                MEMclose(&data_buffer);
             _PDMdebug(fname, "MEMwrite_format : status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
   }

   sprintf(sql_str,"SELECT n_statename FROM nfmstates WHERE n_stateno = %s ",data[n2]);
         status = SQLquery(sql_str,&bufr,512);
        if(status != SQL_S_SUCCESS)
            { 
              MEMclose(&bufr);
              strcpy(state,"DON'T CARE STATE");
            }
      else
   {
   status = MEMbuild_array(bufr);
   if(status != MEM_S_SUCCESS)
   {
              MEMclose(&bufr);
                sprintf(s,"%s %d \n",
                "MEMbuild_array ",status);
                PDMdebug(s);
                return(PDM_E_BUILD_ARRAY);
   }
      state_data = (char **)bufr->data_ptr;
      strcpy(state,state_data[0]);
_PDMdebug(fname,"state = %s, stateno = %s\n",state_data[0] , data[n2]);
   }
 MEMclose (&bufr);
   status = MEMwrite_data(data_buffer,state,1,n1+1 );
   if(status != MEM_S_SUCCESS)
   {
              MEMclose(&data_buffer);
                sprintf(s,"%s %d \n",
                "MEMwrite_data ",status);
                PDMdebug(s);
                return(PDM_E_BUILD_ARRAY);
   }

       return(PDM_S_SUCCESS);
 }

 long PDMdel_part (cat_name, item_name, item_rev)
   char    *cat_name;
   char    *item_name, *item_rev;
   {
     static char *fname = "PDMdel_part" ;
     long     status, atol () ;
     long     item_no, cat_no, x, offset, delete_saveset_flag, latest_version ;
     char     sql_str [1024], file_cat [100] ;
     MEMptr   list = NULL, move_buffer = NULL, error_ptr = NULL ;
     char     **data, cifilename [50];
     struct   fto_buf file_buffer ;
     long     PDMcheck_for_delete_part();
     
     item_no = PDMpart.n_itemno;
     cat_no = PDMpart.n_catalogno;

     _PDMdebug(fname, "Cat  Name = <%s> : Item Name = <%s> : Item Rev = <%s>\n",
		 cat_name, item_name, item_rev);

     _PDMdebug(fname, "Cat No = <%d> : Item No = <%d> \n", cat_no, item_no);

   /* item has to be checked in, not a set, not a member of set, not a member of project */

     status = PDMcheck_for_delete_part (item_name, cat_no, item_no,
						    &delete_saveset_flag);
     if (status != PDM_S_SUCCESS)
       {
	 _PDMdebug(fname, "Item can not be deleted : status = <0x%.8x>\n",
		     status) ;
	 return (status) ;
       }

/* Nongraphic parts will have a corresponding empty row in f_catalogs too.
    MaC 083194
     if(strcmp(PDMpart.p_parttype, "P") && strcmp(PDMpart.p_parttype,"N"))
     */
     if(strcmp(PDMpart.p_parttype, "P") ) {
      sprintf (file_cat, "f_%s", cat_name);

      sprintf (sql_str, "SELECT %s FROM %s WHERE n_itemnum = %d %s ",
          " n_fileno, n_cifilename, n_cisano, n_fileversion, n_fileco ",
	  file_cat, item_no, 
          " order by n_fileversion ");
 
      status = SQLquery (sql_str, &list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) &&
         ((status) != SQL_I_NO_ROWS_FOUND))
       {
        MEMclose (&list);
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _PDMdebug(fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status);
        return ( NFM_E_SQL_QUERY);
       }

     if (status == SQL_S_SUCCESS ) {
      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _PDMdebug(fname, "MEM Build Array : status = <0x%.8x>\n",
		    status);
        return (NFM_E_MEM);
      }

     data = (char **) list -> data_ptr;

     latest_version = atol (data [(list -> rows -1) * (list -> columns) + 3]);
     _PDMdebug(fname, "Latest version is %d\n", latest_version);

     if (strcmp (PDMpart.n_status, "I") == 0) 
       {
        for (x = 0; x < list -> rows; ++x)
        {
     offset = x*list->columns ;
     if (strcmp (data [offset+4], "O"))
       {
	 status = _NFMget_sano_info_fto_buf (atol (data [offset+2]), "",
						     &file_buffer) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     _PDMdebug(fname, " Bad Storage Area : status = <0x%.8x>\n",
				 status);
		     return (status) ;
		   }
	 if (! move_buffer)
	   {
	     status = NFMbuild_fto_buffer (&move_buffer, MEM_SIZE) ;
	     if (status != NFM_S_SUCCESS)
	       {
	 _PDMdebug(fname, "Build fto buffer failed : status = <0x%.8x>\n",
				     status);
			 MEMclose (&move_buffer) ;
			 continue ;
		       }
	   }
	 file_buffer.n_status1 = NFM_DELETE_FILE ;
	 if ((atol (data [offset+3]) == latest_version) &&
	     (strlen (data [offset+1])))
	   {
	     strcpy (file_buffer.n_cifilename, data[offset+1]) ;
	   }
	 else
	   {
	     status = NFMget_file_name (1,
					cat_no, atol (data [offset]),
						cifilename) ;
	     if (status != NFM_S_SUCCESS)
	       {
		 MEMclose (&move_buffer) ;
		 _PDMdebug(fname, "Get file name : status = <0x%.8x>\n",
				     status);
			 continue ;
		       }
		     strcpy (file_buffer.n_cifilename, cifilename) ;
		   }
		 status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
		 if (status != NFM_S_SUCCESS)
		   {
		     MEMclose (&move_buffer) ;
	     _PDMdebug(fname, "Loading second row failed : status = <0x%.8x>\n",
				 status);
		     continue ;
		   }
	       }
	   }
       }
     else
       {
	 _PDMdebug(fname, "Part is not checked in\n");
       }
     
     status = NFMset_autocommit_off (0) ;
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (&move_buffer) ;
	 _PDMdebug(fname, "Failure : Set autocommit off : status = <0x%.8x>\n",
		     status) ;
	 return (status) ;
       }
     /* 02/08/93 -MFB- Adding 2 delete stmt (nfmsafiles and nfmsavesets) to fix
                       TR 249203257 */
     sprintf (sql_str, 
       "delete from nfmsafiles where n_catalogno = %d and n_itemno = %d",
       cat_no, item_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS && 
         status != SQL_I_NO_ROWS_FOUND)
     {
       _PDMdebug(fname, "Failed to delete from nfmsafiles\n");
       MEMclose (&list);
       MEMclose (&move_buffer) ;
       NFMrollback_transaction (0);
       ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
       return (NFM_E_SQL_STMT);
     }
     sprintf (sql_str, 
       "delete from nfmsavesets where n_catalogno = %d and n_itemno = %d",
       cat_no, item_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS && 
         status != SQL_I_NO_ROWS_FOUND)
     {
       _PDMdebug(fname, "Failed to delete from nfmsavesets\n");
       MEMclose (&list);
       MEMclose (&move_buffer) ;
       NFMrollback_transaction (0);
       ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
       return (NFM_E_SQL_STMT);
     }
     
     sprintf (sql_str, "DELETE FROM %s WHERE n_itemnum = %d",
	      file_cat, item_no) ;
	      
     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND)) 
       {
	 MEMclose (&list);
	 MEMclose (&move_buffer) ;
	 NFMrollback_transaction (0);
	 ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	 _PDMdebug(fname, "Sql Stmt Syntax : status = <0x%.8x>\n",
		     status);
	 return (NFM_E_SQL_STMT);
       }
    } /* If query from f_cat returns NRF MaC 102093*/
  }
     
     sprintf (sql_str, "DELETE FROM %s WHERE n_itemno = %d",
	      cat_name, item_no);
     
     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
	MEMclose (&move_buffer) ;
        NFMrollback_transaction (0);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _PDMdebug(fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		    status);
        return (NFM_E_SQL_STMT);
      }

     status = NFMreturn_serial_slot (1, cat_name, "n_itemno", item_no);
     if (status != NFM_S_SUCCESS)
      {
	MEMclose (&move_buffer) ;
        NFMrollback_transaction (0);
        _PDMdebug(fname, "Ret Serial Slot : status = <0x%.8x>\n", status);
        return (status);
      }
     _PDMdebug(fname, "delete saveset flag is %d\n", delete_saveset_flag) ;

     sprintf (sql_str, "DELETE FROM NFMSAVESETS WHERE n_catalogno = %d and n_itemno = %d", cat_no, item_no) ;
     
     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
       {
	 MEMclose (&move_buffer) ;
	 MEMclose (&list) ;
	 NFMrollback_transaction (0);
	 ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	 _PDMdebug(fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		     status);
	 return (NFM_E_SQL_STMT);
       }

     status = NFMset_autocommit_on (0) ;
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (&move_buffer) ;
	 _PDMdebug(fname, "Failure : Set autocommit off : status = <0x%.8x>\n",
		     status);
	 return (status);
       }
     
     if (PDMdebug_on)
       {
	 MEMprint_buffers ("delete buffer", move_buffer, 
			   PDM_DEBUG_FILE) ;
       }
     
     if (move_buffer != NULL)
       {
	 status = NFMfs_chg_files (&move_buffer, &error_ptr) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     _PDMdebug(fname, "remove co files failed : status = <0x%.8x>\n",
			 status);
	     /* send warning */
	   }
	 
	 MEMclose (&move_buffer) ;
       }

     _PDMdebug(fname, "SUCCESSFUL\n");
     return (PDM_S_SUCCESS);
  }


/* item has to be checked in, not a set, not a member of set, 
   not a member of project  - Kumar 10.3.93 */

long PDMcheck_for_delete_part (item_name, cat_no, 
                         item_no, delete_saveset_flag)
char *item_name ;
long cat_no ;
long item_no ;
long *delete_saveset_flag ;
{
  static char *fname = "PDMcheck_for_delete_part" ;
  MEMptr sql_buffer = NULL ;
  long status ;
  char sql_str [1024];

  *delete_saveset_flag = 0 ;

  if ((strcmp (PDMpart.n_status, "I")) && (strcmp (PDMpart.n_status, "")))
    {
      _PDMdebug(fname, "Item is not checked in\n") ;
      ERRload_struct (NFM, NFM_E_ITEM_OUT, "%s", item_name) ;
      return (NFM_E_ITEM_OUT) ;
    }
 else if (strcmp (PDMpart.n_archivestate, ""))
       {
     if (!strcmp (PDMpart.n_archivestate, "A"))
	 *delete_saveset_flag = 1 ;
     else if (!strcmp(PDMpart.n_archivestate, "B"))
	 *delete_saveset_flag = 1 ;
       }
  else if ((strcmp (PDMpart.n_pendingflag, "")) && (strcmp (PDMpart.n_pendingflag, "ID")))
    {
      _PDMdebug(fname, "Item is flagged\n");
      return (NFM_E_ITEM_FLAGGED) ; 
    }
  else if (strcmp (PDMpart.n_itemlock, "N"))
    {
      _PDMdebug(fname, "Item is locked\n");
      return (NFM_E_ITEM_LOCKED) ;
    }


  sprintf (sql_str, "select n_citemno from nfmsetcit where (n_ccatalogno = %d and n_citemno = %d) ", cat_no, item_no) ;
  
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _PDMdebug(fname, "SQLquery : status = <0x%.8x>\n", status);
      return (NFM_E_SQL_QUERY) ;
    }

  if (status != SQL_I_NO_ROWS_FOUND)
    {
      MEMclose (&sql_buffer) ;
      _PDMdebug(fname, "item member of set\n");
      ERRload_struct (NFM, NFM_E_SET_MEMBER, "", "") ;
      return (NFM_E_SET_MEMBER) ;
    }

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _PDMdebug(fname, "MEMclose : status = <0x%.8x>\n", status);
      return (NFM_E_MEM) ;
    }

  sprintf (sql_str, "select n_catalogno from nfmprojectcit where n_catalogno = %d and n_itemno = %d",
	   cat_no, item_no) ;
  
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _PDMdebug(fname, "SQLquery : status = <0x%.8x>\n", status);
      return (NFM_E_SQL_QUERY) ;
    }

  if (status != SQL_I_NO_ROWS_FOUND)
    {
      MEMclose (&sql_buffer) ;
      _PDMdebug(fname, "item member of project\n");
      ERRload_struct (NFM, NFM_E_PROJECT_MEMBER, "", "") ;
      return (NFM_E_PROJECT_MEMBER) ;
    }

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _PDMdebug(fname, "MEMclose : status = <0x%.8x>\n", status);
      return (NFM_E_MEM) ;
    }

  _PDMdebug(fname, "SUCCESSFUL\n") ;
  return (PDM_S_SUCCESS) ;
}



/* This function was written because part was being left in
   a "transfer" state (n_status='TF') after a abnormal
   termination (crash, ofcourse :-).  MaC 030394 */

int PDMreset_transfer_status (catalog, partnum, revision)
char	*catalog, *partnum, *revision;
{
 char	*fn = "PDMreset_transfer_status";
 char            sql_str[512];

   PDMdebug("ENTER:PDMreset_transfer_status\n");

   sql_str[0] = '\0';
   sprintf (sql_str, " %s %s %s %s '%s' %s '%s' %s ",
      " UPDATE ", catalog, " SET n_itemlock = 'N' ",
      " WHERE n_itemname = ", partnum,
      " AND n_itemrev = ", revision,
      " AND n_itemlock = 'Y' ");

   _PDMdebug (fn, "sql_str[%s]\n", sql_str);

   SQLstmt(sql_str);


   sql_str[0] = '\0';
   sprintf (sql_str, " %s %s %s '%s' %s '%s' %s '%s' %s ",
      " UPDATE ", catalog, " SET n_status = ", PDMpart.n_status,
      " WHERE n_itemname = ", partnum,
      " AND n_itemrev = ", revision,
      " AND n_status = 'TF' ");

   _PDMdebug (fn, "sql_str[%s]\n", sql_str);

   SQLstmt(sql_str);

   PDMdebug("EXIT:PDMreset_transfer_status\n");
   return(PDM_S_SUCCESS);
}



