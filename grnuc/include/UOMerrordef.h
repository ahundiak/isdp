#ifndef UOMerrordef_included
#define UOMerrordef_included 1

#define UOM_FAC          238

#define UOM_WARN         0
#define UOM_SUCC         1
#define UOM_ERR          2
#define UOM_INFO         3
#define UOM_FATAL        4

#define UOM_err_setup( mess, sev ) \
  ( ( UOM_FAC % 0xfff ) * 65536 + ( mess % 0x1fff ) * 8 + ( sev % 0x7 ) )

#define UOM_ret_facility( ret )      ( ret / 0x10000 )
#define UOM_ret_mess_index( ret )    ( ( ret % 0x10000 ) / 8 )
#define UOM_ret_severity( ret )      ( ret % 8 )

#define UOM_S_SUCCESS                UOM_err_setup(  1, UOM_SUCC )
#define UOM_E_ALIAS_FOUND            UOM_err_setup(  2, UOM_ERR )
#define UOM_E_ALIAS_NOT_FOUND        UOM_err_setup(  3, UOM_ERR )
#define UOM_E_TYPE_FOUND             UOM_err_setup(  4, UOM_ERR )
#define UOM_E_TYPE_NOT_FOUND         UOM_err_setup(  5, UOM_ERR )
#define UOM_E_UNEXPECTED_NULL_PTR    UOM_err_setup(  6, UOM_ERR )
#define UOM_I_CREATED                UOM_err_setup(  7, UOM_INFO )
#define UOM_I_ALIAS_TRUNCATED        UOM_err_setup(  8, UOM_INFO )
#define UOM_I_TYPE_TRUNCATED         UOM_err_setup(  9, UOM_INFO )
#define UOM_E_ZERO_SCALE             UOM_err_setup( 10, UOM_ERR )
#define UOM_I_MAX_DEFS_EXCEEDED      UOM_err_setup( 11, UOM_INFO )
#define UOM_I_MIN_DEFS_EXCEEDED      UOM_err_setup( 12, UOM_INFO )
#define UOM_E_INVALID_ARG            UOM_err_setup( 13, UOM_ERR )

#endif          /* #ifndef UOMerrordef_included above */
