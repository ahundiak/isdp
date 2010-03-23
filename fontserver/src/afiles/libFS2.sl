#target /usr/shlib/libFS2_s
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
_FSGetKernPairValue			79
__GCShInited				80
__GCShExit					81
__GCShEnter					82
__GCIpcRm					83

#objects
import.o
version.o
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

#objects noload
-ltools_s
-lc_s

#init import.o
	__libFSacos_		_acos
	__libFSasin_		_asin
	__libFSatan_		_atan
	__libFSbcopy_		_bcopy
	__libFScalloc_		_calloc
	__libFSceil_		_ceil
	__libFSclosedir_	_closedir
	__libFScos_		_cos
	__libFSctime_		_ctime
	__libFSexecl_		_execl
	__libFSexecle_		_execle
	__libFSexeclp_		_execlp
	__libFSexecv_		_execv
	__libFSexecve_		_execve
	__libFSexecvp_		_execvp
	__libFSexit_		_exit
	__libFSexp_		_exp
	__libFSfabs_		_fabs
	__libFSfloor_		_floor
	__libFSfmod_		_fmod
	__libFSfork_		_fork
	__libFSfree_		_free
	__libFSfscanf_		_fscanf
	__libFSftell_		_ftell
	__libFSftw_		_ftw
	__libFSlink_		_link
	__libFSlog_		_log
	__libFSlog10_		_log10
	__libFSlocaltime_	_localtime
	__libFSmalloc_		_malloc
	__libFSmatherr_		_matherr
	__libFSmsgctl_		_msgctl
	__libFSmsgget_		_msgget
	__libFSmsgrcv_		_msgrcv
	__libFSmsgsnd_		_msgsnd
	__libFSopendir_		_opendir
	__libFSputenv_		_putenv
	__libFSqsort_		_qsort
	__libFSreaddir_		_readdir
	__libFSrealloc_		_realloc
	__libFSrewind_		_rewind
	__libFSseekdir_		_seekdir
	__libFSsemctl_		_semctl
	__libFSsemget_		_semget
	__libFSsemop_		_semop
	__libFSshmat_		_shmat
	__libFSshmctl_		_shmctl
	__libFSshmdt_		_shmdt
	__libFSshmget_		_shmget
	__libFSsignal_		_signal
	__libFSsin_		_sin
	__libFSsleep_		_sleep
	__libFSsqrt_		_sqrt
	__libFSsscanf_		_sscanf
	__libFSstrdup_		_strdup
	__libFSstrpbrk_		_strpbrk
	__libFSstrspn_		_strspn
	__libFSstrtod_		_strtod
	__libFSstrtok_		_strtok
	__libFSstrtol_		_strtol
	__libFSsystem_		_system
	__libFStan_		_tan
	__libFStelldir_		_telldir
	__libFStimes_		_times
	__libFStolower_		_tolower
	__libFStoupper_		_toupper
	__libFSumask_		_umask
	__libFSvfork_		_vfork
	__libFSvprintf_		_vprintf
	__libFSvfprintf_	_vfprintf
	__libFSvsprintf_	_vsprintf
	__libFSwait_		_wait
	__libFS_assert_		__assert
	__libFS_ctype_		__ctype
	__libFSiob_		__iob
#hide linker
*

#export linker
_Fontserver_appl_version_id
