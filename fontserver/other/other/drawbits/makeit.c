#include <stdio.h>
#include "symfile.h"

main (argc, argv)
int argc;
char *argv[];
{
	FILE *f;
	int i, j, size, rowbytes;
	struct fixed_hdr hdr;
	struct char_hdr chdr;
	char *bitmaps;
	
	if ((f = fopen (argv[1], "r")) == NULL)
	{
		printf ("File not found!\n");
		exit (-1);
	}
	
	fread (&hdr, sizeof (struct fixed_hdr), 1, f);
	fread (&chdr, sizeof (struct char_hdr), 1, f);
	
	size = hdr.fixed.ROPsize - 8;
	bitmaps = (char *) malloc (size);
	fread (bitmaps, size, 1, f);
	
	printf ("size: %d bytes\n", size);
	printf ("rwidth: %d   rheight: %d\n", chdr.rasterwidth,
		chdr.rasterheight);
	rowbytes = (chdr.rasterwidth + 7) / 8;
	
	for (i = 0; i < chdr.rasterheight; i++)
	{
		for (j = 0; j < rowbytes; j++)
		{
			if (j != 0)
				printf (", ");
				
			printf ("%d", bitmaps[i * rowbytes + j]);
		}
		printf (",\n");
	}
}
