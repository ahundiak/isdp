#ifndef aperrmac_included
#define aperrmac_included

/****************************************************************************

   Doc: APerrmac

   Abstract: Error macros for I/FEM

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      02-21-91	msl		Creation
      01-18-92	kk	2.0.0	Added AP_ERR_UM_RETURN
				Forgives stat == OM_W_UNKNOWN_MSG

 ****************************************************************************/

#include "OMerrordef.h"

#define AP_ERR_HNDLR(desc, stat, msg, verbose, label) \
	if ( !(stat&1) || !msg || verbose ) \
		if( !AP_err_hndlr(desc,stat,msg,verbose,__FILE__,__LINE__ ) ) \
			goto label;

#define AP_ERR_RETURN(desc, stat, msg, verbose) \
	if ( !(stat&1) || !msg || verbose ) \
		if( !AP_err_hndlr(desc,stat,msg,verbose,__FILE__,__LINE__ ) ) \
			return(stat);

#define AP_ERR_UM_RETURN(desc, stat, msg, verbose) \
	if ( (!(stat&1) && stat != OM_W_UNKNOWN_MSG) || !msg || verbose ) \
		if( !AP_err_um_hndlr(desc,stat,msg,verbose,__FILE__,__LINE__ ) ) \
			return(stat);

#define AP_ERR_CHECK(desc, stat, err_cond, verbose, label, p_rc, errdef) \
	if ( !(stat&1) || (err_cond) || verbose ) \
		if( !AP_err_check(desc,stat,(err_cond),verbose,p_rc,errdef,__FILE__,__LINE__ ) ) \
			goto label;
#endif
