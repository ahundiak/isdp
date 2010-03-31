/*
 * AE error codes.
 * File dependency : "OMerrordef.h"
 */

#eofifdef AEerrordef_include 
#define AEerrordef_include

#define AE_FACILITY_CODE	192
#define AEerrno( n, sev ) \
		((((AE_FACILITY_CODE)&0xfff)<<16)|(((n)&0x1fff)<<3)|((sev)&7))

#define AEfacility( stat )	( ( (stat) >> 16  ) & 0xfff	)
#define AEmess_index( stat )	( ( (stat) >> 3  )  & 0x1fff	)
#define AEseverity( stat )	(   (stat)          & 7		)

#	define AE_S_SUCCESS		AEerrno(   1, SUCC )
#	define AE_E_OVERFLOW		AEerrno(   2, ERRO )
#	define AE_E_INVCHAR		AEerrno(   3, ERRO )
#	define AE_E_CANT_OPEN		AEerrno(   4, ERRO )
#	define AE_E_UNK_ERRCODE		AEerrno(   5, ERRO )
#	define AE_E_NOT_AE_STS		AEerrno(   6, ERRO )
#	define AE_E_OUT_OF_RANGE	AEerrno(   7, ERRO )
#	define AE_E_UNKNOWN_DATA_TYPE	AEerrno(   8, ERRO )
#	define AE_F_CANT_MALLOC		AEerrno(   9, SEVE )
#	define AE_E_BAD_ARG_COUNT	AEerrno(  10, ERRO )
#	define AE_E_BAD_ARGUMENT	AEerrno(  11, ERRO )
#	define AE_E_ARG_EXISTS		AEerrno(  12, ERRO )
#	define AE_E_NOT_LVALUE		AEerrno(  13, ERRO )
#	define AE_F_HOPELESS		AEerrno(  14, ERRO )
#	define AE_I_ZERO_DIVIDE		AEerrno(  15, INFO )
#	define AE_E_SYNTAX_ERROR	AEerrno(  16, ERRO )
#	define AE_E_REC_NOT_FOUND	AEerrno(  17, ERRO )
#	define AE_E_BAD_OPERATOR	AEerrno(  18, ERRO )
#	define AE_E_BAD_OPERAND		AEerrno(  19, ERRO )
#	define AE_I_CREATED		AEerrno(  20, INFO )
#	define AE_I_MODIFIED		AEerrno(  21, INFO )
#	define AE_I_DELETED		AEerrno(  22, INFO )
#	define AE_W_DATA_LOST		AEerrno(  23, WARN )
#	define AE_E_SUBCLASS_FUNCTION	AEerrno(  24, ERRO )
#	define AE_I_REBIND_FAILED	AEerrno(  25, INFO )
#	define AE_E_DIM_MISMATCH	AEerrno(  26, ERRO )
#	define AE_E_UNIT_MISMATCH	AEerrno(  27, ERRO )
#	define AE_I_IN_CONTEXT		AEerrno(  28, INFO )
#	define AE_I_OUT_CONTEXT		AEerrno(  29, INFO )

/* -- Index of last message.
   -- */
#	define AE_K_LAST_MSG_INDEX 29
