class implementation DPcodpb;

#include <string.h>
#include <stdio.h>
#include "OMlimits.h"
#include "OMmacros.h"

#include "OMerrordef.h"
#include "igrtypedef.h"

#include "exdef.h"
#include "exmacros.h"

#include "dpcodpb.h"
#include "dpcodef.h"

#include "dp.h"
#include "DPdlist.h"
PROTO_DPdlist_deactivate_object_space
PROTO_DPdlist_set_status
PROTO_DPdlist_set_performance_boost_status

/* prototype files */
%safe
#include "DPcodpbi.h"
%endsafe

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

static void DPget_codpb_id __((OM_S_OBJID *codpb_id, OMuword *codpb_os));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe



/*--- DPget_codpb_id ----------------------------------------------*/

static void DPget_codpb_id( codpb_id, codpb_os )

	OM_S_OBJID *codpb_id;
	OMuword    *codpb_os;

/*
DESCRIPTION
	This function gets the id,os of the DPcodpb object
	in the current module.
*/

	{
	OM_S_OBJID cur_mod_id;
	OMuword    cur_mod_os;
	ex$get_cur_mod( osnum = &cur_mod_os, id = &cur_mod_id );

	ex$get_super( mod_id        = cur_mod_id,
	              mod_osnum     = cur_mod_os,
	              super_name    = "DPcodpb",
	              super_class   = "DPcodpb",
	              super_id      = codpb_id,
	              super_osnum   = codpb_os,
	              create        = 1 );
	}


/*--- debug -----------------------------------------------------------------*/

method debug()

/*
DESCRIPTION
	Print out instance data
*/

	{
	struct DPcodpb_data *data;

	fprintf( stderr, "DPcodpb INSTANCE DATA\n\n" );
	fprintf( stderr, "   CCT-FLAGS: 0x%X\n", me->cct_flags );
	fprintf( stderr, "   CTABLE-FILE: %s\n", me->ctable_filename );
	fprintf( stderr, "   PERSP-FLAGS: 0x%X\n", me->persp_flags );
	fprintf( stderr, "   SWS-FLAGS: 0x%X\n", me->sws_flags );

	data = (struct DPcodpb_data *) me->c_expansion;
	fprintf( stderr, "   VLA VERSION: %d\n", data->version );
	fprintf( stderr, "   DLS-FLAGS: 0x%X\n", data->dls_flags );
	fprintf( stderr, "   MVV-FLAGS: 0x%X\n", data->mvv_flags );
	fprintf( stderr, "   LAYER-FLAGS: 0x%X\n", data->layer_flags );
	fprintf( stderr, "   DVD-FLAGS: 0x%X\n", data->dvd_flags );
	fprintf( stderr, "   PIXEL-TOLER: %d\n", data->pixel_tol );
	fprintf( stderr, "   DVD-SPEED: %d\n", data->dvd_speed );


	return( OM_S_SUCCESS );
	}  /* debug */


/*--- super_construct -------------------------------------------------------*/

method super_construct()

/*
DESCRIPTION
	Load default instance data 
*/

	{
	struct DPcodpb_data *data;

	me->persp_flags = 0;
	me->cct_flags = 0;
	me->sws_flags = SWS_WIDTH_FIXED;
	me->ctable_filename[0] = '\0';

	om$vla_set_dimension( varray = me->c_expansion, size = sizeof( struct DPcodpb_data ) );
	data = (struct DPcodpb_data *) me->c_expansion;
	
	data->version = DPCODPB_VERSION;
	data->dls_flags = 0;
	data->mvv_flags = MVV_CHANGE_EYE | MVV_CHANGE_COI;
	data->layer_flags = LAYER_DIS_SEARCH_IGN | LAYER_OCC_SEARCH_IGN;
        data->pixel_tol = 2;
        data->dvd_speed = 5;
        data->dvd_flags = DVD_DLIST_ON | DVD_UNLIMITED_ZOOM;
	data->so_flag_values = 0;
	data->so_symbology_values.color  = 0;
	data->so_symbology_values.weight = 0;
	data->so_symbology_values.style  = 0;


	return( OM_S_SUCCESS );
	}

/*--- wake_up ----------------------------------------------------------------*/

method wake_up()

/*
DESCRIPTION
	Wake-up method for the DPcodpb object.  Make sure the expansion VLA's
	are the correct size.
*/

	{
	struct DPcodpb_data *data;

	data = (struct DPcodpb_data *) me->c_expansion;
	if ( data->version < DPCODPB_VERSION )
	{
	   /* make the conversions necessary to update the version */
	   /* e.g., re-size VLA and initialize fields              */

	   om$vla_set_dimension( varray = me->c_expansion, 
                                 size = sizeof( struct DPcodpb_data ) );

	   data = (struct DPcodpb_data *) me->c_expansion;

           /* Convert it from version 1 to 2                       */
           if ( data->version == 1 )
           {
              data->version = 2;

              data->pixel_tol = 2;
              data->dvd_speed = 5;
              data->dvd_flags = DVD_DLIST_ON | DVD_UNLIMITED_ZOOM;
           }

           /* Conversion routines should be provided for 2 to 3,   */
           /* 3 to 4 etc                                           */
           if ( data->version == 2 )
           {
              data->version = 3;
            
	      data->so_flag_values = 0;
	      data->so_symbology_values.color  = 0;
	      data->so_symbology_values.weight = 0;
	      data->so_symbology_values.style  = 0;
	    }
	}

	return( OM_S_SUCCESS );
	}  /* wake_up */

extern int	WeAreExiting();

/*--- sleep ----------------------------------------------------------------*/

method global_class.sleep( int type_sleep )

/*
DESCRIPTION
	Sleep method for the DPcodpb object.  Delete the persistent form
	created by the viewing commands.
*/

	{
        OM_S_OBJID      mod_id;
        OMuword         mod_osnum;
	int		i;

	ex$get_cur_mod(id = &mod_id,osnum = &mod_osnum);

	if (mod_osnum == OM_Gw_current_OS) 
        {
	   DPdelete_vw_form();
	}

        if ( !WeAreExiting() )
        if ( type_sleep != EX_TEMP_SLEEP )
        {
	for( i=1; i<OM_Gw_maxOS; i++ )
           DPdlist_deactivate_object_space( i );
        }

	return( OM_S_SUCCESS );

	}  /* sleep */

/*--- get_cct_data -----------------------------------------------------------*/

method get_cct_data( IGRushort *cct_flags; IGRchar *ctable_filename )

/*
DESCRIPTION
	Get the Create Color Table data from the instance data
*/

	{
	*cct_flags = me->cct_flags;
	strcpy( ctable_filename, me->ctable_filename );
	return( OM_S_SUCCESS );
	}

/*--- set_cct_data -----------------------------------------------------------*/

method set_cct_data( IGRushort cct_flags; IGRchar *ctable_filename )

/*
DESCRIPTION
	Set the Create Color Table data in the instance data
*/

	{
	IGRint string_size;

	me->cct_flags = cct_flags;

	string_size = strlen( ctable_filename ) + 1;
	if ( string_size > om$dimension_of( varray = me->ctable_filename ) )
	   {
	   om$vla_set_dimension( varray = me->ctable_filename, size = string_size );
	   }

	strcpy( me->ctable_filename, ctable_filename );
	return( OM_S_SUCCESS );
	}


/*--- get_persp_flags -----------------------------------------------------------*/

method get_persp_flags( IGRushort *persp_flags )

/*
DESCRIPTION
	Get the perspective flags from the instance data
*/

	{
	*persp_flags = me->persp_flags;
	return( OM_S_SUCCESS );
	}

/*--- set_persp_flags -----------------------------------------------------------*/

method set_persp_flags( IGRushort persp_flags )

/*
DESCRIPTION
	Set the perspective flags in the instance data
*/

	{
	me->persp_flags = persp_flags;
	return( OM_S_SUCCESS );
	}

/*--- get_sws_flags -----------------------------------------------------------*/

method get_sws_flags( IGRushort *sws_flags )

/*
DESCRIPTION
	Get the Set Window Shape flags from the instance data
*/

	{
	*sws_flags = me->sws_flags;
	return( OM_S_SUCCESS );
	}

/*--- set_sws_flags -----------------------------------------------------------*/

method set_sws_flags( IGRushort sws_flags )

/*
DESCRIPTION
	Set the Set Window Shape flags in the instance data
*/

	{
	me->sws_flags = sws_flags;
	return( OM_S_SUCCESS );
	}

/*--- get_dls_flags -----------------------------------------------------------*/

method get_dls_flags( IGRushort *dls_flags )

/*
DESCRIPTION
	Get the Define Line Style flags from the instance data
*/

	{
	struct DPcodpb_data *data;

	data = (struct DPcodpb_data *) me->c_expansion;

	*dls_flags = data->dls_flags;
	return( OM_S_SUCCESS );
	}

/*--- set_dls_flags -----------------------------------------------------------*/

method set_dls_flags( IGRushort dls_flags )

/*
DESCRIPTION
	Set the Define Line Style flags in the instance data
*/

	{
	struct DPcodpb_data *data;

	data = (struct DPcodpb_data *) me->c_expansion;

	data->dls_flags = dls_flags;
	return( OM_S_SUCCESS );
	}

/*--- get_mvv_flags -----------------------------------------------------------*/

method get_mvv_flags( IGRushort *mvv_flags )

/*
DESCRIPTION
	Get the Modify View Volume flags from the instance data
*/

	{
	struct DPcodpb_data *data;

	data = (struct DPcodpb_data *) me->c_expansion;

	*mvv_flags = data->mvv_flags;
	return( OM_S_SUCCESS );
	}

/*--- set_mvv_flags -----------------------------------------------------------*/

method set_mvv_flags( IGRushort mvv_flags )

/*
DESCRIPTION
	Set the Modify View Volume flags in the instance data
*/

	{
	struct DPcodpb_data *data;

	data = (struct DPcodpb_data *) me->c_expansion;

	data->mvv_flags = mvv_flags;
	return( OM_S_SUCCESS );
	}

/*--- get_layer_flags -----------------------------------------------------------*/

method get_layer_flags( IGRushort *layer_flags )

/*
DESCRIPTION
	Get the Layer command object flags from the instance data
*/

	{
	struct DPcodpb_data *data;

	data = (struct DPcodpb_data *) me->c_expansion;

	*layer_flags = data->layer_flags;
	return( OM_S_SUCCESS );
	}

/*--- set_layer_flags -----------------------------------------------------------*/

method set_layer_flags( IGRushort layer_flags )

/*
DESCRIPTION
	Set the Layer command object flags in the instance data
*/

	{
	struct DPcodpb_data *data;

	data = (struct DPcodpb_data *) me->c_expansion;

	data->layer_flags = layer_flags;
	return( OM_S_SUCCESS );
	}

/*--- get_dvd_flags -----------------------------------------------------------*/

method get_dvd_flags( IGRushort *dvd_flags )

/*
DESCRIPTION
	Get the Display View Dynamically flags from the instance data
*/

	{
	struct DPcodpb_data *data;

	data = (struct DPcodpb_data *) me->c_expansion;

	*dvd_flags = data->dvd_flags;
	return( OM_S_SUCCESS );
	}

/*--- set_dvd_flags -----------------------------------------------------------*/

method set_dvd_flags( IGRushort dvd_flags )

/*
DESCRIPTION
	Set the Display View Dynamically flags in the instance data
*/

	{
	struct DPcodpb_data *data;

	data = (struct DPcodpb_data *) me->c_expansion;

        if (dvd_flags & DVD_DLIST_ON)
           DPdlist_set_status(TRUE);
        else
           DPdlist_set_status(FALSE);

        if (dvd_flags & DVD_PERF_BOOST)
           DPdlist_set_performance_boost_status(TRUE);
        else
           DPdlist_set_performance_boost_status(FALSE);

	data->dvd_flags = dvd_flags;
	return( OM_S_SUCCESS );
	}

/*--- get_pixel_tolerance -----------------------------------------------------------*/

method get_pixel_tolerance( IGRchar *pixel_tol )

/*
DESCRIPTION
	Get the pixel tolerance from the instance data
*/

	{
	struct DPcodpb_data *data;

	data = (struct DPcodpb_data *) me->c_expansion;

	*pixel_tol = data->pixel_tol;
	return( OM_S_SUCCESS );
	}

/*--- set_pixel_tolerance -----------------------------------------------------------*/

method set_pixel_tolerance( IGRchar pixel_tol )

/*
DESCRIPTION
	Set the pixel tolerance in the instance data
*/

	{
	struct DPcodpb_data *data;

	data = (struct DPcodpb_data *) me->c_expansion;

	data->pixel_tol = pixel_tol;
	return( OM_S_SUCCESS );
	}

/*--- get_dvd_speed -----------------------------------------------------------*/

method get_dvd_speed( IGRchar *dvd_speed )

/*
DESCRIPTION
	Get the Display View Dynamically speed from the instance data
*/

	{
	struct DPcodpb_data *data;

	data = (struct DPcodpb_data *) me->c_expansion;

	*dvd_speed = data->dvd_speed;
	return( OM_S_SUCCESS );
	}

/*--- set_dvd_speed -----------------------------------------------------------*/

method set_dvd_speed( IGRchar dvd_speed )

/*
DESCRIPTION
	Set the Display View Dynamically speed in the instance data
*/

	{
	struct DPcodpb_data *data;

	data = (struct DPcodpb_data *) me->c_expansion;

	data->dvd_speed = dvd_speed;
	return( OM_S_SUCCESS );
	}


method get_so_flags(IGRushort *so_flags; struct IGRdisplay *so_symbology)
/*********************************************************************
  DESCRIPTION:  This function is used to retrieve the global symbology
		override flags, which specify the current state of the
		gadgets on the Place Symbology Override form, and 
		return them to the calling function.
**********************************************************************/
{
  struct DPcodpb_data *data;

  data = (struct DPcodpb_data *) me->c_expansion;

  if (so_flags != NULL)
     *so_flags = data->so_flag_values;

  if (so_symbology != NULL)
     {
	so_symbology->color  = data->so_symbology_values.color;
        so_symbology->weight = data->so_symbology_values.weight;
        so_symbology->style  = data->so_symbology_values.style;
      }

  return(OM_S_SUCCESS);
}

method put_so_flags(IGRushort *so_flags; struct IGRdisplay *so_symbology)
/*********************************************************************
  DESCRIPTION:  This function is used to save the global symbology
		override flags, which specify the current state of the
		gadgets on the Place Symbology Override form.
**********************************************************************/
{
  struct DPcodpb_data *data;

  data = (struct DPcodpb_data *) me->c_expansion;

  if (so_flags != NULL)
     data->so_flag_values = *so_flags;

  if (so_symbology != NULL)
     {
	data->so_symbology_values.color  = so_symbology->color;
        data->so_symbology_values.weight = so_symbology->weight;
        data->so_symbology_values.style  = so_symbology->style;
     }

  return(OM_S_SUCCESS);
}



/******** Functions to access instance data ********/


/*--- DPcodpb_get_so_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_get_so_flags(IGRushort  *so_flags, 
			    struct IGRdisplay *so_symbology)
#else
IGRint DPcodpb_get_so_flags(so_flags, so_symbology)

	IGRushort         *so_flags;
	struct IGRdisplay *so_symbology;
#endif

/*
DESCRIPTION
	This function retrieves the global gadget defaults for the
	Place Symbology Override form from the current module.
*/
	{
	  IGRlong sts;
	  OM_S_OBJID dpb_id;
	  OMuword    dpb_os;

	  DPget_codpb_id(&dpb_id, &dpb_os );
	  sts = om$send(msg = message DPcodpb.get_so_flags(so_flags, so_symbology),
			targetid = dpb_id, targetos = dpb_os, senderid = NULL_OBJID);

	  return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_get_so_flags */


/*--- DPcodpb_put_so_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_put_so_flags(IGRushort  *so_flags, 
			    struct IGRdisplay *so_symbology)
#else
IGRint DPcodpb_put_so_flags(so_flags, so_symbology)

	IGRushort         *so_flags;
	IGRdisplay struct *so_symbology;
#endif

/*
DESCRIPTION
	This function saves the global gadget defaults for the
	Place Symbology Override form to the current module.
*/
	{
	  IGRlong sts;
	  OM_S_OBJID dpb_id;
	  OMuword    dpb_os;

	  DPget_codpb_id(&dpb_id, &dpb_os );
	  sts = om$send(msg = message DPcodpb.put_so_flags(so_flags, so_symbology),
			targetid = dpb_id, targetos = dpb_os, senderid = NULL_OBJID);

	  return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_put_so_flags */


/*--- DPcodpb_get_cct_data -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_get_cct_data( IGRushort		*cct_flags,
			     IGRchar		*ctable_filename )
#else
IGRint DPcodpb_get_cct_data( cct_flags, ctable_filename )

	IGRushort *cct_flags;
	IGRchar           *ctable_filename;
#endif

/*
DESCRIPTION
	This function reads the Create Color Table data from the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.get_cct_data( cct_flags, ctable_filename ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_get_cct_data */


/*--- DPcodpb_set_cct_data -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_set_cct_data( IGRushort  cct_flags,
			     IGRchar    *ctable_filename )
#else
IGRint DPcodpb_set_cct_data( cct_flags, ctable_filename )

	IGRushort cct_flags;
	IGRchar           *ctable_filename;
#endif

/*
DESCRIPTION
	This function sets the Create Color Table data in the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.set_cct_data( cct_flags, ctable_filename ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_set_cct_data */


/*--- DPcodpb_get_persp_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_get_persp_flags( IGRushort *persp_flags )
#else
IGRint DPcodpb_get_persp_flags( persp_flags )

	IGRushort *persp_flags;
#endif

/*
DESCRIPTION
	This function reads the perspective flags from the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.get_persp_flags( persp_flags ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_get_persp_flags */


/*--- DPcodpb_set_persp_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_set_persp_flags(	IGRushort persp_flags )
#else
IGRint DPcodpb_set_persp_flags( persp_flags )

	IGRushort persp_flags;
#endif
/*
DESCRIPTION
	This function sets the perspective flags in the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.set_persp_flags( persp_flags ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_set_persp_flags */


/*--- DPcodpb_get_sws_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_get_sws_flags( IGRushort *sws_flags )
#else
IGRint DPcodpb_get_sws_flags( sws_flags )

	IGRushort *sws_flags;
#endif

/*
DESCRIPTION
	This function reads the Set Window Shape flags from the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.get_sws_flags( sws_flags ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_get_sws_flags */


/*--- DPcodpb_set_sws_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_set_sws_flags( IGRushort sws_flags )
#else
IGRint DPcodpb_set_sws_flags( sws_flags )

	IGRushort sws_flags;
#endif

/*
DESCRIPTION
	This function sets the Set Window Shape flags in the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.set_sws_flags( sws_flags ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_set_sws_flags */


/*--- DPcodpb_get_dls_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_get_dls_flags( IGRushort *dls_flags )
#else
IGRint DPcodpb_get_dls_flags( dls_flags )

	IGRushort *dls_flags;
#endif

/*
DESCRIPTION
	This function reads the Define Line Style flags from the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.get_dls_flags( dls_flags ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_get_dls_flags */


/*--- DPcodpb_set_dls_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_set_dls_flags( IGRushort dls_flags )
#else
IGRint DPcodpb_set_dls_flags( dls_flags )

	IGRushort dls_flags;
#endif

/*
DESCRIPTION
	This function sets the Define Line Style flags in the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.set_dls_flags( dls_flags ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_set_dls_flags */


/*--- DPcodpb_get_mvv_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_get_mvv_flags( IGRushort *mvv_flags )
#else
IGRint DPcodpb_get_mvv_flags( mvv_flags )

	IGRushort *mvv_flags;
#endif

/*
DESCRIPTION
	This function reads the Modify View Volume flags from the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.get_mvv_flags( mvv_flags ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_get_mvv_flags */


/*--- DPcodpb_set_mvv_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_set_mvv_flags( IGRushort mvv_flags )
#else
IGRint DPcodpb_set_mvv_flags( mvv_flags )

	IGRushort mvv_flags;
#endif

/*
DESCRIPTION
	This function sets the Modify View Volume flags in the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.set_mvv_flags( mvv_flags ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_set_mvv_flags */


/*--- DPcodpb_get_layer_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_get_layer_flags( IGRushort *layer_flags )
#else
IGRint DPcodpb_get_layer_flags( layer_flags )

	IGRushort *layer_flags;
#endif

/*
DESCRIPTION
	This function reads the Layer command object flags from the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.get_layer_flags( layer_flags ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_get_layer_flags */


/*--- DPcodpb_set_layer_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_set_layer_flags( IGRushort layer_flags )
#else
IGRint DPcodpb_set_layer_flags( layer_flags )

	IGRushort layer_flags;
#endif

/*
DESCRIPTION
	This function sets the Layer command object flags in the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.set_layer_flags( layer_flags ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_set_layer_flags */

/*--- DPcodpb_get_dvd_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_get_dvd_flags( IGRushort *dvd_flags )
#else
IGRint DPcodpb_get_dvd_flags( dvd_flags )

	IGRushort *dvd_flags;
#endif

/*
DESCRIPTION
	This function reads the Display View Dynamically flags from the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.get_dvd_flags( dvd_flags ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_get_dvd_flags */


/*--- DPcodpb_set_dvd_flags -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_set_dvd_flags( IGRushort dvd_flags )
#else
IGRint DPcodpb_set_dvd_flags( dvd_flags )

	IGRushort dvd_flags;
#endif

/*
DESCRIPTION
	This function sets the Display View Dynamically flags in the
	current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.set_dvd_flags( dvd_flags ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_set_dvd_flags */

/*--- DPcodpb_get_pixel_tolerance -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_get_pixel_tolerance( IGRchar *pixel_tol )
#else
IGRint DPcodpb_get_pixel_tolerance( pixel_tol )

	IGRchar *pixel_tol;
#endif

/*
DESCRIPTION
	This function reads the pixel tolerance from the current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.get_pixel_tolerance( pixel_tol ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_get_pixel_tolerance */


/*--- DPcodpb_set_pixel_tolerance -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_set_pixel_tolerance( IGRchar pixel_tol )
#else
IGRint DPcodpb_set_pixel_tolerance( pixel_tol )

	IGRchar pixel_tol;
#endif

/*
DESCRIPTION
	This function sets the pixel tolerance in the current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.set_pixel_tolerance( pixel_tol ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_set_pixel_tolerance */

/*--- DPcodpb_get_dvd_speed -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_get_dvd_speed( IGRchar *dvd_speed )
#else
IGRint DPcodpb_get_dvd_speed( dvd_speed )

	IGRchar *dvd_speed;
#endif

/*
DESCRIPTION
	This function reads the Display View Dynamically speed from the 
        current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.get_dvd_speed( dvd_speed ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_get_dvd_speed */


/*--- DPcodpb_set_dvd_speed -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPcodpb_set_dvd_speed( IGRchar dvd_speed )
#else
IGRint DPcodpb_set_dvd_speed( dvd_speed )

	IGRchar dvd_speed;
#endif

/*
DESCRIPTION
	This function sets the Display View Dynamically speed in the 
        current module.
*/

	{
	IGRlong    sts;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;

	DPget_codpb_id( &dpb_id, &dpb_os );

	sts = om$send( msg      = message DPcodpb.set_dvd_speed( dvd_speed ),
	               targetid = dpb_id,
	               targetos = dpb_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* DPcodpb_set_dvd_speed */

end implementation DPcodpb;
