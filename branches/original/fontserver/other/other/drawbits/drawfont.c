#include <tools.h>

#define BX 56
#define BY 56
#define NX 10
#define NY 10
#define ICONFILE "icon"


main (argc, argv)
int argc;
char *argv[];
{
	int vs, wno, x, y, n, font, ch;
	
	Enter_tools ();
	
	Load_symbol_file (ICONFILE, &font);
	
	Inq_displayed_vs (&vs);
	Create_win (vs, "Bitmaps!", 30, 30, BX * NX + 30, BY * NY + 30, &wno);
	Display_win (wno);

	ch = 0;
	for (n = 0; n < atoi (argv[1]); n++)
	{
		fgcolor (wno, 0);
		rectf (wno, 0, 0, BX * NX - 1, BY * NY - 1);
		fgcolor (wno, -1);

		for (y = 0; y < NY; y++)
		{
			for (x = 0; x < NX; x++)
			{
				drawsymbols (wno, font, x * BX, y * BY, &ch, 1);
			}
		}
	}
	Exit_tools ();
}
