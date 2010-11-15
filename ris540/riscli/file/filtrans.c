/*
**	NAME:							filtrans.c
**	AUTHORS:						David Michal
**	CREATION DATE:					6/90
**	ABSTRACT:
**	This file contains the routines that manage transactions involving
**	the schema file.
**		
**	
**	REVISION HISTORY:
**
**	11/94: 	Changed the call from strchr to RIScom_strchr for INTERNATIONALIZATION
**			support. Dianne
**     7/8/96:  Ashley - fix for  439601714 - temp file array was incorrect size
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include "file.h"
#include "net.h"

/*
**	DEFINES
*/
#define CHKSUM_RETRY_COUNT	3
#define IGNORE_CHECKSUM		0
#define VERIFY_CHECKSUM		1

#define RIS_FIL_COMMIT_FLAG_ON()	\
if (!RISfil_commit_flag) 			\
{									\
	RISfil_commit_flag = 1; 		\
}									\

#define CLEAR_GLOBALS() 							\
{													\
	int i;											\
	RISfil_timestamp = 0; 							\
	RISfil_schema_list = NULL; 						\
	RISfil_db_list = NULL; 							\
	for (i=0;i<RIS_MAX_STMTS;i++) 					\
	{												\
		if (RISfil_schema_tmp_list[i])				\
		{											\
			RISfil_schema_tmp_list[i]->list = NULL; \
			RISfil_schema_tmp_list[i]->trans = 0; 	\
		}											\
		RISfil_schema_tmp_list[i] = NULL; 			\
		RISfil_db_tmp_list[i] = NULL; 				\
	}												\
	RISfil_commit_flag = 0;							\
	RISfil_trans_count = 0;							\
}													\

#define CLEAR_TRANSACTION() \
CLEAR_GLOBALS() \
save_timestamp = 0; \
transaction_state = NO_TRANSACTION;

#define CLEAR_READ_TRANSACTION() 				\
save_timestamp = 0; 							\
transaction_state = NO_TRANSACTION;

#define ID_BUFFER_SIZE	40

#if defined(WIN32)
  #define TEMP_FILE_SIZE   MAX_PATH
#else
  #define TEMP_FILE_SIZE   L_tmpnam
#endif

#if defined(WIN32)
# define umask		_umask
# define unlink		_unlink
# define getpid		_getpid
#endif

/*
**	VARIABLES
*/
static	int		transaction_state = NO_TRANSACTION;
static	long	save_timestamp = 0;
static	char	transaction_id[ID_BUFFER_SIZE];

/*
**      FUNCTION PROTOTYPES
*/
#define filtrans_c
#include "comuni.prt"
#include "ccosqlca.prt"
#include "comdebug.prt"
#include "comalloc.prt"
#include "comsqlca.prt"
#include "comjmp.prt"
#include "comwrap.prt"
#include "fildb.prt"
#include "filsch.prt"
#include "filtrans.prt"
#include "filshare.prt"
#include "filread.prt"
#include "filwrite.prt"
#include "netgnerc.prt"
#include "sys.prt"

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void create_new_file(
			char	*filename,
			int		mode)
{
	int		pre_umask;

	FIL_DBG(("create_new_file(filename:<%s> mode:0%o)\n", filename, mode));

	pre_umask = umask(0);
	RIScom_close(RIScom_creat(filename, mode));
	umask(pre_umask);
}

/******************************************************************************/

static void create_files_if_necessary()
{
 
	char	temp_name[TEMP_FILE_SIZE];

	FIL_DBG(("create_files_if_necessary()\n"));

	if (!RIScom_tmpnam(temp_name)) LONGJMP(RIS_E_CREATE_TEMP_FILE);

	if (NET_get_file(&RIS_file_net, &RIS_file_connect,RIS_file,temp_name))
	{
		if (RIS_file_net.error_code != NET_E_FILE_NOT_FOUND)
		{
			RIScom_remove(temp_name);
			LONGJMP(RIS_E_CANT_GET_SCHEMA_FILE);
		}

		/*
		**	Ignoring the error, so clear the dbca
		*/
		RIScom_clear_sqlca(dbca);

		/*
		**	There is not a schema file, create one.
		*/
		FIL_DBG(("creating schema file\n"));
		create_new_file(temp_name, 00666);
		if (NET_put_file(&RIS_file_net, &RIS_file_connect, temp_name,
			RIS_file))
		{
			RIScom_remove(temp_name);
			LONGJMP(RIS_E_CANT_CREATE_SCHEMA_FILE);
		}
		RIScom_remove(temp_name);

		/*
		**	see if lock file exists
		*/
		if (NET_get_file(&RIS_file_net, &RIS_file_connect, RIS_lock_file,
			temp_name))
		{
			if (RIS_file_net.error_code != NET_E_FILE_NOT_FOUND)
			{
				RIScom_remove(temp_name);
				LONGJMP(RIS_E_CANT_GET_LOCK_FILE);
			}
	
			/*
			**	Ignoring the error, so clear the dbca
			*/
			RIScom_clear_sqlca(dbca);

			/*
			**	There is not a lock file, create one.
			*/
			FIL_DBG(("creating lock file\n"));
			create_new_file(temp_name, 00666);
			if (NET_put_file(&RIS_file_net, &RIS_file_connect, temp_name,
				RIS_lock_file))
			{
				RIScom_remove(temp_name);
				LONGJMP(RIS_E_CANT_CREATE_LOCK_FILE);
			}
			/*
			**	remove the copy.
			*/
			RIScom_remove(temp_name);
		}
		else
		{
			/*
			**	Got the lock file, we don't really need it, remove it.
			*/
			RIScom_remove(temp_name);
		}
	}
	else
	{
		/*
		**	Got the schema file, we don't really need it, remove it.
		*/
		RIScom_remove(temp_name);
	}
}

/******************************************************************************/

static int write_id_file()
{
	char	*ptr;
	char	temp_name[TEMP_FILE_SIZE];
	FILE	*filep;
	int		pre_umask;

	FIL_DBG(("write_id_file()\n"));

	if (transaction_id[0] == '\0')
	{
		if (RIS_local_xns_addr[0]) ptr = RIS_local_xns_addr;
		else if (RIS_local_xns_addr[0]) ptr = RIS_local_xns_addr;
		else if (RIS_local_tcp_addr[0]) ptr = RIS_local_tcp_addr;
		else if (RIS_local_dnp_addr[0]) ptr = RIS_local_dnp_addr;
		else ptr = "";

		sprintf(transaction_id, "%s:%d", ptr, getpid());
	}
	FIL_DBG(("writing transaction_id:<%s>\n", transaction_id));

  	if (!RIScom_tmpnam(temp_name)) LONGJMP(RIS_E_CREATE_TEMP_FILE);

	pre_umask = umask(0);
	if ((filep = RIScom_fopen(temp_name, "w")) == NULL)
	{
		umask(pre_umask);
		return RIS_E_CANT_OPEN_ID_FILE_WRITE;
	}
	umask(pre_umask);

	if (RIScom_fputs(transaction_id, filep) < 0)
	{
		RIScom_fclose(filep);
		RIScom_remove(temp_name);
		return RIS_E_CANT_WRITE_ID_FILE;
	}

	RIScom_fclose(filep);
	
	if (NET_put_file(&RIS_file_net, &RIS_file_connect, temp_name, RIS_id_file))
	{
		RIScom_remove(temp_name);
		return RIS_E_CANT_PUT_ID_FILE;
	}
	unlink(temp_name);

	return RIS_SUCCESS;
}

/******************************************************************************/

static int read_id_file(
			char	*buffer,
			int		size)
{
	char	*ptr;
	char	temp_name[TEMP_FILE_SIZE];
	FILE	*filep;

	/*
	**	NOTE:	If the id file doesn't exist, this routine will put a 
	**			null string in buffer and return RIS_SUCCESS
	*/

	FIL_DBG(("read_id_file(buffer:0x%x size:%d)\n", buffer, size));

	*buffer = 0;
  	if (!RIScom_tmpnam(temp_name)) LONGJMP(RIS_E_CREATE_TEMP_FILE);

	if (NET_get_file(&RIS_file_net,&RIS_file_connect,RIS_id_file,
		temp_name))
	{
		if (RIS_file_net.error_code != NET_E_FILE_NOT_FOUND)
		{
			RIScom_remove(temp_name);
			return RIS_E_CANT_GET_ID_FILE;
		}

		/*
		**	Clear the error
		*/
		RIScom_clear_sqlca(dbca);
		RIScom_remove(temp_name);
	}
	else
	{
		if ((filep = RIScom_fopen(temp_name, "r")) == NULL)
		{
			RIScom_remove(temp_name);
			return RIS_E_CANT_OPEN_ID_FILE_READ;
		}

		RIScom_fgets(buffer, size, filep);
		if ((ptr = RIScom_strchr(buffer, '\n')) == NULL)
			ptr = buffer + (size - 1);
		*ptr = 0;

		RIScom_fclose(filep);
		RIScom_remove(temp_name);
	}

	FIL_DBG(("read transaction_id:<%s>\n", buffer));
	return RIS_SUCCESS;
}

/******************************************************************************/

static void get_lock_file_loop()
{
	int		sts;
	int		retry;
	char	error_flag;
	int		retry_limit;
	char	id[ID_BUFFER_SIZE];
	char	save_id[ID_BUFFER_SIZE];

	FIL_DBG(("get_lock_file_loop()\nRIS_lock_file_retry:%d\n",
		RIS_lock_file_retry));

	if (RIS_lock_file_retry < 0)
	{
		retry_limit = -RIS_lock_file_retry;
		error_flag = 1;
	}
	else
	{
		retry_limit = RIS_lock_file_retry;
		error_flag = 0;
	}

	if ((sts = read_id_file(save_id, ID_BUFFER_SIZE)) != RIS_SUCCESS)
		LONGJMP(sts);
	FIL_DBG(("save_id:<%s>\n", save_id));

	retry = 0;
	while(retry < retry_limit &&
		  NET_get_lock_file(&RIS_file_net,&RIS_file_connect,RIS_lock_file))
	{
		if (RIS_file_net.error_code != NET_E_NO_LOCK)
			LONGJMP(RIS_E_CANT_LOCK_SCHEMA_FILE);

		if ((sts = read_id_file(id, ID_BUFFER_SIZE)) != RIS_SUCCESS)
			LONGJMP(sts);
		FIL_DBG(("id:<%s>\n", id));

		if (strcmp(id, save_id))
		{
			/*
			**	It's a different id, reset retry_count and start over
			*/
			strcpy(save_id, id);
			retry = 0; 
		}
		else
		{
			retry++;
		}
	}

	if (retry == retry_limit)
	{
		if (error_flag)
		{
			FIL_DBG(("Timed Out . . . longjumping\n"));
			LONGJMP(RIS_E_CANT_LOCK_SCHEMA_FILE);
		}
		else
		{
			FIL_DBG(("Timed Out . . . continuing\n"));
		}
	}
	else
	{
		FIL_DBG(("Got lock file"));
	}
}

/******************************************************************************/

/*
** Begins a schema transaction. This is done by locking the schema file and
** making a local copy of it, then reading it into memory.
*/

static void begin_schema_transact_no_chksum_retry(
			int		transaction_type)
{
	int			sts;
	char		id[ID_BUFFER_SIZE];
	char		temp_name[TEMP_FILE_SIZE];
	static char	first_rw_transaction = 1;

	FIL_DBG(("static begin_schema_transact_no_chksum_retry()\n"));

	switch(transaction_type)
	{
		case READ_ONLY_TRANSACTION:
			FIL_DBG(("transaction_type: READ_ONLY_TRANSACTION\n")); break;
		case READ_WRITE_TRANSACTION:
			FIL_DBG(("transaction_type: READ_WRITE_TRANSACTION\n")); break;
		case NO_TRANSACTION:
		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	switch(transaction_state)
	{
		case NO_TRANSACTION:
			FIL_DBG(("transaction_state: NO_TRANSACTION\n")); break;
		case READ_ONLY_TRANSACTION:
			FIL_DBG(("transaction_state: READ_ONLY_TRANSACTION\n")); break;
		case READ_WRITE_TRANSACTION:
			FIL_DBG(("transaction_state: READ_WRITE_TRANSACTION\n")); break;
		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	switch(transaction_type)
	{
		case READ_ONLY_TRANSACTION:
			switch (transaction_state)
			{
				case NO_TRANSACTION:
    				if (!RIScom_tmpnam(temp_name))
						LONGJMP(RIS_E_CREATE_TEMP_FILE);
					if (NET_get_file(&RIS_file_net,&RIS_file_connect,
							RIS_file, temp_name))
					{
						if (RIS_file_net.error_code != NET_E_FILE_NOT_FOUND)
						{
							RIScom_remove(temp_name);
							LONGJMP(RIS_E_CANT_GET_SCHEMA_FILE);
						}

						/*
						**	After first read_write transaction, there 
						**	should always be a transaction
						*/
						if (!first_rw_transaction)
						{
							RIScom_remove(temp_name);
							LONGJMP(RIS_E_CANT_GET_SCHEMA_FILE);
						}
						/*
						**	No schema file, which is not an error, so clear
						**	globals and dbca.
						*/
						RIScom_clear_sqlca(dbca);
						CLEAR_GLOBALS();
						RIScom_remove(temp_name);
					}
					else
					{
						sts = SETJMP();
						if (sts)
						{
							RESETJMP();
							RIScom_remove(temp_name);
							LONGJMP(sts);
						}

						RISfil_read_schema_file(temp_name, VERIFY_CHECKSUM);
						RESETJMP();

						RIScom_remove(temp_name);
					}
					transaction_state = READ_ONLY_TRANSACTION;
				break;

				case READ_ONLY_TRANSACTION:
				case READ_WRITE_TRANSACTION:
					/* NO ACTION */
				break;

				default:
					LONGJMP(RIS_E_INTERNAL_ERROR);
			}
		break;

		case READ_WRITE_TRANSACTION:
			switch(transaction_state)
			{
				case NO_TRANSACTION:
				case READ_ONLY_TRANSACTION:

    				if (!RIScom_tmpnam(temp_name))
						LONGJMP(RIS_E_CREATE_TEMP_FILE);

					/*
					**	Create the files if they don't exist
					*/
					if (first_rw_transaction)
					{
						create_files_if_necessary();
						first_rw_transaction = 0;
					}

					/*
					**	lock schema file
					*/
					if (NET_get_lock_file(&RIS_file_net,&RIS_file_connect,
						RIS_lock_file))
					{
						if (RIS_file_net.error_code != NET_E_NO_LOCK)
							LONGJMP(RIS_E_CANT_LOCK_SCHEMA_FILE);

						get_lock_file_loop();
					}

					/*
					**	We now have the lock file.
					**	Write our id in the id file.
					*/
					if ((sts = write_id_file()) != RIS_SUCCESS)
					{
        				RIScco_push_risca_dbca();
						NET_put_lock_file(&RIS_file_net, &RIS_file_connect,
							RIS_lock_file);
        				RIScco_pop_risca_dbca();
						LONGJMP(sts);
					}

					/*
					**	make a copy of the schema file
					*/
					if (NET_get_file(&RIS_file_net, &RIS_file_connect,
							RIS_file, temp_name))
					{
        				RIScco_push_risca_dbca();
						read_id_file(id, ID_BUFFER_SIZE);
						if (!strcmp(id, transaction_id))
							NET_remove_file(&RIS_file_net,&RIS_file_connect,
								RIS_id_file);
						NET_put_lock_file(&RIS_file_net, &RIS_file_connect,
							RIS_lock_file);
        				RIScco_pop_risca_dbca();
						RIScom_remove(temp_name);
						LONGJMP(RIS_E_CANT_GET_SCHEMA_FILE);
					}

					sts = SETJMP();
					if (sts)
					{
						RESETJMP();
        				RIScco_push_risca_dbca();
						RIScom_remove(temp_name);
						read_id_file(id, ID_BUFFER_SIZE);
						if (!strcmp(id, transaction_id))
							NET_remove_file(&RIS_file_net,&RIS_file_connect,
								RIS_id_file);
						NET_put_lock_file(&RIS_file_net,&RIS_file_connect,
							RIS_lock_file);
        				RIScco_pop_risca_dbca();
						LONGJMP(sts);
					}
					RISfil_read_schema_file(temp_name, VERIFY_CHECKSUM);
					RESETJMP();

					RIScom_remove(temp_name);

					save_timestamp = RISfil_timestamp;
					transaction_state = READ_WRITE_TRANSACTION;
				break;

				case READ_WRITE_TRANSACTION:
					/* NO ACTION */
				break;

				default:
					LONGJMP(RIS_E_INTERNAL_ERROR);
			}
		break;

		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}
}

/******************************************************************************/

extern void RISfil_init_check_trans_count()
{
	FIL_DBG(("RISfil_init_check_trans_count()\n"));

	if (!RISfil_schema_tmp_list[RIS_stmt->stmt_id])
	{
		FIL_DBG(("allocating tmp. list structure\n"));
		RISfil_schema_tmp_list[RIS_stmt->stmt_id] = ALLOCT(filsch_tmp_array);
	}
	if (!RISfil_schema_tmp_list[RIS_stmt->stmt_id]->trans)
	{
		RISfil_schema_tmp_list[RIS_stmt->stmt_id]->trans = 1;
		RISfil_trans_count++ ;
		FIL_DBG(("RISfil_trans_count:%d incremented\n",RISfil_trans_count));
	}
	else
	{
		FIL_DBG(("RISfil_trans_count %d NOT incremented\n",RISfil_trans_count));
	}
}

/******************************************************************************/

extern void RISfil_begin_schema_transact(
			int		transaction_type)
{
	unsigned int		sts;
	static	int		tries;

	FIL_DBG(("RISfil_begin_schema_transact(transaction_type:%d)\n", transaction_type));

	RISfil_init_check_trans_count();

	if (!RIS_file[0])
	{
		LONGJMP(RIS_E_NO_SCHFILE_LOCATION);
	}

	tries = 0;
	sts = SETJMP();
	if (sts)
	{
		switch (sts)
		{
			case RIS_E_READ_NO_CHECKSUM:
			case RIS_E_BAD_CHECKSUM:
				tries++;
				FIL_DBG(("Got CHECKSUM error; tries:%d\n", tries));
				if (tries < CHKSUM_RETRY_COUNT)
					break;
				/* NO BREAK */

				default:
				RESETJMP();
				LONGJMP(sts);
		}
	}

	begin_schema_transact_no_chksum_retry(transaction_type);

	RESETJMP();
}

/******************************************************************************/

/*
** Commit a schema transaction.  This is done by replacing the schema file with ** the local copy and unlocking the schema file.
*/

extern void RISfil_commit_schema_transact()
{
	int		sts;
	char	id[ID_BUFFER_SIZE];
	char	temp_name[TEMP_FILE_SIZE];

	FIL_DBG(("RISfil_commit_schema_transact\nRISfil_trans_count:%d\n", 
		RISfil_trans_count));

	switch(transaction_state)
	{
		case NO_TRANSACTION:
			FIL_DBG(("transaction_state: NO_TRANSACTION\n")); break;
		case READ_ONLY_TRANSACTION:
			FIL_DBG(("transaction_state: READ_ONLY_TRANSACTION\n")); break;
		case READ_WRITE_TRANSACTION:
			FIL_DBG(("transaction_state: READ_WRITE_TRANSACTION\n")); break;
		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	if (transaction_state == READ_WRITE_TRANSACTION)
	{
		commit_to_master_list();

		if ((RISfil_trans_count == 1) && (RISfil_commit_flag))
		{
			if (RISfil_timestamp != save_timestamp)
			{
				/*
				**	Read the id file.
				*/
				if ((sts = read_id_file(id, ID_BUFFER_SIZE)) != RIS_SUCCESS)
				{
					RIScco_push_risca_dbca();
					NET_put_lock_file(&RIS_file_net,&RIS_file_connect,
						RIS_lock_file);
					CLEAR_TRANSACTION();
					RIScco_pop_risca_dbca();
					LONGJMP(sts);
				}

				/*
				**	If it isn't mine, I took too long.
				*/
				if (strcmp(id, transaction_id))
				{
					RIScco_push_risca_dbca();
					NET_put_lock_file(&RIS_file_net,&RIS_file_connect,
						RIS_lock_file);
					CLEAR_TRANSACTION();
					RIScco_pop_risca_dbca();
					LONGJMP(RIS_E_TRANSACTION_TOO_LONG);
				}

				/*
				**	If it is mine, remove it.
				*/
				if (NET_remove_file(&RIS_file_net,&RIS_file_connect,
					RIS_id_file))
				{
					RIScco_push_risca_dbca();
					NET_put_lock_file(&RIS_file_net,&RIS_file_connect,
						RIS_lock_file);
					CLEAR_TRANSACTION();
					RIScco_pop_risca_dbca();
					LONGJMP(RIS_E_CANT_REMOVE_ID_FILE);
				}

				if (!RIScom_tmpnam(temp_name)) LONGJMP(RIS_E_CREATE_TEMP_FILE);

				sts = SETJMP();
				if (sts)
				{
					RESETJMP();
					RIScco_push_risca_dbca();
					RIScom_remove(temp_name);
					NET_put_lock_file(&RIS_file_net,&RIS_file_connect,
						RIS_lock_file);
					CLEAR_TRANSACTION();
					RIScco_pop_risca_dbca();
					LONGJMP(sts);
				}
				RISfil_write_schema_file(temp_name);
				RESETJMP();

				/*
				**	copy the updated schema file back to the original node
				*/
				if (NET_put_file(&RIS_file_net,&RIS_file_connect,temp_name,
					RIS_file))
				{
					RIScco_push_risca_dbca();
					RIScom_remove(temp_name);
					NET_put_lock_file(&RIS_file_net,&RIS_file_connect,
						RIS_lock_file);
					CLEAR_TRANSACTION();
					RIScco_pop_risca_dbca();
					LONGJMP(RIS_E_CANT_PUT_SCHEMA_FILE);
				}

				/*
				**	remove the copy of the schema file
				*/
				RIScom_remove(temp_name);
			}
			else
			{
				FIL_DBG(("No changes made to schema file\n"));

				/*
				**	Read the id file.
				*/
				if ((sts = read_id_file(id, ID_BUFFER_SIZE)) != RIS_SUCCESS)
				{
					RIScco_push_risca_dbca();
					NET_put_lock_file(&RIS_file_net,&RIS_file_connect,
						RIS_lock_file);
					CLEAR_TRANSACTION();
					RIScco_pop_risca_dbca();
					LONGJMP(sts);
				}

				/*
				**	If it is mine, remove it.
				*/
				if (NET_remove_file(&RIS_file_net,&RIS_file_connect,
					RIS_id_file))
				{
					RIScco_push_risca_dbca();
					NET_put_lock_file(&RIS_file_net,&RIS_file_connect,
						RIS_lock_file);
					CLEAR_TRANSACTION();
					RIScco_pop_risca_dbca();
					LONGJMP(RIS_E_CANT_REMOVE_ID_FILE);
				}
			}

			/*
			**	unlock file
			*/
			if (NET_put_lock_file(&RIS_file_net,&RIS_file_connect,
				RIS_lock_file))
			{
				CLEAR_TRANSACTION();
				LONGJMP(RIS_E_CANT_UNLOCK_SCHEMA_FILE);
			}
			CLEAR_TRANSACTION();
		}
		else if (RISfil_trans_count > 1)
		{
			DECR_TRANS_COUNT();
			return;
		}
	}
	else if (transaction_state == READ_ONLY_TRANSACTION)
	{
		commit_to_master_list();
		if (RISfil_trans_count == 1)
		{
			CLEAR_TRANSACTION();
		}
		else if (RISfil_trans_count > 1)
		{
			DECR_TRANS_COUNT();
			return;
		}
	}
	CLEAR_READ_TRANSACTION();
}

/******************************************************************************/

static void commit_to_master_list()
{
	fildb_tmp_list 	*tmp_dbp;
	fildb_list 		*dbp, *dbp1;
	filsch_tmp_list *tmp_schp;
	filsch_list 	*schp, *schp1;

	FIL_DBG(("commit_to_master_list: START RISfil_trans_count %d RISfil_commit_flag %d\n",RISfil_trans_count, RISfil_commit_flag));

if (RISfil_debug)
{
RIScom_output_debug("*********************************************************\n");
RISfil_print_lists();
RIScom_output_debug("*********************************************************\n");
RISfil_print_temp_list(RIS_stmt->stmt_id);
RIScom_output_debug("*********************************************************\n");
}

	for (tmp_dbp = RISfil_db_tmp_list[RIS_stmt->stmt_id]; tmp_dbp; 
		tmp_dbp=tmp_dbp->next)
	{
		/*
		** If temporary risdb structure exists and corresponding
		** master list structure does not exist, it must be a new
		** database (through a create schema statement). So INSERT 
		** into master list.
		*/
		if ((tmp_dbp->tmp_dbp) && (!tmp_dbp->master_dbp))
		{
	FIL_DBG(("In IF 2 ^^^^^^^^^^^^^^^^^^^^^^\n"));
			dbp = ALLOCT(fildb_list);
			dbp->update_lock_flag = UPDATE_LOCK_OFF;
			dbp->dbp = ALLOCT(risdb);
			RISfil_copy_db (dbp->dbp, tmp_dbp->tmp_dbp, ALL_FLAG);
			dbp->next = RISfil_db_list;
			RISfil_db_list = dbp;
		}
		/*
		** If temporary risdb structure does not exist and corresponding
		** master list structure exists,the database must have been DROPPED 
		** (through a drop schema statement)
		*/
		else if ((!tmp_dbp->tmp_dbp) && (tmp_dbp->master_dbp))
		{
	FIL_DBG(("In ELSE IF 2 ^^^^^^^^^^^^^^^^^^^^^^\n"));
			dbp = RISfil_db_list;
			/*
			** If it is the first one in the list
			*/
			if (dbp == tmp_dbp->master_dbp)
			{
	FIL_DBG(("In IF 3 ---------------------------\n"));
				tmp_dbp->master_dbp->dbp = NULL;
				RISfil_db_list = dbp->next;
				tmp_dbp->master_dbp = NULL;
				dbp =NULL;
			}
			else
			{
	FIL_DBG(("In ELSE 3 ---------------------------\n"));
				dbp1 = dbp;
				dbp = dbp->next;
				while (dbp1)
				{
	FIL_DBG(("In WHILE 4 +++++++++++++++++++++++++++\n"));
					if (dbp == tmp_dbp->master_dbp)
					{
	FIL_DBG(("In WHILE / IF 5 +++++++++++++++++++++++++++\n"));
						tmp_dbp->master_dbp->dbp = 0;
						dbp1->next = dbp->next;
						dbp = 0;
						tmp_dbp->master_dbp = 0;
						break;
					}
					else
					{	
	FIL_DBG(("In WHILE / ELSE 5 +++++++++++++++++++++++++++\n"));
						dbp1 = dbp;
						if (!dbp1)
						{
							/*
							** Couldnt match up properly
							*/
							LONGJMP(RIS_E_INTERNAL_ERROR);
						}
						dbp = dbp->next;
					}
				}
			}
		}
		/*
		** If both, the temp. and master structs exist, then it must
		** be an UPDATE.
		*/
		else if ((tmp_dbp->tmp_dbp) && (tmp_dbp->master_dbp))
		{
	FIL_DBG(("In ELSE IF 3 ^^^^^^^^^^^^^^^^^^^^^^\n"));
			tmp_dbp->master_dbp->update_lock_flag = UPDATE_LOCK_OFF;
			RISfil_copy_db (tmp_dbp->master_dbp->dbp,tmp_dbp->tmp_dbp,ALL_FLAG);
			tmp_dbp->master_dbp = 0;
		}
		else
		{
			/*
			** Something wrong somewhere
			*/
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
		RIS_FIL_COMMIT_FLAG_ON();
	}
	RISfil_db_tmp_list[RIS_stmt->stmt_id] = NULL;

	if (RISfil_schema_tmp_list[RIS_stmt->stmt_id])
	{
		for (tmp_schp = RISfil_schema_tmp_list[RIS_stmt->stmt_id]->list;
			 tmp_schp; 
			 tmp_schp=tmp_schp->next)
		{
			FIL_DBG(("SCHEMA TMP LIST 1\n"));
			/*
			** If temporary risschema structure exists and corresponding
			** master list structure does not exist, it must be a new
			** schema (through a create schema statement). So INSERT 
			** into master schema list.
			*/
			if ((tmp_schp->tmp_schemap) && (!tmp_schp->master_schp))
			{
			FIL_DBG(("SCHEMA TMP LIST 2\n"));
				schp = ALLOCT(filsch_list);
				schp->update_lock_flag = UPDATE_LOCK_OFF;
				schp->schemap = ALLOCT(risschema);
				RISfil_copy_schema (schp->schemap, tmp_schp->tmp_schemap, 
					ALL_FLAG);
				schp->next = RISfil_schema_list;
				RISfil_schema_list = schp;
			}
			/*
			** If temporary risschema structure does not exist and corresponding
			** master list structure exists, the schema must have been DROPPED 
			** (through a drop schema statement)
			*/
			else if ((!tmp_schp->tmp_schemap) && (tmp_schp->master_schp))
			{
			FIL_DBG(("SCHEMA TMP LIST 3\n"));
				schp = RISfil_schema_list;
				/*
				** If it is the first one in the list
				*/
				if (schp == tmp_schp->master_schp)
				{
			FIL_DBG(("SCHEMA TMP LIST 4\n"));
					tmp_schp->master_schp->schemap = NULL;
					RISfil_schema_list = schp->next;
					tmp_schp->master_schp = NULL;
					schp = NULL;
				}
				else
				{
			FIL_DBG(("SCHEMA TMP LIST 5\n"));
					schp1 = schp;
					schp = schp->next;
					while (schp1)
					{
			FIL_DBG(("SCHEMA TMP LIST 6\n"));
						if (schp == tmp_schp->master_schp)
						{
			FIL_DBG(("SCHEMA TMP LIST 7\n"));
							tmp_schp->master_schp->schemap = 0;
							schp1->next = schp->next;
							schp = 0;
							tmp_schp->master_schp = 0;
							break;
						}
						else
						{
			FIL_DBG(("SCHEMA TMP LIST 8\n"));
							schp1 = schp;
							if (!schp1)
							{
								/*
								** Couldnt match up properly
								*/
								LONGJMP(RIS_E_INTERNAL_ERROR);
							}
							schp = schp->next;
						}
					}
				}
			}

			/*
			** If both, the temp. and master structs exist, then it must
			** be an UPDATE.
			*/
			else if ((tmp_schp->tmp_schemap) && (tmp_schp->master_schp))
			{
		FIL_DBG(("SCHEMA TMP LIST 9\n"));

				if (RISfil_debug)
				{
					RIScom_output_debug("tmp pass: %s master pass: %s\n",
						tmp_schp->tmp_schemap->passwd, 
						tmp_schp->master_schp->schemap->passwd);
	
					RIScom_output_debug("master_schp: 0x%x\n",
						tmp_schp->master_schp);
				}
				tmp_schp->master_schp->update_lock_flag = UPDATE_LOCK_OFF;
				RISfil_copy_schema (tmp_schp->master_schp->schemap,
					tmp_schp->tmp_schemap, ALL_FLAG);

				if (RISfil_debug)
				{
					RIScom_output_debug("tmp pass: %s master pass: %s\n",
						tmp_schp->tmp_schemap->passwd, 
						tmp_schp->master_schp->schemap->passwd);
				}
				tmp_schp->master_schp = 0;
			}
			else
			{
				/*
				** Something wrong somewhere
				*/
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}
			RIS_FIL_COMMIT_FLAG_ON();
		}
		RISfil_schema_tmp_list[RIS_stmt->stmt_id]->list = NULL;
	}
	else
	{
		FIL_DBG(("commit_to_master_list: RISfil_schema_tmp_list[%d] is NULL\n",
			RIS_stmt->stmt_id));
	}

	FIL_DBG(("commit_to_master_list: END RISfil_trans_count %d RISfil_commit_flag %d\n",RISfil_trans_count, RISfil_commit_flag));

}

/*
** Rollback a schema transaction.  This is done by removing the local copy and
** unlocking the schema file.  If an error occurs during a rollback, this
** routine won't longjmp, it will continue on as best as possible.
*/

extern void RISfil_rollback_schema_transact()
{
	char		id[ID_BUFFER_SIZE];

	FIL_DBG(("RISfil_rollback_schema_transact stmt_id:%d\n",
		RIS_stmt->stmt_id));

	RISfil_db_tmp_list[RIS_stmt->stmt_id] = NULL;
	if (RISfil_schema_tmp_list[RIS_stmt->stmt_id])
	{
		RISfil_schema_tmp_list[RIS_stmt->stmt_id]->list = NULL;
	}

	if (RISfil_trans_count == 1) 
	{
		switch(transaction_state)
		{
			case NO_TRANSACTION:
				FIL_DBG(("transaction_state: NO_TRANSACTION\n")); break;
			case READ_ONLY_TRANSACTION:
				FIL_DBG(("transaction_state: READ_ONLY_TRANSACTION\n")); break;
			case READ_WRITE_TRANSACTION:
				FIL_DBG(("transaction_state: READ_WRITE_TRANSACTION\n")); break;
			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
		}

		/*
		**	Read the id file.
		*/
		if (read_id_file(id, ID_BUFFER_SIZE))
		{
			/*
			**	Ignore the error and clear dbca
			*/
			RIScom_clear_sqlca(dbca);
		}
		else
		{
			/*
			**	If it is mine, remove it.
			*/
			if (*id && !strcmp(id, transaction_id))
			{
				if (NET_remove_file(&RIS_file_net,&RIS_file_connect,
					RIS_id_file))
				{
					RIScom_clear_sqlca(dbca);
				}
			}
		}

		if (transaction_state == READ_WRITE_TRANSACTION)
		{
			/*
			**	unlock the schema file
			*/
			if (NET_put_lock_file(&RIS_file_net,&RIS_file_connect,
				RIS_lock_file))
			{
				/*
				**	Ignore the error and clear dbca
				*/
				RIScom_clear_sqlca(dbca);
			}
		}
		CLEAR_TRANSACTION();
	}
	else if (RISfil_trans_count > 1)
	{
		DECR_TRANS_COUNT();
		return;
	}
	CLEAR_READ_TRANSACTION();
}

/******************************************************************************/

extern int RISfil_recalculate_schema_file_checksum()
{
	int			sts;
	char		temp_name[TEMP_FILE_SIZE];
	static char	file_does_not_exist = 1;

	FIL_DBG(("RISfil_recalculate_schema_file_checksum()\n"));

	RISfil_init_check_trans_count();

	if (!RIScom_tmpnam(temp_name))
		LONGJMP(RIS_E_CREATE_TEMP_FILE);

	/*
	**	Create the files if they don't exist
	*/
	if (file_does_not_exist)
	{
		create_files_if_necessary();
		file_does_not_exist = 0;
	}

	/*
	**	lock schema file
	*/
	if (NET_get_lock_file(&RIS_file_net,&RIS_file_connect, RIS_lock_file))
	{
		if (RIS_file_net.error_code != NET_E_NO_LOCK)
			LONGJMP(RIS_E_CANT_LOCK_SCHEMA_FILE);
		get_lock_file_loop();
	}

	/*
	**	We now have the lock file.
	**	Write our id in the id file.
	*/
	if ((sts = write_id_file()) != RIS_SUCCESS)
	{
   		RIScco_push_risca_dbca();
		NET_put_lock_file(&RIS_file_net, &RIS_file_connect, RIS_lock_file);
   		RIScco_pop_risca_dbca();
		LONGJMP(sts);
	}

	/*
	**	make a copy of the schema file
	*/
	if (NET_get_file(&RIS_file_net,&RIS_file_connect,RIS_file,temp_name))
	{
       	RIScco_push_risca_dbca();
		NET_put_lock_file(&RIS_file_net,&RIS_file_connect, RIS_lock_file);
       	RIScco_pop_risca_dbca();
		RIScom_remove(temp_name);
		LONGJMP(RIS_E_CANT_GET_SCHEMA_FILE);
	}

	sts = SETJMP();
	if (sts)
	{
		RESETJMP();
       	RIScco_push_risca_dbca();
		RIScom_remove(temp_name);
		NET_put_lock_file(&RIS_file_net,&RIS_file_connect,RIS_lock_file);
        RIScco_pop_risca_dbca();
		LONGJMP(sts);
	}
	RISfil_read_schema_file(temp_name, IGNORE_CHECKSUM);
	RESETJMP();
	RIScom_remove(temp_name);

	save_timestamp = RISfil_timestamp;
	transaction_state = READ_WRITE_TRANSACTION;

	/*
	**	Change the value of RISfil_timestamp, which causes commit to rewrite
	**	the file, which in turn causes the checksum to be recalculated.
	*/
	RISfil_timestamp = time(0);

	RIS_FIL_COMMIT_FLAG_ON();

	return RIS_SUCCESS;
}
