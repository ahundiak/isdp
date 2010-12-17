#include <stdio.h>
#include <FI.h>
#include <tools.h>
#include "PDUintdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUstr.h"
#include "PDUforms.h"
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDMcommand.h"
#include "part_gadgets.h"
#include "PDUform_def.h"
#include "PDUproto.h"
#include "PDMproto.h"

extern Form PDU_form_id;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_attr_bufr;
extern MEMptr PDU_data_bufr;
extern struct PDUrefresh    *refresh;
extern struct PDUforms      forms;
extern int    new_mode;
extern int    similar_mode;
extern int    change_mode;
extern int    review_mode;
extern char  *np_project;
extern char  *np_catalog;
extern char  *nn_itemname;
extern char  *np_rev;
extern char  *np_parttype;
extern char  *np_desc;
extern char  *ep_project;
extern char  *ep_catalog;
extern char  *en_itemname;
extern char  *ep_rev;
extern char  *ep_parttype;
extern char  *ep_desc;

void  PDUnew_mode()

{
int      max_rows;

     /* The mode of operation is NEW */

     FIg_enable(forms.part_operations_form_id,REVIEW_MODE_BTN);
     FIg_enable(forms.part_operations_form_id,SIMILAR_MODE_BTN);
     FIg_enable(forms.part_operations_form_id,CHANGE_MODE_BTN);

     new_mode = TRUE;
     similar_mode = FALSE;
     change_mode = FALSE;
     review_mode = FALSE;

         FIg_set_state_off(forms.part_operations_form_id,SIMILAR_MODE_BTN);
         FIg_set_state_off(forms.part_operations_form_id,CHANGE_MODE_BTN);
         FIg_set_state_off(forms.part_operations_form_id,REVIEW_MODE_BTN);

         FIg_set_state_on(forms.part_operations_form_id,NEW_MODE_BTN);

         FIg_erase(forms.part_operations_form_id, EXISTING_PART_GRP);
         FIg_erase(forms.part_operations_form_id, EXISTING_PART_BEZ);
        FIg_erase(forms.part_operations_form_id, EXISTING_FILE_TXT);

        FIg_display(forms.part_operations_form_id, NEW_FILE_TXT);

        FIg_disable(forms.part_operations_form_id, ADD_TO_PROJECT_BTN);
        FIg_disable(forms.part_operations_form_id, DELETE_BTN);
        FIg_disable(forms.part_operations_form_id, WHERE_USED_BTN);
        FIg_disable(forms.part_operations_form_id, CHANGE_BTN);
        FIg_disable(forms.part_operations_form_id, FLAG_CANCELFLAG_BTN);
        FIg_disable(forms.part_operations_form_id, DELETE_FILES_BTN);
        FIg_disable(forms.part_operations_form_id, MOVE_STATE_BTN);

        FIg_enable(forms.part_operations_form_id, ADD_BTN);
        FIg_enable(forms.part_operations_form_id, SEARCH_BTN);

        FIfld_set_mode(forms.part_operations_form_id,NP_PROJECT_FLD,0,
                       FI_INSERT);
        FIg_display(forms.part_operations_form_id,NP_PROJECT_FLD);
        FIfld_set_mode(forms.part_operations_form_id,NP_PARTNUM_FLD,0,
                       FI_INSERT);
        FIg_display(forms.part_operations_form_id,NP_PARTNUM_FLD);
        FIfld_set_mode(forms.part_operations_form_id,NP_REV_FLD,0,FI_INSERT);
        FIg_display(forms.part_operations_form_id,NP_REV_FLD);
        FIfld_set_mode(forms.part_operations_form_id,NP_PARTTYPE_FLD,0,
                       FI_INSERT);
        FIg_display(forms.part_operations_form_id,NP_PARTTYPE_FLD);
        FIfld_set_mode(forms.part_operations_form_id,NP_DESC_FLD,0,FI_INSERT);
        FIg_display(forms.part_operations_form_id,NP_DESC_FLD);

        FIfld_get_num_rows(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
                           &max_rows);
        PDUremove_data(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
                       max_rows,2);

       FIfld_set_text(forms.part_operations_form_id,STORAGE_AREA_FLD,0,0,"",
                      FALSE);
       FIfld_set_text(forms.part_operations_form_id,STATE_NAME_FLD,0,0,"",
                      FALSE);
       FIfld_set_text(forms.part_operations_form_id,WORKFLOW_FLD,0,0,"",FALSE);
       FIfld_set_text(forms.part_operations_form_id,ACL_NAME_FLD,0,0,"",FALSE);

        /* Set File Information Palette to allow for data entry */

        FIfld_set_mode(forms.part_operations_form_id,FILE_INFO_MCF,0,FI_INSERT);
        FIfld_set_mode(forms.part_operations_form_id,FILE_INFO_MCF,1,FI_INSERT);
        FIfld_set_mode(forms.part_operations_form_id,FILE_INFO_MCF,2,FI_INSERT);
        FIfld_set_mode(forms.part_operations_form_id,FILE_INFO_MCF,3,FI_INSERT);

        /* Redisplay the gadgets after changing the field mode */

        FIg_display(forms.part_operations_form_id, FILE_INFO_GRP);
        FIg_display(forms.part_operations_form_id, FILE_INFO_MCF);
        FIg_enable(forms.part_operations_form_id,SIMILAR_MODE_BTN);
}

void PDUsimilar_mode()

{

int      max_rows;

     FIg_enable(forms.part_operations_form_id,REVIEW_MODE_BTN);
     FIg_enable(forms.part_operations_form_id,SIMILAR_MODE_BTN);
     FIg_enable(forms.part_operations_form_id,CHANGE_MODE_BTN);

        similar_mode = TRUE;
        new_mode = FALSE;
        change_mode = FALSE;
        review_mode = FALSE;

        /* Set NEW, CHANGE, and REVIEW mode buttons' state to OFF */
        FIg_set_state_off(forms.part_operations_form_id,NEW_MODE_BTN);
        FIg_set_state_off(forms.part_operations_form_id,CHANGE_MODE_BTN);
        FIg_set_state_off(forms.part_operations_form_id,REVIEW_MODE_BTN);

         /* Set SIMILAR mode buttons' state to ON */
         FIg_set_state_on(forms.part_operations_form_id,SIMILAR_MODE_BTN);

        /* Display the ENTER/SELECT PART toggle */
        FIg_erase(forms.part_operations_form_id, ENTER_SELECT_TGL);

        /* Display the Existing Part Palette */
        FIg_display(forms.part_operations_form_id, EXISTING_PART_BEZ);
        FIg_display(forms.part_operations_form_id, EXISTING_PART_GRP);

        /* Display the New Part Palette */
        FIg_display(forms.part_operations_form_id, NEW_PART_BEZ);
        FIg_display(forms.part_operations_form_id, NEW_PART_GRP);
        FIg_erase(forms.part_operations_form_id,EP_PARTTYPE_BTN);

        /* Disable all command except the ADD, SEARCH and DESIGN commands */
        FIg_disable(forms.part_operations_form_id, ADD_TO_PROJECT_BTN);
        FIg_disable(forms.part_operations_form_id, DELETE_BTN);
        FIg_disable(forms.part_operations_form_id, WHERE_USED_BTN);
        FIg_disable(forms.part_operations_form_id, CHANGE_BTN);
        FIg_disable(forms.part_operations_form_id, FLAG_CANCELFLAG_BTN);
        FIg_disable(forms.part_operations_form_id, DELETE_FILES_BTN);
        FIg_disable(forms.part_operations_form_id, MOVE_STATE_BTN);

        /* Enable the ADD, SEARCH and DESIGN commands */
        FIg_enable(forms.part_operations_form_id, ADD_BTN);
        FIg_enable(forms.part_operations_form_id, SEARCH_BTN);

        /* Erase "Existing File Information" text on File Info Palette */
        FIg_erase(forms.part_operations_form_id, EXISTING_FILE_TXT);

        /* Display the "New File Information" text on the File Info Palette */
        FIg_display(forms.part_operations_form_id, NEW_FILE_TXT);

        /* Erase the FILE_INFO_MCF */
        FIg_erase(forms.part_operations_form_id, FILE_INFO_MCF);

        /* Erase the FILE_INFO_GRP */
        FIg_erase(forms.part_operations_form_id, FILE_INFO_GRP);

        /* Display the STORAGE_AREA_FLD */
        FIg_display(PDU_form_id,STORAGE_AREA_FLD);

        /* Display the STORAGE_AREA_TXT */
        FIg_display(PDU_form_id,STORAGE_AREA_TXT);

        FIfld_get_num_rows(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
                           &max_rows);
        PDUremove_data(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
                       max_rows,2);

        FIg_reset(forms.part_operations_form_id,SIMILAR_MODE_MCF);
        FIg_display(forms.part_operations_form_id,SIMILAR_MODE_MCF);

        FIfld_set_text(forms.part_operations_form_id,STORAGE_AREA_FLD,0,0,"",
                       FALSE);
        FIfld_set_text(forms.part_operations_form_id,STATE_NAME_FLD,0,0,"",
                       FALSE);
        FIfld_set_text(forms.part_operations_form_id,WORKFLOW_FLD,0,0,"",FALSE);
        FIfld_set_text(forms.part_operations_form_id,ACL_NAME_FLD,0,0,"",FALSE);

        /* Set the Part Attribute Palette to allow for data entry */
        FIfld_set_mode(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,1,
                       FI_INSERT);

        /* Redisplay the gadgets after changing the field mode */
        FIg_display(forms.part_operations_form_id, ATTRIBUTE_VALUE_MCF);
        FIg_display(forms.part_operations_form_id, SIMILAR_MODE_GRP);
        FIfld_set_mode(forms.part_operations_form_id,SIMILAR_MODE_MCF,1,
                       FI_REVIEW);
        FIg_display(PDU_form_id,SIMILAR_MODE_MCF);

        FIfld_set_mode(forms.part_operations_form_id,NP_PROJECT_FLD,0,
                       FI_INSERT);
        FIg_display(forms.part_operations_form_id,NP_PROJECT_FLD);
        FIfld_set_mode(forms.part_operations_form_id,NP_PARTNUM_FLD,0,
                       FI_INSERT);
        FIg_display(forms.part_operations_form_id,NP_PARTNUM_FLD);
        FIfld_set_mode(forms.part_operations_form_id,NP_REV_FLD,0,FI_INSERT);
        FIg_display(forms.part_operations_form_id,NP_REV_FLD);
        FIfld_set_mode(forms.part_operations_form_id,NP_PARTTYPE_FLD,0,
                       FI_INSERT);
        FIg_display(forms.part_operations_form_id,NP_PARTTYPE_FLD);
        FIfld_set_mode(forms.part_operations_form_id,NP_DESC_FLD,0,FI_INSERT);
        FIg_display(forms.part_operations_form_id,NP_DESC_FLD);
        /* Erase the SIMMODE_CHECKIN_TGL */
        FIg_erase(forms.part_operations_form_id, SIMMODE_CHECKIN_TGL);

        /* Erase the SIMMODE_COPY_TGL */
        FIg_display(forms.part_operations_form_id, SIMMODE_COPY_TGL);
        FIg_disable(forms.part_operations_form_id, SIMMODE_COPY_TGL);
        FIg_enable(forms.part_operations_form_id,SIMILAR_MODE_BTN);
}

void PDUchange_mode()

{

int      max_rows;
int      display;

     FIg_enable(forms.part_operations_form_id,REVIEW_MODE_BTN);
     FIg_enable(forms.part_operations_form_id,SIMILAR_MODE_BTN);
     FIg_enable(forms.part_operations_form_id,CHANGE_MODE_BTN);

     FIg_display(PDU_form_id,STORAGE_AREA_FLD);
     FIg_display(PDU_form_id,STORAGE_AREA_TXT);

         change_mode = TRUE;
         new_mode = FALSE;
         similar_mode = FALSE;
         review_mode = FALSE;

         /* Set NEW, SIMILAR, and REVIEW mode buttons' state to OFF */
         FIg_set_state_off(forms.part_operations_form_id,NEW_MODE_BTN);
         FIg_set_state_off(forms.part_operations_form_id,SIMILAR_MODE_BTN);
         FIg_set_state_off(forms.part_operations_form_id,REVIEW_MODE_BTN);

         /* Set CHANGE mode buttons' state to ON */
         FIg_set_state_on(forms.part_operations_form_id,CHANGE_MODE_BTN);

        /* Set File Information Palette to allow for data entry */
        FIfld_set_mode(forms.part_operations_form_id,EXISTING_FILES_MCF,0,
                       FI_INSERT);
        FIfld_set_mode(forms.part_operations_form_id,EXISTING_FILES_MCF,1,
                       FI_INSERT);
        FIfld_set_mode(forms.part_operations_form_id,EXISTING_FILES_MCF,2,
                       FI_INSERT);
        FIfld_set_mode(forms.part_operations_form_id,EXISTING_FILES_MCF,3,
                       FI_INSERT);
        FIfld_set_mode(forms.part_operations_form_id,NEW_FILES_MCF,0,
                       FI_INSERT);
        FIfld_set_mode(forms.part_operations_form_id,NEW_FILES_MCF,1,
                       FI_INSERT);
        FIfld_set_mode(forms.part_operations_form_id,NEW_FILES_MCF,2,
                       FI_INSERT);
        FIfld_set_mode(forms.part_operations_form_id,NEW_FILES_MCF,3,
                       FI_INSERT);

        /* Erase the FILE_INFO_GRP */
        FIg_erase(PDU_form_id,FILE_INFO_GRP);

        /* Display the CHANGE_MODE_GRP */
        FIg_display(PDU_form_id,CHANGE_MODE_GRP);

         /* Erase the New Part Palette */
         FIg_erase(forms.part_operations_form_id, NEW_PART_BEZ);
         FIg_erase(forms.part_operations_form_id, NEW_PART_GRP);

         /* Erase the "New File Information" text on the File Info Palette */
         FIg_erase(forms.part_operations_form_id, NEW_FILE_TXT);

        FIfld_get_num_rows(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
                           &max_rows);
        PDUremove_data(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
                       max_rows,2);

        FIfld_get_num_rows(forms.part_operations_form_id,
                           EXISTING_FILES_MCF, &max_rows);
        PDUremove_data(forms.part_operations_form_id,
                       EXISTING_FILES_MCF, max_rows,4);

        FIg_reset(forms.part_operations_form_id, NEW_FILES_MCF);
        FIg_display(forms.part_operations_form_id, NEW_FILES_MCF);

       FIfld_set_text(forms.part_operations_form_id,STORAGE_AREA_FLD,0,0,"",
                      FALSE);
       FIfld_set_text(forms.part_operations_form_id,STATE_NAME_FLD,0,0,"",
                      FALSE);
       FIfld_set_text(forms.part_operations_form_id,WORKFLOW_FLD,0,0,"",FALSE);
       FIfld_set_text(forms.part_operations_form_id,ACL_NAME_FLD,0,0,"",FALSE);

        /* Disable the ADD and DELETE FILES commands */
        FIg_disable(forms.part_operations_form_id, ADD_BTN);
        FIg_disable(forms.part_operations_form_id, DELETE_FILES_BTN);

        /* Enable all other commands */
        FIg_enable(forms.part_operations_form_id, MOVE_STATE_BTN);
        FIg_enable(forms.part_operations_form_id, ADD_TO_PROJECT_BTN);
        FIg_enable(forms.part_operations_form_id, SEARCH_BTN);
        FIg_enable(forms.part_operations_form_id, DELETE_BTN);
        FIg_enable(forms.part_operations_form_id, WHERE_USED_BTN);
        FIg_enable(forms.part_operations_form_id, CHANGE_BTN);
        FIg_enable(forms.part_operations_form_id, FLAG_CANCELFLAG_BTN);
        FIg_erase(forms.part_operations_form_id, ENTER_SELECT_TGL);
        FIg_enable(forms.part_operations_form_id,SIMILAR_MODE_BTN);
        FIg_erase(forms.part_operations_form_id,ACL_NAME_BTN);

        /* display delete files toggle */
        FIg_display(forms.part_operations_form_id, DELETE_FILES_TGL);
        FIg_disable(forms.part_operations_form_id, DELETE_FILES_TGL);
        FIg_set_state_off(forms.part_operations_form_id, DELETE_FILES_TGL);

        FIf_is_displayed(forms.part_operations_form_id, &display);
        if (!display)
          FIf_display(forms.part_operations_form_id);
}

void PDUreview_mode()

{

int      max_rows;

     FIg_enable(forms.part_operations_form_id,REVIEW_MODE_BTN);
     FIg_enable(forms.part_operations_form_id,SIMILAR_MODE_BTN);
     FIg_enable(forms.part_operations_form_id,CHANGE_MODE_BTN);

         review_mode = TRUE;
         new_mode = FALSE;
         similar_mode = FALSE;
         change_mode = FALSE;

         /* Display the FILE_INFO_MCF */
         FIg_display(forms.part_operations_form_id, FILE_INFO_GRP);

        /* Erase the ENTER/SELECT PART toggle */
        FIg_erase(forms.part_operations_form_id, ENTER_SELECT_TGL);

         /* Set NEW, SIMILAR, and CHANGE mode buttons' state to OFF */
         FIg_set_state_off(forms.part_operations_form_id,NEW_MODE_BTN);
         FIg_set_state_off(forms.part_operations_form_id,SIMILAR_MODE_BTN);
         FIg_set_state_off(forms.part_operations_form_id,CHANGE_MODE_BTN);

         /* Set REVIEW mode buttons' state to ON */
         FIg_set_state_on(forms.part_operations_form_id,REVIEW_MODE_BTN);

        /* Set the value column in the Part Attribute Value Palette to be
           non-selectable */
        FIfld_set_mode(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,1,
                       FI_REVIEW);

        /* Redisplay the gadgets after changing the field mode */
        FIg_display(forms.part_operations_form_id, ATTRIBUTE_VALUE_MCF);


        /* Set File Information Palette to be in MULTI-SELECT mode */
        FIfld_set_mode(forms.part_operations_form_id,FILE_INFO_MCF,0,
                       FI_REVIEW);
        FIfld_set_mode(forms.part_operations_form_id,FILE_INFO_MCF,1,
                       FI_REVIEW);
        FIfld_set_mode(forms.part_operations_form_id,FILE_INFO_MCF,2,
                       FI_REVIEW);
        FIfld_set_mode(forms.part_operations_form_id,FILE_INFO_MCF,3,
                       FI_REVIEW);

        /* Redisplay the gadgets after changing the field mode */
        FIg_display(forms.part_operations_form_id, FILE_INFO_MCF);

        /* Turn the list buttons for these fields off */
        FIg_erase(forms.part_operations_form_id,STORAGE_AREA_BTN);
        FIg_erase(forms.part_operations_form_id,ACL_NAME_BTN);

         /* Display the Existing Part Palette */
         FIg_display(forms.part_operations_form_id, EXISTING_PART_BEZ);
         FIg_display(forms.part_operations_form_id, EXISTING_PART_GRP);

         /* Erase the New Part Palette */
         FIg_erase(forms.part_operations_form_id, NEW_PART_BEZ);
         FIg_erase(forms.part_operations_form_id, NEW_PART_GRP);


         /* Erase the "New File Information" text on the File Info Palette */
         FIg_erase(forms.part_operations_form_id, NEW_FILE_TXT);

         /* Display "Existing File Information" text on File Info Palette */
         FIg_display(forms.part_operations_form_id, EXISTING_FILE_TXT);

        FIfld_get_num_rows(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
                           &max_rows);
        PDUremove_data(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
                       max_rows,2);

        FIg_reset(forms.part_operations_form_id,FILE_INFO_MCF);

       FIfld_set_text(forms.part_operations_form_id,STORAGE_AREA_FLD,0,0,"",
                      FALSE);
       FIfld_set_text(forms.part_operations_form_id,STATE_NAME_FLD,0,0,"",
                      FALSE);
       FIfld_set_text(forms.part_operations_form_id,WORKFLOW_FLD,0,0,"",FALSE);
       FIfld_set_text(forms.part_operations_form_id,ACL_NAME_FLD,0,0,"",FALSE);

        /* Disable commands */
        FIg_disable(forms.part_operations_form_id, ADD_BTN);
        FIg_disable(forms.part_operations_form_id, CHANGE_BTN);
        FIg_disable(forms.part_operations_form_id, MOVE_STATE_BTN);
        FIg_disable(forms.part_operations_form_id, ADD_TO_PROJECT_BTN);
        FIg_disable(forms.part_operations_form_id, DELETE_BTN);
        FIg_disable(forms.part_operations_form_id, WHERE_USED_BTN);
        FIg_disable(forms.part_operations_form_id, FLAG_CANCELFLAG_BTN);
        FIg_disable(forms.part_operations_form_id, DELETE_FILES_BTN);

        /* Enable all other commands */
        FIg_enable(forms.part_operations_form_id, SIMILAR_MODE_BTN);
        FIg_enable(forms.part_operations_form_id,FILE_INFO_MCF);
}
