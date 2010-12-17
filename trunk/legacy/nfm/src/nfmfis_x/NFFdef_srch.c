
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "QUI.h"
#include "NFFmain_form.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFdefine_search_criteria (catalog)
  char   *catalog;
  {
    auto    long    status;
    auto    long    config_mask;
    auto    char    title[NFF_MAX_MESSAGE];
    auto    char    active_search[NFM_REPORTNAME + 1];
    auto    QFONT   qfont;
    auto    QCOLOR  qcolor;
    static  char    *fname = "NFFdefine_search_criteria";

    _NFIdebug ((fname, "catalog = <%s>\n", catalog));

    if ((status = (long) UMSGetByNum
        (title, NFT_P_DEFINE_SEARCH, "%s", catalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Define Search Criteria");
      }

    _NFIdebug ((fname, "title = <%s>\n", title));

    /* fonts SSRS 28 Jan 94 */
#ifdef OS_SCO_UNIX
    strcpy (qfont.title_font, "7x13");
#else
    strcpy (qfont.title_font, "swiss742");
#endif
    qfont.title_bodysize = 20.00;
    /* fonts SSRS 28 Jan 94 */
#ifdef OS_SCO_UNIX
    strcpy (qfont.title_font, "7x13bold");
#else
    strcpy (qfont.label_font, "swiss742b");
#endif
    qfont.label_bodysize = 18.00;
    /* fonts SSRS 28 Jan 94 */
#ifdef OS_SCO_UNIX
    strcpy (qfont.fields_font, "7x13");
#else
    strcpy (qfont.fields_font, "mono821");
#endif
    qfont.fields_bodysize = 18.00;
    /* fonts SSRS 28 Jan 94 */
#ifdef OS_SCO_UNIX
    strcpy (qfont.fields_font, "7x13bold");
#else
    strcpy (qfont.operators_font, "mono821b");
#endif
    qfont.operators_bodysize = 18.00;

    qcolor.buttons_on = FI_YELLOW;
    qcolor.buttons_off = FI_BLACK;
    qcolor.and_or_on = FI_YELLOW;
    qcolor.and_or_off = FI_YELLOW;
    qcolor.revision_on = FI_YELLOW;
    qcolor.revision_off = FI_YELLOW;
    qcolor.checkin_on = FI_YELLOW;
    qcolor.checkin_off = FI_YELLOW;
    qcolor.fields_on = FI_YELLOW;
    qcolor.fields_off = FI_BLACK;
    qcolor.checkboxes_on = FI_YELLOW;
    qcolor.checkboxes_off = FI_BLACK;

    /*  See if this is an administrator  */

    config_mask = BEZEL_MESSAGE_STYLE_MASK;

    if (NFMRglobal.administrator == TRUE)
        config_mask |= OWNER_TOGGLE_MASK;

    _NFIdebug ((fname, "config_mask = 0x%.8x\n", config_mask));

    /*  Only use the active search if the toggle is ACTIVE  */

    if (NFFglobal.search_active == TRUE)
        strcpy (active_search, NFFglobal.search);
    else
        strcpy (active_search, "");

    if ((status = QUIinit_form
        (catalog, title, "Criteria Name", active_search,
        config_mask, &qfont, &qcolor, QDB, "NFM", NFFglobal.username,
        _NFFnotify, NFFglobal.forms[MAIN_LABEL], SEARCH_FIELD,
        NFFglobal.search, &(NFFglobal.current_form))) != QUI_S_SUCCESS)
      {
        _NFIdebug ((fname, "QUIinit_form = <0x%.8x>\n", status));
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
