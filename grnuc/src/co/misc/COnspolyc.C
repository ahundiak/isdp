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

   IGRlong COnpolygonConstruct( 
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
                                                                            
Arguments
    msg
        return codes

    RotationMatrix
        matrix from the window that tells how
        the object space is being viewed.

    CenterPoint
        center of the n-sided polygon

    NumberOfPoints
        number of slots in PointArray

    PointArray
        an array of points. will hold all the points of the
        n-sided polygon.  when sent in, it only needs to hold
        the first point of the polygon.  the last point
        in the array will be the same as the first point
                                                                               
Status returns
                                                                               
        OM_S_SUCCESS
        OM_E_ABORT

History
    trc 03/05/87 : adapted to the new include file design

*/

#include "coimport.h"
#include "codebug.h"

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "madef.h"
#include "igr.h"
#include "codef.h"






extern    IGRboolean    MAptsxform();
extern    IGRboolean    MArotmx();


IGRlong COnpolygonConstruct(
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
    struct IGRline   boreline;
    IGRboolean       b_status;
    IGRlong          index;
    IGRlong          NumberToRotate;
    IGRpoint         point1;
    IGRpoint         point2;
    IGRmatrix        OutputMatrix;
    IGRlong          status;
    IGRdouble       *Vector;


    /*
     *  initialize return codes
     */
    *msg = MSSUCC;
    status = MSSUCC;


    /*
     *  the angle of rotation
     */
    AngleOfRotation = ( 2 * PI ) / *NumberOfSides;
#   ifdef DEBUG
    printf( "COnpolygonConstruct - rotation angle %6.4f.\n", AngleOfRotation );
    printf( "COnpolygonConstruct - number of sides %d.\n", *NumberOfSides );
#   endif DEBUG


    /*
     *  initialize the boreline struct
     */
    boreline.point1 = point1;
    boreline.point2 = point2;


    /*
     *  number of points to rotate
     */
    NumberToRotate = 1;


    /*
     *  make sure that the last point in the array is the same as
     *  the first
     */
    PointArray[0] = EdgePoint[0] - CenterPoint[0];
    PointArray[1] = EdgePoint[1] - CenterPoint[1];
    PointArray[2] = EdgePoint[2] - CenterPoint[2];
    PointArray[ (*NumberOfSides * 3) ]     = PointArray[0];
    PointArray[ (*NumberOfSides * 3) + 1 ] = PointArray[1];
    PointArray[ (*NumberOfSides * 3) + 2 ] = PointArray[2];


    /*
     *  set up the rotation matrix
     */
    Vector = &(RotationMatrix[8]);
    b_status = MArotmx( 
                msg,
                Vector,
                &AngleOfRotation,
                OutputMatrix );
#   ifdef DEBUG
    printf( "COnpolygonConstruct - output matrix.\n" );
    {
        IGRlong i;
        for ( i = 0; i < 16; i++ )
        {
            printf( "            matrix[%2d] = %4.2f.\n", 
                                i, OutputMatrix[i] );
        }
    }
#   endif DEBUG


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
        if ( !b_status   ||   COERROR( *msg ) )
        {
#           ifdef DEBUG
            printf( "COnpolygonConstruct - failed in MAptsxform.\n" );
            printf( "                    msg 0x%x.\n", *msg );
#           endif DEBUG
            
            return( MSFAIL );
        }
    }


    /*
     *  go through the point array and add back the center point
     */
    for ( index = 0; index < (*NumberOfSides + 1) * 3; index += 3 )
    {
        PointArray[ index ] += CenterPoint[ 0 ];
        PointArray[ index + 1 ] += CenterPoint[ 1 ];
        PointArray[ index + 2 ] += CenterPoint[ 2 ];
    }


#   ifdef DEBUG
    printf( "COnpolygonConstruct - points in polygon.\n" );
    for ( index = 0; index < (*NumberOfSides + 1) * 3; index += 3 )
    {
        printf( "            point %d.\n", index );
        printf( "               x %4.2f.\n", PointArray[ index ] );
        printf( "               y %4.2f.\n", PointArray[ index + 1 ] );
        printf( "               z %4.2f.\n", PointArray[ index + 2 ] );
    }
#   endif DEBUG

    return( (b_status) ? MSSUCC : MSFAIL );
}
