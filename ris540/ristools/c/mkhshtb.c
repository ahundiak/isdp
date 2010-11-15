/* Do not alter this line: $Revision: 1.1.54.1 $ */
/*
**	NAME:							mkhshtb.c
**	AUTHORS:						David Michal
**	CREATION DATE:					4/88
**	ABSTRACT:
**		This routine builds the hash table which contains the keywords
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#if defined(WIN32) || defined(DOS)
#include <stdlib.h>
#endif
#if defined(sco)
#include <prototypes.h>
#endif

/*
**	DEFINES
*/
#define STR_SIZE 21
#define BUCKET_SIZE 2
#define INPUT_SIZE 255
#define TABLE_SIZE 512

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/

/*
**	VARIABLES
*/
char table[TABLE_SIZE][BUCKET_SIZE][STR_SIZE];
char strs[INPUT_SIZE][STR_SIZE];

/*
**	FUNCTIONS
*/

/******************************************************************************/

int hash(
	char	*s,
	int		table_size,
	int		alpha)
{
	char * p;
	unsigned h = 0;

	/*
	** compute hash value
	*/

	for (p=s;*p;p++)
	{
		h = h * alpha + tolower(*p);
	}
	return(h % table_size);
}

/******************************************************************************/

void print_lower_case_string(
	char *s)
{
	while (*s)
	{
		putchar(tolower(*s));
		s++;
	}
}

/******************************************************************************/

void print_upper_case_string(
	char *s)
{
	while (*s)
	{
		putchar(toupper(*s));
		s++;
	}
}

/******************************************************************************/

void print_hash_table(
	int		table_size)
{
	int i,j;

	for (i=0;i < table_size;i++)
	{
		printf("\t{");
		for (j=0;j < BUCKET_SIZE;j++)
		{
			if (table[i][j][0] == '\0')
			{
				printf("{0,0}");
			}
			else
			{
				printf("{\"");
				print_lower_case_string(table[i][j]);
				printf("\",RIS_TOK_");
				print_upper_case_string(table[i][j]);
				printf("}");
			}
			if (j < BUCKET_SIZE-1)
			{
				printf(",");
			}
		}
		printf("}");
		if (i < table_size-1)
		{
			printf(",");
		}
		printf("\n");
	}
}

/******************************************************************************/

int main(
	int argc,
	char *argv[])
{
	int table_size = TABLE_SIZE;
	int alpha = 11;
	int print_flag = 0;
	int i,j,k = 0;
	char * str;
	int num_strs;
	int val;

	for(i=1;i < argc;i++)
	{
		if (argv[i][0] == '-' && isalpha(argv[i][1]) && argv[i][2] == '\0')
		{
			switch(argv[i][1])
			{
				case 't':
					table_size = atoi(argv[++i]);
				break;
				case 'a':
					alpha = atoi(argv[++i]);
				break;
				case 'p':
					print_flag = 1;
				break;
				default:
					fprintf(stderr,
					 "Usage mkhash [-a alpha] [-t tab size] [-p]\n");
					return(1);
			}
		}
		else
		{
			fprintf(stderr,"Usage mkhash [-a alpha] [-t tab size] [-p]\n");
			return(1);
		}
	}
	if (table_size <= 0 || table_size > TABLE_SIZE)
	{
		fprintf(stderr,"invalid table size\n");
		return(1);
	}
	for(i=0;i < INPUT_SIZE && scanf("%s",strs[i]) != EOF;i++);
	if (i == INPUT_SIZE)
	{
		fprintf(stderr,"too many input strings\n");
		return(1);
	}
	num_strs = i;
	if (print_flag)
	{
		i = table_size;
	}
	for(;i <= table_size;i++)
	{
		for(j=0;j < i;j++)
		{
			for (k=0;k < BUCKET_SIZE;k++)
			{
				table[j][k][0] = '\0';
			}
		}
		for(j=0;j < num_strs;j++)
		{
			str = strs[j];

#ifdef DEBUG
printf("str = %s\n",str);
#endif

			val = hash(str,i,alpha);

#ifdef DEBUG
printf("val = %d\n",val);
#endif

			for (k=0;k < BUCKET_SIZE && table[val][k][0] != '\0' && 
			 strcmp(str,table[val][k]) != 0;k++);
			if (k < BUCKET_SIZE && table[val][k][0] == '\0')
			{

#ifdef DEBUG
printf("putting str into hash table at %d %d\n",val,k);
#endif

				memcpy(table[val][k],str,STR_SIZE);
			}
			else if (k >= BUCKET_SIZE)
			{

#ifdef DEBUG
printf("failure for hash tabe size = %d\n",i);
#endif

				break;
			}
			else
			{

#ifdef DEBUG
printf("str already in hash table at %d %d\n",val,k);
#endif

			}
		}
		if (k < BUCKET_SIZE)
		{
			fprintf(stderr,"Successful hash table alpha:%d table size:%d\n",
				alpha, i);
			if (print_flag)
			{
				print_hash_table(i);
			}
			return(0);
		}
	}
	if (print_flag)
		fprintf(stderr,"Collisions found for alpha:%d and table size:%d\n",
			alpha, table_size);
	else
		fprintf(stderr,"Collisions found for alpha:%d table sizes:%d to %d\n",
			alpha, num_strs, table_size);
	return(1);
}

/******************************************************************************/
