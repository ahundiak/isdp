#ifndef EXLocale
#define EXLocale

/*
	#defines for flags in ex$set_locale and ex$inq_locale
*/
	
#define EX_Text    		1
#define EX_Message 		2
#define EX_Typeface 		4
#define EX_Logical_Name 	8
#define EX_Typeface_Charmap	16

/*
	Error codes when inquiring with ex$inq_locale
*/

#define EX_Success        1
#define EX_Font_Not_Found 2

/*
	settings for 'var' field in EX_locale_var structure
*/	

#define EX_font_parameters 1
#define EX_default_font    2
#define EX_Kbd_Read_Pipe   3
#define EX_Kbd_Write_Pipe  4
#define EX_Kbd_Name        5
#define EX_Kbd_Pid         6
#define EX_alias_fonts     7
#define EX_number_alias    8
#define EX_number_fonts    9
#define EX_all_fonts      10

/*
 * settings for properties field in font parameters
 */

#define EX_Sixteen_Bit   1
#define EX_Bitmap_Font   2
#define EX_Text_Font     4
#define EX_Frac_Font     8
#define EX_Symb_Font    16
#define EX_Msg_Font     32
#define EX_Eight_Bit    64
#define EX_Demand_Font  128

#endif
