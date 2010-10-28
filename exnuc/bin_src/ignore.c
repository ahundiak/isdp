#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lib.h"

struct dtree_node	*get_ignore_list(name)
char			*name;
{
	FILE			*stream;
	char			line[4096];
	int			lineno = 1;
	struct dtree_node	*ret = 0;

	if (!(stream = fopen(name, "r")))
	{
		fprintf(stderr, "mkmk: get_ignore_list: %s: no such file\n", name);
		exit(1);
	}
	while (fgets(line, 4096, stream))
	{
		char			*newline;
		struct dtree_node	*p, *new_dtree_node();

		if (newline = (char *)strrchr(line, '\n'))
			*newline = 0;
		else
		{
			fprintf(stderr, "mkmk: get_ignore_list: %s, %d: line too long\n", name, lineno);
			exit(1);
		}
		p = new_dtree_node(line);
		p->next = ret;
		ret = p;
		++lineno;
	}
	fclose(stream);
	return ret;
}
