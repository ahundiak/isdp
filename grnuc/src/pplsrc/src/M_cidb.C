/*
 *	 Etienne Beeker
 *
 *	functions managing the DataBAse calls
 *	trough om macros calls
 *
 *	functions defined here call functions defined in cidb.c
 *	creation : Feb 29th, 88
 */

#include "ci.h"
#include "OMminimum.h"
#include "OMprimitives.h"

extern	char errmess[];
extern	OM_S_OBJID ci_id;	/* id du ci en train de s'executer */
extern	struct instance_ci *ci_data;
extern char	**ci_data_varvaltable;
extern char	*ci_data_info;

ciDBinit(instr)
struct ci_instruction *instr;
/*
 * initialization of the DB
 * - eventually creates and opens named pipes for DB i/o
 * - call isql with the good DB
 */
{
	i_cival(instr->paramlist[0]) = DBinit( st_cival(instr->paramlist[1]) );
	return 1;
}

ciDBopen(instr)
struct ci_instruction *instr;
/*
 * opens a DB
 */
{
	i_cival(instr->paramlist[0]) = DBopen( st_cival(instr->paramlist[1]) );
	return 1;
}

ciDBclose(instr)
struct ci_instruction *instr;
/*
 * closes the DB
 */
{
	i_cival(instr->paramlist[0]) = DBclose();
	return 1;
}

ciDBcmd(instr)
struct ci_instruction *instr;
/*
 * sends a SQL command to the DB
 * result is written in a special window or in a file
 */
{
	i_cival(instr->paramlist[0]) =
		DBcmd(	st_cival(instr->paramlist[1]),
			st_cival(instr->paramlist[2]) );
	return 1;
}


ciDBsearch(instr)
struct ci_instruction *instr;
/*
 * get the objects satisfying a certain criteria
 */
{
	i_cival(instr->paramlist[0]) = 
		DBsearch(st_cival(instr->paramlist[1]),
			st_cival(instr->paramlist[2]),
			( ispointer(instr->paramlist[3]) ?
				p_cival(instr->paramlist[3]) :
				cival(instr->paramlist[3]) ),
			( ispointer(instr->paramlist[4]) ?
				p_cival(instr->paramlist[4]) :
				cival(instr->paramlist[4]) ),
			p_cival(instr->paramlist[5]) );
	return 1;
}


ciDBread(instr)
struct ci_instruction *instr;
/*
 * reads data attributes from an object
 * goes through a temp table
 */
{
	int i;
	char value[256];
	double atof();

	if ( ! DBread( st_cival(instr->paramlist[1]),
			p_cival(instr->paramlist[2]),
			p_cival(instr->paramlist[3]),
			st_cival(instr->paramlist[4]),
			value ))
		return 1;

	i = instr->paramlist[5];
	if( isstring(i) )
		strcpy( st_cival(i), value );
	else if( ci_data->vartypetable[i] == (CI_INT | PTR) )
		*((int *)p_cival(i)) = atoi(value);
	else if( ci_data->vartypetable[i] == (CI_SHORT | PTR) )
		*((short *)p_cival(i)) = atoi(value);
	else if( ci_data->vartypetable[i] == (CI_DOUBLE | PTR) )
		*((double *)p_cival(i)) = atof(value);

	i_cival(instr->paramlist[0]) = 1;
	return 1;
}

ciDBwrite(instr)
struct ci_instruction *instr;
/*
 * writes data attributes from an object
 */
{
	int i;
	char value[256];

	i = instr->paramlist[5];
	if( isstring(i) )
		strcpy(  value, st_cival(i));
	else if( ci_data->vartypetable[i] == (CI_INT | PTR) )
		 sprintf(value, "%d", *((int *)p_cival(i)));
	else if( ci_data->vartypetable[i] == (CI_SHORT | PTR) )
		 sprintf(value, "%d", *((short *)p_cival(i)));
	else if( ci_data->vartypetable[i] == (CI_DOUBLE | PTR) )
		 sprintf(value, "%lf", *((double *)p_cival(i)));

	i_cival(instr->paramlist[0]) =
		DBwrite( st_cival(instr->paramlist[1]),
			p_cival(instr->paramlist[2]),
			p_cival(instr->paramlist[3]),
			st_cival(instr->paramlist[4]),
			value );
	return 1;
}

ciDBflush(instr)
struct ci_instruction *instr;
/*
 * to optimimized DBwrite by keeping data into a temp table
 * not yet implemented
 */
{
	i_cival(instr->paramlist[0]) = 
		DBflush(st_cival(instr->paramlist[1]));
	return 1;
}

ciDBselect(instr)
struct ci_instruction *instr;
/*
 */
{
	i_cival(instr->paramlist[0]) =
		DBselect( st_cival(instr->paramlist[1]),
			i_cival(instr->paramlist[2]),
			s_cival(instr->paramlist[3]) );
	return 1;
}


ciDBattach(instr)
struct ci_instruction *instr;
/*
 */
{
	i_cival(instr->paramlist[0]) =
		DBattach( st_cival(instr->paramlist[1]),
			( ispointer(instr->paramlist[2]) ?
				p_cival(instr->paramlist[2]) :
				cival(instr->paramlist[2]) ),
			( ispointer(instr->paramlist[3]) ?
				p_cival(instr->paramlist[3]) :
				cival(instr->paramlist[3]) ),
			i_cival(instr->paramlist[4]) );
	return 1;
}


ciDBdetach(instr)
struct ci_instruction *instr;
/*
 */
{
	i_cival(instr->paramlist[0]) =
		DBdetach( st_cival(instr->paramlist[1]),
			( ispointer(instr->paramlist[2]) ?
				p_cival(instr->paramlist[2]) :
				cival(instr->paramlist[2]) ),
			( ispointer(instr->paramlist[3]) ?
				p_cival(instr->paramlist[3]) :
				cival(instr->paramlist[3]) ),
			i_cival(instr->paramlist[4]) );
	return 1;
}
