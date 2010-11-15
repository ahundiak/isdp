/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							frmnodin.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					06/91
**	ABSTRACT:
**		The code to process the node info form.
**	
**	REVISION HISTORY:
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
**
**		11/94:	Added INTERNATIONALIZATION support. Linda Wang
**	02/03/95 Removed NTJ specific changes. rlk
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "forms.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmnodin_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "frmschdf.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmfile.prt"
#include "frmmsg.prt"
#include "frmnodin.prt"
#include "frmntfy.prt"
#include "frmschmg.prt"
#include "frmutil.prt"
#include "fi.prt"
#include "sys.prt"
#include "ris.prt"
#if defined (WIN32)
#include "fi_winnt.prt"
#endif

/*
**	DEFINES
*/
#define DISABLE_ALL_GROUPS	-1
#define MODIFY_USRPASS		0
#define MODIFY_NODE			1
#define MODIFY_OSUSER		2
#define ACTION_COUNT		3

#define VALID_ACTION(action) ((action) >= 0 && (action) < ACTION_COUNT)

/*
**	VARIABLES
*/
static struct
{
	int protocol;
	int address;
} protocol_label[RIS_MAX_PROTOCOLS] =
{
	{	NI_PROTOCOL_ROLLTHRU_1,	NI_ADDRESS_FIELD_1 },
	{	NI_PROTOCOL_ROLLTHRU_2,	NI_ADDRESS_FIELD_2 },
	{	NI_PROTOCOL_ROLLTHRU_3,	NI_ADDRESS_FIELD_3 },
	{	NI_PROTOCOL_ROLLTHRU_4,	NI_ADDRESS_FIELD_4 },
};

static struct action_info_s
{
	int		group;
	int		button;
	void	(*update_function)();	
	void	(*disable_function)();
	void	(*clear_function)();
} action_info[ACTION_COUNT] =
{
	{
		NI_USRPASS_GROUP,
		NI_USRPASS_BUTTON,
		update_usrpass_group, 
		disable_usrpass_group, 
		clear_usrpass_group, 
	},
	{
		NI_NODE_GROUP,
		NI_NODE_BUTTON,
		update_node_group, 
		disable_node_group, 
		clear_node_group, 
	},
	{
		NI_OSUSER_GROUP,
		NI_OSUSER_BUTTON,
		update_osuser_group, 
		disable_osuser_group, 
		clear_osuser_group, 
	},
};

static  Form			ni_form;
static RISfrm_msg	*ni_msg = &RISfrm_msgs[NI_FORM_MSG];
static  char			initial_schname[RIS_MAX_ID_SIZE] = "";


/*
**	FUNCTIONS
*/

/*******************************************************************************
************** NI_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(ni_form, NI_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(ni_form, NI_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SCHEMA_NAME_FIELD *****************************************
*******************************************************************************/

static char *get_schname_field()
{
	static	 char	schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_schname_field()\n"));
	RISfrm_get_field(ni_form, NI_SCHNAME_FIELD, RIS_MAX_ID_SIZE, schname);
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
			sprintf(ni_msg->str, MSG(RISUTL_I_UNKNOWN_SCHEMA), schname);
		}
	}

	if (RISfrm_sm_form_displayed())
	{
		RISfrm_update_sm_schemas_field(schname);
	}

	update_ni_form(schema);
}

/******************************************************************************/

static void update_schname_field(
	char	*schname)
{

	FRM_DBG(("update_schname_field(schname:<%s>)\n", schname));
	FIfld_set_text(ni_form, NI_SCHNAME_FIELD, 0, 0, schname, 0);
	strcpy(initial_schname, schname);
}

/******************************************************************************/

static void clear_schname_field()
{
	FRM_DBG(("clear_schname_field()\n"));
	FIfld_set_text(ni_form, NI_SCHNAME_FIELD, 0, 0, "", 0);
	strcpy(initial_schname, "");
}

/*******************************************************************************
******************** NI_USRNAME_FIELD ******************************************
*******************************************************************************/

static void update_usrname_field(
	char	*usrname)
{

	FRM_DBG(("update_usrname_field(usrname:<%s>)\n", usrname));
	FIfld_set_text(ni_form, NI_USRNAME_FIELD, 0, 0, usrname, 0);
}

/******************************************************************************/

static void clear_usrname_field()
{
	FRM_DBG(("clear_usrname_field()\n"));
	FIfld_set_text(ni_form, NI_USRNAME_FIELD, 0, 0, "",0);
}

/*******************************************************************************
******************** NI_USRPASS_FIELD ******************************************
*******************************************************************************/

static char *get_usrpass_field()
{
	static	 char	usrpass[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_usrpass_field()\n"));

	RISfrm_get_field(ni_form, NI_USRPASS_FIELD, RIS_MAX_ID_SIZE, usrpass);
	return usrpass[0] ? usrpass : NULL;
}

/******************************************************************************/

static void clear_usrpass_field()
{
	FRM_DBG(("clear_usrpass_field()\n"));
	FIfld_set_text(ni_form, NI_USRPASS_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** NI_USRPASS_TOGGLE *****************************************
*******************************************************************************/

static void process_usrpass_toggle()
{
	FRM_DBG(("process_usrpass_toggle()\n"));
	RISfrm_set_passwd_echo(ni_form, NI_USRPASS_TOGGLE, NI_USRPASS_FIELD);
}

/*******************************************************************************
******************** NI_OSUSER_FIELD ******************************************
*******************************************************************************/

static char *get_osuser_field()
{
	static	 char	osuser[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_osuser_field()\n"));
	RISfrm_get_field(ni_form, NI_OSUSER_FIELD, RIS_MAX_ID_SIZE, osuser);
	return osuser[0] ? osuser : NULL;
}

/******************************************************************************/

static void update_osuser_field(
	char	*osuser)
{
	FRM_DBG(("update_osuser_field(osuser:<%s>)\n", osuser));
	FIfld_set_text(ni_form, NI_OSUSER_FIELD, 0, 0, osuser, 0);
}

/******************************************************************************/

static void clear_osuser_field()
{
	FRM_DBG(("clear_osuser_field()\n"));
	FIfld_set_text(ni_form, NI_OSUSER_FIELD, 0, 0, "",0);
}

/*******************************************************************************
******************** NI_OSPASS_FIELD ******************************************
*******************************************************************************/

static char *get_ospass_field()
{
	static	 char	ospass[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_ospass_field()\n"));
	RISfrm_get_field(ni_form, NI_OSPASS_FIELD, RIS_MAX_ID_SIZE, ospass);
	return ospass[0] ? ospass : NULL;
}

/******************************************************************************/

static void clear_ospass_field()
{
	FRM_DBG(("clear_ospass_field()\n"));
	FIfld_set_text(ni_form, NI_OSPASS_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** NI_OSPASS_TOGGLE *****************************************
*******************************************************************************/

static void process_ospass_toggle()
{
	FRM_DBG(("process_ospass_toggle()\n"));
	RISfrm_set_passwd_echo(ni_form, NI_OSPASS_TOGGLE, NI_OSPASS_FIELD);
}

/*******************************************************************************
************** NI_USRPASS_BUTTON ***********************************************
*******************************************************************************/

static void process_usrpass_button()
{
	int state;

	FRM_DBG(("process_usrpass_button()\n"));
	FIg_get_state(ni_form, NI_USRPASS_BUTTON, &state);
	if (state)
	{
		enable_group(MODIFY_USRPASS);
	}
	else
	{
		disable_group(MODIFY_USRPASS);
	}
}

/******************************************************************************/

static void clear_usrpass_button()
{
	FRM_DBG(("clear_usrpass_button()\n"));
	FIg_set_state(ni_form, NI_USRPASS_BUTTON, 0);
}

/*******************************************************************************
************** NI_NODE_BUTTON **************************************************
*******************************************************************************/

static void process_node_button()
{
	int state;

	FRM_DBG(("process_node_button()\n"));
	FIg_get_state(ni_form, NI_NODE_BUTTON, &state);
	if (state)
	{
		enable_group(MODIFY_NODE);
	}
	else
	{
		disable_group(MODIFY_NODE);
	}
}

/******************************************************************************/

static void clear_node_button()
{
	FRM_DBG(("clear_node_button()\n"));
	FIg_set_state(ni_form, NI_NODE_BUTTON, 0);
}

/*******************************************************************************
************** NI_OSUSER_BUTTON ************************************************
*******************************************************************************/

static void process_osuser_button()
{
	int state;

	FRM_DBG(("process_osuser_button()\n"));
	FIg_get_state(ni_form, NI_OSUSER_BUTTON, &state);
	if (state)
	{
		enable_group(MODIFY_OSUSER);
	}
	else
	{
		disable_group(MODIFY_OSUSER);
	}
}

/******************************************************************************/

static void enable_osuser_button()
{
	FRM_DBG(("enable_osuser_button()\n"));
	FIg_enable(ni_form, NI_OSUSER_BUTTON);
}

/******************************************************************************/

static void disable_osuser_button()
{
	FRM_DBG(("disable_osuser_button()\n"));
	FIg_set_state(ni_form, NI_OSUSER_BUTTON, 0);
	FIg_disable(ni_form, NI_OSUSER_BUTTON);
}

/******************************************************************************/

static void clear_osuser_button()
{
	FRM_DBG(("clear_osuser_button()\n"));
	FIg_set_state(ni_form, NI_OSUSER_BUTTON, 0);
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

	RISfrm_get_field(ni_form, protocol_label[row].protocol, FRM_MAX_PROT_SIZE,
		prot);

	RISfrm_get_field(ni_form, protocol_label[row].address, RIS_MAX_NODE_SIZE,
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
	FIfld_set_num_rows(ni_form, prot_label, 1);
	FIfld_set_text(ni_form, prot_label, 0, 0, prot, 0);
	FIfld_set_active_row(ni_form, prot_label, 0, 0);

	FIfld_set_text(ni_form, protocol_label[row].address, 0, 0, addr, 0);
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
	ris_db_info	*db)
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
			if ((p = RISfrm_get_form_prot(db->pathways[i].protocol)) == -1)
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
		ni_msg->label[ni_msg->count++] = protocol_label[row].protocol;
		ni_msg->label[ni_msg->count++] = protocol_label[row].address;
		strcpy(ni_msg->str, MSG(RISUTL_I_ISO_NOT_AVAILABLE));
		FIfld_set_text(ni_form, protocol_label[row].address, 0, 0, "", 0);
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
******************** USRPASS_GROUP *********************************************
*******************************************************************************/

static void update_usrpass_group(
	ris_schema_info *schema)
{
	FRM_DBG(("update_usrpass_group(schema:0x%x)\n", schema));

	if (schema)
	{
		update_usrname_field(schema->schowner);
	}
	else
	{
		clear_usrname_field();
	}
	clear_usrpass_field();
}

/******************************************************************************/

static void disable_usrpass_group()
{
	FRM_DBG(("disable_usrpass_group()\n"));

	clear_usrname_field();
	clear_usrpass_field();
}

/******************************************************************************/

static void clear_usrpass_group()
{
	FRM_DBG(("clear_usrpass_group()\n"));

	clear_usrname_field();
	clear_usrpass_field();
}

/*******************************************************************************
******************** NODE_GROUP ************************************************
*******************************************************************************/

static void update_node_group(
	ris_schema_info	*schemap)
{
	ris_db_info	*dbp;

	FRM_DBG(("update_node_group(schemap:0x%x)\n",schemap));

	dbp = RISfrm_db_from_schema(schemap);
	update_protocol_addr(dbp);
}

/******************************************************************************/

static void disable_node_group()
{
	int	i;

	FRM_DBG(("disable_node_group()\n"));
	for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
		put_protocol_addr(i, "", "");
}

/******************************************************************************/

static void clear_node_group()
{
	FRM_DBG(("clear_node_group()\n"));

	init_protocol_addr();
}

/*******************************************************************************
******************** OSUSER_GROUP **********************************************
*******************************************************************************/

static void update_osuser_group(
	ris_schema_info *schema)
{
	ris_db_info	*dbp;

	FRM_DBG(("update_osuser_group(schema:0x%x)\n", schema));

	if ((dbp = RISfrm_db_from_schema(schema)) != NULL)
	{
		if (dbp->dtype == 'O')
		{
			update_osuser_field(dbp->info.ora.osuser);
		}
		else if (dbp->dtype == 'D')
		{
			update_osuser_field(dbp->info.db2.osuser);
		}
		else if (dbp->dtype == 'Y')
		{
			update_osuser_field(dbp->info.syb.osuser);
		}
		else if (dbp->dtype == 'M')
		{
			update_osuser_field(dbp->info.mssql.osuser);
		}
		else if (dbp->dtype == '4')
		{
			update_osuser_field(dbp->info.os400.osuser);
		}
		else
		{
			clear_osuser_field();
		}
	}
	else
	{
		clear_osuser_field();
	}
	clear_ospass_field();
}

/******************************************************************************/

static void disable_osuser_group()
{
	FRM_DBG(("disable_osuser_group()\n"));

	clear_osuser_field();
	clear_ospass_field();
}

/******************************************************************************/

static void clear_osuser_group()
{
	FRM_DBG(("clear_osuser_group()\n"));

	clear_osuser_field();
	clear_ospass_field();
}

/*******************************************************************************
******************** GROUP *****************************************************
*******************************************************************************/

static int active(
	int action)
{
	int	state;

	FRM_DBG(("active(action:%d)\n", action));

	if (!VALID_ACTION(action)) return 0;

	FIg_get_state(ni_form, action_info[action].button, &state);
	return state;
}

/******************************************************************************/

static void disable_group(
	int	action)
{
	FRM_DBG(("disable_group(action:%d)\n", action));

	if (!VALID_ACTION(action)) return;

	if (action_info[action].disable_function)
		action_info[action].disable_function();
	FIg_disable(ni_form, action_info[action].group);
}

/******************************************************************************/

static void enable_group(
	int	action)
{
	char		*schname;
	ris_schema_info	*schemap;

	FRM_DBG(("enable_group(action:%d)\n", action));

	if (!VALID_ACTION(action)) return;

	FIg_enable(ni_form, action_info[action].group);
	if (action_info[action].update_function)
	{
		schname = get_schname_field();
		schemap = RISfrm_get_schema(schname, update_msg_field, clear_msg_field);
		action_info[action].update_function(schemap);
	}
}

/******************************************************************************/

static void disable_groups()
{
	int action;

	FRM_DBG(("disable_groups()\n"));
	for (action = 0; action < ACTION_COUNT; action++)
		disable_group(action);
}

/******************************************************************************/

static void update_groups(
	ris_schema_info	*schemap)
{
	int	action;

	FRM_DBG(("update_group(schemap:0x%x)\n",schemap));

	for (action = 0; action < ACTION_COUNT; action++)
		if (active(action))
			if (action_info[action].update_function)
				action_info[action].update_function(schemap);
}

/******************************************************************************/

static void clear_groups()
{
	int	action;

	FRM_DBG(("clear_groups()\n"));

	for (action = 0; action < ACTION_COUNT; action++)
		if (active(action))
			if (action_info[action].clear_function)
				action_info[action].clear_function();
}

/*******************************************************************************
******************** NI_LOCAL_MACHINE_BUTTON ***********************************
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

	FIg_set_state(ni_form, NI_LOCAL_MACHINE_BUTTON, 0);
}

/*******************************************************************************
******************** EXECUTE BUTTON ********************************************
*******************************************************************************/

static void process_execute_button()
{
	int		i;
	int		action;
	int 	address_count;
	int		active_count = 0;
	char	*ptr;
	char	*schname;
	char	*usrpass;
	char	*osuser;
	char	*ospass;
	char	command[128];
	char	prot[FRM_MAX_PROT_SIZE];
	char	addr[RIS_MAX_NODE_SIZE];
	ris_schema_info	*schema;

	FRM_DBG(("process_execute_button()\n"));

	for (action = 0; action < ACTION_COUNT; action++)
	{
		if (active(action))
		{
			break;
		}
	}
	if (action == ACTION_COUNT)
	{
		strcpy(ni_msg->str, MSG(RISUTL_I_NO_ACTION_SELECT_ACTION));
		return;
	}

	ptr = command;

	if ((schname = get_schname_field()) == NULL)
	{
		ni_msg->label[ni_msg->count++] = NI_SCHNAME_TEXT;
		ni_msg->label[ni_msg->count++] = NI_SCHNAME_FIELD;
		strcpy(ni_msg->str, MSG(RISUTL_I_SCHNAME_MUST_BE_SPEC));
		FIfld_pos_cursor(ni_form, NI_SCHNAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}
	schema = RISfrm_get_schema(schname, update_msg_field, clear_msg_field);
	if (schema == NULL)
	{
		ni_msg->label[ni_msg->count++] = NI_SCHNAME_TEXT;
		ni_msg->label[ni_msg->count++] = NI_SCHNAME_FIELD;
		sprintf(ni_msg->str, MSG(RISUTL_I_UNKNOWN_SCHEMA), schname);
		FIfld_pos_cursor(ni_form, NI_SCHNAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}

	ptr += sprintf(ptr,"ALTER SCHEMA %s MODIFY", schname);

	if (active(MODIFY_NODE))
	{
		ptr += sprintf(ptr," REMOTE(");
		for (address_count = 0, i = 0; i < RIS_MAX_PROTOCOLS; i++)
		{
			get_protocol_addr(i, prot, addr);
			if (addr[0])
			{
				if (address_count) ptr += sprintf(ptr,", ");
				ptr += sprintf(ptr,"%s %s", prot, addr);
				address_count++;
			}
		}
		ptr += sprintf(ptr,")");

		if (address_count == 0)
		{
			for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
			{
				ni_msg->label[ni_msg->count++] =
					protocol_label[i].address;
			}
			strcpy(ni_msg->str, MSG(RISUTL_I_ONE_ADDR_MUST_BE_SPEC));
			return;
		}
		active_count++;
	}

	if (active(MODIFY_USRPASS))
	{
		if (active_count)
		{
			ptr += sprintf(ptr,",");
		}

		if ((usrpass = get_usrpass_field()) == NULL)
			ptr += sprintf(ptr," USER PASSWORD");
		else
			ptr += sprintf(ptr," USER PASSWORD %s", usrpass);

		active_count++;
	}
	
	if (active(MODIFY_OSUSER))
	{
		if (active_count)
		{
			ptr += sprintf(ptr,",");
		}

		if ((osuser = get_osuser_field()) == NULL)
		{
			ni_msg->label[ni_msg->count++] = NI_OSUSER_TEXT;
			ni_msg->label[ni_msg->count++] = NI_OSUSER_FIELD;
			strcpy(ni_msg->str, MSG(RISUTL_I_OSUSER_MUST_BE_SPEC));
			FIfld_pos_cursor(ni_form, NI_OSUSER_FIELD, 0, 0, 0, 0, 0, 0);
			return;
		}
		if ((ospass = get_ospass_field()) == NULL)
			ptr += sprintf(ptr," OSUSER %s", osuser);
		else
			ptr += sprintf(ptr," OSUSER %s.%s", osuser, ospass);

		active_count++;
	}
	
	if (RISfrm_user_exec_ni_form &&
		RISfrm_user_exec_ni_form(ni_form, command) == 0)
			return;

	sprintf(ni_msg->str, MSG(RISUTL_I_ALTERING_SCHEMA), schname);
	update_msg_field(ni_msg->str);
	RISfrm_execute_schema_command(schema->schname, schema->dbid, command);
	ni_msg->str[0] = 0;
	clear_msg_field();

	if (SQLCODE)
	{
		RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
		if (RISfrm_report_error() == 0) return;

		switch(SQLCODE)
		{
		}
		return;
	}

	RISfrm_file_info_up_to_date = 0;

	sprintf(ni_msg->str,MSG(RISUTL_I_ALTER_SCHEMA_SUCCESS), schname);
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));

	RISfrm_clear_ni_form();
	if (RISfrm_sm_form_displayed())
		RISfrm_update_sm_schemas_field(NULL);
	DISPLAY_HELP_BUTTON(ni_form);
	RISfrm_call_user_init_ni_form();
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));

	RISfrm_erase_ni_form();
}

/*******************************************************************************
******************** AS FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_ni_form(
	int	g_label)
{
	int	i;

	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,					process_cancel_button			},
		{	FI_RESET,					process_reset_button			},
		{	FI_EXECUTE,					process_execute_button			},
		{	NI_SCHNAME_FIELD,			process_schname_field			},
		{	NI_USRPASS_TOGGLE,			process_usrpass_toggle			},
		{	NI_OSPASS_TOGGLE,			process_ospass_toggle			},
		{	NI_LOCAL_MACHINE_BUTTON,	process_local_machine_button	},
		{	NI_PROTOCOL_ROLLTHRU_1,		process_protocol_rollthru_1		},
		{	NI_PROTOCOL_ROLLTHRU_2,		process_protocol_rollthru_2		},
		{	NI_PROTOCOL_ROLLTHRU_3,		process_protocol_rollthru_3		},
		{	NI_PROTOCOL_ROLLTHRU_4,		process_protocol_rollthru_4		},
		{	NI_ADDRESS_FIELD_1,			process_address_field_1			},
		{	NI_ADDRESS_FIELD_2,			process_address_field_2			},
		{	NI_ADDRESS_FIELD_3,			process_address_field_3			},
		{	NI_ADDRESS_FIELD_4,			process_address_field_4			},
		{	NI_USRPASS_BUTTON,			process_usrpass_button			},
		{	NI_NODE_BUTTON,				process_node_button				},
		{	NI_OSUSER_BUTTON,			process_osuser_button			},
	};
	static	int	process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_ni_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(ni_form);

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}

	for (i = 0; i < ACTION_COUNT; i++)
		if (active(i)) break;
	if (i == ACTION_COUNT && !ni_msg->str[0])
	{
		strcpy(ni_msg->str, MSG(RISUTL_I_SELECT_ACTION));
	}
}

/******************************************************************************/

extern void RISfrm_call_user_init_ni_form()
{
	FRM_DBG(("RISfrm_call_user_init_ni_form()\n"));

	VALID_FORM_CHECK(ni_form);

	if (RISfrm_user_init_ni_form)
	{
		FRM_DBG(("calling RISfrm_user_init_ni_form()\n"));
		RISfrm_user_init_ni_form(ni_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_ni_form(
	int	called_by_user)
{
	int	sts;

	FRM_DBG(("RISfrm_display_ni_form(called_by_user:%d)\n",called_by_user));


	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!ni_form)
	{
		sts = FIf_new(NI_FORM, NI_FORM_FILE, RISfrm_notification_routine,
			&ni_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_NI_FORM, sts);
			return RIS_forms_error.error;
		}
#if defined(WIN32)
		FIf_SetDefaultButton(ni_form, FI_EXECUTE);
		FIg_set_text(ni_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));
#endif
		FIfld_set_max_num_chars(ni_form, NI_SCHNAME_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
		FIfld_set_max_num_chars(ni_form, NI_USRPASS_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
	}

	if (!RISfrm_ni_form_displayed())
	{
		ni_msg->str[0] = 0;
		ni_msg->count = 0;
		ni_msg->msg_fld_label = NI_MSG_FIELD;
		ni_msg->fp = ni_form;

		DISPLAY_HELP_BUTTON(ni_form);

		/*
		**	If called directly by a user, display the message,
		**	otherwise, RISfrm_notification will display the message
		*/
		strcpy(ni_msg->str, MSG(RISUTL_I_SELECT_ACTION));
		if (called_by_user) RISfrm_display_msgs(); 

		/*
		**	If called directly by a user, call their init routine,
		**	otherwise, the schema_mgr form will call it
		*/
		if (called_by_user) RISfrm_call_user_init_ni_form();

		sts = FIf_display (ni_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_NI_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

static void update_ni_form(
	ris_schema_info	*schemap)
{
	/*
	**	This routine is called internally when ever the schname changes.
	**	It should update every thing on the form that needs updating
	**	except the schname_field()
	*/

	ris_db_info *dbp;

	FRM_DBG(("update_ni_form(schemap:0x%x)\n",schemap));

	if (schemap)
	{
		if (((dbp = RISfrm_db_from_schema(schemap)) != NULL) &&
			(dbp->dtype == 'O' || dbp->dtype == 'D' ||
                         dbp->dtype == 'Y' || dbp->dtype == 'M' 
									|| dbp->dtype == '4'))
		{
			enable_osuser_button();
		}
		else
		{
			disable_osuser_button();
			disable_group(MODIFY_OSUSER);
		}
		update_groups(schemap);
	}
	else
	{
		enable_osuser_button();
		clear_groups();
	}
}

/******************************************************************************/

extern void RISfrm_update_ni_form(
	ris_schema_info	*schemap)
{
	/*
	**	This routine is called by other forms to update this form.  It should
	**	update the schname field, then call the internal update function.
	*/

	FRM_DBG(("RISfrm_update_ni_form(schemap:0x%x)\n",schemap));

	VALID_FORM_CHECK(ni_form);

	if (schemap)
	{
		update_schname_field(schemap->schname);
	}
	else
	{
		clear_schname_field();
	}

	update_ni_form(schemap);
}

/******************************************************************************/

extern void RISfrm_clear_ni_form()
{
	FRM_DBG(("RISfrm_clear_ni_form()\n"));

	VALID_FORM_CHECK(ni_form);

	clear_schname_field();
	clear_usrname_field();
	clear_usrpass_field();
	clear_usrpass_button();
	clear_node_button();
	clear_osuser_button();
	disable_groups();
}

/*******************************************************************************
******************** USER FUNCTIONS ********************************************
*******************************************************************************/

extern int RISfrm_ni_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_ni_form_displayed()\n"));

	if (!ni_form)
	{
		return 0;
	}
	FIf_is_displayed(ni_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_ni_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_ni_form()\n"));

	if (RISfrm_ni_form_displayed())
	{
		sts = FIf_erase(ni_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_NI_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_ni_form();
		if (RISfrm_sd_form_displayed())
			RISfrm_clear_sd_node_info_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
******************** USER FUNCTIONS ********************************************
*******************************************************************************/

extern int RISAPI RISXfrm_node_info_form_displayed()
{
	return RISfrm_ni_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_node_info_form()
{
	return RISfrm_display_ni_form(CALLED_BY_USER);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_node_info_form()
{
	return RISfrm_erase_ni_form();
}

/******************************************************************************/
