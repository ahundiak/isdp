#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

extern char *sys_errlist[];

#define LINELENG	128
#define TABSIZE		8192

#define DELIMITER	'#'
#define EOL		'\n'

#define ADD		1
#define DELETE		2
#define SEARCH		3

#ifdef SVR4 
#  ifdef NEWDIRS
#    ifdef sgi
#    define BASEDIR		"/var/opt/ingr"
#    define DELTOOLS_DIR	"deltools"
#    else
#    define BASEDIR		"/opt/ingr"
#    define DELTOOLS_DIR	"deltools"
#    endif
#  else
#    define BASEDIR		"/usr/ip32"
#    define DELTOOLS_DIR	"deltools"
#  endif
#endif

/* HP added in the list -- MVR 2 May 1994 */
#if defined(SVR3) || defined(SunOS_4) || defined(_AIX) || defined(HP_UX)
#define BASEDIR		"/usr/ip32"
#define DELTOOLS_DIR	"deltools"
#endif

/*
 * FUNCTION:		usage()
 * PARAMETERS:		progname	name of invoking program
 *
 * RETURN VALUE:	none
 *
 * SIDE EFFECTS:	none
 *
 * PURPOSE:		User gave invalid command line syntax
 *			Tell them the valid syntax
 */
void
usage(char *progname)
{
    fprintf(stderr, "Usage: %s [ -a  |  -d ] [ prodname {prodrelease} ]\n", progname);
    fprintf(stderr, "\t-a\t\tAdd new entries to catalog from CD-ROM table\n");
    fprintf(stderr, "\t-d\t\tDelete entries in CD-ROM table from catalog\n");
    fprintf(stderr, "\tprodname\tName of product to find in catalog\n");
    fprintf(stderr, "\tprodrelease\tRelease of product to find in catalog\n");
}

/*
 * FUNCTION:		cmp()
 *
 * PARAMETERS:		s1	Pointer to one catalog file entry (string)
 * 			s2	Pointer to another catalog file entry (string)
 *
 * RETURN VALUE:	0	entries are lexically equal
 *			< 0	s1 is lexically less than s2
 *			> 0	s1 is lexically greater than s2
 *
 * SIDE EFFECTS:	None -- no globals referenced
 *		      
 * PURPOSE:		Called by lsearch() from main() below.  Puts
 *			catalog file entries in sorted order by
 *			product name, then product number.
 */
int
cmp(const void *s1, const void *s2)
{
    char *p1 = (char *)s1, *p2 = (char *)s2;

    int diff = 0;

    for (; *p1 != DELIMITER && *p1 && *p2 && *p1 == *p2; p1++, p2++) ;
    diff = *p1 - *p2;

    if (diff)
	return(diff);
    else {
	for (; *p1 == DELIMITER && *p1; p1++) ;
	for (; *p2 == DELIMITER && *p2; p2++) ;

	for (; *p1 != DELIMITER && *p1 && *p2 && *p1 == *p2; p1++, p2++) ;

	return(*p1 - *p2);
    }
}


/*
 * FUNCTION:		get_field
 *
 * PARAMETERS:		c		string to scan for field
 *			dstr		destination string for field data
 *			maxchars	maximum field width
 *			ucase		Convert field data to uppercase?
 *						(boolean)
 *
 * RETURN VALUE:	pointer to new current position in scanned string
 *
 * SIDE EFFECTS:	none -- no globals used
 *
 * PURPOSE:		Extract data in a string that is delimited by
 *			predefined character DELIMITER.  Stop when
 *			DELIMITER is reached, or maximum field width
 *			is hit.  Transferred data can be converted to
 *			uppercase, if desired.
 */
char    *get_field(c, dstr, maxchars, ucase)
register char   *c, *dstr;
int     maxchars, ucase;
{
        register int    i = 0;
        register char   *d; /*used to convert dstr to upper case*/

        d = dstr;
        while (*c && (*c != DELIMITER) && (*c != EOL) && (i < maxchars - 1)){
                *dstr++ = *c++;
                ++i;
        }

        /* null terminate the result */
        if (i < maxchars)
                *dstr = '\0';

        if (ucase)
                for (; *d != '\0'; ++d)
                        *d = (char)toupper(*d);

        if (i == maxchars - 1)  /*skip characters until DELIMITER hit*/
                for(; *c && *c != DELIMITER && *c != EOL; ++c)
                        ;

        if (*c && *c == DELIMITER)
                ++c;    /*move c past DELIMITER character*/

        return(c);
}

int
main(int argc, char *argv[])
{
     FILE	*fp1, *fp2;

     unsigned	nel = 0;
     int		operation = 0, i = 0;

     short	found = 0;

     char	tab[TABSIZE][LINELENG];
     char	longline[256];
     char	line[LINELENG];
     char	title[256];
     char	rel_date[128];
     char	vol_label[64];
     char	fmda_number[32];

     char	prodname[16];
     char	prodnum[16];
     char	prodrel[16];
     char	dummy[64];

     char	*c, *targname, *targrel;
     char	*catalog_file = "/usr/ip32/deltools/cd_catalog";
     char	*ingrhome = BASEDIR;

     targname = "";
     targrel = "";

#if defined(SVR4) && defined(NEWDIRS)     
     if ((c = getenv("INGRHOME")) && *c) {
	ingrhome = c;
	if (c = strchr(ingrhome, ':'))
	    *c = '\0';
     }
#endif

     if ((c = getenv("CD_CATALOG_FILE")) && *c)
	catalog_file = c;
     else {
	catalog_file = malloc(strlen(ingrhome) + strlen(DELTOOLS_DIR) + 16);
	sprintf(catalog_file, "%s/%s/cd_catalog", ingrhome, DELTOOLS_DIR);
     }


     if (argc < 2 ) {
	 if ((fp1 = fopen(catalog_file, "r")) == NULL) {
	     if (errno == ENOENT) {
		 if ((i = creat(catalog_file, 0644)) < 0) {
		     fprintf(stderr, "Couldn't create catalog file: %s\n", sys_errlist[errno]);
		     exit(1);
		 }
		 close(i);
		 fp1 = fopen(catalog_file, "r");
	     }
	     else {
		 fprintf (stderr, "Couldn't open catalog file: %s\n", sys_errlist[errno]);
		 exit(1);
	     }
	 }
	 printf("%-12s %-9s %11s %-20s %s %s\n",
		"    Name    ", " Number ", "  Version  ", "      CD Title      ", "CD Release ", "  Part #");

	 while (fgets(longline, 256, fp1)) {
	     c = longline;

	     c = get_field(c, prodname, sizeof(prodname), 1);
	     c = get_field(c, prodnum, sizeof(prodnum), 1);
	     c = get_field(c, prodrel, sizeof(prodrel), 0);
	     c = get_field(c, title, sizeof(title), 0);
	     c = get_field(c, rel_date, sizeof(rel_date), 1);
	     c = get_field(c, fmda_number, sizeof(fmda_number), 1);

	     printf("%-12s %-9s %11s %-20s %s %s\n", 
		     prodname, prodnum, prodrel, title, rel_date, fmda_number);
	 }
	 fclose(fp1);
     }
     else {
	 if (argv[1][0] == '-') {
	     switch (argv[1][1]) {
	     case 'a':
		 operation = ADD;
		 break;
	     case 'd':
		 operation = DELETE;
		 break;
	     default:
		 usage(argv[0]);
		 exit(1);
	     }
	 }
	 else {
	     operation = SEARCH;
	     targname = argv[1];
	     if (argc == 3)
		 targrel = argv[2];
	 }

	 /*
	  * Open catalog file and scan in existing contents.
	  *
	  */
	 if ((fp1 = fopen(catalog_file, "r")) == NULL) {
	     if (errno == ENOENT) {
		 if ((i = creat(catalog_file, 0644)) < 0) {
		     fprintf(stderr, "Couldn't create catalog file: %s\n", sys_errlist[errno]);
		     exit(1);
		 }
		 close(i);

		 fp1 = fopen(catalog_file, "r");
	     }
	     else {
		 fprintf (stderr, "Couldn't open catalog file: %s\n", sys_errlist[errno]);
		 exit(1);
	     }
	 }

	 while (fgets(line, LINELENG, fp1) && nel < TABSIZE)
	    lsearch(line, tab, &nel, LINELENG, strcmp);

	fclose(fp1);

	if (operation == ADD || operation == DELETE) {
/* Let's look for uppercase filename on CD's for HP. -- MVR 30 May 1994*/
#ifdef HP_UX
	    if ((fp1 = fopen("/del/VOLUME", "r")) != NULL) {
#else
	    if ((fp1 = fopen("/del/volume", "r")) != NULL) {
#endif
		fgets(line, 256, fp1);
		fclose(fp1);
		if (line[strlen(line)-1] == '\n')
		    line[strlen(line)-1] = '\0';
		c = strtok(line, "#");
		strcpy(title, c);
		c = strtok(NULL, "#");
		strcpy(rel_date, c);
		c = strtok(NULL, "#");
		strcpy(vol_label, c);
		c = strtok(NULL, "#");
		strcpy(fmda_number, c);
	    }
	    else {
		printf("Enter the title of the CD-ROM you have mounted on /del:  ");
		gets(title);
		printf("Enter the release date of the CD-ROM (format dd-MMM-yyyy):  ");
		gets(rel_date);

		if (title[0] == '\0' || rel_date[0] == '\0') {
		    printf("Exiting.\n");
		    exit(1);
		}
		else {
		    printf("Enter the CD-ROM part number\n   (optional; found on CD label above \"Intergraph\" logo):  ");
		    gets(fmda_number);
		}
	    }

	/* look for uppercase filenames on CD's for HP -- MVR 30 May 1994 */
#ifdef HP_UX
	    if ((fp2 = fopen("/del/WS_S.PRODS", "r")) == NULL) {
#else
	    if ((fp2 = fopen("/del/ws_s.prods", "r")) == NULL) {
#endif
		fprintf (stderr, "Could not open product list file: %s\n", sys_errlist[errno]);
		exit(1);
	    }

	    while (fgets(longline, 256, fp2)) {
		c = longline;
		
		c = get_field(c, prodnum, sizeof(prodnum), 1);
		c = get_field(c, dummy, sizeof(dummy), 0);
		c = get_field(c, dummy, sizeof(dummy), 0);
		c = get_field(c, dummy, sizeof(dummy), 0);
		c = get_field(c, dummy, sizeof(dummy), 0);
		c = get_field(c, dummy, sizeof(dummy), 0);
		c = get_field(c, dummy, sizeof(dummy), 0);
		c = get_field(c, dummy, sizeof(dummy), 0);
		c = get_field(c, prodname, sizeof(prodname), 1);
		c = get_field(c, prodrel, sizeof(prodrel), 0);
		
		sprintf(line, "%s#%s#%s#%s#%s#%s\n",
			prodname, prodnum, prodrel, title, rel_date, fmda_number);

		c = (char *)lsearch (line, (char *)tab, &nel, LINELENG, strcmp);
		
		if (operation == ADD)
		    sprintf(c, "%s#%s#%s#%s#%s#%s\n",
			    prodname, prodnum, prodrel, title, rel_date, fmda_number);
		else
		    *c = 0;
	    }
	    
	    
	    if ((fp1 = fopen(catalog_file, "w")) == NULL) {
		fprintf (stderr, "Couldn't open catalog file: %s\n", sys_errlist[errno]);
		exit(1);
	    }
	    else {
		for (i = 0; i < nel; i++) {
		    if (tab[i][0])
			fputs(tab[i], fp1);
		}
		fclose(fp1);
	    }
	}
	else {				/* operation == SEARCH */
	    for (c=targname; *c; c++)
		*c = toupper(*c);

	    found = 0;
	    for (i = 0; i < nel; i++) {
		if (strncmp(tab[i], targname, strlen(targname)) == 0) {
		   if (*targrel) {
		       c = strchr(tab[i], '#') + 1;
		       c = strchr(c, '#') + 1;
		       if (strncmp(c, targrel, strlen(targrel)) == 0) {
			   c = tab[i];
			   c = get_field(c, prodname, sizeof(prodname), 1);
			   c = get_field(c, prodnum, sizeof(prodnum), 1);
			   c = get_field(c, prodrel, sizeof(prodrel), 0);
			   c = get_field(c, title, sizeof(title), 0);
			   c = get_field(c, rel_date, sizeof(rel_date), 1);
			   c = get_field(c, fmda_number, sizeof(fmda_number), 1);

			   printf("%-12s %-9s %11s %-20s %s %s\n",
			       prodname, prodnum, prodrel, title, rel_date, fmda_number);
			   found++;
		       }
		   }
		   else {
		       c = tab[i];
		       c = get_field(c, prodname, sizeof(prodname), 1);
		       c = get_field(c, prodnum, sizeof(prodnum), 1);
		       c = get_field(c, prodrel, sizeof(prodrel), 0);
		       c = get_field(c, title, sizeof(title), 0);
		       c = get_field(c, rel_date, sizeof(rel_date), 1);
		       c = get_field(c, fmda_number, sizeof(fmda_number), 1);
		       printf("%-12s %-9s %11s %-20s %s %s\n",
			      prodname, prodnum, prodrel, title, rel_date, fmda_number);
		       found++;
		   }
	       }
	    }
	}
    }
    if (operation == SEARCH)
    {
	if (found)
		exit (0);
	else
		exit (1);
    }
}









