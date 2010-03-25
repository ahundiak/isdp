#include	<items.h>
#include	<malloc.h>
#include	"../hfiles/EMDefines.h"
#include	"../hfiles/EMTCB.h"
#include	"../hfiles/EMGlobals.h"
#include	"../hfiles/EMTerm.h"
#include	"../hfiles/EMError.h"


#define	SET		1
#define	GET		2
#define	DRAW		3
#define	ERASE		4

#define	ONLINE_ID	0
#define	LOCAL_ECHO_ID	1
#define	NUM_SCREENS_ID	3
#define	UDK_ID		4
#define	LOG_FILE_ID	5
#define	FILE_NAME_ID	6
#define	NEW_LINE_ID	7
#define	FORM_FEED_ID	8
#define	ERASE_MARG_ID	9
#define	VT220_ID	10
#define	BIT8_ID		11


void		_EMPutEnv ();


static ITItem	General,
		onlineSwitch,
		localEchoSwitch,
		bufScreensKeyin,
		userDefKeysSwitch,
		logFileSwitch,
		logFileKeyin,
		newLineSwitch,
		formFeedChoice,
		eraseMargChoice,
		vt220Choice,
		bit8Choice;



static int SwitchChange_(Switch)
ITItem	Switch;
{
	int	value;
	ITItem	Keyin,Current;

	ITGetSpecial (Switch, &Keyin);
	ITSwitchGetValue (Switch, &value);
	ITSetEnable (Keyin, value);

	if (value)
		ITSetKeyboard(Keyin,value);
	else
	{
		/* Give the keyboard to another keyin */
		_EMEnsureKeyboard ();
	}
}


static int SwitchChange (item)
ITItem	item;
{
	int	window;

	ITGetWindow(item,&window);
	hidecursor (window);

	SwitchChange_ (item);

	showcursor (window);
	flushbuffer (window);
}


static int EmulationChange_ (item)
ITItem	item;
{
	int	value;

	ITChoiceGetValue (item, &value);
	ITSetEnable (bit8Choice, (value == 1));
	if (value == 0)
		ITChoiceSetValue (bit8Choice, 0);
}


static int EmulationChange (item)
ITItem	item;
{
	int	window;

	ITGetWindow(item,&window);
	hidecursor(window);

	EmulationChange_(item);

	showcursor (window);
	flushbuffer (window);
}


static SetGeneral(TCB)
EM_TCB	*TCB;
{
	char		s[10];
	EMTermSettings	*term;

	term = &TCB->term_settings;

	ITSwitchSetValue (onlineSwitch, term->online);
	ITSwitchSetValue (localEchoSwitch, term->localEcho);

	sprintf (s, "%d", term->bufScreens);
	ITKeyinSetText (bufScreensKeyin, s, 0, strlen (s));

	ITSwitchSetValue (userDefKeysSwitch, term->udkLock);
	ITSwitchSetValue (logFileSwitch, term->logFlag);
	ITKeyinSetText (logFileKeyin, term->logFile, 0, strlen (term->logFile));
	ITSwitchSetValue (newLineSwitch, term->newLine);
	ITChoiceSetValue (formFeedChoice, term->formFeed ? 1 : 0);
	ITChoiceSetValue (eraseMargChoice, term->eraseExtent ? 1 : 0);
	ITChoiceSetValue (vt220Choice, term->vt200 ? 1 : 0);
	ITChoiceSetValue (bit8Choice, term->bit8 ? 1 : 0);

	EmulationChange_(vt220Choice);
	SwitchChange_(logFileSwitch);
}


static GetGeneral(TCB)
EM_TCB	*TCB;
{
	int		value,vs_no,phys_no;
	char		*temp1,*temp2,temp3[128];
	EMTermSettings	*term;

	term = &TCB->term_settings;

	ITSwitchGetValue (onlineSwitch, &value);
	term->online = (value ? TRUE : FALSE);

	ITSwitchGetValue (localEchoSwitch, &value);
	term->localEcho = (value ? TRUE : FALSE);

	ITKeyinGetText(bufScreensKeyin,&temp1);
	value = strlen(temp1);
	temp2 = malloc(value + 1);
	memcpy(temp2,temp1,value);
	temp2[value] = '\0';
	value = atoi(temp2);
	free(temp2);
	_EMSetBufferSize(TCB,value);

	ITSwitchGetValue (userDefKeysSwitch, &value);
	term->udkLock = (value ? TRUE : FALSE);

	ITSwitchGetValue (logFileSwitch, &value);
	if ((value != term->logFlag) || (term->logFlag))
	{
		EMSetLogFileStatus(TCB->TCBD,value);
		if (value)
		{
			ITKeyinGetText(logFileKeyin,&temp1);
			value = strlen(temp1);
			strcpy(temp3,term->logFile);
			strncpy(term->logFile,temp1,32);
			if (value < 32)
				term->logFile[value] = '\0';
			else
				term->logFile[31] = '\0';
			if (EMSetLogFileName(TCB->TCBD,term->logFile))
			{    /* if there is an error in accessing this
				file */
			    strcpy(term->logFile,temp3);
			    EMSetLogFileStatus(TCB->TCBD,FALSE);
			    vs_no=_EMGetScreenNumber(&TCB->state_table);
			    phys_no=_EMScreenInfo[vs_no].vsi_screen_num;
			    Error_box(phys_no,EM_LOG_FILE_ERRMSG, 3);



			}
		}
	}

	ITSwitchGetValue (newLineSwitch, &value);
	term->newLine = (value ? TRUE : FALSE);

	ITChoiceGetValue (formFeedChoice, &value);
	term->formFeed = value;

	ITChoiceGetValue (eraseMargChoice, &value);
	term->eraseExtent = value;

	ITChoiceGetValue (vt220Choice,&value);
	if (value != term->vt200)
	{
		term->vt200 = value;
		_EMPutEnv(TCB);
	}

	ITChoiceGetValue (bit8Choice, &value);
	term->bit8 = value;
}


static DrawGeneral(window)
int	window;
{
	ITImmediateInc(General);
	hidecursor(window);
	ITDraw(General);
	showcursor(window);
	flushbuffer(window);
}


static EraseGeneral(window)
int	window;
{
	ITImmediateDec(General);
}


_EMGeneral(action,parameter)
int	action,parameter;
{
	switch (action)
	{
		case SET:	SetGeneral(parameter);
				break;
		case GET:	GetGeneral(parameter);
				break;
		case DRAW:	DrawGeneral(parameter);
				break;
		case ERASE:	EraseGeneral(parameter);
				break;
	}
}


int	_EMCreateGeneral(Menus,name)
ITItem	Menus;
char	*name;
{
	int	memory, id;

	if(ITReadFile(name,&General,&memory))
		return (FALSE);

	ITGetId (General, &id);
	_EMMenuDriver[id - 100] = _EMGeneral;
	ITGroupAdd(Menus,General,NULL);

	ITGroupFindItemNo (General, ONLINE_ID, &onlineSwitch);
	ITGroupFindItemNo (General, LOCAL_ECHO_ID, &localEchoSwitch);
	ITGroupFindItemNo (General, NUM_SCREENS_ID, &bufScreensKeyin);
	ITGroupFindItemNo (General, UDK_ID, &userDefKeysSwitch);
	ITGroupFindItemNo (General, LOG_FILE_ID, &logFileSwitch);
	ITGroupFindItemNo (General, FILE_NAME_ID, &logFileKeyin);
	ITGroupFindItemNo (General, NEW_LINE_ID, &newLineSwitch);
	ITGroupFindItemNo (General, FORM_FEED_ID, &formFeedChoice);
	ITGroupFindItemNo (General, ERASE_MARG_ID, &eraseMargChoice);
	ITGroupFindItemNo (General, VT220_ID, &vt220Choice);
	ITGroupFindItemNo (General, BIT8_ID, &bit8Choice);

	ITSetCompletion (vt220Choice, EmulationChange);
	ITSetCompletion (logFileSwitch, SwitchChange);

	ITSetSpecial (logFileSwitch, logFileKeyin);

	ITSetKeyboard (bufScreensKeyin, TRUE);

	return(TRUE);
}
