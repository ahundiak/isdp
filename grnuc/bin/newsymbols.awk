BEGIN {
	  shlib_section = 1
	  first_time = 1
	  new_import_cnt = 1
	  new_branch_cnt = 1
	  wrong_sym_cnt = 1
	  uninit_var_cnt = 1
	  init_var_cnt = 1
	  newsym_h_file = "newsym.h"
	  newsym_c_file = "newsym.c"
	  newsymar_c_file = "newsymar.c"
	  newsym_sl_file = "newsym.sl"
	  newsym_bt_file = "newsym.bt"
	  method_index = "method_index"
	  class_id = "class_id"
       }

first_time == 1 {
	      first_time = 0
	      shlib_tag = "_" tag "_"
	      shlib_tag_len = length(shlib_tag)
	  }

/shlib finished/ {
		    shlib_section = 0
		 }


{
	    if (shlib_section == 1)
	    {
	       if (($1 == -1) && (substr($2,1,1) == "_"))
	       {
	   	  if (substr($2,1,shlib_tag_len) == shlib_tag)
	   	  {
	      	     import_sym[substr($2,shlib_tag_len)] = 1
	   	  }
	   	  else
	   	  {
	      	     text_sym[$2] = 1
	   	  }
	      }
     	   }
	   else
	   {
	      if ($1 == 0)
	      {
		  if ($3 != "0x00000000")
		  {
		     uninit_var[uninit_var_cnt++] = $2
		  }
		  else
		  {
	             if (substr($2,1,shlib_tag_len) != shlib_tag)
		     {
		        if (text_sym[$2] != 1)
		        {
			   if (import_sym[$2] == 1)
			   {
			      wrong_sym[wrong_sym_cnt++] = $2
			   }
			   else
			   {
			      new_import[new_import_cnt++] = $2

			   }
		        }
		     }
		  }
	       }
	       else
	       {
		  if ($1 == text_section)
		  {
		     if (text_sym[$2] != 1)
		     {
			new_branch[new_branch_cnt++] = $2
		     }
		  }
		  else
		  {
		      if ($1 == data_section)
		      {
		         init_var[init_var_cnt++] = $2
		      }
		  }
	       }
	   }
}


END	{

	   if ((new_import_cnt > 1)  || (new_branch_cnt > 1) || \
	      (wrong_sym_cnt > 1) || (uninit_var_cnt > 1) || \
	      (init_var_cnt > 1))
	   {
	       printf "\n\nFILE: %s\n",file
	   }
	   else
	   {
	      printf "\n\nFILE: %s is ok\n",file
	   }

	   if (new_import_cnt > 1)
	   {
	      printf "\nThe following are symbols that need to be imported:\n\n"

	      for (i=1; i< new_import_cnt; i++)
	      {
		 if ((substr(new_import[i],(length(new_import[i]) - 11)) == "method_index"))
		 {
		    type = "OMuword"
		 }
		 else
		 {
		    if ((substr(new_import[i],(length(new_import[i]) - 7)) == "class_id"))
		    {
		       type = "OMuword"
		    }
		    else
		    {
		        type = "?????"
		    }

		 }

		 printf "%s\n",new_import[i]

		 if (i == 1)
		 {

		    printf "\n\n\nFILE: %s\n\n",file >> newsym_h_file

		    printf "\n\n\nFILE: %s\n\n",file >> newsym_c_file

		    printf "\n\n\nFILE: %s\n\n",file >> newsymar_c_file

		    printf "\n\n\nFILE: %s\n\n",file >> newsym_sl_file

		 }

		 printf "#define %s    %s\n",substr(new_import[i],2),\
				"(*" substr(shlib_tag,2) substr(new_import[i],2) ")" >> newsym_h_file

		 printf "%s %s\n",type,\
				"(*" substr(shlib_tag,2) substr(new_import[i],2) ") = 0;" >> newsym_c_file

		 if (type == "OMuword")
		 {
		    printf "%s %s = & %s\n",type,\
				"(*" substr(shlib_tag,2) substr(new_import[i],2) ")",substr(new_import[i],2) ";" >> newsymar_c_file
		 }
		 else
		 {
		    printf "%s %s = & %s\n",type,\
				"(*" substr(shlib_tag,2) substr(new_import[i],2) ")",substr(new_import[i],2) ";" >> newsymar_c_file
		 }

		 printf " %s      %s\n",shlib_tag substr(new_import[i],2),\
					new_import[i] >> newsym_sl_file
	      }

	      for (i=1; i< new_import_cnt; i++)
	      {
		 if ((substr(new_import[i],(length(new_import[i]) - 11)) == "method_index"))
		 {
		    type = "OMuword"
		 }
		 else
		 {
		    if ((substr(new_import[i],(length(new_import[i]) - 7)) == "class_id"))
		    {
		       type = "OMuword"
		    }
		    else
		    {
		        type = "?????"
		    }

		 }

		 printf "extern %s %s;\n",type,substr(new_import[i],2) >> newsym_h_file
	      }
	  }

	   if (new_branch_cnt > 1)
	   {
	      printf "\nThe following are symbols that need to be added to the branch table:\n\n"

	      for (i=1; i< new_branch_cnt; i++)
	      {
		 printf "%s\n",new_branch[i]
		 if (i == 1)
		 {
		    printf "\n\n\nFILE: %s\n\n",file >> newsym_bt_file
		 }
		 printf "%s\n",new_branch[i] >> newsym_bt_file

	      }
	  }

	   if (wrong_sym_cnt > 1)
	   {
	      printf "\nThe following are symbols that should have the tag %s appended to the\n",substr(shlib_tag,1,shlib_tag_len - 1)
	      printf "front.  There are a couple reasons why the tag was left off\n"
	      printf "1) a file was compiled with the wrong import.h file or\n"
	      printf "2) a file does not have the import.h file included\n\n"
	      for (i=1; i< wrong_sym_cnt; i++)
	      {
		 printf "%s\n",wrong_sym[i]
	      }
	  }

	   if (uninit_var_cnt > 1)
	   {
	      printf "\nThe following are symbols that are uninitialized globals that need\n"
	      printf "to be initialized and added to the global file:\n\n"

	      for (i=1; i< uninit_var_cnt; i++)
	      {
		 printf "%s\n",uninit_var[i]
	      }
	  }

	   if (init_var_cnt > 1)
	   {
	      printf "\nThe following are symbols that are initialized globals that need\n"
	      printf "to be added to the global file:\n\n"

	      for (i=1; i< init_var_cnt; i++)
	      {
		 printf "%s\n",init_var[i]
	      }
	  }



	}
		 
