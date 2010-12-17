#include		<stdio.h>
#include		"SQLerrordef.h"
#include 		"MEMerrordef.h"
#include 		"NFMerrordef.h"
#include		"PDMdbs_err.h"
#include		"MEMstruct.h"
#include		"PDUerror.h"
#include		"PDMproto.h"

long     p_seqno;
long     p_seqno1;
long     p_seqno2;
long     n_level;
long  p_parentno;

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];

extern PDMexec_ptr PDMexec;

static long     status;
static char     s[1024];


int PDMXupdate_exist_bom (bom_name)
char		*bom_name;
{
 char		*fn = "PDMXupdate_exist_bom";


 status = PDMupdate_exist_bom (bom_name);
 if (status != PDM_S_SUCCESS) {
   _PDMdebug (fn, "PDMXupdate_exist_bom failed %d\n", status);
    return (status);
     }


return (PDM_S_SUCCESS);

}

/*
 * Builds bom based on the set information in child_bufr Usefull when
 * generating active BOMs
 * 
 * ws_buffer -> child_bufr attac_bufr
 */


int PDMXXXXXXupdate_exist_bom(ret_bufr)
MEMptr          *ret_bufr;
{

	MEMptr          set_bufr = NULL;
	MEMptr          join_bufr = NULL;
	MEMptr          cat_attr = NULL;
	MEMptr          cit_attr = NULL;
	MEMptr          usr_attr = NULL;
	MEMptr          attr_bufr = NULL;
	char          **column_ptr;
	char            old_bom[40], bom_table[40], temp_table[30];
	char            bom_temp[30], p_explode[2];
	char           *cat_str, *cit_str, *usr_str, *attr_str, *str1;
	char            sql_str[1024];
	int             no_members;
	int             i, a1, a2, a3, a4, size1, size2, size3;
/* added an extra size variable 11/4/91 */
	int		str1_size;
	long            max_level;

	PDMdebug("ENTER:PDMupdate_exist_bom\n");
        *ret_bufr = NULL;

	/* verify part exists */
	status = PDMverify_part(PDMexec->catalog, 
				PDMexec->part_num, PDMexec->revision);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %s %d \n", 
			"PDMverify_part failed : status", status);
		PDMdebug(s);
		return (status);
	}
 
	/* find next level members */
	status = PDMquery_cit_members(PDMexec->user_id, PDMexec->catalog, PDMexec->part_num, PDMexec->revision, 1, &attr_bufr, &set_bufr);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %d\n", 
			"NFMquery_set_members failed status ", status);
		PDMdebug(s);
		return (PDM_E_QUERY_SET_MEMBERS);
	}
	MEMclose(&attr_bufr);
	attr_bufr = NULL;
	status = MEMbuild_array(set_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&set_bufr);
		sprintf(s, "MEMbuild_array failed %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	no_members = set_bufr->rows;
	if (!no_members) {
		MEMclose(&set_bufr);
		return (PDM_I_ATOMIC_PART);
	}

	/* check lock if not locked lock it */
	status = PDMverify_bomlock(PDMexec->catalog, 
				 PDMexec->part_num, PDMexec->revision);
	if (status == PDM_E_BOM_LOCKED) {
		sprintf(s, "%s %s %d \n", 
			"PDMverify_bom_lock  status", status);
		PDMdebug(s);
		return (status);
	} else if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %s %d \n", 
			"PDMverify_bom_lock failed : status", status);
		PDMdebug(s);
		return (status);
	}

	strcpy(old_bom, "");

	/*
	 * find review bom name if it does not exist use the new name
	 */

	status = PDMquery_bom_name(PDMexec->catalog, 
				   PDMexec->part_num, PDMexec->revision, 
				   old_bom);
	if (status != PDM_S_SUCCESS &&
	    status != PDM_E_BOM_NOT_FOUND) {
		sprintf(s, "%s %d \n", 
			"PDMquery_bom_name failed : status", status);
		PDMdebug(s);
		return (status);
	}

	a1 = -1;
	a2 = -1;
	a3 = -1;
	a4 = -1;
	n_level = 1;
	p_seqno = 0;
	p_parentno = 0;
	size1 = 0;
	size2 = 0;
	size3 = 0;

	/* check if part is to be exploded or not */

	status = PDMfind_p_explode(PDMexec->catalog, 
				   PDMexec->part_num, PDMexec->revision, 
				   p_explode);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %d\n", 
			"PDMfind_p_explode failed status ", status);
		PDMdebug(s);
		return (status);
	}
	if (strncmp(p_explode, "Y", 1)) {
		PDMdebug("p_explode for part is not set\n");
		return (PDM_E_EXPLODE_NOT_SET);
	}
	/* find the p_maxlevel of the part */

	status = PDMfind_maxlevel(PDMexec->catalog, 
				  PDMexec->part_num, PDMexec->revision, 
				  &max_level);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %d\n", 
			"PDMfind_maxlevel failed status ", status);
		PDMdebug(s);
		return (status);
	}
	/* if max_level is not set ignore it */

	if (max_level == 0) {
		PDMdebug("The max_level of the part is set to Zero\n");
		max_level = -1;
	}
	status = PDMgen_bomtable_name(bom_table);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %s %d \n", 
			"PDMgen_bomtable_name failed : status", status);
		PDMdebug(s);
		return (status);
	}
	a1 = -1;
	a2 = -1;
	a3 = -1;
	a4 = -1;
	column_ptr = (char **) set_bufr->column_ptr;
	for (i = 0; i < set_bufr->columns; i++) {
		if (!strcmp(column_ptr[i], "n_catalogname"))
			a1 = i;
		if (!strcmp(column_ptr[i], "n_itemname"))
			a2 = i;
		if (!strcmp(column_ptr[i], "n_itemrev"))
			a3 = i;
		if (!strcmp(column_ptr[i], "n_citno"))
			a4 = i;
	}
	if (a1 == -1 || a2 == -1 || a3 == -1 || a4 == -1) {
		MEMclose(&set_bufr);
		PDMdebug("Failed to set offsets in set_bufr\n");
		return (PDM_E_BUFFER_FORMAT);
	}
	status = PDMcreate_temp_table(temp_table);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&set_bufr);
		sprintf(s, "%s %d\n", 
			"PDMcreate_temp_table failed status ", status);
		PDMdebug(s);
		return (status);
	}
	status = PDMload_temp_table(temp_table, set_bufr);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&set_bufr);
		sprintf(s, "DROP TABLE %s", temp_table);
		SQLstmt(s);
		sprintf(s, "%s %d\n", 
			"PDMload_temp_table failed status ", status);
		PDMdebug(s);
		return (status);
	}
	status = PDMcreate_bom_table1(bom_temp);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %d\n", 
			"PDMcreate_bom_table1 failed status ", status);
		PDMdebug(s);
		sprintf(s, "DROP TABLE %s", temp_table);
		SQLstmt(s);
		return (status);
	}
	while (no_members) {
		/* join cits */

		status = PDMjoin_cits(temp_table, &join_bufr);
		if (status != PDM_S_SUCCESS) {
			sprintf(s, "%s %d\n", 
				"PDMjoin_cits failed status ", status);
			PDMdebug(s);
			sprintf(s, "DROP TABLE %s", temp_table);
			SQLstmt(s);
			sprintf(s, "DROP TABLE %s", bom_temp);
			SQLstmt(s);
			return (status);
		}

		/* insert all the members into BOM */

		status = PDMload_bom_table1(PDMexec->user_id, 
					    bom_temp, join_bufr);
		if (status != PDM_S_SUCCESS) {
			MEMclose(&join_bufr);
			sprintf(s, "%s %d\n", 
				"PDMload_bom_table1 failed status ", status);
			PDMdebug(s);
			sprintf(s, "DROP TABLE %s", temp_table);
			SQLstmt(s);
			sprintf(s, "DROP TABLE %s", bom_temp);
			SQLstmt(s);
			return (status);
		}
		MEMclose(&join_bufr);
		join_bufr = NULL;
		no_members = 0;
		status = PDMquery_load_members(PDMexec->user_id, 
				   bom_temp, temp_table, p_seqno1, p_seqno2, 
					       a1, a2, a3, a4, &no_members);
		if (status != PDM_S_SUCCESS) {
			sprintf(s, "DROP TABLE %s", temp_table);
			SQLstmt(s);
			sprintf(s, "DROP TABLE %s", bom_temp);
			SQLstmt(s);
			sprintf(s, "%s %d\n", 
			    "PDMquery_load_members failed status ", status);
			PDMdebug(s);
			return (status);
		}
		/* if at max_level quit */

		if (max_level != -1 && n_level == max_level)
			break;
		n_level = n_level + 1;

	}			/* while there are members at current_level */

	sprintf(s, "DROP TABLE %s", temp_table);
	SQLstmt(s);

	status = PDMcreate_bom_table(PDMexec->user_id, bom_table);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %d\n", 
			"PDMcreate_bom_table failed status ", status);
		PDMdebug(s);
		sprintf(s, "DROP TABLE %s", bom_temp);
		SQLstmt(s);
		return (status);
	}
	status = PDMget_bom_attrbs(PDMexec->user_id, 
				   &cat_attr, &cit_attr, &usr_attr);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "DROP TABLE %s", bom_temp);
		SQLstmt(s);
		sprintf(s, "DROP TABLE %s", bom_table);
		SQLstmt(s);
		sprintf(s, "%s %d\n", 
			"PDMget_bom_attrbs failed status ", status);
		PDMdebug(s);
		return (status);
	}
	status = PDMbuild_attribute_string(cat_attr, &cat_str, &size1);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&cat_attr);
		MEMclose(&cit_attr);
		if (usr_attr != NULL)
			MEMclose(&usr_attr);
		sprintf(s, "%s %d\n", 
			"PDMbuild_attribute_string failed status ", status);
		PDMdebug(s);
		sprintf(s, "DROP TABLE %s", bom_temp);
		SQLstmt(s);
		sprintf(s, "DROP TABLE %s", bom_table);
		SQLstmt(s);
		return (status);
	}
	status = PDMbuild_attribute_string(cit_attr, &cit_str, &size3);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&cat_attr);
		MEMclose(&cit_attr);
		free(cat_str);
		if (usr_attr != NULL)
			MEMclose(&usr_attr);
		sprintf(s, "%s %d\n", 
			"PDMbuild_attribute_string failed status ", status);
		PDMdebug(s);
		sprintf(s, "DROP TABLE %s", bom_temp);
		SQLstmt(s);
		sprintf(s, "DROP TABLE %s", bom_table);
		SQLstmt(s);
		return (status);
	}
	if (usr_attr != NULL) {
		status = PDMbuild_attribute_string(usr_attr, &usr_str, &size2);
		if (status != PDM_S_SUCCESS) {
			sprintf(s, "DROP TABLE %s", bom_temp);
			SQLstmt(s);
			sprintf(s, "DROP TABLE %s", bom_table);
			SQLstmt(s);
			free(cat_str);
			free(cit_str);
			MEMclose(&cit_attr);
			MEMclose(&usr_attr);
			MEMclose(&cat_attr);
			sprintf(s, "%s %d\n", 
			"PDMbuild_attribute_string failed status ", status);
			PDMdebug(s);
			return (status);
		}
	}
	n_level = 1;
	p_seqno = 0;
	sprintf(sql_str, "SELECT * FROM %s %s %d %s", 
		bom_temp, "WHERE n_level = ", n_level, "ORDER BY p_seqno");
	status = SQLquery(sql_str, &attr_bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		sprintf(s, "DROP TABLE %s", bom_temp);
		SQLstmt(s);
		sprintf(s, "DROP TABLE %s", bom_table);
		SQLstmt(s);
		free(cat_str);
		free(cit_str);
		if (size2)
			free(usr_str);
		MEMclose(&cat_attr);
		MEMclose(&cit_attr);
		if (size2)
			MEMclose(&usr_attr);
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
		sprintf(s, "DROP TABLE %s", bom_temp);
		SQLstmt(s);
		return (PDM_E_SQL_QUERY);
	}
/* changed the size1 parameter to str1_size because it was overwriting the
 size 1 value used to the malloc of the attr_str 11/4/91  Beth */
	status = PDMbuild_attribute_string(attr_bufr, &str1, &str1_size);
	if (status != PDM_S_SUCCESS) {
		free(cat_str);
		free(cit_str);
		if (size2)
			free(usr_str);
		MEMclose(&cat_attr);
		MEMclose(&cit_attr);
		if (size2)
			MEMclose(&usr_attr);
		free(str1);
		MEMclose(&attr_bufr);
		sprintf(s, "%s %d\n", 
			"PDMbuild_attribute_string failed status ", status);
		PDMdebug(s);
		sprintf(s, "DROP TABLE %s", bom_temp);
		SQLstmt(s);
		sprintf(s, "DROP TABLE %s", bom_table);
		SQLstmt(s);
		return (status);
	}
	attr_str = (char *) malloc(size1 + size2 + size3 + 100);
	if (attr_str == NULL) {
		free(cat_str);
		free(cit_str);
		if (size2)
			free(usr_str);
		MEMclose(&cat_attr);
		MEMclose(&cit_attr);
		if (size2)
			MEMclose(&usr_attr);
		sprintf(s, "DROP TABLE %s", bom_temp);
		SQLstmt(s);
		free(str1);
		MEMclose(&attr_bufr);
		sprintf(s, "DROP TABLE %s", bom_temp);
		SQLstmt(s);
		sprintf(s, "DROP TABLE %s", bom_table);
		SQLstmt(s);
	}
	sprintf(attr_str, "%s, %s", cat_str, cit_str);
	if (size2) {
		strcat(attr_str, ", ");
		strcat(attr_str, usr_str);
	}
	status = PDMstructure_bom(bom_temp, str1, bom_table, attr_str, 
				  cat_attr, cit_attr, usr_attr, attr_bufr);
	if (status != PDM_S_SUCCESS) {
		free(cat_str);
		free(cit_str);
		if (size2)
			free(usr_str);
		MEMclose(&cat_attr);
		MEMclose(&cit_attr);
		if (size2)
			MEMclose(&usr_attr);
		free(str1);
		free(attr_str);
		MEMclose(&attr_bufr);
		sprintf(s, "%s %d\n", 
			"PDMstructure_bom failed status ", status);
		PDMdebug(s);
		sprintf(s, "DROP TABLE %s", bom_temp);
		SQLstmt(s);
		sprintf(s, "DROP TABLE %s", bom_table);
		SQLstmt(s);
		return (status);
	}
	sprintf(s, "DROP TABLE %s", bom_temp);
	SQLstmt(s);
	free(cat_str);
	free(cit_str);

	MEMclose(&cat_attr);
	MEMclose(&cit_attr);
	free(str1);
	free(attr_str);
	MEMclose(&attr_bufr);
	cat_attr = NULL;
	status = PDMxyz(&cat_attr);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "DROP TABLE %s", bom_table);
		SQLstmt(s);
		sprintf(s, "PDMxyz failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	status = MEMbuild_array(cat_attr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&cat_attr);
		sprintf(s, "MEMbuild_array failed status %d\n", 
			status);
		PDMdebug(s);
		sprintf(s, "DROP TABLE %s", bom_table);
		SQLstmt(s);
		return (PDM_E_BUILD_ARRAY);
	}
	size1 = 0;
	status = PDMbuild_attribute_string(cat_attr, &cat_str, &size1);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&cat_attr);
		sprintf(s, "%s %d\n", 
			"PDMbuild_attribute_string failed status ", status);
		PDMdebug(s);
		sprintf(s, "DROP TABLE %s", bom_table);
		SQLstmt(s);
		return (status);
	}
	/*
	 * at this point BOM is built. all the rows need to be updated with
	 * bomcontent
         */

	status = PDMupdate_bom_attributes(PDMexec->user_id, 
			   bom_table, cat_attr, cat_str, usr_attr, usr_str);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "DROP TABLE %s", bom_table);
		SQLstmt(s);
		free(cat_str);
		MEMclose(&cat_attr);
		if (usr_attr != NULL) {
			MEMclose(&usr_attr);
			free(usr_str);
		}
		sprintf(s, "%s %d\n", 
			"PDMupdate_exist_bom_attributes failed status ", status);
		PDMdebug(s);
		return (status);
	}
	free(cat_str);
	MEMclose(&cat_attr);
	if (usr_attr != NULL) {
		MEMclose(&usr_attr);
		free(usr_str);
	}
          
       status = PDMswap_bom_tables(PDMexec->catalog, PDMexec->part_num, 
                                PDMexec->revision, old_bom, bom_table);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "DROP TABLE %s", bom_table);
                SQLstmt(s);
                sprintf(s, "%s %s %d \n", 
                        "PDMswap_bom_tables", "failed : status", status);
                PDMdebug(s);
                return (status);
        }


	MEMclose(&set_bufr);

	PDMdebug("EXIT:PDMupdate_exist_bom\n");
        return (PDM_S_SUCCESS);

}
