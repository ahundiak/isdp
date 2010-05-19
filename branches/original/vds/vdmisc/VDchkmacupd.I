/* $Id: VDchkmacupd.I,v 1.2 2002/02/01 16:27:42 ramarao Exp $  */
/*************************************************************************
 * I/VDS
 *
 * File:        vds/vdmisc/VDchkmacupd.I
 *
 * Description: Function to check if symbol macros are outdated.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDchkmacupd.I,v $
 *      Revision 1.2  2002/02/01 16:27:42  ramarao
 *      Fixed TR# 5883.
 *
 *      Revision 1.1  2001/03/07 00:47:44  ramarao
 *      New PPL functionality.
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR               DESCRIPTION
 *      03/06/01   Rama Rao             File Creation
 *************************************************************************/

class implementation VDSroot;

#include "nddef.h"
#include "ndmacros.h"
#include "acmacros.h"
#include "VDobj.h"
#include "DIprims.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

from ACcpx_defn 	import	ACgive_temp_desc;

extern OM_S_CHANSELECT  AS_to_comp, AS_to_owner;
extern IGRboolean     	ASbroadcast_in_progress ;
extern GRclassid	OPP_ACheader_class_id, OPP_LCcmd_iso_class_id;

IGRlong	VDchkIfMacsUptoDate( IGRint	option )
{
IGRlong			sts,msg;
IGRint			i, j, k, l, m, macCnt=0, libCnt=0, tot_temp, nb_model, 
			nb_header, mode, root_type, int_msg, cn_type=ND_COMP;
IGRchar			lib[DI_PATH_MAX], pwd_name[DI_PATH_MAX], *p,
			cur_path[DI_PATH_MAX],
			**libNames=NULL, **macNames=NULL;
IGRboolean		is_same, saveBroad;
struct stemp            *dtemp;
struct GRid		mgrID, mac_def, model_obj, header, owner;
struct GRmd_env		loc_env;
struct ret_struct	rs;

   gr$get_module_env( buffer = &loc_env );

   di$pwd( dirname = pwd_name );

   di$give_pathname( osnum    = loc_env.md_id.osnum,
                     pathname = cur_path );

   strcat( cur_path, ":models_lib" );

   di$cd ( dirname = cur_path );

   di$ls( lines = &libNames,  ptr = &libCnt );
 
   for( i=0; i<libCnt; ++i )
   {
      sprintf( lib, "%s%s", libNames[i], "constructs:" );
      di$cd( dirname = lib );
      di$free( lines = macNames, count = macCnt );
      macCnt = 0;
      di$ls( lines = &macNames, ptr = &macCnt );
      for( j=0; j<macCnt; ++j )
      {
	 di$translate(  objname = macNames[j], 
			p_objid = &mgrID.objid,
			p_osnum = &mgrID.osnum  );
	 __DBGpr_str( "Macro Name", macNames[j] );

	 p = strrchr( macNames[j],':' );
  	 if (p) p++;
  	 else   p = macNames[j];

	 __DBGpr_str( "Truncated Macro Name", p );

	 ac$find_macro_defn( macro_name = p,
			     action     = ACfind_load,
			     p_macro_defn_id = &mac_def );
	 __DBGpr_obj( "Macro Definition", mac_def );

         om$send(  msg      = message ACcpx_defn.ACgive_temp_desc
                                        ( &tot_temp, &dtemp ),
			 senderid = NULL_OBJID,
                         targetid = mac_def.objid,
                         targetos = mac_def.osnum );

	 om$get_channel_count(  objid   = mgrID.objid,
				osnum   = mgrID.osnum,
				p_chanselect = &AS_to_comp,
				count   = (OMuint *) &nb_model );
	 __DBGpr_int( "Number of Model Macros", nb_model );
	 is_same = TRUE;
	 for( k=0; k<nb_model; ++k )
	 {
             om$get_objid_at_index( 
				  objid         = mgrID.objid,
				  osnum         = mgrID.osnum,
                                  p_chanselect  = &AS_to_comp,
                                  index         = k,
                                  objidaddr     = &model_obj.objid,
                                  osnumaddr     = &model_obj.osnum );
	     __DBGpr_obj( "Model Object", model_obj );

	     for( l=0; l<tot_temp; ++l )
	     {
	         sts = om$send(	msg =  message ACcpx.ACfind_exp_temp_struct(
					 &int_msg, l, &rs, &loc_env ),
				senderid = model_obj.objid,
				targetid = model_obj.objid,
				targetos = model_obj.osnum );
	         if( !(sts&1&int_msg) )  break;
        	 root_type = dtemp[l].type;
        	 if(root_type&other_generic) root_type |= debug_type;
        	 if(root_type&curve_generic) 
			root_type |= line_generic|conic_generic;
		 if( !IS_SAME_GEOM( rs.type, root_type) ) break;
	     }
	     if( l != tot_temp ) is_same = FALSE;

             sts = om$send( msg =  message ACcpx.ACfind_exp_temp_struct(
                                         &int_msg, l, &rs, &loc_env ),
                                senderid = model_obj.objid,
                                targetid = model_obj.objid,
                                targetos = model_obj.osnum );
	     if( sts&1&int_msg ) is_same = FALSE;
	     __DBGpr_int( "Is Same", is_same );
	
	     if( is_same ) 
	     {
		IGRint	cmp_count=0;
		om$get_channel_count( 	objid	= model_obj.objid,
					osnum	= model_obj.osnum,
					p_chanselect  = &AS_to_comp,
					count	= &cmp_count );	
		__DBGpr_int( "Graphic Component Count", cmp_count );
		if( cmp_count ) continue;
		else		is_same = FALSE;
	     }

	     om$send( msg =  message ACcpx.ACattach( &int_msg, p ),
                                senderid = model_obj.objid,
                                targetid = model_obj.objid,
                                targetos = model_obj.osnum );

	     om$get_channel_count( objid   = model_obj.objid,
                                   osnum   = model_obj.osnum,
                                   p_chanselect = &AS_to_owner,
                                   count   = (OMuint *) &nb_header );

	     for( m=0; m<nb_header; ++m )
	     {
               om$get_objid_at_index(
                                  objid         = model_obj.objid,
                                  osnum         = model_obj.osnum,
                                  p_chanselect  = &AS_to_owner,
                                  index         = m,
                                  objidaddr     = &header.objid,
                                  osnumaddr     = &header.osnum );

	       if( !vd_$is_ancestry_valid( object  = &header,
                              classid = OPP_ACheader_class_id ) ) continue;

               if( vd_$is_ancestry_valid( object  = &header,
                              classid = OPP_LCcmd_iso_class_id ) ) continue;

	       owner = header;
	       ASget_as_owner( &header, &owner );

	       if( option == 2 )
	       {
	          nd$wait_batch( type       = GR_GEOM_POSTED,
                 		 nb_obj     = 1,
                 		 l_object   = &owner,
                 		 l_obj_info = &cn_type       );
	       }
	       else
	       {
		  vd_$bulk_display( dpmode = GRhd, grids = &owner, 
				    theEnv = &loc_env );
	       }
	     }
	 }
	 __DBGpr_int( "Macro is Same?", is_same );
         if( is_same == FALSE )
         {
            if( option > 0 ) 
	    {
		om$send( msg =  message Root.delete( 0 ),
                         senderid = mgrID.objid,
                         targetid = mgrID.objid,
                         targetos = mgrID.osnum );
	    }
            printf( "<%s> macro is outdated. ", p );
	    if( option >  0 )   printf( "Deleting Cache. " );
	    if( option == 2 )   printf( "Updating....\n" );
	    else		printf( "\n" );
         }
      }
   }

   if( option == 2 )
   {
      saveBroad = ASbroadcast_in_progress ;
      ASbroadcast_in_progress = FALSE ;
      nd$mod_batch( request = ND_INQ, p_ret_mode = &mode );
      if( mode != ND_DEFER )        nd$exec_batch();
      ASbroadcast_in_progress = saveBroad ;
   }

wrapup:
   di$cd( dirname = pwd_name );
   di$free( lines = libNames, count = libCnt );
   di$free( lines = macNames, count = macCnt );

   return 1;
}

end implementation VDSroot;
