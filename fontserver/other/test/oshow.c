/* This program displays the outline of a character on a grid.		*/


#include <math.h>
#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSOutl.h>

#define	WINX	1000
#define	WINY	600

#define	EVENTS	(DELETE_EVENT | REFRESH_EVENT)

char chr = 'R';

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			32.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",	/* char map	*/
			FS_NO_PLAID
		    };

struct vlt_slot	vlt[] = { {1, 32768, 32768, 41960} };

double	pixSize;

void	ShowOutline(), ShowOutline3D();

double	atof();


main (argc, argv)
int argc;
char *argv[];
{
    int		vs, window, wx1, wy1, wx2, wy2, rVal;
    FontId	font;
    RangeSpec	range[2];
    OutlInfo	info;
    long	event;

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    if (argc > 3)
	fontSpec.resFactor = atof (argv[3]);

    if (argc > 4)
	fontSpec.rotation = atof (argv[4]);

    if (argc > 5)
	chr = argv[5][0];

    if (argc > 6)
	fontSpec.flags = atoi (argv[6]);
    fontSpec.flags |= (FS_OUTLINE | FS_NO_KERN);

    FSEnter (0);

    FSSetOutlDrawFunc (ShowOutline);
    FSSetOutl3DDrawFunc (ShowOutline3D);

    range[0].start = chr;
    range[0].count = 1;
    range[1].start = (CharId) -1;

    if ((rVal = FSNewFont (&fontSpec, range, &font)) != FS_NO_ERROR)
    {
	printf ("FSNewFont error: %d\n", rVal);
	exit (1);
    }

    FSGetOutlInfo (font, &info);

    Enter_tools ();
    Enable_events (EVENTS);

    Inq_displayed_vs (&vs);
    Loadvlt (vs, vlt, sizeof (vlt) / sizeof (struct vlt_slot));
    Create_win (vs, "Outlines", 50, 50, 50 + WINX - 1, 50 + WINY - 1, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win_marq (window);

    Inq_win_region (window, &wx1, &wy1, &wx2, &wy2);
    pixSize = (wy2 - wy1 + 1) / info.bodySize;

    hidecursor (window);
    RefreshWin (window, font);
    showcursor (window);
    flushbuffer (window);

    for (;;)
    {
	Wait_for_events (EVENTS, &event);

	if (event & DELETE_EVENT)
	{
	    Get_delete_data (&window);
	    break;
	}

	if (event & REFRESH_EVENT)
	{
	    int	rx1, ry1, rx2, ry2, opMask;

	    Get_refresh_area_data (&window, &vs, &wx1, &wy1, &wx2, &wy2,
					&rx1, &ry1, &rx2, &ry2, &opMask);

	    pixSize = (wy2 - wy1 + 1) / info.bodySize;

	    clipbox (window, rx1, ry1, rx2, ry2);
	    hidecursor (window);
	    RefreshWin (window, font);
	    showcursor (window);
	    clipbox (window, 0, 0, wx2 - wx1, wy2 - wy1);
	}
    }

    Exit_tools ();
    FSExit ();
}



RefreshWin (window, font)
int	window;
FontId	font;
{
    int		wx1, wy1, wx2, wy2;
    double	x, y;
    OutlInfo	info;

    FSGetOutlInfo (font, &info);

    fgcolor (window, 0);
    Inq_win_region (window, &wx1, &wy1, &wx2, &wy2);
    rectf (window, 0, 0, wx2 - wx1, wy2 - wy1);

    fgcolor (window, 1);
    for (x = 0.0; x < (double) (wx2 - wx1 + 1); x += pixSize)
    {
	move (window, (int) (x + 0.5), 0);
	draw (window, (int) (x + 0.5), wy2 - wy1);
    }
    for (y = 0.0; y < (double) (wy2 - wy1 + 1); y += pixSize)
    {
	move (window, 0, (int) (y + 0.5));
	draw (window, wx2 - wx1, (int) (y + 0.5));
    }

    x = floor (info.bodySize * 0.05);
    y = floor (info.bodySize - info.descent + info.bodySize * 0.05);
    fgcolor (window, -1);
    FSDrawChar (window, font, chr, x, y, &x, &y);
    FSDrawChar (window, font, chr, x, y, &x, &y);
}



void ShowOutline (window, x, y, vert, pSize, nPolys)
int window;
double x, y;
OutlVertex *vert;
OutlPolySize *pSize;
int nPolys;
{
    int i, j, k, ix, iy;

    if (nPolys > 0)
    {
	ix = (int) (x * pixSize + 0.5);
	iy = (int) (y * pixSize + 0.5);
	rectf (window, ix - 2, iy - 2, ix + 2, iy + 2);

	i = 0;	/* i = vertex index */
	for (j = 0; j < nPolys; j++)	/* j = poly index */
	{
	    ix = (int) ((x + vert[i].x) * pixSize + 0.5);
	    iy = (int) ((y - vert[i].y) * pixSize + 0.5);
	    move (window, ix, iy);
	    for (k = 1; k < pSize[j]; k++)
	    {
		ix = (int) ((x + vert[i + k].x) * pixSize + 0.5);
		iy = (int) ((y - vert[i + k].y) * pixSize + 0.5);
		draw (window, ix, iy);
		rectf (window, ix - 1, iy - 1, ix + 1, iy + 1);
	    }
	    i += pSize[j];
	}
    }
}



void ShowOutline3D (window, x, y, vert, pSize, nPolys)
int window;
double x, y;
Outl3DVertex *vert;
OutlPolySize *pSize;
int nPolys;
{
    int i, j, k, ix, iy;

    if (nPolys > 0)
    {
	ix = (int) (x * pixSize + 0.5);
	iy = (int) (y * pixSize + 0.5);
	rectf (window, ix - 2, iy - 2, ix + 2, iy + 2);

	i = 0;	/* i = vertex index */
	for (j = 0; j < nPolys; j++)	/* j = poly index */
	{
	    ix = (int) ((x + vert[i].x) * pixSize + 0.5);
	    iy = (int) ((y - vert[i].y) * pixSize + 0.5);
	    move (window, ix, iy);
	    for (k = 1; k < pSize[j]; k++)
	    {
		ix = (int) ((x + vert[i + k].x) * pixSize + 0.5);
		iy = (int) ((y - vert[i + k].y) * pixSize + 0.5);
		draw (window, ix, iy);
		rectf (window, ix - 1, iy - 1, ix + 1, iy + 1);
	    }
	    i += pSize[j];
	}
    }
}
