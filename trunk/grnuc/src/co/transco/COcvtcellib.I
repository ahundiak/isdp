/*
 *  This method opens the IGDS cell library, creates the object
 *  space for the EMS cell library, and creates the internal
 *  b-tree for the incomplete cells and begins the conversion
 *  of each element to an object.
 */

class implementation COcvtclsl;

#include "exsysdep.h"
#include "coimport.h"
#include "msdef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "gr.h"
#include "dp.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "OMindex.h"
#include "griomacros.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"
#include "transdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grmessage.h"

%safe
IGRint NumberofBadCells;
%endsafe

#define	 MAX_APP_STRING	15

from OMbtree		import		OMbtree_constr;

method cvt_cellib ( IGRlong *ret_msg; IGRchar *cell_lib_name;
		    IGRchar *seed_file; 
		    struct GRsymbol_lib_file *symb_lib_info)

{
    IGRlong		status;	  	   /* return status      	*/
    struct GRid		object_info;	   /* os id for new objects	*/
    GRobjid		NOD_objid;
    GRobjid		btree_objid;
    unsigned char	btree_type;
    IGRlong		i=0;		   /* variable for delete msg   */
    IGRshort		*ele_ptr;
    IGRulong 		musupu[3];
    IGRchar		mu_name[3];
    IGRdouble		uom_factor;
    IGRboolean		ext_type_nine = FALSE;
    GRspacenum		mod_osnum;
    struct GRmd_env	master_env;
    IGRlong		bytes_ret;
    int			ret_code;
#ifdef BIG_ENDIAN
    IGRint              swapped_int;
#endif
    IGRint              bufsiz;
    IGRchar		errormsg[150];

    status = TRUE;
    bufsiz = sizeof(master_env);
    gr$get_module_env ( msg = ret_msg,
			sizbuf = &bufsiz,
			buffer = &(master_env),
			nret = &bytes_ret );

    if ( strlen ( seed_file ) == 0 )
    {
	/*
	 * use the default seed file
	 */

	for ( i = 0; (1 & status); ++i )
	{
	    if (status = ex$get_path (index = i,
				      path = seed_file,
				      len = 80 ))
	    {
		strcat (seed_file, "config/seed3d.dgn" );
		me->cvt_bufs.file_des = open ( seed_file, GUREAD_ONLY );
    		if ( me->cvt_bufs.file_des != -1 )
		{
		    break;
	   	}
	    }
	}		
        if ( me->cvt_bufs.file_des == -1 )
        {
	    status = FALSE;
	    *ret_msg = GUNOSEEDFILE;
	    goto wrap_up;
        }
    }
    else
    {
	/*
	 *  user has specified seed file
	 */
	 
	me->cvt_bufs.file_des = open ( seed_file, GUREAD_ONLY );
	    
	if  ( me->cvt_bufs.file_des == -1 )
	{
	    *ret_msg = GUNOSEEDFILE;
	    status = FALSE;
	    goto wrap_up;
	}
    }	

    /*
     *  check for valid IGDS seed file
     */
	
    status = GUicheck_igds ( ret_msg, &me->cvt_bufs.file_des );

    if ( ! (1 & status) )
    {
	status = FALSE;
	*ret_msg = GUNOT_IGDS;
	goto wrap_up;
    }

    /*
     *  read the type 9 from the seed file and
     *  compute the proper scale factor to be
     *  applied to all objects that are constructed
     */

    while ( *ret_msg != GULAST_ELEMENT )
    {
        GUget_next_ele ( ret_msg, &me->cvt_bufs );
        
        ele_ptr = (IGRshort *) me->cvt_bufs.ele_buf;

#ifdef BIG_ENDIAN
        if (((*ele_ptr & 0x007f) == 0x0009) && (ext_type_nine == FALSE) )
#else
        if (((*ele_ptr & 0x7f00) == 0x0900) && (ext_type_nine == FALSE) )
#endif
        {
	    ext_type_nine = TRUE;

 	    ele_ptr += 554;

	    /*
	     *  Pull the MU:SU:PU definition from the type 9.
	     */

	    OM_BLOCK_MOVE( ele_ptr, musupu, 12 );

	    ele_ptr += 6;
		
	    OM_BLOCK_MOVE( ele_ptr, mu_name, 2 );
	
	    mu_name[2] = '\0';

#ifdef BIG_ENDIAN
	    GRconv_int(&musupu[1],&swapped_int);
	    GUswapint ( &swapped_int, &musupu[1] );
	    GRconv_int(&musupu[2],&swapped_int);
	    GUswapint ( &swapped_int, &musupu[2] );
#else
	    GUswapint ( &musupu[1], &musupu[1] );
	    GUswapint ( &musupu[2], &musupu[2] );
#endif
	    me->scale_factor = musupu[1] * musupu[2];

	    status = co$cvt_exp_to_wrk ( msg = ret_msg,
				         unit_type = "UOM_DISTANCE",
				         units = 1.0,
				         alias = mu_name,
				         result = &uom_factor );
        /*
         * TR 91n2419.   dhm    02/18/92.
         * mu_name is coming in as MU (most of the time) which the UOM system
         * doesn't reckonize as a valid alias. Therefore, set the status return
         * code back to success and keep processing with the current scale
         * factor.
         */

	    if ( (*ret_msg)&status&1 )
	    {
          me->scale_factor /= uom_factor;
        }
        else
          status = 1;

        }  /* end if type 9 */

    }  /*  end while != GULAST_ELEMENT  */

    close ( me->cvt_bufs.file_des );

    /*
     *  Open IGDS cell library with read only access.
     */

    me->cvt_bufs.file_des = open ( cell_lib_name, GUREAD_ONLY );

    if ( me->cvt_bufs.file_des == -1 )
    {
	status = FALSE;
	*ret_msg = GUNOFILE;
	goto wrap_up;
    }
    else
    {
	status = GUicheck_cellib ( ret_msg, &me->cvt_bufs.file_des );

	if ( ! (1 & status) )
	{
	    status = FALSE;
	    *ret_msg = GUNOT_CELLIB;
	    goto wrap_up;
	}

        ex$message(msgnumb = GR_I_CnvProg);

        ex$message(msgnumb = GR_P_Clear);

	/*
	 *  Create Symbol Library object space
	 */

        status = open(symb_lib_info->file_name,GUREAD_ONLY);
        if(status == -1)
        status = gr$symretrieve_cell_library ( filename = symb_lib_info->file_name,
                                       file_no = &symb_lib_info->file_no,
                                       fstat = EX_new_module,
                                       flag = EX_read_write,
                                       mod_osnum = &mod_osnum );
        else
        status = gr$symretrieve_cell_library ( filename = symb_lib_info->file_name,
                                       file_no = &symb_lib_info->file_no,
                                       fstat = EX_old_module,
                                       flag = EX_read_write,
                                       mod_osnum = &mod_osnum );


	if ( !( 1 & status ) )
  	{
	    *ret_msg = GUNOSYMLIB;
	    status = FALSE;
	    goto wrap_up;
	}		


	/*
	 *  make this new symbol library the
	 *  active symbol library
	 */

	status = gr$symput_asl ( msg = ret_msg,
				 file = symb_lib_info );

	if ( !( 1 & status ) )
  	{
	    *ret_msg = GUNOSYMLIB;
	    status = FALSE;
	    goto wrap_up;
	}		

	status = gr$symget_asl_env ( msg = ret_msg,
				     asl_env = &me->current_env );
	
	if ( !(1 & status) )
	{
	    *ret_msg = GUNOSYMLIB;
	    status = FALSE;
	    goto wrap_up;
	}

	me->current_env.md_id.objid = NULL_OBJID;

	/*
	 *  construct the internal b-tree which will exist
	 *  only while the symbol library is being created
	 *
	 *  this b-tree will contain incomplete symbol
	 *  definition header objects
	 */

	status = GRget_NOD_object ( ret_msg, master_env.md_id.osnum,
				    &NOD_objid );

	if ( (1 & status) )
	{
	    strcpy ( me->btreename, "sd_btree" );
	    btree_type = BTREE_STRING;	/*  BTREE_STRING = 1  */

	    status = om$construct ( classname = "OMbtree",
				    osnum = master_env.md_id.osnum,
				    p_objid = &btree_objid,
				    msg = message OMbtree.OMbtree_constr(
					  BTREE_STRING, &ret_code ) );
	    if ( (1 & status ) )
	    {
		/*
		 *  add the btree to NOD
	  	 */

		status = ex$add_name_to_NOD( NODobjid = NOD_objid,
					objname = me->btreename,
					objid = btree_objid,
					mod_osnum = master_env.md_id.osnum );

		if ( ! (1 & status) )
		{
		    *ret_msg = GUNOSYMLIB;
		    status = FALSE;
		    goto wrap_up;
		}
	    }
	    else
	    {
printf("Failed to Construct OMbtree %s, ret_code: %d\n", me->btreename, 
					ret_code);
		*ret_msg = GUNOSYMLIB;
		status = FALSE;
		goto wrap_up;
	    }
	}
	else
	{
	    *ret_msg = GUNOSYMLIB;
	    status = FALSE;
	    goto wrap_up;
	}

    	/*
      	 *  Read cell library and format element buffers
         *  until reaching the end of file.
         */
	
	sprintf(errormsg,"echo Converting %s >> igdsconv.log",cell_lib_name);
	system(errormsg);

	NumberofBadCells = 0;

        while ( (1 & status) )
	{

	    status = om$send ( mode = OM_e_wrt_object,
			       msg = message COcvtclsl.cvt_next_ele
				     ( ret_msg, &object_info),
			       senderid = my_id,
			       targetid = my_id );
  	}

    	close ( me->cvt_bufs.file_des );

	if(NumberofBadCells > 0)
	{
	sprintf(errormsg,"%d Bad cells in cell library,check igdsconv.log file",NumberofBadCells);

		ex$message(field = ERROR_FIELD,
			   in_buff = errormsg);
	}
	/*
	 *  delete the temporary btree
	 */

	status = ex$remove_name_from_NOD (NODobjid = NOD_objid, 
					objname =  me->btreename,
					mod_osnum = master_env.md_id.osnum );

	status = om$send ( mode = OM_e_wrt_object,
			   msg = message OMbtree.delete ( i ),
			   senderid = NULL,
			   targetid = btree_objid,
			   targetos = master_env.md_id.osnum );

	status = gr$symsave_asl (msg = ret_msg );
	    
        if ( !(1 & status) )
        {
            *ret_msg = GUNOSYMLIB;
        }
    }
		
wrap_up:

    return(status);
}

end implementation COcvtclsl;
