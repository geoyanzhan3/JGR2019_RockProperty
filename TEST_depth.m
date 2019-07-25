%%%% TEST-1 Depth (m)
% allocate structure
TEST_E = struct();
for testNu = 1:length(nu_list)
    for testZ = 1:length(Z_list)
        for testE = 1:length(E_list)
            
            % parameters
            % Young's Modulus
            E = E_list(testE);
            % Poisson's ratio
            nu = nu_list(testNu);
            % rock strength
            C0 = E/1e3;
            T0 = C0/2.5;
            %T0 = 0;
            
            % target failure 
            switch F_type 
                case 'Cf'
                    target = C0;
                case 'solid.sp1'
                    target = T0;
            end
            
            % tolerance of the cohesion
            tolerance = 0.05*target;
            %tolerance=0.1e6;
            
            % Depth
            Z = Z_list(testZ);
            
            % field name
            field_name = ['Z',num2str(testZ),'E',num2str(testE),'nu',num2str(testNu)];
            
            % initial overpressure
            OP = 50e6;
            % Search_radius
            Search_radius = OP;
            
            % print status
            disp(['Start Z = ',num2str(Z/1e3),', E = ',num2str(E/1e9),', nu = ', num2str(nu)])
            disp(['Failure type = ', F_type,' ,target = ',num2str(target/1e6)]);
            
            % Find CMSU
            CMSU;
            
            % storing INFO
            TEST_E.(field_name).OP = OP_hist;
            TEST_E.(field_name).RF = RF_hist;
            TEST_E.(field_name).u = u;
            TEST_E.(field_name).w = w;
            
        end
    end
end