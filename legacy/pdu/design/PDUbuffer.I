/*****************************************************************
*								 *
*	Modifications:						 *
*		a.  January 23, 1989 by Lynn Mettlen--changed	 *
*		    flag in ex$retrieve_module to EX_overwrite	 *
*		    from EX_read_write.				 *
*		b.  January 24, 1989 by Lynn Mettlen--deleted	 *
*		    ex$save_module in PDUint_checkin.		 *
*		c.  April 4, 1989 by Lynn Mettlen--added check   *
*		    on reference description to make sure there  *
*		    were at least 3 colons, which indicates file *
*		    is a PDM reference file. (PDUreport_attached *
*		d.  7/11/89 lmm close bom_list in act and deact  *
*		    						 *
*****************************************************************/
class implementation COpdu;

#include	<string.h>
#include	<PDUpart.h>
#include	<PDUint.h>
#include	<PDUintdef.h>
#include	<refdef.h>
#include	<exdef.h>
#include	<exmacros.h>
#include	<grio.h>
#include	<griodef.h>
#include	<griomacros.h>
#include	<msdef.h>
#include	<dpmacros.h>
#include	<dp.h>
#include	<dpdef.h>
#include	<igrdef.h>
#include        <MEMerrordef.h>

extern IGRchar	PDU_last_file [];
extern struct PDUpart    	*part; 

from GRreffile   import  GRgetdescription;
from GRreffile   import  GRputdescription;

IGRint	PDUbuffer_data (description, buffer)
  IGRchar       *description;
  MEMptr	buffer;
  {
  IGRint	status;
  extern	PDM_debug_on;

  /* build array of pointers to data in attribute buffer */
  status = MEMbuild_array( buffer );
  _pdm_status("MEMbuild_array", status);

  if ( (status == MEM_S_SUCCESS) && PDM_debug_on )
     {
     /* build array of pointers to data in attribute buffer */
     MEMprint_buffer( description, buffer, NULL );
     }

  return ( PDM_S_SUCCESS );
  }

IGRint	PDUwrite_data (buffer, values, size_flag)
  MEMptr	buffer;
  IGRchar	**values;
  IGRshort	size_flag;
  {
  IGRint	status, i;
  IGRint	line_size;
  IGRchar	*part_data;
  IGRchar	seperator[2];

  _pdm_debug("In the function PDUwrite_data", 0);

  if ( !size_flag )
     line_size = 256;
  else
     line_size = 512;

  part_data = (IGRchar *) malloc ( line_size * sizeof(IGRchar) );

  if ( part_data == NULL )
     return ( PDM_E_COULD_NOT_MALLOC );

  /* construct row for buffer */
  sprintf(seperator, "%c", PDU_K_DELIMITER);
  part_data[0] = '\0';
  for ( i = 0; i < buffer->columns-1; ++i )
      {
      strcat(part_data, values[i]);
      strcat(part_data, seperator);
      }
  strcat(part_data, values[i]);
/*  strcat(part_data, "\n"); */

  _pdm_debug("writing data to buffer: %s", part_data);

  /* write row to report buffer */
  status = MEMwrite (buffer, part_data);
  _pdm_status ("MEMwrite", status);

  PDUdealloc(&part_data);

  if ( status  == MEM_S_SUCCESS)
     status = PDM_S_SUCCESS;
  else
     status = PDM_E_WRITE_BUFFER;

  return ( status );
  }

IGRint PDUget_keyin (keyin)
IGRchar *keyin;
  {
    IGRlong msg_sts,mask,size;
    struct GRevent event;
    IGRint response;
    IGRchar response_data[GR_MAX_CHAR];

    size = sizeof (event);
    mask = GRm_STRING;

    while (1)
      {
        GRgetevent (&msg_sts,&mask,&size,&event,&response,response_data);
        if (event.response == STRING)
          break;
      }

    strcpy(keyin,event.event.keyin);
    return (event.nbytes);
  }  /* PDUget_keyin */

end implementation COpdu;

 
