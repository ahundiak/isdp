#include "machine.h"
#include "QUI.h"

long QUIsave_definition (form)
  Form    form;
  {
    auto    int     sel, rpos, state;
    auto    long    status;
    auto    long    attr_ctr, length;
    auto    char    alias[10];
    auto    char    operator[4];
    auto    char    alias_and_attrib[NFM_NAME + 10];
    auto    char    attribute[NFM_NAME + 1];
    auto    char    trio[160];
    auto    char    from_clause[QUI_MAX_ATTR_NUM * (NFM_CATALOGNAME + 3)];
    auto    char    *where_clause;
    auto    char    *select_clause = "*";
    auto    char    logical_op[20];
    auto    char    username[NFM_USERNAME + 1];
    auto    char    description[NFM_REPORTDESC + 1];
    auto    struct  NFMquery_info query_info;
    static  char    *fname = "QUIsave_definition";
    auto    char    nfm_date[100];
    auto    char    ris_date[100];

    nfm_date[0] = 0;
    ris_date[0] = 0;
    _NFIdebug ((fname, "entering ...\n"));

    /*  Make sure there is a name for the definition  */

    if ((strcmp (QUIglobal.query_name, "")) == 0)
      {
        _NFIdebug ((fname, "No name for the definition\n"));
        ERRload_struct (NFI, QUI_E_NO_QUERY_NAME, NULL);
        return (QUI_E_NO_QUERY_NAME);
      }

    /*  Make sure there is a WHERE clause definition  */

    _NFIdebug ((fname, "numofattr = <%d>\n", QUIglobal.QUI_numofattr));

    if (QUIglobal.QUI_numofattr == 0)
      {
        _NFIdebug ((fname, "No attributes have been selected\n"));
        ERRload_struct (NFI, QUI_E_NULL_DEFINITION, NULL);
        return (QUI_E_NULL_DEFINITION);
      }

    if ((where_clause = (char *) malloc (QUI_MIN_VALUE_LEN + 2)) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", QUI_MIN_VALUE_LEN + 2));
        ERRload_struct (NFI, QUI_E_MALLOC, "%d", QUI_MIN_VALUE_LEN + 2);
        return (QUI_E_MALLOC);
      }

    strcpy (where_clause,"(");
    length = QUI_MIN_VALUE_LEN;

    for (attr_ctr = 0; attr_ctr < QUIglobal.QUI_numofattr; attr_ctr++)
      {
        status = QUIget_alias_from_number
            (QUI_attrib_displayed[attr_ctr].catalog_no,
             QUI_attrib_displayed[attr_ctr].attrib_no, alias);
        if (status != QUI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "QUIget_alias_from_number = <0x%.8x>\n", status));
            if (where_clause) free (where_clause);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (status);
          }

        /*  Save data for the FROM clause  */

        status = QUIsave_from_data
            (QUI_attrib_displayed[attr_ctr].catalog_no,
             QUI_attrib_displayed[attr_ctr].attrib_no);
        if (status != QUI_S_SUCCESS)
          {
            _NFIdebug ((fname, "QUIsave_from_data = <0x%.8x>\n", status));
            if (where_clause) free (where_clause);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (status);
          }

        status = QUIget_attribute_from_number
            (QUI_attrib_displayed[attr_ctr].catalog_no,
             QUI_attrib_displayed[attr_ctr].attrib_no, attribute);
        if (status != QUI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "QUIget_attribute_from_number = <0x%.8x>\n", status));
            if (where_clause) free (where_clause);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (status);
          }

        sprintf(alias_and_attrib,"%s.%s", alias, attribute);

        if (!QUI_attrib_displayed[attr_ctr].value[0])
          {
            if (QUI_attrib_displayed[attr_ctr].data_type==QUI_CHAR_TYPE)
                strcpy(QUI_attrib_displayed[attr_ctr].value,"*");
            else
              if (QUI_attrib_displayed[attr_ctr].data_type==QUI_TIMESTAMP_TYPE)
                strcpy(QUI_attrib_displayed[attr_ctr].value,"1992-01-01");
            else
                strcpy(QUI_attrib_displayed[attr_ctr].value,"0");
          }

/* Added by Ravi - 13 June 1998 */
        if(QUI_attrib_displayed[attr_ctr].data_type == QUI_TIMESTAMP_TYPE)
        {
          _NFIdebug((fname, "Before NFMRvalidate_and_format_date\n"));
          status = NFMRvalidate_and_format_date(QUI_attrib_displayed[attr_ctr].value, nfm_date, ris_date);
          if(status != NFM_S_SUCCESS)
          {
            _NFIdebug ((fname, "NFMRvalidate_and_format_date = <0x%.8x>\n", status));
            QUIerase_message (form);
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }
	  else
             strcpy(QUI_attrib_displayed[attr_ctr].value, ris_date);
        }
/* End of Addition by Ravi - 13 June 1998 */

        if (((strcmp (QUI_attrib_displayed[attr_ctr].value, "NULL")) == 0) ||
            ((strcmp (QUI_attrib_displayed[attr_ctr].value, "null")) == 0))
          {
            if (QUI_attrib_displayed[attr_ctr].oper == QUI_OPVAL1)
              {
                sprintf (trio, "(%s IS NULL)", alias_and_attrib);
              }
            else if (QUI_attrib_displayed[attr_ctr].oper == QUI_OPVAL2)
              {
                sprintf (trio, "(%s IS NOT NULL)", alias_and_attrib);
              }
            else
              {
                QUI_set_op
                    ((long) QUI_attrib_displayed[attr_ctr].oper, operator);
                sprintf (trio, "(%s %s '%s')",
                    alias_and_attrib, operator,
                    QUI_attrib_displayed[attr_ctr].value);
              }
          }
        else
          {
            QUI_parseval(alias_and_attrib,
                (long) QUI_attrib_displayed[attr_ctr].data_type,
                (long) QUI_attrib_displayed[attr_ctr].oper,
                QUI_attrib_displayed[attr_ctr].value,trio);
          }

        if ((length+strlen(trio)+6) > strlen(where_clause))
          {
            where_clause = (char *)
                realloc(where_clause, length+strlen(trio)+6);
            length += strlen(trio)+6;
          }

        strcat (where_clause, trio);
        if (attr_ctr<QUIglobal.QUI_numofattr-1)
          {
            if (QUI_attrib_displayed[attr_ctr].and_or)
                strcpy (logical_op," AND ");
            else
                strcpy (logical_op," OR ");

            strcat (where_clause, logical_op);
          }
      }

    strcat (where_clause, ")");

    /*  Build the FROM clause and add any joins to the WHERE clause  */

    QUIbuild_from_clause (from_clause, &where_clause);

    /*  Put the info into the query structure  */

    if ((status = NFMwrite_query_struct (&query_info,
        select_clause, from_clause, where_clause, "", "")) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMwrite_query_struct = <0x%.8x>\n", status));
        free (where_clause);
        NFMfree_query_struct (&query_info);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    free (where_clause);

    /*  Get the owner  */

    FIg_get_state (form, OWNER_TOGGLE, &state);
    if (state == 0)
        strcpy (username, QUIglobal.username);
    else
        strcpy (username, "PUBLIC");

    /*  Get the description  */

    FIfld_get_text (form, DESC_FIELD,
        0, 0, sizeof (description) - 1, description, &sel, &rpos);

    QUIform_message (form, QUI_I_DEFINE, NULL);

    /*  Send the definition to NFM  */

    if ((status = NFMRdefine_query
       (QUIglobal.query_name, description, (short) NFM_WHERE_CLAUSE,
       "NFM", username, query_info)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdefine_query = <0x%.8x>\n", status));
        NFMfree_query_struct (&query_info);
        QUIerase_message (form);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    NFMfree_query_struct (&query_info);

    QUIerase_message (form);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }
