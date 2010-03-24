
#include <stdio.h>
#include "usagetab.h"
#include "ordertab.h"
#include "basictab.h"
#include <string.h>

static void printit (s)
 symbol_ptr s;
 {
  fprintf (stderr, "printit %x : %s\n", s, s->name);
  free (s);
 } /* printit */

void test_usage (tab)
 usagetab_ptr tab;
 {
  int i;

  usagetab_record (tab, 1, 11);

  for (i = 0; i < 10; ++i)
   {
    char symname[60];

    sprintf (symname, "symbol%d of table%d", 5, i);

    lookup_symbol ((symtab_ptr)tab, symname);
   }

  {
   struct table_usage *ut, *u;

   ut = usagetab_usage (tab);

   if (ut)
    {
     u = (struct table_usage *)ut->s.next;
     ut->s.next = 0;
     ut = u;
    }

   for (u = ut; u; u=(struct table_usage *)u->s.next)
    printf (" owner = %s : symbol = %s\n", u->owner, u->s.name);
  }
 } /* test_usage */

static void test1()
 {
  usagetab_ptr tab, t;
  symtab_ptr st;
  int i;

  st = new_basictab (17, stderr);

  for (i = 0; i < 10; ++i)
   {
    char symname[40];
    symbol_ptr p;

    sprintf (symname, "symbol%d", i);

    p = (symbol_ptr) malloc (sizeof (*p) + strlen (symname) + 1);
    p->name = strcpy ((char*)(p+1), symname);
    fprintf (stderr, " calling enter symbol %s\n", p->name);
    enter_symbol (st, p);
   }

  delete_symbol_table (st, printit);

  tab = new_usagetab (17, stderr, "master");

  for (i = 0; i < 10; ++i)
   {
    char tablename[32];
    int j;

    sprintf (tablename, "table%d", i);
    t = new_usagetab (17, stderr,
        strcpy ((char *)malloc(strlen(tablename)+1), tablename));
    for (j = 0; j < 10; ++j)
     {
      char symname[60];
      symbol_ptr p;

      sprintf (symname, "symbol%d of table%d", j, i);

      p = (symbol_ptr) malloc (sizeof (*p) + strlen (symname) + 1);
      p->name = strcpy ((char *)(p+1), symname);
      fprintf (stderr, " calling enter symbol %s\n", p->name);
      enter_symbol ((symtab_ptr)t, p);
     }
    fprintf (stderr, " calling attach %d\n", i);
    hiersymtab_attach ((hiersymtab_ptr)tab, t);
   }

  test_usage (tab);

  test_usage (tab);
 }

static char *Symname[] = {
	"first",
	"second",
	"third",
	"fourth",
	"fifth",
	"sixth",
	"seventh",
	"eighth",
	"ninth",
	"tenth",
	"eleventh",
	0
};

static void test2()
 {
  ordertab_ptr st;
  symbol_ptr p;
  int i;

  st = new_ordertab (17, stderr);

  for (i = 0; Symname[i]; ++i)
   {
    p = (symbol_ptr) malloc (sizeof (*p) + strlen (Symname[i]) + 1);
    p->name = strcpy ((char*)(p+1), Symname[i]);
    fprintf (stderr, " calling enter symbol %s\n", p->name);
    enter_symbol ((symtab_ptr)st, p);
   }

  process_symbol_table((symtab_ptr)st, printit);

  p = lookup_symbol((symtab_ptr)st, Symname[0]);
  if (p)
   remove_symbol((symtab_ptr)st, p);

  process_symbol_table((symtab_ptr)st, printit);

  p = lookup_symbol((symtab_ptr)st, Symname[i-1]);
  if (p)
   remove_symbol((symtab_ptr)st, p);

  process_symbol_table((symtab_ptr)st, printit);
  delete_symbol_table ((symtab_ptr)st, printit);
 }

main (argc, argv)
 int argc;
 char *argv[];
 {
  int i;

  if (argc == 1)
    exit(1);
  
  for (i = 1; i < argc; ++i)
   if ('-' == argv[i][0])
    switch (argv[i][1])
     {
      case '1':	test1(); break;
      case '2': test2(); break;
     }
 } /* main */
