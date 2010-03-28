#ifndef sym_ppl_include
#define sym_ppl_include

#include "OMminimum.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "DIdef.h"
#include "cimacros.h"
#include "cisend.h"
#include "grerr.h"
#include "msdef.h"
#include "grsymmacros.h"
#include "var.h"
#include "vardef.h"
#include "OMindex.h"
#include <stdio.h>



extern int GRdpb_get();
extern int GRsmplace();
extern int GRclplace();
extern int GRggplace();
extern int GRlslmgr_fun();
extern char *malloc();
extern int free();
#ifndef PPL
extern int (*OM_GA_primitives[])();
#endif
extern IGRboolean MAidmx();

extern char *ctime(), *malloc();
extern int GRlslmgr_fun();
extern int GRbtreecount(), GRbtreelocate_all();

int size,ret_size,loop_i,ret;
long time_stamp;
char name[MAX_SYMBOL_DEF_NAME + 1], desc[128];
char *datestring;
FILE *fp;
OM_S_BTREE_CONTENTS *symlibobjs;
struct GRvar_list list[4];
struct GRsymbol_lib_file file;
double rot_angle;
double scale_factors[3];
struct GRactive_symbol_def active_sym;
struct GRid active_sym_id,*ids;
struct GRmd_env md_env,*env;
short  *ly;
struct IGRlbsys lbsys;
struct GRsymbology symbology;
char   classname[50];

/*
Abstract
   This macro retrieves the names and/or the object ids of the 
members of a graphic group

Arguments

IGRlong *ret_msg           O     return code 
					MSSUCC - successful completion
					MSFAIL - error occurred
struct GRid *gg_id	   I     the graphic group id
IGRint *count		   O     count of the number of names and/or
				    object ids returned
IGRchar ***names 	   O     the names of the objects
				    objects in the group without
				    names will return "NO_NAME" as 
				    their name.  Caller must free 
				    memory after the call if names are
				    requested. (i.e., free(*names))
struct GRid  **comp_ids	   O     the object ids of the members of
				    the group. Caller must free memory
				    after the call if comp_ids are
				    requested. (i.e.,free(*comp_ids))
*/  

#omdef gr$get_gg_names(ret_msg,
		gg_id,
		count,
		names=NULL,
		comp_ids=NULL)
{
#   if (! ( om$specified(names) || om$specified(comp_ids)))
    {
     	omerror "Must specify either names or ids"
    }
#   else
    {
	ids = 0;
	*(count)=0;

        ci$send(msg=message GRowner.GRget_number_components
			(ret_msg,count),
	    targetid = (gg_id)->objid,
	    targetos = (gg_id)->osnum);

        if ( 1 & *(ret_msg))
	{
     	    size=sizeof(md_env);
   	    gr$get_module_env(msg=(ret_msg),
  		sizbuf=&size,
		buffer=&md_env,
		nret=&ret_size);

	    size = *(count) * sizeof(struct GRid);

            ids = (struct GRid *) malloc(size);
  	    	    
            ci$send(msg=message GRowner.GRget_components
		(ret_msg,&md_env,ids,*(count),&ret_size,0,OM_K_MAXINT),
   	        targetid = (gg_id)->objid,
	        targetos = (gg_id)->osnum);

	    if ( 1 & *(ret_msg))
	    {
# 	 	if (om$specified(names))
		{
		    size = *(count) * PATH_MAX + *(count)* sizeof(char *);

	    	    (*(names)) = (char **)malloc(size);

		    (*(names))[0] =(char *) ((*(names))+ (*(count) * sizeof(char *)));

	      	    for (loop_i=0; loop_i<ret_size; loop_i=loop_i+1)
	    	    {
	        	ret = ci$send(
			    msg=message GRvg.GRgetname
				(ret_msg,(char *)(*(names))[loop_i]),
			    targetid=ids[loop_i].objid,
			    targetos=ids[loop_i].osnum);

			if (! (1 & ret & *ret_msg))
			{
		   	    strcpy((char *)(*(names))[loop_i],"NO_NAME");
			    *(ret_msg)=MSSUCC;
			}
			if (loop_i< ret_size-1)
			{
		    	    (*(names))[loop_i+1]= (*(names))[loop_i] + PATH_MAX;
			}
		    }
		}
#		endif
	    }
	}
#	if (om$specified(comp_ids))
	{
	    *(comp_ids) = ids;
	}
#	else
	{
	    if (ids)
	        free(ids);
	}
#	endif
    }	
#   endif
}
#endomdef

/*
Abstract
        This macro is used to place the active cell as a cell,
symbol or graphic group.

Synopsis
IGRlong *ret_msg           O     return code 
				        MSSUCC  - successful completion
					MSINARG - invalid place flag
    				        MSFAIL  - failure
IGRpoint origin            I     the origin for placement
IGRdouble *angle           I     the angle (in radians)
				 default of NULL pointer means
				 use active angle
IGRdouble *scale           I     an array of x,y,z scales
				 default of NULL pointer means use
				 active scale
IGRmatrix rot_matrix       I     view rotation matrix 
IGRint	  place_flag	   I     indicator of what to place
					symbol - 0 (default)
					cell -  1
					graphic group - 2
struct GRid *sm_id         O     the new id

*/


#omdef gr$place_cell_or_symbol
			(ret_msg, 
                        origin,
                        angle = NULL,
                        scale = NULL,
                        rot_matrix,
			place_flag = 0,
                        sm_id)         
    {
#	if (! om$specified(angle)) 
	{
		size=sizeof(int);

		gr$get_active_angle
		(msg=(ret_msg),
		 sizbuf=&size,
		 buffer=&rot_angle,
		 nret=&ret_size);
	}
#	else 
	{
	    rot_angle=*(angle);
 	}
#       endif

#	if (! om$specified(scale)) 
	{
		size=sizeof(struct GRdpb_scale);
		gr$get_active_scale
		(msg=(ret_msg),
		 sizbuf=&size,
		 buffer=(struct GRdpb_scale *)scale_factors,
		 nret=&ret_size);
	}
#	else 
	{
	    scale_factors[0]=(scale)[0];
	    scale_factors[1]=(scale)[1];
	    scale_factors[2]=(scale)[2];
 	}
#       endif

   	size=sizeof(md_env);
   	gr$get_module_env(msg=(ret_msg),
  		sizbuf=&size,
		buffer=&md_env,
		nret=&ret_size);

	if (1 & *(ret_msg))
	{
    
   	    gr$symget_active_symbol(msg=ret_msg,
		act_symbol_def=&active_sym);

	    if (1 & *(ret_msg))
	    {
#   		if  ((! om$specified(place_flag)) || (om$equal(place_flag,0)))
   		{
	   	    active_sym_id.objid=active_sym.objid;
	    	    active_sym_id.osnum=active_sym.symbol_env.md_id.osnum;

	    	    gr$sym_sm_place(msg=ret_msg,
			origin=(origin),
			angle=&rot_angle,
			scale=scale_factors,
			rot_matrix=(rot_matrix),
			symbol_env=&active_sym.symbol_env,
			target_env=&md_env,
			sdh_id=&active_sym_id,
			sm_id=(sm_id));
   		}
#   		elif (om$equal(place_flag,1))
   		{
		    active_sym_id.objid= active_sym.objid;
		    active_sym_id.osnum=
			active_sym.symbol_env.md_id.osnum;

	    	    gr$sym_cl_place(msg=ret_msg,
			origin=(origin),
			angle=&rot_angle,
			scale=scale_factors,
			rot_matrix=(rot_matrix),
			symbol_env=&active_sym.symbol_env,
			target_env=&md_env,
			sdh_id=&active_sym_id,
			cl_id=(sm_id));
   		}
#   		elif (om$equal(place_flag,2))
   		{
		    active_sym_id.objid= active_sym.objid;
		    active_sym_id.osnum=
			active_sym.symbol_env.md_id.osnum;

	    	    gr$sym_gg_place(msg=ret_msg,
			origin=(origin),
			angle=&rot_angle,
			scale=scale_factors,
			rot_matrix=(rot_matrix),
			symbol_env=&active_sym.symbol_env,
			target_env=&md_env,
			sdh_id=&active_sym_id,
			gg_id=(sm_id));
		}
#		else
		{		
	    	    *(ret_msg) = MSINARG;
		}
#	        endif
	    }
   	}
    }	
#endomdef


/*
Abstract
    Retrieves information about a cell or symbol.  The information
retrieve is the origin , type (cell or symbol), layer the cell is
placed on, number of components, and if requested the layer of each
component.

Arguments

IGRlong *ret_msg           O     return code 
				    MSSUCC - successful completion
				    GRINVOBJECT - invalid object id,
					object is not a cell or symbol
				    MSFAIL - error
struct GRmd_env *env_info  I	 the cell environment information, if
				 default is used, active environment
				 will be used
struct GRid *cell_id	   I	 the id of the cell or symbol
IGRlong	*type		   O	 indicates if object is placed as cell or
				 a symbol
					0 - object is a symbol
					1 - object is a cell
IGRlong *num_layers	   O	 the number of layer entries in
				     layers array
IGRshort **layers	   O     array of layers 
				 for a cell -
				     array of layers of the components
				 for a symbol
				     array has one entry and it is
				     the layer the symbol was placed on
				  For both cases, memory is allocated 
				   by the macro and caller is responsible 
				   for freeing the memory 
					(i.e.,free(*layers))
IGRdouble *origin	   O     the origin of the cell
IGRlong *num_components	   O	 the number of components
*/

#omdef gr$inq_cell(ret_msg,
	env_info=NULL,
	type,
	num_layers=NULL,	
	layers=NULL,
	origin=NULL,
	num_components=NULL,
	cell_id)
{
    om$get_classname(objid=(cell_id)->objid,
	osnum=(cell_id)->osnum,
	classname= classname);

    ret=om$is_ancestry_valid(subclassname = classname,
	superclassname="GRsmhdr");

    if (ret == OM_S_SUCCESS)
    {
	*(type)=0;
    }
    else
    {
        ret=om$is_ancestry_valid(subclassname = classname,
	    superclassname="GRclhdr");

	if (ret == OM_S_SUCCESS)
	{
	    *(type)=1;
	}
        else
	{
	    *(ret_msg)=GRINVOBJECT;
	}
    }

#   if (! om$specified(env_info))
    {
   	size=sizeof(md_env);
   	gr$get_module_env(msg=(ret_msg),
  		sizbuf=&size,
		buffer=&md_env,
		nret=&ret_size);
	env=&md_env;
    }
#   else
    {
	env=(env_info);
    }
#   endif

#   if (om$specified(origin))
    {
	ci$send(msg=message
		GRvg.GRgetgeom(ret_msg,&env->md_env.matrix_type,
	  	              env->md_env.matrix,(char *)&lbsys),
	    targetid=(cell_id)->objid,
	    targetos=(cell_id)->osnum);

        origin[0]=lbsys.matrix[3];
        origin[1]=lbsys.matrix[7];
        origin[2]=lbsys.matrix[11];
    }
#   endif

#   if (om$specified(layers) && (! om$specified(num_layers)) )
    {
	omerror "If layers are specified must specify num_layers"
    }    
#   elif (om$specified(num_layers) && (! om$specified(layers)))
    {
	omerror "If num_layers are specified must specify layers"
    }
#   elif (om$specified(layers))
    {
	*(num_layers)=0;

	if (*(type) == 0)
	{
	    ci$send(msg=message GRvg.GRgetsymb(ret_msg,&symbology),
		targetid=(cell_id)->objid,
		targetos=(cell_id)->osnum);

	    *(layers) = (short *)malloc(sizeof(short));
	    *(num_layers)=1;
	    *(layers)[0] = symbology.level;
	}
	else
	{
	    ci$send(msg=message GRowner.GRget_number_components
			(ret_msg,(num_layers)),
		    targetid = (cell_id)->objid,
		    targetos = (cell_id)->osnum);


	    *(layers)= (short *)malloc(*(num_layers) * sizeof(short));
	    ly= (short *) *(layers);

	    size=*(num_layers) * sizeof (struct GRid);
	    ids=(struct GRid *)malloc(size);

	    ci$send(msg=message GRowner.GRget_components
			(ret_msg,env,ids,*(num_layers),&ret_size,0,
			 OM_K_MAXINT),
		    targetid = (cell_id)->objid,
		    targetos = (cell_id)->osnum);

	    *(num_layers)=0;
	    for (loop_i=0; loop_i<ret_size; loop_i=loop_i+1)
	    {
	        ret = ci$send(msg=message GRvg.GRgetsymb(ret_msg,&symbology),
		    targetid=ids[loop_i].objid,
		    targetos=ids[loop_i].osnum);

		if ( 1 & ret)
		{
		   ly[*(num_layers)]=symbology.level;
		   *(num_layers)= *(num_layers) + 1;
		}
	    }
	    free(ids);
	}
    }
#   endif

    if(num_components)
    {
       ci$send(msg=message GRowner.GRget_number_components
		(ret_msg,(num_components)),
	    targetid = (cell_id)->objid,
	    targetos = (cell_id)->osnum);
    }

}
#endomdef

/*
Abstract
   This macro returns the number of cells and symbols placed in a file

Arguments

IGRlong *ret_msg           O     return code 
					MSSUCC - successful completion
					MSFAIL - error occurred
IGRlong	*num_cells	   O	 the number of cells
IGRlong *num_symbols	   O     the number of symbols

*/  

uword		  cell_classid,sym_classid;
int		  max_entry;	 
struct OM_sd_OSD  *p_OSD;
OM_p_SPAMAPENT  spamapent_p;
OM_S_OBJID	  oid;		     

#omdef gr$get_count(ret_msg,
		num_cells,
		num_symbols)
{
	*(ret_msg)=MSSUCC;

        om$get_classid(classname = "GRclhdr",
		p_classid = &cell_classid);
        om$get_classid(classname = "GRsmhdr",
		p_classid = &sym_classid);

	*(num_cells) = 0;
	*(num_symbols) = 0;

    	p_OSD = OM_GA_OSDs[2];

    	if (p_OSD->CurSpaceMapSize) 
    	{ 
	    max_entry = p_OSD->CurSpaceMapSize-1;
       	    spamapent_p = &p_OSD->Spacemap[max_entry];

	    for ( ; max_entry >= 0; max_entry=max_entry-1 ) 
	    {
  		if (! ( !(spamapent_p->flags & OM_SM_in_use)
		 	&&  !(spamapent_p->flags & OM_SM_in_mem)))
			break;
		spamapent_p=spamapent_p-1;
	    }
	    spamapent_p = p_OSD->Spacemap;

      	    for (oid=0; oid <= max_entry;  oid=oid+1)
      	    {	
          	if (  (spamapent_p->flags != NULL) ||	
           	      (spamapent_p->p_acld != NULL) ) 
            	{
         	    if ((!(spamapent_p->flags & OM_SM_unknown_obj)) &&
                        ((cell_classid == spamapent_p->p_acld->w_classid) ||
               	         (sym_classid == spamapent_p->p_acld->w_classid)))
         	     {
 			if (cell_classid == spamapent_p->p_acld->w_classid) 
			{
			    *(num_cells)= *(num_cells)+ 1;
			}
			else
			{
			    *(num_symbols) = *(num_symbols)+1;
			}
          	     }
            	}
		spamapent_p=spamapent_p+1;
	    }	
    	} 
    	else 
    	{
    	    *(ret_msg)=MSFAIL;
    	}
}
#endomdef

/*
Abstract
        This command places cell names, descriptions, and creation dates
        in an ASCII file.

Arguments

IGRlong *ret_msg           O     return code 
					MSSUCC - successful completion
					MSINARG - no active cell library
					MSFAIL - error occurred
IGRchar	*filename	   I 	 the output filename

*/  

#omdef gr$print_cellib_info(ret_msg,
	filename)
{
    if ((fp = fopen (filename, "w")) == 0)
    {
	*(ret_msg)=MSFAIL;
    }
    else
    {    
        ret = gr$symget_asl_env (msg = ret_msg, asl_env = &md_env);
    	if (!(ret & *(ret_msg) & 1))
    	{
	    fclose(fp);
	    *(ret_msg)=MSINARG;
    	}
    }    
    if ( 1 & *(ret_msg))
    {
        ret = GRbtreecount (ret_msg, md_env.md_id.osnum, 
                            GR_SD_BTREE_NAME, &size);
        if (ret & *(ret_msg) & 1)
        {
            size = size * (sizeof (OM_S_BTREE_CONTENTS));

            symlibobjs = (OM_S_BTREE_CONTENTS *) malloc (size);

            if (symlibobjs)
            {
                ret = GRbtreelocate_all (ret_msg, md_env.md_id.osnum,
                                         GR_SD_BTREE_NAME, symlibobjs,
                                         0, size, &size);
                if (ret & 1)
                {
                    list[0].var = GR_SYMBOL_NAME;
                    list[0].var_ptr = name;
                    list[0].num_bytes = MAX_SYMBOL_DEF_NAME;
                    list[0].bytes_returned = &ret_size;

                    list[1].var = GR_SYMBOL_DESC;
                    list[1].var_ptr = desc;
                    list[1].num_bytes = 128;
                    list[1].bytes_returned = &ret_size;

                    list[2].var = GR_TIME_STAMP;
                    list[2].var_ptr = (char *) &time_stamp;
                    list[2].num_bytes = sizeof (long);
                    list[2].bytes_returned = &ret_size;

                    list[3].var = END_PARAM;
 
                    for (loop_i = 0; loop_i < size; loop_i = loop_i + 1)
                    {
                        name[0] = NULL;
                        desc[0] = NULL;
                        ret = ci$send (
			    msg = message GRsymbol.GRset_inq_symbol
                                            (ret_msg, 0, list),
                            targetos = md_env.md_id.osnum,
                            targetid = symlibobjs[loop_i].objid);

                        if (ret & *(ret_msg) & 1)
                        {
                            datestring = ctime (&time_stamp);
                            fprintf (fp, "%d\n%s\n%s\n%s\n",
                                     loop_i+1, name, desc, datestring);
                        }
                    }
                    fclose (fp);
                }

                free (symlibobjs);
            }
        }
    }
}
#endomdef

#endif
