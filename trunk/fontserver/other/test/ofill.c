/* This program uses a filled outline font to generate an outlined	*/
/* and a shadowed style of the font.					*/


#include <stdio.h>
#include <tools.h>
#include <gpipe.h>
#include <FS.h>
#include <FSOutl.h>

char *string = "The quick brown fox jumps over the lazy dog.";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			64.0,		/* bodysize	*/
			1.0,		/* res factor	*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii"		/* char map	*/
			FS_3D
		    };

struct vlt_slot vlt[] = { {1, 65535, 16384, 8192} };

void	FillOutline(), FillOutline3();
int	FSSetOutlDrawFunc(), FSSetOutl3DDrawFunc();

main (argc, argv)
int argc;
char *argv[];
{
    FontId	font;
    int		wNo, i, vs, gPipe, event, threeD;
    int		x1, y1, x2, y2;
    double	x, y, atof();
    void	(*fillFunc)(), (*drawFunc)();
    int		(*setFillFunc)();

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atoi (argv[2]);

    if (argc > 3)
	string = argv[3];

    if (argc > 4)
	fontSpec.flags = atoi (argv[4]);

    threeD = (fontSpec.flags & FS_3D) != 0;
    fontSpec.flags |= FS_OUTLINE;

    Enter_tools ();
    Enable_events (DELETE_EVENT);

    GPEnter ();
    FSEnter (0);

    if (FSNewFont (&fontSpec, NULL, &font) != FS_NO_ERROR)
    {
	printf ("Can't create font!\n");
	exit (1);
    }

    Inq_displayed_vs (&vs);
    Loadvlt (vs, vlt, sizeof (vlt) / sizeof (struct vlt_slot));

    x1 = 20;	y1 = 40;
    x2 = 1020;	y2 = 820;
    Create_win (vs, "GPipe-filled outline fonts", x1, y1, x2, y2, &wNo);
    Set_win_sys_icon (wNo, REFRESH_ICON_VALUE, 0);
    Display_win (wNo);

    if (GPCreateWin (threeD ? 1 : 0, wNo, &gPipe) != 0)
    {
	printf ("Can't create gPipe!\n");
	exit (1);
    }

    GPPutViewport (gPipe, 0.0, 0.0, 0.0, (double) x2 - x1, (double) y2 - y1,
			0.0);

    if (threeD)
    {
	fillFunc = FillOutline3;
	drawFunc = _FSDrawOutline3D;
	setFillFunc = FSSetOutl3DDrawFunc;
    }
    else
    {
	fillFunc = FillOutline;
	drawFunc = _FSDrawOutline;
	setFillFunc = FSSetOutlDrawFunc;
    }

    hidecursor (wNo);
    fgcolor (wNo, -1);
    rectf (wNo, 0, 0, x2 - x1, y2 - y1);

    x = 10.0;	y = fontSpec.bodySize;
    (*setFillFunc) (fillFunc);
    fgcolor (wNo, 1);
    FSDrawString (gPipe, font, string, x, y, NULL, NULL);

    x = 10.0;	y = fontSpec.bodySize * 2;
    FSDrawString (gPipe, font, string, x, y, NULL, NULL);

    x = 10.0;	y = fontSpec.bodySize * 2;
    (*setFillFunc) (drawFunc);
    fgcolor (wNo, 0);
    FSDrawString (wNo, font, string, x, y, NULL, NULL);

    x = 10.0;	y = fontSpec.bodySize * 3;
    x += fontSpec.bodySize * 0.07;
    y += fontSpec.bodySize * 0.07;
    (*setFillFunc) (fillFunc);
    fgcolor (wNo, 0);
    FSDrawString (gPipe, font, string, x, y, NULL, NULL);

    x = 10.0;	y = fontSpec.bodySize * 3;
    fgcolor (wNo, -1);
    FSDrawString (gPipe, font, string, x, y, NULL, NULL);

    x = 10.0;	y = fontSpec.bodySize * 3;
    (*setFillFunc) (drawFunc);
    fgcolor (wNo, 0);
    FSDrawString (wNo, font, string, x, y, NULL, NULL);

    showcursor (wNo);
    flushbuffer (wNo);

    Wait_for_events (DELETE_EVENT, &event);

    GPExit ();
    FSExit ();
    Exit_tools ();
}



void FillOutline (gPipe, x, y, vert, pSize, nPolys)
int gPipe;
double x, y;
OutlVertex *vert;
OutlPolySize *pSize;
int nPolys;
{
    if (nPolys > 0)
    {
	GPResetMatrix (gPipe);
	GPScale2D (gPipe, 1.0, -1.0, 0);
	GPTranslate2D (gPipe, x - 0.5, y - 0.5, 0);
	GPPolyFill2D (gPipe, vert, pSize, nPolys, 0);
    }
}



void FillOutline3 (gPipe, x, y, vert, pSize, nPolys)
int gPipe;
double x, y;
Outl3DVertex *vert;
OutlPolySize *pSize;
int nPolys;
{
    if (nPolys > 0)
    {
	GPResetMatrix (gPipe);
	GPScale3D (gPipe, 1.0, -1.0, 1.0, 0);
	GPTranslate3D (gPipe, x - 0.5, y - 0.5, 0.0, 0);
	GPPolyFill3D (gPipe, vert, pSize, nPolys, 0);
    }
}
