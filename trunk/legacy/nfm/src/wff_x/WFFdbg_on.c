#include "machine.h"
#include "WFF.h"
#include "WFFdebug.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

long NFIdebug_on_off ()
  {
	long	status;
	static	char *fname = "NFIdebug_on_off";
	Form    debug_form;

	struct	WFFdbg_st *dbg;

	/*  External functions  */


	extern	void _WFFnotify ();

	_NFIdebug ((fname, "entering ...\n"));

	if ((dbg = (struct WFFdbg_st *) malloc
		(sizeof (struct WFFdbg_st))) == NULL)
	  {
		_NFIdebug ((fname,
			"malloc failed; size = <%d>\n", sizeof (struct WFFdbg_st)));
                status = NFI_E_MALLOC;
		ERRload_struct (NFI, status, "%d", sizeof (struct WFFdbg_st));
		_NFIdebug ((fname, "returning FAILURE\n"));
		return (status);
	  }

	/*  Initialize the debug structure  */

	dbg->type = WFF_DEBUG_TYPE;
	dbg->flag1 = WFFglobal.WFFserver.flag1;           /* WFF */
	dbg->flag2 = WFFglobal.WFFserver.flag2;           /* NFM */
	dbg->flag3 = WFFglobal.WFFserver.flag3;           /* SQL */
	dbg->flag4 = WFFglobal.WFFserver.flag4;           /* MEM */
	dbg->flag5 = WFFglobal.WFFserver.flag5;           /* ERR */
	strncpy (dbg->file1, WFFglobal.WFFserver.file1,
                 sizeof  (dbg->file1) - 1);
	strncpy (dbg->file2, WFFglobal.WFFserver.file2,
                 sizeof (dbg->file2) - 1);
	strncpy (dbg->file3, WFFglobal.WFFserver.file3,
                 sizeof (dbg->file3) - 1);
	strncpy (dbg->file4, WFFglobal.WFFserver.file4,
                 sizeof (dbg->file4) - 1);
	strncpy (dbg->file5, WFFglobal.WFFserver.file5,
                 sizeof (dbg->file5) - 1);

	FIf_new (DEBUG_LABEL,
		 DEBUG_FORM, _WFFnotify, &(debug_form));
	_WFFcenter_form (debug_form, -1, Y_FORM_POS);

	FIg_set_text (debug_form, TITLE,
		"Define I/NFM Debug Mode");

	FIg_set_text (debug_form, CKBOX1, "WFF");
	FIg_set_state (debug_form, CKBOX1, dbg->flag1);

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for the SCO - CRN 25 Feb 94	*/
	FIg_set_font(debug_form, FIELD1, "7x13bold", 15);
#endif
	FIfld_set_text (debug_form, FIELD1, 0, 0, dbg->file1, FALSE);

	FIg_set_text (debug_form, CKBOX2, "NFM");
	FIg_set_state (debug_form, CKBOX2, dbg->flag2);
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for the SCO - CRN 25 Feb 94	*/
	FIg_set_font(debug_form, FIELD2, "7x13bold", 15);
#endif
	FIfld_set_text (debug_form, FIELD2, 0, 0, dbg->file2, FALSE);

	FIg_set_text (debug_form, CKBOX3, "SQL");
	FIg_set_state (debug_form, CKBOX3, dbg->flag3);
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for the SCO - CRN 25 Feb 94	*/
	FIg_set_font(debug_form, FIELD3, "7x13bold", 15);
#endif
	FIfld_set_text (debug_form, FIELD3, 0, 0, dbg->file3, FALSE);

	FIg_set_text (debug_form, CKBOX4, "MEM");
	FIg_set_state (debug_form, CKBOX4, dbg->flag4);
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for the SCO - CRN 25 Feb 94	*/
	FIg_set_font(debug_form, FIELD4, "7x13bold", 15);
#endif
	FIfld_set_text (debug_form, FIELD4, 0, 0, dbg->file4, FALSE);

	FIg_set_text (debug_form, CKBOX5, "ERR");
	FIg_set_state (debug_form, CKBOX5, dbg->flag5);
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for the SCO - CRN 25 Feb 94	*/
	FIg_set_font(debug_form, FIELD5, "7x13bold", 15);
#endif
	FIfld_set_text (debug_form, FIELD5, 0, 0, dbg->file5, FALSE);

	FIf_set_user_pointer (debug_form, (char *) dbg);

	FIf_display (debug_form);

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


long _NFIdebug_notify (g_label, value, form)
  int		g_label;
  double	value;
  Form		form;
  {
	int		sel, pos;
	long	status = NFI_S_SUCCESS;

	struct	WFFdbg_st *dbg;

	static	char *fname = "_NFIdebug_notify";

	_NFIdebug ((fname, "g_label = <%d>\n", g_label));
	_NFIdebug ((fname, "value   = <%d>\n", value));

	FIf_get_user_pointer (form, &dbg);

	switch (g_label)
	  {
		case FI_CANCEL:

			/*  Delete the form  */

			if (dbg) free (dbg);
		        if (form != NULL)
			    FIf_delete (form);

			/*  Enable the main form  */

			if (WFFglobal.main_form != NULL)
			  {
				FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
				_WFFprocess_event (REFRESH_EVENT);
			  }

			break;

		case FI_ACCEPT:

			/*  Get the settings of the checkboxes and fields  */

			/*  WFF  */

                         _NFMdebug_st.NFIdebug_on = WFFglobal.WFFserver.flag1 = 
                                     WFFglobal.debug_on = dbg->flag1;
                        strncpy (WFFglobal.debug_file, dbg->file1,
                                  NFM_DEBUG_FILE_SIZE - 1);
                        strncpy (_NFMdebug_st.NFIdebug_file, dbg->file1,
                                  NFM_DEBUG_FILE_SIZE - 1);
                        strncpy (WFFglobal.WFFserver.file1, dbg->file1,
                                  NFM_DEBUG_FILE_SIZE - 1);

			/*  NFM  */

                        _NFMdebug_st.NFMdebug_on = WFFglobal.WFFserver.flag2 = dbg->flag2;
                        strncpy (_NFMdebug_st.NFMdebug_file, dbg->file2,
                                  NFM_DEBUG_FILE_SIZE - 1);
                        strncpy (WFFglobal.WFFserver.file2, dbg->file2,
                                  NFM_DEBUG_FILE_SIZE - 1);

			/*  SQL  */

                         _NFMdebug_st.SQLdebug_on = WFFglobal.WFFserver.flag3 = dbg->flag3;
                        strncpy (_NFMdebug_st.SQLdebug_file, dbg->file3,
                                  NFM_DEBUG_FILE_SIZE - 1);
                        strncpy (WFFglobal.WFFserver.file3, dbg->file3,
                                  NFM_DEBUG_FILE_SIZE - 1);

			/*  MEM  */

                        _NFMdebug_st.MEMdebug_on = WFFglobal.WFFserver.flag4 = dbg->flag4;
                        strncpy (_NFMdebug_st.MEMdebug_file, dbg->file4,
                                  NFM_DEBUG_FILE_SIZE - 1);
                        strncpy (WFFglobal.WFFserver.file4, dbg->file4,
                                  NFM_DEBUG_FILE_SIZE - 1);

			/*  ERR  */

                         _NFMdebug_st.ERRdebug_on = 
                                     WFFglobal.WFFserver.flag5 = dbg->flag5;
                        strncpy (_NFMdebug_st.ERRdebug_file, dbg->file5,
                                  NFM_DEBUG_FILE_SIZE - 1);
                        strncpy (WFFglobal.WFFserver.file5, dbg->file5,
                                  NFM_DEBUG_FILE_SIZE - 1);

			/*  Delete the form  */

			if (dbg) free (dbg);
			if (form != NULL)
			    FIf_delete (form);

			/*  Enable the main form  */

			if (WFFglobal.main_form != NULL)
			  {
				FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
				_WFFprocess_event (REFRESH_EVENT);
			  }

			break;

		case CKBOX1:
			FIg_get_state (form, g_label, &(dbg->flag1));
			break;

		case CKBOX2:
			FIg_get_state (form, g_label, &(dbg->flag2));
			break;

		case CKBOX3:
			FIg_get_state (form, g_label, &(dbg->flag3));
			break;

		case CKBOX4:
			FIg_get_state (form, g_label, &(dbg->flag4));
			break;

		case CKBOX5:
			FIg_get_state (form, g_label, &(dbg->flag5));
			break;

		case FIELD1:
			FIfld_get_text (form, g_label, 0, 0,
				sizeof (dbg->file1) - 1, dbg->file1, &sel, &pos);
			if ((strcmp (dbg->file1, "")) != 0)
			  {
				dbg->flag1 = TRUE;
				FIg_set_state (form, CKBOX1, TRUE);
			  }

			break;

		case FIELD2:
			FIfld_get_text (form, g_label, 0, 0,
				sizeof (dbg->file2) - 1, dbg->file2, &sel, &pos);
			if ((strcmp (dbg->file2, "")) != 0)
			  {
				dbg->flag2 = TRUE;
				FIg_set_state (form, CKBOX2, TRUE);
			  }

			break;

		case FIELD3:
			FIfld_get_text (form, g_label, 0, 0,
				sizeof (dbg->file3) - 1, dbg->file3, &sel, &pos);
			if ((strcmp (dbg->file3, "")) != 0)
			  {
				dbg->flag3 = TRUE;
				FIg_set_state (form, CKBOX3, TRUE);
			  }

			break;

		case FIELD4:
			FIfld_get_text (form, g_label, 0, 0,
				sizeof (dbg->file4) - 1, dbg->file4, &sel, &pos);
			if ((strcmp (dbg->file4, "")) != 0)
			  {
				dbg->flag4 = TRUE;
				FIg_set_state (form, CKBOX4, TRUE);
			  }

			break;

		case FIELD5:
			FIfld_get_text (form, g_label, 0, 0,
				sizeof (dbg->file5) - 1, dbg->file5, &sel, &pos);
			if ((strcmp (dbg->file5, "")) != 0)
			  {
				dbg->flag5 = TRUE;
				FIg_set_state (form, CKBOX5, TRUE);
			  }

			break;
	  }

	_NFIdebug ((fname, " returning <0x%.8x>\n", status));
	return (status);
  }
