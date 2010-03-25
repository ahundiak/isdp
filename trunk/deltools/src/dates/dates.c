// From the INTEL_SOLARIS MakeFile
// -DSYSV -DSVR4 -DNEWDIRS -DL_ENDIAN
#define SYSV
#define SVR4
#define NEWDIRS
#define L_ENDIAN

#include <stdlib.h>
#include <signal.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <unistd.h>

#define SHOWALL		0
#define SHOWNOTES	1
#define SHOWDATA	2

/* HP added in the list -- MVR 2 May 94 */
#if defined(SVR3) || defined(_AIX) || defined(SunOS_4) || defined(HP_UX)
#  define	BASEDIR		"/usr/ip32"
#endif

#ifdef SVR4
#  ifdef NEWDIRS
#    ifdef sun
#      define	BASEDIR		"/opt/ingr"
#    endif
#    ifdef sgi
#      define	BASEDIR		"/var/opt/ingr"
#    endif
#  else
#    define	BASEDIR		"/usr/ip32"
#  endif
#endif

#define		CONFIG		"/ingrconfig"

#define LINELENG	256
#define TABSIZE		8192

#define	NUMBERLEN	16
#define	NAMELEN		12
#define	TITLELEN	40
#define	VERSIONLEN	12	/* nn.nn.nn.nn */
#define	DATELEN		12
#define	WSDIRLEN	256
#define	LOADTIMELEN	40
#define	MEDIALEN	40

struct product {
	char	number[NUMBERLEN];
	char	name[NAMELEN];
	char	title[TITLELEN];
	char	version[VERSIONLEN];
	char	date[DATELEN];
	char	wsdir[WSDIRLEN];
	char	loadtime[LOADTIMELEN];
	char	media[MEDIALEN];
};

char	*dashes = {"------------------------------------------------------------------------------\n"};
char	tab[TABSIZE][LINELENG];

/*
 * copy from s into d all the way up to a # character
 * return the next location of a valid string (after a #)
 */
char	*get_field(s, d, n)
char	*s, *d;
int	n;
{
	for (; n > 0 && *s != '#' && *s != '\n' && *s != '\0'; s++, d++, n--)
		*d = *s;
	*d = '\0';

	for (; *s != '#' && *s != '\n' && *s != '\0'; s++)
		;

	if (*s)
		return(++s);
	else
		return(s);
}

/*
 * compare two strings, disregarding case
 */
int	nocasecmp(s1, s2, n, exact)
char	*s1, *s2;
int	n;
int	exact;
{
	if (exact) {
	    while (*s1 && *s2 && (toupper(*s1) == toupper(*s2))) {
		s1++;
		s2++;
	    }
	    if ((*s1 == '\0') && (*s2 == '\0'))
	        return(0);
	    else
		return(toupper(*s1) - toupper(*s2));
	}
	else {
	    n++;
	    while (--n > 0 && toupper(*s1) == toupper(*s2++)) 
		if (*s1++ == '\0') 
			return(0);

	    return ((n == 0) ? 0 : (toupper(*s1) - toupper(*--s2)));
	}
}

/*
 * This routine compares two product entries based on the name, number,
 * and pathname. When products have the same name or number AND the same
 * path, then they are considered equal. Otherwise, it returns the difference
 * in product name (for alphabetizing.)
 * SS01191#ACC#C Compiler#05.00.01.24#13-SEP-1990#/usr/ingr/acc#01:02:04 12/23/91#CD/ROM
 */
int	cmp(s1, s2)
char	*s1, *s2;
{
	register int	i, numdiff;

	/*
	 * first get the number difference
	 */
	for (; *s1 != '#' && *s1 && *s2 && *s1 == *s2; s1++, s2++)
		;
	numdiff = *s1 - *s2;

	/*
	 * move up to the next field
	 */
	for (; *s1 != '#' && *s1; s1++)
		;
	for (; *s2 != '#' && *s2; s2++)
		;
	if (*s1) s1++;
	if (*s2) s2++;

	/*
	 * now get the name difference
	 */
	for (; *s1 != '#' && *s1 && *s2 && *s1 == *s2; s1++, s2++)
		;

	if ((*s1 - *s2) && numdiff)
		return (*s1 - *s2);

	/*
	 * Since the name or number is the same, then check the paths.
	 * Make sure we're up to the next field mark first.
	 */
	for (; *s1 != '#' && *s1; s1++)
		;
	for (; *s2 != '#' && *s2; s2++)
		;

	/*
	 * Now test the path, but first move up to the path field.
	 */
	for (i = 0; i < 3; i++) {
		for (s1++; *s1 != '#' && *s1; s1++)
			;
		for (s2++; *s2 != '#' && *s2; s2++)
			;
	}
	if (*s1) s1++;
	if (*s2) s2++;
	for (; *s1 != '#' && *s1 && *s2 && *s1 == *s2; s1++, s2++)
		;
	/*
	 * Return the path difference.
	 */
	return (*s1 - *s2);
}

int	main(argc, argv)
int	argc;
char	**argv;
{
	unsigned	nel = 0;
	int	i, j, k;
	int	startpoint = 0;
	int	names_on_line = 0;
	int	exact_match = 0;
	int	function = SHOWALL;
	char	*c, *str;
	char	*config = CONFIG;
	char	*ingrhome = BASEDIR;
	char	*template = NULL;
	char	fmt[LINELENG];
	char	rfile[LINELENG];
	char	command[LINELENG];
	char	line[LINELENG];
	char	rm_list[1024];
	struct product	p;
	FILE	*f;
	extern char	*getenv(), *lsearch();

	/*
	 * Figure out what we're supposed to do
	 */
	if ((str = (char *)strrchr(argv[0], '/')) != NULL)
		++str;
	else
		str = argv[0];

	if (!strcmp(str, "prodinfo")) {
		function = SHOWNOTES;
		rm_list[0] = '\0';
		if (argc < 2) {
			fprintf(stderr, "Usage: %s <product name> ....\n", argv[0]);
			exit(255);
		}
	} else if (!strcmp(str, "proddata")) {
		function = SHOWDATA;
		if (argc < 2) {
fprintf(stderr, "Usage: %s [+%%n%%#%%d%%v%%t%%p%%w%%m] [[-x] <product name>] ....\n", argv[0]);
			exit(255);
		}
	}

	if ((c = getenv("INGRCONFIG")))
	    config = c;

#if defined(SVR4) && defined(NEWDIRS)
	if ((c = getenv("INGRHOME")) && *c) {
	    ingrhome = c;
	    c = strchr(ingrhome, ':');
	    if (c)
		*c = '\0';
	}
#endif
	
	config = malloc(strlen(ingrhome) + strlen(CONFIG) + 1);
	strcpy(config, ingrhome);
	strcat(config, CONFIG);

	if ((c = getenv("TPLT")))
		template = c;

	if ((f = fopen(config, "r")) == NULL) {
		fprintf(stderr, "%s: Cannot open configuration file %s.\n",
			argv[0], config);
		exit(255);
	}

	/*
	 * read in table, add each new line to table, filter out
	 * duplicate entries
	 */
	while (fgets(line, LINELENG, f) != NULL && nel < TABSIZE)
	    lsearch(line, tab, &nel, LINELENG, (int(*)(void *, void *))cmp);

	fclose(f);

	/*
	 * now sort the table
	 */
	qsort(tab, nel, LINELENG, (int(*)(const void *, const void *))cmp);

	if (argc < 2) {
		printf("Name      Number            Date        Version     Title\n");
		printf(dashes);
	}

	/*
	 * step through the table and display the info
	 */
	for (i = 0; i <= nel; i++) {
		if (!tab[i][0])
			continue;
		str = tab[i];
		str = get_field(str, p.number, NUMBERLEN);
		for (c = p.number; *c != '\0'; *c = toupper(*c), c++)
			;
		str = get_field(str, p.name, NAMELEN);

		/*
		 * match any product names found on the command line
		 * (case insensitive)
		 */
		if (argc > 1) {
		    startpoint = 1;

		    if (strcmp(argv[1], "-x") == 0) {
			exact_match++;
			startpoint++;
		    }

		    if (argv[startpoint][0] == '+') {
			startpoint++;
			if (argc > startpoint)
			    names_on_line++;
		    }
		    else
			names_on_line++;

		    if (names_on_line) {
			k = 0;
			for (j = startpoint; j < argc; j++) {

			    /*
			     * If there's a -x before a name, set
			     * the exact match flag and go on.
			     */
			    if (strcmp(argv[j], "-x") == 0) {
				exact_match ++;
				continue;
			    }
			    if (!nocasecmp(argv[j], p.name, strlen(argv[j]), exact_match))
				k++;

			    /*
			     * Reset the exact match flag after each 
			     * successful match.
			     */
			    exact_match = 0;
			}
			if (!k)
			    continue;
		    }
		}

		str = get_field(str, p.title, TITLELEN);
		str = get_field(str, p.version, VERSIONLEN);
		if (!isdigit(p.version[0]))
			p.version[0] = '\0';
		str = get_field(str, p.date, DATELEN);
		if (strlen(p.date) == 10) { /* pre-pend a '0' to the date */
			line[0] = '0';
			line[1] = '\0';
			strcat(line, p.date);
			strcpy(p.date, line);
		}
		str = get_field(str, p.wsdir, WSDIRLEN);
		str = get_field(str, p.loadtime, LOADTIMELEN);
		str = get_field(str, p.media, MEDIALEN);

		/*
		 * if we're under a template directory, then pre-prend the template
		 * path.
		 */
		if (template) {
			sprintf(line, "%s%s", template, p.wsdir);
			strcpy(p.wsdir, line);
		}

		/*
		 * check for product directory
                 * 25 Mar 2010 - ah - Remove this check for now
		 */
		//if (access(p.wsdir, 0))
		//	tab[i][0] = '\0';

		if (!tab[i][0])
			continue;

		switch (function) {
		case SHOWALL:
			printf("%-9.9s %-15.15s %11.11s %-11.11s %-29.29s\n",
				p.name, p.number, p.date, p.version, p.title);
			break;
		case SHOWNOTES:
			sprintf(rfile, "%s/README", p.wsdir);
			if (access(rfile, 4))
				printf("%s: No README file found for %s in %s.\n", argv[0], p.name, p.wsdir);
			else {
				strcat(rm_list, rfile);
				strcat(rm_list, " ");
			}
			break;
		case SHOWDATA:
			if (argv[1][0] == '+') {
				fmt[0] = '\0';
				for (c = &argv[1][1]; *c != '\0'; c++) {
					if (*c == '%') {
						c++;
						switch (*c) {
						case 'n': /* name */
							strcat(fmt, p.name);
							break;
						case '#': /* number */
							strcat(fmt, p.number);
							break;
						case 't': /* title */
							strcat(fmt, p.title);
							break;
						case 'v': /* version */
							strcat(fmt, p.version);
							break;
						case 'd': /* date */
							strcat(fmt, p.date);
							break;
						case 'p': /* path */
							strcat(fmt, p.wsdir);
							break;
						case 'w': /* when product was loaded */
							strcat(fmt, p.loadtime);
							break;
						case 'm': /* media spec */
							strcat(fmt, p.media);
							break;
						default:
							line[0] = *c;
							strncat(fmt, line, 1);
							break;
						}
					} else {
						line[0] = *c;
						strncat(fmt, line, 1);
					}
				}
			} else
				sprintf(fmt, "%s %s %s %s %s", p.name,
					p.number, p.date, p.version, p.wsdir);
			printf(fmt);
			printf("\n");
			break;
		}
	}

	if (function == SHOWNOTES) {
	    if (rm_list[0]) {
#if defined(SVR4) && defined(NEWDIRS)
		sprintf(command, "%s/bin/rm_pg %s", ingrhome, rm_list);
#else
		sprintf(command, "rm_pg %s", rm_list);
#endif
		system(command);
	    }
	}
	if (argc < 2)
		printf(dashes);

	/*
	 * rewrite config file after clean up
	 */

	signal(SIGINT, SIG_IGN);
	signal(SIGQUIT, SIG_IGN);

	if ((f = fopen(config, "w")) != NULL) {
	for (i = 0; i <= nel; i++)
	    if (tab[i][0])
		fprintf(f, "%s", tab[i]);
	fclose(f);
	}
	
	signal(SIGINT, SIG_DFL);
	signal(SIGQUIT, SIG_DFL);

	exit(0);
}

