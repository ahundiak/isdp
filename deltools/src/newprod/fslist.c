#include	<sys/types.h>
#include	<sys/stat.h>
#include	<stdlib.h>
#include	<stdio.h>
#include	<fcntl.h>
#ifdef SVR3
#  include	<sys/statfs.h>
#  include	<sys/fstyp.h>
#  include	<sys/fsid.h>
# ifndef sgi
#  include	<mnttab.h>
#  define	MNTTAB	"/etc/mnttab"
# else
#  include	<mntent.h>
# endif
#endif
#ifdef SVR4
# ifdef sgi
#  include	<sys/statfs.h>
#  include	<mntent.h>
# else
#  include	<sys/statvfs.h>
#  include	<sys/mnttab.h>
# endif
#  include	<sys/fstyp.h>
#  include	<sys/fsid.h>
#endif
/* HP added in the following conditional if --  MVR 30 Apr 1994 */
#if defined(SunOS_4) || defined(HP_UX)
#  include	<sys/vfs.h>
#  include	<mntent.h>
#endif
#ifdef OSF
#  include	<sys/mount.h>
#endif
#ifdef _AIX
#  include	<sys/statfs.h>
#  include      <sys/vmount.h>
#  include      <sys/mntctl.h>
#endif

static char	*fslistpath = {"/usr/tmp/.fslist"};
static char	*saved_fslist = NULL;
static int	saved_fslist_size;
static char	envptr[128];

void	capture_fslist() {
	struct stat	statbuf;
	int	fd;

	if ((fd = open(fslistpath, O_RDONLY)) < 0)
		return;
	if (fstat(fd, &statbuf) < 0) {
		close(fd);
		return;
	}
	saved_fslist_size = statbuf.st_size;
	if (saved_fslist)
	    saved_fslist = (char *)realloc(saved_fslist, saved_fslist_size);
	else
	    saved_fslist = (char *)malloc(saved_fslist_size);
	if (read(fd, saved_fslist, saved_fslist_size) < 0)
		saved_fslist_size = 0;
	close(fd);
}

void	make_fslist() {
#if defined(SVR3) && !defined(sgi)
	struct statfs   statfsbuf;
	struct mnttab   mp;
	FILE		*fptr;
#  if !defined(clipper) && !defined(__clipper__)
	char		fstype[16];
#  endif
#endif
#ifdef sgi
	struct statfs   statfsbuf;
	struct mntent	*mp;
	FILE		*fptr;
#endif
#if defined(SVR4) && !defined(sgi)
	struct statvfs	statfsbuf;
	struct mnttab	mp;
	int		factor;
	FILE		*fptr;
#endif
/* HP added in the following defined list -- MVR 30 Apr 1994 */
#if  defined(SunOS_4) || defined(HP_UX)
	struct statfs   statfsbuf;
	struct mntent	*mp;
	int		factor;
	FILE		*fptr;
#endif
#ifdef _AIX
	struct statfs   statfsbuf;
        struct vmount *vptr, *vbuf;
        char    *obptr, *stubptr, *tptr;
	int		factor;
        int     result, size = 1024, i;
#endif
#ifdef OSF
	struct statfs	*sfbuf, *mp;
	int		entries, i;
	long		bufsiz;
#endif
	FILE	*fslf;


	if (!(fslf = fopen(fslistpath, "w")))
		return;
#if defined(SVR3) && !defined(sgi)
	if (!(fptr = fopen(MNTTAB, "r")))
		return;
	while (fread(&mp, sizeof(char), sizeof(struct mnttab)/sizeof(char) , fptr)) {
#if defined(clipper) || defined(__clipper__)
	    /*
	     * skip proc file systems, automount entries, and NFS file systems
	     */
	    if (!mp.mt_fstyp[0] || !strcmp(mp.mt_fstyp, "PROC") ||
		!strcmp(mp.mt_fstyp, "NFS"))
		    continue;
#endif
	    if (statfs(mp.mt_filsys, &statfsbuf, sizeof(struct statfs), 0))
		    continue;

#if !defined(clipper) && !defined(__clipper__)
	    if (sysfs(GETFSTYP, statfsbuf.f_fstyp, fstype) < 0)
		continue;
	    if (strcmp(fstype, "PROC") == 0 || strcmp(fstype, "DUFST") == 0 ||
		strcmp(fstype, "NFS") == 0 || strcmp(fstype, "HS") == 0)
		continue;
#endif
	    fprintf(fslf, "%s %s %d %d 0\n", mp.mt_filsys, mp.mt_dev,
		    statfsbuf.f_bfree, statfsbuf.f_blocks - statfsbuf.f_bfree);
	}
	fclose(fptr);
#endif
#if defined(SVR4) && !defined(sgi)
	if (!(fptr = fopen(MNTTAB, "r")))
		return;
	while (getmntent(fptr, &mp) == 0) {
	    if (strcmp(mp.mnt_fstype, "ufs"))
		continue;
	    if (statvfs(mp.mnt_mountp, &statfsbuf))
		continue;
	    if (statfsbuf.f_frsize) {
		factor = statfsbuf.f_frsize / 512;
		statfsbuf.f_bfree *= factor;
		statfsbuf.f_blocks *= factor;
		statfsbuf.f_bavail *= factor;
	    }

	    fprintf(fslf, "%s %s %d %d 0\n", mp.mnt_mountp, mp.mnt_special,
		    statfsbuf.f_bfree, statfsbuf.f_blocks - statfsbuf.f_bfree);
	}
	fclose(fptr);
#endif
/* ifdef HP added for HP port -- MVR 30 Apr 1994  */
#ifdef HP_UX
	if (!(fptr = fopen(MOUNTED, "r")))
		return;
	while ((mp = getmntent(fptr)) != NULL) {
	    /*
	     * Allow only HFS file systems into the list.
	     * (Skip NFS,  CDFS, SWAP, SWAPFS, IGNORE)
	     */
	   /*  HFS is HP native file system --  MVR 30 Apr 1994 */
	    if (strcmp(mp->mnt_type, MNTTYPE_HFS))
		    continue;
	    if (statfs(mp->mnt_dir, &statfsbuf))
		    continue;

	    factor = statfsbuf.f_bsize / 512;
	    statfsbuf.f_bfree *= factor;
	    statfsbuf.f_blocks *= factor;
	    statfsbuf.f_bavail *= factor;

	    fprintf(fslf, "%s %s %d %d 0\n", mp->mnt_dir, mp->mnt_fsname,
		    statfsbuf.f_bfree, statfsbuf.f_blocks - statfsbuf.f_bfree);
	}
	fclose(fptr);
#endif 
#ifdef SunOS_4
	if (!(fptr = fopen(MOUNTED, "r")))
		return;
	while ((mp = getmntent(fptr)) != NULL) {
	    /*
	     * Allow only 4.2 file systems into the list.
	     * (Skip NFS, PCFS, HSFS, SWAP, IGNORE, and LO)
	     */
	    if (strcmp(mp->mnt_type, MNTTYPE_42))
		    continue;
	    if (statfs(mp->mnt_dir, &statfsbuf))
		    continue;

	    factor = statfsbuf.f_bsize / 512;
	    statfsbuf.f_bfree *= factor;
	    statfsbuf.f_blocks *= factor;
	    statfsbuf.f_bavail *= factor;

	    fprintf(fslf, "%s %s %d %d 0\n", mp->mnt_dir, mp->mnt_fsname,
		    statfsbuf.f_bfree, statfsbuf.f_blocks - statfsbuf.f_bfree);
	}
	fclose(fptr);
#endif 
#ifdef sgi
	if (!(fptr = fopen(MOUNTED, "r")))
		return;
	while ((mp = getmntent(fptr)) != NULL) {
	    /*
	     * Allow only EFS and BELL(S51K) file systems into the list.
	     * (Skip NFS, PIPE, SOCKET, and DEBUG)
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

	    fprintf(fslf, "%s %s %d %d 0\n", mp->mnt_dir, mp->mnt_fsname,
		    statfsbuf.f_bfree, statfsbuf.f_blocks - statfsbuf.f_bfree);
	}
	fclose(fptr);
#endif
#ifdef _AIX
        if ((tptr = malloc(size)) == NULL)
            return;
        vbuf = (struct vmount *)tptr;
        result = mntctl(MCTL_QUERY, size, vbuf);
        if (result < 0)
            return;
        else if (result == 0) {
            size = *(ulong *)vbuf;
            tptr = realloc(vbuf, size);
            vbuf = (struct vmount *)tptr;
            result = mntctl(MCTL_QUERY, size, vbuf);
        }

	for (i = 0,vptr = vbuf; i < result; i++, tptr += vptr->vmt_length, vptr=(struct vmount *)tptr) {
            obptr = vmt2dataptr(vptr, VMT_OBJECT);
            stubptr = vmt2dataptr(vptr, VMT_STUB);

            if ((vptr->vmt_gfstype != MNT_JFS) && (vptr->vmt_gfstype != MNT_AIX))
                continue;

            if (statfs(stubptr, &statfsbuf))
                continue;

            factor = statfsbuf.f_bsize / 512;
            statfsbuf.f_bfree *= factor;
            statfsbuf.f_blocks *= factor;
            statfsbuf.f_bavail *= factor;

            fprintf(fslf, "%s %s %d %d 0\n", stubptr, obptr,
                statfsbuf.f_bavail, statfsbuf.f_blocks - statfsbuf.f_bavail);
        }
#endif
#ifdef OSF
	entries = getfsstat((struct statfs *)0, 0, 0);
	bufsiz = entries * sizeof(struct statfs);
	sfbuf = (struct statfs *)malloc(bufsiz);

	getfsstat(sfbuf, bufsiz, MNT_NOWAIT);

	for (i = 0, mp = sfbuf; i < entries; i++, mp++) {
	    if (mp->f_type != MOUNT_UFS)
		continue;

	    mp->f_bfree *= 2;
	    mp->f_blocks *= 2;
	    mp->f_bavail *= 2;

	    fprintf(fslf, "%s %s %d %d 0\n",
		    mp->f_mntonname, mp->f_mntfromname,
		    mp->f_bfree, mp->f_blocks - mp->f_bfree);
	}
	free(sfbuf);
#endif
	fclose(fslf);

	capture_fslist();

	sprintf(envptr, "FSLIST=%s", fslistpath);
	putenv(envptr);
}

void	restore_fslist() {
	int	fd;

	if ((fd = open(fslistpath, O_WRONLY | O_TRUNC)) < 0)
		return;
	write(fd, saved_fslist, saved_fslist_size);
	close(fd);
}

void	remove_fslist() {
	unlink(fslistpath);
	strcpy(envptr, "FSLIST=");
	putenv(envptr);
}
