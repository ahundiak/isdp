/*
 * BG error codes.
 * File dependency : "OMerrordef.h"
 */

#eofifdef BGerrordef_include 
#define BGerrordef_include

#define BG_FACILITY_CODE	159
#define BGerrno( n, sev ) \
		((((BG_FACILITY_CODE)&0xfff)<<16)|(((n)&0x1fff)<<3)|((sev)&7))

#define BGfacility( stat )	( ( (stat) >> 16  ) & 0xfff	)
#define BGmess_index( stat )	( ( (stat) >> 3  )  & 0x1fff	)
#define BGseverity( stat )	(   (stat)          & 7		)

#	define GM_IOR_STOP		0x1000
#	define GM_IAND_STOP		0x0800
  
#	define BG_I_OR_STOP		BGerrno(  GM_IOR_STOP , INFO )
#	define BG_I_AND_STOP		BGerrno(  GM_IAND_STOP, INFO )
#	define BG_S_SUCCESS		BGerrno(  1, SUCC )
#	define BG_I_NEG_RESPONSE	BGerrno(  2, INFO )
#	define BG_E_STOP_PROCESS	BGerrno(  3, ERRO )
#	define BG_F_BAD_FUNCT_ARG	BGerrno(  4, SEVE )
#	define BG_E_NODYNMEM		BGerrno(  5, ERRO )
#	define BG_E_OUT_OF_RANGE	BGerrno(  6, SEVE )
#	define BG_W_OVERFLOW_CYCLE	BGerrno(  7, WARN )
#	define BG_W_SICK_OBJ		BGerrno(  8, WARN )
#	define BG_W_VAR_NOT_INIT	BGerrno(  9, WARN )
#	define BG_E_EMPTY_GRAPH		BGerrno( 10, ERRO )

#	define BG_W_ALREADY_EXISTS	BGerrno( 11, WARN )
#	define BG_E_ELMT_NOT_DEFINED	BGerrno( 12, ERRO )
#	define BG_E_EMPTY_LIST		BGerrno( 13, ERRO )
#	define BG_W_ELMT_NOT_FOUND	BGerrno( 14, WARN )
#	define BG_E_UNK_ERRCODE   	BGerrno( 15, ERRO )

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                     Macro used for  exception processing                   */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define NULL_EXCEPT     0
#define EXCEPTION_1     1
#define EXCEPTION_2     2
#define EXCEPTION_3     3
#define EXCEPTION_4     4
#define EXCEPTION_5     5
#define EXCEPTION_6     6

#omdef gm$status(sts     = status,
                 msg     = NULL,
                 test    = !(status&1),
                 value   = exception,
                 type    = NULL_EXCEPT)
if(test)\
  {  printf("\nError at line %d of the file %s :\n",__LINE__,__FILE__);  \
#if om$specified(type)
exception_type = type; \
#endif
   goto value;\
   }\
#endomdef

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

