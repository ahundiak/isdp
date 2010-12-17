
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
/*
#include <pums_pub.h>
*/
#include <UMS.h>

static void (*utl_prompt_msg_cb)()  = 0;	/* prompt messages */
static void (*utl_message_msg_cb)() = 0;	/* info messages */
static void (*utl_command_msg_cb)() = 0;	/* command messages */
static void (*utl_msgbox_msg_cb)()  = 0;	/* message box messages */

static void (*utl_redraw_ui_cb)()   = 0;	/* enable/disable ui */
static long (*utl_msgbox_yesno_cb)() = 0;	/* for conformation */


/******************************************************************************

Doc: utl_set_prompt_callback 

	Copyright (c) 1993
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: utl_msg.c

Author: Rick Moorefield

Date: April 15, 1993

SDM Number:

Description: This function sets the function to be called to display prompts.

Examples:
            utl_set_prompt_callback ( prompt_func );

Return Status: none

History:

******************************************************************************/


void utl_set_prompt_callback( callback )
void (*callback)();     /* i - Name of the function to call to display prompts */
{
/* set callback for prompt messages */
   utl_prompt_msg_cb = callback;
}


/******************************************************************************

Doc: utl_set_message_callback 

	Copyright (c) 1993
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: utl_msg.c

Author: Rick Moorefield

Date: April 15, 1993

SDM Number:

Description: This function sets the function to be called to display messages.

Examples:
            utl_set_message_callback ( msg_func );

Return Status: none

History:

******************************************************************************/

void utl_set_message_callback( callback )
void (*callback)();     /* i - Name of the function to call to display a message */
{
/* set callback for message messages */
   utl_message_msg_cb = callback;
}


/******************************************************************************

Doc: utl_set_command_callback 

	Copyright (c) 1993
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: utl_msg.c

Author: Rick Moorefield

Date: April 15, 1993

SDM Number:

Description: This function sets the function to be called to display the
            current command.

Examples:
            utl_set_command_callback ( prompt_func );

Return Status: none

History:

******************************************************************************/

void utl_set_command_callback( callback )
void (*callback)();     /* i - Name of the function to call to display the current command */
{
/* set callback for command messages */
   utl_command_msg_cb = callback;
}


/******************************************************************************

Doc: utl_set_msgbox_callback 

	Copyright (c) 1993
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: utl_msg.c

Author: Rick Moorefield

Date: April 15, 1993

SDM Number:

Description: This function sets the function to be called to display a
            message box.

Examples:
            utl_set_msgbox_callback ( msgbox_func );

Return Status: none

History:

******************************************************************************/

void utl_set_msgbox_callback( callback )
void (*callback)();     /* i - Name of the function to call to display a message box */
{
/* set callback for command messages */
   utl_msgbox_msg_cb = callback;
}


/******************************************************************************

Doc: utl_set_yesno_callback 

	Copyright (c) 1993
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: utl_msg.c

Author: Rick Moorefield

Date: April 15, 1993

SDM Number:

Description: This function sets the function to be called to display a
            message box with Yes and No buttons.

Examples:
            utl_set_yesno_callback ( yesno_func );

Return Status: none

History:

******************************************************************************/

void utl_set_yesno_callback( callback )
long (*callback)();
{
/* set callback for confirmation messages */
   utl_msgbox_yesno_cb = callback;
}


void utl_set_ui_callback( callback )
void (*callback)();
{
/* set callback for command messages */
   utl_redraw_ui_cb = callback;
}


void utl_prompt_msg(char *msg)
{
  if (utl_prompt_msg_cb)
  {
     (*(utl_prompt_msg_cb))(msg);
  }
}

void utl_command_msg(char *msg)
{
  if (utl_command_msg_cb)
  {
     (*(utl_command_msg_cb))(msg);
  }
}

void utl_message_msg(char *msg)
{
  if (utl_message_msg_cb)
  {
     (*(utl_message_msg_cb))(msg);
  }
}

void utl_msgbox_msg(char *msg, char*title)
{
  if (utl_msgbox_msg_cb)
  {
     (*(utl_msgbox_msg_cb))(msg,title);
  }
}


void utl_ums_msgbox_msg ( long msg_num, char *title, char *fmt, ... )
{
	va_list	vars;
	char	buf[512];
	short	sts;

        va_start ( vars, fmt );

	if(fmt==NULL)
        	sts = UMSGetByNum( buf, msg_num, 0 );
	else 
        	sts = UMSGetByNumVar ( buf, msg_num, fmt, vars );

	utl_msgbox_msg(buf, title);
        va_end ( vars );
}


void utl_redraw_ui(win_id, flag)
long win_id;
long flag;
{
  if (utl_redraw_ui_cb)
  {
     (*(utl_redraw_ui_cb))(win_id, flag);
  }
}

/*********************************************************************/

long utl_ums_yesno_box ( long title_num,long msg_num, char *fmt, ... )
{
	va_list	vars;
	char	buf[512];
	char	title[512];
	short	sts;

	
	sts = UMSGetByNum( title, title_num, 0 );
	
        va_start ( vars, fmt );

	if(fmt==NULL)
        	sts = UMSGetByNum( buf, msg_num, 0 );
	else 
        	sts = UMSGetByNumVar ( buf, msg_num, fmt, vars );

        va_end ( vars );

  	if (utl_msgbox_yesno_cb)
  	{
        	return((*(utl_msgbox_yesno_cb))(buf, title));
  	}
}
