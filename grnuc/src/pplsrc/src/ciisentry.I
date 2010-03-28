class implementation ci ;

#include "cierrordef.h"
/*--PUBLIC-METHOD-------------------------------------------------------------*/
method is_entry_point( int *rc ; char *entry ) {

	int ifcn ;

  if( !( me^^super_cmd.state & CI_LOADED_WITH_PPL ) )
	*rc = CI_E_OBJCT_EMPTY	;
  else if( ( ifcn = CIgetinstrno( 1, me^^ci.data, entry ) ) == -1 )
	*rc = CI_W_NO_SUCH_FUN	;
  else	*rc = CI_S_SUCCESS	;

  return OM_S_SUCCESS ;
	
} /* is_entry_point */
/*----------------------------------------------------------------------------*/
end implementation  ci ;

