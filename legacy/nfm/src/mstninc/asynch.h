/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   asynch.h  $
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
|   asynch.h --								|
|									|
+----------------------------------------------------------------------*/
#ifndef __asynchH__
#define __asynchH__

#ifndef __mstypesH__
#include <mstypes.h>
#endif

#if !defined (mdl)
#define PREUPDATE    1
#define POSTUPDATE   2
#define NEWVLT	     3
#define CMDBUTN	     4
#define NEWCMD	     5
#define MS_INPUT     6
#define UCM_RECEIVE  7
#define MS_TERMINATE 8
#define PARSE	     9
#define CMDFILTER    10
#define EXECUTE	     11
#define CMDTERM	     12
#define MONITOR	     13
#define NEWDGN	     14
#define APPELEM	     15
#define PRELOCATE    16
#define POSTLOCATE   17
#define LOCATED      18
#define MODLOCSCAN   19
#define FENCEELEM    20
#define UORINPUT     21
#define NEWMAP	     22
#define WINDEVENT    23

#define LOCFILTER_REJECT 0
#define LOCFILTER_NEUTRAL 1
#define LOCFILTER_ACCEPT 2

#define NO_UORDATA	0
#define NEW_UORDATA	1
#define MORE_UORDATA	2

#define WINDOW_SHOWEVENT	    1
#define WINDOW_HIDEEVENT	    2
#define WINDOW_ORDEREVENT	    3
#define WINDOW_MOVEEVENT	    4
#define WINDOW_CHANGESCREENEVENT    5
#endif

typedef struct
    {
    int cmdpromptnum;		/* number of prompt MicroStation displays */
    int cmdclass;		/* class of command */
    char cmdprompt[80];		/* command prompt */
    } Cmd_info;

#endif
