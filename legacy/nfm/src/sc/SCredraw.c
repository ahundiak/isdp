#include "machine.h"
#include <ctype.h>

#include "SCstruct.h"
#include "SCextern.h"

#ifdef OS_HPUX
/* HP PORT - IGI - 1 Jul 94 */
#include "NFMcurses.h"
#endif

int SCredraw_forms()
  {

    SCmsg_win = newwin(1,80,2,0);
    wattrset(SCmsg_win,A_REVERSE);

    SCref_win = newwin(1,80,3,0);
    wattrset(SCref_win,A_REVERSE);

    refresh();

    touchline(stdscr,5,19);

    update_cmd_win();

    return (0);
  }


