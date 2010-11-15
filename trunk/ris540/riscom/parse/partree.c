/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							partree.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		Contains the routines that build and manipulate parse trees.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "parser.h"

/*
**	FUNCTION PROTOTYPES
*/
#define partree_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comgtnme.prt"
#include "comjmp.prt"
#include "parstack.prt"
#include "partree.prt"
#include "ristoken.h"
#include "sys.prt"


/*
**	DEFINES
*/
#define       TABLE_ROW       25
#define       TABLE_COL       25

/*
**	VARIABLES
*/
static  struct 
{
	ristree *ptr;
	int lhs_c;
	int rhs_c;
} table[TABLE_ROW][TABLE_COL];
static  int row;
static  int col;
static  int max_row;
static  int max_col;
static  int min_col;
static  int overflow = 0;

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISpar_update_tree_node(
	ristree	*tp,
	int		tok,
	lex_s	*lex)
{

	PAR_DBG(("RISpar_update_tree_node(tp:0x%x tok:%s lex:%x)\n",
		tp, RIScom_get_token_name(tok), lex));

	tp->tok = (unsigned short)tok;
	if (lex)
	{
		tp->pos = (unsigned short)lex->pos; 
		switch(tok)
		{
			case RIS_TOK_ALIAS_NAME: 
			case RIS_TOK_ALL: 
			case RIS_TOK_APPROX_NUM_LIT:
			case RIS_TOK_ARCH:
			case RIS_TOK_ASYNC_ID:
			case RIS_TOK_AUTH_ID: 
			case RIS_TOK_CHAR_STR_LIT:
			case RIS_TOK_COL_NAME: 
			case RIS_TOK_CURSOR_NAME:
			case RIS_TOK_C_CHAR_STR_LIT:
			case RIS_TOK_DBNAME:
			case RIS_TOK_DEFINENAME:
			case RIS_TOK_DESC_NAME:
			case RIS_TOK_DIR:
			case RIS_TOK_DNP:
			case RIS_TOK_ENV:
			case RIS_TOK_EXACT_NUM_LIT:
			case RIS_TOK_FEATURE:
			case RIS_TOK_FILENAME:
			case RIS_TOK_FROM:
			case RIS_TOK_GROUP:
			case RIS_TOK_HOST_IDENT:
			case RIS_TOK_HOST_LU:
			case RIS_TOK_HOST_PROGRAM:
			case RIS_TOK_IDENT:
			case RIS_TOK_IFDEFNAME:
			case RIS_TOK_IFNDEFNAME:
			case RIS_TOK_INDEX_NAME: 
			case RIS_TOK_MAJOR:
			case RIS_TOK_MODE:
			case RIS_TOK_NET_PROTOCOL:
			case RIS_TOK_NT:
			case RIS_TOK_NODE:
			case RIS_TOK_OPTION:
			case RIS_TOK_OS:
			case RIS_TOK_OSTYPE:
			case RIS_TOK_OSUSER:
			case RIS_TOK_PASSWORD: 
			case RIS_TOK_PORT:
			case RIS_TOK_RIS_LU:
			case RIS_TOK_STMT_ID:
			case RIS_TOK_TABLE_NAME: 
			case RIS_TOK_TCP:
			case RIS_TOK_TIMESTAMP_LIT:
			case RIS_TOK_TO:
			case RIS_TOK_UNDEFNAME:
			case RIS_TOK_UNION:
			case RIS_TOK_UNIX:
			case RIS_TOK_USER:
			case RIS_TOK_USR_NAME:
			case RIS_TOK_USING_DICT_OWNER:
			case RIS_TOK_VAR_NAME:
			case RIS_TOK_VMS:
			case RIS_TOK_XNS:
			case RIS_TOK_RIS_DICT_DBNAME:
				tp->info.val = lex->val;
			break;
		}
	}
}

/******************************************************************************/

extern ristree *RISpar_create_tree_node(
	int		tok,
	lex_s	*lex)
{
	ristree	*new_tp;

	PAR_DBG(("RISpar_create_tree_node(tok:%s lex:%x)\n",
		 RIScom_get_token_name(tok),lex));

	new_tp = ALLOCT(ristree);
	RISpar_update_tree_node(new_tp, tok, lex);
	return(new_tp);
}

/******************************************************************************/

/*
** This routine builds a tree. It takes the root and the number
** of leaves as arguments. The tree is built and then a ptr to the 
** tree is placed on the stack.  NULL_NODE leaves are not included.
*/

extern void RISpar_create_tree(
	int tok,
	lex_s * lex,
	int leaves)
{
	ristree * rootptr;

PAR_DBG(("\nRISpar_create_tree tok = %s lex = %x leaves = %d\n",
 RIScom_get_token_name(tok),lex,leaves));

	rootptr = RISpar_create_tree_node(tok,lex);
	switch(leaves)
	{
		case 0:
		break;
		case 1:
			rootptr->rhs = RISpar_pop();
			if (rootptr->rhs->tok == RIS_TOK_NULL_NODE)
			{
				rootptr->rhs = 0;
			}
		break;
		case 2:
			rootptr->rhs = RISpar_pop();
			if (rootptr->rhs->tok == RIS_TOK_NULL_NODE)
			{
				rootptr->rhs = 0;
			}
			rootptr->lhs = RISpar_pop();
			if (rootptr->lhs->tok == RIS_TOK_NULL_NODE)
			{
				rootptr->lhs = 0;
			}
		break;
		default:
			RISpar_ERR_RETURN(RIS_E_INTERNAL_ERROR,rootptr->pos);
		break;
	}
	RISpar_push(rootptr);
}

/******************************************************************************/

extern void RISpar_link_nodes()
{
	ristree * tp1;
	ristree * tp2;
	ristree * temp;

PAR_DBG(("\nRISpar_link_nodes\n"));

	tp1 = RISpar_pop();
	if (tp1->tok != RIS_TOK_LIST)
	{
		temp = ALLOCT(ristree);
		temp->tok = RIS_TOK_LIST;
		temp->lhs = tp1;
		tp1 = temp;
	}
	tp2 = RISpar_pop();
	if (tp2->tok != RIS_TOK_LIST)
	{
		temp = ALLOCT(ristree);
		temp->tok = RIS_TOK_LIST;
		temp->lhs = tp2;
		tp2 = temp;
	}
	tp1->rhs = tp2;
	RISpar_push(tp1);
}

/******************************************************************************/

extern void RISpar_create_list(
	int tok,
	lex_s * lex,
	int length)
{
	ristree * ptr;
	ristree * nodelist;
	ristree * tp1;
	ristree * tp2;
	ristree * temp;

PAR_DBG(("\nRISpar_create_list tok = %s lex = %x length = %d\n",
 RIScom_get_token_name(tok),lex,length));

	ptr = RISpar_create_tree_node(tok,lex);
	for (nodelist=0;length > 0;length--)
	{
		if (RISpar_top()->tok == RIS_TOK_NULL_NODE)
		{
			RISpar_pop();
		}
		else
		{
			for (tp1=nodelist,tp2=RISpar_pop();tp2;tp1=tp2,tp2=temp)
			{
				if (tp2->tok != RIS_TOK_LIST)
				{
					temp = ALLOCT(ristree);
					temp->tok = RIS_TOK_LIST;
					temp->lhs = tp2;
					tp2 = temp;
				}
				temp = tp2->rhs;
				tp2->rhs = tp1;
			}
			nodelist = tp1;
		}
	}
	ptr->rhs = nodelist;
	RISpar_push(ptr);
}

/******************************************************************************/

static void traverse_tree(
	ristree *ptr,
	int *colp)
{
	int lhs_c = -1;
	int *rhs_cp = 0;
	int odd;

	if (!ptr) return;

	odd = row % 2;

	if (ptr->lhs)
	{
		if (!odd) col--;
		row++;
		traverse_tree(ptr->lhs,&lhs_c);
		if (!odd) col++;
		row--;
	}

	if (0 <= row && row < TABLE_ROW && 0 <= col && col < TABLE_COL)
	{
		while(table[row][col].ptr) col++;
	}
	else
	{
		overflow = 1;
	}

	if (odd)
	{
		if (0 <= row && row < TABLE_ROW && 0 < col && col <= TABLE_COL)
		{
		while (lhs_c >= 0 && col - 1 >= lhs_c && table[row][col - 1].ptr == 0)
			col--;
		}
		else
		{
			overflow = 1;
		}
	}
	else
	{
		if (0 <= row && row < TABLE_ROW && 0 < col && col <= TABLE_COL)
		{
		while (lhs_c >= 0 && col - 1 > lhs_c && table[row][col - 1].ptr == 0)
			col--;
		}
		else
		{
			overflow = 1;
		}
	}

	if (row > max_row) max_row = row;
	if (col < min_col) min_col = col;
	if (col > max_col) max_col = col;

	if (0 <= row && row < TABLE_ROW && 0 <= col && col < TABLE_COL)
	{
		table[row][col].ptr = ptr;
		*colp = col;

		table[row][col].lhs_c = lhs_c;
		rhs_cp = &table[row][col].rhs_c;
	}
	else
	{
		overflow = 1;
	}

	if (ptr->rhs)
	{
		if (odd) col++;
		row++;
		traverse_tree(ptr->rhs,rhs_cp);
		if (odd) col--;
		row--;
	}
}

/******************************************************************************/

extern void RISpar_draw_tree(
	ristree *top)
{
	int i,r,c;
	int odd;
	int len;
	int index;
	int width;
	int start;
	int root_c;
	char *name;
	char s[81];
	char s1[81];
	char s2[81];
	char s3[81];
	char s4[81];
	ristree *ptr;

	RIScom_output_debug("In print_tree\n");
	if (!top) return;
	max_row = row = 0;
	min_col = max_col = col = 13;
	overflow = 0;
	
	memset((char *)table,0,sizeof(table));
	for (r = 0; r < TABLE_ROW; r++)
		for (c = 0; c < TABLE_COL; c++)
			table[r][c].ptr = 0;

	traverse_tree(top,&root_c);

	if (overflow)
	{
		RIScom_output_debug("The Statement Is Too Big To Print!\n");
		return;
	}

	width = (80 / (max_col - min_col + 1));
	if (width > 15) width = 15;

	for (r = 0; r <= max_row && r < TABLE_ROW; r++)
	{
		odd = r % 2;

		memset(s1,' ',80);
		memset(s2,' ',80);
		memset(s3,' ',80);
		memset(s4,' ',80);
		s1[80] = 0;
		s2[80] = 0;
		s3[80] = 0;
		s4[80] = 0;

		for (c = min_col; c <= max_col && c < TABLE_COL; c++)
		{
			if ((ptr = table[r][c].ptr) != 0)
			{
				name = RIScom_get_token_name(ptr->tok);
				len = strlen(name);
				if (len > width - 2) len = width - 2;

				start = (c - min_col) * width;

				memset(s,' ',width);
				strncpy(s + (width - len)/2,name,len);
				strncpy(s1 + start,s,width);

				if (ptr->info.val)
				{
					if (ptr->tok != RIS_TOK_TIMESTAMP_LIT)
					{
						len = strlen(ptr->info.val);
						if (len > width - 2) len = width - 2;

						memset(s,' ',width);
						strncpy(s + (width - len)/2,ptr->info.val,len);
						strncpy(s2 + start,s,width);
					}
				}


				if (ptr->lhs)
				{
					index = start + width/2 - 1;

					if (!ptr->info.val)
						s2[index] = '/';
					index--;

					s3[index--] = '/';

					if (odd)
						len = (c - table[r][c].lhs_c) * width + width/2 - 3;
					else
						len = (c - table[r][c].lhs_c - 1) * width + width/2 - 3;

					for (i = 0; i < len; i++)
						s3[index--] = '_';

					s4[index] = '/';
				}

				if (ptr->rhs)
				{
					index = start + width/2;

					if (!ptr->info.val)
						s2[index] = '\\';
					index++;

					s3[index++] = '\\';

					if (odd)
						len = (table[r][c].rhs_c - c - 1) * width + width/2 - 3;
					else
						len = (table[r][c].rhs_c - c) * width + width/2 - 3;
					for (i = 0; i < len; i++)
						s3[index++] = '_';

					s4[index] = '\\';
				}
			}
		}
		if (r % 2)
		{
			for (i = 0; i < width/2; i++)
				RIScom_output_debug(" ");
			s1[80 - width/2] = 0;
		}
		RIScom_output_debug("%s\n",s1);

		if (r % 2)
		{
			for (i = 0; i < width/2; i++)
				RIScom_output_debug(" ");
			s2[80 - width/2] = 0;
		}
		RIScom_output_debug("%s\n",s2);

		if (r % 2)
		{
			for (i = 0; i < width/2; i++)
				RIScom_output_debug(" ");
			s3[80 - width/2] = 0;
		}
		RIScom_output_debug("%s\n",s3);

		if (r % 2)
		{
			for (i = 0; i < width/2; i++)
				RIScom_output_debug(" ");
			s4[80 - width/2] = 0;
		}
		RIScom_output_debug("%s\n",s4);
	}
}

/******************************************************************************/
