/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
        This is the class of 3-d double precisionplanar orthogonal line
        strings.
Notes
        None.
History
        RDH     03/25/86 : Design date.
        MAS     09/04/87 : Altered for 1.1 Release
        AIC     04/24/91 : Removed num_points from instance data and
                           changed points from VLA of IGRdouble to VLA
                           of IGRpoint.
*/

class specification GR3dorthlnst (1:1) of GRorthlnst;

instance GR3dorthlnst
{
  variable IGRpoint points[];          /* array of points            */
};

override GRgetpolyline,GRputpolyline,GRclipto;

/* 
Motivation

GRgetpolyline - overridden because the method must generate the
        geometry, and parent classes do not have
        access to the instance data defined for this class.

GRputpolyline - overridden because the method must post the
        geometry into the instance data of the object,
        and parent classes do not have access to the instance
        data defined for this class.

GRclipto - overridden because the method must return specific 
        information about what this object becomes when it is 
        clipped and parent classes do not have knowledge of 
        this information.
*/

override debug;         /* dump instance data */

end specification GR3dorthlnst;
