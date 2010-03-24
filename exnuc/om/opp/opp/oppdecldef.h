/*
-------------------------------------------------------------------------------

	Name:			oppdecldef.h
	Author:			Paul Hammond, Geoff Phipps, Kerry Kilbride
	Creation Date:		22-jan-1986
	Operating System(s):	Unix SYSV, v2
	Abstract:

	  This file is conceptually part of oppdecldef.h, but for reasons best
	known to cpp & opp it is necessary to separate the "#defines". This is
	because "#defines" are not inherited from your parents, whereas types
	are. Hence the ".c" files must always include these defines if they
	need to understand data types (which they would if they were using
	odo).

	First used in OM 3.0 .

	Revision History:

-------------------------------------------------------------------------------
*/

#ifndef	OM_D_DECLDEF
#define OM_D_DECLDEF	1


/*
	The order of these numbers is important, it allows for easy
	recognition of the category of the declarator.
*/
					/* basic types */
#define	OM_int			0
#define	OM_long_int		1
#define	OM_short_int		2
#define	OM_unsigned_int		3
#define	OM_unsigned_long_int	4
#define	OM_unsigned_short_int	5
#define	OM_float		6
#define	OM_double		7	
#define	OM_char			8	
#define	OM_basic		10
					/* non_terminal types */
#define	OM_id			11	/* reserved for future OPP things */
#define	OM_pointer		12
#define	OM_array		13
#define	OM_varray		14
#define	OM_bitfield		15
#define	OM_function		16
					/* composite types */
#define	OM_enum			20
#define	OM_struct		21
#define	OM_union		22
					/* used internally by Odin */
#define OM_Odin_symbols		30
#define	OM_object_id	 	31
#define	OM_string	 	32



/* macros used by Odin and OPP */

#define dcltr_is_basic(d)		((d)->type < OM_basic )
#define dcltr_is_non_terminal(d)	((d)->type < OM_enum  &&\
					 (d)->type > OM_basic )
#define dcltr_is_composite(d)		((d)->type >= OM_enum &&\
					 (d)->type < OM_Odin_symbols)

#endif
