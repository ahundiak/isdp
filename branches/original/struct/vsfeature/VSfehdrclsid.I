/*
	I/STRUCT
*/
class implementation VSfeature ;

extern OMuword	OPP_VSimgFeature_class_id ;
/*----------------------------------------------------------------------------*/
method NDgetHeaderClassid( OMuword *headerClassid ) {

	*headerClassid = OPP_VSimgFeature_class_id ;

	return OM_S_SUCCESS ;

} /* method NDgetHeaderClassid */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

