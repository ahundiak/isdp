#include "machine.h"
/*  Function is simply a wrapper so as to eliminate
    prototype include file dependencies - Glenn Scott 2/26/92  */

long NFMvalidate_user_access
(user_id, command, workflow, project, catalog, item, revision)
  long    user_id;
  char    *command;
  char    *workflow;
  char    *project;
  char    *catalog;
  char    *item;
  char    *revision;
  {
    return (WFvalidate_user_access
        (user_id, command, workflow, project, catalog, item, revision));
  }
