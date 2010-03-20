/***********************************

		symbol_scrl.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "place button" and edit button */
/* commands. */
/* */
/* Programmer: Mack Draper */
/* Date: June 20, 1989 */
/* */
/*************************************/

#include <stdio.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"


#define LABEL_FLD 41 /* Needed by characteristics form */

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Symbol_scroll = NULL;
char Scroll_Symbol_filename[200];
int Scroll_Symbol_index;
int Top_gadget;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern struct gadget_struct gadget_attr;


extern Form button_form;
extern Form Symbol_form;
extern Form Toggle_form;
extern Form cklist_form;

static void Display_new_top_gadget();

/*--------------------------------------------------------------------*/

void Init_scroll_area (char *Symbol_file,
                       int Symbol_index)
{
  int x, block;
  char t_str[256];

  strcpy (Scroll_Symbol_filename, Symbol_file);
  Scroll_Symbol_index = Symbol_index;

  block = Scroll_Symbol_index / 16;

  for (x = 0; x < 16; x++)
  {
    sprintf (t_str, "%3d", (block * 16) + x);

    FIg_erase (Symbol_scroll, 30 + x);
    FIg_set_text (Symbol_scroll, 30 + x, t_str);
    FIg_display (Symbol_scroll, 30 + x);

    FIg_set_symbol_file (Symbol_scroll, 14 + x, Scroll_Symbol_filename);
    FIg_set_symbol_index (Symbol_scroll, 14 + x, (block * 16) + x);

    FIg_activate (Symbol_scroll, 14 + x);
    FIg_display (Symbol_scroll, 14 + x);
  }

  FIg_set_state_on (Symbol_scroll, 14 + (Scroll_Symbol_index - (block * 16)));
  Top_gadget = block * 16;
}

/*-----------------------------------------------------------------------*/

void Set_scroll_view_area (int Symbol_index)
{
  int x, block, state;
  char t_str[256];

  for (x = 14; x < 29; x++)
  {
    FIg_get_state (Symbol_scroll, x, &state);
    if (state)
      FIg_set_state_off (Symbol_scroll, x);
  }

  Scroll_Symbol_index = Symbol_index;

  block = Scroll_Symbol_index / 16;

  for (x = 0; x < 16; x++)
  {
    sprintf (t_str, "%3d", (block * 16) + x);

    FIg_erase (Symbol_scroll, 30 + x);
    FIg_set_text (Symbol_scroll, 30 + x, t_str);
    FIg_display (Symbol_scroll, 30 + x);

    FIg_set_symbol_index (Symbol_scroll, 14 + x, (block * 16) + x);
    FIg_activate (Symbol_scroll, 14 + x);
    FIg_display (Symbol_scroll, 14 + x);
  }

  FIg_set_state_on (Symbol_scroll, 14 + (Scroll_Symbol_index - (block * 16)));
  Top_gadget = block * 16;
}

/*-----------------------------------------------------------------------*/

void Set_scroll_symbol_file (char *Symbol_file)
{
  int xx;

  strcpy (Scroll_Symbol_filename, Symbol_file);

  for (xx = 0; xx < 16; xx++)
  {
    FIg_set_symbol_file (Symbol_scroll, 14 + xx,
        Scroll_Symbol_filename);
    FIg_activate (Symbol_scroll, 14 + xx);
    FIg_display (Symbol_scroll, 14 + xx);
  }
}

/*-----------------------------------------------------------------------*/

static void Display_new_top_gadget(void)
{
  int x, state;
  char t_str[256];

  for (x = 14; x < 29; x++)
  {
    FIg_get_state (Symbol_scroll, x, &state);
    if (state)
      FIg_set_state_off (Symbol_scroll, x);
  }

  for (x = 0; x < 16; x++)
  {
    sprintf (t_str, "%3d", Top_gadget + x);

    FIg_erase (Symbol_scroll, 30 + x);
    FIg_set_text (Symbol_scroll, 30 + x, t_str);
    FIg_display (Symbol_scroll, 30 + x);

    FIg_set_symbol_index (Symbol_scroll, 14 + x, Top_gadget + x);
    FIg_activate (Symbol_scroll, 14 + x);
    FIg_display (Symbol_scroll, 14 + x);
  }

  if ((Scroll_Symbol_index >= Top_gadget) &&
      (Scroll_Symbol_index <= (Top_gadget + 15)))
    FIg_set_state_on (Symbol_scroll, 14 + (Scroll_Symbol_index - Top_gadget));
}

/*-----------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* fi_symbol_scroll() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new button gadget, or alter the settings of an */
/* existing button gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_symbol_scroll (int form_label,
                      int gadget_label,
                      double value,
                      Form form_ptr)
{
  int state;
  char t_str[256];

  switch (gadget_label)
  {
  case 49: /* Top of symbol file */

    if (Top_gadget != 0)
    {
      Top_gadget = 0;
      Display_new_top_gadget();
    }
    FIg_set_state_off (Symbol_scroll, 49);
    break;

  case 50: /* Up one page */

    if (Top_gadget != 0)
    {
      Top_gadget -= 16;
      if (Top_gadget < 0)
        Top_gadget = 0;
      Display_new_top_gadget();
    }
    FIg_set_state_off (Symbol_scroll, 50);
    break;

  case 51: /* Up one line */

    if (Top_gadget != 0)
    {
      Top_gadget -= 4;
      if (Top_gadget < 0)
        Top_gadget = 0;
      Display_new_top_gadget();
    }
    FIg_set_state_off (Symbol_scroll, 51);
    break;

  case 52: /* Down one line */

    if (Top_gadget != 240)
    {
      Top_gadget += 4;
      if (Top_gadget > 240)
        Top_gadget = 240;
      Display_new_top_gadget();
    }
    FIg_set_state_off (Symbol_scroll, 52);
    break;

  case 53: /* Down one page */

    if (Top_gadget != 240)
    {
      Top_gadget += 16;
      if (Top_gadget > 240)
        Top_gadget = 240;
      Display_new_top_gadget();
    }
    FIg_set_state_off (Symbol_scroll, 53);
    break;

  case 54: /* Bottom of symbol file */

    if (Top_gadget != 240)
    {
      Top_gadget = 240;
      Display_new_top_gadget();
    }
    FIg_set_state_off (Symbol_scroll, 54);
    break;

  case 14:
  case 15:
  case 16:
  case 17:
  case 18:
  case 19:
  case 20:
  case 21:
  case 22:
  case 23:
  case 24:
  case 25:
  case 26:
  case 27:
  case 28:
  case 29:

    Scroll_Symbol_index = Top_gadget + gadget_label - 14;
    if (cklist_form != NULL)
    {
      FIf_is_displayed (cklist_form, &state);

      if (state)
      {
         sprintf (t_str, "%d", Scroll_Symbol_index);
         FIfld_set_text (cklist_form, 22, 0, 0, t_str, 0); /* INDEX_FLD */
         gadget_attr.off_sym_index = Scroll_Symbol_index;
         gadget_attr.on_sym_index = Scroll_Symbol_index;
      }
    }
    if (button_form != NULL)
    {
      FIf_is_displayed (button_form, &state);

      if (state)
      {
         sprintf (t_str, "%d", Scroll_Symbol_index);
         FIfld_set_text (button_form, 57, 0, 0, t_str, 0); /* SYM_FLD */
         gadget_attr.off_sym_index = Scroll_Symbol_index;
         gadget_attr.on_sym_index = Scroll_Symbol_index;
      }
    }
    if (Symbol_form != NULL)
    {
      FIf_is_displayed (Symbol_form, &state);

      if (state)
      {
         sprintf (t_str, "%d", Scroll_Symbol_index);
         FIfld_set_text (Symbol_form, 14, 0, 0, t_str, 0); /*SYM_INDEX_FLD*/
         gadget_attr.off_sym_index = Scroll_Symbol_index;
         gadget_attr.on_sym_index = Scroll_Symbol_index;
      }
    }
    if (Toggle_form != NULL)
    {
      FIf_is_displayed (Toggle_form, &state);

      if (state)
      {
         sprintf (t_str, "%d", Scroll_Symbol_index);
         FIg_get_off_symbol_index (Toggle_form, 29, &state);

         if (state == 65) /* off symbol */
         {
           FIfld_set_text (Toggle_form, 37, 0, 0, t_str, 0); /* OFF_SYM_INDEX_FLD */
           gadget_attr.off_sym_index = Scroll_Symbol_index;
         }
         else
         {
           FIfld_set_text (Toggle_form, 40, 0, 0, t_str, 0); /* ON_SYM_INDEX_FLD */
           gadget_attr.on_sym_index = Scroll_Symbol_index;
         }
       }
    }
    break;

  case FI_HELP:

    /* Help_topic ("Button") */
    break;

  case FI_CANCEL:

    FIf_erase (Symbol_scroll);
    FIg_set_state_off (Symbol_scroll, FI_CANCEL);

    if (button_form != NULL)
      FIg_set_state_off (button_form, 18); /* SELECT_BTN */
    if (Symbol_form != NULL)
      FIg_set_state_off (Symbol_form, 17); /* SELECT_BTN */
    if (Toggle_form != NULL)
    {
      FIg_set_state_off (Toggle_form, 19); /* SELECT_BTN */
      FIg_erase (Toggle_form, 29); /* ROTATE_BTN */
    }
    if (cklist_form != NULL)
      FIg_set_state_off (cklist_form, 13); /* SYM_SELECT_BTN */
    break;
  }

  return;
}
