/* $Revision: 1.1 $ */
/*
 *	(c) Copyright 1990, Natural Language Incorporated, All Rights Reserved
 *	Copyright notice is precautionary and does not imply publication or
 *	disclosure
 *
 *	This Document/File Contains Proprietary Information, it may not be
 *	copied or disclosed without written permission.
 */

#ifndef _nlc_defined_
#define _nlc_defined_

#ifndef nlc_impl_defined
typedef unsigned long 		Nl_opaque;
typedef Nl_opaque		Nl_session;
#endif

#ifndef FnArgs
#ifdef NeedFunctionPrototypes
#define FnArgs(x)		x
#else
#define FnArgs(x)
#endif
#endif

typedef enum {
	NL_SUCCESS =		0,
	NL_NO_MORE =		1,
	NL_NEED_REPLY =		2,
	NL_WARNING = 		3,
	NL_FAIL =		-1
} Nl_status;

typedef enum {
	NLCOL_INT =		1,
	NLCOL_FLOAT =		2,
	NLCOL_CHAR =		3,
	NLCOL_DATE =		4
} Nl_col_type;

typedef struct {
	int			year;
	unsigned int		month:8;
	unsigned int		day:8;
	unsigned int		hour:8;
	unsigned int		minute:8;
	float			second;
} Nl_datetime;

typedef struct {
	char		*sysmap;
	char		*host;
	char		*user;
	char		*pass;
} Nl_rconnect;

#define NL_ATTR(pkg, type, serial) (((unsigned)pkg<<16)|((unsigned)serial<<8)|(unsigned)type)
#define NL_ATTR_BASE_TYPE(attr)	((unsigned)(attr)&0xF)
#define NL_ATTR_CARDINALITY(attr) (((unsigned)(attr)>>4)&0xF)
#define NL_ATTR_SERIAL(attr)	(((unsigned)(attr)>>8)&0xFF)
#define NL_ATTR_PKG(attr)	(((unsigned)(attr)>>16)&0xFF)
#define NL_ATTR_TYPE(type, cardinality) ((type)|((cardinality)<<4))
#define NL_BAS_ATTR(type, serial) NL_ATTR(NL_PKG_BASE, type, serial)
#define NL_COL_ATTR(type, serial) NL_ATTR(NL_PKG_COL, type, serial)
#define NL_TAB_ATTR(type, serial) NL_ATTR(NL_PKG_TAB, type, serial)
#define NL_FTE_ATTR(type, serial) NL_ATTR(NL_PKG_FRONTEND, type, serial)
#define NL_BKE_ATTR(type, serial) NL_ATTR(NL_PKG_BACKEND, type, serial)
#define NL_ATTR_INDEX_INT	NL_ATTR_TYPE(NL_ATTR_INT, 2)

typedef enum {
	NL_ATTR_INT = 		1,
	NL_ATTR_STRING =	2,
	NL_ATTR_OPAQUE =	3
} Nl_attr_base_type;

typedef enum {
	NL_PKG_BASE =		0,
	NL_PKG_TAB=		1,
	NL_PKG_COL=		2,
	NL_PKG_FRONTEND =	3,
	NL_PKG_BACKEND =	4
} Nl_pkg;

typedef unsigned long		Nl_attr;

#define	NL_RESPONSE_MODE  	NL_BKE_ATTR(NL_ATTR_INDEX_INT,	1)
#define	NL_TABLE_COUNT	 	NL_BKE_ATTR(NL_ATTR_INT,	2)
#define	NL_RESPONSE_TYPE	NL_BKE_ATTR(NL_ATTR_INT,	3)
#define	NL_BDEBUG		NL_BKE_ATTR(NL_ATTR_INT,	4)
#define	NL_END_LINES		NL_BKE_ATTR(NL_ATTR_INT,	5)
#define	NL_LISPERR_STRING	NL_BKE_ATTR(NL_ATTR_STRING,	6)
#define	NL_SRVR_PVERSION	NL_BKE_ATTR(NL_ATTR_INT,	7)
#define	NL_DEBUG 		NL_FTE_ATTR(NL_ATTR_INT,	1)
#define	NL_ERROR_CODE		NL_FTE_ATTR(NL_ATTR_INT,	2)
#define	NL_ERROR_STRING		NL_FTE_ATTR(NL_ATTR_STRING,	3)
#define	NL_ERROR_PROC		NL_FTE_ATTR(NL_ATTR_OPAQUE,	4)
#define	NL_SYSERR_CODE	 	NL_FTE_ATTR(NL_ATTR_INT,	5)
#define	NL_SYSERR_STRING	NL_FTE_ATTR(NL_ATTR_STRING,	6)
#define	NL_WAIT_CHAN		NL_FTE_ATTR(NL_ATTR_INT,	7)
#define	NL_READ_CHAN		NL_FTE_ATTR(NL_ATTR_INT,	8)
#define	NL_WRITE_CHAN		NL_FTE_ATTR(NL_ATTR_INT,	9)
#define	NL_USER_DATA	 	NL_FTE_ATTR(NL_ATTR_INT,	10)
#define	NL_CLNT_PVERSION	NL_FTE_ATTR(NL_ATTR_INT,	11)
#define	NL_READ_IOSB		NL_FTE_ATTR(NL_ATTR_INT,	12)
#define	NL_RCONNECT_PROTOCOL	NL_FTE_ATTR(NL_ATTR_OPAQUE,	13)
#define	NL_RCONNECT_ARGS	NL_FTE_ATTR(NL_ATTR_OPAQUE,	14)
#define	NL_COLUMN_COUNT		NL_TAB_ATTR(NL_ATTR_INT,	1)
#define	NL_COLUMN_NAME		NL_COL_ATTR(NL_ATTR_STRING,	2)
#define	NL_COLUMN_TYPE		NL_COL_ATTR(NL_ATTR_INT,	3)
#define	NL_COLUMN_HEADER	NL_COL_ATTR(NL_ATTR_STRING,	4)
#define	NL_COLUMN_DATA		NL_COL_ATTR(NL_ATTR_OPAQUE,	5)
#define	NL_COLUMN_WIDTH		NL_COL_ATTR(NL_ATTR_INT,	6)
#define	NL_COLUMN_NULL		NL_COL_ATTR(NL_ATTR_INT,	7)

typedef enum {
	NL_ALL_TEXT = 		1, 	/* everything */
	NL_TEXT =		2,	/* other text */
	NL_ECHO =		3,	/* echo text */
	NL_ANSWER = 		4,	/* answer text */
	NL_TABLE =		5, 	/* table text */
	NL_QUERY =		6,	/* SQL */
	NL_TABLE_DATA =		7,	/* table binary data */
	NL_ERROR_MESSAGE = 	8,	/* error message */
	NL_PROMPT = 		9	/* prompt */
} Nl_response_item;

#define NL_RESTATEMENT		NL_ECHO

extern void		nl_init();

extern Nl_session	nl_connect(
#if NeedFunctionPrototypes
 char * 		/* prog */,
 char *			/* options */
#endif
 );

extern Nl_status	nl_eval(
#if NeedFunctionPrototypes
 Nl_session		/* nlc */,
 char *			/* exp */,
 char *			/* ans */,
 int			/* len */,
 int *			/* retlen */
#endif
);

extern Nl_status	nl_eval_a(
#if NeedFunctionPrototypes
 Nl_session		/* nlc */,
 char *			/* exp */,
 char *			/* ans */,
 int			/* len */,
 int *			/* retlen */,
 Nl_status *		/* exitstatus */,
 void (*)()		/* exitfun */,
 long			/* exitprm */
#endif
);

extern Nl_status	nl_logon(
#if NeedFunctionPrototypes
 Nl_session 		/* nlc */,
 char *			/* options */
#endif
);

extern Nl_status	nl_ask(
#if NeedFunctionPrototypes
 Nl_session 		/* nlc */,
 char *			/* cmd */
#endif
);

extern Nl_status	nl_ask_a(
#if NeedFunctionPrototypes
 Nl_session 		/* nlc */,
 char *			/* cmd */,
 Nl_status *		/* exitstatus */,
 void (*)()		/* exitfun */,
 long			/* exitprm */
#endif
);

extern Nl_status	nl_reply(
#if NeedFunctionPrototypes
 Nl_session 		/* nlc */,
 char *			/* cmd */
#endif
);

extern Nl_status	nl_reply_a(
#if NeedFunctionPrototypes
 Nl_session 		/* nlc */,
 char *			/* cmd */,
 Nl_status *		/* exitstatus */,
 void (*)()		/* exitfun */,
 long			/* exitprm */
#endif
);

extern Nl_opaque	nl_get( /* Nl_session , Nl_attr */);
extern Nl_status	nl_set( /* Nl_session , Nl_attr */);

extern Nl_status	nl_open(
#if NeedFunctionPrototypes
 Nl_session 		/* nlc */,
 Nl_response_item	/* item */
#endif
);

extern Nl_status	nl_open_a(
#if NeedFunctionPrototypes
 Nl_session 		/* nlc */,
 Nl_response_item	/* item */
 Nl_status *		/* exitstatus */,
 void (*)()		/* exitfun */,
 long			/* exitprm */
#endif
);

extern Nl_status	nl_close(
#if NeedFunctionPrototypes
 Nl_session 		/* nlc */,
 Nl_response_item	/* item */
#endif
);

extern Nl_status	nl_close_a(
#if NeedFunctionPrototypes
 Nl_session 		/* nlc */,
 Nl_response_item	/* item */
 Nl_status *		/* exitstatus */,
 void (*)()		/* exitfun */,
 long			/* exitprm */
#endif
);

extern Nl_status	nl_fetch(
#if NeedFunctionPrototypes
 Nl_session		/* nlc */,
 Nl_response_item	/* item */,
 char *			/* ans */,
 int 			/* len */,
 int *			/* retlen */
#endif
);

extern Nl_status	nl_fetch_a(
#if NeedFunctionPrototypes
 Nl_session		/* nlc */,
 Nl_response_item	/* item */,
 char *			/* ans */,
 int 			/* len */,
 int *			/* retlen */
 Nl_status *		/* exitstatus */,
 void (*)()		/* exitfun */,
 long			/* exitprm */
#endif
);

extern Nl_status	nl_fetchrow(
#if NeedFunctionPrototypes
 Nl_session		/* nlc */
#endif
);

extern Nl_status	nl_fetchrow_a(
#if NeedFunctionPrototypes
 Nl_session		/* nlc */
 Nl_status *		/* exitstatus */,
 void (*)()		/* exitfun */,
 long			/* exitprm */
#endif
);

extern void		nl_exit(
#if NeedFunctionPrototypes
 Nl_session		/* nlc */
#endif
);

extern Nl_status	nl_break(
#if NeedFunctionPrototypes
 Nl_session		/* nlc */
#endif
);

extern Nl_status	nl_break_a(
#if NeedFunctionPrototypes
 Nl_session		/* nlc */
 Nl_status *		/* exitstatus */,
 void (*)()		/* exitfun */,
 long			/* exitprm */
#endif
);

extern Nl_status	nl_datechar(
#if NeedFunctionPrototypes
 Nl_datetime *		/* datetime */,
 char *			/* string */,
 int			/* len */,
 char *			/* format */
#endif
);

extern void		nl_readmesg(
#if NeedFunctionPrototypes
 Nl_session		/* nlc */
 int			/* nowait */
#endif
);

#endif /* _nlc_defined_ */
