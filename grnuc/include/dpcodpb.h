#ifndef dpcodpb_include
#define dpcodpb_include 1

/* Structure used to map the VLA of characters in the DPcodpb instance data.     */
/* To add data to the DPcodpb add fields to the end of this structure, increase  */
/* the version number, and make the necessary conversions/initializations in the */
/* wake_up method.                                                               */

/* dpbcodef.h contains defines for interpreting the bits of the flags words */

#define DPCODPB_VERSION 3

struct DPcodpb_data
	{
	IGRint    version;      /* version of the structure */
	IGRushort dls_flags;    /* Define Line Style flags */
	IGRushort mvv_flags;    /* Modify View Volume flags */
	IGRushort layer_flags;  /* Layer command object flags */

        /* Version 2 additions */
	IGRchar pixel_tol;      /* Pixel tolerance */
	IGRchar dvd_speed;      /* Display View Dynamically speed */
        IGRushort dvd_flags;    /* Display lists on/off, unlimited zoom, 
                                   performance boost */        
        /* Version 3 additions */
	IGRushort so_flag_values;  		/*symb over form defaults*/
	struct IGRdisplay so_symbology_values;  /*symb over color/weight/style defaults*/

	};

#endif /* dpcodpb_include */
