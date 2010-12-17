#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>

#define		TRUE			 1
#define		FALSE			 0

#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "SQLerrordef.h"

#include "PDMmach_id.h"
#include "PDMinit.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "MSGstruct.h"
#include "DEBUG.h"
#include "PDMproto.h"

/* local definitions */


static  int	 status; 
static  char s[1024]; 

extern 	struct	msg_struct   NFMmsg_ptr;
extern 	struct	msg_struct   MEMmsg_ptr;
extern 	struct	msg_struct   SQLmsg_ptr;

extern  int		PDMdebug_on;
extern	char    PDM_DEBUG_FILE[];
char pdm_proddir[200];

PDMcreate_required_table (user_id, table_id)
  long	user_id;
  int	table_id;
  {
	char		attr_file[120];
	char		data_file[120];
	char		list_file[120];
	char		s[1024], table_name[40];

#if defined (sco)
	char		*PDM_DIR;
#endif

	PDMdebug("ENTER:PDMcreate_required_table\n");

	attr_file[0] = '\0';
	data_file[0] = '\0';
	list_file[0] = '\0';

#if defined (sco)
	PDMdebug("Create SCO specific PDM_DIR");
        status = PDMget_proddir(pdm_proddir);
        if(status != PDM_S_SUCCESS)
          {
              PDMdebug("PDMget_proddir failed \n");
          }
	PDM_DIR = (char *)malloc(strlen(pdm_proddir)+1+strlen("config/initial")+1);
        sprintf(PDM_DIR, "%s%s%s", pdm_proddir, DELIM, "config/initial");
#endif

   switch (table_id)
   {
	case PDM_CIT:
		sprintf (attr_file,"%s%s%s",PDM_DIR,DELIM,"PDMcit.attr");
		sprintf (data_file,"%s%s%s",PDM_DIR,DELIM,"PDMcit.data");
        list_file[0] = '\0';
		strcpy (table_name, "pdmcit");
		break;
	case PDM_BOMSINFO:
		sprintf (attr_file,"%s%s%s",PDM_DIR,DELIM,"PDMboms.attr");
		sprintf (data_file,"%s%s%s",PDM_DIR,DELIM,"PDMboms.data");
		list_file[0] = '\0';
		strcpy (table_name, "pdmboms");
		break;
	case PDM_LOC:
		sprintf (attr_file,"%s%s%s",PDM_DIR,DELIM,"PDMloc.attr");
		sprintf (data_file,"%s%s%s",PDM_DIR,DELIM,"PDMloc.data");
		list_file[0] = '\0';
		strcpy (table_name, "pdmcatalogs");
		break;
	case PDM_BOMMAP:
		sprintf (attr_file,"%s%s%s",PDM_DIR,DELIM,"PDMmap.attr");
		sprintf (data_file,"%s%s%s",PDM_DIR,DELIM,"PDMmap.data");
		list_file[0] = '\0';
		strcpy (table_name, "pdmbommap");
		break;
	case PDM_FAMILIES:
		sprintf (attr_file,"%s%s%s",PDM_DIR,DELIM,"PDMflys.attr");
		sprintf (data_file,"%s%s%s",PDM_DIR,DELIM,"PDMflys.data");
		list_file[0] = '\0';
		strcpy (table_name, "pdmfamilies");
		break;
	case PDM_PARAMETERS:
		sprintf (attr_file,"%s%s%s",PDM_DIR,DELIM,"PDMparam.attr");
		sprintf (data_file,"%s%s%s",PDM_DIR,DELIM,"PDMparam.data");
		list_file[0] = '\0';
		strcpy (table_name, "pdmparameters");
		break;
	case PDM_PARAMLOC:
		sprintf (attr_file,"%s%s%s",PDM_DIR,DELIM,"PDMparloc.attr");
		sprintf (data_file,"%s%s%s",PDM_DIR,DELIM,"PDMparloc.data");
		list_file[0] = '\0';
		strcpy (table_name, "pdmparamloc");
		break;
	case PDM_MACROS:
		sprintf (attr_file,"%s%s%s",PDM_DIR,DELIM,"PDMmacros.attr");
		sprintf (data_file,"%s%s%s",PDM_DIR,DELIM,"PDMmacros.data");
		list_file[0] = '\0';
		strcpy (table_name, "pdmmacros");
		break;
	case PDM_TABLES:
		sprintf (attr_file,"%s%s%s",PDM_DIR,DELIM,"PDMtables.attr");
		sprintf (data_file,"%s%s%s",PDM_DIR,DELIM,"PDMtables.data");
		list_file[0] = '\0';
		strcpy (table_name, "pdmtables");
		break;
        case PDM_SEEDS:
                sprintf (attr_file,"%s%s%s",PDM_DIR,DELIM,"PDMdr_seeds.attr");
                sprintf (data_file,"%s%s%s",PDM_DIR,DELIM,"PDMdr_seeds.data");
                list_file[0] = '\0';
                strcpy (table_name, "pdmseedfiles");
                break;
	default:
		PDMdebug("PDMcreate_required_table \n");
		sprintf (s,"Invalid table_id; table_id = %d\n", table_id);
		PDMdebug(s);
		status = PDM_E_INVALID_TABLEID;
		return (status);
     }
     status = PDMcreate_table(user_id,attr_file,data_file,
			      list_file,table_name);
     if(status != PDM_S_SUCCESS)
	 {
		 sprintf(s,"PDMcreate_table failed status %d\n",status);
		 printf("PDMcreate_table failed status %d\n",status);
		 PDMdebug(s);
		 return(status);
	 }   
	 PDMdebug("EXIT:PDMcreate_required_table\n");
	 return(PDM_S_SUCCESS);
 }

int  PDMcreate_table(user_id,attr_file,data_file,list_file,table_name)
long	user_id;
char	*attr_file;
char	*data_file;
char	*list_file;
char	*table_name;
{
	MEMptr	    attr_buffer = NULL;
	MEMptr	    data_buffer = NULL;
	MEMptr	    list_buffer = NULL;

	PDMdebug("ENTER:PDMcreate_table\n");

/*  Get a template of attribute bufr from NFM  */
     
     status = NFMquery_table_template(user_id,&attr_buffer);
     if (status != NFM_S_SUCCESS)
     {
		sprintf(s,
 		 "NFMquery_table_template failed; status = %d\n", status);
		printf(
 		 "NFMquery_table_template failed; status = 0x%.8x\n", status);
		PDMdebug(s);
		MEMclose (&attr_buffer);
		status = PDM_E_QUERY_TABLE_TEMPLATE;
		return (status);
     }
     status = MEMbuild_array (attr_buffer);
     if (status != MEM_S_SUCCESS)
     {
		sprintf(s,
 		 "MEMbuild_array failed; status = %d\n", status);
		printf(
 		 "MEMbuild_array failed; status = 0x%.8x\n", status);
		PDMdebug(s);
		MEMclose (&attr_buffer);
		status = PDM_E_BUILD_ARRAY;
		return (status);
     }

   /*  Add the required attributes for the table  */

    status = PDMattrfile_to_buffer (attr_file,attr_buffer);
    if (status != PDM_S_SUCCESS)
    {
        sprintf(s,"PDMattrfile_to_buffer failed : %d",status);
	 	PDMdebug(s);
 		MEMclose (&attr_buffer);
 		return (status); 
    }

   /*  Load initial & default values of the above attrbs from 
       .data file */

     status = PDMdatafile_to_buffer 
					(data_file, attr_buffer, &data_buffer);
     if (status != PDM_S_SUCCESS)
     {
		sprintf(s,"PDMdatafile_to_buffer failed : %d\n",status);
		PDMdebug(s);
		MEMclose(&data_buffer);
		MEMclose (&attr_buffer);
		return (status);
     }

   /*  Load list values of the above attrbs from file */
   /*  there may or may not be a list_file */

     if(strcmp(list_file,""))
     {
     	status = PDMlistfile_to_buffer (list_file, &list_buffer);
        if (status != PDM_S_SUCCESS)
        {
	    	sprintf(s,"PDMlistfile_to_buffer failed : %d",status);
	    	PDMdebug(s);
	    	MEMclose (&attr_buffer);
	    	MEMclose(&data_buffer);
	    	MEMclose(&list_buffer);
	    	return (status);
         }
      }
     
    /*  Call NFM to create the table  */

     status = NFMcreate_table (user_id, table_name, table_name, "PDM",
			       attr_buffer,data_buffer,list_buffer);
     if (status != NFM_S_SUCCESS)
     {
	    sprintf(s,"NFMcreate_table failed : %d",status);
	    printf("NFMcreate_table failed : 0x%.8x",status);
	    PDMdebug(s);
	    MEMclose (&attr_buffer);
	    MEMclose(&data_buffer);
	    MEMclose(&list_buffer);
	    status = PDM_E_CREATE_TABLE;
	    return (status);
     }

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&list_buffer);
	PDMdebug("EXIT:PDMcreate_table\n");
    return (PDM_S_SUCCESS);
}

long PDMi_create_pdm_catalog (user_id,pdm_catalog,n_type)
long   user_id;
char	  *pdm_catalog;
char	  *n_type;
{
      long   status;
      MSGptr app_ptr;
      MEMptr loc_attr = NULL, loc_data = NULL, loc_values = NULL;
      MEMptr cat_attr = NULL, cat_data = NULL, cat_values = NULL;
      MEMptr application = NULL ;
      char   **column, **data;
       int   n_catalogno;
      int   a, b, x, y, count, acl_no, n_attrno;
      char    sql_str[250];
      char   loc_name [50], value[50], str [1024] ;

	PDMdebug("ENTER:PDMi_create_pdm_catalog\n");

    status = WFvalidate_user_access (user_id, "Create Catalog",
               "", "", "", "", "");
      if (status != NFM_S_SUCCESS)
       {
          sprintf(s,"WFValidate User Access : status = <%d>\n",
          status);PDMdebug(s);
          return (status);
       }
 
      status = NFMquery_addto_loc_attributes (user_id, loc_name,
               &loc_attr, &loc_data, &loc_values);
      if (status != NFM_S_SUCCESS)
       {

		sprintf(s,"%s %d\n",
		"NFMquery_addto_loc_attributes failed status \n",status);
		PDMdebug(s);
		app_ptr.error_no = NFM_E_FAILURE;
		WFset_to_state(user_id,"PDM",app_ptr);    
		return(status); 
        }

/************
	status = NFMquery_table_attributes(user_id,"pdmcatalogs",
			 "pdmcatalogs",&loc_attr,&loc_data,&loc_values);
	if(status != NFM_S_SUCCESS)
	{
         MEMclose (&loc_attr);
         MEMclose (&loc_data);
         MEMclose (&loc_values);		
		sprintf(s,"%s %d\n",
		"NFMquery_table_attributes failed status \n",status);
		PDMdebug(s);
  	   app_ptr.error_no = NFM_E_FAILURE;
	   WFset_to_state(user_id,"PDM",app_ptr);    
		return(status);
	}
******************/

      status = MEMopen (&application, MEM_SIZE);
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&application);
	  sprintf (s, "NFMRquery_addto_loc_attributes : MEMopen : <0x%.8x>", 
		   status);
	  PDMdebug (s) ;
	  return (status);
	}

      
      status = MEMwrite_format (application, "n_type", "char(20)");
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&application);
	  sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite_format : <0x%.8x>", status);
	  PDMdebug (s) ;
	  return (status);
      }

    status = MEMwrite_format (application, "value", "char(20)");
    if (status != MEM_S_SUCCESS)
      {
        MEMclose (&application);
        sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite_format : <0x%.8x>", status);
	PDMdebug (s) ;
        return (status);
      }

      strcpy (str, "t_basic\001PDM\001") ;

      status = MEMwrite (application, str);
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&application);
	  sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite : <0x%.8x>",
		   status) ;
	  return (NFM_E_MEM) ;
	}

      status = NFMquery_catalog_template_n (&cat_attr, &cat_data, &cat_values,
					    application) ;
      if (status != NFM_S_SUCCESS)
	{
          MEMclose (&loc_attr);
          MEMclose (&loc_data);
          MEMclose (&loc_values);
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
          MEMclose (&cat_values);
	  app_ptr.error_no = NFM_E_FAILURE;
	  WFset_to_state(user_id,"PDM",app_ptr);    
          sprintf(s,"MEM Build Array : status = <%d>\n", status);
	  PDMdebug(s);
          return (PDM_E_BUILD_ARRAY);
	}

      status = MEMbuild_array (loc_attr);
      if (status != MEM_S_SUCCESS)
       {
          MEMclose (&loc_attr);
          MEMclose (&loc_data);
          MEMclose (&loc_values);
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
          MEMclose (&cat_values);
	  app_ptr.error_no = NFM_E_FAILURE;
	  WFset_to_state(user_id,"PDM",app_ptr);    
          sprintf(s,"MEM Build Array : status = <%d>\n", status);
	  PDMdebug(s);
          return (PDM_E_BUILD_ARRAY);
       }

      status = MEMbuild_array (loc_data);
      if (status != MEM_S_SUCCESS)
       {
          MEMclose (&loc_attr);
          MEMclose (&loc_data);
          MEMclose (&loc_values);
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
          MEMclose (&cat_values);
          sprintf(s,"MEM Build Array : status = <%d>\n", status);
	  PDMdebug(s);
	  app_ptr.error_no = NFM_E_FAILURE;
	  WFset_to_state(user_id,"PDM",app_ptr);    
          return (PDM_E_BUILD_ARRAY);
       }

      column = (char **) loc_attr -> column_ptr;
      data   = (char **) loc_attr -> data_ptr;

      a = -1; b = -1; 

      for (y = 0; y < loc_attr -> columns; ++y)
       {
                if (! strcmp (column [y], "n_name"))     a = y;
          else  if (! strcmp (column [y], "n_datatype")) b = y;
      }

      if (a < 0 || b < 0)
       {
          MEMclose (&loc_attr);
          MEMclose (&loc_data);
          MEMclose (&loc_values);
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
          MEMclose (&cat_values);
	  	   app_ptr.error_no = NFM_E_FAILURE;
		   WFset_to_state(user_id,"PDM",app_ptr);    
          sprintf(s,"System Is Corrupted : status = <%d>\n", status);
		  PDMdebug(s);
          return (PDM_E_BUFFER_FORMAT);
       }

      for (x = 0; x < loc_attr -> rows; ++x)
       {
         count = loc_attr -> columns * x;

         if (! strcmp (data [count + a], "n_catalogname"))
          {
            status = MEMwrite_data (loc_data, pdm_catalog, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (&loc_attr);
               MEMclose (&loc_data);
               MEMclose (&loc_values);
               MEMclose (&cat_attr);
               MEMclose (&cat_data);
               MEMclose (&cat_values);
               sprintf(s,"MEM Wr Data : status = <%d>\n", status);
			   PDMdebug(s);
  			   app_ptr.error_no = NFM_E_FAILURE;
			   WFset_to_state(user_id,"PDM",app_ptr);    
               return (PDM_E_WRITE_COLUMN);
             }
          }
         else if (! strcmp (data [count + a], "n_aclno"))
          {
            status = NFMget_acl_no(user_id,"NFM_CATALOG_ACL",&acl_no);
            if (status != NFM_S_SUCCESS)
             {
		  	   app_ptr.error_no = NFM_E_FAILURE;
	 		  WFset_to_state(user_id,"PDM",app_ptr);    
               MEMclose (&loc_attr);
               MEMclose (&loc_data);
               MEMclose (&loc_values);
               MEMclose (&cat_attr);
               MEMclose (&cat_data);
               MEMclose (&cat_values);
		 	   app_ptr.error_no = NFM_E_FAILURE;
			   WFset_to_state(user_id,"PDM",app_ptr);    
               sprintf(s,"Get Acl No : status = <%d>\n", status);
			   PDMdebug(s);
               return (status);
             }
			 sprintf(value, "%d", acl_no);
            status = MEMwrite_data (loc_data, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
		  	   app_ptr.error_no = NFM_E_FAILURE;
			   WFset_to_state(user_id,"PDM",app_ptr);    
               MEMclose (&loc_attr);
               MEMclose (&loc_data);
               MEMclose (&loc_values);
               MEMclose (&cat_attr);
               MEMclose (&cat_data);
               MEMclose (&cat_values);
               sprintf(s,"MEM Wr Data : status = <%d>\n", status);
			   PDMdebug(s);
               return (PDM_E_WRITE_COLUMN);
             }
          }
         else if (! strcmp (data [count + a], "n_application"))
          {
            status = MEMwrite_data (loc_data, "PDM", 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
		  	   app_ptr.error_no = NFM_E_FAILURE;
			   WFset_to_state(user_id,"PDM",app_ptr);    
               MEMclose (&loc_attr);
               MEMclose (&loc_data);
               MEMclose (&loc_values);
               MEMclose (&cat_attr);
               MEMclose (&cat_data);
               MEMclose (&cat_values);
               sprintf(s,"MEM Wr Data : status = <%d>\n", status);
			   PDMdebug(s);
               return (PDM_E_WRITE_COLUMN);
             }
          }
         else if (! strcmp (data [count + a], "n_type"))
          {
            status = MEMwrite_data (loc_data, n_type, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
	 	 	   app_ptr.error_no = NFM_E_FAILURE;
		 	   WFset_to_state(user_id,"PDM",app_ptr);    
               MEMclose (&loc_attr);
               MEMclose (&loc_data);
               MEMclose (&loc_values);
               MEMclose (&cat_attr);
               MEMclose (&cat_data);
               MEMclose (&cat_values);
			    sprintf(s,"MEM Wr Data : status = <%d>\n", status);
			   PDMdebug(s);
               return (PDM_E_WRITE_COLUMN);
             }
          }
       }


      status = NFMcreate_catalog (user_id, loc_attr, loc_data,
               cat_attr, cat_data, cat_values);
      if (status != NFM_S_SUCCESS)
       {
	 app_ptr.error_no = NFM_E_FAILURE;
	 WFset_to_state(user_id,"PDM",app_ptr);    
          MEMclose (&loc_attr);
          MEMclose (&loc_data);
          MEMclose (&loc_values);
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
          MEMclose (&cat_values);
		  sprintf(s,"NFMcreate_catalog failed status %d\n",status);
		  PDMdebug(s);
          return (status);
       }

       status = PDMquery_catalogno(pdm_catalog, &n_catalogno);
       sprintf(sql_str,"INSERT INTO pdmcatalogs (n_catalogno) VALUES(%d)",n_catalogno);
        status = SQLstmt(sql_str);

/* Added to set the default aclno to be 6 for the catalogs created 
   during PDMinit. MaC 012593 */

      status = PDMi_get_attribute_no (n_catalogno, "n_aclno", &n_attrno);

      sprintf(sql_str, 
      "INSERT INTO nfmvalues %s  VALUES (%d, 'C', '6')",
      " (n_attrno, n_type, n_defaultvalue) ", n_attrno);
      status = SQLstmt(sql_str);


/* Added to set the default p_maxlevel to be 50 for the catalogs created 
   during PDMinit. MaC 111193 */

      status = PDMi_get_attribute_no (n_catalogno, "p_maxlevel", &n_attrno);

      if (status == PDM_S_SUCCESS) {
         sprintf(sql_str, "INSERT INTO nfmvalues %s  VALUES (%d, 'C', '50')",
                        " (n_attrno, n_type, n_defaultvalue) ", n_attrno);
          status = SQLstmt(sql_str);
      }

      MEMclose (&loc_values);
      MEMclose (&cat_values);

      status = MEMclose (&loc_attr);
      if (status != MEM_S_SUCCESS)
       {
          MEMclose (&loc_data);
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
	  	   app_ptr.error_no = NFM_E_FAILURE;
		   WFset_to_state(user_id,"PDM",app_ptr);    
          return (status);
       }

      status = MEMclose (&loc_data);
      if (status != MEM_S_SUCCESS)
       {
 	 	   app_ptr.error_no = NFM_E_FAILURE;
		   WFset_to_state(user_id,"PDM",app_ptr);    
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
          return (status);
       }

      status = MEMclose (&cat_attr);
      if (status != MEM_S_SUCCESS)
       {
 	 	   app_ptr.error_no = NFM_E_FAILURE;
		   WFset_to_state(user_id,"PDM",app_ptr);    
          MEMclose (&cat_data);
          return (status);
       }

      status = MEMclose (&cat_data);
      if (status != MEM_S_SUCCESS)
       {
	  	   app_ptr.error_no = NFM_E_FAILURE;
		   WFset_to_state(user_id,"PDM",app_ptr);    
          return (status);
       }
	  app_ptr.error_no = NFM_S_SUCCESS;
      status = WFset_to_state (user_id,"PDM",app_ptr);
      if (status != NFM_S_SUCCESS)
       {
          return (status);
       }
 PDMdebug("EXIT:PDMi_create_pdm_catalog\n");      
 return (PDM_S_SUCCESS);
}

/* FUNCTION: PDMcreate_pdmfilename_table

   This function is called from PDMi_main.c and is used to create a table
   during PDM initialization.
   The table name is pdmfilename. It contains one column (p_cofilename) of
   type character. The value stored in pdmfilename is a 14 digit number used
   by PDU as a filename whenever a unique filename is required by the system.
   This filename/number is generated by the PDM function PDMgenerate_filename
   within the file PDMstools1.c. */

int  PDMcreate_pdmfilename_table(tablename)
   char *tablename;
{
	char	sql_str[512];

	PDMdebug("ENTER:PDMcreate_pdmfilename_table\n");
	sprintf(sql_str,"CREATE TABLE %s ( ",tablename);
	strcat(sql_str,"p_cofilename char (14)) ");
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",status);
		PDMdebug(s);
		PDMdebug("sql string :");
		PDMdebug(sql_str);
		PDMdebug("\n");
		return(PDM_E_SQL_STMT);
	}
	sql_str[0] = '\0';
	sprintf(sql_str,"INSERT INTO %s ",tablename);
        strcat(sql_str,"(p_cofilename)"); 
	strcat(sql_str,"VALUES ('00000000000000')");
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",status);
		PDMdebug(s);
		PDMdebug("sql string :");
		PDMdebug(sql_str);
		PDMdebug("\n");
		return(PDM_E_SQL_STMT);
	}
	PDMdebug("EXIT:PDMcreate_pdmfilename_table\n");
	return(PDM_S_SUCCESS);
 
}

/* eof */ 




 long PDMi_create_drawing_catalog (user_id,pdm_catalog,n_type)
   long   user_id;
   char	  *pdm_catalog;
   char	  *n_type;
   {
      long   status;
      MSGptr app_ptr;
      MEMptr loc_attr = NULL, loc_data = NULL, loc_values = NULL;
      MEMptr cat_attr = NULL, cat_data = NULL, cat_values = NULL;
      MEMptr application = NULL ;
      char   **column, **data;
      long   a, b, x, y, count, acl_no;
      char   loc_name [50], value[50], str [1024] ;

	PDMdebug("ENTER:PDMi_create_drawing_catalog\n");

    status = WFvalidate_user_access (user_id, "Create Catalog",
               "", "", "", "", "");
      if (status != NFM_S_SUCCESS)
       {
          sprintf(s,"WFValidate User Access : status = <%d>\n",
          status);PDMdebug(s);
          return (status);
       }
 
      status = NFMquery_addto_loc_attributes (user_id, loc_name,
               &loc_attr, &loc_data, &loc_values);
      if (status != NFM_S_SUCCESS)
       {

		sprintf(s,"%s %d\n",
		"NFMquery_addto_loc_attributes failed status \n",status);
		PDMdebug(s);
		app_ptr.error_no = NFM_E_FAILURE;
		WFset_to_state(user_id,"PDM",app_ptr);    
		return(status); 
        }


      status = MEMopen (&application, MEM_SIZE);
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&application);
	  sprintf (s, "NFMRquery_addto_loc_attributes : MEMopen : <0x%.8x>", 
		   status);
	  PDMdebug (s) ;
	  return (status);
	}

      
      status = MEMwrite_format (application, "n_type", "char(20)");
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&application);
	  sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite_format : <0x%.8x>", status);
	  PDMdebug (s) ;
	  return (status);
      }

    status = MEMwrite_format (application, "value", "char(20)");
    if (status != MEM_S_SUCCESS)
      {
        MEMclose (&application);
        sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite_format : <0x%.8x>", status);
	PDMdebug (s) ;
        return (status);
      }

      strcpy (str, "t_basic\001PDMDWG\001") ;

      status = MEMwrite (application, str);
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&application);
	  sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite : <0x%.8x>",
		   status) ;
	  return (NFM_E_MEM) ;
	}

      status = NFMquery_catalog_template_n (&cat_attr, &cat_data, &cat_values,
					    application) ;
      if (status != NFM_S_SUCCESS)
	{
          MEMclose (&loc_attr);
          MEMclose (&loc_data);
          MEMclose (&loc_values);
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
          MEMclose (&cat_values);
	  app_ptr.error_no = NFM_E_FAILURE;
	  WFset_to_state(user_id,"PDM",app_ptr);    
          sprintf(s,"MEM Build Array : status = <%d>\n", status);
	  PDMdebug(s);
          return (PDM_E_BUILD_ARRAY);
	}

      status = MEMbuild_array (loc_attr);
      if (status != MEM_S_SUCCESS)
       {
          MEMclose (&loc_attr);
          MEMclose (&loc_data);
          MEMclose (&loc_values);
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
          MEMclose (&cat_values);
	  app_ptr.error_no = NFM_E_FAILURE;
	  WFset_to_state(user_id,"PDM",app_ptr);    
          sprintf(s,"MEM Build Array : status = <%d>\n", status);
	  PDMdebug(s);
          return (PDM_E_BUILD_ARRAY);
       }

      status = MEMbuild_array (loc_data);
      if (status != MEM_S_SUCCESS)
       {
          MEMclose (&loc_attr);
          MEMclose (&loc_data);
          MEMclose (&loc_values);
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
          MEMclose (&cat_values);
          sprintf(s,"MEM Build Array : status = <%d>\n", status);
	  PDMdebug(s);
	  app_ptr.error_no = NFM_E_FAILURE;
	  WFset_to_state(user_id,"PDM",app_ptr);    
          return (PDM_E_BUILD_ARRAY);
       }

      column = (char **) loc_attr -> column_ptr;
      data   = (char **) loc_attr -> data_ptr;

      a = -1; b = -1; 

      for (y = 0; y < loc_attr -> columns; ++y)
       {
                if (! strcmp (column [y], "n_name"))     a = y;
          else  if (! strcmp (column [y], "n_datatype")) b = y;
      }

      if (a < 0 || b < 0)
       {
          MEMclose (&loc_attr);
          MEMclose (&loc_data);
          MEMclose (&loc_values);
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
          MEMclose (&cat_values);
	  	   app_ptr.error_no = NFM_E_FAILURE;
		   WFset_to_state(user_id,"PDM",app_ptr);    
          sprintf(s,"System Is Corrupted : status = <%d>\n", status);
		  PDMdebug(s);
          return (PDM_E_BUFFER_FORMAT);
       }

      for (x = 0; x < loc_attr -> rows; ++x)
       {
         count = loc_attr -> columns * x;

         if (! strcmp (data [count + a], "n_catalogname"))
          {
            status = MEMwrite_data (loc_data, pdm_catalog, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (&loc_attr);
               MEMclose (&loc_data);
               MEMclose (&loc_values);
               MEMclose (&cat_attr);
               MEMclose (&cat_data);
               MEMclose (&cat_values);
               sprintf(s,"MEM Wr Data : status = <%d>\n", status);
			   PDMdebug(s);
  			   app_ptr.error_no = NFM_E_FAILURE;
			   WFset_to_state(user_id,"PDM",app_ptr);    
               return (PDM_E_WRITE_COLUMN);
             }
          }
         else if (! strcmp (data [count + a], "n_aclno"))
          {
            status = NFMget_acl_no(user_id,"NFM_CATALOG_ACL",&acl_no);
            if (status != NFM_S_SUCCESS)
             {
		  	   app_ptr.error_no = NFM_E_FAILURE;
	 		  WFset_to_state(user_id,"PDM",app_ptr);    
               MEMclose (&loc_attr);
               MEMclose (&loc_data);
               MEMclose (&loc_values);
               MEMclose (&cat_attr);
               MEMclose (&cat_data);
               MEMclose (&cat_values);
		 	   app_ptr.error_no = NFM_E_FAILURE;
			   WFset_to_state(user_id,"PDM",app_ptr);    
               sprintf(s,"Get Acl No : status = <%d>\n", status);
			   PDMdebug(s);
               return (status);
             }
			 sprintf(value, "%d", acl_no);
            status = MEMwrite_data (loc_data, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
		  	   app_ptr.error_no = NFM_E_FAILURE;
			   WFset_to_state(user_id,"PDM",app_ptr);    
               MEMclose (&loc_attr);
               MEMclose (&loc_data);
               MEMclose (&loc_values);
               MEMclose (&cat_attr);
               MEMclose (&cat_data);
               MEMclose (&cat_values);
               sprintf(s,"MEM Wr Data : status = <%d>\n", status);
			   PDMdebug(s);
               return (PDM_E_WRITE_COLUMN);
             }
          }
         else if (! strcmp (data [count + a], "n_application"))
          {
            status = MEMwrite_data (loc_data, "PDM", 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
		  	   app_ptr.error_no = NFM_E_FAILURE;
			   WFset_to_state(user_id,"PDM",app_ptr);    
               MEMclose (&loc_attr);
               MEMclose (&loc_data);
               MEMclose (&loc_values);
               MEMclose (&cat_attr);
               MEMclose (&cat_data);
               MEMclose (&cat_values);
               sprintf(s,"MEM Wr Data : status = <%d>\n", status);
			   PDMdebug(s);
               return (PDM_E_WRITE_COLUMN);
             }
          }
         else if (! strcmp (data [count + a], "n_type"))
          {
            status = MEMwrite_data (loc_data, n_type, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
	 	 	   app_ptr.error_no = NFM_E_FAILURE;
		 	   WFset_to_state(user_id,"PDM",app_ptr);    
               MEMclose (&loc_attr);
               MEMclose (&loc_data);
               MEMclose (&loc_values);
               MEMclose (&cat_attr);
               MEMclose (&cat_data);
               MEMclose (&cat_values);
			    sprintf(s,"MEM Wr Data : status = <%d>\n", status);
			   PDMdebug(s);
               return (PDM_E_WRITE_COLUMN);
             }
          }
       }


      status = NFMcreate_catalog (user_id, loc_attr, loc_data,
               cat_attr, cat_data, cat_values);
      if (status != NFM_S_SUCCESS)
       {
	 app_ptr.error_no = NFM_E_FAILURE;
	 WFset_to_state(user_id,"PDM",app_ptr);    
          MEMclose (&loc_attr);
          MEMclose (&loc_data);
          MEMclose (&loc_values);
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
          MEMclose (&cat_values);
		  sprintf(s,"NFMcreate_catalog failed status %d\n",status);
		  PDMdebug(s);
          return (status);
       }

      MEMclose (&loc_values);
      MEMclose (&cat_values);

      status = MEMclose (&loc_attr);
      if (status != MEM_S_SUCCESS)
       {
          MEMclose (&loc_data);
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
	  	   app_ptr.error_no = NFM_E_FAILURE;
		   WFset_to_state(user_id,"PDM",app_ptr);    
          return (status);
       }

      status = MEMclose (&loc_data);
      if (status != MEM_S_SUCCESS)
       {
 	 	   app_ptr.error_no = NFM_E_FAILURE;
		   WFset_to_state(user_id,"PDM",app_ptr);    
          MEMclose (&cat_attr);
          MEMclose (&cat_data);
          return (status);
       }

      status = MEMclose (&cat_attr);
      if (status != MEM_S_SUCCESS)
       {
 	 	   app_ptr.error_no = NFM_E_FAILURE;
		   WFset_to_state(user_id,"PDM",app_ptr);    
          MEMclose (&cat_data);
          return (status);
       }

      status = MEMclose (&cat_data);
      if (status != MEM_S_SUCCESS)
       {
	  	   app_ptr.error_no = NFM_E_FAILURE;
		   WFset_to_state(user_id,"PDM",app_ptr);    
          return (status);
       }
	  app_ptr.error_no = NFM_S_SUCCESS;
      status = WFset_to_state (user_id,"PDM",app_ptr);
      if (status != NFM_S_SUCCESS)
       {
          return (status);
       }
      PDMdebug("EXIT:PDMi_create_drawing_catalog\n");      
      return (PDM_S_SUCCESS);
}




int PDMi_get_attribute_no (n_tableno,n_name,n_attrno)
int  n_tableno;
char *n_name;
int      *n_attrno;
{
        char    sql_str[512];
        MEMptr  bufr = NULL;
        char    **data;

        PDMdebug("ENTER:PDMget_attribute_no\n");
        sprintf(sql_str,"%s %s %d %s '%s'",
        "SELECT n_attrno FROM nfmattributes ",
        "WHERE n_tableno = ", n_tableno,
        "AND n_name = ", n_name);
        status = SQLquery(sql_str, &bufr, 512);
        if(status != SQL_S_SUCCESS) {
          MEMclose(&bufr);
          switch(status)
          {
            case SQL_I_NO_ROWS_FOUND :
                  PDMdebug("Attribute Found \n");
                  return(PDM_I_ATTR_NOT_FOUND);
            default:
                  return(PDM_E_SQL_QUERY);
                  }
        }
        status = MEMbuild_array(bufr);
        if(status != MEM_S_SUCCESS) {
          MEMclose(&bufr);
          sprintf(s,"MEMbuild_array failed status %d\n",
                status);PDMdebug(s);
          return(PDM_E_BUILD_ARRAY);
        }
 data = (char **) bufr->data_ptr;
 *n_attrno = atol(data[0]);
 MEMclose(&bufr);
 PDMdebug("EXIT:PDMget_attribute_no\n");
 return(PDM_S_SUCCESS);
}

/* Added to support reporting on classifications - Kumar 2/22/93 */

int  PDMcreate_nfmpdmcat_view()
{
        char *fname = "PDMcreate_nfmpdmcat_view";
	char	sql_str[1024];

	_PDMdebug(fname, "ENTER:\n");
         sql_str[0]= '\0';
	sprintf(sql_str,"create view nfmpdmcat as select t1.n_catalogno,t1.n_catalogname,t1.n_catalogdesc ,t1.n_creator,t1.n_creationdate,t1.n_updater,t1.n_updatedate,t1.n_identifier,t1.n_stateno,t1.n_aclno,t1.n_type,t1.n_archiveno,t1.n_archivestate,t1.n_pendingflag,t2.p_autofilename,t2.p_dyntable,t2.p_defname,t2.p_level1,t2.p_level2,t2.p_level3,t2.p_level4,t2.p_level5,t2.p_level6,t2.p_level7,t2.p_level8,t2.p_level9,t2.p_level10,t2.p_depth from nfmcatalogs t1 ,pdmcatalogs t2 where t1.n_catalogno = t2. n_catalogno");
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		_PDMdebug(fname,"SQLstmt failed status %d\n",status);
		return(PDM_E_SQL_STMT);
	}
	_PDMdebug(fname,"EXIT:\n");
	return(PDM_S_SUCCESS);
 
}
