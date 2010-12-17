
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFdebug.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFdebug ()
  {
    auto    long   status;
    auto    char   title[NFF_MAX_MESSAGE];
    auto    struct NFFdbg_st *dbg;
    static  char   *fname = "NFFdebug";

    _NFIdebug ((fname, "entering ...\n"));

    if ((dbg = (struct NFFdbg_st *) malloc
        (sizeof (struct NFFdbg_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFdbg_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFdbg_st));
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    /*  Initialize the debug structure  */

    dbg->flag1 = _NFMdebug_st.NFIdebug_on;
    dbg->flag2 = _NFMdebug_st.NFMRdebug_on;
    dbg->flag3 = _NFMdebug_st.NETCdebug_on;
    dbg->flag4 = _NFMdebug_st.MEMdebug_on;
    dbg->flag5 = _NFMdebug_st.ERRdebug_on;
    dbg->flag6 = _NFMdebug_st.NETSdebug_on;
    dbg->flag7 = _NFMdebug_st.NFMSdebug_on;
    dbg->flag8 = _NFMdebug_st.NFMdebug_on;
    dbg->flag9 = _NFMdebug_st.SQLdebug_on;
    dbg->flag10 = _NFMdebug_st.MEMdebug_on;
    dbg->flag11 = _NFMdebug_st.UTIdebug_on;
    dbg->flag12 = _NFMdebug_st.ERRdebug_on;
    strncpy (dbg->file1, _NFMdebug_st.NFIdebug_file, sizeof (dbg->file1) - 1);
    strncpy (dbg->file2, _NFMdebug_st.NFMRdebug_file, sizeof (dbg->file2) - 1);
    strncpy (dbg->file3, _NFMdebug_st.NETCdebug_file, sizeof (dbg->file3) - 1);
    strncpy (dbg->file4, _NFMdebug_st.MEMdebug_file, sizeof (dbg->file4) - 1);
    strncpy (dbg->file5, _NFMdebug_st.ERRdebug_file, sizeof (dbg->file5) - 1);
    strncpy (dbg->file6, _NFMdebug_st.NETSdebug_file, sizeof (dbg->file6) - 1);
    strncpy (dbg->file7, _NFMdebug_st.NFMSdebug_file, sizeof (dbg->file7) - 1);
    strncpy (dbg->file8, _NFMdebug_st.NFMdebug_file, sizeof (dbg->file8) - 1);
    strncpy (dbg->file9, _NFMdebug_st.SQLdebug_file, sizeof (dbg->file9) - 1);
    strncpy (dbg->file10, _NFMdebug_st.MEMdebug_file,
        sizeof (dbg->file10) - 1);
    strncpy (dbg->file11, _NFMdebug_st.UTIdebug_file,
        sizeof (dbg->file11) - 1);
    strncpy (dbg->file12, _NFMdebug_st.ERRdebug_file,
        sizeof (dbg->file12) - 1);

    FIf_new (DEBUG_LABEL,
        DEBUG_FORM, _NFFnotify, &(NFFglobal.debug_form));
    _NFFcenter_form (NFFglobal.debug_form, -1, Y_FORM_POS);

    if ((status = (long) UMSGetByNum
        (title, NFT_P_SERVER_DEBUG, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Define I/NFM Debug Mode");
      }

    FIg_set_text (NFFglobal.debug_form, TITLE, title);

    FIg_set_text (NFFglobal.debug_form, CKBOX1, "NFF");
    FIg_set_state (NFFglobal.debug_form, CKBOX1, dbg->flag1);
#ifdef OS_SCO_UNIX
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( NFFglobal.debug_form, FIELD1, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.debug_form, FIELD1, 0, 0, dbg->file1, FALSE);

    FIg_set_text (NFFglobal.debug_form, CKBOX2, "NFMR");
    FIg_set_state (NFFglobal.debug_form, CKBOX2, dbg->flag2);
#ifdef OS_SCO_UNIX
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( NFFglobal.debug_form, FIELD2, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.debug_form, FIELD2, 0, 0, dbg->file2, FALSE);

    FIg_set_text (NFFglobal.debug_form, CKBOX3, "NETC");
    FIg_set_state (NFFglobal.debug_form, CKBOX3, dbg->flag3);
#ifdef OS_SCO_UNIX
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( NFFglobal.debug_form, FIELD3, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.debug_form, FIELD3, 0, 0, dbg->file3, FALSE);

    FIg_set_text (NFFglobal.debug_form, CKBOX4, "MEMC");
    FIg_set_state (NFFglobal.debug_form, CKBOX4, dbg->flag4);
#ifdef OS_SCO_UNIX
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( NFFglobal.debug_form, FIELD4, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.debug_form, FIELD4, 0, 0, dbg->file4, FALSE);

    FIg_set_text (NFFglobal.debug_form, CKBOX5, "ERRC");
    FIg_set_state (NFFglobal.debug_form, CKBOX5, dbg->flag5);
#ifdef OS_SCO_UNIX
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( NFFglobal.debug_form, FIELD5, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.debug_form, FIELD5, 0, 0, dbg->file5, FALSE);

    FIg_set_text (NFFglobal.debug_form, CKBOX6, "NETS");
    FIg_set_state (NFFglobal.debug_form, CKBOX6, dbg->flag6);
#ifdef OS_SCO_UNIX
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( NFFglobal.debug_form, FIELD6, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.debug_form, FIELD6, 0, 0, dbg->file6, FALSE);

    FIg_set_text (NFFglobal.debug_form, CKBOX7, "NFMS");
    FIg_set_state (NFFglobal.debug_form, CKBOX7, dbg->flag7);
#ifdef OS_SCO_UNIX
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( NFFglobal.debug_form, FIELD7, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.debug_form, FIELD7, 0, 0, dbg->file7, FALSE);

    FIg_set_text (NFFglobal.debug_form, CKBOX8, "NFM");
    FIg_set_state (NFFglobal.debug_form, CKBOX8, dbg->flag8);
#ifdef OS_SCO_UNIX
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( NFFglobal.debug_form, FIELD8, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.debug_form, FIELD8, 0, 0, dbg->file8, FALSE);

    FIg_set_text (NFFglobal.debug_form, CKBOX9, "SQL");
    FIg_set_state (NFFglobal.debug_form, CKBOX9, dbg->flag9);
#ifdef OS_SCO_UNIX
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( NFFglobal.debug_form, FIELD9, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.debug_form, FIELD9, 0, 0, dbg->file9, FALSE);

    FIg_set_text (NFFglobal.debug_form, CKBOX10, "MEMS");
    FIg_set_state (NFFglobal.debug_form, CKBOX10, dbg->flag10);
#ifdef OS_SCO_UNIX
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( NFFglobal.debug_form, FIELD10, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.debug_form, FIELD10, 0, 0, dbg->file10, FALSE);

    FIg_set_text (NFFglobal.debug_form, CKBOX11, "UTI");
    FIg_set_state (NFFglobal.debug_form, CKBOX11, dbg->flag11);
#ifdef OS_SCO_UNIX
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( NFFglobal.debug_form, FIELD11, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.debug_form, FIELD11, 0, 0, dbg->file11, FALSE);

    FIg_set_text (NFFglobal.debug_form, CKBOX12, "ERRS");
    FIg_set_state (NFFglobal.debug_form, CKBOX12, dbg->flag12);
#ifdef OS_SCO_UNIX
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( NFFglobal.debug_form, FIELD12, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.debug_form, FIELD12, 0, 0, dbg->file12, FALSE);

    FIf_set_user_pointer (NFFglobal.debug_form, (char *) dbg);

    FIf_display (NFFglobal.debug_form);
/*
    FIg_start_seq (NFFglobal.debug_form, FIELD1);
*/
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFdebug_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    auto    int     sel, pos;
    auto    long    status = NFI_S_SUCCESS;
    auto    int     toggles[NFM_DEBUG_SUBSYSTEMS];
    auto    char    files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];
    auto    struct  NFFdbg_st *dbg;
    static  char    *fname = "_NFFdebug_notify";

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    FIf_get_user_pointer (*form, &dbg);

    switch (g_label)
      {
        case FI_CANCEL:

            /*  Delete the form  */

            if (dbg) free (dbg);
            FIf_delete (*form);
            *form = NFFglobal.debug_form = NULL;
            break;

        case FI_ACCEPT:

            /*  NFI  */

            toggles[0] = dbg->flag1;
            strncpy (files[0], dbg->file1, NFM_DEBUG_FILE_SIZE - 1);

            /*  NFMR  */

            toggles[2] = dbg->flag2;
            strncpy (files[2], dbg->file2, NFM_DEBUG_FILE_SIZE - 1);

            /*  NETC  */

            toggles[3] = dbg->flag3;
            strncpy (files[3], dbg->file3, NFM_DEBUG_FILE_SIZE - 1);

            /*  MEMC  */

            toggles[4] = dbg->flag4;
            strncpy (files[4], dbg->file4, NFM_DEBUG_FILE_SIZE - 1);

            /*  ERRC  */

            toggles[5] = dbg->flag5;
            strncpy (files[5], dbg->file5, NFM_DEBUG_FILE_SIZE - 1);

            /*  NETS  */

            toggles[6] = dbg->flag6;
            strncpy (files[6], dbg->file6, NFM_DEBUG_FILE_SIZE - 1);

            /*  NFMS  */

            toggles[7] = dbg->flag7;
            strncpy (files[7], dbg->file7, NFM_DEBUG_FILE_SIZE - 1);

            /*  NFM  */

            toggles[8] = dbg->flag8;
            strncpy (files[8], dbg->file8, NFM_DEBUG_FILE_SIZE - 1);

            /*  SQL  */

            toggles[9] = dbg->flag9;
            strncpy (files[9], dbg->file9, NFM_DEBUG_FILE_SIZE - 1);

            /*  MEMS  */

            toggles[11] = dbg->flag10;
            strncpy (files[11], dbg->file10, NFM_DEBUG_FILE_SIZE - 1);

            /*  UTI  */

            toggles[12] = dbg->flag11;
            strncpy (files[12], dbg->file11, NFM_DEBUG_FILE_SIZE - 1);

            /*  ERRS  */

            toggles[14] = dbg->flag12;
            strncpy (files[14], dbg->file12, NFM_DEBUG_FILE_SIZE - 1);

            _NFIdebug ((fname, "calling NFMRall_debug ...\n"));
            status = NFMRall_debug (toggles, files);
            _NFIdebug ((fname, "NFMRall_debug = <0x%.8x>\n", status));

            if (status == NFM_S_SUCCESS)
                status = NFI_S_SUCCESS;

            /*  Delete the form  */

            if (dbg) free (dbg);
            FIf_delete (*form);
            *form = NFFglobal.debug_form = NULL;

            break;

        case CKBOX1:
            FIg_get_state (*form, g_label, &(dbg->flag1));
            break;

        case CKBOX2:
            FIg_get_state (*form, g_label, &(dbg->flag2));
            break;

        case CKBOX3:
            FIg_get_state (*form, g_label, &(dbg->flag3));
            break;

        case CKBOX4:
            FIg_get_state (*form, g_label, &(dbg->flag4));
            break;

        case CKBOX5:
            FIg_get_state (*form, g_label, &(dbg->flag5));
            break;

        case CKBOX6:
            FIg_get_state (*form, g_label, &(dbg->flag6));
            break;

        case CKBOX7:
            FIg_get_state (*form, g_label, &(dbg->flag7));
            break;

        case CKBOX8:
            FIg_get_state (*form, g_label, &(dbg->flag8));
            break;

        case CKBOX9:
            FIg_get_state (*form, g_label, &(dbg->flag9));
            break;

        case CKBOX10:
            FIg_get_state (*form, g_label, &(dbg->flag10));
            break;

        case CKBOX11:
            FIg_get_state (*form, g_label, &(dbg->flag11));
            break;

        case CKBOX12:
            FIg_get_state (*form, g_label, &(dbg->flag12));
            break;

        case FIELD1:
            FIfld_get_text (*form, g_label, 0, 0,
                sizeof (dbg->file1) - 1, dbg->file1, &sel, &pos);
            if ((strcmp (dbg->file1, "")) != 0)
              {
                dbg->flag1 = TRUE;
                FIg_set_state (*form, CKBOX1, TRUE);
              }

            break;

        case FIELD2:
            FIfld_get_text (*form, g_label, 0, 0,
                sizeof (dbg->file2) - 1, dbg->file2, &sel, &pos);
            if ((strcmp (dbg->file2, "")) != 0)
              {
                dbg->flag2 = TRUE;
                FIg_set_state (*form, CKBOX2, TRUE);
              }

            break;

        case FIELD3:
            FIfld_get_text (*form, g_label, 0, 0,
                sizeof (dbg->file3) - 1, dbg->file3, &sel, &pos);
            if ((strcmp (dbg->file3, "")) != 0)
              {
                dbg->flag3 = TRUE;
                FIg_set_state (*form, CKBOX3, TRUE);
              }

            break;

        case FIELD4:
            FIfld_get_text (*form, g_label, 0, 0,
                sizeof (dbg->file4) - 1, dbg->file4, &sel, &pos);
            if ((strcmp (dbg->file4, "")) != 0)
              {
                dbg->flag4 = TRUE;
                FIg_set_state (*form, CKBOX4, TRUE);
              }

            break;

        case FIELD5:
            FIfld_get_text (*form, g_label, 0, 0,
                sizeof (dbg->file5) - 1, dbg->file5, &sel, &pos);
            if ((strcmp (dbg->file5, "")) != 0)
              {
                dbg->flag5 = TRUE;
                FIg_set_state (*form, CKBOX5, TRUE);
              }

            break;

        case FIELD6:
            FIfld_get_text (*form, g_label, 0, 0,
                sizeof (dbg->file6) - 1, dbg->file6, &sel, &pos);
            if ((strcmp (dbg->file6, "")) != 0)
              {
                dbg->flag6 = TRUE;
                FIg_set_state (*form, CKBOX6, TRUE);
              }

            break;

        case FIELD7:
            FIfld_get_text (*form, g_label, 0, 0,
                sizeof (dbg->file7) - 1, dbg->file7, &sel, &pos);
            if ((strcmp (dbg->file7, "")) != 0)
              {
                dbg->flag7 = TRUE;
                FIg_set_state (*form, CKBOX7, TRUE);
              }

            break;

        case FIELD8:
            FIfld_get_text (*form, g_label, 0, 0,
                sizeof (dbg->file8) - 1, dbg->file8, &sel, &pos);
            if ((strcmp (dbg->file8, "")) != 0)
              {
                dbg->flag8 = TRUE;
                FIg_set_state (*form, CKBOX8, TRUE);
              }

            break;

        case FIELD9:
            FIfld_get_text (*form, g_label, 0, 0,
                sizeof (dbg->file9) - 1, dbg->file9, &sel, &pos);
            if ((strcmp (dbg->file9, "")) != 0)
              {
                dbg->flag9 = TRUE;
                FIg_set_state (*form, CKBOX9, TRUE);
              }

            break;

        case FIELD10:
            FIfld_get_text (*form, g_label, 0, 0,
                sizeof (dbg->file10) - 1, dbg->file10, &sel, &pos);
            if ((strcmp (dbg->file10, "")) != 0)
              {
                dbg->flag10 = TRUE;
                FIg_set_state (*form, CKBOX10, TRUE);
              }

            break;

        case FIELD11:
            FIfld_get_text (*form, g_label, 0, 0,
                sizeof (dbg->file11) - 1, dbg->file11, &sel, &pos);
            if ((strcmp (dbg->file11, "")) != 0)
              {
                dbg->flag11 = TRUE;
                FIg_set_state (*form, CKBOX11, TRUE);
              }

            break;

        case FIELD12:
            FIfld_get_text (*form, g_label, 0, 0,
                sizeof (dbg->file12) - 1, dbg->file12, &sel, &pos);
            if ((strcmp (dbg->file12, "")) != 0)
              {
                dbg->flag12 = TRUE;
                FIg_set_state (*form, CKBOX12, TRUE);
              }

            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }
