class implementation ASsrctext ;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "fontdef.h"
#include "font.h"
#include "gotextdef.h"
#include "gotext.h"
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "AS_status.h"
#include "macro.h"
#include "batch.h"

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static void ASget_lbsys __((struct GRid ref, struct GRid point, 
                            struct GRid supp, IGRdouble *real_origin, 
                            IGRdouble *target, IGRdouble *trans, 
                            struct ret_struct *suppdef, struct extents *ext, 
                            IGRint in_flag, struct IGRlbsys *lbs_geom, 
                            IGRint *orient, IGRint *flipped, 
                            struct GRmd_env *md_env, IGRint cn_type));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe



extern IGRboolean ASbroadcast_in_progress;

extern GRclassid  OPP_GR3dtext_class_id;

#define AS_DEBUG

#define MAX_TEXT_PAR 20
/* to call change text attribute */


/* asked text position */

#define ASKED 0x3
#define ASKED_AUTO 0x0
#define ASKED_SAME 0x1
#define ASKED_OPPO 0x2

/* asked text justification change */

#define ASKED_FLIP 0x60
#define X_FLIP     0x0
#define XY_FLIP    0x20


/* obtained text position */

#define ACTUEL 0xc
#define ACTUEL_SAME 0x4 
#define ACTUEL_OPPO 0x8

/* Do i need to change justification for this step */

#define FLIPPED 0x10
#define SAME    0x0


/* static text buffer allocation */

%safe
static IGRchar *text_buffer=0;        /* buffer to store text  */
static IGRshort text_buffer_size=0;   /* size of buffer        */
static IGRshort text_buffer_len=0;    /* len of text in buffer */
%endsafe


/* increase size of text buffer if necessary */

AStext_alloc(size)
IGRint size;
{

if(size <= text_buffer_size) return (OM_S_SUCCESS);

   size = size/10; size = 10*(size+1); /* I don't want to realloc for 1 char */

   if(text_buffer_size == 0)text_buffer = om$malloc (size=size);
   		       else text_buffer = om$realloc(size=size,ptr=text_buffer);

   if(text_buffer != 0)
        {text_buffer_size = size; return (OM_S_SUCCESS);}
   else
        {text_buffer_size = 0; return (OM_W_ABORT);}

}

/*****************************************************
   store the text in the text buffer 
******************************************************/

AStext_store(text,len)
IGRchar *text;
IGRint len;
/*.AStext_store*/
{
  IGRint i,status;

  /*"buffer_len: %d, buffer_size: %d\n",text_buffer_len,text_buffer_size*/
  status = AStext_alloc(len);
  if(status != OM_S_SUCCESS) return (status);
  for(i=0;i<len;i++) text_buffer[i] = text[i];
  text_buffer_len = len;
  /*"buffer_len: %d, buffer_size: %d\n",text_buffer_len,text_buffer_size*/
  return(OM_S_SUCCESS);
}
    
/*****************************************************
   get text extents in local coordinate
******************************************************/

ASget_ext(tx_attr,disp_attr,ext)
struct IGResintx *tx_attr;
struct IGRdisplay *disp_attr;
struct extents *ext;


   /*.ASget_ext*/
    {
     IGRint rc,status;
     struct vfont_entry font_info;
     struct GRdpb_text_symb dpb_ts;

        status = ASfind_font_info(tx_attr->estx->font,&font_info);
	as$status(action = RET_STATUS);

 

/* Oh que c'est genial, c'est pas tout a fait la meme !!!!  */
	dpb_ts.Active_font = tx_attr->estx->font;
	dpb_ts.Active_just = tx_attr->estx->just;
	dpb_ts.Active_width = tx_attr->estx->width;
	dpb_ts.Active_height = tx_attr->estx->height;
	dpb_ts.Active_linespac = tx_attr->estx->line_spac;
	dpb_ts.Active_charspac = tx_attr->estx->char_spac;

        if (!GRjust_string(&rc,&text_buffer,&text_buffer_len,&text_buffer_size,
			   &font_info,disp_attr,&dpb_ts,0,NULL,ext))
        {
         printf("error in just string\n");
	 return (OM_W_ABORT);
	}
/*"box %lf %lf %lf %lf\n",ext->left,ext->right,ext->top,ext->bottom*/
/*"buffer_len: %d, buffer_size: %d\n",text_buffer_len,text_buffer_size*/

           /*
            * calculate number of displayable characters
            */


           tx_attr->estx->num_char= 0;
           GRnum_disp_char(&rc,text_buffer,&text_buffer_len,
                           tx_attr->estx->font,font_info.flags,
                           &tx_attr->estx->num_char);



              
    return(OM_S_SUCCESS);
  }

/*****************************************************
   get lbsys definition corresponding to a text
******************************************************/

static void ASget_lbsys(ref,point,supp,real_origin,target,trans,
			suppdef,ext,in_flag,
                        lbs_geom,orient,flipped,md_env,cn_type)

struct GRid ref,point,supp;  /*  ref, point or support GRid or NULL_GRID     */
IGRdouble *real_origin;      /* coordinate of origine of text                */
IGRdouble *target;	     /* target position when AS_COMP_XF		     */
IGRdouble *trans;            /* translation of text in local coordinate      */
struct ret_struct  *suppdef; /* support definition 			     */
struct extents *ext;	     /* extents of text 			     */
IGRint in_flag;		     /* orientation mode text versus suport and ref  */
struct IGRlbsys *lbs_geom;   /* returned lbs_geom definition 		     */
IGRint *orient;	             /* text orientation versus support 	     */
IGRint *flipped;	     /* As text justification changed for this step  */
struct GRmd_env *md_env;
IGRint cn_type;

/*.ASget_lbsys*/
{
 IGRmatrix mat;
 IGRdouble  axex[3],axey[3],norm[3],new_origin[3],prov[3],scale,*origin,
	    x_positive;
 IGRint status,i,ix,iter,nter;
 IGRdouble one = 1;
 IGRint prev_orient;

/* compute position and coordinate system */

   if(IF_NULL_OBJID(ref.objid)) MAidmx(&status,lbs_geom->matrix);
   if(IF_NULL_OBJID(point.objid)) v_identity(real_origin);
  
/* if support find tangency vector on support */
/* An iterative procedure is necessary a have tangent for middle text */

/*"box %lf %lf %lf %lf\n",ext->left,ext->right,ext->top,ext->bottom*/

   prev_orient = in_flag & ACTUEL;
   origin = real_origin;
   if(!IF_NULL_OBJID(supp.objid))
     {
      AStrans_mat(lbs_geom->matrix,mat);

      nter = 4;
      for(iter=0 ; iter<nter ; iter++)
	{
         if (suppdef->type & line_generic)
           {
	    /*| supp is a line */
	    scale = -v_dot(suppdef->var.line_st.v0,mat+8);
	    v_comb(one,suppdef->var.line_st.v0,scale,mat+8,axex);
	    scale = v_len(axex);
 	    if(scale != 0) { scale = 1/scale; v_scale(axex,scale,axex); }
		      else { v_equal(mat,axex); }
	    v_cross(mat+8,axex,axey);
           }

        
         else if (suppdef->type & conic_generic) 
	   {
	    /*| supp is a circle */
	    /* Modify jla 18-april-89 */
	   
	    /*
	       compute the direction vector from the center of the circle     
	       to the projection of the placement point into the plane
	       of the circle
	    */

	    v_sub(origin,suppdef->var.circle_st.cent_p,axey);

	    /*^ pr_point("cent_p",suppdef->var.circle_st.cent_p); */
            
 	    norm[0] = suppdef->var.circle_st.mat[2];
 	    norm[1] = suppdef->var.circle_st.mat[6];
 	    norm[2] = suppdef->var.circle_st.mat[10];

	    /*^ pr_point("normale",norm); */

	    scale = -v_dot(norm,axey);
	    /*"scale %lf\n",scale */
	    v_comb(one,axey,scale,norm,axey);
	    /*^ pr_point("axey",axey); */

	    /* find coresponding tangent vector to the circle */
         
	    scale = v_len(axey);
	    /*"scale %lf\n",scale */
	    
 	    if(scale != 0)
	      { scale = 1./scale;
		v_scale(axey,scale,axey);
	        v_cross(norm,axey,axex);
	      }
	    else
	      { /* The project point is the center of the circle */
		axex[0] = suppdef->var.circle_st.mat[0];
	        axex[1] = suppdef->var.circle_st.mat[4];
	        axex[2] = suppdef->var.circle_st.mat[8];
	      }


/* KLUDGE BECAUSE TEXT ON ARC USED TO BE WITH A REVERSE ORIENTATION 
   BEFORE MAY 89. TO BE MODIFIED WHEN DIM CAN DO THE CORRESPONDING 
   TRANSFORMATION
*/
            v_neg(axex,axex);

	  
	   /* Project now in Oxy plane */

            scale = -v_dot(axex,mat+8);
            v_comb(one,axex,scale,mat+8,axex);
            scale = v_len(axex);
            if(scale != 0) { scale = 1/scale; v_scale(axex,scale,axex); }
                      else { v_equal(mat,axex); }

   

	    v_cross(mat+8,axex,axey);
	    /*^ pr_point("axex",axex); */
	    /*^ pr_point("axey",axey); */
	   }

	 else if(suppdef->type & curve_generic)
	   {
	    struct ret_struct ptprov,lineprov;
	    v_equal(origin,ptprov.var.point_st.pt);
	    lineprov.type = curve_generic;
	    status = ASlineangl_vor(&ptprov,&lineprov,supp,md_env);
            scale = -v_dot(lineprov.var.line_st.v0,mat+8);
            v_comb(one,lineprov.var.line_st.v0,scale,mat+8,axex);
            scale = v_len(axex);
            if(scale != 0) { scale = 1/scale; v_scale(axex,scale,axex); }
                      else { v_equal(mat,axex); }
            v_cross(mat+8,axex,axey);
	   }


       /*"axex %lf %lf %lf\n",axex[0],axex[1],axex[2] */
   
      /*
         reverse vector
	 - if asked : in_flag & ASKED_OPPO
	 - if asked and necessary to have local and referential y axis in
           the same direction in_flag & ASKED_AUTO
      */

	 switch (in_flag & ASKED)
	   {
	    case ASKED_AUTO :
         	scale = v_dot(axey,mat+4);
         	if(scale<-1.e-2 || (scale < 1.e-2 && v_dot(axey,mat)>0.) )
           	  {
            	   v_neg(axex,axex);v_neg(axey,axey);
            	   *orient = ACTUEL_OPPO ;
           	  }
          	else *orient  = ACTUEL_SAME;
		break;

	
	    case ASKED_OPPO :
		v_neg(axex,axex); v_neg(axey,axey);
            	*orient = ACTUEL_OPPO ;
		break;


	    case ASKED_SAME :
            	*orient = ACTUEL_SAME ;
		break;
	  }

      /*
	 A change of the positive sens of the text will imply a justification
         changed and the change sign of me->trans[0] only if text orientation
         versus support orientation was already defined (call from compute or
         place afer first iteration).
      */
	 if((prev_orient != *orient) && (prev_orient != 0)) x_positive= -1;
						       else x_positive=  1;
	 if(prev_orient == 0) prev_orient = *orient;

	 /* evaluate origine from translation */
	 /*"cn_type %d\n",cn_type */
	 if( (cn_type&ND_COMP_TYPE) != ND_COMP_XF)
	    {
             for(i=0;i<3;i++)
                {
                 lbs_geom->matrix[4*i]   = axex[i];
                 lbs_geom->matrix[4*i+1] = axey[i];
             	 lbs_geom->matrix[4*i+3] = real_origin[i] +
	    	     	      x_positive*axex[i]*trans[0] + axey[i]*trans[1] ;
		}
	    }


	 else
	    {
	     /* modify translation vector to  obtain real_origin */
             for(i=0;i<3;i++)
                {
                 lbs_geom->matrix[4*i]   = axex[i];
                 lbs_geom->matrix[4*i+1] = axey[i];
             	 lbs_geom->matrix[4*i+3] = target[i];
		}
	     v_sub(target,real_origin,prov);
	     ASmatv(ASMV_VECTOR|ASMV_INVERT,lbs_geom,prov,trans);
	     trans[0] = trans[0]*x_positive;
	     /*^
		pr_mat("lbs",4,4,lbs_geom->matrix);
	        pr_point("target ",target);
	        pr_point("real_origin ",real_origin);
	        pr_point("prov ",prov);
	     */
	    }
	     

       /* control solution. Need to compute middle of box */

         if (suppdef->type & line_generic) 
	    {if(prev_orient == 0) prev_orient = *orient;
	     break;
	    }
	 if(iter == nter) break;
      
	

	 for(ix=0,i=0 ; ix<3 ; ix++,i++) new_origin[ix] = 0.5*x_positive*(
	    		lbs_geom->matrix[i++]*(ext->left+ext->right) +
	    		lbs_geom->matrix[i++]*(ext->top+ext->bottom) )
          	+ lbs_geom->matrix[++i];
	 origin = new_origin;
	/*"origine %lf %lf %lf\n",origin[0],origin[1],origin[2] */

       } /* loop on iterations  */
     }

   /*^ pr_mat("placement matrix",4,4,lbs_geom->matrix); */
  

/* text is not on a support */
   else
     {
      *orient = ACTUEL_SAME;prev_orient = ACTUEL_SAME;
      lbs_geom->matrix[3]  = real_origin[0] + lbs_geom->matrix[0]*trans[0] +
      	       lbs_geom->matrix[1]*trans[1] + lbs_geom->matrix[2]*trans[2] ;

      lbs_geom->matrix[7]  = real_origin[1] + lbs_geom->matrix[4]*trans[0] +
      	       lbs_geom->matrix[5]*trans[1] + lbs_geom->matrix[6]*trans[2] ;

      lbs_geom->matrix[11] = real_origin[2] + lbs_geom->matrix[8]*trans[0] +
      	       lbs_geom->matrix[9]*trans[1] + lbs_geom->matrix[10]*trans[2] ;
     }

/* Will the text be flipped ? */

   if(prev_orient != *orient) *flipped = FLIPPED;
		          else    *flipped = SAME;

/*
   compute box (I don't understand why this compute is not done by
   the GRtext.Grconstruct or postabs method)
*/
    if(*flipped == SAME)
      {lbs_geom->diag_pt1[0] = ext->left;
       lbs_geom->diag_pt1[1] = ext->bottom;
       lbs_geom->diag_pt2[0] = ext->right;
       lbs_geom->diag_pt2[1] = ext->top;}
    else if ((in_flag&ASKED_FLIP) == X_FLIP)
      {lbs_geom->diag_pt1[0] = ext->right;
       lbs_geom->diag_pt1[1] = ext->bottom;
       lbs_geom->diag_pt2[0] = ext->left;
       lbs_geom->diag_pt2[1] = ext->top;}
     else
      {lbs_geom->diag_pt1[0] = ext->right;
       lbs_geom->diag_pt1[1] = ext->top;
       lbs_geom->diag_pt2[0] = ext->left;
       lbs_geom->diag_pt2[1] = ext->bottom;}

    lbs_geom->diag_pt1[2] = 0;
    lbs_geom->diag_pt2[2] = 0;

/*^ 
    pr_mat("lbs_mat",4,4,lbs_geom->matrix);
    pr_point("lbs_pt1",lbs_geom->diag_pt1);
    pr_point("lbs_pt2",lbs_geom->diag_pt2);
*/
}



/*----------------------------------------------------------------------------
/*
/* Place an associative text
/* The possible parents are :
/* 
/* a referential : gives the y positive sens of the vue
/* a point       : gives the place where the text is to be placed
/* a curve       : projection of the point on the curve gives tangent vector to
/*		 be used to place the text
/*
------------------------------------------------------------------------------*/


method NDplace(struct GRas *asso_lis;struct GRmd_env *md_env;
	       IGRchar *go_cnst_lis)
{
 struct GRid *list;
 IGRint num,i,j;
 struct GRid ref,point,supp;
 IGRint flipped,orient;
 struct ret_struct  def,suppdef;
 IGRdouble origin[3];
 struct IGRlbsys lbs_geom;
 struct IGResintx *tx_attr;
 struct extents ext;
 IGRint type[MAX_TEXT_PAR];
 IGRdouble *snap;
 IGRint save_just;
 IGRlong status,msg;
 struct IGRdisplay *disp_attr;


/* get parents */

   list = asso_lis->parents;
   num = asso_lis->num_parents;
   if(num >= MAX_TEXT_PAR) { printf("to many parents for a text\n");
		             return(OM_W_ABORT);}
   tx_attr = (struct IGResintx *)
			 ((struct GRvg_construct *)go_cnst_lis)->class_attr;

   ref=NULL_GRID;point=NULL_GRID;supp=NULL_GRID;
   for (i=0 ; i<num ; i++)
    {
     status = om$send(msg = message NDnode.NDgive_structure(&msg,&def,md_env),
		      targetid = (list+i)->objid,
		      targetos = (list+i)->osnum);
     if((!status&1)) continue;
     type[i] = def.type;   /* type for evaluate message */

     if(def.type & ref_generic)
	 {
	  for(j=0;j<16;j++) lbs_geom.matrix[j]=def.var.ref_st.t[j];
	  ref = list[i];
	 }

     else if(def.type & point_generic)
	 {
	  v_equal(def.var.point_st.pt,origin);
	  point = list[i];
	 }

     else if(def.type & line_generic || def.type & conic_generic
				     || def.type &curve_generic)
	 {
	  suppdef = def;
	  supp = list[i];
  	 }
    }

/* get flag and translation in local coordinate if any */

   snap = (IGRdouble *) asso_lis->as_attr;
   me->flag = (IGRint) *snap & (ASKED | ASKED_FLIP);
/*"me->flag %x\n",me->flag */
   snap += 1;
   me->trans[0] = *snap;
   me->trans[1] = *(snap+1);
   me->trans[2] = 0;

/* evaluate text and get extents in local coordinate */

  status = om$send (msg = message ASsrctext.ASevaluate(num,list,type,md_env),
	    	     targetid = my_id);
  as$status(action = RET_STATUS);

  if(text_buffer_len == -1)
     {
      AStext_store(tx_attr->text_string,(IGRint)tx_attr->estx->text_length);
     }


  tx_attr->text_string = text_buffer;
  tx_attr->estx->text_length = text_buffer_len;


/*"tx_attr->estx->text_length: %d\n",tx_attr->estx->text_length */
  disp_attr = ((struct GRvg_construct *)go_cnst_lis)->display;
  status  = ASget_ext(tx_attr,disp_attr,&ext);

  tx_attr->text_string = text_buffer;
  tx_attr->estx->text_length = text_buffer_len;
/*"tx_attr->estx->text_length: %d\n",tx_attr->estx->text_length */

/* compute position and coordinate system */

ASget_lbsys(ref,point,supp,origin,NULL,snap,&suppdef,&ext,me->flag,&lbs_geom,
 	    &orient,&flipped,md_env,0);

me->flag = me->flag | orient | flipped;
				 /* to know if text is in same or reverse */
				 /* position of curve */

save_just = tx_attr->estx->just;
if(flipped == FLIPPED)           /* I have to change justif due to iterations */
				 /* in ASget_lbsys			      */
  {
   if((me->flag & ASKED_FLIP) == X_FLIP)
     {
      /*| only change x justif */
      if(tx_attr->estx->just<5)      tx_attr->estx->just=tx_attr->estx->just+10;
      else if(tx_attr->estx->just>9) tx_attr->estx->just=tx_attr->estx->just-10;
      else  		    	     tx_attr->estx->just = tx_attr->estx->just;
      me->trans[0] = -me->trans[0];
     }
   else
     {
      /*| change x and y justif */
      tx_attr->estx->just  = 14 - tx_attr->estx->just;
      me->trans[0] = -me->trans[0];
      me->trans[1] = -me->trans[1];
     }
   status  = ASget_ext(tx_attr,disp_attr,&ext);

   tx_attr->text_string = text_buffer;
   tx_attr->estx->text_length = text_buffer_len;
  }

 if(go_cnst_lis != NULL)
   {
   ((struct GRvg_construct *)go_cnst_lis)->geometry = (char *) &lbs_geom;
    status = om$send( msg = message ASnode.ASconstruct_go
		      (asso_lis,md_env,go_cnst_lis,OPP_GR3dtext_class_id,FALSE),
	    	      targetid = my_id);

/* restore justif to not affect ci file or command object */
    tx_attr->estx->just = save_just ;
    if(!(status&1)) return (status);
    }



  /*------------------------------------------------------------------
  we ask the graph manager to add the new AStext to the graph 
--------------------------------------------------------------------*/

  status=om$send(msg =  message NDnode.NDconnect(num,list,NULL_GRID,ND_NEW),
      		 targetid = my_id);
  as$status();

  return(status);

} /* place */



/*------------------------------------------------------------------------------
/*
/* Compute node : recompute an associative text when a graphic object this
/*                text depends upon move
/*
/*----------------------------------------------------------------------------*/

method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count;struct GRid list[];struct GRmd_env *md_env)
{
 IGRint i,j,status;
 struct GRid ref,point,supp;
 IGRint flipped,orient;
 struct ret_struct  def,suppdef;
 IGRdouble origin[3],target[3];
 struct IGRlbsys *init_lbs,lbs_geom;
 struct IGRestx   tx_attr;
 struct GRdpb_text_symb text_symb;
 struct extents ext;
 IGRint type[MAX_TEXT_PAR];
 short  text_len, old_text_len;
 int    attr_number;
 IGRchar *ptr = NULL;

/* get parents */
/*"cn_type %d\n", cn_type */
/*^pr_point("trans",me->trans); */

   if(count >= MAX_TEXT_PAR)
            { printf("to many parents for a text doesn't update\n");
	      return(OM_S_SUCCESS);}


   ref=NULL_GRID;point=NULL_GRID;supp=NULL_GRID;
   for (i=0 ; i<count ; i++)
    {
     status = om$send(msg = message NDnode.NDgive_structure(msg,&def,md_env),
		      targetid = list[i].objid,targetos = list[i].osnum);
     if((!status&1)) continue;
     type[i] = def.type;   /* type for evaluate message */

     if(def.type & ref_generic)
	 {
	  for(j=0;j<16;j++) lbs_geom.matrix[j]=def.var.ref_st.t[j];
	  ref = list[i];
	 }

     else if(def.type & point_generic)
	 {
	  v_equal(def.var.point_st.pt,origin);
	  point = list[i];
	 }

     else if(def.type & line_generic || def.type & conic_generic ||
					def.type & curve_generic)
	 {
	  suppdef = def;
	  supp = list[i];
  	 }
    }

  status = om$send (msg = message ASsrctext.ASevaluate(count,list,type,md_env),
	    	     targetid = my_id);
  as$status(action = RET_STATUS);


/*
   If new text_string ASchgtextstr will return new size in local coordinate
   If the string has not change text size returneb by genabs
 */


   if(text_buffer_len != -1)
     {
      /*| change text string */
      text_len = text_buffer_len;
      status = om$send(msg=message GRtext.GRreplace_text(msg,md_env,
							 text_len, (IGRuchar *)text_buffer),
		       p_chanselect = &AS_to_comp);
      as$status(action = RET_STATUS);

     }

      /* get extends of the text */

      status = om$send(msg=message GRtext.GRgenabsg(msg,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					&ptr),
		       p_chanselect = &AS_to_comp);
      as$status(action = RET_STATUS);
      init_lbs = (struct IGRlbsys *)ptr;


      ext.left   = init_lbs->diag_pt1[0];
      ext.bottom = init_lbs->diag_pt1[1];
      ext.right  = init_lbs->diag_pt2[0];
      ext.top    = init_lbs->diag_pt2[1];

/*^pr_mat("lbs",4,4,init_lbs->matrix); */
/*"left %lf bottom %lf right %lf top %lf\n",ext.left,ext.bottom,ext.right,ext.top */



/* find position in global coordinate and placement matrix */

   if( (cn_type&ND_COMP_TYPE) == ND_COMP_XF)
     {
      target[0] = init_lbs->matrix[3];
      target[1] = init_lbs->matrix[7];
      target[2] = init_lbs->matrix[11];
      /*^ pr_point("target",target); */
     }
	

    ASget_lbsys(ref,point,supp,origin,target,me->trans,&suppdef,&ext,me->flag,
		&lbs_geom,&orient,&flipped,md_env,cn_type);


/* do I need to change justification ? */

if( (orient&ACTUEL) != (me->flag&ACTUEL))
  {
   /*| change orient */

   me->flag = (me->flag & ~ACTUEL) | (orient&ACTUEL);
   me->flag = (me->flag & ~FLIPPED) | (~me->flag & FLIPPED);

   status = om$send(msg = message GRtext.GRgettxattr
			(msg,&tx_attr,&old_text_len,NULL),
		    p_chanselect = &AS_to_comp);
   as$status(action = RET_STATUS);

/*"me->flag %x ASKED_FLIP %x X_FLIP %x\n",me->flag,ASKED_FLIP,X_FLIP */
   if((me->flag & ASKED_FLIP) == X_FLIP)
     {
      /*| only change x justif */
      if(tx_attr.just<5)       text_symb.Active_just = tx_attr.just+10;
      else if(tx_attr.just>9)  text_symb.Active_just = tx_attr.just-10;
      else  		       text_symb.Active_just = tx_attr.just;
      me->trans[0] = -me->trans[0];
     }
   else
     {
      /*| change x and y justif */
      text_symb.Active_just  = 14 - tx_attr.just;
      me->trans[0] = -me->trans[0];
      me->trans[1] = -me->trans[1];
     }

   if(tx_attr.just != text_symb.Active_just)
     {
      /*| change text attr */
      attr_number =  GRTEXT_JUST;
      status = om$send(msg=message GRtext.GRchgtextattr(msg,md_env,
						attr_number,&text_symb),
		       p_chanselect = &AS_to_comp);
      as$status(action = RET_STATUS);

      status = om$send(msg=message GRtext.GRgenabsg(msg,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					&ptr),
		       p_chanselect = &AS_to_comp);
      as$status(action = RET_STATUS);
      init_lbs = (struct IGRlbsys *)ptr;


      ext.left   = init_lbs->diag_pt1[0];
      ext.bottom = init_lbs->diag_pt1[1];
      ext.right  = init_lbs->diag_pt2[0];

      lbs_geom.diag_pt1[0] = ext.left;
      lbs_geom.diag_pt1[1] = ext.bottom;
      lbs_geom.diag_pt1[2] = 0;
      lbs_geom.diag_pt2[0] = ext.right;
      lbs_geom.diag_pt2[1] = ext.top;
      lbs_geom.diag_pt2[2] = 0;
     }
  }

/*| update text position */
{
 struct GRpost_info post_info;
 GRobjid newobjid;

    post_info.construct_flag = FALSE;
    status = om$send(msg = message GRvg.GRpostabsg(msg,md_env,
				&post_info, (IGRchar *) &lbs_geom,&newobjid),
		   p_chanselect = &AS_to_comp);
    as$status(action = RET_STATUS);
  }


  GRabsg_del_all();
  return (OM_S_SUCCESS);
}
  

  

/*------------------------------------------------------------------------------
/* 
/*  GRxform changes position of text
/*
/*----------------------------------------------------------------------------*/

method GRxform(IGRlong *msg; struct GRmd_env *md_env; 
	       IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
 IGRlong status;
 struct GRid my_grid;
 IGRint cn_type;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
 as$status();

if (!ASbroadcast_in_progress)
 {
  cn_type = ND_COMP_XF;
  nd$wait_batch(type = GR_GEOM_POSTED,
		l_object = &my_grid, l_obj_info = &cn_type,
		nb_obj = 1);
 }

*newobjid = my_id;
return(status);
}

/*------------------------------------------------------------------------------
/*
/* Give_structure : return GEOMETRIC structure of an associative text (box)
/*                  Used by intersection point and index point
/*
/*----------------------------------------------------------------------------*/

method NDgive_structure(IGRlong *msg; struct ret_struct *inst;
			struct GRmd_env *md_env)
 {
  IGRchar *ptr;				/* abstract geom pointer	     */

  IGRdouble *matrix;
  IGRmatrix mat_id;			/* environment matrix                */
  IGRshort mat_type;			/* environment matrix type           */
  struct IGRlbsys *lb_def;

  IGRlong i;				/* index			     */
  IGRlong status;			/* OM return code		     */


if( md_env == NULL)
  {
   mat_type = MAIDMX;
   MAidmx(&msg,mat_id);
   matrix = mat_id;
  }
else
  {
   mat_type = md_env->md_env.matrix_type;
   matrix   = md_env->md_env.matrix;
  }

  status = om$send(msg = message GRvg.GRgenabsg(msg,&mat_type,matrix, &ptr),
		   p_chanselect = &AS_to_comp);
  as$status(action = RET_STATUS);



  lb_def = (struct IGRlbsys *) ptr;

  for (i=0 ; i<16 ; i++)  inst->var.lb_st.matrix[i] = lb_def->matrix[i]; 

  for (i=0 ; i<3 ; i++) inst->var.lb_st.diag_pt1[i] = lb_def->diag_pt1[i];

  for (i=0 ; i<3 ; i++) inst->var.lb_st.diag_pt2[i] = lb_def->diag_pt2[i];

  if((me->flag & FLIPPED) == FLIPPED) inst->type = lbs_flipped;
  else				     inst->type = lbs_not_flipped;


  return(OM_S_SUCCESS);
  

}


/*
     ASsrctext doesn't know how to evaluate itself -->
     take text from construction list for placement
     and doesn't modify the text for recompute
*/
 
method  ASevaluate(IGRint num;struct GRid *list;IGRint *type;
		   struct GRmd_env *md_env)
{
text_buffer_len = -1;
return(OM_S_SUCCESS);
}


method ACcompute_node( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *prop,*size_inst,*no_go;
			   char *inst_save)
{
int siz_inst,status;

/*^pr_point("me->trans ACcom entry",me->trans); */
 siz_inst=sizeof(struct ASsrctext_instance);
 
#define ND_INST_OVER 0x80 
 if(!(me->state&ND_INST_OVER) && (*prop&ACinst_ch_in))
  {
  /*| inst over */
  OM_BLOCK_MOVE(  inst_save,me->trans, 
		siz_inst);
  }
 else
  {
  /*| pas inst over */
  printf("instance overide of text won't be suported in near future !!!\n");
  me->state&= (~ND_INST_OVER);
  }

/*^pr_point("me->trans ACcom avant NDcomp",me->trans); */
 status = om$send(msg =  message NDnode.NDcompute_node (msg,cn_type ,
					count,list, 
					md_env),
  		   targetid =my_id ); 
 as$status( );

 if (!( (me->state) & ND_OUT_OF_RT)&& *no_go != -1 )
      {*no_go += 1;}
 OM_BLOCK_MOVE( me->trans, inst_save,
		siz_inst);
 *size_inst += siz_inst ;
 return (1) ;
}

method NDprint_root(struct GRmd_env *md_env ; FILE *stream)
{
 om$send(msg = message NDnode.NDprint(md_env,stream),
	 targetid = my_id);
 return(OM_S_SUCCESS);
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  IGRlong status, msg;
  IGRchar *text_addr,*ptr = NULL;
  IGRshort text_len;
  IGRint i_in,i_out;
  IGRchar class_n[OM_K_MAXCLASS_LEN];
  struct IGRestx text_attr;



  /* Get the name of this object */

  as$printer_set_name( prefix = "AS_TEXT", name = name );
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and  Symbology */

  as$printer_print_parents(count=&count);
  as$printer_print_symb();

  text_addr = NULL;
  text_len = 0;

  status = om$send (msg = message GRtext.GRgettxattr
                         (&msg, &text_attr, &text_len,(IGRuchar **)&text_addr),
                    p_chanselect = &AS_to_comp);
  as$status(action = GOTO_VALUE, value  = wrapup);

  ptr = text_addr;

/*" 2er txattr text_len %d\n",text_len */

  /*| suppress escape sequence */
  for(i_in=0,i_out=0;i_in<text_len;)
    {
     /*"%d -> %d\n",i_in,text_addr[i_in]  */
     if(text_addr[i_in] == 27) i_in=i_in+10;
     else text_addr[i_out++] = text_addr[i_in++];
    }

/*" i_out %d\n",i_out */
    text_addr[i_out] = '\0';
    fprintf(stream, "cnst_list.font = %d;\n",text_attr.font);
    fprintf(stream, "cnst_list.just = %d;\n",text_attr.just);
    fprintf(stream, "cnst_list.width = %lf;\n",text_attr.width);
    fprintf(stream, "cnst_list.height = %lf;\n",text_attr.height);
    fprintf(stream, "cnst_list.num_char = %d;\n",i_out);
    fprintf(stream, "cnst_list.line_spac = %lf;\n",text_attr.line_spac);
    fprintf(stream, "cnst_list.char_spac = %lf;\n",text_attr.char_spac);
    fprintf(stream, "cnst_list.text_length = %d;\n",i_out);
    fprintf(stream, "cnst_list.text_string = \"%s\";\n",text_addr);

    fprintf(stream, "set_text_attr();\n");
  





  /* Print the instances */

  fprintf(stream,"ptr[0]=%lf;\n",(IGRdouble) me->flag);
  fprintf(stream,"ptr[1]=%lf;\n",me->trans[0]);
  fprintf(stream,"ptr[2]=%lf;\n",me->trans[1]);
  fprintf(stream,"ptr[3]=%lf;\n",me->trans[2]);

  /*get my class name */
  om$get_classname(objid = my_id, classname = class_n);

  /* Print the message */

    fprintf(stream,"send %s.place(%d,list,ptr) to %s;\n\n",class_n,count,name);


  wrapup : if(ptr != NULL) om$dealloc( ptr = ptr);

  return(OM_S_SUCCESS);
}/* end print */


end implementation ASsrctext ;
