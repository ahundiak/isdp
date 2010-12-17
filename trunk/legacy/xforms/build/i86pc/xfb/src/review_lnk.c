/***********************************

		review_lnk.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		changed local var type for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "review data link" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Apr. 4, 1989 */
/* */
/*************************************/

#include <stdio.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"


/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/


/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern int Loop_check_total_gadgets;
extern int Loop_check[1000];

extern int Total_gadgets;
extern int Next_in_sequence;

extern struct seq_struct seq_list[1000];	       

extern Form work_form;
extern Form Message_form;
extern int command_is_active;
extern char current_command_string[80];

/*************************************************************************/
/* */
/* kill_review_data_link() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to REVIEW_LNK indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_review_data_link(void)
{
  char t_str[256];

  if (command_is_active == REVIEW_DATA_LINK)
  {
     command_is_active = 0;
     strcpy (current_command_string, "None");

     FIfld_set_text (Message_form, 11, 0, 0, "", 0);
     FIfld_set_text (Message_form, 12, 0, 0, "", 0);
     UMSGetByNum (t_str, FB_P_SELCOM, 0);
     FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

     if (work_form != NULL) /* Form already displayed */
     {
        FIf_set_builder_mode_off ((struct FIform_obj *)work_form);
     }
  }
}

/*--------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* execute_review_data_link() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_review_data_link(void)
{
  int status;
  int seq_gadget;
  int not_finished, continue_inner_loop;
  int xsize, ysize;
  Window window;		/* changed from int to Window for ANSI */
  int display_flag, hilite_flag;
  int accept_x, accept_y, mode;
  int x;
  int gadget_index = 0;
  int connection_flag, gadget1, gadget2, perform_backtrack;
  char t_str[500];

   if (work_form == NULL)
   {
      kill_review_data_link();
   }
   else
   {  
      UMSGetByNum (t_str, FB_I_REVDATLNK, 0);
      FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);

      UMSGetByNum (t_str, FB_I_DETCURLNK, 0);
      FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
      FIfld_set_text (Message_form, 33, 0, 0, "", 0);

      Determine_current_data_links();

      FIf_set_builder_mode_on ((struct FIform_obj *)work_form);
   
      not_finished = 1; 
      FIf_get_window (work_form, &window); 

      while (not_finished)
      {
         mode = 0;  /* make operator enter data point */

         UMSGetByNum (t_str, FB_P_SELLNKGDT, 0);
         FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

         status = Select_gadget (&seq_gadget, &xsize, &ysize, &display_flag,
                                 &hilite_flag, &accept_x, &accept_y, mode);

         Loop_check_total_gadgets = 1;
         Loop_check[0] = seq_gadget;

         Clean_up_lines();

         FIfld_set_text (Message_form, 22, 0, 0, "", 0);

         if (status == 2)  /* Success */
         {
       	    connection_flag = 0;
       	    
       	    for (x = 0; x < Total_gadgets; x++)
       	       if (seq_list[x].gadget == seq_gadget)
       	       {
       	          gadget_index = x;
       	          break;
       	       }
       	       
       	    if (seq_list[gadget_index].to_gadget != 0)
       	       connection_flag = 1;
       	       
       	    for (x = 0; x < Total_gadgets; x++)
       	       if (seq_list[x].to_gadget == seq_gadget)
       	       {
       	          connection_flag = 1;
       	          break;
       	       }
       	       
       	    if (connection_flag == 0)
       	    {
               UMSGetByNum (t_str, FB_E_NOTLNKED, 0);
               FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);

       	       Refresh_lines ();
       	    }
       	    else
       	    {
       	    	/* First display any gadgets that follow this gadget  */
       	    	/* in the sequence.                                   */
       	    	
       	        gadget1 = seq_gadget;
       	        
       	        continue_inner_loop = 1;
       	        
       	        while (continue_inner_loop)
       	        {
       	           FIg_get_pass_data (work_form, gadget1, &gadget2);
       	           
       	           if (gadget2 != -1)
       	           {
       	              Draw_line_between_gadgets (gadget1, gadget2);
       	              Refresh_lines ();
       	              gadget1 = gadget2;
       	              
       	              for (x = 0; x < Loop_check_total_gadgets; x++)
       	                 if (Loop_check[x] == gadget2)
       	                 {
       	                    continue_inner_loop = 0;
       	                    break;
       	                 }
       	                 
       	              Loop_check[Loop_check_total_gadgets] = gadget2;
       	              Loop_check_total_gadgets++;
       	           }
       	           else
       	              continue_inner_loop = 0;
       	        }
       	        
       	        /* Next display any gadgets that preceed it in the sequence */

                perform_backtrack = 1;

                for (x = 0; x < Total_gadgets; x++)
                   if (seq_list[x].to_gadget == seq_gadget)
       	           {
       	              perform_backtrack = 0;
       	              x = Total_gadgets;
       	           } 
       	       
       	        if (perform_backtrack)
                   Backtrack (seq_gadget);

/*
                for (x = 1000; x < Next_line_gadget_label; x++)
                   FIg_display (work_form, x);
*/
       	    }
         }
         else
            not_finished = 0;
      }
   
      kill_review_data_link();
   }
}
