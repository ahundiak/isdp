class implementation ov_ci_mac;
/*--------------------------------------------------------------------------*/
/*
/*  ov_ci_maci.I
/*  robert patience
/*  29 april 91
/*
/*	15 decembre 1992 : 	Release 2.1.1.1
/*				Bruno Demars
/*				remove code managing the srf_cyl, srf_pro
/*				and srf_bend from the method ci_kl_NDcompute_node
/*				which avoid a memory fault when placing the 
/*				butterfly valve ( Diam 8").
/*---------------------------------------------------------------------------
/* */

#define AS_DEBUG	/* debug pre-processor */

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igrdef.h"    
#include "grdpbdef.h"    
#include "grdpbmacros.h"    
#include "AS_status.h"
#include "VDmem.h"


from ACmacro_defn		import ACgive_name ;

/* ========================================================================= */
#define  REF        "ref"          /* Connect point referential		*/
#define  WIDTH      "width"        /* dim for piping			*/
#define  DEPTH      "depth"  	   /* depth for type of cpt		*/
#define  SECTION    "section"      /* 0 rect,1 oval,2 circ		*/
#define	 KL_SECT    16
#define  END_PREP   "end_prep"     /* end prep 				*/
#define  PRESSURE   "pressure"     /* pressure				*/
#define  CPT_OFF    "cpt_off"      /*connect pnt offs,gap HVAC,gask PIPE*/
#define  GRAPHIC    "graphic"      /* graphic representation		*/
#define  AXIS	    "axis"         /* cpt x axis 	*/
#define  YAXIS	    "yaxis"        /* cpt y axis 	*/

struct xyz
 {
  double             width,depth,pressure,cpt_off; 
  short		     section,end_prep;
  double             z_vector[3], y_vector[3];
 };

struct	VRcp_attr 
{
   double 	   width;	/* diameter in piping */
   double       depth;
   char         section_mask;   /* bit4 : VR_IN/VR_OUT
                                   bit5 : VR_RED/VR_GREEN
                                   bit0 to 3 : VR_ROUND,VR_OVAL,VR_RECT
				   */
   int          end_prep;
   double       pressure;
   double       cp_offset;
};


method ci_kl_user_func( 
			IGRchar			*entry;
			struct GRmd_env		*mod_env;
			char   			*user_data;
		       )
{
int status;
char *mdef_name;
struct GRid mdef_mac;
struct	VRcp_attr *attr;
struct xyz *newme;

 status = om$send(msg = message ACcpx.find_macro(&mdef_mac),
	           targetid = my_id);
 status = om$send(msg = message ACmacro_defn.ACgive_name(&mdef_name),
		   targetid = mdef_mac.objid,
		   targetos = mdef_mac.osnum);

 if(strcmp("VRcpt",mdef_name)) return(0);
 newme=(struct xyz *) (me->internal_buffer);
 attr=(struct	VRcp_attr 	*)user_data;

 attr->width=newme->width;
 attr->depth=newme->depth;
 attr->section_mask=(char )newme->section;
 attr->end_prep=newme->end_prep;
 attr->pressure=newme->pressure;
 attr->cp_offset=newme->cpt_off;

 return(1);
}



method ci_kl_ACgive_structure(int *suc,*direct_index;char *feet_name;
                struct ret_struct *ptr_rst;struct GRmd_env *md_env)
{
int i,status;
char *mdef_name;
struct GRid mdef_mac;
struct xyz *newme;
int 	vla_sz;

 status = om$send(msg = message ACcpx.find_macro(&mdef_mac),
	           targetid = my_id);
 status = om$send(msg = message ACmacro_defn.ACgive_name(&mdef_name),
		   targetid = mdef_mac.objid,
		   targetos = mdef_mac.osnum);

 if(strcmp("VRcpt",mdef_name)) return(0);

 vla_sz = om$dimension_of(varray=me->internal_buffer);
      if(sizeof(struct xyz) >  vla_sz)
      { 
        status = om$vla_set_dimension(varray=me->internal_buffer 
			,size =sizeof(struct xyz));
        as$status( );
      }
 newme=(struct xyz *) (me->internal_buffer);

 *suc=1;
 ptr_rst->type=parameter_generic | double_type;
 if(!strcmp(feet_name,AXIS))
   {
   ptr_rst->type= point_generic ;
     if(newme->section & KL_SECT)
       {
	for (i=0;i<3;i=i+1)
	{
		ptr_rst->var.point_st.pt [i] =	0;
	}/* end loop */
       }
     else
       {
	for (i=0;i<3;i=i+1)
	{
		ptr_rst->var.point_st.pt [i] =	
		newme->z_vector [0] * md_env->md_env.matrix [i*4] +
		newme->z_vector [1] * md_env->md_env.matrix [i*4+1] +
		newme->z_vector [2] * md_env->md_env.matrix [i*4+2];
	}/* end loop */
       }
   }
 else if(!strcmp(feet_name,YAXIS))
   {
   ptr_rst->type= point_generic ;
	for (i=0;i<3;i=i+1)
	{
		ptr_rst->var.point_st.pt [i] =	
		newme->y_vector [0] * md_env->md_env.matrix [i*4] +
		newme->y_vector [1] * md_env->md_env.matrix [i*4+1] +
		newme->y_vector [2] * md_env->md_env.matrix [i*4+2];
	}/* end loop */
   }
 else if(!strcmp(feet_name,WIDTH))
   ptr_rst->var.root_pm_st.value= newme->width; 
 else if(!strcmp(feet_name,DEPTH))
   ptr_rst->var.root_pm_st.value= newme->depth; 
 else if(!strcmp(feet_name,SECTION))
   ptr_rst->var.root_pm_st.value= (double) (newme->section &(~KL_SECT)); 
 else if(!strcmp(feet_name,END_PREP))
   ptr_rst->var.root_pm_st.value= (double) newme->end_prep; 
 else if(!strcmp(feet_name,PRESSURE))
   ptr_rst->var.root_pm_st.value= newme->pressure; 
 else if(!strcmp(feet_name,CPT_OFF))
   ptr_rst->var.root_pm_st.value= newme->cpt_off;
 else {*suc=0;}

 return(1);
}


method ci_kl_ACget_context_s_compute( IGRlong *msg; IGRint cn_type;
			   struct GRmd_env *md_env;
			   struct GRid context_obj)
{
int 			status;
IGRuint			size;
struct GRid		*list;

    status =om$get_channel_count( objid = my_id,
				p_chanselect = &AC_template_chns,
				count = &size );
    as$status( );
    if(size)
     list =(struct GRid *)_MALLOC(size, struct GRid );
    if (!list) return OM_E_NODYNMEM;

    ACmagic_read(my_id, &AC_template_chns, list, size);

    status = om$send(msg = message ov_ci_mac.ci_kl_NDcompute_node
		   (msg,cn_type,size,list,md_env),
	           targetid = my_id);
    /*^ as$status(); */

    if(size) _FREE(list);

  return(status);
}

kl_int_cnst(dis,cst)
struct GRvg_construct   *cst;
struct IGRdisplay	*dis;
{
   dis->weight 		= 0;
   dis->style 		= 0;
   dis->color		= 1;
   cst->properties	= GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
   cst->display		= dis;
   cst->newflag		= 0;
   cst->level		= 1;
   cst->geometry	= 0;
   cst->class_attr	= 0;
   cst->name		= 0;
   return(1);
}


#define EPSILON 	1.E-10 


method ci_kl_NDcompute_node ( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env)
{
int 		status,retmsg;
IGRlong		stat;
char 		*mdef_name;
struct GRid 	mdef_mac;
struct xyz 	*newme;
struct GRid	map_obj;

 map_obj.objid = NULL_OBJID;

 status = om$send(msg = message ACcpx.find_macro(&mdef_mac),
	           targetid = my_id);
 status = om$send(msg = message ACmacro_defn.ACgive_name(&mdef_name),
		   targetid = mdef_mac.objid,
		   targetos = mdef_mac.osnum);
    as$status( );

 /*"macro computing = %s\n",mdef_name  */

 if(strcmp("VRcpt",mdef_name)) return(0);

	/* COMPUTE VRcpt macro */
   {
   int    k;
   struct GRvg_construct   	cst;
   struct IGRdisplay		dis;
   struct IGRpolyline      	geom;
   IGRdouble			tab[6];
   struct ret_struct		st_ref ,expr;
   int 				vla_sz;

   vla_sz = om$dimension_of(varray=me->internal_buffer);
      if(sizeof(struct xyz) >  vla_sz)
      { 
        status = om$vla_set_dimension(varray=me->internal_buffer 
			,size =sizeof(struct xyz));
        as$status( );
      }
   /*"size is %d %d\n",vla_sz,sizeof(struct xyz)*/

   newme=(struct xyz *) (me->internal_buffer);
   status=om$send( msg = message  NDnode.NDgive_structure(&stat, &expr, md_env),
	   	 targetid = list[1].objid,
		 targetos = list[1].osnum); as$status();
   newme->width = expr.var.root_pm_st.value;
   status=om$send( msg = message  NDnode.NDgive_structure(&stat, &expr, md_env),
	   	 targetid = list[2].objid,
		 targetos = list[2].osnum); as$status();
   newme->depth = expr.var.root_pm_st.value;
   status=om$send( msg = message  NDnode.NDgive_structure(&stat, &expr, md_env),
	   	 targetid = list[3].objid,
		 targetos = list[3].osnum); as$status();
   newme->section = (short) expr.var.root_pm_st.value;
   status=om$send( msg = message  NDnode.NDgive_structure(&stat, &expr, md_env),
	   	 targetid = list[4].objid,
		 targetos = list[4].osnum); as$status();
   newme->end_prep = (short) expr.var.root_pm_st.value;
   status=om$send( msg = message  NDnode.NDgive_structure(&stat, &expr, md_env),
	   	 targetid = list[5].objid,
		 targetos = list[5].osnum); as$status();
   newme->pressure = expr.var.root_pm_st.value;
   status=om$send( msg = message  NDnode.NDgive_structure(&stat, &expr, md_env),
	   	 targetid = list[6].objid,
		 targetos = list[6].osnum); as$status();
   newme->cpt_off = expr.var.root_pm_st.value;
   status=om$send( msg = message  NDnode.NDgive_structure(&stat,&st_ref,md_env),
	   	 targetid = list[0].objid,
		 targetos = list[0].osnum); as$status();

   newme->z_vector[0] = st_ref.var.ref_st.t[2];
   newme->z_vector[1] = st_ref.var.ref_st.t[6];
   newme->z_vector[2] = st_ref.var.ref_st.t[10];
   newme->y_vector[0] = st_ref.var.ref_st.t[0];
   newme->y_vector[1] = st_ref.var.ref_st.t[4];
   newme->y_vector[2] = st_ref.var.ref_st.t[8];


   for(k=0; k<3; k=k+1)
   {
    tab[k]   = st_ref.var.ref_st.t[3+4*k];
    tab[k+3] = st_ref.var.ref_st.t[3+4*k];
   }

   kl_int_cnst(&dis,&cst);
   cst.msg		= msg;
   cst.env_info		= md_env;
   cst.geometry 	= (char *)&geom;
   dis.weight 		= 3;
   geom.num_points 	= 2;
   geom.points  	= tab;

   map_obj.osnum = OM_Gw_current_OS;

   status = om$construct
                   ( classname = "GR3dpoint",
                     p_objid   = &(map_obj.objid),
                     osnum     = OM_Gw_current_OS );

   as$status();
   status =om$send( msg       = message GRgraphics.GRaltconstruct(&cst),
           targetid  = map_obj.objid,
 	   targetos  = map_obj.osnum);
   as$status();

   }

  if( map_obj.objid == NULL_OBJID ) { status = 2; goto wrapup; }

  status = 
  om$send (msg  = message ci_macro.set_all_extern_feet
                        (&retmsg,1,&map_obj,md_env),
	 targetid =my_id);
  as$status( );

  /* successfull completion */
  status = 1;

wrapup :

  return(status);
}

/* ========================================================================= */

end implementation ov_ci_mac;

