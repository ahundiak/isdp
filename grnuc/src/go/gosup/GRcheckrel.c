/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "grgsdef.h"
#include "grerr.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "msdef.h"

#define OUTSIDE 0
#define INSIDE  1
#define OVERLAP 2

IGRlong	GRcheckrel(msg,prism_rel,relationship)

IGRlong		*msg;
IGRlong		*prism_rel;
IGRlong		*relationship;
{
    IGRlong	OMmsg;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    if (prism_rel)
    {
	if ( *prism_rel == TRUE_REL)
	{
	    goto wrapup;
	}

    	if ( *prism_rel & GO_INSIDE )
    	{
    	    if (*relationship == OUTSIDE)
	    {
	    	*msg = GR_E_INV_REQUEST;
	    	OMmsg = OM_W_ABORT;
	    }
	    else if (!(*prism_rel & GO_OVERLAP))
	    {
	     	if (*relationship == OVERLAP)
	    	{
		    *msg = GR_E_INV_REQUEST;
		    OMmsg = OM_W_ABORT;
	         }
	    }
    	}
    	else if (*prism_rel & GO_OUTSIDE)
    	{
	    if (*relationship == INSIDE)
	    {
	    	*msg = GR_E_INV_REQUEST;
	    	OMmsg = OM_W_ABORT;
	    }
	    else if (!(*prism_rel & GO_OVERLAP))
	    {
	    	if (*relationship == OVERLAP)
	    	{
		    *msg = GR_E_INV_REQUEST;
		    OMmsg = OM_W_ABORT;
	    	}
	     }
    	}
    	else if (*prism_rel & GO_OVERLAP )
    	{
	    if (*relationship != OVERLAP)
	    {
	    	*msg = GR_E_INV_REQUEST;
	    	OMmsg = OM_W_ABORT;
	    }
        }
    }

wrapup:   

    return(OMmsg);
}
