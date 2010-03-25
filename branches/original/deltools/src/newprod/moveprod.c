#include	<stdlib.h>
#include	<stdio.h>
#include	<string.h>
#include	<errno.h>
#include	<sys/types.h>
#include	<sys/stat.h>
#ifdef SYSV
#include	<sys/statfs.h>
#include	<sys/fstyp.h>
#endif
#include	<sys/utsname.h>
#include	<unistd.h>
#include	<ftw.h>
#include	<errno.h>
#include	"defs.h"

extern char	*sys_errlist[];
static char	*destdir;	/*set in "move_product"*/
extern char	basedir[STRSIZ];
extern char     sharedfs[STRSIZ];
extern short	verbose;
extern short	makenode;
extern short	shared;
extern struct utsname un;
extern int	copy_file();
extern char	*GetMountPoint();

/*
 * This subroutine is called by the routine "walk" for each
 * file that is encountered in the subtree beginning at the directory
 * "/usr/tmp/XXXXX", where "XXXXX" is the product number of the product
 * that is currently being installed. This routine moves the files 
 * to the destination directory specified in the variable destdir,
 * (local to this file), by creating directories and linking regular files.
 */
int	mov_function(filename, statbuf, rstat)
char *filename;
struct stat *statbuf;
int rstat;
{
    char	destname[STRSIZ];	/*build name of destination file here*/
    char	tmpname[STRSIZ];	/*build destination of busy file here*/
    char	mountpoint[STRSIZ];	/* mountpoint of destdir */
    register char	*charptr;	/*used in moving busy text file*/
    register i;
    
    strcpy(mountpoint, GetMountPoint(destdir));
    sprintf(destname, "%s%s", destdir, filename + 1);  /*skip leading "."*/
    VPRINT1(destname);
    switch (rstat) {
    case FTW_D:
    case FTW_DNR:	     /*creat dir*/
	makedir(destname, statbuf->st_mode, statbuf->st_uid,
		statbuf->st_gid);
	chmod(destname, statbuf->st_mode);
	break;
    case FTW_F:
	/*
	 * try deleting/moving existing file 10 times in case there's
	 * several busy files out in the tmp area.
	 */
	for (i = 0; i < 10 && unlink(destname); i++) {
	    if (errno == ETXTBSY) {	/*attempt to unlink busy file?*/
		charptr = strrchr(destname, '/');
		sprintf(tmpname, "%s/tmp/%s.%d%d", mountpoint,
			charptr?charptr+1:destname, i,getpid());
		VPRINT("Busy file, moving to ", tmpname);
		link(destname, tmpname); /*move busy file*/
	    }
	}
	if (S_ISLNK(statbuf->st_mode)) {
	    if (!(i = readlink(filename, tmpname, STRSIZ))) {
		if (verbose)
		    PRINT "VERBOSE: Cannot read link %s\n", filename);
            }
	    tmpname[i] = '\0';
	    if (symlink(tmpname, destname)) {
		if (verbose)
		    PRINT "VERBOSE: Cannot make symbolic link %s to %s\n",
			  destname, tmpname);
	    }
	} else if (link(filename, destname)) {
	    if (errno == EXDEV) {
		if (verbose) 
		    PRINT "VERBOSE: Cannot link %s to %s, copying the file...\n",
					filename, destname);
	        if (copy_file(filename, destname, verbose, 0)) {
		    PRINT "WARNING: Error copying to %s.  File %s not delivered!\n",
				destname, destname);
		}
	    } else {
		PRINT "WARNING: Error linking to %s\n", destname);
		PRINT "WARNING: file %s not delivered!\n", destname);
	    }
	}
        unlink(filename);	/*this file no longer needed*/
	break;
    case FTW_NS:
	VPRINT("Cannot stat ", destname);
	break;
    }
    return(0);		/*if we fall through, return success*/
}

/*
 * This routine is called after a product has been successfully down-
 * loaded into a temporary directory. It will move the contents of the
 * working directory to the directory that is specified in the parameter
 * "unixdir". The success or failure of the move is returned.
 */
int	move_product(unixdir)
register char	*unixdir;
{
    register char	*charptr;
    char	*ptr;
    struct stat statbuf;	/*filled by "stat" syscall, not used*/
    char	symdir[STRSIZ];
    char	tmpdir[STRSIZ];
    int	rstat;
    extern int	lstat();
#ifdef SYSV
    struct statfs sfbuf;
    char	fstype[16];
#endif

    rstat = stat(unixdir, &statbuf);

#ifndef DONT_SYMLINK
    /*
     * remove a symbolic link if it exists at the destination
     */
#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
    if (!shared && !rstat && !strcmp(un.release, "3.1")) {
#else
    if (!shared && !rstat) {
#endif
	lstat(unixdir, &statbuf);
	if (statbuf.st_mode & S_IFLNK) {
	    rstat = readlink(unixdir, tmpdir, STRSIZ);
	    if (rstat != -1) {
		tmpdir[rstat] = '\0';
		unlink(unixdir);
		PRINT "Symbolic link at %s removed.\n", unixdir);
	        PRINT "The product may be taking up additional space at %s.\n",
	    	      tmpdir);
		rstat = -1;
	    }
	}
    }
#endif

    if (rstat < 0) {
	charptr = unixdir + 1;		/* skip initial '/' */
    
#if defined(clipper) || defined(__clipper__)
#    ifdef SYSV
	/*
	 * If we're on a Cache file system, we've got to move down
	 * past the root level of the file system -- any attempt to
	 * mkdir() in the root directory of a CAFS file system fails.
	 */
	statfs(GetMountPoint(unixdir), &sfbuf, sizeof(struct statfs), 0);
	sysfs(GETFSTYP, sfbuf.f_fstyp, fstype);
	if (!strncmp(fstype, "CAFS", 4) || !strncmp(fstype, "SUBFS", 5)) {
	    charptr = unixdir + strlen(GetMountPoint(unixdir)) + 1;
	}
#    endif
#endif
	while (*charptr != '\0') {
	    /* step through full path name attempting to create */
	    /* any req'd directories*/
	    switch (*charptr) {
	    case '/':
		*charptr = '\0';
		if (makedir(unixdir, CREAT_DIRMODE, 0, 0))
		    VPRINT("Error creating product directory ", unixdir);
		*charptr = '/';		/*fall through*/
	    default:
		++charptr;
		break;
	    }
	}
    }

    /*
     * The homebrew function "walk" is used instead of the standard
     * ftw() function because walk is specially written to recognize
     * symbolic links (using lstat()) and COPY them, instead of blindly
     * following them, as "ftw()" does.
     */
    destdir = unixdir;			/*cannot pass this via "walk"*/
    if (walk(".", mov_function, 17))
	return(1);

    /*
     * avoid making a symbolic link for makenode directories
     */
    if (makenode)
	return(0);

#ifndef DONT_SYMLINK
#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
    if (!shared && strncmp(unixdir, "/usr/", 5) && strcmp(un.release, "3.0")) {
#else
    if (!shared && strncmp(unixdir, "/usr/", 5)) {
#endif
	/*
	 * make a symbolic link to /usr
	 */

	/* Fixes problem where it wouldn't create the symdir
	 * right -- just skipped past the first directory
	 * instead of the whole mount point.
	 *
         * 1/22/92      Sometimes people hand in a basedir that isn't
         *              really a mounted file system.  Guess we have
         *              to handle it.
         */
        if (strcmp(basedir, GetMountPoint(basedir)) != 0)
            sprintf(symdir, "/usr%s", unixdir+strlen(basedir));
        else
	    sprintf(symdir, "/usr%s", unixdir+strlen(GetMountPoint(unixdir)));
	
	/*
	 * Make sure parent directory of symdir exists
	 * otherwise symlink will fail.
	 */
	strcpy(tmpdir, symdir);
	ptr = strrchr(tmpdir, '/');
	*ptr = 0;
	if (access(tmpdir, F_OK)) {
	    if (errno == ENOENT) 
		mkdirp(tmpdir, 0755);
	}

	rstat = lstat(symdir, &statbuf);
	if (!rstat && (statbuf.st_mode & S_IFLNK)) {
	    /*
	     * A symbolic link already exists ... follow it.
	     */
	    rstat = readlink(symdir, tmpdir, STRSIZ);
	    if (rstat != -1) {
		tmpdir[rstat] = '\0';
		if (strcmp(tmpdir, unixdir) != 0) {
		    /*
		     * Symlink is pointing somewhere else; let's remove it.
		     */
		    unlink(symdir);
		    PRINT "Symbolic link at %s removed.\n", symdir);
		    PRINT "The product may be taking up additional space at %s.\n",
			  tmpdir);
		    rstat = -1;
		}
	       	else {
		    /*
		     * Symlink is pointing to the correct location already.
		     * No need to disturb it.
		     */
		    rstat = 0;
		}
	    }
	}
	if (rstat) {
	    if (!symlink(unixdir, symdir))
		PRINT "%s is symbolically linked to %s.\n", unixdir, symdir);
	    else
		PRINT "Symbolic link from %s to %s failed -- %s\n.",
    			unixdir, symdir, sys_errlist[errno]);
	}
    }
#endif
    return(0);
}
