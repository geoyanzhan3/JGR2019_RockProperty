clear all; close all;

F = 25;

%% TEST 2 RADIUS
% load data
T1C = load(['./matfile/TEST2_Radius_C0_F',num2str(F),'.mat']);
T1T = load(['./matfile/TEST2_Radius_T0_F',num2str(F),'.mat']);

nu_list = [0.15,0.25,0.35];
E_list = [5e9,20e9:20e9:80e9];
R1_list = [0.5e3,1.0e3,1.5e3,2.0e3,2.5e3];
% gather the data
% allocate data
disp_CMSU_C = zeros([length(nu_list), length(R1_list), length(E_list)]);
over_CMSU_C = zeros([length(nu_list), length(R1_list), length(E_list)]);
cfva_CMSU_C = zeros([length(nu_list), length(R1_list), length(E_list)]);
disp_CMSU_T = zeros([length(nu_list), length(R1_list), length(E_list)]);
over_CMSU_T = zeros([length(nu_list), length(R1_list), length(E_list)]);
cfva_CMSU_T = zeros([length(nu_list), length(R1_list), length(E_list)]);


for testNu = 1:length(nu_list)
    for testR = 1:length(R1_list)
        for testE = 1:length(E_list)
            
            % Young's Modulus
            E = E_list(testE);
            % Poisson's ratio
            nu = nu_list(testNu);
            % Radius
            R1 = R1_list(testR);
            R2 = R1/3;
            % field name
            field_name = ['R',num2str(testR),'E',num2str(testE),'nu',num2str(testNu)];
            
            % Coulom failure
            % CMSU
            disp_CMSU_C(testNu, testR, testE) = max(T1C.TEST_E.(field_name).w);
            % overpressure
            op_last = T1C.TEST_E.(field_name).OP(T1C.TEST_E.(field_name).OP>0);
            % cohesion
            cf_last = T1C.TEST_E.(field_name).RF(T1C.TEST_E.(field_name).OP>0);
            % Overpressure all
            over_CMSU_C(testNu, testR, testE) = op_last(end);
            % Cohesion all
            cfva_CMSU_C(testNu, testR, testE) = cf_last(end);
                        
            % Tensile failure
            % CMSU
            disp_CMSU_T(testNu, testR, testE) = max(T1T.TEST_E.(field_name).w);
            % overpressure
            op_last = T1T.TEST_E.(field_name).OP(T1T.TEST_E.(field_name).OP>0);
            % cohesion
            cf_last = T1T.TEST_E.(field_name).RF(T1T.TEST_E.(field_name).OP>0);
            % Overpressure all
            over_CMSU_T(testNu, testR, testE) = op_last(end);
            % Cohesion all
            cfva_CMSU_T(testNu, testR, testE) = cf_last(end);
            
            
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
        for testR = 1:length(R1_list)
            
            % Maximum displacement CMSU
            CMSU_C = disp_CMSU_C(testNu, testR, testE);
            CMSU_T = disp_CMSU_T(testNu, testR, testE);
            
            % CMSU reference
            CMSU_C_ref = disp_CMSU_C(testNu, testR, 1);
            CMSU_T_ref = disp_CMSU_T(testNu, testR, 1);
            
            % normalized CMSU
            CMSU_C_n = CMSU_C/CMSU_C_ref;
            CMSU_T_n = CMSU_T/CMSU_T_ref;
            
            % Overpressure
            OPC = over_CMSU_C(testNu, testR, testE);
            OPT = over_CMSU_T(testNu, testR, testE);
            
            % Overpressure reference
            OPC_ref = over_CMSU_C(testNu, testR, 1);
            OPT_ref = over_CMSU_T(testNu, testR, 1);
            
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
            cmsu_point = plot(CMSU_p, R1_list(testR)/1e3);
            hold on;
            cmsu_point.Marker = MarkerStyle{testNu};
            cmsu_point.MarkerEdgeColor = cmap(testE, :);
            cmsu_point.MarkerSize = 5;
            if CMSU_C > CMSU_T
                cmsu_point.MarkerFaceColor = cmap(testE, :);
            end
            xlim([-1, 10]);
            ylim([0, 3]);
            xlabel('CMSU [m]');
            ylabel('R_1 [km]');
            set(gca,'FontSize',8);
            
%                         % plot normalized DISP
%             subplot(2,2,3);
%             cmsu_point = plot(CMSU_pn, R1_list(testR)/1e3);
%             hold on;
%             cmsu_point.Marker = MarkerStyle{testNu};
%             cmsu_point.MarkerEdgeColor = cmap(testE, :);
%             cmsu_point.MarkerSize = 8;
%             if CMSU_C > CMSU_T
%                 cmsu_point.MarkerFaceColor = cmap(testE, :);
%             end
% %             xlim([-1, 10]);
% %             ylim([0, 3]);
%             xlabel('CMSU / CMSU(E=5GPa)');
%             ylabel('R_1 [km]');
%             set(gca,'FontSize',13);
            
            % plot OVERPRESSURE
            subplot(1,2,2);
            cmsu_point = plot(OP_p/1e6, R1_list(testR)/1e3);
            hold on;
            cmsu_point.Marker = MarkerStyle{testNu};
            cmsu_point.MarkerEdgeColor = cmap(testE, :);
            cmsu_point.MarkerSize = 5;
            if CMSU_C > CMSU_T
                cmsu_point.MarkerFaceColor = cmap(testE, :);
            end
            
%             xlim([-10, 90]);
            ylim([0, 3]);
            xlabel('Overpressure [MPa]');
            ylabel('R_1 [km]');
            set(gca,'FontSize',8);
            
%                         % plot normalized OVERPRESSURE
%             subplot(2,2,4);
%             cmsu_point = plot(OP_pn, R1_list(testR)/1e3);
%             hold on;
%             cmsu_point.Marker = MarkerStyle{testNu};
%             cmsu_point.MarkerEdgeColor = cmap(testE, :);
%             cmsu_point.MarkerSize = 8;
%             if CMSU_C > CMSU_T
%                 cmsu_point.MarkerFaceColor = cmap(testE, :);
%             end
%             
% %             xlim([-10, 90]);
% %             ylim([0, 3]);
%             xlabel('OP / OP(E=5GPa)');
%             ylabel('R_1 [km]');
%             set(gca,'FontSize',13);
            
        end
    end
end

h = gcf;
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,['./plots/Radius_Enuall_F',num2str(F)],'-dpdf','-r0');
% close gcf;

% 
% %% Start Plot vs Young's Modulus
% 
% cmap = flipud(colmap('jet', length(E_list)));
% 
% % plot
% figure(1);
% 
% nu_list = [0.25];
% MarkerStyle = {'o'};
% 
% % MarkerStyle = {'d','o','^'};
% for testNu = 1:length(nu_list)
%     for testE = 1:length(E_list)
%         for testR = 1:length(R1_list)
%             
%             % Maximum displacement CMSU
%             CMSU_C = disp_CMSU_C(testNu, testR, testE);
%             CMSU_T = disp_CMSU_T(testNu, testR, testE);
%             
%             CMSU_C_ref = disp_CMSU_C(testNu, testR, 1);
%             CMSU_T_ref = disp_CMSU_T(testNu, testR, 1);
%             
%             CMSU_C = CMSU_C/CMSU_C_ref;
%             CMSU_T = CMSU_T/CMSU_T_ref;
%             
%             C0F = cfva_CMSU_C(testNu, testR, testE);
%             T0F = cfva_CMSU_T(testNu, testR, testE);
%             
%             % Overpressure
%             OPC = over_CMSU_C(testNu, testR, testE);
%             OPT = over_CMSU_T(testNu, testR, testE);
%             
%             CMSU_p = min(CMSU_C, CMSU_T);
%             
%             % plot DISP
%             subplot(1,2,1);
%             cmsu_point = plot(CMSU_p, E_list(testE)/1e9+testR/5);
%             hold on;
%             cmsu_point.Marker = MarkerStyle{testNu};
%             cmsu_point.MarkerEdgeColor = cmap(testR, :);
%             cmsu_point.MarkerSize = 8;
%             if CMSU_C > CMSU_T
%                 cmsu_point.MarkerFaceColor = cmap(testR, :);
%             end
% %             xlim([-1, 10]);
% %             ylim([0, 3]);
%             xlabel('CMSU [m]');
%             ylabel('R_1 [km]');
%             set(gca,'FontSize',13);
%             
%             % plot OVERPRESSURE
%             subplot(1,2,2);
%             cmsu_point = plot(OPC, E_list(testE)/1e9);
%             hold on;
%             cmsu_point.Marker = MarkerStyle{testNu};
%             cmsu_point.MarkerEdgeColor = cmap(testR, :);
%             cmsu_point.MarkerSize = 8;
%             if CMSU_C > CMSU_T
%                 cmsu_point.MarkerFaceColor = cmap(testR, :);
%             end
%             
% %             xlim([-10, 90]);
% %             ylim([0, 3]);
%             xlabel('Overpressure [MPa]');
%             ylabel('R_1 [km]');
%             set(gca,'FontSize',13);
%             
%         end
%     end
% end
% 
% set(gcf,'position',[607   860   821   323]);
% h = gcf;
% set(h,'Units','Inches');
% pos = get(h,'Position');
% set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(h,['Radius_Enuall_F',num2str(F)],'-dpdf','-r0');
% close gcf;
