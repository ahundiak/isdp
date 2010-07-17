/****************************************************************/
/*								*/
/*		mj_cimac library		         	*/
/*								*/
/*	contains functions for ci_macros constructions          */
/*								*/
/*		Maciej Jablkowski 				*/
/*								*/
/*		Intergraph, February 2000			*/
/*								*/
/****************************************************************/
/*
   02-18-2000	get_macro_name
                get_macro_params    
                get_macro_template
		get_macro_foot
                get_temp_struct
		get_foot_struct	
                get_str_attr
                get_template_idx
                get_classname
                classcmp
                struct_classcmp
*****************************************************************/

#ifndef MJCIMAC_H_INCLUDED
#define MJCIMAC_H_INCLUDED 1

//#define TOOLS_DEBUG

#ifndef PI
#define PI  3.141592654
#endif

#ifndef HALF_PI
#define HALF_PI PI/2
#endif

#ifndef exmacros_include
#include "exmacros.h"
#endif

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

create_arc_by_center( GRid_list, Count, ip1 , ip2 , ip3 , dir , st , wt)
struct GRid *GRid_list;
double ip1[3], ip2[3], ip3[3];
int	dir;
int	st , wt;
int     * Count;
{

IGRboolean      Direction;
double 		Tem1[3] , Tem2[3], Tem3[3];
double          normal_vector[3];
double		double100[100];
int		rtcd;
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

   	init_cnst_list();
   	get_symb();
   	dis.color      = cnst_list.color;
   	dis.weight     = wt;
   	dis.style      = st;
 
   	cst.msg        = &rtcd;
   	cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
   	cst.display    = &dis;
   	cst.env_info   = &MOD_ENV;
   	cst.newflag    = 0;
   	cst.level      = cnst_list.level;
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

        GRid_list[*Count].objid = NULL_OBJID;
        GRid_list[*Count].osnum = MOD_ENV.md_id.osnum;

        rtcd = ci$send(msg = message GR3dcirarc.GRconstruct(
                &cst),
                targetid = GRid_list[*Count].objid,
                targetos = GRid_list[*Count].osnum);
        
#ifdef DEBUG
        printf("arc id[ %d, %d] rtcd[%d]\n", GRid_list[*Count].objid, GRid_list[*Count].osnum , rtcd );
#endif
	*Count = *Count + 1;
}

/* ========================================================================= */

create_ell_arc_by_center( GRid_list, Count, ip1, ip2, ip3, dir, st, wt)
struct GRid *GRid_list;
double ip1[3], ip2[3], ip3[3];
int	dir;
int	st , wt;
int     * Count;
{

IGRboolean      Direction;
double 		Tem1[3] , Tem2[3], Tem3[3];
double          normal_vector[3];
double		double100[100];
int		rtcd;
struct IGRbsp_curve     bs;
struct GRvg_construct   cst;
struct IGRdisplay       dis;
struct GRmd_env         MOD_ENV;
 
IGRdouble       pt[3];
IGRdouble       par1, par2;
IGRdouble       base[3];
IGRdouble       dist;
IGRint          rc;
struct IGRbsp_curve act_cur;
IGRboolean      tst_plan;


#ifdef DEBUG
 printpt("ip1", ip1);
 printpt("ip2", ip2);
 printpt("ip3", ip3);
#endif 

        ci$get_module_info( md_env = &MOD_ENV);

   	init_cnst_list();
   	get_symb();
   	dis.color      = cnst_list.color;
   	dis.weight     = wt;
   	dis.style      = st;
 
   	cst.msg        = &rtcd;
   	cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
   	cst.display    = &dis;
   	cst.env_info   = &MOD_ENV;
   	cst.newflag    = 0;
   	cst.level      = cnst_list.level;
   	cst.geometry   = 0;
   	cst.class_attr = 0;
   	cst.name       = 0;
 
        /*
        BSCIRCLE_NUM_POLES_MAX  poles, 7
        BSCIRCLE_NUM_POLES_MAX  weights,
        BSCIRCLE_ORDER          order, 3
        BSCIRCLE_NUM_KNOTS_MAX (BSCIRCLE_NUM_POLES_MAX + BSCIRCLE_ORDER) knots,
        */

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
	
	//placeLine ( ip1, ip2, &grCount, 0, 0 );
	//placeLine ( GRid_list, Count, ip3, ip2, 0, 0 ); // edge points

#endif
	
        /* create the ellipse */
        BSellctaxrm(&rtcd, ip1 , ip2, ip3, &bs);
        //        printf("past BSellctaxrm\n");

        /* get the parameters at the points */
        BSmdstptcv(&bs,ip2,&par1,base,&dist,&rc);
        //        printf("past BSmdstptcv1 \n");
        BSmdstptcv(&bs,ip3,&par2,base,&dist,&rc);
        //        printf("past BSmdstptcv2 \n");

        /* split the ellipse between the points */
        tst_plan = TRUE;
        BSactivsplt(&rc,&bs,&par1,&par2,&act_cur,&tst_plan);
        //        printf("past BSactivsplt \n");

                
#ifdef DEBUG
        printf("return from BSellctaxrm=%d\n", rtcd );
	printf("BSP order[%d], num poles[%d]\n", 
		bs.order , bs.num_poles );
#endif
	
        cst.geometry   = (char *)&act_cur;

        GRid_list[*Count].objid = NULL_OBJID;
        GRid_list[*Count].osnum = MOD_ENV.md_id.osnum;

        rtcd = ci$send(msg = message GR3dellarc.GRconstruct(
                &cst),
                targetid = GRid_list[*Count].objid,
                targetos = GRid_list[*Count].osnum);
        
#ifdef DEBUG
        printf("ellipses id[ %d, %d] rtcd[%d]\n", GRid_list[*Count].objid, GRid_list[*Count].osnum , rtcd );
#endif
	*Count = *Count + 1;
}

/* ========================================================================= */

create_ellipse_by_center( GRid_list, Count, ip1, ip2, ip3, dir, st, wt)
struct GRid *GRid_list;
double ip1[3], ip2[3], ip3[3];
int	dir;
int	st , wt;
int     * Count;
{

IGRboolean      Direction;
double 		Tem1[3] , Tem2[3], Tem3[3];
double          normal_vector[3];
double		double100[100];
int		rtcd;
struct IGRbsp_curve     bs;
struct GRvg_construct   cst;
struct IGRdisplay       dis;
struct GRmd_env         MOD_ENV;
 

#ifdef DEBUG
//printpt("ip1", ip1);
//printpt("ip2", ip2);
//printpt("ip3", ip3);
#endif 

        ci$get_module_info( md_env = &MOD_ENV);

   	init_cnst_list();
   	get_symb();
   	dis.color      = cnst_list.color;
   	dis.weight     = wt;
   	dis.style      = st;
 
   	cst.msg        = &rtcd;
   	cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
   	cst.display    = &dis;
   	cst.env_info   = &MOD_ENV;
   	cst.newflag    = 0;
   	cst.level      = cnst_list.level;
   	cst.geometry   = 0;
   	cst.class_attr = 0;
   	cst.name       = 0;
 
        /*
        BSCIRCLE_NUM_POLES_MAX  poles, 7
        BSCIRCLE_NUM_POLES_MAX  weights,
        BSCIRCLE_ORDER          order, 3
        BSCIRCLE_NUM_KNOTS_MAX (BSCIRCLE_NUM_POLES_MAX + BSCIRCLE_ORDER) knots,
        */

        bs.poles   = &double100[0];
        bs.knots   = &double100[21];
        bs.weights = &bs.knots[10];

       
#ifdef DEBUG

        //	printf("p1[%.3f, %.3f, %.3f]\np2[%.3f, %.3f, %.3f]\np3[%.3f, %.3f, %.3f]\n",
	//	ip1[0],ip1[1],ip1[2],
	//	ip2[0],ip2[1],ip2[2],
	//	ip3[0],ip3[1],ip3[2]);
	
	//placeLine ( ip1, ip2, &grCount, 0, 0 );
	//placeLine ( GRid_list, Count, ip3, ip2, 0, 0 ); // edge points

#endif
	
        BSellctaxrm(&rtcd, ip1 , ip2, ip3, &bs);
                
#ifdef DEBUG
        printf("return from BSellctaxrm=%d\n", rtcd );
	printf("BSP order[%d], num poles[%d]\n", 
		bs.order , bs.num_poles );
#endif
	
        cst.geometry   = (char *)&bs;

        GRid_list[*Count].objid = NULL_OBJID;
        GRid_list[*Count].osnum = MOD_ENV.md_id.osnum;

        rtcd = ci$send(msg = message GR3dellarc.GRconstruct(
                &cst),
                targetid = GRid_list[*Count].objid,
                targetos = GRid_list[*Count].osnum);
        
#ifdef DEBUG
        printf("ellipses id[ %d, %d] rtcd[%d]\n", GRid_list[*Count].objid, GRid_list[*Count].osnum , rtcd );
#endif
	*Count = *Count + 1;
}

/* ========================================================================= */

int placeLine ( GRid_list, Count, ip1, ip2, st, wt )
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
    
    change_style( &GRid_list[*Count] , st , wt );	
    *Count = *Count + 1;
}

/* ========================================================================= */

int change_style( inobj , style, weight )
struct GRid	*inobj;
int		style, weight;
{
    struct GRsymbology symb;
    
#ifdef DEBUG
    printf("Changing symbology to %d, %d\n", style, weight);
#endif
    
    GRdisplay_object    ( inobj , NULL , 1 );
    GRsymbology_options ( inobj , 0 , &symb );
    symb.display_attr.style = style;
    symb.display_attr.weight = weight;
    GRsymbology_options ( inobj , 1 , &symb );
    GRdisplay_object    ( inobj , NULL , 0 );
}

/* ========================================================================= */

int place_label( GRid_list, Count, pnt, label, dim_txt_ht, txt_cs )
struct GRid *GRid_list;
int	    *Count;
double       pnt[3], txt_cs[16], dim_txt_ht;
char        *label;
{
  pl_symbol( GRid_list, Count , label, pnt ,"active", 5 , 0.0, 
             dim_txt_ht , dim_txt_ht , txt_cs );
}

/* ========================================================================= */

int place_vert_label( GRid_list, Count, pnt, label, dim_txt_ht, txt_cs )
struct GRid *GRid_list;
int	    *Count;
double       pnt[3], txt_cs[16], dim_txt_ht;
char        *label;
{

  pl_symbol( GRid_list, Count , label, pnt ,"active", 5 , HALF_PI, 
             dim_txt_ht , dim_txt_ht , txt_cs );
}

/* ========================================================================= */

place_arrow ( GRid_list, Count, ip1, ip2, ip3, txt_cs, zvec, dim_txt_ht )
struct GRid *GRid_list;
IGRdouble    ip1[3], ip2[3], ip3[3], txt_cs[16], zvec[3], dim_txt_ht;
IGRint	    *Count;
{

  IGRdouble t[3] , t1[3] , t2[3], t3[3] , t4[3] , arrow_matrix[16] ;
  IGRshort  i;
 
//  printpt("zvec", zvec ); 
//  printpt("ip1", ip1 ); 
//  printpt("ip2", ip2 ); 
//  printpt("ip3", ip3 ); 

  /* Calculate the orientation matrix for the arrow head */
  v_sub( ip2 , ip1 , t );
  v_scale( t , 1/v_len( t ), t1);
  v_cross( t1 , zvec , t2 );
  v_scale( t2 , 1/v_len( t2 ) , t3 );

  for( i = 0; i < 16; i = i + 1 ) 
    arrow_matrix[i] = txt_cs[i];
  for( i = 0; i < 3; i = i + 1 )
  {
    arrow_matrix[i] = t1[i];
    arrow_matrix[i+4] = t2[i];
  }

#ifdef DEBUG
  //printpt( "arrow position=" , ip3 );
#endif

  /* Place the arrow head */
  pl_symbol( GRid_list, Count , "Z", ip3 , "102" , 12, 0.0, dim_txt_ht , dim_txt_ht , arrow_matrix );

}

/* ========================================================================= */

pl_symbol( GRid_list, Count , text_str, point, font, just, angle, hscale, wscale, matrix)
struct GRid *GRid_list;
int	    *Count;
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
 

#ifdef DEBUG
 printf("PL_SYMBOL text: %s\n",  text_str );
#endif

        ci$get_module_info( md_env = &MOD_ENV);

   	init_cnst_list();
   	get_symb();
   	dis.color      = cnst_list.color;
   	dis.weight     = cnst_list.weight;
   	dis.style      = cnst_list.style;
 
   	cst.msg        = &rtcd;
   	cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
   	cst.display    = &dis;
   	cst.env_info   = &MOD_ENV;
   	cst.newflag    = 0;
   	cst.level      = cnst_list.level;
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
 
#ifdef DEBUG
 // printf("GRfm.GRvirt_search font: %s, msg=%d, position: %d\n", font_name, msg, position );
#endif

 if(position == -1)
 {
   // if font not found then retrieve it

   font$retrieve(msg             = &msg,
                 font            = font_name,
                 local_font_name = font_name,
                 font_flags      = 0x01,
                 font_position   = &position);
#ifdef DEBUG
   //   printf("font$retrieve font: %s, msg=%d, position: %d\n", font_name, msg, position );
#endif
 }

// get the active text symbology

  size = sizeof( struct GRdpb_text_symb );
  
  gr$get_text_symb(msg     = &msg, 
		   sizbuf  = &size, 
		   buffer  = &text_symb, 
		   nret    = &net);

#ifdef DEBUG
  //  printf("gr$get_text_symb msg=%d\n", msg);
  //  printf("txt height=%.3f, width=%.3f\n", text_symb.Active_height,text_symb.Active_width );
  //  printf("Text: %s\n", text_string );
#endif

  if( strcmp(font_name,"active") != 0 )  
    text_symb.Active_font = position;

  text_symb.Active_just     = text_just;
  text_symb.Active_charspac = 1;
  text_symb.Active_linespac = 1;
  text_symb.Active_height   = ( text_symb.Active_height /  text_symb.Active_height ) * (hscale);
  text_symb.Active_width    = ( text_symb.Active_width / text_symb.Active_width ) * (wscale);

#ifdef DEBUG
//  printf("gr$get_text_symb msg=%d\n", msg);
//  printf("txt height=%.3f, width=%.3f\n", text_symb.Active_height,text_symb.Active_width );
//  printf("Text: %s\n", text_string );
  
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

	
   GRid_list[*Count] = TEXT ;
   *Count = *Count + 1;
}

/*************************************************************/

int getparm( txt, expr )
     char	   txt[40];
struct ret_struct *expr;
{
struct GRid	EXPR ;

  ci$send( msg = message  ACcpx.ACfind_temp_obj( &stat , txt , &EXPR ),
           	targetid = CI_MACRO_ID.objid,
           	targetos = CI_MACRO_ID.osnum );

  ci$send( msg = message  NDnode.NDgive_structure  
		( &stat , (char *)expr , (char *)0 ),  
	    	targetid = EXPR.objid,
	    	targetos = EXPR.osnum );
  return(1);
}

/**************************************************************/

int getobj( index, OBJ )
int		  index;
struct GRobj_env *OBJ;
{

  struct GRid TOBJ ;

  msg = ci$send( msg = message  ACcpx.ACfind_exp_temp_obj(
                 &stat,
                 index,
                 &TOBJ),
                 targetid = CI_MACRO_ID.objid,
                 targetos = CI_MACRO_ID.osnum );
  
  if( !(stat&msg&1) ) return FALSE;
  
  msg = ci$send( msg = message NDmacro.ACreturn_foot(
                 &stat ,
                 "",
                 &OBJ->obj_id,
                 &OBJ->mod_env.md_env.matrix_type,
                 OBJ->mod_env.md_env.matrix ),
                 targetid = TOBJ.objid,
                 targetos = TOBJ.osnum );
  
  OBJ->mod_env.md_id.osnum = OBJ->obj_id.osnum;
  ex$get_modid(   mod_osnum = OBJ->mod_env.md_id.osnum,
                  mod_id    = &OBJ->mod_env.md_id.objid ) ;
  return ( 1 );               
}

/**************************************************************/

compute_cs( Coord, new_cs, origin, xvec, yvec, zvec )
struct GRid Coord;
double *new_cs, *origin, *xvec, *yvec, *zvec;
{
  double cs[16];
  IGRlong msg;


  /* get the location and orientation of the coordinate system */
  ci$send( msg = message GRgencs.GRgetmatrix( &msg, cs ),
                targetid = Coord.objid,
                targetos = Coord.osnum );
#ifdef DEBUG
  //  printcs("cs", cs );
#endif
  
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


}

#endif












