/* Do not alter this SPC information: $Revision: 1.2.3.1 $ */
/*
**	NAME:							parmatch.c
**	AUTHORS:						
**	CREATION DATE:					
**	ABSTRACT:
**		
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
#define parmatch_c
#include "comdebug.prt"
#include "comgtnme.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "parlex.prt"
#include "parmatch.prt"
#include "parutil.prt"
#include "sys.prt"
#include "comuni.prt"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

extern lex_s RISpar_match(
	int token,
	char *token_val,
	unsigned int error)
{
	lex_s return_value;

	PAR_DBG(("RISpar_match(token:%s token_val:<%s> error:%d)\n",
		RIScom_get_token_name(token), token_val, error));

	return_value.pos = RISpar_lex.pos;
	return_value.val = RISpar_lex.val;

	if (!RISpar_token) RISpar_get_next_token();

	if (token == RIS_TOK_SEMICOLON && RISpar_token != 0 && 
		RISpar_token != token)
	{
		PAR_DBG(("RISpar_match(): expected %s got %s<%s>\n",
			RIScom_get_token_name(token),
			RIScom_get_token_name(RISpar_token), RISpar_lex.val));

		sprintf(RIS_ERRMSGC, RIScom_umsg(RIS_E_EXPECTED_GOT) ,
			token_val, RISpar_got_string());

		RISpar_ERR_RETURN(error, RISpar_lex.pos);
	}

	if (!RISpar_token || token == RIS_TOK_SEMICOLON) RISpar_get_next_token();

	if ((token != RIS_TOK_SEMICOLON && RISpar_token != token) ||
		(token == RIS_TOK_SEMICOLON && RISpar_token != 0 && RISpar_token != token))
	{
	    if (!(token == RIS_TOK_CHAR_STR_LIT_STB && RISpar_token == RIS_TOK_CHAR_STR_LIT))
            { 
		PAR_DBG(("RISpar_match(): expected %s got %s<%s>\n",
			RIScom_get_token_name(token),
			RIScom_get_token_name(RISpar_token), RISpar_lex.val));

		sprintf(RIS_ERRMSGC, RIScom_umsg(RIS_E_EXPECTED_GOT) ,
			token_val, RISpar_got_string());

		RISpar_ERR_RETURN(error, RISpar_lex.pos);
	    }
	}

	if (token != RIS_TOK_SEMICOLON && RISpar_token != 0)
	{
		return_value.pos = RISpar_lex.pos;
		return_value.val = RISpar_lex.val;
	}
	RISpar_token = 0;

	/*
	** delete trailing blanks - MELANIA M STEWART - TR#4399601154
	*/
        if (RISpar_lex.val && (token == RIS_TOK_CHAR_STR_LIT_STB))
	{
	    RIScom_unpad (RISpar_lex.val, strlen(RISpar_lex.val)) ;
            PAR_DBG (("Returning non-padded value <%s>\n", RISpar_lex.val)) ;
	}
	return return_value;
}

