/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	MAcpfrlb
 
     Abstract:	

		This function creates a curve prism from a 
	local bounded system.
-----
%SC%

     VALUE = MAcpfrlb(message,lbsys,cv_prism)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     lbsys	  IGRlbsys	 the local bounded system geometry
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message      IGRlong	 completion code
				    - MSSUCC if successful
				    - MADGENRAT (error) if an
					error occurred while
					transforming the points of
					the curve prism from local
					to world coordinates
				    - MSFAIL (severe) if an error 
					occurred
     cv_prism	  IGRcv_prism	 curve prism geometry structure

     VALUE (IGRboolean) = TRUE	    - if successful	
		          FALSE	    - if failure
-----
%MD%

     MODULES INVOKED:	
	
	MAptsxform
	MApyfrlb
	MApytobc
	MAtrnmx
	MAwclsmx
	MA3protmx

-----
%NB%

     NOTES:		None.

-----

%CH%
     CHANGE HISTORY:
	
	MAS  06/03/87  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

This function creates a curve prism from a local bounded system. 
This is done by first creating the polyline which defines the 
faces of the local bounded system. A matrix is formed defining the
local system of the face of the prism.  The origin is extracted from
the local bounded system.  
	
----*/
/*EH*/

#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "ma.h"
#include "msdef.h"

extern    IGRboolean    MApyfrlb();
extern    IGRboolean    MApyextents();
extern    IGRboolean    MApytobc();
extern    IGRboolean    MAptsxform();
extern    IGRboolean    MA3protmx();
extern    IGRboolean    MAtrnmx();
extern    IGRboolean    MA2lnproj();

IGRboolean MAcpfrlb(message,lbsys,cv_prism)

IGRlong	*message;		/* completion code		*/
struct IGRlbsys *lbsys;
struct IGRcv_prism *cv_prism;	

{
    IGRshort   	mx_size;

    IGRlong	i;			/* loop index			*/

    struct IGRpolyline prism_py;	/* working polyline		*/
    struct IGRline line1,line2;

    IGRdouble   points[30];
    IGRdouble 	origin[3],pt[3];
    IGRdouble	t1,t2;

    IGRmatrix	tmatrix;


    /*
     *  initialize internal variables
     */

    *message  = MSSUCC;    
    prism_py.points = points;

    if (MApyfrlb(message,lbsys,&prism_py))
    {					/* matrix is formed from face	*/
    	for (i=6; i >= 0; i -= 3)
	{				/* loop until matrix formed	*/
	    if (MA3protmx(message,&prism_py.points[12],
		   &prism_py.points[9],&prism_py.points[i],tmatrix))
	    {
		i = -1;
	    }	    
	}

	if (1 & *message)
	{
	    /* the matrix in the curve prism goes from local coordinates
	     * to world coordinates, therefore, the matrix formed above
	     * must be transformed.
	     */

	    mx_size = 4;

	    if (MAtrnmx(message,&mx_size,tmatrix,cv_prism->matrix))
	    {
		line1.point1 = prism_py.points;
		line1.point2 = &prism_py.points[6];

		line2.point1 = &prism_py.points[3];
		line2.point2 = &prism_py.points[9];

		if (MA2lnproj(message,&line1,&line2,origin,pt,&t1,&t2))
		{
		    MAwclsmx(message,origin,cv_prism->matrix,tmatrix);

	    	    i = 6;		/* transform 6 points to local 
					   system			*/
	    	    if (MAptsxform(message,&i,tmatrix,
			prism_py.points,prism_py.points))
		    {
					/* height is z of point 6	*/
		        cv_prism->height = prism_py.points[17];

					/* reset for conversion		*/
		        prism_py.num_points = 5;
					/* form prism matrix		*/
  		        MAlswcmx(message,origin,cv_prism->matrix,
			     cv_prism->matrix);
	  
					/* convert to curve		*/
		        if (!MApytobc(message,&prism_py,&cv_prism->curve))
		        {
			    *message = MSFAIL;
		    	}
		    }
		}
	 	else
		{
		    *message = MSFAIL;
		}
	    }
	    else
	    {
		*message = MSFAIL;
	    }
	}
	else
	{
	    *message = MSFAIL;
	}
    }
    else
    {
	*message = MSFAIL;
    }

    return(*message == MSSUCC);
}
