#ifndef exmacros_include
#define exmacros_include

#include "exdef.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "ex.h"

/*  PPL does not need prototypes  */

#ifdef __STDC__
#include "exproto.h"
#endif

#define check_error_status(stat,msg)\
           if(!(stat&1)) \
            { \
              if (stat != OM_W_ABORT) \
               { \
                 printf("%s\n",msg); \
                 om$report_error(sts = stat); \
               } \
            } 

/*----------------------------------------------------------------------------*/
/*  executive macros  */


/***********************************************************************/
/*       ex$file_form                                                  */
/***********************************************************************/
/*                                                                     */
/*      this macro will bring up a form and display directories        */
/*      and filenames associated with the current working directory    */
/*                                                                     */
/*      Sample call                                                    */
/*      ex$file_form ( title , startdir, file_name, pattern,           */
/*                       file_type, returned_filename, seedfile,       */
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
/*      char *returned_filename selected filename returned to user     */
/*      char *seedfile   used only by exec                             */
/*      int form_type   EX_STANDARD_FILE_FORM                          */
/*      int *response   response                                       */
/*      char *response_data response_data                              */


#omdef ex$file_form ( title,startdir = 0,file_name =0,
                         pattern = 0,file_types = 0,returned_filename,
                         seedfile = 0,
                         form_type = EX_STANDARD_FILE_FORM, 
                         response,response_data)

EXget_file(title,startdir,file_name,pattern,file_types,
                          returned_filename,seedfile,form_type,
                          response, response_data)
#endomdef

/*********************************************************************/
/*  ex$create_prompt will take a message number from message file    */
/*                   and put the left_prompt message number in $1,   */
/*                   right_promt message in $2, optional string      */
/*                   in $3 of original message, go out and get the   */
/*                   input, compare it to left or right prompt,      */
/*                   and return EX_LEFT_MATCH,EX_RIGHT_MATCH,        */
/*                   EX_NO_MATCH, or EX_INVALID_PROMPT (in exdef.h)  */

/* this macro was added for internationalization of messages         */

#omdef ex$create_prompt ( message_no, left_prompt, right_prompt,
                           string = NULL, response,response_data)
  EX_create_prompt((message_no),(left_prompt),(right_prompt),(string),
                   (response),(response_data))
#endomdef

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$add_fun	                                                */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/*   add function to the list						*/
/*									*/
/*  int  	(*fun)()  pointer to a function to be called in wfi	*/
/*									*/
/*   function will be called just before the return of wfi		*/
/*   function in end list will be called before functions in		*/
/*   the start list are called						*/
/*									*/
/*	mode    EX_START_FUNC EX_END_FUNC defined in exdef.h		*/
/*									*/
/*  Sample call:							*/
/*									*/
/*   status = ex$add_fun( fun = EX_start_fun, mode = EX_START_FUNC )	*/
/*									*/
/* Status Returns							*/
/*									*/
/* 1 - success								*/
/* 0 - failure  							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$add_function( fun , mode)
       EX_add_function( fun , mode)
#endomdef       

/* for internal use only */
#omdef ex$add_cmdserver_func( fun )
  EX_add_cmdserver_function( (fun) )
#endomdef  
#omdef ex$del_cmdserver_func( fun )
  EX_del_cmdserver_function( (fun) )
#endomdef  



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$add_name_to_NOD ( NODname  ^^ NODobjid, objname, 	*/
/*				    objid, mod_osnum )			*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/ 
/* This macro will add the name to the named object directory.		*/
/* Either NODname or NODobjid can be used to identify the Named Object	*/
/* Directory but for efficiency the use of NODname is recommended.	*/
/*									*/ 
/* IGRchar	*NODname	I	pointer to the name of the NOD	*/
/* OM_S_OBJID	NODobjid	I	object id of the NOD		*/
/* IGRchar	*objname	I	pointer to the name of the 	*/
/*					given object			*/ 
/* OM_S_OBJID	objid		I	object id of the given object	*/
/* OMuword	mod_osnum	I	object space number of module	*/
/*									*/
/* Sample Invocation							*/
/*									*/
/* sts = ex$add_name_to_NOD (    NODobjid = nod_objid,			*/
/*                             objname = "MYOBJ", objid = my_objid )    */
/*									*/
/* Status Returns							*/
/*									*/
/* OM_S_SUCCESS - success						*/
/* om error code - fail							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


#omdef ex$add_name_to_NOD ( NODname="" ^ NODobjid=NULL_OBJID, 
                               objname, objid, mod_osnum=OM_Gw_current_OS)

#if om$specified( NODname) 
   EX_add_name_nodname( (NODname), objname, objid , mod_osnum)
#else
   EX_add_name_nodid ( (NODobjid), objname, objid , mod_osnum)
#endif

#endomdef

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* ex$add_win_to_exec ( win_num, objid, osnum )				*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro connects a window object to the exec's absolutely ordered */
/* hw_win channel.							*/
/*									*/
/* int		win_num         I	Environ V window number		*/
/* OM_S_OBJID   objid           I	Object id of window		*/ 
/* OMuword	osnum		I	OS number of the window		*/
/*									*/
/* Sample Invocation							*/
/*									*/ 
/* sts = ex$add_win_to_exec(win_num = win_no,objid = oid,osnum = osn)	*/
/*									*/
/* Status Returns							*/
/*									*/
/* 1  - success								*/
/* 0  - fail								*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$add_win_to_exec ( win_num,    objid,    osnum )

    EX_add_win ( (win_num), (objid), (osnum) )

#endomdef

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$attach_input_generator (objid, osnum ) 			*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro will add an input generator to the to_generator channel of*/
/* the exec object at position 0.					*/
/*									*/
/* OM_S_OBJID   objid		I	object id of input generator    */
/* OMuword	osnum		I	object space number of the 	*/
/*					input generator			*/
/*									*/
/* Sample Invocation							*/
/*									*/ 
/* sts = ex$attach_input_generator (   objid = ingen_id,		*/
/* 				       osnum = ingen_osnum)		*/
/* Status Returns							*/
/*									*/ 
/* OM_S_SUCCESS - success						*/
/* om error code - fail							*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$attach_input_generator ( objid , osnum )

    EX_attach_generator (  (objid), (osnum) )

#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$attach_input_listener (objid, osnum ) 			*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro will add an input listener to the to_listener channel of  */
/* the exec object at position 0.					*/
/*									*/
/* OM_S_OBJID   objid		I	object id of input listener     */
/* OMuword	osnum		I	object space number of the 	*/
/*					input listener			*/
/*									*/
/* Sample Invocation							*/
/*									*/ 
/* sts = ex$attach_input_listener (    objid = inlisn_id,		*/
/* 				       osnum = inlisn_osnum)		*/
/* Status Returns							*/
/*									*/ 
/* OM_S_SUCCESS - success						*/
/* om error code - fail							*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$attach_input_listener ( objid , osnum )

    EX_attach_listener (  (objid), (osnum) )

#endomdef

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$attach_super (   super_class, super_id, modid = 0,	*/
/*				mod_osnum = OM_Gw_current_OS )		*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* int		win_num         I	Environ V window number		*/
/* This macro will construct an object of the given class, connect the  */
/* object to the super channel of the given module object, and return   */
/* the object id of the constructed object in super_id.			*/
/*									*/ 
/* IGRchar	*super_class	I	pointer to super class name	*/
/* OM_S_OBJID   *super_id	O	pointer to object id of the	*/
/* 					object to be constructed	*/
/* OM_S_OBJID	modid		I	module object id		*/
/* OMuword	mod_osnum	I	module object space number	*/
/* int      wakeup_flag I   flag by default to send wakup to newly      */
/*                         constructed super, set to 0 to send no wakeup*/
/*									*/
/* Sample Invocation							*/
/*									*/
/* sts = ex$attach_super (   super_class = "mysuper",			*/
/*				super_id = &sup_id )			*/
/*									*/
/* Status Returns							*/
/*									*/
/* OM_S_SUCCESS - success						*/
/* om error code - fail							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$attach_super ( super_class,
                         super_id,
                         modid = 0,
                         mod_osnum = OM_Gw_current_OS,
                         wakeup_flag = 1 )

    EX_attach_super ( (super_class), (super_id), (modid),
                                  (mod_osnum),(wakeup_flag) )
#endomdef

 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$clear_abs_dig ()						*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro will delete an absolute digitizer area. 			*/
/*									*/
/* Sample Invocation							*/
/*									*/ 
/* sts = ex$clear_abs_dig()						*/
/*									*/ 
/* Status Returns							*/
/*									*/
/* OM_S_SUCCESS - success						*/
/* om error code - fail							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$clear_abs_dig (  )

    EX_clear_abs_dig ( )

#endomdef

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$clear_event_queue ( )					*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro will clear the software event queue.			*/
/*									*/
/* Sample Invocation							*/
/*									*/ 
/* sts = ex$clear_event_queue ( );					*/
/*									*/
/* Status Returns							*/
/*									*/
/* 1  success								*/
/* 0 failure								*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$clear_event_queue()
       EX_flush_event_queue()
#endomdef       

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$close_module( ftype = 0, flag, index ^  last )		*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro closes a module.						*/
/*									*/
/* int		status		O	Return status:			*/
/*							1 - success     */
/*							0 - failure 	*/
/* int		ftype		I       type of file:			*/
/*					 0  EX_invisible  		*/
/*					 1  EX_visible	  (in exdef.h)	*/
/*									*/
/* int		flag		I	Indicates whether you want to	*/
/*					write the object space out to	*/
/*					disk.    0 - do not write	*/
/*						 1 - write		*/
/*									*/
/* int		index		I	Index into the global array 	*/
/*					invisible_table returned from	*/
/*					ex$retrieve_module		*/
/*									*/
/* int		last		O       This argument should only be    */
/*					used when ftype = EX_visible.	*/
/*					If last equals 1 , the file is  */
/*					the last master file. You should*/
/*					retrieve a new one or exit.     */
/*									*/
/* sample Invocation							*/
/*									*/
/* for visible module ( master file )					*/
/*									*/
/*  sts = ex$close_module( ftype = EX_visible, flag = 1, last = &last); */
/*									*/
/* for invisible module 						*/
/*									*/
/*  sts = ex$close_module ( ftype = EX_invisible, index=file_no )	*/
/*									*/
/* Status Returns							*/
/*									*/
/* OM_S_SUCCESS - success						*/
/* om error code - fail							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
#omdef ex$close_module( ftype = 0, flag = 0, index ^  last )	

#if om$equal(ftype, EX_visible )  /* 1 */
#   if 	om$specified (last)
         EX_close1( (last), (flag) )
#   else	         
#       omerror "arg last not specified"
#   endif

#elif om$equal(ftype, EX_invisible )  /* 0 */
#   if 	om$specified (index)
         Close_OS( (index), (flag) )
#   else	         
#       omerror "arg index not specified"
#   endif

#else
#   omerror "type specified is wrong"
#endif
#endomdef



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$del_fun 		                                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/*   del function in the  list						*/
/*									*/
/*  int  	(*fun)()  pointer to a function to be called		*/
/*                        before return from wfi                        */
/*   function will be called just before the return of wfi.		*/
/*   function in end list will be called before functions in		*/
/*   the start list are called						*/
/*									*/
/*	mode    EX_START_FUNC EX_END_FUNC defined in exdef.h		*/
/*									*/
/*  Sample Invocation:							*/
/*									*/
/*   status = ex$del_fun( fun = EX_end_fun, mode = EX_END_FUNC );	*/
/*									*/
/* Status Returns							*/
/*									*/
/* 1 - success								*/
/* 0 - failure  							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$del_function( fun , mode)
       EX_del_function( fun , mode)
#endomdef       


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$detach_input_generator (objid, osnum ) 			*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro will remove an input generator to the to_generator channel*/
/* of the exec object. The input generator object is not deleted.	*/
/*									*/
/* OM_S_OBJID   objid		I	object id of input generator    */
/* OMuword	osnum		I	object space number of the 	*/
/*					input generator			*/
/*									*/
/* Sample Invocation							*/
/*									*/ 
/* sts = ex$detach_input_generator (   objid = ingen_id,		*/
/* 				       osnum = ingen_osnum)		*/
/* Status Returns							*/
/*									*/ 
/* OM_S_SUCCESS - success						*/
/* om error code - fail							*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$detach_input_generator ( objid , osnum  )

    EX_detach_generator ( (objid) , (osnum) )

#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$detach_input_listener (objid, osnum ) 			*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro will remove an input listener to the to_listener channel  */
/* of the exec object. The input listener object is not deleted.	*/
/*									*/
/* OM_S_OBJID   objid		I	object id of input listener     */
/* OMuword	osnum		I	object space number of the 	*/
/*					input listener			*/
/*									*/
/* Sample Invocation							*/
/*									*/ 
/* sts = ex$detach_input_listener (    objid = inlisn_id,		*/
/* 				       osnum = inlisn_osnum)		*/
/* Status Returns							*/
/*									*/ 
/* OM_S_SUCCESS - success						*/
/* om error code - fail							*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$detach_input_listener ( objid , osnum  )

    EX_detach_listener ( (objid) , (osnum) )

#endomdef

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$disp_flag( mode, flag )                                      	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                               	*/
/*  This macro will return/set the disp quiet flag. if disp quiet flag 	*/
/*  equals to 1 , no display will be draw on the screen.		*/
/*									*/
/* int		mode		I	EX_INQ or EX_SET defined in 	*/
/*					exdef.h				*/
/* int		*flag		I/O	disp quiet flag			*/
/*									*/
/* Sample Invocation:							*/
/*									*/
/*      status = ex$disp_flag( mode = EX_INQ, flag = & hflag)         	*/
/*                                                               	*/
/* Status Returns							*/
/*									*/
/* 1 - success								*/
/* 0 - failure  							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
#omdef  ex$disp_flag( mode = EX_INQ, flag)
        EX_disp_flag(  mode, flag)
#endomdef       

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$disp_on	                                         	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                               	*/
/*  This macro will set disp quiet mode to false ( disp on ) and	*/
/*  return the old flag setting.					*/
/*  	                                                         	*/
/* int		*hflag		O	old dispflag			*/
/*									*/
/* Sample Invocation:							*/
/*									*/
/*      status = ex$disp_on( oldflag = & hflag)    		       	*/
/*                                                               	*/
/* Status Returns							*/
/*                                                               	*/
/*      return   1 success						*/
/*		 0 otherwise						*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef  ex$disp_on( oldflag )
        EX_disp_on( oldflag)
#endomdef       


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$disp_off	                                         	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                               	*/
/*  This macro will set disp quiet mode to true ( disp off ) and	*/
/*  return the old flag setting.					*/
/*  	                                                         	*/
/* int		*hflag		O	old dispflag			*/
/*									*/
/* Sample Invocation:							*/
/*									*/
/*      status = ex$disp_off( oldflag = & hflag)    		       	*/
/*                                                               	*/
/* Status Returns							*/
/*                                                               	*/
/*      return   1 success						*/
/*		 0 otherwise						*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef  ex$disp_off( oldflag )
        EX_disp_off( oldflag)
#endomdef       



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$exit( save )	   	                           	        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*								 	*/
/*  This macro will exit the whole design session.	            	*/
/*								 	*/
/* int		save		O	if save = 1  save all visible  	*/
/*					             modules 	  	*/
/*					        = 0  do not save them  	*/
/* Sample Invocation:							*/
/*								 	*/
/*      status = ex$exit( save=save_flag);				*/
/*				 				 	*/
/* Status Returns							*/
/*									*/
/* 	return   1    success					 	*/
/*		 0    fail				 	 	*/
/*									*/
/*  note: This macro will save only visible files. If you opened 	*/
/*        an invisible file or you just want to save some of the 	*/
/*        file, you must use ex$close to save each individual file    	*/
/*        and then call ex$exit with save_flag set to 0 .        	*/
/*								 	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
#omdef ex$exit( save )
       EX_exit1( save )
#endomdef       


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$filename                              	         	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*								 	*/
/*  This macro will return the name of the current active file		*/
/*								 	*/
/* char		*name		O	file name			*/
/* int		len 		I	size of above char array	*/
/*									*/
/* Sample Invocation:						 	*/
/*								 	*/
/*      char result[OM_K_MAXOSNAME_LEN];			 	*/
/*      status = ex$filename( name= result, 			 	*/
/*		               len= OM_K_MAXOSNAME_LEN]);		*/
/*				 					*/
/* Status Returns							*/
/*								 	*/
/* 	return   1    success					 	*/
/*		 0    size given is too small /fail	 	 	*/
/*								 	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
#omdef ex$filename( name, len )
       EX_filename1( name, len )
#endomdef       

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* ex$file_status ( modid, modos, mode )				*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro finds out the state of an OMFiledOS. If mode = 0, the file*/
/* is writable.  If mode = 1, the file is not writable.  This macro 	*/
/* should only be called in the superclass sleep method to find out	*/
/* whether the user wants to save the module or not.			*/
/*									*/
/* OM_S_OBJID	modid		I	Module id			*/
/* OMuword	modos		I	Module object space number	*/
/* int		mode		O	Mode of the file		*/
/*									*/
/* Sample Invocation							*/
/*									*/
/* sts = ex$file_status ( modid = mid, modos = mos, mode = &mode );	*/
/*									*/
/* Status Returns							*/
/*									*/
/* 0 fail								*/
/* 1 success								*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$file_status (modid,  modos,  mode)

      EX_file_status ( (modid), (modos), (mode) )
      
#endomdef




/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$fork( num_entry, argu, wait_flag = 0, redir_io = 0,	*/
/*                         childpid = 0, mask= -1 ,np1 =0, np2 =0	*/
/*			   delete_flag ) 				*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro will send a message to the "driver process" to create	*/
/* subprocesses.							*/
/*									*/
/* int		win_num         I	Environ V window number		*/
/* int		num_entry	I	Number of entries in argu	*/
/* char		*argu[]		I	array of pointers to argument	*/
/* int		wait_flag	I 	wait for the process		*/
/*					wait_flag will be ignored if	*/
/*					redir_io is specified		*/
/* int		redir_io	I	redirect of standard input/	*/
/*					output to use named pipe	*/
/*					redir_io=0 - do not redirect io */
/*					redir_io=  REDIR_INPUT -	*/
/*					(defined in exdef.h) redirect	*/
/*					standard input of child process */
/*					to use named pipe NP1 as input	*/
/*					stream				*/
/*					redir_io=  REDIR_OUTPUT -	*/
/*					redirect standard output of	*/
/*					child process to use named pipe */
/*					NP2 as output stream		*/
/*                                      redir_io = CREATE_PIPE          */
/*                                      driver will create named pipe   */
/*                                      using the string in np1 and np2 */
/* char        *np1, *np2		where np1 and np2 should contain*/
/*					the string  MYNP=/usr/tmp/mypipe*/
/*                                      MYNP is the environment variable*/
/*					you chose. The size of np1, np2 */
/*					string is limited to 80 chars   */
/*									*/
/* int		*childpid	O	Pointer to memory location where*/
/*					you want to get child process id*/
/*									*/
/*                                      If you specified wait_flag = 1 ,*/
/*					usually there is no need to get */
/*					child process id back because 	*/
/*					ex$fork will return only when 	*/
/*					child process is terminated.	*/
/*									*/
/*					If wait_flag = 1, the status 	*/
/*					returned will be the same as if */
/*					you use the "wait" system call. */
/*									*/
/* int         mask             I       default value is -1             */
/*                                      If mask was set , EXEC will set */
/*					the child process's umask value */
/*                                      to mask. 			*/
/* int         delete_flag      I       if delete_flag equals false (0) */
/*                                      the child process will not be   */
/*                                      deleted upon the exit of the    */
/*					application image. 		*/
/* Sample Invocation							*/
/*									*/
/* sts = ex$fork ( num_entry = num, argu = my_argu );			*/
/*									*/
/* Status Returns							*/
/*									*/
/* 0 - failure								*/
/* 1 - success								*/
/* if wait_flag = 1, then the information returned from the wait system */
/* call will be returned						*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$fork ( num_entry,
                   argu,
                 wait_flag = 0,
                 redir_io = 0,
                 childpid = 0 ,
		 mask = -1,
		 np1 = 0,
		 np2 = 0,
		 delete_flag = 1 )

    EX_fork  ( (num_entry), (argu), (wait_flag), (redir_io), (childpid) ,(mask), (np1), (np2), (delete_flag) )
    
#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$get_cmd_info		                                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/*     Given command key or command string, This macro will return	*/
/*     the information about a command requested.			*/
/*									*/
/* char		*string		I	pointer to character string	*/
/* int		mode		I       mode  EX_STRING or EX_CMD_KEY,	*/
/*					defined in exdef.h, identifies  */
/*					what string represents.		*/
/* struct EX_cmd *cmdstr	O       pointer to structure of command */
/*									*/
/*  Sample Invocation:							*/
/*									*/
/*	struct EX_cmd my_cmd;	(this structure is defined in ex.h)	*/
/*									*/
/*   status = ex$get_cmd_info( string = "pl line seg", mode = EX_STRING,*/
/*                             cmdstr = &my_cmd )			*/
/*									*/
/*   status = ex$get_cmd_info( string = "EXVer", mode = EX_CMD_KEY,     */
/*                             cmdstr = &my_cmd )			*/
/*									*/
/* Status Returns							*/
/*									*/
/* 1 - success								*/
/* 0 - failure  							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef ex$get_cmd_info( string, mode, cmdstr=NULL)
  EX_get_cmd_info( string, mode, cmdstr)
#endomdef       

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$get_cur_mod ( id, osnum )				*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro returns the module object id and object space number for	*/
/* the current (active) module.						*/
/*									*/
/* int		status		O	Return status:			*/
/*						  1 - success		*/
/*						  0 - failure		*/
/* OM_S_OBJID	*id		O	pointer to object id of the	*/
/*					current module			*/
/* OMuword	*osnum		O	pointer to object space number	*/
/*					for the current module		*/
/*									*/
/* Sample Invocation							*/
/*									*/
/* sts = ex$get_cur_mod ( id=&mod_id, osnum=&mod_osnum )		*/
/*									*/
/* Status Returns							*/
/*									*/
/* 1  - success								*/
/* 0  - fail								*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$get_cur_mod ( id = NULL, osnum = NULL )

    EX_findmod( (id), (osnum) )

#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$get_exec_id  							*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/*  This macro will return the object id of exec object			*/
/*  									*/
/* OM_S_OBJID	*id		O	pointer to object id of the exec*/
/* OMuword	*osnum		O	pointer to object space number	*/
/*					for the exec(should always be 1)*/
/*									*/
/* Sample Invocation							*/
/*									*/
/* sts = ex$get_exec_id ( id=&exec_id, osnum=&exec_osnum )		*/
/*									*/
/* Status Returns							*/
/*									*/
/* 1  - success								*/
/* 0  - fail								*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef ex$get_exec_id ( id = NULL, osnum = NULL )

    EX_get_exec_id( (id), (osnum) )

#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  status = ex$get_invis_info_by_index ( index,  mod_osnum = NULL,	*/
/*				mod_id = NULL,    filed_id = NULL,	*/
/*				 flag = NULL,  num_open = NULL )	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* 									*/
/* This macro will retrieve information concerning an invisible  	*/
/* module.								*/
/*									*/
/* int		index		I	Entry # of invisible table	*/
/*					(file_no you get back from	*/
/*					ex$retrieve_module.)		*/
/* OMuword	*mod_osnum	O	Pointer to module object space	*/
/*					number.				*/
/* OM_S_OBJID	*mod_id		O 	Pointer to module object id.	*/
/* OM_S_OBJID	*filed_id	O	Pointer to the object id of	*/
/*					OMFiledOS that contains the	*/
/*					module object.			*/
/* int		*flag		O	Pointer to the permission flag. */
/* int		*num_open	O	Pointer to the num of opens.	*/
/*									*/
/* Sample Invocation							*/
/*									*/
/* status = ex$get_invis_info_by_index ( index = 5, mod_osnum = &os_num,*/
/*				modid = &mod_id,filed_id = &filed)	*/
/*									*/
/* Status Returns							*/
/*									*/
/* 1 = success								*/
/* 0 = failure 								*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$get_invis_info_by_index(  index,
                                 mod_osnum = NULL,
                                    mod_id = NULL,
				  filed_id = NULL,
				      flag = NULL, 
				  num_open = NULL,
                                  mod_type = NULL ) 
 EX_get_invis_info_by_index( (index), (mod_osnum),(mod_id),(filed_id),
                                (flag), (num_open), (mod_type) )
 
#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  status = ex$get_modid ( mod_osnum, mod_id )				*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/*   Given a module object space number, this macro will return the     */
/*   module object id in that object space. 				*/
/*									*/
/* Omuword	osnum		I	Module object space number	*/
/* OM_S_OBJID	*mod_id		O	Module object id		*/
/*									*/
/* Sample Invocation							*/
/*									*/
/* status = ex$get_modid ( osnum = mod_osnum, mod_id = &mod );		*/
/*									*/
/* Status Returns							*/
/*									*/
/* 1 for success							*/
/* 0 for failure							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$get_modid( mod_osnum, mod_id )
       EX_get_modid_given_osnum( mod_osnum, mod_id )
#endomdef       

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$get_NOD (  NODname, pobjid, create, modid, mod_osnum )	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro will return the objid of the Named Object Directory	*/
/* specified by NODname.  If create = TRUE, it will create the NOD	*/
/* if it does not already exist, else it will return an error status.	*/
/* If modid and mod_osnum is specified it will look for NOD in the	*/
/* specified module space, else in the default module space.		*/
/*									*/ 
/* IGRchar	*NODname	I	pointer to the name of the Named*/
/*					Object Directory		*/
/* OM_S_OBJID	*pobjid		O	pointer to the objid of NOD	*/
/* OM_S_OBJID	modid		I	module object id or objid of 	*/
/*					some subclass of OMFiledOS	*/
/* OMuword	mod_osnum	I	object space number of module	*/
/*									*/
/* Sample Invocation							*/
/*									*/
/*     sts = ex$get_NOD ( NODname = "IGENOD",pobjid = &myobjid )	*/
/*									*/
/* Status Returns							*/
/*									*/ 
/*   OM_S_SUCCESS - success						*/
/*   om error code - fail						*/
/*									*/ 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$get_NOD ( NODname, pobjid , create=NULL, modid=NULL_OBJID, 
                          mod_osnum=OM_Gw_current_OS )

    EX_get_NOD ( (NODname), (pobjid ) , (create),(modid) ,(mod_osnum) )

#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$get_objid_from_NOD ( NODname  ^^ NODobjid, objname, 	*/
/*				    pobjid, modid, mod_osnum )		*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/ 
/* This macro will translate the object name and return the object ID	*/
/* (pobjid) of the named object specified by objname.  Either NODname or*/
/* NODobjid can be used to identify the Named Object Directory but for	*/
/* efficiency the use of NODname is recommended.			*/
/*									*/ 
/* IGRchar	*NODname	I	pointer to the name of the NOD	*/
/* OM_S_OBJID	NODobjid	I	object id of the NOD		*/
/* IGRchar	*objname	I	pointer to the name of the 	*/
/*					given object			*/ 
/* OM_S_OBJID	*pobjid		O	pointer to the object id of the	*/
/*					given object			*/
/* OM_S_OBJID	modid		I	module object id or objid of 	*/
/*					some subclass of OMFiledOS	*/
/* OMuword	mod_osnum	I	object space number of module	*/
/*									*/
/* Sample Invocation							*/
/*									*/
/* sts = ex$get_objid_from_NOD (    NODobjid = nod_objid,		*/
/*                             objname = "MYOBJ", pobjid = &my_objid )  */
/*									*/
/* Status Returns							*/
/*									*/
/* OM_S_SUCCESS - success						*/
/* om error code - fail							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$get_objid_from_NOD ( NODname="" ^ NODobjid=NULL_OBJID, 
                               objname, pobjid, modid=NULL_OBJID, 
                               mod_osnum=OM_Gw_current_OS, dummy=NULL)

#if om$specified( NODname) 
   EX_get_oid_nodname( (NODname), objname, pobjid ,modid, mod_osnum, dummy)
#else
   EX_get_oid_nodid ( (NODobjid), objname, pobjid ,modid, mod_osnum)
#endif

#endomdef

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$get_path ( index, path, len, type )			*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/*  This macro will return the search path.				*/
/*									*/
/* int		index		O	0 for first path, 1 for second 	*/
/*					path, etc.			*/
/* char		*path		O	Pointer to character array	*/
/* int		len		I	Size of the path array		*/
/* int		type		I       type of path			*/
/*					EX_CONFIG_PATH  (default)	*/
/*					EX_PRODUCT_PATH			*/
/* ( In a distrubuted environment, the config directory may reside on   */
/*   different machine and mounted through NFS.)			*/
/*									*/
/* Sample Invocation							*/
/*									*/
/* 1)  char file_name [80];						*/
/*     status = ex$get_path ( index = 0, path = file_name, len =	*/
/*						    sizeof(file_name);  */
/* 2)  detailed exmaple see DNUC052 IGEDP Programmer's Reference Manual */ 
/*									*/
/* Status Returns							*/
/*									*/
/* 1 for success							*/
/* 0 for failure							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$get_path( index, path, len , type = 0)
       EX_getpath( index, path, len , type )
#endomdef       


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$get_super ( mod_id, mod_osnum, super_name, create,	*/
/*			   super_class, super_id, super_osnum  )	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/ 
/* This macro will get the object id and object space number for the	*/
/* requested super from the default named object directory IGENOD.  If	*/
/* the super does not exist and create flag is TRUE, the Super is 	*/
/* created using super_classname, and global_class place method and     */
/* wake_up message will be sent to the newly created super by default.  */
/* However if wakeup_flag is set to 0, no wakeup will be sent.          */
/*									*/
/* OM_S_OBJID	mod_id		I	Module id			*/ 
/* OMuword	mod_osnum	I	Module OS number		*/
/* IGRchar	*super_name	O	Name for your super		*/
/* IGRint	create		I	Create super if not there	*/
/* IGRchar	*super_classname I      Classname for your super	*/
/* OM_S_OBJID	*super_id	O	objid for super			*/
/* OMuword	*super_osnum    O	osnum for super ( super_osnum 	*/
/*					will be the same as mod_osnum )	*/
/* int      wakeup_flag I   flag by default to send wakup to newly      */
/*                         constructed super, set to 0 to send no wakeup*/
/*									*/
/* Sample Invocation							*/
/*									*/
/* status = ex$get_super ( mod_id = mid, mod_osnum = mos,		*/
/*                         super_name = "XX", create = 1,		*/
/*                         super_class=&class, super_id = &sid,		*/
/*                         super_osnum=&sos );				*/
 /*									*/ 
/* Status Returns							*/
/*									*/ 
/* OM_S_SUCCESS - success						*/
/* om error code - fail							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$get_super( mod_id, mod_osnum, super_name ,
             create = NULL, super_class = NULL, super_id, super_osnum = NULL,
             wakeup_flag = 1)

#if om$specified(create) && !om$equal(create , 0 ) && om$equal(super_class,0)
#omerror "No super class name provided"
#else
   EX_get_super( (mod_id),(mod_osnum),(super_name),(create),
                         (super_class),(super_id),(super_osnum),(wakeup_flag))
#endif
#endomdef

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$getque ( msg, response, byte, buffer )			*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* All input to a command object comes from the software input queue	*/
/* through an input filter.  The software input queue (often referred to*/
/* as just the software queue) contains data events which are put there */
/* either by WFI or other Command objects.  It is maintained by the	*/
/* Executive - Misc. Subsystem.  It is a 1024 bytes buffer which 	*/
/* contains the operator and Command generated responses.		*/
/* ex$getque gets events from the front of the software queue.  One can */
/* only get event structure from the front of the queue.		*/
/*									*/
/* long		*msg		O	pointer to the specific return	*/
/*					status - These values are	*/
/*					defined in  exdef.h		*/
/*					EXs_success -operation succeeded*/
/*					EXe_no_mem - no memory		*/
/*					EXe_inv_nbytes - bad byte count */
/* long		*response	O	pointer to the response type 	*/
/*					generated by event - defined in */
/*					the file exdef.h		*/
/* int		*byte		I/O	pointer to the buffer size in 	*/
/*					bytes, on entry  sizeof buffer  */
/*					on exit  # bytes returned	*/
/* event dependent  *buffer     O	pointer to the buffer containing*/
/*					event data -  defined in ex.h   */
/*									*/
/* Sample Invocation							*/
/*									*/ 
/* To get event in front of queue:					*/
/*  sts = ex$getque (msg=&msg, response=resp, byte=&bufsiz,buffer=buf ) */
/*									*/
/* Status Returns							*/
/*									*/ 
/* EXs_success      -  success = 1					*/
/* EXw_ev_trunc     -  event longer than size of buffer is truncated	*/
/* 0                -  failure						*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef ex$getque ( msg, response, byte,  buffer )

    EXgetq( (msg), (response), (byte), (buffer) ) 

#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$global ( mode = EX_INQ, var,  which_error )		*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/ 
/*									*/
/* This macro will retrieve or set some executive global variables such */
/* as filename, working directory, and support directory.		*/
/*									*/
/* int		mode		I	as defined in exdef.h,		*/
/*					  EX_INQ - for inquire		*/
/*					  EX_SET - for set		*/
/* struct EX_var_list   *var	O	as defined in ex.h, a pointer	*/
/*					to a structure for global	*/
/*					variables referenced.		*/
/* int		*which_error	O	Integer symbol as defined in	*/
/*					exdef.h. Returns the position	*/
/*					in EX_var_list that failed:	*/
/*									*/
/*					EX_CUR_FILENAME - current master*/
/*					file name (no directory path)	*/
/*					EX_WORKING_DIR - directory where*/
/*					saved file is located		*/
/*									*/
/*					EX_SUPPORT_DIR - directory where*/
/*					the appliction product is 	*/
/*					located.  ( /usrx/ingr )	*/
/*									*/
/* Sample Invocation							*/
/*									*/
/*     struct EX_var_list ex_var[2];					*/
/*     IGRint var_size, bad_var;					*/
/*     IGRchar *ffend path[128];					*/
/*									*/ 
/*     var_size = sizeof(path);						*/
/*     ex_var[0].var = EX_WORKING_DIR;					*/
/*     ex_var[0].var_value = path;					*/
/*     ex_var[0].num_bytes = &var_size;					*/
/*									*/ 
/*     ex_var[1].var = NULL;						*/
/* 									*/
/*     status = ex$global ( mode = EX_INQ, var = &ex_var[0],		*/
/*                            which_error = &bad_var );			*/
/*									*/
/* Status Returns							*/
/*									*/ 
/* 1  - success								*/
/* 0  - fail								*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef ex$global (mode = EX_INQ, var,  which_error)

      EX_get_global ( (mode), (var), (which_error) )

#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$help_flag( mode, flag )                                      	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                               	*/
/*  This macro will return/set the help quiet flag. if help quiet flag 	*/
/*  equals to 1 , help is not active.					*/
/*									*/
/* int		mode		I	EX_INQ or EX_SET defined in 	*/
/*					exdef.h				*/
/* int		*flag		I/O	hlep quiet flag			*/
/*									*/
/* Sample Invocation:							*/
/*									*/
/*      status = ex$help_flag( mode = EX_INQ, flag = & hflag)         	*/
/*                                                               	*/
/* Status Returns							*/
/*									*/
/* 1 - success								*/
/* 0 - failure  							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
#omdef  ex$help_flag( mode = EX_INQ, flag)
        EX_help_flag(  mode, flag)
#endomdef       




/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$help_init( ) 		                                     	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                               	*/
/*  This macro will initialize help process			 	*/
/*  This macro should be called only once to initialize help process    */
/*									*/
/* Sample Invocation:							*/
/*									*/
/*      status = ex$help_init( )			         	*/
/*                                                               	*/
/* Status Returns							*/
/*									*/
/* 1 - success								*/
/* 0 - failure  							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
#omdef  ex$help_init( )
        EX_help_init( )
#endomdef       

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$help_on	                                         	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                               	*/
/*  This macro will set help quiet mode to false ( help on ) and	*/
/*  return the old flag setting.					*/
/*  	                                                         	*/
/* int		*hflag		O	old helpflag			*/
/*									*/
/* Sample Invocation:							*/
/*									*/
/*      status = ex$help_on( oldflag = & hflag)    		       	*/
/*                                                               	*/
/* Status Returns							*/
/*                                                               	*/
/*      return   1 success						*/
/*		 0 otherwise						*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef  ex$help_on( oldflag )
        EX_help_on( oldflag)
#endomdef       


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$help_off	                                         	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                               	*/
/*  This macro will set help quiet mode to true ( help off ) and	*/
/*  return the old flag setting.					*/
/*  	                                                         	*/
/* int		*hflag		O	old helpflag			*/
/*									*/
/* Sample Invocation:							*/
/*									*/
/*      status = ex$help_off( oldflag = & hflag)    		       	*/
/*                                                               	*/
/* Status Returns							*/
/*                                                               	*/
/*      return   1 success						*/
/*		 0 otherwise						*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef  ex$help_off( oldflag )
        EX_help_off( oldflag)
#endomdef       


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$is_batch                              	         	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*								 	*/
/* This macro will find out whether the process is interactive or	*/
/* batch mode.								*/
/*								 	*/
/* Sample Invocation:						 	*/
/*								 	*/
/*      if (  ex$is_batche() )					 	*/
/*	{    ......		}				 	*/
/*				 				 	*/
/* Status Returns							*/
/*								 	*/
/* 	return   1    for batch mode				 	*/
/*		 0    for batch mode			 	 	*/
/*								 	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef ex$is_batch()
       EX_is_batch()
#endomdef       




/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$is_cmd_stack_empty                           	         	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*								 	*/
/* This macro will find out whether the command stack is empty or not   */

/*								 	*/
/* Sample Invocation:						 	*/
/*								 	*/
/*      if (  ex$is_cmd_stack_empty() )				 	*/
/*	{    ......		}				 	*/
/*				 				 	*/
/* Status Returns							*/
/*								 	*/
/* 	return   1    for cmd stack empty			 	*/
/*		 0    for some command on the stack	 	 	*/
/*								 	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef ex$is_cmd_stack_empty()
       EX_is_cmd_stack_empty()
#endomdef       

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  status = ex$is_driver_exist()					*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/ 
/*									*/
/* This macro returns 1 if the application was initiated by the driver, */
/*  0  otherwise.							*/
/*									*/
/* Sample Invocation							*/
/*									*/
/*  if (ex$is_driver_exist() ) 						*/
/*  {									*/
/*      status = ex$fork(num_entry = num_entry,argu = argu,		*/
/*                     wait_flag = wait_flag, redir_io );		*/
/*      if ( (redir_io & REDIR_OUTPUT) == REDIR_OUTPUT )		*/
/*      {								*/
/*           pp = getenv("NAMEDPIPE2");					*/
/*      }								*/
/*		   .							*/
/*		   .							*/
/*		   .							*/
/*  }									*/
/*  else  driver process not ther, use system fork 			*/
/*  {									*/
/*		   .							*/
/*		   .							*/
/*	status = ex$fork (.....);					*/
/* 		   .							*/
/*		   .							*/
/*  }									*/
/*									*/
/* Status Returns							*/
/*									*/
/* 1  if driver exists							*/
/* 0  otherwise								*/
/*									*/ 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/ 
#omdef ex$is_driver_exist()
       EX_is_driver_exist()
#endomdef       

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$is_file_open	                                         	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                               	*/
/*  This macro will return success if the object space specified by	*/
/*  filename was open.							*/
/*  	                                                          	*/
/* char 	*filename	I	file name			*/
/*									*/
/* Sample Invocation:							*/
/*									*/
/*      status = ex$is_file_open( name = filename )	         	*/
/*                                                               	*/
/* Status Returns							*/
/*                                                               	*/
/*      return   1 success	( file was open )			*/
/*		 0 otherwise						*/
/*                                                               	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef  ex$is_file_open( name )
        EX_is_file_open( name )
#endomdef       



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$is_help_active                                         	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                               	*/
/*  This macro will return the status of help				*/
/*									*/
/*  Sample Invocation:                                                	*/
/*									*/
/*      if( ex$is_help_active())    ......                       	*/
/*                                                               	*/
/*  Status Returns							*/
/*									*/
/*   1 if help window displayed and not in help quiet mode  		*/
/*   0 otherwise							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
#omdef  ex$is_help_active()
        EX_is_help_active( )
#endomdef       



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$is_interactive                                         	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*								 	*/
/* This macro will find out whether the process is interactive or	*/
/* batch mode.								*/
/*								 	*/
/* Sample Invocation:						 	*/
/*								 	*/
/*      if (  ex$is_interactive() )				 	*/
/*	{    ......		}				 	*/
/*				 				 	*/
/* Status Returns							*/
/*								 	*/
/* 	return   1    for interactive mode			 	*/
/*		 0    for batch mode			 	 	*/
/*								 	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
#omdef ex$is_interactive()
       EX_is_interactive()
#endomdef       

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/ 
/* status = ex$is_invis  ( mod_osnum, index = NULL )			*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/ 
/*									*/ 
/* Given the module object space number, this macro will return 1 if the*/
/* object space number is in the table defined by EXEC and is  called   */
/* invisible_table, 0 otherwise.					*/
/* If index was specified, the entry number of the invisible table will */
/* be returned.								*/
/*									*/
/* OMuword	mod_osnum	I	Module object space number	*/
/* int		*index		O	Pointer to index		*/
/* 									*/
/* Sample Invocation							*/
/*									*/
/* status = ex$is_invis ( mod_osnum = myosnum,   index = &entry_num) 	*/
/*									*/
/* Status Returns							*/
/*									*/
/* 1  object space number is in invisible table ( means this file is a  */
/*    reference or cell library)					*/
/* 0  otherwise								*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/ 
#omdef  ex$is_invis( mod_osnum , index = NULL )
        EX_is_invis( (mod_osnum), (index) )
#endomdef       


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$is_temp_wakeup	                                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro should only be called in global_class(super) wakeup method*/
/* to find out where this wakeup method is  a temp wakeup. (wakeup right*/
/* after temp sleep)						        */
/*								 	*/
/* Sample Invocation:						 	*/
/*								 	*/
/*      if ( ! ex$is_temp_wakeup() )				 	*/
/*	{    ...... 		}				 	*/
/*									*/
/* Status Returns							*/
/*                                                               	*/
/*      return   1 success	( this is a temp wakeup )		*/
/*		 0 otherwise						*/
/*                                                               	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$is_temp_wakeup()
       EX_is_temp_wakeup()
#endomdef       
    


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$mod_info                                                      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/*   Given module object space number, this macro will returns/sets the */
/*   module object instance data -- application in that object space. 	*/
/*									*/
/* OMuword	osnum		I	Module object space number	*/
/* int		mode		I	EX_INQ oe EX_SET		*/
/* char		*app		I/O	Pointer to character array	*/
/* int		applen		I	Size of the app character array */
/*					when INQ, strlen of app string 	*/
/*					when SET			*/
/*									*/ 
/* Sample Invocation							*/
/*									*/
/*   char app_array[15];						*/
/*   status = ex$mod_info( osnum=mod_osnum, mode = EX_INQ,		*/
/*			   app = app,  applen = sizeof( app_array));	*/
/*   status = ex$mod_info( osnum=mod_osnum, mode = EX_SET;		*/
/*			   app = app,  applen = strlen(app_array) + 1);	*/
/*									*/
/* Status Returns							*/
/* 1 success								*/
/* 0 failure								*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef ex$mod_info( mod_osnum, mode=EX_INQ, app=NULL, applen=NULL )
       EX_mod_info( mod_osnum, mode, app, applen )
#endomdef       



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$peek_event_queue()                                  		*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*								 	*/
/* This macro will return the response type of next entry at the front  */
/* of software event queue 				                */
/*								 	*/
/* int		*resp		O	response type                	*/
/*									*/
/* Sample Invocation						 	*/
/*								 	*/
/*      status =  ex$peek_event_queue( resp = &myresp )		 	*/
/*				 				 	*/
/* Status Returns							*/
/*									*/
/* 	return   1    success					 	*/
/*		 0    queue empty			 	 	*/
/*								 	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
#omdef ex$peek_event_queue( resp = NULL )
       EX_peek_event_queue( resp )
#endomdef       


 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$putque ( msg, pos, response, byte , buffer,mode )	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/ 
/* All input to a Command object comes from the software input queue	*/
/* through an input filter.  The software input queue (often referred to*/
/* as just the software queue) contains data events which are put there */
/* either by WFI or other Command objects.  It is maintained by the	*/
/* Executive - Misc. Subsystem.  It is a 1024 bytes buffer which 	*/
/* contains the operator and command generated responses.  An entry can */
/* be added to the front or back of the software queue directly by 	*/
/* by using ex$putque.  						*/
/*									*/ 
/* long		*msg		O	pointer to the  return status - */
/*					defined in exdef.h		*/
/*					EXs_success - operation		*/
/*					 succeeded			*/
/*                                      EXe_no_mem - no memory		*/
/*					EXe_inv_nbytes - bad byte count */
/* long		pos		I	Queue position - FRONT / BACK	*/
/*					defined  in exdef.h		*/
/* int   		    *response	I	pointer to the response type	*/
/*					generated by event - defined in */
/*					the file exdef.h		*/
/* long		*byte		I	pointer to the size of the event*/
/*					in bytes			*/
/* event dependent  *buffer	I	pointer to buffer containing	*/
/*					event data - defined in ex.h	*/ 
/* int		mode		I	specify different mode for the  */
/*					command. THIS IS VALID ONLY WHEN*/
/*					response is EX_CMD_KEY, COMMAND */
/*					EX_STRING or CMD_STRING		*/
/*					Available modes are:		*/
/*					EX_HELP_QUIET, EX_MSG_QUIET and */
/*					EX_DISP_QUIET defined in exdef.h*/
/* Sample Invocation							*/
/*									*/
/* To put event in front of queue:					*/
/*									*/
/* sts = ex$putque (msg=&msg, response=resp, byte=&num_byte,buffer=buf )*/
/*									*/
/* To put event in back of queue:					*/
/*									*/
/*  resp = EX_CMD_KEY;							*/
/*  sts = ex$putque (    msg=&msg, pos=BACK,  response=&resp,		*/
/*                   byte=&num_byte, buffer=buf , mode = EX_HELP_QUIET )*/
/* Status Returns							*/
/* 									*/
/* 1  - success								*/
/* 0  - fail								*/
 /*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef ex$putque ( msg, pos = FRONT,response,byte=0, buffer=NULL, mode = 0)

    EXputq2( (msg), (pos), (response), (byte), (buffer) ,(mode) )

#endomdef
 

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$remove_name_from_NOD ( NODname  ^^ NODobjid, objname, 	*/
/*				     mod_osnum )			*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/ 
/* This macro will remove the object name from the named object 	*/
/* directory.  Either NODname or NODobjid can be used to identify the 	*/
/* Named Object Directory but for efficiency the use of NODname is 	*/
/* recommended.								*/
/*									*/ 
/* IGRchar	*NODname	I	pointer to the name of the NOD	*/
/* OM_S_OBJID	NODobjid	I	object id of the NOD		*/
/* IGRchar	*objname	I	pointer to the name of the 	*/
/*					given object			*/ 
/* OMuword	mod_osnum	I	object space number of module	*/
/*									*/
/* Sample Invocation							*/
/*									*/
/* sts = ex$remove_name_from_NOD (    NODobjid = nod_objid,		*/
/*                             objname = "MYOBJ")			*/
/*									*/
/* Status Returns							*/
/*									*/
/* OM_S_SUCCESS - success						*/
/* om error code - fail							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


#omdef ex$remove_name_from_NOD ( NODname="" ^ NODobjid=NULL_OBJID, 
                               objname,   mod_osnum=OM_Gw_current_OS)

#if om$specified( NODname) 
   EX_remove_name_nodname( (NODname), objname, mod_osnum)
#else
   EX_remove_name_nodid ( (NODobjid), objname, mod_osnum)
#endif

#endomdef

 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  ex$retrieve_module							*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro retrieves a module.  If the module does not exist, a new  */
/* module will be created.						*/
/*									*/
/* argument for retrieving visible module ( master file )		*/
/*       ( argument for invisible module will be ignored )		*/
/*									*/
/* int		ftype		I	EX_visible or EX_invisible	*/
/*					as defined in exdef.h		*/
/* char		*filename	I	pointer to file name of module  */
/* char		*seedfile	I	pointer to seed file name	*/
/* char		create		I	flag. if create equals 1 and	*/
/*					file is not yet exist, create	*/
/*					the file.			*/
/* int		save		I       Currently existing file will	*/
/*					be closed if user try to	*/
/*					retrieve another file. This flag*/
/*					indicates whether you want to 	*/
/*					save the existing file or not.  */
/* int		activate	I       If activate equals to 1, make   */
/*					the newly created file as the   */
/*					currrent active file.		*/
/*					( always set to true for now)	*/
/* OMuword	*osnum		O       object space num of the new file*/
/* OM_S_OBJID   *modid		O	module object id		*/
/* int		*msg		I/O	If specified and if an error 	*/
/*					occured will contain info of err*/
/*									*/
/* argument for retrieving invisible module ( ref file etc )		*/
/*       ( argument for visible module will be ignored )		*/
/*									*/
/* int		ftype		I	EX_visible or EX_invisible	*/
/*					as defined in exdef.h		*/
/* char		*filename	I	pointer to file name of module  */
/* int		flag		I	file permission flag -in exdef.h*/
/*					EX_read_only - read only	*/
/*					EX_write_only - write only	*/
/*					EX_read_write - read and write	*/
/* int		*file_no	O	pointer to an integer which 	*/
/*					represents an index into the 	*/
/*					global array invisible table	*/
/* int		fstat		I	EX_OLD_MODULE - old module	*/
/*					EX_NEW_MODULE - new module	*/
/*					EX_DEFAULT - if not found then 	*/
/*						     creates new one	*/
/* int		type		I	EX_ref for reference file	*/
/*					EX_cell for cell library        */
/*					other flags to be defined.	*/
/*					This value is stored in 	*/
/*					invisible table to indicate type*/
/*					of file.			*/
/* int		*msg		I/O	If specified and if an error 	*/
/*					occured, *msg will contain 	*/
/*					EX_erro  generic error		*/
/*					EX_flag permission flag mismatch*/
/*					        required action.	*/
/*					EX_succ  success		*/
/*					EX_nofile  file not found	*/
/* char         *mount_name     I       The name of the directory the   */
/*                                      file (object space) will be     */
/*					mounted                         */
/* int		mod_type        X       obsolete argument not used.	*/
/*					included for compatibility      */
/*									*/
/* Sample Invocation							*/
/*									*/
/*  To retrieve a visible module ( master file )			*/
/*									*/
/*   sts = ex$retrieve_module(ftype = EX_visible, filename = f_name,    */
/*		seedfile = s_name, create = create_flag, activate = 1,  */
/*		   osnum = &os_num, modid = &mod_id, msg = &retmsg);	*/
/*									*/
/*  To retrieve an invisible file ( reference file)			*/
/*									*/
/*   sts = ex$retrieve_module (   filename=&file_name,			*/
/*                       flag=EX_read_write, file_no=&index )		*/
/*									*/
/* Status Returns							*/
/*									*/
/*  1  - success							*/
/*  0  - fail								*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$retrieve_module( ftype = 0, msg = NULL,
                           filename, seedfile=0,create=1, save=0,
                           activate=1,osnum=0, modid=0,
                           flag = EX_read_write,  file_no=0,  mod_type=-1,
                           fstat = EX_default,  type = NULL, mount_name=0 )

					       
#if om$equal(ftype, EX_visible )  /* 1 */
    EX_retrieve_module( (msg), (filename), (seedfile), (create), (activate),
                        (save),  (osnum), (modid) )

#elif om$equal(ftype, EX_invisible )  /* 0 */


#   if !om$equal (file_no,0) && !om$equal(mount_name,0) 
         EX_retrieve_os( (filename), (flag), (mod_type), (file_no), 
                            (fstat), (type),(msg),(mount_name))
#   else	         
#       omerror "arg file_no or mount_name  not specified"
#   endif

#else
#   omerror "file type specified is wrong"
#endif
#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  status = ex$save_module ( ftype,index, filename, newfilename )	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* This macro saves a  module.  If the newfilename parameter is		*/
/* specified in the invocation, the module is saved using the specified */
/* file name.  Otherwise, the file name used is the same as that used to*/
/* retrieve the module.							*/
/*									*/
/* int          ftype           I       EX_visible or EX_invisible      */
/*					(#defined in exdef.h)		*/
/* int		index		I	Index into the global array 	*/
/*					invisible_table returned from	*/
/*					ex$retrieve_module		*/
/*					This argument is for invisible  */
/*					modules only.			*/
/* char		*filename	I	pointer to the module file name */
/*					This argument is for visible    */
/*					modules only.			*/
/* char		*newfilename	I       pointer to the new module file  */
/*					name.				*/
/*									*/
/* Sample Invocation							*/
/*									*/
/* To save visible module :						*/
/*									*/
/*	char myfile[128];						*/
/*	char newfile[128];						*/
/*   sts = ex$save_module ( filename=myfile, newfilename=newfile )	*/
/*									*/
/* To save invisible moudle :						*/
/*									*/
/*      int file_no;							*/
/*   sts = ex$save_module ( index=file_no )				*/
/*									*/
/* Status Returns							*/
/*									*/
/*  1  - success							*/
/*  0  - fail								*/
/*									*/ 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef ex$save_module ( ftype=0, index=-1 , filename=NULL, newfilename=NULL)

#if om$equal (newfilename, NULL)
#   if om$equal(ftype, EX_visible )  /* 1 */
#      if om$equal (filename, NULL)
#          omerror "filename not provided"
#      else
           EX_save1(filename )
#      endif 	   
#   else
#      if om$equal (index, -1)
#          omerror "index not provided"
#      else
           Save_OS( (index) )
#      endif 	   
#   endif 

#else  /* newfilename not null, save as  */
#   if om$equal(ftype, EX_visible )  /* 1 */
       EX_saveas1( newfilename )
#   else
#      if om$equal (index, -1)
#          omerror "index not provided"
#      else
          Save_As_OS( (index), (newfilename) )
#      endif 	   
#   endif
#endif
#endomdef


 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$set_abs_dig ( fm = 0 )					*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/ 
/*									*/
/* This macro will set up absolute digitizer area.			*/
/*									*/
/* int		fm		I	floating menu type		*/
/*					fm = 0 -- digitizer		*/
/*					fm = 1 -- floating menu		*/
/*									*/
/* Sample Invocation							*/
/*									*/
/*    sts = ex$set_abs_dig()						*/
/*									*/
/* Status Returns							*/
/*  									*/
/*  OM_S_SUCCESS - success						*/
/*  om error code - fail						*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef ex$set_abs_dig (   fm = 0 )

    EX_set_abs_dig ( (fm) )

#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$start_cmdserver 	                             	        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/*  ->	This macro should only be called by the application main program*/
/*  ->  under batch mode operations. If called under interactive mode,  */
/*  ->  unpredictable result may happen.				*/
/*									*/
/* int 		init		I				 	*/
/* int 		exec		I				 	*/
/*									*/
/*      if init flag != 0						*/
/*      This macro will construct cmdserver object, send init_cs 	*/
/*      wakeup_cs message to the cmdserver object.		   	*/
/*								 	*/
/*      if exec flag != 0						*/   
/*      This macro will send the exec_cs message to cmdserver.      	*/
/*								 	*/
/*      Once the cmdserver object received exec_cs message, it will  	*/
/*      start looking for input from the software event queue, and it   */
/*      will return only if exit command or EX_CMDSVR_RETURN response   */
/*      were found.							*/
/*								 	*/
/* Sample Invocation:							*/
/*								 	*/
/*      status =  ex$start_cmdserver( init=TRUE, exec= TRUE)		*/
/*				 				 	*/
/* Status Returns							*/
/* 	return   > 0  for success					*/
/*      others        fail 						*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
#omdef ex$start_cmdserver( init = NULL, exec = NULL)
       EX_start_cmdserver( (init), (exec) )
#endomdef       

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$startup	 	                             	        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/*  ->	This macro should only be called once by the application main 	*/
/*      program.							*/
/*									*/
/*									*/
/* int 		argc		I	number of argument in argv	*/
/* char        *argv[]		I       array of pointers to input 	*/
/*					arguments			*/
/* int 		mode		I       EX_BATCH or EX_INTERACTIVE	*/
/*					as defined in exdef.h		*/
/*									*/
/* Sample Invocation:							*/
/*								 	*/
/*      status =  ex$startup( argc=myargc, argv=myargv, mode=EX_BATCH)  */
/*				 				 	*/
/* Status Returns							*/
/*     1         for success						*/
/*   others        fail 						*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
#omdef ex$startup( argc , argv, mode)
       IGE_startup( (argc), (argv), (mode) )
#endomdef       

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$update_function_key (keyname,response, wait, keystring)	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/ 
/* This macro will update one entry of the function key table.		*/
/*									*/
/* IGRchar	*keyname	I	The name printed on the keyboard*/
/*					This is not case sensitive.  For*/
/*					example, a1, A1, 2nd f SELECT,	*/
/*					and 2ndfselect are all		*/
/*					acceptable key names.		*/
/* IGRint	response	I	Defined in exdef.h. You can use */
/*					9 for command objects.		*/
/* IGRshort	wait		I	Tells the executive whether to  */
/*					wait for further user input.	*/
/*					If wait = 1, the executive	*/
/*					displays the command string on	*/
/*					the screen and waits for some	*/
/*					action from the user.  The user */
/*					can press the <RETURN> key or	*/
/*					key in some more information 	*/
/*					needed for the command.  For	*/
/*					example, the line for the CHANGE*/
/*					ACTIVE ANGLE command can be	*/
/*					specified as b15,9,1,aa=.  The  */
/*					executive then waits for the 	*/
/*					user to key in the active angle.*/
/*					For the UPDATE ALL WINDOWS 	*/
/*					command, however, the line can	*/
/*					be specified as c12,9,0,update 	*/
/*					all. The executive activates 	*/
/*					this command immediately.	*/
/* IGRchar	*keystring	I	The command string identical to */
/*					one specified in the command 	*/
/*					table.				*/
/*									*/
/* Status Returns							*/
/*									*/
/* 1 - success								*/
/* 0 - failure  							*/
/*									*/
/* Notes								*/
/* Defining a Function Key						*/
/* If you define a function key more than once, only the last one	*/
/* defined is taken.							*/
/*									*/
/* Loading the Function Key						*/
/* The executive provides a command object (EX_funcky) to load the	*/
/* function key menu during any design session.  This command object	*/
/* prompts the user for the "function_key" file and then loads the	*/
/* function key definition from that file.				*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef ex$update_function_key (keyname, response, wait, keystring)

    EX_update_funcky ( (keyname), (response), (wait), (keystring) )

#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$wait_for_input(response, buffer, mode=EX_LINE_MODE,byte )*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/
/* The macro provided by the Executive - Misc. Subsystem for returning	*/
/* an event to an input filter is ex$wait_for_input.			*/
/*									*/
/* int		*response	O	pointer to the response 	*/
/*					generated by event		*/
/* char		*buffer		O	pointer to the buffer containing*/
/*					event data			*/
/* int		mode		I	as defined in  exdef.h,		*/
/*					EX_LINE_MODE - return		*/
/*					everything up to a carriage	*/
/*					return EX_CHAR_MODE - return	*/
/*					one character at a time		*/
/*					EX_ALL_CHAR_MODE - return 	*/
/*					everything in keyboard buffer   */
/*					EX_ALL_ASCII_MODE - return      */
/*					every ASCII character, ignore   */
/*					function keys etc.		*/
/* int		*byte		I/O     pointer to the buffer size in	*/
/*					bytes, on entry  sizeof buffer	*/
/*					on exit  # bytes returned	*/
/* Sample Invocation							*/
/*									*/
/* sts = ex$wait_for_input ( response=resp, buffer=buf, byte=&bufsiz )  */
/*									*/
/* Status Returns							*/
/*									*/
/* OM_S_SUCCESS - success						*/
/* om error code - fail							*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#omdef ex$wait_for_input ( response,
                           buffer,
                           mode = EX_LINE_MODE,
                           byte )
    EX_wait_for_input( (response), (buffer), (mode), (byte) )

#endomdef 




/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  not implemented   ex$switch_module( tofilename ) 	          	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*								 	*/
/* This macro will change the active module to the module specified in  */
/* tofilename.							 	*/
/*								 	*/
/* char 	*tofilename	I	ptr to name of the file  	*/
/*					to be switched to	 	*/
/* Sample Invocation						 	*/
/*								 	*/
/*      status = ex$switch_module( to=tofilename);		 	*/
/*				 				 	*/
/* Status Returns							*/
/*								 	*/
/* 	return   1    success					 	*/
/*		 0    fail				 	 	*/
/*								 	*/
/*  note: This macro will make the file named in tofilename as   	*/
/*        active module. 					 	*/
/*        You can only switch to a visible module ( master file) 	*/  
/*								 	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$build_classlist ( classnames, size, p_classlist )             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*								 	*/
/*  This macro will build a classlist structure which represents        */
/*  each classname specified in the classnames array.			*/
/*								 	*/
/* char		   **classnames	 I	Array of pointers to classnames */
/*                                      Each entry will be a classname  */
/*                                      to include in the classlist     */
/*									*/
/* int		   size 	 I	number of classnames            */
/*									*/
/* OM_S_CLASSLIST  *p_classlist  O      Address of classlist structure  */
/*									*/
/* Note									*/
/*									*/
/*   The array to contain the classids (p_classes) which is part of the */
/*   classlist structure,  must be allocated to the proper size prior   */
/*   to calling this macro.						*/
/*									*/
/* Sample Invocation:						 	*/
/*								 	*/
/*   static char *classnames[] = {"GRcircle", "GRarc" };		*/
/*   OM_S_CLASSLIST clist;						*/
/*									*/
/*   clist.p_classes = (ushort)malloc(2 * sizeof(ushort));              */
/*   if (!clist.p_classes) return (some error);				*/
/*									*/
/*   sts = ex$build_classlist ( classnames  = classnames,		*/
/*                              size        = 2,			*/
/*                              p_classlist = &clist );			*/
/*									*/
/* Status Returns							*/
/* 		 1                   Success			 	*/
/*               OM_E_NOSUCHCLASS    Invalid class given		*/
/*								 	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$build_classlist ( classnames, size, p_classlist )
   EX_build_classlist ((classnames), (size), (p_classlist))
#endomdef



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$get_working_dir ( name, len )					*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*								 	*/
/*  This macro will return the name of the current working directory    */
/*  for the master file							*/
/*								 	*/
/* char		*name		O	file name			*/
/* int		*len 	       I/O	Input: size of above char array	*/
/*					Output: len of returned name	*/
/*									*/
/* Sample Invocation:						 	*/
/*								 	*/
/*      char workdir[128];					 	*/
/*	int  len=128;                         				*/
/*									*/
/*      status = ex$get_working_dir ( name = workdir,			*/
/*		                      len  = &len );			*/
/*				 					*/
/* Status Returns							*/
/*								 	*/
/* 	return   1    success					 	*/
/*		 0    size given is too small /fail	 	 	*/
/*								 	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$get_working_dir ( name, len )
   EX_get_working_dir ((name), (len))
#endomdef



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*     ex$get_support_dir ( name, len )					*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*								 	*/
/*  This macro will return the name of the support directory.  This is  */
/*  the directory where the application product is located.             */
/*  (e.g.  /usr/ingr)							*/
/*								 	*/
/* char		*name		O	file name			*/
/* int		*len 	       I/O	Input: size of above char array	*/
/*					Output: len of returned name	*/
/*									*/
/* Sample Invocation:						 	*/
/*								 	*/
/*      char suppdir[128];					 	*/
/*	int  len=128;							*/
/*									*/
/*      status = ex$get_support_dir ( name = suppdir,			*/
/*		                      len  = &len );			*/
/*				 					*/
/* Status Returns							*/
/*								 	*/
/* 	return   1    success					 	*/
/*		 0    size given is too small /fail	 	 	*/
/*								 	*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$get_support_dir ( name, len )
   EX_get_support_dir ((name), (len))
#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$get_prod_info ( logo ^^ runname, config_flag,		*/
/*				pstring )				*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/ 
/* This macro will return information from the EX_prod_def structure    */
/* for a product in the /usr/ip32/product_data file.  Caller may        */
/* specify the product either by run name (Ems) or logo (I/EMS).  Data  */
/* returned may be either the run name, the logo or the config path.    */
/*									*/ 
/* char		*logo		I	product logo as in product_data	*/
/* char		*runname	I	product runname			*/
/* int		config_flag	I	flag=1 if config path desired	*/
/* char		**pstring	O	buffer to hold returned string	*/
/*									*/
/* Sample Invocation to get a product run name:				*/
/*									*/
/* sts = ex$get_prod_info ( logo = "I/FEM", pstring = &path)		*/
/*									*/
/*									*/
/* Status Returns							*/
/*									*/
/* OM_S_SUCCESS - success						*/
/* om error code - fail	(invalid args or could not find EX_prod_def	*/
/*		structure for given product)				*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


#omdef ex$get_prod_info ( logo=(char *)NULL ^ runname=(char *)NULL, config_flag=0,
                               pstring=(char *)NULL)

#if om$specified( config_flag )
#if om$specified( logo )
   EX_get_prod_info( (logo), EXPROD_GET_CONFIG_BY_LOGO, (pstring) )
#else
   EX_get_prod_info( (runname), EXPROD_GET_CONFIG_BY_RUNNAME, (pstring) )
#endif
#else
#if om$specified( logo )
   EX_get_prod_info( (logo), EXPROD_GET_RUNNAME_BY_LOGO, (pstring) )
#else
   EX_get_prod_info( (runname), EXPROD_GET_LOGO_BY_RUNNAME, (pstring) )
#endif
#endif		/* config_flag */

#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$get_prod_flag ( logo ^^ runname, flag )			*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/ 
/* This macro will test flags in the EX_prod_def structure of the given */
/* product.  Caller may specify the product either by run name (Ems) or */
/* logo (I/EMS).  The flag field is 0 if the DLOADED flag is to be      */
/* tested or 1 if the FORCE_DLOADED flag is to be tested.  (Note:  If   */
/* the FORCE_DLOADED flag is set, then the DLOADED flag is also set,    */
/* but the inverse may not be true).
/*									*/ 
/* char		*logo		I	product logo as in product_data	*/
/* char		*runname	I	product runname			*/
/* char		flag		I	which flag to test: 0=DLOADED	*/
/*					flag, 1=FORCE_DLOADED flag	*/
/*									*/
/* Sample Invocations 							*/
/*									*/
/* sts = ex$get_prod_flag ( logo = "I/FEM" )				*/
/*									*/
/* sts = ex$get_prod_flag ( logo = "I/PUNCH", flag = 1 )		*/
/*									*/
/*									*/
/* Status Returns							*/
/*									*/
/* 0 - specified flag was not set (or no such product exists)		*/
/* 1 - specified flag was set						*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


#omdef ex$get_prod_flag ( logo=(char *)NULL ^ runname=(char *)NULL, flag=0 )

#if om$specified( logo )
   EX_get_prod_flag( (logo), EXPROD_GET_FLAG_BY_LOGO, flag )
#else
   EX_get_prod_flag( (runname), EXPROD_GET_FLAG_BY_RUNNAME, flag )
#endif

#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* status = ex$get_product_data                                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*									*/ 
/* This macro will return information from the EX_prod_def structure    */
/* for a product in the /usr/ip32/product_data file.  Caller may        */
/* specify the product either by run name (Ems) or logo (I/EMS) or	*/
/* index (starting with 1) into the product_data file.  Data returned   */
/* returned may be any field of the product_data entry for the product. */
/* Caller supplies a pointer to pointer for each desired field, and the */
/* macro allocates the memory (om$malloc) for the data and fills it in, */
/* except in the case of the flags, which are copied to the int pointed */
/* to by 'flags'.  The flags do not come from the product_data file,    */
/* but are set by Exnuc as the product is dloaded.                      */
/*									*/ 
/* char		*in_logo	I	product logo as in product_data	*/
/* char		*in_runname	I	product runname			*/
/* int		index		I	product_data entry index (1-N)	*/
/* char		**out_runname	O					*/
/* char		**out_logo	O					*/
/* char		**module	O					*/
/* char		**dependency	O					*/
/* char		**config_path	O					*/
/* char		**product_path	O					*/
/* int		**flags		O	flags set by Exnuc		*/
/*									*/
/* Sample Invocation to get a product run name:				*/
/*									*/
/* char *path;                                                          */
/* sts = ex$get_product_data ( in_logo = "I/FEM", config_path = &path)	*/
/*									*/
/*									*/
/* Status Returns							*/
/*									*/
/* OM_S_SUCCESS - success						*/
/* 0 -      fail (invalid args or could not find EX_prod_def	        */
/*		structure for given product)				*/
/*									*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#omdef ex$get_product_data ( in_logo=NULL ^ in_runname=NULL ^ index=0,
      out_runname=NULL, out_logo=NULL, module=NULL, dependency=NULL,
      config_path=NULL, product_path=NULL, flags=NULL)

   EX_get_product_data( (in_runname), (in_logo), (index), (out_runname),
      (out_logo), (module), (dependency), (config_path), (product_path),
      (flags) )

#endomdef

#endif
