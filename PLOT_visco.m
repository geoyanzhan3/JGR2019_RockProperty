clear all; close all;

load ./matfile/TEST_VE5.mat;

% physical parameters
Z = -3000;
R1 = 1500;
R2 = 500;
OP = 50e6;
E = 40e9;
nu = 0.25;
Nu = 2e16;
F_angle = 25;

% test list
% % VE4
% time_list = [1e-4,1e-3,1e-2,1e-1,1e0,1e1,1e2,1e3,1e4,1e5,1e6];
% Nu_list = [2e12,2e14,2e16,2e18,2e20];
% E_list = [5e9,20e9:20e9:80e9];
% VE5
time_list = [1e0,1e1,1e2,1e3,1e4,1e5];
Nu_list = [2e15,2e17,2e19,2e21];
E_list = [5e9,20e9:20e9:80e9];

t_CF = zeros(size(time_list));
t_TF = zeros(size(time_list));
CMSU_CF = zeros(size(time_list));
CMSU_TF = zeros(size(time_list));

%% E and Nu lists for plot
% create 2D matrix
[Nu_2D, E_2D] = meshgrid(Nu_list, E_list);
nrow = length(E_list);
ncol = length(Nu_list);
E_1d = E_2D(:);
Nu_1d = Nu_2D(:);
splot_1d = 1:length(E_1d);
splot = reshape(splot_1d, size(E_2D'))';

% load Elastic test for reference
F = 25;
% load data
T1C = load(['./matfile/TEST1_Depth_C0_F',num2str(F),'.mat']);
T1T = load(['./matfile/TEST1_Depth_T0_F',num2str(F),'.mat']);
Z_list = [-9e3:2e3:-1e3];

CMSU_lim = [0 10
    0 2.5
    0 1.2
    0 1
    0 1];

cmp = colmap('jet',length(time_list));

for testE = 1:length(E_list)
    for testNu = 1:length(Nu_list)

        % get elastic model
        % field name
        field_elas = ['Z',num2str(4),'E',num2str(testE),'nu',num2str(2)];
        
        % Coulom failure
        % CMSU
        disp_CMSU_C = max(T1C.TEST_E.(field_elas).w);
        % overpressure
        op_last = T1C.TEST_E.(field_elas).OP(T1C.TEST_E.(field_elas).OP>0);
        % Overpressure all
        over_CMSU_C = op_last(end)/1e6;
        
        % Tensile failure
        % CMSU
        disp_CMSU_T = max(T1T.TEST_E.(field_elas).w);
        % overpressure
        op_last = T1T.TEST_E.(field_elas).OP(T1T.TEST_E.(field_elas).OP>0);
        % Overpressure all
        over_CMSU_T = op_last(end)/1e6;
        
        
        % calculate the relaxing time
        E = E_list(testE);
        Nu = Nu_list(testNu);
        mu0 = 0.5;
        K = E/3/(1-2*nu);
        G0 = E/2/(1-nu);
        tau0 = Nu/(0.5*G0);
        tau1 = (((3*K)+G0)/(3*K+G0*mu0))*tau0;
        tau0d = tau0/24/3600;
        tau1d = tau1/24/3600;
        
        % failure parameters
        C0 = E/1e3;
        T0 = C0/2.5;
        
        figure(1);
        subplot(nrow, ncol, splot(testE,testNu));
        title(['E=',num2str(E/1e9),'GPa,\eta=2E',num2str(log(Nu/2)/log(10)),'Pa*s']);
        hold on;
        for testTime = 1:length(time_list)
            
            % the ending day
            t_end = time_list(testTime);
            % day interval
            t_inv = t_end / 50;
            % field name of the structure
            fieldname = ['t',num2str(testTime),'Nu',num2str(testNu),'E',num2str(testE)];
            
            % time array
            time = [0:t_inv:t_end]*24*3600;
            t_p = time/max(time);
            w_p = TEST_VE1.(fieldname).w0;
            
            % get Coulomb failure
            I_CF_t = find(max(TEST_VE1.(fieldname).failure.d1,[],2) > C0,1);
            I_TF_t = find(max(TEST_VE1.(fieldname).failure.d2,[],2) > T0,1);
            
            t_CF(testTime) = min(time(I_CF_t))/24/3600;
            t_TF(testTime) = min(time(I_TF_t))/24/3600;
            
            CMSU_CF(testTime) = min(w_p(I_CF_t));
            CMSU_TF(testTime) = min(w_p(I_TF_t));
            
            
            
            % plot displacement
            disp_t = plot(t_p, w_p, '--', 'DisplayName', ['50 [MPa/',num2str(t_end),' day]'], 'LineWidth', 1); hold on;
            disp_t.Color = cmp(testTime,:);
            plot(t_p(I_CF_t), w_p(I_CF_t), 'ro', 'DisplayName', 'Coulomb failure', 'MarkerSize', 5); hold on;
            plot(t_p(I_TF_t), w_p(I_TF_t), 'ko', 'DisplayName', 'Tensile failure', 'MarkerSize', 5); hold on;
            
            
            
        end
        
        % set figure 1
        %         xlabel('time / time span');
        %         ylabel('Uplift at center [m]');
        %         legend('Location', 'northwest');
        %         legend('boxoff');
        ybd1 = get(gca,'ylim');
        ylim([0, ybd1(2)]);
        set(gca,'FontSize',8);
        
        %
        %% PLOT overpressure
        figure(2);
        subplot(nrow, ncol, splot(testE,testNu));
        title(['E=',num2str(E/1e9),'GPa,\eta=2E',num2str(log(Nu/2)/log(10)),'Pa*s']);
        hold on;
        % plot
        plot(log(time_list)/log(10), 50./time_list.*t_CF, 'ro', 'DisplayName', 'Coulomb failure', 'MarkerSize', 5);hold on;
        plot(log(time_list)/log(10), 50./time_list.*t_TF, 'ko', 'DisplayName', 'Tensile failure', 'MarkerSize', 5);hold on;
        plot([-0.5,6.5],[over_CMSU_T, over_CMSU_T],'k-', 'LineWidth', 1.5); hold on;
        plot([-0.5,6.5],[over_CMSU_C, over_CMSU_C],'r-', 'LineWidth', 1.5); hold on;
        %         xlabel('log10 time span');
        %         ylabel('Overpressure triggering failure [MPa]');
        %         legend('Location', 'northwest');
        %         legend('boxoff');
        ylim([10, 50]);
        xlim([-0.5, 6.5]);
        set(gca,'FontSize',8);
        
        
        
        %% PLOT CMSU
        
        figure(3);
        subplot(nrow, ncol, splot(testE,testNu));
        title(['E=',num2str(E/1e9),'GPa,\eta=2E',num2str(log(Nu/2)/log(10)),'Pa*s']);
        hold on;
        % plot
        plot(log(time_list)/log(10), CMSU_CF, 'ro', 'DisplayName', 'Coulomb failure', 'MarkerSize', 5);hold on;
        plot(log(time_list)/log(10), CMSU_TF, 'ko', 'DisplayName', 'Tensile failure', 'MarkerSize', 5);hold on;
        plot([-0.5,6.5],[disp_CMSU_T, disp_CMSU_T],'k-', 'LineWidth', 1.5); hold on;
        plot([-0.5,6.5],[disp_CMSU_C, disp_CMSU_C],'r-', 'LineWidth', 1.5); hold on;
        % plot(log(tau0d)/log(10)*ones([1,2]), [min(CMSU_CF), max(CMSU_CF)], 'r-', 'DisplayName', '\tau_0', 'MarkerSize', 8);hold on;
        plot(log(tau1d)/log(10)*ones([1,2]), CMSU_lim(testE,:), 'b-', 'DisplayName', '\tau_1', 'LineWidth', 1.5);hold on;
        %         xlabel('log10 time span');
        %         ylabel('CMSU [m]');
        %         legend('Location', 'northwest');
        %         legend('boxoff');
        ylim(CMSU_lim(testE,:));
        xlim([-0.5, 6.5]);
        set(gca,'FontSize',8);
        
        
    end
end

figure(1);
set(gcf,'Position',[0,0,600,600]);
h = gcf;
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,['./plots/TEST_VE5_disp',num2str(F_angle)],'-dpdf','-r0');

figure(2);
set(gcf,'Position',[0,0,600,600]);
h = gcf;
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,['./plots/TEST_VE5_OP',num2str(F_angle)],'-dpdf','-r0');

figure(3);
set(gcf,'Position',[0,0,600,600]);
h = gcf;
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,['./plots/TEST_VE5_CMSU',num2str(F_angle)],'-dpdf','-r0');

% close all;


%% plot relaxation time
figure(5);
time_list = [1e0,1e1,1e2,1e3,1e4,1e5];
Nu_list = [2e15,2e17,2e19,2e21];
E_list = [5e9,20e9:20e9:80e9];
cmp = colmap('jet',length(E_list));
for testE = 1:length(E_list)
        % calculate the relaxing time
        E = E_list(testE);
        Nu = Nu_list;
        mu0 = 0.5;
        K = E/3/(1-2*nu);
        G0 = E/2/(1-nu);
        tau0 = Nu./(0.5*G0);
        tau1 = (((3*K)+G0)/(3*K+G0*mu0)).*tau0;
        tau0d = tau0/24/3600;
        tau1d = tau1/24/3600;
        
        pl = plot(log10(tau1d), log10(Nu),'*-'); hold on;
        pl.Color = cmp(testE,:);
        t_array = [1,7,31,365,365*10,365*100];
        
        plot(log10(t_array), max(log10(Nu)),'k+'); hold on;
end
set(gca,'FontSize',9);
xlabel('log(time [day])');
ylabel('log(\eta [Pa*s])');

set(gcf,'Position',[0,0,300,250]);
h = gcf;
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,['./plots/RelaxationTime'],'-dpdf','-r0');

