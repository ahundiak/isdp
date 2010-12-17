#include                <stdio.h>
#include                "SQLerrordef.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "NFMapi.h"
#include                "NFMschema.h"
#include                "MEMstruct.h"
#include                "NFMitems.h"
#include                "NFMstruct.h"
#include                "PDMdbs_err.h"
#include                "PDUerror.h"
#include                "PDUstorage.h"
#include                "dbadev.h"
#include                "rMRPstr.h"
#include                "MRPmessage.h"
#include                "PDMproto.h"


#include                        "PDMbom_strct.h"
static long                     status;
/*static char                   s[1024];*/
extern int                      PDMdebug_on;
extern char                     PDM_DEBUG_FILE[];
extern PDMexec_ptr              PDMexec;
extern PDMpart_ptr              PDMpart;
extern struct NFMglobal_st      NFMglobal;
extern struct   PDUstorage *storage;

void _PDMprint_setmember (name, mem)
char	*name;
struct NFMset_member	*mem;
{
char	s[2096];
s[0] = '\0';
  sprintf (s, 
" %s->level[%d], %s->citno[%d],  %s->type[%s],\n\
  %s->cat_no[%d], %s->cat_name[%s], \n\
  %s->item_no[%d], %s->item_name[%s], %s->item_rev[%s], \n\
  %s->set_indicator[%s], %s->file_co[%s], \n\
  %s->ci_filename  [%s], %s->ci_sano[%d], %s->co_sano[%d], \n\
  %s->co_filename  [%s], %s->move[%d], %s->next[%lx]\n", 

  name, mem->level,
  name, mem->citno,
  name, mem->type,
  name, mem->cat_no,
  name, mem->cat_name,
  name, mem->item_no,
  name, mem->item_name,
  name, mem->item_rev,
  name, mem->set_indicator,
  name, mem->file_co,
  name, mem->ci_filename,
  name, mem->ci_sano,
  name, mem->co_sano,
  name, mem->co_filename,
  name, mem->move,
  name, mem->next);
PDMdebug (s);
}

void _PDMprint_fileentry (name, mem)
char	*name;
struct NFMfile_entry	*mem;
{
/*char	*fn = "_PDMprint_fileentry";*/
char	s[2096];
s[0] = '\0';

/* #ifndef sparc */
/* Added support for SGI port MaC */
#if ! (defined (sparc) && defined (__sgi) && defined (__Sol2__))


sprintf (s, " %s->cisano[%d], %s->cosano[%d], %s->file_no[%d],\n\
  %s->fileversion[%d], %s->filenum[%d], %s->transfer_status[%d],\n\
  %s->cidate[%s], %s->codate[%s], %s->cofilename[%s],\n\
  %s->cifilename[%s], %s->nfs[%s] \n",
  name, mem->cisano, name, mem->cosano, name, mem->file_no, name, 
  mem->fileversion, name, mem->filenum, name, mem->transfer_status,
name, mem->cidate, name, mem->codate, name, mem->cofilename, 
  name, mem->cifilename, name, mem->nfs);

#else

sprintf (s, " %s->cisano[%d], %s->cosano[%d], %s->file_no[%d],\n\
  %s->fileversion[%d], %s->filenum[%d], %s->transfer_status[%d],\n\
  %s->cidate[%s], %s->codate[%s], %s->cofilename[%s],\n\
  %s->cifilename[%s], %s->nfs[%s] \n",
  name, mem->cisano, name, mem->cosano, name, mem->file_no, name, 
  mem->fileversion, name, mem->filenum, name, mem->transfer_status,
name, mem->cidate, name, mem->codate, name, mem->cofilename, 
  name, mem->cifilename, name, mem->nfs);

#endif

PDMdebug (s);
}

void _PDMprint_itementry (name, mem)
char	*name;
struct NFMitem_entry	*mem;
{
char	s[2096];
s[0] = '\0';
/*char	*fn = "_PDMprint_itementry";*/
sprintf (s, " %s->cat_no[%d], %s->item_no[%d], %s->files[%d],\n\
  %s->cat_name[%s], %s->item_name[%s], %s->item_rev[%s], %s->status [%s]\n",
  name, mem->cat_no, name, mem->item_no, name, mem->files, name, mem->cat_name, 
      name, mem->item_name, name, mem->item_rev, name, mem->status );
PDMdebug (s);
}

void _PDMprint_all_setmember (name, mem)
char	*name;
struct NFMset_member	*mem;
{
char	s[2096];
s[0] = '\0';
  sprintf (s, 
" %s->level[%d], %s->citno[%d], \n\
  %s->cat_no[%d], %s->type[%s], %s->cat_name[%s], \n\
  %s->item_no[%d], %s->file_status[%s], %s->archive_state[%s], \n\
  %s->item_name[%s], %s->item_rev[%s], %s->lock[%s], \n\
  %s->version_limit[%d], %s->set_indicator[%s], \n\
  %s->file_class[%s], %s->file_type[%s], %s->file_co[%s], \n\
  %s->file_version[%d], %s->pending_flag[%s], %s->file_size[%d], \n\
  %s->ci_filename[%s], %s->ci_sano[%d], %s->co_sano[%d], \n\
  %s->co_filename[%s], %s->move[%d], %s->flag[%d] \n", 
  name, mem->level,
  name, mem->citno,
  name, mem->cat_no,
  name, mem->type,
  name, mem->cat_name,
  name, mem->item_no,
  name, mem->file_status,
  name, mem->archive_state,
  name, mem->item_name,
  name, mem->item_rev,
  name, mem->lock,
  name, mem->version_limit,
  name, mem->set_indicator,
  name, mem->file_class,
  name, mem->file_type,
  name, mem->file_co,
  name, mem->file_version,
  name, mem->pending_flag,
  name, mem->file_size,
  name, mem->ci_filename,
  name, mem->ci_sano,
  name, mem->co_sano,
  name, mem->co_filename,
  name, mem->move,
  name, mem->flag);  

PDMdebug (s);
 
}


void PDMprint_storage_area()
{
        _PDMdebug("", "STORAGE AREA\n");
        _PDMdebug("", "storage->storage_no    = <%d>\n", storage->storage_no);
        _PDMdebug("", "storage->storage_name  = <%s>\n", storage->storage_name);
        _PDMdebug("", "storage->node_name     = <%s>\n", storage->node_name);
        _PDMdebug("", "storage->user_name     = <%s>\n", storage->user_name);
/* Passwords should not be printed in the debug files. MaC 070894
        _PDMdebug("", "storage->passwd        = <%s>\n", storage->passwd);
*/
        _PDMdebug("", "storage->path_name     = <%s>\n", storage->path_name);
}



int _PDMget_cofilename_cprfnum (catalog, itemno, filenum, cofilename)
char	*catalog, *itemno, *filenum, *cofilename;
{
  char  *fn = "_PDMget_cofilename_cprfnum";
  char  ** data = NULL;
  MEMptr	tmp_bufr = NULL;
  char		sql_str[1024];

  _PDMdebug(fn, "Enter\n");
  sql_str [0] = '\0';
  sprintf (sql_str, 
   "SELECT n_cofilename FROM f_%s WHERE n_itemnum = %s AND n_filenum = %s", 
    catalog, itemno, filenum);

   status = SQLquery(sql_str, &tmp_bufr, 1024);
   if(status != SQL_S_SUCCESS) {
	MEMclose(&tmp_bufr);
	if(status == SQL_I_NO_ROWS_FOUND) return(PDM_I_NO_FILES_FOUND);
        _PDMdebug(fn, "%s %d\n", "SQLquery failed ", status);
	return(PDM_E_SQL_QUERY);
   }
	
   status = MEMbuild_array(tmp_bufr);
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
	return(PDM_E_BUILD_ARRAY);
   }
   data = (char **) tmp_bufr->data_ptr;
 
   cofilename[0] = '\0';
   strcpy (cofilename, data[0]);
   _PDMdebug (fn, "cofilename[%s]\n", cofilename);
    MEMclose(&tmp_bufr);
  
  _PDMdebug(fn, "Exit\n");
  return (PDM_S_SUCCESS);
}




/* This function gets the catalog/partnum/rev given the filename.
   This is used by PDU to determine whether the part in question
   had ever been checked in. If it was, then for the part to be
   local, has to have an entry in lfm. MaC 102893 */


int PDMGetPartInfoGivenFileName (filename, catalog, partnum, revision)
char	*catalog, *partnum, *revision, *filename;
{
  char  *fn = "PDMGetPartInfoGivenFileName";
  char  ** data = NULL;
  MEMptr	tmp_bufr = NULL;
  char		sql_str[1024];
  char		desc[241];
  int		catalogno, itemno;

  _PDMdebug(fn, "Enter\n");
  sql_str [0] = '\0';
  sprintf (sql_str, 
  "SELECT %s  FROM %s WHERE n_filename = '%s' AND n_sano = %d ", 
    "n_catalogno, n_itemno ",
    "nfmsafiles ", filename, storage->storage_no);

   status = SQLquery(sql_str, &tmp_bufr, 1024);
   if(status != SQL_S_SUCCESS) {
	MEMclose(&tmp_bufr);
	if(status == SQL_I_NO_ROWS_FOUND) {
	/*if(status == SQL_I_NO_ROWS_FOUND) return(PDM_LFM_ENTRY_NOT_FOUND);*/
            _PDMdebug (fn, "No entries found: File is not local\n");
            return(PDM_I_NO_FILES_FOUND);
            }
        _PDMdebug(fn, "%s %d\n", "SQLquery failed ", status);
	return(PDM_E_SQL_QUERY);
       }
	
   status = MEMbuild_array(tmp_bufr);
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
	return(PDM_E_BUILD_ARRAY);
      }

   data = (char **) tmp_bufr->data_ptr;
 
   catalogno = atol (data[0]);
   itemno = atol (data[1]);
   _PDMdebug (fn, "catalogno[%d], itemno[%d]\n", catalogno, itemno);

   catalog[0] = '\0';

   status = PDMi_query_catalogname(data[0], catalog);
   if(status != PDM_S_SUCCESS) {
     _PDMdebug (fn, "PDMi_query_catalogname failed status [0x%.8x]\n", status);
     return(status);
    }
  
   MEMclose(&tmp_bufr);
   partnum[0] = '\0';
   revision[0] = '\0';
   desc[0] = '\0';


   status = PDMi_get_partnum_rev_desc (catalog, itemno,
                                         partnum, revision, desc);
   if(status != PDM_S_SUCCESS) {
     _PDMdebug (fn, "PDMi_query_partnumrev failed status [0x%.8x]\n", status);
     return(status);
    }

   _PDMdebug (fn, "catalog[%s] partnum[%s] revision[%s]\n", 
                                           catalog, partnum, revision);

  _PDMdebug(fn, "Exit\n");
  return (PDM_S_SUCCESS);
}

/*  ALR  3/31/94  Function to get storage filename given catalog, part number
    and revision. If the n_cifilename is null then return null in output
    variable else return storage area in output variable.
*/
long PDMget_stg_filename(cpr_catalog, cpr_part, cpr_rev, file_buff)
char *cpr_catalog;
char *cpr_part;
char *cpr_rev;
MEMptr *file_buff;
{
   char sql_str[500], s[500];
   char **data, stg_name[80];
   int itemno;
   int rows;
   int cols;
   int nx;
   int i;
   int char_index = 0;
   char *line = NULL;
   MEMptr tmp_buff = NULL;


   PDMdebug("PDMget_stg_filename: Enter \n");
   sprintf(s,"catalog |%s| part |%s| rev |%s|\n\0",cpr_catalog,cpr_part,cpr_rev);
   PDMdebug(s); 

   sprintf(sql_str,"select n_itemno from %s where n_itemname = '%s' and n_itemrev = '%s'\0",cpr_catalog,cpr_part,cpr_rev);
   status = SQLquery(sql_str,&tmp_buff,MEM_SIZE);
   if (status != SQL_S_SUCCESS)
    {
       sprintf(s,"%s failed <0x%.8x> \0",sql_str,status);
       PDMdebug(s);
       return(status);
    }
   status = MEMbuild_array(tmp_buff);
   if (status != MEM_S_SUCCESS)
   {
     sprintf(s,"MEMbuild_array failed <0x%.8x>\0",status);
     PDMdebug(s);
     return(status);
   }

   data = (char **)tmp_buff->data_ptr;
   itemno = atoi(data[0]);

   sprintf(s,"itemno found %d\n\0",itemno);
   PDMdebug(s);

  if (tmp_buff)
  {
    MEMclose(&tmp_buff);
    tmp_buff = NULL;
  }

   sprintf(sql_str,"select n_cofilename, n_cifilename from f_%s where n_itemnum = %d\0",cpr_catalog,itemno);
   status = SQLquery(sql_str,&tmp_buff,MEM_SIZE);
   if (status != SQL_S_SUCCESS)
    {
       sprintf(s,"%s failed <0x%.8x>\n\0",sql_str,status);
       PDMdebug(s);
       return(status);
    }

   status = MEMbuild_array(tmp_buff);
   if (status != MEM_S_SUCCESS)
   {
     sprintf(s,"MEMbuild_array failed <0x%.8x>\n\0",status);
     PDMdebug(s);
     return(status);
   }

   rows = tmp_buff->rows;
   cols = tmp_buff->columns;
   data = (char **)tmp_buff->data_ptr;

   status =  MEMopen(file_buff,512);
   if (status != MEM_S_SUCCESS)
    {
      PDMdebug("Could not open buffer \n");
      return(PDM_E_OPEN_BUFFER);  
    }
 
   status = MEMwrite_format(*file_buff,"n_cofilename","char(15)");
   if (status != MEM_S_SUCCESS)
     {
     MEMclose(file_buff);
     *file_buff = NULL;
     return(PDM_E_WRITE_BUFFER);
     }

   status = MEMwrite_format(*file_buff,"n_cifilename","char(15)");
   if (status != MEM_S_SUCCESS)
     {
     MEMclose(file_buff);
     *file_buff = NULL;
     return(PDM_E_WRITE_BUFFER);
     }

   line = (char*) malloc ((*file_buff)->row_size);

   for (i=0; i < rows; i++)
   {
    memset (line, NULL, (*file_buff)->row_size);
    char_index = 0;

    nx = i * cols;
    if (data[nx] && (strlen (data[nx] )))
      PDUadd_buffer_string(line, &char_index, data[nx]);
    else
      line[char_index++] = '\1';

    if (data[nx + 1] && (strlen (data[nx + 1] )))
      PDUadd_buffer_string(line, &char_index, data[nx + 1]);
    else
      line[char_index++] = '\1';

    status = MEMwrite(*file_buff,line);
    _pdm_status("MEMwrite", status);
    if (status != MEM_S_SUCCESS)
      {
        MEMclose(file_buff);
        *file_buff = NULL;
        return(PDM_E_WRITE_BUFFER);
      }
   }

   if (line)
     free(line);

   if (tmp_buff)
   {
     MEMclose(&tmp_buff);
     tmp_buff = NULL;
   }

 PDMdebug("PDMget_stg_filename EXIT\n");
 return(PDM_S_SUCCESS);
}
