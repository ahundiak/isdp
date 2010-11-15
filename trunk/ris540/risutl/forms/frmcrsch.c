/* Do not alter this SPC information: $Revision: 1.8.3.1 $ */
/*
**	NAME:									frmcrsch.c
**	AUTHORS:								Terry McIntyre
**	CREATION DATE:							11/90
**	ABSTRACT:
**	
**		The code to process the create schema form.
**	
**	REVISION HISTORY:
**		Modified for secure schema  and OS400 by linda wang     11/93
**		10/24/94 -Radha
**			Added changes for MSSQL data server
**
**		11/94:	Added support for INTERNATIONALIZATION.  Linda Wang
** 	02/03/95 Removed NTJ specific changes. rlk
**	04/19/96 added fix for TR 439502302 - Ashley
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "forms.h"
#include "net.h"
#include "ris_err.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmcrsch_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "fi.prt"
#include "frmschdf.prt"
#include "frmcrsch.prt"
#include "frmdbs.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmfile.prt"
#include "frmntfy.prt"
#include "frmschmg.prt"
#include "frmutil.prt"
#include "sys.prt"
#include "ris.prt"
#if defined (WIN32)
#include "fi_winnt.prt"
#endif

/*
**	DEFINES
*/
#define ERASE_ALL_GROUPS	-1

#if defined(unix)
#define FORCE_BUTTON CS_FORCE_BUTTON
#endif
#if defined(WIN32)
#define FORCE_BUTTON FI_FORM_OK
#endif

/*
**	VARIABLES
*/
static struct
{
	int protocol;
	int address;
} protocol_label[RIS_MAX_PROTOCOLS] =
{
	{	CS_PROTOCOL_ROLLTHRU_1,	CS_ADDRESS_FIELD_1 },
	{	CS_PROTOCOL_ROLLTHRU_2,	CS_ADDRESS_FIELD_2 },
	{	CS_PROTOCOL_ROLLTHRU_3,	CS_ADDRESS_FIELD_3 },
	{	CS_PROTOCOL_ROLLTHRU_4,	CS_ADDRESS_FIELD_4 },
};

static struct
{
	int label;
	int db_info_valid;
	int	dbms_location_valid;
	int osusrname_dbusrname_link;
	char *name;
} db_group[DB_COUNT] =
{
	{	CS_IFX_GROUP,	1,	1,	1,	INFORMIX_NAME	},
	{	CS_ORA_GROUP,	1,	1,	0,	ORACLE_NAME		},
	{	CS_IGS_GROUP,	1,	1,	1,	INGRES_NAME		},
	{	CS_DB2_GROUP,	1,	0,	0,	DB2_NAME		},
	{	CS_RDB_GROUP,	1,	0,	1,	RDB_NAME		},
	{	CS_SYB_GROUP,	1,	1,	0,	SYBASE_NAME		},
	{	CS_OS400_GROUP,	1,	0,	0,	OS400_NAME		},
	{	CS_MSSQL_GROUP,	1,	1,	0,	MSSQL_NAME		},
};

static struct
{
	int label;
	char *name;
} ibmprot_group[IBM_PROT_COUNT] =
{
	{	CS_IBM_LU62_GROUP,	IBM_LU62_NAME	},
	{	CS_IBM_TCP_GROUP,	IBM_TCP_NAME	},
};

char	*valid_ostype[] =
{
	UNIX_NAME,
	VMS_NAME,
	NT_NAME
};
int	valid_ostype_count = (sizeof(valid_ostype)/sizeof(char *));

static  Form			cs_form;
static	int	dbtype;
static RISfrm_msg	*cs_msg = &RISfrm_msgs[CS_FORM_MSG];
static  char			initial_schname[RIS_MAX_ID_SIZE] = "";
/*
**	FUNCTIONS
*/

/*******************************************************************************
************** CS_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(cs_form, CS_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(cs_form, CS_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** DISPLAY DATABASES *****************************************
*******************************************************************************/

static void process_display_dbs_button()
{
	int	state;

	FRM_DBG(("process_display_dbs_button()\n"));

	FIg_get_state(cs_form, CS_DISPLAY_DBS_BUTTON, &state);

	if (state)
	{
		if (RISfrm_display_rd_form() != RIS_SUCCESS)
		{
			RISfrm_report_error();
			RISfrm_clear_cs_display_dbs_button();
			return;
		}
	}
	else
	{
		RISfrm_erase_rd_form();
	}
}

/******************************************************************************/

extern void RISfrm_clear_cs_display_dbs_button()
{
	FRM_DBG(("RISfrm_clear_cs_display_dbs_button()\n"));
	FIg_set_state(cs_form, CS_DISPLAY_DBS_BUTTON, 0);
}

/*******************************************************************************
******************** PROTOCOL ADDR *********************************************
*******************************************************************************/

static void get_protocol_addr(
	int		row,
	char	*prot,
	char	*addr)
{
	FRM_DBG(("get_protocol_addr(row:%d, prot:0x%x, addr:0x%x)\n",
		row, prot, addr));

	RISfrm_get_field(cs_form, protocol_label[row].protocol, FRM_MAX_PROT_SIZE,
		prot);

	RISfrm_get_field(cs_form, protocol_label[row].address, RIS_MAX_NODE_SIZE,
		addr);
}

/******************************************************************************/

static void put_protocol_addr(
	int		row,
	char	*prot,
	char	*addr)
{
	int	prot_label;

	FRM_DBG(("put_protocol_addr(row:%d, prot:<%s>, addr:<%s>)\n",
		row, prot, addr));

	prot_label = protocol_label[row].protocol;
	FIfld_set_num_rows(cs_form, prot_label, 1);
	FIfld_set_text(cs_form, prot_label, 0, 0, prot, 0);
	FIfld_set_active_row(cs_form, prot_label, 0, 0);

	FIfld_set_text(cs_form, protocol_label[row].address, 0, 0, addr, 0);
}

/******************************************************************************/

static void init_protocol_addr()
{
	int	i;

	FRM_DBG(("init_protocol_addr()\n"));

	for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
		put_protocol_addr(i, RISfrm_get_prot_name(i), "");
}

/******************************************************************************/

static void update_protocol_addr(
	ris_db_info *db)
{
	int		i;
	int		p;
	int		prot_count = 0;
	char	prot_used[RIS_MAX_PROTOCOLS];
	char	prot[RIS_MAX_PROTOCOLS][FRM_MAX_PROT_SIZE];
	char	addr[RIS_MAX_PROTOCOLS][RIS_MAX_NODE_SIZE];

	FRM_DBG(("update_protocol_addr(db:0x%x)\n", db));

	if (!db)
	{
		init_protocol_addr();
		return;
	}

	memset(prot_used, 0, sizeof(prot_used));
	memset(prot, 0, sizeof(prot));
	memset(addr, 0, sizeof(addr));

	for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
	{
		if (db->pathways[i].protocol)
		{
			if ((p = RISfrm_get_form_prot(db->pathways[i].protocol))== -1)
			{
				FRM_DBG(("update_protocol_addr(): Error unknown protocol:%d\n",
					db->pathways[i].protocol));
				init_protocol_addr();
				return;
			}

			prot_used[p] = 1;
			strcpy(prot[prot_count], RISfrm_get_prot_name(p));
			strcpy(addr[prot_count], db->pathways[i].netaddr);
			prot_count++;
		}
	}

	for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
	{
		if (!prot_used[i])
		{
			strcpy(prot[prot_count], RISfrm_get_prot_name(i));
			strcpy(addr[prot_count], "");
			prot_count++;
		}
	}

	for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
		put_protocol_addr(i, prot[i], addr[i]);
}

/******************************************************************************/

static void process_protocol_addr(
	int	row)
{
	int		save_row;
	char	save_prot[FRM_MAX_PROT_SIZE];
	char	save_addr[RIS_MAX_NODE_SIZE];
	char	next_prot[FRM_MAX_PROT_SIZE];
	char	next_addr[RIS_MAX_NODE_SIZE];

	FRM_DBG(("process_protocol_addr(row:%d)\n", row));

	save_row = row;
	get_protocol_addr(row, save_prot, save_addr);
	
	for (; row < RIS_MAX_PROTOCOLS - 1; row++)
	{
		get_protocol_addr(row + 1, next_prot, next_addr);
		put_protocol_addr(row, next_prot, next_addr);
	}

	if (row != save_row)
		put_protocol_addr(row, save_prot, save_addr);
}

/******************************************************************************/

static void clear_protocol_addr()
{
	FRM_DBG(("clear_protocol_addr()\n"));
	init_protocol_addr();
}

/******************************************************************************/

static void process_protocol_rollthru_1()
{
	process_protocol_addr(0);
}

/******************************************************************************/

static void process_protocol_rollthru_2()
{
	process_protocol_addr(1);
}

/******************************************************************************/

static void process_protocol_rollthru_3()
{
	process_protocol_addr(2);
}

/******************************************************************************/

static void process_protocol_rollthru_4()
{
	process_protocol_addr(3);
}

/******************************************************************************/

static void process_address_field(
	int row)
{
	char prot[FRM_MAX_PROT_SIZE];
	char addr[RIS_MAX_NODE_SIZE];

	get_protocol_addr(row, prot, addr);
	if (addr[0] && !strcmp(prot, RISfrm_get_prot_name(ISO_PROT)))
	{
		cs_msg->label[cs_msg->count++] = protocol_label[row].protocol;
		cs_msg->label[cs_msg->count++] = protocol_label[row].address;
		strcpy(cs_msg->str, MSG(RISUTL_I_ISO_NOT_AVAILABLE));
		FIfld_set_text(cs_form, protocol_label[row].address, 0, 0, "", 0);
	}
}

/******************************************************************************/

static void process_address_field_1()
{
	process_address_field(0);
}

/******************************************************************************/

static void process_address_field_2()
{
	process_address_field(1);
}

/******************************************************************************/

static void process_address_field_3()
{
	process_address_field(2);
}

/******************************************************************************/

static void process_address_field_4()
{
	process_address_field(3);
}

/*******************************************************************************
******************** CS_LOCAL_MACHINE_BUTTON ***********************************
*******************************************************************************/

static void process_local_machine_button()
{
	int		i;
	int		p;
	int		prot_count = 0;
	char	prot_used[RIS_MAX_PROTOCOLS];
	char	prot[RIS_MAX_PROTOCOLS][FRM_MAX_PROT_SIZE];
	char	addr[RIS_MAX_PROTOCOLS][RIS_MAX_NODE_SIZE];
	char	formprot[FRM_MAX_PROT_SIZE];
	char	formaddr[RIS_MAX_NODE_SIZE];
	char	client_xns_addr[RIS_MAX_NODE_SIZE] = "";
	char	client_tcp_addr[RIS_MAX_NODE_SIZE] = "";
	char	client_dnp_addr[RIS_MAX_NODE_SIZE] = "";
	char	client_lu62_addr[RIS_MAX_NODE_SIZE]	= "";


	RISint_get_client_addresses(client_xns_addr, client_tcp_addr,
			client_lu62_addr, client_dnp_addr);

	memset(prot_used, 0, sizeof(prot_used));
	memset(prot, 0, sizeof(prot));
	memset(addr, 0, sizeof(addr));

	for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
	{
		get_protocol_addr(i, formprot, formaddr);
		p = RISfrm_get_form_prot_by_name(formprot);
		switch(p)
		{
			case XNS_PROT:
				if (!*client_xns_addr) continue;
				strcpy(addr[prot_count], client_xns_addr);
				break;

			case TCP_PROT:
				if (!*client_tcp_addr) continue;
				strcpy(addr[prot_count], client_tcp_addr);
				break;

			case DNP_PROT:
				if (!*client_dnp_addr) continue;
				strcpy(addr[prot_count], client_dnp_addr);
				break;

			case ISO_PROT:
				continue;
		}
		strcpy(prot[prot_count], formprot);
		prot_used[p] = 1;
		prot_count++;
	}

	for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
	{
		if (!prot_used[i])
		{
			strcpy(prot[prot_count], RISfrm_get_prot_name(i));
			strcpy(addr[prot_count], "");
			prot_count++;
		}
	}

	for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
		put_protocol_addr(i, prot[i], addr[i]);

	FIg_set_state(cs_form, CS_LOCAL_MACHINE_BUTTON, 0);
	FIfld_pos_cursor(cs_form, CS_ADDRESS_FIELD_1, 0,0,0,0,0,0);
}

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

static void update_os400_group(
	ris_db_info *db)
{
	update_os400_dict_field(db->info.os400.ris_dict_dbname);
	update_os400_rislu_field(db->info.os400.ris_lu);
	update_os400_hostlu_field(db->info.os400.host_lu);
	update_os400_mode_field(db->info.os400.mode);
	update_os400_program_field(db->info.os400.host_program);
}
/***********************************************************************
******************** CS_OS400_DBNAME_FIELD *****************************
***********************************************************************/

static char *get_os400_dbname_field()
{
	static	 char	os400_dbname[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_os400_dbname_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_OS400_DBNAME_FIELD))

	{
		RISfrm_get_field(cs_form, CS_OS400_DBNAME_FIELD,
                                 RIS_MAX_PATH_SIZE,os400_dbname);
		if (os400_dbname[0]) return(os400_dbname);
	}
	return(NULL);
}

/******************************************************************************/

static void process_os400_dbname_field()
{
	char *dbname;

	FRM_DBG(("process_os400_dbname_field()\n"));
	if ((dbname = get_os400_dbname_field()) != NULL)
	{
		update_os400_dict_field(dbname);
	}

}

/******************************************************************************/

static void update_os400_dbname_field(
	char	*os400_dbname)
{
	FRM_DBG(("udpate_os400_dbname_field(os400_dbname:<%s>)\n", 
                                           os400_dbname));
	FIfld_set_text(cs_form, CS_OS400_DBNAME_FIELD, 0, 0,
                       os400_dbname, 0);
}

/******************************************************************************/

static void clear_os400_dbname_field()
{
	FRM_DBG(("clear_os400_dbname_field()\n"));
	update_os400_dbname_field("");
}

/***********************************************************************
******************** CS_OS400_DICT_FIELD *******************************
***********************************************************************/

static char *get_os400_dict_field()
{
	static	 char	os400_dict[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_os400_dict_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_OS400_DICT_FIELD))

	{
		RISfrm_get_field(cs_form, CS_OS400_DICT_FIELD,
                                 RIS_MAX_PATH_SIZE,os400_dict);
		if (os400_dict[0]) return(os400_dict);
	}
	return(NULL);
}

/******************************************************************************/

static void update_os400_dict_field(
	char	*os400_dict)
{
	FRM_DBG(("udpate_os400_dict_field(os400_dict:<%s>)\n", 
                                           os400_dict));
	FIfld_set_text(cs_form, CS_OS400_DICT_FIELD, 0, 0,
                       os400_dict, 0);
}

/******************************************************************************/

static void clear_os400_dict_field()
{
	FRM_DBG(("clear_os400_dict_field()\n"));
	update_os400_dict_field("");
}

/***********************************************************************
******************** CS_OS400_RISLU_FIELD ******************************
***********************************************************************/

static char *get_os400_rislu_field()
{
	static	 char	os400_rislu[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_os400_rislu_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_OS400_RISLU_FIELD))

	{
		RISfrm_get_field(cs_form, CS_OS400_RISLU_FIELD,
                                 RIS_MAX_PATH_SIZE,os400_rislu);
		if (os400_rislu[0]) return(os400_rislu);
	}
	return(NULL);
}

/******************************************************************************/

static void update_os400_rislu_field(
	char	*os400_rislu)
{
	FRM_DBG(("udpate_os400_rislu_field(os400_rislu:<%s>)\n", 
                                           os400_rislu));
	FIfld_set_text(cs_form, CS_OS400_RISLU_FIELD, 0, 0,
                       os400_rislu, 0);
}

/******************************************************************************/

static void clear_os400_rislu_field()
{
	FRM_DBG(("clear_os400_rislu_field()\n"));
	update_os400_rislu_field("");
}

/***********************************************************************
******************** CS_OS400_HOSTLU_FIELD *****************************
***********************************************************************/

static char *get_os400_hostlu_field()
{
	static	 char	os400_hostlu[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_os400_hostlu_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_OS400_HOSTLU_FIELD))

	{
		RISfrm_get_field(cs_form, CS_OS400_HOSTLU_FIELD,
                                 RIS_MAX_PATH_SIZE,os400_hostlu);
		if (os400_hostlu[0]) return(os400_hostlu);
	}
	return(NULL);
}

/******************************************************************************/

static void update_os400_hostlu_field(
	char	*os400_hostlu)
{
	FRM_DBG(("udpate_os400_hostlu_field(os400_hostlu:<%s>)\n", 
                                           os400_hostlu));
	FIfld_set_text(cs_form, CS_OS400_HOSTLU_FIELD, 0, 0,
                       os400_hostlu, 0);
}

/******************************************************************************/

static void clear_os400_hostlu_field()
{
	FRM_DBG(("clear_os400_hostlu_field()\n"));
	update_os400_hostlu_field("");
}

/***********************************************************************
******************** CS_OS400_MODE_FIELD *******************************
***********************************************************************/

static char *get_os400_mode_field()
{
	static	 char	os400_mode[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_os400_mode_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_OS400_MODE_FIELD))

	{
		RISfrm_get_field(cs_form, CS_OS400_MODE_FIELD,
                                 RIS_MAX_PATH_SIZE,os400_mode);
		if (os400_mode[0]) return(os400_mode);
	}
	return(NULL);
}

/******************************************************************************/

static void update_os400_mode_field(
	char	*os400_mode)
{
	FRM_DBG(("udpate_os400_mode_field(os400_mode:<%s>)\n", 
                                           os400_mode));
	FIfld_set_text(cs_form, CS_OS400_MODE_FIELD, 0, 0,
                       os400_mode, 0);
}

/******************************************************************************/

static void clear_os400_mode_field()
{
	FRM_DBG(("clear_os400_mode_field()\n"));
	update_os400_mode_field("");
}

/***********************************************************************
******************** CS_OS400_PROGRAM_FIELD *******************************
***********************************************************************/

static char *get_os400_program_field()
{
	static	 char	os400_program[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_os400_program_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_OS400_PROGRAM_FIELD))

	{
		RISfrm_get_field(cs_form, CS_OS400_PROGRAM_FIELD,
                                 RIS_MAX_PATH_SIZE,os400_program);
		if (os400_program[0]) return(os400_program);
	}
	return(NULL);
}

/******************************************************************************/

static void update_os400_program_field(
	char	*os400_program)
{
	FRM_DBG(("udpate_os400_program_field(os400_program:<%s>)\n", 
                                           os400_program));
	FIfld_set_text(cs_form, CS_OS400_PROGRAM_FIELD, 0, 0,
                       os400_program, 0);
}

/******************************************************************************/

static void clear_os400_program_field()
{
	FRM_DBG(("clear_os400_program_field()\n"));
	update_os400_program_field("");
}

/***********************************************************************
******************** CS_OS400_PROT_FIELD *******************************
***********************************************************************/

static char *get_os400_prot_field()
{
	static	 char	os400_prot[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_os400_prot_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_OS400_PROT_FIELD))

	{
		RISfrm_get_field(cs_form, CS_OS400_PROT_FIELD,
                                 RIS_MAX_PATH_SIZE,os400_prot);
		if (os400_prot[0]) return(os400_prot);
	}
	return(NULL);
}

/******************************************************************************/
/*******************************************************************************
******************** CS_DBNAME_FIELD *****************************************
*******************************************************************************/

static char *get_dbname_field()
{
	static	 char	dbname[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_dbname_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_DBNAME_FIELD))

	{
		RISfrm_get_field(cs_form, CS_DBNAME_FIELD, RIS_MAX_PATH_SIZE, dbname);
		if (dbname[0]) return(dbname);
	}
	return(NULL);
}

/***********************************************************************/
static void process_dbname_field()
{
	char *ostype;

		
	ostype = get_ostype_field();
	
	if (dbtype == DB2_DB )
	{
	      FIfld_pos_cursor(cs_form, CS_GROUP_FIELD, 0,0,0,0,0,0);
	}
/*
	else if (((dbtype == SYBASE_DB) || (dbtype == MSSQL_DB)) 
				&& (strcmp(ostype, NT_NAME) == 0))
        {
              FIfld_pos_cursor(cs_form, CS_OSUSRNAME_FIELD, 0,0,0,0,0,0);
	}
*/
}

/******************************************************************************/

static void update_dbname_field(
	char	*dbname)
{
	FRM_DBG(("udpate_dbname_field(dbname:<%s>)\n", dbname));
	FIfld_set_text(cs_form, CS_DBNAME_FIELD, 0, 0, dbname, 0);
}

/******************************************************************************/

static void clear_dbname_field()
{
	FRM_DBG(("clear_dbname_field()\n"));
	update_dbname_field("");
}

/*******************************************************************************
******************** CS_DBMS_LOCATION_FIELD ************************************
*******************************************************************************/

static char *get_dbms_location_field()
{
	static	 char	dbms_location[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_dbms_location_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_DBMS_LOCATION_FIELD))
	{
		RISfrm_get_field(cs_form, CS_DBMS_LOCATION_FIELD, RIS_MAX_PATH_SIZE,
			dbms_location);
		if (dbms_location[0]) return(dbms_location);
	}
	return(0);
}

/***********************************************************************/
static void process_dbms_location_field()
{
	if (dbtype == INFORMIX_DB )
	{
	      FRM_DBG(("I am in informix\n"));
	      FIfld_pos_cursor(cs_form, CS_SQLEXEC_FIELD, 0,0,0,0,0,0);
	}
}

/******************************************************************************/

static void update_dbms_location_field(
	char	*dbms_location)
{
	FRM_DBG(("udpate_dbms_location_field(dbms_location:<%s>)\n",dbms_location));
	FIfld_set_text(cs_form, CS_DBMS_LOCATION_FIELD, 0, 0, dbms_location, 0);
}

/******************************************************************************/

static void clear_dbms_location_field()
{
	FRM_DBG(("clear_dbms_location_field()\n"));
	update_dbms_location_field("");
}

/*******************************************************************************
******************** CS_SQLEXEC_FIELD *****************************************
*******************************************************************************/

static char *get_sqlexec_field()
{
	static	 char	sqlexec[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_sqlexec_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_SQLEXEC_FIELD))
	{
		RISfrm_get_field(cs_form, CS_SQLEXEC_FIELD, RIS_MAX_PATH_SIZE,
			sqlexec);
		if (sqlexec[0]) return(sqlexec);
	}
	return(NULL);
}

/******************************************************************************/

static void update_sqlexec_field(
	char	*sqlexec)
{
	FRM_DBG(("update_sqlexec_field(sqlexec:<%s>)\n", sqlexec));
	FIfld_set_text(cs_form, CS_SQLEXEC_FIELD, 0, 0, sqlexec, 0);
}

/******************************************************************************/

static void clear_sqlexec_field()
{
	FRM_DBG(("clear_sqlexec_field()\n"));
	update_sqlexec_field("");
}

/*******************************************************************************
******************** CS_DBTEMP_FIELD ******************************************
*******************************************************************************/

static char *get_dbtemp_field()
{
	static	 char	dbtemp[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_dbtemp_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_DBTEMP_FIELD))
	{
		RISfrm_get_field(cs_form, CS_DBTEMP_FIELD, RIS_MAX_PATH_SIZE, dbtemp);
		if (dbtemp[0]) return(dbtemp);
	}
	return(NULL);
}

/******************************************************************************/

static void update_dbtemp_field(
	char	*dbtemp)
{
	FRM_DBG(("update_dbtemp_field(dbtemp:<%s>)\n", dbtemp));
	FIfld_set_text(cs_form, CS_DBTEMP_FIELD, 0, 0, dbtemp, 0);
}

/******************************************************************************/

static void clear_dbtemp_field()
{
	FRM_DBG(("clear_dbtemp_field()\n"));
	update_dbtemp_field("");
}

/*******************************************************************************
******************** CS_TBCONFIG_FIELD *****************************************
*******************************************************************************/

static char *get_tbconfig_field()
{
	static	 char	tbcnfg[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_tbconfig_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_TBCONFIG_FIELD))
	{
		RISfrm_get_field(cs_form, CS_TBCONFIG_FIELD, RIS_MAX_PATH_SIZE, tbcnfg);
		if (tbcnfg[0]) return(tbcnfg);
	}
	return(NULL);
}

/******************************************************************************/

static void update_tbconfig_field(
	char	*tbconfig)
{
	FRM_DBG(("update_tbconfig_field(tbconfig:<%s>)\n", tbconfig));
	FIfld_set_text(cs_form, CS_TBCONFIG_FIELD, 0, 0, tbconfig, 0);
}

/******************************************************************************/

static void clear_tbconfig_field()
{
	FRM_DBG(("clear_tbconfig_field()\n"));
	update_tbconfig_field("");
}

/*******************************************************************************
******************** CS_OSUSRNAME_FIELD ****************************************
*******************************************************************************/

static char *get_osusrname_field()
{
	static	 char	osusrname[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_osusrname_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_OSUSRNAME_FIELD))
	{
		RISfrm_get_field(cs_form, CS_OSUSRNAME_FIELD, RIS_MAX_ID_SIZE,
			osusrname);
		if (osusrname[0]) return(osusrname);
	}
	return(NULL);
}

/******************************************************************************/
static void process_osusrpass_field()
{
	if (dbtype == SYBASE_DB)
	{
	      FIfld_pos_cursor(cs_form, CS_DSQUERY_FIELD, 0,0,0,0,0,0);
	}
/*********
	if (dbtype == MSSQL_DB)
	{
	      FIfld_pos_cursor(cs_form, CS_MSSQL_DSQUERY_FIELD, 0,0,0,0,0,0);
	}
***********/
}


/******************************************************************************/
static void update_osusrname_field(
	char	*osusrname)
{
	FRM_DBG(("udpate_osusrname_field(osusrname:<%s>)\n",osusrname));
	FIfld_set_text(cs_form, CS_OSUSRNAME_FIELD, 0, 0, osusrname, 0);
}

/******************************************************************************/

static void clear_osusrname_field()
{
	FRM_DBG(("clear_osusrname_field()\n"));

	FIg_erase(cs_form, CS_OS_USER_GROUP);
	update_osusrname_field("");
}

/*******************************************************************************
******************** CS_OSUSRPASS_FIELD ****************************************
*******************************************************************************/

static char *get_osusrpass_field()
{
	static	 char	osusrpass[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_osusrpass_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_OSUSRPASS_FIELD))
	{
		RISfrm_get_field(cs_form, CS_OSUSRPASS_FIELD, RIS_MAX_ID_SIZE,
			osusrpass);
		if (osusrpass[0]) return(osusrpass);
	}
	return(NULL);
}

/******************************************************************************/

/*
static void update_osusrpass_field(
	char	*osusrpass)
{
	FRM_DBG(("udpate_osusrpass_field()\n"));
	FIfld_set_text(cs_form, CS_OSUSRPASS_FIELD, 0, 0, osusrpass, 0);
}

*/
/******************************************************************************/

static void clear_osusrpass_field()
{
	FRM_DBG(("clear_osusrpass_field()\n"));
	FIfld_set_text(cs_form, CS_OSUSRPASS_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CS_OSUSRPASS_TOGGLE ***************************************
*******************************************************************************/

static void process_osusrpass_toggle()
{
	FRM_DBG(("process_osusrpass_toggle()\n"));
	RISfrm_set_passwd_echo(cs_form,CS_OSUSRPASS_TOGGLE,CS_OSUSRPASS_FIELD);
}


/***********************************************************************
******************** CS_USEDICTIONARY_TOGGLE ***************************
*******************************************************************************/

static void process_usedictionary_toggle()
{
	int  usedictionary;
	char *dictowner; 

	FRM_DBG(("process_usedictionary_toggle()\n"));
	FIg_get_state(cs_form,CS_USEDICTIONARY_TOGGLE, &usedictionary);
	if (usedictionary == 0)
	{
		FIg_disable(cs_form, CS_DICTOWNER_FIELD); 
		FIfld_set_text(cs_form, CS_DICTOWNER_FIELD, 0,0, "", 0);
	}
	else
	{
		FIg_enable(cs_form, CS_DICTOWNER_FIELD); 
		if ((dictowner = get_dbusrname_field()) == NULL)
		{
			dictowner = "";
                }
		FIfld_set_text(cs_form, CS_DICTOWNER_FIELD, 0,0, dictowner, 0);
	}
}

/*******************************************************************************
******************** CS_OSTYPE_FIELD *******************************************
*******************************************************************************/

static char *get_ostype_field()
{
	static	 char	ostype[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_os_name_field()\n"));

	RISfrm_get_field(cs_form, CS_OSTYPE_FIELD, RIS_MAX_ID_SIZE, ostype);
	if (ostype[0]) return(ostype);

	return(NULL);
}

/******************************************************************************/

static void process_ostype_field()
{
	char *ostype;
	char *dbtypename;

	FRM_DBG(("process_ostype_field()\n"));

	if ((ostype = get_ostype_field()) == NULL)
	{
		clear_dbtype_field();
		FIg_erase(cs_form, CS_DBMS_LOCATION_GROUP);
		FIg_erase(cs_form, CS_DB_INFO_GROUP);
		cs_msg->label[cs_msg->count++] = CS_OSTYPE_TEXT;
		cs_msg->label[cs_msg->count++] = CS_OSTYPE_FIELD;
		strcpy(cs_msg->str, MSG(RISUTL_I_OSTYPE_MUST_BE_SPEC));
		return;
	}
	dbtypename = get_dbtype_field();
	if (dbtypename != NULL)
	{
		dbtype = RISfrm_get_frmdbtype_from_dbtypename(dbtypename);

/*
		if (dbtype == SYBASE_DB)
		{
			if (strcmp(ostype, NT_NAME) == 0)  
			{
				FIg_disable(cs_form, CS_DBMS_LOCATION_GROUP);
				FIg_disable(cs_form, CS_IFILE_TEXT);
				FIg_disable(cs_form, CS_IFILE_FIELD);
			}
			else
			{
				FIg_enable(cs_form, CS_DBMS_LOCATION_GROUP);
				FIg_enable(cs_form, CS_IFILE_TEXT);
				FIg_enable(cs_form, CS_IFILE_FIELD);
			}
		}
        if (dbtype == MSSQL_DB)
        {
            if (strcmp(ostype, NT_NAME) == 0)
            {
                FIg_disable(cs_form, CS_DBMS_LOCATION_GROUP);
                FIg_disable(cs_form, CS_MSSQL_IFILE_TEXT);
                FIg_disable(cs_form, CS_MSSQL_IFILE_FIELD);
            }
            else
            {
                FIg_enable(cs_form, CS_DBMS_LOCATION_GROUP);
                FIg_enable(cs_form, CS_MSSQL_IFILE_TEXT);
                FIg_enable(cs_form, CS_MSSQL_IFILE_FIELD);
            }
        }

*/
		if ((strcmp(ostype, VMS_NAME) == 0) &&
		    ((dbtype == INFORMIX_DB) ||
		     (dbtype == DB2_DB) ||
		     (dbtype == OS400_DB) ||  
		     (dbtype == MSSQL_DB) ||
		     (dbtype == SYBASE_DB)))	
		{
			erase_db_group(ERASE_ALL_GROUPS);
			cs_msg->label[cs_msg->count++] = CS_DBTYPE_FIELD;
			cs_msg->label[cs_msg->count++] = CS_OSTYPE_FIELD;
			sprintf(cs_msg->str, MSG(RISUTL_I_UNSUPPORT_DBTYPE_ON_VMS), dbtypename);
			return;
		}
		else
	        if ((strcmp(ostype, UNIX_NAME) == 0) &&
                  (dbtype == MSSQL_DB))
                {
                    erase_db_group(ERASE_ALL_GROUPS);
                    cs_msg->label[cs_msg->count++] = CS_DBTYPE_FIELD;
                    cs_msg->label[cs_msg->count++] = CS_OSTYPE_FIELD;
                    sprintf(cs_msg->str, MSG(RISUTL_I_UNSUPPORT_DBTYPE_ON_UNIX), dbtypename);
                    return;
                }
		else
		{
	            erase_db_group(dbtype);
	            display_db_group(dbtype);
	            FIg_display(cs_form, CS_DBTYPE_FIELD);
	      	}
	}

}

/******************************************************************************/
static void init_ostype_field()
{
	int i;

	FRM_DBG(("init_ostype_field()\n"));

	FIfld_set_list_num_rows(cs_form, CS_OSTYPE_FIELD, 0, valid_ostype_count);

	for (i = 0; i < valid_ostype_count; i++)
	{
		FIfld_set_list_default_text(cs_form, CS_OSTYPE_FIELD, i, 0,
			valid_ostype[i], 0);
	}

	FRM_DBG(("init_ostype_field:returning\n"));
}

/******************************************************************************/

static void update_ostype_field(
	char	*ostype)
{
	FRM_DBG(("update_ostype_field(ostype:<%s>)\n", ostype));
	FIfld_set_text(cs_form, CS_OSTYPE_FIELD, 0, 0, ostype, 0);
}

/******************************************************************************/

static void clear_ostype_field()
{
	FRM_DBG(("clear_ostype_field()\n"));
	FIfld_set_text(cs_form, CS_OSTYPE_FIELD, 0, 0, "", 0);
}

/******************************************************************************/

static void update_host_program_field(
	char	*host_program)
{
	FRM_DBG(("update_host_program_field(host_program:<%s>)\n", host_program));
	FIfld_set_text(cs_form, CS_HOST_PROGRAM_FIELD, 0, 0, host_program, 0);
}

/******************************************************************************/

static void clear_host_program_field()
{
	FRM_DBG(("clear_host_program_field()\n"));
	FIfld_set_text(cs_form, CS_HOST_PROGRAM_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CS_IBM_PROT_FIELD *****************************************
*******************************************************************************/

static char *get_ibmprot_field()
{
	static	 char	ibmprot[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_ibmprot_field()\n"));

	RISfrm_get_field(cs_form, CS_IBM_PROT_FIELD, RIS_MAX_ID_SIZE, ibmprot);
	if (ibmprot[0]) return(ibmprot);
	return NULL;
}

/******************************************************************************/

static void init_ibmprot_field()
{
	int i;

	FRM_DBG(("init_ibmprot_field()\n"));

	FIfld_set_list_num_rows(cs_form, CS_IBM_PROT_FIELD, 0, IBM_PROT_COUNT);

	for (i = 0; i < IBM_PROT_COUNT; i++)
	{
		FIfld_set_list_default_text(cs_form, CS_IBM_PROT_FIELD, i, 0,
			ibmprot_group[i].name, 0);
	}

	FRM_DBG(("init_ibmprot_field:returning\n"));
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
		FIg_display(cs_form, CS_IBM_PROT_FIELD);
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

	FIfld_set_text(cs_form, CS_IBM_PROT_FIELD, 0, 0, ibmprotname, 0);

	erase_ibmprot_group(ibmprot);
	display_ibmprot_group(ibmprot);
}

/******************************************************************************/

static void clear_ibmprot_field()
{
	FRM_DBG(("clear_ibmprot_field()\n"));
	FIfld_set_text(cs_form, CS_IBM_PROT_FIELD, 0, 0, "", 0);
	erase_ibmprot_group(ERASE_ALL_GROUPS);
}

/*******************************************************************************
******************** CS_HOST_PROGRAM_FIELD *************************************
*******************************************************************************/

static char *get_host_program_field()
{
	static	 char	host_program[RIS_MAX_HOST_PROGRAM_SIZE];

	FRM_DBG(("get_host_program_field()\n"));

	RISfrm_get_field(cs_form, CS_HOST_PROGRAM_FIELD, RIS_MAX_HOST_PROGRAM_SIZE,
		host_program);
	if (host_program[0]) return(host_program);
	return NULL;
}

/*******************************************************************************
******************** CS_RIS_LU_FIELD *******************************************
*******************************************************************************/

static char *get_ris_lu_field()
{
	static	 char	ris_lu[RIS_MAX_LU_NAME_SIZE];

	FRM_DBG(("get_ris_lu_field()\n"));

	RISfrm_get_field(cs_form, CS_RIS_LU_FIELD, RIS_MAX_LU_NAME_SIZE, ris_lu);
	if (ris_lu[0]) return(ris_lu);
	return NULL;
}

/******************************************************************************/

static void update_ris_lu_field(
	char	*ris_lu)
{
	FRM_DBG(("update_ris_lu_field(ris_lu:<%s>)\n", ris_lu));
	FIfld_set_text(cs_form, CS_RIS_LU_FIELD, 0, 0, ris_lu, 0);
}

/******************************************************************************/

static void clear_ris_lu_field()
{
	FRM_DBG(("clear_ris_lu_field()\n"));
	FIfld_set_text(cs_form, CS_RIS_LU_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CS_HOST_LU_FIELD ******************************************
*******************************************************************************/

static char *get_host_lu_field()
{
	static	 char	host_lu[RIS_MAX_LU_NAME_SIZE];

	FRM_DBG(("get_host_lu_field()\n"));

	RISfrm_get_field(cs_form, CS_HOST_LU_FIELD, RIS_MAX_LU_NAME_SIZE, host_lu);
	if (host_lu[0]) return(host_lu);
	return NULL;
}

/******************************************************************************/

static void update_host_lu_field(
	char	*host_lu)
{
	FRM_DBG(("update_host_lu_field(host_lu:<%s>)\n", host_lu));
	FIfld_set_text(cs_form, CS_HOST_LU_FIELD, 0, 0, host_lu, 0);
}

/******************************************************************************/

static void clear_host_lu_field()
{
	FRM_DBG(("clear_host_lu_field()\n"));
	FIfld_set_text(cs_form, CS_HOST_LU_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CS_MODE_FIELD *********************************************
*******************************************************************************/

static char *get_mode_field()
{
	static	 char	mode[RIS_MAX_MODE_NAME_SIZE];

	FRM_DBG(("get_mode_field()\n"));

	RISfrm_get_field(cs_form, CS_MODE_FIELD, RIS_MAX_MODE_NAME_SIZE, mode);
	if (mode[0]) return(mode);
	return NULL;
}

/******************************************************************************/

static void update_mode_field(
	char	*mode)
{
	FRM_DBG(("update_mode_field(mode:<%s>)\n", mode));
	FIfld_set_text(cs_form, CS_MODE_FIELD, 0, 0, mode, 0);
}

/******************************************************************************/

static void clear_mode_field()
{
	FRM_DBG(("clear_mode_field()\n"));
	FIfld_set_text(cs_form, CS_MODE_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CS_GROUP_FIELD ********************************************
*******************************************************************************/

static char *get_group_field()
{
	static	 char	group[RIS_MAX_GROUP_SIZE];

	FRM_DBG(("get_group_field()\n"));

	RISfrm_get_field(cs_form, CS_GROUP_FIELD, RIS_MAX_GROUP_SIZE, group);
	if (group[0]) return(group);
	return NULL;
}

/******************************************************************************/

static void update_group_field(
	char	*group)
{
	FRM_DBG(("update_group_field(group:<%s>)\n", group));
	FIfld_set_text(cs_form, CS_GROUP_FIELD, 0, 0, group, 0);
}

/******************************************************************************/

static void clear_group_field()
{
	FRM_DBG(("clear_group_field()\n"));
	FIfld_set_text(cs_form, CS_GROUP_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CS_IBM_NODE_FIELD *****************************************
*******************************************************************************/

static char *get_ibm_node_field()
{
	static	 char	ibm_node[RIS_MAX_NODE_SIZE];

	FRM_DBG(("get_ibm_node_field()\n"));

	RISfrm_get_field(cs_form, CS_IBM_NODE_FIELD, RIS_MAX_NODE_SIZE, ibm_node);
	if (ibm_node[0]) return(ibm_node);
	return NULL;
}

/******************************************************************************/

static void update_ibm_node_field(
	char	*ibm_node)
{
	FRM_DBG(("update_ibm_node_field(ibm_node:<%s>)\n", ibm_node));
	FIfld_set_text(cs_form, CS_IBM_NODE_FIELD, 0, 0, ibm_node, 0);
}

/******************************************************************************/

static void clear_ibm_node_field()
{
	FRM_DBG(("clear_ibm_node_field()\n"));
	FIfld_set_text(cs_form, CS_IBM_NODE_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CS_IBM_PORT_FIELD *****************************************
*******************************************************************************/

static char *get_ibm_port_field()
{
	static  char port[8];

	FRM_DBG(("get_ibm_port_field()\n"));

	RISfrm_get_field(cs_form, CS_IBM_PORT_FIELD, 8, port);
	if (port[0])
	{
		return(port);
	}
	return NULL;
}

/******************************************************************************/

static void update_ibm_port_field(
	int	ibm_port)
{
	FRM_DBG(("update_ibm_port_field(ibm_port:%d)\n", ibm_port));
	FIfld_set_value(cs_form, CS_IBM_PORT_FIELD, 0, 0, (double)ibm_port, 0);
}

/******************************************************************************/

static void clear_ibm_port_field()
{
	FRM_DBG(("clear_ibm_port_field()\n"));
	FIfld_set_text(cs_form, CS_IBM_PORT_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CS_DSQUERY_FIELD *****************************************
*******************************************************************************/

static char *get_dsquery_field()
{
	static	 char	dsquery[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_dsquery_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_DSQUERY_FIELD))
	{
		RISfrm_get_field(cs_form, CS_DSQUERY_FIELD, RIS_MAX_ID_SIZE, dsquery);
		if (dsquery[0]) return(dsquery);
	}
	return(NULL);
}

/******************************************************************************/

static void update_dsquery_field(
	char	*dsquery)
{
	FRM_DBG(("update_dsquery_field(dsquery:<%s>)\n", dsquery));
	FIfld_set_text(cs_form, CS_DSQUERY_FIELD, 0, 0, dsquery, 0);
}

/******************************************************************************/

static void clear_dsquery_field()
{
	FRM_DBG(("clear_dsquery_field()\n"));
	update_dsquery_field("");
}

/*******************************************************************************
******************** CS_MSSQL_DSQUERY_FIELD ************************************
*******************************************************************************/

static char *get_mssql_dsquery_field()
{
    static   char   mssql_dsquery[RIS_MAX_ID_SIZE];

    FRM_DBG(("get_mssql_dsquery_field()\n"));

    if (RISfrm_gadget_displayed(cs_form, CS_MSSQL_DSQUERY_FIELD))
    {
        RISfrm_get_field(cs_form, CS_MSSQL_DSQUERY_FIELD, RIS_MAX_ID_SIZE, mssql_dsquery);
        if (mssql_dsquery[0]) return(mssql_dsquery);
    }
    return(NULL);
}

/******************************************************************************/

static void update_mssql_dsquery_field(
    char    *mssql_dsquery)
{
    FRM_DBG(("update_mssql_dsquery_field(mssql_dsquery:<%s>)\n", mssql_dsquery));
    FIfld_set_text(cs_form, CS_MSSQL_DSQUERY_FIELD, 0, 0, mssql_dsquery, 0);
}

/******************************************************************************/

static void clear_mssql_dsquery_field()
{
    FRM_DBG(("clear_mssql_dsquery_field()\n"));
    update_mssql_dsquery_field("");
}



/*******************************************************************************
******************** CS_IFILE_FIELD *****************************************
*******************************************************************************/

static char *get_sybifile_field()
{
	static	 char	sybifile[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_sybifile_field()\n"));

	if (RISfrm_gadget_displayed(cs_form, CS_IFILE_FIELD))
	{
		RISfrm_get_field(cs_form, CS_IFILE_FIELD, RIS_MAX_ID_SIZE, sybifile);
		if (sybifile[0]) return(sybifile);
	}
	return(NULL);
}

/******************************************************************************/

static void update_sybifile_field(
	char	*sybifile)
{
	FRM_DBG(("update_sybifile_field(sybifile:<%s>)\n", sybifile));
	FIfld_set_text(cs_form, CS_IFILE_FIELD, 0, 0, sybifile, 0);
}

/******************************************************************************/

static void clear_sybifile_field()
{
	FRM_DBG(("clear_sybifile_field()\n"));
	update_sybifile_field("");
}

/*******************************************************************************
******************** CS_MSSQL_IFILE_FIELD *************************************
*******************************************************************************/

static char *get_mssql_mssqlifile_field()
{
    static   char   mssql_mssqlifile[RIS_MAX_ID_SIZE];

    FRM_DBG(("get_mssql_mssqlifile_field()\n"));

    if (RISfrm_gadget_displayed(cs_form, CS_MSSQL_IFILE_FIELD))
    {
        RISfrm_get_field(cs_form, CS_MSSQL_IFILE_FIELD, RIS_MAX_ID_SIZE, mssql_mssqlifile);
        if (mssql_mssqlifile[0]) return(mssql_mssqlifile);
    }
    return(NULL);
}

/******************************************************************************/

static void update_mssql_mssqlifile_field(
    char    *mssql_mssqlifile)
{
    FRM_DBG(("update_mssql_mssqlifile_field(mssql_mssqlifile:<%s>)\n", mssql_mssqlifile));
    FIfld_set_text(cs_form, CS_MSSQL_IFILE_FIELD, 0, 0, mssql_mssqlifile, 0);
}

/******************************************************************************/

static void clear_mssql_mssqlifile_field()
{
    FRM_DBG(("clear_mssql_mssqlifile_field()\n"));
    update_mssql_mssqlifile_field("");
}


/*******************************************************************************
******************** DBTYPE FIELD **********************************************
*******************************************************************************/

static void init_dbtype_field()
{
	int i;

	FRM_DBG(("init_dbtype_field()\n"));

	FIfld_set_list_num_rows(cs_form, CS_DBTYPE_FIELD, 0, DB_COUNT);

	for (i = 0; i < DB_COUNT; i++)
	{
		FIfld_set_list_default_text(cs_form, CS_DBTYPE_FIELD, i, 0,
			db_group[i].name, 0);
	}

	FRM_DBG(("init_dbtype_field:returning\n"));
}

/******************************************************************************/

static char *get_dbtype_field()
{
	static	 char	dbtype[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_dbtype_field()\n"));

	RISfrm_get_field(cs_form, CS_DBTYPE_FIELD, RIS_MAX_ID_SIZE, dbtype);
	if (dbtype[0]) return(dbtype);

	return(NULL);
}

/******************************************************************************/

static void process_dbtype_field()
{
	char *ostype;
	char *dbtypename;

	FRM_DBG(("process_dbtype_field()\n"));
        if ((ostype = get_ostype_field()) == NULL)
        {
                FIg_erase(cs_form, CS_DBMS_LOCATION_GROUP);
                FIg_erase(cs_form, CS_DB_INFO_GROUP);
                cs_msg->label[cs_msg->count++] = CS_OSTYPE_TEXT;
                cs_msg->label[cs_msg->count++] = CS_OSTYPE_FIELD;
                strcpy(cs_msg->str, MSG(RISUTL_I_OSTYPE_MUST_BE_SPEC));
                return;
        }

	dbtypename = get_dbtype_field();
	if (dbtypename != NULL)
 	{	
		dbtype = RISfrm_get_frmdbtype_from_dbtypename(dbtypename);
		if ((strcmp(ostype, VMS_NAME) == 0) &&
			((dbtype == INFORMIX_DB) ||
			    (dbtype == DB2_DB) ||
			    (dbtype == OS400_DB) ||  
			    (dbtype == MSSQL_DB) ||  
			    (dbtype == SYBASE_DB)))	
		{
			erase_db_group(ERASE_ALL_GROUPS);
                	cs_msg->label[cs_msg->count++] = CS_DBTYPE_FIELD;
              	        cs_msg->label[cs_msg->count++] = CS_OSTYPE_FIELD;
               	        sprintf(cs_msg->str, 
						MSG(RISUTL_I_UNSUPPORT_DBTYPE_ON_VMS), dbtypename);
			return;
		}
		else if ((strcmp(ostype, UNIX_NAME) == 0) &&
           	     (dbtype == MSSQL_DB))
        	{
           		 erase_db_group(ERASE_ALL_GROUPS);
           	         cs_msg->label[cs_msg->count++] = CS_DBTYPE_FIELD;
                        cs_msg->label[cs_msg->count++] = CS_OSTYPE_FIELD;
                        sprintf(cs_msg->str, 
					MSG(RISUTL_I_UNSUPPORT_DBTYPE_ON_UNIX), dbtypename);
           		 return;
       		 }
		 else
		 {
			erase_db_group(dbtype);
				

/*
			if (dbtype == OS400_DB)
			{
				FIfld_pos_cursor(cs_form, CS_OS400_DBNAME_FIELD,
					0,0,0,0,0,0);
			}
			else
			{
				FIfld_pos_cursor(cs_form, CS_DBNAME_FIELD,
						0,0,0,0,0,0);
			}
*/
 			display_db_group(dbtype);
			FIg_display(cs_form, CS_DBTYPE_FIELD);
		 }
	}
	else
	{
		clear_db_group();
	}

}

/******************************************************************************/

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

	FIfld_set_text(cs_form, CS_DBTYPE_FIELD, 0, 0, dbtypename, 0);

	erase_db_group(dbtype);
	display_db_group(dbtype);
}

/******************************************************************************/

static void clear_dbtype_field()
{
	FRM_DBG(("clear_dbtype_field()\n"));
	FIfld_set_text(cs_form, CS_DBTYPE_FIELD, 0, 0, "", 0);
	erase_db_group(ERASE_ALL_GROUPS);
}

/*******************************************************************************
******************** DB GROUP **************************************************
*******************************************************************************/

static void clear_db_group()
{
	FRM_DBG(("clear_db_group()\n"));

	FIg_set_state_off(cs_form, CS_SECURESCHEMA_TOGGLE);

	clear_dbtype_field();
	clear_dbusrname_field();
	clear_dbusrpass_field();
	clear_dictowner_field();
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

	/*
	**	OS400
	*/
	clear_os400_group();
}

/******************************************************************************/

static void erase_db_group(
	int	dbtype)
{
	int	i;

	FRM_DBG(("erase_db_group(dbtype:%d)\n", dbtype));

	if (dbtype == OS400_DB)
	{
		FIg_erase(cs_form, CS_DB_INFO_GROUP);
		FIg_erase(cs_form, CS_DBMS_LOCATION_GROUP);
		
	}	
	else
		FIg_erase(cs_form, CS_OS400_GROUP);

	if (db_group[dbtype].osusrname_dbusrname_link)
	{
		FIg_erase(cs_form, CS_OS_USER_GROUP);
	}

	/*
	**	Erase DB INFO GROUP
	*/
	if (dbtype == ERASE_ALL_GROUPS ||
		(VALID_DBTYPE(dbtype) && !db_group[dbtype].db_info_valid))
	{
		FIg_erase(cs_form, CS_DB_INFO_GROUP);
	}

	/*
	**	Erase DBMS LOCATION GROUP
	*/
	if (dbtype == ERASE_ALL_GROUPS ||
		(VALID_DBTYPE(dbtype) && !db_group[dbtype].dbms_location_valid))
	{
		FIg_erase(cs_form, CS_DBMS_LOCATION_GROUP);
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
				FIg_erase(cs_form, db_group[i].label);
			}

			/*
			**	Erase any additional gadgets(groups) not covered by 
			**	db_group[i].label
			*/
			switch(i)
			{
				case DB2_DB:
					erase_ibmprot_group(ERASE_ALL_GROUPS);
					break;
				case INFORMIX_DB:
				case ORACLE_DB:
				case INGRES_DB:
				case RDB_DB:
				case MSSQL_DB:
				case SYBASE_DB:
					break;
			}
		}
	}
}

/******************************************************************************/

static void display_db_group(
	int	dbtype)
{
	static  char	*ostype;
	FRM_DBG(("display_db_group(dbtype:%d)\n", dbtype));

	if (VALID_DBTYPE(dbtype))
	{
		if (dbtype == OS400_DB)
		{
			FIg_display(cs_form, CS_OS400_GROUP);
			FIg_display(cs_form, CS_OS_USER_GROUP);
		}

		else
		{
			/*
			**	Display DB INFO GROUP
			*/
			if (db_group[dbtype].db_info_valid)
			{
				FIg_display(cs_form, CS_DB_INFO_GROUP);
			}
			/*
			**	Display DBMS LOCATION GROUP
			*/
			if (db_group[dbtype].dbms_location_valid)
			{
				FIg_display(cs_form, CS_DBMS_LOCATION_GROUP);
				switch(dbtype)
				{
					case DB2_DB:
						break;
					case INFORMIX_DB:
						FIg_enable(cs_form, CS_DBMS_LOCATION_GROUP);
						break;
					case ORACLE_DB:
						FIg_enable(cs_form, CS_DBMS_LOCATION_GROUP);
						break;
					case INGRES_DB:
						FIg_enable(cs_form, CS_DBMS_LOCATION_GROUP);
						break;
					case MSSQL_DB:
					        FIg_erase (cs_form, CS_DBMS_LOCATION_GROUP) ;
					        break;
					case RDB_DB:
					case SYBASE_DB:
/*
						if ((ostype = get_ostype_field()) == NULL)
						{
							clear_dbtype_field();
							FIg_erase(cs_form, CS_DBMS_LOCATION_GROUP);
							FIg_erase(cs_form, CS_DB_INFO_GROUP);
							cs_msg->label[cs_msg->count++] = CS_OSTYPE_TEXT;
							cs_msg->label[cs_msg->count++] = CS_OSTYPE_FIELD;
							strcpy(cs_msg->str, MSG(RISUTL_I_OSTYPE_MUST_BE_SPEC));
							return;
						}

						if (strcmp(ostype, NT_NAME) == 0)
						{
							FIg_disable(cs_form, CS_DBMS_LOCATION_GROUP);
							FIg_disable(cs_form, CS_IFILE_TEXT);
							FIg_disable(cs_form, CS_IFILE_FIELD);
						}
						else
						{
							FIg_enable(cs_form, CS_DBMS_LOCATION_GROUP);
							FIg_enable(cs_form, CS_IFILE_TEXT);
							FIg_enable(cs_form, CS_IFILE_FIELD);
						}
*/
						break;
				}
			}

			/*
			**	Display dbtype specific group
			*/
			if (db_group[dbtype].label)
			{
				FIg_display(cs_form, db_group[dbtype].label);
			}

			/*
			**	Display any addition not covered by db_group[dbtype].label
			*/
			switch(dbtype)
			{
				case DB2_DB:
					process_ibmprot_field();
					break;
				case OS400_DB:
				case INFORMIX_DB:
				case ORACLE_DB:
				case INGRES_DB:
				case RDB_DB:
				case MSSQL_DB:
				case SYBASE_DB:
					break;
			}
			if (!db_group[dbtype].osusrname_dbusrname_link)
			{
				FIg_display(cs_form, CS_OS_USER_GROUP);
			}
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
				update_os400_dbname_field(db->dbname);
				update_os400_group(db);
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
		clear_dbusrpass_field();
	}
	else
	{
		clear_dbusrname_field();
		clear_dbusrpass_field();
	}

}

/*******************************************************************************
******************** OS400_GROUP *********************************************
*******************************************************************************/

static void clear_os400_group()
{
	FRM_DBG(("clear_os400_group()\n"));

	clear_os400_dbname_field();
	clear_os400_dict_field();
	clear_os400_rislu_field();
	clear_os400_hostlu_field();
	clear_os400_mode_field();
	clear_os400_program_field();
}
/*******************************************************************************
******************** IBMPROT_GROUP *********************************************
*******************************************************************************/

static void clear_ibmprot_group()
{
	FRM_DBG(("clear_ibmprot_group()\n"));

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
				FIg_erase(cs_form, ibmprot_group[i].label);
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
			FIg_display(cs_form, ibmprot_group[ibmprot].label);
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
******************** SCHEMA_NAME_FIELD *****************************************
*******************************************************************************/

static char *get_schname_field()
{
	static	 char	schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_schname_field()\n"));

	RISfrm_get_field(cs_form, CS_SCHNAME_FIELD, RIS_MAX_ID_SIZE, schname);
	return schname[0] ? schname : NULL;
}

/******************************************************************************/

static void process_schname_field()
{
	char			*schname;
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
		return;
	}

	RISfrm_update_cs_form(schema);

	if (RISfrm_sm_form_displayed())
		RISfrm_update_sm_schemas_field(schname);
}

/******************************************************************************/

static void update_schname_field(
	char	*schname)
{
	FRM_DBG(("update_schname_field(schname:<%s>)\n",schname));
	FIfld_set_text(cs_form, CS_SCHNAME_FIELD, 0, 0, schname, 0);
	strcpy(initial_schname, schname);
}

/******************************************************************************/

static void clear_schname_field()
{
	FRM_DBG(("clear_schname_field()\n"));
	FIfld_set_text(cs_form, CS_SCHNAME_FIELD, 0, 0, "", 0);
	strcpy(initial_schname, "");
}

/*******************************************************************************
******************** SCHEMA PASSWORD FIELD *************************************
*******************************************************************************/

static char *get_schpass_field()
{
	static	 char	schpass[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_schpass_field()\n"));

	RISfrm_get_field(cs_form, CS_SCHPASS_FIELD, RIS_MAX_ID_SIZE, schpass);
	return schpass[0] ? schpass : NULL;
}

/******************************************************************************/

static void clear_schpass_field()
{
	FRM_DBG(("clear_schpass_field()\n"));
	FIfld_set_text(cs_form, CS_SCHPASS_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CS_SCHPASS_TOGGLE *****************************************
*******************************************************************************/

static void process_schpass_toggle()
{
	FRM_DBG(("process_schpass_toggle()\n"));
	RISfrm_set_passwd_echo(cs_form,CS_SCHPASS_TOGGLE,CS_SCHPASS_FIELD);
}

/*******************************************************************************
******************** DBUSRNAME FIELD *******************************************
*******************************************************************************/

static char *get_dbusrname_field()
{
	static	 char	dbusrname[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_dbusrname_field()\n"));

	RISfrm_get_field(cs_form, CS_DBUSRNAME_FIELD, RIS_MAX_ID_SIZE, dbusrname);
	return dbusrname[0] ? dbusrname : NULL;
}


/******************************************************************************/

static void update_dbusrname_field(
       char	*dbusrname)
{
	FRM_DBG(("update_dbusrname_field(dbusrname:<%s>)\n",dbusrname));
	FIfld_set_text(cs_form, CS_DBUSRNAME_FIELD, 0, 0, dbusrname, 0);
}

/******************************************************************************/

static void clear_dbusrname_field()
{
	FRM_DBG(("clear_dbusrname_field()\n"));
	FIfld_set_text(cs_form, CS_DBUSRNAME_FIELD, 0, 0, "",0);
}

/******************************************************************************/

static void process_dbusrname_field()
{
	char *dbusrname;

	FRM_DBG(("process_dbusrname_field()\n"));
	if ((dbusrname = get_dbusrname_field()) != NULL)
	{
		update_dictowner_field(dbusrname);
	}

}

/*******************************************************************************
******************** DBUSRPASS FIELD *******************************************
*******************************************************************************/

static char *get_dbusrpass_field()
{
	static	 char	dbusrpass[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_dbusrpass_field()\n"));

	RISfrm_get_field(cs_form, CS_DBUSRPASS_FIELD, RIS_MAX_ID_SIZE, dbusrpass);
	return dbusrpass[0] ? dbusrpass : NULL;
}

/******************************************************************************/

static void process_dbusrpass_field()
{
	char *dbusrpass;

	FRM_DBG(("process_dbusrpass_field()\n"));
	if ((dbusrpass = get_dbusrpass_field()) != NULL)
	{
	}

}
/******************************************************************************/

static void clear_dbusrpass_field()
{
	FRM_DBG(("clear_dbusrpass_field()\n"));
	FIfld_set_text(cs_form, CS_DBUSRPASS_FIELD, 0, 0, "", 0);
}

/**************************************************************************************************CS_DICTOWNER_FIELD***********************************
*******************************************************************************/

static char *get_dictowner_field()
{
	static	 char	dictowner[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_dictowner_field()\n"));
	
	RISfrm_get_field(cs_form,CS_DICTOWNER_FIELD, RIS_MAX_ID_SIZE,dictowner);
	return dictowner[0] ? dictowner : NULL;
}

/**********************************************************************/

static void update_dictowner_field(
	char	*dictowner)
{
	FRM_DBG(("update_dictowner_field(dictowner:<%s>)\n",dictowner));
	FIfld_set_text(cs_form, CS_DICTOWNER_FIELD, 0, 0, dictowner, 0);
}

/******************************************************************************/

static void clear_dictowner_field()
{
	FRM_DBG(("clear_dictowner_field()\n"));
	FIg_set_state_off(cs_form, CS_USEDICTIONARY_TOGGLE);
	FIg_disable(cs_form, CS_DICTOWNER_FIELD);
	FIfld_set_text(cs_form, CS_DICTOWNER_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CS_DBUSRPASS_TOGGLE ***************************************
*******************************************************************************/

static void process_dbusrpass_toggle()
{
	FRM_DBG(("process_dbusrpass_toggle()\n"));
	RISfrm_set_passwd_echo(cs_form,CS_DBUSRPASS_TOGGLE,CS_DBUSRPASS_FIELD);
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));
	RISfrm_erase_rd_form();
	RISfrm_erase_cs_form();
	RISfrm_clear_sd_create_schema_button();
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));

	RISfrm_erase_rd_form();
	RISfrm_clear_cs_form();
	if (RISfrm_sm_form_displayed())
		RISfrm_update_sm_schemas_field(NULL);
	DISPLAY_HELP_BUTTON(cs_form);

/* Fix for TR 439502302  Ashley 4/19/96 */
	RISfrm_set_passwd_no_echo(cs_form,CS_DBUSRPASS_FIELD);
	RISfrm_set_passwd_no_echo(cs_form,CS_SCHPASS_FIELD);
	RISfrm_set_passwd_no_echo(cs_form,CS_OSUSRPASS_FIELD);
/* end fix for TR 439502303 */
	RISfrm_call_user_init_cs_form();
}

/*******************************************************************************
******************** EXECUTE_BUTTON ********************************************
*******************************************************************************/

static void process_execute(
	int force)
{
	int		i;
	int		address_count;
	int		option_count;
	char	*schname, *schpass;
	char	*dbusrname, *dbusrpass;
	int 	dbtype;
	char 	*dbtypename;
	char	*dbname;
	char	*ostype;
	char	*dbms_location = (char *)0;
	char	*osusrname;
	char	*osusrpass;
        char    *dictowner;
	int     include;
	int	secureschema;
	int	usedictionary;
	char	prot[FRM_MAX_PROT_SIZE];
	char	addr[RIS_MAX_NODE_SIZE];
	char	*sqlexec, *dbtemp, *tbconfig;
	char	*ibmprotname;
	char	*host_program, *ris_lu, *host_lu, *mode, *group;
	char	*ibm_node, *ibm_port;
	char	*dsquery, *sybifile;
	char	*mssql_dsquery, *mssql_mssqlifile;
	char	*cmd;
	char	declare_schema_command[512];
	char	create_schema_command[512];

	FRM_DBG(("process_execute_button()\n"));

	/**********************
	**     Declare schname
	**********************/

	cmd = declare_schema_command;

	if ((schname = get_schname_field()) == NULL)
	{
		cs_msg->label[cs_msg->count++] = CS_SCHNAME_TEXT;
		cs_msg->label[cs_msg->count++] = CS_SCHNAME_FIELD;
		strcpy(cs_msg->str, MSG(RISUTL_I_SCHNAME_MUST_BE_SPEC));
		FIfld_pos_cursor(cs_form, CS_SCHNAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}

       	cmd += sprintf(cmd,"DECLARE SCHEMA %s", schname);

	if ((schpass = get_schpass_field()) != NULL)
		cmd += sprintf(cmd,".%s", schpass);

	if ((dbusrname = get_dbusrname_field()) == NULL)
	{
		cs_msg->label[cs_msg->count++] = CS_DBUSRNAME_TEXT;
		cs_msg->label[cs_msg->count++] = CS_DBUSRNAME_FIELD;
		strcpy(cs_msg->str, MSG(RISUTL_I_USERNAME_MUST_BE_SPEC));
		FIfld_pos_cursor(cs_form, CS_DBUSRNAME_FIELD,
			0, 0, 0, 0, 0, 0);
		return;
	}

	cmd += sprintf(cmd," USER %s", dbusrname);

	if ((dbusrpass = get_dbusrpass_field()) != NULL)
		cmd += sprintf(cmd,".%s",dbusrpass);

	if ((dbtypename = get_dbtype_field()) == NULL)
	{
		cs_msg->label[cs_msg->count++] = CS_DBTYPE_FIELD;
		strcpy(cs_msg->str, MSG(RISUTL_I_DBTYPE_MUST_BE_SPEC));
		return;
	}

	dbtype = RISfrm_get_frmdbtype_from_dbtypename(dbtypename);
	if (!VALID_DBTYPE(dbtype))
	{
		RISfrm_form_errhandle(RISUTL_E_INTERNAL, 0);
		RISfrm_report_error();
		return;
	}

	if (!db_group[dbtype].osusrname_dbusrname_link)
	{

		if ((osusrname = get_osusrname_field()) == NULL)
		{
			cs_msg->label[cs_msg->count++] = CS_OSUSRNAME_TEXT;
			cs_msg->label[cs_msg->count++] = CS_OSUSRNAME_FIELD;
			strcpy(cs_msg->str, MSG(RISUTL_I_OSUSER_MUST_BE_SPEC));
			FIfld_pos_cursor(cs_form, CS_OSUSRNAME_FIELD, 0,0,0,0,0,0);
			return;
		}
		
		cmd += sprintf(cmd," OSUSER %s", osusrname);

		if ((osusrpass = get_osusrpass_field()) != NULL)
		{
			cmd += sprintf(cmd,".%s", osusrpass);
		}
	}
	RISfrm_execute_command(declare_schema_command);

	/********************
	**     Create schname
	********************/

	cmd = create_schema_command;

	FIg_get_state(cs_form, CS_SECURESCHEMA_TOGGLE, &secureschema);
        if (secureschema == 0)
        	cmd += sprintf(cmd,"CREATE SCHEMA %s", schname);
	else
		cmd += sprintf(cmd,"CREATE SECURE SCHEMA %s", schname);



	/*
	**	Database Type
	*/
	cmd += sprintf(cmd," ON DATABASE(%s", dbtypename);

	/*
	**	database name
	*/
        
	if (dbtype == OS400_DB)
	{
		
		if ((dbname = get_os400_dbname_field()) == NULL)
		{
			cs_msg->label[cs_msg->count++] = CS_OS400_DBNAME_TEXT;
			cs_msg->label[cs_msg->count++] = CS_OS400_DBNAME_FIELD;
			strcpy(cs_msg->str, MSG(RISUTL_I_DBNAME_MUST_BE_SPEC));
			FIfld_pos_cursor(cs_form, CS_OS400_DBNAME_FIELD,
                                           0,0,0,0,0,0);
			return;
		}
		cmd += sprintf(cmd,", DBNAME %s, ", dbname);

		if ((dbname = get_os400_dict_field()) == NULL)
		{
			cs_msg->label[cs_msg->count++] = CS_OS400_DICT_TEXT;
			cs_msg->label[cs_msg->count++] = CS_OS400_DICT_FIELD;
			strcpy(cs_msg->str, MSG(RISUTL_I_DBNAME_MUST_BE_SPEC));
			FIfld_pos_cursor(cs_form, CS_OS400_DICT_FIELD,
                                           0,0,0,0,0,0);
			return;
		}
		cmd += sprintf(cmd,"RIS_DICT_DBNAME %s", dbname);
	}
	else
	{
		if ((dbname = get_dbname_field()) == NULL)
		{
			cs_msg->label[cs_msg->count++] = CS_DBNAME_TEXT;
			cs_msg->label[cs_msg->count++] = CS_DBNAME_FIELD;
			strcpy(cs_msg->str, MSG(RISUTL_I_DBNAME_MUST_BE_SPEC));
			FIfld_pos_cursor(cs_form, CS_DBNAME_FIELD, 0,0,0,0,0,0);
			return;
		}
		cmd += sprintf(cmd,", DBNAME %s", dbname);
	}

	/*
	**	operating system type
	*/
	if ((ostype = get_ostype_field()) == NULL)
	{
		cs_msg->label[cs_msg->count++] = CS_OSTYPE_TEXT;
		cs_msg->label[cs_msg->count++] = CS_OSTYPE_FIELD;
		strcpy(cs_msg->str, MSG(RISUTL_I_OSTYPE_MUST_BE_SPEC));
		return;
	}
	if (!strcmp(ostype, NT_NAME))
	{
		cmd += sprintf(cmd,", OSTYPE NT");
	}
	else
	{
		cmd += sprintf(cmd,", OSTYPE %s", ostype);
	}

	/*
	**	database management system location(required for oracle)
	*/
	
	switch(dbtype)  
	{
		case SYBASE_DB:
		case MSSQL_DB:
			dbms_location = get_dbms_location_field();
			if (strcmp(ostype, NT_NAME))
			{
				if (dbms_location == NULL)
				{
					cs_msg->label[cs_msg->count++] = CS_DBMS_LOCATION_TEXT;
					cs_msg->label[cs_msg->count++] = CS_DBMS_LOCATION_FIELD;
					strcpy(cs_msg->str, MSG(RISUTL_I_DBMS_MUST_BE_SPEC));
					FIfld_pos_cursor(cs_form, CS_DBMS_LOCATION_FIELD, 0,0,0,0,0,0);
					return;
				}
				cmd += sprintf(cmd,", DIR %s", dbms_location);
			}
			else if (!strcmp(ostype, NT_NAME))  
			{
				if(dbms_location != NULL )
				{
					cmd += sprintf(cmd,", DIR %s", dbms_location);
				}
			}
				
			break;

		case INFORMIX_DB:
			if ((dbms_location = get_dbms_location_field()) == NULL)
			{
				cs_msg->label[cs_msg->count++] = CS_DBMS_LOCATION_TEXT;
				cs_msg->label[cs_msg->count++] = CS_DBMS_LOCATION_FIELD;
				strcpy(cs_msg->str, MSG(RISUTL_I_DBMS_MUST_BE_SPEC));
				FIfld_pos_cursor(cs_form, CS_DBMS_LOCATION_FIELD, 0,0,0,0,0,0);
				return;
			}
			cmd += sprintf(cmd,", DIR %s", dbms_location);
			break;

		case ORACLE_DB:
			if ((dbms_location = get_dbms_location_field()) == NULL)
			{
				cs_msg->label[cs_msg->count++] = CS_DBMS_LOCATION_TEXT;
				cs_msg->label[cs_msg->count++] = CS_DBMS_LOCATION_FIELD;
				strcpy(cs_msg->str, MSG(RISUTL_I_DBMS_MUST_BE_SPEC));
				FIfld_pos_cursor(cs_form, CS_DBMS_LOCATION_FIELD, 0,0,0,0,0,0);
				return;
			}
			cmd += sprintf(cmd,", DIR %s", dbms_location);
			break;

		case INGRES_DB:
			if ((dbms_location = get_dbms_location_field()) == NULL)
			{
				cs_msg->label[cs_msg->count++] = CS_DBMS_LOCATION_TEXT;
				cs_msg->label[cs_msg->count++] = CS_DBMS_LOCATION_FIELD;
				strcpy(cs_msg->str, MSG(RISUTL_I_DBMS_MUST_BE_SPEC));
				FIfld_pos_cursor(cs_form, CS_DBMS_LOCATION_FIELD, 0,0,0,0,0,0);
				return;
			}
			cmd += sprintf(cmd,", DIR %s", dbms_location);
			break;
	}

	/*

	**	Location
	*/
	for (address_count = 0, i = 0; i < RIS_MAX_PROTOCOLS; i++)
	{
		get_protocol_addr(i, prot, addr);
		if (addr[0])
		{
			if (address_count == 0)
			{
				cmd += sprintf(cmd,", REMOTE(");
			}
			else
			{
				cmd += sprintf(cmd,", ");
			}
			cmd += sprintf(cmd,"%s %s", prot, addr);
			address_count++;
		}
	}
	if (address_count != 0)
	{
		cmd += sprintf(cmd,")");
	}

	/*
	**	OPTION
	*/
	option_count = 0;
	switch (dbtype)
	{
		case INFORMIX_DB:
			sqlexec = get_sqlexec_field();
			dbtemp = get_dbtemp_field();
			tbconfig = get_tbconfig_field();
			if (sqlexec != NULL || dbtemp != NULL || tbconfig != NULL)
			{
				cmd += sprintf(cmd, ", OPTION(");
				if (sqlexec)
				{
					cmd += sprintf(cmd, "SQLEXEC=%s",sqlexec);
					option_count++;
				}
				if (dbtemp)
				{
					if (option_count) cmd += sprintf(cmd, ", ");
					cmd += sprintf(cmd, "DBTEMP=%s",dbtemp);
					option_count++;
				}
				if (tbconfig)
				{
					if (option_count) cmd += sprintf(cmd, ", ");
					cmd += sprintf(cmd, "TBCONFIG=%s",tbconfig);
					option_count++;
				}
				cmd += sprintf(cmd, ")");
			}
			break;

		case ORACLE_DB:
			break;

		case DB2_DB:
		cmd += sprintf(cmd, ", GATEWAY(");

			if ((ibmprotname = get_ibmprot_field()) == NULL)
			{
				cs_msg->label[cs_msg->count++] = CS_IBM_PROT_TEXT;
				cs_msg->label[cs_msg->count++] = CS_IBM_PROT_FIELD;
				strcpy(cs_msg->str, MSG(RISUTL_I_IBM_PROT_MUST_BE_SPEC));
				return;
			}
			cmd += sprintf(cmd, "NET_PROTOCOL=%s", ibmprotname);

			if (!strcmp(ibmprotname, IBM_LU62_NAME))
			{
				if ((host_program = get_host_program_field()) == NULL)
				{
					cs_msg->label[cs_msg->count++] = CS_HOST_PROGRAM_TEXT;
					cs_msg->label[cs_msg->count++] = CS_HOST_PROGRAM_FIELD;
					strcpy(cs_msg->str, MSG(RISUTL_I_HOST_PROG_MUST_BE_SPEC));
					FIfld_pos_cursor(cs_form,CS_HOST_PROGRAM_FIELD,0,0,0,0,0,0);
					return;
				}
				cmd += sprintf(cmd, ", HOST_PROGRAM=%s", host_program);

				if ((ris_lu = get_ris_lu_field()) == NULL)
				{
					cs_msg->label[cs_msg->count++] = CS_RIS_LU_TEXT;
					cs_msg->label[cs_msg->count++] = CS_RIS_LU_FIELD;
					strcpy(cs_msg->str, MSG(RISUTL_I_RIS_LU_MUST_BE_SPEC));
					FIfld_pos_cursor(cs_form, CS_RIS_LU_FIELD, 0,0,0,0,0,0);
					return;
				}
				cmd += sprintf(cmd, ", RIS_LU=%s", ris_lu);

				if ((host_lu = get_host_lu_field()) == NULL)
				{
					cs_msg->label[cs_msg->count++] = CS_HOST_LU_TEXT;
					cs_msg->label[cs_msg->count++] = CS_HOST_LU_FIELD;
					strcpy(cs_msg->str, MSG(RISUTL_I_HOST_LU_MUST_BE_SPEC));
					FIfld_pos_cursor(cs_form, CS_HOST_LU_FIELD, 0,0,0,0,0,0);
					return;
				}
				cmd += sprintf(cmd, ", HOST_LU=%s", host_lu);

				if ((mode = get_mode_field()) == NULL)
				{
					cs_msg->label[cs_msg->count++] = CS_MODE_TEXT;
					cs_msg->label[cs_msg->count++] = CS_MODE_FIELD;
					strcpy(cs_msg->str, MSG(RISUTL_I_LU62_MODE_MUST_BE_SPEC));
					FIfld_pos_cursor(cs_form, CS_MODE_FIELD, 0,0,0,0,0,0);
					return;
				}
				cmd += sprintf(cmd, ", MODE=%s", mode);
			}
			else if (!strcmp(ibmprotname, IBM_TCP_NAME))
			{
				if ((ibm_node = get_ibm_node_field()) == NULL)
				{
					cs_msg->label[cs_msg->count++] = CS_IBM_NODE_TEXT;
					cs_msg->label[cs_msg->count++] = CS_IBM_NODE_FIELD;
					strcpy(cs_msg->str, MSG(RISUTL_I_IBM_NODE_MUST_BE_SPEC));
					FIfld_pos_cursor(cs_form, CS_IBM_NODE_FIELD, 0,0,0,0,0,0);
					return;
				}
				cmd += sprintf(cmd, ", NODE=%s", ibm_node);

				if ((ibm_port = get_ibm_port_field()) == NULL)
				{
					cs_msg->label[cs_msg->count++] = CS_IBM_PORT_TEXT;
					cs_msg->label[cs_msg->count++] = CS_IBM_PORT_FIELD;
					strcpy(cs_msg->str, MSG(RISUTL_I_IBM_PORT_MUST_BE_SPEC));
					FIfld_pos_cursor(cs_form, CS_IBM_PORT_FIELD, 0,0,0,0,0,0);
					return;
				}
				cmd += sprintf(cmd, ", PORT=%s", ibm_port);
			}

			if ((group = get_group_field()) != NULL)
			{
				cmd += sprintf(cmd, ", GROUP=%s", group);
			}
			cmd += sprintf(cmd,")");
			break;

		case OS400_DB:
			cmd += sprintf(cmd, ", GATEWAY(");

			if ((ibmprotname = get_os400_prot_field()) == NULL)
			{
				cs_msg->label[cs_msg->count++] = CS_OS400_PROT_TEXT;
				cs_msg->label[cs_msg->count++] = CS_OS400_PROT_FIELD;
				strcpy(cs_msg->str, MSG(RISUTL_I_IBM_PROT_MUST_BE_SPEC));
				return;
			}
			cmd += sprintf(cmd, "NET_PROTOCOL=%s", ibmprotname);

			if ((mode = get_os400_mode_field()) == NULL)
			{
				cs_msg->label[cs_msg->count++] = CS_OS400_MODE_TEXT;
				cs_msg->label[cs_msg->count++] = CS_OS400_MODE_FIELD;
				strcpy(cs_msg->str, MSG(RISUTL_I_LU62_MODE_MUST_BE_SPEC));
				FIfld_pos_cursor(cs_form, CS_MODE_FIELD, 0,0,0,0,0,0);
				return;
			}
				cmd += sprintf(cmd, ", MODE=%s", mode);

			if ((ris_lu = get_os400_rislu_field()) == NULL)
			{
				cs_msg->label[cs_msg->count++] = CS_OS400_RISLU_TEXT;
				cs_msg->label[cs_msg->count++] = CS_OS400_RISLU_FIELD;
				strcpy(cs_msg->str, MSG(RISUTL_I_RIS_LU_MUST_BE_SPEC));
				FIfld_pos_cursor(cs_form, CS_OS400_RISLU_FIELD, 0,0,0,0,0,0);
				return;
			}
				cmd += sprintf(cmd, ", RIS_LU=%s", ris_lu);

			if ((host_lu = get_os400_hostlu_field()) == NULL)
			{
				cs_msg->label[cs_msg->count++] = CS_OS400_HOSTLU_TEXT;
				cs_msg->label[cs_msg->count++] = CS_OS400_HOSTLU_FIELD;
				strcpy(cs_msg->str, MSG(RISUTL_I_HOST_LU_MUST_BE_SPEC));
				FIfld_pos_cursor(cs_form, CS_OS400_HOSTLU_FIELD, 0,0,0,0,0,0);
				return;
			}
				cmd += sprintf(cmd, ", HOST_LU=%s", host_lu);

			if ((host_program = get_os400_program_field()) == NULL)
			{
				cs_msg->label[cs_msg->count++] = CS_OS400_PROGRAM_TEXT;
				cs_msg->label[cs_msg->count++] = CS_OS400_PROGRAM_FIELD;
				strcpy(cs_msg->str, MSG(RISUTL_I_HOST_PROG_MUST_BE_SPEC));
				FIfld_pos_cursor(cs_form,CS_OS400_PROGRAM_FIELD,0,0,0,0,0,0);
				return;
			}
			cmd += sprintf(cmd, ", HOST_PROGRAM=%s", host_program);
			cmd += sprintf(cmd,")");
			break;

		case SYBASE_DB:
			dsquery = get_dsquery_field();
			sybifile = get_sybifile_field();
			if (dsquery != NULL || sybifile != NULL)
			{
				cmd += sprintf(cmd, ", OPTION(");

				if (dsquery != NULL)
				{
					cmd += sprintf(cmd, "DSQUERY=%s",dsquery);
					option_count++;
				}
				if (sybifile != NULL)
				{
					if (option_count) cmd += sprintf(cmd, ", ");
					cmd += sprintf(cmd, "FILENAME=%s",sybifile);
					option_count++;
				}
				cmd += sprintf(cmd, ")");
			}
			break;

        case MSSQL_DB:
            mssql_dsquery = get_mssql_dsquery_field();
            mssql_mssqlifile = get_mssql_mssqlifile_field();
            if (mssql_dsquery != NULL || mssql_mssqlifile != NULL)
            {
                cmd += sprintf(cmd, ", OPTION(");

                if (mssql_dsquery != NULL)
                {
                    cmd += sprintf(cmd, "DSQUERY=%s",mssql_dsquery);
                    option_count++;
                }
                if (mssql_mssqlifile != NULL)
                {
                    if (option_count) cmd += sprintf(cmd, ", ");
                    cmd += sprintf(cmd, "FILENAME=%s",mssql_mssqlifile);
                    option_count++;
                }
                cmd += sprintf(cmd, ")");
            }
            break;

		default:
			break;
	} /* switch (dbtype) */

	cmd += sprintf(cmd,")");

	/*
	**	 dictionary owner 
	*/
	
	FIg_get_state(cs_form, CS_USEDICTIONARY_TOGGLE, &usedictionary);
        if (usedictionary == 1)
           {
	     FIg_enable(cs_form, CS_DICTOWNER_FIELD); 
	     dictowner = get_dictowner_field();
             cmd += sprintf(cmd," USING %s", dictowner);
	   }
	else
	   {
	     FIg_disable(cs_form, CS_DICTOWNER_FIELD); 
           }  	

	/*
        **	include or exclude owner's tables
	*/

	FIg_get_state(cs_form,CS_INCLUDETBL_TOGGLE, &include);
	if (include == 1)
		cmd += sprintf(cmd," EXCLUDE");


	if (force)
	{
		cmd += sprintf(cmd," FORCE");
	}
	FRM_DBG(("frmcrsch.c: %s\n",create_schema_command));

	if (RISfrm_user_exec_cs_form &&
		RISfrm_user_exec_cs_form(cs_form, create_schema_command) == 0)
			return;

	sprintf(cs_msg->str, MSG(RISUTL_I_CREATING_SCHEMA), schname);
	update_msg_field(cs_msg->str);
	RISfrm_execute_command(create_schema_command);
	cs_msg->str[0] = 0;
	clear_msg_field();

	if (SQLCODE)
	{
		RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
		if (RISfrm_report_error() == 0) return;
		switch(SQLCODE)
		{
			case RIS_E_BAD_LOGIN:
				cs_msg->label[cs_msg->count++] = CS_OSUSRNAME_TEXT;
				cs_msg->label[cs_msg->count++] = CS_OSUSRNAME_FIELD;
				cs_msg->label[cs_msg->count++] = CS_OSUSRPASS_TEXT;
				cs_msg->label[cs_msg->count++] = CS_OSUSRPASS_FIELD;
				strcpy(cs_msg->str, MSG(RISUTL_I_VERIFY_LOGIN));
				break;

			case RIS_E_DUP_SCHNAME:
				cs_msg->label[cs_msg->count++] = CS_SCHNAME_TEXT;
				cs_msg->label[cs_msg->count++] = CS_SCHNAME_FIELD;
				if (schpass)
				{
					cs_msg->label[cs_msg->count++] = CS_SCHPASS_TEXT;
					cs_msg->label[cs_msg->count++] = CS_SCHPASS_FIELD;
				}
				sprintf(cs_msg->str, MSG(RISUTL_I_UNIQUE_SCHNAME), schname);
				break;

			case RIS_E_DUP_USR_DBID:
				cs_msg->label[cs_msg->count++] = CS_DBUSRNAME_TEXT;
				cs_msg->label[cs_msg->count++] = CS_DBUSRNAME_FIELD;
				if (dbusrpass)
				{
					cs_msg->label[cs_msg->count++] = CS_DBUSRPASS_TEXT;
					cs_msg->label[cs_msg->count++] = CS_DBUSRPASS_FIELD;
				}
				cs_msg->label[cs_msg->count++] = CS_DBNAME_TEXT;
				cs_msg->label[cs_msg->count++] = CS_DBNAME_FIELD;
				strcpy(cs_msg->str, MSG(RISUTL_I_ENTER_UNIQUE_DB_USER));
				break;

			case RIS_E_DUP_DATABASE:
				for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
				{
					cs_msg->label[cs_msg->count++] =
						protocol_label[i].address;
				}
				cs_msg->label[cs_msg->count++] = CS_DBNAME_TEXT;
				cs_msg->label[cs_msg->count++] = CS_DBNAME_FIELD;
				cs_msg->label[cs_msg->count++] = CS_DB_INFO_GROUP;
				break;

			case RIS_E_INV_OPEN_DB:
				cs_msg->label[cs_msg->count++] = CS_DBNAME_TEXT;
				cs_msg->label[cs_msg->count++] = CS_DBNAME_FIELD;
				cs_msg->label[cs_msg->count++] = CS_DBUSRNAME_TEXT;
				cs_msg->label[cs_msg->count++] = CS_DBUSRNAME_FIELD;
				cs_msg->label[cs_msg->count++] = CS_DBUSRPASS_TEXT;
				cs_msg->label[cs_msg->count++] = CS_DBUSRPASS_FIELD;
				strcpy(cs_msg->str, MSG(RISUTL_I_VERIFY_DBUSR));
				strcat(cs_msg->str, " and ");
				strcat(cs_msg->str, MSG(RISUTL_I_VERIFY_DBNAME));
				break;

			case RIS_E_SCHNAME_NOT_SAME:
				cs_msg->label[cs_msg->count++] = CS_SCHNAME_TEXT;
				cs_msg->label[cs_msg->count++] = CS_SCHNAME_FIELD;
				cs_msg->label[cs_msg->count++] = CS_DBUSRNAME_TEXT;
				cs_msg->label[cs_msg->count++] = CS_DBUSRNAME_FIELD;
				strcpy(cs_msg->str, MSG(RISUTL_I_VERIFY_SCHNAME_USERNAME));
				break;

			case RIS_E_SCHPASS_NOT_SAME:
				cs_msg->label[cs_msg->count++] = CS_SCHPASS_TEXT;
				cs_msg->label[cs_msg->count++] = CS_SCHPASS_FIELD;
				cs_msg->label[cs_msg->count++] = CS_SCHPASS_TOGGLE;
				strcpy(cs_msg->str, MSG(RISUTL_I_VERIFY_SCHPASS));
				break;

#ifdef LATER
			case RIS_E_NETWORK_ERROR:
				for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
				{
					cs_msg->label[cs_msg->count++] =
						protocol_label[i].address;
				}
				switch(dbca->sqlcode)
				{
					case NET_CONNECT_ERROR:
						strcpy(cs_msg->str, MSG(RISUTL_I_VERIFY_ADDRESS_NODE));
						break;

					case NET_ADDR_ERROR:
						strcpy(cs_msg->str, MSG(RISUTL_I_VERIFY_NODENAMES));
						break;
				}
				break;
#endif
		}
		return;
	}
	RISfrm_file_info_up_to_date = 0;

	sprintf(cs_msg->str, MSG(RISUTL_I_CREATE_SCHEMA_SUCCESS), schname);

	if (RISfrm_sm_form_displayed())
	{
		RISfrm_update_schema_mgr();
		RISfrm_update_sm_schemas_field(schname);
	}
}

/******************************************************************************/

static void process_execute_button()
{
	process_execute(0);
}

/******************************************************************************/

static void process_force_button()
{
	process_execute(1);
}

/*******************************************************************************
******************** CREATE SCHEMA FORM ****************************************
*******************************************************************************/

extern void RISfrm_process_cs_form(
	int	g_label)
{
	int	i;

	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,					process_cancel_button			},
		{	FI_RESET,					process_reset_button			},
		{	FI_EXECUTE,					process_execute_button			},
		{	FORCE_BUTTON,				process_force_button			},
		{	CS_SCHNAME_FIELD,			process_schname_field			},
		{	CS_DBUSRNAME_FIELD,			process_dbusrname_field			},
		{	CS_DBUSRPASS_FIELD,			process_dbusrpass_field			},
		{	CS_SCHPASS_TOGGLE,			process_schpass_toggle			},
		{	CS_DBUSRPASS_TOGGLE,		process_dbusrpass_toggle		},
		{	CS_OSUSRPASS_TOGGLE,		process_osusrpass_toggle		},
		{	CS_USEDICTIONARY_TOGGLE,	process_usedictionary_toggle            },
		{	CS_LOCAL_MACHINE_BUTTON,	process_local_machine_button	},
		{	CS_PROTOCOL_ROLLTHRU_1,		process_protocol_rollthru_1		},
		{	CS_PROTOCOL_ROLLTHRU_2,		process_protocol_rollthru_2		},
		{	CS_PROTOCOL_ROLLTHRU_3,		process_protocol_rollthru_3		},
		{	CS_PROTOCOL_ROLLTHRU_4,		process_protocol_rollthru_4		},
		{	CS_ADDRESS_FIELD_1,			process_address_field_1			},
		{	CS_ADDRESS_FIELD_2,			process_address_field_2			},
		{	CS_ADDRESS_FIELD_3,			process_address_field_3			},
		{	CS_ADDRESS_FIELD_4,			process_address_field_4			},
		{	CS_DBTYPE_FIELD,			process_dbtype_field			},
		{	CS_IBM_PROT_FIELD,			process_ibmprot_field			},
		{	CS_DISPLAY_DBS_BUTTON,		process_display_dbs_button		},
		{	CS_OS400_DBNAME_FIELD,		process_os400_dbname_field		},
		{	CS_OSTYPE_FIELD,		process_ostype_field		},
		{	CS_DBMS_LOCATION_FIELD,		process_dbms_location_field		},
		{	CS_OSUSRPASS_FIELD,		process_osusrpass_field		},
		{	CS_DBNAME_FIELD,		process_dbname_field		},
	};
	static	int	process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_cs_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(cs_form);

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

extern void RISfrm_call_user_init_cs_form()
{
	FRM_DBG(("RISfrm_call_user_init_cs_form()\n"));

	VALID_FORM_CHECK(cs_form);

	if (RISfrm_user_init_cs_form)
	{
		FRM_DBG(("calling RISfrm_user_init_cs_form()\n"));
		RISfrm_user_init_cs_form(cs_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_cs_form(
	int	called_by_user)
{
	int	sts;

	FRM_DBG(("RISfrm_display_cs_form(called_by_user:%d)\n",called_by_user));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!cs_form)
	{
		sts = FIf_new(CS_FORM, CS_FORM_FILE, RISfrm_notification_routine,
			&cs_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_CS_FORM, sts);
			return RIS_forms_error.error;
		}
#if defined(WIN32)
		FIf_SetDefaultButton(cs_form, FI_EXECUTE);
		FIg_set_text(cs_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));
		FIg_set_text(cs_form, FORCE_BUTTON, RIScom_umsg(RISUTL_I_FORCE));
		
#endif
		FIfld_set_max_num_chars(cs_form, CS_SCHNAME_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
		FIfld_set_max_num_chars(cs_form, CS_SCHPASS_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
		FIfld_set_max_num_chars(cs_form, CS_DICTOWNER_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
		FIfld_set_max_num_chars(cs_form, CS_DBUSRNAME_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
		FIfld_set_max_num_chars(cs_form, CS_DBUSRPASS_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
		FIfld_set_max_num_chars(cs_form, CS_DBNAME_FIELD, 0,
			RIS_MAX_PATH_SIZE - 1);
		FIfld_set_max_num_chars(cs_form, CS_DBMS_LOCATION_FIELD, 0,
			RIS_MAX_PATH_SIZE - 1);
		FIfld_set_max_num_chars(cs_form, CS_OSUSRNAME_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
		FIfld_set_max_num_chars(cs_form, CS_OSUSRPASS_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
		FIfld_set_max_num_chars(cs_form, CS_SQLEXEC_FIELD, 0,
			RIS_MAX_PATH_SIZE - 1);
		FIfld_set_max_num_chars(cs_form, CS_DBTEMP_FIELD, 0,
			RIS_MAX_PATH_SIZE - 1);
		FIfld_set_max_num_chars(cs_form, CS_TBCONFIG_FIELD, 0,
			RIS_MAX_PATH_SIZE - 1);
	}

	if (!RISfrm_cs_form_displayed())
	{
		cs_msg->str[0] = 0;
		cs_msg->count = 0;
		cs_msg->msg_fld_label = CS_MSG_FIELD;
		cs_msg->fp = cs_form;

		DISPLAY_HELP_BUTTON(cs_form);


		init_protocol_addr();
		init_dbtype_field();
		init_ostype_field();
		init_ibmprot_field();

		if (called_by_user) RISfrm_call_user_init_cs_form();

		sts = FIf_display(cs_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_CS_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern void RISfrm_update_cs_form(
	ris_schema_info *schema)
{
	ris_db_info	*db;

	FRM_DBG(("RISfrm_update_cs_form(schema:0x%x)\n", schema));

	VALID_FORM_CHECK(cs_form);

	if (!schema)
	{
		RISfrm_clear_cs_form();
		return;
	}

	db = RISfrm_db_from_schema(schema);
	if (!db)
	{
		RISfrm_clear_cs_form();
		return;
	}

	dbtype = RISfrm_get_frmdbtype_from_risdbtype(db->dtype);
	if (!VALID_DBTYPE(dbtype))
	{
#ifdef MAYBE
		RISfrm_form_errhandle(RISUTL_E_INTERNAL, 0);
		RISfrm_report_error();
		return;
#endif
		RISfrm_clear_cs_form();
		return;
	}

	update_schname_field(schema->schname);

	if (schema->secure)
	{
		FIg_set_state_on(cs_form, CS_SECURESCHEMA_TOGGLE);
	}
	else
	{
		FIg_set_state_off(cs_form, CS_SECURESCHEMA_TOGGLE);
	}

	if (strcmp(schema->schowner, schema->dictowner) == 0)
	{
		clear_dictowner_field();
	}
	else
	{
		FIg_set_state_on(cs_form, CS_USEDICTIONARY_TOGGLE);
		FIfld_set_text(cs_form, CS_DICTOWNER_FIELD, 0, 0,
			                    schema->dictowner, 0);	
		FIg_enable(cs_form, CS_DICTOWNER_FIELD);
	}
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
	clear_osusrpass_field();

	update_db_group(db, schema);
}

/******************************************************************************/

extern void RISfrm_update_cs_form_by_db(
	ris_db_info *db)
{

	FRM_DBG(("RISfrm_update_cs_form_by_db(db:0x%x)\n", db));

	VALID_FORM_CHECK(cs_form);

	if (!db)
	{
		RISfrm_clear_cs_form();
		return;
	}

	dbtype = RISfrm_get_frmdbtype_from_risdbtype(db->dtype);
	if (!VALID_DBTYPE(dbtype))
	{
#ifdef MAYBE
		RISfrm_form_errhandle(RISUTL_E_INTERNAL, 0);
		RISfrm_report_error();
		return;
#endif
		RISfrm_clear_cs_form();
		return;
	}

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
			break;
		case OS400_DB:
			update_osusrname_field(db->info.os400.osuser);
			break;
	}
	clear_osusrpass_field();

	update_db_group(db, NULL);
}

/******************************************************************************/

extern void RISfrm_clear_cs_form()
{
	FRM_DBG(("RISfrm_clear_cs_form()\n"));

	VALID_FORM_CHECK(cs_form);

	clear_schname_field();
	clear_schpass_field();
	clear_protocol_addr();
	clear_ostype_field();
	clear_osusrname_field();
	clear_osusrpass_field();
	clear_db_group();
	RISfrm_clear_cs_display_dbs_button();
}

/******************************************************************************/

extern int RISfrm_cs_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_cs_form_displayed()\n"));

	if (cs_form)
	{
		FIf_is_displayed(cs_form, &form_displayed);
		return form_displayed;
	}
	return 0;
}

/******************************************************************************/

extern int RISfrm_erase_cs_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_cs_form()\n"));

	if (RISfrm_cs_form_displayed())
	{
		RISfrm_erase_rd_form();
		RISfrm_clear_cs_form();
		sts = FIf_erase(cs_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_CS_FORM, sts);
			return RIS_forms_error.error;
		}
		if (RISfrm_sd_form_displayed())
		{
			RISfrm_clear_sd_create_schema_button();
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
******************** USER FUNCTIONS ********************************************
*******************************************************************************/

extern int RISAPI RISXfrm_create_schema_form_displayed()
{
	return RISfrm_cs_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_create_schema_form()
{
	return RISfrm_display_cs_form(CALLED_BY_USER);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_create_schema_form()
{
	return RISfrm_erase_cs_form();
}

/******************************************************************************/
