/* $Id: VDSpti.I,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpoint / VDSpti.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSpti.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1995/10/31  15:51:02  pinnacle
# Replaced: vdpoint/VDSpti.I for:  by yzhu for vds.240
#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      10/25/95        tlb             EMS 3.2: changed cs.h to grcoordsys.h
 *      10/26/95        yzhu            comment print
 *
 * -------------------------------------------------------------------*/

/*
ABSTRACT : 


CHANGE HISTORY
	
     Ch       6 Feb 92  : Design date
     Mallik   8 Jan 94  : Modified the Env 5 Calls
     tlb      3 Mar 94  : change call to WLdraw_text to vd$WLdraw_text
     yz       18 Oct 95  : vd$WLdraw_text only print error message when
                           AS_DEBUG is defined

*/

class implementation VDSpt;

#include "OMmacros.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "bserr.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "parametric.h"
#include "VDSutil_def.h"
#include "vdsmacros.h"
#include "AS_status.h"
#include "wl.h"
#include "VDWLmacros.h"

/* #define  AS_DEBUG */ 

#define TXT    0x0001
#define PLN    0x0002

#define SZ_PLANE 10
#define EPSILON  10e-05

/* Forward declaration : To be remove when prototype file construct */
int VDDrawPt
(
IGRlong               *msg,
IGRshort              *mx_type,
IGRmatrix              matrix,
enum GRdpmode         *mode,
struct IGRaltdisplay  *alt_symb,
struct DP_information *sp_info,
OM_p_KEY_DESC          range_key,
struct GRid	       my_grid,
char		      *name,
struct IGRdisplay     *display_att,
short		       my_props,
short		       x_offset,
short                  y_offset
);


method GRdisyourself(IGRlong *msg; IGRshort *mx_type; IGRmatrix
                        matrix;  enum GRdpmode *mode;
			struct IGRaltdisplay *alt_symb;
			struct DP_information *sp_info;
                        OM_p_KEY_DESC range_key)
{
 IGRlong 	status;
 IGRshort	my_props;

 /*| Get the props	*/
 status = om$send(msg = message VDSpt.VDgetprops(&my_props),
                     targetid = my_id);
      as$status(action = RET_STATUS);
 if(!(my_props & VD_NO_DISP_PT))
  {
   /*| Send back the message to GRgraphics */
   status = om$send(msg = message GR3dpoint.GRdisyourself( msg, mx_type,
				   matrix, mode, alt_symb, sp_info, range_key),
			  mode = OM_e_wrt_message,
			  targetid = my_id);
   as$status(action = RET_STATUS);
  }
   
   /*| Send the message to do the special display */
   status = om$send(msg = message VDSpt.VDdisyourself( msg, mx_type,
				   matrix, mode, alt_symb, sp_info, range_key),
  			  targetid = my_id);
   as$status(action = RET_STATUS);


 *msg = MSSUCC;
 return(status);
}

/***************************************************************************/
/*
 * Override this message to avoid setting this object in the Display List.
 */

method GRadd_to_display_list( IGRlong *msg; IGRboolean is_hidden_line )
{
 *msg = MSFAIL;
 is_hidden_line = FALSE;

 return(OM_E_ERROR);
}


/***************************************************************************/

method VDsetprops(short props)
{
 me->my_props = props;
 return OM_S_SUCCESS;
}

/***************************************************************************/

method VDgetprops(short *props)
{
 *props = me->my_props;
 return OM_S_SUCCESS;
}

/***************************************************************************/

method VDchgprops(short mask, props)
{
 me->my_props = (me->my_props & ~mask) | (props & mask);
 return OM_S_SUCCESS;
}

/***************************************************************************/

method VDsetoffset(short x, y)
{
 me->x_offset = x;
 me->y_offset = y;
 return OM_S_SUCCESS;
}

/***************************************************************************/

method VDgetoffset(short *x, *y)
{
 *x = me->x_offset;
 *y = me->y_offset;
 return OM_S_SUCCESS;
}

/***************************************************************************/

method VDsettext( char *text)
{
 int txt_sz, status;

 if(text==NULL) 
  {
   /*| Clear if there is an existing text */
   if(om$dimension_of(varray=ME.VDSpt->vd_text) > 0) 
    {
     /* As to be done better, Clear the space */
     strcpy(ME.VDSpt->vd_text,"");
    }
   return(OM_S_SUCCESS);
  }  

 txt_sz = strlen(text) + 1;
 if(txt_sz <=1) return(OM_S_SUCCESS);

 if(om$dimension_of(varray=ME.VDSpt->vd_text) < txt_sz)
  {
   /*| Alloc the internal instance */
   status = om$vla_set_dimension(varray=ME.VDSpt->vd_text, size = txt_sz);
   as$status(action = RET_STATUS);
  }

 /*" Store the text: %s\n", text */
 strcpy(ME.VDSpt->vd_text,text);

 return(OM_S_SUCCESS);
}


/***************************************************************************/
method VDgettext( char *text; short size)
{

 if(size < 2) return OM_W_ABORT;

 if(om$dimension_of(varray=ME.VDSpt->vd_text) <= 0) 
  {
   text[0] = '\0';
  }
 else
  {
   strncpy(ME.VDSpt->vd_text, text, size-1);
   text[size-1] = '\0';
  }
   
 return(OM_S_SUCCESS);
}


/***************************************************************************/

method VDinitinst()
{
 me->my_props = 0;
 me->x_offset = 0;
 me->y_offset = 0;

 return(OM_S_SUCCESS);
}


/***************************************************************************/


method VDdisyourself(IGRlong *msg; IGRshort *mx_type; IGRmatrix
                        matrix;  enum GRdpmode *mode;
			struct IGRaltdisplay *alt_symb;
			struct DP_information *sp_info;
                        OM_p_KEY_DESC range_key)
{
 long 		status;
 struct GRid	my_grid;
 short		my_props;
 short		x_offset, y_offset;
 extern IGRboolean ASbroadcast_in_progress;
  
 if ( ((me->properties & GRIS_DISPLAYABLE)  || (*mode == GRhdo) || 
	  (*mode == GRhhdo) || (*mode == GRheo) ||
         (*mode == GRbdheo) || (*mode == GRbeheo) )
	&& (DPlevel_on(me->level,sp_info)))
    {
      my_grid.objid = my_id;
      my_grid.osnum = OM_Gw_current_OS;

      /*| Get the props	*/
      status = om$send(msg = message VDSpt.VDgetprops(&my_props),
                     targetid = my_id);
      as$status(action = RET_STATUS);

      if(my_props & VD_NO_DISP_TXT)
       {
        /* No text display .. */
  	*msg = MSSUCC;
 	return(OM_S_SUCCESS);
       }
      
      status = om$send(msg = message VDSpt.VDgetoffset( &x_offset, &y_offset),
                     targetid = my_id);
      as$status(action = RET_STATUS);
      

      /*| Get the name of the rigid owner (if existing) */
      VDDrawPt (msg, mx_type, matrix, mode, alt_symb, sp_info, range_key, 
	       my_grid, ME.VDSpt->vd_text, &(me->display_attr), my_props,
	       x_offset, y_offset);
    }
 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
int VDDrawPt
(
IGRlong               *msg,
IGRshort              *mx_type,
IGRmatrix              matrix,
enum GRdpmode         *mode,
struct IGRaltdisplay  *alt_symb,
struct DP_information *sp_info,
OM_p_KEY_DESC          range_key,
struct GRid	       my_grid,
char		      *name,
struct IGRdisplay     *display_att,
short		       my_props,
short		       x_offset,
short                  y_offset
)
{
IGRlong             i;                  /* index */
IGRlong             sts, status;        /* return code */
IGRdouble           triad_coords[21];   /* triad legs in coords */
struct IGRpolyline  polyline;           /* triad legs */
/* extern IGRint 	CSfont_descr; */
IGRint		action;
IGRshort	go_mat_type;
IGRdouble	go_mat[16];
IGRdouble	pt0[3];

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

 /*
  *  get the local_to_world matrix -- multiply input matrix and
  *  instance data local-to-world matrix
  */

  GRabsg_del_all();

  /*| Get the matrix of the cs */
  go_mat_type = MAIDMX;   /* KLUDGE TO CHANGE but It seems working, so ... */
  action = 1;
  polyline.points = pt0;
  status=om$send(msg=message GR3dpoint.GRgetpolyline(msg, &go_mat_type, go_mat,
					&action, &polyline),
		     senderid = NULL_OBJID,
                     targetid = my_grid.objid,
                     targetos = my_grid.osnum);
  as$status(action = RET_STATUS);


  for(i=0;i<3;i++)
   {
    triad_coords[i] = polyline.points[i]; 
   }
  
  i = 1;
  /*| transform to the view coordinates */
  MAptsxform (msg, &i, matrix, triad_coords, triad_coords);

    /* 
     *  output the axis labels and the name of the coordinate system
     *
     *  NOTE:   This is done using the Environ V tools directly, ‚since
     *          view- and scale-independent text is not available.  This
     *          happens to work okay since drawing the triad through IGE
     *          leaves everything set up properly.
     */


  if(name != NULL)
   {
    IGRshort  dx, dy;
    IGRshort  x_size_char, y_size_char;


    /*
     *  transform the triad from world to screen coordinates
     */

    i = 1;
    MAptsxform (msg, &i, sp_info->gragad->wld_to_viewport, 
                    triad_coords, triad_coords);

    x_size_char = 9;
    y_size_char = 8;

    i = strlen(name);

    /* dx =  8;
    /* dy = -5;
    /* */
    /* Compute the orientation */
    if     (my_props & VD_X_POS) dx = x_size_char;
    else if(my_props & VD_X_NEG) dx = -(i + 1) * x_size_char;
    else		         dx = -(i * x_size_char)/2;

    if     (my_props & VD_Y_POS) dy = - 2 * y_size_char;
    else if(my_props & VD_Y_NEG) dy =  y_size_char/2;
    else		         dy = -y_size_char/2;
    
    /* Add picel offset */
    dx = dx + x_offset;
    dy = dy + y_offset;

    if(i>0)
        {
	vd$WLdraw_text ( win_no = (WLuint32) sp_info->win_no,
		      x = (int)triad_coords[0]  +dx,
		      y = (int)triad_coords[0+1]+dy,
		      text = name,
		      len = i,
		      sts = msg );
	if (*msg != WL_SUCCESS) {
                #ifdef AS_DEBUG
		printf ("WLdraw_text failed: status = %d\tlabel = %s\n", 
								*msg, name);
                #endif
		}
        }
	WLflush( (WLuint32) sp_info->win_no );
   }
 sts = OM_S_SUCCESS;

return (sts);
}


/*   VDcnst_pt:
/*
/*   See vdsmacros.h for explanation 
/* */

int VDCnstPt
(
IGRlong			*msg,	   /* return code *msg = 1 SUCCESS     	     */
double			*pt,	   /* point coord. (I)			     */
char			*name,	   /* name to display (NULL => no text       */
short			x_offset,  /*  x offset		                     */
short                   y_offset,  /*  y offset		                     */
struct GRid		*pt_obj,   /* Identifier of the constructed plane (O)*/
short			 props,	   /* properties			     */
struct GRvg_construct   *cst       /* the construction list		     */
)
{
IGRint		 	status;
extern GRclassid 	OPP_VDSpt_class_id;
struct IGRpolyline	geom;

 *msg = MSFAIL;

/* ---  define the  normal to the plane (given by axe)--- */
/* define 2 pts of the plan : origine of coord sys + dist on axe */

   cst->geometry    = (IGRchar *) &geom;
   geom.num_points  = 1;
   geom.points      = pt;

   pt_obj->osnum = cst->env_info->md_id.osnum;
   pt_obj->objid = NULL_OBJID;

   cst->properties  = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;
   cst->display->weight += 3;

   status = om$construct(classid = OPP_VDSpt_class_id,
			 osnum   = pt_obj->osnum,
			 p_objid = &pt_obj->objid,
			 msg     = message GRgraphics.GRaltconstruct(cst));
   cst->display->weight -= 3;
   as$status(action = RET_STATUS);
   /*" obj created: %d, %d\n", obj->objid, obj->osnum */

   /* Initialize the object */
   status = om$send(msg = message VDSpt.VDinitinst(),
		        senderid = NULL_OBJID,
 			targetid = pt_obj->objid,
 			targetos = pt_obj->osnum);
   as$status(action = RET_STATUS);

 
   /*| Set the name to be the parameter if existe */
   status = om$send(msg      = message VDSpt.VDsettext(name),
		        senderid = NULL_OBJID,
        	        targetid = pt_obj->objid,
 	                targetos = pt_obj->osnum);
   as$status(action=RET_STATUS);

   /*| Set the properties */
   status = om$send(msg      = message VDSpt.VDsetprops(props),
		        senderid = NULL_OBJID,
        	        targetid = pt_obj->objid,
 	                targetos = pt_obj->osnum);
   as$status(action=RET_STATUS);

   status = om$send(msg      = message VDSpt.VDsetoffset(x_offset, y_offset),
		        senderid = NULL_OBJID,
        	        targetid = pt_obj->objid,
 	                targetos = pt_obj->osnum);
   as$status(action=RET_STATUS);

  /* "pt_obj: %d, %d\n",pt_obj->objid,pt_obj->osnum */

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


end implementation VDSpt;
