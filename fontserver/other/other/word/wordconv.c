#include <stdio.h>

#define SPACE		' '
#define NL		'\n'
#define CR		'\r'

main (argc, argv)
int argc;
char *argv[];
{
	FILE *infile, *outfile;
	char ch, word[1000];
	int wsize, lsize, maxline;
	
	if (argc < 3)
	{
		printf ("Usage:  wordconv infile outfile [chars/line]\n");
		exit (0);
	}
	
	maxline = 79;
	if (argc > 3)
		maxline = atoi (argv[3]);

	if ((infile = fopen (argv[1], "r")) == NULL)
	{
		fprintf (stderr, "Cannot open %s!\n", argv[1]);
		exit (-1);
	}

	if ((outfile = fopen (argv[2], "w")) == NULL)
	{
		fprintf (stderr, "Cannot open %s!\n", argv[2]);
		exit (-1);
	}

	lsize = wsize = 0;
	while (!feof (infile))
	{
		word[wsize++] = ch = fgetc (infile);
		
		if (ch == SPACE)
		{
			if (lsize != 0)
			{
				fputc (SPACE, outfile);
				lsize++;
			}
			fwrite (word, 1, wsize - 1, outfile);
			lsize += wsize - 1;
			wsize = 0;

			if (lsize == maxline)
				goto NEWLINE;
		}
		else if (ch == CR)
		{
			if (lsize != 0)
				fputc (SPACE, outfile);

			fwrite (word, 1, wsize - 1, outfile);
			fputc (NL, outfile);
NEWLINE:		fputc (NL, outfile);
			lsize = wsize = 0;
		}
		else if (lsize + wsize == maxline)
		{
			if (lsize == 0)
			{
				fwrite (word, 1, wsize, outfile);
				fputc (NL, outfile);
				wsize = 0;
			}
			else if (ch == SPACE)
			{
				fputc (SPACE, outfile);
				fwrite (word, 1, wsize - 1, outfile);
				wsize = 0;
			}
			else
			{
				fputc (NL, outfile);
			}

			lsize = 0;
		}
	}
	fwrite (word, 1, wsize, outfile);
	fputc (NL, outfile);

	fclose (infile);
	fclose (outfile);
}
