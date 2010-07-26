/* #######################    APOGEE COMPILED   ######################## */
 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*
Name

   IGRlong COnmppolygonConstruct( 
                message,
                RotationMatrix,
                CenterPoint,
                NumberOfPoints,
                PointArray );

    IGRlong         *msg;
    IGRdouble       *RotationMatrix;
    IGRdouble       *CenterPoint;
    IGRdouble       *EdgePoint;
    IGRlong         *NumberOfSides;
    IGRdouble       *PointArray;
                                                                               

                                                                               

Abstract
    This routine constructs an array of points in an n-sided polygon.
    It should be noted that the EdgePoint that the user inputs is not
    a vertex, but the midpoint of a side.  From the input midpoint, I 
    calculate a vertex and go on like Place N-sided Polygon by Vertex. 
                                                                            
Arguments
    msg
        return code

    RotationMatrix
        matrix from the window that tells how
        the object space is being viewed.

    CenterPoint
        center of the n-sided polygon

    NumberOfSides
        number of sides of polygon which is one less than the
        number of points in the PointArray

    PointArray
        an array of points. will hold all the points of the
        n-sided polygon.  note that the first and last points
        of the array will be the same because of the method of
        construction.




History
    jjc 10/31/89 : created from trc's version for N-sided polygon by vertex

*/

#include "coimport.h"
#include "codebug.h"

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igrmacros.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "madef.h"
#include "igr.h"
#include "codef.h"






extern    IGRboolean    MAptsxform();
extern    IGRboolean    MAgrotmx();
extern    IGRboolean    MA2ptdis();
extern    IGRboolean    MAptalln();
extern    IGRdouble     MAcos();
 

IGRlong COnmppolygonConstruct(
                msg,
                RotationMatrix,
                CenterPoint,
                EdgePoint,
                NumberOfSides,
                PointArray )

    IGRlong         *msg;
    IGRdouble       *RotationMatrix;
    IGRdouble       *CenterPoint;
    IGRdouble       *EdgePoint;
    IGRlong         *NumberOfSides;
    IGRdouble       *PointArray;


{
    IGRdouble        AngleOfRotation;
    IGRdouble        HalfAngle;
    IGRdouble        distance;
    IGRdouble        NewEdgePoint[3];
    IGRdouble        transpoint[3];
    struct IGRline   myline;
    IGRboolean       b_status;
    IGRlong          index;
    IGRlong          NumberToRotate;
    IGRmatrix        OutputMatrix;
    IGRmatrix        OutMatrix;
    IGRlong          status;
    IGRdouble       *Vector;
    IGRdouble        radius;
    IGRdouble        cosine;
    IGRshort         direction;


    /*
     *  initialize return codes
     */
    *msg = MSSUCC;
    status = MSSUCC;

    /*  get the Z vector
     */
    Vector = &(RotationMatrix[8]);

    /*
     *  number of points to rotate
     */
    NumberToRotate = 1;

    /*  direction for MAptalln 
     */
    direction      = 1;

    /*
     *  the angles of rotation
     */
    AngleOfRotation = ( 2 * PI ) / *NumberOfSides;
    HalfAngle = PI / *NumberOfSides;

    /*  get copy of EdgePoint so that it may be transformed to the vertex
     *  point we want
     */
    transpoint[0] = EdgePoint[0];
    transpoint[1] = EdgePoint[1];
    transpoint[2] = EdgePoint[2];

    /*  get a matrix that will perform the rotation of the edgepoint to the
     *  new vertex point using the CenterPoint as the origin of rotation
     */
    b_status = MAgrotmx( 
                msg,
                Vector,
                CenterPoint,
                &HalfAngle,
                OutMatrix );
    _m_check_boolq(b_status);

    /*  transform the point using the matrix
     */
    b_status = MAptsxform(
                msg,
               &NumberToRotate,
                OutMatrix,
                transpoint,
                transpoint );
    _m_check_boolq(b_status);

    /*  initialize the line structure, the vertex point will be on this line
     *  at a distance from the CenterPoint
     */
    myline.point1 = CenterPoint;
    myline.point2 = transpoint;

    /*  now calculate the distance from the CenterPoint to the vertex.
     *  first get the distance from the CenterPoint to the input EdgePoint.
     *  this distance will be the leg of a right triangle and the distance
     *  from center to vertex will be the hypotenuse.  the cosine relationship
     *  is used below.
     */
    b_status = MA2ptdis(
                msg,
                EdgePoint,
                CenterPoint,
               &distance );
    _m_check_boolq(b_status);

    cosine = MAcos(
              msg,
              &HalfAngle );
    _m_checkq(*msg);

    radius = distance / cosine ;


    /*  having the distance along the line now, we can use this function to
     *  get the vertex point 
     */   
    b_status = MAptalln(
                msg,
               &myline,
                CenterPoint,
               &direction,
               &radius,
                NewEdgePoint );                
    _m_check_boolq(b_status);


    /*
     *  make sure that the last point in the array is the same as
     *  the first
     */
    PointArray[0] = NewEdgePoint[0];
    PointArray[1] = NewEdgePoint[1];
    PointArray[2] = NewEdgePoint[2];
    PointArray[ (*NumberOfSides * 3) ]     = PointArray[0];
    PointArray[ (*NumberOfSides * 3) + 1 ] = PointArray[1];
    PointArray[ (*NumberOfSides * 3) + 2 ] = PointArray[2];


    /*
     *  set up the rotation matrix
     */

    b_status = MAgrotmx( 
                msg,
                Vector,
                CenterPoint,
                &AngleOfRotation,
                OutputMatrix );
    _m_check_boolq(b_status);



    /*
     *  rotate the edge point number of sides times
     */
    for ( index = 0; index < (*NumberOfSides - 1) * 3; index += 3 )
    {
        b_status = MAptsxform(
                        msg,
                        &NumberToRotate,
                        OutputMatrix,
                        &(PointArray[ index ]),
                        &(PointArray[ index + 3 ])  );
       _m_check_boolq(b_status);
    }


quit:
    return( (b_status) ? MSSUCC : MSFAIL );
}
