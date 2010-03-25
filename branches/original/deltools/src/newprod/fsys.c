#include	<stdlib.h>
#include	<stdio.h>
#include	<sys/types.h>
#include	<sys/stat.h>
#include	<sys/mount.h>
#ifdef SVR3
#include	<sys/statfs.h>
#include	<sys/fstyp.h>
#include	<sys/fsid.h>
#  ifdef SCO
#  include <mnttab.h>
#  endif
#endif
#ifdef SVR4
#  ifndef sgi
#  include	<sys/statvfs.h>
#  include	<sys/mntent.h>
#  include	<sys/mnttab.h>
#  endif
#include	<sys/fstyp.h>
#include	<sys/fsid.h>
#endif
/* ifdef HP added here -- MVR 30 Apr 1994 */
#ifdef HP_UX
#include	<sys/param.h>
#include	<sys/vfs.h>
#include	<mntent.h>
#include	<sys/dir.h>
/* NMOUNT picked up MNTHASHSZ system -- MVR 30 Apr 1994 */
#define NMOUNT	32
#endif
#ifdef SunOS_4
#include	<sys/param.h>
#include	<sys/vfs.h>
#include	<mntent.h>
#include	<sys/dir.h>
#endif
#ifdef _AIX
#include        <sys/statfs.h>
#include        <sys/vmount.h>
#include        <sys/mntctl.h>
#endif
#ifdef OSF
#include	<sys/mount.h>
#endif
#ifdef sgi
#include	<sys/param.h>
#include	<sys/dir.h>
#include	<mntent.h>
#  ifdef SVR4
#  include	<sys/statfs.h>
#  endif
#endif
#include	<unistd.h>
#include	<string.h>
#include	<errno.h>
#include	"defs.h"

#if defined(SVR3) && !defined(sgi)
#define		MNTTAB	"/etc/mnttab"
#endif

extern char	*sys_errlist[];

extern char	basedir[STRSIZ];
extern char	mountpoint[STRSIZ];
extern char	sharedfs[STRSIZ];
extern char	*dashes;
extern short	makenode;
extern short	verbose;
extern short	shared;
extern short	minus_b;
extern struct stat statbuf;
extern FILE	*logf;

short	iso_9660;
short	fsmounted;

#if defined(SVR4) && !defined(sgi)
struct statvfs	statfsbuf;
#else
struct statfs	statfsbuf;
#endif

#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
/*
 * Format of the new NFS /etc/mnttab file which is set by the mount(1m) command
 */
struct mnttab {
	char	mt_dev[32], mt_filsys[32];
	short	mt_ro_flg;
	time_t	mt_time;
	char	mt_fstyp[16], mt_mntopts[64];
};
#endif

#if !((defined(clipper) || defined(__clipper__) || defined(SCO)) && defined(SYSV))
int mkdirp(name, mode)
char *name;
int mode;
{
	char *tdp, *np, *lastpos;
	struct stat	statbuf;
	char tmpdir[256];
	
	strcpy(tmpdir, name);
	tdp = tmpdir;
	np = name;
	lastpos = strrchr(name, '/');

	if (np < lastpos)
		*tdp++ = *np++;

	while (np < lastpos) {
	  while (*np != '/' && np < lastpos)
	    *tdp++ = *np++;
	  
	  /* temporarily place a null to end the string */
          *tdp = '\0';

	  if (stat(tmpdir, &statbuf) < 0) {
		  if (mkdir(tmpdir, mode) < 0) {
			if (errno != EEXIST) {
			  return(-1);
			}
		  }
	  }
	  if (*np == '/')
	    *tdp++ = *np++;
        }
	if (mkdir(name, mode) < 0) {
	    if (errno != EEXIST) {
	        return(-1);
	    }
	}
	return(0);     
}
#endif

/*
 * This routine will attempt to create the directory whose name is given
 * in the parameter "dirname".
 */
int	makedir(dirname, mode, owner, group)
char	*dirname;
int	mode;
uid_t	owner;
gid_t	group;
{
	extern int	mkdirp();

	if (mkdirp(dirname, mode) == -1) {
	    if (errno != EEXIST) {
		PRINT "ERROR: Could not create directory %s: %s", dirname, sys_errlist[errno]);
		LPRINT "ERROR: Could not create directory %s: %s\n", dirname, sys_errlist[errno]);
		if (verbose)
			PRINT ".\n");
		return(-1);
	    }
	    else
		return(0);
	}
	chown(dirname, owner, group);
	return(0);
}


/*
 * Find the pathname to the mount point of the passed in directory.
 * Return NULL if the file doesn't exist or isn't an absolute path.
 * (4/17/91 SCW -- NOT NECESSARILY... see below!)
 */
char	*GetMountPoint(path)
char	*path;
{
	dev_t	dev;
	char	*c;
	int	result;
	static char	p[STRSIZ];
#if !defined(_AIX)
        extern char *strrchr();
#endif
#if (defined(__clipper__) || defined(clipper)) && defined(SYSV)
	struct statfs	stbuf;
	int	cafs = 0;
	char	fstype[16];
	char	p2[STRSIZ];
	char	*c2;
#endif

	if (path[0] != '/')
		return(NULL);

	strcpy(p, path);

	while ((*p != '\0') && 
	       (((result = stat(p, &statbuf)) < 0) && (errno == ENOENT))) {
	    /* We can't simply return NULL if the file doesn't exist.
	     * If we're installing a new product, the destination directory
	     * won't be out there yet.  We still have to get its mount point,
	     * though.  So start taking things off the back until we DO
	     * have a directory that exists.  If we get all the way back to
	     * the beginning, or if stat() fails for some other reason, then
	     * we'll go ahead and return NULL.
	     */
	    c = strrchr(p, '/');
	    *c = '\0';
	}

	if (*p == '\0')		/* No element of the path existed at all */
	    return(NULL);

	if ((result < 0) && (errno != ENOENT)) /* Some other stat() error */
	    return(NULL);

	/* NOW we have remaining directory.   Let 'er rip */
	dev = statbuf.st_dev;

	for (;;) {
		c = strrchr(p, '/');
		*c = '\0';
		if (c == p)
			stat("/", &statbuf);
		else
			stat(p, &statbuf);
		if (statbuf.st_dev != dev)
			break;
		else if (c == p) {
			p[1] = '\0';
			break;
		}
	}
	*c = '/';

#if defined(clipper) || defined(__clipper__)
#  ifdef SYSV
	/*
	 * CAFS platters appear as if they were all part of the same
	 * device (/dev/dsk/cache), so what gets returned above is the
	 * root directory of the cache file system.  But nobody
	 * is allowed to write in the root directory of the
	 * cache file system - it just exists for the directories
	 * corresponding to the platters (which are the directories
	 * below).  So if we ARE dealing with a CAFS file system, we
	 * have to "back off" one level to get down to the platter.
	 */
	if (statfs(p, &stbuf, sizeof(struct statfs), 0) < 0) {
	    cafs = 0;
	}
	else {
	    sysfs(GETFSTYP, stbuf.f_fstyp, fstype);
	    if (strncmp("CAFS", fstype, 4) == 0)
		cafs = 1;
	}
	if (cafs) {
	    /*
	     * Go back down one directory.
	     */
	    strcpy(p2, path);
	    c = p2 + strlen(p) + 1;
	    c2 = strchr(c, '/');
	    if (c2)
		*c2 = NULL;
	    
	    stat(p2, &statbuf);
	    if (S_ISDIR(statbuf.st_mode)) {
		strcpy(p, p2);
	    }
	}
#  endif
#endif
	return(p);
}

/*
 * Prompt for the directory where the delivery tree files will be put.
 * Also prompt for the filename of the product list file.
 */
void	getmakenodedir()
{
	int     f, ok = 0;
	char	nodeans[STRSIZ];
	char	tmpdir[STRSIZ];
	extern char	makenodelist[STRSIZ];

	if ( !minus_b || basedir[0] == '\0') {
	    PRINT "\n\nA delivery node can have products available from it from several\n");
	    PRINT "directories. It is easier to manage when all the products exist in\n");
	    PRINT "one directory.\n");

	    sprintf(tmpdir, "%s/ws_s", mountpoint);	/* default value */
	    nodeans[0] = '\0';
	}
	else {
    /*
     * Refer to TR 289301107.  Customer does not want "makenode"
     * automatically grafting "ws_s" onto the provided directory name.
     *
	    sprintf(tmpdir, "%s/ws_s", basedir);
	    strcpy(nodeans, tmpdir);
    */
	    strcpy(nodeans, basedir);
	}

	while (!ok) {
	    if (nodeans[0] == '\0') {
		PRINT "\nKey in the directory where the products are to be loaded [%s]: ",
			tmpdir);
		gets(nodeans);

	    }
	    if (nodeans[0] == '\0')
		strcpy(nodeans, tmpdir);

	    if (nodeans[0] != '/') {
		PRINT "Please specify an absolute path-name.\n");
		nodeans[0] = '\0';
		continue;
	    }

	    /*
	     * make the nodeans directory
	     */
	    if ((makedir(nodeans, CREAT_DIRMODE, 0, 0)) < 0) {
		PRINT "Cannot create %s. Try again.\n", nodeans);
		nodeans[0] = '\0';
		continue;
	    }

	    /*
	     * make a temporary directory
	     */
	    sprintf(tmpdir, "%s/tmp", GetMountPoint(nodeans));
	    if ((makedir(tmpdir, CREAT_DIRMODE, 0, 0)) < 0) {
		PRINT "Cannot create %s. Try again.\n", tmpdir);
		nodeans[0] = '\0';
		continue;
	    }

	    /*
	     * if everything above is successful, then set the global
	     * variables.
	     */ 
	    ok = 1;
	    strcpy(basedir, nodeans);
	    strcpy(mountpoint, GetMountPoint(nodeans));
	}

	ok = 0;

	if (!makenodelist[0]) {
	    PRINT "\n\nWhen newprod connects to this node to deliver software, it must\n");
	    PRINT "download a file that defines which products are available and where\n");
	    PRINT "they exist on the delivery node. This file is the product list file.\n");
	    PRINT "Newprod looks for this file in the HOME directory of the account\n");
	    PRINT "defined for the username.password in the network connection string,\n");
	    PRINT "if it is not there, then it looks for it in the root directory.\n");

	    sprintf(makenodelist, "/ws_s.prods");
	    nodeans[0] = '\0';
	}
	else {
	    strcpy(nodeans, makenodelist);
	}

	while (!ok) {
	    if (nodeans[0] == '\0') {
		PRINT "\nKey in the pathname for the product list file [%s]: ", makenodelist);
		gets(nodeans);
	    }

	    if (nodeans[0] == '\0')
		strcpy(nodeans, makenodelist);

	    if (nodeans[0] != '/') {
		PRINT "Please specify an absolute path-name.\n");
		nodeans[0] = '\0';
		continue;
	    }

	    if (stat(nodeans, &statbuf) >= 0 && S_ISDIR(statbuf.st_mode))
		strcat(nodeans, makenodelist);

	    if (access(nodeans, (R_OK | W_OK))) {
		if ((f = creat(nodeans, 0664)) > 0)
		    close(f);
		else {
		    PRINT "Cannot create %s. Try again.\n", nodeans);
		    nodeans[0] = '\0';
		    continue;
		}
	    }
	    ok = 1;
	}
	strcpy(makenodelist, nodeans);
}

/* HP added in the following list -- MVR 30 Apr 1994 */
#if defined(SYSV) || defined(SunOS_4) || defined(OSF) || defined(HP_UX)
/*
 * show the user the available filesystems and prompt for which file system
 * should be used for loading software to.
 */
char	*fsys_choose()
{
    int			maxfree;
    char		maxfsys[STRSIZ], mntchosen[STRSIZ];
#if defined(SVR3) && !defined(sgi)
    FILE		*fptr;		/* used to open/read "/etc/mnttab" */
    struct mnttab	*mp;
    extern int		statfs();
#  if !defined(clipper) && !defined(__clipper__)
    char		fstype[16];
#  endif
#endif
#if defined(SVR4) && !defined(sgi)
    extern int		statvfs();
    FILE		*fptr;
    struct mnttab	*mp;
    int			pctfree;
    int			factor;
#endif
/* HP added here --  MVR 30 Apr 1994 */
#if defined(SunOS_4) || defined(sgi) || defined(HP_UX)
    extern int		statfs();
    FILE		*fptr;		/* used to open/read "/etc/mtab" */
    struct mntent	*mp;
    int			pctfree;
    int			factor;
#endif	
#ifdef OSF
    extern int		statfs();
    int			pctfree;
    struct statfs	*sfbuf, *mp;
    long		bufsiz;
    int			retval;
    int			entries, i;
#endif

#if defined(SYSV) && !defined(sgi)
    if (stat(MNTTAB, &statbuf) < 0)
	return(basedir);

    mp = (struct mnttab *)malloc(sizeof(struct mnttab));
#endif

/* HP added here -- MVR 30 Apr 1994 */
#if defined(SunOS_4) || defined(sgi) || defined(HP_UX)
    if (stat(MOUNTED, &statbuf) < 0)
	return(basedir);

    mp = (struct mntent *)malloc(sizeof(struct mntent));
#endif
#ifdef OSF
    /* First, find out how many file systems are mounted */
    entries = getfsstat((struct statfs *)0, 0, 0);

    /*
     * Now malloc a buffer large enough to hold all of the
     * statfs structures that will be returned.
     */
    bufsiz = entries * sizeof(struct statfs);
    sfbuf = (struct statfs *)malloc(bufsiz);

    /* Now, get the information for real! */
    retval = getfsstat(sfbuf, bufsiz, MNT_NOWAIT);
#endif
    for (;;) {
	PRINT "\033[H\033[JAvailable file systems to download to:\n");
	PRINT dashes);
	PRINT "\nFile System	               Device                 Free/Total Blocks  %% Free\n");
	PRINT dashes);

#if defined(SVR3) && !defined(sgi)
	/* CLIX method of reading mounted filesystem table */
	if ((fptr = fopen(MNTTAB, "r")) == NULL) {
	    free(mp);
	    return(basedir);
	}
	maxfree = 0;
	for (;;) {
	    if (fread(mp, sizeof(struct mnttab), 1, fptr) != 1)
		break;		/* read err or EOF */

#  if defined(__clipper__) || defined (clipper)
	    /*
	     * Skip over readonly file systems, automounted file
	     * systems, proc file systems and NFS file systems.
	     */
	    if (mp->mt_ro_flg || !mp->mt_fstyp[0] ||
	       !strcmp(mp->mt_fstyp, "PROC") || !strcmp(mp->mt_fstyp, "NFS"))
		continue;
#  endif

	    /*
	     * Make sure we can stat the filesystem.
	     */
	    if (statfs(mp->mt_filsys, &statfsbuf, sizeof(struct statfs), 0))
		continue;

#  if !defined(__clipper__) && !defined(clipper)
	    /*
	     * For "standard" SVR3 platforms, this is where we check
	     * file system type.  (CLIX's method of putting it in
	     * /etc/mnttab is a non-portable extension.)
	     */
	    if (sysfs(GETFSTYP, statfsbuf.f_fstyp, fstype) < 0)
		continue;

	    if (strcmp(fstype, "PROC") == 0 || strcmp(fstype, "DUFST") == 0 ||
                strcmp(fstype, "NFS") == 0 || strcmp(fstype, "HS") == 0)
                continue;
#  endif

	    if (statfsbuf.f_bfree > maxfree) {
		maxfree = statfsbuf.f_bfree;
		strcpy(maxfsys, mp->mt_filsys);
	    }

	    PRINT "\n%-30.30s %-22.22s %7d/%7d %7d%%",
			    mp->mt_filsys, mp->mt_dev,
			    statfsbuf.f_bfree, statfsbuf.f_blocks,
			    100 * statfsbuf.f_bfree / statfsbuf.f_blocks);
	}
	fclose(fptr);
	free(mp);
#endif
#if defined(SVR4) && !defined(sgi)
	/* SVR4 method of reading mounted filesystem table */
	if ((fptr = fopen(MNTTAB, "r")) == NULL) {
	    free(mp);
	    return(basedir);
	}
        while (getmntent(fptr, mp) == 0) {
            /*
             * Don't allow read only file systems
             */
/*	    if (hasmntopt(mp, MNTOPT_RO)) */
            if (strstr(mp->mnt_mntopts, MNTOPT_RO))
                continue;
 
            /*
             * We're not allowing NFS file systems anymore.  Nyaaa!
             * (But maybe when network licensing is widely implemented,
             * we'll put it back in...)
             *
             * While we're at it, also throw out entries that have
             * types of "ignore" (automounter), "pcfs", "swap", and "lo".
            if ((strcmp(mp->mnt_fstype, "nfs") == 0) ||
                (strcmp(mp->mnt_fstype, "pcfs") == 0) ||
                (strcmp(mp->mnt_fstype, "swap") == 0) ||
                (strcmp(mp->mnt_fstype, "fd") == 0) ||
		(strcmp(mp->mnt_fstype, "tmpfs") == 0) ||
                (strcmp(mp->mnt_fstype, "proc") == 0) ||
                (strcmp(mp->mnt_fstype, "lo") == 0))
                continue;
             */

	    /*
	     * It might be easier just to do this.
	     */
	    if (strcmp(mp->mnt_fstype, "ufs"))
		continue;
 
            /*
             * Make sure we can stat the filesystem.
             */
            if (statvfs(mp->mnt_mountp, &statfsbuf))
                continue;
 
	    if (statfsbuf.f_frsize) {
		factor = statfsbuf.f_frsize / 512;
                statfsbuf.f_bfree *= factor;
                statfsbuf.f_blocks *= factor;
                statfsbuf.f_bavail *= factor;
	    }

            if (strcmp(mp->mnt_fstype, "ufs") == 0)
                pctfree = (1000 * statfsbuf.f_bfree) / (9 * statfsbuf.f_blocks)
;
            else
                pctfree = 100 * statfsbuf.f_bfree / statfsbuf.f_blocks;
 
            if (statfsbuf.f_bfree  > maxfree) {
                maxfree = statfsbuf.f_bfree;
                strcpy(maxfsys, mp->mnt_mountp);
            }
 
            PRINT "\n%-30.30s %-22.22s %7d/%7d %7d%%",
                                mp->mnt_mountp, mp->mnt_special,
                                statfsbuf.f_bfree, statfsbuf.f_blocks,
                                pctfree);
        }
	fclose(fptr);
	free(mp);
#endif
/* HP added in the list -- MVR 30 Apr 1994 */
#if defined(SunOS_4) || defined(sgi)  || defined(HP_UX)
	/* SunOS method of reading mounted filesystem table */
	if ((fptr = fopen(MOUNTED, "r")) == NULL) {
	    free(mp);
	    return(basedir);
	}
	maxfree = 0;
	while ((mp = getmntent(fptr)) != NULL) {
	    /*
	     * Don't allow read only file systems
	     */
	    if (hasmntopt(mp, MNTOPT_RO))
		continue;

	    /*
	     * We're not allowing NFS file systems anymore.  Nyaaa!
	     * (But maybe when network licensing is widely implemented,
	     * we'll put it back in...)
	     */
#  ifdef SunOS_4
	    /*
	     * While we're at it, also throw out entries that have
	     * types of "ignore" (automounter), "pcfs", "swap", and "lo".
	     */
	    if ((strcmp(mp->mnt_type, MNTTYPE_NFS) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_PC) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_SWAP) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_IGNORE) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_LO) == 0))
		continue;

	    /*
	     * Make sure we can stat the filesystem.
	     */
	    if (statfs(mp->mnt_dir, &statfsbuf))
		continue;

	    factor = statfsbuf.f_bsize / 512;
	    statfsbuf.f_bfree *= factor;
	    statfsbuf.f_blocks *= factor;
	    statfsbuf.f_bavail *= factor;
	
	    if (strcmp(mp->mnt_type, MNTTYPE_42) == 0) 
		pctfree = (1000 * statfsbuf.f_bavail) / (9 * statfsbuf.f_blocks);
	    else	
		pctfree = 100 * statfsbuf.f_bavail / statfsbuf.f_blocks;

	    if (statfsbuf.f_bavail > maxfree) {
		maxfree = statfsbuf.f_bavail;
		strcpy(maxfsys, mp->mnt_dir);
	    }

	    PRINT "\n%-30.30s %-22.22s %7d/%7d %7d%%",
				mp->mnt_dir, mp->mnt_fsname,
				statfsbuf.f_bavail, statfsbuf.f_blocks,
				pctfree);
	}
#  endif
/* ifdef HP added here -- MVR 30 Apr 1994 */
#  ifdef HP_UX
	    /*
	     * Things to disallow in HP are 
	     * types of "ignore" (automounter), "swapfs", "swap",.
	     * "pc" and "lo" are not applicable for HP -- MVR 30 Apr 1994
	     */
	    if ((strcmp(mp->mnt_type, MNTTYPE_NFS) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_SWAP) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_IGNORE) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_SWAPFS) == 0))
		continue;

	    /*
	     * Make sure we can stat the filesystem.
	     */
	    if (statfs(mp->mnt_dir, &statfsbuf))
		continue;

	    factor = statfsbuf.f_bsize / 512;
	    statfsbuf.f_bfree *= factor;
	    statfsbuf.f_blocks *= factor;
	    statfsbuf.f_bavail *= factor;
	
	    /* in case of availability of large free block 1000 * <number> will
	     * exceed the int limit. This is aggravated by fact that always we
	     * bring the unit in to 512 byte blocks. go for unsigned long
	     * casting -- MVR 7 May 1994 
	    */
	    if (strcmp(mp->mnt_type, MNTTYPE_HFS) == 0) 
		pctfree = (1000 * (unsigned long ) statfsbuf.f_bavail) /  (9 * (unsigned long) statfsbuf.f_blocks);
	    else	
		pctfree = 100 * statfsbuf.f_bavail / statfsbuf.f_blocks;

	    if (statfsbuf.f_bavail > maxfree) {
		maxfree = statfsbuf.f_bavail;
		strcpy(maxfsys, mp->mnt_dir);
	    }

	    PRINT "\n%-30.30s %-22.22s %7d/%7d %7d%%",
				mp->mnt_dir, mp->mnt_fsname,
				statfsbuf.f_bavail, statfsbuf.f_blocks,
				pctfree);
	}
#  endif
#  ifdef sgi
	    /*
	     * In IRIX, the list of things to disallow is:
	     *   NFS, PIPE, SOCKET, DBG
	     */
	    if ((strcmp(mp->mnt_type, MNTTYPE_NFS) == 0) ||
#    ifndef SVR4
		(strcmp(mp->mnt_type, MNTTYPE_PIPE) == 0) ||
#    else
		(strcmp(mp->mnt_type, MNTTYPE_PROC) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_MFS) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_PC) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_SWAP) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_IGNORE) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_LO) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_DOS) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_FD) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_AFS) == 0) ||
#    endif
		(strcmp(mp->mnt_type, MNTTYPE_SOCKET) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_DBG) == 0))
		continue;

	    /*
	     * Make sure we can stat the filesystem.
	     */
	    if (statfs(mp->mnt_dir, &statfsbuf, sizeof(struct statfs), 0))
		continue;

	    if (statfsbuf.f_bfree > maxfree) {
		maxfree = statfsbuf.f_bfree;
		strcpy(maxfsys, mp->mnt_dir);
	    }

	    PRINT "\n%-30.30s %-22.22s %7d/%7d %7d%%",
			    mp->mnt_dir, mp->mnt_fsname,
			    statfsbuf.f_bfree, statfsbuf.f_blocks,
			    100 * statfsbuf.f_bfree / statfsbuf.f_blocks);
	}
#  endif
	fclose(fptr);
	free(mp);
#endif
#ifdef OSF
	maxfree = 0;
	for (i = 0, mp = sfbuf; i < entries; i++, mp++) {
	    /*
	     * Don't allow read only file systems
	     */
	    if (mp->f_flags & M_RDONLY)
		continue;

	    /*
	     * We're not allowing NFS file systems anymore.  Nyaaa!
	     * (But maybe when network licensing is widely implemented,
	     * we'll put it back in...)
	     */
	    if ((mp->f_type == MOUNT_NFS) || (mp->f_type == MOUNT_PC))
		continue;

	    mp->f_bfree *= 2;
	    mp->f_blocks *= 2;
	    mp->f_bavail *= 2;
	
	    pctfree = 100 * mp->f_bfree / mp->f_blocks;

	    if (mp->f_bfree  > maxfree) {
		maxfree = mp->f_bfree;
		strcpy(maxfsys, mp->f_mntonname);
	    }

	    PRINT "\n%-30.30s %-22.22s %7d/%7d %7d%%",
				mp->f_mntonname, mp->f_mntfromname,
				mp->f_bavail, mp->f_blocks,
				pctfree);
	}
	free(sfbuf);
#endif

	if (!maxfree)
	    return(basedir);	/* search yields nothing */

	PRINT "\n");
	PRINT dashes);
	if (shared)
	    PRINT "\nKey in the location of the shared root directory (currently \"%s\") [%s]: ",
		    sharedfs, sharedfs);
	else
	    PRINT "\nKey in the directory name (currently \"%s\") [%s]: ",
			    basedir, maxfsys);
	gets(mntchosen);

	if (*mntchosen == '\0')
	    strcpy(mntchosen, shared ? sharedfs : maxfsys);

	if (stat(mntchosen, &statbuf) || !S_ISDIR(statbuf.st_mode)) {
	    PRINT "Invalid directory %s. Try again.\n", mntchosen);
	    PRINT "\nPress <RETURN> to continue: ");
	    gets(mntchosen);
	} else
	    break;
    }

    strcpy(basedir, mntchosen);
    strcpy(mountpoint, GetMountPoint(basedir));

    if (shared) {
	    strcpy(sharedfs, basedir);
	    strcat(basedir, "/usr");
    }
    sprintf(mntchosen, "%s/tmp", mountpoint);
    if ((makedir(mntchosen, 040777, 0, 0)) < 0)
	    PRINT "Cannot create directory %s.\n", mntchosen);

    if (makenode)
	    getmakenodedir();

    return(basedir);
}
#endif

#ifdef _AIX
/*
 * show the user the available filesystems and prompt for which file system
 * should be used for loading software to.
 */
char    *fsys_choose()
{
    int         maxfree;
    char        maxfsys[STRSIZ], mntchosen[STRSIZ];
    char        *obptr, *stubptr, *tptr;
    struct vmount *vbuf, *vptr;
    int         size = 1024, result;
    int         factor, pctfree, i;
    extern int  statfs();

    if ((tptr = malloc(size)) == NULL)
        return(basedir);
    vbuf = (struct vmount *)tptr;

    result = mntctl(MCTL_QUERY, size, vbuf);
    if (result < 0)
        return(basedir);
    else if (result == 0) {
        size = *(ulong *)vbuf;
        tptr = realloc(vbuf, size);
        vbuf = (struct vmount *)tptr;
        result = mntctl(MCTL_QUERY, size, vbuf);
    }

    for (;;) {
        PRINT "\033[H\033[JAvailable file systems to download to:\n");
        PRINT dashes);
        PRINT "\nFile System                   Device                 Free/Total Blocks  %% Free\n");
        PRINT dashes);

        maxfree = 0;

        result = mntctl(MCTL_QUERY, size, vbuf);
        for (i = 0,vptr = vbuf; i < result; i++, tptr += vptr->vmt_length,vptr=(struct vmount *)tptr) {
            /*
             * In "traditional" parlance, the "OBJECT" is the special
             * device node used to access the file system, and the "STUB"
             * is the mount point.
             */
            obptr = vmt2dataptr(vptr, VMT_OBJECT);
            stubptr = vmt2dataptr(vptr, VMT_STUB);

            /*
             * Don't allow read only file systems
             */
            if (vptr->vmt_flags & MNT_READONLY)
                continue;

            /*
             * We're not allowing NFS file systems anymore.  Nyaaa!
             * (But maybe when network licensing is widely implemented,
             * we'll put it back in...)
             */
            if (vptr->vmt_gfstype == MNT_NFS)
                continue;

            /*
             * Make sure we can stat the filesystem.
             */

            if (statfs(stubptr, &statfsbuf))
                continue;

            factor = statfsbuf.f_bsize / 512;
            statfsbuf.f_bfree *= factor;
            statfsbuf.f_blocks *= factor;
            statfsbuf.f_bavail *= factor;

            pctfree = 100 * statfsbuf.f_bavail / statfsbuf.f_blocks;

            if (statfsbuf.f_bavail  > maxfree) {
                maxfree = statfsbuf.f_bavail;
                strcpy(maxfsys, stubptr);
            }

            PRINT "\n%-30.30s %-22.22s %7d/%7d %7d%%", stubptr, obptr,
                statfsbuf.f_bavail, statfsbuf.f_blocks, pctfree);
        }
        if (!maxfree)
                return(basedir);        /* search yields nothing */

        PRINT "\n");
        PRINT dashes);
        if (shared)
	    PRINT "\nKey in the location of the shared root directory (currently \"%s\") [%s]: ",
                        sharedfs, sharedfs);
        else
	    PRINT "\nKey in the directory name (currently \"%s\") [%s]: ",
                        basedir, maxfsys);
        gets(mntchosen);

        if (*mntchosen == NULL)
                strcpy(mntchosen, shared ? sharedfs : maxfsys);

        if (stat(mntchosen, &statbuf) || !S_ISDIR(statbuf.st_mode)) {
            PRINT "Invalid directory %s. Try again.\n", mntchosen);
            PRINT "\nPress <RETURN> to continue: ");
            gets(mntchosen);
        } else
            break;
    }

    strcpy(basedir, mntchosen);
    strcpy(mountpoint, GetMountPoint(basedir));

    if (shared) {
        strcpy(sharedfs, basedir);
        strcat(basedir, "/usr");
    }
    sprintf(mntchosen, "%s/tmp", mountpoint);
    if ((makedir(mntchosen, 040777, 0, 0)) < 0)
        PRINT "Cannot create directory %s.\n", mntchosen);

    if (makenode)
        getmakenodedir();

    return(basedir);
}
#endif


/*
 * This routine checks to determine if the file system where the ws
 * stuff resides is mounted and returns success(0) or failure(1). It is 
 * used in "main" to determine if one can proceed with the installation 
 * or not.
 */
#if !defined(SVR4) && !defined(sgi)
char	*ws_mount_check(dir)
char	*dir;
{
    char	*fs;

    fs = GetMountPoint(dir);
    /*
     * make sure we have write access to the file system
     */
#if defined(SVR3) || defined(sgi)
    if (statfs(fs, &statfsbuf, sizeof(struct statfs), 0))
#else
    if (statfs(fs, &statfsbuf))
#endif
    {
	PRINT "\"%s\" file system not mounted!\n", fs);
	LPRINT "\"%s\" file system not mounted!\n", fs);
	return(NULL);
    }
    if (access(fs, W_OK)) {
	PRINT "Cannot write to \"%s\" file system!\n", fs);
	LPRINT "Cannot write to \"%s\" file system!\n", fs);
	return(NULL);
    }
    return(fs);
}
#else
char	*ws_mount_check(dir)
char	*dir;
{
    char	*fs;

    fs = GetMountPoint(dir);
    /*
     * make sure we have write access to the file system
     */
#if defined(SVR4) && defined(sgi)
    if (statfs(fs, &statfsbuf, sizeof(struct statfs), 0))
#else
    if (statvfs(fs, &statfsbuf))
#endif
    {
	PRINT "\"%s\" file system not mounted!\n", fs);
	LPRINT "\"%s\" file system not mounted!\n", fs);
	return(NULL);
    }
    if (access(fs, W_OK)) {
	PRINT "Cannot write to \"%s\" file system!\n", fs);
	LPRINT "Cannot write to \"%s\" file system!\n", fs);
	return(NULL);
    }
    return(fs);
}
#endif


/*
 * This routine determines the number of free blocks existing on the file
 * system whose device description is given in "path".
 */
#if !defined(SVR4) && !defined(sgi)
int	num_free_blks(path)
char	*path;
{
#  if defined(SVR3) || defined(sgi)
    if (statfs(path, &statfsbuf, sizeof(struct statfs), 0))
	return(-1);
#  else
    if (statfs(path, &statfsbuf))
	return(-1);
#  endif

#  if defined(SYSV)
	return(statfsbuf.f_bfree);
#  elif defined(OSF)
	return(statfsbuf.f_bfree * 2);
#  else
	return(statfsbuf.f_bavail * (statfsbuf.f_bsize / 512));
#  endif
}
#else
int	num_free_blks(path)
char	*path;
{
#ifdef sgi
    if (statfs(path, &statfsbuf, sizeof(struct statfs), 0))
	return(-1);
#else
    if (statvfs(path, &statfsbuf))
	return(-1);
#endif

    if (statfsbuf.f_frsize)
	return(statfsbuf.f_bfree * (statfsbuf.f_frsize / 512));
    else
	return(statfsbuf.f_bfree);
    
}
#endif
/*
 * This routine determines whether or not "blkcnt" + FREBLK_MARGIN number
 * of free blocks are available on the given file system. It returns
 * 0 if there are at least the desired number of free blocks on the
 * device in question and returns 1 if there is not sufficient 
 * free space.
 */
#define FREBLK_MARGIN	100  /*#of free blocks over what needed*/

int	free_space_check(path, pptr, when)
char	*path;
struct prodnode	*pptr;
int	when;
{
    register int	numfreeblks;
    static int	lastcount = 0;

    numfreeblks = num_free_blks(path);
    if (when) {
	if (verbose)
	    PRINT "VERBOSE: Change in space on %s: %d blocks.\n",
			    path, lastcount - numfreeblks);
	LPRINT "Change in space on %s: %d blocks.\n", path, lastcount - numfreeblks);
    } else if (numfreeblks >= 0) {
	if (verbose)
	    PRINT "VERBOSE: Available free space on %s: %d blocks.\n",
			    path, numfreeblks);
	LPRINT "Available free space on %s: %d blocks.\n", path, numfreeblks);
    }

    lastcount = numfreeblks;

    /*
     * if its a new product, then we better make sure it fits. Otherwise
     * we'll assume that it fits by nature of the fact that it was loaded
     * once already.
     */
    if ((pptr->pstat & 0xf) != NEW ||
	    (numfreeblks > (pptr->blocksize / (makenode ? 2 : 1)) + FREBLK_MARGIN))
	return(0);          /*success*/

    return(1);
}

#if defined(SVR3) || defined(sgi)
int	mountfs(dev, dir, ro)
char	*dev, *dir;
int	ro;
{
    int		mflag;
    int		fstyp;
#ifdef sgi
    char	*fstypes[3] = { "iso9660", "efs", ""};
    char        command[160], buf[160];
    int         mount_error;
    FILE        *sfd;
    char        mdev[64], mpoint[64], mtype[64], mflags[64], mcheck[4], mseq[4];
#elif defined(clipper) || defined(__clipper__)
    char	*fstypes[5] = { "FFS", "CDFS", "S51K", ""};
#elif defined(SCO)
    char	*fstypes[5] = { "HS", "EFS", "S51K", "S52K", ""};
#endif
    int		fsindex, success, result;
    struct	statfs sfsbuf;
    char	type[16];

    mflag = (ro ? MS_FSS | 1 : MS_FSS);

    success = 0;
    fsmounted = 0;
	
    for (fsindex = 0; *fstypes[fsindex] != '\0' && !success &&
	 !fsmounted; fsindex++) {
#ifdef sgi
        if (fsindex == 0) {
            sfd = fopen("/etc/mtab", "r");
            while (fscanf(sfd,"%s %s %s %s %s %s\n",
                mdev, mpoint, mtype, mflags, mcheck, mseq) != EOF) {
                if ((strcmp(dev, mdev) == 0) && (strcmp(dir, mpoint) == 0)) {
                    fsmounted++;
                    if (strcmp(mtype, "iso9660") == 0) {
                        iso_9660 = 1;
                        putenv("ISO9660=Y");
                    }
                    fclose(sfd);
                    break;
                }
            }

            if (!fsmounted) {
                sprintf(command, "/etc/mount -t %s %s %s",
                                fstypes[fsindex], dev, dir);
                mount_error = 0;
                if ((sfd = popen(command, "r")) != NULL) {
                    while (fgets(buf, sizeof(buf), sfd) != NULL) {
                        mount_error = 1;
                    }
                    pclose(sfd);
                }

                if (mount_error) {
                    continue;
                }
                else {
                    success++;
                    if (strcmp(fstypes[fsindex], "iso9660") == 0) {
                        iso_9660 = 1;
                        putenv("ISO9660=Y");
                    }
                    break;
                }
            }
        }
        else {
#endif
	fstyp = sysfs(GETFSIND, fstypes[fsindex]);
	if (mount(dev, dir, mflag, fstyp, 0, 0)) {
	    if (errno == EBUSY) {
		/* already mounted */
		fsmounted++;
		statfs(dir, &sfsbuf, sizeof(struct statfs), 0);
		sysfs(GETFSTYP, sfsbuf.f_fstyp, type);
		if ((strncmp(type, "CDFS", 4) == 0) ||
		    (strcmp(type, "HS") == 0)) {
                    iso_9660 = 1;
                    putenv("ISO9660=Y");
		}
		break;
	    }
	}
	else {
	    success++;
	    if (strcmp(fstypes[fsindex], "CDFS") == 0 ||
		strcmp(fstypes[fsindex], "HS") == 0) {
		/* Set flags that we're ISO9660  */
		iso_9660 = 1;
		putenv("ISO9660=Y");
	    }
	    break;
	}
    }
#ifdef sgi
    }
#endif
    if (*fstypes[fsindex] != '\0') {
	return(0);
    }
    else {
	PRINT "Cannot mount %s on %s\n", dev, dir);
	LPRINT "Cannot mount %s on %s\n", dev, dir);
	return(-1);
    }
}
#endif

#if defined(SVR4) && !defined(sgi)
int	mountfs(dev, dir, ro)
char	*dev, *dir;
int	ro;
{
    int		mflag;
    int		fstyp;
    char	*fstypes[5] = { "ufs", "hsfs", "", ""};
    int		fsindex, success, result;
    struct	statvfs sfsbuf;
    char	type[16];

    mflag = (ro ? MS_FSS | 1 : MS_FSS);

    success = 0;
    fsmounted = 0;
	
    for (fsindex = 0; *fstypes[fsindex] != '\0'; fsindex++) {
	fstyp = sysfs(GETFSIND, fstypes[fsindex]);
	if (mount(dev, dir, mflag, fstyp, 0, 0)) {
	    if (errno == EBUSY) {
		/* already mounted */
		fsmounted++;
		statvfs(dir, &sfsbuf);
		if (strncmp(sfsbuf.f_basetype, "hsfs", 4) == 0) {
                    iso_9660 = 1;
                    putenv("ISO9660=Y");
		}
		break;
	    }
	}
	else {
	    success++;
	    if (strcmp(fstypes[fsindex], "hsfs") == 0) {
		/* Set flags that we're ISO9660  */
		iso_9660 = 1;
		putenv("ISO9660=Y");
	    }
	    break;
	}
    }
    if (*fstypes[fsindex] != '\0') {
	return(0);
    }
    else {
	PRINT "Cannot mount %s on %s\n", dev, dir);
	LPRINT "Cannot mount %s on %s\n", dev, dir);
	return(-1);
    }
}
#endif

/* ifdef HP added for HP port -- MVR 30 Apr 1994 */
#ifdef HP_UX
int	mountfs(dev, dir, ro)
char	*dev, *dir;
int	ro;
{
    /* changed hsfs to cdfs and 42 to HFS -- MVR  30 Apr 1994 */
    static char	*fstypes[3] = { MNTTYPE_HFS, MNTTYPE_CDFS, "" };
    int		mflag;
    int		fsindex, success;
    /* ufs_args can be used for cdfs and hfs(ufs) -- MVR 5 May 94 */
    struct ufs_args mnt_opts;
    struct mntent me;
    struct mntent *mp;
    FILE	*mf;
    /* New definitions added. fscodes will have the fstype code of
     * the filesystems listed in fstypes -- 5 May 1994 
    */
    static long	fscodes[2] = { MOUNT_UFS, MOUNT_CDFS };
    struct stat statbuff;
    struct statfs chkbuf;

    mflag = (ro ? M_RDONLY : 0);

    mnt_opts.fspec = dev;
 
    success = 0;
 
    for (fsindex = 0; *fstypes[fsindex] != NULL; fsindex++) {
    	/* First check to see if the device dev can be used to mount 
	 * the filesystem found at fstypes[fsindex]. if not let's not 
	 * proceed  with mounting.  -- MVR 5 May 1994
	*/
    	if (statfsdev(dev, &chkbuf))
    	{
	PRINT "Cannot mount %s on %s\n", dev, dir);
	LPRINT "Cannot mount %s on %s\n", dev, dir);
	return(-1);
    	}
    	else {
		if (chkbuf.f_fsid[1] != fscodes[fsindex])
			continue;
	}
	/* goahead and mount!.  Let's use vfsmount to specify the
	 * filesystem type -- MVR 5 May 1994
	*/
	if (vfsmount(fscodes[fsindex], dir, mflag, (caddr_t) &mnt_opts) < 0) {
	    if (errno == EBUSY) {
		fsmounted++;
		/* How can we see if the device has an ISO9660 file
		 * system on it? 
		 */
		mf = setmntent(MOUNTED, "r");
		while (mp = getmntent(mf)) {
		    if ((strcmp(dir, mp->mnt_dir) == 0) && 
				(strcmp(mp->mnt_type, MNTTYPE_CDFS) == 0)) {
			iso_9660 = 1;
			putenv("ISO9660=Y");
		    }
		}
		endmntent(mf);
                break;
	    }
	}
	else {
	    success++;

	/* two ways of updating /etc/mnttab -- MVR 2 Jun 1994 */	
#ifdef	DONT_USE_FORK
	    /* unless we want to avoid a fork we can replace this segment
	       with system() call MVR 2 Jun 1994
	    */
	    mf = setmntent(MOUNTED, "a+");

	    mp = (struct mntent *)malloc(sizeof(struct mntent));
	    mp->mnt_fsname = dev;
	    mp->mnt_dir = dir;
	    mp->mnt_type = fstypes[fsindex];
	    mp->mnt_opts = ro ? MNTOPT_RO : "";
	    mp->mnt_freq = 0;
	    mp->mnt_passno = 0;
	    /* We need to fill the mnt_time and mnt_cnode before we can 
	     * make an entry in /etc/mnttab. -- MVR 5 May 1994
	    */
	    stat(dir, &statbuff);
	    mp->mnt_time = statbuff.st_mtime;
	    mp->mnt_cnode = statbuff.st_cnode;
	    
	    addmntent(mf, mp);
	    endmntent(mf);
	    free(mp);
#else	/* can use fork ! */
	    system("/etc/mount -u 2>&1 > /dev/null");
#endif

	    if (strcmp(fstypes[fsindex], MNTTYPE_CDFS) == 0) {
		iso_9660 = 1;
		putenv("ISO9660=Y");
	    }
	    break;
        }
    }
 
    if (*fstypes[fsindex] != NULL)
	return(0);
    else {
	PRINT "Cannot mount %s on %s\n", dev, dir);
	LPRINT "Cannot mount %s on %s\n", dev, dir);
	return(-1);
    }
}

unmountfs(dir)
char *dir;
{
    struct mntent *mp, *mpa[NMOUNT];
    int		i, lastentry;
    FILE *mf;

   /* using  umount for HP -- MVR 30 Apr 1994 */
    if (umount(dir) == 0) {

	/* update /etc/mnttab */
	/*  two ways of updating /etc/mnttab ! -- MVR 2 jun 1994 */
#ifdef	DONT_USE_FORK
	mf = setmntent(MOUNTED, "r");

	/* Read all the entries in */
	lastentry = 0;
	while (mp = getmntent(mf)) {
	    mpa[lastentry] = (struct mntent *)malloc(sizeof(struct mntent));

	    /* Since the first 4 fields are just pointers
	     * instead of full arrays, we have to allocate our own
	     * space for them...
	     */

	    if (mpa[lastentry]->mnt_fsname = (char *)malloc(strlen(mp->mnt_fsname)+1))
		strcpy(mpa[lastentry]->mnt_fsname, mp->mnt_fsname);

	    if (mpa[lastentry]->mnt_dir = (char *)malloc(strlen(mp->mnt_dir)+1))
		strcpy(mpa[lastentry]->mnt_dir, mp->mnt_dir);

	    if (mpa[lastentry]->mnt_type = (char *)malloc(strlen(mp->mnt_type)+1))
		strcpy(mpa[lastentry]->mnt_type, mp->mnt_type);
	    
	    if (mpa[lastentry]->mnt_opts = (char *)malloc(strlen(mp->mnt_opts)+1))
		strcpy(mpa[lastentry]->mnt_opts, mp->mnt_opts);
	    
	    mpa[lastentry]->mnt_freq = mp->mnt_freq;
	    mpa[lastentry]->mnt_passno = mp->mnt_passno;
	    /* Also read the mnt_time and mnt_cnode entries -- MVR 5 May 94 */
	    mpa[lastentry]->mnt_time = mp->mnt_time;
	    mpa[lastentry]->mnt_cnode = mp->mnt_cnode;
	    
	    lastentry++;
	}

	endmntent(mf);
	mf = setmntent(MOUNTED, "w+");

	/* Write all the entries out except for the one we unmounted. */
	for (i = 0; i < lastentry; i++) {
	    if (strcmp(dir, mpa[i]->mnt_dir) != 0)
		addmntent(mf, mpa[i]);

	    free(mpa[i]->mnt_fsname);
	    free(mpa[i]->mnt_dir);
	    free(mpa[i]->mnt_type);
	    free(mpa[i]->mnt_opts);
	    free(mpa[i]);
	}
	endmntent(mf);
#else /* we can use fork !! */
	system("/etc/mount -u 2>&1 > /dev/null");
#endif
	return(0);
    }
    else
	return(-1);
}
#endif
#ifdef SunOS_4
int	mountfs(dev, dir, ro)
char	*dev, *dir;
int	ro;
{
    static char	*fstypes[5] = { MNTTYPE_42, "hsfs", "" };
    int		mflag;
    int		fsindex, success;
    struct ufs_args mnt_opts;
    struct mntent me;
    struct mntent *mp;
    FILE	*mf;

    mflag = M_NEWTYPE | (ro ? M_RDONLY : 0);

    mnt_opts.fspec = dev;
 
    success = 0;
 
    for (fsindex = 0; *fstypes[fsindex] != NULL; fsindex++) {
	if (mount(fstypes[fsindex], dir, mflag, &mnt_opts) < 0) {
	    if (errno == EBUSY) {
		fsmounted++;
		/* How can we see if the device has an ISO9660 file
		 * system on it? 
		 */
		mf = setmntent(MOUNTED, "r");
		while (mp = getmntent(mf)) {
		    if ((strcmp(dir, mp->mnt_dir) == 0) && 
				(strcmp(mp->mnt_type, "hsfs") == 0)) {
			iso_9660 = 1;
			putenv("ISO9660=Y");
		    }
		}
		endmntent(mf);
                break;
	    }
	}
	else {
	    success++;

	    mf = setmntent(MOUNTED, "a+");

	    mp = (struct mntent *)malloc(sizeof(struct mntent));
	    mp->mnt_fsname = dev;
	    mp->mnt_dir = dir;
	    mp->mnt_type = fstypes[fsindex];
	    mp->mnt_opts = ro ? MNTOPT_RO : "";
	    mp->mnt_freq = 0;
	    mp->mnt_passno = 0;
	    
	    addmntent(mf, mp);
	    endmntent(mf);
	    free(mp);

	    if (strcmp(fstypes[fsindex], "hsfs") == 0) {
		iso_9660 = 1;
		putenv("ISO9660=Y");
	    }
	    break;
        }
    }
 
    if (*fstypes[fsindex] != NULL)
	return(0);
    else {
	PRINT "Cannot mount %s on %s\n", dev, dir);
	LPRINT "Cannot mount %s on %s\n", dev, dir);
	return(-1);
    }
}

unmountfs(dir)
char *dir;
{
    struct mntent *mp, *mpa[NMOUNT];
    int		i, lastentry;
    FILE *mf;

    if (unmount(dir) == 0) {
	mf = setmntent(MOUNTED, "r");

	/* Read all the entries in */
	lastentry = 0;
	while (mp = getmntent(mf)) {
	    mpa[lastentry] = (struct mntent *)malloc(sizeof(struct mntent));

	    /* Since the first 4 fields are just pointers
	     * instead of full arrays, we have to allocate our own
	     * space for them...
	     */

	    if (mpa[lastentry]->mnt_fsname = (char *)malloc(strlen(mp->mnt_fsname)+1))
		strcpy(mpa[lastentry]->mnt_fsname, mp->mnt_fsname);

	    if (mpa[lastentry]->mnt_dir = (char *)malloc(strlen(mp->mnt_dir)+1))
		strcpy(mpa[lastentry]->mnt_dir, mp->mnt_dir);

	    if (mpa[lastentry]->mnt_type = (char *)malloc(strlen(mp->mnt_type)+1))
		strcpy(mpa[lastentry]->mnt_type, mp->mnt_type);
	    
	    if (mpa[lastentry]->mnt_opts = (char *)malloc(strlen(mp->mnt_opts)+1))
		strcpy(mpa[lastentry]->mnt_opts, mp->mnt_opts);
	    
	    mpa[lastentry]->mnt_freq = mp->mnt_freq;
	    mpa[lastentry]->mnt_passno = mp->mnt_passno;
	    
	    lastentry++;
	}

	endmntent(mf);
	mf = setmntent(MOUNTED, "w+");

	/* Write all the entries out except for the one we unmounted. */
	for (i = 0; i < lastentry; i++) {
	    if (strcmp(dir, mpa[i]->mnt_dir) != 0)
		addmntent(mf, mpa[i]);

	    free(mpa[i]->mnt_fsname);
	    free(mpa[i]->mnt_dir);
	    free(mpa[i]->mnt_type);
	    free(mpa[i]->mnt_opts);
	    free(mpa[i]);
	}
	endmntent(mf);
	return(0);
    }
    else
	return(-1);
}
#endif

#ifdef _AIX
int	mountfs(dev, dir, ro)
char	*dev, *dir;
int	ro;
{
    static char	fstypes[5] = { MNT_JFS, MNT_CDROM, MNT_AIX, -1 };
    int		mflag, result;
    int		fsindex, success;
    int		size, i;
    struct vmount *vptr, *vbuf;

    mflag = (ro ? MNT_READONLY : 0);

    size = strlen(dev) + strlen(dir) + sizeof(struct vmount);

    if ((vptr = (struct vmount *)malloc(size)) == NULL) {
	return(-1);
    }
 
    vptr->vmt_revision = (ulong)VMT_REVISION;
    vptr->vmt_length = size;
    vptr->vmt_flags = mflag;
    vptr->vmt_data[VMT_OBJECT].vmt_off =  sizeof(struct vmount);
    vptr->vmt_data[VMT_OBJECT].vmt_size = strlen(dev);
    vptr->vmt_data[VMT_STUB].vmt_off = sizeof(struct vmount) + strlen(dev);
    vptr->vmt_data[VMT_STUB].vmt_size = strlen(dir);
    for (i = VMT_HOST; i <= VMT_LASTINDEX; i++) {
	vptr->vmt_data[i].vmt_off = 0;
	vptr->vmt_data[i].vmt_size = 0;
    }

    success = 0;
 
    for (fsindex = 0; fstypes[fsindex] != -1; fsindex++) {
	vptr->vmt_gfstype = fstypes[fsindex];
	if (vmount(vptr, size) < 0) {
	    if (errno == EBUSY) {
		fsmounted++;
		/*
		 *  How to find out if we're already mounted as CDROM?
		 *  Look through already mounted file systems.
		 */
		free(vptr);
		size = 1024;
                if ((vbuf = (struct vmount *)malloc(size)) == NULL)
		    return(-1);
    		result = mntctl(MCTL_QUERY, size, vbuf);
		if (result < 0)
		    return(-1);
		else if (result == 0) {
		    size = *(ulong *) vbuf;
		    vbuf = (struct vmount *)realloc(vbuf, size);
		    result = mntctl(MCTL_QUERY, size, vbuf);
		}

		for (vptr=vbuf, i=0; i < result; i++, vptr += vptr->vmt_length){
                    if ((strcmp(dir, vmt2dataptr(vptr, VMT_STUB)) == 0) &&
                                (vptr->vmt_gfstype == MNT_CDROM)) {
                        iso_9660 = 1;
                        putenv("ISO9660=Y");
                    }
                }
                break;
	    }
	}
	else {
	    success++;
	    if (fstypes[fsindex] == MNT_CDROM) {
		iso_9660 = 1;
		putenv("ISO9660=Y");
	    }
	    break;
        }
    }
 
    if (fstypes[fsindex] != -1)
	return(0);
    else {
	PRINT "Cannot mount %s on %s\n", dev, dir);
	LPRINT "Cannot mount %s on %s\n", dev, dir);
	return(-1);
    }
}
#endif

#ifdef OSF
int	mountfs(dev, dir, ro)
char	*dev, *dir;
int	ro;
{
    #define MOUNT_CDFS	99
    int		fstypes[] = { MOUNT_UFS, MOUNT_FFS, MOUNT_NONE };
    struct ufs_args mnt_opts;
    int		mflag;
    int		fsindex, success;
    struct	statfs	*sfbuf, *mp;
    int		entries, result, i;
    long	bufsiz;

    mflag = (ro ? M_RDONLY : 0);
    success = 0;
 
    for (fsindex = 0; fstypes[fsindex] != 0; fsindex++) {
	if (fstypes[fsindex] == MOUNT_UFS) {
	    mnt_opts.fspec = dev;
	}
	if (mount(fstypes[fsindex], dir, mflag, (caddr_t)&mnt_opts) < 0) {
	    if (errno == EBUSY) {
		fsmounted++;

		/* How can we see if the device has an ISO9660 file
		 * system on it? 
		 */

		entries = getfsstat((struct statfs *)0, 0, 0);
		bufsiz = entries * sizeof(struct statfs);
		sfbuf = (struct statfs *)malloc(bufsiz);

		result = getfsstat(sfbuf, bufsiz, MNT_NOWAIT);

		for (i = 0, mp = sfbuf; i < entries; i++, mp++) {
		    if ((strcmp(dir, mp->f_mntonname) == 0) && 
				(mp->f_type == MOUNT_CDFS)) {
			iso_9660 = 1;
			putenv("ISO9660=Y");
		    }
		}
		free(sfbuf);
                break;
	    }
	}
	else {
	    success++;

	    if (fstypes[fsindex] == MOUNT_CDFS) {
		iso_9660 = 1;
		putenv("ISO9660=Y");
	    }
	    break;
        }
    }
 
    if (fstypes[fsindex] != 0)
	return(0);
    else {
	PRINT "Cannot mount %s on %s\n", dev, dir);
	LPRINT "Cannot mount %s on %s\n", dev, dir);
	return(-1);
    }
}
#endif
