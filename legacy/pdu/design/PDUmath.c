#include	<stdio.h>
#include	<string.h>
#include	<ctype.h>
#include	<time.h>
#include	<OMlimits.h>
#include	<PDUintdef.h>
#include	<PDUint.h>
#include	<igrtypedef.h>
#include	<exdef.h>
#include	<PDUfile_def.h>
#include	<PDUproto.h>

extern struct PDUrefresh	*refresh; 
extern FILE   *PDU_debug_file;

int  PDUfix_orientation ( orient_string )
  char	**orient_string;
  {
  IGRint	status = PDM_S_SUCCESS;
  IGRmatrix	offset;
  IGRchar	*origin;
  
  _pdm_debug("In the function PDUfix_orientation", 0);

  /* a refresh field has been set if origin exists */
  if ( refresh->aux_ptr1 )
     {
     /* access coordinate values of checkin file origin */
     origin = (IGRchar *) refresh->aux_ptr1;
     
     /* convert inverted origin orientation string to a matrix */
     status = PDUstring_to_matrix (origin, offset);
     _pdm_status ("PDUstring_to_matrix", status);

     /* transform original orientation string with origin offset matrix */
     status = PDUxform_string (orient_string, offset);
     _pdm_status ("PDUxform_string", status);
     }

  return (status);
  }

int  PDUstring_to_point ( input_string, point )
  char	*input_string;
  struct PDUpoint  *point;
  {
  IGRchar       *location = NULL, *s;
  
  _pdm_debug("In the function PDUstring_to_point", 0);

  PDUstrcpy (&location, input_string);
 
  s = strtok(location, ":");
  sscanf(s, "%lf", &(point->x) );
  s = strtok(0, ":");
  sscanf(s, "%lf", &(point->y) );
  s = strtok(0, "");
  sscanf(s, "%lf", &(point->z) );

  PDUdealloc (&location);

  return (PDM_S_SUCCESS);
  }

int  PDUdump_point (point)
  double     point[3];
  {
  extern IGRint PDM_debug_on;
  FILE          *pdu_debug_file;

  if ( PDM_debug_on )
     {
/*
      pdu_debug_file = fopen (PDU_DEBUG_FILE, "a");
      fprintf(pdu_debug_file, "\n");
      fprintf(pdu_debug_file, "point coordinates:\n");
      fprintf(pdu_debug_file, "%lf\n", point[0]);
      fprintf(pdu_debug_file, "%lf\n", point[1]);
      fprintf(pdu_debug_file, "%lf\n", point[2]);
      fprintf(pdu_debug_file, "\n");
      fclose(pdu_debug_file);
*/
/*
    ALR This causes a core dump on SGI
      _pdm_debug("point coordinates:",0);
      _pdm_debug("lf",point[0]);
      _pdm_debug("lf",point[1]);
      _pdm_debug("lf",point[2]);
*/
      
     }

  return (PDM_S_SUCCESS);
  }


