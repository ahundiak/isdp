#include <tools.h>
#include <stdio.h>
#include <FS.h>
#include <FSOutl.h>


int MsgDrawFunc ();
int MsgSizeFunc ();
OutlInfo info;

FontSpec fontSpec = { "/usr/fs/test/kanji", 24.0, 1.0, 1.0, 0.0, 0.0, "all",
			FS_OUTLINE | FS_3D | FS_DEMAND | FS_NO_KERN };

short buffer0[] = { 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,
			20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,
			37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,
			54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,
			71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,
			88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,
			104,105,106,107,108,109,2000,2001,2002,2003,2004,0 };
short buffer1[] = { 'C','e','n','t','e','r',' ','m','e','s','s','a','g','e',0 };
short buffer2[] = { 'R','i','g','h','t',' ','m','e','s','s','a','g','e',0 };
short *buffer[] = { buffer0, buffer1, buffer2 };
int bufferLen[] = {	sizeof (buffer0) / sizeof(short),
			sizeof (buffer1) / sizeof(short),
			sizeof (buffer2) / sizeof(short) };


RefreshWin (window, x1, y1, x2, y2)
int window;
int x1, y1, x2, y2;
{
    int i, j, color;

    hidecursor (window);
    clipbox (window, x1, y1, x2, y2);

    fgcolor (window, 0);
    rectf (window, x1, y1, x2, y2);

    for (i = 500, j = 300, color = 1; i > 0;
	 i -= 50, j -= 30, color = (color + 1) % 16)
    {
	fgcolor (window, color);
	rectf (window, i/10, j/10, i, j);
    }

    showcursor (window);
    flushbuffer (window);
}



main (argc, argv)
int argc;
char *argv[];
{
    int vs, window, event, opMask, height;
    int x1, y1, x2, y2, rx1, ry1, rx2, ry2;
    int count, mbNum, i, rval, menu;
    FontId msgFont;
    long font;
    static long eventMask = DELETE_EVENT | REFRESH_EVENT | MENUBAR_EVENT;
    static int red[4] = {4, 8, 12, 0}, green[4] = {5, 9, 13, 1},
	       blue[4] = {6, 10, 14, 2};
    static char *pdFont = "/usr/ip32/resrc/bsfont/swiss742.18";
    static int numEntries = 3;
    static int scrSize = 0;
    static char *entry[3] = {"Left", "Center", "Right"};
    static int command[3] = {1, 2, 3};
    static int link[3] = {0, 0, 0};

    if (argc > 1)
	fontSpec.typeface = argv[1];

    Enter_tools ();
    Set_logo ("Fonts");
    Set_message_mode (4);

    Create_quick_pd (red, green, blue, pdFont, numEntries, scrSize, entry,
		     command, link, &menu);

    Attach_menubar ("Message", 1);
    Update_menubar ();

    FSEnter (0);
    Inq_message_text_size (4, &height);		/* get the ms field size */
    fontSpec.bodySize = (double) height;
    if (rval = FSNewFont (&fontSpec, NULL, &font))	/* create the font */
    {
	printf ("Can't create font: %d\n", rval);
	goto DONE;
    }
    msgFont = (FontId) font;			/* just to be safe */

    FSGetOutlInfo (msgFont, &info);		/* need this info later */
    Set_message_font (4, (long) msgFont, 1);	/* set the font */
    Set_message_draw_func (MsgDrawFunc);	/* set the draw function */
    Set_message_size_func (MsgSizeFunc);	/* set the size function */

    Inq_displayed_vs (&vs);
    Create_win (vs, "Message strip fonts", 20, 80, 520, 380, &window);
    Set_win_repaint_icon (window, 0);
    Display_win (window);
    RefreshWin (window, 0, 0, 500, 300);
    Enable_events (eventMask);

    for (;;)
    {
	Wait_for_events (eventMask, &event);

	if (event & DELETE_EVENT)
	    break;

	if (event & REFRESH_EVENT)
	{
	    Get_refresh_area_data (&window, &vs, &x1, &y1, &x2, &y2,
				   &rx1, &ry1, &rx2, &ry2, &opMask);
	    RefreshWin (window, rx1, ry1, rx2, ry2);
	}

	if (event & MENUBAR_EVENT)
	{
	    int	select, just;

	    Get_menubar_data (&mbNum, &x1, &y1);
	    Process_pd (menu, 0, x1, y1, &select);

	    if (select > 0)
	    {
		just = (select == 1) ? LEFT : (select == 2) ? CENTER : RIGHT;
		for (i = bufferLen[select - 1]; --i >= 0;)
		    Display_message (2, just, &buffer[select - 1][i]);
	    }
	}
    }

DONE:
    FSExit ();
    Exit_tools ();
}


int MsgDrawFunc (window, font, x, y, string, length)
int window;
long font;
int x, y;
char *string;
int length;
{
    /* offset the y value to the baseline instead of the top of the font */
    FSDrawText (window, (FontId) font, string, length, 
		(double) x, (double) y + info.bodySize - info.descent,
		NULL, NULL);
    return (0);
}


int MsgSizeFunc (font, string, length, h, w)
long font;
char *string;
int length;
int *h, *w;
{
    double width;

    FSGetTextVect ((FontId) font, string, length, 0.0, 0.0, &width, NULL);
    *w = (int) (width + 0.5);		/* round it */
    *h = (int) (info.bodySize + 0.5);	/* height of the font */
    return (0);
}

