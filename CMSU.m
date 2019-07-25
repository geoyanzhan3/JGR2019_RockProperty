
% allocated documentation
OP_hist = zeros([10,1]); % overpressure
RF_hist = zeros([10,1]); % rock failure

% search the overpressure for Coulomb failure
i = 1;
% initial Coulomb
% COMSOL model
Yang_A2D_elastic;
% get the maximum failure stress along the chamber
failure = mpheval(model,{F_type},'Edim','boundary','Selection',[6 7]);
RF = max(failure.d1, [], 'omitnan');
% store initial OP CF
OP_hist(i) = OP;
RF_hist(i) = RF;
% print status
disp(['i = ',num2str(i),', OP = ',num2str(OP/1e6),', CF = ',num2str(RF/1e6)]);
% % plot
% subplot(3,1,1);
% plot(i, OP, 'ro-'); hold on;
% subplot(3,1,2);
% plot(i, RF, 'bo-'); hold on;


% if the OP is lower than initial stress
while RF < target
    % increasing the OP
    OP = OP + Search_radius;
    % update iteration
    i = i + 1;
    % Redo calculation with new OP
    % COMSOL model
    Yang_A2D_elastic;
    % get the maximum failure stress along the chamber
    failure = mpheval(model,{F_type},'Edim','boundary','Selection',[6 7]);
    RF = max(failure.d1, [], 'omitnan');
    % store OP CF
    OP_hist(i) = OP;
    RF_hist(i) = RF;
    
    % print status
    disp(['i = ',num2str(i),', OP = ',num2str(OP/1e6),', CF = ',num2str(RF/1e6)]);
%     % plot
%     subplot(3,1,1);
%     plot(i, OP, 'ro-'); hold on;
%     subplot(3,1,2);
%     plot(i, RF, 'bo-'); hold on;
%     
end

% if the OP is larger than initial stress
UP = OP;
DOWN = 0;
MID = (UP + DOWN)/2;
OP = MID;
% update iteration
i = i + 1;
% Redo calculation with new OP
% COMSOL model
Yang_A2D_elastic;
% get the maximum failure stress along the chamber
failure = mpheval(model,{F_type},'Edim','boundary','Selection',[6 7]);
RF = max(failure.d1, [], 'omitnan');
% store OP CF
OP_hist(i) = OP;
RF_hist(i) = RF;
% print status
disp(['i = ',num2str(i),', OP = ',num2str(OP/1e6),', CF = ',num2str(RF/1e6)]);
% % plot
% subplot(3,1,1);
% plot(i, OP, 'ro-'); hold on;
% subplot(3,1,2);
% plot(i, RF, 'bo-'); hold on;

% delayed switch
delayed_switch = -1;

while abs(target - RF) > tolerance && i < 50
    % do while the tolerance does meet
    if target < RF
        % update the OP if failure has happen, decrease OP
        % if last time is also decreasing OP; retain the decreaseing value
        if delayed_switch == -1
            UP = OP;
            MID = (UP + DOWN)/2;
            OP = MID;
        else
            UP = MID;
            MID = (UP + DOWN)/2;
            OP = MID;
        end
        % update iteration
        i = i + 1;
        % Redo calculation with new OP
        % COMSOL model
        Yang_A2D_elastic;
        % get the maximum failure stress along the chamber
        failure = mpheval(model,{F_type},'Edim','boundary','Selection',[6 7]);
        RF = max(failure.d1, [], 'omitnan');
        % store OP CF
        OP_hist(i) = OP;
        RF_hist(i) = RF;
        % update switch
        delayed_switch = -1;
        
    else
        % update the OP if failure has NOT happen, increase OP
        % if last time is also increasing OP; retain the increasing value
        if delayed_switch == +1
            DOWN = OP;
            MID = (UP + DOWN)/2;
            OP = MID;
        else
            DOWN = MID;
            MID = (UP + DOWN)/2;
            OP = MID;
        end
        % update iteration
        i = i + 1;
        % Redo calculation with new OP
        % COMSOL model
        Yang_A2D_elastic;
        % get the maximum failure stress along the chamber
        failure = mpheval(model,{F_type},'Edim','boundary','Selection',[6 7]);
        RF = max(failure.d1, [], 'omitnan');
        % store OP CF
        OP_hist(i) = OP;
        RF_hist(i) = RF;
        % update switch
        delayed_switch = +1;
    end
    
    % print status
    disp(['i = ',num2str(i),', OP = ',num2str(OP/1e6),', CF = ',num2str(RF/1e6)]);
%     % plot
%     subplot(3,1,1);
%     plot(i, OP, 'ro-'); hold on;
%     subplot(3,1,2);
%     plot(i, RF, 'bo-'); hold on;
%     
    
end

%% get LAST surface deformation
[pX, pY, pZ] = meshgrid(0:0.1e3:10e3,0,0);
p = [pX(:)';pZ(:)'];
[u,v,w] = mphinterp(model,{'u','v','w'},'coord',p);


