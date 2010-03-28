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
 *  coformpriv.h 
 *
 *  NO dependencies
 *
 *  labels, etc used by department 3416's c-based forms
 *
 *  srh - created 
 */

/*
 *  label the gadget tag numbers for "CurrentPt" Form
 */
#define  DISMISS_FORM                  (  1 )
#define  MSG_FIELD                     ( 10 )
#define  TITLE                         ( 11 )
#define  SECOND_COORD_VALUE            ( 12 )
#define  THIRD_COORD_VALUE             ( 13 )
#define  COORDINATE_SYSTEM_TYPE        ( 14 )
#define  FIRST_COORD_VALUE             ( 15 )
#define  COORDINATE_SYSTEM_NAME        ( 16 )
#define  FIRST_COORD_NAME              ( 17 )
#define  SECOND_COORD_NAME             ( 18 )
#define  THIRD_COORD_NAME              ( 19 )

/*
 * indices into forms.9 font for coordinate name labels in "CurrentPt" form
 */
#define  Xindex                         'X'
#define  Yindex                         'Y'
#define  Zindex                         'Z'
#define  THETAindex                     '\200'
#define  RHOindex                       '\201'
#define  PHIindex                       '\202'
#define  Rindex                         '\203'

#define  CURRENT_PT_LABEL              ( 0 )
#define  CURRENT_PT_FILENAME           "CurrentPt"

