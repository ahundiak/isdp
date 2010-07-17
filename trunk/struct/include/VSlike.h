/* $Id */

/***************************************************************************
 * I/STRUCT
 *
 * File: include/VSlike.h
 * Description:
 *
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSlike.h,v $
 *      Revision 1.2  2001/03/02 21:04:40  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:42  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  2000/02/23  19:59:36  pinnacle
 * ylong
 *
 * Revision 1.2  1999/10/05  18:22:46  pinnacle
 * ylong
 *
 * Revision 1.1  1999/06/21  13:33:52  pinnacle
 * ylong
 *
 *
 * History:
 * MM/DD/YY     AUTHOR          DESCRIPTION
 * 06/21/99     ylong           create for mirror like
 * 10/04/99	ylong		Added partName for CR179900828
 * 02/23/00	ylong		Added partNum for TR179901139 
 ***************************************************************************/

#ifndef VSlike_include
#define VSlike_include

#define MAX_NUM_PTS  17

typedef struct 
{
  TGRbsp_curve    *crv ;          
  IGRint           num_pts ;            // actual number of sample pts
  IGRpoint         pts[MAX_NUM_PTS] ;   // sample points of the curve
  IGRdouble        crvlen ;             // curve length
} TVSlikeCrv ;

typedef struct 
{
  IGRint           count ;      // number of curves
  TVSlikeCrv       edge[40] ;   // curves
  IGRdouble        angl[40] ;   // angle i btwn 2 chords of edges i-1 and i
} TVSlikeEdges ;


typedef struct 
{
  IGRchar    endTreatment0[80];
  IGRchar    endTreatment1[80];
  IGRchar    endTreatInfo0[80];
  IGRchar    endTreatInfo1[80];

} TVSlikeTreat;


typedef struct 
{
  TGRobj_env     pieceOE;
  IGRint         pieceLike;       // piece like has the same value
  IGRchar        partName[128];   // added for CR179900828
  IGRchar        partNum[128];    // added for TR179901139
  IGRchar        category[80];    // applied to both plate and beam
  IGRchar        material[80];    // applied to both plate and beam
  IGRchar        grade[30];       // applied to both plate and beam
  IGRint         planar;          // applied to both plate and beam
  double         area;            // applied to both plate and beam

  double         thickness;       // plate
  TVSlikeEdges   edges;           // plate

  IGRchar        family[80];      // beam
  double         length;          // beam
  char           treat[128];      // beam: end treatment type and info 
  TGRid          beamCL_ID;       // beam 
  TVSlikeCrv     beamCL;          // beam

  IGRdouble      planePoint[3];
  IGRdouble      planeNormal[3];

} TVSlikePiece;


typedef struct 
{

  int           pieceCNT;
  TVSlikePiece *pieceLIKEs;
  
  TGRmd_env     env;
  int           selInProgress;
  
} TVSlikeInfo;




#endif


