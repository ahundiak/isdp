/* $RCSfile: import.h $$Revision: 1.2 $$Date: 1994/12/14 19:43:20 $ Copyright (c) 1990 Intergraph Corp. */

#ifdef IMPORTS

#define	abs		(*_libFSabs_)
#define	acos		(*_libFSacos_)		/* declared in math.h	*/
#define	access		(*_libFSaccess_)
#define	asin		(*_libFSasin_)		/* declared in math.h	*/
#define	atan		(*_libFSatan_)		/* declared in math.h	*/
#define atof		(*_libFSatof_)		/* declared in math.h	*/
#define atoi		(*_libFSatoi_)
#define	bcopy		(*_libFSbcopy_)
#define	calloc		(*_libFScalloc_)
#define	ceil		(*_libFSceil_)		/* declared in math.h	*/
#define	chdir		(*_libFSchdir_)
#define close		(*_libFSclose_)
#define	closedir	(*_libFSclosedir_)	/* declared in dirent.h */
#define	cos		(*_libFScos_)		/* declared in math.h	*/
#define	creat		(*_libFScreat_)
#define	ctime		(*_libFSctime_)
#define	draw		(*_libFSdraw_)
#define	drawbitmap	(*_libFSdrawbitmap_)
#define	execl		(*_libFSexecl_)
#define	execle		(*_libFSexecle_)
#define	execlp		(*_libFSexeclp_)
#define	execv		(*_libFSexecv_)
#define	execve		(*_libFSexecve_)
#define	execvp		(*_libFSexecvp_)
#define	exit		(*_libFSexit_)
#define	exp		(*_libFSexp_)		/* declared in math.h	*/
#define	fabs		(*_libFSfabs_)		/* declared in math.h	*/
#define	fclose		(*_libFSfclose_)	/* declared in stdio.h	*/
#define	fcntl		(*_libFSfcntl_)
#define	fflush		(*_libFSfflush_)	/* declared in stdio.h	*/
#define	fgetc		(*_libFSfgetc_)		/* declared in stdio.h	*/
#define	fgets		(*_libFSfgets_)		/* declared in stdio.h	*/
#define	fillpoly	(*_libFSfillpoly_)
#define	fillpolyset	(*_libFSfillpolyset_)
#define	floor		(*_libFSfloor_)		/* declared in math.h	*/
#define	fmod		(*_libFSfmod_)		/* declared in math.h	*/
#define	fopen		(*_libFSfopen_)		/* declared in stdio.h	*/
#define	fork		(*_libFSfork_)
#define	fprintf		(*_libFSfprintf_)	/* declared in stdio.h	*/
#define	fputc		(*_libFSfputc_)		/* declared in stdio.h	*/
#define	fputs		(*_libFSfputs_)		/* declared in stdio.h	*/
#define	fread		(*_libFSfread_)		/* declared in stdio.h	*/
#define	free		(*_libFSfree_)		/* declared in malloc.h	*/
#define	freopen		(*_libFSfreopen_)	/* declared in stdio.h	*/
#define	fscanf		(*_libFSfscanf_)	/* declared in stdio.h	*/
#define	fseek		(*_libFSfseek_)		/* declared in stdio.h	*/
#define fstat		(*_libFSfstat_)
#define	ftell		(*_libFSftell_)		/* declared in stdio.h	*/
#define ftw		(*_libFSftw_)
#define	fwrite		(*_libFSfwrite_)	/* declared in stdio.h	*/
#define	getenv		(*_libFSgetenv_)
#define	getpid		(*_libFSgetpid_)
#define	getw		(*_libFSgetw_)		/* declared in stdio.h	*/
#define kill		(*_libFSkill_)
#define	link		(*_libFSlink_)
#define	log		(*_libFSlog_)		/* declared in math.h	*/
#define	log10		(*_libFSlog10_)		/* declared in math.h	*/
#define	lseek		(*_libFSlseek_)
#define	localtime	(*_libFSlocaltime_)
#define	malloc		(*_libFSmalloc_)	/* declared in malloc.h	*/
#define	matherr		(*_libFSmatherr_)	/* declared in math.h	*/
#define	memccpy		(*_libFSmemccpy_)	/* declared in memory.h	*/
#define	memchr		(*_libFSmemchr_)	/* declared in memory.h	*/
#define	memcmp		(*_libFSmemcmp_)	/* declared in memory.h	*/
#define	memcpy		(*_libFSmemcpy_)	/* declared in memory.h	*/
#define	memset		(*_libFSmemset_)	/* declared in memory.h	*/
#define mktemp		(*_libFSmktemp_)
#define	move		(*_libFSmove_)
#define	msgctl		(*_libFSmsgctl_)
#define msgget		(*_libFSmsgget_)
#define msgrcv		(*_libFSmsgrcv_)
#define msgsnd		(*_libFSmsgsnd_)
#define	open		(*_libFSopen_)
#define	opendir		(*_libFSopendir_)	/* declared in dirent.h */
#define	pnt		(*_libFSpnt_)
#define	polyf		(*_libFSpolyf_)
#define	printf		(*_libFSprintf_)	/* declared in stdio.h	*/
#define	putenv		(*_libFSputenv_)
#define	putw		(*_libFSputw_)		/* declared in stdio.h	*/
#define	qsort		(*_libFSqsort_)
#define	read		(*_libFSread_)
#define	readdir		(*_libFSreaddir_)	/* declared in dirent.h */
#define	realloc		(*_libFSrealloc_)	/* declared in malloc.h	*/
#define	rectf		(*_libFSrectf_)
#define	rewind		(*_libFSrewind_)
#define	seekdir		(*_libFSseekdir_)	/* declared in dirent.h */
#define	semctl		(*_libFSsemctl_)
#define	semget		(*_libFSsemget_)
#define	semop		(*_libFSsemop_)
#define	setbuf		(*_libFSsetbuf_)
#define	shmat		(*_libFSshmat_)
#define	shmctl		(*_libFSshmctl_)
#define	shmdt		(*_libFSshmdt_)
#define	shmget		(*_libFSshmget_)
#define	signal		(*_libFSsignal_)
#define	sin		(*_libFSsin_)		/* declared in math.h	*/
#define	sleep		(*_libFSsleep_)
#define	sprintf		(*_libFSsprintf_)	/* declared in stdio.h	*/
#define	sqrt		(*_libFSsqrt_)		/* declared in math.h	*/
#define	sscanf		(*_libFSsscanf_)	/* declared in stdio.h	*/
#define	strcat		(*_libFSstrcat_)	/* declared in string.h	*/
#define strchr		(*_libFSstrchr_)	/* declared in string.h	*/
#define	strcmp		(*_libFSstrcmp_)	/* declared in string.h	*/
#define	strcpy		(*_libFSstrcpy_)	/* declared in string.h	*/
#define	strdup		(*_libFSstrdup_)	/* declared in string.h	*/
#define	strlen		(*_libFSstrlen_)	/* declared in string.h	*/
#define	strncat		(*_libFSstrncat_)	/* declared in string.h	*/
#define	strncmp		(*_libFSstrncmp_)	/* declared in string.h	*/
#define	strncpy		(*_libFSstrncpy_)	/* declared in string.h	*/
#define	strpbrk		(*_libFSstrpbrk_)	/* declared in string.h	*/
#define strrchr		(*_libFSstrrchr_)	/* declared in string.h	*/
#define	strspn		(*_libFSstrspn_)	/* declared in string.h	*/
#define	strtod		(*_libFSstrtod_)
#define	strtok		(*_libFSstrtok_)	/* declared in string.h	*/
#define	strtol		(*_libFSstrtol_)
#define	system		(*_libFSsystem_)
#define	tan		(*_libFStan_)		/* declared in math.h	*/
#define	telldir		(*_libFStelldir_)	/* declared in dirent.h */
#define	time		(*_libFStime_)
#define	times		(*_libFStimes_)
#define	tolower		(*_libFStolower_)
#define	toupper		(*_libFStoupper_)
#define	trapf		(*_libFStrapf_)
#define	ungetc		(*_libFSungetc_)	/* declared in stdio.h	*/
#define	umask		(*_libFSumask_)
#define	unlink		(*_libFSunlink_)
#define	vfork		(*_libFSvfork_)
#define	vprintf		(*_libFSvprintf_)	/* declared in stdio.h	*/
#define	vfprintf	(*_libFSvfprintf_)	/* declared in stdio.h	*/
#define	vsprintf	(*_libFSvsprintf_)	/* declared in stdio.h	*/
#define	wait		(*_libFSwait_)
#define	write		(*_libFSwrite_)
#define	_assert		(*_libFS_assert_)
#define _ctype		(*_libFS_ctype_)	/* declared in ctype.h	*/
#define _iob		(*_libFSiob_)		/* declared in stdio.h	*/
#else
#ifdef	SHLIB
#define	acos	(*_libFSacos_)		
#define asin	(*_libFSasin_)
#define atan	(*_libFSatan_)
#define	bcopy	(*_libFSbcopy_)
#define	calloc	(*_libFScalloc_)
#define	ceil	(*_libFSceil_)	
#define	closedir	(*_libFSclosedir_)
#define	cos	(*_libFScos_)	
#define	ctime	(*_libFSctime_)	
#define	execl	(*_libFSexecl_)	
#define	execle	(*_libFSexecle_)
#define	execlp	(*_libFSexeclp_)
#define	execv	(*_libFSexecv_)	
#define	execve	(*_libFSexecve_)
#define	execvp	(*_libFSexecvp_)
#define	exit	(*_libFSexit_)	
#define	exp	(*_libFSexp_)	
#define	fabs	(*_libFSfabs_)	
#define	floor	(*_libFSfloor_)	
#define	fmod	(*_libFSfmod_)	
#define	fork	(*_libFSfork_)	
#define	free	(*_libFSfree_)	
#define	fscanf	(*_libFSfscanf_)
#define	ftell	(*_libFSftell_)	
#define	ftw	(*_libFSftw_)	
#define	link	(*_libFSlink_)	
#define	log	(*_libFSlog_)	
#define	log10	(*_libFSlog10_)	
#define	localtime (*_libFSlocaltime_)
#define malloc	(*_libFSmalloc_)
#define	matherr	(*_libFSmatherr_)
#define	msgctl	(*_libFSmsgctl_)
#define	msgget	(*_libFSmsgget_)
#define	msgrcv	(*_libFSmsgrcv_)
#define	msgsnd	(*_libFSmsgsnd_) 
#define	opendir	(*_libFSopendir_)
#define	putenv	(*_libFSputenv_)
#define	qsort	(*_libFSqsort_)	
#define	readdir	(*_libFSreaddir_)
#define	realloc	(*_libFSrealloc_)
#define	rewind	(*_libFSrewind_)
#define	seekdir	(*_libFSseekdir_)
#define	semctl	(*_libFSsemctl_)
#define	semget	(*_libFSsemget_)
#define	semop	(*_libFSsemop_)	
#define	shmat	(*_libFSshmat_)	
#define	shmctl	(*_libFSshmctl_)
#define	shmdt	(*_libFSshmdt_)	
#define	shmget	(*_libFSshmget_)
#define	signal	(*_libFSsignal_)
#define	sin	(*_libFSsin_)	
#define	sleep	(*_libFSsleep_)	
#define	sqrt	(*_libFSsqrt_)	
#define	sscanf	(*_libFSsscanf_)
#define	strdup	(*_libFSstrdup_)
#define	strpbrk	(*_libFSstrpbrk_)
#define	strspn	(*_libFSstrspn_)
#define	strtod	(*_libFSstrtod_)
#define	strtok	(*_libFSstrtok_)
#define	strtol	(*_libFSstrtol_)
#define	system	(*_libFSsystem_)
#define	tan	(*_libFStan_)	
#define	telldir	(*_libFStelldir_)
#define	times	(*_libFStimes_)	
#define	tolower	(*_libFStolower_)
#define	toupper	(*_libFStoupper_)
#define	umask	(*_libFSumask_)	
#define	vfork	(*_libFSvfork_)	
#define	vprintf	(*_libFSvprintf_)
#define	vfprintf (*_libFSvfprintf_)
#define	vsprintf (*_libFSvsprintf_)
#define	wait	(*_libFSwait_)	
#define	_assert	(*_libFS_assert_)
#define	_ctype	(*_libFS_ctype_)
#define	_iob	(*_libFSiob_)	
#endif
#endif

#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>

extern int	abs();
extern int	access();
extern int	atoi();
extern void	bcopy();
extern void	*calloc(unsigned int, unsigned int);
extern int	chdir();
extern int	close();
extern int	creat __((const char *path, mode_t mode));
extern int	draw();
extern int	drawbitmap();
extern int	execl __((const char *, const char *, ...));
extern int	execle __((const char *, const char *, ...));
extern int	execlp __((const char *, const char *, ...));
extern int	execv();
extern int	execve();
extern int	execvp();
extern void	exit();
extern int	fcntl __((int fd, int cmd, ...));
extern int	fillpoly();
extern int	fillpolyset();
extern pid_t	fork __((void));
extern int	fstat();
extern int	ftw();
extern char	*getenv();
extern pid_t	getpid __((void));
extern int	kill __((pid_t pid, int sig));
extern int	link();
extern long	lseek();
extern char	*mktemp();
extern int	move();
extern int	msgctl __((int, int, ...));
extern int	msgget();
extern int	msgrcv __((int, struct msgbuf *, int, long, int));
extern int	msgsnd __((int, struct msgbuf *, int, int));
extern int	open __((const char *path, int oflag, ...));
extern int	pnt();
extern int	polyf();
extern int	putenv();
extern void	qsort();
extern int	read();
extern int	rectf();
extern void	rewind();
extern int	semctl __((int, int, int, ...));
extern int	semget();
extern int	semop();
extern void	setbuf();
extern char	*shmat();
extern int	shmctl();
extern int	shmdt();
extern int	shmget();
extern void	(*signal())();
extern unsigned	sleep();
extern double	strtod();
extern long	strtol();
extern int	system();
extern long	time();
extern long	times();
extern int	tolower();
extern int	toupper();
extern int	trapf();
extern mode_t	umask __((mode_t cmask));
extern int	unlink();
extern int	vfork();
extern int	wait();
extern int	write();
extern void	_assert();
