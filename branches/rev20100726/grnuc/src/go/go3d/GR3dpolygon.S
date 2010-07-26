/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
        The class GR3dpolygon is a subclass of GRpolygon and is a 3-D 
        double precision representation of a polygon.
Notes
        None
History 
        MAS     11/12/85 : Design date.
        RDH     03/25/86 : Rewrite.
        MAS     09/04/87 : Altered for 1.1 Release
        AIC     04/24/91 : Removed num_points from instance data and
                           changed points from VLA of IGRdouble to VLA
                           of IGRpoint.
*/

class specification GR3dpolygon  (1:1) of GRpolygon;

instance GR3dpolygon
{
  variable IGRpoint points[];  /* array of points              */
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

end specification GR3dpolygon;
