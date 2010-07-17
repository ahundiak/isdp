This file is supposed to keep history of what has
been done and what remains to be done.


07 JAN 98	Onay
********************

RT Functions that need to be provided.

Function name			File

RT_init_read			read.C
RT_exit_read			read.C
RT_get_piping_systems		read.C
RT_get_pipelines		read.C
RT_get_pipe_runs		read.C
RT_get_pipe_run_part		read.C
RT_get_pipe_attributes		read.C
RT_get_piping_component_attr	read.C
RT_init_write			write.C
RT_exit_write			write.C
RT_put_piping_entity		write.C

Functions above have some dependancies in
files :
piperun.C
dngl.C
RTeqp.I
rtiges.h
rteqp.h


external references so far not existing which
need to be implemented

_long_to_cmpint
_diag_malloc
_ll_new
_diag0_free
_ll_freef
_ll_find_object
_diag
_pointera_free
_str_cmp
_ll_free
_debug
_Diag_debug
_ll_insert
_ll_array
_str_copy

08 JAN 98	Onay
********************

Other files below are kept because they use to exist
and contain some samples but are not part of the
vrrt.m file. fun.C can for instance be used to test
the proper behaviour of the RT functions. A simple
ppl program calling the fun function would need to
be created.
drive.C
fun.C
tmp.C
trial.C


12 JAN 98	Onay
********************
Here is the content of an email (Sep 03 1997) which explains 
that we must keep track of work done on this project and
crosscharge another group and send a justifications
of this crosscharge at the end of each month to
Joyce Howell.

************* Beginning of mail *****************************8

Ad, 

As summary to our discussions, the following documents the 
MariSTEP requirements for support from the ISDP Development 
organization:

Need .3 person from ISDP Development to support MariSTEP project 
over next 22 months ( 13 hours/week which is about 60 hrs/month 
or 700 hrs/year)

Labor hours may be charged to W.A. 474-00 2100-2824 

Initial Requirements:
   RT functions 
- Port to Solaris environment
- Assure use of better memory allocation routines

Specifications and schedule for RT enhancements and additional ISDP 
APIs are targeted to be available in early October.

For monthly reporting to the Government, I will also need brief weekly 
status reports from each person charging against the WA detailing :
# hours charged
tasks performed
accomplishments

Thanks,
Joyce

************* End of mail *****************************8


Things to do :
Since there are some unresolved externals, the final .o is
created in the local directory.
The external functions not available in the product need to be
created. Most of them are easy, only the linked list management
might be a little bit more tricky. Linked list functions begin
with ll_.
Once all unresolved externals are fixed, and functions tested, the
memory management needs to be changed. Every malloc and free must be
changed by VDS malloc and free functions.
MariSTEP will ask for further developments since the NAVY seems to
have changed the piperuns definitions. We might need to cut the network
whenever a valve is encountered.

14 JAN 98	Onay
********************
Finally an old tape containing old sources of CPIGES has been found.
Most or all the external references are resolved BUT NOT ALL OF THEM because
at least one source file is missing which is commonext.h.

New files needed are :
dgstdlb.h
dgstdlb.c
llstruct.c
llmisc.c
llinsert.c
cmp.c
str.c
ll.h
common.h
self.h
diag.h
cfunc.h
arrays.h
struct.h
strcfunc.h
dflags.h
diagstdlib.h


Let's have a look at what needs to be done to fix the unresolved externals.
_long_to_cmpint		generic convertion macros in file cmmnxt.h
_diag_malloc		function defined inside dgstdlb.c
_ll_new			function defined inside llstruct.c
_diag0_free		function defined inside dgstdlb.c
_ll_freef		complex defined in llstruct.c
_ll_find_object		function defined in llinsert.c
_diag			defined in dgstdlb.c
_pointera_free		UNDEFINED
_str_cmp		function defined in cmp.c
_ll_free		function defined in llstruct.c
_debug			Should get rid of it easily
_Diag_debug		Should get rid of it easily
_ll_insert		function defined in llmisc.c
_ll_array		function defined in llmisc.c
_str_copy		function defined in str.c

It is very important to convert .c files into .C simply by renaming the
extension, this way the precompiler will resolve all defined macros.
By doing this most of files will compile except that I got a syntax error
problem, a blank was inserted in the member name of a structure, and I did
have time to figure out why.
.c files had a header in RCS format. It has been removed. Since work needs
to be done on these files, they have not been integrated into Pinnacle yet.
But both isdp23 and skylon systems are the same. Only high level functions
are compiled and the resulting .o is not put into the lib directory due
to unresolved externals.
Old source files of IGES are located on vdssrv sdmadmin*2, directory
traci/iges12/rt/common/RCS.
