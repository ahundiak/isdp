/* ###################   APOGEE COMPILED   ################## */
class implementation Rootmsg;

/*
HISTORY:

Creation:  ??   : Long ago.
08/21/92:  NP   : Modified for ANSI compliance. In the "som_construct_object"
		  function, "p_tag" had not been typecast.
09/13/96:  SCW  : Removed references to OMprimindex.h

*/


#include "EMS.h"

extern OM_p_MESSAGE OM_Gp_NULL_MESSAGE;

method construct_obj( char  		*classname;
		  OMuword		classid;
		  OM_S_OBJID		objid;
		  OM_S_OBJECTHDR	*object;
		  OMuword		obj_osnum;
		  OMuword		osnum;
		  char			*osname;
		  OM_S_NEIGHBOR		neighbor;
		  OM_p_MESSAGE		msg;
		  OM_S_OBJID		*p_objid;
		  char			*p_tag;
	)

{
#define	SUCCESS(x)	((x) & 1)
#define	WARNING(x)	(((x) & 7) == 0)

long	stsc,sts;

	stsc = som_construct_object(classname,classid, objid,
                            object, obj_osnum, osnum,
                            osname, p_objid, msg, 
                            neighbor, (OMuint *)p_tag);
	if ( ! SUCCESS(stsc) && ! WARNING(stsc) ) return(stsc);

/*
 This will cause the sender_id to be the object that is doing the
 construction, instead of the object that has been constructed.
 */
	sts = om$send(msg=msg,targetid=*p_objid);
	if ( ! SUCCESS(sts) && ! WARNING(sts) ) return(sts);

	return(stsc);
}
end implementation Rootmsg;
