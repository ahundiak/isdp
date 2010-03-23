#include <stdio.h>
#include "dload.h"
#include "test.h"

/* globals for test cases to reference */

char   GBLchar        = 'A';
short  GBLshort       = 30000;
int    GBLint         = 100100;
float  GBLfloat       = 2.97;
double GBLdouble      = 3.14159;
int    GBLintarray[5] = { 0, 10, 20, 30, 40 };
char   GBLchararray[] = "This is an array of chars";

/* functions for test cases to reference as required */

int Main_ref1 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  return ans;
}
int Main_ref2 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  return 2*ans;
}
int Main_ref3 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  return 3*ans;
}
int Main_ref4 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  return 4*ans;
}
int Main_ref5 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  return 5*ans;
}

/* functions for test cases to redefine as required */

static char phrase[] = "The answer is";
static char buffer[30];
char *Main_redef1 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  sprintf (buffer, "%s %d", phrase, ans);
  return buffer;
}
char *Main_redef2 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  sprintf (buffer, "%s %d", phrase, ans);
  return buffer;
}
char *Main_redef3 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  sprintf (buffer, "%s %d", phrase, ans);
  return buffer;
}
char *Main_redef4 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  sprintf (buffer, "%s %d", phrase, ans);
  return buffer;
}
char *Main_redef5 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  sprintf (buffer, "%s %d", phrase, ans);
  return buffer;
}
char *Main_redef6 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  sprintf (buffer, "%s %d", phrase, ans);
  return buffer;
}
char *Main_redef7 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  sprintf (buffer, "%s %d", phrase, ans);
  return buffer;
}
char *Main_redef8 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  sprintf (buffer, "%s %d", phrase, ans);
  return buffer;
}
char *Main_redef9 (int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7)
{
  int ans = arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7;
  sprintf (buffer, "%s %d", phrase, ans);
  return buffer;
}


void loadfile ()
{
  char name[256];

  printf ("Enter name of file to load:  ");
  scanf ("%s", name);
  if (dload (name, TEXTREF | DATAREF | TEXTREDEF))
    printf ("File loaded successfully\n");
  else printf ("Error loading file\n");
}

void loadincr ()
{
}

void lookup ()
{
  char  name[256];
  void *addr;

  printf ("Enter name to look up: ");
  scanf ("%s", name);
  if (addr = dload_address_lookup (name))
    printf ("\t0x%.8x\n", addr);
  else printf ("\tname not found\n");
}

void callfunc ()
{
  char  name[256];
  void *func;

  printf ("Enter name of function to call:  ");
  scanf ("%s", name);
  if (!(func = dload_address_lookup (name)))
    printf ("Function not found\n");
  else ((void (*)())func) ();
}

void writeto ()
{
}

void readfrom ()
{
}

void runtests ()
{
  int            testnum = 0;
  char           testfile[256], answer;
  void          *handle;
  struct symdef *testmain, *testtitle;

  while (++testnum) {
    sprintf (testfile, "DLtest_%d." EXT, testnum);
    if (0 != access (testfile, 0))
      break;
    if (!(handle = dload (testfile, TEXTREF | DATAREF | HIDEGLOBAL)))
      break;

    if (   !dload_symbol_lookup (handle, PFX "Title", &testtitle)
        || !dload_symbol_lookup (handle, PFX "main",  &testmain ) ) {
      printf ("Test file / %s / not in correct format!\n", testfile);
      break;
    }

    printf ("\n\n");
    printf ("============================================================\n");
    printf ("\t\t%s\n", (char *)testtitle->value);
    printf ("============================================================\n");

    if (((int (*)())testmain->value) (testnum)) {
      printf ("\n\t\t\tSUCCESS\n");
      printf ("============================================================\n");
    }
    else {
      printf ("\n\07\07\07\t\t\tFAILURE !!\n");
      printf ("============================================================\n");
      printf ("\nExecute remaining tests (y/n)? ");
      fflush (stdin);
      scanf ("%c", &answer);
      if (answer != 'y')
        break;
    }
  }
}


main ()
{
  int what;

  while (1) {
  	
    /* verify redefined functions */

    (void)Main_redef1 (1, 2, 3, 4, 5, 6, 7);
    (void)Main_redef2 (1, 2, 3, 4, 5, 6, 7);
    (void)Main_redef3 (1, 2, 3, 4, 5, 6, 7);
    (void)Main_redef4 (1, 2, 3, 4, 5, 6, 7);
    (void)Main_redef5 (1, 2, 3, 4, 5, 6, 7);
    (void)Main_redef6 (1, 2, 3, 4, 5, 6, 7);
    (void)Main_redef7 (1, 2, 3, 4, 5, 6, 7);
    (void)Main_redef8 (1, 2, 3, 4, 5, 6, 7);
    (void)Main_redef9 (1, 2, 3, 4, 5, 6, 7);

    printf ("\n\n\t\tDYNAMIC LOADER TEST BED\n\n\n");
    printf ("\t0) Exit test driver\n");
    printf ("\t1) Execute regression tests\n");
    printf ("\t2) Run internal dload test routine (NOT AVAILABLE)\n");
    printf ("\t3) Load a single file\n");
    printf ("\t4) Incremental load of files\n");
    printf ("\t5) Look up the address of a variable\n");
    printf ("\t6) Call a function with no arguments\n");
    printf ("\t7) Validate an address (by reading from it)\n");
    printf ("\t8) Validate an address (by writing to it)\n");
    printf ("\n\nEnter number of selection: ");
    what = 999;
    fflush (stdin);
    scanf ("%d", &what);

    switch (what) {
      case  0: exit (0);
      case  1: runtests ();    break;
/*    case  2: dload_debug (); break;   */
      case  3: loadfile ();    break;
      case  4: loadincr ();    break;
      case  5: lookup ();      break;
      case  6: callfunc ();    break;
      case  7: writeto ();     break;
      case  8: readfrom ();    break;
      default: printf ("Invalid option\n"); break;
    }
  }
}
