/****************************************************************/
/*								*/
/*		pc_cimac library		         	*/
/*								*/
/*	contains functions for profilew card 			*/
/*		ci_macros constructions          		*/
/*								*/
/* 		Jim Hanson					*/
/*		Maciej Jablkowski 				*/
/*								*/
/*		Intergraph, February 2000			*/
/*								*/
/****************************************************************/
/*
   09-30-2000	create_arc_by_center_globals
   		create_ell_arc_by_center_globals
   		create_ellipse_by_center_globals
   		place_line_globals
   		place_label_globals
   		place_vert_label_globals
   		place_arrow_globals
   		place_symbol_globals
   		get_GRobj_env
   		get_GRid
   		compute_cs_globals( Coord, new_cs, origin, xvec, yvec, zvec )
   		GetXlenFromAngleAndY
   		get_snipe_pts
   		change_style
   		intersect2lines
   		place_radial_dim_globals
   		place_linear_dim_globals
   		getIntParm
   		getDoubleParm
   		getTextParm
   		getparm
   		set_symbology( style, color, weight, level )
   		initialize_graphic_symbology( )

*****************************************************************/

#ifndef PCCIMAC_H_INCLUDED
#define PCCIMAC_H_INCLUDED 1

#ifndef grwireframe_include
#include "grwireframe.h"
#endif

#ifndef stdio_include
#include "stdio.h"
#endif

#ifndef grdpb_include
#include "grdpb.h"
#endif

#ifndef cimath_include
#include "cimath.h"
#endif

#ifndef growner_include
#include "growner.h"
#endif

#ifndef grdpbmacros_include
#include "grdpbmacros.h"
#endif

#ifndef fontmacros_include
#include "fontmacros.h"
#endif

#ifndef cotxmacros_include
#include "cotxmacros.h"
#endif

#ifndef exmacros_include
#include "exmacros.h"
#endif

#ifndef grmacros_include
#include "grmacros.h"
#endif

#include "grmeasmac.h"



//#define TOOLS_DEBUG
#ifndef PI
#define PI  3.141592654
#endif
#ifndef HALF_PI
#define HALF_PI PI/2
#endif


/* Dimension constants */
#define DIM_TXT_LEFT 0
#define DIM_TXT_CENTER 1
#define DIM_TXT_RIGHT 2

#define DIM_ORIENT_TOP 0
#define DIM_ORIENT_BOTTOM 1
#define DIM_ORIENT_RIGHT 2
#define DIM_ORIENT_LEFT 3

#define LINEAR  0
#define RADIAL  1

struct GRid	simpleGRid_list[100];
IGRint		simpleCount;
IGRint		element_style, element_weight, element_color, element_level;

IGRdouble	text_coord_sys[16];
IGRdouble	dimension_text_height;
IGRdouble	label_text_height;
IGRdouble	x_axis_vector[3];
IGRdouble	y_axis_vector[3];
IGRdouble	z_axis_vector[3];
IGRdouble	axis_origin[3];

extern  BSac2ptctvc();
extern  BSellctaxrm();
extern  BSmdstptcv();
extern  BSactivsplt();
extern  GRdisplay_object();
extern  EX_get_oid_nodname();
extern  GRretrieve_font();
extern  GRdpb_get();
extern  GRplace_text();
extern  EX_get_modid_given_osnum();

extern  init_cnst_list();
extern  GRcreate_linestring();
extern  GRproject_point();
extern  GRsymbology_options();


/* ========================================================================= */

printcs( txt , cs)
char txt[128];
double cs[16];
{
    int i;

    for( i = 0; i < 16; i = i + 1 )
        printf("%s[%d] =  %.3f\n", txt , i, cs[i] );
}

/* ========================================================================= */

printpt( txt , pnt)
char txt[128];
double pnt[3];
{
  printf("%s[ %.3f,  %.3f,  %.3f ]\n", txt , pnt[0] , pnt[1] , pnt[2] );
}

/* ========================================================================= */

printvec( txt, vec, size)
char txt[128];
double *vec;
int size;
{
    int i;

    for( i=0; i<size; i=i+1 )
        printf("%s[%d] =  %.3f\n", txt, i, vec[i] );
}

/* ========================================================================= */

create_arc_by_center_globals( ip1 , ip2 , ip3, dir, style, weight )
IGRdouble ip1[3]; // I - start point of arc
IGRdouble ip2[3]; // I - center of arc
IGRdouble ip3[3]; // I - end/sweep point of arc
IGRint	  dir;	  // I - 1-counterclockwise 0-clockwise
IGRint    style, weight;
{

    IGRboolean              Direction;
    double                  Tem1[3] , Tem2[3], Tem3[3];
    double                  normal_vector[3];
    double                  double100[100];
    int                     rtcd;
    struct IGRbsp_curve     bs;
    struct GRvg_construct   cst;
    struct IGRdisplay       dis;
    struct GRmd_env         MOD_ENV;

#ifdef DEBUG
    printpt("ip1", ip1);
    printpt("ip2", ip2);
    printpt("ip3", ip3);
#endif

    ci$get_module_info( md_env = &MOD_ENV);

    //   init_cnst_list();
    //   get_symb();
    dis.color      = element_color;
    dis.weight     = element_weight;
    dis.style      = element_style;
    cst.msg        = &rtcd;
    cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
    cst.display    = &dis;
    cst.env_info   = &MOD_ENV;
    cst.newflag    = 0;
    cst.level      = element_level;
    cst.geometry   = 0;
    cst.class_attr = 0;
    cst.name       = 0;

    bs.poles   = &double100[0];
    bs.knots   = &double100[21];
    bs.weights = &bs.knots[10];

    if( dir > 0) Direction = 1; else Direction = 0;

    v_sub( ip2 , ip1 , Tem1 ) ;
    v_sub( ip3 , ip1 , Tem2 ) ;
    v_cross( Tem1 , Tem2 , Tem3);
    v_scale( Tem3, 1/v_len(Tem3), normal_vector);

#ifdef DEBUG
    printf("normal vector[ %.3f ,%.3f ,%.3f ]\n",
           normal_vector[0] , normal_vector[1] , normal_vector[2] );
#endif

    BSac2ptctvc ( ip2 , ip1, ip3, normal_vector, Direction,
                  &bs, &rtcd );

#ifdef DEBUG
    printf("return from BSac2ptctvc=%d\n", rtcd );
    printf("BSP order[%d], num poles[%d]\n",
           bs.order , bs.num_poles );
#endif

    v_equal( &bs.poles[(bs.num_poles - 1) * 3] , ip3);
    cst.geometry   = (char *)&bs;

    simpleGRid_list[simpleCount].objid = NULL_OBJID;
    simpleGRid_list[simpleCount].osnum = MOD_ENV.md_id.osnum;

    rtcd = ci$send(msg = message GR3dcirarc.GRconstruct(&cst),
                   targetid = simpleGRid_list[simpleCount].objid,
                   targetos = simpleGRid_list[simpleCount].osnum);

#ifdef DEBUG
    printf("arc id[ %d, %d] rtcd[%d]\n",
           simpleGRid_list[simpleCount].objid,
           simpleGRid_list[simpleCount].osnum , rtcd );
#endif
    change_style( simpleGRid_list[simpleCount] , style , weight );
    simpleCount = simpleCount + 1;
}

/* ========================================================================= */

create_ell_arc_by_center_globals( ip1, ip2, ip3, style, weight )
IGRdouble ip1[3]; // I - start point of arc
IGRdouble ip2[3]; // I - center of arc
IGRdouble ip3[3]; // I - end/sweep point of arc
IGRint    style, weight;
{
    double                  Tem1[3] , Tem2[3], Tem3[3];
    double                  normal_vector[3];
    double                  double100[100];
    int                     rtcd;
    struct IGRbsp_curve     bs;
    struct GRvg_construct   cst;
    struct IGRdisplay       dis;
    struct GRmd_env         MOD_ENV;

    IGRdouble               pt[3];
    IGRdouble               par1, par2;
    IGRdouble               base[3];
    IGRdouble               dist;
    IGRint                  rc;
    struct IGRbsp_curve     act_cur;
    IGRboolean              tst_plan;


#ifdef DEBUG
    printpt("ip1", ip1);
    printpt("ip2", ip2);
    printpt("ip3", ip3);
#endif

    ci$get_module_info( md_env = &MOD_ENV);

    //   init_cnst_list();
    //   get_symb();
    dis.color      = element_color;
    dis.weight     = element_weight;
    dis.style      = element_style;

    cst.msg        = &rtcd;
    cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
    cst.display    = &dis;
    cst.env_info   = &MOD_ENV;
    cst.newflag    = 0;
    cst.level      = element_level;
    cst.geometry   = 0;
    cst.class_attr = 0;
    cst.name       = 0;

    bs.poles   = &double100[0];
    bs.knots   = &double100[21];
    bs.weights = &bs.knots[10];
    act_cur.poles   = &double100[0];
    act_cur.knots   = &double100[21];
    act_cur.weights = &bs.knots[10];

#ifdef DEBUG
    printf("p1[%.3f, %.3f, %.3f]\np2[%.3f, %.3f, %.3f]\np3[%.3f, %.3f, %.3f]\n",
           ip1[0],ip1[1],ip1[2],
           ip2[0],ip2[1],ip2[2],
           ip3[0],ip3[1],ip3[2]);
#endif

    /* create the ellipse */
    BSellctaxrm(&rtcd, ip1 , ip2, ip3, &bs);

    /* get the parameters at the points */
    BSmdstptcv(&bs,ip2,&par1,base,&dist,&rc);
    BSmdstptcv(&bs,ip3,&par2,base,&dist,&rc);

    /* split the ellipse between the points */
    tst_plan = TRUE;
    BSactivsplt(&rc,&bs,&par1,&par2,&act_cur,&tst_plan);

#ifdef DEBUG
    printf("return from BSellctaxrm=%d\n", rtcd );
    printf("BSP order[%d], num poles[%d]\n",
           bs.order , bs.num_poles );
#endif

    cst.geometry   = (char *)&act_cur;

    simpleGRid_list[simpleCount].objid = NULL_OBJID;
    simpleGRid_list[simpleCount].osnum = MOD_ENV.md_id.osnum;

    rtcd = ci$send(msg = message GR3dellarc.GRconstruct(&cst),
                   targetid = simpleGRid_list[simpleCount].objid,
                   targetos = simpleGRid_list[simpleCount].osnum);

#ifdef DEBUG
    printf("ellipses id[ %d, %d] rtcd[%d]\n",
           simpleGRid_list[simpleCount].objid,
           simpleGRid_list[simpleCount].osnum , rtcd );
#endif
    change_style( simpleGRid_list[simpleCount] , style , weight );
    simpleCount = simpleCount + 1;
}

/* ========================================================================= */

create_ellipse_by_center_globals( ip1, ip2, ip3, style, weight )
double ip1[3], ip2[3], ip3[3];
int    style, weight;
{
    double                  Tem1[3] , Tem2[3], Tem3[3];
    double                  normal_vector[3];
    double                  double100[100];
    int                     rtcd;
    struct IGRbsp_curve     bs;
    struct GRvg_construct   cst;
    struct IGRdisplay       dis;
    struct GRmd_env         MOD_ENV;

#ifdef DEBUG
    printpt("ip1", ip1);
    printpt("ip2", ip2);
    printpt("ip3", ip3);
#endif

    ci$get_module_info( md_env = &MOD_ENV);

    //   init_cnst_list();
    //   get_symb();
    dis.color      = element_color;
    dis.weight     = element_weight;
    dis.style      = element_style;

    cst.msg        = &rtcd;
    cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
    cst.display    = &dis;
    cst.env_info   = &MOD_ENV;
    cst.newflag    = 0;
    cst.level      = element_level;
    cst.geometry   = 0;
    cst.class_attr = 0;
    cst.name       = 0;

    bs.poles   = &double100[0];
    bs.knots   = &double100[21];
    bs.weights = &bs.knots[10];

    BSellctaxrm(&rtcd, ip1 , ip2, ip3, &bs);

#ifdef DEBUG
    printf("return from BSellctaxrm=%d\n", rtcd );
    printf("BSP order[%d], num poles[%d]\n",
           bs.order , bs.num_poles );
#endif

    cst.geometry   = (char *)&bs;

    simpleGRid_list[simpleCount].objid = NULL_OBJID;
    simpleGRid_list[simpleCount].osnum = MOD_ENV.md_id.osnum;

    rtcd = ci$send(msg = message GR3dellarc.GRconstruct(
        &cst),
                   targetid = simpleGRid_list[simpleCount].objid,
                   targetos = simpleGRid_list[simpleCount].osnum);

#ifdef DEBUG
    printf("ellipses id[ %d, %d] rtcd[%d]\n",
           simpleGRid_list[simpleCount].objid,
           simpleGRid_list[simpleCount].osnum , rtcd );
#endif
    change_style( simpleGRid_list[simpleCount] , style , weight );
    simpleCount = simpleCount + 1;
}

/* ========================================================================= */

int place_line_globals ( ip1, ip2 )
IGRdouble    ip1[3] , ip2[3];
{
    IGRdouble myp[6];
    IGRlong msg;
    struct GRid line;

    v_equal( ip1, myp );
    v_equal( ip2, &myp[3] );

    gr$place_linear_object(
        msg 		= &msg,
        num_points	= 2,
        points   	= myp,
        object_id 	= &simpleGRid_list[simpleCount] );

    change_style( simpleGRid_list[simpleCount] , element_style , element_weight );
    simpleCount = simpleCount + 1;
}


/* ========================================================================= */

int place_line ( GRid_list, Count, ip1, ip2, st, wt )
struct GRid *GRid_list;
IGRdouble    ip1[3] , ip2[3];
IGRint	    *Count, st , wt ;
{
    IGRdouble myp[6];
    IGRlong msg;

    v_equal( ip1, myp );
    v_equal( ip2, &myp[3] );

    gr$place_linear_object(
        msg 		= &msg,
        num_points	= 2,
        points   	= myp,
        object_id 	= &GRid_list[*Count] );

    change_style( GRid_list[*Count] , st , wt );
    *Count = *Count + 1;
}
/* ========================================================================= */

int change_style( inobj , style, weight )
struct GRid	inobj;
int		style, weight;
{
    struct GRsymbology symb;

    GRdisplay_object    ( &inobj , NULL , 1 );
    GRsymbology_options ( &inobj , 0 , &symb );
    symb.display_attr.style = style;
    symb.display_attr.weight = weight;
    GRsymbology_options ( &inobj , 1 , &symb );
    GRdisplay_object    ( &inobj , NULL , 0 );
}

/* ========================================================================= */

int place_label_globals( pnt, label, th, txt_cs )
double       pnt[3], txt_cs[16], th;
char        *label;
{
    place_symbol_globals( label, pnt ,"active", 5 , 0.0 , th , th , txt_cs );
}


/* ========================================================================= */

int place_vert_label_globals( pnt, label, th )
double       pnt[3], th ;
char        *label;
{
    place_symbol_globals( label, pnt ,"active", 5 , HALF_PI,
                          th , th , text_coord_sys );
}


/* ========================================================================= */

place_arrow( GRid_list, Count, ip1 , ip2 , ip3 , txt_cs, vec, dim_ht)
struct GRid *GRid_list;
double ip1[3], ip2[3], ip3[3], txt_cs[16], vec[3], dim_ht;
int    * Count;
{
    int i;

    dimension_text_height = dim_ht;
    for( i=0; i < 16; i=i+1 )
        text_coord_sys[i] = txt_cs[i];
    for( i=0; i<3; i=i+1 )
        z_axis_vector[i] = vec[i];

    place_arrow_globals( ip1 , ip2 , ip3 );
    increment_data ( GRid_list, Count );
}

/* ========================================================================= */

place_arrow_globals( ip1, ip2, ip3 )
IGRdouble    ip1[3], ip2[3], ip3[3];
{

    IGRdouble t[3] , t1[3] , t2[3], t3[3] , t4[3] , arrow_matrix[16] ;
    IGRshort  i;

#ifdef DEBUG
    printpt("z_axis_vector", z_axis_vector );
    printpt("ip1", ip1 );
    printpt("ip2", ip2 );
    printpt("ip3", ip3 );
#endif

    /* Calculate the orientation matrix for the arrow head */
    v_sub( ip2 , ip1 , t );
    v_scale( t , 1/v_len( t ), t1);
    v_cross( t1 , z_axis_vector , t2 );
    v_scale( t2 , 1/v_len( t2 ) , t3 );

    for( i = 0; i < 16; i = i + 1 )
        arrow_matrix[i] = text_coord_sys[i];
    for( i = 0; i < 3; i = i + 1 ) {
        arrow_matrix[i] = t1[i];
        arrow_matrix[i+4] = t2[i];
    }

    /* Place the arrow head */
    place_symbol_globals( "Z", ip3 , "102" , 12, 0.0,
                          dimension_text_height ,
                          dimension_text_height , arrow_matrix );
}

/* ========================================================================= */

place_symbol_globals( text_str, point, font, just, angle, hscale, wscale, matrix)
char	     text_str[132];
double       point[3], angle;
char         font[20];
IGRshort     just;
double	     matrix[16], hscale, wscale;

{
IGRshort		position,text_just,style;
char			text_string[132], font_name[20];
double			text_matrix[16], text_pos[3];
struct GRid		TEXT, OBJS[10];
struct GRmd_env         MOD_ENV;
GRobj			OBJECT;
int			size, net, len, i;
struct GRdpb_text_symb  text_symb;
IGRlong                 msg;
int		        rtcd;
struct GRvg_construct   cst;
struct IGRdisplay       dis;
 

#ifdef DEBUG
  printf("PLACE_SYMBOL_GLOBALS text: %s\n",  text_str );
#endif

  ci$get_module_info( md_env = &MOD_ENV);

//  init_cnst_list();
//  get_symb();
  dis.color      = element_color;
  dis.weight     = element_weight;
  dis.style      = element_style;
 
  cst.msg        = &rtcd;
  cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
  cst.display    = &dis;
  cst.env_info   = &MOD_ENV;
  cst.newflag    = 0;
  cst.level      = element_level;
  cst.geometry   = 0;
  cst.class_attr = 0;
  cst.name       = 0;
 
  /* Initialize text and matrices */
  text_just = (just);
  strcpy(text_string,(text_str));
  for(i=0;i<16;i=i+1) 
    text_matrix[i] = (matrix)[i];
  for(i=0;i<3;i=i+1) 
    text_pos[i] = (point)[i];
  strcpy(font_name,(font));
 
  /* Get the font managers objid */
  ex$get_objid_from_NOD ( NODname   = "IGENOD",
                         objname   = "GRFONTMGR",
                         pobjid    = &OBJECT,
                         mod_osnum = MOD_ENV.md_id.osnum);
 
#ifdef DEBUG
  printf("ex$get_objid_from_NOD id[%d]\n", OBJECT);
#endif
 
  /* Get the position of the string in the font manager */
  position = -1;
 
  ci$send(msg = message GRfm.GRvirt_search ( &msg, font_name, &position),
         targetid = OBJECT,
         targetos = MOD_ENV.md_id.osnum);
 
#ifdef DEBUG_MORE
  printf("GRfm.GRvirt_search font: %s, msg=%d, position: %d\n", font_name, msg, position );
#endif

  if(position == -1)
  {
   // if font not found then retrieve it

   font$retrieve(msg             = &msg,
                 font            = font_name,
                 local_font_name = font_name,
                 font_flags      = 0x01,
                 font_position   = &position);
#ifdef DEBUG_MORE
      printf("font$retrieve font: %s, msg=%d, position: %d\n", font_name, msg, position );
#endif
  }

// get the active text symbology

  size = sizeof( struct GRdpb_text_symb );
  
  gr$get_text_symb(msg     = &msg, 
		   sizbuf  = &size, 
		   buffer  = &text_symb, 
		   nret    = &net);

#ifdef DEBUG_MORE
    printf("gr$get_text_symb msg=%d\n", msg);
    printf("txt height=%.3f, width=%.3f\n", text_symb.Active_height,text_symb.Active_width );
    printf("Text: %s\n", text_string );
#endif

  if( strcmp(font_name,"active") != 0 )  
    text_symb.Active_font = position;

  text_symb.Active_just     = text_just;
  text_symb.Active_charspac = 1;
  text_symb.Active_linespac = 1;
  text_symb.Active_height   = ( text_symb.Active_height /  text_symb.Active_height ) * (hscale);
  text_symb.Active_width    = ( text_symb.Active_width / text_symb.Active_width ) * (wscale);

#ifdef DEBUG_MORE
  printf("gr$get_text_symb msg=%d\n", msg);
  printf("txt height=%.3f, width=%.3f\n", text_symb.Active_height,text_symb.Active_width );
  printf("Text: %s\n", text_string );
#endif

  /* Place the text here */
  len = strlen(text_string);
  co$place_text( msg = &msg, 
		 text_string   = text_string,
		 text_length   = &len,
		 origin        = text_pos,
		 rot_matrix    = text_matrix,
		 ActiveDisplay = &dis,
		 ActiveAngle   = angle, 
                 TextSymb      = &text_symb,
                 mode          = 0,
		 buffer        = &TEXT);

#ifdef DEBUG
  //printf("co$place_text msg =%d, ID[ %d , %d ]\n", msg , TEXT.objid , TEXT.osnum );
#endif

   simpleGRid_list[simpleCount] = TEXT ;
   simpleCount = simpleCount + 1;
}


/*************************************************************/

int getparm( macroid, txt, expr )
     struct GRid   macroid;
     char	   txt[40];
     struct ret_struct *expr;
{
    struct GRid EXPR ;
    IGRint stat;

    ci$send( msg = message  ACcpx.ACfind_temp_obj( &stat , txt , &EXPR ),
             targetid = macroid.objid,
             targetos = macroid.osnum );

    ci$send( msg = message  NDnode.NDgive_structure( &stat , (char *)expr , (char *)0 ),
             targetid = EXPR.objid,
             targetos = EXPR.osnum );
    return(1);
}

/*************************************************************/

int getTextParm( macroid, txt, tout )
     struct GRid   macroid;
     char	   txt[40];
     char	  *tout;
{
    struct ret_struct expr;

    getparm( macroid, txt, &expr );
    strcpy( tout , expr.var.text_st.text_string );
    return(1);
}

/*************************************************************/

int getDoubleParm( macroid, txt, dout )
     struct GRid   macroid;
     char          txt[40];
     IGRdouble    *dout;
{
struct ret_struct expr;
 getparm( macroid, txt, &expr );
  *dout = expr.var.root_pm_st.value;
  return(1);
}
/*************************************************************/

int getIntParm( macroid, txt, iout )
     struct GRid   macroid;
     char          txt[40];
     IGRint       *iout;
{
    struct ret_struct expr;

    getparm( macroid, txt, &expr );
    *iout = expr.var.root_pm_st.value;
    return(1);
}

/**************************************************************/

int get_GRobj_env( macroid, index, OBJ )
    struct GRid 	macroid ; // I - CIMACRO id
    int               index;	  // I - index into the template definition
    struct GRobj_env *OBJ;     // O - GRobj of the located template
{

    IGRint	stat, msg;
    struct GRid TOBJ ;
    struct GRid env;

    msg = ci$send( msg = message  ACcpx.ACfind_exp_temp_obj( &stat,
                                                             index,
                                                             &TOBJ),
                   targetid = macroid.objid,
                   targetos = macroid.osnum );

    if( !(stat&msg&1) ) return FALSE;

#ifdef DEBUG
    printf("\tLocated TObject %d[%d]\n", TOBJ.objid, TOBJ.osnum );
#endif

    msg = ci$send( msg = message NDmacro.ACreturn_foot( &stat ,
                                                        "",
                                                        &OBJ->obj_id,
                                                        &OBJ->mod_env.md_env.matrix_type,
                                                        OBJ->mod_env.md_env.matrix ),
                   targetid = TOBJ.objid,
                   targetos = TOBJ.osnum );
#ifdef DEBUG
    printf("\tLocated Object %d[%d]\n", OBJ->obj_id.objid, OBJ->obj_id.osnum );
#endif
    OBJ->mod_env.md_id.osnum = OBJ->obj_id.osnum;
    env.osnum = OBJ->obj_id.osnum;
#ifdef DEBUG
    printf("\tOsnum set to %d\n", env.osnum);
#endif
    ex$get_modid(   mod_osnum = env.osnum,
                    mod_id    = &env.objid ) ;
#ifdef DEBUG
    printf("\t Modid set to %d\n", env.objid );
#endif
    return ( 1 );

}

/**************************************************************/

int get_GRid( macroid, index, OBJ )
struct GRid  macroid; // I - GRid of the CIMACRO
int		index;	 // I - index into the templates of the CIMACRO
struct GRid	*OBJ;	 // O - the GRid of the output template
{
    struct GRobj_env OBJECT;
    IGRint	stat, msg;

    msg = ci$send( msg = message  ACcpx.ACfind_exp_temp_obj( &stat,
                                                             index,
                                                             OBJ ),
                   targetid = macroid.objid,
                   targetos = macroid.osnum );
#ifdef DEBUG
    printf( "\tGRid [%d, %d]\n", OBJ->objid, OBJ->osnum );
#endif
    if( !(stat&msg&1) ) return FALSE;
}


/**************************************************************/

compute_cs_globals( Coord, new_cs, origin, xvec, yvec, zvec )
struct GRid Coord;
double *new_cs, *origin, *xvec, *yvec, *zvec;
{
    double 	cs[16];
    IGRlong 	msg;
    IGRint	i;

    initialize_graphic_symbology( );

    /* get the location and orientation of the coordinate system */
    ci$send( msg = message GRgencs.GRgetmatrix( &msg, cs ),
             targetid = Coord.objid,
             targetos = Coord.osnum );
#ifdef DEBUG
//    printcs("cs", cs );
#endif

    /* check to see something is set up for dim height */
    if( dimension_text_height < .1 ) {
        printf("dimension_text_height=%.3f, reset to 1\n", dimension_text_height );
        dimension_text_height = 1.0;
    }

    /* flip the coord system for the text coord system */
    new_cs[0] = cs[0];
    new_cs[1] = cs[4];
    new_cs[2] = cs[8];

    new_cs[4] = cs[1];
    new_cs[5] = cs[5];
    new_cs[6] = cs[9];

    new_cs[8] = cs[2];
    new_cs[9] = cs[6];
    new_cs[10] = cs[10];

    new_cs[3] = cs[12];
    new_cs[7] = cs[13];
    new_cs[11] = cs[14];

    new_cs[12] = cs[3];
    new_cs[13] = cs[7];
    new_cs[14] = cs[11];

    new_cs[15] = cs[15];

    xvec[0] = cs[0]; xvec[1] = cs[4]; xvec[2] = cs[8];
    yvec[0] = cs[1]; yvec[1] = cs[5]; yvec[2] = cs[9];
    zvec[0] = cs[2]; zvec[1] = cs[6]; zvec[2] = cs[10];

    origin[0] = cs[3]; origin[1] = cs[7]; origin[2] = cs[11];

    /* added this stuff for our global variables for simpler calls */
    for(i=0;i<3;i=i+1){
        x_axis_vector[i] = xvec[i];
        y_axis_vector[i] = yvec[i];
        z_axis_vector[i] = zvec[i];
        axis_origin[i] = origin[i];
    }
    for( i=0; i<16; i=i+1 ) text_coord_sys[i] = new_cs[i];
}

/*******************************************************************/

IGRint place_linear_dim_globals ( ip1, ip2 , orientO, txtO , txt, dimscale )
  IGRint	orientO; // I - dim top, bottom , right, left-> 0,1,2,3
  IGRint	txtO;	 // I - dim txt left, inside, right -> 0,1,2
  IGRdouble	ip1[3] ; // I - dimension point 1
  IGRdouble	ip2[3] ; // I - dimension point 2
  IGRdouble	dimscale; // I - scale dim text height to raise the leader line
  char	txt[40];
{
    double tp1[3];
    double tp2[3];
    double tp3[3];
    double aro_pt1[3];
    double aro_pt2[3];
    double brk_pt[3];
    double txt_pt[3];

    double	dl1p1[3];
    double	dl1p2[3];
    double	dl2p1[3];
    double	dl2p2[3];

    double	ap1p2[3];
    double	ap2p2[3];

    double	ll1[3];
    double	ll2[3];

    int	just;
    double xlen, ylen , tlen;
    char	dim_lbl[10];
    double 	txvec[3];
    double 	tyvec[3];
    double 	tl[3];
    double 	bl[3];
    double 	tr[3];
    double 	br[3];
    double 	pp1[3];
    double 	pp2[3];
    double 	mpp1[3];
    double 	mpp2[3];
    double	ppt1[3] ;
    double	ppt2[3] ;
    double	tdt[3], l1 ,l2 ;
    int	arrowO;  // dim arrows inside, outside -> 0,1
    int	dir;
    int	one;

    one = 0;
    /* set the arrow side */
    if ( txtO == 1 )
        arrowO = 0;
    else
        arrowO = 1;
    v_sub( ip1 , ip2 , ppt1 );
    xlen = v_dot ( x_axis_vector , ppt1 );
    ylen = v_dot ( y_axis_vector , ppt1 );
    tlen = v_len ( ppt1 );

    /*
      printf("\nx=%.3f , y=%.3f, sqr(x,y)=%.3f, h=%.3f\n\n", xlen , ylen ,
      sqrt( xlen * xlen + ylen * ylen ) , tlen );
    */

    v_scale( x_axis_vector , xlen , tp1);
    if ( ylen < 0 ){
        if ( xlen < 0 ){
            v_add( ip2, tp1, tl );
            v_sub( ip1, tp1, br );
            v_equal( ip2 , tr );
            v_equal( ip1 , bl );
            one = 0;
        } else {
            v_add( ip2, tp1, tr );
            v_sub( ip1, tp1, bl );
            v_equal( ip2 , tl );
            v_equal( ip1 , br );
            one = 1;
        }
    }else {
        if ( xlen < 0 ){
            v_sub( ip1, tp1, tr );
            v_add( ip2, tp1, bl );
            v_equal( ip1 , tl );
            v_equal( ip2 , br );
            one = 2;
        } else {
            v_sub( ip1, tp1, tl );
            v_add( ip2, tp1, br );
            v_equal( ip1 , tr );
            v_equal( ip2 , bl );
            one = 3;
        }
    }

    if ( orientO == 0 ){ // top
        v_equal( tl , pp1 );
        v_equal( tr , pp2 );
        v_equal( y_axis_vector, tyvec );
        v_equal( x_axis_vector, txvec );
        if (one == 0 || one == 2) one = 0; else one = 1;
    } else if ( orientO == 1 ){ //bottom
        v_equal( bl , pp1 );
        v_equal( br , pp2 );
        v_neg( y_axis_vector, tyvec );
        v_equal( x_axis_vector, txvec );
        if (one == 0 || one == 2) one = 0; else one = 1;
    } else if (orientO ==2 ){ //right dimesion
        v_equal( tr , pp1 );
        v_equal( br , pp2 );
        v_equal( x_axis_vector, tyvec );
        v_neg( y_axis_vector, txvec );
        if (one > 1) one = 0; else one = 1;
    } else if (orientO ==3 ){ //left
        v_equal( tl , pp1 );
        v_equal( bl , pp2 );
        v_neg( x_axis_vector, tyvec );
        v_neg( y_axis_vector, txvec );
        if (one > 1) one = 0; else one = 1;
    }

    /* set the position of the text */
    v_sub( pp1 ,pp2 , tdt);
    if ( orientO == 0 || orientO == 1 ){ //bottom
        if( v_len( tdt ) < ( strlen(txt) + 3 )* dimension_text_height ){
            // put the dimension outside
            /* set the arrow side */
            arrowO = 1;
            if( txtO == 1 ) txtO = 0;
        } else {
            arrowO = 0;
            txtO = 1;
        }
    } else { //left
        if( v_len( tdt ) < 4 * dimension_text_height ){
            // put the dimension outside
            arrowO = 1;
            if( txtO == 1 ) txtO = 0;
        } else {
            arrowO = 0;
            txtO = 1;
        }
    }

    v_scale( tyvec, dimension_text_height/2, tp1);
    v_add( pp1, tp1, dl1p1 );

    v_scale( tyvec, dimension_text_height/2, tp1);
    v_add( pp2, tp1, dl2p1 );

    v_scale( tyvec, dimension_text_height * (dimscale ) , tp1);
    v_add( dl1p1, tp1, dl1p2 );
    v_add( dl2p1, tp1, dl2p2 );

    v_scale( tyvec, dimension_text_height * (dimscale - 1) , tp1);
    v_add( dl1p1, tp1, aro_pt1 );
    v_add( dl2p1, tp1, aro_pt2 );

    if ( arrowO == 1 || !(txtO == 1) ){
        v_scale( txvec, dimension_text_height * 3 , tp1);
        v_sub( aro_pt1 , tp1, ll1 );
        v_add( aro_pt2 , tp1, ll2 );
    } else {
        v_equal( aro_pt1, ll1 );
        v_equal( aro_pt2, ll2 );
    }

    if ( txtO == 0 ){ 		//left
        v_add( aro_pt1 , ll1, tp1 );
    } else if (txtO == 1 ){ 	//center
        v_add( aro_pt1 , aro_pt2, tp1 );

    } else { 			//right
        v_add( aro_pt2 , ll2, tp1 );
    }
    v_scale( tp1, .5 , txt_pt );
    v_scale( tyvec, dimension_text_height * 2 , tp1);
    v_add( txt_pt, tp1, txt_pt );
    if ( arrowO == 0 ) {
        v_sub( aro_pt1, txvec , ap1p2 );
        v_add( aro_pt2, txvec , ap2p2 );
    } else {
        v_add( aro_pt1, txvec , ap1p2 );
        v_sub( aro_pt2, txvec , ap2p2 );
    }
    just = 7;

    v_scale( tyvec, dimension_text_height, tp1);
    if (one == 0 ){
        v_add( ip1, tp1, dl1p1);
        v_add( ip2, tp1, dl2p1);
    } else {
        v_add( ip2, tp1, dl1p1);
        v_add( ip1, tp1, dl2p1);
    }

    /* place all the graphics */
    element_weight = 0;
    element_style = 0;
    place_line_globals ( dl1p1 , dl1p2);
    place_line_globals ( dl2p1 , dl2p2 );
    place_line_globals ( ll1 , ll2 );
    place_arrow_globals ( aro_pt1 , ap1p2 , aro_pt1 );
    place_arrow_globals ( aro_pt2 , ap2p2 , aro_pt2 );
    place_symbol_globals( txt , txt_pt ,"active", just , 0.0,
                          dimension_text_height , dimension_text_height , text_coord_sys );
}

/*******************************************************************/
/* The dimension leader line will split the start and sweep points
   the arrow will be placed scale*rad away from the center of the
   arc. The text will be places outside of the scale*radius area.
   The text size is "dimension_text_height" a global parameter
   that can be set outside of this call.
*/
/*******************************************************************/

IGRint place_radial_dim_globals( rad , dimtxt, ip1, ip2 , ip3, scale, flip )
IGRdouble 	rad;	 // I - the value of the radius
IGRchar		*dimtxt; // I - the text for the dimension
IGRdouble	ip1[3];  // I - arc start point
IGRdouble	ip2[3];  // I - center of arc
IGRdouble	ip3[3];  // I - end/sweep point of the arc
IGRdouble	scale;   // I - the scale beam height to drawing frame height 
IGRint          flip;    // I - option to flip the leader line
{
    double trad;
    double tp1[3];
    double tp2[3];
    double tp3[3];
    double aro_pt[3];
    double brk_pt[3];
    double txt_pt[3];
    double ppt1[3] ;
    char   dim_lbl[10];
    int    flip_sign;

    if( flip == 0 )
        flip_sign = 1;
    else
        flip_sign = -1;
    element_weight = 0;
    element_style = 0;
    v_sub( ip1 , ip2 , ppt1 );
    v_add( ip3 , ppt1 , tp1 );
    v_sub( tp1 , ip2 , tp3 );
    v_scale( tp3 , (rad * scale)/v_len( tp3 ) , tp2 );
    v_add( tp2 , ip2, aro_pt );
    place_arrow_globals ( tp1 , ip2 , aro_pt );

    v_scale( tp3 , dimension_text_height * 2.0 /v_len( tp3) , tp2 );
    v_add( aro_pt , tp2, brk_pt );
    place_line_globals( brk_pt , ip2 );

    v_scale( x_axis_vector , flip * dimension_text_height * 5 , ppt1 );
    v_sub( brk_pt , ppt1 , tp1 );
    place_line_globals( tp1 , brk_pt );

    v_scale( x_axis_vector , flip * dimension_text_height * 2.5 , ppt1 );
    v_sub( brk_pt , ppt1 , tp2 );
    //  sprintf( dim_lbl , "%.0f", rad );
    place_symbol_globals( dimtxt , tp2 ,"active", 5 , 0.0 ,
                          dimension_text_height , dimension_text_height , text_coord_sys );

}

/*******************************************************************/
/* The dimension leader line will split the start and sweep points
   the arrow will be placed scale*rad away from the center of the
   arc. The text will be places outside of the scale*radius area.
   The text size is "dimension_text_height" a global parameter 
   that can be set outside of this call.
*/
/*******************************************************************/

IGRint place_snipe_dim_globals( rad , dimtxt, ip1, ip2 , ip3, scale, flip )
IGRdouble 	rad;	 // I - the value of the snipe
IGRchar		*dimtxt; // I - the text for the dimension
IGRdouble	ip1[3];  // I - snipe start point
IGRdouble	ip2[3];  // I - center of arc
IGRdouble	ip3[3];  // I - snipe end point
IGRdouble	scale;   // I - the scale beam height to drawing frame height
IGRint          flip;    // I - option to flip the leader line
{
    double trad;
    double tp1[3];
    double tp2[3];
    double tp3[3];
    double aro_pt[3];
    double brk_pt[3];
    double txt_pt[3];
    double ppt1[3] ;
    char   dim_lbl[10];
    int    flip_sign;

    element_weight = 0;
    element_style = 0;
    v_sub( ip1 , ip2 , ppt1 );
    v_add( ip3 , ppt1 , tp1 );
    v_sub( tp1 , ip2 , tp3 );
    v_scale( tp3 , (rad* sqrt(2)/2 * scale)/v_len( tp3 ) , tp2 );
    v_add( tp2 , ip2, aro_pt );
    //find_mid_pt( ip1, ip2, aro_pt );
    place_arrow_globals ( tp1 , ip2 , aro_pt );

    v_scale( tp3 , dimension_text_height * 3.0 /v_len( tp3) , tp2 );
    v_add( aro_pt , tp2, brk_pt );
    place_line_globals( brk_pt , aro_pt );

    v_scale( x_axis_vector, flip * dimension_text_height * 5 , ppt1 );
    v_sub( brk_pt , ppt1 , tp1 );
    place_line_globals( tp1 , brk_pt );

    v_scale( x_axis_vector, flip * dimension_text_height * 2.5 , ppt1 );
    v_sub( brk_pt , ppt1 , tp2 );
    //  sprintf( dim_lbl , "%.0f", rad );
    place_symbol_globals( dimtxt , tp2 ,"active", 5 , 0.0 ,
                          dimension_text_height , dimension_text_height , text_coord_sys );

}

/**************************************************************/

GetXlenFromAngleAndY ( len , ang , X )
double len;
double ang;
double *X;
{
    if ( ang == 90)
        *X = 0.0;
    else
        *X = len / tan( ang / ( 180 / PI) );
    return;
}


/******************************************************************/

get_snipe_pts( hor, ver , angle, rad , cpt , up , scale, op1 , op2 )
IGRdouble hor ; 	//I - horizontal set back
IGRdouble ver ; 	//I - vertical set back
IGRdouble rad ; 	//I - radius of the
IGRdouble angle; 	//I - angle of the cut
IGRdouble scale;	//I - scale of beam height to drw frame height
IGRdouble cpt[3] ; 	//I - corner point
IGRdouble op1[3] ;	//O - horizontal setback point
IGRdouble op2[3] ;	//O - vertical setback point
int       up; 		//I - direction of the snipe 0 is top else bottom snipe
{
    double thor , tver , tp1[3] , tp2[3], tp3[3], tx , ty ;
    int    ud;

    if ( up > 0 ) ud = 1; else ud = -1;
    if ( ver > rad ) tver = ver ; else tver = rad;
    if ( hor > rad ) thor = hor ; else thor = rad;
    tx = thor * scale;

    v_scale ( x_axis_vector , tx , tp1 );
    v_sub ( cpt , tp1 , op1 );
    GetXlenFromAngleAndY ( tver , angle , &ty);
    tx = ty * scale * ud;
    v_scale ( x_axis_vector , tx , tp2 );
    ty = tver * scale * ud;
    v_scale ( y_axis_vector , ty , tp3 );
    v_sub ( cpt , tp2 , tp1 );
    v_add ( tp1, tp3 , op2 );
}

/*************************************************************/

intersect2lines ( ip1 , ip2 , ip3 , ip4 , op1, xs)
IGRdouble ip1[3]; //I - pt1 of line 1
IGRdouble ip2[3]; //I - pt2 of line 1
IGRdouble ip3[3]; //I - pt1 of line 2
IGRdouble ip4[3]; //I - pt2 of line 3
IGRdouble op1[3]; //O - intersection point
int       *xs;    //O - is intersection inside points 0=none, 1=first, 2=second, 3=both
{
    double t1[3],t2[3],t3[3],t4[3],t5[3],t6[3],t7[3], t8[3];
    double u1[3],u2[3],u3[3],u4[3],u5[3],u6[3],u7[3];
    double l1 ,l2 ,l3 ,l4,l5,l6,l7;
    double a1;

    /* initialize outputs */
    *xs = 0;
    v_identity( op1 );

    /* check to see if points are coincident */
    v_sub( ip1 , ip2, t1);
    if ( v_len( t1 ) == 0 )
        return;
    v_sub( ip3 , ip4, t1);
    if ( v_len( t1 ) == 0 )
        return;
    /* points are ok continue */
    v_sub( ip2 , ip1, t2 );
    v_sub( ip3 , ip1, t3 );
    v_sub( ip4 , ip1, t4 );

    v_scale( t2, 1/v_len(t2), u2 );
    l2 = v_dot( u2, t3 );
    v_scale( u2, l2, t8 );
    v_sub( t8, t3 , t1);
    l1 = v_len( t1);
    v_sub( t3, t4, t6);
    v_scale( t1, 1/v_len(t1), u1);
    v_scale( t6, 1/v_len(t6), u6);
    a1 = v_dot( u1 , u6 );
    v_scale( u6 , l1/a1 , t7 );

    /* this is the output point */
    v_add( t7 , ip3 , op1);

    /* now check the point to see
       if it is inside the points
    */
    v_sub( ip2, ip1, t1 );
    l1 = v_len( t1 );
    v_sub( op1, ip1, t2 );
    l2 = v_len( t2 );
    v_sub( op1, ip2, t3 );
    l3 = v_len( t3 );
    if( l1 >= l2 && l1 >= l3 )
        *xs = 1;
    v_sub( ip3, ip4, t4 );
    l4 = v_len( t4 );
    v_sub( op1, ip3, t5 );
    l5 = v_len( t5 );
    v_sub( op1, ip4, t6 );
    l6 = v_len( t6 );
    if( l4 >= l5 && l4 >= l6 )
        *xs = *xs + 2;

#ifdef DEBUG
    printf("output ints=%d, \n",*xs );
#endif
}

/*************************************************************

set_symbology( style, color, weight, level )
IGRint	style;
IGRint	color;
IGRint	weight;
IGRint	level;
{
    element_style = style;
    element_color = color;
    element_weight = weight;
    element_level = level;
}

*************************************************************/

initialize_graphic_symbology( )
{
    init_cnst_list();
    get_symb();
    element_style = cnst_list.style;;
    element_color = cnst_list.color;
    element_weight = cnst_list.weight;
    element_level = cnst_list.level;
}

/*************************************************************/

int getobj ( cimacroid, index, OBJ )
struct GRid	  cimacroid; // CIMACRO'S id
int		  index;  // index of the wanted template
struct GRobj_env *OBJ;    // output GRobj_env of the template
{
    return( get_GRobj_env( cimacroid,  index, OBJ ));
}


extern GRcreate_linestring(), GRproject_point_on_element(), GRdelete_object();

/* ***********************************************************
 * This function  computes distance between two points
 *************************************************************/
double dist_2_pts( pt1, pt2 )
    double *pt1,*pt2;
{
    double dx, dy, dz;

    dx = pt2[0] - pt1[0];
    dy = pt2[1] - pt1[1];
    dz = pt2[2] - pt1[2];

    return( sqrt( dx*dx + dy*dy + dz*dz ));
}

/* ***********************************************************
 * This function creates a unit vector along the line
 * specified by p1, p2. The vector is oriented from p1 to p2.
 *************************************************************/

vec_along_line( p1, p2, vec )
  double *p1, *p2, *vec;
{
  double dx, dy, dz, scale;

  /* Find deltas */
  dx = p2[0] - p1[0];
  dy = p2[1] - p1[1];
  dz = p2[2] - p1[2];

  /* Set scale */
  scale = 1/sqrt( dx*dx + dy*dy + dz*dz );

  /* Create vector */
  vec[0] = scale * dx;
  vec[1] = scale * dy;
  vec[2] = scale * dz;
}

vec_from_line( p1, p2, vec )
  double *p1, *p2, *vec;
{
  double dx, dy, dz;

  /* Find deltas */
  vec[0] = p2[0] - p1[0];
  vec[1] = p2[1] - p1[1];
  vec[2] = p2[2] - p1[2];
}

/* ***********************************************************
 * This function finds a mid point between p1 and p2.
 *************************************************************/

find_mid_pt( p1, p2, mid_pt )
    double *p1, *p2, *mid_pt;
{
    mid_pt[0] = (p1[0] + p2[0])/2;
    mid_pt[1] = (p1[1] + p2[1])/2;
    mid_pt[2] = (p1[2] + p2[2])/2;
    return;
}

/* ***********************************************************
 * This function creates a unit vector as a bisector between
 * lines specified by end_pt1 and end_pt2 with common_pt.
 * The vector is always oriented towards smaller angle.
 *************************************************************/

vec_bisector( end_pt1, common_pt, end_pt2, vec )
double *end_pt1, *common_pt, *end_pt2, *vec;
{
    double mid_pt[3], vec1[3], vec2[3], pt1[3], pt2[3];

    /* Find vectors of lines */
    vec_along_line( common_pt, end_pt1, vec1 );
    vec_along_line( common_pt, end_pt2, vec2 );
    /* Add two points along arms in equal distance */
    v_add( common_pt, vec1, pt1 );
    v_add( common_pt, vec2, pt2 );
    /* Find mid pt */
    find_mid_pt( pt1, pt2, mid_pt );
    /* Build bisector vector */
    vec_along_line( common_pt, mid_pt, vec );
}

/* ***********************************************************
 * This function finds a point that is projected pt on line
 * specified by ln_pt1 and ln_pt2.
 *************************************************************/

proj_pnt_on_line_2_pts( ln_pt1, ln_pt2, pt_to_proj, proj_pt )
    double *ln_pt1, *ln_pt2, *pt_to_proj, *proj_pt;
{
    struct GRid     object;
    IGRdouble       points[6], u, v;
    IGRlong         msg, i;

    /* Build points vector */
    for( i=0; i<3; i=i+1 ) {
        points[i] = ln_pt1[i];
        points[i+3] = ln_pt2[i];
    }
    /* Place line to project point on */
    gr$place_linear_object( msg = &msg,
                            num_points = 2,
                            points = points,
                            object_id = &object,
                            display_flag = 0 );
    /* Project point */
    gr$project_pnt_on_element( msg = &msg,
                               object_id  = &object,
                               point = pt_to_proj,
                               u_parm = &u,
                               v_parm = &v,
                               proj_pt = proj_pt );
    /* Delete line */
    gr$delete_object( msg = &msg,
                      object_id = &object,
                      display_flag = 0 );
}


/* ***********************************************************
 * This function finds a point that is projected pt on line
 * specified by ln_pt1 and ln_pt2.
 *************************************************************/

proj_pnt_on_line_2_pts_vec( ln_pt1, ln_pt2, vec, pt_to_proj, proj_pt )
    double *ln_pt1, *ln_pt2, *pt_to_proj, *proj_pt, *vec;
{
    struct GRid     object;
    IGRdouble       points[6], u, v;
    IGRlong         msg, i;

    /* Build points array */
    for( i=0; i<3; i=i+1 ) {
        points[i] = ln_pt1[i];
        points[i+3] = ln_pt2[i];
    }
    /* Place line to project point on */
    gr$place_linear_object( msg = &msg,
                            num_points = 2,
                            points = points,
                            object_id = &object,
                            display_flag = 0 );
    /* Project point */
    gr$project_point_along_vector( msg = &msg,
                                   object_id  = &object,
                                   vec_start = vec,
                                   point = pt_to_proj,
                                   u_parm = &u,
                                   v_parm = &v,
                                   proj_pt = proj_pt );
    /* Delete line */
    gr$delete_object( msg = &msg,
                      object_id = &object,
                      display_flag = 0 );
}

extern CO_measure_angle_3pts();

/* ***********************************************************
 * This function finds an angle between 3 points
 *************************************************************/

angle_3_pts( pt1, cntr_pt, pt2, angle )
double *pt1, *cntr_pt, *pt2, *angle;
{
    int status, msg;
    struct GRid window;

    status = gr$meas_angle_3pts ( msg        = &msg,
                                  first_pt   = pt1,
                                  vertex_pt  = cntr_pt,
                                  axis_pt    = pt2,
                                  proj       = 0,
                                  window_id  = window.objid,
                                  p_angle    = angle );
    return;
}

/* ***********************************************************
 * This function finds center point and tangent points of
 * fillet between lines specified by ln_pt1, ln_pt2 and common_pt.
 *************************************************************/

fillet_pts( ln_pt1, common_pt, ln_pt2, radius, arc_center, arc_pt1, arc_pt2 )
double *ln_pt1, *common_pt, *ln_pt2,
       *arc_center, *arc_pt1, *arc_pt2;
double radius;
{
    double bisector_vec[3], varV, tmp[3], angle, ratio;
    int status, msg;
    struct GRid window;

    /* Find bisector vector */
    vec_bisector( ln_pt1, common_pt, ln_pt2, bisector_vec );

    angle_3_pts( ln_pt1, common_pt, ln_pt2, &angle );
    ratio = radius/sin( angle/2 );

#ifdef DEBUG
    printf("Radius = %f\tRatio = %f\n", radius, ratio );
#endif

    /* scale it with radius value - find fillet center */
    v_scale( bisector_vec, ratio, tmp );
    v_add( common_pt, tmp, arc_center );

    /* Find fillet tangent points */
    proj_pnt_on_line_2_pts( ln_pt1, common_pt, arc_center, arc_pt1 );
    proj_pnt_on_line_2_pts( ln_pt2, common_pt, arc_center, arc_pt2 );
}

/* ========================================================================= */

create_arc_by_center ( GRid_list, Count, ip1 , ip2 , ip3 , dir , st , wt)
struct GRid *GRid_list;
double ip1[3], ip2[3], ip3[3];
int	dir, st , wt, * Count;
{
 	element_style = st;
 	element_weight = wt;
	create_arc_by_center_globals(ip1 , ip2 , ip3, dir, st, wt );
	increment_data ( GRid_list, Count );
}

/* ========================================================================= */

create_ell_arc_by_center ( GRid_list, Count, ip1, ip2, ip3, dir, st, wt)
struct GRid *GRid_list;
double ip1[3], ip2[3], ip3[3];
int	dir, st , wt, * Count;
{
 	element_style = st;
 	element_weight = wt;
	create_ell_arc_by_center_globals( ip1, ip2, ip3, st, wt);
	increment_data ( GRid_list, Count );
}

/* ========================================================================= */

create_ellipse_by_center ( GRid_list, Count, ip1, ip2, ip3, dir, st, wt)
struct GRid *GRid_list;
double ip1[3], ip2[3], ip3[3];
int    dir,st , wt, * Count;
{
    element_style = st;
    element_weight = wt;
    create_ellipse_by_center_globals( ip1, ip2, ip3, st, wt);
    increment_data ( GRid_list, Count );
}

/* ========================================================================= */

int placeLine ( GRid_list, Count, ip1, ip2, st, wt )
struct GRid *GRid_list;
IGRdouble    ip1[3] , ip2[3];
IGRint      *Count, st , wt;
{
    element_style = st;
    element_weight = wt;
    place_line_globals( ip1 , ip2 );
    increment_data ( GRid_list, Count );
}

/* ========================================================================= */

int place_linear_dim( GRid_list, Count, ip1, ip2 , orientO, txtO , txt, dimscale )
struct GRid *GRid_list;
int         *Count;
IGRint       orientO;    // I - dim top, bottom , right, left-> 0,1,2,3
IGRint       txtO;       // I - dim txt left, inside, right -> 0,1,2
IGRdouble    ip1[3] ;    // I - dimension point 1
IGRdouble    ip2[3] ;    // I - dimension point 2
IGRdouble    dimscale;   // I - scale dim text height to raise the leader line
char         txt[40];
{
    int st, wt;

    //printf("Linear dim [%s] orient: %d\n", txt, orientO );

    if( !strcmp( txt, "0" ) )
        return;
    element_style = st;
    element_weight = wt;
    place_linear_dim_globals( ip1, ip2 , orientO, txtO , txt, dimscale );
    increment_dim_data ( GRid_list, Count, LINEAR );
}

/* ========================================================================= */

int place_radial_dim( GRid_list, Count, rad , dimtxt, ip1, ip2 , ip3, scale, flip )
struct GRid *GRid_list;
int         *Count;
IGRdouble 	rad;	 // I - the value of the radius
IGRchar		*dimtxt; // I - the text for the dimension
IGRdouble	ip1[3];  // I - arc start point
IGRdouble	ip2[3];  // I - center of arc
IGRdouble	ip3[3];  // I - end/sweep point of the arc
IGRdouble	scale;   // I - the scale beam height to drawing frame height 
IGRint          flip;    // I - option to flip the leader line
{
    int st, wt;

    if( !strcmp( dimtxt, "0" ) )
        return;
    element_style = st;
    element_weight = wt;
    place_radial_dim_globals( rad , dimtxt, ip1, ip2 , ip3, scale, flip );
    increment_dim_data ( GRid_list, Count, RADIAL );
}


/* ========================================================================= */

int place_snipe_dim( GRid_list, Count, rad , dimtxt, ip1, ip2 , ip3, scale, flip )
struct GRid *GRid_list;
int         *Count;
IGRdouble    rad;        // I - the value of the radius
IGRchar     *dimtxt;     // I - the text for the dimension
IGRdouble    ip1[3];     // I - arc start point
IGRdouble    ip2[3];  // I - center of arc
IGRdouble    ip3[3];  // I - end/sweep point of the arc
IGRdouble    scale;   // I - the scale beam height to drawing frame height
IGRint       flip;    // I - option to flip the leader line
{
    int st, wt;

    if( !strcmp( dimtxt, "0" ) )
        return;
    element_style = st;
    element_weight = wt;
    place_snipe_dim_globals( rad , dimtxt, ip1, ip2 , ip3, scale, flip );
    increment_dim_data ( GRid_list, Count, RADIAL );
}


/* ========================================================================= */

int place_label ( GRid_list, Count, pnt, label, dim_txt_ht, txt_cs )
struct GRid *GRid_list;
int         *Count;
double       pnt[3], txt_cs[16], dim_txt_ht;
char        *label;
{
    dimension_text_height = dim_txt_ht;
    place_label_globals( pnt, label, dim_txt_ht, txt_cs );
    increment_data ( GRid_list, Count );
}

/* ========================================================================= */

compute_cs ( Coord, new_cs, origin, xvec, yvec, zvec )
struct GRid Coord;
double *new_cs, *origin, *xvec, *yvec, *zvec;
{
    compute_cs_globals( Coord, new_cs, origin, xvec, yvec, zvec );
}

/* ========================================================================= */

increment_data ( GRid_list, Count )
struct GRid *GRid_list;
int         *Count;
{
    GRid_list[simpleCount-1] = simpleGRid_list[simpleCount-1];
    *Count = simpleCount;
}

/* ========================================================================= */

increment_dim_data ( GRid_list, Count, Type )
struct GRid *GRid_list;
int         *Count;
int          Type;
{
    int i, range;

#ifdef DEBUG
    printf("Increment Dim Data - type %d", Type );
#endif

    switch ( Type )
    {
        case LINEAR:
            range = 6;
            break;
        case RADIAL:
            range = 4;
            break;
    }
#ifdef DEBUG
    printf(" : range %d\n", range );
#endif

    for( i=0; i<range; i=i+1)
    {
        GRid_list[grCount] = simpleGRid_list[simpleCount - range + i];
        *Count = *Count + 1;
    }
}

/* ========================================================================= */

int place_vert_label ( GRid_list, Count, pnt, label, dim_txt_ht, txt_cs )
struct GRid *GRid_list;
int         *Count;
double       pnt[3], txt_cs[16], dim_txt_ht;
char        *label;
{
    int i;

    for( i=0; i < 16; i=i+1 )
        text_coord_sys[i] = txt_cs[i];

    place_symbol_globals( label, pnt ,"active", 5, HALF_PI,
                          dim_txt_ht , dim_txt_ht , text_coord_sys );
//    place_vert_label_globals( pnt, label, dim_txt_ht );
    increment_data ( GRid_list, Count );
}

/* ========================================================================= */

int place_pcg_label ( GRid_list, Count, pnt, label, dim_txt_ht, txt_cs )
struct GRid *GRid_list;
int         *Count;
double       pnt[3], txt_cs[16], dim_txt_ht;
char        *label;
{
    int i;

    for( i=0; i < 16; i=i+1 )
        text_coord_sys[i] = txt_cs[i];
        
//    dimension_text_height = dim_txt_ht;
    place_symbol_globals( label, pnt ,"active", 3, HALF_PI,
                          dim_txt_ht , dim_txt_ht , text_coord_sys );
 
//    place_vert_label_globals( pnt, label, dim_txt_ht );
    increment_data ( GRid_list, Count );
}

#endif












