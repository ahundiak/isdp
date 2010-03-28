class implementation ci ;

/*--PRIVATE-METHOD------------------------------------------------------------*/
method get_fcn_val( char *name ; void *p_val ; int size ) {

	int ifcn ;

  if( p_val != NULL && size != 0 ) {
	if( ( ifcn = CIgetvarno( name, me^^ci.data ) ) != -1 ) {
		memcpy( p_val, me^^ci.my_varvaltable[ifcn], size ) ;
	}
  }
  return OM_S_SUCCESS ;
	
} /* get_fcn_val */
/*----------------------------------------------------------------------------*/
end implementation  ci ;

