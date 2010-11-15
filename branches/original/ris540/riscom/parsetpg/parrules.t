* ris_stmt.c *******************************************************************
#include "comstmt.prt"
#include "comsttyp.prt"

ris_stmt
:	sql_statement
|   RIS_TOK_ASYNC
        {
            RISpar_PREPROCESSOR_ONLY();
        }
    async_id async_sql_statement
        {
			RISpar_create_tree(RIS_TOK_ASYNC, &_1, 2);
        }
;


sql_statement
:	sql_stmt RIS_TOK_SEMICOLON
		{
			if (!PREPROCESSOR && !RISpar_schema)
			{
				if (RIScom_default_schema_required(RIScom_tok_to_stmt_type(
					RISpar_top()->tok)))
				{
					RISpar_ERR_RETURN(RIS_E_NO_SCHEMA,0);
				}
			}
		}
;

async_sql_statement
:	async_sql_stmt RIS_TOK_SEMICOLON
;

sql_stmt
:	RIS_TOK_ALTER alter_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_CLEAR clear_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_CLOSE close_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_CREATE create_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_DECLARE declare_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_DESCRIBE describe_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_DROP drop_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_EXECUTE execute_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_OPEN open_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_REDECLARE redeclare_superschema_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_REPORT report_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_SET set_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_UNDECLARE undeclare_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_GRANT grant_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_REVOKE revoke_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	begin_declare_section
|	commit_stmt
|	default_schema_stmt
|	define
|	delete_stmt
|	else
|	end_declare_section
|	endif
|	exec_stmt
|	fetch_stmt
|	host_var_def
|	ifdef
|	ifndef
|	include
|	insert_stmt
|	lock_tables_stmt
|	prepare_stmt
|	rollback_stmt
|	select_stmt
|	test_stmt
|	undef
|	update_stmt
|	virtual
|	wait_stmt
|	whenever_stmt
;

async_sql_stmt
:	RIS_TOK_ALTER alter_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_CLEAR async_clear_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_CLOSE close_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_CREATE create_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_DECLARE declare_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_DROP drop_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_EXECUTE execute_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_OPEN open_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_REDECLARE redeclare_superschema_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_SET set_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	RIS_TOK_UNDECLARE undeclare_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|   RIS_TOK_GRANT grant_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|   RIS_TOK_REVOKE revoke_stmt
		{
			RISpar_update_tree_node(RISpar_top(), RISpar_top()->tok, &_1);
		}
|	commit_stmt
|	default_schema_stmt
|	delete_stmt
|	exec_stmt
|	fetch_stmt
|	insert_stmt
|	lock_tables_stmt
|	rollback_stmt
|	select_stmt
|	update_stmt
;

alter_stmt
:	alter_schema_stmt
|	alter_table_stmt
;

close_stmt
:	close_cursor_stmt
|	close_schema_stmt
;

create_stmt
:	create_index_stmt
|	create_secure_schema_stmt
|	create_schema_stmt
|	create_table_stmt
|	create_view_stmt
;

declare_stmt
:	declare_cursor_stmt
|	declare_schema_stmt
|	declare_table_stmt
|	declare_view_stmt
|	declare_superschema_stmt
;

describe_stmt
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_INPUT describe_input_stmt
|	RIS_TOK_OUTPUT describe_output_stmt
|	describe_output_stmt
;

drop_stmt
:	drop_index_stmt
|	drop_schema_stmt
|	drop_table_stmt
|	drop_view_stmt
;

execute_stmt
:	execute_immediate
|	execute_stmt_id
;

grant_stmt
:	grant_on_table
|	grant_schema
|	grant_connect
|	grant_resource
;

open_stmt
:	open_cursor_stmt
|	open_schema_stmt
;

report_stmt
:	report_superschema_error
|	report_error
;

revoke_stmt
:   revoke_on_table
|   revoke_schema
|   revoke_connect
|   revoke_resource
;

undeclare_stmt
:   undeclare_schema_stmt
|   undeclare_table_stmt
|   undeclare_view_stmt
|   undeclare_superschema_stmt
;

* stmt.c ***********************************************************************

alter_schema_stmt
:	RIS_TOK_SCHEMA schema_spec alter_schema_action
		{
			RISpar_create_list(RIS_TOK_ALTER_SCHEMA, &_1, 2);
		}
;

alter_table_stmt
:	RIS_TOK_TABLE table_name alter_table_action
		{
			RISpar_create_list(RIS_TOK_ALTER_TABLE, &_1, 2);
		}
;

begin_declare_section
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_BEGIN
	RIS_TOK_DECLARE RIS_TOK_SECTION
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_BEGIN_DECLARE, &_1));
		}
;

clear_stmt
{
	RISpar_PREPROCESSOR_ONLY();
}
:	stmt_id
		{
			RISpar_create_list(RIS_TOK_CLEAR, &_1, 1);
		}
|	RIS_TOK_CURSOR cursor_name
		{
			RISpar_create_list(RIS_TOK_CLEAR, &_1, 1);
		}
|	RIS_TOK_ASYNC async_id
		{
			RISpar_create_list(RIS_TOK_CLEAR, &_1, 1);
		}
;

async_clear_stmt
{
	RISpar_PREPROCESSOR_ONLY();
}
:	stmt_id
		{
			RISpar_create_list(RIS_TOK_CLEAR, &_1, 1);
		}
|	RIS_TOK_CURSOR cursor_name
		{
			RISpar_create_list(RIS_TOK_CLEAR, &_1, 1);
		}
;


close_cursor_stmt
{
	RISpar_PREPROCESSOR_ONLY();
}
:	cursor_name
		{
			RISpar_create_list(RIS_TOK_CLOSE, &_1, 1);
		}
;

close_schema_stmt
:	RIS_TOK_SCHEMA close_schema_action
		{
			RISpar_create_list(RIS_TOK_CLOSE_SCHEMA, &_1, 1);
		}
;

commit_stmt
:	RIS_TOK_COMMIT opt_tok_work opt_schema_option
		{
			RISpar_create_list(RIS_TOK_COMMIT, &_1, 1);
		}
;

create_index_stmt
:	RIS_TOK_INDEX index_name opt_extern_index RIS_TOK_ON table_name RIS_TOK_LPAREN column_list
	RIS_TOK_RPAREN
		{
			RISpar_create_list(RIS_TOK_CREATE_INDEX, &_1, 4);
		}
|	RIS_TOK_UNIQUE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_UNIQUE, &_1));
		}
	RIS_TOK_INDEX index_name opt_extern_index RIS_TOK_ON table_name RIS_TOK_LPAREN column_list
	RIS_TOK_RPAREN
		{
			RISpar_create_list(RIS_TOK_CREATE_INDEX, &_1, 5);
		}
;

opt_extern_index
:
		RIS_TOK_EXTERN index_name 	
		{
			RISpar_create_list(RIS_TOK_EXTERN, &_1, 1);
		}
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

create_secure_schema_stmt
{
	RISpar_VERSION_5_REQUIRED(RISpar_top()->pos);
}
:	RIS_TOK_SECURE create_schema_stmt
		{
			RISpar_top()->lhs = RISpar_create_tree_node(RIS_TOK_SECURE, &_1);
		}
;

create_schema_stmt
:	RIS_TOK_SCHEMA opt_tok_authorization schema_spec 
	opt_on_database opt_user_spec opt_using_spec
	opt_server_version opt_force_include_exclude
		{
			RISpar_create_list(RIS_TOK_CREATE_SCHEMA, &_1, 7);
		}
;

create_table_stmt
:	RIS_TOK_TABLE table_name RIS_TOK_LPAREN column_def_list RIS_TOK_RPAREN 
	opt_extern_table_col_list
		{
			RISpar_create_list(RIS_TOK_CREATE_TABLE, &_1, 3);
		}
;

create_view_stmt
:	RIS_TOK_VIEW table_name opt_col_list opt_extern_table_col_list RIS_TOK_AS query_spec 
		{
			RISpar_create_list(RIS_TOK_CREATE_VIEW, &_1, 4);
		}
;

opt_extern_table_col_list
:	RIS_TOK_EXTERN dbms_table_name opt_col_list 
		{
			RISpar_create_list(RIS_TOK_EXTERN, &_1, 2);
		}

|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;



opt_user_table_col_list
:	RIS_TOK_EXTERN user_name_table_name opt_col_list 
		{
			RISpar_create_list(RIS_TOK_EXTERN, &_1, 2);
		}
| 
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

declare_cursor_stmt
{
	RISpar_PREPROCESSOR_ONLY();
}
:	cursor_name RIS_TOK_CURSOR RIS_TOK_FOR declare_action
		{
			RISpar_create_list(RIS_TOK_DECLARE, &_1, 3);
		}
;

declare_schema_stmt
{
	RISpar_VERSION_5_REQUIRED(RISpar_top()->pos);
}
:   RIS_TOK_SCHEMA schema_spec opt_dbuser_osuser_spec
        {
            RISpar_create_list(RIS_TOK_DECLARE_SCHEMA, &_1, 3);
        }
;

opt_dbuser_osuser_spec
: user_spec opt_osuser_spec
| osuser_spec opt_user_spec
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		}
;

declare_table_stmt
{
    ristree *tp1;
}
:   RIS_TOK_TABLE table_name RIS_TOK_LPAREN declare_col_def_list RIS_TOK_RPAREN
	opt_user_table_col_list  opt_with_verify_option
        {
            tp1 = RISpar_pop(); /* No or Partial or Full Verify */
            RISpar_create_list(RIS_TOK_DECLARE_TABLE, &_1, 3);
            RISpar_top()->lhs = tp1;
        }
;

declare_view_stmt
{
    ristree *tp1;
}
:   RIS_TOK_VIEW table_name RIS_TOK_LPAREN declare_col_def_list RIS_TOK_RPAREN
	opt_user_table_col_list  opt_with_verify_option
        {
            tp1 = RISpar_pop(); /* No or Partial or Full Verify */
            RISpar_create_list(RIS_TOK_DECLARE_VIEW, &_1, 3);
            RISpar_top()->lhs = tp1;
        }
;

declare_superschema_stmt
:	RIS_TOK_SUPERSCHEMA opt_tok_authorization schema_spec RIS_TOK_WITH
	primary_schema opt_secondary_schema_list
		{
			RISpar_create_list(RIS_TOK_DECLARE_SUPERSCHEMA, &_1, 3);
		}
;

default_schema_stmt
:	RIS_TOK_DEFAULT RIS_TOK_SCHEMA schema_spec
		{
			RISpar_create_list(RIS_TOK_SCHEMA_LIST, &_3, 1);
			RISpar_create_list(RIS_TOK_DEFAULT_SCHEMA, &_1, 1);
		}
;

delete_stmt
:	RIS_TOK_DELETE RIS_TOK_FROM table_name opt_where_clause
		{
			RISpar_create_list(RIS_TOK_DELETE, &_1, 2);
		}
;

describe_input_stmt
:	stmt_id RIS_TOK_USING descriptor
		{
			RISpar_create_tree(RIS_TOK_USING, &_2, 1);
			RISpar_create_list(RIS_TOK_DESCRIBE_INPUT, &_1, 2);
		}
;

describe_output_stmt
:	stmt_id RIS_TOK_USING descriptor
		{
			RISpar_create_tree(RIS_TOK_USING, &_2, 1);
			RISpar_create_list(RIS_TOK_DESCRIBE_OUTPUT, &_1, 2);
		}
;

drop_index_stmt
:	RIS_TOK_INDEX index_name
		{
			RISpar_create_list(RIS_TOK_DROP_INDEX, &_1, 1);
		}
;

drop_schema_stmt
:	RIS_TOK_SCHEMA schema_spec opt_force
		{
			RISpar_create_list(RIS_TOK_DROP_SCHEMA, &_1, 2);
		}
;

drop_table_stmt
:	RIS_TOK_TABLE table_name
		{
			RISpar_create_list(RIS_TOK_DROP_TABLE, &_1, 1);
		}
;

drop_view_stmt
:	RIS_TOK_VIEW table_name
		{
			RISpar_create_list(RIS_TOK_DROP_VIEW, &_1, 1);
		}
;

end_declare_section
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_END RIS_TOK_DECLARE RIS_TOK_SECTION
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_END_DECLARE, &_1));
		}
;

exec_stmt
:	RIS_TOK_EXEC db_type
		{
			RISpar_lex_flag = SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_top()->info.val = _3.val;
			RISpar_create_tree(RIS_TOK_EXEC, &_1, 1);
		}
;

execute_immediate
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_IMMEDIATE string_spec
		{
			RISpar_create_list(RIS_TOK_EXECUTE_IMMEDIATE, &_1, 1);
		}
;

execute_stmt_id
{
	RISpar_PREPROCESSOR_ONLY();
}
:	stmt_id opt_using_clause
		{
			RISpar_create_list(RIS_TOK_EXECUTE, &_1, 2);
		}
;

fetch_stmt
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_FETCH cursor_name fetch_stmt_arg
		{
			RISpar_create_list(RIS_TOK_FETCH, &_1, 2);
		}
;

grant_on_table
:	grant_privileges RIS_TOK_ON table_name RIS_TOK_TO grantee_list
	opt_tok_with_grant_option
		{
			RISpar_create_list(RIS_TOK_GRANT_ON_TABLE, &_1, 4);
		}
;

grant_schema
{
	RISpar_VERSION_5_REQUIRED(RISpar_top()->pos);
}
:	RIS_TOK_SCHEMA to_login
		{
			RISpar_create_list(RIS_TOK_GRANT_SCHEMA, &_1, 1);
		}
;

grant_connect
{
	RISpar_VERSION_5_REQUIRED(RISpar_top()->pos);
}
:	RIS_TOK_CONNECT to_login
		{
			RISpar_create_list(RIS_TOK_GRANT_CONNECT, &_1, 1);
		}
;

grant_resource
{
	RISpar_VERSION_5_REQUIRED(RISpar_top()->pos);
}
:	RIS_TOK_RESOURCE to_login
		{
			RISpar_create_list(RIS_TOK_GRANT_RESOURCE, &_1, 1);
		}
;

host_var_def
{
	RISpar_PREPROCESSOR_ONLY();
}
:	host_storage_class
		{
			RISpar_host_ident_flag = 1;
		}
	 host_type_spec_list host_var_list
		{
			RISpar_host_ident_flag = 0;
			RISpar_create_list(RIS_TOK_HOST_VAR_DEF, &_1, 3);
		}
|		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
			RISpar_host_ident_flag = 1;
		}
	host_type_spec_list host_var_list
		{
			RISpar_host_ident_flag = 0;
			RISpar_create_list(RIS_TOK_HOST_VAR_DEF, &_1, 3);
		}
;

insert_stmt
:	RIS_TOK_INSERT RIS_TOK_INTO table_name opt_col_list insert_values
		{
			RISpar_create_list(RIS_TOK_INSERT, &_1, 3);
		}
;

lock_tables_stmt
:	RIS_TOK_LOCK RIS_TOK_TABLES lock_action_list
		{
			RISpar_create_list(RIS_TOK_LOCK_TABLES, &_1, 1);
		}
;

open_cursor_stmt
{
	RISpar_PREPROCESSOR_ONLY();
}
:	cursor_name opt_using_clause
		{
			RISpar_create_list(RIS_TOK_OPEN, &_1, 2);
		}
;

open_schema_stmt
:	RIS_TOK_SCHEMA schema_list
		{
			RISpar_create_list(RIS_TOK_OPEN_SCHEMA,&_1,1);
		}
;

prepare_stmt
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_PREPARE stmt_id RIS_TOK_FROM string_spec
		{
			RISpar_create_list(RIS_TOK_PREPARE, &_1, 2);
		}
;

redeclare_superschema_stmt
:	RIS_TOK_SUPERSCHEMA schema_spec redeclare_superschema_action
		{
			RISpar_create_list(RIS_TOK_REDECLARE_SUPERSCHEMA, &_1, 2);
		}
;

report_error
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_ERROR opt_for_async_id opt_into_var
		{
			RISpar_create_list(RIS_TOK_REPORT_ERROR, &_1, 2);
		}
;

report_superschema_error
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_SUPERSCHEMA RIS_TOK_ERROR RIS_TOK_FOR schema_id
		{
			RISpar_create_list(RIS_TOK_REPORT_SS_ERROR, &_1, 1);
		}
;

revoke_on_table
:	revoke_privileges RIS_TOK_ON table_name RIS_TOK_FROM
	grantee_list
		{
			RISpar_create_list(RIS_TOK_REVOKE_ON_TABLE, &_1, 3);
		}
;

revoke_schema
{
	RISpar_VERSION_5_REQUIRED(RISpar_top()->pos);
}
:	RIS_TOK_SCHEMA from_login
		{
			RISpar_create_list(RIS_TOK_REVOKE_SCHEMA, &_1, 1);
		}
;

revoke_connect
{
	RISpar_VERSION_5_REQUIRED(RISpar_top()->pos);
}
:	RIS_TOK_CONNECT from_login
		{
			RISpar_create_list(RIS_TOK_REVOKE_CONNECT, &_1, 1);
		}
;

revoke_resource
{
	RISpar_VERSION_5_REQUIRED(RISpar_top()->pos);
}
:   RIS_TOK_RESOURCE from_login
		{
			RISpar_create_list(RIS_TOK_REVOKE_RESOURCE, &_1, 1);
		}
;

rollback_stmt
:   RIS_TOK_ROLLBACK opt_tok_work opt_schema_option
		{
			RISpar_create_list(RIS_TOK_ROLLBACK, &_1, 1);
		}
;

opt_union_select_expr
:   RIS_TOK_UNION opt_tok_union_all RIS_TOK_SELECT
		{
			RISpar_no_parms = 1;
		}
	select_list
		{
			RISpar_no_parms = 0;
		}
	table_expr
		{
			if (RISpar_union_all)
			{
				RISpar_create_list(RIS_TOK_UNION_ALL_SELECT, &_1, 5);
			}
			else
			{
				RISpar_create_list(RIS_TOK_UNION_SELECT, &_1, 5);
			}
			RISpar_link_nodes();
			if (PREPROCESSOR)
			{
				RISpar_ERR_RETURN(RIS_E_UNION_CLAUSE_NOT_ALLOWED, _1.pos);
			}
		}
	opt_union_select_expr
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

select_expr
:	RIS_TOK_SELECT  
		{
			RISpar_no_parms = 1;
		}
	select_list
		{
			RISpar_no_parms = 0;
		}
	opt_into_clause table_expr
		{
			RISpar_create_list(RIS_TOK_SELECT_SELECT, &_1, 6);
			if (PREPROCESSOR)
			{
				if (RISpar_top()->rhs->rhs->lhs->tok != RIS_TOK_INTO)
				{
					RISpar_ERR_RETURN(RIS_E_MISSING_INTO, _1.pos);
				}
			}
		}
	opt_union_select_expr
		{
			RISpar_create_list(RIS_TOK_SELECT_EXPR, &_1, 2);
		}
;

select_stmt
:     select_expr opt_order_by
		{
			RISpar_create_list(RIS_TOK_SELECT, &_1, 2);
			if (PREPROCESSOR)
			{
				if (RISpar_top()->rhs->rhs && 
					RISpar_top()->rhs->rhs->lhs->tok == RIS_TOK_ORDER_BY)
				{
					RISpar_ERR_RETURN(RIS_E_ORDER_BY_NOT_ALLOWED,
					RISpar_top()->rhs->rhs->lhs->pos);
				}
			}
		}
;

set_stmt
:	RIS_TOK_DATABASE set_database_action
		{
			RISpar_create_list(RIS_TOK_DATABASE, &_1, 1);
			RISpar_create_tree(RIS_TOK_SET, &_1, 1);
		}
|	RIS_TOK_MODE set_mode_action
		{
			RISpar_create_list(RIS_TOK_MODE, &_1, 4);
			RISpar_create_tree(RIS_TOK_SET, &_1, 1);
		}
|	RIS_TOK_TRANSACTION set_transaction_action
		{
			RISpar_create_list(RIS_TOK_TRANSACTION, &_1, 1);
			RISpar_create_tree(RIS_TOK_SET, &_1, 1);
		}
|   RIS_TOK_NETWORK RIS_TOK_VERIFICATION set_net_verify_action
        {
            RISpar_create_list(RIS_TOK_NETWORK, &_1, 2);
            RISpar_create_tree(RIS_TOK_SET, &_1, 1);
        }
|   RIS_TOK_AUTORENAME on_off 
        {
            RISpar_create_list(RIS_TOK_AUTORENAME, &_1, 1);
            RISpar_create_tree(RIS_TOK_SET, &_1, 1);
        }
;

test_stmt
{
    RISpar_PREPROCESSOR_ONLY();
}
:   RIS_TOK_TEST test_cond RIS_TOK_COMPLETION
        {
            RISpar_create_tree(RIS_TOK_TEST, &_1, 1);
        }
;

undeclare_superschema_stmt
:	RIS_TOK_SUPERSCHEMA schema_spec 
		{
			RISpar_create_list(RIS_TOK_UNDECLARE_SUPERSCHEMA, &_1, 1);
		}
;

undeclare_schema_stmt
{
	RISpar_VERSION_5_REQUIRED(RISpar_top()->pos);
}
:   RIS_TOK_SCHEMA undeclare_schema_action
        {
            RISpar_create_list(RIS_TOK_UNDECLARE_SCHEMA, &_1, 1);
        }
;

undeclare_table_stmt
:   RIS_TOK_TABLE table_name
        {
            RISpar_create_list(RIS_TOK_UNDECLARE_TABLE, &_1, 1);
        }
;

undeclare_view_stmt
:   RIS_TOK_VIEW table_name
        {
            RISpar_create_list(RIS_TOK_UNDECLARE_VIEW, &_1, 1);
        }
;

update_stmt
:	RIS_TOK_UPDATE table_name RIS_TOK_SET set_list opt_where_clause
		{
			RISpar_create_list(RIS_TOK_UPDATE, &_1, 3);
		}
;

virtual
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_VIRTUAL
		{
			RISpar_host_ident_flag = 1;
		}
	host_type_spec_list virtual_host_var RIS_TOK_AS
		{
			/*
			** NOTE: virtual_host_var clears the RISpar_host_ident_flag
			*/
			RISpar_lex_flag = SPACE_FLAG|SEMICOLON_FLAG;
		}
	char_str_lit
		{
			RISpar_create_list(RIS_TOK_VIRTUAL, &_1, 3);
		}
;

wait_stmt
{
    RISpar_PREPROCESSOR_ONLY();
}
:   RIS_TOK_WAIT test_cond RIS_TOK_COMPLETION
        {
            RISpar_create_tree(RIS_TOK_WAIT, &_1, 1);
        }
;

whenever_stmt
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_WHENEVER whenever_cond whenever_action
		{
			RISpar_create_list(RIS_TOK_WHENEVER, &_1, 2);
		}
;

* embed.c *********************************************************************

define
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_DEFINE
		{
			RISpar_lex_flag = SPACE_FLAG|SEMICOLON_FLAG;
	    }	
	char_str_lit opt_signed_int
		{
			RISpar_create_list(RIS_TOK_DEFINE,&_1,2);
		}
;

else	
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_ELSE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ELSE,&_1));
			RISpar_create_list(RIS_TOK_ELSE,&_1,1);
		}
;

endif
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_ENDIF
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ENDIF,&_1));
			RISpar_create_list(RIS_TOK_ENDIF,&_1,1);
		}
;

ifdef
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_IFDEF
		{
			RISpar_lex_flag = SPACE_FLAG|SEMICOLON_FLAG;
	    }	
	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_IFDEFNAME,&_2));
			RISpar_create_list(RIS_TOK_IFDEF,&_1,1);
		}
;

ifndef
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_IFNDEF 
		{
			RISpar_lex_flag = SPACE_FLAG|SEMICOLON_FLAG;
	    }	
	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_IFNDEFNAME,&_2));
			RISpar_create_list(RIS_TOK_IFNDEF,&_1,1);
		}
;

include
{
	ristree *tp1;

	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_INCLUDE 
		{
			RISpar_lex_flag = SPACE_FLAG|SEMICOLON_FLAG;
	    }	
	RIS_TOK_CHAR_STR_LIT
		{
			tp1 = RISpar_create_tree_node(RIS_TOK_FILENAME,&_2);
			if (tp1->info.val[0] == '"')
			{
				int i;
				int len;

				len = strlen(tp1->info.val) - 2;
				for (i = 0; i < len; i++)
					tp1->info.val[i] = tp1->info.val[i+1];
				tp1->info.val[i] = '\0';
			}
			RISpar_push(tp1);
			RISpar_create_list(RIS_TOK_INCLUDE,&_1,1);
		}
;

undef
{
	RISpar_PREPROCESSOR_ONLY();
}
:	RIS_TOK_UNDEF 
		{
			RISpar_lex_flag = SPACE_FLAG|SEMICOLON_FLAG;
	    }	
	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_UNDEFNAME,&_2));
			RISpar_create_list(RIS_TOK_UNDEF,&_1,1);
		}
;

* action.c *********************************************************************

alter_schema_action
:	RIS_TOK_MODIFY alt_sch_modify_action
|	RIS_TOK_TO RIS_TOK_SECURE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_SECURE, &_2));
		}
|	RIS_TOK_INCLUDE alt_sch_inc_action
        {
            RISpar_create_tree(RIS_TOK_INCLUDE, &_1, 1);
        }
|   RIS_TOK_EXCLUDE 
        {
			RISpar_exclude_flag = 1;
        }
        alt_sch_exc_action
        {
	    		RISpar_exclude_flag = 0;
            		RISpar_create_tree(RIS_TOK_EXCLUDE, &_1, 1);
        }
;

alt_sch_modify_action
:	RIS_TOK_SCHEMA RIS_TOK_PASSWORD opt_password
		{
 			RISpar_create_tree(RIS_TOK_SCHEMA, &_1, 1);
		}
|	RIS_TOK_DB2 RIS_TOK_PASSWORD RIS_TOK_FROM 
		{
			RISpar_lex_flag = SPACE_FLAG|SEMICOLON_FLAG;
		}
	db2_pwd RIS_TOK_TO 
		{
			RISpar_lex_flag = SPACE_FLAG|SEMICOLON_FLAG;
		}
	db2_pwd opt_mode_spec
		{
			RISpar_create_list(RIS_TOK_DB2, &_1, 3);
		}
|	modify_action_list
;

modify_action_list
:	modify_action opt_modify_action_list
;

opt_modify_action_list
:	RIS_TOK_COMMA modify_action
		{
			RISpar_link_nodes();
		}
	opt_modify_action_list
|	
;

modify_action
{
	ristree *tp1;
}
:	RIS_TOK_USER RIS_TOK_PASSWORD opt_password
		{
			RISpar_create_tree(RIS_TOK_USER, &_1, 1);
		}
|	RIS_TOK_OSUSER 
		{
			RISpar_lex_flag = SPACE_FLAG|DOT_FLAG|COMMA_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT 
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_OSUSER, &_2));
			RISpar_dot_flag = 1;
		}
	opt_dot_password
		{
			tp1 = RISpar_pop();
			if (tp1->tok != RIS_TOK_NULL_NODE)
				RISpar_top()->rhs = tp1;
		}
|	RIS_TOK_REMOTE RIS_TOK_LPAREN proto_addr_list RIS_TOK_RPAREN
		{
			RISpar_create_list(RIS_TOK_REMOTE, &_1, 1);
		}
|	RIS_TOK_SERVER server_version
;

db2_pwd
:
	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_PASSWORD, &_1));
		}
;

opt_mode_spec
:
	RIS_TOK_USING RIS_TOK_MODE
		{
			RISpar_lex_flag = SPACE_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_MODE, &_3));
		}
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		}
;

alt_sch_exc_action
:   RIS_TOK_TABLE dbms_table_name 
        {
            RISpar_create_list(RIS_TOK_TABLE, &_1, 1);
        }
|   RIS_TOK_INDEX dbms_table_name
        {
            RISpar_create_list(RIS_TOK_INDEX, &_1, 1);
        }
|   RIS_TOK_VIEW dbms_table_name
        {
            RISpar_create_list(RIS_TOK_VIEW, &_1, 1);
        }
;

alt_sch_inc_action
:   RIS_TOK_TABLE user_name_table_name opt_internal_table_col_list
        {
            RISpar_create_list(RIS_TOK_TABLE, &_1, 2);
        }
|   RIS_TOK_INDEX user_name_index_name opt_internal_index
        {
            RISpar_create_list(RIS_TOK_INDEX, &_1, 2);
        }
|   RIS_TOK_VIEW user_name_table_name opt_internal_table_col_list
        {
            RISpar_create_list(RIS_TOK_VIEW, &_1, 2);
        }
;

user_name_table_name
{
    ristree *tp1;
    ristree *tp2;
	RISpar_lex_flag =
		SPACE_FLAG|DOT_FLAG|COMMA_FLAG|RPAREN_FLAG|SEMICOLON_FLAG;
}
:   RIS_TOK_CHAR_STR_LIT opt_dot_ident
        {
            tp1 = RISpar_pop();

            if (tp1->tok != RIS_TOK_NULL_NODE)
            {
                tp2 = RISpar_create_tree_node(RIS_TOK_USR_NAME, &_1);
                tp1->tok=RIS_TOK_TABLE_NAME;
                tp2->rhs = tp1;
                RISpar_push(tp2);
            }
            else
            {
                tp2 = RISpar_create_tree_node(RIS_TOK_TABLE_NAME, &_1);
				if (RISpar_lookup_keyword(tp2->info.val,1))
				{
					RISpar_ERR_RETURN(RIS_E_INVALID_IDENT, tp2->pos);
				}
                RISpar_push(tp2);
            }
		}
;

user_name_index_name
{
    ristree *tp1;
    ristree *tp2;
	RISpar_lex_flag =
		SPACE_FLAG|DOT_FLAG|COMMA_FLAG|RPAREN_FLAG|SEMICOLON_FLAG;
}
:   RIS_TOK_CHAR_STR_LIT opt_dot_ident
        {
            tp1 = RISpar_pop();

            if (tp1->tok != RIS_TOK_NULL_NODE)
            {
                tp2 = RISpar_create_tree_node(RIS_TOK_USR_NAME, &_1);
                tp1->tok=RIS_TOK_INDEX_NAME;
                tp2->rhs = tp1;
                RISpar_push(tp2);
            }
            else
            {
				tp2 = RISpar_create_tree_node(RIS_TOK_INDEX_NAME, &_1);
				if (RISpar_lookup_keyword(tp2->info.val,1))
				{
					RISpar_ERR_RETURN(RIS_E_INVALID_IDENT, tp2->pos);
				}
				RISpar_push(tp2);
            }
		}
;

close_schema_action
:	schema_list
|	RIS_TOK_ALL
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ALL, &_1));
		}
;

undeclare_schema_action
{
	RISpar_VERSION_5_REQUIRED(RISpar_top()->pos);
}
:	schema_list
|	RIS_TOK_ALL
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ALL, &_1));
		}
;

declare_action
:	query_spec opt_order_by
|	stmt_id
		{
			/*
			**	So both rules generate 2 nodes
			*/
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

lock_action_list
:	lock_action opt_lock_action_list
;

opt_lock_action_list
:	lock_action
	{
		RISpar_link_nodes();
	}
	opt_lock_action_list
|
;

lock_action
{
	ristree *tp1;
	ristree *tp2;
}
:	table_list
	{
		RISpar_create_list(RIS_TOK_TABLE_LIST, &_1, 1);
	}
	RIS_TOK_IN lock_table_mode
	{
		tp1 = RISpar_pop();
		tp2 = RISpar_pop();
		tp1->rhs = tp2;
		RISpar_push(tp1);
	}
;

redeclare_superschema_action
:   replace_primary
|   swap_primary
|   add_secondary
|   drop_secondary
;

replace_primary
:   RIS_TOK_REPLACE RIS_TOK_PRIMARY RIS_TOK_WITH secondary_schema
        {
            RISpar_create_list(RIS_TOK_REPLACE, &_1, 1);
        }
;

swap_primary
:   RIS_TOK_SWAP RIS_TOK_PRIMARY RIS_TOK_WITH secondary_schema
        {
            RISpar_create_list(RIS_TOK_SWAP, &_1, 1);
        }
;

add_secondary
:   RIS_TOK_ADD secondary_schema
        {
            RISpar_create_list(RIS_TOK_ADD, &_1, 1);
        }
;

drop_secondary
:   RIS_TOK_DROP secondary_schema
        {
            RISpar_create_list(RIS_TOK_DROP, &_1, 1);
        }
;

set_database_action
:	RIS_TOK_ENABLE db_enable_action
		{
			RISpar_create_tree(RIS_TOK_ENABLE, &_1, 1);
		}
;

db_enable_action
:	RIS_TOK_ONLY db_type_list
		{
			RISpar_create_list(RIS_TOK_DB_TYPE_LIST, &_2, 1);
		}
|	RIS_TOK_ALL
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ALL, &_1));
		}
;

db_type_list
:   db_type opt_db_type_list
;

opt_db_type_list
:   RIS_TOK_COMMA db_type
        {
            RISpar_link_nodes();
        }
    opt_db_type_list
|
;

set_mode_action
:	ansi_on_off opt_verify_strip_rename_on_off
|	verify_on_off opt_ansi_strip_rename_on_off
|	blankstrip_on_off opt_ansi_verify_rename_on_off
|	autorename_on_off opt_ansi_verify_strip_on_off
;

opt_verify_strip_rename_on_off
: verify_on_off opt_strip_rename_on_off
| blankstrip_on_off opt_verify_rename_on_off
| autorename_on_off opt_verify_strip_on_off
|	
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;


opt_ansi_strip_rename_on_off
: ansi_on_off opt_strip_rename_on_off
| blankstrip_on_off opt_ansi_rename_on_off
| autorename_on_off opt_ansi_strip_on_off
|	
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;

opt_ansi_verify_rename_on_off
: ansi_on_off opt_verify_rename_on_off
| verify_on_off opt_ansi_rename_on_off
| autorename_on_off opt_ansi_verify_on_off
|	
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;

opt_ansi_verify_strip_on_off
: ansi_on_off opt_verify_strip_on_off
| verify_on_off opt_ansi_strip_on_off
| blankstrip_on_off opt_ansi_verify_on_off
|	
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;


opt_strip_rename_on_off
:	blankstrip_on_off opt_autorename_on_off
|	autorename_on_off opt_blankstrip_on_off
|
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;

opt_verify_rename_on_off
:	verify_on_off opt_autorename_on_off
|	autorename_on_off opt_verify_on_off
|
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;

opt_ansi_rename_on_off
:	ansi_on_off opt_autorename_on_off
|	autorename_on_off opt_ansi_on_off
|
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;

opt_verify_strip_on_off
:	verify_on_off opt_blankstrip_on_off
|	blankstrip_on_off opt_verify_on_off
|
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;

opt_ansi_strip_on_off
:	ansi_on_off opt_blankstrip_on_off
|	blankstrip_on_off opt_ansi_on_off
|
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;

opt_ansi_verify_on_off
:	ansi_on_off opt_verify_on_off
|	verify_on_off opt_ansi_on_off
|
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;

opt_verify_on_off
:	verify_on_off
|
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;

opt_autorename_on_off
:	autorename_on_off
|
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;

verify_on_off
:	RIS_TOK_VERIFY on_off
	{
		RISpar_create_tree(RIS_TOK_VERIFY, &_1, 1);
	}
;

opt_ansi_on_off
:	ansi_on_off
|
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;

ansi_on_off
:   RIS_TOK_ANSI on_off
{
		RISpar_create_tree(RIS_TOK_ANSI, &_1, 1);
	}
;

opt_blankstrip_on_off
:   blankstrip_on_off
|
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
	}
;

blankstrip_on_off
:	RIS_TOK_BLANK RIS_TOK_STRIP on_off
	{
		RISpar_create_tree(RIS_TOK_BLANKSTRIP, &_1, 1);
	}
;

autorename_on_off
:	RIS_TOK_AUTORENAME on_off
	{
		RISpar_create_tree(RIS_TOK_AUTORENAME, &_1, 1);
	}
;

set_transaction_action
:	RIS_TOK_AUTOCOMMIT on_off
		{
			RISpar_create_tree(RIS_TOK_AUTOCOMMIT, &_1, 1);
		}
;

set_net_verify_action
:   net_verify_list opt_net_schema_list
;

opt_net_schema_list
:   RIS_TOK_FOR schema_list
|
      {
          RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
      }
;

net_verify_list
:   net_verify_def opt_net_verify_list
        {
            RISpar_create_list(RIS_TOK_PARAM_LIST, &_1, 1);
        }
;

opt_net_verify_list
:   RIS_TOK_COMMA net_verify_def
        {
            RISpar_link_nodes();
        }
    opt_net_verify_list
|
;

net_verify_def
:   RIS_TOK_TIMESTAMP net_timestamp_def
|   RIS_TOK_BUFFER RIS_TOK_FULL net_buffer_def
|   RIS_TOK_INITIAL RIS_TOK_TIMEOUT unsigned_int
        {
            RISpar_create_tree(RIS_TOK_INITIAL_TIMEOUT, &_3, 1);
        }
|   RIS_TOK_RESPONSE RIS_TOK_INTERVAL signed_int
        {
            RISpar_create_tree(RIS_TOK_RESPONSE_INTERVAL, &_3, 1);
        }
;

net_timestamp_def
:   RIS_TOK_INTERVAL unsigned_int
        {
            RISpar_create_tree(RIS_TOK_INTERVAL, &_2, 1);
        }
|   RIS_TOK_TOLERANCE unsigned_int
        {
            RISpar_create_tree(RIS_TOK_TOLERANCE, &_2, 1);
        }
;

net_buffer_def
:   RIS_TOK_SIZE unsigned_int
        {
            RISpar_create_tree(RIS_TOK_BUFFER_SIZE, &_2, 1);
        }
|   RIS_TOK_TIMEOUT unsigned_int
        {
            RISpar_create_tree(RIS_TOK_BUFFER_TIMEOUT, &_2, 1);
        }
;

* query.c **********************************************************************

opt_union_query_expr
:     RIS_TOK_UNION opt_tok_union_all RIS_TOK_SELECT  
		{
			RISpar_no_parms = 1;
		}
	select_list
		{
			RISpar_no_parms = 0;
		}
	table_expr
		{
			if (RISpar_union_all)
			{
				RISpar_create_list(RIS_TOK_UNION_ALL_SELECT, &_1, 5);
			}
			else
			{
				RISpar_create_list(RIS_TOK_UNION_SELECT, &_1, 5);
			}
			RISpar_link_nodes();
		}
	opt_union_query_expr
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

query_expr
:     RIS_TOK_SELECT  
		{
			RISpar_no_parms = 1;
		}
	select_list
		{
			RISpar_no_parms = 0;
		}
	table_expr
		{
			RISpar_create_list(RIS_TOK_SELECT_SELECT, &_1, 5);
		}
	opt_union_query_expr
		{
			RISpar_create_list(RIS_TOK_SELECT_EXPR, &_1, 2);
		}
;

query_spec
:     query_expr
		{
			RISpar_create_list(RIS_TOK_SELECT, &_1, 1);
		}
;

subquery_expr
:     RIS_TOK_SELECT  
		{
			RISpar_no_parms = 1;
		}
	result_list
		{
			RISpar_no_parms = 0;
		}
	table_expr
		{
			RISpar_create_list(RIS_TOK_SELECT_SELECT, &_1, 5);
			RISpar_create_list(RIS_TOK_SELECT_EXPR, &_1, 1);
		}
;

subquery_spec
:     subquery_expr
		{
			RISpar_create_list(RIS_TOK_SELECT, &_1, 1);
		}
;

select_list
:	select_spec
		{
			RISpar_create_tree(RIS_TOK_ALL, 0, 1);
		}
|	RIS_TOK_ALL select_spec
		{
			RISpar_create_tree(RIS_TOK_ALL, &_1, 1);
		}
|	RIS_TOK_DISTINCT select_spec
		{
			RISpar_create_tree(RIS_TOK_DISTINCT, &_1, 1);
		}
;

select_spec
:	value_expr_list
		{
			RISpar_create_list(RIS_TOK_VALUE_EXPR_LIST, &_1, 1);
		}
|	RIS_TOK_MUL
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_MUL, &_1));
		}
;

result_list
:	result_spec
		{
			RISpar_create_tree(RIS_TOK_ALL, 0, 1);
		}
|	RIS_TOK_ALL result_spec
		{
			RISpar_create_tree(RIS_TOK_ALL, &_1, 1);
		}
|	RIS_TOK_DISTINCT result_spec
		{
			RISpar_create_tree(RIS_TOK_DISTINCT, &_1, 1);
		}
;

result_spec
:	value_expr
		{
			RISpar_create_list(RIS_TOK_VALUE_EXPR_LIST, &_1, 1);
		}
|	RIS_TOK_MUL
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_MUL, &_1));
		}
;

table_expr
:	from_clause opt_where_clause opt_group_by_clause opt_having_clause
;

from_clause
:	RIS_TOK_FROM table_list
		{
			RISpar_create_list(RIS_TOK_FROM, &_1, 1);
		}
;

opt_where_clause
:	RIS_TOK_WHERE search_cond
		{
			RISpar_create_tree(RIS_TOK_WHERE, &_1, 1);
		}
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		}
;

opt_group_by_clause
:	RIS_TOK_GROUP RIS_TOK_BY column_spec_list
		{
			RISpar_create_list(RIS_TOK_GROUP_BY, &_1, 1);
		}
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		}
;

opt_having_clause
:	RIS_TOK_HAVING search_cond
		{
			RISpar_create_tree(RIS_TOK_HAVING, &_1, 1);
		}
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		}
;

opt_order_by
:	RIS_TOK_ORDER RIS_TOK_BY sort_spec_list
		{
			RISpar_create_list(RIS_TOK_ORDER_BY, &_1, 1);
		}
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

sort_spec_list
:	sort_spec opt_sort_spec_list
;

opt_sort_spec_list
:	RIS_TOK_COMMA sort_spec
		{
			RISpar_link_nodes();
		}
	opt_sort_spec_list
|	
;

sort_spec
{
	ristree *tp1;
}
:	unsigned_int opt_tok_asc_desc
		{
			tp1 = RISpar_pop();
			RISpar_top()->rhs = tp1;
		}
|	column_spec opt_tok_asc_desc
		{
			tp1 = RISpar_pop();
			RISpar_top()->lhs = tp1;
		}
;

opt_tok_asc_desc
:	RIS_TOK_ASC
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ASC, &_1));
		}
|	RIS_TOK_DESC
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DESC, &_1));
		}
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ASC, &_1));
		}
;

opt_into_clause
:	into_clause
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

into_clause
:	RIS_TOK_INTO
		{
			RISpar_PREPROCESSOR_ONLY();
		}
	target_list
		{
			RISpar_create_list(RIS_TOK_INTO, &_1, 1);
		}
;

target_list
:	var_spec opt_target_list
;

opt_target_list
:	RIS_TOK_COMMA var_spec
		{
			RISpar_link_nodes();
		}
	opt_target_list
|	
;

opt_tok_union_all
:     RIS_TOK_ALL
		{
			RISpar_union_all = 1;
		}
|
		{
			RISpar_union_all = 0;
		}
;

* schema.c *********************************************************************
#include "comalloc.prt"

schema_list
:	auth_id opt_schema_list
		{
			RISpar_create_list(RIS_TOK_SCHEMA_LIST, &_1, 1);
		}
;

opt_schema_list
:	RIS_TOK_COMMA auth_id
		{
			RISpar_link_nodes();
		}
	opt_schema_list
|	
;

schema_spec_list
:	schema_spec opt_schema_spec_list
;

opt_schema_spec_list
:	RIS_TOK_COMMA schema_spec
		{
			RISpar_link_nodes();
		}
	opt_schema_spec_list
|	
;

schema_spec
{
	ristree *tp1;
}
:	auth_id
		{
			RISpar_dot_flag = 1;
		}
	opt_dot_password
		{
			RISpar_dot_flag = 0;
			tp1 = RISpar_pop();
			if (tp1->tok != RIS_TOK_NULL_NODE)
			{
				RISpar_top()->rhs = tp1;
			}
			else
			{
				RISpar_top()->rhs = RISpar_create_tree_node(
				 RIS_TOK_PASSWORD,0);
				RISpar_top()->rhs->info.val = "";
			}
		}
;

auth_id
{
    ristree *tp1;
}
:   RIS_TOK_IDENT
        {
            tp1 = RISpar_create_tree_node(RIS_TOK_AUTH_ID, &_1);

            if(RISpar_new_sch && RISpar_old_sch && tp1->info.val 
			&& strcmp(tp1->info.val, RISpar_old_sch)==0)
            {
                tp1->info.val = ALLOCB(RIS_MAX_ID_SIZE);
                strcpy(tp1->info.val, RISpar_new_sch);
            }
            RISpar_push(tp1);
        }
;

opt_dot_password
:	RIS_TOK_DOT
		{
			RISpar_lex_flag = SPACE_FLAG|COMMA_FLAG|RPAREN_FLAG|SEMICOLON_FLAG;
		}
	password
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

opt_force
:	RIS_TOK_FORCE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_FORCE,0));
		}
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		}
;

opt_force_include_exclude
:	RIS_TOK_INCLUDE opt_force
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_INCLUDE,0));
		}
|	RIS_TOK_EXCLUDE opt_force
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_EXCLUDE,0));
		}
|	RIS_TOK_FORCE opt_include_exclude
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_FORCE,0));
		}
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		}
;

opt_include_exclude
:	RIS_TOK_INCLUDE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_INCLUDE,0));
		}
|	RIS_TOK_EXCLUDE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_EXCLUDE,0));
		}
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		}
;

opt_server_version
:	RIS_TOK_SERVER server_version
|
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
        }
;

server_version
{
	ristree *tp1;
}
:	RIS_TOK_VERSION
		{
			RISpar_lex_flag = SPACE_FLAG|DOT_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT 
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_MAJOR, &_2));
			RISpar_dot_flag = 1;
		}
	opt_dot_feature
        {
			RISpar_dot_flag = 0;
			tp1 = RISpar_pop();
			if (tp1->tok != RIS_TOK_NULL_NODE)
			{
				RISpar_top()->rhs = tp1;
			}
			else
			{
				RISpar_top()->rhs = RISpar_create_tree_node(
					RIS_TOK_FEATURE,0);
			 	RISpar_top()->rhs->info.val = "";
			}
		}
;

opt_dot_feature
:	RIS_TOK_DOT
		{
			RISpar_lex_flag = SPACE_FLAG|COMMA_FLAG|RPAREN_FLAG|SEMICOLON_FLAG;
		}
	feature
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

feature
:	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_FEATURE, &_1));
		}
;

primary_schema
:	RIS_TOK_PRIMARY schema_spec
		{
			RISpar_create_list(RIS_TOK_PRIMARY, &_1, 1);
		}
;

secondary_schema
:	RIS_TOK_SECONDARY schema_spec
		{
			RISpar_create_list(RIS_TOK_SECONDARY, &_1, 1);
		}
;

secondary_schema_list
:   RIS_TOK_SECONDARY schema_spec_list
        {
            RISpar_create_list(RIS_TOK_SECONDARY, &_1, 1);
        }
;

opt_secondary_schema_list
:   secondary_schema_list
|
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
        }
;

opt_using_spec
:	using_spec
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		}
;

using_spec
{
	RISpar_VERSION_5_REQUIRED(RISpar_top()->pos);
}
:	RIS_TOK_USING
		{
			RISpar_lex_flag = SPACE_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_USING_DICT_OWNER, &_2));
		}
;

to_login
:	RIS_TOK_TO
		{
			RISpar_lex_flag = SPACE_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_TO, &_2));
		}
;

from_login
:	RIS_TOK_FROM
		{
			RISpar_lex_flag = SPACE_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_FROM, &_2));
		}
;

* db.c *************************************************************************

opt_on_database
:	RIS_TOK_ON RIS_TOK_DATABASE RIS_TOK_LPAREN db_spec RIS_TOK_RPAREN
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

db_spec
:	db_elem_list
		{
			RISpar_create_list(RIS_TOK_DATABASE, &_1, 1);
		}
;

db_elem_list
:	db_elem opt_db_elem_list
;

opt_db_elem_list
:	RIS_TOK_COMMA db_elem
		{
			RISpar_link_nodes();
		}
	opt_db_elem_list
|	
;

db_elem
{
	ristree *tp1;
}
:	db_type
|	RIS_TOK_DBNAME
		{
			RISpar_lex_flag = SPACE_FLAG|RPAREN_FLAG|COMMA_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DBNAME, &_2));
		}
|   opt_dict_dbname
|	RIS_TOK_DIR
		{
			RISpar_lex_flag = RPAREN_FLAG|COMMA_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT_STB
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DIR, &_2));
		}
|	RIS_TOK_OSTYPE os_type
|	RIS_TOK_OSUSER 
		{
			RISpar_lex_flag =
				SPACE_FLAG|DOT_FLAG|COMMA_FLAG|RPAREN_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT 
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_OSUSER, &_2));
			RISpar_dot_flag = 1;
		}
	opt_dot_password
		{
			RISpar_dot_flag = 0;
			tp1 = RISpar_pop();
			if (tp1->tok != RIS_TOK_NULL_NODE)
				RISpar_top()->rhs = tp1;
		}
|	RIS_TOK_OPTION RIS_TOK_LPAREN
		{
			RISpar_lex_flag = RPAREN_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT RIS_TOK_RPAREN
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_OPTION, &_3));
		}
|	RIS_TOK_REMOTE RIS_TOK_LPAREN proto_addr_list RIS_TOK_RPAREN
		{
			RISpar_create_list(RIS_TOK_REMOTE, &_1, 1);
		}
|	RIS_TOK_GATEWAY RIS_TOK_LPAREN gateway_parm_list RIS_TOK_RPAREN
		{
 	        RISpar_create_list(RIS_TOK_GATEWAY, &_1, 1);
 	    }
;

opt_dict_dbname
:   RIS_TOK_RIS_DICT_DBNAME
        {
            RISpar_lex_flag = SPACE_FLAG|RPAREN_FLAG|COMMA_FLAG|SEMICOLON_FLAG;
        }
    RIS_TOK_CHAR_STR_LIT
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_RIS_DICT_DBNAME, &_2));
        }
|
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
        }
;

db_type
:	RIS_TOK_OS400
		{
			RISpar_VERSION_5_REQUIRED(RISpar_top()->pos);
			RISpar_push(RISpar_create_tree_node(RIS_TOK_OS400, &_1));
		}
|	RIS_TOK_INFORMIX
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_INFORMIX, &_1));
		}
|	RIS_TOK_INGRES
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_INGRES, &_1));
		}
|	RIS_TOK_ORACLE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ORACLE, &_1));
		}
|	RIS_TOK_SQLDS
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_SQLDS, &_1));
		}
|	RIS_TOK_DB2
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DB2, &_1));
		}
|	RIS_TOK_RDB
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_RDB, &_1));
		}
|	RIS_TOK_SYBASE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_SYBASE, &_1));
		}
|   RIS_TOK_MSSQL
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_MSSQL, &_1));
        }
;

os_type
:	RIS_TOK_UNIX
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_OSTYPE, &_1));
	}
|   RIS_TOK_VMS
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_OSTYPE, &_1));
	}
|   RIS_TOK_NT
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_OSTYPE, &_1));
	}
;

proto_addr_list
:	proto_addr opt_proto_addr_list
;

opt_proto_addr_list
:	RIS_TOK_COMMA proto_addr
		{
			RISpar_link_nodes();
		}
	opt_proto_addr_list
|	
;

proto_addr
{
	ristree *tp1;
}
:	protocol
		{
			RISpar_lex_flag = SPACE_FLAG|RPAREN_FLAG|COMMA_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT
		{
			tp1 = RISpar_pop();
			RISpar_push(RISpar_create_tree_node(tp1->tok, &_2));
		}
;

protocol
:	RIS_TOK_XNS
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_XNS, &_1));
		}
|	RIS_TOK_TCP
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_TCP, &_1));
		}
|	RIS_TOK_DNP
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DNP, &_1));
		}
;

gateway_parm_list
:	gateway_parm opt_gateway_parm_list
;

opt_gateway_parm_list
:	RIS_TOK_COMMA gateway_parm
		{
			RISpar_link_nodes();
		}
	opt_gateway_parm_list
|	
;

gateway_parm
{
	ristree *tp1;
}
:	gateway_parm_keyword RIS_TOK_EQ
		{
			RISpar_lex_flag = SPACE_FLAG|RPAREN_FLAG|COMMA_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT
		{
			tp1 = RISpar_pop();
			RISpar_push(RISpar_create_tree_node(tp1->tok, &_3));
		}
;
 
gateway_parm_keyword
:	RIS_TOK_ARCH
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ARCH, &_1));
		}
|	RIS_TOK_OS
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_OS, &_1));
		}
|	RIS_TOK_ENV
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ENV, &_1));
		}
|	RIS_TOK_NET_PROTOCOL
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NET_PROTOCOL, &_1));
		}
|	RIS_TOK_HOST_PROGRAM
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_HOST_PROGRAM, &_1));
		}
|	RIS_TOK_RIS_LU
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_RIS_LU, &_1));
		}
|	RIS_TOK_HOST_LU
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_HOST_LU, &_1));
		}
|	RIS_TOK_MODE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_MODE, &_1));
		}
|	RIS_TOK_GROUP
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_GROUP, &_1));
		}
|   RIS_TOK_NODE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NODE, &_1));
		}
|   RIS_TOK_PORT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_PORT, &_1));
		}
;

* table.c **********************************************************************
#include "comalloc.prt"

table_list
:	table_ref opt_table_list
;

opt_table_list
:	RIS_TOK_COMMA table_ref
		{
			RISpar_link_nodes();
		}
	opt_table_list
|	
;

table_ref
{
	ristree *tp1;
	ristree *tp2;
}
:	table_name opt_alias_name
		{

			tp1 = RISpar_pop();
			if (tp1->tok != RIS_TOK_NULL_NODE)
			{
				tp2 = RISpar_top();
				if (tp2->rhs)
				{
					tp2->rhs->rhs = tp1;
				}
				else
				{
					tp2->rhs = tp1;
				}
			}
		}
;

table_name
{
	ristree *tp1;
	ristree *tp2;
}
:	RIS_TOK_IDENT opt_dot_ident
		{
			tp1 = RISpar_pop();

			if (tp1->tok != RIS_TOK_NULL_NODE)
			{
                tp1->tok = RIS_TOK_TABLE_NAME;
                tp2 = RISpar_create_tree_node(RIS_TOK_AUTH_ID, &_1);
				
                if(RISpar_new_sch && RISpar_old_sch && tp2->info.val && strcmp(tp2->info.val, RISpar_old_sch)==0)
                {
                    tp2->info.val = ALLOCB(RIS_MAX_ID_SIZE);
                    strcpy(tp2->info.val, RISpar_new_sch);
                }
                tp2->rhs = tp1;
                RISpar_push(tp2);
			}
			else
			{
				RISpar_push(RISpar_create_tree_node(RIS_TOK_TABLE_NAME, &_1));
			}
		}
;


opt_alias_name
:	RIS_TOK_IDENT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ALIAS_NAME, &_1));
		}
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

lock_table_mode
:	RIS_TOK_SHARE RIS_TOK_MODE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_SHARE,&_1));
		}
|	RIS_TOK_EXCLUSIVE RIS_TOK_MODE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_EXCLUSIVE,&_1));
		}
|	RIS_TOK_DEFAULT RIS_TOK_MODE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DEFAULT,&_1));
		}
;

* expr.c ***********************************************************************
#include "parexpr.prt"

value_expr_list
:	value_expr opt_value_expr_list
;

opt_value_expr_list
:	RIS_TOK_COMMA value_expr
		{
			RISpar_link_nodes();
		}
	opt_value_expr_list
|	
;

value_expr
:	b_expr
		{
			RISpar_valid_value_expr(RISpar_top());
		}
;

search_cond
:	b_expr
		{
			RISpar_valid_bool_expr(RISpar_top());
		}
;

b_expr
:	b_term b_expr2
;

b_expr2
:	RIS_TOK_OR b_term
	{
		RISpar_create_tree(RIS_TOK_OR, &_1, 2);
	}
	b_expr2
|	
;

b_term
:	b_fact b_term2
;

b_term2
:	RIS_TOK_AND b_fact
	{
		RISpar_create_tree(RIS_TOK_AND, &_1, 2);
	}
	b_term2
|	
;

b_fact
:	predicate
|	RIS_TOK_NOT predicate
	{
		RISpar_create_tree(RIS_TOK_NOT, &_1, 1);
	}
;

v_expr
:	v_term v_expr2
;

v_expr2
:	RIS_TOK_PLUS v_term
	{
		RISpar_create_tree(RIS_TOK_PLUS, &_1, 2);
	}
	v_expr2
|	RIS_TOK_SUB v_term
	{
		RISpar_create_tree(RIS_TOK_SUB, &_1, 2);
	}
	v_expr2
|	
;

v_term
:	v_fact v_term2
;

v_term2
:	RIS_TOK_MUL v_fact
	{
		RISpar_create_tree(RIS_TOK_MUL, &_1, 2);
	}
	v_term2
|	RIS_TOK_DIV v_fact
	{
		RISpar_create_tree(RIS_TOK_DIV, &_1, 2);
	}
	v_term2
|	
;

v_fact
:	primary
|	RIS_TOK_PLUS primary
|	RIS_TOK_SUB primary
	{
		RISpar_create_tree(RIS_TOK_UNARYMINUS, &_1, 1);
	}
;

primary
:	value_spec
|	column_spec
|	set_func_spec
|	datetime_func_spec
|	RIS_TOK_LPAREN paren_primary RIS_TOK_RPAREN
;

paren_primary
:	subquery_spec
|	b_expr
;

* pred.c ***********************************************************************

predicate
:	v_expr predicate2
|	exists_pred
;

predicate2
:	predicates
|	
;

predicates
:	comp_preds
|	not_preds
|	RIS_TOK_NOT not_preds
		{
			RISpar_create_tree(RIS_TOK_NOT, &_1, 1);
		}
|	null_pred
;

comp_preds
{
	ristree *tp1;
	ristree *tp2;
}
:	comp_op comp_arg
		{
			tp1 = RISpar_pop();
			tp2 = RISpar_pop();
			RISpar_push(tp1);
			RISpar_create_tree(tp2->tok, &_1, 2);
		}
;

not_preds
:	between_pred
|	in_pred
|	like_pred
;

exists_pred
:	RIS_TOK_EXISTS RIS_TOK_LPAREN subquery_spec RIS_TOK_RPAREN
		{
			RISpar_create_tree(RIS_TOK_EXISTS, &_1, 1);
		}
;

between_pred
:	RIS_TOK_BETWEEN v_expr RIS_TOK_AND v_expr
		{
			RISpar_create_tree(RIS_TOK_BETWEEN_AND, &_1, 2);
			RISpar_create_tree(RIS_TOK_BETWEEN, &_1, 2);
		}
;

in_pred
:	RIS_TOK_IN RIS_TOK_LPAREN in_pred_arg RIS_TOK_RPAREN
		{
			RISpar_create_tree(RIS_TOK_IN, &_1, 2);
		}
;

like_pred
{
	ristree *tp1;
}
:
		{
			tp1 = RISpar_top();
			if (tp1->tok != RIS_TOK_AUTH_ID &&
				tp1->tok != RIS_TOK_TABLE_NAME &&
				tp1->tok != RIS_TOK_COL_NAME)
			{
				RISpar_ERR_RETURN(RIS_E_INV_COLUMN_SPEC, tp1->pos);
			}
		}
	RIS_TOK_LIKE value_spec
		{
			RISpar_create_tree(RIS_TOK_LIKE, &_1, 2);
		}
;

null_pred
{
	ristree *tp1;
}
:	
		{
			tp1 = RISpar_top();
			if (tp1->tok != RIS_TOK_AUTH_ID &&
				tp1->tok != RIS_TOK_TABLE_NAME &&
				tp1->tok != RIS_TOK_COL_NAME)
			{
				RISpar_ERR_RETURN(RIS_E_INV_COLUMN_SPEC, tp1->pos);
			}
		}
	RIS_TOK_IS opt_tok_not RIS_TOK_NULL
		{
			tp1 = RISpar_pop();
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL, &_3));
			RISpar_create_tree(RIS_TOK_IS, &_1, 2);
			if (tp1->tok == RIS_TOK_NOT)
			{
				tp1->rhs = RISpar_pop();
				RISpar_push(tp1);
			}
		}
;

comp_op
:	RIS_TOK_EQ
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_EQ, &_1));
		}
|	RIS_TOK_NE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NE, &_1));
		}
|	RIS_TOK_LT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_LT, &_1));
		}
|	RIS_TOK_GT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_GT, &_1));
		}
|	RIS_TOK_LE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_LE, &_1));
		}
|	RIS_TOK_GE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_GE, &_1));
		}
;

comp_arg
:	unquantified_comp_arg
|	quantified_comp_arg
;

unquantified_comp_arg
:	v_expr
;

quantified_comp_arg
{
	ristree *tp1;
	ristree *tp2;
}
:	quantifier RIS_TOK_LPAREN subquery_spec RIS_TOK_RPAREN
		{
			tp1 = RISpar_pop();
			tp2 = RISpar_pop();
			RISpar_push(tp1);
			RISpar_create_tree(tp2->tok, &_1, 1);
		}
;

in_pred_arg
:	subquery_spec
|	in_value_list
		{
			RISpar_create_list(RIS_TOK_VALUES, &_1, 1);
		}
;

in_value_list
:	signed_value_spec opt_in_value_list
;

opt_in_value_list
:	RIS_TOK_COMMA signed_value_spec
		{
			RISpar_link_nodes();
		}
	opt_in_value_list
|	
;

quantifier
:	RIS_TOK_ALL
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ALL, &_1));
		}
|	RIS_TOK_SOME
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ANY, &_1));
		}
|	RIS_TOK_ANY
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ANY, &_1));
		}
;

opt_tok_not
:	RIS_TOK_NOT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NOT, &_1));
		}
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

* column.c *********************************************************************
#include "comalloc.prt"

column_def_list
:	column_def opt_column_def_list
		{
			RISpar_create_list(RIS_TOK_COLUMN_DEF_LIST, &_1, 1);
		}
;

opt_column_def_list
:	RIS_TOK_COMMA column_def
		{
			RISpar_link_nodes();
		}
	opt_column_def_list
|	
;

column_def
:	column_name data_type opt_tok_not_null
		{
			RISpar_create_list(RIS_TOK_COLUMN_DEF, &_1, 3);
		}
;

declare_col_def_list
:	declare_col_def opt_declare_col_def_list
		{
			RISpar_create_list(RIS_TOK_COLUMN_DEF_LIST, &_1, 1);
		}
;

opt_declare_col_def_list
:	RIS_TOK_COMMA declare_col_def
		{
			RISpar_link_nodes();
		}
	opt_declare_col_def_list
|	
;

declare_col_def
:	column_name declare_data_type opt_tok_not_null
		{
			RISpar_create_list(RIS_TOK_COLUMN_DEF, &_1, 3);
		}
;

column_name
:	RIS_TOK_IDENT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_COL_NAME, &_1));
		}
;

opt_col_list
:	RIS_TOK_LPAREN column_list RIS_TOK_RPAREN
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		}
;

column_list
:	column_name opt_column_list
		{
			RISpar_create_list(RIS_TOK_COLUMN_LIST, &_1, 1);
		}
;

opt_column_list
:	RIS_TOK_COMMA column_name
		{
			RISpar_link_nodes();
		}
	opt_column_list
|	
;


column_spec_list
:	column_spec opt_column_spec_list
;

opt_column_spec_list
:	RIS_TOK_COMMA column_spec
		{
			RISpar_link_nodes();
		}
	opt_column_spec_list
|	
;


column_spec
{
	ristree *tp1;
	ristree *tp2;
	ristree *tp3;
}
:	RIS_TOK_IDENT opt_dot_ident_opt_dot_ident
		{
			tp2 = RISpar_pop();
			tp1 = RISpar_pop();
			if (tp1->tok != RIS_TOK_NULL_NODE)
			{
				/*
				**	schema.table.column
				*/

				tp1->tok = RIS_TOK_COL_NAME;

				tp2->tok = RIS_TOK_TABLE_NAME;
				tp2->rhs = tp1;

				tp3 = RISpar_create_tree_node(RIS_TOK_AUTH_ID, &_1);
				
                if(RISpar_new_sch && RISpar_old_sch && tp3->info.val && strcmp(tp3->info.val, RISpar_old_sch)==0)
                {
                    tp3->info.val = ALLOCB(RIS_MAX_ID_SIZE);
                    strcpy(tp3->info.val, RISpar_new_sch);
                }
				tp3->rhs = tp2;
				RISpar_push(tp3);
			}
			else if (tp2->tok != RIS_TOK_NULL_NODE)
			{
				/*
				**	table.column
				*/
				tp2->tok = RIS_TOK_COL_NAME;

				tp3 = RISpar_create_tree_node(RIS_TOK_TABLE_NAME, &_1);
				tp3->rhs = tp2;
				RISpar_push(tp3);
			}
			else
			{
				/*
				**	column
				*/
				tp3 = RISpar_create_tree_node(RIS_TOK_COL_NAME, &_1);
				RISpar_push(tp3);
			}
		}
;


opt_tok_not_null
:	RIS_TOK_NOT RIS_TOK_NULL
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NOT_NULL, &_1));
		}
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

* type.c ***********************************************************************

data_type
:	approx_num_type
|	char_str_type
|	datetime_type
|	exact_num_type
|   ris_blob_type
|   ris_text_type
;

declare_data_type
:	unsupported_type
|	approx_num_type
|	char_str_type
|	datetime_type
|	exact_num_type
|   ris_blob_type
|   ris_text_type
;

approx_num_type
:	RIS_TOK_REAL
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_REAL, &_1));
		}
|	RIS_TOK_DOUBLE opt_tok_precision
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DOUBLE, &_1));
		}
;

char_str_type
:	character opt_length
		{
			RISpar_create_tree(RIS_TOK_CHAR, &_1, 1);
		}
;

datetime_type
:	RIS_TOK_TIMESTAMP
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_TIMESTAMP, &_1));
		}
;

ris_blob_type
:   RIS_TOK_RIS_BLOB opt_blob_or_text_length
        {
            RISpar_create_tree(RIS_TOK_RIS_BLOB, &_1, 1);
        }
;

ris_text_type
:   RIS_TOK_RIS_TEXT opt_blob_or_text_length
        {
            RISpar_create_tree(RIS_TOK_RIS_TEXT, &_1, 1);
        }
;

exact_num_type
:	decimal opt_precision_scale
		{
			RISpar_create_tree(RIS_TOK_DECIMAL, &_1, 1);
		}
|	integer
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_INT, &_1));
		}
|	RIS_TOK_SMALLINT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_SMALLINT, &_1));
		}
;

unsupported_type
: RIS_TOK_UNSUPPORTED
		{
        	RISpar_push(RISpar_create_tree_node(RIS_TOK_UNSUPPORTED, &_1));
		}
;

character
:	RIS_TOK_CHARACTER
|	RIS_TOK_CHAR
;

decimal
:	RIS_TOK_DECIMAL
|	RIS_TOK_DEC
;

integer
:	RIS_TOK_INTEGER
|	RIS_TOK_INT
;

opt_tok_precision
:	RIS_TOK_PRECISION
|	
;

opt_length
:	RIS_TOK_LPAREN unsigned_int RIS_TOK_RPAREN
|	
		{
			{
				lex_s temp;

				temp.pos = 0;
				temp.val = "1";
				RISpar_push(RISpar_create_tree_node(RIS_TOK_EXACT_NUM_LIT,
					&temp));
			}
		}
;

opt_blob_or_text_length
:	RIS_TOK_LPAREN unsigned_int RIS_TOK_RPAREN
|	
		{
			{
				lex_s temp;

				temp.pos = 0;
				temp.val = "0";
				RISpar_push(RISpar_create_tree_node(RIS_TOK_EXACT_NUM_LIT,
					&temp));
			}
		}
;

opt_precision_scale
{
	ristree *tp1;
}
:	RIS_TOK_LPAREN unsigned_int opt_comma_unsigned_int RIS_TOK_RPAREN
		{
			if ((tp1 = RISpar_pop())->tok != RIS_TOK_NULL_NODE)
			{
				RISpar_top()->rhs = tp1;
			}
		}
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

opt_comma_unsigned_int
:	RIS_TOK_COMMA unsigned_int
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

* value.c **********************************************************************
#include "comalloc.prt"

value_spec
:	parm_spec
|	var_spec
|	literal
|	user
;

signed_value_spec
:	parm_spec
|	var_spec
|	signed_literal
|	user
;

parm_spec
{
	RISpar_CLIENT_ONLY();
}
:	RIS_TOK_QUESTION
		{
			if (RISpar_no_parms)
			{
				RISpar_ERR_RETURN(RIS_E_NOT_IMPLEMENTED, _1.pos);
			}
			RISpar_push(RISpar_create_tree_node(RIS_TOK_QUESTION, &_1));
		}
;

var_spec
{
	ristree *tp1;

	RISpar_PREPROCESSOR_ONLY();
}
:	var_name opt_indict_var
		{
			if (RISpar_no_parms)
			{
				RISpar_ERR_RETURN(RIS_E_NOT_IMPLEMENTED, _1.pos);
			}

			if ((tp1 = RISpar_pop())->tok != RIS_TOK_NULL_NODE)
			{
				RISpar_top()->rhs = tp1;
			}
		}
;

var_name
:	RIS_TOK_COLON
		{
			RISpar_host_ident_flag = 1;
		}
	RIS_TOK_IDENT
		{
			RISpar_host_ident_flag = 0;
			RISpar_push(RISpar_create_tree_node(RIS_TOK_VAR_NAME, &_2));
		}
;

opt_indict_var
:	indict_var
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

indict_var
:	RIS_TOK_INDICATOR var_name
|	var_name
;

user
:	RIS_TOK_USER
		{
			if (PREPROCESSOR)
			{
				_1.val = 0;
				RISpar_push(RISpar_create_tree_node(RIS_TOK_USER, &_1));
			}
			else
			{
				int len;

				if (!RISpar_schema)
					RISpar_ERR_RETURN(RIS_E_INTERNAL_ERROR, _1.pos);

				_1.val = ALLOCB(RIS_MAX_ID_SIZE + 2);
				len = strlen(RISpar_schema->schname);
				_1.val[0] = '\'';
				memcpy(&(_1.val[1]), RISpar_schema->schname,len);
				_1.val[len+1] = '\'';
				_1.val[len+2] = '\0';
				RISpar_push(RISpar_create_tree_node(RIS_TOK_CHAR_STR_LIT, &_1));
			}
		}
;

* literal.c ********************************************************************
#include "pardate.prt"
#include "comalloc.prt"

signed_literal
:	char_str_lit
|	signed_numeric_lit
|	datetime_lit
;

literal
:	char_str_lit
|	numeric_lit
|	datetime_lit
;

c_char_str_lit
:	RIS_TOK_C_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_C_CHAR_STR_LIT, &_1));
		}
;

char_str_lit
:	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_CHAR_STR_LIT, &_1));
		}
;

signed_numeric_lit
{
	ristree *tp1;
}
:	numeric_lit
|	RIS_TOK_PLUS numeric_lit
		{
			RISpar_top()->pos = (unsigned short)_1.pos;
		}
|	RIS_TOK_SUB numeric_lit
		{
			{
				char	*temp;
				int		length;

				tp1 = RISpar_top();
				tp1->pos = (unsigned short)_1.pos;
				temp = tp1->info.val;
				length = strlen(temp) + 1;
				tp1->info.val = ALLOCB(length + 1);
				tp1->info.val[0] = '-';
				memcpy(&(tp1->info.val[1]), temp, length);
			}
		}
;

numeric_lit
:	approx_num_lit
|	exact_num_lit
;

approx_num_lit
:	RIS_TOK_APPROX_NUM_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_APPROX_NUM_LIT, &_1));
		}
;

exact_num_lit
:	RIS_TOK_EXACT_NUM_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_EXACT_NUM_LIT, &_1));
		}
;

datetime_lit
{
	ristree *tp1;
}
:	RIS_TOK_TIMESTAMP RIS_TOK_CHAR_STR_LIT
		{
			tp1 = RISpar_create_tree_node(RIS_TOK_TIMESTAMP_LIT, &_2);
			RISpar_parse_datetime(tp1);

			tp1->pos = (unsigned short)_1.pos;
			RISpar_push(tp1);
		}
;

* set_func.c *******************************************************************

set_func_spec
:	RIS_TOK_AVG RIS_TOK_LPAREN set_func_arg RIS_TOK_RPAREN
		{
			RISpar_create_tree(RIS_TOK_AVG, &_1, 2);
		}
|	RIS_TOK_MAX RIS_TOK_LPAREN set_func_arg RIS_TOK_RPAREN
		{
			RISpar_create_tree(RIS_TOK_MAX, &_1, 2);
		}
|	RIS_TOK_MIN RIS_TOK_LPAREN set_func_arg RIS_TOK_RPAREN
		{
			RISpar_create_tree(RIS_TOK_MIN, &_1, 2);
		}
|	RIS_TOK_SUM RIS_TOK_LPAREN set_func_arg RIS_TOK_RPAREN
		{
			RISpar_create_tree(RIS_TOK_SUM, &_1, 2);
		}
|	RIS_TOK_COUNT RIS_TOK_LPAREN count_func_arg RIS_TOK_RPAREN
		{
			RISpar_create_tree(RIS_TOK_COUNT, &_1, 2);
		}
;

set_func_arg
{
	ristree *tp1;
}
:	RIS_TOK_DISTINCT column_spec
		{
			tp1 = RISpar_pop();
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DISTINCT, &_1));
			RISpar_push(tp1);
		}
|	RIS_TOK_ALL value_expr
		{
			tp1 = RISpar_pop();
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ALL, &_1));
			RISpar_push(tp1);
		}
|	value_expr
		{
			tp1 = RISpar_pop();
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ALL, 0));
			RISpar_push(tp1);
		}
;

count_func_arg
{
	ristree *tp1;
}
:	RIS_TOK_MUL
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, &_1));
			RISpar_push(RISpar_create_tree_node(RIS_TOK_MUL, &_1));
		}
|	RIS_TOK_DISTINCT column_spec
		{
			tp1 = RISpar_pop();
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DISTINCT, &_1));
			RISpar_push(tp1);
		}
;

* misc.c ***********************************************************************

async_id
:	RIS_TOK_COLON
		{
			RISpar_host_ident_flag = 1;
		}
	RIS_TOK_IDENT
		{
			RISpar_host_ident_flag = 0;
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ASYNC_ID, &_2));
		}
;

async_id_list
:	async_id opt_async_id_list
		{
			RISpar_create_list(RIS_TOK_ASYNC_ID_LIST, &_1, 1);
		}
;

opt_async_id_list
:	RIS_TOK_COMMA async_id
		{
			RISpar_link_nodes();
		}
	opt_async_id_list
|	
;

cursor_name
:	RIS_TOK_IDENT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_CURSOR_NAME, &_1));
		}
;

datetime_func_spec
:	RIS_TOK_CURRENT_TIMESTAMP
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_CURRENT_TIMESTAMP,&_1));
		}
;

descriptor
:	RIS_TOK_DESCRIPTOR
		{
			RISpar_host_ident_flag = 1;
		}
	RIS_TOK_IDENT
		{
			RISpar_host_ident_flag = 0;
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DESC_NAME, &_2));
		}
;

fetch_stmt_arg
:	using_clause
|	into_clause
;

index_name
:	RIS_TOK_IDENT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_INDEX_NAME, &_1));
		}
;

on_off
:	RIS_TOK_ON
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ON, &_1));
		}
|	RIS_TOK_OFF
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_OFF, &_1));
		}
;

opt_dot_ident
:	RIS_TOK_DOT RIS_TOK_IDENT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_IDENT, &_2));
		}
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

opt_dot_ident_opt_dot_ident
:   RIS_TOK_DOT RIS_TOK_IDENT opt_dot_ident
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_IDENT, &_2));
        }
|
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
            RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
        }
;

opt_for_async_id
:	RIS_TOK_FOR RIS_TOK_ASYNC var_name
		{
			RISpar_create_tree(RIS_TOK_ASYNC, &_1, 1);
		}	
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

opt_into_var
:	RIS_TOK_INTO var_name
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

opt_password
		{
			RISpar_lex_flag = SPACE_FLAG|COMMA_FLAG|SEMICOLON_FLAG;
		}
:	password
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

opt_signed_int
:	signed_int
|	
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		}
;

opt_schema_option
: RIS_TOK_FOR auth_id
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DEFAULT, 0));
		}
;

opt_tok_authorization
:	RIS_TOK_AUTHORIZATION
|
;

opt_tok_work
:	RIS_TOK_WORK
|
;

opt_using_clause
:	using_clause
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		}
;

password
:	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_PASSWORD, &_1));
		}
;

schema_id
:	auth_id
|	var_name
;

signed_int
:	signed_numeric_lit
		{
			{
				extern char *strchr();

				if (strchr(_1.val,'.'))
					RISpar_ERR_RETURN(RIS_E_MUST_BE_UINT, _1.pos);
			}
		}
;

stmt_id
:	RIS_TOK_IDENT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_STMT_ID, &_1));
		}
;

string_spec
:	c_char_str_lit
|	var_spec
;

test_cond
:   RIS_TOK_ANY
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_ANY, &_1));
        }
|   RIS_TOK_ALL
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_ALL, &_1));
        }
|   async_id_list
|	using_clause
;

unsigned_int
:	exact_num_lit
		{
			{
				extern char *strchr();

				if (strchr(_1.val,'.'))
					RISpar_ERR_RETURN(RIS_E_MUST_BE_UINT, _1.pos);
			}
		}
;

opt_user_spec
:	user_spec
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

user_spec
{
	ristree *tp1;
}
:	RIS_TOK_USER 
		{
			RISpar_lex_flag =
				SPACE_FLAG|DOT_FLAG|COMMA_FLAG|RPAREN_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT 
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_USER, &_2));
			RISpar_dot_flag = 1;
		}
	opt_dot_password
        {
			RISpar_dot_flag = 0;
			tp1 = RISpar_pop();
			if (tp1->tok != RIS_TOK_NULL_NODE)
			{
				RISpar_top()->rhs = tp1;
			}
			else
			{
				RISpar_top()->rhs = RISpar_create_tree_node(
					RIS_TOK_PASSWORD,0);
			 	RISpar_top()->rhs->info.val = "";
			}
		}
;

opt_osuser_spec
:     osuser_spec
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

osuser_spec
{
	ristree *tp1;
}
:	RIS_TOK_OSUSER
		{
			RISpar_lex_flag =
				SPACE_FLAG|DOT_FLAG|COMMA_FLAG|RPAREN_FLAG|SEMICOLON_FLAG;
		}
	RIS_TOK_CHAR_STR_LIT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_OSUSER, &_2));
			RISpar_dot_flag = 1;
		}
	opt_dot_password
		{
			RISpar_dot_flag = 0;
			tp1 = RISpar_pop();
			if (tp1->tok != RIS_TOK_NULL_NODE)
			{
				RISpar_top()->rhs = tp1;
			}
			else
			{
				RISpar_top()->rhs = RISpar_create_tree_node(
						RIS_TOK_PASSWORD,0);
				RISpar_top()->rhs->info.val = "";
			}
		}
;

using_clause
:	RIS_TOK_USING using_clause_arg
		{
			if (RISpar_top()->tok == RIS_TOK_DESC_NAME)
				RISpar_create_tree(RIS_TOK_USING, &_1, 1);
			else
				RISpar_create_list(RIS_TOK_USING, &_1, 1);
		}
;

using_clause_arg
:	target_list
|	descriptor
;

whenever_action
:	RIS_TOK_CONTINUE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_CONTINUE, &_1));
		}
|	RIS_TOK_GOTO RIS_TOK_COLON
		{
			RISpar_host_ident_flag = 1;
		}
	RIS_TOK_IDENT
		{
			RISpar_host_ident_flag = 0;
			RISpar_push(RISpar_create_tree_node(RIS_TOK_HOST_IDENT, &_3));
			RISpar_create_tree(RIS_TOK_GOTO, &_1, 1);
		}
|	RIS_TOK_GO RIS_TOK_TO RIS_TOK_COLON
		{
			RISpar_host_ident_flag = 1;
		}
	 RIS_TOK_IDENT
		{
			RISpar_host_ident_flag = 0;
			RISpar_push(RISpar_create_tree_node(RIS_TOK_HOST_IDENT, &_4));
			RISpar_create_tree(RIS_TOK_GOTO, &_1, 1);
		}
;

whenever_cond
:	RIS_TOK_SQLERROR
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_SQLERROR,&_1));
		}
|	RIS_TOK_NOT RIS_TOK_FOUND
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NOT_FOUND,&_1));
		}
;


dbms_table_name
:   RIS_TOK_IDENT
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_TABLE_NAME, &_1));
        }
;

opt_internal_table_col_list
:   RIS_TOK_AS table_name opt_col_list 
	{	
    	RISpar_create_list(RIS_TOK_AS, &_1, 2);
	}
|  
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
	}
;


opt_internal_index
:   RIS_TOK_AS index_name
   	{
   		RISpar_create_list(RIS_TOK_AS, &_1, 1);
	}
|
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
	}
;

alter_table_action
:	RIS_TOK_ADD column_def opt_external_column
		{
			RISpar_create_tree(RIS_TOK_ADD, &_1, 2);
		}
;

opt_external_column
:	RIS_TOK_EXTERN column_name
		{
			RISpar_create_list(RIS_TOK_EXTERN, &_1, 1);
		}
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

* privs.c **********************************************************************

grant_privileges
:	RIS_TOK_ALL opt_tok_privileges
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ALL, &_1));
		}
|	grant_privilege_list
;

grant_privilege_list
:	grant_privilege opt_grant_privilege_list
		{
			RISpar_create_list(RIS_TOK_PRIVILEGE_LIST, &_1, 1);
		}
;

opt_grant_privilege_list
:	RIS_TOK_COMMA grant_privilege
		{
			RISpar_link_nodes();
		}
	opt_grant_privilege_list
|	
;

grant_privilege
:	RIS_TOK_SELECT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_SELECT, &_1));
		}
|	RIS_TOK_INSERT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_INSERT, &_1));
		}
|	RIS_TOK_UPDATE opt_col_list
		{
			RISpar_create_tree(RIS_TOK_UPDATE, &_1, 1);
		}
|	RIS_TOK_DELETE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DELETE, &_1));
		}
;

grantee_list
:	grantee opt_grantee_list
		{
			RISpar_create_list(RIS_TOK_GRANTEE_LIST, &_1, 1);
		}
;

opt_grantee_list
:	RIS_TOK_COMMA grantee
		{
			RISpar_link_nodes();
		}
	opt_grantee_list
|	
;

grantee
:	RIS_TOK_PUBLIC
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_PUBLIC, &_1));
		}
|	auth_id
;


revoke_privileges
:	RIS_TOK_ALL opt_tok_privileges
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_ALL, &_1));
		}
|	revoke_privilege_list
;

revoke_privilege_list
:	revoke_privilege opt_revoke_privilege_list
		{
			RISpar_create_list(RIS_TOK_PRIVILEGE_LIST, &_1, 1);
		}
;

opt_revoke_privilege_list
:	RIS_TOK_COMMA revoke_privilege
		{
			RISpar_link_nodes();
		}
	opt_revoke_privilege_list
|	
;

revoke_privilege
:	RIS_TOK_SELECT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_SELECT, &_1));
		}
|	RIS_TOK_INSERT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_INSERT, &_1));
		}
|	RIS_TOK_UPDATE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_UPDATE, &_1));
		}
|	RIS_TOK_DELETE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DELETE, &_1));
		}
;

opt_tok_privileges
:	RIS_TOK_PRIVILEGES
|	
;

opt_tok_with_grant_option
:	RIS_TOK_WITH RIS_TOK_GRANT RIS_TOK_OPTION
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_GRANT, &_1));
		}
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE, 0));
		}
;

opt_with_verify_option
:   RIS_TOK_WITH with_verify_option_action
|
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_NO_VERIFY, 0));
        }
;

with_verify_option_action
:   RIS_TOK_PARTIAL RIS_TOK_VERIFY RIS_TOK_OPTION
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_PARTIAL, 0));
        }
|   RIS_TOK_VERIFY RIS_TOK_OPTION
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_VERIFY, 0));
        }
;

* update.c *********************************************************************

set_list
:	set_expr opt_set_list
		{
			RISpar_create_list(RIS_TOK_SET,&_1,1);
		}
;

opt_set_list
:	RIS_TOK_COMMA set_expr
		{
			RISpar_link_nodes();
		}
	opt_set_list
|	
;

set_expr
:	column_name RIS_TOK_EQ set_expr_arg
		{
			RISpar_create_tree(RIS_TOK_ASGN,&_2,2);
		}
;

set_expr_arg
:	value_expr
|	RIS_TOK_NULL
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL, &_1));
		}
;

insert_values
:	RIS_TOK_VALUES RIS_TOK_LPAREN insert_val_list RIS_TOK_RPAREN
		{
			RISpar_create_list(RIS_TOK_VALUES, &_3, 1);
		}
|	query_spec
;

insert_val_list
:	insert_val opt_insert_val_list
;

opt_insert_val_list
:	RIS_TOK_COMMA insert_val
		{
			RISpar_link_nodes();
		}
	opt_insert_val_list
|	
;

insert_val
:	signed_value_spec
|	datetime_func_spec
|	RIS_TOK_NULL
	{
		RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL,&_1));
	}
;

* host.c ***********************************************************************

host_storage_class
:	RIS_TOK_AUTO
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_AUTO, &_1));
		}
|	RIS_TOK_EXTERN
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_EXTERN, &_1));
		}
|	RIS_TOK_REGISTER
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_REGISTER, &_1));
		}
|	RIS_TOK_STATIC
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_STATIC, &_1));
		}
;

host_type_spec_list
:	host_type_spec opt_host_type_spec_list
		{
			RISpar_create_list(RIS_TOK_HOST_TYPE_SPEC_LIST, &_1, 1);
		}
;

opt_host_type_spec_list
:	host_type_spec
		{
			RISpar_link_nodes();
		}
	opt_host_type_spec_list
|	
;

host_type_spec
:	RIS_TOK_CHAR
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_CHAR, &_1));
		}
|	RIS_TOK_SHORT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_SHORT, &_1));
		}
|	RIS_TOK_INT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_INT, &_1));
		}
|	RIS_TOK_LONG
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_LONG, &_1));
		}
|	RIS_TOK_UNSIGNED
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_UNSIGNED, &_1));
		}
|	RIS_TOK_FLOAT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_FLOAT, &_1));
		}
|	RIS_TOK_DOUBLE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DOUBLE,&_1));
		}
|	RIS_TOK_SQLDA
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_SQLDA,&_1));
		}
|	RIS_TOK_STRUCT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_STRUCT,&_1));
		}
|	RIS_TOK_DATETIME
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_DATETIME,&_1));
		}
|	RIS_TOK_SIGNED
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_SIGNED, &_1));
		}
|	RIS_TOK_VOLATILE
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_VOLATILE, &_1));
		}
|	RIS_TOK_CONST
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_CONST, &_1));
		}
|   RIS_TOK_RIS_BLOB
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_RIS_BLOB,&_1));
        }
|   RIS_TOK_RIS_TEXT
        {
            RISpar_push(RISpar_create_tree_node(RIS_TOK_RIS_TEXT,&_1));
        }
;

host_var_list
:	host_var opt_host_var_list
		{
			RISpar_create_list(RIS_TOK_HOST_VAR_LIST, &_1, 1);
		}
;

opt_host_var_list
:	RIS_TOK_COMMA host_var
		{
			RISpar_link_nodes();
		}
	opt_host_var_list
|	
;

host_var
:	star_list host_ident opt_array_spec_list
		{
			RISpar_create_list(RIS_TOK_HOST_VAR, &_2, 3);
		}
|	host_ident opt_array_spec_list
		{
			RISpar_create_list(RIS_TOK_HOST_VAR, &_1, 2);
		}
;

virtual_host_var
:	star_list host_ident
		{
			RISpar_host_ident_flag = 0;
		}
	opt_array_spec_list
		{
			RISpar_create_list(RIS_TOK_HOST_VAR, &_2, 3);
		}
|	host_ident
		{
			RISpar_host_ident_flag = 0;
		}
	opt_array_spec_list
		{
			RISpar_create_list(RIS_TOK_HOST_VAR, &_1, 2);
		}
;

star_list
:	star opt_star_list
		{
			RISpar_create_list(RIS_TOK_STAR_LIST,&_1,1);
		}
;

opt_star_list
:	star
		{
			RISpar_link_nodes();
		}
	opt_star_list
|	
;

star
:	RIS_TOK_MUL
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_MUL,&_1));
		}
;

host_ident
:	RIS_TOK_IDENT
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_HOST_IDENT,&_1));
		}
;

opt_array_spec_list
:	array_spec_list
|
		{
			RISpar_push(RISpar_create_tree_node(RIS_TOK_NULL_NODE,0));
		}
;

array_spec_list
:	array_spec opt_array_specs
		{
			RISpar_create_list(RIS_TOK_ARRAY_SPEC_LIST,&_1,1);
		}
;

opt_array_specs
:	array_spec
		{
			RISpar_link_nodes();
		}
	opt_array_specs
|	
;

array_spec
:	RIS_TOK_LBRACK unsigned_int RIS_TOK_RBRACK
;
