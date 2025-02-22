function random_numbers = generate_random_numbers_mcm(n)    
    a = 7;           
    m = 1e10;        
    
    seed = mod(floor(now * 1e6), m);

    random_numbers = zeros(1, n);
    
    s = seed;
    
    for i = 1:n
        s = mod(a * s, m);
        
        random_numbers(i) = 2 * (s / m) - 1;
    end
end