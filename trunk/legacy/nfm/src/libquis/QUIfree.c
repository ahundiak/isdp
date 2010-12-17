#include "machine.h"
#include "QUI.h"

long QUIfree_structs ()
  {
    auto    int     i;
    static  char    *fname = "QUIfree_structs";

    _NFIdebug ((fname, "entering ...\n"));

    MEMclose (&QUIglobal.catalogs);
    for (i = 0; i < QUI_MAX_ATTR_NUM; ++i)
      {
        if (QUIglobal.attributes[i] != (MEMptr) -1)
            MEMclose (&QUIglobal.attributes[i]);

        if (QUIglobal.values[i] != (MEMptr) -1)
            MEMclose (&QUIglobal.values[i]);
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
    return (QUI_S_SUCCESS);
  }
