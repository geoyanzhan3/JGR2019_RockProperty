clear all; close all;

F = 25;

%% TEST 1 DEPTH
% load data
T1C = load(['./matfile/TEST3_Aspect_C0_F',num2str(F),'.mat']);
T1T = load(['./matfile/TEST3_Aspect_T0_F',num2str(F),'.mat']);

nu_list = [0.15,0.25,0.35];
E_list = [5e9,20e9:20e9:80e9];
Aspect_list = [1,2,3,4,5,0,-1,-2];
% gather the data
% allocate data
disp_CMSU_C = zeros([length(nu_list), length(Aspect_list), length(E_list)]);
over_CMSU_C = zeros([length(nu_list), length(Aspect_list), length(E_list)]);
cfva_CMSU_C = zeros([length(nu_list), length(Aspect_list), length(E_list)]);
disp_CMSU_T = zeros([length(nu_list), length(Aspect_list), length(E_list)]);
over_CMSU_T = zeros([length(nu_list), length(Aspect_list), length(E_list)]);
cfva_CMSU_T = zeros([length(nu_list), length(Aspect_list), length(E_list)]);


for testNu = 1:length(nu_list)
    for testA = 1:length(Aspect_list)
        for testE = 1:length(E_list)
            
            % Young's Modulus
            E = E_list(testE);
            % Poisson's ratio
            nu = nu_list(testNu);
            % Aspect ratio
            Asp = Aspect_list(testA);
            % field name
            field_name = ['A',num2str(testA),'E',num2str(testE),'nu',num2str(testNu)];
            
            % Coulom failure
            % CMSU
            disp_CMSU_C(testNu, testA, testE) = max(T1C.TEST_E.(field_name).w);
            % overpressure
            op_last = T1C.TEST_E.(field_name).OP(T1C.TEST_E.(field_name).OP>0);
            % cohesion
            cf_last = T1C.TEST_E.(field_name).RF(T1C.TEST_E.(field_name).OP>0);
            % Overpressure all
            over_CMSU_C(testNu, testA, testE) = op_last(end);
            % Cohesion all
            cfva_CMSU_C(testNu, testA, testE) = cf_last(end);
            
            % Tensile failure
            % CMSU
            disp_CMSU_T(testNu, testA, testE) = max(T1T.TEST_E.(field_name).w);
            % overpressure
            op_last = T1T.TEST_E.(field_name).OP(T1T.TEST_E.(field_name).OP>0);
            % cohesion
            cf_last = T1T.TEST_E.(field_name).RF(T1T.TEST_E.(field_name).OP>0);
            % Overpressure all
            over_CMSU_T(testNu, testA, testE) = op_last(end);
            % Cohesion all
            cfva_CMSU_T(testNu, testA, testE) = cf_last(end);
            
            
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
        for testA = 1:length(Aspect_list)
            
            % Maximum displacement CMSU
            CMSU_C = disp_CMSU_C(testNu, testA, testE);
            CMSU_T = disp_CMSU_T(testNu, testA, testE);
            
            % CMSU reference
            CMSU_C_ref = disp_CMSU_C(testNu, testA, 1);
            CMSU_T_ref = disp_CMSU_T(testNu, testA, 1);
            
            % normalized CMSU
            CMSU_C_n = CMSU_C/CMSU_C_ref;
            CMSU_T_n = CMSU_T/CMSU_T_ref;
            
            % Overpressure
            OPC = over_CMSU_C(testNu, testA, testE);
            OPT = over_CMSU_T(testNu, testA, testE);
            
            % Overpressure reference
            OPC_ref = over_CMSU_C(testNu, testA, 1);
            OPT_ref = over_CMSU_T(testNu, testA, 1);
            
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
            cmsu_point = plot(CMSU_p, Aspect_list(testA));
            hold on;
            cmsu_point.Marker = MarkerStyle{testNu};
            cmsu_point.MarkerEdgeColor = cmap(testE, :);
            cmsu_point.MarkerSize = 5;
            if CMSU_C > CMSU_T
                cmsu_point.MarkerFaceColor = cmap(testE, :);
            end
            %             xlim([-0.1, 1.1]);
            ylim([-3, 6]);
            xlabel('CMSU [m]');
            ylabel('R_1/R_2');
            set(gca,'FontSize',8);
            
%             % plot normalized DISP
%             subplot(2,2,3);
%             cmsu_point = plot(CMSU_pn, Aspect_list(testA));
%             hold on;
%             cmsu_point.Marker = MarkerStyle{testNu};
%             cmsu_point.MarkerEdgeColor = cmap(testE, :);
%             cmsu_point.MarkerSize = 8;
%             if CMSU_C > CMSU_T
%                 cmsu_point.MarkerFaceColor = cmap(testE, :);
%             end
%             xlim([0, 1.2]);
%             ylim([-3, 6]);
%             xlabel('CMSU / CMSU(E=5GPa)');
%             ylabel('R_1/R_2');
%             set(gca,'FontSize',13);
%             
            
            % plot OVERPRESSURE
            subplot(1,2,2);
            cmsu_point = plot(OP_p/1e6, Aspect_list(testA));
            hold on;
            cmsu_point.Marker = MarkerStyle{testNu};
            cmsu_point.MarkerEdgeColor = cmap(testE, :);
            cmsu_point.MarkerSize = 5;
            if CMSU_C > CMSU_T
                cmsu_point.MarkerFaceColor = cmap(testE, :);
            end
%             xlim([0.6, 2.5]);
            ylim([-3, 6]);
            xlabel('Overpressure [MPa]');
            ylabel('R_1/R_2');
            set(gca,'FontSize',8);
            
%             % plot normalized OVERPRESSURE
%             subplot(2,2,4);
%             cmsu_point = plot(OP_pn, Aspect_list(testA));
%             hold on;
%             cmsu_point.Marker = MarkerStyle{testNu};
%             cmsu_point.MarkerEdgeColor = cmap(testE, :);
%             cmsu_point.MarkerSize = 8;
%             if CMSU_C > CMSU_T
%                 cmsu_point.MarkerFaceColor = cmap(testE, :);
%             end
%             xlim([0.5, 4]);
%             ylim([-3, 6]);
%             xlabel('OP / OP(E=5GPa)');
%             ylabel('R_1/R_2');
%             set(gca,'FontSize',13);
            
            
        end
    end
end


h = gcf;
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,['./plots/Aspect_Enuall_F',num2str(F)],'-dpdf','-r0');
% close gcf;
