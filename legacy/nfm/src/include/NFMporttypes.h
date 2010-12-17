/*    This file will contain all the type definitions   */
/*     which may vary on different platforms.           */
/*     MSSP  10 Dec 93.                    */     

/* Added to support SGI Port. 030394 MaC */
/*#ifdef OS_SOLARIS || defined (__sgi)*/
/* Added OS_CLIX for port types  - Jujare 29, Dec 95 */
#if defined OS_SOLARIS || defined (__sgi) || defined OS_CLIX
#define  NFM_UID_T	uid_t
/* Following line added by MVR 16 Dec 1993 */ 
#define  NFM_GID_T	gid_t
#define  NFM_PID_T	pid_t
#define  NFM_SIZE_T	size_t
#define  NFM_MODE_T	mode_t
#else
#define  NFM_UID_T	int
/* Following line added by MVR 16 Dec 1993 */ 
#define  NFM_GID_T	int
#define  NFM_PID_T	int
#define  NFM_SIZE_T	int
#define  NFM_MODE_T	int
#endif
