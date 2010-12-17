#include		<stdio.h>
#include                "PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"NFMfile.h"
#include		"PDMproto.h"

extern		int		PDMdebug_on;
extern		char	PDM_DEBUG_FILE[];
static 		long		status;
static		char		s[1024];

/*
	DESCRIPTION : 

			Updates n_fileco column in data_bufr as given below
			And returns the list of files to be moved 

       INPUT:
			<attr_bufr,data_bufr> are the standard NFM buffers
			obtained after a NFMprepare_checkout call
	 note:
			data_bufr is expected with n_fileco set to Y or N
			depending on the objective.

			The following columns are REQD.

		n_catalogname
		n_itemname
		n_itemrev
		n_cofilename
		n_fileco
                n_type

		<storage_buffer> standard PDM storage area buffer

	OUTPUT:
	
		   <out_bufr> a copy of data_bufr with n_fileco set to N 
		   for rows whose files are available and current on the WS

	new_files:  Contains a list of files that ought to be 
               	    moved by NFM. It is NULL if no files are to be
                    moved.
		
		n_catalogname		
		n_itemname
		n_itemrev
		n_cofilename
		n_catalogno
		n_itemno
		p_mtype      "Y" if the file is available and current
			     "F" if the file is available and is not current
			     "N" if the file is not available

	Note: After a successfull call to NFMcomplete_checkout 
		  PDMXupdate_filemanager with new_files as input
			
*/

int PDMXchkout_file_transfers( data_bufr, storage_buffer, 
                              new_files, parent_row)
MEMptr	data_bufr;
MEMptr  storage_buffer;
MEMptr  new_files;
int	parent_row;
{
	char		**data, **data1;
	char		**columns;
	char		*fn = "PDMXchkout_file_transfers";
	char		*a_row, n_fileco[2];
	int			i = 0, j = 0, k = 0, nxj = 0, nxk = 0, found;
	int			n1 = 0, n2 = 0, n3 = 0, n4 = 0, n5 = 0; 
	int			n6 = 0, n7 = 0;
	int			m1 = 0, m2 = 0, m3 = 0, m4 = 0, m5 = 0; 
	int			m6 = 0, m7 = 0, m8 = 0, m9 = 0, m10 = 0; 
	int			m11 = 0, m12 = 0;
	MEMptr		bufr = NULL;
        int             catno;
    
   PDMdebug("ENTER:PDMXchkout_file_transfers\n");



   status = MEMbuild_array(data_bufr);
   if(status != MEM_S_SUCCESS)
   {
	_PDMdebug (fn, "MEMbuild_array failed status %d\n",status);
	return(PDM_E_BUILD_ARRAY);
   }
   data = (char **) data_bufr->data_ptr;
   columns = (char **) data_bufr->column_ptr;

   /* check to see if any files are to be moved */

   if(PDMdebug_on)
   {
    MEMprint_buffer("data_bufr at the start ", data_bufr,PDM_DEBUG_FILE);
      }
   k = 0;
    for(i=0 ; i < data_bufr->columns ; i++)
      {
        if(!strcmp(columns[i],"n_filetype")) m1 = i; 
        if(!strcmp(columns[i],"n_cifilesize")) m2 = i; 
        if(!strcmp(columns[i],"n_cofilename")) m3 = i; 
        if(!strcmp(columns[i],"n_cifilename")) m4 = i; 
        if(!strcmp(columns[i],"n_cisano")) m5 = i; 
        if(!strcmp(columns[i],"n_fileco")) m6 = i; 
        if(!strcmp(columns[i],"n_catalogname")) m7 = i; 
        if(!strcmp(columns[i],"n_itemno")) m8 = i; 
        if(!strcmp(columns[i],"n_fileno")) m9 = i; 
        if(!strcmp(columns[i],"n_itemname")) m10 = i; 
        if(!strcmp(columns[i],"n_itemrev")) m11 = i; 
        if(!strcmp(columns[i],"n_level")) m12 = i; 
      }
         
   for(j=0;j<data_bufr->rows;j++)
   {
	   nxj = j * data_bufr->columns;
	   if(!strcmp(data[nxj+m6],"Y"))
	   {
			k = 1;	break;
	   }
   }
   if(k == 0)
   {
	PDMdebug("No files to check \n");
	PDMdebug("EXIT:PDMXchkout_file_transfers \n");
	return(PDM_S_SUCCESS);
   }   


  status = MEMbuild_array (new_files);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&new_files);
    _PDMdebug ( fn, "MEMbuild_array: 0x%.8x\n", status );
    return (status);
  }


   a_row = (char *) malloc ((new_files)->row_size);
   if(a_row == NULL)
   {
                MEMclose(&new_files); MEMclose(&data_bufr);
                PDMdebug("Failed to malloc\n");
                return(PDM_E_COULD_NOT_MALLOC);
   }

   /* Get a list of files available on WS */

   status = PDMi_get_file_list(storage_buffer,&bufr);
   if((status == PDM_I_NO_FILES_FOUND)|| ( status == PDM_I_NO_SAREA_FOUND))
      {
	PDMdebug("There are no files available on storagearea \n");
	
	/* set n_fileco to Y and load new_files 
           if the part is a parent meaning that
           n_level is 0 or 1. */
/* modified for NFM2.2: the first row is not the parent in
   data_bufr; so in  new_files buffer, we write the parent row first
   and then in the subsequent rows, write the children. This was done
   because PDMXupdate_file_manager assumes that this buffer has parent
   information in the first row. (Look for p_type in that code) */

	   for(j=0; j<data_bufr->rows; j++)
 	    {
	      if (j == parent_row ) {
  	   	nxj = j * data_bufr->columns;
                if ((atol(data[nxj + m12])) < 2) {
                _PDMdebug (fn, "j = %d, data[%d + %d] = %s\ncolumns[m12] = %s", 
				j, nxj, m6, data[nxj + m6], columns[m12]);
		status = MEMwrite_data(data_bufr,"Y", j + 1, m6 + 1);
		if(status != MEM_S_SUCCESS)
		{
			 MEMclose(&data_bufr);	 free(a_row);
			 MEMclose(&new_files);
			 sprintf(s,
		 	 "MEMwrite_data failed status %d\n",status);
		 	 PDMdebug(s);
			 return(PDM_E_WRITE_COLUMN);
                       }
                   }
		/* write into new_files */
                _PDMdebug (fn, "j = %d, {data[nxj+m7]} data[%d + %d] = %s\n", 
				j, nxj, m7, data[nxj + m7] );
                status = PDMris_get_catno(data[nxj+m7], &catno);
		if(status != SQL_S_SUCCESS)
		{
			 MEMclose(&data_bufr);	 free(a_row);
			 MEMclose(&new_files);
			 _PDMdebug (fn, 
                           "PDMris_get_catno failed status %d\n",status);
			 return (status);
                       }
        _PDMdebug (fn, "catno = %d\n", catno);
		a_row[0] = '\0';
	_PDMdebug (fn,
"%d|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|\n", 
catno, data[nxj+m8],data[nxj+m9],data[nxj+m5], "","","","","","","","","","",
data[nxj+m4],data[nxj+m3],data[nxj+m1],"-1","move");
	sprintf(a_row,
"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", 
catno, data[nxj+m8],data[nxj+m9],data[nxj+m5], "","","","","","","","","","",
data[nxj+m4],data[nxj+m3],data[nxj+m1],"-1","move");
_PDMdebug (fn, "j=%d; a_row for parent is:\n %s\n", j, a_row);
	        status = MEMwrite(new_files, a_row);
		    if(status != MEM_S_SUCCESS)
			{
			MEMclose(&new_files);
			free(a_row); MEMclose(&data_bufr);
			sprintf(s,"MEMwrite failed status %d\n",
			status); PDMdebug(s);
			return(PDM_E_WRITE_ROW);
			}
		break;
		}
        }		   /* end of for */

   /* now add information from children rows .. */

	    for(j=0;j<data_bufr->rows;j++)
 	    {
	       if ( j != parent_row ) {
  	   	  nxj = j * data_bufr->columns;
                  if (!strcmp(data[nxj + m6],"Y"))
                  {
			/* write into new_files */
                status = PDMris_get_catno(data[nxj+m7], &catno);
		if(status != SQL_S_SUCCESS)
		{
			 MEMclose(&data_bufr);	 free(a_row);
			 MEMclose(&new_files);
			 _PDMdebug (fn, 
                           "PDMris_get_catno failed status %d\n",status);
			 return (status);
                       }
		a_row[0] = '\0';
	_PDMdebug (fn,
"child_row:\n %d|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|\n", 
catno, data[nxj+m8],data[nxj+m9],data[nxj+m5], "","","","","","","","","","",
data[nxj+m4],data[nxj+m3],data[nxj+m1],"-1","move");
	sprintf(a_row,
"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
catno, data[nxj+m8],data[nxj+m9],data[nxj+m5], "","","","","","","","","","",
data[nxj+m4],data[nxj+m3],data[nxj+m1],"-1","copy");
_PDMdebug (fn, "j=%d; a_rows for child is:\n %s\n", j, a_row);
	        status = MEMwrite(new_files, a_row);
		if(status != MEM_S_SUCCESS)
		{
		 MEMclose(&new_files);
		 free(a_row); MEMclose(&data_bufr);
		 sprintf(s,"MEMwrite failed status %d\n",
		 status); PDMdebug(s);
		 return(PDM_E_WRITE_ROW);
		}
              }
	    }
        }		   /* end of for */

	    free(a_row);  
   	   if(PDMdebug_on)
   		{
		 MEMprint_buffer("data_bufr in PDMchkout_file_transfers after NFM2.2 mod",
		 			data_bufr,PDM_DEBUG_FILE);
	         MEMprint_buffer("new_files in PDMchkout_file_transfers after NFM2.2 mod",
		  			new_files,PDM_DEBUG_FILE);
 	         }

	   PDMdebug("EXIT:PDMXchkout_file_transfers\n");
	   return(PDM_S_SUCCESS);
   }
   else if( status == SQL_I_NO_ROWS_FOUND)
   {
		PDMdebug("The specified storagearea is not defined yet\n");
   }
   else if(status != PDM_S_SUCCESS)
   {
		MEMclose(&new_files); MEMclose(&data_bufr);
		free(a_row);
		sprintf(s,"PDMi_get_file_list failed status %d\n",status);
		PDMdebug(s);
		return(status);
   }
   if(PDMdebug_on)
   {
        PDMdebug ("there are some files in the workstation\n");
	MEMprint_buffer("bufr ",bufr,PDM_DEBUG_FILE);
   }
   status = MEMbuild_array(bufr);
   if(status != MEM_S_SUCCESS)
   {
	MEMclose(&new_files);	free(a_row);
	MEMclose(&bufr); MEMclose(&data_bufr);
	sprintf(s,"MEMbuild_array failed status %d\n",status);
	PDMdebug(s);
	return(PDM_E_BUILD_ARRAY);
   }
   data1 = (char **) bufr->data_ptr;
   columns = (char **) bufr->column_ptr;
   n1 = -1; n2 = -1; n3 = -1; n4 = -1; n5 = -1;
   n6 = -1; n7 = -1;

   for(i=0;i<bufr->columns;i++)
   {
	if(!strcmp(columns[i],"n_catalogname"))  n1 = i;
	if(!strcmp(columns[i],"n_itemname")) 	 n2 = i;
	if(!strcmp(columns[i],"n_itemrev")) 	 n3 = i;
	if(!strcmp(columns[i],"p_mdate"))	 n4 = i;
	if(!strcmp(columns[i],"p_mtime")) 	 n5 = i;
	if(!strcmp(columns[i],"n_catalogno"))	 n6 = i;
	if(!strcmp(columns[i],"n_itemno")) 	 n7 = i;
   }

   if(n1 == -1 || n2 == -1 || n3 == -1 || 
	  n4 == -1 || n5 == -1 || n6 == -1 || n7 == -1)
   {
		PDMdebug("Couldnot find reqd columns in <bufr>\n");
		MEMclose(&new_files); free(a_row);
		MEMclose(&bufr); MEMclose(&data_bufr);
		return(PDM_E_BUFFER_FORMAT);
   }

    /* reset n_fileco if file is available and current */
		
/* modified for NFM2.2: the first row is not the parent in
   data_bufr; so in  new_files buffer, we write the parent row first
   and then in the subsequent rows, write the children. This was done
   because PDMXupdate_file_manager assumes that this buffer has parent
   information in the first row. (Look for p_type in that code) */

		
/* first write the parent row .. */
   for(j=0;j<data_bufr->rows;j++)
   {
    if (j == parent_row) {
     nxj = j * data_bufr->columns;

	   /* check only files that are to be moved */

     if(!strcmp(data[nxj+m6],"Y"))
     {
	n_fileco[0] = '\0';
	found = 0;

	/* match cat, part and rev */

	for(k=0;k<bufr->rows;k++)
	{
		nxk = k * bufr->columns;
		if(!strcmp(data[nxj+m7],data1[nxk+n1]) && 
		   !strcmp(data[nxj+m10],data1[nxk+n2]) && 
		   !strcmp(data[nxj+m11],data1[nxk+n3]))
		{
                _PDMdebug (fn, "**Found: item_name = %s\n", data[nxj+m10]);
		found = 1; break;
		}
	}
			
	/* if file exists on WS check dates */

	if(found)
	{
	  status = PDMi_set_fileco( data1[nxk+n1],data1[nxk+n2],
				    data1[nxk+n3],data1[nxk+n4],
				       data1[nxk+n5],n_fileco);
	     if(status != PDM_S_SUCCESS)
	     {
		MEMclose(&bufr); MEMclose(&data_bufr);
		free(a_row);
		sprintf(s,"PDMi_set_fileco failed status %d\n",
		status); PDMdebug(s);
		return(status);
		  }
			/* if current reset n_fileco */
	
		  if(!strncmp(n_fileco,"N",1))
		  {
			/* set n_fileco for matching entry */

		   status = MEMwrite_data(data_bufr,n_fileco,j+1,m6+1);
		   if(status != MEM_S_SUCCESS)
		   {
		    MEMclose(&bufr); MEMclose(&data_bufr);
		    free(a_row);
		    sprintf(s,
		     "MEMwrite_data failed status %d\n",status);
		     PDMdebug(s);
		    return(PDM_E_WRITE_COLUMN);
			}

		   /* write into new_files */
                status = PDMris_get_catno(data[nxj+m7], &catno);
		if(status != SQL_S_SUCCESS)
		{
			 MEMclose(&data_bufr);	 free(a_row);
			 MEMclose(&new_files);
			 _PDMdebug (fn, 
                           "PDMris_get_catno failed status %d\n",status);
			 return (status);
                       }
		a_row[0] = '\0';
	sprintf(a_row,
"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
catno, data[nxj+m8], data[nxj+m9], data[nxj+m5],  "", "", "", "", "", "", "", "", "", "", data[nxj+m4], data[nxj+m3], data[nxj+m1], "-1", "");

		  }  	 /* file is current */
		  else  /* file is not current */
		  {
			/* write into new_files */
                status = PDMris_get_catno(data[nxj+m7], &catno);
		if(status != SQL_S_SUCCESS)
		{
			 MEMclose(&data_bufr);	 free(a_row);
			 MEMclose(&new_files);
			 _PDMdebug (fn, 
                           "PDMris_get_catno failed status %d\n", status);
			 return (status);
                       }
		a_row[0] = '\0';
	sprintf(a_row,
"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
catno, data[nxj+m8], data[nxj+m9], data[nxj+m5],  "", "", "", "", "", "", "","", "", "", data[nxj+m4], data[nxj+m3], data[nxj+m1], "-1", "move");

		  }
		}  		/*  if found */
		else
		{
                PDMdebug ("Parent file is not on the workstation\n");
                status = PDMris_get_catno(data[nxj+m7], &catno);
		if(status != SQL_S_SUCCESS)
		{
		 MEMclose(&data_bufr);	 free(a_row);
		 MEMclose(&new_files);
		 _PDMdebug (fn, 
                          "PDMris_get_catno failed status %d\n", status);
		 return (status);
                       }
		a_row[0] = '\0';
	sprintf(a_row,
"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
catno, data[nxj+m8], data[nxj+m9], data[nxj+m5],  "", "","", "", "", "", "", "",
 "", "", data[nxj+m4], data[nxj+m3], data[nxj+m1], "-1", "move");
		}
_PDMdebug (fn, "parent a_row is : \n %s\n", a_row);
	    status = MEMwrite(new_files, a_row);
		if(status != MEM_S_SUCCESS)
		{
		MEMclose(&bufr); MEMclose(new_files);
		free(a_row); MEMclose(&data_bufr);
		sprintf(s, "MEMwrite failed status %d\n",
		status); PDMdebug(s);
		return(PDM_E_WRITE_ROW);
		}
     }         /* file is reqd to be moved */
    break;
    } /* end of if j = parent_row */
   }		   /* end of for */


/* now the children rows .. */
   for(j=0;j<data_bufr->rows;j++)
   {
    if (j != parent_row) {
     nxj = j * data_bufr->columns;


	   /* check only files that are to be moved */

     if(!strcmp(data[nxj+m6], "Y"))
     {
	n_fileco[0] = '\0';
	found = 0;

	/* match cat, part and rev */

	for(k=0;k<bufr->rows;k++)
	{
		nxk = k * bufr->columns;
		if(!strcmp(data[nxj+m7], data1[nxk+n1]) && 
		   !strcmp(data[nxj+m10], data1[nxk+n2]) && 
		   !strcmp(data[nxj+m11], data1[nxk+n3]))
		{
		 found = 1; 
                 PDMdebug("Found a CaPaRe common betn bufr and data_bufr\n");
                 break;
		}
	}
			
	/* if file exists on WS check dates */

	if(found)
	{
	  status = PDMi_set_fileco( data1[nxk+n1], data1[nxk+n2], 
				    data1[nxk+n3], data1[nxk+n4], 
				       data1[nxk+n5], n_fileco);
	     if(status != PDM_S_SUCCESS)
	     {
		MEMclose(&bufr); MEMclose(&data_bufr);
		free(a_row);
		sprintf(s, "PDMi_set_fileco failed status %d\n",
		status); PDMdebug(s);
		return(status);
		  }
			/* if current reset n_fileco */
	
		  if(!strncmp(n_fileco, "N", 1))
		  {
			/* set n_fileco for matching entry */

			status = MEMwrite_data(data_bufr, n_fileco, j+1, m6+1);
			if(status != MEM_S_SUCCESS)
			{
			 MEMclose(&bufr); MEMclose(&data_bufr);
			 free(a_row);
			 sprintf(s, 
		 	 "MEMwrite_data failed status %d\n", status);
		 	 PDMdebug(s);
			 return(PDM_E_WRITE_COLUMN);
			}

			/* write into new_files */
                status = PDMris_get_catno(data[nxj+m7], &catno);
		if(status != SQL_S_SUCCESS)
		{
			 MEMclose(&data_bufr);	 free(a_row);
			 MEMclose(&new_files);
			 _PDMdebug (fn, 
                           "PDMris_get_catno failed status %d\n", status);
			 return (status);
                       }
		a_row[0] = '\0';
	sprintf(a_row, 
"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", 
catno, data[nxj+m8], data[nxj+m9], data[nxj+m5],  "", "", "", "", "", 
"", "","", "", "", data[nxj+m4], data[nxj+m3], data[nxj+m1], 
"-1", "");
		  }  	 /* file is current */
		  else  /* file is not current */
		  {
			/* write into new_files */
                status = PDMris_get_catno(data[nxj+m7], &catno);
		if(status != SQL_S_SUCCESS)
		{
			 MEMclose(&data_bufr);	 free(a_row);
			 MEMclose(&new_files);
			 _PDMdebug (fn,  
                           "PDMris_get_catno failed status %d\n", status);
			 return (status);
                       }
		a_row[0] = '\0';
	sprintf(a_row, 
"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", 
catno, data[nxj+m8], data[nxj+m9], data[nxj+m5],  "", "", "", "", "", "", "", "", "", "", data[nxj+m4], data[nxj+m3], data[nxj+m1], "-1", "copy");
		  }
		}  		/*  if found */
		else
		{
                status = PDMris_get_catno(data[nxj+m7],  &catno);
		if(status != SQL_S_SUCCESS)
		{
			 MEMclose(&data_bufr);	 free(a_row);
			 MEMclose(&new_files);
			 _PDMdebug (fn, 
                           "PDMris_get_catno failed status %d\n", status);
			 return (status);
                       }
		a_row[0] = '\0';
	sprintf(a_row,
 "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
 catno, data[nxj+m8], data[nxj+m9], data[nxj+m5],  "", "", "", "", "", "", "", "", "", "", data[nxj+m4], data[nxj+m3], data[nxj+m1], "-1", "move");
		}
_PDMdebug (fn, "child #%d a_row is : \n %s\n", j, a_row);
	    status = MEMwrite(new_files, a_row);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&bufr); MEMclose(&new_files);
			free(a_row); MEMclose(&data_bufr);
			sprintf(s, "MEMwrite failed status %d\n", 
			status); PDMdebug(s);
			return(PDM_E_WRITE_ROW);
		}
     }         /* file is reqd to be moved */
    } /* end of if j != parent_row */
   }		   /* end of for */

   free(a_row);  MEMclose(&bufr);


   if(PDMdebug_on)
   {
		MEMprint_buffer("data_bufr in PDMchkout_file_transfers",
						data_bufr, PDM_DEBUG_FILE);
		MEMprint_buffer("new_files in PDMchkout_file_transfers",
						new_files, PDM_DEBUG_FILE);
   }
   PDMdebug("EXIT:PDMXchkout_file_transfers\n");
   return(PDM_S_SUCCESS);
}


/*
	Should be called after a successfull file transfer

	INPUT:	file_list 
			
	format:
				n_catalogname
				n_itemname
				n_itemrev
				n_cofilename
				n_catalogno
				n_itemno
				p_mtype    
*/

int  PDMXupdate_filemanager( file_list, storage_buffer, type)
MEMptr	file_list;
MEMptr  storage_buffer;
char	*type;
{
	char	c_date[12], c_time[10];
	char	        **columns, **data, **data1, **data2;
	char		*fn = "PDMXupdate_filemanager";
	int		n_sano;
	int		n1, n2, n3, n4, n5, n6, n8, n9;
	int		i, nxi, p_type;
        MEMptr  status_bufr = NULL;
        MEMptr  status_bufr1 = NULL;
        MEMptr  status_bufr2 = NULL;
        char    sql_str[300];
        int     attach_count;


  PDMdebug("ENTER:PDMXupdate_filemanager\n");

  if (PDMdebug_on)
    {
    _PDMdebug (fn,"type -> %s\n",type);
    MEMprint_buffer("file_list", file_list, PDM_DEBUG_FILE);
    }

  if(!file_list)
   {
		PDMdebug("EXIT:PDMXupdate_filemgr\n");
		return(PDM_S_SUCCESS);
   }
   if(!strcmp(type,"CHECKOUT"))
   {
		p_type = 1;
   }
   else if(!strcmp(type,"COPY"))
   {
		p_type = 2;
   }
   else if( !strcmp(type,"ATTACH"))
   {
		p_type = 3;
   }
   else if( !strcmp(type,"DETACH"))
   {
		p_type = 4;
   }
   else if( !strcmp(type,"CHECKIN"))
   {
		p_type = 5;
   }
   else if( !strcmp(type,"CANCELASSM"))
   {
		p_type = 6;
   }
   else if( !strcmp(type,"CANCELPART"))
   {
		p_type = 7;
   }
   else if( !strcmp(type,"CHKOUTATTACH"))
   {
		p_type = 8;
   }
   else if( !strcmp(type,"COPYATTACH"))
   {
		p_type = 9;
   }
   else
   {
		sprintf(s,"Unknown type <%s>\n",type);
		PDMdebug(s);
		return(PDM_E_FAILURE);
   }
   status = PDMi_find_storageno(storage_buffer,&n_sano);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s,"PDMi_find_storageno failed status %d\n",status);
		PDMdebug(s);
		return(status);
   }
   status = MEMbuild_array(file_list);
   if(status != MEM_S_SUCCESS)
   {
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   columns = (char **) file_list->column_ptr;
   data = (char **) file_list->data_ptr;
   n1 = -1; n2 = -1; n3 = -1; 
   n4 = -1; n5 = -1; n6 = -1; 
   n8 = -1; n9 = -1;
   for(i=0;i<file_list->columns;i++)
   {
		if(!strcmp(columns[i],"n_catalogno"))  n1 = i;
		if(!strcmp(columns[i],"n_itemno"))     n2 = i;
		if(!strcmp(columns[i],"n_fileno"))	     n3 = i;
		if(!strcmp(columns[i],"n_sano"))    n4 = i;
		if(!strcmp(columns[i],"n_status"))    n5 = i;
		if(!strcmp(columns[i],"n_cofilename"))   n6 = i;
   }
   if(n1 == -1 || n2 == -1 || n3 == -1 || n4 == -1 || n6 == -1 )
   {
		PDMdebug("Could not find cols in <file_list>\n");
		return(PDM_E_BUFFER_FORMAT);
   }
   status = PDMi_get_date(c_date,c_time);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s,"PDMi_get_date failed status %d\n",status);
		PDMdebug(s);

		return(status);
   }
for(i=0;i<file_list->rows;i++)
  {
   nxi = i * file_list->columns;
    if((p_type == 6) && (i > 0))
      {
        p_type = 7;
      }
    if(p_type == 7 && i == 0)
      {
        p_type = 6;
      }
    if(p_type == 8 && i == 0)
      {
        p_type = 1;
      }
    if((p_type == 1) && (i > 0))
      {
        p_type = 3;
      }
    if(p_type != 6 && p_type != 1 && p_type != 9 && p_type !=2 && p_type != 4)
     {
          attach_count = 1;

     }
    else attach_count = 1;

/* BETH 5/15/91 attach_count should be 0 if it is a copy */
    if (p_type == 2)
      attach_count = 0;

    if(PDMdebug_on)
    {
    _PDMdebug (fn, "attach_count %d\n", attach_count); 
    _PDMdebug (fn, "p_type %d\n", p_type); 
    }

    if( (!strcmp(data[nxi+n5],"move")) || (!strcmp(data[nxi+n5],"copy")))  
    {
    sprintf(sql_str, "%s %s %s %s  %s", "SELECT n_itemname FROM pdmwsparts",
           "WHERE n_catalogno =",data[nxi+n1], "AND n_itemno =", data[nxi+n2]);
            status = SQLquery(sql_str, &status_bufr1,512);
            if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
            {
             MEMclose(&status_bufr1);
             return(PDM_E_SQL_STMT);
            }
            else if(status == SQL_S_SUCCESS)/* part available on WS */
             {
               sprintf(sql_str, "%s %s '%s'", "SELECT p_fileno FROM pdmwsfiles",
                      "WHERE p_filename =",data[nxi+n6]);
                status = SQLquery(sql_str, &status_bufr2,512);
                if (status != SQL_S_SUCCESS)
                {
                 MEMclose(&status_bufr1);
                 MEMclose(&status_bufr2);
                 return(PDM_E_SQL_STMT);
                } 
                else if(status == SQL_S_SUCCESS)/* part available on WS */
                {
	   		status = MEMbuild_array(status_bufr1);
			status = MEMbuild_array(status_bufr2);
			data1=(char**)status_bufr1->data_ptr;
			data2=(char**)status_bufr2->data_ptr;
			sprintf(sql_str, "%s %s %s %s %s %s %d", 
			"SELECT p_sano FROM pdmfmgr",
  		         "WHERE n_itemname =",data1[0], "AND p_fileno =", 
			 data2[0],  "AND p_sano =", n_sano);
   	             status = SQLquery(sql_str, &status_bufr,512);
    	             if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
     	             {
       	             MEMclose(&status_bufr);
       	             return(PDM_E_SQL_STMT);
                     } 
                if (status == SQL_S_SUCCESS)/* file is available in WS */
                   {
                   MEMclose(&status_bufr);
                   MEMclose(&status_bufr1);
                   MEMclose(&status_bufr2);
	           status = PDMXupdate_fmgrentry( n_sano, data[nxi+n4],
                 data[nxi+n5], data[nxi+n6], c_date,c_time,p_type,attach_count);
			    if(status != PDM_S_SUCCESS)
			     {
		             sprintf(s,"PDMupdate_fmgrentry failed status %d\n",
				status); PDMdebug(s);
		             return(status);
			     }
		        }
                   }
	 /* When part is there, file not available on WS is not possible*/

              }
           /*Part and file not available on WS */
           if((status == SQL_I_NO_ROWS_FOUND) )  
           {
                MEMclose(&status_bufr);
		status = PDMXload_fmgrentry( n_sano, data[nxi+n1], data[nxi+n2],
			   data[nxi+n6], c_date,c_time,p_type,attach_count);
			if(status != PDM_S_SUCCESS)
		      	{
			sprintf(s,"PDMXload_fmgrentry failed status %d\n",
			status); PDMdebug(s);
			return(status);
		        }
            }
       }/* first check for "N" */
       /* available and file current on WS */
     else if(!strcmp(data[nxi+n8],"Y")) 
          {
          MEMclose(&status_bufr);
	  status = PDMXupdate_fmgrentry( n_sano, data[nxi+n1], data[nxi+n2],
		       data[nxi+n6], c_date,c_time,p_type,attach_count);
         	   if(status != PDM_S_SUCCESS)
		   {
		   sprintf(s,"PDMXupdate_fmgrentry failed status %d\n",
		   status); PDMdebug(s);
		   return(status);
		   }
	  }
	/* available & file not current on WS */
      else if(!strcmp(data[nxi+n8],"F"))   
	 {
           MEMclose(&status_bufr);
	   status = PDMXupdate_fmgrdates( n_sano, data[nxi+n1], data[nxi+n2],
			data[nxi+n6], c_date,c_time, p_type,attach_count);
       	   if(status != PDM_S_SUCCESS)

	   {
	   sprintf(s,"PDMXupdate_fmgrdates failed status %d\n", status);
           PDMdebug(s);
	   return(status);
           }
	 }
     else
         {
	 sprintf(s,"Unknown p_mtype <%s> in file_list \n", data[nxi+n8]);
	 PDMdebug(s);
	 }
    if(p_type == 7 && i == 0)
      {
        p_type = 7;
      }
    if((p_type == 6) && (i > 0))
      {
        p_type = 6;
      }
     }/*end of the for loop */
   PDMdebug("EXIT:PDMXupdate_filemanager\n");
   return(PDM_S_SUCCESS);
}

int PDMXload_fmgrentry(n_sano, p_catno, n_itemno, p_filename,
				  p_mdate,p_mtime,p_mtype,attach_count)
int		n_sano;
char	*p_catno;
char	*n_itemno;
char	*p_filename;
char	*p_mdate;
char	*p_mtime;
int		p_mtype;
int     attach_count;
{
	int		n_itemname;
	int		p_fileno, p_ref1, p_ref2;
	char	sql_str[300];
	MEMptr		status_bufr = NULL;
	char		**status_data;
	
	PDMdebug("ENTER:PDMXload_fmgrentry\n");

	if(p_mtype == 1)/*CHECK OUT*/
    {
		p_ref1 = 1;
		p_ref2 = 0;
    }
	else if(p_mtype == 2)/*COPY*/
    {
		p_ref1 = 0;
		p_ref2 = 0;
	}
	else if(p_mtype == 3)/*  ATTACH*/
    {
		p_ref1 = 0;
		p_ref2 = attach_count;
	}
	else if(p_mtype == 9)/*  COPY AND ATTACH*/
    {
		p_ref1 = 0;
		p_ref2 = attach_count;
	}
    else
    {
		sprintf(s,"Unknown p_mtype %d\n",p_mtype);
		PDMdebug(s);
		return(PDM_E_FAILURE);
    }
	/* check to see if the part is already in the pdmwsparts table */
	sprintf(sql_str, "%s %s %s %s  %s", "SELECT n_itemname FROM pdmwsparts",
           "WHERE n_catalogno =",p_catno, "AND n_itemno =", n_itemno);
        status = SQLquery(sql_str, &status_bufr,512);

	if (status == SQL_S_SUCCESS)
	{
		status = MEMbuild_array(status_bufr);
		status_data = (char **)status_bufr->data_ptr;
		n_itemname = atoi(status_data[0]);
	}
	else
	if (status == SQL_I_NO_ROWS_FOUND)
	{
		/* get next n_itemname and insert into pdmwsparts */

		status = PDMi_maxrow_no("pdmwsparts","n_itemname",&n_itemname);
		if(status != PDM_S_SUCCESS)
		{
			sprintf(s,"PDMi_maxrow_no failed status %d\n",
			status); PDMdebug(s); 
			return(status);
		}
		n_itemname = n_itemname + 1 ;

		sprintf(sql_str,"%s VALUES(%d,%s,%s)",
		"INSERT INTO pdmwsparts (n_itemname,n_catalogno,n_itemno)",
		n_itemname,p_catno,n_itemno);
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s,"SQLstmt failed status %d\n",
			status); PDMdebug(s);
			return(PDM_E_SQL_STMT);
		}
	}
	
	/* get next p_fileno and insert into pdmwsfiles */

	status = PDMi_maxrow_no("pdmwsfiles","p_fileno",&p_fileno);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMi_maxrow_no failed status %d\n",
		status); PDMdebug(s); 
		return(status);
	}
	p_fileno = p_fileno + 1 ;

	sprintf(sql_str,"%s VALUES(%d,'%s','%s','%s')",
	"INSERT INTO pdmwsfiles (p_fileno,p_filename,p_mdate,p_mtime)",
	p_fileno,p_filename,p_mdate,p_mtime);
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",
		status); PDMdebug(s);
		return(PDM_E_SQL_STMT);
	}

	/* insert into pdmfmgr */

	sprintf(sql_str,"%s %s VALUES (%d,%d,%d,%d,%d)",
	"INSERT INTO pdmfmgr ",
	" (n_itemname,p_fileno,p_sano,p_ref1,p_ref2) ",
	n_itemname,p_fileno,n_sano,p_ref1,p_ref2);
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",
		status); PDMdebug(s);
		return(PDM_E_SQL_STMT);
	}
	PDMdebug("EXIT:PDMXload_fmgrentry\n");
	return(PDM_S_SUCCESS);
}

int PDMXupdate_fmgrentry(n_sano, p_catno, n_itemno, p_filename,
			p_mdate,p_mtime,p_mtype,attach_count)
int		n_sano;
char	*p_catno;
char	*n_itemno;
char	*p_filename;
char	*p_mdate;
char	*p_mtime;
int		p_mtype;
int     attach_count;
{
	int		n_itemname;
	int		p_ref1;
	int		p_ref2;
	char	sql_str[300];

	PDMdebug("ENTER:PDMXi_update_fmgrentry\n");

/* APOGEE START */
sprintf (s, "Added to humor acc: p_filename = %s; p_mdate = %s; p_mtime = %s\n",
		 p_filename, p_mdate, p_mtime );
/* APOGEE END */

	if(p_mtype != 1 && p_mtype != 2 && p_mtype != 3 &&
	   p_mtype != 4 && p_mtype != 5 && p_mtype != 6 && 
           p_mtype != 7 && p_mtype != 8 && p_mtype != 9)
    {
		sprintf(s,"Unknown p_mtype %d\n",p_mtype);
		PDMdebug(s);
		return(PDM_E_FAILURE);
    }

	status = PDMi_find_partnum(
					atol(p_catno),
					atol(n_itemno),&n_itemname);
    if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMi_find_partnum failed status %d\n",
		status); PDMdebug(s);
		return(status);
	}

	/* Update pdmfmgr  */

	status = PDMi_find_references(n_itemname,n_sano, &p_ref1,&p_ref2);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMi_find_references failed status %d \n",
		status); PDMdebug(s);
		return(status);
	}
       
	if(p_mtype == 1) /* Just a CHECK OUT */
          {
            p_ref1 = 1;
            p_ref2 = p_ref2;
          }
	 else if(p_mtype == 2) /* Just a COPY */
          {
            p_ref1 = 0;
            p_ref2 = p_ref2;
          }
	 else if(p_mtype == 3) /* Just a ATTACH */
          {
            p_ref1 = p_ref1;
            p_ref2 = p_ref2 +attach_count;
          }
	 else if(p_mtype == 9) /* COPY AND ATTACH */
          {
            p_ref1 = p_ref1;
            p_ref2 = p_ref2 +attach_count;
          }
	 else if(p_mtype == 4) /* Just a DETACH */
          {
            p_ref1 = p_ref1;
            p_ref2 = p_ref2  - attach_count;
          }
	 else if(p_mtype == 5) /*  CHECKIN */
          {
            p_ref1 = 0;
            p_ref2 = p_ref2 ;
          }
	 else if(p_mtype == 6) /*  CANCEL CHECKOUT ASSEMBLY */
          {
            p_ref1 = 0;
            p_ref2 = p_ref2 ;
          }
	 else if(p_mtype == 7) /*  CANCEL CHECKOUT PART OF A ASSEMBLY*/
          {
            p_ref1 = p_ref1;
            if(p_ref2 != 0) p_ref2 = p_ref2 - attach_count ;
            else p_ref2 = 0;
          }
     
   
	sprintf(sql_str,"%s %d,%s %d %s %d %s %d",
        "UPDATE pdmfmgr SET p_ref1 = ",p_ref1,"p_ref2 = ",p_ref2,
	"WHERE p_sano = ",n_sano,
	"AND n_itemname = ",n_itemname);
  
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",
		status); PDMdebug(s);
		PDMdebug("Failed While updating pdmfmgr \n");
		return(PDM_E_SQL_STMT);
	}
	PDMdebug("EXIT:PDMXi_update_fmgrentry\n");
	return(PDM_S_SUCCESS);
}

int PDMXupdate_fmgrdates(n_sano, p_catno, n_itemno, p_filename,
			p_mdate,p_mtime,p_mtype,attach_count)
int	n_sano;
char	*p_catno;
char	*n_itemno;
char	*p_filename;
char	*p_mdate;
char	*p_mtime;
int	p_mtype;
int     attach_count;
{
	int		n_itemname;
	int		p_fileno;
	int		p_ref1;
	int		p_ref2;
	char	sql_str[300];

	PDMdebug("ENTER:PDMXi_update_fmgrdates\n");

	if(p_mtype != 1 && p_mtype != 2 &&
	   p_mtype != 3 && p_mtype != 4 &&
	   p_mtype != 5 && p_mtype != 6 && 
           p_mtype != 7 && p_mtype != 9)
    {
		sprintf(s,"Unknown p_mtype %d\n",p_mtype);
		PDMdebug(s);
		return(PDM_E_FAILURE);
    }

	status = PDMi_find_partnum(
					atol(p_catno),
					atol(n_itemno),&n_itemname);
    if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMi_find_partnum failed status %d\n",
		status); PDMdebug(s);
		return(status);
	}

	status = PDMi_find_fileno(n_itemname,n_sano,&p_fileno);
    if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMi_find_fileno failed status %d\n",
		status); PDMdebug(s);
		return(status);
	}

	/* Update pdmwsfiles */

	sprintf(sql_str,"%s '%s', %s '%s' %s %d %s '%s'",
	"UPDATE pdmwsfiles SET p_mdate = ",p_mdate,
	"p_mtime = 	",p_mtime,
	"WHERE p_fileno = ",p_fileno,
	"AND p_filename = ",p_filename);
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d \n",
		status); PDMdebug(s);
		PDMdebug("Failed While updating pdmwsfiles \n");
		return(PDM_E_SQL_STMT);
	}

	/* Update pdmfmgr  */

	status = PDMi_find_references(n_itemname,n_sano, &p_ref1,&p_ref2);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMi_find_references failed status %d \n",
		status); PDMdebug(s);
		return(status);
	}
	if(p_mtype == 1) /* Just a CHECK OUT */
          {
            p_ref1 = 1;
            p_ref2 = p_ref2;
          }
	 else if(p_mtype == 2) /* Just a COPY */
          {
            p_ref1 = 0;
            p_ref2 = p_ref2;
          }
	 else if(p_mtype == 3) /* Just a ATTACH */
          {
            p_ref1 = p_ref1;
            p_ref2 = p_ref2 + attach_count;
          }
	 else if(p_mtype == 9) /* COPY ATTACH */
          {
            p_ref1 = p_ref1;
            p_ref2 = p_ref2 + attach_count;
          }
	 else if(p_mtype == 4) /* Just a DETACH */
          {
            p_ref1 = p_ref1;
            p_ref2 = p_ref2  - attach_count;
          }
	 else if(p_mtype == 5) /*  CHECKIN */
          {
            p_ref1 = 0;
            p_ref2 = p_ref2 ;
          }
	 else if(p_mtype == 6) /*  CANCEL CHECKOUT ASSEMBLY */
          {
            p_ref1 = 0;
            p_ref2 = p_ref2 ;
          }
	 else if(p_mtype == 7) /*  CANCEL CHECKOUT PART OF A ASSEMBLY*/
          {
            p_ref1 = p_ref1;
            p_ref2 = p_ref2 - attach_count ;
          }
	sprintf(sql_str,"%s %d,%s %d %s %d %s %d",
        "UPDATE pdmfmgr SET p_ref1 = ",p_ref1,"p_ref2 = ",p_ref2,
	"WHERE p_sano = ",n_sano,
	"AND n_itemname = ",n_itemname);
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",
		status); PDMdebug(s);
		PDMdebug("Failed While updating pdmfmgr \n");
		return(PDM_E_SQL_STMT);
	}
	PDMdebug("EXIT:PDMXi_update_fmgrdates\n");
	return(PDM_S_SUCCESS);
}
