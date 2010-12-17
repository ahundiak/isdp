/* Do not alter this SPC information: $Revision: 1.5.3.1 $ */
/*
**	NAME:							cpptrstr.c
**	AUTHORS:						Prasad Challa
**	CREATION DATE:					7/29/91
**	ABSTRACT:
**		The functions that generate string from the tree.
**	
**	REVISION HISTORY:	Dec. 93, Added changes for version 5.x - Sanju
**						Jan. 94, Added changes for shared dictionary - Sanju
**						Mar. 94, Added changes for Rename Objects - Hitesh
**						Oct. 94, Added changes for MSSQL data server -Radha
**						Mar. 95, Fixed bug in fix_char_literal_str for i18n. Paula
**								 (tr: 439500692 )
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "ris_err.h"
#include "rismem.h"
#include "commacro.h"
#include "cpp.h"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/
static int grant_flag=0;
static int select_flag=0;
static int close_paren_flag=0;

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define cpptrstr_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comgtnme.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comsqlms.prt"
#include "comwrap.prt"
#include "cpptrstr.prt"
#include "sys.prt"

#ifdef WIN32
#include "comuni.prt"
#endif

/*****************************************************************************/

extern void print_token(
	int token)
{
	char *cp;

	for(cp = RIScom_get_token_name(token); *cp; cp++)
	{
		if(*cp == '_')
		{
			if(token != RIS_TOK_RIS_BLOB && token != RIS_TOK_RIS_TEXT &&
			   token != RIS_TOK_RIS_DICT_DBNAME)
			{
				RIScom_fputs(" ", RIScpp_temp_file);
			}
			else
			{
				putc(*cp, RIScpp_temp_file);
			}
		}
		else
		{
			if (RIScom_isupper(*cp))
			{
				putc(RIScom_tolower(*cp), RIScpp_temp_file);
			}
			else
			{
				putc(*cp, RIScpp_temp_file);
			}
		}
	}
}

/*****************************************************************************/

static void RIScpp_tree_to_string(
	ristree * tp,
	int stmt_type)
{
	ristree *temp, *temp1, *temp2;
	char * string;

	if (!tp)
	{
		return;
	}

	CPP_DBG(("RIScpp_tree_to_string(tp:0x%x  stmt_type:%d)\ntp->tok:<%s>\n",
		tp, stmt_type, RIScom_get_token_name(tp->tok)));

	switch(tp->tok)
	{
		case RIS_TOK_DEFAULT_SCHEMA:
			RIScom_fputs("default schema ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_DECLARE_SCHEMA:
			RIScom_fputs("declare schema ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_GRANT_SCHEMA:
			RIScom_fputs("grant schema ", RIScpp_temp_file);
			if (tp->rhs->lhs && tp->rhs->lhs->tok == RIS_TOK_TO)
			{
				RIScom_fputs("to ", RIScpp_temp_file);
				if (tp->rhs->lhs->info.val)
				{
					RIScom_fputs(tp->rhs->lhs->info.val, RIScpp_temp_file);
				}
			}
		break;

		case RIS_TOK_GRANT_CONNECT:
			RIScom_fputs("grant connect ", RIScpp_temp_file);
			if (tp->rhs->lhs && tp->rhs->lhs->tok == RIS_TOK_TO)
			{
				RIScom_fputs("to ", RIScpp_temp_file);
				if (tp->rhs->lhs->info.val)
				{
					RIScom_fputs(tp->rhs->lhs->info.val, RIScpp_temp_file);
				}
			}
		break;

		case RIS_TOK_GRANT_RESOURCE:
			RIScom_fputs("grant resource ", RIScpp_temp_file);
			if (tp->rhs->lhs && tp->rhs->lhs->tok == RIS_TOK_TO)
			{
				RIScom_fputs("to ", RIScpp_temp_file);
				if (tp->rhs->lhs->info.val)
				{
					RIScom_fputs(tp->rhs->lhs->info.val, RIScpp_temp_file);
				}
			}
		break;

		case RIS_TOK_REVOKE_SCHEMA:
			RIScom_fputs("revoke schema ", RIScpp_temp_file);
			if (tp->rhs->lhs && tp->rhs->lhs->tok == RIS_TOK_FROM);
			{
				RIScom_fputs("from ", RIScpp_temp_file);
				if (tp->rhs->lhs->info.val)
				{
					RIScom_fputs(tp->rhs->lhs->info.val, RIScpp_temp_file);
				}
			}
		break;

		case RIS_TOK_REVOKE_CONNECT:
			RIScom_fputs("revoke connect ", RIScpp_temp_file);
			if (tp->rhs->lhs && tp->rhs->lhs->tok == RIS_TOK_FROM);
			{
				RIScom_fputs("from ", RIScpp_temp_file);
				if (tp->rhs->lhs->info.val)
				{
					RIScom_fputs(tp->rhs->lhs->info.val, RIScpp_temp_file);
				}
			}
		break;

		case RIS_TOK_REVOKE_RESOURCE:
			RIScom_fputs("revoke resource ", RIScpp_temp_file);
			if (tp->rhs->lhs && tp->rhs->lhs->tok == RIS_TOK_FROM);
			{
				RIScom_fputs("from ", RIScpp_temp_file);
				if (tp->rhs->lhs->info.val)
				{
					RIScom_fputs(tp->rhs->lhs->info.val, RIScpp_temp_file);
				}
			}
		break;

		case RIS_TOK_OPEN_SCHEMA:
			RIScom_fputs("open schema ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_CLOSE_SCHEMA:
			RIScom_fputs("close schema ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_CREATE_SCHEMA:
			if (tp->lhs && tp->lhs->tok == RIS_TOK_SECURE)
			{
				RIScom_fputs("create secure schema ", RIScpp_temp_file);
			}
			else
			{
	    		RIScom_fputs("create schema ", RIScpp_temp_file);
			}
       		RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_DROP_SCHEMA:
			RIScom_fputs("drop schema ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_ALTER_SCHEMA:
			RIScom_fputs("alter schema ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs->lhs, stmt_type);
			if (tp->rhs->rhs->lhs->tok != RIS_TOK_EXCLUDE &&
				tp->rhs->rhs->lhs->tok != RIS_TOK_INCLUDE &&
				tp->rhs->rhs->lhs->tok != RIS_TOK_SECURE)
			{
				RIScom_fputs(" modify", RIScpp_temp_file);
            }
            for (temp=tp->rhs->rhs;temp;temp=temp->rhs)
            {
                if (temp == tp->rhs->rhs)
                {
                    RIScom_fputs(" ", RIScpp_temp_file);
                }
                else
                {
                    RIScom_fputs(",", RIScpp_temp_file);
                }
                switch(temp->lhs->tok)
                {
                    case RIS_TOK_REMOTE:
                        RIScpp_tree_to_string(tp->rhs->rhs->lhs, stmt_type);
                    break;
                    case RIS_TOK_SECURE:
                        RIScom_fputs("to secure",RIScpp_temp_file);
                    break;
                    case RIS_TOK_USER:
                    case RIS_TOK_SCHEMA:
                        print_token(temp->lhs->tok);
                        RIScom_fputs(" password",RIScpp_temp_file);
                        if (temp->lhs->rhs && temp->lhs->rhs->info.val)
                        {
                            RIScom_fputs(" ",RIScpp_temp_file);
                            RIScom_fputs(temp->lhs->rhs->info.val, RIScpp_temp_file);
                        }
                    break;
                    case RIS_TOK_DB2:
                        fprintf(RIScpp_temp_file, 
							"db2 password from %s to %s",
							temp->lhs->rhs->lhs->info.val,
							temp->lhs->rhs->rhs->lhs->info.val);
                        if (temp->lhs->rhs->rhs->rhs &&
                            temp->lhs->rhs->rhs->rhs->lhs->tok == RIS_TOK_MODE)
                        {
                            fprintf(RIScpp_temp_file, " using mode %s",
                                temp->lhs->rhs->rhs->rhs->lhs->info.val);
                        }
                    break;
                    case RIS_TOK_INCLUDE:
                    case RIS_TOK_EXCLUDE:
                        /* temp == INCLUDE|EXCLUDE node */
                        print_token(temp->lhs->tok);
                        RIScom_fputs(" ",RIScpp_temp_file);
                        print_token(temp->lhs->rhs->tok);
                        RIScom_fputs(" ",RIScpp_temp_file);
						RIScpp_tree_to_string(temp->lhs->rhs->rhs, stmt_type);
#ifdef OLD
                        if (temp->lhs->rhs->rhs->lhs->tok == RIS_TOK_USR_NAME)
                        {
                        	RIScom_fputs(temp->lhs->rhs->rhs->lhs->info.val,
                         		RIScpp_temp_file);
                        	RIScom_fputs(".",RIScpp_temp_file);
                        	RIScom_fputs(temp->lhs->rhs->rhs->lhs->rhs->info.val,
                         		RIScpp_temp_file);
                        }
                        else
                        {
                        	RIScom_fputs(temp->lhs->rhs->rhs->lhs->info.val,
                         		RIScpp_temp_file);
                        }
						/* extern rename stuff */
						RIScpp_tree_to_string(temp->lhs->rhs->rhs->rhs, stmt_type);
#endif
                    break;
                    case RIS_TOK_OSUSER:
                        print_token(temp->lhs->tok);
                        RIScom_fputs(" ",RIScpp_temp_file);
                        RIScom_fputs(temp->lhs->info.val, RIScpp_temp_file);
                        if (temp->lhs->rhs && temp->lhs->rhs->info.val)
                        {
                            RIScom_fputs(".",RIScpp_temp_file);
                            RIScom_fputs(temp->lhs->rhs->info.val, RIScpp_temp_file);
                        }
                    break;
                    default:
                        CPP_ERR_RETURN(RIS_E_INTERNAL_ERROR,temp->lhs->pos);
					break;
				}
			}
		break;

		case RIS_TOK_CREATE_TABLE:
			RIScom_fputs("create table ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
#ifdef FULL_EXPANSION		
			RIScom_fputs(" (", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs->rhs->lhs, stmt_type);
			RIScom_fputs(")", RIScpp_temp_file);
#endif			
		break;

		case RIS_TOK_DECLARE_TABLE:
			RIScom_fputs("declare table ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
			RIScpp_tree_to_string(tp->lhs, stmt_type);
#ifdef FULL_EXPANSION		
			RIScom_fputs(" (", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs->rhs->lhs, stmt_type);
			RIScom_fputs(")", RIScpp_temp_file);
#endif			
		break;

		case RIS_TOK_UNDECLARE_TABLE:
			RIScom_fputs("undeclare table ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_DECLARE_VIEW:
			RIScom_fputs("declare view ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
			RIScpp_tree_to_string(tp->lhs, stmt_type);
#ifdef FULL_EXPANSION		
			RIScom_fputs(" (", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs->rhs->lhs, stmt_type);
			RIScom_fputs(")", RIScpp_temp_file);
#endif			
		break;

		case RIS_TOK_UNDECLARE_VIEW:
			RIScom_fputs("undeclare view ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_DECLARE_SUPERSCHEMA:
			RIScom_fputs("declare superschema ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_UNDECLARE_SUPERSCHEMA:
			RIScom_fputs("undeclare superschema ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_REDECLARE_SUPERSCHEMA:
			RIScom_fputs("redeclare superschema ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

        case RIS_TOK_SWAP:
            RIScom_fputs(" swap primary with", RIScpp_temp_file);
            RIScpp_tree_to_string(tp->rhs, stmt_type);
        break;

        case RIS_TOK_REPLACE:
            RIScom_fputs(" replace primary with", RIScpp_temp_file);
            RIScpp_tree_to_string(tp->rhs, stmt_type);
        break;

		case RIS_TOK_DROP:
			RIScom_fputs(" drop ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_NO_VERIFY:
			if (stmt_type == RIS_TOK_DECLARE_TABLE || 
				stmt_type == RIS_TOK_DECLARE_VIEW)
			{
				break;
			}
			else
			{
				RIScom_fputs(" no_verify ", RIScpp_temp_file);
			}
		break;

		case RIS_TOK_PARTIAL:
			RIScom_fputs(" with partial verify option ", RIScpp_temp_file);	
		break;

		case RIS_TOK_VERIFY:
			if (stmt_type == RIS_TOK_DECLARE_TABLE || 
				stmt_type == RIS_TOK_DECLARE_VIEW)
			{
				RIScom_fputs(" with verify option ", RIScpp_temp_file);	
			}
			else
			{
				RIScom_fputs(" verify", RIScpp_temp_file);
			}
		break;

		case RIS_TOK_PRIMARY:
		if (stmt_type == RIS_TOK_DECLARE_SUPERSCHEMA)
		{
			RIScom_fputs(" with primary ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		}
		else if (stmt_type == RIS_TOK_REDECLARE_SUPERSCHEMA)
		{
			RIScom_fputs(" primary ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		}
		break;

		case RIS_TOK_SECONDARY:
			RIScom_fputs(" secondary ", RIScpp_temp_file);
			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
				RIScpp_tree_to_string(temp->lhs, stmt_type);
				if(temp->rhs)
					RIScom_fputs(", ",RIScpp_temp_file);
			}
		break;

		/*'add' token is used for two different purposes, one as '+' and the
		other as 'add column' in alter schema statement. Because of that we
		are generating the string from tree manually, instead of using 
		recursion as in the other cases*/

		case RIS_TOK_ALTER_TABLE:
			RIScom_fputs("alter table ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs->lhs, stmt_type);
			RIScom_fputs(" ",RIScpp_temp_file);
			print_token(tp->rhs->rhs->lhs->tok);
			RIScom_fputs(" ",RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs->rhs->lhs->lhs, stmt_type);
		break;

		case RIS_TOK_DROP_TABLE:
			RIScom_fputs("drop table ",RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_LOCK_TABLES:
			RIScom_fputs("lock tables ",RIScpp_temp_file);
			for(temp1=tp->rhs;temp1;temp1=temp1->rhs)
			{
				for(temp2=temp1->lhs->rhs->rhs; temp2; temp2=temp2->rhs)
				{
					RIScpp_tree_to_string(temp2->lhs, stmt_type);
					if(temp2->rhs)
						RIScom_fputs(", ",RIScpp_temp_file);
				}
				RIScom_fputs(" in ",RIScpp_temp_file);
				print_token(temp1->lhs->tok);
				RIScom_fputs(" mode",RIScpp_temp_file);
				if(temp1->rhs)
					RIScom_fputs(" ",RIScpp_temp_file);
			}
		break;

		case RIS_TOK_CREATE_INDEX:
			if (tp->rhs && tp->rhs->lhs->tok == RIS_TOK_UNIQUE)
			{
				RIScom_fputs("create unique index ", RIScpp_temp_file);
				RIScpp_tree_to_string(tp->rhs->rhs, stmt_type);
			}
			else
			{
	    		RIScom_fputs("create index ", RIScpp_temp_file);
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
		break;

		case RIS_TOK_INDEX_NAME:
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
		break;			

		case RIS_TOK_CREATE_VIEW:
			RIScom_fputs("create view ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_DROP_VIEW:
			RIScom_fputs("drop view ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_DROP_INDEX:
			RIScom_fputs("drop index ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_GRANT_ON_TABLE:
			if(!grant_flag)
			{
				RIScom_fputs("grant ", RIScpp_temp_file);
				grant_flag=1;
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
			break;
		case RIS_TOK_GRANT:
/* This token was used in 4.*.*.* to represent the 'grant' privilege.
	In 5.*.*.* there are seperate tokens for GRANT_SCHEMA, GRANT_ON_TABLE
	etc. So, this GRANT token is used to represent the 'with grant option'
	that is specific to GRANT_ON_TABLE. -Radha 05/05/94
*/

			RIScom_fputs(" with grant option", RIScpp_temp_file);
			break;

		case RIS_TOK_REVOKE_ON_TABLE:
			RIScom_fputs("revoke ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_COMMIT:
			RIScom_fputs("commit",RIScpp_temp_file);
			if (tp->rhs->lhs->tok == RIS_TOK_AUTH_ID)
			{
				RIScom_fputs(" for ",RIScpp_temp_file);
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
		break;

		case RIS_TOK_ROLLBACK:
			RIScom_fputs("rollback",RIScpp_temp_file);
			if (tp->rhs->lhs->tok == RIS_TOK_AUTH_ID)
			{
				RIScom_fputs(" for ",RIScpp_temp_file);
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
		break;

		case RIS_TOK_EXEC:
			RIScom_fputs("exec ",RIScpp_temp_file);
			print_token(tp->rhs->tok);
			RIScom_fputs(" ",RIScpp_temp_file);
			string = fix_char_literal_str(tp->rhs->info.val,0);
			RIScom_fputs(string,RIScpp_temp_file);
		break;

		case RIS_TOK_DEFINE:
			RIScom_fputs("\n", RIScpp_temp_file);
			RIScom_fputs("#define ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_UNDEF:
			RIScom_fputs("\n", RIScpp_temp_file);
			RIScom_fputs("#undef ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_IFDEF:
			RIScom_fputs("ifdef ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_IFNDEF:
			RIScom_fputs("ifndef ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_ELSE:
			RIScom_fputs("else ", RIScpp_temp_file);
		break;

		case RIS_TOK_ENDIF:
			RIScom_fputs("endif ", RIScpp_temp_file);
		break;

		case RIS_TOK_INCLUDE:
			RIScom_fputs("include ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_FILENAME:
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
		break;

		case RIS_TOK_UNDEFNAME:
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
		break;

		case RIS_TOK_IFDEFNAME:
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
		break;

		case RIS_TOK_IFNDEFNAME:
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
		break;

		case RIS_TOK_BEGIN_DECLARE:
			RIScom_fputs("begin declare section", RIScpp_temp_file);
		break;

		case RIS_TOK_HOST_VAR_DEF:
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_VIRTUAL:
			RIScom_fputs("virtual ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_AS:
		case RIS_TOK_EXTERN:
			RIScom_fputs(" ",RIScpp_temp_file);
			print_token(tp->tok);
			RIScom_fputs(" ",RIScpp_temp_file);
			if (tp->rhs)
			{
				/* extern rename stuff */
				RIScpp_tree_to_string(tp->rhs->lhs, stmt_type);
				if (tp->rhs->rhs)
				{
                	/* Columns are also renamed */
                   	/* This is true of view and table only */
					RIScpp_tree_to_string(tp->rhs->rhs, stmt_type);
				}
			}
		break;

		case RIS_TOK_USR_NAME:
            RIScom_fputs(tp->info.val, RIScpp_temp_file);
            if (tp->rhs)
            {
            	RIScom_fputs(".",RIScpp_temp_file);
            	RIScom_fputs(tp->rhs->info.val, RIScpp_temp_file);
            }
		break;

		case RIS_TOK_AUTO:
		case RIS_TOK_REGISTER:
		case RIS_TOK_STATIC:
			print_token(tp->tok);
			RIScom_fputs(" ",RIScpp_temp_file);
		break;

		case RIS_TOK_HOST_TYPE_SPEC_LIST:
			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
				print_token(temp->lhs->tok);
				if(temp->rhs)
					RIScom_fputs(" ", RIScpp_temp_file);
			}
		break;

		case RIS_TOK_HOST_VAR_LIST:
			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
				RIScpp_tree_to_string(temp->lhs, stmt_type);
				if(temp->rhs)
					RIScom_fputs(", ",RIScpp_temp_file);
			}
		break;

		case RIS_TOK_HOST_VAR:
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_HOST_IDENT:
			RIScom_fputs(" ",RIScpp_temp_file);
			if(stmt_type==RIS_TOK_WHENEVER)
				RIScom_fputs(":", RIScpp_temp_file);
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
		break; 

		case RIS_TOK_STAR_LIST:
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_ARRAY_SPEC_LIST:
			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
				RIScom_fputs("[", RIScpp_temp_file);
				RIScpp_tree_to_string(temp->lhs, stmt_type);
				RIScom_fputs("]", RIScpp_temp_file);
			}
		break;

		case RIS_TOK_END_DECLARE:
			RIScom_fputs("end declare section", RIScpp_temp_file);
		break;

		case RIS_TOK_DEBUG:
			RIScom_fputs("debug ", RIScpp_temp_file);
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
		break;

		case RIS_TOK_PREPARE:
			RIScom_fputs(tp->rhs->rhs->lhs->info.val, RIScpp_temp_file);
#ifdef FULL_EXPANSION 
			RIScom_fputs("prepare ",RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
#endif
		break;

		case RIS_TOK_STMT_ID:
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
			if(tp->rhs)
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			if(tp->lhs)
				RIScpp_tree_to_string(tp->lhs, stmt_type);
		break;

		case RIS_TOK_WHENEVER:
			RIScom_fputs("whenever ",RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_DESCRIBE_INPUT:
			RIScom_fputs("describe input ",RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_DESCRIBE_OUTPUT:
			RIScom_fputs("describe output ",RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_REPORT_ERROR:
			RIScom_fputs("report error ",RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_REPORT_SS_ERROR:
			RIScom_fputs("report superschema error ",RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_NOT_FOUND:
			RIScom_fputs("not found ", RIScpp_temp_file);
		break;

		case RIS_TOK_USING:
			RIScom_fputs(" using ", RIScpp_temp_file);
			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
				if(temp->lhs)
				{
					RIScpp_tree_to_string(temp->lhs, stmt_type);
					if(temp->rhs)
						RIScom_fputs(" ,", RIScpp_temp_file);
				}
				else
					RIScpp_tree_to_string(temp, stmt_type);
			}
		break;

		case RIS_TOK_DESC_NAME:
			RIScom_fputs("descriptor ", RIScpp_temp_file);
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
		break;

		case RIS_TOK_GOTO:
			RIScom_fputs("goto", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_SQLERROR:
			RIScom_fputs("sqlerror ", RIScpp_temp_file);
		break;

		case RIS_TOK_CONTINUE:
			RIScom_fputs("continue", RIScpp_temp_file);
		break;

		case RIS_TOK_DECLARE:
#ifdef FULL_EXPANSION
			RIScom_fputs("declare ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
			if(tp->lhs)
				RIScpp_tree_to_string(tp->lhs, stmt_type);
#endif
			RIScpp_tree_to_string(tp->rhs->rhs, stmt_type);
		break;

		case RIS_TOK_OPEN:
			RIScom_fputs("open ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_CLOSE:
			RIScom_fputs("close ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_FETCH:
			RIScom_fputs("fetch ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_EXECUTE:
			RIScom_fputs("execute ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_EXECUTE_IMMEDIATE:
			RIScom_fputs("execute immediate ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_CLEAR:
			RIScom_fputs("clear ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_CURSOR_NAME:
			if(stmt_type==RIS_TOK_CLEAR)
				RIScom_fputs("cursor ", RIScpp_temp_file);
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
			RIScom_fputs(" ", RIScpp_temp_file);
			if(stmt_type==RIS_TOK_DECLARE)
				RIScom_fputs("cursor for ", RIScpp_temp_file);
		break;

		case RIS_TOK_SELECT:
			if(!select_flag)
			{
				if(stmt_type==RIS_TOK_CREATE_VIEW)
				{
					RIScom_fputs(" as ",RIScpp_temp_file);
				}
				RIScom_fputs("select ",RIScpp_temp_file);
			}
			else
			{
				RIScom_fputs("(select ",RIScpp_temp_file);
				close_paren_flag++;
			}
			RIScpp_tree_to_string(tp->rhs, stmt_type);
			if(tp->lhs)
			{
				RIScpp_tree_to_string(tp->lhs, stmt_type);
			}
			if(close_paren_flag)
			{
				RIScom_fputs(")",RIScpp_temp_file);
				close_paren_flag--;
			}
		break;

		case RIS_TOK_SELECT_EXPR:
		case RIS_TOK_SELECT_SELECT:
			if(tp->lhs)
			{
				RIScpp_tree_to_string(tp->lhs, stmt_type);
			}
			if(tp->rhs)
			{
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
		break;

		case RIS_TOK_UNION_SELECT:
			RIScom_fputs("union select ",RIScpp_temp_file);
			if(tp->rhs)
			{
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
		break;

		case RIS_TOK_UNION_ALL_SELECT:
			RIScom_fputs("union all select ",RIScpp_temp_file);
			if(tp->rhs)
			{
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
		break;

		case RIS_TOK_INSERT:
			RIScom_fputs("insert into ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_UPDATE:
			RIScom_fputs("update ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_DELETE:
			RIScom_fputs("delete from ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_SET:
			RIScom_fputs("set ", RIScpp_temp_file);
			if (tp->rhs->tok == RIS_TOK_MODE 
			 || tp->rhs->tok == RIS_TOK_DATABASE
			 || tp->rhs->tok == RIS_TOK_TRANSACTION
			 || tp->rhs->tok == RIS_TOK_NETWORK)
			{
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
			else
			{
				for(temp=tp->rhs; temp; temp=temp->rhs)
				{
					RIScpp_tree_to_string(temp->lhs, stmt_type);
					if(temp->rhs)
						RIScom_fputs(" ,", RIScpp_temp_file);
				}
			}
		break;

		case RIS_TOK_TRANSACTION:
			RIScom_fputs("transaction ",RIScpp_temp_file);
			print_token(tp->rhs->lhs->tok);
			RIScom_fputs(" ", RIScpp_temp_file);
			print_token(tp->rhs->lhs->rhs->tok);
		break;

		case RIS_TOK_MODE:
			RIScom_fputs("mode ",RIScpp_temp_file);
			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
				RIScom_fputs(" ", RIScpp_temp_file);
				print_token(temp->lhs->tok);
				RIScom_fputs(" ", RIScpp_temp_file);
				print_token(temp->lhs->rhs->tok);
			}
		break;

		case RIS_TOK_NETWORK:
			RIScom_fputs("network verification ",RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_PARAM_LIST:
			if(tp->rhs->rhs)
			{
				for(temp=tp->rhs; temp; temp=temp->rhs)
				{
					if(temp->lhs)
					{
						RIScpp_tree_to_string(temp->lhs, stmt_type);
						if(temp->rhs)
							RIScom_fputs(",", RIScpp_temp_file);
					}
				}
			}
			else
			{
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
		break;

		case RIS_TOK_INTERVAL:
			RIScom_fputs(" timestamp interval ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;	

		case RIS_TOK_INITIAL_TIMEOUT:
			RIScom_fputs(" initial timeout ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;	

		case RIS_TOK_TOLERANCE:
			RIScom_fputs(" timestamp tolerance ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;	

		case RIS_TOK_BUFFER_SIZE:
			RIScom_fputs(" buffer full size ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;	

		case RIS_TOK_BUFFER_TIMEOUT:
			RIScom_fputs(" buffer full timeout ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;	

		case RIS_TOK_RESPONSE_INTERVAL:
			RIScom_fputs(" response interval ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;	

		case RIS_TOK_VALUES:
			if(stmt_type != RIS_TOK_INSERT)
				RIScom_fputs(" (", RIScpp_temp_file);
			else
				RIScom_fputs(" values (", RIScpp_temp_file);

			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
				RIScpp_tree_to_string(temp->lhs, stmt_type);
				if(temp->rhs)
					RIScom_fputs(", ", RIScpp_temp_file);
			}
				RIScom_fputs(")", RIScpp_temp_file);
		break;

        case RIS_TOK_INTO:
			if(stmt_type==RIS_TOK_SELECT)
				break;
			else
			{
            	RIScom_fputs(" into ",RIScpp_temp_file);
				for(temp=tp->rhs; temp; temp=temp->rhs)
				{
					RIScpp_tree_to_string(temp->lhs, stmt_type);
					if(temp->rhs)
						RIScom_fputs(", ", RIScpp_temp_file);
				}
			}
        break;

		case RIS_TOK_VAR_NAME:
			if(stmt_type==RIS_TOK_REPORT_ERROR)
				RIScom_fputs("into ", RIScpp_temp_file);
#ifdef FULL_EXPANSION
			if(stmt_type==RIS_TOK_PREPARE)
				RIScom_fputs(" from ", RIScpp_temp_file);
            RIScom_fputs(":",RIScpp_temp_file);
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
			if(tp->rhs)
			{
				RIScpp_tree_to_string(tp->rhs, stmt_type);
				RIScom_fputs(" ",RIScpp_temp_file);
			}
			if(tp->lhs)
				RIScpp_tree_to_string(tp->lhs, stmt_type);
#endif

			RIScom_fputs("?", RIScpp_temp_file);
		break;

		case RIS_TOK_LIST:
			RIScpp_tree_to_string(tp->lhs, stmt_type);
			if (tp->rhs)
			{
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
		break;

		case RIS_TOK_EXACT_NUM_LIT:
			if(stmt_type!=RIS_TOK_HOST_VAR_DEF)
				RIScom_fputs(" ", RIScpp_temp_file);
			RIScom_fputs(tp->info.val, RIScpp_temp_file);

			/*asc of des for order by */
			if(tp->rhs)
			{
				if(stmt_type==RIS_TOK_CREATE_TABLE ||
				   stmt_type==RIS_TOK_ALTER_TABLE  ||
				   stmt_type==RIS_TOK_DECLARE_TABLE||
				   stmt_type==RIS_TOK_DECLARE_VIEW)
				{
					RIScom_fputs(", ", RIScpp_temp_file);
				}
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
		break;

		case RIS_TOK_APPROX_NUM_LIT:
		case RIS_TOK_CHAR_STR_LIT:
			if(stmt_type==RIS_TOK_VIRTUAL)
				RIScom_fputs(" as ", RIScpp_temp_file);
			string = fix_char_literal_str(tp->info.val,1);
			RIScom_fputs(string, RIScpp_temp_file);
		break;

/*
** We use this only for prepare and execute immediate statements. These
** statements are allowed to be delimited only by double quotes ("), unlike
** all the other statements in our riscpp (in all other cases we only allow
** single quote delimiters).
*/
		case RIS_TOK_C_CHAR_STR_LIT:
			string = fix_char_literal_str(tp->info.val,1);
			RIScom_fputs(string, RIScpp_temp_file);
		break;

		case RIS_TOK_VALUE_EXPR_LIST:
			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
				RIScpp_tree_to_string(temp->lhs, stmt_type);
				if(temp->rhs)
					RIScom_fputs(", ",RIScpp_temp_file);
			}
		break;

		case RIS_TOK_QUESTION:
			RIScom_fputs(" ? ", RIScpp_temp_file);
		break;

		case RIS_TOK_EQ:
		case RIS_TOK_ASGN:
			RIScpp_tree_to_string(tp->lhs, stmt_type);
			RIScom_fputs(" = ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_NE:
			RIScpp_tree_to_string(tp->lhs, stmt_type);
			RIScom_fputs(" <> ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_LT:
			RIScpp_tree_to_string(tp->lhs, stmt_type);
			RIScom_fputs(" < ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_GT:
			RIScpp_tree_to_string(tp->lhs, stmt_type);
			RIScom_fputs(" > ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_LE:
			RIScpp_tree_to_string(tp->lhs, stmt_type);
			RIScom_fputs(" <= ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_GE:
			RIScpp_tree_to_string(tp->lhs, stmt_type);
			RIScom_fputs(" >= ", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_SCHEMA_LIST:
			if(stmt_type == RIS_TOK_SET)
			{
				RIScom_fputs(" for ",RIScpp_temp_file);
			}
			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
				RIScpp_tree_to_string(temp->lhs, stmt_type);
				if(temp->rhs)
					RIScom_fputs(", ",RIScpp_temp_file);
			}
		break;


        case RIS_TOK_ADD:
			RIScom_fputs(" add ",RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
			break;

/* operators that may need parenthesis */

        case RIS_TOK_PLUS:
        case RIS_TOK_SUB:
        case RIS_TOK_MUL:
        case RIS_TOK_DIV:
        case RIS_TOK_OR:
        case RIS_TOK_AND:
        case RIS_TOK_UNARYMINUS:
        case RIS_TOK_NOT:
            if (tp->lhs)
            {
                if (RIScom_need_parens(tp->tok,tp->lhs->tok,'L'))
                {
                    RIScom_fputs("(", RIScpp_temp_file);
                    RIScpp_tree_to_string(tp->lhs, stmt_type);
                    RIScom_fputs(")", RIScpp_temp_file);
                }
                else
                {
                    RIScpp_tree_to_string(tp->lhs, stmt_type);
                }
            }
            switch(tp->tok)
            {
                case RIS_TOK_MUL:
                    RIScom_fputs(" *", RIScpp_temp_file);
                break;

                case RIS_TOK_DIV:
                    RIScom_fputs(" / ", RIScpp_temp_file);
                break;

                case RIS_TOK_PLUS:
                    RIScom_fputs(" + ", RIScpp_temp_file);
                break;

                case RIS_TOK_SUB:
                    RIScom_fputs(" - ", RIScpp_temp_file);
                break;

                case RIS_TOK_AND:
                case RIS_TOK_OR:
                    RIScom_fputs(" ", RIScpp_temp_file);
                    print_token(tp->tok);
                    RIScom_fputs(" ", RIScpp_temp_file);
                break;

                case RIS_TOK_NOT:
                    print_token(tp->tok);
                    RIScom_fputs(" ", RIScpp_temp_file);
                break;

                case RIS_TOK_UNARYMINUS:
                    RIScom_fputs("- ", RIScpp_temp_file);
                break;
            }
			if(tp->rhs)
			{
            	if (RIScom_need_parens(tp->tok,tp->rhs->tok,'R'))
            	{
               		RIScom_fputs("(", RIScpp_temp_file);
               		RIScpp_tree_to_string(tp->rhs, stmt_type);
               		RIScom_fputs(")", RIScpp_temp_file);
            	}
            	else 
            	{
               	    RIScpp_tree_to_string(tp->rhs, stmt_type);
            	}
			}
        break;

        case RIS_TOK_AVG:
        case RIS_TOK_MAX:
        case RIS_TOK_MIN:
        case RIS_TOK_SUM:
            print_token(tp->tok);
            if (tp->lhs->tok == RIS_TOK_ALL)
            {
                RIScom_fputs("(all ", RIScpp_temp_file);
            }
            else if (tp->lhs->tok == RIS_TOK_DISTINCT)
            {
                RIScom_fputs("(distinct ", RIScpp_temp_file);
            }
			else
			{
				CPP_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->lhs->pos);
			}
            RIScpp_tree_to_string(tp->rhs, stmt_type);
            RIScom_fputs(")", RIScpp_temp_file);
        break;

        case RIS_TOK_COUNT:
            RIScom_fputs("count(", RIScpp_temp_file);
            if (tp->lhs)
            {
                if (tp->lhs->tok == RIS_TOK_DISTINCT)
                {
                    RIScom_fputs("distinct ", RIScpp_temp_file);
                }
				else
				{
					CPP_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->lhs->pos);
				}
            }
            if (tp->rhs->tok == RIS_TOK_MUL)
            {
                RIScom_fputs("*", RIScpp_temp_file);
            }
            else
            {
                RIScpp_tree_to_string(tp->rhs, stmt_type);
            }

            RIScom_fputs(")", RIScpp_temp_file);
        break;

        case RIS_TOK_NULL:
            print_token(tp->tok);
            RIScom_fputs(" ", RIScpp_temp_file);
		break;

        case RIS_TOK_ASC:
        case RIS_TOK_DESC:
            RIScom_fputs(" ", RIScpp_temp_file);
            print_token(tp->tok);
        break;

        case RIS_TOK_ALL:
        case RIS_TOK_ANY:
        case RIS_TOK_EXISTS:
        case RIS_TOK_DISTINCT:
            print_token(tp->tok);
            RIScom_fputs(" ", RIScpp_temp_file);
			if(stmt_type == RIS_TOK_GRANT_ON_TABLE ||stmt_type== RIS_TOK_REVOKE_ON_TABLE)
				RIScom_fputs("on ", RIScpp_temp_file);
			if(tp->rhs)
            	RIScpp_tree_to_string(tp->rhs, stmt_type);
        break;

        case RIS_TOK_IN:
        case RIS_TOK_IS:
        case RIS_TOK_LIKE:
        case RIS_TOK_BETWEEN:
			if(tp->lhs)
            	RIScpp_tree_to_string(tp->lhs, stmt_type);
            RIScom_fputs(" ", RIScpp_temp_file);
            print_token(tp->tok);
            RIScom_fputs(" ", RIScpp_temp_file);
			if(tp->rhs)
            	RIScpp_tree_to_string(tp->rhs, stmt_type);
        break;

		case RIS_TOK_BETWEEN_AND:
			if(tp->lhs)
            	RIScpp_tree_to_string(tp->lhs, stmt_type);
            RIScom_fputs(" and ", RIScpp_temp_file);
			if(tp->rhs)
            	RIScpp_tree_to_string(tp->rhs, stmt_type);
			break;

		case RIS_TOK_FROM:
			RIScom_fputs(" from ", RIScpp_temp_file);
				for(temp=tp->rhs; temp; temp=temp->rhs)
				{
            		RIScpp_tree_to_string(temp->lhs, stmt_type);
					if(temp->rhs)
						RIScom_fputs(", ", RIScpp_temp_file);
				}
		break;

        case RIS_TOK_GROUP_BY:
        case RIS_TOK_ORDER_BY:
            RIScom_fputs(" ", RIScpp_temp_file);
            print_token(tp->tok);
            RIScom_fputs(" ", RIScpp_temp_file);
			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
            	RIScpp_tree_to_string(temp->lhs, stmt_type);
				if(temp->rhs)
					RIScom_fputs(", ", RIScpp_temp_file);
			}
			if(tp->lhs)
            	RIScpp_tree_to_string(tp->lhs, stmt_type);
        break;

        case RIS_TOK_WHERE:
        case RIS_TOK_HAVING:
            RIScom_fputs(" ", RIScpp_temp_file);
            print_token(tp->tok);
            RIScom_fputs(" ", RIScpp_temp_file);
			select_flag = 1;
            RIScpp_tree_to_string(tp->rhs, stmt_type);
			select_flag = 0;
		break;

		case RIS_TOK_TABLE_NAME:
			if (stmt_type == RIS_TOK_CREATE_INDEX)
			{
				/* This will not be in rename tree */
				RIScom_fputs(" on ", RIScpp_temp_file);
			}
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
			if(tp->rhs)
			{
				if(tp->rhs->tok != RIS_TOK_ALIAS_NAME)
				{
					RIScom_fputs(".",RIScpp_temp_file);
				}
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}	
			else
			{
				RIScom_fputs(" ", RIScpp_temp_file);
			}
#ifdef FULL_EXPANSION		
			if (stmt_type == RIS_TOK_CREATE_TABLE  ||
			    stmt_type == RIS_TOK_DECLARE_TABLE ||
			    stmt_type == RIS_TOK_DECLARE_VIEW )
			{
				RIScom_fputs(" (", RIScpp_temp_file);
			}
#endif
			if(tp->lhs)
			{
				RIScpp_tree_to_string(tp->lhs, stmt_type);
			}
		break;

		case RIS_TOK_ALIAS_NAME:
			RIScom_fputs(" ", RIScpp_temp_file);
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
		break;

		case RIS_TOK_COL_NAME:
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
			RIScom_fputs(" ", RIScpp_temp_file);
			if(tp->lhs)
				RIScpp_tree_to_string(tp->lhs, stmt_type);
			if(tp->rhs)
				RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_PRIVILEGE_LIST:
			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
				if(temp->lhs->tok==RIS_TOK_UPDATE)
				{
					RIScom_fputs("update ", RIScpp_temp_file);
					/*for optional column list*/
					if(temp->lhs->rhs)
					RIScpp_tree_to_string(temp->lhs->rhs, stmt_type);
				}
				else
					print_token(temp->lhs->tok);

					if(temp->rhs)
						RIScom_fputs(", ", RIScpp_temp_file);
			}
			RIScom_fputs(" on ", RIScpp_temp_file);
		break;

		case RIS_TOK_GRANTEE_LIST:
			if(stmt_type==RIS_TOK_GRANT_ON_TABLE)
				RIScom_fputs(" to ", RIScpp_temp_file);
			else
				RIScom_fputs(" from ", RIScpp_temp_file);
			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
				RIScpp_tree_to_string(temp->lhs, stmt_type);
				if(temp->rhs)
					RIScom_fputs(", ", RIScpp_temp_file);
			}
		break;

		case RIS_TOK_PUBLIC:
			print_token(tp->tok);
		break;

		case RIS_TOK_COLUMN_LIST:
#ifdef OLD
			if (stmt_type == RIS_TOK_CREATE_VIEW ||
				stmt_type == RIS_TOK_CREATE_INDEX ||
				stmt_type == RIS_TOK_INSERT || 
				stmt_type == RIS_TOK_GRANT_ON_TABLE ||
				stmt_type == RIS_TOK_CREATE_TABLE  ||
			    stmt_type == RIS_TOK_DECLARE_TABLE ||
			    stmt_type == RIS_TOK_DECLARE_VIEW )
			{
				RIScom_fputs("(", RIScpp_temp_file);
			}
#endif
			RIScom_fputs("(", RIScpp_temp_file);
			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
				RIScpp_tree_to_string(temp->lhs, stmt_type);
				if(temp->rhs) 
				{
					RIScom_fputs(", ",RIScpp_temp_file);
				}

			}
			RIScom_fputs(")", RIScpp_temp_file);
#ifdef OLD
			if (stmt_type == RIS_TOK_CREATE_VIEW ||
				stmt_type == RIS_TOK_CREATE_INDEX ||
				stmt_type == RIS_TOK_INSERT || 
				stmt_type == RIS_TOK_GRANT_ON_TABLE ||
				stmt_type == RIS_TOK_CREATE_TABLE  ||
			    stmt_type == RIS_TOK_DECLARE_TABLE ||
			    stmt_type == RIS_TOK_DECLARE_VIEW )
			{
				RIScom_fputs(")", RIScpp_temp_file);
			}
#endif
		break;

		case RIS_TOK_COLUMN_DEF_LIST:
			RIScom_fputs("(",RIScpp_temp_file);
			for(temp=tp->rhs; temp; temp=temp->rhs)
			{
				RIScpp_tree_to_string(temp->lhs, stmt_type);
				if(temp->rhs)
					RIScom_fputs(", ",RIScpp_temp_file);
			}
			RIScom_fputs(") ",RIScpp_temp_file);
		break;

		case RIS_TOK_COLUMN_DEF:
			RIScpp_tree_to_string(tp->rhs, stmt_type);
		break;

		case RIS_TOK_CHAR:
		case RIS_TOK_CHARACTER:
			print_token(tp->tok);
			/*Array's value*/
			RIScom_fputs("(", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
			RIScom_fputs(")", RIScpp_temp_file);
		break;

       case RIS_TOK_RIS_BLOB:
       case RIS_TOK_RIS_TEXT:
			print_token(tp->tok);
			/*Array's value*/
			RIScom_fputs("(", RIScpp_temp_file);
			RIScpp_tree_to_string(tp->rhs, stmt_type);
			RIScom_fputs(")", RIScpp_temp_file);
		break;

		case RIS_TOK_INT:
		case RIS_TOK_INTEGER:
			print_token(tp->tok);
		break;

		case RIS_TOK_SMALLINT:
			print_token(tp->tok);
		break;

		case RIS_TOK_DOUBLE:
			print_token(tp->tok);
		break;

		case RIS_TOK_REAL:
			print_token(tp->tok);
		break;

		case RIS_TOK_DEC:
		case RIS_TOK_DECIMAL:
			print_token(tp->tok);
			if(tp->rhs)
			{
				RIScom_fputs("(",RIScpp_temp_file);
				RIScpp_tree_to_string(tp->rhs, stmt_type);
				RIScom_fputs(")",RIScpp_temp_file);
			}
		break;

		case RIS_TOK_TIMESTAMP:
			print_token(tp->tok);
		break;

		case RIS_TOK_UNSUPPORTED:
			print_token(tp->tok);
		break;

		case RIS_TOK_NOT_NULL:
			RIScom_fputs(" not null", RIScpp_temp_file);
		break;

		case RIS_TOK_AUTH_ID:
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
			if(tp->rhs)
			{
				if (tp->rhs->info.val && tp->rhs->info.val[0])
				{
					RIScom_fputs(".", RIScpp_temp_file);
				}
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
			if(tp->lhs)
			{
				RIScpp_tree_to_string(tp->lhs, stmt_type);
			}
		break;

		case RIS_TOK_PASSWORD:
			if (tp->info.val && tp->info.val[0])
			{
				RIScom_fputs(tp->info.val, RIScpp_temp_file);
			}
		break;
				
		case RIS_TOK_DATABASE:
			if (stmt_type == RIS_TOK_SET)
			{
				ristree *enable = tp->rhs->lhs;
				if (enable->rhs->tok == RIS_TOK_ALL)
				{
					RIScom_fputs("database enable all",RIScpp_temp_file);
				}
				else if (enable->rhs->tok == RIS_TOK_DB_TYPE_LIST)
				{
					RIScom_fputs("database enable only ",RIScpp_temp_file);
					for (temp=enable->rhs->rhs; temp; temp = temp->rhs)
					{
						print_token(temp->lhs->tok);
						if (temp->rhs)
							RIScom_fputs(", ", RIScpp_temp_file);
					}
				}
				else
				{
					CPP_ERR_RETURN(RIS_E_INTERNAL_ERROR,enable->pos);
				}
			}
			else
			{
				RIScom_fputs(" on database ",RIScpp_temp_file);
				RIScom_fputs("(",RIScpp_temp_file);
				for (temp = tp->rhs; temp; temp = temp->rhs)
				{
					RIScpp_tree_to_string(temp->lhs, stmt_type);
					if (temp->rhs)
						RIScom_fputs(", ", RIScpp_temp_file);
				}
				RIScom_fputs(")",RIScpp_temp_file);
			}
		break;

		case RIS_TOK_INFORMIX:
		case RIS_TOK_ORACLE:
		case RIS_TOK_INGRES:
		case RIS_TOK_DB2:
		case RIS_TOK_SQLDS:
		case RIS_TOK_RDB:
		case RIS_TOK_SYBASE:
		case RIS_TOK_MSSQL:
		case RIS_TOK_OS400:
			print_token(tp->tok);
		break;

		case RIS_TOK_REMOTE:
			RIScom_fputs("remote(", RIScpp_temp_file);
			for (temp = tp->rhs; temp; temp = temp->rhs)
			{
				RIScpp_tree_to_string(temp->lhs, stmt_type);
				if (temp->rhs)
					RIScom_fputs(", ", RIScpp_temp_file);
			}
			RIScom_fputs(")", RIScpp_temp_file);
		break;
		case RIS_TOK_GATEWAY:
			RIScom_fputs("gateway (", RIScpp_temp_file);
			for (temp = tp->rhs; temp; temp = temp->rhs)
			{
                if(temp->lhs->tok == RIS_TOK_HOST_LU)
                {
                    RIScom_fputs("host_lu", RIScpp_temp_file);
                }
                else if (temp->lhs->tok == RIS_TOK_HOST_PROGRAM)
                {
                    RIScom_fputs("host_program", RIScpp_temp_file);
                }
                else if (temp->lhs->tok == RIS_TOK_NET_PROTOCOL)
                {
                    RIScom_fputs("net_protocol", RIScpp_temp_file);
                }
                else if (temp->lhs->tok == RIS_TOK_RIS_LU)
                {
                    RIScom_fputs("ris_lu", RIScpp_temp_file);
                }
                else
                {
                    print_token(temp->lhs->tok);
                }
				RIScom_fputs("=",RIScpp_temp_file);
				RIScom_fputs(temp->lhs->info.val, RIScpp_temp_file);
				if(temp->rhs)
					RIScom_fputs(", ",RIScpp_temp_file);
			}
			RIScom_fputs(")", RIScpp_temp_file);
		break;

		case RIS_TOK_RIS_DICT_DBNAME:
		case RIS_TOK_DBNAME:
		case RIS_TOK_DIR:
		case RIS_TOK_XNS:
		case RIS_TOK_TCP:
		case RIS_TOK_DNP:
			print_token(tp->tok);
			RIScom_fputs(" ", RIScpp_temp_file);
			string = fix_char_literal_str(tp->info.val,0);
			RIScom_fputs(string,RIScpp_temp_file);
		break;
			
		case RIS_TOK_OPTION:
			RIScom_fputs(" ", RIScpp_temp_file);
			print_token(tp->tok);
			RIScom_fputs(" ( ", RIScpp_temp_file);
			RIScom_fputs(tp->info.val, RIScpp_temp_file);
			RIScom_fputs(" ) ", RIScpp_temp_file);
		break;

		case RIS_TOK_FORCE:
			RIScom_fputs(" ", RIScpp_temp_file);
			print_token(tp->tok);
			RIScom_fputs(" ", RIScpp_temp_file);
		break;

		case RIS_TOK_USER:
		case RIS_TOK_OSUSER:
			RIScom_fputs(" ", RIScpp_temp_file);
			print_token(tp->tok);
			RIScom_fputs(" ", RIScpp_temp_file);

/*
** user is used in two different contexts.
** the user associated with a schema has an associated string.
** the user function that returns the default schema name does not.
*/

            if (tp->info.val)
            {
                RIScom_fputs(tp->info.val, RIScpp_temp_file);
            }

			if(tp->rhs)
			{
				if (tp->rhs->info.val && tp->rhs->info.val[0])
				{
					RIScom_fputs(".", RIScpp_temp_file);
				}
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
		break;

		case RIS_TOK_OSTYPE:
			RIScom_fputs(" ", RIScpp_temp_file);
			print_token(tp->tok);
			RIScom_fputs(" ", RIScpp_temp_file);

            if (tp->info.val)
            {
                RIScom_fputs(tp->info.val, RIScpp_temp_file);
            }
		break;

		case RIS_TOK_TIMESTAMP_LIT:
			time_stamp_exp(tp);
		break;

		case RIS_TOK_CURRENT_TIMESTAMP:
			RIScom_fputs(" current_timestamp ", RIScpp_temp_file);
		break;

		case RIS_TOK_ANSI:
			RIScom_fputs("ansi", RIScpp_temp_file);
			if (tp->rhs)
			{
				RIScpp_tree_to_string(tp->rhs, stmt_type);
			}
		break;

		case RIS_TOK_USING_DICT_OWNER:
			RIScom_fputs(" using ", RIScpp_temp_file);
            if (tp->info.val)
            {
                RIScom_fputs(tp->info.val, RIScpp_temp_file);
			}
		break;

		default:
			CPP_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->pos);
	}
}

/****************************************************************************/

extern void RIScpp_generate_string(
	ristree * tp)
{
	int stmt_type;
	
	CPP_DBG(("RIScpp_generate_string(tp:0x%x)\n", tp));
	stmt_type = tp->tok;
	grant_flag=0;
	select_flag=0;
	close_paren_flag=0;
	RIScpp_tree_to_string(tp, stmt_type);
	CPP_DBG(("RIScpp_generate_string:complete\n"));
}

/****************************************************************************/

extern void time_stamp_exp(
	ristree * tp)
{
	fprintf(RIScpp_temp_file, "timestamp '%d-%02d-%02d:%02d:%02d:%02d'", 
	((datetime *)tp->info.val)->year, 
	((datetime *)tp->info.val)->month,
	((datetime *)tp->info.val)->day,
	((datetime *)tp->info.val)->hour,
	((datetime *)tp->info.val)->minute,
	((datetime *)tp->info.val)->second);
}

/****************************************************************************/

static char *fix_char_literal_str(
	char	*in_string,
	int     delimit_flag)
{
	int		i = 0;
	int		j = 0;
	int		len = 0;
	int		numchars;
	char	*out_string;

#ifdef WIN32
	wchar_t *tmp_in_string;
	wchar_t *tmp_out_string;
	int		mnum;
	int		snum;
	int		wide_len = 0;
#else
	char *tmp_in_string;
	char *tmp_out_string;
#endif

	CPP_DBG(("fix_char_literal_str(in_string: <%s> delimit_flag: %d)\n",
					 in_string, delimit_flag));

	len = strlen(in_string);
	out_string = ALLOCBP(2 * len);

#ifdef WIN32
	RIScom_numchars ( in_string, &mnum, &snum, len );
	numchars = mnum + snum;
	wide_len = strlen(in_string) * MULTIBYTE_SIZE;

	tmp_out_string = (wchar_t *)SYS_MALLOC(2 * wide_len);
	RIScom_multiwide(&RISwide_ptr,&in_string,&RISwide_size,MULTITOWIDE,0);
	tmp_in_string = RISwide_ptr;
	CPP_DBG(("fix_char_literal_str(tmp_in__string: <%S>, numchars: <%d>\n", 
				tmp_in_string, numchars ));
#else
	tmp_in_string = in_string;
	tmp_out_string = out_string;

	/* on non-multibyte systems, one character = one byte */
	numchars =  len;
#endif

	if (delimit_flag)
	{
	    tmp_out_string[j++] = tmp_in_string[i++];
		for(; i < numchars-1; ++i, ++j )
		{
			if(tmp_in_string[i] == WIDECHAR('"'))
			{
				tmp_out_string[j] = WIDECHAR('\\');
				tmp_out_string[++j] = WIDECHAR('"');
/* TR#439600540 - mms - need to stretch the lenght by one */				
				++len ;
			}
			else if(tmp_in_string[i] == WIDECHAR('\\'))
			{
				tmp_out_string[j] = WIDECHAR('\\');
				tmp_out_string[++j] = WIDECHAR('\\');
/* TR#439600540 - mms - need to stretch the lenght by one */				
				++len ;
			}
			else
				tmp_out_string[j] = tmp_in_string[i];
		}
		/*  Fix for tr: 439500692.  Under NT the last character
		**  was being truncated.  Paula 3/6/95
		*/

		tmp_out_string[j++] = tmp_in_string[i];
	}
	else
	{
		for(; i < numchars; i++ )
		{
			if(tmp_in_string[i] == WIDECHAR('"'))
			{
				tmp_out_string[j] = WIDECHAR('\\');
				tmp_out_string[++j] = WIDECHAR('"');
			}
			else if(tmp_in_string[i] == WIDECHAR('\\'))
			{
				tmp_out_string[j] = WIDECHAR('\\');
				tmp_out_string[++j] = WIDECHAR('\\');
			}
			else
				tmp_out_string[j] = tmp_in_string[i];
			j++;				
		}
	}

#ifdef WIN32
/* mms - TR#439503650 replaced the 3rd parameter from j to len */
	RIScom_wcstombs(out_string, tmp_out_string, len );
	if ( tmp_out_string )
	{
		SYS_FREE((char*) tmp_out_string );
	}
#endif
	CPP_DBG(("fix_char_literal_str: complete - <%s>  len: <%d>\n", out_string, len));
	return(out_string);
}

/****************************************************************************/
