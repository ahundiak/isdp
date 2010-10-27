/* $Id: pp.I,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpoint / pp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: pp.I,v $
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
int VDDrawPt(msg, mx_type, matrix, mode, alt_symb, sp_info, range_key, my_grid,
            name, display_att, my_props, x_offset, y_offset)
IGRlong               *msg;
IGRshort              *mx_type;
IGRmatrix              matrix;
enum GRdpmode         *mode;
struct IGRaltdisplay  *alt_symb;
struct DP_information *sp_info;
OM_p_KEY_DESC          range_key;
struct GRid	       my_grid;
char		      *name;
struct IGRdisplay     *display_att;
short		       my_props;
short		       x_offset, y_offset;
{
IGRlong             i;                  /* index */
IGRlong             sts, status;        /* return code */
IGRdouble           triad_coords[21];   /* triad legs in coords */
struct IGRpolyline  polyline;           /* triad legs */
extern IGRint 	CSfont_descr;
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
         drawsymbols ((short) sp_info->win_no, CSfont_descr,
                         (short) triad_coords[0]  +dx,
                         (short) triad_coords[0+1]+dy, name, i);
        }
    flushbuffer ((short) sp_info->win_no);
   }
 sts = OM_S_SUCCESS;

return (sts);
}

/*   VDcnst_pt:
/*
/*   See vdsmacros.h for explanation 
/* */

int VDCnstPt(msg, pt, name, x_offset, y_offset, pt_obj, props, cst)
IGRlong			*msg;	   /* return code *msg = 1 SUCCESS     	     */
double			*pt;	   /* point coord. (I)			     */
char			*name;	   /* name to display (NULL => no text       */
short			x_offset, y_offset;   /* x, y offset		     */
struct GRid		*pt_obj;   /* Identifier of the constructed plane (O)*/
short			 props;	   /* properties			     */
struct GRvg_construct   *cst;      /* the construction list		     */
/*.VDcnst_pln*/
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


