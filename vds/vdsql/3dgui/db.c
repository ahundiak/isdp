/* ----------------------------------------------
 * Low level database routines
 */
#include "stdlib.h"
#include "sqlite.h"
#include "db.h"

sqlite *init_database(char *dbName)
{
  int     retFlag = 0;
  int     sts;

  sqlite *db     = NULL;
  char   *errmsg = NULL;

  char    sql[999];
  char    buf[512];

  /* Clear any previous */
  sprintf(buf,"/bin/test -f %s.dbl && /bin/rm %s.dbl",dbName,dbName);
  system (buf);

  /* Open */
  sprintf(buf,"%s.dbl",dbName);
  db = sqlite_open(buf, 0, &errmsg);
  if (db == NULL)
  {
    printf("*** Problem opening %s.dbl database, %s\n",dbName,errmsg);
    free(errmsg);
    goto wrapup;
  }

wrapup:

  return db;
}

sqlite *open_database(char *dbName)
{
  sqlite *db     = NULL;
  char   *errmsg = NULL;
  char    buf[512];

  /* Open */
  sprintf(buf,"%s.dbl",dbName);
  db = sqlite_open(buf, 0, &errmsg);
  if (db == NULL)
  {
    printf("*** Problem opening %s.dbl database, %s\n",dbName,errmsg);
    free(errmsg);
    goto wrapup;
  }

wrapup:
  return db;
}

