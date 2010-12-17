/***********************************

		review_seq.c

***********************************/

/*
  History
	04-28-92	sml		ANSI-ized; removed unused vars
	05-07-92	sml		changed var type for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "review sequence" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Apr. 3, 1989 */
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

int Loop_check_total_gadgets;
int Loop_check[1000];
/* dmb:08/31/92:This should be extern: Use the one defined in create_seq */
extern struct seq_struct seq_list[1001];

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern Form work_form;
extern Form Message_form;
extern int command_is_active;
extern char current_command_string[80];

extern int Total_gadgets;
extern int Next_in_sequence;

/*************************************************************************/
/* */
/* kill_review_sequence() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to REVIEW_SEQ indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_review_sequence(void)
{
char t_str[500];

  if (command_is_active == REVIEW_SEQUENCE)
  {
     command_is_active = 0;
     strcpy (current_command_string, "None");

     FIg_set_text (Message_form, 11, "");
     FIg_set_text (Message_form, 22, "");
     UMSGetByNum (t_str, FB_P_SELCOM, 0);
     FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

     if (work_form != NULL) /* Form already displayed */
     {
        FIf_set_builder_mode_off ((struct FIform_obj *)work_form);
     }
  }
}

/*--------------------------------------------------------------------*/

Draw_line_between_gadgets (int from_gadget,
                           int to_gadget)
{
  int	x1, y1, x2, y2; 	/*, ii;	not used */
/*  int	gadget_index = 0;	not used */
  int	xpos, ypos, xsize, ysize, x;
  int   gad_index;

   FIg_get_location (work_form, from_gadget, &xpos, &ypos);
   FIg_get_size (work_form, from_gadget, &xsize, &ysize);
   x1 = xpos + (xsize / 2);
   y1 = ypos + (ysize / 2); 

   FIg_get_location (work_form, to_gadget, &xpos, &ypos);
   FIg_get_size (work_form, to_gadget, &xsize, &ysize);
   x2 = xpos + (xsize / 2);
   y2 = ypos + (ysize / 2); 

   /* sml:05-07-92	initialized gad_index for ANSI purposes */
   gad_index = -10;

   for (x = 0; x < Total_gadgets; x++)
      if (seq_list[x].gadget == from_gadget)
         gad_index = x;

   if (gad_index != -10)	/* add condition, just to be sure */
     Draw_arrow (FI_YELLOW, x1, y1, x2, y2, gad_index);
}

/*--------------------------------------------------------------------*/

Backtrack (int gadget)
{
  int x, y, stop_here;

  for ( x = 0; x < Total_gadgets; x++ )
    {
      if ( seq_list[x].to_gadget == gadget )
	{
          Draw_line_between_gadgets ( seq_list[x].gadget, gadget );
            
          Refresh_lines (); 
          
          stop_here = 0;
         
	  for ( y = 0; y < Loop_check_total_gadgets; y++ )
	    {
	      if ( Loop_check[y] == seq_list[x].gadget )
                {
                  stop_here = 1;
                  break;
                } 
	    }
            
	  if ( stop_here != 1 )
            {
              Loop_check[Loop_check_total_gadgets] = seq_list[x].gadget;
              Loop_check_total_gadgets++;
              Backtrack (seq_list[x].gadget);
            }
	}
    }
}

/*--------------------------------------------------------------------*/

/**********************************************************************/
/*                                                                    */
/*                       execute_review_sequence()                    */
/*                                                                    */
/*  This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the    */
/* builder mode to on for the work_form.  As a result the gadgets will*/
/* no longer change their state when poked.  They will just call their*/
/* gadget notification routine.                                       */
/*                                                                    */
/**********************************************************************/

void execute_review_sequence(void)
{
  int status;
  int seq_gadget;
  int not_finished, continue_inner_loop;
  int xsize, ysize;
  Window window;		/* change from int to Window for ANSI */
  int display_flag, hilite_flag;
  int accept_x, accept_y, mode;
  int x;
  int gadget_index = 0;
  int connection_flag, gadget1, gadget2;
/*
, perform_backtrack; not used
*/
  char t_str[500];

   if (work_form == NULL)
   {
      kill_review_sequence();
   }
   else
   {  
      UMSGetByNum (t_str, FB_I_REVSEQ, 0);
      FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
      UMSGetByNum (t_str, FB_I_DETCURSEQ, 0);
      FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
      FIg_set_text (Message_form, 33, "");

      Determine_current_sequences();

      FIf_set_builder_mode_on ((struct FIform_obj *)work_form);
   
      not_finished = 1; 
      FIf_get_window (work_form, &window); 

      while (not_finished)
      {
         mode = 0;  /* make operator enter data point */

         UMSGetByNum (t_str, FB_P_SELSEQGDT, 0);
         FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

         status = Select_gadget (&seq_gadget, &xsize, &ysize, &display_flag,
                                 &hilite_flag, &accept_x, &accept_y, mode);

         Loop_check_total_gadgets = 1;
         Loop_check[0] = seq_gadget;

         Clean_up_lines();

         FIg_set_text (Message_form, 22, "");

         if (status == 2)  /* Success */
         {
       	    connection_flag = 0;

       	    for ( x = 0; x < Total_gadgets; x++ )
	      {
       	        if ( seq_list[x].gadget == seq_gadget )
       	          {
       	            gadget_index = x;
       	            break;
       	          }
	      }
       	       
       	    if (seq_list[gadget_index].to_gadget > 0)
       	       connection_flag = 1;
       	       
       	    for (x = 0; x < Total_gadgets; x++)
	      {
       	        if (seq_list[x].to_gadget == seq_gadget)
       	          {
       	            connection_flag = 1;
       	            break;
       	          }
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
       	           FIg_get_next_in_seq (work_form, gadget1, &gadget2);
       	           
       	           if (gadget2 > 0)
       	           {
       	              Draw_line_between_gadgets (gadget1, gadget2);
       	              gadget1 = gadget2;
       	              
       	              for (x = 0; x < Loop_check_total_gadgets; x++)
			{
       	                  if ( Loop_check[x] == gadget2 )
       	                    {
       	                      continue_inner_loop = 0;
       	                      break;
       	                    }
			}
       	                 
       	              Loop_check[Loop_check_total_gadgets] = gadget2;
       	              Loop_check_total_gadgets++;
       	           }
       	           else
       	              continue_inner_loop = 0;
       	        }
       	        
                Refresh_lines();

       	        /* Next display any gadgets that precede it in the sequence */

/*
                perform_backtrack = 1;

                for (x = 0; x < Total_gadgets; x++)
		  {
                    if (seq_list[x].to_gadget == seq_gadget)
       	            {
       	              perform_backtrack = 0;
       	              break;
       	            } 
		  }
       	       
       	        if ( perform_backtrack )
		  {
                   Backtrack (seq_gadget);
		  }
*/
       	    }
         }
         else
            not_finished = 0;
      }
   
      kill_review_sequence();
/*
      Clean_up_lines();
*/
   }
}

