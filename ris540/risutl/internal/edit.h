/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */
/*
**	NAME:							edit.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					1/93
**	ABSTRACT:
**		An editor for RIS.	
**	
**	REVISION HISTORY:
*/

#ifndef EDIT_H
#define EDIT_H
 
/*
**	INCLUDES
*/
#include <stdio.h>
#if defined(WIN32)
#include <windows.h>
#endif

/*
**	DEFINES
*/
#ifdef EDIT_GLOBAL_DEFINE
#define EDIT_EXTERN
#define EDIT_INITIAL(value) = value
#else
#define EDIT_EXTERN extern
#define EDIT_INITIAL(value)
#endif

#define EDT_DBG(s)			if (RISedt_debug) { RIScom_output_debug s; }
#define EDT_isalnum_(c)		((RIScom_isalnum(c)) || ((c) == '_'))

#define CTRL_A	1
#define CTRL_B	2
#define CTRL_D	4
#define CTRL_E	5
#define CTRL_F	6
#define CTRL_H	8
#define CTRL_I	9
#define CTRL_K	11
#define CTRL_L	12
#define CTRL_N	14
#define CTRL_P	16
#define CTRL_R	18
#define CTRL_V	22
#define CTRL_Y	25
#define CTRL_Z	26
#define	ESC		27
#define DEL		127

#define ESC_V	EOF
#define ESC_LT	EOF
#define ESC_GT	EOF
#define ESC_F	EOF
#define ESC_B	EOF

/******************************************************************************/

#if defined(unix)

#define NEWLINE_CHAR			'\n'

#define SAVE_CURSOR				{printf("7");}
#define RESTORE_CURSOR			{printf("8");}
#define HIDE_CURSOR				{printf("[?25l");}
#define SHOW_CURSOR				{printf("[?25h");}
#define SET_CURSOR_REAL(r,c)	{printf("[%d;%dH",(r),(c));}
#define SET_CURSOR(r,c)			SET_CURSOR_REAL((r),(c)+PROMPT_LEN)

#define CLR_TO_EOL				{printf("[0K");}
#define CLR_TO_EOB				{printf("[0J");}
#define INSERT_BLANKS(n)		{printf("[%d@", n);}

#define FORWARD(n)				{printf("[%dC", n);}
#define BACKWARD(n)				{printf("[%dD", n);}
#if defined(__clipper__)
#define NEXT_LINE				{printf("E");}
#else
#define NEXT_LINE				{printf("\n");}
#endif

#define REPLACE_CHARS(n)		{printf("[%dX", n);}
#define DEL_CHARS(n)			{printf("[%dP", n);}

#define PUT_CHAR(ch)			{printf("%c",ch);}
#define PUT_PROMPT(prompt)		{printf(prompt);}
#endif

/******************************************************************************/

#if defined(WIN32)
#define NEWLINE_CHAR			13

#define SAVE_CURSOR_MODE		0
#define RESTORE_CURSOR_MODE		1
#define HIDE_CURSOR_MODE		FALSE
#define SHOW_CURSOR_MODE		TRUE
#define MOVE_CURSOR_UP			0
#define MOVE_CURSOR_DOWN		1
#define MOVE_CURSOR_RIGHT		2
#define MOVE_CURSOR_LEFT		3

#define SAVE_CURSOR				{save_restore_cursor(SAVE_CURSOR_MODE)}
#define RESTORE_CURSOR			{save_restore_cursor(RESTORE_CURSOR_MODE)}
#define HIDE_CURSOR				{hide_show_cursor(HIDE_CURSOR_MODE);}
#define SHOW_CURSOR				{hide_show_cursor(SHOW_CURSOR_MODE);}
#define SET_CURSOR_REAL(r,c)	{set_cursor((r),(c)-1);}
#define SET_CURSOR(r,c)			{set_cursor((r),(c)+PROMPT_LEN-1);}

#define CLR_TO_EOL				{clr_to_eol();}
#define CLR_TO_EOB				{clr_to_eob();}

#define FORWARD(n)				{move_cursor(MOVE_CURSOR_RIGHT,n);}
#define BACKWARD(n)				{move_cursor(MOVE_CURSOR_LEFT,n);}

#define NEXT_LINE				{printf("\n");}

#define	REPLACE_CHARS(n)
#define PUT_CHAR(ch)			{printf("%c",ch);}
#define PUT_PROMPT(prompt)		{printf(prompt);}

#define PERR(bSuccess, api) \
	{if (!(bSuccess)) perr(__FILE__, __LINE__, api, GetLastError());}

#endif

/******************************************************************************/

#if defined(DOS)
#define MOVE_CURSOR(r,c)	{printf("[%d;%dH", r, c+PROMPT_LEN);}

#define NEWLINE_CHAR			13

#define SAVE_CURSOR				{printf("[s");}
#define RESTORE_CURSOR			{printf("[u");}

#define HIDE_CURSOR				{printf("[?25l");}
#define SHOW_CURSOR				{printf("[?25h");}
#define SET_CURSOR_REAL(r,c)	{printf("[%d;%dH",(r),(c));}
#define SET_CURSOR(r,c)			SET_CURSOR_REAL((r),(c)+PROMPT_LEN)

#define CLR_TO_EOL				{printf("[0K");}
#define CLR_TO_EOB\
{ \
	int i;\
	SAVE_CURSOR;\
	for(i = home_row; i <= max_row; i++)\
	{\
		MOVE_CURSOR(i,1);\
		CLR_TO_EOL;\
	}\
	RESTORE_CURSOR;\
}

#define FORWARD(n)				{printf("[%dC", n);}
#define BACKWARD(n)				{printf("[%dD", n);}

#define NEXT_LINE				{printf("\n");}

#define REPLACE_CHARS(n)		{printf("[%dX", n);}
#define DEL_CHARS(n)			{printf("[%dP", n);}

#define PUT_CHAR(ch)			{printf("%c",ch);}
#define PUT_PROMPT(prompt)		{printf(prompt);}
#endif

/******************************************************************************/

#define RIS_CMD_FILE		"history.ris"
#define PROMPT1				"ris> "
#define PROMPT2				"   > "
#define PROMPT_LEN			(sizeof(PROMPT1)-1)
#define SEARCH_PROMPT		"Search for> "
#define SEARCH_PROMPT_LEN	(sizeof(SEARCH_PROMPT)-1)

#define MAX_SAVE_CMDS	50

#define VI		0
#define EMACS	1

#define VI_COMMAND_MODE			0
#define VI_INSERT_MODE			1
#define	VI_SEARCH_MODE			2
#define	VI_DELETE_MODE			3
#define	VI_CHANGE_MODE			4
#define	VI_REPLACE_MODE			5
#define	VI_REPLACE_1_CHAR_MODE	6
#define VI_NEWLINE_CHAR			''

/*
**	TYPES
*/

/*
**	VARIABLES
*/
EDIT_EXTERN int		RISedt_debug		EDIT_INITIAL(0); 

#if defined (__clipper__)
EDIT_EXTERN int		WINDOW_ROWS			EDIT_INITIAL(24);
EDIT_EXTERN	int		WINDOW_COLS			EDIT_INITIAL(80);
#endif
#if defined (sun) || defined(__Sol2__) || defined(Soli) || defined(__hpux__)
EDIT_EXTERN int		WINDOW_ROWS			EDIT_INITIAL(35);
EDIT_EXTERN	int		WINDOW_COLS			EDIT_INITIAL(80);
#endif
#if defined(WIN32) || defined (DOS)
EDIT_EXTERN int		WINDOW_ROWS			EDIT_INITIAL(0); /* filled in later */
EDIT_EXTERN	int		WINDOW_COLS			EDIT_INITIAL(0); /* filled in later */
#endif
#if defined(WIN32)
EDIT_EXTERN HANDLE	hStdIn, hStdOut;
#endif
#endif
