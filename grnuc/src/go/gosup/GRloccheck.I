/*
Name
        GRloccheck

Abstract
 	This function checks the properties, the class and the level to
        determine if an object satisfies the input locate criteria.

Description
        This function checks to see if the object meets the locate criteria
        requested by the command.

Synopsis
        IGRint GRloccheck(msg,mx_type,matrix,obj_properties,req_properties,
                          obj_level,req_levels,objid)

        < IGRlong *msg               completion code:
 				     MSSUCC - successful completion
				     MSFAIL - error occured
				     GR_NOT_VALID_PROPS - object
					does not satisfy properties
				     GRINVOBJECT - error, object
				        failed physically closed request
	    			     GRLEVEL_OFF - the objects level is off
        > IGRshort *mx_type 	     matrix type			  
        > IGRmatrix matrix	     environment matrix 		  
        > IGRushort *obj_properties  objects properties
        > IGRuint *req_properties    requested properties	  
        > IGRshort *obj_level        the objects level		  
        > IGRint *req_levels  	     the levels that are "on"	  
        > GRobjid *objid	     object id 			  

History
	MAS     03/20/87 : Design date.
        mrm     05/06/92   GRLocInfo changes
*/
 
class implementation GRgraphics;

#include "grimport.h"
#include "dpmacros.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "grerr.h"
#include "lcdef.h"
#include "lcmacros.h"
#include "lcmsg.h"
#include "dpstruct.h"

from GRvg import GRgeomprops;

IGRint GRloccheck(msg,mx_type,matrix,obj_properties,req_properties,
                  obj_level,req_levels,objid)

IGRlong		*msg;		/* return code			*/
IGRshort 	*mx_type;	/* matrix type			*/
IGRmatrix	matrix;		/* environment matrix 		*/
IGRushort       *obj_properties;/* objects properties		*/
IGRulong        *req_properties;/* requested properties	        */
IGRshort	*obj_level;	/* the objects level		*/
IGRint		*req_levels;	/* the levels that are "on"	*/
GRobjid		*objid;		/* object id 			*/

{	
    IGRlong	OMmsg;

    *msg = MSSUCC;			/* initialize return variables	*/
    OMmsg = OM_S_SUCCESS;

    *msg = GRcheck_props(mx_type,matrix,objid,obj_properties,
	req_properties);

    if ( ( 1 & *msg) || (*msg == GRINVOBJECT ))
    {					/* see if objects level on	*/
  	if (! DPlevel_check(*obj_level,req_levels))
	{
	    *msg = GRLEVEL_OFF;
            GRLocInfo(GRObjectIneligible, LC_E_LayerOff,
                      OM_Gw_current_OS, *objid);
	}
    }
    else				/* properties not valid		*/
    {
	*msg = GRNOT_VALID_PROPS;
    }

    if ( !(1 & *msg))
    {
	OMmsg = OM_W_ABORT;
    }

    return (OMmsg);
}

/************************************************************************
 
 This function checks to see if the properties of the object match
 the requested properties.

*************************************************************************/

#define MAX_BITS 12

GRcheck_props(mx_type,matrix,objid,props,test_props)

IGRshort *mx_type;			/* type matrix			*/
IGRmatrix matrix;			/* environment matrix		*/
GRobjid  *objid;			/* object id			*/
IGRushort *props;		/* objects properties		*/
IGRulong *test_props;		/* locate criteria		*/

{
    IGRint  	status;
    IGRint   	even,both_valid;
    IGRint 	i;
    IGRint 	OMmsg;
    IGRlong	msg1;
    IGRuint     bit_mask,pair_bit_mask;	/* bit masks			*/

    struct GRprops geom_props;		/* geometry properties		*/

    status = MSSUCC;			/* initialize return		*/

    if (*test_props != 0)		/* props == 0 means ignore check*/
    {
	bit_mask = 1;			/* set bit mask			*/
        pair_bit_mask = 3;		/* special for double request	*/
	even = 1;			/* even/odd flag		*/
					/* loop for all possible request*/
	for (i=0; i<MAX_BITS && ( 1 & status); ++i)
	{				/* indicator for both		*/
	    if (even)
	    {
	        if ( ((*test_props & pair_bit_mask) == pair_bit_mask) ||
		     ((*test_props & pair_bit_mask) == 0))
	        {
		    both_valid = TRUE;
	        }
	    	else
	    	{
		    both_valid = FALSE;
	        }		
	    }
	    else
	    {
		both_valid = FALSE;
	    }
					/* check only if requested	*/
	    if ( (! both_valid ) && (*test_props & bit_mask))
	    {
		switch (i)		/* switch on set bit position	*/
		{
		    case 0:		/* requested locatable only	*/
		    {
		        if ( !(*props & GRIS_LOCATABLE))
	    		{		/* object was not locatable	*/
			    status = MSFAIL;
                            GRLocInfo(GRObjectIneligible, LC_E_NotLocatable,
                                      OM_Gw_current_OS, *objid);
			}
			break;
		    }
		    case 1:		/* requested non-locatable	*/
		    {
	    		if (*props & GRIS_LOCATABLE)
	    		{		/* object locatable		*/
			    status = MSFAIL;	
                            GRLocInfo(GRObjectIneligible, LC_E_NotNonLocatable,
                                      OM_Gw_current_OS, *objid);
			}
			break;
		    }
		    case 2:
		    {			/* requested read-only		*/
	    		if (!(*props & GRIS_READ_ONLY))
	    		{		/* object is not read only	*/
			    status = MSFAIL;
                            GRLocInfo(GRObjectIneligible, LC_E_NotReadOnly,
                                      OM_Gw_current_OS, *objid);
			}
			break;
		    }	
		    case 3:		/* locate writable only		*/
		    {
		        if (*props & GRIS_READ_ONLY)
	       		{		/* object is read only		*/
			    status = MSFAIL;
                            GRLocInfo(GRObjectIneligible, LC_E_NotWritable,
                                      OM_Gw_current_OS, *objid);
	    		}
			break;
		    }
		    case 4:		/* locate displayable only	*/
		    {
			if (! (*props & GRIS_DISPLAYABLE))
			{
			    status = MSFAIL;
                            GRLocInfo(GRObjectIneligible, LC_E_NotDisplayable,
                                      OM_Gw_current_OS, *objid);
			}
			break;
		    }
		    case 5:		/* locate invisible only	*/
		    {
			if (*props & GRIS_DISPLAYABLE)
			{		/* object is displayable	*/
			    status = MSFAIL;		        
                            GRLocInfo(GRObjectIneligible, LC_E_NotNonDisplayable,
                                      OM_Gw_current_OS, *objid);
			}
			break;
		    }
		    case 6:		/* locate new objects only	*/
		    {
			if (! (*props & GRIS_NEW))
			{		/* object is not new		*/
			    status = MSFAIL;		        
                            GRLocInfo(GRObjectIneligible, LC_E_NotNew,
                                      OM_Gw_current_OS, *objid);
			}
			break;
		    }
		    case 7:		/* locate modified objects only	*/
		    {
			if (!(*props & GRIS_MODIFIED))
			{		/* object is not modified	*/
			    status = MSFAIL;		        
                            GRLocInfo(GRObjectIneligible, LC_E_NotModified,
                                      OM_Gw_current_OS, *objid);
			}
			break;
		    }
		    case 8:
		    case 9:
		    case 10:
		    case 11:
		    {
			OMmsg = om$send(
		   	     msg = message GRvg.GRgeomprops
				(&msg1,mx_type,matrix,&geom_props),
			     senderid = *objid,
			     targetid = *objid);

			if (! (OMmsg & 1))
			{
			    status = MSFAIL;
                            GRLocInfo(GRObjectIneligible, LC_E_GRgeomprops,
                                      OM_Gw_current_OS, *objid);
			}
			else
			{
			    if (i == 8)
			    {		/* planar only			*/
				if (! geom_props.planar)
				{
				    status = MSFAIL;
                                    GRLocInfo(GRObjectIneligible,
                                              LC_E_NotPlanar,
                                              OM_Gw_current_OS, *objid);
				}
			    }			   
			    else if ( i == 9) 
			    {
				if (geom_props.planar)
				{
			    		/* non-planar only		*/
			    	    status = MSFAIL;		        
                                    GRLocInfo(GRObjectIneligible, 
                                              LC_E_Planar,
                                              OM_Gw_current_OS, *objid);
				}
			    }
			    else if (i == 10) 
			    {		/* physically closed only	*/
				if (!geom_props.phy_closed)
				{
    				    status = GRINVOBJECT;	        
                                    GRLocInfo(GRObjectIneligible, 
                                              LC_E_NotPhyClosed,
                                              OM_Gw_current_OS, *objid);
				}
			    }
			    else if (i == 11)
			    {		/* physically open only		*/
				if (geom_props.phy_closed)
				{
			            status = MSFAIL;		        
                                    GRLocInfo(GRObjectIneligible, 
                                              LC_E_NotPhyOpen,
                                              OM_Gw_current_OS, *objid);
				}
			    }
			}
			break;
		    }
		    default:
		    {
			
		    }
		}
	    }
	    if ( both_valid)		/* no need to check next bit	*/
	    {
	        bit_mask = bit_mask << 2;			
	        pair_bit_mask = pair_bit_mask << 2;
		++i;			/* bump to next pair		*/
	    }
	    else
	    {	
	        bit_mask = bit_mask << 1;
	        pair_bit_mask = pair_bit_mask << 1;
	        even = (even ? 0 : 1); 	/* toggle even/odd flag		*/
	    }
	}	
    }
    return(status);
}

end implementation GRgraphics;
