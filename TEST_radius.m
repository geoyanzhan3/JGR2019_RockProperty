%%%% TEST-2 Radius (m)
% allocate structure
TEST_E = struct();
for testNu = 1:length(nu_list)
    for testR = 1:length(R1_list)
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
            
            % Radius
            R1 = R1_list(testR);
            R2 = R1/3;
            
            % field name
            field_name = ['R',num2str(testR),'E',num2str(testE),'nu',num2str(testNu)];
            
            % initial overpressure
            OP = 50e6;
            % Search_radius
            Search_radius = OP;
            
            % print status
            disp(['Start R1 = ',num2str(R1/1e3),', E = ',num2str(E/1e9),', nu = ', num2str(nu)])
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