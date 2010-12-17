#include		<stdio.h>
#include                "PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"NFMfile.h"
#include		"PDUstorage.h"
#include		"PDMproto.h"
#include		"PDUintdef.h"
#include		"PDUfile_def.h"

extern		int		PDMdebug_on;
extern		char	PDM_DEBUG_FILE[];
static 		long		status;
static		char		s[1024];
extern struct   PDUstorage *storage;

/*
DESCRIPTION : 

Updates n_fileco column in copy_files as given below

 INPUT:  this is PDM generated and is specific to PDM

	copy_buffer

	The following columns are REQD.

	n_catalogname
	n_itemname
	n_itemrev
	n_cofilename
	n_fileco		 set to "Y"

OUTPUT:

	copy_buffer:
			 For each entry if the file is not needed
			 to be moved n_fileco = "N"

	new_files:  Contains a list of files that ought to be 
		moved by NFM. It is NULL if no files are reqd.
		
	n_catalogname		
	n_itemname
	n_itemrev
	n_cofilename
	n_catalogno
	n_itemno
	p_mtype      "Y" 
		 "N" 
		 "F"

*/

int PDMcopy_file_transfers(copy_files, 
				storage_buffer, 
				new_files)
MEMptr	copy_files;
MEMptr  storage_buffer;
MEMptr  *new_files;
{
	char		**data, **data1;
	char		**columns, **format;
	char		*a_row, n_fileco[2];
	int			i, j, k, nxj, nxk = 0, found;
	int			n1, n2, n3, n4, n5, n6, n7;
	int			m1, m2, m3, m4, m5, m6, m7;
	MEMptr		bufr = NULL;
    
   PDMdebug("ENTER:PDMcopy_file_transfers\n");
   if(PDMdebug_on)
   {
		MEMprint_buffer("copy_files", copy_files, PDM_DEBUG_FILE);
   }
   status = MEMbuild_array(copy_files);
   if(status != MEM_S_SUCCESS)
   {
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);		
   }
   data = (char **) copy_files->data_ptr;
   columns = (char **) copy_files->column_ptr;
   m1 = -1; m2 = -1; m3 = -1; m4 = -1; m5 = -1; m6 = -1; m7= -1;
   for(i=0;i<copy_files->columns;i++)
   {
		if(!strcmp(columns[i], "n_catalogname"))   	m1 = i;
		if(!strcmp(columns[i], "n_itemname"))   		m2 = i;
		if(!strcmp(columns[i], "n_itemrev"))   		m3 = i;
		if(!strcmp(columns[i], "n_cofilename"))  	m4 = i;
		if(!strcmp(columns[i], "n_fileco"))   		m5 = i;
		if(!strcmp(columns[i], "p_parttype"))   		m6 = i;
		if(!strcmp(columns[i], "p_level"))   		m7 = i;
   }

   if(m1 == -1 || m2 == -1 || m3 == -1 ||
	  m4 == -1 || m5 == -1 || m6 == -1 || m7 == -1)
   {
		PDMdebug("Could not find columns in <copy_files>\n");
		return(PDM_E_BUFFER_FORMAT);
   }
   *new_files = NULL;   
   a_row = NULL;
   format = (char **) copy_files->format_ptr;
   status = MEMopen(new_files, 1024);
   if(status != MEM_S_SUCCESS)
   {
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
   }
   status = MEMwrite_format(*new_files, "n_catalogname", format[m1]);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(new_files);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*new_files, "n_itemname", format[m2]);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(new_files);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*new_files, "n_itemrev", format[m3]);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(new_files);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*new_files, "n_cofilename", format[m4]);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(new_files); 
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*new_files, "n_catalogno", "integer");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(new_files);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*new_files, "n_itemno", "integer");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(new_files);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*new_files, "p_mtype", "char(1)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(new_files);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*new_files, "p_level", "integer");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(new_files);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   a_row = (char *) malloc((*new_files)->row_size);
   if(a_row == NULL)
   {
		MEMclose(new_files); MEMclose(&bufr);
		PDMdebug("Failed to malloc\n");
		return(PDM_E_COULD_NOT_MALLOC);
   }

   /* Get a list of files available on WS */

   status = PDMi_get_file_list(storage_buffer, &bufr);
	   if((status == PDM_I_NO_FILES_FOUND) || (status == PDM_I_NO_SAREA_FOUND))
   {
	   PDMdebug("There are no files available on storagearea \n");

	   for(j=0;j<copy_files->rows;j++)
 	   {
   		    nxj = j * copy_files->columns;
		    status = MEMwrite_data(copy_files, "Y", j+1, m5+1);
			if(status != MEM_S_SUCCESS)
			{
				 MEMclose(new_files); free(a_row);
				 sprintf(s, 
			 	 "MEMwrite_data failed status %d\n", status);
			 	 PDMdebug(s);
				 return(PDM_E_WRITE_COLUMN);
			}
					/* write into new_files */
                        if(strcmp(data[nxj+m6], "N"))
                        {
               	        sprintf(a_row, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", 
			            data[nxj+m1], data[nxj+m2], data[nxj+m3], 
			            data[nxj+m4], "", "", "N", data[nxj+m7]);
               	        status = MEMwrite(*new_files, a_row);

		            if(status != MEM_S_SUCCESS)
		             {
				MEMclose(new_files); free(a_row);
				sprintf(s, "MEMwrite failed status %d\n", 
				status); PDMdebug(s);
				return(PDM_E_WRITE_ROW);
		             }
                         }
       }		   /* end of for */

	   free(a_row);

		   /* load n_catalogno, n_itemno for new files */

	   status = PDMload_partnos(*new_files);
 	   if(status != PDM_S_SUCCESS)
  	   {
			MEMclose(new_files); *new_files = NULL;
			sprintf(s, "PDMload_partnos failed status %d\n", 
			status); PDMdebug(s);
			return(status);
  	   }

       if(PDMdebug_on)
       {
			MEMprint_buffer("copy_files in PDMcopy_file_transfers", 
						copy_files, PDM_DEBUG_FILE);
			MEMprint_buffer("new_files in PDMcopy_file_transfers", 
						*new_files, PDM_DEBUG_FILE);
        }

		PDMdebug("EXIT:PDMcopy_file_transfers\n");
		return(PDM_S_SUCCESS);
   }
   else if( status == SQL_I_NO_ROWS_FOUND)
   {
		PDMdebug("The specified storagearea is not defined yet\n");
   }
   else if(status != PDM_S_SUCCESS)
   {
		sprintf(s, "PDMi_get_file_list failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   status = MEMbuild_array(bufr);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   data1 = (char **) bufr->data_ptr;
   columns = (char **) bufr->column_ptr;
   n1 = -1; n2 = -1; n3 = -1; 
   n4 = -1; n5 = -1; n6 = -1; n7 = -1;
   for(i=0;i<bufr->columns;i++)
   {
		if(!strcmp(columns[i], "n_catalogname"))  n1 = i;
		if(!strcmp(columns[i], "n_itemname")) 	 n2 = i;
		if(!strcmp(columns[i], "n_itemrev")) 	 n3 = i;
		if(!strcmp(columns[i], "p_mdate"))		 n4 = i;
		if(!strcmp(columns[i], "p_mtime")) 		 n5 = i;
		if(!strcmp(columns[i], "n_catalogno"))	 n6 = i;
		if(!strcmp(columns[i], "n_itemno")) 		 n7 = i;
   }
   if(n1 == -1 || n2 == -1 || n3 == -1 || 
	  n4 == -1 || n5 == -1 || n6 == -1 || n7 == -1)
   {
		PDMdebug("Couldnot find reqd columns in <bufr>\n");
		MEMclose(&bufr); MEMclose(new_files);
		return(PDM_E_BUFFER_FORMAT);
   }

    /* reset n_fileco if file is available and current */

   for(j=0;j<copy_files->rows;j++)
   {
     nxj = j * copy_files->columns;

	   /* check only files that are to be moved */

     if(!strcmp(data[nxj+m5], "Y"))
     {
		n_fileco[0] = '\0';
		found = 0;

		/* match cat, part and rev */

		for(k=0;k<bufr->rows;k++)
		{
			nxk = k * bufr->columns;
			if(!strcmp(data[nxj+m1], data1[nxk+n1]) && 
			   !strcmp(data[nxj+m2], data1[nxk+n2]) && 
			   !strcmp(data[nxj+m3], data1[nxk+n3]))
			{
				found = 1; break;
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
				MEMclose(&bufr); MEMclose(new_files);
				free(a_row);
				sprintf(s, "PDMi_set_fileco failed status %d\n", 
				status); PDMdebug(s);
				return(status);
		  }
					/* if current reset n_fileco */
	
		  if(!strncmp(n_fileco, "N", 1))
		  {
					/* set n_fileco for matching entry */

			status = MEMwrite_data(copy_files, n_fileco, j+1, m5+1);
			if(status != MEM_S_SUCCESS)
			{
				 MEMclose(&bufr); MEMclose(new_files);
				 free(a_row);
				 sprintf(s, 
			 	 "MEMwrite_data failed status %d\n", status);
			 	 PDMdebug(s);
				 return(PDM_E_WRITE_COLUMN);
			}
					/* write into new_files */

		sprintf(a_row, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", 
			data[nxj+m1], data[nxj+m2], data[nxj+m3], 
	data[nxj+m4], data1[nxk+n6], data1[nxk+n7], "Y", data[nxj+m7]);
		  }  	 /* file is current */
          else
          {	
			sprintf(a_row, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", 
			data[nxj+m1], data[nxj+m2], data[nxj+m3], 
		data[nxj+m4], data1[nxk+n6], data1[nxk+n7], "F", data[nxj+m7]);
		  }  	 /* file is not current */
		}  		/*  if found */
		else
		{

               	        sprintf(a_row, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", 
			            data[nxj+m1], data[nxj+m2], data[nxj+m3], 
			            data[nxj+m4], "", "", "N", data[nxj+m7]);
		}
             if(strcmp(data[nxj+m6], "N"))
                {
	    status = MEMwrite(*new_files, a_row);
		if(status != MEM_S_SUCCESS)
		        {
			MEMclose(&bufr); MEMclose(new_files);
			free(a_row);
			sprintf(s, "MEMwrite failed status %d\n", 
			status); PDMdebug(s);
			return(PDM_E_WRITE_ROW);
		         }
                }
     }         /* file is reqd to be moved */
   }		   /* end of for */

   free(a_row);  MEMclose(&bufr);

   /* load n_catalogno, n_itemno for new files */

   status = PDMload_partnos(*new_files);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(new_files); *new_files = NULL;
		sprintf(s, "PDMload_partnos failed status %d\n", 
		status); PDMdebug(s);
		return(status);
   }

   if(PDMdebug_on)
   {
		MEMprint_buffer("copy_files in PDMcopy_file_transfers", 
						copy_files, PDM_DEBUG_FILE);
		MEMprint_buffer("new_files in PDMcopy_file_transfers", 
						*new_files, PDM_DEBUG_FILE);
   }
   PDMdebug("EXIT:PDMcopy_file_transfers\n");
   return(PDM_S_SUCCESS);
}


int PDMupdate_fmgr_copy(sano, fmgr_bufr)
int sano;
MEMptr fmgr_bufr;
{
  char  sql_str[1024];
char    *fn="PDMupdate_fmgr_copy";
  char  **fmgr_data, **data;
  int   i = 0, nxi =0;
 MEMptr bufr = NULL;

 _PDMdebug(fn, "ENTER ...\n");    


       status = MEMbuild_array(fmgr_bufr);
               if (status != MEM_S_SUCCESS)
                  {
                 _PDMdebug (fn, "MEM error  0x%.8x\n", status);
                   return (PDM_E_BUILD_ARRAY);
                   }
   if(PDMdebug_on)
     {
      MEMprint_buffer("fmgr_bufr in PDMupdate_fmgr_copy", fmgr_bufr, PDM_DEBUG_FILE);
     }
           fmgr_data = (char **)fmgr_bufr->data_ptr;

     for(i=0; i < fmgr_bufr->rows; i++)
        {
           nxi = i * fmgr_bufr->columns;
            
/* If it's not to be moved, checking for negation of non-negation */
                 if(strcmp(fmgr_data[nxi+6], "MOVE"))
                 {
sql_str[0] = '\0';
sprintf(sql_str, "select n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint, n_fileversion from nfmsafiles where n_sano = %d and n_filename = '%s' and n_catalogno = %s and n_itemno = %s and n_filenum = %s", sano, fmgr_data[nxi+5], fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2] );

         /* Added fix to because the bufr still contains information about
            previous query....  Subsequent rows will be updated depending
            on the information in the first row always. This is not
            correct. MaC 022194 */

            MEMclose (&bufr);
            bufr = NULL;

                status = SQLquery(sql_str, &bufr, 512);
               if(status != SQL_S_SUCCESS)
                 {
                   if (status == SQL_I_NO_ROWS_FOUND)
                    {
                   sql_str[0] = '\0';
       sprintf(sql_str, "INSERT INTO NFMSAFILES (n_sano, n_filename, n_catalogno, n_itemno, n_filenum, n_fileversion, n_ref, n_copy, n_cisano) VALUES(%d, '%s', %s, %s, %s, %s, %d, '%s', %s)", sano, fmgr_data[nxi+5], fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2], fmgr_data[nxi+3], 1, "N", fmgr_data[nxi+4]);
            
                    status = SQLstmt(sql_str);
                     if (status != SQL_S_SUCCESS)
                     {
                       /* report a error */
                       MEMclose(&bufr);
                       return(PDM_E_SQL_STMT);
                     }
                 }
                    else 
                     {
                       /* skip this part */
                       continue;
                     }
             }

            status = MEMbuild_array(bufr);
               if (status != MEM_S_SUCCESS)
                  {
                 _PDMdebug (fn, "MEM error  0x%.8x\n", status);
                   return (PDM_E_BUILD_ARRAY);
                   }
   if(PDMdebug_on)
     {
      MEMprint_buffer("bufr in PDMupdate_fmgr_copy ", bufr, PDM_DEBUG_FILE);
     }
            data = (char **) bufr->data_ptr;
 
            /* if the file version is the same as  previous copy */
                 if(!strcmp(fmgr_data[nxi+6], "REF_UPDATE") ||
                 !strcmp(fmgr_data[nxi+6], "CHECKOUT") )
              {
                   sql_str[0] = '\0';
                       sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %d, n_copy = '%s' WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s ", (atoi(data[2])+1), data[1], sano, fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2]);
                    status = SQLstmt(sql_str);
                     if (status != SQL_S_SUCCESS)
                     {
                       /* report a error */
                       MEMclose(&bufr);
                       return(PDM_E_SQL_STMT);
                     }
              }
            /* if the file version is later than  and  provious copy */
            else     if(!strcmp(fmgr_data[nxi+6], "VERSION_UPDATE"))
              {
                   sql_str[0] = '\0';
                       sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %d, n_fileversion = %s, n_copy = '%s' WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s  ", (atoi(data[2])+1), fmgr_data[nxi+3], data[1], sano, fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2]);
                    status = SQLstmt(sql_str);
                     if (status != SQL_S_SUCCESS)
                     {
                       /* report a error */
                       MEMclose(&bufr);
                       return(PDM_E_SQL_STMT);
                     }
              }
               
               }
           else
               {
                   sql_str[0] = '\0';
sprintf(sql_str, "INSERT INTO NFMSAFILES (n_sano, n_filename, n_catalogno, n_itemno, n_filenum, n_fileversion, n_ref, n_copy, n_cisano) VALUES(%d, '%s', %s, %s, %s, %s, %d, '%s', %s)", sano, fmgr_data[nxi+5], fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2], fmgr_data[nxi+3], 1, "N", fmgr_data[nxi+4]);
            
                    status = SQLstmt(sql_str);
                     if (status != SQL_S_SUCCESS)
                     {
                       /* report a error */
                       MEMclose(&bufr);
                       return(PDM_E_SQL_STMT);
                     }

              }

          }
                       MEMclose(&bufr);
          _PDMdebug(fn, "EXIT.....\n");
          return(PDM_S_SUCCESS);
}

int PDMcheck_fmgr_copy (n_sano, n_cofilename, n_catalogno, n_itemno, 
                                               n_filenum, n_fileversion)
int n_sano;
char *n_cofilename;
int n_catalogno;
int n_itemno;
int n_filenum;
int n_fileversion;
{
  char  sql_str[1024];
char    *fn="PDMcheck_fmgr_copy";
 char    **data;
 MEMptr bufr = NULL;
       _PDMdebug(fn, "ENTER ..\n");

sql_str[0] = '\0';
sprintf(sql_str, "select n_co, n_copy, n_fileversion from nfmsafiles where n_sano = %d and  n_filename = '%s' and n_catalogno = %d and n_itemno = %d  and n_filenum = %d", n_sano, n_cofilename, n_catalogno,  n_itemno, n_filenum );


        status = SQLquery(sql_str, &bufr, 512);
         if(status != SQL_S_SUCCESS)
           {
              if (status == SQL_I_NO_ROWS_FOUND)
                 {
                       /* report that the file is to be moved */
                    MEMclose(&bufr);
       _PDMdebug(fn, "EXIT ..MOVE\n");
                       return(PDM_I_FILE_MOVE);
                     }
             }

            status = MEMbuild_array(bufr);
               if (status != MEM_S_SUCCESS)
                  {
                 _PDMdebug (fn, "MEM error  0x%.8x\n", status);
                    MEMclose(&bufr);
       _PDMdebug(fn, "EXIT ..\n");
                   return (PDM_E_BUILD_ARRAY);
                   }
            data = (char **) bufr->data_ptr;
        _PDMdebug(fn, "n_co %s, n_copy %s n_fileversion %s\n", data[0], data[1], 
                          data[2]);
           if(!strcmp(data[0], "Y") || !strcmp(data[0], "y"))
               {
                   MEMclose(&bufr);
       _PDMdebug(fn, "EXIT ..CHECKOUT\n");
                   return(PDM_I_CHECK_OUT);
               }
 
            /* if the file verision is later than the checked in verison */
            
            else if(atoi(data[2]) < n_fileversion)
                   {
                    MEMclose(&bufr);
       _PDMdebug(fn, "EXIT ..VERSION_UPDATE\n");
                   return (PDM_I_VERSION_UPDATE);
                    }
             else if(!strcmp(data[1], "Y") || !strcmp(data[1], "y"))
                   {
                    MEMclose(&bufr);
       _PDMdebug(fn, "EXIT ..NO_UPDATE\n");
                   return (PDM_I_NO_UPDATE);
                    }

        /* otherwise return a error */
       _PDMdebug(fn, "EXIT ..UNKNOWN\n");
         return(PDM_E_FAILURE);
}
    

int PDMcheck_fmgr_attach(n_sano, n_cofilename, n_catalogno, 
                          n_itemno, n_filenum, n_fileversion)
int n_sano;
char *n_cofilename;
int n_catalogno;
int n_itemno;
int n_filenum;
int n_fileversion;
{
  char  sql_str[1024];
char    *fn="PDMcheck_fmgr_attach";
 char    **data;
 MEMptr bufr = NULL;
       _PDMdebug(fn, "ENTER ..\n");

sql_str[0] = '\0';
sprintf(sql_str, "select n_co, n_copy, n_fileversion from nfmsafiles where n_sano = %d and  n_filename = '%s' and n_catalogno = %d and n_itemno = %d  and n_filenum = %d", n_sano, n_cofilename, n_catalogno,  n_itemno, n_filenum );


        status = SQLquery(sql_str, &bufr, 512);
         if(status != SQL_S_SUCCESS)
           {
              if (status == SQL_I_NO_ROWS_FOUND)
                 {
                       /* report that the file is to be moved */
                    MEMclose(&bufr);
       _PDMdebug(fn, "EXIT ..MOVE\n");
                       return(PDM_I_FILE_MOVE);
                     }
             }

            status = MEMbuild_array(bufr);
               if (status != MEM_S_SUCCESS)
                  {
                 _PDMdebug (fn, "MEM error  0x%.8x\n", status);
                    MEMclose(&bufr);
       _PDMdebug(fn, "EXIT ..\n");
                   return (PDM_E_BUILD_ARRAY);
                   }
            data = (char **) bufr->data_ptr;
        _PDMdebug(fn, "n_co %s, n_copy %s n_fileversion %s\n", data[0], data[1], 
                          data[2]);
           if(!strcmp(data[0], "Y") || !strcmp(data[0], "y"))
               {
                   MEMclose(&bufr);
       _PDMdebug(fn, "EXIT ..CHECKOUT\n");
                   return(PDM_I_CHECK_OUT);
               }
 
            /* if the file verision is later than the checked in verison */
            
            else if(atoi(data[2]) < n_fileversion)
                   {
                    MEMclose(&bufr);
       _PDMdebug(fn, "EXIT ..VERSION_UPDATE\n");
                   return (PDM_I_VERSION_UPDATE);
                    }
             else 
                  if(atoi(data[2]) == n_fileversion)
                   {
                    MEMclose(&bufr);
       _PDMdebug(fn, "EXIT ..REF_UPDATE\n");
                   return (PDM_I_REF_UPDATE);
                    }

        /* otherwise return a error */
       _PDMdebug(fn, "EXIT ..UNKNOWN\n");
         return(PDM_E_FAILURE);
}
    
 long PDMcreate_fmgr_bufr ( attr_list)
   MEMptr   *attr_list;
   {
      static char *fn = "PDMcreate_fmgr_bufr" ;
      long     status;

       PDMdebug("ENTER: PDMcreate_fmgr_bufr");

      status = MEMopen (attr_list, 1024);

      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }
         status = MEMwrite_format (*attr_list, "n_catno", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_itemnum", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_filenum", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_fileversion", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_cisano", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_cofilename", "char(14)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
/*
         status = MEMwrite_format (*attr_list, "p_parttype", "char(20)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
*/
         status = MEMwrite_format (*attr_list, "n_action", "char(20)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }

      _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
      return (NFM_S_SUCCESS); 
   }

int PDMupdate_fmgr_copy_file(sano, fmgr_bufr, copy_bufr)
int sano;
MEMptr fmgr_bufr;
MEMptr copy_bufr;
{
  char  sql_str[1024];
char    *fn="PDMupdate_fmgr_copy_file";
  char  **fmgr_data;
  int   i = 0, nxi =0;
  short attached = FALSE;
  int   ref_count = 0;
  int   catno = 0;
  int   itemno = 0;

 _PDMdebug(fn, "ENTER ...\n");    


       status = MEMbuild_array(fmgr_bufr);
               if (status != MEM_S_SUCCESS)
                  {
                 _PDMdebug (fn, "MEM error  0x%.8x\n", status);
                   return (PDM_E_BUILD_ARRAY);
                   }
           fmgr_data = (char **)fmgr_bufr->data_ptr;

     for(i=0; i < fmgr_bufr->rows; i++)
        {
           nxi = i * fmgr_bufr->columns;
            
/* 2/7/96 MJG - TR 139526084 */
/* MJG - change this to increment n_ref rather than n_copy for attachments */
           _PDMdebug(fn, "retrieving catno and itemno from fmgr_bufr\n");
           catno = atoi(fmgr_data[nxi]);
           itemno = atoi(fmgr_data[nxi+1]);

           status = PDMcheck_if_child_before_fmgr_update(copy_bufr, 
                                            catno, itemno,
                                            sano, 1, /* get ref_count */
                                            &attached, &ref_count);
           _PDMdebug(fn, "PDMcheck_if_child_before_fmgr_update returns <0x%.8x>\n", status);
           if (status != PDM_S_SUCCESS)
             return(status);

                 if(!strcmp(fmgr_data[nxi+6], "MOVE"))
                 {
                   _PDMdebug(fn, "entering case for MOVE\n");
                   sql_str[0] = '\0';
     if (!attached)
       sprintf(sql_str, "INSERT INTO NFMSAFILES (n_sano, n_filename, n_catalogno, n_itemno, n_filenum, n_fileversion, n_copy, n_cisano) VALUES(%d, '%s', %s, %s, %s, %s, '%s', %s)", sano, fmgr_data[nxi+5], fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2], fmgr_data[nxi+3], "Y", fmgr_data[nxi+4]);
     else
       sprintf(sql_str, "INSERT INTO NFMSAFILES (n_sano, n_filename, n_catalogno, n_itemno, n_filenum, n_fileversion, n_ref, n_cisano) VALUES(%d, '%s', %s, %s, %s, %s, %d, %s)", sano, fmgr_data[nxi+5], fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2], fmgr_data[nxi+3], ref_count, fmgr_data[nxi+4]);
            
                    status = SQLstmt(sql_str);
                     if (status != SQL_S_SUCCESS)
                     {
                       /* report a error */
                       return(PDM_E_SQL_STMT);
                     }
                       /* skip this part */
                       continue;
                   }
 
            /* if the file version is the same as  previous copy */
                 if(!strcmp(fmgr_data[nxi+6], "REF_UPDATE")) 
              {
                   _PDMdebug(fn, "entering case for REF_UPDATE\n");
                   sql_str[0] = '\0';
                   if (!attached)
                       sprintf(sql_str, "UPDATE NFMSAFILES SET  n_copy = 'Y' WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s ", sano, fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2], fmgr_data[nxi+3]);
                   else
                       sprintf(sql_str, "UPDATE NFMSAFILES SET  n_ref = %d WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s ", ref_count, sano, fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2], fmgr_data[nxi+3]);
                    status = SQLstmt(sql_str);
                     if (status != SQL_S_SUCCESS)
                     {
                       /* report a error */
                       return(PDM_E_SQL_STMT);
                     }
              }
            /* if the file version is later than  and  previous copy */
            else     if(!strcmp(fmgr_data[nxi+6], "VERSION_UPDATE"))
              {
                   _PDMdebug(fn, "entering case for VERSION_UPDATE\n");
                   sql_str[0] = '\0';
                   if (!attached)
                       sprintf(sql_str, "UPDATE NFMSAFILES SET n_fileversion = %s, n_copy = 'Y' WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s ", fmgr_data[nxi+3], sano, fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2]);
                   else
                       sprintf(sql_str, "UPDATE NFMSAFILES SET n_fileversion = %s, n_ref = %d WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s ", fmgr_data[nxi+3], ref_count, sano, fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2]);
                    status = SQLstmt(sql_str);
                     if (status != SQL_S_SUCCESS)
                     {
                       /* report a error */
                       return(PDM_E_SQL_STMT);
                     }
              }
            else     if(!strcmp(fmgr_data[nxi+6], "NO_UPDATE") || !strcmp(fmgr_data[nxi+6], "CHECKOUT") )
              {
                     _PDMdebug(fn, "case CHECKOUT OR NO_UPDATE\n");
                  if (!attached)
                     continue;
                  else
                     {
                      sql_str[0] = '\0';

                       sprintf(sql_str, "UPDATE NFMSAFILES SET n_fileversion = %s, n_ref = %d WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s ", fmgr_data[nxi+3], ref_count, sano, fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2], fmgr_data[nxi+3]);

                      status = SQLstmt(sql_str);
                       if (status != SQL_S_SUCCESS)
                       {
                         /* report a error */
                         return(PDM_E_SQL_STMT);
                       }
                     }
               }
               
            else     if(!strcmp(fmgr_data[nxi+6], "UPDATE_COPY"))
              {
                   _PDMdebug(fn, "entering case for UPDATE_COPY\n");
                   sql_str[0] = '\0';
                   if (!attached)
                       sprintf(sql_str, "UPDATE NFMSAFILES SET n_fileversion = %s, n_copy = 'Y' WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s ", fmgr_data[nxi+3], sano, fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2], fmgr_data[nxi+3]);
                   else
                       sprintf(sql_str, "UPDATE NFMSAFILES SET n_fileversion = %s, n_ref = %d WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s ", fmgr_data[nxi+3], ref_count, sano, fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2], fmgr_data[nxi+3]);
                    status = SQLstmt(sql_str);
                     if (status != SQL_S_SUCCESS)
                     {
                       /* report a error */
                       return(PDM_E_SQL_STMT);
                     }
               }
           else
               {
                   _PDMdebug(fn, "entering DEFAULT case\n");
                   sql_str[0] = '\0';
                   if (!attached)
sprintf(sql_str, "INSERT INTO NFMSAFILES (n_sano, n_filename, n_catalogno, n_itemno, n_filenum, n_fileversion, n_copy, n_cisano) VALUES(%d, '%s', %s, %s, %s, %s, '%s', %s)", sano, fmgr_data[nxi+5], fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2], fmgr_data[nxi+3], "Y", fmgr_data[nxi+4]);
                   else
sprintf(sql_str, "INSERT INTO NFMSAFILES (n_sano, n_filename, n_catalogno, n_itemno, n_filenum, n_fileversion, n_ref, n_cisano) VALUES(%d, '%s', %s, %s, %s, %s, %d, %s)", sano, fmgr_data[nxi+5], fmgr_data[nxi], fmgr_data[nxi+1], fmgr_data[nxi+2], fmgr_data[nxi+3], ref_count, fmgr_data[nxi+4]);
            
                    status = SQLstmt(sql_str);
                     if (status != SQL_S_SUCCESS)
                     {
                       /* report a error */
                       return(PDM_E_SQL_STMT);
                     }

              }

          }
          _PDMdebug(fn, "EXIT.....\n");
          return(PDM_S_SUCCESS);
}


int PDMupdate_fmgr_delete(sano, n_cofilename, n_catalogno, n_itemno, delete_bufr)
int sano;
char *n_cofilename;
int n_catalogno;
int n_itemno;
MEMptr delete_bufr;
{
  char  sql_str[1024];
char    *fn="PDMupdate_fmgr_delete";
 char    **data;
 MEMptr bufr = NULL;
 int    ref_count = 0;
 short  attached = FALSE;

   _PDMdebug(fn, "ENTER ..\n");

/* 2/7/96 MJG - TR 139526084 */
/* determine if part is in original buffer of files.  If the part is in the
   buffer, it is not an attachment.  Decrement n_ref for attachments, rather 
   that setting n_copy = N */

   status = PDMcheck_if_child_before_fmgr_update(delete_bufr, 
                        n_catalogno, n_itemno, sano, 
                        0, /* get n_ref */  &attached, &ref_count);
   _PDMdebug(fn, "PDMcheck_if_child_before_fmgr_update returns <0x%.8x>\n", status);

sql_str[0] = '\0';
sprintf(sql_str, "select n_co, n_copy, n_ref from nfmsafiles where n_sano = %d and  n_filename = '%s' and n_catalogno = %d and n_itemno = %d ", sano, n_cofilename, n_catalogno,  n_itemno );

        status = SQLquery(sql_str, &bufr, 512);
         if(status != SQL_S_SUCCESS)
           {
              if (status == SQL_I_NO_ROWS_FOUND)
                    {
                       /* report that the file is to be moved */
                      _PDMdebug(fn, "EXIT ..\n");
                       return(PDM_I_FILE_DELETE);
                     }
             }

            status = MEMbuild_array(bufr);
               if (status != MEM_S_SUCCESS)
                  {
                 _PDMdebug (fn, "MEM error  0x%.8x\n", status);
                    MEMclose(&bufr);
                   _PDMdebug(fn, "EXIT ..\n");
                   return (PDM_E_BUILD_ARRAY);
                   }
            data = (char **) bufr->data_ptr;
     _PDMdebug(fn, "n_co %s, n_copy %s n_ref %s\n", data[0], data[1], data[2]);
if (!attached)
  {
           _PDMdebug(fn, "processing parent/copied part\n");
           if(!strcmp(data[0], "Y") || !strcmp(data[0], "y"))
               {
                   sql_str[0] = '\0';
                       sprintf(sql_str, "UPDATE NFMSAFILES SET  n_copy = 'N' WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filename ='%s'", sano, n_catalogno, n_itemno, n_cofilename);
                    status = SQLstmt(sql_str);
                     if (status != SQL_S_SUCCESS)
                     {
                      if (status == SQL_E_MESSAGE)  {
                        _PDMdebug ("Retrying", "%s\n",  sql_str);
                        status = _PDMRetrySqlStmt (sql_str);
                        if (status != PDM_S_SUCCESS) {
                          _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                          return(PDM_E_SQL_STMT);
                         }
                        }
                       else {
                       /* report a error */
                          _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                          return(PDM_E_SQL_STMT);
                         }
                      }
                   _PDMdebug(fn, "EXIT ..\n");
                   return(PDM_I_CHECK_OUT);
               }
        else   if((!strcmp(data[2], "") || (atoi(data[2]) == 0)) && (!strcmp(data[0], "") || !strcmp(data[0], "N")))
               {
                   sql_str[0] = '\0';
                       sprintf(sql_str, "DELETE FROM NFMSAFILES WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filename ='%s'", sano, n_catalogno, n_itemno, n_cofilename);
                    status = SQLstmt(sql_str);
                     if (status != SQL_S_SUCCESS)
                     {
                       /* report a error */
                      if (status == SQL_E_MESSAGE)  {
                        _PDMdebug ("Retrying", "%s\n",  sql_str);
                        status = _PDMRetrySqlStmt (sql_str);
                        if (status != PDM_S_SUCCESS) {
                          _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                          return(PDM_E_SQL_STMT);
                         }
                        }
                       else {
                       /* report a error */
                          _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                          return(PDM_E_SQL_STMT);
                         }

                     }
                    _PDMdebug(fn, "EXIT ..\n");
                   return(PDM_I_FILE_DELETE);
               }
        else   
               {
                   sql_str[0] = '\0';
                     sprintf(sql_str, "UPDATE NFMSAFILES  SET n_copy = 'N' WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filename ='%s'", sano, n_catalogno, n_itemno, n_cofilename);
                    status = SQLstmt(sql_str);
                     if (status != SQL_S_SUCCESS)
                     {
                      if (status == SQL_E_MESSAGE)  {
                        _PDMdebug ("Retrying", "%s\n",  sql_str);
                        status = _PDMRetrySqlStmt (sql_str);
                        if (status != PDM_S_SUCCESS) {
                          _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                          return(PDM_E_SQL_STMT);
                         }
                        }
                       else {
                       /* report a error */
                          _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                          return(PDM_E_SQL_STMT);
                         }
                  
                       /* report a error */
                     }
                    _PDMdebug(fn, "EXIT ..\n");
                   return(PDM_I_COPY_UPDATE);
               }
  }
/* MJG - added else statement for reference files */
else
  {
           _PDMdebug(fn, "processing attached part\n");
           /* if CO = Y || COPY = Y */
           if((!strcmp(data[0], "Y") || !strcmp(data[0], "y")) ||
              (!strcmp(data[1], "Y") || !strcmp(data[1], "y")))
             {
             _PDMdebug(fn, "CO or COPY = Y:  decrement the ref_count\n");
             ref_count = atoi(data[2]);
             _PDMdebug(fn, "existing ref_count = %d\n", ref_count);
             --ref_count;
             _PDMdebug(fn, "new ref_count = %d\n", ref_count);

             sql_str[0] = '\0';
             sprintf(sql_str, "UPDATE NFMSAFILES SET  n_ref = %d WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filename ='%s'", ref_count, sano, n_catalogno, n_itemno, n_cofilename);

             status = SQLstmt(sql_str);
             if (status != SQL_S_SUCCESS)
               {
                if (status == SQL_E_MESSAGE)  
                  {
                  _PDMdebug ("Retrying", "%s\n",  sql_str);
                  status = _PDMRetrySqlStmt (sql_str);
                  if (status != PDM_S_SUCCESS) 
                    {
                    _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                    return(PDM_E_SQL_STMT);
                    }
                  }
                else 
                  {
                  /* report a error */
                  _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                  return(PDM_E_SQL_STMT);
                  }
                }
             _PDMdebug(fn, "EXIT ..\n");
             return(PDM_I_CHECK_OUT);
             }

           /* if ref_count = 1 && CO = N && COPY = N */
           else   if((!strcmp(data[2], "1")) && 
                     (!strcmp(data[0], "") || !strcmp(data[0], "N")) &&
                     (!strcmp(data[1], "") || !strcmp(data[1], "N")))
             {
             _PDMdebug(fn, "delete the row\n");

             sql_str[0] = '\0';
             sprintf(sql_str, "DELETE FROM NFMSAFILES WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filename ='%s'", sano, n_catalogno, n_itemno, n_cofilename);

             status = SQLstmt(sql_str);
             if (status != SQL_S_SUCCESS)
               {
               /* report a error */
               if (status == SQL_E_MESSAGE)  
                 {
                 _PDMdebug ("Retrying", "%s\n",  sql_str);
                 status = _PDMRetrySqlStmt (sql_str);
                 if (status != PDM_S_SUCCESS) 
                   {
                   _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                   return(PDM_E_SQL_STMT);
                   }
                 }
               else 
                 {
                /* report a error */
                 _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                 return(PDM_E_SQL_STMT);
                 }
               }
             _PDMdebug(fn, "EXIT ..\n");
             return(PDM_I_FILE_DELETE);
             }
           /* ref count > 1 */
           else   if(atoi(data[2]) > 1)
             {
             _PDMdebug(fn, "file is referenced:  decrement the ref_count\n");
             ref_count = atoi(data[2]);
             _PDMdebug(fn, "existing ref_count = %d\n", ref_count);
             --ref_count;
             _PDMdebug(fn, "new ref_count = %d\n", ref_count);

             sql_str[0] = '\0';
             sprintf(sql_str, "UPDATE NFMSAFILES SET  n_ref = %d WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filename ='%s'", ref_count, sano, n_catalogno, n_itemno, n_cofilename);

             status = SQLstmt(sql_str);
             if (status != SQL_S_SUCCESS)
               {
                if (status == SQL_E_MESSAGE)  
                  {
                  _PDMdebug ("Retrying", "%s\n",  sql_str);
                  status = _PDMRetrySqlStmt (sql_str);
                  if (status != PDM_S_SUCCESS) 
                    {
                    _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                    return(PDM_E_SQL_STMT);
                    }
                  }
                else 
                  {
                  /* report a error */
                  _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                  return(PDM_E_SQL_STMT);
                  }
                }
             _PDMdebug(fn, "EXIT ..\n");
             return(PDM_I_COPY_UPDATE);
             }
           else
             {
             _PDMdebug(fn, "default case\n");
             ref_count = atoi(data[2]);
             _PDMdebug(fn, "existing ref_count = %d\n", ref_count);
             if (ref_count > 0)
               --ref_count;
             _PDMdebug(fn, "new ref_count = %d\n", ref_count);

             sql_str[0] = '\0';
             sprintf(sql_str, "UPDATE NFMSAFILES SET  n_ref = %d WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filename ='%s'", ref_count, sano, n_catalogno, n_itemno, n_cofilename);

             status = SQLstmt(sql_str);
             if (status != SQL_S_SUCCESS)
               {
                if (status == SQL_E_MESSAGE)  
                  {
                  _PDMdebug ("Retrying", "%s\n",  sql_str);
                  status = _PDMRetrySqlStmt (sql_str);
                  if (status != PDM_S_SUCCESS) 
                    {
                    _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                    return(PDM_E_SQL_STMT);
                    }
                  }
                else 
                  {
                  /* report a error */
                  _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                  return(PDM_E_SQL_STMT);
                  }
                }
             _PDMdebug(fn, "EXIT ..\n");
             return(PDM_I_COPY_UPDATE);
             }
  }
}
    
    
long PDMcreate_delete_bufr ( attr_list)
MEMptr   *attr_list;
   {
      static char *fn = "PDMcreate_delete_bufr" ;
      long     status;

       PDMdebug("ENTER: PDMcreate_delete_bufr");
      status = MEMopen (attr_list, 1024);

      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }
         status = MEMwrite_format (*attr_list, "n_catalogno", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_itemno", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_catalogname", "char(20)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_itemname", "char(40)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_itemrev", "char(40)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_cofilename", "char(14)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_action", "char(20)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }

      _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
      return (PDM_S_SUCCESS); 
   }



int PDMdelete_filelist_pdu(file_list, delete_list)

MEMptr file_list;
MEMptr *delete_list;
{
   MEMptr   fmgr_bufr = NULL;
   int      n1, n2, n3, n4, n5, n6;
   int      n_sano;
   int      i, nxi;
   char     **data;
   char     **columns;

   PDMdebug("ENTER: PDMdelete_filelist_pdu\n"); 
/*
   status = PDMi_find_storageno(strg_bufr, &n_sano);
   if(status != PDM_S_SUCCESS)
   {
                sprintf(s, "PDMi_find_storageno failed status %d\n", status);
                PDMdebug(s);
                return(status);
   }
*/
   n_sano = storage->storage_no;


  status = MEMbuild_array(file_list);
   if(status != MEM_S_SUCCESS)
   {
                sprintf(s, "MEMbuild_array failed status %d\n", status);
                PDMdebug(s);
                return(PDM_E_BUILD_ARRAY);
   }
   columns = (char **) file_list->column_ptr;
   data = (char **) file_list->data_ptr;
   n1 = -1; n2 = -1; n3 = -1;
   n4 = -1; n5 = -1; n6 = -1;
   for(i=0;i<file_list->columns;i++)
   {
                if(!strcmp(columns[i], "n_catalogname"))  n1 = i;
                if(!strcmp(columns[i], "n_itemname"))     n2 = i;
                if(!strcmp(columns[i], "n_itemrev"))      n3 = i;
                if(!strcmp(columns[i], "n_catalogno"))    n4 = i;
                if(!strcmp(columns[i], "n_itemno"))       n5 = i;
                if(!strcmp(columns[i], "n_cofilename"))   n6 = i;
   }
   if(n1 == -1 || n2 == -1 || n3 == -1 ||
      n4 == -1 || n5 == -1 || n6 == -1 )
   {
                PDMdebug("Could not find cols in <file_list>\n");
                return(PDM_E_BUFFER_FORMAT);
   }
   status = PDMcr_chkin_fmgrbufr(&fmgr_bufr);
    if(status != PDM_S_SUCCESS)
      {
               MEMclose(&delete_list);
               MEMclose(&fmgr_bufr);
               MEMclose(&file_list);
                sprintf(s, "PDMi_find_partnum failed status %d\n", 
                status); PDMdebug(s);
                return(status);
        }
        
   for(i=0;i<file_list->rows;i++)
   {
       
       nxi = i * file_list->columns;
status = PDMfmgr_dereferencing(n_sano, atoi(data[nxi+n4]), 
                                   atoi(data[nxi+n5]), fmgr_bufr);
        if(status != PDM_S_SUCCESS)
           {
           MEMclose(&fmgr_bufr);
           sprintf(s, "PDMfmgr_dereferencing failed status %d\n", 
           status);   PDMdebug(s);
           return(status);
           }
  }
   if(PDMdebug_on)
     {
      MEMprint_buffer("fmgr_bufr ", fmgr_bufr, PDM_DEBUG_FILE);
     }

      status = PDMupdate_fmgr_chkin(n_sano, fmgr_bufr);
        if(status != PDM_S_SUCCESS)
           {
           MEMclose(&fmgr_bufr);
           sprintf(s, "PDMupdate_fmgr_chkin failed status %d\n", 
           status);   PDMdebug(s);
           return(status);
           }
     
      status = PDMpdu_delete_filelist(fmgr_bufr, delete_list);
        if(status != PDM_S_SUCCESS)
           {
           MEMclose(&fmgr_bufr);
           sprintf(s, "PDMupdate_fmgr_chkin failed status %d\n", 
           status);   PDMdebug(s);
           return(status);
           }

      MEMclose(&fmgr_bufr);
   if(PDMdebug_on)
     {
      MEMprint_buffer("delete_list ", *delete_list, PDM_DEBUG_FILE);
     }
   PDMdebug("EXIT: PDMdelete_filelist_pdu\n"); 
         return(PDM_S_SUCCESS);
}


int _PDMRetrySqlStmt (sql_str)
char  *sql_str;
{
 char     *fn = "_PDMRetrySqlStmt";
 int      try;
 int      RetryStatus;

  _PDMdebug (fn, "ENTER\n");

  RetryStatus = SQL_E_MESSAGE;
  
   try = 0;
   while (try < 60 && (RetryStatus == SQL_E_MESSAGE)) {
   PDUmessage (PDM_E_CON_ACCESS1, 's');
   sleep (2);
   RetryStatus = SQLstmt (sql_str);
   try += 2;
    _PDMdebug (fn, "Try[%d] -> Status [0x%.8x]\n", try, RetryStatus);
   }
   
   if (RetryStatus != SQL_S_SUCCESS)  {
     PDUmessage (PDM_E_CON_TRY_LATER, 's');
     _PDMdebug (fn, "SQLstmt failed RetryStatus %d\n", RetryStatus);
     RetryStatus = _PDMget_db_error (RetryStatus);
     return (RetryStatus);
     }
   
 _PDMdebug(fn, "EXIT\n"); 
 return (PDM_S_SUCCESS);
}
               
/* 2/7/96 MJG - TR 139526084 */

int PDMcheck_if_child_before_fmgr_update(orig_bufr, catno, itemno, sano, 
                                         get_ref, child, ref_count)
MEMptr	orig_bufr;
int	catno;
int     itemno;
int     sano;
short   get_ref;
int     *child;
int     *ref_count;
{
  int    status = PDM_S_SUCCESS;
  int    row = 0;
  int    catno_col = 0;
  int    itemno_col = 0;
  char   **data_row;
  char   *fn = "PDMcheck_if_child";
  char   refstr[5];
  char   sql_str[1024];
  short  found = FALSE;
  MEMptr bufr = NULL;

  _PDMdebug (fn, "Enter\n");

  status = MEMbuild_array(orig_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = PDM_S_SUCCESS;
  PDUsetup_buffer(orig_bufr, ROW, &data_row);
  PDUget_buffer_col(orig_bufr, "n_catalogno", &catno_col);
  PDUget_buffer_col(orig_bufr, "n_itemno", &itemno_col);

  for (row = 0; row < orig_bufr->rows; ++row)
    {
    if ((atoi(data_row[(orig_bufr->columns * row) + catno_col]) == catno) &&
        (atoi(data_row[(orig_bufr->columns * row) + itemno_col]) == itemno))
      {
      _PDMdebug (fn, "part is a parent; found in list\n");
      found = TRUE;
      break;
      }
    }
  if (found)
    *child = 0;
  else
    {
    _PDMdebug (fn, "part is a child; NOT in list\n");
    *child = 1;

    if (get_ref)
      {
      _PDMdebug (fn, "get the ref count\n");
      sql_str[0] = '\0';
  
      sprintf(sql_str, "select n_ref from nfmsafiles where n_sano = %d  and n_catalogno = %d and n_itemno = %d ", sano, catno, itemno );
  
      _PDMdebug(fn, "sql_str = <%s>\n", sql_str);
      status = SQLquery(sql_str, &bufr, 512);
      _PDMdebug(fn, "SQLquery returns <0x%.8x>\n", status);
      if (status == SQL_I_NO_ROWS_FOUND)
        {
        status = PDM_S_SUCCESS;
        _PDMdebug(fn, "Returning 1 for incremented ref count\n");
        *ref_count = 1;
        }
      else if (status == SQL_S_SUCCESS)
        {
        _PDMdebug(fn, "checking bufr for NULL\n");
        if (!bufr)
          {
          _PDMdebug(fn, "SQL bufr is NULL\n");
          return(PDM_E_ERROR_COPYING_FILES);
          }
  
        if (PDMdebug_on)
          MEMprint_buffer("ref bufr", bufr, PDM_DEBUG_FILE);
  
        status = MEMbuild_array(bufr);
        _PDMdebug(fn, "MEMbuild_array returns <0x%.8x>\n", status);
        if (status != MEM_S_SUCCESS)
          {
          if (bufr) MEMclose(&bufr);
          return(PDM_E_BUILD_BUFFER_ARRAY);
          }
  
        data_row = (char **) bufr->data_ptr;
        refstr[0] = '\0';
        strcpy(refstr, data_row[0]);
        _PDMdebug(fn, "refstr = <%s>\n", refstr);
  
        if ((refstr) && (strlen(refstr)))
          *ref_count = atoi(refstr);
        else
          *ref_count = 0;
        ++(*ref_count);
        _PDMdebug(fn, "ref_count = %d\n", *ref_count);
  
        if (bufr)
          {
          _PDMdebug(fn, "closing bufr\n");
          MEMclose(&bufr);
          bufr = NULL;
          }
        status = PDM_S_SUCCESS;
        }
      else if (status != SQL_S_SUCCESS)
        {
        if (bufr) MEMclose(&bufr);
        _PDMdebug(fn, "SQLquery failed\n");
        return(PDM_E_ERROR_COPYING_FILES);
        }
      }
    }

  return(status);
}
