/* $Revision: 1.1 $ */
/*           cforms.h      */

#ifndef CFORMS_H

#define CFORMS_H

#include <curses.h>


#define		 CTRL(c) 	((c) & 037)
#define		 CR 		13
#define		 BS 		8
#define		 DEL 		127
#define		 NULL_COL 	999
#define		 PF1 		265
#define		 PF2 		266
#define		 PF3 		267
#define		 PF4 		268
#define		 ESC 		27
#define		 PG_UP 		264
#define		 ALT_PG_UP 	271
#define		 PG_DOWN 	349
#define		 ALT_UP 	270
#define		 ALT_DOWN 	350
#define		 SP 		32
#define		 KP0 		351
#define		 KP1 		348
#define		 KP2 		350
#define		 KP3 		349
#define		 KP4 		273
#define		 KP5 		274
#define		 KP6 		271
#define		 KP7 		269
#define		 KP8 		270
#define		 KP9 		264
#define		 KPMINUS 	999
#define		 KPDOT 		352
#define		 KPENTER 	343
#define		 KPCOMMA 	272
#define		 UNDEFINED 	9999

#define		 ALT_KEY_UP    	KP8
#define		 ALT_KEY_DOWN  	KP2

#define		 min(a,b)     	( (a) < (b) ) ? a : b
#define		 max(a,b)     	( (a) < (b) ) ? b : a


/* Built-in Keys */

#define		Meta		600
#define		Key_Up		601
#define		Key_Down	602
#define		Key_Left	603
#define		Key_Right	604
#define		Cancel		605
#define		Submit		606
#define		Page_Up		607
#define		Page_Down	608
#define		Page_Left	609
#define		Page_Right	610
#define		Incr_Value	611
#define		Decr_Value	612
#define		Refresh		613
#define		Kill_Line	614
#define		Move_to_BOL	615
#define		Move_to_EOL	616
#define		Delete		617
#define		Edit_Mode	618
#define		Top_of_Form	619
#define		Bottom_of_Form	620
#define		Help		621
#define		Advance		622
#define		Menu		623
#define		Repeat		624
#define		Quit		625
#define		Exit		626

#define		Func_C1		627
#define		Func_C2		628
#define		Func_C3		629
#define		Func_C4		630
#define		Func_C5		631
#define		Func_C6		632
#define		Func_C7		633
#define		Func_C8		634
#define		Func_C9		635
#define		Func_C10	636
#define		Func_C11	637
#define		Func_C12	638
#define		Func_C13	639
#define		Func_C14	640
#define		Func_C15	641
#define		Func_C16	642

#define		Next_Form	643
#define		Prev_Form	644
#define		Shell		645
#define		Select		646
#define		Window_Move 	647
#define		Config		648
#define		Clear		649
#define		Text_Wrap	650
#define		Yank		651
#define		Paste		652
#define		Scroll_Up	653
#define		Scroll_Down	654
#define		Scroll_Left	655
#define		Scroll_Right	656
#define		Mouse_Up	657
#define		Mouse_Down	658
#define		Mouse_Left	659
#define		Mouse_Right	660
#define		Mouse		661
#define		Select_List	662

#define		User_Def1	700
#define		User_Def2	701
#define		User_Def3	702
#define		User_Def4	703
#define		User_Def5	704
#define		User_Def6	705
#define		User_Def7	706
#define		User_Def8	707
#define		User_Def9	708
#define		User_Def10	709
#define		User_Def11	710
#define		User_Def12	711
#define		User_Def13	712
#define		User_Def14	713
#define		User_Def15	714
#define		User_Def16	715
#define		User_Def17	716
#define		User_Def18	717
#define		User_Def19	718
#define		User_Def20	719

#define		META_MASK	0x8000
#define		META(ch)	( META_MASK | ch )

#define		FI_abort_mask	0x80000000

/*  defines used in FI_set_field_links()  */

#define		 FI_disable	-1
#define		 FI_ignore	-2


/*  Field Types */

#define		 FI_ALPHA	0
#define		 FI_INT		1
#define		 FI_DOUBLE	2

/*  New Type for cforms - NOT IMPLEMENTED YET */

#define		 FI_DATETIME	3

/* Text Field Edit Modes */

#define		 FI_REVIEW         1
#define		 FI_SINGLE_SELECT  2
#define		 FI_MULTI_SELECT   3
#define		 FI_APPEND         4
#define		 FI_OVSTRIKE       5
#define		 FI_INSERT         0

/* Gadget Types */

#define		 FI_GROUP      0
#define		 FI_TOGGLE     2
#define		 FI_FIELD      3
#define		 FI_CHECKLIST  4
#define		 FI_TEXT       6
#define		 FI_BUTTON     7
#define		 FI_LINE       8
#define		 FI_RECT       10
#define		 FI_MULTI_COL  13

#define		 FI_VERT 0
#define		 FI_HORIZ 1
#define		 ASCEND 2
#define		 DESCEND 3
#define		 LINE 0
#define		 LINE_CAPPED 1
#define		 RECTANGLE 2
	

/* Event Definitions:  From tools.h */

#define	KEYBOARD_EVENT		0x00000001
#define	BUTTON_EVENT		0x00000002
#define REFRESH_EVENT		0x00000004
#define DELETE_EVENT		0x00000008
#define	COVER_EVENT		0x00000010
#define	KEYIN_EVENT		0x00000020
#define	MENUBAR_EVENT		0x00000040
#define	PTTY_EVENT		0x00000080
#define	AUX_EVENT		0x00000200
#define COLLAPSE_EVENT		0x00000400
#define	PROCESS_EVENT		0x00000800
#define	TIMER_EVENT		0x00001000
#define	WINDOW_ICON_EVENT	0x00002000
#define	WINDOW_USER_ICON_EVENT	0x00002000
#define	USER_EVENT		0x00004000
#define	SYSTEM_EVENT		0x00008000
#define MOTION_EVENT		0x00010000
#define DIGMOTION_EVENT		0x00020000
#define SWAPVS_EVENT		0x00040000
#define	EXTRA_EVENT		0x80000000
	

#define FILE_READ	0
#define FILE_WRITE	1

#define		 FI_NOT_MAPPED 999999
#define		 KEY_NOT_MAPPED 0x80000000


	/*****************************************************/
	/*** Masks for field and multicol field attributes ***/
	/*****************************************************/

#define		FI_VERT_SCROLL		0x00000001
#define		FI_HORT_SCROLL		0x00000002
#define 	FI_DISPLAY_VSCROLL      0x00000004
#define 	FI_DISPLAY_HSCROLL      0x00000008

	/***************************************/
	/*** Masks for field attributes only ***/
	/***************************************/

#define		 FI_ROLL_THRU		0x00000010	/* mode MUST be	  */
							/*  FI_SINGLE_SELECT */
#define		 FI_WRAP		0x00000020
#define		 FI_CLEAR_ON_SELECTION	0x00000040
#define		 FI_NOTIFY_BY_LINE	0x00000080

#define		 FI_ASSOCIATED_LIST	0x80000000
#define		 FI_POPUP_ASSO_LIST	0x00000200
#define		 FI_DISMISS_LIST_ON_SEL	0x00000400
#define		 FI_VALIDATE_BY_LIST	0x00000800

#define		 FI_ASCII_INPUT_ONLY	0x00001000
#define		 FI_NO_ECHO		0x00002000
#define		 FI_REQUIRED		0x00004000
/* Hebrew 30-07-90 */
#define		 FI_LEFT_TO_RIGHT	0x00000000
#define		 FI_RIGHT_TO_LEFT	0x00008000
#define		 FI_REVERSE_INPUT	0x00010000
#define		 FI_REVERSE_OUTPUT	0x00020000

#define		 FI_UPPER_CASE		0x00040000
#define		 FI_LOWER_CASE		0x00080000

#ifndef FI_H_INCLUDED

/* Text Justifications  */

#define		FI_LEFT_JUSTIFIED	0
#define		FI_RIGHT_JUSTIFIED	1
#define		FI_CENTER_JUSTIFIED	2
#define		FI_FITTED		FI_CENTER_JUSTIFIED    /* Doesn't apply to cforms */

#endif


	/*************************************************/
	/*** Masks passed in the FIf_set_attr function ***/
	/*************************************************/

#define FI_DEFAULT		0x00000000
#define FI_SAVE_RESTORE		0x00000001
#define FI_NO_BEZEL		0x00000002
#define FI_DISPLAY_COLLAPSED	0x00000004
#define FI_NOT_SCALABLE		0x00000008
#define FI_NOT_RESIZABLE	0x00000010
#define FI_LINE_BORDER		0x00000020

/*	New Attributes defined for cforms  */

#define	FI_TITLE_LEFT		0x00001000
#define	FI_TITLE_CENTER		0x00002000
#define	FI_TITLE_RIGHT		0x00004000


	/****************************************************/
	/*** Masks for multi-column field attributes only ***/
	/****************************************************/

#define		FI_DISABLE_VSCROLL	0x00000010
#define		FI_DISABLE_HSCROLL	0x00000020
#define		FI_ROW_SELECT		0x00000040
#define		FI_NO_ROW_BUTTONS	0x00000080    /* Doesn't apply to cforms */


	/***********************************************/
	/*** Masks for the gadgets "characteristics" ***/
	/***********************************************/

#define		FI_NOT_DISPLAYED	0x00000001
#define		FI_NOT_ENABLED		0x00000002
#define		FI_HILITED		0x00000004    /* Doesn't apply to cforms */
#define		FI_INITIAL_NOTIFY	0x00000008
#define		FI_NO_COMPLETE_NOTIFY	0x00000010
#define		FI_HELP_TOPIC		0x00000020
#define		FI_CMD_STRING		0x00000040
#define		FI_CMD_KEY 	     	0x00000080
#define		FI_TEXT_GADGET		0x00000100
#define		FI_NO_DITHERING		0x00000200    /* Doesn't apply to cforms */
#define		FI_VERT_SCROLL_NOTIFY	0x00000400


/* Cforms attributes  */

#define		FI_MODIFIED		0x00000800
#define		FI_LINE_CAPPED		0x00001000
#define		FI_ERASED		0x00002000
#define		FI_AUTO_POP_UP		0x00004000

#define		FI_NOT_INITIALIZED	0x00008000


  /***************************************************************/
  /*** Gadget labels reserved by the Forms Interface subsystem ***/
  /***************************************************************/

#define FI_FORM_GROUP		0
#define FI_ACCEPT		1
#define FI_EXECUTE		2
#define FI_RESET		3
#define FI_CANCEL		4
#define FI_CVT_TO_PERM_WIN	5
#define FI_HELP			6
#define FI_CTRL_GROUP		7
#define FI_PROMPT_FIELD		9
#define FI_MSG_FIELD		10


#ifndef FI_H_INCLUDED

	/***********************************/
	/*** These are error definitions ***/
	/***********************************/

#define		FI_SUCCESS			0
#define		FI_FORM_FILE_NOT_FOUND		1
#define		FI_FORM_FILE_READ_ERROR		2
#define		FI_FORM_NOT_DISPLAYED		3
#define		FI_FORM_DISPLAYED		4
#define		FI_QUIET_MODE_ON		5
#define		FI_NO_WINDOWS_AVAIL		6
#define		FI_NO_SUCH_FORM			7
#define		FI_LABEL_IN_USE			8
#define		FI_NO_SUCH_GADGET		9
#define		FI_NO_MEMORY			10
#define		FI_NO_SUCH_GROUP		11
#define		FI_NO_PASS_ON			12
#define		FI_NO_SUCH_VS			13    /* Doesn't apply to cforms */
#define		FI_INVALID_GADGET_TYPE		14
#define		FI_INVALID_FORMAT		15
#define		FI_INVALID_VERSION		16
#define		FI_ILLEGAL_VALUES		17
#define		FI_FORM_FILE_OPEN_DENIED	18
#define		FI_INVALID_BUFFER		19
#define		FI_LOAD_FONT_ERROR		20    /* Doesn't apply to cforms */
#define		FI_NO_SUCH_ENV_FUNCTION 	21    /* Doesn't apply to cforms */
#define		FI_INVALID_ROW                  22
#define		FI_INVALID_COL                  23
#define		FI_NO_CONNECTION                24
#define		FI_UNABLE_TO_SAVE_FORM		25
#define		FI_FORM_FILE_SAVE_ERROR         26
#define		FI_INVALID_NEWER_FORM_VERSION	27

/*  End of FI errors */

/*  Begin CFI errors */

#define		FI_GADGET_DISABLED    	        28
#define		FI_NO_SUCH_KEY    	        -1
#define		FI_MESSAGES_DISABLED   	        30
#define		FI_IO_ERROR	   	        31
#define		FI_UNSUPPORTED_FUNCTION         32
#define		FI_FILE_OPEN_ERROR         	33

/*  End of CFI errors */


typedef char * Form ;

#endif

#define		FI_EOF				-1
#define		FI_BORDER			0x1


#define		FIf_store_cursor(form)		_FI_pos_cursor( form, 0 )
#define		FIf_restore_cursor(form)	_FI_pos_cursor( form, 1 )
#define		FIf_store_window(form)		_FI_store_window( form, 0 )
#define		FIf_restore_window(form)	_FI_store_window( form, 1 )
#define		FIf_clear_windows()		_FI_store_window( (FORM *)NULL, 2 )

#define		FIf_inq_rows(frm)		FI_I_get_dimension( frm, 0 )
#define		FIf_inq_columns(frm)		FI_I_get_dimension( frm, 1 )

#define		FIf_enable_key(frm,key)		FIf_I_enable_key( frm, key, 0 )
#define		FIf_disable_key(frm,key)	FIf_I_enable_key( frm, key, 1 )

#define		FIg_clear_message(form,field)	FI_set_message( form, field, NULL )



/*  flag = 0 or 1 */


#endif
