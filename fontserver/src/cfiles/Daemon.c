/* $RCSfile: daemon.c $$Revision: 1.9 $$Date: 1992/10/25 10:22:11 $ Copyright (c) 1990 Intergraph Corp. */

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <signal.h>
#include <string.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSCharMap.h"
#include "../hfiles/FSDaemon.h"


#define	MSG_MAX		65536	/* maximum size of message		*/
#define	PROC_MAX	512	/* maximum number of processes		*/
#define	NUM_FONTS	32	/* realloc fonts in multiples of this	*/

/** Exit status values returned by the daemon **/
#define	CANT_SEND_MSG	1


/** This structure is functionally identical to struct msgbuf (msg.h) **/
typedef union
{
    struct
    {
	long	mtype;
	char	mtext[MSG_MAX];
    } d;
    double	align;		/* for alignment with any data type */
} MsgBuf;


/** This structure is the union of all message sent to the daemon **/
typedef union
{
    AckSnd		ak;
    EnterSnd		en;
    ExitSnd		ex;
    NewFontSnd		nf;
    AppendFontSnd	af;
    AppendCharSnd	ac;
    ReadFontFileSnd	rf;
    DeleteFontSnd	df;
    UsedCharsSnd	uc;
} EverySnd;


/** This structure is the union of all messages sent back to the application **/
typedef union
{
    AckRcv		ak;
    NewFontRcv		nf;
    AppendFontRcv	af;
    AppendCharRcv	ac;
    ReadFontFileRcv	rf;
    DeleteFontRcv	df;
} EveryRcv;


/** This structure is used to keep a list of fonts for each process **/
typedef struct
{
    int		pid;		/* process id				*/
    int		numFonts;	/* number of fonts in list		*/
    int		listSize;	/* size of list				*/
    FontNode	***fonts;	/* the list of fonts			*/
} ProcFonts;

void handle_term(); /** handler for terminate signal **/

int	msgQSnd;		/* message queue from FS processes	*/
int	msgQRcv;		/* message queue to FS processes	*/

extern char	_FSTFPathVar[];
extern char	_FSCMPathVar[];

char		*tfSearchPath;	/* search path env variables	*/
char		*cmSearchPath;

MsgBuf		msg;				/* the message buffer	*/
EverySnd	*sndMsg = (EverySnd *) &msg;	/* ptr to msg buffer	*/
EveryRcv	rcvMsg;				/* reply message	*/

int		numProc;			/* number of processes	*/
ProcFonts	procList[PROC_MAX];		/* the process list	*/


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  main ()							*/
/*									*/
/*	DESCRIPTION							*/
/*	  This is the main routine for the Font Server daemon.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

main ()
{
    int		rval, rcvSize=0, reply;

    /** Make me a process group leader so I don't get kill by my parent **/
    setpgrp ();

	signal(SIGTERM, handle_term);

    /** Create the message queues **/
    msgQSnd = msgget (MSG_SND_KEY, IPC_CREAT | 0666);
    msgQRcv = msgget (MSG_RCV_KEY, IPC_CREAT | 0666);
    if ((msgQSnd == -1) || (msgQRcv == -1))
	exit (-1);

    /** Flush the message queues (they may have been created earlier) **/
    while (msgrcv (msgQSnd, (struct msgbuf *)(&msg), MSG_MAX, 0,
			 IPC_NOWAIT) >= 0);
    while (msgrcv (msgQRcv, (struct msgbuf *)(&msg), MSG_MAX, 0,
			IPC_NOWAIT) >= 0);

    /** Clear the process list **/
    numProc = 0;
    memset (procList, 0, PROC_MAX * sizeof (ProcFonts));

    /** Initialize the search path env variables **/
    tfSearchPath = (char *) _FSMalloc (0);
    cmSearchPath = (char *) _FSMalloc (0);

    /** Calling FSEnter initializes the Font Server for the daemon and	**/
    /** creates the shared memory and semaphore.			**/
    FSEnter (1);

    for (;;)
    {
	if (msgrcv (msgQSnd, (struct msgbuf *)(&msg), MSG_MAX, 0, 0) >= 0)
	{
	    reply = TRUE;
	    switch (sndMsg->nf.opcode)
	    {
		case FS_ACK_MSG:
		{
		    rcvMsg.ak.rval = FS_NO_ERROR;
		    rcvSize = sizeof (AckRcv);
		    break;
		}

		case FS_ENTER_MSG:
		{

		    /** Check validity of all processes **/
		    CheckProc ();

		    AddProc (sndMsg->en.mtype);
		    reply = FALSE;
		    break;
		}

		case FS_EXIT_MSG:
		{
		    RemoveProc (sndMsg->ex.mtype);

		    reply = FALSE;
		    break;
		}

		case FS_NEWFONT_MSG:
		{
		    char	*str;
		    RangeSpec	*rangeSpec;

		    /** Check validity of all processes **/
		    CheckProc ();

		    /** Convert the string offsets back into pointers **/
		    sndMsg->nf.fontSpec.typeface = (char *) sndMsg +
					(int) sndMsg->nf.fontSpec.typeface;

		    if (!(sndMsg->nf.flags & FS_NEWFONT_MSG_CHARMAP_ID))
			sndMsg->nf.fontSpec.charMap = (char *) sndMsg +
					(int) sndMsg->nf.fontSpec.charMap;

		    if (sndMsg->nf.flags & FS_NEWFONT_MSG_NO_RANGESPEC)
			rangeSpec = NULL;
		    else
			rangeSpec = sndMsg->nf.rangeSpec;

		    /** The search paths **/
		    str = (char *) sndMsg + sndMsg->nf.tfPath;
		    tfSearchPath = (char *) _FSRealloc (tfSearchPath,
							strlen (str) + 1);
		    strcpy (tfSearchPath, str);
		    putenv (tfSearchPath);

		    str = (char *) sndMsg + sndMsg->nf.cmPath;
		    cmSearchPath = (char *) _FSRealloc (cmSearchPath,
							strlen (str) + 1);
		    strcpy (cmSearchPath, str);
		    putenv (cmSearchPath);

		    rcvMsg.nf.rval = FSNewFont (&sndMsg->nf.fontSpec, rangeSpec,
						&rcvMsg.nf.fontNode);
		    rcvSize = sizeof (NewFontRcv);

		    if (rcvMsg.nf.rval == FS_NO_ERROR)
			AddFontToProc (sndMsg->nf.mtype, rcvMsg.nf.fontNode);

		    break;
		}

		case FS_APPENDFONT_MSG:
		{
		    RangeSpec		*rangeSpec;

		    if (sndMsg->af.flags & FS_APPENDFONT_MSG_NO_RANGESPEC)
			rangeSpec = NULL;
		    else
			rangeSpec = sndMsg->af.rangeSpec;

		    rcvMsg.af.rval = FSAppendFont (&sndMsg->af.fontNode,
						   rangeSpec);

		    rcvSize = sizeof (AppendFontRcv);

		    break;
		}

		case FS_APPENDCHAR_MSG:
		{
		    rcvMsg.ac.rval = _FSAppendChar (sndMsg->ac.fontNode,
						    sndMsg->ac.charId);

		    rcvSize = sizeof (AppendCharRcv);

		    break;
		}

		case FS_READFONTFILE_MSG:
		{
		    /** Check validity of all processes **/
		    CheckProc ();

		    chdir ((char *) sndMsg + sndMsg->rf.cwd);

		    rcvMsg.rf.rval = FSReadFontFile ((char *) sndMsg +
						     sndMsg->rf.fileName,
						     &rcvMsg.rf.fontNode);
		    rcvSize = sizeof (ReadFontFileRcv);

		    if (rcvMsg.rf.rval == FS_NO_ERROR)
			AddFontToProc (sndMsg->rf.mtype, rcvMsg.rf.fontNode);

		    break;
		}

		case FS_DELETEFONT_MSG:
		{
		    rcvMsg.df.rval = FSDeleteFont (sndMsg->df.fontNode);
		    rcvSize = sizeof (DeleteFontRcv);

		    if (rcvMsg.df.rval == FS_NO_ERROR)
			RemoveFontFromProc (sndMsg->df.mtype,
					    sndMsg->df.fontNode);

		    break;
		}

		case FS_USEDCHARS_MSG:
		{
		    FontCharNode	***charPtr, ***charEnd;

		    charEnd = &sndMsg->uc.charNode[sndMsg->uc.numChars];
		    for (charPtr = sndMsg->uc.charNode; charPtr < charEnd;
			 charPtr++)
			_FSUpdateCharTime (NULL, *charPtr);

		    reply = FALSE;
		    break;
		}

		default:
		    reply = FALSE;
		    break;
	    }

	    if (reply)
	    {
		rcvMsg.nf.mtype = sndMsg->nf.mtype;
		rval = msgsnd (msgQRcv, (struct msgbuf *)(&rcvMsg),
				rcvSize - sizeof (long), IPC_NOWAIT);
		if (rval != 0)
		    Terminate (CANT_SEND_MSG);
	    }
	}
    }
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  AddProc (pid)							*/
/*									*/
/*	  int		pid;		- the process id		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine adds the specified process to the process list.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

AddProc (pid)
int	pid;
{
    ProcFonts	*ptr;

    /** Look for an unused slot in the process list **/
    for (ptr = procList; ptr->pid != 0; ptr++);

    ptr->pid = pid;
    ptr->listSize = ptr->numFonts = 0;
    ptr->fonts = (FontNode ***) _FSMalloc (0);
    numProc++;
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  RemoveProc (pid)						*/
/*									*/
/*	  int		pid;		- the process id		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine removes the specified process from the process	*/
/*	  list.								*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

RemoveProc (pid)
int	pid;
{
    int		i;
    char	aMsg[sizeof (EveryRcv)];	/* max size of rcv msg */
    ProcFonts	*ptr;

    /** Look for the process id in the process list **/
    for (ptr = procList; ptr->pid != pid; ptr++);

    /** Delete all fonts in the list **/
    for (i = 0; i < ptr->listSize; i++)
	if (ptr->fonts[i] != NULL)
	    FSDeleteFont (ptr->fonts[i]);

    /** Flush the process' messages from the receive queue **/
    while (msgrcv (msgQRcv, (struct msgbuf *)aMsg, MSG_MAX, pid,
			IPC_NOWAIT) >= 0);

    ptr->pid = 0;
    _FSFree (ptr->fonts);
    numProc--;
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  AddFontToProc (pid, fontNode)					*/
/*									*/
/*	  int		pid;		- the process id		*/
/*	  FontNode	**fontNode;	- the font			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine adds the specified font to the given process'	*/
/*	  font list.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

AddFontToProc (pid, fontNode)
int		pid;
FontNode	**fontNode;
{
    int		i, listSize;
    ProcFonts	*ptr;

    /** Look for the process id in the process list **/
    for (ptr = procList; ptr->pid != pid; ptr++);

    ptr->numFonts++;
    listSize = ((ptr->numFonts + NUM_FONTS - 1) / NUM_FONTS) * NUM_FONTS;
    if (listSize > ptr->listSize)
    {
	ptr->fonts = (FontNode ***) _FSRealloc
				(ptr->fonts, listSize * sizeof (FontNode **));

	/** Clear the new part of the list **/
	for (i = ptr->listSize; i < listSize; i++)
	    ptr->fonts[i] = NULL;
	ptr->listSize = listSize;
    }

    /** Find a place to put the font into the list **/
    for (i = 0; i < ptr->listSize; i++)
    {
	if (ptr->fonts[i] == NULL)
	{
	    ptr->fonts[i] = fontNode;
	    break;
	}
    }
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  RemoveFontFromProc (pid, fontNode)				*/
/*									*/
/*	  int		pid;		- the process id		*/
/*	  FontNode	**fontNode;	- the font			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine removes the specified font from the given	*/
/*	  process' font list.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

RemoveFontFromProc (pid, fontNode)
int		pid;
FontNode	**fontNode;
{
    int		i;
    ProcFonts	*ptr;

    /** Look for the process id in the process list **/
    for (ptr = procList; ptr->pid != pid; ptr++);

    /** Look for the font in the font list and clear it **/
    for (i = 0; i < ptr->listSize; i++)
	if (ptr->fonts[i] == fontNode)
	{
	    ptr->fonts[i] = NULL;
	    break;
	}
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  CheckProc ()							*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine checks the processes that the daemon knows about	*/
/*	  to make sure they are all still alive.  If a process is dead,	*/
/*	  its fonts are deleted.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

CheckProc ()
{
    int		i;
    ProcFonts	*ptr;

    for (ptr = procList, i = 0; i < numProc; ptr++, i++)
    {
	for (; ptr->pid == 0; ptr++);
	if (isdead((pid_t)ptr->pid))        /* is it alive? */
		RemoveProc (ptr->pid);

    }
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  Terminate (status)						*/
/*									*/
/*	  int	status;		- exit status				*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine cleans up and terminates the daemon, returning	*/
/*	  the specified exit status.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

Terminate (status)
int	status;
{
    if (status != 0)
	fprintf (stderr, "Font Server daemon aborting!  Error = %d.\n", status);

    /** Exit the Font Server **/
    FSExit ();

    /** Remove the message queues **/
    msgctl (msgQSnd, IPC_RMID, NULL);
    msgctl (msgQRcv, IPC_RMID, NULL);

	/** Remove the shared memory and semaphore **/
	_GCIpcRm();

    exit (status);
}


int isdead( pid )
pid_t pid;
{
	char path[32];
	struct stat statbuf;

	sprintf(path, "/proc/%05d", (int)pid);

	return (stat(path, &statbuf));
}


/*ARGSUSED*/
void handle_term(sig)
int sig;
{
	Terminate(0);
}
