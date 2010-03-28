/*
 * CI macros dealing with channels and their connected objects
 * M_cichannel.C
 */

#include "ci.h"
#include "OMminimum.h"
#include "OMprimitives.h"

extern struct instance_ci	*ci_data;
extern char	**ci_data_varvaltable;
extern char	*ci_data_info;
extern char			errmess[];

#argsused
CIget_channel_objects(func, response, response_data, pos)
struct ci_instruction	*func;
int			*response;
char			*response_data;
int			pos;
/*
 * Executes the macro ci$get_channel_objects()
 */
#define OSNUM		1
#define OBJID		2
#define CHANNAME	3
#define OSN_LIST	4
#define OBJ_LIST	5
#define COUNT		6
{
    OMuword		osn;		/* OS number */
    OM_S_OBJID		obj;		/* object id. */
    OM_S_CHANSELECT	chansel;	/* channel selector */
    OM_S_OBJECT_LINKAGE	list[100];	/* list of connected objects */
    int			sz;		/* dimension of the array "list" */
    int			*nb;		/* # of connected objects */
    int			rc;		/* return code */
    OM_p_OBJID		p_obj;		/* aimed to increase computationnal speed */
    OMuword		*p_osn;		/* idem */
    register		i;		/* mere index */
    int			iobj_list = func->paramlist[OBJ_LIST],
			iosn_list = func->paramlist[OSN_LIST];

/* Fetch and decode the arguments one by one */
    osn = ci_give_intvalue(func->paramlist[OSNUM]);
    if ( osn == -1 )
	osn = OM_Gw_current_OS;

    obj = o_cival(func->paramlist[OBJID]);

    chansel.type       = OM_e_name;
    chansel.u_sel.name = st_cival(func->paramlist[CHANNAME]);

    sz = ci_data->vardimtable[ iobj_list ];
    if ( ispointer( iobj_list ) )
	sz = 100; 
    if ( sz > 100 )
    {
	erreur("ci$get_channel_objects() curently limited to 100 objects");
	sz = 100;
    }

    nb = (int *)p_cival( func->paramlist[COUNT] );

/* Call the corresponding OM macro */
    rc = om$get_channel_objects(
	osnum =		osn,
	objid = 	obj,
	p_chanselect =	&chansel,
	list =		list,
	size = 		sz,
	count =		(OMuint *)nb );
    if ( COERROR(rc) )
    {
	i_cival( func->paramlist[0] ) = rc;
	return ISUCCESS;
    }
    else
	i_cival( func->paramlist[0] ) = 1;

/* Update the output parameters */
    if ( ispointer( iobj_list ) )
	p_obj = (OM_p_OBJID)p_cival( iobj_list );
    else	/* supposed to be an array */
	p_obj = (OM_p_OBJID)ci_data_varvaltable[ iobj_list ];
    for (i=0; i < *nb; i++)
	p_obj[i] = list[i].S_objid;

    if ( ispointer( iosn_list ) )
    {
	if ( (p_osn = (OMuword *)p_cival( iosn_list)) == NULL )
	    return ISUCCESS;
    }
    else	/* supposed to be an array */
	p_osn = (OMuword *)cival( iosn_list );
    for (i=0; i < *nb; i++)
	p_osn[i] = list[i].osnum;

    return ISUCCESS;
}
