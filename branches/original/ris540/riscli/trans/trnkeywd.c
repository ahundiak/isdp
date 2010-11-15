/* Do not alter this SPC information: $Revision: 1.2.33.1 $ */
/*
**	NAME:							trnkeywd.c
**	AUTHORS:						Sarah Byram
**	CREATION DATE:					10/91
**	ABSTRACT:
**		This file contains the routines to search known keywords and build
**				message strings.
**	
**	REVISION HISTORY:
**		10/24/94 -Radha
**			Added changes to MSSQL data server.
*/
 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "riscom.h"
#include "rismem.h"
#include "trans.h"
#include "keyword.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trnkeywd_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "trnkeywd.prt"
#include "sys.prt"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/
struct Key_Error *KeyTop = (struct Key_Error *) 0;
char message[MAX_MSG_SIZE];   /* use this until we have a message array */


/*
**	FUNCTIONS
*/

/******************************************************************************/

/*
*		This function looks up a value in the keywords array using a binary
*			search.  If found, pass back the index into the array else a -1
*/
extern int RIStrn_lookup_keyword(
	char *value)
{

	int lower = 0;
	int mid, upper, test;


TRN_DBG(("\nRIStrn_lookup_keyword %s\n",value));

	/*
	 *   Binary Search for keyword
	*/

	upper = key_count-1;

	while ( lower <= upper )
	{

		mid = ( lower + upper ) / 2;
		
		test = strcmp ( keywords[mid].keyword, value );

		if ( test < 0 )
			lower = mid + 1;
		else if ( test > 0 )
			upper = mid -1;
		else
			return ( mid );

	}

	return ( -1 );

}

/*
*   This function builds a tree of erronous keywords.  The dbms_mask is set
*	according to the databases that the keyword is illegal.  This mask allows
*	us to build a list of keywords for this database mask.  For example:
*		"...Keyword(s) 'all', 'alter', 'any' reserved by DB2, Informix, Ingres, 
*		Oracle database(s).  Keyword(s) 'ascending', 'ascii' reserved by
*		Informix database(s)...
*
*	Parameters:
*		value - pointer to keyword 
*		new_tree - is set to true when checking first keyword in a statement.
*					When true we know to reinitialize KeyTop ( which is the
*					top of the binary bad-keyword tree ).  This has to be
*					done because when ALLOC space is freed, the pointers to
*					the space are not nulled.
*/
extern  void RIStrn_check_keyword ( 
	char *value,
	int *new_tree
)
{
	int key_index;

	if ( *new_tree )
	{
		KeyTop = (struct Key_Error *) 0;
		*new_tree = 0;
	}

TRN_DBG(("\nRIStrn_check_keyword %s in database 0x%x\n",value, RIS_enable_dbms));

	key_index = RIStrn_lookup_keyword ( (char *) value );
	if ( key_index >= 0 )
	{
		/* 
	 	** If keyword reserved by database specified in mode,
		** add to Key_Error tree
		*/
		if ( RIS_enable_dbms & keywords[key_index].dbms )
		{
			RIStrn_add_to_tree ( key_index );
		}
	}
	return;
}
/*
*	This function builds the dbms mask and searches the tree for a match.  If 
*		it finds the dbms mask it adds the keyword to the char string.  If it 
*		doesn't find the dbms mask, it adds a new node to the tree
*/
extern void RIStrn_add_to_tree ( 
	int key_index
)
{
	unsigned int keyword_dbms;
	struct Key_Error *parent, *child;

TRN_DBG(("\nRIStrn_add_to_tree 0x%x keyword %s\n", KeyTop, 
				keywords[key_index].keyword));

	/*
	 *  parent will trail child through the tree
	*/
	parent = (struct Key_Error *) 0;
	child = KeyTop;

	while ( child != (struct Key_Error *)0 )
	{
		keyword_dbms = keywords[key_index].dbms & RIS_enable_dbms;
		/*
		*  search left subtree
		*/
		if ( keyword_dbms < child->dbms )
		{
			parent = child;
			child = child->left;
		}
		else if ( keyword_dbms == child->dbms )
		{
			if ( strlen( child->keywords ) + 
					strlen( keywords[key_index].keyword ) + 4 > MAX_MSG_SIZE )
			{
				/*
				* no more room for error message, return
				*/
				return;
			}
			
			sprintf ( child->keywords, "%s, '%s'", child->keywords, 
						keywords[key_index].keyword );
			return;
		}
		/*
		* search right subtree
		*/
		else /* ( keyword_dbms > child->dbms ) */
		{
			parent = child;
			child = child->right;
		}
	}

	/*
	*  This database mask is not in tree.  Add as a child of parent
	*/
	child = ALLOCT(struct Key_Error);
		
	strcpy( child->keywords, "'");
	strncat( child->keywords, keywords[key_index].keyword, MAX_MSG_SIZE-2 ); /*itbokic */
	strcat( child->keywords, "'" );

	child->dbms = keywords[key_index].dbms & RIS_enable_dbms;

	/*
	*  insert into empty tree
	*/
	if ( KeyTop == (struct Key_Error * )0 )
	{
		KeyTop = child;
	}
	else if ( keywords[key_index].dbms < parent->dbms )
	{
		parent->left = child;
	}
	else
	{
		parent->right = child;
	}
	return;
}
/*
*	This function checks existence of error tree and initiates the traversal.
*/
extern int RIStrn_get_keyword_message (
)
{
	struct Key_Error *tree;


TRN_DBG(("\nRIStrn_get_keyword_message from 0x%x tree\n", KeyTop));

	if ( KeyTop != (struct Key_Error *) 0 )
	{
		tree = KeyTop;
		message[0] = '\0';
		RIStrn_traverse_tree ( tree );
		strcpy(RIS_ERRMSGC, message);
		KeyTop = (struct Key_Error *) 0;
		return (1);		
	}
	return (0);
}

/*
*	This function traverse the 'reserved keyword tree' ( Key_Error )
*		tree.
*/
extern void RIStrn_traverse_tree ( 
	struct Key_Error *tree
)
{
	if ( tree != (struct Key_Error *) 0 )
	{
		RIStrn_traverse_tree ( tree->left );
		RIStrn_build_message ( tree );
		RIStrn_traverse_tree ( tree->right );

	} /* endif */
	return;
}

/*
*	This function builds the error msg in global 'message' array from the 
*		list of keywords in the Key_Error tree.
*/
extern void RIStrn_build_message ( 
	struct Key_Error *tree
)
{

	int sqlca_len, len;

	static char kprompt[] = {"  Keyword(s) "};
	static char rprompt[] = {" reserved by "};
	static char dprompt [] = {" database(s)."};

	static char db2[] = { "DB2" };
	static char informix[] = { "Informix" };
	static char ingres[] = { "Ingres" };
	static char oracle[] = { "ORACLE" };
	static char rdb[] = { "Rdb" };
	static char sybase[] = { "Sybase" };
	static char mssql[] = { "MSSQL" };
	static char sqlds[] = { "SQL/DS" };
	static char adabas[] = { "ADABAS" };
	static char os400[] = { "OS400" };

	static int kpr_len = sizeof ( kprompt );
	static int rpr_len = sizeof ( rprompt );
	static int dpr_len = sizeof ( dprompt );


	char db_list[MAX_MSG_SIZE];


	/*
	*  build error message
	*/
	sqlca_len = strlen ( message );

	/*
	*  see if there is room for message
	*/
	if ( sqlca_len + kpr_len > MAX_MSG_SIZE )
	{
		strncat ( message, kprompt, MAX_MSG_SIZE - (sqlca_len + kpr_len) ); /*itbokic */
		message[MAX_MSG_SIZE-4] = message[MAX_MSG_SIZE-3] = message[MAX_MSG_SIZE-2] = '.';
		message[MAX_MSG_SIZE-1] = '\0';
		tree = (struct Key_Error *) 0;
		return;
	}
	strcat ( message, kprompt );
	sqlca_len += kpr_len;

	len = strlen ( tree->keywords );

	/*
	*  see if there is room for more message
	*/
	if ( sqlca_len + len > MAX_MSG_SIZE )
	{
		strncat ( message, tree->keywords, MAX_MSG_SIZE - (sqlca_len + len) ); /*itbokic */
		message[MAX_MSG_SIZE-4] = message[MAX_MSG_SIZE-3] = message[MAX_MSG_SIZE-2] = '.';
		message[MAX_MSG_SIZE-1] = '\0';
		tree = (struct Key_Error *) 0;
		return;
	}
	strcat ( message, tree->keywords );
	sqlca_len += len;


	/*
	*  see if there is room for more message
	*/
	if ( sqlca_len + rpr_len > MAX_MSG_SIZE )
	{
		strncat ( message, rprompt, MAX_MSG_SIZE - (sqlca_len + rpr_len) ); /*itbokic */
		message[MAX_MSG_SIZE-4] = message[MAX_MSG_SIZE-3] = message[MAX_MSG_SIZE-2] = '.';
		message[MAX_MSG_SIZE-1] = '\0';
		tree = (struct Key_Error *) 0;
		return;
	}
	strcat ( message, rprompt );
	sqlca_len += rpr_len;


	db_list[0] = '\0';

	if ( tree->dbms & (unsigned int ) D )
		sprintf ( db_list, "%s%s, ", db_list, db2 );
	if ( tree->dbms & (unsigned int ) X )
		sprintf ( db_list, "%s%s, ", db_list, informix );
	if ( tree->dbms & (unsigned int ) I )
		sprintf ( db_list, "%s%s, ", db_list, ingres );
	if ( tree->dbms & (unsigned int ) O )
		sprintf ( db_list, "%s%s, ", db_list, oracle );
	if ( tree->dbms & (unsigned int ) R )
		sprintf ( db_list, "%s%s, ", db_list, rdb );
	if ( tree->dbms & (unsigned int ) Y )
		sprintf ( db_list, "%s%s, ", db_list, sybase );
	if ( tree->dbms & (unsigned int ) M )
		sprintf ( db_list, "%s%s, ", db_list, mssql );
	if ( tree->dbms & (unsigned int ) S )
		sprintf ( db_list, "%s%s, ", db_list, sqlds );
	if ( tree->dbms & (unsigned int ) A )
		sprintf ( db_list, "%s%s, ", db_list, adabas );
	if ( tree->dbms & (unsigned int ) _4 )
		sprintf ( db_list, "%s%s, ", db_list, os400 );

	len = strlen ( db_list );
	/*
	*  take off last comma
	*/
	if ( len )
	{
		len -= 2;
		db_list[len] = '\0';
	}

	/*
	*  see if there is room for more message
	*/
	if ( sqlca_len + len > MAX_MSG_SIZE )
	{
		strncat ( message, db_list, MAX_MSG_SIZE - (sqlca_len + len) ); /*itbokic */
		message[MAX_MSG_SIZE-4] = message[MAX_MSG_SIZE-3] = message[MAX_MSG_SIZE-2] = '.';
		message[MAX_MSG_SIZE-1] = '\0';
		tree = (struct Key_Error *) 0;
		return;
	}
	strcat ( message, db_list );
	sqlca_len += len;

	/*
	*  see if there is room for more message
	*/
	if ( sqlca_len + dpr_len > MAX_MSG_SIZE )
	{
		strncat ( message, dprompt, MAX_MSG_SIZE - (sqlca_len + dpr_len) ); /*itbokic */
		message[MAX_MSG_SIZE-4] = message[MAX_MSG_SIZE-3] = message[MAX_MSG_SIZE-2] = '.';
		message[MAX_MSG_SIZE-1] = '\0';
		tree = (struct Key_Error *) 0;
		return;
	}
	strcat ( message, dprompt );
	return;
}
