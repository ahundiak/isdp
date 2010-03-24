#include <igrtypedef.h>
#include <msdef.h>
#include <exms.h>
#include <msmacros.h>



extern int   EX_larger_screen;
extern short MS_Gs_messages_on;

/************************** COMMAND MESSAGE ***************************/
/*                                                                    */
/*   This routine displays the message in the top left portion of     */
/*   the control strip.                                               */
/*                                                                    */
/**********************************************************************/

void UI_message(symstr)
 char *symstr;
 {
  if (MS_Gs_messages_on) 
  {
      ex$message(in_buff=symstr,field=MESSAGE_FIELD,justification=CENTER_JUS); 
  }
 } /* UI_message */


/************************** STATUS MESSAGE ****************************/
/*                                                                    */
/*   This routine displays the message in the top right portion of    */
/*   the control strip.                                               */
/*                                                                    */
/**********************************************************************/

void UI_status(symstr)
 char *symstr;
 {
  if (MS_Gs_messages_on) 
  {
      ex$message(in_buff=symstr,field=ERROR_FIELD,justification=CENTER_JUS); 
  }
 } /* UI_status */

/************************** PROMPT MESSAGE ****************************/
/*                                                                    */
/*   This routine displays the message in the bottom left portion of  */
/*   the control strip.                                               */
/*                                                                    */
/**********************************************************************/

void UI_prompt(symstr)
 char *symstr;
 {
  if (MS_Gs_messages_on) 
  {
      ex$message(in_buff=symstr,field=PROMPT_FIELD,justification=RIGHT_JUS); 
  }
 } /* UI_prompt */

/************************** ECHO   MESSAGE ****************************/
/*                                                                    */
/*   This routine displays the message in the bottom right portion of */
/*   the control strip.                                               */
/*                                                                    */
/**********************************************************************/

void UI_echo(symstr)
 char *symstr;
 {
  if (MS_Gs_messages_on) 
  {
      ex$message(in_buff=symstr,field=KEYIN_FIELD,justification=LEFT_JUS); 
  }
 } /* UI_echo */
