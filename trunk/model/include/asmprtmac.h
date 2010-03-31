#ifndef asmprtmac_include
#define asmprtmac_include

#include "exdef.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "ex.h"
#include "exproto.h"

#define EM_PLACE_PART_FORM 111

/*  executive macros  */


/***********************************************************************/
/*       ex$prtfile_form                                               */
/***********************************************************************/
/*                                                                     */
/*      this macro will bring up a form and display directories        */
/*      and filenames associated with the current working directory    */
/*                                                                     */
/*      Sample call                                                    */
/*      ex$prtfile_form ( title , startdir, file_name, pattern,        */
/*                       file_type, numb, rev, attribs, numattr,       */
/*                       returned_filename, seedfile,                  */
/*                       form_type,response, response_data )           */
/*      char *title     pointer to character string that is the        */
/*                        title of the form                            */
/*      char *startdir  pointer to character string that is the        */
/*                        initial directory, if not specified          */
/*                        defaults to cwd                              */
/*      char *file_name pointer to character string for initial file   */
/*      char *pattern   pointer to character string for pattern to     */
/*                        to match                                     */
/*      int file_types[] an int array of file types to test against    */
/*                        example: Cell files defined in exectypes.mb  */
/*      EMattr *numb,*rev  Partnumber, revision                        */
/*      EMattr **attr    Part attribs                                  */
/*      int    *numattr number of part attribs                         */
/*      char *returned_filename selected filename returned to user     */
/*      char *seedfile   used only by exec                             */
/*      int form_type   EX_STANDARD_FILE_FORM                          */
/*      int *response   response                                       */
/*      char *response_data response_data                              */


#omdef ex$prtfile_form ( title,startdir = 0,file_name =0,
                         pattern = 0,file_types = 0,returned_filename,
			 number, revision,
			 attribs = 0,
                         numattr = 0,
                         seedfile = 0,
                         my_id = my_id,
                         form_type = EX_STANDARD_FILE_FORM, 
                         response,response_data)

EXgetprt_file(title,startdir,file_name,pattern,file_types,
			  number, revision, attribs, numattr,my_id,
                          returned_filename,seedfile,form_type,
                          response, response_data)
#endomdef

#endif
