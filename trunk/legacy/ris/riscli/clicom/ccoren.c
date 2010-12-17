/*
**	NAME:							ccoren.c
**	AUTHORS:						Jin Jing		
**	CREATION DATE:					12/93
**	ABSTRACT:
**		This routine will generate external object (table, view, or index)
**		names or external column names from internal ones.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "riscli.h"
#include "risdebug.h"
#include "rislimit.h"
#include "risstjmp.h"
#include "riscl_pa.h"
#include "ris_err.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ccoren_c
#include "ccoren.prt"
#include "comdebug.prt"
#include "comstrng.prt"
#include "comjmp.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

char ran_hash()
{
	char	ret = '0';
	int 	val = 0;

	val = rand();
	val = val % 36;

	if (val < 10)
	{
		ret = 48 + val;
	}
	else
	{
		ret = 55 + val;
	}
	return ret;
}

/******************************************************************************/

char str_hash(
	char *name)
{
	int 	i, len;
	char	ret = '0';
	int 	val = 0;

	len = strlen(name);
	switch(len)
	{
		case 0:
			ret = '0';
			break;
		case 1:
			ret = *name;
			break;
		default:
			for (i=0 ; i < len; i++)
			{
				val += name[i];
			}
			val = val % 36;

			if (val < 10)
			{
				ret = 48 + val;
			}
			else
			{
				ret = 55 + val;
			}
	}
	return ret;
}

/******************************************************************************/

void generate_hash_name(
	char 	*name,
	int		hash_size)
{
	int		i, div, len;
	/*char	str[RIS_MAX_ID_SIZE];*/

	len = strlen(name);
	div = len / hash_size;
	
	for (i = 0; i < hash_size; i++)
	{
		/*strcpy(str, &name[i*div]);
		if (i < hash_size - 1)
		{
			str[div] = '\0';
		}
		name[i] = str_hash(str);*/
		name[i] = ran_hash();
	} 
	name[hash_size] = '\0';
}

/******************************************************************************/

int column_name_collision(
	risattr	*attr,
	char *extern_name)
{
	risattr	*attrp;
	
	for (attrp = attr; attrp; attrp = attrp->next)
	{
		if (!strcmp(extern_name, attrp->extern_attrname))
		{
			return(1);
		}
	}
	return (0);
}

/******************************************************************************/

void next_extern_name(
	char *extern_name,
	int	  size)
{
	int	i;
	
	for (i = 0; i < RIS_EXTERN_HASH_SIZE; i++)
	{
		if (extern_name[size-(i+1)] > 89 || 
			extern_name[size-(i+1)] < 48)
		{
			extern_name[size-(i+1)] = 48;
		}
		else if (extern_name[size-(i+1)] > 56 && 
			extern_name[size-(i+1)] < 65)
		{
			extern_name[size-(i+1)] = 65;
			break;
		}
		else
		{
			extern_name[size-(i+1)] += 1;
			break;
		}
	}
	extern_name[size] = '\0';
}

/******************************************************************************/

extern void RIScco_extern_column_names(
	risschema	*schema,
	risattr		*attr)
{
	risattr	*attrp;
	char	extern_name[RIS_MAX_ID_SIZE];
	
	CCO_DBG(("RIScco_extern_column_names(attr: 0x%x)\n", attr));

	for (attrp = attr; attrp; attrp = attrp->next)
	{
		if (schema->db->dtype == '4')
		{
			strcpy(extern_name, attrp->attrname);
			RIScom_uppercase(strlen(extern_name), (unsigned char *)extern_name);
			if (strlen(extern_name) > RIS_MAX_OS400_ID_SIZE)
			{
				if (RIS_autorename_mode)
				{
					extern_name[RIS_MAX_OS400_ID_SIZE] = '\0';
				}
				else
				{
					LONGJMP(RIS_E_COL_NAME_TOO_LONG);
				}	
			}
			
			while (column_name_collision(attr,extern_name))
			{
				next_extern_name(extern_name, RIS_MAX_OS400_ID_SIZE);
			}
			strcpy(attrp->extern_attrname, extern_name);
		}
		else
		{
			strcpy(attrp->extern_attrname, attrp->attrname);
		}
	}
	CCO_DBG(("RIScco_extern_column_names: returning\n"));
}

/******************************************************************************/

extern void RIScco_extern_table_name(
	char	*intern_name,
	char	*extern_name)
{
	CCO_DBG(("RIScco_extern_tab_name(intern_name:<%s> extern_name:<%s>)\n", 
		intern_name, extern_name));

	strcpy(extern_name, intern_name);
	RIScom_uppercase(strlen(extern_name), (unsigned char *)extern_name);
	if (strlen(extern_name) > RIS_MAX_OS400_ID_SIZE)
	{
		if (RIS_autorename_mode)
		{
			/* generating ext name by hashing */
			/*generate_hash_name(
				&extern_name[RIS_MAX_OS400_ID_SIZE-RIS_EXTERN_HASH_SIZE], 
				RIS_EXTERN_HASH_SIZE);*/
			/* generating ext name by truncating */
			extern_name[RIS_MAX_OS400_ID_SIZE] = '\0';
		}
		else
		{
			LONGJMP(RIS_E_TAB_NAME_TOO_LONG);
		}
	}

	CCO_DBG(("RIScco_extern_tab_name: returning <%s>\n", extern_name));
}

/******************************************************************************/

extern void RIScco_next_extern_table_name(
	char	*intern_name,
	char	*extern_name)
{
	CCO_DBG(("RIScco_next_extern_table_name(intern_name:<%s>extern_name:<%s>)\n", 
		intern_name, extern_name));

	strcpy(extern_name, intern_name);
	RIScom_uppercase(strlen(extern_name), (unsigned char *)extern_name);
	if (strlen(extern_name) > RIS_MAX_OS400_ID_SIZE)
	{
		if (RIS_autorename_mode)
		{
			generate_hash_name(
				&extern_name[RIS_MAX_OS400_ID_SIZE-RIS_EXTERN_HASH_SIZE], 
				RIS_EXTERN_HASH_SIZE);
			/* truncate the name */
			extern_name[RIS_MAX_OS400_ID_SIZE] = '\0';
		}
		else
		{
			LONGJMP(RIS_E_TAB_NAME_TOO_LONG);
		}
	}

	CCO_DBG(("RIScco_next_extern_table_name: returning <%s>\n", extern_name));
}

/******************************************************************************/
