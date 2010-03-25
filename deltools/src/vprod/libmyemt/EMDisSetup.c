#include	<items.h>
#include	"../hfiles/EMDefines.h"
#include	"../hfiles/EMTCB.h"
#include	"../hfiles/EMGlobals.h"
#include	"../hfiles/EMTerm.h"


#define	SET	1
#define	GET	2
#define	DRAW	3
#define	ERASE	4

#define	AUTOWRAP_ID	0
#define	DISP_CTRL_ID	1
#define	JUMP_SCROLL_ID	2
#define	LIGHT_BG_ID	3
#define	ERASE_SCREEN_ID	4
#define	COLUMNS_80_ID	5
#define	CURS_VIS_ID	6
#define	CURS_BLINK_ID	7
#define	CURS_BLOCK_ID	8


static ITItem	Display,
		autoWrapSwitch,
		displayCtrlSwitch,
		jumpScrollSwitch,
		lightBGSwitch,
		eraseScreenSwitch,
		columns80Choice,
		cursVisSwitch,
		cursBlinkSwitch,
		cursBlockChoice;



int	_EMColumns(columns)
int	columns;
{
	int	value;

	ITChoiceGetValue(columns80Choice,&value);
	if (value)
		if (columns == 132)
			return (TRUE);
		else
			return (FALSE);
	else
		if (columns == 80)
			return (TRUE);
		else
			return (FALSE);
}


static SetDisplay(TCB)
EM_TCB	*TCB;
{
	EMTermSettings	*term;

	term = &TCB->term_settings;

	ITSwitchSetValue (autoWrapSwitch, term->autoWrap);
	ITSwitchSetValue (displayCtrlSwitch, term->displayControls);
	ITSwitchSetValue (jumpScrollSwitch, term->noScroll);
	ITSwitchSetValue (lightBGSwitch, term->screenReverse);
	ITSwitchSetValue (eraseScreenSwitch, term->chngWdErase);
	ITChoiceSetValue (columns80Choice, term->eighty ? 0 : 1);
	ITSwitchSetValue (cursVisSwitch, term->cursorVisible);
	ITSwitchSetValue (cursBlinkSwitch, term->cursorBlinking);
	ITChoiceSetValue (cursBlockChoice, term->cursorBlock ? 0 : 1);
}


static GetDisplay(TCB)
EM_TCB	*TCB;
{
	int		value,
			update = FALSE;
	EMTermSettings	*term;

	term = &TCB->term_settings;

	ITSwitchGetValue (autoWrapSwitch, &value);
	term->autoWrap = (value ? TRUE : FALSE);

	ITSwitchGetValue (displayCtrlSwitch, &value);
	term->displayControls = (value ? TRUE : FALSE);

	ITSwitchGetValue (jumpScrollSwitch, &value);
	term->noScroll = (value ? TRUE : FALSE);

	ITSwitchGetValue (lightBGSwitch, &value);
	if (value != term->screenReverse)
	{
		update = TRUE;
		term->screenReverse = value;
		_EMReverseScreenColors(TCB);
	}

	ITSwitchGetValue (eraseScreenSwitch, &value);
	term->chngWdErase = (value ? TRUE : FALSE);

	ITChoiceGetValue (columns80Choice, &value);
	value = ((value == 0) ? TRUE : FALSE);
	if (value != term->eighty)
	{
		update = TRUE;
		term->eighty = value;
		if (term->eighty)
			_EMSet80Columns(TCB);
		else
			_EMSet132Columns(TCB);
	}

	ITSwitchGetValue (cursVisSwitch, &value);
	if (value != term->cursorVisible)
	{
		update = TRUE;
		term->cursorVisible = value;
	}

	ITSwitchGetValue (cursBlinkSwitch, &value);
	if (value != term->cursorBlinking)
	{
		update = TRUE;
		term->cursorBlinking = value;
	}

	ITChoiceGetValue (cursBlockChoice, &value);
	value = ((value == 0) ? TRUE : FALSE);
	if (value != term->cursorBlock)
	{
		update = TRUE;
		term->cursorBlock = value;
	}

	if (update)
	{
		hidecursor (TCB->window);
		_EMClearScreen(TCB);
		_EMDisplayScreen(TCB, 0, TCB->displayed_rows,
				 0, TCB->col_width, TRUE);
		_EMDrawCursor(TCB);
		showcursor (TCB->window);
		update = FALSE;
	}
}


static DrawDisplay(window)
int	window;
{
	ITImmediateInc(Display);
	hidecursor(window);
	ITDraw(Display);
	showcursor(window);
	flushbuffer(window);
}


static EraseDisplay(window)
int	window;
{
	ITImmediateDec(Display);
}


_EMDisplay(action,parameter)
int	action,parameter;
{
	switch (action)
	{
		case SET:	SetDisplay(parameter);
				break;
		case GET:	GetDisplay(parameter);
				break;
		case DRAW:	DrawDisplay(parameter);
				break;
		case ERASE:	EraseDisplay(parameter);
				break;
	}
}


int	_EMCreateDisplay(Menus,name)
ITItem	Menus;
char	*name;
{
	int	memory, id;

	if(ITReadFile(name,&Display,&memory))
		return (FALSE);

	ITGetId (Display, &id);
	_EMMenuDriver[id - 100] = _EMDisplay;
	ITGroupAdd (Menus, Display, NULL);

	ITGroupFindItemNo (Display, AUTOWRAP_ID, &autoWrapSwitch);
	ITGroupFindItemNo (Display, DISP_CTRL_ID, &displayCtrlSwitch);
	ITGroupFindItemNo (Display, JUMP_SCROLL_ID, &jumpScrollSwitch);
	ITGroupFindItemNo (Display, LIGHT_BG_ID, &lightBGSwitch);
	ITGroupFindItemNo (Display, ERASE_SCREEN_ID, &eraseScreenSwitch);
	ITGroupFindItemNo (Display, COLUMNS_80_ID, &columns80Choice);
	ITGroupFindItemNo (Display, CURS_VIS_ID, &cursVisSwitch);
	ITGroupFindItemNo (Display, CURS_BLINK_ID, &cursBlinkSwitch);
	ITGroupFindItemNo (Display, CURS_BLOCK_ID, &cursBlockChoice);

	return(TRUE);
}
