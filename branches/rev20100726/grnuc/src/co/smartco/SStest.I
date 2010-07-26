/*

Name
  SStest.I

Description
  Smart Sketch driver routines.
  
Notes

 */
class implementation Root;

#include <math.h>
#include <stdio.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igrdef.h"
#include "igr.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpmacros.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMdtmacros.h"
#include "msdef.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"
#include "msmacros.h"
#include "grmsg.h"

/*

Name
  SSSketch

Abstract
  This is the entry point for Smart Sketch!  An EX_button struct containing
  the current cursor position, window info, etc. is passed in to drive the
  search for key points and constraints.
 
Synopsis

  int SSSketch ( PButton )
  struct EX_button *PButton   IN   Cursor button (as sent by dp$dynamics())
                                   used to locate constraints/keypoints

Description

Return Value
  OM_S_SUCCESS  always

Notes

Index

Keywords
  smart-sketch,dynamics

History
  06/08/93 : Shelley R. Heard : implemented from Henry's prototype
  09/01/93 : Shelley R. Heard : moved DB_set_term_func call to SSFindObjects();
                                improved SSObjects list reordering algorithm.

 */

SSSketch ( PButton )
struct EX_button *PButton;
{
  int        constraint_type;
  int        ObjectIndex;
  GRobjid    Objid1, Objid2;
  IGRlong    bufsize = sizeof( IGRboolean );
  IGRlong    nret;
  IGRboolean dynamics_all_windows;
  extern int SSWeNeedToReorder();

  if (!SSIsActive ())
    return OM_S_SUCCESS;

  if (!SSRefLock)
  {
    struct IGRline      BoreLine;
    double              Points [6] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
    double              Tolerance;
    struct IGRpolyline  PolyLine;
    long                LocalStatus;
    struct IGRdisplay   DisplayAttribute;
    struct DPele_header LineHeader;
    
    /*
     * We display the boreline
     */
    BoreLine.point1 = &Points [0];
    BoreLine.point2 = &Points [3];
    SSGetWindowTolerance ( PButton->objid, 
                           PButton->x,
                           PButton->y,
                           PButton->z, 
                          &Tolerance, 
                           NULL, 
                          &BoreLine );

    PolyLine.num_points = 2;
    PolyLine.points = &Points [0];
    DisplayAttribute.color = 0;
    DisplayAttribute.weight = 0;
    DisplayAttribute.style = 4;

    gr$get_dynamics_all_windows( msg = &LocalStatus,
                                 sizbuf = &bufsize,
                                 buffer = &dynamics_all_windows,
                                 nret = &nret );

    dp$build_dis_buffer ( buffer = &LineHeader,
                          type = IGRPY,
                          display_att = &DisplayAttribute,
                          geometry = &PolyLine );

    /* 
     * We must honor the dynamics_all_windows flag! 
     */
    if ( !dynamics_all_windows )
    {
       dp$display ( msg = &LocalStatus,
                    osnum = PButton->osnum,
                    objid = PButton->objid,
                    buffer = &LineHeader,
                    mode = GRhd );
    }
    else
    {
       dp$display ( msg = &LocalStatus,
                    buffer = &LineHeader,
                    mode = GRhd );
    }
  }


  
  SSHasMoved ( SSON );

  /*
   * We check the existing objects and scan the R-tree (see SSCheckObjects for 
   * details)
   */

  SSCheckObjects ( PButton->objid, 
                   PButton->x,
                   PButton->y, 
                   PButton->z, 
                   &constraint_type );


  /*
   * Re-order the list of objects so that the last objects that had constraints
   * found on them will be examined first.
   */    
  Objid1 = SSLastObject1 ? SSLastObject1->grid.objid : NULL_OBJID;
  Objid2 = SSLastObject2 ? SSLastObject2->grid.objid : NULL_OBJID;


  if ( SSWeNeedToReorder(SSLastObject1, SSLastObject2) )
  {
    int flag;


    SSOrder ( SSLastObject1, SSLastObject2 );
    /*
     * Order of SSObjects may have changed; SSLastObject[12] must be reassigned.
     */
    SSLastObject1 = NULL;
    SSLastObject2 = NULL;
    if (Objid1 != NULL_OBJID)
    {
      for (ObjectIndex = 0; ObjectIndex < SSnb_objects; ObjectIndex++)
      {
        if (Objid1 == SSObjects [ObjectIndex].grid.objid)
        {
          SSLastObject1 = &SSObjects [ObjectIndex];
          break;
        }
      }
    }
  
    if (Objid2 != NULL_OBJID)
    {
      for (ObjectIndex = 0; ObjectIndex < SSnb_objects; ObjectIndex++)
      {
        if (Objid2 == SSObjects [ObjectIndex].grid.objid)
        {
          SSLastObject2 = &SSObjects [ObjectIndex];
          break;
        }
      }
    }
  }


  if (constraint_type != SSNONE)
  {

    SSDisplayConstraint ( GRhd, 
                          PButton, 
                          SSGetXCoordinate (),
                          SSGetYCoordinate () );
  }

  /*
   *  We no longer care if the cursor has moved 
   */
  SSHasMoved ( SSOFF );

  return OM_S_SUCCESS;
}

/*

Name
  SSDynamicTest

Abstract
  Dummy (do nothing) dynamics routine for calling smart sketch when other
  dynamics are not needed.

Index

Keywords
  smart-sketch,dynamics

History
  09/03/93 : Shelley R. Heard : header added to original prototype code.

 */
 
#argsused
SSDynamicTest ( dummy, point, matrix, p_grids, num_grids, buffers, 
                num_buffers, dummy_in1, dummy_in2, dummy_in3, dummy_out1, 
                dummy_out2, dummy_out3 )
char                 *dummy;
struct EX_button     *point;
double               *matrix;
struct GRid          **p_grids;
int                  *num_grids;
struct DPele_header  **buffers;
int                  *num_buffers;
char                 *dummy_in1, *dummy_in2, *dummy_in3;
char                 **dummy_out1, **dummy_out2, **dummy_out3;
{
  *num_buffers = 0;
  
  return OM_S_SUCCESS;
}


/*
Name
  SSDynamics

Abstract
  Calls dp$dynamics with a dummy dynamics routine (does nothing) if 
  Smart Sketch is active.

Synopsis
  int SSDynamics ()

Description
  This routine is useful for invoking Smart Sketch from outside dynamics.
  For example, this is the call made by the co$getevent filter.

Return Value
  OM_S_SUCCESS -if not active 
  <return code from dp$dynamics> otherwise

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */

SSDynamics ()
/*
 * Just call dynamics.
 */
{
  int rc = OM_S_SUCCESS;

  if (SSIsActive ())
  {
    rc = dp$dynamics ( dyn_fun = SSDynamicTest );
  }

  return rc;
}

/*

Name
  SSWeNeedToReorder

Abstract
  This routine can be called to determine if the objects (*pO1, *pO2)
  are "out of order" in the SSObjects list.  

Synopsis
  int SSWeNeedToReorder ( pO1, pO2 )
    SSObject *pO1, *pO2;

Description
  Typically, this routine is used to determine if a call to SSOrder() is 
  required.  There are conditions that must be met before it it necessary 
  to reorder the SSObjects list:

   1) The list cannot be empty.
     - AND -
   2) pO1 or PO2 must exists (not NULL) and one of them must be 
      out of order.
   
  
Return Value

Notes
  The term "out of order" means :  
  1) if only pO1 is specified, then it is not the last element in the list
  2) if pO1 and pO2 are specified, then one or both are not in the last two
     slots in the list.  In this case, we do not care which of the last two
     slots pO1 and pO2 take in the list, as long as they are they are in those
     slots.

Index

Keywords
  smart-sketch,dynamics

History
  09/03/93 : Shelley R. Heard : created

 */

int SSWeNeedToReorder ( pO1, pO2 )
  SSObject *pO1, *pO2;
{
  int rc = FALSE;


  if ( SSnb_objects > 0 )
  {
    /* 
     * either pO1 or pO2 has to exist and be "out of order" (see notes above)
     */
    if ( pO1 )
    {
      if (   ( pO1->grid.objid != SSObjects[SSnb_objects-1].grid.objid )
          || (   (SSnb_objects > 1)
              && (pO2)
              && (pO1->grid.objid != SSObjects[SSnb_objects-2].grid.objid)
             )
         )
      {
        rc = TRUE;
      }
      else if ( pO2 )
      {
        if (   (pO2->grid.objid != SSObjects[SSnb_objects-1].grid.objid) 
            && (pO2->grid.objid != SSObjects[SSnb_objects-1].grid.objid) ) 
        {
          rc = TRUE;
        }
      }
    }
  }
  return rc;
}


/****************************************************************************

 ooooo   oooo  oooo  ooo ooo   ooo        oooo  ooooo  ooo ooo  ooooo  ooooo
  o   o  o     o   o  o   o   o          o        o     o   o   o      o     
  o   o  ooo   oooo   o   o   o  ooo      oooo    o     o   o   oooo   oooo   
  o   o  o     o   o  o   o   o   o           o   o     o   o   o      o     
 ooooo   oooo  oooo    ooo     ooo        oooo    o      ooo    o      o     

 ****************************************************************************/

/*
 * the following routines (SSPrint...) are very useful in analyzing problem
 * within the smart sketch system.  It is recommended that they be called from
 * the debugger (if possible) for diagnostic purposes. 
 *
 * THESE ROUTINES SHOULD NOT BE REFERENCED IN CODE RELEASED TO CUSTOMERS !!!
 */ 
void SSPrintUserInfo( pUserInfo )
  struct SSUserInfo  *pUserInfo;
{
  extern void SSPrintSSObj();
  
  printf("pUserInfo -> \n");
  printf("  tolerance : %g\n", pUserInfo-> tolerance );
  printf("  point {%g, %g, %g}\n", pUserInfo->point[0], 
                                    pUserInfo->point[1],  
                                    pUserInfo->point[2] );
  printf("  PBoreLine->\n" );
  printf("    point1 {%g, %g, %g}\n", 
         pUserInfo-> PBoreLine->point1[0],
         pUserInfo-> PBoreLine->point1[1],
         pUserInfo-> PBoreLine->point1[2] );
  printf("    point2 {%g, %g, %g}\n", 
         pUserInfo-> PBoreLine->point2[0],
         pUserInfo-> PBoreLine->point2[1],
         pUserInfo-> PBoreLine->point2[2] );
  printf("  ConstraintPoint {%g, %g, %g}\n", 
         pUserInfo->ConstraintPoint[0], 
         pUserInfo->ConstraintPoint[1],  
         pUserInfo->ConstraintPoint[2] );
  printf("  type : %d\n", pUserInfo-> type );
  printf("  matrix\n" );
  printf("  [ %g, %g, %g, %g ]\n",
         pUserInfo-> matrix[0],
         pUserInfo-> matrix[1],
         pUserInfo-> matrix[2],
         pUserInfo-> matrix[3] );
  printf("  [ %g, %g, %g, %g ]\n",
         pUserInfo-> matrix[4],
         pUserInfo-> matrix[5],
         pUserInfo-> matrix[6],
         pUserInfo-> matrix[7] );
  printf("  [ %g, %g, %g, %g ]\n",
         pUserInfo-> matrix[8],
         pUserInfo-> matrix[9],
         pUserInfo-> matrix[10],
         pUserInfo-> matrix[11] );
  printf("  [ %g, %g, %g, %g ]\n",
         pUserInfo-> matrix[12],
         pUserInfo-> matrix[13],
         pUserInfo-> matrix[14],
         pUserInfo-> matrix[15] );
  printf("  module.osnum : %d\n", pUserInfo->module.osnum );
  printf("  module.objid : %d\n", pUserInfo->module.objid );
  if (pUserInfo->p_object)
  {
    SSPrintSSObj( "p_object", pUserInfo->p_object);
  }
  else
  {
    printf("  p_object : NULL\n");
  }
}

void SSPrintSSObj(label, p_smobj) 
  char *label;
  SSObject *p_smobj;
{
  int ndx;

  if ( om$is_objid_valid ( osnum = p_smobj->grid.osnum, 
                           objid = p_smobj->grid.objid ) )
  {
    printf("  %s -> grid.objid.osnum : %d\n", label, p_smobj->grid.osnum );
    printf("  %s -> grid.objid.objid : %d\n", label, p_smobj->grid.objid );
    printf("  %s -> type : %d\n", label, p_smobj->type );
    printf("  %s -> NbKeyPoints : %d\n", label, p_smobj->NbKeyPoints );
  
    for ( ndx = 0; ndx < p_smobj->NbKeyPoints; ndx ++ )
    {
      printf( "  %s -> KeyPoints [%d] : { %g, %g, %g } - %s\n",
              label, 
              ndx,
              p_smobj->KeyPoints [ndx][0],
              p_smobj->KeyPoints [ndx][1],
              p_smobj->KeyPoints [ndx][2],
              p_smobj->KeyPointActive[ndx] ? "Active" : "Not Active" );
    }       
    printf("  %s -> NbBuffers : %d\n", label, p_smobj->NbBuffers );
    for ( ndx = 0; ndx < p_smobj->NbBuffers; ndx ++ )
    {
      printf("  %s -> buffers[%d] : 0X%x\n", label, ndx, p_smobj->buffers );
    }
  
    printf("  %s -> ExtendedPoints[0] : { %g, %g, %g }\n",
           label, 
           p_smobj->ExtendedPoints[0][0],
           p_smobj->ExtendedPoints[0][1],
           p_smobj->ExtendedPoints[0][2] );
           
    printf("  %s -> ExtendedPoints[1] :  { %g, %g, %g }\n", 
           label, 
           p_smobj->ExtendedPoints[1][0],
           p_smobj->ExtendedPoints[1][1],
           p_smobj->ExtendedPoints[1][2] );
         
    printf("  %s -> Radius : %g\n", label, p_smobj->Radius );
  }
  else
  {
    printf("  %s -> grid.objid.osnum : %d\n", label, p_smobj->grid.osnum );
    printf("  %s -> grid.objid.objid : %d\n", label, p_smobj->grid.objid );
    printf("  NOT A VALID OBJECT!\n" );
  }
}

void SSPrintMask()
{
  int smart_sketch_on;
  int elligible_constraints;

  gr$get_ss_lock ( buffer = &smart_sketch_on ); 
  gr$get_ss_constraints ( buffer = &elligible_constraints );
  printf("  DPB elligible constraints = 0X%x\n", elligible_constraints );

  printf("  DPB elligible constraints = \n" );
  if ( elligible_constraints & SSACTIVEHORIZONTAL  )
  {
    printf ( "  SSACTIVEHORIZONTAL\n" );
  }
  if ( elligible_constraints & SSACTIVEVERTICAL    )
  {
    printf ( "  SSACTIVEVERTICAL\n" );
  }
  if ( elligible_constraints & SSACTIVEONELE       )
  {
    printf ( "  SSACTIVEONELE\n" );
  }
  if ( elligible_constraints & SSACTIVETANGENT     )
  {
    printf ( "  SSACTIVETANGENT\n" );
  }
  if ( elligible_constraints & SSACTIVEPARALLEL    )
  {
    printf ( "  SSACTIVEPARALLEL\n" );
  }
  if ( elligible_constraints & SSACTIVEPERPEND     )
  {
    printf ( "  SSACTIVEPERPEND\n" );
  }
  if ( elligible_constraints & SSACTIVEINTERSECT   )
  {
    printf ( "  SSACTIVEINTERSECT\n" );
  }
  if ( elligible_constraints & SSACTIVEKEYPOINT    )
  {
    printf ( "  SSACTIVEKEYPOINT\n" );
  }
  if ( elligible_constraints & SSACTIVEONEXELE     )
  {
    printf ( "  SSACTIVEONEXELE\n\n" );
  }

  printf ( "Constraint Text Display is %s.\n", 
           (elligible_constraints & SSTEXTDISPLAYED ) ? "ON" : "OFF" );
}

void SSPrintConstrainType( int ConstraintType )
{
  char *ptype;

  switch ( ConstraintType )
  {
    case SSNONE          : ptype = "SSNONE";          break;
    case SSONELEMENT     : ptype = "SSONELEMENT";     break;
    case SSCENTER        : ptype = "SSCENTER";        break;
    case SSINTERSECT     : ptype = "SSINTERSECT";     break;
    case SSFIRSTPOINT    : ptype = "SSFIRSTPOINT";    break;
    case SSLASTPOINT     : ptype = "SSLASTPOINT";     break;
    case SSKEYPOINT      : ptype = "SSKEYPOINT";      break;
    case SSHORIZONTAL    : ptype = "SSHORIZONTAL";    break;
    case SSVERTICAL      : ptype = "SSVERTICAL";      break;
    case SSPERPENDICULAR : ptype = "SSPERPENDICULAR"; break;
    case SSPARALLEL      : ptype = "SSPARALLEL";      break;
    case SSTANGENT       : ptype = "SSTANGENT";       break;
    case SSMIDPOINT      : ptype = "SSMIDPOINT";      break;
    case SSONXELEMENT    : ptype = "SSONXELEMENT";    break;
    case SSXINTERSECT    : ptype = "SSXINTERSECT";    break;
    case SSHVERTICAL     : ptype = "SSHVERTICAL";     break;
    case SSVHORIZONTAL   : ptype = "SSVHORIZONTAL";   break;
    case SSONHORIZONTAL  : ptype = "SSONHORIZONTAL";  break;
    case SSONVERTICAL    : ptype = "SSONVERTICA";     break;
    case SSONXHORIZONTAL : ptype = "SSONXHORIZONTAL"; break;
    case SSONXVERTICAL   : ptype = "SSONXVERTICAL";   break;
    case SSXTANGENT      : ptype = "SSXTANGENT";      break;
    default              : ptype = "unknown";         break;
  }
    printf( "Constaint type = %s <%d>\n", ptype, ConstraintType );
}

void SSPrintBoreline( pBoreLine )
  struct IGRline *pBoreLine;
{
  printf ( "pBoreLine = 0x%x\n", pBoreLine );

  if ( pBoreLine )
  {
    printf ( "pBoreLine->point1 = 0x%x\n", pBoreLine->point1 );
    if ( pBoreLine->point1 )
    {
      printf ( "pBoreLine->point1 = [%g, %g, %g ]\n", 
                pBoreLine->point1[0],
                pBoreLine->point1[1],
                pBoreLine->point1[2] );
    }

    printf ( "pBoreLine->point2 = 0x%x\n", pBoreLine->point2 );
    if ( pBoreLine->point2 )
    {
      printf ( "pBoreLine->point2 = [%g, %g, %g ]\n", 
                pBoreLine->point2[0],
                pBoreLine->point2[1],
                pBoreLine->point2[2] );
    }
  }
}


void SSPrintObjectList()
{
  int   ndx;
  char *pstr;

  if ( SSnb_objects > 0 )
  {
    printf( "SSObjects table:\n" );
    for (ndx = 0; ndx < SSnb_objects; ndx++)
    {
      switch ( SSObjects[ndx].type )
      {
        case SSLINE    : pstr = "SSLINE"    ; break;
        case SSCIRCLE  : pstr = "SSCIRCLE"  ; break;
        case SSARC     : pstr = "SSARC"     ; break;
        case SSPOINT   : pstr = "SSPOINT"   ; break;
        case SSBSCURVE : pstr = "SSBSCURVE" ; break;
        default        : pstr = "UNKNOWN"   ;
      }
      printf ( "SSObjects [%d] = %s (objid = %d)\n", 
               ndx, 
               pstr,
               SSObjects[ndx].grid.objid );
    }
  }
  else
  {
    printf( "SSObjects table is EMPTY.\n" );
  }
}

void SSPrintVector( label, v )
  char   *label; 
  double *v;
{
  printf ( "%s = { %g, %g, %g }\n", label, v[0], v[1], v[2] );
}


/* 
void SSPrintDispBuff( label, p_buffer )
  char                *label;
  struct DPele_header *p_buffer;
{
  printf ( "  %s->tag   = %d\n", label, p_buffer->tag ); 
  printf ( "  %s->type  = %d\n", label, p_buffer->type ); 
  printf ( "  %s->flags = %d\n", label, p_buffer->flags );           
  printf ( "  %s->range = %g\n", label, p_buffer->range[0] );
  printf ( "  %s->level[0] = %d\n", label, p_buffer->level[0] );
  printf ( " struct IGRdisplay  *dis_att\n" );
  printf ( " union  IGRele_attr ele_spec_att\n" );
  printf ( " union  IGRgeometry geometry\n"        );
  printf ( " struct IGRdisplay  **u_bound_att\n" );
  printf ( " struct IGRdisplay  **v_bound_att\n" );
  printf ( "  %s->u_num_bound_att = %d\n", label, p_buffer->u_num_bound_att );
  printf ( "  %s->v_num_bound_att = %d\n", label, p_buffer->v_num_bound_att );
  printf ( "  %s->u_bound_att_indices = 0x%x\n", label, p_buffer->u_bound_att_indices );
  printf ( "  %s->v_bound_att_indices = 0x%x\n", label, p_buffer->v_bound_att_indices );
  printf ( "  %s->mdenv_info = 0x%x\n", label, p_buffer->mdenv_info );
}
*/
end implementation Root;

