class implementation COlayer;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <FI.h>
#include <limits.h>
#include "dpfile.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "dp.h"
#include "exmacros.h"

%safe
#include "COlyfmnot.h"
#include "DPgroupof.h"
%endsafe

from module   import GRmod_passon;
from DPlvldir import translate_level_to_mask, create_temp, add_name_to_lvldir,
                     verify, translate_level_to_number;


comp_names(ptr1, ptr2)

struct GRlayer *ptr1, *ptr2;

{
  static char *name1, *name2;
  static int  sts;

  name1 = ptr1->name;
  name2 = ptr2->name;

  sts = strcmp(name1, name2);

  return(sts);
}


comp_mask(ptr1, ptr2)

struct GRlayer *ptr1, *ptr2;

{
  /*
   * Description:
   *    Comparing two layer number masks to determine if ptr1->mask is greater
   *    than, less than, or equal to ptr2->mask.
   *
   * Algorithm:
   *    Compare the bits of the masks until you get a set of bits that are 
   *    different (one on and one off).  If either one was a series and they
   *    started with the same number, then the first one that's off is the
   *    least of the two mask.  If neither of the mask had a series in it,
   *    then the first one that is on is the least of the two masks.
   *
   * Assumption:
   *    At least 1 bit is on in the layer number mask.
   *
   * Return Code:
   *    sts    0    ptr1->mask = ptr2->mask
   *           1    ptr1->mask > ptr2->mask
   *          -1    ptr1->mask < ptr2->mask
   *
   * History
   *    dhm   10/24/91   redesign logic.
   */


  IGRlong  mask1[32], mask2[32];
  IGRlong  shift1, shift2;
  IGRint   i, j, sts, bit1, bit2, both_ones, series;

  OM_BLOCK_MOVE(ptr1->ly_num_mask, mask1, sizeof(IGRlong) * 32);
  OM_BLOCK_MOVE(ptr2->ly_num_mask, mask2, sizeof(IGRlong) * 32);

  sts = 0;           /* equal */
  both_ones = FALSE;
  series = FALSE;

  i = 0;
  bit1 = 0;
  bit2 = 0;
  while ( (i < 32) && (bit1 == bit2) )
  {
    shift1 = mask1[i];
    shift2 = mask2[i];

    j = 0;
    bit1 = 0;
    bit2 = 0;
    while ( (j < 32) && (bit1 == bit2) )
    {
      /*   Determine which bits are on in shift1 and shift2   */

      if (1 & shift1)
        bit1 = 1;
      else
        bit1 = 0;

      if (1 & shift2)
        bit2 = 1;
      else
        bit2 = 0;

      if ( (both_ones) && (bit1 || bit2) )   /* start at same number and */
      {                                      /* at least one is a series */
        series = TRUE;
        both_ones = FALSE;
      }
      else
        both_ones = FALSE;

      if (bit1 & bit2)     /* both bits are on */
        both_ones = TRUE;

      j++;
      shift1 >>= 1;
      shift2 >>= 1;

    }  /* end while j loop */

    i++;

  }  /* end while i loop */

  /*  Determine the return code  */

  if ( bit1 == bit2 )
  {
    sts = 0;   /* equal */
  }
  else if ( series )     /* at least one was a series */
  {
    if ( 1 & bit1 )
      sts = 1;              /* ly_num_mask1 > ly_num_mask2 */
    else if ( 1 & bit2 )
      sts = -1;             /* ly_num_mask1 < ly_num_mask2 */
  }
  else                      /* started out not equal */
  {
    if ( 1 & bit1 )
      sts = -1;             /* ly_num_mask1 < ly_num_mask2 */
    else if ( 1 & bit2 )
      sts = 1;              /* ly_num_mask1 > ly_num_mask2 */
  }

  return(sts);
}


/*
Name
    form_notification( int form_label; int gadget_label; double value;
                       char *form_ptr )

Synopsis

Description

Notes

Keywords
    form, method

History
    dhm    ??/??/91    creation date.
    dhm    09/20/93    fixes for TR's 119310276 & 119310277.
*/

method form_notification( int form_label; int gadget_label; double value;
                          char *form_ptr )
{
  IGRint             status, msg, length, flag, pos, row, col, update;
  IGRint             toggle_state, num_layer, i, j, ind, yes, no, tmp_int;
  IGRint             resp, ii, inval_char, duplicate_name;
  IGRlong            size, msg2;
  IGRshort           in_flags=0, found[MAX_LVLDEF], level;
  IGRdouble          temp_no;
  IGRchar            *text = NULL, s_layer[4], s_name[4], s_elig[4];
  IGRchar            buff[500], msgbuff[200], onbuff[50], offbuff[50];
  IGRchar            s_occupied[4], mixedbuff[50];
  struct EX_button   response_data;

  status = OM_S_SUCCESS;

  /*
   * Be sure the message field is cleared.
   */

  FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0, "", FALSE);

  /*
   * Initialize different comparison buffers to "on", "off" and "mixed" for
   * message internationalization.
   */

  ex$message( msgnumb = GR_I_LayOn,    buff = onbuff ); 
  ex$message( msgnumb = GR_I_LayOff,   buff = offbuff ); 
  ex$message( msgnumb = GR_I_LayMixed, buff = mixedbuff ); 


  switch( gadget_label )
  {
    case LAYER_FIELD:
      row = (IGRint)value;

      /*
       * Check to see if select button was hit (row = -1). If it was, then
       * Flag the row for deletion if it is a named layer.
       * Otherwise, just save the changes the user made.
       */

      if (row == -1)
      {
        FIfld_get_active_row(form_ptr, LAYER_FIELD, &row, &pos);

        /*
         * Get the proper index to access the layers array.
         */

        if (me->display_ind[0] != -1)
          ind = me->display_ind[row];
        else
          ind = row;

        /*
         * Flag the named layer for deletion.
         */

        if (me->group_flag == L_On_Flag)
        {
          /*
           * If the row has already been selected for deletion and the user
           * selects it again, then unselect it by setting it back to the
           * default color and setting the selected flag to FALSE.
           * TR 119310276 - dhm 9/21/93
           */

          if (me->group[ind].selected)
          {
              FIfld_set_line_color(form_ptr, LAYER_FIELD, row, 0, -1);
              FIfld_set_line_color(form_ptr, LAYER_FIELD, row, 2, -1);

              if (me->eligibility_enabled)
              {
                  FIfld_set_line_color(form_ptr, LAYER_FIELD, row, 3, -1);
              }

              if (me->occupied_enabled)
              {
                FIfld_set_line_color(form_ptr, LAYER_FIELD, row, 4, -1);
              }

              me->group[ind].selected = FALSE;
          }
          else  /* hasn't been selected yet */
          {
              FIfld_set_line_color(form_ptr, LAYER_FIELD, row, 0, FI_YELLOW);
              FIfld_set_line_color(form_ptr, LAYER_FIELD, row, 2, FI_YELLOW);

              if (me->eligibility_enabled)
              {
                FIfld_set_line_color(form_ptr, LAYER_FIELD, row, 3, FI_YELLOW);
              }

              if (me->occupied_enabled)
              {
                FIfld_set_line_color(form_ptr, LAYER_FIELD, row, 4, FI_YELLOW);
              }

              me->group[ind].selected = TRUE;
          }

        }
        else
        {
          ex$message( msgnumb = GR_I_NameModeLayDel, buff = msgbuff ); 
          FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0,
                         msgbuff, FALSE);
        }

      }  /* end if */
      else
      {
        FImcf_get_active_col(form_ptr, LAYER_FIELD, &col, &pos);

        /*
         * Get the changes the user made.
         */

        FIfld_get_text_length(form_ptr, LAYER_FIELD, row, col, &length);

        text = (IGRchar *) om$malloc(size = length * sizeof(IGRchar) );

        FIfld_get_text(form_ptr, LAYER_FIELD, row, col, length,
                       text, &flag, &pos);

        if (me->display_ind[0] != -1)
            ind = me->display_ind[row];
          else
            ind = row;

/* 
   If name is entered check whether it is a duplicate name or contains an
   invalid character such as '-', '=', ';' and ','. If any of the condition
   is true, don't add the name in the DPlvldir object. This is acheieved by
   setting me->group[ind].delete flag. -- TR119302357  Mrudula.
*/
        if (col == 0) { /* Check only for named layers */
          me->group[ind].delete = FALSE;  /* initialize to FALSE */
          duplicate_name = 0;

          for (ii=0; ii<me->total_num_names; ii++) {
             if (!strcmp (me->group[ii].name, text)){

           /* If ii and row is same, that means user hit the return key on 
              the existing name. Really didn't add or modified the name which
              resulted in the duplicate name. If not same, then we have a
              duplicate name.
           */ 
                if (ii != row) { 
                  duplicate_name = 1;
                  break;
                }
             }
          }

          if (duplicate_name) {
             me->group[ind].delete = TRUE;

             if (row >= me->total_num_names) {
             /* Increment only if names are added.  */
             me->num_in_group++;  /* add one to total number in the array */
             me->total_num_names++;
             }

             strcpy(me->group[ind].name, text);
             ex$message( msgnumb = GR_I_DuplicateName, buff = msgbuff,
                         type = "%s", var = `me->group[ii].number` );
             FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0, msgbuff,
                       FALSE);
             break;
          }

          inval_char = 0;
          for (ii=0; ii<length; ii++) {
            if ((text[ii] == '-') || (text[ii] == '=') ||
                (text[ii] == ';') || (text[ii] == ',')) {
                inval_char = 1;
                break;
            }
          }

          if (inval_char) {
/*           FImcf_set_active_col(form_ptr, LAYER_FIELD, 0, 0);
           FIfld_set_active_row(form_ptr, LAYER_FIELD, row, 0);
           FIfld_erase_cursor (form_ptr, LAYER_FIELD);
           FIfld_pos_cursor (form_ptr, LAYER_FIELD, row, row, 0, 0, 0, 0);*/

             me->group[ind].delete = TRUE;

             if (row >= me->total_num_names) {
             /* Increment only if names are added  */
             me->num_in_group++;  /* add one to total number in the array */
             me->total_num_names++;
             }

             strcpy(me->group[ind].name, text);
             ex$message( msgnumb = GR_I_InvalChar, buff = msgbuff,
                         type = "%c", var = `text[ii]` );
             FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0, msgbuff,
                       FALSE);
            break;
          }
        }

        if ( strlen(text) )  /* if name modified or added */
        {
          /*
           * Get the proper index to access the layers array.
           */

/*          if (me->display_ind[0] != -1)
            ind = me->display_ind[row];
          else
            ind = row;  Mrudula moved this to occur before checks for duplicate
name and invalid characters.  */

          /*
           * Check to see if they are adding a new name to a group.
           */

          if (me->group_flag == L_On_Flag)
          {
            if ( (col == 0) && (row >= me->total_num_names) )  /* addition */
            {
              if ( row >= MAX_LVLDEF )  /* check the dimension of the array */
              {
                status = OM_E_ERROR;
                goto quit;
              }

              me->num_in_group++;  /* add one to total number in the array */
              me->total_num_names++;  /* add one to the number displayed */
              me->group[ind].delete = FALSE;
              me->group[ind].selected = FALSE;
            }

          }

          /*
           * Make the change in the layers array.
           */

          if (col == 0)
          {
            strcpy(me->group[ind].name, text);

            /*
             * Once the row has been deleted, then the user can write over it.
             */

            if (me->group[ind].delete)
              me->group[ind].delete = FALSE;
          }
          else if (col == 2)
          {
            strcpy(me->group[ind].number, text);

            status = om$send(msg = message DPlvldir.translate_level_to_mask
                                   (&msg, me->group[ind].number,
                                    me->group[ind].ly_num_mask),
                             senderid = my_id,
                             targetid = me->lvl_oid,
                             targetos = me->lvl_osnum);
            if ( !(1&status) )
            {
              om$report_error(sts = status);
              goto quit;
            }

            status = om$send(msg = message DPlvldir.translate_level_to_number
                                   (&msg, me->group[ind].number,
                                    &me->group[ind].num_lys, &level),
                             senderid = my_id,
                             targetid = me->lvl_oid,
                             targetos = me->lvl_osnum);
            if ( !(1&status) )
            {
              om$report_error(sts = status);
              goto quit;
            }

            /*
             * If the occupied field has been initialized, then I need to find
             * out the occupied status of this layer group.  I also need to 
             * display it if the occupied_enabled toggle is on.
             */

            if (!me->init_occupied) /* already initialized */
            {
              yes = FALSE;
              no = FALSE;

              for (j = 0; j < MAX_LVLDEF; j++)
              {
                if ( DPlevel_check(j, me->group[ind].ly_num_mask) )
                {
                  if (me->elements_on_layer[j])
                    yes = TRUE;
                  else
                    no = TRUE;
                }

              }  /* end for j loop */

              if (yes && no)
              {
                ex$message( msgnumb = GR_I_LayMixed, buff = me->group[ind].occupied );
              }
              else if (yes)
              {
                ex$message( msgnumb = GR_I_LayYes, buff = me->group[ind].occupied); 
              }
              else
              {
                ex$message( msgnumb = GR_I_LayNo, buff = me->group[ind].occupied );
              }

              if (me->occupied_enabled)  /* display the occupied status */
              {
                FIfld_set_text(form_ptr, LAYER_FIELD, row, 4,
                               me->group[ind].occupied, FALSE);
              }

            }  /* end if occupied has been initialized */

            /* 
             * If eligibility is enabled, then I need to set the eligibility
             * field with on, off, mixed status.
             */

            if (me->eligibility_enabled)
            {
              DPproc_group_of(&msg2, me->elig_mask,
                              me->group[ind].ly_num_mask,
                              me->group[ind].elig);

              FIfld_set_text(form_ptr, LAYER_FIELD, row, 3,
                             me->group[ind].elig, FALSE);
            }

          }
          else if ( (col == 3) && (me->eligibility_enabled) )
          {
            if (me->group_flag == L_On_Flag)
            {
              update = TRUE;

              for (j = 0; j < MAX_LVLDEF; j++)
              {
                if ( DPlevel_check(j, me->group[ind].ly_num_mask) )
                {
                  if ( !strcmp(text, onbuff) )
                  {
                    LYset_level_on(j, me->elig_mask);
                    ex$message(msgnumb = GR_I_LayOn,
                               buff = me->ind_ly[j].elig);  /* set ind lay also */
                  }
                  else if ( (!strcmp(text, offbuff)) && (j != me->active_layer) )
                  {
                    LYset_level_off(j, me->elig_mask);
                    ex$message(msgnumb = GR_I_LayOff,
                               buff = me->ind_ly[j].elig);  /* set ind lay also */
                  }
                  else if ( (j == me->active_layer) && (!strcmp(text, offbuff)) )
                  {
                    ex$message(msgnumb = GR_I_ActLayNTurOff,
                               buff = buff);

                    FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0, buff,
                                   FALSE);

                    if (me->group[ind].num_lys == 1)
                    {
                      update = FALSE;
                      ex$message(msgnumb = GR_I_LayOn,
                                 buff = me->group[ind].elig);
                      FIfld_set_text(form_ptr, LAYER_FIELD, row, 3,
                                      me->group[ind].elig, FALSE);
                    }
                    else
                    {
                      ex$message(msgnumb = GR_I_LayMixed,
                                 buff = me->group[ind].elig);
                      FIfld_set_text(form_ptr, LAYER_FIELD, row, 3,
                                     me->group[ind].elig, FALSE);
                    }

                  }
                  else if ( strcmp(text, mixedbuff) )  /* if not mixed, error */
                  {
                    update = FALSE;

                    ex$message(msgnumb = GR_E_InvInpEntOnOff,
                               buff = buff);

                    FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0, buff,
                                   FALSE);
                  }

                }  /* end if level check */

              }  /* end for loop */

              if (update)
              {
                for (i = 0; i < me->num_in_group; i++)
                {
                  DPproc_group_of(&msg2, me->elig_mask,
                                  me->group[i].ly_num_mask,
                                  me->group[i].elig);
                }
 
                for (i = 0; i < me->total_num_names; i++)
                {
                  if (me->display_ind[0] != -1)
                    ind = me->display_ind[i];
                  else
                    ind = i;

                  if ( !(me->group[ind].delete) )
                  {
                    FIfld_set_text(form_ptr, LAYER_FIELD, i, 3,
                                    me->group[ind].elig, FALSE);
                  }

                }  /* end for loop */

              }  /* end update */

            }  /* end if group_flag is on */
            else
            {
              tmp_int = atoi(me->ind_ly[ind].number);

              if ( !strcmp(text, onbuff) )
              {
                LYset_level_on(tmp_int, me->elig_mask);
                ex$message(msgnumb = GR_I_LayOn,
                           buff = me->ind_ly[ind].elig);
              }
              else if ( (tmp_int != me->active_layer)&&(!strcmp(text, offbuff)) )
              {
                LYset_level_off(tmp_int, me->elig_mask);
                ex$message(msgnumb = GR_I_LayOff,
                           buff = me->ind_ly[ind].elig);
              }
              else if ( (tmp_int == me->active_layer) &&
                        (!strcmp(text, offbuff)) )
              {
                ex$message(msgnumb = GR_I_ActLayNTurOff,
                           buff = buff);

                FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0, buff, FALSE);

                FIfld_set_text(form_ptr, LAYER_FIELD, row, 3, onbuff, FALSE);
              }
              else if ( strcmp(text, mixedbuff) )  /* if not mixed, error */
              {
                ex$message(msgnumb = GR_E_InvInpEntOnOff,
                           buff = buff);

                FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0, buff,
                               FALSE);
              }

              for (j = 0; j < me->num_in_group; j++)
              {
                DPproc_group_of(&msg2, me->elig_mask,
                                me->group[j].ly_num_mask,
                                me->group[j].elig);
              }

            }

          }  /* end col == 3 */

        }  /* end if text */

      }  /* end else */

      break;


    case MODE_TOGGLE:
      /*
       * Erase the field gadget.
       */

      FIg_erase(form_ptr, LAYER_FIELD);

      /*
       * Clear the rows.
       */

      FIfld_delete_rows(form_ptr, LAYER_FIELD, 0, me->total_num_names);

      /*
       * If toggled to value mode, erase the sort toggle and delete button,
       * set name and definition field to review, and display the values
       * with their status and occupied values if enabled.  If toggled  to name
       * mode, display sort toggle and delete button, set value field to 
       * review, and display name definition fields with their status and
       * occupied values if enabled.
       */

      toggle_state = (IGRint) value;

      if (toggle_state == 1)  /* value mode */
      {
        me->group_flag = L_Off_Flag;

        FIg_erase(form_ptr, SORT_TOGGLE);
        FIg_erase(form_ptr, DELETE_BUTTON);

        FIfld_set_mode(form_ptr, LAYER_FIELD, 0, FI_REVIEW);
        FIfld_set_mode(form_ptr, LAYER_FIELD, 2, FI_REVIEW);

        status = om$send(msg = message COlayer.display_layer_field(&msg2,
                               IND_LY, NULL, MAX_LVLDEF, form_ptr),
                         senderid = my_id,
                         targetid = my_id);
        if ( !(1&status) )
        {
          om$report_error(sts = status);
          goto quit;
        }

        me->total_num_names = MAX_LVLDEF;

      }
      else if (toggle_state == 0)  /* name mode */
      {
        me->group_flag = L_On_Flag;

        FIg_display(form_ptr, SORT_TOGGLE);
        FIg_display(form_ptr, DELETE_BUTTON);

        FIfld_set_mode(form_ptr, LAYER_FIELD, 0, FI_INSERT);
        FIfld_set_mode(form_ptr, LAYER_FIELD, 2, FI_INSERT);

        status = om$send(msg = message COlayer.display_layer_field(&msg2, 
                               GROUP, NULL, me->num_in_group, form_ptr),
                         senderid = my_id,
                         targetid = my_id);
        if ( !(1&status) )
        {
          om$report_error(sts = status);
          goto quit;
        }

        me->total_num_names = me->num_in_group;

      }

      break;


    case OCCUPIED_TOGGLE:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)  /* occupied enabled */
      {
        me->occupied_enabled = TRUE;

        /*
         * If this is the first time occupied is toggle to on, then we need to
         * call the routine that initializes the occupied field in the layers
         * instance data.
         */

        if (me->init_occupied)
        {
          me->init_occupied = FALSE;

          status = om$send(msg = message COlayer.occupied(&msg2),
                           senderid = my_id,
                           targetid = my_id);
          if ( !(1&status) )
          {
            om$report_error(sts = status);
            goto quit;
          }

        }

        /*
         * Write the occupied status out to the layer field.
         */

        for (i = 0; i < me->total_num_names; i++)
        {
          if (me->display_ind[0] != -1)
            ind = me->display_ind[i];
          else
            ind = i;

          if ( (me->group_flag == L_On_Flag) && !(me->group[ind].delete) )
          {
            FIfld_set_text(form_ptr, LAYER_FIELD, i, 4,
                           me->group[ind].occupied, FALSE);

            if (me->group[ind].selected)
              FIfld_set_line_color(form_ptr, LAYER_FIELD, i, 4, FI_YELLOW);

          }
          else if ( me->group_flag == L_Off_Flag)
          {
            FIfld_set_text(form_ptr, LAYER_FIELD, i, 4,
                           me->ind_ly[ind].occupied, FALSE);
          }

        }  /* end for loop */

      }  /* end if */
      else  /* occupied disenabled */
      {
        me->occupied_enabled = FALSE;

        for (i = 0; i < me->total_num_names; i++)
          FIfld_set_text(form_ptr, LAYER_FIELD, i, 4, "", FALSE);

      }

      break;


    case ELIG_ROLL:
       ex$message( msgnumb = GR_I_LayOn2,    buff = onbuff ); 
       ex$message( msgnumb = GR_I_LayOff2,    buff = offbuff ); 

      if (me->eligibility_enabled)
      {
        /*
         * Get the user's selection.
         */

        row = (IGRint) value;

        FIfld_get_text_length(form_ptr, ELIG_ROLL, row, 0, &length);

        text = (IGRchar *) om$malloc(size = length * sizeof(IGRchar) );

        FIfld_get_text(form_ptr, ELIG_ROLL, row, 0, length, text, &flag, &pos);

        if ( !strcmp(text, onbuff) )
          me->eligibility = L_On_Flag;
        else if ( !strcmp(text, offbuff) )
          me->eligibility = L_Off_Flag;
        else
          me->eligibility = L_Ign_Flag;
      }
      else
      {
        ex$message( msgnumb = GR_I_ErrSrchCrit,
                    buff = msgbuff );
        FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0, 
                       msgbuff, FALSE);
      }

      break;


    case OCCUPIED_ROLL:
       ex$message( msgnumb = GR_I_LayYes2,    buff = onbuff ); 
       ex$message( msgnumb = GR_I_LayNo2,    buff = offbuff ); 

      if (me->occupied_enabled)
      {
        /*
         * Get the user's selection.
         */

        row = (IGRint) value;

        FIfld_get_text_length(form_ptr, OCCUPIED_ROLL, row, 0, &length);

        text = (IGRchar *) om$malloc(size = length * sizeof(IGRchar) );

        FIfld_get_text(form_ptr, OCCUPIED_ROLL, row, 0, length,
                       text, &flag, &pos);

        if ( !strcmp(text, onbuff) )
          me->occupied = L_On_Flag;
        else if ( !strcmp(text, offbuff) )
          me->occupied = L_Off_Flag;
        else
          me->occupied = L_Ign_Flag;
      }
      else
      {
        ex$message( msgnumb = GR_I_ErrSrchCrit,
                    buff = msgbuff );
        FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0,
                       msgbuff, FALSE);
      }

      break;


    case SEARCH_BUTTON:
      FIg_set_state_off(form_ptr, SEARCH_BUTTON);

      strcpy(s_layer, "");
      strcpy(s_name, "");
      strcpy(s_elig, "");
      strcpy(s_occupied, "");

      if (me->eligibility == L_On_Flag)
        strcpy(s_elig, onbuff);
      else if (me->eligibility == L_Off_Flag)
        strcpy(s_elig, offbuff);

      if (me->occupied == L_On_Flag) 
      {
        ex$message(msgnumb = GR_I_LayYes, 
                   buff = s_occupied );
      }
      else if (me->occupied == L_Off_Flag)
      {
        ex$message(msgnumb = GR_I_LayNo,
                   buff = s_occupied );
      }

      /*
       * Be sure we need to call the search routine.
       */

      if ( (me->occupied != L_Ign_Flag) || (me->eligibility != L_Ign_Flag) )
      {
        if (me->group_flag == L_On_Flag)
          num_layer = me->num_in_group;
        else
          num_layer = MAX_LVLDEF;

        status = om$send(msg = message COlayer.search(me->group, me->ind_ly,
                               s_layer, s_name, s_elig, s_occupied, &num_layer,
                               found, me->group_flag),
                         senderid = my_id,
                         targetid = my_id);
        if ( !(1&status) )
        {
          om$report_error(sts = status);
          goto quit;
        }

        if (num_layer)
        {
          /*
           * Erase the field gadget.
           */

          FIg_erase(form_ptr, LAYER_FIELD);

          /*
           * Clear the fields.
           */

          FIfld_delete_rows(form_ptr, LAYER_FIELD, 0, me->total_num_names);

          /*
           * Display the found layers.
           */

          if (me->group_flag == L_On_Flag)
            in_flags = GROUP;
          else if (me->group_flag == L_Off_Flag)
            in_flags = IND_LY;

          status = om$send(msg = message COlayer.display_layer_field( &msg2,
                                  in_flags, found, num_layer, form_ptr),
                           senderid = my_id,
                           targetid = my_id);
          if ( !(1&status) )
          {
            om$report_error(sts = status);
            goto quit;
          }

          me->total_num_names = num_layer;
        }
        else
        {
          ex$message(msgnumb = GR_I_NoMtchFnd,
                     buff = buff);

          FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0, buff, FALSE);
        }

      }  /* end if */

      break;


    case DELETE_BUTTON:
      FIg_set_state_off(form_ptr, DELETE_BUTTON);

      for (i = 0; i < me->total_num_names; i++)
      {
        if (me->display_ind[0] != -1)
          ind = me->display_ind[i];
        else
          ind = i;

        /*
         * If the row has been selected for deletion, then set the row color 
         * back to the default color, delete the row, and insert a blank row
         * as a place holder so the index doesn't get messed up.  The row
         * doesn't really get done away with until the EXIT_SAVE button is hit.
         */

        if (me->group[ind].selected)
        {
          FIfld_set_line_color(form_ptr, LAYER_FIELD, i, 0, -1);
          FIfld_set_line_color(form_ptr, LAYER_FIELD, i, 2, -1);

          if (me->eligibility_enabled)
          {
            FIfld_set_line_color(form_ptr, LAYER_FIELD, i, 3, -1);
          }

          if (me->occupied_enabled)
          {
            FIfld_set_line_color(form_ptr, LAYER_FIELD, i, 4, -1);
          }

          FIfld_delete_rows(form_ptr, LAYER_FIELD, i, 1);
          FIfld_insert_blank_row(form_ptr, LAYER_FIELD, i);

          me->group[ind].selected = FALSE;
          me->group[ind].delete = TRUE;
        }

      }  /* end for loop */      

      break;


    case SORT_TOGGLE:
      toggle_state = (int) value;

      if (toggle_state == 0)  /* alphabetic sort */
      {
        qsort( (char *)me->group, (unsigned)me->num_in_group,
               (unsigned)sizeof(struct GRlayer), (IGRint (*)())comp_names);
      }
      else if (toggle_state == 1)  /* numeric sort */
      {
        qsort( (char *)me->group, (unsigned)me->num_in_group,
               (unsigned)sizeof(struct GRlayer), (IGRint (*)())comp_mask);
      }

      /*
       * Erase the field gadget.
       */

      FIg_erase(form_ptr, LAYER_FIELD);

      /*
       * Clear the rows.
       */

      FIfld_delete_rows(form_ptr, LAYER_FIELD, 0, me->num_in_group);

      /*
       * Display the sorted named layers.
       */

      status = om$send(msg = message COlayer.display_layer_field(&msg2, GROUP,
                             NULL, me->num_in_group, form_ptr),
                       senderid = my_id,
                       targetid = my_id);
      if ( !(1&status) )
      {
        om$report_error(sts = status);
        goto quit;
      }

      break;


    case CVT_TO_WINDOW:
      /*
       * Form is now on its own.
       */

      break;


    case ACT_LAYER:
      FIfld_get_value(form_ptr, ACT_LAYER, 0, 0, &temp_no, &flag, &pos);

      me->active_layer = (IGRshort) temp_no;

      /*
       * Set the layer 'on' and display it to the form if eligibility_enabled 
       * and the layer was off.
       */

      tmp_int = (IGRint) me->active_layer;

      if ( (me->eligibility_enabled) &&
           !(DPlevel_check(tmp_int, me->elig_mask)) )
      {
        LYset_level_on(tmp_int, me->elig_mask);

        strcpy(me->ind_ly[tmp_int].elig, onbuff);

        for (i = 0; i < me->num_in_group; i++)
        {
          DPproc_group_of(&msg2, me->elig_mask,
                          me->group[i].ly_num_mask, me->group[i].elig);
        }

        for (i = 0; i < me->total_num_names; i++)
        {
          if (me->display_ind[0] != -1)
            ind = me->display_ind[i];
          else
            ind = i;

          if ( (me->group_flag == L_On_Flag) && !(me->group[ind].delete) )
          {
            if ( DPlevel_check(tmp_int, me->group[ind].ly_num_mask) )
            {
              FIfld_set_text(form_ptr, LAYER_FIELD, i, 3, me->group[ind].elig,
                             FALSE);
            }
          }
          else if ( (me->group_flag == L_Off_Flag) &&
                    (atoi(me->ind_ly[ind].number) == tmp_int) )
          {
            FIfld_set_text(form_ptr, LAYER_FIELD, i, 3, me->ind_ly[ind].elig,
                           FALSE);
          }

        }  /* end for loop */

      }  /* end if eligibility_enabled */

      break;


    case EXIT_SAVE:
      status = om$send(msg = message DPlvldir.create_temp(),
                       senderid = my_id,
                       targetid = me->lvl_oid,
                       targetos = me->lvl_osnum);
      if ( !(1&status) )
      {
        om$report_error(sts = status);
        goto quit;
      }

      for (i = 0; i < me->num_in_group; i++)
      {
        if ( !(me->group[i].delete) )
        {
          strcpy(buff, me->group[i].name);
          strcat(buff, "=");
          strcat(buff, me->group[i].number);

          status = om$send(msg = message DPlvldir.add_name_to_lvldir(&msg,
                                 buff),
                           senderid = my_id,
                           targetid = me->lvl_oid,
                           targetos = me->lvl_osnum);
          if ( !(1&status) )
          {
            om$report_error(sts = status);
            goto quit;
          }

        }  /* end if */

      }  /* end for loop */

      status = om$send(msg = message DPlvldir.verify(&msg, &row),
                       senderid = my_id,
                       targetid = me->lvl_oid,
                       targetos = me->lvl_osnum);
      if ( !(1&status) )
      {
        om$report_error(sts = status);
        goto quit;
      }
      else if (msg == MSFAIL)
      {
/*
        FIfld_set_active_row(form_ptr, LAYER_FIELD, row, 0);
        ex$message( msgnumb = GR_I_InvLay, buff = msgbuff );
        FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0, msgbuff,
                       FALSE);
*/
        break;
      }

      /* No break here */

    case EXIT_BUTTON:
      /*
       * Erase the form if not already erased.  dhm 10/24/91
       */

      FIf_is_displayed(form_ptr, &msg);

      if (msg)
      {
        status = om$send(msg = message CEO.erase_form_by_label(form_label, 1,
                                                               &msg),
                         senderid = my_id,
                         targetid = my_id);
        if (! (1&status) )
        {
          om$report_error(sts = status);
          goto quit;
        }
      }

      resp = EX_FORM_FINISHED;
      size = sizeof(struct EX_button);
      ex$putque(msg = &msg2, response = &resp, byte = &size, 
                buffer = (IGRchar *)&response_data);

      break;


    default:
      /*
       * Erase the form if not already erased.  dhm 10/24/91
       */

      FIf_is_displayed(form_ptr, &msg);

      if (msg)
      {
        status = om$send(msg = message CEO.erase_form_by_label(form_label, 1,
                                                               &msg),
                         senderid = my_id,
                         targetid = my_id);
        if (! (1&status) )
        {
          om$report_error(sts = status);
          goto quit;
        }
      }

      break;

  }  /* end switch  */


quit:
  if (text)  om$dealloc(ptr = text);

  return(status);

}

end implementation COlayer;
