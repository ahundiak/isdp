#include		<stdio.h>
#include		"SQLerrordef.h"
#include 		"MEMerrordef.h"
#include 		"NFMerrordef.h"
#include		"PDMdbs_err.h"
#include		"MEMstruct.h"
#include		"PDUerror.h"
#include		"PDMproto.h"

extern	long		p_seqno;
extern	long		p_seqno1;
extern	long		p_seqno2;
extern	long		n_level;
extern	long		p_parentno;
static  long		status;
static  char		s[1024];
extern		int		PDMdebug_on;
extern		char	PDM_DEBUG_FILE[];


/* 
		Creates a temporary table to hold the set info
		at one level. This is used for a later join 
		on n_citno.
*/

int		PDMcreate_temp_table(temp_table)
char	*temp_table;
{
	char		sql_str[1024];

	PDMdebug("ENTER:PDMcreate_temp_table\n");
	status = PDMgen_bomtable_name(temp_table);
	if(status != PDM_S_SUCCESS)
	{
		PDMdebug("PDMcreate_temp_table\n");
		sprintf(s, "%s %d\n", 
		"PDMgen_bomtable_name failed status ", status);
		PDMdebug(s);
		return(status);
	}
	sprintf(sql_str, "CREATE TABLE %s( ", temp_table);	
	strcat(sql_str, "p_parentno integer, ");
	strcat(sql_str, "n_catalogname char(14), ");
	strcat(sql_str, "n_itemname char(30), ");
	strcat(sql_str, "n_itemrev char(30), ");
	strcat(sql_str, "p_citno integer");
	strcat(sql_str, ")");
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s, "SQLstmt failed status %d\n", status);
		PDMdebug(s);
		PDMdebug("sql_str :");
		PDMdebug(sql_str);
		PDMdebug("\n");
		return(PDM_E_SQL_STMT);
	}
	PDMdebug("EXIT:PDMcreate_temp_table\n");
	return(PDM_S_SUCCESS);
}

/*
	loads the temp_table with info from set_bufr
	deletes previous entries first	
*/

int	PDMload_temp_table(temp_table, set_bufr)
char	*temp_table;
MEMptr	set_bufr;
{
	char		**column_ptr;
	char		sql_str[1024];
	char		sql_str1[1024];
	char		sql_str2[1024];
	char		**set_data;
	int			set_rows;
	int			i, nxi;
	int			a1, a2, a3, a4;

	PDMdebug("ENTER:PDMload_temp_table \n");
	a1 = -1; a2 = -1 ; a3 = -1; a4 = -1; 
	status = MEMbuild_array(set_bufr);
    if(status != MEM_S_SUCCESS)
    {
		sprintf(s, "%s %d \n", 
		"MEMbuild_array failed - status ", status);
        PDMdebug(s);
   		return(PDM_E_BUILD_ARRAY);
    }
	column_ptr = (char **) set_bufr->column_ptr;
	set_rows = set_bufr->rows;
	for(i=0;i<set_bufr->columns;i++)
	{
		if(!strcmp(column_ptr[i], "n_catalogname"))  a1 = i;
		if(!strcmp(column_ptr[i], "n_itemname")) 	a2 = i;
		if(!strcmp(column_ptr[i], "n_itemrev")) 		a3 = i;
		if(!strcmp(column_ptr[i], "n_citno")) 		a4 = i;
	}
	if(a1 == -1 || a2 == -1 || a3 == -1 || a4 == -1 )
	{
		PDMdebug("PDMload_temp_table : Could not set offsets \n");
		return(PDM_E_BUFFER_FORMAT);
	}

	/* delete previous entries in temp_table */

	sprintf(s, "DELETE FROM %s", temp_table);
	status = SQLstmt(s);
	if(status != SQL_S_SUCCESS )
	{
	}
	sprintf(sql_str1, "INSERT INTO %s ", temp_table);
	strcat(sql_str1, "(n_catalogname, n_itemname, n_itemrev, ");
	strcat(sql_str1, "p_citno, p_parentno)");
	set_data = (char **) set_bufr->data_ptr;

	/* insert all rows */

	for(i=0;i<set_rows;i++)
	{
		nxi = i * set_bufr->columns;
		sprintf(sql_str2, "VALUES('%s', '%s', '%s', %d, %d)", 
		set_data[nxi+a1], set_data[nxi+a2], set_data[nxi+a3], 
		atol(set_data[nxi+a4]), p_parentno);
		sql_str[0] = '\0';
		sprintf(sql_str, "%s %s", sql_str1, sql_str2);
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
			PDMdebug("sql string : "); PDMdebug(sql_str);
			return(PDM_E_SQL_STMT);
		}
	}
	PDMdebug("EXIT:PDMload_temp_table \n");
	return(PDM_S_SUCCESS);
}

int		PDMcreate_bom_table1(temp_table)
char	*temp_table;
{
	char		sql_str[1024];

	PDMdebug("ENTER:PDMcreate_bom_table1\n");
	status = PDMgen_bomtable_name(temp_table);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s, "%s %d\n", 
		"PDMgen_bomtable_name failed status ", status);
		PDMdebug(s);
		return(status);
	}
	sprintf(sql_str, "CREATE TABLE %s( ", temp_table);	
	strcat(sql_str, "p_parentno integer, ");
	strcat(sql_str, "p_seqno integer, ");
	strcat(sql_str, "n_level integer, ");
	strcat(sql_str, "p_tagno integer, ");
	strcat(sql_str, "p_attached char(1), ");
	strcat(sql_str, "n_catalogname char(14), ");
	strcat(sql_str, "n_itemname char(30), ");
	strcat(sql_str, "n_itemrev char(30), ");
	strcat(sql_str, "p_history char(10), ");
	strcat(sql_str, "p_orient char(240), ");
	strcat(sql_str, "p_quantity double, ");
	strcat(sql_str, "p_childno char(20), ");
	strcat(sql_str, "p_usageid char(25), ");
	strcat(sql_str, "p_viewid char(25), ");
	strcat(sql_str, "p_alttagno char(25), ");
	strcat(sql_str, "p_incbom char(1), ");
	strcat(sql_str, "p_explode char(1)");
	strcat(sql_str, ")");
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s, "SQLstmt failed status %d\n", status);
		PDMdebug(s);
		PDMdebug("sql_str :");
		PDMdebug(sql_str);
		PDMdebug("\n");
		return(PDM_E_SQL_STMT);
	}
	PDMdebug("EXIT:PDMcreate_bom_table1\n");
	return(PDM_S_SUCCESS);
}

int	  PDMjoin_cits(temp_table, join_bufr)
char	*temp_table;
MEMptr	*join_bufr;
{
	char	sql_str[1024];

	PDMdebug("ENTER:PDMjoin_cits\n");
	sprintf(sql_str, "%s %s %s %s %s t1, %s t2 WHERE %s %s", 
	"SELECT t1.p_parentno, t1.n_catalogname, ", 
	"t1.n_itemname, t1.n_itemrev, ", 
	"t2.p_history, t2.p_orient, t2.p_quantity, ", 
     "t2.p_childno, t2.p_viewid, t2.p_usageid, t2.p_tagno, t2.p_alttagno, t2.p_incbom, t2.p_explode FROM ", 
	temp_table, 
	"pdmcit", 
	"t1.p_citno = t2.p_citno", 
	"ORDER BY t1.n_catalogname, t1.n_itemname, t1.n_itemrev "); 
	status = SQLquery(sql_str, join_bufr, 2048);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
		PDMdebug("sql string : ");
		PDMdebug(sql_str);
		MEMclose(join_bufr);
		return(PDM_E_SQL_QUERY);
	}
	PDMdebug("EXIT:PDMjoin_cits\n");
	return(PDM_S_SUCCESS);
}

/*
	Loads BOM table with cit+ catalog, part, rev info 
	at a level.
*/

int PDMload_bom_table1(user_id, bom_table, join_bufr)
long	user_id;
char	*bom_table;
MEMptr	join_bufr;
{
	MEMptr		bufr = NULL;
	char		**column_ptr;
	char		**data;
	char		**join_data;
	char		attr_str[1024];
	char		val_str[2048];
	char		ins_str[4048];
	char		sql_str[1024];
	int			i, j, k, nxi;
	int			a14, a15, a13;
        char                    s[512];

/* ANSI */
	user_id = 0;

	PDMdebug("ENTER:PDMload_bom_table1\n");
	sprintf(s, "bom_table : %s\n", bom_table);
	PDMdebug(s);	
	if(PDMdebug_on)
	MEMprint_buffer("join_bufr", join_bufr, PDM_DEBUG_FILE);

	sprintf(sql_str, "%s %s", 
	"SELECT MAX(p_seqno) FROM ", bom_table );
	status = SQLquery(sql_str, &bufr, 512);
	if(status != SQL_S_SUCCESS)
	{
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			MEMclose(&bufr);
			p_seqno = 0;
			p_seqno1 = 1;
		}
		else
		{
			return(PDM_E_SQL_QUERY);
		}
	}
	else
	{
		status = MEMbuild_array(bufr);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&bufr);
			return(PDM_E_BUILD_ARRAY);
		}
		data = (char **) bufr->data_ptr;
		p_seqno = atol(data[0]);
		p_seqno1 = p_seqno +1;
		MEMclose(&bufr);
	}

	status = MEMbuild_array(join_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "%s %d\n", 
		"MEMbuild_array failed status ", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
        column_ptr=(char **)join_bufr->column_ptr;
        a15 = -1;
        a14 = -1;
        a13 = -1;
        for(k=0;k<join_bufr->columns;k++)
        {
          if(!strcmp(column_ptr[k], "p_quantity")) a15 = k;
          if(!strcmp(column_ptr[k], "p_tagno")) a14 = k;
          if(!strcmp(column_ptr[k], "p_incbom")) a13 = k;
        }
	if(a15 == -1  || a14 == -1 || a13 == -1)
	{
                sprintf(s, "p_quantity offset %d\n", a15);
                PDMdebug(s);
		PDMdebug("PDMload_bom_table1 :\n");
		PDMdebug("Failed to find offsets in join_bufr\n");
		return(PDM_E_BUFFER_FORMAT);
	}

	/* prepare insert string */

	sprintf(attr_str, "INSERT INTO %s (", bom_table);
   strcat(attr_str, "p_seqno, p_parentno, n_level, p_quantity, p_tagno, p_attached, ");
	strcat(attr_str, "n_catalogname, n_itemname, n_itemrev, ");			
	strcat(attr_str, "p_history, p_orient, ");
	strcat(attr_str, "p_childno, p_viewid, ");
	strcat(attr_str, "p_usageid, p_alttagno, ");

	strcat(attr_str, "p_incbom, p_explode");
	strcat(attr_str, ")");

	join_data = (char **) join_bufr->data_ptr;
	for(i=0;i<join_bufr->rows;i++)
	{
		nxi = i * join_bufr->columns;
                if((strncmp(join_data[nxi+a13], "N", 1)) && (strncmp(join_data[nxi+a13], "n", 1)))
             {
		p_seqno = p_seqno +1;
		sprintf(val_str, "VALUES (%d, %d, %d, %s, %s, 'N'", 
		p_seqno, atol(join_data[nxi+0]), n_level, join_data[nxi+a15], join_data[nxi+a14]);

		for(j=1;j<join_bufr->columns;j++)
		{
                        if(j == a15 || j == a14) continue;
                        else
                        {
			strcat(val_str, ", '");
			strcat(val_str, join_data[nxi+j]);
			strcat(val_str, "'");
                        }
		}
		strcat(val_str, ")");
		sprintf(ins_str, "%s %s", attr_str, val_str);
		status = SQLstmt(ins_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
			PDMdebug("sql string: ");
			PDMdebug(ins_str);			
			PDMdebug("\n");
			return(PDM_E_SQL_STMT);
		}
              }
	}
	p_seqno2 = p_seqno;
	PDMdebug("EXIT:PDMload_bom_table1\n");
	return(PDM_S_SUCCESS);
}

int		PDMcreate_bom_table(uid, temp_table)
long	uid;
char	*temp_table;
{
	char		*sql_str;
	MEMptr		cat_attr = NULL;
	MEMptr		cit_attr = NULL;
	MEMptr		usr_attr = NULL;
	int			size;
	int			i;
	char		**column_ptr;
	char		**format_ptr;
	
	PDMdebug("ENTER:PDMcreate_bom_table\n");
	status = PDMget_bom_attrbs(uid, &cat_attr, &cit_attr, &usr_attr);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s, "PDMget_bom_attrbs failed status %d\n", status);
		PDMdebug(s);
		return(status);
	}
	if(usr_attr != NULL)
	{
		status = MEMbuild_array(usr_attr);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&cat_attr);
			MEMclose(&cit_attr);
			MEMclose(&usr_attr);
			sprintf(s, "MEMbuild_array failed status %d\n", status);
			PDMdebug(s);
			return(PDM_E_BUILD_ARRAY);
		}
	}
	size = 1024;
	if(usr_attr != NULL)
	{
		column_ptr = (char **) usr_attr->column_ptr;
		for(i=0;i<usr_attr->columns;i++)
		{
			size = size + strlen(column_ptr[i]);
		}
	}
	sql_str = (char *) malloc(size + 100);
	if(sql_str == NULL)
	{
		MEMclose(&cat_attr);
		MEMclose(&cit_attr);
		MEMclose(&usr_attr);
		sprintf(s, "Could not malloc\n");
		PDMdebug(s);
		return(PDM_E_COULD_NOT_MALLOC);
	}
	sprintf(sql_str, "CREATE TABLE %s( ", temp_table);	
	strcat(sql_str, "p_parentno integer, ");
	strcat(sql_str, "p_seqno integer, ");
	strcat(sql_str, "n_level integer, ");
	strcat(sql_str, "p_tagno integer, ");
	strcat(sql_str, "p_attached char(1), ");
/*	strcat(sql_str, "n_catalogname char(14), ");
	strcat(sql_str, "n_itemname char(30), ");
	strcat(sql_str, "n_itemrev char(30), "); */
	strcat(sql_str, "p_history char(10), ");
	strcat(sql_str, "p_orient char(240), ");
	strcat(sql_str, "p_quantity double, ");
	strcat(sql_str, "p_childno char(20), ");
	strcat(sql_str, "p_usageid char(25), ");
	strcat(sql_str, "p_viewid char(25), ");
	strcat(sql_str, "p_alttagno char(25), ");
	strcat(sql_str, "p_incbom char(1), ");
	strcat(sql_str, "p_explode char(1), ");
/*	strcat(sql_str, "n_itemdesc char(40), "); 
	strcat(sql_str, "p_creationdate char(10), ");
	strcat(sql_str, "p_creationtime char(8), ");
	strcat(sql_str, "p_updatedate char(10), ");
	strcat(sql_str, "p_updatetime char(8), "); */
	strcat(sql_str, "p_incpartrpt char(1), ");
	strcat(sql_str, "p_mrpbomuom char(10), ");
	strcat(sql_str, "p_mrpeffectdate char(8), ");
	strcat(sql_str, "p_mrpinvuom char(10)");

	if(usr_attr != NULL)
	{
		column_ptr = (char **) usr_attr->column_ptr;
		format_ptr = (char **) usr_attr->format_ptr;
		for(i=0;i<usr_attr->columns;i++)
		{
			strcat(sql_str, ", ");
			strcat(sql_str, column_ptr[i]);
			strcat(sql_str, " ");
			strcat(sql_str, format_ptr[i]);
		}
	}
	strcat(sql_str, ")");
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		free(sql_str);
		MEMclose(&cat_attr);
		MEMclose(&cit_attr);
		MEMclose(&usr_attr);
		sprintf(s, "SQLstmt failed status %d\n", status);
		PDMdebug(s);
		PDMdebug("sql_str :");
		PDMdebug(sql_str);
		PDMdebug("\n");
		return(PDM_E_SQL_STMT);
	}
	MEMclose(&cat_attr);
	MEMclose(&cit_attr);
	MEMclose(&usr_attr);
	free(sql_str);
	PDMdebug("EXIT:PDMcreate_bom_table\n");
	return(PDM_S_SUCCESS);
}

/*
	Loads BOM table with cit+ catalog, part, rev info 
	at a level.
*/

int PDMload_bom_table(user_id, bom_table, join_bufr, 
	cat_attr, cat_str, usr_attr, usr_str, set_bufr)
long	user_id;
char	*bom_table;
MEMptr	join_bufr;
MEMptr	cat_attr;
MEMptr	usr_attr;
char	*cat_str;
char	*usr_str;
MEMptr	set_bufr;
{
	char		**column_ptr;
	char		**join_data;
	char		**set_data;
	char		**cat_columns;
	char		**cat_format;
	char		**usr_columns = NULL;
	char		**usr_format = NULL;
	char 		*val_str;
	char		*ins_str = NULL;
	char		*attr_str;
	int			i, k, nxi, nxp, size, size1;
	int			a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13;
	int			p, p1, p2, p3, p4;

/* ANSI */
	user_id = 0;

	PDMdebug("ENTER:PDMload_bom_table\n");
	sprintf(s, "bom_table : %s\n", bom_table);
	PDMdebug(s);	
	sprintf(s, "cat_str : %s\n", cat_str);
	PDMdebug(s);
	sprintf(s, "usr_str : %s\n", usr_str);
	PDMdebug(s);
/*	if(PDMdebug_on)
	MEMprint_buffer("join_bufr", join_bufr, PDM_DEBUG_FILE);
	if(PDMdebug_on)
	MEMprint_buffer("cat_attr", cat_attr, PDM_DEBUG_FILE);
	if(PDMdebug_on)
	MEMprint_buffer("usr_attr", usr_attr, PDM_DEBUG_FILE);
*/
	status = MEMbuild_array(set_bufr);
	if(status != MEM_S_SUCCESS)
	{
		PDMdebug("PDMload_bom_table\n");
		sprintf(s, "%s %d\n", 
		"MEMbuild_array failed status ", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	set_data = (char **) set_bufr->data_ptr;
	p1 = -1; p2 = -1; p3 = -1; p4 = -1;
	column_ptr = (char **) set_bufr->column_ptr;
	for(i=0;i<set_bufr->columns;i++)
	{
		if(!strcmp(column_ptr[i], "n_catalogname")) 	p1 = i;
		if(!strcmp(column_ptr[i], "n_itemname")) 	p2 = i;
		if(!strcmp(column_ptr[i], "n_itemrev"))		p3 = i;
		if(!strcmp(column_ptr[i], "n_level")) 		p4 = i;
	}	
	if(p1 == -1 || p2 == -1 || p3 == -1 || p4 == -1 )
	{
		PDMdebug("PDMload_bom_table :\n");
		PDMdebug("Failed to find offsets in join_bufr\n");
		return(PDM_E_BUFFER_FORMAT);
	}
	for(i=0;i<set_bufr->rows;i++)
	{
		status = MEMwrite_data(set_bufr, "", i+1, p4+1);
		if(status != MEM_S_SUCCESS)
		{
			PDMdebug("PDMload_bom_table\n");
			sprintf(s, "%s %d\n", 
			"MEMwrite_data failed status ", status);
			PDMdebug(s);
			return(PDM_E_WRITE_ROW);
		}
	}

	status = MEMbuild_array(join_bufr);
	if(status != MEM_S_SUCCESS)
	{
		PDMdebug("PDMload_bom_table\n");
		sprintf(s, "%s %d\n", 
		"MEMbuild_array failed status ", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}

	a1 = -1; a2 = -1; a3 = -1; a4 = -1;
	a5 = -1; a6 = -1; a7 = -1; a8 = -1; 
	a9 = -1; a10 = -1;a11 = -1; a12 = -1; a13 = -1;

	column_ptr = (char **) join_bufr->column_ptr;
	for(i=0;i<join_bufr->columns;i++)
	{
		if(!strcmp(column_ptr[i], "n_catalogname")) 	a1 = i;
		if(!strcmp(column_ptr[i], "n_itemname")) 		a2 = i;
		if(!strcmp(column_ptr[i], "n_itemrev"))		a3 = i;
		if(!strcmp(column_ptr[i], "p_history")) 		a4 = i;
		if(!strcmp(column_ptr[i], "p_orient")) 		a5 = i;
		if(!strcmp(column_ptr[i], "p_quantity"))		a6 = i;
		if(!strcmp(column_ptr[i], "p_usageid"))		a7 = i;
		if(!strcmp(column_ptr[i], "p_viewid"))		a8 = i;
		if(!strcmp(column_ptr[i], "p_parentno"))		a9 = i;
		if(!strcmp(column_ptr[i], "p_childno"))		a10 = i;
		if(!strcmp(column_ptr[i], "p_tagno"))		a11 = i;
		if(!strcmp(column_ptr[i], "p_alttagno"))		a11 = i;
		if(!strcmp(column_ptr[i], "p_incbom"))		a12 = i;
		if(!strcmp(column_ptr[i], "p_explode"))		a13 = i;
	}	
	if(a1 == -1 || a2 == -1 || a3 == -1 || a4 == -1 ||
       a5 == -1 || a6 == -1 || a7 == -1 || a8 == -1 || 
	   a9 == -1 || a10 == -1 || a11 == -1 || a12 == -1 || a13 == -1)
	{
		PDMdebug("PDMload_bom_table :\n");
		PDMdebug("Failed to find offsets in join_bufr\n");
		return(PDM_E_BUFFER_FORMAT);
	}
	status = MEMbuild_array(cat_attr);
	if(status != MEM_S_SUCCESS)
	{
		PDMdebug("PDMload_bom_table\n");
		sprintf(s, "%s %d\n", 
		"MEMbuild_array failed status ", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	cat_columns = (char **) cat_attr->column_ptr;
	cat_format = (char **) cat_attr->format_ptr;
	size = strlen(cat_str);
	if(usr_attr != NULL)
    {
		status = MEMbuild_array(usr_attr);
		if(status != MEM_S_SUCCESS)
		{
			PDMdebug("PDMload_bom_table\n");
			sprintf(s, "%s %d\n", 
			"MEMbuild_array failed status ", status);
			PDMdebug(s);
			return(PDM_E_BUILD_ARRAY);
		}
		usr_columns = (char **) usr_attr->column_ptr;
		usr_format = (char **) usr_attr->format_ptr;
		size = size + strlen(usr_str);
    }

	size = size + 512;
	attr_str = (char *) malloc(size);
	if(attr_str == NULL)
	{
		PDMdebug("PDMload_bom_table :\n");
		PDMdebug("Failed to malloc\n");
		return(PDM_E_COULD_NOT_MALLOC);
	}	
	size1 = 0;
	size1 = size1 + cat_attr->row_size;
	if(usr_attr != NULL)
		size1 = size1 + usr_attr->row_size;

	val_str = (char *) malloc(size1);
	if(ins_str == NULL)
	{
		free(attr_str);
		PDMdebug("PDMload_bom_table :\n");
		PDMdebug("Failed to malloc\n");
		return(PDM_E_COULD_NOT_MALLOC);
	}
	ins_str = (char *) malloc(size + size1);
	if(ins_str == NULL)
	{
		free(attr_str);
		free(val_str);
		PDMdebug("PDMload_bom_table :\n");
		PDMdebug("Failed to malloc\n");
		return(PDM_E_COULD_NOT_MALLOC);
	}

	/* prepare insert string */

	sprintf(attr_str, "INSERT INTO %s (", bom_table);
	strcat(attr_str, "n_catalogname, n_itemname, n_itemrev, ");			
	strcat(attr_str, cat_str);
	if(usr_attr!= NULL)
	{
		strcat(attr_str, ", ");
		strcat(attr_str, usr_str);
	}
	strcat(attr_str, ") VALUES (");

	join_data = (char **) join_bufr->data_ptr;
	for(i=0;i<join_bufr->rows;i++)
	{
		nxi = i * join_bufr->columns;
		sprintf(val_str, "'%s', '%s', '%s', ", 
		join_data[nxi+a1], join_data[nxi+a2], join_data[nxi+a3]);
		p_seqno = p_seqno +1;
		for(p=0;p<set_bufr->rows;p++)
		{
			nxp = p * set_bufr->columns;
			if(!strcmp(join_data[nxi+a1], set_data[nxp+p1])  && 
			   !strcmp(join_data[nxi+a2], set_data[nxp+p2])  && 
			   !strcmp(join_data[nxi+a3], set_data[nxp+p3]))
			{
				if(!strlen(set_data[nxp+p4]))
				{
					sprintf(s, "%d", p_seqno);
					status = MEMwrite_data(set_bufr, s, p+1, p4+1);
					if(status != MEM_S_SUCCESS)
					{
						return(PDM_E_WRITE_COLUMN);
					}
				}
				else
				{
					break;
				}
			}
		}
		for(k=0;k<cat_attr->columns;k++)
		{
			if(!strcmp(cat_columns[k], "p_history"))
			{
				strcat(val_str, "'");
				strcat(val_str, join_data[nxi+a4]);
				strcat(val_str, "'");
			}
            else if(!strcmp(cat_columns[k], "p_orient"))
			{
				strcat(val_str, "'");
				strcat(val_str, join_data[nxi+a5]);
				strcat(val_str, "'");
			}
            else if(!strcmp(cat_columns[k], "p_quantity"))
			{
				strcat(val_str, join_data[nxi+a6]);
			}
            else if(!strcmp(cat_columns[k], "p_childno"))
			{
				strcat(val_str, "'");
				strcat(val_str, join_data[nxi+a10]);
				strcat(val_str, "'");
			}
            else if(!strcmp(cat_columns[k], "p_usageid"))
			{
				strcat(val_str, "'");
				strcat(val_str, join_data[nxi+a7]);
				strcat(val_str, "'");
			}
            else if(!strcmp(cat_columns[k], "p_viewid"))
			{
				strcat(val_str, "'");
				strcat(val_str, join_data[nxi+a8]);
				strcat(val_str, "'");
			}
            else if(!strcmp(cat_columns[k], "p_tagno"))
			{
				strcat(val_str, "'");
				strcat(val_str, join_data[nxi+a10]);
				strcat(val_str, "'");
			}
            else if(!strcmp(cat_columns[k], "p_alttagno"))
			{
				strcat(val_str, "'");
				strcat(val_str, join_data[nxi+a11]);
				strcat(val_str, "'");
			}
            else if(!strcmp(cat_columns[k], "p_incbom"))
			{
				strcat(val_str, "'");
				strcat(val_str, join_data[nxi+a12]);
				strcat(val_str, "'");
			}
            else if(!strcmp(cat_columns[k], "p_explode"))
			{
				strcat(val_str, "'");
				strcat(val_str, join_data[nxi+a13]);
				strcat(val_str, "'");
			}
			else if(!strcmp(cat_columns[k], "p_parentno"))
			{
				strcat(val_str, join_data[nxi+a9]);
			}
            else if(!strcmp(cat_columns[k], "p_attached"))
			{
				strcat(val_str, "'N'");
			}
			else if(!strcmp(cat_columns[k], "n_level"))
			{
				sprintf(s, "%d", n_level);
				strcat(val_str, s);
			}
			else if(!strcmp(cat_columns[k], "p_seqno"))
			{
				sprintf(s, "%d", p_seqno);
				strcat(val_str, s);
			}			
			else 
			{
				if(!strncmp(cat_format[k], "char", 4))
				{
					strcat(val_str, "''");					
				}
				else
				{
					strcat(val_str, "null");
				}	
			}
		    if(k != cat_attr->columns-1)
					strcat(val_str, ", ");		
		}
		if(usr_attr != NULL)
		{
			strcat(val_str, ", ");
			for(k=0;k<usr_attr->columns-1;k++)
			{
				if(!strncmp(usr_format[k], "char", 4))
				{
					strcat(val_str, "''");					
				}
				else
				{
					strcat(val_str, "null");
				}
			}
			if(k != usr_attr->columns-1)
			strcat(val_str, ", ");
		}			
		strcat(val_str, ")");
		sprintf(ins_str, "%s %s", attr_str, val_str);
		status = SQLstmt(ins_str);
		if(status != SQL_S_SUCCESS)
		{
			free(ins_str);
			free(attr_str);
			free(val_str);
			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
			PDMdebug("sql string: ");
			PDMdebug(ins_str);			
			PDMdebug("\n");
			return(PDM_E_SQL_STMT);
		}

		/* store the p_seqno in join_data[nxi+a9] */

		s[0] = '\0';
		sprintf(s, "%d", p_seqno);
		status = MEMwrite_data(join_bufr, s, i+1, a9+1);
		if(status != MEM_S_SUCCESS)
		{
			free(ins_str);
			free(attr_str);
			free(val_str);
			PDMdebug("PDMload_bom_table\n");
			sprintf(s, "%s %d\n", 
			"MEMwrite_data failed status ", status);
			PDMdebug(s);
			return(PDM_E_WRITE_COLUMN);
		}	
	}
	free(attr_str);
	free(val_str);
	free(ins_str);
	PDMdebug("EXIT:PDMload_bom_table\n");
	return(PDM_S_SUCCESS);
}

/* 
	Updates BOM that is partially constructed with pdmcit 
	attributes and n_catalogname, n_itemname, n_itemrev 
*/

int	PDMupdate_bom_attributes(user_id, bom_table, 
		cat_attr, cat_str, usr_attr, usr_str)
long	user_id;
char	*bom_table;
MEMptr	cat_attr;
MEMptr	usr_attr;
char	*usr_str;
char	*cat_str;
{
	char	sql_str1[1024];
	char	**bom_data = NULL;
	char	*upd_str = NULL;
	char	**cat_format = NULL;
	char	**usr_format = NULL;
	char	**cat_columns = NULL;
	char	**usr_columns = NULL;
	char	**temp_data = NULL;
	char	*sql_str = NULL;
	MEMptr	bom_bufr = NULL;
	MEMptr	temp_bufr = NULL;
	MEMptr	usr_bufr = NULL;
	int		size = 0, size1 =0;
	int		map_row_size = 0;
	int		k, nx1, j, l;
        static char  *fname = "PDMupdate_bom_attributes";

	PDMdebug("ENTER:PDMupdate_bom_attributes\n");

/* ANSI */
	usr_str = NULL;
	cat_str = NULL;

	sprintf(sql_str1, "%s FROM %s", 
	"SELECT DISTINCT n_catalogname, n_itemname, n_itemrev ", 
	bom_table);
	status = SQLquery(sql_str1, &bom_bufr, 2048);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(bom_bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bom_bufr);
		sprintf(s, "%s %d\n", 
		"MEMbuild_array failed status ", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	cat_columns = (char **) cat_attr->column_ptr;
	cat_format = (char **) cat_attr->format_ptr;
	size = 0;
	for(k=0;k<cat_attr->columns;k++)
	{
		size = size + strlen(cat_columns[k]);		
	}

        _PDMdebug(fname, "cat_attr size %d\n", size);
	if(usr_attr != NULL)
	{
		status = MEMbuild_array(usr_attr);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&bom_bufr);
			sprintf(s, "%s %d\n", 
			"MEMbuild_array failed status ", status);
			PDMdebug(s);
			return(PDM_E_BUILD_ARRAY);
		}
    }

	size = size + cat_attr->row_size;

        _PDMdebug(fname, "cat_attr+row size %d\n", size);
	bom_data = (char **) bom_bufr->data_ptr;
	for(k=0;k<bom_bufr->rows;k++)
	{
		map_row_size = 0;
		nx1 = k * bom_bufr->columns;

		/* if successfull sql_str is a SELECT string.
		   it may or may not conatin user defined attributes
		   depending on whether the catalog has mapping defined
		   or not. "usr_bufr" contains user attributes in
		   pdmbomcontent which have a mapping attribute */

	    status = PDMbuild_select_string(user_id, cat_attr, 
				 usr_attr, bom_data[nx1+0], bom_data[nx1+1], 
				 bom_data[nx1+2], &map_row_size, &sql_str, &usr_bufr);
		if(status != PDM_S_SUCCESS)
		{
			MEMclose(&bom_bufr);
			sprintf(s, "%s %d\n", 
			"PDMbuild_select_string failed status ", status);
			PDMdebug(s);
			return(status);
		}
		if(map_row_size) 
		{
			size1 = 0;
			status = MEMbuild_array(usr_bufr);
			if(status != MEM_S_SUCCESS)
			{
				MEMclose(&temp_bufr);MEMclose(&bom_bufr);
				MEMclose(&usr_bufr); 
				sprintf(s, "%s %d\n", 
				"MEMbuild_array failed status ", status);
				PDMdebug(s);
				return(PDM_E_BUILD_ARRAY);
			}
			usr_columns = (char **) usr_bufr->column_ptr;
			usr_format = (char **) usr_bufr->format_ptr;
			for(j=0;j<usr_bufr->columns;j++)
			{
				size1 = size1 + strlen(usr_columns[j]);
			}
        }
		status = SQLquery(sql_str, &temp_bufr, 1024);
		free(sql_str);
	    if(status != SQL_S_SUCCESS)
	    {
			MEMclose(&bom_bufr); MEMclose(&usr_bufr);
	 	    switch(status)
		    {
			  case SQL_I_NO_ROWS_FOUND :
				 sprintf(s, "%s:%s Part is not found \n", 
				 bom_data[nx1+1], bom_data[nx1+2]);
				 PDMdebug(s);
				 return(PDM_E_PART_NOT_FOUND);
			  case PDMS_NO_SUCH_TABLE:
				 sprintf(s, "%s Catalog is not found \n", 
				 bom_data[nx1+0]);
				 PDMdebug(s);				 
				return(PDM_E_CATALOG_NOT_FOUND);
  			  case PDMS_NO_SUCH_ATTRIBUTE:
				sprintf(s, "A req Col is not found in %s\n", 
				bom_data[nx1]);
				PDMdebug(s);
				return(PDM_E_REQ_COLUMN_NOT_FOUND);
  			  default :  
					return(PDM_E_SQL_QUERY);
		    }
	    }
		status = MEMbuild_array(temp_bufr);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&bom_bufr);	MEMclose(&usr_bufr);
			sprintf(s, "%s %d\n", 
			"MEMbuild_array failed status ", status);
			PDMdebug(s);
			return(PDM_E_BUILD_ARRAY);
		}
	status = MEMbuild_array(cat_attr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bom_bufr);
		sprintf(s, "%s %d\n", 
		"MEMbuild_array failed status ", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	cat_columns = (char **) cat_attr->column_ptr;
	cat_format = (char **) cat_attr->format_ptr;
		temp_data = (char **) temp_bufr->data_ptr;
        _PDMdebug(fname, "cat_attr size %d\n", size);
        _PDMdebug(fname, "usr_attr size1 %d\n", size);
        _PDMdebug(fname, "temp_bufr size1 %d\n", temp_bufr->row_size);
               size = (size+size1+100+ (temp_bufr->row_size));
        _PDMdebug(fname, "upd_str size %d\n", size);
 	 	upd_str = (char *) malloc(size);
		if(upd_str == NULL)
		{
			MEMclose(&temp_bufr);MEMclose(&bom_bufr);
			MEMclose(&usr_bufr);
			MEMclose(&cat_attr);
			PDMdebug("Failed to malloc\n");
			return(PDM_E_COULD_NOT_MALLOC);
		}
		sprintf(upd_str, "UPDATE %s SET ", bom_table);

		for(j=0;j<cat_attr->columns;j++)
		{
			strcat(upd_str, cat_columns[j]);
			strcat(upd_str, "=");
			if(!strncmp(cat_format[j], "char", 4))
			{
				strcat(upd_str, "'");
				strcat(upd_str, temp_data[j]);
				strcat(upd_str, "'");
			}
			else
			{
				if(strlen(temp_data[j]))
					strcat(upd_str, temp_data[j]);
				else
					strcat(upd_str, "null");
			}
			if(j != cat_attr->columns-1)
				strcat(upd_str, ", ");
		}

		/* check if mapping exists */

		l = -1;
		if(map_row_size) 
		{
			strcat(upd_str, ", ");
			for(j=cat_attr->columns;j<temp_bufr->columns;j++)
			{
				l = l +1;
				strcat(upd_str, usr_columns[l]);
				strcat(upd_str, "=");
				if(!strncmp(usr_format[l], "char", 4))
				{
					strcat(upd_str, "'");
					strcat(upd_str, temp_data[j]);
					strcat(upd_str, "'");
				}
				else
				{
					if(strlen(temp_data[j]))
						strcat(upd_str, temp_data[j]);
					else
						strcat(upd_str, "null");
				}
				if(j != temp_bufr->columns-1)
					strcat(upd_str, ", ");
			}
	    }
		MEMclose(&temp_bufr); temp_bufr = NULL;
		MEMclose(&usr_bufr); usr_bufr = NULL;
		sprintf(s, " %s '%s' %s '%s'", 
		"WHERE n_itemname = ", bom_data[nx1+1], 
		"AND n_itemrev = " , bom_data[nx1+2]);
		strcat(upd_str, s);
                PDMdebug(upd_str);
		status = SQLstmt(upd_str);
		free(upd_str);
		if(status != SQL_S_SUCCESS)
		{
			MEMclose(&bom_bufr);
			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
			return(PDM_E_SQL_STMT);
		}
    }
	PDMdebug("EXIT:PDMupdate_bom_attributes\n");
	return(PDM_S_SUCCESS);
}

/*
	returns the attributes in the template "pdmbomcontent"

	OUTPUT:
			usr_attr contains
	attributes that donot start with "p_" are returned 

	attrbs that start with "p_" and not in (n_catalogname, 
	n_itemname, n_itemrev) are returned in the MEMbufr "cat_attr"
*/

int	PDMget_bom_attrbs(user_id, cat_attr, cit_attr, usr_attr)
long		user_id;
MEMptr		*cat_attr;
MEMptr		*cit_attr;
MEMptr		*usr_attr;
{
	MEMptr		attr_bufr = NULL;
	int			i;
	int			nx1;
	int			n;
	int			a1 = -1;
	int			a2 = -1;
	char		attr_name[40];
	char		attr_type[20];
	char		**column_ptr;
	char		**data;

	*cat_attr = NULL;
	*usr_attr = NULL;

/* ANSI */
	user_id = 0;
	
	/* query the "bomcontent" template */
	
	PDMdebug("ENTER PDMget_bom_attrbs \n");
    /*
	status = NFMquery_template_definition
				(user_id, "pdmbomcontent", "pdmbomcontent", &attr_bufr);
      */
	status = NFMquery_template_definition ("t_appltable", "bom_template", "BOM", &attr_bufr);
	if(status != NFM_S_SUCCESS)
	{
		MEMclose(&attr_bufr);
		sprintf(s, "%s %s %d %s", 
		" NFMquery_modify_template_attributes ", 
		"failed status ", status, "\n");
		PDMdebug(s);
		return(PDM_E_QUERY_TEMPLATE_DEF);
	}	
	status = MEMbuild_array(attr_bufr);
    if(status != MEM_S_SUCCESS)
    {
		MEMclose(&attr_bufr);
		sprintf(s, "%s %s %d \n", 
		"MEMbuild_array ", 
		" failed - status ", status);
	    PDMdebug(s);
   		return(PDM_E_BUILD_ARRAY);
   	}

/*	if(PDMdebug_on)
	MEMprint_array("bomcontent", attr_bufr, PDM_DEBUG_FILE);
*/

	column_ptr = (char **) attr_bufr->column_ptr;
	data = (char **) attr_bufr->data_ptr;
	for(i=0;i<attr_bufr->columns;i++)
	{
		if(!strcmp(column_ptr[i], "n_name"))		a1 = i;
		if(!strcmp(column_ptr[i], "n_datatype"))	a2 = i;
	}
	if(a1 == -1 || a2 == -1)
	{
		MEMclose(&attr_bufr);
		sprintf(s, "%s %s", 
		"Failed to set ", 
		"offsets in attribute buffer \n");
	    PDMdebug(s);
		return(PDM_E_BUFFER_FORMAT);
	}
	status = MEMopen(usr_attr, 1024);
    if(status != MEM_S_SUCCESS)
    {
		MEMclose(&attr_bufr);
		sprintf(s, "%s %d %s", 
		"MEMopen failed - status ", status, "\n");
	    PDMdebug(s);
   		return(PDM_E_OPEN_BUFFER);
   	}
	status = MEMopen(cat_attr, 1024);
    if(status != MEM_S_SUCCESS)
    {
		MEMclose(&attr_bufr);
		MEMclose(usr_attr);
		*usr_attr = NULL;
		sprintf(s, "%s %d %s", 
		"MEMopen failed - status ", status, "\n");
	    PDMdebug(s);
   		return(PDM_E_OPEN_BUFFER);
   	}
	status = MEMopen(cit_attr, 1024);
    if(status != MEM_S_SUCCESS)
    {
		MEMclose(&attr_bufr);
		MEMclose(usr_attr);
		MEMclose(cat_attr);
		*usr_attr = NULL;
		sprintf(s, "%s %d %s", 
		"MEMopen failed - status ", status, "\n");
	    PDMdebug(s);
   		return(PDM_E_OPEN_BUFFER);
   	}

	n = 0;
	for(i=0;i<attr_bufr->rows;i++)
	{
		nx1 = i * (attr_bufr->columns);
		attr_name[0] = '\0';attr_type[0] = '\0';
		sprintf(attr_name, "%s", data[nx1+a1]);
		sprintf(attr_type, "%s", data[nx1+a2]);
		if(strncmp(data[nx1+a1], "p_", 2)) /* user catalog attribute */
		{
			status = MEMwrite_format(*usr_attr, attr_name, attr_type);
			if(status != MEM_S_SUCCESS)
			{
				MEMclose(usr_attr);
				*usr_attr = NULL;
				MEMclose(cat_attr);
				*cat_attr = NULL;
				MEMclose(cit_attr);
				*cit_attr = NULL;
				sprintf(s, "%s %s %d \n", 
				"MEMwrite_format", 
				"failed status ", status);
				PDMdebug(s);
				return(PDM_E_WRITE_FORMAT);
			}
			n = n +1;
		}
	    else	/* req. catalog attribute */
		{
		}
	}
	if(!n)  		/* there are no user defined attributes */
	{
		MEMclose(usr_attr);
		*usr_attr = NULL;
	}

	status = MEMwrite_format(*cat_attr, "p_parentno", "integer");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_seqno", "integer");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "n_level", "integer");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_tagno", "integer");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_attached", "char(1)");
	if(status == MEM_S_SUCCESS)
/*	status = MEMwrite_format(*cat_attr, "n_catalogname", "char(20)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "n_itemname", "char(30)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "n_itemrev", "char(30)"); 
	if(status == MEM_S_SUCCESS) 
	status = MEMwrite_format(*cat_attr, "n_itemdesc", "char(45)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_creationdate", "char(10)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_creationtime", "char(8)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_updatedate", "char(10)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_updatetime", "char(8)");
	if(status == MEM_S_SUCCESS) */
	status = MEMwrite_format(*cat_attr, "p_incpartrpt", "char(1)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_mrpbomuom", "char(10)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_mrpeffectdate", "char(8)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_mrpinvuom", "char(10)");
    if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cit_attr, "p_history", "char(10)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cit_attr, "p_orient", "char(240)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cit_attr, "p_quantity", "double");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cit_attr, "p_childno", "char(20)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cit_attr, "p_usageid", "char(25)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cit_attr, "p_viewid", "char(25)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cit_attr, "p_alttagno", "char(25)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cit_attr, "p_incbom", "char(1)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cit_attr, "p_explode", "char(1)");
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(usr_attr);
    	*usr_attr = NULL;
		MEMclose(cat_attr);
		*cat_attr = NULL;
		MEMclose(cit_attr);
		*cit_attr = NULL;
		sprintf(s, "MEMwrite_format failed status %d\n", 
		status);
	}
	
	if(PDMdebug_on)
	{
/*		MEMprint_buffer("req. bomcontent", *cat_attr, PDM_DEBUG_FILE);
		if(n)
		MEMprint_buffer("user bomcontent", *usr_attr, PDM_DEBUG_FILE);
*/
	}
	PDMdebug("EXIT:PDMget_bom_attrbs \n");	
	return(PDM_S_SUCCESS);
}

/* 
	Called after inserting into bom_temp

   Queries for next level members of all entries between
   no1 to no2 in bom_temp table and loads into temp_table 
*/

PDMquery_load_members(user_id, bom_temp, temp_table, 
					  no1, no2, a1, a2, a3, a4, members)
long		user_id;
char		*bom_temp;
char		*temp_table;
long		no1;
long		no2;
int			a1;
int			a2;
int			a3;
int			a4;
int			*members;
{
	char		sql_str[1024];
	char		sql_str1[512];
	char		val_str[1024];
	char		p_incbom1[2];
	char		**data;
	char		**data1;
	int			i, nx1;
	int			query;
	int			j, nx2;
	MEMptr		bufr = NULL;
	MEMptr		data_bufr = NULL;
	MEMptr		attr_bufr = NULL;

    PDMdebug("ENTER PDMquery_load_members \n");

	*members = 0;

	/* delete previous entries in temp_table */

	sprintf(s, "DELETE FROM %s", temp_table);
	status = SQLstmt(s);
	if(status != SQL_S_SUCCESS )
	{
	}

	sprintf(sql_str, "%s %s %s %d %s %d", 
	"SELECT n_catalogname, n_itemname, n_itemrev, p_seqno, p_incbom, p_explode FROM ", 
	bom_temp, "WHERE p_seqno >= ", no1, 
	"AND p_seqno <= ", no2);
	status = SQLquery(sql_str, &bufr, 1024);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&bufr);
		if(status == SQL_I_NO_ROWS_FOUND)
		{
		}
		else
		{
			sprintf(s, "SQLquery failed status %d\n", status);
			PDMdebug(s);
		}
		return(PDM_E_SQL_QUERY);
	}
	else
	{
		status = MEMbuild_array(bufr);
		if(status != MEM_S_SUCCESS)
		{
			sprintf(s, "MEMbuild_array failed status %d\n", status);
			PDMdebug(s);
			return(PDM_E_BUILD_ARRAY);
		}
		data = (char **) bufr->data_ptr;
	}

	query = 1;
  for(i=0;i<bufr->rows;i++)
   {
		nx1 = i * bufr->columns;
             /*
		p_explode[0] = '\0';
		status = PDMfind_citp_explode(data[nx1], data[nx1+1], 
					data[nx1+2], p_explode, p_incbom);
		if(status != PDM_S_SUCCESS)
		{
			sprintf(s, "%s %s %d %s", "PDMfind_citp_explode ", 
			"failed - status ", status, "\n"); PDMdebug(s);
		}
              */

/*		if(i == 0)
		{
			query = 1;
		}
        else if (i > 1)
		{
			nx3 = (i-2) * bufr->columns;
			if(!strcmp(data[nx1], data[nx3])     &&
			   !strcmp(data[nx1+1], data[nx3+1]) &&
			   !strcmp(data[nx1+2], data[nx3+2]))
			{
				query = 0;
			}
			else
				query = 1;
		}
*/

       sprintf(s, "%s %d \n", "query value is -> ", query);PDMdebug(s);
       sprintf(s, "%s %s \n", "Explode indicator is -> ", data[nx1+5]);PDMdebug(s);
      if(query && (strncmp(data[nx1+5], "N", 1) && strncmp(data[nx1+5], "n", 1)))
             {
		MEMclose(&data_bufr); data_bufr = NULL;
	        status = PDMquery_cit_members(user_id, 
		data[nx1], data[nx1+1], data[nx1+2], 1, &attr_bufr, &data_bufr);
	        if(status != PDM_S_SUCCESS)
	        {
		sprintf(s, "%s %s %d %s", 
		"NFMquery_set_members", " failed - status ", status, "\n");
		PDMdebug(s);
		return(PDM_E_QUERY_SET_MEMBERS);
	        }   
	        MEMclose(&attr_bufr); attr_bufr = NULL;
	        status = MEMbuild_array(data_bufr);
	        if(status != MEM_S_SUCCESS)
		  {
		  sprintf(s, "MEMbuild_array failed status %d\n", status);
                  PDMdebug(s);
	          MEMclose(&data_bufr);MEMclose(&bufr);
	          return(PDM_E_BUILD_ARRAY);
		  }
	        data1 = (char **) data_bufr->data_ptr;
		*members = *members + data_bufr->rows;
		sprintf(sql_str1, "%s %s %s %s ", "INSERT INTO ", temp_table, 
		"(n_catalogname, n_itemname, n_itemrev, ", "p_citno, p_parentno)");
             for(j=0;j<data_bufr->rows;j++)
	     {
		nx2 = j * data_bufr->columns;
/* changed to only pass citno 11/4/91 beth */
		status = PDMfind_citc_explode(data1[nx2+a1], data1[nx2+a2], data1[nx2+a3], p_incbom1);
		if(status != PDM_S_SUCCESS)
	        	 {
		         sprintf(s, "%s %s %d %s", "PDMfind_p_explode ", 
                         "failed - status ", status, "\n"); PDMdebug(s);
		         }
                 if ((!strncmp(p_incbom1, "Y", 1)) || (!strncmp(p_incbom1, "y", 1)))
               {
		sprintf(val_str, "VALUES('%s', '%s', '%s', %s, %s)", 
		data1[nx2+a1], data1[nx2+a2], data1[nx2+a3], 
		data1[nx2+a4], data[nx1+3]);
		sprintf(sql_str, "%s %s", sql_str1, val_str);
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		   {
		MEMclose(&bufr); MEMclose(&data_bufr);
		sprintf(s, "SQLstmt failed status %d\n", status); PDMdebug(s);
		return(PDM_E_SQL_STMT);
		   }

               }/*if p_incbom is set to yes */
            }/*for the members of sub - assembly */
         }/* for the part to be exploded */

     }  /* finished with querying for all the parts */

	 MEMclose(&bufr); MEMclose(&data_bufr);
	 PDMdebug("EXIT PDMquery_load_members \n");
	 return(PDM_S_SUCCESS);
}

/* 
   Builds a select string to select the bomcontent 
   from a catalog for a part.
   cat_str is c1, c2, ...., cn where ci is REQ. bom attrb

   sql_str is "SELECT c1, ..cn, m1, ..mn FROM catalog 
               WHERE n_itemname = part_num 
			   AND   n_itemrev = part_rev"

   m1..mn are mapped attributes
*/

PDMbuild_select_string(user_id, cat_attr, usr_attr, 
					   catalog, part_num, part_rev, 
					   map_row_size, sql_str, usr_bufr)
long		user_id;
MEMptr		cat_attr;
MEMptr		usr_attr;
char		*catalog;
char		*part_num;
char		*part_rev;
int			*map_row_size;
char		**sql_str;
MEMptr		*usr_bufr;
{
	  MEMptr		map_attr = NULL;
	  int			size;
	  int			size2;
	  char			*map_str;
	  char			*cat_str;
          static char *fname = "PDMbuild_select_string";
	
	  PDMdebug("ENTER: PDMbuild_select_string \n");
	  size = 0;
      status = PDMbuild_attribute_string(cat_attr, 
				 &cat_str, &size);
 	  if(status != PDM_S_SUCCESS)
	  {
 		 sprintf(s, "%s %s %d \n", 
		 "PDMbuild_attribute_string ", 
		 "failed status ", status);
		 PDMdebug(s);
		 return(status);
	  }
	  *map_row_size = 0;
          _PDMdebug(fname, "cat_str size %d\n", size);
	  if(usr_attr != NULL)
	  {
			status = PDMmap_user_attributes(user_id, catalog, 
					 &map_attr, usr_bufr);
		    if(status != PDM_S_SUCCESS)
			{
				free(cat_str);
				sprintf(s, "%s %s %d \n", 
				"PDMmap_user_attributes ", 
				"failed status ", status);
				PDMdebug(s);
				return(status);
			}

			/* if there is a mapping */

			size2 = 0;
			if(map_attr != NULL)
			{
				status = MEMbuild_array(map_attr);
				if(status != MEM_S_SUCCESS)
				{
					MEMclose(&map_attr);free(cat_str);
					sprintf(s, "%s %s %d \n", 
					"MEMbuild_array ", 
					"failed status ", status);
					PDMdebug(s);
					return(PDM_E_BUILD_ARRAY);
				}

				status = PDMbuild_attribute_string(map_attr, 
							 &map_str, &size2);
				if(status != PDM_S_SUCCESS)
				{
					MEMclose(&map_attr);free(cat_str);
					sprintf(s, "%s %s %d \n", 
					"PDMbuild_attribute_string ", 
					"failed status ", status);
					PDMdebug(s);
					return(status);
			    }
				size = size + strlen(map_str);
          _PDMdebug(fname, "cat_str+map_str size %d\n", size);
   			    *map_row_size = map_attr->row_size;	
/* BETH the buffers had a * in front of the variable this is incorrect 11/18/91
*/
			if (PDMdebug_on)
			  {
				MEMprint_buffer("usr_bufr", usr_bufr, PDM_DEBUG_FILE);
				MEMprint_buffer("map_attr", map_attr, PDM_DEBUG_FILE);
			  }
			}
		    else
			{
/* BETH pointers to MEMptr usr_bufr were incorrect 11/18/91 */
	/*			MEMclose(usr_bufr); *usr_bufr = NULL; */
			}
	  	    *sql_str = (char *) malloc(size + 200);
          _PDMdebug(fname, "sql_str size %d\n", size+200);
	   		if(*sql_str == NULL)
	   		{
			  if(size2)
			  {
				MEMclose(&map_attr);free(map_str);
/* BETH pointers to MEMptr usr_bufr are incorrect 11/18/91 */
				MEMclose(&usr_bufr);
			  }
			  free(cat_str);
			  PDMdebug(" Failed to malloc \n");
			  return(PDM_E_COULD_NOT_MALLOC);
	   		}
			if(size2)
			{
				strcpy(*sql_str, "");
				sprintf(*sql_str, 
				"SELECT %s, %s FROM %s %s '%s' %s '%s'", 
				 cat_str, map_str, catalog, 
				"WHERE n_itemname = ", part_num, 
				"AND n_itemrev = ", part_rev);
				free(map_str);
				free(cat_str);
				MEMclose(&map_attr);
			}
			else
			{
				strcpy(*sql_str, "");
				sprintf(*sql_str, 
				"SELECT %s FROM %s %s '%s' %s '%s'", 
				 cat_str, catalog, 
				"WHERE n_itemname = ", part_num, 
				"AND n_itemrev = ", part_rev);
				free(cat_str);
				MEMclose(&map_attr);
			}
      }
	  else    /* no user defined */
	  {
				PDMdebug("No user defined \n");
			*sql_str = (char *) malloc(size + 200);
			if(*sql_str == NULL)
	  	    {
				PDMdebug("Failed to malloc \n");
				return(PDM_E_COULD_NOT_MALLOC);
			}
			strcpy(*sql_str, "");
			sprintf(*sql_str, "SELECT %s FROM %s %s '%s' %s '%s'", 
			cat_str, catalog, 
			"WHERE n_itemname = ", part_num, 
			"AND n_itemrev = ", part_rev);
	  }
          sprintf(s, "PDMbuild_select_string %s \n", *sql_str);
          PDMdebug(s);

	  PDMdebug("EXIT: PDMbuild_select_string\n");
	  return(PDM_S_SUCCESS);
}

/* From the column format in cat_attr buffer
   A string is constructed with all the columns and 
   commas in between
   Example:	name1, name2, name3
*/

PDMbuild_attribute_string(cat_attr, cat_str, size)
MEMptr		cat_attr;
char		**cat_str;
int			*size;
{
	int			i;
	char		**column_ptr;

	PDMdebug("ENTER:PDMbuild_attribute_string \n");
	if(cat_attr == NULL)
	{
		*size = 0;
		return(PDM_S_SUCCESS);
	}
	status = MEMbuild_array(cat_attr);
    if(status != MEM_S_SUCCESS)
    {
		sprintf(s, "%s %s %d %s", 
		"PDMbuild_attribute_string : ", 
		"MEMbuild_array failed - status ", status, "\n");
        PDMdebug(s);
   		return(PDM_E_BUILD_ARRAY);
    }

	/* build a string of attributes interspersed by commas */

	column_ptr = (char **) cat_attr->column_ptr;
	*size = 0;
	for(i=0;i<cat_attr->columns;i++)
		*size = *size + strlen(column_ptr[i]) + 5;
	*size = *size + 100;
	*cat_str = (char *) malloc((*size));
	if(*cat_str == NULL)
	{
		PDMdebug("PDMbuild_attribute_string : Failed to malloc \n");
		return(PDM_E_COULD_NOT_MALLOC);
	}
	strcpy(*cat_str, "");
	strcpy(*cat_str, column_ptr[0]);
	for(i=1;i<cat_attr->columns;i++)
	{
		strcat(*cat_str, ", ");
		strcat(*cat_str, column_ptr[i]);
	}
	PDMdebug("Attribute_string\n");
	PDMdebug(*cat_str);
	PDMdebug("\n");
	PDMdebug("EXIT:PDMbuild_attribute_string \n");
	return(PDM_S_SUCCESS);
}

/* 
	Queries for mapped attributes from the pdmbommap
	and loads them into map_attr bufr
	Since it is okay to have catalogs without mapping
	defined, map_attr in such cases will be a dummy buffer
*/

int PDMmap_user_attributes(user_id, catalog, map_attr, usr_bufr)
long	user_id;
char	*catalog;
MEMptr	*map_attr;
MEMptr	*usr_bufr;
{
	MEMptr		bufr = NULL;
	char		n_name[30];
	char		sql_str[1024];
	char		**data;
	int			i, nxi;
	int			p_catalogno;
	int			n_tmpltno;

	PDMdebug("ENTER : PDMmap_user_attributes \n");

/* ANSI */
	user_id = 0;
	
	status = PDMget_table_no(catalog, "catalog", &p_catalogno);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s, "PDMget_table_no failed status %d\n", 
		status);PDMdebug(s);
		return(status);
	}
	status = PDMget_table_no("bom_template", 
					"t_appltable", &n_tmpltno);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s, "PDMget_table_no failed status %d\n", 
		status);PDMdebug(s);
		return(status);
	}
	sprintf(sql_str, "%s %s %s %d %s %d %s", 
	"SELECT n_name, p_bomattrno, p_mapattrno, n_name, n_datatype FROM ", 
	" pdmbommap, nfmattributes ", 
	"WHERE nfmattributes.n_tableno = ", 	n_tmpltno, 
	"AND pdmbommap.n_catalogno = ", p_catalogno, 
	"AND pdmbommap.p_bomattrno=nfmattributes.n_attrno");
	status = SQLquery(sql_str, &bufr, 1024);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&bufr);
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			PDMdebug("There is no mapping for \n");
			PDMdebug("user defined attributes \n");
			sprintf(s, "catalog <%s>\n", catalog);
			PDMdebug(s);
			return(PDM_S_SUCCESS);
		}
		else
		{
			return(PDM_E_SQL_QUERY);
		}
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", 
		status); PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	for(i=0;i<bufr->rows;i++)
	{
		nxi = i * bufr->columns;
		strcpy(n_name, "");
		status = PDMget_attribute_name(p_catalogno, 
					atoi(data[nxi+2]), n_name);
		if(status != PDM_S_SUCCESS )
		{
			sprintf(s, "PDMget_attribute_name failed status %d\n", 
			status); PDMdebug(s);
			return(status);
		}
		if(strlen(n_name)) /* mapping available */
		{
			status = MEMwrite_data(bufr, n_name, i+1, 4);
			if(status != MEM_S_SUCCESS)
			{
				MEMclose(&bufr);
				sprintf(s, "MEMwrite_data failed status %d\n", 
				status); PDMdebug(s);
				return(PDM_E_WRITE_COLUMN);
			}
		}
		else 	/* mapping not available */
		{
			status = MEMwrite_data(bufr, n_name, i+1, 4);
			if(status != MEM_S_SUCCESS)
			{
				MEMclose(&bufr);
				sprintf(s, "MEMwrite_data failed status %d\n", 
				status); PDMdebug(s);
				return(PDM_E_WRITE_COLUMN);
			}
			sprintf(s, "No mapping for <%s> in catalog <%s>\n", 
			data[nxi], catalog);	PDMdebug(s);
		}
	}

	status = MEMopen(map_attr, 1024);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
	}
	status = MEMopen(usr_bufr, 1024);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr); MEMclose(map_attr); *map_attr=NULL;
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
	}
	for(i=0;i<bufr->rows;i++)
	{
		nxi = i * bufr->columns;
		if(strlen(data[nxi+3]))
		{		
			status = MEMwrite_format(*map_attr, data[nxi+3], data[nxi+4]);
			if(status != MEM_S_SUCCESS)
			{
				MEMclose(map_attr); *map_attr = NULL;
				MEMclose(&bufr);MEMclose(usr_bufr);
				sprintf(s, "MEMwrite_foramt failed status %d\n", 
				status);
				PDMdebug(s);
				return(PDM_E_WRITE_FORMAT);
			}
			status = MEMwrite_format(*usr_bufr, data[nxi+0], data[nxi+4]);
			if(status != MEM_S_SUCCESS)
			{
				MEMclose(map_attr); *map_attr = NULL;
				MEMclose(&bufr);MEMclose(usr_bufr);
				sprintf(s, "MEMwrite_foramt failed status %d\n", 
				status);
				PDMdebug(s);
				return(PDM_E_WRITE_FORMAT);
			}
		}
	}
	MEMclose(&bufr);
	PDMdebug("EXIT : PDMmap_user_attributes \n");
	return(PDM_S_SUCCESS);
}
/* Copies old tag nos from old_bom to bom
   If necessary generates new ones 
*/

int	 PDMupdatebom_tagnos(bom, old_bom)
char	*bom;
char	*old_bom;
{
	char	sql_str[1024];
	char 	**bom_data;
	char	**tag_data;
	MEMptr  bom_bufr = NULL;
	MEMptr	tag_bufr = NULL;
	int		i, j, nxi, nxj;

 PDMdebug("ENTER:PDMgenerate_tagnos\n");

   {
	/* select all unique parts in new bom */

	sprintf(sql_str, "%s %s %s", 
	"SELECT DISTINCT n_catalogname, n_itemname, n_itemrev, p_tagno ", 
	"FROM", bom);	
	status = SQLquery(sql_str, &bom_bufr, 4096);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(bom_bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bom_bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	bom_data = (char **) bom_bufr->data_ptr;

	/* find unique parts and tagnos in old bom */

	sprintf(sql_str, "%s %s %s", 
	"SELECT DISTINCT n_catalogname, n_itemname, n_itemrev, p_tagno ", 
	"FROM", old_bom);	
	status = SQLquery(sql_str, &tag_bufr, 4096);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(tag_bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bom_bufr);	MEMclose(&tag_bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	tag_data = (char **) tag_bufr->data_ptr;

        if (PDMdebug_on)
          {
	    MEMprint_buffer("new bom", bom_bufr, PDM_DEBUG_FILE);

	    MEMprint_buffer("old bom", tag_bufr, PDM_DEBUG_FILE);
          }	

	/* carry old tagnos */

	for(i=0;i<bom_bufr->rows;i++)
	{
		nxi = i * bom_bufr->columns;
		for(j=0;j<tag_bufr->rows;j++)
		{
			nxj = j * tag_bufr->columns;
			if(!strcmp(tag_data[nxj+0], bom_data[nxi+0]) && 
			   !strcmp(tag_data[nxj+1], bom_data[nxi+1]) && 
			   !strcmp(tag_data[nxj+2], bom_data[nxi+2]))
			{
				status = MEMwrite_data
						(bom_bufr, tag_data[nxj+3], i+1, 4);
				if(status != 0)
				{
					sprintf(s, "MEMwrite_data failed status %d\n", 
					status); PDMdebug(s);
					MEMclose(&bom_bufr);MEMclose(&tag_bufr);
					return(PDM_E_WRITE_COLUMN);
				}
				break;
			}
		}
	}
	MEMclose(&tag_bufr);
	
	/* set tagnos in new bom */

	for(i=0;i<bom_bufr->rows;i++)
	{
		nxi = i * bom_bufr->columns;
		sprintf(sql_str, "%s %s %s %s %s '%s' %s '%s' %s '%s'", 
		"UPDATE ", bom, "SET p_tagno = ", bom_data[nxi+3], 
		"WHERE n_catalogname = ", bom_data[nxi+0], 
		"AND n_itemname = ", bom_data[nxi+1], 
		"AND n_itemrev = ", bom_data[nxi+2]);
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			MEMclose(&bom_bufr);
			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
			return(PDM_E_SQL_STMT);
		}
	}
	MEMclose(&bom_bufr);	
 }
 PDMdebug("EXIT:PDMgenerate_tagnos\n");
 return(PDM_S_SUCCESS);
}


/* Copies old tag nos from old_bom to bom
   If necessary generates new ones 
*/

int	 PDMactive_carry_tagnos(bom, child_bufr)
char	*bom;
MEMptr  child_bufr;
{
	char	**column_ptr;
	char	**child_data;
	int		i, nk;
        int     a1, a2, a3, a7, a11, a10;
        char    s[1024];
        char    p_assembly[2];
        

 PDMdebug("ENTER:PDMactive_carry_tagnos\n");


	      a1 = -1; a2 = -1; a3 = -1; 
	      a7 = -1; a10 = -1; a11 = -1;

	    /* set offsets using set_bufr	*/
    
	       status = MEMbuild_array(child_bufr);
               if(status != MEM_S_SUCCESS)
                {
		sprintf(s, "%s %s %d \n", 
		"MEMbuild_array ", "failed - status ", status);
                PDMdebug(s);
   		return(PDM_E_BUILD_ARRAY);
                }

	        column_ptr = (char **) child_bufr->column_ptr;
	        child_data = (char **) child_bufr->data_ptr;
	if(PDMdebug_on)
	MEMprint_buffer("child_bufr", child_bufr, PDM_DEBUG_FILE);

	for(i=0;i<child_bufr->columns;i++)
	{
		if(!strcmp(column_ptr[i], "n_catalogname"))      a1 = i;
		if(!strcmp(column_ptr[i], "n_itemname")) 		a2 = i;
		if(!strcmp(column_ptr[i], "n_itemrev"))		a3 = i;
		if(!strcmp(column_ptr[i], "p_childno")) 		a7 = i;
		if(!strcmp(column_ptr[i], "p_tagno")) 		a10 = i;
		if(!strcmp(column_ptr[i], "p_alttagno")) 	a11 = i;
	}
	if(a1 == -1 || a2 == -1 || a3 == -1 ||  
	   a7 == -1 || a10 == -1 || a11 == -1)
	{
		PDMdebug("Could not set offsets in set_bufr\n");
		return(PDM_E_BUFFER_FORMAT);
	}
	for(i=0;i<child_bufr->rows;i++)
        {
               nk = i * child_bufr->columns;
               p_assembly[0] = '\0';
               status = PDMquery_assembly_ind(child_data[nk+a1],          
                        child_data[nk+a2], child_data[nk+a3], p_assembly);
        	if(status != PDM_S_SUCCESS)
        	{
		sprintf(s, "PDMquery_assembly_ind failed status %d\n", status);
		PDMdebug(s);
		return(status);
        	}
            if(!strncmp(p_assembly, "Y", 1) || !strncmp(p_assembly, "y", 1))
            {
               status = PDMactive_child_tags(bom, 
                       0, 1, child_data[nk + a7], 
                       atol(child_data[nk + a10]), child_data[nk + a11]);

        	if(status != PDM_S_SUCCESS)
        	{
		sprintf(s, "PDMactive_child_tags failed status %d\n", status);
		PDMdebug(s);
		return(status);
        	}
            }
        }
 PDMdebug("EXIT:PDMactive_carry_tagnos\n");
 return(PDM_S_SUCCESS);
}

int	 PDMreview_carry_tagnos(bom, child_bufr)
char	*bom;
MEMptr  child_bufr;
{
	char	**column_ptr;
	char	**child_data;
	int		i, nk;
        int     a1, a2, a3, a7, a11, a10;
        int     pp_partno;
        char    s[1024];
        char    p_assembly[2];
        

 PDMdebug("ENTER:PDMreview_carry_tagnos\n");

/* ANSI */
	bom = NULL;
	
	      a1 = -1; a2 = -1; a3 = -1; 
	      a7 = -1; a10 = -1; a11 = -1;

	    /* set offsets using set_bufr	*/
    
	       status = MEMbuild_array(child_bufr);
               if(status != MEM_S_SUCCESS)
                {
		sprintf(s, "%s %s %d \n", 
		"MEMbuild_array ", "failed - status ", status);
                PDMdebug(s);
   		return(PDM_E_BUILD_ARRAY);
                }

	        column_ptr = (char **) child_bufr->column_ptr;
	        child_data = (char **) child_bufr->data_ptr;

	for(i=0;i<child_bufr->columns;i++)
	{
		if(!strcmp(column_ptr[i], "n_catalogname"))      a1 = i;
		if(!strcmp(column_ptr[i], "n_itemname"))		a2 = i;
		if(!strcmp(column_ptr[i], "n_itemrev"))		a3 = i;
		if(!strcmp(column_ptr[i], "n_citno")) 		a7 = i;
		if(!strcmp(column_ptr[i], "n_level")) 		a10 = i;
	}
	if(a1 == -1 || a2 == -1 || a3 == -1 ||
	   a7 == -1 ||a10 == -1 )
	{
		PDMdebug("Could not set offsets in set_bufr\n");
		return(PDM_E_BUFFER_FORMAT);
	}
	for(i=0;i<child_bufr->rows;i++)
        {
               nk = i * child_bufr->columns;
               p_assembly[0] = '\0';
               status = PDMquery_assembly_ind(child_data[nk+a1],          
                        child_data[nk+a2], child_data[nk+a3], p_assembly);
        	if(status != PDM_S_SUCCESS)
        	{
		sprintf(s, "PDMquery_assembly_ind failed status %d\n", status);
		PDMdebug(s);
		return(status);
        	}
            if(!strncmp(p_assembly, "Y", 1) || !strncmp(p_assembly, "y", 1))
            {
               
               pp_partno = 0;
               status = PDMquery_partno(child_data[nk+a1], child_data[nk+a2], 
                                        child_data[nk+a3], &pp_partno);

        	if(status != PDM_S_SUCCESS)
        	{
		sprintf(s, "PDMquery_partno failed status %d\n", status);
		PDMdebug(s);
		return(status);
        	}
               status = PDMreview_child_tags(pp_partno, 
                       atol(child_data[nk + a10]), child_data[nk + a11]);

        	if(status != PDM_S_SUCCESS)
        	{
		sprintf(s, "PDMreview_child_tags failed status %d\n", status);
		PDMdebug(s);
		return(status);
        	}
            }
        }
 PDMdebug("EXIT:PDMreview_carry_tagnos\n");
 return(PDM_S_SUCCESS);
}


int	 PDMcreate_join_buffer(set_bufr, join_bufr)
MEMptr		set_bufr;
MEMptr		*join_bufr;
{
	int		a1, a2, a3, a4;
	int		a5, a6, a7, a8, a9, a10, a11, a12, a13;
	int		i, nxi;
	char	**set_data;
	char	**column_ptr;
	
	PDMdebug("ENTER:PDMcreate_join_buffer\n");

	a1 = -1; a2 = -1; a3 = -1; 
	a4 = -1; a5 = -1; a6 = -1;
	a7 = -1; a8 = -1; a9 = -1;
        a10 = -1; a11 = -1; a12 = -1; a13 = -1;

	    /* set offsets using set_bufr	*/
	status = MEMbuild_array(set_bufr);
    if(status != MEM_S_SUCCESS)
    {
		sprintf(s, "%s %s %d \n", 
		"MEMbuild_array ", "failed - status ", status);
        PDMdebug(s);
   		return(PDM_E_BUILD_ARRAY);
    }
	column_ptr = (char **) set_bufr->column_ptr;
	set_data = (char **) set_bufr->data_ptr;
	for(i=0;i<set_bufr->columns;i++)
	{
		if(!strcmp(column_ptr[i], "n_catalogname"))  a1 = i;
		if(!strcmp(column_ptr[i], "n_itemname")) 		a2 = i;
		if(!strcmp(column_ptr[i], "n_itemrev"))		a3 = i;
		if(!strcmp(column_ptr[i], "p_history")) 		a4 = i;
		if(!strcmp(column_ptr[i], "p_orient")) 		a5 = i;
		if(!strcmp(column_ptr[i], "p_quantity")) 	a6 = i;
		if(!strcmp(column_ptr[i], "p_childno")) 		a7 = i;
		if(!strcmp(column_ptr[i], "p_viewid")) 		a8 = i;
		if(!strcmp(column_ptr[i], "p_usageid")) 		a9 = i;
		if(!strcmp(column_ptr[i], "p_tagno")) 		a10 = i;
		if(!strcmp(column_ptr[i], "p_alttagno")) 	a11 = i;
		if(!strcmp(column_ptr[i], "p_incbom"))    	a12 = i;
		if(!strcmp(column_ptr[i], "p_explode"))    	a13 = i;
	}
	if(a1 == -1 || a2 == -1 || a3 == -1 ||
	   a4 == -1 || a5 == -1 || a6 == -1 ||
	   a7 == -1 || a8 == -1 || a9 == -1 ||
          a10 == -1 || a11 == -1|| a12== -1 || a13 == -1)
	{
		PDMdebug("Could not set offsets in set_bufr\n");
		return(PDM_E_BUFFER_FORMAT);
	}

	/* open join_bufr */

	status = MEMopen(join_bufr, 2048);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "%s %s %d \n", 
		"MEMopen ", "failed - status ", status);
                PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
	}

	status = MEMwrite_format(*join_bufr, "p_parentno", "integer");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*join_bufr, "n_catalogname", "char(20)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*join_bufr, "n_itemname", "char(30)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*join_bufr, "n_itemrev", "char(30)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*join_bufr, "p_history", "char(10)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*join_bufr, "p_orient", "char(240)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*join_bufr, "p_quantity", "double");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*join_bufr, "p_childno", "char(20)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*join_bufr, "p_viewid", "char(20)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*join_bufr, "p_usageid", "char(20)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*join_bufr, "p_tagno", "integer");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*join_bufr, "p_alttagno", "char(25)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*join_bufr, "p_incbom", "char(1)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*join_bufr, "p_explode", "char(1)");
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		MEMclose(join_bufr);
		return(PDM_E_WRITE_FORMAT);
	}
	for(i=0;i<set_bufr->rows;i++)
	{
		nxi = i * set_bufr->columns;
	sprintf(s, "0\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", 
 		set_data[nxi+a1], set_data[nxi+a2], set_data[nxi+a3], 
 		set_data[nxi+a4], set_data[nxi+a5], set_data[nxi+a6], 
 		set_data[nxi+a7], set_data[nxi+a8], set_data[nxi+a9], 
 		set_data[nxi+a10], set_data[nxi+a11], set_data[nxi+a12], 
                set_data[nxi+a13]);
		status = MEMwrite(*join_bufr, s);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(join_bufr);
			sprintf(s, "%s %s %d \n", 
			"MEMwrite ", "failed - status ", status);
	        PDMdebug(s);
			return(PDM_E_WRITE_ROW);
		}
	}
	PDMdebug("EXIT:PDMcreate_join_buffer\n");
	return(PDM_S_SUCCESS);
}

/*
   function built on top of NFMqery_set_members
   eliminates the first row in the data_bufr
   returned by  NFMqery_set_members function
*/

int NFMquery_set_members1(user_id, catalog, part_num, 
	revision, qry_level, attr_bufr, data_bufr)
long	user_id;
char    *catalog;
char	*part_num;
char	*revision;
long	qry_level;
MEMptr	*attr_bufr;
MEMptr	*data_bufr;
{
	MEMptr		data_bufr1 = NULL;
	char		**column_ptr;
	char		**data_ptr;
	char		**format_ptr;
	char		arow[1024];
	int			i, nxi, j;

	PDMdebug("ENTER:NFMquery_set_members1\n");
	status = NFMquery_set_members(user_id, catalog, part_num, 
			 revision, qry_level, 0, attr_bufr, &data_bufr1);
	if(status != NFM_S_SUCCESS)
	{
		sprintf(s, "%s %d \n", 
		"NFMquery_set_members failed status ", status);
		PDMdebug(s);
		return(PDM_E_QUERY_SET_MEMBERS);
	}
	status = MEMbuild_array(data_bufr1);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(attr_bufr);
		MEMclose(&data_bufr1);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	status = MEMopen(data_bufr, 1024);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(attr_bufr);
		MEMclose(&data_bufr1);
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
	}
	column_ptr = (char **) data_bufr1->column_ptr;
	format_ptr = (char **) data_bufr1->format_ptr;
	data_ptr   = (char **) data_bufr1->data_ptr;
	for(i=0;i<data_bufr1->columns;i++)
	{
		status = MEMwrite_format(*data_bufr, 
					column_ptr[i], format_ptr[i]);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(attr_bufr);
			MEMclose(&data_bufr1);
			MEMclose(data_bufr);
			sprintf(s, "MEMwrite_format failed status %d\n", 
			status);
			PDMdebug(s);
			return(PDM_E_WRITE_FORMAT);
		}
	}
	for(i=1;i<data_bufr1->rows;i++)
	{
		strcpy(arow, "");
		nxi = i * data_bufr1->columns;
		for(j=0;j<data_bufr1->columns;j++)
		{
			strcat(arow, data_ptr[nxi+j]);
			strcat(arow, "\1");
		}
		status = MEMwrite(*data_bufr, arow);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(attr_bufr);
			MEMclose(&data_bufr1);
			MEMclose(data_bufr);
			sprintf(s, "MEMwrite failed status %d\n", status);
			PDMdebug(s);
			return(PDM_E_WRITE_ROW);
		}
	}
	MEMclose(&data_bufr1);
	PDMdebug("EXIT:NFMquery_set_members1\n");
	return(NFM_S_SUCCESS);
}

int	PDMstructure_bom(t1, t1_str, t2, attr_str, 
	cat_attr, cit_attr, usr_attr, bufr)
char	*t1;
char	*t1_str;
char	*t2;
char	*attr_str;
MEMptr	cat_attr;
MEMptr	cit_attr;
MEMptr	usr_attr;
MEMptr	bufr;
{
	MEMptr		bufr1 = NULL;
	char		*ins_str = NULL;
	char		*sel_str = NULL;
	char		*val_str = NULL;
	char		sql_str[1024];
	char		**cat_names = NULL;
	char		**cat_format = NULL;
	char		**cit_names = NULL;
	char		**cit_format = NULL;
	char		**usr_names = NULL;
	char		**usr_format = NULL;
	char		**bufr_names = NULL;
	char		**bufr_data = NULL;
	int			s1, s2, a1, a2, a3, a4;
	int			found;
	int			i, j, k, nx;

	PDMdebug("ENTER:PDMstucture_bom\n");
	a1 = 1;
	a2 = 5 ; a3 = 6; a4 = 7;
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		return(PDM_E_BUILD_ARRAY);
	}
	if(bufr->rows == 0)  
	{
		PDMdebug("EXIT:PDMstucture_bom\n");
		return(PDM_S_SUCCESS);
	}

	cat_names = (char **) cat_attr->column_ptr;
	cat_format = (char **) cat_attr->format_ptr;
	cit_names = (char **) cit_attr->column_ptr;
	cit_format = (char **) cit_attr->format_ptr;
	bufr_names = (char **) bufr->column_ptr;
	bufr_data = (char **) bufr->data_ptr;

	if(usr_attr != NULL)
	{
		usr_names = (char **) usr_attr->column_ptr;
		usr_format = (char **) usr_attr->format_ptr;
        }
	s1 = strlen(attr_str);
	sel_str = (char *) malloc(s1 + 512);
	if(sel_str == NULL)
	{
		return(PDM_E_COULD_NOT_MALLOC);
	}
/*
         if(PDMdebug_on)
         {
           MEMprint_buffer("cat_atr", cat_attr, PDM_DEBUG_FILE);
           MEMprint_buffer("cit_atr", cit_attr, PDM_DEBUG_FILE);
           MEMprint_buffer("usr_atr", usr_attr, PDM_DEBUG_FILE);
           MEMprint_buffer("data_bufr", bufr, PDM_DEBUG_FILE);
         }
*/
	s2 = 0;
	s2 = s2 + cat_attr->row_size;
	s2 = s2 + cit_attr->row_size;
	if(usr_attr != NULL)
	{
		s2 = s2 + usr_attr->row_size;
	}
	val_str = (char *) malloc( s2 + 512);
	if(val_str == NULL)
	{
		free(sel_str);
		return(PDM_E_COULD_NOT_MALLOC);
	}
	ins_str = (char *) malloc(s1 + s2 + 512);
	if(ins_str == NULL)
	{
		free(sel_str); free(val_str);
		return(PDM_E_COULD_NOT_MALLOC);
	}
	sprintf(sel_str, "INSERT INTO %s (%s) VALUES (", t2, attr_str);	
	for(i=0;i<bufr->rows;i++)
	{
		strcpy(val_str, "");
		nx = i * bufr->columns;
		for(j=0;j<cat_attr->columns;j++)
		{
			found = -1;
		    for(k=0;k<bufr->columns;k++)
			{
				if(!strcmp(cat_names[j], bufr_names[k]))
				{
					found = k; break;
				}
			}
			if(!strncmp(cat_format[j], "char", 4))
			{
				strcat(val_str, "'");
				if(found != -1)
					strcat(val_str, bufr_data[nx+found]);
				else
					strcat(val_str, "");
				strcat(val_str, "', ");
			}
			else
			{
				if(found != -1)
					strcat(val_str, bufr_data[nx+found]);
				else
					strcat(val_str, "null");
				strcat(val_str, ", ");
			}
		}
		for(j=0;j<cit_attr->columns;j++)
		{
			found = -1;
		    for(k=0;k<bufr->columns;k++)
			{
				if(!strcmp(cit_names[j], bufr_names[k]))
				{
					found = k; break;
				}
			}
			if(!strncmp(cit_format[j], "char", 4))
			{
				strcat(val_str, "'");
				if(found != -1)
					strcat(val_str, bufr_data[nx+found]);
				else
					strcat(val_str, "");
				strcat(val_str, "'");
				 strcat(val_str, ", ");
			}
			else
			{
				if(found != -1)
					strcat(val_str, bufr_data[nx+found]);
				else
					strcat(val_str, "null");
			          strcat(val_str, ", ");
			}
		}
		if(usr_attr != NULL)
		{
			for(j=0;j<usr_attr->columns;j++)
			{
			             found = -1;
		                 for(k=0;k<bufr->columns;k++)
			         {
				if(!strcmp(usr_names[j], bufr_names[k]))
				       {
					found = k; break;
				       }
			          }

				if(!strncmp(usr_format[j], "char", 4))
				{
			              strcat(val_str, "'");
				if(found != -1)
					strcat(val_str, bufr_data[nx+found]);
				else
					strcat(val_str, "");
					strcat(val_str, "'");
					if(j != usr_attr->columns-1) strcat(val_str, ", ");
				}
				else
				{
				if(found != -1)
					strcat(val_str, bufr_data[nx+found]);
				else
					strcat(val_str, "null");
			  if(j != usr_attr->columns-1) strcat(val_str, ", ");
			    }
			}
		}
		strcat(val_str, ")");
		sprintf(ins_str, "%s %s ", sel_str, val_str);
		status = SQLstmt(ins_str);
		if(status != SQL_S_SUCCESS)
		{
			free(ins_str); free(sel_str); free(val_str);
			return(PDM_E_SQL_STMT);
		}
		sprintf(sql_str, "SELECT %s FROM %s %s %d %s", 
		t1_str, t1, "WHERE p_parentno = ", atol(bufr_data[nx+a1]), 
		"ORDER BY p_seqno");
		status = SQLquery(sql_str, &bufr1, 1024);
		if(status != SQL_S_SUCCESS)
		{
			if(status == SQL_I_NO_ROWS_FOUND)
			{
			}
			else
			{
				MEMclose(&bufr1);
				free(ins_str); free(sel_str); free(val_str);
				return(PDM_E_SQL_QUERY);
			}
		}
		status = PDMstructure_bom(t1, t1_str, t2, attr_str, 
				cat_attr, cit_attr, usr_attr, bufr1);
		if(status != PDM_S_SUCCESS)
		{
			free(ins_str); free(sel_str); free(val_str);
			MEMclose(&bufr1);
			return(status);
		}
		MEMclose(&bufr1); bufr1 = NULL;
	}
	free(ins_str); free(sel_str); free(val_str);
	PDMdebug("EXIT:PDMstucture_bom\n");
	return(PDM_S_SUCCESS);
}

int PDMxyz(cat_attr)
MEMptr	*cat_attr;
{
	PDMdebug("ENTER:PDMxyz\n");
	status = MEMopen(cat_attr, 1024);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
	}

	status = MEMwrite_format(*cat_attr, "n_itemdesc", "char(40)");
/*
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_creationdate", "char(10)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_creationtime", "char(8)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_updatedate", "char(10)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_updatetime", "char(8)");
*/
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_incpartrpt", "char(1)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_mrpbomuom", "char(10)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_mrpeffectdate", "char(8)");
	if(status == MEM_S_SUCCESS)
	status = MEMwrite_format(*cat_attr, "p_mrpinvuom", "char(10)");
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(cat_attr);
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
	}
	PDMdebug("EXIT:PDMxyz\n");
	return(PDM_S_SUCCESS);
}

int PDMreview_child_tags(pp_partno, p_tagno, p_alttagno)
int     pp_partno;
int     p_tagno;
char	*p_alttagno;
{
	char	sql_str[512];
        MEMptr  cit_bufr = NULL;
	char		**join_data;
        int     i, nxi;

	PDMdebug("ENTER:PDMreview_child_tags\n");
	sprintf(sql_str, "%s %s  WHERE %s %d", 
	"SELECT n_citno", 
     " FROM nfmsetcit", 
	"n_pitemno = ", pp_partno); 
	status = SQLquery(sql_str, &cit_bufr, 1024);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
		PDMdebug("sql string : ");
		PDMdebug(sql_str);
		MEMclose(&cit_bufr);
		return(PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(cit_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "%s %d\n", 
		"MEMbuild_array failed status ", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	join_data = (char **) cit_bufr->data_ptr;
	for(i=0;i<cit_bufr->rows;i++)
        {
        
		nxi = i * cit_bufr->columns;
		sprintf(sql_str, "%s  %s %d, %s '%s' %s %d ", 
		"UPDATE pdmcit", "SET p_tagno = ", p_tagno, "p_alttagno =", p_alttagno, "WHERE p_citno = ", atol(join_data[nxi]));

		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
			return(PDM_E_SQL_STMT);
		}
       }
        MEMclose(&cit_bufr);
	PDMdebug("EXIT:PDMreview_child_tags\n");
	return(PDM_S_SUCCESS);
}


int PDMactive_child_tags ( bom, p_parentno, n_level, 
                          p_childno, p_tagno, p_alttagno)
char    *bom;
int     p_parentno;
int     n_level;
char	*p_childno;
int     p_tagno;
char	*p_alttagno;
{
	char	sql_str[512];
        MEMptr  cit_bufr = NULL;
	char	**join_data;
        int     i, nxi;

	PDMdebug("ENTER:PDMactive_child_tags\n");

/* ANSI */
	p_parentno = 0;

	sprintf(sql_str, "%s %s %s WHERE %s %s %s %d", 
	"SELECT p_parentno, p_childno, n_level", 
     " FROM ", bom, 
	"p_parentno = ", p_childno, "AND n_level =", (n_level +1)); 
	status = SQLquery(sql_str, &cit_bufr, 1024);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&cit_bufr);

                if(status == SQL_I_NO_ROWS_FOUND)
                {
                   return(PDM_S_SUCCESS);
                }
                else
                {
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
		PDMdebug("sql string : ");
		PDMdebug(sql_str);
		return(PDM_E_SQL_QUERY);
                }
	}
	status = MEMbuild_array(cit_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "%s %d\n", 
		"MEMbuild_array failed status ", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	join_data = (char **) cit_bufr->data_ptr;
        if(strlen(p_alttagno)== 0) strcpy(p_alttagno, "NULL");
	for(i=0;i<cit_bufr->rows;i++)
        {
        
		nxi = i * cit_bufr->columns;
		if (strcmp(p_alttagno, "NULL"))
  		  sprintf(sql_str, "%s %s %s %d, %s '%s' %s %d %s '%s' %s %d", 
		  "UPDATE ", bom, "SET p_tagno = ", p_tagno, "p_alttagno =", p_alttagno, "WHERE p_parentno = ", atol(join_data[nxi]), "AND p_childno =", join_data[nxi+1], "AND n_level = ", atol(join_data[nxi+2]));
		else
  		  sprintf(sql_str, "%s %s %s %d, %s %s %s %d %s '%s' %s %d", 
		  "UPDATE ", bom, "SET p_tagno = ", p_tagno, "p_alttagno =", p_alttagno, "WHERE p_parentno = ", atol(join_data[nxi]), "AND p_childno =", join_data[nxi+1], "AND n_level = ", atol(join_data[nxi+2]));
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
			return(PDM_E_SQL_STMT);
		}
                status = PDMactive_child_tags(bom, atol(join_data[nxi]), 
                 atol(join_data[nxi+2]), join_data[nxi+1], p_tagno, p_alttagno);
                if(status != PDM_S_SUCCESS)
                {
                   MEMclose(&cit_bufr);
                   return(status);
                }
       }
        MEMclose(&cit_bufr);
	PDMdebug("EXIT:PDMactive_child_tags\n");
	return(PDM_S_SUCCESS);
}
