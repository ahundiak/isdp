#include <stdio.h>
#include <stdlib.h>
#include <sys/varargs.h>
#include <dlfcn.h>
#include <link.h>

#define DLOAD_TRACE 0

#define  INITIAL    0	/* initialize without loading any files       */
#define  LOADCMPL   1	/* make incrementally loaded files executable */
#define  UNLOAD     2	/* unload the given file(s)                   */
#define  GETHANDLE  3	/* get the handle associated with a file      */
#define  GETSTATUS  4	/* get status information about a file        */
#define  SETOPTION  5	/* set global options                         */
#define  CLROPTION  6	/* clear global options                       */
#define  ENTERTAG   7	/* enter a reactive load tag                  */

#define  Malloc malloc

typedef struct tagdef RLTAG;
struct tagdef {
   char  *tagname;
   char  *dirname;
   void (*recover)();
};
#define  ADDR            unsigned int

static initialized = 0;
static dload_startup()
{
  initialized = 1;
}

void *dload_ctrl (int cmd, ...)
{
  va_list args;

  // if (setjmp (errorloc)) return 0;

  va_start (args, cmd);
  switch (cmd) {

    case INITIAL:
      if (!initialized) dload_startup();
      break;

    case SETOPTION: {
      int options = va_arg (args, int);
      // G_options |= options;
      return (void *)1;
    }
    case GETHANDLE:
    {
      /* This is called by som_dload_class
       * Handle is not actually saved anywhere
       * A non-zero return kicks off an actual load of the file
       * /opt/ingr/bspmath/config/dload/init/BSPMATHver.so
       */
      char *path = va_arg (args, char *);

      if (!initialized || !path) return 0;
      
      if (DLOAD_TRACE) printf("XC dload_ctrl GETHANDLE %s\n",path);
      
      return 0;
      // return hashlookup (filehash, path);
    }

    case ENTERTAG: 
    {
      /* EX_init_dload
       * The functions all point to the same error handler
       * /opt/ingr/bspmath/config/dload/prod Bspmath
       */
      char  *tag    = va_arg (args, char *);
      char  *dir    = va_arg (args, char *);
      void (*fcn)() = (void (*)())va_arg (args, ADDR);
      int    len    = strlen (tag) + 1;
      RLTAG *newtag = Malloc (sizeof (RLTAG) + len + strlen (dir) + 1);

      if (!initialized) dload_startup ();
      
      newtag->recover = fcn;
      strcpy (newtag->tagname = (char *)&newtag[1], tag);
      strcpy (newtag->dirname = newtag->tagname + len, dir);

      if (DLOAD_TRACE) printf("XC dload_ctrl ENTERTAG %s %s\n",dir,tag);
      
      // if (!hashadd (taghash, newtag, 0)) report_error (DL_E_TAGEXIST, tag);

      return (void *)1;
    }
    case LOADCMPL:
    {
      /* EX_init_dload
       * Just checks for non-zero return
       * Something to do with delayed loading?
       */
      if (DLOAD_TRACE) printf("XC dload_ctrl LOADCMPL\n");
      return (void *)1;
    }
    default:
      printf("XC dload_ctrl %d\n",cmd);
  }
  return 0;
}
void *dload (char *path, int options)
{
  if (DLOAD_TRACE) printf("XC dload %s %d\n",path,options);
  return dlopen(path,RTLD_NOW | RTLD_GLOBAL);
  // printf("XC dload %s %d\n",path,options);
  // return 0;
}
void *dload_address_lookup (char *name)
{
  void *address;

  address = dlsym(RTLD_DEFAULT,name);
  if (!address) 
  {
    if (DLOAD_TRACE) printf("dload_adderss_lookup - Not found - %s\n",name);
    return 0;
  }
  if (DLOAD_TRACE) printf("XC dload_address_lookup %s\n",name);
  return address;
  
  // printf("XC dload_address_lookup %s\n",name);
  // return NULL;
}
