class implementation COpdu;

#include	<string.h>
#include        <PDUint.h>
#include        <PDUintdef.h>
#include        <exdef.h>
#include        <msdef.h>
#include	<godef.h>
#include        <igrdp.h>
#include        <go.h>
#include        <lcmacros.h>
#include        <grdpbmacros.h>
#include	<gotextdef.h>
#include	<grsymdef.h>
#include	<grsym.h>
#include	<grownerdef.h>
#include	<madef.h>
#include  	<igewinmacros.h>
#include  	<igewindef.h>
#include  	<igewindow.h>

extern struct PDUrefresh        *refresh;

from	GRvg	    import	GRgenabsg;
from    GRreffile   import	GRgetdescription;
from 	GRgraphics  import	GRdelete;
from 	IGEgragad   import	DPinrot;
from 	GRowner	    import	GRadd_components;

#define PARTID_COL 	0
#define REVISION_COL	1
#define CATALOG_COL	2
#define USAGEID_COL	3
#define QUANTITY_COL	4
#define VIEWID_COL	5
#define HISTORY_COL	6
#define ORIENT_COL	7


/***************************************************************************

Document:   CHECKOUT and UPDATE

Algorithm:
	  1.  Make buffer of serial numbers and object
		ids for parts in file. Sort the buffer
		by serial numbers.
	  2.  Loop through both the part_file_buffer
		and the get_child_buffer until the
		end of one of the buffers is reached.
	        The cases will be based on serial num:
	   a. part_file_buffer < get_child_buffer
		If there is a pointer without a related
		child entry, delete the part.
		(using the GRdelete message)
	       Increment pointer to part_file_buf row.
	   b. part_file_buffer = get_child_buffer
	        Use the extract_1stlevel method to
		get the first level part pointer info,
		compare this info in the file with info
		from the PDMget_children buffer.
		If there is a difference in the info
		in the pointer and the child entry,
		update the history using make_history
		method,	then erase and delete the part,
		and update and place part pointer using
		the construct method. Find the range
		of this part using get_rang, and update
		the file_MIN.
	       Increment pointer to part_file_buf row.
	       Increment pointer to get_child_buf row.
	   c. part_file_buffer > get_child_buffer
	   	If there is a child entry without a cor-
		responding part, put the child entry in
		a separate buffer--new_child_buffer.
	       Increment pointer to get_child_buf row.
	 3.  If the new_child_buffer is not null, then
		call the PDUbuffer_to_parts function
		to create each part and place it
		starting at (file_MINx, file_MINy-1000),
		increased in the x direction 1000.
Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	
				

Notes:


Example:
.bp

.ep

History:
	11/01/88	Lynn Mettlen
	1/23/89		Lynn Mettlen--changed
		    	flag in ex$retrieve_module to EX_overwrite
		    	from EX_read_write.			
	1/25/89 	Lynn Mettlen--deleted
		    	ex$save_module and changed flag on ex$close_
		    	module to 1.				

****************************************************************************/
IGRint PDUcompare_objects (child_buffer, row, index, serial_array,
			   orientation, object_found,
			   new_md_env)
  MEMptr		child_buffer;
  struct PDUserial	*serial_array;
  IGRchar		*orientation;
  IGRint		row, index;
  struct PDUid		object_found;
  struct GRmd_env	*new_md_env;
  {
  IGRint           status = PDM_S_SUCCESS;
  IGRlong	   rmsg = MSSUCC;
/*IGRint           type = MAIDMX;      APOGEE */
  IGRint           /*text_count, orient_index,  APOGEE */ change_flag=FALSE;
  IGRint	   select_cols[8]; /* message keys */
  OM_S_OBJID	   senderid;
/*IGRmatrix	   idmatrix;           APOGEE */
/*struct IGRlbsys  *lbs_geom;          APOGEE */

  _pdm_debug("In PDUcompare_objects", 0);

  /* find column numbers of select attributes for these message codes */
  select_cols[ PARTID_COL   ] = PDM_I_ATTR_PARTID;
  select_cols[ REVISION_COL ] = PDM_I_ATTR_REVISION;
  select_cols[ CATALOG_COL  ] = PDM_I_ATTR_CATALOG;
  select_cols[ USAGEID_COL  ] = PDM_I_ATTR_USAGEID;
  select_cols[ QUANTITY_COL ] = PDM_I_ATTR_QUANTITY;
  select_cols[ VIEWID_COL ] = PDM_I_ATTR_VIEWID;
  select_cols[ HISTORY_COL  ] = PDM_I_ATTR_HISTORY;
  select_cols[ ORIENT_COL   ] = PDM_I_ATTR_ORIENT;

  status = PDUmsgs_to_cols( child_buffer, select_cols, 8 );
  _pdm_status ("PDUmsgs_to_cols", status);

  _pdm_debug("change_flag before checks= %d", change_flag);
  /** set change_flag if part info is different from CIT **/
  if (strcmp( serial_array[index].usageid, 
		   _pdm_colptr(child_buffer, row, select_cols[USAGEID_COL])))
       {
	change_flag = TRUE;
        _pdm_debug("change_flag usageid= %d", change_flag);
       }
  else
      if (strcmp( serial_array[index].quantity, 
		    _pdm_colptr(child_buffer, row, select_cols[QUANTITY_COL])))
        {
	change_flag = TRUE;
        _pdm_debug("change_flag  quantity= %d", change_flag);
        }
      else
	 if ( strcmp( serial_array[index].history,
		    _pdm_colptr(child_buffer, row, select_cols[HISTORY_COL])))
           {
	   change_flag = TRUE;
           _pdm_debug("change_flag history= %d", change_flag);
           }
         else
	    if (strcmp( serial_array[index].viewname,
		    _pdm_colptr(child_buffer, row, select_cols[VIEWID_COL])))
	      {
	      change_flag = TRUE;
  	      _pdm_debug("change_flag viewname = %d", change_flag);
	      }
            else
	       if (strcmp( serial_array[index].partid,
		    _pdm_colptr(child_buffer, row, select_cols[PARTID_COL])))
		 {
	         change_flag = TRUE;
                 _pdm_debug("change_flag partid= %d", change_flag);
		 }
	       else
	          if (strcmp( serial_array[index].catalog,
		     _pdm_colptr(child_buffer, row, select_cols[CATALOG_COL])))
		    {
	            change_flag = TRUE;
  		    _pdm_debug("change_flag catalog= %d", change_flag);
		    }
		  else
	             if (strcmp( serial_array[index].revision,
		    _pdm_colptr(child_buffer, row, select_cols[REVISION_COL])))
		       {
	               change_flag = TRUE;
  		       _pdm_debug("change_flag revision = %d", change_flag);
		       }

  _pdm_debug("change_flag right before delete= %d", change_flag);
  if (change_flag)
    {
/*	strncpy( _pdm_colptr(child_buffer, row, select_cols[ORIENT_COL]),
		serial_array[index].orient, 280);

	if (!strcmp( _pdm_colptr(child_buffer, row, select_cols[HISTORY_COL]),
		    PDU_DEFAULT_HISTORY ))
	    strcpy( _pdm_colptr(child_buffer, row, select_cols[HISTORY_COL]),
		    "-1"); */

	/**   delete object from file **/
	_pdm_debug ("new_md_env->md_id.objid = %d", new_md_env->md_id.objid);
	_pdm_debug ("object_found.objid = %d", object_found.objid);
	_pdm_debug ("object_found.osnum = %d", object_found.osnum);
        status = om$send ( msg = message GRgraphics.GRdelete
                         ( &rmsg, new_md_env ),
			      senderid = new_md_env->md_id.objid,
			      targetid = object_found.objid,
			      targetos = object_found.osnum );
	_pdm_rstatus2 ("GRreffile.GRdelete (object in file, not same2)",
			status, rmsg);
    }
   else
     {
      /** delete entry from buffer **/
      status = PDM_I_PART_SAME;
     }
  if ( (1&status) && (status != PDM_I_PART_SAME) )
    status = PDM_S_SUCCESS;

  return (status);
}

#define SERIAL_COL	0
#define PARTID_COL	1

method checkout_update (IGRint *sts)
/* changed sts from IGRlong to IGRint for APOGEE */
  {
   IGRlong	  	nbytes_in_buffer;	/* dpb call param */
   IGRlong		nbytes_transferred;	/* dpb call param */
   IGRlong		rmsg;
   IGRint		status = PDM_S_SUCCESS;
   IGRint		i, j, temp_index /*, os_delete_flag = TRUE   APOGEE*/;
/* IGRint		k, jump, max, temp, temp2, m, n, all_sorted_flag = TRUE;
                                                APOGEE */
   IGRint               n;
   IGRint		obj_count, same_count = 0;
   IGRint		buf_serial_num; /* current buffer row's serial number */
   IGRint	        index = 0;	/* entry in invisible mod table */
 /*IGRint		flag;  APOGEE */ /* write file or don't write */
 /*IGRint		ftype; APOGEE *//* type file -invisible or visible */
 /*IGRchar		temp_filename[OM_K_MAXOSNAME_LEN]; APOGEE */ /* created files name */
 /*IGRchar		file_path[OM_K_MAXOSNAME_LEN]; APOGEE */ /* directory path */
 /*OM_S_CHANSELECT	target_channel;                APOGEE */
   struct PDUid		obj, *objects_found = NULL;
   struct GRmd_env	new_md_env;
   struct PDUreport	list;
   struct PDUserial	*serial_array = NULL;
   struct PDUserindex	*serial_index = NULL;
   IGRchar	   	**orientation = NULL;
   IGRint	   	select_cols[2]; /* message keys */
   struct GRid		newmod;		/* objid,osnum of active module */
 /*struct GRid	window;	*/	/* objid,osnum of new window */
 /*OMuword		osnum = NULL;                  APOGEE */
 /*GRobjid		osid = NULL_OBJID; APOGEE *//* objid of object space */
   MEMptr		child_buffer=NULL;

  _pdm_debug("In the method COpdu.checkout_update", 0);

  status = PDUretrieve_invis_file ( &newmod, &index );
  _pdm_status ("PDUretrieve_invis_file", status);

  if ( 1&status )
   {
   obj.objid = NULL_OBJID;
   obj.osnum = newmod.osnum;
   _pdm_debug("checkout update obj.osnum = %d", obj.osnum);
   _pdm_debug("checkout update obj.osid = %d", obj.objid);
/*   status = PDUmgr_info (&obj, &obj_count);
   _pdm_status ("PDUmgr_info", status); */


   /*** Get Objids of Parts in File ***/
   status = PDUdir_get_objects (obj.osnum, PDU_PARTS_DIR, &objects_found, &obj_count);
   _pdm_status ("PDUdir_get_objects", status);

   if ( 1&status )
     {
     /* allocate memory for orientation string */
     orientation = (IGRchar **) malloc ( obj_count * sizeof (IGRchar *) );
     /* changed IGRchar * to struct PDUserial in next 2 stmts    APOGEE */
     serial_array = (struct PDUserial *) malloc ( obj_count * sizeof (struct PDUserial) );
     serial_index = (struct PDUserindex *) malloc ( obj_count * sizeof (struct PDUserindex) );

     list.type = PDU_REPORT_GENBOM;
     list.data = NULL;
     list.items = PDU_GENBOM_COLS;

     for (i=0; i< obj_count; ++i)
     {
      status = PDUget_attr (&objects_found[i], &list);
      _pdm_status ("PDUget_attr", status);
      PDUstrcpy2 (&serial_array[i].catalog, list.data[0]);
  _pdm_debug("catalog = %s", serial_array[i].catalog);
      PDUstrcpy2 (&serial_array[i].partid, list.data[1]);
  _pdm_debug("partid= %s", serial_array[i].partid);
      PDUstrcpy2 (&serial_array[i].revision, list.data[2]);
  _pdm_debug("revision= %s", serial_array[i].revision);
      PDUstrcpy2 (&serial_array[i].orient, list.data[3]);
  _pdm_debug("orient= %s", serial_array[i].orient);
      PDUstrcpy2 (&serial_array[i].quantity, list.data[4]);
  _pdm_debug("quantity= %s", serial_array[i].quantity);
      PDUstrcpy2 (&serial_array[i].history, list.data[5]);
  _pdm_debug("history= %s", serial_array[i].history);
      PDUstrcpy2 (&serial_array[i].serial, list.data[6]);
  _pdm_debug("serial= %s", serial_array[i].serial);
      PDUstrcpy2 (&serial_array[i].usageid, list.data[7]);
  _pdm_debug("usageid= %s", serial_array[i].usageid);
      PDUstrcpy2 (&serial_array[i].viewname, list.data[8]);
  _pdm_debug("viewname= %s", serial_array[i].viewname);
/*      serial_array[i].index = i; */
      serial_index[i].index = i;
      serial_index[i].serial = atoi ( serial_array[i].serial );
  _pdm_debug("serial = %d", serial_index[i].serial);
     }

   /** SHELL SORT serial index array by serial numbers **/
   status = PDUshell_sort (obj_count, serial_index);
   _pdm_status ("PDUshell_sort", status);


  for (n = 0; n < obj_count; ++n)
    {
    _pdm_debug("serial_index[n].index = %d", serial_index[n].index);
    _pdm_debug("serial_index[n].serial = %d", serial_index[n].serial);
    }
  /***	Get Child Buffer - get buffer with info for part pointers ***/
  child_buffer = (MEMptr) refresh->part_list;

  if ( 1& status )
   {
     i = 0;
     j = 0;

    /* get active module */
    nbytes_in_buffer = sizeof( struct GRmd_env );
    status = gr$get_module_env ( msg = &rmsg,
			       sizbuf = &nbytes_in_buffer,
			       buffer = &new_md_env,
			       nret = &nbytes_transferred );
    _pdm_status2 ("gr$get_module_env", status, rmsg);
    new_md_env.md_id.objid = newmod.objid;
    new_md_env.md_id.osnum = newmod.osnum;

    if ( child_buffer != NULL )
      {
      select_cols[ SERIAL_COL   ] = PDM_I_ATTR_SERIAL;
      select_cols[ PARTID_COL   ] = PDM_I_ATTR_PARTID;

      status = PDUmsgs_to_cols( child_buffer, select_cols, 2 );
      _pdm_status ("PDUmsgs_to_cols", status);
      _pdm_debug ("child_buffer->rows = %d", child_buffer->rows);
  /* print contents of buffer */
  PDUbuffer_data("child buffer", child_buffer);



     /************ Comparisons ******************/

     _pdm_debug ("obj_count = %d", obj_count);
    while ((i < obj_count) && (j < child_buffer->rows))
    {
     buf_serial_num =atoi (_pdm_colptr( child_buffer, j,
                             select_cols[SERIAL_COL]) ); 
     temp_index = serial_index[i].index;
     _pdm_debug ("serial_index[i].serial = %d", serial_index[i].serial);
     _pdm_debug ("buf_serial_num = %d", buf_serial_num);
     if (serial_index[i].serial < buf_serial_num)
	{
	/**  delete object in file - it does not exist in CIT **/
        *sts = om$send ( msg = message GRgraphics.GRdelete
                       ( sts, &new_md_env ),
			 senderid = newmod.objid,
			 targetid = objects_found[temp_index].objid,
			 targetos = objects_found[temp_index].osnum );
	_pdm_rstatus ("GRgraphics.GRdelete (object in file not in CIT1)", *sts);
	++i;
	}
     else
       if (serial_index[i].serial == buf_serial_num)
	{
	_pdm_debug ("objects_found[temp_index].objid = %d", objects_found[temp_index].objid);
	_pdm_debug ("objects_found[temp_index].osnum = %d", objects_found[temp_index].osnum);
	/** object exists in file and CIT--compare the two **/
	status = PDUcompare_objects (child_buffer, j, serial_index[i].index,
			serial_array, orientation[j], objects_found[temp_index],
			&new_md_env);
	_pdm_status ("PDUcompare_objects", status);
	if (status == PDM_I_PART_SAME) /** Part is same **/
	  {
	  ++same_count;
_pdm_debug("SAME_COUNT = %d", same_count);
	  /** set partid to null so PDUbuffer_to_parts won't add it to file **/
          strcpy( _pdm_colptr(child_buffer, j, select_cols[PARTID_COL]), NULLSTR);
_pdm_debug("COL in BUF =%s", _pdm_colptr(child_buffer, j, select_cols[PARTID_COL])); 
	  }
	++i;
	++j;
	}
       else
	/** object doesn't exist in file, but does in CIT - place later into file **/
	++j;
    } /** while **/
  refresh->part_list = (IGRchar *) child_buffer;
/*  if ((same_count != obj_count) || (obj_count < child_buffer->rows)) */
  if (same_count < child_buffer->rows)
     {
     status = PDUbuffer_to_parts ( &newmod );
     _pdm_status ("PDUbuffer_to_parts", status);
     }
   }  /** if for null buffer **/
     _pdm_debug ("i= %d", i);
     for (; i < obj_count; ++i)
	{
	/**  delete object in file - it does not exist in CIT **/
	temp_index = serial_index[i].index;
        *sts = om$send ( msg = message GRgraphics.GRdelete
                       ( &rmsg, &new_md_env ),
			 senderid = newmod.objid,
			 targetid = objects_found[temp_index].objid,
			 targetos = objects_found[temp_index].osnum );
	_pdm_rstatus ("GRreffile.GRdelete (objects in file not in CIT3)", *sts);
	}
   }
  }
  /* Close and save new module object space */
/* d  sprintf( file_path, "%s", "/usr2/pdu/bin/" ); */
/* d  *sts = ex$save_module (index = index);
  _pdm_status ("ex$save_module", *sts); */
/*  *sts = ex$close_module (index = index, flag = 1, ftype = EX_invisible); */
  *sts = ex$close_module (index = index,
			  flag = 1 | EX_ACTINV,
			  ftype = EX_invisible);
  _pdm_status ("ex$close_module", *sts);

 }
  if ( (1&status) && (1 & *sts) )
     *sts = PDM_S_SUCCESS;
  else
     *sts = status;

  if ( objects_found ) free ( objects_found );
  refresh->status = *sts;
  return (OM_S_SUCCESS);
  }
end implementation COpdu;

