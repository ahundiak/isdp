/* ===============================================
 * Just for kicks, find out what is actully being used
 * in this library
 */
#include <stdio.h>
#include <stdlib.h>

#include <assert.h>
#include <unistd.h>
#include <sys/ipc.h>

#ifndef NULL
#define NULL 0
#endif

/* ============================================================
 * Called in IGEstartup after checking get args for
 * OMipcl
 * Need to find out more about what ipcl (inter process communication?
 * Maybe the stop sign functionality?
 */
int	IPCL_init( int qid, key_t key, int protection, int flags )
{
  printf("XC IPCL_init\n");
  return 0;
}
int IPCL_get( int type, key_t key, int misc, int flags )
{
  printf("XC IPCL_get\n");
  return 0;
}
int IPCL_ctl( int type, int id, int semnum, int cmd, int misc )
{
  printf("XC IPCL_ctl\n");
  return 0;
}