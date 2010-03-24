/*
---------------------------------------------------------------------------
	Name:			OMintercept.h
	Author:			Grace Oliver
	Creation Date:		April 13, 1987
	Operating System(s):	Unix SYSV, V3
	Abstract:

		Intercept (X Object's Messages and Route to Y Object)
	        Definitions

	Revision History:
---------------------------------------------------------------------------
*/

#ifndef OM_D_INTERCEPT
#define OM_D_INTERCEPT	1

#ifndef OM_D_MINIMUM
#include	"OMminimum.h"
#endif

#define	OM_K_MSGINTR_HSHTBL_SIZE	199	/* mod 199 */
#define	OM_K_MSGINTR_HSHTBL_INITSIZE	299	/* size + 1 ext size */
#define	OM_K_MSGINTR_HSHTBL_EXTSIZE	100	/* overflow region size */

#define	OM_MSGINTR_HSHFUNC(key, index)	\
{					\
  index = key % OM_K_MSGINTR_HSHTBL_SIZE; \
}

/* Object being intercepted and Object to receive instead */

struct OM_sd_msg_intercept
{
  int			next;	/* hash table is contiguous, so next     */
				/* is array index. 0 means no next since */
				/* next must be in overflow area         */
  OM_S_OBJID		intercept_objid;
  OMuword		to_osnum;
  OM_S_OBJID		to_objid;
};
typedef	struct OM_sd_msg_intercept	OM_S_MSG_INTRCPT;
typedef	struct OM_sd_msg_intercept	*OM_p_MSG_INTRCPT;

struct OM_sd_intercept_hash_table
{
  OM_p_MSG_INTRCPT	hash_table;
  int			cur_size;
  int			num_entries;
  int			next_free;
};
typedef	struct OM_sd_intercept_hash_table OM_S_INTRCPT_HT;
typedef	struct OM_sd_intercept_hash_table *OM_p_INTRCPT_HT;

#endif
