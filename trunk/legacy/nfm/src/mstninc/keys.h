/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   keys.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
| Copyright (C) 1986-90   Bentley Systems, Inc., All rights reserved.	|
|									|
| "MicroStation", "MDL", and "MicroCSL" are trademarks of Bentley	|
|  Systems, Inc.							|
|									|
| Limited permission is hereby granted to reproduce and modify this	|
| copyrighted material provided that the resulting code is used only in	|
| conjunction with Bentley Systems products under the terms of the	|
| license agreement provided therein, and that this notice is retained	|
| in its entirety in any such reproduction or modification.		|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   keys.h -- MicroStation keyboard definitions				|
|									|
|									|
+----------------------------------------------------------------------*/

#ifndef __keysH__
#define __keysH__

/*----------------------------------------------------------------------+
|									|
|   MSDOS Raw Key Codes							|
|									|
+----------------------------------------------------------------------*/
#if defined (msdos)
#define F1 0x3b00
#define F2 0x3c00
#define F3 0x3d00
#define F4 0x3e00
#define F5 0x3f00
#define F6 0x4000
#define F7 0x4100
#define F8 0x4200
#define F9 0x4300
#define F10 0x4400
#define F11 0x5400    
#define F12 0x5500
#define F13 0x5600
#define F14 0x5700
#define F15 0x5800
#define F16 0x5900
#define F17 0x5a00
#define F18 0x5b00
#define F19 0x5c00
#define F20 0x5d00

#define INS_KEY		0x5200
#define DEL_KEY		0x5300
#define UP_ARRW		0x4800
#define DOWN_ARRW	0x5000
#define LEFT_ARRW	0x4b00
#define RGHT_ARRW	0x4d00
#define HOME_KEY	0x4700
#define END_KEY		0x4f00
#define PGUP_KEY	0x4900
#define PGDN_KEY	0x5100
#define CENTER_KEY	0x4c00
#define RAW_BACK_KEY	0x0e08
#define RAW_ENT_KEY	0x1c0d
#define RAW_ESC_KEY	0x011b
#define RAW_HTAB_KEY	0x0f09
#define BACK_TAB	0x0f00

#define CTL_INS		0x9200
#define CTL_DEL		0x9300
#define CTL_UP		0x8d00
#define CTL_DOWN	0x9100
#define CTL_LEFT	0x7300
#define CTL_RIGHT	0x7400
#define CTL_HOME	0x7700
#define CTL_END		0x7500
#define CTL_PGUP	0x8400
#define CTL_PGDN	0x7600
#define CTL_CENTER	0x8f00
#define CTL_ATSIGN	0x0300
#define CTL_BACK	0x0e7f
#define CTL_ENTER	0x1c0a
#define CTL_KEYPAD_ENT	0xE00A
#define CTL_TAB		0x9400

#define CTL_KEYPAD_FWDSLASH    0x9500
 
#define EXT_INS_KEY	0x52E0
#define EXT_DEL_KEY	0x53E0
#define EXT_UP_ARRW	0x48E0
#define EXT_DOWN_ARRW	0x50E0
#define EXT_LEFT_ARRW	0x4bE0
#define EXT_RGHT_ARRW	0x4dE0
#define EXT_HOME_KEY	0x47E0
#define EXT_END_KEY	0x4fE0
#define EXT_PGUP_KEY	0x49E0
#define EXT_PGDN_KEY	0x51E0

#define EXT_CTL_INS	0x92E0
#define EXT_CTL_DEL	0x93E0
#define EXT_CTL_UP	0x8dE0
#define EXT_CTL_DOWN	0x91E0
#define EXT_CTL_LEFT	0x73E0
#define EXT_CTL_RIGHT	0x74E0
#define EXT_CTL_HOME	0x77E0
#define EXT_CTL_END	0x75E0
#define EXT_CTL_PGUP	0x84E0
#define EXT_CTL_PGDN	0x76E0

/* alt keys */
#define ALT_ESC		0x0100
#define ALT_F1		0x6800
#define ALT_F2		0x6900
#define ALT_F3		0x6A00
#define ALT_F4  	0x6B00
#define ALT_F5  	0x6C00
#define ALT_F6  	0x6D00
#define ALT_F7  	0x6E00
#define ALT_F8  	0x6F00
#define ALT_F9  	0x7000
#define ALT_F10 	0x7100
#define ALT_F11 	0x8B00
#define ALT_F12 	0x8C00
#define ALT_BACKQUOTE   0x2900
#define ALT_1   	0x7800
#define ALT_2   	0x7900
#define ALT_3   	0x7A00
#define ALT_4   	0x7B00
#define ALT_5   	0x7C00
#define ALT_6   	0x7D00
#define ALT_7   	0x7E00
#define ALT_8   	0x7F00
#define ALT_9   	0x8000
#define ALT_0   	0x8100
#define ALT_HYPHEN      0x8200
#define ALT_EQUAL       0x8300
#define ALT_BACKSPACE   0x0e00

#define ALT_TAB		0xa500
#define ALT_Q   	0x1000
#define ALT_W   	0x1100
#define ALT_E   	0x1200
#define ALT_R   	0x1300
#define ALT_T   	0x1400
#define ALT_Y   	0x1500
#define ALT_U   	0x1600
#define ALT_I   	0x1700
#define ALT_O   	0x1800
#define ALT_P   	0x1900
#define ALT_LBRACKET    0x1A00
#define ALT_RBRACKET    0x1B00
#define ALT_BACKSLASH   0x2B00

#define ALT_A   	0x1E00
#define ALT_S   	0x1F00
#define ALT_D   	0x2000
#define ALT_F   	0x2100
#define ALT_G   	0x2200
#define ALT_H   	0x2300
#define ALT_J   	0x2400
#define ALT_K   	0x2500
#define ALT_L   	0x2600
#define ALT_SEMICOLON   0x2700
#define ALT_QUOTE       0x2800
#define ALT_ENTER	0x1c00

#define ALT_Z   	0x2C00
#define ALT_X   	0x2D00
#define ALT_C   	0x2E00
#define ALT_V   	0x2F00
#define ALT_B   	0x3000
#define ALT_N   	0x3100
#define ALT_M   	0x3200
#define ALT_COMMA       0x3300
#define ALT_PERIOD      0x3400
#define ALT_FWDSLASH    0x3500

#define EXT_ALT_INS	0xa200
#define EXT_ALT_DEL	0xa300
#define EXT_ALT_HOME	0x9700
#define EXT_ALT_END	0x9f00
#define EXT_ALT_PGUP	0x9900
#define EXT_ALT_PGDN	0xa100

#define EXT_ALT_UP	0x9800
#define EXT_ALT_DOWN	0xa000
#define EXT_ALT_LEFT	0x9b00
#define EXT_ALT_RIGHT	0x9d00

#define ALT_KEYPAD_ENT	0xA600

#define SHIFT_F1	0x5400
#define SHIFT_F2	0x5500
#define SHIFT_F3	0x5600
#define SHIFT_F4  	0x5700
#define SHIFT_F5  	0x5800
#define SHIFT_F6  	0x5900
#define SHIFT_F7  	0x5A00
#define SHIFT_F8  	0x5B00
#define SHIFT_F9  	0x5C00
#define SHIFT_F10 	0x5D00
#define SHIFT_F11 	0x8700
#define SHIFT_F12 	0x8800

#define CTL_F1		0x5E00
#define CTL_F2		0x5F00
#define CTL_F3		0x6000
#define CTL_F4  	0x6100
#define CTL_F5  	0x6200
#define CTL_F6  	0x6300
#define CTL_F7  	0x6400
#define CTL_F8  	0x6500
#define CTL_F9  	0x6600
#define CTL_F10 	0x6700
#define CTL_F11 	0x8900
#define CTL_F12 	0x8A00

/*----------------------------------------------------------------------+
|									|
|   IP32 Raw Key Codes							|
|									|
+----------------------------------------------------------------------*/
#elif defined (ip32)
#if !defined (KB_KEY_SHIFT)
#include </usr/include/tools.h>
#endif

#if !defined (resource)
typedef union
	{
	struct
	    {
	    byte key1;
	    byte key2;
	    byte key3;
	    byte key4;
	    } b;
	int key;
	} KeyUnion;
#endif

#define UP_ARRW		0x8f41	    /* does not require appl_keypad mode */
#define DOWN_ARRW	0x8f42	    /* " */
#define LEFT_ARRW	0x8f44	    /* " */
#define RGHT_ARRW	0x8f43	    /* " */
#define PREV_CMD	0x8f41	    /* " */
#define NEXT_CMD	0x8f42	    /* " */
#define HOME_KEY	0x8f77	    /* using KEYBD_DEC_APPL_KEYPAD_MODE */
#define END_KEY		0x8f71	    /* " */
#define PGUP_KEY	0x8f79	    /* " */
#define PGDN_KEY	0x8f73	    /* " */
#define INS_KEY		0x8f70	    /* " */
#define DEL_KEY		0x7f
#define BACK_TAB	199	/* can't get */
#define CTL_HOME	204	/* can't get */
#define CTL_END		205	/* can't get */
#define FUNC_LEADIN	0xfe
#define KEYPAD_LEADIN	0x8f
#define FIRST_FUNCKEY   0xfe02
#define LAST_FUNCKEY    0xfe6d

/*----------------------------------------------------------------------+
|									|
|   Macintosh Raw Key Codes						|
|									|
+----------------------------------------------------------------------*/
#elif defined (macintosh)
#define ENTR		0x3
#endif

/*----------------------------------------------------------------------+
|									|
|   Common Key Codes							|
|									|
+----------------------------------------------------------------------*/
#define BACK_KEY 29
#define RET_KEY 13
#define ESC_KEY 27

#define CTLC		0x03
#define CTLD		0x04
#define CTLE		0x05
#define HTAB		0x09
#define BACK_SP		0x08
#define LINE_FEED	0x0A
#define CTLQ		0x11
#define CTLR		0x12
#define CTLS		0x13
#define CTLZ		0x1A

#define SWAP_KEY F9

/*----------------------------------------------------------------------+
|                                                                       |
|   Shift/Ctl/Alt key modifier masks                                    |
|                                                                       |
+----------------------------------------------------------------------*/
#if defined (msdos)
#define	SHIFTKEY    0x3	    /* both left and right shift keys */
#define CTRLKEY	    0x4
#define ALTKEY	    0x8

#elif defined (ip32)
#define	SHIFTKEY    KB_KEY_SHIFT
#define CTRLKEY	    KB_KEY_CONTROL
#define ALTKEY	    KB_KEY_ALT

#elif defined (macintosh)
#define SHIFTKEY    shiftKey
#define CTRLKEY	    cmdKey
#define ALTKEY	    optionKey
#endif

/*----------------------------------------------------------------------+
|									|
|   Virtual Keys (16 bit)						|
|									|
|   Standard & Extended ASCII keys are 0 - 256				|
|									|
+----------------------------------------------------------------------*/
#define TOASCIICTRL(key)	(key % 32)

/* bit masks */
#define VBIT_ANYSHIFT	    0x8000
#define VBIT_ANYCTRL	    0x4000
#define VBIT_ANYALT	    0x2000

#define VBIT_SHIFT	    0x1000
#define VBIT_CTRL	    0x0800
#define VBIT_ALT	    0x0400

#define VBIT_SPECIAL	    0x0200
#define VBIT_FUNCTION	    0x0100

#define VBIT_MODANDKEYMASK  0x1FFF
#define VBIT_KEYMASK	    0x03FF

/* control keys */
#define VKEY_NULL	    0x00
#define VKEY_BREAK	    0x03
#define VKEY_BELL	    0x07
#define VKEY_BACKSPACE	    0x08
#define VKEY_TAB	    0x09
#define VKEY_LINEFEED	    0x0A
#define VKEY_VTAB	    0x0B
#define VKEY_FORMFEED	    0x0C
#define VKEY_ENTER	    0x0D
#define VKEY_ESCAPE	    0x1B

/* special keys */
#define VKEY_INSERT                  (0x01 | VBIT_SPECIAL)
#define VKEY_DELETE                  (0x02 | VBIT_SPECIAL)
#define VKEY_HOME                    (0x03 | VBIT_SPECIAL)
#define VKEY_END                     (0x04 | VBIT_SPECIAL)
#define VKEY_PAGEUP                  (0x05 | VBIT_SPECIAL)
#define VKEY_PAGEDOWN                (0x06 | VBIT_SPECIAL)
#define VKEY_UP                      (0x07 | VBIT_SPECIAL)
#define VKEY_DOWN                    (0x08 | VBIT_SPECIAL)
#define VKEY_LEFT                    (0x09 | VBIT_SPECIAL)
#define VKEY_RIGHT                   (0x0A | VBIT_SPECIAL)
#define VKEY_CENTER		     (0x0B | VBIT_SPECIAL)

#define VKEY_PRINTSCRN               (0x0C | VBIT_SPECIAL)
#define VKEY_SCRLLOCK                (0x0D | VBIT_SPECIAL)
#define VKEY_NUMLOCK                 (0x0E | VBIT_SPECIAL)
#define VKEY_PAUSE                   (0x0F | VBIT_SPECIAL)
#define VKEY_CAPSLOCK                (0x10 | VBIT_SPECIAL)
#define VKEY_SYSRQ                   (0x11 | VBIT_SPECIAL)
#define VKEY_SHIFT		     (0x12 | VBIT_SPECIAL)
#define VKEY_CONTROL		     (0x13 | VBIT_SPECIAL)
#define VKEY_ALT		     (0x14 | VBIT_SPECIAL)

#define VKEY_F1                      (0x01 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F2                      (0x02 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F3                      (0x03 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F4                      (0x04 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F5                      (0x05 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F6                      (0x06 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F7                      (0x07 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F8                      (0x08 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F9                      (0x09 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F10                     (0x0A | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F11                     (0x0B | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F12                     (0x0C | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F13                     (0x0D | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F14                     (0x0E | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F15                     (0x0F | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F16                     (0x10 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F17                     (0x11 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F18                     (0x12 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F19                     (0x13 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F20                     (0x14 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F21                     (0x15 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F22                     (0x16 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F23                     (0x17 | VBIT_SPECIAL | VBIT_FUNCTION)
#define VKEY_F24                     (0x18 | VBIT_SPECIAL | VBIT_FUNCTION)

#define VKEY_INVALID		    0xFFFF

#endif	/* __keysH__ */
