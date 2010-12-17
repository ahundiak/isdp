/* $Revision: 1.1 $ */
#include "dba.ext"
#include <signal.h>
#include "script.def"
#include "keys.def"

extern int dba_abort_flag;
extern long dba_bug_reload_function;

static jumpstacktype save_abort_flag_stack;

#if !defined __WIN16__ && !defined __WIN32__ && !defined _MAC_
static void (*old_sigcld_handler)();
#endif

/*
    Function:	dba_util_rpt_save_env
    Author:	Tim A. Thompson
    Date:	14-DEC-92
*/

long dba_util_rpt_save_env (bfunc)
functiontype *bfunc;
{
  dba_int_push (&save_abort_flag_stack, (long) dba_abort_flag);
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_util_rtp_restore_env
    Author:	Tim A. Thompson
    Date:	14-DEC-92
*/

long dba_util_rpt_restore_env (bfunc)
functiontype *bfunc;
{
  int (*debug)();

  dba_abort_flag = (int) dba_int_pop (&save_abort_flag_stack);
  if ((debug = dba_inq_service (DBA_DEBUG_ACTIVE)) && (*debug)())
    dba_bug_reload_function = 1;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_util_rpt_mod_return
    Author:	Tim A. Thompson
    Date:	14-DEC-92
*/

void dba_util_rpt_mod_return (status)
int *status;
{
  if (*status && *status != 1)
    *status = 99;
}


/*
    Function:	dba_util_fix_98
    Author:	Tim A. Thompson
    Date:	20-JAN-93
*/

void dba_util_fix_98 (status)
int *status;
{
  if (*status == 98)
    *status = 0;
}


#if !defined __WIN16__ && !defined __WIN32__ && !defined _MAC_
/*
    Function:	dba_util_save_sigcld
    Author:	Tim A. Thompson
    Date:	19-JAN-93
*/

long dba_util_save_sigcld (bfunc)
functiontype *bfunc;
{
  old_sigcld_handler = sigset (SIGCLD, SIG_DFL);
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_util_restore_sigcld
    Author:	Tim A. Thompson
    Date:	19-JAN-93
*/

long dba_util_restore_sigcld (bfunc)
functiontype *bfunc;
{
  sigset (SIGCLD, old_sigcld_handler);
  return SCRERR_SUCCESS;
}
#endif
