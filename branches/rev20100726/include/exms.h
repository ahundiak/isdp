#ifndef EX_D_EXMS

#define EX_D_EXMS 1
/*
 *	include 
 *		o	igrtypedef.h
 */
#include <msdef.h>

struct MS_sd_msg
{
    IGRint	no_args;
    IGRlong	no_msg;
    IGRchar     msgname[81];    /* message name                         */
    IGRchar	u_type[81];	/* types from macro			*/
    IGRchar	for_type[81];	/* types formated with terminating	*/
    IGRchar 	in_msg[ MS_MAX_MSG_LENGTH ];	/* read from message file		*/
    IGRchar 	variables[256];	/* variables after sprIGRintf with '\1'	*/
    IGRchar	out_msg[ MS_MAX_MSG_LENGTH ];	/* message in final form		*/
};

#endif
