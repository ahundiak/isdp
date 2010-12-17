#include "machine.h"
#include "QUI.h"
#include "NFMerrordef.h"

long _QUIget_queries (form, username)
  Form    form;
  char    *username;
  {
    auto    int     i;
    auto    long    status;
    auto    char    search[512];
    auto    char    **data_ptr;
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "_QUIget_queries";

    _NFIdebug ((fname, "username = <%s>\n", username));

    /*  Get all queries owned by this user or by PUBLIC  */

    sprintf (search, "n_owner IN (SELECT n_userno FROM nfmusers WHERE \
n_username = '%s' OR n_username = 'PUBLIC')", username);

    /*  Get the list of queries from NFM  */

    if ((status = NFMRdisplay_querys
        ("W", search, "", 1, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_querys = <0x%.8x>\n", status));
        ERRreset_struct ();
        MEMclose (&synonyms);
        MEMclose (&data);

        /*  There are none defined for this user to use  */

        _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
        return (QUI_S_SUCCESS);
      }

    /*  We're not using this buffer  */

    MEMclose (&synonyms);

    if ((status = MEMbuild_array (data)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        MEMclose (&data);
        ERRload_struct (NFI, QUI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, "returning <0x%.8x>\n", QUI_E_MEM));
        return (QUI_E_MEM);
      }

    data_ptr = (char **) data->data_ptr;

    for (i = 0; i < data->rows; ++i)
      {
        _NFIdebug ((fname,
            "Setting <%s> in row %d\n", data_ptr[(i * data->columns) + 1], i));

        FIfld_set_list_text (form, QUERY_FIELD,
            i, 0, data_ptr[(i * data->columns) + 1], FALSE);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }
