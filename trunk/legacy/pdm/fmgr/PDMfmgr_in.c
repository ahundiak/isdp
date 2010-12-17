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

extern		int		PDMdebug_on;
extern		char	PDM_DEBUG_FILE[];
static 		long		status;
static		char		s[1024];
extern          struct PDUstorage *storage;
extern          PDMpart_ptr     PDMpart;
extern          PDMexec_ptr     PDMexec;

/*
	NOTES:
			During Checkin only concern is to leave the file(s)
    if it is currently being accessed as another attachment or 
    if it has been copied by the user explicitly.

	Modifies the n_fileco COLUMN in data_bufr

	RETURN CODES:
	
			PDM_S_SUCCESS

*/

int PDMchkin_file_transfers(n_pcatalogno, n_pitemno, 
                            n_cofilename, attach_bufr, fmgr_bufr)
int     n_pcatalogno;
int     n_pitemno;
char    *n_cofilename;
MEMptr	attach_bufr;
MEMptr	fmgr_bufr;
{
        char		*fn = "PDMchkin_file_transfers";
	char		**attach_data = NULL;
	char		**columns;
	int			i,  nx;
	int			n1 = -1 , n2 = -1;
	int			n_sano;
    
   _PDMdebug(fn, "ENTER:\n");

   /* find storage no */

   n_sano = storage->storage_no;
   if(attach_bufr != NULL && attach_bufr->rows > 0)
   {
   status = MEMbuild_array(attach_bufr);
   if(status != MEM_S_SUCCESS)
   {
         MEMclose(fmgr_bufr);
	  _PDMdebug(fn, "MEMbuild_array failed status %d\n", status);
	return(PDM_E_BUILD_ARRAY);
   }
   attach_data = (char **) attach_bufr->data_ptr;
   columns = (char **) attach_bufr->column_ptr;
   n1 = -1; n2 = -1;
   for(i=0;i<attach_bufr->columns;i++)
   {
		if(!strcmp(columns[i], "n_catalogno"))    n1 = i;
		if(!strcmp(columns[i], "n_itemno"))	     n2 = i;
   }
   if(n1 == -1 || n2 == -1 )
   {
		MEMclose(&attach_bufr);
		_PDMdebug(fn, "Could not find cols in <attach_bufr>\n");
		return(PDM_E_BUFFER_FORMAT);
   }
   }
	status = PDMcheck_fmgr_chkin(n_sano , n_pcatalogno, n_pitemno, 
			n_cofilename, fmgr_bufr);
	if(status != PDM_S_SUCCESS)
	{
	   _PDMdebug(fn, "PDMcheck_fmgr_chkin failed status %d\n", status);   
	   return(status);
	   }
        
   /* load file information based on n_itemno and n_catalogno */
    if(attach_bufr != NULL  && attach_data != NULL)
    {
   for(i=0;i<attach_bufr->rows;i++)
      {
    nx = i * attach_bufr->columns;
    status = PDMfmgr_dereferencing(n_sano, atoi(attach_data[nx+n1]), 
                                   atoi(attach_data[nx+n2]), fmgr_bufr);
	if(status != PDM_S_SUCCESS)
	   {
	   MEMclose(&fmgr_bufr);
	   _PDMdebug(fn, "PDMfmgr_dereferencing failed status %d\n", status);            return(status);
	   }
       }
     }
   if(PDMdebug_on)
	MEMprint_buffer("fmgr_bufr at exit", fmgr_bufr, PDM_DEBUG_FILE);
   _PDMdebug(fn, "EXIT:\n");
   return(PDM_S_SUCCESS);
}

int PDMprocess_parametric_files(attr_bufr, data_bufr, 
				parent_row, parent_row_offset)
MEMptr	attr_bufr;
MEMptr	data_bufr;
int	parent_row, parent_row_offset;
{
	char		**data;
	char		**columns;
	char		part_type[2];
	int		i, nx;
	int		n1 = -1 , n2 = -1 , n3 = -1;
	MEMptr		temp_buffer = NULL;
    
   PDMdebug("ENTER:PDMprocess_parametric_files\n");
/* APOGEE START */
   if(PDMdebug_on)
   {
        sprintf (s, " %s = %d & %s = %d \n", 
                   "parent_row", 
                    parent_row, 
                   "parent_row_offset", 
                    parent_row_offset);
        PDMdebug (s);
        temp_buffer = attr_bufr;
   }
/* APOGEE END */

   status = MEMbuild_array(data_bufr);
   if(status != MEM_S_SUCCESS)
   {
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   data = (char **) data_bufr->data_ptr;
   columns = (char **) data_bufr->column_ptr;
     n1 = -1; n2 = -1; n3 = -1;

   for(i=0;i<data_bufr->columns;i++)
   {
		if(!strcmp(columns[i], "n_itemno"))    n1 = i;
		if(!strcmp(columns[i], "n_catalogname"))    n3 = i;
		if(!strcmp(columns[i], "n_fileco"))	     n2 = i;
   }
   if(n1 == -1 || n2 == -1  || n3 == -1)
   {
		MEMclose(&data_bufr);
		PDMdebug("Could not find cols in <data_bufr>\n");
		return(PDM_E_BUFFER_FORMAT);
   }


   for(i=0;i<data_bufr->rows;i++) {
      /* added to accomodate NFM2.2 changes */
        if (i != parent_row ) {
		nx = i * data_bufr->columns;
                status = PDMfind_part_type(data[nx+n3], atol(data[nx+n1]), part_type);
	         if(status != PDM_S_SUCCESS) 
	          {
			sprintf(s, "PDMfind_part_type failed status %d\n", 
			status); PDMdebug(s);
			return(status);
                   }
				if((!strcmp(part_type, "P")) ||
				(!strcmp(part_type, "p"))) 
				{
				status = MEMwrite_data(data_bufr, "N", i+1, n2+1);
				if(status != MEM_S_SUCCESS)
					{
						MEMclose(&data_bufr);
						sprintf(s, "MEMwrite_data failed status %d\n", 
						status); PDMdebug(s);
						return(PDM_E_WRITE_COLUMN);
					}
				}
               }/* added to accomodate NFM2.2 changes */
   }
   

   PDMdebug("EXIT:PDMprocess parametric files\n");
   return(PDM_S_SUCCESS);
}

int PDMupdate_fmgr_chkin(sano, fmgr_bufr)
int sano;
MEMptr fmgr_bufr;
{
  char  sql_str[1024];
  char    *fn="PDMupdate_fmgr_chkin";
  char  **fmgr_data;
  int   i = 0, nxi =0, ref_count;
  int   i_filename = 1, i_catalogno = 2, i_itemno = 3;
  int   i_filenum = 4, i_fileversion = 5, i_co = 6, i_copy = 7;
  int   i_ref = 8, i_action = 9;

 _PDMdebug(fn, "ENTER ...\n");    


       status = MEMbuild_array(fmgr_bufr);
       if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEM error  0x%.8x\n", status);
         return (PDM_E_BUILD_ARRAY);
         }
       fmgr_data = (char **)fmgr_bufr->data_ptr;

     for(i=0; i < fmgr_bufr->rows; i++) {
       nxi = i * fmgr_bufr->columns;
       sql_str[0] = '\0'; 
       /* if the n_co has to be updated */
       if(!strcmp(fmgr_data[nxi+i_action], "UPDATE_CO")) {
         sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %s, n_copy = '%s', n_co = 'N'  WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", fmgr_data[nxi+i_ref], fmgr_data[nxi+i_copy], sano, fmgr_data[nxi+i_catalogno], fmgr_data[nxi+i_itemno], fmgr_data[nxi+i_filenum], fmgr_data[nxi+i_fileversion], fmgr_data[nxi+i_filename]);
                  }
        else if(!strcmp(fmgr_data[nxi+i_action], "UPDATE_CO_N")) {
                       sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %s, n_copy = '%s', n_co = 'N'  WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", fmgr_data[nxi+i_ref], fmgr_data[nxi+i_copy], sano, fmgr_data[nxi+i_catalogno], fmgr_data[nxi+i_itemno], fmgr_data[nxi+i_filenum], fmgr_data[nxi+i_fileversion], fmgr_data[nxi+i_filename]);
                  }
         else if(!strcmp(fmgr_data[nxi+i_action], "UPDATE_REF"))
           {
           _PDMdebug(fn, "sql_str for UPDATE_REF = <%s>\n", sql_str);
           ref_count = atoi(fmgr_data[nxi+i_ref]);
           if(ref_count != 0) ref_count = ref_count - 1;   
           sprintf(sql_str, "UPDATE NFMSAFILES SET n_ref = %d, n_copy = '%s', n_co = '%s'  WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", ref_count, fmgr_data[nxi+i_copy], fmgr_data[nxi+i_co], sano, fmgr_data[nxi+i_catalogno], fmgr_data[nxi+i_itemno], fmgr_data[nxi+i_filenum], fmgr_data[nxi+i_fileversion], fmgr_data[nxi+i_filename]);
                  }
           else if(!strcmp(fmgr_data[nxi+i_action], "DELETE"))
                 {
           sprintf(sql_str, "DELETE FROM  NFMSAFILES  WHERE n_sano = %d AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", sano, fmgr_data[nxi+i_catalogno], fmgr_data[nxi+i_itemno], fmgr_data[nxi+i_filenum], fmgr_data[nxi+i_fileversion], fmgr_data[nxi+i_filename]);
                  }
           else if(!strcmp(fmgr_data[nxi+i_action], "DO_NOTHING") ||
           !strcmp(fmgr_data[nxi+i_action], "NO_UPDATE"))
                 {
                      continue;
                  }
            else continue;
                 status = SQLstmt(sql_str);
                 if(status != SQL_S_SUCCESS)
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
         _PDMdebug (fn, "SQLstmt  0x%.8x\n", status);
         _PDMdebug (fn, "catno %s itemno %s sano %d filenum %s filename %s fileversion %s\n", fmgr_data[nxi+i_catalogno], fmgr_data[nxi+i_itemno], fmgr_data[nxi+i_filenum], fmgr_data[nxi+i_filename], fmgr_data[nxi+i_fileversion]);
                    }
                }
         }
          _PDMdebug(fn, "EXIT.....\n");
          return(PDM_S_SUCCESS);
}


int PDMcheck_fmgr_chkin(n_sano, n_catalogno, n_itemno, 
                         n_cofilename, fmgr_bufr)
int n_sano;
int n_catalogno;
int n_itemno;
char *n_cofilename;
MEMptr fmgr_bufr;
{
  char  sql_str[1024], mem_str[512];
  static char    *fn="PDMcheck_fmgr_chkin";
 char    **data, update_str[20];
 int     mul, mulx;
 MEMptr bufr = NULL;
       _PDMdebug(fn, "ENTER ..\n");

sql_str[0] = '\0';

sprintf(sql_str, "select n_co, n_copy, n_fileversion, n_ref, n_filename, n_filenum from nfmsafiles where n_sano = %d  and n_catalogno = %d and n_itemno = %d ", n_sano, n_catalogno, n_itemno );


        status = SQLquery(sql_str, &bufr, 512);
         if(status != SQL_S_SUCCESS)
           {
              if (status == SQL_I_NO_ROWS_FOUND)
                 {
                       /* report that the files to be moved */
                    MEMclose(&bufr);
                  mem_str[0] = '\0';
  sprintf(mem_str, "%d\1%s\1%d\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1", n_sano, n_cofilename, n_catalogno, n_itemno, "", "", "", "", "", "NO_UPDATE");
    if(PDMdebug_on)
   _PDMdebug(fn, "mem_str %s\n", mem_str);
                  status = MEMwrite(fmgr_bufr, mem_str);
                    if (status != MEM_S_SUCCESS)
                     {
                  _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
                     return (NFM_E_MEM);
                      }

                       PDMdebug("No filemgr update is needed for this item\n");
                      _PDMdebug(fn, "EXIT ..\n");
                       return(PDM_S_SUCCESS);
                     }
                  else return(PDM_E_SQL_QUERY);
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

                  update_str[0] = '\0';
         for(mul = 0; mul < bufr->rows ; mul++)
           {
              mulx = mul * bufr->columns;
           if((!strcmp(data[mulx+0], "Y") || !strcmp(data[mulx+0], "y"))
           && (!strcmp(data[mulx+1], "Y") || !strcmp(data[mulx+1], "y"))
           && (!strcmp(data[mulx+3], "")))
               {
                    strcpy(update_str, "UPDATE_CO");
                  }
           else if((!strcmp(data[mulx+0], "Y") || !strcmp(data[mulx+0], "y"))
           && (!strcmp(data[mulx+1], "Y") || !strcmp(data[mulx+1], "y"))
           && (atoi(data[mulx+3]) > 0 ))
               {
                    strcpy(update_str, "UPDATE_CO");
               }
           else if((!strcmp(data[mulx+0], "Y") || !strcmp(data[mulx+0], "y"))
           && (!strcmp(data[mulx+1], "Y") || !strcmp(data[mulx+1], "y"))
           && (atoi(data[mulx+3]) == 0 ))
               {
                    strcpy(update_str, "UPDATE_CO_N");
               }
    else if((!strcmp(data[mulx+0], "Y") || !strcmp(data[mulx+0], "y") ) && (!strcmp(data[mulx+1], "n") || !strcmp(data[mulx+1], "N") || !strcmp(data[mulx+1], "")) && (!strcmp(data[mulx+3], "")))
               {
                    strcpy(update_str, "DELETE");
          /* Checked out and not referenced or copied - DELETE */
               }
    else if((!strcmp(data[mulx+0], "Y") || !strcmp(data[mulx+0], "y") ) && (!strcmp(data[mulx+1], "n") || !strcmp(data[mulx+1], "N") || !strcmp(data[mulx+1], "")) && (atoi(data[mulx+3]) == 0))
               {
                    strcpy(update_str, "DELETE");
          /* Checked out and not referenced or copied - DELETE */
               }
    else if((!strcmp(data[mulx+0], "Y") || !strcmp(data[mulx+0], "y") ) && (!strcmp(data[mulx+1], "") || !strcmp(data[mulx+1], "N")) && (atoi(data[mulx+3]) > 0))
               {
                    strcpy(update_str, "UPDATE_CO");
          /* Checked out and  referenced and not copied - DELETE */
               }
    else if((!strcmp(data[mulx+0], "Y") || !strcmp(data[mulx+0], "y") ) && !strcmp(data[mulx+1], "") && (atoi(data[mulx+3]) == 0))
               {
                    strcpy(update_str, "DELETE");
          /* Checked out and not referenced or copied - DELETE */
               }
    if(PDMdebug_on)
   _PDMdebug(fn, "n_co %s, n_copy %s n_ref %s n_filename %s update_str %s\n", data[mulx+0], data[mulx+1], data[mulx+3], data[mulx+4], update_str);
                  mem_str[0] = '\0';
  sprintf(mem_str, "%d\1%s\1%d\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1", n_sano, data[mulx+4], n_catalogno, n_itemno, data[mulx+5], data[mulx+2], data[mulx], data[mulx+1], data[mulx+3], update_str);
    if(PDMdebug_on)
   _PDMdebug(fn, "mem_str %s\n", mem_str);
                  status = MEMwrite(fmgr_bufr, mem_str);
                    if (status != MEM_S_SUCCESS)
                     {
                  _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
                     return (NFM_E_MEM);
                      }
           }
            MEMclose(&bufr);
 
       _PDMdebug(fn, "EXIT ..\n");
         return(PDM_S_SUCCESS);
}

int PDMfmgr_dereferencing(n_sano, n_catalogno, n_itemno, fmgr_bufr)
int n_sano;
int n_catalogno;
int n_itemno;
MEMptr fmgr_bufr;
{
  char  sql_str[1024], mem_str[512];
  static char    *fn="PDMfmgr_dereferencing";
 char    **data, update_str[20];
 int     mul, mulx;
 MEMptr bufr = NULL;
       _PDMdebug(fn, "ENTER ..\n");

sql_str[0] = '\0';

sprintf(sql_str, "select n_co, n_copy, n_fileversion, n_ref, n_filename, n_filenum from nfmsafiles where n_sano = %d  and n_catalogno = %d and n_itemno = %d ", n_sano, n_catalogno, n_itemno );


        status = SQLquery(sql_str, &bufr, 512);
         if(status != SQL_S_SUCCESS) {
           MEMclose(&bufr);
           if (status == SQL_I_NO_ROWS_FOUND) {
              /* report that the files to be moved */
              PDMdebug("No filemgr update is needed for this item\n");
              _PDMdebug(fn, "EXIT ..\n");
              return(PDM_S_SUCCESS);
              }
           else  {
            status = _PDMget_db_error (status);
            return (status);
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

/* Fix added for the following scenario:
     If the child is same as the assy (attached via BG attachment);
     then, it is going to be decremented once only instead once
     for assy and current child. 
   One way to fix is set the child row n_co to 'N'. 
 */

/* This needs modification since the parent part information may
   not be stored in the PDMpart structure... */
 
    status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
            PDMexec->revision);
    if (status != PDM_S_SUCCESS) {
        _PDMdebug (fn, "PDMload_part_info failed status %d\n", status);
        status = NFMstart_transaction (0);
        if (status != NFM_S_SUCCESS) {
            _PDMdebug (fn, "Start Transaction : status = <0x%.8x>\n",
                    status);
            return (status);
            }
        return (PDM_E_COULD_NOT_LOAD_PART_INFO);
        }
 
   
  _PDMdebug (fn, "Assy cat[%d] item[%d]\n", PDMpart.n_catalogno, 
                                            PDMpart.n_itemno);
  if ( (n_catalogno == PDMpart.n_catalogno) &&
                   (n_itemno == PDMpart.n_itemno) ) { 
    _PDMdebug (fn, "Child is same as assy: cat[%d], item[%d]\n",    
                                     n_catalogno, n_itemno);
    for(mul = 0; mul < bufr->rows ; mul++) {
       mulx = mul * bufr->columns;
       update_str[0] = '\0';
       
       status = MEMwrite_data(bufr, "N", mul+1, 1);
       if(status != MEM_S_SUCCESS) {
         MEMclose(&bufr);
         _PDMdebug (fn, "MEMwrite_data failed status %d\n", status); 
         return(PDM_E_WRITE_COLUMN);
         }
       }

    status = MEMbuild_array(bufr);
    if (status != MEM_S_SUCCESS) {
      _PDMdebug (fn, "MEM error  0x%.8x\n", status);
      MEMclose(&bufr);
      _PDMdebug(fn, "MEMbuild_array Failed : 0x%.8x ..\n", status);
      return (PDM_E_BUILD_ARRAY);
      }

    if (PDMdebug_on) {
                 MEMprint_buffer("LFM Bufr", bufr, PDM_DEBUG_FILE);
          }

    data = (char **) bufr->data_ptr;
    }


    for(mul = 0; mul < bufr->rows ; mul++)
           {
              mulx = mul * bufr->columns;
               update_str[0] = '\0';

           if((!strcmp(data[mulx+0], "Y") || !strcmp(data[mulx+0], "y"))
           && (!strcmp(data[mulx+1], "Y") || !strcmp(data[mulx+1], "y"))
           && (!strcmp(data[mulx+3], "")))
               {
                 /* fmgr-case 2 */
                    /* Checked out and  copied  - DO_NOTHING*/
                     strcpy(update_str, "DO_NOTHING");
                  }

/* Added to support a part is a child of the assy being checkedin,
   and also is checked out _and_ copied to local already. Th
   n_copy:n_co:n_ref :: Y:Y:>0 MaC  021794 */

     else if( (!strcmp(data[mulx+0], "Y") || !strcmp(data[mulx+0], "y"))
             && (!strcmp(data[mulx+1], "Y") || !strcmp(data[mulx+1], "y"))
             && (atoi(data[mulx+3]) > 0))
               {
                 /* fmgr-case ??? */
                    /* Checked out, copied  AND referenced  - UPDATE_REF*/
                     strcpy(update_str, "UPDATE_REF");
                  }
           else if ((!strcmp(data[mulx+0], "Y") || !strcmp(data[mulx+0], "y"))
           && (!strcmp(data[mulx+1], "") || !strcmp(data[mulx+1], "N"))
           && (!strcmp(data[mulx+3], "")))
               {
                 /* fmgr-case 1 */
                    /* Just Checked out  - DO_NOTHING*/
                     strcpy(update_str, "DO_NOTHING");
                  }
         else  if((!strcmp(data[mulx+0], "Y") || !strcmp(data[mulx+0], "y"))
           && (!strcmp(data[mulx+1], "") || !strcmp(data[mulx+1], "N"))
           && (atoi(data[mulx+3]) > 0))
               {
                 /* fmgr-case 3 */
                    /* Checked out and   referenced  - UPDATE_REF*/
                     strcpy(update_str, "UPDATE_REF");
               _PDMdebug(fn, "case 3 - UPDATE_REF\n");
               }
           else if((!strcmp(data[mulx+0], "") || !strcmp(data[mulx+0], "N"))
           && (!strcmp(data[mulx+1], "") || !strcmp(data[mulx+1], "N"))
           && (atoi(data[mulx+3]) > 0 ))
               {
                /* fmgr case-7 */
          /* Just  referenced - UPDATE_CO*/
                    if(atoi(data[mulx+3]) == 1) strcpy(update_str, "DELETE");
               else  strcpy(update_str, "UPDATE_REF");
               }
           else if((!strcmp(data[mulx+0], "") || !strcmp(data[mulx+0], "N"))
           && (!strcmp(data[mulx+1], "Y") || !strcmp(data[mulx+1], "y"))
           && (atoi(data[mulx+3]) > 0 ))
               {
                /* fmgr case-9 */
          /* Referenced and copied - UPDATE_REF*/
                 strcpy(update_str, "UPDATE_REF");
               }
           else if((!strcmp(data[mulx+0], "Y") || !strcmp(data[mulx+0], "y"))
           && (!strcmp(data[mulx+1], "") || !strcmp(data[mulx+1], "N"))
           && (atoi(data[mulx+3]) > 0 ))
               {
                /* fmgr case-8 */
          /* chkout and referenced - UPDATE_REF*/
                 strcpy(update_str, "UPDATE_REF");
               _PDMdebug(fn, "case 3 - UPDATE_REF\n");
               }
    else if((!strcmp(data[mulx+0], "N") || !strcmp(data[mulx+0], "") ) && (!strcmp(data[mulx+1], "y") || !strcmp(data[mulx+1], "Y")) && (!strcmp(data[mulx+3], "") ))
               {
                 /* fmgr case-4 */
          /* Just copy - DO_NOTHING */
                 strcpy(update_str, "DO_NOTHING");
               }
    else if((!strcmp(data[mulx+0], "Y") || !strcmp(data[mulx+0], "y") ) && (!strcmp(data[mulx+1], "y") || !strcmp(data[mulx+1], "Y")) && (!strcmp(data[mulx+3], "") ))
               {
                 /* fmgr case-5  DO_NOTHING*/
                 strcpy(update_str, "DO_NOTHING");
               }
    else if((!strcmp(data[mulx+0], "") || !strcmp(data[mulx+0], "N") ) && (!strcmp(data[mulx+1], "y") || !strcmp(data[mulx+1], "Y")) && (atoi(data[mulx+3]) > 0))
               {
                 /* fmgr case-6 UPDATE_REF*/
          /* Copy and referenced */
                 strcpy(update_str, "UPDATE_REF");
               }
    if(PDMdebug_on)
   _PDMdebug(fn, "n_co %s, n_copy %s n_ref %s n_filename %s update_str %s\n", data[mulx+0], data[mulx+1], data[mulx+3], data[mulx+4], update_str);
                  mem_str[0] = '\0';
  sprintf(mem_str, "%d\1%s\1%d\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1", n_sano, data[mulx+4], n_catalogno, n_itemno, data[mulx+5], data[mulx+2], data[mulx], data[mulx+1], data[mulx+3], update_str);
    if(PDMdebug_on)
   _PDMdebug(fn, "mem_str %s\n", mem_str);
                  status = MEMwrite(fmgr_bufr, mem_str);
                    if (status != MEM_S_SUCCESS)
                     {
                  _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
                     return (NFM_E_MEM);
                      }
           }
            MEMclose(&bufr);
 
       _PDMdebug(fn, "EXIT ..\n");
         return(PDM_S_SUCCESS);
}
    
int PDMcr_chkin_fmgrbufr ( attr_list)
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
         status = MEMwrite_format (*attr_list, "n_sano", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_filename", "char(128)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
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
         status = MEMwrite_format (*attr_list, "n_co", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_copy", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fn, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_ref", "integer");
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
    
long PDMpdu_delete_filelist ( fmgr_bufr, attr_list)
MEMptr   fmgr_bufr;
MEMptr   *attr_list;
{
      static char *fn = "PDMpdu_delete_filelist" ;
      char   **fmgr_data;
      char    mem_str[128];
  int   i = 0, nxi =0;
  int   i_filename = 1;
  int   i_action = 9;
      long     status;

       PDMdebug("ENTER: PDMpdu_delete_filelist\n");

       if(fmgr_bufr != NULL) {
         status = MEMbuild_array(fmgr_bufr);
         if (status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEM error  0x%.8x\n", status);
           return (PDM_E_BUILD_ARRAY);
           }
         fmgr_data = (char **)fmgr_bufr->data_ptr;
         for(i=0; i < fmgr_bufr->rows; i++) {
           nxi = i * fmgr_bufr->columns;
           if (!strcmp(fmgr_data[nxi+i_action], "DELETE") 
                    || !strcmp(fmgr_data[nxi+i_action], "NO_UPDATE")) {
             mem_str[0] = '\0';
             sprintf(mem_str, "%s\1", fmgr_data[nxi+i_filename]);
             _PDMdebug(fn, "%s\n", mem_str);
             status = MEMwrite(*attr_list, mem_str); 
             if (status != MEM_S_SUCCESS) {
                 _PDMdebug (fn, "MEM error  0x%.8x\n", status);
                 return (NFM_E_MEM);
                 }
             if (PDMdebug_on)
                 MEMprint_buffer("filelist", 
				 *attr_list, PDM_DEBUG_FILE);
       		}
              }
           }

      _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
      return (PDM_S_SUCCESS); 
}
