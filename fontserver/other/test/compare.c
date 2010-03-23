/* This program draws character from a bitmap font next to characters	*/
/* from an outline font filled with GPipe.  Compare and weep.		*/


#include <stdio.h>
#include <tools.h>
#include <gpipe.h>
#include <FS.h>
#include <FSBmap.h>
#include <FSOutl.h>

char *string = "The quick brown fox jumps over the lazy dog.";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			24.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",	/* char map	*/
			FS_OUTLINE | FS_DEMAND
		    };

void FillOutline();
extern double	atof ();

main (argc, argv)
int argc;
char *argv[];
{
    FontId oFont, bFont;
    int wno, i, vs, gPipe;
    long event;
    double x, y, atof();
    
    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    if (argc > 3)
	fontSpec.rotation = atof (argv[3]);

    if (argc > 4)
	string = argv[4];

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    GPenter ();
    FSEnter (0);

    fontSpec.flags |= FS_OUTLINE;
    FSNewFont (&fontSpec, NULL, &oFont);	/* outline font */
    
    fontSpec.flags &= ~FS_OUTLINE;
    FSNewFont (&fontSpec, NULL, &bFont);	/* bitmap font */

    Inq_displayed_vs (&vs);
    Create_win (vs, "Compare bitmap with filled outline", 20, 40, 1020, 640,
		&wno);
    Set_win_sys_icon (wno, REFRESH_ICON_VALUE, 0);
    Display_win (wno);
    GPcreate_win (0, wno, &gPipe);
    GPputviewport (gPipe, 0.0, 0.0, 0.0, 1000.0, 800.0, 0.0);

    hidecursor (wno);

    x = 10.0;	y = (double) fontSpec.bodySize;
    FSSetOutlDrawFunc (FillOutline);
    FSDrawString (gPipe, oFont, string, x, y, NULL, NULL);

    x = 10.0;	y = (double) fontSpec.bodySize * 2;
    FSDrawString (wno, bFont, string, x, y, NULL, NULL);

    showcursor (wno);
    flushbuffer (wno);

    Wait_for_events (DELETE_EVENT, &event);

    GPexit ();
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
	GPreset_matrix (gPipe);
	GPscale2d (gPipe, 1.0, -1.0, 0);
	GPtranslate2d (gPipe, x - 0.5, y - 0.5, 0);
	GPpolyfill2d (gPipe, vert, pSize, nPolys, 0);
    }
}
