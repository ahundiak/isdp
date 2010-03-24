/*
-------------------------------------------------------------------------------

	Name:			OMMOSD.h
	Author:			Chuck Puckett
	Creation Date:		nov-15-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	 Master Obecjt Space Directory definitions

	Revision History:

cgp001	15-nov-1985	Add MOSD construct arglist.
-------------------------------------------------------------------------------
*/

#ifndef	OM_D_MOSD
#define	OM_D_MOSD	1
#ifndef	OM_D_MINIMUM
#include 	"OMminimum.h"
#endif

struct OM_sd_MOSD_entry
{
  OM_p_OSD		p_OS_descr;
};
typedef	struct	OM_sd_MOSD_entry	OM_S_MOSD_ENTRY;
typedef	struct	OM_sd_MOSD_entry	*OM_p_MOSD_ENTRY;


struct OM_sd_MOSD
{
  OM_S_OBJECTHDR	S_header;
  char			s_name[OM_K_MAXOSNAME_LEN];	/* name of this MOSD
							   object */
  uword			w_number_entries;
  OM_p_MOSD_ENTRY	A_entries;
};
typedef	struct	OM_sd_MOSD	OM_S_MOSD;
typedef	struct	OM_sd_MOSD	*OM_p_MOSD;

struct OM_sd_MOSD_construct_args
{
  char			*s_name;
  OMuint		i_init_count;
};
typedef	struct	OM_sd_MOSD_construct_args 	OM_S_MOSD_CONSTRUCT_ARGS;
typedef	struct	OM_sd_MOSD_construct_args	*OM_p_MOSD_CONSTRUCT_ARGS;

#endif
 
