#include	<items.h>
#include	"../hfiles/EMDefines.h"
#include	"../hfiles/EMTCB.h"
#include	"../hfiles/EMGlobals.h"
#include	"../hfiles/EMTerm.h"


#define	SET	1
#define	GET	2
#define	DRAW	3
#define	ERASE	4

#define	WARN_BELL_ID	0
#define	AUTO_REPEAT_ID	1
#define	CURSOR_KEYS_ID	2
#define	KEYPAD_ID	3
#define	CONCEALED_ID	4
#define	ANSWERBACK_ID	5


static ITItem	Keyboard,
		warnBellSwitch,
		autoRepeatSwitch,
		cursorKeysChoice,
		keypadChoice,
		concealedSwitch,
		answerbackKeyin;

static char	answerbackCopy[30];

void	_EMUpdateKeyboardMode ();



static int ConcealedChange (item)
ITItem	item;
{
	int		window;

	ITGetWindow (item, &window);
	hidecursor (window);

	ConcealedChange_ (item);

	showcursor (window);
	flushbuffer (window);
}


static int ConcealedChange_ (item)
ITItem	item;
{
	int	value;
	char	*text;
	ITItem	keyin;

	ITSwitchGetValue (item, &value);
	if (value)
	{
		ITGetSpecial (item, &keyin);

		ITSetEnable (item, FALSE);
		ITKeyinGetText(keyin,&text);
		value = strlen(text);
		strncpy(answerbackCopy,text,30);
		if (value < 30)
			answerbackCopy[value] = '\0';
		else
			answerbackCopy[29] = '\0';
		ITKeyinSetText (keyin, "", 0, 0);
	}
}


static int AnswerbackChange (item, key)
ITItem	item;
char	*key;
{
	int	value;
	ITItem	theSwitch;

	ITGetSpecial (item, &theSwitch);
	ITSwitchGetValue (theSwitch, &value);
	if (value)
	{
		int	window;

		ITGetWindow (theSwitch, &window);
		hidecursor (window);
		ITSetEnable (theSwitch, TRUE);
		ITSwitchSetValue (theSwitch, FALSE);
		showcursor (window);
		flushbuffer (window);
	}
}


static SetKeyboard(TCB)
EM_TCB	*TCB;
{
    EMTermSettings	*term;

    term = &TCB->term_settings;

    ITSwitchSetValue (warnBellSwitch, term->warningBell);
    ITSwitchSetValue (autoRepeatSwitch, term->autoRepeat);
    ITChoiceSetValue (cursorKeysChoice, term->normalCursorKeys ? 0 : 1);
    ITChoiceSetValue (keypadChoice, term->numericKeypad ? 0 : 1);
    ITSwitchSetValue (concealedSwitch, term->answerbackConcealed);
    ITSetEnable (concealedSwitch, !term->answerbackConcealed);
    ITKeyinSetText (answerbackKeyin, term->answerback, 0,
		    strlen (term->answerback));

    ConcealedChange_ (concealedSwitch);
}


static GetKeyboard(TCB)
EM_TCB	*TCB;
{
	int		value;
	char		*text;
	EMTermSettings	*term;

	term = &TCB->term_settings;

	ITSwitchGetValue (warnBellSwitch, &value);
	term->warningBell = (value ? TRUE : FALSE);

	ITSwitchGetValue (autoRepeatSwitch, &value);
	if (value != term->autoRepeat)
	{
		term->autoRepeat = value;
		keybd_auto_repeat(value);
	}

	ITChoiceGetValue (cursorKeysChoice, &value);
	term->normalCursorKeys = ((value == 0) ? TRUE : FALSE);

	ITChoiceGetValue (keypadChoice, &value);
	term->numericKeypad = ((value == 0) ? TRUE : FALSE);

	ITSwitchGetValue (concealedSwitch, &value);
	term->answerbackConcealed = (value ? TRUE : FALSE);

	if (term->answerbackConcealed)
		strcpy (term->answerback, answerbackCopy);
	else
	{
		ITKeyinGetText(answerbackKeyin,&text);
		value = strlen(text);
		strncpy(term->answerback,text,30);
		if (value < 30)
			term->answerback[value] = '\0';
		else
			term->answerback[29] = '\0';
	}
}


static DrawKeyboard(window)
int	window;
{
	ITImmediateInc(Keyboard);
	hidecursor(window);
	ITDraw(Keyboard);
	showcursor(window);
	flushbuffer(window);
}


static EraseKeyboard(window)
int	window;
{
	ITImmediateDec(Keyboard);
}


_EMKeyboard(action,parameter)
int	action,parameter;
{
	switch (action)
	{
		case SET:	SetKeyboard(parameter);
				break;
		case GET:	GetKeyboard(parameter);
				break;
		case DRAW:	DrawKeyboard(parameter);
				break;
		case ERASE:	EraseKeyboard(parameter);
				break;
	}
}


int	_EMCreateKeyboard(menus,name)
ITItem	menus;
char	*name;
{
	int	memory, id;

	if(ITReadFile(name,&Keyboard,&memory))
		return (FALSE);

	ITGetId (Keyboard, &id);
	_EMMenuDriver[id - 100] = _EMKeyboard;
	ITGroupAdd (menus, Keyboard, NULL);

	ITGroupFindItemNo (Keyboard, WARN_BELL_ID, &warnBellSwitch);
	ITGroupFindItemNo (Keyboard, AUTO_REPEAT_ID, &autoRepeatSwitch);
	ITGroupFindItemNo (Keyboard, CURSOR_KEYS_ID, &cursorKeysChoice);
	ITGroupFindItemNo (Keyboard, KEYPAD_ID, &keypadChoice);
	ITGroupFindItemNo (Keyboard, CONCEALED_ID, &concealedSwitch);
	ITGroupFindItemNo (Keyboard, ANSWERBACK_ID, &answerbackKeyin);

	ITKeyinSetFilter (answerbackKeyin, AnswerbackChange);
	ITSetSpecial (answerbackKeyin, concealedSwitch);

	ITSetCompletion (concealedSwitch, ConcealedChange);
	ITSetSpecial (concealedSwitch, answerbackKeyin);

	return(TRUE);
}
