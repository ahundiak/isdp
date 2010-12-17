#include		<stdio.h>
#include		"SQLerrordef.h"
#include 		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"PDMdbs_err.h"
#include		"MEMstruct.h"
#include		"PDUerror.h"
#include		"ERR.h"
#include		"PDMproto.h"
#include		"PDUpdmrpro.h"
#include                "PDUstorage.h"

extern		int		PDMdebug_on;
extern		char	PDM_DEBUG_FILE[];
static		long		status;
char            PDMdynamic_table[20];
extern 		PDMexec_ptr	PDMexec;
extern struct PDUstorage *storage;

/* MODIFIED  on Nov 5, 90 by Kumar Narayanan for dynamic attributes */
/* DESCRIPTION: Creates a CATALOG specified by the INPUT BUFFERS
				If successfull also creates pdmsv_XXX table.
				This table holds all the saved views of all the 
				parts that will eventually be created and stored 
				in this catalog.

   PARAMETERS:  PDMexecptr       PDMexec;

   INPUT:   The following fields in the PDMexec are required.

	PDMexec->user_id;
	PDMexec->ws_buffer;

   The ws_buffer field is expected to contain the following buffers
   appended in the order specified.

	(1)  loc_attr
	(2)  loc_data
	(3)  catalog_buffer
	(4)  catalog_data
        (5)  dynamic_attr
        (6)  dynamic_data
        (7)  dynamic_lists
	(8)  catalog_lists

   OUTPUT: NONE

   RETURN CODES:

		  PDM_S_SUCCESS                on success

   The following are fatal errors meaning that the 
   function failed. The following point are worth noting.

   (a) It is possible to fail while trying to reset(rollback).
       This happens when the function tests for fatal errors and 
	   accordingly tries to reset/rollback.
   
   (b) Some are a result of checks on the PDU interface. Though this 
	   interface may be stable soon the NET layer may cause problems.

  PDM_E_RESET_BUFFER 		MEM Sub systems 
  PDM_E_COPY_BUFFER 		failures.
  PDM_E_BUILD_ARRAY

  PDM_E_NUMBER_OF_BUFFERS   The appended list of buffers
							doesn't contain the required
							number of buffers.
  PDM_E_BUFFER_FORMAT       System Buffers are of incorrect 
						    format (NFM & PDM)
  PDM_E_CATALOG_EXISTS	    Catalog exists (PDM check)
  PDM_E_CREATE_CATALOG	    NFM function to create catalog
						    failed.
  PDM_E_SYSTEM_CORRUPTED	Failed to delete catalog and/or 
						    could not delete the pdmcatalogs
						    entry
Kumar Narayanan
*/

int PDMcreate_catalog(	loc_attr, loc_data,
			catalog_buffer, catalog_data, catalog_lists,dyn_table,
			dynamic_attr, dynamic_data, dynamic_list)
	MEMptr		loc_attr;
	MEMptr		loc_data;
	MEMptr		catalog_buffer;
	MEMptr		catalog_data;
	MEMptr		catalog_lists;
        char            *dyn_table;
        MEMptr          dynamic_attr;
        MEMptr          dynamic_data;
        MEMptr          dynamic_list;
{
        char            *fname = "PDMcreate_catalog";

    _PDMdebug(fname,"ENTER:\n");
   status = MEMbuild_array(loc_data);
   if(status != MEM_S_SUCCESS)
   {
   _PDMdebug(fname,"\tMEMbuild_array failed : status %d\n", status);
   return(PDM_E_BUILD_ARRAY);
   }
   if(PDMdebug_on)
   {
		MEMprint_buffer("loc_attr",loc_attr,PDM_DEBUG_FILE);
		MEMprint_buffer("loc_data",loc_data,PDM_DEBUG_FILE);
		MEMprint_buffer("catalog_buffer",catalog_buffer,PDM_DEBUG_FILE);
		MEMprint_buffer("catalog_data",catalog_data,PDM_DEBUG_FILE);
		MEMprint_buffer("dynamic_attr",dynamic_attr,PDM_DEBUG_FILE);
		MEMprint_buffer("dynamic_data",dynamic_data,PDM_DEBUG_FILE);
		MEMprint_buffer("dynamic_list",dynamic_list,PDM_DEBUG_FILE);
		MEMprint_buffer("catalog_list",catalog_lists,PDM_DEBUG_FILE);
   }

    strcpy(PDMdynamic_table,"");
   status = PDMi_create_catalog(PDMexec->user_id,PDMexec->part_num, loc_attr,loc_data, catalog_buffer,catalog_data,catalog_lists,dynamic_attr,dynamic_data,dynamic_list, dyn_table);
   if(status != PDM_S_SUCCESS)
   {
   _PDMdebug(fname,"\tPDMi_create_catalog failed : status %d\n",status);
   return(status);
   }    
   _PDMdebug(fname,"EXIT:-SUCCESSFUL\n");
   return(PDM_S_SUCCESS);
}

int PDMi_create_catalog(user_id,auto_file,loc_attr,loc_data,
						catalog_buffer,catalog_data,catalog_lists,dynamic_attr,dynamic_data,dynamic_list, dyn_table)
	long		user_id;
        char            auto_file[2];
	MEMptr		loc_attr ;
	MEMptr		loc_data ;
	MEMptr		catalog_buffer;
	MEMptr		catalog_data ;
	MEMptr		catalog_lists;
	MEMptr		dynamic_attr;
	MEMptr		dynamic_data;
	MEMptr		dynamic_list;
        char            *dyn_table;
{
        char            *fname = "PDMi_create_catalog";
	char		catalog_name[50];
	char		pdc_table[50];
	char	    **column_ptr, **cat_column, **cat_data;
	char		**data;
	int			i, dyn_no;
	int			a1,a2,a3,a4 = -1, nxi;
	int			sts1 = 0 ,sts2 = 0;
	long		n_catalogno;
        MEMptr		mod_dynamic_attr = NULL;
        MEMptr		mod_data_bufr = NULL;
        MEMptr		mod_value_bufr = NULL;

      _PDMdebug(fname,"ENTER:\n");

/* ANSI */
   strcpy(auto_file, "");

   a1 = -1;
   a2 = -1;
   a3 = -1;
   status = MEMbuild_array(loc_data);
   if(status != MEM_S_SUCCESS)
   {

  _PDMdebug(fname,"MEMbuild_array failed status %d\n", status); 
  return(PDM_E_BUILD_ARRAY);
   }

   column_ptr = (char **) loc_data->column_ptr;
   status = MEMbuild_array(catalog_buffer);
   if(status != MEM_S_SUCCESS)
   {

  _PDMdebug(fname,"MEMbuild_array failed status %d\n", status); 
  return(PDM_E_BUILD_ARRAY);
   }
   cat_column = (char **) catalog_buffer->column_ptr;
   cat_data = (char **) catalog_buffer->data_ptr;
   for(i=0;i<catalog_buffer->columns;i++)
   {
	 if(!strcmp(cat_column[i],"n_name"))  
          {
          a4 = i; break;
           }
   }
   for(i=0;i<loc_data->columns;i++)
   {
	 if(!strcmp(column_ptr[i],"n_catalogname"))  a1 = i;
	 else if(!strcmp(column_ptr[i],"n_catalogno"))  	 a3 = i;
	 else if(!strcmp(column_ptr[i],"n_type"))  	 a2 = i;
   }
   if(a1 == -1 || a3 == -1)
   {
	_PDMdebug(fname,"\t %s \n \t %s \n",
		"The buffer loc_data does not ",
		"contain the expected attributes");
	if(PDMdebug_on) MEMprint_buffer("loc_data",loc_data,PDM_DEBUG_FILE);
	status = PDM_E_BUFFER_FORMAT;
	return(status);		
   }	
   for(i=0;i<catalog_buffer->rows;i++)
   {
       nxi = i * catalog_buffer->columns;
	 if(!strcmp(cat_data[nxi+a4],"p_altpartno"))  
          {
             status = MEMwrite_data(catalog_buffer, "EXT",i+1, a2+1);
            if(status != MEM_S_SUCCESS)
             {
              _PDMdebug(fname,"MEMbuild_array failed status %d\n", status); 
              return(PDM_E_BUILD_ARRAY);
              }
            break;
           }
    }
   data = (char **) loc_data->data_ptr;	
   catalog_name[0] = '\0';
   strcpy(catalog_name,data[a1]);
	
   /* check if v_catalogname is <= 20 */

   if(strlen(catalog_name) > 18)
   {
	_PDMdebug(fname,"Catalog Identifier <%s> is long \n", catalog_name);
	return(PDM_E_IDENTIFIER_TOO_LONG);
   }
   /*
   status = PDMi_verify_catalog(catalog_name);
   if(status == PDM_S_SUCCESS)
   {
	_PDMdebug(fname, "%s \t %s %s %s \n",
	"PDMi_create_catalog aborted ..",
	"Catalog ",catalog_name,"found on the server");
	return(PDM_E_CATALOG_EXISTS);
   }
    */

   status = NFMcreate_catalog(user_id,loc_attr,loc_data,
			catalog_buffer,catalog_data,catalog_lists);
   if(status != NFM_S_SUCCESS)
   {
    if(status == NFM_E_SQL_STMT) 
        {
        if(PDMparse_for_illegal_char(catalog_name))
        {
        _PDMdebug(fname,"NFMcreate_catalog failed : status <0x%.8x>\n",status);
         _PDMdebug(fname,"Catalog has illegal character\n");
        return(PDM_E_ILL_CHAR);
         }
         else 
           {        
           ERRget_specific_number (NFM, &status);
           return(status);
            }
         }
    _PDMdebug(fname,"NFMcreate_catalog failed : status <0x%.8x>\n",status);
    return(status);
   }

   /* loc_data will have n_catalogno set by NFM */

   status = MEMbuild_array(loc_data);
   if(status != MEM_S_SUCCESS)
   {
     _PDMdebug(fname,"\tMEMbuild_array failed : status %d\n", status);
      status = PDM_E_BUILD_ARRAY;
      goto cleanup;
   }
   if(PDMdebug_on)
    MEMprint_buffer("loc_data after creation ", loc_data,PDM_DEBUG_FILE);

   data = (char **) loc_data->data_ptr;
   n_catalogno = atol(data[a3]);

  /* create  pdc table for this catalog */

   if(dynamic_attr != NULL && dynamic_attr->rows > 0 )
   {
   pdc_table[0] = '\0';
   _PDMdebug(fname,"Dynamic table from PDU %s\n",dyn_table);
   if((!strcmp(dyn_table,"")) || dyn_table == NULL)
   sprintf(pdc_table,"y_%s",catalog_name);
   else(strcpy(pdc_table,dyn_table));

    status = PDMget_table_no(pdc_table,pdc_table,&dyn_no);
    if(status != PDM_S_SUCCESS && status != PDM_E_TABLE_NOT_FOUND)
    {
	_PDMdebug(fname,"\tPDMget_table_no failed : status %d\n",status);
	return(status);
    }
    if(status != PDM_S_SUCCESS)
    {
    strcpy(PDMdynamic_table,pdc_table);
    status = PDMcreate_dynamic_table(user_id,pdc_table,dynamic_attr,dynamic_data,dynamic_list);
   if(status != PDM_S_SUCCESS)
     {
    _PDMdebug(fname,"%s %d\n", "PDMcreate_dynamic_table failed status ",status);
    goto cleanup2;
     }
    }
    else if(status == PDM_S_SUCCESS) {
      status = NFMchange_table(PDMexec->user_id,pdc_table, pdc_table,
                                 dynamic_attr,dynamic_data,dynamic_list);
       if (status != NFM_S_SUCCESS) {
          ERRget_specific_number (NFM, &status);
          _PDMdebug(fname, 
             "NFMchange_table of dynamic attrfailed : <0x%.8x>\n",status);
           NFMreset_change_table(PDMexec->user_id, pdc_table,  
                                          pdc_table, mod_dynamic_attr, 
                                          mod_data_bufr, mod_value_bufr);
           return(status);
           }
    strcpy(PDMdynamic_table,pdc_table);
    }
   }
   _PDMdebug(fname,"EXIT:Successful creation of catalog\n");
   return(PDM_S_SUCCESS);

    /* delete pdmsv_CATALOG table */

cleanup2:

	PDMdebug("ENTER: cleanup2\n",PDM_DEBUG_FILE);
        /*
        status = NFMdelete_table(user_id,"t_appltable",sv_table);
        if(status != NFM_S_SUCCESS)
        {
                _PDMdebug(fname,"NFMdelete_table failed status %d\n",status);
                PDMdebug(s);
                status = PDM_E_DELETE_TABLE;
                return(status);
        }
         */
	PDMdebug("EXIT: cleanup2\n",PDM_DEBUG_FILE);

 cleanup:
   /* need to delete the catalog */
   sts2 = 0;
     _PDMdebug(fname,"Cleaning up the creation of %s .......\n",catalog_name);
   sts2 = NFMdelete_catalog(user_id,catalog_name,&n_catalogno);
   if(sts1 == SQL_S_SUCCESS && sts2 == NFM_S_SUCCESS)
   {
     _PDMdebug(fname,"Cleaning up failure\n");
      return(status);
   }
   else
   {
		return(PDM_E_SYSTEM_CORRUPTED);
   }
}

/* DESCRIPTION :	
   Modifies an existing catalog.
   As a result of this PDM deletes the BOM 
   mapping for the user defined attributes in the catalog. 
   In future this can be refined if need be.
   Also the pdmcatalogs attribute p_catalogtype is updated 
   if required.

   PARAMETERS:  PDMexecptr       PDMexec;

   INPUT:   The following fields in the PDMexec are required.

	PDMexec->user_id;
	PDMexec->ws_buffer;

   The ws_buffer field is expected to contain the following buffers
   appended in the order specified.

	(1)  loc_attr
	(2)  loc_data
	(3)  catalog_buffer
	(4)  catalog_data
	(5)  catalog_lists
        (6)  dynamic_attr
        (7)  dynamic_data

   OUTPUT: NONE

   RETURN CODES:

  PDM_S_SUCCESS                on success

  PDM_E_RESET_BUFFER 		MEM Sub systems 
  PDM_E_COPY_BUFFER 		failures.
  PDM_E_BUILD_ARRAY

  PDM_E_NUMBER_OF_BUFFERS   The appended list of buffers
							doesn't contain the required
							number of buffers.
  PDM_E_BUFFER_FORMAT       System Buffers are of incorrect 
						    format (NFM & PDM)
  PDM_E_MODIFY_CATALOG	    NFM function to modify catalog
						    failed.
  PDM_E_DELETE_BOMMAP		The BOM mapping could not be deleted

  No check is made to see if p_catalogtype is updated or not.
  
- Kumar Narayanan
*/

int PDMmodify_catalog
(	 
MEMptr          loc_attr,
MEMptr          loc_data,
MEMptr          catalog_buffer,
MEMptr          catalog_data,
MEMptr          catalog_lists,
char            *dyn_table,
MEMptr          dynamic_attr,
MEMptr          dynamic_data,
MEMptr          dynamic_list
)
{
char            *fname = "PDMmodify_catalog";
MEMptr		mod_dynamic_attr = NULL;
MEMptr		mod_data_bufr = NULL;
MEMptr		mod_value_bufr = NULL;
char		**data;
char		**column_ptr;
char		sql_str[512];
char            pdc_table[50];
long		status;
long		n_catalogno;
int			a1 = -1;
int			a3 = -1;
int			i;

    _PDMdebug(fname, "ENTER:\n");

   if(PDMdebug_on)
   {
	MEMprint_buffer("loc_attr",loc_attr,PDM_DEBUG_FILE);
	MEMprint_buffer("loc_data",loc_data,PDM_DEBUG_FILE);
	MEMprint_buffer("catalog_buffer",catalog_buffer,PDM_DEBUG_FILE);
	MEMprint_buffer("catalog_data",catalog_data,PDM_DEBUG_FILE);
	MEMprint_buffer("dynamic_attr",dynamic_attr,PDM_DEBUG_FILE);
	MEMprint_buffer("dynamic_data",dynamic_data,PDM_DEBUG_FILE);
	MEMprint_buffer("dynamic_list",dynamic_list,PDM_DEBUG_FILE);
   }

    strcpy(PDMdynamic_table,"");
    status = MEMbuild_array(loc_data);
    if(status != MEM_S_SUCCESS) {
       _PDMdebug(fname,"\tMEMbuild_array failed : status %d\n", status);
        return(PDM_E_BUILD_ARRAY);
     }

    column_ptr = (char **) loc_data->column_ptr;
    data = (char **) loc_data->data_ptr;

    for(i=0;i<loc_data->columns;i++) {
	 if(!strcmp(column_ptr[i],"n_catalogname"))      a1 = i;
	 if(!strcmp(column_ptr[i],"n_catalogno"))  	     a3 = i;
    }

    if(a1 == -1 || a3 == -1) {
     _PDMdebug(fname,"\t %s \n \t %s \n", "The buffer loc_data does not ",
		"contain the expected attributes");
	if(PDMdebug_on) MEMprint_buffer("loc_data",loc_data,PDM_DEBUG_FILE);
	return(PDM_E_BUFFER_FORMAT);
    }	

    /*
    pdc_tbl[0] = '\0';
    sprintf(pdc_tbl,"y_%s",data[a1]);
     */

    status = PDMget_table_no(data[a1],"catalog",&n_catalogno);
    if(status != PDM_S_SUCCESS)
    {
	_PDMdebug(fname,"\tPDMget_table_no failed : status <0x%.8x>\n",status);
	return(PDM_E_TABLE_NOT_FOUND);
    }

    status = NFMchange_catalog(PDMexec->user_id,loc_attr,loc_data,
			catalog_buffer,catalog_data,catalog_lists);
    if(status != NFM_S_SUCCESS)
    {
     _PDMdebug(fname, "NFMmodify_catalog failed : status <0x%.8x>\n",status);
      ERRget_specific_number (NFM, &status);
      return(status);
    }

    if(dynamic_attr != NULL) {
      pdc_table[0] = '\0';

      _PDMdebug(fname,"Dynamic table from PDU %s\n",dyn_table);

       if((!strcmp(dyn_table,"")) || dyn_table == NULL)
           sprintf(pdc_table,"y_%s",data[a1]);
       else(strcpy(pdc_table,dyn_table));

    /* fix to make sure that dyntable is in lower case. This
       is how they are supposed to be stored in nfmtables. MaC 121493 */

       PDMconvert_to_lower (pdc_table, pdc_table);


      _PDMdebug(fname, "Lower case Dynamic table %s\n", pdc_table);

        status = PDMget_table_no(pdc_table,pdc_table,&n_catalogno);
        if(status == PDM_E_TABLE_NOT_FOUND) {
             status = NFMcreate_table (PDMexec->user_id, pdc_table,
                                                pdc_table,"PDM", 
                                                dynamic_attr,
                                                dynamic_data,
                                                dynamic_list);
             if (status != NFM_S_SUCCESS) {
                _PDMdebug(fname,"NFMcreate_table failed : <0x%.8x>\n",status);
                ERRget_specific_number (NFM, &status);
	        return(status);
                }
         strcpy(PDMdynamic_table,pdc_table);
         }
        else if(status == PDM_S_SUCCESS) {
         status = NFMchange_table(PDMexec->user_id,pdc_table, pdc_table,
                                      dynamic_attr,dynamic_data,dynamic_list);
          if (status != NFM_S_SUCCESS) {
             ERRget_specific_number (NFM, &status);
             _PDMdebug(fname, 
                "NFMchange_table of dynamic attrfailed : <0x%.8x>\n",status);
              NFMreset_change_table(PDMexec->user_id, pdc_table,  
                                             pdc_table, mod_dynamic_attr, 
                                             mod_data_bufr, mod_value_bufr);
              return(status);
              }
         strcpy(PDMdynamic_table,pdc_table);
         } 
    }

    data = (char **) loc_data->data_ptr;	

/* Update old catalogno in pdmcatalogs */

/*         typo: where clause was not included in the statement
           effect: all the catnos were getting updated to current catno
           later on, we delete all the rows where catno=current catno
           and add the modified current_catno row 
           result: all the rows except the current cat row vanished 
                                         - MaC/AR 011593

      sprintf (sql_str, "UPDATE pdmcatalogs SET n_catalogno = %d, p_autofilename = '%s'", atol(data[a3]),PDMexec->part_num,"WHERE n_catalogno = ",n_catalogno);
	status = SQLstmt(sql_str);
*/
      /*sprintf (sql_str, 
   "UPDATE pdmcatalogs SET n_catalogno = %d, p_autofilename = '%s' %s %d ",
        atol(data[a3]), PDMexec->part_num, 
         "WHERE n_catalogno = ", n_catalogno);
	status = SQLstmt(sql_str);
         if(status != SQL_S_SUCCESS) { 
            _PDMdebug (fname, "Update Failed: %d\n", status);
             return (status);
            }*/

sql_str[0] = '\0';

MEMclose (&mod_data_bufr);
MEMclose (&mod_value_bufr);

/* Need to delete the BOMmapping for this catalog even though the old user
   defined attrbs may or may not have been changed.  Also check if the 
   p_catalogtype in pdmcatalogs need to be updated.
   If error inform PDU but leave catalog modified  */

/* Since the user attributes cannot be modified in any way;
   cannot be deleted, cannot have datatype changed etc.
   it may not be necessary to delete existing mappings.
   If in future any other factors make it necessary,
   this part will be uncommented. MaC/JBP 051393

sql_str[0] = '\0';

    sprintf(sql_str,"%s %s %d", 
        "DELETE FROM pdmbommap ","WHERE n_catalogno = ",
	n_catalogno);
    status = SQLstmt(sql_str);
   ... End comment */

  _PDMdebug(fname,"EXIT:\n");
  return(PDM_S_SUCCESS);
}

/* Creates y_XXX .. a dynamic attributes table.
   This is expected to be called for every catalog creation

   - Kumar Narayanan */
int PDMcreate_dynamic_table
(
long		user_id,
char 		*pdc_tbl,
MEMptr          dynamic_attr,
MEMptr          dynamic_data,
MEMptr          dynamic_list
)
{
long		status;
char            *fname = "PDMcreate_dynamic_table";

_PDMdebug(fname,"ENTER:\n");
    /*  Call NFM to create the table  */
    if(dynamic_attr == NULL || dynamic_attr->rows == 0)
      {
         _PDMdebug(fname, "NOTHING TO CREATE A DYNAMIC TABLE\n");
         return(PDM_S_SUCCESS);
      }
     status = NFMcreate_table (user_id, pdc_tbl,pdc_tbl,"PDM", 
			    dynamic_attr,dynamic_data,dynamic_list);
     if (status != NFM_S_SUCCESS)
	 {
	    _PDMdebug(fname,"NFMcreate_table failed : <0x%.8x>\n",status);
            ERRget_specific_number (NFM, &status);
	    return(status);
         }
     _PDMdebug(fname,"EXIT:\n");
     return (PDM_S_SUCCESS);
}

/* DESCRIPTION : 
Deletes a PDM catalog and its associated
	 pdmsv_CATALOG (saved views) table.
	 First n_catalogno has to be queried.
	 So that pdmcatalogs entry can also be deleted
         Even if n_catalogno can not be found the catalog
         is deleted. This may leave an entry in pdmcatalogs

   RETURN CODES:
   PDM_S_SUCCESS	 			SUCCESS
   PDM_E_CATALOG_NOT_EMPTY		catalog contains one/more parts
   PDM_E_CATALOG_NOT_FOUND		catalog does not exist
   PDM_E_REQ_COLUMN_NOT_FOUND	        Attribute in a RIS query does not exist in the table
   PDM_E_BUILD_ARRAY		  

   Informational:
	
   PDM_E_DELETE_TABLE		saved views table could not be deleted   

- Kumar Narayanan
*/

int PDMdelete_catalog()
{
	long		status;
	char		sql_str[1024];
        MEMptr   dyn_bufr = NULL, cat_bufr = NULL;
        char     **dyn_data;
	long		n_catalogno;
        char            *fname = "PDMdelete_catalog";
        char            del_str[240];

	_PDMdebug(fname,"ENTER:\n");

 status = NFMset_autocommit_on (1200) ;
     if (status != NFM_S_SUCCESS) 
       {
         _PDMdebug (fname, "Failure to force autocommit on \n") ;
       }


status = NFMdelete_catalog(PDMexec->user_id,PDMexec->catalog, &n_catalogno);
	if(status != NFM_S_SUCCESS)
	{
		if(status == NFM_E_NOT_EMPTY_CAT)
		{
			return(PDM_E_CATALOG_NOT_EMPTY);
		}
		_PDMdebug(fname,"%s  %d \n",
		"NFMdelete_catalog failed status",status);
                ERRget_specific_number (NFM, &status);
		return(status);
	}

       status = PDMdelete_functions (PDMexec->catalog, storage->storage_name );
       if(status != PDM_S_SUCCESS)
        {
		_PDMdebug(fname,"%s  %d \n",
		"PDMdelete_functions failed status",status);
         }

sprintf(del_str,"DELETE FROM pdmfnattrmap where n_catalogname = '%s'",PDMexec->catalog);
       status = SQLstmt(del_str);
         if(status != SQL_S_SUCCESS)
         {
       _PDMdebug (fname, "No function-attr map for this catalog : status = <0x%.8x>\n", status);
         }
sprintf(del_str,"SELECT p_dyntable FROM pdmcatalogs where n_catalogno = %d", n_catalogno);
        status = SQLquery(del_str,&dyn_bufr,512);
         if(status == SQL_S_SUCCESS)
          {
           status = MEMbuild_array (dyn_bufr);
            if(status != MEM_S_SUCCESS)
             {
        _PDMdebug (fname, "MEMbuild_array : status = <0x%.8x>\n", status);
        return (status);
             }
             dyn_data = (char **) dyn_bufr->data_ptr;
           sprintf(del_str,"SELECT n_catalogno FROM pdmcatalogs WHERE p_dyntable= '%s'", dyn_data[0]);
            status = SQLquery(del_str, &cat_bufr,512);
            if(status == SQL_S_SUCCESS)
             {
              status = MEMbuild_array (cat_bufr);
              if(status != MEM_S_SUCCESS)
              {
              _PDMdebug (fname, "MEMbuild_array : status = <0x%.8x>\n", status);
               return (status);
               }
               if(cat_bufr->rows == 1)
               {
                 PDMconvert_to_lower(dyn_data[0], dyn_data[0]);
                 status = NFMdelete_table (PDMexec->user_id, dyn_data[0], dyn_data[0]);
                 if (status != NFM_S_SUCCESS)
                 {
                _PDMdebug (fname, "Delete Table : status = <0x%.8x>\n", status);
                 return (status);
                }
               }
              }
               MEMclose(&cat_bufr);
               MEMclose(&dyn_bufr);
             }
       /* 
	status = PDMget_table_no(pdc_tbl,pdc_tbl,&tblno);
	if(status == PDM_S_SUCCESS)
	{
	status = NFMdelete_table(PDMexec->user_id,pdc_tbl,pdc_tbl);
		if(status != NFM_S_SUCCESS)
		{
	_PDMdebug(fname,"NFMdelete_table failed status <0x%.8x>\n",status);
			status = PDM_E_DELETE_TABLE;
			return(status);
		}

	}
        */
    /* delete pdmcatalogs entry if n_catalogno is known */
    if(n_catalogno != -1)
        {
		sql_str[0] = '\0';
		sprintf(sql_str,"%s %s %d",
		"DELETE FROM pdmcatalogs",
		"WHERE n_catalogno = ",n_catalogno);
		status = SQLstmt(sql_str);
	}
	_PDMdebug(fname,"EXIT:\n");
	return(PDM_S_SUCCESS);
}

