#ifndef filemacros_h
#define filemacros_h

/*
 * File:    
 *        filemacros.h
 *
 * Description:
 *        This file contains the macros for adding/deleting/retrieving info
 *        from the ASCII part data file that is present in the directory.
 *        If the directory name in the input to a macro is NULL, PWD is  
 *        assumed.
 *
 *        The ASCII partdata file is maintained in the working directory so
 *        as to speed up the process of retrieval of part data info.
 *
 * Macros Provided:
 *        asm$num_directory_parts()
 *        asm$add_directory_part()
 *        asm$mod_directory_part()
 *        asm$rem_directory_part()
 *        asm$get_directory_part()
 *        asm$update_ascii_file()
 *
 * Dependencies:
 *
 *
 * Notes:
 *
 *   ASCII File Format:
 *        Except for the first two lines, the record length in the 
 *        ASCII file is taken as 115 bytes + the newline char.
 *        The fields are separated by a tab char. 
 *
 *        Total Number of Parts   : %04d 
 *        Status\tFilename\tPartNumber\tRevision\tPartDescription\tProduct\n   
 *        char(5) char(20)  char(20)    char(5)   char(50)         char(10)
 *
 *        The Status field indicates if the Part is deleted or not, D or A.
 *
 * History:
 *
 *      /07/93     Krishna Kumar                creation date
 *
 */

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$num_directory_parts                                            |
 |                                                                           |
 | This macro returns the number of parts in the ASCII partdata file.        |
 |                                                                           |
 | Input:                                                                    |
 |        char *dir			    Directory of partdata ascii file.|
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * p_num           number of parts.                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/

#omdef asm$num_directory_parts (msg,
                        dir = NULL,
                        p_num )

       EMasc_num_parts( (msg),
		      (dir),
		      (p_num))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$add_directory_part                                             |
 |                                                                           |
 | This macro adds an entry into the ASCII part data file, if the ascii file |
 | does not exist in the given directory, it is created.                     |
 |									     |
 | Input:                                                                    |
 |        IGRchar         * dir		    Directory of partdata ascii file.|
 |        IGRchar         * filename        Name of the design file          |
 |        IGRchar         * numb            partnumber                       |
 |        IGRchar         * rev             partrevision                     |
 |        IGRchar         * desc            part description                 |
 |        IGRchar         * prod            Product                          |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |                                                                           |
 +---------------------------------------------------------------------------*/

#omdef asm$add_directory_part (msg,
                        dir      = NULL,
                        filename,
			numb = NULL,
			rev  = NULL,
			desc = NULL,
			prod = NULL )

       EMasc_add_part( (msg),
		     (dir),
		     (filename),
		     (numb),
                     (rev),
		     (desc),
                     (prod))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$mod_directory_part                                             |
 |                                                                           |
 | This macro updates entry in  the ASCII part data file.                    |
 |									     |
 | Input:                                                                    |
 |        IGRchar         * dir		    Directory of partdata ascii file.|
 |        IGRchar         * filename        Name of the design file          |
 |        IGRchar         * numb            partnumber                       |
 |        IGRchar         * rev             partrevision                     |
 |        IGRchar         * desc            part description                 |
 |        IGRchar         * prod            Product                          |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |                                                                           |
 +---------------------------------------------------------------------------*/

#omdef asm$mod_directory_part (msg,
                        dir      = NULL,
                        filename,
			numb = NULL,
			rev  = NULL,
			desc = NULL,
			prod = NULL )

       EMasc_mod_part( (msg),
		     (dir),
		     (filename),
		     (numb),
                     (rev),
		     (desc),
                     (prod))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$rem_directory_part                                             |
 |                                                                           |
 | This macro removes an entry from the ASCII part data file                 |
 |									     |
 | Input:                                                                    |
 |        IGRchar         * dir		    Directory of partdata ascii file.|
 |        IGRchar         * filename        Name of the design file          |
 |        IGRint          index             Index of the part in file        |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |                                                                           |
 +---------------------------------------------------------------------------*/

#omdef asm$rem_directory_part (msg,
                        dir      = NULL,
                        filename = NULL,
			index = -1)

       EMasc_rem_part( (msg),
		     (dir),
		     (filename),
		     (index))

#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_directory_part                                             |
 |                                                                           |
 | This macro gets a part from the ASCII part data file. If the "filename"   |
 | arg is an empty string "", and if either "index" or "numb" & "rev" are    |
 | specified, the part filename is copied into "filename". Conversely, if    |
 | "filename" is specified, the "numb", "rev" and "desc" of the part are     |
 | returned. Memory should be allocated by the caller.                       |
 |									     |
 | Input:                                                                    |
 |        IGRchar         * dir		    Directory of partdata ascii file.|
 |        IGRint          index             Index of the part in file.       |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRchar         * desc            partdesc, if filename is Input   |
 |        unsigned short  * perm            file mode, from stat()           |
 |                                                                           |
 | In/Out:                                                                   |
 |        IGRchar         * numb            Partnumber    |                  |
 |        IGRchar         * rev             Partrevision  |            or    |
 |        IGRchar         * filename        Name of the design file          |
 |                                                                           |
 +---------------------------------------------------------------------------*/

#omdef asm$get_directory_part (msg,
                        dir      = NULL,
                        filename,
			perm = NULL,
			numb = NULL,
			rev  = NULL,
			desc = NULL,
			index = -1)

       EMasc_get_part( (msg),
		     (dir),
		     (filename),
		     (perm),
		     (numb),
		     (rev),
		     (desc),
		     (index))

#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$update_ascii_file                                              |
 |                                                                           |
 | This macro updates the ASCII part data file, ie., removes entries with    |
 | status 'D' and also looks at the unix directory and if some parts listed  |
 | in the ascii file are not seen, will delete these entries also from the   |
 | ascii file.                                                               |
 |									     |
 | Input:                                                                    |
 |        IGRchar         * dir		    Directory of partdata ascii file.|
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |                                                                           |
 +---------------------------------------------------------------------------*/

#omdef asm$update_ascii_file (msg, 
			      dir = NULL )

       EMasc_update_file( (msg),
			  (dir) )

#endomdef

#endif /* filemacros_h */



