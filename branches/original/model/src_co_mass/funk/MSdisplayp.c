/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
HISTORY

07/21/89    gupta Added code for supporting active coodinate system;

10/14/88    pp The return status from opening the file was not being checked.
            Made appropriate fixes.
4-29-88	    in mass props if prop[13] < 0.0; then the computed properties
	    may not be valid;

10-2-87	    Govindaraj Kuntimad: The original powers were right

08-Jul-1987 J. Brooke King:  Changed the indicated (jBk) moments
to display fourth power instead of second power units.

??-???-1987 Govindaraj Kuntimad:  Creation

*/

/* MSdisplay_prop(stderr_only, filename, option, numb_less_1, obj_descr,
                  glo_loc, origin, prop, factor, master_units, coord_type,
                  coord_name, object_name)

IGRboolean  stderr_only data to be dumped only on stderr
IGRchar		filename;	file name for outputting results

IGRlong		option		0	area properties
				1	mass properties in global origin
				2	mass properties in principal orientn
				3	mass properties in general orientn
					(about any user defined point)

IGRlong		numb_less_1	object index.

IGRchar		obj_descr	description of the object

IGRdouble	glo_loc	  orientation matrix global to local

IGRdouble	origin		point about properties are computed

IGRdouble	prop		properties

IGRdouble	factor  	working units to master units

IGRchar		master_units 	master units string

IGRint      coord_type    active coordinate system - rectangular,
                                                     spherical,
                                                     cylindrical
IGRchar     coord_name    name of coordinate system
IGRchar     object_name
*/

#include <stdio.h>
#include "igrtypedef.h"
#include "csdef.h"

MSdisplay_prop(stderr_only, filename, option, numb_less_1, obj_descr,
               glo_loc, origin, prop, factor, master_units, coord_type,
               c_name, object_name)

IGRchar		*filename;
IGRlong		option;
IGRlong		numb_less_1;
IGRchar		*obj_descr;
IGRdouble	*glo_loc;
IGRdouble	*origin;
IGRdouble	prop[];
IGRdouble	factor;
IGRchar		*master_units;
IGRint      coord_type;
IGRchar     *c_name;
IGRchar     *object_name;
{
  extern  IGRdouble  sqrt();
  IGRdouble	scaling_2, scaling_3, scaling_4, scaling_5, x;

  IGRlong	i;

  static IGRchar	mass_units[3] = "MU",
			squared[4]    = "**2",
			cubed[4]      = "**3",
			forth[4]      = "**4";
  IGRchar  coord_desc[80];

  FILE			*outf;

#define	AREA_PROPERTIES 0

#define ACTIVE_AT_CENTROID 1
#define PRINCIPAL 2
#define GENERAL 3

  outf = NULL;
  if (! stderr_only)
   {
    if ((! strcmp(filename, "stderr")) || (! strcmp (filename, "STDERR")))
         stderr_only = TRUE;
   }
     
  if (! stderr_only)
   {
    outf = fopen(filename, "a");
    if (! outf) 
    fprintf (stderr, "Cannot open file.Possible permission violation\n");
   }

  scaling_2 = factor * factor;
  scaling_3 = scaling_2 * factor;
  scaling_4 = scaling_3 * factor;
  scaling_5 = scaling_4 * factor;

  switch (coord_type)
   {
    case RECTANGULAR:
         strcpy(coord_desc, "Rectangular");
         break;
    case SPHERICAL:
         strcpy(coord_desc, "Spherical");
         break;
    case CYLINDRICAL:
         strcpy(coord_desc, "Cylindrical");
         break;
    default:
         strcpy(coord_desc, "Unknown");
         break;
   }

  strcat(coord_desc, "--");
  strcat(coord_desc, c_name);

  if (option <= AREA_PROPERTIES)		/* area properties */
   {
    IGRdouble	polar_mom, z_axis[3];

    if (stderr_only)
     {
      printf("\n\nSUMMARY OF SURFACE PROPERTIES\n");
      printf("Area properties of: %s\n", object_name);
      printf("Object description: %s\n", obj_descr);
      printf("Length units - %s\n", master_units);
      printf("Coordinate system  %s\n", coord_desc);
     }
    else if (outf)
     {
      fprintf(outf, "\n\nSUMMARY OF SURFACE PROPERTIES\n");
      fprintf(outf, "Area properties of: %s\n", object_name);
      fprintf(outf, "Object description: %s\n", obj_descr);
      fprintf(outf, "Length units - %s\n", master_units);
      fprintf(outf, "Coordinate System  %s\n", coord_desc);
     }

    x = prop[5]*prop[5] + prop[6]*prop[6] + prop[7]*prop[7];

    if(x < 0.95) /* axis not defined */
     {
      if (stderr_only)
       {
        printf("Surface non-planar: area and centroid computed\n");
        if (coord_type == CYLINDRICAL)
          printf("Centroid            [%lg,%lg,%lg]\n",
	              prop[2]/factor, prop[3], prop[4]/factor);
        else if (coord_type == SPHERICAL)
          printf("Centroid            [%lg,%lg,%lg]\n",
	              prop[2]/factor, prop[3], prop[4]);
        else
          printf("Centroid            [%lg,%lg,%lg]\n",
	              prop[2]/factor, prop[3]/factor, prop[4]/factor);

	    printf("Surface area  %lg %s%s\n",
		        prop[11]/scaling_2, master_units, squared);
       }
      else if (outf)
       {
        fprintf(outf, "Surface non-planar: area and centroid computed\n");
        if (coord_type == CYLINDRICAL)
            fprintf(outf, "Centroid            [%lg,%lg,%lg]\n",
                    prop[2]/factor, prop[3], prop[4]/factor);
        else if (coord_type == SPHERICAL)
            fprintf(outf, "Centroid            [%lg,%lg,%lg]\n",
                    prop[2]/factor, prop[3], prop[4]);
        else
            fprintf(outf, "Centroid            [%lg,%lg,%lg]\n",
                    prop[2]/factor, prop[3]/factor, prop[4]/factor);

        fprintf(outf, "Surface area  %lg %s%s\n",
		        prop[11]/scaling_2, master_units, squared);
       }
	  goto wrapup;
     }

    polar_mom = prop[14] + prop[15];

    z_axis[0] = prop[6]*prop[10] - prop[9]*prop[7];
    z_axis[1] = prop[7]*prop[8]  - prop[10]*prop[5];
    z_axis[2] = prop[5]*prop[9]  - prop[8]*prop[6];

    if (stderr_only)
     {
      printf( "Axes Orientation wrt global co-ordinate system:\n");
      printf( "%lg, %lg, %lg\n", prop[5], prop[6], prop[7]);
      printf( "%lg, %lg, %lg\n", prop[8], prop[9], prop[10]);
      printf( "%lg, %lg, %lg\n\n", z_axis[0], z_axis[1], z_axis[2]);
     }
    else if (outf)
     {
      fprintf( outf, "Axes Orientation wrt global co-ordinate system:\n");
      fprintf( outf, "%lg, %lg, %lg\n", prop[5], prop[6], prop[7]);
      fprintf( outf, "%lg, %lg, %lg\n", prop[8], prop[9], prop[10]);
      fprintf( outf, "%lg, %lg, %lg\n\n", z_axis[0], z_axis[1],z_axis[2]);
     }

    if (stderr_only)
     {
      if (coord_type == CYLINDRICAL)
        printf("Centre of Mass      [%lg,%lg,%lg]\n",
               prop[2]/factor, prop[3], prop[4]/factor);
      else if (coord_type == SPHERICAL)
        printf("Centre of Mass      [%lg,%lg,%lg]\n",
               prop[2]/factor, prop[3], prop[4]);
      else
        printf("Centre of Mass      [%lg,%lg,%lg]\n",
               prop[2]/factor, prop[3]/factor, prop[4]/factor);

     }
    else if (outf)
     {
      if (coord_type == CYLINDRICAL)
        fprintf(outf, "Centre of Mass      [%lg,%lg,%lg]\n",
	            prop[2]/factor, prop[3], prop[4]/factor);
      else if (coord_type == SPHERICAL)
        fprintf(outf, "Centre of Mass      [%lg,%lg,%lg]\n",
	            prop[2]/factor, prop[3], prop[4]);
      else
        fprintf(outf, "Centre of Mass      [%lg,%lg,%lg]\n",
	            prop[2]/factor, prop[3]/factor, prop[4]/factor);
     }

    if (stderr_only)
        printf("Surface area        %lg %s%s\n",
               prop[11]/scaling_2, master_units, squared);
    else if (outf)
        fprintf(outf, "Surface area        %lg %s%s\n",
                prop[11]/scaling_2, master_units, squared);


    if (stderr_only)
     {
      printf("First area moment about X axis %lg %s%s\n",
              prop[18] / scaling_3, master_units, cubed);
     }
    else if (outf)
     {
      fprintf(outf, "First area moment about X axis %lg %s%s\n",
              prop[18] / scaling_3, master_units, cubed);
     }

    if (stderr_only)
     {
      printf("First area moment about Y axis %lg %s%s\n",
              prop[19] / scaling_3, master_units, cubed);
     }
    else if (outf)
     {
      fprintf(outf, "First area moment about Y axis %lg %s%s\n",
              prop[19] / scaling_3, master_units, cubed);
     }

    if (stderr_only)
     {
      printf("Moment about X axis %lg %s%s\n",
              prop[14]/scaling_4, master_units, forth);
     }
    else if (outf)
     {
      fprintf(outf, "Moment about X axis %lg %s%s\n",
              prop[14]/scaling_4, master_units, forth);
     }

    if (stderr_only)
     {
      printf("Moment about Y axis %lg %s%s\n",
             prop[15]/scaling_4, master_units, forth);
     }
    else if (outf)
     {
      fprintf(outf, "Moment about Y axis %lg %s%s\n",
              prop[15]/scaling_4, master_units, forth);
     }

     if (stderr_only)
         printf("Product moment XY   %lg %s%s\n",
                 prop[16]/scaling_4, master_units, forth);
     else if (outf)
          fprintf(outf, "Product moment XY   %lg %s%s\n",
                  prop[16]/scaling_4, master_units, forth);

    if (stderr_only)
        printf("Polar moment        %lg %s%s\n\n",
               polar_mom/scaling_4, master_units, forth);
    else if (outf)
        fprintf(outf, "Polar moment        %lg %s%s\n\n",
 	            polar_mom/scaling_4, master_units, forth);

    if (stderr_only)
        printf("Radii of gyration:\n");
    else if (outf)
        fprintf(outf, "Radii of gyration:\n");

    x = sqrt(polar_mom/prop[11])/factor;

    if (stderr_only)
        printf("     Polar  %lg %s\n", x, master_units);
    else if (outf)
        fprintf(outf, "     Polar  %lg %s\n", x, master_units);

    x = sqrt(prop[14]/prop[11])/factor;

    if (stderr_only)
        printf("     X axis %lg %s\n", x, master_units);
    else if (outf)
        fprintf(outf, "     X axis %lg %s\n", x, master_units);

    x = sqrt(prop[15]/prop[11])/factor;
    if (stderr_only)
        printf("     Y axis %lg %s\n", x, master_units);
    else if (outf)
        fprintf(outf, "     Y axis %lg %s\n", x, master_units);
   }
  else	/* mass properties */
   {
    IGRdouble	polar_mom, z_axis[3];

    if(prop[13] < -2.0)	/* properties corrupted */
     {
      if (stderr_only)
          printf(
            "Object not closed: Computed properties may not be valid\n");
      else if (outf)
	      fprintf( outf,
		    "Object not closed: Computed properties may not be valid\n");
     }

    if (stderr_only)
     {
      printf( "\n\nSUMMARY OF MASS PROPERTIES\n");
      printf("Mass properties of: %s\n", object_name);
      printf( "Object number:   %d\n", (numb_less_1 + 1));
      printf( "Object description: %s\n", obj_descr);
      printf( "Mass units - %s; Length units - %s\n",
              mass_units, master_units);
      printf("Coordinate System - %s\n", coord_desc);
     }
    else if (outf)
     {
      fprintf( outf, "\n\nSUMMARY OF MASS PROPERTIES\n");
      fprintf( outf, "Mass properties of: %s\n", object_name);
      fprintf( outf, "Object number:   %d\n", (numb_less_1 + 1));
      fprintf( outf, "Object description: %s\n", obj_descr);
      fprintf( outf, "Mass units - %s; Length units - %s\n",
               mass_units, master_units);
      fprintf( outf, "Coordinate System - %s\n", coord_desc);
     }

    if (stderr_only)
        printf( "Density             %lg\n", prop[1]/prop[0]);
    else if (outf)
        fprintf( outf, "Density             %lg\n", prop[1]/prop[0]);

    if(option == ACTIVE_AT_CENTROID)
     {
      if (stderr_only)
          printf( "Axes orientation    Active\n");
      else if (outf)
          fprintf( outf, "Axes orientation    Active\n");
     }
    else if(option == PRINCIPAL)
     {
      if (stderr_only)
          printf( "Axes orientation    Principal\n");
      else if (outf)
          fprintf( outf, "Axes orientation    Principal\n");
     }
    else if(option == GENERAL)
     {
      if (stderr_only)
       {
        printf( "Axes orientation    General\n");
        if (coord_type == CYLINDRICAL)
            printf( "Reference point          [%lg,%lg,%lg]\n",
	                origin[0]/factor, origin[1], origin[2]/factor);
        else if (coord_type == SPHERICAL)
            printf( "Reference point          [%lg,%lg,%lg]\n",
	                origin[0]/factor, origin[1], origin[2]);
        else
            printf( "Reference point          [%lg,%lg,%lg]\n",
	                origin[0]/factor, origin[1]/factor, origin[2]/factor);
       }
      else if (outf)
       {
        fprintf( outf, "Axes orientation    General\n");
        if (coord_type == CYLINDRICAL)
   	        fprintf(outf, "Reference point          [%lg,%lg,%lg]\n",
	                origin[0]/factor, origin[1], origin[2]/factor);
        else if (coord_type == SPHERICAL)
   	        fprintf(outf, "Reference point          [%lg,%lg,%lg]\n",
	                origin[0]/factor, origin[1], origin[2]);
        else
   	        fprintf(outf, "Reference point          [%lg,%lg,%lg]\n",
	                origin[0]/factor, origin[1]/factor, origin[2]/factor);
       }
      }

     if (stderr_only)
      {
       printf( "Axes Orientation wrt global co-ordinate system:\n");
       printf( "%lg, %lg, %lg\n", glo_loc[0], glo_loc[1], glo_loc[2]);
       printf( "%lg, %lg, %lg\n", glo_loc[3], glo_loc[4], glo_loc[5]);
       printf( "%lg, %lg, %lg\n\n", glo_loc[6], glo_loc[7], glo_loc[8]);
      }
     else if (outf)
      {
       fprintf(outf, "Axes Orientation wrt global co-ordinate system:\n");
       fprintf( outf,"%lg, %lg, %lg\n", glo_loc[0],glo_loc[1],glo_loc[2]);
       fprintf( outf,"%lg, %lg, %lg\n", glo_loc[3],glo_loc[4],glo_loc[5]);
       fprintf(outf,"%lg, %lg, %lg\n\n",glo_loc[6],glo_loc[7],glo_loc[8]);
      }

     if (stderr_only)
      {
       if (coord_type == CYLINDRICAL)
         printf( "Center of Mass     [%lg,%lg,%lg]\n",
  	             prop[2]/factor, prop[3], prop[4]/factor);

       else if (coord_type == SPHERICAL)
         printf( "Center of Mass     [%lg,%lg,%lg]\n",
  	             prop[2]/factor, prop[3], prop[4]);

       else
         printf( "Center of Mass     [%lg,%lg,%lg]\n",
  	             prop[2]/factor, prop[3]/factor, prop[4]/factor);
      }
     else if (outf)
      {
       if (coord_type == CYLINDRICAL)
         fprintf( outf, "Center of Mass       [%lg,%lg,%lg]\n",
	              prop[2]/factor, prop[3], prop[4]/factor);
       else if (coord_type == SPHERICAL)
         fprintf( outf, "Center of Mass        [%lg,%lg,%lg]\n",
	              prop[2]/factor, prop[3], prop[4]);
       else
         fprintf( outf, "Center of Mass       [%lg,%lg,%lg]\n",
	              prop[2]/factor, prop[3]/factor, prop[4]/factor);
      }
/*
 * This means that the caller is requesting to display the centroid
 * of volume.
 * I hate to use this special key, but this is the least impact thing
 * that we can do in the short time we have.
 * Did somebody say quality process?
 * pp 10/28/92
 */
     if (prop[19] == 0.43210) /* Signal to indicate that the center of 
                                 mass is the same as center of volume */
     {
      prop[16] = prop[2];
      prop[17] = prop[3];
      prop[18] = prop[4];
     }

     if ((prop[19] == 0.01234) || (prop[19] == 0.43210))
     {
     if (stderr_only)
      {
       if (coord_type == CYLINDRICAL)
         printf( "Centroid of Volume   [%lg,%lg,%lg]\n",
  	             prop[16]/factor, prop[17], prop[18]/factor);

       else if (coord_type == SPHERICAL)
         printf( "Centroid of Volume   [%lg,%lg,%lg]\n",
  	             prop[16]/factor, prop[17], prop[18]);

       else
         printf( "Centroid of Volume   [%lg,%lg,%lg]\n",
  	             prop[16]/factor, prop[17]/factor, prop[18]/factor);
      }
     else if (outf)
      {
       if (coord_type == CYLINDRICAL)
         fprintf( outf, "Centroid of Volume   [%lg,%lg,%lg]\n",
	              prop[16]/factor, prop[17], prop[18]/factor);
       else if (coord_type == SPHERICAL)
         fprintf( outf, "Centroid of Volume    [%lg,%lg,%lg]\n",
	              prop[16]/factor, prop[17], prop[18]);
       else
         fprintf( outf, "Centroid of Volume   [%lg,%lg,%lg]\n",
	              prop[16]/factor, prop[17]/factor, prop[18]/factor);
      }
     }
     

     if (stderr_only)
         printf( "Volume              %lg %s%s\n",
	             prop[0]/scaling_3, master_units, cubed);
     else if (outf)
         fprintf( outf, "Volume              %lg %s%s\n",
	             prop[0]/scaling_3, master_units, cubed);

     if (stderr_only)
         printf( "Mass                %lg %s\n",
	             prop[1]/scaling_3, mass_units);
     else if (outf)
         fprintf( outf, "Mass                %lg %s\n",
	             prop[1]/scaling_3, mass_units);

     if (stderr_only)
         printf( "Moment about X axis %lg %s %s%s\n",
	             prop[5]/scaling_5, mass_units, master_units, squared);
     else if (outf)
         fprintf( outf, "Moment about X axis %lg %s %s%s\n",
	              prop[5]/scaling_5, mass_units, master_units, squared);

     if (stderr_only)
         printf( "Moment about Y axis %lg %s %s%s\n",
	             prop[6]/scaling_5, mass_units, master_units, squared);
     else if (outf)
         fprintf( outf, "Moment about Y axis %lg %s %s%s\n",
	              prop[6]/scaling_5, mass_units, master_units, squared);

     if (stderr_only)
         printf( "Moment about Z axis %lg %s %s%s\n",
	             prop[7]/scaling_5, mass_units, master_units, squared);
     else if (outf)
         fprintf( outf, "Moment about Z axis %lg %s %s%s\n",
	              prop[7]/scaling_5, mass_units, master_units, squared);

     if(option != PRINCIPAL)
      {
       if (stderr_only)
           printf( "Product moment XY   %lg %s %s%s\n",
                   prop[8]/scaling_5, mass_units, master_units, squared);
       else if (outf)
           fprintf( outf, "Product moment XY   %lg %s %s%s\n",
	               prop[8]/scaling_5, mass_units, master_units, squared);

       if (stderr_only)
           printf( "Product moment YZ   %lg %s %s%s\n",
                prop[9]/scaling_5, mass_units, master_units, squared);
       else if (outf)
           fprintf( outf, "Product moment YZ   %lg %s %s%s\n",
                prop[9]/scaling_5, mass_units, master_units, squared);

       if (stderr_only)
           printf( "Product moment ZX   %lg %s %s%s\n",
               prop[10]/scaling_5, mass_units, master_units, squared);
       else if (outf)
           fprintf( outf, "Product moment ZX   %lg %s %s%s\n",
               prop[10]/scaling_5, mass_units, master_units, squared);
      }
/*
      polar_mom = prop[5] + prop[6];

      if (stderr_only)
         printf( "Polar moment        %lg %s %s%s\n",
	             polar_mom/scaling_5, mass_units, master_units, squared);
      else if (outf)
         fprintf( outf, "Polar moment        %lg %s %s%s\n",
                     polar_mom/scaling_5, mass_units, master_units, squared);
*/

     if (stderr_only)
         printf( "Surface area        %lg %s%s\n\n",
	             prop[11]/scaling_2, master_units, squared);
     else if (outf)
         fprintf( outf, "Surface area        %lg %s%s\n\n",
	             prop[11]/scaling_2, master_units, squared);

     if (stderr_only)
         printf( "Radii of gyration:\n") ;
     else if (outf)
         fprintf( outf, "Radii of gyration:\n") ;

     x = sqrt(prop[5]/prop[1])/factor;
     if (stderr_only)
         printf( "    X axis %lg %s\n", x, master_units);
     else if (outf)
         fprintf( outf, "    X axis %lg %s\n", x, master_units);

     x = sqrt(prop[6]/prop[1])/factor;
     if (stderr_only)
         printf( "    Y axis %lg %s\n", x, master_units);
     else if (outf)
         fprintf( outf, "    Y axis %lg %s\n", x, master_units);

     x = sqrt(prop[7]/prop[1])/factor;
     if (stderr_only)
         printf( "    Z axis %lg %s\n", x, master_units);
     else if (outf)
         fprintf( outf, "    Z axis %lg %s\n", x, master_units);
   }

wrapup:
 if (outf)
  fclose(outf);

  return;
}
