/*
	I/STRUCT
*/
class implementation VSsomeObjcVw ;

/*----------------------------------------------------------------------------*/
method getObjectToDisplay( struct GRid *theObjToDisplay ) {

	long			sts = OM_S_SUCCESS ;
	OM_S_CHANSELECT		toObjToDisp ;
	OM_S_OBJECT_LINKAGE	theObject ;
	OMuint			count ;

	toObjToDisp.type	= OM_e_addr ;
	toObjToDisp.u_sel.addr	= &me->toObjToDisplay ;

	sts = om$get_channel_objects(	p_chanselect	= &toObjToDisp,
					objid		= my_id,
					list		= &theObject,
					size		= 1,
					count		= &count ) ;

	if( ( sts & 1 ) && count ) {
		theObjToDisplay->objid = theObject.S_objid ;
		theObjToDisplay->osnum = theObject.osnum ;
	} else {
		theObjToDisplay->objid = NULL_OBJID ;
		sts = OM_S_SUCCESS ;
	}

	return sts ;

} /* method getObjectToDisplay */
/*----------------------------------------------------------------------------*/

end implementation VSsomeObjcVw ;
