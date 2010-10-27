/* $Id: VDSpdmfile.c,v 1.1.1.1 2001/01/04 21:08:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpdm/source / VDSpdmfile.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSpdmfile.c,v $
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
#include	"VDSpdminit.h"

/* local definitions */

#define	NOT !

/* Globals for manipulating column names in attribute buffer */

static  char	s[1024];
static  int		status;

extern 	struct	msg_struct   NFMmsg_ptr;
extern 	struct	msg_struct   MEMmsg_ptr;
extern 	struct	msg_struct   SQLmsg_ptr;

extern  int		VDSdebug_on;
extern	char		VDS_DEBUG_FILE[];

/* This function reads filename (.attr type) and writes the data into 
   buffer (attribute buffer of nfmattributes sys). The  attrbs 
   that make up the fields of a row are dynamic. indx is an array into
   global var. attr_names and no_fileds is the no. of. fields per row */

VDSattrfile_to_buffer (filename,buffer)
  char		*filename;
  MEMptr	buffer;
  {
	int		no_fields;
	int		found;
	int		i, k;
	int		nx1;
	char	**column;
	char	ss[1024], sz[1024],buffer_string[4096];
	char    *fields[16];
	char    *field_names[16];
	FILE	*infile, *fopen ();

  /*  Open the attr file  */

   VDSdebug("ENTER:VDSattrfile_to_buffer\n");
   infile = NULL;
   if ((infile = fopen (filename, "r")) == NULL)
   {
		sprintf (s, "Could not open file <%s> \n",filename);
		VDSdebug(s);
		status = VDS_E_OPEN_FILE;
		return (status);
   }
   if(VDSdebug_on)
   {
   		MEMprint_buffer("empty buffer",buffer,VDS_DEBUG_FILE);
   }
   status = MEMbuild_array(buffer);
   if(status != MEM_S_SUCCESS)
   {
		sprintf (s, "MEMbuild_array failed : %d",status);
		VDSdebug(s);
		status = VDS_E_BUILD_ARRAY;
		return (status);
   }
   column = (char **) buffer->column_ptr;

 /* read the file until no more data . there are "no_fields" fields
    in each row in this type of files */

   fgets (sz, 1024, infile);
   while((sz[0] == '#') || (sz[0] == '\n')) 
   {
	   fgets (sz, 1024, infile);
   }
   if ((field_names[0] = strtok (sz, "|")) == NULL)
   {
   		VDSdebug("File in unrecognized format\n");
   		status = VDS_E_FILE_FORMAT;
   		fclose (infile);
   		return (status);
   }

   no_fields = 1;
   while((field_names[no_fields] = strtok (NULL, "|\n")) != NULL)
   {
		no_fields  = no_fields + 1 ;
   }

/*  for(i=0;i<no_fields;i++)
   {
		sprintf(s,"%d -> %s\n",i,field_names[i]);
		VDSdebug(s);
   }
*/
  
   /* Check if the field names tally with 
		NFM columns in buffer */

   for(i=0;i<no_fields;i++)
   {
		found = 0;
		for(k=0;k<buffer->columns;k++)
		{
			if(!strcmp(column[k],field_names[i]))
			{
				found = 1; break;
			}
		}	
		if(!found)
		{
			sprintf(s,
            "Field Name -> %s in File -> %s is Illegal\n",
			field_names[i],filename);	VDSdebug(s);
	   		status = VDS_E_FILE_FORMAT;
	   		fclose (infile);
	   		return (status);			
		}	
   }

   while (fgets (ss, 1024, infile))
   {
		/*  Check for comment in file  */

     if ((ss[0] == '#') || (ss[0] == '\n')) continue;

     if ((fields[0] = strtok (ss, "|")) == NULL)
     {
	   		VDSdebug("File in unrecognized format\n");
	   		status = VDS_E_FILE_FORMAT;
	   		fclose (infile);
	   		return (status);
     }

     for(i=1;i<no_fields-1;i++)
     {
		if ((fields[i] = strtok (NULL, "|")) == NULL)
		{
  	  		VDSdebug("File in unrecognized format\n");
  	  		status = VDS_E_FILE_FORMAT;
   	  		fclose (infile);
   	  		return (status);
        }
     }
     if ((fields[no_fields-1] = strtok (NULL, "|\n")) == NULL)
     {
			VDSdebug("File in unrecognized format\n");
			status = VDS_E_FILE_FORMAT;
			fclose (infile);
			return (status);
     }

/*   for(i=0;i<no_fields;i++)
   {
		sprintf(s,"%d -> %s\n",i,fields[i]);
		VDSdebug(s);
   }
*/
            /* write a row in buffer  */

     strcpy (buffer_string, "");

     for (i = 0; i < buffer->columns; ++i)
     {
	       /* locate which field in file corresponds to column[i] */

	    nx1 = -1;
        for(k=0;k<no_fields;k++)
        {
		   if(!strcmp(column[i],field_names[k]))
           {
 	 	       nx1 = k;
	 	       break;
           }
        }
        if(nx1 != -1)
        {
           strcat (buffer_string, fields[nx1]);
        }
		strcat(buffer_string,"\1");
     }
     status = MEMwrite (buffer, buffer_string);
     if (status != MEM_S_SUCCESS)
     {
		VDSdebug("VDSattrfile_to_buffer \n");
		sprintf(s,"MEMwrite failed status = %d\n",status);
		VDSdebug(s);
		fclose (infile);
		status = VDS_E_WRITE_ROW;
		return (status);
     }
     status = MEMbuild_array (buffer);
     if (status  != MEM_S_SUCCESS)
     {
		VDSdebug("VDSattrfile_to_buffer \n");
		sprintf(s,"MEMbuild_array failed status = %d\n",status);
		VDSdebug(s);
		fclose (infile);
		return (VDS_E_BUILD_ARRAY);
     }
     column = (char **) buffer->column_ptr;
   }   /* end of while */

   if(VDSdebug_on)
   {
   		MEMprint_buffer("buffer",buffer,VDS_DEBUG_FILE);
   }
  fclose (infile);
  VDSdebug("EXIT:VDSattrfile_to_buffer\n");
  return (VDS_S_SUCCESS);
}

/* attr_buffer is used to create data_buffer. each attr_name and datatype
   columns in attr_buffer makeup the data_buffer format. 
   entries in filename is of fixed format. */

VDSdatafile_to_buffer (filename,attr_buffer,data_buffer)
  MEMptr	attr_buffer;
  char		*filename;
  MEMptr	*data_buffer;
  {
	FILE	*infile, *fopen ();
	int		i, j;
    int     nx1, nx2;
	int		rows,cols;
	int     name_offset, dtype_offset;
	char	ss[1024], s[1024] ;
	char    *init_val, *def_val;
	char	**data,**column;
 	char	dummy_row[1024];
	char	*attrname;
	MEMptr	tmp_bufr = NULL;

/*  Open the .data file  */

   VDSdebug("ENTER:VDSdatafile_to_buffer\n");
   if ((infile = fopen (filename, "r")) == NULL)
   {
		sprintf(s,"VDSdatafile_to_buffer: \n");
		VDSdebug(s);
		sprintf (s, "Could not open file <%s> \n",filename);
		VDSdebug(s);
		status = VDS_E_OPEN_FILE;
		return (status);
   }

/* create data_buffer  */

   status = MEMbuild_array(attr_buffer);
   if(status != MEM_S_SUCCESS)
   {
		VDSdebug("VDSdatafile_to_buffer \n");
		sprintf(s,"MEMbuild_array failed status = %d",status);
		VDSdebug(s);
		fclose (infile);
		status = VDS_E_BUILD_ARRAY;
		return (status);
   }
   rows = attr_buffer->rows;
   cols = attr_buffer->columns;
   data = (char **)attr_buffer->data_ptr;
   column = (char **)attr_buffer->column_ptr;
   name_offset = -1;
   dtype_offset = -1;

/* find offsets of n_name and n_datatype in the attr_buffer */

   for(i=0;i<cols;i++)
   {
       if(!strcmp(column[i],"n_name"))
       {
		   name_offset = i;
       }
       if(!strcmp(column[i],"n_datatype"))
       {
		   dtype_offset = i;
       }
       if(name_offset != -1 && dtype_offset != -1)
	   break;
   }
   if(name_offset == -1 || dtype_offset == -1)
   {
       VDSdebug("VDSdatafile_to_buffer \n");
       VDSdebug("Input buffer format is invalid\n");
       status = VDS_E_BUFFER_FORMAT;
       return(status);
   }
   status = MEMopen(&tmp_bufr,2048);
   if(status != MEM_S_SUCCESS)
   {
		VDSdebug("VDSdatafile_to_buffer \n");
		sprintf(s,"MEMopen failed status = %d",status);
		VDSdebug(s);
		fclose (infile);
		status = VDS_E_OPEN_BUFFER;
		return (status);
   }
   for(i=0;i<rows;i++)
   {
       nx1 = i * cols + name_offset;
       nx2 = i * cols + dtype_offset;
       status = MEMwrite_format(tmp_bufr,data[nx1],data[nx2]);
       if(status != MEM_S_SUCCESS)
       {
 	  		VDSdebug("VDSdatafile_to_buffer \n");
 	  		sprintf(s,"MEMwrite_format failed status = %d",status);
	  		VDSdebug(s);
   	  		fclose (infile);
          	MEMclose(&tmp_bufr);
   	  		status = VDS_E_WRITE_FORMAT;
          	return (status);
       }
   }
    strcpy(dummy_row,"");
    for(i=0;i<rows;i++)
    {
		strcat(dummy_row,"\1");
    }   
    status = MEMwrite(tmp_bufr,dummy_row);
    if(status != MEM_S_SUCCESS)
    {
		VDSdebug("VDSdatafile_to_buffer \n");
		sprintf(s,"MEMwrite failed status = %d",status);
		VDSdebug(s);
        MEMclose(&tmp_bufr);
		fclose (infile);
		status = VDS_E_WRITE_ROW;
		return (status);
    }
    status = MEMwrite(tmp_bufr,dummy_row);
    if(status != MEM_S_SUCCESS)
    {
		VDSdebug("VDSdatafile_to_buffer \n");
		sprintf(s,"MEMwrite failed status = %d",status);
		VDSdebug(s);
        MEMclose(&tmp_bufr);
		fclose (infile);
		status = VDS_E_WRITE_ROW;
		return (status);
    }
    status = MEMbuild_array(tmp_bufr);
    if(status != MEM_S_SUCCESS)
    {
		VDSdebug("VDSdatafile_to_buffer \n");
		sprintf(s,"MEMbuild_array failed status = %d",status);
		VDSdebug(s);
		fclose (infile);
		status = VDS_E_BUILD_ARRAY;
		return (status);
   }
   rows = tmp_bufr->rows;
   cols = tmp_bufr->columns;
   column = (char **) tmp_bufr->column_ptr;

 /* Load tmp_bufr with inital and default values     */

  while (fgets (ss, 1024, infile))
  {
    /*  Check for comment in file  */

    if ((ss[0] == '#') || (ss[0] == '\n')) continue;

    if ((attrname = strtok (ss, "|")) == NULL)
    {
		VDSdebug("VDSdatafile_to_buffer:\n");
		sprintf (s, "File in unrecognized format <%s>\n",ss);
		VDSdebug(s);
		MEMclose(&tmp_bufr);
		status = VDS_E_FILE_FORMAT;
		fclose (infile);
		return (status);
    }
    if ((init_val = strtok (NULL, "|")) == NULL)
    {
		VDSdebug("VDSdatafile_to_buffer:\n");
		sprintf (s, "File in unrecognized format <%s>\n",ss);
		VDSdebug(s);
		MEMclose(&tmp_bufr);
		status = VDS_E_FILE_FORMAT;
		fclose (infile);
		return (status);
    }
    if ((def_val = strtok (NULL, "|\n")) == NULL)
    {
		VDSdebug("VDSdatafile_to_buffer:\n");
		sprintf (s, "File in unrecognized format <%s>\n",ss);
		VDSdebug(s);
		MEMclose(&tmp_bufr);
		status = VDS_E_FILE_FORMAT;
		fclose (infile);
		return (status);
    }

 /* find the column to write the data */
   
    j = -1;
    for (i = 0; i < cols; ++i)
    {
      sprintf (s, "comparing %s with %s\n", attrname, column[i]);
      VDSdebug (s) ;
		if (!strcmp(attrname,column[i]))
 	   {
	 	   j= i ;
	  	   break;
        }
    }
    if(j == -1)
    {
		status = VDS_E_BUFFER_FORMAT;
		VDSdebug("VDSdatafile_to_buffer \n");
		VDSdebug("Data buffer is incorrect\n");
		MEMclose(&tmp_bufr);
		return(status);
    }

/* prepare two rows one for init and one for default */
    if(strlen(init_val))
    {
    	 status = MEMwrite_data(tmp_bufr,init_val,1,j+1);
    	 if(status != MEM_S_SUCCESS)
    	 {
				VDSdebug("VDSdatafile_to_buffer \n");
				sprintf(s,"MEMwrite_data failed status = %d",status);
				VDSdebug(s);
   			   	MEMclose(&tmp_bufr);
				fclose (infile);
				status = VDS_E_WRITE_COLUMN;
				return (status);
    	 }
    }
    if(strlen(def_val))
    {
	   	status = MEMwrite_data(tmp_bufr,def_val,2,j+1);
    	if(status != MEM_S_SUCCESS)
    	{
			VDSdebug("VDSdatafile_to_buffer \n");
			sprintf(s,"MEMwrite_data failed status = %d",status);
			VDSdebug(s);
 		    MEMclose(&tmp_bufr);
			fclose (infile);
			status = VDS_E_WRITE_COLUMN;
 			return (status);
        }
     }
  }  /* end of while */
  fclose (infile);
  *data_buffer = tmp_bufr;
  VDSdebug("EXIT:VDSdatafile_to_buffer\n");
  return (VDS_S_SUCCESS);
}

VDSlistfile_to_buffer (file, list_buffer)
/* to be developed . currently there are no lists to load */
char		*file[];
MEMptr  	*list_buffer;
{
    
	VDSdebug("ENTER:VDSlistfile_to_buffer\n");
	VDSdebug("EXIT:VDSlistfile_to_buffer\n");
    return(VDS_S_SUCCESS);
}

VDSsub_catalog_attr_names (file_name,indx,no_fields,buffer)
 char		*file_name;
 int		indx[];
 int		no_fields;
 MEMptr	buffer;
{
	int		i, k;
	int		rows,cols;
	int		nx1;
 	int		which_row;
 	char		ss[1024];
	char		**data;
	char 		**column;
	char		*fields[30];
	FILE		*infile, *fopen ();

	VDSdebug("ENTER:VDSsub_catalog_attr_names\n");
   infile = NULL;
   if ((infile = fopen (file_name, "r")) == NULL)
   {
		VDSdebug("VDSsub_catalog_attr_names:\n ");
		sprintf (s, "Could not open file <%s> \n",file_name);
		VDSdebug(s);
		status = VDS_E_OPEN_FILE;
		return (status);
   }
   status = MEMbuild_array(buffer);
   if(status != MEM_S_SUCCESS)
   {
		VDSdebug("VDSsub_catalog_attr_names:\n ");
		sprintf (s, "MEMbuild_array failed : %d",status);
		VDSdebug(s);
		status = VDS_E_BUILD_ARRAY;
		return (status);
   }
   if(VDSdebug_on)
   {
   		MEMprint_buffer("in sub_cat",buffer,VDS_DEBUG_FILE);
   }
   data = (char **)buffer->data_ptr;
   rows = buffer->rows;
   cols = buffer->columns;
   column = (char **) buffer->column_ptr;

 /* read the file until no more data . there are "no_fields" fields
    in each row in this type of files */

   while (fgets (ss, 1024, infile))
   {
	/*  Check for comment in file  */

     if ((ss[0] == '#') || (ss[0] == '\n')) continue;
     if ((fields[0] = strtok (ss, "|")) == NULL)
     {
	   VDSdebug("VDSsub_catalog_attr_names:\n ");
	   VDSdebug("File in unrecognized format\n");
	   status = VDS_E_FILE_FORMAT;
 	   fclose (infile);
  	   return (status);
     }
    /*  printf ("no of fields is %d\n", no_fields) ; */
     for(i=1;i<no_fields-1;i++)
     {
		if ((fields[i] = strtok (NULL, "|")) == NULL)
		{
		   VDSdebug("VDSsub_catalog_attr_names:\n ");
	 	   VDSdebug("File in unrecognized format\n");
	  	   status = VDS_E_FILE_FORMAT;
 	   	   fclose (infile);
  	   	   return (status);
        }
     }
     if ((fields[no_fields-1] = strtok (NULL, "|\n")) == NULL)
     {
			VDSdebug("VDSsub_catalog_attr_names:\n ");
			VDSdebug("File in unrecognized format\n");
			status = VDS_E_FILE_FORMAT;
			fclose (infile);
			return (status);
     }

    /* modify row in buffer with fields[1..no_fields-1]
	         whose n_name == fields[0]  */

     which_row = -1;
     for (i = 0; i < rows; i++)   /* first find matching row */
     {
		nx1 = i * cols;
/* BETH 2/11/92 remove the use of offsets array because it is not set up prior
		to call */
/*        if (!strncmp(fields[0],data[nx1+offsets[indx[0]]],
			strlen(fields[0])))
*/        if (!strncmp(fields[0],data[nx1+indx[0]], strlen(fields[0])))
       	{
				which_row = i;
				break;
		}
      }
     
      /* write fields[1..no_fields-1] in to nx1 th row */
    
      if(which_row != -1)
      {  
			for(k=1;k<=no_fields-1;k++)
 	        {
/* BETH 2/11/92 removed the use of offsets because it is not set up prior
	 to function */
/*   			    status = MEMwrite_data(buffer,fields[k],
								which_row+1,offsets[indx[k]]+1);
*/	    			    status = MEMwrite_data(buffer,fields[k],
						which_row+1,indx[k]+1);
	  		if(status != MEM_S_SUCCESS)
	  	  		{
	       		   VDSdebug("VDSsub_catalog_attr_names:\n ");
   	 	   		   sprintf (s, "MEMwrite_data failed : %d",status);
		   	 	   VDSdebug(s);
		   	 	   status = VDS_E_WRITE_COLUMN;
		   	 	   return (status);
       			}
			}
      }   
      else
      {
           VDSdebug("VDSsub_catalog_attr_names\n");
	   	   sprintf(s,"There is no n_name -> %s in buffer\n",fields[0]);
	   	   VDSdebug(s);
	       status = VDS_E_BUFFER_FORMAT;
	       return(status);	   
       }
  }    /* end of while */
  fclose (infile);
  if(VDSdebug_on)
  {
		MEMprint_buffer("exit sub_cat",buffer,VDS_DEBUG_FILE);
  }
  VDSdebug("EXIT:VDSsub_catalog_attr_names\n");
  return (VDS_S_SUCCESS);
}

void VDSheading()
{

  printf("\n\
      *****************************************************************\n\
      *                                                               *\n\
      *               I/VDS   2.1 Initialization Program              *\n\
      *                                                               *\n\
      *****************************************************************\n\
    ") ;

printf("\n \
\tCopyright Intergraph Corporation, 1988, 1989, 1990, 1991, 1992\n\
\tincluding  software  and  its  file formats,  and audio-visual\n\
\tdisplays;  this is the  property of  Intergraph  Corporation;\n\
\tAll  Rights  Reserved.   May  only  be  used  pursuant to  the\n\
\tapplicable  software license agreement;  contains confidential\n\
\tand  proprietary  information of Intergraph and/or other third\n\
\tparties  which is  protected  by  copyright,  trade secret and\n\
\ttrademark law  and  may  not be  provide  or  otherwise  made\n\
\tavailable without prior written authorization;\n\
\n\
\t                 Restricted Rights Legend:\n\
\tUse, duplication or  disclosure  by the  government is subject\n\
\tto  restrictions as set forth in  subdivision  (b) (3) (ii) of\n\
\tthe rights in  technical data and  computer software clause at\n\
\t52.227-7013.\n\
\n\
\tIntergraph Corporation\n\
\tHuntsville, Alabama   35807-0001\n");
sleep (3);
printf("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
}

