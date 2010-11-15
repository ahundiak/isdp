/*
**	NAME:							usrexec.c
**	AUTHORS:						David Michal
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY: 'set mode' case added by Prasad Challa. 10/91
**				12/91 sjb split into start_exec and finish_exec. Added async
**		10/24/94 Radha
**			Added changes for MSSQL dat server.
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "riscl_sr.h"
#include "riscli.h"
#include "rishshtb.h"
#include "rismem.h"
#include "ristoken.h"
#include "user.h"

/*
**	FUNCTION PROTOTYPES
*/
#define usrexec_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "comstrng.prt"
#include "ccoeot.prt"
#include "ccostmgr.prt"
#include "dicalsch.prt"
#include "dicclsch.prt"
#include "diccrsch.prt"
#include "dicdcsch.prt"
#include "dicdecss.prt"
#include "dicdrsch.prt"
#include "dicgrant.prt"
#include "dicindex.prt"
#include "diclook.prt"
#include "dicopsch.prt"
#include "dictable.prt"
#include "dicrdcss.prt"
#include "dicrevk.prt"
#include "dicundss.prt"
#include "dicview.prt"
#include "usrexec.prt"
#include "usrtab.prt"
#include "usrsndrc.prt"
#include "sys.prt"
/* BLOB */
#include "usrexebl.prt"

/*
**	DEFINES
*/
/*  The blobinfo:
             7 6  5 4  3 2  1 0
             | |  | |  | |  | |
             | |  | |  | |  | |
             | |  | |Unused | |
             | |  | |       | - more_blob_data_to_follow
             | |  | |        -- more_blob_col_to_follow
             | |  | local_file
             | |  remote_file
             | deffered_code
             execblob_code
*/

#define MORE_BLOB_COL_TO_FOLLOW (blobinfo & 0x02)
#define BLOB_EXEC      (blobinfo & 0x80)
#define DEFERRED_EXEC  (blobinfo & 0x40)

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

/*
** This function routes statements to the appropriate function for execution.
** User side transaction status is set and used here.
*/

extern void RISusr_exec_stmt(
	risstmt			*stmt,
	unsigned char   execute_mode,
	unsigned int    blobinfo)
{
	int			i;
	int			status = 0;
	char		opcode;
	ristree		*tp;
	risschema	*schema;
	unsigned int enabled_dbms;
    struct ristimestamp timestamp;
    struct ristimestamp *tsp = 0;
    ristree *schp;
    ristree *pp;
    int interval_flag = 0;
    int tolerance_flag = 0;
    int buffer_size_flag = 0;
    int buffer_timeout_flag = 0;
    int initial_timeout_flag = 0;
	int response_interval_flag = 0;

	USR_DBG(("RISusr_exec_stmt(stmt:0x%x execute_mode:0x%x)\n",
		stmt, execute_mode));

	switch(stmt->tree->tok)
	{

/*
**  This set of DDL statements does not effect a transactions (supposedly).
**  Does not implicitly commit after its execution.
*/

		case RIS_TOK_DEFAULT_SCHEMA:
			RISdic_default_schema(stmt->tree->rhs->lhs->info.val,
				stmt->tree->rhs->lhs->rhs->info.val, execute_mode);
		break;

/*
** Only allow these DDL statements if not in a transaction.
** These DDL statements are autocommit
*/

		case RIS_TOK_CREATE_VIEW:
		case RIS_TOK_DROP_VIEW:
		case RIS_TOK_ALTER_TABLE:
		case RIS_TOK_CREATE_TABLE:
		case RIS_TOK_DROP_TABLE:
		case RIS_TOK_CREATE_INDEX:
		case RIS_TOK_DROP_INDEX:
		case RIS_TOK_GRANT:
		case RIS_TOK_GRANT_ON_TABLE:
		case RIS_TOK_REVOKE:
		case RIS_TOK_REVOKE_ON_TABLE:
		case RIS_TOK_DECLARE_TABLE:
		case RIS_TOK_DECLARE_VIEW:
		case RIS_TOK_UNDECLARE_TABLE:
		case RIS_TOK_UNDECLARE_VIEW:
		case RIS_TOK_CREATE_SCHEMA:
		case RIS_TOK_DROP_SCHEMA:
		case RIS_TOK_ALTER_SCHEMA:
			if (IN_START_MODE(execute_mode))
			{
				if (RISusr_search_sch_in_transact(stmt->sql->schema))
				{
					if (RIS_autocommit)
					{
						RISusr_close_all_cursors_for_sch(stmt->sql->schema);
						RISusr_remove_sch_from_transact(stmt->sql->schema);
					}
					else
					{
						LONGJMP(RIS_E_DDL_NOT_ALLOWED);
					}
				}
				else
				{
					RISusr_validate_room_in_transact();
				}
			}
			switch(stmt->tree->tok)
			{
				case RIS_TOK_CREATE_VIEW:
					RISdic_create_view(stmt, execute_mode);
				break;
				case RIS_TOK_DROP_VIEW:
            		RISdic_drop_view(stmt, execute_mode);
        		break;
				case RIS_TOK_ALTER_TABLE:
			        RISdic_alter_table(stmt, execute_mode);
        		break;
				case RIS_TOK_CREATE_TABLE:
            		RISdic_create_table(stmt, execute_mode);
        		break;
				case RIS_TOK_DROP_TABLE:
			        RISdic_drop_table(stmt, execute_mode);
        		break;
				case RIS_TOK_CREATE_INDEX:
            		RISdic_create_index(stmt, execute_mode);
        		break;
				case RIS_TOK_DROP_INDEX:
            		RISdic_drop_index(stmt, execute_mode);
        		break;
				case RIS_TOK_GRANT:
				case RIS_TOK_GRANT_ON_TABLE:
			        RISdic_grant(stmt->tree, execute_mode);
        		break;
				case RIS_TOK_REVOKE:
				case RIS_TOK_REVOKE_ON_TABLE:
            		RISdic_revoke(stmt->tree, execute_mode);
        		break;
				case RIS_TOK_DECLARE_TABLE:
				case RIS_TOK_DECLARE_VIEW:
            		RISdic_declare_table_view(stmt, execute_mode);
        		break;
				case RIS_TOK_UNDECLARE_TABLE:
				case RIS_TOK_UNDECLARE_VIEW:
			        RISdic_undeclare_table_view(stmt, execute_mode);
        		break;
				case RIS_TOK_CREATE_SCHEMA:
        		    RISdic_create_schema(stmt->tree, execute_mode);
        		break;
				case RIS_TOK_DROP_SCHEMA:
			        RISdic_drop_schema(stmt->tree->rhs->lhs->info.val,
                		stmt->tree->rhs->lhs->rhs->info.val, execute_mode);
				break;
				case RIS_TOK_ALTER_SCHEMA:
            		RISdic_alter_schema(stmt->tree, execute_mode);
        		break;
		        default:
            		LONGJMP(RIS_E_INTERNAL_ERROR);
        		break;
			}
        break;

		case RIS_TOK_GRANT_SCHEMA:
		case RIS_TOK_GRANT_CONNECT:
		case RIS_TOK_GRANT_RESOURCE:
		case RIS_TOK_REVOKE_SCHEMA:
		case RIS_TOK_REVOKE_CONNECT:
		case RIS_TOK_REVOKE_RESOURCE:
			if (IN_START_MODE(execute_mode))
			{
				if (RIS_default->db->dtype == '4' ||
					RIS_default->db->dtype == 'D' ||
					RIS_default->db->dtype == 'O' ||
					RIS_default->db->dtype == 'R')
				{
					RIScom_uppercase(strlen(RIS_stmt->tree->rhs->lhs->info.val),
						(unsigned char *)RIS_stmt->tree->rhs->lhs->info.val);
				}
				if (!strcmp(RIS_stmt->tree->rhs->lhs->info.val, 
					RIS_default->login))
				{
					LONGJMP(RIS_E_CAN_NOT_GRA_REV_SELF);
				}

				if (RISusr_search_sch_in_transact(stmt->sql->schema))
				{
					if (RIS_autocommit)
					{
						RISusr_close_all_cursors_for_sch(stmt->sql->schema);
						RISusr_remove_sch_from_transact(stmt->sql->schema);
					}
					else
					{
						LONGJMP(RIS_E_DDL_NOT_ALLOWED);
					}
				}
				else
				{
					RISusr_validate_room_in_transact();
				}
			}
			switch(stmt->tree->tok)
			{
				case RIS_TOK_GRANT_SCHEMA:
					RISusr_send_rec(RIS_GRANT_SCHEMA_CODE, stmt->sql,
						execute_mode);
					break;
				case RIS_TOK_GRANT_CONNECT:
					RISusr_send_rec(RIS_GRANT_CONNECT_CODE, stmt->sql,
						execute_mode);
					break;
				case RIS_TOK_GRANT_RESOURCE:
					RISusr_send_rec(RIS_GRANT_RESOURCE_CODE, stmt->sql,
						execute_mode);
					break;
				case RIS_TOK_REVOKE_SCHEMA:
					RISusr_send_rec(RIS_REVOKE_SCHEMA_CODE, stmt->sql,
						execute_mode);
					break;
				case RIS_TOK_REVOKE_CONNECT:
					RISusr_send_rec(RIS_REVOKE_CONNECT_CODE, stmt->sql,
						execute_mode);
					break;
				case RIS_TOK_REVOKE_RESOURCE:
					RISusr_send_rec(RIS_REVOKE_RESOURCE_CODE, stmt->sql,
						execute_mode);
					break;
		        default:
            		LONGJMP(RIS_E_INTERNAL_ERROR);
        		break;
			}
		break;
						
		case RIS_TOK_OPEN_SCHEMA:
            RISdic_open_mult_schemas(stmt->tree, execute_mode);
        break;

		case RIS_TOK_CLOSE_SCHEMA:
			if (IN_START_MODE(execute_mode))
			{
				if (stmt->tree->rhs->tok == RIS_TOK_ALL)
				{
					for (i=0;i < RIS_parms.max_transactions;i++)
					{
						schema = RISusr_transact_schemas[i].schema;
						if (schema)
						{
							if (RIS_autocommit)
							{

	/* explicitly do a commit because errors for close schema are ignored */

								RIS_sdp->schema = schema;
								RISusr_send_rec(RIS_COMMIT_WORK_CODE,RIS_sdp,
									SYNC_MODE);
								RISusr_close_all_cursors_for_sch(schema);
								RISusr_remove_sch_from_transact(schema);
							}
							else
							{
								LONGJMP(RIS_E_DDL_NOT_ALLOWED);
							}
						}
					}
				}
				else
				{
					for (tp=stmt->tree->rhs;tp;tp=tp->rhs)
					{
						schema = RISdic_lookup_schema(tp->lhs->info.val,HASH_TABLE);
						if (RISusr_search_sch_in_transact(schema))
						{
							if (RIS_autocommit)
							{

	/* explicitly do a commit because errors for close schema are ignored */

								RIS_sdp->schema = schema;
								RISusr_send_rec(RIS_COMMIT_WORK_CODE,RIS_sdp,
									SYNC_MODE);
								RISusr_close_all_cursors_for_sch(schema);
								RISusr_remove_sch_from_transact(schema);
							}
							else
							{
								LONGJMP(RIS_E_DDL_NOT_ALLOWED);
							}
						}
					}
				}
			}
        	RISdic_close_mult_schemas(stmt->tree, execute_mode);
        break;

		case RIS_TOK_DECLARE_SCHEMA:
			if (IN_START_MODE(execute_mode))
			{
				tp=stmt->tree->rhs;
				schema = RISdic_lookup_schema(tp->lhs->info.val,HASH_TABLE);
				if (RISusr_search_sch_in_transact(schema))
				{
					if (RIS_autocommit)
					{

	/* explicitly do a commit because errors for close schema are ignored */

						RIS_sdp->schema = schema;
						RISusr_send_rec(RIS_COMMIT_WORK_CODE,RIS_sdp,
							SYNC_MODE);
						RISusr_close_all_cursors_for_sch(schema);
						RISusr_remove_sch_from_transact(schema);
					}
					else
					{
						LONGJMP(RIS_E_DDL_NOT_ALLOWED);
					}
				}
			}
        	RISdic_declare_schema(stmt->tree, execute_mode);
        break;
		
		case RIS_TOK_UNDECLARE_SCHEMA:
			if (IN_START_MODE(execute_mode))
			{
				if (stmt->tree->rhs->lhs->tok == RIS_TOK_ALL)
				{
					risdclrschema   *dschema;
					risdclrschema   *next_dschema;

					dschema = RIS_declare_schema;
					while(dschema)
					{
						next_dschema = dschema->next;
						schema = 
							RISdic_lookup_schema(dschema->schname, HASH_TABLE);
						if (RISusr_search_sch_in_transact(schema))
						{
							if (RIS_autocommit)
							{

	/* explicitly do a commit because errors for close schema are ignored */

								RIS_sdp->schema = schema;
								RISusr_send_rec(RIS_COMMIT_WORK_CODE,RIS_sdp,
									SYNC_MODE);
								RISusr_close_all_cursors_for_sch(schema);
								RISusr_remove_sch_from_transact(schema);
							}
							else
							{
								LONGJMP(RIS_E_DDL_NOT_ALLOWED);
							}
						}
					}
				}
				else
				{
					for (tp=stmt->tree->rhs->lhs->rhs; tp; tp=tp->rhs)
					{
						schema = 
							RISdic_lookup_schema(tp->lhs->info.val,HASH_TABLE);
						if (RISusr_search_sch_in_transact(schema))
						{
							if (RIS_autocommit)
							{

	/* explicitly do a commit because errors for close schema are ignored */

								RIS_sdp->schema = schema;
								RISusr_send_rec(RIS_COMMIT_WORK_CODE,RIS_sdp,
									SYNC_MODE);
								RISusr_close_all_cursors_for_sch(schema);
								RISusr_remove_sch_from_transact(schema);
							}
							else
							{
								LONGJMP(RIS_E_DDL_NOT_ALLOWED);
							}
						}
					}
				}
			}
        	RISdic_undeclare_schema(stmt->tree, execute_mode);
        break;

		case RIS_TOK_DECLARE_SUPERSCHEMA:
			if (IN_START_MODE(execute_mode))
			{
				RISdic_decl_superschema(stmt->tree);
			}
		break;
		case RIS_TOK_UNDECLARE_SUPERSCHEMA:
			if (IN_START_MODE(execute_mode))
			{
				RISdic_undecl_superschema(stmt->tree->rhs->lhs->info.val);
			}
		break;
		case RIS_TOK_REDECLARE_SUPERSCHEMA:
			if (IN_START_MODE(execute_mode))
			{
				RISdic_redecl_superschema(stmt->tree);
			}
		break;

/*
** DDL statements that do NOT interact with the RIS dictionary.
** Only allow these DDL statements if not in a transaction.
** These DDL statements are autocommit
*/
		case RIS_TOK_EXEC:
			if (IN_START_MODE(execute_mode))
			{
				if (RISusr_search_sch_in_transact(stmt->sql->schema))
				{
					if (RIS_autocommit)
					{
						RISusr_close_all_cursors_for_sch(stmt->sql->schema);
						RISusr_remove_sch_from_transact(stmt->sql->schema);
					}
					else
					{
						LONGJMP(RIS_E_DDL_NOT_ALLOWED);
					}
				}
				else
				{
					RISusr_validate_room_in_transact();
				}
			}
			RISusr_send_rec(RIS_EXEC_NOW_CODE,stmt->sql,execute_mode);

		break;

		case RIS_TOK_SET:
			switch(stmt->tree->rhs->tok)
			{
				case RIS_TOK_DATABASE:
					if (IN_START_MODE(execute_mode))
					{
						if (stmt->tree->rhs->rhs->tok == RIS_TOK_ALL)
						{
							RIS_enable_dbms = RIS_ENABLE_ALL;
						}
						else if(stmt->tree->rhs->rhs->tok==RIS_TOK_DB_TYPE_LIST)
						{
							enabled_dbms = (unsigned int)0;
							for (tp = stmt->tree->rhs->rhs->rhs;tp;tp=tp->rhs )
							{
								switch ( tp->lhs->tok )
								{
									case( RIS_TOK_INFORMIX ):
										enabled_dbms |= RIS_ENABLE_INFORMIX;
										break;

									case( RIS_TOK_ORACLE ):
										enabled_dbms |= RIS_ENABLE_ORACLE;
										break;

									case( RIS_TOK_INGRES ):
										enabled_dbms |= RIS_ENABLE_INGRES;
										break;

									case( RIS_TOK_DB2 ):
										enabled_dbms |= RIS_ENABLE_DB2;
										break;

									case( RIS_TOK_RDB ):
										enabled_dbms |= RIS_ENABLE_RDB;
										break;

									case( RIS_TOK_SYBASE ):
										enabled_dbms |= RIS_ENABLE_SYBASE;
										break;

									case( RIS_TOK_MSSQL ):
										enabled_dbms |= RIS_ENABLE_MSSQL;
										break;

									case( RIS_TOK_SQLDS ):
										enabled_dbms |= RIS_ENABLE_SQLDS;
										break;

									case( RIS_TOK_OS400 ):
										enabled_dbms |= RIS_ENABLE_OS400;
										break;

									default:
										LONGJMP(RIS_E_INTERNAL_ERROR);
										break;
								}
							}
							RISdic_check_open_sch(enabled_dbms);
							RIS_enable_dbms = enabled_dbms;
						}
						else
						{
							LONGJMP(RIS_E_INTERNAL_ERROR);
						}
					}
					break;

				case RIS_TOK_MODE:
					for (tp = stmt->tree->rhs->rhs; tp; tp = tp->rhs)
					{
						switch ( tp->lhs->tok )
						{
							case RIS_TOK_ANSI:
								if (IN_START_MODE(execute_mode))
								{
									if (tp->lhs->rhs->tok == RIS_TOK_ON)
									{
										RIS_max_id_size = 18;
										RIS_ansi_mode = 1;
									}
									else if (tp->lhs->rhs->tok == RIS_TOK_OFF)
									{
										RIS_max_id_size = RIS_MAX_ID_SIZE-1;
										RIS_ansi_mode = 0;
									}
									else
									{
										LONGJMP(RIS_E_INTERNAL_ERROR);
									}
								}
								break;
							
							case RIS_TOK_VERIFY:
								if (IN_START_MODE(execute_mode))
								{
									if (tp->lhs->rhs->tok == RIS_TOK_ON)
									{
										RIS_verify_mode = 1;
									}
									else if (tp->lhs->rhs->tok == RIS_TOK_OFF)
									{
										RIS_verify_mode = 0;
									}
									else
									{
										LONGJMP(RIS_E_INTERNAL_ERROR);
									}
								}
								break;

							case RIS_TOK_AUTORENAME:
								if (IN_START_MODE(execute_mode))
								{
									if (tp->lhs->rhs->tok == RIS_TOK_ON)
									{
										RIS_autorename_mode = 1;
									}
									else if (tp->lhs->rhs->tok == RIS_TOK_OFF)
									{
										RIS_autorename_mode = 0;
									}
									else
									{
										LONGJMP(RIS_E_INTERNAL_ERROR);
									}
								}
								break;

							case RIS_TOK_BLANKSTRIP:
								if (tp->lhs->rhs->tok == RIS_TOK_ON)
								{
									if (!RIS_blankstrip_mode)
									{
										if (IN_START_MODE(execute_mode))
										{
											RISusr_send_all_srvs(
												RIS_BLANKSTRIP_ON_CODE, 0, 	
												execute_mode);
										}
										if (IN_FINISH_MODE(execute_mode))
										{
											RIS_blankstrip_mode = 1;
										}
									}
								}
								else if (tp->lhs->rhs->tok == RIS_TOK_OFF)
								{
									if (RIS_blankstrip_mode)
									{
										if (IN_START_MODE(execute_mode))
										{
											RISusr_send_all_srvs(
												RIS_BLANKSTRIP_OFF_CODE, 0,
												execute_mode);
										}
										if (IN_FINISH_MODE(execute_mode))
										{
											RIS_blankstrip_mode = 0;
										}
									}
								}
								else
								{
									LONGJMP(RIS_E_INTERNAL_ERROR);
								}
								break;
							
							default:
								LONGJMP(RIS_E_INTERNAL_ERROR);
								break;
						}
					}
					break;

				case RIS_TOK_TRANSACTION:
					/*
					**	Make the user and the server aware of the new setting
					**	for autocommit.  Setting autocommit on does an implicit
					**	commit if it is not already on.
					*/
					if (stmt->tree->rhs->rhs->tok == RIS_TOK_ON)
					{
						if (!RIS_autocommit)
						{
							RISusr_send_all_srvs(RIS_AUTOCOMMIT_ON_CODE, 0, 	
								execute_mode);
							if (IN_FINISH_MODE(execute_mode))
							{
								RIS_autocommit = 1;
								/*
								** setting autocommit on forces a commit so
								** do user side commit stuff
								*/
								RISusr_close_all_cursors();
                    			RISusr_remove_all_schs_from_transact();
							}
						}
					}
					else if (stmt->tree->rhs->rhs->tok == RIS_TOK_OFF)
					{
						if (RIS_autocommit)
						{
							RISusr_send_all_srvs(RIS_AUTOCOMMIT_OFF_CODE, 0,
								execute_mode);
							if (IN_FINISH_MODE(execute_mode))
							{
								RIS_autocommit = 0;
							}
						}
					}
					else
					{
						LONGJMP(RIS_E_INTERNAL_ERROR);
					}
					break;

                case RIS_TOK_NETWORK:
                    /*
                    **  Set the parameters in risschema structure if 
					**  <FOR schema_list> is specified. Otherwise,
					**  Set the parameters in RIS_timestamp structure.
                    */

					if (IN_START_MODE(execute_mode))
					{
						for (pp = stmt->tree->rhs->lhs->rhs; pp; pp = pp->rhs)
						{
							switch(pp->lhs->tok)
							{
								case RIS_TOK_INTERVAL:
									/* timesatmp interval */
									interval_flag = 1;
									timestamp.timestamp_interval =
										atoi(pp->lhs->rhs->info.val);
								break;

								case RIS_TOK_TOLERANCE:
									/* timestamp tolerance */
									tolerance_flag = 1;
									timestamp.timestamp_tolerance =
										atoi(pp->lhs->rhs->info.val);
								break;

								case RIS_TOK_BUFFER_SIZE:
									/* buffer size */
									buffer_size_flag = 1;
									timestamp.buffer_full_size  =
										atoi(pp->lhs->rhs->info.val);
								break;

								case RIS_TOK_BUFFER_TIMEOUT:
									/* buffer timeout */
									buffer_timeout_flag = 1;
									timestamp.buffer_full_timeout =
										atoi(pp->lhs->rhs->info.val);
									break;

								case RIS_TOK_INITIAL_TIMEOUT:
									/* initial timeout */
									initial_timeout_flag = 1;
									timestamp.initial_timeout =
										atoi(pp->lhs->rhs->info.val);
									break;

								case RIS_TOK_RESPONSE_INTERVAL:
									/* server response interval */
									response_interval_flag = 1;
									timestamp.response_interval =
										atoi(pp->lhs->rhs->info.val);
									break;

							   default:
									LONGJMP(RIS_E_INTERNAL_ERROR);
							}
						}

						if (stmt->tree->rhs->rhs)
						{
							for( schp = stmt->tree->rhs->rhs->rhs; schp; 
								 schp = schp->rhs )
							{
								tsp = &(schp->lhs->info.schema->timestamp);
								if (interval_flag)
								{
									tsp->timestamp_interval =
										timestamp.timestamp_interval;
								}
								if (initial_timeout_flag)
								{
									tsp->initial_timeout =
										timestamp.initial_timeout;
								}
								if (tolerance_flag)
								{
									tsp->timestamp_tolerance =
										timestamp.timestamp_tolerance;
								}
								if (buffer_size_flag)
								{
									tsp->buffer_full_size  =
										timestamp.buffer_full_size;
								}
								if (buffer_timeout_flag)
								{
									tsp->buffer_full_timeout =
										timestamp.buffer_full_timeout;
								}
								if (response_interval_flag)
								{
									tsp->response_interval =
										timestamp.response_interval;
								}
							}
						}
						else
						{
							if (interval_flag)
							{
								RIS_timestamp.timestamp_interval =
									timestamp.timestamp_interval;
							}
							if (initial_timeout_flag)
							{
								RIS_timestamp.initial_timeout =
									timestamp.initial_timeout;
							}
							if (tolerance_flag)
							{
								RIS_timestamp.timestamp_tolerance =
									timestamp.timestamp_tolerance;
							}
							if (buffer_size_flag)
							{
								RIS_timestamp.buffer_full_size  =
									timestamp.buffer_full_size;
							}
							if (buffer_timeout_flag)
							{
								RIS_timestamp.buffer_full_timeout =
									timestamp.buffer_full_timeout;
							}
							if (response_interval_flag)
							{
								RIS_timestamp.response_interval =
									timestamp.response_interval;
							}

						}
					}
                    break;
				default:
					LONGJMP(RIS_E_INTERNAL_ERROR);
					break;
			}
		break;

/* transaction statements */

		case RIS_TOK_COMMIT:
/*
**  Special case when MAX_TRANSACTION is 1
**  so that old concept of commit would work i.e., sql stmt commit would not
**  commit default schema but the schema in transaction
*/
			if (IN_START_MODE_ONLY(execute_mode))
			{
				if( RIS_parms.max_transactions == 1 )
				{
					if( RISusr_transact_schemas[0].schema )
					{
						RIS_sdp->schema = RISusr_transact_schemas[0].schema;
						RISusr_send_rec(RIS_COMMIT_WORK_CODE,RIS_sdp,
						 execute_mode);
					}
				}
				else
				{
					if (RISusr_search_sch_in_transact(stmt->sql->schema))
					{
						RIS_sdp->schema = stmt->sql->schema;
						RISusr_send_rec(RIS_COMMIT_WORK_CODE,RIS_sdp,
						 execute_mode);
					}
				}
			}
			if (IN_FINISH_MODE(execute_mode))
			{
				if( RIS_parms.max_transactions == 1 )
				{
					if( RISusr_transact_schemas[0].schema )
					{
						RIS_sdp->schema = RISusr_transact_schemas[0].schema;
						RISusr_send_rec(RIS_COMMIT_WORK_CODE,RIS_sdp,
						 execute_mode);
						RISusr_close_all_cursors_for_sch(RIS_sdp->schema);
						RISusr_remove_sch_from_transact(RIS_sdp->schema);
					}
				}
				else
				{
					if (RISusr_search_sch_in_transact(stmt->sql->schema))
					{
						RIS_sdp->schema = stmt->sql->schema;
						RISusr_send_rec(RIS_COMMIT_WORK_CODE,RIS_sdp,
						 execute_mode);
						RISusr_close_all_cursors_for_sch(RIS_sdp->schema);
						RISusr_remove_sch_from_transact(RIS_sdp->schema);
					}
				}
			}
		break;

		case RIS_TOK_ROLLBACK:
/*
**  Special case when MAX_TRANSACTION is 1
**  so that old concept of rollback would work i.e., sql stmt rollback would not
**  rollback default schema but the schema in transaction
*/
			if (IN_START_MODE_ONLY(execute_mode))
			{
				if( RIS_parms.max_transactions == 1 )
				{
					if( RISusr_transact_schemas[0].schema )
					{
						RIS_sdp->schema = RISusr_transact_schemas[0].schema;
						RISusr_send_rec(RIS_ROLLBACK_WORK_CODE,RIS_sdp,
						 execute_mode);
					}
				}
				else
				{
					if (RISusr_search_sch_in_transact(stmt->sql->schema))
					{
						RIS_sdp->schema = stmt->sql->schema;
						RISusr_send_rec(RIS_ROLLBACK_WORK_CODE,RIS_sdp,
						 execute_mode);
					}
				}
			}
			if (IN_FINISH_MODE(execute_mode))
			{
				if( RIS_parms.max_transactions == 1 )
				{
					if( RISusr_transact_schemas[0].schema )
					{
						RIS_sdp->schema = RISusr_transact_schemas[0].schema;
						RISusr_send_rec(RIS_ROLLBACK_WORK_CODE,RIS_sdp,
						 execute_mode);
						RISusr_close_all_cursors_for_sch(RIS_sdp->schema);
						RISusr_remove_sch_from_transact(RIS_sdp->schema);
					}
				}
				else
				{
					if (RISusr_search_sch_in_transact(stmt->sql->schema))
					{
						RIS_sdp->schema = stmt->sql->schema;
						RISusr_send_rec(RIS_ROLLBACK_WORK_CODE,RIS_sdp,
						 execute_mode);
						RISusr_close_all_cursors_for_sch(RIS_sdp->schema);
						RISusr_remove_sch_from_transact(RIS_sdp->schema);
					}
				}
			}
		break;


/* all DML statements except SELECT and LOCK */

		case RIS_TOK_INSERT:
		case RIS_TOK_UPDATE:
		case RIS_TOK_DELETE:

			if (IN_START_MODE(execute_mode))
			{
				/*
				**  Search RISusr_transact_schemas to check if current stmt's
				**	schema is in transaction or not. If not check for
				**	MAX_TRANSACTION limit.
				*/
         		RISusr_srch_vldt_transact(stmt->sql->schema);

				/*
				**  Validate to the existence of each table specified in this
				**	stmt against those specified in the lock tables stmt.
				*/
	            RISusr_validate_lock_tables(stmt->sql->schema,stmt->tablist);
			}
			/*
			**	EXEC only needs to be sent if the statement has been
			**	prepared. Otherwise PREP_EXEC should be sent.
			*/
			/*******    BLOB       *********/

			opcode = (!blobinfo)?( (stmt->sql->dbms) ? RIS_EXEC_CODE:
						RIS_PREP_EXEC_CODE ):
						(
							DEFERRED_EXEC ?
							( (stmt->sql->dbms)?
								RIS_EXEC_DEFERRED_CODE :
								RIS_PREP_EXEC_DEFERRED_CODE
							):
							RIS_EXEC_BLOB_CODE /* it is blob */
						);

			status = SETJMP();
			if (!status)
			{
				if (opcode !=  RIS_EXEC_BLOB_CODE)
					RISusr_send_rec(opcode, stmt->sql, execute_mode);
				else
					RISusr_exec_blob(RIS_stmt, execute_mode, blobinfo);
			}
			
			/*******    BLOB       *********/
			RESETJMP();

			if (IN_FINISH_MODE(execute_mode))
			{
				/*
				**	finish mode
				*/
				if (status)
				{
					/*
					** An execution error occured then a rollback
					** was done. If we were in a transaction the
					** user side must do its stuff.
					*/

					if (!IS_SERVER_DEAD(status))
					{
						if (stmt && stmt->sql->rollback)
						{
							if(RISusr_search_sch_in_transact(stmt->sql->schema))
							{
								RISusr_close_all_cursors_for_sch(
									stmt->sql->schema);
								RISusr_remove_sch_from_transact(
									stmt->sql->schema);
							}
						}
					}
					LONGJMP(status);
				}
				else
				{
					/*
					**	RISusr_send_rec was successful
					*/
					if (!blobinfo || (BLOB_EXEC && ! MORE_BLOB_COL_TO_FOLLOW ))
					/* If a blob column is involved we dont worry about 
					transaction until entire blob has been transferd. */ 
					{

               		if (RISusr_search_sch_in_transact(stmt->sql->schema))
					{
						if (RIS_autocommit)
						{
							/*
							** If autocommit is on then these statements
							** will cause a commit.  The user side must
							** perform its transaction termination stuff
							** if we were in a transaction.
							*/

							RISusr_close_all_cursors_for_sch(stmt->sql->schema);
							RISusr_remove_sch_from_transact(stmt->sql->schema);
						}
					}
					else if (!RIS_autocommit)
					{
						/*
						** if we were not in a transaction and
						** autocommit is not on then record that
						** we are now in a transaction.
						*/
						RISusr_insert_sch_in_transact(stmt->sql->schema);
					}
				}
				}
			}
			else if (IN_START_MODE(execute_mode))
			{
				/* start mode only */
				if (status)
				{
					LONGJMP(status);
				}
			}
		break;

/* the lock tables statement */

		case RIS_TOK_LOCK_TABLES:
/*
**	LOCK_TABLES must be the first statement in a transaction
*/
			if (IN_START_MODE(execute_mode))
			{
				if (RISusr_search_sch_in_transact(stmt->sql->schema))
				{
					if (RIS_autocommit)
					{
						RIS_sdp->schema = stmt->sql->schema;
						RISusr_send_rec(RIS_COMMIT_WORK_CODE,RIS_sdp,SYNC_MODE);
						RISusr_close_all_cursors_for_sch(RIS_sdp->schema);
						RISusr_remove_sch_from_transact(RIS_sdp->schema);
					}
					else
					{
						LONGJMP(RIS_E_INVALID_LOCK_TABLES);
					}
				}
				else
				{
					RISusr_validate_room_in_transact();
				}
			}
			RISusr_send_rec(RIS_LOCK_TABLES_CODE, stmt->sql,execute_mode);

			if (IN_FINISH_MODE(execute_mode))
			{
				if (!RIS_autocommit)
				{

					/*
					** if autocommit is not on then record that
					** we are now in a transaction.
					*/

					RISusr_insert_sch_in_transact(stmt->sql->schema);

	/*
	** Copy allowable tables list into transact_schemas's table list
	*/
					RISusr_insert_ristablist(stmt->sql->schema);
				}
			}
		break;

/* The select statement */

		case RIS_TOK_SELECT:

			if (IN_START_MODE(execute_mode))
			{
				/*
				**  Search RISusr_transact_schemas to check if current stmt's
				**	schema is in transaction or not. If not check for
				**	MAX_TRANSACTION limit
				*/
            	RISusr_srch_vldt_transact(stmt->sql->schema);

				/*
				**  Validate to the existence of each table specified in this
				**	stmt against those specified in the lock tables stmt
				*/
				RISusr_validate_lock_tables(stmt->sql->schema,stmt->tablist);

				RISusr_update_ristabs(stmt);

				/*
				** PREP_DESC_DECL only needs to be sent if the
				** statement has not been prepared. Otherwise
				** OPEN can be sent.
				*/

				if (stmt->fetch_buf)
				{
					LONGJMP(RIS_E_CURSOR_NOT_CLOSED);
				}
				else
				{
					stmt->fetch_buf = (ris_srvcli_buf *)1;
				}
			}

			status = SETJMP();
			if (status)
			{
				RESETJMP();
				USR_DBG(("RISusr_exec_stmt: got error: %d\n", status));
				if (status != STATEMENT_NOT_COMPLETE)
				{
                    if( !IS_SERVER_DEAD(status) )
					{
						stmt->fetch_buf = (ris_srvcli_buf *)0;
					}
				}
				LONGJMP(status);
			}

			if (stmt->sql->dbms)
			{
				USR_DBG(("stmt was prepd, sending RIS_OPEN_CODE\n"));
				RISusr_send_rec(RIS_OPEN_CODE, stmt->sql, execute_mode);
			}
			else
			{
				USR_DBG(("stmt was not prepd, sending PDDO_CODE\n"));
				RISusr_send_rec(RIS_PREP_DESC_DECL_OPEN_CODE, stmt->sql,
					execute_mode);
			}
			RESETJMP();

			if (IN_FINISH_MODE(execute_mode))
			{
            	if (!RISusr_search_sch_in_transact(stmt->sql->schema))
            	{
					/*
					** if we were not in a transaction then record that we are
					**	now in a transaction.
					*/
                	RISusr_insert_sch_in_transact(stmt->sql->schema);
            	}
			}
		break;

		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
		break;
	}
}

/******************************************************************************/
/*
** This function closes a cursor as far as the user side is concerned.
*/
extern void RISusr_close_cursor(
	int i)
{
	USR_DBG(("RISusr_close_cursor(id:%d)\n", i));

	if (RIS_stmts[i] && RIS_stmts[i]->fetch_buf)
	{
		USR_DBG(("closing cursor %d\n",i));
		RIS_stmts[i]->fetch_buf = (ris_srvcli_buf *)0;
		if (RIS_autocommit && RIS_stmts[i]->sql->schema)
		{
			RISusr_close_all_cursors_for_sch(RIS_stmts[i]->sql->schema);
			RISusr_remove_sch_from_transact(RIS_stmts[i]->sql->schema);
		}
	}
	USR_DBG(("RISusr_close_cursor: done...\n"));
}

/******************************************************************************/
/*
** This function closes cursors as far as the user side is concerned.
*/
extern void RISusr_close_all_cursors()
{
	int i;

	USR_DBG(("RISusr_close_all_cursors()\n"));

	for(i = 0; i < RIS_parms.max_user_stmts; i++)
	{
		if (RIS_stmts[i] && RIS_stmts[i]->fetch_buf)
		{
			USR_DBG(("closing cursor %d\n", i));
			RIS_stmts[i]->fetch_buf = (ris_srvcli_buf *)0;
		}
	}
	USR_DBG(("RISusr_close_all_cursors: done...\n"));
}

/******************************************************************************/
/*
** This function closes cursors as far as the user side is concerned for a 
** particular schema only.
*/
extern void RISusr_close_all_cursors_for_sch(
	risschema *schema)
{
	int i;

	USR_DBG(("RISusr_close_all_cursors_for_sch(0x%x)\n"
		"schema->schname:<%s>\n", schema, STRING(schema->schname)));

	for(i=0; i < RIS_parms.max_user_stmts; i++)
	{
		if (RIS_stmts[i] && RIS_stmts[i]->fetch_buf &&
			RIS_stmts[i]->sql->schema == schema) 
		{
			USR_DBG(("\tclosing cursor %d\n", i));
			RIS_stmts[i]->fetch_buf = (ris_srvcli_buf *)0;
		}
	}
	USR_DBG(("RISusr_close_all_cursors_for_sch: done...\n"));
}

/******************************************************************************/
/*
**	This function searches a schema in RISusr_transact_schema array, then 
**	validates the MAX_TRANSACTIONS limits
*/

extern void RISusr_srch_vldt_transact(
	risschema *schema)
{
	USR_DBG(("RISusr_srch_vldt_transact(schname<%s>)\n",schema->schname));

	if (!RISusr_search_sch_in_transact(schema))
	{
		RISusr_validate_room_in_transact();
	}

	USR_DBG(("RISusr_srch_vldt_transact: End.\n"));
}

/******************************************************************************/

/*
**	This function searches a schema in RISusr_transact_schema array
*/

extern int RISusr_search_sch_in_transact(
	risschema *schema)
{
	int schindx;
	int return_sts = 0;

	USR_DBG(("RISusr_search_sch_in_transact(schema:0x%x)\n"
		"RISusr_search_sch_in_transact: schname:<%s>\n",
		schema, schema ? schema->schname : "NULL"));

	if (schema)
	{
		for( schindx = 0; schindx < RIS_parms.max_transactions; schindx++ )
		{
			USR_DBG(("RISusr_search_sch_in_transact: checking schname:<%s>\n",
				RISusr_transact_schemas[schindx].schema ?
				RISusr_transact_schemas[schindx].schema->schname : "NULL"));
			if( RISusr_transact_schemas[schindx].schema == schema )
			{
				return_sts = 1;
				break;
			}
		}
	}

	USR_DBG(("RISusr_search_sch_in_transact: returning %d\n", return_sts));
	return return_sts;
}


/******************************************************************************/

/*
**	This function validates the MAX_TRANSACTIONS limits
*/

extern void RISusr_validate_room_in_transact()
{
	int schindx;

	USR_DBG(("RISusr_validate_room_in_transact: Begin.\n"));

	for(schindx = 0; schindx < RIS_parms.max_transactions; schindx++ )
	{
		if (!RISusr_transact_schemas[schindx].schema)
		{
			return;
		}
	}
    /*
    **  To simulate old behaviour
    */
    if(RIS_autocommit)
    {
        if( RIS_parms.max_transactions == 1 )
        {
            if( RISusr_transact_schemas[0].schema )
            {
                RIS_sdp->schema = RISusr_transact_schemas[0].schema;
                RISusr_send_rec(RIS_COMMIT_WORK_CODE,RIS_sdp, SYNC_MODE);
                RISusr_close_all_cursors_for_sch(RIS_sdp->schema);
                RISusr_remove_sch_from_transact(RIS_sdp->schema);
            }
        }
    }
    else
	{
        LONGJMP(RIS_E_EXCEED_MAX_TRANSACTIONS);
	}


	USR_DBG(("1. RISusr_validate_room_in_transact: End.\n"));
}

/******************************************************************************/

/*
**	This function copies a tablist_list into permanent memory list
*/

static ristablist *copy_tablist_list(
    ristablist *list)
{
    ristablist *new_list = 0;
	ristablist **newp = &new_list;

	for(; list; list = list->next)
	{
		*newp = RIScco_alloc_ristablist();
       	memcpy(*newp, list, sizeof(ristablist));
		newp = &((*newp)->next);
	}
	*newp = 0;

    return(new_list);
}

/******************************************************************************/

/*
**  This function inserts a tablist (allowable tables in a transaction) in
**  RISusr_transact_schemas array
*/

static void RISusr_insert_ristablist(
    risschema *schema)
{
    int schindx;

    USR_DBG(("RISusr_insert_tablist(schname<%s>)\n",schema->schname));

    for(schindx = 0; schindx < RIS_parms.max_transactions; schindx++ )
    {
        if (RISusr_transact_schemas[schindx].schema == schema)
        {
            RISusr_transact_schemas[schindx].tablist =
                (ristablist *) copy_tablist_list(RIS_stmt->tablist);
            return;
        }
    }
    LONGJMP(RIS_E_INTERNAL_ERROR);
}

/******************************************************************************/

/*
**	This function inserts a schema in the array
*/

extern void RISusr_insert_sch_in_transact(
	risschema *schema)
{
	int schindx;

	USR_DBG(("RISusr_insert_sch_in_transact(schname<%s>)\n",schema->schname));

	for(schindx = 0; schindx < RIS_parms.max_transactions; schindx++ )
	{
		if (!RISusr_transact_schemas[schindx].schema)
		{
			RISusr_transact_schemas[schindx].schema = schema;
			return;
		}
	}
	LONGJMP(RIS_E_EXCEED_MAX_TRANSACTIONS);
}

/******************************************************************************/
/*
**	This function removes a schema from the array
*/
extern void RISusr_remove_sch_from_transact(
	risschema *schema)
{
	int schindx;
	int i;
	int add_to_list = 0;

	USR_DBG(("RISusr_remove_sch_from_transact(schname<%s>)\n",schema->schname));

	for (i=0; i < RIS_parms.max_user_stmts; i++)
	{
		if (RIS_stmts[i] && RIS_stmts[i]->sql &&
			RIS_stmts[i]->sql->schema == schema)
		{
			add_to_list = 1;
			break;
		}
	}
	if (add_to_list)
	{
		RIScco_add_to_eot_schname_list(schema->schname);
	}

	for(schindx = 0; schindx < RIS_parms.max_transactions; schindx++ )
	{
		if (RISusr_transact_schemas[schindx].schema == schema)
		{
			RISusr_transact_schemas[schindx].schema = 0;
            if( RISusr_transact_schemas[schindx].tablist )
			{
                RIScco_free_ristablist_list(
					RISusr_transact_schemas[schindx].tablist);
                RISusr_transact_schemas[schindx].tablist = 0;
			}
			return;
		}
	}
	USR_DBG(("RISusr_remove_sch_from_transact: done...\n"));
}

/******************************************************************************/
/*
**	This function removes all schemas from the array
*/
extern void RISusr_remove_all_schs_from_transact()
{
	int schindx;

	USR_DBG(("RISusr_remove_all_schs_from_transact()\n"));

	RIScco_add_to_eot_schname_list("all");

	for( schindx = 0; schindx < RIS_parms.max_transactions; schindx++ )	
	{
		RISusr_transact_schemas[schindx].schema = 0;
        if( RISusr_transact_schemas[schindx].tablist )
		{
            RIScco_free_ristablist_list(
				RISusr_transact_schemas[schindx].tablist);
            RISusr_transact_schemas[schindx].tablist = 0;
		}
	}
	USR_DBG(("RISusr_remove_all_schs_from_transact: done...\n"));
}

/******************************************************************************/
/*
**	This function prints RISusr_transact_schema array and allowable tables
*/
extern void RISusr_print_transact()
{
    int count = 0;
    int schindx;
    ristablist *tabp;

    for( schindx = 0; schindx < RIS_parms.max_transactions; schindx++ )
    {
        if (RISusr_transact_schemas[schindx].schema)
        {
            count++;
            RIScom_output_debug("\t%s\n",
				RISusr_transact_schemas[schindx].schema->schname);
            if( RISusr_transact_schemas[schindx].tablist )
            {
                RIScom_output_debug("\t\tAllowable tables: ");
                for( tabp = RISusr_transact_schemas[schindx].tablist;
                        tabp;
                            tabp = tabp->next )
                {
                    RIScom_output_debug("%s ",tabp->tab->tabname);
                }
                RIScom_output_debug("\n");
            }
            else
            {
                RIScom_output_debug("\t\tAll tables allowed.\n");
            }
        }
    }
    if( count == 0 )
        RIScom_output_debug("\tNo transactions.\n");
}

/******************************************************************************/

/*
**  Validate the existence of each table mentioned in a statement.
**  If the tablist doesnot exists in RISusr_transact_schemas, that means
**  lock tables statement was not executed. That's OK.
*/

static void RISusr_validate_lock_tables(
    risschema   *schema,
    ristablist *tablist)
{
    int schindx;
    ristablist *currp;
    ristablist *allowablep;
    ristablist *last_matchp;

    USR_DBG(("RISusr_validate_lock_tables(schname<%s>)\n",schema->schname));

	if (IS_RDB_ENABLED(RIS_enable_dbms))
	{
		for(schindx = 0; schindx < RIS_parms.max_transactions; schindx++ )
		{
			if (RISusr_transact_schemas[schindx].schema == schema)
			{
				if( RISusr_transact_schemas[schindx].tablist )
				{
					last_matchp = RISusr_transact_schemas[schindx].tablist;
					for(currp = tablist; currp; currp = currp->next)
					{
						USR_DBG(("currp %d tabname<%s>\n",
									currp->tab, currp->tab->tabname));
						for(allowablep = last_matchp;
								allowablep;
									allowablep = allowablep->next)
						{
							USR_DBG(("allowablep %d tabname<%s>\n",
									allowablep->tab, allowablep->tab->tabname));
							if( currp->tab == allowablep->tab )
							{
								/*
								**  As both the lists are in sorted orders,
								**  next iteration can begin from this spot onwards
								*/
								last_matchp = allowablep->next;
								break;
							}
							if( !allowablep->next )
							{
								LONGJMP(RIS_E_TABLE_NOT_SPECIFIED_IN_LOCK);
							}
						}
					}
				}
				break;
			}
		}
	}
    USR_DBG(("1. RISusr_validate_lock_tables: End.\n"));
}

/******************************************************************************/
