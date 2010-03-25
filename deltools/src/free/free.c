#include	<stdlib.h>
#include	<stdio.h>
#include	<string.h>
#include	<sys/types.h>
#include	<sys/stat.h>
#include	<errno.h>
#if defined (__clipper__) && defined(SecureWare)
#include        <sys/immu.h>
#include        <sys/region.h>
#include        <sys/param.h>
#include        <sys/proc.h>
#include        <sys/inode.h>
#include        <sys/sec/sectypes.h>
#include        <sys/sec/auditsysc.h>
#include        <sys/sec/security.h>
#endif
#ifdef SVR3
#  include	<sys/statfs.h>
#  include	<sys/fstyp.h>
#  include	<sys/fsid.h>
# ifndef sgi
#  include	<mnttab.h>
#  define	MNTTAB	"/etc/mnttab"
# endif
#endif
#ifdef sgi
#  include	<mntent.h>
#  define	NMOUNT	40
#endif
#ifdef SVR4
#  include	<sys/fstyp.h>
#  include	<sys/fsid.h>
#  ifndef sgi
#  include	<sys/statvfs.h>
#  include	<sys/mnttab.h>
#  include	<sys/param.h>
#  else
#  include	<sys/statfs.h>
#  endif
#  define	NMOUNT	40
#endif
#ifdef SunOS_4
#  include	<sys/param.h>
#  include	<sys/vfs.h>
#  include	<mntent.h>
#endif

/* added for HP port --  MVR 2 May 1994 */
#ifdef HP_UX
#  include	<sys/param.h>
#  include	<sys/vfs.h>
#  include	<mntent.h>
/* NMOUNT picked up from MNTHASHSZ system macro -- MVR 2 May 1994 */ 
#  define NMOUNT 32
#endif

#ifdef _AIX
#  include        <sys/statfs.h>
#  include        <sys/mntctl.h>
#  include        <sys/vmount.h>
#  define NMOUNT  64
#endif
#ifdef OSF
#  include	<sys/param.h>
#  include	<sys/mount.h>
#  define NMOUNT  64
#endif

#define PRINT	fprintf(tty,
#define	STRSIZ	128

char	*fslistpath = NULL;
unsigned int	fsli = 0;
struct fslist {
    char	path[STRSIZ];
    char	dev[STRSIZ];
    unsigned long	free_blocks;
    unsigned long	used_blocks;
    unsigned long	claimed_blocks;
} fsl[NMOUNT];

char *dashes="-------------------------------------------------------------------------------\n";
FILE	*tty = stdout;

char    *GetMountPoint(path)
char    *path;
{
    dev_t       dev;
    char        *c;
    int result = 0;
    static char p[STRSIZ];
    extern char *strrchr();
    struct stat statbuf;
    char	tmpbuf[STRSIZ], tmpbuf2[STRSIZ];

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

    if (*p == '\0')             /* No element of the path existed at all */
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

/*
** SCW	1/20/95
**
** One gotcha that can trip us is that we must check the returned
** mount point to see if it's a symbolic link.  This happens on
** SGI systems, where "/var" is symbolically linked to "/usr/var".
** The processing above will say that "/var" is the mount point,
** because stat() will follow the link to /usr.  But then the
** search of the file system table will fail, because there isn't
** a /var in the table.  So what we need to do is follow the symlink
** to find the place where it leads, and use THAT directory with
** GetMountPoint.
**
*/
    lstat(p, &statbuf);
    if (S_ISLNK(statbuf.st_mode)) {
	/*
	** Need to follow the link to see where it really leads.
	*/
	readlink(p, tmpbuf, sizeof(tmpbuf));
	if (*tmpbuf != '/') {
	    strcpy(tmpbuf2, tmpbuf);
	    tmpbuf[0] = '/';
	    tmpbuf[1] = '\0';
	    strcat(tmpbuf, tmpbuf2);
	}
	return(GetMountPoint(tmpbuf));
    }
    else
	return(p);
}


/* HP included in the list --  MVR  2 May 1994 */
#if defined(SYSV) || defined(SunOS_4) || defined(OSF) || defined(HP_UX)
/*
 * show the user the available filesystems and prompt for which file system
 * should be used for loading software to.
 */
char	*showthem(maxonly)
int	maxonly;
{
    int		i = 0, j;
    int		maxfree = 0;

#if defined(clipper) || defined(__clipper__)
    long	total_blocks, free_blocks;
#else
    unsigned long	total_blocks, free_blocks;
#endif
    char	*c, *pathname, *devname;
    char	dev[STRSIZ];
    static char	maxfsys[STRSIZ] = {"/usr"};
    extern int	statfs();
#if defined(SVR3) && !defined(sgi)
    struct statfs	statfsbuf;
    struct mnttab	mp;
    FILE		*fptr = NULL;	/* used to open/read "/etc/mnttab" */
    char		fstype[16];
#endif
#ifdef sgi
    struct statfs	statfsbuf;
    struct mntent	*mp;
    FILE		*fptr = NULL;
#endif
#if defined(SVR4) && !defined(sgi)
    struct statvfs	statfsbuf;
    struct mnttab	mp;
    FILE		*fptr = NULL;
    int			factor = 1;
#endif
/* HP aded along with sun --- MVR 2 May 1994 */
#if defined(SunOS_4) || defined(HP_UX)
    struct statfs	statfsbuf;
    struct mntent	*mp;
    FILE		*fptr = NULL;	/* used to open/read "/etc/mtab" for SUN					   and /etc/mnttab for HP */
    int	factor, pctfree;
#endif
#ifdef OSF
    int entries, pctfree;
    long bufsiz;
    struct statfs *sbuf, *mp;
#endif
    
    if (!fsli) {
#if defined(SYSV) && !defined(sgi)
	if ((fptr = fopen(MNTTAB, "r")) == NULL)
	    return(NULL);
#endif
/* HP added in the list -- MVR 2 May 1994  */
#if defined(SunOS_4) || defined(sgi) || defined(HP_UX)
        if ((fptr = fopen(MOUNTED, "r")) == NULL)
	    return(NULL);
#endif
#ifdef OSF
	entries = getfsstat((struct statfs *)0, 0, 0);
	bufsiz = entries * sizeof(struct statfs);
	sbuf = (struct statfs *)malloc(bufsiz);
	if (getfsstat(sbuf, bufsiz, MNT_NOWAIT) < 0)
	    return(NULL);
	else
	    mp = sbuf;
#endif
    }
    
    if (!maxonly) {
	PRINT "File System\t\tDevice\t\t  Free +    Used = Total Blocks  %% Used\n");
	PRINT dashes);
    }
    for (;;) {
	if (fsli) {
	    if (i >= fsli)
		break;
	    pathname = fsl[i].path;
	    devname = fsl[i].dev;
	    free_blocks = fsl[i].free_blocks - fsl[i].claimed_blocks;
	    total_blocks = fsl[i].used_blocks + fsl[i].free_blocks;
	    ++i;
	} else {
#if defined(SVR3) && !defined(sgi)
	    if (fread(&mp, sizeof(struct mnttab), 1, fptr) != 1)
		break;		/* read err or EOF */

#if defined(__clipper__) || defined(clipper)
	    /* skip automounter entries and proc file systems */
	    if (!mp.mt_fstyp[0] || !strcmp(mp.mt_fstyp, "PROC"))
		continue;
#endif

	    if (statfs(mp.mt_filsys, &statfsbuf, sizeof(struct statfs), 0))
		continue;

#if !defined(clipper) && !defined(__clipper__)
	    /*
	     * Need to determine fstype here because standard SVR3 doesn't
	     * put it in mnttab entry.
	     */
	    if (sysfs(GETFSTYP, statfsbuf.f_fstyp, fstype) < 0)
		continue;
	    if (strcmp(fstype, "PROC") == 0 || strcmp(fstype, "DUFST") == 0)
		continue;
#endif

	    pathname = mp.mt_filsys;
	    devname = mp.mt_dev;
	    free_blocks = statfsbuf.f_bfree;
	    total_blocks = statfsbuf.f_blocks;
#endif
#ifdef sgi
            if ((mp = getmntent(fptr)) == NULL)
                break;

            /*
             * Skip any file system that's not the EFS
             * (extent file system) or BELL (S51K) file system
             */
#  ifdef SVR4
	    if (strcmp(mp->mnt_type, MNTTYPE_EFS))
		continue;
#  else
            if (strcmp(mp->mnt_type, MNTTYPE_EFS) &&
                strcmp(mp->mnt_type, MNTTYPE_BELL))
                continue;
#  endif

            if (statfs(mp->mnt_dir, &statfsbuf, sizeof(struct statfs), 0))
                continue;

	    pathname = mp->mnt_dir;
	    devname = mp->mnt_fsname;
	    free_blocks = statfsbuf.f_bfree;
	    total_blocks = statfsbuf.f_blocks;

#endif
#if defined(SVR4) && !defined(sgi)
	    if (getmntent(fptr, &mp) != 0)	/* EOF or read error */
		break;

	    if (strcmp(mp.mnt_fstype, "ufs"))
		continue;

	    if (statvfs(mp.mnt_mountp, &statfsbuf)) 
	        continue;

	    pathname = mp.mnt_mountp;
	    devname = mp.mnt_special;

	    if (statfsbuf.f_frsize) {
		factor = statfsbuf.f_frsize / 512 ;
		statfsbuf.f_bfree *= factor;
		statfsbuf.f_blocks *= factor;
		statfsbuf.f_bavail *= factor;
	    }

	    pathname = mp.mnt_mountp;
	    devname = mp.mnt_special;
	    free_blocks = statfsbuf.f_bfree;
	    total_blocks = statfsbuf.f_blocks;
#endif

#ifdef SunOS_4
	    if ((mp = getmntent(fptr)) == NULL)
		break;

	    /*
	     * Skip any file system that's marked "ignore", 
	     * and the special swap, pc,  and loopback file systems
	     */
	    if ((strcmp(mp->mnt_type, MNTTYPE_IGNORE) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_SWAP) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_PC) == 0) ||
		(strcmp(mp->mnt_type, "tmp") == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_LO) == 0))
		continue;

	    if (statfs(mp->mnt_dir, &statfsbuf))
		continue;
	    
	    factor = statfsbuf.f_bsize / 512 ;
	    
	    statfsbuf.f_bfree *= factor;
	    statfsbuf.f_blocks *= factor;
	    statfsbuf.f_bavail *= factor;
	    
	    pathname = mp->mnt_dir;
	    devname = mp->mnt_fsname;
	    free_blocks = statfsbuf.f_bavail;
	    total_blocks = statfsbuf.f_blocks;
	    if (strcmp(mp->mnt_type, MNTTYPE_42) == 0)
		pctfree = (1000 * free_blocks) / (9 * total_blocks);
	    else
		pctfree = (100 * free_blocks) / total_blocks;
#endif

/* ifdef HP added here -- MVR 30 Apr 1994 */
#ifdef	HP_UX
	    if ((mp = getmntent(fptr)) == NULL)
		break;

	    /*
	     * Skip any file system that's marked "ignore", 
	     * and the special tmp, swap and swapfs file systems
	     */
	    if ((strcmp(mp->mnt_type, MNTTYPE_IGNORE) == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_SWAP) == 0) ||
		(strcmp(mp->mnt_type, "tmp") == 0) ||
		(strcmp(mp->mnt_type, MNTTYPE_SWAPFS) == 0))
		continue;

	    if (statfs(mp->mnt_dir, &statfsbuf))
		continue;
	    
	    factor = statfsbuf.f_bsize / 512 ;
	    
	    statfsbuf.f_bfree *= factor;
	    statfsbuf.f_blocks *= factor;
	    statfsbuf.f_bavail *= factor;
	    
	    pathname = mp->mnt_dir;
	    devname = mp->mnt_fsname;
	    free_blocks = statfsbuf.f_bavail;
	    total_blocks = statfsbuf.f_blocks;
	    if (strcmp(mp->mnt_type, MNTTYPE_HFS) == 0)
		pctfree = (1000 * free_blocks) / (9 * total_blocks);
	    else
		pctfree = (100 * free_blocks) / total_blocks;
#endif

#ifdef OSF
	    if (i >= entries)
		break;

	    if (mp->f_type == MOUNT_EFS) {
		i++;
		mp++;
		continue;
	    }

	    mp->f_bfree *= 2;
	    mp->f_blocks *= 2;
	    mp->f_bavail *= 2;

	    pathname = mp->f_mntonname;
	    devname = mp->f_mntfromname;
	    free_blocks = mp->f_bfree;
	    total_blocks = mp->f_blocks;

	    pctfree = (100 * mp->f_bfree) / mp->f_blocks;

	    i++;
	    mp++;
#endif
	}
	
	if (free_blocks > maxfree) {
	    maxfree = free_blocks;
	    if (maxonly)
		sprintf(maxfsys, "%s %d", pathname, maxfree);
	    else
		strcpy(maxfsys, pathname);
	}
	
	if (strchr(devname, ':') != NULL) {
	    if (strchr(devname, '/') != NULL) {
#ifndef SYSV
		bzero(dev, STRSIZ);
#else
		memset(dev, 0, STRSIZ);
#endif
		for (j = 0, c = devname; *c != ':'; ++j, ++c)
		    dev[j] = *c;
		dev[j++] = ':';
		for (c = (char *)(1 + strrchr(devname, '/')); *c; ++j, ++c)
		    dev[j] = *c;
		devname = dev;
	    }
	    else {
		/*
		 * File system is handled via automount
		 * So skip it (it's what /etc/mount and /bin/df do)
		 */
		continue;
	    }
	} else
	    devname = (char *)(1 + strrchr(devname, '/'));
#if defined(SunOS_4) || defined(OSF) 
#  ifdef SunOS_4
	pctfree = (1000 * free_blocks) / (9 * total_blocks);
#  else
	pctfree = (100 * free_blocks) / total_blocks;
#  endif
	if (!maxonly)
	    PRINT "%-23.23s %-14.14s %7d + %7d = %7d\t %3d%%\n",
		  pathname, devname, free_blocks, total_blocks - free_blocks, total_blocks,
		  100 - pctfree);
/* added HP here -- MVR 20 May 1994 */
#elif defined(HP_UX)
	if (!maxonly)
	    PRINT "%-23.23s %-14.14s %7d + %7d = %7d\t %3d%%\n",
		  pathname, devname, free_blocks, total_blocks - free_blocks, total_blocks,
		  100 - pctfree);
#else
	if (!maxonly)
	    PRINT "%-23.23s %-14.14s %7d + %7d = %7d\t %3d%%\n",
		  pathname, devname, free_blocks, total_blocks - free_blocks, total_blocks,
		  100 - 100 * free_blocks / total_blocks);
#endif
    }
    if (!maxonly)
	PRINT dashes);
#if defined(SYSV) || defined(SunOS_4)
    if (!fsli)
	fclose(fptr);
#endif
    return(maxfsys);
}
#endif

#ifdef _AIX
/*
 * show the user the available filesystems and prompt for which file system
 * should be used for loading software to.
 */
char    *showthem(maxonly)
int     maxonly;
{
    int i = 0, j;
    int maxfree = 0;
    int total_blocks, free_blocks;
    char        *c, *pathname, *devname;
    char        dev[STRSIZ];
    static char maxfsys[STRSIZ] = {"/usr"};
    int factor, pctfree;
    struct vmount *vptr, *vbuf;
    char *hname;
    char fsname[STRSIZ];
    int result, size=1024;
    struct statfs       statfsbuf;
    extern int  statfs();

    if (!fsli) {
        vbuf = malloc(size);
        if (!vbuf)
            return(NULL);

        result = mntctl(MCTL_QUERY, size, vbuf);

        if (result < 0)
            return(NULL);
        else if (result == 0){
            size = *(ulong *)vbuf;
            vbuf = realloc(vbuf, size);
            result = mntctl(MCTL_QUERY, size, vbuf);
        }
    }

    if (!maxonly) {
        PRINT "File System\t\tDevice\t\t  Free +    Used = Total Blocks  %% Used\n");
        PRINT dashes);
    }
    for (vptr = vbuf, i = 0;;) {
        if (fsli) {
            if (i >= fsli)
                break;
            pathname = fsl[i].path;
            strcpy(fsname, fsl[i].dev);
            free_blocks = fsl[i].free_blocks - fsl[i].claimed_blocks;
            total_blocks = fsl[i].used_blocks + fsl[i].free_blocks;
            ++i;
        } else {
            if (i >= result)
                break;

            pathname = vmt2dataptr(vptr, VMT_STUB);
            devname = vmt2dataptr(vptr, VMT_OBJECT);

            if (vptr->vmt_gfstype != MNT_JFS && vptr->vmt_gfstype != MNT_AIX &&
                vptr->vmt_gfstype != MNT_NFS && vptr->vmt_gfstype != MNT_CDROM) {
                vptr = (ulong)vptr + vptr->vmt_length;
                ++i;
                continue;
            }

            if (statfs(pathname, &statfsbuf)) {
                vptr = (ulong)vptr + vptr->vmt_length;

                ++i;
                continue;
            }

            if (vptr->vmt_gfstype == MNT_NFS) {
                hname = vmt2dataptr(vptr, VMT_HOSTNAME);
                sprintf(fsname, "%s:%s", hname, devname);
            }
            else
                strcpy(fsname, devname);

            factor = statfsbuf.f_bsize / 512 ;

            statfsbuf.f_bfree *= factor;
            statfsbuf.f_blocks *= factor;
            statfsbuf.f_bavail *= factor;

            free_blocks = statfsbuf.f_bavail;
            total_blocks = statfsbuf.f_blocks;
            pctfree = (100 * statfsbuf.f_bavail) / statfsbuf.f_blocks;

            vptr = (ulong)vptr + vptr->vmt_length;
            ++i;
        }

        if (free_blocks > maxfree) {
            maxfree = free_blocks;
            if (maxonly)
                sprintf(maxfsys, "%s %d", pathname, maxfree);
            else
                strcpy(maxfsys, pathname);
        }

        if (strchr(fsname, ':') != NULL) {
            if (strchr(fsname, '/') != NULL) {
#ifndef SYSV
                bzero(dev, STRSIZ);
#else
		memset(dev, 0, STRSIZ);
#endif
                for (j = 0, c = fsname; *c != ':'; ++j, ++c)
                    dev[j] = *c;

                dev[j++] = ':';
                for (c = (char *)(1 + strrchr(fsname, '/')); *c; ++j, ++c)
                    dev[j] = *c;
                strcpy(fsname, dev);
            }
            else {
                /*
                 * File system is handled via automount
                 * So skip it (it's what /etc/mount and /bin/df do)
                 */
                continue;
            }
        } else
            strcpy(fsname, (char *)(1 + strrchr(fsname, '/')));

        if (!maxonly)
            PRINT "%-23.23s %-14.14s %7d + %7d = %7d\t %3d%%\n",
                  pathname, fsname, free_blocks, total_blocks - free_blocks, total_blocks,
                  100 - pctfree);

    }
    if (!maxonly)
        PRINT dashes);

    return(maxfsys);
}
#endif



/*
 * This routine determines the number of free blocks existing on the file
 * system whose path is "fs".
 */
int	num_free_blks(fs)
char	*fs;
{
    int	i, l, maxi = -1, maxl = 0;
#if defined(SVR4) && !defined(sgi)
    struct statvfs	statfsbuf;
#else
    struct statfs	statfsbuf;
#endif
    
    if (fsli) {
	for (i = 0; i < fsli; ++i) {
	    l = strlen(fsl[i].path);
	    if (l > maxl)
		maxl = l;
            if (!strcmp(GetMountPoint(fs), fsl[i].path))
		maxi = i;
	}
   	if (maxi != -1)
	    return(fsl[maxi].free_blocks - fsl[maxi].claimed_blocks);
    } else {
/* HP added in the list -- MVR 2 May 1994 */
#if defined(SunOS_4) || defined(_AIX) || defined(HP_UX)
	if (!statfs(GetMountPoint(fs), &statfsbuf))
	    return(statfsbuf.f_bavail * (statfsbuf.f_bsize / 512));
#endif
#if defined(SVR3) || defined(sgi)
	if (!statfs(GetMountPoint(fs), &statfsbuf, sizeof(struct statfs), 0))
	    return(statfsbuf.f_bfree);
#endif
#if defined(SVR4) && !defined(sgi)
	if (!statvfs(GetMountPoint(fs), &statfsbuf)) {
	    if (statfsbuf.f_frsize)
		return(statfsbuf.f_bfree * statfsbuf.f_frsize / 512);
	    else
		return(statfsbuf.f_bfree);
	}
#endif
#ifdef OSF
	if (!statfs(GetMountPoint(fs), &statfsbuf))
	    return(statfsbuf.f_bavail * 2);
#endif
    }
    return(-1);
}

void	usage(progname)
char	*progname;
{
    PRINT "Usage:\n%s\t\t\t\tDisplay usage of currently mounted file systems\n", progname);
    PRINT "%s -t <filesys> <nblocks>\tCheck if <filesys> has <nblocks> free\n", progname);
    PRINT "%s -a <filesys> <nblocks>\tAllocate <nblocks> in <filesys>\n", progname);
    PRINT "%s -f <filesys>\t\tShow free blocks of <filesys>\n", progname);
    PRINT "%s -p\t\t\tPrompt the user for a file system from a menu\n", progname);
    PRINT "%s -m\t\t\tShow file system with the most free space\n", progname);
    exit(255);
}

int	main(argc, argv)
int	argc;
char	**argv;
{
    int	size, result;
    int	i, l, maxi = -1, maxl = 0;
    char	FS[64];
    char	*maxfs, *fs;
    FILE	*fslf;
    struct stat statbuf;

#ifdef SecureWare
    if (trustlevel()) {
        set_auth_parameters(argc, argv);
        if (!authorized_user("queryspace"))  {
            fprintf(stderr, "Free:  You are not authorized to use Free.\n");
            exit(1);
        }
    }
#endif
    
    if ((fslistpath = (char *)getenv("FSLIST")) && (*fslistpath != '\0')) {
	if (stat(fslistpath, &statbuf) || !S_ISREG(statbuf.st_mode)) {
	    PRINT "Error: %s is not a regular file.  Abort.\n", fslistpath);
	    exit(1);
	}
	if (!(fslf = fopen(fslistpath, "r"))) {
	    PRINT "Error opening %s. Abort.\n", fslistpath);
	    exit(1);
	}

	while ((fscanf(fslf, "%s%s%d%d%d",
		      fsl[fsli].path, fsl[fsli].dev,
		      &fsl[fsli].free_blocks, &fsl[fsli].used_blocks,
		      &fsl[fsli].claimed_blocks) > 0) && (fsli < 64)) { 

	    ++fsli;
	}
        fclose(fslf);
    }
    
    if (argc > 1) {
	if (*argv[1] == '-') {
	    switch(argv[1][1]) {
	    case '?': /* show usage */
		usage(argv[0]);
		break;
		
	    case 't': /* test a fs for free blocks */
		if (argc < 4)
		    usage(argv[0]);
		fs = argv[2];
		size = atoi(argv[3]);
		if (num_free_blks(fs) >= size)
		    exit(0);
		exit(1);
		break;
		
	    case 'f': /* display free space of an fs */
		if (argc < 3)
		    usage(argv[0]);
		fs = argv[2];
		PRINT "%d\n", num_free_blks(fs));
		break;
		
	    case 'm': /* display the max free fsys */
		PRINT "%s\n", showthem(1));
		break;
		
	    case 'a': /* register some blocks as "claimed" */
		if (argc < 4)
		    usage(argv[0]);
		if (!fsli) {
		    PRINT "Unknown file system list.\n");
		    exit(1);
		}
		/* locate the correct entry to update the claimed_blocks value */
		for (i = 0; i < fsli; ++i) {
		    l = strlen(fsl[i].path);
		    if (l > maxl)
			maxl = l;
		    if (!strcmp(GetMountPoint(argv[2]), fsl[i].path))
			maxi = i;
		}
		if (maxi != -1) {
		    l = atoi(argv[3]);
		    if ((fsl[maxi].claimed_blocks + l) < fsl[maxi].free_blocks)
			fsl[maxi].claimed_blocks += l;
		    else {
			PRINT "Not enough free space to register this amount.\n");
			exit(1);	/* can't register that much */
		    }
		} else {
		    PRINT "No match for this filesystem\n");
		    exit(1);	/* no match for the filesystem */
		}
		
		if (!(fslf = fopen(fslistpath, "w"))) {
		    PRINT "Error opening %s. Abort.\n", fslistpath);
		    exit(1);
		}
		for (i = 0; i < fsli; ++i)
		    fprintf(fslf, "%s %s %d %d %d\n", fsl[i].path, fsl[i].dev,
			    fsl[i].free_blocks, fsl[i].used_blocks, fsl[i].claimed_blocks);
		fclose(fslf);
		break;
		
	    case 'p': /* prompt for an fs */
		tty = fopen("/dev/tty", "r+");
		for(;;) {
		    PRINT "Available file systems and sizes:\n");
		    maxfs = showthem(0);
		    PRINT "Please select a file system [%s]: ",
			  maxfs);
#ifdef SunOS_4
		    fflush(tty);
#endif
		    fgets(FS, 64, stdin);
		
		    if (FS[strlen(FS)-1] == '\n')
		    	FS[strlen(FS)-1] = '\0';

		    if (*FS == '\0' || *FS == '\n')
			strcpy(FS, maxfs);
		    if (!access(FS, 0)) {
			printf("%s\n", FS);
			exit(0);
		    }
		    PRINT "Invalid file system \"%s\". Try again.\n", FS);
		}
	    }
	} else
	    showthem(0);
    } else
	showthem(0);
    exit(0);
}
