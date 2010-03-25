#include <items.h>
#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMMenu.h"
#include "../hfiles/EMError.h"


#define	SET	1
#define	GET	2
#define	DRAW	3
#define	ERASE	4

#define	LIST_ID		1
#define	CANCEL_ID	2
#define	OK_ID		3


static	ITItem	Control,MenuList;
static	ITItem	Menus = NULL;
static	int	current,ok;

int	(*_EMMenuDriver[16])();

int	_EMMenuWindow;



_EMEnsureKeyboard ()
{
	ITItem	thisItem, prevItem, nextItem;

	/* Find the next eligible keyboard item */
	ITFindByKeyboard (Menus, &thisItem);
	if (thisItem != NULL)
	{
		ITGetPrevKeyboard (thisItem, &prevItem);
		ITFindNextKeyboard (prevItem, &nextItem);
		if ((nextItem != NULL) && (nextItem != thisItem))
			ITSetKeyboard (nextItem, TRUE);
	}
}


static ListCompletion(list)
ITItem	list;
{
	int	window, temp = 0;

	ITGetWindow(list,&window);
	_EMMenuDriver[current](ERASE,window);
	ITListFirstCell(list,&current,&temp,1,IT_LIST_WALK_COLUMN_CONT,&temp);
	_EMMenuDriver[current](DRAW,window);

	_EMEnsureKeyboard ();
}


static OKCompletion(Ok)
ITItem	Ok;
{
	ok = TRUE;
}


static CancelCompletion(Cancel)
ITItem	Cancel;
{
	ok = FALSE;
}


int	_EMCreateControl(Menus,name)
ITItem	Menus;
char	*name;
{
	int	id;
	ITItem	Item;

	ITReadFile(name,&Control,&id);
	ITGroupFindItemNo (Control, LIST_ID, &MenuList);
	ITSetCompletion(MenuList,ListCompletion);

	ITGroupFindItemNo (Control, CANCEL_ID, &Item);
	ITSetCompletion(Item,CancelCompletion);

	ITGroupFindItemNo (Control, OK_ID, &Item);
	ITSetCompletion(Item,OKCompletion);

	ITGroupAdd(Menus,Control,NULL);
	return(TRUE);
}


static SetControl(TCB)
EM_TCB	*TCB;
{
	int	finished, temp = 0;

	current = 0;
	for (ITListFirstCell(MenuList,&current,&temp,-1,IT_LIST_WALK_COLUMN,
			     &finished); !finished;
	     ITListNextCell(MenuList,&current,&temp,-1,IT_LIST_WALK_COLUMN,
			    &finished))
	{
		_EMMenuDriver[current](SET,TCB);
	}
	current = (int) TCB->last_menu;
	ITListSetCellSelect(MenuList,current,0,1);
}


static GetControl(TCB)
EM_TCB	*TCB;
{
	int	finished, temp = 0;

	TCB->last_menu = (char) current;
	if (ok)
	{
		current = 0;
		for (ITListFirstCell(MenuList,&current,&temp,-1,
				     IT_LIST_WALK_COLUMN,&finished);
			!finished;
		     ITListNextCell(MenuList,&current,&temp,-1,
				    IT_LIST_WALK_COLUMN,&finished))
		{
			_EMMenuDriver[current](GET,TCB);
		}
		ok = FALSE;
	}
}


static DrawControl(window)
int	window;
{
	ITImmediateInc(Control);
	hidecursor(window);
	ITDraw(Control);
	_EMMenuDriver[current](DRAW,window);
}


static EraseControl(window)
int	window;
{
	ITImmediateDec(Control);
	_EMMenuDriver[current](ERASE,window);
}


_EMControl(action,parameter)
int	action,parameter;
{
	switch (action)
	{
		case SET:	SetControl(parameter);
				break;
		case GET:	GetControl(parameter);
				break;
		case DRAW:	DrawControl(parameter);
				break;
		case ERASE:	EraseControl(parameter);
				break;
	}
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMSetupMenus					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMSetupMenus (controlFile, generalFile, displayFile,	*/
/*			    keyboardFile, tabFile, printerFile,		*/
/*			    macroFile)					*/
/*									*/
/*	  char	*controlFile;	-- full pathname of control setup menu	*/
/*									*/
/*	  char	*generalFile;	-- full pathname of general setup menu	*/
/*									*/
/*	  char	*displayFile;	-- full pathname of display setup menu	*/
/*									*/
/*	  char	*keyboardFile;	-- full pathname of keyboard setup menu	*/
/*									*/
/*	  char	*tabFile;	-- full pathname of tab setup menu	*/
/*									*/
/*	  char	*printerFile;	-- full pathname of printer setup menu	*/
/*									*/
/*	  char	*macroFile;	-- full pathname of macro setup menu	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sets the menu files for all terminal instances.	*/
/*	  This function should be called before creating any terminal	*/
/*	  instances.  If not, then the standard vterm menus are used.	*/
/*	  If NULL is passed in, then that particular menu is not	*/
/*	  overridden (i.e., the vterm menu is used).  If a zero-length	*/
/*	  string is passed in, the menu is not created.			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  Zero.								*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

static	char	controlMenu[128]	= C_MENU_FILE,
		generalMenu[128]	= G_MENU_FILE,
		displayMenu[128]	= D_MENU_FILE,
		keyboardMenu[128]	= K_MENU_FILE,
		tabMenu[128]		= T_MENU_FILE,
		printerMenu[128]	= P_MENU_FILE,
		macroMenu[128]		= M_MENU_FILE;


int EMSetupMenus (controlFile, generalFile, displayFile, keyboardFile,
		  tabFile, printerFile, macroFile)
char	*controlFile, *generalFile, *displayFile, *keyboardFile,
	*tabFile, *printerFile, *macroFile;
{
	if (controlFile != NULL)
		strcpy(controlMenu,controlFile);
	if (generalFile != NULL)
		strcpy(generalMenu,generalFile);
	if (displayFile != NULL)
		strcpy(displayMenu,displayFile);
	if (keyboardFile != NULL)
		strcpy(keyboardMenu,keyboardFile);
	if (tabFile != NULL)
		strcpy(tabMenu,tabFile);
	if (printerFile != NULL)
		strcpy(printerMenu,printerFile);
	if (macroFile != NULL)
		strcpy(macroMenu,macroFile);
	return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMCreateMenus					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMCreateMenus ()						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function creates the setup menus.			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  If all menus are successfully created, a zero value is	*/
/*	  returned.  Otherwise a non-zero value is returned.  The	*/
/*	  following conditions will return an error:			*/
/*									*/
/*		1.  the general menu cannot be created			*/
/*		2.  the display menu cannot be created,			*/
/*		3.  the keyboard menu cannot be created, and		*/
/*		4.  the tab menu cannot be created.			*/
/*		5.  the printer menu cannot be created			*/
/*		6.  the macro menu cannot be created			*/
/*		7.  the control menu cannot be created			*/
/*									*/
/************************************************************************/

int _EMCreateMenus()
{
	static	ITGroupSpec	menus;

	memset(&menus,(char)0,sizeof(menus));
	menus.item.class = IT_GROUP_CLASS;
	menus.item.type = IT_GROUP;
	menus.item.scale = 1.0;

	if (Menus != NULL)
		return (EM_NO_ERROR);
	
	ITCreate(&menus,&Menus);

	if (generalMenu[0] != '\0')
		if (!_EMCreateGeneral(Menus,generalMenu))
			return(EM_G_MENU_ERROR);

	if (displayMenu[0] != '\0')
		if (!_EMCreateDisplay(Menus,displayMenu))
			return(EM_D_MENU_ERROR);

	if (keyboardMenu[0] != '\0')
		if (!_EMCreateKeyboard(Menus,keyboardMenu))
			return(EM_K_MENU_ERROR);

	if (tabMenu[0] != '\0')
		if (!_EMCreateTab(Menus,tabMenu))
			return(EM_T_MENU_ERROR);

	if (printerMenu[0] != '\0')
		if (!_EMCreatePrinter(Menus,printerMenu))
			return(EM_P_MENU_ERROR);

	if (macroMenu[0] != '\0')
		if (!_EMCreateMacro(Menus,macroMenu))
			return(EM_M_MENU_ERROR);

	_EMCreateControl(Menus,controlMenu);

	ITGroupLinkKeyboards (Menus, IT_KEYIN_CLASS);

	return (EM_NO_ERROR);
}


int	EMSetup(TCBD)
int	TCBD;
{
	EM_TCB	*TCB;
	ITItem	quit;
	int	screen, oldPid;
	float	xSize, ySize;

	TCB = EM_TCB_list[TCBD];	/* point to terminal instance	*/
	_EMSetClipBox(TCB,0,0,-1,-1);	/* set clipbox			*/
					/* user may change column mode	*/
	_EMGraphicsNormal(TCB);		/* set graphics to normal state	*/

	if (TCB->setup_enabled)		/* display if setup enabled	*/
	{
		Inq_displayed_vs (&screen);
		Enter_SR (screen, 4, &_EMMenuWindow);
		Set_win_button_mode (_EMMenuWindow,3);

		/** Load the fixed vlt if necessary **/
		if (!(_EMScreenInfo[screen].vsi_flags & VSI_VLT_FIXED))
		{
		    int			vltSize;
		    struct vlt_slot	*fixedVlt;

		    Get_fixed_vlt (&fixedVlt, &vltSize);
		    Load_SR_vlt (_EMMenuWindow, fixedVlt, vltSize);
		}

		_EMControl (SET, TCB);
		ITSetWindow (Menus,_EMMenuWindow);
		ITGetSize (Menus, &xSize, &ySize);
		Create_SR_area (_EMMenuWindow, 62, 15, (int) (62 + xSize - 1),
				(int) (15 + ySize - 1));

		assign_keybd (getpid (), &oldPid);

		_EMControl (DRAW, _EMMenuWindow);
		_EMEnsureKeyboard ();
		ITProcess (Menus, &quit);
		_EMControl (ERASE, _EMMenuWindow);

		assign_keybd (oldPid, &oldPid);

		Delete_SR_area (_EMMenuWindow);
		Exit_SR (_EMMenuWindow);
		_EMControl (GET, TCB);
	}
	_EMRestoreClipBox (TCB);
	return (0);
}
