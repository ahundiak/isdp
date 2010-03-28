/********************************************************************************

dsmacros.h

General Description:

     This file contains all macros needed to access the drawing sheets and
     drawing sheet standards defined for a particular file.

     Macros provided:

          o gr$get_default_standard()        - gets the default standard
          o gr$set_default_standard()        - set the default standard
     
          o gr$get_num_standards()  - retrieves # of string pointers to allocate
          o gr$get_standard()       - gets the standard by name
          o gr$get_standards()      - gets the list of standards available
          o gr$del_standard()       - deletes a standard from the drawing sheet manager
          o gr$mod_standard()       - modifies a standard
          o gr$add_standard()       - adds a standard
          
          o gr$get_num_sheets()     - retrieves # of sheet structure pointers to allocate
          o gr$get_sheet()          - gets the sheet by name
          o gr$get_sheets()         - gets the list of sheet sizes available
          o gr$del_sheet()          - deletes a sheet from the drawing sheet manager
          o gr$mod_sheet()          - modifies a sheet
          o gr$add_sheet()          - adds a sheet

Dependencies:

     dsdef.h
     ds.h
          
History:

     8/31/88   Jay Wallingford     Creation Date
     7/06/92   Scott Walters       Typecast macro args
     
**********************************************************************************/

#ifndef dsmacros_include
#define dsmacros_include
 
#include "ds.h"



/*********************************************************************************

Macro: 

     gr$get_num_standards


     This macro returns the number of standards defined in a particular file
     It should be used by commands to determine the number of standard structures 
     that need to be allocated for the gr$get_standards macro.

Arguments:

     ARGUMENT       DATA TYPE  I/O      DESCRIPTION

     msg            *IGRlong   O        address of the return code

     num_standards  *IGRint    O        number of standards
          
Sample Invocation:

     IGRlong   ok;
     IGRint    num_stds;
     
     status = gr$get_num_standards( msg = &ok,
                                    num_standards = &num_stds)
Notes:                              

     OM_S_SUCCESS        success

     OM_E_ABORT          failure
     
***********************************************************************************/

#omdef gr$get_num_standards( msg,
                             num_standards )
                            
       _ds_do (  (msg),
                  (IGRlong)ds_get,
                  (IGRlong)ds_num_standards,
                 (num_standards),
                  (IGRchar *)NULL)

#endomdef


/**********************************************************************************

Macro: 

     gr$get_standard

     This macro fetches a specific standard by name. The name should be filled in the 
     ds_standard structure.
     

Arguments:

     ARGUMENT:      DATA TYPE           I/O  DESCRIPTION
          
     msg            *IGRlong            O    address of the return code

     standard       *struct ds_standard I    address of the standard struct
                                             to fetch. The name field should
                                             be filled in with the standard 
                                             to be fetched.
Sample Invocation:

     IGRlong   ok;
     struct ds_standard  std;
     
     strcpy(std.name, "ISO");
     
     gr$get_standard( msg = ok,
                      standard = &std);
                              
Notes:

     OM_S_SUCCESS        success

     OM_E_ABORT          failure
     
********************************************************************************/

#omdef gr$get_standard( msg,
                        standard)
                            
       _ds_do ( (msg),
                 (IGRlong)ds_get,
                 (IGRlong)ds_standard_by_name,
                (standard),
                 (IGRchar *)NULL )
                 
#endomdef

/*******************************************************************************

Macro: 

     gr$get_standards 
     
     This macro gets the list of all defined drawing sheet standards for a file.
     The macro gr$get_num_standards may be used to determine the size of the 
     array to allocate for this macro.
     
Arguments:

     ARGUMENTS      DATA TYPE           I/O  DESCRIPTION

     msg            *IGRlong            O    address of the return code
     
     standards      *struct ds_standard O    list of standard structures
     

Sample Invocation:

     IGRlong             ok;
     IGRint              num;
     struct ds_standard  *stds;
     
     gr$get_num_standards( msg = &ok,
                           num_standards = &num );
                           
     stds = om$malloc ( size = sizeof(struct ds_standard) * num );
     
     gr$get_standards ( msg = &ok,
                        standards = stds );

Notes:

     OM_S_SUCCESS        success

     OM_E_ABORT          failure
     
********************************************************************************/

#omdef gr$get_standards( msg,
                         standards)
                            
       _ds_do ( (msg),
                 (IGRlong)ds_get,
                 (IGRlong)ds_standards,
                (standards),
                 (IGRchar *)NULL )
                 
#endomdef

/*******************************************************************************

Macro: 

     gr$get_default_standard

     This macro fetches the default standard for a file.
     
Arguments:
     
     ARGUMENTS      DATA TYPE           I/O  DESCROPTION
     
     msg            *IGRlong            O    address of the return code

     sheet          *struct ds_standard O    default standard

Sample Invocation:

     IGRlong ok;
     struct ds_standard  def_std;

     gr$get_default_standard ( msg = &ok,
                               standard = &def_std );
                               
Notes:

     OM_S_SUCCESS        success

     OM_E_ABORT          failure
     
********************************************************************************/

#omdef gr$get_default_standard( msg,
                                standard )
                                   
       _ds_do ( (msg),
                 (IGRlong)ds_get,
                 (IGRlong)ds_default_standard,
                (standard),
                 (IGRchar *)NULL)
                 
#endomdef

/*******************************************************************************

Macro: 

     gr$set_default_standard

     This macros is used to set the default standard for the file.

Arguments:

     ARGUMENTS      DATA TYPE           I/O  DESCRIPTION
     
     msg            *IGRlong            O    address of the return code
     
     standard       *struct ds_standard I    new default standard

Sample Invocation:

     IGRlong   ok;

     gr$set_default_standard ( msg = &ok,
                               standard = &some_already_defined_std );
Notes:

     OM_S_SUCCESS        success
     OM_E_ABORT          failure (standard not found)
     
********************************************************************************/

#omdef gr$set_default_standard ( msg,
                        	 standard )
                                   
       _ds_do ( (msg),
                 (IGRlong)ds_put,
                 (IGRlong)ds_default_standard,
                (standard),
                 (IGRchar *)NULL)
                 
#endomdef

/******************************************************************************

Macro: 

     gr$del_standard

     This macro will delete a standard from the file.
     
Arguments:

     ARGUMENTS      DATA TYPE           I/O  DESCRIPTION
     
     msg            *IGRlong            O    address of the return code
     standard       *struct ds_standard I    standard to delete

Sample Invocation:

     IGRlong   ok;
     
     gr$del_standard ( msg = &ok,
                       standard = &some_already_defined_std );
     
Notes:
     
     When a standard is deleted ALL SHEETS associated with that standard are
     deleted. If the deleted standard is the default standard the default is
     set to the first standard in the standard list.

     OM_S_SUCCESS        success
     OM_E_ABORT          failure (standard not found)
     
*******************************************************************************/

#omdef gr$del_standard( msg,
                        standard )
                                   
       _ds_do ( (msg),
                 (IGRlong)ds_del,
                 (IGRlong)ds_standards,
                (standard),
                 (IGRchar *)NULL)
                 
#endomdef

/******************************************************************************

Macro: 

     gr$mod_standard
     
     This macro will modify an existing standard.
     
Arguments:

     ARGUMENTS      DATA TYPE           I/O  DESCRIPTION

     msg            *IGRlong            O    address of the return code
     standard       *struct ds_standard I    standard to modify with all
                                             modifications made except standard
                                             name.
     new_name       *IGRchar            I    new name for the standard
	                                     (default = NULL)
Sample Invocation:

     IGRlong   ok;
     IGRchar   name[40];
     
     gr$mod_standard ( msg = &ok,
                       standard = &some_already_defined_standard,
                       new_name = name );
                       
Status Return

     OM_S_SUCCESS        success
     OM_E_ABORT          failure 
     
**********************************************************************************/

#omdef gr$mod_standard (msg,
                        standard,
                        new_name = NULL)
                                   
       _ds_do ( (msg),
                 (IGRlong)ds_put,
                 (IGRlong)ds_standards,
                (standard),
                (new_name) )
                 
#endomdef

/***************************************************************************

Macro: 

     gr$add_standard
     
     This macro adds a standard to the file.
     
Arguments:

     ARGUMENTS      DATA TYPE           I/O  DESCRIPTION
     
     msg            *IGRlong            O    address of the return code

     standard       *struct ds_standard I    standard to add

Notes:

     OM_S_SUCCESS        success

     OM_E_ABORT          failure 
     
************************************************************************************/

#omdef gr$add_standard (msg,
                        standard )
                                   
       _ds_do ( (msg),
                 (IGRlong)ds_put,
                 (IGRlong)ds_standards,
                (standard),
                 (IGRchar *)NULL)
                 
#endomdef

/*********************************************************************************

Macro: 

     gr$get_num_sheets


     This macro returns the number of sheets defined for the default standard.
     It should be used by commands to determine the number of sheet structures 
     that need to be allocated for the gr$get_sheets macro.

Arguments:

     ARGUMENT       DATA TYPE  I/O      DESCRIPTION

     msg            *IGRlong   O        address of the return code

     num_sheets     *IGRint    O        number of sheets

Sample Invocation:

     IGRlong   ok;
     IGRint    num_shts;
     
     status = gr$get_num_sheets( msg = &ok,
                                 num_sheets = &num_shts)
Notes:                              

     OM_S_SUCCESS        success

     OM_E_ABORT          failure
     
***********************************************************************************/

#omdef gr$get_num_sheets( msg,
                          num_sheets )
                            
       _ds_do ( (msg),
                 (IGRlong)ds_get,
                 (IGRlong)ds_num_sheets,
                (num_sheets),
                 (IGRchar *)NULL)
                 
#endomdef


/**********************************************************************************

Macro: 

     gr$get_sheet

     This macro fetches a specific sheet by name and units. The name and units should 
     be filled in the ds_sheet structure.
     

Arguments:

     ARGUMENT:      DATA TYPE           I/O  DESCRIPTION
          
     msg            *IGRlong            O    address of the return code

     sheet          *struct ds_sheet    I    address of sheet structure. The
                                             name and units of the sheet to retrieve
                                             should be filled in.
Sample Invocation:

     IGRlong   ok;
     struct ds_sheet  sht;
     
     strcpy(sht.name, "A Size (8.5 x 11)");
     sht.units = DS_IMPERIAL;  

     gr$get_sheet( msg = ok,
                   sheet = &sht );
                              
Notes:

     OM_S_SUCCESS        success

     OM_E_ABORT          failure
     
********************************************************************************/

#omdef gr$get_sheet( msg,
                     sheet )
                            
       _ds_do ( (msg),
                 (IGRlong)ds_get,
                 (IGRlong)ds_sheet_by_name,
                (sheet),
                 (IGRchar *)NULL )                 
#endomdef


/*******************************************************************************

Macro: 

     gr$get_sheets 
     
     This macro gets the list of all defined drawing sheets for a specified standard
     The macro gr$get_num_sheets may be used to determine the size of the 
     array to allocate for this macro.
     
Arguments:

     ARGUMENTS      DATA TYPE           I/O  DESCRIPTION

     msg            *IGRlong            O    address of the return code
     
     standards      *struct ds_sheet    O    list of sheet structures
     

Sample Invocation:

     IGRlong             ok;
     IGRint              num;
     struct ds_sheet    *shts;
     
     gr$get_num_sheets(  msg = &ok,
                         num_sheets = &num );
                           
     stds = om$malloc ( size = sizeof(struct ds_sheet) * num );
     
     gr$get_sheets ( msg = &ok,
                     sheets = shts );

Notes:

     OM_S_SUCCESS        success

     OM_E_ABORT          failure
     
********************************************************************************/

#omdef gr$get_sheets( msg,
                      sheets )
                            
       _ds_do ( (msg),
                 (IGRlong)ds_get,
                 (IGRlong)ds_sheets,
                (sheets),
                 (IGRchar *)NULL )                 
#endomdef



/******************************************************************************

Macro: 

     gr$del_sheet

     This macro will delete a sheet from the file.
     
Arguments:

     ARGUMENTS      DATA TYPE           I/O  DESCRIPTION
     
     msg            *IGRlong            O    address of the return code
     sheet          *struct ds_sheet    I    sheet to delete

Sample Invocation:

     IGRlong   ok;
     
     gr$del_sheet ( msg = &ok,
                    sheet = &some_already_defined_sht );
     
Notes:
     
     OM_S_SUCCESS        success

     OM_E_ABORT          failure (sheet not found)
     
*******************************************************************************/

#omdef gr$del_sheet ( msg,
                      sheet )
                                   
       _ds_do ( (msg),
                 (IGRlong)ds_del,
                 (IGRlong)ds_sheets,
                (sheet),
                 (IGRchar *)NULL)
                 
#endomdef


/******************************************************************************

Macro: 

     gr$mod_sheet
     
     This macro will modify an existing sheet.
     
Arguments:

     ARGUMENTS      DATA TYPE           I/O  DESCRIPTION

     msg            *IGRlong            O    address of the return code
     sheet          *struct ds_sheet    I    sheet to modify with all
                                             modifications made except sheet
                                             name.
     new_name       *IGRchar            I    new name for the sheet
	                                     (default = NULL)
Sample Invocation:

     IGRlong   ok;
     IGRchar   name[40];
     
     gr$mod_sheet ( msg = &ok,
                    sheet = &some_already_defined_sheet,
                    new_name = name );
                       
Status Return

     OM_S_SUCCESS        success
     OM_E_ABORT          failure 
     
**********************************************************************************/

#omdef gr$mod_sheet ( msg,
                      sheet,
                      new_name = NULL)
                                   
       _ds_do ( (msg),
                 (IGRlong)ds_put,
                 (IGRlong)ds_sheets,
                (sheet),
                (new_name))
                 
#endomdef


/***************************************************************************

Macro: 

     gr$add_sheet
     
     This macro adds a sheet to the file.
     
Arguments:

     ARGUMENTS      DATA TYPE           I/O  DESCRIPTION
     
     msg            *IGRlong            O    address of the return code

     sheet          *struct ds_sheet    I    sheet to add

Notes:

     OM_S_SUCCESS        success

     OM_E_ABORT          failure 
     
************************************************************************************/

#omdef gr$add_sheet ( msg,
                      sheet )
                                   
       _ds_do ( (msg),
                 (IGRlong)ds_put,
                 (IGRlong)ds_sheets,
                (sheet),
                 (IGRchar *)NULL )
                 
#endomdef


#endif

