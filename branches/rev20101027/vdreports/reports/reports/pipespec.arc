    X               �      B      ��   	�   ��        ��   	�   ��        ��        ��   	�   "��   	�   %��   	�   (��   	�   ,��   	�   /��   
   2��   
   6��        9��        <��   
   D��           L� o@FAoBb oC�L�UA60�_Ax0	�{oD adA60��oE
addoF����oGad��PoJad oK�Z� voMdoO��ad��oPad� v oSHAZ��oUdoVA%0��oWadA%0��oXadA%0�oYadA%0�S
A_0�moZadA%0��o[addo\A)0�oo]�UadA)0��o^��addo_A)0���΄�o` adA)0��oa��adA)0�ob�adA)0�'�C��oc adA)0�P�l��od adA)0�y����oe adA)0��of��adA)0��og��adA)0��oh�adA)0��4��oi adA)0�A�]��oj adA)0�j���� ��okadA)0������ol adA)0���܄�om adA)0����on adA)0��+��oo adA)0�:�V��op adA)0�`oq�|adA)0��or��adA)0���̄� ��osadA)0�ׇ��ot adA)0���	��ou ad�'ovFowb��oyFAo{bFo|�	bF�	$o}bF�	$o~b�	&Z�	�	&Z��o�Fo��	&bF�	-o�b��o�Fo��	/bF�	$o�bF�	$o�b�	8A_�	$Z�	8�	/Z�&o�Fo��	8bF�	-o�b�&o�F	o��	AbF
�	$o�bF�	$o�b�	KA_�	$Z�	K�	AZ�ro�F
o��	KbF�	-o�b�ro�Fo��	UbF�	$o�bF�	$o�b�	_Z�	_�	UZ��o�Fo��	_bF�	-o�b��o�Fo��	ib�&o�A0o��-�	m �	ro��	t�	m o�A0o��8�	m �	ro��	��	m o�A0o��C�	� o�A 0o��	�o�A'0o��	�o�A.0o��	�o�A:0o�H�	� Ho�H�	� o�AC0o�HHo�Ho�AO0o�H	Ho�H
o�A[0o�H�	� Ho�H�	� o�Ac0o�Ho�At0o��	��	� o�Ax0o��	Ƅ	� o�A}0oÇ	΄	�o� a)d o�HZ��o�Foɇ	bF�	$o�bF�	$o�b�	&Z�	�	&Z�o�Fo·	&bF�	-o�b�o�Fo҇	/bF�	$o�bF�	$o�b�	8A_�	$Z�	8�	/Z�Oo�Foׇ	8bF�	-o�b�Oo�F	oۇ	AbF
�	$o�bF�	$o�b�	KA_�	$Z�	K�	AZ��o�F
o��	KbF�	-o�b��o�Fo�	UbF�	$o�bF�	$o�b�	_Z�	_�	UZ��o�Fo�	_bF�	-o�b��o�Fo�	ibA0o�-�	m �	ro��	t�	m o�A0o�8�	m �	ro�	��	m o�A0o��C�	� o�A 0o��	�o�A'0o��	�o�A.0o��	�o�A:0o�H�	� Ho�H�	� o�AC0� HH�H�AO0�H	H�H
�A[0�H�	� H�H�	� �Ac0�	H�
At0��	��	� �Ax0��	Ƅ	� �A}0��	΄	կ a(d��F�b �d 
 nfm specif newcomp pby p1 p2 rby r1 r2 sby s1 s2 eby e1 e2 geomstd pagenum Spec name>  pipespec.rpt select
   piping_spec.*, 
   comps.*,
   comps.comp_code aabbcc,
   piping_comp_type.*,
   geom.long_txt geo,
   ctype.long_txt cat
from
   piping_comps comps,
   piping_spec,
   outer piping_codelist geom,
   outer (piping_comp_type, outer piping_codelist ctype)
where
   piping_spec.spec_name= ?      			    and
   comps.spec_no=piping_spec.spec_no  			    and
   (geom.list_num=575 and geom.code_num =comps.geom_std)    and
   (comps.comp_code=piping_comp_type.comp_code and
   comps.short_code=piping_comp_type.comp_shcode)           and
   (ctype.list_num=422 and ctype.code_num=piping_comp_type.comp_rptcat)
order by
   comp_rptcat,
   aabbcc,
   size_g_low,
   size_r_low,
   opt_code
 comp_rptcat aabbcc size_g_low size_r_low opt_code Spec  :  spec_name -- PIPING COMPONENT LIST -- Page <<    DATE:  Comp   Size 1    Size 2    Opt Scode  Family Part        End Prep  Pr Rating   Sched/Thk   End Std Geom Standard    Mtl  Wtf Fc ====== ========= ========= === ====== ====== =========== ========  =========== =========== ======= ================ ==== === == cat ============= =========================================================== | P I P I N G    S P E C I F I C A T I O N    R E P O R T | |                                                         | |                  DATE:  | Specification Name       :  Service Description      :  serv_descr Components Table         :  spec_no ##& Generic Material Type    :  d_mtl_descr Default Fluid            :  d_flcode Bend Table               :  chgdir_tblno Branch Table             :  branch_tblno Adapter Table            :  adaptr_tblno Pipe Comp Code           :  dflt_pipe Conc Reducer Comp Code   :  dflt_conred Ecc Reducer Comp Code    :  dflt_eccred End Compatabilty Table   :  compat_tblno Min Pipe Length Table    :  minlen_tblno Default Gasket Thickness :  gask_sep &.&&& " Gasket Gap Table         :  gskgap_tblno Allowable Npd Table      :  npd_tblno Temp/Press Limits Table  :  tp_lim_tblno Materials Data Table     :  mtl_data_tblno Tap Properties Table     :  tap_tblno Wall Thickness Equation  :  wall_thk_eqn Vent/ Drain Assembly     :  vd_assmbly Corrosion Allowance      :  corr_allow General Note 1           :  note_a General Note 2           :  note_b prep_g   prep_r x rating_g rating_r sch_thk_g sch_thk_r end_std_g end_std_r geo ##.# - size_g_high size_r_high ### short_code family_name part_no_prfx <<< material #### wt_fctr fabcat ##                                                                       	  ������ R& ����� w- ��������8 ��������C ��������
           ef              �� 