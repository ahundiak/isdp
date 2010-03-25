#include	<items.h>
#include	"../hfiles/EMDefines.h"
#include	"../hfiles/EMTCB.h"
#include	"../hfiles/EMGlobals.h"
#include	"../hfiles/EMTerm.h"


#define	SET	1
#define	GET	2
#define	DRAW	3
#define	ERASE	4

#define	COLUMNS_80_ID	0
#define	COLUMNS_132_ID	1
#define	CLEAR_ID	2
#define	SET_ID		3
#define	MOTION_ID	4


static ITItem	Tab,
		ListColumns80,
		ListColumns132,
		ClearButton,
		SetButton,
		MotionChoice;



static ClearTabs(Item)
ITItem	Item;
{
	int	window;

	ITGetWindow(Item,&window);
	hidecursor(window);
	if (_EMColumns(80))
		ITListSetSelect(ListColumns80,0);
	else
		ITListSetSelect(ListColumns132,0);
	showcursor(window);
	flushbuffer(window);
}


static SetTabs(Item)
ITItem	Item;
{
	int	column,window;

	ITGetWindow(Item,&window);
	hidecursor(window);
	if (_EMColumns(80))
		for (column = 0; column < 80; column++)
			ITListSetCellSelect (ListColumns80, 0, column, (column % 8) ? 0 : 1);
	else
		for (column = 0; column < 132; column++)
			ITListSetCellSelect (ListColumns132, 0, column, (column % 8) ? 0 : 1);
	showcursor(window);
	flushbuffer(window);
}


static SetTab(TCB)
EM_TCB	*TCB;
{
	int		column;
	unsigned char	*cell;
	EMTermSettings	*term;

	term = &TCB->term_settings;
	cell = &term->tabMap[0];
	for (column = 0; column < 80; column++)
	{
		ITListSetCellSelect(ListColumns80,0,column,*cell);
		ITListSetCellSelect(ListColumns132,0,column,*cell);
		cell++;
	}
	for (column = 80; column < 132; column++)
	{
		ITListSetCellSelect(ListColumns132,0,column,*cell);
		cell++;
	}
	ITChoiceSetValue(MotionChoice,term->tabMovement);
}


static GetTab(TCB)
EM_TCB	*TCB;
{
	int		column,value;
	EMTermSettings	*term;

	term = &TCB->term_settings;

	for (column=0; column<132; column++)
	{
		ITListGetCellSelect(ListColumns132,0,column,&value);
		term->tabMap[column] = (value ? TRUE : FALSE);
	}
	ITChoiceGetValue(MotionChoice,&value);
	term->tabMovement = (value ? TRUE : FALSE);
}


static DrawTab(window)
int	window;
{
	if (_EMColumns(80))
		ITImmediateInc(ListColumns80);
	else
		ITImmediateInc(ListColumns132);
	ITImmediateInc(Tab);
	hidecursor(window);
	ITDraw(Tab);
	showcursor(window);
	flushbuffer(window);
}


static EraseTab(window)
int	window;
{
	int	column,select;

	if (_EMColumns(80))
	{
		ITImmediateDec(ListColumns80);
		for (column = 0; column < 80; column++)
		{
			ITListGetCellSelect(ListColumns80,0,column,&select);
			ITListSetCellSelect(ListColumns132,0,column,select);
		}
	}
	else
	{
		ITImmediateDec(ListColumns132);
		for (column = 0; column < 80; column++)
		{
			ITListGetCellSelect(ListColumns132,0,column,&select);
			ITListSetCellSelect(ListColumns80,0,column,select);
		}
	}
	ITImmediateDec(Tab);
}


_EMTab(action,parameter)
int	action,parameter;
{
	switch (action)
	{
		case SET:	SetTab(parameter);
				break;
		case GET:	GetTab(parameter);
				break;
		case DRAW:	DrawTab(parameter);
				break;
		case ERASE:	EraseTab(parameter);
				break;
	}
}


int	_EMCreateTab(Menus,name)
ITItem	Menus;
char	*name;
{
	int	memory, id;

	if (ITReadFile(name,&Tab,&memory))
		return (FALSE);

	ITGetId (Tab, &id);
	_EMMenuDriver[id - 100] = _EMTab;
	ITGroupAdd(Menus,Tab,NULL);

	ITGroupFindItemNo(Tab,COLUMNS_80_ID,&ListColumns80);
	ITGroupFindItemNo(Tab,COLUMNS_132_ID,&ListColumns132);
	ITGroupFindItemNo(Tab,CLEAR_ID,&ClearButton);
	ITGroupFindItemNo(Tab,SET_ID,&SetButton);
	ITGroupFindItemNo(Tab,MOTION_ID,&MotionChoice);

	ITImmediateDec(ListColumns80);
	ITImmediateDec(ListColumns132);

	ITSetCompletion(ClearButton,ClearTabs);
	ITSetCompletion(SetButton,SetTabs);

	return(TRUE);
}
