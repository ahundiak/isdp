/* stole this from df.c */

/*****************************************************************************/
/* routines in the file:                                                     */
/*									     */
/* scroll_filesystems - scrolls the file systems to a given percentage       */
/* show_filsystems    - gets and dispalys existing file systems              */
/* printit            - puts the file system information onto the form       */
/*****************************************************************************/


#include <sys/types.h>
#include <sys/param.h>
#include <stdio.h>
#if defined(clipper) || defined(__clipper__)
#include <sys/fs/s5param.h>
#include <sys/sysmacros.h>
#include <sys/ino.h>
#include <mnttab.h>
#include <sys/stat.h>
#include <ustat.h>
#include <sys/statfs.h>
#include <sys/fs/s5filsys.h>
#include <sys/fs/s5fblk.h>
#include <sys/fs/s5dir.h>
#include <setjmp.h>
#include <sys/sysingr.h>
#endif
#if defined(SunOS_4)
#include <sys/time.h>
#include <sys/sysmacros.h>
#include <sys/vnode.h>
#include <ufs/fs.h>
#include <ufs/inode.h>
#include <mntent.h>
#include <sys/stat.h>
#include <ustat.h>
#include <sys/vfs.h>
#endif
#if defined(SVR4) && !defined(sgi)
#include <sys/time.h>
#include <sys/sysmacros.h>
#include <sys/stat.h>
#include <sys/statvfs.h>
#include <sys/mntent.h>
#include <sys/mnttab.h>
#include <ustat.h>
#endif
#ifdef sgi
#include <sys/time.h>
#include <sys/sysmacros.h>
#include <sys/vnode.h>
#include <sys/statfs.h>
#include <sys/stat.h>
#include <ustat.h>
#include <mntent.h>
#endif

#include <string.h>
#include "main.h"
#include "defs.h"

#if defined(clipper) || defined(__clipper__)
#define MNTTAB "/etc/mnttab"
#define MNTED fs_name[0]

#define DEVLEN sizeof(Mp.mt_dev)
#define DEVLSZ 200	/* number of unique file systems we can remember */
#define FREMOTE	0x0002	/* file is remote (see <sys/user.h>)  */
char *devnm();
#else
#define MNTED fs_name[0]
#define DEVLEN sizeof(Mp->mnt_dir)
#endif

#if defined(clipper) || defined(__clipper__)
struct	mnttab	Mp;
struct stat	S;
struct filsys	sblock;
struct ustat	*Fs = (struct ustat *)&sblock.s_tfree;
struct statfs	Fs_info;
#endif
#if defined(SunOS_4) || defined(sgi)
struct mntent	*Mp;
struct stat	S;
#ifndef sgi
struct fs	sblock;
#endif
struct ustat	Fs ;
struct statfs	Fs_info;
#endif
#if defined(SVR4) && !defined(sgi)
struct mnttab	*Mp;
struct stat	S;
struct ustat	Fs;
struct statvfs	Fs_info;
#endif

int	physblks;
long	bsize;
int 	bshift;
int	fd;
daddr_t	blkno	= 1;

#if defined(clipper) || defined(__clipper__)
daddr_t	alloc();
#endif

int	next_fs_button;
int	curr_fs = 0;
int	num_fs = 0;
int	topind = 0;

struct fsdata fs_table[40];

char nfsmes[] = "          (%-10.32s): \
is not a file system, directory, or mounted resource\n";



int
scroll_filesystems(fp, percent)

/*****************************************************************************/
/* this routine scrolls the file systems on the file system for to the       */
/* percent view                                                              */
/*****************************************************************************/

Form fp;
int  percent;

{
	int	index;

	if (num_fs == 0)
		return(0);

	/* first decide which file system will be at the top of the list */
	if (percent == 0)
		index = 0;
	else
		index = (percent / (100/num_fs));

	if (index >= 40)	/* don't go over the limit */
		index = 39;

	if (index >= num_fs-2)   /* subtract 1 becuase we start counting with 0 */
		index = num_fs - 2;  /* and subtract another because we are showing 2 */

	topind = index;
	/* do fs #1 */
	FIg_erase(fp, FS1);
	FIg_set_text(fp, FS1, fs_table[index].name);
	FIg_display(fp, FS1);
	if (index == curr_fs)
		FIg_set_value(fp, FS1, (double)1);
	else
		FIg_set_value(fp, FS1, (double)0);
	FIg_set_value(fp, BLOCKS_SEL_1, (double)fs_table[index].selected);
	FIg_set_value(fp, BLOCKS_FREE_1, (double)fs_table[index].space); 
	FIg_set_value(fp, PERC_USED_1, (double)fs_table[index].pct);

	/* do fs #2 */
	FIg_erase(fp, FS2);
	FIg_set_text(fp, FS2, fs_table[index+1].name);
	FIg_display(fp, FS2);
	if (index+1 == curr_fs)
		FIg_set_value(fp, FS2, (double)1);
	else
		FIg_set_value(fp, FS2, (double)0);
	FIg_set_value(fp, BLOCKS_SEL_2, (double)fs_table[index+1].selected);
	FIg_set_value(fp, BLOCKS_FREE_2, (double)fs_table[index+1].space); 
	FIg_set_value(fp, PERC_USED_2, (double)fs_table[index+1].pct);
} /* scroll_filesystems */


int
show_filesystems(fp)

/****************************************************************************/
/* this routine gets and displays the existing file systems                 */
/****************************************************************************/

Form fp;

{
#if defined(clipper) || defined(__clipper__)
	register fi, i;
	char	 dev[DEVLEN+1];
#endif
#if defined(SunOS_4) || defined(SVR4)
	register i;
	FILE	 *fi;
	char	 dev[65];
#endif
	int	 errcnt = 0;


	next_fs_button = FS1;
	num_fs = 0;

#if defined(clipper) || defined(__clipper__)
	if((fi = open(MNTTAB, 0)) < 0) 
	{
		fprintf(stderr,"df: cannot open %s\n",MNTTAB);
		return(1);
	} /* if */

	while ((i = read(fi, &Mp, sizeof(Mp))) == sizeof(Mp)) 
	{
		if (Mp.mt_ro_flg)
		    continue;
		
		/*
		 * Skip entries that are handled by
		 * the automounter, and things that are explicitly
		 * NFS file systems.
		 */

		if ((!Mp.mt_fstyp[0]) || !strcmp(Mp.mt_fstyp, "NFS"))
		    continue;

		/* doing all things in the mount table */
		if(stat(Mp.mt_filsys, &S) == -1)
			S.st_dev = -1;
		if(S.st_dev < 0)	 /*is this an NFS mounted filesystem?*/
		    continue;
		else
		    sprintf(dev,"%.32s",Mp.mt_dev);

		errcnt += printit(fp, dev, Mp.mt_filsys);
	} /* while */

	close(fi);
#endif
#if defined(SunOS_4) || defined(sgi)
	if((fi = fopen(MOUNTED, "r")) == NULL)
	{
		fprintf(stderr, "df: cannot open %s\n", MOUNTED);
		return(1);
	} /* if */
	while (Mp = getmntent(fi)) {
#ifdef SunOS_4
                if (strcmp(Mp->mnt_type, MNTTYPE_42))
                   continue;
#endif
#ifdef sgi
            /*
             * In IRIX, the list of things to disallow is:
             *   NFS, PIPE, SOCKET, DBG
             */
            if ((strcmp(Mp->mnt_type, MNTTYPE_NFS) == 0) ||
#    ifndef SVR4
                (strcmp(Mp->mnt_type, MNTTYPE_PIPE) == 0) ||
#    else
                (strcmp(Mp->mnt_type, MNTTYPE_PROC) == 0) ||
                (strcmp(Mp->mnt_type, MNTTYPE_MFS) == 0) ||
                (strcmp(Mp->mnt_type, MNTTYPE_PC) == 0) ||
                (strcmp(Mp->mnt_type, MNTTYPE_SWAP) == 0) ||
                (strcmp(Mp->mnt_type, MNTTYPE_IGNORE) == 0) ||
                (strcmp(Mp->mnt_type, MNTTYPE_LO) == 0) ||
                (strcmp(Mp->mnt_type, MNTTYPE_DOS) == 0) ||
                (strcmp(Mp->mnt_type, MNTTYPE_FD) == 0) ||
                (strcmp(Mp->mnt_type, MNTTYPE_AFS) == 0) ||
#    endif
                (strcmp(Mp->mnt_type, MNTTYPE_SOCKET) == 0) ||
                (strcmp(Mp->mnt_type, MNTTYPE_DBG) == 0))
                continue;
#endif


                if(stat(Mp->mnt_fsname, &S) == -1)
                        S.st_dev = -1;

		if (S.st_dev < 0)
		    continue;
		else
		    sprintf(dev,"%.32s",Mp->mnt_fsname);

                errcnt += printit(fp, dev, Mp->mnt_dir);
        } /* while */

        close(fi);
#endif
#if defined(SVR4) && !defined(sgi)
        /* SVR4 method of reading mounted filesystem table */
        if ((fi= fopen(MNTTAB, "r")) == NULL) {
	    fprintf(stderr, "df: cannot open %s\n", MNTTAB);
	    return(1);
        }
        while (getmntent(fi, Mp) == 0) {
            /*
             * Don't allow read only file systems
             */
/*          if (hasmntopt(Mp, MNTOPT_RO)) */
            if (strstr(Mp->mnt_mntopts, MNTOPT_RO))
                continue;

            /*
             * We're not allowing NFS file systems anymore.  Nyaaa!
             * (But maybe when network licensing is widely implemented,
             * we'll put it back in...)
             *
             * While we're at it, also throw out entries that have
             * types of "ignore" (automounter), "pcfs", "swap", and "lo".
             */
            if ((strcmp(Mp->mnt_fstype, MNTTYPE_NFS) == 0) ||
                (strcmp(Mp->mnt_fstype, MNTTYPE_PC) == 0) ||
                (strcmp(Mp->mnt_fstype, MNTTYPE_SWAP) == 0) ||
                (strcmp(Mp->mnt_fstype, MNTTYPE_TMPFS) == 0) ||
                (strcmp(Mp->mnt_fstype, MNTTYPE_LO) == 0))
                continue;

            /*
             * It might be easier just to do this.
            if (strcmp(Mp->mnt_fstype, "ufs"))
                continue;
             */

	    if(stat(Mp->mnt_special, &S) == -1)
		    S.st_dev = -1;

	    if (S.st_dev < 0)
		continue;
	    else
		sprintf(dev,"%.32s",Mp->mnt_special);

                errcnt += printit(fp, dev, Mp->mnt_mountp);
        } /* while */
	fclose(fi);
#endif

	if (num_fs != 0)
		FIscrl_set_view(fp, FS_SCROLL, (double) ((100/num_fs)*2));

	return(1);
}



printit(fp, dev, fs_name)

/****************************************************************************/
/* this routine prints the filesystem information on the fsavail form       */
/****************************************************************************/

Form fp;
char *dev, *fs_name; 

{
	int	percent_used;
	char	free_space[8];

	if(!MNTED) {	/* Unmounted file system queries
					   and freelist querries work only
					   on UNIX file systems */
#if defined(clipper) || defined(__clipper__)
		if((fd = open(dev, 0)) < 0) 
		{
			fprintf(stderr,"df: cannot open %s\n",dev);
			close(fd);
			return(1);
		} /* if */

		if(stat(dev, &S) < 0) 
		{
			fprintf(stderr, "df: cannot stat %s\n", dev);
			close(fd);
			return(1);
		} /* if */

		if(((S.st_mode & S_IFMT) == S_IFREG) 
		|| ((S.st_mode & S_IFMT) == S_IFIFO)) 
		{
			printf(nfsmes, dev);
			close(fd);
			return(1);
		} /* if */

		sync();

		if(lseek(fd, (long)SUPERBOFF, 0) < 0
		|| read(fd, &sblock, (sizeof sblock)) != (sizeof sblock)) 
		{
			close(fd);
			return(1);
		} /* if */

		if(sblock.s_magic == FsMAGIC) 
		{
			if(sblock.s_type == Fs1b) 
			{
				physblks = 1;
				bsize = BSIZE;
				bshift = BSHIFT;
			} /* if */
			else if(sblock.s_type == Fs2b) 
			{
#ifdef u3b15
				physblks = 4;
				bsize = 4 * BSIZE;
				bshift = BSHIFT + 2;
#else
				physblks = 2;
				bsize = 2 * BSIZE;
				bshift = BSHIFT + 1;
#endif
			} /* else */
			else 
			{
				printf("          (%-12s): bad block type\n", dev);
				return(1);
			} /* else */
		} 
		else 
		{
			if (checkfstyp(dev))
				return(0);

			physblks = 1;
			bsize = BSIZE;
			bshift = BSHIFT;
		} /* else */

		/* file system sanity test */
		if(sblock.s_fsize <= sblock.s_isize
		|| sblock.s_fsize < Fs->f_tfree
		|| sblock.s_isize < Fs->f_tinode*sizeof(struct dinode)/bsize
		|| (long)sblock.s_isize*bsize/sizeof(struct dinode) > 0xffffL) 
		{
			printf(nfsmes, dev);
			return(1);
		}
#endif		
	} else {	/* mounted file system */
#if defined(clipper) || defined(__clipper__)
		if(statfs(fs_name, &Fs_info, sizeof(struct statfs), 0) < 0) {
			fprintf(stderr, "df: cannot statfs %s\t", dev);
			perror(" statfs");
			return(1);
		}
			/* copy statfs info into superblock structure */
		Fs->f_tfree = Fs_info.f_bfree;
		Fs->f_tinode = Fs_info.f_ffree;
		strncpy(Fs->f_fname,Fs_info.f_fname,sizeof(Fs_info.f_fname));
		strncpy(Fs->f_fpack,Fs_info.f_fpack,sizeof(Fs_info.f_fpack));
				/* statfs returns block counts mod 512,
				so no conversion is required */
		physblks = 1;
#endif
#if defined(SunOS_4)
		if (statfs(fs_name, &Fs_info, sizeof(Fs_info)) < 0) {
		  fprintf(stderr, "df: cannot statfs %s\t", dev);
		  perror(" statfs ");
		  return(1);
		}
		physblks = (Fs_info.f_bsize / 512);
#endif
#if defined(SVR4) && !defined(sgi)
		if (statvfs(fs_name, &Fs_info) < 0) {
		  fprintf(stderr, "df: cannot statfs %s\t", dev);
		  perror(" statfs ");
		  return(1);
		}
		physblks = (Fs_info.f_bsize / 512);
#endif
#ifdef sgi
		if(statfs(fs_name, &Fs_info, sizeof(struct statfs), 0) < 0) {
			fprintf(stderr, "df: cannot statfs %s\t", dev);
			perror(" statfs");
			return(1);
		}
		physblks = (Fs_info.f_bsize / 512);
#endif
	}


	if (!(strcmp(fs_name, "/")))
		return(0);


	if (next_fs_button <= FS2)
		FIg_set_text(fp, next_fs_button, fs_name);

	strcpy(fs_table[next_fs_button-FS1].name, fs_name);

	/* percent used = (total - free) * 100 / total */
#if defined(clipper) || defined(__clipper__)
	percent_used = (Fs_info.f_blocks - (Fs->f_tfree * physblks)) * 100  / Fs_info.f_blocks;
	sprintf(free_space, "%d", Fs->f_tfree*physblks);
	fs_table[next_fs_button-FS1].space= Fs->f_tfree*physblks;
#endif
#if defined(SunOS_4) || (defined(SVR4) && !defined(sgi))
	percent_used = (((0.9 *Fs_info.f_blocks) - (Fs_info.f_bavail)) * 100) / (0.9 *Fs_info.f_blocks);
	sprintf(free_space, "%d", Fs_info.f_bavail*physblks);
	fs_table[next_fs_button-FS1].space = Fs_info.f_bavail*physblks;
#endif
#ifdef sgi
	percent_used = (((0.9 *Fs_info.f_blocks) - (Fs_info.f_bfree)) * 100) / (0.9 *Fs_info.f_blocks);
	sprintf(free_space, "%d", Fs_info.f_bfree*physblks);
#endif

	if (num_fs <= 40) {
		fs_table[num_fs].selected = 0;
		fs_table[num_fs].pct = percent_used;
		fs_table[num_fs].total = Fs_info.f_blocks;
		fs_table[num_fs].current_fs = FALSE;
	}

	switch (next_fs_button)
	{
	 case FS1:
		FIfld_set_text(fp, BLOCKS_FREE_1, 0, 0, free_space, FALSE); 
		FIfld_set_text(fp, BLOCKS_SEL_1, 0, 0, "0", FALSE);
		FIg_set_value(fp, PERC_USED_1, (double)percent_used);
/*		FIg_set_value(fp, FS1, (double)1); */
		fs_table[0].current_fs = TRUE;
		break;

	 case FS2:
		FIfld_set_text(fp, BLOCKS_FREE_2, 0, 0, free_space, FALSE); 
		FIg_set_value(fp, PERC_USED_2, (double)percent_used);
		FIfld_set_text(fp, BLOCKS_SEL_2, 0, 0, "0", FALSE);
/*		FIg_set_value(fp, FS2, (double)0); */
		break;
	} /* switch */

	num_fs++;
	next_fs_button++;
	return(0);
}

#if defined(clipper) || defined(__clipper__)
firstpik()
{
	static dev_t devlst[DEVLSZ];
	static	int i, ndev;

	if(S.st_dev == -1)
		return(1);	/* stat() failed.. data invalid */
	if(ndev)
		for(i = 0; i < ndev; i++) 
			if(S.st_dev == devlst[i])
				return(0);
	if(ndev < DEVLSZ)
		devlst[ndev++] = S.st_dev;
	return(1);
}

daddr_t
alloc()
{
	int i;
	daddr_t	b;
		/* Would you believe the 3b20 dfc requires read counts mod 64?
		   Believe it! (see dfc1.c).
		*/
	char buf[(sizeof(struct fblk) + 63) & ~63];
	struct fblk *fb = (struct fblk *)buf;
	
	i = --sblock.s_nfree;
	if(i<0 || i>=NICFREE) {
		printf("bad free count, b=%ld\n", blkno);
		return(0);
	}
	b = sblock.s_free[i];
	if(b == 0)
		return(0);
	if(b<sblock.s_isize || b>=sblock.s_fsize) {
		printf("bad free block (%ld)\n", b);
		return(0);
	}
	if(sblock.s_nfree <= 0) {

		bread(b, buf, sizeof(buf));
		blkno = b;
		sblock.s_nfree = fb->df_nfree;
		for(i=0; i<NICFREE; i++)
			sblock.s_free[i] = fb->df_free[i];
	}
	return(b);
}

bread(bno, buf, cnt)
daddr_t bno;
char *buf;
{
	int n;

	if((lseek(fd, bno<<bshift, 0)) < 0) 
	{
		perror("bread: seek error");
		return(1);
	} /* if */

	if((n=read(fd, buf, cnt)) != cnt) 
	{
		perror("bread: read error");
		printf("read error %x, count = %d\n", bno, n);
		return(1);
	} /* if */
} /* bread */

struct direct dbuf;

char *
devnm(fsptr)

char  *fsptr;

{
	int i;
	static short fno;
	static struct devs {
		char *devdir;
		short dfd;
	} devd[] = {		/* in order of desired search */
		"/dev/dsk",0,
		"/dev",0,
		"/dev/rdsk",0
	};
	static char devnam[DEVLEN];
	int addr;
	struct singrdiskless sd;

	devnam[0] = '\0';
	if(!devd[1].dfd) 	/* if /dev isn't open, nothing happens */
		for(i = 0; i < 3; i++)
			devd[i].dfd = open(devd[i].devdir, 0);

	fno = S.st_dev;
	if ( fno < 1 && (strcmp(fsptr,"/") == 0))
	{ 
		/* negative S.st_dev indicates NFS root fs */

		addr = syscall(125, SINGRDISKLESS, &sd);
		if (addr != 0) 
		{
			strcpy(devnam,sd.serv_name);
			strcat(devnam,":");
			strcat(devnam,sd.root_dir);
			return(devnam);
		} /* if */
	} /* if */

	for(i = 0; i < 3; i++) 
	{
		if((devd[i].dfd >= 0)
		   && (chdir(devd[i].devdir) == 0) 
		   && (dsearch(devd[i].dfd,fno))) 
		{
			strcpy(devnam, devd[i].devdir);
			strcat(devnam,"/");
			strncat(devnam,dbuf.d_name,DIRSIZ);
			return(devnam);
		} /* if */
	} /* for */
	return(devnam);

} /* devnm */

dsearch(ddir,fno)
short ddir, fno;
{
	lseek(ddir, (long)0, 0);
	while(read(ddir, &dbuf, sizeof dbuf) == sizeof dbuf) 
	{
		if(!dbuf.d_ino) 
			continue;

		if(stat(dbuf.d_name, &S) == -1) 
		{
			fprintf(stderr, "devnm: cannot stat %s\n",dbuf.d_name);
			return(0);
		} /* if */

		if((fno != S.st_rdev) 
		|| ((S.st_mode & S_IFMT) != S_IFBLK)
		|| (strcmp(dbuf.d_name,"swap") == 0)
		|| (strcmp(dbuf.d_name,"pipe") == 0)
			) continue;
				return(1);
	} /* while */
	return(0);
} /* dsearch */


/*
 * This routine checks the file system type and acts as a driver
 * for other file system's df's.  The names of the other df's
 * are derived from the output of /etc/fstypsw.  The output is
 * set to lower case, prefixed with "/etc/", and suffixed with "df".
 *
 * If any errors are encountered, give up and assume the default case, viz.,
 * an S5 file system.  Return NULL in this case.
 */
checkfstyp(fsname)

char *fsname;

{
	int pfd[2];
	char pbuf[17];
	register ii;
	char etcdf[50];
	int waitloc;

	if (pipe(pfd) != 0)
		return (NULL);

	switch(fork()) {
	case -1:			/* error */
		return (NULL);
	case 0:				/* child */
		close(1);
		fcntl(pfd[1],F_DUPFD,1); /* duplicate pfd[1] as standard out */
		close(pfd[0]);
		execl("/bin/sh","/bin/sh", "/etc/fstyp",fsname,0);
		return (NULL);
	default:			/* parent */
		if (wait(&waitloc) == -1)
			return(NULL);
		if (((waitloc >> 8) & 0xff) != 0)
			return(NULL);
		if ((ii = read(pfd[0],pbuf,sizeof(pbuf)-1)) <= 0)
			return (NULL);
		pbuf[--ii] = 0;		/* put terminating null in '\n' spot */
		if (strcmp("S51K\n",pbuf) == 0)
			return (NULL);
		break;
	}
	close(pfd[0]);
	close(pfd[1]);

	/*
	 * Construct the /etc/Xdf
	 */

	for( ; --ii >= 0; )
		pbuf[ii] = tolower(pbuf[ii]);

	strcpy(etcdf, "/etc/");
	strcat(&etcdf[5], pbuf);
	strcat(&etcdf[5], "df");

	switch(fork()) {
	case -1:			/* error */
		return (NULL);
	case 0:				/* child */
		execv(etcdf, "");
		return(NULL);
	default:
		if (wait(0) < 0)
			return (NULL);
		break;
	}
	return (!NULL);
}
#endif
