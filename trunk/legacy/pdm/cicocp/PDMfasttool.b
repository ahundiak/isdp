#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "NFMstruct.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "PDMexec.h"
#include "NFMerrordef.h"
#include "NETerrordef.h"
#define MAX_BUFFER_SIZE 16384

extern long     sqlstatus;
extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static long     status;
static char     s[1024];
PDMpart_ptr PDMpart;
PDMchild_ptr PDMchild;
extern PDMexec_ptr PDMexec;




int PDMload_part_info(catalog,partnum,revision)
char *catalog;
char *partnum;
char *revision;
{
	MEMptr          bufr = NULL;
        int             parametric_flag= 0;
	char            sql_str[2048];
	char          **data;
        char          *fname = "PDMload_part_info";

	_PDMdebug(fname,"ENTER:\n");
	sql_str[0] = 0;
         parametric_flag= 0;
	sprintf(sql_str, 
 "SELECT t1.n_itemno, t1.n_creator, t1.n_creationdate,  \
 t1.n_updatedate,  t1.n_status, t1.n_setindicator, t1.n_archivestate,\
 t1.n_stateno, t1.n_itemlock, t1.n_versionlimit, t2.n_fileno, \
 t2.n_fileversion, t2.n_fileco, t1.n_pendingflag, t2.n_cisano, \
 t2.n_cifilename, t2.n_ciuser, t2.n_cidate, \
 t2.n_cosano, t2.n_cofilename, t2.n_couser,\
 t2.n_codate, t1.p_explode, t1.p_maxlevel,\
 t1.p_parttype, t1.p_incpartrpt FROM %s t1, f_%s t2 WHERE t1.n_itemname = '%s' AND \
 t1.n_itemrev = '%s' AND t1.n_itemno = t2.n_itemnum  AND \
 t2.n_fileversion = (select max(n_fileversion) from %s, f_%s where \
 %s.n_itemname = '%s' AND %s.n_itemrev = '%s' AND f_%s.n_itemnum = %s.n_itemno)",
 catalog, catalog, partnum, revision, catalog, catalog,catalog,partnum,catalog,revision, catalog, catalog);
                 
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS)
         {
		if (status == SQL_I_NO_ROWS_FOUND) {
			MEMclose(&bufr);
			sprintf(s, "PDMload_part_info Query failed\n");
			PDMdebug(s);
			return (status);
                    }
	       else
               {
	MEMclose(&bufr);
	sprintf(sql_str, 
 "SELECT n_itemno, n_creator, n_creationdate,  \
 n_updatedate,  n_status, n_setindicator, n_archivestate,\
 n_stateno, n_itemlock, n_versionlimit, \
 n_pendingflag,  \
 p_explode, p_maxlevel,\
 p_parttype FROM %s WHERE \
 n_itemrev = '%s' AND n_itemname= '%s'",
 catalog, revision, partnum);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS)
           {
	    if (status == SQL_I_NO_ROWS_FOUND)
                {
			MEMclose(&bufr);
			return (status);
		}
              else
                {
			sprintf(s, "PDMload_part_info Query failed\n");
			PDMdebug(s);
			return (status);
                 }
	     }
              parametric_flag = 1;
          }
        }
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
        if(!parametric_flag)
        {
        PDMpart.n_itemno = atol(data[0]);
        PDMpart.n_itemnum = atol(data[0]);
        strcpy(PDMpart.n_creator,data[1]);
        strcpy(PDMpart.n_creationdate,data[2]);
        strcpy(PDMpart.n_updatedate,data[3]);
        strcpy(PDMpart.n_status,data[4]);
        strcpy(PDMpart.n_setindicator,data[5]);
        strcpy(PDMpart.n_archivestate,data[6]);
        PDMpart.n_stateno= atol(data[7]);
        strcpy(PDMpart.n_itemlock,data[8]);
        PDMpart.n_versionlimit= atol(data[9]);
        PDMpart.n_fileno= atol(data[10]);
        PDMpart.n_fileversion= atol(data[11]);
        strcpy(PDMpart.n_fileco,data[12]);
        strcpy(PDMpart.n_pendingflag,data[13]);
        PDMpart.n_cisano= atol(data[14]);
        strcpy(PDMpart.n_cifilename,data[15]);
        strcpy(PDMpart.n_ciuser,data[16]);
        strcpy(PDMpart.n_cidate,data[17]);
        PDMpart.n_cosano= atol(data[18]);
        strcpy(PDMpart.n_cofilename,data[19]);
        strcpy(PDMpart.n_couser,data[20]);
        strcpy(PDMpart.n_codate,data[21]);
        strcpy(PDMpart.p_explode,data[22]);
        PDMpart.p_maxlevel = atol (data[23]);
        strcpy(PDMpart.p_parttype,data[24]);
        strcpy(PDMpart.p_incpartrpt,data[25]);
        }
         else
         {
        PDMpart.n_itemno = atol(data[0]);
        PDMpart.n_itemnum = atol(data[0]);
        strcpy(PDMpart.n_creator,data[1]);
        strcpy(PDMpart.n_creationdate,data[2]);
        strcpy(PDMpart.n_updatedate,data[3]);
        strcpy(PDMpart.n_status,data[4]);
        strcpy(PDMpart.n_setindicator,data[5]);
        strcpy(PDMpart.n_archivestate,data[6]);
        PDMpart.n_stateno= atol(data[7]);
        strcpy(PDMpart.n_itemlock,data[8]);
        strcpy(PDMpart.n_pendingflag,data[9]);
        PDMpart.n_versionlimit= atol(data[10]);
        strcpy(PDMpart.p_explode,data[11]);
        PDMpart.p_maxlevel = atol (data[12]);
        strcpy(PDMpart.p_parttype,data[13]);
         }
        
 if(PDMdebug_on)
     MEMprint_buffer("CATALOG AND F_CATALOG  INFO OF THE PART ", bufr, PDM_DEBUG_FILE);
	MEMclose(&bufr);
	_PDMdebug(fname,"EXIT:\n");
	return (PDM_S_SUCCESS);
}

int PDMload_child_info(catalog,partnum,revision)
char *catalog;
char *partnum;
char *revision;
{
	MEMptr          bufr = NULL;
	char            sql_str[2048];
	char          **data;

	PDMdebug("ENTER:PDMload_child_info\n");
	sql_str[0] = 0;
/*
	sprintf(sql_str, "SELECT %s.n_itemno,%s.n_creator,%s.n_creationdate, %s.n_creationtime,%s.n_updatedate,%s.n_updatetime, %s.n_status,%s.n_setindicator,%s.n_archivestate,%s.n_stateno, %s.n_itemlock,%s.n_versionlimit,f_%s.n_fileno, f_%s.n_fileversion,f_%s.n_fileco,f_%s.n_pendingflag,f_%s.n_cisano, f_%s.n_cifilename,f_%s.n_ciuser,f_%s.n_cidate, f_%s.n_citime,f_%s.n_cosano,f_%s.n_cofilename, f_%s.n_couser,f_%s.n_codate,f_%s.n_cotime, %s.p_explode,%s.p_maxlevel,%s.p_parttype FROM %s,f_%s WHERE %s.n_itemname = '%s' AND %s.n_itemrev = '%s' AND %s.n_itemno = f_%s.n_itemnum",catalog,catalog,catalog,catalog,catalog, catalog,catalog,catalog,catalog,catalog,catalog,catalog, catalog,catalog,catalog,catalog,catalog,catalog,catalog, catalog,catalog,catalog,catalog,catalog,catalog,catalog, catalog,catalog,catalog,catalog,catalog,catalog,partnum,catalog,revision, catalog,catalog);
*/
sprintf(sql_str, 
 "SELECT %s.n_itemno, %s.n_creator, %s.n_creationdate,  \
 %s.n_updatedate,  %s.n_status, %s.n_setindicator, %s.n_archivestate,\
 %s.n_stateno, %s.n_itemlock, %s.n_versionlimit, f_%s.n_fileno, \
 f_%s.n_fileversion, f_%s.n_fileco, %s.n_pendingflag, f_%s.n_cisano, \
 f_%s.n_cifilename, f_%s.n_ciuser, f_%s.n_cidate, \
 f_%s.n_cosano, f_%s.n_cofilename, f_%s.n_couser,\
 f_%s.n_codate, %s.p_explode, %s.p_maxlevel,\
 %s.p_parttype FROM %s, f_%s WHERE %s.n_itemname = '%s' AND \
 %s.n_itemrev = '%s' AND %s.n_itemno = f_%s.n_itemnum",
catalog,  catalog, catalog, 
catalog, catalog, catalog, catalog, catalog,  catalog, catalog, 
catalog, catalog, catalog, catalog, catalog,  catalog, catalog, 
catalog, catalog, catalog, catalog, catalog,  catalog, catalog, 
catalog, catalog, catalog, catalog, partnum, catalog, revision,  
catalog, catalog);
                 
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		if (status == SQL_I_NO_ROWS_FOUND) {
			MEMclose(&bufr);
			sprintf(s, "PDMload_part_info Query failed\n");
			PDMdebug(s);
			return (PDM_E_FAILURE);
		} else {
			return (PDM_E_SQL_QUERY);
		}
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
        PDMpart.n_itemno = atol(data[0]);
        PDMpart.n_itemnum = atol(data[0]);
        strcpy(PDMpart.n_creator,data[1]);
        strcpy(PDMpart.n_creationdate,data[2]);
        strcpy(PDMpart.n_updatedate,data[3]);
        strcpy(PDMpart.n_status,data[4]);
        strcpy(PDMpart.n_setindicator,data[5]);
        strcpy(PDMpart.n_archivestate,data[6]);
        PDMpart.n_stateno= atol(data[7]);
        strcpy(PDMpart.n_itemlock,data[8]);
        PDMpart.n_versionlimit= atol(data[9]);
        PDMpart.n_fileno= atol(data[10]);
        PDMpart.n_fileversion= atol(data[11]);
        strcpy(PDMpart.n_fileco,data[12]);
        strcpy(PDMpart.n_pendingflag,data[13]);
        PDMpart.n_cisano= atol(data[14]);
        strcpy(PDMpart.n_cifilename,data[15]);
        strcpy(PDMpart.n_ciuser,data[16]);
        strcpy(PDMpart.n_cidate,data[17]);
        PDMpart.n_cosano= atol(data[18]);
        strcpy(PDMpart.n_cofilename,data[19]);
        strcpy(PDMpart.n_couser,data[20]);
        strcpy(PDMpart.n_codate,data[21]);
        strcpy(PDMpart.p_explode,data[22]);
        PDMpart.p_maxlevel = atol (data[23]);
        strcpy(PDMpart.p_parttype,data[24]);
/* removed for NFM3.0 schema changes....
        strcpy(PDMpart.n_creationtime,data[3]);
        strcpy(PDMpart.n_updatetime,data[5]);
        strcpy(PDMpart.n_citime,data[20]);
        strcpy(PDMpart.n_cotime,data[25]);
*****/
                 
/*
	data = (char **) bufr->data_ptr;
        PDMchild.n_itemno = atol(data[0]);
        PDMchild.n_itemnum = atol(data[0]); 
        strcpy(PDMchild.n_creator,data[1]);
        strcpy(PDMchild.n_creationdate,data[2]);
        strcpy(PDMchild.n_creationtime,data[3]);
        strcpy(PDMchild.n_updatedate,data[4]);
        strcpy(PDMchild.n_updatetime,data[5]);
        strcpy(PDMchild.n_status,data[6]);
        strcpy(PDMchild.n_setindicator,data[7]);
        strcpy(PDMchild.n_archivestate,data[8]);
        PDMchild.n_stateno= atol(data[9]);
        strcpy(PDMchild.n_itemlock,data[10]);
        PDMchild.n_versionlimit= atol(data[11]);
        PDMchild.n_fileno= atol(data[12]);
        PDMchild.n_fileversion= atol(data[13]);
        strcpy(PDMchild.n_fileco,data[14]);
        strcpy(PDMchild.n_pendingflag,data[15]);
        PDMchild.n_cisano= atol(data[16]);
        strcpy(PDMchild.n_cifilename,data[17]);
        strcpy(PDMchild.n_ciuser,data[18]);
        strcpy(PDMchild.n_cidate,data[19]);
        strcpy(PDMchild.n_citime,data[20]);
        PDMchild.n_cosano= atol(data[21]);
        strcpy(PDMchild.n_cofilename,data[22]);
        strcpy(PDMchild.n_couser,data[23]);
        strcpy(PDMchild.n_codate,data[24]);
        strcpy(PDMchild.n_cotime,data[25]);
        strcpy(PDMchild.p_explode,data[26]);
        PDMchild.p_maxlevel = atol (data[27]);
        strcpy(PDMchild.p_parttype,data[28]);
*/
        
 if(PDMdebug_on)
   {
     PDMdebug ("GLOBAL part struct buffer:\n");
     MEMprint_buffer("part buffer ", bufr, PDM_DEBUG_FILE);
    }

	MEMclose(&bufr);
	PDMdebug("EXIT:PDMload_child_info\n");
	return (PDM_S_SUCCESS);
}



int PDMquery_part_info (bufr)
MEMptr          *bufr;
{
        char		*fn = "PDMquery_part_info";
	char            sql_str[2048];
        char            catalog[20];

   PDMdebug("ENTER:PDMquery_part_info\n");
   strcpy (catalog, PDMexec->catalog);
   sql_str[0] = 0;

   *bufr = NULL;

   sprintf(sql_str,  
      "SELECT %s.n_itemno, %s.n_creator, %s.n_creationdate,  %s.n_updatedate,  \
      %s.n_status, %s.n_setindicator, %s.n_archivestate, %s.n_stateno,  \
      %s.n_itemlock, %s.n_versionlimit, f_%s.n_fileno,  f_%s.n_fileversion, \
      f_%s.n_fileco, %s.n_pendingflag, f_%s.n_cisano,  f_%s.n_cifilename, \
      f_%s.n_ciuser, f_%s.n_cidate,  f_%s.n_cosano, f_%s.n_cofilename,  \
      f_%s.n_couser, f_%s.n_codate,  %s.p_explode, %s.p_maxlevel, %\
      s.p_parttype \
      FROM %s, f_%s \
      WHERE %s.n_itemname = '%s' AND %s.n_itemrev = '%s' \
      AND %s.n_itemno = f_%s.n_itemnum", 
      catalog, catalog, catalog, catalog, catalog, catalog, 
      catalog, catalog, catalog, catalog,  catalog, catalog, 
      catalog, catalog, catalog, catalog, catalog,  catalog, catalog,
      catalog, catalog, catalog, catalog, catalog,  catalog, 
      catalog, catalog, catalog, 
      PDMexec->part_num, catalog, PDMexec->revision,  catalog, catalog);
                 
    status = SQLquery(sql_str, bufr, 512);
    if (status != SQL_S_SUCCESS) {
    	if (status == SQL_I_NO_ROWS_FOUND) {
	   MEMclose(bufr);
	   _PDMdebug (fn, "PDMquery_part_info - NO RW FOUND\n");
	   return (PDM_E_PARTREV_NOT_FOUND);
     } 
    else {
    MEMclose(bufr);
    sprintf(sql_str, 
           "SELECT n_itemno, n_creator, n_creationdate,  \
           n_updatedate,  n_status, n_setindicator, n_archivestate,\
           n_stateno, n_itemlock, n_versionlimit, \
           n_pendingflag,  \
           p_explode, p_maxlevel,\
           p_parttype FROM %s WHERE \
           n_itemrev = '%s' AND n_itemname= '%s'",
           catalog, PDMexec->revision, PDMexec->part_num);

    status = SQLquery(sql_str, bufr, 512);
    if (status != SQL_S_SUCCESS) {
        if (status == SQL_I_NO_ROWS_FOUND) {
            _PDMdebug (fn, "No rows Found");
	    return (status);
		}
       else {
	_PDMdebug (fn, "SQLquery failed\n");
	return (status);
        }
      }
    }
   }
    if(PDMdebug_on)
     MEMprint_buffer("CATALOG AND F_CATALOG  INFO OF THE PART ", 
                                               *bufr, PDM_DEBUG_FILE);

	PDMdebug("EXIT:PDMquery_part_info\n");
	return (PDM_S_SUCCESS);
}

void _PDMinit_part_struct (PDMchild)
PDMpart_ptr	PDMchild;
{
 PDMdebug ("ENTER: _PDMinit_part_struct\n");
  PDMchild.n_itemno= -1;			 PDMchild.n_stateno= -1;
  PDMchild.n_versionlimit= -1;			 PDMchild.n_fileno= -1;
  PDMchild.n_fileversion= -1;			 PDMchild.n_cisano= -1;
  PDMchild.n_cosano= -1; 		 	 PDMchild.p_maxlevel = -1;
  
PDMchild.n_creator[0] = 0;		 	 PDMchild.n_creationdate[0] = 0; 
  PDMchild.n_creationtime[0] = 0;		 PDMchild.n_updatedate[0] = 0;
  PDMchild.n_updatetime[0] = 0;		 PDMchild.n_status[0] = 0;
  PDMchild.n_setindicator[0] = 0;		 PDMchild.n_archivestate[0] = 0;
  PDMchild.n_itemlock[0] = 0;		 PDMchild.n_fileco[0] = 0;
  PDMchild.n_pendingflag[0] = 0;		 PDMchild.n_cifilename[0] = 0;
  PDMchild.n_ciuser[0] = 0;			 PDMchild.n_cidate[0] = 0;
  PDMchild.n_citime[0] = 0;			 PDMchild.n_cofilename[0] = 0;
  PDMchild.n_couser[0] = 0;			 PDMchild.n_codate[0] = 0;
  PDMchild.n_cotime[0] = 0;			 PDMchild.p_explode[0] = 0;
  PDMchild.p_parttype[0] = 0;			
 PDMdebug ("EXIT: _PDMinit_part_struct\n");
}

void _PDMprint_setinfo1_struct (struct_name, set)
char *struct_name;
struct set_info1 *set;
{
if (set == (struct set_info1 *) NULL)
  {
    _PDMdebug ("PDMprint_setinfo1_struct:", "%s is NULL\n", struct_name);
       return;
        }
  sprintf (s, 
 "%s.itemno_v = %s, %s.itemname_v = %s,     %s.itemrev_v = %s,\n\
  %s.coout_v = %s,  %s.archivestate_v = %s, %s.itemlock_v = %s,\n \
  %s.versionlimit_v = %s, %s.fileclass_v = %s, \n \
  %s.fileversion_v = %s,  %s.cifilename_v = %s,\n\
  %s.type = %s\n",
  struct_name, set->itemno_v, 
  struct_name, set->itemname_v,
  struct_name, set->itemrev_v,
  struct_name, set->coout_v,
  struct_name, set->archivestate_v,
  struct_name, set->itemlock_v,
  struct_name, set->versionlimit_v,
  struct_name, set->fileclass_v,
  struct_name, set->fileversion_v,
  struct_name, set->cifilename_v,
  struct_name, set->type );
PDMdebug (s);
  sprintf (s, 
  "%s.table_no = %d, %s.citno = %d, \n\
   %s.level = %d,    %s.consecutive = %d\n",
  struct_name, set->table_no,
  struct_name, set->citno,
  struct_name, set->level,
  struct_name, set->consecutive );
PDMdebug (s);

/*
  _NFMdebug (struct_name, 
 "%s.itemno_v = %s, %s.itemname_v = %s, %s.itemrev_v = %s, %s.coout_v = %s,\n\
  %s.archivestate_v = %s, %s.itemlock_v = %s, %s.versionlimit_v = %s,\n\
  %s.fileclass_v = %s, %s.fileversion_v = %s, %s.cifilename_v = %s,\n\
  %s.type = %s\n",
  struct_name, set->itemno_v, 
  struct_name, set->itemname_v,
  struct_name, set->itemrev_v,
  struct_name, set->coout_v,
  struct_name, set->archivestate_v,
  struct_name, set->itemlock_v,
  struct_name, set->versionlimit_v,
  struct_name, set->fileclass_v,
  struct_name, set->fileversion_v,
  struct_name, set->cifilename_v,
  struct_name, set->type );
  _NFMdebug (struct_name, 
  "%s.table_no = %d, %s.citno = %d, %s.level = %d, %s.consecutive = %d\n",
  struct_name, set->table_no,
  struct_name, set->citno,
  struct_name, set->level,
  struct_name, set->consecutive );
*/
}

void _PDMprint_childinfo_struct (struct_name, set)
char *struct_name;
struct child_info *set;
{
sprintf (s, "%s.cat_name = %s, %s.type = %s\n",
  struct_name, set->cat_name, 
  struct_name, set->type );
PDMdebug (s);

sprintf (s, 
  "%s.level = %d, %s.citno = %d, %s.ccatalogno = %d, \n\
   %s.fcat_no = %d, %s.citemno = %d, %s.consecutive = %d\n",
  struct_name, set->level,
  struct_name, set->citno,
  struct_name, set->ccatalogno,
  struct_name, set->fcat_no,
  struct_name, set->citemno,
  struct_name, set->consecutive );
PDMdebug (s);
}
