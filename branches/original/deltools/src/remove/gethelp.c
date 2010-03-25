#include	<stdlib.h>
#include <stdio.h>
#include <string.h>

#define	LINELENG	128

int	main(argc, argv)
int	argc;
char	**argv;
{
	register int	state;
	register int	tpos;
	char	line[LINELENG];
	char	*c, *b;
	FILE	*f, *out = stderr;

	if (argc < 3) {
		fprintf(stderr, "Usage: %s text_database entry_point\n",
			argv[0]);
		exit(1);
	}

	if ((f = fopen(argv[1], "r")) == NULL) {
		fprintf(stderr, "Cannot open help text database for read.\n");
		exit(2);
	}

	/*
	if ((out = fopen("/tmp/help.txt", "w")) == NULL) {
		fprintf(stderr, "Cannot open help text output file for write.\n");
		exit(2);
	}
	*/

	state = 0;	/* not found */
	while (fgets(line, LINELENG, f) != NULL) {
		if (line[0] == '#')
			continue;
		if (line[0] != '>' || line[1] != '>') {
			if (state)
				fputs(line, out);
			continue;
		} else if (state)
			break;

		if ((b = strpbrk(line, " \t\n")))
			*b = '\0';
		if (strcmp(&line[2], argv[2]))
			continue;
		state++;

		tpos = strspn(++b, " \t");
		b += tpos;
		c = strrchr(b, '\n');
		*c = '\0';
		printf("title=Help on \\\"%s\\\"\n", b);
	}

	if (!state) {
		printf("title=Help\n");
		fprintf(out, "Help for %s not available at this time.", argv[2]);
	}
	fclose(out);
	fclose(f);

}
