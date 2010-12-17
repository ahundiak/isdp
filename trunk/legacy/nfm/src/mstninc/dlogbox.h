/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   dlogbox.h  $
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
|   dlogbox.h -- Dialog Box Manager definitions used by			|
|		  MicroStation/MDL					|
|									|
+----------------------------------------------------------------------*/
#if !defined (__dlogboxH__)
#define __dlogboxH__

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

/*----------------------------------------------------------------------+
|									|
|   Basic Dialog Box Constants  					|
|									|
+----------------------------------------------------------------------*/
#define DCOORD_RESOLUTION   12	    /* # of dialog coords/font height */

/* define what one char width and one char height are in resource files */
#if defined (resource)
#define XC (DCOORD_RESOLUTION/2)
#define YC DCOORD_RESOLUTION

/* define conversion macro from row # to dialog Y coordinate */
#define GAP 3
#define GENY(row) ((row-1)*(YC+GAP) + YC/2)
#endif

/*----------------------------------------------------------------------+
|									|
|   Dialog Attributes Constants						|
|									|
+----------------------------------------------------------------------*/
#define	DIALOGATTR_DEFAULT			 0
#define DIALOGATTR_MODAL		0x00000001
#define DIALOGATTR_GROWABLE		0x00000002
#define DIALOGATTR_SINKABLE		0x00000004
#define DIALOGATTR_UNMOVEABLE		0x00000008
#define DIALOGATTR_UNCLOSEABLE		0x00000010

#define DIALOGATTR_NOAUTOSWITCH		0x00000020
#define DIALOGATTR_CLOSEONNEW		0x00000040
#define DIALOGATTR_ALWAYSSETSTATE	0x00000080
#define DIALOGATTR_NORIGHTICONS		0x00000100
#define DIALOGATTR_AUTOOPEN		0x00000200
#define DIALOGATTR_NOWINDOWCONTROLICON  0x00000400	/* do not use */
#define DIALOGATTR_ALLOWNOTITLEBAR	0x00000800
#define DIALOGATTR_NOAUTOACTIVATE	0x00001000
#define DIALOGATTR_NOSYNCHONNEW		0x00002000

/*----------------------------------------------------------------------+
|									|
|   Item Attributes							|
|									|
+----------------------------------------------------------------------*/
#define DISABLED	   0x0		/* same as OFF */
#define ENABLED		   0x1		/* same as ON */
#define HIDDEN		   0x2

/*----------------------------------------------------------------------+
|									|
|   General Item Constants (Only needed in resource files)      	|
|									|
+----------------------------------------------------------------------*/
#define MCMD		    0
#define	LCMD		    1

#define MHELP		    0x0
#define LHELP		    0x1
#define HELPCMD		    0x2
#define HELPTOPIC	    0x0

#define MHELPTOPIC	    (MHELP | HELPTOPIC)
#define MHELPCMD	    (MHELP | HELPCMD)
#define LHELPTOPIC	    (LHELP | HELPTOPIC)
#define LHELPCMD	    (LHELP | HELPCMD)

#if defined (resource)

/* for Text Pulldown Menus & Icon Commands Only */
/* used in commandTaskId field */
#define OTASKID		    ""
#define MTASKID		    "+"

/* for Text Pulldown Menus & Icon Commands Only */
/* used in helpTaskId field */
#define	OHELPTASKIDCMD	    ""
#define OHELPTASKIDTOPIC    "*"
#define MHELPTASKIDCMD	    "+"
#define	MHELPTASKIDTOPIC    "+*"

#define LOOKUP		    1
#define NOLOOKUP	    0

#define INVERT		    1
#define	NOINVERT	    0

#define NOCMD		    0
#define NOMASK		    0xFFFFFFFF

#define NOSYNONYM	    0
#define NOHELP		    0
#define NOHOOK		    0
#define NOARG		    0
#define NOID		    0

#define NOSUBMENU	    0
#define NOMARK		    0
#define	NOACCEL		    0

#define NOPARENTID	    0

#define NOTYPE		    0
#define NOICON	    	    0

#endif

/*----------------------------------------------------------------------+
|									|
|   Item Specific Constants						|
|									|
+----------------------------------------------------------------------*/
#define ALIGN_LEFT	    0x0
#define ALIGN_RIGHT	    0x2
#define	ALIGN_CENTER	    0x4
#define ALIGN_MASK	    0x6
#define ALIGN_SHIFTAMOUNT   1

#define BUTTON_STDWIDTH	    (8*XC)

#define LABEL_WORDWRAP	    0x08
#define LABEL_FONT_BOLD	    0x10	/* Only used in label items */

#define TEXT_NOCONCAT	    0x0
#define TEXT_CONCAT	    0x1
#define TEXT_NOECHO	    0x2
#define TEXT_READONLY	    0x4

#define SCROLL_ARROW_UP	    0
#define SCROLL_ARROW_DOWN   1
#define SCROLL_ARROW_LEFT   2
#define SCROLL_ARROW_RIGHT  3

#define MARK_TOGGLE_OUT	    1
#define MARK_TOGGLE_IN      2
#define MARK_RADIO_OUT	    3
#define MARK_RADIO_IN	    4
#define MARK_RIGHT_ARROW    5

#define DEFAULT_BUTTON	    0x01
#define NOT_DEFAULT_BUTTON  0x00
#define CANCEL_BUTTON	    0x02

#define TEXT_MASK_LABELABOVE	1

#define FORMAT_MONOBITMAP   0

#define NOICONID	    0

#define LISTATTR_LABELONSIDE	    0x01    /* not above */
#define LISTATTR_NEVERSELECTION	    0x02    /* can never have any selection */
#define LISTATTR_RANGESELECTION	    0x04    /* not single selection */
#define LISTATTR_DISJOINTSELECTION  0x08    /* not contiguous */
#define LISTATTR_NOSELECTION	    0x10    /* can have nothing selected */
#ifdef NOTYET
#define LISTATTR_INDEPENDENTCOLS    0x20    /* columns can be indiv. sel */
#endif
#define LISTATTR_NOKEYSEARCH	    0x40    /* no search upon key press */
#define LISTATTR_FIXEDFONT	    0x80    /* use fixed width font */

#define ICONCMDATTR_DONTSINGLESHOT    0x01

/* these next four #defines are obsolete DO NOT USE */
#define NOCONCAT	    0x0
#define CONCAT		    0x1
#define NOECHO		    0x2
#define READONLY	    0x4

/*----------------------------------------------------------------------+
|									|
|   Action Button Types							|
|									|
+----------------------------------------------------------------------*/
#define ACTIONBUTTON_APPLY	    1
#define ACTIONBUTTON_RESET	    2
#define ACTIONBUTTON_OK		    3
#define ACTIONBUTTON_CANCEL	    4
#define ACTIONBUTTON_DEFAULT	    5

/*----------------------------------------------------------------------+
|									|
|   Resource Definitions						|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   Standard Resource Types        					|
|									|
+----------------------------------------------------------------------*/
#define RTYPE_DialogBox		    'dBox'
#define RTYPE_DialogItemList	    'dilt'
#define RTYPE_ItemList		    'iLst'
#define RTYPE_DialogPosition	    'dPos'
#define RTYPE_PalettePosition	    'PPos'
#define RTYPE_KeyinSaveArea	    'kSav'

#define RTYPE_ColorPicker	    'cPck'
#define RTYPE_Command		    'cmnd'
#define RTYPE_Generic		    'gnrc'
#define RTYPE_GroupBox		    'gBox'
#define RTYPE_IconCmd		    'iCmd'
#define RTYPE_IconCmdSmallIcon	    'iCSm'
#define RTYPE_IconCmdLargeIcon	    'iCLg'
#define RTYPE_IconCmdPalette	    'iPal'
#define RTYPE_IconCmdFrame	    'iFrm'
#define RTYPE_Label		    'labl'
#define RTYPE_LevelMap		    'levm'
#define RTYPE_List		    'list'  /* obsolete, do not use */
#define RTYPE_ListBox		    'lBox'
#define RTYPE_MenuBar		    'mBar'
#define RTYPE_MultilineText	    'mTxt'
#define RTYPE_OptionButton 	    'oBtn'
#define RTYPE_PopupMenu 	    'pMen'  /* obsolete, do not use */
#define RTYPE_PrecisionButton	    'prcB'
#define RTYPE_PulldownMenu	    'pdMn'
#define RTYPE_PulldownOptionMenu    'pdOM'
#define RTYPE_PulldownCPickerMenu   'pdCM'
#define RTYPE_PushButton	    'pBtn'
#define RTYPE_ScrollBar		    'sBar'
#define RTYPE_Synonyms  	    'syns'
#define RTYPE_Text		    'dTxt'
#define RTYPE_ToggleButton	    'tBtn'
#define RTYPE_WindowMenu	    'wMen'

#define	RTYPE_Icon		    'Icon'
#define RTYPE_StringArray	    'str#'

#define RTYPE_VirtualKeyTable	    'vTbl'
#define RTYPE_AcceleratorKeyTable   'aTbl'

/*----------------------------------------------------------------------+
|									|
|  Microstation StringArray Resource Type			    	|
|									|
+----------------------------------------------------------------------*/
#if defined (resource)
typedef struct stringarray
    {
    char    variableLengthString [];
    }  StringArray [];
#else
typedef struct stringarray
    {
    ULong   numStrings;
    /* First string element. */
    ULong   stringSize;
    char    data[1];	
    } StringArray;
#endif
#if defined (resource)
resourceclass StringArray RTYPE_StringArray;
#endif

/*----------------------------------------------------------------------+
|									|
|   Dialog Box Position Resource					|
|									|
+----------------------------------------------------------------------*/
typedef struct dialogpositionrsc
    {
    UShort  screen;		    /* high bits=autoOpen,contains frame */
    short   screenWidth;
    short   screenHeight;
    Point2d pt;			    /* global origin of contentRect */
    } DialogPositionRsc;
#if defined (resource)
resourceclass DialogPositionRsc RTYPE_DialogPosition;
#endif

/*----------------------------------------------------------------------+
|									|
|   Palette Position Resource						|
|									|
+----------------------------------------------------------------------*/
typedef DialogPositionRsc PalettePositionRsc;
#if defined (resource)
resourceclass PalettePositionRsc RTYPE_PalettePosition;
#endif

/*----------------------------------------------------------------------+
|									|
|   Item Specifier Structure						|
|									|
+----------------------------------------------------------------------*/
typedef struct dialogitemspec
    {
    long    type;
    long    id;
    } DialogItemSpec;
    
/*----------------------------------------------------------------------+
|									|
|   Dialog Box Structures       					|
|									|
+----------------------------------------------------------------------*/
typedef struct dialogitemrsc
    {
    Sextent extent;	/* sensitive area, origin (in dialog coords), 
			   if width/height is zero use dimensions
			   specified in item */
    long    type;	/* item type */
    long    id;
    byte    attributes;
    long    itemArg;
#if defined (resource)
    char    label[]; 
    char    auxInfo[];
#else
    long    labelLength;
    char    label[1];
#endif    
    } DialogItemRsc;
    
typedef struct dialogboxrsc
    {
    ULong	    attributes;
    int		    width;		/* dialog coords */
    int		    height;		/* dialog coords */
    ULong	    helpInfo;
    ULong	    helpSource;
    long	    dialogHookId;
    long	    parentDialogId;	/* used to inform when destroyed */
#if defined (resource)
    char	    label[]; 
    DialogItemRsc   itemList[];
#else
    long    labelLength;
    char    label[1];
#endif    
    } DialogBoxRsc;
#if defined (resource)
resourceclass DialogBoxRsc RTYPE_DialogBox;
#endif

/*----------------------------------------------------------------------+
|									|
|   Dialog Item List Structure (just like list in dialogs)      	|
|									|
+----------------------------------------------------------------------*/
typedef struct dialogitemlistrsc
    {
#if defined (resource)
    DialogItemRsc   items[];
#else
    long	    nItems;
    DialogItemRsc  itemList[1];
#endif    
    } DialogItemListRsc;
#if defined (resource)
resourceclass DialogItemListRsc RTYPE_DialogItemList;
#endif

/*----------------------------------------------------------------------+
|									|
|   Item List Structure (Only has list of type and ids) 		|
|									|
+----------------------------------------------------------------------*/
typedef struct itemlistrsc
    {
#if defined (resource)
    DialogItemSpec   items[];
#else
    long	    nItems;
    DialogItemSpec  itemList[1];
#endif    
    } ItemListRsc;
#if defined (resource)
resourceclass ItemListRsc RTYPE_ItemList;
#endif

/*----------------------------------------------------------------------+
|									|
|   Item Synonyms Structure     					|
|									|
+----------------------------------------------------------------------*/
typedef ItemListRsc DItem_SynonymsRsc;
#if defined (resource)
resourceclass DItem_SynonymsRsc RTYPE_Synonyms;
#endif

/*----------------------------------------------------------------------+
|									|
|   Icon Resource							|
|									|
+----------------------------------------------------------------------*/
typedef struct iconRsc
    {
    int	    width;
    int	    height;
    int	    format;
    int	    fgColorIndex;
    char    name[16];
#if defined (resource)
    byte    data[];
#else
    long    numBytes;
    byte    data[1];
#endif
    } IconRsc;

#if defined (resource)
resourceclass	IconRsc RTYPE_Icon;
#define Icon RTYPE_Icon
#endif
#if defined (resource)
typedef IconRsc IconCmdSmallRsc;
resourceclass	IconCmdSmallRsc RTYPE_IconCmdSmallIcon;
#endif
#if defined (resource)
typedef IconRsc IconCmdLargeRsc;
resourceclass	IconCmdLargeRsc RTYPE_IconCmdLargeIcon;
#endif

/*----------------------------------------------------------------------+
|									|
|   Icon Cmd Palette Item (can only contain Icon Cmds)      		|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_iconcmdpalettersc
    {
    int	    nColumns;
    int	    nRows; 
    int	    defaultItem;
    ULong   helpInfo;
    ULong   helpSource;
    long    itemHookId;
    long    itemHookArg;
#if defined (resource)
    char    label[];
    int	    iconCmds[];
#else
    long    labelLength;
    char    label[1];
#endif
    } DItem_IconCmdPaletteRsc;
#if defined (resource)
resourceclass DItem_IconCmdPaletteRsc RTYPE_IconCmdPalette;
#define IconCmdPalette RTYPE_IconCmdPalette
#endif
    
/*----------------------------------------------------------------------+
|									|
|   Standard Dialog Item Definitions   					|
|									|
|   These definitions are only needed in resource files & mdl files.	|
|   They are never used by .c files.					|
|									|
+----------------------------------------------------------------------*/
#if defined (resource) || defined (mdl)
/*----------------------------------------------------------------------+
|									|
|   Color Picker							|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_colorpickerrsc
    {
    ULong	    commandNumber;
    ULong	    commandSource;
    long	    synonymsId;
    ULong	    helpInfo;
    ULong	    helpSource;
    long	    itemHookId;
    long	    itemHookArg;
    long	    associatedTextId;
    
    ULong	    mask;
    
#if defined (resource)
    char    label[];
    char    accessStr[];
#else
    long    labelLength;
    char    label[1];
#endif    
    } DItem_ColorPickerRsc;

#if defined (resource)
resourceclass DItem_ColorPickerRsc RTYPE_ColorPicker;
#define ColorPicker RTYPE_ColorPicker
#endif
    
/*----------------------------------------------------------------------+
|									|
|   Command Dialog Item							|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_commandrsc
    {
    ULong	    helpInfo;
    ULong	    helpSource;
    long	    itemHookId;
    long	    itemHookArg;
    unsigned char    maxSize;		    /* max # of chars in field */
#if defined (resource)
    char    label[];
#else
    long    labelLength;
    char    label[1];
#endif    
    } DItem_CommandRsc;

#if defined (resource)
resourceclass DItem_CommandRsc RTYPE_Command;
#define Command RTYPE_Command  
#endif

/*----------------------------------------------------------------------+
|									|
|   Generic Dialog Item							|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_genericrsc
    {
    ULong	    helpInfo;
    ULong	    helpSource;
    long	    itemHookId;
    long	    itemHookArg;
    } DItem_GenericRsc;

#if defined (resource)
resourceclass DItem_GenericRsc RTYPE_Generic;
#define Generic RTYPE_Generic
#endif

/*----------------------------------------------------------------------+
|									|
|   GroupBox Dialog Item						|
|									|
+----------------------------------------------------------------------*/
#if defined (resource)
#define GroupBox RTYPE_GroupBox
#endif

/*----------------------------------------------------------------------+
|									|
|   Icon Command Item (not to be directly placed in dialog)		|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_iconcmdrsc
    {
    ULong   helpInfo;
#if defined (resource)
    char    helpTaskId[];
    ULong   attributes;
    ULong   commandNumber;
    char    commandTaskId[];
    char	    unparsed[]
    char	    enabledAccessStr[];
    DialogItemRsc   iconItems[];
#else
    long    helpTaskIdLength;
    char    helpTaskId[1];
#endif    
    } DItem_IconCmdRsc;
#if defined (resource)
resourceclass DItem_IconCmdRsc RTYPE_IconCmd;
#define IconCmd RTYPE_IconCmd
#endif

/*----------------------------------------------------------------------+
|									|
|   Icon Cmd Frame Item (can contain Icon Cmds & Icon Palettes)		|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_iconcmdframersc
    {
    int	nColumns;
    int	nRows; 
    ULong   helpInfo;
    ULong   helpSource;
#if defined (resource)
    char		label[];
    DialogItemSpec	iconPieces[];
#else
    long    labelLength;
    char    label[1];
#endif
    } DItem_IconCmdFrameRsc;
#if defined (resource)
resourceclass DItem_IconCmdFrameRsc RTYPE_IconCmdFrame;
#define IconCmdFrame RTYPE_IconCmdFrame
#endif
    
/*----------------------------------------------------------------------+
|									|
|   Label Dialog Item							|
|									|
+----------------------------------------------------------------------*/
#if defined (resource)
#define Label RTYPE_Label
#endif

/*----------------------------------------------------------------------+
|									|
|   Level Map Dialog Item						|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_levelmaprsc
    {
    ULong	    helpInfo;
    ULong	    helpSource;
#if defined (resource)
    char    label[];
    char    accessStr[];
    char    activeLevelAccessStr[];
#else
    long    labelLength;
    char    label[1];
#endif    
    } DItem_LevelMapRsc;


#if defined (resource)
resourceclass DItem_LevelMapRsc RTYPE_LevelMap;
#define LevelMap RTYPE_LevelMap
#endif

/*----------------------------------------------------------------------+
|									|
|   ListBox Dialog Item							|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_listcolumnrsc
    {
    int	    width;
    int	    maxSize;			    /* max # of chars in column */
    long    attributes;
#if defined (resource)
    char    heading[];
#else
    long    headingLength;
    char    heading[1];
#endif    
    } DItem_ListColumnRsc;
    
typedef struct ditem_listrsc
    {
    ULong	    helpInfo;
    ULong	    helpSource;
    long	    itemHookId;
    long	    itemHookArg;
    long	    attributes;
    int		    nRows;
    int		    sizeNumColumn;
    
#if defined (resource)
    char    label[];
    DItem_ListColumnRsc	listColumns[];
#else
    long    labelLength;
    char    label[1];
#endif    

    } DItem_ListRsc;
typedef DItem_ListRsc DItem_ListBoxRsc;

#if defined (resource)
resourceclass DItem_ListRsc RTYPE_List;	    /* OBSOLETE DO NOT USE */
#define List RTYPE_List			    /* OBSOLETE DO NOT USE */
resourceclass DItem_ListBoxRsc RTYPE_ListBox;
#define ListBox RTYPE_ListBox
#endif

/*----------------------------------------------------------------------+
|									|
|   Menu Bar Item       						|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_menubaritemrsc
    {
    long    type;
    long    id;
    } DItem_MenuBarItemRsc;

typedef struct ditem_menubarrsc
    {
    long	    itemHookId;
    long	    itemHookArg;
#if defined (resource)
    DItem_MenuBarItemRsc  menuBarItems[];
#else
    long		  nMenus;
    DItem_MenuBarItemRsc  pulldownMenus[1];
#endif    
    } DItem_MenuBarRsc;
#if defined (resource)
resourceclass DItem_MenuBarRsc RTYPE_MenuBar;
#define MenuBar RTYPE_MenuBar
#endif

/*----------------------------------------------------------------------+
|									|
|   Multiline Text Dialog Item						|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_multilinetextrsc
    {
    long	    synonymsId;
    ULong	    helpInfo;
    ULong	    helpSource;
    long	    itemHookId;
    long	    itemHookArg;
    
    UShort	    attributes;		    /* other attributes */
    int		    displayRows;
#if defined (resource)
    char	    label[];
#else
    long	    labelLength;
    char	    label[1];
#endif    
    } DItem_MultilineTextRsc;

#if defined (resource)
resourceclass DItem_MultilineTextRsc RTYPE_MultilineText;
#define MLText RTYPE_MultilineText  
#endif


/*----------------------------------------------------------------------+
|									|
|   Option Button Dialog Item						|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_optionbuttonitemrsc
    {
    ULong   iconType;
    long    iconId;
    ULong   commandNumber;
    ULong   commandSource;
    ULong   value;
    ULong   mask;
    byte    enabled;
#if defined (resource)
    char    label[];
#else
    long    labelLength;
    char    label[1];
#endif    
    } DItem_OptionButtonItemRsc;

typedef struct ditem_optionbuttonrsc
    {
    long    synonymsId;
    ULong   helpInfo;
    ULong   helpSource;
    long    itemHookId;
    long    itemHookArg;
#if defined (resource)
    char    label[];
    char    accessStr[];
    DItem_OptionButtonItemRsc  optionButtonItems[];
#else
    long    labelLength;
    char    label[1];
#endif    
    } DItem_OptionButtonRsc;
#if defined (resource)
resourceclass DItem_OptionButtonRsc RTYPE_OptionButton;
#define OptionButton RTYPE_OptionButton
#endif

/*----------------------------------------------------------------------+
|									|
|   PopupMenu Dialog Item (OBSOLETE DO NOT USE)				|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_popupmenuitemrsc
    {
    ULong   commandNumber;
    ULong   commandSource;
    ULong   value;
    ULong   mask;
    byte    enabled;
#if defined (resource)
    char    label[];
#else
    long    labelLength;
    char    label[1];
#endif    
    } DItem_PopupMenuItemRsc;

typedef struct ditem_popupmenursc
    {
    long    synonymsId;
    ULong   helpInfo;
    ULong   helpSource;
    long    itemHookId;
    long    itemHookArg;
#if defined (resource)
    char    label[];
    char    accessStr[];
    DItem_PopupMenuItemRsc  popupMenuItems[];
#else
    long    labelLength;
    char    label[1];
#endif    
    } DItem_PopupMenuRsc;
#if defined (resource)
resourceclass DItem_PopupMenuRsc RTYPE_PopupMenu;
#define PopupMenu RTYPE_PopupMenu
#endif

/*----------------------------------------------------------------------+
|									|
|   Pulldown Menu Item (must be used only inside menubars)		|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_pulldownmenuitemrsc
    {
#if defined (resource)
    char    label[];
    ULong   accelerator;
    byte    enabled;
    byte    mark;
    long    subMenuType;
    long    submenuId;
    ULong   helpInfo;
    char    helpTaskId[];
    long    pulldownItemHookId;	    
    long    searchId;		    /* used to search for item */
    ULong   commandNumber;
    char    commandTaskId[];
    char    unparsed[];
#else
    long    labelLength;
    char    label[1];
#endif
    } DItem_PulldownMenuItemRsc;
    
typedef struct ditem_pulldownmenursc
    {
    ULong	    helpInfo;
#if defined (resource)
    char     helpTaskId[];
    long     pulldownHookId;
    ULong    attributes;
    char     menuTitle[];
    DItem_PulldownMenuItemRsc  pulldownItems[];
#else
    long     helpTaskIdLength;
    char     helpTaskId[1];
#endif    
    } DItem_PulldownMenuRsc;
#if defined (resource)
resourceclass DItem_PulldownMenuRsc RTYPE_PulldownMenu;
#define PulldownMenu RTYPE_PulldownMenu
#endif
	
/*----------------------------------------------------------------------+
|									|
|   Pulldown Color Picker Menu						|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_pulldowncpickermenursc
    {
    long    synonymsId;
    ULong   helpInfo;
    ULong   helpSource;
    long    pulldownHookId;
    ULong   attributes;
    ULong   commandNumber;
    ULong   commandSource;
    ULong   mask;
    
#if defined (resource)
    char    menuTitle[];
    char    accessStr[];
#else
    long    menuTitleLength;
    char    menuTitle[1];
#endif    
    } DItem_PulldownCPickerMenuRsc;

#if defined (resource)
resourceclass DItem_PulldownCPickerMenuRsc RTYPE_PulldownCPickerMenu;
#define PulldownCPickerMenu RTYPE_PulldownCPickerMenu
#endif
    
/*----------------------------------------------------------------------+
|									|
|   Pulldown Option Menu Item (must be used only inside menubars)	|
|									|
+----------------------------------------------------------------------*/
typedef DItem_OptionButtonItemRsc DItem_PulldownOptionItemRsc;

typedef struct ditem_pulldownoptionmenursc
    {
    long	    synonymsId;
    ULong	    helpInfo;
    ULong	    helpSource;
    long	    pulldownHookId;
    ULong	    attributes;
#if defined (resource)
    char    menuTitle[];
    char    accessStr[];
    DItem_PulldownOptionItemRsc  pulldownOptionItems[];
#else
    long    menuTitleLength;
    char    menuTitle[1];
#endif    
    } DItem_PulldownOptionMenuRsc;
#if defined (resource)
resourceclass DItem_PulldownOptionMenuRsc RTYPE_PulldownOptionMenu;
#define PulldownOptionMenu RTYPE_PulldownOptionMenu
#endif

/*----------------------------------------------------------------------+
|									|
|   Push Button Dialog Item						|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_pushbuttonrsc
    {
    char	    isDefault;		/* TRUE if this is default button */
    ULong	    helpInfo;
    ULong	    helpSource;
    long	    itemHookId;
    long	    itemHookArg;
    ULong	    commandNumber;
    ULong	    commandSource;
#if defined (resource)
    char    unparsed[];
    char    label[];
#else
    long    unparsedLength;
    char    unparsed[1];
#endif    
    } DItem_PushButtonRsc;

#if defined (resource)
resourceclass DItem_PushButtonRsc RTYPE_PushButton;
#define PushButton RTYPE_PushButton  
#endif

/*----------------------------------------------------------------------+
|									|
|   Scrollbar Dialog Item       					|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_scrollbarrsc
    {
    long    itemHookId;
    long    itemHookArg;
    int	    minValue;
    int	    maxValue;
    int	    incAmount;
    int	    pageIncAmount;
    double  sliderSize;
#if defined (resource)
    char    accessStr[];
#else
    long    accessStrLength;
    char    accessStr[1];
#endif    
    } DItem_ScrollBarRsc;
#if defined (resource)
resourceclass DItem_ScrollBarRsc RTYPE_ScrollBar;
#define ScrollBar RTYPE_ScrollBar
#endif

/*----------------------------------------------------------------------+
|									|
|   Text Dialog Item							|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_textrsc
    {
    ULong	    commandNumber;
    ULong	    commandSource;
    long	    synonymsId;
    ULong	    helpInfo;
    ULong	    helpSource;
    long	    itemHookId;
    long	    itemHookArg;
    
    byte    maxSize;		    /* max # of chars in field */
    char    formatToDisplay[16];    /* format str to convert from internal */
    char    formatToInternal[16];   /* convert to internal from display str */
    char    minimum[16];		    /* minimum value */
    char    maximum[16];		    /* maximum value */
    ULong   mask;	    /* only used with integer types */
    UShort  attributes;		    /* other attributes */
#if defined (resource)
    char    label[];
    char    accessStr[];
#else
    long    labelLength;
    char    label[1];
#endif    
    } DItem_TextRsc;

#if defined (resource)
resourceclass DItem_TextRsc RTYPE_Text;
#define Text RTYPE_Text  
#endif

/*----------------------------------------------------------------------+
|									|
|   ToggleButton Dialog Item						|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_togglebuttonrsc
    {
    ULong   commandNumber;
    ULong   commandSource;
    long    synonymsId;
    ULong   helpInfo;
    ULong   helpSource;
    long    itemHookId;
    long    itemHookArg;

    ULong   mask;
    char    invertFlag;
    
#if defined (resource)
    char    label[];
    char    accessStr[];
#else
    long    labelLength;
    char    label[1];
#endif    
    } DItem_ToggleButtonRsc;

#if defined (resource)
resourceclass DItem_ToggleButtonRsc RTYPE_ToggleButton;
#define ToggleButton RTYPE_ToggleButton
#endif

/*----------------------------------------------------------------------+
|									|
|   Non-General Use Items						|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   Precision Button Dialog Item					|
|									|
+----------------------------------------------------------------------*/
typedef struct ditem_precisionbuttonrsc
    {
    ULong	    helpInfo;
    ULong	    helpSource;
    long	    itemHookId;
    long	    itemHookArg;
    ULong	    commandNumber;
    ULong	    commandSource;
#if defined (resource)
    char    label[];
    char    accessStr[];
#else
    long    labelLength;
    char    label[1];
#endif    
    } DItem_PrecisionButtonRsc;

#if defined (resource)
resourceclass DItem_PrecisionButtonRsc RTYPE_PrecisionButton;
#define PrecisionButton RTYPE_PrecisionButton  
#endif

/*----------------------------------------------------------------------+
|									|
|   Window Menu Item							|
|									|
+----------------------------------------------------------------------*/
typedef DItem_MenuBarRsc DItem_WindowMenuRsc;

#if defined (resource)
resourceclass DItem_WindowMenuRsc RTYPE_WindowMenu;
#define WindowMenu RTYPE_WindowMenu
#endif

#endif  /* resource || mdl */

/*----------------------------------------------------------------------+
|									|
|   Other Resource Structures						|
|									|
+----------------------------------------------------------------------*/
#endif	/* __dlogboxH__ */
