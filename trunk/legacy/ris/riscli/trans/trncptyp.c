/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							TRNcomp_type.c
**	AUTHORS:						David Michal
**	CREATION DATE:					5/88
**	ABSTRACT:
**		This file contains the routine that compares types.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscl_sr.h"
#include "ristypes.h"
#include "trans.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trncptyp_c
#include "comjmp.prt"
#include "comdebug.prt"
#include "trncptyp.prt"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern int RIStrn_compare_types(
	int type1,
	int type2,
	int targ_type,
	int	pos)
{
	int type3;

	TRN_DBG(("RIStrn_compare_types(type1:%s type2:%s targ_type:%s pos:%d)\n",
		RIS_types[ATTR_TYPE(type1)].string, RIS_types[ATTR_TYPE(type2)].string,
		RIS_types[ATTR_TYPE(targ_type)].string, pos));

	type3 = -1;

	switch(ATTR_TYPE(type1))
	{
		case RIS_UNKNOWN_TYPE:
			switch(ATTR_TYPE(type2))
			{
				case RIS_SMALLINT:
				case RIS_INTEGER:
				case RIS_REAL:
				case RIS_DOUBLE:
					if (targ_type == RIS_UNKNOWN_TYPE)
					{
						type3 = RIStrn_compare_types(type2,
							RIStrn_pos_targ_type, 0, pos);
					}
					else
					{
						type3 = RIStrn_compare_types(type2, targ_type, 0, pos);
					}
				break;
				case RIS_CHARACTER:
				case RIS_DECIMAL:
				case RIS_DATETIME:
					if (targ_type == RIS_UNKNOWN_TYPE)
					{
						type3 = ATTR_TYPE(type2);
					}
					else
					{
						type3 = RIStrn_compare_types(type2, targ_type, 0, pos);
					}
				break;

				case RIS_UNKNOWN_TYPE:
					TRN_ERR_RETURN(RIS_E_INV_PARAMETER_OPERANDS, pos);
			}
		break;
		case RIS_SMALLINT:
			switch(ATTR_TYPE(type2))
			{
				case RIS_SMALLINT:
					type3 = RIS_SMALLINT;
				break;
				case RIS_INTEGER:
					type3 = RIS_INTEGER;
				break;
				case RIS_REAL:
					type3 = RIS_REAL;
				break;
				case RIS_DOUBLE:
					type3 = RIS_DOUBLE;
				break;
				case RIS_DECIMAL:
					type3 = RIS_DECIMAL;
					break;
				case RIS_UNKNOWN_TYPE:
					if (targ_type == RIS_UNKNOWN_TYPE)
					{
						type3 = RIStrn_compare_types(type1,
							RIStrn_pos_targ_type, 0, pos);
					}
					else
					{
						type3 = RIStrn_compare_types(type1, targ_type, 0, 
							pos);
					}
				break;
			}
		break;
		case RIS_INTEGER:
			switch(ATTR_TYPE(type2))
			{
				case RIS_SMALLINT:
				case RIS_INTEGER:
					type3 = RIS_INTEGER;
				break;
				case RIS_REAL:
					type3 = RIS_REAL;
				break;
				case RIS_DOUBLE:
					type3 = RIS_DOUBLE;
				break;
				case RIS_DECIMAL:
					type3 = RIS_DECIMAL;
					break;
				case RIS_UNKNOWN_TYPE:
					if (targ_type == RIS_UNKNOWN_TYPE)
					{
						type3 = RIStrn_compare_types(type1,
							RIStrn_pos_targ_type, 0, pos);
					}
					else
					{
						type3 = RIStrn_compare_types(type1, targ_type, 0, pos);
					}
				break;
			}
		break;
		case RIS_REAL:
			switch(ATTR_TYPE(type2))
			{
				case RIS_SMALLINT:
				case RIS_INTEGER:
				case RIS_REAL:
					type3 = RIS_REAL;
				break;
				case RIS_DOUBLE:
					type3 = RIS_DOUBLE;
				break;
				case RIS_DECIMAL:
					type3 = RIS_REAL;
					break;
				case RIS_UNKNOWN_TYPE:
					if (targ_type == RIS_UNKNOWN_TYPE)
					{
						type3 =
							RIStrn_compare_types(type1, RIStrn_pos_targ_type,
								0, pos);
					}
					else
					{
						type3 = RIStrn_compare_types(type1, targ_type, 0, pos);
					}
				break;
			}
		break;
		case RIS_DOUBLE:
			switch(ATTR_TYPE(type2))
			{
				case RIS_SMALLINT:
				case RIS_INTEGER:
				case RIS_REAL:
				case RIS_DOUBLE:
					type3 = RIS_DOUBLE;
				break;
				case RIS_DECIMAL:
					type3 = RIS_DOUBLE;
					break;
				case RIS_UNKNOWN_TYPE:
					if (targ_type == RIS_UNKNOWN_TYPE)
					{
						type3 = RIStrn_compare_types(type1,
							RIStrn_pos_targ_type, 0, pos);
					}
					else
					{
						type3 = RIStrn_compare_types(type1, targ_type, 0, pos);
					}
				break;
			}
		break;
		case RIS_CHARACTER:
			switch(ATTR_TYPE(type2))
			{
				case RIS_CHARACTER:
					type3 = RIS_CHARACTER;
				break;
				case RIS_UNKNOWN_TYPE:
					if (targ_type == RIS_UNKNOWN_TYPE)
					{
						type3 = RIS_CHARACTER;
					}
					else
					{
						type3 = RIStrn_compare_types(type1, targ_type, 0, pos);
					}
				break;
			}
		break;
		case RIS_DECIMAL:
			switch(ATTR_TYPE(type2))
			{
				case RIS_SMALLINT:
				case RIS_INTEGER:
					type3 = RIS_DECIMAL;
					break;
				case RIS_REAL:
					type3 = RIS_REAL;
					break;
				case RIS_DOUBLE:
					type3 = RIS_DOUBLE;
					break;
				case RIS_DECIMAL:
					type3 = RIS_DECIMAL;
					break;
				case RIS_CHARACTER:
				break;
				case RIS_UNKNOWN_TYPE:
					if (targ_type == RIS_UNKNOWN_TYPE)
					{
						type3 = RIS_DECIMAL;
					}
					else
					{
						type3 = RIStrn_compare_types(type1, targ_type, 0, pos);
					}
				break;
			}
		break;
		case RIS_DATETIME:
			switch(ATTR_TYPE(type2))
			{
				case RIS_DATETIME:
					type3 = RIS_DATETIME;
					break;

				case RIS_UNKNOWN_TYPE:
					if (targ_type == RIS_UNKNOWN_TYPE)
					{
						type3 = RIS_DATETIME;
					}
					else
					{
						type3 = RIStrn_compare_types(type1, targ_type, 0, pos);
					}
				break;
			}
			break;

        case RIS_BLOB:
            switch(ATTR_TYPE(type2))
            {
                case RIS_CHARACTER:
                    type3 = RIS_BLOB;
                break;
                case RIS_BLOB:
                    type3 = RIS_BLOB;
                break;
                case RIS_UNKNOWN_TYPE:
                    if (targ_type == RIS_UNKNOWN_TYPE)
                    {
                        type3 = RIS_BLOB;
                    }
                    else
                    {
                        type3 = RIStrn_compare_types(type1, targ_type, 0, pos);
                    }
                break;
            }
        break;
        case RIS_TEXT:
            switch(ATTR_TYPE(type2))
            {
                case RIS_CHARACTER:
                    type3 = RIS_TEXT;
                break;
                case RIS_TEXT:
                    type3 = RIS_TEXT;
                break;
                case RIS_UNKNOWN_TYPE:
                    if (targ_type == RIS_UNKNOWN_TYPE)
                    {
                        type3 = RIS_TEXT;
                    }
                    else
                    {
                        type3 = RIStrn_compare_types(type1, targ_type, 0, pos);
                    }
                break;
            }
        break;
		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,0);
			break;
	}

	if (type3 == -1)
	{
		TRN_ERR_RETURN(RIS_E_INCOMPATIBLE_TYPES, pos);
	}

	if (NULLS_ALLOWED(type1) || NULLS_ALLOWED(type2))
	{
		ALLOW_NULLS(type3);
	}

	TRN_DBG(("RIStrn_compare_type: returning %s\n",
		RIS_types[ATTR_TYPE(type3)].string));
	return(type3);
}
