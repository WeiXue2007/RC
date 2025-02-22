clear;
clc;

% Set the Record Points and Related Parameters
N_values = [2, 3, 4, 5, 6, 7, 8, 10, 12, 15, 18, 20, 25, 30, 35, 40, 50, 60, 70, 80, 100, 120, 150, 180, 200, 250, 300, 350, 400, 500, 600, 700, 800, 900, 1000];
M_values = [2, 3, 4, 5, 6, 7, 8, 10, 12, 15, 18, 20, 25, 30, 35, 40, 50, 60, 70, 80, 100, 120, 150, 180, 200, 250, 300, 350, 400, 500, 600, 700, 800, 900, 1000, 1200, 1500, 1800, 2000, 2500, 3000, 3500, 4000, 5000, 6000, 7000, 8000, 9000, 10000];
random_numbers = generate_random_numbers_mcm(6 * max(M_values));

% Set the Boundary
Min = [0, 0, 0];
Max = [1.5, 1.44, 0.92];

% Set the Parameters of Sources
numSources = 10;
sourceLocationsX = rand(1, numSources);
sourceLocationsY = rand(1, numSources);
sourceLocationsZ = rand(1, numSources);
sourceMax = [1.5, 1.44, 0.92];
sourceNums = 0;

% Set the Array used to Store Simulation Results
meanFreePaths = struct();
for n = N_values
    for m = M_values
        meanFreePaths.(sprintf('meanFreePaths_%d_%d', n, m)) = [];
    end
end

nums = zeros(1, 3);

% Simulation for each combination of N
for i = 1:length(sourceLocationsX)
    for j = 1:length(sourceLocationsY)
        for k = 1:length(sourceLocationsZ)
            sourceLocation = [sourceLocationsX(i), sourceLocationsY(j), sourceLocationsZ(k)];
            
            local = zeros(1, 3);
            direct = zeros(1, 3);
            lambda = zeros(1, 3);
            
            totalPath = struct();
            for n = N_values
                totalPath.(sprintf('totalPath_%d', n)) = 0;
            end
            
            % Source Location
            local(1) = sourceLocation(1) * sourceMax(1);
            local(2) = sourceLocation(2) * sourceMax(2);
            local(3) = sourceLocation(3) * sourceMax(3);
            
            sourceNums = sourceNums + 1;

            % The mth simulation
            for m = 1:max(M_values)

                % Initial Propagation Direction
                meanSquare = sqrt(random_numbers(6 * (m - 1) + 4) ^ 2 + random_numbers(6 * (m - 1) + 5) ^ 2 + random_numbers(6 * (m - 1) + 6) ^ 2);
                direct(1) = random_numbers(6 * (m - 1) + 4) / meanSquare;
                direct(2) = random_numbers(6 * (m - 1) + 5) / meanSquare;
                direct(3) = random_numbers(6 * (m - 1) + 6) / meanSquare;
                
                totalPath_current = 0;

                for n = 1:max(N_values)
                    
                    lambda(1) = (custom_function(direct(1), Max(1)) - local(1)) / direct(1);
                    lambda(2) = (custom_function(direct(2), Max(2)) - local(2)) / direct(2);
                    lambda(3) = (custom_function(direct(3), Max(3)) - local(3)) / direct(3);

                    index = min_abs(lambda(1), lambda(2), lambda(3));
                    
                    lambaDivDirection = (custom_function(direct(index), Max(index)) - local(index)) / direct(index);

                    % Cumulative Path Length
                    if n > 1
                        totalPath_current = totalPath_current + abs(lambaDivDirection);
                    end

                    if ismember(n, N_values)
                        totalPath.(sprintf('totalPath_%d', n)) = totalPath.(sprintf('totalPath_%d', n)) + totalPath_current;
                    end

                    local(1) = local(1) + lambaDivDirection * direct(1);
                    local(2) = local(2) + lambaDivDirection * direct(2);
                    local(3) = local(3) + lambaDivDirection * direct(3);  
                    
                    nums(index) = nums(index) + 1;

                    % Deal with Reflections
                    direct(index) = -direct(index);
                    
                    meanSquare = sqrt(direct(1)^2 + direct(2)^2 + direct(3)^2);
                    direct = direct / meanSquare;
                    
                    outputStr = sprintf('%d / %d 个源位置；%d/ %d 个传播方向; %d/ %d 次碰撞', sourceNums, 1000, m, max(M_values), n, max(N_values));
                    disp(outputStr);
                end
                
                if ismember(m, M_values)
                    for n = N_values
                        meanFreePaths.(sprintf('meanFreePaths_%d_%d', n, m)) = [meanFreePaths.(sprintf('meanFreePaths_%d_%d', n, m)), totalPath.(sprintf('totalPath_%d', n)) / (m * (n - 1))];
                    end
                end    
            end
        end
    end
end

totalArea = (Max(2) * Max(3)) + (Max(1) * Max(3)) + (Max(1) * Max(2));
meanFreePathThr = 2 * Max(1) * Max(2) * Max(3) / totalArea;

yz_prob = nums(1) * totalArea / (sum(nums) * Max(2) * Max(3));
xz_prob = nums(2) * totalArea / (sum(nums) * Max(1) * Max(3));
xy_prob = nums(3) * totalArea / (sum(nums) * Max(1) * Max(2));
