/* JAJ:08-10-88 */

#ifndef COB_pf_nod_dot_h
#define COB_pf_nod_dot_h

#include "COBlist_tool.h"

struct COB_pf_nod
{
  char		  name[256];
  char		* form_ptr;	/* I/Forms Forms Ptr	*/
  OM_S_OBJID	  cmd_oid;	/* oid of cmd currently "owning" form */

  _COB_list ( struct COB_pf_nod, list );
} ;

#endif
