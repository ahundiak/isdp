#include "machine.h"
#include "QUI.h"

long _QUIload_query (form)
  Form    form;
  {
    auto    long    status;
    auto    char    desc[NFM_REPORTDESC + 1];
    auto    char    owner[NFM_USERNAME + 1];
    auto    struct  NFMquery_info query_info;
    static  char    *fname = "_QUIload_query";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Initialize the query structure  */

    query_info.select_clause = NULL;
    query_info.from_clause = NULL;
    query_info.where_clause = NULL;
    query_info.order_by_clause = NULL;
    query_info.prompts = NULL;

    QUIform_message (form, QUI_I_LOAD, NULL);

    if ((status = NFMRretrieve_query_info (QUIglobal.query_name,
        "W", "NFM", "", desc, owner, &query_info)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRretrieve_query_info = <0x%.8x>\n", status));
        NFMfree_query_struct (&query_info);
        QUIerase_message (form);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    /*  Put the query description on the form  */

    FIfld_set_text (form, DESC_FIELD, 0, 0, desc, FALSE);

    /*  Set the owner toggle accordingly  */

    if ((strcmp (owner, "PUBLIC")) == 0)
        FIg_set_state_on (form, OWNER_TOGGLE);
    else
        FIg_set_state_off (form, OWNER_TOGGLE);

    /*  Parse the FROM clause and set old aliases  */
/*
    if ((status = _QUIparse_from_clause
        (query_info.from_clause)) != QUI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_QUIparse_from_clause = <0x%.8x>\n", status));
        NFMfree_query_struct (&query_info);
        QUIerase_message (form);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
*/
    /*  Load the definition onto the form  */

    if ((status = QUIload_definition
        (form, query_info.where_clause)) != QUI_S_SUCCESS)
      {
        _NFIdebug ((fname, "QUIload_definition = <0x%.8x>\n", status));
        NFMfree_query_struct (&query_info);
        QUIerase_message (form);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    /*  Free the stuff in the structure and erase the message  */

    NFMfree_query_struct (&query_info);
    QUIerase_message (form);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }
