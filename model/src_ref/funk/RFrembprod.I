class implementation Root;

#include "stdio.h"
#include "string.h"

%safe
static char prev_product[2048];
%endsafe

int SetProductName(char *product)
{
  if (product)
  {
     strcpy(prev_product, product);
  }
  else
  {
    prev_product[0] = '\0';
  }
  return(TRUE);
}

int GetProductName(char *product)
{
  if (product)
  {
    strcpy(product, prev_product);
    return(TRUE);
  }
  else
  {
    return(FALSE);
  }
}

end implementation Root;

