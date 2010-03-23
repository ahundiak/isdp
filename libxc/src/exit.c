#define  MAXHAND  25

extern void  _exit    ();
extern int   _cleanup ();
static int (*handlers[MAXHAND + 1])() = {_cleanup};
static int   next = 1;


/*****************************************************************************/
/*									     */
/*  exitadd  --  Define an exit handler.  Up to 25 user defined exit	     */
/*		 handlers may exist at any one time.  Upon a normal program  */
/*		 termination, each exit handler is called in the reverse     */
/*		 order of their definition.  If adding this exit handler     */
/*		 would exceed the maximum allowed or the given function has  */
/*		 already been added, -1 is returned and the handler is not   */
/*		 added; otherwise, 0 is returned.			     */
/*									     */
/*****************************************************************************/

int exitadd (function)

int (*function) ();
{
  int index;

  /* check for too many exit handlers */

  if (next > MAXHAND)
    return -1;

  /* see if the given handler already exists */

  for (index = 0; index < next; index++)
    if (handlers[index] == function)
      return -1;

  /* add the function to our table of exit handlers and return success */

  handlers[next++] = function;
  return 0;
}


/*****************************************************************************/
/*									     */
/*  exitdel  --  Remove a previously defined exit handler.  A pointer to the */
/*		 handler to be removed is supplied by the caller.  Zero is   */
/*		 returned upon success; -1 is returned if the specified      */
/*		 handler does not exist.				     */
/*									     */
/*****************************************************************************/

int exitdel (function)

int (*function) ();
{
  int index;

  /* run through the table of handlers looking for the one to remove.  if it
     is found, compress the table and decrement "next" */

  for (index = 0; index < next; index++)
    if (handlers[index] == function) {
      next--;
      for (; index < next; index++)
        handlers[index] = handlers[index + 1];
      return 0;
    }

  /* if we got to here, the specified function was not found */

  return -1;
}


/*****************************************************************************/
/*									     */
/*  exit  --  Normal program termination.  All defined exit handlers are     */
/*	      called in reverse order of their definition.  Each handler is  */
/*	      passed the exit status as a parameter.  The pre-defined        */
/*	      handler _cleanup (close all open streams) occupies slot zero   */
/*	      of the handler table.					     */
/*									     */
/*****************************************************************************/

void exit (status)

int status;
{

  for (next--; next >= 0; next--)
    handlers[next] (status); 

  _exit (status);
}
