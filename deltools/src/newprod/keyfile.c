#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#if defined(SVR3) || defined(_AIX) || defined(sgi)
#  include <sys/statfs.h>
#endif
#if defined(SVR4) && !defined(sgi)
#  include <sys/statvfs.h>
#endif
/* HP added along with SUN -- MVR 30 Apr 1994 */
#if defined(SunOS_4) || defined(HP_UX)
#  include <sys/vfs.h>
#endif
#ifdef OSF
#  include <sys/mount.h>
#endif
#include "defs.h"
#include "req.h"

/* HP added in the list -- MVR 30 Apr 1994 */
#if defined(SVR3) || defined(_AIX) || defined(OSF) || defined(HP_UX)
#  define WC	"/bin/wc"
#endif
#ifdef SVR4
#  define WC	"/usr/bin/wc"
#endif
#ifdef SunOS_4
#  define WC	"/usr/ucb/wc"
#endif

#ifndef NEW_KEY_CUTIN
#define NEW_KEY_CUTIN	"010194"
#endif
extern short    verbose;        /*set if "-v" cmd line option present*/
extern char	deltools_home[STRSIZ];
extern char	*ingrhome;

extern short	iso_9660;
char		cdrel[16];
static char	lastkeyfound[KEY_LEN];

struct keyinfo {
	char 	pn[20];
};

struct keyinfo	*keys;

/*
 * This routine compares two key file entries based on the first chars
 * up to the space delimiter. It returns 0 when the product numbers are
 * equal.
 */
int	keycmp(s1, s2)
char	*s1, *s2;
{
	for (; *s1 == *s2; ++s1, ++s2) {
		if (*s1 == '\0' || *s1 == ' ')
			return(0);
	}
	return(1);
}


/*
 * This routine compares two CD-ROM volume labels.  It returns 0 if
 * the volume labels are the same date; otherwise it returns <0 if
 * the first label is "earlier" than the second and >0 if the first
 * label is "later" than the second.
 *
 *  Assumptions:	the two labels are six digit strings in the
 *			form mmddyy
 */
int	labelcmp(s1, s2)
char	*s1, *s2;
{
	char	ns1[7], ns2[7];

	/*
	 * If we rearrange the strings so they're in the form
	 * yymmdd instead of mmddyy, we can compare them directly.
	 * That way, 931231 really IS less than 940101.
	 *
	 * (If you try to compare them without rearranging, you
	 *  get bad results:  010194 < 123193...)
	 */
	ns1[0] = *(s1+4);	ns2[0] = *(s2+4);
	ns1[1] = *(s1+5);	ns2[1] = *(s2+5);
	memcpy(ns1+2, s1, 4);
	memcpy(ns2+2, s2, 4);
	ns1[6] = '\0';
	ns2[6] = '\0';

	return(strncmp(ns1, ns2, 6));
}
	

/*
** Builds a 15 character part number (INCLUDING VERSION) from
** any existing part number
*/
void build_pn15(new_pnumber, pnumber, pversion)
char *new_pnumber;
char *pnumber;
char *pversion;
{
    memset(new_pnumber, 0, 16);
    strcpy(new_pnumber, pnumber);

    if (strlen(pnumber) == 7)
	strcat(new_pnumber, "AA-0000A");
    else if (strlen(pnumber) == 9) 
	strcat(new_pnumber, "-0000A");
    
    
    /*
    ** 07/21/94
    **
    ** PNs that have the initial 9-digit section
    ** end in "00" are a problem for Software Distribution.
    **
    ** They need to be changed to "AA".
    **
    */
    if (new_pnumber[7] == '0' &&
	new_pnumber[8] == '0') {
	new_pnumber[7] = 'A';
	new_pnumber[8] = 'A';
    }

    new_pnumber[10] = pversion[0];
    new_pnumber[11] = pversion[1];
    new_pnumber[12] = pversion[3];
    new_pnumber[13] = pversion[4];
}





/*
 * This routine makes the key entry for a product. It uses
 * lsearch to do the dirty work.
 */
#define ELSIZE	64
#define TABSIZE	8192
void	make_keyfile_entry(keyf, prodnum, prodver, loadkey, authtyp)
char	*keyf, *prodnum, *prodver, *loadkey;
unsigned short authtyp;
{
	char		line[ELSIZE], tab[TABSIZE][ELSIZE], *lsearch();
	char		fname[256];
	char		longnum[32];
	char		*c;
	unsigned	nel = 0;
	int		i;
	struct flock	fl;
	FILE		*f;

	/*
	 * don't bother saving the key if we know we got it from the file in
	 * the first place.
	 */
	if (!strcmp(loadkey, lastkeyfound))
		return;

	build_pn15(longnum, prodnum, prodver);

	sprintf(fname, "%s/%s", ingrhome, KEYSDIR);

	if (access(fname, (R_OK | W_OK | X_OK)))
		mkdir(fname, 0755);

	if ((f = fopen(keyf, "r+")) == NULL)
		if ((f = fopen(keyf, "w+")) == NULL) 	/* create the file */
			return;

	/*
	 * lock the whole keys file for reading and writing, wait on any
	 * process that already has the file locked.
	 */
	fl.l_type = F_WRLCK;
	fl.l_whence = 0;
	fl.l_start = 0;
	fl.l_len = 0;
	fcntl(fileno(f), F_SETLKW, &fl);

	fseek(f, 0L, 0);
	while (fgets(line, ELSIZE, f) != NULL && nel < TABSIZE)
	    (void)lsearch(line, (char *)tab, &nel, ELSIZE, 
				(int(*)(const void *, const void *))keycmp);

	if (authtyp)
		sprintf(line, "%s %s \n", longnum, loadkey);
	else
		sprintf(line, "%s %s\n", longnum, loadkey);
	c = lsearch(line, (char *)tab, &nel, ELSIZE,
				(int(*)(const void *, const void *))keycmp);
	if (authtyp)
		sprintf(c, "%s %s \n", longnum, loadkey);
	else
		sprintf(c, "%s %s\n", longnum, loadkey);
#ifndef SCO
	/* write the table into the file */
	fseek(f, 0L, 0);
	ftruncate(fileno(f), 0);
	for (i = 0; i < nel; ++i)
		fprintf(f, "%s", tab[i]);
	/* closing the file also removes locks on the file */
	fclose(f);
#else
	/*
 	 * SCO doesn't have ftruncate, so we'll have to close the file and
	 * re-open it to get it truncated.  There is a risk here, that
	 * in the window between the time that we close the file and
	 * reopen and re-assert our write lock, some other process will
 	 * sneak in and steal the lock away from us.  If they 
	 * update the file, that new data would be lost when we write
 	 * our information back out.
	 */
	fclose(f);
	if (f=fopen(keyf, "w")) {
	    /*
	     * lock the whole keys file for reading and writing, wait on any
	     * process that already has the file locked.
	     */
	    fl.l_type = F_WRLCK;
	    fl.l_whence = 0;
	    fl.l_start = 0;
	    fl.l_len = 0;
	    fcntl(fileno(f), F_SETLKW, &fl);

	    for (i = 0; i < nel; ++i)
		fprintf(f, "%s", tab[i]);
	    fclose(f);
	}
#endif
}

/*
 * returns zero on failure, non-zero on success and the loadkey
 * argument gets the found key.
 */
int	find_keyfile_entry(keyf, prodnum, prodver, loadkey, authtyp)
char	*keyf, *prodnum, *prodver, *loadkey;
unsigned short authtyp;
{
	char	num[STRSIZ];
	char	longnum[32];
	int	i;
	FILE	*kf;

	if ((kf = fopen(keyf, "r")) == NULL)
		return(0);
        
	build_pn15(longnum, prodnum, prodver);

	/*
	 * scan the key file and check to see if prodnumber is in it.
	 */
	loadkey[0] = '\0';
	if (authtyp) {
	    while (fscanf(kf, "%s %s ", num, loadkey) != EOF) {
		for (i = 0; i < strlen(num); ++i)
			num[i] = (char)toupper(num[i]);
		if (!strcmp(num, longnum)) {
			strcpy(lastkeyfound, loadkey);
			break;
		}
		loadkey[0] = '\0';
	    }
	}
	else {
	    while (fscanf(kf, "%s %s", num, loadkey) != EOF) {
		for (i = 0; i < strlen(num); ++i)
			num[i] = (char)toupper(num[i]);
		if (!strcmp(num, longnum)) {
			strcpy(lastkeyfound, loadkey);
			break;
		}
		loadkey[0] = '\0';
	    }
	}
	fclose(kf);
	return((int)loadkey[0]);
}

char *generate_sn_filename(path)
char	*path;
{
	static char	*snf = NULL;

	/*
	 * if snfile is set, then that means the name has already been
	 * generated.
	 */
	if (snf)
		return(snf);

	if (snf = (char *)malloc(48))
	    *snf = '\0';
	else
	    return("");

	    sprintf(snf, "%s/%s/snfile", ingrhome, KEYSDIR);
	return(snf);
}

/*
 * returns the pointer to the string if successful, NULL otherwise
 */
extern char *generate_kf_from_fsstat(char *);

char *generate_key_filename(path)
char	*path;
{
	int	fd;
	static char	*keyf = NULL;
	char		command[256];
	extern char	*GetMountPoint();
	char		vbuf[1024], vfile[128];
	int		fd1;
	int		use_fsstat = 0;
	char		*c, *mp;


	/*
	 * if keyfile is set, then that means the name has already been
	 * generated.
	 */
	if (keyf)
		return(keyf);

#ifdef sgi
	/*
	** SGI systems implement their CD-ROM device in a weird
	** way -- you can't access it directly.  On these systems,
	** the "volume" file in the root directory of the CD
	** is the only chance to determine the "release date"
	** of the CD.
	*/

	if (keyf = (char *)malloc(48))
	    *keyf = '\0';
	else
	    return("");

	mp = GetMountPoint(path);
	if (mp == NULL)
	    return("");

	strcpy(vfile, mp);
	strcat(vfile, "/volume");

	/*
	 * check for the volume file, if not there then exit quietly
	 */
	if (access(vfile, R_OK) == 0) {
	    fd1 = open(vfile, O_RDONLY);
	    if (fd1 < 0)
		return("");
	}
	else {
	    for (c = vfile + strlen(mp); *c; c++)
		    *c = toupper(*c);

	    if (access(vfile, R_OK) == 0) {
		fd1 = open(vfile, O_RDONLY);
		if (fd1 < 0)
		    return("");
	    }
	    else
		return("");
	}

    /*
     *  Alright, now we've got the file open.
     *  Read the data, which is formatted as:
     *
     *  {Disc Title}#{Disc Date}#{Volume label}#{FMDA part number}
     */
	if (read (fd1, vbuf, 1024) < 0) {
	    close(fd1);
	    return("");
	}
	close(fd1);

	/*
	 * Now, with the magic of strtok(), find the third field.
	 */
	c = (char *)strtok(vbuf, "#");	/* Field 1 */
	c = (char *)strtok(NULL, "#");	/* Field 2 */
	c = (char *)strtok(NULL, "#");	/* Field 3 */

	if (c == NULL)
	    return ("");
	else {
	    sprintf(keyf, "%s/%s/keyfile", ingrhome, KEYSDIR);

	    sprintf(cdrel, "%c%c/%c%c/%c%c",
			    *c, *(c+1), *(c+2), *(c+3), *(c+4), *(c+5));
	}
#else
	/*
	** First, look for a "volume" file on the CD.
	** This is the "new-fangled" way to get the info.
	** 
	** Doing this instead of a fstatfs() makes it possible to
	** obtain volume information even when the CD is mounted
	** over NFS.
	*/

	fd1 = -1;
	if (keyf = (char *)malloc(48))
	{
	    *keyf = '\0';
	    mp = GetMountPoint(path);
	    if (mp != NULL)
	    {
		strcpy(vfile, mp);
		strcat(vfile, "/volume");

		/*
		 * check for the volume file, if it's there then let's use it
		 */
		if (access(vfile, R_OK) == 0) {
		    fd1 = open(vfile, O_RDONLY);
		    if (fd1 < 0)
			use_fsstat = 1;
		}
		else {
		    for (c = vfile + strlen(mp); *c; c++)
			    *c = toupper(*c);

		    if (access(vfile, R_OK) == 0) {
			fd1 = open(vfile, O_RDONLY);
			if (fd1 < 0)
			    use_fsstat = 1;
		    }
		    else
			use_fsstat = 1;
		}
	    }
	    else
		use_fsstat = 1;
	}
	else
	    use_fsstat = 1;


	if (use_fsstat == 0 && fd1 >= 0) 
	{
	    /*
	     *  Alright, now we've got the file open.
	     *  Read the data, which is formatted as:
	     *
	     *  {Disc Title}#{Disc Date}#{Volume label}#{FMDA part number}
	     */
	    if (read (fd1, vbuf, 1024) < 0) {
		close(fd1);
		use_fsstat = 1;	
	    }
	    close(fd1);

	    /*
	     * Now, with the magic of strtok(), find the third field.
	     */
	    c = (char *)strtok(vbuf, "#");	/* Field 1 */
	    c = (char *)strtok(NULL, "#");	/* Field 2 */
	    c = (char *)strtok(NULL, "#");	/* Field 3 */

	    if (c != NULL) {
		sprintf(keyf, "%s/%s/keyfile", ingrhome, KEYSDIR);
		sprintf(cdrel, "%c%c/%c%c/%c%c",
				*c, *(c+1), *(c+2), *(c+3), *(c+4), *(c+5));
	    }
	    else {
		use_fsstat = 1;
	    }	
	}

	if (use_fsstat)
	    strcpy (keyf, generate_kf_from_fsstat(path));
#endif /* sgi */
	return(keyf);
}



char *generate_kf_from_fsstat(path)
char *path;
{
	int fd;
    #if defined(SVR4) && !defined(sgi)
	struct statvfs	statfsbuf;
    #else
	struct statfs	statfsbuf;
    #endif

	static char *keyf = NULL;

	/*
	 * get volume name from mounted filesystem with open descriptor fd
	 */
	fd = open(path, O_RDONLY);
    #if defined(SVR3) || defined(sgi)
	if (!fstatfs(fd, &statfsbuf, sizeof(struct statfs), 0))
    #endif /* SVR3 */
    #if defined(SVR4) && !defined(sgi)
	if (!fstatvfs(fd, &statfsbuf))
    #endif /* SVR4 */
    #if defined(SunOS_4) || defined(_AIX) || defined(OSF)
	if (!fstatfs(fd, &statfsbuf))
    #endif /* SunOS || AIX || OSF */
	{
	    if ((keyf = (char *)malloc(48))) {
		keyf[0] = '\0';
    #if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
		if (!iso_9660) {

    /*
    * 94/01/13
    * Now we always ignore any loadkey information from an old product CD
    * The only source we recognize is the "master loadkey database", which
    * will have keys for ALL products, ALL platforms, ALL customers.
    * CD-ROM release date will no longer be significant, so the "keyfile"
    * file will hold all of this information.
    */
		    sprintf(keyf, "%s/%s/keyfile", ingrhome, KEYSDIR);
		    sprintf(cdrel, "%c%c/%c%c/%c%c",
				statfsbuf.f_fpack[0], statfsbuf.f_fpack[1],
				statfsbuf.f_fpack[2], statfsbuf.f_fpack[3],
				statfsbuf.f_fpack[4], statfsbuf.f_fpack[5]);
		    }
		    else {
			int cfd;
			char label[7];
			
			cfd = open(CDROM_DEVICE, O_RDONLY);
			lseek(cfd, (16*2048+47), 0);
			read(cfd, label, 6);
			label[6] = '\0';
			close(cfd);

			sprintf(keyf, "%s/%s/keyfile", ingrhome, KEYSDIR);
			sprintf(cdrel, "%c%c/%c%c/%c%c",
				label[0], label[1], label[2], label[3], label[4], label[5]);
		    }
    #else /* not clipper */
		    {
			int cfd;
			char label[7];
			
			cfd = open(CDROM_DEVICE, O_RDONLY);
			lseek(cfd, (16*2048+47), 0);
			read(cfd, label, 6);
			label[6] = '\0';
			close(cfd);

			sprintf(keyf, "%s/%s/keyfile", ingrhome, KEYSDIR);
			sprintf(cdrel, "%c%c/%c%c/%c%c",
				label[0], label[1], label[2], label[3], label[4], label[5]);
		    }
    #endif
	    }
	}
	close(fd);
    return(keyf);
    }


int	get_key_data(keyf,snf)
char	*keyf;
char	*snf;
{
	extern	unsigned short cdtype;
	FILE	*kf;
	int	i, lines=0, kflines=0, snlines=0;
	char	key[STRSIZ];
	char	istr[80];
	char	*isp;
	struct  keyinfo *kp;

	if (access(keyf, R_OK) == 0) {
	    sprintf(key, "%s -l %s", WC, keyf);
	    if ((kf = popen(key, "r")) == NULL)
		return(-1);
	    while (fscanf(kf, "%d %s", &kflines, key) != EOF)
	 	;
	    pclose(kf);
	}
	if (access(snf, R_OK) == 0) {
	    sprintf(key, "%s -l %s", WC, snf);
	    if ((kf = popen(key, "r")) == NULL)
		return(-1);
	    while (fscanf(kf, "%d %s", &snlines, key) != EOF)
		;
	    pclose(kf);
	  }
	lines = kflines+snlines;
	if (!lines) {
	    lines = 0;
	    if ((keys = (struct keyinfo *)malloc(sizeof(struct keyinfo))) == NULL)
		return(-1);
	    keys->pn[0] = '\0';
	    return(0);
        }
	    lines = lines+1;

	    if ((keys = (struct keyinfo *)malloc(lines * sizeof(struct keyinfo))) == NULL)
		return(-1);
	    kp=keys;
	    if ((kf = fopen(keyf, "r")) != NULL) {
		    while (fgets(istr, 80, kf) != NULL) {
			for (i=0, isp=istr; *isp != ' '; i++, isp++)
			    kp->pn[i] = toupper(*isp);

		kp->pn[i] = '\0';
		kp++;
	    	}
	    fclose(kf);
	    }

	    if ((kf = fopen(snf, "r")) != NULL) {
		    while (fgets(istr, 80, kf) != NULL) {
			for (i=0, isp=istr; *isp != ' '; i++, isp++)
			    kp->pn[i] = toupper(*isp);

			kp->pn[i] = '\0';
			kp++;
		    }
	    	kp->pn[0] = '\0';
		fclose(kf);
		return(0);
	    }
return(0);
}

/*
 * returns zero on failure, non-zero on success
 */
int	get_key_status(pptr)
struct prodnode	*pptr;
{
	struct keyinfo *kp;
	char longnum[32];

	build_pn15(longnum, pptr->prodnumber, pptr->prodversion);

	for (kp = keys; (kp->pn[0] != '\0'); kp++) {
	    if (!strcmp(kp->pn, longnum)) {
		    pptr->pstat |= HAVEKEY;
		    break;
	    }
	}
	return(0);
}
