/* $Revision: 1.2 $ */
#include "dba.ext"
/* Function:	dba_get_atyp */
int dba_get_atyp (in_type)
int in_type;
{
  int out_type;

  switch (in_type) {
    case ATT_DATE:  case ATT_RIS_TEXT:
    out_type = ATT_ASC;
    break;
    
    case ATT_SHORT:  case ATT_SERIAL:
    out_type = ATT_INT;
    break;
    
    case ATT_FLOAT:  case ATT_DECIMAL:  case ATT_MONEY:
    out_type = ATT_DOUBLE;
    break;
    
    default:
    out_type = in_type;
    break;
  }
  return (out_type);
}
