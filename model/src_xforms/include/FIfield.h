#ifndef FIfield_included
#define FIfield_included	 1

#include "FIgadget.h"
#include "FIscroll.h"
#include "FIbtn.h"


#define CHAR_LT_SYM		'\036'
#define CHAR_RT_SYM		'\037'
#define FIELD_BEZEL		 2
#define ROLL_THROUGH_SYM_WIDTH	15

struct FI_fld_flags
{
  unsigned int uds :1;		/* up/down scrolling */
  unsigned int lrs :1;		/* left/right scrolling */
  unsigned int roll_thru :1;	/* roll through */
  unsigned int wrap :1;		/* wrap if doesn't fit display */

  unsigned int draw_vscrl :1;	/* draw vert scroll bar */
  unsigned int draw_hscrl :1;	/* draw hort scroll bar */
  unsigned int clear :1;	/* clear on selection */
  unsigned int no_echo :1;	/* no echo */

  unsigned int by_line :1;	/* notify line by line */
  unsigned int ascii_only :1;	/* restrict to ascii input */
  unsigned int is_a_list :1;	/* this IS the list */
  unsigned int popup_list :1;	/* list is NOT always displayed */

  unsigned int dismiss :1;	/* dismiss list on selection */
  unsigned int valid_list :1;	/* validate with list */
  unsigned int is_a_col :1;	/* this IS part of mcf */
  unsigned int required:1;	/* required field */

/* Hebrew 30-07-90 */
  unsigned int right_to_left:1;	/* Hebrew language direction flag */
/* Hebrew 8/6/90 */
  unsigned int reverse_input:1;
  unsigned int reverse_output:1;
};

#define FI_FIELD_UDS                    1
#define FI_FIELD_LRS                    2
#define FI_FIELD_ROLL_THRU              4
#define FI_FIELD_WRAP                   8
#define FI_FIELD_DRAW_VSCRL            16
#define FI_FIELD_DRAW_HSCRL            32
#define FI_FIELD_CLEAR                 64
#define FI_FIELD_NO_ECHO              128
#define FI_FIELD_BY_LINE              256
#define FI_FIELD_ASCII_ONLY           512
#define FI_FIELD_IS_A_LIST           1024
#define FI_FIELD_POPUP_LIST          2048
#define FI_FIELD_DISMISS             4096
#define FI_FIELD_VALID_LIST          8192
#define FI_FIELD_IS_A_COL           16384
#define FI_FIELD_REQUIRED           32768
#define FI_FIELD_RIGHT_TO_LEFT      65536
#define FI_FIELD_REVERSE_INPUT     131072
#define FI_FIELD_REVERSE_OUTPUT    262144


struct FI_buf_st
{
  unsigned char * line;
  short		  sel;
  char		  broken_word;
  char		  paragraph;
  int		  color;
};


struct FIfield_instance
{
  short		field_type;
  short		mode;

  short		ar;		/* currently active row		     */
  short		ac;		/* currently active character in row */

  short		nr;		/* max # of rows - 0 infinite	*/
  short		nvr;		/* # of visible rows		*/

  short		roff;		/* row display offset		*/
  short		nc;		/* max # of chars - 0 infinite	*/

  short		nvc;		/* # of visible chars		*/
  short		coff;		/* char display offset		*/

  short		buffer_size;	/* # of rows of actual data	*/
  short		default_size;	/* # of default rows of data	*/

  int		line_height;	/* height of each line		*/
				/* ( including spacing )	*/

  int		(*validation)();  /* user defined validate func */
  int		(*format)();	  /* user defined format func	*/

  double	min;		/* minimum value		*/
  double	max;		/* maximum value		*/

  char		*fmt;		/* format specification		*/

  struct FI_buf_st *buffer;	/* actual data			*/ 
  struct FI_buf_st *defaults;	/* default data			*/

  struct FIfld_obj *list_id;	/* associated list obj ptr	*/
  struct FIscrl_obj *vscrl_id;	/* vertical scroll bar obj ptr	*/
  struct FIbtn_obj **hscrl;	/* horizontal scroll btns	*/

  struct FI_fld_flags flags;	/* field flags			*/

  int		alloc_size;

  short		prev_sel;
};


struct FIfld_obj
{
  struct FIgadget_instance	FIgadget;
  struct FIfield_instance	FIfield;
};


#endif
