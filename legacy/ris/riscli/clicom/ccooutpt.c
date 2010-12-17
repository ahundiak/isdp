/*
**	NAME:							ccooutpt.c
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					11/92
**	ABSTRACT:
**		Generic output routines.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "riscl_pa.h"
#include "riscom.h"
#include "risdebug.h"
#include "risinsql.h"
#include "ristoken.h"
#include "ristypes.h"
#include "ris.h"

/*
**	DEFINES
*/
#define MAX_INDENT_SIZE	11
#define LOAD_INDENT_STRING(indent, s) \
{ \
	int i = indent < MAX_INDENT_SIZE ? indent : MAX_INDENT_SIZE; \
	memset(s, '\t', i); \
	s[i] = '\0'; \
}

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ccooutpt_c
#include "ccooutpt.prt"
#include "comoutpt.prt"
#include "comdebug.prt"
#include "comgtnme.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScco_output_internal_sqlvar(
	int		(* output_func)(const char *, ...),
	internal_sqlvar	*var,
	int		indent)
{
	char indent_str[MAX_INDENT_SIZE];

	if (var)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%ssqltype:%s  sqllen:%d",
			indent_str, RIS_types[var->sqltype].string, var->sqllen);
		if (var->sqltype == RIS_DECIMAL)
			output_func("  sqlscale = %d", var->sqlscale);
		output_func("  sqlnull = %d\n", var->sqlnull);

		output_func("%ssqlnamel:%d sqlnamec:<%*s>\n",
			indent_str,  var->sqlname.sqlnamel, var->sqlname.sqlnamel,
			(*var->sqlname.sqlnamec) ? var->sqlname.sqlnamec : "");
		output_func("%ssqldata:0x%x sqlind:0x%x\n",
			indent_str, var->sqldata, var->sqlind);
		output_func("%sdbsqltype:%d  dbsqllen:%d\n", 
			indent_str, var->dbsqltype, var->dbsqllen);
	}
}

/******************************************************************************/

static void output_internal_tree(
	int		(* output_func)(const char *, ...),
	void	*ptr,
	int		indent,
	char	side)
{
	char		indent_str[MAX_INDENT_SIZE];
	risaccess	*acc;
	ristree		*tp = ptr;

	if (!tp) return;

	if (tp->tok == RIS_TOK_LIST)
	{
		output_internal_tree(output_func, tp->lhs,indent,'l');
		output_internal_tree(output_func, tp->rhs,indent,'r');
	}
	else
	{
		LOAD_INDENT_STRING(indent, indent_str);
		if (indent)
		{
			output_func("%d%c%s", indent, side, indent_str);
		}

		if (RIStree_debug) output_func("tp:0x%x  ", tp);
		output_func("tok:%s  ", RIScom_get_token_name(tp->tok));
		output_func("pos:%d  ", tp->pos);
		switch(tp->tok)
		{
			case RIS_TOK_GRANT:
			case RIS_TOK_REVOKE:
				output_func("\n");
				for (acc = tp->info.access; acc; acc = acc->next)
				{
					output_func("%saccess:", indent_str);
					if (RIStree_debug)
						output_func("0x%x\n", acc);
					else
						output_func("\n");
					RIScom_output_acc(output_func, acc, indent + 1);
				}
				break;

			case RIS_TOK_CREATE_SCHEMA:
			case RIS_TOK_DROP_SCHEMA:
				output_func("\n%sschema:", indent_str);
				if (RIStree_debug)
					output_func("0x%x\n", tp->info.schema);
				else
					output_func("\n");
				if (tp->info.schema)
				{
					RIScom_output_schema(output_func, tp->info.schema,
						indent + 1);

					output_func("%s\tdb:", indent_str);
					if (RIStree_debug)
						output_func("0x%x\n", tp->info.schema->db);
					else
						output_func("\n");
					RIScom_output_db(output_func, tp->info.schema->db,
						indent + 2);
				}
				break;
			
			case RIS_TOK_TABLE:
				output_func("\n%stable:", indent_str);
				if (RIStree_debug)
					output_func("0x%x\n", tp->info.tab);
				else
					output_func("\n");
				RIScom_output_table(output_func, tp->info.tab, indent + 1);
				if (RIStree_debug)
				{
					for (acc = tp->info.tab->acc; acc; acc = acc->next)
					{
						output_func("%s\taccess:0x%x\n", indent_str, acc);
						RIScom_output_acc(output_func, acc, indent + 2);
					}
				}
				break;

			case RIS_TOK_ATTR:
				output_func("\n%sattr:", indent_str);
				if (RIStree_debug)
					output_func("0x%x\n", tp->info.attr);
				else
					output_func("\n");
				RIScom_output_attr(output_func, tp->info.attr, indent + 1);
				if (RIStree_debug && tp->info.attr)
				{
					for (acc = tp->info.attr->acc; acc; acc = acc->next)
					{
						output_func("%s\taccess:0x%x\n", indent_str, acc);
						RIScom_output_acc(output_func, acc, indent + 2);
					}
				}
				break;

			case RIS_TOK_PARAMETER:
				output_func("\n%ssqlvar:", indent_str);
				if (RIStree_debug)
				{
					output_func("0x%x\n", tp->info.data);
				}
				else
				{
					output_func("\n");
				}
				RIScco_output_internal_sqlvar (output_func, tp->info.data,
					indent + 1);
				break;

			case RIS_TOK_PLUS:
			case RIS_TOK_SUB:
			case RIS_TOK_MUL:
			case RIS_TOK_DIV:
			case RIS_TOK_UNARYMINUS:
			case RIS_TOK_COUNT:
			case RIS_TOK_AVG:
			case RIS_TOK_SUM:
			case RIS_TOK_MAX:
			case RIS_TOK_MIN:
				output_func("\n%sattr:", indent_str);
				if (RIStree_debug)
					output_func("0x%x\n", tp->info.attr);
				else
					output_func("\n");
				RIScom_output_attr(output_func, tp->info.attr, indent + 1);
				if (RIStree_debug && tp->info.attr)
				{
					for (acc = tp->info.attr->acc; acc; acc = acc->next)
					{
						output_func("%s\taccess:0x%x\n", indent_str, acc);
						RIScom_output_acc(output_func, acc, indent + 2);
					}
				}
				break;

			case RIS_TOK_TIMESTAMP_LIT:
				if (tp->info.val)
				{
					output_func("val: ");
					if (isprint(*tp->info.val)) /*itbokic 3/30 */
						output_func(tp->info.val);
					else
						RIScom_output_datetime(output_func,
							(dtime *)tp->info.val);
				}
				output_func("\n");
				break;

			default:
				if (tp->info.val)
					output_func("val: %s\n",tp->info.val);
				else
					output_func("\n");
				break;
		}

		if (tp->tok != RIS_TOK_TABLE || RIStree_debug)
		{
			output_internal_tree(output_func, tp->lhs, indent + 1, 'l');
			output_internal_tree(output_func, tp->rhs, indent + 1, 'r');
		}
	}
}

/******************************************************************************/

extern void RIScco_output_internal_tree(
	int		(* output_func)(const char *, ...),
	void	*ptr)
{
	ristree	*tp = ptr;

	output_func("\n");
	output_internal_tree(output_func, tp, 0, 'h');
}

/******************************************************************************/

extern void RIScco_output_internal_data(
	int		(* output_func)(const char *, ...),
	int		count,
	internal_sqlvar	*var,
	char	*data,
	int		indent)
{
	int		i;
	int		sqllen  = 0;
	int		sqltype = 0;
	int		indicator = 0;
	char	indent_str[MAX_INDENT_SIZE];

	LOAD_INDENT_STRING(indent, indent_str);

	RIS_ALIGN(sizeof(double),data);

	for (i = 0; i < count; ++i)
	{
		sqltype = (int)var[i].sqltype;
		sqllen  = (int)var[i].sqllen;

		/*
		** We must always align data based on its data type.
		** Since the 'integer' indicator gets aligned here, the only
		** other data type that needs alignment will be the 'double'.
		*/
		RIS_ALIGN(sizeof(int),data);

		indicator = *(int *)data;
		output_func("%scol %d: indicator:%d data:", indent_str, i, indicator);

		/*
		** properly increment the pointer
		*/
		data += sizeof(int);
		if (indicator < 0)
		{
			output_func("NULL\n");
			/*
			** When the data type is a RIS_DOUBLE we need to 
			** align the pointer -data- so that it is properly 
			** data for adding the sqllen at the end of
			** the loop.
			*/
			if (sqltype == RIS_DOUBLE)
			{
				RIS_ALIGN(sizeof(double),data);
			}
		}
		else
		{
			switch (sqltype)
			{
				case RIS_CHARACTER:
					output_func("CHARACTER:<%s>\n", data);
					break;

				case RIS_DECIMAL:
					output_func("DECIMAL:<%s>\n", data);
					break;

				case RIS_DATETIME:
					RIScom_output_datetime(output_func, (dtime *)data);
					output_func("\n");
					break;

				case RIS_DOUBLE:
					RIS_ALIGN(sizeof(double),data);
					output_func("DOUBLE:%f\n", *(double *)data);
					break;

				case RIS_INTEGER:
					output_func("INTEGER:%d\n", *(int *)data);
					break;

				case RIS_REAL:
					output_func("REAL:%f\n", *(float *)data);
					break;

				case RIS_SMALLINT:
					output_func("SMALLINT:%d\n", *(short *)data);
					break;

                case RIS_BLOB:
                case RIS_TEXT:
                    RIScom_output_blob(output_func, (ris_blob *)data);
                    break;

				default:
					output_func("UNKNOWN DATA TYPE:%d", sqltype);
					break;
			}
		}

		/*
		** properly increment the pointer
		** we have some special rules here...
		*/
		if (sqltype == RIS_DECIMAL && sqllen < RIS_types[RIS_DOUBLE].sqllen)
		{
			/*
			**  INGRES always needs room for a RIS_DOUBLE so do it here for
			**  all databases.
			*/
			data += RIS_types[RIS_DOUBLE].sqllen;
		} else if (sqltype == RIS_BLOB  || sqltype == RIS_TEXT)
        {
            data += sizeof(ris_blob);
		} else
		{
			data += sqllen;
		}
		if (sqltype == RIS_CHARACTER)
		{
			data++;
		}
		else if (sqltype == RIS_DECIMAL)
		{
			data++;
		}
	}
}

