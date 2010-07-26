#ifndef dpcomacros_include
#define dpcomacros_include 1

/***
	This file contains the macros used to get/set DPcodpb global data.
	
	Dependencies:

	    dpcodef.h
***/


/*--- dp$codpb_get_cct_data ------------------------------------------*/

/*
	This macro gets the Create Color Table data for the current module
	   
	Parameters:
	   
	   *cct_flags       - IGRushort - see dpcodef.h for bit use
	   *ctable_filename - IGRchar

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_get_cct_data( cct_flags, ctable_filename )
					
	DPcodpb_get_cct_data( cct_flags, ctable_filename )
	
#endomdef

/*--- dp$codpb_set_cct_data ------------------------------------------*/

/*
	This macro sets the Create Color Table data in the current module
	   
	Parameters:
	   
	   cct_flags        - IGRushort - see dpcodef.h for bit use
	   *ctable_filename - IGRchar

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_set_cct_data( cct_flags, ctable_filename )
					
	DPcodpb_set_cct_data( cct_flags, ctable_filename )
	
#endomdef

/*--- dp$codpb_get_persp_flags ------------------------------------------*/

/*
	This macro gets the perspective flags for the current module
	   
	Parameters:
	   
	   *persp_flags - IGRushort - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_get_persp_flags( persp_flags )
					
	DPcodpb_get_persp_flags( persp_flags )
	
#endomdef

/*--- dp$codpb_set_persp_flags ------------------------------------------*/

/*
	This macro sets the perspective flags in the current module
	   
	Parameters:
	   
	   persp_flags - IGRushort - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_set_persp_flags( persp_flags )
					
	DPcodpb_set_persp_flags( persp_flags )
	
#endomdef

/*--- dp$codpb_get_sws_flags ------------------------------------------*/

/*
	This macro gets the Set Window Shape flags for the current module
	   
	Parameters:
	   
	   *sws_flags - IGRushort - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_get_sws_flags( sws_flags )
					
	DPcodpb_get_sws_flags( sws_flags )
	
#endomdef

/*--- dp$codpb_set_sws_flags ------------------------------------------*/

/*
	This macro sets the Set Window Shape flags in the current module
	   
	Parameters:
	   
	   sws_flags - IGRushort - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_set_sws_flags( sws_flags )
					
	DPcodpb_set_sws_flags( sws_flags )
	
#endomdef

/*--- dp$codpb_get_dls_flags ------------------------------------------*/

/*
	This macro gets the Define Line Style flags for the current module
	   
	Parameters:
	   
	   *dls_flags - IGRushort - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_get_dls_flags( dls_flags )
					
	DPcodpb_get_dls_flags( dls_flags )
	
#endomdef

/*--- dp$codpb_set_dls_flags ------------------------------------------*/

/*
	This macro sets the Define Line Style flags in the current module
	   
	Parameters:
	   
	   dls_flags - IGRushort - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_set_dls_flags( dls_flags )
					
	DPcodpb_set_dls_flags( dls_flags )
	
#endomdef

/*--- dp$codpb_get_mvv_flags ------------------------------------------*/

/*
	This macro gets the Modify View Volume flags for the current module
	   
	Parameters:
	   
	   *mvv_flags - IGRushort - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_get_mvv_flags( mvv_flags )
					
	DPcodpb_get_mvv_flags( mvv_flags )
	
#endomdef

/*--- dp$codpb_set_mvv_flags ------------------------------------------*/

/*
	This macro sets the Modify View Volume flags in the current module
	   
	Parameters:
	   
	   mvv_flags - IGRushort - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_set_mvv_flags( mvv_flags )
					
	DPcodpb_set_mvv_flags( mvv_flags )
	
#endomdef

/*--- dp$codpb_get_layer_flags ------------------------------------------*/

/*
	This macro gets the Layer command object flags for the current module
	   
	Parameters:
	   
	   *layer_flags - IGRushort - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_get_layer_flags( layer_flags )
					
	DPcodpb_get_layer_flags( layer_flags )
	
#endomdef

/*--- dp$codpb_set_layer_flags ------------------------------------------*/

/*
	This macro sets the Layer command object flags in the current module
	   
	Parameters:
	   
	   layer_flags - IGRushort - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_set_layer_flags( layer_flags )
					
	DPcodpb_set_layer_flags( layer_flags )
	
#endomdef


/*--- dp$codpb_get_dvd_flags ------------------------------------------*/

/*
	This macro gets the display view dynamically flags for the current module
	   
	Parameters:
	   
	   *dvd_flags - IGRushort - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_get_dvd_flags( dvd_flags )
					
	DPcodpb_get_dvd_flags( dvd_flags )
	
#endomdef

/*--- dp$codpb_set_dvd_flags ------------------------------------------*/

/*
	This macro sets the display view dynamically flags in the current module
	   
	Parameters:
	   
	   dvd_flags - IGRushort - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_set_dvd_flags( dvd_flags )
					
	DPcodpb_set_dvd_flags( dvd_flags )
	
#endomdef


/*--- dp$codpb_get_pixel_tolerance ------------------------------------------*/

/*
	This macro gets the pixel tolerance for the current module
	   
	Parameters:
	   
	   *pixel_tol - IGRchar 

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_get_pixel_tolerance( pixel_tol )
					
	DPcodpb_get_pixel_tolerance( pixel_tol )
	
#endomdef

/*--- dp$codpb_set_pixel_tolerance ------------------------------------------*/

/*
	This macro sets the pixel tolerance in the current module
	   
	Parameters:
	   
	   pixel_tol - IGRchar

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_set_pixel_tolerance( pixel_tol )
					
	DPcodpb_set_pixel_tolerance( pixel_tol )
	
#endomdef


/*--- dp$codpb_get_dvd_speed ------------------------------------------*/

/*
	This macro gets the display view dynamically speed for the current module
	   
	Parameters:
	   
	   *dvd_speed - IGRchar 

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_get_dvd_speed( dvd_speed )
					
	DPcodpb_get_dvd_speed( dvd_speed )
	
#endomdef

/*--- dp$codpb_set_dvd_speed ------------------------------------------*/

/*
	This macro sets the display view dynamically speed in the current module
	   
	Parameters:
	   
	   dvd_speed - IGRchar

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_set_dvd_speed( dvd_speed )
					
	DPcodpb_set_dvd_speed( dvd_speed )
	
#endomdef

/*--- dp$codpb_get_so_flags ------------------------------------------*/

/*
	This macro retrieves the symbology override flags in the current module
	   
	Parameters:
	   
	   so_flags     - IGRushort  - see dpcodef.h for bit use
	   so_symbology - IGRdisplay - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_get_so_flags(so_flags = NULL, so_symbology = NULL)

	DPcodpb_get_so_flags(so_flags, so_symbology)

#endomdef


/*--- dp$codpb_put_so_flags ------------------------------------------*/

/*
	This macro saves the symbology override flags in the current module
	   
	Parameters:
	   
	   so_flags     - IGRushort  - see dpcodef.h for bit use
	   so_symbology - IGRdisplay - see dpcodef.h for bit use

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef dp$codpb_put_so_flags(so_flags = NULL, so_symbology = NULL)

	DPcodpb_put_so_flags(so_flags, so_symbology)

#endomdef


#endif /* dpcomacros_include */
