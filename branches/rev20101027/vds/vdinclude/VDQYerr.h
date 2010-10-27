/* $Id: VDQYerr.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdinclude / VDQYerr.h
 *
 * Description:
 *	VDquery return codes and error messages
 *	   return codes
 *		1	matching objects found
 *		0	no matching objects
 *	      < 0	syntax error
 *
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDQYerr.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1995/01/23  15:08:12  pinnacle
 * Created: vdinclude/VDQYerr.h by tlbriggs r#
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/16/95	tlb		created file
 * --------------------------------------------------------------------*/


#define IDENT_LEN 	80		/* maximum identifier length */

/*
 * Error values 
 */
#define QY_E_SYNTAX		-1	/* syntax error */
#define QY_E_IDENT_LEN		-2	/* identifier length > IDENT_LEN */

#define QY_E_NO_SELECT		-3	/* missing select keyword */
#define QY_E_NO_CLASS		-4	/* missing class name */
#define QY_E_NO_EXPR		-5	/* missing expression  */
#define QY_E_NO_OPER1		-6	/* missing first operand in expr */
#define QY_E_NO_OPER2		-7	/* missing 2nd operand in expr */
#define QY_E_NO_REL_OP		-8	/* missing relational operator */
#define QY_E_NO_LOG_OP		-9	/* missing logical operator */
#define QY_E_NO_R_PAREN		-10	/* missing right parenthesis */
#define QY_E_NO_L_PAREN		-11	/* missing left parenthesis */

#define QY_E_EXTRA_SELECT	-12	/* extra select keyword */
#define QY_E_EXTRA_WHERE	-13	/* extra where keyword */
#define QY_E_EXTRA_LOG_OP	-14	/* extra logical operator */
#define QY_E_EXTRA_REL_OP	-15	/* extra relational operator */
#define QY_E_EXTRA_SYMB		-16	/* extra symbols after query */


/* 
 * Error messages
 */
#define QY_EMSG_SYNTAX		"syntax error"
#define QY_EMSG_IDENT_LEN	"identifier length > 80" 

#define QY_EMSG_NO_SELECT	"missing select keyword"
#define QY_EMSG_NO_CLASS	"missing class name"
#define QY_EMSG_NO_EXPR		"missing expression "
#define QY_EMSG_NO_OPER1	"missing first operand in expr"
#define QY_EMSG_NO_OPER2	"missing 2nd operand in expr"
#define QY_EMSG_NO_REL_OP		"missing relational operator"
#define QY_EMSG_NO_LOG_OP	"missing logical operator"
#define QY_EMSG_NO_R_PAREN	"missing right parenthesis"
#define QY_EMSG_NO_L_PAREN	"missing left parenthesis"

#define QY_EMSG_EXTRA_SELECT	"extra keyword: select "
#define QY_EMSG_EXTRA_WHERE	"extra keyword: where"
#define QY_EMSG_EXTRA_LOG_OP	"extra logical operator"
#define QY_EMSG_EXTRA_REL_OP	"extra relational operator"
#define QY_EMSG_EXTRA_SYMB	"extra symbols after query" 

/* function to print query error messages */
extern char * qy_emsg ( int err);
