/*
	I/STRUCT
*/
class implementation VSxtrBeam ;

/*----------------------------------------------------------------------------*/
method VSgetExtendedEnd( long *msg ; int *p_extEnd ) {

	*p_extEnd	= me->extEnd ;
	*msg		= MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VSgetExtendedEnd */
/*----------------------------------------------------------------------------*/

end implementation VSxtrBeam ;

