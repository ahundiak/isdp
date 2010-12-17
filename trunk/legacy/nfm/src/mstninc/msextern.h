/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   msextern.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
| Copyright (C) 1986-90   Bentley Systems, Inc., All rights reserved.	|
|									|
| "MicroStation", "MDL", and "MicroCSL" are trademarks of Bentley	|
|  Systems, Inc.							|
|									|
| Limited permission is hereby granted to reproduce and modify this	|
| copyrighted material provided that the resulting code is used only in	|
| conjunction with Bentley Systems products under the terms of the	|
| license agreement provided therein, and that this notice is retained	|
| in its entirety in any such reproduction or modification.		|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   extern.h -- describes how MicroStation interacts with external	|
|		programs.						|
|									|
+----------------------------------------------------------------------*/
#ifndef __msexternH__
#define __msexternH__

/* .h File Dependencies */
#ifndef __basedefsH__
#include    <basedefs.h>
#endif
#ifndef __msdefsH__
#include    <msdefs.h>
#endif
#ifndef	__basetypeH__
#include    <basetype.h>
#endif

/*----------------------------------------------------------------------+
|									|
|   Defines								|
|									|
+----------------------------------------------------------------------*/

#if defined (mdl) || !defined (unix)
#define IPC_NOWAIT	1
#endif

#define	    EXTP_KEY_GENERATE		0
#define	    EXTP_NAME_SIZE		20

/*  Operators for mdlExternal_queueGet  */
#define	    EXTP_QUEUE_ATTACH		1
#define	    EXTP_QUEUE_CREATE		2

/*  Status for MsgQDescr	*/
#define	    EXTP_QUEUE_INUSE		1
#define	    EXTP_QUEUE_FREE		2

/*  Message types	*/
#define	    EXTP_FOR_MDL		1
#define	    EXTP_FOR_MCSL		2
#define	    EXTP_FOR_APPL		3

#define	    EXTP_STATUS_NOTIFIED	-2
#define	    EXTP_STATUS_TERMINATED	-1
#define	    EXTP_STATUS_ACTIVE     	0

#if defined (pm386)
/*  Declare the shared memory storage class.  */    
#define	    SHMEM_SC			_far
#else
#define	    SHMEM_SC
#endif

/*----------------------------------------------------------------------+
|									|
|   Typedefs								|
|									|
+----------------------------------------------------------------------*/
typedef	long	msgqID_t;

#if defined (mdl) || !defined (unix)
typedef long	key_t;
#endif

typedef struct mdlmessage
    {
    long	    mtype;
    long	    msglength;	    /* number of bytes in request mtext */
    long	    sendpid;	    /* filled in by MDL.  */
    long	    reqtype;	    /* request type */
    char	    mtext [1];
    } ExternalMessage;

typedef struct MSexternalProgramDescr
    {
    char	    name[MAXFILELENGTH];    /* child program's name */
    char	    *pCommandLine;
    int		    pid;		    /* process id that we started */
    char	    status;		    /* active/inactive */
    int		    exitStatus;
    } MSExternalProgramDescr;

typedef struct MSmsgqDescr
    {
    key_t	    messageKey;	    /* key for msg queue to/from process */
    char	    externalName [EXTP_NAME_SIZE];  /*  Name used for external
				      programs to get access.	*/
    int		    msgqID;	    /* message queue id */
    byte	    status;
    byte	    rcvType;
    } MSMsgqDescr;

typedef struct MSshmemDescr
    {
    char	    *psharedMem;
    key_t	    shmemKey;	    /* name to pass to process */
    char	    externalName [EXTP_NAME_SIZE];  /*  Name used for external
				      programs to get access.	*/
    int		    shmemID;	    /* shared memory id */
    byte	    status;
    } MSShmemDescr;

#endif
