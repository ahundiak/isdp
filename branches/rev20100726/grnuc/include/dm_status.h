#include <stdio.h>

/* Possibles actions :                                                        */

#define CONTINUE   0                 /* Continue the current process          */
#define RET_STATUS 1                 /* Return with the status of the message */
#define RET_VALUE  2                 /* Return with the value specified       */
#define GOTO_VALUE 3                 /* Go to the specified value             */

/* Macro definition                                                           */

#omdef dm$status(sts     = status,
                 msg     = NULL,
                 action  = CONTINUE,
                 value   = NULL)
if(!((sts) &0x00000001))
{
#if om$specified(action)
#if om$specified(value)
#if om$equal(action,RET_VALUE)
          return((value));
#else if om$equal(action,GOTO_VALUE)
          goto value;
#endif
#else if om$equal(action,RET_STATUS)
	  return(sts);
#endif
#endif
}

#endomdef

#define print_point(c, x)
#define print_line(c, ln)
#define print_grid(c, p_grid)
#define print_matrix(c, m)

/* - debug macros - */

#omdef dbg$print(msg)
#endomdef

#omdef dbg$error(msg)
#endomdef

#omdef dbg$trace(routine=NULL)
#endomdef

