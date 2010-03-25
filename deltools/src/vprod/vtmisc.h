#ifndef		NULL
#define		NULL	0
#endif

#ifndef		TRUE
#define		TRUE	1
#define		FALSE	0
#endif

#ifndef		MIN
#define		MIN(a,b)	( ((a) < (b)) ? (a) : (b) )
#define		MAX(a,b)	( ((a) > (b)) ? (a) : (b) )
#endif

#ifndef		ERROR
#define		ERROR		-1
#endif

#ifndef		NO_ERROR
#define		NO_ERROR	0
#endif

#define		MAX_HOST_NAME_LEN	40	/* used in args.c	*/
#define		LOCAL_TYPE	1	/* local terminal		*/
#define		AUX_TYPE	2	/* auxiliary port		*/
#define		NET_TYPE	3	/* network			*/
#define		EXEC_TYPE	4	/* execute command		*/

/* symbol file indices */
#define		COPY_INDEX		0
#define		PASTE_INDEX		1
#define		CLS_INDEX		2
#define		RESET_INDEX		3
#define		RESIZE_INDEX		4
#define		SPACE_INDEX		5
#define		SETUP_INDEX		6
#define		CAT_INDEX		7
#define		RS232_INDEX		8
#define		CHECK_MARK_INDEX	16

/* Get_icon_data return values */
#define		PASTE_VALUE	0
#define		COPY_VALUE	1
#define		CLS_VALUE	2
#define		RESIZE_VALUE	3
#define		RESET_VALUE	4
#define		SETUP_VALUE	5
#define		CAT_VALUE	6
#define		RS232_VALUE	7

/* magic & version numbers for catalog file */
/* Some of these 4-char strings are backwards.  Whoops. */
#define		MAGIC		0x54414356	/* "VCAT" */
#define		VERSION10	0x56312E30	/* "V1.0" */
#define		VERSION11	0x56312E31	/* "V1.1" */
#define		VERSION12	0x56312E32	/* "V1.2" */
#define		VERSION13	0x332E3156	/* "V1.3" */
#define		VERSION14	0x342E3156	/* "V1.3" */

/* scroll bar stuff */
#define		SB_WIDTH	24	/* scroll bar width */

/* vterm miscellaneous symbol file */
#define		SYM_FILE	"/usr/ip32/vt200/icons.sym"

#define	MAX_TITLE	4096	/* max size of window title		*/
#define	MAX_LOGO	16	/* max size of logo			*/
#define	MAX_CMD		4096	/* max size of exec command (-x option)	*/
#define	MAX_SYM		128	/* max size of collapse symbol file name*/


