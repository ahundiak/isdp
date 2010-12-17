class implementation COpdu;

#include   <string.h>
#include   <PDUint.h>
#include   <PDUintdef.h>
#include   <igrtypedef.h>
#include   <ctype.h>
#include   <exdef.h>
#include   <exmacros.h>
#include   <dp.h>
#include   <dpmacros.h>
#include   <msdef.h>
#include   <dpdef.h>
#include   <igrdef.h>
#include   <grdpbdef.h>
#include   <grdpb.h>
#include   <grgs.h>
#include   <growner.h>
#include   <gotextdef.h>
#include   <cotxmacros.h>
#include   <OMmacros.h>


extern struct PDUrefresh	*refresh; 
extern struct GRid              PDU_invis_newmod;

from    GRgraphics  import      GRchgprops;
from    GRvg  	    import      GRgetgeom;
from    GRvg  	    import      GRpostabsg;

IGRint  PDUmake_text (text_fields, field_count, new_text, text_len)
  IGRchar		**text_fields;
  IGRint		field_count;
  IGRchar		**new_text;
  IGRint		*text_len; /* changed IGRshort to IGRint APOGEE */
  {
  IGRint	i, j = 0, len;
  IGRchar	*text_string = NULL;
  IGRdouble	move;
  IGRchar attributes = 2, field_num;

  _pdm_debug("In the function PDUmake_text, field_count = %d", field_count);

  _pdm_debug_list ("text fields:", text_fields, field_count, 1 );

  /* make a text string with fields separated by a newline */
  text_string = (IGRchar *) malloc ( 512 * sizeof(IGRchar) );

  _pdm_debug("text index = %d", j);

  for ( i = 0; i < field_count; ++i )
      {
      move = 2.0;				/* 2 character spaces */
      text_string[j++] = ESC;			/* horizontal move */
      text_string[j++] = 'h';
      len = sizeof(IGRdouble);
      OM_BLOCK_MOVE(&move, &text_string[j], len);
      j += len;

      _pdm_debug("text index = %d", j);

      _pdm_debug("field number = %d", i);
      field_num = (IGRchar) i;

      text_string[j++] = ESC;			/* set field */
      text_string[j++] = 'F';
      text_string[j++] = field_num;
      text_string[j++] = attributes;

      _pdm_debug("text field = %s", text_fields[i]);
      _pdm_debug("text index = %d", j);

      len = strlen( text_fields[i] );		/* field data */
      OM_BLOCK_MOVE(text_fields[i], &text_string[j], len);
      j += len;

      _pdm_debug("text index = %d", j);

      text_string[j++] = ESC;			/* end field */
      text_string[j++] = 'E';
      text_string[j++] = ESC;		       /* line feeds seperate fields */
      text_string[j++] = LINEFEED;
      text_string[j++] = ESC;
      text_string[j++] = LINEFEED;

      _pdm_debug("text index = %d", j);
      }

  _pdm_debug("text string = %s", text_string);
  _pdm_debug("text length = %d", j);

  text_string[j] = '\0';
  *text_len = j++;

  *new_text = (IGRchar *) malloc( sizeof(IGRchar) * j );
  OM_BLOCK_MOVE(&text_string[0], *new_text, j);
  PDUdealloc(&text_string);

  if ( PDM_debug_on )
     for (i = 0; i < *text_len; ++i)
	 {	
	 if ( isalpha( (*new_text)[i] ) )
	    printf(" %c ", (*new_text)[i]);
	 else
	    printf(" %x ", (*new_text)[i]);
	 }

  return (PDM_S_SUCCESS);
  }

IGRint	PDUextract_text (text_string, text_len)
  IGRchar	**text_string;
  IGRshort	*text_len;
  {
  IGRint	status = PDM_S_SUCCESS;
  IGRchar	*extracted, *original;

  /* skip justification info imbedded in text string */
  original = *text_string;	/* save pointer to start of string */
  *text_string += 4;		/* for ESC F fieldno attr */
  *text_len -= 6;		/* skip 6 bytes   */

  /* extract useable text characters from input string */
  extracted = (IGRchar *) malloc ( (*text_len+1) * sizeof(IGRchar) );
  strncpy( extracted, *text_string, *text_len );
  extracted[*text_len] = '\0';

  PDUdealloc(&original);
  *text_string = extracted;

  /* verify string contents */
  status = PDUexamine_string (*text_string, *text_len);
  _pdm_status ("PDUexamine_text", status);

  return ( status );
  }

IGRint	PDUexamine_string (input_string, text_len)
  IGRchar	*input_string;
  IGRshort	text_len;
  {
  IGRint	status = PDM_S_SUCCESS, i;

  if ( !PDUnullstr(input_string) )
     {
     for ( i = 0; i < text_len; ++i )
	 {
         if ( isprint(input_string[i]) )
	    {
/*
	    _pdm_debug("text string[%d] :", i);
	    _pdm_debug("\tis a printable character", 0);
	    _pdm_debug("\tcharacter value = <%c>", input_string[i]);
*/
	    }
	 else
	    {
	    _pdm_debug("text string[%d] :", i);
	    _pdm_debug("\tis a non-printable character", 0);
	    _pdm_debug("\tis a control character", 0);
	    _pdm_debug("\t  decimal value = <%d>", input_string[i]);
	    _pdm_debug("\t    octal value = <%o>", input_string[i]);
	    _pdm_debug("\t      hex value = <%x>", input_string[i]);

	    status = PDM_E_EXTRACT_TEXT;
	    }
	 }
     }
  else
     status = PDM_E_EXTRACT_TEXT;

  return ( status );
  }
end implementation COpdu;
‚
