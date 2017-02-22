close all
clear all

tic;
start = cputime;
start_ = clock;
spot = 100;
strike = 90;
up = 1.10;
down = 0.90;
rate = 4;
num_steps = 10;
price = binomial_pricer(spot, strike, up, down, rate, num_steps, OptionType.PUT, ExerciseType.AMERICAN);
end_ = cputime;
elapsed = toc;
fin = clock;
fprintf('American PUT price : %f\n', price);
fprintf('steps : %d\n', num_steps);
fprintf('TIC TOC: %g\n', elapsed);
fprintf('CPU Time: %g\n', end_ - start);
fprintf('CLOCK: %g\n', etime(fin, start_));
function [price] = binomial_pricer(spot, strike, up, down, rate, num_steps, type, exercise)
% binomial tree pricer
% spot ===> spot price
% strike ===> exercise price
% up ===> the price will get up
% down ====> the price will get down
% rate ===> the rate by month

Rate = 1 + rate/100/12;
prob_up = (Rate - down) / (up - down);
prob_down = 1 - prob_up;

for i=1:num_steps+1
    for j=i:num_steps+1
        stock_price(i,j) = spot*up^(j-i)*down^(i-1); % stock price
    end
end

for i=1:num_steps+1     % pay off for terminal nodes
    if type == OptionType.CALL
        pay_off(i, num_steps+1) = max(stock_price(i, num_steps+1) - strike, 0);
    else 
        pay_off(i, num_steps+1) = max(strike - stock_price(i, num_steps+1), 0);
    end
end

for j=num_steps:-1:1
    for i=1:j
        if exercise == ExerciseType.EUROPEAN
            pay_off(i, j) = 1/Rate*(prob_up*pay_off(i, j+1) + prob_down*pay_off(i+1, j+1));
        else if exercise == ExerciseType.AMERICAN
                if type == OptionType.CALL
                    pay_off(i, j) = max(stock_price(i, j) - strike, 1/Rate*(prob_up*pay_off(i, j+1) + prob_down*pay_off(i+1, j+1)));
                else
                    pay_off(i, j) = max(strike - stock_price(i, j), 1/Rate*(prob_up*pay_off(i, j+1) + prob_down*pay_off(i+1, j+1)));
                end
            end
        end
    end
end

price = pay_off(1, 1);
end


                    
        


