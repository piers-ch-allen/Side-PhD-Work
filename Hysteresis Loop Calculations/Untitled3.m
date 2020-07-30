datafile{1,1} = 'cartSub1 03162018 040517.dat';
datafile{2,1} = 'cartSub1 03162018 041305.dat';
datafile{3,1} = 'cartSub2 03162018 041523.dat';
datafile{4,1} = 'cartSub3 03162018 094053.dat';
datafile{5,1} = 'cartSub4 03162018 041745.dat';
datafile{6,1} = 'cartSub5 03162018 041824.dat';
datafile{7,1} = 'cartSub6 03162018 041844.dat';
datafile{8,1} = 'cartSub7 03162018 041906.dat';
datafile{9,1} = 'cartSub8 03162018 041927.dat';
datafile{10,1} = 'cartSub9 03162018 041949.dat';
datafile{11,1} = 'cartSub10 03162018 042012.dat';
datafile{12,1} = 'cartSub11 03162018 042037.dat';

datafile{1,1} = 'ca-boSub1 03162018 100730.dat';
datafile{2,1} = 'ca-boSub2 03162018 100951.dat';
datafile{3,1} = 'ca-boSub3 03162018 101112.dat';
datafile{4,1} = 'ca-boSub4 03162018 101218.dat';
datafile{5,1} = 'ca-boSub5 03162018 101256.dat';
datafile{6,1} = 'ca-boSub6 03162018 101317.dat';
datafile{7,1} = 'ca-boSub7 03162018 101338.dat';
datafile{8,1} = 'ca-boSub8 03162018 101359.dat';
datafile{9,1} = 'ca-boSub9 03162018 101421.dat';
datafile{10,1} = 'ca-boSub10 03162018 101445.dat';
datafile{11,1} = 'ca-boSub11 03162018 101510.dat';

datafile{1,1} = 'RHH214Anterior_cartilageSub1.dat';
datafile{2,1} = 'RHH214Anterior_cartilageSub2.dat';
datafile{3,1} = 'RHH214Anterior_cartilageSub3.dat';
datafile{4,1} = 'RHH214Anterior_cartilageSub4.dat';
datafile{5,1} = 'RHH214Anterior_cartilageSub5.dat';
datafile{6,1} = 'RHH214Anterior_cartilageSub6.dat';
datafile{7,1} = 'RHH214Anterior_cartilageSub7.dat';
datafile{8,1} = 'RHH214Anterior_cartilageSub8.dat';
datafile{9,1} = 'RHH214Anterior_cartilageSub9.dat';
datafile{10,1} = 'RHH214Anterior_cartilageSub10.dat';
datafile{11,1} = 'RHH214Anterior_cartilageSub11.dat';
datafile{12,1} = 'RHH214Anterior_cartilageSub12.dat';

datafile{1,1} = 'RHH238Anterior_boneSub1 03162018 102430.dat';
datafile{2,1} = 'RHH238Anterior_boneSub2 03162018 102647.dat';
datafile{3,1} = 'RHH238Anterior_boneSub3 03162018 102807.dat';
datafile{4,1} = 'RHH238Anterior_boneSub4 03162018 102912.dat';
datafile{5,1} = 'RHH238Anterior_boneSub5 03162018 102951.dat';
datafile{6,1} = 'RHH238Anterior_boneSub6 03162018 103011.dat';
datafile{7,1} = 'RHH238Anterior_boneSub7 03162018 103034.dat';
datafile{8,1} = 'RHH238Anterior_boneSub8 03162018 103055.dat';
datafile{9,1} = 'RHH238Anterior_boneSub9 03162018 103117.dat';
datafile{10,1} = 'RHH238Anterior_boneSub10 03162018 103140.dat';
datafile{11,1} = 'RHH238Anterior_boneSub11 03162018 103206.dat';

answers = zeros(12,3);
%3 : 10
for i = 3:10
    try
        [a,b,c] = HysteresisCalc(datafile{i,1},0);
        answers(i,1:3) = [a,b,c];
        a = i
        clear a b c
    catch
        warning('Problem using function.  Assigning a value of 0.');
        answers(i,1:3) = [10,10,10];
    end
end
clear i