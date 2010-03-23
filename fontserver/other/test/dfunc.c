/* This program tests the bitmap (and outline) draw function		*/
/* capability.  By default, a bitmap font is created; if the FS_OUTLINE	*/
/* flag is turned on, an outline font is created (thus testing the	*/
/* outline draw function).						*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>
#include <FSOutl.h>

char *string = "The quick brown fox jumps over the lazy dog. 0123456789 !@#$%^&*()[]{}<>";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			24.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",	/* char map	*/
			FS_DEMAND	/* flags	*/
		    };

void	DrawBitmap (), DrawOutline (), DrawOutline3D ();

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    BmapInfo info;
    int vs, tmp, window;
    double x, y, atof ();

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    if (argc > 3)
	fontSpec.flags = atoi (argv[3]);

    if (argc > 4)
	string = argv[4];

    FSEnter (0);

    if (FSNewFont (&fontSpec, NULL, &font) != FS_NO_ERROR)
    {
	printf ("Can't create font!\n");
	goto DONE;
    }

    if (FSGetBmapInfo (font, &info) == FS_INVALID_FONT)
	FSGetOutlInfo (font, &info);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    Inq_displayed_vs (&vs);
    Create_win (vs, "A weirded font", 20, 40, 1020, 440, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);

    hidecursor (window);

    FSSetBmapDrawFunc (DrawBitmap);
    FSSetOutlDrawFunc (DrawOutline);
    FSSetOutl3DDrawFunc (DrawOutline3D);

    x = 20.0;	y = info.maxExtent;
    FSDrawString (window, font, string, x, y, &x, &y);

    showcursor (window);
    flushbuffer (window);

    Wait_for_events (DELETE_EVENT, &tmp);

    FSDeleteFont (font);

    Exit_tools ();

DONE:
    FSExit ();
}


void DrawBitmap (window, x, y, width, height, bitmap, bx, by, charInfo)
int		window;
int		x, y;
int		width, height;
BmapBitmap	*bitmap;
double		bx, by;
BmapCharInfo	*charInfo;
{
    int	xi, yi;

    xi = (int) (bx + 0.5);
    yi = (int) (by + 0.5);
    flipblock (window, xi - 1, yi - 1, xi + 1, yi + 1);

    if ((width > 0) && (height > 0))
    {
	drawbitmap (window, 0xFFFF, x, y, x + width - 1, y + height - 1,
		    bitmap);

	xi += charInfo->hOff;
	yi -= charInfo->vOff + charInfo->rHgt;
	flipblock (window, xi, yi, xi + charInfo->rWid - 1,
			yi + charInfo->rHgt - 1);
    }
}


void DrawOutline (window, x, y, vert, pSize, nPolys, charInfo)
int		window;
Real64		x, y;
OutlVertex	*vert;
OutlPolySize	*pSize;
int		nPolys;
OutlCharInfo	*charInfo;
{
    int		j, k, count;
    int		xi, yi;
    Real64	xr, yr;

    xi = (int) (x + 0.5);
    yi = (int) (y + 0.5);
    flipblock (window, xi - 1, yi - 1, xi + 1, yi + 1);

    for (j = 0; j < nPolys; j++)
    {
	move (window, (int) (x + vert->x), (int) (y - vert->y));
	vert++;
	count = *pSize++;
	for (k = 1; k < count; k++, vert++)
	    draw (window, (int) (x + vert->x), (int) (y - vert->y));
    }

    xr = x + charInfo->xMin;
    yr = y - charInfo->yMax;
    flipblock (window, (int) (xr + 0.5), (int) (yr + 0.5),
		(int) (xr + charInfo->xMax - charInfo->xMin + 0.5) - 1,
		(int) (yr + charInfo->yMax - charInfo->yMin + 0.5) - 1);
}


void DrawOutline3D (window, x, y, vert, pSize, nPolys, charInfo)
int		window;
Real64		x, y;
Outl3DVertex	*vert;
OutlPolySize	*pSize;
int		nPolys;
OutlCharInfo	*charInfo;
{
    int		j, k, count;
    int		xi, yi;
    Real64	xr, yr;

    xi = (int) (x + 0.5);
    yi = (int) (y + 0.5);
    flipblock (window, xi - 1, yi - 1, xi + 1, yi + 1);

    for (j = 0; j < nPolys; j++)
    {
	move (window, (int) (x + vert->x), (int) (y - vert->y));
	vert++;
	count = *pSize++;
	for (k = 1; k < count; k++, vert++)
	    draw (window, (int) (x + vert->x), (int) (y - vert->y));
    }

    xr = x + charInfo->xMin;
    yr = y - charInfo->yMax;
    flipblock (window, (int) (xr + 0.5), (int) (yr + 0.5),
		(int) (xr + charInfo->xMax - charInfo->xMin + 0.5) - 1,
		(int) (yr + charInfo->yMax - charInfo->yMin + 0.5) - 1);
}
