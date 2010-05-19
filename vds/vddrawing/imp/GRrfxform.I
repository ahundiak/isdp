/* $Id: GRrfxform.I,v 1.1.1.1 2001/01/04 21:08:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/emsfixes/grnuc/GRrfxform.I
 *
 * Description:
 *      This file is a enhancement to GRrfxform.I for "move drawing view" 
 *	commands.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: GRrfxform.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/03/23  16:19:22  pinnacle
# Replaced: vddrawing/imp/GRrfxform.I for:  by impd for vds
#
# Revision 1.4  1998/03/19  20:23:28  pinnacle
# Replaced: vddrawing/imp/GRrfxform.I for:  by yzhu for vds
#
# Revision 1.2  1998/03/02  20:38:14  pinnacle
# Replaced: vddrawing/imp/GRrfxform.I for:  by yzhu for vds
#
# Revision 1.1  1997/12/10  16:53:56  pinnacle
# Created: vddrawing/imp/GRrfxform.I by impd for vds
#
# Revision 1.2  1997/12/10  15:08:08  pinnacle
# Replaced: emsfixes/grnuc/GRrfxform.I for:  by impd for vds
#
# Revision 1.1  1997/08/29  15:42:06  pinnacle
# Created: emsfixes/grnuc/GRrfxform.I by yzhu for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      08/28/97        yzh		add VDS_K_RecomputeDrawingM for 
 *					"move drawing view" commands.
 * -------------------------------------------------------------------*/

/*
Name
	GRreffile.GRxform

Synopsis
        GRxform(msg,md_env,matrix_type,matrix,newobjid)

Description

        This method transforms the geometry of a graphics object by a matrix.

	After calling GRgetlbsys to get the local bounded system definition of
	the reference file attachment, transform the local bounded system.
	Then post the modified geometry back into the object.

	The clip polygon is also transformed if the message is not originating
	from the clipping polygon.

        The transformation matrix is incorporated into the instance data view
        rotation matrix.

	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
	GRSNOINVTRAN  -  in env_info is not invertible
	GRSDGNEXCEED design space limits are exceeded

History
	MAS 	04/05/87	Design date.
        dhm     07/07/92        ANSI conversion.
        mrm     08/03/93        Grind the rotation part of the transformation
                                matrix into the view rotation matrix stored in
                                instance data.  This is neccessary to get the
                                boreline into the correct orientation in
                                GRpassrange for point & boreline locate.
                                TR11924936.
        yzhu    08/28/97        add VDS_K_RecomputeDrawingM for "move drawing
				view" commands.
*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "madef.h"
#include "OMmacros.h"
#include "godef.h"
#include "v_dbgmacros.h"
#include "VDmem.h"

extern IGRboolean  VDS_K_RecomputeDrawingM;

from NDnode  import ASreturn_go;
extern    IGRboolean    MAlbxform();
extern    OMuword    OPP_VDcontext_class_id;
extern    OMuword    OPP_GRcontext_class_id;
extern    OMuword    OPP_ACpretendin_class_id;
extern    OMuword    OPP_VDdrw2d_class_id;
extern    OMuword    OPP_VDdrawing_class_id;

/****************************************************************************/
/* add VD_drw2d_GRxform by yzhu */

static long  VD_drw2d_GRxform( msg, md_env,  matrix_type, matrix, objid)
  IGRlong	 	*msg; 
  struct GRmd_env	*md_env;
  IGRshort		 matrix_type; 
  IGRmatrix		 matrix; 
  OM_S_OBJID		 objid;
{
  OM_S_OBJECT_LINKAGE 	*refObj = NULL, *reflist = NULL; 
  OM_S_OBJECT_LINKAGE 	*miscObj = NULL, *misclist = NULL; 
  OM_S_OBJECT_LINKAGE 	*chilObj = NULL, *chillist = NULL; 
  OM_S_OBJECT_LINKAGE 	*nestedObj = NULL; 
  char        		classname[80]; /* classname  */
  long                  OMmsg;
  OM_S_CHANSELECT       reffile_to_context_chan, nested_files_chan, 
			misc_chan, children_chan;
  OMuint	        reffile_to_context_count,
             		context_to_misc_count,
			nested_files_count,
			children_count;
  int			size_int, ii, i, j;	
  OMuint		ref_count, misc_count, chil_count, nested_count;	
  int			context_num, children_num, vddrw2d_num, memory_size;	
  GRobjid               dummy;		
  struct GRid 		go,mod_grid;
  IGRshort 		mat_type;
  enum GRdpmode		mode;  
  IGRmatrix 	        matrix1; 


  SetProc( VD_drw2d_GRxform);  Begin	

  OMmsg = OM_S_SUCCESS;    /* initialize return values  */
  *msg  = MSSUCC;
  ii = 0;

  __DBGpr_int( "VDS_K_RecomputeDrawingM", VDS_K_RecomputeDrawingM); 	
  __DBGpr_int( "input matrix_type", matrix_type); 	
  __DBGpr_int( "input objid", objid); 	

  /* set up channel  */
  OMmsg = om$make_chanselect ( channame = "GRreffile.to_context",
                               p_chanselect = &reffile_to_context_chan );
  if (!(1 & OMmsg)) {
      *msg = MSFAIL;
      OMmsg = MSFAIL;
      goto wrapup; 
  }

  OMmsg = om$make_chanselect ( channame = "GRcontext.to_misc",
                               p_chanselect = &misc_chan );
  if (!(1 & OMmsg)) {
      *msg = MSFAIL;
      OMmsg = MSFAIL;
      goto wrapup; 
  }

  OMmsg = om$make_chanselect ( channame = "NDchildren.children",
                               p_chanselect = &children_chan );
  if (!(1 & OMmsg)) {
      *msg = MSFAIL;
      OMmsg = MSFAIL;
      goto wrapup; 
  }
 
  OMmsg = om$make_chanselect ( channame = "GRcontext.to_nested_files",
                               p_chanselect = &nested_files_chan );
  if (!(1 & OMmsg)) {
      *msg = MSFAIL;
      OMmsg = MSFAIL;
      goto wrapup; 
  }
 
  /* Input object should be GRreffile class*/
  /* find VDcontext object in channel GRreffile.to_context*/
  reffile_to_context_count = 0;
  OMmsg = om$get_channel_count( objid = objid,
                                p_chanselect = &reffile_to_context_chan,
                                count = &reffile_to_context_count);
  __DBGpr_int("reffile_to_context_count ", reffile_to_context_count);

  if( reffile_to_context_count ) { 

    /* get object from the reffile_to_context_chan */ 
    size_int = (int) reffile_to_context_count;
    refObj = _MALLOC( size_int, OM_S_OBJECT_LINKAGE ); 

    ref_count = 0;
    OMmsg = om$get_channel_objects( objid = objid,
                                    p_chanselect = &reffile_to_context_chan,
                                    list = refObj,
                                    size = size_int,
                                    count = &ref_count);
    __DBGpr_int( " ref_count", ref_count);

    ii = 0;
    for ( i = 0; i < ref_count; i++ ) {
      /* goto find the VDcontext objects first get classname from id */
      OMmsg = om$get_classname (objid = refObj[i].S_objid,
                                osnum = refObj[i].osnum,
                                classname = classname);

      /* now check whether it is a succesor of GRlinear */
      OMmsg = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_VDcontext_class_id );
      if (OMmsg != OM_S_SUCCESS) {
          OMmsg = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_GRcontext_class_id );

          if (OMmsg != OM_S_SUCCESS)  continue;

          /* find the VDcontext objects from GRcontext in the channel :
           * nested_files_chan
          */ 

          nested_files_count = 0;

          OMmsg = om$get_channel_count( objid = refObj[i].S_objid,
                                osnum = refObj[i].osnum,
                                p_chanselect = &nested_files_chan,
                                count = &nested_files_count);
          __DBGpr_int( " nested_files_count ", nested_files_count);

      
          if( !nested_files_count ) continue;
          
   	  nestedObj = 
	  _MALLOC( (int)nested_files_count, OM_S_OBJECT_LINKAGE);
         
          size_int = (int)  nested_files_count;
          nested_count = 0;
          OMmsg = om$get_channel_objects( objid = refObj[i].S_objid,
                                osnum = refObj[i].osnum,
                                    p_chanselect = &nested_files_chan,
                                    list = nestedObj,
                                    size = size_int,
                                    count = &nested_count);
          __DBGpr_int( " nested_count ", nested_count);

          if( !nested_count ) continue;

          for ( j = 0; j < nested_count ; j++ ) {
            /* goto find the VDcontext objects first get classname from id */
            OMmsg = om$get_classname (objid = nestedObj[j].S_objid,
                                osnum = nestedObj[j].osnum,
                                       classname = classname);

            /* now check whether it is a succesor of VDcontext */
            OMmsg = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_VDcontext_class_id );

            if (OMmsg != OM_S_SUCCESS)  continue;

            if ( !ii ) {
              ii = ii + 1;
              reflist = _MALLOC( ii,  OM_S_OBJECT_LINKAGE);
            }
            else {
              ii = ii + 1;
              reflist = _REALLOC(reflist, ii, OM_S_OBJECT_LINKAGE);
      	    }

            /* otherwise set a temp reflist */
            reflist [ii-1] = nestedObj[j];
          } /* for j */

          _FREE( nestedObj ); 

      } /* OPP_VDcontext_class_id */
      else {
        if ( !ii ) {
            ii = ii + 1;
            reflist = _MALLOC( ii,  OM_S_OBJECT_LINKAGE );
        }
        else {
            ii = ii + 1;
            reflist = _REALLOC(reflist, ii, OM_S_OBJECT_LINKAGE);
        }
 
        /* otherwise set a temp reflist */ 
        reflist [ii - 1] = refObj[i];
      } 
    } /* for i */
  }  /* if( reffile_to_context_count ) */

  context_num = ii;
  __DBGpr_int( " VDcontext objects found", context_num);

  /* find channel GRcontext.to_misc */
  ii = 0;
  memory_size = 0;
  for ( j = 0; j < context_num; j++) { 
    context_to_misc_count = 0;
    OMmsg = om$get_channel_count( objid = reflist[j].S_objid,
                                osnum = reflist[j].osnum,
                                p_chanselect = &misc_chan,
                                count = &context_to_misc_count);

    if( context_to_misc_count ) {
      miscObj = _MALLOC( (int)context_to_misc_count, OM_S_OBJECT_LINKAGE );
      if ( !memory_size ) {
        memory_size = (int) context_to_misc_count;
        misclist = _MALLOC( memory_size, OM_S_OBJECT_LINKAGE);
      } 
      else {
        memory_size = memory_size + (int) context_to_misc_count;
        misclist = _REALLOC(misclist, memory_size, OM_S_OBJECT_LINKAGE);
      } 

      size_int = (int) context_to_misc_count;
      misc_count = 0;
      OMmsg = om$get_channel_objects( objid = reflist[j].S_objid,
                                    osnum = reflist[j].osnum,
                                    p_chanselect = &misc_chan,
                                    list = miscObj,
                                    size = size_int,
                                    count = &misc_count);

      for ( i = 0; i < misc_count ; i++ ) {
        /* goto find the VDcontext objects first get classname from id */
        OMmsg = om$get_classname (objid = miscObj[i].S_objid,
                                    osnum = miscObj[i].osnum,
                                classname = classname);

        /* now check whether it is a succesor of ACpretendin */
        OMmsg = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_ACpretendin_class_id );
        if (OMmsg != OM_S_SUCCESS)  continue;

        /* otherwise set a temp reflist */
        misclist [ii] = miscObj[i];
        ii = ii + 1;
      } /* for i */
    } /* if(context_to_misc_count ) */
  } /* for j */

  children_num = ii;
  __DBGpr_int( " ACpretendin object in the misc channel", children_num);

  /* find channel NDchildren.children */
  ii = 0;
  memory_size = 0;
  for ( j = 0; j < children_num; j++) {
    children_count = 0;
    OMmsg = om$get_channel_count( objid = misclist[j].S_objid,
                                    osnum = misclist[j].osnum,
                                p_chanselect = &children_chan,
                                count = &children_count);

    if( children_count ) {
      chilObj = _MALLOC((int)children_count, OM_S_OBJECT_LINKAGE);
      if ( !memory_size ) {
        memory_size = (int) children_count;
        chillist = _MALLOC( (int)memory_size, OM_S_OBJECT_LINKAGE);
      }
      else {
        memory_size = memory_size + (int) children_count;
        chillist = _REALLOC(chillist, memory_size, OM_S_OBJECT_LINKAGE);
      }

      size_int = (int) children_count;
      chil_count = 0;
      OMmsg = om$get_channel_objects( objid = misclist[j].S_objid,
                                    osnum = misclist[j].osnum,
                                    p_chanselect = &children_chan,
                                    list = chilObj,
                                    size = size_int,
                                    count = &chil_count);

      for ( i = 0; i < chil_count ; i++ ) {
        /* goto find the VDcontext objects first get classname from id */
        OMmsg = om$get_classname (objid = chilObj[i].S_objid,
                                    osnum = chilObj[i].osnum,
                                classname = classname);

        /* now check whether it is a succesor of ACpretendin */
        OMmsg = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_VDdrw2d_class_id );
        if (OMmsg != OM_S_SUCCESS)  {
 		/* 179800220 */
                OMmsg = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_VDdrawing_class_id );
                if (OMmsg != OM_S_SUCCESS)  continue; 
        }
        /* otherwise set a temp reflist */
        chillist [ii] = chilObj[i];
        ii = ii + 1;
      } /* for i */
    } /* ifchildren_count ) */
  } /* for j */

  vddrw2d_num = ii;
  __DBGpr_int( " vddrw2d/vddrawing objects", vddrw2d_num);

  __DBGpr_mat(" matrix", matrix);
  /* using GRxform to VDdrw2d objects */
 
  GRfindmod(&mod_grid);
  for( j = 0 ; j < vddrw2d_num ; j++ ){

    __DBGpr_int("chillist", chillist[j].S_objid);

    mode = GRbe ;
    OMmsg = om$send(msg = message NDnode.ASreturn_go(&go,&mat_type,matrix1),
                       senderid = chillist[j].S_objid,
                       targetid = chillist[j].S_objid,
                       targetos = chillist[j].osnum );
    __DBGpr_obj("go", go);

    /* 179800220 */
    OMmsg = om$get_classname (objid = chillist[j].S_objid,
                              osnum = chillist[j].osnum,
                              classname = classname);

    /* now check whether it is a succesor of ACpretendin */
    OMmsg = om$is_ancestry_valid (  subclassname = classname,
                                superclassid = OPP_VDdrawing_class_id );
    if (OMmsg == OM_S_SUCCESS)  {
       om$send(msg = message GRgraphics.GRdisplay(msg,
                                  &mat_type, matrix1, &mode,&mod_grid),
                       senderid = chillist[j].S_objid,
                       targetid = chillist[j].S_objid,
                       targetos = chillist[j].osnum );
    }
    else { 
      om$send(msg = message GRgraphics.GRdisplay(msg,
                                  &mat_type, matrix1, &mode,&mod_grid),
                       senderid = go.objid,
                       targetid = go.objid,
                       targetos = go.osnum );
    }

    om$send(msg = message GRgraphics.GRxform ( msg, md_env,
                                    &matrix_type, matrix, &dummy ),
                       senderid = chillist[j].S_objid,
                       targetid = chillist[j].S_objid,
                       targetos = chillist[j].osnum );

    mode = GRbd ;
    om$send(msg = message GRgraphics.GRdisplay(msg,
                                  &mat_type, matrix1, &mode,&mod_grid),
                       senderid = chillist[j].S_objid,
                       targetid = chillist[j].S_objid,
                       targetos = chillist[j].osnum );
  }

wrapup:
  _FREE( refObj);
  _FREE( reflist);
  _FREE( nestedObj);
  _FREE( miscObj);
  _FREE( chilObj);
  _FREE( misclist);
  _FREE( chillist);

  End 	
  return( OMmsg);
}

method GRxform(IGRlong *msg; struct GRmd_env *md_env; 
	       IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
    IGRshort	xtype;
    IGRshort    mxsize = 4;
    IGRlong     OMmsg,			/* OM return status		*/
		msg1;
    IGRdouble   xmatrix_rot[16], tmx[16];
    IGRmatrix 	xmatrix;
    struct GRmd_env local_env;		/* environment for clip polygon	*/
    OM_S_CHANSELECT poly_chan;		/* channel to clip polygon	*/
    struct IGRlbsys lbsys,		/* local bounded system		*/
		new_lbsys;

    IGRshort  i, rank;
    IGRdouble vectors[9], o_vectors[9];
    IGRmatrix omx;
    short     id_type;
   
     
    SetProc( GRrfxform.I --- GRxform); Begin 

    *msg = MSSUCC;			/* initialize objects		*/
    OMmsg = OM_S_SUCCESS;
    *newobjid = my_id;

    local_env = *md_env;
    local_env.md_id.objid = NULL_OBJID;

    if (!IF_NULL_OBJID(md_env->md_id.objid))
    {					/* remove object from R-tree	*/
        OMmsg = om$send(
	    msg = message GRgraphics.GRremwrng
		(msg,md_env),
	    targetid = my_id);
    }

    if ( 1 & OMmsg & *msg)
    {	
					/* get channel to clip polygon	*/
	poly_chan.type = OM_e_addr;
	poly_chan.u_sel.addr = &me->to_clip;		    

	OMmsg = om$send(
		msg = message GRreffile.GRgetlbsys
		    (msg,&md_env->md_env.matrix_type,
		     md_env->md_env.matrix,&lbsys),
		targetid = my_id);

    if ( 1 & OMmsg & *msg)
    {
      GRfixmatrix(msg,matrix_type,matrix,xmatrix,&xtype);

      if ( 1 & *msg ) 
      {
        if (MAlbxform(msg,&lbsys,xmatrix,&new_lbsys))
        {
            struct GRpost_info	post_info;
            
            post_info.construct_flag = FALSE;
          
            OMmsg = om$send(msg = message GRreffile.GRpostlbsys
                            (msg,&local_env,&post_info,&new_lbsys),
                            targetid = my_id);
     
            if ( VDS_K_RecomputeDrawingM ) {
              /* move vddrw2d object with out recompute add by zhu */
              id_type = 1; 
              OMmsg =  VD_drw2d_GRxform(msg, md_env, id_type, matrix, my_id);
            }


            /* Grind the rotation part of the transformation matrix into
               the view rotation matrix stored in instance data.  This is
               neccessary to get the boreline into the correct orientation
               in GRpassrange for point & boreline locate.  TR11924936 */
            memcpy((char *)xmatrix_rot, (char *)xmatrix,
                   sizeof(double) * 12);
            xmatrix_rot[3]  = xmatrix_rot[7]  = xmatrix_rot[11] = 0.0;
            xmatrix_rot[12] = xmatrix_rot[13] = xmatrix_rot[14] = 0.0;
            xmatrix_rot[15] = 1.0;
            MAmulmx(msg, &mxsize, &mxsize, &mxsize, 
                    me->vw_rotation, xmatrix_rot, tmx);
            memcpy((char *)me->vw_rotation, (char *)tmx,
                   sizeof(double) * 16);

            /* Remove the scale from the rotation matrix. */
            vectors[0] = me->vw_rotation[0]; 
            vectors[1] = me->vw_rotation[1]; 
            vectors[2] = me->vw_rotation[2];
            vectors[3] = me->vw_rotation[4]; 
            vectors[4] = me->vw_rotation[5]; 
            vectors[5] = me->vw_rotation[6];
            vectors[6] = me->vw_rotation[8]; 
            vectors[7] = me->vw_rotation[9]; 
            vectors[8] = me->vw_rotation[10];
            
            i = 3;
            
            if (!MAgrmscht (msg, &i, &i, vectors, o_vectors, &rank))
            {
#ifdef DEBUG
                printf ("GRgencs.GRxform: MAgrmscht failed\n");
#endif
                goto finish;
            }
                
            omx[0] = o_vectors[0];
            omx[1] = o_vectors[1];
            omx[2] = o_vectors[2];
            omx[3] = me->vw_rotation[3];
            omx[4] = o_vectors[3];
            omx[5] = o_vectors[4];
            omx[6] = o_vectors[5];
            omx[7] = me->vw_rotation[7];
            omx[8] = o_vectors[6];
            omx[9] = o_vectors[7];
            omx[10] = o_vectors[8];
            omx[11] = me->vw_rotation[11];
            omx[12] = me->vw_rotation[12];
            omx[13] = me->vw_rotation[13];
            omx[14] = me->vw_rotation[14];
            omx[15] = me->vw_rotation[15];
                
            for (i=0; i<16; ++i) 
            {
                me->vw_rotation[i] = omx[i];
            }
        }
        else
        {
            OMmsg = OM_E_ABORT;
        }

      } else 
          OMmsg = OM_E_ABORT;
    }

    if ( 1 & OMmsg )
	{
	    IGRchar *ptr;
	    struct IGRcv_prism *prism;

	    GRgetabsg(msg,&md_env->md_env.matrix_type, 
		md_env->md_env.matrix, &ptr, i );

	    if ( 1 & *msg)
	    {
		prism = (struct IGRcv_prism *) ptr;

		GRxformprism (msg, &local_env , prism , xmatrix, &xtype, 
			NULL, &my_id, &poly_chan);

		GRabsg_del_all();

	    }
	}
    }

    if (!(IF_NULL_OBJID( md_env->md_id.objid)))
    {
	om$send(
	     msg = message GRgraphics.GRaddwrng
	    	(&msg1,md_env),
	     targetid = my_id);

	if ( ! (1 & msg1))
	{
	    OMmsg =  OM_E_ABORT;
	    *msg =  MSFAIL;
	}
    }



    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_XFORMED);

 finish:
    
    End 
    return (OMmsg);

}

/*\
Name
	GRaltscale - this method transforms the geometry of a 
		     graphics object by a matrix and alters the
		     scale string of reffile object.  

Synopsis
     GRaltscale(msg,md_env,matrix_type,matrix,newobjid, scale)

Description

	After calling GRxform, the scale string of the reffile attachment
	is modified.

	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
	GRSNOINVTRAN  -  in env_info is not invertible
	GRSDGNEXCEED design space limits are exceeded

Notes
	None.
History
	BJ 	06/21/90	Design date.

\*/

method GRaltscale(IGRlong *msg; struct GRmd_env *md_env; 
	       IGRshort *mx_type; IGRmatrix matrix; GRobjid *newobjid;
		IGRchar *scale)
{

    IGRlong     OMmsg;			/* OM return status		*/

     
    *msg = MSSUCC;			/* initialize objects		*/
    OMmsg = OM_S_SUCCESS;
 
    OMmsg = om$send(
	    	msg = message GRgraphics.GRxform
			(msg, md_env, mx_type, matrix, newobjid),
	    targetid = my_id);

    if ( 1 & OMmsg & *msg)
    {	
	OMmsg = om$vla_set_dimension(
		varray = me->scale_factor,
		size = (strlen(scale)+1));

	if ( 1 & OMmsg)
	{				/* copy in new scale		*/
	    strcpy(me->scale_factor,scale);
   	}
	else
	{
	    *msg = MSFAIL;
	}
    }

    return (OMmsg);

}
end implementation GRreffile;

