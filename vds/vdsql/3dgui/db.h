/* ----------------------------------------------
 * db routines include file
 */
#ifndef DB_H
#define DB_H

extern sqlite *open_database(char *dbName);
extern sqlite *init_database(char *dbName);

#endif

