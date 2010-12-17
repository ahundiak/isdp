#include "machine.h"
/******************************************************************************

Doc: QUI_clear_values

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: QUI_clr_vals.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number: 

Description: This routine clears the Query form and optionally clears the
             data structures behind the form.

Examples: QUI_clear_values(fp)

Return Status: None

History: 6/7/90 - JWA - original code
         9/4/91 - JWA - added header
       11/17/91 - JWA - removed QUI_values,QUI_operators

******************************************************************************/

#include "QUI.h"

long QUI_clear_values( form )

Form form;  /* I - pointer to the form */

{
  long sts, index;

  for (index=0;index<NUMBER_OF_ROWS;index++)
  {
    sts = FIg_set_text( form, (CATALOG_FIELD1+index),"");
    QUI_unhilite(form, (CATALOG_FIELD1+index));
    sts = FIg_set_text( form, (ATTRIBUTE_FIELD1+index),"");
    QUI_unhilite(form, (ATTRIBUTE_FIELD1+index));
    sts = FIg_set_text( form, (VALUE_FIELD1+index),"");
    QUI_unhilite(form, (VALUE_FIELD1+index));
    sts = FIfld_set_active_row( form, (OPERATOR_FIELD1+index), 0, 0);
    sts = FIg_set_state_off( form, (AND_OR_TOGGLE1+index));
    sts = FIg_set_state_off( form, (CHECKBOX1+index));
    FIg_erase(form, CHECKBOX1+index);
    FIg_disable(form, CHECKBOX1+index);
    if (index>0)
    {
      FIg_disable(form, CATALOG_FIELD1+index);
      FIg_disable(form, ATTRIBUTE_FIELD1+index);
      FIg_disable(form, OPERATOR_FIELD1+index);
      FIg_disable(form, VALUE_FIELD1+index);
      FIg_disable(form, AND_OR_TOGGLE1+index-1);
    }
  }
  FIg_erase(form, SCROLL_BAR);
  QUIglobal.QUI_numofattr=0;
  QUIglobal.QUI_offset=0;
  QUIglobal.QUI_delete_or_reorder=0;
  for (index=0;index<QUI_MAX_ATTR_NUM;index++)
  {
    free(QUI_attrib_displayed[index].value);
    QUI_initialize_structure(index);
  }
  return(QUI_S_SUCCESS);
}
