class implementation GRgnunit;

#include <stdio.h>
#include "DItypedef.h"
#include "DIprims.h"

#if 0

/* *****************************H H H H H******************************* */
/* Doc:		get_first_aliases

   Abstract: 	This method will return the first (short)  alias on every
		line of the uom_table.
		( eg. "distance" -> "in", "ft", "mm", "cm", "m", ... )

		The first alias on each line has been restricted to 10
		characters in order that it may be displayed on a form.
		The subsequent aliases on the line may be more descriptive.

   Notes:	Memory will be allocated of
			size = <# of names> * GRIO_MAX_ALIAS_SIZE
		into which the type names will be placed.  The variable names
		will be set to point to the allocated memory.  THE CALLING
		FUNCTION SHOULD FREE THIS MEMORY WHEN IT IS NO LONGER NEEDED.

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      09-26-91	kk	2.0.0	Creation
      07/14/92  scw     2.1.0   ansi conversion

   Return Status:
	OM_S_SUCCESS	-	Success
*/
/* *****************************H H H H H******************************* */

method	get_first_aliases (
	IGRlong	*msg;		/* o - Ret status: MSSUCC or MSFAIL		*/
	IGRchar	**names;	/* o - A list of first aliases on each line	*/
				/*	for the specified unit type		*/
				/*	(allocated by this method).		*/
				/*	access i-th name by			*/
				/*	names[i * GRIO_MAX_ALIAS_SIZE]		*/
	IGRlong	*num_names;	/* o - Number of names output			*/
)
{
IGRlong	oldindex, i, j;

	*msg = 0;

	*num_names = me^^GRgnunit.num_definition;

	if ( ! *num_names ) return(OM_S_SUCCESS);

	*names = (char *) malloc ( *num_names * GRIO_MAX_ALIAS_SIZE );
	if ( ! *names ) return(OM_E_NODYNMEM);

	for ( i = 0, oldindex = -1, j = 0;
		i < me^^GRunit.num_alias && j < *num_names; i++ )
	{
	   if ( me^^GRunit.alias_list[i].index != oldindex )
	   {
		oldindex = me^^GRunit.alias_list[i].index;
		strcpy( &((*names)[j++ * GRIO_MAX_ALIAS_SIZE]),
					me^^GRunit.alias_list[i].alias);
	   }
	}

	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}
/* ------------------------------------------------------------------------ */

/* Doc:		get_synonyms

   Abstract: 	This method returns the synonyms of a unit type.
		Synonyms are a list of names that appear on one line in the
		uom_table and possess the same relationship to the database
		units.
		( ex. "ft" -> "feet", "'", "foot", ...
			toDatabase = 12.0 assuming database is inches )

   Notes:	Memory will be allocated of
			size  =  <# of unit names> * GRIO_MAX_ALIAS_SIZE
		into which the type names will be placed.  The variable names
		will be set to point to the allocated memory.  The calling
		function should free this memory when it is no longer needed.

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      09-26-91	kk	2.0.0	Creation

   Return Status:
	OM_S_SUCCESS	-	Success
*/
/* *****************************H H H H H******************************* */

method get_synonyms (

	IGRlong	*msg;		/* o - Ret status: MSSUCC or MSFAIL		*/
	IGRchar	*UnitName;	/* i - Short unit name for which to find the	*/
				/*	available aliases			*/
	IGRchar	**names;	/* o - An array of unit names of that are aliases */
				/*	for the short unit name			*/
				/*	(allocated by this method).		*/
				/*     access i-th name by names[i * GRIO_MAX_ALIAS_SIZE] */
	IGRlong	*num_names;	/* o - Number of names output			*/
	IGRdouble *toDatabase;	/* o - Conversion factor. 			*/
				/*	unit * toDatabase = database units	*/
)
{
IGRlong	oldindex, i, j, found_index, unit_list_index;

	*msg = 0;
	*num_names = 0;

	for ( i = 0, oldindex = -1; i < me^^GRunit.num_alias; i++ )
	{
	   if ( me^^GRunit.alias_list[i].index != oldindex )
	   {
		oldindex = me^^GRunit.alias_list[i].index;

		if ( ! strcmp(me^^GRunit.alias_list[i].alias, UnitName))
		{
		   for ( found_index = j = i; j < me^^GRunit.num_alias; j++ )
			if ( me^^GRunit.alias_list[j].index == oldindex )
							(*num_names)++;
			else goto get_names;
		}
	   }
	}

get_names:

	if ( ! *num_names ) return(OM_S_SUCCESS);

	*names = (char *) malloc ( *num_names * GRIO_MAX_ALIAS_SIZE );
	if ( ! *names ) return(OM_E_NODYNMEM);

	for ( i = found_index, j = 0; j < *num_names; i++ )
	   strcpy( &((*names)[j++ * GRIO_MAX_ALIAS_SIZE]),
			me^^GRunit.alias_list[i].alias);

	unit_list_index = me^^GRunit.alias_list[found_index].index;

	*toDatabase = me^^GRgnunit.unit_list[unit_list_index].num_parent_units;

	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}
/* ------------------------------------------------------------------------ */

/* Doc:		get_database_units

   Abstract: 	This method will return the database units.
		( ex. "LENGTH" -> "inch" )

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      09-26-91	kk	2.0.0	Creation

   Return Status:
	OM_S_SUCCESS	-	Success
*/
/* *****************************H H H H H******************************* */

method get_database_units (

	IGRlong	*msg;		/* o - Ret status: MSSUCC or MSFAIL		*/
	IGRchar	name[];		/* o - The name of the database units		*/
)
{
	strcpy(name,me^^GRunit.alias_list[0].alias);

	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}
#endif

/* ------------------------------------------------------------------------ */

/* Doc:		debug

   Abstract: 	This method print the instance data to stderr.

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      09-26-91	kk	2.0.0	Creation

   Return Status:
	OM_S_SUCCESS	-	Success
*/
/* *****************************H H H H H******************************* */

method debug ()
{
IGRlong sts, i;
char name[1024];

        name[0] = 0;
        di$untranslate( objname = name, objid = my_id );
	fprintf(stderr,"\ndi name = <%s>\n",name);
	sts = om$send ( msg	= message Root.debug(),
			mode	= OM_e_wrt_message,
			targetid= my_id);

	fprintf(stderr,"\nInstance on GRunit:\n");
	fprintf(stderr,"\t num_alias = %d\n",me^^GRunit.num_alias);
	fprintf(stderr,"\t alias_list:\n");
	fprintf(stderr,"\t    entry  alias             index\n");

	for (i=0; i<me^^GRunit.num_alias; i++)
	   fprintf(stderr,"\t    %3d    %s  %d\n",i,me^^GRunit.alias_list[i].alias,
				  me^^GRunit.alias_list[i].index);
	fprintf(stderr,"\t num_defs_in = %d\n",me^^GRunit.num_defs_in);
	fprintf(stderr,"\t default_alias_in:\n");
	for (i=0; i<me^^GRunit.num_defs_in; i++)
	   fprintf(stderr,"\t    %s\n",me^^GRunit.default_alias_in[i]);

	fprintf(stderr,"\t num_defs_out = %d\n",me^^GRunit.num_defs_out);
	fprintf(stderr,"\t default_alias_out:\n");
	for (i=0; i<me^^GRunit.num_defs_out; i++)
	   fprintf(stderr,"\t    %s\n",me^^GRunit.default_alias_out[i]);

	fprintf(stderr,"\nInstance on GRgnunit:\n");
	fprintf(stderr,"\t num_definition = %d\n",me^^GRgnunit.num_definition);
	fprintf(stderr,"\t unit_list:\n");
	fprintf(stderr,"\t    entry  parent_index  num_parent_units  working_units\n");

	for (i=0; i<me^^GRgnunit.num_definition; i++)
	fprintf(stderr,"\t    %3d    %12d  %16g  %16g\n",i,me^^GRgnunit.unit_list[i].parent_index,
		me^^GRgnunit.unit_list[i].num_parent_units, me^^GRgnunit.unit_list[i].working_units);

	return(OM_S_SUCCESS);
}
end implementation GRgnunit;
