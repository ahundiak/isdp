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

/* -------------------------------------------------------------
 * dload stubbs
 */
struct symdef {
   char *name;      /* the name of the symbol            */
   void *value;     /* the value (address) of the symbol */
   int   flags;     /* flags (see below)                 */
};
#if 0
void *dload (char *path, int options)
{
  printf("XC dload %s %d\n",path,options);
  return 0;
}
#endif
#if 0
void *dload_ctrl (int cmd, ...)
{
  printf("XC dload_ctrl\n");
  return NULL;
}
#endif
#if 0
void *dload_address_lookup (char *name)
{
  printf("XC dload_address_lookup %s\n",name);
  return NULL;
}
#endif
int dload_symbol_lookup(void *handle, char *name, struct symdef **buf)
{
  printf("XC dload_symbol_lookup %s\n",name);
  return 0;
}
/* ============================================================
 * Called in IGEstartup after checking get args for
 * OMipcl
 * Need to find out more about what ipcl (inter process communication?
 * Maybe the stop sign functionality?
 */
int	IPCL_init( int qid, key_t key, int protection, int flags )
{
  // printf("XC IPCL_init\n");
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
#if 0
// EX_read_product_data
char *stralloc(char *str)
{
  printf("XC stralloc\n");
  return NULL;
}
#endif
/* ============================================================
 * Called in IGEstartup after checking get args for IPCL_init
 * Why it can't use the passed arguments remains a mystery for now
 */
void getargs (int *argc_p, char ***argv_p, char ***envp_p)
{
  // printf("XC getargs\n");
}
/* =====================================
 * Gets called by OM init
 */
#if 0
int exitadd (int (*function) ())
{
  printf("XC exitadd\n");
  return -1;
}
#endif