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
#include "PDMproto.h"

/* local definitions */

#define	NOT !

static  int	 status; 
static  char	s[1024];

/* Globals for manipulating column names in attribute buffer */

extern	int	 	offsets[30];
extern	char    *attr_names[30];

extern 	struct	msg_struct   NFMmsg_ptr;
extern 	struct	msg_struct   MEMmsg_ptr;
extern 	struct	msg_struct   SQLmsg_ptr;

extern  int		PDMdebug_on;
extern	char    PDM_DEBUG_FILE[];

PDMcreate_catalog_template1(user_id)
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


#if defined (sco)
	char		*PDM_DIR;
	char		pdm_proddir[200];
#endif

#if defined (sco)
        PDMdebug("Create SCO specific PDM_DIR");
        status = PDMget_proddir(pdm_proddir);
        if(status != PDM_S_SUCCESS)
          {
              PDMdebug("PDMget_proddir failed \n");
          }
        PDM_DIR = (char *)malloc(strlen(pdm_proddir)+1+strlen("config/initial")+
1);
        sprintf(PDM_DIR, "%s%s%s", pdm_proddir, DELIM, "config/initial");
#endif

	PDMdebug("ENTER:PDMcreate_catalog_template1\n");
	
 /* pdm_file contains PDM req. attributes 
    nfm_file contains PDM names for NFM names */
    
    sprintf(pdm_file,"%s%s%s",PDM_DIR,DELIM,"PDMcat.pdm");
    sprintf(nfm_file,"%s%s%s",PDM_DIR,DELIM,"PDMcat.nfm");
    sprintf(pdm_data,"%s%s%s",PDM_DIR,DELIM,"PDMcat.data");
    sprintf(pdm_file_f,"%s%s%s",PDM_DIR,DELIM,"PDMfcat.pdm");
    sprintf(pdm_data_f,"%s%s%s",PDM_DIR,DELIM,"PDMfcat.data");


/*******************************************************************
                  creating catalog template
********************************************************************/

/*  First, get the NFM default catalog attributes  */
    status = NFMquery_template_information
("t_basic", "catalog", "NFM", &attr_buffer, &data_buffer, &list_buffer) ;
    if (status != NFM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_catalog_template1: \n");
		sprintf (s,"NFMquery_table_information failed; status = %d\n",
 		status);
		PDMdebug(s);
		status = PDM_E_FAILURE;
		MEMclose (&attr_buffer);
		return (status);
    }
    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_catalog_template1:\n ");
		sprintf (s,"MEMbuild_array failed; status = %d\n",status);
		PDMdebug(s);
		status = PDM_E_BUILD_ARRAY;
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
    status = PDMsub_catalog_attr_names(nfm_file,indx,8,attr_buffer);
    if (status != PDM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_catalog_template1: \n");
		sprintf(s,"PDMsub_catalog_attribute_names failed: %d",status);
		PDMdebug(s) ;
		MEMclose (&attr_buffer);
		return (status);
    }
    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
                sprintf (s, "MEMbuild_array failed; status = %d\n", status);
                PDMdebug(s);
                status = PDM_E_BUILD_ARRAY;
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
		PDMdebug("PDMcreate_catalog_template1: \n");
		sprintf(s,"n_seqno not found in attr_buffer\n");
		PDMdebug(s);
		if(PDMdebug_on)
		MEMprint_buffer("attr_buffer from NFMquery_catalog_template",
		attr_buffer,PDM_DEBUG_FILE);
 		return(PDM_E_BUFFER_FORMAT);
    }

    /*
    for(i=1;i<= attr_buffer->rows;i++)
    {
        status = MEMwrite_data(attr_buffer,"0",i,i_offset+1);
        if(status != MEM_S_SUCCESS)
        {
	    	PDMdebug("PDMcreate_catalog_template1:\n ");
   	    	sprintf (s, "MEMwrite_data failed : %d",status);
 	    	PDMdebug(s);
	    	status = PDM_E_WRITE_COLUMN;
	    	return (status);
        }
   }

    */

   strcpy(n_seqno, data[(attr_buffer->columns *
			(attr_buffer->rows - 1))+seqno_col]);
   sscanf(n_seqno, "%d", &next_seqno);
   ++next_seqno;
   sprintf(n_seqno, "%d", next_seqno);

   if(PDMdebug_on)
	{
		MEMprint_buffer("PDMcreate_catalog_template1",attr_buffer,
		PDM_DEBUG_FILE);
		MEMprint_buffer("PDMcreate_catalog_template1",data_buffer,
		PDM_DEBUG_FILE);
	}
   
    status=NFMcreate_template("t_basic", "catalog","PDM", attr_buffer,
  			data_buffer,list_buffer); 
    if (status != NFM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_catalog_template1: \n");
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		PDMdebug(s);
		MEMclose (&attr_buffer);
        status = PDM_E_CREATE_TEMPLATE;
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
                status);        PDMdebug(s);
                status = PDM_E_QUERY_TABLE;
                MEMclose (&attr_buffer);
                return (status);
    }
    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
                sprintf (s, "MEMbuild_array failed; status = %d\n", status);
                PDMdebug(s);
                status = PDM_E_BUILD_ARRAY;
                MEMclose (&attr_buffer);
                return (status);
    }
    status = PDMattrfile_to_buffer(pdm_file,attr_buffer);
    if (status != PDM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_catalog_template1: \n");
		sprintf(s,"PDMattrfile_to_buffer failed: %d\n",status);
		MEMclose (&attr_buffer);
		return (status);
    }
    status = PDMdatafile_to_buffer(pdm_data, attr_buffer, &data_buffer);
    if (status != PDM_S_SUCCESS)
    {
                sprintf(s, "PDMattrfile_to_buffer failed: %d", status);
                PDMdebug(s);
                MEMclose (&attr_buffer);
                return (status);
    }

/* BETH 2/11/92 change the sequence numbers */
    for (i=1; i <= attr_buffer->rows; ++i)   
    {
        status = MEMwrite_data(attr_buffer,n_seqno,i,seqno_col+1);
        if(status != MEM_S_SUCCESS)
        {
	    	PDMdebug("PDMcreate_catalog_template1:\n ");
   	    	sprintf (s, "MEMwrite_data failed : %d",status);
 	    	PDMdebug(s);
	    	status = PDM_E_WRITE_COLUMN;
	    	return (status);
        }

	sscanf(n_seqno, "%d", &next_seqno);
	++next_seqno;
	sprintf(n_seqno, "%d", next_seqno);
	
    }
   if(PDMdebug_on) {
		MEMprint_buffer("PDMcreate_catalog_template1",attr_buffer,
		PDM_DEBUG_FILE);
		MEMprint_buffer("PDMcreate_catalog_template1",data_buffer,
		PDM_DEBUG_FILE);
	}
    status=NFMcreate_template("t_appl", "catalog","PDM", attr_buffer,
  			data_buffer,NULL); 
    if (status != NFM_S_SUCCESS) {
		PDMdebug("PDMcreate_catalog_template1: \n");
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		PDMdebug(s);
		MEMclose (&attr_buffer);
        status = PDM_E_CREATE_TEMPLATE;
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
		PDMdebug("PDMcreate_catalog_template1: \n");
		sprintf (s,"NFMquery_table_information failed; status = %d\n",
 		status);
		PDMdebug(s);
		status = PDM_E_FAILURE;
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
	    	PDMdebug("PDMcreate_catalog_template1:\n ");
   	    	sprintf (s, "MEMwrite_data failed : %d",status);
 	    	PDMdebug(s);
	    	status = PDM_E_WRITE_COLUMN;
	    	return (status);
        }

	sscanf(n_seqno, "%d", &next_seqno);
	++next_seqno;
	sprintf(n_seqno, "%d", next_seqno);
	
    }

   if(PDMdebug_on)
	{
		MEMprint_buffer("PDMcreate_catalog_template1",attr_buffer,
		PDM_DEBUG_FILE);
		MEMprint_buffer("PDMcreate_catalog_template1",data_buffer,
		PDM_DEBUG_FILE);
	}
   
/* BETH 2/10/92 END */
    status=NFMcreate_template("t_basic", "f_catalog","PDM", attr_buffer,
  			data_buffer,list_buffer); 
    if (status != NFM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_catalog_template1: \n");
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		PDMdebug(s);
		MEMclose (&attr_buffer);
        status = PDM_E_CREATE_TEMPLATE;
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
                status);        PDMdebug(s);
                status = PDM_E_QUERY_TABLE;
                MEMclose (&attr_buffer);
                return (status);
    }
    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS) {
                sprintf (s, "MEMbuild_array failed; status = %d\n", status);
                PDMdebug(s);
                status = PDM_E_BUILD_ARRAY;
                MEMclose (&attr_buffer);
                return (status);
    }
    status = PDMattrfile_to_buffer(pdm_file_f, attr_buffer);
    if (status != PDM_S_SUCCESS) {
		PDMdebug("PDMcreate_catalog_template1: \n");
		sprintf(s,"PDMattrfile_to_buffer failed: %d\n",status);
		MEMclose (&attr_buffer);
		return (status);
    }
    status = PDMdatafile_to_buffer(pdm_data_f, attr_buffer, &data_buffer);
    if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMattrfile_to_buffer failed: %d", status);
                PDMdebug(s);
                MEMclose (&attr_buffer);
                return (status);
    }

/* BETH 2/11/92 change the sequence numbers */
    for (i=1; i <= attr_buffer->rows; ++i)   {
        status = MEMwrite_data(attr_buffer,n_seqno,i,seqno_col+1);
        if(status != MEM_S_SUCCESS) {
	    	PDMdebug("PDMcreate_catalog_template1:\n ");
   	    	sprintf (s, "MEMwrite_data failed : %d",status);
 	    	PDMdebug(s);
	    	status = PDM_E_WRITE_COLUMN;
	    	return (status);
        }

	sscanf(n_seqno, "%d", &next_seqno);
	++next_seqno;
	sprintf(n_seqno, "%d", next_seqno);
	
    }
   if(PDMdebug_on) {
	MEMprint_buffer("PDMcreate_catalog_template1 for f_catalog",attr_buffer,
	PDM_DEBUG_FILE);
	MEMprint_buffer("PDMcreate_catalog_template1 for f_catalog",data_buffer,
	PDM_DEBUG_FILE);
	}
    status=NFMcreate_template("t_appl", "f_catalog","PDM", attr_buffer,
  			data_buffer,NULL); 
    if (status != NFM_S_SUCCESS) {
		PDMdebug("PDMcreate_catalog_template1: \n");
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		PDMdebug(s);
		MEMclose (&attr_buffer);
        status = PDM_E_CREATE_TEMPLATE;
		return(status);
    }
    MEMclose (&attr_buffer);
    MEMclose (&data_buffer);

    return (PDM_S_SUCCESS);
  }

PDMcreate_catalog_template2(user_id)
long	user_id;
{
	int		indx[12];
	int		i;
	int		i_offset;
	char	        s[1024];
	char		n_seqno[20];
	char		nfm_file[120];
	char		pdm_file[120];
	char		**columns;

	MEMptr	attr_buffer = NULL;
	MEMptr	data_buffer = NULL;
	MEMptr	data1_buffer = NULL;
	MEMptr  list_buffer = NULL;

#if defined (sco)
	char		*PDM_DIR;
	char		pdm_proddir[200];
#endif

#if defined (sco)
        PDMdebug("Create SCO specific PDM_DIR");
        status = PDMget_proddir(pdm_proddir);
        if(status != PDM_S_SUCCESS)
          {
              PDMdebug("PDMget_proddir failed \n");
          }
        PDM_DIR = (char *)malloc(strlen(pdm_proddir)+1+strlen("config/initial")+
1);
        sprintf(PDM_DIR, "%s%s%s", pdm_proddir, DELIM, "config/initial");
#endif

	PDMdebug("ENTER:PDMcreate_catalog_template2\n");
/* ANSI */
user_id = 0;
	
 /* pdm_file contains PDM req. attributes 
    nfm_file contains PDM names for NFM names */
    
    sprintf(pdm_file,"%s%s%s",PDM_DIR,DELIM,"PDMcat.pdm");
    sprintf(nfm_file,"%s%s%s",PDM_DIR,DELIM,"PDMcat.nfm");

/*  First, get the NFM default catalog attributes  */
/*
    status = NFMquery_catalog_template 
      (user_id,&attr_buffer,&data_buffer,&list_buffer);
*/
    status = NFMquery_template_attributes
("t_basic", "catalog", "NFM", &attr_buffer,&data_buffer,&list_buffer);
    if (status != NFM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_catalog_template2: \n");
		sprintf (s,"NFMquery_catalog_template failed; status = %d\n",
 		status);
		PDMdebug(s);
		status = PDM_E_QUERY_CATALOG_TEMPLATE;
		MEMclose (&attr_buffer);
		return (status);
    }
    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_catalog_template2:\n ");
		sprintf (s,"MEMbuild_array failed; status = %d\n",status);
		PDMdebug(s);
		status = PDM_E_BUILD_ARRAY;
		MEMclose (&attr_buffer);
		return (status);
    }
    indx[0] = 0;
    indx[1] = 0;
    indx[2] = 2;
    indx[3] = 6;
    indx[4] = 7;
    indx[5] = 8;
    indx[6] = 9;
    indx[7] = 10;
    indx[8] = 14;
    indx[9] = 11;

  /*  Substitute PDM attribute names for NFM attribute names  */

    status = PDMsub_catalog_attr_names
					(nfm_file,indx,8,attr_buffer);
    if (status != PDM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_catalog_template2: \n");
		sprintf(s,"PDMsub_catalog_attribute_names failed: %d",status);
		MEMclose (&attr_buffer);
		return (status);
    }

 /*  Next, add PDM required catalog attributes not present in NFM  */

    status = PDMattrfile_to_buffer(pdm_file,attr_buffer);
    if (status != PDM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_catalog_template2: \n");
		sprintf(s,"PDMattrfile_to_buffer failed: %d\n",status);
		MEMclose (&attr_buffer);
		return (status);
    }

 /* since there are pdm attributes in attr_buffer. expand 
    the data_buffer for these new attributes */

    status = PDMiexpand_databuffer
				(attr_buffer,data_buffer,&data1_buffer);
    if (status != PDM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_catalog_template2: \n");
		sprintf(s,"PDMiexpand_databufr failed: %d\n",status);
		MEMclose (&attr_buffer);
		return (status);
    }

 /* before creating template need to sequentialize n_seqno 
    since there are duplicates */

    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_catalog_template2:\n ");
		sprintf (s,"MEMbuild_array failed; status = %d\n",status);
		PDMdebug(s);
		status = PDM_E_BUILD_ARRAY;
		MEMclose (&attr_buffer);
		return (status);
    }
    columns = (char **) attr_buffer->column_ptr;
    i_offset = -1;
    for(i=0;i<attr_buffer->columns;i++)
    {
		if(!(strcmp(columns[i],"n_seqno")))
		{
	 	   i_offset = i;
	  	   break;
		}
    }
    if(i_offset == -1)
    {
		PDMdebug("PDMcreate_catalog_template2: \n");
		sprintf(s,"n_seqno not found in attr_buffer\n");
		PDMdebug(s);
		if(PDMdebug_on)
		MEMprint_buffer("attr_buffer from NFMquery_catalog_template",
		attr_buffer,PDM_DEBUG_FILE);
 		return(PDM_E_BUFFER_FORMAT);
    }

    for(i=1;i<= attr_buffer->rows;i++)
    {
		strcpy(n_seqno,"");
		sprintf(n_seqno,"%d",i);
        status = MEMwrite_data(attr_buffer,n_seqno,i,i_offset+1);
        if(status != MEM_S_SUCCESS)
        {
	    	PDMdebug("PDMcreate_catalog_template2:\n ");
   	    	sprintf (s, "MEMwrite_data failed : %d",status);
 	    	PDMdebug(s);
	    	status = PDM_E_WRITE_COLUMN;
	    	return (status);
        }
   }

 /*  Now, load them into NFM  */
/*
    status=NFMcreate_template(user_id,"pdmcatalog","catalog",attr_buffer,
  			data1_buffer,list_buffer); 
*/
    status=NFMcreate_template("t_appltable", "d_template", "PDM0", attr_buffer,
  			data1_buffer,list_buffer); 
    if (status != NFM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_catalog_template2: \n");
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		PDMdebug(s);
		MEMclose (&attr_buffer);
        status = PDM_E_CREATE_TEMPLATE;
		return(status);
    }
    MEMclose (&attr_buffer);
    MEMclose (&data_buffer);
    MEMclose (&list_buffer);
	PDMdebug("EXIT:PDMcreate_catalog_template2\n");
    return (PDM_S_SUCCESS);
  }

int PDMcreate_required_template(user_id,template_id)
long	user_id;
int		template_id;
{
	char	    s[1024];
	char    	attr_file[120];
	char    	data_file[120];
	char    	list_file[120];
	char		template[40];
	char            table_name [40] ;
	char            identifier [40] ;

#if defined (sco)
	char		*PDM_DIR;
	char		pdm_proddir[200];
#endif

#if defined (sco)
        PDMdebug("Create SCO specific PDM_DIR");
        status = PDMget_proddir(pdm_proddir);
        if(status != PDM_S_SUCCESS)
          {
              PDMdebug("PDMget_proddir failed \n");
          }
        PDM_DIR = (char *)malloc(strlen(pdm_proddir)+1+strlen("config/initial")+
1);
        sprintf(PDM_DIR, "%s%s%s", pdm_proddir, DELIM, "config/initial");
#endif

	PDMdebug("ENTER:PDMcreate_required_template\n");

   switch (template_id)
   {
	case PDM_BOM:
 	    sprintf(attr_file,"%s%s%s",PDM_DIR,DELIM,"PDMbom.attr");
	    sprintf(data_file,"%s%s%s",PDM_DIR,DELIM,"PDMbom.data");
	    strcpy (identifier, "BOM") ;
	    list_file[0] = '\0';
	    strcpy(template,"pdmbomcontent");
	    strcpy (table_name, "bom_template") ;
	    break;
	case PDM_VIEW:
 	    sprintf(attr_file,"%s%s%s",PDM_DIR,DELIM,"PDMviews.attr");
	    sprintf(data_file,"%s%s%s",PDM_DIR,DELIM,"PDMviews.data");
		list_file[0] = '\0';
	    strcpy(template,"pdmviews");
	    strcpy (identifier, "PDM") ;
	    strcpy (table_name, "v_template") ;
		break;
	default:
		sprintf(s,"Unknown Template ID \n");
		PDMdebug(s);
		break;
    }
    status = PDMcreate_template(user_id,attr_file,data_file,
				list_file,template,
				table_name, identifier);

	if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMcreate_template failed status %d\n",
		status); PDMdebug(s);
		return(status);
	}
	PDMdebug("EXIT:PDMcreate_required_templates\n");
	return(PDM_S_SUCCESS);
}

int PDMcreate_template(user_id,attr_file,data_file,
			list_file,template, table_name, identifier)
long	user_id;
char	*attr_file;
char	*data_file;
char	*list_file;
char	*template;
char    *table_name;
char    *identifier ;
{
	MEMptr	    attr_buffer = NULL;
	MEMptr	    data_buffer = NULL;

	PDMdebug("ENTER:PDMcreate_template\n");
/* ANSI */
list_file = NULL;
template = NULL;

 /*  First, get the NFM default catalog attributes  */

    status = NFMquery_table_template(user_id,&attr_buffer);
    if (status != NFM_S_SUCCESS)
    {
		sprintf (s,"NFMquery_table_template failed; status = %d\n",
		status);	PDMdebug(s);
		status = PDM_E_QUERY_TABLE;
		MEMclose (&attr_buffer);
		return (status);
    }
    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
		sprintf (s,"MEMbuild_array failed; status = %d\n",status);
		PDMdebug(s);
		status = PDM_E_BUILD_ARRAY;
		MEMclose (&attr_buffer);
		return (status);
    }
    status = PDMattrfile_to_buffer(attr_file,attr_buffer);
    if (status != PDM_S_SUCCESS)
    {
		sprintf(s,"PDMattrfile_to_buffer failed: %d",status);
		MEMclose (&attr_buffer);
		return (status);
    }
    status = PDMdatafile_to_buffer(data_file,attr_buffer,&data_buffer);
    if (status != PDM_S_SUCCESS)
    {
		sprintf(s,"PDMattrfile_to_buffer failed: %d",status);
		PDMdebug(s);
		MEMclose (&attr_buffer);
		return (status);
    }
	if(PDMdebug_on)
	{
		MEMprint_buffer("PDMcreate_template",attr_buffer,
		PDM_DEBUG_FILE);
		MEMprint_buffer("PDMcreate_template",data_buffer,
		PDM_DEBUG_FILE);
	}
    /*  Now, load them into NFM  */

/*    status=NFMcreate_template(template,template, "PDM",
			      attr_buffer,data_buffer,NULL); */
    status=NFMcreate_template("t_appltable", table_name, identifier,
			      attr_buffer,data_buffer,NULL);
    if (status != NFM_S_SUCCESS)
    {
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		PDMdebug(s);
		MEMclose (&attr_buffer); MEMclose(&data_buffer);
		status = PDM_E_CREATE_TEMPLATE;
		return(status);
    }
    MEMclose (&attr_buffer);
    MEMclose (&data_buffer);
	PDMdebug("EXIT:PDMcreate_template\n");
    return (PDM_S_SUCCESS);
  }

 long PDMload_acl (user_id, user_name, wf_name, acl_name)
   long     user_id;
   char     *user_name;
   char     *wf_name, *acl_name;
   {
     long    status;
     MEMptr  attr_list = NULL, data_list = NULL, value_list = NULL;


     PDMdebug ("        ADD ACL \n");       

     status = WFquery_acl_attributes (user_id,
              &attr_list, &data_list, &value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list); 
        MEMclose (&data_list);
        MEMclose (&value_list);
        _NFM_num ("ITEM WF : Qry Acl Attr : status = <0x%.8x>\n", status);
        return (status);
      }

     status = WFset_acl (user_id, wf_name, acl_name,
              attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list); MEMclose (&data_list);
        _NFM_num ("ITEM WF : Set Acl : status = <0x%.8x>\n", status);
        return (status);
      }
        
     status = WFadd_acl (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list); MEMclose (&data_list);
        _NFM_num ("ITEM WF : Enter Acl : status = <0x%.8x>\n", status);
        return (status);
      }

     MEMclose (&attr_list);   
     MEMclose (&data_list); 
     MEMclose (&value_list);

     PDMdebug ("        ADD ACL SUCCESSFUL%s\n");       

     status = WFquery_acl_class_users (user_id, acl_name,
              &attr_list, &data_list, &value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list); 
        MEMclose (&data_list);
        MEMclose (&value_list);
        _NFM_num ("ITEM WF : Qry Acl Users : status = <0x%.8x>\n", status);
        return (status);
      }
     
     status = WFset_acl_class_users (user_id, wf_name, user_name,
              attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list); MEMclose (&data_list);
        _NFM_num ("ITEM WF : Set Acl Class Users : status = <0x%.8x>\n",
        status);
        return (status);
      }

     status = WFupdate_acl_class_users (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list); 
        MEMclose (&data_list);
        MEMclose (&value_list);
        _NFM_num ("ITEM WF : Upd Acl Users : status = <0x%.8x>\n", status);
        return (status);
      }

     MEMclose (&attr_list); 
     MEMclose (&data_list); 
     MEMclose (&value_list);

     PDMdebug ("        ADD ACL CLASS USERS SUCCESSFUL%s\n");       

     status = WFquery_acl_signoff_users (user_id, acl_name,
              &attr_list, &data_list, &value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list); 
        MEMclose (&data_list); 
        MEMclose (&value_list);
        _NFM_num ("ITEM WF : Qry Acl Signoff Users : status = <0x%.8x>\n",
        status);
        return (status);
      }
     
     status = WFset_acl_signoff_users (user_id, wf_name, user_name,
              attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list); MEMclose (&data_list);
        _NFM_num ("ITEM WF : Set Acl SignOff Users : status = <0x%.8x>\n", 
        status);
        return (status);
      }

     status = WFupdate_acl_signoff_users (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list); 
        MEMclose (&data_list); 
        MEMclose (&value_list);
        _NFM_num ("ITEM WF : Upd Acl Signoff Users : status = <0x%.8x>\n",
        status);
        return (status);
      }
 
     MEMclose (&attr_list);
     MEMclose (&data_list);
     MEMclose (&value_list);

     PDMdebug ("        ADD ACL SIGNOFF USERS SUCCESSFUL%s\n");

     _NFM_num ("LOAD ACL : SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
     return (NFM_S_SUCCESS);
   }

PDMcreate_drawing_template(user_id)
long	user_id;
{
	int		indx[12];
	int		i;
	int		i_offset;
	char	        s[1024];
	char		n_seqno[20];
	char		pdm_f_file[120];
	char		pdm_f_data[120];
	char		pdm_file[120];
	char		**columns;

	MEMptr	attr_buffer = NULL;
	MEMptr	data_buffer = NULL;
	MEMptr	data1_buffer = NULL;
	MEMptr  list_buffer = NULL;

#if defined (sco)
	char		*PDM_DIR;
	char		pdm_proddir[200];
#endif

#if defined (sco)
        PDMdebug("Create SCO specific PDM_DIR");
        status = PDMget_proddir(pdm_proddir);
        if(status != PDM_S_SUCCESS)
          {
              PDMdebug("PDMget_proddir failed \n");
          }
        PDM_DIR = (char *)malloc(strlen(pdm_proddir)+1+strlen("config/initial")+
1);
        sprintf(PDM_DIR, "%s%s%s", pdm_proddir, DELIM, "config/initial");
#endif

	PDMdebug("ENTER:PDMcreate_drawing_template\n");
	
 /* pdm_file contains PDM req. attributes 
    nfm_file contains PDM names for NFM names */
    
    sprintf(pdm_file,"%s%s%s",PDM_DIR,DELIM,"PDMdwg.attr");
    sprintf(pdm_f_file,"%s%s%s",PDM_DIR,DELIM,"PDMdwg_f.attr");
    sprintf(pdm_f_data,"%s%s%s",PDM_DIR,DELIM,"PDMdwg_f.data");

/*  First, get the NFM default catalog attributes  */
    status = NFMquery_template_information
("t_basic", "catalog", "PDM", &attr_buffer, &data_buffer, &list_buffer) ;
    if (status != NFM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template: \n");
		sprintf (s,"NFMquery_table_information failed; status = %d\n",
 		status);
		PDMdebug(s);
		status = PDM_E_FAILURE;
		MEMclose (&attr_buffer);
		return (status);
    }

   status=NFMcreate_template("t_basic", "catalog","PDMDWG", attr_buffer,
  			data_buffer,list_buffer); 
    if (status != NFM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template: \n");
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		PDMdebug(s);
		MEMclose (&attr_buffer);
        status = PDM_E_CREATE_TEMPLATE;
		return(status);
    }
    MEMclose (&attr_buffer); attr_buffer = NULL;
    MEMclose (&data_buffer); data_buffer = NULL;
    MEMclose (&list_buffer); list_buffer = NULL;

    status = NFMquery_template_information
    ("t_appl", "catalog", "PDM", &attr_buffer, &data_buffer, &list_buffer) ;
    if (status != NFM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template: \n");
		sprintf (s,"NFMquery_table_information failed; status = %d\n",
 		status);
		PDMdebug(s);
		status = PDM_E_FAILURE;
		MEMclose (&attr_buffer);
		return (status);
    }

    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template:\n ");
		sprintf (s,"MEMbuild_array failed; status = %d\n",status);
		PDMdebug(s);
		status = PDM_E_BUILD_ARRAY;
		MEMclose (&attr_buffer);
		return (status);
    }
    indx[0] = 0;
    indx[1] = 0;
    indx[2] = 2;
    indx[3] = 6;
    indx[4] = 7;
    indx[5] = 8;
    indx[6] = 9;
    indx[7] = 10;
    indx[8] = 14;
    indx[9] = 11;


 /*  Next, add PDM required catalog attributes not present in NFM  */ 

    status = PDMattrfile_to_buffer(pdm_file,attr_buffer);
    if (status != PDM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template: \n");
		sprintf(s,"PDMattrfile_to_buffer failed: %d\n",status);
		MEMclose (&attr_buffer);
		return (status);
    }

 /* since there are pdm attributes in attr_buffer. expand 
    the data_buffer for these new attributes */ 

    status = PDMiexpand_databuffer
				(attr_buffer,data_buffer,&data1_buffer);
    if (status != PDM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template: \n");
		sprintf(s,"PDMiexpand_databufr failed: %d\n",status);
		MEMclose (&attr_buffer);
		return (status);

    }
 /* before creating template need to sequentialize n_seqno 
    since there are duplicates */ 

    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template:\n ");
		sprintf (s,"MEMbuild_array failed; status = %d\n",status);
		PDMdebug(s);
		status = PDM_E_BUILD_ARRAY;
		MEMclose (&attr_buffer);
		return (status);
    }
    columns = (char **) attr_buffer->column_ptr;
    i_offset = -1;
    for(i=0;i<attr_buffer->columns;i++)
    {
		if(!(strcmp(columns[i],"n_seqno")))
		{
	 	   i_offset = i;
	  	   break;
		}
    }
    if(i_offset == -1)
    {
		PDMdebug("PDMcreate_drawing_template: \n");
		sprintf(s,"n_seqno not found in attr_buffer\n");
		PDMdebug(s);
		if(PDMdebug_on)
		MEMprint_buffer("attr_buffer from NFMquery_catalog_template",
		attr_buffer,PDM_DEBUG_FILE);
 		return(PDM_E_BUFFER_FORMAT);
    }

    for(i=1;i<= attr_buffer->rows;i++)
    {
		strcpy(n_seqno,"");
		sprintf(n_seqno,"%d",i);
        status = MEMwrite_data(attr_buffer,n_seqno,i,i_offset+1);
        if(status != MEM_S_SUCCESS)
        {
	    	PDMdebug("PDMcreate_drawing_template:\n ");
   	    	sprintf (s, "MEMwrite_data failed : %d",status);
 	    	PDMdebug(s);
	    	status = PDM_E_WRITE_COLUMN;
	    	return (status);
        }
   }
  /*  Now, load them into NFM  */
/*
    status=NFMcreate_template(user_id,"pdmcatalog0","catalog",attr_buffer,
  			data1_buffer,list_buffer); */

   status=NFMcreate_template("t_appl", "catalog","PDMDWG", attr_buffer,
  			data1_buffer,list_buffer); 
    if (status != NFM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template: \n");
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		PDMdebug(s);
		MEMclose (&attr_buffer);
        status = PDM_E_CREATE_TEMPLATE;
		return(status);
    }
    MEMclose (&attr_buffer); attr_buffer = NULL;
    MEMclose (&data_buffer); data_buffer = NULL;
    MEMclose (&data1_buffer); data1_buffer = NULL;
    MEMclose (&list_buffer); list_buffer = NULL;

    status = NFMquery_template_information
("t_basic", "f_catalog", "PDM", &attr_buffer, &data_buffer, &list_buffer) ;
    if (status != NFM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template: \n");
		sprintf (s,"NFMquery_table_information failed; status = %d\n",
 		status);
		PDMdebug(s);
		status = PDM_E_FAILURE;
		MEMclose (&attr_buffer);
		return (status);
    }

   status=NFMcreate_template("t_basic", "f_catalog","PDMDWG", attr_buffer,
  			data_buffer,list_buffer); 
    if (status != NFM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template: \n");
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		PDMdebug(s);
		MEMclose (&attr_buffer);
        status = PDM_E_CREATE_TEMPLATE;
		return(status);
    }
    MEMclose (&attr_buffer); attr_buffer = NULL;
    MEMclose (&data_buffer); data_buffer = NULL;
    MEMclose (&list_buffer); list_buffer = NULL;

    status = NFMquery_table_template(user_id, &attr_buffer);
    if (status != NFM_S_SUCCESS)
    {
                sprintf (s, "NFMquery_table_template failed; status = %d\n", 
                status);        PDMdebug(s);
                status = PDM_E_QUERY_TABLE;
                MEMclose (&attr_buffer);
                return (status);
    }

    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template:\n ");
		sprintf (s,"MEMbuild_array failed; status = %d\n",status);
		PDMdebug(s);
		status = PDM_E_BUILD_ARRAY;
		MEMclose (&attr_buffer);
		return (status);
    }
    indx[0] = 0;
    indx[1] = 0;
    indx[2] = 2;
    indx[3] = 6;
    indx[4] = 7;
    indx[5] = 8;
    indx[6] = 9;
    indx[7] = 10;
    indx[8] = 14;
    indx[9] = 11;


 /*  Next, add PDM required catalog attributes not present in NFM  */ 

    status = PDMattrfile_to_buffer(pdm_f_file,attr_buffer);
    if (status != PDM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template: \n");
		sprintf(s,"PDMattrfile_to_buffer failed: %d\n",status);
		MEMclose (&attr_buffer);
		return (status);
    }

    status = PDMdatafile_to_buffer(pdm_f_data, attr_buffer,&data_buffer);
    if (status != PDM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template: \n");
		sprintf(s,"PDMdatafile_to_buffer failed: %d\n",status);
		MEMclose (&attr_buffer);
		return (status);

    }
 /* before creating template need to sequentialize n_seqno 
    since there are duplicates */ 

    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template:\n ");
		sprintf (s,"MEMbuild_array failed; status = %d\n",status);
		PDMdebug(s);
		status = PDM_E_BUILD_ARRAY;
		MEMclose (&attr_buffer);
		return (status);
    }
    columns = (char **) attr_buffer->column_ptr;
    i_offset = -1;
    for(i=0;i<attr_buffer->columns;i++)
    {
		if(!(strcmp(columns[i],"n_seqno")))
		{
	 	   i_offset = i;
	  	   break;
		}
    }
    if(i_offset == -1)
    {
		PDMdebug("PDMcreate_drawing_template: \n");
		sprintf(s,"n_seqno not found in attr_buffer\n");
		PDMdebug(s);
		if(PDMdebug_on)
		MEMprint_buffer("attr_buffer from NFMquery_catalog_template",
		attr_buffer,PDM_DEBUG_FILE);
 		return(PDM_E_BUFFER_FORMAT);
    }

    for(i=1;i<= attr_buffer->rows;i++)
    {
		strcpy(n_seqno,"");
		sprintf(n_seqno,"%d",i);
        status = MEMwrite_data(attr_buffer,n_seqno,i,i_offset+1);
        if(status != MEM_S_SUCCESS)
        {
	    	PDMdebug("PDMcreate_drawing_template:\n ");
   	    	sprintf (s, "MEMwrite_data failed : %d",status);
 	    	PDMdebug(s);
	    	status = PDM_E_WRITE_COLUMN;
	    	return (status);
        }
   }
  /*  Now, load them into NFM  */

    status=NFMcreate_template("t_appl", "f_catalog","PDMDWG", attr_buffer,
  			data_buffer,NULL); 
    if (status != NFM_S_SUCCESS)
    {
		PDMdebug("PDMcreate_drawing_template: \n");
		sprintf(s,"NFMcreate_template failed status = %d\n",status);
		PDMdebug(s);
		MEMclose (&attr_buffer);
        status = PDM_E_CREATE_TEMPLATE;
		return(status);
    }
    MEMclose (&attr_buffer);
    MEMclose (&data_buffer);

    return (PDM_S_SUCCESS);
  }
