%% load COMSOL start (v5.3)
run /Applications/COMSOL54/Multiphysics/mli/mphstart.m


%% calculate th C0 and T0
clear all; close all;

E = 75;
phi = 20 / 180 * pi;
UCS = 2.28 + 4.1089 * E;
C0 = UCS*(1-sin(phi))/2/cos(phi);
T0 = UCS / 10;

%% Diagram
clear all; close all;

% allocate structure
TEST_E = struct();

% import COMSOL modul
import com.comsol.model.*
import com.comsol.model.util.*

% initial parameters
nu = 0.25;
F_angle = 25;

% parameter list
E_list = [5e9,20e9:20e9:80e9];
Z_list = [-9e3:2e3:-1e3];
R1_list = [0.5e3,1.0e3,1.5e3,2.0e3,2.5e3];
Aspect_list = [3,2,1/3,1/2];
% Coulomb
F_type = 'Cf';
TEST_diagram;
save TEST_Diagram_C0 TEST_E;
clear TEST_E;
% tensile
F_type = 'solid.sp1';
TEST_diagram;
save TEST_Diagram_T0 TEST_E;
clear TEST_E;

%% start script TEST-1 Depth (m)
clear all; close all;

% import COMSOL modul
import com.comsol.model.*
import com.comsol.model.util.*

% initial parameters
Z = -3000;
R1 = 1500;
R2 = R1/3;
E = 75e9;
nu = 0.25;
% F_angle = 25;
F_angle = 35;

nu_list = [0.15,0.25,0.35];
E_list = [5e9,20e9:20e9:80e9];
Z_list = [-9e3:2e3:-1e3];

%%%% TEST-1 Depth (m)
% type of failure = Coulomb
F_angle = 15;
F_type = 'Cf';
TEST_depth;
save TEST1_Depth_C0_F15 TEST_E;
clear TEST_E;
F_type = 'solid.sp1';
TEST_depth;
save TEST1_Depth_T0_F15 TEST_E;
clear TEST_E;

F_angle = 25;
F_type = 'Cf';
TEST_depth;
save TEST1_Depth_C0_F25 TEST_E;
clear TEST_E;
F_type = 'solid.sp1';
TEST_depth;
save TEST1_Depth_T0_F25_new TEST_E;
clear TEST_E;

F_angle = 35;
F_type = 'Cf';
TEST_depth;
save TEST1_Depth_C0_F35 TEST_E;
clear TEST_E;
F_type = 'solid.sp1';
TEST_depth;
save TEST1_Depth_T0_F35 TEST_E;
clear TEST_E;



%% start script TEST-2 Size (m)
clear all; close all;

% import COMSOL modul
import com.comsol.model.*
import com.comsol.model.util.*
% initial parameters
Z = -3000;
nu_list = [0.15,0.25,0.35];
E_list = [5e9,20e9:20e9:80e9];

% radius
R1_list = [0.5e3,1.0e3,1.5e3,2.0e3,2.5e3];


%% TEST-2 Radius (m)
% type of failure = Coulomb
F_angle = 15;
F_type = 'Cf';
TEST_radius;
save TEST2_Radius_C0_F15 TEST_E;
clear TEST_E;
F_type = 'solid.sp1';
TEST_radius;
save TEST2_Radius_T0_F15 TEST_E;
clear TEST_E;

F_angle = 25;
F_type = 'Cf';
TEST_radius;
save TEST2_Radius_C0_F25 TEST_E;
clear TEST_E;
F_angle = 25;
F_type = 'solid.sp1';
TEST_radius;
save TEST2_Radius_T0_F25_new TEST_E;
clear TEST_E;

F_angle = 35;
F_type = 'Cf';
TEST_radius;
save TEST2_Radius_C0_F35 TEST_E;
clear TEST_E;
F_type = 'solid.sp1';
TEST_radius;
save TEST2_Radius_T0_F35 TEST_E;
clear TEST_E;

%% start TEST-3 apesct ratio

% initial parameters
Z = -3000;
nu_list = [0.15,0.25,0.35];
E_list = [5e9,20e9:20e9:80e9];

% radius
Aspect_list = [1,2,3,4,5,1/2,1/3,1/4];

%%%% TEST-3 Aspect ratio
F_angle = 15;
F_type = 'Cf';
TEST_aspect;
save TEST3_Aspect_C0_F15 TEST_E;
clear TEST_E;
F_type = 'solid.sp1';
TEST_aspect;
save TEST3_Aspect_T0_F15 TEST_E;
clear TEST_E;

F_angle = 25;
F_type = 'Cf';
TEST_aspect;
save TEST3_Aspect_C0_F25 TEST_E;
clear TEST_E;
F_type = 'solid.sp1';
TEST_aspect;
save TEST1_Aspect_T0_F25_new TEST_E;
clear TEST_E;

F_angle = 35;
F_type = 'Cf';
TEST_aspect;
save TEST3_Aspect_C0_F35 TEST_E;
clear TEST_E;
F_type = 'solid.sp1';
TEST_aspect;
save TEST3_Aspect_T0_F35 TEST_E;
clear TEST_E;

