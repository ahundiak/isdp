/* $Revision: 1.1 $ */
/*
 *	(c) Copyright 1990, Natural Language Incorporated, All Rights Reserved
 *	Copyright notice is precautionary and does not imply publication or
 *	disclosure
 *
 *	This Document/File Contains Proprietary Information, it may not be
 *	copied or disclosed without written permission.
 */

#ifndef _nlc_error_defined_
#define _nlc_error_defined_

#define MSG_CODE(c1,c2,e,s) ((c1<<24)|(c2<<16)|(e<<4)|s)
#define NL_MSG_FAC1(e)	(((e)>>24)&0xFF)
#define NL_MSG_FAC2(e)	(((e)>>16)&0xFF)
#define NL_MSG_SEQ(e)	(((e)>>4)&0xFFF)
#define NL_MSG_SEV(e)	((e)&0xF)
#define MSG_WARN	0
#define MSG_INFO	1
#define MSG_ERROR	2


#define NL_WARN(e)		MSG_CODE('L','C',e,MSG_WARN)
#define NL_ERROR(e)		MSG_CODE('L','C',e,MSG_ERROR)

typedef unsigned int		Nl_error;

#define NLE_SUCCESS 		0
#define	NLE_NOMEM 		NL_ERROR(1)
#define	NLE_CONN_FAIL		NL_ERROR(2)
#define	NLE_DBLOAD_FAIL		NL_ERROR(3)
#define	NLE_PROTOCOL		NL_ERROR(4)
#define	NLE_READ_ERR		NL_ERROR(5)
#define	NLE_EVAL_ERR		NL_ERROR(6)
#define	NLE_BUFOVF 		NL_WARN(7)
#define	NLE_TABOVF 		NL_WARN(8)
#define	NLE_NO_MORE 		NL_ERROR(9)
#define	NLE_INV_ARG		NL_ERROR(10)
#define	NLE_NEED_REPLY		NL_ERROR(11)
#define	NLE_INPOVF		NL_ERROR(12)
#define	NLE_INTERRUPTED		NL_ERROR(13)
#define	NLE_EXITED		NL_ERROR(14)
#define NLE_INPROG		NL_ERROR(15)
#define	NLE_ABORT		NL_ERROR(16)
#define	NLE_USEREXIT		NL_ERROR(17)
#endif /* _nlc_error_defined_ */
