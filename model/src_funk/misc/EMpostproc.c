/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "igrtypedef.h"

/*
  DESCRIPTION

    Declaring and defining a global variable that serves to inform
    a piece of code (typically a function/method), whether it can take up
    the responsibility of post-processing (notifying, etc.) or that it has
    already been taken up some place else (higher up in the calling sequence). 
    The variable is initialized to TRUE (perform the post-process) when the
    system is brought up. It might get toggled over and over but in a steady
    state it should always be TRUE.

  HISTORY

    SS  :  08/24/88  :  Creation
*/

static IGRushort _EMSglobal_notify = TRUE;



/*
  DESCRIPTION

    The following functions are used to control all post-processing:

    a) EMScheck_inhibit_postproc() is to be used to determine if
       post-processing must be performed at the end of a certain section
       of the code. It must be called at the beginning of the section.
       The Boolean return value gives this TRUE/FALSE data. If post-processing
       needed to be done the global flag is immediately turned off as a
       side-effect from this call. This inhibits anyone else from 
       post-processing until the flag is restored.

    c) EMSrestore_postproc() is to be used to undo any inhibiting that
       might have been done by the method/function. This is necessary, so
       that the subsequent code gets a clear slate to decide for itself 
       about post-processing. The function must be called at the end of the
       given section of the code.

  EXAMPLES

    The entire system can be divided into sections of code (typically -
    methods/functions) that fall into two categories: 1) one that has enough
    information to do the post-processing by itself, 2) one that does not
    or cannot do the post-processing. Here is an example of the former
    (for the latter, nothing special is done) where the only post-processing
    step is the notification. Special macros may be defined in some include
    file as follows (specifically for notification from within methods):

    #omdef BEGIN_NOTIFY_SECTION(p_notify_flag)
            *p_notify_flag = EMcheck_inhibit_postproc()
    #endomdef

    #omdef END_NOTIFY_SECTION (notify_flag, status, action)
            if (notify_flag)
             {
             if (1&status)
               {
               action;
               }
             EMrestore_postproc();
             }
    #endomdef


    method self_sufficient(IGRlong *msg)
    {
    IGRboolean notify;
      .
      BEGIN_NOTIFY_SECTION (p_notify_flag = &notify);
      .
      .
    wrapup:
      END_NOTIFY_SECTION (notify_flag = notify, status = *msg, 
       action = om$send (msg = message GRnotify.GRnotifymsg (arg1, arg2),
       p_chanselect = &chan_to_notify));
    }

  HISTORY

    SS  :  08/26/88  :  Creation   
*/

IGRboolean EMcheck_inhibit_postproc()
{
  if (_EMSglobal_notify)
    {
    _EMSglobal_notify = FALSE;
    return (TRUE);
    }
  else
    return (FALSE);
}

void EMrestore_postproc()
{
  _EMSglobal_notify = TRUE;
}
