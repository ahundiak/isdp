#include "machine.h"
#include "QUI.h"

QUI_swap(index1,index2)

long index1;
long index2;

{
  auto    MEMptr  temp;
  static  char    *fname = "QUI_swap";
  Display_info dummy_info;

  _NFIdebug ((fname, "entering ...\n"));

/* initialize dummy_info structure */

  dummy_info.value = (char *) malloc(QUI_MIN_VALUE_LEN);
  dummy_info.query_display = 0;
  dummy_info.join = 0;
  dummy_info.and_or = 0;
  dummy_info.data_type = 0;
  dummy_info.browse_display = 0;
  dummy_info.attrib_no=0;
  dummy_info.catalog_no=0;
  dummy_info.lookup_cat=0;
  dummy_info.field1[0]=0;
  dummy_info.field2[0]=0;
  dummy_info.item_code=0;
  dummy_info.write_code=0;
  dummy_info.oper=1;
  dummy_info.value[0]=0;
  dummy_info.used=0;
  dummy_info.order_by=0;
  dummy_info.repeats=0;
  dummy_info.browse_scroll=1;

/* copy index1 attribute info into dummy structure */

  dummy_info.query_display=
         QUI_attrib_displayed[index1].query_display;
  dummy_info.join = 
         QUI_attrib_displayed[index1].join;
  dummy_info.and_or = 
         QUI_attrib_displayed[index1].and_or;
  dummy_info.data_type = 
         QUI_attrib_displayed[index1].data_type;
  dummy_info.browse_display =
         QUI_attrib_displayed[index1].browse_display;
  dummy_info.attrib_no = QUI_attrib_displayed[index1].attrib_no;
  dummy_info.catalog_no = QUI_attrib_displayed[index1].catalog_no;
  dummy_info.lookup_cat=
         QUI_attrib_displayed[index1].lookup_cat;
  strcpy(dummy_info.field1,
         QUI_attrib_displayed[index1].field1);
  strcpy(dummy_info.field2,
         QUI_attrib_displayed[index1].field2);
  dummy_info.item_code=
         QUI_attrib_displayed[index1].item_code;
  dummy_info.write_code=
         QUI_attrib_displayed[index1].write_code;
  dummy_info.oper=
         QUI_attrib_displayed[index1].oper;
  if (strlen(dummy_info.value)<
      strlen(QUI_attrib_displayed[index1].value))
    dummy_info.value = 
    (char *) realloc(dummy_info.value,
    strlen(QUI_attrib_displayed[index1].value));
  strcpy(dummy_info.value,
         QUI_attrib_displayed[index1].value);
  dummy_info.used=
         QUI_attrib_displayed[index1].used;
  dummy_info.order_by=
         QUI_attrib_displayed[index1].order_by;
  dummy_info.repeats=
         QUI_attrib_displayed[index1].repeats;
  dummy_info.browse_scroll=
         QUI_attrib_displayed[index1].browse_scroll;

/* copy index2 attribute info into index1 structure */

  QUI_attrib_displayed[index1].query_display=
         QUI_attrib_displayed[index2].query_display;
  QUI_attrib_displayed[index1].join = 
         QUI_attrib_displayed[index2].join;
  QUI_attrib_displayed[index1].and_or = 
         QUI_attrib_displayed[index2].and_or;
  QUI_attrib_displayed[index1].data_type = 
         QUI_attrib_displayed[index2].data_type;
  QUI_attrib_displayed[index1].browse_display =
         QUI_attrib_displayed[index2].browse_display;
  QUI_attrib_displayed[index1].attrib_no =
         QUI_attrib_displayed[index2].attrib_no;
  QUI_attrib_displayed[index1].catalog_no = 
         QUI_attrib_displayed[index2].catalog_no;
  QUI_attrib_displayed[index1].lookup_cat=
         QUI_attrib_displayed[index2].lookup_cat;
  strcpy(QUI_attrib_displayed[index1].field1,
         QUI_attrib_displayed[index2].field1);
  strcpy(QUI_attrib_displayed[index1].field2,
         QUI_attrib_displayed[index2].field2);
  QUI_attrib_displayed[index1].item_code=
         QUI_attrib_displayed[index2].item_code;
  QUI_attrib_displayed[index1].write_code=
         QUI_attrib_displayed[index2].write_code;
  QUI_attrib_displayed[index1].oper=
         QUI_attrib_displayed[index2].oper;
  if (strlen(QUI_attrib_displayed[index1].value)<
      strlen(QUI_attrib_displayed[index2].value))
    QUI_attrib_displayed[index1].value = 
    (char *) realloc(QUI_attrib_displayed[index1].value,
    strlen(QUI_attrib_displayed[index2].value)+1);
  strcpy(QUI_attrib_displayed[index1].value,
         QUI_attrib_displayed[index2].value);
  QUI_attrib_displayed[index1].used=
         QUI_attrib_displayed[index2].used;
  QUI_attrib_displayed[index1].order_by=
         QUI_attrib_displayed[index2].order_by;
  QUI_attrib_displayed[index1].repeats=
         QUI_attrib_displayed[index2].repeats;
  QUI_attrib_displayed[index1].browse_scroll=
         QUI_attrib_displayed[index2].browse_scroll;

/* copy dummy structure attribute info into index2 */

  QUI_attrib_displayed[index2].query_display=
         dummy_info.query_display;
  QUI_attrib_displayed[index2].join = 
         dummy_info.join;
  QUI_attrib_displayed[index2].and_or = 
         dummy_info.and_or;
  QUI_attrib_displayed[index2].data_type = 
         dummy_info.data_type;
  QUI_attrib_displayed[index2].browse_display =
         dummy_info.browse_display;
  QUI_attrib_displayed[index2].attrib_no = dummy_info.attrib_no;
  QUI_attrib_displayed[index2].catalog_no = dummy_info.catalog_no;
  QUI_attrib_displayed[index2].lookup_cat=
         dummy_info.lookup_cat;
  strcpy(QUI_attrib_displayed[index2].field1,
         dummy_info.field1);
  strcpy(QUI_attrib_displayed[index2].field2,
         dummy_info.field2);
  QUI_attrib_displayed[index2].item_code=
         dummy_info.item_code;
  QUI_attrib_displayed[index2].write_code=
         dummy_info.write_code;
  QUI_attrib_displayed[index2].oper=
         dummy_info.oper;
  if (strlen(QUI_attrib_displayed[index2].value)<
      strlen(dummy_info.value))
    QUI_attrib_displayed[index2].value = 
    (char *) realloc(QUI_attrib_displayed[index2].value,
    strlen(dummy_info.value)+1);
  strcpy(QUI_attrib_displayed[index2].value,
         dummy_info.value);
  QUI_attrib_displayed[index2].used=
         dummy_info.used;
  QUI_attrib_displayed[index2].order_by=
         dummy_info.order_by;
  QUI_attrib_displayed[index2].repeats=
         dummy_info.repeats;
  QUI_attrib_displayed[index2].browse_scroll=
         dummy_info.browse_scroll;

  /*  This will exchange the two value list pointers  */

  temp = QUIglobal.values[index1];
  QUIglobal.values[index1] = QUIglobal.values[index2];
  QUIglobal.values[index2] = temp;

  _NFIdebug ((fname, "exiting ...\n"));
}
