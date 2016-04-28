function [ func ] = scaleRange( domain,range )
%imitate d3 scale function
%   Detailed explanation goes here
a = (range(2)-range(1))/(domain(2)-domain(1));
b = range(2)-domain(2)*a;
func = @(x)a*x+b;


end

