clear all; close all;

F = 25;

%% TEST 1 DEPTH
% load data
T1C = load(['./matfile/TEST1_Depth_T0_F',num2str(F),'.mat']);
T1T = load(['./matfile/TEST1_Depth_T0_F',num2str(F),'_new.mat']);

nu_list = [0.15,0.25,0.35];
E_list = [5e9,20e9:20e9:80e9];
Z_list = [-9e3:2e3:-1e3];
% gather the data
% allocate data
disp_CMSU_C = zeros([length(nu_list), length(Z_list), length(E_list)]);
over_CMSU_C = zeros([length(nu_list), length(Z_list), length(E_list)]);
cfva_CMSU_C = zeros([length(nu_list), length(Z_list), length(E_list)]);
disp_CMSU_T = zeros([length(nu_list), length(Z_list), length(E_list)]);
over_CMSU_T = zeros([length(nu_list), length(Z_list), length(E_list)]);
cfva_CMSU_T = zeros([length(nu_list), length(Z_list), length(E_list)]);


for testNu = 1:length(nu_list)
    for testZ = 1:length(Z_list)
        for testE = 1:length(E_list)
            
            % Young's Modulus
            E = E_list(testE);
            % Poisson's ratio
            nu = nu_list(testNu);
            % Depth
            Z = Z_list(testZ);
            % field name
            field_name = ['Z',num2str(testZ),'E',num2str(testE),'nu',num2str(testNu)];
            
            % Coulom failure
            % CMSU
            disp_CMSU_C(testNu, testZ, testE) = max(T1C.TEST_E.(field_name).w);
            % overpressure
            op_last = T1C.TEST_E.(field_name).OP(T1C.TEST_E.(field_name).OP>0);
            % cohesion
            cf_last = T1C.TEST_E.(field_name).RF(T1C.TEST_E.(field_name).OP>0);
            % Overpressure all
            over_CMSU_C(testNu, testZ, testE) = op_last(end);
            % Cohesion all
            cfva_CMSU_C(testNu, testZ, testE) = cf_last(end);
            
            % Tensile failure
            % CMSU
            disp_CMSU_T(testNu, testZ, testE) = max(T1T.TEST_E.(field_name).w);
            % overpressure
            op_last = T1T.TEST_E.(field_name).OP(T1T.TEST_E.(field_name).OP>0);
            % cohesion
            cf_last = T1T.TEST_E.(field_name).RF(T1T.TEST_E.(field_name).OP>0);
            % Overpressure all
            over_CMSU_T(testNu, testZ, testE) = op_last(end);
            % Cohesion all
            cfva_CMSU_T(testNu, testZ, testE) = cf_last(end);
            
            
        end
    end
end


%% Start Plot
cmap = flipud(colmap('jet', length(E_list)));

% plot
figure(1);
set(gcf,'position',[607   860   600   250]);
% nu_list = [0.25];
% MarkerStyle = {'o'};

% Poisson's ratio
nu_list = [0.15, 0.25, 0.35];
MarkerStyle = {'d','o','v'};

for testNu = 1:length(nu_list)
    for testE = 1:length(E_list)
        for testZ = 1:length(Z_list)
            
            % Maximum displacement CMSU
            CMSU_C = disp_CMSU_C(testNu, testZ, testE);
            CMSU_T = disp_CMSU_T(testNu, testZ, testE);
            
            % CMSU reference
            CMSU_C_ref = disp_CMSU_C(testNu, testZ, 1);
            CMSU_T_ref = disp_CMSU_T(testNu, testZ, 1);
            
            % normalized CMSU
            CMSU_C_n = CMSU_C/CMSU_C_ref;
            CMSU_T_n = CMSU_T/CMSU_T_ref;
            
            % Overpressure
            OPC = over_CMSU_C(testNu, testZ, testE);
            OPT = over_CMSU_T(testNu, testZ, testE);
            
            % Overpressure reference
            OPC_ref = over_CMSU_C(testNu, testZ, 1);
            OPT_ref = over_CMSU_T(testNu, testZ, 1);
            
            % normalized Overpressure
            OPC_n = OPC/OPC_ref;
            OPT_n = OPT/OPT_ref;
            
            % which failure happens first
            CMSU_p = min(CMSU_C, CMSU_T);
            OP_p = min(OPC, OPT);
            % normalized
            CMSU_pn = min(CMSU_C_n, CMSU_T_n);
            OP_pn = min(OPC_n, OPT_n);
            
            % plot DISP
            subplot(1,2,1);
            cmsu_point = plot(CMSU_p, Z_list(testZ)/1e3);
            hold on;
            cmsu_point.Marker = MarkerStyle{testNu};
            cmsu_point.MarkerEdgeColor = cmap(testE, :);
            cmsu_point.MarkerSize = 5;
            if CMSU_C > CMSU_T
                cmsu_point.MarkerFaceColor = cmap(testE, :);
            end
            %             xlim([-0.1, 1.1]);
            ylim([-10, 0]);
            xlabel('CMSU [m]');
            ylabel('Depth [km]');
            set(gca,'FontSize',8);
            
            %             % plot normalized DISP
            %             subplot(2,2,3);
            %             cmsu_point = plot(CMSU_pn, Z_list(testZ)/1e3);
            %             hold on;
            %             cmsu_point.Marker = MarkerStyle{testNu};
            %             cmsu_point.MarkerEdgeColor = cmap(testE, :);
            %             cmsu_point.MarkerSize = 8;
            %             if CMSU_C > CMSU_T
            %                 cmsu_point.MarkerFaceColor = cmap(testE, :);
            %             end
            %             %             xlim([-0.1, 1.1]);
            %             %             ylim([-10, 0]);
            %             xlabel('CMSU / CMSU(E=5GPa)');
            %             ylabel('Depth [km]');
            %             set(gca,'FontSize',13);
            
            
            % plot OVERPRESSURE
            subplot(1,2,2);
            cmsu_point = plot(OP_p/1e6, Z_list(testZ)/1e3);
            hold on;
            cmsu_point.Marker = MarkerStyle{testNu};
            cmsu_point.MarkerEdgeColor = cmap(testE, :);
            cmsu_point.MarkerSize = 5;
            if CMSU_C > CMSU_T
                cmsu_point.MarkerFaceColor = cmap(testE, :);
            end
            %             xlim([0.6, 2.5]);
            ylim([-10, 0]);
            xlabel('Overpressure [MPa]');
            ylabel('Depth [km]');
            set(gca,'FontSize',8);
            
            %             % plot normalized OVERPRESSURE
            %             subplot(2,2,4);
            %             cmsu_point = plot(OP_pn, Z_list(testZ)/1e3);
            %             hold on;
            %             cmsu_point.Marker = MarkerStyle{testNu};
            %             cmsu_point.MarkerEdgeColor = cmap(testE, :);
            %             cmsu_point.MarkerSize = 8;
            %             if CMSU_C > CMSU_T
            %                 cmsu_point.MarkerFaceColor = cmap(testE, :);
            %             end
            %             %             xlim([0.6, 2.5]);
            %             %             ylim([-10, 0]);
            %             xlabel('OP / OP(E=5GPa)');
            %             ylabel('Depth [km]');
            %             set(gca,'FontSize',13);
            %
            
        end
    end
end

h = gcf;
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,['./plots/Depth_Enuall_F_new',num2str(F)],'-dpdf','-r0');
% close gcf;
