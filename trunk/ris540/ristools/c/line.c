/* Do not alter this line: $Revision: 1.1.54.1 $ */
#include <stdio.h>

#define EXE	"line"

extern int atoi();

static void Usage()
{
	fprintf(stderr, "Usage: %s [n]\n");
}

extern void main(
	int argc,
	char *argv[])
{
	int n = 1;
	char s[512];

	switch(argc)
	{
		case 1:
			break;

		case 2:
			n = atoi(argv[1]);
			break;

		default:
			Usage();
			return;
	}

	for (; n>0; n--)
	{
		if (fgets(s, 512, stdin) == NULL) break;
		fputs(s, stdout);
	}
}
