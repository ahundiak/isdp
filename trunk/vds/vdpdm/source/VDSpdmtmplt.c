/* $Id: VDSpdmtmplt.c,v 1.1.1.1 2001/01/04 21:08:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpdm/source / VDSpdmtmplt.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSpdmtmplt.c,v $
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

#include	"VDSdberrdef.h"
#include	"VDSdbstr.h"
#include	"VDSpdminit.h"

/* local definitions */

#define	NOT !

static  int	 status; 

/* Globals for manipulating column names in attribute buffer */

extern	int	 	offsets[30];
extern	char    *attr_names[30];

extern 	struct	msg_struct   NFMmsg_ptr;
extern 	struct	msg_struct   MEMmsg_ptr;
extern 	struct	msg_struct   SQLmsg_ptr;

extern  int		VDSdebug_on;
extern	char		VDS_DEBUG_FILE[];

VDScreate_catalog_template1(user_id)
long	user_id;
{
	int		indx[12];
	int		i;
	char	        s[1024];
	char		n_seqno[20];
	char		nfm_file[120];
	char		pdm_file[120];
	char		pdm_data[120];
	char		pdm_file_f[120];
	char		pdm_data_f[120];
	char		**columns;
	MEMptr	attr_buffer = NULL;
	MEMptr	data_buffer = NULL;
	MEMptr  list_buffer = NULL;

	char		**data;
	int		seqno_col;
	int		next_seqno=1;	
	VDSdebug("ENTER:VDScreate_catalog_template1\n");
	
 /* pdm_file contains PDM req. attributes 
    nfm_file contains PDM names for NFM names */
    
    sprintf(pdm_file,"%s%s%s",VDS_DIR,DELIM,"PDMcat.pdm");
    sprintf(nfm_file,"%s%s%s",VDS_DIR,DELIM,"PDMcat.nfm");
    sprintf(pdm_data,"%s%s%s",VDS_DIR,DELIM,"PDMcat.data");
    sprintf(pdm_file_f,"%s%s%s",VDS_DIR,DELIM,"PDMfcat.pdm");
    sprintf(pdm_data_f,"%s%s%s",VDS_DIR,DELIM,"PDMfcat.data");


/*******************************************************************
                  creating catalog template
********************************************************************/

/*  First, get the NFM default catalog attributes  */
    status = NFMquery_template_information
("t_basic", "catalog", "NFM", &attr_buffer, &data_buffer, &list_buffer) ;
    if (status != NFM_S_SUCCESS)
    {
		VDSdebug("VDScreate_catalog_template1: \n");
		sprintf (s,"NFMquery_table_information failed; status = %d\n",
 		status);
		VDSdebug(s);
		status = VDS_E_FAILURE;
		MEMclose (&attr_buffer);
		return (status);
    }
    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
		VDSdebug("VDScreate_catalog_template1:\n ");
		sprintf (s,"MEMbuild_array failed; status = %d\n",status);
		VDSdebug(s);
		status = VDS_E_BUILD_ARRAY;
		MEMclose (&attr_buffer);
		return (status);
    }
    indx[0] = 0;
    indx[1] = 2;
    indx[2] = 4;
    indx[3] = 5;
    indx[4] = 6;
    indx[5] = 7;
    indx[6] = 8;
    indx[7] = 11;

  /*  Substitute PDM attribute names for NFM attribute names  */ 
    status = VDSsub_catalog_attr_names(nfm_file,indx,8,attr_buffer);
    if (status != VDS_S_SUCCESS)
    {
		VDSdebug("VDScreate_catalog_template1: \n");
		sprintf(s,"VDSsub_catalog_attribute_names failed: %d",status);
		VDSdebug(s) ;
		MEMclose (&attr_buffer);
		return (status);
    }
    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
                sprintf (s, "MEMbuild_array failed; status = %d\n", status);
                VDSdebug(s);
                status = VDS_E_BUILD_ARRAY;
                MEMclose (&attr_buffer);
                return (status);
    }

    data = (char **) attr_buffer->data_ptr;
    columns = (char **) attr_buffer->column_ptr;
    seqno_col = -1;
    for(i=0;i<attr_buffer->columns;i++) {
	if(!(strcmp(columns[i],"n_seqno"))) {
 	   seqno_col = i;
	}
    }
    if ( (seqno_col == -1) ) {
		VDSdebug("VDScreate_catalog_template1: \n");
		sprintf(s,"n_seqno not found in attr_buffer\n");
		VDSdebug(s);
		if(VDSdebug_on)
		MEMprint_buffer("attr_buffer from NFMquery_catalog_template",
		attr_buffer,VDS_DEBUG_FILE);
 		return(VDS_E_BUFFER_FORMAT);
    }

    /*
    for(i=1;i<= attr_buffer->rows;i++)
    {
        status = MEMwrite_data(attr_buffer,"0",i,i_offset+1);
        if(status != MEM_S_SUCCESS)
        {
	    	VDSdebug("VDScreate_catalog_template1:\n ");
   	    	sprintf (s, "MEMwrite_data failed : %d",status);
 	    	VDSdebug(s);
	    	status = VDS_E_WRITE_COLUMN;
	    	return (status);
        }
   }

    */

   strcpy(n_seqno, data[(attr_buffer->columns *
			(attr_buffer->rows - 1))+seqno_col]);
   sscanf(n_seqno, "%d", &next_seqno);
   ++next_seqno;
   sprintf(n_seqno, "%d", next_seqno);

   if(VDSdebug_on)
	{
		MEMprint_buffer("VDScreate_catalog_template1",attr_buffer,
		VDS_DEBUG_FILE);
		MEMprint_buffer("VDScreate_catalog_template1",data_buffer,
		VDS_DEBUG_FILE);
	}
   
    status=NFMcreate_template("t_basic", "catalog","PDM", attr_buffer,
  			data_buffer,list_buffer); 
    if (status != NFM_S_SUCCESS)
    {
		VDSdebug("VDScreate_catalog_template1: \n");
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		VDSdebug(s);
		MEMclose (&attr_buffer);
        status = VDS_E_CREATE_TEMPLATE;
		return(status);
    }
    MEMclose (&attr_buffer);
    MEMclose (&data_buffer);
    MEMclose (&list_buffer);

/* BETH 2/11/92 add the PDM required attributes to a new seperate template */
    status = NFMquery_table_template(user_id, &attr_buffer);
    if (status != NFM_S_SUCCESS)
    {
                sprintf (s, "NFMquery_table_template failed; status = %d\n", 
                status);        VDSdebug(s);
                status = VDS_E_QUERY_TABLE;
                MEMclose (&attr_buffer);
                return (status);
    }
    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
                sprintf (s, "MEMbuild_array failed; status = %d\n", status);
                VDSdebug(s);
                status = VDS_E_BUILD_ARRAY;
                MEMclose (&attr_buffer);
                return (status);
    }
    status = VDSattrfile_to_buffer(pdm_file,attr_buffer);
    if (status != VDS_S_SUCCESS)
    {
		VDSdebug("VDScreate_catalog_template1: \n");
		sprintf(s,"VDSattrfile_to_buffer failed: %d\n",status);
		MEMclose (&attr_buffer);
		return (status);
    }
    status = VDSdatafile_to_buffer(pdm_data, attr_buffer, &data_buffer);
    if (status != VDS_S_SUCCESS)
    {
                sprintf(s, "VDSattrfile_to_buffer failed: %d", status);
                VDSdebug(s);
                MEMclose (&attr_buffer);
                return (status);
    }

/* BETH 2/11/92 change the sequence numbers */
    for (i=1; i <= attr_buffer->rows; ++i)   
    {
        status = MEMwrite_data(attr_buffer,n_seqno,i,seqno_col+1);
        if(status != MEM_S_SUCCESS)
        {
	    	VDSdebug("VDScreate_catalog_template1:\n ");
   	    	sprintf (s, "MEMwrite_data failed : %d",status);
 	    	VDSdebug(s);
	    	status = VDS_E_WRITE_COLUMN;
	    	return (status);
        }

	sscanf(n_seqno, "%d", &next_seqno);
	++next_seqno;
	sprintf(n_seqno, "%d", next_seqno);
	
    }
   if(VDSdebug_on) {
		MEMprint_buffer("VDScreate_catalog_template1",attr_buffer,
		VDS_DEBUG_FILE);
		MEMprint_buffer("VDScreate_catalog_template1",data_buffer,
		VDS_DEBUG_FILE);
	}
    status=NFMcreate_template("t_appl", "catalog","PDM", attr_buffer,
  			data_buffer,NULL); 
    if (status != NFM_S_SUCCESS) {
		VDSdebug("VDScreate_catalog_template1: \n");
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		VDSdebug(s);
		MEMclose (&attr_buffer);
        status = VDS_E_CREATE_TEMPLATE;
		return(status);
    }
    MEMclose (&attr_buffer);
    MEMclose (&data_buffer);

/*******************************************************************
                  creating f_catalog template
********************************************************************/

    status = NFMquery_template_information
("t_basic", "f_catalog", "NFM", &attr_buffer, &data_buffer, &list_buffer) ;
    if (status != NFM_S_SUCCESS)
    {
		VDSdebug("VDScreate_catalog_template1: \n");
		sprintf (s,"NFMquery_table_information failed; status = %d\n",
 		status);
		VDSdebug(s);
		status = VDS_E_FAILURE;
		MEMclose (&attr_buffer);
		return (status);
    }
    columns = (char **) attr_buffer->column_ptr;

/* BETH 2/11/92 change the sequence numbers */

    for (i=1; i <= attr_buffer->rows; ++i)   
    {
        status = MEMwrite_data(attr_buffer,n_seqno,i,seqno_col+1);
        if(status != MEM_S_SUCCESS)
        {
	    	VDSdebug("VDScreate_catalog_template1:\n ");
   	    	sprintf (s, "MEMwrite_data failed : %d",status);
 	    	VDSdebug(s);
	    	status = VDS_E_WRITE_COLUMN;
	    	return (status);
        }

	sscanf(n_seqno, "%d", &next_seqno);
	++next_seqno;
	sprintf(n_seqno, "%d", next_seqno);
	
    }

   if(VDSdebug_on)
	{
		MEMprint_buffer("VDScreate_catalog_template1",attr_buffer,
		VDS_DEBUG_FILE);
		MEMprint_buffer("VDScreate_catalog_template1",data_buffer,
		VDS_DEBUG_FILE);
	}
   
/* BETH 2/10/92 END */
    status=NFMcreate_template("t_basic", "f_catalog","PDM", attr_buffer,
  			data_buffer,list_buffer); 
    if (status != NFM_S_SUCCESS)
    {
		VDSdebug("VDScreate_catalog_template1: \n");
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		VDSdebug(s);
		MEMclose (&attr_buffer);
        status = VDS_E_CREATE_TEMPLATE;
		return(status);
    }
    MEMclose (&attr_buffer);
    MEMclose (&data_buffer);
    MEMclose (&list_buffer);

/* MaC 001892 
  add the PDM required attributes to a new seperate template */

    status = NFMquery_table_template(user_id, &attr_buffer);
    if (status != NFM_S_SUCCESS) {
                sprintf (s, "NFMquery_table_template failed; status = %d\n", 
                status);        VDSdebug(s);
                status = VDS_E_QUERY_TABLE;
                MEMclose (&attr_buffer);
                return (status);
    }
    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS) {
                sprintf (s, "MEMbuild_array failed; status = %d\n", status);
                VDSdebug(s);
                status = VDS_E_BUILD_ARRAY;
                MEMclose (&attr_buffer);
                return (status);
    }
    status = VDSattrfile_to_buffer(pdm_file_f, attr_buffer);
    if (status != VDS_S_SUCCESS) {
		VDSdebug("VDScreate_catalog_template1: \n");
		sprintf(s,"VDSattrfile_to_buffer failed: %d\n",status);
		MEMclose (&attr_buffer);
		return (status);
    }
    status = VDSdatafile_to_buffer(pdm_data_f, attr_buffer, &data_buffer);
    if (status != VDS_S_SUCCESS) {
                sprintf(s, "VDSattrfile_to_buffer failed: %d", status);
                VDSdebug(s);
                MEMclose (&attr_buffer);
                return (status);
    }

/* BETH 2/11/92 change the sequence numbers */
    for (i=1; i <= attr_buffer->rows; ++i)   {
        status = MEMwrite_data(attr_buffer,n_seqno,i,seqno_col+1);
        if(status != MEM_S_SUCCESS) {
	    	VDSdebug("VDScreate_catalog_template1:\n ");
   	    	sprintf (s, "MEMwrite_data failed : %d",status);
 	    	VDSdebug(s);
	    	status = VDS_E_WRITE_COLUMN;
	    	return (status);
        }

	sscanf(n_seqno, "%d", &next_seqno);
	++next_seqno;
	sprintf(n_seqno, "%d", next_seqno);
	
    }
   if(VDSdebug_on) {
	MEMprint_buffer("VDScreate_catalog_template1 for f_catalog",attr_buffer,
	VDS_DEBUG_FILE);
	MEMprint_buffer("VDScreate_catalog_template1 for f_catalog",data_buffer,
	VDS_DEBUG_FILE);
	}
    status=NFMcreate_template("t_appl", "f_catalog","PDM", attr_buffer,
  			data_buffer,NULL); 
    if (status != NFM_S_SUCCESS) {
		VDSdebug("VDScreate_catalog_template1: \n");
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		VDSdebug(s);
		MEMclose (&attr_buffer);
        status = VDS_E_CREATE_TEMPLATE;
		return(status);
    }
    MEMclose (&attr_buffer);
    MEMclose (&data_buffer);

    return (VDS_S_SUCCESS);
}

