class implementation ASfieldpt;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "AS_status.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "fontdef.h"
#include "font.h"
#include "asbox.h"
#include "gotextdef.h"
#include "gotext.h"
#include "msmacros.h"
#include "ASmsg.h"

#define AS_DEBUG 

extern GRclassid OPP_GR3dpoint_class_id;

from GRtext
  import
  GRgettxattr,
  GRfield_inquire;

#define  RATIO        0.31      /* ratio of space on and under the text       */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                   INTERNAL function AStext_pt_eval                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

AStext_pt_eval(p_text_attr, p_dx, p_dy, justif, p_textdef, abs_point)

  struct IGRestx    *p_text_attr;/* IN     Attributes of the text             */
  IGRdouble         *p_dx;       /* IN     Offset along X axis                */
  IGRdouble         *p_dy;       /* IN     Offset along Y axis                */
  IGRshort          justif;      /* IN     Justification of the field         */
  struct ret_struct *p_textdef;  /* IN     Definition of the text             */
  IGRdouble         *abs_point;  /* OUT    Aboslute point of the field        */
  /*.AStext_pt_eval*/
  {
  IGRdouble point[4];            /* Tempory point for compute                 */
  IGRlong       msg;             /* Status returned by a message              */
  IGRshort i=3,j=4,k=1;          /* Dimensions for the matrix product         */

  switch(justif)
    {
    case LEFT_BOTTOM:
    point[0]=p_textdef->var.lb_st.diag_pt1[0];
    point[1]=p_textdef->var.lb_st.diag_pt1[1];
    break;

    case LEFT_BASE:
    point[0]=p_textdef->var.lb_st.diag_pt1[0];
    point[1]=p_textdef->var.lb_st.diag_pt1[1]+RATIO*p_text_attr->height;
    break;

    case LEFT_CENTER:
    point[0]=p_textdef->var.lb_st.diag_pt1[0];
    point[1]=(p_textdef->var.lb_st.diag_pt1[1]+p_textdef->var.lb_st.diag_pt2[1])/2.;
    break;

    case LEFT_CAP:
    point[0]=p_textdef->var.lb_st.diag_pt1[0];
    point[1]=p_textdef->var.lb_st.diag_pt2[1]-RATIO*p_text_attr->height;
    break;

    case LEFT_TOP:
    point[0]=p_textdef->var.lb_st.diag_pt1[0];
    point[1]=p_textdef->var.lb_st.diag_pt2[1];
    break;

    case CENTER_BOTTOM:
    point[0]=(p_textdef->var.lb_st.diag_pt1[0]+p_textdef->var.lb_st.diag_pt2[0])/2.;
    point[1]=p_textdef->var.lb_st.diag_pt1[1];
    break;

    case CENTER_BASE:
    point[0]=(p_textdef->var.lb_st.diag_pt1[0]+p_textdef->var.lb_st.diag_pt2[0])/2.;
    point[1]=p_textdef->var.lb_st.diag_pt1[1]+RATIO*p_text_attr->height;
    break;

    case CENTER_CENTER:
    point[0]=(p_textdef->var.lb_st.diag_pt1[0]+p_textdef->var.lb_st.diag_pt2[0])/2.;
    point[1]=(p_textdef->var.lb_st.diag_pt1[1]+p_textdef->var.lb_st.diag_pt2[1])/2.;
    break;

    case CENTER_CAP:
    point[0]=(p_textdef->var.lb_st.diag_pt1[0]+p_textdef->var.lb_st.diag_pt2[0])/2.;
    point[1]=p_textdef->var.lb_st.diag_pt2[1]-RATIO*p_text_attr->height;
    break;

    case CENTER_TOP:
    point[0]=(p_textdef->var.lb_st.diag_pt1[0]+p_textdef->var.lb_st.diag_pt2[0])/2.;
    point[1]=p_textdef->var.lb_st.diag_pt2[1];
    break;

    case RIGHT_BOTTOM:
    point[0]=p_textdef->var.lb_st.diag_pt2[0];
    point[1]=p_textdef->var.lb_st.diag_pt1[1];
    break;

    case RIGHT_BASE:
    point[0]=p_textdef->var.lb_st.diag_pt2[0];
    point[1]=p_textdef->var.lb_st.diag_pt1[1]+RATIO*p_text_attr->height;
    break;

    case RIGHT_CENTER:
    point[0]=p_textdef->var.lb_st.diag_pt2[0];
    point[1]=(p_textdef->var.lb_st.diag_pt1[1]+p_textdef->var.lb_st.diag_pt2[1])/2.;
    break;

    case RIGHT_CAP:
    point[0]=p_textdef->var.lb_st.diag_pt2[0];
    point[1]=p_textdef->var.lb_st.diag_pt2[1]-RATIO*p_text_attr->height;
    break;

    case RIGHT_TOP:
    point[0]=p_textdef->var.lb_st.diag_pt2[0];
    point[1]=p_textdef->var.lb_st.diag_pt2[1];
    break;
  }/* end switch */

  point[0]+= (*p_dx) * p_text_attr->width;
  point[1]+= (*p_dy) * p_text_attr->height;
  point[2]=p_textdef->var.lb_st.diag_pt1[2];
  point[3] = 1.;

  MAmulmx(&msg,&i,&j,&k,p_textdef->var.lb_st.matrix,point,abs_point);

  return( 1 );
}/* end AStext_pt_eval */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                  INTERNAL function ASfield_pt_eval                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

ASfield_pt_eval(p_justif_pts, p_text_attr, p_dx, p_dy, p_extent, justif, p_textdef, abs_point)
  
  struct just_pts *p_justif_pts; /* Justification points of the field         */
  struct IGRestx  *p_text_attr;  /* IN     Attributes of the text             */
  IGRdouble       *p_dx;         /* IN     Offset along X axis                */
  IGRdouble       *p_dy;         /* IN     Offset along Y axis                */
  struct extents  *p_extent;     /* IN     Extents of the text                       */
  IGRshort        justif;        /* IN     Justification of the field         */
  struct ret_struct *p_textdef;  /* IN     Definition of the text             */
  IGRdouble        *abs_point;   /* OUT    Aboslute point of the field        */
  /*.ASfield_pt_eval*/
  {
  IGRdouble point[4];            /* Tempory point for compute                 */
  IGRlong       msg;             /* Status returned by a message              */
  IGRshort i=3,j=4,k=1;          /* Dimensions for the matrix product         */
  IGRmatrix     mat;             /* Tempory matrix for compute                */

  /*"justif = %d\n",justif*/

  ASmake_ref(p_justif_pts->left_bottom,p_justif_pts->right_bottom,p_justif_pts->left_top,mat);

  (p_extent->right)-=p_extent->left;
  (p_extent->top)-=p_extent->bottom;
  (p_extent->cap)-=p_extent->bottom;
  (p_extent->base)-=p_extent->bottom;
  p_extent->left=0;
  p_extent->bottom=0;

  switch(justif)
    {
    case LEFT_BOTTOM:
    point[0]=p_extent->left;
    point[1]=p_extent->bottom;
    break;
  
    case LEFT_BASE:
    point[0]=p_extent->left;
    point[1]=p_extent->base;
    break;
  
    case LEFT_CENTER:
    point[0]=p_extent->left;
    point[1]=(p_extent->top+p_extent->bottom)/2.;
    break;
  
    case LEFT_CAP:
    point[0]=p_extent->left;
    point[1]=p_extent->cap;
    break;
  
    case LEFT_TOP:
    point[0]=p_extent->left;
    point[1]=p_extent->top;
    break;
  
    case CENTER_BOTTOM:
    point[0]=(p_extent->left + p_extent->right)/2.;
    point[1]=p_extent->bottom;
    break;
  
    case CENTER_BASE:
    point[0]=(p_extent->left + p_extent->right)/2.;
    point[1]=p_extent->base;
    break;
  
    case CENTER_CENTER:
    point[0]=(p_extent->left + p_extent->right)/2.;
    point[1]=(p_extent->top+p_extent->bottom)/2.;
    break;
  
    case CENTER_CAP:
    point[0]=(p_extent->left + p_extent->right)/2.;
    point[1]=p_extent->cap;
    break;
  
    case CENTER_TOP:
    point[0]=(p_extent->left + p_extent->right)/2.;
    point[1]=p_extent->top;
    break;
  
    case RIGHT_BOTTOM:
    point[0]=p_extent->right;
    point[1]=p_extent->bottom;
    break;
  
    case RIGHT_BASE:
    point[0]=p_extent->right;
    point[1]=p_extent->base;
    break;
  
    case RIGHT_CENTER:
    point[0]=p_extent->right;
    point[1]=(p_extent->top+p_extent->bottom)/2.;
    break;
  
    case RIGHT_CAP:
    point[0]=p_extent->right;
    point[1]=p_extent->cap;
    break;
  
    case RIGHT_TOP:
    point[0]=p_extent->right;
    point[1]=p_extent->top;
    break;
  }/* end switch */

  point[0]+= (*p_dx) * p_text_attr->width;
  point[1]+= (*p_dy) * p_text_attr->height;
  point[2]= p_textdef->var.lb_st.diag_pt1[2];
  point[3] = 1.;

  MAmulmx(&msg,&i,&j,&k,mat,point,abs_point);
  return(TRUE);
}/* end ASfield_pt_eval */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           method  NDplace                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#define NUM_PARENT   1           /* Number of parents of the object           */

method NDplace 
  (
  struct GRas *asso_lis;         /* IN/OUT Information about the associativity*/
  struct GRmd_env *md_env;       /* IN     Information about the environment  */
  IGRchar *go_cnst_lis           /* IN/OUT Information about the graphic obj  */
  )
  {
  struct GRid   go_text;         /* Graphic object of the text                */
  IGRshort      mat_type;        /* Matrix type of the graphic object         */
  IGRmatrix     matrix;          /* Matrix of the graphic object              */
  IGRlong       status;          /* Status returned by OM                     */
  IGRlong       msg;             /* Status returned by a message              */
  IGRshort      field_length;    /* Length of the field                       */
  IGRuchar *text_contents;       /* Contents of the text                      */
  GRrange       range;           /* Range of the field                        */
  struct   IGRpolyline geom;     /* Geometry of the point                     */
  struct   just_pts justif_pts;  /* Justification points of the field         */
  IGRuchar  attribute;           /* Attribute of the text                     */
  struct   extents  extent;      /* Extents of the text                       */
  IGRdouble     abs_point[4];    /* Absolute coordinates of the field point   */
  struct   ret_struct textdef;   /* Definition of the text                    */
  struct   IGRestx    text_attr; /* Attributes of the text                    */
  IGRshort      num_char;        /* Number of escape codes to search for      */
  IGRchar       esc_char[4];     /* Char to be search for follow. the esc char*/
  IGRuchar *esc_num[4];          /* Array for numbers after esc sequences     */
  IGRshort      start_index;     /* Number of escape codes to search for      */
  IGRshort      beg_esc;         /* Number of escape codes to search for      */
  struct vfont_entry font_info;


  /*" Get the graphic object of %d,%d\n",asso_lis->parents->objid,asso_lis->parents->osnum */

  status = om$send
             (msg      = message NDnode.ASreturn_go(&go_text,&mat_type,matrix),
              targetid = asso_lis->parents->objid,
              targetos = asso_lis->parents->osnum);
  as$status(action = RET_STATUS);

  /*" Get the Text information of %d,%d\n",go_text.objid,go_text.osnum */

  me->no_field = (char)((double *) asso_lis->as_attr)[0];
  me->justif   = (short)((double *) asso_lis->as_attr)[1];
  me->dx       = ((double *)asso_lis->as_attr)[2];
  me->dy       = ((double *)asso_lis->as_attr)[3];

  /*| Test if the Text have fields */

  field_length = 0;
  text_contents = NULL;

  status = om$send
             (msg      = message GRtext.GRgettxattr(&msg,&text_attr,
                                 &field_length,&text_contents),
              targetid = go_text.objid,
              targetos = go_text.osnum);
  as$status(action = GOTO_VALUE,value = EXEPT);

  start_index = 0;
  esc_char[0] = 'F';
  num_char    = 1;
  esc_num[0]  = &me->no_field;

  /*| Get the coordinate system */

  status = om$send
            (msg      = message NDnode.NDgive_structure(&msg,&textdef,md_env),
             targetid = asso_lis->parents->objid,
             targetos = asso_lis->parents->osnum);
  as$status(action = GOTO_VALUE,value = EXEPT);

  status = ASfind_font_info(text_attr.font,&font_info);
  as$status(action = RET_STATUS);


  if(GRfwd_beg_esc_seq(&msg,text_contents,&field_length,&num_char,
		       esc_char,esc_num,&start_index,
		       &text_attr.font,&text_attr.font,
		       &font_info,
		       &beg_esc))
    {
    /*" For the field %d the justification is %d\n",me->no_field,me->justif*/

    status = om$send(msg      = message GRtext.GRfield_inquire(&msg,&me->no_field,
                                   &(md_env->md_env.matrix_type),
                                   md_env->md_env.matrix,&field_length,
                                   &text_contents,&attribute,
                                   &extent,range,&justif_pts),
                targetid = go_text.objid,
                targetos = go_text.osnum);
    as$status(action = RET_VALUE);

    /*| Compute position of field point */

    ASfield_pt_eval(&justif_pts,&text_attr,&me->dx,&me->dy,&extent,me->justif,&textdef,abs_point);
    }
  else
    {
    /*| The text have not fields */

    me->no_field = 0;
    AStext_pt_eval(&text_attr,&me->dx,&me->dy,me->justif,&textdef,abs_point);
  }/* end if GRfwd_beg_esc_seq */


  if(go_cnst_lis != NULL)
    {
    /*| Construct the Graphic Object */

    geom.num_points = 1;
    geom.points     = abs_point;
    ((struct GRvg_construct *)go_cnst_lis)->geometry = (char *) &geom;

    status = om$send
               (msg      = message ASnode.ASconstruct_go
		      (asso_lis,md_env,go_cnst_lis,OPP_GR3dpoint_class_id,TRUE),
                targetid = my_id); 
    as$status(action = GOTO_VALUE,value = EXEPT);
  }/* end if(go_cnst_lis != NULL)*/

  /*| Connect the parents of this node */

  status = om$send
             (msg      = message NDnode.NDconnect(NUM_PARENT,asso_lis->parents,NULL_GRID,ND_NEW),
              targetid = my_id);
  as$status(action = GOTO_VALUE,value = EXEPT);

EXEPT:
  free(text_contents);
  return(status);
}/* end place */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method NDcompute_node                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDcompute_node
  (
  IGRlong     *msg;              /* OUT    Returned code of this method       */
  IGRint      cn_type;           /* IN     Type for the connection            */
  int         count;             /* IN     Number of parents of the object    */
  struct GRid list_par[];        /* IN     List of the parents of the object  */
  struct GRmd_env *md_env;       /* IN     Information about the environment  */
  )
  { 
  struct GRid   go_text;         /* Graphic object of the text                */
  IGRshort      mat_type;        /* Matrix type of the graphic object         */
  IGRmatrix     matrix;          /* Matrix of the graphic object              */
  IGRlong       status;          /* Status returned by OM                     */
  IGRshort      field_length;    /* Length of the field                       */
  IGRuchar *text_contents;       /* Contents of the text                      */
  GRrange       range;           /* Range of the field                        */
  struct   just_pts justif_pts;  /* Justification points of the field         */
  IGRuchar  attribute;           /* Attribute of the text                     */
  struct   extents  extent;      /* Extents of the text                       */
  IGRdouble     abs_point[4];    /* Absolute coordinates of the field point   */
  struct   ret_struct textdef;   /* Definition of the text                    */
  struct   IGRestx    text_attr; /* Attributes of the text                    */
  IGRshort      num_char;        /* Number of escape codes to search for      */
  IGRchar       esc_char[4];     /* Char to be search for follow. the esc char*/
  IGRchar       *esc_num[4];     /* Array for numbers after esc sequences     */
  IGRshort      start_index;     /* Number of escape codes to search for      */
  IGRshort      beg_esc;         /* Number of escape codes to search for      */
  struct vfont_entry font_info;


  /*" Get the graphic object of %d,%d\n",list_par->objid,list_par->osnum */

  status = om$send
             (msg      = message NDnode.ASreturn_go(&go_text,&mat_type,matrix),
             targetid = list_par->objid,
             targetos = list_par->osnum);
  as$status(action = RET_STATUS);

  /*| Test if the Text have fields */


  field_length = 0;
  text_contents = NULL;

  status = om$send
             (msg      = message GRtext.GRgettxattr(msg,&text_attr,
                                 &field_length,&text_contents),
              targetid = go_text.objid,
              targetos = go_text.osnum);
  as$status(action = GOTO_VALUE,value = EXEPT);

  start_index = 0;
  esc_char[0] = 'F';
  num_char    = 1;
  esc_num[0]  = (IGRchar *)&me->no_field;

  /*| Get the coordinate system */

  status = om$send
            (msg      = message NDnode.NDgive_structure(msg,&textdef,md_env),
             targetid = list_par->objid,
             targetos = list_par->osnum);
  as$status(action = GOTO_VALUE,value = EXEPT);

  status = ASfind_font_info(text_attr.font,&font_info);
  as$status(action = RET_STATUS);


  if(GRfwd_beg_esc_seq(msg,text_contents,&field_length,&num_char,esc_char,
		       esc_num,&start_index,
		       &text_attr.font,&text_attr.font,
		       &font_info,
		       &beg_esc))
    {
    /*" For the field %d the justification is %d\n",me->no_field,me->justif*/

    status = om$send(msg      = message GRtext.GRfield_inquire(msg,&me->no_field,
                                   &(md_env->md_env.matrix_type),
                                   md_env->md_env.matrix,&field_length,
                                   &text_contents,&attribute,
                                   &extent,range,&justif_pts),
                targetid = go_text.objid,
                targetos = go_text.osnum);
    as$status(action = RET_VALUE);

    /*| Compute position of field point */

    ASfield_pt_eval(&justif_pts,&text_attr,&me->dx,&me->dy,&extent,me->justif,&textdef,abs_point);
    }
  else
    {
    /*| The text have not fields */

    /* me->no_field = 0; jla 03-Oct-89 */
    AStext_pt_eval(&text_attr,&me->dx,&me->dy,me->justif,&textdef,abs_point);
  }/* end if GRfwd_beg_esc_seq */

  /*| update graphic object */
  {
  struct GRpost_info post_info;
  GRobjid newobjid;
  struct IGRpolyline polyline;

  polyline.num_points      = 1;
  polyline.points          = abs_point;
  post_info.construct_flag = FALSE;

  status = om$send(msg          = message GRlinear.GRputpolyline
				   (msg,md_env,&post_info,&polyline,&newobjid),
	           p_chanselect = &AS_to_comp );
  as$status(action = RET_STATUS);
  }

EXEPT:
  free(text_contents);
  return (status);
}/* end method NDcompute_node */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_PARENTS 1                      /* Number maximum of parents       */
#define MAX_CHAR    80                     /* Number maximum of char for name */

method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  int                 count;               /* Number of parents               */
  char                name[MAX_CHAR];      /* Name of the object to print     */

  /*| Get the name of this object */

  as$printer_set_name(prefix = "FIELD_POINT",name = name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);
    {
    /* Print the parents and symb */

    as$printer_print_parents(size = MAX_PARENTS,
			     count = &count);
			     
    as$printer_print_symb();

    /*| Print the instances baricentric  coordinate */

    fprintf(stream,"ptr[0]=%lf;\n",((double)(me->no_field)));
    fprintf(stream,"ptr[1]=%lf;\n",((double)(me->justif)));
    fprintf(stream,"ptr[2]=%lf;\n",me->dx);
    fprintf(stream,"ptr[3]=%lf;\n",me->dy);

    /*| Print the message */

    fprintf(stream,"send ASfieldpt.place(%d,list,ptr) to %s;\n\n",count,name);
  }
  return(1);
}/* end print */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method GRgetobjinfo                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetobjinfo
  (
  IGRlong     *msg;              /* OUT    Returned code of this method       */
  struct GRobj_info *info
  )
  {
  *msg = MSSUCC;
  ex$message (buff=info->type,
              msgnumb = AS_I_FieldPt );
  return(OM_S_SUCCESS);
}/* end method GRgetobjinfo */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation ASfieldpt;
