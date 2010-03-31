#ifndef OMrootmsg
#define OMrootmsg

typedef struct {
	OM_S_CHANSELECT	*chansel;
	OM_E_WRT_FLAG	mode;
	int		from_ndx;
	int		to_ndx;
	char		*user_arg;
} OM_S_PATH_LIST;

#define	$mode	mode
#define	$user_arg	user_arg
#omdef om$fill_path(p_chanselect,
		    level,
		    path,
		    mode = OM_e_wrt_object,
		    from = NULL,
		    to = OM_K_MAXINT,
		    user_arg = (char *) 0
		    )

	path[level].chansel = p_chanselect;
	path[level].$mode = mode;
	path[level].from_ndx = from;
	path[level].to_ndx = to;
	path[level].$user_arg = user_arg;

#endomdef

#omdef om$construct_msg ( classname=NULL ^
                      classid=OM_K_NOTUSING_CLASSID ^
                      objid=NULL_OBJID ^
                      object=NULL,
                      obj_osnum=OM_Gw_current_OS,
                      osnum=OM_Gw_current_OS,
                      osname=NULL,
                      p_objid,
                      msg=OM_Gp_NULL_MESSAGE,
                      neighbor=OM_GS_NULL_NEIGHBOR,
                      p_tag = NULL
                      )

  message Rootmsg.construct_obj( (classname), (classid), (objid),
                                          (object), (obj_osnum), (osnum),
                                          (osname), (neighbor), (msg),
                                          (p_objid),(p_tag) )
#endomdef

#omdef om$send_msg ( mode=OM_e_wrt_object,
                 msg,
                 senderid=my_id,
                 targetid ^ 
                 p_chanselect,
                 targetos=OM_Gw_current_OS,
                 from=NULL,
                 to=OM_K_MAXINT )

#if om$specified (targetid)
#if om$specified (targetos) && !om$equal(targetos,OM_Gw_current_OS)

	message Rootmsg.send_obj( (int) 1, (mode), (msg), (senderid), 
                (targetid), (targetos), (NULL), (from), (to) )

#else
	message Rootmsg.send_obj( (int) 2, (mode), (msg), (senderid), 
                (targetid), (targetos), (NULL), (from), (to) )
 
#endif
#else
	message Rootmsg.send_obj( (int) 3, (mode), (msg), (senderid), 
                (targetid), (targetos), (p_chanselect), (from), (to) )

#endif
#endomdef

#endif
