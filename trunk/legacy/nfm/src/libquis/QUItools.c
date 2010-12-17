#include "machine.h"
#include "QUI.h"
#include "MEMerrordef.h"

long _QUIfind_column_offset (buffer, attrname, offset)
  MEMptr   buffer;
  char     *attrname;
  short    *offset;
  {
    auto    int     i;
    auto    char    **column;
    auto    short   found = FALSE;
    static  char    *fname = "_QUIfind_column_offset";

    _NFIdebug ((fname, "attrname = <%s>\n", attrname));

    if (buffer == NULL)
      {
        _NFIdebug ((fname, "input buffer is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (MEM_E_NULL_BUFFER);
      }

    column = (char **) buffer->column_ptr;

    for (i = 0; i < buffer->columns; ++i)
      {
        if ((strcmp (column[i], attrname)) == 0)
          {
            *offset = i;
            found = TRUE;
            break;
          }
      }

    if (found == FALSE)
      {
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (QUI_E_FAILURE);
      }

    _NFIdebug ((fname, "offset = <%d>\n", *offset));

    _NFIdebug ((fname, "returning SUCCESS\n"));
    return (QUI_S_SUCCESS);
  }


long _QUIcenter_form (form, xlocation, ylocation)
  Form   form;
  int    xlocation;  /*  i - if < 0, center along x axis  */
  int    ylocation;  /*  i - if < 0, center along y axis  */
  {
    static  char    *fname = "_QUIcenter_form";

    /*  Make sure the form is valid  */

    if (form == NULL)
      {
        _NFIdebug ((fname, "form is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (QUI_E_NULL_FORM);
      }

    xlocation = xlocation;
    ylocation = ylocation;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (QUI_S_SUCCESS);
  }
