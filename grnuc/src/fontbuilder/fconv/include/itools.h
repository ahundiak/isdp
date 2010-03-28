/*
$Log: itools.h,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:56  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:12  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:09  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:52:30  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:30:45  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  20:42:39  tim
 * COMMENT : added Log variable
 *
*/

#ifndef itools_include
#define itools_include		

/* status definitions */

#define UI_SUCCESS 0 
#define UI_FAIL    1
#define UI_OVERLAP 2 
#define UI_ALTERED 3 
#define UI_BOUNDS  4 
#define UI_NO_MENUES 5 
#define UI_NOT_FOUND 6 
#define UI_WIN_UNKNOWN 7
#define UI_NO_GADGETS  8
#define UI_RESET_BUTTON  9
#define UI_DP_BOUNDS  10
#define UI_SCROLL_BUTTON  11
#define UI_SCROLL_ITEM  12
#define UI_UNKNOWN_EVENT  13
#define UI_CMD_BUTTON  15

#define UI_KB_FOUND     5
#define UI_KB_NEED_MORE 6
#define UI_KB_NOT_FOUND 7
  
/* keyboard types */

typedef struct UIcommand_entry 
{
        char n_bytes;
        unsigned char key_sequence[6];
        short *ptr;

} UIcommand_entry;

typedef struct UIcommand_table
{
       int n_entries;
       int extension;
       struct UIcommand_entry *entries;

} UIcommand_table;

#define KB_SHORT_FORM  "/usr/ip32/dpmnu/kbshort"
#define KB_LONG_FORM   "/usr/ip32/dpmnu/kblong"

/* state definitions */

#define UNSELECTED 0
#define SELECTED   1

/* text or symbol justification definitions */

#define TOP_LEFT  1 
#define TOP_CENT  2
#define TOP_RITE  3
#define CENT_LEFT 4
#define CENT_CENT 5
#define CENT_RITE 6
#define BOT_LEFT  7
#define BOT_CENT  8
#define BOT_RITE  9


/* window types */

#define WINDOW 0
#define SR_WINDOW 1


/* slider types */

#define INTEGER 0
#define REAL    1

/* measure types */

#define POINT      0
#define PICA       1
#define INCH       2
#define METER      3
#define CENTIMETER 4
#define MILLIMETER 5
#define CICERO     6
#define DIDOT      7

/* type definintions */

typedef short GGlist[256];

typedef struct
{
	short item[256];
	int state;
	short seq_no;
	
}GGitem_list;

typedef struct
{
	int gadget_id;
	int gadget_type;
	int gadget_state;
	union {
        	int i;
		double d;
		short str[256];
	      } value;
} GGbuffer;
		

/* macro definitions - take out later */

#define check_error( status, message ) if( status != 0 ) \
                   { \
                     printf( message ); \
	             (status == 1 ? printf("Fatal error\n") : \
                      status == 2 ? printf("Overlapping gadgets\n") : \
	              status == 3 ? printf("Altered gadget\n") : \
	              status == 4 ? printf("Gadget out of bounds\n"): \
	              status == 5 ? printf("No menues exist\n"): \
	              status == 6 ? printf("Menu not found\n"): \
	              status == 7 ? printf("Unknown window type\n"): \
	              status == 8 ? printf("No gadgets exist\n"): \
	                            printf("Unknown status\n") \
                     ); \
		   }
		
#endif
