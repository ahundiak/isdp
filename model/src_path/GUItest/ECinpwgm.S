/*
  DESCRIPTION

  This command reads in geometry from a PW data-file and creates an appropriate
  EMS object in the EMS data-base.
  
  Polyline: Inputs a file containing a PW polyline definition (2d or 3d; if 2d,
   Z is set to 0.0) and outputs an EMS linestring.

  B-spline Cv: Inputs a file containing a PW B-spline curve def and outputs
   an EMS general B-spline in the EMS data-base.

  Cv Intersection Points: Reads in a file that contains a PW Cvintpt_list
   structure and generates the intersection points as output.
*/

class specification ECinpwgm (3:2) of ECpathway;

instance ECinpwgm
{
  char *infile;
};

override execute;

end specification ECinpwgm;
