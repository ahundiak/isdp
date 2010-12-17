#include "PDUris_incl.h"
#include "SQLerrordef.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "PDMproto.h"
#include "NFMerrordef.h"

extern int	PDMdebug_on;
extern char PDM_DEBUG_FILE[];
static  char   s[1024];

/* Returns the maximum string size for an attribute
   i.e., attributes with identical domains
*/
 
int	PDMi_find_maxdatatype(attribute,datatype)
char	*attribute;
char	*datatype;
{
 
	PDMdebug("ENTER:PDMi_find_maxdatatype \n");
        sprintf(s,"Attribute <%s>\n",attribute);
	strcpy(datatype,"char(30)");
	PDMdebug("EXIT:PDMi_find_maxdatatype \n");
	return(PDM_S_SUCCESS);
}

