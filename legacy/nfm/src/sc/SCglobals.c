#include "machine.h"
#include <stdio.h>
#include "SCstruct.h"

#ifdef OS_HPUX
/* HP PORT - IGI - 1 Jul 94 */
#include "NFMcurses.h"
#endif

int SCdebug;
FILE *SCconsole;

char SCprint_file[133];

char SCmsg_string[133];
WINDOW *SCmsg_win;

char SCref_string[133];
WINDOW *SCref_win;

char SCerr_string[133];
WINDOW *SCerr_win;

WINDOW *SCcol_win = NULL;
WINDOW *SCfree_win = NULL;
