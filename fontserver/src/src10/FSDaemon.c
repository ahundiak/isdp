/* $RCSfile: fsdaemon.c $$Revision: 1.5 $$Date: 1992/10/25 10:37:02 $ Copyright (c) 1990 Intergraph Corp. */

#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <string.h>
#include <memory.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSCharMap.h"
#include "../hfiles/FSFontCach.h"
#include "../hfiles/FSGenCache.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSDaemon.h"


int	_FSDaemon = FALSE;		/* T: I am the daemon		*/

extern char	_FSTFPathVar[];		/* tf search path env variable */
extern char	_FSCMPathVar[];		/* cm search path env variable */


static	int	myPid;			/* process id			*/

static	int	msgQSnd;		/* message queue to daemon	*/
static	int	msgQRcv;		/* message queue from daemon	*/


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSDaemonInit ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine kicks off the shared memory daemon.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

int _FSDaemonInit (void)
{
#ifdef SHFONT

    int	pid, count;

    myPid = getpid ();

    msgQSnd = msgget (MSG_SND_KEY, 0666);
    msgQRcv = msgget (MSG_RCV_KEY, 0666);

    /** If either message queue doesn't exist, kick off the	**/
    /** daemon, which will create them.				**/
    if ((msgQSnd == -1) || (msgQRcv == -1) ||
	(_FSDaemonAcknowledge () != FS_NO_ERROR))
    {
	pid = vfork ();
	if (pid == 0)
	{
	    execl (DAEMON_PATH, DAEMON_PATH, 0);
	    _FSAssert (FALSE);		/* exec failed */
	    return (FS_DAEMON_ERROR);
	}
	else if (pid == -1)
	    return (FS_DAEMON_ERROR);

	/** Wait for message queues to be created **/
	for (count = 20;;)
	{
	    if (msgQSnd == -1)
		msgQSnd = msgget (MSG_SND_KEY, 0666);
	    if (msgQRcv == -1)
		msgQRcv = msgget (MSG_RCV_KEY, 0666);

	    if ((msgQSnd != -1) && (msgQRcv != -1))
		break;

	    if (--count == 0)
		return (FS_DAEMON_ERROR);
	    sleep (1);
	}
    }

    return (_FSDaemonAcknowledge ());	/* wait until daemon is ready */

#endif
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSDaemonAcknowledge ()					*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine verifies that the daemon exists by sending it	*/
/*	  a message and waiting for a period of time for the reply.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the daemon does not exist				*/
/*		- the daemon has a problem				*/
/*									*/
/************************************************************************/

int _FSDaemonAcknowledge (void)
{
#ifdef SHFONT

    int		count;
    AckSnd	aSnd;
    AckRcv	aRcv;

    aSnd.mtype = myPid;
    aSnd.opcode = FS_ACK_MSG;

#ifdef SHLIB	/* errno isn't imported in import version of FS shlib */
    {
    int rval;
    do
	rval = msgsnd (msgQSnd, (struct msgbuf *)&aSnd,
			sizeof (AckSnd) - sizeof (long), 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
    }
#else
    msgsnd (msgQSnd, (struct msgbuf *) &aSnd,
			sizeof (AckSnd) - sizeof (long), 0);
#endif

    for (count = 20;;)
    {
	if (msgrcv (msgQRcv, (struct msgbuf *)&aRcv,
			sizeof (AckRcv) - sizeof (long), myPid,
		    IPC_NOWAIT) >= 0)
	    return (FS_NO_ERROR);

	    if (--count == 0)
		return (FS_DAEMON_ERROR);
	    sleep (1);
    }

#endif
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSDaemonEnter ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sends the FSEnter command to the daemon.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  FS_NO_ERROR							*/
/*									*/
/************************************************************************/

int _FSDaemonEnter (void)
{
#ifdef SHFONT

    EnterSnd	enSnd;

    enSnd.mtype = myPid;
    enSnd.opcode = FS_ENTER_MSG;

#ifdef SHLIB
    {
    int		rval;
    do
	rval = msgsnd (msgQSnd, (struct msgbuf *)&enSnd,
			sizeof (EnterSnd) - sizeof (long), 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
    }
#else
    msgsnd (msgQSnd, (struct msgbuf *)&enSnd,
			sizeof (EnterSnd) - sizeof (long), 0);
#endif

    return (FS_NO_ERROR);

#endif
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSDaemonExit ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sends the FSExit command to the daemon.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  FS_NO_ERROR							*/
/*									*/
/************************************************************************/

int _FSDaemonExit (void)
{
#ifdef SHFONT

    ExitSnd	exSnd;

    exSnd.mtype = myPid;
    exSnd.opcode = FS_EXIT_MSG;

#ifdef SHLIB
    {
    int		rval;
    do
	rval = msgsnd (msgQSnd, (struct msgbuf *) &exSnd,
			sizeof (ExitSnd) - sizeof (long), 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
    }
#else
    msgsnd (msgQSnd, (struct msgbuf *)&exSnd,
			sizeof (ExitSnd) - sizeof (long), 0);
#endif

    return (FS_NO_ERROR);

#endif
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSDaemonNewFont (fontSpec, rangeSpec, fontNode)		*/
/*									*/
/*	  FontSpec	*fontSpec;	- font specification		*/
/*	  RangeSpec	*rangeSpec;	- range specification		*/
/*	  FontNode	***fontNode;	- font id returned		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sends the FSNewFont command to the daemon.	*/
/*	  Format of message FS_NEWFONT_MSG sent to daemon:		*/
/*									*/
/*		name		size					*/
/*		----		----					*/
/*		flags		sizeof (uInt32)				*/
/*		FontSpec	sizeof (FontSpec)			*/
/*				(containing offsets to tf & cm strings)	*/
/*		RangeSpec	variable (ending with 0xFFFF char id)	*/
/*				(may not be presen)			*/
/*		typeface	strlen (typeface)			*/
/*		charMap		strlen (charMap) (may not be present)	*/
/*									*/
/*	  Format of message received from daemon:			*/
/*									*/
/*		name		size					*/
/*		----		----					*/
/*		rval		sizeof (int)				*/
/*		fontNode	sizeof (FontNode)			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the specified typeface does not exist			*/
/*		- the memory cannot be allocated for the font		*/
/*		- the font cannot be generated				*/
/*									*/
/************************************************************************/

int _FSDaemonNewFont (FontSpec *fontSpec, RangeSpec *rangeSpec, FontNode *fontNode)
{
#ifdef SHFONT

    int			tfLength, cmLength, rsSize, size, cmId, range, rval;
    int			tfPathLength, cmPathLength;
    char		*ptr, *tfPath, *cmPath;
    static char		empty[] = "";
    CharMapId		charMapId;
    RangeSpec		*rsPtr;
    NewFontSnd		*nfSnd;
    NewFontRcv		nfRcv;

    _GCLockSem (TRUE);

    tfLength = strlen (fontSpec->typeface) + 1;

    charMapId = (int) fontSpec->charMap;
    if (cmId = ((charMapId >= -1) && (charMapId < MAX_CHARMAP)))
	cmLength = 0;
    else
	cmLength = strlen (fontSpec->charMap) + 1;

    if ((tfPath = getenv (_FSTFPathVar)) == NULL)
	tfPath = empty;
    tfPathLength = strlen (_FSTFPathVar) + strlen (tfPath) + 2;

    if ((cmPath = getenv (_FSCMPathVar)) == NULL)
	cmPath = empty;
    cmPathLength = strlen (_FSTFPathVar) + strlen (cmPath) + 2;

    if (range = (rangeSpec != NULL))
    {
	/** Find size of rangeSpec **/
	for (rsPtr = rangeSpec; rsPtr->start != 0xFFFF; rsPtr++);
	rsSize = (rsPtr - rangeSpec + 1) * sizeof (RangeSpec);
    }
    else
	rsSize = 0;

    /** Allocate the send buffer **/
    size = sizeof (NewFontSnd) + tfPathLength + cmPathLength + rsSize +
	   tfLength + cmLength;
    nfSnd = (NewFontSnd *) _FSAlloc (size);

    /** Fill in the data **/
    nfSnd->flags = (cmId ? FS_NEWFONT_MSG_CHARMAP_ID : 0) |
		   (range ? 0 : FS_NEWFONT_MSG_NO_RANGESPEC);
    memcpy (&nfSnd->fontSpec, fontSpec, sizeof (FontSpec));
    memcpy (nfSnd->rangeSpec, rangeSpec, rsSize);

    ptr = (char *) nfSnd + sizeof (NewFontSnd) + rsSize;

    strcpy (ptr, fontSpec->typeface);
    nfSnd->fontSpec.typeface = (char *) (ptr - (char *) nfSnd);
    ptr += tfLength;

    sprintf (ptr, "%s=%s", _FSTFPathVar, tfPath);
    nfSnd->tfPath = ptr - (char *) nfSnd;
    ptr += tfPathLength;

    sprintf (ptr, "%s=%s", _FSCMPathVar, cmPath);
    nfSnd->cmPath = ptr - (char *) nfSnd;
    ptr += cmPathLength;

    if (!cmId)
    {
	strcpy (ptr, fontSpec->charMap);
	nfSnd->fontSpec.charMap = (char *) (ptr - (char *) nfSnd);
    }

    /** Send the message **/
    nfSnd->mtype = myPid;
    nfSnd->opcode = FS_NEWFONT_MSG;

#ifdef SHLIB
    do
	rval = msgsnd (msgQSnd, (struct msgbuf *)nfSnd,
			size - sizeof (long), 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
#else
    msgsnd (msgQSnd, (struct msgbuf *)nfSnd,
			size - sizeof (long), 0);
#endif

    _FSDealloc ((char *)nfSnd);


    /** Wait for a reply from the daemon **/
#ifdef SHLIB
    do
	rval = msgrcv (msgQRcv, (struct msgbuf *)&nfRcv,
		sizeof (NewFontRcv) - sizeof (long), myPid, 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
#else
    msgrcv (msgQRcv, (struct msgbuf *)&nfRcv,
			sizeof (NewFontRcv) - sizeof (long), myPid, 0);
#endif

    rval = nfRcv.rval;
    if (rval == FS_NO_ERROR)
//	*fontNode = nfRcv.fontNode; // XXX - Bad pointer assignment in original code?
        memcpy(fontNode, *nfRcv.fontNode, sizeof(*fontNode));
//	fontNode = *nfRcv.fontNode;

    _GCUnlockSem (TRUE);
    return (rval);

#endif
}




/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSDaemonAppendFont (fontNode, rangeSpec)			*/
/*									*/
/*	  FontNode	**fontNode;	- font id			*/
/*	  RangeSpec	*rangeSpec;	- range specification		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sends the FSAppendFont command to the daemon.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the memory cannot be allocated			*/
/*		- the characters cannot be generated			*/
/*									*/
/************************************************************************/

int _FSDaemonAppendFont (FontNode **fontNode, RangeSpec *rangeSpec)
{
#ifdef SHFONT

    int			rsSize, size, range;
    RangeSpec		*rsPtr;
    AppendFontSnd	*afSnd;
    AppendFontRcv	afRcv;

    _GCLockSem (TRUE);

    if (range = (rangeSpec != NULL))
    {
	/** Find end of rangeSpec **/
	for (rsPtr = rangeSpec; rsPtr->start != 0xFFFF; rsPtr++);
	rsSize = (rsPtr - rangeSpec + 1) * sizeof (RangeSpec);
    }
    else
	rsSize = 0;

    size = sizeof (AppendFontSnd) + rsSize;
    afSnd = (AppendFontSnd *) _FSAlloc (size);

    /** Fill in the data **/
    afSnd->flags = (range ? 0 : FS_NEWFONT_MSG_NO_RANGESPEC);
    afSnd->fontNode = fontNode;
    memcpy (afSnd->rangeSpec, rangeSpec, rsSize);

    afSnd->mtype = myPid;
    afSnd->opcode = FS_APPENDFONT_MSG;

#ifdef SHLIB
    {
    int rval;
    do
	rval = msgsnd (msgQSnd, (struct msgbuf *)afSnd,
			size - sizeof (long), 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
    }
#else
    msgsnd (msgQSnd, (struct msgbuf *)afSnd, size - sizeof (long), 0);
#endif

    _FSDealloc ((char *)afSnd);


    /** Wait for a reply from the daemon **/
#ifdef SHLIB
    {
    int rval;
    do
	rval = msgrcv (msgQRcv, (struct msgbuf *)&afRcv,
			sizeof (AppendFontRcv) - sizeof (long),	myPid, 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
    }
#else
    msgrcv (msgQRcv, (struct msgbuf *)&afRcv,
			sizeof (AppendFontRcv) - sizeof (long), myPid, 0);
#endif

    _GCUnlockSem (TRUE);
    return (afRcv.rval);
#else
    printf ("_FSDaemonAppendFont() in FSDaemon.c being called but not used.\n");
    return -1;
#endif
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSDaemonAppendChar (fontNode, character)			*/
/*									*/
/*	  FontNode	**fontNode;	- font id			*/
/*	  CharId	character;	- character id			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sends the FSAppendChar command to the daemon.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the memory cannot be allocated			*/
/*		- the character cannot be generated			*/
/*									*/
/************************************************************************/

int _FSDaemonAppendChar (FontNode **fontNode, CharId character)
{
#ifdef SHFONT

    AppendCharSnd	acSnd;
    AppendCharRcv	acRcv;

    _GCLockSem (TRUE);

    /** Copy the data into the message **/
    acSnd.fontNode = fontNode;
    acSnd.charId = character;

    acSnd.mtype = myPid;
    acSnd.opcode = FS_APPENDCHAR_MSG;

#ifdef SHLIB
    {
    int			rval;
    do
	rval = msgsnd (msgQSnd, (struct msgbuf *)&acSnd,
			sizeof (AppendCharSnd) - sizeof (long), 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
    }
#else
    msgsnd (msgQSnd, (struct msgbuf *)&acSnd,
			sizeof (AppendCharSnd) - sizeof (long), 0);
#endif


    /** Wait for a reply from the daemon **/
#ifdef SHLIB
    {
    int rval;
    do
	rval = msgrcv (msgQRcv, (struct msgbuf *)&acRcv,
			sizeof (AppendCharRcv) - sizeof (long), myPid, 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
    }
#else
    msgrcv (msgQRcv, (struct msgbuf *)&acRcv,
			sizeof (AppendCharRcv) - sizeof (long), myPid, 0);
#endif

    _GCUnlockSem (TRUE);
    return (acRcv.rval);
#else
    printf ("_FSDaemonAppendChar() in FSDaemon.c being called but not used.\n");
    return -1;
#endif
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSDaemonReadFontFile (fileName, font)			*/
/*									*/
/*	  char		*fileName;	- font file name		*/
/*	  FontNode	***font;	- font id returned		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sends the FSReadFontFile command to the daemon.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the specified file cannot be read			*/
/*		- memory cannot be allocated in the cache		*/
/*									*/
/************************************************************************/

int _FSDaemonReadFontFile (char *fileName, FontNode ***fontNode)
{
#ifdef SHFONT

    int			cwdSize, fnSize, size, rval;
    char		*cwd, *ptr;
    ReadFontFileSnd	*rfSnd;
    ReadFontFileRcv	rfRcv;

    _GCLockSem (TRUE);

    cwd = getenv ("PWD");
    cwdSize = strlen (cwd) + 1;

    fnSize = strlen (fileName) + 1;

    size = sizeof (ReadFontFileSnd) + cwdSize + fnSize;
    rfSnd = (ReadFontFileSnd *) _FSAlloc (size);

    /** Copy the data into the message **/
    ptr = (char *) rfSnd + sizeof (ReadFontFileSnd);

    rfSnd->cwd = ptr - (char *) rfSnd;
    strcpy (ptr, cwd);
    ptr += cwdSize;

    rfSnd->fileName = ptr - (char *) rfSnd;
    strcpy (ptr, fileName);

    rfSnd->mtype = myPid;
    rfSnd->opcode = FS_READFONTFILE_MSG;

#ifdef SHLIB
    do
	rval = msgsnd (msgQSnd, (struct msgbuf *)rfSnd,
			size - sizeof (long), 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
#else
    msgsnd (msgQSnd, (struct msgbuf *)rfSnd, size - sizeof (long), 0);
#endif

    _FSDealloc ((char *)rfSnd);


    /** Wait for a reply from the daemon **/
#ifdef SHLIB
    do
	rval = msgrcv (msgQRcv, (struct msgbuf *)&rfRcv,
			sizeof (ReadFontFileRcv) - sizeof (long), myPid, 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
#else
    msgrcv (msgQRcv, (struct msgbuf *) &rfRcv,
			sizeof (ReadFontFileRcv) - sizeof (long), myPid, 0);
#endif

    rval = rfRcv.rval;
    if (rval == FS_NO_ERROR)
	*fontNode = rfRcv.fontNode;

    _GCUnlockSem (TRUE);
    return (rval);

#endif
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSDaemonDeleteFont (fontNode)				*/
/*									*/
/*	  FontNode	**fontNode;	- font id			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine sends the FSDeleteFont command to the daemon.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the specified font does not exist			*/
/*									*/
/************************************************************************/

int _FSDaemonDeleteFont (FontNode **fontNode)
{
#ifdef SHFONT

    DeleteFontSnd	dfSnd;
    DeleteFontRcv	dfRcv;

    _GCLockSem (TRUE);

    /** Copy the data into the message **/
    dfSnd.fontNode = fontNode;

    dfSnd.mtype = myPid;
    dfSnd.opcode = FS_DELETEFONT_MSG;

#ifdef SHLIB
    {
    int			rval;
    do
	rval = msgsnd (msgQSnd, (struct msgbuf *)&dfSnd,
			sizeof (DeleteFontSnd) - sizeof (long), 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
    }
#else
    msgsnd (msgQSnd, (struct msgbuf *)&dfSnd,
			sizeof (DeleteFontSnd) - sizeof (long), 0);
#endif


    /** Wait for a reply from the daemon **/
#ifdef SHLIB
    {
    int rval;
    do
	rval = msgrcv (msgQRcv, (struct msgbuf *)&dfRcv,
			sizeof (DeleteFontRcv) - sizeof (long), myPid, 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
    }
#else
    msgrcv (msgQRcv, (struct msgbuf *)&dfRcv,
			sizeof (DeleteFontRcv) - sizeof (long), myPid, 0);
#endif

    _GCUnlockSem (TRUE);
    return (dfRcv.rval);

#endif
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSDaemonUsedChars (charList, numChars)			*/
/*									*/
/*	  FontCharNode	***charList;	- list of character nodes	*/
/*	  int		numChars;	- how many chars in list	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine tells the daemon to update the time stamps of	*/
/*	  the specified characters.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  FS_NO_ERROR							*/
/*									*/
/************************************************************************/

int _FSDaemonUsedChars (FontCharNode ***charList, int numChars)
{
#ifdef SHFONT

    int			charSize, size;
    UsedCharsSnd	*ucSnd;

    charSize = numChars * sizeof (FontCharNode**);
    size = sizeof (UsedCharsSnd) + charSize;
    ucSnd = (UsedCharsSnd *) _FSAlloc (size);

    /** Copy the data into the message **/
    ucSnd->numChars = numChars;
    memcpy (ucSnd->charNode, charList, charSize);

    ucSnd->mtype = myPid;
    ucSnd->opcode = FS_USEDCHARS_MSG;

#ifdef SHLIB
    {
    int rval;
    do
	rval = msgsnd (msgQSnd, (struct msgbuf *)ucSnd,
			size - sizeof (long), 0);
    while ((rval == -1) && (errno == EINTR));	/* interrupted by signal? */
    }
#else
    msgsnd (msgQSnd, (struct msgbuf *)ucSnd,
			size - sizeof (long), 0);
#endif

    _FSDealloc ((char *)ucSnd);

    return (FS_NO_ERROR);

#endif
}

