#include <stdio.h>
#include "NFMdef.h"
#include "ERR.h"
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDMdbs_err.h"
#include		"PDMproto.h"
#define   PDM_I_NO_CHILDREN 74486011
#define   PDM_I_SOMEONE_PROCESSING 74485931
#define   PDM_E_REBUILD_STRUCTURE 74485939

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static long     status;

int PDMprocess_struc_attach(n_catalogno,p_itemno,data_bufr, parent_row, parent_row_offset)
        int             n_catalogno,p_itemno;
	MEMptr          data_bufr;
	int		parent_row, parent_row_offset;
{
	char          **column;
	char          **data;
	char           **struc_data;
	MEMptr          struc_bufr = NULL;
	char            sql_str[1024],s[512];
	char            p_attached[2];
	int             i, j, nx;
	int             a1, a2, a3, a4, a5, a6;

	PDMdebug("ENTER:PDMprocess_struc_atchmts\n");


        sprintf (s, "parent_row = %d , parent_row_offset = %d\n",
                     parent_row, parent_row_offset);
	PDMdebug(s);

	status = MEMbuild_array(data_bufr);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	if (PDMdebug_on) {
		MEMprint_buffer("data_bufr", data_bufr, PDM_DEBUG_FILE);
	}
	column = (char **) data_bufr->column_ptr;
	data = (char **) data_bufr->data_ptr;
	a1 = -1;
	a2 = -1;
	a3 = -1;
        a4 = -1;
        a5 = -1;
        a6 = -1;

	for (i = 0; i < data_bufr->columns; i++) {
		if (!strcmp(column[i], "n_citno"))
			a1 = i;
		if (!strcmp(column[i], "n_fileco"))

			a2 = i;
		if (!strcmp(column[i], "n_level"))
			a3 = i;
                if (!strcmp(column[i], "n_catalogname"))
                        a4 = i;
                if (!strcmp(column[i], "n_itemname"))
                        a5 = i;
                if (!strcmp(column[i], "n_itemrev"))
                        a6 = i;
		if (a1 != -1 && a2 != -1 && a3 != -1 && a4 != -1 && a5 != -1 && a6 != -1) {
			break;
		}
	}
	if (a1 == -1 || a2 == -1 || a3 == -1 || a4 == -1 || a5 == -1 || a6 == -1) {
		PDMdebug("Could_not set offsets in data_bufr\n");
		return (PDM_E_BUFFER_FORMAT);
	}

        /* modified to accomodate NFM2.2 changes */
	for (i = 0; i < data_bufr->rows; i++) {
        	nx = i * data_bufr->columns;
	    if ((i != parent_row) && (strcmp(data[nx + a2], "Y"))) {
		p_attached[0] = '\0';
		sql_str[0] = '\0';
		sprintf(sql_str, "%s %s %s '%s' %s '%s' %s '%s' %s %d %s %d",
    "SELECT p_impattached,p_expattached FROM PDMCIT WHERE n_catalogname =", data[nx + a4], "AND n_itemname =", data[nx + a5], "AND n_itemrev =", data[nx + a6],"AND p_level = ",data[nx+a3],"AND n_catalogno = ",n_catalogno,"AND p_itemno = ",p_itemno); 
		status = SQLquery(sql_str, &struc_bufr, 512);
		if (status != SQL_S_SUCCESS) {
			MEMclose(&struc_bufr);
			sprintf(s, "SQLquery failed status %d\n", status);
			PDMdebug(s);
			return (PDM_E_SQL_QUERY);
		}
                if (status == SQL_S_SUCCESS) {
		status = MEMbuild_array(struc_bufr);
		if (status != MEM_S_SUCCESS) {
			MEMclose(&struc_bufr);
			sprintf(s, "MEMbuild_array failed status %d\n", status);
			return (PDM_E_BUILD_ARRAY);
		}
		struc_data = (char **) struc_bufr->data_ptr;
                strcpy(p_attached,"N"); 
                for (j = 0; j < struc_bufr->rows; ++j) {
			if(!strcmp(struc_data[j],"Y")) {
                                strcpy(p_attached,"Y");
				break;
                        }
                }
                if(!strcmp(p_attached,"Y")) {
			status = MEMwrite_data(data_bufr, "Y", i + 1, a2 + 1);
			if (status != MEM_S_SUCCESS) {

				sprintf(s, "MEMwrite_data failed status %d\n",
					status);
				PDMdebug(s);
				return (PDM_E_WRITE_COLUMN);
			}
                } 
                MEMclose(&struc_bufr);
                } /* not successful */
             } 
          }
		MEMclose(&struc_bufr);
	PDMdebug("EXIT:PDMprocess_struc_atchmts\n");
	return (PDM_S_SUCCESS);
}
