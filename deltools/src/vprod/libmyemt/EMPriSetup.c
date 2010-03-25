#include	<items.h>
#include	"../hfiles/EMDefines.h"
#include	"../hfiles/EMTCB.h"
#include	"../hfiles/EMGlobals.h"
#include	"../hfiles/EMTerm.h"


#define	SET	1
#define	GET	2
#define	DRAW	3
#define	ERASE	4

#define	PR_ATT_ID	0
#define	PR_MODE_ID	1
#define	TERM_ID		2


static ITItem	Printer,
		prAttachedSwitch,
		modeChoice,
		termChoice;



static int PrinterAttachChange (item)
ITItem	item;
{
    int	window;

    ITGetWindow (item, &window);
    hidecursor (window);

    PrinterAttachChange_ (item);

    showcursor (window);
    flushbuffer (window);
}


static int PrinterAttachChange_ (item)
ITItem	item;
{
    int	value;

    ITSwitchGetValue (item, &value);
    ITSetEnable (modeChoice, value);
    ITSetEnable (termChoice, value);
}


static SetPrinter(TCB)
EM_TCB	*TCB;
{
	EMTermSettings	*term;

	term = &TCB->term_settings;

	ITSwitchSetValue (prAttachedSwitch, term->printerMode != NO_PRINTER);
	ITChoiceSetValue (modeChoice, MAX (0, (int) term->printerMode - 1));
	ITChoiceSetValue (termChoice, term->printTerminator ? 1 : 0);

	PrinterAttachChange_ (prAttachedSwitch);
}


static GetPrinter(TCB)
EM_TCB	*TCB;
{
	int		value;
	EMTermSettings	*term;

	term = &TCB->term_settings;

	ITSwitchGetValue (prAttachedSwitch, &value);
	if (!value)
		term->printerMode = NO_PRINTER;
	else
	{
		ITChoiceGetValue (modeChoice, &value);
		term->printerMode = value + 1;
	}

	ITChoiceGetValue (termChoice, &value);
	term->printTerminator = (value ? TRUE : FALSE);
}


static DrawPrinter(window)
int	window;
{
	ITImmediateInc(Printer);
	hidecursor(window);
	ITDraw(Printer);
	showcursor(window);
	flushbuffer(window);
}


static ErasePrinter(window)
int	window;
{
	ITImmediateDec(Printer);
}


_EMPrinter(action,parameter)
int	action,parameter;
{
	switch (action)
	{
		case SET:	SetPrinter(parameter);
				break;
		case GET:	GetPrinter(parameter);
				break;
		case DRAW:	DrawPrinter(parameter);
				break;
		case ERASE:	ErasePrinter(parameter);
				break;
	}
}


int	_EMCreatePrinter(menus,name)
ITItem	menus;
char	*name;
{
	int	memory, id;

	if(ITReadFile(name,&Printer,&memory))
		return (FALSE);

	ITGetId (Printer, &id);
	_EMMenuDriver[id - 100] = _EMPrinter;
	ITGroupAdd (menus, Printer, NULL);

	ITGroupFindItemNo (Printer, PR_ATT_ID, &prAttachedSwitch);
	ITGroupFindItemNo (Printer, PR_MODE_ID, &modeChoice);
	ITGroupFindItemNo (Printer, TERM_ID, &termChoice);

	ITSetCompletion (prAttachedSwitch, PrinterAttachChange);

	return(TRUE);
}
