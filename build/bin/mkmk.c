/*=============================================================

   mkmk.c

   This file contains the main routines used by the makemake
   utility.  makemake generates as output a makefile readable
   by the Unix make utility.  The input is a xxx.m file that
   contains directives for building the makefile.  See the
   documentation for keywords recognizable by makemake.

   Revision history:

   Oct. 1988   New features added to support changes in OM 1.2
               (or 4.5 to om-folks).

   BUGs are marked with a BUG !!! comment
  =============================================================*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <memory.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "toolshash.h"
#include "lib.h"
#include "env.h"

#define KEYWORDSIZE 	sizeof(struct keyword_node)
#define MAXLINESIZE	133
#define MAXMACROSIZE	80

char	whyFlag;

void	write_outfile();

#ifdef NT
#include <stdlib.h>
extern int	getopt();
#define SEPARATOR_S	"\\"
#define SEPARATOR_C	'\\'

#define OPP	"$(EXTARG)\\bin\\opp"
#define OMCPP	"$(EXTARG)\\bin\\omcpp"
#define CC	"cl"
#define OCFILES	"$(EXTARG)\\bin\\ocfiles"

static char	*Path_to_mkmk = 0;	/* If mkmk was specified with a path */

#else
#define SEPARATOR_S	"/"
#define SEPARATOR_C	'/'

#define OPP	"$(EXTARG)/bin/opp"
#define OMCPP	"$(EXTARG)/bin/omcpp"
#define CC	"cc"
#define OCFILES	"$(EXTARG)/bin/ocfiles"

extern char *strdup();

#endif

extern int   fga_line_pos;
extern char *getenv();
extern int   optind;
extern char *optarg;

extern char *ccdef;
extern char *omcppdef;
extern char *oppdef;

int   verbose = 0;
int   has_archive = 0;
int   Errors = 0;
int   src_specified = 0;
int   norules = 0;
int   nosuffixes = 0;
int   verbose_rules = 0;

FILE  *outfp = 0;
#ifdef NT
char  obj_file[512];
#endif
char  new_keyword = 1;

static char file_name[512];

/*================================================*/
/* Structures used to build keyword linked lists. */
/*================================================*/
struct keyword_node
{
   int                        keycode;
   struct dtree_node          *linked_list;
   struct keyword_node        *next;
};

struct keyword_node        *makelist = 0;
struct source_group_node   *srcfiles = 0;

struct dtree_node	   *get_ignore_list();

struct dtree_node *depfiles    = 0;  struct dtree_node *postpath    = 0;
struct dtree_node *incfiles    = 0;  struct dtree_node *spcfiles    = 0;
struct dtree_node *oppath      = 0;  struct dtree_node *homepath    = 0;
struct dtree_node *omcppath    = 0;  struct dtree_node *ccpath      = 0;
struct dtree_node *cflags      = 0;  struct dtree_node *oppflags    = 0;
struct dtree_node *version     = 0;  struct dtree_node *depsversion = 0;
struct dtree_node *sufixpath   = 0;  struct dtree_node *rulespath   = 0;
struct dtree_node *srcpath     = 0;  struct dtree_node *doptpath    = 0;
struct dtree_node *target      = 0;  struct dtree_node *ccfilter    = 0;
struct dtree_node *define      = 0;  struct dtree_node *ignore      = 0;
struct dtree_node *asflags     = 0;  struct dtree_node *execflags   = 0;
struct dtree_node *echopath    = 0;  struct dtree_node *linkflags   = 0;

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

struct dtree_node *new_dtree_node __((char *a));
int read_special __((struct dtree_node **pnode, FILE *infile, char *endstring));
int read_line __((struct dtree_node **pnode, FILE *infile));
struct dtree_node *find_name __((struct dtree_node *p, char *f));
struct source_group_node *new_src_group __((char *name));
int in_any_src_group __((char *f));
int in_src_group __((struct source_group_node *sg, char *f));
struct source_group_node *find_src_group __((char *name));
struct source_group_node *get_src_group __((char *buf, char *keyword));
void add_dep_list __((struct dtree_node **dd, struct dtree_node *d));
void gobble_filename __((char *a));
int generate_filename __((char *path, char *base));
char *find_file __((int mode, char *fn, char *cf));
struct dtree_node *scan_om_file __((char *f));
struct dtree_node *scan_c_file __((char *f));
int find_include_file __((char *line, struct dtree_node **deps, char *f));
void add_to_dep_list __((char *f));
void generate_dep __((void));
struct dtree_node *extract_deps __((struct dtree_node *d));
void write_defaults __((void));
char *dot_o __((char *x, char c));
#ifdef NT
void write_file_dep __((struct dtree_node *p_list, char *archive, FILE *fp));
#else
void write_file_dep __((struct dtree_node *p_list, char *archive));
#endif
void write_src_deps __((void));
void divide_src_list __((void));
void write_object_files __((void));
void write_src_group_targets __((void));
void write_outfile __((void));
void read_infile __((FILE *infile));

#if defined(__cplusplus)
}
#endif

static char	*is_include(char *s)
{
#define NONWHITE(S)	while (*(S) && (' ' == *(S) || '\t' == *(S))) ++(S)

	/*
	*	See if string s has valid include directive.
	*	Return pointer to first char after include.
	*/

	char	*p_includefilename = 0;

	/*
	*	Remove leading white space and look for
	*	a pound sign.
	*/

	NONWHITE(s);
	if (*s && '#' == *s && *++s)
	{
		/*
		*	Scan for the word include.
		*/

		NONWHITE(s);
		if (*s && !strncmp("include", s, 7))
			p_includefilename = s + 7;
	}

	return p_includefilename;

#undef NONWHITE
}

static int	is_std_include_directory(char *path)
{
         if( !strcmp(path, "/usr/include")) return 1;

         return 0;
}

static int	is_object_file(char *name, char **p_ext)
{
	int	object_file = 0;
	char	*dot = 0;

	if (dot = strrchr(name, '.'))
	{
		if (p_ext)
			*p_ext = dot + 1;

		if (*(dot+1) == 'o') object_file = 1;
	}
	return object_file;
}

/*=============================================================

                         M A I N

   Revision history:

   saw001   Oct 1988    Added getopt call to validate command
                        line input.

  =============================================================*/

int main (int argc, char *argv[], char **envr)
{

   FILE *in_file, *fopen ();
   int  option;
   char filename[50];

#if defined(NT)
   char  *p, *p2;

	{
		/*
		*	See if mkmk was executed with a pathname.  This
		*	path is used later to reference other executables
		*	that the output makefile may depend on.
		*/
   		char	*separator = 0;
   		if (separator = strrchr(argv[0], '\\'))
   		{
   			Path_to_mkmk = _strdup(argv[0]);
   			Path_to_mkmk[separator - argv[0]] = 0;
   		}
   	}
#endif

#if defined (UNIX)
   whyFlag = 1;
#elif defined (NT)
   whyFlag = 0;	/* When NT's nmake allows a larger buffer, can take this out */
#else
#error Unknown OS
#endif

   while (EOF != (option = getopt(argc,argv,"vo:i:w")))
   {
      switch(option)
      {
         case 'v':
            verbose = 1;
            break;
         case 'o':
            if ('-' == *optarg && 0 == *(optarg+1))
               outfp = stdout;
#ifdef NT
            else
            {
               /* Generate the path for any M<src_group> files
                * generated for use by the makefile
                */

               strcpy(obj_file, optarg);
               p = strrchr(obj_file, '\\');
               p2 = strrchr(obj_file, '/');
               if (p && (p > p2))
               {
                  *(++p) = 'M';
                  *(++p) = '\0';
               }
               else if (p2)
               {
                  *(++p2) = 'M';
                  *(++p2) = '\0';
               }
               else
                  strcpy(obj_file, "M");
               if (!(outfp = fopen(optarg, "w")))
               {
                  perror(optarg);
                  exit(1);
               }
            }
#else
            else if (!(outfp = fopen(optarg, "w")))
            {
               perror(optarg);
               exit(1);
            }
#endif
            break;
	 case 'i':
	    ignore = get_ignore_list(optarg);
	    break;
	 case 'w':
	    whyFlag = 0; /* Don't include the "WHY ... $?" clause in makefile */
	    break;
         default:
            fprintf(stderr,"usage: mkmk [-i ignorefile] [-v] [-w] [-o makefile] [spec.m]\n");
            exit(1);
            break;
      }
   }

   if (!outfp)
      if (!(outfp = fopen("makefile", "w")))
      {
         perror("Unable to open makefile\n");
         exit(1);
      }

   if (argv[optind])
   {
      if (!(in_file = fopen(argv[optind], "r")))
      {
         perror(argv[optind]);
         exit(1);
      }
   }
   else
   {
      strcpy(&filename[0], "mkmk.m");
      if (!(in_file = fopen(&filename[0], "r")))
      {
         perror("Unable to open mkmk.m\n");
         exit(1);
      }
   }

   *(int *)&src_flags = 0;	      /* Clear flags */

   read_infile(in_file);      /* Read the .m file, building a linked
                                 list for each keyword used. */
   generate_dep();            /* Add dependencies to source linked lists. */
   write_outfile();           /* Generate the make file. */
   exit(Errors);
#ifdef NT
   return Errors;
#endif
}

/*========================================

   new_dtree_node (a)

   Routine to add a node to a linked list.

  ========================================*/

struct dtree_node *new_dtree_node (a)
char *a;
{
   register struct dtree_node *dn;


   dn = (struct dtree_node *)calloc (1, sizeof (struct dtree_node));
   dn->fname =  string_malloc (a);

   return( dn );
}

/*========================================

   read_special

  ========================================*/

int read_special(struct dtree_node **pnode, FILE *infile, char *endstring)
{
   register struct dtree_node *p;
   int   ii;
   char  line[MAXLINESIZE], c;

   while (1)
   {
      ii = 0;
      while(1)
      {
         if (((c = getc(infile)) != EOF) && (c != '\n'))
         {
#ifdef NT
            if (c == '/')
               line[ii++] = '\\';
            else
#endif
               line[ii++] = c;
         }
         else
         {
            line[ii] = '\0';
            break;
         }
      }

      if (strcmp(endstring, line))
      {
         p = (struct dtree_node *)calloc (1, sizeof (struct dtree_node));
         p->fname = (char *)malloc(strlen(line)+1);
         strcpy(p->fname,line);
         if (*pnode)
         {
            while ((*pnode)->next)
               pnode = &((*pnode)->next);
            (*pnode)->next = p;
         }
         else
            *pnode = p;
         pnode = &((*pnode)->next);
         if (c == EOF)
            break;
      }
      else
         break;
   }

   return(0);
}

/*========================================

   read_line

  ========================================*/

int read_line(struct dtree_node **pnode, FILE *infile)
{
   register struct dtree_node *p;
   int   ii, c;
   char  line[MAXLINESIZE];

   ii = 0;
   while (1)
   {
      if (((c = getc(infile)) != EOF) && (c != '\n'))
         line[ii++] = c;
      else
      {
         line[ii] = '\0';
         break;
      }
   }
   p = (struct dtree_node *)calloc (1, sizeof (struct dtree_node));
   p->fname = (char *)malloc(strlen(line)+1);
   strcpy(p->fname,line);
   if (*pnode)
   {
      while ((*pnode)->next)
         pnode = &((*pnode)->next);
      (*pnode)->next = p;
   }
   else
      *pnode = p;
   pnode = &((*pnode)->next);

   return(0);
}

/*****************************************************************

   find_name (p, f)

	Searches linked list p for token f.

******************************************************************/


struct dtree_node *find_name (p,f)
register struct dtree_node *p;
register char *f;
{
   while (p)
   {
      if (!strcmp(f,p->fname)) return (p);
      p = p->next;
   }
   return (0);
}

/*****************************************************************

   new_src_group

	Allocates a new src_group

******************************************************************/

struct source_group_node	*new_src_group(name)
char	*name;
{
	struct source_group_node	**src_group;

	if (src_group = &srcfiles)  /* Add new source group to srcfiles */
		while(*src_group)
			src_group = &((*src_group)->next);
	if (*src_group = (struct source_group_node *)
		calloc(1, sizeof(struct source_group_node)))
		(*src_group)->sgrp_name = name;

	return *src_group;
}

/*****************************************************************

   in_any_src_group

	Determines if given file name resides in any source group.

******************************************************************/

int in_any_src_group(f)
register char *f;
{
   register  struct source_group_node   *s;

   s = srcfiles;
   while (s) {
	if ( in_src_group( s, f ) ) return( 1 );
	s = s->next;
   }
   return( 0 );
}

/*****************************************************************

   in_src_group

	Determines if given file name resides in any the given
	source group.

 *****************************************************************/

int in_src_group( sg, f )
register  struct source_group_node   *sg;
char	*f;
{
   register  struct dtree_node   *p;
   char  *ex_f;

   if( ! expand_filename( f, file_name, sizeof( file_name ) )  &&  (ex_f=strdup( file_name ) ) ) {
         p = sg->c_list;
         while (p) {
             if( ! generate_filename(srcpath->fname, p->fname)  &&  ! strcmp( ex_f, file_name) ) return( 1 );
             p = p->next;
         }
         free( ex_f );
   }
   return( 0 );
}

/*****************************************************************

   find_src_group

	Returns src_group pointer by name.

******************************************************************/

struct source_group_node *find_src_group(name)
char *name;
{
   struct source_group_node   *s;

   for (s = srcfiles; s; s = s->next)
	if (!strcmp(s->sgrp_name, name))
		return s;
   return 0;
}

/*****************************************************************

   get_src_group

	Looks up a source group by name (scans for =<source_group> syntax).
	If it does not exist, a new source group is created.

******************************************************************/

struct source_group_node *get_src_group(buf, keyword)
char	*buf;
char	*keyword;
{
	struct source_group_node	*p = 0;

	if (strrchr(buf, '='))    /* =<source_group> syntax */
	{
		int   ii;
		char  *name = 0;

		for (ii = 0; (isspace(buf[ii]) || (buf[ii] == '=')); ii++);
		name = string_malloc(&buf[ii]);
		if (!(p = find_src_group(name)))
		{
			if (!(p = new_src_group(name)))
			{
				fprintf(stderr, "mkmk: %s: could not allocate source group %s\n", keyword, name);
				exit(++Errors);
			}
		}
	}
	else  /* default is "objects" source group */
	{
		static struct source_group_node	*objects = 0;

		if (!objects)
		{
			if (!(objects = find_src_group("objects")))
			{
				if (!(objects = new_src_group(strdup("objects"))))
				{
					fprintf(stderr, "mkmk: %s: cannot allocate source group\n", keyword);
					exit(++Errors);
				}
			}
		}
		p = objects;
	}

	return p;
}

/*****************************************************************

   add_dep_list

*****************************************************************/

void add_dep_list (dd,d)
register struct dtree_node **dd;
register struct dtree_node *d;
{
   register struct dtree_node *p;

   while (d)
   {
      if( ! d->DN_macro  &&  ! d->DN_nodep )
      {
         if (!find_name(*dd,d->fname))
         {
               p = new_dtree_node (d->fname);
               p->next = *dd;
               *dd = p;
               p = find_name (depfiles,d->fname);
               if (p)
                  add_dep_list (dd,p->dep);
         }
      }
      else
      {
         p = (struct dtree_node *)calloc (1, sizeof (struct dtree_node));
         p->fname = (char *)malloc(strlen(d->fname)+1);
         strcpy(p->fname,d->fname);
         p->next = *dd;
         *dd = p;
      }
      d = d->next;
   }
}

/*****************************************************************

   gobble_filename

*****************************************************************/

void gobble_filename (a)
register char *a;
{
   register int i;

   i = strlen (a);
   while (i--)
   {
      if (a[i] == SEPARATOR_C) return;
      a[i] = 0;
   }
}

/*****************************************************************

  generate_filename

	will expand macro in path name and prepend it to the base
	name and store the results in "file_name".  Currently only
	looks for macro at beginning of the path and will not find
	any that are embedded.

*****************************************************************/

int generate_filename( path, base )
char 	*path, *base;
{
  char *in_file;
  register int status;

  sprintf(file_name, "%s%s%s", path, ( (base[0]) ? SEPARATOR_S: "\0"), base );

  in_file = strdup( file_name );

  if( status = expand_filename( in_file, file_name, sizeof( file_name ) ) ) {
	fprintf(stderr, " WARNING: Unable to expand %s\n", in_file );
	perror("\tSYSTEM: ");
  } else {
	reduce_pth (file_name);
  }

  free( in_file );
  return( status );
}

/*****************************************************************

   find_file

*****************************************************************/

char *find_file (mode, fn, cf)
int   mode;
char  *fn;
char  *cf;
{
   struct dtree_node *p;

   if (is_absolute_path(fn))
   {
      strcpy(file_name, fn);
      reduce_pth(file_name);
      if (is_file(file_name))
         return(file_name);
      else if (!ignore || !find_name(ignore, file_name))
      {
         fprintf (stderr," Cannot find file <%s> included by <%s>\n", fn, cf);
         ++Errors;
      }
      return (0);
   }
   else
   {
      if (mode == 'S')
      {
         p = spcfiles;
         while (p)
         {
	    if( !generate_filename( p->fname, fn )  &&  is_file(file_name) )
            {
               sprintf(file_name, "%s%s%s", p->fname, SEPARATOR_S, fn);
               return (file_name);
            }
            p = p->next;
         }
         if (!ignore || !find_name(ignore, fn))
         {
           fprintf (stderr," Cannot find file <%s> included by <%s>\n", fn, cf);
           ++Errors;
         }
         return (0);
      }
      else
      {
         if (mode == '\"')
         {
            strcpy(file_name, cf);
            gobble_filename(file_name);
            strcat(file_name, fn);
            reduce_pth(file_name);
            if (is_file(file_name))
               return(file_name);
         }
         p = incfiles;
         while (p)
         {
	    if( !generate_filename( p->fname, fn )  &&  is_file(file_name) )
            {
               sprintf(file_name, "%s%s%s", p->fname, SEPARATOR_S, fn);
               return(file_name);
            }
            p = p->next;
         }
         if (!ignore || !find_name(ignore, fn))
         {
           fprintf (stderr," Cannot find file <%s> included by <%s>\n", fn, cf);
           ++Errors;
         }
         return (0);
      }
   }
}

/*****************************************************************

   scan_om_file

	For each file listed in srcpath and spcpath, scan for
	'#include' or 'class' or 'specification' statements to
	build a list of dependencies for the source or spec file.

*****************************************************************/

#define NEXT_ATOM()	if (!(stat = fget_atom (atom,infile))) break
#define DISCARD_OPTIONAL_VERSION() 				\
	if (!strcmp(atom, "("))					\
	{							\
		NEXT_ATOM();	/* major version */		\
		NEXT_ATOM();					\
		if (!strcmp(atom,":"))				\
		{						\
			NEXT_ATOM();	/* minor version */	\
			NEXT_ATOM();				\
			if (strcmp(atom,")"))			\
				continue;			\
			NEXT_ATOM();				\
		}						\
		else						\
			continue;				\
	}

struct dtree_node *scan_om_file(f)
char  *f;
{
   FILE  *infile;
   int   stat, len;
   struct dtree_node *deps;
   struct dtree_node *p;
   char  *rdp;
   char  atom[MAXLINESIZE];
   char  line[MAXLINESIZE];
   char  depfile[MAXLINESIZE];
   int   is_opp = 0;

   deps = 0;

   if (verbose)
      fprintf (stderr,"scanning file <%s>\n",f);

   if( expand_filename( f, depfile, sizeof(depfile) )  ||  ! (infile = fopen (depfile,"r") ) )
   {
      fprintf (stderr," Cannot find file <%s> \n", f);
      ++Errors;
      return (0);
   }

   len = strlen(depfile);
   if ('S' == depfile[len-1] || 'I' == depfile[len-1])
      is_opp = 1;

   stat = fget_atom(atom, infile);
   while (stat)
   {
#ifdef _DEBUG
printf("%s: atom: %s\n", f, atom);
#endif
      if (0 == atomic_line_position && !strcmp(atom, "#include"))
      {
         int error = 0;

         if (!fgets(line, MAXLINESIZE, infile))
            return(0);
         ungetc('\n', infile);

         error = find_include_file(line, &deps, f);

         if (error)
         {
            fprintf(stderr, "Bad #include statement in file <%s>\n", f);
            return(0);
         }
         stat = fget_atom (atom,infile);

      }/* if first atom on the line and include */
      else if (is_opp && !strcmp(atom,"class"))
      {
         NEXT_ATOM();
         if (!strcmp(atom,"specification"))
         {
            NEXT_ATOM();	/* classname */
	    strcpy(depfile, atom);
            NEXT_ATOM();
            DISCARD_OPTIONAL_VERSION();
            while (!strcmp(atom, ",") || !strcmp(atom,"of"))
            {
               NEXT_ATOM();
               if (strcmp(depfile, atom))
               {
                  strcat(atom, ".S");
                  rdp = find_file('S', atom, f);
                  if (rdp)
                  {
                     p = new_dtree_node(rdp);
                     p->next = deps;
                     deps = p;
		  }
                  NEXT_ATOM();
               }
            }/* while comma separated list */
            is_opp = 0;  /* only one class spec line per file */
         }/* if specification */
         else if (!strcmp(atom, "implementation"))
         {
            NEXT_ATOM();
            strcat(atom, ".S");
            rdp = find_file('S', atom, f);
            if (rdp)
            {
               p = new_dtree_node(rdp);
               p->next = deps;
               deps = p;
            }
            else
            {
               fprintf(stderr, " Cannot find file <%s> from class implementation in <%s>\n", atom, f);
               ++Errors;
            }

            stat = fget_atom(atom, infile);
         }
      } /* if class */
      else if (is_opp && !strcmp(atom, "from"))
      {
         NEXT_ATOM();
         strcpy(depfile, atom);
         NEXT_ATOM();
         if (!strcmp(atom, "import"))
         {
            strcat(depfile, ".S");
            rdp = find_file('S', depfile, f);
            if (rdp)
            {
               p = new_dtree_node(rdp);
               p->next = deps;
               deps = p;
            }
            else if (!ignore || !find_name(ignore, depfile))
            {
               fprintf(stderr, " Cannot find file <%s> from import in <%s>\n", depfile, f);
               ++Errors;
            }

            stat = fget_atom(atom, infile);
         }
      } /* if from */
      else
         stat = fget_atom(atom, infile);

   }/* while stat */

   fclose(infile);
   return(deps);
}

#undef NEXT_ATOM
#undef DISCARD_OPTIONAL_VERSION

/*****************************************************************

   scan_c_file

	For source files other than spec and implementation files,
	build a list of dependencies for the source or spec file.

*****************************************************************/

struct dtree_node *scan_c_file(f)
char  *f;
{
   FILE  *infile;
   struct dtree_node *deps;
   char  *p_includefilename = 0;

   char  line[MAXLINESIZE];


   deps = 0;

   if (verbose)
      fprintf (stderr,"scanning file <%s>\n",f);

   if( expand_filename( f, file_name, sizeof(file_name) )  ||  ! (infile = fopen (file_name, "r") ) )
   {
      fprintf (stderr," Cannot find file <%s> \n", f);
      ++Errors;
      return(0);
   }
   while (fgets(line, MAXLINESIZE, infile))
      if (p_includefilename = is_include(line))
         if (find_include_file(p_includefilename, &deps, f))
         {
            fprintf(stderr, "Bad #include statement in file <%s>\n", f);
            return(0);
         }
   ungetc('\n', infile);
   fclose (infile);
   return (deps);
}

/*****************************************************************

   find_include_file

	Add include file to list of dependencies for a source file.

*****************************************************************/

int find_include_file(line, deps, f)
char              *line;
char              *f;
struct dtree_node **deps;
{
   int   ii, jj;
   struct dtree_node *p;
   char  *rdp;
   char  depfile[MAXMACROSIZE];
   char  macname[MAXMACROSIZE];        /* To hold macro names */

   macname[0] = '$';
   macname[1] = '(';
   ii = 0;
   for (; ((ii<124) && isspace(line[ii]) && (line[ii] != '\n')); ii++);
   if (line[ii] == '\n')
      return(1);
   if ((line[ii] != '<') && (line[ii] != '"'))

   {
      /*======================================================*/
      /* Instead of a filename, a macro name was given in the */
      /* #include statement.  Surround it with "$(" and ")"   */
      /* when writing it to the makefile, so it will not be   */
      /* substituted until the makefile is used for a make.   */
      /*======================================================*/

      if (!(isalnum(line[ii]) || '_' == line[ii]))
		return 0;
      macname[2] = line[ii++];
      jj = 3;
      while (isgraph(line[ii]))
         if (jj >= MAXMACROSIZE - 3 - 1)
         {
            fprintf(stderr, "Bad #include statement in file <%s>\n", f);
            fprintf(stderr, "maximum macro size of %u, has been exceeded by line:\n%s\n", MAXMACROSIZE, line);
            exit(++Errors);
         }
         else
            macname[jj++] = line[ii++];
      macname[jj++] = ')';
      macname[jj] = 0;
      p = (struct dtree_node *) calloc (1, sizeof (struct dtree_node));
      p->fname = (char *) malloc(strlen(macname)+1);
      strcpy(p->fname, macname);
      p->DN_macro = 1;
      p->next = *deps;
      *deps = p;
   }
   else
   {
      /*========================================*/
      /* Add file name to list of dependencies. */
      /*========================================*/
      char  c;
      if (line[ii] == '<')
         c = '>';
      else
         c = line[ii];            /* c = " */
      for (jj=0; line[++ii] != c; jj++)
         if (jj >= MAXMACROSIZE - 1)
         {
            fprintf(stderr, "Bad #include statement in file <%s>\n", f);
            fprintf(stderr, "maximum include pathname size of %u, has been exceeded by line:\n%s\n", MAXMACROSIZE, line);
            exit(++Errors);
         }
         else
            depfile[jj] = line[ii];
      depfile[jj] = 0;
      rdp = find_file(c, depfile, f);
      if (rdp)
      {
         p = new_dtree_node(rdp);
         p->next = *deps;
         *deps = p;
      }
   }
   return(0);
}

/*****************************************************************

   add_to_dep_list

*****************************************************************/

void add_to_dep_list (f)
register char *f;
{
   register  struct source_group_node   *s;
   register  struct dtree_node *p;
   register  struct dtree_node *d;
   char	*ext = 0;

   s = srcfiles;
   while (s)
   {
      char  c;

      /*if( in_src_group( s, f ) ) return;*/

      p = depfiles;
      while (p)
      {
         if (!strcmp(f,p->fname)) return;
         p = p->next;
      }
      p = new_dtree_node (f);
      p->next = depfiles;
      depfiles = p;
      if (! is_object_file(p->fname, &ext) )
      {
         c = *ext;
         if ((c == 'S') || (c == 'I') || (c == 'C'))
            p->dep = scan_om_file (f);
         else
            p->dep = scan_c_file (f);
         d = p->dep;
         while (d)
         {
/*            if (d->fname[0] != '$')
 *                add_to_dep_list (d->fname);  */
	    if( ! d->DN_macro  &&  ! d->DN_nodep )
	          add_to_dep_list (d->fname);
            d = d->next;
         }
      }
      s = s->next;
   }
}

/*****************************************************************

   generate_dep

	For each source file in the srcfiles list, generate the
	list of include files its dependent upon.

*****************************************************************/

void generate_dep ()
{
   register struct source_group_node   *s;
   register struct dtree_node          *d;
   struct dtree_node    *p;
   char                 c = (char)0;

   s = srcfiles;
   while (s)                     /* For each source group */
   {
      p = s->c_list;           /* Build dep list for each source file */
      while (p)
      {
	 char	*dot;

         dot = strrchr(p->fname, '.');
         if (dot && (c = *(dot + 1)) == 'S'
			||
		c == 'I'
			||
		c == 'C')
            p->dep = scan_om_file (p->fname);
         else
            p->dep = scan_c_file (p->fname);
         d = p->dep;
         while (d)
         {
            /*=====================================================*/
            /* Add to depfiles list if not a macro, is not already */
            /* in list or is not to be searched for dependants.    */
            /*=====================================================*/

	    if( ! d->DN_macro  &&  ! d->DN_nodep )
		add_to_dep_list (d->fname);
            d = d->next;
         }
         p = p->next;
      }
      s = s->next;               /* Repeat for next source code group */
   }
}

/*****************************************************************

   extract_deps

*****************************************************************/

struct dtree_node *extract_deps (d)
register struct dtree_node *d;
{
   struct dtree_node *deps;


   deps = 0;
   add_dep_list (&deps,d);
   return (deps);
}

/*****************************************************************

   write_defaults

	Write .SUFFIXES line and macro definitions.  Use mkmk
	defaults for all unless user has specified them.

*****************************************************************/

void write_defaults()
{
   register struct dtree_node *p;

   if (!sufixpath && !nosuffixes)
   {
      if (has_archive)
      {
         struct source_group_node *s;

         fprintf (outfp,".PRECIOUS:");
         for (s = srcfiles; s; s = s->next)
            if (s->archive)
               fprintf (outfp," %s",  s->archive->fname);
         fprintf (outfp,"\n\n");
#if defined(UNIX)
         fprintf (outfp,".SUFFIXES: .a");
#elif defined(NT)
         fprintf (outfp,".SUFFIXES: .lib");
#else
#error Unknown OS
#endif
      }
      else
         fprintf (outfp,".SUFFIXES:");
      if (src_flags.spec)
         fprintf (outfp," .S");
      if (src_flags.imp)
         fprintf (outfp," .I");
      if (src_flags.C)
         fprintf (outfp," .C");
      if (src_flags.assm)
         fprintf (outfp," .s");
#if defined(UNIX)
      fprintf(outfp, " .c .o\n\n");
#elif defined(NT)
      fprintf(outfp, " .c .obj\n\n");
#else
#error Unknown OS
#endif
   }

   if (verbose_rules)
      fprintf (outfp, "VERBOSE_RULES = 1\n\n");

   if (!oppath && (src_flags.imp || src_flags.spec))
      fprintf (outfp,"opp = %s\n\n", OPP);
   if (!omcppath && src_flags.C)
      fprintf (outfp,"omcpp = %s\n\n", OMCPP);
   if (!ccpath)
      fprintf (outfp,"CC = %s\n\n", CC);
#ifdef NT
   if (!echopath)
   {
   	if (Path_to_mkmk)
		fprintf(outfp, "ECHO = %s\\execho\n\n", Path_to_mkmk);
	else
		fprintf(outfp, "ECHO = execho\n\n");
   }
#endif

   if ( !linkflags )
#ifdef NT
     fprintf(outfp, "LINKOPT = -subsystem:console -entry:mainCRTStartup\n\n" );
#else
     fprintf(outfp, "LINKOPT =\n\n" );
#endif

   if (!src_specified)
      fprintf(outfp, "SRC = %s\n\n", srcpath->fname);

   if (!oppflags && (src_flags.spec || src_flags.imp || src_flags.C))
   {
      fprintf(outfp, "OPPFLAGS = ");
      for ( p = incfiles; p; p = p->next )
         if(!is_std_include_directory(p->fname))
             fprintf(outfp, " \\\n\t-I%s", p->fname);

      p = spcfiles;
      while(p)
      {
         fprintf(outfp, " \\\n\t-I%s", ('.' == p->fname[0] && 0 == p->fname[1])?"$(SRC)":p->fname);
         p = p->next;
      }
      p = oppflags;
      while(p)
      {
         fprintf(outfp, " \\\n\t%s", p->fname);
         p = p->next;
      }
      fprintf(outfp, "\n\n");
   }
}

/*****************************************************************

    dot_o

*****************************************************************/

char doto_arr [MAXLINESIZE];

char *dot_o (char *x, char c)
{
   register int   i;

   doto_arr [0] = 0;
   strcpy (doto_arr, x);
   i = strlen (doto_arr);
   i--;
   while (doto_arr [i] != '.')
   {
      doto_arr [i] = 0;
      i--;
   }
   i++;
   doto_arr[i] = c;
#ifdef NT
   if ('o' == c)
   {
   	doto_arr[++i] = 'b';
   	doto_arr[++i] = 'j';
   }
#endif
   doto_arr[i+1] = 0;
   return (doto_arr);
}

/*****************************************************************

   free_dtree_list

*****************************************************************/

static void free_dtree_list(list)
struct dtree_node	*list;
{
	struct dtree_node	*d, *dp;

	for (d = list; d; )
	{
		dp = d;
		free(d->fname);
		d = d->next;
		free(dp);
	}
}

/*****************************************************************

   write_file_dep

*****************************************************************/

#ifdef NT
void write_file_dep(struct dtree_node *p_list, char *archive, FILE *fp)
#else
void write_file_dep(struct dtree_node *p_list, char *archive)
#endif
{
   struct dtree_node *d, *deps;

   while (p_list)
   {
      if (archive)
         fprintf (outfp,"%s(%s) :", archive, dot_o(p_list->fname, 'o'));
      else
         fprintf (outfp,"%s :", dot_o (p_list->fname, 'o'));
#ifdef NT
      fprintf(fp, "%s\n", dot_o (p_list->fname, 'o'));
#endif

      fprintf (outfp," \\\n	$(SRC)%s%s", SEPARATOR_S, p_list->fname);

      d = deps = extract_deps (p_list->dep);
      while (d)
      {
         if ('.' == d->fname[0] && SEPARATOR_C == d->fname[1])
            fprintf (outfp," \\\n	$(SRC)%s%s", SEPARATOR_S, &d->fname[2]);
         else if (!strchr(d->fname, SEPARATOR_C))
            fprintf (outfp," \\\n	$(SRC)%s%s", SEPARATOR_S, d->fname);
	 else
            fprintf (outfp," \\\n	%s", d->fname);

         d = d->next;

      }/* while more dependents */
      fprintf (outfp,"\n\n");

      free_dtree_list(deps);
      p_list = p_list->next;
   }
}

/*****************************************************************

   write_src_deps

*****************************************************************/

void write_src_deps ()
{
   struct source_group_node *s = srcfiles;

#ifdef NT
   FILE  *objects_file = 0;
   char  outfname[256];
   int   i;
   struct dtree_node *p_list;
   int   index=strlen(obj_file);
#endif

   while(s)
   {
#ifdef NT
      strcat(obj_file, s->sgrp_name);
      if (!(objects_file = fopen(obj_file, "w" )))
      {
         perror(obj_file);
         exit(1);
      }

      write_file_dep(s->c_list, (char *)0, objects_file);
      write_file_dep(s->C_list, (char *)0, objects_file);
      write_file_dep(s->spec_list, (char *)0, objects_file);
      write_file_dep(s->imp_list, (char *)0, objects_file);
      write_file_dep(s->assm_list, (char *)0, objects_file);
      write_file_dep(s->yacc_list, (char *)0, objects_file);
      write_file_dep(s->lex_list, (char *)0, objects_file);
      write_file_dep(s->unk_list, (char *)0, objects_file);
/*Added this to include DEPLIB files in M<src_grp>file generated -KK */
      p_list = s->deplib;
      while(p_list)
      {
        /* Remove MACROS from the filename written to M<src> - KK */
        if (p_list->fname[0] == '$')
          expand_filename(p_list->fname, outfname,256);
        else
          strcpy(outfname,p_list->fname);
        /* if the file is a .lib dont convert it to .obj - kk */
        i = strlen (outfname);
        if (!strcmp(&outfname[i - 3], "lib"))
          fprintf(objects_file, "%s\n", outfname);
        else
          fprintf(objects_file, "%s\n", dot_o(outfname, 'o'));

        p_list = p_list->next;
      }
      fclose(objects_file);
      obj_file[index] = '\0';
#else
      write_file_dep(s->c_list, (char *)0);
      write_file_dep(s->C_list, (char *)0);
      write_file_dep(s->spec_list, (char *)0);
      write_file_dep(s->imp_list, (char *)0);
      write_file_dep(s->assm_list, (char *)0);
      write_file_dep(s->yacc_list, (char *)0);
      write_file_dep(s->lex_list, (char *)0);
      write_file_dep(s->unk_list, (char *)0);
#endif
      s = s->next;
   }
}

/*****************************************************************

  divide_src_list

	At this point, each source group node off of srcfiles
	contains one long linked list of all source files it's
	dependent on off of its c_list field.  In this routine,
	we divide them into different linked lists off of
	srcfiles, depending on their suffixes.  .S files all go
	on the spec_list linked list; .I files on imp_list; .C files
	on C_list;  everything else, including .c files, stays on the c_list.

 *****************************************************************/

void divide_src_list ()
{
   register struct source_group_node   *s;

   register struct dtree_node   *p,
				**src,
				***tmp;

   struct dtree_node 		**C,
				**assm,
				**lex,
				**yacc,
  				**imp,
				**spec,
				**unk;

   /*===========================================================*/
   /* Loop through the list of source groups again and separate */
   /* each list of source files into 5 lists: spec files, imp   */
   /* files, C files and other type source files.    		*/
   /*===========================================================*/
   s = srcfiles;
   while (s)                        /* For each source group */
   {
      register	char 	*c;

      C = &(s->C_list);
      assm = &(s->assm_list);
      lex = &(s->lex_list);
      yacc = &(s->yacc_list);
      imp = &(s->imp_list);
      spec = &(s->spec_list);
      unk = &(s->unk_list);

      src = &(s->c_list);
      p = *src;

      while (p)                     /* For each source file */
      {
        int len;

        /*
	**	Check to see if the filename ends
	**	in .[MISClycs]
	*/

        len = strlen(p->fname);
        if ('.' == p->fname[len-2])
           c = &p->fname[len-1];
        else
           c = "?";

	switch ( *c ) {

	    case 'S':
	            src_flags.spec = 1;
		    tmp = &spec;
		    break;

	    case 'I':
	            src_flags.imp = 1;
        	    tmp = &imp;
		    break;

	    case 'C':
	            src_flags.C = 1;
        	    tmp = &C;
		    break;

	    case 'l':
	            src_flags.lex = 1;
        	    tmp = &lex;
	            break;

	    case 'y':
	            src_flags.yacc = 1;
        	    tmp = &yacc;
	            break;

	    case 's':
	            src_flags.assm = 1;
        	    tmp = &assm;
		    break;

	    case 'c':
	            src_flags.c = 1;
		    tmp = 0;
		    break;

	    default:
	            src_flags.unk = 1;
		    tmp = &unk;
	            break;
	}
	if( tmp ) {
		**tmp = p;
		p = p->next;
	        *src = p;
	        (**tmp)->next = 0;
	        *tmp = &((**tmp)->next);
	} else {
        	src = &(p->next);
	        p = p->next;
	}
      }
      s = s->next;                /* Repeat for next source code group */
   }
}


/*****************************************************************

    write_object_files

*****************************************************************/

void write_object_files ()
{
   register struct source_group_node   *s;
   register struct dtree_node          *p;
   char	last_str[ 512 ];

   fprintf (outfp,"\n# Object files \n\n");
   s = srcfiles;
   while (s)
   {
      last_str[0] = 0;

      if( p = s->yacc_list ) {
	      fprintf (outfp,"yacc_%s =", s->sgrp_name);
	      while (p) {
	         fprintf (outfp," \\\n	%s", dot_o (p->fname, 'o'));
        	 p = p->next;
	      }
	      fprintf (outfp,"\n\n");
	      sprintf( last_str, "%s\\\n\t$(yacc_%s) ", last_str, s->sgrp_name );
      }

      if( p = s->lex_list ) {
      	      fprintf (outfp,"lex_%s =", s->sgrp_name);
	      while (p) {
	         fprintf (outfp," \\\n	%s", dot_o (p->fname, 'o'));
	         p = p->next;
	      }
	      fprintf (outfp,"\n\n");
	      sprintf( last_str, "%s\\\n\t$(lex_%s) ", last_str, s->sgrp_name );
      }

      if( p = s->c_list ) {
	      fprintf (outfp,"c_%s =", s->sgrp_name);
	      while (p) {
	         fprintf (outfp," \\\n	%s", dot_o (p->fname, 'o'));
	         p = p->next;
	      }
	      fprintf (outfp,"\n\n");
	      sprintf( last_str, "%s\\\n\t$(c_%s) ", last_str, s->sgrp_name );
      }

      if( p = s->assm_list ) {
	      fprintf (outfp,"assm_%s =", s->sgrp_name);
	      while (p) {
	         fprintf (outfp," \\\n	%s", dot_o (p->fname, 'o'));
	         p = p->next;
	      }
	      fprintf (outfp,"\n\n");
	      sprintf( last_str, "%s\\\n\t$(assm_%s) ", last_str, s->sgrp_name );
      }

      if( p = s->C_list ) {
	      fprintf (outfp,"C_%s =", s->sgrp_name);
	      while (p) {
	         fprintf (outfp," \\\n	%s", dot_o (p->fname, 'o'));
	         p = p->next;
	      }
	      fprintf (outfp,"\n\n");
	      sprintf( last_str, "%s\\\n\t$(C_%s) ", last_str, s->sgrp_name );
      }

      if( p = s->spec_list ) {
	      fprintf (outfp,"spec_%s =", s->sgrp_name);
	      while (p) {
	         fprintf (outfp," \\\n	%s", dot_o (p->fname, 'o'));
	         p = p->next;
	      }
	      fprintf (outfp,"\n\n");
	      sprintf( last_str, "%s\\\n\t$(spec_%s) ", last_str, s->sgrp_name );
      }

      if (p = s->imp_list ) {
	      fprintf (outfp,"imp_%s =", s->sgrp_name);
	      while (p) {
	         fprintf (outfp," \\\n	%s", dot_o (p->fname, 'o'));
        	 p = p->next;
	      }
	      fprintf (outfp,"\n\n");
	      sprintf( last_str, "%s\\\n\t$(imp_%s) ", last_str, s->sgrp_name );
      }

      if( p = s->unk_list ) {
	      fprintf (outfp,"unk_%s =", s->sgrp_name);
	      while (p) {
	         fprintf (outfp," \\\n	%s", dot_o (p->fname, 'o'));
	         p = p->next;
	      }
	      fprintf (outfp,"\n\n");
	      sprintf( last_str, "%s\\\n\t$(unk_%s) ", last_str, s->sgrp_name );
      }

      fprintf(outfp, "%s = %s\n\n", s->sgrp_name, last_str );
      s = s->next;
   }
}

/*****************************************************************

    write_src_group_targets

*****************************************************************/

void write_src_group_targets()
{
   struct source_group_node   *s;
   struct dtree_node *p;

   if (target)
   {
      /*
      **   Main target was specified.  This should be a list of
      **   executable(s), library(s), and/or archive(s).
      */

      fprintf(outfp, "\n# main target\n\n");
      fprintf(outfp, "target:");
      for (p = target; p; p = p->next)
         fprintf(outfp, " \\\n\t%s", p->fname);
      fprintf(outfp, "\n\n");
   }

   fprintf (outfp,"\n# src group targets\n\n");
   s = srcfiles;
   while (s)
   {
      int    is_objects = 0;

      if (!strcmp(s->sgrp_name, "objects"))
         is_objects = 1;

      if (s->linklib)
      {
         if (!is_objects)
            fprintf(outfp, "LINKLIB_%s =", s->sgrp_name);
         else
            fprintf(outfp, "LINKLIB =");
         for (p = s->linklib; p; p = p->next)
             fprintf(outfp, " \\\n\t%s", p->fname);
         fprintf(outfp, "\n\n");
      }

      if (s->archive || s->execname || s->libname)
      {
         char *name = s->archive ?
			s->archive->fname :
			s->execname ?
				s->execname->fname : s->libname->fname;

         fprintf(outfp, "%s_TARGET = %s\n\n", s->sgrp_name, name);
         fprintf(outfp, "$(%s_TARGET): $(%s)", s->sgrp_name, s->sgrp_name);
         for (p = s->deplib; p; p = p->next)
            fprintf(outfp, " \\\n\t%s", p->fname);
         fprintf(outfp, "\n");
#if defined(UNIX)
         fprintf (outfp,"\t@echo \n" );
#elif defined(NT)
         fprintf (outfp,"\t@$(ECHO)\n" );
#else
#error Unknown OS
#endif
         if (s->execname)
         {
#if defined(UNIX)
            fprintf (outfp,"\t$(CC) $(LINKOPT) $(EXECOPT) $(COPT) -o %s ", name);
#elif defined(NT)
            fprintf (outfp,"\t@if exist %s del/q %s\n", name, name);
            fprintf (outfp,"\tlink $(DEBUGAMOUNT) $(DEBUGTYPE) $(LINKOPT) $(EXECOPT) $(COPT) -out:%s ", name);
#else
#error Unknown OS
#endif
            fprintf (outfp,"$(%s)", s->sgrp_name);
            for (p = s->deplib; p; p = p->next)
               fprintf(outfp, " %s", p->fname);
            if (s->linklib)
               if (!is_objects)
                  fprintf(outfp, " $(LINKLIB_%s)", s->sgrp_name);
               else
                  fprintf(outfp, " $(LINKLIB)");
#ifdef NT
            fprintf(outfp, " libc.lib kernel32.lib");
#endif
            fprintf(outfp, "\n");
         }
         else if (s->libname)
	 {
            fprintf (outfp,"\tld $(LDOPT) -r -o %s $(%s)", name, s->sgrp_name);

            for (p = s->deplib; p; p = p->next)
               fprintf(outfp, " %s", p->fname);
            fprintf(outfp, "\n");
         }
         else
         {
#if defined(SYSV)
            fprintf (outfp,"\tar rsuv %s $(%s)", s->archive->fname, s->sgrp_name);
#elif defined(BSD)
            fprintf (outfp,"\tar ruv %s $(%s)", s->archive->fname, s->sgrp_name);
#elif defined(NT)
            fprintf (outfp,"\tlib $(DEBUGTYPE) -out:%s @%s%s\n", name, obj_file, s->sgrp_name);
#else
#error Unknown OS
#endif

#ifndef NT
            for (p = s->deplib; p; p = p->next)
               fprintf(outfp, " %s", p->fname);
            fprintf(outfp, "\n");
#endif

#if defined(BSD)
  	    fprintf(outfp, "\tranlib %s\n", s->archive->fname);
#endif
         }
#if defined(UNIX)
         fprintf (outfp,"\t@if test -n \"$(VERBOSE_RULES)\"; then echo \"\\tls -ls %s\"; fi; ls -ls %s; echo\n\n", name, name);
#elif defined(NT)
         fprintf (outfp,"\t@if not \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\tdir /n %s\"\n", name);
         fprintf (outfp,"\t@dir /n %s\n", name);
         fprintf (outfp,"\t@$(ECHO)\n\n");
#else
#error Unknown OS
#endif
      }
      else
      {
         fprintf(outfp, "%s_TARGET = %s\n\n", s->sgrp_name, s->sgrp_name);
         fprintf(outfp, "$(%s_TARGET): $(%s)", s->sgrp_name, s->sgrp_name);
         for (p = s->deplib; p; p = p->next)
            fprintf(outfp, " %s", p->fname);
         fprintf(outfp, "\n\n");
      }
#if !defined(NT)
      fprintf(outfp, "%s_FAST: FASTstart $(%s) FASTfinish $(%s_TARGET)\n", s->sgrp_name, s->sgrp_name, s->sgrp_name);
      fprintf(outfp, "\n");
#endif
      s = s->next;
   }
}

/*****************************************************************

    write_outfile

*****************************************************************/

void write_outfile()
{
   char   user_rules_written, str[MAXLINESIZE];
   struct keyword_node  *mk;
   struct dtree_node    *p;

   user_rules_written = str[0] = 0;
   mk = makelist;

   divide_src_list();

   write_defaults();         /* Write default definitions not given by user */
   while(mk)
   {
      if (mk->linked_list)
      {
         switch (mk->keycode)
         {
            case 1:                 /* INCLUDE */
               fprintf(outfp, "IPATH = ");

               for(p = mk->linked_list; p; p = p->next )
                  if( !is_std_include_directory(p->fname) )
                     fprintf(outfp, " \\\n\t-I%s", p->fname);
	       fprintf(outfp, "\n\n");
               break;
            case 2:                 /* SPEC */
               break;
            case 3:                 /* SOURCE */
               break;
            case 4:                 /* VERSION */
               break;
            case 5:                 /* DEPENDENCIES */
               break;
            case 6:                 /* LINKLIB */
               break;
            case 7:                 /* COPT */
               fprintf(outfp, "COPT = ");
               p = mk->linked_list;
               while(p)
               {
                  fprintf(outfp, " \\\n\t%s", p->fname);
                  p = p->next;
               }
               fprintf(outfp, "\n\n");
               break;
            case 8:                 /* OPPFLAGS */
               fprintf(outfp, "OPPFLAGS = ");
               p = incfiles;
               while(p)
               {
                  if (!is_std_include_directory(p->fname))
                     fprintf(outfp, " \\\n\t-I%s", p->fname);
                  p = p->next;
               }
               p = spcfiles;
               while(p)
               {
                  fprintf(outfp, " \\\n\t-I%s", p->fname);
                  p = p->next;
               }
               p = mk->linked_list;
               while(p)
               {
                  fprintf(outfp, " \\\n\t%s", p->fname);
                  p = p->next;
               }
               fprintf(outfp, "\n\n");
               break;
            case 9:                 /* LIB */
               break;
            case 10:                 /* OPP */
               fprintf(outfp, "opp = %s\n\n", mk->linked_list->fname);
               break;
            case 11:                /* OMCPP */
               fprintf(outfp, "omcpp = %s\n\n", mk->linked_list->fname);
               break;
            case 12:                /* CC */
               fprintf(outfp, "CC = %s\n\n", mk->linked_list->fname);
               break;
            case 13:                /* HOME */
               fprintf(outfp, "HOME = %s\n\n", mk->linked_list->fname);
               break;
            case 14:                /* SRC */
               fprintf(outfp, "SRC = %s\n\n", mk->linked_list->fname);
               break;
            case 15:                /* EXEC */
               break;
            case 16:                /* ARCHIVE */
               break;
            case 17:                /* SUFFIXES */
               if (!nosuffixes)
                  fprintf(outfp, ".SUFFIXES: %s\n", mk->linked_list->fname);
               break;
            case 18:                /* RULES */
               if (!norules)
               {
                  p = mk->linked_list;
                  while (p)
                  {
                     fprintf(outfp, "%s\n", p->fname);
                     p = p->next;
                  }
                  fprintf(outfp, "\n");
                  user_rules_written = 1;
               }
               break;
            case 19:                /* SPECIAL */
               p = mk->linked_list;
               while (p)
               {
                  fprintf(outfp, "%s\n", p->fname);
                  p = p->next;
               }
               fprintf(outfp, "\n");
               break;
            case 20:                /* DOPT */
               fprintf(outfp, "DOPT = -D%s", mk->linked_list->fname);
               p = mk->linked_list->next;
               while (p)
               {
                  fprintf(outfp, " -D%s", p->fname);
                  p = p->next;
               }
               fprintf(outfp, "\n\n");
               break;
            case 21:                /* POST_SPECIAL */
               break;
            case 22:                /* TARGET */
               break;
            case 23:                /* DEPLIB */
               break;
            case 24:		    /* CCFILTER */
               fprintf(outfp, "CCFILTER = %s\n\n", mk->linked_list->fname);
               break;
            case 25:                /* DEFINE */
               for (p = mk->linked_list; p; p = p->next)
               {
		  char *value = 0;

                  if (!strcmp("CCDEF", p->fname))
                     value = ccdef;
		  else if (!strcmp("OMCPPDEF", p->fname))
                     value = omcppdef;
		  else if (!strcmp("OPPDEF", p->fname))
                     value = oppdef;
                  if (value)
                     fprintf(outfp, "%s = %s\n\n", p->fname, value);
               }
               break;
            case 26:                 /* ASOPT */
               fprintf(outfp, "ASOPT = ");
               p = mk->linked_list;
               while(p)
               {
                  fprintf(outfp, " \\\n\t%s", p->fname);
                  p = p->next;
               }
               fprintf(outfp, "\n\n");
               break;
            case 27:                 /* EXECOPT */
               fprintf(outfp, "EXECOPT = ");
               p = mk->linked_list;
               while(p)
               {
                  fprintf(outfp, " \\\n\t%s", p->fname);
                  p = p->next;
               }
               fprintf(outfp, "\n\n");
               break;
            case 28:                 /* VERBOSE_RULES */
               break;
            case 29:                 /* ECHO */
#ifdef NT
               fprintf(outfp, "ECHO =");
               p = mk->linked_list;
               while(p)
               {
                  fprintf(outfp, " %s", p->fname);
                  p = p->next;
               }
               fprintf(outfp, "\n\n");
#endif
               break;
            case 30:                 /* LINKOPT */
               fprintf(outfp, "LINKOPT = ");
               p = mk->linked_list;
               while(p)
               {
                  fprintf(outfp, " \\\n\t%s", p->fname);
                  p = p->next;
               }
               fprintf(outfp, "\n\n");
               break;
            default:
               fprintf(stderr, "Invalid keyword\n");
               exit(++Errors);
               break;
         }
      }
      mk = mk->next;
   }


   /*
   **	Write hardware specific -D flags.
   */

#if defined(clipper)
   fprintf(outfp, "MOPT = -Dclipper=1 -D__clipper__=1\n\n");
#elif defined(sparc)
   fprintf(outfp, "MOPT = -Dsparc=1 -D__sparc__=1 -Dsun=1 -D__sun__=1\n\n");
#elif defined(__mips) || defined(mips)
   fprintf(outfp, "MOPT = -Dmips=1 -D__mips__=1 -D__mips=1\n\n");
#elif defined(_M_IX86)
   fprintf(outfp, "MOPT = -D_M_IX86=%d -Di386=1\n\n", _M_IX86);
#elif defined(i386)
   fprintf(outfp, "MOPT = -Dsun=1 -D__sun__=1 -Di386=1 -D__i386=1 -D__i386__=1\n\n" );
#else
#error Unknown processor type
#endif
#if !defined(NT)
   /* Leave out on NT until FAST is working */
   fprintf(outfp, "ocfiles = %s\n\n", OCFILES);
#endif

   write_object_files();
   write_src_group_targets();
   write_src_deps();

   if (!user_rules_written && !norules)
      write_rules();
   if (p = postpath)
   {
      while (p)
      {
         fprintf(outfp, "%s\n", p->fname);
         p = p->next;
      }
      fprintf(outfp, "\n");
   }

#if !defined(NT)
         fprintf(outfp, "FASTstart:\n");
         fprintf(outfp, "\t@rm -f opp.list cc.list\n\n");
         fprintf(outfp, "FASTfinish:\n");
         fprintf(outfp, "\t@if [ \"$(FAST)\" ]; \\\n");
         fprintf(outfp, "\t then \\\n");
         fprintf(outfp, "\t     if [ -s opp.list ]; \\\n");
         fprintf(outfp, "\t     then \\\n");
         fprintf(outfp, "\t         echo \"\\topping files\"; \\\n");
         fprintf(outfp, "\t         if [ -n \"$(VERBOSE_RULES)\" ]; \\\n");
         fprintf(outfp, "\t         then \\\n");
         fprintf(outfp, "\t             echo \"\\t$(ocfiles) %s `cat opp.list`\"; \\\n", oppdef);
         fprintf(outfp, "\t         fi; \\\n");
         fprintf(outfp, "\t         $(ocfiles) %s `cat opp.list`; \\\n", oppdef);
         fprintf(outfp, "\t         sed -e 's/\\.[IS]/.c/' <opp.list >>cc.list; \\\n");
         fprintf(outfp, "\t     else \\\n");
         fprintf(outfp, "\t         echo \"\\tnothing to opp\"; \\\n");
         fprintf(outfp, "\t     fi; \\\n");
         fprintf(outfp, "\t     if [ -s cc.list ]; \\\n");
         fprintf(outfp, "\t     then \\\n");
         fprintf(outfp, "\t         echo \"\\tcompiling files\"; \\\n");
         fprintf(outfp, "\t         if [ -n \"$(VERBOSE_RULES)\" ]; \\\n");
         fprintf(outfp, "\t         then \\\n");
         fprintf(outfp, "\t             echo \"\\t$(ocfiles) %s -c `cat cc.list`\"; \\\n", ccdef);
         fprintf(outfp, "\t         fi; \\\n");
         fprintf(outfp, "\t         $(ocfiles) %s -c `cat cc.list`; \\\n", ccdef);
         fprintf(outfp, "\t         if [ \"$(COPT)\" != \"-g\" -a \"$(DEBUG)\" != \"yes\" ]; \\\n");
         fprintf(outfp, "\t         then \\\n");
         fprintf(outfp, "\t             echo \"\\tremoving .c files\"; \\\n");
         fprintf(outfp, "\t             rm `cat cc.list`; \\\n");
         fprintf(outfp, "\t         else \\\n");
         fprintf(outfp, "\t             echo \"\\tleaving .c files\"; \\\n");
         fprintf(outfp, "\t         fi; \\\n");
         fprintf(outfp, "\t     else \\\n");
         fprintf(outfp, "\t         echo \"\\tnothing to compile\"; \\\n");
         fprintf(outfp, "\t     fi; \\\n");
         fprintf(outfp, "\t     if [ -n \"$(VERBOSE_RULES)\" ]; \\\n");
         fprintf(outfp, "\t     then \\\n");
         fprintf(outfp, "\t         echo \"\\trm -f opp.list cc.list\"; \\\n");
         fprintf(outfp, "\t     fi; \\\n");
         fprintf(outfp, "\t     rm -f opp.list cc.list; \\\n");
         fprintf(outfp, "\t fi\n\n");

	{
		/*
		*	Write global fast target for all source groups.
		*/

		struct source_group_node   *s;

		if (!srcfiles)
			return;

		fprintf(outfp, "FAST:\n\t$(MAKE) FAST=1");
		s = srcfiles;
		while (s)
		{
			fprintf(outfp, " %s_FAST", s->sgrp_name);
			s = s->next;
		}
	}
#endif
	fprintf(outfp, "\n\n");
}

/*****************************************************************

    read_infile

	This function reads the input file and puts all the
	information in the appropriate linked lists.

*****************************************************************/

void read_infile (infile)
FILE *infile;
{
   char  _inline_[MAXLINESIZE];
   int   stat = 1;
   register struct keyword_node **mk;
   register struct dtree_node   **ci;
   register struct dtree_node   *p;
   struct source_group_node     *src_group;
   int convert_filename = 0;
   int is_executable_name = 0;

   srcfiles = 0;
   depfiles = 0;
   oppath = 0;
   omcppath = 0;
   ccpath = 0;
   echopath = 0;
   homepath = 0;
   cflags = 0;
   execflags = 0;
   version = 0;
   depsversion = 0;
   sufixpath = 0;
   rulespath = 0;
   ci = 0;
   srcpath = new_dtree_node(".");
   postpath = 0;
   linkflags = 0;

   new_keyword = 1;
   mk = &makelist;

   stat = fread_infile (_inline_, infile);
   while (1)
   {
      if (stat == 0) break;

      if      (!strcmp ("INCLUDE", _inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 1;
         new_keyword = 1;
         convert_filename = 1;
         is_executable_name = 0;
         ci = &incfiles;
      }
      else if (!strcmp ("SPEC", _inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 2;
         new_keyword = 1;
         convert_filename = 1;
         is_executable_name = 0;
         ci = &spcfiles;
      }
      else if (!strncmp ("SOURCE", _inline_, 6))
      {
         src_group = get_src_group(_inline_+6, "SOURCE");
         src_group->spec_list = 0;
         src_group->imp_list = 0;
         src_group->c_list = 0;
         src_group->C_list = 0;
         src_group->next = 0;
         ci = &src_group->c_list;
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 3;
         (*mk)->linked_list = (struct dtree_node *)ci; /* BUG !!! */
         mk = &((*mk)->next);
         new_keyword = 0;
         convert_filename = 0;
         is_executable_name = 0;
      }
      else if (!strcmp ("VERSION", _inline_))
      {
         fprintf(stderr, "mkmk: warning: VERSION keyword no longer supported\n");
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 4;
         new_keyword = 1;
         ci = &version;
         convert_filename = 0;
         is_executable_name = 0;
      }
      else if (!strcmp ("DEPENDENCIES", _inline_))
      {
         fprintf(stderr, "mkmk: warning: DEPENDENCIES keyword no longer supported\n");
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 5;
         new_keyword = 1;
         ci = &depsversion;
         convert_filename = 0;
         is_executable_name = 0;
      }
      else if (!strncmp ("LINKLIB", _inline_, 7))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 6;
         new_keyword = 1;
         convert_filename = 1;
         is_executable_name = 0;

         ci = &(get_src_group(_inline_+7, "LINKLIB"))->linklib;
      }
      else if (!strcmp ("COPT", _inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 7;
         new_keyword = 1;
         ci = &cflags;
         convert_filename = 0;
         is_executable_name = 0;
      }
      else if (!strcmp ("OPPFLAGS", _inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 8;
         new_keyword = 1;
         ci = &oppflags;
         convert_filename = 0;
         is_executable_name = 0;
      }
      else if (!strncmp ("LIB", _inline_, 3))
      {
#if defined(UNIX)
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 9;
         new_keyword = 1;
         convert_filename = 1;
         is_executable_name = 0;

         ci = &(get_src_group(_inline_+3, "LIB"))->libname;
#elif defined(NT)
         fprintf(stderr, "LIB is not supported on NT\n");
         exit(++Errors);
#else
#error Unknown OS
#endif
      }
      else if (!strcmp ("OPP", _inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 10;
         new_keyword = 1;
         convert_filename = 1;
         is_executable_name = 0;
         ci = &oppath;
      }
      else if (!strcmp ("OMCPP", _inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 11;
         new_keyword = 1;
         convert_filename = 1;
         is_executable_name = 0;
         ci = &omcppath;
      }
      else if (!strcmp ("CC", _inline_))
      {
         int  c;
         while(isspace(c = fgetc(infile))) {}
         ungetc(c, infile);
         read_line(&ccpath, infile);
         stat = fread_infile (_inline_, infile);
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 12;
         (*mk)->linked_list = ccpath;
         mk = &((*mk)->next);
         new_keyword = 0;
         convert_filename = 0;
         is_executable_name = 0;
         continue;
      }
      else if (!strcmp ("HOME", _inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 13;
         new_keyword = 1;
         convert_filename = 1;
         is_executable_name = 0;
         ci = &homepath;
      }
      else if (!strcmp ("SRC", _inline_))
      {
         src_specified = 1;
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 14;
         new_keyword = 1;
         convert_filename = 1;
         is_executable_name = 0;
         ci = &srcpath;
      }
      else if (!strcmp ("EXECOPT", _inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 27;
         new_keyword = 1;
         convert_filename = 0;
         is_executable_name = 0;
         ci = &execflags;
      }
      else if (!strncmp ("EXEC", _inline_, 4))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 15;
         new_keyword = 1;
         convert_filename = 1;
         is_executable_name = 1;

         ci = &(get_src_group(_inline_+4, "EXEC"))->execname;
      }
      else if (!strncmp ("ARCHIVE", _inline_, 7))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 16;
         new_keyword = 1;
         convert_filename = 1;
         is_executable_name = 0;

         ci = &(get_src_group(_inline_+7, "ARCHIVE"))->archive;
         has_archive = 1;
      }
      else if (!strcmp ("NOSUFFIXES", _inline_))
      {
         nosuffixes = 1;
         new_keyword = 0;
         convert_filename = 0;
         is_executable_name = 0;
      }
      else if (!strcmp ("SUFFIXES", _inline_))
      {
         int   c;
         while(isspace(c = fgetc(infile))) {}
         ungetc(c, infile);
         read_line(&sufixpath, infile);
         stat = fread_infile (_inline_, infile);
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 17;
         (*mk)->linked_list = sufixpath;
         mk = &((*mk)->next);
         new_keyword = 0;
         convert_filename = 0;
         is_executable_name = 0;
         continue;
      }
      else if (!strcmp ("NORULES", _inline_))
      {
         norules = 1;
         new_keyword = 0;
         convert_filename = 0;
         is_executable_name = 0;
      }
      else if (!strcmp ("RULES", _inline_))
      {
         int   c;
         while(isspace(c = fgetc(infile))) {}
         ungetc(c, infile);
         read_special(&rulespath, infile, "END_RULES");
         stat = fread_infile (_inline_, infile);
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 18;
         (*mk)->linked_list = rulespath;
         mk = &((*mk)->next);
         new_keyword = 0;
         convert_filename = 0;
         is_executable_name = 0;
         continue;
      }
      else if (!strcmp ("SPECIAL",      _inline_))
      {
         int   c;
         while(isspace(c = fgetc(infile))) {}
         ungetc(c, infile);
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         read_special(&((*mk)->linked_list), infile, "END_SPECIAL");
         (*mk)->keycode = 19;
         mk = &((*mk)->next);
         new_keyword = 0;
         stat = fread_infile (_inline_, infile);
         convert_filename = 0;
         is_executable_name = 0;
         continue;
      }
      else if (!strcmp ("DOPT", _inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 20;
         new_keyword = 1;
         convert_filename = 0;
         is_executable_name = 0;
         ci = &doptpath;
      }
      else if (!strcmp ("POST_SPECIAL",_inline_))
      {
         int   c;
         while(isspace(c = fgetc(infile))) {}
         ungetc(c, infile);
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         if (*(ci = &postpath))
            while ((*ci)->next)
               ci = &((*ci)->next);
         if (*ci)
	    read_special(&((*ci)->next), infile, "END_SPECIAL");
         else
	    read_special(ci, infile, "END_SPECIAL");
         ci = 0;
         (*mk)->keycode = 21;
         mk = &((*mk)->next);
         new_keyword = 0;
         stat = fread_infile (_inline_, infile);
         convert_filename = 0;
         is_executable_name = 0;
         continue;
      }
      else if (!strcmp ("TARGET",_inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 22;
         new_keyword = 1;
         convert_filename = 1;
         is_executable_name = 0;

         ci = &target;
      }
      else if (!strncmp ("DEPLIB", _inline_, 6))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 23;
         new_keyword = 1;
         convert_filename = 1;
         is_executable_name = 0;
         ci = &(get_src_group(_inline_+6, "DEPLIB"))->deplib;
      }
      else if (!strcmp ("CCFILTER", _inline_))
      {
         int  c;
         while(isspace(c = fgetc(infile))) {}
         ungetc(c, infile);
         read_line(&ccfilter, infile);
         stat = fread_infile (_inline_, infile);
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 24;
         (*mk)->linked_list = ccfilter;
         mk = &((*mk)->next);
         new_keyword = 0;
         convert_filename = 0;
         is_executable_name = 0;
         continue;
      }
      else if (!strcmp("DEFINE", _inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 25;
         new_keyword = 1;
         convert_filename = 0;
         is_executable_name = 0;
         ci = &define;
      }
      else if (!strcmp ("ASOPT", _inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 26;
         new_keyword = 1;
         convert_filename = 0;
         is_executable_name = 0;
         ci = &asflags;
      }
      else if (!strcmp ("VERBOSE_RULES", _inline_))
      {
         verbose_rules = 1;
         new_keyword = 0;
         convert_filename = 0;
         is_executable_name = 0;
      }
      else if (!strcmp ("ECHO", _inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 29;
         new_keyword = 1;
         convert_filename = 1;
         is_executable_name = 0;
         ci = &echopath;
      }
      else if (!strcmp ("LINKOPT", _inline_))
      {
         *mk = (struct keyword_node *) calloc(1, KEYWORDSIZE);
         (*mk)->keycode = 30;
         new_keyword = 1;
         convert_filename = 0;
         is_executable_name = 0;
         ci = &linkflags;
      }
      else if (ci)
      {
         /* Insert atom in appropriate linked list */

         if (*ci)
            while ((*ci)->next)
               ci = &((*ci)->next);
         if (convert_filename)
         	convert_to_native_filename(_inline_, is_executable_name);
         p = new_dtree_node (_inline_);
         if (*ci)
            (*ci)->next = p;
         else
            *ci = p;
         ci = &((*ci)->next);
         if (new_keyword)
         {
            (*mk)->linked_list = p;
            mk = &((*mk)->next);
            new_keyword = 0;
         }
      }
      else
      {
         fprintf (stderr,"premature atom <%s>\n",_inline_);
         fprintf (stderr,"have not found INCLUDE, SOURCE,");
         fprintf (stderr,"SPEC, LIB, or VERSION atom yet\n");
      }
      stat = fread_infile (_inline_, infile);
   }

   if ( *(ci=(&spcfiles) ) )
        while ((*ci)->next)
               ci = &((*ci)->next);
   p = new_dtree_node ( "." );
   if (*ci)
      (*ci)->next = p;
   else
       *ci = p;

#if defined(UNIX)
#if defined(SUNOS4)
#if defined(__STDC__)
   p = new_dtree_node ( "/usr/sunc/lang/SC1.0/ansi_include" );
   if ( *(ci=(&incfiles) ) )
        while ((*ci)->next)
               ci = &((*ci)->next);
   if (*ci)
      (*ci)->next = p;
   else
       *ci = p;
#endif
   p = new_dtree_node ( "/usr/5include" );
   if ( *(ci=(&incfiles) ) )
        while ((*ci)->next)
               ci = &((*ci)->next);
   if (*ci)
      (*ci)->next = p;
   else
       *ci = p;
#endif

   p = new_dtree_node ( "/usr/include" );
   if ( *(ci=(&incfiles) ) )
        while ((*ci)->next)
               ci = &((*ci)->next);
   if (*ci)
      (*ci)->next = p;
   else
       *ci = p;
#elif defined(NT)
	{
		char	*dir = 0;

		while (dir = getNextEnvIncludeDir())
		{
			p = new_dtree_node ( dir );
			if ( *(ci=(&incfiles) ) )
				while ((*ci)->next)
					ci = &((*ci)->next);
			if (*ci)
				(*ci)->next = p;
			else
				*ci = p;
       		}
       	}
#else
#error Unknown OS
#endif

}
