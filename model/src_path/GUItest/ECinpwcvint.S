/*
  DESCRIPTION

  This command reads into EMS the point geometry from a PW data-file that 
  contains the formatted linked-list output of - struct PWcvintpt_list.
*/

class specification ECinpwcvint (3:2) of ECpathway;

instance ECinpwcvint
{
  char *infile;
};

override execute;

end specification ECinpwcvint;
