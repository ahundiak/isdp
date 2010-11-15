/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:									frmdbs.c
**	AUTHORS:								Terry McIntyre
**	CREATION DATE:							11/90
**	ABSTRACT:
**	
**		The code to process the RIS databases code.
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Linda Wang
**	02/03/95 Removed NTJ specific changes. rlk
*/
 
/*
**	INCLUDES
*/
#include "forms.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmdbs_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "fi.prt"
#include "frmcrsch.prt"
#include "frmdbs.prt"
#include "frmerror.prt"
#include "frmfile.prt"
#include "frmmsg.prt"
#include "frmntfy.prt"
#include "frmutil.prt"
#include "sys.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif




/*
**	DEFINES
*/

/*
**	VARIABLES
*/
static	 Form		rd_form = 0;
static	RISfrm_msg	*rd_msg = &RISfrm_msgs[RD_FORM_MSG];

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** RD_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(rd_form, RD_MSG_FIELD, 0, 0, (char *)msg, 0);
}

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(rd_form, RD_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
************** RD_DBS_MCF ******************************************************
*******************************************************************************/

static void load_dbs_mcf()
{
	int				row;
	ris_db_info			*db;
	RISfrm_db_id	*db_idp;

	FRM_DBG(("load_dbs_mcf()\n"));

	for (db = RISfrm_dbs, row = 0; db; db = db->next)
	{
		if ((db_idp = RISfrm_get_db_id(db)) == NULL) continue;

		FIfld_set_text(rd_form, RD_DBS_MCF, row, 0, db_idp->type, 0);
		FIfld_set_text(rd_form, RD_DBS_MCF, row, 1, db_idp->name, 0);
		FIfld_set_text(rd_form, RD_DBS_MCF, row, 2, db_idp->location, 0);
		row++;
	}
}

/******************************************************************************/

static RISfrm_db_id *get_selected_db_id()
{
	int				row;
	int				position;
	int				sel_flag;
	int				r_pos;

	static  RISfrm_db_id	db_id;

	FRM_DBG(("get_selected_db_id()\n"));

	FIfld_get_active_row(rd_form, RD_DBS_MCF, &row, &position);

	FImcf_get_select(rd_form, RD_DBS_MCF, row, &sel_flag);
	if (!sel_flag) return NULL;

	memset((char *)&db_id, 0, sizeof(db_id));
	FIfld_get_text(rd_form, RD_DBS_MCF, row, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)db_id.type, &sel_flag, &r_pos);
	FIfld_get_text(rd_form, RD_DBS_MCF, row, 1, RIS_MAX_PATH_SIZE,
		(unsigned char *)db_id.name, &sel_flag, &r_pos);
	FIfld_get_text(rd_form, RD_DBS_MCF, row, 2, FRM_MAX_LOCATION_SIZE,
		(unsigned char *)db_id.location, &sel_flag, &r_pos);

	return &db_id;
}

/******************************************************************************/

static void process_dbs_mcf()
{
	ris_db_info		*dbp;
	RISfrm_db_id	*db_idp;

	FRM_DBG(("process_dbs_mcf()\n"));

	db_idp = get_selected_db_id();
	dbp = RISfrm_get_db(db_idp);
	if (RISfrm_cs_form_displayed())
	{
		RISfrm_update_cs_form_by_db(dbp);
	}
}

/******************************************************************************/

static void clear_dbs_mcf()
{
	FRM_DBG(("clear_dbs_mcf()\n"));
	RISfrm_clear_multi_row_field(rd_form, RD_DBS_MCF);
}

/*******************************************************************************
************** RD_FORM *********************************************************
*******************************************************************************/

extern void RISfrm_process_rd_form(
	int	g_label)
{
	FRM_DBG(("RISfrm_process_rd_form(g_label:%d)\n", g_label));

	if (!rd_form) return;

	switch (g_label)
	{
		case RD_DBS_MCF:
			process_dbs_mcf();
			/* NO break */

		case FI_CANCEL:
			RISfrm_erase_rd_form();
			break;
	}
}

/******************************************************************************/

static void update_rd_form()
{
	FRM_DBG(("update_rd_form()\n"));

	if (!rd_form) return;

	if (!RISfrm_file_info_up_to_date)
	{
		update_msg_field(MSG(RISUTL_I_READING_SCHFILE));
		RISfrm_read_schema_file();
		clear_msg_field();
		if (RIS_forms_error.error && RISfrm_report_error())
		{
			switch(RIS_forms_error.error)
			{
			}
		}
	}

	load_dbs_mcf();
}

/******************************************************************************/

static void clear_rd_form()
{
	FRM_DBG(("clear_rd_form()\n"));

	if (!rd_form) return;

	clear_dbs_mcf();
}

/******************************************************************************/

extern int RISfrm_rd_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_rd_form_displayed()\n"));

	if (!rd_form) return 0;

	FIf_is_displayed(rd_form, &form_displayed);
	return form_displayed;
}

/******************************************************************************/

extern int RISfrm_display_rd_form()
{
	int	sts;

	FRM_DBG(("RISfrm_display_rd_form()\n"));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!rd_form)
	{
		sts = FIf_new(RD_FORM, RD_FORM_FILE, RISfrm_notification_routine,
			&rd_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_RD_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	if (!RISfrm_rd_form_displayed())
	{
		rd_msg->str[0] = 0;
		rd_msg->count = 0;
		rd_msg->msg_fld_label = RD_MSG_FIELD;
		rd_msg->fp = rd_form;

		DISPLAY_HELP_BUTTON(rd_form);

		sts = FIf_display (rd_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_RD_FORM, sts);
			return RIS_forms_error.error;
		}
		update_rd_form();
		RISfrm_display_msgs();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern int RISfrm_erase_rd_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_rd_form()\n"));

	if (RISfrm_rd_form_displayed())
	{
		sts = FIf_erase(rd_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_RD_FORM, sts);
			return RIS_forms_error.error;
		}
		clear_rd_form();
		RISfrm_clear_cs_display_dbs_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISAPI RISXfrm_ris_dbs_form_displayed()
{
	return RISfrm_rd_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_ris_dbs_form()
{
	return RISfrm_display_rd_form();
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_ris_dbs_form()
{
	return RISfrm_erase_rd_form();
}

/******************************************************************************/
