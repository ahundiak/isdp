#include		<stdio.h>
#include		"PDUerror.h"
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
extern        char  glob_var[100];
extern struct PDUstorage *storage;


/*
	RETURN CODES :

	PDM_I_NO_FILES_FOUND
	PDM_I_NO_SAREA_FOUND

	OUTPUT:

	bufr : format

			p_fileno
			n_catalogname
			n_catalogno
			n_itemno
			p_moveddate
			p_movedtime
			p_filename
			p_type
			n_itemname
			n_itemrev
*/

int	PDMi_get_file_list(storage_buffer, bufr)
MEMptr		storage_buffer;
MEMptr		*bufr;
{
	int		n_sano, size;
	char	sql_str[1024];
	char	data_type[50];
	MEMptr	file_bufr = NULL;
	MEMptr	temp_bufr = NULL;

   PDMdebug("ENTER:PDMi_get_file_list\n");
   status = PDMi_find_storageno(storage_buffer, &n_sano);
   if(status != PDM_S_SUCCESS)
   {
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			return(PDM_I_NO_FILES_FOUND);
		}
		sprintf(s, "PDMi_find_storageno failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
/*  sprintf(sql_str, "%s %s %s %s %s %d %s %s %s", 
   "SELECT t1.n_catalogno, t1.n_itemno, t1.n_itemname, ", 
   "t2.p_mdate, t2.p_mtime, t2.p_filename, t2.p_fileno, ", 
   "t4.n_catalogname ", 
   "FROM pdmwsparts t1, pdmwsfiles t2, pdmfmgr t3, nfmcatalogs t4", 
   "WHERE t3.p_sano = ", n_sano, 
   "AND t1.n_itemname = t3.n_itemname ", 
   "AND t2.p_fileno = t3.p_fileno ", 
   "AND t4.n_catalogno = t1.n_catalogno ");
*/
  sprintf(sql_str, "%s %s %s %s %s %d %s %s %s", 
   "SELECT t1.n_catalogno, t1.n_itemno, ", 
   "t2.p_mdate, t2.p_mtime, t2.p_filename, ", 
   "t4.n_catalogname ", 
   "FROM pdmwsparts t1, pdmwsfiles t2, pdmfmgr t3, nfmcatalogs t4", 
   "WHERE t3.p_sano = ", n_sano, 
   "AND t1.n_itemname = t3.n_itemname ", 
   "AND t2.p_fileno = t3.p_fileno ", 
   "AND t4.n_catalogno = t1.n_catalogno ");

   status = SQLquery(sql_str, &file_bufr, 2048);
   if(status != SQL_S_SUCCESS)
   {
		MEMclose(&file_bufr);
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			return(PDM_I_NO_FILES_FOUND);
		}
		sprintf(s, "%s %d\n", "SQLquery failed ", status);
		PDMdebug(s);
		return(PDM_E_SQL_QUERY);
   }
	
   if(PDMdebug_on)
   {
		MEMprint_buffer("file_bufr", file_bufr, PDM_DEBUG_FILE);
   }

   /* store attributes by which the 
			buffer needs to be expanded */

   status = MEMopen(&temp_bufr, 1024);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&file_bufr);
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
   }
   status = PDMi_find_maxtype(file_bufr, 0, "n_itemname", &size);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "PDMi_find_maxtype failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   sprintf(data_type, "char(%d)", size);
   status = MEMwrite_format(temp_bufr, "n_itemname", data_type);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = PDMi_find_maxtype(file_bufr, 0, "n_itemrev", &size);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "PDMi_find_maxtype failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   sprintf(data_type, "char(%d)", size);
   status = MEMwrite_format(temp_bufr, "n_itemrev", data_type);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   
   /* copy expand buffer */

   status = PDMexpand_copy_buffer(file_bufr, temp_bufr, bufr);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "PDMexpand_copy_buffer failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   MEMclose(&file_bufr); MEMclose(&temp_bufr);
  
   /* fill in part data */

   status = PDMload_partdata(*bufr);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s, "PDMload_partdata failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   if(PDMdebug_on)
   {
		MEMprint_buffer("file_bufr at exit", *bufr, PDM_DEBUG_FILE);
   }
   PDMdebug("EXIT:PDMi_get_file_list\n");
   return(PDM_S_SUCCESS);
}

int  PDMasses_move_type(cat, part, rev, n_sano, movetype)
char	*cat;
char	*part;
char	*rev;
int     n_sano;
char	**movetype;
{

        int      n_itemname;
        int      p_ref1, p_ref2;
        int      p_catno, n_itemno;

	PDMdebug("ENTER:PDMasses_move_type\n");
       
        status = PDMquery_catalog_partnos(cat, part, rev, &p_catno, &n_itemno);
        if(status == PDM_I_NO_ROWS_FOUND)
        {
                sprintf(s, "Part <%s:%s:%s> does not exist in the System\n", 
                        cat, part, rev); PDMdebug(s);
                        return(status);
        }
        else if(status != PDM_S_SUCCESS)
        {
                        sprintf(s, "PDMquery_catalog_partnos failed status %d\n", 
                        status); PDMdebug(s);
                        return(status);
        }
	status = PDMi_find_partnum(p_catno, n_itemno, &n_itemname);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s, "PDMi_find_partnum failed status %d\n", 
		status); PDMdebug(s);
		return(status);
	}
	status = PDMi_find_references(n_itemname, n_sano, &p_ref1, &p_ref2);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s, "PDMi_find_references failed status %d\n", 
		status); PDMdebug(s);
		return(status);
	}
        *movetype = (char *) malloc (25);
        sprintf(s, "p_ref1 = %d\n", p_ref1);PDMdebug(s);
        sprintf(s, "p_ref2 = %d\n", p_ref2);PDMdebug(s);
        if(p_ref1 == 0 && p_ref2 == 0)
        {
          strcpy(*movetype, "COPY FILE LOCAL");
        }
        else if (p_ref1 == 1 && p_ref2 == 0)
         {
           strcpy(*movetype, "CHECK OUT PART");
         }
        else if (p_ref1 == 0 && p_ref2 > 0)
         {
           strcpy(*movetype, "ATTACH PART");
         }
        else if (p_ref1 == 1 && p_ref2 > 0)
         {
           strcpy(*movetype, "CHECKOUT AND ATTACH");
         }
        else 
         {
           strcpy(*movetype, "UNKNOWN");
         }
       
	PDMdebug("EXIT:PDMasses_move_type\n");
	return(PDM_S_SUCCESS);
}


int  PDMi_set_fileco(cat, part, rev, date1, time1, n_fileco)
char	*cat;
char	*part;
char	*rev;
char	*date1;
char	*time1;
char	*n_fileco;
{
	char	date2[20];
	char	time2[20];

	PDMdebug("ENTER:PDMi_set_fileco\n");
	status = PDMi_get_cidate(cat, part, rev, date2, time2);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s, "PDMi_get_cidate failed status %d\n", 
		status); PDMdebug(s);
		return(status);
	}
	status = PDMi_compare_dates(date1, time1, date2, time2);
    if(status == 0)
	{
		strcpy(n_fileco, "N");
	}
	else if(status == 1)
	{
		strcpy(n_fileco, "Y");
	}
	else if(status == 2)
	{
		strcpy(n_fileco, "N");
	}
	else
	{
		strcpy(n_fileco, "Y");
		sprintf(s, "PDMi_compare_dates failed status %d\n", status);
		PDMdebug(s);
		return(status);
	}
	PDMdebug("EXIT:PDMi_set_fileco\n");
	return(PDM_S_SUCCESS);
}

PDMi_update_bufr_column(bufr, r1, n1, n2, n3, val)
MEMptr	bufr;
int		r1;
int		n1;
int		n2;
int		n3;
char	*val;
{
	int		k, nxk;
	char	**data;

	PDMdebug("ENTER:PDMi_update_bufr_column\n");
	sprintf(s, "val -> %s\n", val);
	PDMdebug(s);
	data = (char **) bufr->data_ptr;
	for(k=0;k<bufr->rows;k++)
	{
		nxk = k * bufr->columns;
		if(!strcmp(data[r1+n1], data[nxk+n1]) &&
           !strcmp(data[r1+n2], data[nxk+n2]))
		{	
		   status = MEMwrite_data(bufr, val, k+1, n3+1);
		   if(status != MEM_S_SUCCESS)
		   {
				sprintf(s, "%s %d \n", 
				"MEMwrite_data failed status ", status);
				PDMdebug(s);
				return(PDM_E_WRITE_COLUMN);
		   }
		}
	}
	PDMdebug("EXIT:PDMi_update_bufr_column\n");
	return(PDM_S_SUCCESS);
}

int	PDMshow_file_list(file_list)
MEMptr		*file_list;
{
	int		nx, i;
	int		n_sano, size;
	int		n1, n2, n3, n4, n5, n6;
	int		n7 = 0, n8 = 0, n9 = 0, n10 = 0, n11 = 0;
	char	sql_str[1024];
	char	mem_str[1024];
	char	data_type[50];
	char	p_update[3];
	char	movetype[40];
	char	**columns, **format, **data, **fcat_data;
	MEMptr	file_bufr = NULL;
	MEMptr	temp_bufr = NULL;
	MEMptr	fcat_bufr = NULL;
	MEMptr	bufr = NULL;
	MEMptr	new_file_bufr = NULL;
        char    *fname = "PDMshow_file_list";

   _PDMdebug(fname, "ENTER:\n");
   n_sano = storage->storage_no;
   sprintf(sql_str, "%s %s %s %s %s %d %s ORDER BY t4.n_catalogname, t3.n_itemno, t3.n_filename", 
   "SELECT t3.n_catalogno, t3.n_itemno, ", 
   "t3.n_fileversion, t3.n_filename, t3.n_ref, t3.n_filenum, t3.n_co, t3.n_copy, ", 
   "t4.n_catalogname ", 
   "FROM nfmsafiles t3, nfmcatalogs t4", 
   "WHERE t3.n_sano = ", n_sano, 
   "AND t4.n_catalogno = t3.n_catalogno ");

   status = SQLquery(sql_str, &file_bufr, 2048);
   if(status != SQL_S_SUCCESS)
   {
	MEMclose(&file_bufr);
	if(status == SQL_I_NO_ROWS_FOUND) return(PDM_I_NO_FILES_FOUND);
        _PDMdebug(fname, "%s %d\n", "SQLquery failed ", status);
	return(PDM_E_SQL_QUERY);
   }
	
   if(PDMdebug_on)
		MEMprint_buffer("file_bufr", file_bufr, PDM_DEBUG_FILE);

/* Tmp fix added to overlook inconsistancies in lfm */
   status = _PDMclean_lfm_bufr (file_bufr, &new_file_bufr);
   if(status != PDM_S_SUCCESS) {
	MEMclose(&file_bufr);
	_PDMdebug(fname, "_PDMclean_lfm_bufr failed status %d\n", status);
	return(status);
   }
   MEMclose (&file_bufr);
   file_bufr = NULL;
   file_bufr = new_file_bufr;

   /* store attributes by which the 
			buffer needs to be expanded */

   status = MEMopen(&temp_bufr, 1024);
   if(status != MEM_S_SUCCESS)
   {
	MEMclose(&file_bufr);
	_PDMdebug(fname, "MEMopen failed status %d\n", status);
	return(PDM_E_OPEN_BUFFER);
   }
   status = PDMi_find_maxtype(file_bufr, 0, "n_itemname", &size);
   if(status != PDM_S_SUCCESS)
   {
	MEMclose(&file_bufr); MEMclose(&temp_bufr);
	_PDMdebug(fname, "PDMi_find_maxtype failed status %d\n", status);
	return(status);
   }
   sprintf(data_type, "char(%d)", size);
   status = MEMwrite_format(temp_bufr, "n_itemname", data_type);
   if(status != MEM_S_SUCCESS)
   {
	MEMclose(&file_bufr); MEMclose(&temp_bufr);
	_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }
   status = PDMi_find_maxtype(file_bufr, 0, "n_itemrev", &size);
   if(status != PDM_S_SUCCESS)
   {
	MEMclose(&file_bufr); MEMclose(&temp_bufr);
	_PDMdebug(fname, "PDMi_find_maxtype failed status %d\n", status);
	return(status);
   }
   sprintf(data_type, "char(%d)", size);
   status = MEMwrite_format(temp_bufr, "n_itemrev", data_type);
   if(status != MEM_S_SUCCESS)
   {
	MEMclose(&file_bufr); MEMclose(&temp_bufr);
	_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }
   
   /* copy expand buffer */

   status = PDMexpand_copy_buffer(file_bufr, temp_bufr, &bufr);
   if(status != PDM_S_SUCCESS)
   {
	MEMclose(&file_bufr); MEMclose(&temp_bufr);
	_PDMdebug(fname, "PDMexpand_copy_buffer failed status %d\n", status);
	return(status);
   }
   MEMclose(&file_bufr); MEMclose(&temp_bufr);
  
   /* fill in part data */

   status = PDMload_partdata(bufr);
   if(status != PDM_S_SUCCESS)
   {
    _PDMdebug(fname, "PDMload_partdata failed status %d\n", status);
     return(status);
   }
   if(PDMdebug_on)
  MEMprint_buffer("unsorted file_bufr at exit", bufr, PDM_DEBUG_FILE);
   status = PDMsort_local_buffer(&bufr);
   if(status != PDM_S_SUCCESS)
   {
    _PDMdebug(fname, "PDMsort_local_bufr failed status %d\n", status);
     return(status);
   }
   if(PDMdebug_on)
		MEMprint_buffer("file_bufr at exit", bufr, PDM_DEBUG_FILE);
   status = MEMbuild_array(bufr);
   if(status != MEM_S_SUCCESS)
   {
	MEMclose(&bufr);
        _PDMdebug(fname, "MEMbuild_array failed status %d\n", status);
	return(PDM_E_BUILD_ARRAY);
   }
   columns = (char **) bufr->column_ptr;
   format  = (char **) bufr->format_ptr;
   n1 = -1; n2 = -1; n3 = -1; n4 = -1;
   for(i=0;i<bufr->columns;i++)
   {
		if(!strcmp(columns[i], "n_catalogname"))  	n1 = i;
		if(!strcmp(columns[i], "n_itemname"))	  	n2 = i;
		if(!strcmp(columns[i], "n_itemrev"))	  	n3 = i;
		if(!strcmp(columns[i], "n_filename"))	  	n4 = i;
		if(!strcmp(columns[i], "n_catalogno"))	  	n5 = i;
		if(!strcmp(columns[i], "n_itemno"))	  	n6 = i;
		if(!strcmp(columns[i], "n_fileversion"))	  	n7 = i;
		if(!strcmp(columns[i], "n_filenum"))	  	n8 = i;
		if(!strcmp(columns[i], "n_ref"))	        	n9 = i;
		if(!strcmp(columns[i], "n_co"))	  	        n10 = i;
		if(!strcmp(columns[i], "n_copy"))	       	n11 = i;
   }
   status = MEMopen(file_list, 1024);
   if(status != MEM_S_SUCCESS)
   {
	MEMclose(file_list); MEMclose(&bufr);
	_PDMdebug(fname, "MEMopen failed status %d\n", status);
	return(PDM_E_OPEN_BUFFER);
   }
   status = MEMwrite_format(*file_list, "n_catalogname", format[n1]);
   if(status != MEM_S_SUCCESS)
   {
	MEMclose(file_list);MEMclose(&bufr);
	_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_itemname", format[n2]);
   if(status != MEM_S_SUCCESS)
   {
	MEMclose(file_list);MEMclose(&bufr);
	_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_itemrev", format[n3]);
   if(status != MEM_S_SUCCESS)
   {
	MEMclose(file_list);MEMclose(&bufr);
	_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_itemdesc", "char(40)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
	_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_filetype", "char(5)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
	_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_cofilename", "char(15)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
	_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "p_local", "char(40)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
	_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_statename", "char(40)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
	_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "p_update", "char(3)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
	_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "p_parttype", "char(2)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
	_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
		return(PDM_E_WRITE_FORMAT);
   }
   data = (char **) bufr->data_ptr;
   for(i=0;i<bufr->rows;i++)
   {
	nx = i * bufr->columns;
        if(strcmp(data[nx+n2], ""))
        {
           fcat_bufr = NULL;
           sql_str[0] = '\0';
     sprintf(sql_str, "SELECT f_%s.n_filetype, nfmstates.n_statename, f_%s.n_fileversion, f_%s.n_filenum , %s.p_parttype , %s.n_itemdesc FROM f_%s, nfmstates, %s WHERE %s.n_itemname = '%s' AND %s.n_itemrev = '%s' AND %s.n_itemno = f_%s.n_itemnum AND nfmstates.n_stateno = %s.n_stateno AND f_%s.n_filenum = %s", data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n2], data[nx+n1], data[nx+n3], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n8]);
            status = SQLquery(sql_str, &fcat_bufr, 512);
             if(status != SQL_S_SUCCESS)
              {
                 if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
                     MEMclose(&fcat_bufr);
                     continue;
                    }
               else
                {
                     MEMclose(&fcat_bufr);
                     return(PDM_E_SQL_QUERY);
                    }
               }
               status = MEMbuild_array(fcat_bufr);
               if (status != MEM_S_SUCCESS)
                {
                MEMclose(&fcat_bufr);
      _PDMdebug(fname, "MEMbuild_array of fcat_bufr failed status %d\n", status);
                return(PDM_E_BUILD_ARRAY);
                }
                fcat_data = (char **)fcat_bufr->data_ptr;
/* Beth told me 
   Consider  reference file attachments as  n_ref1 = 1 and n_copy = "Y"
   where as NFM consider  reference file attachments as  n_ref1 = 1
         and n_copy = "N" 
  consider Copy file local (primary member) as
     n_copy = "Y" and n_ref = 0  and copy file local (secondary member as
       n_copy = "Y" and n_ref = 0;
 Hence commenting this part out 
*/
    if(!strcmp(data[nx+n10], "Y") && (!strcmp(data[nx+n11], "N") || !strcmp(data[nx+n11], "")) && (atoi(data[nx+n9]) > 0)) strcpy(movetype, "CHECKED OUT & ATTACHED");
    else if(!strcmp(data[nx+n10], "Y") && !strcmp(data[nx+n11], "Y") && (atoi(data[nx+n9]) > 0)) strcpy(movetype, "CHECKED OUT, COPIED & ATTACHED");
    else if((!strcmp(data[nx+n10], "N") || !strcmp(data[nx+n10], ""))  && !strcmp(data[nx+n11], "Y") && (atoi(data[nx+n9]) > 0)) strcpy(movetype, "COPIED & ATTACHED");
    else if(!strcmp(data[nx+n10], "") && !strcmp(data[nx+n11], "Y") && (atoi(data[nx+n9]) > 0)) strcpy(movetype, "COPIED & ATTACHED");
    else if((!strcmp(data[nx+n10], "N") || !strcmp(data[nx+n10], "")) && (!strcmp(data[nx+n11], "N") || !strcmp(data[nx+n11], "")) && (atoi(data[nx+n9]) > 0)) strcpy(movetype, "ATTACHED");
    else if(!strcmp(data[nx+n10], "") && !strcmp(data[nx+n11], "N") && (atoi(data[nx+n9]) > 0)) strcpy(movetype, "ATTACHED");
    else if(!strcmp(data[nx+n10], "Y") && (!strcmp(data[nx+n11], "N") || !strcmp(data[nx+n11])) && ( !strcmp(data[nx+n9], "") || (atoi(data[nx+n9]) == 0))) strcpy(movetype, "CHECKED OUT");
    else if(!strcmp(data[nx+n10], "N") && !strcmp(data[nx+n11], "Y") && (atoi(data[nx+n9]) == 0)) strcpy(movetype, "COPIED TO LOCAL");
    else if(!strcmp(data[nx+n10], "") && !strcmp(data[nx+n11], "Y") && (atoi(data[nx+n9]) == 0)) strcpy(movetype, "COPIED TO LOCAL");
    else if(!strcmp(data[nx+n10], "Y") && !strcmp(data[nx+n11], "Y") && (atoi(data[nx+n9]) == 0)) strcpy(movetype, "CHECKED OUT & COPIED");
                 else strcpy(movetype, "COPY"); 
/*

    if(!strcmp(data[nx+n10], "Y") &&  (atoi(data[nx+n9]) > 0)) strcpy(movetype, "CHKOUT & ATTACH");
    else if(!strcmp(data[nx+n10], "N") && !strcmp(data[nx+n11], "Y") && (atoi(data[nx+n9]) > 0)) strcpy(movetype, "ATTACHED");
    else if(!strcmp(data[nx+n10], "Y") && !strcmp(data[nx+n11], "N") ) strcpy(movetype, "CHECKED OUT");
    else if(!strcmp(data[nx+n10], "N") && !strcmp(data[nx+n11], "Y") && (atoi(data[nx+n9]) == 0)) strcpy(movetype, "FILE COPY");
    else if(!strcmp(data[nx+n10], "") && !strcmp(data[nx+n11], "") && (atoi(data[nx+n9]) > 0)) strcpy(movetype, "ATTACHED");
    else if(!strcmp(data[nx+n10], "") && !strcmp(data[nx+n11], "N") && (atoi(data[nx+n9]) > 0)) strcpy(movetype, "ATTACHED");
                 else strcpy(movetype, "COPY"); 

*/
  if(atoi(fcat_data[2]) > atoi(data[nx+n7])  ) strcpy(p_update, "N");
                else strcpy(p_update, "Y");
      
                if(!strcmp(fcat_data[4], "G") || !strcmp(fcat_data[4], "g")
                 || !strcmp(fcat_data[4], "A") || !strcmp(fcat_data[4], "a")
                 || !strcmp(fcat_data[4], "D") || !strcmp(fcat_data[4], "d")
                 || !strcmp(fcat_data[4], "M") || !strcmp(fcat_data[4], "m")
                 || !strcmp(fcat_data[4], "P") || !strcmp(fcat_data[4], "p"))
               {
          mem_str[0] = '\0';
sprintf(mem_str, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", data[nx+n1], data[nx+n2], data[nx+n3], fcat_data[5], fcat_data[0], data[nx+n4], movetype, fcat_data[1], p_update, fcat_data[4]);
		status = MEMwrite(*file_list, mem_str);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(file_list);MEMclose(&bufr);
			_PDMdebug(fname, "MEMwrite failed status %d\n", status);
			return(PDM_E_WRITE_ROW);
		}
               }
               MEMclose(&fcat_bufr);
        }
   }
   MEMclose(&bufr);
   if(PDMdebug_on)
	MEMprint_buffer("at exit file_list", *file_list, PDM_DEBUG_FILE);
   _PDMdebug(fname, "EXIT:\n");
   return(PDM_S_SUCCESS);
}

/* get the list of files that can be deleted */

int	PDMdelete_file_list(storage_buffer, file_list)
MEMptr		storage_buffer;
MEMptr		*file_list;
{
	int		nx, i;
	int		n_sano, size;
	int		n1, n2, n3, n4;
	char	sql_str[1024];
	char	data_type[50];
	char	*a_row;
	char	**columns, **format, **data;
	MEMptr	file_bufr = NULL;
	MEMptr	temp_bufr = NULL;
	MEMptr	bufr = NULL;

   PDMdebug("ENTER:PDMdelete_file_list\n");
   status = PDMi_find_storageno(storage_buffer, &n_sano);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s, "PDMi_find_storageno failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   sprintf(sql_str, "%s %s %s %s %s %d %s %s %s  %s ORDER BY t4.n_catalogname, t1.n_itemno, t1.n_filename", 
   "SELECT t1.n_catalogno, t1.n_itemno, ", 
   "t1.n_filename, ", 
   "t4.n_catalogname ", 
   "FROM nfmsafiles t1, nfmcatalogs t4", 
   "WHERE t1.n_sano = ", n_sano, 
   "AND t1.n_ref1 = 0  ", 
   "AND t1.n_co = 'N'  ", 
   "AND t1.n_copy = 'Y' ", 
   "AND t4.n_catalogno = t1.n_catalogno ");

   status = SQLquery(sql_str, &file_bufr, 2048);
   if(status != SQL_S_SUCCESS)
   {
		MEMclose(&file_bufr);
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			return(PDM_I_NO_FILES_FOUND);
		}
		sprintf(s, "%s %d\n", "SQLquery failed ", status);
		PDMdebug(s);
		return(PDM_E_SQL_QUERY);
   }
	
   if(PDMdebug_on)
   {
		MEMprint_buffer("file_bufr", file_bufr, PDM_DEBUG_FILE);
   }

   /* store attributes by which the 
			buffer needs to be expanded */

   status = MEMopen(&temp_bufr, 1024);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&file_bufr);
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
   }
   status = PDMi_find_maxtype(file_bufr, 0, "n_itemname", &size);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "PDMi_find_maxtype failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   sprintf(data_type, "char(%d)", size);
   status = MEMwrite_format(temp_bufr, "n_itemname", data_type);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = PDMi_find_maxtype(file_bufr, 0, "n_itemrev", &size);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "PDMi_find_maxtype failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   sprintf(data_type, "char(%d)", size);
   status = MEMwrite_format(temp_bufr, "n_itemrev", data_type);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   
   /* copy expand buffer */

   status = PDMexpand_copy_buffer(file_bufr, temp_bufr, &bufr);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "PDMexpand_copy_buffer failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   MEMclose(&file_bufr); MEMclose(&temp_bufr);
  
   /* fill in part data */

   status = PDMload_partdata(bufr);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s, "PDMload_partdata failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   if(PDMdebug_on)
   {
		MEMprint_buffer("file_bufr at exit", bufr, PDM_DEBUG_FILE);
   }
   status = MEMbuild_array(bufr);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   columns = (char **) bufr->column_ptr;
   format  = (char **) bufr->format_ptr;
   n1 = -1; n2 = -1; n3 = -1; n4 = -1;
   for(i=0;i<bufr->columns;i++)
   {
		if(!strcmp(columns[i], "n_catalogname"))  	n1 = i;
		if(!strcmp(columns[i], "n_itemname"))	  	n2 = i;
		if(!strcmp(columns[i], "n_itemrev"))		  	n3 = i;
		if(!strcmp(columns[i], "p_filename"))	  	n4 = i;
   }
   status = MEMopen(file_list, 1024);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list); MEMclose(&bufr);
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
   }
   status = MEMwrite_format(*file_list, "n_catalogname", format[n1]);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_itemname", format[n2]);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_itemrev", format[n3]);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "p_filename", format[n4]);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   a_row = (char *) malloc(bufr->row_size);
   if(a_row == NULL)
   {
		MEMclose(file_list);MEMclose(&bufr);
		PDMdebug("Failed to malloc\n");
		return(PDM_E_COULD_NOT_MALLOC);
   }
   data = (char **) bufr->data_ptr;
   for(i=0;i<bufr->rows;i++)
   {
		nx = i * bufr->columns;
		sprintf(a_row, "%s\1%s\1%s\1%s\1", 
		data[nx+n1], data[nx+n2], data[nx+n3], data[nx+n4]);
		status = MEMwrite(*file_list, a_row);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(file_list);MEMclose(&bufr);
			free(a_row);
			sprintf(s, "MEMwrite failed status %d\n", status);
			PDMdebug(s);
			return(PDM_E_WRITE_ROW);
		}
   }
   MEMclose(&bufr);
   free(a_row);
   if(PDMdebug_on)
   {
		MEMprint_buffer("at exit file_list", 
					*file_list, PDM_DEBUG_FILE);
   }
   PDMdebug("EXIT:PDMdelete_file_list\n");
   return(PDM_S_SUCCESS);
}


int	PDMshow_chkout_files(file_list)
MEMptr		*file_list;
{
	int		nx, i;
	int		n_sano, size;
	int		n1, n2, n3, n4, n5, n6, n7 = 0, n8 = 0, n9;
	char	sql_str[1024];
	char	mem_str[1024];
	char	data_type[50];
	char	p_update[3];
	char	movetype[40];
	char	**columns, **format, **data, **fcat_data;
	MEMptr	file_bufr = NULL;
	MEMptr	temp_bufr = NULL;
	MEMptr	fcat_bufr = NULL;
	MEMptr	bufr = NULL;
        char *fname = "PDMshow_chkout_files";

   PDMdebug("ENTER:PDMshow_chkout_files\n");
/*
   status = PDMi_find_storageno(storage_buffer, &n_sano);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s, "PDMi_find_storageno failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
*/
   n_sano = storage->storage_no;
    sql_str[0] = '\0';
   sprintf(sql_str, "%s %s %s %s %s %d %s %s ORDER BY t4.n_catalogname", 
   "SELECT t3.n_catalogno, t3.n_itemno, ", 
   "t3.n_fileversion, t3.n_filenum, t3.n_filename, ", 
   "t4.n_catalogname , t3.n_ref", 
   "FROM nfmsafiles t3, nfmcatalogs t4", 
   "WHERE t3.n_sano = ", n_sano, 
   "AND t3.n_co = 'Y' ", 
   "AND t4.n_catalogno = t3.n_catalogno ");

   status = SQLquery(sql_str, &file_bufr, 2048);
   if(status != SQL_S_SUCCESS)
   {
		MEMclose(&file_bufr);
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			return(PDM_I_NO_FILES_FOUND);
		}
		sprintf(s, "%s %d\n", "SQLquery failed ", status);
		PDMdebug(s);
		return(PDM_E_SQL_QUERY);
   }
	
   if(PDMdebug_on)
   {
		MEMprint_buffer("file_bufr", file_bufr, PDM_DEBUG_FILE);
   }

   /* store attributes by which the 
			buffer needs to be expanded */

   status = MEMopen(&temp_bufr, 1024);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&file_bufr);
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
   }
   status = PDMi_find_maxtype(file_bufr, 0, "n_itemname", &size);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "PDMi_find_maxtype failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   sprintf(data_type, "char(%d)", size);
   status = MEMwrite_format(temp_bufr, "n_itemname", data_type);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = PDMi_find_maxtype(file_bufr, 0, "n_itemrev", &size);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "PDMi_find_maxtype failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   sprintf(data_type, "char(%d)", size);
   status = MEMwrite_format(temp_bufr, "n_itemrev", data_type);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   
   /* copy expand buffer */

   status = PDMexpand_copy_buffer(file_bufr, temp_bufr, &bufr);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(&file_bufr); MEMclose(&temp_bufr);
		sprintf(s, "PDMexpand_copy_buffer failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   MEMclose(&file_bufr); MEMclose(&temp_bufr);
  
   /* fill in part data */

   status = PDMload_partdata(bufr);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s, "PDMload_partdata failed status %d\n", status);
		PDMdebug(s);
		return(status);
   }
   if(PDMdebug_on)
   {
		MEMprint_buffer("bufr", bufr, PDM_DEBUG_FILE);
   }
   status = PDMsort_checkout_buffer(&bufr);
   if(status != PDM_S_SUCCESS)
   {
    _PDMdebug(fname, "PDMsort_local_bufr failed status %d\n", status);
     return(status);
   }
   if(PDMdebug_on)
   {
		MEMprint_buffer("file_bufr at exit", bufr, PDM_DEBUG_FILE);
   }
   status = MEMbuild_array(bufr);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   columns = (char **) bufr->column_ptr;
   format  = (char **) bufr->format_ptr;
   n1 = -1; n2 = -1; n3 = -1; n4 = -1;
   for(i=0;i<bufr->columns;i++)
   {
		if(!strcmp(columns[i], "n_catalogname"))  	n1 = i;
		if(!strcmp(columns[i], "n_itemname"))	  	n2 = i;
		if(!strcmp(columns[i], "n_itemrev"))		  	n3 = i;
		if(!strcmp(columns[i], "n_filename"))	  	n4 = i;
		if(!strcmp(columns[i], "n_catalogno"))	  	n5 = i;
		if(!strcmp(columns[i], "n_itemno"))	  	n6 = i;
		if(!strcmp(columns[i], "n_fileversion"))	  	n7 = i;
		if(!strcmp(columns[i], "n_filenum"))	  	n8 = i;
		if(!strcmp(columns[i], "n_ref"))	  	n9 = i;
   }
   status = MEMopen(file_list, 1024);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list); MEMclose(&bufr);
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
   }
   status = MEMwrite_format(*file_list, "n_catalogname", format[n1]);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_itemname", format[n2]);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_itemrev", format[n3]);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_itemdesc", "char(40)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_filetype", "char(5)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_cofilename", "char(15)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "p_local", "char(40)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "n_statename", "char(40)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "p_update", "char(3)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(*file_list, "p_parttype", "char(2)");
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(file_list);MEMclose(&bufr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
   }
   data = (char **) bufr->data_ptr;
   for(i=0;i<bufr->rows;i++)
   {
	nx = i * bufr->columns;
           fcat_bufr = NULL;
           sql_str[0] = '\0';
     sprintf(sql_str, "SELECT f_%s.n_filetype, nfmstates.n_statename, f_%s.n_fileversion, f_%s.n_fileco , %s.p_parttype , %s.n_itemdesc FROM f_%s, nfmstates, %s WHERE %s.n_itemname = '%s' AND %s.n_itemrev = '%s' AND %s.n_itemno = f_%s.n_itemnum AND nfmstates.n_stateno = %s.n_stateno AND f_%s.n_filenum = %s", data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n2], data[nx+n1], data[nx+n3], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n1], data[nx+n8]);
            status = SQLquery(sql_str, &fcat_bufr, 512);
             if(status != SQL_S_SUCCESS)
              {
                 if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
                     MEMclose(&fcat_bufr);
                     continue;
                    }
               else
                {
                     MEMclose(&fcat_bufr);
                     return(PDM_E_SQL_QUERY);
                    }
               }
               status = MEMbuild_array(fcat_bufr);
               if (status != MEM_S_SUCCESS)
                {
                MEMclose(&fcat_bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return(PDM_E_BUILD_ARRAY);
                }
                fcat_data = (char **)fcat_bufr->data_ptr;
                strcpy(movetype, "CHECKED OUT");

 status = PDMi_compare_dates(data[nx+n7], data[nx+n8], fcat_data[2], fcat_data[3]);
    if(atoi(fcat_data[2]) > atoi(data[nx+n8])) strcpy(p_update, "Y");
                else strcpy(p_update, "Y");
      
                if(!strcmp(fcat_data[4], "G") || !strcmp(fcat_data[4], "g")
                 || !strcmp(fcat_data[4], "A") || !strcmp(fcat_data[4], "a")
                 || !strcmp(fcat_data[4], "M") || !strcmp(fcat_data[4], "m")
                 || !strcmp(fcat_data[4], "P") || !strcmp(fcat_data[4], "p"))
               {
          mem_str[0] = '\0';
sprintf(mem_str, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", data[nx+n1], data[nx+n2], data[nx+n3], fcat_data[5], fcat_data[0], data[nx+n4], movetype, fcat_data[1], p_update, fcat_data[4]);
		status = MEMwrite(*file_list, mem_str);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(file_list);MEMclose(&bufr);
			sprintf(s, "MEMwrite failed status %d\n", status);
			PDMdebug(s);
			return(PDM_E_WRITE_ROW);
		}
               }
               MEMclose(&fcat_bufr);
   }
   MEMclose(&bufr);
   if(PDMdebug_on)
   {
		MEMprint_buffer("at exit file_list", 
					*file_list, PDM_DEBUG_FILE);
   }
   PDMdebug("EXIT:PDMshow_chkout_files\n");
   return(PDM_S_SUCCESS);
}



/****************************************************************************

Name
   PDMsort_local_bufr

Abstract

Synopsis
  long PDMsort_local_bufr (MEMptr unsorted_bufr)

Description
   Input/output:
     Buffer information from the nfmsafiles table. This information is
     not sorted becuase nfmsafiles stores only the numbers of cataloggs
     and itemnos

   Output:
     sorted buffer of the same information.

   Algorithm:
   1)

Return Values

Notes

Index

Keywords

History
   Kumar Narayanan Fri April 17 13:30:52 CST 1993: Initial Creation
****************************************************************************/


/****************************************************************************
Include Files
****************************************************************************/

/****************************************************************************
Main Function
****************************************************************************/


int PDMsort_local_buffer (MEMptr *unsorted_bufr)
{
  int    i =0, j = 0, nxi = 0, nxj = 0;
  char	cpr11[199], cpr1[200], cpr22[199], cpr2[200];
  char  catno_ptr [20]; 
  char  itemno_ptr [10]; 
  char  filever_ptr [10]; 
  char  filename_ptr [240]; 
  char  ref_ptr [10]; 
  char  filenum_ptr [10]; 
  char  co_ptr [5]; 
  char  copy_ptr [5];
  char  cat_ptr [20]; 
  char  part_ptr [80]; 
  char  rev_ptr [40]; 
  char  ** data = NULL;
  char  *fname="PDMsort_local_buffer";

   _PDMdebug(fname, "Enter");

      if(PDMdebug_on)
   {
     MEMprint_buffer("Unsorted bufr", *unsorted_bufr, PDM_DEBUG_FILE);
   }
        status = MEMbuild_array(*unsorted_bufr);
        if(status != MEM_S_SUCCESS)
        {
         _PDMdebug (fname, "MEMbuild_array failed status %d\n", status);
                return(PDM_E_BUILD_ARRAY);
        }
        /*  Sort the buffer  */

        data = (char **) (*unsorted_bufr)->data_ptr;

        for (i = 0; i < (*unsorted_bufr)->rows - 1; ++i)
          {
             nxi = i * (*unsorted_bufr)->columns;
/*_PDMdebug(fname, "<%s> <%s> <%s>\n", data[nxi+8], data[nxi+9], data[nxi+10]);
         cpr11[0] = '\0';
           sprintf(cpr11, "%s%s%s\0", data[nxi+8], data[nxi+9], data[nxi+10]);
           PDMconvert_to_lower(cpr11, cpr1);
    _PDMdebug(fname, "CPR1  <%s>\n", cpr1); */
                for (j = i + 1; j < (*unsorted_bufr)->rows; ++j)
                  {
/*_PDMdebug(fname, "<%s> <%s> <%s>\n", data[nxj+8], data[nxj+9], data[nxj+10]);*/
                     nxj = j * (*unsorted_bufr)->columns;
         cpr11[0] = '\0';
           sprintf(cpr11, "%s%s%s\0", data[nxi+8], data[nxi+9], data[nxi+10]);
           PDMconvert_to_lower(cpr11, cpr1);
    _PDMdebug(fname, "CPR1  <%s>\n", cpr1);
         cpr22[0] = '\0';
           sprintf(cpr22, "%s%s%s\0", data[nxj+8], data[nxj+9], data[nxj+10]);
           PDMconvert_to_lower(cpr22, cpr2);
    _PDMdebug(fname, "CPR2  <%s>\n", cpr2);
              _PDMdebug("Value", "CPR1 Vs CPR2 %d\n", (strcmp (cpr1, cpr2)));
                    if ((strcmp (cpr1, cpr2)) > 0)
                         {
               _PDMdebug("", "Swapping CPR2 Vs CPR2 %s-%s\n", cpr1, cpr2);
                        /*  Store the previous  value*/
                        strcpy(catno_ptr , data[nxi+0]); 
                        strcpy(itemno_ptr , data[nxi+1]); 
                        strcpy(filever_ptr , data[nxi+2]); 
                        strcpy(filename_ptr , data[nxi+3]); 
                        strcpy(ref_ptr , data[nxi+4]); 
                        strcpy(filenum_ptr , data[nxi+5]); 
                        strcpy(co_ptr , data[nxi+6]); 
                        strcpy(copy_ptr,  data[nxi+7]); 
                        strcpy(cat_ptr , data[nxi+8]); 
                        strcpy(part_ptr , data[nxi+9]); 
                        strcpy(rev_ptr , data[nxi+10]); 
                                /*  Swap the 2 rows  */
                         strcpy(data[nxi+0] , data[nxj+0]); 
                         strcpy(data[nxi+1] , data[nxj+1]); 
                         strcpy(data[nxi+2] , data[nxj+2]); 
                         strcpy(data[nxi+3] , data[nxj+3]); 
                         strcpy(data[nxi+4] , data[nxj+4]); 
                         strcpy(data[nxi+5] , data[nxj+5]); 
                         strcpy(data[nxi+6] , data[nxj+6]); 
                         strcpy(data[nxi+7] , data[nxj+7]); 
                         strcpy(data[nxi+8] , data[nxj+8]); 
                         strcpy(data[nxi+9] , data[nxj+9]); 
                         strcpy(data[nxi+10] , data[nxj+10]); 
                             /* Restore the stored value */
                        strcpy(data[nxj+0] , catno_ptr) ; 
                        strcpy(data[nxj+1] , itemno_ptr) ; 
                        strcpy(data[nxj+2] , filever_ptr); 
                        strcpy(data[nxj+3] , filename_ptr); 
                        strcpy(data[nxj+4] , ref_ptr ); 
                        strcpy(data[nxj+5] , filenum_ptr ); 
                        strcpy(data[nxj+6] , co_ptr ); 
                        strcpy(data[nxj+7] , copy_ptr); 
                        strcpy(data[nxj+8] , cat_ptr) ; 
                        strcpy(data[nxj+9] , part_ptr); 
                        strcpy(data[nxj+10] , rev_ptr); 
                          }

                  }
          }

     _PDMdebug(fname, "Exit");
  return (PDM_S_SUCCESS);
}


int _PDMclean_lfm_bufr (file_bufr, new_file_bufr)
MEMptr	file_bufr, *new_file_bufr;
{
  char  *fn = "_PDMclean_lfm_bufr";
  MEMptr	tmp_bufr = NULL;
  char		mem_str[1024];
  char		cofilename[256];
  int		j, k, index, kindex;
  int		p1, p2, p3, p4, duplicate;
  char		**file_data, **columns;

  _PDMdebug(fn, "Enter\n");

   status = MEMbuild_array(file_bufr);
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
	return(PDM_E_BUILD_ARRAY);
   }

   status = MEMopen(&tmp_bufr, 1024);
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMopen failed status %d\n", status);
	return(PDM_E_BUILD_ARRAY);
     }

   status = MEMwrite_format(tmp_bufr, "n_catalogno", "integer");
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(tmp_bufr, "n_itemno", "integer");
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(tmp_bufr, "n_fileversion", "integer");
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(tmp_bufr, "n_filename", "char(240)");
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(tmp_bufr, "n_ref", "integer");
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(tmp_bufr, "n_filenum", "integer");
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(tmp_bufr, "n_co", "char(1)");
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(tmp_bufr, "n_copy", "char(1)");
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }
   status = MEMwrite_format(tmp_bufr, "n_catalogname", "char(20)");
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
	return(PDM_E_WRITE_FORMAT);
   }

   file_data = (char **) file_bufr->data_ptr;
   columns = (char **) file_bufr->column_ptr;
   p1 = -1; p2 = -1; p3 = -1; p4 = -1;
   for(j=0;j<file_bufr->columns;j++)
   {
       if(!strcmp(columns[j], "n_catalogno"))     p1 = j;
       if(!strcmp(columns[j], "n_itemno"))     p2 = j;
       if(!strcmp(columns[j], "n_filenum"))	   p3 = j;
     }
   for (j=0;j<file_bufr->rows;j++) {
    index = j * file_bufr->columns;
    duplicate = 0;
    for (k=0;k<j;k++) {
     kindex = k * file_bufr->columns;
     if ( (atol (file_data[index+p1]) == atol (file_data[kindex+p1])) &&
      (atol (file_data[index+p2]) == atol (file_data[kindex+p2])) &&
      (atol (file_data[index+p3]) == atol (file_data[kindex+p3]))) {
      duplicate = 1;
      break;
       }
     }
     if (duplicate != 1) {
        status = _PDMget_cofilename_cprfnum (file_data[index+8], 
                                             file_data[index+1], 
                                             file_data[index+5], 
                                             cofilename);
        if(status != PDM_S_SUCCESS) {
	   MEMclose(&tmp_bufr);
	   _PDMdebug(fn, "_PDMget_cofilename_cprfnum failed status %d\n", status);
	   return(status);
          }

        _PDMdebug ("cat", "[%s].itemno[%s].filenum[%s].fname[%s]\n", 
                                             file_data[index+8], 
                                             file_data[index+1], 
                                             file_data[index+5], 
                                             cofilename);

        sprintf (mem_str, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", 
        file_data[index+0], file_data[index+1], file_data[index+2], 
        cofilename, file_data[index+4], file_data[index+5], 
        file_data[index+6], file_data[index+7], file_data[index+8]);
        
     status = MEMwrite(tmp_bufr, mem_str);
     if(status != MEM_S_SUCCESS) {
	MEMclose(&tmp_bufr);
	_PDMdebug(fn, "MEMwrite failed status %d\n", status);
	return(PDM_E_WRITE_ROW);
          }
        }
    }

   status = MEMbuild_array(tmp_bufr);
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
	return(PDM_E_BUILD_ARRAY);
   }

   *new_file_bufr = tmp_bufr;
	
   if(PDMdebug_on) {
	MEMprint_buffer("new_file_bufr", *new_file_bufr, PDM_DEBUG_FILE);
   }

  _PDMdebug(fn, "Exit\n");
  return (PDM_S_SUCCESS);
}

/****************************************************************************

Name
   PDMsort_checkout_bufr

Abstract

Synopsis
  long PDMsort_checkput_bufr (MEMptr unsorted_bufr)

Description
   Input/output:
     Buffer information from the nfmsafiles table. This information is
     not sorted becuase nfmsafiles stores only the numbers of cataloggs
     and itemnos

   Output:
     sorted buffer of the same information.

   Algorithm:
   1)

Return Values

Notes

Index

Keywords

History
   Kumar Narayanan Fri April 17 13:30:52 CST 1993: Initial Creation
****************************************************************************/


/****************************************************************************
Include Files
****************************************************************************/

/****************************************************************************
Main Function
****************************************************************************/


int PDMsort_checkout_buffer (MEMptr *unsorted_bufr)
{
  int    i =0, j = 0, nxi = 0, nxj = 0;
  char	cpr11[199], cpr1[200], cpr22[199], cpr2[200];
  char  catno_ptr [20]; 
  char  itemno_ptr [10]; 
  char  filever_ptr [10]; 
  char  filename_ptr [240]; 
  char  ref_ptr [10]; 
  char  filenum_ptr [10]; 
  char  cat_ptr [20]; 
  char  part_ptr [80]; 
  char  rev_ptr [40]; 
  char  ** data = NULL;
  char  *fname="PDMsort_checkout_buffer";

   _PDMdebug(fname, "Enter");

      if(PDMdebug_on)
   {
     MEMprint_buffer("Unsorted bufr", *unsorted_bufr, PDM_DEBUG_FILE);
   }
        status = MEMbuild_array(*unsorted_bufr);
        if(status != MEM_S_SUCCESS)
        {
         _PDMdebug (fname, "MEMbuild_array failed status %d\n", status);
                return(PDM_E_BUILD_ARRAY);
        }
        /*  Sort the buffer  */

        data = (char **) (*unsorted_bufr)->data_ptr;

        for (i = 0; i < (*unsorted_bufr)->rows - 1; ++i)
          {
             nxi = i * (*unsorted_bufr)->columns;
/*_PDMdebug(fname, "<%s> <%s> <%s>\n", data[nxi+5], data[nxi+7], data[nxi+8]);
         cpr11[0] = '\0';
           sprintf(cpr11, "%s%s%s\0", data[nxi+5], data[nxi+7], data[nxi+8]);
           PDMconvert_to_lower(cpr11, cpr1);
    _PDMdebug(fname, "CPR1  <%s>\n", cpr1); */
                for (j = i + 1; j < (*unsorted_bufr)->rows; ++j)
                  {
/*_PDMdebug(fname, "<%s> <%s> <%s>\n", data[nxj+8], data[nxj+9], data[nxj+10]);*/
                     nxj = j * (*unsorted_bufr)->columns;
         cpr11[0] = '\0';
           sprintf(cpr11, "%s%s%s\0", data[nxi+5], data[nxi+7], data[nxi+8]);
           PDMconvert_to_lower(cpr11, cpr1);
    _PDMdebug(fname, "CPR1  <%s>\n", cpr1);
         cpr22[0] = '\0';
           sprintf(cpr22, "%s%s%s\0", data[nxj+5], data[nxj+7], data[nxj+8]);
           PDMconvert_to_lower(cpr22, cpr2);
    _PDMdebug(fname, "CPR2  <%s>\n", cpr2);
              _PDMdebug("Value", "CPR1 Vs CPR2 %d\n", (strcmp (cpr1, cpr2)));
                    if ((strcmp (cpr1, cpr2)) > 0)
                         {
               _PDMdebug("", "Swapping CPR2 Vs CPR2 %s-%s\n", cpr1, cpr2);
                        /*  Store the previous  value*/
                        strcpy(catno_ptr , data[nxi+0]); 
                        strcpy(itemno_ptr , data[nxi+1]); 
                        strcpy(filever_ptr , data[nxi+2]); 
                        strcpy(filename_ptr , data[nxi+4]); 
                        strcpy(ref_ptr , data[nxi+6]); 
                        strcpy(filenum_ptr , data[nxi+3]); 
                        strcpy(cat_ptr , data[nxi+5]); 
                        strcpy(part_ptr , data[nxi+7]); 
                        strcpy(rev_ptr , data[nxi+8]); 
                                /*  Swap the 2 rows  */
                         strcpy(data[nxi+0] , data[nxj+0]); 
                         strcpy(data[nxi+1] , data[nxj+1]); 
                         strcpy(data[nxi+2] , data[nxj+2]); 
                         strcpy(data[nxi+3] , data[nxj+3]); 
                         strcpy(data[nxi+4] , data[nxj+4]); 
                         strcpy(data[nxi+5] , data[nxj+5]); 
                         strcpy(data[nxi+6] , data[nxj+6]); 
                         strcpy(data[nxi+7] , data[nxj+7]); 
                         strcpy(data[nxi+8] , data[nxj+8]); 
                             /* Restore the stored value */
                        strcpy(data[nxj+0] , catno_ptr) ; 
                        strcpy(data[nxj+1] , itemno_ptr) ; 
                        strcpy(data[nxj+2] , filever_ptr); 
                        strcpy(data[nxj+4] , filename_ptr); 
                        strcpy(data[nxj+6] , ref_ptr ); 
                        strcpy(data[nxj+3] , filenum_ptr ); 
                        strcpy(data[nxj+5] , cat_ptr) ; 
                        strcpy(data[nxj+7] , part_ptr); 
                        strcpy(data[nxj+8] , rev_ptr); 
                          }

                  }
          }

     _PDMdebug(fname, "Exit");
  return (PDM_S_SUCCESS);
}

