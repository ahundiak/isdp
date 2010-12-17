/*
**  NAME:                           DICundecl_ss.c
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
#include "rismem.h"
#include "riscom.h"
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
#define dicundss_c
#include "dicundss.prt"
#include "cliclear.prt"
#include "ccoclstm.prt"
#include "comdebug.prt"
#include "comfree.prt"
#include "comjmp.prt"
#include "comstcmi.prt"

/******************************************************************************/

extern void RISdic_undecl_superschema(
	char *ssch_name)
{
	rissuperschema *undecl_sschema=0;
	rissuperschema *ptr = 0;
	rissuperschema *pptr;

DIC_DBG(("RISdic_undecl_superschema ssch_name = <%s>\n", STRING(ssch_name)));

/*
** checking if the superschema is declared, before we undeclare
*/
	if(!(undecl_sschema = RISdic_find_supersch(ssch_name)))
	{
		LONGJMP(RIS_E_SUPERSCHEMA_NOT_DECLARED);
	}

/*
** clearing all the statements involving the primary schema, and resetting
** the superschema flag only and not super_schp pointer
*/
	RISdic_supersch_clear_stmts(undecl_sschema);	

/*
** removing the superschema from the superschema list
*/
	for(pptr=0, ptr=RIS_super_schema; ptr; ptr=ptr->next)
	{
		if (ptr == undecl_sschema)
		{
			if(!pptr)
			{
				RIS_super_schema = ptr->next;
			}
			else
			{
				pptr->next = ptr->next;
			}
			break;
		}
		else
		{
			pptr = ptr;
		}
	}

/*
** RIS_default to be reset if this superschema was default
*/
    if( RIS_default && RIS_default->super_schp == undecl_sschema )
    {
        RIS_default = 0;
    }

/*
** reset all involved schemas' super_schp and free the superschema structure
*/

	RISdic_reset_n_free_supersch_stuff(undecl_sschema);
}

/*e****************************************************************************/

/*
** Goes through the superschema list and returns the schema structure if the
** passed superschema name is found, else it returns null.
*/

extern rissuperschema *RISdic_find_supersch(
	char *ssch_name)
{

	rissuperschema *sschema;

DIC_DBG(("RISdic_find_supersch ssch_name <%s>\n", STRING(ssch_name)));

	if(ssch_name)
	{
		for(sschema=RIS_super_schema; sschema; sschema=sschema->next)
		{
			if(RIScom_strcmp_ic(sschema->schname, ssch_name)==0)
			{
				return(sschema);
			}
		}
	}
	return(NULL);
}

/******************************************************************************/

/*
** frees the superschema structure.
*/

extern void RISdic_free_supersch_str(
	rissuperschema *sschema)
{

DIC_DBG(("RISdic_free_supersch_str sschema 0x%x\n", sschema));

	RIS_ssmem[sschema->ssid] = 0;
	FREESS(sschema->ssid);
}

/******************************************************************************/

extern void RISdic_reset_n_free_supersch_stuff(
	rissuperschema *sschema)
{

DIC_DBG(("RISdic_reset_n_free_supersch_stuff sschema 0x%x\n", sschema));

    RISdic_reset_subschemas(sschema);
	RISdic_free_supersch_str(sschema);
}

/******************************************************************************/

/*
** Given an error in the declare statement, this function resets the 
** superschema flag of the involved schemas for the superschema.
*/

static void RISdic_reset_subschemas(
    rissuperschema * sschema)
{
	risschema * temp;
	risschema * next;

DIC_DBG(("RISdic_reset_subschemas(sschema: 0x%x\n", sschema));

	for(temp=sschema->sub_schp; temp;)
	{
		next = temp->sub_schp;
		temp->superschema_flag = REGULAR_SCHEMA;
		temp->super_schp = 0;
		temp->sub_schp = 0;
		temp = next;
	}
}

/******************************************************************************/

/*
** We clear all active statements of a superschema when we undeclare.
*/

extern void RISdic_supersch_clear_stmts(
    rissuperschema * sschema)
{
    int i;
	short save_id;
	risstmt *stmt;
	risstmt *save_next;

DIC_DBG(("RISdic_supersch_clear_stmts schema = <%s>\n", 
			STRING(sschema->schname)));

/*
** In the CLIclear we manipulate statement id and risstatement structure.
** So we need to save the original values and restore 'em when we are done
** with the clear operation
*/
    save_id = RIS_current_stmt_id;

	for (i=0; i<RIS_parms.max_user_stmts; i++)
	{
		if(RIS_stmts[i] &&
		   RIS_stmts[i]->sql &&
		   RIS_stmts[i]->sql->schema &&
		   RIS_stmts[i]->sql->schema->super_schp ==  sschema)
		{
		for( stmt = RIS_stmts[i]; stmt; stmt = save_next )
		{
			save_next = stmt->next;

/*
** Make it regular schema before stmts are cleared on it
*/
        	stmt->sql->schema->superschema_flag = REGULAR_SCHEMA;
        	RIScli_clear(stmt->stmt_id,0,SYNC_MODE,1);
       	}

/*
** We need to do this everytime we call 'dic_supersch_clear_stmts' function,
** to make the application process know that we are clearing the statements
** prepared on the superschema.
*/

            RIScco_add_to_clear_stmt_list((short)i);
        }
    }

/*
** restoring ristatement and id.
*/
    RIS_stmt = RIS_stmts[save_id];
    RIS_current_stmt_id = save_id;

}

/******************************************************************************/

