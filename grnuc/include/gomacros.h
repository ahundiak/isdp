#ifndef gomacros_include
#define gomacros_include


/************************************************************************
 This macro loads a buffer for a call to the GRfunction method
 
 The variables md_env,and your_info only need values if
	 you need to pass this information to your function.

 buffer is a pointer to a buffer of size = sizeof (struct GRfunction_info)

 ************************************************************************/

#omdef  go$build_user_function_buffer(
		buffer,			/* pointer to buffer
					   sizeof (struct GRfunction_info)*/
		md_env = NULL,		/* module environment		*/
		pass_on = 0,		/* 0 = do not pass to other spaces
				           1 = pass to other spaces	*/
		your_info = NULL)	/* your information to your 
					   function			*/

  GRbuildbuf((buffer), (md_env), (pass_on),(your_info))
	
#endomdef
					
#endif
