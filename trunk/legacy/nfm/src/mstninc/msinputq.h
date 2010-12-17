/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   msinputq.h  $
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
|   msinputq.h -- Input queue definitions for MicroStation/MDL  	|
|									|
+----------------------------------------------------------------------*/
#if !defined (__msinputqH__)
#define __msinputqH__

#if !defined (__basetypeH__)
#   include <basetype.h>
#endif

#if !defined (__basedefsH__)
#   include <basedefs.h>
#endif
    
#if !defined (__msdefsH__)
#   include <msdefs.h>
#endif

/* these types are returned from xx_getInput and appear in the queue
   the first three are the button codes returned by input_getInput */
#define KEYIN		    501		/* a normal keyin was entered */
#define UNASSIGNEDCB	    502		/* user hit an unassigned curs butn */
#define DATAPNT3D	    503		/* user hit 3d datapoint button */
#define TENTPNT3D	    504		/* user hit 3d tentative button */
#define NULLQELEM	    505		/* NULL element (skip a gather) */
#define TUTKEYIN	    506		/* user typed into tutorial I field */
#define CMDKEYIN	    507		/* keyin generated from a menu */
#define CMDNUMBER	    508		/* command number from a menu */
#define NULLCMDELEM	    509		/* NULLCMD special queue element */
#define TIMEREVENT	    510		/* timer event */

#define	LOWEST_BUTTON	        512
#define DATAPNT		        512	/* user hit datapnt button */
#define TENTPNT		        514	/* user hit tentative button */
#define RESET		        515	/* user hit reset button */
#define DATAPNT3D_CURSOR_BUTN	516
#define TENTPNT3D_CURSOR_BUTN	517
#define FIRST_CURSOR_BUTN	516
#define LAST_CURSOR_BUTN	528
	
/* these types are generated from menus and put into the input queue */
#define CMDNUM		    550
#define UKEYIN		    551
#define MENU_MESSAGE	    552
#define MENU_SUBMENU	    553
#define MENU_CONTENTS	    554
#define MENU_INPUT_WAIT	    555

/* this type is used by all the windowing related events on the queue */
#define WINDOWEVENT	    600

/* these types represent raw input that will be processed into real events */
#define RAWBUTTON	    800
#define RAWKEYSTROKE	    801
#define RAWICONEVENT        802
#define RAWKEYRETURN	    803
    
/* Application events are reserved by applications  The format of the format
   beyond the header is defined by the application.	*/
#define APPLICATION_EVENT   900
    
/*  INPUTQ_EOQ as the position parameter tells the mdlInput_send functions
    to queue the element at the end of the queue. */
#define INPUTQ_EOQ	    -1
	
/*----------------------------------------------------------------------+
|                                                                       |
|    Cmdtype bit masks for input filter                                 |
|                                                                       |
+----------------------------------------------------------------------*/
#define CMDNUM_MASK	    0x00000001L
#define DATAPNT_MASK	    0x00000002L
#define TENTPNT_MASK	    0x00000004L
#define RESET_MASK	    0x00000008L
#define KEYIN_MASK	    0x00000010L
#define UNASSIGNEDCB_MASK   0x00000020L
#define MENU_CONTENTS_MASK  0x00000040L
#define TUTKEYIN_MASK	    0x00000080L
#define STANDARD_MASK	    0x0000013bL

/*----------------------------------------------------------------------+
|									|
|  Input sources							|
|									|
+----------------------------------------------------------------------*/
#define FROM_KEYBOARD	    400
#define FROM_CMDFILE	    401
#define FROM_TUTORIAL	    402
#define FROM_APP	    403
#define FROM_UCM	    404
#define TABLET_MENU	    405
#define SCREEN_MENU	    406
#define FUNCKEY_MENU	    407
#define CURSOR_BUTTON_MENU  408
#define PULLDOWN_MENU	    409
#define CONTROL_STRIP_MENU  410
#define HIERARCHICAL_MENU   411
#define TUTORIAL	    412
#define	WINDOW_ICON	    413
#define PALETTE_MENU	    414
#define FROM_STARTUP	    415
#define FROM_DIALOG	    416
#define FROM_PROCESS	    417
#define FROM_MDL	    418
#define FROM_PRDFPI	    419

/*----------------------------------------------------------------------+
|                                                                       |
|   mdlInput_commandType maps all values for u.cmd.class into           |
|   one of the 3 following values.                                      |
|                                                                       |
+----------------------------------------------------------------------*/
#define	    PRIMITIVE_COMMAND	    1	    /*  Creation, deletion, etc. */
#define	    VIEW_COMMAND	    2	    /*  Viewing */
#define	    IMMEDIATE_COMMAND	    3	    /*  Uses no parameters */


/*----------------------------------------------------------------------+
|                                                                       |
|   Input queue elements structures                                     |
|                                                                       |
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|                                                                       |
|   contents of a menu entry                                            |
|                                                                       |
+----------------------------------------------------------------------*/

typedef struct mentryContents
    {
    byte	type;	    /* menu type */
    union
	{
	long	prim;	    /* primitive (in radix 50) for P types */
	long	interpcmd;  /* interpreted command for P, T, E types */
	long	ucmd;	    /* command index for U, A types */
	long	cell;	    /* cell name (in radix 50) for C types */
	char	symbol;	    /* symbol, for S types */
	int	intype;	    /* input type (data or keyin) for / and % types */
	int	offset;	    /* offset into data for ones that dont fit here */
 	} data;
    } MentryContents;

typedef struct inputq_keyin
    {
    short   len;			/* length of string */
    short   type;			/* 0 = keyin, 1 = command keyin */
    char    keyin[1];			/* actual string */
    } Inputq_keyin;

typedef struct inputq_pnt
    {
    short	view;			/* view that datapoint is in */
    short	phys_screen;		/* physical screen point was in */
    Uspoint3d	cmdpoint;		/* point in input device space */
    short	region;			/* tablet region (ip32, macintosh) */
    Spoint2d	scrnpoint;		/* point in screen space */
    Point3d	rawUors;		/* point in design file coordinates */
    Point3d	uors;			/* point adjusted for locks */
    short	buttonTrans;		/* type of transition */
    short	qualifierMask;		/* qualifying keys down when hit */
    } Inputq_pnt;

typedef struct inputq_datapnt
    {
    Inputq_pnt  pnt;			/* point structure */
    short	precision;		/* TRUE for precision input */
    short	viewflags[MAX_VIEWS];	/* view that datapoint was close to */
    } Inputq_datapnt;

typedef struct inputq_command
    {
    int		class;			/* command class */
    int		immediate;		/* has immediate mode */
    long	command;		/* unique command id */
    char	taskId[16];		/* destination child task */
    char	unparsed[1];		/* Unparsed portion (if any) */
    } Inputq_command;

typedef struct inputq_tentpnt
    {
    Inputq_pnt	pnt;			/* point structure */
    } Inputq_tentpnt;

typedef struct inputq_reset
    {
    short	reset;			/* place holder */
    } Inputq_reset;

typedef struct inputq_partial
    {
    short	len;			/* length of string so far */
    char	keyin[1];		/* actual string so far */
    } Inputq_partial;

typedef struct inputq_unassignedcb
    {
    Inputq_pnt	pnt;
    short	cursbutn;
    } Inputq_unassignedcb;

typedef struct inputq_menumsg
    {
    char	message[1];
    } Inputq_menumsg;

typedef struct inputq_submenu
    {
    char	subname[1];
    } Inputq_submenu;

typedef struct inputq_contents
    {
    MentryContents contents;
    } Inputq_contents;

typedef struct inputq_menuwait
    {
    int		prompt;			/* true if MStation prompts wanted */
    int		waittype;		/* 0 for data, 1 for keyin */
    } Inputq_menuwait;

typedef struct inputq_null      	/*  Used for control only.  */
    {
    short	breaknow;		/*  1 => Leave processing cycle.  */
    } Inputq_null;

typedef struct inputq_nullcmd
    {
    short nullcmd;			/* place holder */
    } Inputq_nullcmd;

typedef struct inputq_tutkeyin
    {
    short   len;			/* length of string */
    char    keyin[1];			/* actual string */
    } Inputq_tutkeyin;

typedef struct inputq_rawButton
    {
    void       *gwP;			/* window button event is in */
    void       *handlerGwP;		/* = gwP except when pt in border */
    int	        buttonNumber;		/* button number */
    int		buttonTrans;		/* type of transition */
    unsigned long buttonTime;		/* time of transition */
    int		qualifierMask;		/* ctrl/alt/shift keys down */
    Spoint2d	scrnPoint;		/* point in screen space */
    Uspoint3d	tabletPoint;		/* point in input device space */
    int		region;			/* tablet region */
    } Inputq_rawButton;

typedef struct inputq_rawIconEvent
    {
    Inputq_rawButton	rawButton;	/* raw button info */
    union				/* information stored with icon */
	{
	long	 data;
	void	*dataP;
	} callBackID;
    Rectangle		*controlRectP;	/* icon rectangle */
    } Inputq_rawIconEvent;

typedef struct inputq_rawKeyStroke
    {
    int	        keyStroke;		/* keystroke */
    int		qualifierMask;		/* ctrl/alt/shift keys down */
    } Inputq_rawKeyStroke;

typedef struct inputq_timerEvent
    {
    int	      (*functionP)();		/* function to call */
    void       *timerSource;		/* MDL/MicroStation file descr */
    int	        timerHandle;		/* timer handle */
    long	timerArg;		/* argument to timer function */
    } Inputq_timerEvent;

typedef struct inputq_header
    {
    short   cmdtype;			/* type of input following */
    short   bytes;			/* bytes in queue element */
    short   source;			/* source of input (user, app, etc) */
    short   uc_fno_value;		/* value to put in tcb->uc_fno */
    int	    sourcepid;			/* source pid for queue element */
    char    taskId[16];			/* destination child task */
    } Inputq_header;

typedef struct inputq_element
    {
    Inputq_header hdr;
    union
	{
	Inputq_keyin	    keyin;	    /* keyed in (not command) */
	Inputq_datapnt	    data;	    /* data point */
	Inputq_command	    cmd;	    /* parsed command */
	Inputq_tentpnt	    tent;	    /* tentative point */
	Inputq_reset	    reset;	    /* reset */
	Inputq_partial	    partial;	    /* incomplete keyin */
	Inputq_unassignedcb cursbutn;	    /* unassigned cursor button */
	Inputq_menumsg	    menumsg;	    /* menu message to be posted */
	Inputq_submenu	    submenu;	    /* submenu to be displayed */
	Inputq_menuwait	    menuwait;	    /* go back, get another input */
	Inputq_contents	    contents;	    /* menu entry contents */
	Inputq_null	    nullqelem;	    /* NULL event */
	Inputq_tutkeyin	    tutkeyin;	    /* Tutorial keyin */
	Inputq_nullcmd	    nullcmd;	    /* NULL command elem */
	Inputq_rawButton    rawButton;	    /* raw button information */
	Inputq_rawKeyStroke rawKeyStroke;   /* raw keystroke information */
	Inputq_rawIconEvent rawIconEvent;   /* raw Icon event information */
	Inputq_timerEvent   timerEvent;	    /* timer event information */
	char fill[480];			    /* make sure it's big enough */
	} u;
    } Inputq_element;

#endif  /*  __msinputqH__  */
