#include "machine.h"
#include "QUI.h"

long _QUIexchange_lists (form, label1, label2)
  Form    form;
  int     label1;
  int     label2;
  {
    auto    int     i;
    auto    int     sel1, sel2;
    auto    int     num_rows1;
    auto    int     num_rows2;
    auto    int     end_loop = 0;
    auto    int     length = 0;
    auto    int     length1 = 0;
    auto    int     length2 = 0;
    auto    char    *temp1 = NULL;
    auto    char    *temp2 = NULL;
    static  char    *fname = "_QUIexchange_lists";

    /*  Exchange the list data between label1 and label2  */

    _NFIdebug ((fname, "label1 = <%d>\n", label1));
    _NFIdebug ((fname, "label2 = <%d>\n", label2));

    /*  Find out how much space to allocate  */

    FIfld_get_list_num_rows (form, label1, 0, &num_rows1);
    for (i = 0, length1 = 0; i < num_rows1; ++i)
      {
        FIfld_get_list_text_length (form, label1, i, 0, &length);
        if (length1 < length)
            length1 = length;
      }

    _NFIdebug ((fname, "list field1 length = <%d>\n", length1));

    if ((temp1 = (char *) malloc (length1 + 1)) == NULL)
      {
        _NFIdebug ((fname, "failed to allocate <%d> bytes\n", length1 + 1));
        ERRload_struct (NFI, QUI_E_MALLOC, "%d", length1 + 1);
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", QUI_E_MALLOC));
        return (QUI_E_MALLOC);
      }

    FIfld_get_list_num_rows (form, label2, 0, &num_rows2);
    for (i = 0, length2 = 0; i < num_rows2; ++i)
      {
        FIfld_get_list_text_length (form, label2, i, 0, &length);
        if (length2 < length)
            length2 = length;
      }

    _NFIdebug ((fname, "list field2 length = <%d>\n", length2));

    if ((temp2 = (char *) malloc (length2 + 1)) == NULL)
      {
        _NFIdebug ((fname, "failed to allocate <%d> bytes\n", length2 + 1));
        ERRload_struct (NFI, QUI_E_MALLOC, "%d", length2 + 1);
        if (temp1) free (temp1);
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", QUI_E_MALLOC));
        return (QUI_E_MALLOC);
      }

    /*  Find out which list is the longest  */

    if (num_rows1 < num_rows2)
        end_loop = num_rows2;
    else
        end_loop = num_rows1;

    for (i = 0; i < end_loop; ++i)
      {
        /*  Pull the text out of label1  */

        if (i < num_rows1)
          {
            /*  Use the text from the list  */

            FIfld_get_list_text (form, label1, i, 0, length1, temp1, &sel1);
          }
        else
          {
            /*  Use the NULL string instead  */

            strcpy (temp1, "");
          }

        /*  Pull the text out of label2  */

        if (i < num_rows2)
          {
            /*  Use the text from the list  */

            FIfld_get_list_text (form, label2, i, 0, length2, temp2, &sel2);
          }
        else
          {
            /*  Use the NULL string instead  */

            strcpy (temp2, "");
          }

        /*  Put the text from label1 into label2  */

        _NFIdebug ((fname, "setting <%s> in label2 (list)\n", temp1));
        FIfld_set_list_text (form, label2, i, 0, temp1, sel1);

        /*  Put the text from label2 into label1  */

        _NFIdebug ((fname, "setting <%s> in label1 (list)\n", temp2));
        FIfld_set_list_text (form, label1, i, 0, temp2, sel2);
      }

    /*  Wipe out any leftovers  */

    FIfld_set_list_num_rows (form, label1, 0, num_rows2);
    FIfld_set_list_num_rows (form, label2, 0, num_rows1);

    FIg_display (form, label1);
    FIg_display (form, label2);

    if (temp1) free (temp1);
    if (temp2) free (temp2);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }
