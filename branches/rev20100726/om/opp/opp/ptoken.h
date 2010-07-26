/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* ptoken.h - parser tokens						*/
/*									*/
/* Paul L. Hammond							*/
/* December 18, 1986							*/
/*									*/
/* This structure is used in stead of cpp_token to save memory for	*/
/* parse tree building within opp.  This saves 8 bytes per token.	*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#ifndef PTOKEN_INCLUDED
#define PTOKEN_INCLUDED

struct pnode_token /* 16 bytes minimum */
 {
  int typ;			/* token type */
  char *filename;		/* pointer to string */
  short line_no;		/* position in file starting at 1 */
  short pol; 			/* position on line starting at 1 */
  char constr[1];		/* text of token */
 };

extern struct pnode_token *pnode_token_malloc();
/* in kutil.c - copys token from active_stream */

#endif
