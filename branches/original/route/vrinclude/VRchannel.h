#ifndef vr_channel_include
#define vr_channel_include


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif


#if defined(__cplusplus)
extern "C" {
#endif

extern int VRget_channel_objects __(( 	struct GRid    	*object,
					GRobjid		objid,
					GRspacenum	osnum,
					char		*chan_name,
					OM_S_CHANSELECT *p_channel,
					char		*ancestry_class,
					GRclassid	ancestry_id,
					char		*filter_class,
					GRclassid	filter_id,
					int		operation,
					int		*count,
					struct GRid	**object_list )); 

#if defined(__cplusplus)
}
#endif

/************************************************************************
* vr$get_channel_objects
*------------------------------------------------------------------------
*
* I:  object		*(struct GRid)	- target object GRid
* 
* I:  objid		GRobjid		- object.objid 
* I:  osnum		GRspacenum	- object.osnum
*
* I:  chan_name		*(char)		- channel name tp search in.
* I:  p_channel		*(OM_S_CHANSELECT)- pointer to search channel
* 
* I:  ancestry_class	*(char)		- selection filter classname 
* I:  ancestry_id	GRclassid	- selection filter classid
*
* I:  filter_class	*(char)		- selection filter classname 
* I:  filter_id		GRclassid	- selection filter classid
*
* I:  operation		int		- applied filter operation VRutildef.h
*					  (VR_INCLUDE or VR_EXCLUDE) 
*					  include all objects by default. 
*
* O:  count		*int		- number of Objects found
* O:  object_list	**(struct GRid)	- list of object IDs found 
*------------------------------------------------------------------------
*
* RETURN
*
* 1     - OK
* 0     - Error
************************************************************************/
#omdef vr$get_channel_objects(  osnum 		= OM_Gw_current_OS,

				object 		= NULL	^
				objid		= NULL_OBJID,

				chan_name	= NULL  ^
				p_channel	= NULL,

				ancestry_class	= NULL ,
				ancestry_id	= 0, 

				filter_class	= NULL ,
				filter_id	= 0, 

				operation	= VR_INCLUDE,

				count,
				object_list	= NULL) 

VRget_channel_objects ( (object),       	(objid),        (osnum),
                        (chan_name),    	(p_channel), 
			(ancestry_class), 	(ancestry_id), 
                        (filter_class), 	(filter_id),    (operation),
                        (count),        	(object_list) )


#endomdef


#endif

