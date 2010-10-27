/* $Id: VDSpdmtable.c,v 1.1.1.1 2001/01/04 21:08:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpdm/source / VDSpdmtable.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSpdmtable.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:58  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

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

#include "MEMstruct.h"
#include "MSGstruct.h"
#include "DEBUG.h"

#include	"VDSdberrdef.h"
#include	"VDSpdminit.h"
#include	"VDSdbstr.h"

/* local definitions */


static  int	 status; 
static  char s[1024]; 

extern 	struct	msg_struct   NFMmsg_ptr;
extern 	struct	msg_struct   MEMmsg_ptr;
extern 	struct	msg_struct   SQLmsg_ptr;

extern  int		VDSdebug_on;
extern	char    	VDS_DEBUG_FILE[];

VDScreate_required_table (user_id, table_id)
  long	user_id;
  int	table_id;
{
	char		attr_file[120];
	char		data_file[120];
	char		list_file[120];
	char		s[1024], table_name[40];

	VDSdebug("ENTER:VDScreate_required_table\n");

	attr_file[0] = 0;
	data_file[0] = 0;
	list_file[0] = 0;

   switch (table_id)
   {
	case VDSPDM_LOC:
		sprintf (attr_file,"%s%s%s",VDS_DIR,DELIM,"PDMloc.attr");
		sprintf (data_file,"%s%s%s",VDS_DIR,DELIM,"PDMloc.data");
		list_file[0] = 0;
		strcpy (table_name, "pdmcatalogs");
		break;
	case VDSPDM_PARAMETERS:
		sprintf (attr_file,"%s%s%s",VDS_DIR,DELIM,"PDMparam.attr");
		sprintf (data_file,"%s%s%s",VDS_DIR,DELIM,"PDMparam.data");
		list_file[0] = 0;
		strcpy (table_name, "pdmparameters");
		break;
	case VDSPDM_PARAMLOC:
		sprintf (attr_file,"%s%s%s",VDS_DIR,DELIM,"PDMparloc.attr");
		sprintf (data_file,"%s%s%s",VDS_DIR,DELIM,"PDMparloc.data");
		list_file[0] = 0;
		strcpy (table_name, "pdmparamloc");
		break;
	default:
		VDSdebug("VDScreate_required_table \n");
		sprintf (s,"Invalid table_id; table_id = %d\n", table_id);
		VDSdebug(s);
		status = VDS_E_INVALID_TABLEID;
		return (status);
     }
     status = VDScreate_table(user_id,attr_file,data_file,
			      list_file,table_name);
     if(status != VDS_S_SUCCESS)
	{
		sprintf(s,"VDScreate_table failed status %x\n",status);
		printf("VDScreate_table failed status %d\n",status);
		VDSdebug(s);
		return(status);
	}   
	VDSdebug("EXIT:VDScreate_required_table\n");
	return(VDS_S_SUCCESS);
}

int  VDScreate_table(user_id,attr_file,data_file,list_file,table_name)
long	user_id;
char	*attr_file;
char	*data_file;
char	*list_file;
char	*table_name;
{
	MEMptr	    attr_buffer = NULL;
	MEMptr	    data_buffer = NULL;
	MEMptr	    list_buffer = NULL;
	int	    status;

	VDSdebug("ENTER:VDScreate_table\n");

/*  Get a template of attribute bufr from NFM  */
     
     status = NFMquery_table_template(user_id,&attr_buffer);
     if (status != NFM_S_SUCCESS)
     {
		sprintf(s,
 		 "NFMquery_table_template failed; status = %d\n", status);
		printf(
 		 "NFMquery_table_template failed; status = 0x%.8x\n", status);
		VDSdebug(s);
		MEMclose (&attr_buffer);
		status = VDS_E_QUERY_TABLE_TEMPLATE;
		return (status);
     }
     status = MEMbuild_array (attr_buffer);
     if (status != MEM_S_SUCCESS)
     {
		sprintf(s,
 		 "MEMbuild_array failed; status = %d\n", status);
		printf(
 		 "MEMbuild_array failed; status = 0x%.8x\n", status);
		VDSdebug(s);
		MEMclose (&attr_buffer);
		status = VDS_E_BUILD_ARRAY;
		return (status);
     }

   /*  Add the required attributes for the table  */

    status = VDSattrfile_to_buffer (attr_file,attr_buffer);
    if (status != VDS_S_SUCCESS)
    {
        sprintf(s,"VDSattrfile_to_buffer failed : %d",status);
	 	VDSdebug(s);
 		MEMclose (&attr_buffer);
 		return (status); 
    }

   /*  Load initial & default values of the above attrbs from 
       .data file */

     status = VDSdatafile_to_buffer (data_file, attr_buffer, &data_buffer);
     if (status != VDS_S_SUCCESS)
     {
		sprintf(s,"VDSdatafile_to_buffer failed : %d\n",status);
		VDSdebug(s);
		MEMclose(&data_buffer);
		MEMclose (&attr_buffer);
		return (status);
     }

   /*  Load list values of the above attrbs from file */
   /*  there may or may not be a list_file */

/*
     if(strcmp(list_file,""))
     {
     	status = VDSlistfile_to_buffer (list_file, &list_buffer);
        if (status != VDS_S_SUCCESS)
        {
	    	sprintf(s,"VDSlistfile_to_buffer failed : %d",status);
	    	VDSdebug(s);
	    	MEMclose (&attr_buffer);
	    	MEMclose(&data_buffer);
	    	MEMclose(&list_buffer);
	    	return (status);
         }
      }
*/
     
    /*  Call NFM to create the table  */

     status = NFMcreate_table (user_id, table_name, table_name, "PDM",
			       attr_buffer,data_buffer,list_buffer);
     if (status != NFM_S_SUCCESS)
     {
	    sprintf(s,"NFMcreate_table failed : %d",status);
	    printf("NFMcreate_table failed : 0x%.8x",status);
	    VDSdebug(s);
	    MEMclose (&attr_buffer);
	    MEMclose(&data_buffer);
	    MEMclose(&list_buffer);
	    status = VDS_E_CREATE_TABLE;
	    return (status);
     }

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&list_buffer);
	VDSdebug("EXIT:VDScreate_table\n");
    return (VDS_S_SUCCESS);
}

long VDSi_create_pdm_catalog (user_id,pdm_catalog,n_type)
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
      long   a, b, x, y, count, acl_no;
      char    sql_str[250];
      char   loc_name [50], value[50], str [1024] ;

	VDSdebug("ENTER:VDSi_create_pdm_catalog\n");

    status = WFvalidate_user_access (user_id, "Create Catalog",
               "", "", "", "", "");
      if (status != NFM_S_SUCCESS)
       {
          sprintf(s,"WFValidate User Access : status = <%d>\n",
          status);VDSdebug(s);
          return (status);
       }
 
      status = NFMquery_addto_loc_attributes (user_id, loc_name,
               &loc_attr, &loc_data, &loc_values);
      if (status != NFM_S_SUCCESS)
       {

		sprintf(s,"%s %d\n",
		"NFMquery_addto_loc_attributes failed status \n",status);
		VDSdebug(s);
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
		VDSdebug(s);
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
	  VDSdebug (s) ;
	  return (status);
	}

      
      status = MEMwrite_format (application, "n_type", "char(20)");
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&application);
	  sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite_format : <0x%.8x>", status);
	  VDSdebug (s) ;
	  return (status);
      }

    status = MEMwrite_format (application, "value", "char(20)");
    if (status != MEM_S_SUCCESS)
      {
        MEMclose (&application);
        sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite_format : <0x%.8x>", status);
	VDSdebug (s) ;
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
	  VDSdebug(s);
          return (VDS_E_BUILD_ARRAY);
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
	  VDSdebug(s);
          return (VDS_E_BUILD_ARRAY);
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
	  VDSdebug(s);
	  app_ptr.error_no = NFM_E_FAILURE;
	  WFset_to_state(user_id,"PDM",app_ptr);    
          return (VDS_E_BUILD_ARRAY);
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
		  VDSdebug(s);
          return (VDS_E_BUFFER_FORMAT);
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
			   VDSdebug(s);
  			   app_ptr.error_no = NFM_E_FAILURE;
			   WFset_to_state(user_id,"PDM",app_ptr);    
               return (VDS_E_WRITE_COLUMN);
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
			   VDSdebug(s);
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
			   VDSdebug(s);
               return (VDS_E_WRITE_COLUMN);
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
			   VDSdebug(s);
               return (VDS_E_WRITE_COLUMN);
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
			   VDSdebug(s);
               return (VDS_E_WRITE_COLUMN);
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
		  VDSdebug(s);
          return (status);
       }

       status = VDSget_catno(pdm_catalog, &n_catalogno);
        sprintf(sql_str,"INSERT INTO pdmcatalogs (n_catalogno) VALUES(%d)",n_catalogno);
        status = VDSexecute_sql_stmt(sql_str);
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
      VDSdebug("EXIT:VDSi_create_pdm_catalog\n");      
      return (VDS_S_SUCCESS);
}
