/*
	I/VDS	Copy.
*/
#ifndef v_datamacros_include
#	define v_datamacros_include

#omdef	vd_$om_error( sts, msg = msg , jump = wrapup )
	{
		(*msg)	= EMS_E_OMerror ;
		goto jump ;
	}
#endomdef

#omdef	vd_$mem_fail( sts = sts, msg = msg , jump = wrapup )
	{
		(*msg)	= EMS_E_NoDynamicMemory ;
		(sts)	= OM_E_NODYNMEM ;
		goto jump ;
	}
#endomdef

#omdef	vd_$inv_arg( sts = sts, msg = msg , jump = wrapup )
	{
		(*msg)	= EMS_E_InvalidArg ;
		(sts)	= OM_E_INVARG ;
		goto jump ;
	}
#endomdef

#omdef	vd_$failure( sts = sts, msg = msg , jump = wrapup )
	{
		(*msg)	= MSFAIL ;
		(sts)	= OM_W_ABORT ;
		goto jump ;
	}
#endomdef

#omdef	vd_$error( sts = sts, msg = msg , stsval = OM_W_ABORT, msgval = MSFAIL,
		  jump = wrapup )
	{
		(*msg)	= (msgval) ;
		(sts)	= (stsval) ;
		goto jump ;
	}
#endomdef

#endif
