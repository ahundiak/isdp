#include	<stdlib.h>
#include	<stdio.h>
#include	<fcntl.h>
#include	<ctype.h>
#include	<string.h>
#include	<errno.h>
#include	<sys/types.h>
#include	<sys/stat.h>
#include	"defs.h"
#include	"dipdef.h"
#ifdef VPROD
#include	"main.h"
#endif

#define	DELIMITER	'#'	/*This is the field separator in PRODLIST*/
#define	DATE_LENGTH	11	/*length of the date field, (06-NOV-1985)*/
#define PRODDEF		"product.def"
#define ELSIZE		256


extern char	*strncpy();
extern char	*ingrhome;
extern char	basedir[STRSIZ];
extern char	sharedfs[STRSIZ];
extern char	makenodelist[STRSIZ];
extern char	*cpu_types[NUM_ARCH];
extern short	verbose;
extern short	srcmedia;
extern short	shared;
extern short	makenode;
extern unsigned long	my_arch;
extern unsigned short	cdtype;
extern struct prodnode classheader;
extern char	*configfile;

struct prodnode loadedheader;

int paidfor(x)
struct prodnode *x;
{
  if ((atoi(x->flags)==0) || (x->pstat & HAVEKEY))
      return(1);
  else
      return(0);
}

/*
 * This routine compares the product numbers of the two prodnodes. Its return
 * value is the same as strcmp().
 */
int	cmp(cmpa, cmpb, for_real)
struct prodnode *cmpa, *cmpb;
int	for_real;
{
    if (for_real && (srcmedia == CDROM || srcmedia == NETCDROM)) {
	if ((cmpa->pstat & ~HAVEKEY) == (cmpb->pstat & ~HAVEKEY)) {
	    /*
	     * Priorities are the same.
	     * So order by:
	     *   Free
	     *   Cost item w/ load key
	     *   Cost item w/o load key
	     *
	     */
	    
	    if (paidfor(cmpa) && paidfor(cmpb)) {
		/* Both free.  Which one has the higher name? */
		return(strcmp(cmpb->prodname, cmpa->prodname));
	    }
	    else {
		if (paidfor(cmpa))
		    return(1);
		else {
		    if (paidfor(cmpb))
			return(-1);
		    else
			return(strcmp(cmpb->prodname, cmpa->prodname));
		}
	    }
	}
	else
	    return((cmpb->pstat & ~HAVEKEY) - (cmpa->pstat & ~HAVEKEY));
    }
    else {
	if (cmpa->pstat == cmpb->pstat)
	    return(strcmp(cmpb->prodname, cmpa->prodname));
	else
	    return(cmpb->pstat - cmpa->pstat);
    }
}


void	ins_class(pptr, h)
struct prodnode	*pptr, *h;
{
    struct prodnode	*curr, *new;
    int	rval;
    
    /* search up to where we should insert */
    curr = h->flink;
    while (curr != h) {
	rval = strcmp(curr->prodclass, pptr->prodclass);
	if (rval == 0) {
	    curr->blocksize++;
	    pptr->clink = curr;
	    return;
	}
	if (rval > 0)
	    break;
	curr = curr->flink;
    }
    
    new = (struct prodnode *)malloc(sizeof(struct prodnode));
    strcpy(new->prodclass, pptr->prodclass);
    new->blocksize = 1;
    new->pstat = 0;
    new->clink = pptr;	/* clink of class node is first node in class */
    pptr->clink = new;	/* clink of prod node points to the class node*/
    
    /* put the new node in the list */
    curr = curr->blink;
    new->flink = curr->flink;
    new->blink = curr;
    curr->flink = new;
    new->flink->blink = new;
    h->blocksize++; /*number of nodes on list, (h node only)*/
}

/*
 * This routine inserts a prodnode structure into a doubly-linked
 * list of product nodes whose head is given in the header argument.
 */
void	ins_prod_node(pptr, header, for_real)
struct prodnode *pptr, *header;
int for_real;
{
    struct prodnode *curr;
    
    if (for_real && (srcmedia == CDROM || srcmedia == NETCDROM))
	get_key_status(pptr);
    
    for (curr = header; curr != header->blink && cmp(pptr, curr->flink, for_real) < 0;
	 curr = curr->flink)
	;	/* search up to where we should insert */

    pptr->flink = curr->flink;
    pptr->blink = curr;
    curr->flink = pptr;
    pptr->flink->blink = pptr;
    header->blocksize++; /*number of nodes on list, (header node only)*/
}

/*
 * This subroutine is used to fill in a character array with the next
 * field from the product list file. It will copy characters from
 * the address given by parameter "c" to the address given by
 * "dstr" until either EOL is detected or DELIMITER.
 * transferred is equal to the value in parameter "maxchars". The
 * parameter "ucase" is a boolean and if non-zero indicates that
 * the string in "dstr" should be converted to upper case. The
 * position of the character pointer in the input record after
 * copying is returned.
 */
char	*get_field(c, dstr, maxchars, ucase)
register char	*c, *dstr;
int	maxchars, ucase;
{
	register int	i = 0;
	register char	*d; /*used to convert dstr to upper case*/
	
	d = dstr;
	while (*c && (*c != DELIMITER) && (*c != EOL) && (i < maxchars - 1)){
	    *dstr++ = *c++;
	    ++i;
	}
	
	/* null terminate the result */
	if (i < maxchars)
		*dstr = (char)'\0';
	
	if (ucase)
		for (; *d != (char)'\0'; ++d)
		*d = (char)toupper(*d);
	
	if (i == maxchars - 1)	/*skip characters until DELIMITER hit*/
	    for(; *c && *c != DELIMITER && *c != EOL; ++c)
		;
	
	if (*c && *c == DELIMITER)
	    ++c;	/*move c past DELIMITER character*/
	
	return(c);
}

/*
 * This routine will read in one line from the product list file whose
 * file pointer is given in argument "fptr" and copy the fields from
 * the file into a product node structure whose address is given in
 * the parameter "prodptr". It will return an indication of whether
 * or not EOF has been detected. If an invalid product record is
 * encountered, then the "prodptr" value is set to NULL.
 */
char	get_prod_rec(lbuf, prodptr, header)
char	*lbuf;
struct prodnode **prodptr;
struct prodnode *header;
{
    char	str[64];	/*used for field manipulations*/
    register char	*c = '\0';/*pulls off one char at a time from buffer*/
    register char	*t;	/*pulls off one char at a time from buffer*/
    register struct prodnode *pptr;	/*used to fill in the prod structure*/
    register struct prodnode *sptr;	/*used to search for other nodes of the
					  same product*/
    int	i;
    
    if (pptr = (struct prodnode *)calloc(1, sizeof(struct prodnode))) {
	c = lbuf;

	pptr->prodindx[0] = '\0';
	cdtype = 0;
	pptr->arch = 0;

	if (*(c = get_field(c, pptr->prodnumber, PRODNUM_LEN, 1))==EOL)
	    goto error;
	
	if (*(c = get_field(c, pptr->prodtitle, TITLE_LEN, 0)) == EOL)
	    goto error;
	
	if (*(c = get_field(c, pptr->date, FIXDATE_LEN, 0)) == EOL)
	    goto error;
	
	if (*(c = get_field(c, str, 64, 0)) == EOL)
	    goto error;
	pptr->blocksize = atoi(str);
	
	if (*(c = get_field(c, pptr->flags, FLAGS_LEN, 0)) == EOL)
	    goto error;
	
	if (*(c = get_field(c, pptr->srcdir, DIR_LEN, 0)) == EOL)
	    goto error;
	
	/*
	 * if the source is a unix OS then check to make sure
	 * there is a / as final char in srcdir spec, if not, then
	 * append a /.
	 */
	if ((srcmedia == NETCDROM || srcmedia == TCPIP ||
	     srcmedia == LOCAL_DIR || srcmedia == CDROM ||
	     srcmedia == WORKSTATION) &&
	    pptr->srcdir[strlen(pptr->srcdir) - 1] != '/')
	    strcat(pptr->srcdir, "/");
	
	if (*(c = get_field(c, pptr->unixdir, DIR_LEN, 0)) == EOL)
	    goto error;
	
	c = get_field(c, str, 64, 0);
	pptr->load_priority = atoi(str);
	
	if (*c != EOL)
	    c = get_field(c, pptr->prodname, PRODNAME_LEN, 0);
	
	if (*c != EOL)
	    c = get_field(c, pptr->prodversion, VERSION_LEN, 0);
	
	if (*c != EOL)
	    c = get_field(c, pptr->prodclass, TITLE_LEN, 0);
	
		if (pptr->prodclass[0] == '\0')
	    strcpy(pptr->prodclass, "Other");
	
	pptr->attr = 0;
	if (pptr->blocksize < 0) {
	    pptr->attr |= ATTR_INVISIBLE;
	    pptr->blocksize = -pptr->blocksize;
	}
	if (*c != EOL)
	    c = get_field(c, str, 64, 0);
		t = (char *)strtok(str, " |:,;\t");
	while (t != NULL) {
	    switch(*t) {
	    case 'B':
	    case 'b':
		pptr->attr |= ATTR_BOM;
		break;
	    case 'I':
	    case 'i':
		pptr->attr |= ATTR_INVISIBLE;
		break;
	    case 'P':
	    case 'p':
		pptr->attr |= ATTR_PREPROCESS;
		break;
	    case 'S':
	    case 's':
		pptr->attr |= ATTR_SHARED;
		break;
	    }
	    t = (char *)strtok(NULL, " :,;\t");
	}
	
	if (shared && !(pptr->attr & ATTR_SHARED)) {
	    free(pptr);
	    pptr = NULL;
	    return(*c);
	}
	
	if (*c != EOL) {
	    /* NEW FOR 06.00
	     * The DELarch field indicates the target platforms
	     * of the product
	     */
	    c = get_field(c, str, 64, 0);
	    t = (char *)strtok(str, "|");
	    while (t != NULL) {
		for (i = 0; (i < NUM_ARCH) && (*cpu_types[i] != '\0'); i++) {
		    if (strcmp(t, cpu_types[i]) == 0)
			pptr->arch |= (1 << i);
		}
			t = (char *)strtok(NULL, "|,:;");
	    }
	    if (pptr->arch == 0)
		pptr->arch = CLIPPER_ARCH;
	}
	else
	    pptr->arch = CLIPPER_ARCH;

	if (!(pptr->arch & my_arch)) {
		free(pptr);
		pptr = NULL;
		return(*c);
	}

	if (*c != EOL) {
		c = get_field(c, pptr->prodindx, PRODINDX_LEN, 0);
		cdtype = 1;
	}
#ifdef MERGE_MENU
	if (makenode) {
	    /* Since there may be multiple lines in the 
	     * file that refer to the same product but different
	     * platform, look for a pre-existing entry in the list
	     * for this product with the same name, title and srcdir
	     * and if it exists, merge the info into it. Add the
	     * delsize in, and OR the arch into the preexisting
	     * value.
	     */
	    for (sptr = header->flink; sptr != header; sptr = sptr->flink) {
		if ((strcmp(sptr->prodname, pptr->prodname) == 0) &&
		    (strcmp(sptr->prodtitle, pptr->prodtitle) == 0) &&
		    (strcmp(sptr->srcdir, pptr->srcdir) == 0)) {
		    sptr->blocksize += pptr->blocksize;
		    sptr->arch |= pptr->arch;
		    free(pptr);
		    pptr = NULL;
		    return(*c);
		}
	    }
	}
#endif

	*prodptr = pptr;   /*return addr of alloc'd prodnode struct*/
	return(*c);
error:
	VPRINT1("Bad record format in product list file.");
	free(pptr);
	pptr = NULL;
    } else
	PRINT "\nError allocating memory for product structure.\n");
    return(*c);
}

/*
 * This routine will convert an ASCII string, (not necessarily
 * null-terminated), representing a month into an integer value in the
 * range of 1..12 and return this month value.
 */
int	get_month(month)
char	*month;
{
    register char	*charptr;
    
    charptr = month;
    switch (*charptr) {
    case 'J':
    case 'j':
	++charptr;
	switch (*charptr) {
	case 'a':
	case 'A':	/*January*/
	    return(1);
	case 'U':
	case 'u':
	    ++charptr;
	    if ((*charptr == 'L') || (*charptr == 'l'))
		return(7);		/*July*/
	    else
		return(6);		/*June*/
	}
	break;
    case 'A':
    case 'a':
	++charptr;
	if ((*charptr == 'p') || (*charptr == 'P'))
	    return(4);			/*April*/
	else
	    return(8);			/*August*/
    case 'D':
    case 'd':		/*December*/
	return(12);
    case 'F':
    case 'f':		/*February*/
	return(2);
    case 'M':
    case 'm':
	charptr += 2;		/*looking for May, March*/
	if ((*charptr == 'R') || (*charptr == 'r'))
	    return(3);			/*March*/
	else
	    return(5);			/*May*/
    case 'N':
    case 'n':		/*November*/
	return(11);
    case 'O':
    case 'o':		/*October*/
	return(10);
    case 'S':
    case 's':		/*September*/
	return(9);
    }
    return(1);		/* This is here to keep lint happy */
}

/*
 * This routine will compare two ASCII date strings, (not necessarily
 * null-terminated), of the form: DD-MMM-YYYY, where DD are [0-9],
 * MMM is JAN, FEB, ... , DEC; and YYYY is 19xx. The routine will return
 * 0, 1, or -1 in accordance to what the status of the of parameter wsdate is
 * in comparison to srcdate.
 */
int	compare_dates(wsdate, srcdate)
register char	*wsdate, *srcdate;
{
    register char	*wsptr, *srcptr;	/*parameter parsing pointers*/
    register int	i;
    char	daystr[8];			/*used to pull off day portion*/
    int	wsday, srcday;			/*convert ASCII day to int*/
    int	wsmonth, srcmonth;		/*convert ASCII month to 1..12*/
    
    if (strlen(wsdate) < 11 || strlen(srcdate) < 11)
	return(-1);
    wsptr = wsdate;
    srcptr = srcdate;
    i = 0;
    while ((*wsptr != '-') && (*wsptr != '\0') && (wsptr - wsdate < 8)) {
	daystr[i] = *wsptr++;
	++i;
    }
    if (*wsptr == '\0')
	return(-1);
	daystr[wsptr - wsdate] = '\0';
    wsday = atoi(daystr);
    i = 0;
    while ((*srcptr != '-') && (*srcptr != '\0') && (srcptr - srcdate < 8)){
	daystr[i] = *srcptr++;
	++i;
    }
    if (*srcptr == '\0')
	return(-1);
	daystr[srcptr - srcdate] = '\0';
    srcday = atoi(daystr);
    
    /*convert months to integers*/
    ++wsptr;
    ++srcptr;				/*skip '-' delimiter*/
    wsmonth = get_month(wsptr);
    for (; *wsptr != '-' && *wsptr != '\0'; ++wsptr) ;
    if (*wsptr == '\0')
	return(-1);
    srcmonth = get_month(srcptr);
    for (; *srcptr != '-' && *srcptr != '\0'; ++srcptr) ;
    if (*srcptr == '\0')
	return(-1);
    ++wsptr;
    ++srcptr;			/*step past delimiter*/
    for (i = 0; i < 4; ++i) {	/*check for different year*/
	if (*(wsptr + i) < *(srcptr + i))
	    return(-1);
	else if (*(wsptr + i) > *(srcptr + i))
	    return(1);
    }
    if (wsmonth < srcmonth)	/*check for different month*/
	return(-1);
    else if (wsmonth > srcmonth)
	return(1);
    if (wsday < srcday)		/*compare the day of the month*/
	return(-1);
    else if (wsday > srcday)
	return(1);
    else
	return(0);
}

/*
 * Compare two version numbers field-by-field.
 * Returns a negative value when the wsver is less than srcver, 0 when they're
 * equal and a positive value when wsver is greater than srcver.
 */
int	compare_versions(wsver, srcver)
char	*wsver, *srcver;
{
    int	wi, si;
    char	*wc, *sc;
    extern long	strtol();
    
    wc = wsver;
    sc = srcver;
    do {
	wi = strtol(wc, &wc, 10);
	si = strtol(sc, &sc, 10);
	if (*wc == '\0' || *sc == '\0')
	    break;
	wc++;
	sc++;
    } while (wi == si);
    return(wi - si);
}

/*
 * This routine is called to determine what the status or classification
 * of a particular product is. This determination is made by first check-
 * ing whether or not the product in question is already installed on the
 * system. If so, then the date in the product structure passed in is
 * compared to the date in the product.def in the product's directory.
 * The routine returns UP_TO_DATE or NEEDS_UPDATING if the product
 * already is in existence on the system and NEW if the product is not
 * currently installed on the system.
 */
void	get_prod_status(pptr)
struct prodnode *pptr;
{
    register int	status;
    register struct prodnode *lpptr;
    int		i, found;
    char	*c;
    char	*buffer;	/*"DATE" had better be in first block*/
    char	IDdate[FIXDATE_LEN+1], IDversion[FIXDATE_LEN+1];
    FILE	*fptr;		/*pointer to the opened file*/
    char	file[STRSIZ];	/*construct fixes file name in this guy*/
    char	arch_name[32];
    short	arch_date_set, arch_vers_set;
    char	arch_date_name[64], arch_vers_name[64];
    
    extern short	makenode;
    extern char	*strrchr();
    
    arch_name[0] = 0;
    for (i = 0; i < NUM_ARCH; i++) {
	if (my_arch == (1 << i)) {
	    strcpy(arch_name, cpu_types[i]);
	    break;
	}
    }

    /*
     * search the loadedheader list for any previously loaded
     * versions and update the pptr->loadeddir accordingly.
     */
    found = 0;

    for (lpptr = loadedheader.flink; lpptr != &loadedheader;
	 lpptr = lpptr->flink) {
	status = strcmp(lpptr->prodname, pptr->prodname);
	if (status == 0) {
	    if (strcmp(lpptr->prodnumber, pptr->prodnumber))
		continue;
	    found = 1;
	    strcpy(pptr->loadeddir, lpptr->loadeddir);
	    strcpy(pptr->loadedvers, lpptr->loadedvers);
	    break;
	} else if (status > 0)
	    /*
	     * cut the search short since loadedheader is
	     * a sorted linked list.
	     */
	    break;
    }
    if (makenode) {
	if (pptr->loadeddir[0])
	    sprintf(file, "%s/%s", pptr->loadeddir, PRODDEF);
	else {
	    sprintf(file, "%s/%s", basedir, pptr->prodname);
	    /*
	     * convert the product name portion to lower case
	     */
		for (c = strrchr(file, '/'); *c != '\0'; ++c)
		*c = (char)tolower(*c);
	    strcat(file, "/");
	    strcat(file, PRODDEF);
	}
    } else {
	if (pptr->loadeddir[0])
	    sprintf(file, "%s/%s", pptr->loadeddir, PRODDEF);
	else if (pptr->unixdir[0] == '/')
	    sprintf(file, "%s/%s", pptr->unixdir, PRODDEF);
	else
	    sprintf(file, "%s/%s/%s", basedir, pptr->unixdir, PRODDEF);
    }
    
    pptr->pstat &= 0xfff0;		/* clear out lower 4 bits */

    if (!found) {
	pptr->pstat |= NEW;
	return;
    }

    if (!(fptr = fopen(file, "r"))) {
	pptr->pstat |= NEW;
	return;
    }
    
    buffer = (char *)calloc(1, BUFFSIZ);
#ifndef SVR4
    bzero(IDdate, FIXDATE_LEN+1);
    bzero(IDversion, VERSION_LEN+1);
#else
    memset(IDdate, 0, FIXDATE_LEN+1);
    memset(IDversion, 0, VERSION_LEN+1);
#endif
    
    strcpy(arch_date_name, arch_name);
    strcat(arch_date_name, "_IDdate=");
    arch_date_set = 0;
    
    strcpy(arch_vers_name, arch_name);
    strcat(arch_vers_name, "_IDversion=");
    arch_vers_set = 0;
    
    while(fgets(buffer, BUFFSIZ, fptr) != NULL) {
	if (!strncmp(buffer, arch_date_name, strlen(arch_date_name))) {
	    strncpy(IDdate, &buffer[strlen(arch_date_name)], 11);
	    arch_date_set = 1;
	}
	else if (!strncmp(buffer, arch_vers_name, strlen(arch_vers_name))) {
	    strncpy(IDversion, &buffer[strlen(arch_vers_name)], 11);
	    arch_vers_set = 1;
	}
	else if (!strncmp(buffer, "IDdate=", 7) && !arch_date_set)
	    strncpy(IDdate, &buffer[7], 11);
	else if (!strncmp(buffer, "IDversion=", 10) && !arch_vers_set)
	    strncpy(IDversion, &buffer[10], 11);
	    
	/*if (IDversion[0] && IDdate[0])*/
	    
	/*
	 * We used to stop when both variables were defined, but 
	 * since platform-specific variables can be present that override
	 * the other values, we have to keep going.  So now, we'll 
	 * stop when we've hit the end of the variable definitions
	 */
    
	if (strncmp(buffer, "#PRODUCT DEPENDENCIES", 21) == 0)
	    break;
    }
    fclose(fptr);
    free(buffer);
    
    /*
     * check the date of the product -- if it's earlier than 11-OCT-1990
     * then use the date as the status, otherwise use the version number.
     */
    status = compare_dates(IDdate, "11-OCT-1990");
    if (status <= 0)
	status = compare_dates(IDdate, pptr->date);
    else
	status = compare_versions(IDversion, pptr->prodversion);
    
    if (status == 0) {
	/* 
	 *  Chip Cribbs wanted this -- if the versions are the same, see
	 *  if one has a later date.  Their plan is to NOT increment the
	 *  version number if a product is merely recompiled; they would
	 *  only change the date.  I think this is BOGUS -- the Intergraph
	 *  Configuration Management Standard clearly says that a recompile
	 *  indicates a change in the version number is needed....
	 */
	status = compare_dates(IDdate, pptr->date);
	if (status == 0)
	    pptr->pstat |= UP_TO_DATE;
	else if (status > 0)
	    pptr->pstat |= WORKSTATION_NEWER;
	else
	    pptr->pstat |= NEEDS_UPDATING;
    }
    else if (status > 0)
	pptr->pstat |= WORKSTATION_NEWER;
    else
	pptr->pstat |= NEEDS_UPDATING;
}

/*
 * Create a linked list of the products that are currently loaded
 * Here's a sample ingrconfig entry:
 * SS01191#ACC#Apogee C Compiler#05.00.01.27#07-NOV-1990#/usr/ip32/comp/acc#
 */
void	get_loaded_location()
{
    register struct prodnode *pptr;
    char	line[ELSIZE];
    char	config[STRSIZ];
    char	*c;
    FILE	*f;
    
    loadedheader.blocksize = 0;   
    loadedheader.flink = &loadedheader;
    loadedheader.blink = &loadedheader;
    
    config[0] = '\0';
    if (shared) {
	if (!configfile) {
		sprintf(config, "%s/%s/%s", sharedfs, ingrhome, CONFIGFILE);
	}
	else
	    strcpy(config, configfile);
    }
	else {
	    sprintf(config, "%s/%s", ingrhome, CONFIGFILE);
	}

    if ((f = fopen(config, "r")) == NULL)
	return;
    
    while (fgets(line, ELSIZE, f) != NULL) {
	pptr = (struct prodnode *)calloc(1, sizeof(struct prodnode));
	if (pptr == NULL)
	    continue;
	c = line;
	if (*(c = get_field(c, pptr->prodnumber, PRODNUM_LEN, 0))== EOL)
	    continue;
	if (*(c = get_field(c, pptr->prodname, PRODNAME_LEN, 1)) == EOL)
	    continue;
	if (*(c = get_field(c, pptr->prodtitle, TITLE_LEN, 0)) == EOL)
	    continue;
	if (*(c = get_field(c, pptr->loadedvers, VERSION_LEN, 0))== EOL)
	    continue;
	if (*(c = get_field(c, pptr->date, FIXDATE_LEN, 1)) == EOL)
	    continue;
	get_field(c, pptr->loadeddir, DIR_LEN, 0);
	if (access(pptr->loadeddir, 0))	/* skip it if it's not here */
	    continue;
	pptr->pstat = 0;
	ins_prod_node(pptr, &loadedheader, 0);
    }
    fclose(f);
}

/*
 * Create a linked list of the products that are currently "makenode"ed
 * This is actually very similar to the routine get_prod_rec() above, since
 * the record of "makenoded" products is another ws_s.prods file...
 */
void	get_mknode_location()
{
    register struct prodnode *pptr, *sptr;
    char	line[ELSIZE];
    char	str[64];
	char	*c, *t;
    FILE	*f;
    char	already_here;
	int	i;
    
    loadedheader.blocksize = 0;   
    loadedheader.flink = &loadedheader;
    loadedheader.blink = &loadedheader;
    
    if ((f = fopen(makenodelist, "r")) == NULL)
	return;
    
    while (fgets(line, ELSIZE, f) != NULL) {
	pptr = (struct prodnode *)calloc(1, sizeof(struct prodnode));
	if (pptr == NULL)
	    continue;
	
	already_here = 0;
	c = line;
	
	if (*(c = get_field(c, pptr->prodnumber, PRODNUM_LEN, 1))==EOL)
	    continue;
	
	if (*(c = get_field(c, pptr->prodtitle, TITLE_LEN, 0)) == EOL)
	    continue;
	
	if (*(c = get_field(c, pptr->date, FIXDATE_LEN, 0)) == EOL)
	    continue;
	
	/* blocksize field - skip over it */
	if (*(c = get_field(c, str, 64, 0)) == EOL)
	    continue;
	
	/* flags field - skip over it */
	if (*(c = get_field(c, str, FLAGS_LEN, 0)) == EOL)
	    continue;
	
	if (*(c = get_field(c, pptr->loadeddir, DIR_LEN, 0)) == EOL)
	    continue;
	
	/* unixdir field - skip over it */
	if (*(c = get_field(c, str, DIR_LEN, 0)) == EOL)
	    continue;
	
	/* load_priority field - skip over it */
	if (*(c = get_field(c, str, 64, 0)) == EOL)
	    continue;
	
	if (*(c = get_field(c, pptr->prodname, PRODNAME_LEN, 0)) == EOL)
	    continue;
	
	if (*(c = get_field(c, pptr->loadedvers, VERSION_LEN, 0)) == EOL)
	    continue;
	
	if (access(pptr->loadeddir, 0))	/* skip it if it's not here */
	    continue;
	
#ifdef OLD_STUFF
	/*
	 * We're not doing this any more.  Because of changes in
	 * 7.5 to "split" products by architecture, we don't want
	 * to lump them together in the menu.  We'll show them
	 * separately.
	 */
	/* Since there may be multiple lines in the
	 * file that refer to the same product but different
	 * platform, look for a pre-existing entry in the list
	 * for this product with the same name, title and loadeddir
	 * and if it exists, don't add it again.
	 */
	    for (sptr = loadedheader.flink; sptr != &loadedheader && !already_here; sptr = sptr->flink) {
	    if ((strcmp(sptr->prodname, pptr->prodname) == 0) &&
		(strcmp(sptr->prodtitle, pptr->prodtitle) == 0) &&
		(strcmp(sptr->loadeddir, pptr->loadeddir) == 0)) {
		free(pptr);
		pptr = NULL;
		already_here = 1;
	    }
	}
	
	if (already_here)
	    continue;
#endif
	    /* "class" field - skip over it */
	
	    c = get_field(c, str, 64, 0);
	    
	    /* "attributes" field - skip over it */

	    if (*c != EOL)
		c = get_field(c, str, 64, 0);

	    if (*c != EOL) {
		/* NEW FOR 06.00
		 * The DELarch field indicates the target platforms
		 * of the product
		 */
		c = get_field(c, str, 64, 0);
		t = (char *)strtok(str, "|");
		while (t != NULL) {
		    for (i = 0; (i < NUM_ARCH) && (*cpu_types[i] != '\0'); i++) {
			if (strcmp(t, cpu_types[i]) == 0)
			    pptr->arch |= (1 << i);
		    }
		    t = (char *)strtok(NULL, "|,:;");
		}
		if (pptr->arch == 0)
		    pptr->arch = CLIPPER_ARCH;
	    }
	    else
		pptr->arch = CLIPPER_ARCH;


	pptr->pstat = 0;
	ins_prod_node(pptr, &loadedheader, 0);
    }
    fclose(f);
}

/*
 * Find the location where a product has been installed.
 */
char *
find_loaded_location(prodname)
char *prodname;
{
    int         found = 0, place = 0, fd;
    static char *loadeddir = NULL, *c;
    FILE        *f;
    char        config[STRSIZ], line[ELSIZE];

    if (loadeddir == NULL)
	loadeddir = malloc(256);

    if (shared) {
        if (!configfile) {
            strcpy(config, sharedfs);
            strcat(config, CONFIGFILE);
        }
        else
            strcpy(config, configfile);
    }
    else {
        sprintf(config, "%s/%s", ingrhome, CONFIGFILE);
    }

    if ((f = fopen(config, "r")) == NULL) {
        if (errno == ENOENT) {
            if ((fd = creat(config, 0664)) < 0)
                return("");
            else {
                close(fd);
                f = fopen(config, "r");
            }
        }
        else
            return("");
    }


nextline:
    while (fgets(line, ELSIZE, f) != NULL && !found) {
        place = 1;
        c = (char *)strtok(line, "#");
        while (c != NULL) {
            if (place == 2) {
                if (strcmp(c, prodname) == 0) {
                    found++;
                }
                else
                    goto nextline;
            }
            if (place == 6 && found) {
                strcpy(loadeddir, c);
                break;
            }

            c = strtok(NULL, "#");
            place++;
        }
    }
    fclose(f);

    if (found)
        return(loadeddir);
    else
        return("");
}


/*
 * This routine reads in records(lines) from the prodlist file whose name
 * is given in argument "filename", copies the fields from the file's
 * record into an internal product structure and then appends the
 * product structure to the appropriate product classification list.
 */
int	read_prodlist_file(filename, header)
char	*filename;
struct prodnode	*header;
{
    int	*listbuf;
    int	fptr;
    char	*lptr;
    struct prodnode	*pptr = NULL;    /*filled in by "get_prod_rec"*/
    extern struct stat statbuf;
    
    if ((fptr = open(filename, O_RDONLY)) == -1)
	return(-1);
    if (fstat(fptr, &statbuf))
	return(-2);
    if ((listbuf = (int *)malloc(statbuf.st_size + 4)) == NULL)
	return(-3);
    if (read(fptr, listbuf, statbuf.st_size) != statbuf.st_size)
	return(-4);
    
    if (makenode)
	get_mknode_location();
    else
	get_loaded_location();
    
    lptr = (char *)((int)listbuf + statbuf.st_size);
	*lptr = (char)EOF;
    lptr = (char *)listbuf;
	while (*lptr != (char)EOF && get_prod_rec(lptr, &pptr, header) != (char)EOF) {
	if (pptr) {	/*valid product record??*/
	    get_prod_status(pptr);
	    ins_prod_node(pptr, header, 1);
	    ins_class(pptr, &classheader);
	    pptr = NULL;	/*re-initialize for next pass*/
	}
	/* search up to the EOL, skip lines starting with # */
		for (; *lptr != EOL && *lptr != (char)EOF; ++lptr)
	    ;
		if (*lptr == (char)EOF)
	    break;
	++lptr;
	while (*lptr == '#' || *lptr == '\0') {
			for (; *lptr != EOL && *lptr != (char)EOF; ++lptr)
		;
			if (*lptr == (char)EOF)
		break;
	    ++lptr;
	}
    }
    close(fptr);
    free(listbuf);
    return(header->blocksize);
}
