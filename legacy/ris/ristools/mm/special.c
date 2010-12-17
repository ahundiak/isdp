/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							special.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include "mm.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/
typedef struct special_s
{
	char *data;
	struct special_s *next;
} special_s;

/*
**	FUNCTION PROTOTYPES
*/
#define special_c
#include "output.prt"
#include "special.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
special_s *pre = NULL;
special_s **prep = &pre;
special_s *post = NULL;
special_s **postp = &post;

/*
**	FUNCTIONS
*/

extern void add_pre_special(
	char	*data)
{
	(*prep) = MALLOC(special_s);
	(*prep)->data = malloc(strlen(data) + 1);
	strcpy((*prep)->data, data);
	(*prep)->next = NULL;
	prep = &(*prep)->next;
}

extern void add_post_special(
	char	*data)
{
	(*postp) = MALLOC(special_s);
	(*postp)->data = malloc(strlen(data) + 1);
	strcpy((*postp)->data, data);
	(*postp)->next = NULL;
	postp = &(*postp)->next;
}

extern void write_pre_special()
{
	output("\n");
	while(pre)
	{
		output("%s", pre->data);
		pre = pre->next;
	}
}

extern void write_post_special()
{
	output("\n");
	while(post)
	{
		output("%s", post->data);
		post = post->next;
	}
}
