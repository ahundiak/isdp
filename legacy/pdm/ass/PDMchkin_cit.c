#include <stdio.h>
#include "NFMdef.h"
#include "ERR.h"
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"PDMexec.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDMdbs_err.h"

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static long     status;
static char     s[1024];
extern PDMexec_ptr PDMexec;



/*
 * This function is to be called whenever (during checkin) the n_citnos are
 * changed by NFM.
 * 
 * DESCRIPTION:
 * 
 * (a)Keeps up with the changes to pdmcit table. old_set contains p_citno's
 * prior to checkin. All the entries in pdmcit with the matching p_citno can
 * be deleted. Then all the entries in child_bufr are inserted into pdmcit
 * using set_data. It works because .. set_data contains the new n_citnos ->
 * by matching the catalog,partnum,partrev entries the new n_citno in nfmcit
 * can be found
 * 
 * (b)Keeps up with changes to pdc_xxx entries
 * 
 *  Kumar - 11/12/91
 */

int PDMXXinsert_citinfo( p_catalogno,p_itemno,child_bufr, parm_buffer, data_buffers,parmdata_buffers,citno,p_update)
int   p_catalogno;
int   p_itemno;
MEMptr          child_bufr;
MEMptr          parm_buffer;
MEMptr          data_buffers;
MEMptr          parmdata_buffers;
MEMptr          citno;
char *p_update;
{
	char          **column_ptr;
	char          **set_dataptr;
	char          **child_data, **fly_data;
	char            pdc_row[200];
	char            sql_str[2048];
	char            sql_str1[1024];
	char            sql_str2[1024];
	int             m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13,
                        m14,m15,m16,m17,m19,m20, m21;
	int             n1, n2, n3, n4, n5, n6, n7, n8;
	int             i, nxi;
	int             j, nxj;
	int             p_citno;
	int             p_pdcno;
	MEMptr          pdc_bufr = NULL;
        char            *fname = "PDMinsert_citinfo";

	_PDMdebug(fname,"ENTER:\n");

/* following junk is added to remove the warnings temp. MaC 050293*/
        p_pdcno = p_catalogno;
        p_pdcno = p_itemno;
        p_pdcno = -1;

	/* set offsets in data_buffers */
	n1 = -1;
	n2 = -1;
	n3 = -1;
	n4 = -1;
	n5 = -1;
	n6 = -1;
	n7 = -1;
	n8 = -1;

	column_ptr = (char **) data_buffers->column_ptr;
	for (i = 0; i < data_buffers->columns; i++) {
		if (!strcmp(column_ptr[i], "n_catalogname"))
			n1 = i;
		if (!strcmp(column_ptr[i], "n_itemname"))
			n2 = i;
		if (!strcmp(column_ptr[i], "n_itemrev"))
			n3 = i;
		if (!strcmp(column_ptr[i], "n_citno"))
			n4 = i;
		if (!strcmp(column_ptr[i], "n_type"))
			n5 = i;
		if (!strcmp(column_ptr[i], "n_coout"))
			n6 = i;
		if (!strcmp(column_ptr[i], "n_setindicator"))
			n8 = i;
	}
	if (n1 == -1 || n2 == -1 || n3 == -1 ||
	    n4 == -1 || n5 == -1 || n6 == -1  || n8 == -1) {
		sprintf(s, "%s \n", "Failed to set offsets ");
		PDMdebug(s);
		return (PDM_E_BUFFER_FORMAT);
	}
	/* set offsets in child_bufr */

	m1 = -1;
	m2 = -1;
	m3 = -1;
	m4 = -1;
	m5 = -1;
	m6 = -1;
	m7 = -1;
	m8 = -1;
	m9 = -1;
	m10 = -1;
	m11 = -1;
	m12 = -1;
	m13 = -1;
	m14 = -1;
	m15 = -1;
	m16 = -1;
	m17 = -1;
	m19 = -1;
	m20 = -1;
	m21 = -1;
	column_ptr = (char **) child_bufr->column_ptr;
	child_data = (char **) child_bufr->data_ptr;
	for (i = 0; i < child_bufr->columns; i++) {
		if (!strcmp(column_ptr[i], "n_catalogname"))
			m1 = i;
	else	if (!strcmp(column_ptr[i], "n_itemname"))
			m2 = i;
	else	if (!strcmp(column_ptr[i], "n_itemrev"))
			m3 = i;
	else	if (!strcmp(column_ptr[i], "p_quantity"))
			m4 = i;
	else	if (!strcmp(column_ptr[i], "p_history"))
			m5 = i;
	else	if (!strcmp(column_ptr[i], "p_childno"))
			m6 = i;
	else	if (!strcmp(column_ptr[i], "p_usageid"))
			m7 = i;
	else	if (!strcmp(column_ptr[i], "p_tagno"))
			m8 = i;
	else	if (!strcmp(column_ptr[i], "p_alttagno"))
			m9 = i;
	else	if (!strcmp(column_ptr[i], "p_incbom"))
			m10 = i;
	else	if (!strcmp(column_ptr[i], "p_explode"))
			m11 = i;
	else	if (!strcmp(column_ptr[i], "p_attached"))
			m12 = i;
	else	if (!strcmp(column_ptr[i], "n_cofilename"))
			m13 = i;
        else    if (!strcmp(column_ptr[i], "p_incstr"))
                        m14 = i;
	}
	if (m1 == -1 || m2 == -1 || m3 == -1 || m4 == -1 ||

	    m5 == -1 || m6 == -1 || m9 == -1 ||
	    m7 == -1 || m8 == -1 ||  m10 == -1 ||  
	    m11 == -1 || m12 == -1 || m13 == -1 || m14 == -1 ) {
	_PDMdebug(fname, "%s  \n", " Incorrect buffer format in child_bufr");
		return (PDM_E_BUFFER_FORMAT);

	}

   /* MODIFY PDMCIT ONLY WHEN THE ASSEMBLY HAS CHANGED */ 

   if(!strcmp(p_update,"Y") || !strcmp(p_update,"y"))
        {
	status = PDMi_maxrow_no("pdmcit", "p_pdcno", &p_pdcno);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug(fname, "PDMi_maxrow_no failed status %d\n", status);
		return (status);
	}
	/* cleanup pdmcit, pdc_xxx */

	set_dataptr = (char **) data_buffers->data_ptr;
	for (i = 1; i < data_buffers->rows; i++) {
		nxi = i * data_buffers->columns;
		/* if part has dynamic information  to delete */
		status = PDMi_delete_dynamic_info(
			set_dataptr[nxi + n4], set_dataptr[nxi + n1], citno);
		if (status != PDM_S_SUCCESS) {
	_PDMdebug(fname, "PDMi_delete_pdcentries failed status %d\n", status);
		}
	}

	status = MEMopen(&pdc_bufr, 512);
	if (status != MEM_S_SUCCESS) {
	_PDMdebug(fname, "MEMopen of pdc_bufr failed status %d\n", status);
	return (PDM_E_OPEN_BUFFER);
	}
	status = MEMwrite_format(pdc_bufr, "n_catalogname", "char(30)");
	if (status != MEM_S_SUCCESS) {
		_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
		return (PDM_E_WRITE_FORMAT);
	}
	status = MEMwrite_format(pdc_bufr, "n_itemname", "char(30)");
	if (status != MEM_S_SUCCESS) {
		MEMclose(&pdc_bufr);
		_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
		return (PDM_E_WRITE_FORMAT);
	}
	status = MEMwrite_format(pdc_bufr, "p_partrev", "char(30)");
	if (status != MEM_S_SUCCESS) {
		MEMclose(&pdc_bufr);
		_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
		return (PDM_E_WRITE_FORMAT);
	}
	status = MEMwrite_format(pdc_bufr, "p_childno", "char(20)");
	if (status != MEM_S_SUCCESS) {
		MEMclose(&pdc_bufr);
		_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
		return (PDM_E_WRITE_FORMAT);
	}
	status = MEMwrite_format(pdc_bufr, "p_pdcno", "integer");
	if (status != MEM_S_SUCCESS) {
		MEMclose(&pdc_bufr);
		_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
		return (PDM_E_WRITE_FORMAT);
	}
	/* insert new entries in child_bufr into pdmcit */

	sql_str1[0] = '\0';
	sprintf(sql_str1, "INSERT INTO pdmcit (p_citno,n_catalogname,n_itemname,n_itemrev,n_cofilename,p_childno,p_attached, p_history,p_quantity,p_usageid,p_tagno,p_alttagno,p_incbom,p_explode,p_pdcno) VALUES ");
	set_dataptr = (char **) data_buffers->data_ptr;
	for (i = 0; i < child_bufr->rows; i++) {
		nxi = i * child_bufr->columns;


                if (!strcmp(PDMexec->catalog, child_data[nxi + m1]) &&
                    !strcmp(PDMexec->part_num, child_data[nxi + m2]) &&
                    !strcmp(PDMexec->revision, child_data[nxi + m3]))
                   {
                 _PDMdebug(fname, "Ist level cyclic placement not allowed \n");
                                MEMclose(&pdc_bufr);
                     return(PDM_E_CYCLIC_1STLEVEL);
                   }
		/* find the p_citno of this child */

		p_pdcno = p_pdcno + 1;
		p_citno = -1;
		for (j = 0; j < data_buffers->rows; j++) {
			nxj = j * data_buffers->columns;
		if (!strcmp(set_dataptr[nxj + n1], child_data[nxi + m1]) &&
		    !strcmp(set_dataptr[nxj + n2], child_data[nxi + m2]) &&
		    !strcmp(set_dataptr[nxj + n3], child_data[nxi + m3])) {
			p_citno = atol(set_dataptr[nxj + n4]);
			sprintf(pdc_row, "%s\1%s\1%s\1%s\1%d\1",
			 child_data[nxi + m1], child_data[nxi + m2],
			child_data[nxi + m3], child_data[nxi + m6], p_pdcno);
			status = MEMwrite(pdc_bufr, pdc_row);
			if (status != MEM_S_SUCCESS) {
				MEMclose(&pdc_bufr);
_PDMdebug(fname, "MEMwrite of pdc_bufr failed status %d%s \n", status, pdc_row);
					return (PDM_E_WRITE_ROW);
				}
				break;
			}
		}
		if (p_citno == -1) {
		_PDMdebug(fname, "p_citno not found for part : \n");
	        _PDMdebug(fname, "Catalog %s \n Partnum %s \n Partrev %s\n",
	child_data[nxi + m1], child_data[nxi + m2], child_data[nxi + m3]);
			MEMclose(&pdc_bufr);
			return (PDM_E_INTERNAL_ERROR);
		}
		sql_str2[0] = '\0';

/* support added for background part (p_incstr):
     p_incstr   p_incbom        p_incbom
     Y          Y               Y
     N          N               N
     Y          N               A
     N          Y               B
  */
     if ((!strcmp (child_data[nxi+m10], "Y") ||
                          !strcmp (child_data[nxi+m10], "y")) &&
         (!strcmp (child_data[nxi+m14], "Y") ||
                          !strcmp (child_data[nxi+m14], "y")))
                                        strcpy (child_data[nxi+m10], "Y");
     else if ((!strcmp (child_data[nxi+m10], "N") ||
                          !strcmp (child_data[nxi+m10], "n")) &&
         (!strcmp (child_data[nxi+m14], "N") ||
                          !strcmp (child_data[nxi+m14], "n")))
                                        strcpy (child_data[nxi+m10], "N");
     else if ((!strcmp (child_data[nxi+m10], "N") ||
                          !strcmp (child_data[nxi+m10], "n")) &&
         (!strcmp (child_data[nxi+m14], "Y") ||
                          !strcmp (child_data[nxi+m14], "y")))
                           strcpy (child_data[nxi+m10], "A");
        else if ((!strcmp (child_data[nxi+m10], "Y") ||
                          !strcmp (child_data[nxi+m10], "y")) &&
         (!strcmp (child_data[nxi+m14], "N") ||
                          !strcmp (child_data[nxi+m14], "n")))
                                        strcpy (child_data[nxi+m10], "B");

        sprintf(sql_str2, "(%d,'%s','%s','%s','%s',%s,'%s','%s',%s,'%s',%s,'%s', '%s','%s',%d)", p_citno, child_data[nxi + m1], child_data[nxi + m2], child_data[ nxi + m3], child_data[nxi + m13],child_data[nxi+m6],child_data[nxi+m12],child_data[nxi+m5],child_data[nxi+m4],child_data[nxi+m7],child_data[nxi+m8],child_data[nxi+m9],child_data[nxi+m10],child_data[nxi + m11], p_pdcno);
  
		sql_str[0] = '\0';
		sprintf(sql_str, "%s %s", sql_str1, sql_str2);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS) {
			switch (status) {
			case PDMS_NO_SUCH_TABLE:
			_PDMdebug(fname, "%s \n", "pdmcit not found");
			break;
			case PDMS_NO_SUCH_ATTRIBUTE:
               _PDMdebug(fname, "%s \n", "Required column in pdmcit not found");
			break;
			default:
			break;
			}
			MEMclose(&pdc_bufr);
			return (PDM_E_SQL_STMT);
		}
	}			/* end .. for all children */

	if ((parm_buffer == NULL) || (parm_buffer->rows == 0)) {
	_PDMdebug(fname,"EXIT:PDMinsert_citinfo - No dynamic part info\n");
		MEMclose(&pdc_bufr);
		return (PDM_S_SUCCESS);
	}
	/* set offsets in parm_buffer */

	m1 = -1;
	m2 = -1;
	m3 = -1;
	m4 = -1;
	m5 = -1;
	m6 = -1;
	m7 = -1;
	m8 = -1;
	m9 = -1;

	status = MEMbuild_array(pdc_bufr);
	if (status != MEM_S_SUCCESS) {
      _PDMdebug(fname, "MEMbuild_array of pdc_bufr failed status %d\n", status);
		MEMclose(&pdc_bufr);
		return (PDM_E_BUILD_ARRAY);
	}
	status = MEMbuild_array(parm_buffer);
	if (status != MEM_S_SUCCESS) {
	_PDMdebug(fname, "MEMbuild_array failed status %d\n", status);
		MEMclose(&pdc_bufr);
		return (PDM_E_BUILD_ARRAY);
	}
	fly_data = (char **) parm_buffer->data_ptr;
	for (i = 0; i < parm_buffer->rows; i++) {
		status = MEMreset_buffer_no(parmdata_buffers, i + 1);
		if (status != MEM_S_SUCCESS) {
			MEMclose(&pdc_bufr);
	_PDMdebug(fname, "MEMreset_buffer_no failed status %d\n", status);
			return (PDM_E_RESET_BUFFER);
		}
         if (PDMdebug_on) 
         MEMprint_buffer("data_buffers",parmdata_buffers,PDM_DEBUG_FILE);
	status = PDMi_insert_pdcinfo(fly_data[i], pdc_bufr, parmdata_buffers);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fname, "PDMi_insert_pdcinfo failed status %s\n", status);
			MEMclose(&pdc_bufr);
			return (PDM_E_COPY_BUFFER);
		}
	}
	MEMclose(&pdc_bufr);
     }/* Finished modifying after checking the update flag */
	_PDMdebug(fname,"EXIT:\n");
	return (PDM_S_SUCCESS);
}
