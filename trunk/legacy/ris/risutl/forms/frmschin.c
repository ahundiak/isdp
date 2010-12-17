/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							frmschin.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/90
**	ABSTRACT:
**		The code to process the schema info form.
**	
**	REVISION HISTORY:
**	Modified to display dictionary ownername, schema type  and os400
**                                            by Linda Wang        12/93
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
**
**		11/94:	Added support for INTERNATIONALIZATION.  Linda Wang
**	02/03/95 Removed NTJ specific changes. rlk
*/
/*
**	INCLUDES
*/
#include <ctype.h>
#include "forms.h"
#include "ris.h"
#include "riscom.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmschin_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "fi.prt"
#include "frmerror.prt"
#include "frmfile.prt"
#include "frmntfy.prt"
#include "frmschin.prt"
#include "frmschmg.prt"
#include "frmschdf.prt"
#include "frmutil.prt"
#include "sys.prt"
#if defined (WIN32)
#include "fi_winnt.prt"
#endif

/*
**	DEFINES
*/
#define ERASE_ALL_GROUPS	-1

/*
**	VARIABLES
*/
static struct
{
    int	prot_field_label;
    int	addr_field_label;
} node_info[RIS_MAX_PROTOCOLS] =
{
    {   SI_PROT1_FIELD,    SI_ADDR1_FIELD },
    {   SI_PROT2_FIELD,    SI_ADDR2_FIELD },
    {   SI_PROT3_FIELD,    SI_ADDR3_FIELD },
    {   SI_PROT4_FIELD,    SI_ADDR4_FIELD },
};

static struct 
{
	int	label;
	int db_info_valid;
	int	dbms_location_valid;
	int	osusrname_dbusrname_link;
	char *name;
} db_group[DB_COUNT] =
{
	{	SI_IFX_GROUP,	1,	1,	1, INFORMIX_NAME	},
	{	SI_ORA_GROUP,	1,	1,	0, ORACLE_NAME	},
	{	SI_IGS_GROUP,	1,	1,	1, INGRES_NAME	},
	{	SI_DB2_GROUP,	1,	0,	0, DB2_NAME	},
	{	SI_RDB_GROUP,	1,	0,	0, RDB_NAME	},
	{	SI_SYB_GROUP,	1,	1,	0, SYBASE_NAME	},
	{	SI_OS400_GROUP,	1,	0,	0, OS400_NAME	},
	{	SI_MSSQL_GROUP,	1,	1,	0, MSSQL_NAME	},
};

static struct
{
	int label;
	char *name;
} ibmprot_group[IBM_PROT_COUNT] =
{
	{	SI_IBM_LU62_GROUP,	IBM_LU62_NAME	},
	{	SI_IBM_TCP_GROUP,	IBM_TCP_NAME	},
};

static  Form			si_form = 0;
static RISfrm_msg	*si_msg = &RISfrm_msgs[SI_FORM_MSG];
static  char			initial_schname[RIS_MAX_ID_SIZE] = "";

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** SI_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(si_form, SI_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(si_form, SI_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SI_SCHNAME FIELD ******************************************
*******************************************************************************/

static char *get_schname_field()
{
	static	 char		schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_schname_field()\n"));
	RISfrm_get_field(si_form, SI_SCHNAME_FIELD, RIS_MAX_ID_SIZE, schname);
	return schname[0] ? schname : NULL;
}

/******************************************************************************/

static void process_schname_field()
{
	char		*schname;
	ris_schema_info	*schema;

	FRM_DBG(("process_schname_field()\n"));

	schname = get_schname_field();
	if (!RISfrm_field_changed(schname, initial_schname))
	{
		return;
	}
	schema = RISfrm_get_schema(schname, update_msg_field, clear_msg_field);
	if (schema == NULL)
	{
		if (schname)
		{
			sprintf(si_msg->str, MSG(RISUTL_I_UNKNOWN_SCHEMA), schname);
		}
	}

	if (RISfrm_sm_form_displayed())
	{
		RISfrm_update_sm_schemas_field(schname);
	}

	update_si_form(schema);
}

/******************************************************************************/

static void update_schname_field(
	char	*schname)
{
	FRM_DBG(("update_schname_field(schname:<%s>)\n",schname));
	FIfld_set_text(si_form, SI_SCHNAME_FIELD, 0, 0, schname, 0);
	strcpy(initial_schname, schname);
}

/******************************************************************************/

static void clear_schname_field()
{
	FRM_DBG(("clear_schname_field()\n"));
	FIfld_set_text(si_form, SI_SCHNAME_FIELD, 0, 0, "", 0);
	strcpy(initial_schname, "");
}

/*******************************************************************************
******************** PROT FIELDS ***********************************************
*******************************************************************************/

static void update_prot_field(
	int		n,
	char	*prot)
{
	FRM_DBG(("RISfrm_update_prot_field(n:%d prot:<%s>)\n",n ,prot));
	FIfld_set_text(si_form, node_info[n].prot_field_label, 0, 0, prot, 0);
}

/******************************************************************************/

static void clear_prot_field(
	int		n)
{
	FRM_DBG(("clear_prot_field(n:%d)\n", n));
	FIfld_set_text(si_form, node_info[n].prot_field_label, 0, 0, "", 0);
}

/*******************************************************************************
******************** ADDR FIELDS ***********************************************
*******************************************************************************/

static void update_addr_field(
	int		n,
	char	*addr)
{
	FRM_DBG(("RISfrm_update_addr_field(n:%d addr:<%s>)\n",n ,addr));
	FIfld_set_text(si_form, node_info[n].addr_field_label, 0, 0, addr, 0);
}

/******************************************************************************/

static void clear_addr_field(
	int	n)
{
	FRM_DBG(("clear_addr_field(n:%d)\n", n));
	FIfld_set_text(si_form, node_info[n].addr_field_label, 0, 0, "", 0);
}

/*******************************************************************************
******************** PROTOCOL_ADDR *********************************************
*******************************************************************************/

static void update_protocol_addr(
	ris_db_info *db)
{
	int i;
	int prot;

	FRM_DBG(("update_protocol_addr()\n"));

	for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
	{
		if ((prot = RISfrm_get_form_prot(db->pathways[i].protocol)) != -1)
		{
			update_prot_field(i, RISfrm_get_prot_name(prot));
			update_addr_field(i, db->pathways[i].netaddr);
		}
		else
		{
			clear_prot_field(i);
			clear_addr_field(i);
		}
	}
	FRM_DBG(("update_protocol_addr:returning\n"));
}

/******************************************************************************/

static void clear_protocol_addr()
{
	int i;
	FRM_DBG(("clear_protocol_addr()\n"));

	for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
	{
		clear_prot_field(i);
		clear_addr_field(i);
	}

	FRM_DBG(("clear_protocol_addr:returning\n"));
}

/*******************************************************************************
******************** OSTYPE ****************************************************
*******************************************************************************/

static void update_ostype_field(
	char	*ostype)
{
	FRM_DBG(("update_ostype_field(ostype:<%s>)\n",ostype));
	FIfld_set_text(si_form, SI_OSTYPE_FIELD, 0, 0, ostype, 0);
}

/******************************************************************************/

static void clear_ostype_field()
{
	FRM_DBG(("clear_ostype_field()\n"));
	FIfld_set_text(si_form, SI_OSTYPE_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SI_OSUSRNAME_FIELD ****************************************
*******************************************************************************/

static void update_osusrname_field(
	char	*osusrname)
{
	FRM_DBG(("udpate_osusrname_field(osusrname:<%s>)\n",osusrname));
	FIfld_set_text(si_form, SI_OSUSRNAME_FIELD, 0, 0, osusrname, 0);
}

/******************************************************************************/

static void clear_osusrname_field()
{
	FRM_DBG(("clear_osusrname_field()\n"));
	update_osusrname_field("");
}

/***********************************************************************
******************** DATABASE USER NAME FIELD **************************
***********************************************************************/

static void update_dbusrname_field(
	char	*dbusrname)
{
	FRM_DBG(("update_dbusrname_field(dbusrname:<%s>)\n",dbusrname));
	FIfld_set_text(si_form, SI_DBUSRNAME_FIELD, 0, 0, dbusrname, 0);
}

/**********************************************************************/

static void clear_dbusrname_field()
{
	FRM_DBG(("clear_dbusrname_field()\n"));
	FIfld_set_text(si_form, SI_DBUSRNAME_FIELD, 0, 0, "", 0);
}

/***********************************************************************
******************** DICTIONARY OWNER FIELD ****************************
***********************************************************************/

static void update_dictowner_field(
	char	*dictowner)
{
	FRM_DBG(("update_dictowner_field(dictowner:<%s>)\n",dictowner));
	FIfld_set_text(si_form, SI_DICTOWNER_FIELD, 0, 0, dictowner, 0);
}

/**********************************************************************/

static void clear_dictowner_field()
{
	FRM_DBG(("clear_dictowner_field()\n"));
	FIfld_set_text(si_form, SI_DICTOWNER_FIELD, 0, 0, "", 0);
}

/***********************************************************************
******************** SCHEMA TYPE FIELD *********************************
***********************************************************************/

static void update_schtype_field(
unsigned short	secure)
{
	FRM_DBG(("update_schtype_field(secure:<%d>)\n",secure));
        if (secure)
 	      {	
                FIfld_set_text(si_form, SI_SCHTYPE_FIELD, 0, 0,
        	"SECURE" , 0);
              }
	else 
	      {
                FIfld_set_text(si_form, SI_SCHTYPE_FIELD, 0, 0, 
		"STANDARD", 0);
	    
	      }
}

/********************************************************************/

static void clear_schtype_field()
{
	FRM_DBG(("clear_schtype_field()\n"));
	FIfld_set_text(si_form, SI_SCHTYPE_FIELD, 0, 0, "", 0);
}

/***********************************************************************
******************** DBTYPE FIELD **************************************
***********************************************************************/

static void update_dbtype_field(
	int dbtype)
{
	char *dbtypename;

	FRM_DBG(("update_dbtype_field(dbtype:%d)\n", dbtype));
	if (!VALID_DBTYPE(dbtype)) return;

	if ((dbtypename = RISfrm_get_dbtypename_from_frmdbtype(dbtype)) == NULL)
	{
		dbtypename = "";
	}

	FIfld_set_text(si_form, SI_DBTYPE_FIELD, 0, 0, dbtypename, 0);

	erase_db_group(dbtype);
	display_db_group(dbtype);
}

/******************************************************************************/

static void clear_dbtype_field()
{
	FRM_DBG(("clear_dbtype_field()\n"));
	FIfld_set_text(si_form, SI_DBTYPE_FIELD, 0, 0, "", 0);
	erase_db_group(ERASE_ALL_GROUPS);
}


/*******************************************************************************
******************** DBNAME ****************************************************
*******************************************************************************/

static void update_dbname_field(
	char	*dbname)
{
	FRM_DBG(("update_dbname_field(dbname:<%s>)\n",dbname));
	FIfld_set_text(si_form, SI_DBNAME_FIELD, 0, 0, dbname, 0);
}

/******************************************************************************/

static void clear_dbname_field()
{
	FRM_DBG(("clear_dbname_field()\n"));
	FIfld_set_text(si_form, SI_DBNAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** DBMS_LOCATION *********************************************
*******************************************************************************/

static void update_dbms_location_field(
	char	*dbms_location)
{
	FRM_DBG(("update_dbms_location_field()\n"));
	FIfld_set_text(si_form, SI_DBMS_LOCATION_FIELD, 0, 0, dbms_location, 0);
}

/******************************************************************************/

static void clear_dbms_location_field()
{
	FRM_DBG(("clear_dbms_location_field()\n"));
	FIfld_set_text(si_form, SI_DBMS_LOCATION_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SQLEXEC **************************************************
*******************************************************************************/

static void update_sqlexec_field(
	char	*sqlexec)
{
	FRM_DBG(("update_sqlexec_field(sqlexec:<%s>)\n",sqlexec));
	FIfld_set_text(si_form, SI_SQLEXEC_FIELD, 0, 0, sqlexec, 0);
}

/******************************************************************************/

static void clear_sqlexec_field()
{
	FRM_DBG(("clear_sqlexec_field()\n"));
	FIfld_set_text(si_form, SI_SQLEXEC_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** DBTEMP ***************************************************
*******************************************************************************/

static void update_dbtemp_field(
	char	*dbtemp)
{
	FRM_DBG(("update_dbtemp_field(dbtemp:<%s>)\n",dbtemp));
	FIfld_set_text(si_form, SI_DBTEMP_FIELD, 0, 0, dbtemp, 0);
}

/******************************************************************************/

static void clear_dbtemp_field()
{
	FRM_DBG(("clear_dbtemp_field()\n"));
	FIfld_set_text(si_form, SI_DBTEMP_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SI_TBCONFIG_FIELD *****************************************
*******************************************************************************/

static void update_tbconfig_field(
	char	*tbconfig)
{
	FRM_DBG(("update_tbconfig_field(tbconfig:<%s>)\n", tbconfig));
	FIfld_set_text(si_form, SI_TBCONFIG_FIELD, 0, 0, tbconfig, 0);
}

/******************************************************************************/

static void clear_tbconfig_field()
{
	FRM_DBG(("clear_tbconfig_field()\n"));
	update_tbconfig_field("");
}

/*******************************************************************************
******************** SI_GROUP_FIELD ********************************************
*******************************************************************************/

static void update_group_field(
	char	*group)
{
	FRM_DBG(("update_group_field(group:<%s>)\n", group));
	FIfld_set_text(si_form, SI_GROUP_FIELD, 0, 0, group, 0);
}

/******************************************************************************/

static void clear_group_field()
{
	FRM_DBG(("clear_group_field()\n"));
	FIfld_set_text(si_form, SI_GROUP_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SI_IBM_PROT_FIELD *****************************************
*******************************************************************************/

static char *get_ibmprot_field()
{
	static	 char	ibmprot[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_ibmprot_field()\n"));

	RISfrm_get_field(si_form, SI_IBM_PROT_FIELD, RIS_MAX_ID_SIZE, ibmprot);
	return ibmprot[0] ? ibmprot : NULL;
}

/******************************************************************************/

static void process_ibmprot_field()
{
	int	ibmprot;
	char *ibmprotname;

	FRM_DBG(("process_ibmprot_field()\n"));

	if ((ibmprotname = get_ibmprot_field()) != NULL)
	{
		ibmprot = RISfrm_get_frmibmprot_from_ibmprotname(ibmprotname);
		erase_ibmprot_group(ibmprot);
		display_ibmprot_group(ibmprot);
	}
	else
	{
		clear_ibmprot_group();
	}

}

/******************************************************************************/

static void update_ibmprot_field(
	int ibmprot)
{
	char *ibmprotname;

	FRM_DBG(("update_ibmprot_field(ibmprot:%d)\n", ibmprot));
	if (!VALID_IBMPROT(ibmprot)) return;

	if ((ibmprotname = RISfrm_get_ibmprotname_from_frmibmprot(ibmprot)) == NULL)
	{
		ibmprotname = "";
	}

	FIfld_set_text(si_form, SI_IBM_PROT_FIELD, 0, 0, ibmprotname, 0);

	erase_ibmprot_group(ibmprot);

	display_ibmprot_group(ibmprot);
}

/******************************************************************************/

static void clear_ibmprot_field()
{
	FRM_DBG(("clear_ibmprot_field()\n"));
	FIfld_set_text(si_form, SI_IBM_PROT_FIELD, 0, 0, "", 0);
	erase_ibmprot_group(ERASE_ALL_GROUPS);
}

/*******************************************************************************
******************** SI_HOST_PROGRAM_FIELD *************************************
*******************************************************************************/

static void update_host_program_field(
	char	*host_program)
{
	FRM_DBG(("update_host_program_field(host_program:<%s>)\n", host_program));
	FIfld_set_text(si_form, SI_HOST_PROGRAM_FIELD, 0, 0, host_program, 0);
}

/******************************************************************************/

static void clear_host_program_field()
{
	FRM_DBG(("clear_host_program_field()\n"));
	FIfld_set_text(si_form, SI_HOST_PROGRAM_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SI_RIS_LU_FIELD *******************************************
*******************************************************************************/

static void update_ris_lu_field(
	char	*ris_lu)
{
	FRM_DBG(("update_ris_lu_field(ris_lu:<%s>)\n", ris_lu));
	FIfld_set_text(si_form, SI_RIS_LU_FIELD, 0, 0, ris_lu, 0);
}

/******************************************************************************/

static void clear_ris_lu_field()
{
	FRM_DBG(("clear_ris_lu_field()\n"));
	FIfld_set_text(si_form, SI_RIS_LU_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SI_HOST_LU_FIELD ******************************************
*******************************************************************************/

static void update_host_lu_field(
	char	*host_lu)
{
	FRM_DBG(("update_host_lu_field(host_lu:<%s>)\n", host_lu));
	FIfld_set_text(si_form, SI_HOST_LU_FIELD, 0, 0, host_lu, 0);
}

/******************************************************************************/

static void clear_host_lu_field()
{
	FRM_DBG(("clear_host_lu_field()\n"));
	FIfld_set_text(si_form, SI_HOST_LU_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SI_MODE_FIELD *********************************************
*******************************************************************************/

static void update_mode_field(
	char	*mode)
{
	FRM_DBG(("update_mode_field(mode:<%s>)\n", mode));
	FIfld_set_text(si_form, SI_MODE_FIELD, 0, 0, mode, 0);
}

/******************************************************************************/

static void clear_mode_field()
{
	FRM_DBG(("clear_mode_field()\n"));
	FIfld_set_text(si_form, SI_MODE_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SI_GROUP_FIELD ********************************************
*******************************************************************************/

static void update_ibm_node_field(
	char	*ibm_node)
{
	FRM_DBG(("update_ibm_node_field(ibm_node:<%s>)\n", ibm_node));
	FIfld_set_text(si_form, SI_IBM_NODE_FIELD, 0, 0, ibm_node, 0);
}

/******************************************************************************/

static void clear_ibm_node_field()
{
	FRM_DBG(("clear_ibm_node_field()\n"));
	FIfld_set_text(si_form, SI_IBM_NODE_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SI_IBM_PORT_FIELD *****************************************
*******************************************************************************/

static void update_ibm_port_field(
	int	ibm_port)
{
	FRM_DBG(("update_ibm_port_field(ibm_port:%d)\n", ibm_port));
	FIfld_set_value(si_form, SI_IBM_PORT_FIELD, 0, 0, (double)ibm_port, 0);
}

/******************************************************************************/

static void clear_ibm_port_field()
{
	FRM_DBG(("clear_ibm_port_field()\n"));
	FIfld_set_text(si_form, SI_IBM_PORT_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
***************** display_OS400_GROUP *************************************
*******************************************************************************/
static void display_os400_group()
{
	FIg_display(si_form, SI_GROUP_FIELD); /*os400 dictdb & db2 group share*/
	FIg_display(si_form, SI_OS400_DICT_TEXT);
	FIg_display(si_form, SI_IBM_LU62_GROUP);
}
	
/*******************************************************************************
***************** OS400_DICT_FIELD *************************************
*******************************************************************************/

static void update_os400_dict_field(
	char	*dict)
{
	FRM_DBG(("update_os400_dict_field(dict:<%s>)\n", dict));
	FIfld_set_text(si_form, SI_GROUP_FIELD, 0, 0, dict, 0);
}

/*******************************************************************************
***************** OS400_HOST_PROGRAM_FIELD *************************************
*******************************************************************************/

static void update_os400_program_field(
	char	*host_program)
{
	FRM_DBG(("update_os400_program_field(host_program:<%s>)\n", host_program));
	FIfld_set_text(si_form, SI_HOST_PROGRAM_FIELD, 0, 0, host_program, 0);
}

/******************************************************************************/

static void clear_os400_program_field()
{
	FRM_DBG(("clear_os400_program_field()\n"));
	FIfld_set_text(si_form, SI_HOST_PROGRAM_FIELD, 0, 0, "", 0);
}

/******************************************************************************/

static void update_os400_prot_field(
	char	*prot)
{
	FRM_DBG(("update_os400_prot_field(prot:<%s>)\n", prot));
	FIfld_set_text(si_form, SI_IBM_PROT_FIELD, 0, 0, prot, 0);
}

/*******************************************************************************
******************** OS400_RIS_LU_FIELD ***************************************
*******************************************************************************/

static void update_os400_rislu_field(
	char	*ris_lu)
{
	FRM_DBG(("update_os400_rislu_field(ris_lu:<%s>)\n", ris_lu));
	FIfld_set_text(si_form, SI_RIS_LU_FIELD, 0, 0, ris_lu, 0);
}

/******************************************************************************/

static void clear_os400_rislu_field()
{
	FRM_DBG(("clear_os400_rislu_field()\n"));
	FIfld_set_text(si_form, SI_RIS_LU_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** OS400_HOSTLU_FIELD ***************************************
*******************************************************************************/

static void update_os400_hostlu_field(
	char	*host_lu)
{
	FRM_DBG(("update_os400_hostlu_field(host_lu:<%s>)\n", host_lu));
	FIfld_set_text(si_form, SI_HOST_LU_FIELD, 0, 0, host_lu, 0);
}

/******************************************************************************/

static void clear_os400_hostlu_field()
{
	FRM_DBG(("clear_os400_hostlu_field()\n"));
	FIfld_set_text(si_form, SI_HOST_LU_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** OS400_MODE_FIELD ****************************************
*******************************************************************************/

static void update_os400_mode_field(
	char	*mode)
{
	FRM_DBG(("update_os400_mode_field(mode:<%s>)\n", mode));
	FIfld_set_text(si_form, SI_MODE_FIELD, 0, 0, mode, 0);
}

/******************************************************************************/

static void clear_os400_mode_field()
{
	FRM_DBG(("clear_mode_field()\n"));
	FIfld_set_text(si_form, SI_MODE_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** DSQUERY ***************************************************
*******************************************************************************/

static void update_dsquery_field(
	char	*dsquery)
{
	FRM_DBG(("update_dsquery_field(dsquery:<%s>)\n",dsquery));
	FIfld_set_text(si_form, SI_DSQUERY_FIELD, 0, 0, dsquery, 0);
}

/******************************************************************************/

static void clear_dsquery_field()
{
	FRM_DBG(("clear_dsquery_field()\n"));
	FIfld_set_text(si_form, SI_DSQUERY_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** MSSQL DSQUERY *********************************************
*******************************************************************************/

static void update_mssql_dsquery_field(
    char    *mssql_dsquery)
{
    FRM_DBG(("update_mssql_dsquery_field(mssql_dsquery:<%s>)\n",mssql_dsquery));
    FIfld_set_text(si_form, SI_MSSQL_DSQUERY_FIELD, 0, 0, mssql_dsquery, 0);
}

/******************************************************************************/

static void clear_mssql_dsquery_field()
{
    FRM_DBG(("clear_mssql_dsquery_field()\n"));
    FIfld_set_text(si_form, SI_MSSQL_DSQUERY_FIELD, 0, 0, "", 0);
}


/*******************************************************************************
******************** IFILE **************************************************
*******************************************************************************/

static void update_sybifile_field(
	char	*sybifile)
{
	FRM_DBG(("update_sybifile_field(sybifile:<%s>)\n",sybifile));
	FIfld_set_text(si_form, SI_IFILE_FIELD, 0, 0, sybifile, 0);
}

/******************************************************************************/

static void clear_sybifile_field()
{
	FRM_DBG(("clear_sybifile_field()\n"));
	FIfld_set_text(si_form, SI_IFILE_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** MSSQL IFILE ***********************************************
*******************************************************************************/

static void update_mssql_mssqlifile_field(
    char    *mssql_mssqlifile)
{
    FRM_DBG(("update_mssql_mssqlifile_field(mssql_mssqlifile:<%s>)\n",mssql_mssqlifile));
    FIfld_set_text(si_form, SI_MSSQL_IFILE_FIELD, 0, 0, mssql_mssqlifile, 0);
}

/******************************************************************************/

static void clear_mssql_mssqlifile_field()
{
    FRM_DBG(("clear_mssql_mssqlifile_field()\n"));
    FIfld_set_text(si_form, SI_MSSQL_IFILE_FIELD, 0, 0, "", 0);
}


/*******************************************************************************
******************** DB GROUP **************************************************
*******************************************************************************/

static void clear_db_group()
{
	FRM_DBG(("clear_db_group()\n"));

	erase_db_group(ERASE_ALL_GROUPS);

	clear_dbtype_field();
	clear_dbusrname_field();
	clear_dbname_field();
	clear_dbms_location_field();

	/*
	**	INFORMIX
	*/
	clear_sqlexec_field();
	clear_dbtemp_field();
	clear_tbconfig_field();

	/*
	**	ORACLE
	*/

	/*
	**	INGRES
	*/

	/*
	**	DB2
	*/
	clear_group_field();
	clear_ibmprot_group();

	/*
	**	OS400
	*/
	clear_os400_mode_field();
	clear_os400_hostlu_field();
	clear_os400_rislu_field();
	clear_os400_program_field();

	/*
	**	RDB
	*/

	/*
	**	SYBASE
	*/
	clear_dsquery_field();
	clear_sybifile_field();
	/*
	**	MSSQL
	*/
	clear_mssql_dsquery_field();
	clear_mssql_mssqlifile_field();
}

/******************************************************************************/

static void erase_db_group(
	int	dbtype)
{
	int	i;

	FRM_DBG(("erase_db_group(dbtype:%d)\n", dbtype));

        FIg_erase(si_form, SI_OS400_DICT_TEXT);
        FIg_erase(si_form, SI_IBM_PROT_TEXT);

	FIg_erase(si_form, SI_OSUSRNAME_TEXT); 
	FIg_erase(si_form, SI_OSUSRNAME_FIELD); 

	/*
	**	Erase DB INFO GROUP
	*/
	if (dbtype == ERASE_ALL_GROUPS ||
		(VALID_DBTYPE(dbtype) && !db_group[dbtype].db_info_valid))
	{
		FIg_erase(si_form, SI_DB_INFO_GROUP);
	}

	/*
	**	Erase DBMS LOCATION GROUP
	*/
	if (dbtype == ERASE_ALL_GROUPS ||

		(VALID_DBTYPE(dbtype) && !db_group[dbtype].dbms_location_valid))
	{
		FIg_erase(si_form, SI_DBMS_LOCATION_GROUP);
	}


	/*
	**	Erase all dbtype specific groups execpt for dbtype
	*/
	for (i = 0; i < DB_COUNT; i++)
	{
		if (i != dbtype)
		{
			if (db_group[i].label)
			{
				FIg_erase(si_form, db_group[i].label);
			}

			/*
			**	Erase any additional gadgets(groups) not covered by 
			**	db_group[i].label
			*/
			switch(i)
			{
				case INFORMIX_DB:
				case ORACLE_DB:
				case INGRES_DB:
				case DB2_DB:
					erase_ibmprot_group(ERASE_ALL_GROUPS);
					break;
				case RDB_DB:
					break;
				case SYBASE_DB:
				case MSSQL_DB:
					break;
				case OS400_DB:
					break;
			}
		}
	}
}

/******************************************************************************/

static void display_db_group(
	int	dbtype)
{

	FRM_DBG(("display_db_group(dbtype:%d)\n", dbtype));

        if (!db_group[dbtype].osusrname_dbusrname_link)
        {
		FIg_display(si_form, SI_OSUSRNAME_TEXT); 
		FIg_display(si_form, SI_OSUSRNAME_FIELD); 
        }

	if (VALID_DBTYPE(dbtype))
	{
		/*
		**	Display DB INFO GROUP
		*/
		if (db_group[dbtype].db_info_valid)
		{
			FIg_display(si_form, SI_DB_INFO_GROUP);
		}

		/*
		**	Display DBMS LOCATION GROUP
		*/
		if (db_group[dbtype].dbms_location_valid)
		{
			FIg_display(si_form, SI_DBMS_LOCATION_GROUP);
		}

		/*
		**	Display dbtype specific group
		*/
		if (db_group[dbtype].label)
		{
			FIg_display(si_form, db_group[dbtype].label);
		}

		/*
		**	Display any addition not covered by db_group[dbtype].label
		*/
		switch(dbtype)
		{
			case INFORMIX_DB:
			case ORACLE_DB:
			case INGRES_DB:
			case DB2_DB:
			     process_ibmprot_field();
			     break;
			case RDB_DB:
			case SYBASE_DB:
			case MSSQL_DB:
			     break;
			case OS400_DB:
			     FIg_display(si_form, SI_OS400_DICT_TEXT);
			     FIg_display(si_form, SI_IBM_PROT_TEXT);
			     FIg_display(si_form, SI_IBM_PROT_FIELD);
			     display_os400_group();
			     break;
		}

	}
}

/******************************************************************************/

static void update_db_group(
	ris_db_info	*db,
	ris_schema_info *schema)
{
	int			dbtype;

	FRM_DBG(("update_db_group(db:0x%x schema:0x%x)\n", db, schema));

	/*
	**	Update db info in the db group
	*/
	dbtype = RISfrm_get_frmdbtype_from_risdbtype(db->dtype);
	if (db && VALID_DBTYPE(dbtype))
	{
		update_dbtype_field(dbtype);
		update_dbname_field(db->dbname);
		switch(dbtype)
		{
			case INFORMIX_DB:
				update_dbms_location_field(db->info.ifx.dir);
				update_sqlexec_field(db->info.ifx.sqlexec);
				update_dbtemp_field(db->info.ifx.dbtemp);
				update_tbconfig_field(db->info.ifx.tbconfig);
				break;
	
			case ORACLE_DB:
				update_dbms_location_field(db->info.ora.dir);
				break;
	
			case INGRES_DB:
				update_dbms_location_field(db->info.igs.dir);
				break;
	
			case DB2_DB:
				update_group_field(db->info.db2.group);
				update_ibmprot_group(db);
				break;
	
			case RDB_DB:
				break;
	
			case SYBASE_DB:
				update_dbms_location_field(db->info.syb.dir);
				update_dsquery_field(db->info.syb.dsquery);
				update_sybifile_field(db->info.syb.sybifile);
				break;
			case MSSQL_DB:
				update_dbms_location_field(db->info.mssql.dir);
				update_mssql_dsquery_field(db->info.mssql.dsquery);
				update_mssql_mssqlifile_field(db->info.mssql.mssqlifile);
				break;

			case OS400_DB:
				update_os400_prot_field(db->info.os400.net_protocol);
				update_os400_program_field(db->info.os400.host_program);
				update_os400_rislu_field(db->info.os400.ris_lu);
				update_os400_hostlu_field(db->info.os400.host_lu);
				update_os400_mode_field(db->info.os400.mode);
				update_os400_dict_field(db->info.os400.ris_dict_dbname);
FRM_DBG(("db->info.os400.ris_dict_dbname:<%s>\n", db->info.os400.ris_dict_dbname));
				break;

		}
	}
	else
	{
		clear_dbtype_field();
		clear_dbname_field();
		clear_dbms_location_field();

		clear_sqlexec_field();
		clear_dbtemp_field();
		clear_tbconfig_field();

		clear_group_field();
		clear_ibmprot_group();

		clear_dsquery_field();
		clear_sybifile_field();

		clear_mssql_dsquery_field();
		clear_mssql_mssqlifile_field();
	}
	
	/*
	**	Update schema info in the db group
	*/


	if (schema)
	{
		update_dbusrname_field(schema->schowner);
		update_dictowner_field(schema->dictowner);
		update_schtype_field(schema->secure);
	}
	else
	{
		clear_dbusrname_field();
		clear_dictowner_field();
		clear_schtype_field();
	}

}

	
/*******************************************************************************
******************** IBMPROT_GROUP *********************************************
*******************************************************************************/

static void clear_ibmprot_group()
{
	FRM_DBG(("clear_ibmprot_group()\n"));

	erase_ibmprot_group(ERASE_ALL_GROUPS);

	clear_ibmprot_field();

	/*
	**	LU62
	*/
	clear_host_program_field();
	clear_ris_lu_field();
	clear_host_lu_field();
	clear_mode_field();

	/*
	**	TCP
	*/
	clear_ibm_node_field();
	clear_ibm_port_field();
}

/******************************************************************************/

static void erase_ibmprot_group(
	int	ibmprot)
{
	int	i;

	FRM_DBG(("erase_ibmprot_group(ibmprot)\n"));

	/*
	**	Erase all ibmprot specific groups execpt for ibmprot
	*/
	for (i = 0; i < IBM_PROT_COUNT; i++)
	{
		if (i != ibmprot)
		{
			if (ibmprot_group[i].label)
			{
				FIg_erase(si_form, ibmprot_group[i].label);
			}
		}
	}
}

/******************************************************************************/

static void display_ibmprot_group(
	int	ibmprot)
{
	FRM_DBG(("display_ibmprot_group(ibmprot:%d)\n", ibmprot));

	if (VALID_IBMPROT(ibmprot))
	{
		/*
		**	Display ibmprot specific group
		*/
		if (ibmprot_group[ibmprot].label)
		{
			FIg_display(si_form, ibmprot_group[ibmprot].label);
		}
	}
}

/******************************************************************************/

static void update_ibmprot_group(
	ris_db_info	*db)
{
	int			ibmprot;

	FRM_DBG(("RISfrm_update_ibmprot_group(db:0x%x)\n", db));

	/*
	**	Update db info in the db group
	*/
	ibmprot = RISfrm_get_frmibmprot_from_ibmprotname(db->info.db2.net_protocol);

	if (db && VALID_IBMPROT(ibmprot))
	{
		update_ibmprot_field(ibmprot);
		switch(ibmprot)
		{
			case IBM_LU62_PROT:
				update_host_program_field(db->info.db2.host_program);
				update_ris_lu_field(db->info.db2.ris_lu);
				update_host_lu_field(db->info.db2.host_lu);
				update_mode_field(db->info.db2.mode);
				break;

			
			case IBM_TCP_PROT:
				update_ibm_node_field(db->info.db2.node);
				update_ibm_port_field(db->info.db2.port);
				break;
		}
	}
	else
	{
		clear_ibmprot_field();
		clear_host_program_field();
		clear_ris_lu_field();
		clear_host_lu_field();
		clear_mode_field();

		clear_ibm_node_field();
		clear_ibm_port_field();
	}
}

/*******************************************************************************
******************** DS FORM ***************************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));

	RISfrm_erase_si_form();
	if (RISfrm_sd_form_displayed())
	{
		RISfrm_clear_sd_schema_info_button();
	}
}

/*******************************************************************************
******************** DS FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_si_form(
	int g_label)
{
	int	i;

	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,					process_cancel_button			},
		{	SI_SCHNAME_FIELD,			process_schname_field			},
	};
	static	int	process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_si_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(si_form);

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}
}

/******************************************************************************/

extern void RISfrm_process_si_form_initial(
	int g_label)
{
	FRM_DBG(("RISfrm_process_si_form_initial(g_label:%d)\n", g_label));
	switch(g_label)
	{
		case SI_SCHNAME_FIELD:
			RISfrm_get_field(si_form, SI_SCHNAME_FIELD, RIS_MAX_ID_SIZE,
				initial_schname);
			break;
	}
}

/******************************************************************************/

extern void RISfrm_call_user_init_si_form()
{
	FRM_DBG(("RISfrm_call_user_init_si_form()\n"));

	if (RISfrm_user_init_si_form)
	{
		FRM_DBG(("calling RISfrm_user_init_si_form()\n"));
		RISfrm_user_init_si_form(si_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_si_form(
	int	called_by_user)
{
	int	sts;

	FRM_DBG(("RISfrm_display_si_form(called_by_user:%d)\n", called_by_user));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!si_form)
	{
		sts = FIf_new(SI_FORM, SI_FORM_FILE, RISfrm_notification_routine,
			&si_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_SI_FORM, sts);
			return RIS_forms_error.error;
		}

		FIf_set_initial_notification_routine(si_form,
			RISfrm_initial_notification_routine);

#if defined(WIN32)
		FIf_SetDefaultButton(si_form, FI_CANCEL);
		FIg_set_text(si_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));
#endif

		FIfld_set_max_num_chars(si_form, SI_SCHNAME_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
	}

	si_msg->str[0] = 0;
	si_msg->count = 0;
	si_msg->msg_fld_label = SI_MSG_FIELD;
	si_msg->fp = si_form;

	if (!RISfrm_si_form_displayed())
	{
		DISPLAY_HELP_BUTTON(si_form);

		if (called_by_user) RISfrm_call_user_init_si_form();

		sts = FIf_display (si_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_SI_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

static void update_si_form(
	ris_schema_info *schema)
{
	/*
	**	This routine is called internally when ever the schname changes.
	**	It should update every thing on the form that needs updating
	**	except the schname_field()
	*/

	int dbtype;
	ris_db_info	*db;

	FRM_DBG(("update_si_form(schema:0x%x)\n", schema));

	clear_schtype_field();
	clear_dictowner_field();
	clear_protocol_addr();
	clear_ostype_field();
	clear_osusrname_field();
	clear_db_group();

	if (schema)
	{
		if ((db = RISfrm_db_from_schema(schema)) == NULL)
		{
			return;
		}

		dbtype = RISfrm_get_frmdbtype_from_risdbtype(db->dtype);
	FRM_DBG(("update_si_form() dbtype = %d\n", dbtype));

		if (!VALID_DBTYPE(dbtype))
		{
			return;
		}

		update_schname_field(schema->schname);
		update_protocol_addr(db);
		update_ostype_field(RISfrm_get_ostype_name(db->ostype));
		switch(dbtype)
		{
			case ORACLE_DB:
				update_osusrname_field(db->info.ora.osuser);
				break;

			case DB2_DB:
				update_osusrname_field(db->info.db2.osuser);
				break;

			case SYBASE_DB:
				update_osusrname_field(db->info.syb.osuser);
				break;
			case MSSQL_DB:
				update_osusrname_field(db->info.mssql.osuser);
				break;

			case INFORMIX_DB:
			case INGRES_DB:
			case RDB_DB:
				update_osusrname_field(schema->schowner);
				break;
			case OS400_DB:
				update_osusrname_field(db->info.os400.osuser);
				break;
				
		}
		update_db_group(db, schema);
	}
}

/******************************************************************************/

extern void RISfrm_update_si_form(
	ris_schema_info *schema)
{
	/*
	**	This routine is called by other forms to update this form.  It should
	**	update the schname field, then call the internal update function.
	*/

	FRM_DBG(("RISfrm_update_si_form(schema:0x%x)\n", schema));

	VALID_FORM_CHECK(si_form);

	if (schema)
	{
		update_schname_field(schema->schname);
	}
	else
	{
		clear_schname_field();
	}

	update_si_form(schema);
}

/******************************************************************************/

extern void RISfrm_clear_si_form()
{
	FRM_DBG(("RISfrm_clear_si_form()\n"));

	VALID_FORM_CHECK(si_form);

	clear_schname_field();
	clear_schtype_field();
	clear_dictowner_field();
	clear_protocol_addr();
	clear_ostype_field();
	clear_osusrname_field();
	clear_db_group();
}

/******************************************************************************/

extern int RISfrm_si_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_si_form_displayed()\n"));

	if (!si_form)
	{
		return(0);
	}
	FIf_is_displayed(si_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_si_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_si_form()\n"));

	if (RISfrm_si_form_displayed())
	{
		RISfrm_clear_si_form();
		sts = FIf_erase(si_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_SI_FORM, sts);
			return RIS_forms_error.error;
		}
		if (RISfrm_sd_form_displayed())
		{
			RISfrm_clear_sd_schema_info_button();
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER CALLABLE FUNCTIONS *****************************************
*******************************************************************************/

extern int RISAPI RISXfrm_schema_info_form_displayed()
{
	return RISfrm_si_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_schema_info_form()
{
	return RISfrm_display_si_form(CALLED_BY_USER);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_schema_info_form()
{
	return RISfrm_erase_si_form();
}

/*****************************************************************************/
