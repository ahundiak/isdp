Main build sequence:
-------------------
  1. vr_make
  ----------

   options:
   -------
	echo "Unprotect I/ROUTE files?"				chmod +w
	echo "Clean all ROUTE executables ? (total rebuild)"	vr_clean
	echo "Remove all makefiles?"				vr_rmMake
	echo "Create a list of I/ROUTE modifications?"		vr_list
	echo "touch *.sl files to force recompile ?"		touch
	echo "Slic *.sl files ?"				vr_mkSpec
	echo "Build ROUTE ?"					vr_compile
	echo "Change version number?"				vr_updprodef
	echo "Link and update version?"				vr_mkdload
	echo "Create newprod package?"				vr_release

   Actions
   -------
	script	     optional   action
	-----	     -------	------
			opt	change protection
	vr_clean	opt	remove binaries
	vr_rmMake	opt	remove makefiles
     	vr_list		opt	list files modified from pinnacle
	vr_msgbuild		build message files if needed
	vr_menubuild		build menu files if needed
			opt	touch all *.sl
 	vr_mkSpec	opt	slic *.sl 
				link spec files
	vr_compile	opt	build
	vr_updprodef	opt	change version number
	vr_mkdload	opt	dload, update VRversion.o 
    	vr_release	opt	create newprod package


Secondary Scripts
-------------
  vr_mkSpec
	vrslic
  vr_compile
	vrmake

  vrmake
	vrslic
	vrmakemake
	

Other Scripts
-------------
   vrmkcmds	rebuild commands and command table

  vrrebuild
  ---------
	script	     	action
	-----	     	------
	sources	     	define directories to compile, SRC env variables
	vrslic		slic given directories
	vrmakemake	
	mkmkppl		makemake for ppl directories

    New scripts (from vrrebuild)
        vr_rmmkfile             remove makefiles
        vr_slic                 run slic
        vr_makefile             create makefiles
        vr_build                compile source



README
------
	$ROUTE/etc/version/README
	$ROUTE/config/dload/init/VRversion.o
