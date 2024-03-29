/* $RCSfile: import.c $$Revision: 1.1 $$Date: 1990/07/02 16:07:11 $ Copyright (c) 1990 Intergraph Corp. */

#include <stdio.h>
#include "../hfiles/import.h"

#ifdef IMPORTS

/* Declarations for each imported symbol present in the shared library.	*/
/* The symbols are included in each of the routines via import.h.	*/


char	*_libFSabs_ = 0,
	*_libFSaccess_ = 0,
	*_libFSacos_ = 0,
	*_libFSasin_ = 0,
	*_libFSatan_ = 0,
	*_libFSatof_ = 0,
	*_libFSatoi_ = 0,
	*_libFSbcopy_ = 0,
	*_libFScalloc_ = 0,
	*_libFSceil_ = 0,
	*_libFSchdir_ = 0,
	*_libFSclose_ = 0,
	*_libFSclosedir_ = 0,
	*_libFScos_ = 0,
	*_libFScreat_ = 0,
	*_libFSctime_ = 0,
	*_libFSdraw_ = 0,
	*_libFSdrawbitmap_ = 0,
	*_libFSexecl_ = 0,
	*_libFSexecle_ = 0,
	*_libFSexeclp_ = 0,
	*_libFSexecv_ = 0,
	*_libFSexecve_ = 0,
	*_libFSexecvp_ = 0,
	*_libFSexit_ = 0,
	*_libFSexp_ = 0,
	*_libFSfabs_ = 0,
	*_libFSfclose_ = 0,
	*_libFSfcntl_ = 0,
	*_libFSfflush_ = 0,
	*_libFSfgetc_ = 0,
	*_libFSfgets_ = 0,
	*_libFSfillpoly_ = 0,
	*_libFSfillpolyset_ = 0,
	*_libFSfloor_ = 0,
	*_libFSfmod_ = 0,
	*_libFSfopen_ = 0,
	*_libFSfork_ = 0,
	*_libFSfprintf_ = 0,
	*_libFSfputc_ = 0,
	*_libFSfputs_ = 0,
	*_libFSfread_ = 0,
	*_libFSfree_ = 0,
	*_libFSfreopen_ = 0,
	*_libFSfscanf_ = 0,
	*_libFSfseek_ = 0,
	*_libFSfstat_ = 0,
	*_libFSftell_ = 0,
	*_libFSftw_ = 0,
	*_libFSfwrite_ = 0,
	*_libFSgetenv_ = 0,
	*_libFSgetpid_ = 0,
	*_libFSgetw_ = 0,
	*_libFSkill_ = 0,
	*_libFSlink_ = 0,
	*_libFSlog_ = 0,
	*_libFSlog10_ = 0,
	*_libFSlseek_ = 0,
	*_libFSlocaltime_ = 0,
	*_libFSmalloc_ = 0,
	*_libFSmatherr_ = 0,
	*_libFSmemccpy_ = 0,
	*_libFSmemchr_ = 0,
	*_libFSmemcmp_ = 0,
	*_libFSmemcpy_ = 0,
	*_libFSmemset_ = 0,
	*_libFSmktemp_ = 0,
	*_libFSmove_ = 0,
	*_libFSmsgctl_ = 0,
	*_libFSmsgget_ = 0,
	*_libFSmsgrcv_ = 0,
	*_libFSmsgsnd_ = 0,
	*_libFSopen_ = 0,
	*_libFSopendir_ = 0,
	*_libFSpnt_ = 0,
	*_libFSpolyf_ = 0,
	*_libFSprintf_ = 0,
	*_libFSputenv_ = 0,
	*_libFSputw_ = 0,
	*_libFSqsort_ = 0,
	*_libFSread_ = 0,
	*_libFSreaddir_ = 0,
	*_libFSrealloc_ = 0,
	*_libFSrectf_ = 0,
	*_libFSrewind_ = 0,
	*_libFSseekdir_ = 0,
	*_libFSsemctl_ = 0,
	*_libFSsemget_ = 0,
	*_libFSsemop_ = 0,
	*_libFSsetbuf_ = 0,
	*_libFSshmat_ = 0,
	*_libFSshmctl_ = 0,
	*_libFSshmdt_ = 0,
	*_libFSshmget_ = 0,
	*_libFSsignal_ = 0,
	*_libFSsin_ = 0,
	*_libFSsleep_ = 0,
	*_libFSsprintf_ = 0,
	*_libFSsqrt_ = 0,
	*_libFSsscanf_ = 0,
	*_libFSstrcat_ = 0,
	*_libFSstrchr_ = 0,
	*_libFSstrcmp_ = 0,
	*_libFSstrcpy_ = 0,
	*_libFSstrdup_ = 0,
	*_libFSstrlen_ = 0,
	*_libFSstrncat_ = 0,
	*_libFSstrncmp_ = 0,
	*_libFSstrncpy_ = 0,
	*_libFSstrpbrk_ = 0,
	*_libFSstrrchr_ = 0,
	*_libFSstrspn_ = 0,
	*_libFSstrtod_ = 0,
	*_libFSstrtok_ = 0,
	*_libFSstrtol_ = 0,
	*_libFSsystem_ = 0,
	*_libFStan_ = 0,
	*_libFStelldir_ = 0,
	*_libFStime_ = 0,
	*_libFStimes_ = 0,
	*_libFStolower_ = 0,
	*_libFStoupper_ = 0,
	*_libFStrapf_ = 0,
	*_libFSungetc_ = 0,
	*_libFSumask_ = 0,
	*_libFSunlink_ = 0,
	*_libFSvfork_ = 0,
	*_libFSvprintf_ = 0,
	*_libFSvfprintf_ = 0,
	*_libFSvsprintf_ = 0,
	*_libFSwait_ = 0,
	*_libFSwrite_ = 0,
	*_libFS_assert_ = 0,
	*_libFS_ctype_ = 0,
	*_libFSiob_ = 0;

#elifdef SHLIB
char	
	*_libFSacos_ = 0,
	*_libFSasin_ = 0,
	*_libFSatan_ = 0,
	*_libFSbcopy_ = 0,
	*_libFScalloc_	= 0,
	*_libFSceil_	 = 0,
	*_libFSclosedir_ = 0,
	*_libFScos_	= 0,
	*_libFSctime_	= 0,
	*_libFSexecl_	= 0,
	*_libFSexecle_	= 0,
	*_libFSexeclp_	= 0,
	*_libFSexecv_	= 0,
	*_libFSexecve_	= 0,
	*_libFSexecvp_	= 0,
	*_libFSexit_	= 0,
	*_libFSexp_	= 0,
	*_libFSfabs_	= 0,
	*_libFSfloor_	= 0,
	*_libFSfmod_	= 0,
	*_libFSfork_	= 0,
	*_libFSfree_	= 0,
	*_libFSfscanf_	= 0,
	*_libFSftell_	= 0,
	*_libFSftw_	= 0,
	*_libFSlink_	= 0,
	*_libFSlog_	= 0,
	*_libFSlog10_	= 0,
	*_libFSlocaltime_ = 0,
	*_libFSmalloc_	= 0,
	*_libFSmatherr_	= 0,
	*_libFSmsgctl_	= 0,
	*_libFSmsgget_	= 0,
	*_libFSmsgrcv_	= 0,
	*_libFSmsgsnd_	= 0,
	*_libFSopendir_	 = 0,
	*_libFSputenv_	= 0,
	*_libFSqsort_	= 0,
	*_libFSreaddir_	= 0,
	*_libFSrealloc_	= 0,
	*_libFSrewind_	= 0,
	*_libFSseekdir_	= 0,
	*_libFSsemctl_	= 0,
	*_libFSsemget_	= 0,
	*_libFSsemop_	= 0,
	*_libFSshmat_	= 0,
	*_libFSshmctl_	= 0,
	*_libFSshmdt_	= 0,
	*_libFSshmget_	= 0,
	*_libFSsignal_	= 0,
	*_libFSsin_	= 0,
	*_libFSsleep_	= 0,
	*_libFSsqrt_	= 0,
	*_libFSsscanf_	= 0,
	*_libFSstrdup_	= 0,
	*_libFSstrpbrk_	= 0,
	*_libFSstrspn_	= 0,
	*_libFSstrtod_	= 0,
	*_libFSstrtok_	= 0,
	*_libFSstrtol_	= 0,
	*_libFSsystem_	= 0,
	*_libFStan_	= 0,
	*_libFStelldir_	= 0,
	*_libFStimes_	= 0,
	*_libFStolower_	= 0,
	*_libFStoupper_	= 0,
	*_libFSumask_	= 0,
	*_libFSvfork_	= 0,
	*_libFSvprintf_	= 0,
	*_libFSvfprintf_	= 0,
	*_libFSvsprintf_	= 0,
	*_libFSwait_ = 0,
	*_libFS_assert_	= 0,
	*_libFS_ctype_	= 0,
	*_libFSiob_	= 0;
#else
int	draw() {printf("WARNING: draw() called!!!\n"); return -1;}
int	drawbitmap() {printf("WARNING: drawbitmap() called!!!\n"); return -1;}
int	move() {printf("WARNING: move() called!!!\n"); return -1;}
#endif
