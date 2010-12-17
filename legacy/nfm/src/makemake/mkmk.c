#include "machine.h"
#include <stdio.h>
#include "lib.h"
#include <string.h>

extern int atomic_line_position;

#define debug 1

struct dtree_node
 {
  char *fname;
  struct dtree_node *next,*dep;
 };


struct dtree_node *libdir=0;   /* Added to support  OBJEXT and LIBDIR. */ 
struct dtree_node *objext=0;   /* M. S. Sai Prasad. 14 Dec 93.         */

struct dtree_node *srcfiles=0;
struct dtree_node *depfiles=0;
struct dtree_node *incfiles=0;
struct dtree_node *archive=0;
struct dtree_node *library=0;
struct dtree_node *cc=0;
struct dtree_node *riscc=0;
struct dtree_node *opt=0;
struct dtree_node *mode=0;
struct dtree_node *osflag=0;
struct dtree_node *risflag=0;
struct dtree_node *miscflag=0;
long combine_flag = 0;
long xwin_flag = 0;

struct dtree_node *new_dtree_node (a)
char *a;
 {
  struct dtree_node *c;

  c = (struct dtree_node *)malloc (sizeof (struct dtree_node));
  c->fname = strdup(a);
  c->next = 0;
  c->dep = 0;
  return (c);
 }


struct dtree_node *find_name (p,f)
struct dtree_node *p;
char *f;
 {
  while (p)
   {
    if (!strcmp(f,p->fname)) return (p);
    p = p->next;
   }
  return (0);
 }

extern char *dot_o();

add_dep_list (dd,d)
struct dtree_node **dd;
struct dtree_node *d;
 {
  struct dtree_node *p;

  while (d)
   {
    if (!find_name(*dd,d->fname))
     {
      if (find_name(srcfiles,d->fname))
       {
        p = new_dtree_node (d->fname);
        p->next = *dd;
        *dd = p;
        p = find_name (srcfiles,d->fname);
        if (p) add_dep_list (dd,p->dep);
       }
      else
       {
        p = new_dtree_node (d->fname);
        p->next = *dd;
        *dd = p;
        p = find_name (depfiles,d->fname);
        if (p) add_dep_list (dd,p->dep);
       }
     }
    d = d->next;
   }
 }


struct dtree_node *extract_deps (d)
struct dtree_node *d;
 {
  struct dtree_node *deps;

  deps = 0;
  add_dep_list (&deps,d);
  return (deps);
 }


char doto_arr[100];
char *dot_o (f)
char *f;
 {
  int i;

  strcpy (doto_arr,f);
  i = strlen(doto_arr);
  while ((doto_arr[i] != '.')&&(i)) i--;
  doto_arr[i+1] = '$';
  doto_arr[i+2] = '(';
  doto_arr[i+3] = 'O';
  doto_arr[i+4] = 'B';
  doto_arr[i+5] = 'J';
  doto_arr[i+6] = 'E';
  doto_arr[i+7] = 'X';
  doto_arr[i+8] = 'T';
  doto_arr[i+9] = ')';
  doto_arr[i+10] = '\000';
  return (doto_arr);
 }

write_outfile ()
  {
  struct dtree_node *p;
  struct dtree_node *d;
  struct dtree_node *dp;
  unsigned int cur_length;
  char *fname_temp;

  fprintf (stdout,".SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9\n");

/* Print C compilet */
  if (cc)
      fprintf (stdout,"CC=%s\n", cc->fname);
  else
#if defined OS_SCO_UNIX || defined OS_HPUX || defined OS_INTELSOL 
      fprintf (stdout,"CC=cc\n");
#else
      fprintf (stdout,"CC=acc\n");
#endif

/* print RIS compiler */
/* Added option to print RIS compiler  - Jujare, 27 Oct 95 */  
  if (riscc)
      fprintf (stdout,"RISCC=%s\n", riscc->fname);
  else
#if defined OS_SCO_UNIX || defined OS_HPUX
    fprintf (stdout,"RISCC=/usr/ip32/ris/risdp/bin/riscpp\n"); 
#elif defined OS_CLIX
    fprintf (stdout,"RISCC=/usr/ip32/ris/rispcuc/bin/riscpp\n"); 
#elif defined OS_INTELSOL
    fprintf (stdout,"RISCC=/opt/ingr/ris/risdp/bin/riscpp\n"); 
#else
    fprintf (stdout,"RISCC=/usr/ip32/ris/rispcuc/bin/riscpp\n"); 
#endif


/* if OPT is not defined, use "" */
/* Changed to print the OPT option - Jujare 29, Dec 95 */ 
    if (opt)
        fprintf (stdout,"OPT=%s\n", opt->fname);
    else
#ifdef OS_CLIX
    fprintf (stdout,"OPT=-O3\n");
#else
        fprintf (stdout,"OPT=\n");
#endif

/* default to the "" CPU definition */
#ifdef OS_CLIX
  fprintf (stdout,"CPUFLAG=-D__cpu_c100__\n");
#else
  fprintf (stdout,"CPUFLAG=\n");
#endif

/* flag for building the combined client/server */
  if (combine_flag)
      fprintf (stdout,"COMBINE_FLAG=-DCOMBINED_MAKE\n");

/* flag for building X window clients */
  if (xwin_flag)
      fprintf (stdout,"XWINDOWS_FLAG=-DXWINDOWS\n");

/* Pick OBJEXT from .m file or set OBJEXT depending on the platform. */
  if (objext)
      fprintf(stdout, "OBJEXT=%s\n", objext->fname);
  else
  {
#ifdef OS_SCO_UNIX
      fprintf (stdout,"OBJEXT=5\n");
#elif  defined OS_SUNOS
      fprintf (stdout,"OBJEXT=6\n");
#elif  defined OS_SOLARIS && !defined(OS_INTELSOL)
      fprintf (stdout,"OBJEXT=7\n");
#elif defined OS_HPUX
      fprintf (stdout,"OBJEXT=8\n");
#elif defined OS_INTELSOL
      fprintf (stdout,"OBJEXT=9\n");
#elif defined OS_CLIX
      fprintf (stdout,"OBJEXT=1\n");
#else
      /* default to the ".o" extension */
      fprintf (stdout,"OBJEXT=o\n");
#endif
  }

  /* Pick LIBDIR from .m file or set LIBDIR depending on the platform. */
  if (libdir)
      fprintf(stdout, "LIBDIR=%s\n", libdir->fname);
  else
  {
#ifdef OS_SCO_UNIX
     fprintf (stdout,"LIBDIR=../scolib\n");
#elif defined OS_SUNOS
     fprintf (stdout,"LIBDIR=../sunlib\n");
#elif defined OS_SOLARIS && !defined OS_INTELSOL  
     fprintf (stdout,"LIBDIR=../sollib\n");
#elif defined OS_CLIX
     fprintf (stdout,"LIBDIR=../libc100\n");
#elif defined OS_INTELSOL
     fprintf (stdout,"LIBDIR=../tdlib\n");
#elif defined OS_HPUX
     fprintf (stdout,"LIBDIR=../hplib\n");
#else
     /* default to the "../lib" archive library directory */
     fprintf (stdout,"LIBDIR=../lib\n");
#endif
  }

/* default ARCHNAME to what is in the .m file */
  if (archive)
      fprintf (stdout,"ARCHNAME=%s\n", archive->fname);

/* Pick OSFLAG from the .m file or default depending on the platform */
  if (osflag)
      fprintf (stdout,"OSFLAG=-D%s\n", osflag->fname);
  else
  {
#if defined OS_SOLARIS || defined OS_INTELSOL  
      fprintf (stdout,"OSFLAG=-Dsolaris\n");
#else
      fprintf (stdout,"OSFLAG=\n");
#endif
  }

#ifdef OS_SCO_UNIX
      fprintf(stdout, "RISFLAGS=-Dsco\n");
#elif defined(OS_HPUX)
      fprintf(stdout, "RISFLAGS=-D__hpux__\n");
#endif

  if (miscflag)
  {
      fprintf (stdout,"MISCFLAG=-D%s", miscflag->fname);
      p = miscflag;
      p = p->next;
      while(p)
      {
          fprintf(stdout, "\t-D%s", p->fname);
          p = p->next;
      }
      fprintf(stdout, "\n");
  }
  else
      fprintf (stdout,"MISCFLAG=\n");


/* default to the "" target processor */
#ifdef OS_CLIX
  fprintf (stdout,"TARGSTR=-Atarg=c100\n");
#else
  fprintf (stdout,"TARGSTR=\n");
#endif

/* Set C compiler specific flags */
#ifdef OS_CLIX
  fprintf( stdout, "CFLAGS=-ansi");
#elif defined OS_HPUX
  fprintf( stdout, "CFLAGS=-Aa -D_HPUX_SOURCE +DA1.0");
#elif defined OS_SOLARIS 
  fprintf (stdout,"CFLAGS=-Xa ");
#elif defined OS_SUNOS || defined OS_SCO_UNIX
  fprintf (stdout,"CFLAGS=-Xa -PIC");
#endif

/* KT - add INCLUDE files */
  p = incfiles;
  p = p->next;    /* skip "/usr/include" */
  while (p)
      {
      if ((strcmp(p->fname,"/usr/include"))&&
          (strcmp(p->fname,"/usr/include/CC" )))
      { 
      fprintf (stdout,"\t-I%s",p->fname);
      }
      p = p->next;
      }

  fprintf (stdout,"\n");

  fprintf (stdout,"OBJECTS=");
  p = srcfiles;
  cur_length = 0;
  while (p)
      {
        fname_temp = dot_o(p->fname);
        cur_length+=strlen(fname_temp);
        if (cur_length > 74)
          {
             cur_length=strlen(fname_temp);
             fprintf (stdout," \\\n");
          }
      fprintf (stdout," %s",dot_o(p->fname));
      p = p->next;
      }
  fprintf (stdout,"\n\n");

/* KT - write compile definition */

  fprintf (stdout, "#====================================================\n");
  fprintf (stdout, ".c.$(OBJEXT):\n");
  fprintf (stdout, "\t@echo \" $*.c -> $*.$(OBJEXT)\"\n");
  fprintf (stdout, "\t@echo \"\\n remaking $*.$(OBJEXT) because of : $? \\n\"\n");

  fprintf (stdout, "\t$(CC) -c $(CFLAGS) $(CPUFLAG) ");

  if (combine_flag)
      fprintf (stdout, "$(COMBINE_FLAG) ");
  if (xwin_flag)
      fprintf (stdout, "$(XWINDOWS_FLAG) ");

  fprintf(stdout, "$(OSFLAG) ");
  fprintf(stdout, "$(MISCFLAG) ");
  fprintf(stdout, "$(RISFLAGS) ");

  fprintf (stdout, "$(OPT) $(TARGSTR) $*.c\n");
  fprintf (stdout, "\t@echo\n");

  fprintf (stdout, "\t@mv $*.o $*.$(OBJEXT)\n");

  fprintf (stdout, "#====================================================\n");
  fprintf (stdout, ".rc.$(OBJEXT):\n");
  fprintf (stdout, "\t@echo \" $*.rc -> $*.$(OBJEXT)\"\n");
  fprintf (stdout, "\t@echo \"\\n remaking $*.$(OBJEXT) because of : $? \\n\"\n");
  fprintf (stdout, "\t$(RISCC) -r $(CFLAGS) $(CPUFLAG) ");
  fprintf (stdout, "$(OSFLAG) ");
  fprintf(stdout, "$(MISCFLAG) ");
  fprintf (stdout, "$(RISFLAGS) ");
  fprintf (stdout, "$(OPT) $(TARGSTR) $*.rc\n");

  fprintf (stdout, "\t@echo\n");
  fprintf (stdout, "\t$(CC) -c $(CFLAGS) $(CPUFLAG) ");
  fprintf(stdout, "$(OSFLAG) ");
  fprintf(stdout, "$(MISCFLAG) ");
  fprintf (stdout, "$(RISFLAGS) ");
  fprintf (stdout, "$(OPT) $(TARGSTR) $*.c\n");
  fprintf (stdout, "\t@echo\n");
  fprintf (stdout, "\t@mv $*.o $*.$(OBJEXT)\n");

  fprintf (stdout, "#====================================================\n");

  if (archive)
      {
      fprintf (stdout, "$(LIBDIR)/$(ARCHNAME) : $(OBJECTS)\n");
      fprintf (stdout, "\t@echo\n");
      fprintf (stdout, "\tar ruv $(LIBDIR)/$(ARCHNAME) $(OBJECTS)\n");

/* ranlib is required for SUN only - IGI 23 Feb 94 */
#ifdef OS_SUNOS
      fprintf (stdout, "\t@echo\n");
      fprintf (stdout, "\tranlib $(LIBDIR)\/$(ARCHNAME)\n");
#endif

      fprintf (stdout, "\t@echo\n");
      fprintf (stdout, "\t@ls -l $(LIBDIR)/$(ARCHNAME)\n");
      fprintf (stdout, "\t@echo\n");
      fprintf (stdout, "#====================================================\n");
      }
  else
      {
      fprintf (stdout, "$(LIBDIR)/%s : $(OBJECTS)\n", library->fname);
      fprintf (stdout, "\t@echo\n");
      fprintf (stdout, "\tld -r -o $(LIBDIR)/%s $(OBJECTS)\n", library->fname);
      fprintf (stdout, "\t@echo\n");
      fprintf (stdout, "\t@ls -l $(LIBDIR)/%s\n", library->fname);
      fprintf (stdout, "\t@echo\n");
      fprintf (stdout, "#====================================================\n");
      }

  fprintf (stdout,"\n\n");

  p = srcfiles;
  
  cur_length = 0;
  while (p)
      {
      fname_temp = dot_o(p->fname);
      fprintf (stdout, "%s : ",fname_temp);
      cur_length+=strlen(fname_temp); 
       
      d = extract_deps (p->dep);
      while (d)
          {
          cur_length+=strlen(d->fname);
          if (cur_length > 75)
          {
             cur_length=strlen(d->fname);
             fprintf (stdout," \\\n");
          }
          fprintf (stdout,"  %s",d->fname);
          cur_length+=2;
          free (d->fname);
          dp = d;
          d = d->next;
          free (dp);
          }
      fprintf (stdout,"\n\n");
      p = p->next;
      }

  fprintf (stdout,"\n\n");
  }

extern struct dtree_node *scan_file();

add_to_dep_list (f)
char *f;
 {
  struct dtree_node *p;
  struct dtree_node *d;

  p = srcfiles;
  while (p)
      {
      if (!strcmp(f,p->fname)) return;
      p = p->next;
      }
  p = depfiles;
  while (p)
      {
      if (!strcmp(f,p->fname)) return;
      p = p->next;
      }
  p = new_dtree_node (f);
  p->next = depfiles;
  depfiles = p;
  p->dep = scan_file (f);
  d = p->dep;
  while (d)
      {
      add_to_dep_list (d->fname);
      d = d->next;
      }
 }


gobble_filename (a)
char *a;
 {
  int i;

  i = strlen (a);
  while (i--)
   {
    if (a[i] == '/') return;
    a[i] = 0;
   }
 }


static char file_name[300];

char *find_file (mode,fn,cf)
int mode;
char *fn;
char *cf;
 {
  struct dtree_node *p;

  if (fn[0] == '/')
   {
    strcpy (file_name,fn);
    reduce_pth (file_name);
    if (is_file(file_name))
     return (file_name);
    else
     {
      fprintf (stderr,"cannot find file <%s>\n",fn);
      return (0);
     }
   }
  else
   {
    if (mode == '\"')
     {
      strcpy (file_name,cf);
      gobble_filename (file_name);
      strcat (file_name,fn);
      reduce_pth (file_name);
      if (is_file(file_name))
       return (file_name);
     }
    p = incfiles;
    while (p)
     {
      strcpy (file_name,p->fname);
      strcat (file_name,"/");
      strcat (file_name,fn);
      reduce_pth (file_name);
      if (is_file(file_name))
       return (file_name);
      p = p->next;
     }
    fprintf (stderr,"cannot find file <%s>\n",fn);
    return (0);
   }
 }


struct dtree_node *scan_file(f)
char *f;
 {
  struct dtree_node *deps;
  struct dtree_node *p;
  FILE *infile;
  char atom[100];
  char depfile[100];
  char *rdp;
  int stat;
  int ran_get=0;

  deps = 0;
/*  fprintf (stderr,"scanning file <%s>\n",f); */
  infile = fopen (f,"r");
  if (!(infile))
   {
     perror(f); return (0);
   }

  stat = fget_atom(atom,infile);
  while (stat)
   {
    if ((!strcmp(atom,"#include")) && (atomic_line_position == 0))
     {
      stat = fget_str (depfile,infile);
      rdp = find_file (stat,depfile,f);
      if (rdp)
       {
        p = new_dtree_node (rdp);
        p->next = deps;
        deps = p;
       }
      stat = fget_atom (atom,infile);
     }
    else if ((!strcmp(atom,"#")) && (atomic_line_position == 0))
     {
      stat = fget_atom (atom,infile);
      if (!stat) break;
      if (!strcmp(atom,"include"))
       {
        stat = fget_str (depfile,infile);
        rdp = find_file (stat,depfile,f);
        if (rdp)
         {
          p = new_dtree_node (rdp);
          p->next = deps;
          deps = p;
         }
       }
      stat = fget_atom (atom,infile);
     }
    else
     {
      stat = fget_atom (atom,infile);
     }
   }
  fclose (infile);
  if (ran_get)
    {
      int s;
      char msg[256];
      sprintf (msg,"rm -f %s > /dev/null 2>&1",f);
      fprintf (stderr,"%s\n",msg);
      s = system (msg);
      if (s) { perror (msg); }
    }
  return (deps);
 }


generate_dep ()
 {
  struct dtree_node *p;
  struct dtree_node *d;

  p = srcfiles;
  while (p)
   {
    p->dep = scan_file (p->fname);
    d = p->dep;
    while (d)
     {
      add_to_dep_list (d->fname);
      d = d->next;
     }
    p = p->next;
   }
 }

read_infile ()
 {
  char inline[100];
  struct dtree_node **ci;
  int i;
  struct dtree_node *p;

/* PS */
  char tmpinline[100];
  char cmd[256] ;
  FILE *ptr;

  objext = 0;  /* M. S. Sai Prasad.  14 Dec 93 */
  libdir = 0;

  srcfiles = 0;
  depfiles = 0;
  incfiles = 0;
  archive = 0;
  library = 0;
  cc = 0;
/* Added option to print RIS compiler  - Jujare, 27 Oct 95 */  
  riscc = 0;
  opt = 0;
  mode = 0;
  combine_flag = 0;
  xwin_flag = 0;
  osflag = 0;
  risflag = 0;
  miscflag = 0;


  incfiles = new_dtree_node ("/usr/include");
  ci = 0;
  while (!feof(stdin))
   {
    i = scanf("%s",tmpinline);
    if (i==EOF) break;

    sprintf(cmd, "echo %s", tmpinline);
 
    if ((ptr = popen(cmd, "r")) != NULL)
     {
       if (fscanf(ptr, "%s", inline) == NULL)
	  printf("fgets failed\n");

	pclose(ptr);
/*
	fprintf(stderr, "MKMK tmpinlinle=%s\tinline=%s\n", tmpinline, inline);
*/
     }

    /* LIBDIR can be specified by user.  M. S. Sai Prasad 14 Dec 93 */
    /* Note :- The strcmp() for "LIBDIR" should precede that of     */
    /*         LIB for proper working.                              */

    if (!strcmp("LIBDIR",inline))  
     {
      ci = &libdir;
      if (*ci) while ((*ci)->next) ci = &((*ci)->next);
     }
    else if (!strcmp("OBJEXT",inline)) /* OBJEXT can be user specified */
     {                                 /* M. S. Sai Prasad. 14 Dec 93  */
      ci = &objext;
      if (*ci) while ((*ci)->next) ci = &((*ci)->next);
     }
    else if (!strcmp("INCLUDE",inline))
     {
      ci = &incfiles;
      if (*ci) while ((*ci)->next) ci = &((*ci)->next);
     }
    else if (!strcmp("SOURCE",inline))
     {
      ci = &srcfiles;
      if (*ci) while ((*ci)->next) ci = &((*ci)->next);
     }
    else if (!strcmp("ARCHIVE",inline))
     {
      ci = &archive;
      if (*ci) while ((*ci)->next) ci = &((*ci)->next);
     }
    else if (!strcmp("LIB",inline))
     {
      ci = &library;
      if (*ci) while ((*ci)->next) ci = &((*ci)->next);
     }
    else if (!strcmp("CC",inline))
     {
      ci = &cc;
      if (*ci) while ((*ci)->next) ci = &((*ci)->next);
     }
/* Added option to print RIS compiler  - Jujare, 27 Oct 95 */  
    else if (!strcmp("RISCC",inline))
     {
      ci = &riscc;
      if (*ci) while ((*ci)->next) ci = &((*ci)->next);
     }
    else if (!strcmp("OPT",inline))
     {
      ci = &opt;
      if (*ci) while ((*ci)->next) ci = &((*ci)->next);
     }
    else if (!strcmp("MODE",inline))
     {
      ci = &mode;
      if (*ci) while ((*ci)->next) ci = &((*ci)->next);
     }
    else if (!strcmp("OSFLAG",inline))
     {
      ci = &osflag;
      if (*ci) while ((*ci)->next) ci = &((*ci)->next);
     }
    else if (!strcmp("RISFLAGS",inline))
     {
      ci = &risflag;
      if (*ci) while ((*ci)->next) ci = &((*ci)->next);
     }
    else if (!strcmp("MISCFLAG",inline))
     {
      ci = &miscflag;
      if (*ci) while ((*ci)->next) ci = &((*ci)->next);
     }
    else if (!strcmp("COMBINE_FLAG",inline))
     {
      combine_flag = 1;
     }
    else if (!strcmp("XWINDOWS_FLAG",inline))
     {
      xwin_flag = 1;
     }
    else if (ci)
     {
      p = new_dtree_node (inline);
      if (*ci)
       (*ci)->next = p;
      else
       *ci = p;
      ci = &((*ci)->next);
     }
    else
     {
/*
      fprintf (stderr,"premature atom <%s>\n",inline);
      fprintf (stderr,"have not found INCLUDE, SOURCE, ... atom yet\n");
*/
     }
   }
 }


main (argc,argv,envr)
int argc;
char **argv,**envr;
 {

  read_infile ();
  if (!(srcfiles) && (!(archive) && !(library)))
      {
      fprintf (stderr, "Need SOURCE and ARCHIVE/LIB sections!\n");
      exit (0);
      }
  generate_dep ();
  write_outfile ();
 }
