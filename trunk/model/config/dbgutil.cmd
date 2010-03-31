"//-------------- Primary tools (often used) ------------------------------",,

"z Dynamic Loader",EMSdave2,ECdynload,0
"z Load from File",EMSdave2,ECdynload,3

"z get element id",ECpost312,ECpost31,3
"z get feature id",ECpost313,ECpost31,2

"z print feature tree",ECdprtree0,ECdprtree,0
"z undo feature tree",ECdprtree1,ECdprtree,1
"z redo boolean tree",ECrebool0,ECrebool,0
"z print boolean tree",ECrebool1,ECrebool,1
"z undo boolean tree",ECrebool2,ECrebool,2
"z remove macro states",ECrebool3,ECrebool,3

"z check slivers",ECchksliver0,ECchksliver,0
"z display uv space",EMSrlw9,ECdebugout,1
"z show normals",sikidbg2,ECsptloc,1
"z reverse normals",EMSsikidbg1,ECsptloc,2

"z output polyline",ECoutpwgm0,ECoutpwgm,0
"z output polyline 2d",ECoutpwgm1,ECoutpwgm,1
"z output B-spline curve",ECoutpwgm2,ECoutpwgm,2
"z input polyline",ECinpwgm0,ECinpwgm,0
"z input polyline 2d",ECinpwgm1,ECinpwgm,1
"z input B-spline curve",ECinpwgm2,ECinpwgm,2
"z input point",ECinpwgm3,ECinpwgm,3

"z toggle surface intersection data fitting",EMSsunit8,ECdbgsend,8
"z place convex fit curve",EMPCrCnFt,ECfitcur,55,
"z force composite surface/solid",EMS0103,ECmkcompsf,1

"//------------- Secondary tools (rarely used) ----------------------------",,

"Z View Rtree Range",EMSdave11,ECdynload,2
"Z Investigate Edge-Match",EMSRV,ECstitch,1
"Z Reverse Normals",sikidbg1,ECsptloc,2
"Z Toggle Range Box Display",fubbyman,ECdrawrngbx,0
"Z Debug Out",EMSrlw1,ECdebugout,0
"Z Measure Tangency between 2 Surfaces",EMMTnSr,ECtasurfs,1,
"Z Zap msc",sikidbg6,ECdbgsend,2
"Z Zap em msc",sikidbg7,ECdbgsend,3
"Z Debug Send Message",sikidbg0,ECdbgsend,0
"Z Show Boolean ssi",EMSjBk0,ECshowSSI,0
"Z Reset Creator ID",EMSrlw4,ECdebugout,3
"Z Validate Creator ID",EMSrlw9,ECdebugout,4
"Z Valid No Edge Match",EMSsunit2,ECvalid,2
"z fix 3.1 add-remove feature",EMStest2,ECtest,2

"z input curve intersection points",ECinpwcvint0,ECinpwcvint,0

"//------------- Set/Unset internal flags or variables --------------------",,

"z toggle pathway",ECpathway0,ECpathway,0

"Z Keep Fillets and Patches",Janaka0,ECdbgsend,10
"Z Process Interaction Rounding",Aditya,ECdbgsend,19

"z set angle tol",ECpwtol0,ECpwtol,0
"z set post 3.1 behaviour",ECpost310,ECpost31,0
"z unset post 3.1 behaviour",ECpost311,ECpost31,1
"Z Toggle Refinement",EMSsunit11,ECsptloc,11

"//------------- Set/Unset debug flags---------------- --------------------",,

"z set debug level",ECpathway2,ECpathway,3
"z set error log",ECpathway3,ECpathway,4

"Z Graph On",ECtggraph,ECmisc,100
"Z Graph Off",ECtggraph,ECmisc,101
"Z Toggle Debug Jacobian",ECtggraph,ECmisc,102
"Z Toggle Debug Jacobian File",ECtggraph,ECmisc,103

"//------------- Performance measuring commands ---------------------------",,

"z initialize clocks",ECclock0,ECclock,0
"z print clocks",ECclock1,ECclock,1

"//------------- Alpha commands (trial commands) --------------------------",,

"Z Extrude Profile",ECextrude,ECprims,0
"Z Turn Profile",ECturn,ECprims,0
"Z Old Place Skinning Surface",EMScmw1,ECplcsknsf,0,
"Z Old Place Skinning Solid",EMScmw2,ECplcsknsf,1,
"Z Toggle Special Partial Surface Placement",siki120391,ECdbgsend,7
"z adjust curve parameterization",ECcvreparam,ECcvreparam,0

"//------------- API Testing commands ------------------------------------",,

"z test intersect polyline 2d",ECtester0,ECtester,0
"z test intersect curve 2d",ECtester1,ECtester,1
"z test intersect curve - Bspmath",ECtester2,ECtester,2
"z test surface open",ECtester3,ECtester,3
"z test surface open - old",ECtester4,ECtester,4
"z test get top owners",ECtester5,ECtester,5
"z test print/read",ECtester6,ECtester,6
"z test surface rule lines",ECtester7,ECtester,7
"z test surface edge curves",ECtester8,ECtester,8
"z test get tols",ECtester9,ECtester,9
"z test surface geometric quantities",ECtester10,ECtester,10
"z pathway Boolean union",ECpwbool0,ECpwbool,0
"z pathway Boolean difference",ECpwbool1,ECpwbool,1
"z pathway Boolean intersection",ECpwbool2,ECpwbool,2
"z add material -- debug",ECridge99,ECridge,99
"z remove material -- debug",ECridge98,ECridge,98
"Z Get Boundary",EMSgetbdry,ECtest,0
"Z Get Boundary Reduce",EMSnavin1,ECtest,1

"//----------------- Virtually useless commands --------------------------",,

"Z Debug sal",davetst1,ECdbgsal,0
"Z Toggle Taggability",sikidbg5,ECdbgsend,1
"Z Generate Natural Sides between 2 Surfaces",natsides4,ECnatsides,4
"Z Place Associative Parting Lines",EMSaic0,ECconstruct,201
"Z Split ls",EMSsunit4,COimpbnd,2
"Z Debug Out Edge",EMSrlw3,ECdebugout,2
"Z Toggle Associative",ZSK8,ECsptloc,8
"Z Make Loopset",EMSjunk,ECmklps,0
"Z Convert to Envelope",envelope,ECcvigeenv,0
"Z Make Common",EMSsunit0,ECstitch,2
"Z Re-execute Tree",EMSsunit5,ECreex,0
"Z Toggle IGDS EMS Log",EMSpsd2,ECsptloc,3
"Z Toggle IGDS EMS Log",EMSpsd1,ECsptloc,5
"Z Init IGDS EMS Log",EMSpsd23,ECsptloc,6
"Z Show Getrange",EMSpsd111,ECsptloc,4
"Z Toggle intf Write Flag",EMSsunit6,ECintf,3
"Z Toggle sf-sf Intersection Math",EMSsiki998,ECdbgsend,4
"Z Toggle Infinite Plane",EMSsiki997,ECdbgsend,5
"Z Toggle Associative Placement",EMSsiki996,ECdbgsend,6
"Z Round Edge",EMSinasu0,ECround,4
"Z Valid",EMSrlw2,ECvalid,0
"Z Auto Correct",EMSsunit1,ECvalid,1
"Z Toggle Math Routine",Jack1,ECmathtog,0
"Z Toggle Intersection Fixing",EMSnavin3,ECdbgsend,11
"Z Toggle Skip Fixing",EMSnavin4,ECdbgsend,12
"Z Toggle New Stitch",EMSsunit12,ECsptloc,12
"Z Round 2cx1cv Blend",Janaka1,ECdbgsend,13
"Z Round with Blends Only",Janaka2,ECdbgsend,14
"Z Timer Init",sikidbg3,ECtimer,0
"Z Timer Total",sikidbg4,ECtimer,1
"z toggle timer clocks",EMSnavin2,ECdbgsend,9
"Z Blend with Setback Solution",knap0,ECdbgsend,18
"Z Place Cutout",EMPlCt,ECplcutout,0
"z toggle internal debug",EMSdbg15,ECdbgsend,15
"z toggle range support",ECdbg17,ECdbgsend,17
"zgrnuc convert from IGDS",GRCnIGFlMc,COcvigdsige
"zgrnuc convert IGDS cell library",GRCnIGClLb,COcvtclsl
"z make common",EMSsunit0,ECstitch,2
"z toggle infinite plane",EMSsiki997,ECdbgsend,5
"z place solid of projection",EMSprasad,ECplsolproj,84
"z toggle sfint data fit",EMSsunit,ECdbgsend,8
"z fix suppressed nodes",bubba,ECfixsup,0
