/*
  FILE DESCRIPTION

    This file contains the definition and declaration of the "error stack",
    which stores the sequence in which the functions unwind after an 
    error has occurred. The stack is built by the "wrapup" of the functions
    that are on the program execution stack when the error occurred. It
    contains information about the nature of the error that took place.
    Functions are provided to query and manipulate this stack. There is a
    maximum to the stack, ie, the stack gets truncated after this max is
    reached.
*/
#include <malloc.h>

#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/errstack.h"

struct errstackentry
{
  struct PWerrentry errentry;
  int stackcode;
};

static struct errstackentry *_p_errstack = NULL;
static int _stackptr = FIRST;

static void update_error_stack();
static PWboolean get_error_stack();

#define _INACTIVE  0
#define _ACTIVE    1
#define _TRUNCATED 2

#define _NOT_FOUND -1

/*
  DESCRIPTION

  The following is the set of functions used at the "wrapup" line of
  a function. This is the means of creating entries on the stack. Note
  that the stack grows until the max-element has been reached and thereafter,
  the next entry always REWRITES the last entry. This behaviour is adopted
  so that there is a record of the unwinding stack from the deepest
  function and there is a record of the highest level function too. 
  Intermediate function calls maybe lost.
*/

PWboolean pwPushError 
(
  PWresult retcode
)
{
  if (get_error_stack())
  {
    _p_errstack[_stackptr].stackcode = retcode;
    _p_errstack[_stackptr].errentry.type = PWerrentry_null;

    update_error_stack();
    return TRUE;
  }
  else
  {
    return FALSE;
  }
}

PWboolean pwPushErrorId 
(
  PWresult retcode,
  PWobjid id
)
{
  if (get_error_stack())
  {
    _p_errstack[_stackptr].stackcode = retcode;
    _p_errstack[_stackptr].errentry.type = PWerrentry_id;
    _p_errstack[_stackptr].errentry.id1 = id;
    
    update_error_stack();
    return TRUE;
  }
  else
  {
    return FALSE;
  }
}

PWboolean pwPushErrorIdVal 
(
  PWresult retcode,
  PWobjid id,
  double val
)
{
  if (get_error_stack())
  {
    _p_errstack[_stackptr].stackcode = retcode;
    _p_errstack[_stackptr].errentry.type = PWerrentry_idval;
    _p_errstack[_stackptr].errentry.id1 = id;
    _p_errstack[_stackptr].errentry.val = val;

    update_error_stack();
    return TRUE;
  }
  else
  {
    return FALSE;
  }
}

PWboolean pwPushErrorIdId 
(
  PWresult retcode,
  PWobjid id1,
  PWobjid id2
)
{
  if (get_error_stack())
  {
    _p_errstack[_stackptr].stackcode = retcode;
    _p_errstack[_stackptr].errentry.type = PWerrentry_idid;
    _p_errstack[_stackptr].errentry.id1 = id1;
    _p_errstack[_stackptr].errentry.id2 = id2;
    
    update_error_stack();
    return TRUE;
  }
  else
  {
    return FALSE;
  }
}

/*
  DESCRIPTION

  The following functions help retrieve information from the error stack.
  These functions are primarily used by commands to inform the user
  of the error situation. Most of these query functions, AUTOMATICALLY
  initialize the stack in readiness for the subsequent operation. The
  one exception is the pwGetErrorAtInx. This latter function is provided
  as a means of querying the stack in detail (if anyone ever needs to do
  this). In this case, the onus is on the user to call the init-stack
  function. All of the functions return TRUE/FALSE, depending whether they
  are successfully returning an error-entry or not.


  NOTES

  The function pwGetFirstError returns the first entry that went
  on the stack, which is where the error had it's roots.

  The function pwGetFirstInfoError returns the first entry that 
  contains any kind of "id" information. This is useful as the command can 
  display this object and further interpret the 'retcode' and give a 
  meaningful message to the user.

  The function pwGetErrorAtInx returns the entry at the specified index,
  zero being the first entry. If no valid entry exists at this index
  the return code is FALSE.
*/

PWboolean pwGetFirstError 
(
  struct PWerrentry *p_errentry
)
{
  PWboolean funcval;

  if (_stackptr && _p_errstack[FIRST].stackcode == _ACTIVE)
  {
    *p_errentry = _p_errstack[FIRST].errentry;
    funcval = TRUE;
  }
  else
  {
    funcval = FALSE;
  }
  
  pwInitErrorStack();
  return (funcval);
}

int pwGetFirstInfoError 
(
  struct PWerrentry *p_errentry
)
{
  PWboolean funcval, found;
  int inx;

  if (_stackptr)
  {
    found = FALSE;
    for (inx=FIRST; inx<=_stackptr; inx++)
    {
      if (_p_errstack[inx].stackcode == _ACTIVE &&
          _p_errstack[inx].errentry.type != PWerrentry_null)
      {
        found = TRUE;
        break;
      }
    }

    if (found)
    {
      *p_errentry = _p_errstack[inx].errentry;
      funcval = TRUE;
    }
    else
      funcval = FALSE;
  }
  else
  {
    funcval = FALSE;
  }

  pwInitErrorStack();
  return (funcval);
}


PWboolean pwGetErrorAtInx 
(
  int inx,
  struct PWerrentry *p_errentry
)
{
  PWboolean   funcval;
  if (_stackptr && 
      inx <= _stackptr && 
      _p_errstack[inx].stackcode != _INACTIVE)
  {
    *p_errentry = _p_errstack[inx].errentry;
    funcval = TRUE;
  }
  else
  {
    funcval = FALSE;
  }

  return (funcval);
}


/*
  DESCRIPTION

  This function is called to initialize the stack. It is called whenever
  the user decides to start all over. Should be rarely used. It is typically
  used in conjunction with 'GetErrAtInx', which should be rarely used.
  Most of the time, the other query functions are used, which automatically
  initialize the stack after it has been read
*/

void pwInitErrorStack
(
)
{
  int i;

  if (_p_errstack)
  {
    for (i=0; i<PW_K_MaxErrStackSize; i++)
      _p_errstack[i].stackcode = _INACTIVE;
    _stackptr = FIRST;
  }

  return;
}

/*
 * Helper functions that manipulate the error stack. 
 */

static PWboolean get_error_stack()
{
  if (!_p_errstack)
  {
    _p_errstack = (struct errstackentry *) malloc (PW_K_MaxErrStackSize *
                  sizeof (struct errstackentry));
    if (_p_errstack)
      pwInitErrorStack();
  }
  return (_p_errstack ? TRUE : FALSE); 
}

void update_error_stack()
{
  if (_stackptr < PW_K_MaxErrStackSize-1)
  {
    _p_errstack[_stackptr].stackcode = _ACTIVE;
    _stackptr++;
  }
  else
  {
    if (_p_errstack[_stackptr].stackcode == _ACTIVE)
      _p_errstack[_stackptr].stackcode = _TRUNCATED;
  }
  return;
}

