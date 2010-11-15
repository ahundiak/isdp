/*
**  NAME:                           dicdecss.c
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
#include "rismem.h"
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
#define dicdecss_c
#include "cliclear.prt" 
#include "ccoclstm.prt" 
#include "ccoss_id.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comgtnme.prt"
#include "dicdecss.prt"
#include "dicopsch.prt"
#include "diclook.prt"
#include "dicundss.prt"
#include "sys.prt"


/******************************************************************************/

extern void RISdic_decl_superschema(
	ristree *tp)
{
	int		  ssid = -1;
	rissuperschema *decl_sschema=0;
	risschema *temp;
	risschema *temp2=0;
	ristree   *primary;
	ristree   *secondary;
	int	total_sch_num = 0;
	char * ssch_name;
	int status;

DIC_DBG(("RISdic_decl_superschema tp = 0x%x\n", tp));

	ssch_name = tp->rhs->lhs->info.val;

	if(decl_sschema = RISdic_find_supersch(ssch_name))
	{
		LONGJMP(RIS_E_SCHEMA_EXISTS_ALREADY);
	}

	if(temp = RISdic_lookup_schema(ssch_name, HASH_TABLE|SCHEMA_FILE))
	{
		LONGJMP(RIS_E_SCHEMA_EXISTS_ALREADY);
	}

/*
** allocating and filling the superschema and building the superschema list
*/
	ssid = RIScco_new_sschema_id(ssch_name);
	decl_sschema = ALLOCTSS(ssid,rissuperschema);
	strcpy(decl_sschema->schname, ssch_name);
	decl_sschema->ssid = (short)ssid;
	RIS_ssmem[ssid] = decl_sschema;
	decl_sschema->primary_id = -1;

/*
** validating primary schema 
*/
	primary=tp->rhs->rhs->lhs->rhs->lhs;

/*
** setting total schemas involved in a superschema to 1 because of 
** primary schema
*/
	total_sch_num++;

	status = SETJMP();
	if(!status)
	{
		decl_sschema->sub_schp = 
		RISdic_default_schema(primary->info.val, primary->rhs->info.val, SYNC_MODE);
		RESETJMP();
	}
	else
	{
		RESETJMP();
		RISdic_free_supersch_str(decl_sschema);
		LONGJMP(status);
	}

/*
** its involved as a primary or secondary schema in a superschema
*/
    if(decl_sschema->sub_schp->superschema_flag != REGULAR_SCHEMA)
    {
        RISdic_free_supersch_str(decl_sschema);
        LONGJMP(RIS_E_INVOLVED_IN_OTHER_SUPERSCHEMA);
    }
/*
** clearing any statements involved with the primary schema
*/
	status = SETJMP();
	if(!status)
	{
		RISdic_clear_stmts(decl_sschema->sub_schp);
		RESETJMP();
	}
	else
	{
		RESETJMP();
		RISdic_reset_n_free_supersch_stuff(decl_sschema);
		LONGJMP(status);
	}

/*
** primary schema might have died during above RIScli_clear() which returns
** silently even if there were errors
*/
	if( !RISdic_lookup_schema(primary->info.val, HASH_TABLE) )
	{
		RESETJMP();
		LONGJMP(RIS_E_SCHEMA_DIED);
	}

/*
** make it a primary schema in a superschema
*/
	decl_sschema->sub_schp->superschema_flag = PRIMARY_SCHEMA;
	decl_sschema->sub_schp->super_schp = decl_sschema;
	decl_sschema->sub_schp->sub_schp = 0;

/*
** creating and filling secondary schema list, if it exists 
*/

	if(tp->rhs->rhs->rhs)
	{
		for(secondary=tp->rhs->rhs->rhs->lhs->rhs; secondary;
		 secondary=secondary->rhs)
		{
			total_sch_num++;

	/*
	** total number of schemas defined for a superschema should be <= 
	** RIS_parms.max_secondary_schemas+1
	*/
			if (total_sch_num > RIS_parms.max_secondary_schemas+1)
			{
				RISdic_reset_n_free_supersch_stuff(decl_sschema);
				LONGJMP(RIS_E_SCHEMA_OVERFLOW);
			}

	/*
	** validating secondary schema 
	*/
			temp = decl_sschema->sub_schp->sub_schp;

			status = SETJMP();
			if(!status)
			{
				temp2 =
				RISdic_default_schema(secondary->lhs->info.val, secondary->lhs->rhs->info.val, SYNC_MODE);
				RESETJMP();
	/*
	** Making sure that it is not involved in a superschema 
	*/
				if(temp2->superschema_flag != REGULAR_SCHEMA)
				{
					RISdic_reset_n_free_supersch_stuff(decl_sschema);
					LONGJMP(RIS_E_INVOLVED_IN_OTHER_SUPERSCHEMA);
				}

			}
			else
			{
				RESETJMP();
				RISdic_reset_n_free_supersch_stuff(decl_sschema);
				LONGJMP(status);
			}

			decl_sschema->sub_schp->sub_schp = temp2;

	/*
	** clearing any statements involved with the secondary schema 
	*/
			status = SETJMP();
			if(!status)
			{
				RISdic_clear_stmts(decl_sschema->sub_schp->sub_schp);
/*
** secondary schema might have died during above RIScli_clear() which returns
** silently even if there were errors
*/
				if(!RISdic_lookup_schema(secondary->lhs->info.val, HASH_TABLE))
				{
					RESETJMP();
					LONGJMP(RIS_E_SCHEMA_DIED);
				}
				RESETJMP();
			}
			else
			{
				RESETJMP();
				RISdic_reset_n_free_supersch_stuff(decl_sschema);
				LONGJMP(status);
			}

/*
** setting the secondary flag and superschema ptr of the new secondary
*/
			decl_sschema->sub_schp->sub_schp->superschema_flag =
			 SECONDARY_SCHEMA;
			decl_sschema->sub_schp->sub_schp->super_schp = decl_sschema;

			decl_sschema->sub_schp->sub_schp->sub_schp = temp;
		}
	}

/*
** setting default to primary schema of a superschema
*/
	RIS_default = decl_sschema->sub_schp;

/*
** building a list of superschemas; assigning RIS_super_schema, the start
** pointer of the list.
*/

	decl_sschema->next = RIS_super_schema;
	RIS_super_schema = decl_sschema;
}

/******************************************************************************/

/*
** We clear any active statements in a given schema before it becomes a part
** of a superschema. That is, when declaring and redeclaring with add
** secondary feature--we use this.
*/

extern void RISdic_clear_stmts(
    risschema * schema)
{
    short i;
	short save_id;

DIC_DBG(("RISdic_clear_stmts schema.name = <%s>\n", STRING(schema->schname)));

/*
** In the CLIclear we manipulate statement id and risstatement structure.
** So we need to save the original values and restore 'em when we are done
** with the clear operation
*/
	save_id = RIS_current_stmt_id;

/*
** For the statements of the type 'create schema', 'alter schema' etc. (as
** shown below) the sql->schema ptr is not set. So we need to treat them
** differently for clearing. We traverse the query tree to see if the schema
** name (which is going to be a part of the superschema) exists in the tree.
*/
    for (i=0; i<(short)RIS_parms.max_user_stmts; i++)
    {
    	if( ( RIS_stmts[i]												&& 
			  RIS_stmts[i]->sql											&& 
			  RIS_stmts[i]->sql->schema == schema
			)																||
			  ( RIS_stmts[i]											&&
				RIS_stmts[i]->tree										&&
               	( RIS_stmts[i]->tree->tok == RIS_TOK_CREATE_SCHEMA ||
                  RIS_stmts[i]->tree->tok == RIS_TOK_ALTER_SCHEMA  ||
                  RIS_stmts[i]->tree->tok == RIS_TOK_DROP_SCHEMA   ||
                  RIS_stmts[i]->tree->tok == RIS_TOK_OPEN_SCHEMA   ||
                  RIS_stmts[i]->tree->tok == RIS_TOK_CLOSE_SCHEMA
				)														&&
				RISdic_match_schname(RIS_stmts[i]->tree, schema->schname)
			  )
		  )
        {
			RIScli_clear(i,0,SYNC_MODE,0);

/*
** We need to do this everytime we call 'dic_clear_stmts' function, to make
** the application process know that we are clearing the statements prepared
** on the schema before it is a part of a superschema.
*/

			RIScco_add_to_clear_stmt_list(i);
       	}
    }

/*
** restoring ristatement and id.
*/
	RIS_stmt = RIS_stmts[save_id];
	RIS_current_stmt_id = save_id;
}

/******************************************************************************/

/*
** This function returns the number of schemas (primary plus secondary) 
** involved in a given superschema.
*/

extern int RISdic_get_subsch_num(
    rissuperschema * sschema)
{
	int sub_sch_num = 0;
	risschema *temp;

DIC_DBG(("RISdic_get_subsch_num sschema name = <%s>\n", sschema ? 
sschema->schname: "NONE"));

	for(temp=sschema->sub_schp; temp; temp=temp->sub_schp)
	{
		sub_sch_num++;
	}
	return(sub_sch_num);
}

/******************************************************************************/

/*
** This function returns 'true', if the passed schema name matches any of the
** schemas in the tree.
*/

static int RISdic_match_schname(
    ristree * tp,
    char * schname)
{

    int status;

DIC_DBG(("RISdic_match_schname tp tok = %s schname = <%s>\n",
	RIScom_get_token_name(tp->tok),STRING(schname)));

	if(tp->tok == RIS_TOK_CREATE_SCHEMA)
	{
		if(strcmp(tp->info.schema->schname, schname)==0)
		{
			return 1;
		}
	}
	if(tp->tok == RIS_TOK_ALTER_SCHEMA)
	{
		if(strcmp(tp->info.val, schname)==0)
		{
			return 1;
		}
	}
    if(tp->tok == RIS_TOK_AUTH_ID)
    {
        if(strcmp(tp->info.val, schname)==0)
        {
            return(1);
        }
    }
    if(tp->lhs)
    {
        if( (status = RISdic_match_schname(tp->lhs, schname))!=0 )
            return(1);
    }
    if(tp->rhs)
    {
        if( (status = RISdic_match_schname(tp->rhs, schname))!=0 )
            return(1);
    }

    return(0);
}

/******************************************************************************/

