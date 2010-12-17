/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   dlogitem.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   dlogitem.h -- Dialog Box Manager Item definitions used ONLY by Item	|
|		  Handler and Item Hook Writers				|
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
#if !defined (__dlogitemH__)
#define __dlogitemH__

#if !defined (resource)

#if !defined (__basedefsH__)
#include <basedefs.h>
#endif
#if !defined (__basetypeH__)
#include <basetype.h>
#endif
#if !defined (__msdefsH__)
#include <msdefs.h>
#endif
#if !defined (__rscdefsH__)
#include <rscdefs.h>
#endif
#if !defined (__msinputqH__)
#include <msinputq.h>
#endif
#if !defined (__vartypesH__)
#include <vartypes.h>
#endif
#if !defined (__dlogboxH__)
#include <dlogbox.h>
#endif

#endif	/* !defined (resource) */

/*----------------------------------------------------------------------+
|									|
|   Basic Item Constants						|
|									|
+----------------------------------------------------------------------*/
#define INVALID_ITEM	    (-1)

#define BUTTONTIMEOUT_CLICK		0   /* down to up > dClickTime/2 */
#define BUTTONTIMEOUT_DOUBLECLICK	1   /* down to down > dclickTime */

/*----------------------------------------------------------------------+
|									|
|   Opaque Pointer Typedefs						|
|									|
+----------------------------------------------------------------------*/
#if !defined (resource)

typedef void DialogBox;	    /* used to create opaque DialogBox ptr's */
typedef void StringList;    /* used for creation/use of string lists */

#if defined (mdl)
typedef void GuiWindow;	    /* used to create opaque GuiWindow ptr */
#endif

typedef void AccelKeyTable; /* used to create opaque AccelKeyTable ptr */

/*----------------------------------------------------------------------+
|									|
|   Structure For Passing Values to and from Items			|
|									|
+----------------------------------------------------------------------*/
typedef union valueunion    /* union of types processed by get/set messages */
    {
    unsigned char    uCharFormat;
    char	    *charPFormat;
    unsigned Wordint uWordFormat;
    Wordint	     sWordFormat;
    unsigned Longint uLongFormat;
    Longint	     sLongFormat;
    double	     doubleFormat;
    } ValueUnion;

#endif	/* !defined (resource) */

/*----------------------------------------------------------------------+
|									|
|   Dialog Messages							|
|									|
|   Sent to dialogHooks.						|

    CREATE	    sent before item hooks are sent create messages.
    INIT	    sent after all item hooks are sent create messages.
    DESTROY	    sent after all item hooks are sent destroy messages.
    UPDATE	    sent after all update messages sent to items.
    RESIZE	    sent after window has been resized (or moved), but before
			update. (don't draw here simply move & rescale).
    CALCSIZE	    window mgr needs to know new size since dialog
		         may be moved to screen w/ different screen font.
    FONTCHANGED	    dialog has been moved to a screen w/ different screen
			 font.

    BUTTON	    sent after button message sent to item.
    FOCUSIN	    sent when dialog receives focus before item focus in.
    FOCUSOUT	    sent when dialog loses focus after item focus out.
    ITEMFOCUSIN	    sent after item in dialog gets focusIn message.
    ITEMFOCUSOUT    sent after item in dialog gets focusOut message.
|									|
+----------------------------------------------------------------------*/
#define DIALOG_MESSAGE_CREATE	    0   /* sent before item creates */
#define DIALOG_MESSAGE_INIT	    1	/* sent after item creates */
#define	DIALOG_MESSAGE_DESTROY      2   /* about to close window */
#define DIALOG_MESSAGE_UPDATE	    3   /* window just got update message */
#define DIALOG_MESSAGE_RESIZE	    4	
#define DIALOG_MESSAGE_CALCSIZE	    5	/* calc size with new fontIndex */
#define DIALOG_MESSAGE_FONTCHANGED  6	/* dialog's font index changed */
#define DIALOG_MESSAGE_SYNCH	    7

#define DIALOG_MESSAGE_BUTTON	    8	/* got button event */

#define DIALOG_MESSAGE_KEYSTROKE    9
#define DIALOG_MESSAGE_FOCUSIN	    10
#define DIALOG_MESSAGE_FOCUSOUT	    11
#define DIALOG_MESSAGE_ITEMFOCUSIN  12
#define DIALOG_MESSAGE_ITEMFOCUSOUT 13

#define DIALOG_MESSAGE_CHILDDESTROYED	14  /* after child removed frm scrn */
#define DIALOG_MESSAGE_ACTIONBUTTON	15
#define DIALOG_MESSAGE_USER		16

#define DIALOG_MESSAGE_ANOTHEROPENED	17  /* sent after INIT msgs */
#define DIALOG_MESSAGE_ANOTHERCLOSED	18  /* sent before DESTROY msg */

/*----------------------------------------------------------------------+
|									|
|   									|
|									|
+----------------------------------------------------------------------*/
#if !defined (resource)

typedef struct dialoghookinterests  /* set member TRUE if want notification */
    {
    ULong  updates:1;
    ULong  mouses:1;
    ULong  keystrokes:1;
    ULong  dialogFocuses:1;	    /* when dialog gets/loses focus */
    ULong  itemFocuses:1;	    /* when item get/loses focus */
    ULong  synchs:1;
    ULong  resizes:1;		    /* when dialog resized or moved */
    ULong  calcSizes:1;
    ULong  fontChanges:1;
    ULong  nonDataPoints:1;	    /* send RESET & TENTATIVE msgs */
    ULong  otherDialogs:1;	    /* another dialog open & close msgs */
    ULong  unused:21;
    } DialogHookInterests;  /* CREATE, INIT, & DESTROY ALWAYS SENT */
    
typedef struct dialogmessage
    {
    boolean	    msgUnderstood;	/* <= message understood? */
    int		    messageType;	/* => message type */
    DialogBox	   *db;			/* => dialog box handle */
    long	    dialogId;		/* => resource id of dialog box */
    void	   *userDataP;		/* => set by user during CREATE */
    union	    
	{
	struct 
	    {
	    boolean		  createFailed;	/* <= set TRUE if error */
	    DialogHookInterests	  interests;	/* <= */
	    void		**userDataPP;	/* <= */
	    DialogBoxRsc	 *dialogBoxRP;	/* => */
	    } create;
	struct
	    {
	    int		actionType;	/* => only if stdAction button used */
	    } destroy;
	struct 
	    {
	    boolean	initFailed;	/* <= set TRUE if error */
	    } init;
	struct
	    {
	    long	whichCorners;	    /* => */
	    Rectangle	oldFrame;	    /* => old frame rectangle */
	    Rectangle	oldContent;	    /* => old content rectangle */
	    } resize;
        struct
	    {
	    boolean	hookHandled;	/* <= TRUE if handled */
	    int		newWidth;	/* <= calc'ed width (in pixels) */
	    int		newHeight;	/* <= calc'ed height (in pixels) */
	    int		dialogWidth;	/* <> in dialog coord units */
	    int		dialogHeight;	/* <> in dialog coord units */
	    int		newFontHeight;  /* => new font's height */
	    int		oldFontHeight;  /* => old font's height */
	    } calcSize;	
	struct
	    {
	    int		newFontHeight;  /* => new font's height */
	    int		oldFontHeight;  /* => old font's height */
	    } fontChanged;		/* because dialog now on new screen */
	struct
	    {
	    int	        buttonNumber;	/* => button number */
	    int		buttonTrans;	/* => type of transition */
	    int		qualifierMask;	/* => ctrl/alt/shift keys down */
	    int		upNumber;	/* => 1=singleClick,2=dblClick,etc */
	    boolean	clicked;	/* => FALSE means press or drag */
	    ULong	buttonTime;	/* => time of transition */
	    Point2d	pt;		/* => location in local coords */
	    int		itemIndex;	/* => item button already send to */
	    Inputq_element *iqelP;	/* => source queue element */
	    } button;
        struct
	    {
	    boolean	hookHandled;   /* <= only for hooks,TRUE if handled */
	    int		moveDirection; /* <= -1 or 1,to indicate next field */
	    int		keystroke;	/* <> virtual keystroke */
	    int		rawKeystroke;	/* <> raw keystroke */
	    int		qualifierMask;	/* => */
	    int		itemIndex;	/* => item key WOULD be send to */
	    Inputq_element *iqelP;	/* => source queue element */

	    boolean	 isAccelerator;	/* <> key is accelerator */
	    ULong	 commandNumber;	/* <> accelerator key cmd */
	    char	*unparsedP;	/* <> accelerator key unparsed */
	    char	*commandTaskIdP; /*<>accelerator key command taskid */
	    } keystroke;
	struct
	    {
	    int		itemIndex;	/* => item about to get focus */
	    int		focusOutType;	/* => reason focused out prev item */
	    } focusIn;
	struct
	    {
	    boolean	outOfRange;    /* <= if current value out of range */
	    int		itemIndex;     /* => item just lost focus */
	    int		focusOutType; /* => item fo reason only, FOCUSOUT_? */
	    } focusOut;
	struct
	    {
	    long	childDialogId;	/* => */
	    int		actionType;	/* => only if stdAction button used */
	    } childDestroyed;
	struct
	    {
	    boolean	abortAction;	/* <= abort current action */
	    int		actionType;	/* => OK, Cancel, Reset, Apply */
	    } actionButton;
	struct
	    {
	    int		type;		/* => type of user message */
	    void	*userDataP;	/* => */
	    } user;
	struct
	    {
	    DialogBox	*db;		/* => ptr to dialog opened */
	    ULong	dialogType;	/* => type of dialog opened */
	    long	dialogId;	/* => id of dialog opened */
	    } anotherOpened;
	struct
	    {
	    DialogBox	*db;		/* => ptr to dialog closed */
	    ULong	dialogType;	/* => type of dialog closed */
	    long	dialogId;	/* => id of dialog closed */
	    int		actionType;	/* => only if stdAction button used */
	    } anotherClosed;
	} u;
    } DialogMessage;

#endif	/* !defined (resource) */

/*----------------------------------------------------------------------+
|									|
|   Dialog Item Messages						|
|									|
|   Sent to itemHandlers & itemHooks (specified within actual item)	|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   Dialog Item Message Type Constants					|
|									|
    FOCUSOUT	About to move out of field, now is the time to validate	|
|									|
+----------------------------------------------------------------------*/
#define DITEM_MESSAGE_CREATE		50
#define DITEM_MESSAGE_DESTROY		51
#define DITEM_MESSAGE_DRAW		52
#define DITEM_MESSAGE_FONTCHANGED	53
#define DITEM_MESSAGE_BUTTON		54
#define DITEM_MESSAGE_SETSTATE		55
#define DITEM_MESSAGE_SYNCHRONIZE	56	/* match app state */
#define DITEM_MESSAGE_HIGHLIGHT		57
  
/* Messages only sent to keystrokable items */
#define DITEM_MESSAGE_KEYSTROKE		58
#define DITEM_MESSAGE_POSTKEYSTROKE	59  /* after default processing */
#define DITEM_MESSAGE_FOCUSIN		60
#define DITEM_MESSAGE_FOCUSOUT		61

/* Messages for application support (not sent by dialog manager) */
#define DITEM_MESSAGE_SETENABLEDSTATE   62
#define DITEM_MESSAGE_MOVE		63
#define DITEM_MESSAGE_SETEXTENT		64
#define DITEM_MESSAGE_SETLABEL  	65
#define DITEM_MESSAGE_GETSTATE		66 /* gets appl state */
#define DITEM_MESSAGE_GETVALUE		67 /* gets item value not app state */
#define DITEM_MESSAGE_SETVALUE		68 /*does NOT set application state*/

/* item hook messages (never sent TO item handlers) */
#define DITEM_MESSAGE_INIT		69	/* after initial getState */
#define DITEM_MESSAGE_QUEUECOMMAND	70
#define DITEM_MESSAGE_STATECHANGED	71	/* notification only */
#define DITEM_MESSAGE_USER		72

/* handler initialization & cleanup messages */
#define	DITEM_MESSAGE_HANDLERLOADED	100
#define DITEM_MESSAGE_HANDLERUNLOADED	101

#define DITEM_MESSAGE_ACTIVATE		110	/* %%% move up */

/*----------------------------------------------------------------------+
|									|
|   Item Focus Out Types						|
|									|
+----------------------------------------------------------------------*/
#define FOCUSOUT_KEYSWITCH		1   /* TABed or RETURNed out */
#define FOCUSOUT_BUTTONSWITCH		2   /* clicked in new item */
#define FOCUSOUT_SETITEM		3
#define FOCUSOUT_HIDEITEM		4
#define FOCUSOUT_DISABLEITEM		5
#define FOCUSOUT_SWITCHDIALOG		10
#define FOCUSOUT_APPLYDIALOG		11

#if !defined (resource)
/*----------------------------------------------------------------------+
|									|
|   Dialog Item Message Structures					|
|									|
+----------------------------------------------------------------------*/
typedef struct dialogitemattributes
    {
    ULong  acceptsKeystrokes:1;
    ULong  mouseSensitive:1;
    ULong  traverseable:1;
    ULong  canHaveSynonyms:1;
    ULong  enabled:1;
    ULong  hidden:1;
    ULong  unused:26;
    } DialogItemAttributes;

typedef struct rawitemhdr RawItemHdr;

typedef struct dialogitem
    {
    ULong	    type;
    long	    id;
    int		    itemIndex;
    int		    itemArg;
    Rectangle	    rect;	/* mouse sensitive/update region of item */
    Sextent	    extent;	/* (in dcoord units) for fontChange msgs */
    Point2d	    origin;	/* (dcoord units) for fontChange msgs */
    
    DialogItemAttributes  attributes;
    RawItemHdr		 *rawItemP;
    } DialogItem;

typedef struct dialogitemmessage
    {
    boolean	    msgUnderstood;	/* <= item understood the message */
    int		    messageType;	/* => message type */
    DialogBox	   *db;			/* => dialog box handle */
    long	    dialogId;		/* => resource id of dialog box */
    int		    itemIndex;		/* => index of item message sent to */
    DialogItem	   *dialogItemP;	/* => dialogItem info for item */
    int		    auxMessageType;	/* => item specific message type */
    void	   *auxInfoP;		/* => item specific message info */
    union	    
	{
	struct 
	    {
	    boolean	     createFailed;  /* <= set TRUE if error */
	    void	    *resourceDataP; /* => */
	    Sextent	    *itemListExtentP;	/* => */
	    char	    *labelP;	    /* => */
	    char	    *auxInfoP;	    /* => */
	    long	     itemArg;	    /* => */
	    void	    *ownerMD;	    /* => */
	    DialogItem	    *parentDiP;	    /* => null if owner is dialog */
	    } create;
	struct
	    {
	    boolean	     eraseFirst;    /* => erase before drawing */
	    int		     nRects;	    /* => # of update rects */
	    Rectangle	    *rectList;	    /* => update rects(local coords)*/
	    } draw;
	struct
	    {
	    boolean	hookHandled;	/* <= TRUE if handled */
	    int		newFontHeight;  /* => new font's height */
	    int		oldFontHeight;  /* => old font's height */
	    } fontChanged;		/* because dialog now on new screen */
	struct
	    {
	    boolean	couldSetState;	/* <= if not modal, could set State */
	    void	(*motionFunc)(); /* <= for mouse down only */
	    void	*motionMD;	/* <= for mouse down only 
					   (only for item handlers) */
	    
	    int	        buttonNumber;	/* => button number */
	    int		buttonTrans;	/* => type of transition */
	    int		qualifierMask;	/* => ctrl/alt/shift keys down */
	    int		upNumber;	/* => 1=singleClick,2=dblClick,etc */
	    boolean	clicked;	/* => FALSE means press or drag */
	    ULong	buttonTime;	/* => time of transition */
	    Point2d	pt;		/* => point in local coords */
	    Inputq_element  *iqelP;
	    } button;
	struct 
	    {
	    boolean	redrawn;	/* => item had to be redrawn */
	    } synchronize;
	struct
	    {
	    boolean	highlightOn;
	    } highlight;
        struct
	    {
	    boolean	hookHandled;   /* <= only for hooks,TRUE if handled */
	    int		moveDirection; /* <= -1 or 1,to indicate next field */
	    int		keystroke;	/* <> virtual keystroke */
	    int		rawKeystroke;	/* <> raw keystroke */
	    int		qualifierMask;	/* => */
	    Inputq_element  *iqelP;	/* => */
	    int		cursorIndex; /* => hook only, charIndex curs before */

	    boolean	 isAccelerator;	/* <> key is accelerator */
	    ULong	 commandNumber;	/* <> accelerator key cmd */
	    char	*unparsedP;	/* <> accelerator key unparsed */
	    char	*commandTaskIdP; /*<>accelerator key command taskid */
	    } keystroke;	     /* also for POSTKEYSTROKE msgs */
	struct
	    {
	    int		moveDirection; /* => -1 or 1,to indicate next field */
	    int		keystroke;     /* => */
	    int		rawKeystroke;	/* => */
	    int		qualifierMask;	/* => */
	    int		cursorIndex; /* => hook only, charIndex curs before */
	    } executeRequest;
	struct
	    {
	    int		focusOutType;	/* => reason focused out prev item */
	    } focusIn;
	struct
	    {
	    boolean	hookHandled;   /* <= only for hooks,TRUE if handled */
	    boolean	outOfRange;    /* <= if current value out of range */
	    int		nextFocusItemIndex; /* <= -1 = means search */
	    char	*stringValueP; /* => hooks only, string value */
	    char	*formatStrP;   /* => hooks only, to internal format */
	    char	*minStrP;      /* => hooks only, max string */
	    char	*maxStrP;      /* => hooks only, min string */
	    int		 focusOutType; /* => reason focus out, FOCUSOUT_? */
	    int		 moveDirection; /* => 1:Forward, -1:Backward */
	    } focusOut;
	    
	struct
	    {
	    boolean	enabled;	/* => */
	    } setEnabledState;
        struct
	    {
	    Point2d	newPt;	/* => new origin(pixels) rawItemHdr.itemRect*/
	    boolean	redraw;	    /* => redraw at new position? */
	    } move;
	struct
	    {
	    /* used as if resource extent was respecified (except in pixels)*/
	    Sextent	sextent;    /* => pixels */
	    boolean	redraw;	    /* => redraw at new position? */
	    } setExtent;
	struct
	    {
	    char	*newLabelP;	/* => */
	    } setLabel;
	struct		/* used by GETSTATE, SETSTATE, GETVALUE, SETVALUE */
	    {
	    boolean	 hookHandled;  /* <= only for hooks,TRUE if handled */
	    boolean	 valueChanged; /* <= on SET's if value changed */
	    int		 formatType;   /* defined in vartypes.h */
	    ValueUnion	 value;

	    char	*stringValueP;	/* only if string */
	    char	*formatStrP;	/* only if string */
	    int		 maxStringSize; /* only if string & GETs */
	    } value;

	struct
	    {
	    boolean	initFailed;	/* <= set TRUE if error */
	    } init;			/* sent after initial GetState */
	struct
	    {
	    boolean	hookHandled;   /* <= only for hooks,TRUE if handled */
	    int		subItemIndex;  /* => */
	    } queueCommand;
	struct
	    {
	    boolean	reallyChanged;	/* => if setState noticed difference*/
	    } stateChanged;
	struct
	    {
	    int		type;		/* => type of user message */
	    void	*userDataP;     /* => */
	    } user;
	} u;
    } DialogItemMessage;

/*----------------------------------------------------------------------+
|									|
|   									|
|									|
+----------------------------------------------------------------------*/
/* the following structure must be at the beginning of all runtime items */
struct rawitemhdr
    {
    void    *userDataP;		/* for use by itemHooks */
    char    *accessStrP;	/* access str to application variable */
    
    char     *labelP;		/* items label or NULL */
    Point2d   labelPt;		/* position of label */
    Rectangle itemRect;		/* item specific rectangle */
    ULong     helpInfo;		/* item help */
    ULong     helpSource;	/* help file indicator */
    long      synonymsId;	/* id of synonyms resource */
    UShort    highlightOn:1;	/* highlight state */
    
    void    *itemHookMD;	/* mdl process descriptor for hook */
    long     itemHookOffset;	/* mdl hook offset */
    long     itemHookArg;	/* rsc defined arg to hook function */
    void    *ownerDialogP;	/* ptr to owner dialog box */
    DialogItem	*diP;		/* ptr to dialog item struct */
    DialogItem	*parentDiP;	/* ptr to parent dialog item struct */
    };
    
/*----------------------------------------------------------------------+
|									|
|   Dialog Item Handler functions "Publishing" structure		|
|									|
+----------------------------------------------------------------------*/
typedef struct dialogitemhandler
    {
    long	    itemType;
    void	    (*itemHandlerFunction)();
    char	    name[20];
    VersionNumber   version;
    } DialogItemHandler;

/*----------------------------------------------------------------------+
|									|
|   Dialog Hook functions "Publishing" structure			|
|									|
|   Used for both dialog hooks & dialog item hooks.			|
|									|
+----------------------------------------------------------------------*/
typedef struct dialoghookinfo
    {
    long    hookId;
    void    (*dialogHookFunction)();
    } DialogHookInfo;
    
/*----------------------------------------------------------------------+
|									|
|   SplitString Structure -- Used when word wrapping text		|
|									|
+----------------------------------------------------------------------*/
typedef struct splitstringline
    {
    int	     nChars;
    int	     width;
    char    *lineP;
    } SplitStringLine;
    
typedef struct splitstring
    {
    int		     nLines;
    SplitStringLine *lines;
    } SplitString;
    
/*----------------------------------------------------------------------+
|									|
|   Structure for motionFunc Argument					|
|									|
+----------------------------------------------------------------------*/
typedef struct motionfuncarg
    {
    Point2d pt;		    /* => current cursor location (global coords) */
    boolean dragging;	    /* => TRUE if we've moved "DELTA" from down pt */
    } MotionFuncArg;

/*----------------------------------------------------------------------+
|									|
|   Auxiliary Message Structures					|
|									|
|   These structures are only needed by item handler writers emulating	|
|   the standard BSI items.  This section can and should be ignored by	|
|   most readers.							|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   Icon Cmd Palette or Frame Auxiliary Messages			|
|									|
+----------------------------------------------------------------------*/
#define ICONCMD_AUXMESSAGE_CMDKEYEDIN		1
#define ICONCMD_AUXMESSAGE_GETPALETTESELECTION	2
#define ICONCMD_AUXMESSAGE_SETPALETTESELECTION	3
#define	ICONCMD_AUXMESSAGE_ADJUSTTOOLSETTINGS	4

#define ICONCMD_AUXMESSAGE_NITEMS		5
#define ICONCMD_AUXMESSAGE_GETITEMINFO		6
#define ICONCMD_AUXMESSAGE_SETITEMINFO		7

/* selection types */
#define ICONCMD_SELECTTYPE_OFF		0
#define ICONCMD_SELECTTYPE_SINGLESHOT	1
#define ICONCMD_SELECTTYPE_LOCKED       2

typedef struct iconcmd_cmdkeyedin
    {
    void	*iconCmdP;    /* <= NULL if didn't find command in item */
    
    DialogBox	*initiatingDb;
    ULong	 commandNumber;
    char	*taskId;
    int		 selectType;
    } IconCmd_CmdKeyedIn;
    
typedef struct iconcmd_paletteselection
    {
    int	    currentItem;    /* <= currently selected or default item */
    long    paletteId;
    void    *ownerMD;
    } IconCmd_PaletteSelection;
    
typedef struct iconcmd_adjusttoolsettings
    {
    void	*frameIconCmdP;
    DialogItem	*frameDiP;
    void	*paletteIconCmdP;
    DialogItem	*paletteDiP;
    } IconCmd_AdjustToolSettings;

typedef struct iconcmdmessage
    {
    union
	{
	struct
	    {
	    int	    nItems;		/* <= */
	    } getNItems;
	struct
	    {
	    ULong   type;
	    long    id;
	    int	    subItemIndex;
	    } itemInfo;
	} u;
    } IconCmdMessage;

/*----------------------------------------------------------------------+
|									|
|   List Item Auxiliary Messages (Obsolete, DO NOT USE)			|
|									|
+----------------------------------------------------------------------*/
#define LIST_AUXMESSAGE_SETCONTENTS	1
#define LIST_AUXMESSAGE_GETSELECTION	2
#define LIST_AUXMESSAGE_SETSELECTION	3
#define LIST_AUXMESSAGE_CLEARSELECTION	4

typedef struct list_setcontents
    {
    int	    nRows;
    int	    nColumns;
    char    **rowPtrs;
    } List_SetContents;
    
typedef struct list_selection
    {
    int	    rowIndex;
    int	    columnIndex;
    } List_Selection;
    
/*----------------------------------------------------------------------+
|									|
|   ListBox Item Auxiliary Messages    					|
|									|
+----------------------------------------------------------------------*/
#define LISTCELLATTR_HIGHLIGHT	    0x01    /* cell is highlighted */
#define LISTCELLATTR_DISABLED	    0x02    /* cell is unselectable */

#define LISTBOX_AUXMESSAGE_INIT		    1
#define LISTBOX_AUXMESSAGE_GETSTRLISTP	    2
#define LISTBOX_AUXMESSAGE_NROWSCHANGED	    3
#define LISTBOX_AUXMESSAGE_GETDISPLAYRANGE  4
#define LISTBOX_AUXMESSAGE_SETTOPROW	    5
#define LISTBOX_AUXMESSAGE_DRAWCONTENTS	    6
#define LISTBOX_AUXMESSAGE_SELECTCELLS	    7
#define LISTBOX_AUXMESSAGE_ENABLECELLS	    8
#define LISTBOX_AUXMESSAGE_GETSELECTRANGE   9
#define LISTBOX_AUXMESSAGE_GETNEXTSELECTION 10
#define LISTBOX_AUXMESSAGE_CELLSELECTED     11
#define LISTBOX_AUXMESSAGE_CELLENABLED	    12
#define LISTBOX_AUXMESSAGE_CLICKCELL	    13
#define LISTBOX_AUXMESSAGE_SETATTRIBUTES    14

typedef struct listboxmessage
    {
    union
	{
	struct
	    {
	    int		nColumns;    /* => should match # displayed cols */
	    StringList	*strListP;   /* => 1st infoField used by ListBox */
	    } init;
	struct
	    {
	    StringList	*strListP;	    /* <= */
	    } getStrListP;
	struct
	    {
	    int	    minRowIndex;
	    int	    maxRowIndex;
	    int	    minColIndex;
	    int	    maxColIndex;

	    boolean operation;
	    boolean redraw;
	    } range;
	struct
	    {
	    int	    rowIndex;
	    int	    colIndex;
	    
	    boolean result;
	    } cell;
	struct
	    {
	    boolean *foundP;	    /* <= */
	    int	    *rowIndexP;	    /* <> */
	    int	    *colIndexP;	    /* <> */
	    } getNextSelection;
	struct
	    {
	    long    attributes;	    /* => */
	    } setAttributes;
	} u;
    } ListBoxMessage;
    
/*----------------------------------------------------------------------+
|									|
|   MenuBar Item Auxiliary Messages					|
|									|
+----------------------------------------------------------------------*/
#define MENUBAR_AUXMESSAGE_GETITEMINFO	1
#define MENUBAR_AUXMESSAGE_SETITEMINFO	2
#define MENUBAR_AUXMESSAGE_NITEMS	3
#define MENUBAR_AUXMESSAGE_GETSELECTION	4
#define MENUBAR_AUXMESSAGE_FINDITEM	5
#define MENUBAR_AUXMESSAGE_GETITEM	6
#define MENUBAR_AUXMESSAGE_FINDMENU	7
#define MENUBAR_AUXMESSAGE_DELETEMENU	8
#define MENUBAR_AUXMESSAGE_INSERTMENU	9
#define MENUBAR_AUXMESSAGE_GETMENU	10
#define MENUBAR_AUXMESSAGE_NMENUS	11
#define MENUBAR_AUXMESSAGE_DELETEMENUS	12
#define MENUBAR_AUXMESSAGE_ACTIVATEACCEL 13

typedef struct ditem_pulldownmenu
    {
    ULong    type;
    long     id;
    void    *rawMenuP;
    } DItem_PulldownMenu;

typedef struct ditem_pulldownmenuitem
    {
    long		 searchId;
    void		*rawItemP;
    DItem_PulldownMenu	*menuP;		/* set by pdmlib.mc */
    } DItem_PulldownMenuItem;

typedef struct menubar_selection
    {
    ULong   menuType;
    long    menuId;
    int	    subItemIndex;
    long    searchId;
    } MenuBar_Selection;

typedef struct menubar_finditem
    {
    DItem_PulldownMenuItem  *menuItemP;	    /* <= */
    DItem_PulldownMenu	    *menuP;	    /* <> */

    ULong   menuType;
    long    menuId;
    long    searchId;
    int	    subItemIndex;
    } MenuBar_FindItem;

typedef struct menubar_insertmenu
    {
    ULong   menuType;			/* => type of menu to insert */
    long    menuId;			/* => id of menu to insert */

    DItem_PulldownMenu	*beforeMenuP;		/* => insert before menu */
    } MenuBar_InsertMenu;

typedef struct menubar_activateAccel
    {
    DialogItemMessage	*dimP; /* => initiating message (usually keystroke)*/
    DItem_PulldownMenuItem  *menuItemP;
    } MenuBar_ActivateAccel;

typedef struct textpdm_item	    /* text pulldown menu item info */
    {
    DItem_PulldownMenu	submenu;
    
    byte     enabled;
    byte     mark;
    ULong    helpInfo;
    ULong    helpType;
    char    *helpTaskIdP;
    long     pulldownItemHookId;	    
    long     pulldownSearchId;
    ULong    commandNumber;
    char    *commandTaskIdP;
    char    *unparsedP;
    
    char    *labelP;
    ULong    accelerator;
    int	     mnemonic;
    int	     mneIndex;
    } TextPDM_Item;

typedef struct textpdm_itemmodify
    {
    ULong   submenu:1;
    
    ULong   enabled:1;
    ULong   mark:1;
    ULong   helpInfo:1;
    ULong   helpType:1;
    ULong   helpTaskIdP:1;
    ULong   pulldownItemHookId:1;
    ULong   pulldownSearchId:1;
    ULong   commandNumber:1;
    ULong   commandTaskIdP:1;
    ULong   unparsedP:1;

    ULong   labelP:1;
    ULong   acceleratorP:1;
    ULong   mnemonic:1;
    ULong   mneIndex:1;
    } TextPDM_ItemModify;

/*----------------------------------------------------------------------+
|									|
|   Pulldown Menu Messages						|
|									|
+----------------------------------------------------------------------*/
#define PDMENU_MESSAGE_LOAD		200
#define PDMENU_MESSAGE_FREE		201
#define PDMENU_MESSAGE_GETTITLERECT	202
#define PDMENU_MESSAGE_SETTITLERECT	203
#define PDMENU_MESSAGE_GETTITLE		204
#define PDMENU_MESSAGE_SETTITLE		205
#define PDMENU_MESSAGE_SETENABLED	206

#define PDMENU_MESSAGE_DISPLAY		207 /* before getMenuExtent */
#define PDMENU_MESSAGE_GETSUBMENU	208
#define PDMENU_MESSAGE_GETSUBMENURECT	209
#define PDMENU_MESSAGE_GETMENUEXTENT	210
#define PDMENU_MESSAGE_PULLDOWN		211
#define PDMENU_MESSAGE_DRAW		212
#define PDMENU_MESSAGE_WHICHITEM	213
#define PDMENU_MESSAGE_HIGHLIGHTITEM	214
#define PDMENU_MESSAGE_GETITEMSEARCHID	215
#define PDMENU_MESSAGE_ACTIVATEITEM	216

#define PDMENU_MESSAGE_SRCHMENUFORMENU	217
#define PDMENU_MESSAGE_SRCHMENUFORID	218
#define PDMENU_MESSAGE_GETITEM		219
#define PDMENU_MESSAGE_GETNITEMS	220
#define PDMENU_MESSAGE_DELETEITEM	221
#define PDMENU_MESSAGE_DELETEALL	222

#define PDMENU_MESSAGE_GETITEMINFO	223
#define PDMENU_MESSAGE_SETITEMINFO	224
#define PDMENU_MESSAGE_INSERTITEM	225

#define PDMENU_MESSAGE_DISPLAYHELP	226
#define PDMENU_MESSAGE_ACTIVATEACCEL	227
#define PDMENU_MESSAGE_GETITEMLABEL	228
#define PDMENU_MESSAGE_GETPARENT	229

/*  for keeping track of currently "pulled" menus */
typedef struct ditem_pulledmenu
    {
    DItem_PulldownMenu	*menuP;
    DialogBox		*pulldownWindP;

    int			 currentItem;
    ULong		 inItemTime;
    Rectangle		 globalRect;
    void		*motionFuncOffset;
    void		*motionFuncMD;

    boolean		     justContainedMouse; /* only TRUE for 1 in list */
    int			     submenuItemIndex;
    struct ditem_pulledmenu *nextP;
    } DItem_PulledMenu;
    
typedef struct pulldowntrackinginfo	    /* sent to pulldown motion func */
    {
    int	    *currentItemP;	/* <> */
    void    *rawMenuP;		/* => */
    Point2d  pt;		/* => local coords */
    } PulldownTrackingInfo;
    
typedef struct pulldownmenumessage
    {
    boolean		 msgUnderstood;	/* <= message understood? */
    int			 messageType;	/* => message type */
    DItem_PulldownMenu	*menuP;
    union 
	{
	struct
	    {
	    boolean		 loadFailed;	/* <= set TRUE if error */
	    void		*rawMenuP;	/* <= created menu */
	    DialogBox		*db;		/* => owning dialog */
	    void		*ownerMD;	/* => */
	    DItem_PulldownMenu	*parentMenuP;	/* => parent menu */
	    int			 parentItemIndex; /* => index of parentitem */
	    } load;
	struct
	    {
	    Rectangle	*rectP;
	    } rect;
	struct
	    {
	    int		 mneIndex;	/* <= only valid for GETTITLE */
	    boolean	 alignRight;	/* <= only valid for GETTITLE */
	    boolean	 enabled;	/* <= only valid for GETTITLE */
	    char	*titleP;
	    } title;
	struct
	    {
	    boolean	enabled;	/* => */
	    } setEnabled;
	struct
	    {
	    RawItemHdr	*mbarP;		/* => used to construct draw msg */
	    } display;
	struct
	    {
	    void	(*motionFunc)();    /* <= */
	    DialogBox	*pulldownDb;	    /* => */
	    } pulldown;
	struct
	    {
	    int		 itemIndex;	/* <= itemIndex of item cursor in */
	    boolean	 hasSubmenu;	/* <= item has submenu */
	    Point2d	*ptP;		/* => cursor location, local coords */
	    } whichItem;
	struct
	    {
	    int		 itemIndex;	/* => item to highlight */
	    boolean	 highlightOn;	/* => FALSE means turn highlight off*/
	    } highlightItem;
	struct
	    {
	    DItem_PulldownMenu	*submenuP;	/* <= submenu */
	    int			 itemIndex;	/* => submenu to get */
	    } getSubmenu;
	struct
	    {
	    int		     screen;	/* <= screen to display on */
	    Rectangle	    *rectP;	/* <= submenu rect (global coords) */
	    int		     itemIndex;	/* => submenu rect to get */
	    } getSubmenuRect;
	struct
	    {
	    long	 searchId;	/* <= item's search id */
	    int		 itemIndex;	/* => item whose search id to get */
	    } getItemSearchId;
	struct
	    {
	    int			 itemIndex;	/* => item to activate */
	    long		 searchId;	/* => just passed to hook */
	    DialogItemMessage	*dimP;		/* => hooks can ignore */
	    } activateItem;
	    
	struct
	    {
	    DItem_PulldownMenu *menuP;		/* <= found menu */
	    ULong		menuType;	/* => */
	    long		menuId;		/* => */
	    } searchMenuForMenu;
	struct
	    {
	    DItem_PulldownMenuItem *menuItemP;		/* <= found menu */
	    long		    searchId;		/* => */
	    } searchMenuForId;
	struct
	    {
	    DItem_PulldownMenuItem *menuItemP;		/* <= found menu */
	    int			    subItemIndex;	/* => */
	    } getItem;
	struct
	    {
	    int			    nItems;		/* <= */
	    } getNItems;
	struct
	    {
	    DItem_PulldownMenuItem  *menuItemP;	    /* => item to delete */
	    } deleteItem;
	    
	struct
	    {
	    void		    *itemInfoP;
	    void		    *itemModifyP;
	    DItem_PulldownMenuItem  *menuItemP;	    /* => found */
	    } itemInfo;
	struct
	    {
	    int	itemIndex;	/* => item to display help on */
	    } displayHelp;
	struct
	    {
	    DItem_PulldownMenuItem  *menuItemP;	    /* => found */
	    int			 itemIndex;	/* => just passed to hook */
	    long		 searchId;	/* => just passed to hook */
	    DialogItemMessage	*dimP;		/* => hooks can ignore */
	    } activateAccel;
	struct
	    {
	    char		    *labelP;	    /* <= */
	    DItem_PulldownMenuItem  *menuItemP;	    /* =>  */
	    } getItemLabel;
	struct
	    {
	    DItem_PulldownMenu	*parentMenuP;	    /* <= */
	    } getParent;
	} u;
    } PulldownMenuMessage;
    
/*----------------------------------------------------------------------+
|									|
|   Option Button Item Auxiliary Messages				|
|									|
+----------------------------------------------------------------------*/
#define OPTIONBUTTON_AUXMESSAGE_SETENABLED 	1
#define OPTIONBUTTON_AUXMESSAGE_GETITEM		2
#define OPTIONBUTTON_AUXMESSAGE_SETITEM		3
#define OPTIONBUTTON_AUXMESSAGE_NITEMS		4
#define OPTIONBUTTON_AUXMESSAGE_INSERTITEM	5
#define OPTIONBUTTON_AUXMESSAGE_DELETEITEM	6
#define OPTIONBUTTON_AUXMESSAGE_DELETEALL	7

typedef struct optionbutton_setenabled
    {
    boolean	enabled;
    int		subItemIndex;
    } OptionButton_SetEnabled;
    
typedef struct optionbutton_iteminfo
    {
    int	     subItemIndex;

    char    *labelP;
    ULong   *iconTypeP;
    long    *iconIdP;
    int	    *commandSourceP;
    ULong   *valueP;
    ULong   *maskP;
    int	    *enabledP;
    void    *userDataP;
    } OptionButton_ItemInfo;

/*----------------------------------------------------------------------+
|									|
|   Popup Menu Item Auxiliary Messages					|
|									|
+----------------------------------------------------------------------*/
#define POPUPMENU_AUXMESSAGE_SETENABLED 	1

typedef struct popupmenu_setenabled
    {
    boolean	enabled;
    int		subItemIndex;
    } PopupMenu_SetEnabled;
    
/*----------------------------------------------------------------------+
|									|
|   Push Button Item Auxiliary Messages					|
|									|
+----------------------------------------------------------------------*/
#define PUSHBUTTON_AUXMESSAGE_SETDEFAULT	1
#define PUSHBUTTON_AUXMESSAGE_SETCANCEL		2

typedef struct pushbutton_setdefault
    {
    boolean isDefault;
    } PushButton_SetDefault;
    
/*----------------------------------------------------------------------+
|									|
|   Scroll Bar Item Auxiliary Messages					|
|									|
+----------------------------------------------------------------------*/
#define SCROLLBAR_AUXMESSAGE_SETRANGE		1

typedef struct scrollbar_setrange
    {
    double  sliderSize;
    int	    minValue;
    int	    maxValue;
    int	    incAmount;
    int	    pageIncAmount;
    } ScrollBar_SetRange;
    
/*----------------------------------------------------------------------+
|									|
|   Text Item Auxiliary Messages					|
|									|
*+----------------------------------------------------------------------*/
#define TEXT_AUXMESSAGE_GETRANGE	1
#define TEXT_AUXMESSAGE_SETRANGE	2
#define TEXT_AUXMESSAGE_GETBASICTEXT	3

typedef struct text_range
    {
    char   *minimumP;	    /* minimum value */
    char   *maximumP;	    /* maximum value */
    } Text_Range;
    
typedef struct text_getbasictext
    {
    void    *basicTextP;
    } Text_GetBasicText;

/*----------------------------------------------------------------------+
|									|
|   Aux Dialog Handler Structures					|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   Aux Handler Types							|
|									|
+----------------------------------------------------------------------*/
#define AUXHANDLER_VKEYTRAN    'vKey'

/*----------------------------------------------------------------------+
|									|
|   Mdl Aux Handler Structure						|
|									|
+----------------------------------------------------------------------*/
typedef struct mdlauxhandler
    {
    ULong	    handlerType;
    void	   *handlerMD;
    long	    handlerOffset;
    char	    name[20];
    VersionNumber   version;
    } MdlAuxHandler;
    
typedef struct auxhandlermessage
    {
    boolean	 msgUnderstood;	    /* <= message understood? */
    ULong	 handlerType;	 
    void	*messageP;
    } AuxHandlerMessage;
    
/*----------------------------------------------------------------------+
|									|
|   Virtual Key Tranlator Messages					|
|									|
+----------------------------------------------------------------------*/
#define VKEYTRAN_MESSAGE_TRANSRAWKEY	    1	/* raw -> virtual */
#define VKEYTRAN_MESSAGE_GETPRINTSTR	    2
#define VKEYTRAN_MESSAGE_LOADACCELTABLE	    3
#define	VKEYTRAN_MESSAGE_FREEACCELTABLE	    4
#define VKEYTRAN_MESSAGE_GETACCELERATOR	    5	/* virtual -> command */
#define VKEYTRAN_MESSAGE_GETSYSTABLE	    6
#define VKEYTRAN_MESSAGE_ADDACCELERATOR	    7
#define VKEYTRAN_MESSAGE_REMOVEACCELERATOR  8
#define	VKEYTRAN_MESSAGE_SHOWACCELTABLE	    9

typedef struct vkeytranmessage
    {
    int	    messageType;	/* => message type */

    union
	{
	struct
	    {
	    int	virtualKeyCode;	    /* <= */
	    int	qualifierMask;	    /* <> */

	    int rawKeyCode;	    /* => */
	    } translateRawKey;
	struct
	    {
	    char    *printableStrP;	/* <= */
	    int	     virtualKeyCode;	/* => */
	    } getPrintStr;
	struct
	    {
	    AccelKeyTable   *akTableP;	/* <= */
	    
	    RscFileHandle   rscFileH;	/* => */
	    int		    resourceId;	/* => */
	    void	   *ownerMD;	/* => */
	    } loadAccelTable;
        struct
	    {
	    AccelKeyTable   *akTableP;	/* => */
	    } freeAcceleratorTable;
        struct
	    {
	    ULong    commandNumber;	/* <= */
	    char    *unparsedP;		/* <= */
	    char    *commandTaskIdP;	/* <= */
	    DItem_PulldownMenuItem  *menuItemP;	/* <=NULL from system table */
	    
	    AccelKeyTable   *akTableP;		/* => */
	    int		     virtualKeyCode;	/* => */
	    int		     rawKeyCode;	/* => */
	    int		     qualifierMask;	/* => */
	    boolean	     searchSystemTable;	/* => */
	    } getAccelerator;
	struct
	    {
	    AccelKeyTable   **systemAKTablePP;	/* <= */
	    } getSystemAKTablePP;
	struct 
	    {
	    AccelKeyTable   **akTablePP;    /* => */
	    int	     virtualKeyCode;	/* => */
	    int	     rawKeyCode;	/* => */
	    ULong    commandNumber;	/* => */
	    char    *unparsedP;		/* => */
	    char    *commandTaskIdP;	/* => */
	    
	    ULong    menuType;		/* => */
	    long     menuId;		/* => */
	    void    *rawMenuP;		/* => */
	    long     searchId;		/* => */
	    void    *rawItemP;		/* => */ 
	    } addAccelerator;
	struct 
	    {
	    AccelKeyTable   *akTableP;		/* => */
	    int		     virtualKeyCode;	/* => */
	    int		     rawKeyCode;	/* => */
	    } removeAccelerator;
	struct 
	    {
	    AccelKeyTable   *akTableP;    /* => */
	    } showAcceleratorTable;
	} u;
    } VKeyTranMessage;

#endif	/* !defined (resource) */
    
#endif	/* __dlogitemH__ */
