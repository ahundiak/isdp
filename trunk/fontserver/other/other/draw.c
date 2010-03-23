/* This program draws the characters from an Environv V font.		*/


#include <tools.h>
#include <stdio.h>

int height, maxWidth, baseline, font, nChars;


RefreshWin (window)
int window;
{
    int i, j, x, y, x1, y1, x2, y2;
    char s[256];

    hidecursor (window);

    Inq_win_region (window, &x1, &y1, &x2, &y2);
    fgcolor (window, 0);
    rectf (window, 0, 0, x2 - x1, y2 - y1);
    fgcolor (window, -1);

    x = 10;
    y = 10;
    for (i = 0; i < 256; i += nChars)
    {
	for (j = 0; j < nChars; j++)
	    s[j] = i + j;

	drawsymbols (window, font, x, y, s, nChars);
	y += height;
    }
    y += height + height;
    sprintf (s, "Height: %d\n", height);
    drawsymbols (window, font, x, y, s, strlen (s));

    showcursor (window);
    flushbuffer (window);
}



main (argc, argv)
int argc;
char *argv[];
{
    int window, event, vs, i, eventMask;

    if (argc < 2)
    {
	printf ("Usage:  draw {font file} [chars/line]\n");
	exit (1);
    }

    nChars = 16;
    if (argc > 2)
	nChars = atoi (argv[2]);
    if (nChars <= 0)
	nChars = 16;

    eventMask = DELETE_EVENT | REFRESH_EVENT | COLLAPSE_EVENT;

    Enter_tools();
    Set_logo("A Font");
    Enable_events(eventMask);

    if (Load_symbol_file (argv[1], &font))
    {
	printf ("Invalid symbol file.\n");
	exit (1);
    }

    Inq_font (font, &height, &maxWidth, &baseline);

    Inq_displayed_vs (&vs);
    Create_win (vs, "Font Window", 20, 100, 600, 700, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);
    RefreshWin (window);

    for (;;)
    {
	Wait_for_events (eventMask, &event);

	if (event & DELETE_EVENT)
	    break;

	if (event & REFRESH_EVENT)
	{
	    int	aWindow, x1, y1, x2, y2, rx1, ry1, rx2, ry2, opMask;

	    Get_refresh_area (&aWindow, &vs, &x1, &y1, &x2, &y2,
				&rx1, &ry1, &rx2, &ry2, &opMask);
	    clipbox (window, rx1, ry1, rx2, ry2);
	    RefreshWin(window);
	}

	if (event & COLLAPSE_EVENT)
	{
	    int	flag, aWindow;

	    Get_collapse_data (&aWindow, &flag);
	    if (!flag)
		RefreshWin (window);
	}
    }

    Exit_tools();
}
