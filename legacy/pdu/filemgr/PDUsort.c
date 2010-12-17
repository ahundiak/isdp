#include <stdio.h>
#include "FI.h"
#include "tools.h"
#include "PDUforms.h"
#include "PDUintdef.h"
#include "PDUform_def.h"
#include "PDUfile_def.h"
#include "PDMtypes.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUproto.h"

#define PART_SORT                16
#define PART_SORT2               33
#define PART_SORT3               34
#define PART_SORT4               35
#define PART_SORT5               36
#define PART_SORT2_LIST_BTN      45
#define PART_SORT3_LIST_BTN      46
#define PART_SORT4_LIST_BTN      47
#define PART_SORT5_LIST_BTN      48

extern int    PDU_num_of_part_rows;
extern int    PDU_prev_part_sort;
extern int    PDU_part_displayed;
extern int    NumAttribs;
extern char  *PDU_part_sort_conds;
extern char **PDU_part_sort_attr;
extern char **AttrList;
extern char **AttrSynonym;
extern struct PDUforms   forms;

int PDUdisplay_part_sort_conditions()
{
int        status = PDM_S_SUCCESS;
int        attr_count;
int        row;
int        index;
char      *sort_type = NULL;
char      *sort_string = NULL;
char      *syn_string = NULL;
char     **attr_list = NULL;

  /* Get the previously defined sort conditions */
  sort_type = "C";
  status = PDUget_criteria_string("O",sort_type, PDU_part_sort_conds,
                                   &sort_string);
  _pdm_status("PDUget_criteria_string", status);

  if (status == PDM_S_SUCCESS)
    {
    status = PDUstring_to_attributes(sort_string, &attr_count,
                                     &attr_list);
    _pdm_status("PDUstring_to_attributes", status);

    PDU_num_of_part_rows = 0;
    if (status == PDM_S_SUCCESS)
      PDU_num_of_part_rows += attr_count;

    if (PDU_num_of_part_rows > NumAttribs)
      {
      _pdm_debug("number of retrieved sort attrs exceeds NumAttribs", 0);
      status = PDM_E_ERROR_RETRIEVING_SORT;
      PDUmessage(status, 's');
      return(status);
      }

    }
  else
    {
    PDUmessage(status, 's');
    return(status);
    }

  /* print the attribute list */
  _pdm_debug("defined attribute list", 0);
  for (row = 0; row < PDU_num_of_part_rows; ++row)
     _pdm_debug("attr_list data = <%s>", AttrList[row]);

  /* print the synonym list */
  _pdm_debug("defined synonym list", 0);
  for (row = 0; row < PDU_num_of_part_rows; ++row)
     _pdm_debug("synonym_list data = <%s>", AttrSynonym[row]);

  /* put the existing attributes in the sort criteria */
  if (PDU_num_of_part_rows > 0)
    {
    for (row = 0; row < PDU_num_of_part_rows; ++row)
       {
       index = 0;
       while ((strcmp(attr_list[row], AttrList[index]) != 0) &&
              (index < NumAttribs))
          {
          _pdm_debug("index = %d", (char *) index);
          _pdm_debug("AttrList[index] = <%s>", AttrList[index]);
          ++index;
          }

       if ((index == NumAttribs - 1) && 
           (strcmp(attr_list[row], AttrList[index]) != 0))
         {
         _pdm_debug("attribute was not found in AttrList; not being loaded", 0);
         continue;
         }

       if ((AttrSynonym[index]) && 
           (strcmp(AttrSynonym[index], "") != 0))
         {
         PDUfill_in_string(&syn_string, AttrSynonym[index]);
         _pdm_debug("filling in AttrSynonym[index] = <%s>", AttrSynonym[index]);
         }
       else
         {
         PDUfill_in_string(&syn_string, AttrList[index]);
         _pdm_debug("filling in AttrList[index] = <%s>", AttrList[index]);
         }
       _pdm_debug("synonym string = <%s>", syn_string);

       switch (row + 1)
        {
        case 1:
         FIg_set_text(forms.sort_form_id, PART_SORT, syn_string);
         _pdm_debug("writing to PDU_part_sort_attr row %d", (char *)row);
         PDUfill_in_string(&PDU_part_sort_attr[row], syn_string);
         _pdm_debug("PDU_part_sort_attr[row] = <%s>", PDU_part_sort_attr[row]);

         FIg_display(forms.sort_form_id, PART_SORT2);
         FIg_display(forms.sort_form_id, PART_SORT2_LIST_BTN);
         break;

        case 2:
         FIg_set_text(forms.sort_form_id, PART_SORT2, syn_string);
         _pdm_debug("writing to PDU_part_sort_attr row %d", (char *)row);
         PDUfill_in_string(&PDU_part_sort_attr[row], syn_string);
         _pdm_debug("PDU_part_sort_attr[row] = <%s>", PDU_part_sort_attr[row]);

         FIg_display(forms.sort_form_id, PART_SORT2);
         FIg_display(forms.sort_form_id, PART_SORT2_LIST_BTN);
         FIg_display(forms.sort_form_id, PART_SORT3);
         FIg_display(forms.sort_form_id, PART_SORT3_LIST_BTN);
         break;

        case 3:
         FIg_set_text(forms.sort_form_id, PART_SORT3, syn_string);
         _pdm_debug("writing to PDU_part_sort_attr row %d", (char *)row);
         PDUfill_in_string(&PDU_part_sort_attr[row], syn_string);
         _pdm_debug("PDU_part_sort_attr[row] = <%s>", PDU_part_sort_attr[row]);

         FIg_display(forms.sort_form_id, PART_SORT3);
         FIg_display(forms.sort_form_id, PART_SORT3_LIST_BTN);
         FIg_display(forms.sort_form_id, PART_SORT4);
         FIg_display(forms.sort_form_id, PART_SORT4_LIST_BTN);
         break;

        case 4:
         FIg_set_text(forms.sort_form_id, PART_SORT4, syn_string);
         PDUfill_in_string(&PDU_part_sort_attr[row], syn_string);

         FIg_display(forms.sort_form_id, PART_SORT4);
         FIg_display(forms.sort_form_id, PART_SORT4_LIST_BTN);
         FIg_display(forms.sort_form_id, PART_SORT5);
         FIg_display(forms.sort_form_id, PART_SORT5_LIST_BTN);
         break;

        case 5:
         FIg_set_text(forms.sort_form_id, PART_SORT5, syn_string);
         PDUfill_in_string(&PDU_part_sort_attr[row], syn_string);
         break;
        } /* end switch */
       } /* end for row */
    }

  PDU_prev_part_sort = TRUE;
  PDU_part_displayed = TRUE;

  return(status);
}
