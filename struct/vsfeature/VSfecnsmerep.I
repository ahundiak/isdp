/*
	I/STRUCT
*/
class implementation VSfeature ;

/*----------------------------------------------------------------------------*/
method VSputConsumedRep( VSdspRep rep ) {
	me->ConsumedRep = rep ;
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
method VSgetConsumedRep( VSdspRep *rep ) {
	*rep = me->ConsumedRep ;
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

