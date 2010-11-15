/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */
/*
**	NAME:							edtgets.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					8/88
**	ABSTRACT:
**		An editor for RIS
**	
**	REVISION HISTORY:
**		Modified extensively to support double-byte char format for Hangul.
**											-- Hitesh R. Patel (10/19/92)
**
**		TDM - 1/30/94 - Fixed TR# 249300840
**			Function ends_with_semicolon now checks for comments also
**
**		RLK - 10/06/94 -	Removed all references to RIScom_isdbcha(ch)
**
**		RLK - 11/94 - 	Added support for INTERNATIONALIZATION.
*/
 
#define EDIT_GLOBAL_DEFINE
 
/*
**	INCLUDES
*/

#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#if defined(WIN32)
#include <windows.h>
#endif
#if defined(DOS)
#include <conio.h>
#include <graph.h>
#endif
#include "edit.h"
#include "rislimit.h"
#include "rispath.h"

/*
**	DEFINES
*/
#if defined(DOS)
#undef getchar
#undef putchar
#endif

#define PREVIOUS_COMMAND    0
#define NEXT_COMMAND        1

#define isalnum_(c) ((isalnum(c)) || ((c) == '_'))

#if defined(unix)
# define GETCHAR()	getchar()
#endif
#if defined(WIN32)
# define GETCHAR()	getinput(hStdIn);
#endif
#if defined(DOS)
# define GETCHAR()	_getch()
#endif

#define GETCHAR_CHECK() \
{\
	ch = GETCHAR();\
	save_errno = errno;\
	if ( ch == EOF || ch == CTRL_Z || ch == '') break;\
}

/*
**	TYPES
*/
struct command_data_st
{
    char buf[RIS_MAX_STMT_LEN];
    int offset;
    int col;
    int row;
};

struct cmd_stack_st
{
    struct cmd_stack_st *next, *prev;
    char *s;
};

struct pt_st
{
    int r,c;
};

struct cmd
{
    int emacs;
    int vi;
    void (*func)();
};


/*
**	FUNCTION PROTOTYPES
*/
#define edtgets_c
#include "comisfn.prt"
#include "comdebug.prt"
#include "edtgets.prt"
#if defined(WIN32)
#include "edtwin32.prt"
#endif
#include "ucocmd.prt"
#include "ucoterm.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static int						edit_style = VI;
static int						home_row, home_col, row, col;
static int						*end_col;
static int						max_row;
static int						max_col;
static char						*search_string = 0;
static char						*filename;
static char						filebuf[256];
static char						deletebuf[2000] = "";
static char						save_delete = 1;
static struct cmd_stack_st		*cmd_root = 0;
static struct cmd_stack_st		*pnode;
static struct command_data_st	undo_data[2];
static struct command_data_st	current_command;

static char *EDT_vi_modes[] =
{
	"VI_COMMAND_MODE",
	"VI_INSERT_MODE",
	"VI_SEARCH_MODE",
	"VI_DELETE_MODE",
	"VI_CHANGE_MODE",
	"VI_REPLACE_MODE",
	"VI_RELACE_1_CHAR_MODE"
};
#if !defined (DOS)
extern int	errno;
#endif
/*
**  FUNCTIONS
*/

/******************************************************************************/

static void recalculate_end_col(
	char *user_bufp)
{
	int index = 0;

	EDT_DBG(("recalculate()\n"));
	/*
	** There is end_col for each row to store the last column position('\n')
	*/
	for (index = 0; index < (RIS_MAX_STMT_LEN/max_col); end_col[index++] = 0);

	index = 0;
	while(*user_bufp)
	{
		end_col[index]++;
        if (*user_bufp == NEWLINE_CHAR)
        {
            index++;
        }
        else
        {
       		if (end_col[index] == max_col) index++;
        }
		user_bufp++;
	}
	end_col[index]++;
	for (index = 0; index < max_row; index++)
	{
		if( end_col[index] > 0 )
		{
			EDT_DBG(("end_col[%d] = %d\n", index, end_col[index]));
		}
	}
}

/******************************************************************************/

static void new_line()
{
	EDT_DBG(("new_line()\n"));

	if (row == max_row)
	{
		/*
		**	If current row is max_row (i.e., we start from max_row) then 
		**	decrement home_row (row remains same)
		*/
		home_row--;
	}
	else 
	{
		row++;
	}
	col = 1;
	NEXT_LINE;
	PUT_PROMPT(PROMPT2);
}

/******************************************************************************/

static void strcprepend(
	char *s,
	char c)
{
	char temp;

	while (*s)
	{
		temp = *s;
		*s++ = c;
		c = temp;
	}
	*s++ = c;
	*s = '\0';
}

/******************************************************************************/

static void insert_ch(
	char **cur_bufpp, 
	char *user_bufp,
	char ch,
	char db_ch)
{
	short 	byte = 1;
	short 	cursor_at_dbchar = 0;
#ifdef OLD
	char 	*p;
	char    tmp_buf[RIS_MAX_STMT_LEN]; /* modify later on */
#endif

	EDT_DBG(("insert_ch(ch=<%c> ch=<%d> db_ch=<%c> db_ch=<%d>)\n", 
			ch, ch, db_ch, db_ch));

	if( db_ch )
	{
		byte = 2;
	}

	/* shift string forward one/two character(s) to right */

#ifdef OLD
	p = *cur_bufpp;
	strcpy(tmp_buf,p);
	*p++ = ch;	 
	if( byte == 2 )
	{
		*p++ = db_ch;	 
	}
	strcpy(p,tmp_buf);
#else
	strcprepend(*cur_bufpp, ch);
	if( byte == 2 )
	{
		strcprepend(*cur_bufpp, db_ch);
	}
#endif


	/*
	**	While inserting a char, subsequent chars are shifted to next location
	**	and therefore they might be moved to next row. Hence recalculate 
	**	end_col for each row
	*/
	recalculate_end_col(user_bufp);

#if defined(unix)
	EDT_DBG(("byte == %d cursor_at_dbchar == %d\n", byte, cursor_at_dbchar));

	if (byte == 1 && end_col[row-home_row] < max_col && ch != NEWLINE_CHAR) 
	{
		/*
		** English
		*/
		INSERT_BLANKS(1); /* insert one/two blank(s) at current location */
		PUT_CHAR(ch);	  	 /* put first byte onto the screen */
		BACKWARD(1); /* move backward one/two byte(s) */
	}
	else
	{
		refresh_save_cursor(cur_bufpp, user_bufp, 0);
	}

#ifdef HVTERM_BUG_GETS_FIXED
	if (end_col[row-home_row] == max_col-1 || ch == NEWLINE_CHAR ||
	    (byte == 1 && cursor_at_dbchar == 1) || 
		(byte == 2 && cursor_at_dbchar == 0) ) 
	{
		/*
		** refresh if:
		** 1. this row as many as chars allowed
		** 2. it is new line char
		** 3. current char and inserting char are of different char set.
		*/
		refresh_save_cursor(cur_bufpp, user_bufp, 0);
	}
	else
	{
		INSERT_BLANKS(byte); /* insert one/two blank(s) at current location */
		PUT_CHAR(ch);	  	 /* put first byte onto the screen */
		if( byte == 2 )
		{
			PUT_CHAR(db_ch); /* put second byte onto the screen */
		}
		BACKWARD(byte); /* move backward one/two byte(s) */
	}
#endif /*HVTERM*/
#endif
#if defined(WIN32)
	refresh_save_cursor(cur_bufpp, user_bufp, 1);
#endif
#if defined(DOS)
	refresh_save_cursor(cur_bufpp, user_bufp, 0);/* rlk */
#endif

	next_char(cur_bufpp);
	EDT_DBG(("insert_ch() complete.\n")); 
}

/******************************************************************************/

static void insert_str(
	char **cur_bufpp, 
	char *user_bufp, 
	char *is)
{
	EDT_DBG(("insert_str()\n")); 
	for ( ; *is; ++is) 
	{	
			insert_ch(cur_bufpp, user_bufp, *is, *(++is));
	}
}

/******************************************************************************/

static int prev_char(
	char **cur_bufpp, 
	char *user_bufp)
{
	short byte = 1;

	EDT_DBG(("prev_char(ch:<%c>[%d])\n", **cur_bufpp, **cur_bufpp));
	EDT_DBG(("user_bufp:<%c>[%d]\n", *user_bufp, *user_bufp));
	EDT_DBG(("row:%d col:%d\n", row, col));

	if (user_bufp < *cur_bufpp)
	{
		if (col == 1)
		{
			row--;
			col = end_col[row - home_row];
		}
		else 
		{
			col--;
			if( byte == 2 )
			{
				col--;
			}
		}

		SET_CURSOR(row, col);
		(*cur_bufpp)--;
		if( byte == 2 )
		{
			(*cur_bufpp)--;
		}
		return(1);
	}
	return(0);
}

/******************************************************************************/

static int next_char(
	char **cur_bufpp)
{
	short byte = 1;

	EDT_DBG(("next_char(ch:<%c>[%d])\n", **cur_bufpp, **cur_bufpp));
	EDT_DBG(("row:%d col:%d\n", row, col));

	if (**cur_bufpp)
	{
		/*
		** To check whether this was the last-byte of this current row
		*/
		if (col == end_col[row - home_row] ||
		   ((byte == 2) && (col == (end_col[row - home_row] - 1))) )
		{
			new_line();
		}
		else /* if (col < end_col[row - home_row]) */
		{
			FORWARD(byte);	/* move cursor forward one/two byte(s) */
			col++;
			if( byte == 2 )
			{
				col++;
			}
		}
		(*cur_bufpp)++;			/* increment string pointer */
		if( byte == 2 )
		{
	 		(*cur_bufpp)++;    /* increment string pointer (second-byte) */
		}
		return(1);
	}
	return(0);
}

/******************************************************************************/

static void begin_buf(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("begin_buf()\n"));

	row = home_row;
	col = home_col;
	SET_CURSOR_REAL(row, col);
	PUT_PROMPT(PROMPT1);
	*cur_bufpp = user_bufp;
}

/******************************************************************************/

extern void EDT_puts(
	char *s,
	int len2)
{
	EDT_DBG(("EDT_puts(s:<%s> len2:%d)\n", s, len2));

	while(len2--)
	{
		if (*s == NEWLINE_CHAR) 
		{
			putchar(' ');
		}
		else 
		{
			putchar(*s);
		}
		s++;
	}
}

/******************************************************************************/

static void refresh(
	char **cur_bufpp, 
	char *user_bufp)
{
	int len, len2;

	EDT_DBG(("refresh()\n"));

	begin_buf(cur_bufpp, user_bufp);
	CLR_TO_EOB;

	len = strlen(user_bufp);
	EDT_DBG(("refresh():len=%d\n", len));

	while (len)
	{
		if (len <= end_col[row - home_row]) 
		{
			len2 = len;
		}
		else 
		{
			len2 = end_col[row - home_row];
		}

		EDT_puts(*cur_bufpp, len2);
		*cur_bufpp += len2;
		len -= len2;

		EDT_DBG(("refresh():len=%d\n", len));
		if (len) 
		{
			new_line();
		}
		else 
		{
			col = len2 + 1;
		}
	}

	EDT_DBG(("refresh():row=%d col=%d\n", row, col));
	EDT_DBG(("refresh():end_col[]=%d\n", end_col[row-home_row]));
	if (col > end_col[row-home_row]) 
	{
		new_line();
	}
}

/******************************************************************************/

static void refresh_EOB(
	char **cur_bufpp) 
{
	int len, len2;
	int first_flag = 1;

	EDT_DBG(("refresh_EOB()\n"));

	CLR_TO_EOB;

	len = strlen(*cur_bufpp);
	EDT_DBG(("refresh_EOB():len=%d\n", len));

	while (len)
	{
		if (first_flag)
		{
			if (len == 1)
			{
				len2 = 1;
			}
			else
			{
				EDT_DBG(("refresh_EOB():end_col[%d]=%d\n", row-home_row, 
					end_col[row-home_row]));
				if (len <= (end_col[row - home_row] - col + 1)) 
				{
					len2 = len;
				}
				else 
				{
					len2 = end_col[row - home_row] - col + 1;
				}
			}
			first_flag = 0;
		}
		else
		{
			if (len <= end_col[row - home_row]) 
			{
				len2 = len;
			}
			else 
			{
				len2 = end_col[row - home_row];
			}
		}

		EDT_puts(*cur_bufpp, len2);
		*cur_bufpp += len2;
		len -= len2;

		EDT_DBG(("refresh_EOB():len=%d\n", len));
		if (len) 
		{
			new_line();
		}
		else 
		{
			col = len2 + 1;
		}
	}

	EDT_DBG(("refresh_EOB():row=%d col=%d\n", row, col));
	EDT_DBG(("refresh_EOB():end_col[]=%d\n", end_col[row-home_row]));
	if (col > end_col[row-home_row]) 
	{
		new_line();
	}
}

/******************************************************************************/

static void command_push(
	char *s,
	int alloc_flag)
{
	int len;
	struct cmd_stack_st *node;

	if (*s == 0 || *s == NEWLINE_CHAR) return;

	if (cmd_root && cmd_root->s == s) return;

	node = (struct cmd_stack_st *) malloc (sizeof(struct cmd_stack_st));
	if (!node) return;

	len = strlen(s)+1;

	if (alloc_flag)
	{
		node->s = (char *) malloc(len);
		if (!node->s) return;
		memcpy(node->s, s, len);
	}
	else node->s = s;

	node->next = cmd_root;
	node->prev = 0;
	if (cmd_root) cmd_root->prev = node;
	cmd_root = node;
}

/******************************************************************************/

static int pop()
{
	if (pnode)
	{
		if (pnode->next) pnode = pnode->next;
		else return(0);
	}
	else if (cmd_root) pnode = cmd_root;

	return((int) pnode);
}

/******************************************************************************/

static int pip()
{
	if (pnode)
	{
		pnode = pnode->prev;
		return(1);
	}

	return(0);
}

/******************************************************************************/

extern void EDT_set_edit_style(
	char *cp)
{
	if (strncmp(cp, "vi", 2) == 0) 
	{
		edit_style = VI;
	}
	else if (strncmp(cp, "emacs", 5) == 0) 
	{
		edit_style = EMACS;
	}
	else
	{
		printf("Invalid edit style... choices are \"vi\" and \"emacs\"\n");
	}
}

/******************************************************************************/

static void reset_cols(
	char *user_bufp)
{
	EDT_DBG(("reset_cols()\n"));

	SET_CURSOR_REAL(home_row, home_col);
	CLR_TO_EOB;

	row = home_row;
	col = home_col;
	recalculate_end_col(user_bufp);
}

/******************************************************************************/

static void save_command(
	char *cur_bufp, 
	char *user_bufp,
	struct command_data_st *data_ptr)
{
	EDT_DBG(("save_command()\n"));

	data_ptr->col = col - home_col;
	data_ptr->row = row - home_row;
	data_ptr->offset = cur_bufp - user_bufp;
	strcpy(data_ptr->buf,user_bufp);
}

/******************************************************************************/

static void restore_command(
	char **cur_bufpp, 
	char *user_bufp,
	struct command_data_st *data_ptr)
{
	col = home_col + data_ptr->col;
	row = home_row + data_ptr->row;
	*cur_bufpp = user_bufp + data_ptr->offset;
	strcpy(user_bufp,data_ptr->buf);

	recalculate_end_col(user_bufp);
	refresh_save_cursor(cur_bufpp, user_bufp, 0);
}

/******************************************************************************/

static void delete_chars_from_buffer(
	int n,
	char **cur_bufpp)
{
	EDT_DBG(("delete_chars_from_buffer(n:%d ch:%c)\n", n, **cur_bufpp));

	if (save_delete)
	{
		strncpy(deletebuf, *cur_bufpp, n);
		deletebuf[n] = 0;
	}
	strcpy(*cur_bufpp, *cur_bufpp + n);
}

/******************************************************************************/

static void next_cmd(
	char **cur_bufpp, 
	char *user_bufp)
{
	if (pip())
	{
		if (pnode)
		{
			*cur_bufpp = user_bufp;
			strcpy(user_bufp, pnode->s);
			reset_cols(user_bufp);
			refresh_save_cursor(cur_bufpp, user_bufp, 0);
		}
		else
		{
			restore_command(cur_bufpp, user_bufp, &current_command);
		}
	}
}

/******************************************************************************/

static void prev_cmd(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("prev_cmd()\n"));

	if (pnode == 0) 
	{
		save_command(*cur_bufpp, user_bufp, &current_command);
	}

	if (pop())
	{
		*cur_bufpp = user_bufp;
		strcpy(user_bufp, pnode->s);
		reset_cols(user_bufp);
		refresh_save_cursor(cur_bufpp, user_bufp, 0);
	}
}

/******************************************************************************/

static void begin_stmt(
	char **cur_bufpp, 
	char *user_bufp)
{
	row = home_row;
	col = home_col;
	SET_CURSOR(row, col);
	*cur_bufpp = user_bufp;
}

/******************************************************************************/

static void end_stmt(
	char **cur_bufpp, 
	char *user_bufp)
{
	int len;

	for (len = strlen(user_bufp);
			len && next_char(cur_bufpp);
				--len) ;
	prev_char_no_nl(cur_bufpp, user_bufp);
}

/******************************************************************************/

static void begin_line(
	char **cur_bufpp, 
	char *user_bufp)
{
	while (prev_char_no_nl(cur_bufpp, user_bufp) ) ;
}

/******************************************************************************/

static void end_line(
	char **cur_bufpp)
{
	EDT_DBG(("end_line()\n"));

	if ( edit_style == EMACS )
	{
		if (col < end_col[row - home_row])
		{
			while (next_char_no_nl(cur_bufpp));
			next_char(cur_bufpp);
		}
	}
	else
	{
		while (next_char_no_nl(cur_bufpp));
	}
}

/******************************************************************************/

static void prev_line(
	char **cur_bufpp, 
	char *user_bufp)
{
    EDT_DBG(("prev_line()\n"));
    EDT_DBG(("prev_line(): row=%d col=%d\n", row, col));

	if (row > home_row)
	{
		int dest_col, dest_row;

		dest_row = row-1;

		if (col < end_col[dest_row - home_row])
		{
			dest_col = col;
            EDT_DBG(("first time\n"));
            EDT_DBG(("ch:<%d>\n", user_bufp[get_user_buf_index(dest_row,dest_col)]));
            /*
            ** dest_col can be at first or second byte of the character
            */
            EDT_DBG(("second time\n"));
            if( is_second_byte(user_bufp+get_user_buf_index(dest_row,dest_col)) )
            {
                dest_col--;
            }
		}
		else
		{
			if (end_col[dest_row - home_row] > 1)
			{
				dest_col = end_col[dest_row - home_row] - 1;
                /*
                ** dest_col can be at second byte of the character
                */
			}
			else
			{
				dest_col = 1;
			}
		}

    	EDT_DBG(("prev_line(): dest_row=%d dest_col=%d\n", dest_row, dest_col));
		while (row != dest_row || col != dest_col)
		{
			if (!prev_char(cur_bufpp, user_bufp)) break;
		}
	}
	else 
	{
		prev_cmd(cur_bufpp, user_bufp);
	}
}

/******************************************************************************/

static void next_line(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("next_line()\n"));
	EDT_DBG(("next_line():row:%d col:%d\n", row, col));

	if (row < max_row)
	{
		if (end_col[(row + 1) - home_row])
		{
			int dest_col, dest_row;

			dest_row = row+1;

			if (col < end_col[dest_row - home_row])
			{
				dest_col = col;
				EDT_DBG(("next_line():first time\n"));
            	EDT_DBG(("next_line():ch:<%d>\n", 
						user_bufp[get_user_buf_index(dest_row,dest_col)]));
				/*
				** dest_col can be at first or second byte of the character
				*/
				if( is_second_byte(user_bufp+get_user_buf_index(dest_row,dest_col)) )
				{
					dest_col--;
				}
			}
			else
			{
				if (end_col[dest_row - home_row] > 1)
				{
					dest_col = end_col[dest_row - home_row] - 1;
					/*
					** dest_col can be at second byte of the character
					*/
				}
				else
				{
					dest_col = 1;
				}
			}

			EDT_DBG(("next_line(): dest_row:%d dest_col:%d\n",
					dest_row,dest_col));
			while (row != dest_row || col != dest_col)
			{
				/*
				** next_char assumes that double_byte chars are taken care off
				*/
				if (!next_char(cur_bufpp)) break;
			}
		}
		else 
		{
			next_cmd(cur_bufpp, user_bufp);
		}
	}
	else 
	{
		next_cmd(cur_bufpp, user_bufp);
	}
}

/******************************************************************************/

static int get_user_buf_index(
	int curr_row,
	int curr_col)
{
	int total = 0; /* index from the beginning */
	int index;

	EDT_DBG(("get_user_buf_index(curr_row:%d curr_col:%d)\n",
			curr_row, curr_col));

	curr_row = curr_row - home_row - 1;

	/*
	**	(end_col[row-home_row]-1) gives the curr's row last char-byte
	*/

	EDT_DBG(("curr_row:%d (index)\n", curr_row));

	for (index = 0; index <= curr_row; index++)
	{
		EDT_DBG(("end_col[%d] = %d\n", index, end_col[index]));
		total += end_col[index];
	}
	total += curr_col - 1; 
	EDT_DBG(("get_user_buf_index(): returning total = %d\n", total));
	return total;
}

/******************************************************************************/

static int is_second_byte(
	char *cur_bufp)
{
	int i, odd_or_even = 0;

	EDT_DBG(("is_second_byte()\n"));

	/*
	for( i = col-1; i > 1; i--, cur_bufp-- )
	*/
	for( i = col-1; i >= 0; i--, cur_bufp-- )
	{
		/*
		**	Go till beginning of this current row and find the number of hangul
		**	bytes
		*/
		EDT_DBG(("<%c>[%d]", *cur_bufp, *cur_bufp));
		break;
	}
	EDT_DBG(("\n"));

	EDT_DBG(("odd_or_even = %d\n", odd_or_even));
	if( odd_or_even == 0 )
	{
		EDT_DBG(("is_second_byte():returning 0\n"));
		return 0;	
	}
	if( odd_or_even & 1 )
	{
		/*
		** odd number (col represent that it was on first-byte)
		*/
		EDT_DBG(("is_second_byte():returning 0\n"));
		return 0;	
	}
	else
	{
		/*
		**	even number including zero (col represent that it was on second)
		*/
		EDT_DBG(("is_second_byte():returning 1\n"));
		return 1;
	}
}

/******************************************************************************/

static void next_word(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("next_word()\n"));

	if (EDT_isalnum_(**cur_bufpp))
	{
		while ((EDT_isalnum_(**cur_bufpp)) && next_char(cur_bufpp)) ;
	}
	else if (RIScom_ispunct(**cur_bufpp))
	{
		while ((RIScom_ispunct(**cur_bufpp)) && next_char(cur_bufpp) ) ;
	}

	while (RIScom_isspace(**cur_bufpp) && **cur_bufpp != NEWLINE_CHAR 
			&& next_char(cur_bufpp) ) ;

	if (**cur_bufpp == 0) 
	{
		prev_char(cur_bufpp, user_bufp);
	}
	if (**cur_bufpp == NEWLINE_CHAR) 
	{	
		next_char(cur_bufpp);
	}
}

/******************************************************************************/

static void next_Word(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("next_Word()\n"));

	while (!RIScom_isspace(**cur_bufpp) && next_char(cur_bufpp) ) ;
	while (RIScom_isspace(**cur_bufpp) && **cur_bufpp != NEWLINE_CHAR &&
		next_char(cur_bufpp) ) ;

	if (**cur_bufpp == 0) prev_char(cur_bufpp, user_bufp);
	if (**cur_bufpp == NEWLINE_CHAR) next_char(cur_bufpp);
}

/******************************************************************************/

static void prev_word(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("prev_word()\n"));

	prev_char(cur_bufpp, user_bufp);
	while (1)
	{
		if (!RIScom_isspace(**cur_bufpp)) break;
		if (**cur_bufpp == NEWLINE_CHAR && col == 1) break;
		if (!prev_char(cur_bufpp, user_bufp)) break;
	}

	if (EDT_isalnum_(**cur_bufpp))
	{
		while ((EDT_isalnum_(*((*cur_bufpp)-1)) || 
				prev_char(cur_bufpp, user_bufp))) ;
	}
	else if (RIScom_ispunct(**cur_bufpp))
	{
		while ((RIScom_ispunct(*((*cur_bufpp)-1)) || 
				prev_char(cur_bufpp, user_bufp))) ;
	}
}

/******************************************************************************/

static void prev_Word(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("prev_Word()\n"));

	prev_char(cur_bufpp, user_bufp);
	while (1)
	{
		if (!RIScom_isspace(**cur_bufpp)) break;
		if (**cur_bufpp == NEWLINE_CHAR && col == 1) break;
		if (!prev_char(cur_bufpp, user_bufp)) break;
	}
	while (!RIScom_isspace(*((*cur_bufpp)-1)) && 
			prev_char(cur_bufpp, user_bufp)) ;
}

/******************************************************************************/

static void end_word(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("end_word()\n"));

	next_char(cur_bufpp);
	while (RIScom_isspace(**cur_bufpp) && next_char(cur_bufpp) ) ;

	if (EDT_isalnum_(**cur_bufpp))
	{
		while ((EDT_isalnum_(**cur_bufpp))
				&& next_char(cur_bufpp)) ;
	}
	else if (RIScom_ispunct(**cur_bufpp))
	{
		while ((RIScom_ispunct(**cur_bufpp))
				&& next_char(cur_bufpp)) ;
	}

	prev_char(cur_bufpp, user_bufp);
	if (**cur_bufpp == NEWLINE_CHAR) 
	{
		next_char(cur_bufpp);
	}
}

/******************************************************************************/

static void end_Word(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("end_Word()\n"));

	next_char(cur_bufpp);
	while (RIScom_isspace(**cur_bufpp) && next_char(cur_bufpp) ) ;

	while (!RIScom_isspace(*((*cur_bufpp)+1)) && next_char(cur_bufpp) ) ;
	if (**cur_bufpp == 0) prev_char(cur_bufpp, user_bufp);
	if (**cur_bufpp == NEWLINE_CHAR) next_char(cur_bufpp);
}

/******************************************************************************/

static int prev_char_no_nl(
	char **cur_bufpp, 
	char *user_bufp)
{
	short byte = 1;

	EDT_DBG(("prev_char_no_nl(<%c>[%d])\n", **cur_bufpp, **cur_bufpp));
	EDT_DBG(("row:%d col:%d\n", row, col));

	if (user_bufp < *cur_bufpp)
	{
		if (*((*cur_bufpp) - 1) != NEWLINE_CHAR)
		{
			if (col == 1)
			{
				row--;
				col = end_col[row - home_row];
			}
			else 
			{
				col--;
				if( byte == 2 )
				{
					col--;
				}
			}
			SET_CURSOR(row, col);
			(*cur_bufpp)--;
			if( byte == 2 )
			{
				(*cur_bufpp)--;
			}
			return(1);
		}
	}
	return(0);
}

/******************************************************************************/

static int next_char_no_nl(
	char **cur_bufpp)
{
	char next_ch;
	short byte = 1;

	EDT_DBG(("next_char_no_nl(<%c>[%d])\n", **cur_bufpp, **cur_bufpp));
	EDT_DBG(("row:%d col:%d\n", row, col));

	if (**cur_bufpp)
	{
        next_ch = *((*cur_bufpp) + 1);
		if (next_ch != 0 && next_ch != NEWLINE_CHAR)
		{
			/*
			** To check whether this was the last-byte of this current row 
			*/
			if (col == end_col[row - home_row] ||
		   	((byte == 2) && (col == (end_col[row - home_row] - 1))) )
			{
				new_line();
			}
			else /* if (col < end_col[row - home_row]) */
			{
				FORWARD(byte);	/* move cursor forward one or two byte(s) */
				col++;
				if( byte == 2 )
				{
					col++;
				}
			}
			(*cur_bufpp)++;			/* increment string pointer */
			if( byte == 2 )
			{
				(*cur_bufpp)++;	/* increment string pointer (second-byte) */
			}
			return(1);
		}
	}
	return(0);
}

/******************************************************************************/

static int del_char(
	char **cur_bufpp, 
	char *user_bufp)
{
	char	deleted_ch;
	short	byte = 1;

	EDT_DBG(("del_char(ch:<%c>)\n", **cur_bufpp));

	if (**cur_bufpp)
	{
		deleted_ch = **cur_bufpp;

		delete_chars_from_buffer(byte,cur_bufpp);
		EDT_DBG(("del_char:<%s>\n", user_bufp));
		recalculate_end_col(user_bufp);

#if defined(unix)
		if (end_col[row-home_row] < max_col-1 && deleted_ch != NEWLINE_CHAR)
		{
			DEL_CHARS(byte);
		}
		else
		{
			refresh_save_cursor(cur_bufpp, user_bufp, 1);
		}
#endif
#if defined(WIN32)
			refresh_save_cursor(cur_bufpp, user_bufp, 1);
#endif
#if defined(DOS)
			refresh_save_cursor(cur_bufpp, user_bufp, 0);
#endif

		if (pnode) 
		{
			pnode = 0; /* reset command stack pointer */
		}
		return(1);
	}
	return(0);
}

/******************************************************************************/

static int del_prev_char(
	char **cur_bufpp, 
	char *user_bufp)
{
	int sts;

	/* if go back, del char */
	if (prev_char(cur_bufpp, user_bufp))
	{
		save_delete = 0;
		sts = del_char(cur_bufpp, user_bufp);
		save_delete = 1;
		return(sts);
	}

	return(0);
}

/******************************************************************************/

static int del_prev_char_no_nl(
    char **cur_bufpp,
    char *user_bufp)
{
    int sts;

    /* if go back, del char */
    if (prev_char_no_nl(cur_bufpp, user_bufp))
    {
        save_delete = 0;
        sts = del_char(cur_bufpp, user_bufp);
        save_delete = 1;
        return(sts);
    }
    return(0);
}

/******************************************************************************/

static void del_char_backup(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("del_char_backup(ch:<%c>)\n", **cur_bufpp));

	if (**cur_bufpp && **cur_bufpp != NEWLINE_CHAR)
	{
		del_char(cur_bufpp, user_bufp);
		if (**cur_bufpp == NEWLINE_CHAR || **cur_bufpp == 0)
		{
			prev_char_no_nl(cur_bufpp, user_bufp);
		}
	}
}

/******************************************************************************/

static void refresh_save_cursor(
	char **cur_bufpp, 
	char *user_bufp,
	int  eob_only)
{
	int save_row, save_col, save_hr;
	char *save_str;

	EDT_DBG(("refresh_save_cursor()\n"));
	EDT_DBG(("refresh_save_cursor:row:%d col:%d\n", row, col));

	save_row = row;
	save_col = col;
	save_hr = home_row;
	save_str = *cur_bufpp;


	if( eob_only )
	{
		/*
		** Refresh from current location to end of buffer (EOB) only
		*/
		refresh_EOB(cur_bufpp);
	}
	else
	{
		/*
		** Refresh from beginning to end of buffer
		*/
		refresh(cur_bufpp, user_bufp);
	}

	row = save_row - (save_hr - home_row);
	col = save_col;
	*cur_bufpp = save_str;

	EDT_DBG(("refresh_save_cursor:row:%d col:%d\n", row, col));
	SET_CURSOR(row, col);

	EDT_DBG(("refresh_save_cursor() complete.\n"));
}

/******************************************************************************/

static void insert_tab(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("insert_tab()\n")); 
	insert_str(cur_bufpp, user_bufp, "    ");
	if (pnode) pnode = 0; /* reset command stack pointer */
}

/******************************************************************************/

static void del_end_line(
	char **cur_bufpp, 
	char *user_bufp)
{
	int delete_count;
	char *ptr;

	EDT_DBG(("del_end_line()\n"));

	ptr = *cur_bufpp;
	while (*ptr && *ptr != NEWLINE_CHAR) ptr++;

	delete_count = ptr - *cur_bufpp;
	delete_chars_from_buffer(delete_count,cur_bufpp);
	recalculate_end_col(user_bufp);
	refresh_save_cursor(cur_bufpp, user_bufp, 1);

	if ( edit_style == VI && (**cur_bufpp == NEWLINE_CHAR || **cur_bufpp == 0))
		prev_char_no_nl(cur_bufpp, user_bufp);

	if (pnode) pnode = 0; /* reset command stack pointer */
}

/******************************************************************************/

static void del_line(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("del_line()\n"));

	begin_line(cur_bufpp,user_bufp);
	del_end_line(cur_bufpp,user_bufp);
	if (**cur_bufpp == 0)
	{
		del_prev_char(cur_bufpp,user_bufp);
		begin_line(cur_bufpp,user_bufp);
	}
	else
	{
		del_char(cur_bufpp,user_bufp);
	}
}

/******************************************************************************/

static void put_buf(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("put_buf()\n")); 
	if (*deletebuf)
	{
		if (col != 1 || **cur_bufpp != NEWLINE_CHAR)
			next_char(cur_bufpp);
		insert_str(cur_bufpp, user_bufp, deletebuf);
		if (col != 1) prev_char(cur_bufpp, user_bufp);
		if (pnode) pnode = 0; /* reset command stack pointer ??? */
	}
}

/******************************************************************************/

static void Put_buf(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("Put_buf()\n")); 
	if (*deletebuf)
	{
		insert_str(cur_bufpp, user_bufp, deletebuf);
		if ( edit_style == VI && col != 1) prev_char(cur_bufpp, user_bufp);
		if (pnode) pnode = 0; /* reset command stack pointer ??? */
	}
}

/******************************************************************************/

static int check_undo(
	char *user_bufp)
{
	if (strcmp(user_bufp,undo_data[1].buf))
	{
		undo_data[0] = undo_data[1];
		return(1);
	}
	return(0);
}

/******************************************************************************/

static void undo(
	char **cur_bufpp, 
	char *user_bufp)
{
	restore_command(cur_bufpp, user_bufp, &undo_data[0]);
}

/******************************************************************************/

/*
**	For clarity:
**		Previous commands progress towards older commands while
**		Next commands progess towards newer commands.  Note this
**		is the opposite of the struct cmd_stack_st where ptr->next
**		points to the older command and ptr->prev points to the
**		newer command.
*/

static int cmd_search(
	char **cur_bufpp, 
	char *user_bufp,
	int mode)
{
	int i;
	int len;
	int s_len;
	struct cmd_stack_st *pnode_save;

	pnode_save = pnode;
	s_len = strlen(search_string);
	if (s_len)
	{
		while (1)
		{
			if (mode == PREVIOUS_COMMAND)
			{
				if (pop() == 0) break;
			}
			else /* mode == NEXT_COMMAND */
			{
				if (pip() == 0 || pnode == 0) break;
			}

			len = strlen(pnode->s);
			for (i = 0; i <= len - s_len; i++)
			{
				if (strncmp(search_string,pnode->s + i,s_len) == 0)
				{
					/* pnode is set to proper command */
					*cur_bufpp = user_bufp;
					strcpy(user_bufp, pnode->s);
					reset_cols(user_bufp);
					refresh_save_cursor(cur_bufpp, user_bufp, 0);
					return(1);
				}
			}
		}
	}
	pnode = pnode_save;
	return(0);
}

/******************************************************************************/

static int prev_cmd_search(
	char **cur_bufpp, 
	char *user_bufp)
{
	return cmd_search(cur_bufpp, user_bufp, PREVIOUS_COMMAND);
}

/******************************************************************************/

static int next_cmd_search(
	char **cur_bufpp, 
	char *user_bufp)
{
	return cmd_search(cur_bufpp, user_bufp, NEXT_COMMAND);
}

/******************************************************************************/

static void join_lines(
	char **cur_bufpp, 
	char *user_bufp)
{
	char *ptr;

	ptr = *cur_bufpp;
	while (*ptr && *ptr != NEWLINE_CHAR) ptr++;

	if (*ptr == NEWLINE_CHAR)
	{
		while (**cur_bufpp && **cur_bufpp != NEWLINE_CHAR)
			next_char(cur_bufpp);

		delete_chars_from_buffer(1,cur_bufpp);
		recalculate_end_col(user_bufp);
		refresh_save_cursor(cur_bufpp, user_bufp, 1);

		if (**cur_bufpp == NEWLINE_CHAR || **cur_bufpp == 0)
			prev_char_no_nl(cur_bufpp, user_bufp);

		if (pnode) pnode = 0; /* reset command stack pointer */
	}
}

/******************************************************************************/

static void del_next_word(
	char **cur_bufpp, 
	char *user_bufp,
	int mode)
{
	int delete_count;
	char *ptr;

	EDT_DBG(("del_next_word()\n"));

	if (**cur_bufpp == NEWLINE_CHAR)
	{
		if (mode == VI_CHANGE_MODE) 
		{
			delete_count = 0;
		}
		else 
		{
			delete_count = 1;
		}
	}
	else
	{
		ptr = *cur_bufpp;

		if (RIScom_isspace(*ptr) && mode == VI_CHANGE_MODE)
		{
			delete_count = 1;
		}
		else
		{
			if (EDT_isalnum_(*ptr))
			{
				while (EDT_isalnum_(*ptr)) ptr++;
			}
			else if (RIScom_ispunct(*ptr))
			{
				while (RIScom_ispunct(*ptr)) ptr++;
			}

			if (mode == VI_DELETE_MODE)
			{
				while (RIScom_isspace(*ptr) && *ptr != NEWLINE_CHAR) ptr++;
			}
			delete_count = ptr - *cur_bufpp;
		}
	}
	delete_chars_from_buffer(delete_count,cur_bufpp);
	recalculate_end_col(user_bufp);
	refresh_save_cursor(cur_bufpp, user_bufp, 1);

	if (mode == VI_DELETE_MODE)
	{
		if (**cur_bufpp == NEWLINE_CHAR || **cur_bufpp == 0)
		{
			prev_char_no_nl(cur_bufpp, user_bufp);
		}
	}
}

/******************************************************************************/

static void del_next_Word(
	char **cur_bufpp, 
	char *user_bufp,
	int mode)
{
	int delete_count;
	char *ptr;

	EDT_DBG(("del_next_Word()\n"));

	if (**cur_bufpp == NEWLINE_CHAR)
	{
		if (mode == VI_CHANGE_MODE) delete_count = 0;
		else delete_count = 1;
	}
	else
	{
		ptr = *cur_bufpp;
		if (RIScom_isspace(*ptr) && mode == VI_CHANGE_MODE)
		{
			delete_count = 1;
		}
		else
		{
			while (*ptr && !RIScom_isspace(*ptr)) ptr++;
			if (mode == VI_DELETE_MODE)
			{
				while (RIScom_isspace(*ptr) && *ptr != NEWLINE_CHAR) ptr++;
			}

			delete_count = ptr - *cur_bufpp;
		}
	}
	delete_chars_from_buffer(delete_count,cur_bufpp);
	recalculate_end_col(user_bufp);
	refresh_save_cursor(cur_bufpp, user_bufp, 1);

	if (mode == VI_DELETE_MODE)
	{
		if (**cur_bufpp == NEWLINE_CHAR || **cur_bufpp == 0)
		{
			prev_char_no_nl(cur_bufpp, user_bufp);
		}
	}
}

/******************************************************************************/

static void del_prev_word(
	char **cur_bufpp, 
	char *user_bufp)
{
	int delete_count;
	char *ptr;

	EDT_DBG(("del_prev_word()\n"));

	ptr = *cur_bufpp;
	prev_word(cur_bufpp, user_bufp);

	delete_count = ptr - *cur_bufpp;
	delete_chars_from_buffer(delete_count,cur_bufpp);
	recalculate_end_col(user_bufp);
	refresh_save_cursor(cur_bufpp, user_bufp, 1);
}

/******************************************************************************/

static void del_prev_Word(
	char **cur_bufpp, 
	char *user_bufp)
{
	int delete_count;
	char *ptr;

	EDT_DBG(("del_prev_Word()\n"));

	ptr = *cur_bufpp;
	prev_Word(cur_bufpp, user_bufp);

	delete_count = ptr - *cur_bufpp;
	delete_chars_from_buffer(delete_count,cur_bufpp);
	recalculate_end_col(user_bufp);
	refresh_save_cursor(cur_bufpp, user_bufp, 1);
}

/******************************************************************************/

static void del_begin_line(
	char **cur_bufpp, 
	char *user_bufp)
{
	int delete_count;
	char *ptr;

	ptr = *cur_bufpp;
	begin_line(cur_bufpp,user_bufp);

	delete_count = ptr - *cur_bufpp;
	delete_chars_from_buffer(delete_count,cur_bufpp);
	recalculate_end_col(user_bufp);
	refresh_save_cursor(cur_bufpp, user_bufp, 1);
}

/******************************************************************************/

static void del_end_buffer(
	char **cur_bufpp, 
	char *user_bufp)
{
	if (**cur_bufpp)
	{
		CLR_TO_EOB;
		if (save_delete)
		{
			strcpy(deletebuf, *cur_bufpp);
		}
		**cur_bufpp = 0;
		recalculate_end_col(user_bufp);
		prev_char_no_nl(cur_bufpp, user_bufp);
		if ( edit_style == EMACS )
		{
			if (col != 1 || **cur_bufpp != NEWLINE_CHAR) next_char(cur_bufpp);
		}	
	}
}

/******************************************************************************/

static void open_line(
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("open_line()\n"));

	end_line(cur_bufpp);
	if (col != 1 || **cur_bufpp != NEWLINE_CHAR) 
	{
		next_char(cur_bufpp);
	}
	insert_ch(cur_bufpp, user_bufp, NEWLINE_CHAR, '\0');
}

/******************************************************************************/

static void Open_line(
	char **cur_bufpp, 
	char *user_bufp)
{
	begin_line(cur_bufpp, user_bufp);
	insert_ch(cur_bufpp, user_bufp, NEWLINE_CHAR, '\0');
	prev_char(cur_bufpp, user_bufp);
}

/******************************************************************************/

static void emacs_escape(
	char	**cur_bufpp, 
	char 	*user_bufp, 
	char 	ch)
{
	switch(ch)
	{
		case 'V':
		case 'v':
			prev_line(cur_bufpp, user_bufp);
			break;
		case '<':
			begin_stmt(cur_bufpp, user_bufp);
			break;
		case '>':
			end_stmt(cur_bufpp, user_bufp);
			break;
		case 'F':
		case 'f':
			next_word(cur_bufpp, user_bufp);
			break;
		case 'B':
		case 'b':
			prev_word(cur_bufpp, user_bufp);
			break;
		default:
			break;
	}
}

/******************************************************************************/

static void process_replace_one_char(
	char ch, 
	char db_ch,
	char **cur_bufpp, 
	char *user_bufp)
{
	short byte = 1;
	short cursor_at_dbchar = 0;

	EDT_DBG(("process_replace_one_char()\n"));

	if (**cur_bufpp && **cur_bufpp != NEWLINE_CHAR)
	{
		if( db_ch )
		{
			byte = 2;
		}	
		if (end_col[row-home_row] == max_col-1 || ch == NEWLINE_CHAR ||
	   	   (byte == 1 && cursor_at_dbchar == 1) || 
		   (byte == 2 && cursor_at_dbchar == 0) ) 
		{
			del_char(cur_bufpp, user_bufp);
			insert_ch(cur_bufpp, user_bufp, ch, db_ch);
			prev_char_no_nl(cur_bufpp, user_bufp);
		}
		else
		{
			/*
			** Replace a char of same char set
			*/
			**cur_bufpp = ch;
			if( byte == 2 )
			{
				*(*cur_bufpp+1) = db_ch;
			}
			REPLACE_CHARS(byte);
			PUT_CHAR(ch);
			if( byte == 2 )
			{
				PUT_CHAR(db_ch);
			}
			BACKWARD(byte);
		}
	}
}

/******************************************************************************/

static int process_replace(
	char ch, 
	char db_ch,
	char **cur_bufpp, 
	char *user_bufp)
{
	static int insert_mode;
	static int icount, rcount;
	static char buffer[100];
	short  byte = 1;
	short  replace_DEL_byte = 1;
	short  cursor_at_dbchar = 0;

	EDT_DBG(("process_replace()\n"));

	if (ch == 0) /* initialize values */
	{
		insert_mode = 0;
		icount = 0;
		rcount = 0;
		buffer[0] = 0;
	}
	else
	{
		if (**cur_bufpp == 0 || **cur_bufpp == NEWLINE_CHAR)
		{
			insert_mode = 1;
		}

		switch(ch)
		{
			case ESC:
				prev_char_no_nl(cur_bufpp, user_bufp);
				return(1);

			case DEL:
			case CTRL_H:
				if (insert_mode)
				{
					if (icount)
					{
						del_prev_char(cur_bufpp, user_bufp);
						icount--;
						if( replace_DEL_byte == 2 )
						{
							icount--;
						}
					}
					else 
					{
						insert_mode = 0;
					}
				}

				replace_DEL_byte = 1;
				if (insert_mode == 0)
				{
					if (rcount)
					{
						del_prev_char(cur_bufpp, user_bufp);
						if( replace_DEL_byte == 1 )
						{
							insert_ch(cur_bufpp, user_bufp, buffer[rcount-1], 
									'\0');
						}
						else
						{
							insert_ch(cur_bufpp, user_bufp, buffer[rcount-2], 
									buffer[rcount-1]);
						}
						prev_char(cur_bufpp, user_bufp);
						rcount--;
						if( replace_DEL_byte == 2 )
						{
							rcount--;
						}
					}
				}
				break;

			case NEWLINE_CHAR:
				if (insert_mode == 0)
				{
					buffer[rcount++] = **cur_bufpp;
				}
				else
				{
					icount++;
				}
				del_char(cur_bufpp, user_bufp);
				insert_ch(cur_bufpp, user_bufp, ch, db_ch);
				break;

			default:
				if (insert_mode == 0)
				{
					buffer[rcount++] = **cur_bufpp;
					if( (byte == 1 && cursor_at_dbchar == 1) || 
		   				(byte == 2 && cursor_at_dbchar == 0) ) 
					{
						/*
						** Opposite char set
						*/
						insert_ch(cur_bufpp, user_bufp, ch, db_ch);
						del_char(cur_bufpp, user_bufp);
						/*
						next_char(cur_bufpp);
						prev_char_no_nl(cur_bufpp, user_bufp);
						*/
					}
					else
					{
						/*
						** Same char set
						*/
						**cur_bufpp = ch;
						if( byte == 2 )
						{
							*(*cur_bufpp+1) = db_ch;
						}
						REPLACE_CHARS(byte);
						PUT_CHAR(ch);
						if( byte == 2 )
						{
							PUT_CHAR(db_ch);
						}
						BACKWARD(byte);
						next_char(cur_bufpp);
					}
				}
				else
				{
					insert_ch(cur_bufpp, user_bufp, ch, db_ch);
					icount++;
					if( byte == 2 )
					{
						icount++;
					}
				}
				break;
		}
	}
	return(0);
}

/******************************************************************************/

static int process_delete_change(
	int mode,
	char ch,
	char **cur_bufpp, 
	char *user_bufp)
{
	EDT_DBG(("process_delete_change()\n"));

	switch (ch)
	{
		case 'h':
			prev_char_no_nl(cur_bufpp, user_bufp);
		case 'l':
			del_char(cur_bufpp, user_bufp);
			if (**cur_bufpp == NEWLINE_CHAR || **cur_bufpp == 0)
			{
				prev_char_no_nl(cur_bufpp, user_bufp);
			}
			break;

		case 'w':
			del_next_word(cur_bufpp, user_bufp, mode);
			break;

		case 'W':
			del_next_Word(cur_bufpp, user_bufp, mode);
			break;

		case 'b':
			del_prev_word(cur_bufpp, user_bufp);
			break;

		case 'B':
			del_prev_Word(cur_bufpp, user_bufp);
			break;

		case '0':
			del_begin_line(cur_bufpp, user_bufp);
			break;

		case '$':
			del_end_line(cur_bufpp, user_bufp);
			break;

		case 'G':
			del_end_buffer(cur_bufpp, user_bufp);
			break;

		case 'd':
			del_line(cur_bufpp, user_bufp);
			break;

		default:
			return(0);
	}
	return(1);
}

/******************************************************************************/

static int ends_with_semicolon(
	char *user_bufp)
{
	char *ptr;

	if (*user_bufp)
	{
		if ((ptr = strrchr(user_bufp,';')) != NULL)
		{
			ptr++;
			while(*ptr)
			{
				if (RIScom_isspace(*ptr)) 
				{
					/* skip white space */
					ptr++;
				}
				else if (*ptr == '-' && *(ptr + 1) == '-')
				{
					/* skip comment */
					ptr += 2;
					while(*ptr && *ptr != NEWLINE_CHAR)
					{
						ptr++;
					}
				}
				else
				{
					/* something besides white space or comment */
					return 0;
				}
			}
			return(1);
		}
	}
	return(0);
}

/******************************************************************************/

static struct cmd cmds[] = {

/* history commands */
{ CTRL_N,	'+',		next_cmd,				},	/* next command			*/
{ CTRL_P,	'-',		prev_cmd,				},	/* previous command		*/

/* statement positioning commands */
{ ESC_LT,	'H',		begin_stmt,				},	/* beginning of stmt	*/
{ ESC_GT,	'G',		end_stmt,				},	/* end of stmt			*/
{ EOF,		'g',		end_stmt,				},	/* end of stmt			*/

/* line commands */
{ CTRL_A,	'0',		begin_line,				},	/* beginning of line	*/
{ CTRL_E,	'$',		end_line,				},	/* end of line			*/
{ ESC_V,	'k',		prev_line,				},	/* previous line		*/
{ CTRL_V,	'j',		next_line,				},	/* next line			*/

/* word commands */
{ ESC_F,	'w',		next_word,				},	/* next word			*/
{ EOF,		'W',		next_Word,				},	/* next Word			*/
{ ESC_B,	'b',		prev_word,				},	/* previous word		*/
{ EOF,		'B',		prev_Word,				},	/* previous Word		*/
{ EOF,		'e',		end_word,				},	/* end of word			*/
{ EOF,		'E',		end_Word,				},	/* end of Word			*/

/* character commands */
{ CTRL_B,	'h',	(void (*)())prev_char_no_nl,},	/* back one char		*/
{ CTRL_F,	'l',	(void (*)())next_char_no_nl,},	/* forward one char		*/
{ CTRL_D,	EOF,	(void (*)())del_char,		},	/* del one char			*/
{ CTRL_H,   'X',(void (*)())del_prev_char_no_nl,},  /* del back one char    */
{ DEL,      EOF,(void (*)())del_prev_char_no_nl,},  /* backspace            */
{ EOF,		'x',		del_char_backup,		},	/* del one char, backup	*/

/* miscellaneous commands */
{ CTRL_L,	CTRL_L,		refresh_save_cursor,	},	/* refresh; save cursor	*/
{ CTRL_I,	'	',		insert_tab,				},	/* tab -insert 4 sp		*/
{ CTRL_K,	'D',		del_end_line,			},	/* delete to end line	*/
{ CTRL_Y,	'P',		Put_buf,				},	/* yank last ^k			*/
{ EOF,		'p',		put_buf,				},	/* yank last ^k			*/
{ EOF,		'u',		undo,					},	/* undo last command	*/
{ EOF,		'n',	(void (*)())prev_cmd_search,},	/* search for command	*/
{ EOF,		'N',	(void (*)())next_cmd_search,},	/* search for command	*/
{ EOF,		'J',		join_lines,				},	/* join next line		*/

};

#define NUM_CMDS (sizeof(cmds) / sizeof (struct cmd))

/*
**	This is the main routine which parses the input chars. It returns the
**	command to EDT_getcmd().
*/

extern char *EDT_gets(
	char *user_buf)
{
	int i;
	int len;
	int repeat_cmd_flag;
	int insert_count = 0;
	int vi_mode = 0, escape_mode = 0;
	char ch;
	char double_ch = '\0'; /* second byte of double-byte char */
	int  double_ch_flag = 0;
	char *cur_buf;
	char *cmd_ptr;
	char *repeat_cmd_ptr = 0;
	char *repeat_cmd_buf;
	char cmd_buf[RIS_MAX_STMT_LEN+1];
	int  save_errno = 0;

	EDT_DBG(("EDT_gets(user_buf:0x%x)\n", user_buf));

	repeat_cmd_flag = 0;
	repeat_cmd_buf = (char *)malloc(1);
	cmd_ptr = cmd_buf;
	*cmd_ptr = 0;

	cur_buf = user_buf;
	*cur_buf = 0;

	pnode = 0;

	PUT_PROMPT(PROMPT1);

	/*
	**	row - home_row => current row i.e., index to end_col array 
	*/
	home_row = row = max_row;
	home_col = col = 1;
	recalculate_end_col(user_buf);

	undo_data[0].row = row;
	undo_data[0].col = col;
	undo_data[0].offset = cur_buf - user_buf;
	strcpy(undo_data[0].buf,user_buf);

	if (!search_string)
	{
		search_string = (char *)malloc(1);
		search_string[0] = 0;
	}

	RISuco_set_terminal_noecho_raw();
	if (edit_style == VI)
	{
		vi_mode = VI_INSERT_MODE;
		insert_count = 0;
		*cmd_ptr++ = 'i';
		*cmd_ptr = 0;
	}
	else if (edit_style == EMACS) 
	{
		escape_mode = 0;
	}

	SET_CURSOR(row, col);
	CLR_TO_EOL;

	SHOW_CURSOR;

	/* WHILE */
	while (1)
	{
		/*
		** Reset before getting a new char
		*/
		double_ch_flag = 0;

		if (repeat_cmd_flag)
		{
			if ((ch = *repeat_cmd_ptr++) == 0)
			{
				repeat_cmd_flag = 0;
				EDT_DBG(("row = %d col = %d ", row, col));
				EDT_DBG(("cur_buf = <%c> cur_buf = <%d>\n",*cur_buf,*cur_buf));
				GETCHAR_CHECK();
			}
		}
		else
		{
			EDT_DBG(("row = %d col = %d ", row, col));
			EDT_DBG(("cur_buf = <%c> cur_buf = <%d>\n",*cur_buf,*cur_buf));
			GETCHAR_CHECK();
		}

		EDT_DBG(("vi_mode = %d (%s)\n", vi_mode, EDT_vi_modes[vi_mode]));

		if (edit_style == EMACS)
		{

			/*
			** SJB added the use of VI_SEARCH_MODE flag in emacs.
			** I also added the check for ctrl_r and getting
			** the word to search on
			*/
			if (ch == NEWLINE_CHAR && vi_mode != VI_SEARCH_MODE)
			{
				if (ends_with_semicolon(user_buf)) break;
				else if (!RISuco_need_semi(user_buf)) break;
			}

			HIDE_CURSOR;

			if (ch == ESC) 
			{
				escape_mode = 1;
			}
			else if (escape_mode)
			{
				emacs_escape(&cur_buf, user_buf, ch);
				escape_mode = 0;
			}
			/*
			**  If we get ctrl_r, give SEARCH_PROMPT and set
			**  mode flag
			*/
			else if ( ch == CTRL_R )
			{
				save_command(cur_buf, user_buf, &undo_data[1]);

				if (pnode == 0)
					save_command(cur_buf, user_buf,
							 &current_command);
				strcpy(user_buf,SEARCH_PROMPT);
				reset_cols(user_buf);
				refresh(&cur_buf, user_buf);
				vi_mode = VI_SEARCH_MODE;
				insert_count=0;
			}
			/*
			**   if in search mode, get search string until NEWLINE_CHAR
			*/
			else if ( vi_mode == VI_SEARCH_MODE )
			{
				switch ( ch )
				{
					case NEWLINE_CHAR:
						len = strlen(user_buf + SEARCH_PROMPT_LEN);
						if (len) 
						{
							search_string =
								(char *)realloc(search_string, len + 1);
							strcpy(search_string,
								user_buf + SEARCH_PROMPT_LEN);
						}
						if (prev_cmd_search(&cur_buf,user_buf) == 0)
						{
							/* no command was found */
							undo_data[0] = undo_data[1];
							undo(&cur_buf, user_buf);
						}
						vi_mode = 0;
						break;

					case DEL:
					case CTRL_H:
						if (insert_count)
						{
							del_prev_char(&cur_buf, user_buf);
							insert_count--;
						}
						break;

					default:
						insert_ch(&cur_buf, user_buf, ch, '\0');
						insert_count++;
						break;
				}
			}
			else
			{
				for (i = 0; i < NUM_CMDS; i++)
				{
					if (cmds[i].emacs == ch)
					{
						cmds[i].func(&cur_buf, user_buf);
						break;
					}
				}
				if (i == NUM_CMDS) insert_ch(&cur_buf, user_buf, ch, '\0');
			}
		}
		else if (edit_style == VI)
		{
			if (ch == NEWLINE_CHAR)
			{
				if (vi_mode == VI_COMMAND_MODE ||
					vi_mode == VI_INSERT_MODE ||
					vi_mode == VI_REPLACE_MODE )
				{
					if (ends_with_semicolon(user_buf) ||
						!RISuco_need_semi(user_buf)) 
					{
						break;
					}
				}
			}

			HIDE_CURSOR;

			switch (vi_mode)
			{
				case VI_COMMAND_MODE:
					save_command(cur_buf, user_buf, &undo_data[1]);

					switch (ch)
					{
						case 'I':
							begin_line(&cur_buf,user_buf);
						case 'i':
							vi_mode = VI_INSERT_MODE;
							insert_count = 0;
							if (pnode) pnode = 0;
							break;

						case 'A':
							end_line(&cur_buf);
						case 'a':
							if (col != 1 || *cur_buf != NEWLINE_CHAR)
								next_char(&cur_buf);
							vi_mode = VI_INSERT_MODE;
							insert_count = 0;
							if (pnode) pnode = 0;
							break;

						case 'O':
							Open_line(&cur_buf,user_buf);
							vi_mode = VI_INSERT_MODE;
							insert_count = 0;
							if (pnode) pnode = 0;
							break;

						case 'o':
							open_line(&cur_buf,user_buf);
							vi_mode = VI_INSERT_MODE;
							insert_count = 0;
							if (pnode) pnode = 0;
							break;

						case 'd':
							vi_mode = VI_DELETE_MODE;
							break;

						case 'R':
							vi_mode = VI_REPLACE_MODE;
							/* init replace mechanism */
							process_replace(0, '\0', &cur_buf, user_buf); 
							break;

						case 'r':
							vi_mode = VI_REPLACE_1_CHAR_MODE;
							break;

						case 'C':
							del_end_line(&cur_buf,user_buf);
							if (col != 1 || *cur_buf != NEWLINE_CHAR)
								next_char(&cur_buf);
							if (pnode) pnode = 0;
							vi_mode = VI_INSERT_MODE;
							insert_count = 0;
							break;

						case 'c':
							vi_mode = VI_CHANGE_MODE;
							break;

						case '/':
							if (pnode == 0)
								save_command(cur_buf, user_buf,
											 &current_command);
							strcpy(user_buf,SEARCH_PROMPT);
							reset_cols(user_buf);
							refresh(&cur_buf, user_buf);

							vi_mode = VI_SEARCH_MODE;
							insert_count = 0;
							break;

						case '.':
							if (*repeat_cmd_buf)
							{
								repeat_cmd_ptr = repeat_cmd_buf;
								repeat_cmd_flag = 1;
							}
							break;

						default:
							for (i = 0; i < NUM_CMDS; ++i)
							{
								if (cmds[i].vi == ch)
								{
									cmds[i].func(&cur_buf, user_buf);
									break;
								}
							}
						break;
					} /* switch (ch) */
					break;

				case VI_INSERT_MODE:
					if (ch == VI_NEWLINE_CHAR) ch = NEWLINE_CHAR;
					switch (ch)
					{
						case DEL:
						case CTRL_H:
							if (insert_count)
							{
								del_prev_char(&cur_buf, user_buf);
								insert_count--;
							}
							break;

						case ESC:
							if (col != 1) 
							{
								EDT_DBG(("hereee\n"));
								prev_char(&cur_buf, user_buf);
							}
							vi_mode = VI_COMMAND_MODE;
							break;

						default:
							if( !double_ch_flag )
							{
								insert_ch(&cur_buf, user_buf, ch, '\0');
								insert_count++;
							}
							else
							{
								insert_ch(&cur_buf, user_buf, ch, double_ch);
								insert_count += 2;
							}
							break;
					} /* switch (ch) */
					break;

				case VI_SEARCH_MODE:
					switch (ch)
					{
						case DEL:
						case CTRL_H:
							if (insert_count)
							{
								del_prev_char(&cur_buf, user_buf);
								insert_count--;
							}
							break;

						case NEWLINE_CHAR:
							len = strlen(user_buf + SEARCH_PROMPT_LEN);
							if (len) 
							{
								search_string =
									(char *)realloc(search_string, len + 1);
								strcpy(search_string,
									user_buf + SEARCH_PROMPT_LEN);
							}
							if (prev_cmd_search(&cur_buf,user_buf) == 0)
							{
								/* no command was found */
								undo_data[0] = undo_data[1];
								undo(&cur_buf, user_buf);
							}
							vi_mode = VI_COMMAND_MODE;
							break;

						default:
							if( !double_ch_flag )
							{
								insert_ch(&cur_buf, user_buf, ch, '\0');
								insert_count++;
							}
							else
							{
								insert_ch(&cur_buf, user_buf, ch, double_ch);
								insert_count += 2;
							}
							break;
					} /* switch (ch) */
					break;

				case VI_DELETE_MODE:
					process_delete_change(vi_mode, ch, &cur_buf, user_buf);
					if (pnode) pnode = 0;
					vi_mode = VI_COMMAND_MODE;
					break;

				case VI_CHANGE_MODE:
					if (process_delete_change(vi_mode, ch, &cur_buf, user_buf))
					{
						if (ch == '$')
						{
							if (col != 1 || *cur_buf != NEWLINE_CHAR)
								next_char(&cur_buf);
						}
						if (pnode) pnode = 0;
						vi_mode = VI_INSERT_MODE;
						insert_count = 0;
					}
					else vi_mode = VI_COMMAND_MODE;
					break;

				case VI_REPLACE_MODE:
					if (ch == VI_NEWLINE_CHAR) ch = NEWLINE_CHAR;
					if (process_replace(ch, double_ch, &cur_buf, user_buf))
					{
						if (pnode) pnode = 0;
						vi_mode = VI_COMMAND_MODE;
					}
					break;

				case VI_REPLACE_1_CHAR_MODE:
					if (ch == VI_NEWLINE_CHAR) ch = NEWLINE_CHAR;
					process_replace_one_char(ch, double_ch, &cur_buf, user_buf);
					if (pnode) pnode = 0;
					vi_mode = VI_COMMAND_MODE;
					break;

				default:
					break;

			} /* switch (vi_mode) */


			if (!repeat_cmd_flag)
			{
				*cmd_ptr++ = ch;
				*cmd_ptr = 0;
			}

			if (vi_mode == VI_COMMAND_MODE)
			{
				/* 	a command was just executed, check if buffer changed
					if so, save buffer for undo and save command for '.'  */

				if (check_undo(user_buf) && !repeat_cmd_flag)
				{
					repeat_cmd_buf = (char *)realloc(repeat_cmd_buf,
													 strlen(cmd_buf) + 1);
					strcpy(repeat_cmd_buf,cmd_buf);
				}

				cmd_ptr = cmd_buf;
				*cmd_ptr = 0;
			}
		}
		SHOW_CURSOR;
	}

	/* 
	**	Check if cmd is "r"
	*/
	if (!strcmp(user_buf,"r"))
	{
		prev_cmd(&cur_buf, user_buf);
	}
	else if (!strncmp(user_buf,"r ",2))
	{
		char *ptr;

		ptr = user_buf + 2;
		if (*ptr) 
		{
			search_string = (char *)realloc(search_string, strlen(ptr) + 1);
			strcpy(search_string, ptr);
		}
		if (prev_cmd_search(&cur_buf,user_buf) == 0)
		{
			printf("\nRIS: %s: not found",ptr);
			strcpy(user_buf,"");
		}
	}

	SET_CURSOR(max_row, end_col[row - home_row]);

	EDT_DBG(("1>> user_buf=<%s>\n", user_buf));

	putchar('\n');

	RISuco_reset_terminal();

	if (repeat_cmd_buf)
	{
		free(repeat_cmd_buf);
		repeat_cmd_buf = NULL;
	}

	if (ch == EOF || ch == '')
	{
#if defined(unix)
		if (save_errno != EINTR) return(0);
#endif
		*user_buf = 0;
	}

	/* save the command in the history file */
	command_push(user_buf, 1);

	return(user_buf);
}

/******************************************************************************/

extern int EDT_init(
	char *editor_style)
{
	int len;
	char *s;
	FILE *fptr;
#if defined(WIN32)
	BOOL bSuccess;
	CONSOLE_SCREEN_BUFFER_INFO info;
#if 0
	DWORD dwMode;
#endif
	CONSOLE_CURSOR_INFO cci = {100, FALSE};
#endif
#if defined(DOS)
	struct videoconfig v1;
#endif

	EDT_DBG(("EDT_init(editor_style=<%s>)\n", editor_style));

	if (editor_style && *editor_style)
	{
		EDT_set_edit_style(editor_style);
	}

#if defined(WIN32)
#if 0
	/* free the console and immediately allocate a new one. This is done so */
	/* that when debugging under ntsd, the application output will not be */
	/* intermingled with the debugger output. This section can be removed */
	/* without any change in the behavior of this program */
	bSuccess = FreeConsole();
	/* C run-time output will not work from now on! */
	if (!bSuccess)
	{
		Beep(600, 500);  /* can't output an error message! */
		return(1);
	}
	bSuccess = AllocConsole();
	if (!bSuccess)
	{
		Beep(600, 500);  /* can't output an error message! */
		return(2);
	}
#endif
	bSuccess = SetConsoleTitle("RIS Interactive Utility");
	PERR(bSuccess, "SetConsoleTitle");

	/* get the standard handles */
	hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
	PERR(hStdOut != INVALID_HANDLE_VALUE, "GetStdHandle");
	hStdIn = GetStdHandle(STD_INPUT_HANDLE);
	PERR(hStdIn != INVALID_HANDLE_VALUE, "GetStdHandle");

#if 0
	/* set up mouse and window input */
	bSuccess = GetConsoleMode(hStdIn, &dwMode);
	PERR(bSuccess, "GetConsoleMode");
	/* when turning off ENABLE_LINE_INPUT, you MUST also turn off */
	/* ENABLE_ECHO_INPUT. */
	bSuccess = SetConsoleMode(hStdIn, (dwMode & ~(ENABLE_LINE_INPUT |
		ENABLE_ECHO_INPUT)) | ENABLE_WINDOW_INPUT | ENABLE_MOUSE_INPUT);
	PERR(bSuccess, "SetConsoleMode");
#endif

	bSuccess = GetConsoleScreenBufferInfo(hStdOut, &info);
	PERR(bSuccess, "GetConsoleScreenBufferInfo");
	WINDOW_ROWS = info.dwSize.Y - 1;
	WINDOW_COLS = info.dwSize.X - 1;
#endif
#if defined(DOS)
    _getvideoconfig(&v1);
	WINDOW_ROWS = v1.numtextrows;
	WINDOW_COLS = v1.numtextcols-1;
#endif

	if ((s = getenv("LINES")) == NULL)
	{
		max_row = WINDOW_ROWS;
	}
	else if ((max_row = atoi(s)) <= 0)
	{
		max_row = WINDOW_ROWS;
	}

	if ((s = getenv("COLUMNS")) == NULL)
	{
		max_col = WINDOW_COLS;
	}
	else if ((max_col = atoi(s)) <= 0)
	{
		max_col = WINDOW_COLS;
	}

	max_col -= PROMPT_LEN;

	if( max_row < 1 ||  max_col < 7 )
	{
		EDT_DBG(("EDT_init: returning 1\n"));
		return 1;
	}

	EDT_DBG(("max_row:%d max_col:%d\n", max_row, max_col));

	end_col = (int *)malloc((RIS_MAX_STMT_LEN/max_col) * sizeof(int));

	RISuco_set_terminal_noecho_raw();

	SET_CURSOR_REAL(max_row, 1);
	CLR_TO_EOL;
	fflush(stdout);

	RISuco_reset_terminal();

	filename = getenv("RIS_HFILE");
	if (!filename)
	{
		filename = getenv("HOME");
		if (filename)
		{
			int len;

			len = strlen(filename);
			if (len)
			{
				if (filename[len - 1] == PATH_CHAR)
				{
					sprintf(filebuf, "%s%s", filename, RIS_CMD_FILE);
				}
				else
				{
					sprintf(filebuf, "%s%c%s", filename, PATH_CHAR,
						RIS_CMD_FILE);
				}
				filename = filebuf;
			}
			else
			{
				filename = RIS_CMD_FILE;
			}
		}
		else
		{
			filename = RIS_CMD_FILE;
		}
	}
	else if (!*filename) 	/* indicates history not wanted */
	{
		EDT_DBG(("EDT_init: returning 0\n"));
		return 0;
	}

	/*
	**	load_old_cmds
	*/
	fptr = fopen(filename, "r");
	if (!fptr)
	{
		printf("Creating new ris history file in \"%s\"\n", filename);

		EDT_DBG(("EDT_init: returning 0\n"));
		return 0;
	}

	while ((fscanf(fptr, "%d", &len) != EOF) && len)
	{
		if (len <= 0) break;
		s = (char *) malloc(len + 1);
		if (!s) break;
		fread(s, len, 1, fptr);
		s[len] = 0;
		command_push(s, 0);
		len = 0;
	}
	fclose(fptr);

	EDT_DBG(("EDT_init: returning 0\n"));
	return 0;
}

/******************************************************************************/

extern void EDT_terminate()
{
	int len, count;
	FILE *fptr;
	int i = 0;

	RISuco_reset_terminal();

	/* save commands */

	if (!*filename) 	/* indicates history not wanted */
	{
		return;
	}

	fptr = fopen(filename, "w");
	if (!fptr)
	{
		printf("Could not open history file \"%s\" for writing\n", filename);
		return;
	}

	count = MAX_SAVE_CMDS;
	pnode = 0;

	while (pop()) i++;

	while(i > MAX_SAVE_CMDS)
	{
		pip();
		i--;
	}

	do
	{
		if (pnode)
		{
			len = strlen(pnode->s);
			fprintf(fptr, "%d%s", len, pnode->s);
		}
		else break;
	} while (pip() && count--);

	fclose(fptr);
}

/******************************************************************************/
