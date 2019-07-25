%% load COMSOL start (v5.3)
run /Applications/COMSOL53/Multiphysics/mli/mphstart.m

%% start calculation
clear all; close all;

Z = -3000;
R1 = 1500;
R2 = 500;
OP = 50e6;
E = 40e9;
nu = 0.25;
F_angle = 25;

time_list = [1e0,1e1,1e2,1e3,1e4,1e5];
Nu_list = [2e15,2e17,2e19,2e21];
E_list = [5e9,20e9:20e9:80e9];

TEST_VE1 = struct();

for testTime = 1:length(time_list)
    for testNu = 1:length(Nu_list)
        for testE = 1:length(E_list)
            
            % the ending day
            t_end = time_list(testTime);
            % day interval
            t_inv = t_end / 50;
            % viscosity
            Nu = Nu_list(testNu);
            % Young's Modulus
            E = E_list(testE);
            
            % field name of the structure
            fieldname = ['t',num2str(testTime),'Nu',num2str(testNu),'E',num2str(testE)];
            disp(['t = ',num2str(t_end),', Nu = ',num2str(log(Nu/2)/log(10)),', E = ',num2str(E/1e9),' start']);
            
            import com.comsol.model.*
            import com.comsol.model.util.*
            
            model = ModelUtil.create('Model');
            
            model.modelPath('/Users/yanzhan/Box Sync/COMSOL/ApplicationSample/Elast_2D_Modulus_Strenght/mph_newtest');
            
            model.label('DelNegro_2D_VE.mph');
            
            model.comments(['DelNegro 2D VE 05\n\nuntitled\n\n']);
            
            model.param.set('zc', [num2str(Z),'[m]']);
            model.param.set('rc1', [num2str(R1),'[m]']);
            model.param.set('rc2', [num2str(R2),'[m]']);
            model.param.set('OP', [num2str(OP),'[Pa]']);
            model.param.set('E', [num2str(E),'[Pa]']);
            model.param.set('nu', num2str(nu));
            model.param.set('Nu', [num2str(Nu),'[Pa*s]'], 'Viscosity');
            model.param.set('F_angle', [num2str(F_angle),'[deg]']);
            
            
            model.param.set('rho', '2700[kg/m^3]', 'rock');
            model.param.set('G0', 'E/(2*(1+nu))', 'Shear');
            model.param.set('K', 'E/(3*(1-2*nu))', 'Bulk');
            model.param.set('mu0', '0.5', 'Fractional');
            model.param.set('mu1', '0.5', 'Fractional');
            model.param.set('tau0', 'Nu/(G0*mu0)');
            model.param.set('tau1', '(((3*K)+G0)/(3*K+G0*mu0))*tau0');
            model.param.set('tau2', 'tau0/mu0', 'Viscoelastic');
            
            model.component.create('comp1', false);
            
            model.component('comp1').geom.create('geom1', 2);
            model.component('comp1').geom('geom1').axisymmetric(true);
            
            model.component('comp1').mesh.create('mesh1');
            
            model.component('comp1').geom('geom1').repairTolType('relative');
            model.component('comp1').geom('geom1').create('r1', 'Rectangle');
            model.component('comp1').geom('geom1').feature('r1').set('pos', {'0' '-30 [km]'});
            model.component('comp1').geom('geom1').feature('r1').set('size', {'50 [km]' '30 [km]'});
            model.component('comp1').geom('geom1').create('e1', 'Ellipse');
            model.component('comp1').geom('geom1').feature('e1').set('pos', {'0' 'zc'});
            model.component('comp1').geom('geom1').feature('e1').set('semiaxes', {'rc1' 'rc2'});
            model.component('comp1').geom('geom1').create('dif1', 'Difference');
            model.component('comp1').geom('geom1').feature('dif1').selection('input').set({'r1'});
            model.component('comp1').geom('geom1').feature('dif1').selection('input2').set({'e1'});
            model.component('comp1').geom('geom1').feature('fin').set('repairtoltype', 'relative');
            model.component('comp1').geom('geom1').run;
            
            model.component('comp1').variable.create('var1');
            model.component('comp1').variable('var1').set('Cf', '((-solid.sp3+solid.sp1)/2)/cos(F_angle)-(-solid.sp3-solid.sp1)/2*tan(F_angle)');
            
            model.view.create('view2', 3);
            
            model.component('comp1').physics.create('solid', 'SolidMechanics', 'geom1');
            model.component('comp1').physics('solid').feature('lemm1').create('vis1', 'Viscoelasticity', 2);
            model.component('comp1').physics('solid').feature('lemm1').create('iss1', 'InitialStressandStrain', 2);
            model.component('comp1').physics('solid').create('roll1', 'Roller', 1);
            model.component('comp1').physics('solid').feature('roll1').selection.set([2 5]);
            model.component('comp1').physics('solid').create('bndl1', 'BoundaryLoad', 1);
            model.component('comp1').physics('solid').feature('bndl1').selection.set([6 7]);
            model.component('comp1').physics('solid').create('gr1', 'Gravity', 2);
            model.component('comp1').physics('solid').feature('gr1').selection.set([1]);
            
            model.component('comp1').mesh('mesh1').autoMeshSize(3);
            
            model.capeopen.label('Thermodynamics Package');
            
            model.component('comp1').physics('solid').prop('ShapeProperty').set('order_displacement', 2);
            model.component('comp1').physics('solid').feature('lemm1').set('IsotropicOption', 'KG');
            model.component('comp1').physics('solid').feature('lemm1').set('K', 'K');
            model.component('comp1').physics('solid').feature('lemm1').set('G', 'G0*mu0');
            model.component('comp1').physics('solid').feature('lemm1').set('rho', 'rho');
            model.component('comp1').physics('solid').feature('lemm1').feature('vis1').set('Gvm', 'G0*mu0');
            model.component('comp1').physics('solid').feature('lemm1').feature('vis1').set('tauvm', 'tau1');
            model.component('comp1').physics('solid').feature('lemm1').feature('iss1').set('Sil', {'rho*g_const*z'; '0'; '0'; '0'; 'rho*g_const*z'; '0'; '0'; '0'; 'rho*g_const*z'});
            model.component('comp1').physics('solid').feature('bndl1').set('FperArea', {'0'; '0'; ['-OP/(',num2str(t_end),'*24*3600[s])*t+rho*g_const*z']});
            model.component('comp1').physics('solid').feature('bndl1').set('coordinateSystem', 'sys1');
            model.component('comp1').physics('solid').feature('lemm1').set('K_mat', 'userdef');
            model.component('comp1').physics('solid').feature('lemm1').set('G_mat', 'userdef');
            model.component('comp1').physics('solid').feature('lemm1').set('rho_mat', 'userdef');
            
            model.study.create('std1');
            model.study('std1').create('time', 'Transient');
            
            model.sol.create('sol1');
            model.sol('sol1').study('std1');
            model.sol('sol1').attach('std1');
            model.sol('sol1').create('st1', 'StudyStep');
            model.sol('sol1').create('v1', 'Variables');
            model.sol('sol1').create('t1', 'Time');
            model.sol('sol1').feature('t1').create('fc1', 'FullyCoupled');
            model.sol('sol1').feature('t1').feature.remove('fcDef');
            
            model.result.dataset.create('rev1', 'Revolve2D');
            model.result.create('pg1', 'PlotGroup2D');
            model.result.create('pg2', 'PlotGroup3D');
            model.result.create('pg3', 'PlotGroup1D');
            model.result('pg1').create('surf1', 'Surface');
            model.result('pg2').create('surf1', 'Surface');
            model.result('pg2').feature('surf1').create('def', 'Deform');
            model.result('pg3').create('lngr1', 'LineGraph');
            model.result('pg3').feature('lngr1').selection.set([4]);
            
            model.study('std1').feature('time').set('tlist', ['range(0,',num2str(t_inv),'*24*3600,',num2str(t_end),'*24*3600)']);
            
            model.sol('sol1').attach('std1');
            model.sol('sol1').runAll;
            
            % get LAST surface deformation
            % [pX, pY, pZ] = meshgrid(0:0.1e3:10e3,0,0);
            % p = [pX(:)';pZ(:)'];
            % [u,v,w] = mphinterp(model,{'u','v','w'},'coord',p, 't', 0);
            
            % get data
            % time array
            time = [0:t_inv:t_end]*24*3600;
            % calculate failure
            failure = mpheval(model,{'Cf','solid.sp1'},'Edim','boundary','Selection',[6 7], 't', time);
            % coordinate
            p0 = [0;0];
            % maximum w
            w0 = mphinterp(model,{'w'},'coord',p0, 't', time);
            
            TEST_VE1.(fieldname).t = time;
            TEST_VE1.(fieldname).w0 = w0;
            TEST_VE1.(fieldname).failure = failure;
            
        end
    end
end

save ./matfile/TEST_VE5 TEST_VE1;

%% PLOT data



