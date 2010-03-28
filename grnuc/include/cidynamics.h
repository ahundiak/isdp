/* -- This macro invokes the given PPL dynamics function in the specified PPL
      file. This macros works the same way as "dp$dynamics".
      See  I/DRAFT DEVELOPMENT PLATFORM PROGRAMMER'S REFERENCE MANUAL - MACROS,
      at the entry "dp$dynamics" for details.

      File dependency : "ciminimum.h"
   -- */

#ifndef CIDYNAMICS_INCLUDE
#	define CIDYNAMICS_INCLUDE


/* --	Macro ci$dynamics

	ARGUMENTS :
	char 	*dyn_file	: name of PPL file containing dynamics function.
	char	*dyn_fun	: name of dynamic function in above file.
	char	*information	: pointer to information to be passed to the
				  dynamics function
	int	flags		: flags used in the dynamics function, see
				  documentation on "dp$dynamics"
	int	*stat		: completion code

	Values for `flags' are defined in "dpdef.h"
	Values for `*stat' are defined in "cierrordef.h"

	"ci$dynamics" returns TRUE if everything went file else FALSE ( and
	in this latter case `*stat' may be examined ).

	SAMPLE USAGE :

	1) ci$dynamics(	dyn_file	= "dynhandler.u",
			dyn_fun		= "dynamics"	,
			stat		= &rc		) ;

	2) if( !ci$dynamics(	dyn_file	= "$MYSRC/dynfile.u",
				dyn_fun		= "dyn_fun",
				information	= &my_info,
				stat		= &rc,
				flags		=   DP_IGN_INV_PNT
						  | DP_CUR_NOT_CHG ) ) {
		write( "Dynamics failed:\n" ) ;
		ci$report_error( status = rc ) ;
	   }

	NOTES : 
		- `dyn_file' may be the same file as the one from which
		  "ci$dynamics" is invoked.
		- `dyn_fun' must have the 13 arguments with the sames types
		  as those described in the documentation for "dp$dynamics"
		  for the dynamics function.
  -- */
#	omdef ci$dynamics(	dyn_file			,
				dyn_fun				,
				information	= CI_NULL	,
				flags		= 0		,
				stat )
	CIdpdynamics( (dyn_file), (dyn_fun), (information), (flags), (stat) )
#	endomdef

#endif
