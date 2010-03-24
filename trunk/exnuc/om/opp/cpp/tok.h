#ifndef TOK_D_INCLUDED
#define TOK_D_INCLUDED	1

#include <stddef.h>

struct cpp_token
 {
  int typ;			/* token type */
  struct cpp_token *flink;	/* internal use by cpp */
  struct cpp_token *blink;	/* internal use by cpp */
  char *filename;		/* pointer to string */
  short line_no;		/* position in file starting at 1 */
  short pol; 			/* position on line starting at 1 */
  char constr[1];		/* text of token */
 };


struct stripped_tok
 {
  int typ;			/* token type */
  char *filename;		/* pointer to string */
  int line_no;			/* position in file starting at 1 */
  int pol; 			/* position on line starting at 1 */
  union				/* union of constant types */
   {
    double flconst;		/* floating point constant */
    long intconst;		/* integer constant */
    char charconst;		/* character constant */
    wchar_t wcharconst;		/* wide character constant */
   } body;
 };


/*   fields typ, filename, line_no, and pol are valid for every token. */

#define TOK_EOF 		0x00000000
#define TOK_POUND		'#'
#define TOK_SEMI		';'
#define TOK_LEFT_CURLY		'{'
#define TOK_RIGHT_CURLY		'}'
#define TOK_COMMA		','
#define TOK_COLEN		':'
#define TOK_LEFT_ROUND		'('
#define TOK_RIGHT_ROUND		')'
#define TOK_LEFT_SQUARE		'['
#define TOK_RIGHT_SQUARE	']'
#define TOK_STAR		'*'
#define TOK_PERIOD		'.'
#define TOK_AND			'&'
#define TOK_MINUS		'-'
#define TOK_NOT			'!'
#define TOK_SQUIG		'~'
#define TOK_DIVIDE		'/'
#define TOK_MOD			'%'
#define TOK_PLUS		'+'
#define TOK_LESS		'<'
#define TOK_GREATER		'>'
#define TOK_HAT			'^'
#define TOK_OR			'|'
#define TOK_QUESTION		'?'
#define TOK_EQUAL		'='
#define TOK_BACKLASH		'\\'
#define TOK_NEW_LINE		'\n'
#define TOK_BASE		0x00000100	/* never returned */
#define TOK_POINTER		(TOK_BASE + 1)
#define TOK_PLUS_PLUS		(TOK_BASE + 2)
#define TOK_MINUS_MINUS		(TOK_BASE + 3)
#define TOK_SHIFT_LEFT		(TOK_BASE + 4)
#define TOK_SHIFT_RIGHT		(TOK_BASE + 5)
#define TOK_LESS_EQUAL		(TOK_BASE + 6)
#define TOK_GREATER_EQUAL	(TOK_BASE + 7)
#define TOK_EQUAL_EQUAL		(TOK_BASE + 8)
#define TOK_NOT_EQUAL		(TOK_BASE + 9)
#define TOK_AND_AND		(TOK_BASE + 10)
#define TOK_OR_OR		(TOK_BASE + 11)
#define TOK_PLUS_EQUAL		(TOK_BASE + 12)
#define TOK_MINUS_EQUAL		(TOK_BASE + 13)
#define TOK_TIMES_EQUAL		(TOK_BASE + 14)
#define TOK_DIV_EQUAL		(TOK_BASE + 15)
#define TOK_MOD_EQUAL		(TOK_BASE + 16)
#define TOK_RIGHT_SHIFT_EQUAL	(TOK_BASE + 17)
#define TOK_LEFT_SHIFT_EQUAL	(TOK_BASE + 18)
#define TOK_AND_EQUAL		(TOK_BASE + 19)
#define TOK_HAT_EQUAL		(TOK_BASE + 20)
#define TOK_OR_EQUAL		(TOK_BASE + 21)

/* additional field constr */
#define TOK_ID			(TOK_BASE + 22)
#define TOK_STRING_CONSTANT	(TOK_BASE + 23)

/* additional fields body.charconst, and constr */
#define TOK_CHAR_CONSTANT	(TOK_BASE + 24)

/* additional fields body.flconst, and constr */
#define TOK_FLOAT_CONSTANT	(TOK_BASE + 25)

/* additional fields body.intconst, and constr */
#define TOK_INT_CONSTANT	(TOK_BASE + 26)

#define TOK_NULL		(TOK_BASE + 27)
#define TOK_BACKLASH_NL		(TOK_BASE + 28)

#define TOK_SQOINTER		(TOK_BASE + 29)

#define TOK_CONCAT		(TOK_BASE + 30)

#define TOK_ELLIPSIS		(TOK_BASE + 31)

#define TOK_WCHAR_CONSTANT	(TOK_BASE + 32)

#define TOK_ARGSUSED		(TOK_BASE + 33)

extern struct cpp_token *token_malloc();
extern void token_unpack();
extern struct cpp_token *cpp_dupe_tok();

#endif
