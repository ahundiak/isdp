/*
	I/STRUCT
*/
#ifndef vsdatamacros_include
#	define vsdatamacros_include

#omdef	vs$om_error( sts, msg = msg , jump = wrapup )
	{
		(*msg)	= EMS_E_OMerror ;
		goto jump ;
	}
#endomdef

#omdef	vs$mem_fail( sts = sts, msg = msg , jump = wrapup )
	{
		(*msg)	= EMS_E_NoDynamicMemory ;
		(sts)	= OM_E_NODYNMEM ;
		goto jump ;
	}
#endomdef

#omdef	vs$inv_arg( sts = sts, msg = msg , jump = wrapup )
	{
		(*msg)	= EMS_E_InvalidArg ;
		(sts)	= OM_E_INVARG ;
		goto jump ;
	}
#endomdef

#omdef	vs$failure( sts = sts, msg = msg , jump = wrapup )
	{
		(*msg)	= MSFAIL ;
		(sts)	= OM_W_ABORT ;
		goto jump ;
	}
#endomdef

#omdef	vs$error( sts = sts, msg = msg , stsval = OM_W_ABORT, msgval = MSFAIL,
		  jump = wrapup )
	{
		(*msg)	= (msgval) ;
		(sts)	= (stsval) ;
		goto jump ;
	}
#endomdef

/*+M
Macro vs$getDataMgr

Abstract
	Retrieves the shared data manager for an object space or creates it
	if it does not exist.
Arguments
	IN	OMuword		osnum	Object space where manager is wanted.
	OUT	OM_S_OBJID	p_objid	Id of manager.
Notes
	Returns an OM error code (OM_S_SUCCESS if OK).
-M*/

#omdef	vs$getDataMgr( osnum, p_objid )
		VSgetDataMgr( (osnum), (p_objid) )
#endomdef

/*+M
Macro vs$getSharedData

Abstract
	Given a list of data, returns a collection of shared data, being either
	new and formatted or already existing and containing the same data
	as those input.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		count		Of data for collection.
	IN	OMuword		osnum		OS where collection is to be
						created/found.
	IN	VSdataDesc	data[]		List of data for collection.
	OUT	OM_S_OBJID	*p_objid	The created/found collection.
Note
	The returned collection lives in the same object space as the object
	target of this message.
	The returned collection should never be deleted. The system handles
	the destruction of no longer needed collections, i.e. collections
	which have no children any longer.
-M*/
#omdef	vs$getSharedData( msg, osnum = OM_Gw_current_os, count, data, p_objid )
		VSgetSharedData( (msg), (osnum), (count), (data), (p_objid) )
#endomdef

#endif
