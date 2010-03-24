
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* oppdata.c - global data for opp					*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* September 1986							*/
/*									*/
/* Global Variables :							*/
/*	opppwd	  - current working directory (".")			*/
/*	oppout	  - output file pointer.				*/
/*	outlines  - count of lines written to oppout.			*/
/*	keep_mode - if set, incomplete output is not deleted		*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#include "opp.h"

unsigned int opp_version = 0x050109; /* 5.1.9 */

/*

  05/06/93 version 5.1.9 -      Opp will now tag unnamed enum definitions
                                with a generated Phantom tag.

  1/20/93  version 5.1.8 -      Opp has to be able to handle syntax in NT
                                include files. Accept backslash in midst of
                                macro argument list; allow ^Z character at
                                end of file; don't chain down an identifier's
                                field_link list to free links on the list,
                                just free the identifier and assume identifiers
                                on the list get freed later.  Put off really
                                hard problems in NT include files til later. 

  12/28/92 version 5.1.7 -	Call unmark_all_written_symbols before calling
				cpp_stream_close, which deletes symbols.
				Changes went into opp.c and oppface.c.

  12/14/92 version 5.1.6 -	Fix to process_unique in ordertab.c to check
				for level of zero before processing symbol.
				This was due to a global extern of:
					extern OMuword mod_osnum;
				which matched a parameter in a prototype that
				had been previously defined.

				Also put in a fix to dumpmessage.c in function
				verify_imported_message where a symbol was 
				being put into the written list and then the
				struct was freed.  Fix was to not free the
				symbol structs.

  12/02/92 version 5.1.5 -	Fix for inherited (from spec) externs which
				prevented global definition of variable from
				being written to output file.  Fix was in
				local_processed_name to check for extern class
				before marking symbol as defined.

  11/19/92 version 5.1.4 -	Fix for multi-opp:  needed a specific
				way to clear the F_IDENTIFIER_WRITTEN
				bit after each file is processed.  This 
				ensures that all symbols are written out
				correctly.

  11/17/92 version 5.1.3 -	Update yacc input to compile on NT.

  10/30/92 version 5.1.2 -	NT mods to remove warnings.  Mostly adding
				prototypes.

  10/15/92 version 5.1.1 -	NT mod for pathname separator.
  
  10/12/92 version 5.1.0 -	NT mods.
  
  09/22/92 version 5.0.25 -	Change to use offsetof macro for ansi
				portable way of computing structure
				offsets.

  08/27/92 version 5.0.24 -	Fixed bug in following %endsafe with
				#argsused (lex3.c).

  08/14/92 version 5.0.23 -	Add cases for IRIX:
					opp.c	use of stat fstat.
					oppy.y	suppression of illegal
						redeclaration errors.
					initgen.c	output of create
							class args.
					odinsup.c	output of message
							defns.

  07/10/92 version 5.0.22 -	Separate the name spaces for symbols and tag
				names.  This allows a struct tag and typedef
				name to be the same.

  06/16/92 version 5.0.21 -	Add "signed" keyword.

  06/08/92 version 5.0.20 -	Fix initialization of enums.

  05/12/92 version 5.0.19 -	Fix bug in using the sizeof operator
				on typedefs.  Was defaulting to int
				for the size.

  05/12/92 version 5.0.18 -	Fix bug in dumping types required for
				struct members.  It was returning from
				a for loop instead of continuing.

  05/11/92 version 5.0.17 -	Fix to changing method arguments from arrays
				into pointers.  The fix is for arrays of
				typedefs.

  05/08/92 version 5.0.16 -	Fix memory fault in parser.

  05/08/92 version 5.0.15 -	Change to not dump top-level data declarations
				more than once.  Fix initialization of "me"
				in methods.

  05/07/92 version 5.0.14 -	Change method arguments that are array typedefs
				into pointers.

  05/07/92 version 5.0.13 -	Change local declaration of "me" in methods
				to pointer to object header.  Used to be
				pointer to char.

  05/01/92 version 5.0.12 -	Use opping_for_discos global to change the
				parser to do typedef names the old way.  This
				is for ddp.

  04/30/92 version 5.0.11 -	Change to support TOK_ARGSUSED

  04/30/92 version 5.0.10 -	Change to not dump duplicate typedefs.

  04/24/92 version 5.0.9  -	Change to not check message argument types and
				to dump typedefs for message arg structs.

  04/21/92 version 5.0.8  -	Change to dump typedef names instead of
				definitions.

  04/15/92 version 5.0.7  -	Change long float to double.

  04/07/92 version 5.0.6  -	Remove dollar sign from method index variable
				name.  It is not part of an ansi identifier.

  04/06/92 version 5.0.5  -	Add support for CONST and VOLATILE to
				the ptree.  And also add prototype support
				to the ptree.

  04/03/92 version 5.0.4  -	Add support for storing and regurgitating
				prototype info (outside of the ptree).

  04/01/92 version 5.0.3  -	Add support for parsing function prototypes.

  04/01/92 version 5.0.2  -	Add support for wide character constants.

  03/30/92 version 5.0.1  -	Add support for accepting a list of string
				constants separated by white space as a single
				string constant as per ansi.

  03/30/92 version 5.0.0  -	Start the ansi port.  Adding the keywords
				"const" and "volatile".

  03/03/92 version 4.5.34 -	Changed to remove the keyword class from the
				symbol table after it is parsed.  This was
				being freed twice if a struct contained a
				field named class.  Can be repeated by exporting
				BLKCHECKS=1 and opping a .I that includes
				<X11/Xlib.h> and declares a variable of
				type Visual (this struct contains a member
				"class").

  09/19/91 version 4.5.33 -	Added a cleanup routine for SIGINT and
				SIGTERM.

  07/08/91 version 4.5.32 -	Made source code ansi clean.  Also changed to
				not output an extra comma at the end of
				enum declarations.  Also changed the output of
				typecasting for OM_sd_ancestry structure:  The
				p_create_args field is now declared as a 
				pointer to a function returning an int.

  07/08/91 version 4.5.31 -	Add ARGSUSED comment before methods in opp
				output to suppress appogee warnings about
				arguments declared and never used.

  05/29/91 version 4.5.30 -	Remove indexed_struct_list from class 
				structure.

  05/22/91 version 4.5.29 -     Fix oppy.y to allow multiple declarations 
				of the form:
					int foo();
					int foo();

  05/14/91 version 4.5.28 -	Fix oppy.y to allow multiple declarations
				of the form:
					int foo();
					extern int foo();

  05/07/91 version 4.5.27 -	Fix for porting defines name changes.

  05/07/91 version 4.5.26 -	Fix for get_struct_dcltr[kgti.c].  Check for
				NULL expression before evaluating.  Symptom
				was core dump from evaluate_ptree_exp.

  05/01/91 version 4.5.25 -	Remove "class" as a keyword for X compatibilty.

  03/06/91 version 4.5.24 -	Condition compile around 4.5.23 appogee fix
				for SUN compatibility.  Also fix to share_type
				to check zero pointer before referencing.

  01/02/91 version 4.5.23 -	Fix to not flush tokens on line containg
				endsafe (lex3.c)

  08/27/90 version 4.5.22 -	Apogee fixes -- OM_S_METHDEFN in odinsup.c.

  08/27/90 version 4.5.21 -	Apogee fixes.

  08/09/90 version 4.5.20 -	Change an error to a warning: when a symbol
				being undefed is not found.

  08/06/90 version 4.5.19 -	Add %undef control line to remove symbols
				from the current symbol table.  Used to 
				prevent name conflicts between system
				include files and OM files.

  10/04/89 version 4.5.18 -	Added type cast to restricted channel to
				avoid compiler warning. 

   3/08/89 version 4.5.17 -	Added new keyword "not_taggable". Overrides any
				taggable keywords specified by ancestors.
				It is NOT inherited.

   2/17/89 version 4.5.16 -	Fixed bug in opp_process_impl_file.  It
				was using strchr to search for the . in the
				file name (looking for the extension).  Had
				obvious problems with ./file etc.  Changed
				to search from the end of the string.

   2/9/89  version 4.5.15 -	Made the malloc profiling more sophisticated.
				Dumps a report every n seconds when setSample(n)
				is called.

   2/2/89  version 4.5.14 -	Added some malloc profiling if compiled
				with -DMALLOC_PROFILE

   2/1/89  version 4.5.13 -	Added type casts to code inserted in the
				beginning of methods in an attempt to reduce
				the number of warnings generated by 1.8.4
				Greenhill's C compiler.  Also add type casts
				to the initialization of OM_S_ANCESTRY and
				OM_S_METHDEFN structs to avoid the same 
				warnings.

   8/29/88 version 4.5.12 -	(rme) Restricted singleton channels are
   				not included in the vla's.  They are just
   				OBJID's in the instance data.
   				
   8/09/88 version 4.5.11 -	(rme) Added new keyword "taggable" to spec
   				files.  Marks the class as taggable by the
   				om runtime system.  Extra flag put at the 
   				end of the create class args.
   				
   7/18/88 version 4.5.10 -	(rme) Renamed the static OM_class_init struct
   				inside the class init functions.
   				
   7/08/88 version 4.5.9 -	(rme) Since messages are passed by reference
   				, needed to have multiple OM_S_MESSAGE structs
   				to handle nested messages.
   				
   7/04/88 version 4.5.8 -	(rme) %safe stuff is returned as part of the
   				parse tree so that it will be put in the
   				proper place inside of methods or functions.
   				
   6/15/88 version 4.5.7 -	(rme) Classinit is now a function that
   				returns the pointer to the component class
   				def structure.
   				
   4/28/88 version 4.5.6 -	(rme) Allow sizeof in constant expression
				outside of ant function or method.

   4/05/88 version 4.5.5 -	(rme) Changes to pass OPPmsg by address
				were backed out in class j.  This version
				change is just to distinguish between cls_j
				and cls_k

   2/10/88 version 4.5.2 -	(rme) Changed the size field in dcltr_ptr in
				identifiers.h to an int from a short.  A short
				limited vla initial size.

  12/17/87 version 4.5.1 -	(rme) Stopped the variable OPPclident_(class)
				from being put in implementation files.  It
				was no longer being used for anything and it
				reeked havoc with the shared library.

  12/14/87 version 4.5.0 -	(rme) Passing messages by address.  This
				optimizes sends to self.

  12/01/87 version 4.4.5 -      (rme) Fixed a problem in overriding instance
				data.  Do not include any vlas from the 
				overridden class in the VARLENARR_DEFNS
				struct.  (initgen.c)

  11/20/87 version 4.4.4 -	(rme) Fixed problem when overriding instance
				data.  A reference to the overridden class's
				was still being included in the COMPONENT 
				list. (initgen.c)

  11/6/87 version 4.4.3 -       (rme) Fixed problem with rejected messages,
				they were not being included in the override 
				count in the COMPONENT list.  (initgen.c)

  10/5/87 version 4.4.2  -	(rme) Fixed problem with implementation files:
				Was a problem with functions that had formal
				parameters with the same name as the function.
				Added code to override the inclusion of
				instance data from a class as specified in the
				OM43 release notes.

  9/16/87 version 4.4.1  - changed channels to pointers.
 
  9/10/87 version 4.4.0  - changed VLA access to use pointer rather than offset

  8/27/87 version 4.3.9  - fixed restricted channel for discos.

  8/25/87 version 4.3.8  - restricted many chans now use less space.
			   misc. compressions in initgen.c.

  8/24/87 version 4.3.7	 - negative enum constants are now ok.
			 - misc. compressions in dumpmessage.c.

  8/21/87 version 4.3.6  - added reject and from class inherit.

  8/19/87 version 4.3.5  - class_id used for component_offset is now 
			   passed through cpp for macro expansion.

  8/12/87 version 4.3.4  - changed class creation logic.
			 - changed component_offset etc.

  6/30/87 version 4.3.3  - enum init, channel init and incr are now expressions

  6/23/87 version 4.3.2  - assigned values to method_indices in class_init

  6/22/87 version 4.3.1  - changed method_index to use "$"

  6/22/87 version 4.3.0  - removed declarations for class_id and method_index

  6/10/87 version 4.2.3  - fixed class_field_search to search the most
			   recent class first.  This causes most recently
			   declared instance field with the given name
			   to be found.

  5/13/87 version 4.2.2  - fixed class count in restricted channel defn.

  5/12/87 version 4.2.1  - fixed spec globals becoming externs in multi-opp.
			 - fixed default channel attributes broke by 4.2.0.

  5/11/87 version 4.2.0  - restricted channels

  4/09/87 version 4.0.51 - freed all memory used by .I file compilation.

  3/24/87 version 4.0.50 - Set link to 0 before call to setlisttype on function.
			   Fixed bug in parameters to function.  Previously
			   the types of some parameters to functions were
			   accedentaly modified by the call to setlisttype
			   for the function itself.
  3/12/87 version 4.0.49 - Fixed function definitions in which typedef name is
			   used to declare return type.
			 - Fixed order of struct declarations in output file.
			 - Issued error message when classname which has been
			   redeclared as something else is used to try to send
			   a message.
			 - Fixed line numbering in output file.
			 - added private and querynomod attributes
			 - added traceback of include files
			 - unknown cpp directives are now treated with warnings.
			 - "#if clipper" etc. are now correct on both.
  3/06/87 version 4.0.48 - merged 4.0.44(craighead) with 4.0.47.
			 - fixed lookup_local of basictab.
			 - removed increment_level before func_dcltr in kgti.
  2/24/87 version 4.0.47 - fixed filename problem in oppface.c 
  2/23/87 version 4.0.46 - changed "we_overrode_it" to compare by pointer 
  2/04/87 version 4.0.45 - fixed dump_struct to keep structs in order 
  1/08/87 version 4.0.44 - mods for less symtab dependence 
 12/18/86 version 4.0.43 - cut size of cpp token for pnodes
 12/13/86 version 4.0.42 - reworked symtab, builds use list for discos
 12/09/86 version 4.0.41 - uses less memory, no longer calls mallopt
*/

int opping_for_discos = 1; /* boolean - cleared by opp.c */

FILE *oppout;
int outlines = 0;
char oppout_name[256] = "";

int keep_mode;
int filter_duplicate_includes = 0;
int emit_lines = 1;
