/****************************************************************
*	Modifications:						*
*		a.  January 23, 1989 by Lynn Mettlen--changed	*
*		    flag in ex$retrieve_module to EX_overwrite	*
*		    from EX_read_write.				*
*		b.  January 25, 1989 by Lynn Mettlen--deleted	*
*		    ex$save_module and changed flag on ex$close_*
*		    module to 1.				*
*		c.  Septemb 1989 PDUretrieve_invis_file created *
*		d.  October 1989 PDUclose_invis_file created    *
*		e.  October 1989 lmm--changed inrot to identity *
*		    matrix when orientation not in cit		*
*		f.  October 1989 no longer creates default win  *
*****************************************************************/
class implementation COpdu;

#include  <PDUint.h>
#include  <PDUintdef.h>
#include  <OMlimits.h>
#include  <grsymdef.h>
#include  <grsym.h>
#include  <msdef.h>
#include  <godef.h>
#include  <go.h>
#include  <gr.h>
#include  <dpmacros.h>
#include  <grdpbmacros.h>
#include  <grownerdef.h>
#include  <exmacros.h>
#include  <igewinmacros.h>
#include  <dpdef.h>
#include  <igewindef.h>
#include  <igewindow.h>
#include  <madef.h>
#include  <MEMerrordef.h>

extern IGRmatrix PDUrot_mat;
extern struct PDUrefresh	*refresh;
extern struct GRid              PDU_invis_newmod;
extern IGRint                   PDU_invis_file_index;

from	GRgraphics  import	GRxform;
from    GRgraphics  import	GRconstruct;
from    IGEgragad   import	gragad_cons;
from    IGEgadget   import	add_gadget;

/****************************************************************************

Document:	PDUclose_invis_file

Description:
	This function provides internal support to the PDU command
	PDC_M_CREATE_GRAPHICS.  It close an invisible file.

Algorithm:
	1. Close file.

Return Status:
	PDM_S_SUCCESS	-	Success
	PDM_E_FAILURE	-	IGE exec macro failed

History:
	10/7/89	Lynn Mettlen    Created

*****************************************************************************/

IGRint	PDUclose_invis_file ( index )
  IGRint	index;	 		/* entry in invisible mod table */
  {
  IGRint	status = PDM_S_SUCCESS;		/* return status */

  _pdm_debug("In the function PDUclose_invis_file", 0);

  _pdm_debug("Invis file index = %d", index);
    
  /* Close and save ( flag = 1 )new module object space */
    status = ex$close_module (index = index,
			  flag = 1 | EX_ACTINV,
			  ftype = EX_invisible);
    _pdm_status ("ex$close_module", status);
  return (status);
  }

/****************************************************************************

Document:	PDUretrieve_invis_file

Description:
	This function provides internal support to the PDU command
	PDC_M_CREATE_GRAPHICS.  It retrieves or creates a graphic file for a
	a non-graphic assembly.

Algorithm:
	1. See if review refresh file exists.
	2. Open file and retrieve module information.
	3. Create a default window in file.

Return Status:
	PDM_S_SUCCESS	-	Success
	PDM_E_FAILURE	-	IGE exec macro failed
	Other status	-	Status returned by PDUdefault_window
				or PDUbuffer_to_parts.

History:
	09/17/89	Lynn Mettlen    Created

*****************************************************************************/

IGRint	PDUretrieve_invis_file ( newmod, index )
  struct GRid	*newmod;		/* objid,osnum of active module */
   /*  struct GRid	*window; */		/* objid,osnum of new window */
  IGRint	*index;	 		/* entry in invisible mod table */
  {
  IGRchar	temp_filename[OM_K_MAXOSNAME_LEN]; /* created files name */
  IGRint	status = PDM_S_SUCCESS;		/* return status */
  IGRint	sts = OM_S_SUCCESS;		/* return status */
  IGRint	msg = MSSUCC;			/* return status */
  GRobjid	osid = NULL_OBJID;		/* objid of object space */

  _pdm_debug("In the function PDUretrieve_invis_file", 0);

  /* see if review refresh file exists on local disk */
  status = PDUverify_file( refresh->rev_filename );
  _pdm_debug("filename after verify %s", refresh->rev_filename);
  _pdm_status("PDUverify_file", status);

  if ( (status == PDM_S_SUCCESS) || ((status == PDM_E_FILE_NOT_FOUND)
			&& (refresh->command == PDC_M_CREATE_GRAPHICS))  )
     {
     /* Open invisible module object space for new graphics */
/*  d   if ( status == PDM_E_FILE_NOT_FOUND )
       {
	status = ex$get_path(index =0, path = seed_path,len = sizeof(seed_path));
	strcat( seed_path, "config/seed_file");
        strcpy( temp_filename, seed_path );
	}
     else   */
     strcpy( temp_filename, refresh->rev_filename );
     _pdm_debug("filename before retrieve = %s", temp_filename);
     status = ex$retrieve_module ( filename =temp_filename,
				      file_no = index,
				      ftype = EX_invisible,
				      flag = EX_overwrite,
				      fstat = EX_default,
				      type = EX_ACTINV,
				      mount_name = temp_filename,
				      msg = &msg );
     _pdm_debug("filename after retrieve : %s", temp_filename);
     _pdm_status ("ex$retrieve_module", status);
     _pdm_debug("index = %d", *index);

     if ( status == 1 )
	{
	/* open invisible module object space for new graphics */
	status = ex$get_invis_info_by_index ( index = *index,
					      mod_osnum =&newmod->osnum,
					      mod_id = &newmod->objid,
					      filed_id = &osid );
	_pdm_status ("ex$get_invis_info_by_index", status);

	if ( 1&status )
	      status = PDM_S_SUCCESS;
	else
	      status = PDM_E_FAILURE;

	}
     else
	status = PDM_E_FAILURE;


     } /* verify file */

     if (( 1&status ) && ( 1&sts ))
	{
	 status = PDM_S_SUCCESS;
	}
  return (status);
  }

end implementation COpdu;

