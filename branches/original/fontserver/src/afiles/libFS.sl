#target /usr/shlib/libFS_s
#address .text 0x83400000
#address .data 0x83800000
#branch

_FSEnter				1
_FSExit					2
_FSNewFont				3
_FSAppendFont				4
_FSDeleteFont				5
_FSReadFontFile				6
_FSWriteFontFile			7
_FSWriteSymbolFile			8
_FSDrawChar				9
_FSDrawText				10
_FSDrawString				11
_FSGetCharVect				12
_FSGetTextVect				13
_FSGetStringVect			14
_FSSetBmapDrawFunc			15
_FSGetBmapDrawFunc			16
__FSDrawBitmap				17
_FSSetRLE8DrawFunc			18
_FSGetRLE8DrawFunc			19
__FSDrawRLE8				20
_FSSetRLE16DrawFunc			21
_FSGetRLE16DrawFunc			22
__FSDrawRLE16				23
_FSSetOutlDrawFunc			24
_FSGetOutlDrawFunc			25
__FSDrawOutline				26
_FSSetOutl3DDrawFunc			27
_FSGetOutl3DDrawFunc			28
__FSDrawOutline3D			29
_FSReadCharMapFile			30
_FSWriteCharMapFile			31
_FSDefCharMap				32
_FSDeleteCharMap			33
_FSSetKernMode				34
_FSGetKernMode				35
_FSSetKernTrack				36
_FSGetKernTrack				37
_FSSetLigMode				38
_FSGetLigMode				39
_FSSetExtraWidth			40
_FSGetExtraWidth			41
_FSGetBmapHeader			42
_FSGetBmapInfo				43
_FSGetBmapKernTable			44
_FSGetBmapLigTable			45
_FSGetBmapCharInfo			46
_FSGetBmapAllCharInfo			47
_FSGetBmapBitmap			48
_FSPutBmapHeader			49
_FSPutBmapInfo				50
_FSPutBmapKernTable			51
_FSPutBmapLigTable			52
_FSPutBmapCharInfo			53
_FSPutBmapBitmap			54
_FSUpdateBmapFont			55
_FSGetOutlHeader			56
_FSGetOutlInfo				57
_FSGetOutlKernTable			58
_FSGetOutlLigTable			59
_FSGetOutlCharInfo			60
_FSGetOutlAllCharInfo			61
_FSGetOutlPolySizes			62
_FSGetOutlVertices			63
_FSGetOutl3DVertices			64
_FSGetTFInfo				65
_FSGetTFKernTable			66
_FSGetTFKernTrack			67
_FSGetTFLigTable			68
_FSGetTFCharDir				69
_FSGetTFOutlines			70
__FSAppendChar				71
__FSMalloc				72
__FSRealloc				73
__FSFree				74
__FSUpdateCharTime			75
__FSInitRecState			76
__FSGetRec				77
_FSGetTypefaces				78

#objects
import.o
FSAlloc.o
FSBitmap.o
FSBmapCach.o
FSCharMap.o
FSConvert.o
FSCrypt.o
FSDaemon.o
FSDoFunc.o
FSDraw.o
FSEnter.o
FSFontCach.o
FSGenCache.o
FSGetBmap.o
FSGetFont.o
FSGetOutl.o
FSGetRec.o
FSGetTF.o
FSIO.o
FSInterpro.o
FSKern.o
FSLoadTF.o
FSMakeFont.o
FSModes.o
FSNewFont.o
FSOutlCach.o
FSPixCache.o
FSPutBmap.o
FSReadFont.o
FSRules.o
FSScanConv.o
FSSplitArc.o
FSSym.o
FSTFCache.o
FSUtil.o
FSWriteFnt.o

#init import.o
	__libFSabs_		_abs
	__libFSaccess_		_access
	__libFSacos_		_acos
	__libFSasin_		_asin
	__libFSatan_		_atan
	__libFSatof_		_atof
	__libFSatoi_		_atoi
	__libFSbcopy_		_bcopy
	__libFScalloc_		_calloc
	__libFSceil_		_ceil
	__libFSchdir_		_chdir
	__libFSclose_		_close
	__libFSclosedir_	_closedir
	__libFScos_		_cos
	__libFScreat_		_creat
	__libFSctime_		_ctime
	__libFSdraw_		_draw
	__libFSdrawbitmap_	_drawbitmap
	__libFSexecl_		_execl
	__libFSexecle_		_execle
	__libFSexeclp_		_execlp
	__libFSexecv_		_execv
	__libFSexecve_		_execve
	__libFSexecvp_		_execvp
	__libFSexit_		_exit
	__libFSexp_		_exp
	__libFSfabs_		_fabs
	__libFSfclose_		_fclose
	__libFSfcntl_		_fcntl
	__libFSfflush_		_fflush
	__libFSfgetc_		_fgetc
	__libFSfgets_		_fgets
	__libFSfillpoly_	_fillpoly
	__libFSfillpolyset_	_fillpolyset
	__libFSfloor_		_floor
	__libFSfmod_		_fmod
	__libFSfopen_		_fopen
	__libFSfork_		_fork
	__libFSfprintf_		_fprintf
	__libFSfputc_		_fputc
	__libFSfputs_		_fputs
	__libFSfread_		_fread
	__libFSfree_		_free
	__libFSfreopen_		_freopen
	__libFSfscanf_		_fscanf
	__libFSfseek_		_fseek
	__libFSfstat_		_fstat
	__libFSftell_		_ftell
	__libFSftw_		_ftw
	__libFSfwrite_		_fwrite
	__libFSgetenv_		_getenv
	__libFSgetpid_		_getpid
	__libFSgetw_		_getw
	__libFSkill_		_kill
	__libFSlink_		_link
	__libFSlog_		_log
	__libFSlog10_		_log10
	__libFSlseek_		_lseek
	__libFSlocaltime_	_localtime
	__libFSmalloc_		_malloc
	__libFSmatherr_		_matherr
	__libFSmemccpy_		_memccpy
	__libFSmemchr_		_memchr
	__libFSmemcmp_		_memcmp
	__libFSmemcpy_		_memcpy
	__libFSmemset_		_memset
	__libFSmktemp_		_mktemp
	__libFSmove_		_move
	__libFSmsgctl_		_msgctl
	__libFSmsgget_		_msgget
	__libFSmsgrcv_		_msgrcv
	__libFSmsgsnd_		_msgsnd
	__libFSopen_		_open
	__libFSopendir_		_opendir
	__libFSpnt_		_pnt
	__libFSpolyf_		_polyf
	__libFSprintf_		_printf
	__libFSputenv_		_putenv
	__libFSputw_		_putw
	__libFSqsort_		_qsort
	__libFSread_		_read
	__libFSreaddir_		_readdir
	__libFSrealloc_		_realloc
	__libFSrectf_		_rectf
	__libFSrewind_		_rewind
	__libFSseekdir_		_seekdir
	__libFSsemctl_		_semctl
	__libFSsemget_		_semget
	__libFSsemop_		_semop
	__libFSsetbuf_		_setbuf
	__libFSshmat_		_shmat
	__libFSshmctl_		_shmctl
	__libFSshmdt_		_shmdt
	__libFSshmget_		_shmget
	__libFSsignal_		_signal
	__libFSsin_		_sin
	__libFSsleep_		_sleep
	__libFSsprintf_		_sprintf
	__libFSsqrt_		_sqrt
	__libFSsscanf_		_sscanf
	__libFSstrcat_		_strcat
	__libFSstrchr_		_strchr
	__libFSstrcmp_		_strcmp
	__libFSstrcpy_		_strcpy
	__libFSstrdup_		_strdup
	__libFSstrlen_		_strlen
	__libFSstrncat_		_strncat
	__libFSstrncmp_		_strncmp
	__libFSstrncpy_		_strncpy
	__libFSstrpbrk_		_strpbrk
	__libFSstrrchr_		_strrchr
	__libFSstrspn_		_strspn
	__libFSstrtod_		_strtod
	__libFSstrtok_		_strtok
	__libFSstrtol_		_strtol
	__libFSsystem_		_system
	__libFStan_		_tan
	__libFStelldir_		_telldir
	__libFStime_		_time
	__libFStimes_		_times
	__libFStolower_		_tolower
	__libFStoupper_		_toupper
	__libFStrapf_		_trapf
	__libFSungetc_		_ungetc
	__libFSumask_		_umask
	__libFSunlink_		_unlink
	__libFSvfork_		_vfork
	__libFSvprintf_		_vprintf
	__libFSvfprintf_	_vfprintf
	__libFSvsprintf_	_vsprintf
	__libFSwait_		_wait
	__libFSwrite_		_write
	__libFS_assert_		__assert
	__libFS_ctype_		__ctype
	__libFSiob_		__iob

#hide linker
*
