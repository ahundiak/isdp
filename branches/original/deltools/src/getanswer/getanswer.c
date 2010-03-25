#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/termio.h>
#include <sys/termios.h>
#include <sys/signal.h>
#include <string.h>
#ifdef SVR4
#include <libgen.h>
#endif

/* HP added in the list --  MVR 2 May 1994 */
#if defined (SVR3) || defined(_AIX) || defined(SunOS_4) || defined(HP_UX)
#  define	BASEDIR		"/usr/ip32"
#endif
#ifdef SVR4
#  ifdef NEWDIRS
#    ifdef sun
#      define BASEDIR		"/opt/ingr"
#    endif
#    ifdef sgi
#      define BASEDIR		"/var/opt/ingr"
#    endif
#  else
#    define BASEDIR		"/usr/ip32"
#  endif
#endif

#define	ANSWER_FILE	"/.defaults"

#define LINELENG	256
#define TABSIZE		8192
char	tab[TABSIZE][LINELENG];

#if !defined(_XOPEN_SOURCE) && !defined(_POSIX_SOURCE)
struct termio	termarg;
#else
struct termios	termarg;
#endif /* !defined(_XOPEN_SOURCE) && !defined(_POSIX_SOURCE) */

/*
 * This routine checks a user response for a valid answer. If it isn't valid
 * then it displays a message saying so and returns 0.
 */
int	valid(s, args)
char	*s, **args;
{
	int	st;
	int	n, max, min;
	char	*c, *r;
	struct stat	sb;
#ifdef SVR3
	extern char	*regex(), *regcmp();
#else
	extern char	*re_comp();
	extern int	re_exec();
#endif

	/*
	 * first find out what kind of validation to do, if any. The validation
	 * criteria is located in args[0].
	 */
	if (args[0]) {
	if (!strcmp(args[0], "yesno")) {
		switch (tolower(*s)) {
		case 'y':
		case 'n':
			*s = tolower(*s);
			*(s+1) = '\0';
			return(1);
		default:
			fprintf(stderr, "Please answer \"Yes\" or \"No\". Try Again.\n\n");
			return(0);
		}
	} else if (!strcmp(args[0], "number")) {
		c = s; 
		while (*c != '\0') {
			if (*c == '-' || *c == '+' || *c == '.' ||
				(*c >= '0' && *c <= '9')) {
				c++;
				continue;
			}
			fprintf(stderr, "Please enter a numeric value. Try Again.\n\n");
			return(0);
		}
		return(1);
	} else if (!strcmp(args[0], "range")) {
		n = atoi(s); 
		min = atoi(args[1]);
		max = atoi(args[2]);
		if (n <= min || n >= max) {
			fprintf(stderr, "Please enter a number between %d and %d.\n\n",
				min, max);
			return(0);
		}
		return(1);
	} else if (!strcmp(args[0], "choices")) {
		n = atoi(args[1]);
		for (st = 0; st < n; ++st)
			if (!strcmp(s, args[st + 2]))
				return(1);
		fprintf(stderr, "Please choose one of the following:\n");
		for (st = 0; st < n; ++st)
			fprintf(stderr, "%s ", args[st + 2]);
		fprintf(stderr, "\n\n");
		return(0);
	} else if (!strcmp(args[0], "pattern")) {
/* we need to compile this file with -DSYSV for HP -- MVR 2 May 1994 */
#ifdef SYSV
		r = regcmp(args[1], (char *)0);
		if (r) {
			r = regex(r, s);
			if (r && (*r == '\0'))
				return(1);
			fprintf(stderr, "Invalid answer. Try Again.\n\n");
			return(0);
		}
#else
		r = re_comp(args[1]);
		if (!r) {
			if (re_exec(s) == 1)
				return(1);

			fprintf(stderr, "Invalid answer. Try Again.\n\n");
			return(0);
		}
#endif
		return(1);	/* bad pattern, so assume user's answer is ok */
	} else if (!strcmp(args[0], "existingdir")) {
		st = stat(s, &sb);
		if (!st && (sb.st_mode & S_IFDIR))
			return(1);
		fprintf(stderr, "Directory \"%s\" does not exist. Try Again.\n\n", s);
		return(0);
	} else if (!strcmp(args[0], "existingfile")) {
		st = stat(s, &sb);
		if (!st && (sb.st_mode & S_IFREG))
			return(1);
		fprintf(stderr, "File \"%s\" does not exist. Try Again.\n\n", s);
		return(0);
	} else if (!strcmp(args[0], "newpath")) {
		if (!access(s, 0)) {
			fprintf(stderr, "Path \"%s\" already exists. Try Again.\n\n", s);
			return(0);
		}
		return(1);
	}
	}
	return(1);
}

#define ADVANCE(x)	while (isspace(*++(x)));

/*
 * This routine compares two lines based on the product name and prompt.
 * It returns a value like strcmp() does.
 */
int	linecmp(s1, s2)
char	*s1, *s2;
{
	for (; *s1 != '#' && *s1 != '\0' && *s1 == *s2; s1++, s2++) 
			;
	if (*s1 != *s2)
		return(*s1 - *s2);

	s1++;
	s2++;

	while (*s1 != '#' && *s1 != '\0' && tolower(*s1) == tolower(*s2)) {
	    ADVANCE(s1);
	    ADVANCE(s2);
	}

	return(tolower(*s1) - (*s2));
}

void parse(src, dest)
char *src;
char *dest;
{
    int value = 0, loops;

    for (; *src; src++) {
	if (*src != '\\')
	    *dest++ = *src;
	else {
	    src++;
	    switch (*src) {
	    case '0':			/* Octal character code */
		loops = 0;
		value = 0;
		while (loops < 3 && isdigit(*src)) {
		    value = (8 * value) + (*src - '0');
		    src++;
		    loops++;
		}
		src--;
		*dest++ = (char)value;
		break;
	    case 'n':			/* Newline */
		*dest++ = '\n';
		break;
	    case 'r':			/* Carriage return */
		*dest++	= '\r';
		break;
	    case 't':			/* Horzontal tab */
		*dest++ = '\t';
		break;
	    case 'b':			/* Backspace */
		*dest++ = '\b';
		break;
	    default:			/* Escaped special character */
		*dest++ = *src;
		break;
	    }
	}
    }
    *dest = '\0';
}



/*ARGSUSED*/
void cleanup(dummy)
int dummy;
{
    termarg.c_lflag |= ECHO;
#if !defined(_XOPEN_SOURCE) && !defined(_POSIX_SOURCE)
    ioctl(0, TCSETA, &termarg);
#else
    tcsetattr(0, TCSANOW, &termarg);
#endif /* !defined(_XOPEN_SOURCE) && !defined(_POSIX_SOURCE) */
    fputc('\n', stderr);
    exit(1);
}



/*
 * argv[optind] = prompt, argv[optind + 1] = default, $PRODNAME, $DEFAULTS
 */

int	main(argc, argv)
int	argc;
char	**argv;
{
	unsigned	nel = 0;
	int	i;
	int	errflg = 0;
	int	nosave = 0;
	int	noecho = 0;
	int	prevonly = 0;
	char	line[LINELENG];
	char	search_str[LINELENG];
	char	*envname;
	char	*envdef;
	char	*answer, *defanswer;
	char	*str;
	char	*found;
	char	*context = NULL;
	char	*help = NULL;
	char	*file = { ANSWER_FILE };
	char	*ingrhome = BASEDIR;
	char 	*c;
	FILE	*ansf;
	extern char	*optarg;
	extern char	*strrchr();
	extern char	*getenv();
	extern char	*lsearch();
	extern int	optind, getopt(); /*"getopt" variables*/
	char contextstr[1024], helpstr[1024];

#if !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE)
	ioctl(0, TCGETA, &termarg);
#else
	tcgetattr(0, &termarg);
#endif

	while ((i = getopt(argc, argv, "seqc:h:")) != EOF) {
		switch (i) {
		case 's':
			++nosave;
			break;
		case 'e':
			++noecho;
			break;
		case 'c':
			context = optarg;
			break;
		case 'h':
			help = optarg;
			break;
		case 'q':
			++prevonly;
			break;
		default:
			++errflg;
			break;
		}
	}


	/*
	 * At this point, argv[optind] points to the prompt and argv[optind + 1]
	 * points to the default answer.
	 */

	if (argc < 3 || errflg) {
		fprintf(stderr, "Usage: %s [-s] [-e] [-c context] \"prompt\" \"default answer\" [validation]\n", argv[0]);
		fprintf(stderr, "Where [validation] can be one of the following:\n");
		fprintf(stderr, "yesno\n");
		fprintf(stderr, "number\n");
		fprintf(stderr, "existingfile\n");
		fprintf(stderr, "existingdir\n");
		fprintf(stderr, "newpath\n");
		fprintf(stderr, "pattern {reg-exp}\n");
		fprintf(stderr, "range {min} {max}\n");
		fprintf(stderr, "choices {nchoices} {choice1} {choice2} ...\n");
		exit(1);
	}

	/*
	 * define the location for the default answers
	 */
	if ((str = getenv("ANSWERS")) != NULL)
	    file = str;
	else {
#if defined(SVR4) && defined(NEWDIRS)
	    if ((c = getenv("INGRHOME")) && *c) {
		ingrhome = c;
		c = strchr(ingrhome, ':');
		if (c)
		    *c = '\0';
	    }
#endif
	    file = malloc(strlen(ingrhome) + strlen(ANSWER_FILE) + 1);
	    strcpy(file, ingrhome);
	    strcat(file, ANSWER_FILE);
	}

	if ((envname = getenv("PRODNAME")) == NULL) {
		fprintf(stderr, "%s: Error, no product name defined in environment.\n", argv[0]);
		printf("%s\n", argv[optind + 1]);
		exit(2);
	}

	sprintf(search_str, "%s#%s#", envname, argv[optind]);
	answer = argv[optind + 1];
	found = NULL;

	/*
	 * open the answer file and search it for the product name and
	 * prompt
	 */
	if ((ansf = fopen(file, "r")) != NULL) {
		/*
	 	 * Read in table, add each new line to table, filter out
	 	 * duplicate entries for prodname and prompt.
		 * If a default answer is found, then set it.
	 	 */
		while (fgets(line, LINELENG, ansf) != NULL && nel < TABSIZE) {
			str = lsearch(line, tab, &nel, LINELENG, linecmp);
			if (linecmp(search_str, str) == 0)
				found = str;
		}
		fclose(ansf);
		if (found) {
			answer = (char *)(1 + strrchr(found, '#'));
			str = strrchr(answer, '\n');
			*str = '\0';
		}
	}

	if (prevonly) {
		printf("%s\n", found ? answer : "");
		exit(found ? 0 : 1);
	}

	if (help)
		parse(help, helpstr);

	signal(SIGTERM, cleanup);
	signal(SIGHUP, cleanup);
	signal(SIGINT, cleanup);

	if ((envdef = getenv("DEFAULTS")) == NULL || *envdef == 'n') {
		defanswer = answer;
		if (context) {
			parse(context, contextstr);
			fputs(contextstr, stderr);
			fputc('\n', stderr);
		}
		do {
prompt:		    fprintf(stderr, "%s [%s]: ", argv[optind],
				(noecho ? "secret" : defanswer));
		    if (noecho) {
			termarg.c_lflag &= ~ECHO;
#if !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE)
			ioctl(0, TCSETA, &termarg);
#else
			tcsetattr(0, TCSANOW, &termarg);
#endif /* !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE) */
		    }

		    fgets(line, LINELENG, stdin);

		    if (noecho) {
			termarg.c_lflag |= ECHO;
#if !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE)
			ioctl(0, TCSETA, &termarg);
#else
			tcsetattr(0, TCSANOW, &termarg);
#endif /* !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE) */

			fputc('\n', stderr);
		    }

		    if (line[0] == '\n')
			answer = defanswer;
		    else {
			answer = line;
			str = strrchr(answer, '\n');
			*str = '\0';
			if (line[0] == '?' && help) {
			    fputs(helpstr, stderr);
			    fputc('\n', stderr);
			    goto prompt;
			}
		    }
		} while (!valid(answer, &argv[optind + 2]));
	}

	if (found)
		found[0] = '\0';
	sprintf(tab[++nel], "%s%s\n", search_str, answer);

	/*
	 * rewrite CONFIG file after clean up
	 */
	if (!nosave && ((ansf = fopen(file, "w")) != NULL)) {
	    for (i = 0; i <= nel; i++)
		if (tab[i][0])
		    fprintf(ansf, "%s", tab[i]);
	    fclose(ansf);
	}

	printf("%s", answer);
}
