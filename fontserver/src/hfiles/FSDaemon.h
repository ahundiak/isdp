/* $RCSfile: fsdaemon.h $$Revision: 1.3 $$Date: 1991/11/27 16:35:39 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef DAEMON
#define DAEMON

#include "FS.h"
#include "FSFontCach.h"


#define	MSG_SND_KEY	0x48515346	/* send msg queue key ("FSQ0") */
#define	MSG_RCV_KEY	0x49515346	/* receive msg queue key ("FSQ1") */

#define	DAEMON_PATH	"/usr/ip32/resrc/fontserver/fsdaemon"


/** Message opcodes **/

#define	FS_ACK_MSG			1
#define	FS_ENTER_MSG			2
#define	FS_EXIT_MSG			3
#define	FS_NEWFONT_MSG			4
#define	FS_APPENDFONT_MSG		5
#define	FS_APPENDCHAR_MSG		6
#define	FS_READFONTFILE_MSG		7
#define	FS_DELETEFONT_MSG		8
#define	FS_USEDCHARS_MSG		9


/** Message structures **/

/** NOTE: The following structures are functionally equivalent to the	**/
/**	  msgbuf structure in <sys/msg.h>.  However, due to stupidity	**/
/**	  in the declaration of said structure, it cannot simply be	**/
/**	  included in each of the following structures.			**/


/* Acknowledge messages */

typedef struct
{
    long	mtype;
    long	opcode;
} AckSnd;

typedef struct
{
    long	mtype;
    int		rval;
} AckRcv;


/* FSEnter() message */

typedef struct
{
    long	mtype;
    long	opcode;
} EnterSnd;


/* FSExit() message */

typedef struct
{
    long	mtype;
    long	opcode;
} ExitSnd;


/* FSNewFont() messages */

typedef struct
{
    long	mtype;
    long	opcode;
    uInt32	flags;		/* below */
    int		tfPath;		/* typeface search path offset */
    int		cmPath;		/* typeface search path offset */
    FontSpec	fontSpec;
    RangeSpec	rangeSpec[1];
} NewFontSnd;

#define	FS_NEWFONT_MSG_NO_RANGESPEC	1	/* rangeSpec == NULL	*/
#define	FS_NEWFONT_MSG_CHARMAP_ID	2	/* use char map id	*/

typedef struct
{
    long	mtype;
    int		rval;
    FontNode	**fontNode;
} NewFontRcv;


/* FSAppendFont() messages */

typedef struct
{
    long	mtype;
    long	opcode;
    long	flags;		/* below */
    FontNode	**fontNode;
    RangeSpec	rangeSpec[1];
} AppendFontSnd;

#define	FS_APPENDFONT_MSG_NO_RANGESPEC	1	/* rangeSpec == NULL	*/

typedef struct
{
    long	mtype;
    int		rval;
} AppendFontRcv;


/* _FSAppendChar() messages */

typedef struct
{
    long	mtype;
    long	opcode;
    FontNode	**fontNode;
    CharId	charId;
} AppendCharSnd;

typedef struct
{
    long	mtype;
    int		rval;
} AppendCharRcv;


/* FSReadFontFile() messages */

typedef struct
{
    long	mtype;
    long	opcode;
    int		cwd;		/* current working dir offset	*/
    int		fileName;	/* file name offset		*/
} ReadFontFileSnd;

typedef struct
{
    long	mtype;
    int		rval;
    FontNode	**fontNode;
} ReadFontFileRcv;


/* FSDeleteFont() messages */

typedef struct
{
    long	mtype;
    long	opcode;
    FontNode	**fontNode;
} DeleteFontSnd;

typedef struct
{
    long	mtype;
    int		rval;
} DeleteFontRcv;


/* Used characters message (updates time stamp of characters in cache)	*/

typedef struct
{
    long		mtype;
    long		opcode;
    int			numChars;
    FontCharNode	**charNode[1];
} UsedCharsSnd;


#endif
