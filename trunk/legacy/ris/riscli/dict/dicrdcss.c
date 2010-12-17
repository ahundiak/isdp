/*
**  NAME:                           dicrdcss.c
**  AUTHORS:                        Prasad Challa
**  CREATION DATE:                  10/91
**  ABSTRACT:			
**
**
**  REVISION HISTORY:
*/

/*
**  INCLUDES
*/
#include "risasync.h"
#include "riscom.h"
#include "ristoken.h"
#include "dict.h"

/*
**  DEFINES
*/

/*
**  VARIABLES
*/

/*
**  FUNCTIONS
*/


/*
**      FUNCTION PROTOTYPES
*/
#define dicrdcss_c
#include "cliprep.prt"
#include "cliclear.prt"
#include "clitab.prt"
#include "clisvglb.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "compd.prt"
#include "comswmem.prt"
#include "dicdecss.prt"
#include "diclook.prt"
#include "dicopsch.prt"
#include "dicrdcss.prt"
#include "dicundss.prt"
#include "sys.prt"

/******************************************************************************/

extern void RISdic_redecl_superschema(
	ristree *tp)
{
	rissuperschema *redecl_sschema;

DIC_DBG(("RISredic_decl_superschema tp = 0x%x\n", tp));

/*
** check to see if the superschema exists, to be redeclared. 
*/
	if(!(redecl_sschema = RISdic_find_supersch(tp->rhs->lhs->info.val)))
	{
		LONGJMP(RIS_E_SUPERSCHEMA_NOT_DECLARED);
	}

	switch (tp->rhs->rhs->lhs->tok)
	{
		case RIS_TOK_SWAP:

/*
** swap primary with secondary option. Here primary schema becomes secondary
** and the secondary becomes the primary.
*/
			RISdic_swap
			(tp->rhs->rhs->lhs->rhs->lhs->rhs->lhs->info.val, redecl_sschema);
		break;

		case RIS_TOK_REPLACE:

/*
** replace primary with secondary option. Here the specified secondary schema
** becomes the primary and the original primary goes offline (dropped)
*/
			RISdic_replace
			(tp->rhs->rhs->lhs->rhs->lhs->rhs->lhs->info.val, redecl_sschema);
		break;

		case RIS_TOK_ADD:

/*
** add secondary option
*/
			RISdic_add_secondary(tp, redecl_sschema);
		break;

		case RIS_TOK_DROP:

/*
** drop secondary option
*/
			RISdic_drop_secondary
			(tp->rhs->rhs->lhs->rhs->lhs->rhs->lhs->info.val, redecl_sschema);
		break;

		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
		break;
	}
}

/******************************************************************************/

static void RISdic_add_secondary(
	ristree *tp,
	rissuperschema *sschema)
{
	risschema *add_schema;
	ristree *temptp;
	int status;
	int sub_sch_num;

DIC_DBG(("RISadd_secondary tp = 0x%x sschema = 0x%x\n", tp, sschema));

/*
** check to see if the number of schemas defined on a superschema are less
** than or equal to the number of allowed secondaries, if the new schema is
** added.
*/

	sub_sch_num = RISdic_get_subsch_num(sschema);

	if(sub_sch_num > RIS_parms.max_secondary_schemas)
	{
		LONGJMP(RIS_E_SCHEMA_OVERFLOW);
	}

	status = SETJMP();
	if (!status)
	{
		temptp = tp->rhs->rhs->lhs->rhs->lhs->rhs->lhs;
		if(RISdic_find_supersch(temptp->info.val))
		{
			RESETJMP();
			LONGJMP(RIS_E_SCHEMA_EXISTS_ALREADY);
		}

		add_schema = RISdic_open_schema(temptp->info.val, SYNC_MODE);

		if(!RIScom_pd_same(temptp->rhs->info.val, add_schema->schpass))
		{
			RESETJMP();
/*
**  Changed error to RIS_E_UNKNOWN_SCHEMA to be consistent with RIS 4.3.
**  by checking for application version.
**  This fixes TR# 249406468. RAJU 09/19/94.
**	For V5 application the corresponding error is:
**	LONGJMP(RIS_E_SCHPASS_NOT_SAME);
*/
			if (RIS_app_cli_version < 5)
				LONGJMP(RIS_E_UNKNOWN_SCHEMA);
			else
				LONGJMP(RIS_E_SCHPASS_NOT_SAME);
		}

		if(add_schema->superschema_flag != REGULAR_SCHEMA)
		{
			RESETJMP();
			LONGJMP(RIS_E_INVOLVED_IN_OTHER_SUPERSCHEMA);
		}

	/*
	** clear all stmts prepared on this add_schema
	*/
		RISdic_clear_stmts(add_schema);

	/*
    ** secondary schema might have died during above RIScli_clear() which
    ** returns silently even if there were errors
    */
       if( !RISdic_lookup_schema(temptp->info.val, HASH_TABLE) )
       {
          RESETJMP();
          LONGJMP(RIS_E_SCHEMA_DIED);
       }

    /*
    ** prepare stmts on this add_schema (stmts which were previously prepared
    ** on primary schema)
    */
        RISdic_prepare_all(sschema, add_schema);
 
	/*
	** adding it to the secondary schema list
	*/
		add_schema->superschema_flag = SECONDARY_SCHEMA;
		add_schema->super_schp = sschema;

		add_schema->sub_schp = sschema->sub_schp->sub_schp;
		sschema->sub_schp->sub_schp = add_schema;
	}
	RESETJMP();

	if (status)
	{
		LONGJMP(status);
	}

DIC_DBG(("RISadd_secondary complete:\n"));

}

/******************************************************************************/

static void RISdic_prepare_all(
	rissuperschema *super_sch, 
	risschema *second_sch)
{

	int id;
	unsigned int s_id;
	int i;
	short temp_id;
	int status;

DIC_DBG(("RISdic_prepare_all super_sch = 0x%x second_sch = 0x%x\n", 
super_sch , second_sch));

DIC_DBG(("super_schname = <%s> second_schname = <%s>\n", 
super_sch ? super_sch->schname : "NONE", second_sch ? second_sch->schname 
: "NONE"));

/*
**  save the original default schema, stmt, current_stmt_id
*/
	RIScli_save_globals();

	status = SETJMP();
	if (!status)
	{
/*
** preparing all the statements, which were prepared on the primary schema, for
** the new secondary schema.
*/

		for (id=0; id< RIS_parms.max_user_stmts; id++)
		{
			if(RIS_stmts[id] && RIS_stmts[id]->sql &&
			   RIS_stmts[id]->sql->schema == super_sch->sub_schp)
			{
				if(strcmp(RIS_stmts[id]->prep_def_schname, 
				   RIS_stmts[id]->sql->schema->schname)==0)
				{
					RIS_default = second_sch;
				}
				else
				{
					RIS_default = RISdic_open_schema(
					RIS_stmts[id]->prep_def_schname, SYNC_MODE);
				}

				for(s_id=RIS_parms.max_user_stmts;
					s_id<(unsigned int)(RIS_parms.max_user_stmts+RIS_max_secondary_stmts);
					s_id++)
				{
					if (!RIS_stmts[s_id]) 
						break;
				}
				status = SETJMP();
				if (status)
				{
					RESETJMP();
					for (i=0;i < id;i++)
					{
						if(RIS_stmts[i] && RIS_stmts[i]->sql &&
						   RIS_stmts[i]->sql->schema == super_sch->sub_schp)
						{
							temp_id = RIS_stmts[i]->next->stmt_id;
							RIS_stmts[i]->next = RIS_stmts[i]->next->next;
							RIScli_clear(temp_id, 0, SYNC_MODE, 0);
						}
					}
					LONGJMP(status);
				}
				RIScli_put_tables_in_hash(id,super_sch->sub_schp,second_sch);
				RIScli_prepare((short)s_id,RIS_stmts[id]->query,
				 super_sch->schname, second_sch->schname, (short)id);
				RIS_stmts[s_id]->next = RIS_stmts[id]->next;
				RIS_stmts[id]->next = RIS_stmts[s_id];
				RESETJMP();
			}
		}
	}
	else
	{
		RESETJMP();
/*
**  restoring the globals
*/
		RIScli_restore_globals();
		LONGJMP(status);
	}

	RESETJMP();
/*
**  restoring the globals
*/
	RIScli_restore_globals();
}
	
/******************************************************************************/

extern void RISdic_drop_secondary(
	char *drop_sec_schema,
	rissuperschema *sschema)
{
	risschema *drop_schema;

DIC_DBG(("RISdic_drop_secondary drop_sec_schema = <%s> sschema = 0x%x\n", 
		STRING(drop_sec_schema), sschema));

	if(drop_schema = RISdic_validate_secondary(drop_sec_schema))
	{
/*
**    Make it regular schema and remove it from the secondary list
*/
		drop_schema->superschema_flag = REGULAR_SCHEMA;
		drop_schema->super_schp = 0;
		RISdic_rem_from_sec_list(sschema, drop_schema);

/*
**    Clear all stmts on drop_schema
*/
      RISdic_drop_sec_clear_stmts(drop_schema);
	}
	
}

/******************************************************************************/

static risschema *RISdic_validate_secondary(
	char *sec_schema)
{
	risschema *schema;

DIC_DBG(("RISdic_validate_secondary sec_schema = <%s>\n", STRING(sec_schema)));

	schema = RISdic_lookup_schema(sec_schema, HASH_TABLE);
	if(!schema || schema->superschema_flag != SECONDARY_SCHEMA)
	{
		LONGJMP(RIS_E_NOT_A_SECONDARY);
	}
	return(schema);
}

/******************************************************************************/

extern void RISdic_swap(
	char   *sec_sch_name,
	rissuperschema *sschema)
{
	risschema *sec_schema;
	risschema *prime_schema;
	int primary_id;
	risstmt * primary_stmt;
	risstmt * secondary_stmt;
	risstmt * temp;
	
DIC_DBG(("RISdic_swap: sec_sch_name = <%s> sschema = 0x%x\n",
STRING(sec_sch_name), sschema));

	sec_schema = RISdic_validate_secondary(sec_sch_name);
	prime_schema = sschema->sub_schp;

	RISdic_rem_from_sec_list(sschema, sec_schema);

/*
**	swapping all the statements between the primary and the given secondary.
**  Except the one being cleared indicated by swap_n_clear_flag
*/

	for(primary_id=0; primary_id < RIS_parms.max_user_stmts; primary_id++)
	{
		if(RIS_stmts[primary_id] &&
		   RIS_stmts[primary_id]->sql &&
		   RIS_stmts[primary_id]->sql->schema == prime_schema &&
		   !RIS_stmts[primary_id]->swap_n_clear_flag)
		{
			primary_stmt = RIS_stmts[primary_id];

DIC_DBG(("RISdic_swap: swapping stmt_id = <%d>\n", primary_stmt->stmt_id));

/*
**  getting secondary statement that is to be swapped.
*/
			for (secondary_stmt = primary_stmt->next;
				 secondary_stmt && secondary_stmt->sql->schema != sec_schema;
				 secondary_stmt=secondary_stmt->next);

/*
**  converting the risstmt linked list to a circular chain TEMPORARILY; to
**	make the swapping much simpler.
*/
			 for(temp=primary_stmt;temp;temp=temp->next)
			 {
				if(temp->next == NULL)
				{
					temp->next = primary_stmt;
					break;
				}
			 }
/*
**	swapping the low level allocated memory for the given primary and
**  secondary statements.
*/
			RIScom_swap_mem(primary_stmt->stmt_id, secondary_stmt->stmt_id);

			RIS_stmts[primary_stmt->stmt_id] = secondary_stmt;
			RIS_stmts[secondary_stmt->stmt_id] = primary_stmt;

/*
**  after swapping, statement ids need be set to the right values.
*/
			primary_stmt->stmt_id = secondary_stmt->stmt_id;
			secondary_stmt->stmt_id = (short)primary_id;

/*
** converting the circular risstmt structure, back to the regular linked 
** list.
*/
			for(temp=primary_stmt;temp;temp=temp->next)
			{
				if(temp->next == secondary_stmt)
				{
					temp->next = NULL;
					break;
				}
			}
		}
	}

/*
** make the secondary the new primary
*/
	sec_schema->superschema_flag = PRIMARY_SCHEMA;
	sschema->sub_schp = sec_schema;

/*
** making the old primary secondary
*/
	prime_schema->superschema_flag = SECONDARY_SCHEMA;
	sec_schema->sub_schp = prime_schema;

/*
** we always set the primary schema to be the default schema
*/
	RIS_default = sec_schema;	

}

/******************************************************************************/

/*
** First we do a swap and then we drop the secondary.
*/

extern void RISdic_replace(
	char   *sec_sch_name,
	rissuperschema *sschema)
{
	risschema *drop_schema;

DIC_DBG(("RISdic_replace: sec_sch_name = <%s> sschema = 0x%x\n",
STRING(sec_sch_name), sschema));

	drop_schema = sschema->sub_schp;

	RISdic_swap(sec_sch_name, sschema);

	RISdic_drop_secondary(drop_schema->schname,sschema);
}

/******************************************************************************/

/*
** removing the secondary from the secondary_list
*/

static void RISdic_rem_from_sec_list(
	rissuperschema *sschema,
	risschema *sec_schema)
{
	risschema *temp1;
	risschema *temp2;

DIC_DBG(("RISdic_rem_from_sec_list(sschema: 0x%x  sec_schema: 0x%x)\n",sschema,sec_schema));

	for(temp1=0, temp2=sschema->sub_schp->sub_schp;
	    temp2;
			temp2=temp2->sub_schp)
	{
		if (temp2 == sec_schema)
		{
			if(!temp1)
			{
				sschema->sub_schp->sub_schp = temp2->sub_schp;
			}
			else
			{
				temp1->sub_schp = temp2->sub_schp;
			}
			break;
		}
		else
		{
			temp1 = temp2;
		}
	}
}

/******************************************************************************/

/*
** When we drop a secondary using 'redeclare' statement, we clear all the 
** statements prepared on that schema.
*/

extern void RISdic_drop_sec_clear_stmts(
    risschema * schema)
{
    int i;
	short save_id;
	risstmt *stmt;
	risstmt *stmtp;
    risstmt *save_next;
    risstmt *drop_stmt_headp = 0;
    risstmt *drop_stmt_currp = 0;

DIC_DBG(("RISdic_drop_sec_clear_stmts schema = <%s>\n", 
			STRING(schema->schname)));

/*
** In the CLIclear we manipulate statement id and risstatement structure.
** So we need to save the original values and restore 'em when we are done
** with the clear operation
*/
DIC_DBG(("RIS_current_stmt_id:%d\n", RIS_current_stmt_id));
    save_id = RIS_current_stmt_id;

/*
**  Unlink all the statements prepared on "dropping" schema
*/
	for (i = RIS_parms.max_user_stmts;
		 i < (int)(RIS_parms.max_user_stmts+RIS_max_secondary_stmts);
		 i++)
	{
		if(RIS_stmts[i] &&
		   RIS_stmts[i]->sql &&
		   RIS_stmts[i]->sql->schema == schema)
		{
			stmt = RIS_stmts[i];
/*
**  Create a link-list of stmts to be cleared
*/
            if( drop_stmt_headp )
            {
                drop_stmt_currp->next = stmt;
                drop_stmt_currp = stmt;
            }
            else
            {
                drop_stmt_headp = drop_stmt_currp = stmt;
            }
/*
**  Unlink this stmt from the list
*/
            for(stmtp = RIS_stmts[stmt->primary_id];
					stmtp && stmtp->next != stmt;
				      	stmtp = stmtp->next);
				stmtp->next = stmt->next;

/*
**	TDM & HRP - 10/28/93 : next still points to valid stmt linked list,
**	set it to null to completely remove it from list.
*/
			stmt->next = NULL;
		}
	}
/*
**    Now, Clear all the statements prepared on "dropping" schema
*/
	for (drop_stmt_currp = drop_stmt_headp;
            drop_stmt_currp;
                drop_stmt_currp = save_next)
    {
        save_next = drop_stmt_currp->next;
        /*
        **  Clear stmts on as a regular schema
        */
        RIScli_clear(drop_stmt_currp->stmt_id,0,SYNC_MODE,0);
    }

/*
** restoring ristatement and id.
*/
    RIS_stmt = RIS_stmts[save_id];
    RIS_current_stmt_id = save_id;
DIC_DBG(("RIS_current_stmt_id:%d\n", RIS_current_stmt_id));

}

/******************************************************************************/
