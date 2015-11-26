function [result] = GetColor(basecolor, angleValue)

    value = round(angleValue);

    endcolor = [1 1 1];

    r = linspace(basecolor(1,1), endcolor(1,1), 90);
    g = linspace(basecolor(1,2), endcolor(1,2), 90);
    b = linspace(basecolor(1,3), endcolor(1,3), 90);

    result = [r(value) g(value) b(value)];

end