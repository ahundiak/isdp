#ifndef  TRUE
#define  TRUE 		1
#endif

#ifndef  FALSE
#define  FALSE 		0
#endif

#define	 H_DISK		720
#define  F_DISK		722
#define  O_DISK		724
#define  JUKE_BOX	726
#define  M_TAPE		730
#define  C_TAPE		732
#define	 U_TAPE		734
#define  CACHE		736
#define  TJB		738
#define  NFM_ARCHIVE_P  752
#define  NFM_BACKUP_P   782
#define  NFM_RETRIEVE_P 812
#define  UTI_ARCHIVE    100
#define  UTI_BACKUP     200
#define  UTI_RESTORE    300
#define	 UTIDELIM	':'
#define	 UTIWILD_CARD   "*"
#define  UTI_COMMENT_UNIX "#  "
#define  UTI_COMMENT_VMS  "$ ! "

# ifdef OS_UNIX
# 	include <sys/types.h>
#	include <sys/stat.h>
#	define  LEAD_CHAR	""
#	define  DEL_CMD		"rm "
#	define  PATH_CHAR	'/'
#	define  MOVE_CMD	"mv "
#	define  TYPE_CMD	"pg "
#	define  CUR_DIR		". "
#	define  SYS_PROMPT	""
#	define	VERS		""
#	define  WRK_DIR		"./"
# endif
# if VMS
# 	include <types.h>
# 	include <stat.h>
#	define  LEAD_CHAR	"@"
#	define  DEL_CMD		"del "
#	define  PATH_CHAR  	']'
#	define  MOVE_CMD	"rename "
#	define  TYPE_CMD	"type "
#	define  CUR_DIR		"[] "
#	define  SYS_PROMPT	"$ "
# 	define  VERS		";0"
#	define  WRK_DIR		"[]"
# endif
