#ifndef  FETPmacros_included
#define  FETPmacros_included

#include "TPruntp.h"

/* *****************************H H H H H******************************* */

/* Doc: fe$run_MSC_analysis

   Abstract:
   	This macro executes analysis using MSC/NASTRAN.

   Arguments:
       int    host            i - LOCAL_HOST, REMOTE_HOST, see TPruntp.h

       int    exe_mode        i - INTERACTIVE_MODE, BATCH_MODE, see TPruntp.h

       int    analysis_type   i - Analysis type, see TPruntp.h

       char   node_name[]     i - Remote host name

       char   login[]         i - Login on remote host

       char   passwd[]        i - password on remote host

       char   workdir[]       i - working directory on remote host

       char   exe[]           i - path to executable and executable

   Return Status:
	1	-	SUCCESS

   Examples:

        (1) Local execution

	#include "FEmacincl.h"

	main()
	{	
	int sts ;

            sts = fe$run_MSC_analysis();
	}

        (2) Remote execution

	#include "FEmacincl.h"

	main()
	{	
	int sts ;

            sts = fe$run_MSC_analysis( host = REMOTE_HOST,
                                       node_name = "server_1",
                                       login = "steve",
                                       passwd = "l123456",
                                       workdir = "/usr/steve",
                                       exe = "/usr/ip32/nastran/bin/nastran" );
	}

   History:
	Date		Who		Why
	---------	------		--------------------------------
        09-01-93        ckc             Creation

*/

/* *****************************H H H H H******************************* */

extern 	int	FE_run_MSC_analysis();

#omdef 	fe$run_MSC_analysis( host = LOCAL_HOST,
                             exe_mode = INTERACTIVE_MODE,
                             analysis_type = LINEAR_STATIC,
                             node_name,
                             login,
                             passwd,
                             workdir,
                             exe )

	FE_run_MSC_analysis( host, exe_mode, analysis_type, node_name, login, passwd,
	                     workdir, exe ) 	

#endomdef

/* *****************************H H H H H******************************* */

/* Doc: fe$run_CSA_analysis

   Abstract:
   	This macro executes analysis using CSA/NASTRAN.

   Arguments:
       int    host            i - LOCAL_HOST, REMOTE_HOST, see TPruntp.h

       int    exe_mode        i - INTERACTIVE_MODE, BATCH_MODE, see TPruntp.h

       int    analysis_type   i - Analysis type, see TPruntp.h

       char   node_name[]     i - Remote host name

       char   login[]         i - Login on remote host

       char   passwd[]        i - password on remote host

       char   workdir[]       i - working directory on remote host

       char   exe[]           i - path to executable and executable

   Return Status:
	1	-	SUCCESS

   Examples:

        (1) Local execution

	#include "FEmacincl.h"

	main()
	{	
	int sts ;

            sts = fe$run_CSA_analysis();
	}

        (2) Remote execution

	#include "FEmacincl.h"

	main()
	{	
	int sts ;

            sts = fe$run_CSA_analysis( host = REMOTE_HOST,
                                       node_name = "server_1",
                                       login = "steve",
                                       passwd = "l123456",
                                       workdir = "/usr/steve",
                                       exe = "/usr/ip32/csanastran90/nastran" );
	}

   History:
	Date		Who		Why
	---------	------		--------------------------------
        09-01-93        ckc             Creation

*/

/* *****************************H H H H H******************************* */

extern 	int	FE_run_CSA_analysis();

#omdef 	fe$run_CSA_analysis( host = LOCAL_HOST,
                             exe_mode = INTERACTIVE_MODE,
                             analysis_type = LINEAR_STATIC,
                             node_name,
                             login,
                             passwd,
                             workdir,
                             exe )

	FE_run_CSA_analysis( host, exe_mode, analysis_type, node_name, login, passwd,
	                     workdir, exe ) 	

#endomdef

/* *****************************H H H H H******************************* */

/* Doc: fe$run_ANSYS_analysis

   Abstract:
   	This macro executes analysis using ANSYS Version 4.4A.

   Arguments:
       int    host            i - LOCAL_HOST, REMOTE_HOST, see TPruntp.h

       int    exe_mode        i - INTERACTIVE_MODE, BATCH_MODE, see TPruntp.h

       int    analysis_type   i - Analysis type, see TPruntp.h

       char   node_name[]     i - Remote host name

       char   login[]         i - Login on remote host

       char   passwd[]        i - password on remote host

       char   workdir[]       i - working directory on remote host

       char   exe[]           i - path to executable and executable

   Return Status:
	1	-	SUCCESS

   Examples:

        (1) Local execution

	#include "FEmacincl.h"

	main()
	{	
	int sts ;

            sts = fe$run_ANSYS_analysis();
	}

        (2) Remote execution

	#include "FEmacincl.h"

	main()
	{	
	int sts ;

            sts = fe$run_ANSYS_analysis( host = REMOTE_HOST,
                                         node_name = "server_1",
                                         login = "steve",
                                         passwd = "l123456",
                                         workdir = "/usr/steve",
                                         exe = "/usr/ip32/ansys44a/bin/ansys" );
	}

   History:
	Date		Who		Why
	---------	------		--------------------------------
        09-01-93        ckc             Creation

*/

/* *****************************H H H H H******************************* */

extern 	int	FE_run_ANSYS_analysis();

#omdef 	fe$run_ANSYS_analysis( host = LOCAL_HOST,
                               exe_mode = INTERACTIVE_MODE,
                               analysis_type = LINEAR_STATIC,
                               node_name,
                               login,
                               passwd,
                               workdir,
                               exe )

        FE_run_ANSYS_analysis( host, exe_mode, analysis_type, node_name, login,
                               passwd, workdir, exe ) 	

#endomdef

/* *****************************H H H H H******************************* */

/* Doc: fe$run_ANSYS_5_analysis

   Abstract:
   	This macro executes analysis using ANSYS Version 5.

   Arguments:
       int    host            i - LOCAL_HOST, REMOTE_HOST, see TPruntp.h

       int    exe_mode        i - INTERACTIVE_MODE, BATCH_MODE, see TPruntp.h

       int    analysis_type   i - Analysis type, see TPruntp.h

       char   node_name[]     i - Remote host name

       char   login[]         i - Login on remote host

       char   passwd[]        i - password on remote host

       char   workdir[]       i - working directory on remote host

       char   exe[]           i - path to executable and executable

   Return Status:
	1	-	SUCCESS

   Examples:

        (1) Local execution

	#include "FEmacincl.h"

	main()
	{	
	int sts ;

            sts = fe$run_ANSYS_5_analysis();
	}

        (2) Remote execution

	#include "FEmacincl.h"

	main()
	{	
	int sts ;

            sts = fe$run_ANSYS_5_analysis( host = REMOTE_HOST,
                                           node_name = "server_1",
                                           login = "steve",
                                           passwd = "l123456",
                                           workdir = "/usr/steve",
                                           exe = "/ansys50/bin/ansys" );
	}

   History:
	Date		Who		Why
	---------	------		--------------------------------
        09-01-93        ckc             Creation

*/

/* *****************************H H H H H******************************* */

extern 	int	FE_run_ANSYS_5_analysis();

#omdef 	fe$run_ANSYS_5_analysis( host = LOCAL_HOST,
                                 exe_mode = INTERACTIVE_MODE,
                                 analysis_type = LINEAR_STATIC,
                                 node_name,
                                 login,
                                 passwd,
                                 workdir,
                                 exe )

        FE_run_ANSYS_5_analysis( host, exe_mode, analysis_type, node_name, login,
                                 passwd, workdir, exe ) 	

#endomdef

/* *****************************H H H H H******************************* */

/* Doc: fe$run_MARC_analysis

   Abstract:
   	This macro executes analysis using MARC.

   Arguments:
       int    host            i - LOCAL_HOST, REMOTE_HOST, see TPruntp.h

       int    exe_mode        i - INTERACTIVE_MODE, BATCH_MODE, see TPruntp.h

       int    analysis_type   i - Analysis type, see TPruntp.h

       char   node_name[]     i - Remote host name

       char   login[]         i - Login on remote host

       char   passwd[]        i - password on remote host

       char   workdir[]       i - working directory on remote host

       char   exe[]           i - path to executable and executable

   Return Status:
	1	-	SUCCESS

   Examples:

        (1) Local execution

	#include "FEmacincl.h"

	main()
	{	
	int sts ;

            sts = fe$run_MARC_analysis();
	}

        (2) Remote execution

	#include "FEmacincl.h"

	main()
	{	
	int sts ;

            sts = fe$run_MARC_analysis( host = REMOTE_HOST,
                                        node_name = "server_1",
                                        login = "steve",
                                        passwd = "l123456",
                                        workdir = "/usr/steve",
                                        exe = "/usr/ip32/marc_solver/bin/run_marc" );
	}

   History:
	Date		Who		Why
	---------	------		--------------------------------
        09-01-93        ckc             Creation

*/

/* *****************************H H H H H******************************* */

extern 	int	FE_run_MARC_analysis();

#omdef 	fe$run_MARC_analysis( host = LOCAL_HOST,
                              exe_mode = INTERACTIVE_MODE,
                              analysis_type = LINEAR_STATIC,
                              node_name,
                              login,
                              passwd,
                              workdir,
                              exe )

        FE_run_MARC_analysis( host, exe_mode, analysis_type, node_name, login,
                              passwd, workdir, exe ) 	

#endomdef

/* *****************************H H H H H******************************* */

/* Doc: fe$run_ABAQUS_analysis

   Abstract:
   	This macro executes analysis using ABAQUS.

   Arguments:
       int    host            i - LOCAL_HOST, REMOTE_HOST, see TPruntp.h

       int    exe_mode        i - INTERACTIVE_MODE, BATCH_MODE, see TPruntp.h

       int    analysis_type   i - Analysis type, see TPruntp.h

       char   node_name[]     i - Remote host name

       char   login[]         i - Login on remote host

       char   passwd[]        i - password on remote host

       char   workdir[]       i - working directory on remote host

       char   exe[]           i - path to executable and executable

   Return Status:
	1	-	SUCCESS

   Examples:

        (1) Local execution

	#include "FEmacincl.h"

	main()
	{	
	int sts ;

            sts = fe$run_ABAQUS_analysis();
	}

        (2) Remote execution

	#include "FEmacincl.h"

	main()
	{	
	int sts ;

            sts = fe$run_ABAQUS_analysis( host = REMOTE_HOST,
                                          node_name = "server_1",
                                          login = "steve",
                                          passwd = "l123456",
                                          workdir = "/usr/steve",
                                          exe = "/usr2/abaqus/abaqus" );
	}

   History:
	Date		Who		Why
	---------	------		--------------------------------
        09-01-93        ckc             Creation

*/

/* *****************************H H H H H******************************* */

extern 	int	FE_run_ABAQUS_analysis();

#omdef 	fe$run_ABAQUS_analysis( host = LOCAL_HOST,
                                exe_mode = INTERACTIVE_MODE,
                                analysis_type = LINEAR_STATIC,
                                node_name,
                                login,
                                passwd,
                                workdir,
                                exe )

        FE_run_ABAQUS_analysis( host, exe_mode, analysis_type, node_name, login,
                                passwd, workdir, exe ) 	

#endomdef

#endif
