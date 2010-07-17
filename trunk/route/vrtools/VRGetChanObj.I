/* $Id: VRGetChanObj.I,v 1.2 2001/02/20 01:17:49 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRGetChanObj.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRGetChanObj.I,v $
 *      Revision 1.2  2001/02/20 01:17:49  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:13:11  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/10/20  15:38:52  pinnacle
# Replaced: vrtools/VRGetChanObj.I for:  by kddinov for route
#
# Revision 1.3  1997/09/18  20:14:30  pinnacle
# Replaced: vrtools/VRGetChanObj.I for:  by kddinov for route
#
# Revision 1.2  1997/09/12  23:44:12  pinnacle
# Replaced: vrtools/VRGetChanObj.I for:  by kddinov for route
#
# Revision 1.1  1997/09/11  17:37:04  pinnacle
# Created: vrtools/VRGetChanObj.I by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/
class implementation Root;

/*
#define vdsDEBUG        1
*/ 


#include <stdio.h>
#include <string.h> 

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h" 
#include "msdef.h"
#include "nddef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "VRutildef.h"
#include "VRattr_def.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "vrdbgmacros.h"
#include "VDmem.h"
#include "VRutildef.h"


extern GRclassid	OPP_VRNozzle_class_id;
extern GRclassid	OPP_ACpretend_class_id;

#define	VR_NotPresent	0
#define VR_Present	1

/************************************************************************
* vr$get_channel_objects
*------------------------------------------------------------------------
*
* I:  object            *(struct GRid)  - target object GRid
*
* I:  objid             GRobjid         - object.objid
* I:  osnum             GRspacenum      - object.osnum
*
* I:  chan_name         *(char)         - channel name tp search in.
* I:  p_channel         *(OM_S_CHANSELECT)- pointer to search channel
*
* I:  ancestry_class    *(char)         - selection filter classname
*					Ex: "ACpretend, ACpretendin"
* I:  ancestry_id       GRclassid       - selection filter classid
*
* I:  filter_class      *(char)         - selection filter classname
*					Ex: "ACpretend, ACpretendin"
* I:  filter_id         GRclassid       - selection filter classid
*
* I:  operation         int             - applied filter operation VRutildef.h
*                                         (VR_INCLUDE or VR_EXCLUDE)
*                                         include all objects by default.
*
* O:  count             *int            - number of Objects found
* O:  object_list      **(struct GRid)  - pointer to list of object IDs found
*------------------------------------------------------------------------
*
* RETURN
*
* 1	- OK
* 0	- Error
************************************************************************/
int VRget_channel_objects(  	struct GRid		*object,
                                GRobjid			objid_In,
                                GRspacenum		osnum_In,
				char			*chan_name,
				OM_S_CHANSELECT		*p_channel, 
                                char			*ancestry_class,
                                GRclassid		ancestry_id,
                                char			*filter_class,
                                GRclassid		filter_id,
                                int			operation,
                                int			*count,
                                struct GRid		**object_list)
{
  struct GRid		Target, *ObjList = NULL;

  OMuword		ClassId, 
			*AncestryId = NULL, 
			*FilterId   = NULL;

  OM_S_CHANSELECT     	Channel;
  OM_S_OBJECT_LINKAGE   *Items = NULL;

  IGRlong		sts = 1; 

  int			channel_count = 0, 
			NumAncestryId = 0,
			NumFilterId   = 0,
			flag,
			i,j;

  char			text[132], *p1 = NULL, *p2 = NULL;


SetProc(VRget_channel_objects); Begin

/*------------------
#  Initialize 
------------------*/
    if ( !count) { goto wrapup; }
    if ( !object && (objid_In == NULL_OBJID) ) { goto wrapup; } 
    if ( !p_channel && !chan_name )         { goto wrapup; }

    text[131] = '\0'; 
    *count = 0;

    if ( object) Target = *object;
    else {
	Target.objid = objid_In; 
	Target.osnum = osnum_In; 
    } 

    if ( p_channel )  Channel = *p_channel; 
    else { 
	Channel.type	   = OM_e_name;
	Channel.u_sel.name = chan_name; 
    }

    if ( ancestry_class ) {
	strncpy( text, ancestry_class, 131);
	p1 = text;
	if ( (p2 = strchr( p1, ',')) != NULL) *p2 ='\0';

        AncestryId    = _MALLOC( 1, OMuword);

        sts = om$get_classid ( classname  = p1,
                               p_classid  = &ClassId); 
	AncestryId[0] = ClassId;
        NumAncestryId = 1;

	while ( p2 != NULL) {
	      p1 = p2 + 1;
	      if ( (p2 = strchr( p1, ',')) != NULL) *p2 ='\0';

	      AncestryId = _REALLOC( AncestryId, NumAncestryId + 1, OMuword);

       	      sts = om$get_classid ( classname  = p1,
      	     	                     p_classid  = &ClassId);
	      AncestryId[ NumAncestryId ] = ClassId;
	      NumAncestryId++; 
	}
    }
    else if ( ancestry_id > 0 ) { 
	        AncestryId    = _MALLOC( 1, OMuword);
		AncestryId[0] = (OMuword) ancestry_id; 
	        NumAncestryId = 1;
    }


    if ( filter_class ) {
        strncpy( text, filter_class, 131);
        p1 = text;
        if ( (p2 = strchr( p1, ',')) != NULL) *p2 ='\0';

        FilterId    = _MALLOC( 1, OMuword);

        sts = om$get_classid ( classname  = p1,
                               p_classid  = &ClassId );
	FilterId[0] = ClassId;
        NumFilterId = 1;
 
        while ( p2 != NULL) {
              p1 = p2 + 1;
              if ( (p2 = strchr( p1, ',')) != NULL) *p2 ='\0';

              FilterId = _REALLOC( FilterId, NumFilterId + 1, OMuword);
 
              sts = om$get_classid ( classname  = p1,
                                     p_classid  = &ClassId); 
	      FilterId[ NumFilterId ] = ClassId; 
              NumFilterId++;
        }
    }
    else if ( filter_id > 0 ) {
                FilterId    = _MALLOC( 1, OMuword);
                FilterId[0] = (OMuword) filter_id;
                NumFilterId = 1;
    }

__DBGpr_int("Number of class    filters", NumFilterId);
__DBGpr_int("Number of ancestor filters", NumAncestryId);

/*------------------
# Get Objects on specified channel 
------------------*/
    sts = om$get_channel_count( osnum           = Target.osnum,
                                objid           = Target.objid,
                                p_chanselect    = &Channel,
                                count           = (OMuint *) &channel_count );

__DBGpr_obj("Target Object ID  ", Target); 
__DBGpr_str("Channel searched  ", Channel.u_sel.name);
__DBGpr_int("Number of objects ", channel_count);

    if ( channel_count <= 0 ) { goto wrapup; }

    Items = _MALLOC( channel_count, OM_S_OBJECT_LINKAGE);


    sts = om$get_channel_objects( objid       	= Target.objid,
				  osnum		= Target.osnum,
                                  p_chanselect 	= &Channel,
                                  list         	= Items,
				  size		= channel_count,
                                  count        	= (OMuint *) &channel_count );

    for (i=0; i < channel_count; i++) {
	if ( NumFilterId > 0 ) {
      	    sts = om$get_classid( objid    = (OM_S_OBJID) Items[i].S_objid,
      	       		          osnum    = (OMuword) Items[i].osnum, 
      			          p_classid= &ClassId);
 
            flag = VR_NotPresent;
            for ( j = 0; j < NumFilterId; j++) {
		if ( FilterId[j] == ClassId) { flag = VR_Present; break; }
            }
 
            if ( (flag == VR_Present) && ( operation == VR_EXCLUDE)) continue;
            if ( (flag != VR_Present) && ( operation == VR_INCLUDE)) continue;
	}


	if ( NumAncestryId > 0 )  {
      	    sts = om$get_classid( objid    = (OM_S_OBJID) Items[i].S_objid,
	    		          osnum    = (OMuword) Items[i].osnum,
                                  p_classid= &ClassId);
 
	    flag = VR_NotPresent;
	    for ( j = 0; j < NumAncestryId; j++) { 
		if ( om$is_ancestry_valid( subclassid  =(OMuword) ClassId,
			    	          superclassid =(OMuword) AncestryId[j])
		     		== OM_S_SUCCESS ) { 

		     flag = VR_Present;
		     break;
		}
	    }

	    if ( (flag == VR_Present) && ( operation == VR_EXCLUDE)) continue;
	    if ( (flag != VR_Present) && ( operation == VR_INCLUDE)) continue;
        }


	if ( *count == 0 )  ObjList = _MALLOC( 1, struct GRid); 
	else             ObjList = _REALLOC( ObjList, *count + 1, struct GRid);

	ObjList[ *count ].objid = (GRobjid)    Items[i].S_objid;
	ObjList[ *count ].osnum = (GRspacenum) Items[i].osnum; 

__DBGpr_obj("Object taken      ", ObjList[ *count ]); 

	*count += 1;
    }


wrapup:

    if ( Items)     { _FREE( Items );      Items      = NULL; } 
    if ( FilterId)  { _FREE( FilterId );   FilterId   = NULL; } 
    if ( AncestryId){ _FREE( AncestryId ); AncestryId = NULL; } 

    if ( object_list ) { *object_list = ObjList; } 
    else	       { _FREE (ObjList); ObjList = NULL; } 

End;
sts = 1;
return ( (int) sts);
}

end implementation Root;


