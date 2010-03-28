/*
 * GM error codes.
 * File dependency : "OMerrordef.h"
 */

#ifndef GMerrordef_include 
#define GMerrordef_include

#define GM_FACILITY_CODE	159
#define GMerrno( n, sev ) \
		((((GM_FACILITY_CODE)&0xfff)<<16)|(((n)&0x1fff)<<3)|((sev)&7))

#define GMfacility( stat )	( ( (stat) >> 16  ) & 0xfff	)
#define GMmess_index( stat )	( ( (stat) >> 3  )  & 0x1fff	)
#define GMseverity( stat )	(   (stat)          & 7		)

#	define GM_IOR_STOP		0x1000
#	define GM_IAND_STOP		0x0800
#	define GM_ITAG  		0x0400
  
#	define GM_I_OR_STOP		GMerrno(  GM_IOR_STOP , INFO )
#	define GM_I_AND_STOP		GMerrno(  GM_IAND_STOP, INFO )
#	define GM_I_TAG			GMerrno(  GM_ITAG     , INFO )
#	define GM_S_SUCCESS		GMerrno(  2, SUCC )
#	define GM_I_NEG_RESPONSE	GMerrno(  3, INFO )
#	define GM_E_STOP_PROCESS	GMerrno(  4, ERRO )
#	define GM_F_BAD_FUNCT_ARG	GMerrno(  5, SEVE )
#	define GM_E_NODYNMEM		GMerrno(  6, ERRO )
#	define GM_E_OUT_OF_RANGE	GMerrno(  7, SEVE )
#	define GM_W_SICK_OBJ		GMerrno(  8, WARN )
#	define GM_W_VAR_NOT_INIT	GMerrno(  9, WARN )
#	define GM_E_EMPTY_GRAPH		GMerrno( 10, ERRO )

#	define GM_W_ALREADY_EXISTS	GMerrno( 11, WARN )
#	define GM_E_ELMT_NOT_DEFINED	GMerrno( 12, ERRO )
#	define GM_E_EMPTY_LIST		GMerrno( 13, ERRO )
#	define GM_W_ELMT_NOT_FOUND	GMerrno( 14, WARN )
#	define GM_E_UNK_ERRCODE   	GMerrno( 15, ERRO )
#	define GM_I_ALREADY_EXISTS	GMerrno( 16, INFO )

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

#endif
