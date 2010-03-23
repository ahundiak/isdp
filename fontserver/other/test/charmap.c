#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>

char *string = "The quick brown fox jumps over the lazy dog. 0123456789 !@#$%^&*()[]{}<>";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			24.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			NULL,		/* assigned later */
			FS_DEMAND	/* flags	*/
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    CharMapId cmId;
    char *cmFile;
    BmapInfo info;
    int vs, tmp, window;
    double x, y, atof ();

    cmFile = "ascii";
    if (argc > 1)
	cmFile = argv[1];

    FSEnter (0);

    FSReadCharMapFile (cmFile, &cmId);
    fontSpec.charMap = (char *) cmId;

    if (FSNewFont (&fontSpec, NULL, &font) != FS_NO_ERROR)
    {
	printf ("Can't create font!\n");
	goto DONE;
    }

    if (FSGetBmapInfo (font, &info) != FS_NO_ERROR)
	FSGetOutlInfo (font, &info);

    FSDeleteCharMap (cmId);

    FSReadCharMapFile (cmFile, &cmId);	/* just checking */
    FSDeleteCharMap (cmId);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    Inq_displayed_vs (&vs);
    Create_win (vs, "A font", 20, 30, 1020, 820, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);

    hidecursor (window);

    x = 500.0;	y = 400.0 + info.maxExtent;
    FSDrawString (window, font, string, x, y, &x, &y);

    showcursor (window);
    flushbuffer (window);

    Wait_for_events (DELETE_EVENT, &tmp);

    FSDeleteFont (font);

    Exit_tools ();

DONE:
    FSExit ();
}
