/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GR3dorthlnst
     METHOD NAME:  GRgetpolyline

     Abstract: 
                This method gets the polyline representation for a 
        3-D double precision floating point orthogonal line string.  
        The input transformation matrix is applied to the object 
        before placing it in the buffer.
-----
%SC%    
     GRgetpolyline(msg,matrix_type,matrix,action,polyline)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort       type of transformation matrix
     matrix        IGRmatrix      transformation matrix
     *action       IGRint         action desired
                                    0 - return only number of points
                                    1 - return the polyline 
                                    2 - default buffer sent in of size
                                        equal number of points
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
                                    - MSINARG buffer not large enough
                                      due to allocation problems;
                                      polyline->num_points is reset
                                      to the appropriate size.

     *polyline    struct IGRpolyline 
                                 the polyline structure
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  
                GRpytransutil

     Methods:  none.
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  none.
-----
%CH%

     CHANGE HISTORY:
        
        MAS     10/06/87: Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

        This method converts the 3-D double precision floating
        point orthogonal line string into a polyline.
        Then the line string is transformed to world coordinates
        using the input transformation matrix.

----*/
/*EH*/

class implementation GR3dorthlnst;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"
#include "OMmacros.h"

extern    IGRboolean    MAoptsxform();

method GRgetpolyline(IGRlong *msg; IGRshort *matrix_type;
         IGRmatrix matrix; IGRint *action; struct IGRpolyline *polyline)
{

    IGRlong             OMmsg;          /* OM return status             */
    IGRint              i, j;

    *msg = MSSUCC;                      /* initialize to success        */
    OMmsg = OM_S_SUCCESS;
                                        /* initialize for allocate      */
    if ( *action == 0)
    {
        polyline->num_points = om$dimension_of(varray = me->points);
    }
    else
    {
        if (*action == 2)
        {
            if (polyline->num_points < om$dimension_of(varray = me->points))
            {
                polyline->num_points = om$dimension_of(varray = me->points);
                OMmsg = OM_W_ABORT;
                *msg = MSINARG;
                goto wrapup;
            }
        }
        polyline->num_points = om$dimension_of(varray = me->points);
        
        if (*matrix_type != MAIDMX)
        {
            if (! MAoptsxform(msg,&polyline->num_points,matrix_type,
                        matrix,&me->points[0][0],&polyline->points[0]))
            {
                *msg = MSFAIL;
                OMmsg = OM_E_ABORT;
            }
        }
        else
        {
            for (i=0, j=0; i< polyline->num_points; ++i)
            {
                polyline->points[j++] = me->points[i][0];
                polyline->points[j++] = me->points[i][1];
                polyline->points[j++] = me->points[i][2];
            }
        }
    }


wrapup:
        

        return (OMmsg);

}

end implementation GR3dorthlnst;
