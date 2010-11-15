/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							rishshtb.h
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					3/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/

#ifdef HASHTAB_GLOBAL_DEFINE
# define HASHTAB_EXTERN
#else
# define HASHTAB_EXTERN extern
#endif

/*
**	INCLUDES
*/

/*
**	DEFINES
*/
#define HASH_TAB_SIZE 1201

/*
**	TYPES
*/
typedef struct hashnode
{
	unsigned short	tok;		/* token code */
	void			*ptr;		/* data pointer, actually one of the following:
									ristab, risschema, risdb */
	unsigned int	hash_time;
	struct hashnode *next;
	struct hashnode *prev;
} hashnode;

/*
**	VARIABLES
*/
HASHTAB_EXTERN struct hashnode	*RIS_hashtab[HASH_TAB_SIZE];
