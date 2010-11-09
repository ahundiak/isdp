/*

Name
  SSDispIcon.I

Description
  Code for displaying the various constaint text (from UMS), icons, and other
  visual aids in a view independent manner.

Notes
  Shelley Heard : 06/03/93 Header added
  Scott Walters : 12/22/97 Constrained font selection

 */


class implementation Root;

#include "igrtypedef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "grownmacros.h"
#include "codebug.h"
#include "igrmacros.h"
#include "coplcmac.h"
#include "FI.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "exmacros.h"
#include "comiscmac.h"
#include "dpstruct.h"
#include "coniarray.h"
#include "grmessage.h"
#include "coreadout.h"
#include "codef.h"
#include "msmacros.h"
#include "madef.h"
#include "stdio.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "csmacros.h"
#include "codynmeas.h"
#include "EMdtmacros.h"
#include "msdef.h"
#include "igrdef.h"
#include "bstypes.h"
#include "OMmacros.h"
#include "EMSdatumdef.h"
#include "bserr.h" 
#include "bsconic.h"
#include "SSdef.h"
#include "SS.h"
#include "dpezmac.h"
#include "math.h"
#include "bsvalues.h"

/* prototypes */
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bsint2lns.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "macr3ptco.h"
#include "maptsxfor.h"
#include "marotmx.h"

/**Added for initialization of default Font  **/
#if defined(ENV5)
#define TEXT_FONT       "/usr/ip32/resrc/rfont/drake.10"             // EMS 3
#elif defined(XGL)
#define TEXT_FONT       "Roman.font"    // EMS 3
#elif defined(X11)
#define TEXT_FONT       "-*-courier-medium-o-normal-*-15-*-*-*-*-*-*-*" // EMS 3
#endif

/*
 * To create an equilateral triangle with base = L, the altitude as
 * a function of L = L/2 * tan(60) = l * 0.86602.
 */

#define ALTITUDE_FACTOR    0.86602

#define POS                1
#define NEG               -1

/*
 * SSNUM_PIXELS is the approximate pixel height/width of constrain icons
 */
#define SSNUM_PIXELS      12


static WLfont font_id ;
static int coordsys_font_loaded ;

/*

Name
  SSDispIcon

Abstract
 This routine displays the text and the icon of the specified constraint.
 It is called by the smart sketcher during the dynamics phase to give visual
 feed back. The text is always displayed in the window plane near the
 mouse position.

Synopsis
  int SSDispIcon ( msg, in_points, ConstraintType, DisplayMode, PButton, 
                   XCoordinate, YCoordinate )
  long             *msg            IN  return status / test low order bit only
  double           *in_points      IN  where to display the icon
  int              ConstraintType  IN  ConstraintType icon (see SS.h)
  enum GRdpmode    DisplayMode     IN  The mode to use for display
  struct EX_button *PButton        IN  The window, button, ...
  int              XCoordinate,    IN  X Screen coordinate
                   YCoordinate     IN  Y Screen coordinate

Description

Return Value

  OM_E_ABORT    Constraint type unknown
  OM_S_SUCCESS  if SSXINTERSECT found
  0             otherwise

  This return code scenario is crazy!

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */
int SSDispIcon ( msg, in_points, ConstraintType, DisplayMode, PButton, 
                 XCoordinate, YCoordinate )
/*
 * This routine displays the text and the icon of the specified constraint.
 * It is called by the smart sketcher during the dynamics phase to give visual
 * feed back. The text is always displayed in the window plane near the
 * mouse position.
 */
long             *msg            /* return status                  IN */;
IGRdouble        *in_points      /* where to display the icon      IN */;
int               ConstraintType /* ConstraintType icon (see SS.h) IN */;
enum GRdpmode     DisplayMode    /* The mode to use for display    IN */;
struct EX_button *PButton        /* The window, button, ...        IN */;
int               XCoordinate,
                  YCoordinate    /* Screen coordinates             IN */;
{
  struct IGResbc        *SpecialAttributes;
  struct DPele_header   ElementHeader;
  struct IGRdisplay     DisplayAttributes;
  struct IGRpolyline    PolyLine;
  char                  *Geometry;
  int                   BufferType, s1, s2, i, j, k;
  IGRpoint              dtripts [5];
  struct SSDisplayInfo  *PText;
  long                  LocalStatus, Sts;
  double                VvolVportScale;
  double                DispScale;
  long                  WhichError;
  struct var_list       VarList [2];
  long                  Bytes;
  IGRboolean            dynamics_all_windows;
  IGRlong               bufsize = sizeof( IGRboolean );
  IGRlong               nret;


  /* we must honor the dynamics_all_windows flag */
  gr$get_dynamics_all_windows( msg = msg,
                               sizbuf = &bufsize,
                               buffer = &dynamics_all_windows,
                               nret = &nret );

  /* if valid constraint, set up the text to accompany the icon display */
  switch (ConstraintType) 
  {
    case SSONELEMENT :
    case SSCENTER    :
    case SSINTERSECT :
    case SSFIRSTPOINT:
    case SSLASTPOINT :
    case SSKEYPOINT :
    case SSMIDPOINT :
    case SSPARALLEL  :
    case SSPERPENDICULAR  :
    case SSTANGENT:
    case SSHORIZONTAL  :
    case SSVERTICAL  :
    case SSONXELEMENT  :
    case SSXINTERSECT:
    case SSXTANGENT:
    case SSONHORIZONTAL :
    case SSONVERTICAL :
    case SSONXHORIZONTAL :
    case SSONXVERTICAL :
    case SSCARDINAL90 :
    case SSCARDINAL180 :
    case SSCARDINAL270 :
    {
      if (SStext [ConstraintType].string[0] == NULL )
      {
        ex$message ( msgnumb = SSums_keys[ConstraintType],
                     buff = SStext[ConstraintType].string, 
                     buffer_size = SS_MAX_CONSTR_STRING );
      }
      PText = &SStext[ConstraintType]; 
      break;
    }

    default : 
    {
      return OM_E_ABORT;
    }
  }

  /*
   * Draw text describing constraint if (SSDisplayMode & SSDISPLAY_TEXT)
   */
  /* Now the default font is being intialized -- TR# 119418331 */
  if(!coordsys_font_loaded)
  {
    WLuint16 lscreen_no;

    WLget_window_screen(PButton->window,&lscreen_no);
    WLload_font(lscreen_no,TEXT_FONT,&font_id);
    coordsys_font_loaded = 1;
  }
  WLset_active_font(PButton->window,font_id);

  if (SSDisplayMode)
  {
    /* for now, we use the default font */
    WLset_drawing_mode ( PButton->window, (WL_BASE_NOOP | WL_HILITE_DRAW) );
    WLdraw_text ( PButton->window,
                  XCoordinate + PText->offset [0],
                  YCoordinate + PText->offset [1],
                  PText->string,
                  strlen ( PText->string ) );
  }

  /* default display attributes*/
  DisplayAttributes.color = 0;
  DisplayAttributes.weight = 0;
  DisplayAttributes.style = 0;
  SpecialAttributes = NULL;
  
  /*
   * In order for the icons to display proportional to the view, we need to 
   * determine the scale factor for translating the geometries.  The pixel
   * density for CLIX/SUN/SGI is about 90 to 100 per inch.  We need an
   * appropriate value for the approximate height/width (in pixels) for the
   * icons.
   *
   *   display_scale = SSNUM_PIXELS / view_volume_to_viewport_scale
   * 
   * 25 pixels = about 1/4 inch on the screen; see #define* for SSNUM_PIXELS 
   * above.
   */
  VarList [0].var            = VVOL_VIEWPORT_SCALE;
  VarList [0].var_ptr        = (char*) &VvolVportScale;
  VarList [0].num_bytes      = sizeof ( double );
  VarList [0].bytes_returned = &Bytes;

  VarList [1].var            = END_PARAM;
  VarList [1].var_ptr        = NULL;
  VarList [1].num_bytes      = 0;
  VarList [1].bytes_returned = NULL;

  dp$inq_set_gragad ( msg          = &LocalStatus,
                      osnum        =  PButton->osnum,
                      gragad_objid =  PButton->objid,
                      which_error  = &WhichError,
                      var_list     = &VarList );

  DispScale = SSNUM_PIXELS / VvolVportScale;

  /* 
   * construct the icon's geometry 
   */
  switch (ConstraintType)
  {
    case SSCENTER:
    case SSINTERSECT:
    case SSFIRSTPOINT:
    case SSMIDPOINT:
    case SSLASTPOINT:
    case SSKEYPOINT:
    case SSCARDINAL90 :
    case SSCARDINAL180 :
    case SSCARDINAL270 :
    {
      double DisplayLength;
      
      DisplayLength = DispScale * 0.5;
      for (i=0, s1=1, s2=-1; i<=3; i++, s1=-s1, s2=i>1?1:-1)
        for (j=0; j<=2; j++) 
          dtripts[i][j] = in_points[j] + s1 * DisplayLength * SSRefXaxis[j] +
              s2 * DisplayLength * ALTITUDE_FACTOR * SSRefYaxis[j];
  
      OM_BLOCK_MOVE ( dtripts [0], dtripts [4], sizeof ( IGRpoint ) );
      PolyLine.num_points = 5;
      PolyLine.points = (double *)dtripts;
      BufferType = IGRPY;
      Geometry = (char *)&PolyLine;
    }
    break;
  
    case SSXINTERSECT:
    {
      int                 i, j, LineIndex;
      struct DPele_header line_header;
      double              DisplayLength;
  
      DisplayLength = DispScale * 0.5;
      for (i=0, s1=1, s2=-1; i<=3; i++, s1=-s1, s2=i>1?1:-1)
        for (j=0; j<=2; j++) 
          dtripts[i][j] = in_points[j] + s1 * DisplayLength * SSRefXaxis[j] +
              s2 * DisplayLength * ALTITUDE_FACTOR * SSRefYaxis[j];

      /*
       * First we draw the coincident symbol
       */  
      OM_BLOCK_MOVE ( dtripts [0], dtripts [4], sizeof ( IGRpoint ) );
      PolyLine.num_points = 5;
      PolyLine.points = (double *)dtripts;
      BufferType = IGRPY;
      Geometry = (char *)&PolyLine;

      dp$build_dis_buffer ( buffer = &ElementHeader, 
                            type = BufferType,
                            display_att = &DisplayAttributes,
                            ele_spec_att = SpecialAttributes,
                            geometry = Geometry );
      dp$display ( msg    = msg, 
                   buffer = &ElementHeader, 
                   objid  = PButton->objid,  /* for icon display only */
                   osnum  = PButton->osnum,
                   mode   = DisplayMode );
      for (LineIndex = 0; LineIndex < 2; LineIndex++)
      {
        /*
         * this creates and displays the line 
         */
        PolyLine.num_points = 2;
        PolyLine.points = &in_points [LineIndex ? 9 : 3];
        DisplayAttributes.style = 2;
        dp$build_dis_buffer (buffer = &line_header, type = IGRPY,
            display_att = &DisplayAttributes, geometry = &PolyLine );

        if ( !dynamics_all_windows )
        {
          dp$display (msg    = msg,
                      osnum  = PButton->osnum,
                      objid  = PButton->objid,
                      buffer = &line_header,
                      mode   = DisplayMode);
        }
        else
        {
          dp$display (msg    = msg,
                      buffer = &line_header,
                      mode   = DisplayMode);
        }
        DisplayAttributes.style = 0;
      }
      return OM_S_SUCCESS;
    }
    
    case SSONXELEMENT:
    {
      int                 i, j, n;
      long                one = 1;
      IGRvector           firstvec, rot_firstvec;
      IGRpoint            firstpt, crosspts[5];
      IGRpoint            (*points)[];
      double              ang, rotangle;
      IGRmatrix           rotmat;
      struct DPele_header line_header;
      double              DisplayLength;
  
      /* 
       * this icon needs the line to be the first in the input
       * points.
       */
  
      /*
       * this creates and displays the line 
       */
      PolyLine.num_points = 2;
      PolyLine.points = &in_points [0];
      DisplayAttributes.style = 2;
      dp$build_dis_buffer (buffer = &line_header, type = IGRPY,
          display_att = &DisplayAttributes, geometry = &PolyLine );
      if ( !dynamics_all_windows )
      {
        dp$display (msg    = msg,
                    osnum  = PButton->osnum,
                    objid  = PButton->objid,
                    buffer = &line_header,
                    mode   = DisplayMode);
      }
      else
      {
        dp$display (msg    = msg,
                    buffer = &line_header,
                    mode   = DisplayMode);
      }
      DisplayAttributes.style = 0;

      /*
       * this creates the cross at 45 degrees, displays later
       */
      points = (IGRpoint (*)[])(&in_points [0]);

      for (n=0; n<2; n++)
      {
        /* Compute the 5 points for the cross. */
        for (i=0; i<3; i++)
        {
          firstvec[i] = (* points)[n+1][i] - (* points)[n][i];
          firstpt[i] = (* points)[n][i] + firstvec[i] / 2.0; 
        }

        BSnorvec (&LocalStatus, firstvec);
        if (LocalStatus != BSSUCC)
          for (i=0; i<3; i++)
            firstvec[i] = 0.0;

        for (i=0, j=0, ang=45; i<2; i++, j+=2, ang+=90)
        {
          DisplayLength = DispScale * 0.5;
          rotangle = ang * (M_PI / 180.0);
          MArotmx (&LocalStatus, SSRefPlane.normal, &rotangle, rotmat);
          SSerr_hndlr (LocalStatus, *msg, MSFAIL, wrapup);

          MAptsxform (&LocalStatus, &one, rotmat, firstvec, rot_firstvec);

          SSerr_hndlr (LocalStatus, Sts, OM_E_ABORT, wrapup);

          for (k=0; k<=2; k++)
          {
            crosspts[j][k] = firstpt[k] + DisplayLength * rot_firstvec[k];
            crosspts[j+1][k] = firstpt[k] - DisplayLength * rot_firstvec[k];
          }
        }
        /* making room and inserting a point at the center of the cross */
        OM_BLOCK_MOVE (crosspts[2], crosspts[3], 2 * (sizeof (IGRpoint)));
        for (i = 0; i < 3; i++)
        {
          crosspts[2][i] = 
            crosspts[0][i] - (crosspts[0][i] - crosspts[1][i]) / 2.0;
        }
        PolyLine.num_points = 5;
        PolyLine.points = (double *)crosspts;
        BufferType = IGRPY,
        Geometry = (char *)&PolyLine;
      }

      break;
    }
      
    case SSPARALLEL: 
    {
      double    shift_len, DisplayLength, (*in_pts) [2][2][3];
      int       n;
      long      one = 1;
      IGRpoint  parpts [2][2], midpt;
      IGRvector vec, rot_vec;
   
      shift_len = DispScale * 0.25;
      DisplayLength = DispScale * 0.75;
      in_pts = (double (*) [2][2][3])in_points;
   
      /* comp line vectors and midpoints */
      for (n=0; n<=1; n++)
      {
        for (i=0; i<=2; i++)
        {
          vec[i] = (*in_pts)[n][1][i] - (*in_pts)[n][0][i];
          midpt[i] = (*in_pts)[n][0][i] + vec[i] / 2.0;
        }
   
        /* normalize the line vector */
        BSnorvec (&LocalStatus, vec);
   
        /* rotate it 60 degrees */
        MAptsxform (&LocalStatus, &one, SSRotMat60, vec, rot_vec);
        SSerr_hndlr (LocalStatus, *msg, OM_E_ABORT, wrapup);
 
        for (i=0, s1=NEG; i<=1; i++, s1=POS)
          for (j=0, s2=NEG; j<=1; j++, s2=POS)
            for (k=0; k<=2; k++)
              parpts[i][j][k] = midpt[k] + (s1 * shift_len * vec[k]) + 
                (s2 * DisplayLength * rot_vec[k]);
        PolyLine.num_points = 2;
        for (i=0; i<2; i++)
        {
          PolyLine.points = &parpts[i][0][0];
          dp$build_dis_buffer ( buffer = &ElementHeader, 
                                type = IGRPY,
                                display_att = &DisplayAttributes,
                                geometry = &PolyLine );
          dp$display (msg    = msg, 
                      objid  = PButton->objid,  /* for icon display only */
                      osnum  = PButton->osnum, 
                      buffer = &ElementHeader, 
                      mode   = DisplayMode);
        }
      }
      return 0;
    }

    case SSPERPENDICULAR: 
    {
      struct IGRline *lines [2];
      struct IGRline line1, line2;
      IGRpoint       int_pts_inf[2], PolyLine_points[5];
      double         dist;
      IGRvector      v11x, v12x, v21x, v22x;
      BSrc           bsrc = BSSUCC;
      double         DisplayLength;
      double         DotProduct = 0.0;
        
      DisplayLength = DispScale * 0.5; /* size of the icon */
  
      line1.point1 = &in_points[0];
      line1.point2 = &in_points[3];
      line2.point1 = &in_points[6];
      line2.point2 = &in_points[9];
  
      lines[0] = &line1;
      lines[1] = &line2;
  
      /* find intersection between the infinite lines */
      BSint2lns ( lines, int_pts_inf, &dist, &bsrc);
  
      /* the icon will always start at this point */
      PolyLine.points = PolyLine_points[0];
      OM_BLOCK_MOVE ( &int_pts_inf [0] [0], 
                      &PolyLine.points[0], 
                       sizeof ( IGRpoint ) );
 
      /* vector from 1st and 2nd pts of lines 1 and 2 to intersection point */
      BSmkvec (&bsrc, v11x, line1.point1, int_pts_inf[0]);
      BSmkvec (&bsrc, v12x, line1.point2, int_pts_inf[0]);
      BSmkvec (&bsrc, v21x, line2.point1, int_pts_inf[0]);
      BSmkvec (&bsrc, v22x, line2.point2, int_pts_inf[0]);
      
      DotProduct = BSdotp(&bsrc,v11x,v12x);
      if (DotProduct > 0.0) 
      {
        double points [6];
          
        /* from int. point */
        OM_BLOCK_MOVE (int_pts_inf[0],points,sizeof (IGRpoint));
          
        /* to closest point on the line to the int point */
        if (BSdistptpt ( &bsrc,line1.point1,int_pts_inf[0] ) <=
            BSdistptpt ( &bsrc, line1.point2, int_pts_inf[0] ))
          OM_BLOCK_MOVE ( line1.point1, &points [3],sizeof ( IGRpoint ) );
        else 
          OM_BLOCK_MOVE ( line1.point2, &points [3],sizeof ( IGRpoint ) );
            
        /* save the corner for the icon */
        PolyLine.points = (double *)points;
        PolyLine.num_points = 2;
        DisplayAttributes.style = 2;
  
        dp$build_dis_buffer( buffer = &ElementHeader, 
                             type = IGRPY,
                             display_att = &DisplayAttributes, 
                             geometry = &PolyLine );
        dp$display (msg    = msg, 
                    objid  = PButton->objid,  /* for icon display only */
                    osnum  = PButton->osnum,
                    buffer = &ElementHeader, 
                    mode   = DisplayMode);
      }

      DotProduct = BSdotp(&bsrc,v21x,v22x);
      if (DotProduct > 0.0) 
      { 
        /* then draw_leg2 = true;*/
        IGRpoint points[2];
        
        OM_BLOCK_MOVE (int_pts_inf[0],points[0],sizeof (IGRpoint));
        if (BSdistptpt(&bsrc,line2.point1,int_pts_inf[0]) <=
            BSdistptpt (&bsrc, line2.point2, int_pts_inf[0]))
          OM_BLOCK_MOVE (line2.point1,points[1],sizeof (IGRpoint));
        else 
          OM_BLOCK_MOVE (line2.point2,points[1],sizeof (IGRpoint));
          
        PolyLine.points = (double *)points;
        PolyLine.num_points = 2;
        DisplayAttributes.style = 2;

        dp$build_dis_buffer( buffer = &ElementHeader, 
                             type = IGRPY,
                             display_att = &DisplayAttributes, 
                             geometry = &PolyLine );
                             
        dp$display( msg    = msg, 
                    buffer = &ElementHeader, 
                    objid  =  PButton->objid,  /* for icon display only */
                    osnum  =  PButton->osnum,
                    mode   = DisplayMode);
      }
        
      /* create the icon itself (the square) */
      OM_BLOCK_MOVE (int_pts_inf[0], &PolyLine.points[0], sizeof (IGRpoint));
  
      BSnorvec(&bsrc,v11x);
      
      /* 
       * in case the starting point of the line being placed is on
       * the line we are perpendicular to 
       */
      if (v21x[0] == v21x[1] == v21x[2] == 0)
        BSmkvec (&bsrc, v21x, line2.point1, line2.point2);
      BSnorvec(&bsrc,v21x);

      for (i=0; i<3; i++) 
        PolyLine.points[3+i] = int_pts_inf[0][i] - DisplayLength * v11x[i];

      for (i=0; i<3; i++)
        PolyLine.points[6+i] = PolyLine.points[3+i] - DisplayLength * v21x[i];

      for (i=0; i<3; i++)
        PolyLine.points[9+i] = int_pts_inf[0][i] - DisplayLength * v21x[i];

      OM_BLOCK_MOVE (int_pts_inf[0],&PolyLine.points[12], sizeof (IGRpoint));
      PolyLine.num_points = 5;
      Geometry = (char *)(&PolyLine);
      BufferType = IGRPY;
      DisplayAttributes.style = 0;

      break;
    }
      
    case SSONELEMENT: 
    {
      /* 
       * This draws the inner circle, it is essentially the same as the
       * next case (SSTANGENT), the radius is the only thing different. Need
       * to find a way to do it more efficiently if we decide to keep it 
       */
      double              *vptr;
      int                 sign;
      double              cirwts [BSCIRCLE_NUM_POLES_MAX];
      double              cirkts [BSCIRCLE_NUM_KNOTS_MAX];
      IGRpoint            cirpls [BSCIRCLE_NUM_POLES_MAX];
      IGRpoint            cir_pts [3];
      struct IGRbsp_curve cv;
      double              DisplayLength;
        
      DisplayLength = DispScale * 0.333;
  
      for (i=0; i<=2; i++) 
      {
        vptr = !(i % 2) ? SSRefXaxis : SSRefYaxis;
        sign = i == 2 ? -1 : 1;
        for (j=0; j<=2; j++)
          cir_pts[i][j] = in_points[j] + (sign * DisplayLength * vptr[j]);
      }
      
      cv.poles = (double *) cirpls;
      cv.knots = (double *) cirkts;
      cv.weights = (double *) cirwts;
      MAcr3ptconstr (&LocalStatus, (double *)cir_pts, &cv);
      if (LocalStatus&1)
      {
        struct IGResbc spec_att;
        spec_att.is_polydis = FALSE;
        spec_att.is_curvedis = TRUE;
        SpecialAttributes = &spec_att;
        BufferType = IGRBC;
        Geometry = (char *)(&cv);
        dp$build_dis_buffer ( buffer = &ElementHeader, 
            type = BufferType, display_att = &DisplayAttributes, 
            ele_spec_att = SpecialAttributes, geometry = Geometry );
        dp$display ( msg    = msg, 
                     buffer = &ElementHeader, 
                     objid  = PButton->objid,  /* for icon display only */
                     osnum  = PButton->osnum,
                     mode   = DisplayMode );
      }
      else
      {
        return 0;
      }
    }
    
    /* 
     * no break on purpose. The following case draws the outter 
     * circle
     */
    case SSTANGENT: 
    case SSXTANGENT: 
    {
      double              *vptr;
      int                 sign;
      double              cirwts[BSCIRCLE_NUM_POLES_MAX];
      double              cirkts[BSCIRCLE_NUM_KNOTS_MAX];
      IGRpoint            cirpls[BSCIRCLE_NUM_POLES_MAX];
      IGRpoint            cir_pts[3];
      struct IGRbsp_curve cv;
      double              DisplayLength;
      struct DPele_header line_header;
      
      if (ConstraintType == SSXTANGENT)
      {
        double Points [6];
        
        /*
         * We draw a line segment from the current mouse position to 
         * in_points [0,1,2]
         */
        memcpy ( Points, in_points, 3 * sizeof ( double ) );
        Points [3] = PButton->x;
        Points [4] = PButton->y;
        Points [5] = PButton->z;
        PolyLine.num_points = 2;
        PolyLine.points = Points;
        DisplayAttributes.style = 2;
        dp$build_dis_buffer ( buffer = &line_header, type = IGRPY,
          display_att = &DisplayAttributes, geometry = &PolyLine );

        if ( !dynamics_all_windows )
        {
          dp$display (msg    = msg,
                      osnum  = PButton->osnum,
                      objid  = PButton->objid,
                      buffer = &line_header,
                      mode   = DisplayMode);
        }
        else
        {
          dp$display (msg    = msg,
                      buffer = &line_header,
                      mode   = DisplayMode);
        }
        DisplayAttributes.style = 0;
      }

      DisplayLength = DispScale * 0.50;

      for (i=0; i<=2; i++) 
      {
        vptr = !(i % 2) ? SSRefXaxis : SSRefYaxis;
        sign = i == 2 ? -1 : 1;
        for (j=0; j<=2; j++)
          cir_pts[i][j] = in_points[j] + (sign * DisplayLength * vptr[j]);
      }
      
      cv.poles = (double *) cirpls;
      cv.knots = (double *) cirkts;
      cv.weights = (double *) cirwts;
      MAcr3ptconstr (&LocalStatus, (double *)cir_pts, &cv);

      if ((LocalStatus&1))
      {
        struct IGResbc spec_att;
        spec_att.is_polydis = FALSE;
        spec_att.is_curvedis = TRUE;
        SpecialAttributes = &spec_att;
        BufferType = IGRBC;
        Geometry = (char *)(&cv);
      }
      else
      {
        return 0;
      }
      break;
    }
      
    case SSHORIZONTAL:
    case SSVERTICAL: 
    {
      struct DPele_header line_header;
      IGRpoint anchorpt;
      short    i,j,k;
      double  *curr_vec;
      double PolyLine_points[15];
      double DisplayLength;
  
      for (i=0; i<3; i++)
        anchorpt[i] = in_points[i] + (in_points[3+i] - in_points[i]) / 2.0;

      /* 
       * this creates and displays the line 
       */
      PolyLine.num_points = 2;
      PolyLine.points = &in_points [0];
      DisplayAttributes.style = 2;
      dp$build_dis_buffer (buffer = &line_header, type = IGRPY,
          display_att = &DisplayAttributes, geometry = &PolyLine );
      if ( !dynamics_all_windows )
      {
        dp$display (msg    = msg,
                    osnum  = PButton->osnum,
                    objid  = PButton->objid,
                    buffer = &line_header,
                    mode   = DisplayMode);
      }
      else
      {
        dp$display (msg    = msg,
                    buffer = &line_header,
                    mode   = DisplayMode);
      }
      DisplayAttributes.style = 0;

      /* 
       * this creates the cross (it displays later) 
       */
      DisplayLength = DispScale * 0.5;
      PolyLine.num_points = 5;
      PolyLine.points = PolyLine_points;
      for (i=0, j=0; i<=1; i++, j+=2) 
      {
        curr_vec = i == 0 ? SSRefXaxis : SSRefYaxis;
        for (k=0; k<=2; k++) 
        {
          if (j == 2) 
          {
            PolyLine.points[6] = anchorpt[0]; /* place center point */
            PolyLine.points[7] = anchorpt[1];
            PolyLine.points[8] = anchorpt[2];
            j++;
          } /* place 4 points at ends of the cross */

          PolyLine.points[3*j+k] = anchorpt[k] + DisplayLength * curr_vec[k];
          PolyLine.points[3*(j+1)+k] = anchorpt[k]-DisplayLength*curr_vec[k];
        }
      }
      
      /* the following used for building buffer and find range */
      BufferType = IGRPY;
      Geometry = (char *)&PolyLine;

      break;
    }
      
    default:
    {
      return 0;
    }
  } /* end of switch on ConstraintType */

  /* this is used for those cases where a single icon is drawn */
  dp$build_dis_buffer ( buffer = &ElementHeader, type = BufferType,
      display_att = &DisplayAttributes, ele_spec_att = SpecialAttributes,
      geometry = Geometry );

  dp$display ( msg    = msg, 
               buffer = &ElementHeader, 
               objid  = PButton->objid,  /* for icon display only */
               osnum  = PButton->osnum,
               mode   = DisplayMode );

wrapup:
  return 0;
}

end implementation Root;
