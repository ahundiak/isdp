/* Do not alter this SPC information: $Revision: 1.4.3.1 $ */
/*
**	NAME:							frmutil.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					10/90
**	ABSTRACT:
**		This file contains misc routines used by RIS forms
**	
**	REVISION HISTORY:
** 		10/24/94 -Radha
**			Added changes for MSSQL data server.
**              04/19/96 - Ashley
**                      added RISfrm_set_passwd_no_echo() for TR 439502302 
**		06/18/96 - Ashley
**			took out FIg_display() from RISfrm_set_passwd_no_echo()
**			for TR 439601342 
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "forms.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmutil_c
#include "comdebug.prt"
#include "comstcmi.prt"
#include "frmexec.prt"
#include "frmutil.prt"
#include "fi.prt"
#include "sys.prt"
#include "comisfn.prt"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int RISfrm_gadget_displayed(
	Form fp,
	int g_label)
{
	int ret;
	int attr_mask;

	FRM_DBG(("RISfrm_gadget_displayed(fp:0x%x g_label:%d)\n", fp, g_label));

	FIg_get_attr(fp, g_label, &attr_mask);
	if (attr_mask & FI_NOT_DISPLAYED) ret = 0;
	else ret = 1;

	FRM_DBG(("RISfrm_gadget_displayed() returns %d\n", ret));
	return ret;
}

/******************************************************************************
*  Created  for TR 439502302 - Ashley 4/19/96
*******************************************************************************/
extern void RISfrm_set_passwd_no_echo(
	Form	fp,
	int		field_label)
{

	FRM_DBG(("RISfrm_set_passwd_no_echo(fp:0x%x field_label:%d)\n",
		fp, field_label));
	
	FIfld_set_attr(fp, field_label, 0, FI_NO_ECHO);

}

/******************************************************************************/

extern void RISfrm_set_passwd_echo(
	Form	fp,
	int		toggle_label,
	int		field_label)
{
	int	passwd_echo;
	long	attr_mask;

	FRM_DBG(("RISfrm_set_passwd_echo(fp:0x%x toggle_label:%d field_label:%d)\n",
		fp, toggle_label, field_label));

	FIg_get_state(fp, toggle_label, &passwd_echo);
	
	FIfld_get_attr(fp, field_label, 0, &attr_mask);
	if (passwd_echo)
	{
		attr_mask &= ~FI_NO_ECHO;
	}
	else
	{
		attr_mask |= FI_NO_ECHO;
	}
	FIfld_set_attr(fp, field_label, 0, attr_mask);
	FIg_display(fp, field_label);
}

/******************************************************************************/

extern void RISfrm_get_field(
	Form	fp,
	int		label,
	int		size,
	char	*buffer)
{
	int		sel_flag;
	int		r_pos;
	char	*start;
	char	*finish;

	FRM_DBG(("RISfrm_get_field(form:0x%x label:%d size:%d buffer:0x%x)\n",
		fp, label, size, buffer));

	*buffer = 0;
	FIfld_get_text(fp, label, 0, 0, size, (unsigned char*)buffer, &sel_flag,
		&r_pos);

	/*
	**	remove leading and trailing white space
	*/
	for (start = buffer; *start && RIScom_isspace(*start); start++);
	if (!*start)
	{
		*buffer = 0;
		return;
	}

	finish = start + strlen(start) - 1;
	for (;finish > start && RIScom_isspace(*finish); finish--);

	for (; start <= finish; start++, buffer++)
		*buffer = *start;

	*buffer = '\0';
}

/******************************************************************************/

extern ris_db_info *RISfrm_db_from_schema(
	ris_schema_info *schema)
{
	ris_db_info	*db = NULL;

	FRM_DBG(("RISfrm_db_from_schema(schema:0x%x)\n", schema));

	if (!schema) return NULL;

	for (db = RISfrm_dbs; db; db = db->next)
	{
		if (schema->dbid == db->dbid)
			break;
	}

	FRM_DBG(("RISfrm_db_from_schema: returning db:0x%x\n", db));
	return db;
}

/*******************************************************************************
******************** PROT ******************************************************
*******************************************************************************/

extern int RISfrm_get_form_prot(
	unsigned char ris_prot)
{
	FRM_DBG(("RISfrm_get_form_prot(ris_prot:%c)\n", ris_prot));
	switch(ris_prot)
	{
		case 'X': return(XNS_PROT);
		case 'T': return(TCP_PROT);
		case 'D': return(DNP_PROT);
		case 'I': return(ISO_PROT);
		default:  return(-1);
	}
}

/******************************************************************************/

extern unsigned char RISfrm_get_ris_prot(
	int form_prot)
{
	FRM_DBG(("RISfrm_get_ris_prot(form_prot:%d)\n", form_prot));
	switch(form_prot)
	{
		case XNS_PROT:	return 'X';
		case TCP_PROT:	return 'T';
		case DNP_PROT:	return 'D';
		case ISO_PROT:	return 'I';
		default:		return(0);
	}
}

/******************************************************************************/

extern int RISfrm_get_form_prot_by_name(
	char	*name)
{
	int i;
	int ret = -1;

	FRM_DBG(("RISfrm_get_form_prot_by_name(name:<%s>)\n",name ? name : "NULL"));

	if (name)
	{
		for (i = 0; i < PROT_COUNT; i++)
		{
			if (!strcmp(name, RISfrm_get_prot_name(i)))
			{
				ret = i;
				break;
			}
		}
	}

	FRM_DBG(("RISfrm_get_form_prot() returns %d\n", ret));

	return ret;
}

/******************************************************************************/

extern char *RISfrm_get_prot_name(
	int prot)
{
	FRM_DBG(("RISfrm_get_prot_name(prot:%d)\n", prot));
	switch(prot)
	{
		case XNS_PROT:	return("XNS");
		case TCP_PROT:	return("TCP");
		case DNP_PROT:	return("DNP");
		case ISO_PROT:	return("ISO");
		default:		return("Unknown");
	}
}

/*******************************************************************************
******************** DB TYPE ***************************************************
*******************************************************************************/

extern int RISfrm_get_frmdbtype_from_risdbtype(
	unsigned char risdbtype)
{
	FRM_DBG(("RISfrm_get_frmdbtype_from_risdbtype(risdbtype:%c)\n", risdbtype));
	switch(risdbtype)
	{
		case INFORMIX_CHAR:	return(INFORMIX_DB);
		case INGRES_CHAR:	return(INGRES_DB);
		case ORACLE_CHAR:	return(ORACLE_DB);
		case DB2_CHAR:		return(DB2_DB);
		case RDB_CHAR:		return(RDB_DB);
		case SYBASE_CHAR:	return(SYBASE_DB);
		case OS400_CHAR:        return(OS400_DB);
		case MSSQL_CHAR:	return(MSSQL_DB);
	}
	return -1;
}

/******************************************************************************/

extern unsigned char RISfrm_get_risdbtype_from_frmdbtype(
	int frmdbtype)
{
	FRM_DBG(("RISfrm_get_risdbtype_from_frmdbtype(frmdbtype:%d)\n",
		frmdbtype));
	switch(frmdbtype)
	{
		case INFORMIX_DB:	return INFORMIX_CHAR;
		case INGRES_DB:		return INGRES_CHAR;
		case ORACLE_DB:		return ORACLE_CHAR;
		case DB2_DB:		return DB2_CHAR;
		case RDB_DB:		return RDB_CHAR;
		case SYBASE_DB:		return SYBASE_CHAR;
		case OS400_DB:		return OS400_CHAR;
		case MSSQL_DB:		return MSSQL_CHAR;
	}

	return 0;
}

/******************************************************************************/

extern char *RISfrm_get_dbtypename_from_frmdbtype(
	int frmdbtype)
{
	FRM_DBG(("RISfrm_get_dbtypename_from_frmdbtype(frmdbtype:%d)\n",frmdbtype));
	switch(frmdbtype)
	{
		case INFORMIX_DB:	return INFORMIX_NAME;
		case ORACLE_DB:		return ORACLE_NAME;
		case INGRES_DB:		return INGRES_NAME;
		case DB2_DB:		return DB2_NAME;
		case RDB_DB:		return RDB_NAME;
		case SYBASE_DB:		return SYBASE_NAME;
		case OS400_DB:		return OS400_NAME;
		case MSSQL_DB:		return MSSQL_NAME;
	}
	return NULL;
}

/******************************************************************************/

extern int RISfrm_get_frmdbtype_from_dbtypename(
	char *dbtypename)
{
	FRM_DBG(("RISfrm_get_frmdbtype_from_dbtypename(dbtypename:%s)\n",
		STRING(dbtypename)));

	if (!RIScom_strcmp_ic(dbtypename, INFORMIX_NAME)) return INFORMIX_DB;
	if (!RIScom_strcmp_ic(dbtypename, INGRES_NAME)) return INGRES_DB;
	if (!RIScom_strcmp_ic(dbtypename, ORACLE_NAME)) return ORACLE_DB;
	if (!RIScom_strcmp_ic(dbtypename, DB2_NAME)) return DB2_DB;
	if (!RIScom_strcmp_ic(dbtypename, RDB_NAME)) return RDB_DB;
	if (!RIScom_strcmp_ic(dbtypename, SYBASE_NAME)) return SYBASE_DB;
	if (!RIScom_strcmp_ic(dbtypename, OS400_NAME)) return OS400_DB;
	if (!RIScom_strcmp_ic(dbtypename, MSSQL_NAME)) return MSSQL_DB;

	return -1;
}

/******************************************************************************/
/******************************************************************************/
/******************* WILDCARD STRCMP ******************************************/
/******************************************************************************/

#define MULTI_WILDCARD_CHAR		'%'
#define SINGLE_WILDCARD_CHAR	'_'

extern int RISfrm_wildcard_strcmp(
	char *s1,	/* string with possible wild card */
	char *s2)	/* string to compare against */
{
	if (*s1 == MULTI_WILDCARD_CHAR)
	{
		while(*s1 == MULTI_WILDCARD_CHAR)
			s1++;

		while(*s2)
		{
			if(RISfrm_wildcard_strcmp(s1, s2) == 0)
				return 0;
			s2++;
		}

		if (*s1 == 0 && *s2 == 0)
		{
			return 0;
		}
		else
		{
			return 1;
		}
	}
	else if (*s1 == SINGLE_WILDCARD_CHAR)
	{
		if (*s2)
		{
			return RISfrm_wildcard_strcmp(s1+1, s2+1);
		}
		else
		{
			return 1;
		}
	}
	else
	{
		if (*s1 == *s2)
		{
			if (*s1 == 0) /* which implies s2 == 0 */
			{
				return 0;
			}
			return RISfrm_wildcard_strcmp(s1+1, s2+1);
		}
		else
		{
			return 1;
		}
	}
}

/*******************************************************************************
******************** OSTYPE ****************************************************
*******************************************************************************/

extern char *RISfrm_get_ostype_name(
	unsigned char ris_ostype)
{
	FRM_DBG(("RISfrm_get_ostype_name(ris_ostype:%c)\n", ris_ostype));
	switch(ris_ostype)
	{
		case 'U': return(UNIX_NAME);
		case 'V': return(VMS_NAME);
		case 'N': return(NT_NAME);
	}
	return(NULL);
}

/*******************************************************************************
******************** IBM_PROT **************************************************
*******************************************************************************/

extern char *RISfrm_get_ibmprotname_from_frmibmprot(
	int frmibmprot)
{
	FRM_DBG(("RISfrm_get_ibmprotname_from_frmibmprot(frmibmprot:%d)\n",
		frmibmprot));
	switch(frmibmprot)
	{
		case IBM_LU62_PROT:	return IBM_LU62_NAME;
		case IBM_TCP_PROT:	return IBM_TCP_NAME;
	}
	return NULL;
}

/******************************************************************************/

extern int RISfrm_get_frmibmprot_from_ibmprotname(
	char *ibmprotname)
{
	FRM_DBG(("RISfrm_get_frmibmprot_from_ibmprotname(ibmprotname:%s)\n",
		STRING(ibmprotname)));

	if (!RIScom_strcmp_ic(ibmprotname, IBM_LU62_NAME)) return IBM_LU62_PROT;
	if (!RIScom_strcmp_ic(ibmprotname, IBM_TCP_NAME)) return IBM_TCP_PROT;

	return -1;
}

/******************************************************************************/

extern void RISfrm_clear_multi_row_field(
	Form fp,
	int glabel)
{
	int num_rows;

	FRM_DBG(("RISfrm_clear_multi_row_field(fp:0x%x glabel:%d)\n", fp, glabel));

	FIfld_get_num_rows(fp, glabel, &num_rows);
	if (num_rows)
	{
		FIfld_set_num_rows(fp, glabel, 0);
	}
}

/******************************************************************************/

extern int RISfrm_field_changed(
	char *field,
	char *initial_field)
{
	if (field)
	{
		if (!strcmp(field, initial_field))
		{
			return 0;
		}
		strcpy(initial_field, field);
		return 1;
	}
	else
	{
		if (!initial_field[0])
		{
			return 0;
		}
		initial_field[0] = '\0';
		return 1;
	}
}

/******************************************************************************/

extern int * RISAPI RISXfrm_get_RISfrm_debug_addr()
{
	return &RISfrm_debug;
}

/******************************************************************************/

extern void RISfrm_set_default_schema(	
 	char *schname,
	unsigned short dbid)
{
	char command[80];

	if (!schname || !schname[0])
	{
		FRM_DBG(("RISfrm_set_default_schema: !schname: returning\n"));
		return;
	}

	sprintf(command, "default schema %s", schname);
	FRM_DBG(("RISfrm_set_default_schema command in frmutil.c: <%s> \n",
                  command));
	RISfrm_execute_schema_command(schname, dbid, command);
	
	FRM_DBG(("schema in frmutil.c: <%s> returning\n",
                  schname));
}

/******************************************************************************/
