/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							tests.c
**	AUTHORS:						
**	CREATION DATE:					
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include "tpg.h"

/*
**	FUNCTION PROTOTYPES
*/
#define tests_c
#include "tests.prt"
#include "write.prt"
#include "sys.prt"


/*
**	DEFINES
*/
#define NO_NULL_RULE		0
#define CONTAINS_NULL_RULE	1

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

extern int first_list_cmp(
	data_s	*list1,
	data_s	*list2)
{
	data_s	*l1;
	data_s	*l2;

	for (l1 = list1; l1; l1 = l1->next)
	{
		for (l2 = list2; l2; l2 = l2->next)
		{
			if (strcmp(l1->name, l2->name) == 0)
			{
				return 0;
			}
		}
	}
	return 1;
}

extern int get_first(
	data_s	*data_in,
	data_s	**listp)
{
	int		sts;
	data_s	*first, *temp;
	rule_s	*rule;
	prod_s	*prod;

	/*
	**	Returns CONTAINS_NULL_RULE if listp contains a null rule.
	**	Otherwise returns NO_NULL_RULE.
	*/

	/*
	**	Check for null rule
	*/
	if (data_in == NULL)
	{
		MALLOC(temp, data_s);
		temp->next = (*listp);
		(*listp) = temp;
		return CONTAINS_NULL_RULE;
	}

	/*
	**	check for token
	*/
	if (ISTOKEN(data_in->name))
	{
		MALLOC(temp, data_s);
		strcpy(temp->name, data_in->name);
		temp->next = (*listp);
		(*listp) = temp;
		return NO_NULL_RULE;
	}

	/*
	**	it must be a production
	*/
	for (prod = prod_list; prod; prod = prod->next)
		if (!strcmp(prod->name, data_in->name))
			break;
	if (!prod)
	{
		fprintf(stderr,
			"ERROR: get_first(): Unable to find production <%s> in prod_list\n",
			data_in->name);
		exit(1);
	}

	sts = NO_NULL_RULE;
	for (rule = prod->rule; rule; rule = rule->next)
	{
		get_first_for_rule(rule);
		for (first = rule->first; first; first = first->next)
		{
			MALLOC(temp, data_s);

			if (first->name[0] == '\0')
				sts = CONTAINS_NULL_RULE;
			else
				strcpy(temp->name, first->name);

			temp->next = (*listp);
			(*listp) = temp;
		}
	}
	return sts;
}

extern void get_first_for_rule(
	rule_s *rule)
{
	data_s	*data;

	if (!rule->first)
	{
		if (rule->data == NULL)
		{
			MALLOC(rule->first, data_s);
		}
		else
		{
			for (data = rule->data; data; data = data->next)
			{
				if (get_first(data, &rule->first) == NO_NULL_RULE)
					break;
			}
		}
	}
}

extern int left_recursion()
{
	int		sts;
	rule_s	*rule;
	prod_s	*prod;
	
	sts = 0;
	for(prod = prod_list; prod; prod = prod->next)
	{
		for (rule = prod->rule; rule; rule = rule->next)
		{
			if (rule->data)
			{
				if (!strcmp(prod->name, rule->data->name))
				{
					if (sts == 0)
					{
						sts = 1;
						fprintf(stderr,"Productions with LEFT RECURSION\n\n");
					}
					write_prod(stderr, prod);
					fprintf(stderr,"\n");
					break;
				}
			}
		}
	}
	return sts;
}

extern int left_factor()
{
	int		ok;
	int		sts;
	rule_s	*rule1;
	rule_s	*rule2;
	prod_s	*prod;

	sts = 0;
	for(prod = prod_list; prod; prod = prod->next)
	{
		ok = 1;
		for (rule1 = prod->rule; ok && rule1; rule1 = rule1->next)
		{
			get_first_for_rule(rule1);

			for (rule2 = rule1->next; rule2; rule2 = rule2->next)
			{
				get_first_for_rule(rule2);
				if (!first_list_cmp(rule1->first, rule2->first))
				{
					if (sts == 0)
					{
						sts = 1;
						fprintf(stderr,
							"Productions that need LEFT FACTORING\n\n");
					}
					write_prod(stderr, prod);
					fprintf(stderr,"Offending rules:\n");
					write_data_list(stderr, rule1->data);
					fprintf(stderr,"FIRST->");
					write_data_list(stderr, rule1->first);
					write_data_list(stderr, rule2->data);
					fprintf(stderr,"FIRST->");
					write_data_list(stderr, rule2->first);
					fprintf(stderr,"\n");
					ok = 0;
					break;
				}
			}
		}
	}
	return sts;
}

extern void set_prod_used(
	char *name,
	char secondary_call)
{
	prod_s *prod;
	
	for (prod = prod_list; prod; prod = prod->next)
		if (!strcmp(prod->name, name))
			break;
	if (!prod)
	{
		fprintf(stderr, "set_prod_used(): Unable to find production <%s>\n",
			name);
		exit(1);
	}
	prod->used = 1;
	prod->secondary_call |= secondary_call;
}

extern void unused_prods()
{
	int		sts;
	prod_s	*prod;
	rule_s	*rule;
	data_s	*data;


	prod_list->used = 1;
	prod_list->secondary_call = 1;

	sts = 0;
	for (prod = prod_list; prod; prod = prod->next)
	{
		for (rule = prod->rule; rule; rule = rule->next)
		{
			for (data = rule->data; data; data = data->next)
			{
				if (data && !ISTOKEN(data->name))
				{
					set_prod_used(data->name,(char)(data == rule->data ? 0 : 1));
				}
			}
		}
	}

	for (prod = prod_list; prod; prod = prod->next)
	{
		if (!prod->used)
		{
			if (sts == 0)
			{
				fprintf(stderr,"Productions that are UNUSED\n\n");
				sts = 1;
			}
			write_prod(stderr, prod);
		}
	}
}

