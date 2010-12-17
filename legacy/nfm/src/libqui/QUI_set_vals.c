#include "machine.h"
/******************************************************************************

Doc: QUIset_values

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: QUI_set_vals.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number: 

Description: This routine displays the attribute information of the
             query form with the given scroll offset

Examples: QUIset_values( form, value)

Return Status: None

History: 6/7/90 - JWA - original code
         9/4/91 - JWA - added header
       11/06/91 - JWA - added check against old catalog to guard against
                        repeated trios of same attribute but different cats
        6/24/92 - Completely stripped function of unneeded functionality
                  and cleaned up the source code to make it readable - Glenn

******************************************************************************/

#include "QUI.h"

long QUIset_values (form, value)
  Form    form;   /* I - the pointer to the form */
  double  value;  /* I - the value of the scroll */
  {
    auto    int     attr_mask = 0;
    auto    int     gadget_index = 0;
    auto    char    synonym[NFM_SYNONYM + 1];
    auto    long    old_offset = 0;
    auto    long    index = 0, status;
    auto    long    displayable_attrs = 0;
    auto    long    num_spaces_taken = 0;
    auto    long    numofattr = 0;
    auto    long    display_index = 0;
    auto    long    displayed_count = 0;
    auto    long    attr_index = 0;
    auto    long    oper = 0;
    auto    short   catalog_no = 0;
    auto    short   attrib_no = 0;
    auto    double  puck = 0.0, high_value = 0.0;
    static  char    *fname = "QUIset_values";

    _NFIdebug ((fname, "scroll value = <%f>\n", value));

    status = QUI_S_SUCCESS;

    /* get number of displayable attributes */
 
    numofattr = QUIglobal.QUI_numofattr;

    for (index = 0; index < numofattr; index++)
      {
        if ((QUI_attrib_displayed[index].query_display) &&
            (QUI_attrib_displayed[index].attrib_no >= 0)) 
          {
            displayable_attrs++;
          }
      }

    if (QUIglobal.QUI_numofattr > displayable_attrs)
        numofattr = QUIglobal.QUI_numofattr;
    else
        numofattr = displayable_attrs;
     
    /*  See if the total number of attributes will fit without a scrollbar  */

    if (QUIglobal.QUI_numofattr + 1 == NUMBER_OF_ROWS)
        value = 0.0;

    high_value = displayable_attrs + 1 - NUMBER_OF_ROWS;
    if (value < 0)
      {
        if (high_value >= 0)
            value = high_value;
        else
            value = 0;
      }

    _NFIdebug ((fname, "value = <%f>\n", value));

    if (displayable_attrs + 1 > NUMBER_OF_ROWS)
      {
        puck = (double) NUMBER_OF_ROWS / (double) (displayable_attrs + 1);

        if (puck > 1)
            puck = 1;

        if (puck == 1)
          {
            FIg_erase (form, SCROLL_BAR);
          }
        else
          {
            FIg_display (form, SCROLL_BAR);
            FIg_set_increment (form, SCROLL_BAR, 1.0);
            FIscrl_set_view (form, SCROLL_BAR, puck);
            FIg_set_high_value (form, SCROLL_BAR, high_value);
            FIg_set_value (form, SCROLL_BAR, value);
          }
      }
    else
      {
        FIg_erase (form, SCROLL_BAR);
      }

    old_offset = QUIglobal.QUI_offset;
    QUIglobal.QUI_offset = value;

    _NFIdebug ((fname, "QUIglobal.QUI_offset = <%f>\n", value));

    if (displayable_attrs + 1 < NUMBER_OF_ROWS)
        num_spaces_taken = displayable_attrs;
    else
        num_spaces_taken = NUMBER_OF_ROWS;

    attrib_no = -1;

    for (index = 0; index < num_spaces_taken; index++)
      {
        attr_index = 0;
        displayed_count = 0;

        while ((attr_index < numofattr) &&
            (displayed_count < index + QUIglobal.QUI_offset + 1))
          {
            if ((QUI_attrib_displayed[attr_index].query_display) &&
                (QUI_attrib_displayed[attr_index].attrib_no >= 0))
                displayed_count++;

            attr_index++;
          }

        attr_index--;

        if (QUI_attrib_displayed[attr_index].query_display == 0) continue;

        catalog_no = QUI_attrib_displayed[attr_index].catalog_no;
        attrib_no = QUI_attrib_displayed[attr_index].attrib_no;

        if ((status = QUIget_synonym
            (catalog_no, attrib_no, synonym)) != QUI_S_SUCCESS)
          {
            _NFIdebug ((fname, "QUIget_synonym = <0x%.8x>\n", status));
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }

        if (display_index >= NUMBER_OF_ROWS) continue;

        /*  Load the attributes for this catalog  */

        if ((status = _QUIload_catalog_attributes (form,
            ATTRIBUTE_FIELD1 + display_index, catalog_no)) != QUI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_QUIload_catalog_attributes = <0x%.8x>\n", status));
          }

        FIfld_set_list_select (form,
            CATALOG_FIELD1 + display_index, catalog_no, 0, TRUE);

        FIg_set_text (form, ATTRIBUTE_FIELD1 + display_index, synonym);
        QUI_highlight_list (form, ATTRIBUTE_FIELD1 + display_index, synonym);

        FIg_enable (form, CATALOG_FIELD1 + display_index);
        FIg_enable (form, ATTRIBUTE_FIELD1 + display_index);
        FIg_enable (form, OPERATOR_FIELD1 + display_index);
        FIg_enable (form, VALUE_FIELD1 + display_index);
        FIg_enable (form, AND_OR_TOGGLE1 + display_index);

        FIg_set_text (form, VALUE_FIELD1 + display_index,
            QUI_attrib_displayed[attr_index].value);

        /*  Load the value list for this attribute  */

        if ((status = QUIload_value_list (form, attr_index)) != QUI_S_SUCCESS)
          {
            _NFIdebug ((fname, "QUIload_value_list = <0x%.8x>\n", status));
          }

        if (QUI_attrib_displayed[attr_index].oper == 0)
            QUI_attrib_displayed[attr_index].oper = 1;

        oper = QUI_attrib_displayed[attr_index].oper - 1;

        FIfld_set_active_row (form, OPERATOR_FIELD1 + display_index, oper, 0);

        if (display_index < NUMBER_OF_ROWS - 1)
          {
            FIg_set_state (form, AND_OR_TOGGLE1 + display_index,
                QUI_attrib_displayed[attr_index].and_or);
          }

        display_index++;
      }

    FIg_enable (form, CATALOG_FIELD1 + display_index);
    FIg_enable (form, ATTRIBUTE_FIELD1 + display_index);
    FIg_enable (form, OPERATOR_FIELD1 + display_index);
    FIg_enable (form, VALUE_FIELD1 + display_index);

    if ((display_index > 0) && (display_index < NUMBER_OF_ROWS - 1))
        FIg_enable (form, AND_OR_TOGGLE1 + display_index - 1);

    _NFIdebug ((fname, "defaulting catalog ...\n"));

    /*  Default the catalog to the first one in the list  */

    QUI_attrib_displayed[attr_index].catalog_no = (short) 0;

    /*  Load the attributes for this catalog  */

    if ((status = _QUIload_catalog_attributes
        (form, ATTRIBUTE_FIELD1 + display_index, (short) 0)) != QUI_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "_QUIload_catalog_attributes = <0x%.8x>\n", status));
      }

    for (index = display_index; index < NUMBER_OF_ROWS; index++)
      {
        FIfld_set_active_row (form, OPERATOR_FIELD1 + index, 0, 0);
        FIg_set_text (form, CATALOG_FIELD1 + index, "");
        QUI_unhilite (form, CATALOG_FIELD1 + index);
        FIg_set_text (form, ATTRIBUTE_FIELD1 + index, "");
        QUI_unhilite (form, ATTRIBUTE_FIELD1 + index);
        FIg_set_text (form, VALUE_FIELD1 + index, "");
        FIfld_set_list_num_rows (form, VALUE_FIELD1 + index, 0, 0);

        if (index > display_index)
          {
            FIg_disable (form, CATALOG_FIELD1 + index);
            FIg_disable (form, ATTRIBUTE_FIELD1 + index);
            FIg_disable (form, OPERATOR_FIELD1 + index);
            FIg_disable (form, VALUE_FIELD1 + index);
            FIg_disable (form, AND_OR_TOGGLE1 + index - 1);
            FIg_set_state_off (form, AND_OR_TOGGLE1 + index - 1);
          }
      }

    if (QUIglobal.QUI_offset == QUIglobal.QUI_numofattr - NUMBER_OF_ROWS + 1)
      {
        FIg_set_text (form, CATALOG_FIELD8, "");
        QUI_unhilite (form, CATALOG_FIELD8);
        FIg_set_text (form, ATTRIBUTE_FIELD8, "");
        QUI_unhilite (form, ATTRIBUTE_FIELD8);
        FIg_set_text (form, VALUE_FIELD8, "");
        QUI_unhilite (form, VALUE_FIELD8);
        FIfld_set_list_num_rows (form, VALUE_FIELD8, 0, 0);
        FIfld_set_active_row (form, OPERATOR_FIELD8, 0, 0);
      }

    /*  Find out if the checkboxes are displayed  */

    _NFIdebug ((fname, "checking checkboxes ...\n"));

    FIg_get_attr (form, CHECKBOX1, &attr_mask);
    if ((attr_mask & FI_NOT_DISPLAYED) == 0)
      {
        /*  This will fix the checkbox
            display with the current scroll offset  */

        QUIdisplay_checkboxes (form, 0);

        /*  Calculate the old checkbox label  */

        gadget_index = -QUIglobal.QUI_delete_or_reorder - old_offset;

        /*  Turn off the previously selected checkbox  */

        FIg_set_state_off (form, CHECKBOX1 + gadget_index);

        /*  Calculate the new checkbox label (new minus old)  */

        gadget_index = -QUIglobal.QUI_delete_or_reorder - value;

        /*  Turn on the checkbox in the new scroll location  */

        if ((gadget_index >= 0) && (gadget_index < NUMBER_OF_ROWS))
            FIg_set_state_on (form, CHECKBOX1 + gadget_index);

        QUIdisplay_checkboxes (form, 1);
      }

    _NFIdebug ((fname, "returning <0x%.8x>\n", status));
    return (status);
  }
