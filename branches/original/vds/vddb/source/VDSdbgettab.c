/* $Id: VDSdbgettab.c,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbgettab.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbgettab.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:13  cvs
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
 * Revision 1.6  1996/05/20  15:40:54  pinnacle
 * Replaced: vddb/source/VDSdbgettab.c for:  by v240_int for vds.240
 *
 * Revision 1.5  1996/05/20  14:33:44  pinnacle
 * Replaced: vddb/source/VDSdbgettab.c for:  by v240_int for vds.240
 *
 * Revision 1.4  1996/05/20  05:01:14  pinnacle
 * Replaced: vddb/source/VDSdbgettab.c for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/04/22  15:14:06  pinnacle
 * Replaced: vddb/source/VDSdbgettab.c for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/21  23:49:32  pinnacle
 * Replaced: vddb/source/VDSdbgettab.c for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/18/96   tlb		Add prototypes
 *	04/22/96     tlb	Fix log comment problem 
 *	04/30/96     tlb	Add NFM prototypes
 *				VDSget_table_attributes: remove catalog arg
 *			    	Add VDS memory checking
 *			    	Use new error routines
 *				VDScreate_application - return VDS error
 *				VDSget_table_attributes - close application
 *
 * -------------------------------------------------------------------*/

#include  <stdio.h>
#include  <string.h>
#include  "MEMerrordef.h"
#include  "MEMstruct.h"
#include  "MEMproto.h"
#include  "NFMerrordef.h"
#include  "NFMstruct.h"
#include  "DEBUG.h"
#include  "NFMapi.h"
#include  "NDXstruct.h"
#include  "NFMAproto.h"
#include  "NFMRproto.h"
#include  "NFMUproto.h"
#include  "VDSdberrdef.h"
#include	"v_risproto.h"
#include	"v_dbloadprot.h"


/*----------------------------------------------------------------------*/
int	VDSget_table_data ( 	int	operation,
				int	entity,
				char	*catalog,
				MEMptr	*attribute_buffer,
				MEMptr	*data_buffer,
				MEMptr	*list_buffers)
{
	int	status;
	char	loc_name[25];

	VDSdebug("ENTER: VDSget_table_data\n");

	*attribute_buffer = NULL;
	*data_buffer = NULL;
	*list_buffers = NULL;

	switch (entity) {
	case PDM_LOC :
	
	    switch (operation) {
		case ADD_DATA:

		     if (( status = NFMquery_addto_loc_attributes ( 
					VDSuser_id, loc_name, attribute_buffer,
					data_buffer, list_buffers )) 
					!= NFM_S_SUCCESS ) {

        		    VDSprintNfmErr("\t","NFMquery_addto_loc_attributes",
								 	status);
			    VDSprintErr("\t","Cannot get attributes from <%s>\n"
								, catalog);
			     MEMclose (attribute_buffer);
			     MEMclose (data_buffer);
			     MEMclose (list_buffers);
			     status = VDS_E_QUE_LOC_ATT;
			     return ( status );
			     }
			break;
		default:
			fprintf( stdout, "%s: Not a valid operation: %d\n",
						"VDSget_table_data", operation);
			return VDS_E_FAILURE;
		}
		break;

	case PDM_PART :

	    switch (operation) {
		case ADD_DATA:

		    if (( status = NFMquery_add_item_attributes ( 
					VDSuser_id, catalog, attribute_buffer, 
					data_buffer, list_buffers )) 
				   != NFM_S_SUCCESS) 
			{
        		    VDSprintNfmErr("\t","NFMquery_addto_loc_attributes",
								 	status);
			     status = VDS_E_QUE_ITEM_ATT;
			     MEMclose (attribute_buffer);
			     MEMclose (data_buffer);
			     MEMclose (list_buffers);
			     return ( status );
			     }
			break;
		default:
			VDSprintErr( "%s: Not a valid operation: %d\n",
						"VDSget_table_data", operation);
			return VDS_E_FAILURE;
		}
		break;
	default:
		VDSprintErr( "%s: Not a valid entity: %d\n",
						"VDSget_table_data", entity);
		return VDS_E_FAILURE;
	}

	VDSdebug("EXIT: VDSget_table_data\n");
	return VDS_S_SUCCESS;
}

/*----------------------------------------------------------------------*/
int	VDSget_table_attributes ( 
			int	operation,
			int	entity,
			MEMptr	*attribute_buffer,
			MEMptr	*data_buffer,
			MEMptr	*list_buffers
			)
{
	int	sts, status;
	MEMptr  application = NULL;

	VDSdebug("ENTER: VDSget_table_attributes\n");
	*attribute_buffer = NULL;
	*data_buffer = NULL;
	*list_buffers = NULL;

	switch (entity) {
	case PDM_CATALOG :
	
	   switch (operation) {
		case ADD_TABLE:
			status = VDScreate_application( &application );
			if ( status != VDS_S_SUCCESS ) {
      			    VDSprintVdsErr( "\t", "VDScreate_application", 
								status );
			    status = VDS_E_CREATE_APP;
			    }
			if ((status = NFMquery_catalog_template_n ( 
						attribute_buffer, data_buffer,
					 	list_buffers, application )) 
					!= NFM_S_SUCCESS )
			{
        		    VDSprintNfmErr( "\t","NFMquery_catalog_template_n",
								 status);
			     status = VDS_E_GET_CAT_TEMP;
				}
			else
			     status = VDS_S_SUCCESS;
		
			break;
		default:
			VDSprintErr( "%s: Not a valid operation: %d\n",
					"VDSget_table_attributes", operation);
			status = VDS_E_FAILURE;
		}
		break;
	default:
		VDSprintErr( "\t", "%s: Not a valid entity: %d\n",
					"VDSget_table_attributes", entity);
		status = VDS_E_FAILURE;
	}
wrapup:
        sts = MEMclose (&application);
	if (sts != MEM_S_SUCCESS) 
		VDSprintMemErr("\t", "MEMclose", sts, VDS_E_CLOSE_BUFFER);
	VDSdebug("EXIT: VDSget_table_attributes\n");
	return status;
}


/*----------------------------------------------------------------------*/
int VDScreate_application(application)
MEMptr *application;
{
 int   status;
 char  str[100];

      VDSdebug("ENTER: VDScreate_application\n");

      status = MEMopen (application, 512);
      if (status != MEM_S_SUCCESS) {
          VDSprintMemErr( "\t", "MEMopen", status, VDS_E_OPEN_BUFFER);
          status  = VDS_E_OPEN_BUFFER;
	  goto wrapup;
        }


      status = MEMwrite_format (*application, "n_type", "char(20)");
      if (status != MEM_S_SUCCESS) {
          VDSprintMemErr( "\t", "MEMwrite_format", status, VDS_E_WRITE_BUFFER);
          status  = VDS_E_WRITE_BUFFER;
	  goto wrapup;
      }

      status = MEMwrite_format (*application, "value", "char(20)");
      if (status != MEM_S_SUCCESS) {
          VDSprintMemErr( "\t", "MEMwrite_format", status, VDS_E_WRITE_BUFFER);
          status  = VDS_E_WRITE_BUFFER;
	  goto wrapup;
      }

      strcpy (str, "t_basic\001PDM\001") ;

      status = MEMwrite (*application, str);
      if (status != MEM_S_SUCCESS) {
          VDSprintMemErr( "\t", "MEMwrite", status, VDS_E_WRITE_BUFFER);
          status  = VDS_E_WRITE_BUFFER;
          goto wrapup;
        }
     status = VDS_S_SUCCESS;

wrapup:
      VDSdebug("EXIT: VDScreate_application\n");
      return (status);
}

/*---------------------------------------------------------------------*/
int VDSadd_part_( catalog, attr_list, data_list )
char	*catalog;
MEMptr          attr_list;
MEMptr          data_list;
{
        char            **column_ptr;
        char            **data;
        int             i = 0,a1 = -1,a2 = -1;
	int		status = VDS_S_SUCCESS;
	char		s[1024];


        VDSdebug("ENTER : VDSadd_part_\n");

        status = MEMbuild_array(data_list);
        if(status != MEM_S_SUCCESS) {
          	VDSprintMemErr( "\t", "MEMbuild_array", status, 
							VDS_E_BUILD_ARRAY);
        	return(VDS_E_BUILD_ARRAY);
        	}

        column_ptr = (char **) data_list->column_ptr;
        data = (char **) data_list->data_ptr;
        a1 = -1; a2 = -1;
        for(i=0;i<data_list->columns;i++) {
                if(!strcmp(column_ptr[i],"p_maxlevel")) a1 = i;
                if(!strcmp(column_ptr[i],"p_explode"))  a2 = i;
        }

        if(a1 == -1 || a2 == -1) {
          	VDSprintErr( "failed to set offsets in data_list\n" );
        	return(VDS_E_BUFFER_FORMAT);
           	}

        if(!strcmp(data[a1],"") || !strlen(data[a1])) {
                /* default p_maxlevel is 0 */

                s[0] = 0;
                sprintf(s,"%d",0);
                status = MEMwrite_data(data_list,s,1,a1+1);
                if(status != MEM_S_SUCCESS) {
          		VDSprintMemErr( "\t", "MEMwrite_data", status, 
							VDS_E_WRITE_COLUMN);
                	return(VDS_E_WRITE_COLUMN);
                	}
        	}

        /* if p_explode is not set default to Y */
        if(!strcmp(data[a2],"") || !strlen(data[a2])) {
                status = MEMwrite_data(data_list,"Y",1,a2+1);
                if(status != MEM_S_SUCCESS) {
          		VDSprintMemErr( "\t", "MEMwrite_data", status, 
						VDS_E_WRITE_COLUMN);
                	return(VDS_E_WRITE_COLUMN);
                	}
        	}
   	status = NFMadd_item(VDSuser_id,catalog, attr_list,data_list);
    	if(status != NFM_S_SUCCESS) {
        	VDSprintNfmErr( "\t", "NFMadd_item", status);
        	if(status == NFM_E_DUP_ITEM) 
			return(VDS_E_PART_EXISTS);
    		}

   VDSdebug("EXIT : VDSadd_part_\n");
   return (VDS_S_SUCCESS);
}


/*---------------------------------------------------------------------------*/
int VDSupdate_data_buffer(data_buffer, attr_buffer)
  MEMptr	*data_buffer;	/* i/o - buffer containing old data for defaults and new user defined attribute defaults and initial values */
  MEMptr	attr_buffer;	/* i - buffer of attributes (default and user defined */

/******************************************************************************
Copy of PDUupdate_data_buffer

Doc:	VDSupdate_data_buffer

Abstract:
	Create a new data buffer which matches the attribute buffer.

Algorithm:
	.bp
	1.	Build new array of pointers to the modified attribute buffer.
	2.	Open a new data buffer.
	3.	Put the old data buffer column names and formats in the 
			new buffer.
	4.	Put the new attributes and data type in new buffer column 
			names and format information.
	5.	Add the data from the old buffer in the new buffer.
	.ep

Return Status:

	VDS_S_SUCCESS			- Successful completion
	VDS_E_BUILD_BUFFER_ARRAY	- Could not build array of pointers 
						to the new attribute buffer
	VDS_E_OPEN_BUFFER		- Could not open a new buffer
	VDS_E_WRITE_BUFFER		- Could not write data to the new buffer
	VDS_E_WRITE_FORMAT		- Could not write the format 
						information to the new buffer

Caveats:

History:

*****************************************************************************/

{
    int		status = VDS_S_SUCCESS; /* PDM status */
    MEMptr	new_buffer = NULL;	/* new buffer containing new defaults 
						and initials */
    int		row = 0; 		/* row index for buffer */
    int		col = 0; 		/* column index for buffer */
    char	*string = NULL; 	/* string to concatenate the data to 
						put in new buffer */
    int		string_len = 0; 	/* length of string used to add a 
						row to new buffer */
    int		string_index = NULL; 	/* character index for string */
    char        **data_cols = NULL; 	/*     added NULL    APOGEE   */
    char	**data_format = NULL; 	/*   added NULL    APOGEE   */
            /* array of pointers to data types of columns in old data buffer */
    char	**data_data = NULL; 	/*     added NULL    APOGEE   */
	            /* array of pointers to old default and initial values */
    char	**attr_data; 		/* array of pointers to default and 
						user defined attributes */
    int         max_col;
    int         max_row;
    int		sts;

    VDSdebug("ENTER VDSupdate_data_buffer\n");

    /* construct array of pointers to attribute data */
    status = MEMbuild_array(attr_buffer);
    if ( status != MEM_S_SUCCESS) {
      VDSprintMemErr ("\t", "MEMbuild_array", status, VDS_E_BUILD_BUFFER_ARRAY);
      return(VDS_E_BUILD_BUFFER_ARRAY);
      }

    if (*data_buffer)
     {
      status = MEMbuild_array(*data_buffer);
      if ( status != MEM_S_SUCCESS){
         VDSprintMemErr ("\t", "MEMbuild_array", status, 
						VDS_E_BUILD_BUFFER_ARRAY);
         return(VDS_E_BUILD_BUFFER_ARRAY);
	 }
     }

    /* open the new buffer */
    status = MEMopen(&new_buffer, VDS_BUFFER_SIZE);
    if (status != MEM_S_SUCCESS) {
      VDSprintMemErr ("\t", "MEMopen", status, VDS_E_OPEN_BUFFER);
      return(VDS_E_OPEN_BUFFER);
      }

    if (*data_buffer)
     {
      data_cols = (char **)(*data_buffer)->column_ptr;
      data_format = (char **)(*data_buffer)->format_ptr;
      data_data = (char **)(*data_buffer)->data_ptr;
      max_col = (*data_buffer)->columns;
      max_row = (*data_buffer)->rows;
     }
    else

    {
     max_col = 0;
    
     if (attr_buffer->rows == 0)
        max_row = 0;
     else
        max_row = 1;
    }
      attr_data = (char **) attr_buffer->data_ptr;

    /* write the format information from the old buffer to the new buffer */
    for (col=0; col<max_col; ++col)
      {
        status = MEMwrite_format (new_buffer, data_cols[col], data_format[col]);

        if (status != MEM_S_SUCCESS) {
           VDSprintMemErr ("\t", "MEMwrite_format", status, VDS_E_WRITE_FORMAT);
	   /* prototype catch - previously not passing pointer 4/30/96 */
            MEMclose(&new_buffer);
            return (VDS_E_WRITE_FORMAT);
          }
          
      }

    /* put the attribute name and data types for new attribute in column data */
    for (row=max_col;col<attr_buffer->rows; ++row, ++col)
      {
        status = MEMwrite_format(new_buffer, 
                   attr_data[(attr_buffer->columns * row)+VDS_NFM_ATTR_COL],
                   attr_data[(attr_buffer->columns * row)+VDS_NFM_DATA_COL]);

        if (status != MEM_S_SUCCESS) {
           VDSprintMemErr ("\t", "MEMwrite_format", status, VDS_E_WRITE_FORMAT);
            MEMclose(&new_buffer);
            return(VDS_E_WRITE_FORMAT);
          }
      }

    string_len = new_buffer->row_size;
    string = _MALLOC (string_len, char);
    _CheckAlloc(string, "row string", status, VDS_E_ALLOC_MEMORY, fail )

    for (row=0; row < max_row; ++row)
      {
        string_index=0;
        memset(string,NULL, string_len);

	/* copy the old defaults and initials */
       for (col=0; col<max_col; ++col)
           VDSadd_buffer_string(string, &string_index, 
			data_data[(max_col * row) + col]);
       
       /* add the blank values for the user defined attributes */
       for (; col<attr_buffer->rows; ++col)
         string[string_index++] = VDS_BUFFER_TERM;

       status = MEMwrite(new_buffer, string);
       if ( status != MEM_S_SUCCESS) {
           VDSprintMemErr ("\t", "MEMwrite", status, VDS_E_WRITE_BUFFER);
           status = VDS_E_WRITE_BUFFER;
	   goto fail;
         }
      }
    status = VDS_S_SUCCESS;

wrapup:
    _FREE(string);
    sts = MEMclose(data_buffer);
    if (sts != MEM_S_SUCCESS) 
           VDSprintMemErr ("\t", "MEMclose", sts, VDS_E_CLOSE_BUFFER);

    *data_buffer = new_buffer;
    VDSdebug("EXIT VDSupdate_data_buffer\n");

   return (status);
	
fail:
   MEMclose(&new_buffer);
   _FREE(string);
   return (status);
}


/*---------------------------------------------------------------------------*/
int VDSfind_attr_in_buffer(buffer, attr)
  MEMptr	buffer; 	/* i - buffer of attributes */
  char		*attr;		/* i - attribute or synonym */

/******************************************************************************

Doc:	VDSfind_attr_in_buffer
Copy of PDUfind_attr_in_buffer

Abstract:
	Finds the row in a buffer which contains an attribute or synonym.
	
Algorithm:
	.bp
		1.	If the attribute name passed in is equal to the row in the buffer, return the row number and exit function.
	.ep

Return Status:
	none	

Caveats:

History:
	9/13/89	-	Documentation date
*****************************************************************************/

{
  int		row;
  int		col;
  char 		**data;

  data = (char **)buffer->data_ptr;

  for (row=0; row<buffer->rows; ++row)
    {
      for (col=0; col<buffer->columns; ++col)
        {
          if (strcmp(data[(buffer->columns * row) + col],attr) == 0)
            break;
        }
      if ( col < buffer->columns)
        break;
    }

  if (row == buffer->rows)
    row = -1;

  return(row);
}    

/*---------------------------------------------------------------------------*/
int VDSfind_col_in_buffer(buffer, attr)
  MEMptr	buffer; 	/* i - buffer of attributes */
  char		*attr;		/* i - attribute or synonym */

{
  int		row;
  char 		**data;

  data = (char **)buffer->column_ptr;

  for (row=0; row<buffer->columns; ++row)
    {
     if (strcmp(data[row],attr) == 0)
       break;
    }

  if (row == buffer->columns)
    row = -1;

  return(row);
}

/*---------------------------------------------------------------------------*/
int VDSadd_buffer_string(
  		char			*buff_string,
  		int			*position,
  		char			*char_string)
{
    strcpy((buff_string + (*position)), char_string);
    (*position) += strlen(char_string);

    buff_string[(*position)++] = VDS_BUFFER_TERM;
    return(VDS_S_SUCCESS);
}

