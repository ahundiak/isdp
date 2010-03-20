
           /*************************************/
           /*                                   */
           /*          symbol_scrl.c            */
           /*                                   */
           /*    This file contains all of the  */
           /* functions pertaining to the       */
           /* "place button" and edit button    */
           /* commands.                         */
           /*                                   */
           /*      Programmer: Mack Draper      */
           /*      Date:       June 20, 1989    */
           /*                                   */
           /*************************************/

#include <stdio.h>

#include "FI.h"
#include "FIdyn.h"
#include "XMBpriv.h"
#include "XMB.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

/*************************************/
/* Global variables for this Command */
/*************************************/

Form Symbol_scroll = NULL;
static char Scroll_Symbol_filename[200];
static int  Scroll_Symbol_index;
static int  Top_gadget;

/************************************/
/*  External variable declarations  */
/************************************/

extern Form button_form;
extern int off_sym_index;


/*--------------------------------------------------------------------*/

void Init_scroll_area (char Symbol_file[200],
                      Font Symbol_index)
{
int x, block;
char t_str[200];

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

/*--------------------------------------------------------------------*/

void Set_scroll_view_area (Font Symbol_index)
{
int x, block, state;
char t_str[200];

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

/*--------------------------------------------------------------------*/

void Set_scroll_symbol_file (char Symbol_file[200])
{
int x;

   strcpy (Scroll_Symbol_filename, Symbol_file);
   
   for (x = 0; x < 16; x++)
   {
      FIg_set_symbol_file (Symbol_scroll, 14 + x, Scroll_Symbol_filename);
      FIg_activate (Symbol_scroll, 14 + x);
      FIg_display (Symbol_scroll, 14 + x);
   }
}

/*--------------------------------------------------------------------*/

void Display_new_top_gadget(void)
{
int x, state;
char t_str[200];

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
    {
      FIg_set_state_on ( Symbol_scroll,
		14 + (Scroll_Symbol_index - Top_gadget) );
    }
}


/**********************************************************************/
/*                           fi_symbol_scroll()                       */
/*                                                                    */
/*    This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!)                                */
/*                                                                    */
/*    This form is used to allow the operator to change the default   */
/* settings for a new button gadget, or alter the settings of an      */
/* existing button gadget.                                            */
/**********************************************************************/

/* ARGSUSED */
void fi_symbol_scroll (int    form_label,
                      int    gadget_label,
                      double value,
                      Form   form)
{
    char t_str[200];

   switch (gadget_label)
   {
       case 49:   /* Top of symbol file */
       
          if (Top_gadget != 0)
          {
             Top_gadget = 0;
             Display_new_top_gadget();
          }
          FIg_set_state_off (Symbol_scroll, 49);
          break;
          
       case 50:   /* Up one page */
       
          if (Top_gadget != 0)
          {
             Top_gadget -= 16;
             if (Top_gadget < 0)
                Top_gadget = 0;
             Display_new_top_gadget();
          }
          FIg_set_state_off (Symbol_scroll, 50);
          break;
          
       case 51:   /* Up one line */
       
          if (Top_gadget != 0)
          {
             Top_gadget -= 4;
             if (Top_gadget < 0)
                Top_gadget = 0;
             Display_new_top_gadget();
          }
          FIg_set_state_off (Symbol_scroll, 51);
          break;         

       case 52:   /* Down one line */
       
          if (Top_gadget != 240)
          {
             Top_gadget += 4;
             if (Top_gadget > 240)
                Top_gadget = 240;
             Display_new_top_gadget();
          }
          FIg_set_state_off (Symbol_scroll, 52);
          break;         

       case 53:   /* Down one page */
       
          if (Top_gadget != 240)
          {
             Top_gadget += 16;
             if (Top_gadget > 240)
                Top_gadget = 240;
             Display_new_top_gadget();
          }
          FIg_set_state_off (Symbol_scroll, 53);
          break;
          
       case 54:   /* Bottom of symbol file */
       
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

          if ( button_form )
          {
             sprintf (t_str, "%d", Scroll_Symbol_index);
             FIfld_set_text (button_form, 57, 0, 0, t_str, 0);  /* SYM_FLD */
             off_sym_index = Scroll_Symbol_index;
          }  
          break;
       
       case FI_HELP:
        
          /*  Help_topic ("Button")  */
          break; 
     
       case FI_CANCEL:
   
          FIf_erase (Symbol_scroll);
          FIg_set_state_off (Symbol_scroll, FI_CANCEL);

          if ( button_form )
             FIg_set_state_off (button_form, 18);   /* SELECT_BTN */
          break; 
   }
}

