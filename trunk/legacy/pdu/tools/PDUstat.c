/*
 * Author: Raja Sekhar Pathivada
 * Date:   02-Mar-95
 */

/*
 * Function PDUstat():
 *   Calls stat() with arguments passed to it and returns the value
 *    returned by it.
 *   Used by PPL programmes on Solaris Intel since sys/stat.h
 *   file defines stat() as a static function and PPL does not
 *   support it.
 */

#include "stdio.h"
#include "sys/types.h"
#include "sys/stat.h"

int PDUstat(char *filename, struct stat *file_status)
{
/*
 * Use local var. when file_status arg. == NULL. TR139526046. 26/may/95 - raj.
 */
  struct stat fsts;

  if (file_status != NULL)
    return stat(filename, file_status);
  else
    return stat(filename, &fsts);
}
