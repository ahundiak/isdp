#include "machine.h"
#include "QUI.h"

Display_info QUI_attrib_displayed[QUI_MAX_ATTR_NUM];
long QUI_attrib_index[QUI_MAX_GADGET_NUMBER];

long QUI_initialize_structure(index)

long index;

{
  QUI_attrib_displayed[index].value = (char *) malloc(QUI_MIN_VALUE_LEN);
  QUI_attrib_displayed[index].query_display = 0;
  QUI_attrib_displayed[index].join = 0;
  QUI_attrib_displayed[index].browse_display = 0;
  QUI_attrib_displayed[index].catalog_no=0;
  QUI_attrib_displayed[index].attrib_no=-1;
  QUI_attrib_displayed[index].and_or=0;
  QUI_attrib_displayed[index].lookup_cat=0;
  QUI_attrib_displayed[index].field1[0]=0;
  QUI_attrib_displayed[index].field2[0]=0;
  QUI_attrib_displayed[index].item_code=0;
  QUI_attrib_displayed[index].write_code=0;
  QUI_attrib_displayed[index].oper=1;
  QUI_attrib_displayed[index].value[0]=0;
  QUI_attrib_displayed[index].used=0;
  QUI_attrib_displayed[index].order_by=0;
  QUI_attrib_displayed[index].repeats=0;
  QUI_attrib_displayed[index].browse_scroll=1;
  return(QUI_S_SUCCESS);
}

long QUI_initialize_gadgets(form)

Form form;

{
  long index,gadget_ctr;
  long gadget_index;
  long status=QUI_S_SUCCESS;

  static  char    *fname = "QUI_initialize_gadgets";

  _NFIdebug ((fname, "entering ...\n"));

  QUIglobal.QUI_numofattr = 0;

  QUIglobal.text = (char *) malloc (80);
  QUIglobal.text_size = 80;
  QUIglobal.QUI_delete_or_reorder = 0;
  QUIglobal.QUI_offset = 0;

  for (index=0;index<QUI_MAX_ATTR_NUM;index++)
  {
    status = QUI_initialize_structure(index);
  }

/* initialize an array that parameterizes all the fields on the Query form
   to a standard i.e. ATTRIBUTE1=VALUE1=OPERATOR1=1 to aid in storing
   data */

  for (index=0; index<QUI_MAX_GADGET_NUMBER; index++)
    QUI_attrib_index[index]=0;
  for (gadget_ctr=0;gadget_ctr<NUMBER_OF_ROWS;gadget_ctr++)
  {
    QUI_attrib_index[ATTRIBUTE_FIELD1+gadget_ctr]=
        QUI_attrib_index[CATALOG_FIELD1+gadget_ctr]=
        QUI_attrib_index[AND_OR_TOGGLE1+gadget_ctr]=
        QUI_attrib_index[VALUE_FIELD1+gadget_ctr]=
        QUI_attrib_index[BACKGROUND_LIST_SYM1+gadget_ctr]=
        QUI_attrib_index[BORDER_LIST_SYM1+gadget_ctr]=
        QUI_attrib_index[ASSOC_LIST_SYM1+gadget_ctr]=
        QUI_attrib_index[CHECKBOX1+gadget_ctr]=
        QUI_attrib_index[OPERATOR_FIELD1+gadget_ctr]=1+gadget_ctr;
#ifdef OS_SCO_UNIX
        FIg_set_font(form, OPERATOR_FIELD1+gadget_ctr, "7x13bold", 15);
#endif
  }
  FIg_disable(form, AND_OR_TOGGLE1);
  for (gadget_index=1;gadget_index<NUMBER_OF_ROWS;gadget_index++)
  {
    FIg_disable(form, CATALOG_FIELD1+gadget_index);
    FIg_disable(form, ATTRIBUTE_FIELD1+gadget_index);
#ifdef OS_SCO_UNIX
    FIg_set_font(form, OPERATOR_FIELD1+gadget_index, "7x13bold", 15);
#endif
    FIg_disable(form, OPERATOR_FIELD1+gadget_index);
    FIg_disable(form, VALUE_FIELD1+gadget_index);
    FIg_disable(form, AND_OR_TOGGLE1+gadget_index);
  }
  _NFIdebug ((fname, "exiting ...\n"));
  return(status);
}
