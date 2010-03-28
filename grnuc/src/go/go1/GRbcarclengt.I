/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline
     METHOD NAME:	GRarclength

     Abstract: 	This module computes the arclength of
		an object between specified input points.
		The measurement begins at point1 and 
		ends at point3.

		Point2 is used as an indicator to determine if
		the curve is to be treated as an open or closed
		curve.  If it is to be treated as open point2
		should be the same as point1.  If it is to 
		be treated as closed, point2 must be different 
		from point1 and point3.  Point2 is used to 
		determine direction for measurement on closed 
		curves.
-----
%SC%    

	GRarclength(msg,mx_type,matrix,point1,point2,point3,
		     p1,p2,p3,length)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
	*mx_type  IGRshort	 matrix type
	matrix    IGRmatrix	 environment matrix	
	point1	  IGRpoint	 beginning point for equal spaced
				    points
	point2    IGRpoint	 direction point needed for closed
				    objects
	point3    IGRpoint	 ending point for equal spaced points
	*p1	  GRparms	 structure for parameter information
				    for point1
	*p2	  GRparms	 structure for parameter information
				    for point2
	*p3	  GRparms	 structure for parameter information
				    for point3

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	*msg	  IGRlong	 completion code
				    MSSUCC - successful completion
				    MSFAIL - error occured
	*length   IGRdouble	 length of the designated portion of
				    the curve 

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	MAbctotlen
	MAbcarclen
	MA2pt2dis

     Methods:
	
-----
%RL%

     RELATIONS REFERENCED:
	none.
-----
%NB%

     NOTES:
	If your object is to be treated as a closed curve, point2 
	(and its parameter,p2) is required to be the same as point1 
	(with parameter, p1). 
-----
%CH%

     CHANGE HISTORY:
	
	MAS     05/16/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method produces the arclength of an object between 2 points.

To do this a math routine is called which computes the arclength.
	
----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAbcarclen();
extern    IGRboolean    MAbctotlen();
extern    IGRboolean    MA2pt2dis();

method GRarclength(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
		 IGRpoint point1,point2,point3; struct GRparms *p1,
		 *p2,*p3; IGRdouble *length)

{
	
    IGRlong	OMmsg;			/* OM return value		*/
    IGRlong     msg2;			/* local return code		*/
    IGRlong	max_subs;		/* maximum sub intervals	*/

    IGRdouble   tot_len;		/* total length			*/
    IGRdouble	len1,len2;		/* local length variables	*/
    IGRdouble	dist1,dist2;		/* distance 			*/
    IGRdouble   tol;			/* tolerance			*/

    IGRchar	*ptr;			/* pointer to cache 		*/


    *msg = MSSUCC;			/* initialize to failure	*/
    OMmsg = OM_S_SUCCESS;

 					/* get abstract geometry	*/
    GRgetabsg(&msg2,mx_type,matrix,&ptr,i);

    if (1 & msg2)			/* see if successful		*/
    {			
	tol = 0.0000000001;		/* these values may be adjusted	*/
	max_subs = 100;
					/* tolerance check between points*/
	MA2pt2dis(&msg2,point1,point2,&dist1);
	MA2pt2dis(&msg2,point1,point3,&dist2);

        if (dist1 == 0.0)		/* curve will be treated as open*/
        {
	   if (dist2 == 0.0)
	   {
		*length = 0.0;	
	   }
	   else
	   {				/* compute length to p1->u	*/
		if (MAbcarclen(&msg2,ptr,&tol,&max_subs,&p1->u,&len1))
		{			/* compute length to p2->u	*/
		    if ( MAbcarclen(&msg2,ptr,&tol,&max_subs,&p3->u,&len2))
		    {
		 	if (p1->u < p3->u)
			{
			    *length = len2 - len1;
			}
			else
			{
			    *length = len1 - len2;
			}

		    }		     
		    else		/* arclength failed		*/
		    {
		    	*msg = MSFAIL;
		    	OMmsg = OM_E_ABORT;	
		    }
					
		}
		else			/* arclength failed		*/
	        {
		    *msg = MSFAIL;
		    OMmsg = OM_E_ABORT;	
		}
	    }

	}
	else				/* curve is closed		*/
	{
	    if (dist2 == 0.0)		/* total arclength is returned	*/
	    {
	    	if (! MAbctotlen(&msg2,ptr,&tol,&max_subs,length))
		{
		    *msg = MSFAIL;
		    OMmsg = OM_E_ABORT;	
		}
	    }
	    else			
	    {				/* compute length to p1->u	*/
		if (MAbcarclen(&msg2,ptr,&tol,&max_subs,&p1->u,&len1))
		{			/* compute length to p2->u	*/
		    if ( MAbcarclen(&msg2,ptr,&tol,&max_subs,&p3->u,&len2))
		    {
			if ( (p1->u < p2->u) && (p2->u < p3->u) )
			{
			    *length = len2 - len1;
			}
			else if ( (p3->u < p2->u) && (p2->u < p1->u) ) 
			{
			    *length = len1 - len2;
			}
			else
			{		/* compute total length		*/
			    if (MAbctotlen(&msg2,ptr,&tol,&max_subs,&tot_len))
			    {
				if (((p2->u < p3->u) && (p3->u < p1->u)) ||
				    ((p3->u < p1->u) && (p1->u < p2->u)))
				{
				    *length = len2 + tot_len - len1;
				}
				else
			     	{
				    *length = len1 + tot_len - len2;
				}
			    }
			    else	/* total length failed		*/
			    {
				*msg = MSFAIL;
				OMmsg = OM_E_ABORT;	
			    }
			
			}
		    }
		    else		/* arclength failed		*/
		    {
		    	*msg = MSFAIL;
		    	OMmsg = OM_E_ABORT;	
		    }
					
		}
		else			/* arclength failed		*/
	        {
		    *msg = MSFAIL;
		    OMmsg = OM_E_ABORT;	
		}
	    }
	}
    }    
    else
    {
	*msg = MSFAIL;			/* get abstract geometry failed	*/
	OMmsg = OM_E_ABORT;
    }

    

    return( OMmsg );

}
end implementation GRbspline;

