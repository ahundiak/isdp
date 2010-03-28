/* #######################    APOGEE COMPILED   ######################## */
/*
 * Description
 *    This file contains functions which handle complex strings and
 *    shapes.
 *
 * History
 *    ?????     ??/??/??    created a long time ago.
 *    dhm       03/30/92    added the sparc stuff.
 *    dhm       04/22/92    added fix for TR 91n1999.
 *    dhm       08/20/92    added fixes to GUcpxhandler and GUcpxclose_string
 *                          to handle translating out composite curves rigidly
 *                          owned.
 *
 * Notes
 *
 */

class implementation GRvg;

#include "exsysdep.h"
#include "grimport.h"
#include "OMmacros.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"
#include "msdef.h"

/*
 * Static control variables.
 */

%safe
static IGRboolean 	cpx_in_progress=0;	/* complex element is	*/
						/* currently being 	*/
						/* written		*/
static IGRlong 		handler_calls_count=0;	/* number of calls made	*/
						/* to GUcpxhandler	*/
static IGRlong 		offset=0;		/* file offset (pointer)*/
						/* for beginning of cpx	*/
						/* header element	*/
static IGRboolean 	cpx_open=0;		/* call to GUcpxopen	*/
						/* has been made	*/
static OM_S_CHANSELECT  own_chan,comp_chan;
static int		chan_init=0;



/* **************************************************** */
/* Mike, Alex added this                                */
/* **************************************************** */
static IGRboolean       IDtransmvw_modelview_conversion_in_progress = FALSE;





%endsafe

static IGRuchar level_map[8];		/* level map for cells	*/
static IGRuchar class_map[2];		/* class map for cells	*/

/*
 *  This function initializes all of the static control information.
 *  It should be called before any elements are converted and at the
 *  end of each complex.
 */



/* **************************************************** */
/* Mike, Alex added this                                */
/* **************************************************** */
void IDtransmvw_init_cpxhndlr()
{
        IDtransmvw_modelview_conversion_in_progress = TRUE;
}

void IDtransmvw_end_cpxhndlr()
{
        IDtransmvw_modelview_conversion_in_progress = FALSE;
}






GUcpxinit()
{
	if (!chan_init)
	{
	    om$make_chanselect(channame= "GRconnector.to_owners",
		p_chanselect = &own_chan);

	    om$make_chanselect(channame= "GRcmpowner.to_components",
		p_chanselect = &comp_chan);
	    chan_init=1;
	}

	cpx_in_progress = FALSE;
	handler_calls_count = 0;
	offset = 0;
	cpx_open = FALSE;
	return 1;
};

/*
 *  This function should be called prior to writing a complex header
 *  into the IGDS file.  The I/O buffers are flushed by this function
 *  and certain control information is initialized.
 */

IGRboolean GUcpxopen ( msg, dgn_buf, ele_buf, ele_size, file_des,
	previous_state, previous_offset)
IGRlong 	*msg;
IGRchar		*dgn_buf;
IGRchar		*ele_buf;
IGRint		*ele_size;
IGRint		*file_des;
IGRint		*previous_state;
IGRint		*previous_offset;
{
	IGRshort write_mode;
	IGRint	 block_ptr;
	IGRint	 byte_ptr;
	IGRshort type = 0;
	IGRint	 i;

	*msg = MSSUCC;

	*previous_state = cpx_open;
	*previous_offset = offset;

	cpx_open = TRUE;

/*
 *  Flush the I/O buffers so that we can get an accurate file pointer
 *  for the IGDS complex header.
 */

	write_mode = GUFLUSH;
	GUwrite_element ( msg, dgn_buf, ele_buf, &type, ele_size,
			  file_des, &write_mode, &block_ptr, 
			  &byte_ptr );

/*
 *  Initialize the level and class maps for cells.
 */

	for (i = 0; i < 8; i++)
	{
	  level_map[i] = 0;
	}

	for (i = 0; i < 2; i++)
	{
	  class_map[i] = 0;
	}

/*
 *  Get the current file pointer for later use.
 */

	offset = lseek ( *file_des, 0, 1 );



	return ( 1 & *msg );
	
}

/*
 *  This function should be called after all components of a complex
 *  header (which was actually written into an IGDS file) are finished
 *  translating.  The I/O buffers are flushed by this function and
 *  the complex header is updated.  Also, each element in the complex
 *  is marked with the complex bit.
 */

IGRboolean GUcpxclose ( msg, dgn_buf, ele_buf, ele_size, file_des )

IGRlong 	*msg;
IGRchar		*dgn_buf;
IGRchar		*ele_buf;
IGRint		*ele_size;
IGRint		*file_des;

{
	IGRshort write_mode;
	IGRint	 block_ptr;
	IGRint	 byte_ptr;
	IGRshort type = 0;
	IGRlong	 sav_offset;
	IGRlong	 words_in_description;

	IGRint status = 0;
	IGRshort buffer[2];
	IGRlong  cur_offset;
	IGRboolean first_read = TRUE;
        IGRshort wds_in_des;

	*msg = MSSUCC;
	
/*
 *  Flush the I/O buffers so that we can get an accurate file pointer
 *  for the IGDS complex header.
 */

	write_mode = GUFLUSH;
	GUwrite_element ( msg, dgn_buf, ele_buf, &type, ele_size,
			  file_des, &write_mode, &block_ptr, 
			  &byte_ptr );

/*
 *  If GUcpxopen hasn't been called, skip the "fixing" of the complex
 *  header.
 */

	if ( ! cpx_open )
	{
	  goto wrapup;
	}

	cpx_open = FALSE;		/* reset to no GUcpxopen call	*/

/*
 *  Save the current file pointer (which is beyond the end of the last
 *  component of the complex) and back up in the file to the complex
 *  header.
 */

	sav_offset = lseek ( *file_des, 0, 1 );

	if ( lseek ( *file_des, offset, 0 ) != offset )
	{
	  *msg = MSFAIL;
	  goto wrapup;
	}

/*
 *  Calculate the number of words in description of the complex
 *  element.  If too long for the IGDS file, "delete" the header and
 *  reset the file pointer to the current end-of-file.
 */

	words_in_description = sav_offset - offset - 19 * sizeof(IGRshort);
	words_in_description /= sizeof(IGRshort);

/*
 *  A request was made for the cell header not to be deleted when the 
 *  words in description was greater than 65535. Now the cell header is
 *  not deleted and the words in description points to the end of the 
 *  cell header itself. All the elements in the cell are flattened.
 */

	if (words_in_description <= 65535) 
	{
/*
 *  Loop thru each of the elements from the complex header to the current
 *  end-of-file.  The complex header should have it's number of words in
 *  description, level map, and class map updated (maps if a cell). 
 *  The other elements should have their complex bits set.
 */

	  cur_offset = offset;

	  while ( !status )
	  {
	    if ( read( *file_des, buffer, 4 ) != 4)	/* error	*/
	    {
	      status = 1;				/* quit loop	*/
	    }

	    if ( first_read )				/* cpx header	*/
	    {
	      lseek ( *file_des, 32, 1 );
          wds_in_des = (IGRshort) words_in_description;
#ifdef BIG_ENDIAN
          GRconv_short(&wds_in_des, &wds_in_des);
#endif
	      write ( *file_des, &wds_in_des, 2 );
	      lseek ( *file_des, 4, 1 );
	      write ( *file_des, class_map, 2 );
	      write ( *file_des, level_map, 8 );
	      lseek ( *file_des, offset + 4 , 0 );	/* backup 	*/
	      first_read = FALSE;
	    }
	    else
	    {
#ifdef BIG_ENDIAN
          buffer[0] |= 0x8000;
#else
	      buffer[0] |= 0x080;		/* mark as in cpx	*/
#endif
	      lseek ( *file_des, -4, 1 );	/* back-up and		*/
	      write ( *file_des, buffer, 4 );	/* rewrite	*/
	    }
#ifdef BIG_ENDIAN
        GRconv_short(&buffer[1], &buffer[1]);
#endif
	    cur_offset += 4 + buffer[1]*2;	/* find next element	*/
	    if (cur_offset >= sav_offset)	/* found last element?	*/
	    {
	      status = 1;			/* yes, exit loop	*/
	    }
	    lseek ( *file_des, buffer[1]*2, 1);	/* seek to next element	*/
	  }					/* end while (status)	*/
	}					/* end if		*/

/*
 *  Reset file pointer to current end-of-file.
 */

	lseek ( *file_des, sav_offset, 0 );

wrapup:

/*
 *  Re-initialize complex handling.
 */

	GUcpxinit();
	
	return ( 1 & *msg );
	
}

/*
 *  This function tells a complex header object whether or not it should
 *  write a complex header element into the IGDS file (i.e.,
 *  controls the flattening of nested complexes).
 */

IGRboolean GUcpxwritehdr ( msg, twrite )

IGRlong		*msg;			/* output - completion code	*/
IGRboolean	*twrite;		/* output - if TRUE, write out	*/
					/* 	    the current cpx	*/
					/*	    header, else just	*/
					/*	    write components	*/

{

	*msg = MSSUCC;

/*
 *  The only complex headers which should be written to the file are
 *  ones that call when handler_calls_count is zero.
 */
 
	*twrite = TRUE;

	if (handler_calls_count >= 1)
	{
	  *twrite = FALSE;
	}

	return(TRUE);

};

/*
 *  This function is the complex owner handler.  Each object which gets
 *  a GRformatele message should call this function to determine whether
 *  it should actually format itself into the IGDS file.  This function
 *  will cause owning complexes to translate and set-up to flatten
 *  nested complexes.
 */

IGRboolean GUcpxhandler ( msg, cpx_calling, md_env, dgn_buf, bs_buf, 
			  ele_buf, ele_size, file_des, max_overflow, 
			  scale_factor, IGDSclass, properties, level, 
			  id, format, cpx )

IGRlong 	*msg;			/* output - completion code	*/
IGRboolean	*cpx_calling;		/* input - calling object is a  */
					/*         cpx element		*/
struct GRmd_env *md_env;		/* input - context info		*/
IGRchar		*dgn_buf;		/* input - output DGN file buf	*/
IGRchar		*bs_buf;		/* input - geometry buffer	*/
IGRchar		*ele_buf;		/* input - IGDS element buffer	*/
IGRint		*ele_size;		/* input - # bytes in ele_buf	*/
IGRint		*file_des;		/* input - pointer to IGDS file	*/
IGRdouble	*max_overflow;		/* input - max when overflowed	*/
IGRdouble	*scale_factor;		/* input - translation scale	*/
IGRchar		*IGDSclass;		/* input - IGDS class of element*/
IGRushort	*level;			/* input - level of object	*/
IGRushort	*properties;		/* input - object properties	*/
struct GRid	*id;			/* input - object being xlated	*/
IGRboolean	*format;		/* output - continue format ele	*/
IGRboolean	*cpx;			/* output - mark complex bit -	*/
					/*	    reserved for future	*/
{
	
	IGRlong  	status;
	struct GRid	owner;
	OMuword		classid;
	IGRint		index;
        IGRshort    props;

	*msg = MSSUCC;
	*format = TRUE;
	*cpx = FALSE;



/* **************************************************** */
/* Mike, Alex added this                                */
/* **************************************************** */

        if(IDtransmvw_modelview_conversion_in_progress)
        {
                goto wrapup;
        }



	if (!chan_init)
	{
	    om$make_chanselect(channame= "GRconnector.to_owners",
		p_chanselect = &own_chan);

	    om$make_chanselect(channame= "GRcmpowner.to_components",
		p_chanselect = &comp_chan);
	    chan_init=1;
	}

	++handler_calls_count;		/* GUcpxhandler called again	*/

/*
 *  If a complex is in progress and we are being called by a non-complex
 *  object, update the level map and class map.
 *  The variable true_level is an index into level_map.
 */
	if ( cpx_in_progress && (! *cpx_calling ) )
	{
	  GUbit_set ( level_map, *level );
	  GUbit_set ( class_map, *IGDSclass );
	}

	status = om$get_classid ( osnum = id->osnum, objid = id->objid,
				  p_classid = &classid);

	status = om$is_ancestry_valid ( subclassid = classid,
					superclassname = "GRsmdfhdr");

	if ((*properties & GR_RIGID_RELATIONSHIP) || ( status == OM_S_SUCCESS))
	{

/*
 *  Determine if this object is owned.
 */

	  status = om$get_objid_at_index(osnum = id->osnum,
					 objid = id->objid,
					 p_chanselect = &own_chan,
					 index = 0,
					 objidaddr = &owner.objid,
					 osnumaddr = &owner.osnum);

	  if (! (1 & status))
	  {
	    *msg = MSFAIL;
	    goto wrapup;
	  }

	  if ( status != OM_S_SUCCESS )
	  {
	     if ( *cpx_calling )	/* highest level cpx */
	     {
       	 /*  
	   	  *  We found a complex not owned and not a cell.
	   	  *  Initialize to trigger the translation of the entire
	   	  *  complex.
	   	  */

		 handler_calls_count = 0;
		 cpx_in_progress = TRUE;
	     }
	     goto wrapup;
	  }

/*
 *  Now we know the object is owned.  If no complex is in 
 *  progress, we should not format this object (since we are still in
 *  the R-tree pass) and continue determining whether this object should
 *  trigger the translation of the complex.   If a complex is in progress,
 *  we should set to format the element and return.
 */
 
	  if ( ! cpx_in_progress )		/* must be in R-tree	*/
	  {					/* pass => skip		*/
	    *format = FALSE;
	  }

	  /* if this is a complex object within a complex such as a 
	   * composite curve within a cell, continue processing to 
	   * trigger the processing of the complex header.
	   */

	  if ( cpx_in_progress )
	  {
	    goto wrapup;

	  }

/*
 *  If this object is at slot 0 on the channel, it should be the one
 *  to trigger the translation of the complex.
 */

	  status = om$get_index ( osnum_c = owner.osnum,
				  objid_c = owner.objid,
				  p_chanselect = &comp_chan,
				  objid = id->objid,
				  osnum2 = id->osnum,
				  indexaddr = (OMuint *) &index );

	  if (! (1 & status))
	  {
	    *msg = MSFAIL;
	    goto wrapup;
	  }

	  if (index == 0)
	  {
	    int trigger_complex = TRUE;
	    int keep_checking = TRUE;
	    struct GRid 	cur_owner,prev_owner,comp_id;
	
	    status = om$get_classid ( osnum = owner.osnum,
			     objid = owner.objid,
			     p_classid = &classid );
		    
	    /* we must check to see if the owner is a composite curve that
	     * is also owned by a complex.  If so the composite curve will
	     * be triggered by the owner and should not be triggered by
	     * the r-tree pass.  If the composite curve is at index 0 of
	     * the owner, however, it should trigger the conversion.
	     */

   	    status = om$is_ancestry_valid ( subclassid = classid,
				    superclassname = "GRcompcurve" );
	    
	    if ( status == OM_S_SUCCESS )
	    {   
		/* cycle back through all owners of this composite curve
		 * to determine if this object should trigger the 
		 * translation of the complex.  If any of this composite's
		 * owners are themselves components at indexes other
		 * than 0, they will receive a trigger from the
		 * owner and will in turn trigger the translation of 
		 * the composite.
 		 */

		cur_owner = owner;
		prev_owner = owner;
		trigger_complex = FALSE;

		while (keep_checking)
		{
		    status = om$get_objid_at_index(osnum = cur_owner.osnum,
					 objid = cur_owner.objid,
					 p_chanselect = &own_chan,
					 index = 0,
					 objidaddr = &prev_owner.objid,
					 osnumaddr = &prev_owner.osnum);
 		    if ( 1 & status)
		    {			
              /* Get the cur_owner's properties and see if this is a 
               * flexible relationship.  If so, then this compcurve has not
               * been processed and we need to trigger the complex.
               * dhm    4/22/92   fix for TR 91n1999.
               */

              status = om$send(msg = message GRgraphics.GRgetprops(msg,
                                     &props),
                               senderid = NULL_OBJID,
                               targetid = cur_owner.objid,
                               targetos = cur_owner.osnum);
              if (!(1&status))
              {
                *msg = MSFAIL;
                goto wrapup;
              }

              if (!(props & GR_RIGID_RELATIONSHIP))
              {
                keep_checking = FALSE;
                trigger_complex = TRUE;
              }
              else
              {

		        /* see if the current owner is at index 
                         * 0 of his owner
		         */
	  		
		        status = om$get_objid_at_index(
					osnum = prev_owner.osnum,
					objid = prev_owner.objid,
					p_chanselect = &comp_chan,
					index = 0,
					objidaddr = &comp_id.objid,
					osnumaddr = &comp_id.osnum);
			
			    if (!IF_EQ_OBJID(comp_id.objid,cur_owner.objid))
			    {
			    keep_checking = FALSE;
			    }
			    else
			    {
			    cur_owner = prev_owner;
			    }

              }  /* end else GR_RIGID_RELATIONSHIP */

		    }  /* end if status&1 */
		    else
		    {
			keep_checking = FALSE;
			trigger_complex = TRUE;
		    }
		} /* end while */

	    } /* end if compcurve */
	    
	    if (trigger_complex)
	    {
	        status = om$is_ancestry_valid ( subclassid = classid,
					    superclassname = "GRclhdr" );

	        if ( status == OM_S_SUCCESS )
	        {

		    status = om$send (  mode = OM_e_wrt_message,
				    msg = message GRvg.GRformatele ( msg,
					  md_env, dgn_buf, bs_buf, ele_buf,
					  ele_size, file_des, max_overflow,
					  scale_factor ),
			            senderid = NULL_OBJID,
			            targetos = owner.osnum,
			            targetid = owner.objid );

		    if (! (1 & status))
		    {
	               *msg = MSFAIL;
	               goto wrapup;
	    	    }
	        }
	        else
	        {
		    status = om$send ( mode = OM_e_wrt_object,
				    msg = message GRvg.GRformatele ( msg,
					  md_env, dgn_buf, bs_buf, ele_buf,
					  ele_size, file_des, max_overflow,
					  scale_factor ),
			            senderid = NULL_OBJID,
			            targetos = owner.osnum,
			            targetid = owner.objid );

		    if (! (1 & status))
		    {
		   	*msg = MSFAIL;
		   	goto wrapup;
		    }

                    /*
                     * After the entire complex is finished, then turn off the 
                     * cpx_in_progress global variable.  This was not being 
                     * turned off in the right order for complexes inside of 
                     * complexes to work properly (e.g. nested symbols, nested
                     * cells, section view objects, profiles joined together,
                     * or any group of composite curves owned by a rigid
                     * owner).   Doree   8/20/92
                     */

                    cpx_in_progress = 0;
	    	}
	    }
	  }
	}
	else if ( *cpx_calling )		/* highest level cpx	*/
	{
/*  
 *  We found a complex not owned.  Initialize to trigger the translation
 *  of the entire complex.
 */
	  handler_calls_count = 0;
	  cpx_in_progress = TRUE;
	}

wrapup:

	return ( 1 & *msg );

}

IGRboolean GUcpxclose_string ( msg, dgn_buf, ele_buf, ele_size, 
	file_des,type,previous_state,previous_offset)

IGRlong 	*msg;
IGRchar		*dgn_buf;
IGRchar		*ele_buf;
IGRint		*ele_size;
IGRint		*file_des;
IGRshort	*type;
IGRint		*previous_state;
IGRint		*previous_offset;
{
	IGRshort write_mode;
	IGRint	 block_ptr;
	IGRint	 byte_ptr;
/*	IGRshort type = 0;  */       /*   apogee compiler    ..MOHAN   */
	IGRlong	 sav_offset;
	IGRlong	 words_in_description;

	IGRint status = 0;
	IGRshort buffer[2];
	IGRlong  cur_offset;
	IGRboolean first_read = TRUE;
	IGRshort hdr_level = 0;
	IGRshort disp_symb;
	IGRshort element_count=0;
        IGRshort wds_in_des;

	*msg = MSSUCC;
        *type = 0;                  /*  apogee compiler    ..MOHAN   */
	
/*
 *  Flush the I/O buffers so that we can get an accurate file pointer
 *  for the IGDS complex header.
 */

	write_mode = GUFLUSH;
/*	GUwrite_element ( msg, dgn_buf, ele_buf, &type, ele_size,
			  file_des, &write_mode, &block_ptr, 
			  &byte_ptr ); */    /* apogee     ..MOHAN   */

        GUwrite_element ( msg, dgn_buf, ele_buf, type, ele_size,
                          file_des, &write_mode, &block_ptr,
                          &byte_ptr );

/*
 *  If GUcpxopen hasn't been called, skip the "fixing" of the complex
 *  header.
 */

	if ( ! cpx_open )
	{
	  goto wrapup;
	}

/*
 *  Save the current file pointer (which is beyond the end of the last
 *  component of the complex) and back up in the file to the complex
 *  header.
 */
	sav_offset = lseek ( *file_des, 0, 1 );

	if ( lseek ( *file_des, offset, 0 ) != offset )
	{
	  *msg = MSFAIL;
	  goto wrapup;
	}

/*
 *  Calculate the number of words in description of the complex
 *  element.  If too long for the IGDS file, "delete" the header and
 *  reset the file pointer to the current end-of-file.
 */

	words_in_description = sav_offset - offset - 19 * sizeof(IGRshort);
	words_in_description /= sizeof(IGRshort);

	if (words_in_description <= 65535) 
	{
/*
 *  Loop thru each of the elements from the complex header to the current
 *  end-of-file.  
 *  complex header - set number of words in description.
 *		     set number of elements
 *  other elements - set their complex bits
 *		     force symbology and level to be same as the header
 */

	  cur_offset = offset;

	  while ( !status )
	  {
	    if ( read( *file_des, buffer, 4 ) != 4)	/* error	*/
	    {
	      status = 1;				/* quit loop	*/
	    }

	    if ( first_read )				/* cpx header	*/
	    {
	      lseek ( *file_des, 30, 1 );		/* display info	*/
	      read(*file_des,&disp_symb,2);
          wds_in_des = (IGRshort) words_in_description;
#ifdef BIG_ENDIAN
          GRconv_short(&wds_in_des, &wds_in_des);
#endif
	      write ( *file_des, &wds_in_des, 2 );
#ifdef BIG_ENDIAN
          hdr_level = buffer[0] & 0x3F00;
#else
	      hdr_level = buffer[0] & 0x3F;	      	/* save level	*/
#endif
	      lseek ( *file_des, offset + 4 , 0 );	/* backup 	*/
	      first_read = FALSE;
	    }
	    else
	    {
	      /* set the complex bit, display symbology and level	*/

	      ++element_count;			/* increment count	*/

	      lseek( *file_des,30,1);		/* symbology		*/
	      write(*file_des,&disp_symb,2);
#ifdef BIG_ENDIAN
          buffer[0] &= 0xC0FF;
          buffer[0] |= (0x8000 | hdr_level);
#else
	      buffer[0] &= 0xFFC0; 		/* clear level		*/
   	      buffer[0] |= (0x080 | hdr_level);	
#endif
	      lseek ( *file_des, cur_offset, 0 );/* back-up and	*/
	      write ( *file_des, buffer, 4 );	/* rewrite	*/
	    }
#ifdef BIG_ENDIAN
        GRconv_short(&buffer[1], &buffer[1]);
#endif

	    cur_offset += 4 + buffer[1]*2;	/* find next element	*/
	    if (cur_offset >= sav_offset)	/* found last element?	*/
	    {
/*   Don't set the number of elements because I set it in GUotype1214
 *   dhm   4/23/92

	      lseek(*file_des, offset+38,0);	* set header # elements*
#ifdef BIG_ENDIAN
          GRconv_short(&element_count, &element_count);
#endif
	      write(*file_des,&element_count,2);  *******/

	      status = 1;			/* yes, exit loop	*/
	    }
	    lseek ( *file_des, buffer[1]*2, 1);	/* seek to next element	*/
	  }					/* end while (status)	*/
	}					/* end if		*/
	else
	{
	    /* delete the complex header
	     */
	
	    if ( read( *file_des, buffer, 4 ) == 4)	
	    {
#ifdef BIG_ENDIAN
          buffer[0] |= 0x0080;
#else
	      buffer[0] |= 0x8000;
#endif
	      write ( *file_des, buffer, 4 );/* rewrite	*/    
	    }
	}

/*
 *  Reset file pointer to current end-of-file. Reset complex handler
 *  variables to  previous state.
 */
	
	cpx_open = *previous_state;	
	lseek ( *file_des, sav_offset, 0 );

/* Do not set the cpx_in_progress global variable here.  Setting it here caused
 * composite curves rigidly owned to not translate out properly.  Only the
 * first composite curve in the group would translate out.  Set it in 
 * GUcpxhandler() instead of here.  Doree  8/20/92.
 */

/*	cpx_in_progress = cpx_open;  */
	offset = *previous_offset;

wrapup:

	return ( 1 & *msg );
	
}

end implementation GRvg;
