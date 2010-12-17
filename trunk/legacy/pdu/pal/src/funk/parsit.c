#include <stdio.h>

#define	HASHSIZE	128
#define DEBUG           0

struct part_struct {
	char part_name[128];
	struct part_struct *next;
};

static  struct part_struct *hashtab [HASHSIZE] ;


int hash( s )
char	*s;
{
	int hashval;

	for( hashval=0; *s != '\0';  )
		hashval = *s++ ;

	return ( hashval % HASHSIZE );
}



struct	part_struct  *_lookup( s )
char	*s;
{
	struct part_struct  *np;

	for( np = hashtab[hash(s)]; np != NULL; np = np->next )
	{
		if( strcmp( s, np->part_name ) == 0 )
			return ( np ) ;		 /* Name found */
	}
	return ( NULL );
}




struct	part_struct  *install( name )
char	*name;
{
	int  hashval;
	struct part_struct  *np;

        if( name[0] == '\0' ) return(NULL );

	if(( np = _lookup( name )) == NULL )  /* Name not found */
	{
		np = (struct part_struct *) calloc( 1, sizeof(struct part_struct) );
		if( np == NULL )
		{
			fprintf(stderr,"Error in Calloc: size=%d\n",
					sizeof(struct part_struct) );
			return ( NULL );
		}
		hashval = hash( name );
		np->next = hashtab[hashval];
		hashtab[hashval] = np;
		strcpy( np->part_name, name );
		return ( np );
	}
	else	/* Name already there	*/
		return ( NULL );
}



free_ptrs()
{
	int	ii;
	struct part_struct  *cur_ptr, *next_ptr;

	for(ii=0;ii<HASHSIZE; ii=ii+1 )
	{
		cur_ptr = hashtab[ii];

		while( cur_ptr != NULL )
		{
			next_ptr = cur_ptr->next;
			free( cur_ptr );
			cur_ptr = next_ptr;
		}
		hashtab[ii] = NULL;
	}
}


parse_all_expr ( nexp, exparry, nfld, arry )
char *exparry[], *arry[];
int  *nfld, nexp;
{
	int  i,  j;
	char  *malloc();
	*nfld = 0;

	for ( i=0; i<nexp; i++ )
	{
if ( DEBUG )
                printf("in parse: exp: %s %d\n", exparry[i], strlen( exparry[i]));

		parse_expr ( exparry[i], nfld, arry );
                if( DEBUG )
		for (j=0; j<*nfld; j++)
			printf ("arry[%d] = %s\n", j, arry[j]);
	}
}



parse_expr ( exp_str, nfld, arry )
char  *exp_str, *arry[];
int   *nfld;
{
	int  i;
	char *token, *parsetok(), *malloc();;

        if( strcmp(exp_str,"0") == 0 ) return ;

	token = parsetok(exp_str);
        if( DEBUG ) printf("token : %s\n", token );
	i = *nfld;
	while ( token )
	{
		if ( strcmp (token, "****") )
		{
			arry[i] = malloc ( (unsigned)(strlen(token) + 1 ));
			strcpy (arry[i], token);
			i++;
		}
		token = parsetok(NULL);
                if( DEBUG )
                    printf("token : %s\n", token );
	}
	if ( i )
		*nfld = i;
}



char  *parsetok(s1)
char   *s1;
{
	int    i, j, k;
	char   *ret;
	struct part_struct *tok_ptr, *install();

	static  char *ops = "+-*/&!<>@#,";
	static  int  curp=0;
	static  char s[1024];
	
	if(s1 != NULL)		/* first time; so 's' is built */
	{
		for(i=0, j=0; *(s1+i) != '\0'; i++)
			if ( *(s1+i) != ' ' && *(s1+i) != '\n' )
			{
				*(s+j) = *(s1+i);
				j++;
			}
                if ( DEBUG )
          		printf ("expression: %s %d\n", s1,s, strlen(s));
		curp = 0;
                *( s + j ) = '\0' ;
	}

	if(*(s+curp) == '\0')
		return(NULL);  /* end of parsing */

	for(j=curp; *(s+j) != '\0'; j++)
	{
		for (k= 0; *(ops+k) != '\0'; k++)
			if ( *(s+j) == *(ops+k) )
			{	*(s+j) = '\0';
				ret = s+curp;
				curp = j+1;
				tok_ptr = install ( ret );
				if ( tok_ptr == NULL )
				{
                                        if( DEBUG )
						printf("name already in list\n");
					return ( "****" );
				}
				else
					return(ret);
			}
	}
	ret = s+curp;
	curp = j;
	tok_ptr = install ( ret );
	if ( tok_ptr == NULL )
	{
                if ( DEBUG )
			printf("name already in list\n");
		return ( "****" );
	}
	else
		return(ret);
}




/*
main (argc, argv)
char *argv[];
int  argc;
{
	int  nfld, i;
	static	char *exp_str[] = { "agdd + fsgaf < vasd - pasd & gaga",
				    "agdd / gasd ! fafa > jhfjsd * dada"
				  };
	char *arry[10], *ptr, *gets();
	parse_all_expr ( 2, exp_str, &nfld, arry );
	free_ptrs();
}
*/


