#include "machine.h"
#include "CMDTOOLS.h"

 long NFMcheck_device_type (dev_type)
   char    *dev_type;
   {
     char *fname = "NFMcheck_device_type" ;

     _NFMdebug ((fname, "Device Type = <%s>\n", dev_type));

          if (! strcmp (dev_type, "HD"));
     else if (! strcmp (dev_type, "FD"));
     else if (! strcmp (dev_type, "UT"));
     else if (! strcmp (dev_type, "CT"));
     else if (! strcmp (dev_type, "MT"));
     else if (! strcmp (dev_type, "CA"));
     else
       {
	 ERRload_struct (NFM, NFM_E_INVALID_DEVICE, "", NULL);
	 _NFMdebug ((fname, "Bad Dev Type : status = <0x%.8x>\n", 
		     NFM_E_INVALID_DEVICE));
	 return (NFM_E_INVALID_DEVICE);          
       }
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
/*******
select n_value from nfmlists where n_listno in \
(select n_listno from nfmvalues where n_attrno in \
(select n_attrno from nfmsysattributes where n_tableno in (select n_tableno from nfmtables  where n_tablename = 'nfmstoragearea')))
**********/



