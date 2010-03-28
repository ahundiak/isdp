/*
$Log: flib_global.h,v $
Revision 1.1.1.1  2001/12/17 22:39:13  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:16:14  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:31  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:26  root
 * *** empty log message ***
 *
 * Revision 240.0  1992/12/06  23:53:17  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:31:23  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  19:17:11  tim
 * COMMENT : added Log variable
 *
*/

#include "local.h"
#include "cdtstruct.h"
#include "struct.h"
#include <stdio.h>
static	char     Cell_nm[7];


short	Chr_code;

static unsigned long 	Offset_pos[256][2];
/*		FILE  	*Flib_cb;  font library file control block */
		long	Recover_words;		/* # of recoverable words in font library */

bool	Add_font = TRUE;
bool	Proc_dimen = FALSE;
bool	Repl_font = FALSE;


byt_dim	        Cdt_byt[256];		/*widths for byte font*/ 
word_dim 	Cdt_word[256];
lgword_dim 	Cdt_lgword[256];

library_header		*Lh_o_ptr;
font_offset_table 	*Fot_o_ptr;
font_header	 	*Fh_o_ptr;
char_dim_table 	 	*Cdt_o_ptr;
char_code_off_tbl 	*Ccot_o_ptr;
/*char_header	 	*Ch_o_ptr;*/
