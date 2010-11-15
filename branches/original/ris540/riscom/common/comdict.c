/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
------------------------------------------------------------------------

Name:								comdict.c
Author:								Dan Karier
Creation Date:						08/91
Abstract:

	There are some dictionary routines and structures that have to
	be available to the client and the server.  Rather than
	having duplicate (and possibly out-of-sync/out-of-date) information
	in two places, I'm trying to consolidate it in one place.

	This file contains dictionary-related functions used by the client.

	The actual dictionary definitions are in internal/risdict.h,
	and there are a lot of general dictionary routines in 
	dd/DDSdict.c.


Revision History:
		
	Add RIScom_test_dict_tabid(tabid) 
		which returns true if tabid is a dict tabid, by Jin Jing 01/94
	add RIScom_is_v4_dict_tabid(tabid) 
		which returns true if tabid is a v4 dict table id, by Jin Jing 02/94
	add RIScom_is_v5_dict_tabid(tabid) 
		which returns true if tabid is a v5 dict table id, by Jin Jing 04/94

------------------------------------------------------------------------
*/

#include "risdebug.h"
#include "risdict.h"


#define comdict_c
#include "comdict.prt"
#include "comdebug.prt"

/******************************************************************************/
	/*
	**	This routine is a quick search mechanism.  Given a table name
	**	(null-terminated string in lowercase), this routine returns
	**	the number of the dictionary table (index into RIS tables structure),
	**	which can then be used to get appropriate information.
	**
	**  The routine returns:
	**
	**		table number (the index into RIScom_dict_tables) if found;
	**		-1 if not found;
	**
	**  A free coke to anyone who can find a faster search mechanism 
	**		for the dictionary tables.   dank
	*/

extern int RIScom_get_dict_tabid(
	char * target)
{
	int index  = 0;
	int character = 0;

COM_DBG(("RIScom_get_dict_tabid target:%s\n", target));

		/*
		** Since this is a bottom-up search, if we ever encounter a
		** "less than" mismatch, we know we have failed.
		*/ 

	while(1)
	{
		if (*target < RIScom_dict_tables[index].name[character])
			return (-1);
	
		else if (*target == RIScom_dict_tables[index].name[character])
		{
				/*
				** If they are equal and null, then we have found a match ...
				*/
	
			if (!*target)
				return index;
	
				/*
				** ... otherwise we loop back to check the next character
				*/
			else
			{
				++character;
				++target;
				continue;
			}
		}
		else		/* *target > current character */
		{
				/*
				**  Take advantage of what we know --
				**     Instead of resetting the character offset to zero,
				**     we can reset it to the minimum of where we are now
				**     and the number of characters that are identical in
				**     this string and the next.
				*/
		
				if (character >  RIScom_dict_tables[index].compression)
					character = RIScom_dict_tables[index].compression;
				++index;
					/*
					** make sure we do not go beyond the end of the list
					*/
				if (! RIScom_dict_tables[index].name[0] )
					return (-1);
		}
	}
}


#ifdef TEST
char *test[] = {
"riscolumn_privs",	
"riscolumns",			
"ris_columns",			
"risdbs",				
"risindex_columns",	
"ris_index_columns",	
"risindexes",			
"ris_indexes",			
"ris_privs",			
"ris_schemaid",		
"risschemas",			
"ris_schusr",			
"ristable_privs",		
"ristables",			
"ris_tables",			
"risview_strings"	,
"ris_view_strings"	,
"bad",
"RISVIEWS",
"risjunk",
"",
"ristypes",			
"risstrings",			
"risdbsnonono",
"riscolumn_privileges",
"BOOGA",
"riszero",
"riSbananas",
"ri"
};

main()
{
	int i;

	for (i=0; i< sizeof(test)/sizeof(char *); ++i)
		printf("%d: <%s>\n",RIScom_get_dict_tabid(test[i]), test[i]);
}
#endif /* test */

/******************************************************************************/
/*
extern int RIScom_test_dict_tabid(
	int		tabid)
{
	int     dict_tab_cnt;

	dict_tab_cnt = sizeof(RIScom_dict_tables[])/sizeof(struct dict_tabdef);

	if (tabid >= 0 && tabid < dict_tab_cnt)
	{
		return (1);
	}
	else
	{
		return (0);
	}
}
*/
/******************************************************************************/

extern int RIScom_is_v4_dict_tabid(
	int		tabid)
{
	if(tabid != -1 && RIScom_dict_tables[tabid].version == 4)
	{
		return(1);
	}
	else
	{
		return(0);
	}
}

/******************************************************************************/

extern int RIScom_is_v5_dict_tabid(
	int		tabid)
{
	if(tabid != -1 && RIScom_dict_tables[tabid].version == 5)
	{
		return(1);
	}
	else
	{
		return(0);
	}
}

/******************************************************************************/
