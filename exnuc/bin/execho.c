/*
*	Used to replace the DOS echo command to allow a formatted
*	printing.  Supports the following escape sequences:
*
*			\\n	newline
*			\\c	suppress terminating newline
*			\\t	tab
*
*	The use of double backslash is to avoid confusion with DOS filenames.
*/
#include <stdio.h>
#include <string.h>

#define MAXBUFLEN	4096

main (int argc, char *argv[])
{
	if (argc > 1)
	{
		int	i;
		char	buf[MAXBUFLEN];
		int	cur = 0;
		int	noNewline = 0;
		
		for (i = 1; i < argc; ++i)
		{
			/*
			*	scan for escape sequences.
			*/
			size_t	j;
			size_t	len;

			len = strlen(argv[i]);
			for (j = 0; j < len; ++j)
			{
				if (argv[i][j] == '"')
					continue;
				noNewline = 0;
				if (argv[i][j] == '\\' && argv[i][j+1] == '\\')
				{
					if (argv[i][j+2] == 'n')
						buf[cur++] = '\n';
					else if (argv[i][j+2] == 't')
						buf[cur++] = '\t';
					else if (argv[i][j+2] == 'c')
						noNewline = 1;
					else
						buf[cur++] = argv[i][j+2];
					j += 2;
				}
				else
					buf[cur++] = argv[i][j];
			}
		}
		if (!noNewline)
			buf[cur++] = '\n';
		buf[cur] = 0;
		printf(buf);
	}
	else
		printf("\n");
	return 0;
}
