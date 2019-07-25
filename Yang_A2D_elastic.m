

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('/Users/yanzhan/Box Sync/COMSOL/ApplicationSample/Elast_2D_Modulus_Strenght/mph_newtest');

model.label('Yang_A2D_elastic.mph');

model.comments(['untitled\n\n']);

model.param.set('xc', '0[m]');
model.param.set('yc', '0[m]');
model.param.set('zc', [num2str(Z),'[m]']);
model.param.set('rc1', [num2str(R1),'[m]']);
model.param.set('rc2', [num2str(R2),'[m]']);
model.param.set('OP', [num2str(OP),'[Pa]']);
model.param.set('E', [num2str(E),'[Pa]']);
model.param.set('nu', num2str(nu));
model.param.set('rho', '2700[kg*m^-3]');
model.param.set('F_angle', [num2str(F_angle),'[deg]']);

model.component.create('comp1', true);

model.component('comp1').geom.create('geom1', 2);

model.result.table.create('tbl1', 'Table');
model.result.table.create('tbl2', 'Table');
model.result.table.create('tbl3', 'Table');


model.component('comp1').geom('geom1').axisymmetric(true);

model.component('comp1').mesh.create('mesh1');

model.component('comp1').geom('geom1').selection.create('csel1', 'CumulativeSelection');
model.component('comp1').geom('geom1').selection('csel1').label('chamber_wall');
model.component('comp1').geom('geom1').create('r1', 'Rectangle');
model.component('comp1').geom('geom1').feature('r1').set('pos', {'0' '-20e3'});
model.component('comp1').geom('geom1').feature('r1').set('size', {'20e3' '20e3'});
model.component('comp1').geom('geom1').create('e1', 'Ellipse');
model.component('comp1').geom('geom1').feature('e1').set('pos', {'0' 'zc'});
model.component('comp1').geom('geom1').feature('e1').set('semiaxes', {'rc1' 'rc2'});
model.component('comp1').geom('geom1').create('dif1', 'Difference');
model.component('comp1').geom('geom1').feature('dif1').selection('input').set({'r1'});
model.component('comp1').geom('geom1').feature('dif1').selection('input2').set({'e1'});
model.component('comp1').geom('geom1').run('fin');
model.component('comp1').geom('geom1').create('sel1', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel1').label('chamber wall');
model.component('comp1').geom('geom1').feature('sel1').selection('selection').init(1);
model.component('comp1').geom('geom1').feature('sel1').selection('selection').set('fin(1)', [6 7]);
model.component('comp1').geom('geom1').feature('sel1').set('contributeto', 'csel1');
model.component('comp1').geom('geom1').run;

model.component('comp1').variable.create('var1');
model.component('comp1').variable('var1').set('FI', '((-solid.sp3+solid.sp1)/2)/((C0/tan(F_angle)+(-solid.sp3-solid.sp1)/2)*sin(F_angle))');
model.component('comp1').variable('var1').set('Apsi', 'acos(3/6^0.5*(-solid.sl33+(solid.sl11+solid.sl22+solid.sl33)/3)/((solid.sl11-(solid.sl11+solid.sl22+solid.sl33)/3)^2+(solid.sl22-(solid.sl11+solid.sl22+solid.sl33)/3)^2+(solid.sl33-(solid.sl11+solid.sl22+solid.sl33)/3)^2)^0.5)*step1(-solid.sl11+solid.sl22)');
model.component('comp1').variable('var1').set('dPtE', 'dPt/coefE(E)');
model.component('comp1').variable('var1').set('Cf', '((-solid.sp3+solid.sp1)/2)/cos(F_angle)-(-solid.sp3-solid.sp1)/2*tan(F_angle)');

model.component('comp1').material.create('mat1', 'Common');

model.component('comp1').cpl.create('intop1', 'Integration');
model.component('comp1').cpl('intop1').selection.set([1]);

model.component('comp1').physics.create('solid', 'SolidMechanics', 'geom1');
model.component('comp1').physics('solid').feature('lemm1').create('iss1', 'InitialStressandStrain', 2);
model.component('comp1').physics('solid').create('gr1', 'Gravity', 2);
model.component('comp1').physics('solid').feature('gr1').selection.set([1]);
model.component('comp1').physics('solid').create('roll1', 'Roller', 1);
model.component('comp1').physics('solid').feature('roll1').selection.set([2 5]);
model.component('comp1').physics('solid').create('bndl1', 'BoundaryLoad', 1);
model.component('comp1').physics('solid').feature('bndl1').selection.set([6 7]);

model.component('comp1').mesh('mesh1').create('ftri1', 'FreeTri');
model.component('comp1').mesh('mesh1').feature('ftri1').create('dis1', 'Distribution');
model.component('comp1').mesh('mesh1').feature('ftri1').create('dis2', 'Distribution');
model.component('comp1').mesh('mesh1').feature('ftri1').create('dis3', 'Distribution');
model.component('comp1').mesh('mesh1').feature('ftri1').feature('dis1').selection.set([4]);
model.component('comp1').mesh('mesh1').feature('ftri1').feature('dis2').selection.set([3 6 7]);
model.component('comp1').mesh('mesh1').feature('ftri1').feature('dis3').selection.set([1]);

model.result.table('tbl1').label('Domain_MC');
model.result.table('tbl1').comments('Surface Integration 1 (if(FI>1,1,0))');
model.result.table('tbl2').label('Wall_tensile');
model.result.table('tbl2').comments('Volume Integration 2 (if(FI>1,1,0))');
model.result.table('tbl3').label('Wall_MC');
model.result.table('tbl3').comments('Line Integration 2 (if(FI>1,1,0))');

model.component('comp1').view('view1').axis.set('xmin', -11281.9482421875);
model.component('comp1').view('view1').axis.set('xmax', 31281.939453125);
model.component('comp1').view('view1').axis.set('ymin', -20963.828125);
model.component('comp1').view('view1').axis.set('ymax', 1361.3472900390625);
model.component('comp1').view('view1').axis.set('abstractviewlratio', -0.5075889825820923);
model.component('comp1').view('view1').axis.set('abstractviewrratio', 0.5075885653495789);
model.component('comp1').view('view1').axis.set('abstractviewbratio', -0.03017314523458481);
model.component('comp1').view('view1').axis.set('abstractviewtratio', 0.04261767491698265);
model.component('comp1').view('view1').axis.set('abstractviewxscale', 34.774417877197266);
model.component('comp1').view('view1').axis.set('abstractviewyscale', 34.774417877197266);

model.component('comp1').material('mat1').propertyGroup('def').set('youngsmodulus', 'Ep(p)');
model.component('comp1').material('mat1').propertyGroup('def').set('poissonsratio', 'nu');
model.component('comp1').material('mat1').propertyGroup('def').set('density', 'rho');

model.component('comp1').cpl('intop1').set('frame', 'material');

model.component('comp1').physics('solid').feature('lemm1').set('E', 'E');
model.component('comp1').physics('solid').feature('lemm1').set('nu', 'nu');
model.component('comp1').physics('solid').feature('lemm1').set('rho', 'rho');
model.component('comp1').physics('solid').feature('lemm1').feature('iss1').set('Sil', {'rho*g_const*z'; '0'; '0'; '0'; 'rho*g_const*z'; '0'; '0'; '0'; 'rho*g_const*z'});
model.component('comp1').physics('solid').feature('bndl1').set('FperArea', {'0'; '0'; 'rho*g_const*z-OP'});
model.component('comp1').physics('solid').feature('bndl1').set('coordinateSystem', 'sys1');

model.component('comp1').mesh('mesh1').feature('size').set('hauto', 4);
model.component('comp1').mesh('mesh1').feature('ftri1').feature('dis1').set('type', 'predefined');
model.component('comp1').mesh('mesh1').feature('ftri1').feature('dis1').set('elemcount', 50);
model.component('comp1').mesh('mesh1').feature('ftri1').feature('dis1').set('elemratio', 10);
model.component('comp1').mesh('mesh1').feature('ftri1').feature('dis2').set('numelem', 20);
model.component('comp1').mesh('mesh1').feature('ftri1').feature('dis3').set('type', 'predefined');
model.component('comp1').mesh('mesh1').feature('ftri1').feature('dis3').set('reverse', true);
model.component('comp1').mesh('mesh1').feature('ftri1').feature('dis3').set('elemcount', 50);
model.component('comp1').mesh('mesh1').feature('ftri1').feature('dis3').set('elemratio', 10);
model.component('comp1').mesh('mesh1').run;

model.component('comp1').physics('solid').feature('lemm1').set('E_mat', 'userdef');
model.component('comp1').physics('solid').feature('lemm1').set('nu_mat', 'userdef');
model.component('comp1').physics('solid').feature('lemm1').set('rho_mat', 'userdef');

model.study.create('std1');
model.study('std1').create('stat', 'Stationary');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('s1', 'Stationary');
model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').feature.remove('fcDef');

model.result.dataset.create('rev1', 'Revolve2D');
model.result.create('pg10', 'PlotGroup1D');
model.result.create('pg11', 'PlotGroup1D');
model.result.create('pg14', 'PlotGroup1D');
model.result.create('pg15', 'PlotGroup2D');
model.result.create('pg16', 'PlotGroup3D');
model.result.create('pg17', 'PlotGroup1D');
model.result('pg10').create('tblp1', 'Table');
model.result('pg11').create('tblp1', 'Table');
model.result('pg14').create('tblp1', 'Table');
model.result('pg15').create('surf1', 'Surface');
model.result('pg15').feature('surf1').create('def', 'Deform');
model.result('pg16').create('surf1', 'Surface');
model.result('pg16').feature('surf1').create('def', 'Deform');
model.result('pg17').create('lngr1', 'LineGraph');
model.result('pg17').feature('lngr1').selection.named('geom1_csel1_bnd');

model.sol('sol1').attach('std1');
model.sol('sol1').runAll;
